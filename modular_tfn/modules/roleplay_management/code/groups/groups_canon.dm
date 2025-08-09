// ==============================================================================
// groups_canon.dm — Canonical group registry and bootstrap
// ==============================================================================

#define CANON_GROUPS_MAP list( \
	/* Cities */ \
	GROUP_KEY_CITY = /datum/group/city/SanFrancisco, \
	/* Factions */ \
	GROUP_KEY_FACTION_UNKNOWING = /datum/group/faction/citizen, \
	GROUP_KEY_FACTION_KINDRED   = /datum/group/faction/kindred, \
	GROUP_KEY_FACTION_FERA      = /datum/group/faction/fera, \
	GROUP_KEY_FACTION_HUNTERS   = /datum/group/faction/hunter, \
	GROUP_KEY_FACTION_GHOUL     = /datum/group/faction/ghoul, \
	GROUP_KEY_FACTION_KUEIJIN   = /datum/group/faction/kueijin, \
	/* Sects */ \
	GROUP_KEY_SECT_CAMARILLA    = /datum/group/sect/camarilla, \
	GROUP_KEY_SECT_ANARCHS      = /datum/group/sect/anarchs, \
	GROUP_KEY_SECT_SABBAT       = /datum/group/sect/sabbat, \
	GROUP_KEY_SECT_INDEPENDENT  = /datum/group/sect/independent, \
	GROUP_KEY_SECT_PAINTEDCITY  = /datum/group/sect/paintedcity, \
	GROUP_KEY_SECT_AMBERGLADE   = /datum/group/sect/amberglade, \
	GROUP_KEY_SECT_POISONEDSHORE = /datum/group/sect/poisonedshore, \
	/* Clans */ \
	GROUP_KEY_CLAN_VENTRUE      = /datum/group/clan/ventrue, \
	GROUP_KEY_CLAN_BRUJAH       = /datum/group/clan/brujah, \
	GROUP_KEY_CLAN_TRUE_BRUJAH  = /datum/group/clan/true_brujah, \
	GROUP_KEY_CLAN_BANU_HAQIM   = /datum/group/clan/banu_haqim, \
	GROUP_KEY_CLAN_TOREADOR     = /datum/group/clan/toreador, \
	GROUP_KEY_CLAN_MALKAVIAN    = /datum/group/clan/malkavian, \
	GROUP_KEY_CLAN_NOSFERATU    = /datum/group/clan/nosferatu, \
	GROUP_KEY_CLAN_GANGREL      = /datum/group/clan/gangrel, \
	GROUP_KEY_CLAN_TREMERE      = /datum/group/clan/tremere, \
	GROUP_KEY_CLAN_LASOMBRA     = /datum/group/clan/lasombra, \
	GROUP_KEY_CLAN_TZIMISCE     = /datum/group/clan/tzimisce, \
	GROUP_KEY_CLAN_MINISTRY     = /datum/group/clan/ministry, \
	GROUP_KEY_CLAN_GIOVANNI     = /datum/group/clan/giovanni, \
	GROUP_KEY_CLAN_SALUBRI      = /datum/group/clan/salubri, \
	GROUP_KEY_CLAN_DAUGHTERS_OF_CACOPHONY = /datum/group/clan/daughters_of_cacophony, \
	GROUP_KEY_CLAN_BAALI        = /datum/group/clan/baali, \
	GROUP_KEY_CLAN_CAITIF       = /datum/group/clan/caitif, \
	/* Tribes */ \
	GROUP_KEY_TRIBE_RONIN              = /datum/group/tribe/ronin, \
	GROUP_KEY_TRIBE_BLACKFURIES        = /datum/group/tribe/blackfuries, \
	GROUP_KEY_TRIBE_BLACKSPIRALDANCERS = /datum/group/tribe/blackspiraldancers, \
	GROUP_KEY_TRIBE_BONEGNAWERS        = /datum/group/tribe/bonegnawers, \
	GROUP_KEY_TRIBE_CHILDRENOFGAIA     = /datum/group/tribe/childrenofgaia, \
	GROUP_KEY_TRIBE_CORAX              = /datum/group/tribe/corax, \
	GROUP_KEY_TRIBE_GALESTALKERS       = /datum/group/tribe/galestalkers, \
	GROUP_KEY_TRIBE_GETOFFENRIS        = /datum/group/tribe/getoffenris, \
	GROUP_KEY_TRIBE_GHOSTCOUNCIL       = /datum/group/tribe/ghostcouncil, \
	GROUP_KEY_TRIBE_GLASSWALKERS       = /datum/group/tribe/glasswalkers, \
	GROUP_KEY_TRIBE_HARTWARDENS        = /datum/group/tribe/hartwardens, \
	GROUP_KEY_TRIBE_REDTALONS          = /datum/group/tribe/redtalons, \
	GROUP_KEY_TRIBE_SHADOWLORDS        = /datum/group/tribe/shadowlords, \
	GROUP_KEY_TRIBE_SILENTSTRIDERS     = /datum/group/tribe/silentstriders, \
	GROUP_KEY_TRIBE_SILVERFANGS        = /datum/group/tribe/silverfangs, \
	GROUP_KEY_TRIBE_STARGAZERS         = /datum/group/tribe/stargazers, \
	/* Core Orgs */ \
	GROUP_KEY_ORG_GOVERNMENT        = /datum/group/organization/government, \
	GROUP_KEY_ORG_POLICE            = /datum/group/organization/policedepartment, \
	GROUP_KEY_ORG_HOSPITAL          = /datum/group/organization/hospital, \
	GROUP_KEY_ORG_MILITARY          = /datum/group/organization/military, \
	GROUP_KEY_ORG_WAREHOUSE         = /datum/group/organization/warehouse, \
	GROUP_KEY_ORG_CHURCH            = /datum/group/organization/church, \
	GROUP_KEY_ORG_CIVICSERVICES     = /datum/group/organization/civicservices, \
	GROUP_KEY_ORG_NATIONALSECURITY  = /datum/group/organization/nationalsecurity, \
	/* Independent Orgs */ \
	GROUP_KEY_ORG_TZIMISCE          = /datum/group/organization/tzimisce, \
	GROUP_KEY_ORG_TRIAD             = /datum/group/organization/triad, \
	/* Fronts */ \
	GROUP_KEY_ORG_MILLENNIUMTOWER   = /datum/group/organization/millenniumtower, \
	GROUP_KEY_ORG_ANARCHYROSE       = /datum/group/organization/anarchyrose, \
	GROUP_KEY_ORG_SABBATCULT        = /datum/group/organization/sabbatcult, \
	GROUP_KEY_ORG_TREMERE_COVER     = /datum/group/organization/historicsociety, \
	GROUP_KEY_ORG_GIOVANNI_BANK     = /datum/group/organization/giovannibank, \
	GROUP_KEY_ORG_ENDRON            = /datum/group/organization/endron, \
	GROUP_KEY_ORG_AMBERGLADE        = /datum/group/organization/amberglade, \
	GROUP_KEY_ORG_PAINTEDCITYMALL   = /datum/group/organization/paintedcitymall \
)



