// ==============================================================================
// MEMORY — UI (memory_ui.dm)
// Visibility + optional richer helpers.
// ==============================================================================

/**
 * Override for secrets/privacy if needed later.
 * Currently all memories are visible.
 */
/datum/memory/proc/is_visible_to(mob/user, character_key)
	return TRUE

// Example richer UI helper: resolve friendly related labels later if desired.
// Keep IDs here; front-end or SSRP can resolve names safely.
