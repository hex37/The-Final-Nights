// ---------------------------------------------
// Premade Groups! Yes this needs split up, am i doing it yet? No.
// ---------------------------------------------
//CITY/FACTIONS/SECTS/CLANS/TRIBES/ORGANIZATIONS/PARTIES!!!
//This is where groups start to change a lot. The main ones stay the same though.
//These are the base group datums, datum/group/something, should NEVER be used, use these.
//These are being extended for fully premade groups and dynamics below, and will only be generated in round, as needed, in most cases.
//City is just the whole city.
/datum/group/city
	gtype = GROUP_TYPE_CITY
	tags = list(GROUP_TAG_CITY)
	orders = "'Live your life as you see fit within the confines of the city's laws.'-Mayor of San Fran"
/datum/group/faction
	gtype = GROUP_TYPE_FACTION
	tags = list(GROUP_TAG_FACTION)
	orders = "(Nothing of note is happening, currently...)"
/datum/group/sect
	gtype = GROUP_TYPE_SECT
	tags = list(GROUP_TAG_SECT)
	orders = "'(Follow the ways of the sect.)' - Leader"
/datum/group/clan
	gtype = GROUP_TYPE_CLAN
	tags = list(GROUP_TAG_CLAN)
	var/sect = "" //if applies.
	orders = "'(Follow the ways of the clan.' - Leader"
/datum/group/tribe
	gtype = GROUP_TYPE_TRIBE
	tags = list(GROUP_TAG_TRIBE)
	var/sect = ""
	orders = "'(Follow the ways of the tribe.' - Leader"
// Catch-all organizations (PD, hospital, etc)
/datum/group/organization
	gtype = GROUP_TYPE_ORGANIZATION
	tags = list(GROUP_TAG_ORG)
/datum/group/party
	gtype = GROUP_TYPE_PARTY
	tags = list(GROUP_TAG_PARTY)

//PREMADE GROUPS!
//ALL OF THESE MUST HAVE A KEY FOR THEIR ID. Found in group.dm.
//The WHOLE City.
/datum/group/city/SanFrancisco
	is_public = TRUE
	id = GROUP_KEY_CITY
	name = "San Francisco"
	desc = "The city of San Francisco. No matter your story, citizen or visitor, your choices brought you here this night."
	leader_name = "Government/Mayor/City Council"
//Factions: These represent mob mentality, for example kindred whispers of sabbat can be updated here. Very Generalized
//Citizens, all city services fall under this.
/datum/group/faction/citizen
	is_public = TRUE
	id = GROUP_KEY_FACTION_UNKNOWING // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Citizen of San Francisco"
	desc = "You are among the masses of San Francisco."
	leader_name = "The Masses."
//Kindred
/datum/group/faction/kindred
	id = GROUP_KEY_FACTION_KINDRED // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Kindred of San Francisco"
	desc = "You are among the Kindred of San Francisco."
	leader_name = "Varies"
//Ghouls
/datum/group/faction/ghoul
	id = GROUP_KEY_FACTION_FERA // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Ghouls of San Francisco"
	desc = "You are among the Ghouls of San Francisco."
	leader_name = "Varies, between sects."
//KueiJin
/datum/group/faction/kueijin
	id = GROUP_KEY_FACTION_KUEIJIN // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Kuei-Jin of San Francisco"
	desc = "You are among the Kuei-Jin of San Francisco."
	leader_name = "Varies, between sects."
//Fera
/datum/group/faction/fera
	id = GROUP_KEY_FACTION_FERA // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Fera of San Francisco"
	desc = "You are among the Fera of San Francisco."
	leader_name = "Varies, between sects."
//Hunters
/datum/group/faction/hunter
	id = GROUP_KEY_FACTION_HUNTERS // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Hunter of San Francisco"
	desc = "You are a hunter of San Francisco, with all that entails."
	leader_name = "Varies"
//Sects: Unlike generalized factions, sects are driven largly by player choices!
//Independent, Catch all for everyone.
/datum/group/sect/independent
	is_public = TRUE
	id = GROUP_KEY_SECT_INDEPENDENT
	name = "Independent"
	desc = "You are independent, and not aligned with any major sect, for now."
	leader_name = "You lead your own life, as you will."
