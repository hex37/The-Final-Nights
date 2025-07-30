// ============================================================================
// About Me: Player Input - Relationship Management Entry Point
// ============================================================================
// This proc launches the relationship menu from the TGUI About Me panel.
// It branches into:
//
//   - Add New Relationship
//   - Edit or Remove Existing
//   - View All Relationships
//
// Each of those options should link to a dedicated proc.
// ============================================================================

/datum/component/about_me/proc/prompt_change_relationship(mob/user)
	message_admins("[key_name(user)] opened the Relationship editor.")

	var/choice = tgui_input_list(user, "Choose a relationship action:", "Manage Relationships", list(
		"Add New Relationship",
		"Edit or Remove Relationship",
		"View All Relationships",
		"Back"
	), null, 0, GLOB.always_state)

	if (isnull(choice) || choice == "Back") return

	message_admins("[key_name(user)] selected Relationship option: [choice]")

	switch(choice)
		if ("Add New Relationship") return src.prompt_add_relationship(user)
		if ("Edit or Remove Relationship") return src.prompt_edit_relationship(user)
		if ("View All Relationships") return src.prompt_view_relationships(user)

	return TRUE



/datum/component/about_me/proc/prompt_add_relationship(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R) return

	var/target_type = tgui_input_list(user, "Is this relationship with a character or group?", "Target Type", list("Character", "Group"))
	if (isnull(target_type)) return

	var/rel_name = tgui_input_text(user, "Enter the name of the [target_type]:", "Relationship Name")
	if (isnull(rel_name) || !length(trim(rel_name))) return

	var/rtype = tgui_input_list(user, "Select relationship type:", "Relationship Type", RELATIONSHIP_TYPE_KEYS)
	if (isnull(rtype)) return

	var/strength = tgui_input_number(user, "How strong is this relationship? (0–100)", "Loyalty", 50, 0, 100)
	if (isnull(strength)) return

	var/tags_input = tgui_input_text(user, "Tags (comma-separated): [jointext(RELATIONSHIP_TAGS_ALLOWED, ", ")]", "Tags", "")
	var/list/taglist = list()
	if (length(tags_input))
		for (var/T in splittext(tags_input, ","))
			var/tag = lowertext(trim(T))
			if (tag in RELATIONSHIP_TAGS_ALLOWED)
				taglist += tag

	var/datum/relationships/rel = new
	rel.name = rel_name
	rel.rtype = rtype
	rel.strength = strength
	rel.tags = taglist
	rel.source_character = src.character_key

	if (target_type == "Group")
		var/list/group_map = list()
		for (var/group_id in GLOB.groups)
			var/datum/group/G = GLOB.groups[group_id]
			if (!G) continue
			group_map["[G.name] ([G.gtype])"] = G

		var/group_choice = tgui_input_list(user, "Which group is this with?", "Group Target", group_map)
		if (isnull(group_choice) || !isdatum(group_choice)) return

		var/datum/group/G = group_choice
		rel.group_target_id = G.id

	else
		var/target_ckey = tgui_input_text(user, "Enter the character_key of the target (OOC username):", "Target Character")
		if (isnull(target_ckey) || !length(trim(target_ckey))) return

		rel.target_character = trim(target_ckey)

	// Register and persist
	R.relationship_keys += rel.id
	SSrpmanagement.register_relationship(rel)

	to_chat(user, "<span class='notice'>Relationship created with [rel.name].</span>")
	message_admins("[key_name(user)] created relationship with [rel.name] (type: [rtype], loyalty: [strength]).")

	return src.prompt_change_relationship(user)

/datum/component/about_me/proc/prompt_edit_relationship(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R || !length(R.relationship_keys)) return to_chat(user, "<span class='notice'>No relationships to edit.</span>")

	var/list/edit_map = list()
	for (var/key in R.relationship_keys)
		var/datum/relationships/rel = SSrpmanagement.get_relationship_by_key(key)
		if (!rel || !rel.is_visible_to(user, src.character_key)) continue

		var/label = rel.group_target_id ? "[rel.name] (Group)" : "[rel.name] (Character)"
		edit_map[label] = rel

	if (!length(edit_map))
		to_chat(user, "<span class='notice'>No relationships are visible to you.</span>")
		return src.prompt_change_relationship(user)

	var/choice = tgui_input_list(user, "Choose a relationship to edit:", "Edit Relationship", edit_map)
	if (isnull(choice) || !isdatum(choice)) return src.prompt_change_relationship(user)

	var/datum/relationships/rel = choice

	var/action = tgui_input_list(user, "Modify or Remove?", "Edit", list("Modify", "Delete", "Back"))
	if (isnull(action) || action == "Back") return src.prompt_edit_relationship(user)

	switch(action)
		if ("Modify")
			var/new_strength = tgui_input_number(user, "Update loyalty (0–100):", "Loyalty", rel.strength, 0, 100)
			var/new_tags = tgui_input_text(user, "Tags (comma-separated): [jointext(RELATIONSHIP_TAGS_ALLOWED, ", ")]", "Tags", jointext(rel.tags, ", "))

			var/list/taglist = list()
			if (!isnull(new_tags))
				for (var/T in splittext(new_tags, ","))
					var/tag = lowertext(trim(T))
					if (tag in RELATIONSHIP_TAGS_ALLOWED)
						taglist += tag

			if (!isnull(new_strength)) rel.strength = new_strength
			rel.tags = taglist

			to_chat(user, "<span class='notice'>Updated relationship with [rel.name].</span>")
			message_admins("[key_name(user)] updated relationship [rel.id].")

		if ("Delete")
			R.relationship_keys -= rel.id
			SSrpmanagement.unregister_relationship(rel)
			qdel(rel)
			to_chat(user, "<span class='alert'>Deleted relationship with [rel.name].</span>")
			message_admins("[key_name(user)] removed relationship [rel.id].")

	return src.prompt_edit_relationship(user)

/datum/component/about_me/proc/prompt_view_relationships(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R || !length(R.relationship_keys))
		to_chat(user, "<span class='notice'>You have no defined relationships.</span>")
		return src.prompt_change_relationship(user)

	var/visible = FALSE
	to_chat(user, "<b>Your Relationships:</b>")
	for (var/key in R.relationship_keys)
		var/datum/relationships/rel = SSrpmanagement.get_relationship_by_key(key)
		if (!rel || !rel.is_visible_to(user, src.character_key)) continue

		var/target = rel.group_target_id ? "Group: [rel.group_target_id]" : "Character: [rel.target_character]"
		to_chat(user, "<hr><b>Name:</b> [rel.name]<br><b>Type:</b> [rel.rtype]<br><b>Loyalty:</b> [rel.strength]<br><b>[target]</b><br><b>Tags:</b> [jointext(rel.tags, ", ")]")
		visible = TRUE

	if (!visible)
		to_chat(user, "<i>No visible relationships found.</i>")

	message_admins("[key_name(user)] viewed their relationships.")
	return src.prompt_change_relationship(user)


