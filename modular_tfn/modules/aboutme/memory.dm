// ==========================
// Memory Datum - Core
// ==========================
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
/datum/memory/New(character_key)
    ..()

    if (!date_occurred)
        date_occurred = time2text(world.realtime, "MMM DD, YYYY")

    if (!id)
        var/timestr = replacetext(time2text(world.realtime, "YYYY_MM_dd"), " ", "_")
        id = "[owner_key]_[timestr]_[rand(1,1000000)]"

    SSrpmanagement.register_memory(src)



/datum/memory/Destroy()
    SSrpmanagement.unregister_memory(src)
    ..()

/datum/memory/proc/is_visible_to(mob/user, character_key)
    return TRUE


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

