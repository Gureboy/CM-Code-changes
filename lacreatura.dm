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

    // Variables para el sistema de infección
    var/infection_chance = 30 // Porcentaje de probabilidad de infectar al objetivo
    var/datum/disease/addiction/creature_infection // La enfermedad que se aplicará

    // Inicializar la enfermedad al instanciar la criatura
    New()
        ..()
        InitializeInfection()

    // Configurar la infección utilizando /datum/disease/addiction
    proc/InitializeInfection()
        // Crear una nueva instancia de la enfermedad de adicción
        if(!creature_infection)
            creature_infection = new /datum/disease/addiction
            creature_infection.name = "Creature Infection"
            creature_infection.description = "A strange compulsion induced by contact with the creature."
            creature_infection.stages = list(
                list(
                    name = "Mild Compulsion",
                    message = "You feel an unnatural craving...",
                    symptoms = list(/datum/symptom/shivering)
                ),
                list(
                    name = "Severe Compulsion",
                    message = "Your mind is consumed by thoughts of the creature!",
                    symptoms = list(/datum/symptom/hallucigen)
                )
            )
            creature_infection.addiction_rate = 0.1 // Velocidad a la que progresa la adicción

    // Manejador de ataque para propagar la infección
    attack_hand(mob/living/carbon/human/target)
        ..() // Llama al método base para aplicar daño
        if(!target || target.stat == DEAD)
            return

        // Intentar infectar al objetivo con una probabilidad determinada
        if(prob(infection_chance))
            InfectTarget(target)

    // Método para infectar al objetivo con la enfermedad
    proc/InfectTarget(mob/living/carbon/human/target)
        if(!target || target.stat == DEAD)
            return

        // Comprobar si ya está infectado para evitar duplicación
        if(target.has_disease(creature_infection))
            return

        // Infectar al objetivo con la adicción personalizada
        if(creature_infection)
            target.addiction = creature_infection // Asigna la adicción al objetivo
            target.addiction_stage = 1 // Comienza en la primera etapa
            to_chat(target, "[creature_infection.description]")
            to_chat(world, "[target.name] ha sido infectado por [src.name]!")
            target.visible_message("[target.name] looks visibly distressed.")

        // Efecto visual y de sonido al ser infectado
        target.play_sound('sound/items/hypospray.ogg')
