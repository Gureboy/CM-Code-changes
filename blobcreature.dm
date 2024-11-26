    icon = 'icons/mob/critter.dmi'
    name = "eldritch blob"
    desc = "A pulsating mass of unnatural horrors."
    icon_state = "blob" 
     
    var/amount_grown = 0
    health = 1000
    maxHealth = 10000
    // Inicialización del Blob
    Initialize()
        pixel_x = rand(3, -3)
        pixel_y = rand(3, -3)
        START_PROCESSING(SSobj, src)
        
        spawn(2500)  

    // Método para destruir el Blob
    Destroy()
        STOP_PROCESSING(SSobj, src)
        return ..()

    // Método para el proceso de crecimiento del Blob
    process()
        amount_grown += rand(0, 2)
        if (amount_grown >= 100)  // Cuando el Blob alcanza un tamaño determinado (100)
            // Después de 5 minutos, el Blob genera 1 o 2 criaturas (50% de chance para dos)
            var/num_creatures = prob(50) ? 2 : 1
            for (var/i = 0, i < num_creatures, i++)
                var/new_creature = new /mob/living/simple_animal/hostile/creature
                new_creature.loc = src.loc
                new_creature.icon_state = "otherthing"  // Crear la criatura con el icono 'otherthing'
            qdel(src)  // Destruye el Blob después de generar las criaturas
