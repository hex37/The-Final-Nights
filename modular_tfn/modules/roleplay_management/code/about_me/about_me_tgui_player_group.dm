// ============================================================================
// About Me: Player Input - Group Management (aboutme_tgui_player_group.dm)
// ----------------------------------------------------------------------------
// Handles all TGUI-driven group actions from the About Me panel:
//   - Join, leave, create party/coterie groups
//   - View and interact with player's current groups
//   - Group administration tools for leaders and officers
//   - Voting, loyalty, member invites, and leader/officer management
//
// These procs are invoked by UI actions in the Groups tab.
// Groups are managed via GLOB.groups and tracked in each character's aboutme_record.
// ============================================================================

/**
 * Main entrypoint for group management UI.
 * Prompts the user to pick a group action: view, join, leave, or create.
 * Switches to the correct follow-up proc based on selection.
 */
/datum/component/about_me/proc/prompt_manage_groups(mob/user)
	var/choice = tgui_input_list(user, "What group action?", "Manage Groups", list(
		"My Groups", "Join Group", "Leave Group", "Create Party", "Back"
	), null, 0, GLOB.always_state)
	if (isnull(choice) || choice == "Back") return
	switch(choice)
		if ("My Groups") return src.prompt_manage_groups_my(user)
		if ("Join Group") return src.prompt_manage_groups_join(user)
		if ("Leave Group") return src.prompt_manage_groups_leave(user)
		if ("Create Party") return src.prompt_manage_groups_create(user)


/**
 * Lists all groups the player can interact with (excluding city/faction unless officer/leader).
 * Allows the player to select a group for member/leader/officer actions.
 */
/datum/component/about_me/proc/prompt_manage_groups_my(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R)
		to_chat(user, "<span class='alert'>Could not retrieve your character record.</span>")
		return src.prompt_manage_groups(user)
	if (!length(R.group_keys))
		to_chat(user, "<span class='notice'>You are not part of any groups.</span>")
		return src.prompt_manage_groups(user)

	var/character_key = R.character_key
	var/list/group_map = list()
	for (var/group_id in R.group_keys)
		var/datum/group/G = GLOB.groups[group_id]
		if (!G) continue
		// Filter out city/faction unless this user is officer/leader
		var/is_leader = (character_key in G.leaders)
		var/is_officer = (character_key in G.officers)
		if ((G.group_type == GROUP_TYPE_CITY || G.group_type == GROUP_TYPE_FACTION) && !is_leader && !is_officer)
			continue
		group_map[G.name] = G
	if (!length(group_map))
		to_chat(user, "<span class='notice'>You are not part of any groups you can interact with.</span>")
		return src.prompt_manage_groups(user)
	while (TRUE)
		var/group_key = tgui_input_list(user, "Select a group to interact with:", "My Groups", group_map)
		if (isnull(group_key)) break
		var/datum/group/G = group_map[group_key]
		if (!istype(G, /datum/group)) break
		src.prompt_my_group_view(user, G, R)


/**
 * Opens interactive options for the selected group:
 * - Member actions: Loyalty, propose officer vote
 * - Officer actions: Review loyalty, invite, promote leader vote
 * - Leader actions: Orders, promote/demote/remove members
 */
