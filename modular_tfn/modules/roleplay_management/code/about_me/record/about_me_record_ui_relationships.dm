// ==============================================================================
// ABOUT ME RECORD — UI: RELATIONSHIPS (about_me_record_ui_relationships.dm)
// ==============================================================================

/datum/aboutme_record/proc/get_ui_relationships(mob/living/carbon/human/owner)
	var/list/out = list()
	for (var/rkey in relationship_keys)
		var/datum/relationships/R = SSroleplay_management.get_relationship_by_key(rkey)
		out += list(R.GetFormattedUI())
	return out
