// ============================================================================
// About Me: Player Input - Chronicle Management (aboutme_tgui_player_chronicle.dm)
// ----------------------------------------------------------------------------
// Handles creation and viewing of personal and group chronicle entries from the
// About Me panel. Allows:
//   - Adding/viewing personal chronicle entries (character's own story)
//   - Adding/viewing group chronicle entries (officer/leader-only)
//   - UI input is routed here by TGUI act via aboutme_tgui.dm.
// ----------------------------------------------------------------------------
// NOTE: Chronicles are shared event logs, intended for memorable IC events and RP.
// ============================================================================

/**
 * Main entry point: Opens the Chronicle action menu for the player.
 * Lets the user choose between managing their personal or a group chronicle.
 */
/datum/component/about_me/proc/prompt_interact_chronicle(mob/user)
	message_admins("[key_name(user)] opened the Chronicle interaction panel.")

	var/choice = tgui_input_list(user, "Choose a chronicle action:", "Chronicle Interaction", list(
		"Manage Personal Chronicle",
		"Manage Group Chronicle",
		"Back"
	), null, 0, GLOB.always_state)

	if (isnull(choice) || choice == "Back") return

	switch(choice)
		if ("Manage Personal Chronicle") return src.prompt_manage_personal_chronicle(user)
		if ("Manage Group Chronicle")    return src.prompt_manage_group_chronicle(user)

	message_admins("[key_name(user)] selected Chronicle option: [choice]")
	return TRUE

/**
 * Handles adding and viewing entries in the player's personal chronicle.
 * Only visible to the player and staff.
 */
/datum/component/about_me/proc/prompt_manage_personal_chronicle(mob/user)
	var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(src.character_id)
	if (!R) return

	var/action = tgui_input_list(user, "Personal Chronicle Options:", "Personal Chronicle", list(
		"Add Entry",
		"View Entries",
		"Back"
	))
	if (isnull(action) || action == "Back") return src.prompt_interact_chronicle(user)

	switch(action)
		if ("Add Entry")
			var/title = tgui_input_text(user, "Title of the event:", "Chronicle Title")
			if (isnull(title) || !length(trim(title))) return

			var/desc = tgui_input_text(user, "Details about the event:", "Chronicle Description")
			if (isnull(desc) || !length(trim(desc))) return

			var/date = time2text(world.realtime, "YYYY-MM-DD hh:mm")

			var/datum/chronicle/entry = new(
				src.character_id,
				title,
				"event",
				desc,
				date
			)
			R.chronicle_keys += entry.id
			to_chat(user, "<span class='notice'>Personal chronicle entry added.</span>")
			message_admins("[key_name(user)] added personal chronicle entry '[title]'.")
			return

		if ("View Entries")
			return src.view_chronicles(user, R.chronicle_keys)

	return src.prompt_manage_personal_chronicle(user)

/**
 * Handles adding and viewing entries in a group chronicle.
 * Only available to group leaders or officers.
 */
/datum/component/about_me/proc/prompt_manage_group_chronicle(mob/user)
	var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(src.character_id)
	if (!R) return

	var/list/admin_groups = list()
	for (var/group_id in R.group_keys)
		var/datum/group/G = SSroleplay_management.get_group_by_id(group_id)
		if (!G) continue
		if ((src.character_id in G.leaders) || (src.character_id in G.officers))
			admin_groups["[G.name] ([G.gtype])"] = G

	if (!length(admin_groups))
		to_chat(user, "<span class='notice'>You are not a leader or officer in any group.</span>")
		return src.prompt_interact_chronicle(user)

	var/Gchoice = tgui_input_list(user, "Which group to manage?", "Group Chronicle", admin_groups)
	if (isnull(Gchoice) || !isdatum(Gchoice)) return

	var/datum/group/G = Gchoice

	var/action = tgui_input_list(user, "Action for [G.name]:", "Group Chronicle", list(
		"Add Entry",
		"View Entries",
		"Back"
	))
	if (isnull(action) || action == "Back") return src.prompt_manage_group_chronicle(user)

	switch(action)
		if ("Add Entry")
			var/title = tgui_input_text(user, "Title of the event:", "Chronicle Title")
			if (isnull(title) || !length(trim(title))) return

			var/desc = tgui_input_text(user, "Details about the event:", "Chronicle Description")
			if (isnull(desc) || !length(trim(desc))) return

			//var/date = time2text(world.realtime, "YYYY-MM-DD hh:mm")

			//var/datum/chronicle_entry/entry = new()

			//to_chat(user, "<span class='notice'>Group chronicle entry added for [G.name].</span>")
			//message_admins("[key_name(user)] added group chronicle '[title]' for [G.name].")

		if ("View Entries")
			return //src.view_chronicles(user, G.chronicle_keys)

	return src.prompt_manage_group_chronicle(user)

/**
 * Utility: Shows a list of chronicle entries with details to the user.
 * Filters for visibility (e.g. group members, player for personal, etc).
 */
/datum/component/about_me/proc/view_chronicles(mob/user, list/chronicle_ids)
	if (!length(chronicle_ids))
		to_chat(user, "<span class='notice'>No chronicle entries found.</span>")
		return

	to_chat(user, "<b>Chronicle Entries:</b>")
	for (var/key in chronicle_ids)
		var/datum/chronicle/C = SSroleplay_management.get_chronicle_by_key(key)
		if (!C || !C.is_visible_to(user, src.character_id)) continue

		var/date = C.created_at || "Unknown"
		var/desc = C.desc || "No details provided."
		to_chat(user, "<hr><b>[C.title]</b><br><i>[date]</i><br>[desc]")

	return
