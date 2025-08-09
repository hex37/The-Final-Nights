// ============================================================================
// Base Group Datum and Voting System (group.dm)
// ----------------------------------------------------------------------------
// Core group representation for About Me and RP Management.
//   - Stores membership, leadership, officer roles, member names, and group meta
//   - Tracks group relationships, chronicles, and active votes
//   - Provides add/remove/promotion/demotion APIs for all group roles
//   - Handles group invites and notification
//
// Voting logic handled by /datum/group_vote:
//   - Supports officer and leader promotion votes within a group
//   - Tracks votes, results, expiration, and automatic resolution
// ============================================================================

/**
 * Base group datum.
 * - is_public:      If TRUE, anyone can join this group; if FALSE, leaders/officers must approve.
 * - id:             Unique group ID (auto-generated if not set).
 * - name:           Group display name.
 * - gtype:          Group type (e.g., "clan", "sect", "organization", "party").
 * - desc:           Description of the group.
 * - tags:           Tags for type filtering and group searches.
 * - leader_name:    Display name for the main leader (optional).
 * - leaders:        List of character_keys for group leaders.
 * - officers:       List of character_keys for group officers.
 * - members:        List of character_keys for regular group members.
 * - group_relationship_keys: All relationship datums connecting this group to characters.
 * - orders:         Orders/motto/instructions set by group leadership (editable).
 * - member_names:   Map of character_key => display_name, for all group members.
 * - ispublic:       (Legacy, use is_public instead) TRUE if public, else restricted.
 * - chronicle_keys: List of chronicle/event IDs linked to this group.
 * - active_votes:   List of active group_vote datums (id => /datum/group_vote), for role voting.
 *
 * All core group logic, membership changes, role management, and relationship logic
 * are defined on this base datum and inherited by specific group types (clan, org, etc).
 */

/datum/group
	var/is_public = FALSE       // If TRUE, anyone can join; else, requires leader/officer approval.
	var/id                      // Unique group ID.
	var/name = "Some Group"
	var/gtype                   // Group type (e.g., "clan", "organization", etc.)
	var/desc
	var/tags
	var/leader_name
	var/list/leaders = list()   // List of character_keys (leaders)
	var/list/officers = list()  // List of character_keys (officers)
	var/list/members = list()   // List of character_keys (regular members)
	var/list/group_relationship_keys = list() // List of all group relationship datums
	var/orders = ""             // Group orders, editable by leaders
	var/list/member_names = list() // character_key => display_name
	var/ispublic = TRUE         // Legacy: duplicate of is_public, but keep for now
	var/list/chronicle_keys = list()   // Chronicle/event IDs for this group
	var/list/active_votes = list()     // id => /datum/group_vote

/datum/group/proc/get_group_type()
	// Prefer explicit, but fall back to checking the type path.
	if (gtype) return gtype
	if (istype(src, /datum/group/city))         return GROUP_TYPE_CITY
	if (istype(src, /datum/group/faction))      return GROUP_TYPE_FACTION
	if (istype(src, /datum/group/sect))         return GROUP_TYPE_SECT
	if (istype(src, /datum/group/clan))         return GROUP_TYPE_CLAN
	if (istype(src, /datum/group/tribe))        return GROUP_TYPE_TRIBE
	if (istype(src, /datum/group/organization)) return GROUP_TYPE_ORGANIZATION
	if (istype(src, /datum/group/party))        return GROUP_TYPE_PARTY
	return "unknown"

// Optional: set it once on construct if empty
/datum/group/New()
	..()
	if (!id)
		id = "[type]_[world.time]_[rand(1,1000000)]"
	if (!gtype)
		gtype = get_group_type()

/// On deletion, clean up registration.
/datum/group/Destroy()
	SSroleplay_management.unregister_group(src)
	..()

/// Checks if this group can be viewed by a user (based on character_key).
/datum/group/proc/can_be_viewed_by(mob/user, character_key)
	return (character_key in members) || (character_key in officers) || (character_key in leaders)


/datum/group/proc/prettify_character_key(key)
	if (!istext(key)) return key
	if (findtext(key, "_character_key"))
		var/base = replacetext(key, "_character_key", "")
		// Replace underscores with spaces, then capitalize each word
		base = capitalize_words(replacetext(base, "_", " "))
		return base
	return key

/datum/group/proc/capitalize_words(text)
	var/list/words = splittext(text, " ")
	for (var/i = 1, i <= length(words), i++)
		words[i] = capitalize(words[i])
	return jointext(words, " ")

/**
 * Returns a UI-safe formatted data structure for this group.
 * Includes leader/officer/member names, orders, etc.
 */
