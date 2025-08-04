// ==============================================================================
// CANONICAL ABOUT ME DATA RECORDS (aboutme_record.dm)
// ------------------------------------------------------------------------------
//  - Represents persistent character data across sessions, round to round for now.
//  - Serves as the canonical "truth" for all character-related info shown in the About Me panel.
//  - Tracks editable overview fields, group affiliations, relationships, memories, and chronicles.
//  - All edits and access funnel through this datum, supporting future saves and dynamic role/group changes.
//  - Managed and created by the RP Management subsystem.
// ==============================================================================

/datum/aboutme_record
	// --------------------------------------------------------------------------
	// Initialization Flags (used to track setup actions)
	// --------------------------------------------------------------------------
	/// TRUE if this character has their personal chronicle set up.
	var/has_initialized_personal_chronicle = FALSE
	/// TRUE if this character has had group membership established from their role.
	var/has_initialized_groups_from_role = FALSE
	/// TRUE if this character has had an initial entry memory generated.
	var/has_initialized_entry_memory = FALSE

	// --------------------------------------------------------------------------
	// Identity Key (unique, persistent per character)
	// --------------------------------------------------------------------------
	/// Unique persistent key for this character (matches about_me.component's character_key)
	var/character_key = null

	// --------------------------------------------------------------------------
	// Editable Overview Fields (player-editable "About Me" info)
	// --------------------------------------------------------------------------
	var/edit_display_name = null
	var/edit_goals = null
	var/edit_personal_quote = null
	var/edit_gender = null
	var/edit_physical_desc = null

	// --------------------------------------------------------------------------
	// Canonical Associations (group, relationship, chronicle, memory keys)
	// --------------------------------------------------------------------------
	/// List of group IDs this character belongs to
	var/list/group_keys = list()
	/// List of relationship IDs for this character (player ↔ player or player ↔ group)
	var/list/relationship_keys = list()
	/// List of chronicle (event) IDs associated with this character
	var/list/chronicle_keys = list()
	/// List of memory IDs owned by this character
	var/list/memory_keys = list()


// ==============================================================================
// PAYLOAD BUILDING: Returns full UI-safe payload for the TGUI panel
// ==============================================================================

/// Assembles and returns the full About Me payload for the TGUI panel.
/// Contains overview, groups, relationships, chronicle, and categorized memories.
/// @param owner The mob/living associated with this record.
/datum/aboutme_record/proc/update_payload(mob/living/carbon/human/owner)
	return list(
		"overview" = build_overview_data(owner),
		"groups" = get_ui_groups(owner),
		"relationships" = get_ui_relationships(owner),
		"chronicle" = get_ui_chronicles(owner),
		"memories" = get_ui_memories_by_tag(owner)
	)


/// Builds a dictionary of overview data for the panel's Overview tab.
/// Pulls from both saved fields and live mob state (name, species, stats, codes, etc).
/datum/aboutme_record/proc/build_overview_data(mob/living/carbon/human/owner)
	var/list/general = list(
		"name"            = (edit_display_name && edit_display_name != "") ? edit_display_name : (owner.real_name || "Unknown"),
		"role"            = owner?.mind?.assigned_role || "Unknown",
		"species"         = owner?.dna?.species?.name || "Unknown",
		"gender"          = edit_gender || "",
		"physical_desc"   = edit_physical_desc || "",
		"goals"           = edit_goals || "",
		"personal_quote"  = edit_personal_quote || ""
	)
	// --- Role-specific codes Everyone gets a bank account code, then roles for bank, panic room, armory, etc
	for (var/datum/vtm_bank_account/account in GLOB.bank_account_list)
		if (owner.bank_id == account.bank_id)
			general["bank_account_code"] = account.code
			break
		var/role = owner?.mind?.assigned_role
		// Armory/Panic Room: Only for Prince, Sheriff, Seneschal
		var/obj/keypad/armory/armory = find_keypad(/obj/keypad/armory)
		if (armory && (role in list("Prince", "Sheriff", "Seneschal")))
			general["armory_code"] = armory.pincode
		var/obj/keypad/panic_room/panic = find_keypad(/obj/keypad/panic_room)
		if (panic && (role in list("Prince")))
			general["panic_room_code"] = panic.pincode
		// Bank Vault: Capo always, La Squadra sometimes
		var/obj/structure/vaultdoor/pincode/bank/bankdoor = find_door_pin(/obj/structure/vaultdoor/pincode/bank)
		if (bankdoor)
			if (role == "Capo")
				general["bank_vault_code"] = bankdoor.pincode
			else if (role == "La Squadra" && prob(50))
				general["bank_vault_code"] = bankdoor.pincode

	// --- Player stats from mob/living
	var/list/stats = list(
		"Physique"     = owner.get_total_physique(),
		"Dexterity"    = owner.get_total_dexterity(),
		"Social"       = owner.get_total_social(),
		"Mentality"    = owner.get_total_mentality(),
		"Athletics"    = owner.get_total_athletics(),
		"Lockpicking"  = owner.get_total_lockpicking(),
		"Cruelty"      = owner.get_total_blood(),
	)
	general["stats"] = stats

	// --- Species-specific details (Kindred, Garou, etc)
	var/list/species_block = list(
		"clan" = "", "generation" = "", "masquerade" = "", "morality_path" = "", "morality_score" = "",
		"disciplines" = list(), "regnant" = "", "regnant_clan" = "",
		"tribe" = "", "auspice" = "", "gifts" = list(),
		"rage" = "", "gnosis" = "", "willpower" = "",
	)
	if (iskindred(owner))
		var/datum/species/kindred/K = owner.dna?.species
		species_block["clan"]         = owner.clane?.name || "None"
		species_block["generation"]   = owner.generation || "Unknown"
		species_block["masquerade"] = "[owner.masquerade]"
		species_block["morality_path"] = owner.morality_path?.name || ""
		species_block["morality_score"] = owner.morality_path?.score || ""
		// species_block["regnant"] and ["regnant_clan"] planned for future
		if (K && islist(K.disciplines))
			for (var/datum/discipline/D in K.disciplines)
				species_block["disciplines"] += list(list(
					"name" = D.name,
					"level" = D.level,
					"desc" = D.desc || ""
				))
	return list("general" = general, "species" = species_block)


