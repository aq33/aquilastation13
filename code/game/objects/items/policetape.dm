//Define all tape types in policetape.dm
/obj/item/stack/taperoll
	name = "tape roll"
	icon = 'icons/obj/policetape.dmi'
	icon_state = "tape"
	w_class = WEIGHT_CLASS_TINY
	amount = 30
	max_amount = 30
	var/turf/start
	var/turf/end
	var/tape_type = /obj/item/tape
	var/icon_base = "tape"

/obj/item/policetape
	name = "police tape"
	icon = 'icons/obj/policetape.dmi'
	icon_state = "tape"
	layer = ABOVE_DOOR_LAYER
	anchored = 1
	var/lifted = 0
	var/crumpled = 0
	var/tape_dir = 0
	var/icon_base = "tape"

/obj/item/policetape/update_icon()
	//Possible directional bitflags: 0 (AIRLOCK), 1 (NORTH), 2 (SOUTH), 4 (EAST), 8 (WEST), 3 (VERTICAL), 12 (HORIZONTAL)
	cut_overlays()
	var/new_state
	switch (tape_dir)
		if(0)  // AIRLOCK
			new_state = "[icon_base]_door[rand(1,8)]"
		if(3)  // VERTICAL
			new_state = "[icon_base]_v"
		if(12) // HORIZONTAL
			new_state = "[icon_base]_h"
		else   // END POINT (1|2|4|8)
			new_state = "[icon_base]_dir"
			dir = tape_dir
	icon_state = "[new_state]_[crumpled]"

/obj/item/stack/taperoll/police
	name = "police tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	tape_type = /obj/item/policetape/police
	color = COLOR_YELLOW

/obj/item/policetape/police
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	req_access = list(ACCESS_SECURITY)
	color = COLOR_YELLOW

/obj/item/stack/taperoll/update_icon()
	cut_overlays()
	var/image/overlay = image(icon = src.icon)
	overlay.appearance_flags = RESET_COLOR
	if(ismob(loc))
		if(!start)
			overlay.icon_state = "start"
		else
			overlay.icon_state = "stop"
		overlays += overlay

/obj/item/stack/taperoll/dropped(mob/user)
	update_icon()
	return ..()

/obj/item/stack/taperoll/pickup(mob/user)
	update_icon()
	return ..()

/obj/item/stack/taperoll/attack_hand()
	update_icon()
	return ..()

/obj/item/stack/taperoll/attack_self(mob/user as mob)
	if(!start)
		start = get_turf(src)
		to_chat(usr, "<span class='notice'>You place the first end of \the [src].</span>")
		update_icon()
	else
		end = get_turf(src)
		if(start.y != end.y && start.x != end.x || start.z != end.z)
			start = null
			update_icon()
			to_chat(usr, "<span class='notice'>\The [src] can only be laid horizontally or vertically.</span>")
			return

		if(start == end)
			// spread tape in all directions, provided there is a wall/window
			var/turf/T
			var/possible_dirs = 0
			for(var/dir in GLOB.cardinals)
				T = get_step(start, dir)
				if(T && T.density)
					possible_dirs += dir
				else
					for(var/obj/structure/window/W in T)
						if(W.fulltile || W.dir == GLOB.reverse_dir[dir])
							possible_dirs += dir
			if(!possible_dirs)
				start = null
				update_icon()
				to_chat(usr, "<span class='notice'>You can't place \the [src] here.</span>")
				return
			if(possible_dirs & (NORTH|SOUTH))
				var/obj/item/policetape/TP = new tape_type(start)
				for(var/dir in list(NORTH, SOUTH))
					if (possible_dirs & dir)
						TP.tape_dir += dir
				TP.update_icon()
			if(possible_dirs & (EAST|WEST))
				var/obj/item/policetape/TP = new tape_type(start)
				for(var/dir in list(EAST, WEST))
					if (possible_dirs & dir)
						TP.tape_dir += dir
				TP.update_icon()
			start = null
			update_icon()
			to_chat(usr, "<span class='notice'>You finish placing \the [src].</span>")
			use(1)
			return

		if(abs(end.x - start.x) && abs(end.x - start.x) + 1 <= amount)
			use(abs(end.x - start.x) + 1)
		else if(abs(end.y - start.y) && abs(end.y - start.y) + 1 <= amount)
			use(abs(end.y - start.y) + 1)
		else
			to_chat(usr, "<span class='notice'>You don't have enough tape!</span>")
			start = null
			update_icon()
			return

		var/turf/cur = start
		var/orientation = get_dir(start, end)
		var/dir = 0
		switch(orientation)
			if(NORTH, SOUTH)	dir = NORTH|SOUTH	// North-South taping
			if(EAST,   WEST)	dir =  EAST|WEST	// East-West taping

		var/can_place = 1
		while (can_place)
			if(cur.density == 1)
				can_place = 0
			else if (istype(cur, /turf/open/space))
				can_place = 0
			else
				for(var/obj/O in cur)
					if(O.density)
						can_place = 0
						break
			if(cur == end)
				break
			cur = get_step_towards(cur,end)
		if (!can_place)
			start = null
			update_icon()
			to_chat(usr, "<span class='warning'>You can't run \the [src] through that!</span>")
			return

		cur = start
		var/tapetest
		var/tape_dir
		while (1)
			tapetest = 0
			tape_dir = dir
			if(cur == start)
				var/turf/T = get_step(start, GLOB.reverse_dir[orientation])
				if(T && !T.density)
					tape_dir = orientation
					for(var/obj/structure/window/W in T)
						if(W.fulltile || W.dir == orientation)
							tape_dir = dir
			else if(cur == end)
				var/turf/T = get_step(end, orientation)
				if(T && !T.density)
					tape_dir = GLOB.reverse_dir[orientation]
					for(var/obj/structure/window/W in T)
						if(W.fulltile || W.dir == GLOB.reverse_dir[orientation])
							tape_dir = dir
			for(var/obj/item/policetape/T in cur)
				if((T.tape_dir == tape_dir) && (T.icon_base == icon_base))
					tapetest = 1
					break
			if(!tapetest)
				var/obj/item/policetape/T = new tape_type(cur)
				T.tape_dir = tape_dir
				T.update_icon()
				if(tape_dir & SOUTH)
					T.layer += 0.1 // Must always show above other tapes
			if(cur == end)
				break
			cur = get_step_towards(cur,end)
		start = null
		update_icon()
		to_chat(usr, "<span class='notice'>You finish placing \the [src].</span>")
		return

