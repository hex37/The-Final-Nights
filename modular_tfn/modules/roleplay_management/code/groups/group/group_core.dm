// ==============================================================================
// GROUP — CORE (group_core.dm)
// Canonical group datum (no UI, no voting here).
// ==============================================================================

/datum/group
	var/id
	var/name = "Unnamed Group"
	var/group_type = "unknown"     // e.g. "organization", "party", "coterie"
	var/desc = ""
	var/list/tags = list()

	var/is_public = TRUE
	var/status = "Active"          // Active, Closed, Hidden

	var/list/leader_keys = list()
	var/list/officer_keys = list()
	var/list/member_keys = list()

	var/created_by_key
	var/created_at = ""
	var/created_at_ts = 0
	var/updated_at = ""
	var/updated_at_ts = 0

	// Relationships/chronicles collections can be tracked at SSRP,
	// but keep optional IDs here if you already reference them:
	var/list/chronicle_keys = list()
	var/list/group_relationship_keys = list()

/datum/group/New(id, name, group_type, desc, is_public = TRUE, created_by_key)
	..()
	id = id || "[id]_[group_type]_[rand(1000,9999)]_[world.time]" //(player made ID's)
	name = name
	group_type = group_type
	desc = desc
	is_public = is_public
	created_by_key = created_by_key
	if (!created_at_ts)
		created_at_ts = world.realtime
		created_at = time2text(created_at_ts, "MMM DD, YYYY hh:mm")
	updated_at_ts = created_at_ts
	updated_at = created_at

	SSroleplay_management.register_group(src)

/datum/group/Destroy()
	SSroleplay_management.unregister_group(src)
	..()

/datum/group/proc/touch()
	updated_at_ts = world.realtime
	updated_at = time2text(updated_at_ts, "MMM DD, YYYY hh:mm")


/datum/group/proc/get_group_type()
	if (group_type && group_type != "unknown") return group_type
	if (istype(src, /datum/group/city))         return "city"
	if (istype(src, /datum/group/faction))      return "faction"
	if (istype(src, /datum/group/sect))         return "sect"
	if (istype(src, /datum/group/clan))         return "clan"
	if (istype(src, /datum/group/tribe))        return "tribe"
	if (istype(src, /datum/group/organization)) return "organization"
	if (istype(src, /datum/group/party))        return "party"
	return "unknown"