// ==============================================================================
// UI PAYLOAD HELPERS: Filter and return only what the viewer can see
// ==============================================================================
/// Groups a list of groups by their type (for UI display organization).
/datum/aboutme_record/proc/group_by_type(list/groups)
	var/list/by_type = list()
	for (var/G in groups)
		if (!islist(G)) continue
		var/type = G["type"]
		if (!istext(type) || !length(type)) type = "unknown"
		if (!(type in by_type)) by_type[type] = list()
		by_type[type] += G
	return by_type

/// Returns all groups this character is a member of, organized by type, and formatted for UI.
/datum/aboutme_record/proc/get_ui_groups(mob/living/carbon/human/owner)
	var/list/group_objects = list()
	for (var/group_key in src.group_keys)
		var/datum/group/G = SSroleplay_management.get_group_by_key(group_key)
		if (!G) continue
		var/type = G.gtype || "unknown"
		if (!(type in group_objects))
			group_objects[type] = list()
		group_objects[type] += G.GetFormattedUI()
	return list("group_objects" = group_objects)

/// Returns all relationships for this character that are visible to the viewer, formatted for UI.
/datum/aboutme_record/proc/get_ui_relationships(mob/living/carbon/human/owner)
	var/list/output = list()
	for (var/key in src.relationship_keys)
		var/datum/relationships/R = SSroleplay_management.get_relationship_by_key(key)
		if (!R || !R.visible) continue
		output += list(R.GetFormattedUI())
	return output

/// Returns all chronicle (event) entries visible to the viewer, including participant/group names.
/datum/aboutme_record/proc/get_ui_chronicles(mob/user)
	var/list/visible = list()
	for (var/key in chronicle_keys)
		var/datum/chronicle/C = SSroleplay_management.get_chronicle_by_key(key)
		if (!C || !C.is_visible_to(user, character_key)) continue
		var/list/char_names = list()
		for (var/char_key in C.related_characters)
			var/datum/component/about_me/CMP = SSroleplay_management.get_aboutme_component(char_key)
			char_names += CMP?.owner?.real_name || char_key
		var/list/group_names = list()
		for (var/group_key in C.related_groups)
			var/datum/group/G = SSroleplay_management.get_group_by_key(group_key)
			group_names += G?.name || group_key
		var/event_data = C.GetFormattedUI()
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
		var/datum/memory/M = SSroleplay_management.get_memory_by_key(key)
		if (!M || !M.is_visible_to(user, character_key)) continue
		var/mem_ui = M.GetFormattedUI()
		by_tag["memories_all"] += list(mem_ui)
		for (var/tag in M.tags)
			if (tag in by_tag)
				by_tag[tag] += list(mem_ui)
	return by_tag

// ==============================================================================
// EDITABLE FIELDS: Called by TGUI to update values
// ==============================================================================

/// Sets the character's display name (shown in Overview tab).
/datum/aboutme_record/proc/set_display_name(n)        edit_display_name = n
/// Sets the character's personal goals.
/datum/aboutme_record/proc/set_goals(n)               edit_goals = n
/// Sets the character's personal quote.
/datum/aboutme_record/proc/set_personal_quote(n)      edit_personal_quote = n
/// Sets the character's gender field.
/datum/aboutme_record/proc/set_gender(n)              edit_gender = n
/// Sets the character's physical description field.
/datum/aboutme_record/proc/set_physical_desc(n)       edit_physical_desc = n

// ==============================================================================
// UTILITY HELPERS
// ==============================================================================

/// Returns a copy of all current group keys for this character (used for checks, UI, etc).
/datum/aboutme_record/proc/get_current_group_keys(owner)
	return group_keys.Copy()
