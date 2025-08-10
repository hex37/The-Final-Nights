// ================================================================
// RP Management Subsystem - Core (0_ssroleplay_management_core.dm)
// ================================================================
// This file defines:
//   - Core subsystem declaration
//   - Global registries
//   - Subsystem verbs (debug, UI inspection)
//   - Shared validation and AboutMe access utilities
// ================================================================
// ---------------- SUBSYSTEM DEF ----------------
SUBSYSTEM_DEF(roleplay_management)
	name = "RP Management"
	init_order = INIT_ORDER_DEFAULT
	wait = 10
/datum/controller/subsystem/roleplay_management

/datum/controller/subsystem/roleplay_management/Initialize()
	..()
	SSroleplay_management.rpm_register_canonical_groups()

/datum/controller/subsystem/roleplay_management/fire()
	..()
	for (var/group_id in GLOB.groups)
		var/datum/group/G = GLOB.groups[group_id]
		if (!G?.active_votes || !length(G.active_votes)) continue
		G.resolve_votes()





// ---------------- LOOKUPS & UTILITIES ----------------
/datum/controller/subsystem/roleplay_management/proc/get_aboutme_component(character_key)
	for (var/datum/component/about_me/C in GLOB.aboutme_components)
		if (C.character_key == character_key)
			return C
	return null

/datum/controller/subsystem/roleplay_management/proc/get_aboutme_record(character_key)
	if (!character_key || !is_valid_character_key(character_key))
		return null
	if (!(character_key in GLOB.aboutme_records))
		var/datum/aboutme_record/R = new()
		R.character_key = character_key
		GLOB.aboutme_records[character_key] = R
		check_register_valid_character_key(character_key)
	return GLOB.aboutme_records[character_key]

/datum/controller/subsystem/roleplay_management/proc/ensure_aboutme_record_for_key(character_key, mob/living/carbon/human/owner)
	if (!character_key)
		return null
	return get_aboutme_record(character_key)
// ---------------- VALIDATION ----------------
/datum/controller/subsystem/roleplay_management/proc/is_valid_key(key)
	return istext(key) && length(key) > 3

/datum/controller/subsystem/roleplay_management/proc/is_valid_character_key(character_key)
	return istext(character_key) && (character_key in GLOB.valid_character_keys)

/// Adds only if not already known and it works.
/datum/controller/subsystem/roleplay_management/proc/check_register_valid_character_key(character_key)
	if (istext(character_key) && !(character_key in GLOB.valid_character_keys))
		GLOB.valid_character_keys += character_key

/datum/controller/subsystem/roleplay_management/proc/get_relationship_by_id(rel_id)
	// Returns the relationship object with the given id, or null if not found
	if (!rel_id || !(rel_id in GLOB.relationships))
		return null
	return GLOB.relationships[rel_id]

/datum/controller/subsystem/roleplay_management/proc/about_me_new_id(prefix)
	if (!prefix) prefix = "id"
	var/tstamp = time2text(world.realtime, "YYYYMMDD_hhmmss")
	return "[prefix]_[tstamp]_[rand(100000, 999999)]"
