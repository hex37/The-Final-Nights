// Base row upsert (no JSON)
/// row = list("chron_key","scope","title","summary","owner_key","group_id","status",
///            "start_at","start_at_ts","end_at","end_at_ts",
///            "created_by_key","created_at","created_at_ts","updated_at","updated_at_ts")
/datum/db/roleplay_management/proc/chronicles_upsert_base(list/row)
	if (!SSdbcore || !SSdbcore.IsConnected()) return TRUE
	return DB_Exec({"
		INSERT INTO [TBL_RP_CHRONICLES]
		  (`chron_key`,`scope`,`title`,`summary`,`owner_key`,`group_id`,`status`,
		   `start_at`,`start_at_ts`,`end_at`,`end_at_ts`,
		   `created_by_key`,`created_at`,`created_at_ts`,`updated_at`,`updated_at_ts`)
		VALUES
		  (:ck,:sc,:t,:sum,:ok,:gid,:st,
		   :sa,:sats,:ea,:eats,
		   :by,:ca,:cats,:ua,:uats)
		ON DUPLICATE KEY UPDATE
		  `scope`=VALUES(`scope`),
		  `title`=VALUES(`title`),
		  `summary`=VALUES(`summary`),
		  `owner_key`=VALUES(`owner_key`),
		  `group_id`=VALUES(`group_id`),
		  `status`=VALUES(`status`),
		  `start_at`=VALUES(`start_at`),
		  `start_at_ts`=VALUES(`start_at_ts`),
		  `end_at`=VALUES(`end_at`),
		  `end_at_ts`=VALUES(`end_at_ts`),
		  `created_by_key`=VALUES(`created_by_key`),
		  `created_at`=VALUES(`created_at`),
		  `created_at_ts`=VALUES(`created_at_ts`),
		  `updated_at`=VALUES(`updated_at`),
		  `updated_at_ts`=VALUES(`updated_at_ts`)
	"}, list(
		"ck"=row["chron_key"], "sc"=row["scope"], "t"=row["title"], "sum"=row["summary"],
		"ok"=row["owner_key"], "gid"=row["group_id"], "st"=row["status"],
		"sa"=row["start_at"], "sats"=row["start_at_ts"], "ea"=row["end_at"], "eats"=row["end_at_ts"],
		"by"=row["created_by_key"], "ca"=row["created_at"], "cats"=row["created_at_ts"],
		"ua"=row["updated_at"], "uats"=row["updated_at_ts"]
	))

/// Fetch base chronicle row
/datum/db/roleplay_management/proc/chronicles_get(chron_key)
	if (!SSdbcore || !SSdbcore.IsConnected()) return null
	return DB_FetchOne({"
		SELECT * FROM [TBL_RP_CHRONICLES]
		WHERE `chron_key` = :ck
		LIMIT 1
	"}, list("ck" = chron_key))

/// List all base chronicles for a character (owner_key)
/datum/db/roleplay_management/proc/chronicles_list_for_char(owner_key)
	if (!SSdbcore || !SSdbcore.IsConnected()) return list()
	return DB_FetchAll({"
		SELECT * FROM [TBL_RP_CHRONICLES]
		WHERE `owner_key` = :ck
		ORDER BY `created_at_ts` DESC, `created_at` DESC
	"}, list("ck" = owner_key))

/// Delete base chronicle row + cascade entries
/datum/db/roleplay_management/proc/chronicles_delete(chron_key)
	if (!SSdbcore || !SSdbcore.IsConnected()) return TRUE
	// Remove entries first (no FK in BYOND unless defined)
	DB_Exec({"
		DELETE FROM [TBL_RP_CHRONICLE_ENTRIES]
		WHERE `chron_key` = :ck
	"}, list("ck" = chron_key))
	return DB_Exec({"
		DELETE FROM [TBL_RP_CHRONICLES]
		WHERE `chron_key` = :ck
		LIMIT 1
	"}, list("ck" = chron_key))

/// Replace all entries for a chronicle (simple delete+insert; can optimize later)
/datum/db/roleplay_management/proc/chronicles_replace_entries(chron_key, list/rows)
	if (!SSdbcore || !SSdbcore.IsConnected()) return TRUE
	DB_Exec({"
		DELETE FROM [TBL_RP_CHRONICLE_ENTRIES]
		WHERE `chron_key` = :ck
	"}, list("ck" = chron_key))

	if (!islist(rows) || !rows.len) return TRUE

	// Insert each (keeps it simple/robust for now)
	for (var/i in 1 to rows.len)
		var/list/r = rows[i]
		DB_Exec({"
			INSERT INTO [TBL_RP_CHRONICLE_ENTRIES]
			  (`entry_key`,`chron_key`,`memory_key`,`title`,`body`,`author_key`,`status`,
			   `occurred_at`,`occurred_at_ts`,`created_at`,`created_at_ts`,`updated_at`,`updated_at_ts`)
			VALUES
			  (:ek,:ck,:mk,:t,:b,:ak,:st,
			   :oa,:oats,:ca,:cats,:ua,:uats)
			ON DUPLICATE KEY UPDATE
			  `chron_key`=VALUES(`chron_key`),
			  `memory_key`=VALUES(`memory_key`),
			  `title`=VALUES(`title`),
			  `body`=VALUES(`body`),
			  `author_key`=VALUES(`author_key`),
			  `status`=VALUES(`status`),
			  `occurred_at`=VALUES(`occurred_at`),
			  `occurred_at_ts`=VALUES(`occurred_at_ts`),
			  `created_at`=VALUES(`created_at`),
			  `created_at_ts`=VALUES(`created_at_ts`),
			  `updated_at`=VALUES(`updated_at`),
			  `updated_at_ts`=VALUES(`updated_at_ts`)
		"}, list(
			"ek"=r["entry_key"], "ck"=r["chron_key"], "mk"=r["memory_key"],
			"t"=r["title"], "b"=r["body"], "ak"=r["author_key"], "st"=r["status"],
			"oa"=r["occurred_at"], "oats"=r["occurred_at_ts"],
			"ca"=r["created_at"], "cats"=r["created_at_ts"],
			"ua"=r["updated_at"], "uats"=r["updated_at_ts"]
		))
	return TRUE

/// Load all entry rows for a chronicle (for from_rows_entries)
/datum/db/roleplay_management/proc/chronicles_get_entries(chron_key)
	if (!SSdbcore || !SSdbcore.IsConnected()) return list()
	return DB_FetchAll({"
		SELECT * FROM [TBL_RP_CHRONICLE_ENTRIES]
		WHERE `chron_key` = :ck
		ORDER BY `occurred_at_ts` ASC, `created_at_ts` ASC
	"}, list("ck" = chron_key))
