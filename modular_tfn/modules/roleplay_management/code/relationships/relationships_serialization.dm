// ==============================================================================
// RELATIONSHIP — SERIALIZATION (relationship_serialization.dm)
// ==============================================================================

/datum/relationships/proc/to_row()
	return list(
		"id" = id,
		"subject_key" = subject_key,
		"target_type" = target_type,
		"target_key" = target_key,
		"rtype" = rtype,
		"strength" = strength,
		"tags" = tags.Copy(),
		"mutual" = mutual,
		"visible" = visible,
		"related_memory_keys" = related_memory_keys.Copy(),
		"created_by_key" = created_by_key,
		"created_at" = created_at,
		"created_at_ts" = created_at_ts,
		"updated_at" = updated_at,
		"updated_at_ts" = updated_at_ts
	)

/datum/relationships/proc/from_row(list/row)
	if (!islist(row)) return
	id = "[row["id"]]"
	subject_key = "[row["subject_key"]]"
	target_type = row["target_type"] || target_type
	target_key = "[row["target_key"]]"
	rtype = row["rtype"] || rtype
	strength = isnum(row["strength"]) ? clamp(row["strength"], 0, 100) : strength
	tags = islist(row["tags"]) ? row["tags"] : list()
	mutual = !!row["mutual"]
	visible = (row["visible"] != null) ? !!row["visible"] : visible
	related_memory_keys = islist(row["related_memory_keys"]) ? row["related_memory_keys"] : list()
	created_by_key = row["created_by_key"]
	created_at = row["created_at"] || created_at
	created_at_ts = isnum(row["created_at_ts"]) ? row["created_at_ts"] : created_at_ts
	updated_at = row["updated_at"] || updated_at
	updated_at_ts = isnum(row["updated_at_ts"]) ? row["updated_at_ts"] : updated_at_ts