//Kindred Sects, set from role
/datum/group/sect/camarilla
	id = GROUP_KEY_SECT_CAMARILLA
	name = "Camarilla of San Francisco"
	desc = "You are a member of the Camarilla, you are dedicated to preserving the Traditions."
	leader_name = "Prince"
/datum/group/sect/anarchs
	id = GROUP_KEY_SECT_ANARCHS
	name = "Anarch of San Francisco"
	desc = "You are an Anarch, a member of the Anarch Movement, which opposes the rigid hierarchy of the Camarilla and seeks greater freedom and equality among Kindred."
	leader_name = "Baron"
/datum/group/sect/sabbat
	id = GROUP_KEY_SECT_SABBAT
	name = "Sabbat of San Francisco"
	desc = "You are a member of the Sabbat, a sect of Kindred that rejects human morality and embraces their predatory nature, often engaging in violent and ruthless behavior."
	leader_name = "Ductus"
//Fera Sects, set from role
/datum/group/sect/paintedcity
	id = GROUP_KEY_SECT_PAINTEDCITY
	name = "Painted City of San Francisco"
	desc = "You are a member of the painted city."
	leader_name = "The Spirits"
/datum/group/sect/amberglade
	id = GROUP_KEY_SECT_AMBERGLADE
	name = "Amber Glade of San Francisco"
	desc = "You are a member of the amber glade."
	leader_name = "The Spirits"
/datum/group/sect/poisonedshore
	id = GROUP_KEY_SECT_POISONEDSHORE
	name = "Poisoned Shore of San Francisco"
	desc = "You are a member of the poisoned shore."
	leader_name = "The Spirits"
//Kindred Clans, set from character
/datum/group/clan/caitif
	id = GROUP_KEY_CLAN_CAITIF
	name = "Clanless"
	desc = "You are without clan."
/datum/group/clan/ventrue
	id = GROUP_KEY_CLAN_VENTRUE
	name = "Clan Ventrue"
	desc = "Clan Ventrue, the blue bloods and aristocrats of the Kindred."
/datum/group/clan/brujah
	id = GROUP_KEY_CLAN_BRUJAH
	name = "Clan Brujah"
	desc = "Clan Brujah, the rabble, rebels, and iconoclasts of the Kindred."
/datum/group/clan/toreador
	id = GROUP_KEY_CLAN_TOREADOR
	name = "Clan Toreador"
	desc = "Clan Toreador, the artistes, socialites, and patrons of the Kindred."
/datum/group/clan/malkavian
	id = GROUP_KEY_CLAN_MALKAVIAN
	name = "Clan Malkavian"
	desc = "Clan Malkavian, the seers, lunatics, and visionaries of the Kindred."
/datum/group/clan/nosferatu
	id = GROUP_KEY_CLAN_NOSFERATU
	name = "Clan Nosferatu"
	desc = "Clan Nosferatu, the outcasts, spies, and information brokers of the Kindred."
/datum/group/clan/gangrel
	id = GROUP_KEY_CLAN_GANGREL
	name = "Clan Gangrel"
	desc = "Clan Gangrel, the wanderers and shapeshifters of the Kindred."
/datum/group/clan/tremere
	id = GROUP_KEY_CLAN_TREMERE
	name = "Clan Tremere"
	desc = "Clan Tremere, the warlocks, scholars, and blood mages of the Kindred."
/datum/group/clan/lasombra
	id = GROUP_KEY_CLAN_LASOMBRA
	name = "Clan Lasombra"
	desc = "Clan Lasombra, the shadow manipulators and rulers of the Kindred."
/datum/group/clan/tzimisce
	id = GROUP_KEY_CLAN_TZIMISCE
	name = "Clan Tzimisce"
	desc = "Clan Tzimisce, the flesh-shapers and lords of horror among the Kindred."
/datum/group/clan/ministry
	id = GROUP_KEY_CLAN_MINISTRY
	name = "Clan Ministry"
	desc = "The Ministry (formerly Setites), the corrupters, tempters, and cultists of the Kindred."
