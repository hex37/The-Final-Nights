// ================================================================
// RP Management Subsystem - Groups (ssroleplay_management_groups.dm)
// ================================================================
// Handles:
//   - Canonical group registration
//   - Initial group assignment based on species/role
//   - Runtime group lookup and modification
// ================================================================
//Species Factions, and Base clan membership is already handled before here.
/datum/controller/subsystem/roleplay_management/var/list/ROLE_GROUP_MAPPINGS = list(
	// -------------------
	// Camarilla (Sect + Millennium Tower)
	// -------------------
	"prince" = list(
		list("sect" = GROUP_KEY_SECT_CAMARILLA, "is_leader" = TRUE),
		list("organization" = GROUP_KEY_ORG_MILLENNIUMTOWER, "is_leader" = TRUE)
	),
	"seneschal" = list(
		list("sect" = GROUP_KEY_SECT_CAMARILLA, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_MILLENNIUMTOWER, "is_officer" = TRUE)
	),
	"harpy" = list(
		list("sect" = GROUP_KEY_SECT_CAMARILLA, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_MILLENNIUMTOWER, "is_officer" = TRUE)
	),
	"sheriff" = list(
		list("sect" = GROUP_KEY_SECT_CAMARILLA, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_MILLENNIUMTOWER, "is_officer" = TRUE)
	),
	"hound" = list(
		list("sect" = GROUP_KEY_SECT_CAMARILLA),
		list("organization" = GROUP_KEY_ORG_MILLENNIUMTOWER)
	),

	// ---- PRIMOGEN ----
	// These get only sect + clan unless otherwise specified.

	"primogen banu haqim" = list(
		list("clan" = GROUP_KEY_CLAN_BANU_HAQIM, "is_leader" = TRUE),
		list("sect" = GROUP_KEY_SECT_CAMARILLA, "is_officer" = TRUE)
		// NEVER Tower
	),
	"primogen lasombra" = list(
		list("clan" = GROUP_KEY_CLAN_LASOMBRA, "is_leader" = TRUE),
		list("sect" = GROUP_KEY_SECT_CAMARILLA, "is_officer" = TRUE)
		// NEVER Tower
	),
	"primogen malkavian" = list(
		list("clan" = GROUP_KEY_CLAN_MALKAVIAN, "is_leader" = TRUE),
		list("sect" = GROUP_KEY_SECT_CAMARILLA, "is_officer" = TRUE)
		// NEVER Tower
	),
	"primogen nosferatu" = list(
		list("clan" = GROUP_KEY_CLAN_NOSFERATU, "is_leader" = TRUE),
		list("sect" = GROUP_KEY_SECT_CAMARILLA, "is_officer" = TRUE)
		// NEVER Tower
	),
	"primogen toreador" = list(
		list("clan" = GROUP_KEY_CLAN_TOREADOR, "is_leader" = TRUE),
		list("sect" = GROUP_KEY_SECT_CAMARILLA, "is_officer" = TRUE)
		// NEVER Tower
	),
	// The only one with implied direct access.
	"primogen ventrue" = list(
		list("clan" = GROUP_KEY_CLAN_VENTRUE, "is_leader" = TRUE),
		list("sect" = GROUP_KEY_SECT_CAMARILLA, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_MILLENNIUMTOWER, "is_officer" = TRUE)
	),

	// -------------------
	// Anarchs (Sect + Anarchy Rose Bar)
	// -------------------
	"baron" = list(
		list("sect" = GROUP_KEY_SECT_ANARCHS, "is_leader" = TRUE),
		list("organization" = GROUP_KEY_ORG_ANARCHYROSE, "is_leader" = TRUE)
	),
	"emissary" = list(
		list("sect" = GROUP_KEY_SECT_ANARCHS, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_ANARCHYROSE, "is_officer" = TRUE)
	),
	"sweeper" = list(
		list("sect" = GROUP_KEY_SECT_ANARCHS)
		// No org, just Anarchs sect
	),
	"bruiser" = list(
		list("sect" = GROUP_KEY_SECT_ANARCHS)
		// No org, just Anarchs sect
	),

	// -------------------
	// Sabbat (Sect + Sabbat Cult Front)
	// -------------------
	"ductus" = list(
		list("sect" = GROUP_KEY_SECT_SABBAT, "is_leader" = TRUE),
		list("organization" = GROUP_KEY_ORG_SABBATCULT, "is_leader" = TRUE)
	),
	"pack priest" = list(
		list("sect" = GROUP_KEY_SECT_SABBAT, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_SABBATCULT, "is_officer" = TRUE)
	),
	"sabbat pack" = list(
		list("sect" = GROUP_KEY_SECT_SABBAT, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_SABBATCULT, "is_officer" = TRUE)
	),

	// -------------------
	// Tremere (Clan + Historic Society)
	// -------------------
	"chantry regent" = list(
		list("clan" = GROUP_KEY_CLAN_TREMERE, "is_leader" = TRUE),
		list("organization" = GROUP_KEY_ORG_TREMERE_COVER, "is_leader" = TRUE)
	),
	"chantry gargoyle" = list(
		list("clan" = GROUP_KEY_CLAN_TREMERE, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_TREMERE_COVER, "is_officer" = TRUE)
	),
	"chantry archivist" = list(
		list("clan" = GROUP_KEY_CLAN_TREMERE),
		list("organization" = GROUP_KEY_ORG_TREMERE_COVER)
	),

	// -------------------
	// Giovanni (Clan + Bank Front)
	// -------------------
	"capo" = list(
		list("clan" = GROUP_KEY_CLAN_GIOVANNI, "is_leader" = TRUE),
		list("organization" = GROUP_KEY_ORG_GIOVANNI_BANK, "is_leader" = TRUE)
	),
	"la squadra" = list(
		list("clan" = GROUP_KEY_CLAN_GIOVANNI, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_GIOVANNI_BANK, "is_officer" = TRUE)
	),
	"la famiglia" = list(
		list("clan" = GROUP_KEY_CLAN_GIOVANNI),
		list("organization" = GROUP_KEY_ORG_GIOVANNI_BANK)
	),

	// -------------------
	// Amberglade
	// -------------------
	"amberglade councillor" = list(
		list("sect" = GROUP_KEY_SECT_AMBERGLADE, "is_leader" = TRUE),
		list("organization" = GROUP_KEY_ORG_AMBERGLADE, "is_leader" = TRUE)
	),
	"amberglade keeper" = list(
		list("sect" = GROUP_KEY_SECT_AMBERGLADE, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_AMBERGLADE, "is_officer" = TRUE)
	),
	"amberglade truthcatcher" = list(
		list("sect" = GROUP_KEY_SECT_AMBERGLADE),
		list("organization" = GROUP_KEY_ORG_AMBERGLADE)
	),
	"amberglade warder" = list(
		list("sect" = GROUP_KEY_SECT_AMBERGLADE),
		list("organization" = GROUP_KEY_ORG_AMBERGLADE)
	),
	"amberglade guardian" = list(
		list("sect" = GROUP_KEY_SECT_AMBERGLADE),
		list("organization" = GROUP_KEY_ORG_AMBERGLADE)
	),

	// -------------------
	// Painted City
	// -------------------
	"painted city councillor" = list(
		list("sect" = GROUP_KEY_SECT_PAINTEDCITY, "is_leader" = TRUE),
		list("organization" = GROUP_KEY_ORG_PAINTEDCITYMALL, "is_leader" = TRUE)
	),
	"painted city keeper" = list(
		list("sect" = GROUP_KEY_SECT_PAINTEDCITY, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_PAINTEDCITYMALL, "is_officer" = TRUE)
	),
	"painted city truthcatcher" = list(
		list("sect" = GROUP_KEY_SECT_PAINTEDCITY),
		list("organization" = GROUP_KEY_ORG_PAINTEDCITYMALL)
	),
	"painted city warder" = list(
		list("sect" = GROUP_KEY_SECT_PAINTEDCITY),
		list("organization" = GROUP_KEY_ORG_PAINTEDCITYMALL)
	),
	"painted city guardian" = list(
		list("sect" = GROUP_KEY_SECT_PAINTEDCITY),
		list("organization" = GROUP_KEY_ORG_PAINTEDCITYMALL)
	),

	// -------------------
	// Endron
	// -------------------
	"endron branch lead" = list(
		list("sect" = GROUP_KEY_SECT_POISONEDSHORE, "is_leader" = TRUE),
		list("organization" = GROUP_KEY_ORG_ENDRON, "is_leader" = TRUE)
	),
	"endron executive" = list(
		list("sect" = GROUP_KEY_SECT_POISONEDSHORE, "is_officer" = TRUE),
		list("organization" = GROUP_KEY_ORG_ENDRON, "is_officer" = TRUE)
	),
	"endron internal affairs agent" = list(
		list("sect" = GROUP_KEY_SECT_POISONEDSHORE),
		list("organization" = GROUP_KEY_ORG_ENDRON, "is_officer" = TRUE)
	),
	"endron chief of security" = list(
		list("sect" = GROUP_KEY_SECT_POISONEDSHORE),
		list("organization" = GROUP_KEY_ORG_ENDRON, "is_officer" = TRUE)
	),
	"endron security agent" = list(
		list("sect" = GROUP_KEY_SECT_POISONEDSHORE),
		list("organization" = GROUP_KEY_ORG_ENDRON)
	),
	"endron employee" = list(
		list("sect" = GROUP_KEY_SECT_POISONEDSHORE),
		list("organization" = GROUP_KEY_ORG_ENDRON)
	),


	// -------------------
	// Tzimisce (Plastic Surgery Front / Mansion)
	// -------------------
	"voivode" = list(
		list("organization" = GROUP_KEY_ORG_TZIMISCE, "is_leader" = TRUE)
	),
	"bogatyr" = list(
		list("organization" = GROUP_KEY_ORG_TZIMISCE, "is_officer" = TRUE)
	),
	"zadruga" = list(
		list("organization" = GROUP_KEY_ORG_TZIMISCE)
	),


	// -------------------
	// Triad (Criminal Front)
	// -------------------
	"triad soldier" = list(
		list("organization" = GROUP_KEY_ORG_TRIAD, "is_officer" = TRUE)
	),


	// -------------------
	// Police Department
	// -------------------
	"police chief" = list(
		list("organization" = GROUP_KEY_ORG_POLICE, "is_leader" = TRUE)
	),
	"police sergeant" = list(
		list("organization" = GROUP_KEY_ORG_POLICE, "is_officer" = TRUE)
	),
	"police officer" = list(
		list("organization" = GROUP_KEY_ORG_POLICE)
	),
	"emergency dispatcher" = list(
		list("organization" = GROUP_KEY_ORG_POLICE, "is_officer" = TRUE)
	),

	// -------------------
	// National Security / Federal Oversight
	// -------------------
	"federal investigator" = list(
		list("organization" = GROUP_KEY_ORG_NATIONALSECURITY),
		list("organization" = GROUP_KEY_ORG_POLICE, "is_officer" = TRUE)
	),

	// -------------------
	// Hospital
	// -------------------
	"clinic director" = list(
		list("organization" = GROUP_KEY_ORG_HOSPITAL, "is_leader" = TRUE)
	),
	"doctor" = list(
		list("organization" = GROUP_KEY_ORG_HOSPITAL)
	),

	// Warehouse Union
	"union boss" = list(
		list("organization" = GROUP_KEY_ORG_WAREHOUSE, "is_leader" = TRUE)
	),
	"dealer" = list(
		list("organization" = GROUP_KEY_ORG_WAREHOUSE, "is_officer" = TRUE)
	),
	"supply technician" = list(
		list("organization" = GROUP_KEY_ORG_WAREHOUSE)
	),
	"dock worker" = list(
		list("organization" = GROUP_KEY_ORG_WAREHOUSE)
	),

	// Civic Services
	"graveyard keeper" = list(
		list("organization" = GROUP_KEY_ORG_CIVICSERVICES)
	),
	"club worker" = list(
		list("organization" = GROUP_KEY_ORG_CIVICSERVICES)
	),
	"street janitor" = list(
		list("organization" = GROUP_KEY_ORG_CIVICSERVICES)
	),
	"taxi driver" = list(
		list("organization" = GROUP_KEY_ORG_CIVICSERVICES)
	),

	//Church
	"priest" = list(
		list("organization" = GROUP_KEY_ORG_CHURCH, "is_leader" = TRUE)
	),
	"church curator" = list(
		list("organization" = GROUP_KEY_ORG_CHURCH, "is_officer" = TRUE)
	),
	"church caretaker" = list(
		list("organization" = GROUP_KEY_ORG_CHURCH, "is_officer" = TRUE)
	),

)


