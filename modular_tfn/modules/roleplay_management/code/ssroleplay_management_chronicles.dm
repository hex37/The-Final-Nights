// ================================================================
// RP Management Subsystem - Chronicles (ssroleplay_management_chronicles.dm)
// ================================================================
// Handles:
//   - Chronicle registration, lookup, and removal
//   - Personal chronicle creation on character entry
//   - Centralized global chronicle tracking
// ================================================================
// ---------------- REGISTRATION ----------------
/datum/controller/subsystem/roleplay_management/proc/register_chronicle(datum/chronicle/C)
	if (C?.id && is_valid_key(C.id))
		GLOB.chronicles[C.id] = C
/datum/controller/subsystem/roleplay_management/proc/unregister_chronicle(datum/chronicle/C)
	if (C?.id)
		GLOB.chronicles -= C.id
/datum/controller/subsystem/roleplay_management/proc/add_chronicle_entry(entry)
	GLOB.chronicles += entry
/datum/controller/subsystem/roleplay_management/proc/get_all_chronicles()
	return GLOB.chronicles
// ---------------- LOOKUP ----------------
/datum/controller/subsystem/roleplay_management/proc/get_chronicle_by_key(key)
	return is_valid_key(key) ? GLOB.chronicles[key] : null
// ---------------- PERSONAL CHRONICLE ----------------
/datum/controller/subsystem/roleplay_management/proc/ensure_personal_chronicle(character_key, mob/living/carbon/human/owner)
	if (!character_key || !owner) return null
	for (var/datum/chronicle/C in GLOB.chronicles)
		if (C.ctype == "personal" && C.host_key == character_key)
			return C // Already exists
	var/datum/chronicle/new_personal = new(
		host_key_arg = character_key,
		title_arg = "[owner.real_name]'s Chronicle",
		ctype_arg = "personal",
		desc_arg = "(This is your personal chronicle of this night's events. Record your journey, important events, or reflections here. Your personal chronicle might get spotlighted!)",
		related_characters_arg = list(character_key)
	)
	var/datum/aboutme_record/rec = get_aboutme_record(character_key)
	if (rec)
		rec.chronicle_keys += new_personal.id
	return new_personal
