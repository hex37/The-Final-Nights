// ==============================================================================
// MEMORY — CORE (memory_core.dm)
// Player-authored memory / note / journal entry.
// ==============================================================================

/datum/memory
	var/id
	var/summary = ""
	var/details = ""
	var/list/tags = list()
	var/owner_key = ""
	var/list/related_keys = list()
	var/date_occurred = ""
	var/source = ""
	var/status = "New"

	// Audit
	var/created_at = ""
	var/created_at_ts = 0
	var/updated_at = ""
	var/updated_at_ts = 0

/datum/memory/New(owner_key)
	..()
	src.owner_key = "[owner_key]"

	if (!date_occurred)
		date_occurred = time2text(world.realtime, "MMM DD, YYYY")

	if (!id)
		var/pfx = owner_key ? "mem_[owner_key]" : "mem"
		id = SSroleplay_management.about_me_new_id(pfx)

	if (!created_at_ts)
		created_at_ts = world.realtime
		created_at = time2text(created_at_ts, "MMM DD, YYYY hh:mm")
	updated_at_ts = created_at_ts
	updated_at = created_at

	SSroleplay_management.register_memory(src)


/datum/memory/Destroy()
	SSroleplay_management.unregister_memory(src)
	..()

/datum/memory/proc/touch()
	updated_at_ts = world.realtime
	updated_at = time2text(updated_at_ts, "MMM DD, YYYY hh:mm")

// Minimal UI payload (richer helpers live in memory_ui.dm)
/datum/memory/proc/GetFormattedUI()
	return list(
		"id" = id,
		"summary" = summary,
		"details" = details,
		"tags" = islist(tags) ? tags.Copy() : list(),
		"owner_key" = owner_key,
		"related_keys" = islist(related_keys) ? related_keys.Copy() : list(),
		"date_occurred" = date_occurred,
		"status" = status,
		"created_at" = created_at,
		"updated_at" = updated_at
	)