/datum/group/clan/giovanni
	id = GROUP_KEY_CLAN_GIOVANNI
	name = "Clan Giovanni"
	desc = "Clan Giovanni, the necromancers and merchant princes of the Kindred."
/datum/group/clan/salubri
	id = GROUP_KEY_CLAN_SALUBRI
	name = "Clan Salubri"
	desc = "Clan Salubri, the healers, sages, and outcasts among the Kindred."
/datum/group/clan/daughters_of_cacophony
	id = GROUP_KEY_CLAN_DAUGHTERS_OF_CACOPHONY
	name = "Daughters of Cacophony"
	desc = "The Daughters of Cacophony, enigmatic sirens and masters of supernatural song."
/datum/group/clan/baali
	id = GROUP_KEY_CLAN_BAALI
	name = "Clan Baali"
	desc = "The Baali, infernalists, corrupters, and worshippers of dark powers among the Kindred."
/datum/group/clan/true_brujah
    id = GROUP_KEY_CLAN_TRUE_BRUJAH
    name = "Clan True Brujah"
    desc = "Clan True Brujah, the masters of time and keepers of ancient secrets among the Kindred."
/datum/group/clan/banu_haqim
    id = GROUP_KEY_CLAN_BANU_HAQIM
    name = "Clan Banu Haqim"
    desc = "Clan Banu Haqim (Assamites), the judges, assassins, and scholars of Kindred law and blood."
//Fera Tribes, ronin default, set from character.
/datum/group/tribe/ronin
	id = GROUP_KEY_TRIBE_RONIN
	name = "Ronin"
	desc = "Ronin, those Garou and Fera who walk alone without tribe or allegiance."
/datum/group/tribe/blackfuries
	id = GROUP_KEY_TRIBE_BLACKFURIES
	name = "Black Furies"
	desc = "The Black Furies, protectors of the sacred and avengers of the oppressed."
/datum/group/tribe/blackspiraldancers
	id = GROUP_KEY_TRIBE_BLACKSPIRALDANCERS
	name = "Black Spiral Dancers"
	desc = "The Black Spiral Dancers, lost to the Wyrm and bringers of chaos and corruption."
/datum/group/tribe/bonegnawers
	id = GROUP_KEY_TRIBE_BONEGNAWERS
	name = "Bone Gnawers"
	desc = "The Bone Gnawers, survivors of the streets and scavengers among the Garou."
/datum/group/tribe/childrenofgaia
	id = GROUP_KEY_TRIBE_CHILDRENOFGAIA
	name = "Children of Gaia"
	desc = "The Children of Gaia, peacemakers, healers, and seekers of unity among the Garou."
/datum/group/tribe/corax
	id = GROUP_KEY_TRIBE_CORAX
	name = "Corax"
	desc = "The Corax, raven-shifters, messengers, and keepers of secrets."
/datum/group/tribe/galestalkers
	id = GROUP_KEY_TRIBE_GALESTALKERS
	name = "Gale Stalkers"
	desc = "The Gale Stalkers, elusive and wild Garou, attuned to the storm."
/datum/group/tribe/getoffenris
	id = GROUP_KEY_TRIBE_GETOFFENRIS
	name = "Get of Fenris"
	desc = "The Get of Fenris, warriors, berserkers, and defenders of Garou honor."
/datum/group/tribe/ghostcouncil
	id = GROUP_KEY_TRIBE_GHOSTCOUNCIL
	name = "Ghost Council"
	desc = "The Ghost Council, mysterious spirit-guided Garou or the wise of the Umbra."
/datum/group/tribe/glasswalkers
	id = GROUP_KEY_TRIBE_GLASSWALKERS
	name = "Glass Walkers"
	desc = "The Glass Walkers, masters of technology and urban Garou society."
/datum/group/tribe/hartwardens
	id = GROUP_KEY_TRIBE_HARTWARDENS
	name = "Hart Wardens"
	desc = "The Hart Wardens, guardians of nature and sacred lands."
/datum/group/tribe/redtalons
	id = GROUP_KEY_TRIBE_REDTALONS
	name = "Red Talons"
	desc = "The Red Talons, savage Garou, fierce protectors of the wild."
