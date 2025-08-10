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
	if (!character_key || !owner)
		return null

	// Return existing personal chronicle for this character, if any.
	for (var/datum/chronicle/C in GLOB.chronicles)
		if (C.scope == "personal" && C.owner_key == character_key)
			return C

	var/title = "[owner.real_name]'s Chronicle"
	var/desc = "(This is your personal chronicle of this night's events. Record your journey, important events, or reflections here. Your personal chronicle might get spotlighted!)"

	// New constructor: (id, scope, title, desc, owner_key, group_id, created_by_key)
	var/datum/chronicle/new_personal = new(
		null,
		"personal",
		title,
		desc,
		character_key,
		null,
		character_key
	)

	// Optional: mark with a tag for filtering
	if (!islist(new_personal.tags))
		new_personal.tags = list()
	if (!("personal" in new_personal.tags))
		new_personal.tags += "personal"

	// Link to the aboutme_record
	var/datum/aboutme_record/rec = get_aboutme_record(character_key)
	if (rec)
		if (!islist(rec.chronicle_keys))
			rec.chronicle_keys = list()
		if (!(new_personal.id in rec.chronicle_keys))
			rec.chronicle_keys += new_personal.id
		rec.touch()

	return new_personal

