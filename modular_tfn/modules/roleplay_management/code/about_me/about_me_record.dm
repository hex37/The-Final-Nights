// ==============================================================================
// CANONICAL ABOUT ME DATA RECORDS (aboutme_record.dm)
// ------------------------------------------------------------------------------
//  - Persistent data only: character identity, player-edited fields, group/rel/mem IDs.
//  - No runtime logic, mob refs, or component code.
//  - All data edits and fetches are handled here; SSRP/subsystem manages creation/deletion.
// ==============================================================================

/datum/aboutme_record
	// -- Initialization flags (used for onboarding/setup) --
	var/has_initialized_personal_chronicle = FALSE
	var/has_initialized_groups_from_role = FALSE
	var/has_initialized_entry_memory = FALSE

	// -- Unique character identity (persistent key, matches component) --
	var/character_key = null

	// -- Editable overview fields (persistent, player-editable) --
	var/edit_display_name = null
	var/edit_goals = null
	var/edit_personal_quote = null
	var/edit_gender = null
	var/edit_physical_desc = null

	// -- Canonical associations (store only persistent IDs, never mob refs) --
	var/list/group_keys = list()
	var/list/relationship_keys = list()
	var/list/chronicle_keys = list()
	var/list/memory_keys = list()

// ------------------------------------------------------------------------------
// PAYLOAD BUILDING: Returns full UI-safe payload for the TGUI panel.
// Mob is required for context! Never store mob refs or runtime state here.
// ------------------------------------------------------------------------------

/// Assembles and returns the full About Me payload for the TGUI panel.
/// Contains overview, groups, relationships, chronicle, and categorized memories.
/// @param owner The mob/living providing live context for rendering.
/datum/aboutme_record/proc/update_payload(mob/living/carbon/human/owner)
	return list(
		"overview" = get_ui_overview_data(owner),
		"groups" = get_ui_groups(owner),
		"relationships" = get_ui_relationships(owner),
		"chronicle" = get_ui_chronicles(owner),
		"memories" = get_ui_memories_by_tag(owner)
	)

/// Builds a dictionary of overview data for the panel's Overview tab.
/// Pulls from both saved fields and live mob state (name, species, stats, codes, etc).
/datum/aboutme_record/proc/get_ui_overview_data(mob/living/carbon/human/owner)
	var/list/general = list(
		"name" = (edit_display_name && edit_display_name != "") ? edit_display_name : (owner.real_name || "Unknown"),
		"role" = owner?.mind?.assigned_role || "Unknown",
		"species" = owner?.dna?.species?.name || "Unknown",
		"gender" = edit_gender || "",
		"physical_desc" = edit_physical_desc || "",
		"goals" = edit_goals || "",
		"personal_quote" = edit_personal_quote || ""
	)

	// --- Bank account code, if available ---
	if (owner.bank_id && GLOB.bank_account_list[owner.bank_id])
		var/datum/vtm_bank_account/account = GLOB.bank_account_list[owner.bank_id]
		general["bank_account_code"] = account.code


	// --- Role-specific codes ---
	var/role = owner?.mind?.assigned_role

	var/obj/keypad/armory/armory = find_keypad(/obj/keypad/armory)
	if (armory && (role in list("Prince", "Sheriff", "Seneschal")))
		general["armory_code"] = armory.pincode

	var/obj/keypad/panic_room/panic = find_keypad(/obj/keypad/panic_room)
	if (panic && role == "Prince", "Seneschal")
		general["panic_room_code"] = panic.pincode

	var/obj/structure/vaultdoor/pincode/bank/bankdoor = find_door_pin(/obj/structure/vaultdoor/pincode/bank)
	if (bankdoor)
		if (role == "Capo")
			general["bank_vault_code"] = bankdoor.pincode
		else if (role == "La Squadra" && prob(50))
			general["bank_vault_code"] = bankdoor.pincode

	// --- Player stats from mob/living ---
	var/list/stats = list(
		"Physique" = owner.get_total_physique(),
		"Dexterity" = owner.get_total_dexterity(),
		"Social" = owner.get_total_social(),
		"Mentality" = owner.get_total_mentality(),
		"Athletics" = owner.get_total_athletics(),
		"Lockpicking" = owner.get_total_lockpicking(),
		"Cruelty" = owner.get_total_blood()
	)
	general["stats"] = stats

	/// Builds the species block for About Me UI, delegating by species.
	var/datum/species/species_datum = owner.dna?.species
	var/species_type = istype(species_datum) ? species_datum.type : null

	switch (species_type)
		if (/datum/species/kindred)
			return list("general" = general, "species" = get_species_ui_kindred(owner))
		if (/datum/species/garou)
			return list("general" = general, "species" = get_species_ui_garou(owner))
		if (/datum/species/ghoul)
			return list("general" = general, "species" = get_species_ui_ghoul(owner))
		if (/datum/species/kuei_jin)
			return list("general" = general, "species" = get_species_ui_cathayan(owner))
	//more species cases as needed
	// Fallback/default
	return list("general" = general, "species" = get_species_ui_default(owner))

