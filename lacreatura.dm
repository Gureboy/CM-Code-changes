// Define the constant for the life threshold (25%)
#define LIFE_THRESHOLD 0.25 // 25%

/mob/living/simple_animal/hostile/creature
    name = "creature"
    desc = "A sanity-destroying otherthing."
    icon = 'icons/mob/critter.dmi'
    speak_emote = list("gibbers")
    icon_state = "otherthing"  // Inicialmente el icono es otro
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

    // Variables para el sistema de infección
    var/infection_chance = 30
    var/datum/disease/addiction/creature_infection
    var/regen_amount = 15
    var/datum/effects/heal_over_time/heal_effect
    var/datum/xeno_shield/hedgehog_shield/hedgehog_shield_instance

    // Inicialización de enfermedad y regeneración cuando la criatura es creada
    New()
        ..()
        InitializeInfection()

    // Configurar la infección usando /datum/disease/addiction
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

    // Manejador de ataques para propagar la infección y activar la regeneración
    attack_hand(mob/living/carbon/human/target)
        ..()
        if(!target || target.stat == DEAD)
            return

        // Intentar infectar al objetivo con una cierta probabilidad
        if(prob(infection_chance))
            InfectTarget(target)

        // Activar el efecto de regeneración en la criatura
        ApplyRegeneration()

        // Activar el hedgehog_shield si la vida de la criatura está al 25% o menos
        if(health <= maxHealth * LIFE_THRESHOLD && !hedgehog_shield_instance)
            ActivateHedgehogShield()

    // Método para infectar al objetivo con la enfermedad
    proc/InfectTarget(mob/living/carbon/human/target)
        if(!target || target.stat == DEAD)
            return

        if(target.has_disease(creature_infection))
            return

        if(creature_infection)
            target.addiction = creature_infection
            target.addiction_stage = 1
            target.visible_message("[creature_infection.description]")
            src.visible_message("[target.name] has been touched by the eldritch horrors of [src.name]!")
            target.visible_message("[target.name] seems to wither under the weight of a mind-shattering force...")

        target.play_sound('sound/items/hypospray.ogg')

        // Cambiar el icono a "blob" cuando la criatura infecta a un objetivo
        SpawnBlob()

    // Método para aplicar regeneración a la criatura
    proc/ApplyRegeneration()
        if(!heal_effect)
            heal_effect = new /datum/effects/heal_over_time(src, regen_amount, 5, 1)
        else
            heal_effect.total_heal_amount += regen_amount
        heal_effect.start()

    // Activar el hedgehog_shield cuando la vida llega al 25% o menos
    proc/ActivateHedgehogShield()
        if(!hedgehog_shield_instance)
            hedgehog_shield_instance = new /datum/xeno_shield/hedgehog_shield
            hedgehog_shield_instance.owner = src // Establecer la criatura como el propietario del escudo
            hedgehog_shield_instance.ammo_type = /datum/ammo/bullet/shrapnel/incendiary // Usar munición incendiaria
            src.visible_message("As the creature's life fades, a horrific, chaotic shield activates... incendiary shrapnel tears the air, a sign of doom from beyond the void.")
            src.play_sound('sound/bullets/rocket_ricochet3.ogg')

    // Método para cambiar el icono de la criatura a "blob" y luego crear una nueva criatura
    proc/SpawnBlob()
        // Cambiar el icono de la criatura a "blob" de manera inmediata
        icon_state = "blob"
        // Mostrar el mensaje de que el blob aparece
        src.visible_message("An eldritch blob begins to pulse unnaturally on [src.name]! The horror intensifies!")

        // Crear una nueva criatura después de 5 minutos (300 segundos)
        spawn(300) // Esperar 5 minutos
            CreateNewCreature()

    // Crear una nueva instancia de la criatura
    proc/CreateNewCreature()
        var/new_creature = new /mob/living/simple_animal/hostile/creature
        new_creature.loc = src.loc // Colocar la nueva criatura en la misma ubicación que la original
        new_creature.icon_state = "otherthing" // La nueva criatura comienza con el icono "otherthing"

        // Mensaje visible que indica que la nueva criatura ha aparecido
        src.visible_message("A new eldritch creature is born from the horrors of the blob!")
        
        // Restaurar el icono de la criatura original después de la creación
        icon_state = "otherthing"
        src.visible_message("The eldritch blob has faded, leaving only a lingering sense of dread.")
