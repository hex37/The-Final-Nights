// ==============================================================================
// ABOUT ME RECORD — UI: GROUPS (about_me_record_ui_groups.dm)
// ==============================================================================

// about_me_record.dm
/datum/aboutme_record/proc/get_ui_groups(mob/living/carbon/human/owner)
	var/list/group_objects = list()
	for (var/group_key in group_keys)
		var/datum/group/G = SSroleplay_management.get_group_by_key(group_key)
		if (!G) continue
		var/gt = G.get_group_type()
		if (!(gt in group_objects))
			group_objects[gt] = list()
		group_objects[gt] += list(G.GetFormattedUI())
	return list("group_objects" = group_objects)

