/mob/living/proc/check_devil_bane_multiplier(obj/item/weapon, mob/living/attacker)
	var/datum/antagonist/devil/devilInfo = mind.has_antag_datum(/datum/antagonist/devil)
	switch(devilInfo.bane)
		if(BANE_WHITECLOTHES)
			if(ishuman(attacker))
				var/mob/living/carbon/human/H = attacker
				if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under))
					var/obj/item/clothing/under/U = H.w_uniform
					var/static/list/whiteness = list (
						/obj/item/clothing/under/color/white = 2,
						/obj/item/clothing/under/rank/civilian/bartender = 1,
						/obj/item/clothing/under/rank/civilian/chef = 1,
						/obj/item/clothing/under/rank/engineering/chief_engineer = 1,
						/obj/item/clothing/under/rank/rnd/scientist = 1,
						/obj/item/clothing/under/rank/medical/chemist = 1,
						/obj/item/clothing/under/rank/medical/chief_medical_officer = 1,
						/obj/item/clothing/under/rank/rnd/geneticist = 1,
						/obj/item/clothing/under/rank/medical/virologist = 1,
						/obj/item/clothing/under/rank/medical/doctor/nurse = 1,
						/obj/item/clothing/under/rank/medical/doctor = 1,
						/obj/item/clothing/under/rank/security/detective = 1,
						/obj/item/clothing/under/suit/white = 0.5,
						/obj/item/clothing/under/misc/burial = 1
					)
					if(U && whiteness[U.type])
						src.visible_message(span_warning("[src], похоже, страдает из-за чистоты одежды [attacker].") , span_notice("Безупречно белая одежда портит ваш вид."))
						return whiteness[U.type] + 1
		if(BANE_TOOLBOX)
			if(istype(weapon, /obj/item/storage/toolbox))
				src.visible_message(span_warning("[weapon] кажется необычайно надежным.") , span_notice("[weapon] - это ваша смерть!"))
				return 2.5 // Will take four hits with a normal toolbox to crit.
	return 1