/datum/group/tribe/shadowlords
	id = GROUP_KEY_TRIBE_SHADOWLORDS
	name = "Shadow Lords"
	desc = "The Shadow Lords, cunning politicians, manipulators, and seekers of power."
/datum/group/tribe/silentstriders
	id = GROUP_KEY_TRIBE_SILENTSTRIDERS
	name = "Silent Striders"
	desc = "The Silent Striders, wanderers and messengers of the restless dead."
/datum/group/tribe/silverfangs
	id = GROUP_KEY_TRIBE_SILVERFANGS
	name = "Silver Fangs"
	desc = "The Silver Fangs, noble rulers and ancient leaders of the Garou Nation."
/datum/group/tribe/stargazers
	id = GROUP_KEY_TRIBE_STARGAZERS
	name = "Stargazers"
	desc = "The Stargazers, mystics, philosophers, and seekers of cosmic truth."



// ========================================================================
// Major Organizations and Faction Fronts
// ========================================================================

// --- City Government ---
/datum/group/organization/government
    id = GROUP_KEY_ORG_GOVERNMENT
    name = "San Francisco City Government"
    desc = "The officials, clerks, and leaders who keep the city running."
    leader_name = "Mayor, City Council, and Commissioners"
    orders = "Maintain city operations and liaise with other departments."

// --- Police Department ---
/datum/group/organization/policedepartment
    id = GROUP_KEY_ORG_POLICE
    name = "San Francisco Police Department"
    desc = "The police officers sworn to serve and protect the city."
    leader_name = "Chief of Police"
    orders = "Patrol and monitor suspicious activity. Keep the peace."

// --- Hospital Staff ---
/datum/group/organization/hospital
    id = GROUP_KEY_ORG_HOSPITAL
    name = "St. Mary's Hospital Staff"
    desc = "Doctors, nurses, and medical professionals of San Francisco."
    leader_name = "Chief Medical Officer"
    orders = "ER is on high alert for unusual injuries. Coordinate with PD for blood shortage."

// --- Military ---
/datum/group/organization/military
    id = GROUP_KEY_ORG_MILITARY
    name = "National Guard - San Francisco Garrison"
    desc = "National Guard soldiers stationed in the city."
    leader_name = "Colonel of the Garrison"
    orders = "Secure key assets, provide emergency support, and maintain martial readiness."

// --- Warehouse Union ---
/datum/group/organization/warehouse
    is_public = TRUE
    id = GROUP_KEY_ORG_WAREHOUSE
    name = "San Fran Warehouse Union"
    desc = "The dock workers, warehouse staff, and logistics crew who keep shipments moving."
    leader_name = "Union Boss"
    orders = "Loadouts run every third shift. Watch for smuggling or Kindred tampering."

// --- Church ---
/datum/group/organization/church
    is_public = TRUE
    id = GROUP_KEY_ORG_CHURCH
    name = "Church of Saint Brigid"
    desc = "A growing congregation known for its aid work and strange sermons."
    leader_name = "Father MacGowan"
    orders = "Open soup kitchen at dusk. Midnight mass ongoing. Beware interlopers."

// --- Civic Services ---
/datum/group/organization/civicservices
    id = GROUP_KEY_ORG_CIVICSERVICES
    name = "Civic Services Bureau"
    desc = "Garbage collection, grid maintenance, and vital city infrastructure roles."
    leader_name = "Dept. of Public Works Superintendent"
    orders = "Keep power and water flowing. Strike threats under observation."

// --- National Security ---
/datum/group/organization/nationalsecurity
    id = GROUP_KEY_ORG_NATIONALSECURITY
    name = "Federal Oversight Division"
    desc = "A shadowy national security task force. Their exact purpose is classified."
    leader_name = "Special Agent-in-Charge"
    orders = "Maintain surveillance on supernatural hotspots and potential threats."

// ========================================================================
// Major Sects/Factions and Public/Front Organizations
// ========================================================================

