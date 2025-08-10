// ==============================================================================
// CHRONICLE — SERIALIZATION (chronicle_serialization.dm)
// ==============================================================================

/datum/chronicle/proc/to_row()
	return list(
		"id" = id,
		"scope" = scope,
		"title" = title,
		"desc" = desc,
		"owner_key" = owner_key,
		"group_id" = group_id,
		"tags" = tags.Copy(),
		"entries" = entries.Copy(),
		"status" = status,
		"start_at" = start_at,
		"start_at_ts" = start_at_ts,
		"end_at" = end_at,
		"end_at_ts" = end_at_ts,
		"created_by_key" = created_by_key,
		"created_at" = created_at,
		"created_at_ts" = created_at_ts,
		"updated_at" = updated_at,
		"updated_at_ts" = updated_at_ts
	)

/datum/chronicle/proc/from_row(list/row)
	if (!islist(row)) return
	id = "[row["id"]]"
	scope = row["scope"] || scope
	title = row["title"] || title
	desc = row["desc"] || desc
	owner_key = row["owner_key"]
	group_id = row["group_id"]
	tags    = islist(row["tags"])    ? row["tags"]    : list()
	entries = islist(row["entries"]) ? row["entries"] : list()

	status = row["status"] || status
	start_at = row["start_at"] || start_at
	start_at_ts = isnum(row["start_at_ts"]) ? row["start_at_ts"] : start_at_ts
	end_at = row["end_at"] || end_at
	end_at_ts = isnum(row["end_at_ts"]) ? row["end_at_ts"] : end_at_ts
	created_by_key = row["created_by_key"]
	created_at = row["created_at"] || created_at
	created_at_ts = isnum(row["created_at_ts"]) ? row["created_at_ts"] : created_at_ts
	updated_at = row["updated_at"] || updated_at
	updated_at_ts = isnum(row["updated_at_ts"]) ? row["updated_at_ts"] : updated_at_ts
