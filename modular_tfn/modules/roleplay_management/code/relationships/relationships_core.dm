// ============================================================================
// Relationship Datum (relationships.dm)
// ----------------------------------------------------------------------------
// Represents a single relationship between two characters or a character and a group.
// - Can be mutual or one-way.
// - Stores relationship type (friend, rival, etc), strength, tags, and visibility.
// - Registered globally by the RP Management subsystem.
// ----------------------------------------------------------------------------

/**
 * Relationship datum.
 * - id:         Unique relationship key (auto-generated if not set).
 * - name:       Display name for the relationship.
 * - rtype:      Relationship type (e.g. "friend", "rival", "enemy", etc).
 * - desc:       Freeform description.
 * - strength:   Loyalty/affinity score, negative for foes.
 * - tags:       List of arbitrary tags for sorting/filtering.
 * - visible:    Should the relationship be visible in the UI?
 * - group_target_id:  If present, this is a character-group relationship.
 * - source_character: character_key for the originator.
 * - target_character: character_key for the target (null for group).
 * - date_created:     When the relationship was created (for sorting/history).
 * - mutual:     If TRUE, this is a mutual relationship.
// ============================================================================
 */
/datum/relationships
	var/id = null
	var/name = "Relationship"
	var/rtype = null
	var/desc = ""
	var/strength = 0
	var/list/tags = list()
	var/visible = TRUE
	var/group_target_id = null
	var/source_character = null
	var/target_character = null
	var/date_created = ""
	var/mutual = FALSE

/**
 * On creation: auto-generates an id and creation date if missing, registers with subsystem.
 */
/datum/relationships/New()
	..()
	if (!id)
		id = "[lowertext(trim(name))]_[world.time]_[rand(1,1000000)]"
	if (!date_created)
		date_created = "[world.realtime]"
	SSroleplay_management.register_relationship(src)
	message_admins("([id]) created with type: [rtype], strength: [strength]")

/**
 * On deletion: unregisters from global subsystem.
 */
/datum/relationships/Destroy()
	SSroleplay_management.unregister_relationship(src)
	..()

/**
 * Returns TRUE if the given character can see this relationship in the UI.
 * - Character is source/target, or (for group relationships) in the group.
 */
/datum/relationships/proc/is_visible_to(mob/user, character_key)
	var/datum/aboutme_record/rec = SSroleplay_management.get_aboutme_datum_for_key(character_key)
	if (!rec) return FALSE
	return ((character_key == source_character) || (character_key == target_character) || (group_target_id) && (group_target_id in rec.group_keys))

/**
 * Returns a UI-ready data structure for this relationship.
 * - Group relationships display group name instead of character key.
 */
/datum/relationships/proc/GetFormattedUI()
	var/target_display = target_character
	if (group_target_id)
		var/datum/group/G = SSroleplay_management.get_group_by_key(group_target_id)
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
