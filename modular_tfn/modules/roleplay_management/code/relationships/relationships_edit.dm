// ==============================================================================
// RELATIONSHIP — EDIT (relationship_edit.dm)
// Sanitize at UI entry-point; these just mutate and touch.
// ==============================================================================

/datum/relationships/proc/set_strength(value)
	strength = clamp(isnum(value) ? value : strength, 0, 100)
	touch()

/datum/relationships/proc/add_tag(tag)
	if (!tag) return
	if (!islist(tags)) tags = list()
	if (!(tag in tags)) tags += tag
	touch()

/datum/relationships/proc/remove_tag(tag)
	if (!islist(tags)) return
	tags -= tag
	touch()

/datum/relationships/proc/set_visible(flag)
	visible = !!flag
	touch()

/**
 * If you want to create a mirror automatically when mutual is TRUE.
 * Returns the mirrored relationship or null.
 */
/datum/relationships/proc/ensure_mutual()
	if (!mutual) return null
	// Only meaningful for character↔character cases
	if (target_type != "character") return null
	var/mirror_id = "[target_key]_character_[subject_key]_[rand(1,1000000)]"
	var/datum/relationships/mirror = new(mirror_id, target_key, "character", subject_key, rtype, strength, created_by_key)
	mirror.mutual = TRUE
	return mirror
