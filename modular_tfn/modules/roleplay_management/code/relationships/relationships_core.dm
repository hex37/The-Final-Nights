// ==============================================================================
// RELATIONSHIP — CORE (relationship_core.dm)
// Canonical relationship datum (character↔character or character↔group)
// ==============================================================================

/datum/relationships
	// Identity
	var/id
	var/name //for display purposes Source -> Target (e.g. "Alice is Bob's (rtype/friend)")
	// Subject & Target
	var/subject_key                 // who owns/initiated the record
	var/target_type = "character"   // "character" | "group"
	var/target_key                  // character_key or group id

	// Properties
	var/rtype = "unknown"           // friend, ally, enemy, group, etc.
	var/strength = 50               // 0..100 (use clamp in New/setters)
	var/list/tags = list()
	var/mutual = FALSE              // if TRUE, you may create a mirrored record
	var/visible = TRUE
	var/list/related_memory_keys = list()

	// Audit
	var/created_by_key
	var/created_at = ""
	var/created_at_ts = 0
	var/updated_at = ""
	var/updated_at_ts = 0

/datum/relationships/New(id, subject_key, target_type, target_key, rtype = "unknown", strength = 50, created_by_key)
	..()
	src.id = id
	src.subject_key = "[subject_key]"
	src.target_type = target_type || "character"
	src.target_key  = "[target_key]"
	src.rtype = rtype
	src.strength = clamp(strength, 0, 100)
	src.created_by_key = created_by_key

	if (!src.id)
		var/pfx = "rel_[rtype]"
		src.id = SSroleplay_management.about_me_new_id(pfx)

	if (!created_at_ts)
		created_at_ts = world.realtime
		created_at = time2text(created_at_ts, "MMM DD, YYYY hh:mm")
	updated_at_ts = created_at_ts
	updated_at = created_at

	SSroleplay_management.register_relationship(src)


/datum/relationships/Destroy()
	SSroleplay_management.unregister_relationship(src)
	..()

/datum/relationships/proc/touch()
	updated_at_ts = world.realtime
	updated_at = time2text(updated_at_ts, "MMM DD, YYYY hh:mm")