/// Returns a fully populated Kindred species block for About Me UI.
/datum/aboutme_record/proc/get_species_ui_kindred(mob/living/carbon/human/owner)
	var/list/species_block = list()
	var/datum/vampire_clan/clan = owner.clan
	species_block["clan"] = clan?.name || "Unknown"
	if (clan)
		species_block["clan_desc"] = clan.desc
		species_block["clan_curse"] = clan.curse
	species_block["generation"] = owner.generation || "Unknown"
	species_block["masquerade"] = "[owner.masquerade]"
	species_block["morality_path"] = owner.morality_path?.name || ""
	species_block["morality_score"] = owner.morality_path?.score || ""
	species_block["disciplines"] = list()
	var/datum/species/kindred/species_kindred = owner.dna?.species
	if (species_kindred && islist(species_kindred.disciplines))
		for (var/datum/discipline/discipline in species_kindred.disciplines)
			species_block["disciplines"] += list(list(
				"name" = discipline.name,
				"level" = discipline.level,
				"desc" = discipline.desc || ""
			))
	return species_block

/// Returns a fully populated Garou species block for About Me UI.
/datum/aboutme_record/proc/get_species_ui_garou(mob/living/carbon/human/owner)
	var/list/species_block = list()
	var/datum/auspice/auspice = owner.auspice
	species_block["masquerade"] = "[owner.masquerade]"
	species_block["tribe"] = auspice?.tribe?.name || "Unknown"
	species_block["auspice"] = auspice?.name || "Unknown"
	species_block["base_breed"] = auspice?.base_breed || "Unknown"
	species_block["gnosis"] = auspice?.gnosis || auspice?.start_gnosis || 0
	species_block["rage"] = auspice?.rage || auspice?.start_rage || 0
	species_block["honor"] = owner.honor || 0
	species_block["glory"] = owner.glory || 0
	species_block["wisdom"] = owner.wisdom || 0
	species_block["rank"] = RankName(owner.renownrank) || "Cub"
	species_block["gifts"] = list()
	if (auspice && islist(auspice.gifts))
		for (var/gift_path in auspice.gifts)
			var/datum/action/gift/gift = locate(gift_path)
			species_block["gifts"] += list(list(
				"name" = gift?.name || "[gift_path]",
				"desc" = gift?.desc || ""
			))
	return species_block

/// Returns a fully populated Ghoul species block for About Me UI.
/datum/aboutme_record/proc/get_species_ui_ghoul(mob/living/carbon/human/owner)
	var/list/species_block = list()
	var/datum/species/ghoul/ghoul_species = owner.dna?.species
	if (ghoul_species?.master)
		var/datum/species/kindred/master_kindred = ghoul_species.master.dna?.species
		var/datum/vampire_clan/master_clan = master_kindred.clan
		species_block["regnant"] = ghoul_species.master.real_name || "Unknown"
		species_block["regnant_clan"] = master_clan?.name || "Unknown"
	else
		species_block["regnant"] = ""
		species_block["regnant_clan"] = ""
	species_block["masquerade"] = "[owner.masquerade]"
	species_block["generation"] = owner.generation || 13
	species_block["disciplines"] = list()
	if (ghoul_species && islist(ghoul_species.disciplines))
		for (var/datum/discipline/discipline in ghoul_species.disciplines)
			species_block["disciplines"] += list(list(
				"name" = discipline.name,
				"level" = discipline.level,
				"desc" = discipline.desc || ""
			))
	if (owner.bloodpool || owner.maxbloodpool)
		species_block["bloodpool"] = "[owner.bloodpool || 0] / [owner.maxbloodpool || 0]"
	return species_block

/// Returns a fully populated Cathayan (Kuei-Jin) species block for About Me UI.
/datum/aboutme_record/proc/get_species_ui_cathayan(mob/living/carbon/human/owner)
	var/list/species_block = list()
	var/datum/mind/mind = owner.mind
	var/datum/dharma/dharma = mind?.dharma
	species_block["dharma"] = dharma?.name || ""
	species_block["dharma_level"] = dharma?.level || ""
	species_block["dharma_flavor"] = dharma?.desc || ""
	species_block["tenets"] = islist(dharma?.tenets) ? dharma.tenets : list()
	species_block["fails"] = islist(dharma?.fails) ? dharma.fails : list()
	species_block["po"] = dharma?.Po || ""
	species_block["hun"] = dharma?.Hun || ""
	species_block["animated"] = dharma?.animated || ""
	species_block["initial_skin_color"] = dharma?.initial_skin_color || ""
	species_block["max_yin_chi"] = owner.max_yin_chi || 0
	species_block["yin_chi"] = owner.yin_chi || 0
	species_block["max_yang_chi"] = owner.max_yang_chi || 0
	species_block["yang_chi"] = owner.yang_chi || 0
	species_block["max_demon_chi"] = owner.max_demon_chi || 0
	species_block["demon_chi"] = owner.demon_chi || 0
	species_block["masquerade"] = "[owner.masquerade]"
	return species_block

