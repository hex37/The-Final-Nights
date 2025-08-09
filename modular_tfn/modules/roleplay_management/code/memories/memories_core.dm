// ==========================
// Memory Datum - Core (memory.dm)
// ==========================
/**
 * Memory datum.
 * - id:            Unique memory ID (auto-generated if not set).
 * - summary:       Short title/summary for UI display.
 * - details:       Longer description or details of the memory.
 * - tags:          List of tags (e.g., "background", "goal", "secret", etc).
 * - owner_key:     Character_key for the owner of this memory (can be null).
 * - related_keys:  List of related group, chronicle, relationship, or memory keys.
 * - date_occurred: Human-readable date/timestamp for the memory.
 * - source:        Internal tag for memory origin (e.g. "arrival_autogen").
 * - status:        Current status (e.g., "New", "Shared", etc).
 *
 * Memories represent player-authored journal entries, secrets, or log notes.
 * Each memory is globally registered for About Me and RP subsystem tracking.
 */
// ============================================================================
/datum/memory
	var/id                // Unique memory ID.
	var/summary = ""      // Short title or summary for UI.
	var/details = ""      // Detailed description.
	var/list/tags = list()// e.g. "background", "goal", etc
	var/owner_key = ""    // (optional) Which character_key owns it.
	var/list/related_keys = list() // Related group/chronicle/relationship/memory keys
	var/date_occurred = "" // (optional) Human-readable date or timestamp
	var/source = ""  // internal tag (e.g. "arrival_autogen")
	var/status = "New"

/**
 * Constructor: Generates a unique id/date if missing, registers the memory.
 */
/datum/memory/New(character_key)
	..()

	if (!date_occurred)
		date_occurred = time2text(world.realtime, "MMM DD, YYYY")

	if (!id)
		var/timestr = replacetext(time2text(world.realtime, "YYYY_MM_dd"), " ", "_")
		id = "[owner_key]_[timestr]_[rand(1,1000000)]"

	SSroleplay_management.register_memory(src)

/**
 * On deletion, unregister this memory from the global registry.
 */
/datum/memory/Destroy()
	SSroleplay_management.unregister_memory(src)
	..()

/**
 * Determines if the given character can see this memory.
 * (Override for secrets, privacy, etc. Currently always TRUE.)
 */
/datum/memory/proc/is_visible_to(mob/user, character_key)
	return TRUE

/**
 * Returns a UI-ready data structure for frontend/archival use.
 */
/datum/memory/proc/GetFormattedUI()
	return list(
		"id"            = id,
		"summary"       = summary,
		"details"       = details,
		"tags"          = islist(tags) ? tags.Copy() : list(),
		"owner_key"     = owner_key,
		"related_keys"  = islist(related_keys) ? related_keys.Copy() : list(),
		"date_occurred" = date_occurred,
		"status"        = status
	)
