//These are Defines for RP Management, About Me, and supporting datums.
// About Me Component, and Record, as well as Groups, Chronciles, Relationships, and Memories.

// GROUP TYPE DEFINES
#define GROUP_TYPE_CITY             "city"
#define GROUP_TYPE_FACTION          "faction"
#define GROUP_TYPE_SECT             "sect"
#define GROUP_TYPE_CLAN             "clan"
#define GROUP_TYPE_TRIBE            "tribe"
#define GROUP_TYPE_ORGANIZATION     "organization"
#define GROUP_TYPE_PARTY            "party"
#define GROUP_TYPE_PLAYER           "player_created"

// =========================
// GROUP TAGS (used in type filtering)
// =========================
#define GROUP_TAG_CITY              "group_tag_city"
#define GROUP_TAG_FACTION           "group_tag_faction"
#define GROUP_TAG_SECT              "group_tag_sect"
#define GROUP_TAG_CLAN              "group_tag_clan"
#define GROUP_TAG_TRIBE             "group_tag_tribe"
#define GROUP_TAG_ORG               "group_tag_org"
#define GROUP_TAG_PARTY             "group_tag_party"

// =========================
// RELATIONSHIP TYPES
// =========================
#define RELATIONSHIP_ALLY           "ally"
#define RELATIONSHIP_ENEMY          "enemy"
#define RELATIONSHIP_RIVAL          "rival"
#define RELATIONSHIP_FRIEND         "friend"
#define RELATIONSHIP_LOVER          "lover"
#define RELATIONSHIP_CONTACT        "contact"
#define RELATIONSHIP_FAMILY         "family"
#define RELATIONSHIP_SUSPECT        "suspect"
#define RELATIONSHIP_UNKNOWN        "unknown"
#define RELATIONSHIP_GROUP          "group"

// =========================
// RELATIONSHIP UI Type List
// =========================
#define RELATIONSHIP_TYPE_KEYS list( \
	RELATIONSHIP_ALLY, \
	RELATIONSHIP_ENEMY, \
	RELATIONSHIP_RIVAL, \
	RELATIONSHIP_FRIEND, \
	RELATIONSHIP_LOVER, \
	RELATIONSHIP_CONTACT, \
	RELATIONSHIP_FAMILY, \
	RELATIONSHIP_SUSPECT, \
	RELATIONSHIP_UNKNOWN, \
	RELATIONSHIP_GROUP \
)


#define RELATIONSHIP_TAGS_ALLOWED list( \
	"trusted", "romantic", "bloodbond", "business", \
	"secret", "public", "clan", "rivalry", "political", \
	"mentor", "target", "ally", "danger" \
)



// =========================
// MEMORY TAGS
// =========================
#define MEMORY_TAG_BACKGROUND       "background"
#define MEMORY_TAG_CURRENT          "current"
#define MEMORY_TAG_RECENT           "recent"
#define MEMORY_TAG_GOAL             "goal"
#define MEMORY_TAG_SECRET           "secret"
#define MEMORY_TAG_REPUTATION       "reputation"
#define MEMORY_TAG_RELATIONSHIP     "relationship"
#define MEMORY_TAG_CHARACTER        "character_memories"
#define MEMORY_TAG_ALL              "memories_all"

// =========================
// ACCESS ROLES
// =========================
#define ACCESS_ROLE_LEADER          "leader"
#define ACCESS_ROLE_OFFICER         "officer"
#define ACCESS_ROLE_MEMBER          "member"
#define ACCESS_ROLE_NONE            "none"

// =========================
// FILE PATH HELPERS
// =========================
#define SAVEFILE_ROOT_PATH              "data/player_saves"
#define SAVEFILE_ABOUTME_PATH(ckey, character_key) "[SAVEFILE_ROOT_PATH]/[ckey]/aboutme/[character_key].sav"

// =========================
// TGUI
// =========================
#define TGUI_ABOUTME_ID             "AboutmeInt"

// =========================
// SUBSYSTEM
// =========================
#define SUBSYSTEM_ABOUTME_TAG       "aboutme_rp"

// =========================
// GROUP KEYS (PREMADE)
// =========================
// =========================
// GROUP KEY HELPERS
// =========================
#define GROUP_KEY_SECT(SECT) "sect_[lowertext(replacetext(SECT, " ", "_"))]"
#define GROUP_KEY_CLAN(CLAN) "clan_[lowertext(replacetext(CLAN, " ", "_"))]"
#define GROUP_KEY_TRIBE(TRIBE) "tribe_[lowertext(replacetext(TRIBE, " ", "_"))]"


// City
#define GROUP_KEY_CITY "city_sanfrancisco"

