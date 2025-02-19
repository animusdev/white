#define ELECTROLYZER_MODE_STANDBY	"standby"
#define ELECTROLYZER_MODE_WORKING	"working"

/obj/machinery/electrolyzer
	anchored = FALSE
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN
	icon = 'icons/obj/atmos.dmi'
	icon_state = "electrolyzer-off"
	name = "электролизер"
	desc = "Благодаря быстрому и динамическому реагированию наших электролизеров производство водорода на месте гарантировано. Гарантия недействительна при использовании клоунами."
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 100, FIRE = 80, ACID = 10)
	circuit = /obj/item/circuitboard/machine/electrolyzer
	/// We don't use area power, we always use the cell
	use_power = NO_POWER_USE
	///used to check if there is a cell in the machine
	var/obj/item/stock_parts/cell/cell
	///check if the machine is on or off
	var/on = FALSE
	///check what mode the machine should be (WORKING, STANDBY)
	var/mode = ELECTROLYZER_MODE_STANDBY
	///Increase the amount of moles worked on, changed by upgrading the manipulator tier
	var/workingPower = 1
	///Decrease the amount of power usage, changed by upgrading the capacitor tier
	var/efficiency = 0.5

/obj/machinery/electrolyzer/get_cell()
	return cell

/obj/machinery/electrolyzer/Initialize()
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	update_icon()

/obj/machinery/electrolyzer/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

/obj/machinery/electrolyzer/on_deconstruction()
	if(cell)
		LAZYADD(component_parts, cell)
		cell = null
	return ..()

/obj/machinery/electrolyzer/examine(mob/user)
	. = ..()
	. += "<hr>"
	. += "<b>[src.name]</b> [on ? "работает" : "не работает"] и техническая панель [panel_open ? "открыта" : "закрыта"]."

	if(cell)
		. += "<hr>Заряд: [cell ? round(cell.percent(), 1) : 0]%."
	else
		. += "<hr>Внутри нет батарейки."

/obj/machinery/electrolyzer/update_icon_state()
	icon_state = "electrolyzer-[on ? "[mode]" : "off"]"

/obj/machinery/electrolyzer/update_overlays()
	. = ..()

	if(panel_open)
		. += "electrolyzer-open"

/obj/machinery/electrolyzer/process(delta_time)
	if(!is_operational && on)
		on = FALSE
	if(!on)
		return PROCESS_KILL

	if(!cell || cell.charge <= 0)
		on = FALSE
		update_icon()
		return PROCESS_KILL

	var/turf/L = loc
	if(!istype(L))
		if(mode != ELECTROLYZER_MODE_STANDBY)
			mode = ELECTROLYZER_MODE_STANDBY
			update_icon()
		return

	var/newMode = on ? ELECTROLYZER_MODE_WORKING : ELECTROLYZER_MODE_STANDBY //change the mode to working if the machine is on

	if(mode != newMode) //check if the mode is set correctly
		mode = newMode
		update_icon()

	if(mode == ELECTROLYZER_MODE_STANDBY)
		return

	var/datum/gas_mixture/env = L.return_air() //get air from the turf
	var/datum/gas_mixture/removed = env.remove(0.1 * env.total_moles())

	if(!removed)
		return
	var/proportion = min(removed.get_moles(GAS_H2O), (1.5 * delta_time * workingPower))//Works to max 12 moles at a time.
	removed.adjust_moles(GAS_H2O, -proportion * 2 * workingPower)
	removed.adjust_moles(GAS_O2, proportion * workingPower)
	removed.adjust_moles(GAS_HYDROGEN, proportion * 2 * workingPower)
	env.merge(removed) //put back the new gases in the turf
	air_update_turf()
	cell.use((5 * proportion * workingPower) / (efficiency + workingPower))

/obj/machinery/electrolyzer/RefreshParts()
	. = ..()
	var/manipulator = 0
	var/cap = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		manipulator += M.rating
	for(var/obj/item/stock_parts/capacitor/M in component_parts)
		cap += M.rating

	workingPower = manipulator //used in the amount of moles processed

	efficiency = (cap + 1) * 0.5 //used in the amount of charge in power cell uses

/obj/machinery/electrolyzer/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, I))
		return
	if(istype(I, /obj/item/stock_parts/cell))
		if(!panel_open)
			to_chat(user, span_warning("Техническая панель должна быть открыта для вставки батарейки!"))
			return
		if(cell)
			to_chat(user, span_warning("Внутри уже есть батарейка!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		cell = I
		I.add_fingerprint(usr)

		user.visible_message(span_notice("[capitalize(user)] вставляет батарейку в <b>[src.name]</b>.") , span_notice("Вставляю батарейку внутрь <b>[src.name]</b>."))
		SStgui.update_uis(src)

		return
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		panel_open = !panel_open
		user.visible_message(span_notice("[capitalize(user)] [panel_open ? "открывает" : "закрывает"] техническую панель <b>[src.name]</b>.") , span_notice("[panel_open ? "Открываю" : "Закрываю"] техническую панель <b>[src.name]</b>."))
		update_icon()
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/electrolyzer/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/electrolyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Electrolyzer", name)
		ui.open()

/obj/machinery/electrolyzer/ui_data()
	var/list/data = list()
	data["open"] = panel_open
	data["on"] = on
	data["hasPowercell"] = !isnull(cell)
	if(cell)
		data["powerLevel"] = round(cell.percent(), 1)
	return data

/obj/machinery/electrolyzer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			mode = ELECTROLYZER_MODE_STANDBY
			usr.visible_message(span_notice("[usr] [on ? "включает" : "выключает"] <b>[src.name]</b>.") , span_notice("[on ? "Включаю" : "Выключаю"] <b>[src.name]</b>."))
			update_icon()
			if (on)
				START_PROCESSING(SSmachines, src)
			. = TRUE
		if("eject")
			if(panel_open && cell)
				cell.forceMove(drop_location())
				cell = null
				. = TRUE

#undef ELECTROLYZER_MODE_STANDBY
#undef ELECTROLYZER_MODE_WORKING
