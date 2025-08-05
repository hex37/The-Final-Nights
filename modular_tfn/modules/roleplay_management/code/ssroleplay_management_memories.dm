// ================================================================
// RP Management Subsystem - Memories (ssroleplay_management_memories.dm)
// ================================================================
// Handles:
//   - Registration and global storage of all memory datums
//   - Character-specific memory generation (e.g., arrival memory)
//   - Visibility and memory record tracking
// ================================================================
// ---------------- REGISTER / LOOKUP ----------------
/datum/controller/subsystem/roleplay_management/proc/register_memory(datum/memory/M)
	if (M?.id && is_valid_key(M.id))
		GLOB.memories[M.id] = M
/datum/controller/subsystem/roleplay_management/proc/get_memory_by_key(key)
	return is_valid_key(key) ? GLOB.memories[key] : null
/datum/controller/subsystem/roleplay_management/proc/unregister_memory(datum/memory/M)
	if (M?.id)
		GLOB.memories -= M.id
// ---------------- MEMORY CREATORS ----------------
/datum/controller/subsystem/roleplay_management/proc/ensure_entry_memory_for_key(character_key, mob/living/carbon/human/owner)
	if (!character_key || !owner) return
	var/datum/aboutme_record/rec = get_aboutme_record(character_key)
	if (!rec) return
	// Check if memory already exists
	for (var/key in rec.memory_keys)
		var/datum/memory/M = get_memory_by_key(key)
		if (M?.source == "arrival_autogen")
			return
	// Build memory content
	var/summary = "Another Night the City"
	var/details = "[owner.real_name || owner.name] arrived in the city."
	var/datum/memory/M = new
	M.owner_key = character_key
	M.summary = summary
	M.details = details
	M.tags = list("background", "recent")
	M.source = "arrival_autogen"
	// Register and attach
	rec.memory_keys += M.id
	return M
