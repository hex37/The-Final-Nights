// RP Management Subsystem — Save/Load Hub (ssroleplay_management_save_load.dm)
// ===========================================================================
//Save everything relevant to a character's About Me
/datum/controller/subsystem/roleplay_management/proc/aboutme_save(owner_key)
	if (!owner_key) return FALSE
	var/datum/aboutme_record/R = get_aboutme_record(owner_key)
	if (!R) return FALSE

	// 1) Persist AboutMe record itself (fields + key lists)
	record_save(owner_key)

	// 2) Persist memories (write-through only dirty)
	memories_save(owner_key)

	// 3) (future) Persist relationships
	relationships_save(owner_key)

	// 4) (future) Persist groups/memberships
	// groups_save(owner_key)

	// 5) (future) Persist chronicles
	chronicles_save(owner_key)
	chronicle_entries_save(owner_key)
	return TRUE

// Load everything needed to a character's About Me into live datums
/datum/controller/subsystem/roleplay_management/proc/aboutme_load(owner_key, mob/living/carbon/human/owner_mob)
	if (!owner_key) return FALSE

	// 1) Character record (creates shell if missing)
	record_load(owner_key, owner_mob)
	memories_load(owner_key)
	// 2) Groups + memberships
	groups_load(owner_key)
	// 3) Relationships
	relationships_load(owner_key)
	// 4) Chronicles + entries
	chronicles_load(owner_key)
	chronicle_entries_load(owner_key)
	return TRUE

/datum/controller/subsystem/roleplay_management/proc/record_save(owner_key)
	if (!owner_key) return FALSE
	var/datum/aboutme_record/R = get_aboutme_record(owner_key)
	if (!R) return FALSE

	var/datum/db/roleplay_management/DB = new
	if (hascall(DB, "aboutme_upsert_record"))
		return DB.aboutme_upsert_record(R)
	return TRUE

/datum/controller/subsystem/roleplay_management/proc/record_load(owner_key, mob/living/carbon/human/owner_mob)
	if (!owner_key) return FALSE

	var/datum/aboutme_record/R = get_aboutme_record(owner_key, owner_mob)
	if (!R) return FALSE

	var/datum/db/roleplay_management/DB = new
	if (hascall(DB, "aboutme_get_record"))
		var/list/dbrow = DB.aboutme_get_record(owner_key)
		if (dbrow)
			R.from_row_db(dbrow)

	return TRUE

/datum/controller/subsystem/roleplay_management/proc/memories_save(owner_key)
	if (!owner_key) return FALSE
	var/datum/aboutme_record/R = get_aboutme_record(owner_key)
	if (!R) return FALSE

	var/datum/db/roleplay_management/DB = new
	for (var/mem_id in (R.memory_keys || list()))
		var/datum/memory/M = GLOB.memories[mem_id]
		if (!M) continue
		if (M.dirty)
			if (hascall(DB, "memories_upsert_serial"))
				DB.memories_upsert_serial(M.to_row_db())
			M.dirty = FALSE
	return TRUE

/datum/controller/subsystem/roleplay_management/proc/memories_load(owner_key)
	if (!owner_key) return FALSE
	var/datum/aboutme_record/R = get_aboutme_record(owner_key)
	if (!R) return FALSE

	var/datum/db/roleplay_management/DB = new
	if (!hascall(DB, "memories_for_owner"))
		return TRUE

	var/list/serials = DB.memories_for_owner(owner_key) // assoc by id
	if (!islist(serials) || !serials.len)
		return TRUE

	if (!islist(R.memory_keys)) R.memory_keys = list()

	for (var/mem_id in serials)
		// already live? just ensure key
		if (GLOB.memories[mem_id])
			if (!(mem_id in R.memory_keys))
				R.memory_keys += mem_id
			continue

		var/datum/memory/M = new /datum/memory(null, TRUE)
		M.autosave = FALSE
		M.from_row(serials[mem_id])
		M.dirty = FALSE

		if (!(mem_id in GLOB.memories))
			GLOB.memories[mem_id] = M
		if (!(mem_id in R.memory_keys))
			R.memory_keys += mem_id

	return TRUE

