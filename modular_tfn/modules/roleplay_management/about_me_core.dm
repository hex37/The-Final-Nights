// ==============================================================================
// ABOUT ME COMPONENT (aboutme_core.dm)
// ------------------------------------------------------------------------------
//  - Attaches to every human mob (dormant unless activated by player client).
//  - Acts as the thin controller/view for the About Me TGUI panel.
//  - Handles runtime identity, record lookup, UI payload assembly, and player
//    editing actions.
//  - All persistent data and relationships live in the SSRP Management subsystem.
// ==============================================================================

/datum/component/about_me
	/// The mob this component is attached to (set on Initialize()).
	/// Only valid for human/player mobs.
	var/mob/living/carbon/human/owner = null

	/// Unique character key (built from the player's true_real_name).
	/// Used to fetch/update all About Me records and RP links.
	var/character_key = null

	/// Player BYOND ckey (optional/fallback, not persisted).
	var/ckey = null

	/// Reference to the aboutme_record (optional, future optimization/caching).
	var/connected_record = null


/// Called when the component is initialized and attached to a mob.
/// - Checks for valid mob.
/// - Creates and grants the About Me UI button.
/// - SSRP registration is deferred for now, done on UI open for performance.
/datum/component/about_me/Initialize()
	..()
	if (!ismob(parent))
		CRASH("About Me component must attach to a mob!")
	owner = parent
	// Add the UI button for About Me panel.
	var/datum/action/about_me/action = new(owner)
	action.Grant(parent)


/// Called when the component is destroyed (mob deleted/cleaned up).
/// - Removes this character from all groups.
/// - Unregisters this component from the global registry.
/datum/component/about_me/Destroy()
	if (character_key)
		SSroleplay_management.remove_key_from_all_groups(character_key)
		SSroleplay_management.unregister_aboutme_component(src)
	owner = null
	..()

// ==============================================================================
// Identity & Record Handling
// ==============================================================================

/// Builds or updates this component's character_key from the mob's true_real_name.
/// Ensures a consistent, in-round identity for About Me tracking.
/datum/component/about_me/proc/UpdateCharacterKey()
	if (owner && owner.true_real_name)
		var/raw_key = lowertext(replacetext(owner.true_real_name, " ", "_"))
		character_key = "[raw_key]_character_key"


/// Fetches the aboutme_record for this character (optionally override key for remote display viewing).
/// All About Me data, group keys, relationships, and memories are stored here.
/datum/component/about_me/proc/get_aboutme_record(character_key_override = null)
	var/key = character_key_override || character_key
	return SSroleplay_management.get_aboutme_record(key)


/// Shorthand to fetch this component's aboutme_record.
/datum/component/about_me/proc/get_record()
	return character_key ? SSroleplay_management.get_aboutme_record(character_key) : null

/// Generates the full About Me UI payload for this mob/player.
/// - Registers the component globally (if not already).
/// - Ensures a valid aboutme_record.
/// - Returns everything needed for TGUI (overview, groups, rels, memories, etc).
/datum/component/about_me/proc/get_full_payload(mob/living/carbon/human/user)
	UpdateCharacterKey()
	if (!(src in GLOB.aboutme_components))
		SSroleplay_management.register_aboutme_component(src)
	var/datum/aboutme_record/R = get_aboutme_record()
	if (!R)
		R = SSroleplay_management.ensure_aboutme_datum_for_key(character_key, owner)
	return R.update_payload(owner)


// ==============================================================================
// Tab-Specific Data Fetchers (used by the TGUI handler)
// ==============================================================================

/// Returns overview data (name, stats, disciplines, etc) for the About Me panel.
/// Delegates to the aboutme_record.
/datum/component/about_me/proc/build_overview_data()
	var/datum/aboutme_record/R = get_aboutme_record()
	return R?.build_overview_data(owner)


/// Returns a list of group objects for the Groups tab in About Me.
/// Delegates to the aboutme_record.
/datum/component/about_me/proc/get_groups_for_ui()
	var/datum/aboutme_record/R = get_aboutme_record()
	return R?.get_ui_groups(owner)


/// Returns categorized memories for the Memories tab (by tag/category).
/datum/component/about_me/proc/get_memories_by_category()
	var/datum/aboutme_record/R = get_aboutme_record()
	return R?.get_ui_memories_by_tag(owner)


// ==============================================================================
// Editable Field Setters (UI-triggered, always routed to aboutme_record)
// ==============================================================================

/// Sets the character's display name via the aboutme_record.
/datum/component/about_me/proc/set_display_name(name)
	var/datum/aboutme_record/R = get_aboutme_record()
	if (R) R.set_display_name(name)


/// Sets the character's goals string via the aboutme_record.
/datum/component/about_me/proc/set_goals(goals)
	var/datum/aboutme_record/R = get_aboutme_record()
	if (R) R.set_goals(goals)


// ==============================================================================
// Helpers - Group Key Access
// ==============================================================================

/// Returns all current group keys (ids) for this character.
/// Used for membership and permission checks.
/datum/component/about_me/proc/get_current_group_keys()
	var/datum/aboutme_record/R = get_aboutme_record()
	return R?.get_current_group_keys(owner)


// ==============================================================================
// Debug Verb - Shows the About Me JSON payload (for dev/admin use)
// ==============================================================================

/// Admin/Dev verb: Prints this mob's About Me JSON payload to chat.
/// Useful for inspecting the current state of the current controled character's About Me record.
/client/verb/DebugAboutMePayload()
	set name = "About Me Debug Payload"
	set category = "IC"
	if (!istype(mob, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = mob
	var/datum/component/about_me/C = H.GetComponent(/datum/component/about_me)
	if (!C) return
	to_chat(src, "<span class='notice'>[json_encode(C.get_full_payload(), TRUE)]</span>")


// ==============================================================================
// Voting Helper - Simple voting prompt for group role actions
// ==============================================================================

/// Opens a TGUI prompt to vote on a group role/officer/leader action.
/// - Used for in-group leadership votes or officer promotions.
/// - Registers the player's choice and updates the vote tally.
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

