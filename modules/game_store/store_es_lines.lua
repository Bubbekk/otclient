-- Líneas cortas de descripción de la tienda (inglés del servidor -> español).
local ES = StoreES

local lines = {
    ["use it to open it"] = "úsalo para abrirlo",
    ["use it to sleep in it"] = "úsala para dormir en ella",
    ["usable 500 times a piece"] = "se puede usar 500 veces por unidad",
    ["usable 1000 times a piece"] = "se puede usar 1000 veces por unidad",
    ["usable 1800 times a piece"] = "se puede usar 1800 veces por unidad",
    ["usable 14400 times a piece"] = "se puede usar 14400 veces por unidad",
    ["deactivated upon purchase"] = "se desactiva al comprarlo",
    ["added to your reward wall"] = "se añade a tu muro de recompensas",
    ["lasts for 1 hour hunting time"] = "dura 1 hora de tiempo de caza",
    ["added directly to Prey dialog"] = "se añade directamente al diálogo de Presa",
    ["Refills your character's mana."] = "Recupera el maná de tu personaje.",
    ["use it to open the reward wall"] = "úsalo para abrir el muro de recompensas",
    ["can be fed once every 65 seconds"] = "se le puede dar de comer una vez cada 65 segundos",
    ["increases Kill Tasks from 6 to 9"] = "aumenta las tareas de matar de 6 a 9",
    ["increases Delivery Tasks from 6 to 9"] = "aumenta las tareas de entrega de 6 a 9",
    ["usable for 500 conversions a piece"] = "sirve para 500 conversiones por unidad",
    ["price increases with every purchase"] = "el precio aumenta con cada compra",
    ["use it to open up some storage space"] = "úsalo para abrir un espacio de almacenaje",
    ["Restores your character's hit points."] = "Restaura los puntos de vida de tu personaje.",
    ["Restores your character's hit points and mana."] = "Restaura los puntos de vida y el maná de tu personaje.",
    ["paused if stamina falls under 14 hours"] = "se pausa si la resistencia baja de 14 horas",
    ["usable by all characters of the account"] = "lo pueden usar todos los personajes de la cuenta",
    ["Change the sex of one of your hirelings"] = "Cambia el sexo de uno de tus mercenarios",
    ["Change the name of one of your hirelings"] = "Cambia el nombre de uno de tus mercenarios",
    ["added directly to the Record of Blessings"] = "se añade directamente al Registro de bendiciones",
    ["use it to teleport you to your home temple"] = "úsalo para teletransportarte a tu templo",
    ["use the magic lamp to summon your hireling"] = "usa la lámpara mágica para invocar a tu mercenario",
    ["Permanently expand every weekly task cycle."] = "Amplía de forma permanente cada ciclo semanal de tareas.",
    ["can only be used by one character at a time"] = "solo lo puede usar un personaje a la vez",
    ["Teleports you instantly to your home temple."] = "Te teletransporta al instante a tu templo.",
    ["use an unwrapped carpet to roll it out or up"] = "usa una alfombra desenvuelta para extenderla o enrollarla",
    ["use one of the exercise weapons on this dummy"] = "usa un arma de ejercicio sobre este maniquí",
    ["colours can be changed using the Outfit dialog"] = "los colores se pueden cambiar en el diálogo de Atuendo",
    ["use a bucket to pour it out or fill it back in"] = "usa un cubo para vaciarlo o volver a llenarlo",
    ["drag the unwrapped tapestry to a wall to hang it up"] = "arrastra el tapiz desenvuelto a una pared para colgarlo",
    ["use it on an exercise dummy to train your fist skill"] = "úsalo sobre un maniquí de ejercicio para entrenar tu habilidad de puño",
    ["cannot be purchased if an XP boost is already active"] = "no se puede comprar si ya hay un potenciador de XP activo",
    ["Use it to train your fist skill on an exercise dummy!"] = "¡Úsalo para entrenar tu habilidad de puño en un maniquí de ejercicio!",
    ["can be purchased up to 5 times between 2 server saves"] = "se puede comprar hasta 5 veces entre 2 guardados del servidor",
    ["use it on an exercise dummy to train your magic level"] = "úsalo sobre un maniquí de ejercicio para entrenar tu nivel mágico",
    ["Use it to train your magic level on an exercise dummy!"] = "¡Úsalo para entrenar tu nivel mágico en un maniquí de ejercicio!",
    ["does not work for characters with a red or black skull"] = "no funciona con personajes con calavera roja o negra",
    ["always placed on the first position of your Store inbox"] = "se coloca siempre en la primera posición de tu buzón de la Tienda",
    ["use it with an imbuable item to open the imbuing dialog"] = "úsalo con un objeto imbuible para abrir el diálogo de imbuimiento",
    ["Send your letters and parcels right from your own home!"] = "¡Envía tus cartas y paquetes desde tu propia casa!",
    ["Get an additional prey slot to activate additional prey!"] = "¡Consigue una ranura de presa adicional para activar más presas!",
    ["relog required after purchase to finalise the name change"] = "tras la compra hay que volver a entrar para completar el cambio de nombre",
    ["use it to activate or deactivate the automatic conversion"] = "úsalo para activar o desactivar la conversión automática",
    ["Tired of your current character name? Purchase a new one!"] = "¿Cansado del nombre de tu personaje? ¡Compra uno nuevo!",
    ["use it on an exercise dummy to train your shielding skill"] = "úsalo sobre un maniquí de ejercicio para entrenar tu habilidad de escudo",
    ["Reduces the penalty of your character's most recent death."] = "Reduce la penalización de la muerte más reciente de tu personaje.",
    ["Use it to train your shielding skill on an exercise dummy!"] = "¡Úsalo para entrenar tu habilidad de escudo en un maniquí de ejercicio!",
    ["can only be used for hirelings of the purchasing character"] = "solo se puede usar con los mercenarios del personaje que lo compra",
    ["Enhance your equipment comfortably in your own four walls!"] = "¡Mejora tu equipo cómodamente entre las cuatro paredes de tu casa!",
    ["can be used by all characters that have access to the house"] = "puede usarlo cualquier personaje con acceso a la casa",
    ["Turns your female character into a male one - or vice versa."] = "Convierte a tu personaje femenino en masculino, o viceversa.",
    ["use it on an exercise dummy to train your axe fighting skill"] = "úsalo sobre un maniquí de ejercicio para entrenar tu habilidad con hacha",
    ["Fill up potions to refill your mana no matter where you are!"] = "¡Rellena pociones para recuperar tu maná estés donde estés!",
    ["Use it to train your axe fighting skill on an exercise dummy!"] = "¡Úsalo para entrenar tu habilidad con hacha en un maniquí de ejercicio!",
    ["use it on an exercise dummy to train your club fighting skill"] = "úsalo sobre un maniquí de ejercicio para entrenar tu habilidad con maza",
    ["Pick up your daily reward comfortably in your own four walls!"] = "¡Recoge tu recompensa diaria cómodamente entre las cuatro paredes de tu casa!",
    ["use it on an exercise dummy to train your sword fighting skill"] = "úsalo sobre un maniquí de ejercicio para entrenar tu habilidad con espada",
    ["use it on a stack of 100 to change it to the superior currency"] = "úsalo sobre un montón de 100 para cambiarlo a la moneda superior",
    ["Use it to train your club fighting skill on an exercise dummy!"] = "¡Úsalo para entrenar tu habilidad con maza en un maniquí de ejercicio!",
    ["you will keep all outfits you have purchased or earned in quest"] = "conservarás todos los atuendos que hayas comprado u obtenido en misiones",
    ["Place it in your house and fill up potions to refill your mana!"] = "¡Colócalo en tu casa y rellena pociones para recuperar tu maná!",
    ["Use it to train your sword fighting skill on an exercise dummy!"] = "¡Úsalo para entrenar tu habilidad con espada en un maniquí de ejercicio!",
    ["use it on an exercise dummy to train your distance fighting skill"] = "úsalo sobre un maniquí de ejercicio para entrenar tu habilidad a distancia",
    ["only buyable if fitting vocation and level of purchasing character"] = "solo se puede comprar si la vocación y el nivel del personaje que lo compra son adecuados",
    ["can only be unwrapped in a house owned by the purchasing character"] = "solo puede desenvolverse en una casa que pertenezca al personaje que lo compra",
    ["Give your hirelings the ability of managing your banking business."] = "Da a tus mercenarios la capacidad de gestionar tus asuntos bancarios.",
    ["Use it to train your distance fighting skill on an exercise dummy!"] = "¡Úsalo para entrenar tu habilidad a distancia en un maniquí de ejercicio!",
    ["saves capacity because it's constant weight equals only 250 potions"] = "ahorra capacidad porque su peso constante equivale solo a 250 pociones",
    ["Fill up potions to restore your hit points no matter where you are!"] = "¡Rellena pociones para restaurar tus puntos de vida estés donde estés!",
    ["comes in a magic lamp which can only be used by purchasing character"] = "viene en una lámpara mágica que solo puede usar el personaje que la compra",
    ["includes basic outfit and 2 addons which can be selected individually"] = "incluye el atuendo básico y 2 complementos que se pueden elegir por separado",
    ["No matter where you are in Tibia, claim your daily reward on the spot!"] = "¡Estés donde estés en Tibia, reclama tu recompensa diaria al instante!",
    ["does not work in no-logout zones or close to a character's home temple"] = "no funciona en zonas sin cierre de sesión ni cerca del templo del personaje",
    ["Place it in your house and fill up potions to restore your hit points!"] = "¡Colócalo en tu casa y rellena pociones para restaurar tus puntos de vida!",
    ["number that can be purchased depends on the amount of hirelings you own"] = "la cantidad que se puede comprar depende del número de mercenarios que tengas",
    ["Fill up potions to restore your hit points and mana no matter where you are!"] = "¡Rellena pociones para restaurar tus puntos de vida y maná estés donde estés!",
    ["Sleep in a bed to restore soul, mana and hit points and to train your skills!"] = "¡Duerme en una cama para recuperar alma, maná y puntos de vida y para entrenar tus habilidades!",
    ["characters with a red or black skull will always lose all equipment upon death"] = "los personajes con calavera roja o negra siempre pierden todo el equipo al morir",
    ["can be used to fill up potions by all characters that have access to the house"] = "cualquier personaje con acceso a la casa puede usarlo para rellenar pociones",
    ["Place it in your house and fill up potions to restore your hit points and mana!"] = "¡Colócalo en tu casa y rellena pociones para restaurar tus puntos de vida y maná!",
    ["Get your very own hireling to serve you and your guests in your own four walls!"] = "¡Consigue tu propio mercenario para que os sirva a ti y a tus invitados en tu casa!",
    ["can only be used for the most recent death and only within 24 hours after this death"] = "solo se puede usar para la muerte más reciente y dentro de las 24 horas posteriores",
    ["converts all stacks of 100 gold or platinum in the inventory whenever it is activated"] = "convierte todos los montones de 100 monedas de oro o platino del inventario cada vez que se activa",
    ["Train your skills more effectively at home than in public on this expert exercise dummy!"] = "¡Entrena tus habilidades en casa con más eficacia que en público con este maniquí de ejercicio experto!",
    ["Give your hirelings the ability to access and manage your stash at the comfort of your home"] = "Da a tus mercenarios la capacidad de acceder a tu alijo y gestionarlo desde la comodidad de tu casa",
    ["Purchase a boost that increases the experience points your character gains from hunting by 50%!"] = "¡Compra un potenciador que aumenta un 50% la experiencia que tu personaje gana al cazar!",
    ["if not already occupied, it can be used by every Premium character that has access to the house"] = "si no está ocupada, la puede usar cualquier personaje Premium con acceso a la casa",
    ["Give your hirelings the ability to cook exclusive status enhancement and instant recovery meals!"] = "¡Da a tus mercenarios la capacidad de cocinar comidas exclusivas de mejora de estado y recuperación instantánea!",
    ["Carries as many gold, platinum or crystal coins as your capacity allows, however, no other items."] = "Lleva tantas monedas de oro, platino o cristal como permita tu capacidad, pero ningún otro objeto.",
    ["to trigger an animation feed it with meat, ham, dragon ham, haunch of a boar, roasted meat or bug meat"] = "para activar una animación, aliméntalo con carne, jamón, jamón de dragón, pernil de jabalí, carne asada o carne de insecto",
    ["Considering the sheer size of this axe, it might even be possible to chop onions without shedding a tear."] = "Dado el tamaño de esta hacha, quizá hasta se pueda cortar cebollas sin derramar una lágrima.",
    ["potions created from this keg will be sent to your Store inbox and can only be stored there and in depot box"] = "las pociones creadas con este tonel se enviarán a tu buzón de la Tienda y solo pueden guardarse allí o en el cofre del depósito",
    ["potions created from this cask will be sent to your Store inbox and can only be stored there and in depot box"] = "las pociones creadas con este barril se enviarán a tu buzón de la Tienda y solo pueden guardarse allí o en el cofre del depósito",
    ["Changes either a stack of 100 gold pieces into 1 platinum coin, or a stack of 100 platinum coins into 1 crystal coin!"] = "¡Cambia un montón de 100 monedas de oro por 1 moneda de platino, o un montón de 100 de platino por 1 moneda de cristal!",
    ["Protects your character's regular blessings or an Amulet of Loss if you are unfortunate enough to die in a PvP fight."] = "Protege las bendiciones normales de tu personaje o un Amuleto de la pérdida si tienes la mala suerte de morir en un combate PvP.",
    ["comes in 2 boxes which can only be unwrapped by purchasing character, put the 2 parts together to get a functional bed"] = "viene en 2 cajas que solo puede abrir el personaje que las compra; junta las 2 partes para obtener una cama funcional",
    ["Use Prey Wildcards to reroll the bonus of an active prey, to lock your active prey or to select a prey of your choice."] = "Usa comodines de presa para volver a tirar el bonus de una presa activa, para bloquearla o para elegir la presa que quieras.",
    ["Assign as many of your unlocked Charms as you like and get a 25% discount whenever you are removing a Charm from a creature!"] = "¡Asigna tantos amuletos desbloqueados como quieras y obtén un 25% de descuento cada vez que retires un amuleto de una criatura!",
    ["Give your hirelings the ability of trading several types of items, including equipment, tools, potions, runes, wands and rods."] = "Da a tus mercenarios la capacidad de comerciar con varios tipos de objetos, como equipo, herramientas, pociones, runas, varitas y varas.",
    ["Reduces your character's chance to lose any items as well as the amount of your character's experience and skill loss upon death:"] = "Reduce la probabilidad de que tu personaje pierda objetos, así como la experiencia y las habilidades que pierde al morir:",
    ["Changes automatically either a stack of 100 gold pieces into 1 platinum coin, or a stack of 100 platinum coins into 1 crystal coin!"] = "¡Cambia automáticamente un montón de 100 monedas de oro por 1 moneda de platino, o un montón de 100 de platino por 1 moneda de cristal!",
    ["the purchased dress can be used by all hirelings, however, how many hirelings can wear this outfit at the same time depends on the number of dresses you own"] = "el vestido comprado lo pueden usar todos los mercenarios, pero cuántos pueden llevar este atuendo a la vez depende del número de vestidos que tengas",
    ["house owner can use it to display a duplicate of an owned Ferumbras' Hat on this bust - also works if the character has already turned Ferumbras' hat in to earn the outfit addon"] = "el dueño de la casa puede usarlo para exhibir en este busto un duplicado de un Sombrero de Ferumbras que posea; también funciona si el personaje ya entregó el sombrero para conseguir el complemento del atuendo",
}

