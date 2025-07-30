// ================================================================
// RP Management Subsystem - Relationships (ssrpmanagement_relationships.dm)
// ================================================================
// Handles:
//   - Player ↔ Group relationship creation
//   - Relationship lookup, formatting, and registration
// ================================================================

// ---------------- REGISTER / LOOKUP ----------------
/datum/controller/subsystem/rpmanagement/proc/register_relationship(datum/relationships/R)
	if (R?.id && is_valid_key(R.id))
		GLOB.relationships[R.id] = R

/datum/controller/subsystem/rpmanagement/proc/get_relationship_by_key(key)
	return is_valid_key(key) ? GLOB.relationships[key] : null

/datum/controller/subsystem/rpmanagement/proc/unregister_relationship(datum/relationships/R)
	if (R?.id)
		GLOB.relationships -= R.id

// ---------------- HIGH-LEVEL CREATORS ----------------
/datum/controller/subsystem/rpmanagement/proc/ensure_group_relationship(character_key, datum/group/G, initial_strength = 0)
	if (!character_key || !G) return

	// Already exists?
	for (var/datum/relationships/R in GLOB.relationships)
		if (R.source_character == character_key && R.group_target_id == G.id)
			return R

	// Create new one
	var/datum/relationships/R = new()
	R.source_character = character_key
	R.group_target_id = G.id
	R.rtype = "group"
	R.strength = initial_strength
	R.name = "[G.name] Affiliation"
	R.desc = "Initial loyalty toward [G.name]"
	GLOB.relationships[R.id] = R

	// Link to aboutme record
	var/datum/aboutme_record/rec = get_aboutme_record(character_key)
	if (rec)
		rec.relationship_keys += R.id

	// Link to the group
	if (!(R.id in G.group_relationship_keys))
		G.group_relationship_keys += R.id

	return R


/datum/controller/subsystem/rpmanagement/proc/get_or_create_group_relationship(character_key, group_id)
	if (!character_key || !group_id) return null
	// First check if it exists
	for (var/datum/relationships/R in GLOB.relationships)
		if (R.source_character == character_key && R.group_target_id == group_id)
			return R
	// Attempt to create it
	var/datum/group/G = GLOB.groups[group_id]
	if (!G) return null
	return SSrpmanagement.ensure_group_relationship(character_key, G, 0)


/datum/controller/subsystem/rpmanagement/proc/CreateGroupRelationship(source_key, group_key, rtype, strength = 0, name = null, desc = "")
	if (!source_key || !group_key || !rtype) return

	var/datum/relationships/R = new()
	R.source_character = source_key
	R.group_target_id = group_key
	R.rtype = rtype
	R.strength = strength
	R.name = name || "[rtype] toward [group_key]"
	R.desc = desc

	GLOB.relationships[R.id] = R

	var/datum/aboutme_record/record = get_aboutme_record(source_key)
	if (record)
		record.relationship_keys += R.id


/datum/controller/subsystem/rpmanagement/proc/get_relationship_strength(character_key, group_id)
	for (var/datum/relationships/R in GLOB.relationships)
		if (R.source_character == character_key && R.group_target_id == group_id)
			return R.strength
	return null