/// Default: Returns an empty species block (for baseline humans or unknown species).
/datum/aboutme_record/proc/get_species_ui_default(mob/living/carbon/human/owner)
	return list() //empty for now, doesn't show in UI

/// Returns all groups this character is a member of, organized by type, and formatted for UI.
/datum/aboutme_record/proc/get_ui_groups(mob/living/carbon/human/owner)
	var/list/group_objects = list()
	for (var/group_key in group_keys)
		var/datum/group/group = SSroleplay_management.get_group_by_key(group_key)
		if (!group)
			continue
		var/group_type = group.get_group_type()
		if (!(group_type in group_objects))
			group_objects[group_type] = list()
		group_objects[group_type] += group.GetFormattedUI()
	return list("group_objects" = group_objects)

/// Returns all relationships for this character that are visible to the viewer, formatted for UI.
/datum/aboutme_record/proc/get_ui_relationships(mob/living/carbon/human/owner)
	var/list/output = list()
	for (var/key in relationship_keys)
		var/datum/relationships/relationship = SSroleplay_management.get_relationship_by_key(key)
		if (!relationship.visible)
			continue
		output += list(relationship.GetFormattedUI())
	return output

/// Returns all chronicle (event) entries visible to the viewer, including participant/group names.
/datum/aboutme_record/proc/get_ui_chronicles(mob/user)
	var/list/visible = list()
	for (var/key in chronicle_keys)
		var/datum/chronicle/chronicle = SSroleplay_management.get_chronicle_by_key(key)
		if (!chronicle.is_visible_to(user, character_key))
			continue
		var/list/char_names = list()
		for (var/char_key in chronicle.related_characters)
			var/datum/component/about_me/component = SSroleplay_management.get_aboutme_component(char_key)
			char_names += component?.owner?.real_name || char_key
		var/list/group_names = list()
		for (var/group_key in chronicle.related_groups)
			var/datum/group/group = SSroleplay_management.get_group_by_key(group_key)
			group_names += group?.name || group_key
		var/event_data = chronicle.GetFormattedUI()
		event_data["related_characters"] = char_names
		event_data["related_groups"] = group_names
		visible += list(event_data)
	return list("events" = visible)

/// Returns categorized memories, filtered for viewer visibility, organized by tag/category.
/datum/aboutme_record/proc/get_ui_memories_by_tag(mob/user)
	var/list/by_tag = list(
		"memories_all" = list(),
		"background" = list(), "current" = list(), "recent" = list(),
		"goal" = list(), "secret" = list(), "reputation" = list(),
		"relationship" = list(), "character_memories" = list()
	)
	for (var/key in memory_keys)
		var/datum/memory/memory = SSroleplay_management.get_memory_by_key(key)
		if (!memory.is_visible_to(user, character_key))
			continue
		var/mem_ui = memory.GetFormattedUI()
		by_tag["memories_all"] += list(mem_ui)
		for (var/tag in memory.tags)
			if (tag in by_tag)
				by_tag[tag] += list(mem_ui)
	return by_tag

// ------------------------------------------------------------------------------
// EDITABLE FIELDS: Called by TGUI to update values. No mob refs—pure persistence.
// ------------------------------------------------------------------------------
/// Sets the character's display name (shown in Overview tab).
/datum/aboutme_record/proc/set_display_name(new_name)
	edit_display_name = new_name
/// Sets the character's personal goals.
/datum/aboutme_record/proc/set_goals(new_goal)
	edit_goals = new_goal
/// Sets the character's personal quote.
/datum/aboutme_record/proc/set_personal_quote(new_quote)
	edit_personal_quote = new_quote
/// Sets the character's gender field.
/datum/aboutme_record/proc/set_gender(new_gender)
	edit_gender = new_gender
/// Sets the character's physical description field.
/datum/aboutme_record/proc/set_physical_desc(new_phys_desc)
	edit_physical_desc = new_phys_desc

// HELPERS:
/// Returns a copy of all current group keys for this character (used for checks, UI, etc).
/datum/aboutme_record/proc/get_current_group_keys()
	return group_keys.Copy()
