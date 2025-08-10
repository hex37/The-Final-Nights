// ==============================================================================
// ABOUT ME RECORD — EDIT (about_me_record_edit.dm)
// Only persistence edits; sanitize at UI entry-point.
// ==============================================================================

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

/datum/aboutme_record/proc/get_current_group_keys()
	return group_keys.Copy()
