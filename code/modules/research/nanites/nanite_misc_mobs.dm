/mob/living/simple_animal/hostile/nanophage
	name = "nanophage"
	desc = "A little drone made of pre-programmed nanites."
	icon_state = "nanophage"
	icon_living = "nanophage"
	icon_dead = "nanophage"
	icon = 'icons/mob/nanophage.dmi'
	gender = NEUTER
	speak_emote = list("states")
	turns_per_move = 0
	melee_damage = 1
	attacktext = "bites"
	attack_sound = 'sound/misc/nanobuzz.ogg'
	response_help  = "shoos"
	response_disarm = "swats away"
	response_harm   = "squashes"
	harm_intent_damage = 10 //you can swat these little guys
	maxHealth = 10
	health = 10
	healable = 0
	spacewalk = TRUE
	faction = list("hostile")
	move_to_delay = 0
	obj_damage = 0
	ventcrawler = VENTCRAWLER_ALWAYS
	environment_smash = ENVIRONMENT_SMASH_NONE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	density = FALSE
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ROBOTIC)
	movement_type = FLYING
	ventcrawler = VENTCRAWLER_ALWAYS
	deathsound = 'sound/misc/nanodead.ogg'
	deathmessage = "dissolves into a fine, metallic dust..."

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	del_on_death = 1

/mob/living/simple_animal/hostile/nanophage/Initialize()
	. = ..()
	AddComponent(/datum/component/swarming)
	addtimer(CALLBACK(src, .proc/death), 15 SECONDS)

/mob/living/simple_animal/hostile/nanophage/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	death()

/mob/living/simple_animal/hostile/nanophage/Life()
	.=..()
	flick("nanophage[rand(1,8)]", src)