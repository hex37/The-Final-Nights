// ABOUTME: MEMORIES (trimmed + updated for current datum & DB helpers)
/datum/db/roleplay_management/proc/db_row_to_serial_row(list/dbrow)
	if (!islist(dbrow)) return null
	var/list/payload = null
	if (dbrow["payload_json"])
		payload = json_decode(dbrow["payload_json"]) || list()
	return list(
		"id" = dbrow["id"] || dbrow["memory_key"],
		"owner_key" = dbrow["owner_key"],
		"summary" = dbrow["summary"] || dbrow["title"] || "",
		"details" = dbrow["details"] || dbrow["desc"] || "",
		"tags" = json_decode(dbrow["tags_json"] || "[]"),
		"related_keys" = json_decode(dbrow["related_keys_json"] || "[]"),
		"date_occurred" = dbrow["date_occurred"] || (payload ? payload["date_occurred"] : null) || "",
		"source"        = dbrow["source"]        || (payload ? payload["source"]        : null) || "",
		"status"        = dbrow["status"]        || (payload ? payload["status"]        : null) || "New",
		"created_at" = dbrow["created_at"],
		"updated_at" = dbrow["updated_at"]
	)

/datum/db/roleplay_management/proc/serial_row_to_db_params(list/row)
	return list(
		"id"    = row["id"],
		"owner" = row["owner_key"],
		"sum"   = row["summary"],
		"det"   = row["details"],
		"tags"  = json_encode(islist(row["tags"]) ? row["tags"] : list()),
		"rels"  = json_encode(islist(row["related_keys"]) ? row["related_keys"] : list()),
		"date"  = row["date_occurred"],
		"src"   = row["source"],
		"stat"  = row["status"],
	)

/datum/db/roleplay_management/proc/memories_insert_serial(list/serial_row)
	var/list/p = serial_row_to_db_params(serial_row)
	var/list/res = DB_Exec({"
		INSERT INTO [TBL_RP_MEMORIES]
		  (`id`,`owner_key`,`summary`,`details`,
		   `tags_json`,`related_keys_json`,
		   `date_occurred`,`source`,`status`,`created_at`)
		VALUES
		  (:id,:owner,:sum,:det,:tags,:rels,:date,:src,:stat, Now())
	"}, p)
	return res["ok"]

/datum/db/roleplay_management/proc/memories_update_serial(list/serial_row)
	var/list/p = serial_row_to_db_params(serial_row)
	var/list/res = DB_Exec({"
		UPDATE [TBL_RP_MEMORIES]
		SET `owner_key`=:owner,
		    `summary`=:sum, `details`=:det,
		    `tags_json`=:tags, `related_keys_json`=:rels,
		    `date_occurred`=:date, `source`=:src, `status`=:stat,
		    `updated_at`=Now()
		WHERE `id`=:id
	"}, p)
	return res["ok"] && res["rows"] >= 0

/datum/db/roleplay_management/proc/memories_upsert_serial(list/serial_row)
	var/list/p = serial_row_to_db_params(serial_row)
	var/list/upd = DB_Exec({"
		UPDATE [TBL_RP_MEMORIES]
		SET `owner_key`=:owner,
		    `summary`=:sum, `details`=:det,
		    `tags_json`=:tags, `related_keys_json`=:rels,
		    `date_occurred`=:date, `source`=:src, `status`=:stat,
		    `updated_at`=Now()
		WHERE `id`=:id OR `memory_key`=:id
	"}, p)
	if (upd["ok"] && upd["rows"] > 0)
		return TRUE
	return memories_insert_serial(serial_row)

/datum/db/roleplay_management/proc/memories_get_serial_by_id(memory_id)
	var/list/dbrow = DB_FetchOne({"
		SELECT *
		FROM [TBL_RP_MEMORIES]
		WHERE id=:id OR memory_key=:id
		LIMIT 1
	"}, list("id"=memory_id))
	return db_row_to_serial_row(dbrow)

/datum/db/roleplay_management/proc/memories_for_owner(owner_key)
	var/list/dbrows = DB_FetchAll({"
		SELECT *
		FROM [TBL_RP_MEMORIES]
		WHERE `owner_key` = :owner
		ORDER BY `created_at` DESC
	"}, list("owner" = owner_key))

	var/list/out = list()
	for (var/list/r in dbrows)
		var/list/s = db_row_to_serial_row(r)
		if (s) out[s["id"]] = s
	return out

/datum/db/roleplay_management/proc/memories_delete(memory_key)
	var/list/res = DB_Exec({"
		DELETE FROM [TBL_RP_MEMORIES]
		WHERE `id` = :mk OR `memory_key` = :mk
		LIMIT 1
	"}, list("mk" = memory_key))
	return res["ok"] && res["rows"] > 0

/datum/db/roleplay_management/proc/memories_insert(datum/memory/m)
	return src.memories_insert_serial(m.to_row())

/datum/db/roleplay_management/proc/memories_update(datum/memory/m)
	return src.memories_update_serial(m.to_row())

/datum/db/roleplay_management/proc/memories_upsert(datum/memory/m)
	return src.memories_upsert_serial(m.to_row())
