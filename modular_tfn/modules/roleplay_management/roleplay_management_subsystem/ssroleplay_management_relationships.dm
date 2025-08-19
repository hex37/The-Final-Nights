// RP Management Subsystem - Relationships (ssroleplay_management_relationships.dm)
/datum/controller/subsystem/roleplay_management/proc/register_relationship(datum/relationships/R)
	if (!R?.id) return
	GLOB.relationships[R.id] = R
	var/datum/aboutme_record/AR = SSroleplay_management.get_aboutme_record(R.owner_key)
	if (AR)
		if (!islist(AR.relationship_keys)) AR.relationship_keys = list()
		if (!(R.id in AR.relationship_keys)) AR.relationship_keys += R.id
		AR.touch()

/datum/controller/subsystem/roleplay_management/proc/unregister_relationship(datum/relationships/R)
	if (!R?.id) return
	var/datum/aboutme_record/AR = SSroleplay_management.get_aboutme_record(R.owner_key)
	if (AR && islist(AR.relationship_keys) && (R.id in AR.relationship_keys))
		AR.relationship_keys -= R.id
		AR.touch()
	GLOB.relationships -= R.id

/datum/controller/subsystem/roleplay_management/proc/get_relationship_by_key(id)
	return id ? GLOB.relationships[id] : null

/datum/controller/subsystem/roleplay_management/proc/ensure_relationship(owner_key, target_key, kind = "acquaintance")
	if (!owner_key || !target_key) return null
	for (var/rid in GLOB.relationships)
		var/datum/relationships/R = GLOB.relationships[rid]
		if (R?.owner_key == owner_key && R.target_key == target_key)
			return R
	var/datum/relationships/newrel = new(owner_key, target_key)
	newrel.kind = kind
	return newrel

/datum/controller/subsystem/roleplay_management/proc/ensure_group_relationship(owner_key, datum/group/G, initial_strength = 50)
	if (!owner_key || !G) return null

	// existing?
	var/list/existing = get_group_relationship_keys_for_owner(owner_key, G.id)
	if (length(existing))
		var/datum/relationships/R = GLOB.relationships[existing[1]]
		if (isnum(initial_strength) && initial_strength > (R.intensity || 0))
			R.intensity = initial_strength
			R.touch()
		return R

	var/datum/relationships/NewRel = new(owner_key, G.id)
	NewRel.kind = "group"
	NewRel.intensity = isnum(initial_strength) ? initial_strength : 50
	NewRel.label = "[owner_key] ↔ [G.name]"
	NewRel.touch()
	return NewRel

/datum/controller/subsystem/roleplay_management/proc/get_or_create_group_relationship(character_key, group_id)
	if (!character_key || !group_id) return null
	for (var/rid in GLOB.relationships)
		var/datum/relationships/R = GLOB.relationships[rid]
		if (R?.owner_key == character_key && R.target_key == group_id)
			return R
	var/datum/group/G = GLOB.groups[group_id]
	if (!G) return null
	return SSroleplay_management.ensure_group_relationship(character_key, G, 0)

/datum/controller/subsystem/roleplay_management/proc/CreateGroupRelationship(source_key, group_key, rtype, strength = 0, name = null, desc = "")
	if (!source_key || !group_key || !rtype) return
	var/datum/relationships/R = new(source_key, group_key) // ctor registers+saves
	R.kind = rtype
	R.intensity = strength
	R.label = name || "[rtype] toward [group_key]"
	R.notes = istext(desc) ? desc : ""
	R.touch()

/datum/controller/subsystem/roleplay_management/proc/remove_all_group_relationships(group_id)
	var/list/to_delete = list()
	for (var/rid in GLOB.relationships)
		var/datum/relationships/rel = GLOB.relationships[rid]
		if (rel?.target_key == group_id)
			to_delete += rid
	for (var/rid in to_delete)
		var/datum/relationships/rel = GLOB.relationships[rid]
		if (rel)
			unregister_relationship(rel)
			qdel(rel)

/datum/controller/subsystem/roleplay_management/proc/clear_personal_relationship(source_key, target_key)
	if (!source_key || !target_key) return
	var/list/to_delete = list()
	for (var/rid in GLOB.relationships)
		var/datum/relationships/rel = GLOB.relationships[rid]
		if (!rel) continue
		if ((rel.owner_key == source_key && rel.target_key == target_key) || (rel.owner_key == target_key && rel.target_key == source_key))
			to_delete += rid
	for (var/rid in to_delete)
		var/datum/relationships/rel = GLOB.relationships[rid]
		if (rel)
			unregister_relationship(rel)
			qdel(rel)

/datum/controller/subsystem/roleplay_management/proc/find_relationship_between(key1, key2)
	var/datum/aboutme_record/R = get_aboutme_record(key1)
	if (!R) return null
	for (var/rid in R.relationship_keys)
		var/datum/relationships/rel = get_relationship_by_key(rid)
		if (!rel) continue
		if ((rel.owner_key == key1 && rel.target_key == key2) || (rel.owner_key == key2 && rel.target_key == key1))
			return rel
	return null

/datum/controller/subsystem/roleplay_management/proc/update_relationship_strength(rel_id, new_strength)
	var/datum/relationships/rel = get_relationship_by_key(rel_id)
	if (!rel) return FALSE
	rel.intensity = new_strength
	rel.touch()
	return TRUE

/datum/controller/subsystem/roleplay_management/proc/get_relationship_keys(owner_key = null, target_key = null, kind = null)
	. = list()
	for (var/rid in GLOB.relationships)
		var/datum/relationships/R = GLOB.relationships[rid]
		if (!R) continue
		if (owner_key  && R.owner_key  != owner_key)  continue
		if (target_key && R.target_key != target_key) continue
		if (kind       && R.kind       != kind)       continue
		. += rid

/datum/controller/subsystem/roleplay_management/proc/get_group_relationship_keys_for_owner(owner_key, group_id)
	if (!owner_key || !group_id) return list()
	return get_relationship_keys(owner_key, group_id, "group")

/datum/controller/subsystem/roleplay_management/proc/get_relationships_to_target(target_key, owner_filter = null)
	var/list/ids = list()
	if (!target_key) return ids
	for (var/rid in GLOB.relationships)
		var/datum/relationships/R = GLOB.relationships[rid]
		if (!R) continue
		if (R.target_key != target_key) continue
		if (owner_filter && R.owner_key != owner_filter) continue
		ids += rid
	return ids

/datum/controller/subsystem/roleplay_management/proc/get_relationship_strength(owner_key, target_key, kind = "group")
	var/list/keys = get_relationship_keys(owner_key, target_key, kind)
	if (!length(keys)) return null
	var/datum/relationships/R = GLOB.relationships[keys[1]]
	return isnum(R?.intensity) ? R.intensity : null
