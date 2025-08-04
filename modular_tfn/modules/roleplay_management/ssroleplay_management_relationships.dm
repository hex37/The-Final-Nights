// ================================================================
// RP Management Subsystem - Relationships (ssroleplay_management_relationships.dm)
// ================================================================
// Handles:
//   - Player ↔ Group relationship creation and removal
//   - Player ↔ Player (mutual) relationship creation and removal
//   - Relationship lookup, formatting, and registration
// ================================================================
// ---------------- REGISTER / LOOKUP ----------------
/// Register a relationship datum in the global registry by its id.
/datum/controller/subsystem/roleplay_management/proc/register_relationship(datum/relationships/R)
	if (R?.id && is_valid_key(R.id))
		GLOB.relationships[R.id] = R
/// Returns the relationship datum by id, or null if not found.
/datum/controller/subsystem/roleplay_management/proc/get_relationship_by_key(key)
	return is_valid_key(key) ? GLOB.relationships[key] : null
/// Removes the relationship from the global registry.
/datum/controller/subsystem/roleplay_management/proc/unregister_relationship(datum/relationships/R)
	if (R?.id)
		GLOB.relationships -= R.id
// ---------------- GROUP RELATIONSHIPS ----------------
/// Ensures a relationship exists between a character and a group. Returns the datum.
/datum/controller/subsystem/roleplay_management/proc/ensure_group_relationship(character_key, datum/group/G, initial_strength = 0)
	if (!character_key || !G) return
	// Check for existing
	for (var/datum/relationships/R in GLOB.relationships)
		if (R.source_character == character_key && R.group_target_id == G.id)
			return R
	// Create new
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
	// Link to group (for group-side lookups)
	if (!(R.id in G.group_relationship_keys))
		G.group_relationship_keys += R.id
	return R
/// Finds or creates a group relationship by character and group_id.
/datum/controller/subsystem/roleplay_management/proc/get_or_create_group_relationship(character_key, group_id)
	if (!character_key || !group_id) return null
	for (var/datum/relationships/R in GLOB.relationships)
		if (R.source_character == character_key && R.group_target_id == group_id)
			return R
	var/datum/group/G = GLOB.groups[group_id]
	if (!G) return null
	return SSroleplay_management.ensure_group_relationship(character_key, G, 0)
/// Creates a group relationship with a custom type/name/desc (used for events, tags, etc.)
/datum/controller/subsystem/roleplay_management/proc/CreateGroupRelationship(source_key, group_key, rtype, strength = 0, name = null, desc = "")
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

/// Returns the strength of a group relationship, or null if not found.
/datum/controller/subsystem/roleplay_management/proc/get_relationship_strength(character_key, group_id)
	for (var/datum/relationships/R in GLOB.relationships)
		if (R.source_character == character_key && R.group_target_id == group_id)
			return R.strength
	return null

/// Removes all group relationships for the given group (e.g. on group disband/delete).
/datum/controller/subsystem/roleplay_management/proc/remove_all_group_relationships(group_id)
	var/list/to_delete = list()
	for (var/rel_id in GLOB.relationships)
		var/datum/relationships/rel = GLOB.relationships[rel_id]
		if (rel.group_target_id == group_id)
			to_delete += rel_id
	for (var/rel_id in to_delete)
		var/datum/relationships/rel = GLOB.relationships[rel_id]
		if (rel)
			unregister_relationship(rel)
			qdel(rel)

// ---------------- PERSONAL/MUTUAL RELATIONSHIPS ----------------
/// Removes the single shared relationship between two characters.
/datum/controller/subsystem/roleplay_management/proc/clear_personal_relationship(source_key, target_key)
	message_admins("Removing mutual relationship: [source_key] ↔ [target_key]")
	if (!source_key || !target_key)
		message_admins("Remove failed: missing source or target key!")
		return
	// Collect all matching relationship ids
	var/list/to_delete = list()
	for (var/rel_id in GLOB.relationships)
		var/datum/relationships/rel = GLOB.relationships[rel_id]
		if (!rel) continue
		if ((rel.source_character == source_key && rel.target_character == target_key) || (rel.source_character == target_key && rel.target_character == source_key))
			message_admins("Deleting rel.id=[rel.id] ([rel.name])")
			to_delete += rel_id
	// Actually remove all found
	for (var/rel_id in to_delete)
		var/datum/relationships/rel = GLOB.relationships[rel_id]
		if (rel)
			var/datum/aboutme_record/SourceR = get_aboutme_record(source_key)
			var/datum/aboutme_record/TargetR = get_aboutme_record(target_key)
			if (SourceR && (rel.id in SourceR.relationship_keys))
				SourceR.relationship_keys -= rel.id
				message_admins("Removed rel.id=[rel.id] from [source_key]")
			if (TargetR && (rel.id in TargetR.relationship_keys))
				TargetR.relationship_keys -= rel.id
				message_admins("Removed rel.id=[rel.id] from [target_key]")
			GLOB.relationships -= rel.id
			message_admins("Deleted rel.id=[rel.id] from global list")
			qdel(rel)
	return

/// Finds the relationship datum between two characters, or null.
/datum/controller/subsystem/roleplay_management/proc/find_relationship_between(key1, key2)
	var/datum/aboutme_record/R = get_aboutme_record(key1)
	if (!R) return null
	for (var/rel_id in R.relationship_keys)
		var/datum/relationships/rel = get_relationship_by_key(rel_id)
		if (!rel) continue
		if ((rel.source_character == key1 && rel.target_character == key2) || (rel.source_character == key2 && rel.target_character == key1))
			return rel
	return null

/// Updates the strength value of a relationship by id.
/datum/controller/subsystem/roleplay_management/proc/update_relationship_strength(rel_id, new_strength)
	var/datum/relationships/rel = get_relationship_by_key(rel_id)
	if (rel)
		rel.strength = new_strength
		return TRUE
	return FALSE
