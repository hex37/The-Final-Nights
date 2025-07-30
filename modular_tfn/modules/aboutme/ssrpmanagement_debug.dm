// ================================================================
// RP Management Subsystem Debug Tools (ssrpmanagement_debug.dm)
// ================================================================
// Admin tools for inspecting live RP metadata, including:
// - AboutMe records
// - Group status
// - Relationships, Memories, Chronicles
// ================================================================

/client/verb/ViewCharacterAboutMe()
    set name = "About Me View Character Record"
    set category = "IC"

    if (!GLOB.valid_character_keys.len)
        to_chat(src, "<span class='warning'>No character keys are currently registered.</span>")
        return

    var/list/options = list()
    for (var/key in GLOB.valid_character_keys)
        options += key

    var/key = tgui_input_list(src, list(
        "title" = "Select Character Key",
        "message" = "Which character would you like to inspect?",
        "options" = options
    ))

    if (!key || !(key in GLOB.valid_character_keys))
        to_chat(src, "<span class='warning'>That key is not valid or doesn't exist.</span>")
        return

    var/datum/component/about_me/C = SSrpmanagement.get_aboutme_component_by_key(key)
    if (!C)
        to_chat(src, "<span class='warning'>No active About Me component is registered for [key]. That character may not be in-round.</span>")
        return

    C.ui_interact(src)


/client/verb/DebugRPManagement()
    set name = "AboutMe Subsystem Overview"
    set category = "IC"

    var/list/summary = list()
    summary += "<b>=== RP Management Debug Dump ===</b><br>"

    // --- AboutMe Records ---
    summary += "<details><summary><b>AboutMe Records (via Components)</b> ([length(GLOB.aboutme_components)])</summary>"
    for (var/datum/component/about_me/C in GLOB.aboutme_components)
        var/key = C.character_key
        var/mob/living/carbon/human/H = C.owner
        if (!H) continue
        var/list/payload = C.get_full_payload(H)
        var/display_name = H.real_name || "Unknown Mob"
        var/display = json_encode(payload, TRUE)
        summary += "<details><summary><b>[key]</b> ([display_name])</summary><pre>[display]</pre></details>"
    summary += "</details><br>"

    // --- AboutMe Components ---
    summary += "<details><summary><b>AboutMe Components</b> ([length(GLOB.aboutme_components)])</summary>"
    for (var/datum/component/about_me/C in GLOB.aboutme_components)
        var/display = json_encode(C, TRUE)
        summary += "<details><summary><b>[C]</b> (character_key: [C.character_key])</summary><pre>[display]</pre></details>"
    summary += "</details><br>"

    // --- Valid Character Keys ---
    summary += "<details><summary><b>Valid Character Keys</b> ([length(GLOB.valid_character_keys)])</summary><pre>"
    for (var/key in GLOB.valid_character_keys)
        summary += "[key]\n"
    summary += "</pre></details><br>"

    // --- Chronicle Dump ---
    summary += "<details><summary><b>Chronicles</b> ([length(GLOB.chronicles)])</summary>"
    var/list/chronicle_groups = list()
    for (var/key in GLOB.chronicles)
        var/datum/chronicle/C = GLOB.chronicles[key]
        var/host = C.host_key || "Unknown"
        (chronicle_groups[host] ||= list()) += key

    for (var/host in chronicle_groups)
        var/list/keys = chronicle_groups[host]
        summary += "<details><summary><b>[host]</b> ([length(keys)])</summary>"
        for (var/key in keys)
            var/datum/chronicle/C = GLOB.chronicles[key]
            var/display = json_encode(C.GetFormattedUI(), TRUE)
            summary += "<details><summary><b>[key]</b></summary><pre>[display]</pre></details>"
        summary += "</details>"
    summary += "</details><br>"

    // --- Groups ---
    var/list/group_categories = list(
        GROUP_TYPE_CITY = list(), GROUP_TYPE_FACTION = list(), GROUP_TYPE_SECT = list(),
        GROUP_TYPE_CLAN = list(), GROUP_TYPE_TRIBE = list(), GROUP_TYPE_ORGANIZATION = list(),
        GROUP_TYPE_PARTY = list(), GROUP_TYPE_PLAYER = list(), "unknown" = list()
    )
    for (var/key in GLOB.groups)
        var/datum/group/G = GLOB.groups[key]
        var/type = G?.gtype || "unknown"
        (group_categories[type] ||= list()) += key

    for (var/category in group_categories)
        var/list/keys = group_categories[category]
        summary += "<details><summary><b>Groups - [capitalize(category)] ([length(keys)])</b></summary>"
        for (var/key in keys)
            var/datum/group/G = GLOB.groups[key]
            var/display = json_encode(G.GetFormattedUI(), TRUE)
            summary += "<details><summary><b>[key]</b></summary><pre>[display]</pre></details>"
        summary += "</details><br>"

    // --- Relationships ---
    summary += "<details><summary><b>Relationships</b> ([length(GLOB.relationships)])</summary>"
    var/list/rel_groups = list()
    for (var/key in GLOB.relationships)
        var/datum/relationships/R = GLOB.relationships[key]
        var/source = R?.source_character || "Unknown"
        (rel_groups[source] ||= list()) += key

    for (var/source in rel_groups)
        var/list/keys = rel_groups[source]
        summary += "<details><summary><b>[source]</b> ([length(keys)])</summary>"
        for (var/key in keys)
            var/datum/relationships/R = GLOB.relationships[key]
            var/display = json_encode(R.GetFormattedUI(), TRUE)
            summary += "<details><summary><b>[key]</b></summary><pre>[display]</pre></details>"
        summary += "</details>"
    summary += "</details><br>"

    // --- Memories ---
    summary += "<details><summary><b>Memories</b> ([length(GLOB.memories)])</summary>"
    var/list/memory_groups = list()
    for (var/key in GLOB.memories)
        var/datum/memory/M = GLOB.memories[key]
        var/owner = M?.owner_key || "Unknown"
        (memory_groups[owner] ||= list()) += key

    for (var/owner in memory_groups)
        var/list/keys = memory_groups[owner]
        summary += "<details><summary><b>[owner]</b> ([length(keys)])</summary>"
        for (var/key in keys)
            var/datum/memory/M = GLOB.memories[key]
            var/display = json_encode(M.GetFormattedUI(), TRUE)
            summary += "<details><summary><b>[key]</b></summary><pre>[display]</pre></details>"
        summary += "</details>"
    summary += "</details><br>"

    // --- Output ---
    src << browse("<html><body style='background-color:#1e1e1e; color:#dcdcdc; font-family:monospace'>" + summary.Join("") + "</body></html>", "window=rpmanagement_debug;size=1000x800")