// ---------------- INITIALIZATION ----------------
/datum/controller/subsystem/roleplay_management/Initialize()
	..()
	InitAllGroups()
/datum/controller/subsystem/roleplay_management/proc/InitAllGroups()
	var/created = "", skipped = ""
	for (var/group_key in canonical_groups)
		if (!(group_key in GLOB.groups))
			var/typepath = canonical_groups[group_key]
			GLOB.groups[group_key] = new typepath()
			created += "[group_key], "
		else
			skipped += "[group_key], "
	message_admins("Groups created: [created]\nGroups skipped: [skipped]")
// ---------------- LOOKUP / REGISTRATION ----------------
/datum/controller/subsystem/roleplay_management/proc/get_group_by_key(key)
	return is_valid_key(key) ? GLOB.groups[key] : null
/datum/controller/subsystem/roleplay_management/proc/register_group(datum/group/G)
	if (G && G.id && is_valid_key(G.id))
		GLOB.groups[G.id] = G
/datum/controller/subsystem/roleplay_management/proc/unregister_group(datum/group/G)
	if (G?.id)
		GLOB.groups -= G.id
/datum/controller/subsystem/roleplay_management/proc/get_canonical_group_key_for_type(typepath)
	for (var/k in canonical_groups)
		if (canonical_groups[k] == typepath)
			return k
	return null