/datum/component/about_me/proc/prompt_my_group_view(mob/user, datum/group/this_group, datum/aboutme_record/R)
	if (!this_group || !R?.character_key) return
	var/character_key = R.character_key
	var/is_leader = (character_key in this_group.leaders)
	var/is_officer = (character_key in this_group.officers)
	while (TRUE)
		// Find this character's group relationship for loyalty
		var/datum/relationships/my_rel = null
		for (var/rid in R.relationship_keys)
			if (rid in this_group.group_relationship_keys)
				var/datum/relationships/test_rel = SSroleplay_management.get_relationship_by_key(rid)
				if (test_rel?.target_key == character_key && test_rel?.target_key == this_group.id)
					my_rel = test_rel
					break
		var/strength = my_rel?.strength || 0
		// Dynamic options based on role
		var/list/options = list("(Member) Loyalty: Raise", "(Member) Loyalty: Lower", "(Member) Promote Officer Vote")
		if (is_officer || is_leader)
			options += list("(Officer) Review Group Loyalty", "(Officer) Invite Member", "(Officer) Promote Leader Vote")
		if (is_leader)
			options += list("(Leader) Set Orders", "(Leader) Promote Member", "(Leader) Demote Member", "(Leader) Remove Member")
		options += "Back"
		var/selection = tgui_input_list(user, "[this_group.name] — Loyalty: [strength]", "Group View", options)
		if (isnull(selection) || selection == "Back") break
		switch(selection)
			// -- Loyalty adjustment (members)
			if ("(Member) Loyalty: Raise", "(Member) Loyalty: Lower")
				var/delta = (selection == "(Member) Loyalty: Raise") ? 10 : -10
				var/reason = tgui_input_text(user, "Why are you adjusting loyalty?", "Adjust Loyalty", encode = FALSE)
				if (isnull(reason)) continue
				if (!my_rel || !(my_rel.id in R.relationship_keys) || !(my_rel.id in this_group.group_relationship_keys))
					to_chat(user, "<span class='alert'>Could not update loyalty — invalid relationship binding.</span>")
					continue
				my_rel.strength = clamp(my_rel.strength + delta, 0, 100)
				to_chat(user, "<span class='notice'>Loyalty to [this_group.name] is now [my_rel.strength].</span>")

			// -- Propose officer vote (members)
			if ("(Member) Promote Officer Vote")
				var/list/candidates = list()
				for (var/key in this_group.members)
					if (!(key in this_group.leaders) && !(key in this_group.officers))
						candidates[this_group.member_keys[key] || key] = key
				if (!length(candidates))
					to_chat(user, "<span class='warning'>No eligible candidates found to promote.</span>")
					continue
				var/candidate_choice = tgui_input_list(user, "Who do you want to nominate for officer?", "Propose Vote", candidates)
				if (!candidate_choice || !istext(candidate_choice)) continue
				var/target_key = candidates[candidate_choice]
				var/datum/group_vote/V = this_group.start_vote("promote officer", target_key, character_key)
				if (!V)
					to_chat(user, "<span class='alert'>Failed to start a vote.</span>")
					continue
				to_chat(user, "<span class='notice'>Vote to promote [candidate_choice] to officer started.</span>")
				message_admins("[key_name(user)] started a vote to promote [candidate_choice] in [this_group.name].")

			// -- Propose leader vote (officers/leaders)
			if ("(Officer) Promote Leader Vote")
				var/list/candidates = list()
				for (var/key in this_group.officers)
					if (!(key in this_group.leaders))
						candidates[this_group.member_keys[key] || key] = key
				if (!length(candidates))
					to_chat(user, "<span class='warning'>No eligible officers available for promotion to leader.</span>")
					continue
				var/candidate_choice = tgui_input_list(user, "Which officer do you want to nominate for leader?", "Promote Leader Vote", candidates)
				if (!candidate_choice || !istext(candidate_choice)) continue
				var/target_key = candidates[candidate_choice]
				var/datum/group_vote/V = this_group.start_vote("promote leader", target_key, character_key)
				if (!V)
					to_chat(user, "<span class='alert'>Failed to start a vote for leader promotion.</span>")
					continue
				to_chat(user, "<span class='notice'>Vote to promote [candidate_choice] to leader started.</span>")
				message_admins("[key_name(user)] started a vote to promote [candidate_choice] to Leader in [this_group.name].")

			// -- Officer: Invite member
			if ("(Officer) Invite Member")
				var/list/valid_targets = list()
				for (var/target_key in GLOB.aboutme_records)
					if (this_group.member_keys && (target_key in this_group.member_keys))
						continue
					var/datum/component/about_me/C = SSroleplay_management.get_aboutme_component(target_key)
					if (!C?.owner || !ismob(C.owner)) continue
					var/mob/living/carbon/human/M = C.owner
					var/display_name = M.true_real_name || M.real_name || target_key
					valid_targets[display_name] = target_key
				if (!length(valid_targets))
					to_chat(user, "<span class='warning'>No valid players found to invite.</span>")
					continue
				var/choice = tgui_input_list(user, "Invite which character?", "Invite Member", valid_targets)
				if (!choice || !istext(choice)) continue
				var/target_key = valid_targets[choice]
				var/officer_key = R.character_key
				var/datum/component/about_me/TargetC = SSroleplay_management.get_aboutme_component(target_key)
				if (!TargetC?.owner || !ismob(TargetC.owner))
					to_chat(user, "<span class='warning'>Could not find target's mob to send invite.</span>")
					continue
				this_group.invite_member_prompt(officer_key, target_key)
				to_chat(user, "<span class='notice'>Sent invite to [choice].</span>")
				message_admins("[key_name(user)] sent an invite to [choice] for [this_group.name].")

			// -- Officer: Review group loyalty
			if ("(Officer) Review Group Loyalty")
				var/list/loyalty_report = list()
				for (var/rid in this_group.group_relationship_keys)
					if (!(rid in R.relationship_keys)) continue
					var/datum/relationships/rel = SSroleplay_management.get_relationship_by_key(rid)
					if (!rel || rel.target_key != this_group.id) continue
					var/rkey = rel.id
					var/role = "Unknown"
					if (rkey in this_group.leaders) role = "Leader"
					else if (rkey in this_group.officers) role = "Officer"
					else if (rkey in this_group.members) role = "Member"
					var/name = this_group.member_keys[rkey] || rkey
					loyalty_report += "[name] ([role]) — [rel.strength]"
				if (!length(loyalty_report))
					to_chat(user, "<span class='warning'>No valid loyalty entries found for this group.</span>")
				else
					to_chat(user, "<b>Loyalty Overview for [this_group.name]</b><br>[jointext(loyalty_report, "<br>")]")

			// -- Leader: Promote member to officer
			if ("(Leader) Promote Member")
				var/list/promote_candidates = list()
				for (var/key in this_group.members)
					if (!(key in this_group.officers) && !(key in this_group.leaders))
						promote_candidates[this_group.member_keys[key] || key] = key
				if (!length(promote_candidates))
					to_chat(user, "<span class='warning'>No valid candidates to promote.</span>")
					continue
				var/promote_choice = tgui_input_list(user, "Promote to Officer", "Select Member", promote_candidates)
				if (!promote_choice) continue
				var/target_key = promote_candidates[promote_choice]
				this_group.add_officer(target_key, this_group.member_keys[target_key])
				to_chat(user, "<span class='notice'>Promoted [promote_choice] to Officer.</span>")
				message_admins("[key_name(user)] promoted [promote_choice] to Officer in [this_group.name].")

			// -- Leader: Demote officer to member
			if ("(Leader) Demote Member")
				var/list/demote_targets = list()
				for (var/key in this_group.officers)
					if (!(key in this_group.leaders))
						demote_targets[this_group.member_keys[key] || key] = key
				if (!length(demote_targets))
					to_chat(user, "<span class='warning'>No officers available to demote.</span>")
					continue
				var/demote_choice = tgui_input_list(user, "Demote Officer", "Select Officer", demote_targets)
				if (!demote_choice) continue
				var/target_key = demote_targets[demote_choice]
				this_group.demote_officer(target_key)
				to_chat(user, "<span class='notice'>Demoted [demote_choice] to Member.</span>")
				message_admins("[key_name(user)] demoted [demote_choice] to Member in [this_group.name].")

			// -- Leader: Remove member from group
			if ("(Leader) Remove Member")
				var/list/remove_targets = list()
				for (var/key in this_group.members + this_group.officers + this_group.leaders)
					if (key != character_key)
						remove_targets[this_group.member_keys[key] || key] = key
				if (!length(remove_targets))
					to_chat(user, "<span class='warning'>No members available to remove.</span>")
					continue
				var/remove_choice = tgui_input_list(user, "Remove Member", "Select Member", remove_targets)
				if (!remove_choice) continue
				var/target_key = remove_targets[remove_choice]
				this_group.remove_member_key(target_key)
				to_chat(user, "<span class='notice'>Removed [remove_choice] from [this_group.name].</span>")
				message_admins("[key_name(user)] removed [remove_choice] from [this_group.name].")


