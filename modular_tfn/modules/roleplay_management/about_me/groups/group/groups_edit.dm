// ==============================================================================
// GROUP — EDIT (group_edit.dm)
// Role/membership mutations, safe & side-effect aware.
// ==============================================================================

/datum/group/proc/add_member_key(character_key)
	if (!character_key) return
	if (!(character_key in members))
		members += character_key
	// Optionally seed a baseline relationship:
	SSroleplay_management?.ensure_group_relationship(character_key, src, 50)
	touch()

/datum/group/proc/remove_member_key(character_key)
	if (!character_key) return
	members -= character_key
	leaders -= character_key
	officers -= character_key
	SSroleplay_management?.clear_group_relationship(character_key, src)
	touch()

/datum/group/proc/add_officer(character_key)
	if (!character_key) return
	if (!(character_key in members))
		members += character_key
	if (!(character_key in officers))
		officers += character_key
	SSroleplay_management?.ensure_group_relationship(character_key, src, 75)
	touch()

/datum/group/proc/add_leader(character_key)
	if (!character_key) return
	if (!(character_key in members))
		members += character_key
	if (!(character_key in leaders))
		leaders += character_key
	officers -= character_key
	SSroleplay_management?.ensure_group_relationship(character_key, src, 100)
	touch()

/datum/group/proc/promote_to_officer(character_key)
	if (!character_key || !(character_key in members)) return
	if (!(character_key in officers))
		officers += character_key
	SSroleplay_management?.ensure_group_relationship(character_key, src, 75)
	touch()

/datum/group/proc/promote_to_leader(character_key)
	if (!character_key || !(character_key in members)) return
	if (!(character_key in leaders))
		leaders += character_key
	officers -= character_key
	SSroleplay_management?.ensure_group_relationship(character_key, src, 100)
	touch()

/datum/group/proc/demote_officer(character_key)
	if (!character_key) return
	officers -= character_key
	touch()

/datum/group/proc/demote_leader(character_key)
	if (!character_key) return
	leaders -= character_key
	touch()
