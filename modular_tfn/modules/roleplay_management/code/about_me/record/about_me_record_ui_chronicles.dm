// ==============================================================================
// ABOUT ME RECORD — UI: CHRONICLES (about_me_record_ui_chronicles.dm)
// ==============================================================================
/datum/aboutme_record/proc/get_ui_chronicles(mob/user)
	var/list/visible = list()
	for (var/ckey in chronicle_keys)
		var/datum/chronicle/C = SSroleplay_management.get_chronicle_by_key(ckey)
		if (!C || !C.is_visible_to(user, character_key)) continue
		var/list/event_data = C.GetFormattedUI()
		visible += list(event_data)
	return list("events" = visible)