/**
 * Shows all public organizations/parties the player can join or apply to.
 * - Parties are joined directly.
 * - Public organizations send a request to leadership, requiring IC approval.
 */
/datum/component/about_me/proc/prompt_manage_groups_join(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R) return
	var/character_key = src.character_key
	var/display_name = src.owner?.true_real_name || src.owner?.name || character_key
	var/list/join_options = list()
	for (var/group_id in GLOB.groups)
		var/datum/group/G = GLOB.groups[group_id]
		if (!G || !G.is_public || (group_id in R.group_keys)) continue
		// Only show public orgs and parties (sect/faction/city/clan/tribe hidden)
		if (G.group_type == GROUP_TYPE_PARTY)
			join_options["Join Party: [G.name]"] = G.id
		else if (G.group_type == GROUP_TYPE_ORGANIZATION)
			join_options["Apply to Organization: [G.name]"] = G.id
	if (!length(join_options))
		return to_chat(user, "<span class='notice'>No public organizations or parties are currently available to join.</span>")
	var/choice = tgui_input_list(user, "Select a group to join or apply to:", "Available Public Groups", join_options)
	if (!choice || !istext(choice)) return
	var/group_id = join_options[choice]
	var/datum/group/G = GLOB.groups[group_id]
	if (!G || (group_id in R.group_keys) || !G.is_public)
		to_chat(user, "<span class='alert'>Unable to join [G?.name || "selected group"].</span>")
		return src.prompt_manage_groups(user)
	if (G.group_type == GROUP_TYPE_PARTY)
		G.add_member_key(character_key, display_name)
		R.group_keys += group_id
		to_chat(user, "<span class='notice'>You have joined party/coterie/hosted-event: [G.name].</span>")
		message_admins("[key_name(user)] joined public party group: [G.name] ([group_id]).")
	else if (G.group_type == GROUP_TYPE_ORGANIZATION)
		to_chat(user, "<span class='notice'>Your application has been sent to [G.name]'s leadership. Please speak with them IC to complete the process.</span>")
		for (var/key in G.leaders + G.officers)
			var/datum/component/about_me/C = SSroleplay_management.get_aboutme_component(key)
			if (C?.owner && ismob(C.owner))
				to_chat(C.owner, "<span class='alert'>[display_name] has applied to join your organization: [G.name].</span>")
		message_admins("[key_name(user)] applied to join public organization group: [G.name] ([group_id]).")
	return src.prompt_manage_groups(user)