// --- Camarilla Faction: Millennium Tower ---
/datum/group/organization/millenniumtower
    id = GROUP_KEY_ORG_MILLENNIUMTOWER
    name = "Millennium Tower"
    desc = "A luxury skyscraper housing elite city interests, corporate headquarters, and influential private residents."
    leader_name = "Tower Executive Committee"
    orders = "Maintain exclusivity, organize Tower events, and support major city projects."

// --- Anarch Faction: Anarchy Rose Bar ---
/datum/group/organization/anarchyrose
    id = GROUP_KEY_ORG_ANARCHYROSE
    name = "Anarchy Rose Bar"
    desc = "A raucous, music-filled dive in the heart of the city, headquarters for alternative culture, bikes, and rebellion."
    leader_name = "Baron & Management"
    orders = "Host live music, biker rallies, and support 'local causes' (sometimes of questionable legality)."

// --- Sabbat Faction: Church of the New Flesh ---
/datum/group/organization/sabbatcult
    id = GROUP_KEY_ORG_SABBATCULT
    name = "Church of the New Flesh"
    desc = "A secretive cult masquerading as an underground faith community, rumored to practice bizarre rites."
    leader_name = "High Priest/Archbishop"
    orders = "Spread the doctrine, conduct rituals, recruit among the desperate and lost."

// --- Tremere Cover: Historic Society ---
/datum/group/organization/historicsociety
    is_public = TRUE
    id = GROUP_KEY_ORG_TREMERE_COVER
    name = "San Francisco Historic Society"
    desc = "A respected nonprofit dedicated to preserving and studying the city’s heritage, archives, and cultural secrets."
    leader_name = "Society President"
    orders = "Catalog rare artifacts, run city tours, and consult on historical matters for the city council."

// --- Giovanni Front: Bank of San Francisco ---
/datum/group/organization/giovannibank
    is_public = TRUE
    id = GROUP_KEY_ORG_GIOVANNI_BANK
    name = "Bank of San Francisco"
    desc = "The most discreet, prestigious, and old-money financial institution in the city, with international reach."
    leader_name = "Chairman of the Board"
    orders = "Protect client secrets. Ensure all debts are paid."
// --- Endron/Corporation Front ---
/datum/group/organization/endron
    id = GROUP_KEY_ORG_ENDRON
    name = "Endron San Francisco HQ"
    desc = "The local headquarters of Endron Energy, the city's largest utility and a front for deeper interests."
    leader_name = "Site CEO"
    orders = "Secure energy operations. Maintain plausible deniability for special projects."
// --- Amberglade Faction: Golden Gate National Park HQ ---
/datum/group/organization/amberglade
    id = GROUP_KEY_ORG_AMBERGLADE
    name = "Golden Gate National Park HQ"
    desc = "The park’s management office, responsible for rangers, programs, and wildlife protection."
    leader_name = "Head Ranger"
    orders = "Preserve the wild, protect the park, and welcome only the worthy."
// --- Painted City Faction: Mall & Techshop ---
/datum/group/organization/paintedcitymall
    id = GROUP_KEY_ORG_PAINTEDCITYMALL
    name = "Mall & Techshop"
    desc = "A sprawling, high-tech urban hub for shopping, innovation, and urban renewal. Home to many secrets."
    leader_name = "Mall Director"
    orders = "Promote innovation and commerce, keep the peace, monitor for trouble."
// --- Tzimisce Front/Organization: Flesh & Form Institute ---
/datum/group/organization/tzimisce
    is_public = TRUE
    id = GROUP_KEY_ORG_TZIMISCE
    name = "Flesh & Form Institute"
    desc = "A renowned plastic surgery and body modification clinic, catering to elite and eccentric tastes alike. The Institute boasts discretion, artistry, and 'miraculous' results for those who can pay."
    leader_name = "Dr. Voivode (Chief Surgeon)"
    orders = "Redefine beauty. Welcome all who seek transformation, but discretion is paramount. VIP clients receive 'special' services."
// --- Triad Front/Organization ---
/datum/group/organization/triad
    is_public = TRUE
    id = GROUP_KEY_ORG_TRIAD
    name = "San Francisco Triad"
    desc = "An influential criminal syndicate with deep roots in the city’s underworld."
    leader_name = "Dragon Head"
    orders = "Control territory, run operations, enforce loyalty."
