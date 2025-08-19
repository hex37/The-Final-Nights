/datum/db/roleplay_management/proc/aboutme_upsert_record(datum/aboutme_record/R)
	if (!R || !R.character_id) return FALSE
	var/list/p = list(
		"ck" = R.character_id,
		"dn" = R.edit_display_name,
		"go" = R.edit_goals,
		"pq" = R.edit_personal_quote,
		"ge" = R.edit_gender,
		"pd" = R.edit_physical_desc,
		"gk" = json_encode(islist(R.group_keys)        ? R.group_keys        : list()),
		"rk" = json_encode(islist(R.relationship_keys) ? R.relationship_keys : list()),
		"ckeys" = json_encode(islist(R.chronicle_keys) ? R.chronicle_keys    : list()),
		"mk" = json_encode(islist(R.memory_keys)       ? R.memory_keys       : list()),
		"ipc" = R.has_initialized_personal_chronicle ? 1 : 0,
		"igr" = R.has_initialized_groups_from_role   ? 1 : 0,
		"iem" = R.has_initialized_entry_memory       ? 1 : 0,
	)

	var/list/upd = DB_Exec({"
		UPDATE [TBL_RP_RECORDS]
		SET edit_display_name=:dn, edit_goals=:go, edit_personal_quote=:pq,
		    edit_gender=:ge, edit_physical_desc=:pd,
		    group_keys_json=:gk, relationship_keys_json=:rk,
		    chronicle_keys_json=:ckeys, memory_keys_json=:mk,
		    has_initialized_personal_chronicle=:ipc,
		    has_initialized_groups_from_role=:igr,
		    has_initialized_entry_memory=:iem,
		    updated_at=Now()
		WHERE character_id=:ck
	"}, p)
	if (upd["ok"] && upd["rows"] > 0) return TRUE

	var/list/ins = DB_Exec({"
		INSERT INTO [TBL_RP_RECORDS]
		  (character_id, edit_display_name, edit_goals, edit_personal_quote,
		   edit_gender, edit_physical_desc,
		   group_keys_json, relationship_keys_json, chronicle_keys_json, memory_keys_json,
		   has_initialized_personal_chronicle, has_initialized_groups_from_role, has_initialized_entry_memory,
		   created_at, updated_at)
		VALUES
		  (:ck,:dn,:go,:pq,:ge,:pd,:gk,:rk,:ckeys,:mk,:ipc,:igr,:iem, Now(), Now())
	"}, p)
	return ins["ok"]

/datum/db/roleplay_management/proc/aboutme_get_record(character_id)
	if (!character_id) return null
	return DB_FetchOne({"
		SELECT *
		FROM [TBL_RP_RECORDS]
		WHERE character_id=:ck
		LIMIT 1
	"}, list("ck"=character_id))

/datum/db/roleplay_management/proc/aboutme_delete_record(character_id)
	if (!character_id) return FALSE
	var/list/res = DB_Exec({"
		DELETE FROM [TBL_RP_RECORDS]
		WHERE character_id=:ck
		LIMIT 1
	"}, list("ck"=character_id))
	return res["ok"] && res["rows"] > 0
