// ==============================================================================
// MEMORY — EDIT (memory_edit.dm)
// Sanitize at the UI layer. These just mutate and touch.
// ==============================================================================

/datum/memory/proc/set_summary(s)
	summary = "[s]"
	touch()

/datum/memory/proc/set_details(d)
	details = "[d]"
	touch()

/datum/memory/proc/add_tag(tag)
	if (!tag) return
	if (!(tag in tags)) tags += tag
	touch()

/datum/memory/proc/remove_tag(tag)
	tags -= tag
	touch()

/datum/memory/proc/link_key(key)
	if (!key) return
	if (!(key in related_keys)) related_keys += key
	touch()

/datum/memory/proc/unlink_key(key)
	if (!key) return
	related_keys -= key
	touch()

/datum/memory/proc/set_status(s)
	status = "[s]"
	touch()

/datum/memory/proc/set_date_occurred(d)
	date_occurred = "[d]"
	touch()