/datum/group/proc/GetFormattedUI()
	var/list/leader_names = list()
	var/list/officer_names = list()
	var/list/member_names = list()

	for (var/key in leaders)
		var/datum/component/about_me/C = SSroleplay_management.get_aboutme_component(key)
		var/display = prettify_character_key(key)
		if (!C)
			display += " (DC)"
		leader_names += display

	for (var/key in officers)
		var/datum/component/about_me/C = SSroleplay_management.get_aboutme_component(key)
		var/display = prettify_character_key(key)
		if (!C)
			display += " (DC)"
		officer_names += display

	for (var/key in members)
		var/datum/component/about_me/C = SSroleplay_management.get_aboutme_component(key)
		var/display = prettify_character_key(key)
		if (!C)
			display += " (DC)"
		member_names += display

	return list(
		"id"          = id,
		"name"        = name,
		"type"        = gtype || "unknown",
		"desc"        = desc,
		"tags"        = tags,
		"leader_name" = leader_name,
		"leaders"     = leader_names,
		"officers"    = officer_names,
		"members"     = member_names,
		"orders"      = orders
	)


/**
 * Returns display names for a given list of character_keys.
 */
/datum/group/proc/get_named_roles(keys)
	var/list/named = list()
	for (var/key in keys)
		named += member_names[key] || key
	return named

/// Adds a character to members (and registers initial group relationship).
/datum/group/proc/add_member_key(character_key, display_name = null)
	if (!character_key) return

	if (!(character_key in members))
		members += character_key
	if (display_name)
		member_names[character_key] = display_name

	SSroleplay_management.ensure_group_relationship(character_key, src, 50)

/// Adds a character as group leader (also ensures they are a member).
/datum/group/proc/add_leader(character_key, display_name = null)
	if (!character_key) return
	if (!(character_key in leaders))
		leaders += character_key
	if (!(character_key in members))
		members += character_key
	if (display_name)
		member_names[character_key] = display_name

	SSroleplay_management.ensure_group_relationship(character_key, src, 100)

/// Adds a character as group officer (also ensures they are a member).
/datum/group/proc/add_officer(character_key, display_name = null)
	if (!character_key) return
	if (!(character_key in officers))
		officers += character_key
	if (!(character_key in members))
		members += character_key
	if (display_name)
		member_names[character_key] = display_name

/// Checks if a character is a member, officer, or leader in this group.
/datum/group/proc/has_member(character_key)
	return (character_key in src.members) || (character_key in src.officers) || (character_key in src.leaders)

/// Promote a member to officer.
/datum/group/proc/promote_to_officer(character_key)
	if (!character_key || !(character_key in members)) return
	if (!(character_key in officers))
		officers += character_key
		SSroleplay_management.ensure_group_relationship(character_key, src, 75)
	return

/// Transfers group leadership to a new character (demotes all old leaders to officer, sets new leader).
/datum/group/proc/transfer_leadership_to(character_key)
	if (!character_key || !(character_key in members)) return

	// Demote all current leaders to officers
	for (var/L in leaders)
		if (!(L in officers))
			officers += L
	leaders.Cut()
	// Promote new leader
	if (!(character_key in leaders))
		leaders += character_key
	officers -= character_key
	to_chat_group("[member_names[character_key] || character_key] is now the Leader of [name].", src)

/// Demote an officer to regular member.
/datum/group/proc/demote_officer(character_key)
	if (!character_key) return
	officers -= character_key
	return

/// Promote a member or officer to leader.
/datum/group/proc/promote_to_leader(character_key)
	if (!character_key || !(character_key in members)) return
	if (!(character_key in leaders))
		leaders += character_key
		officers -= character_key
	return

/// Demote a leader (does not remove from membership).
/datum/group/proc/demote_leader(character_key)
	if (!character_key) return
	leaders -= character_key
	return

/// Removes a character entirely from all roles in this group and relationship.
/datum/group/proc/remove_member_key(character_key)
	if (!character_key) return
	members -= character_key
	officers -= character_key
	leaders -= character_key
	member_names -= character_key
	SSroleplay_management.clear_group_relationship(character_key, src)
	return

/**
 * Broadcasts a message to all online group members (any role).
 */
/datum/group/proc/to_chat_group(msg, datum/group/G)
	for (var/ckey in G.members + G.officers + G.leaders)
		var/datum/component/about_me/C = SSroleplay_management.get_aboutme_component(ckey)
		if (C?.owner && ismob(C.owner))
			to_chat(C.owner, "<span class='notice'>[msg]</span>")

/**
 * Officer invites a target character to the group.
 * Returns TRUE if accepted, FALSE if declined or invalid.
 */
/datum/group/proc/invite_member_prompt(officer_key, target_key)
	if (!officer_key || !target_key) return FALSE

	var/datum/component/about_me/C_officer = SSroleplay_management.get_aboutme_component(officer_key)
	var/datum/component/about_me/C_target = SSroleplay_management.get_aboutme_component(target_key)

	if (!C_officer?.owner || !ismob(C_officer.owner)) return FALSE
	if (!C_target?.owner || !ismob(C_target.owner)) return FALSE

	var/mob/living/carbon/human/user = C_officer.owner
	var/mob/living/carbon/human/target_mob = C_target.owner

	if (has_member(target_key))
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

// ============================================================================
// Voting System for Groups (promotion/demotion via in-character voting)
// ============================================================================

/**
 * Group voting datum. Tracks one active vote for officer/leader promotion.
 */
