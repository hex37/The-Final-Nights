// ===================================================================
// About Me: Player Input - Overview Editing (aboutme_tgui_player_overview.dm)
// -------------------------------------------------------------------
// Handles editing of Overview tab fields via the About Me TGUI interface:
//   - Goals, personal quote, gender/pronouns, physical description
//   - UI input is routed here by aboutme_tgui.dm's ui_act() calls
//
// KEEP IT SIMPLE! This is the first impression and first menu most players see.
// The procs here serve as the basic expansion template for other UI editing features.
// ===================================================================

/**
 * Primary entry point when the player clicks "Edit Overview" in the UI.
 * Lets the player choose which overview category to edit.
 */
/datum/component/about_me/proc/prompt_edit_overview(mob/user)
	// Ask the player what overview section to edit
	var/choice = tgui_input_list(user, "Choose what to edit:", "Edit Overview", list(
		"Edit Goal/Quote",
		"Edit Details",
		"Back"
	), null, 0, GLOB.always_state)
	if (isnull(choice) || choice == "Back") return
	switch(choice)
		if ("Edit Goal/Quote")  return src.prompt_edit_overview_status(user)
		if ("Edit Details")     return src.prompt_edit_overview_other(user)
	return TRUE

/**
 * Prompts the player to edit their character's goals or personal quote.
 * These appear in the Overview tab for the player to see. Can be grabbed to display elsewhere.
 */
/datum/component/about_me/proc/prompt_edit_overview_status(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R) return
	var/choice = tgui_input_list(user, "Update what field?", "Status/Goals", list(
		"Goal",
		"Quote",
		"Back"
	), null, 0, GLOB.always_state)
	if (isnull(choice) || choice == "Back") return src.prompt_edit_overview(user)
	if (choice == "Goal")
		var/new_goals = tgui_input_text(user, "Ambition or goal?", "Edit Goals", R.edit_goals, encode = FALSE)
		if (!isnull(new_goals))
			R.set_goals(new_goals)
			to_chat(user, "<span class='notice'>Updated goals.</span>")
		return src.prompt_edit_overview_status(user)
	if (choice == "Quote")
		var/new_quote = tgui_input_text(user, "Your character's personal quote", "Edit Quote", R.edit_personal_quote, encode = FALSE)
		if (!isnull(new_quote))
			R.set_personal_quote(new_quote)
			to_chat(user, "<span class='notice'>Updated quote.</span>")
		return src.prompt_edit_overview_status(user)

/**
 * Prompts the player to edit gender/pronouns or their physical description.
 * These are also shown in the Overview tab.
 */
/datum/component/about_me/proc/prompt_edit_overview_other(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R) return
	var/choice = tgui_input_list(user, "Update character info:", "Details", list(
		"Gender(Pronouns)",
		"Physical Description",
		"Back"
	), null, 0, GLOB.always_state)
	if (isnull(choice) || choice == "Back") return src.prompt_edit_overview(user)
	if (choice == "Gender(Pronouns)")
		var/new_gender = tgui_input_text(user, "Gender/Pronouns", "Edit Gender", R.edit_gender, encode = FALSE)
		if (!isnull(new_gender))
			R.set_gender(new_gender)
			to_chat(user, "<span class='notice'>Updated gender/pronouns.</span>")
		return src.prompt_edit_overview_other(user)
	if (choice == "Physical Description")
		var/new_desc = tgui_input_text(user, "What do you look like?", "Edit Description", R.edit_physical_desc, encode = FALSE)
		if (!isnull(new_desc))
			R.set_physical_desc(new_desc)
			to_chat(user, "<span class='notice'>Updated physical description.</span>")
		return src.prompt_edit_overview_other(user)
