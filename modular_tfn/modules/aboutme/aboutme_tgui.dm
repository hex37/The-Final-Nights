// ==============================================================================
// About Me TGUI Handler (aboutme_tgui.dm)
// ------------------------------------------------------------------------------
// Bridge between BYOND backend and About Me TGUI (AboutmeInt.jsx)
// Handles UI state, data payloads, and action routing
//
// System Responsibilities:
//   - Opens the TGUI window for each mob via `ui_interact()`
//   - Sends the current payload from the component to the TGUI frontend
//   - Responds to ui_act() button clicks and routes actions appropriately
//
// Data & Logic Flow:
//   [mob] -> has component (/datum/component/about_me)
//         -> component fetches data from record in SSRPmanagement (via character_key)
//         -> sends data to TGUI (AboutmeInt.jsx) for rendering
//
// Editing/Modifying:
//   - All button actions should be routed via `ui_act()` below
//   - Actual behavior lives in aboutme_tgui_player_input.dm
// ==============================================================================

// ==============================================================================
// UI Lifecycle Methods (Required for TGUI)
// ==============================================================================
/datum/component/about_me/ui_state(mob/user)
    return GLOB.always_state

/datum/component/about_me/ui_data(mob/user)
    try
        return get_full_payload()
    catch (var/exception/e)
        return list("error" = "ui_data exception: [e]")

/datum/component/about_me/ui_static_data(mob/user)
    return list()

// ==============================================================================
// On UI Open: Initializes the record, groups, and chronicle for the player
// ==============================================================================
/datum/component/about_me/ui_interact(mob/user, datum/tgui/ui)
	if (!character_key && ismob(parent))
		var/mob/living/carbon/human/H = parent
		if (H?.true_real_name)
			var/raw_key = lowertext(replacetext(H.true_real_name, " ", "_"))
			character_key = "[raw_key]_character_key"
			ckey = ckey(H.client?.key)
	if (owner?.client && character_key)
		SSrpmanagement.register_valid_character_key(character_key)
		SSrpmanagement.initialize_aboutme_for(character_key, owner, src)
	// Open or update the About Me interface
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "AboutmeInt")
		ui.open()

/datum/component/about_me/ui_close(mob/user)
    . = ..()

// ==============================================================================
// UI Button Entry Point: Player "About Me" action icon
// ==============================================================================
/datum/action/about_me
    name = "About Me"
    desc = "Press to view your About Me Menu."
    button_icon_state = "masquerade"
    check_flags = NONE
    var/datum/component/about_me/about_me_component

/datum/action/about_me/New()
    . = ..()

/datum/action/about_me/Trigger(trigger_flags)
    about_me_component = owner.GetComponent(/datum/component/about_me)
    if (about_me_component)
        about_me_component.ui_interact(owner)


// ==============================================================================
// UI Button Routing: Handles frontend <Button> click actions from AboutmeInt.jsx
// Any actions not handled here can be routed out to aboutme_tgui_player_input.dm
// ==============================================================================
//BUTTONS! This is where the UI goes to aboutme_tgui_player_input.dm
/datum/component/about_me/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.) return
	var/mob/user = ui.user
	switch(action)
		if ("edit_overview")
			return src.prompt_edit_overview(user)
		if ("manage_groups")
			return src.prompt_manage_groups(user)
		if ("change_relationship")
			return src.prompt_change_relationship(user)
		if ("interact_chronicle")
			return src.prompt_interact_chronicle(user)
		if ("manage_memories")
			return src.prompt_manage_memories(user)

