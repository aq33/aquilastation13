#define FLUKEOPS_TIME_DELAY 12000 // 20 minutes, how long before the credits stop calling the nukies flukeops

/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	report_type = "nuclear"
	false_report_weight = 10
	required_players = 20 // 30 players - 3 players to be the nuke ops = 27 players remaining
	required_enemies = 1
	recommended_enemies = 3
	antag_flag = ROLE_OPERATIVE
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "Siły Syndykatu zbliżają się do stacji w celu jej zniszczenia!\n\
	<span class='danger'>Operatives</span>: Zabezpieczcie dysk nuklearnej autoryzacji i uzyjcie swojej atomówki do zniszczenia stacji.\n\
	<span class='notice'>Crew</span>: Chrońcie dysk nuklearnej autoryzacji i upewnijcie się, że zawsze będzie z wami na promie ratunkowym."

	title_icon = "nukeops"

	var/const/agents_possible = 5 //If we ever need more syndicate agents.
	var/nukes_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/list/pre_nukeops = list()

	var/datum/team/nuclear/nuke_team

	var/operative_antag_datum_type = /datum/antagonist/nukeop
	var/leader_antag_datum_type = /datum/antagonist/nukeop/leader

/datum/game_mode/nuclear/pre_setup()
	var/n_agents = min(round(num_players() / 10), antag_candidates.len, agents_possible)
	if(n_agents >= required_enemies)
		for(var/i = 0, i < n_agents, ++i)
			var/datum/mind/new_op = pick_n_take(antag_candidates)
			pre_nukeops += new_op
			new_op.assigned_role = "Nuclear Operative"
			new_op.special_role = "Nuclear Operative"
			log_game("[key_name(new_op)] has been selected as a nuclear operative")
		return TRUE
	else
		setup_error = "Not enough nuke op candidates"
		return FALSE
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/post_setup()
	//Assign leader
	var/datum/mind/leader_mind = pre_nukeops[1]
	var/datum/antagonist/nukeop/L = leader_mind.add_antag_datum(leader_antag_datum_type)
	nuke_team = L.nuke_team
	//Assign the remaining operatives
	for(var/i = 2 to pre_nukeops.len)
		var/datum/mind/nuke_mind = pre_nukeops[i]
		nuke_mind.add_antag_datum(operative_antag_datum_type)
	return ..()

/datum/game_mode/nuclear/OnNukeExplosion(off_station)
	..()
	nukes_left--

/datum/game_mode/nuclear/check_win()
	if (nukes_left == 0)
		return TRUE
	return ..()

/datum/game_mode/nuclear/check_finished()
	//Keep the round going if ops are dead but bomb is ticking.
	if(nuke_team.operatives_dead())
		for(var/obj/machinery/nuclearbomb/N in GLOB.nuke_list)
			if(N.proper_bomb && (N.timing || N.exploding))
				return FALSE
	return ..()

/datum/game_mode/nuclear/set_round_result()
	..()
	var result = nuke_team.get_result()
	switch(result)
		if(NUKE_RESULT_FLUKE)
			SSticker.mode_result = "loss - syndicate nuked - disk secured"
			SSticker.news_report = NUKE_SYNDICATE_BASE
		if(NUKE_RESULT_NUKE_WIN)
			SSticker.mode_result = "win - syndicate nuke"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_NOSURVIVORS)
			SSticker.mode_result = "halfwin - syndicate nuke - did not evacuate in time"
			SSticker.news_report = STATION_NUKED
		if(NUKE_RESULT_WRONG_STATION)
			SSticker.mode_result = "halfwin - blew wrong station"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			SSticker.mode_result = "halfwin - blew wrong station - did not evacuate in time"
			SSticker.news_report = NUKE_MISS
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			SSticker.mode_result = "loss - evacuation - disk secured - syndi team dead"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_CREW_WIN)
			SSticker.mode_result = "loss - evacuation - disk secured"
			SSticker.news_report = OPERATIVES_KILLED
		if(NUKE_RESULT_DISK_LOST)
			SSticker.mode_result = "halfwin - evacuation - disk not secured"
			SSticker.news_report = OPERATIVE_SKIRMISH
		if(NUKE_RESULT_DISK_STOLEN)
			SSticker.mode_result = "halfwin - detonation averted"
			SSticker.news_report = OPERATIVE_SKIRMISH
		else
			SSticker.mode_result = "halfwin - interrupted"
			SSticker.news_report = OPERATIVE_SKIRMISH

