// ================================================================
// RP Management Subsystem - Core (ssroleplay_management_core.dm)
// ================================================================
// This file defines:
//   - Core subsystem declaration
//   - Global registries
//   - Subsystem verbs (debug, UI inspection)
//   - Shared validation and AboutMe access utilities
// ================================================================

// ---------------- GLOBAL REGISTRIES ----------------
GLOBAL_LIST_EMPTY(groups)
GLOBAL_LIST_EMPTY(relationships)
GLOBAL_LIST_EMPTY(chronicles)
GLOBAL_LIST_EMPTY(memories)
GLOBAL_LIST_EMPTY(valid_character_keys)
GLOBAL_LIST_EMPTY(aboutme_records)
GLOBAL_LIST_EMPTY(aboutme_components)

//List of group keys and their pre-made datums for ensuring that canon-groups exist.
GLOBAL_LIST_EMPTY(canonical_groups)
// ---------------- CANONICAL Initialization GROUP KEYS ----------------
var/global/list/canonical_groups = list(
	// Cities
	GROUP_KEY_CITY = /datum/group/city/SanFrancisco,
	// Factions
	GROUP_KEY_FACTION_UNKNOWING = /datum/group/faction/citizen,
	GROUP_KEY_FACTION_KINDRED   = /datum/group/faction/kindred,
	GROUP_KEY_FACTION_FERA      = /datum/group/faction/fera,
	GROUP_KEY_FACTION_HUNTERS   = /datum/group/faction/hunter,
	// Sects
	GROUP_KEY_SECT_CAMARILLA     = /datum/group/sect/camarilla,
	GROUP_KEY_SECT_ANARCHS       = /datum/group/sect/anarchs,
	GROUP_KEY_SECT_SABBAT        = /datum/group/sect/sabbat,
	GROUP_KEY_SECT_INDEPENDENT   = /datum/group/sect/independent,
	GROUP_KEY_SECT_PAINTEDCITY   = /datum/group/sect/paintedcity,
	GROUP_KEY_SECT_AMBERGLADE    = /datum/group/sect/amberglade,
	GROUP_KEY_SECT_POISONEDSHORE = /datum/group/sect/poisonedshore,
	// Clans
	GROUP_KEY_CLAN_VENTRUE      = /datum/group/clan/ventrue,
	GROUP_KEY_CLAN_BRUJAH       = /datum/group/clan/brujah,
	GROUP_KEY_CLAN_TOREADOR     = /datum/group/clan/toreador,
	GROUP_KEY_CLAN_MALKAVIAN    = /datum/group/clan/malkavian,
	GROUP_KEY_CLAN_NOSFERATU    = /datum/group/clan/nosferatu,
	GROUP_KEY_CLAN_GANGREL      = /datum/group/clan/gangrel,
	GROUP_KEY_CLAN_TREMERE      = /datum/group/clan/tremere,
	GROUP_KEY_CLAN_LASOMBRA     = /datum/group/clan/lasombra,
	GROUP_KEY_CLAN_TZIMISCE     = /datum/group/clan/tzimisce,
	GROUP_KEY_CLAN_MINISTRY     = /datum/group/clan/ministry,
	GROUP_KEY_CLAN_GIOVANNI     = /datum/group/clan/giovanni,
	GROUP_KEY_CLAN_SALUBRI      = /datum/group/clan/salubri,
	GROUP_KEY_CLAN_DAUGHTERS_OF_CACOPHONY = /datum/group/clan/daughters_of_cacophony,
	GROUP_KEY_CLAN_BAALI        = /datum/group/clan/baali,
	GROUP_KEY_CLAN_CAITIF       = /datum/group/clan/caitif,
	// Tribes
	GROUP_KEY_TRIBE_RONIN               = /datum/group/tribe/ronin,
	GROUP_KEY_TRIBE_BLACKFURIES         = /datum/group/tribe/blackfuries,
	GROUP_KEY_TRIBE_BLACKSPIRALDANCERS  = /datum/group/tribe/blackspiraldancers,
	GROUP_KEY_TRIBE_BONEGNAWERS         = /datum/group/tribe/bonegnawers,
	GROUP_KEY_TRIBE_CHILDRENOFGAIA      = /datum/group/tribe/childrenofgaia,
	GROUP_KEY_TRIBE_CORAX               = /datum/group/tribe/corax,
	GROUP_KEY_TRIBE_GALESTALKERS        = /datum/group/tribe/galestalkers,
	GROUP_KEY_TRIBE_GETOFFENRIS         = /datum/group/tribe/getoffenris,
	GROUP_KEY_TRIBE_GHOSTCOUNCIL        = /datum/group/tribe/ghostcouncil,
	GROUP_KEY_TRIBE_GLASSWALKERS        = /datum/group/tribe/glasswalkers,
	GROUP_KEY_TRIBE_HARTWARDENS         = /datum/group/tribe/hartwardens,
	GROUP_KEY_TRIBE_REDTALONS           = /datum/group/tribe/redtalons,
	GROUP_KEY_TRIBE_SHADOWLORDS         = /datum/group/tribe/shadowlords,
	GROUP_KEY_TRIBE_SILENTSTRIDERS      = /datum/group/tribe/silentstriders,
	GROUP_KEY_TRIBE_SILVERFANGS         = /datum/group/tribe/silverfangs,
	GROUP_KEY_TRIBE_STARGAZERS          = /datum/group/tribe/stargazers,
	// Organizations (complete list)
	GROUP_KEY_ORG_GOVERNMENT         = /datum/group/organization/government,
	GROUP_KEY_ORG_POLICE             = /datum/group/organization/policedepartment,
	GROUP_KEY_ORG_HOSPITAL           = /datum/group/organization/hospital,
	GROUP_KEY_ORG_MILITARY           = /datum/group/organization/military,
	GROUP_KEY_ORG_BIKERGANG          = /datum/group/organization/bikergang,
	GROUP_KEY_ORG_CORP               = /datum/group/organization/corporation,
	GROUP_KEY_ORG_WAREHOUSE          = /datum/group/organization/warehouse,
	GROUP_KEY_ORG_CHURCH             = /datum/group/organization/church,
	GROUP_KEY_ORG_CIVICSERVICES      = /datum/group/organization/civicservices,
	GROUP_KEY_ORG_NATIONALSECURITY   = /datum/group/organization/nationalsecurity,
	GROUP_KEY_ORG_TZIMISCE           = /datum/group/organization/tzimisce,
	GROUP_KEY_ORG_TRIAD              = /datum/group/organization/triad
)
// ---------------- SUBSYSTEM DEF ----------------
SUBSYSTEM_DEF(roleplay_management)
	name = "RP Management"
	init_order = INIT_ORDER_DEFAULT
	wait = 10

