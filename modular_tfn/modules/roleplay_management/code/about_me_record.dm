// ==============================================================================
// CANONICAL ABOUT ME DATA RECORDS (aboutme_record.dm)
// ------------------------------------------------------------------------------
//  - Persistent data only: character identity, player-edited fields, group/rel/mem IDs.
//  - No runtime logic, mob refs, or component code.
//  - All data edits and fetches are handled here; SSRP/subsystem manages creation/deletion.
// ==============================================================================

/datum/aboutme_record
    // -- Initialization (setup, used for onboarding) --
    var/has_initialized_personal_chronicle = FALSE
    var/has_initialized_groups_from_role = FALSE
    var/has_initialized_entry_memory = FALSE

    // -- Unique identity (persistent key, matches component) --
    var/character_key = null

    // -- Editable overview fields --
    var/edit_display_name = null
    var/edit_goals = null
    var/edit_personal_quote = null
    var/edit_gender = null
    var/edit_physical_desc = null

    // -- Canonical associations --
    var/list/group_keys = list()
    var/list/relationship_keys = list()
    var/list/chronicle_keys = list()
    var/list/memory_keys = list()

// ------------------------------------------------------------------------------
// PAYLOAD BUILDING (TGUI/UI helpers): Mob argument required for context! No refs stored
// ------------------------------------------------------------------------------

/datum/aboutme_record/proc/update_payload(mob/living/carbon/human/owner)
    // Returns a dictionary for the About Me TGUI: Overview, Groups, Relationships, Chronicle, Memories
    return list(
        "overview" = get_ui_overview_data(owner),
        "groups" = get_ui_groups(owner),
        "relationships" = get_ui_relationships(owner),
        "chronicle" = get_ui_chronicles(owner),
        "memories" = get_ui_memories_by_tag(owner)
    )

