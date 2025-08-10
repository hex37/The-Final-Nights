// ==============================================================================
// CHRONICLE — CORE (chronicle_core.dm)
// Chronicle = story container with linked entries (memory ids).
// ==============================================================================

/datum/chronicle
	var/id
	var/scope = "personal"
	var/title = "Untitled Chronicle"
	var/desc = ""
	var/owner_key
	var/group_id
	var/list/tags = list()
	var/list/entries = list() // memory ids
	var/status = "Ongoing"

	var/start_at = ""
	var/start_at_ts = 0
	var/end_at = ""
	var/end_at_ts = 0

	var/created_by_key
	var/created_at = ""
	var/created_at_ts = 0
	var/updated_at = ""
	var/updated_at_ts = 0

/datum/chronicle/New(id, scope, title, desc, owner_key, group_id, created_by_key)
	..()
	src.id = id
	src.scope = scope || src.scope
	src.title = title || src.title
	src.desc  = desc  || src.desc
	src.owner_key = owner_key
	src.group_id  = group_id
	src.created_by_key = created_by_key

	if (!src.id)
		var/host = owner_key ? "[owner_key]" : (group_id ? "[group_id]" : "unknown")
		var/pfx = "chron_[src.scope]_[host]"
		src.id = SSroleplay_management.about_me_new_id(pfx)

	if (!created_at_ts)
		created_at_ts = world.realtime
		created_at = time2text(created_at_ts, "MMM DD, YYYY hh:mm")
	updated_at_ts = created_at_ts
	updated_at = created_at

	start_at_ts = created_at_ts
	start_at = created_at

	SSroleplay_management.register_chronicle(src)


/datum/chronicle/Destroy()
	SSroleplay_management.unregister_chronicle(src)
	..()

/datum/chronicle/proc/touch()
	updated_at_ts = world.realtime
	updated_at = time2text(updated_at_ts, "MMM DD, YYYY hh:mm")

/datum/chronicle/proc/add_entry(memory_id)
	if (!memory_id) return
	if (!(memory_id in entries))
		entries += memory_id
	touch()

/datum/chronicle/proc/close(now = TRUE)
	status = "Concluded"
	if (now)
		end_at_ts = world.realtime
		end_at = time2text(end_at_ts, "MMM DD, YYYY hh:mm")
	touch()

/datum/chronicle/proc/GetFormattedUI()
	return list(
		"id" = id,
		"scope" = scope,
		"title" = title,
		"desc" = desc,
		"owner_key" = owner_key,
		"group_id" = group_id,
		"tags" = islist(tags) ? tags.Copy() : list(),
		"entries" = islist(entries) ? entries.Copy() : list(),
		"status" = status,
		"start_at" = start_at,
		"end_at" = end_at,
		"created_at" = created_at,
		"updated_at" = updated_at
	)