/datum/controller/subsystem/roleplay_management/proc/memory_load_by_id(memory_id)
	if (!memory_id) return null
	if (GLOB.memories[memory_id])
		return GLOB.memories[memory_id]

	var/datum/db/roleplay_management/DB = new
	if (!hascall(DB, "memories_get_serial_by_id"))
		return null

	var/list/serial = DB.memories_get_serial_by_id(memory_id)
	if (!serial) return null

	var/datum/memory/M = new /datum/memory(null, TRUE)
	M.autosave = FALSE
	M.from_row(serial)
	M.dirty = FALSE

	GLOB.memories[memory_id] = M
	return M

/datum/controller/subsystem/roleplay_management/proc/relationships_save(owner_key)
    if (!owner_key) return TRUE
    var/datum/aboutme_record/R = get_aboutme_record(owner_key)
    if (!R) return TRUE
    if (!islist(R.relationship_keys) || !R.relationship_keys.len) return TRUE

    var/datum/db/roleplay_management/DB = new
    for (var/rk in R.relationship_keys)
        var/datum/relationships/Rel = GLOB.relationships[rk]
        if (!Rel) continue
        if (Rel.dirty)
            DB.relationships_upsert_base(Rel.to_row())
            Rel.dirty = FALSE
    return TRUE

/datum/controller/subsystem/roleplay_management/proc/relationships_load(owner_key)
    if (!owner_key) return TRUE
    var/datum/aboutme_record/R = get_aboutme_record(owner_key)
    if (!R) return TRUE

    var/datum/db/roleplay_management/DB = new
    var/list/rows = DB.relationships_list_for_owner(owner_key)
    if (!islist(rows) || !rows.len) return TRUE
    if (!islist(R.relationship_keys)) R.relationship_keys = list()

    for (var/i in 1 to rows.len)
        var/list/row = rows[i]
        var/key = row["rel_key"]
        if (!key) continue

        if (GLOB.relationships[key])
            if (!(key in R.relationship_keys))
                R.relationship_keys += key
            continue

        var/datum/relationships/Rel = new /datum/relationships(null, null, TRUE)
        Rel.autosave = FALSE
        Rel.from_row(row)
        Rel.dirty = FALSE

        GLOB.relationships[key] = Rel
        if (!(key in R.relationship_keys))
            R.relationship_keys += key

    return TRUE


/datum/controller/subsystem/roleplay_management/proc/groups_save(owner_key)
	if (!owner_key) return TRUE
	var/datum/aboutme_record/R = get_aboutme_record(owner_key)
	if (!R) return TRUE
	if (!islist(R.group_keys) || !R.group_keys.len) return TRUE

	var/datum/db/roleplay_management/DB = new
	for (var/gk in R.group_keys)
		var/datum/group/G = GLOB.groups[gk]
		if (!G) continue
		if (DB.groups_upsert_base(G.to_row_base()))
			DB.group_members_replace(G.id, G.to_rows_members())
	return TRUE

/datum/controller/subsystem/roleplay_management/proc/groups_load(owner_key)
	if (!owner_key) return TRUE
	var/datum/aboutme_record/R = get_aboutme_record(owner_key)
	if (!R) return TRUE
	if (!islist(R.group_keys) || !R.group_keys.len) return TRUE

	var/datum/db/roleplay_management/DB = new
	for (var/gk in R.group_keys)
		if (GLOB.groups[gk]) continue

		var/list/base = DB.groups_get(gk)
		if (!islist(base)) continue

		var/datum/group/G = new /datum/group(null, TRUE)
		G.autosave = FALSE
		G.from_row_db(base)
		G.from_rows_members(DB.group_members_list(gk))
		G.dirty = FALSE

		SSroleplay_management.register_group(G)
	return TRUE