/datum/aboutme_record/proc/get_ui_overview_data(mob/living/carbon/human/owner)
    // Builds the character overview for the UI panel (draws on persistent fields, uses mob for context)
    var/list/general = list(
        "name"            = (edit_display_name && edit_display_name != "") ? edit_display_name : (owner.real_name || "Unknown"),
        "role"            = owner?.mind?.assigned_role || "Unknown",
        "species"         = owner?.dna?.species?.name || "Unknown",
        "gender"          = edit_gender || "",
        "physical_desc"   = edit_physical_desc || "",
        "goals"           = edit_goals || "",
        "personal_quote"  = edit_personal_quote || ""
    )

    // --- Add bank account code if available ---
    for (var/datum/vtm_bank_account/account in GLOB.bank_account_list)
        if (owner.bank_id == account.bank_id)
            general["bank_account_code"] = account.code
            break

    // --- Add role-specific codes ---
    var/role = owner?.mind?.assigned_role

    // Armory Code (Prince, Sheriff, Seneschal)
    var/obj/keypad/armory/armory = find_keypad(/obj/keypad/armory)
    if (armory && (role in list("Prince", "Sheriff", "Seneschal")))
        general["armory_code"] = armory.pincode

    // Panic Room Code (Prince)
    var/obj/keypad/panic_room/panic = find_keypad(/obj/keypad/panic_room)
    if (panic && role == "Prince")
        general["panic_room_code"] = panic.pincode

    // Bank Vault Code (Capo always, La Squadra sometimes)
    var/obj/structure/vaultdoor/pincode/bank/bankdoor = find_door_pin(/obj/structure/vaultdoor/pincode/bank)
    if (bankdoor)
        if (role == "Capo")
            general["bank_vault_code"] = bankdoor.pincode
        else if (role == "La Squadra" && prob(50))
            general["bank_vault_code"] = bankdoor.pincode


    // -- Stats block --
    var/list/stats = list(
        "Physique"     = owner.get_total_physique(),
        "Dexterity"    = owner.get_total_dexterity(),
        "Social"       = owner.get_total_social(),
        "Mentality"    = owner.get_total_mentality(),
        "Athletics"    = owner.get_total_athletics(),
        "Lockpicking"  = owner.get_total_lockpicking(),
        "Cruelty"      = owner.get_total_blood()
    )
    general["stats"] = stats

    // -- Species-specific block (Kindred, Garou, Ghoul, etc), mob needed for live context --
    var/list/species_block = list()

    // Kindred
    if (iskindred(owner))
        var/datum/species/kindred/K = owner.dna?.species
        species_block["clan"]           = K.clan?.name || "None"
        species_block["generation"]     = owner.generation || "Unknown"
        species_block["masquerade"]     = "[owner.masquerade]"
        species_block["morality_path"]  = owner.morality_path?.name || ""
        species_block["morality_score"] = owner.morality_path?.score || ""
        species_block["disciplines"]    = list()
        if (K && islist(K.disciplines))
            for (var/datum/discipline/D in K.disciplines)
                species_block["disciplines"] += list(list(
                    "name"  = D.name,
                    "level" = D.level,
                    "desc"  = D.desc || ""
                ))

    // Garou
    else if (isgarou(owner))
        var/datum/auspice/a = owner.auspice
        species_block["masquerade"] = "[owner.masquerade]"
        species_block["tribe"]      = a?.tribe?.name || "Unknown"
        species_block["auspice"]    = a?.name || "Unknown"
        species_block["base_breed"] = a?.base_breed || "Unknown"
        species_block["gnosis"]     = a?.gnosis || a?.start_gnosis || 0
        species_block["rage"]       = a?.rage || a?.start_rage || 0
        species_block["honor"]      = owner.honor || 0
        species_block["glory"]      = owner.glory || 0
        species_block["wisdom"]     = owner.wisdom || 0
        species_block["rank"]       = RankName(owner.renownrank) || "Cub"
        species_block["gifts"]      = list()
        if (a && islist(a.gifts))
            for (var/G in a.gifts)
                var/datum/action/gift/g = locate(G)
                species_block["gifts"] += list(list(
                    "name" = g?.name || "[G]",
                    "desc" = g?.desc || ""
                ))

    // Ghoul
    else if (isghoul(owner))
        var/datum/species/ghoul/G = owner.dna?.species
        if (G?.master)
            var/datum/species/kindred/M = G.master.dna?.species
            species_block["regnant"] = G.master.real_name || "Unknown"
            species_block["regnant_clan"] = M.clan?.name || "Unknown"
        else
            species_block["regnant"] = ""
            species_block["regnant_clan"] = ""
        species_block["masquerade"] = "[owner.masquerade]"
        species_block["generation"] = owner.generation || 13
        species_block["disciplines"] = list()
        if (G && islist(G.disciplines))
            for (var/datum/discipline/D in G.disciplines)
                species_block["disciplines"] += list(list(
                    "name" = D.name,
                    "level" = D.level,
                    "desc" = D.desc || ""
                ))
        if (owner.bloodpool || owner.maxbloodpool)
            species_block["bloodpool"] = "[owner.bloodpool || 0] / [owner.maxbloodpool || 0]"

    // Cathayan (Kuei-Jin)
    else if (iscathayan(owner))
        var/datum/mind/M = owner.mind
        var/datum/dharma/D = M?.dharma
        species_block["dharma"]        = D?.name         || ""
        species_block["dharma_level"]  = D?.level        || ""
        species_block["dharma_flavor"] = D?.desc         || ""
        species_block["tenets"]        = islist(D?.tenets) ? D.tenets : list()
        species_block["fails"]         = islist(D?.fails) ? D.fails : list()
        species_block["po"]            = D?.Po           || ""
        species_block["hun"]           = D?.Hun          || ""
        species_block["animated"]      = D?.animated     || ""
        species_block["initial_skin_color"] = D?.initial_skin_color || ""
        species_block["max_yin_chi"]   = owner.max_yin_chi   || 0
        species_block["yin_chi"]       = owner.yin_chi       || 0
        species_block["max_yang_chi"]  = owner.max_yang_chi  || 0
        species_block["yang_chi"]      = owner.yang_chi      || 0
        species_block["max_demon_chi"] = owner.max_demon_chi || 0
        species_block["demon_chi"]     = owner.demon_chi     || 0
        species_block["masquerade"]    = "[owner.masquerade]"

    // Other species: add more blocks here as needed

    // -- Attach to UI overview result --
    return list("general" = general, "species" = species_block)