/obj/item/stack/taperoll/afterattack(var/atom/A, mob/user as mob, proximity)
	if(!proximity || istype(A, /turf/open/floor))
		return

	if (istype(A, /obj/machinery/door/airlock))
		var/turf/T = get_turf(A)
		var/obj/item/policetape/P = new tape_type(T)
		P.update_icon()
		P.layer = ABOVE_DOOR_LAYER
		to_chat(user, "<span class='notice'>You finish placing \the [src].</span>")
		use(1)

/obj/item/policetape/proc/crumple()
	if(!crumpled)
		crumpled = 1
		update_icon()
		name = "crumpled [name]"
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 30, 1)

/obj/item/policetape/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!lifted && ismob(mover))
		var/mob/M = mover
		add_fingerprint(M)
		if (!allowed(M))	//only select few learn art of not crumpling the tape
			if(M.a_intent == INTENT_HELP)
				return 0
			crumple()
	return ..(mover)

/obj/item/policetape/attackby(obj/item/W as obj, mob/user as mob)
	breaktape(user)

/obj/item/policetape/attack_hand(mob/user as mob)
	if (user.a_intent == INTENT_HELP && src.allowed(user))
		user.visible_message("<span class='notice'>\The [user] lifts \the [src], allowing passage.</span>")
		for(var/obj/item/policetape/T in gettapeline())
			T.lift(100) //~10 seconds
	else
		breaktape(user)

/obj/item/policetape/proc/lift(time)
	lifted = 1
	layer = ABOVE_MOB_LAYER
	spawn(time)
		lifted = 0
		plane = initial(plane)
		layer = initial(layer)

// Returns a list of all tape objects connected to src, including itself.
/obj/item/policetape/proc/gettapeline()
	var/list/dirs = list()
	if(tape_dir & NORTH)
		dirs += NORTH
	if(tape_dir & SOUTH)
		dirs += SOUTH
	if(tape_dir & WEST)
		dirs += WEST
	if(tape_dir & EAST)
		dirs += EAST

	var/list/obj/item/policetape/tapeline = list()
	for (var/obj/item/policetape/T in get_turf(src))
		tapeline += T
	for(var/dir in dirs)
		var/turf/cur = get_step(src, dir)
		var/not_found = 0
		while (!not_found)
			not_found = 1
			for (var/obj/item/policetape/T in cur)
				tapeline += T
				not_found = 0
			cur = get_step(cur, dir)
	return tapeline




/obj/item/policetape/proc/breaktape(mob/user)
	if(user.a_intent == INTENT_HELP)
		to_chat(user, "<span class='warning'>You refrain from breaking \the [src].</span>")
		return
	user.visible_message("<span class='notice'>\The [user] breaks \the [src]!</span>","<span class='notice'>You break \the [src].</span>")
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 30, 1)

	for (var/obj/item/policetape/T in gettapeline())
		if(T == src)
			continue
		if(T.tape_dir & get_dir(T, src))
			qdel(T)

	qdel(src) //TODO: Dropping a trash item holding fibers/fingerprints of all broken tape parts
	return
