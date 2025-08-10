// ==============================================================================
// ABOUT ME RECORD — SERIALIZATION (about_me_record_serialization.dm)
// DB-friendly helpers; no mob refs.
// ==============================================================================

/datum/aboutme_record/proc/to_row()
	return list(
		"character_key" = character_key,
		"edit_display_name" = edit_display_name,
		"edit_goals" = edit_goals,
		"edit_personal_quote" = edit_personal_quote,
		"edit_gender" = edit_gender,
		"edit_physical_desc" = edit_physical_desc,
		"group_keys" = group_keys.Copy(),
		"relationship_keys" = relationship_keys.Copy(),
		"chronicle_keys" = chronicle_keys.Copy(),
		"memory_keys" = memory_keys.Copy(),
		"has_initialized_personal_chronicle" = has_initialized_personal_chronicle,
		"has_initialized_groups_from_role" = has_initialized_groups_from_role,
		"has_initialized_entry_memory" = has_initialized_entry_memory,
		"created_at" = created_at,
		"created_at_ts" = created_at_ts,
		"updated_at" = updated_at,
		"updated_at_ts" = updated_at_ts
	)

/datum/aboutme_record/proc/from_row(list/row)
	if (!islist(row)) return
	character_key = "[row["character_key"]]"
	edit_display_name = row["edit_display_name"]
	edit_goals = row["edit_goals"]
	edit_personal_quote = row["edit_personal_quote"]
	edit_gender = row["edit_gender"]
	edit_physical_desc = row["edit_physical_desc"]
	group_keys       = islist(row["group_keys"])       ? row["group_keys"]       : list()
	relationship_keys= islist(row["relationship_keys"]) ? row["relationship_keys"] : list()
	chronicle_keys   = islist(row["chronicle_keys"])   ? row["chronicle_keys"]   : list()
	memory_keys      = islist(row["memory_keys"])      ? row["memory_keys"]      : list()
	has_initialized_personal_chronicle = !!row["has_initialized_personal_chronicle"]
	has_initialized_groups_from_role = !!row["has_initialized_groups_from_role"]
	has_initialized_entry_memory = !!row["has_initialized_entry_memory"]
	created_at = row["created_at"] || created_at
	created_at_ts = isnum(row["created_at_ts"]) ? row["created_at_ts"] : created_at_ts
	updated_at = row["updated_at"] || updated_at
	updated_at_ts = isnum(row["updated_at_ts"]) ? row["updated_at_ts"] : updated_at_ts
