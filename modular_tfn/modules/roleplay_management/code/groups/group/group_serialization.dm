/datum/group/proc/to_row()
	return list(
		"id" = id,
		"name" = name,
		"group_type" = group_type,
		"desc" = desc,
		"tags" = tags.Copy(),
		"is_public" = is_public,
		"status" = status,
		"leader_keys" = leader_keys.Copy(),
		"officer_keys" = officer_keys.Copy(),
		"member_keys" = member_keys.Copy(),
		"chronicle_keys" = chronicle_keys.Copy(),
		"group_relationship_keys" = group_relationship_keys.Copy(),
		"created_by_key" = created_by_key,
		"created_at" = created_at,
		"created_at_ts" = created_at_ts,
		"updated_at" = updated_at,
		"updated_at_ts" = updated_at_ts
	)

/datum/group/proc/from_row(list/row)
	if (!islist(row)) return
	id = "[row["id"]]"
	name = row["name"] || name
	group_type = row["group_type"] || group_type
	desc = row["desc"] || desc
	tags = islist(row["tags"]) ? row["tags"] : list()
	is_public = (row["is_public"] != null) ? !!row["is_public"] : is_public
	status = row["status"] || status
	leader_keys = islist(row["leader_keys"]) ? row["leader_keys"] : list()
	officer_keys = islist(row["officer_keys"]) ? row["officer_keys"] : list()
	member_keys = islist(row["member_keys"]) ? row["member_keys"] : list()
	chronicle_keys = islist(row["chronicle_keys"]) ? row["chronicle_keys"] : list()
	group_relationship_keys = islist(row["group_relationship_keys"]) ? row["group_relationship_keys"] : list()
	created_by_key = row["created_by_key"]
	created_at = row["created_at"] || created_at
	created_at_ts = isnum(row["created_at_ts"]) ? row["created_at_ts"] : created_at_ts
	updated_at = row["updated_at"] || updated_at
	updated_at_ts = isnum(row["updated_at_ts"]) ? row["updated_at_ts"] : updated_at_ts
