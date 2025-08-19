// About Me: Player Input - Overview Tab
/datum/component/about_me/proc/prompt_edit_overview(mob/user)
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

/datum/component/about_me/proc/prompt_edit_overview_status(mob/user)
	var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(src.character_id)
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
			R.edit_goals = new_goals
			to_chat(user, "<span class='notice'>Updated goals.</span>")
		return src.prompt_edit_overview_status(user)
	if (choice == "Quote")
		var/new_quote = tgui_input_text(user, "Your character's personal quote", "Edit Quote", R.edit_personal_quote, encode = FALSE)
		if (!isnull(new_quote))
			R.edit_personal_quote = new_quote
			to_chat(user, "<span class='notice'>Updated quote.</span>")
		return src.prompt_edit_overview_status(user)

/datum/component/about_me/proc/prompt_edit_overview_other(mob/user)
	var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(src.character_id)
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
			R.edit_gender = new_gender
			to_chat(user, "<span class='notice'>Updated gender/pronouns.</span>")
		return src.prompt_edit_overview_other(user)
	if (choice == "Physical Description")
		var/new_desc = tgui_input_text(user, "What do you look like?", "Edit Description", R.edit_physical_desc, encode = FALSE)
		if (!isnull(new_desc))
			R.edit_physical_desc = new_desc
			to_chat(user, "<span class='notice'>Updated physical description.</span>")
		return src.prompt_edit_overview_other(user)
