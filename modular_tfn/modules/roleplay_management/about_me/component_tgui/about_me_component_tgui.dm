// ==============================================================================
// About Me TGUI Handler (aboutme_tgui.dm)
// ------------------------------------------------------------------------------
// Bridge between backend About Me data and player-facing TGUI interface.
// Handles UI lifecycle, data flow, and frontend action routing.
// System Responsibilities:
//   - Open/update About Me TGUI via ui_interact()
//   - Provide live About Me data via ui_data()
//   - Route button actions from About Me TGUI to backend procs
//   - Ensure About Me record/component initialization and sync
//   - All logic and data edits live in aboutme_record and the SSRP subsystem
// Editing/Modifying:
//   - New button actions: route from ui_act() to about_me_tgui_player_<section>.dm
//   - See: about_me_tgui_player_(overview/group/relationship/chronicle/memory).dm
// ==============================================================================

/// Returns the UI state object for TGUI. Always uses the global always_state.
/datum/component/about_me/ui_state(user)
	return GLOB.always_state

/// Returns the full About Me UI payload for TGUI display. All data comes from component.
/datum/component/about_me/ui_data()
	return get_full_payload()

// ==============================================================================
// UI Open/Initialization
// ------------------------------------------------------------------------------
// Handles About Me record/component key generation, registration, and About Me window opening.
// Called by TGUI or action button to begin a session.
// ==============================================================================

/// Called when a player opens the About Me UI. Initializes character_id if not already set,
/// registers the character if needed and ensures data is ready, then opens or updates the TGUI panel.
/datum/component/about_me/ui_interact(mob/user, datum/tgui/ui)
	if (!character_id && ismob(parent))
		var/mob/living/carbon/human/H = parent
		if (H?.true_real_name)
			UpdateCharacterId()
	if (owner?.client && character_id)
		SSroleplay_management.check_register_valid_character_id(character_id)
		SSroleplay_management.check_initialize_aboutme_for(character_id, owner, src)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "AboutmeInt")
		ui.open()

// ==============================================================================
// UI Action Routing (Button Clicks/Frontend Events)
// ------------------------------------------------------------------------------
// All UI button actions are routed here from the TGUI panel. Each button name/action string
// should route to a dedicated prompt_ proc or be sent to about_me_tgui_player_<section>.dm
// ==============================================================================

/// Handles button click actions from the About Me TGUI.
/// Routes action to appropriate backend proc or prompt handlers.
/datum/component/about_me/ui_act(action, params, about_me_ui, about_me_ui_state)
	. = ..()
	var/mob/user_mob = parent
	switch(action)
		if ("edit_overview")
			return prompt_edit_overview(user_mob)
		if ("manage_groups")
			return prompt_manage_groups(user_mob)
		if ("change_relationship")
			return prompt_change_relationship(user_mob)
		if ("interact_chronicle")
			return prompt_interact_chronicle(user_mob)
		if ("manage_memories")
			return prompt_manage_memories(user_mob)
	// Add more button actions as needed

