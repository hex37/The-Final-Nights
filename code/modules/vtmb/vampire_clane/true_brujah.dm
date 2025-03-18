/datum/vampireclane/true_brujah
	name = CLAN_TRUE_BRUJAH
	desc = "The True Brujah are a bloodline of Clan Brujah that claim to be descendants of the original Antediluvian founder of the lineage and not his diablerist/childe Troile. They are also noted for their calm, detached behavior, which puts them in contrast to the main lineage who are known for their rather short, violent tempers and anti-establishment attitudes. "
	curse = "Absence of passion."
	clane_disciplines = list(
		/datum/discipline/potence,
		/datum/discipline/presence,
		/datum/discipline/temporis
	)
	violating_appearance = FALSE
	is_enlightened = TRUE
	male_clothes = /obj/item/clothing/under/vampire/rich
	female_clothes = /obj/item/clothing/under/vampire/business
	clan_keys = /obj/item/vamp/keys/trujah
	restricted_disciplines = list(/datum/discipline/celerity)
	whitelisted = FALSE
