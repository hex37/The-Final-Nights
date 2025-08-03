// ===================================================================
// About Me: Player Input - Overview Editing
// ===================================================================
// Overview details.
// Called from the Overview tab UI in AboutMeInt.jsx via TGUI Act button.
// Input sent here from aboutme_tgui.dm, ui_act.
// ===================================================================
//KEEP IT SIMPLE. This is a first impression of the system, likely the first buttons the players will press in the menu.
/// Primary entry point: launched when the player clicks "Edit Overview"

//This proc and following procs are a great easy to use examples to show how this can be expanded.
/datum/component/about_me/proc/prompt_edit_overview(mob/user)
	// Let the player pick which branching option they want to select.
	var/choice = tgui_input_list(user, "Choose what to edit:", "Edit Overview", list(
		"Edit Goal/Quote",           // Goals and personal quote
		"Edit Details",      // Gender/pronouns and description
		"Back"
	), null, 0, GLOB.always_state)
	if (isnull(choice) || choice == "Back")
		return
	switch(choice)
		if ("Edit Goal/Quote")
			return src.prompt_edit_overview_status(user)
		if ("Edit Details")
			return src.prompt_edit_overview_other(user)
	return TRUE

/// Edits the player's Goals or Quote.
/// These are displayed in the Overview tab of About Me.
/datum/component/about_me/proc/prompt_edit_overview_status(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R) return
	// Ask which status field to edit
	var/choice = tgui_input_list(user, "Update what field?", "Status/Goals", list(
		"Goal",
		"Quote",
		"Back"
	), null, 0, GLOB.always_state)
	if (isnull(choice) || choice == "Back")
		return src.prompt_edit_overview(user)
	if (choice == "Goal")
		var/new_goals = tgui_input_text(user, "Ambition or goal?", "Edit Goals", R.edit_goals, encode = FALSE)
		if (!isnull(new_goals))
			R.set_goals(new_goals)
			to_chat(user, "<span class='notice'>Updated goals.</span>")
		return src.prompt_edit_overview_status(user)
	if (choice == "Quote")
		var/new_quote = tgui_input_text(user, "Your character's personal quote", "Edit Quote", R.edit_personal_quote, encode = FALSE)
		if (!isnull(new_quote))
			R.set_goals(new_quote)
			to_chat(user, "<span class='notice'>Updated quote.</span>")
		return src.prompt_edit_overview_status(user)

/// Edits personal identity information:
/// Gender/Pronouns and a short physical description.
/datum/component/about_me/proc/prompt_edit_overview_other(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R) return
	var/choice = tgui_input_list(user, "Update character info:", "Details", list(
		"Gender(Pronouns)",             // "He/Him", "They/Them", etc.
		"Physical Description",  // Short visual descriptor
		"Back"
	), null, 0, GLOB.always_state)
	if (isnull(choice) || choice == "Back")
		return src.prompt_edit_overview(user)
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
