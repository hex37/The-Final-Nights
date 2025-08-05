/**
 * Chronicle datum.
 * - id:                Unique chronicle ID (auto-generated on creation).
 * - title:             Display name for the chronicle/event/story arc.
 * - ctype:             Chronicle type ("event", "arc", "plot", etc).
 * - desc:              Description or summary of the event or arc.
 * - tags:              List of arbitrary tags for sorting/search.
 * - date_started:      When the chronicle/event began (string).
 * - date_ended:        When the chronicle/event ended (string, optional).
 * - host_key:          Key of the host (character or group); who “owns” this chronicle.
 * - related_characters: List of character_keys involved in the event.
 * - related_groups:    List of group IDs involved in the event.
 * - related_memories:  List of memory IDs attached to this chronicle.
 *
 * Chronicles represent shared RP history: memorable events, stories, or arcs.
 * They link to multiple memories, characters, and groups, and are registered globally.
 */
// ============================================================================
/datum/chronicle
	var/id = null
	var/title = "Chronicle"
	var/ctype = null   // "event", "arc", "plot"
	var/desc = ""
	var/list/tags = list()
	var/date_started = ""
	var/date_ended = ""
	var/list/host_key = "" // character or group key (who “owns” the chronicle)
	var/list/related_characters = list() // All character_keys in this chronicle
	var/list/related_groups = list()     // All group ids linked
	var/list/related_memories = list()   // All memory ids attached

/**
 * Chronicle constructor.
 * Accepts all key fields as arguments, generates a unique id and registers globally.
 */
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

/**
 * Unregisters this chronicle from global subsystem on deletion.
 */
/datum/chronicle/Destroy()
	SSroleplay_management.unregister_chronicle(src)
	..()

/**
 * Checks if this chronicle is visible to the given character.
 * (Override for custom access logic; currently always TRUE.)
 */
/datum/chronicle/proc/is_visible_to(mob/user, character_key)
	return TRUE

/**
 * Returns a UI-ready list of chronicle data for frontend use.
 */
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