/datum/controller/subsystem/roleplay_management/proc/chronicles_save(owner_key)
	if (!owner_key) return TRUE
	var/datum/aboutme_record/R = get_aboutme_record(owner_key)
	if (!R) return TRUE
	if (!islist(R.chronicle_keys) || !R.chronicle_keys.len) return TRUE

	var/datum/db/roleplay_management/DB = new
	for (var/ck in R.chronicle_keys)
		var/datum/chronicle/C = GLOB.chronicles[ck]
		if (!C) continue
		DB.chronicles_upsert_base(C.to_row_base())
	return TRUE

/datum/controller/subsystem/roleplay_management/proc/chronicles_load(owner_key)
	if (!owner_key) return TRUE
	var/datum/aboutme_record/R = get_aboutme_record(owner_key)
	if (!R) return TRUE

	var/datum/db/roleplay_management/DB = new
	var/list/rows = DB.chronicles_list_for_char(owner_key)
	if (!islist(rows) || !rows.len) return TRUE
	if (!islist(R.chronicle_keys)) R.chronicle_keys = list()

	for (var/i in 1 to rows.len)
		var/list/row = rows[i]
		var/key = row["chron_key"]
		if (!key) continue

		if (GLOB.chronicles[key])
			if (!(key in R.chronicle_keys))
				R.chronicle_keys += key
			continue

		var/datum/chronicle/C = new /datum/chronicle(null, null, null, null, null, null, null)
		C.autosave = FALSE
		C.from_row_db(row)
		C.dirty = FALSE

		GLOB.chronicles[key] = C
		if (!(key in R.chronicle_keys))
			R.chronicle_keys += key

	return TRUE

/datum/controller/subsystem/roleplay_management/proc/chronicle_entries_save(owner_key)
    var/datum/aboutme_record/R = get_aboutme_record(owner_key); if (!R) return TRUE
    for (var/ck in (R.chronicle_keys || list()))
        chronicle_entries_save_one(ck)
    return TRUE

/datum/controller/subsystem/roleplay_management/proc/chronicle_entries_load(owner_key)
    var/datum/aboutme_record/R = get_aboutme_record(owner_key); if (!R) return TRUE
    for (var/ck in (R.chronicle_keys || list()))
        chronicle_entries_load_one(ck)
    return TRUE

/datum/controller/subsystem/roleplay_management/proc/chronicle_entries_save_one(chron_key)
	if (!chron_key) return TRUE
	var/datum/chronicle/C = get_chronicle_by_key(chron_key)
	if (!C) return TRUE
	if (!islist(C.entries) || !C.entries.len) return TRUE

	var/datum/db/roleplay_management/DB = new
	for (var/eid in C.entries)
		var/datum/chronicle_entry/E = GLOB.chronicle_entries[eid]
		if (!E) continue
		if (E.dirty)
			if (hascall(DB, "chronicle_entries_upsert_serial"))
				DB.chronicle_entries_upsert_serial(E.to_row_db())
			E.dirty = FALSE
	return TRUE

/datum/controller/subsystem/roleplay_management/proc/chronicle_entries_load_one(chron_key)
	if (!chron_key) return TRUE
	var/datum/chronicle/C = get_chronicle_by_key(chron_key)
	if (!C) return TRUE

	var/datum/db/roleplay_management/DB = new
	if (!hascall(DB, "chronicle_entries_list_for_chron"))
		return TRUE

	var/list/rows = DB.chronicle_entries_list_for_chron(chron_key)
	if (!islist(rows) || !rows.len) return TRUE
	if (!islist(C.entries)) C.entries = list()

	for (var/i in 1 to rows.len)
		var/list/row = rows[i]
		var/eid = row["entry_key"]
		if (!eid) continue

		if (!GLOB.chronicle_entries[eid])
			var/datum/chronicle_entry/E = new /datum/chronicle_entry(chron_key, TRUE)
			E.autosave = FALSE
			E.from_row_db(row)
			E.dirty = FALSE
			SSroleplay_management.register_chronicle_entry(E)

		if (!(eid in C.entries))
			C.entries += eid

	return TRUE

