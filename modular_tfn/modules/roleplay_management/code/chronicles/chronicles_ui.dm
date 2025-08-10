// ==============================================================================
// CHRONICLE — UI (chronicle_ui.dm)
// Visibility + (optionally) richer payload helpers.
// ==============================================================================

/datum/chronicle/proc/is_visible_to(mob/user, character_key)
	if (!character_key) return FALSE
	switch (scope)
		if ("personal") return character_key == owner_key
		if ("group")
			var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(character_key)
			return !!(R && (group_id in R.group_keys))
		if ("active") return TRUE
	return TRUE

// If you want a richer payload later, add helper like GetFormattedUIRich() here.