// Factions
#define GROUP_KEY_FACTION_UNKNOWING "faction_citizen"
#define GROUP_KEY_FACTION_KINDRED   "faction_kindred"
#define GROUP_KEY_FACTION_FERA      "faction_fera"
#define GROUP_KEY_FACTION_HUNTERS   "faction_hunters"

// Sects
#define GROUP_KEY_SECT_INDEPENDENT  "sect_independent"
#define GROUP_KEY_SECT_CAMARILLA    "sect_camarilla"
#define GROUP_KEY_SECT_ANARCHS      "sect_anarchs"
#define GROUP_KEY_SECT_SABBAT       "sect_sabbat"
#define GROUP_KEY_SECT_PAINTEDCITY  "sect_paintedcity"
#define GROUP_KEY_SECT_AMBERGLADE   "sect_amberglade"
#define GROUP_KEY_SECT_POISONEDSHORE "sect_poisonedshore"

// Clans
#define GROUP_KEY_CLAN_CAITIF       "clan_caitif"
#define GROUP_KEY_CLAN_VENTRUE      "clan_ventrue"
#define GROUP_KEY_CLAN_BRUJAH       "clan_brujah"
#define GROUP_KEY_CLAN_TOREADOR     "clan_toreador"
#define GROUP_KEY_CLAN_MALKAVIAN    "clan_malkavian"
#define GROUP_KEY_CLAN_NOSFERATU    "clan_nosferatu"
#define GROUP_KEY_CLAN_GANGREL      "clan_gangrel"
#define GROUP_KEY_CLAN_TREMERE      "clan_tremere"
#define GROUP_KEY_CLAN_LASOMBRA     "clan_lasombra"
#define GROUP_KEY_CLAN_TZIMISCE     "clan_tzimisce"
#define GROUP_KEY_CLAN_MINISTRY     "clan_ministry"
#define GROUP_KEY_CLAN_GIOVANNI     "clan_giovanni"
#define GROUP_KEY_CLAN_SALUBRI      "clan_salubri"
#define GROUP_KEY_CLAN_DAUGHTERS_OF_CACOPHONY "clan_daughters_of_cacophony"
#define GROUP_KEY_CLAN_BAALI        "clan_baali"

// Tribes
#define GROUP_KEY_TRIBE_RONIN               "tribe_ronin"
#define GROUP_KEY_TRIBE_BLACKFURIES         "tribe_blackfuries"
#define GROUP_KEY_TRIBE_BLACKSPIRALDANCERS  "tribe_blackspiraldancers"
#define GROUP_KEY_TRIBE_BONEGNAWERS         "tribe_bonegnawers"
#define GROUP_KEY_TRIBE_CHILDRENOFGAIA      "tribe_childrenofgaia"
#define GROUP_KEY_TRIBE_CORAX               "tribe_corax"
#define GROUP_KEY_TRIBE_GALESTALKERS        "tribe_galestalkers"
#define GROUP_KEY_TRIBE_GETOFFENRIS         "tribe_getoffenris"
#define GROUP_KEY_TRIBE_GHOSTCOUNCIL        "tribe_ghostcouncil"
#define GROUP_KEY_TRIBE_GLASSWALKERS        "tribe_glasswalkers"
#define GROUP_KEY_TRIBE_HARTWARDENS         "tribe_hartwardens"
#define GROUP_KEY_TRIBE_REDTALONS           "tribe_redtalons"
#define GROUP_KEY_TRIBE_SHADOWLORDS         "tribe_shadowlords"
#define GROUP_KEY_TRIBE_SILENTSTRIDERS      "tribe_silentstriders"
#define GROUP_KEY_TRIBE_SILVERFANGS         "tribe_silverfangs"
#define GROUP_KEY_TRIBE_STARGAZERS          "tribe_stargazers"

// Organizations
#define GROUP_KEY_ORG_GOVERNMENT         "org_government"
#define GROUP_KEY_ORG_POLICE             "org_police"
#define GROUP_KEY_ORG_HOSPITAL           "org_hospital"
#define GROUP_KEY_ORG_MILITARY           "org_military"
#define GROUP_KEY_ORG_BIKERGANG          "org_bikergang"
#define GROUP_KEY_ORG_CORP               "org_corporation"
#define GROUP_KEY_ORG_WAREHOUSE          "org_warehouse"
#define GROUP_KEY_ORG_CHURCH             "org_church"
#define GROUP_KEY_ORG_CIVICSERVICES      "org_civicservices"
#define GROUP_KEY_ORG_NATIONALSECURITY   "org_nationalsecurity"
#define GROUP_KEY_ORG_TZIMISCE           "org_tzimisce"
#define GROUP_KEY_ORG_TRIAD              "org_triad"
