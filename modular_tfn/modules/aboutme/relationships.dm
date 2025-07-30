/datum/relationships
    var/id = null            // Unique key string
    var/name = "Relationship"
    var/rtype = null         // "friend", "foe", "rival", etc
    var/desc = ""
    var/strength = 0         // 0 = neutral, positive/negative values
    var/list/tags = list()
    var/visible = TRUE
    var/group_target_id = null //if its a group relationship, what group?
    var/source_character = null // character_key of source
    var/target_character = null // character_key of target
    var/date_created = ""       // e.g. "2025-07-23"

/datum/relationships/New()
    ..()
    if (!id)
        id = "[rtype]_[world.time]_[rand(1,1000000)]"
    if (!date_created)
        date_created = "[world.realtime]"
    SSrpmanagement.register_relationship(src)
    message_admins("([id]) created with type: [rtype], strength: [strength]")

/datum/relationships/Destroy()
    SSrpmanagement.unregister_relationship(src)
    ..()

/datum/relationships/proc/is_visible_to(mob/user, character_key)
    var/datum/aboutme_record/rec = SSrpmanagement.get_aboutme_datum_for_key(character_key)
    if (!rec) return FALSE
    return ((character_key == source_character) || (character_key == target_character) || (group_target_id) && (group_target_id in rec.group_keys))


/datum/relationships/proc/GetFormattedUI()
    var/target_display = target_character
    if (group_target_id)
        var/datum/group/G = SSrpmanagement.get_group_by_key(group_target_id)
        target_display = G?.name || group_target_id

    return list(
        "id"           = id,
        "name"         = name,
        "desc"         = desc,
        "rtype"        = rtype,
        "strength"     = strength,
        "tags"         = islist(tags) ? tags.Copy() : list(),
        "visible"      = visible,
        "source"       = source_character,
        "target"       = target_display,
        "is_group"     = isnull(target_character) && !isnull(group_target_id),
        "group_id"     = group_target_id,
        "date_created" = date_created
    )


