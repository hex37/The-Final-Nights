// RP Management Subsystem - AboutMe Record
/datum/controller/subsystem/roleplay_management/proc/register_aboutme_component(datum/component/about_me/C)
	if (!C || !C.owner) return
	if (!(C in GLOB.aboutme_components))
		GLOB.aboutme_components += C

/datum/controller/subsystem/roleplay_management/proc/unregister_aboutme_component(datum/component/about_me/C)
	if (C && (C in GLOB.aboutme_components))
		GLOB.aboutme_components -= C

/datum/controller/subsystem/roleplay_management/proc/find_aboutme_component_by_character_id(character_id)
	for (var/datum/component/about_me/C in GLOB.aboutme_components)
		if (C?.character_id == character_id)
			return C
	return null

/datum/controller/subsystem/roleplay_management/proc/register_aboutme_record(datum/aboutme_record/R)
	if (!R || !R.character_id) return
	GLOB.aboutme_records[R.character_id] = R

/datum/controller/subsystem/roleplay_management/proc/unregister_aboutme_record(datum/aboutme_record/R)
	if (!R || !R.character_id) return
	GLOB.aboutme_records -= R.character_id

/datum/controller/subsystem/roleplay_management/proc/get_aboutme_record(character_id)
	if (!character_id) return null
	return GLOB.aboutme_records[character_id]

/datum/controller/subsystem/roleplay_management/proc/ensure_aboutme_record_for_id(character_id, mob/living/carbon/human/owner)
	if (!character_id) return null

	// 1) In-memory - runtime registry
	var/datum/aboutme_record/existing = get_aboutme_record(character_id)
	if (existing) return existing

	// 2) DB load
	var/datum/db/roleplay_management/DB = new
	var/list/row = DB.aboutme_get_record(character_id)
	if (islist(row))
		var/datum/aboutme_record/loaded = new(character_id)
		loaded.from_row_db(row)
		register_aboutme_record(loaded)
		return loaded

	// 3) Create new + seed
	var/datum/aboutme_record/R = new(character_id)
	register_aboutme_record(R)
	if (!R.has_initialized_entry_memory && owner)
		ensure_entry_memory_for_key(character_id, owner)
		R.has_initialized_entry_memory = TRUE
	if (!R.has_initialized_groups_from_role && owner)
		ensure_groups_from_role(character_id, owner)
		R.has_initialized_groups_from_role = TRUE
	if (!R.has_initialized_personal_chronicle && owner)
		ensure_personal_chronicle(character_id, owner)
		R.has_initialized_personal_chronicle = TRUE
	R.touch()
	return R

/datum/controller/subsystem/roleplay_management/proc/check_initialize_aboutme_for(character_id, mob/living/carbon/human/owner, datum/component/about_me/C)
	if (!character_id) return

	check_register_valid_character_id(character_id)
	if (C) register_aboutme_component(C)

	var/datum/aboutme_record/rec = ensure_aboutme_record_for_id(character_id, owner)

	if (!rec.has_initialized_personal_chronicle)
		ensure_personal_chronicle(character_id, owner)
		rec.has_initialized_personal_chronicle = TRUE

	if (!rec.has_initialized_groups_from_role)
		ensure_groups_from_role(character_id, owner)
		rec.has_initialized_groups_from_role = TRUE

	if (!rec.has_initialized_entry_memory)
		ensure_entry_memory_for_key(character_id, owner)
		rec.has_initialized_entry_memory = TRUE

	rec.touch()

/datum/controller/subsystem/roleplay_management/proc/get_aboutme_payload_for_owner(mob/living/carbon/human/owner, character_id)
	var/datum/aboutme_record/rec = get_aboutme_record(character_id)
	return rec ? rec.GetFormattedUI(owner) : null

/datum/controller/subsystem/roleplay_management/proc/set_aboutme_field(character_id, field, value)
	var/datum/aboutme_record/rec = get_aboutme_record(character_id)
	if (!rec) return null

	switch (field)
		if ("display_name")
			rec.edit_display_name = (istext(value) ? value : null)
		if ("goals")
			rec.edit_goals = (istext(value) ? value : null)
		if ("personal_quote")
			rec.edit_personal_quote = (istext(value) ? value : null)
		if ("gender")
			rec.edit_gender = (istext(value) ? value : null)
		if ("physical_desc")
			rec.edit_physical_desc = (istext(value) ? value : null)

	rec.touch()
	return rec

/datum/controller/subsystem/roleplay_management/proc/load_all_aboutme()
	// Intentionally left minimal; prefer on-demand ensure_aboutme_record_for_id()
	return

/datum/controller/subsystem/roleplay_management/proc/save_all_aboutme()
	// Iterate and save dirty records if desired
	for (var/id in GLOB.aboutme_records)
		var/datum/aboutme_record/R = GLOB.aboutme_records[id]
		if (R?.dirty)
			R.save()
	return
