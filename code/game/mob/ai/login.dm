/mob/ai/Login()
	..()
	UpdateClothing()
	for(var/S in src.client.screen)
		del(S)
	src.blind = new /obj/screen( null )
	src.blind.icon_state = "black"
	src.blind.name = " "
	src.blind.screen_loc = "1,1 to 15,15"
	src.blind.layer = 0
	src.client.screen += src.blind
	if(!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	return


/mob/ai/New()
	..()
	src.connector = new /obj/machinery/AIconnector(src.loc)
	connectora = src.connector
	connectora.ais += src
	connector.ailabel = "Local Hardlink"
	src.connectors["Local Hardlink"] = src.connector
	makecomputernets(1)