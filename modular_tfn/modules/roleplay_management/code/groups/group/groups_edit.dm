// ==============================================================================
// GROUP — EDIT (group_edit.dm)
// Role/membership mutations, safe & side-effect aware.
// ==============================================================================

/datum/group/proc/add_member_key(character_key)
	if (!character_key) return
	if (!(character_key in member_keys))
		member_keys += character_key
	// Optionally seed a baseline relationship:
	SSroleplay_management?.ensure_group_relationship(character_key, src, 50)
	touch()

/datum/group/proc/remove_member_key(character_key)
	if (!character_key) return
	member_keys -= character_key
	leader_keys -= character_key
	officer_keys -= character_key
	SSroleplay_management?.clear_group_relationship(character_key, src)
	touch()

/datum/group/proc/add_officer(character_key)
	if (!character_key) return
	if (!(character_key in member_keys))
		member_keys += character_key
	if (!(character_key in officer_keys))
		officer_keys += character_key
	SSroleplay_management?.ensure_group_relationship(character_key, src, 75)
	touch()

/datum/group/proc/add_leader(character_key)
	if (!character_key) return
	if (!(character_key in member_keys))
		member_keys += character_key
	if (!(character_key in leader_keys))
		leader_keys += character_key
	officer_keys -= character_key
	SSroleplay_management?.ensure_group_relationship(character_key, src, 100)
	touch()

/datum/group/proc/promote_to_officer(character_key)
	if (!character_key || !(character_key in member_keys)) return
	if (!(character_key in officer_keys))
		officer_keys += character_key
	SSroleplay_management?.ensure_group_relationship(character_key, src, 75)
	touch()

/datum/group/proc/promote_to_leader(character_key)
	if (!character_key || !(character_key in member_keys)) return
	if (!(character_key in leader_keys))
		leader_keys += character_key
	officer_keys -= character_key
	SSroleplay_management?.ensure_group_relationship(character_key, src, 100)
	touch()

/datum/group/proc/demote_officer(character_key)
	if (!character_key) return
	officer_keys -= character_key
	touch()

/datum/group/proc/demote_leader(character_key)
	if (!character_key) return
	leader_keys -= character_key
	touch()
