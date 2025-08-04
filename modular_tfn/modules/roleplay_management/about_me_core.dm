// ==============================================================================
// ABOUT ME COMPONENT (aboutme_core.dm)
// -- Thin controller/view for player character's About Me panel
// -- All persistent data lives in SSRPmanagement (ssroleplay_management.dm)
// ==============================================================================
/datum/component/about_me
	// === runtime vars only (no persistent storage here, use record) ===
	var/mob/living/carbon/human/owner = null
	var/character_key = null
	var/ckey = null
	var/connected_record = null

/datum/component/about_me/Initialize()
	..()
	if (!ismob(parent))
		CRASH("About Me component must attach to a mob!")
	owner = parent
	// SSRP registration is deferred until the player opens the UI for lightweight startup, and "opt-in" feature for now.
	var/datum/action/about_me/action = new(owner)
	action.Grant(parent)  // Adds UI button to open About Me, currently right next to the old one, for players and testing to compare.

/datum/component/about_me/Destroy()
	if (character_key)
		SSroleplay_management.remove_key_from_all_groups(character_key)
		SSroleplay_management.unregister_aboutme_component(src)
	owner = null
	..()

// Character Key Handling: Builds a consistent, safe character key for current Runtime needs.
//Will be expanded later for saving features.
/datum/component/about_me/proc/UpdateCharacterKey()
	if (owner && owner.true_real_name)
		var/raw_key = lowertext(replacetext(owner.true_real_name, " ", "_"))
		character_key = "[raw_key]_character_key"

// Record and Payload Fetching
/datum/component/about_me/proc/get_aboutme_record(character_key_override = null)
	var/key = character_key_override || character_key
	return SSroleplay_management.get_aboutme_record(key)
/datum/component/about_me/proc/get_record()
	return character_key ? SSroleplay_management.get_aboutme_record(character_key) : null
/datum/component/about_me/proc/get_full_payload(mob/living/carbon/human/user)
	UpdateCharacterKey()
	if (!(src in GLOB.aboutme_components))
		SSroleplay_management.register_aboutme_component(src)
	var/datum/aboutme_record/R = get_aboutme_record()
	if (!R)
		R = SSroleplay_management.ensure_aboutme_datum_for_key(character_key, owner)
	return R.update_payload(owner) // Returns the full UI-ready payload
// ==============================================================================
// Tab-Specific Fetchers (delegated to aboutme_record)
// ==============================================================================
/datum/component/about_me/proc/build_overview_data()
	var/datum/aboutme_record/R = get_aboutme_record()
	return R?.build_overview_data(owner)

/datum/component/about_me/proc/get_groups_for_ui()
	var/datum/aboutme_record/R = get_aboutme_record()
	return R?.get_ui_groups(owner)

/datum/component/about_me/proc/get_memories_by_category()
	var/datum/aboutme_record/R = get_aboutme_record()
	return R?.get_ui_memories_by_tag(owner)

// ==============================================================================
// Editable Field Setters: Always routed through SSRP datums (AboutMeRecord)
// ==============================================================================
/datum/component/about_me/proc/set_display_name(name)
	var/datum/aboutme_record/R = get_aboutme_record()
	if (R) R.set_display_name(name)
/// Can add similar setters here for secrets, alignment, roles, etc.
/datum/component/about_me/proc/set_goals(goals)
	var/datum/aboutme_record/R = get_aboutme_record()
	if (R) R.set_goals(goals)
// ==============================================================================
// Helpers: Group Keys (delegated to record)
// ==============================================================================
/datum/component/about_me/proc/get_current_group_keys()
	var/datum/aboutme_record/R = get_aboutme_record()
	return R?.get_current_group_keys(owner)
// ==============================================================================
// Debug Tools: Show JSON payload in-game (for devs/admins)
// ==============================================================================
/client/verb/DebugAboutMePayload()
	set name = "About Me Debug Payload"
	set category = "IC"
	if (!istype(mob, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = mob
	var/datum/component/about_me/C = H.GetComponent(/datum/component/about_me)
	if (!C) return
	to_chat(src, "<span class='notice'>[json_encode(C.get_full_payload(), TRUE)]</span>")

// ==============================================================================
// Voting Helper (simple UI for group role/officer/leader voting)
// ==============================================================================
/datum/component/about_me/proc/prompt_vote_on_group(datum/group_vote/V)
	if (!V || !owner || !ismob(owner)) return
	var/datum/group/G = SSroleplay_management.get_group_by_key(V.group_id)
	if (!G || V.has_voted(character_key)) return
	var/target = G.member_names[V.target_character_key] || V.target_character_key
	var/title = "Vote in [G.name]: [V.vote_type]"
	var/message = "Do you vote YES or NO to [V.vote_type] [target]?"
	var/choice = tgui_input_list(owner, message, title, list("Yes", "No"))
	if (isnull(choice)) return
	V.add_vote(character_key, choice == "Yes")
	to_chat(owner, "<span class='notice'>Your vote for [target] has been recorded.</span>")

