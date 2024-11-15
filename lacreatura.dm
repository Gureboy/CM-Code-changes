/mob/living/simple_animal/hostile/creature
    name = "creature"
    desc = "A sanity-destroying otherthing."
    icon = 'icons/mob/critter.dmi'
    speak_emote = list("gibbers")
    icon_state = "otherthing"
    icon_living = "otherthing"
    icon_dead = "otherthing-dead"
    health = 200
    maxHealth = 200
    melee_damage_lower = 25
    melee_damage_upper = 50
    attacktext = "chomps"
    attack_sound = 'sound/effects/attackblob.ogg'
    faction = "creature"
    speed = 4

    // Variables for the infection system
    var/infection_chance = 30 // Percentage chance to infect the target
    var/datum/disease/addiction/creature_infection // The disease that will be applied

    // Initialize the disease upon creature creation
    New()
        ..()
        InitializeInfection()

    // Setup the infection using /datum/disease/addiction
    proc/InitializeInfection()
        // Create a new instance of the addiction disease
        if(!creature_infection)
            creature_infection = new /datum/disease/addiction
            creature_infection.name = "Creature Infection"
            creature_infection.description = "A strange compulsion induced by contact with the creature."
            creature_infection.stages = list(
                list(
                    name = "Mild Compulsion",
                    message = "You feel an unnatural craving...",
                    symptoms = list(/datum/symptom/shivering, /datum/symptom/cough)
                ),
                list(
                    name = "Severe Compulsion",
                    message = "Your mind is consumed by thoughts of the creature!",
                    symptoms = list(/datum/symptom/hallucigen)
                )
            )
            creature_infection.addiction_rate = 0.1 // Speed at which addiction progresses

    // Attack handler to spread infection
    attack_hand(mob/living/carbon/human/target)
        ..() // Call base method to apply damage
        if(!target || target.stat == DEAD)
            return

        // Attempt to infect the target with a specified probability
        if(prob(infection_chance))
            InfectTarget(target)

    // Method to infect the target with the disease
    proc/InfectTarget(mob/living/carbon/human/target)
        if(!target || target.stat == DEAD)
            return

        // Check if already infected to avoid duplication
        if(target.has_disease(creature_infection))
            return

        // Infect the target with the custom addiction disease
        if(creature_infection)
            target.addiction = creature_infection // Assign the addiction to the target
            target.addiction_stage = 1 // Start at the first stage
            to_chat(target, "[creature_infection.description]")
            to_chat(world, "[target.name] has been infected by [src.name]!")
            target.visible_message("[target.name] looks visibly distressed.")

        // Visual and sound effect upon infection
        target.play_sound('sound/items/hypospray.ogg')
