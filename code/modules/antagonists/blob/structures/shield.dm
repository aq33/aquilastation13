/obj/structure/blob/shield
	name = "gęsty grzyb"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_shield"
	desc = "Solidna ściana lekko drgających zgrzybiałych pnączy."
	var/damaged_desc = "Ściana lekko drgających zgrzybiałych pnączy."
	max_integrity = 150
	brute_resist = 0.25
	explosion_block = 3
	point_return = 4
	atmosblock = TRUE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90, "stamina" = 0)

/obj/structure/blob/shield/scannerreport()
	if(atmosblock)
		return "Zapobiega rozprzestrzenianiu się zmian w atmosferze."
	return "N/A"

/obj/structure/blob/shield/core
	point_return = 0

/obj/structure/blob/shield/update_icon()
	..()
	if(obj_integrity < max_integrity * 0.5)
		icon_state = "[initial(icon_state)]_damaged"
		name = "weakened [initial(name)]"
		desc = "[damaged_desc]"
		atmosblock = FALSE
	else
		icon_state = initial(icon_state)
		name = initial(name)
		desc = initial(desc)
		atmosblock = TRUE
	air_update_turf(1)

/obj/structure/blob/shield/reflective
	name = "lustrzany grzyb"
	desc = "Solidna ściana lekko drgających zgrzybiałych pnączy z odbijającym światło połyskiem."
	damaged_desc = "Ściana lekko drgających zgrzybiałych pnączy z odbijającym światło połyskiem."
	icon_state = "blob_glow"
	flags_1 = CHECK_RICOCHET_1
	point_return = 8
	max_integrity = 100
	brute_resist = 0.5
	explosion_block = 2

/obj/structure/blob/shield/reflective/handle_ricochet(obj/item/projectile/P)
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	if(abs(incidence_s) > 90 && abs(incidence_s) < 270)
		return FALSE
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.setAngle(new_angle_s)
	if(!(P.reflectable & REFLECT_FAKEPROJECTILE))
		visible_message("<span class='warning'>[P] odbija się od [src]!</span>")
	return TRUE

