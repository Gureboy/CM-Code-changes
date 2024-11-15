// Define the constant for the life threshold (25%)
#define LIFE_THRESHOLD 0.25 // 25%

/mob/living/simple_animal/hostile/creature
    name = "creature"
    desc = "An abomination from beyond the stars, with a twisted form and incomprehensible will."
    icon = 'icons/mob/critter.dmi'
    speak_emote = list("gibbers incomprehensibly")
    icon_state = "otherthing"
    icon_living = "otherthing"
    icon_dead = "otherthing-dead"
    health = 200
    maxHealth = 200
    melee_damage_lower = 25
    melee_damage_upper = 50
    attacktext = "chomps with a horrible, unnatural motion"
    attack_sound = 'sound/effects/attackblob.ogg'
    faction = "creature"
    speed = 4

    // Variables for the infection system
    var/infection_chance = 30
    var/datum/disease/addiction/creature_infection
    var/regen_amount = 15
    var/datum/effects/heal_over_time/heal_effect
    var/datum/xeno_shield/hedgehog_shield/hedgehog_shield_instance

    // Initialize disease and regeneration when the creature is created
    New()
        ..()
        InitializeInfection()

    // Set up the infection using /datum/disease/addiction
    proc/InitializeInfection()
        if(!creature_infection)
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

    // Attack handler to spread infection and activate regeneration
    attack_hand(mob/living/carbon/human/target)
        ..()
        if(!target || target.stat == DEAD)
            return

        // Attempt to infect the target with a certain probability
        if(prob(infection_chance))
            InfectTarget(target)

        // Activate regeneration effect on itself
        ApplyRegeneration()

        // Activate the hedgehog_shield if the creature's life is at or below 25%
        if(health <= maxHealth * LIFE_THRESHOLD && !hedgehog_shield_instance)
            ActivateHedgehogShield()

    // Method to infect the target with the disease
    proc/InfectTarget(mob/living/carbon/human/target)
        if(!target || target.stat == DEAD)
            return

        if(target.has_disease(creature_infection))
            return

        if(creature_infection)
            target.addiction = creature_infection
            target.addiction_stage = 1
            to_chat(target, "[creature_infection.description]")
            to_chat(world, "[target.name] has been touched by the eldritch horrors of [src.name]!")
            target.visible_message("[target.name] seems to wither under the weight of a mind-shattering force...")

        target.play_sound('sound/items/hypospray.ogg')

    // Method to apply regeneration to the creature
    proc/ApplyRegeneration()
        if(!heal_effect)
            heal_effect = new /datum/effects/heal_over_time(src, regen_amount, 5, 1)
        else
            heal_effect.total_heal_amount += regen_amount
        heal_effect.start()

    // Activate the hedgehog_shield when the life reaches 25% or lower
    proc/ActivateHedgehogShield()
        if(!hedgehog_shield_instance)
            hedgehog_shield_instance = new /datum/xeno_shield/hedgehog_shield
            hedgehog_shield_instance.owner = src // Set the creature as the owner of the shield
            src.visible_message("As the creature's life fades, a horrific, chaotic shield activates... shrapnel tears the air, a sign of doom from beyond the void.")
            src.play_sound('sound/bullets/rocket_ricochet3.ogg')
