// ==============================================================================
// RELATIONSHIP — UI (relationship_ui.dm)
// UI-safe formatting, visibility checks
// ==============================================================================

/**
 * Visibility:
 * - Subject always sees their own record.
 * - For character targets: that target also sees it.
 * - For group targets: member of that group sees it (via record.group_keys).
 */
/datum/relationships/proc/is_visible_to(mob/user, character_key)
	if (!character_key) return FALSE
	if (character_key == subject_key) return TRUE

	if (target_type == "character")
		return character_key == target_key

	if (target_type == "group")
		var/datum/aboutme_record/rec = SSroleplay_management.get_aboutme_record(character_key)
		if (!rec) return FALSE
		return (target_key in rec.group_keys)

	return FALSE

/datum/relationships/proc/GetFormattedUI()
	// resolve a friendly display for target
	var/target_display = target_key
	if (target_type == "group")
		var/datum/group/G = SSroleplay_management.get_group_by_key(target_key)
		target_display = G?.name || target_key

	return list(
		"id" = id,
		"name" = target_display,       // UI can also resolve prettier names from keys
		"desc" = "",                   // optional field (kept for future parity)
		"rtype" = rtype,
		"strength" = strength,
		"tags" = tags.Copy(),
		"visible" = visible,
		"mutual" = mutual,
		"target_type" = target_type,
		"target_key" = target_key,
		"related_memories" = related_memory_keys.Copy(),
		"created_at" = created_at,
		"updated_at" = updated_at
	)
