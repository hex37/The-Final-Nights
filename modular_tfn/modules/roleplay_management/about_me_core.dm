// ==============================================================================
// ABOUT ME COMPONENT (aboutme_core.dm)
// -- Thin controller/view for player character's About Me panel
// -- All persistent data lives in SSRPmanagement (ssroleplay_management.dm)
// ==============================================================================

/datum/component/about_me
	// === Local runtime vars only (no persistent storage here) ===
	var/mob/living/carbon/human/owner = null       // Mob this component is attached to
	var/character_key = null                        // Unique character ID, generated from true_real_name
	var/ckey = null                                 // Player ckey (fallback for display)
	var/connected_record = null                     // SSRP link (can be removed safely)

// ==============================================================================
// Component Lifecycle: Initialize/Destroy
// ==============================================================================
/datum/component/about_me/Initialize()
	..()
	if (!ismob(parent))
		CRASH("About Me component must attach to a mob!")
	owner = parent
	// We do NOT register with SSRP here — that's deferred to UI open
	var/datum/action/about_me/action = new(owner)
	action.Grant(parent)  // Adds the UI button to open About Me

/datum/component/about_me/Destroy()
	if (character_key)
		SSroleplay_management.remove_key_from_all_groups(character_key)
		SSroleplay_management.unregister_aboutme_component(src)
	owner = null
	..()


// ==============================================================================
// Character Key Handling: Builds a consistent, underscore-safe character key
// Used to index all data in SSRPmanagement
// ==============================================================================
/datum/component/about_me/proc/UpdateCharacterKey()
	if (owner && owner.true_real_name)
		var/raw_key = lowertext(replacetext(owner.true_real_name, " ", "_"))
		character_key = "[raw_key]_character_key"

// ==============================================================================
// Fetch From SSRP: AboutMeRecord, Groups, Relationships, Memories
// ==============================================================================
/datum/component/about_me/proc/get_aboutme_datum(character_key_override = null)
	var/key = character_key_override || character_key
	return SSroleplay_management.get_aboutme_datum_for_key(key)

/datum/component/about_me/proc/get_record()
	if (!src.character_key)
		return null
	return SSroleplay_management.get_aboutme_record(src.character_key)

/datum/component/about_me/proc/get_full_payload(mob/living/carbon/human/user)
	UpdateCharacterKey()

	// First-time registration (in case we're not yet known to SSRP)
	if (!(src in GLOB.aboutme_components))
		SSroleplay_management.register_aboutme_component(src)

	var/datum/aboutme_record/R = get_aboutme_datum()
	if (!R)
		R = SSroleplay_management.ensure_aboutme_datum_for_key(character_key, owner)

	return R.update_payload(owner)  // Gets UI-ready structured payload

// ==============================================================================
// Tab-Specific Fetchers: Overview, Groups, Memories
// ==============================================================================
/datum/component/about_me/proc/build_overview_data()
	var/datum/aboutme_record/R = get_aboutme_datum()
	if (!R) return list()
	return R.build_overview_data()

/datum/component/about_me/proc/get_groups_for_ui()
	var/datum/aboutme_record/R = get_aboutme_datum()
	if (!R) return list()
	return R.get_ui_groups(owner)

/// Returns memory objects grouped by tag/category
/datum/component/about_me/proc/get_memories_by_category()
	var/datum/aboutme_record/R = get_aboutme_datum()
	if (!R) return list()
	return R.get_ui_memories_by_tag(owner)

// ==============================================================================
// Editable Field Setters: All updates routed to SSRP datums (AboutMeRecord)
// ==============================================================================
/datum/component/about_me/proc/set_display_name(name)
	var/datum/aboutme_record/R = get_aboutme_datum()
	if (R) R.set_display_name(name)

/datum/component/about_me/proc/set_goals(goals)
	var/datum/aboutme_record/R = get_aboutme_datum()
	if (R) R.set_goals(goals)

// Add similar setters here for secrets, alignment, roles, etc.
// All setters should follow the pattern above

// ==============================================================================
// Helpers: Group Keys
// ==============================================================================
/datum/component/about_me/proc/get_current_group_keys()
	var/datum/aboutme_record/R = get_aboutme_datum()
	if (!R) return list()
	return R.get_current_group_keys(owner)

// ==============================================================================
// Debug Tools: Show JSON payload in-game
// ==============================================================================
/client/verb/DebugAboutMePayload()
	set name = "About Me Debug Payload"
	set category = "IC"
	if (!istype(mob, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = mob
	var/datum/component/about_me/C = H.GetComponent(/datum/component/about_me)
	if (!C) return
	to_chat(src, "<span class='notice'>[json_encode(C.get_full_payload(), TRUE)]</span>")


/datum/component/about_me/proc/prompt_vote_on_group(datum/group_vote/V)
	if (!V || !owner || !ismob(owner)) return

	var/datum/group/G = SSroleplay_management.get_group_by_key(V.group_id)
	if (!G || V.has_voted(src.character_key)) return

	var/target = G.member_names[V.target_character_key] || V.target_character_key
	var/title = "Vote in [G.name]: [V.vote_type]"
	var/message = "Do you vote YES or NO to [V.vote_type] [target]?"

	var/choice = tgui_input_list(owner, message, title, list("Yes", "No"))
	if (isnull(choice)) return

	V.add_vote(src.character_key, choice == "Yes")
	to_chat(owner, "<span class='notice'>Your vote for [target] has been recorded.</span>")