/datum/game_mode/nuclear/generate_report()
	return "Jeden ze szlaków handlowych Centrali został niedawno zaatakowany przez kosmicznych piratów. Szukali oni jednego statku - przewoził on broń atomową o dalekim rażeniu. Nasz wywiad ustalił, że po kilku transakcjach prawdopodobnie ładunek trafił w ręce Syndykatu. Sama bomba jest bezużyteczna bez kodu oraz dysku autoryzacyjnego. Kod został prawdopodobnie szybko znaleziony, lecz dysku nie było na pokładzie, a wasza stacja posiada jeden taki dysk. Istnieje możliwość, że spróbują oni zaatakować stację w celu jego zdobycia oraz użycia broni jądrowej na waszej stacji. Upewnijcie się, że dysk jest chroniony oraz bądźcie przygotowani na abordaż,"


/proc/is_nuclear_operative(mob/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/nukeop)

/datum/outfit/syndicate
	name = "Syndicate Operative - Basic"

	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/fireproof
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/pinpointer/nuke/syndicate
	id = /obj/item/card/id/syndicate
	belt = /obj/item/gun/ballistic/automatic/pistol
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
		/obj/item/kitchen/knife/combat/survival)

	var/tc = 25
	var/command_radio = FALSE
	var/uplink_type = /obj/item/uplink/nuclear


/datum/outfit/syndicate/leader
	name = "Syndicate Leader - Basic"
	id = /obj/item/card/id/syndicate/nuke_leader
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	r_hand = /obj/item/nuclear_challenge
	command_radio = TRUE

/datum/outfit/syndicate/no_crystals
	name = "Syndicate Operative - Reinforcement"
	tc = 0

/datum/outfit/syndicate/post_equip(mob/living/carbon/human/H)
	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_SYNDICATE)
	R.freqlock = TRUE
	if(command_radio)
		R.command = TRUE

	if(ispath(uplink_type, /obj/item/uplink/nuclear) || tc) // /obj/item/uplink/nuclear understands 0 tc
		var/obj/item/U = new uplink_type(H, H.key, tc)
		H.equip_to_slot_or_del(U, SLOT_IN_BACKPACK)

	var/obj/item/implant/explosive/E = new/obj/item/implant/explosive(H)
	E.implant(H)
	var/obj/item/implant/weapons_auth/W = new/obj/item/implant/weapons_auth(H)
	W.implant(H)
	H.faction |= ROLE_SYNDICATE
	H.update_icons()

/datum/outfit/syndicate/full
	name = "Syndicate Operative - Full Kit"

	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	internals_slot = SLOT_R_STORE
	belt = /obj/item/storage/belt/military
	r_hand = /obj/item/gun/ballistic/shotgun/bulldog
	backpack_contents = list(/obj/item/storage/box/syndie=1,\
		/obj/item/tank/jetpack/oxygen/harness=1,\
		/obj/item/gun/ballistic/automatic/pistol=1,\
		/obj/item/kitchen/knife/combat/survival)


/datum/game_mode/nuclear/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	if((world.time-SSticker.round_start_time) < (FLUKEOPS_TIME_DELAY)) // If the nukies died super early, they're basically a massive disappointment
		title_icon = "flukeops"

	round_credits += "<center><h1>Operatorzy [syndicate_name()]:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/operative in nuke_team.members)
		round_credits += "<center><h2>[operative.name] jako Operator Specjalny Syndykatu</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>Operatorzy Specjalni Syndykatu wylecieli w powietrze!</h2>", "<center><h2>Ich szczątki nie mogły zostać zidentyfikowane!</h2>")
		round_credits += "<br>"

	round_credits += ..()
	return round_credits
