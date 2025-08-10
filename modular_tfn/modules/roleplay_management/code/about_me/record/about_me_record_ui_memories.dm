// ==============================================================================
// ABOUT ME RECORD — UI: MEMORIES (about_me_record_ui_memories.dm)
// ==============================================================================

/datum/aboutme_record/proc/get_ui_memories_by_tag(mob/user)
	var/list/by_tag = list(
		"memories_all" = list(),
		"background" = list(), "current" = list(), "recent" = list(),
		"goal" = list(), "secret" = list(), "reputation" = list(),
		"relationship" = list(), "character_memories" = list()
	)
	for (var/mkey in memory_keys)
		var/datum/memory/M = SSroleplay_management.get_memory_by_key(mkey)
		if (!M || !M.is_visible_to(user, character_key)) continue
		var/mui = M.GetFormattedUI()
		by_tag["memories_all"] += list(mui)
		for (var/tag in M.tags)
			if (tag in by_tag)
				by_tag[tag] += list(mui)
	return by_tag
