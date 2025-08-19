// RP Management Subsystem - Chronicles (ssroleplay_management_chronicles.dm)
/datum/controller/subsystem/roleplay_management/proc/register_chronicle(datum/chronicle/C)
	if (C?.id && is_valid_id(C.id))
		GLOB.chronicles[C.id] = C
/datum/controller/subsystem/roleplay_management/proc/unregister_chronicle(datum/chronicle/C)
	if (C?.id)
		GLOB.chronicles -= C.id

/datum/controller/subsystem/roleplay_management/proc/get_chronicle_by_key(id)
	return is_valid_id(id) ? GLOB.chronicles[id] : null

/datum/controller/subsystem/roleplay_management/proc/ensure_personal_chronicle(character_key, mob/living/carbon/human/owner)
	if (!character_key || !owner)
		return null
	for (var/datum/chronicle/C in GLOB.chronicles)
		if (C.scope == "personal" && C.owner_key == character_key)
			return C
	var/title = "[owner.real_name]'s Chronicle"
	var/desc = "(This is your personal chronicle of this night's events. Record your journey, important events, or reflections here. Your personal chronicle might get spotlighted!)"
	var/datum/chronicle/new_personal = new(
		null,
		"personal",
		title,
		desc,
		character_key,
		null,
		character_key
	)
	if (!islist(new_personal.tags))
		new_personal.tags = list()
	if (!("personal" in new_personal.tags))
		new_personal.tags += "personal"
	var/datum/aboutme_record/rec = get_aboutme_record(character_key)
	if (rec)
		if (!islist(rec.chronicle_keys))
			rec.chronicle_keys = list()
		if (!(new_personal.id in rec.chronicle_keys))
			rec.chronicle_keys += new_personal.id
		rec.touch()
	return new_personal

