// ==============================================================================
// RELATIONSHIP — EDIT (relationship_edit.dm)
// Sanitize at UI entry-point; these just mutate and touch.
// ==============================================================================

/datum/relationships/proc/set_strength(value)
	intensity = clamp(isnum(value) ? value : intensity, 0, 100)
	touch()



/datum/relationships/proc/set_visible(flag)
	visibility = !!flag
	touch()