// ---------------- ROLE-BASED ASSIGNMENT ----------------
/datum/controller/subsystem/roleplay_management/proc/ensure_groups_from_role(character_key, mob/living/carbon/human/owner)
	var/datum/aboutme_record/R = ensure_aboutme_datum_for_key(character_key, owner)
	var/mob/living/carbon/human/H = owner
	var/list/group_keys = list()
	var/display_name = H.true_real_name || H.name
	// --- City (always)
	var/datum/group/city_group = GLOB.groups[GROUP_KEY_CITY]
	if (city_group)
		city_group.add_member_key(character_key, display_name)
		group_keys += GROUP_KEY_CITY
	// --- Faction
	var/faction_key = null
	if (isghoul(H))
		faction_key = GROUP_KEY_FACTION_GHOUL
	else if (iscathayan(H))
		faction_key = GROUP_KEY_FACTION_KUEIJIN
	else if (iskindred(H))
		faction_key = GROUP_KEY_FACTION_KINDRED
	else if (isgarou(H))
		faction_key = GROUP_KEY_FACTION_FERA
	else
		faction_key = GROUP_KEY_FACTION_UNKNOWING
	if (faction_key)
		var/datum/group/faction_group = GLOB.groups[faction_key]
		if (faction_group)
			faction_group.add_member_key(character_key, display_name)
			group_keys += faction_key

	// --- Dynamic Role-Based Assignments
	var/group_roles = role_to_groups(H.mind?.assigned_role)
	for (var/Role in group_roles)
		var/group_key = Role["group_key"]
		var/datum/group/G = GLOB.groups[group_key]
		if (!G) continue
		group_keys += group_key
		if (Role["is_leader"])
			G.add_leader(character_key, display_name)
		else if (Role["is_officer"])
			G.add_officer(character_key, display_name)
		else
			G.add_member_key(character_key, display_name)
	// --- Clan
	if (iskindred(H))
		var/clan_name = H.clane?.name
		if (!clan_name || lowertext(clan_name) == "unknown" || lowertext(clan_name) == "none")
			clan_name = "Caitiff"
		var/clan_key = GROUP_KEY_CLAN(clan_name)
		var/datum/group/clan_group = GLOB.groups[clan_key]
		if (!clan_group)
			clan_key = GROUP_KEY_CLAN_CAITIF
			clan_group = GLOB.groups[clan_key]
		if (clan_group)
			clan_group.add_member_key(character_key, display_name)
			group_keys += clan_key
	// --- Tribe
	if (isgarou(H) || iswerewolf(H))
		var/tribe = H.auspice?.tribe?.name
		var/tribe_key = tribe ? GROUP_KEY_TRIBE(tribe) : GROUP_KEY_TRIBE_RONIN
		var/datum/group/tribe_group = GLOB.groups[tribe_key] || GLOB.groups[GROUP_KEY_TRIBE_RONIN]
		if (tribe_group)
			tribe_group.add_member_key(character_key, display_name)
			group_keys += tribe_key // use canonical key
	// --- Finalize Group Links
	if (!islist(R.group_keys)) R.group_keys = list()
	for (var/gk in group_keys)
		if (!(gk in R.group_keys))
			R.group_keys += gk
