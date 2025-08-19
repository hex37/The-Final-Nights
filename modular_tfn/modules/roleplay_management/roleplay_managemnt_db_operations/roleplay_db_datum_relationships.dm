// ============================================================================
// DAO: Relationships (flat columns; no JSON)
// Uses TBL_RP_RELATIONSHIPS; safe if SQL disabled.
// ============================================================================

/datum/db/roleplay_management

/datum/db/roleplay_management/proc/relationships_upsert_base(list/row)
    if (!SSdbcore || !SSdbcore.IsConnected()) return TRUE
    return DB_Exec({"
        INSERT INTO [TBL_RP_RELATIONSHIPS]
          (`rel_key`,`owner_key`,`target_key`,`kind`,`label`,`notes`,
           `visibility`,`status`,`intensity`,
           `created_at`,`created_at_ts`,`updated_at`,`updated_at_ts`)
        VALUES
          (:rk,:ok,:tk,:k,:lbl,:n,:vis,:st,:int,:ca,:cats,:ua,:uats)
        ON DUPLICATE KEY UPDATE
          `owner_key`=VALUES(`owner_key`),
          `target_key`=VALUES(`target_key`),
          `kind`=VALUES(`kind`),
          `label`=VALUES(`label`),
          `notes`=VALUES(`notes`),
          `visibility`=VALUES(`visibility`),
          `status`=VALUES(`status`),
          `intensity`=VALUES(`intensity`),
          `created_at`=VALUES(`created_at`),
          `created_at_ts`=VALUES(`created_at_ts`),
          `updated_at`=VALUES(`updated_at`),
          `updated_at_ts`=VALUES(`updated_at_ts`)
    "}, list(
        "rk"=row["rel_key"], "ok"=row["owner_key"], "tk"=row["target_key"],
        "k"=row["kind"], "lbl"=row["label"], "n"=row["notes"],
        "vis"=row["visibility"], "st"=row["status"], "int"=row["intensity"],
        "ca"=row["created_at"], "cats"=row["created_at_ts"],
        "ua"=row["updated_at"], "uats"=row["updated_at_ts"]
    ))

/datum/db/roleplay_management/proc/relationships_get(rel_key)
    if (!SSdbcore || !SSdbcore.IsConnected()) return null
    return DB_FetchOne({"
        SELECT * FROM [TBL_RP_RELATIONSHIPS]
        WHERE `rel_key` = :rk
        LIMIT 1
    "}, list("rk" = rel_key))

/datum/db/roleplay_management/proc/relationships_list_for_owner(owner_key)
    if (!SSdbcore || !SSdbcore.IsConnected()) return list()
    return DB_FetchAll({"
        SELECT * FROM [TBL_RP_RELATIONSHIPS]
        WHERE `owner_key` = :ok
        ORDER BY `updated_at_ts` DESC, `created_at_ts` DESC
    "}, list("ok" = owner_key))

/datum/db/roleplay_management/proc/relationships_delete(rel_key)
    if (!SSdbcore || !SSdbcore.IsConnected()) return TRUE
    return DB_Exec({"
        DELETE FROM [TBL_RP_RELATIONSHIPS]
        WHERE `rel_key` = :rk
        LIMIT 1
    "}, list("rk" = rel_key))
