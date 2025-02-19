//Soul counter is stored with the humans, it does weird when you place it here apparently...

/datum/hud/devil/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drone_drop
	using.hud = src
	static_inventory += using

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_drone_pull
	pull_icon.hud = src
	static_inventory += pull_icon

	build_hand_slots()

	using = new /atom/movable/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1_m"
	using.screen_loc = ui_swaphand_position(owner,1)
	using.hud = src
	static_inventory += using

	using = new /atom/movable/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand_position(owner,2)
	using.hud = src
	static_inventory += using

	zone_select = new /atom/movable/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.hud = src
	zone_select.update_icon()

	lingchemdisplay = new /atom/movable/screen/ling/chems()
	lingchemdisplay.hud = src

	devilsouldisplay = new /atom/movable/screen/devil/soul_counter
	devilsouldisplay.hud = src
	infodisplay += devilsouldisplay


/datum/hud/devil/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/true_devil/D = mymob

	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in D.held_items)
			I.screen_loc = ui_hand_position(D.get_held_index_of_item(I))
			D.client.screen += I
	else
		for(var/obj/item/I in D.held_items)
			I.screen_loc = null
			D.client.screen -= I