for k, v in pairs(lines) do
    ES.lines[k] = v
end

-- Líneas con cifras o nombres variables
local patterns = ES.linePatterns

table.insert(patterns, { "^maximum amount that can be owned by character: (%d+)$", function(n)
    return "cantidad máxima que puede poseer un personaje: " .. n
end })

table.insert(patterns, { "^%- (%d) blessing = ([%d%.]+)%% less Skill / XP loss, (%d+)%% equipment protection$", function(n, loss, protection)
    local plural = tonumber(n) == 1 and "bendición" or "bendiciones"
    return string.format("- %s %s = %s%% menos pérdida de habilidad / XP, %s%% de protección del equipo", n, plural, loss, protection)
end })

table.insert(patterns, { "^usable (%d+) times a piece$", function(n)
    return "se puede usar " .. n .. " veces por unidad"
end })

-- Tiempo premium / VIP (descripción construida en premium_time.lua)
local extra = {
    ["Enhance your gaming experience by gaining additional abilities and advantages:"] = "Mejora tu experiencia de juego obteniendo habilidades y ventajas adicionales:",
    ["Enhance your gaming experience by gaining advantages:"] = "Mejora tu experiencia de juego obteniendo ventajas:",
    ["- access to Premium areas"] = "- acceso a zonas Premium",
    ["- use Tibia's transport system (ships, carpet)"] = "- usar el sistema de transporte de Tibia (barcos, alfombra)",
    ["- more spells"] = "- más hechizos",
    ["- rent houses"] = "- alquilar casas",
    ["- found guilds"] = "- fundar gremios",
    ["- offline training"] = "- entrenamiento sin conexión",
    ["- larger depots"] = "- depósitos más grandes",
    ["- and many more"] = "- y mucho más",
    ["- stay online idle without getting disconnected"] = "- permanecer conectado inactivo sin ser desconectado",
    ["valid for all characters on this account"] = "válido para todos los personajes de esta cuenta",

    -- Descripciones por defecto (constants.lua)
    ["This outfit looks nice. Only high-class people are able to wear it!"] = "¡Este atuendo queda muy bien. Solo la gente de clase alta puede llevarlo!",
    ["An outfit that was created to suit you. We are sure you'll like it."] = "Un atuendo creado a tu medida. Seguro que te gustará.",
    ["Legend says only smart people should wear it, otherwise you will burn!"] = "¡La leyenda dice que solo la gente lista debería llevarlo, si no, arderás!",
    ["This is a fantastic mount that helps to become faster, try it!"] = "¡Es una montura fantástica que te ayuda a ser más rápido, pruébala!",
    ["The first rider of this mount became the leader of his country! legends say that."] = "¡El primer jinete de esta montura llegó a ser el líder de su país! Eso dicen las leyendas.",
    ["Are you hunted? Tired of that? Get a new name, a new life!"] = "¿Te persiguen? ¿Estás cansado de eso? ¡Consigue un nombre nuevo, una vida nueva!",
    ["A new name to suit your needs!"] = "¡Un nombre nuevo a tu medida!",
    ["Bored of your character's sex? Get a new sex for him now!!"] = "¿Aburrido del sexo de tu personaje? ¡Cámbialo ahora!",
    ["Are you tired of leveling slow? try it!"] = "¿Cansado de subir de nivel despacio? ¡Pruébalo!",
    ["It's hunting season! Activate a prey to gain a bonus when hunting a certain monster. Every character can purchase one Permanent Prey Slot, which enables the activation of an additional prey. \\nIf you activate a prey, you can select one monster out of nine. The bonus for your prey will be selected randomly from one of the following: damage boost, damage reduction, bonus XP, improved loot. The bonus value may range from 5% to 50%. Your prey will be active for 2 hours hunting time: the duration of an active prey will only be reduced while you are hunting."] = "¡Es temporada de caza! Activa una presa para obtener un bonus al cazar un monstruo concreto. Cada personaje puede comprar una Ranura de presa permanente, que permite activar una presa adicional. Si activas una presa, puedes elegir un monstruo entre nueve. El bonus se elige al azar entre: aumento de daño, reducción de daño, XP extra o botín mejorado. El valor del bonus puede ir del 5% al 50%. Tu presa estará activa durante 2 horas de tiempo de caza: la duración solo se reduce mientras cazas.",
    ["You activated a prey but do not like the randomly selected bonus? Roll for a new one! Here you can purchase five Prey Bonus Rerolls! \\nA Bonus Reroll allows you to get a bonus with a higher value (max. 50%). The bonus for your prey will be selected randomly from one of the following: damage boost, damage reduction, bonus XP, improved loot. The 2 hours hunting time will start anew once you have rolled for a new bonus. Your prey monster will stay the same."] = "¿Activaste una presa pero no te gusta el bonus elegido al azar? ¡Tira de nuevo! ¡Aquí puedes comprar cinco nuevas tiradas de bonus de presa! Una nueva tirada te permite obtener un bonus de mayor valor (máx. 50%). El bonus se elige al azar entre: aumento de daño, reducción de daño, XP extra o botín mejorado. Las 2 horas de tiempo de caza vuelven a empezar al tirar de nuevo. Tu monstruo de presa sigue siendo el mismo.",
    ["Need a quick way home? Buy this transportation service to get instantly teleported to your home temple. \\n\\nNote, you cannot use this service while having a battle sign or a protection zone block. Further, the service will not work in no-logout zones or close to your home temple."] = "¿Necesitas volver a casa rápido? Compra este servicio de transporte para teletransportarte al instante a tu templo. Ten en cuenta que no puedes usarlo con señal de batalla o bloqueo de zona de protección, y que no funciona en zonas sin cierre de sesión ni cerca de tu templo.",
}
for k, v in pairs(extra) do
    ES.lines[k] = v
