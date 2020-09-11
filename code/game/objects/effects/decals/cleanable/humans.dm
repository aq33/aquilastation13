//deprecated, use splatter instead
/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's red and gooey. Perhaps it's the chef's cooking?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	var/is_slippery = FALSE
	var/is_old = FALSE
	var/can_dry = TRUE
	var/dry_timer = null

/obj/effect/decal/cleanable/blood/examine()
	. = ..()
	if(is_old)
		. += "Looks like it's been here a while.  Eew.<br>"

/obj/effect/decal/cleanable/blood/proc/make_old()
	ASSERT(!is_old)
	dry_timer = null
	name = "dried [name]"

	check_slippery()
	is_old = TRUE
	bloodiness = 0
	var/old_alpha = alpha
	color = BLOOD_DRY_COLOR
	alpha = old_alpha

/obj/effect/decal/cleanable/blood/proc/update_dry_timer()
	if(dry_timer != null)
		deltimer(dry_timer)
		dry_timer = null
	if(can_dry && dry_timer == null)
		dry_timer = addtimer(CALLBACK(src, .proc/make_old), BLOOD_DRY_TIME_MINIMUM + bloodiness * BLOOD_DRY_TIME_PER_BLOODINESS, TIMER_STOPPABLE)

/obj/effect/decal/cleanable/blood/proc/check_slippery()
	var/comp = GetComponent(/datum/component/slippery)

	if(is_slippery && !is_old && bloodiness >= BLOOD_SLIPPERY_TRESHOLD)
		if(comp == null)
			AddComponent(/datum/component/slippery, BLOOD_SLIPPERY_KNOCKDOWN, NO_SLIP_WHEN_WALKING)
	else
		if(comp != null)
			qdel(comp)

/obj/effect/decal/cleanable/blood/proc/make_fresh()
	ASSERT(is_old)
	name = initial(name)

	check_slippery()
	is_old = FALSE
	color = initial(color)
	update_dry_timer()

/obj/effect/decal/cleanable/blood/add_bloodiness(var/amount)
	. = ..()
	if(is_old)
		if(amount > 0)
			make_fresh()
	else
		check_slippery()
		update_dry_timer()

/obj/effect/decal/cleanable/blood/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if(isexacttype(src, /obj/effect/decal/cleanable/blood))
		is_slippery = TRUE
	// we revert the is_old values so that asserts in make_* will pass
	// that's because is_old both corresponds to the initial "desired" value, and the "actual" one
	if(is_old && can_dry)
		is_old = FALSE
		make_old()
	else
		is_old = TRUE
		make_fresh()

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	C.add_blood_DNA(return_blood_DNA())
	C.add_bloodiness(bloodiness)
	return ..()

/obj/effect/decal/cleanable/blood/old
	var/list/disease = list()
	is_old = TRUE

/obj/effect/decal/cleanable/blood/old/Initialize(mapload, list/datum/disease/diseases)
	add_blood_DNA(list("Non-human DNA" = random_blood_type()))
	. = ..()
	if(prob(40))
		var/datum/disease/advance/R = new /datum/disease/advance/random(rand(1, 4), rand(4, 9))
		disease += R

/obj/effect/decal/cleanable/blood/old/extrapolator_act(mob/user, var/obj/item/extrapolator/E, scan = TRUE)
	if(!disease.len)
		return FALSE
	if(scan)
		E.scan(src, disease, user)
	else
		E.extrapolate(src, disease, user)
	return TRUE

/obj/effect/decal/cleanable/blood/splatter
	icon_state = "gibbl1"
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")
	is_slippery = TRUE

