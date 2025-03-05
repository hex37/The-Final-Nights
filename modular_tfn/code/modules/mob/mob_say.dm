/// Big version of the me emote verb
/mob/verb/me_big_verb()
	set name = "Me(big)"
	set category = "IC"
	var/message = tgui_input_text(usr, "Input a custom emote:", "Emote", max_length = MAX_MESSAGE_LEN, multiline = TRUE)

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_notice("Speech is currently admin-disabled."))
		return

	usr.emote("me",1,message,TRUE)
