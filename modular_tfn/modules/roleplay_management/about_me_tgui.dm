// ==============================================================================
// About Me TGUI Handler (aboutme_tgui.dm)
// ------------------------------------------------------------------------------
// A bit of overhead here, tgui is complicated, and this file is very vital.
// Bridge between backend and Player interactions with the About Me TGUI (AboutmeInt.jsx)
// Handles UI state, data payloads, and action routing using tgui prompts, and the roleplay_management subsystem procs.
//
// System Responsibilities:
//   - Opens the TGUI window for each mob via `ui_interact()`
//   - Sends the current payload from the about me component key, and gets the record information payload to the TGUI frontend.
//   - Responds to ui_act() button clicks and routes actions appropriately.
//   - Updates live to changes made anywhere in the system.
//
// Data & Logic Flow:
//   [mob] -> has component (/datum/component/about_me)
//         -> component fetches data from record in SSRPmanagement (via character_key)
//         -> sends "permission/view" data to TGUI (AboutmeInt.jsx) for rendering and premade interactions.
//
// Editing/Modifying:
//   - All NEW buttons should be caught in `ui_act()` then routed to an appropriate about_me_tgui_player_(newbutton).dm file.
//   - Modifying buttons that already exist? See:
//   - about_me_tgui_player_(overview/group/relationship/chronicle/memory).dm
// ==============================================================================

// UI Lifecycle Methods (Required for TGUI)
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
// On UI Open: Initializes the record. Planned to load up saved data, and prepare to save.
// ==============================================================================
/datum/component/about_me/ui_interact(mob/user, datum/tgui/ui)
	if (!character_key && ismob(parent))
		var/mob/living/carbon/human/H = parent
		if (H?.true_real_name)
			var/raw_key = lowertext(replacetext(H.true_real_name, " ", "_"))
			character_key = "[raw_key]_character_key"
			ckey = ckey(H.client?.key)
	if (owner?.client && character_key)
		SSroleplay_management.check_register_valid_character_key(character_key)
		SSroleplay_management.check_initialize_aboutme_for(character_key, owner, src)
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