/obj/effect/decal/cleanable/blood/splatter/add_bloodiness(var/amount)
	var/before = (bloodiness > MAX_SHOE_BLOODINESS / 2)
	. = ..()
	var/after = (bloodiness > MAX_SHOE_BLOODINESS / 2)
	if(before != after)
		if(bloodiness > MAX_SHOE_BLOODINESS / 2)
			icon_state = pick(list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7"))
		else if(bloodiness <= MAX_SHOE_BLOODINESS / 2)
			icon_state = pick(random_icon_states)

/obj/effect/decal/cleanable/blood/tracks
	icon_state = "tracks"
	desc = "They look like tracks left by wheels."
	random_icon_states = null

/obj/effect/decal/cleanable/blood/trail_holder
	name = "bloody trails"
	icon = 'icons/effects/blood.dmi'
	icon_state = null //rendered through overlays
	random_icon_states = null
	desc = "Your instincts say you shouldn't be following these."
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/blood/trail_holder/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	icon = 'icons/effects/blood.dmi'
	icon_state = "gib1"
	layer = LOW_OBJ_LAYER
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	mergeable_decal = FALSE
	is_slippery = TRUE

/obj/effect/decal/cleanable/blood/gibs/examine()
	. = ..()
	if(is_old)
		. += "Space Jesus, why didn't anyone clean this up?<br>"

/obj/effect/decal/cleanable/blood/gibs/make_old()
	. = ..()
	name = "rotten [name]"
	AddComponent(/datum/component/rot/gibs)
	reagents.add_reagent(/datum/reagent/liquidgibs, 5)

/obj/effect/decal/cleanable/blood/gibs/make_fresh()
	. = ..()
	reagents.del_reagent(/datum/reagent/liquidgibs, 5)
	qdel(GetComponent(/datum/component/rot/gibs))

/obj/effect/decal/cleanable/blood/gibs/ex_act(severity, target)
	return

/obj/effect/decal/cleanable/blood/gibs/Crossed(mob/living/L)
	if(istype(L) && has_gravity(loc))
		playsound(loc, 'sound/effects/gib_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 20 : 50, 1)
	. = ..()

/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions)
	set waitfor = FALSE
	var/list/diseases = list()
	SEND_SIGNAL(src, COMSIG_GIBS_STREAK, directions, diseases)
	var/direction = pick(directions)
	for(var/i in 0 to pick(0, 200; 1, 150; 2, 50))
		sleep(2)
		if(i > 0)
			new /obj/effect/decal/cleanable/blood/splatter(loc, diseases)
		if(!step_to(src, get_step(src, direction), 0))
			break

/obj/effect/decal/cleanable/blood/gibs/up
	icon_state = "gibup1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	icon_state = "gibdown1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	icon_state = "gibtorso"
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/torso
	icon_state = "gibtorso"
	random_icon_states = null

/obj/effect/decal/cleanable/blood/gibs/limb
	icon_state = "gibleg"
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	icon_state = "gibmid1"
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

/obj/effect/decal/cleanable/blood/gibs/old
	var/list/disease = list()
	is_old = TRUE

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	setDir(pick(1,2,4,8))
	add_blood_DNA(list("Non-human DNA" = random_blood_type()))
	if(prob(50))
		var/datum/disease/advance/R = new /datum/disease/advance/random(rand(1, 6), rand(5, 9))
		disease += R

/obj/effect/decal/cleanable/blood/gibs/old/extrapolator_act(mob/user, var/obj/item/extrapolator/E, scan = TRUE)
	if(!disease.len)
		return FALSE
	if(scan)
		E.scan(src, disease, user)
	else
		E.extrapolate(src, disease, user)
	return TRUE

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	icon_state = "drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	bloodiness = 0
	var/drips = 1

/obj/effect/decal/cleanable/blood/drip/can_bloodcrawl_in()
	return TRUE

//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/blood/footprints
	name = "footprints"
	icon = 'icons/effects/footprints.dmi'
	icon_state = null //rendered through overlays
	random_icon_states = null
	desc = "WHOSE FOOTPRINTS ARE THESE?"
	blood_state = BLOOD_STATE_HUMAN //the icon state to load images from
	var/entered_dirs = 0
	var/exited_dirs = 0
	var/list/shoe_types = list()

/obj/effect/decal/cleanable/blood/footprints/Crossed(atom/movable/O)
	..()
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/shoes/S = H.shoes
		if(S && S.bloody_shoes[blood_state])
			S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			shoe_types |= S.type
			if (!(entered_dirs & H.dir))
				entered_dirs |= H.dir
				update_icon()

/obj/effect/decal/cleanable/blood/footprints/Uncrossed(atom/movable/O)
	..()
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/shoes/S = H.shoes
		if(S && S.bloody_shoes[blood_state])
			S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			shoe_types |= S.type
			if (!(exited_dirs & H.dir))
				exited_dirs |= H.dir
				update_icon()

/obj/effect/decal/cleanable/blood/footprints/update_icon()
	cut_overlays()

	for(var/Ddir in GLOB.cardinals)
		if(entered_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["entered-[blood_state]-[Ddir]"]
			if(!bloodstep_overlay)
				bloodstep_overlay = image(icon, "[blood_state]1", dir = Ddir)
				GLOB.bloody_footprints_cache["entered-[blood_state]-[Ddir]"] = bloodstep_overlay
			add_overlay(bloodstep_overlay)
		if(exited_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["exited-[blood_state]-[Ddir]"]
			if(!bloodstep_overlay)
				bloodstep_overlay = image(icon, "[blood_state]2", dir = Ddir)
				GLOB.bloody_footprints_cache["exited-[blood_state]-[Ddir]"] = bloodstep_overlay
			add_overlay(bloodstep_overlay)

	alpha = BLOODY_FOOTPRINT_BASE_ALPHA+bloodiness


/obj/effect/decal/cleanable/blood/footprints/examine(mob/user)
	. = ..()
	if(shoe_types.len)
		. += "You recognise the footprints as belonging to:\n"
		for(var/shoe in shoe_types)
			var/obj/item/clothing/shoes/S = shoe
			. += "[icon2html(initial(S.icon), user)] Some <B>[initial(S.name)]</B>.\n"

/obj/effect/decal/cleanable/blood/footprints/replace_decal(obj/effect/decal/cleanable/C)
	if(blood_state != C.blood_state) //We only replace footprints of the same type as us
		return
	..()

/obj/effect/decal/cleanable/blood/footprints/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return 1
	return 0

/obj/effect/decal/cleanable/blood/wallsplatter
	icon_state = "gibbl1"
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5") //te rzeczy można zmienić na coś bardziej pasującego
	plane = -1

/obj/effect/decal/cleanable/blood/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon = 'icons/effects/blood.dmi'
	icon_state = "hitsplatter1"
	random_icon_states = list("hitsplatter1", "hitsplatter2", "hitsplatter3")
	var/turf/prev_loc
	var/mob/living/blood_source
	var/skip = FALSE //Skip creation of blood when destroyed?
	var/amount = 3

/obj/effect/decal/cleanable/blood/hitsplatter/Initialize(mapload, blood)
	. = ..()
	if(blood)
		blood_source = blood
	prev_loc = loc //Just so we are sure prev_loc exists

/obj/effect/decal/cleanable/blood/hitsplatter/proc/GoTo(turf/T, var/range)
	for(var/i in 1 to range)
		step_towards(src,T)
		sleep(1)
		prev_loc = loc
		for(var/atom/A in get_turf(src))
			if(istype(A,/obj/item))
				var/obj/item/I = A
				I.add_mob_blood(blood_source)
				amount--
			if(istype(A, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = A
				if(H.wear_suit)
					H.wear_suit.add_mob_blood(blood_source)
					H.update_inv_wear_suit()    //updates mob overlays to show the new blood (no refresh)
				if(H.w_uniform)
					H.w_uniform.add_mob_blood(blood_source)
					H.update_inv_w_uniform()    //updates mob overlays to show the new blood (no refresh)
				amount--
		if(!amount) // we used all the puff so we delete it.
			qdel(src)
			break
	qdel(src)

/obj/effect/decal/cleanable/blood/hitsplatter/Bump(atom/A)
	if(istype(A, /turf/closed/wall))
		if(istype(prev_loc)) //var definition already checks for type
			loc = A
			skip = TRUE
			var/mob/living/carbon/human/H = blood_source
			if(istype(H))
				var/obj/effect/decal/cleanable/blood/wallsplatter/B = new(prev_loc)
				//Adjust pixel offset to make splatters appear on the wall
				if(istype(B))
					B.pixel_x = (dir == EAST ? 32 : (dir == WEST ? -32 : 0))
					B.pixel_y = (dir == NORTH ? 32 : (dir == SOUTH ? -32 : 0))
		else //This will only happen if prev_loc is not even a turf, which is highly unlikely.
			loc = A //Either way we got this.
			QDEL_IN(src, 3)
	qdel(src)

/obj/effect/decal/cleanable/blood/hitsplatter/Destroy()
	if(istype(loc, /turf) && !skip)
		loc.add_mob_blood(blood_source)
	return ..()
