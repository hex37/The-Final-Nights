// RP Management Subsystem - Chronicle Entries
/datum/controller/subsystem/roleplay_management/proc/register_chronicle_entry(datum/chronicle_entry/E)
	if (E?.id) GLOB.chronicle_entries[E.id] = E

/datum/controller/subsystem/roleplay_management/proc/unregister_chronicle_entry(datum/chronicle_entry/E)
	if (E?.id) GLOB.chronicle_entries -= E.id

/datum/controller/subsystem/roleplay_management/proc/get_chronicle_entry_by_id(id)
	return is_valid_id(id) ? GLOB.chronicle_entries[id] : null

/datum/controller/subsystem/roleplay_management/proc/chronicle_attach_entry(chron_key, datum/chronicle_entry/E)
    var/datum/chronicle/C = get_chronicle_by_key(chron_key)
    if (!C || !E) return
    if (!(E.id in C.entries)) C.entries += E.id
    C.touch()

/datum/controller/subsystem/roleplay_management/proc/chronicle_detach_entry(chron_key, entry_id)
	if (!chron_key || !entry_id) return FALSE
	var/datum/chronicle/C = get_chronicle_by_key(chron_key)
	if (!C) return FALSE
	C.entries -= entry_id
	C.touch()
	return TRUE