/datum/group_vote
	var/id
	var/group_id
	var/vote_type // e.g., "promote_leader", "promote_officer"
	var/target_character_key
	var/initiator_key
	var/list/votes = list() // ckey => TRUE/FALSE
	var/start_time
	var/duration = 600 // 60 seconds

/datum/group_vote/New(group_id, vote_type, target_key, initiator)
	..()
	src.start_time = world.time
	id = "[vote_type]_[target_key]_[world.time]"
	src.group_id = group_id
	src.vote_type = vote_type
	src.target_character_key = target_key
	src.initiator_key = initiator

/// Add a vote for this vote datum.
/datum/group_vote/proc/add_vote(ckey, value)
	if (isnull(value)) return
	votes[ckey] = value

	var/datum/group/G = SSroleplay_management.get_group_by_key(src.group_id)
	if (G && is_complete(G))
		G.resolve_votes()

/// Returns TRUE if the given ckey has already voted.
/datum/group_vote/proc/has_voted(ckey)
	return ckey in votes

/// Returns TRUE if the vote has expired (duration passed).
/datum/group_vote/proc/is_expired()
	return (world.time - start_time) > duration

/// Returns TRUE if all eligible members have voted.
/datum/group_vote/proc/is_complete(datum/group/G)
	if (!G) return FALSE
	var/list/eligible = G.members + G.officers + G.leaders
	for (var/ckey in eligible)
		if (!(ckey in votes))
			return FALSE
	return TRUE

/// Returns a result object: number of yes/no votes.
/datum/group_vote/proc/get_result()
	var/votes_yes = 0
	var/votes_no = 0
	for (var/voter in votes)
		var/value = votes[voter]
		if (value)
			votes_yes++
		else
			votes_no++
	return list("yes" = votes_yes, "no" = votes_no)

/**
 * Starts a new vote in the group (for promotion to officer/leader).
 * Auto-promotes sole members, otherwise creates a group_vote datum.
 */
/datum/group/proc/start_vote(vote_type, target_key, initiator_key)
	// If only one member (initiator), auto-promote them.
	var/all_members = list() + src.members + src.officers + src.leaders
	if (length(all_members) <= 1 && vote_type == "promote_officer" && initiator_key == target_key)
		if (!(initiator_key in src.officers))
			src.officers += initiator_key
			var/datum/component/about_me/C = SSroleplay_management.get_aboutme_component(initiator_key)
			if (C?.owner && ismob(C.owner))
				to_chat(C.owner, "<span class='notice'>You have been promoted to Officer of [src.name] as its only member.</span>")
		return null
	// Start vote and count initiator's vote as YES
	var/datum/group_vote/V = new(src.id, vote_type, target_key, initiator_key)
	V.votes[initiator_key] = "yes"
	src.active_votes[V.id] = V
	// Notify all members (except initiator)
	for (var/c_key in all_members)
		if (c_key == initiator_key) continue
		var/datum/component/about_me/C = SSroleplay_management.get_aboutme_component(c_key)
		if (!C || !ismob(C.owner)) continue
		to_chat(C.owner, "<span class='notice'>A new vote has started in [src.name]!</span>")
		C.prompt_vote_on_group(V)
	// Automatically resolve after vote duration
	spawn(V.duration + 5)
		resolve_votes()
	return V

/**
 * Checks and resolves all active votes for this group (promotion or failure).
 * Broadcasts results and updates roles.
 */
/datum/group/proc/resolve_votes()
	for (var/vote_id in active_votes)
		var/datum/group_vote/V = active_votes[vote_id]
		if (!V || (!V.is_expired() && !V.is_complete(src))) continue

		var/res = V.get_result()
		var/promote = res["yes"] > res["no"]
		var/target_key = V.target_character_key
		var/name_text = member_names[target_key] || target_key

		var/datum/relationships/target_rel = null
		var/datum/aboutme_record/R = SSroleplay_management.get_aboutme_record(target_key)
		if (R)
			for (var/rid in R.relationship_keys)
				if (rid in src.group_relationship_keys)
					var/datum/relationships/test_rel = SSroleplay_management.get_relationship_by_key(rid)
					if (test_rel?.source_character == target_key && test_rel?.group_target_id == src.id)
						target_rel = test_rel
						break

		switch(V.vote_type)
			if ("promote officer")
				if (promote && has_member(target_key))
					add_officer(target_key, name_text)
					if (target_rel)
						target_rel.strength = 75
						target_rel.desc = "Promoted to Officer via vote."
					to_chat_group("[name_text] has been promoted to Officer in [name].", src)
				else
					to_chat_group("Vote to promote [name_text] to Officer in [name] failed.", src)

			if ("promote leader")
				if (promote && has_member(target_key))
					transfer_leadership_to(target_key)
					if (target_rel)
						target_rel.strength = 100
						target_rel.desc = "Promoted to Leader via vote."
					to_chat_group("[name_text] has been promoted to Leader in [name].", src)
				else
					to_chat_group("Vote to promote [name_text] to Leader in [name] failed.", src)

		active_votes -= vote_id
