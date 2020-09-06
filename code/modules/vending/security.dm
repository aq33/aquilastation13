/obj/machinery/vending/security
	name = "\improper SecTech"
	desc = "A security equipment vendor."
	product_ads = "Rozstrzaskaj czaszki kapitalistów!;Natłucz trochę głów!;Nie zapomnij - krzywda jest dobra!;Twoje bronie są dokładnie tutaj.;Kajdanki!;Ani drgnij, śmieciu!;Nie tazuj mnie, stary!;Tazuj ich, stary.;A może tak pączka?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	light_color = LIGHT_COLOR_BLUE
	req_access = list(ACCESS_SECURITY)
	products = list(/obj/item/restraints/handcuffs = 8,
					/obj/item/restraints/handcuffs/cable/zipties = 10,
					/obj/item/grenade/flashbang = 4,
					/obj/item/assembly/flash/handheld = 5,
					/obj/item/reagent_containers/food/snacks/donut = 12,
					/obj/item/storage/box/evidence = 6,
					/obj/item/flashlight/seclite = 4,
					/obj/item/holosign_creator/security = 3,
					/obj/item/restraints/legcuffs/bola/energy = 7,
					/obj/item/club = 5,
					/obj/item/stack/taperoll/police = 4)	// AQ EDIT
	contraband = list(/obj/item/clothing/glasses/sunglasses/advanced = 2,
					  /obj/item/storage/fancy/donut_box = 2)
	premium = list(/obj/item/storage/belt/security/webbing = 5,
					/obj/item/storage/backpack/duffelbag/sec/deputy = 4,
				   /obj/item/coin/antagtoken = 1,
				   /obj/item/grenade/barrier = 4,
				   /obj/item/clothing/head/helmet/blueshirt = 1,
				   /obj/item/clothing/suit/armor/vest/blueshirt = 1)
	refill_canister = /obj/item/vending_refill/security
	default_price = 100
	extra_price = 150
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/security/pre_throw(obj/item/I)
	if(istype(I, /obj/item/grenade))
		var/obj/item/grenade/G = I
		G.preprime()
	else if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		F.on = TRUE
		F.update_brightness()

/obj/item/vending_refill/security
	icon_state = "refill_sec"
