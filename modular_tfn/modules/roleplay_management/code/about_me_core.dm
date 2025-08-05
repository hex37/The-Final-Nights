// ==============================================================================
// ABOUT ME COMPONENT (aboutme_core.dm)
// ------------------------------------------------------------------------------
//  - Attaches to every human mob (dormant unless activated by player client).
//  - Thin controller: Entry point and player control over About Me UI.
//  - All data, group/relationship/memory management is handled in aboutme_record.
// ==============================================================================

/datum/component/about_me
    // Quick reference to the mob this is attached to
    var/mob/living/carbon/human/owner = null
    // Unique character key (built from owner mob's true_real_name.)
    var/character_key = null

/datum/component/about_me/Initialize()
    ..()
    owner = parent
    // Add UI button for About Me
    var/datum/action/about_me/action = new(owner)
    action.Grant(parent)

/datum/component/about_me/Destroy()
    if (character_key)
        SSroleplay_management.unregister_aboutme_component(src)
    owner = null
    ..()

    // === IDENTITY & RECORD LOOKUP ===

    /// Updates/sets character_key from mob's true_real_name
/datum/component/about_me/proc/UpdateCharacterKey()
    if (owner && owner.true_real_name)
        var/raw_key = lowertext(replacetext(owner.true_real_name, " ", "_"))
        character_key = "[raw_key]_character_key"

    /// Gets this component's aboutme_record (optionally for another key)
/datum/component/about_me/proc/get_aboutme_record(character_key_override = null)
    var/key = character_key_override || character_key
    return SSroleplay_management.get_aboutme_record(key)

    /// Short form: gets this record for convenience
/datum/component/about_me/proc/get_record()
    return character_key ? SSroleplay_management.get_aboutme_record(character_key) : null

    // === UI PAYLOAD & TGUI INTERFACE ===

    /// Provides the full About Me payload for TGUI
/datum/component/about_me/proc/get_full_payload(mob/living/carbon/human/user)
    UpdateCharacterKey()
    if (!(src in GLOB.aboutme_components))
        SSroleplay_management.register_aboutme_component(src)
    var/datum/aboutme_record/R = get_aboutme_record()
    if (!R)
        R = SSroleplay_management.ensure_aboutme_datum_for_key(character_key, owner)
    return R.update_payload(owner)

    /// Tab data accessors (all just delegate to the record)
/datum/component/about_me/proc/build_overview_data()
    var/datum/aboutme_record/R = get_aboutme_record()
    return R?.get_ui_overview_data(owner)

/datum/component/about_me/proc/get_groups_for_ui()
    var/datum/aboutme_record/R = get_aboutme_record()
    return R?.get_ui_groups(owner)

/datum/component/about_me/proc/get_memories_by_category()
    var/datum/aboutme_record/R = get_aboutme_record()
    return R?.get_ui_memories_by_tag(owner)

    // === VOTING UI (quick access, yes or no, with context for groups to use.) ===
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

// ==============================================================================
// END OF /datum/component/about_me (REFINED)
// ==============================================================================