/datum/controller/subsystem/roleplay_management

/datum/controller/subsystem/roleplay_management/Initialize()
	..()
	SSroleplay_management.InitAllGroups()

/datum/controller/subsystem/roleplay_management/fire()
	..()
	for (var/group_id in GLOB.groups)
		var/datum/group/G = GLOB.groups[group_id]
		if (!G?.active_votes || !length(G.active_votes)) continue
		G.resolve_votes()

// ---------------- LOOKUPS & UTILITIES ----------------
/datum/controller/subsystem/roleplay_management/proc/get_aboutme_component_by_key(character_key)
	for (var/datum/component/about_me/C in GLOB.aboutme_components)
		if (C.character_key == character_key)
			return C
	return null

/datum/controller/subsystem/roleplay_management/proc/get_aboutme_record(character_key)
	if (!character_key || !is_valid_character_key(character_key))
		return null

	if (!(character_key in GLOB.aboutme_records))
		var/datum/aboutme_record/R = new()
		R.character_key = character_key
		GLOB.aboutme_records[character_key] = R
		register_valid_character_key(character_key)

	return GLOB.aboutme_records[character_key]

/datum/controller/subsystem/roleplay_management/proc/ensure_aboutme_datum_for_key(character_key, mob/living/carbon/human/owner)
	if (!character_key) return null
	return get_aboutme_record(character_key)

// ---------------- VALIDATION ----------------
/datum/controller/subsystem/roleplay_management/proc/is_valid_key(key)
	return istext(key) && length(key) > 3

/datum/controller/subsystem/roleplay_management/proc/is_valid_character_key(character_key)
	return istext(character_key) && (character_key in GLOB.valid_character_keys)

/// Adds only if not already known
/datum/controller/subsystem/roleplay_management/proc/register_valid_character_key(character_key)
	if (istext(character_key) && !(character_key in GLOB.valid_character_keys))
		GLOB.valid_character_keys += character_key

/datum/controller/subsystem/roleplay_management/proc/get_relationship_by_id(rel_id)
	// Returns the relationship object with the given id, or null if not found
	if (!rel_id || !(rel_id in GLOB.relationships))
		return null
	return GLOB.relationships[rel_id]