/**
 * Allows the player to leave eligible groups (except city, faction, clan, tribe, or high-loyalty orgs).
 * Disbands private party if leaving as last leader.
 */
/datum/component/about_me/proc/prompt_manage_groups_leave(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R) return
	var/character_key = src.character_key
	var/list/leave_options = list()
	for (var/group_id in R.group_keys)
		var/datum/group/G = GLOB.groups[group_id]
		if (!G) continue
		var/gtype = G.group_type
		var/strength = SSroleplay_management.get_relationship_strength(character_key, group_id)
		// Core groups, or those with high loyalty, cannot be left
		if (gtype == GROUP_TYPE_CITY)
			leave_options["(Cannot Leave) [G.name] - You have to walk out of the city, just reside here, or die."] = null
			continue
		if (gtype == GROUP_TYPE_FACTION)
			leave_options["(Cannot Leave) [G.name] - You can not stop being what you are, can you?"] = null
			continue
		if (gtype == GROUP_TYPE_CLAN || gtype == GROUP_TYPE_TRIBE)
			leave_options["(Cannot Leave) [G.name] - Your blood doesn't forget."] = null
			continue
		if (gtype == GROUP_TYPE_SECT && (isnull(strength) || strength > 10))
			leave_options["(Cannot Leave) [G.name] - Too loyal to abandon your sect [strength] > 10."] = null
			continue
		if (gtype == GROUP_TYPE_ORGANIZATION && (isnull(strength) || strength >= 30))
			leave_options["(Cannot Leave) [G.name] - Loyalty too high to leave [strength] > 30."] = null
			continue
		leave_options["Leave [G.name] ([G.group_type])"] = G
	if (!length(leave_options))
		return to_chat(user, "<span class='notice'>No eligible groups to leave.</span>")
	var/choice = tgui_input_list(user, "Choose group to leave:", "Leave Group", leave_options)
	if (!choice || !istext(choice)) return
	var/datum/group/selected_group = leave_options[choice]
	if (!selected_group) return
	var/group_id = selected_group.id
	// If private party and player is the last leader, disband group
	if (selected_group.group_type == GROUP_TYPE_PARTY && !selected_group.is_public && (character_key in selected_group.leaders))
		if (length(selected_group.leaders) == 1)
			to_chat(user, "<span class='alert'>You were the only leader of [selected_group.name]. The party has been disbanded.</span>")
			message_admins("[key_name(user)] disbanded party group [selected_group.name] ([group_id]) by leaving as last leader.")
			GLOB.groups -= group_id
			SSroleplay_management.unregister_group(selected_group)
			R.group_keys -= group_id
			return src.prompt_manage_groups(user)
	// Normal leave (remove all roles)
	selected_group.members -= character_key
	selected_group.leaders -= character_key
	selected_group.officers -= character_key
	selected_group.member_keys -= character_key
	R.group_keys -= group_id
	to_chat(user, "<span class='notice'>Left [selected_group.name].</span>")
	message_admins("[key_name(user)] left group [selected_group.name] ([group_id]).")

	return src.prompt_manage_groups(user)


