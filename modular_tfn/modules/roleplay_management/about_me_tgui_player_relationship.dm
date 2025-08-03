// ============================================================================
// About Me: Player Input - Mutual Relationship Management (Player ↔ Player)
// ============================================================================
// Only handles player-to-player (mutual) relationships, not groups.
// Group relationships are managed in the Groups tab/UI.
// ============================================================================

/datum/component/about_me/proc/prompt_change_relationship(mob/user)
    message_admins("[key_name(user)] opened the Relationship editor.")
    var/list/options = list(
        "Create Mutual Relationship",
        "Remove Relationship",
        "Back"
    )
    var/choice = tgui_input_list(user, "Choose a relationship action:", "Manage Relationships", options, null, 0, GLOB.always_state)
    if (isnull(choice) || choice == "Back") return
    switch(choice)
        if ("Create Mutual Relationship")
            return src.prompt_add_mutual_relationship(user)
        if ("Remove Relationship")
            return src.prompt_remove_personal_relationship(user)
    return TRUE

/// Creates a mutual relationship between the user and another character (if one doesn't already exist).
/datum/component/about_me/proc/prompt_add_mutual_relationship(mob/user)
    var/datum/aboutme_record/R = src.get_record()
    if (!R) return
    // Build options for valid target characters (excluding self and those with an existing relationship)
    var/list/char_options = list()
    for (var/target_key in GLOB.aboutme_records)
        if (target_key == src.character_key) continue
        if (src.has_relationship_with(target_key)) continue // Prevent duplicates
        var/datum/component/about_me/C = SSrpmanagement.get_aboutme_component_by_key(target_key)
        if (!C?.owner || !ismob(C.owner)) continue
        var/mob/living/carbon/human/M = C.owner
        var/display_name = M.true_real_name || M.real_name || target_key
        char_options[display_name] = target_key
    if (!length(char_options))
        to_chat(user, "<span class='warning'>No valid characters available to form a new relationship with.</span>")
        return src.prompt_change_relationship(user)
    // Pick target
    var/char_choice = tgui_input_list(user, "Choose a character:", "Character", char_options)
    if (!char_choice || !istext(char_choice)) return src.prompt_change_relationship(user)
    var/target_key = char_options[char_choice]
    // Pick type
    var/list/type_choices = list()
    for (var/t in RELATIONSHIP_TYPE_KEYS)
        if (t != "group") type_choices += t
    var/rtype = tgui_input_list(user, "Select relationship type:", "Relationship Type", type_choices)
    if (isnull(rtype)) return src.prompt_change_relationship(user)
    // Pick strength
    var/list/strength_options = list(
        "-100: Nemesis/Hatred" = -100,
        "-75: Enemy" = -75,
        "-50: Rival" = -50,
        "-25: Distrusted" = -25,
        "0: Neutral" = 0,
        "25: Acquaintance" = 25,
        "50: Neutral/Friendly" = 50,
        "75: Close/Bonded" = 75,
        "100: Deep Loyalty" = 100
    )
    var/strength = tgui_input_list(user, "Choose the loyalty/strength of this relationship (negative for enemies):", "Loyalty", strength_options)
    if (isnull(strength)) return src.prompt_change_relationship(user)
    // Find display label for summary
    var/strength_label = ""
    for (var/L in strength_options)
        if (strength_options[L] == strength)
            strength_label = L; break
    // Pick tag (one only, for simplicity)
    var/tag = tgui_input_list(user, "Select relationship tag.", "Tag", RELATIONSHIP_TAGS_ALLOWED)
    var/list/taglist = tag ? list(tag) : list()
    // Confirmation summary
    var/summary = "[user.name] wants to form a mutual relationship with you.\n"
    summary += "Type: [rtype]\n"
    summary += "Loyalty/Strength: [strength_label]\n"
    if (taglist.len)
        summary += "Tag: [jointext(taglist, ", ")]\n"
    // Find and confirm with target
    var/datum/component/about_me/TargetC = SSrpmanagement.get_aboutme_component_by_key(target_key)
    if (!TargetC?.owner || !ismob(TargetC.owner))
        to_chat(user, "<span class='warning'>Could not find target to send request.</span>")
        return src.prompt_change_relationship(user)
    var/mob/living/carbon/human/Target = TargetC.owner
    var/accepted = tgui_alert(
        Target,
        summary,
        "Mutual Relationship Request",
        list("Accept", "Decline")
    )
    if (accepted != "Accept") {
        to_chat(user, "<span class='alert'>[Target.name] declined the relationship.</span>")
        return src.prompt_change_relationship(user)
    }
    // Create shared relationship datum
    src.create_mutual_relationship(target_key, rtype, strength, taglist, user, Target)
    // Notify both
    to_chat(user, "<span class='notice'>Mutual relationship created with [Target.name].</span>")
    to_chat(Target, "<span class='notice'>You accepted a mutual relationship with [user.name].</span>")
    message_admins("[key_name(user)] and [key_name(Target)] created a mutual relationship (type: [rtype], loyalty: [strength]).")
    return src.prompt_change_relationship(user)

