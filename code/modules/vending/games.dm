/obj/machinery/vending/games
	name = "\improper Good Clean Fun"
	desc = "Vends things that the Captain and Head of Personnel are probably not going to appreciate you fiddling with instead of your job..."
	product_ads = "Ucieknij w świat fantasy!;Napędź swoje uzależnienie od hazardu!;Zniszcz swoje przyjaźnie!;Rzut za inicjatywę!;Elfy i krasnoludy!;Paranoiczne komputery!;Wcale nie satanistyczne!;Zabawa na wieki!"
	icon_state = "games"
	light_color = LIGHT_COLOR_ORANGE
	products = list(/obj/item/toy/cards/deck = 5,
		            /obj/item/storage/pill_bottle/dice = 10,
					/obj/item/storage/box/yatzy = 3,
		            /obj/item/toy/cards/deck/cas = 3,
		            /obj/item/toy/cards/deck/cas/black = 3,
		            /obj/item/toy/cards/deck/unum = 3,
					/obj/item/hourglass = 2)
	contraband = list(/obj/item/dice/fudge = 9)
	premium = list(/obj/item/melee/skateboard/pro = 3,
					/obj/item/melee/skateboard/hoverboard = 1)
	refill_canister = /obj/item/vending_refill/games
	default_price = 10
	extra_price = 25
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/games
	machine_name = "\improper Good Clean Fun"
	icon_state = "refill_games"
