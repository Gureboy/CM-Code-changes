#define LIFE_THRESHOLD 0.25 // 25%

/mob/living/simple_animal/hostile/creature
    name = "creature"
    desc = "A sanity-destroying otherthing."
    icon = 'icons/mob/critter.dmi'
    speak_emote = list("gibbers")
    icon_state = "otherthing"  
    icon_living = "otherthing"
    icon_dead = "otherthing-dead"
    health = 350
    maxHealth = 350
    melee_damage_lower = 25
    melee_damage_upper = 50
    attack_sound = 'sound/effects/attackblob.ogg'
    faction = "creature"
    speed = 4

    // Infection system variables
    var/infection_chance = 30
    var/datum/disease/addiction/creature_infection
    var/regen_amount = 15
    var/datum/effects/heal_over_time/heal_effect
    var/datum/xeno_shield/hedgehog_shield/hedgehog_shield_instance

    // Initialization for infection and regeneration when the creature is created
    New()
        ..()
        InitializeInfection()

    // Configure the infection using /datum/disease/addiction
    proc/InitializeInfection()
        if (!creature_infection)
            creature_infection = new /datum/disease/addiction
            creature_infection.name = "Eldritch Compulsion"
            creature_infection.description = "A creeping madness, a terrifying compulsion birthed from incomprehensible horrors."
            creature_infection.stages = list(
                list(
                    name = "The Whisper of Madness",
                    message = "A strange compulsion gnaws at your sanity... as if the creature's presence invades your mind.",
                    symptoms = list(/datum/symptom/shivering, /datum/symptom/cough)
                ),
                list(
                    name = "The Unraveling",
                    message = "Your mind begins to unravel, consumed by thoughts of the creature... and the darkness that follows.",
                    symptoms = list(/datum/symptom/hallucigen)
                )
            )
            creature_infection.addiction_rate = 0.1

    // Handle attack logic for infection and regeneration
    attack_hand(mob/living/carbon/human/target)
        ..()
        if (!target || target.stat == DEAD)
            return

        // Attempt to infect the target with a certain probability
        if (prob(infection_chance))
            InfectTarget(target)

        // Trigger regeneration
        ApplyRegeneration()

        // Activate hedgehog shield if health drops below the threshold
        if (health <= maxHealth * LIFE_THRESHOLD && !hedgehog_shield_instance)
            ActivateHedgehogShield()

    // Infect the target with the creature's disease
    proc/InfectTarget(mob/living/carbon/human/target)
        if (!target || target.stat == DEAD)
            return

        if (target.has_disease(creature_infection))
            return

        if (creature_infection)
            target.addiction = creature_infection
            target.addiction_stage = 1
            target.visible_message("[creature_infection.description]")
            src.visible_message("[target.name] has been touched by the eldritch horrors of [src.name]!")
            target.visible_message("[target.name] seems to wither under the weight of a mind-shattering force...")

        target.play_sound('sound/items/hypospray.ogg')

        // Trigger blob spawn
        SpawnBlob()

    // Apply regeneration to the creature
    proc/ApplyRegeneration()
        if (!heal_effect)
            heal_effect = new /datum/effects/heal_over_time(src, regen_amount, 5, 1)
        else
            heal_effect.total_heal_amount += regen_amount
        heal_effect.start()

    // Activate the hedgehog shield
    proc/ActivateHedgehogShield()
        if (!hedgehog_shield_instance)
            hedgehog_shield_instance = new /datum/xeno_shield/hedgehog_shield
            hedgehog_shield_instance.owner = src
            hedgehog_shield_instance.ammo_type = /datum/ammo/bullet/shrapnel/incendiary
            src.visible_message("As the creature's life fades, a horrific, chaotic shield activates... incendiary shrapnel tears the air, a sign of doom from beyond the void.")
            src.play_sound('sound/bullets/rocket_ricochet3.ogg')

    // Trigger the appearance of the blob
    proc/SpawnBlob()
        var/blob = new /obj/effect/blob(src.loc)
        blob.Initialize()
        src.visible_message("An eldritch blob begins to pulse unnaturally on [src.name]! The horror intensifies!")

// Define the blob class
/obj/effect/blob
    name = "eldritch blob"
    desc = "A pulsating mass of unnatural horrors."
    icon_state = "blob"
    var/amount_grown = 0

    // Initialize the blob
    Initialize()
        pixel_x = rand(3, -3)
        pixel_y = rand(3, -3)
        START_PROCESSING(SSobj, src)

    // Destroy the blob
    Destroy()
        STOP_PROCESSING(SSobj, src)
        return ..()

    // Blob growth process
    process()
        amount_grown += rand(0, 2)
        if (amount_grown >= 100)
            // 5-minute growth leads to a chance of spawning two creatures
            var/num_creatures = prob(50) ? 2 : 1
            for (var/i = 0, i < num_creatures, i++)
                var/new_creature = new /mob/living/simple_animal/hostile/creature
                new_creature.loc = src.loc
                new_creature.icon_state = "otherthing"
            qdel(src)
