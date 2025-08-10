// ==============================================================================
// GROUP — UI (group_ui.dm)
// Pure formatting helpers; no DB logic.
// ==============================================================================

/datum/group/proc/prettify_character_key(key)
	if (!istext(key)) return key
	if (findtext(key, "_character_key"))
		var/base = replacetext(key, "_character_key", "")
		base = capitalize_words(replacetext(base, "_", " "))
		return base
	return key

/datum/group/proc/capitalize_words(text)
	var/list/words = splittext(text, " ")
	for (var/i = 1, i <= length(words), i++)
		words[i] = capitalize(words[i])
	return jointext(words, " ")

/datum/group/proc/resolve_display_name(key)
	var/datum/component/about_me/C = SSroleplay_management.get_aboutme_component(key)
	if (C?.owner && ismob(C.owner))
		return C.owner.true_real_name || C.owner.real_name
	return prettify_character_key(key)

/// The single UI payload proc.
/datum/group/proc/GetFormattedUI()
	// Build display-name lists
	var/list/leader_names  = list()
	for (var/k in leader_keys)  leader_names  += resolve_display_name(k)

	var/list/officer_names = list()
	for (var/k in officer_keys) officer_names += resolve_display_name(k)

	var/list/member_names  = list()
	for (var/k in member_keys)  member_names  += resolve_display_name(k)

	var/leader_display = leader_names.len ? leader_names[1] : ""
	var/total_members_count = leader_names.len + officer_names.len + member_names.len

	return list(
		"id"           = id,
		"name"         = name,
		"group_type"   = get_group_type(),
		"desc"         = desc,
		"tags"         = islist(tags) ? tags.Copy() : list(),
		"is_public"    = is_public,
		"status"       = status,

		// UI-friendly names
		"leader_name"  = leader_display,
		"leaders"      = leader_names,
		"officers"     = officer_names,
		"members"      = member_names,
		"members_count"= total_members_count,

		// raw keys for logic
		"leader_keys"  = islist(leader_keys)  ? leader_keys  : list(),
		"officer_keys" = islist(officer_keys) ? officer_keys : list(),
		"member_keys"  = islist(member_keys)  ? member_keys  : list(),

		"created_at"   = created_at,
		"updated_at"   = updated_at
	)
