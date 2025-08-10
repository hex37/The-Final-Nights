// ==============================================================================
// MEMORY — SERIALIZATION (memory_serialization.dm)
// ==============================================================================

/datum/memory/proc/to_row()
	return list(
		"id" = id,
		"summary" = summary,
		"details" = details,
		"tags" = tags.Copy(),
		"owner_key" = owner_key,
		"related_keys" = related_keys.Copy(),
		"date_occurred" = date_occurred,
		"source" = source,
		"status" = status,
		"created_at" = created_at,
		"created_at_ts" = created_at_ts,
		"updated_at" = updated_at,
		"updated_at_ts" = updated_at_ts
	)

/datum/memory/proc/from_row(list/row)
	if (!islist(row)) return
	id = "[row["id"]]"
	summary = row["summary"] || summary
	details = row["details"] || details
	tags = islist(row["tags"]) ? row["tags"] : list()
	owner_key = row["owner_key"] || owner_key
	related_keys = islist(row["related_keys"]) ? row["related_keys"] : list()
	date_occurred = row["date_occurred"] || date_occurred
	source = row["source"] || source
	status = row["status"] || status
	created_at = row["created_at"] || created_at
	created_at_ts = isnum(row["created_at_ts"]) ? row["created_at_ts"] : created_at_ts
	updated_at = row["updated_at"] || updated_at
	updated_at_ts = isnum(row["updated_at_ts"]) ? row["updated_at_ts"] : updated_at_ts

