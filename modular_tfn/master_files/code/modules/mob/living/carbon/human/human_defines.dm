/mob/living/carbon/human
	var/headshot_link = null
	var/flavor_text
	var/flavor_text_nsfw
	var/character_notes
	var/ooc_notes
	var/show_flavor_text_when_masked

/mob/living/carbon/human/ComponentInitialize()
	. = ..()
	if(!GetComponent(/datum/component/about_me))
		AddComponent(/datum/component/about_me)
