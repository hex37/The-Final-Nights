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
/datum/controller/subsystem/roleplay_management/proc/ensure_group_relationship(subject_key, datum/group/G, initial_strength = 50)
	if (!subject_key || !G)
		return null

	// Return existing subject→group relationship if present
	for (var/datum/relationships/R in GLOB.relationships)
		if (R.subject_key == subject_key && R.target_type == "group" && R.target_key == G.id)
			// optionally sync strength upward
			if (isnum(initial_strength) && initial_strength > R.strength)
				R.set_strength(initial_strength)
			return R

	// Create new (auto-registers via New())
	var/datum/relationships/new_rel = new( null, subject_key, "group", G.id, "group", isnum(initial_strength) ? initial_strength : 50, subject_key)

	// Link onto the subject's About Me record
	var/datum/aboutme_record/rec = get_aboutme_record(subject_key)
	if (rec)
		if (!islist(rec.relationship_keys)) rec.relationship_keys = list()
		if (!(new_rel.id in rec.relationship_keys))
			rec.relationship_keys += new_rel.id
		rec.touch()

	// Link to group for group-side lookups
	if (!islist(G.group_relationship_keys)) G.group_relationship_keys = list()
	if (!(new_rel.id in G.group_relationship_keys))
		G.group_relationship_keys += new_rel.id
	G.touch()

	return new_rel


/// Finds or creates a group relationship by character and group_id.
/datum/controller/subsystem/roleplay_management/proc/get_or_create_group_relationship(character_key, group_id)
	if (!character_key || !group_id) return null
	for (var/datum/relationships/R in GLOB.relationships)
		if (R.subject_key == character_key && R.target_key == group_id)
			return R
	var/datum/group/G = GLOB.groups[group_id]
	if (!G) return null
	return SSroleplay_management.ensure_group_relationship(character_key, G, 0)
/// Creates a group relationship with a custom type/name/desc (used for events, tags, etc.)
/datum/controller/subsystem/roleplay_management/proc/CreateGroupRelationship(source_key, group_key, rtype, strength = 0, name = null, desc = "")
	if (!source_key || !group_key || !rtype) return
	var/datum/relationships/R = new()
	R.subject_key = source_key
	R.target_key = group_key
	R.rtype = rtype
	R.strength = strength
	R.name = name || "[rtype] toward [group_key]"
	GLOB.relationships[R.id] = R
	var/datum/aboutme_record/record = get_aboutme_record(source_key)
	if (record)
		record.relationship_keys += R.id

/// Returns the strength of a group relationship, or null if not found.
/datum/controller/subsystem/roleplay_management/proc/get_relationship_strength(character_key, group_id)
	for (var/datum/relationships/R in GLOB.relationships)
		if (R.subject_key == character_key && R.target_key == group_id)
			return R.strength
	return null

/// Removes all group relationships for the given group (e.g. on group disband/delete).
/datum/controller/subsystem/roleplay_management/proc/remove_all_group_relationships(group_id)
	var/list/to_delete = list()
	for (var/rel_id in GLOB.relationships)
		var/datum/relationships/rel = GLOB.relationships[rel_id]
		if (rel.target_key == group_id)
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
		if ((rel.subject_key == source_key && rel.target_key == target_key) || (rel.subject_key == target_key && rel.target_key == source_key))
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
		if ((rel.subject_key == key1 && rel.target_key == key2) || (rel.subject_key == key2 && rel.target_key == key1))
			return rel
	return null

/// Updates the strength value of a relationship by id.
/datum/controller/subsystem/roleplay_management/proc/update_relationship_strength(rel_id, new_strength)
	var/datum/relationships/rel = get_relationship_by_key(rel_id)
	if (rel)
		rel.strength = new_strength
		return TRUE
	return FALSE
