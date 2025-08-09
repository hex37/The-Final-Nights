// ==============================================================================
// ABOUT ME COMPONENT (aboutme_core.dm)
// ------------------------------------------------------------------------------
//  - Attaches to every human mob (dormant unless activated by player client).
//  - Thin controller: Entry point and player control over About Me UI.
//  - All data, group/relationship/memory management is handled in aboutme_record.
// ==============================================================================

/datum/component/about_me
	var/mob/living/carbon/human/owner = null
	var/character_key = null

/// Called when the component is initialized and attached to a mob.
/// Grants the About Me UI action button to the mob.
/datum/component/about_me/Initialize()
	..()
	owner = parent
	var/datum/action/about_me/about_me_action = new(owner)
	about_me_action.Grant(parent)

/// Called when the component is destroyed (mob deleted or cleaned up).
/// Unregisters this component from the global registry and clears refs.
/datum/component/about_me/Destroy()
	if (character_key)
		SSroleplay_management.unregister_aboutme_component(src)
	owner = null
	..()

/// Updates or sets this component's character_key from the mob's true_real_name.
/// Ensures a consistent, unique key for About Me tracking.
/datum/component/about_me/proc/UpdateCharacterKey()
	var/raw_key = lowertext(replacetext(owner.true_real_name, " ", "_"))
	character_key = "[raw_key]_character_key"

/// Gets the aboutme_record for this component (optionally for another key).
/// This is the canonical data record, used for About Me info at runtime, supports future save and load features.
/datum/component/about_me/proc/get_aboutme_record(character_key_override = null)
	var/lookup_key = character_key_override ? character_key_override : character_key
	return SSroleplay_management.get_aboutme_record(lookup_key)

/// Convenience proc to get this component's own aboutme_record.
/// Returns null if no character_key is set.
/datum/component/about_me/proc/get_record()
	return SSroleplay_management.get_aboutme_record(character_key)

/// Provides the full About Me payload for TGUI.
/// Registers this component globally if needed, ensures the record exists, and returns all panel data.
/datum/component/about_me/proc/get_full_payload(mob/living/carbon/human/user)
	UpdateCharacterKey()
	if (!(src in GLOB.aboutme_components))
		SSroleplay_management.register_aboutme_component(src)
	var/datum/aboutme_record/aboutme_record = get_aboutme_record()
	if (!aboutme_record)
		aboutme_record = SSroleplay_management.ensure_aboutme_datum_for_key(character_key, owner)
	return aboutme_record.update_payload(owner)

/// Returns overview data (e.g. name, stats, clan) for the About Me UI tab.
/// Delegates to aboutme_record.
/datum/component/about_me/proc/build_overview_data()
	var/datum/aboutme_record/aboutme_record = get_aboutme_record()
	return aboutme_record.get_ui_overview_data(owner)

/// Returns all group data (by type) for the Groups tab in the About Me UI.
/// Delegates to aboutme_record.
/datum/component/about_me/proc/get_groups_for_ui()
	var/datum/aboutme_record/aboutme_record = get_aboutme_record()
	return aboutme_record.get_ui_groups(owner)

/// Returns categorized memories (by tag/category) for the Memories tab in the About Me UI.
/// Delegates to aboutme_record.
/datum/component/about_me/proc/get_memories_by_category()
	var/datum/aboutme_record/aboutme_record = get_aboutme_record()
	return aboutme_record.get_ui_memories_by_tag(owner)

/// Opens a TGUI prompt to vote on a group role action (officer/leader/etc).
/// Registers the player's choice and notifies them. Used by group voting features.
/// Prompts the user to vote in a group decision, then records their vote.
/datum/component/about_me/proc/prompt_vote_on_group(datum/group_vote/group_vote)
	var/datum/group/group = SSroleplay_management.get_group_by_key(group_vote.group_id)
	if (!group || !owner || !ismob(owner) || group_vote.has_voted(character_key))
		return
	var/vote_target = group.member_names[group_vote.target_character_key] || group_vote.target_character_key
	var/player_choice = tgui_input_list(
		owner,
		"Do you vote YES or NO to [group_vote.vote_type] [vote_target]?",
		"Vote in [group.name]: [group_vote.vote_type]",
		list("Yes", "No")
	)
	if (isnull(player_choice))
		return
	group_vote.add_vote(character_key, player_choice == "Yes")
	to_chat(owner, span_notice("Your vote for [vote_target] has been recorded."))