/**
 * Allows the player to create a new party/coterie group, if they don't already lead one.
 * Party/coterie groups are always private, with the creator as first leader/member.
 */
/datum/component/about_me/proc/prompt_manage_groups_create(mob/user)
	var/datum/aboutme_record/R = src.get_record()
	if (!R) return
	var/character_key = src.character_key
	var/display_name = src.owner?.true_real_name || src.owner?.name || character_key
	// Prevent creating a second party group
	for (var/group_id in R.group_keys)
		var/datum/group/G = GLOB.groups[group_id]
		if (!G) continue
		if (G.group_type == GROUP_TYPE_PARTY && (character_key in G.leaders))
			to_chat(user, "<span class='alert'>You already lead a party group: [G.name]. You cannot create another.</span>")
			return src.prompt_manage_groups(user)
	var/group_name = tgui_input_text(user, "Enter a name for your new party group:", "Create Party Group", encode = FALSE)
	if (isnull(group_name) || !length(group_name)) return
	var/safe_id = "party_[lowertext(replacetext(group_name, " ", "_"))]_[world.time]"
	if (GLOB.groups[safe_id])
		return
	var/datum/group/party/G = new /datum/group/party()
	G.is_public = FALSE
	G.name = group_name
	G.group_type = GROUP_TYPE_PARTY
	G.id = safe_id
	G.leaders += character_key
	G.members += character_key
	G.member_keys[character_key] = display_name
	GLOB.groups[G.id] = G
	SSroleplay_management.register_group(G)
	R.group_keys += G.id
	SSroleplay_management.ensure_group_relationship(character_key, G, 100)
	to_chat(user, "<span class='notice'>You have created and joined a new party: [G.name]</span>")
	message_admins("[key_name(user)] created party group: [G.name] ([G.id])")
	return src.prompt_manage_groups(user)