end

table.insert(ES.linePatterns, { "^%- %+(%d+)%% experience rate$", function(n) return "- +" .. n .. "% de experiencia" end })
table.insert(ES.linePatterns, { "^%- %+(%d+)%% skill training speed$", function(n) return "- +" .. n .. "% de velocidad de entrenamiento de habilidades" end })
table.insert(ES.linePatterns, { "^%- %+(%d+)%% loot$", function(n) return "- +" .. n .. "% de botín" end })

-- Nombres generados: "30 Days of Premium Time", "90 Days of VIP"...
for _, days in ipairs({ 30, 90, 180, 360 }) do
    ES.names[days .. " Days of Premium Time"] = days .. " días de tiempo premium"
    ES.names[days .. " Days of VIP"] = days .. " días de VIP"
end

-- Ofertas de tiempo premium: un día, una semana, un mes, permanente
for offerName, label in pairs({ ["Premium Time"] = "tiempo premium", ["VIP"] = "VIP" }) do
    ES.names["1 Day of " .. offerName] = "Un día de " .. label
    ES.names["1 Week of " .. offerName] = "Una semana de " .. label
    ES.names["1 Month of " .. offerName] = "Un mes de " .. label
    ES.names["Permanent " .. offerName] = (offerName == "VIP") and "VIP permanente" or "Tiempo premium permanente"
