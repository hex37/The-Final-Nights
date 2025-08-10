// ==============================================================================
// GROUP — HELPERS (group_helpers.dm)
// ==============================================================================

/**
 * Broadcast a message to all members (keys-based; resolves to online mobs via component).
 */
/datum/group/proc/to_chat_group(msg)
	var/list/all = list() + member_keys + officer_keys + leader_keys
	for (var/ckey in all)
		var/datum/component/about_me/C = SSroleplay_management.get_aboutme_component(ckey)
		if (C?.owner && ismob(C.owner))
			to_chat(C.owner, "<span class='notice'>[msg]</span>")

/datum/group/var/tmp/list/leaders as anything
/datum/group/var/tmp/list/officers as anything
/datum/group/var/tmp/list/members as anything

/datum/group/proc/__legacy_lists_refresh()
	leaders = leader_keys.Copy()
	officers = officer_keys.Copy()
	members = member_keys.Copy()

// Call after major changes (or remove these shims when the codebase is updated).
/datum/group/proc/after_change_refresh()
	__legacy_lists_refresh()


/datum/group/proc/invite_member_prompt(officer_key, target_key)
	if (!officer_key || !target_key) return FALSE

	var/datum/component/about_me/C_officer = SSroleplay_management.get_aboutme_component(officer_key)
	var/datum/component/about_me/C_target = SSroleplay_management.get_aboutme_component(target_key)

	if (!C_officer?.owner || !ismob(C_officer.owner)) return FALSE
	if (!C_target?.owner || !ismob(C_target.owner)) return FALSE

	var/mob/living/carbon/human/user = C_officer.owner
	var/mob/living/carbon/human/target_mob = C_target.owner

	if (member_keys[target_key])
		to_chat(user, "<span class='warning'>[target_mob.real_name] is already in the group.</span>")
		return FALSE

	var/choice = tgui_alert(target_mob,
		"[user.true_real_name] has invited you to join [name]. Accept?",
		"Group Invitation",
		list("Accept", "Decline"))

	if (choice == "Accept")
		add_member_key(target_key, target_mob.true_real_name)
		var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(target_key)
		if (R && !(id in R.group_keys))
			R.group_keys += id

		to_chat(user, "<span class='notice'>[target_mob.true_real_name] accepted the invitation and joined [name].</span>")
		to_chat(target_mob, "<span class='notice'>You have joined the group: [name].</span>")
		message_admins("[key_name(user)]'s invitation to [target_mob.true_real_name] was accepted. They joined [name].")
		return TRUE
	else
		to_chat(user, "<span class='warning'>[target_mob.true_real_name] declined the invitation to join [name].</span>")
		to_chat(target_mob, "<span class='notice'>You declined the invitation to join [name].</span>")
		message_admins("[key_name(user)]'s invitation to [target_mob.true_real_name] was declined.")
		return FALSE
