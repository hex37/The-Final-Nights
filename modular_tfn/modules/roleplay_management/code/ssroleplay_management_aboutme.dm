// ================================================================
// RP Management Subsystem - AboutMe Core (ssroleplay_management_aboutme.dm)
// ================================================================
// Handles:
//   - AboutMe record/component registration
//   - Initial group/memory/chronicle setup
//   - Character key tracking
//   - Basic AboutMe field get/set
// ================================================================
// ---------------- ABOUTME INITIALIZATION ----------------
/datum/controller/subsystem/roleplay_management/proc/check_initialize_aboutme_for(character_key, mob/living/carbon/human/owner, datum/component/about_me/C)
	var/datum/aboutme_record/rec = SSroleplay_management.ensure_aboutme_record_for_key(character_key, owner)
	if (!(C in GLOB.aboutme_components))
		SSroleplay_management.register_aboutme_component(C)
	if (!rec.has_initialized_personal_chronicle)
		SSroleplay_management.ensure_personal_chronicle(character_key, owner)
		rec.has_initialized_personal_chronicle = TRUE
	if (!rec.has_initialized_groups_from_role)
		SSroleplay_management.ensure_groups_from_role(character_key, owner)
		rec.has_initialized_groups_from_role = TRUE
	if (!rec.has_initialized_entry_memory)
		SSroleplay_management.ensure_entry_memory_for_key(character_key, owner)
		rec.has_initialized_entry_memory = TRUE
// ---------------- ABOUTME RECORD MANAGEMENT ----------------
/datum/controller/subsystem/roleplay_management/proc/register_aboutme_record(rec)
	if (rec)
		var/datum/aboutme_record/R = rec
		if (R.character_key)
			GLOB.aboutme_records[R.character_key] = R
/datum/controller/subsystem/roleplay_management/proc/unregister_aboutme_record(rec)
	if (rec)
		var/datum/aboutme_record/R = rec
		if (R.character_key)
			GLOB.aboutme_records -= R.character_key
/datum/controller/subsystem/roleplay_management/proc/get_aboutme_datum_for_key(character_key)
	return ensure_aboutme_record_for_key(character_key, null)
// ---------------- COMPONENT REGISTRATION ----------------
/datum/controller/subsystem/roleplay_management/proc/register_aboutme_component(C)
	if (C && !(C in GLOB.aboutme_components))
		GLOB.aboutme_components += C
/datum/controller/subsystem/roleplay_management/proc/unregister_aboutme_component(C)
	GLOB.aboutme_components -= C
/datum/controller/subsystem/roleplay_management/proc/find_aboutme_component_by_character_key(character_key)
	for (var/datum/component/about_me/C in GLOB.aboutme_components)
		if (C?.character_key == character_key)
			return C
	return null
// ---------------- GETTERS & FIELD SET ----------------
/datum/controller/subsystem/roleplay_management/proc/get_aboutme_payload_for_owner(mob/living/carbon/human/owner, character_key)
	var/datum/aboutme_record/rec = get_aboutme_record(character_key)
	return rec ? rec.update_payload(owner) : null
/datum/controller/subsystem/roleplay_management/proc/set_aboutme_field(character_key, field, value)
	var/datum/aboutme_record/rec = get_aboutme_record(character_key)
	switch (field)
		if ("display_name")      rec.set_display_name(value)
		if ("goals")             rec.set_goals(value)
		if ("personal_quote")    rec.set_personal_quote(value)
		if ("gender")            rec.set_gender(value)
		if ("physical_desc")     rec.set_physical_desc(value)
	return rec
// ---------------- PERSISTENCE ----------------
/datum/controller/subsystem/roleplay_management/proc/load_all_aboutme()
	// TODO: Load aboutme_records from file
	return
/datum/controller/subsystem/roleplay_management/proc/save_all_aboutme()
	// TODO: Save aboutme_records to file
	return
