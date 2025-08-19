// ==============================================================================
// GROUP VOTING — FLOWS (group_voting_flows.dm)
// Depends on group_core, group_voting_core.
// ==============================================================================

/datum/group
	var/list/active_votes = list()   // id => /datum/group_vote

/datum/group/proc/start_vote(vote_type, target_key, initiator_key)
	var/list/all = list() + members + officers + leaders

	// Single-member auto-promotion for officer case
	if (length(all) <= 1 && vote_type == "promote_officer" && initiator_key == target_key)
		if (!(initiator_key in officers))
			officers += initiator_key
			var/datum/component/about_me/C = SSroleplay_management.find_aboutme_component_by_character_id(initiator_key)
			if (C?.owner && ismob(C.owner))
				to_chat(C.owner, "<span class='notice'>You have been promoted to Officer of [name] as its only member.</span>")
		touch()
		return null

	var/datum/group_vote/V = new(src.id, vote_type, target_key, initiator_key)
	V.votes[initiator_key] = TRUE
	active_votes[V.id] = V

	// Notify members to vote (component prompt if you have it)
	for (var/c_key in all)
		if (c_key == initiator_key) continue
		var/datum/component/about_me/C = SSroleplay_management.find_aboutme_component_by_character_id(c_key)
		if (!C || !ismob(C.owner)) continue
		to_chat(C.owner, "<span class='notice'>A new vote has started in [src.name]!</span>")
		if (hascall(C, "prompt_vote_on_group"))
			C.prompt_vote_on_group(V)

	// Auto-resolve after duration
	spawn(V.duration + 5)
		resolve_votes()

	return V

/datum/group/proc/resolve_votes()
	for (var/vote_id in active_votes)
		var/datum/group_vote/V = active_votes[vote_id]
		if (!V) continue

		var/complete = V.is_complete(src)
		var/expired = V.is_expired()
		if (!complete && !expired) continue

		var/res = V.get_result()
		var/promote = res["yes"] > res["no"]
		var/target_key = V.target_character_key
		var/name_text = target_key // swap to pretty if you maintain name cache

		switch(V.vote_type)
			if ("promote_officer")
				if (promote && (target_key in (members + officers + leaders)))
					add_officer(target_key)
					to_chat_group("[name_text] has been promoted to Officer in [name].")
				else
					to_chat_group("Vote to promote [name_text] to Officer in [name] failed.")

			if ("promote_leader")
				if (promote && (target_key in (members + officers + leaders)))
					promote_to_leader(target_key)
					to_chat_group("[name_text] has been promoted to Leader in [name].")
				else
					to_chat_group("Vote to promote [name_text] to Leader in [name] failed.")

		active_votes -= vote_id
	touch()