/datum/controller/subsystem/roleplay_management/proc/rpm_get_or_make_canonical_group(group_key, group_typepath)
	if (!GLOB.canonical_groups)
		GLOB.canonical_groups = list()
	if (GLOB.canonical_groups[group_key])
		return GLOB.canonical_groups[group_key]

	var/datum/group/group_datum = new group_typepath()
	if (!group_datum.id)
		group_datum.id = group_key

	GLOB.canonical_groups[group_key] = group_datum

	if (!GLOB.groups)
		GLOB.groups = list()
	if (!GLOB.groups[group_key])
		GLOB.groups[group_key] = group_datum

	return group_datum

/datum/controller/subsystem/roleplay_management/proc/rpm_register_canonical_groups()
	if (!GLOB.canonical_groups) GLOB.canonical_groups = list()
	if (!GLOB.groups) GLOB.groups = list()
	if (!GLOB.canonical_type_to_key) GLOB.canonical_type_to_key = list()

	var/list/canonical_map = CANON_GROUPS_MAP
	for (var/group_key in canonical_map)
		var/group_typepath = canonical_map[group_key]
		if (!ispath(group_typepath))
			world.log << "Bad typepath for canonical group: [group_key]"
			continue

		rpm_get_or_make_canonical_group(group_key, group_typepath)

		// Build reverse map for quick lookup
		GLOB.canonical_type_to_key[group_typepath] = group_key

/datum/controller/subsystem/roleplay_management/proc/rpm_canonical_key_for_typepath(typepath)
	return GLOB.canonical_type_to_key ? GLOB.canonical_type_to_key[typepath] : null

#undef CANON_GROUPS_MAP