/// Actually creates and registers the shared relationship datum
/datum/component/about_me/proc/create_mutual_relationship(target_key, rtype, strength, taglist, mob/living/carbon/human/user, mob/living/carbon/human/Target)
    var/datum/relationships/rel = new
    rel.source_character = src.character_key
    rel.target_character = target_key
    rel.rtype = rtype
    rel.strength = strength
    rel.tags = taglist
    rel.name = "[user.name] ↔ [Target.name]"
    rel.mutual = TRUE
    // Register to both records
    var/datum/aboutme_record/R = src.get_record()
    var/datum/aboutme_record/TargetR = SSrpmanagement.get_aboutme_datum_for_key(target_key)
    if (R) R.relationship_keys += rel.id
    if (TargetR) TargetR.relationship_keys += rel.id
    SSrpmanagement.register_relationship(rel)

/// Returns a map of all personal (non-group) relationships you are part of, keyed by display name
/datum/component/about_me/proc/get_personal_relationships(mob/user)
    var/datum/aboutme_record/R = src.get_record()
    var/list/edit_map = list()
    if (!R || !length(R.relationship_keys)) return edit_map
    for (var/key in R.relationship_keys)
        var/datum/relationships/rel = SSrpmanagement.get_relationship_by_key(key)
        if (!rel || !rel.is_visible_to(user, src.character_key)) continue
        if (rel.group_target_id) continue // skip group relationships
        var/label = "[rel.name] (Character)"
        edit_map[label] = rel
    return edit_map


/datum/component/about_me/proc/prompt_remove_personal_relationship(mob/user)
    message_admins("Relationship Remove: [key_name(user)] opened the remove relationship menu.")

    // Build map: label => rel.id, and id => rel object
    var/list/edit_map = list()
    var/list/rel_by_id = list()
    var/datum/aboutme_record/R = src.get_record()
    if (!R || !length(R.relationship_keys))
        message_admins("Relationship Remove: No relationships available for [key_name(user)].")
        to_chat(user, "<span class='notice'>No personal relationships are visible to you.</span>")
        return src.prompt_change_relationship(user)
    for (var/key in R.relationship_keys)
        var/datum/relationships/rel = SSrpmanagement.get_relationship_by_key(key)
        if (!rel || !rel.is_visible_to(user, src.character_key)) continue
        if (rel.group_target_id) continue
        var/label = "[rel.name] (Character)"
        edit_map[label] = rel.id
        rel_by_id[rel.id] = rel

    if (!length(edit_map))
        message_admins("Relationship Remove: No personal relationships are visible to you (final map empty) for [key_name(user)].")
        to_chat(user, "<span class='notice'>No personal relationships are visible to you.</span>")
        return src.prompt_change_relationship(user)

    message_admins("Relationship Remove: [key_name(user)] can choose from: [jointext(edit_map, ", ")]")
    var/choice = tgui_input_list(user, "Choose a relationship to remove:", "Remove Personal Relationship", edit_map)
    if (isnull(choice) || !istext(choice) || !(choice in rel_by_id))
        message_admins("Relationship Remove: No valid selection made by [key_name(user)], returning to menu. Got: [choice]")
        return src.prompt_change_relationship(user)
    var/datum/relationships/rel = rel_by_id[choice]
    var/source_key = src.character_key
    var/target_key = rel.target_character
    message_admins("Relationship Remove: Attempting removal for rel.id=[rel.id] ([rel.name]) between [source_key] and [target_key]")

    // Call the core removal logic (removes from both records and GLOB)
    SSrpmanagement.clear_personal_relationship(source_key, target_key)

    // Notify both users if possible
    var/datum/component/about_me/OtherComp = SSrpmanagement.get_aboutme_component_by_key(target_key)
    if (OtherComp && ismob(OtherComp.parent))
        to_chat(OtherComp.parent, "<span class='alert'>[user.name] has removed the relationship with you.</span>")
    to_chat(user, "<span class='alert'>You have removed the relationship with [rel.name].</span>")
    message_admins("[key_name(user)] deleted mutual relationship [rel.id].")

    return src.prompt_change_relationship(user)



/// Checks if there is already a relationship (in either direction) between you and another key.
/datum/component/about_me/proc/has_relationship_with(other_key)
    var/datum/aboutme_record/R = src.get_record()
    if (!R) return FALSE
    for (var/rel_id in R.relationship_keys)
        var/datum/relationships/rel = SSrpmanagement.get_relationship_by_key(rel_id)
        if (!rel) continue
        if ((rel.source_character == src.character_key && rel.target_character == other_key) || (rel.source_character == other_key && rel.target_character == src.character_key))
            return TRUE
    return FALSE

