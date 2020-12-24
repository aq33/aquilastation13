/datum/surgery/gender_reassignment
	name = "gender reassignment"
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_PRECISE_GROIN)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/reshape_genitals,
		/datum/surgery_step/close
		)

//reshape_genitals
/datum/surgery_step/reshape_genitals
	name = "reshape genitals"
	implements = list(/obj/item/scalpel = 100, /obj/item/hatchet = 50, TOOL_WIRECUTTER = 35)
	time = 64

/datum/surgery_step/reshape_genitals/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.gender == FEMALE)
		user.visible_message("<span class='notice'>[user] begins to reshape [target]'s genitals to look more masculine.</span>")
	else
		user.visible_message("<span class='notice'>[user] begins to reshape [target]'s genitals to look more feminine.</span>")

/datum/surgery_step/reshape_genitals/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/H = target	//no type check, as that should be handled by the surgery
	H.gender_ambiguous = 0
	if(target.gender == FEMALE)
		user.visible_message("<span class='notice'>[user] has made a man of [target]!</span>")
		target.gender = MALE
	else
		user.visible_message("<span class='notice'>[user] has made a woman of [target]!</span>")
		target.gender = FEMALE
	target.regenerate_icons()
	return 1

/datum/surgery_step/reshape_genitals/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/H = target
	H.gender_ambiguous = 1
	user.visible_message("<span class='warning'>[user] mutilates [target]'s genitals beyond the point of recognition!</span>")
	target.gender = pick(MALE, FEMALE)
	target.regenerate_icons()
	return 1