// ------------------------------------------------------------------------------
// UI PAYLOAD: Group, Relationship, Chronicle, Memory
// ------------------------------------------------------------------------------

/datum/aboutme_record/proc/get_ui_groups(mob/living/carbon/human/owner)
    // Returns a list (by group type) of all groups for this character, ready for UI
    var/list/group_objects = list()
    for (var/group_key in src.group_keys)
        var/datum/group/this_group = SSroleplay_management.get_group_by_key(group_key)
        if (!this_group) continue
        var/type = this_group.gtype || "unknown"
        if (!(type in group_objects)) group_objects[type] = list()
        group_objects[type] += this_group.GetFormattedUI()
    return list("group_objects" = group_objects)

/datum/aboutme_record/proc/get_ui_relationships(mob/living/carbon/human/owner)
    // Returns all relationships (for this character) visible to the viewer, ready for UI
    var/list/output = list()
    for (var/key in relationship_keys)
        var/datum/relationships/this_relationship = SSroleplay_management.get_relationship_by_key(key)
        if (!this_relationship || !this_relationship.visible) continue
        output += list(this_relationship.GetFormattedUI())
    return output

/datum/aboutme_record/proc/get_ui_chronicles(mob/user)
    // Returns all visible chronicle events for this character, for the UI
    var/list/visible = list()
    for (var/key in chronicle_keys)
        var/datum/chronicle/this_chronicle = SSroleplay_management.get_chronicle_by_key(key)
        if (!this_chronicle || !this_chronicle.is_visible_to(user, character_key)) continue
        var/list/char_names = list()
        for (var/char_key in this_chronicle.related_characters)
            var/datum/component/about_me/CMP = SSroleplay_management.get_aboutme_component(char_key)
            char_names += CMP?.owner?.real_name || char_key
        var/list/group_names = list()
        for (var/group_key in this_chronicle.related_groups)
            var/datum/group/this_group = SSroleplay_management.get_group_by_key(group_key)
            group_names += this_group?.name || group_key
        var/event_data = this_chronicle.GetFormattedUI()
        event_data["related_characters"] = char_names
        event_data["related_groups"] = group_names
        visible += list(event_data)
    return list("events" = visible)

/datum/aboutme_record/proc/get_ui_memories_by_tag(mob/user)
    // Returns categorized (by tag) memories for this character, ready for UI
    var/list/by_tag = list(
        "memories_all" = list(),
        "background" = list(), "current" = list(), "recent" = list(),
        "goal" = list(), "secret" = list(), "reputation" = list(),
        "relationship" = list(), "character_memories" = list()
    )
    for (var/key in memory_keys)
        var/datum/memory/this_memory = SSroleplay_management.get_memory_by_key(key)
        if (!this_memory || !this_memory.is_visible_to(user, character_key)) continue
        var/mem_ui = this_memory.GetFormattedUI()
        by_tag["memories_all"] += list(mem_ui)
        for (var/tag in this_memory.tags)
            if (tag in by_tag) by_tag[tag] += list(mem_ui)
    return by_tag

// ------------------------------------------------------------------------------
// EDITABLE FIELDS (Setters for persistent fields only)
// ------------------------------------------------------------------------------

/datum/aboutme_record/proc/set_display_name(new_name)
    edit_display_name = new_name

/datum/aboutme_record/proc/set_goals(new_goal)
    edit_goals = new_goal

/datum/aboutme_record/proc/set_personal_quote(new_quote)
    edit_personal_quote = new_quote

/datum/aboutme_record/proc/set_gender(new_gender)
    edit_gender = new_gender

/datum/aboutme_record/proc/set_physical_desc(new_phys_desc)
    edit_physical_desc = new_phys_desc

// ------------------------------------------------------------------------------
// UTILITY (No mob refs or component refs stored—pure data)
// ------------------------------------------------------------------------------

/datum/aboutme_record/proc/get_current_group_keys()
    return group_keys.Copy()

// ------------------------------------------------------------------------------
// END: aboutme_record.dm (REFINED FOR PURE DATA, UI-PAYLOAD-ONLY LOGIC)
// ------------------------------------------------------------------------------