/// Cleanly removes a character from a specific group, including leadership/officer/member status, deleting the relationshoip, and key etc.
/datum/controller/subsystem/roleplay_management/proc/clear_group_relationship(character_key, datum/group/G)
	// Remove from group
	G.leaders -= character_key
	G.officers -= character_key
	G.members -= character_key
	G.member_names -= character_key
	// Remove group key from record
	var/datum/aboutme_record/R = get_aboutme_record(character_key)
	if (R && islist(R.group_keys))
		R.group_keys -= G.id
	// Remove group relationship
	for (var/datum/relationships/rel in GLOB.relationships)
		if (rel.source_character == character_key && rel.group_target_id == G.id)
			GLOB.relationships -= rel.id
			if (R?.relationship_keys)
				R.relationship_keys -= rel.id
			qdel(rel)
			break
	return
// ---------------- GROUP PARSER ----------------
/datum/controller/subsystem/roleplay_management/proc/role_to_groups(role)
	var/list/results = list()
	var/entry = SSroleplay_management.ROLE_GROUP_MAPPINGS[lowertext(trim(role))]
	if (!islist(entry))
		return results
	// Handle both: legacy single-mapping and new multi-mapping
	if (!islist(entry[1]))
		entry = list(entry)
	for (var/map in entry)
		for (var/group_type in map)
			if (!(group_type in list(GROUP_TYPE_SECT, GROUP_TYPE_CLAN, GROUP_TYPE_TRIBE, GROUP_TYPE_ORGANIZATION, GROUP_TYPE_PARTY)))
				continue
			var/group_key = map[group_type] // Already the define key!
			results += list(list(
				"group_key" = group_key,
				"group_type" = group_type,
				"is_leader" = map["is_leader"] || FALSE,
				"is_officer" = map["is_officer"] || FALSE
			))
	return results

// ---------------- CLEANUP ----------------
/datum/controller/subsystem/roleplay_management/proc/remove_key_from_all_groups(character_key)
	for (var/group_id in GLOB.groups)
		var/datum/group/G = GLOB.groups[group_id]
		if (!G) continue
		G.leaders -= character_key
		G.officers -= character_key
		G.members -= character_key
		G.member_names -= character_key
