// RP Management Subsystem - Memories (ssroleplay_management_memories.dm)
/datum/controller/subsystem/roleplay_management/proc/register_memory(datum/memory/M)
	if (!M?.id || !is_valid_id(M.id)) return
	GLOB.memories[M.id] = M

/datum/controller/subsystem/roleplay_management/proc/unregister_memory(datum/memory/M)
	if (!M?.id) return
	GLOB.memories -= M.id

/datum/controller/subsystem/roleplay_management/proc/get_memory_by_key(id)
	return is_valid_id(id) ? GLOB.memories[id] : null

/datum/controller/subsystem/roleplay_management/proc/get_all_memories()
	return GLOB.memories

/datum/controller/subsystem/roleplay_management/proc/ensure_entry_memory_for_key(character_key, mob/living/carbon/human/owner)
	if (!character_key || !owner) return null
	var/datum/aboutme_record/rec = get_aboutme_record(character_key)
	if (!rec) return null
	for (var/mkey in rec.memory_keys)
		var/datum/memory/existing = get_memory_by_key(mkey)
		if (existing?.source == "arrival_autogen")
			return existing

	var/datum/memory/M = new /datum/memory(character_key)
	M.set_summary("Another Night in the City")
	M.set_details("[owner.real_name || owner.name] arrived in the city.")
	M.add_tag("background")
	M.add_tag("recent")
	M.source = "arrival_autogen"

	if (!(M.id in rec.memory_keys))
		rec.memory_keys += M.id
	rec.touch()
	return M
