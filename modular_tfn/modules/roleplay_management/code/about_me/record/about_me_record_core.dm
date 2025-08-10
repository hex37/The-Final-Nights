// ==============================================================================
// ABOUT ME RECORD — CORE (about_me_record_core.dm)
// Persistent snapshot only. No mob refs except where explicitly documented.
// ==============================================================================

/datum/aboutme_record
	// Identity
	var/character_key

	// Editable profile bits
	var/edit_display_name
	var/edit_goals
	var/edit_personal_quote
	var/edit_gender
	var/edit_physical_desc

	// Associations (ID lists only)
	var/list/group_keys = list()
	var/list/relationship_keys = list()
	var/list/chronicle_keys = list()
	var/list/memory_keys = list()

	// Init flags
	var/has_initialized_personal_chronicle = FALSE
	var/has_initialized_groups_from_role = FALSE
	var/has_initialized_entry_memory = FALSE

	// Audit
	var/created_at = ""
	var/created_at_ts = 0
	var/updated_at = ""
	var/updated_at_ts = 0

/datum/aboutme_record/New(character_key)
	..()
	src.character_key = "[character_key]"
	if (!created_at_ts)
		created_at_ts = world.realtime
		created_at = time2text(created_at_ts, "MMM DD, YYYY hh:mm")
	updated_at_ts = created_at_ts
	updated_at = created_at
	SSroleplay_management.check_register_valid_character_key(src)


/datum/aboutme_record/proc/touch()
	updated_at_ts = world.realtime
	updated_at = time2text(updated_at_ts, "MMM DD, YYYY hh:mm")

/// Minimal UI payload shell (full builders live in record_ui_* files) This is more descriptive than group UI, for staff purposes.
	// NOTE: Owner is needed for live reads; do NOT store mob refs. Takes in a usuable owner mob, and builds live UI data.
/datum/aboutme_record/proc/GetFormattedUI(mob/living/carbon/human/owner)
	var/overview = get_ui_overview_data(owner)
	if (!islist(overview)) overview = list("general"=list(), "species"=list())

	return list(
		"overview" = overview,
		"groups" = get_ui_groups(owner),
		"relationships" = get_ui_relationships(owner),
		"chronicle" = get_ui_chronicles(owner),
		"memories" = get_ui_memories_by_tag(owner),
		"created_at" = created_at,
		"updated_at" = updated_at
	)

