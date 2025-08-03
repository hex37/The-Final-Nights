// ================================================================
// RP Management Subsystem - Groups (ssroleplay_management_groups.dm)
// ================================================================
// Handles:
//   - Canonical group registration
//   - Initial group assignment based on species/role
//   - Runtime group lookup and modification
// ================================================================

/datum/controller/subsystem/roleplay_management/var/list/ROLE_GROUP_MAPPINGS = list(
    // -------------------
    // Camarilla
    // -------------------
    "prince"            = list("sect" = "Camarilla", "is_leader" = TRUE),
    "seneschal"         = list("sect" = "Camarilla", "is_officer" = TRUE),
    "harpy"             = list("sect" = "Camarilla", "is_officer" = TRUE),
    "sheriff"           = list("sect" = "Camarilla"),
    "hound"             = list("sect" = "Camarilla"),
    "tower employee"    = list("sect" = "Camarilla"),

    "primogen malkavian"        = list("clan" = "malkavian", "is_leader" = TRUE),
    "primogen nosferatu"        = list("clan" = "nosferatu", "is_leader" = TRUE),
    "primogen toreador"         = list("clan" = "toreador", "is_leader" = TRUE),
    "primogen ventrue"          = list("clan" = "ventrue", "is_leader" = TRUE),
    "primogen lasombra"         = list("clan" = "lasombra", "is_leader" = TRUE),
    "primogen banu haqim"       = list("clan" = "banu_haqim", "is_leader" = TRUE),

    "chantry regent"            = list("clan" = "tremere", "is_leader" = TRUE),
    "chantry gargoyle"          = list("clan" = "tremere", "is_officer" = TRUE),
    "chantry archivist"         = list("clan" = "tremere"),

    "capo"              = list("clan" = "giovanni", "is_leader" = TRUE),
    "la squadra"        = list("clan" = "giovanni", "is_officer" = TRUE),
    "la famiglia"       = list("clan" = "giovanni"),

    // -------------------
    // Anarchs
    // -------------------
    "baron"             = list("sect" = "Anarchs", "is_leader" = TRUE),
    "emissary"          = list("sect" = "Anarchs", "is_officer" = TRUE),
    "sweeper"           = list("sect" = "Anarchs"),
    "bruiser"           = list("sect" = "Anarchs"),

    // -------------------
    // Sabbat
    // -------------------
    "archbishop"        = list("sect" = "Sabbat", "is_leader" = TRUE),
    "bishop"            = list("sect" = "Sabbat", "is_officer" = TRUE),
    "templar"           = list("sect" = "Sabbat", "is_officer" = TRUE),
    "ductus"            = list("sect" = "Sabbat"),

    // -------------------
    // Garou Septs
    // -------------------
    "painted city councillor" = list("tribe" = "Painted City", "is_leader" = TRUE),
    "amberglade councillor"   = list("tribe" = "Amberglade", "is_leader" = TRUE),

    // -------------------
    // Organizations - Endron
    // -------------------
    "endron branch lead" = list("organization" = "Endron", "is_leader" = TRUE),
    "endron executive"   = list("organization" = "Endron", "is_officer" = TRUE),
    "endron employee"    = list("organization" = "Endron"),

    // -------------------
    // Organizations - Police
    // -------------------
    "police chief"       = list("organization" = "Police", "is_leader" = TRUE),
    "police sergeant"    = list("organization" = "Police", "is_officer" = TRUE),
    "police officer"     = list("organization" = "Police"),

    // -------------------
    // Organizations - Hospital
    // -------------------
    "clinic director"    = list("organization" = "hospital", "is_leader" = TRUE),
    "doctor"             = list("organization" = "hospital")
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
	if (!character_key || !owner) return

	var/datum/aboutme_record/R = ensure_aboutme_datum_for_key(character_key, owner)
	if (!R || !ismob(owner)) return

	var/mob/living/carbon/human/H = owner
	if (!H) return

	var/list/group_keys = list()
	var/display_name = H.true_real_name || H.name

	// --- City (always)
	var/datum/group/city_group = GLOB.groups[GROUP_KEY_CITY]
	if (city_group)
		city_group.add_member_key(character_key, display_name)
		group_keys += GROUP_KEY_CITY

	// --- Faction
	var/faction_key = null
	if (!iskindred(H) && !isgarou(H))
		faction_key = GROUP_KEY_FACTION_UNKNOWING
	else if (iskindred(H) || isghoul(H))
		faction_key = GROUP_KEY_FACTION_KINDRED
	else if (isgarou(H))
		faction_key = GROUP_KEY_FACTION_FERA

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
	if (!character_key || !G) return

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
    if (!role) return list()

    var/list/results = list()
    var/entry = SSroleplay_management.ROLE_GROUP_MAPPINGS[lowertext(trim(role))]
    if (!islist(entry)) return results

    for (var/group_type in entry)
        if (!(group_type in list(GROUP_TYPE_SECT, GROUP_TYPE_CLAN, GROUP_TYPE_TRIBE, GROUP_TYPE_ORGANIZATION, GROUP_TYPE_PARTY)))
            continue

        var/group_raw = entry[group_type]
        if (!istext(group_raw) || !length(group_raw)) continue

        var/group_key

        switch (group_type)
            if (GROUP_TYPE_SECT)
                group_key = GROUP_KEY_SECT(group_raw)
            if (GROUP_TYPE_CLAN)
                group_key = GROUP_KEY_CLAN(group_raw)
            if (GROUP_TYPE_TRIBE)
                group_key = GROUP_KEY_TRIBE(group_raw)
            if (GROUP_TYPE_ORGANIZATION)
                switch(lowertext(group_raw))
                    if ("hospital") group_key = GROUP_KEY_ORG_HOSPITAL
                    if ("police") group_key = GROUP_KEY_ORG_POLICE
                    if ("government") group_key = GROUP_KEY_ORG_GOVERNMENT
                    if ("military") group_key = GROUP_KEY_ORG_MILITARY
                    if ("bikergang") group_key = GROUP_KEY_ORG_BIKERGANG
                    if ("corporation", "corp") group_key = GROUP_KEY_ORG_CORP
                    if ("warehouse") group_key = GROUP_KEY_ORG_WAREHOUSE
                    if ("church") group_key = GROUP_KEY_ORG_CHURCH
                    if ("civicservices") group_key = GROUP_KEY_ORG_CIVICSERVICES
                    if ("nationalsecurity") group_key = GROUP_KEY_ORG_NATIONALSECURITY
                    if ("tzimisce") group_key = GROUP_KEY_ORG_TZIMISCE
                    if ("triad") group_key = GROUP_KEY_ORG_TRIAD
                    else group_key = "org_[lowertext(replacetext(group_raw, " ", "_"))]" // fallback for undefined orgs

            if (GROUP_TYPE_PARTY)
                group_key = "party_[lowertext(replacetext(group_raw, " ", "_"))]"

        results += list(list(
            "group_key" = group_key,
            "group_type" = group_type,
            "is_leader" = entry["is_leader"] || FALSE,
            "is_officer" = entry["is_officer"] || FALSE
        ))

    return results


// ---------------- CLEANUP ----------------
/datum/controller/subsystem/roleplay_management/proc/remove_key_from_all_groups(character_key)
    if (!character_key) return
    for (var/group_id in GLOB.groups)
        var/datum/group/G = GLOB.groups[group_id]
        if (!G) continue
        G.leaders -= character_key
        G.officers -= character_key
        G.members -= character_key
        G.member_names -= character_key
