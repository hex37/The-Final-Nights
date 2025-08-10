// ==============================================================================
// GROUP VOTING — CORE (group_voting_core.dm)
// ==============================================================================

/datum/group_vote
	var/id
	var/group_id
	var/vote_type           // "promote_officer", "promote_leader"
	var/target_character_key
	var/initiator_key
	var/list/votes = list() // character_key => TRUE/FALSE
	var/start_time
	var/duration = 600      // ticks

/datum/group_vote/New(group_id, vote_type, target_key, initiator)
	..()
	start_time = world.time
	id = "[vote_type]_[target_key]_[world.time]"
	src.group_id = group_id
	src.vote_type = vote_type
	src.target_character_key = target_key
	src.initiator_key = initiator

/datum/group_vote/proc/add_vote(ckey, value)
	if (isnull(value)) return
	votes[ckey] = !!value

/datum/group_vote/proc/has_voted(ckey)
	return ckey in votes

/datum/group_vote/proc/is_expired()
	return (world.time - start_time) > duration

/datum/group_vote/proc/is_complete(datum/group/G)
	if (!G) return FALSE
	var/list/eligible = list() + G.member_keys + G.officer_keys + G.leader_keys
	for (var/ckey in eligible)
		if (!(ckey in votes))
			return FALSE
	return TRUE

/datum/group_vote/proc/get_result()
	var/votes_yes = 0
	var/votes_no = 0
	for (var/_ in votes)
		if (votes[_]) votes_yes++
		else votes_no++
	return list("yes" = votes_yes, "no" = votes_no)
