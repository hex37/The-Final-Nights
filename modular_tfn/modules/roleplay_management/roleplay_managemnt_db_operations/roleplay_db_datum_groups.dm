/// Upsert base group row (no JSON)
/datum/db/roleplay_management/proc/groups_upsert_base(list/row)
	if (!SSdbcore || !SSdbcore.IsConnected()) return TRUE
	return DB_Exec({"
		INSERT INTO [TBL_RP_GROUPS]
		  (`group_key`,`type`,`name`,`desc`,`visibility`,`status`,
		   `created_by_key`,`created_at`,`created_at_ts`,`updated_at`,`updated_at_ts`)
		VALUES
		  (:gk,:tp,:n,:d,:vis,:st,
		   :by,:ca,:cats,:ua,:uats)
		ON DUPLICATE KEY UPDATE
		  `type`=VALUES(`type`),
		  `name`=VALUES(`name`),
		  `desc`=VALUES(`desc`),
		  `visibility`=VALUES(`visibility`),
		  `status`=VALUES(`status`),
		  `created_by_key`=VALUES(`created_by_key`),
		  `created_at`=VALUES(`created_at`),
		  `created_at_ts`=VALUES(`created_at_ts`),
		  `updated_at`=VALUES(`updated_at`),
		  `updated_at_ts`=VALUES(`updated_at_ts`)
	"}, list(
		"gk"   = row["group_key"],
		"tp"   = row["type"],
		"n"    = row["name"],
		"d"    = row["desc"],
		"vis"  = row["visibility"],
		"st"   = row["status"],
		"by"   = row["created_by_key"],
		"ca"   = row["created_at"],
		"cats" = row["created_at_ts"],
		"ua"   = row["updated_at"],
		"uats" = row["updated_at_ts"]
	))

/// Fetch base row by key
/datum/db/roleplay_management/proc/groups_get(group_key)
	if (!SSdbcore || !SSdbcore.IsConnected()) return null
	return DB_FetchOne({"
		SELECT * FROM [TBL_RP_GROUPS]
		WHERE `group_key` = :gk
		LIMIT 1
	"}, list("gk" = group_key))

/// List ALL groups (useful when bootstrapping canonical); optional
/datum/db/roleplay_management/proc/groups_list_all()
	if (!SSdbcore || !SSdbcore.IsConnected()) return list()
	return DB_FetchAll({"
		SELECT * FROM [TBL_RP_GROUPS]
		ORDER BY `updated_at_ts` DESC, `created_at_ts` DESC
	"})

/// Delete a group + cascade members
/datum/db/roleplay_management/proc/groups_delete(group_key)
	if (!SSdbcore || !SSdbcore.IsConnected()) return TRUE
	DB_Exec({"
		DELETE FROM [TBL_RP_GROUP_MEMBERS]
		WHERE `group_key` = :gk
	"}, list("gk" = group_key))
	return DB_Exec({"
		DELETE FROM [TBL_RP_GROUPS]
		WHERE `group_key` = :gk
		LIMIT 1
	"}, list("gk" = group_key))

// -------- Members (child rows) ---------------------------------------------

/// Replace all members for a given group (delete + bulk insert)
/datum/db/roleplay_management/proc/group_members_replace(group_key, list/rows)
	if (!SSdbcore || !SSdbcore.IsConnected()) return TRUE

	DB_Exec({"
		DELETE FROM [TBL_RP_GROUP_MEMBERS]
		WHERE `group_key` = :gk
	"}, list("gk" = group_key))

	if (!islist(rows) || !rows.len) return TRUE

	for (var/i in 1 to rows.len)
		var/list/r = rows[i]
		DB_Exec({"
			INSERT INTO [TBL_RP_GROUP_MEMBERS]
			  (`group_key`,`member_key`,`role`,`joined_at`,`joined_at_ts`)
			VALUES
			  (:gk,:mk,:rl,:ja,:jats)
			ON DUPLICATE KEY UPDATE
			  `role`=VALUES(`role`),
			  `joined_at`=VALUES(`joined_at`),
			  `joined_at_ts`=VALUES(`joined_at_ts`)
		"}, list(
			"gk"   = r["group_key"],
			"mk"   = r["member_key"],
			"rl"   = r["role"],
			"ja"   = r["joined_at"],
			"jats" = r["joined_at_ts"]
		))
	return TRUE

/// List all members for a group
/datum/db/roleplay_management/proc/group_members_list(group_key)
	if (!SSdbcore || !SSdbcore.IsConnected()) return list()
	return DB_FetchAll({"
		SELECT * FROM [TBL_RP_GROUP_MEMBERS]
		WHERE `group_key` = :gk
		ORDER BY `joined_at_ts` ASC, `member_key` ASC
	"}, list("gk" = group_key))
