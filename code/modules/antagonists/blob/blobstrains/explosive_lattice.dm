//does aoe brute damage when hitting targets, is immune to explosions
/datum/blobstrain/reagent/explosive_lattice
	name = "Взрывная решетка"
	description = "нанесет грубый урон в области вокруг целей."
	effectdesc = "также будет сопротивляться взрывам, но получает повышенный урон от огня и других источников энергии."
	analyzerdescdamage = "Наносит средний грубый урон и наносит урон всем, кто находится рядом с его целями. При смерти споры взрываются."
	analyzerdesceffect = "Обладает высокой устойчивостью к взрывам, но получает повышенный урон от огня и других источников энергии."
	color = "#8B2500"
	complementary_color = "#00668B"
	blobbernaut_message = "лупит"
	message = "Масса лупит меня"
	reagent = /datum/reagent/blob/explosive_lattice

/datum/blobstrain/reagent/explosive_lattice/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_flag == BOMB)
		return 0
	else if(damage_flag != MELEE && damage_flag != BULLET && damage_flag != LASER)
		return damage * 1.5
	return ..()

/datum/blobstrain/reagent/explosive_lattice/on_sporedeath(mob/living/spore)
	var/obj/effect/temp_visual/explosion/fast/effect = new /obj/effect/temp_visual/explosion/fast(get_turf(spore))
	effect.alpha = 150
	for(var/mob/living/actor in orange(get_turf(spore), 1))
		if(ROLE_BLOB in actor.faction) //no friendly fire
			continue
		actor.apply_damage(20, BRUTE, wound_bonus=CANT_WOUND)

/datum/reagent/blob/explosive_lattice
	name = "Взрывная решетка"
	enname = "Explosive Lattice"
	taste_description = "бомба"
	color = "#8B2500"

/datum/reagent/blob/explosive_lattice/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	var/initial_volume = reac_volume
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	if(reac_volume >= 10) //if it's not a spore cloud, bad time incoming
		var/obj/effect/temp_visual/explosion/fast/ex_effect = new /obj/effect/temp_visual/explosion/fast(get_turf(exposed_mob))
		ex_effect.alpha = 150
		for(var/mob/living/nearby_mob in orange(get_turf(exposed_mob), 1))
			if(ROLE_BLOB in nearby_mob.faction) //no friendly fire
				continue
			exposed_mob = nearby_mob
			methods = TOUCH
			reac_volume = initial_volume
			show_message = FALSE
			touch_protection = nearby_mob.get_permeability_protection()
			var/aoe_volume = ..()
			nearby_mob.apply_damage(0.4*aoe_volume, BRUTE, wound_bonus=CANT_WOUND)
		if(exposed_mob)
			exposed_mob.apply_damage(0.6*reac_volume, BRUTE, wound_bonus=CANT_WOUND)
	else
		exposed_mob.apply_damage(0.6*reac_volume, BRUTE, wound_bonus=CANT_WOUND)
