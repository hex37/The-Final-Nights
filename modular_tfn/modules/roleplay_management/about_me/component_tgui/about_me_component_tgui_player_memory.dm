// ============================================================================
// About Me: Player Input - Memory Management (aboutme_tgui_player_memory.dm)
// ----------------------------------------------------------------------------
// Handles creation, editing, tagging, sharing, and viewing of memories (journal
// entries, secrets, RP notes) from the About Me TGUI panel.
// - Procs here are triggered by UI actions in the Memories tab.
// - Each memory is a flexible, taggable record visible to the player and optionally others.
// ----------------------------------------------------------------------------
// Notes:
//   • Tags are entered as comma-separated strings for organization/search.
//   • Future expansion could support memory sharing with other players/groups.
// ============================================================================

/**
 * Main entrypoint for the Memories tab management UI.
 * Lets the player choose to create, edit/delete, tag/share, or view memories.
 */
/datum/component/about_me/proc/prompt_manage_memories(mob/user)
	message_admins("[key_name(user)] opened the Memory manager.")

	var/choice = tgui_input_list(user, "Choose a memory action:", "Manage Memories", list(
		"Create New Memory",
		"Edit or Delete Memory",
		"Tag or Share Memory",
		"View All Memories",
		"Back"
	), null, 0, GLOB.always_state)

	if (isnull(choice) || choice == "Back") return

	switch(choice)
		if ("Create New Memory")      return src.prompt_create_memory(user)
		if ("Edit or Delete Memory")  return src.prompt_edit_memory(user)
		if ("Tag or Share Memory")    return src.prompt_tag_share_memory(user)
		if ("View All Memories")      return src.prompt_view_memories(user)

	message_admins("[key_name(user)] selected Memory option: [choice]")
	return TRUE

/**
 * Prompts the player to create a new memory record.
 * Memory must have a summary/title and details. Tags are optional.
 */
/datum/component/about_me/proc/prompt_create_memory(mob/user)
	var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(src.character_id)
	if (!R) return

	var/summary = tgui_input_text(user, "Memory title:", "New Memory")
	if (isnull(summary) || !length(trim(summary))) return

	var/details = tgui_input_text(user, "Memory description/details:", "Memory Details")
	if (isnull(details) || !length(trim(details))) return

	var/tags_input = tgui_input_text(user, "Memory tags (comma-separated):", "Tags", "")
	var/list/taglist = list()
	if (length(tags_input))
		for (var/T in splittext(tags_input, ",")) // Add tag validation if needed
			var/tag = lowertext(trim(T))
			taglist += tag

	var/datum/memory/M = new
	M.summary = summary
	M.details = details
	M.owner_key = src.character_id
	M.tags = taglist
	M.date_occurred = time2text(world.realtime, "YYYY-MM-DD hh:mm")

	R.memory_keys += M.id
	SSroleplay_management.register_memory(M)

	to_chat(user, "<span class='notice'>Memory '[summary]' created.</span>")
	message_admins("[key_name(user)] created memory '[summary]'.")
	return src.prompt_manage_memories(user)

/**
 * Prompts the player to edit or delete one of their memories.
 * Can modify summary/details, or delete the memory entirely.
 */
/datum/component/about_me/proc/prompt_edit_memory(mob/user)
	var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(src.character_id)
	if (!R || !length(R.memory_keys)) return to_chat(user, "<span class='notice'>You have no memories.</span>")

	var/list/edit_map = list()
	for (var/key in R.memory_keys)
		var/datum/memory/M = SSroleplay_management.get_memory_by_key(key)
		if (M && M.is_visible_to(user, src.character_id))
			edit_map["[M.summary] ([M.date_occurred])"] = M

	if (!length(edit_map)) return to_chat(user, "<span class='notice'>No editable memories found.</span>")

	var/choice = tgui_input_list(user, "Select memory to edit or delete:", "Edit Memory", edit_map)
	if (isnull(choice) || !isdatum(choice)) return

	var/datum/memory/M = choice

	var/action = tgui_input_list(user, "Modify or delete?", "Memory Action", list("Modify", "Delete", "Back"))
	if (isnull(action) || action == "Back") return src.prompt_edit_memory(user)

	switch(action)
		if ("Modify")
			var/new_summary = tgui_input_text(user, "Update title:", "Title", M.summary)
			var/new_details = tgui_input_text(user, "Update details:", "Details", M.details)

			if (!isnull(new_summary)) M.summary = new_summary
			if (!isnull(new_details)) M.details = new_details

			to_chat(user, "<span class='notice'>Memory updated.</span>")
			message_admins("[key_name(user)] updated memory [M.id].")

		if ("Delete")
			R.memory_keys -= M.id
			SSroleplay_management.unregister_memory(M)
			qdel(M)
			to_chat(user, "<span class='alert'>Memory deleted.</span>")
			message_admins("[key_name(user)] deleted memory [M.id].")

	return src.prompt_edit_memory(user)

/**
 * Prompts the player to retag or share a memory (currently only tags supported).
 * Updates the tags associated with a memory.
 */
/datum/component/about_me/proc/prompt_tag_share_memory(mob/user)
	var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(src.character_id)
	if (!R || !length(R.memory_keys)) return to_chat(user, "<span class='notice'>You have no memories.</span>")

	var/list/edit_map = list()
	for (var/key in R.memory_keys)
		var/datum/memory/M = SSroleplay_management.get_memory_by_key(key)
		if (M && M.is_visible_to(user, src.character_id))
			edit_map[M.summary] = M

	var/choice = tgui_input_list(user, "Select memory to tag/share:", "Tag/Share", edit_map)
	if (isnull(choice) || !isdatum(choice)) return

	var/datum/memory/M = choice

	var/tag_input = tgui_input_text(user, "New tags (comma-separated):", "Tags", jointext(M.tags, ", "))
	var/list/taglist = list()
	if (length(tag_input))
		for (var/T in splittext(tag_input, ",")) // Add tag validation if needed
			var/tag = lowertext(trim(T))
			taglist += tag
	M.tags = taglist

	to_chat(user, "<span class='notice'>Tags updated for memory '[M.summary]'.</span>")
	message_admins("[key_name(user)] retagged memory [M.id].")
	return src.prompt_manage_memories(user)

/**
 * Shows all memories to the player (one-page archive view).
 * Only shows memories visible to the current user.
 */
/datum/component/about_me/proc/prompt_view_memories(mob/user)
	var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(src.character_id)
	if (!R || !length(R.memory_keys))
		to_chat(user, "<span class='notice'>You have no memories saved.</span>")
		return

	to_chat(user, "<b>Memory Archive:</b>")
	for (var/key in R.memory_keys)
		var/datum/memory/M = SSroleplay_management.get_memory_by_key(key)
		if (!M || !M.is_visible_to(user, src.character_id)) continue

		to_chat(user, "<hr><b>[M.summary]</b><br><i>[M.date_occurred]</i><br>[M.details]<br><b>Tags:</b> [jointext(M.tags, ", ")]")

	message_admins("[key_name(user)] viewed their memories.")
	return src.prompt_manage_memories(user)