end
ES.messages["You already have permanent premium time."] = "Ya tienes tiempo premium permanente."

-- Día de premium gratis (una vez cada 30 días por cuenta)
ES.messages["The free premium day is temporarily unavailable."] = "El día de premium gratis no está disponible en este momento."
table.insert(ES.messagePatterns, 1, { "^You already claimed your free premium day%. You can claim it again in (%d+) day%(s%)%.$", function(n)
    return string.format("Ya reclamaste tu día de premium gratis. Podrás reclamarlo de nuevo en %s %s.", n, n == "1" and "día" or "días")
end })
ES.lines["only buyable once every 30 days per account"] = "gratis una vez cada 30 días por cuenta"

-- Beneficios VIP (descripción construida en premium_time.lua)
ES.lines["- automatic loot"] = "- botín automático"
ES.lines["- keep your house without premium time"] = "- conservas tu casa sin tiempo premium"
ES.lines["- +50% daily reward"] = "- +50% en la recompensa diaria"
ES.lines["- more Tibia Coins for being online"] = "- más Tibia Coins por estar conectado"
table.insert(ES.linePatterns, { "^%- familiar cooldown reduced by (%d+) minutes$", function(n) return "- espera del familiar reducida en " .. n .. " minutos" end })
table.insert(ES.linePatterns, { "^%- (%d+)%% discount on consumables in the Store$", function(n) return "- " .. n .. "% de descuento en consumibles de la Tienda" end })
ES.lines["- all Premium benefits (areas, spells, travel, houses, guilds)"] = "- todas las ventajas Premium (zonas, hechizos, viajes, casas, gremios)"
ES.messages["Twist of Fate is not available on this world."] = "Giro del destino no está disponible en este mundo."
ES.names["Arctic Unicorn"] = "Unicornio ártico"
ES.names["Tangerine Flecked Koi"] = "Koi moteado mandarina"
ES.names["Ferumbras Bust"] = "Busto de Ferumbras"
ES.messages["You can't use temple teleport in a no-logout zone."] = "No puedes usar el teletransporte al templo en una zona sin cierre de sesión."
ES.messages["You are already close to your home temple."] = "Ya estás cerca de tu templo."
ES.messages["You already have a gold pouch."] = "Ya tienes una bolsa de oro."
ES.lines["- no daily limit on XP Boost purchases"] = "- sin límite diario de compras de Potenciador de XP"
ES.lines["- third Prey slot and third Hunting Task slot unlocked"] = "- tercer espacio de Prey y de Hunting Task desbloqueados"
ES.lines["- bestiary kills count 5x instead of 3x"] = "- las muertes del bestiario cuentan x5 en vez de x3"
ES.lines["- exclusive VIP daily rewards in the reward wall"] = "- recompensas diarias VIP exclusivas en el muro de recompensas"
ES.lines["- access to the Wheel of Destiny"] = "- acceso a la Wheel of Destiny"
