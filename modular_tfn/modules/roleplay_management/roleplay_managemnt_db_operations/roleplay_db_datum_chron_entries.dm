/datum/db/roleplay_management

// Upsert one entry (flat columns)
/// row keys: entry_key, chron_key, memory_key, title, body, author_key, status,
///           occurred_at, occurred_at_ts, created_at, created_at_ts, updated_at, updated_at_ts
/datum/db/roleplay_management/proc/chronicle_entries_upsert_serial(list/row)
	if (!SSdbcore || !SSdbcore.IsConnected()) return TRUE
	return DB_Exec({"
		INSERT INTO [TBL_RP_CHRONICLE_ENTRIES]
		  (`entry_key`,`chron_key`,`memory_key`,`title`,`body`,`author_key`,`status`,
		   `occurred_at`,`occurred_at_ts`,`created_at`,`created_at_ts`,`updated_at`,`updated_at_ts`)
		VALUES
		  (:ek,:ck,:mk,:t,:b,:ak,:st,:oa,:oats,:ca,:cats,:ua,:uats)
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
		"ek"=row["entry_key"], "ck"=row["chron_key"], "mk"=row["memory_key"],
		"t"=row["title"], "b"=row["body"], "ak"=row["author_key"], "st"=row["status"],
		"oa"=row["occurred_at"], "oats"=row["occurred_at_ts"],
		"ca"=row["created_at"], "cats"=row["created_at_ts"],
		"ua"=row["updated_at"], "uats"=row["updated_at_ts"]
	))

/datum/db/roleplay_management/proc/chronicle_entries_list_for_chron(chron_key)
	if (!SSdbcore || !SSdbcore.IsConnected()) return list()
	return DB_FetchAll({"
		SELECT * FROM [TBL_RP_CHRONICLE_ENTRIES]
		WHERE `chron_key` = :ck
		ORDER BY `occurred_at_ts` ASC, `created_at_ts` ASC
	"}, list("ck" = chron_key))

/datum/db/roleplay_management/proc/chronicle_entries_get(entry_key)
	if (!SSdbcore || !SSdbcore.IsConnected()) return null
	return DB_FetchOne({"
		SELECT * FROM [TBL_RP_CHRONICLE_ENTRIES]
		WHERE `entry_key` = :ek
		LIMIT 1
	"}, list("ek" = entry_key))

/datum/db/roleplay_management/proc/chronicle_entries_delete(entry_key)
	if (!SSdbcore || !SSdbcore.IsConnected()) return TRUE
	return DB_Exec({"
		DELETE FROM [TBL_RP_CHRONICLE_ENTRIES]
		WHERE `entry_key` = :ek
		LIMIT 1
	"}, list("ek" = entry_key))
