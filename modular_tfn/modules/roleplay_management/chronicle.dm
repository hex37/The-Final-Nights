/datum/chronicle
	var/id = null
	var/title = "Chronicle"
	var/ctype = null   // "event", "arc", "plot"
	var/desc = ""
	var/list/tags = list()
	var/date_started = ""
	var/date_ended = ""
	var/list/host_key = "" //character or group key.
	var/list/related_characters = list() // shared character_keys
	var/list/related_groups = list()     // shared group ids
	var/list/related_memories = list()   // memory ids shared to this chronicle

/datum/chronicle/New(
	host_key_arg = null,
	title_arg = "Chronicle",
	ctype_arg = "event",
	desc_arg = "",
	date_started_arg = "",
	date_ended_arg = "",
	list/related_characters_arg = null,
	list/related_groups_arg = null,
	list/related_memories_arg = null
)
	..()
	host_key = host_key_arg
	id = "[host_key]_personal_chronicle_[world.time]_[rand(1,1000000)]"
	title = title_arg
	ctype = ctype_arg
	desc = desc_arg
	date_started = date_started_arg
	date_ended = date_ended_arg
	related_characters = related_characters_arg || list()
	related_groups = related_groups_arg || list()
	related_memories = related_memories_arg || list()

	SSroleplay_management.register_chronicle(src)


/datum/chronicle/Destroy()
	SSroleplay_management.unregister_chronicle(src)
	..()

/datum/chronicle/proc/is_visible_to(mob/user, character_key)
	return TRUE

/datum/chronicle/proc/GetFormattedUI()
	return list(
		"id"                = id,
		"title"             = title,
		"desc"              = desc,
		"ctype"             = ctype,
		"tags"              = tags,
		"date_started"      = date_started,
		"date_ended"        = date_ended,
		"related_characters"= islist(related_characters) ? related_characters.Copy() : list(),
		"related_groups"    = islist(related_groups) ? related_groups.Copy() : list(),
		"related_memories"  = islist(related_memories) ? related_memories.Copy() : list()
	)

