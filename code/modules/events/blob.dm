/datum/round_event_control/blob //god, we really need a "latest start" var, because blobs spawning an hour in is cringe
	name = "Blob"
	typepath = /datum/round_event/ghost_role/blob
	weight = 15
	max_occurrences = 1
	earliest_start = 45 MINUTES


	min_players = 20

	gamemode_blacklist = list("blob") //Just in case a blob survives that long

/datum/round_event/ghost_role/blob
	announceChance	= 0
	role_name = "blob overmind"
	fakeable = TRUE

/datum/round_event/ghost_role/blob/announce(fake)
	priority_announce("Potwierdzono wystąpienie zagrożenia biologicznego piątego poziomu na pokładzie [station_name()]. Cały personel ma za zadanie powstrzymać rozprzestrzenienie.", "Alarm biologiczny", 'sound/ai/outbreak5.ogg')

/datum/round_event/ghost_role/blob/spawn_role()
	if(!GLOB.blobstart.len)
		return MAP_ERROR
	var/list/candidates = get_candidates(ROLE_BLOB, null, ROLE_BLOB)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/new_blob = pick(candidates)
	var/mob/camera/blob/BC = new_blob.become_overmind()
	spawned_mobs += BC
	message_admins("[ADMIN_LOOKUPFLW(BC)] has been made into a blob overmind by an event.")
	log_game("[key_name(BC)] was spawned as a blob overmind by an event.")
	return SUCCESSFUL_SPAWN
