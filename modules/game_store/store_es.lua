-- Traducción al español de la tienda (store).
-- El servidor envía los textos en inglés y el cliente los usa como identificadores
-- (nombres de categoría, de producto, etc.), por eso NO se cambian en origen: aquí se
-- traducen únicamente al mostrarlos. Si un texto no está en los diccionarios, se muestra
-- tal cual llega del servidor.

StoreES = {}
local ES = StoreES

ES.enabled = true

-- Textos con tr() de los .otui y del .lua
ES.ui = {
    ["Store"] = "Tienda",
    ["Close"] = "Cerrar",
    ["History"] = "Historial",
    ["Get Tibia Coins"] = "Obtener Tibia Coins",
    ["Get"] = "Obtener",
    ["Transfer Coins"] = "Transferir monedas",
    ["Setup up an auction to sell you currents characters."] = "Crea una subasta para vender tus personajes actuales.",
    ["Next Page"] = "Página siguiente",
    ["Prev Page"] = "Página anterior",
    ["Page 1 / 4"] = "Página 1 / 4",
    ["Enter New Character Name"] = "Introduce el nuevo nombre del personaje",
    ["Please enter the new name for your character:"] = "Introduce el nuevo nombre de tu personaje:",
    ["Cancel"] = "Cancelar",
    ["Ok"] = "Aceptar",
    ["ok"] = "Aceptar",
    ["Gift Tibia Coins"] = "Regalar Tibia Coins",
    ["Please select the amount of Tibia\nCoins you like to gift and enter the\nname of the character that should\nreceive the Tibia Coins."] = "Selecciona la cantidad de Tibia\nCoins que quieres regalar e introduce\nel nombre del personaje que\nrecibirá las Tibia Coins.",
    ["Recipient:"] = "Destinatario:",
    ["Transferable Tibia Coins:"] = "Tibia Coins transferibles:",
    ["Gift"] = "Regalar",
    ["Type to search"] = "Escribe para buscar",
    ["Recently Added"] = "Añadidos recientemente",
    ["Amount to gift:"] = "Cantidad a regalar:",
    ["Buy"] = "Comprar",
    ["General Stats"] = "Estadísticas generales",
    ["Confirmation of Purchase"] = "Confirmación de compra",
    ["You don't have enough coins"] = "No tienes suficientes monedas",
}

-- Nombres de categorías (también aparecen como nombre de menú)
ES.categories = {
    ["Home"] = "Inicio",
    ["Home Offers"] = "Ofertas de inicio",
    ["VIP Shop"] = "Tienda VIP",
    ["Something Special"] = "Algo especial",
    ["Premium Time"] = "Tiempo premium",
    ["Consumables"] = "Consumibles",
    ["Blessings"] = "Bendiciones",
    ["Casks"] = "Barriles",
    ["Exercise Weapons"] = "Armas de ejercicio",
    ["Kegs"] = "Toneles",
    ["Potions"] = "Pociones",
    ["Runes"] = "Runas",
    ["Cosmetics"] = "Cosméticos",
    ["Mounts"] = "Monturas",
    ["Outfits"] = "Atuendos",
    ["Houses"] = "Casas",
    ["Decorations"] = "Decoración",
    ["Furniture"] = "Muebles",
    ["Beds"] = "Camas",
    ["Upgrades"] = "Mejoras",
    ["Hirelings"] = "Mercenarios",
    ["Hireling Dresses"] = "Vestidos de mercenario",
    ["Hirelings Dresses"] = "Vestidos de mercenario",
    ["Boosts"] = "Potenciadores",
    ["Extras"] = "Extras",
    ["Extra Services"] = "Servicios extra",
    ["Useful Things"] = "Cosas útiles",
    ["Tournament"] = "Torneo",
    ["Tickets"] = "Entradas",
    ["Exclusive Offers"] = "Ofertas exclusivas",
}

-- Iconos de la descripción: texto asociado a cada etiqueta {tag}
ES.tags = {
    ["only usable by purchasing character"] = "solo puede usarlo el personaje que lo compra",
    ["can be used by all characters that have access to the house"] = "puede usarlo cualquier personaje con acceso a la casa",
    ["comes in a box which can only be unwrapped by purchasing character"] = "viene en una caja que solo puede abrir el personaje que la compra",
    ["will be sent to your Store inbox and can only be stored there and in depot box"] = "se enviará a tu buzón de la Tienda y solo puede guardarse allí o en el cofre del depósito",
    ["can only be unwrapped in a house owned by the purchasing character"] = "solo puede desenvolverse en una casa que pertenezca al personaje que lo compra",
    ["can only be purchased once"] = "solo puede comprarse una vez",
    ["will be wrapped back and sent to inbox if the purchasing character is no longer the house owner"] = "se volverá a envolver y se enviará al buzón si el personaje que lo compró deja de ser el dueño de la casa",
    ["only buyable if fitting vocation and level of purchasing character"] = "solo se puede comprar si la vocación y el nivel del personaje que lo compra son adecuados",
    ["provides character with a speed boost"] = "otorga al personaje un aumento de velocidad",
    ["activated at purchase"] = "se activa al comprarlo",
    ["cannot be purchased by characters with protection zone block or battle sign"] = "no pueden comprarlo personajes con bloqueo de zona de protección o con señal de batalla",
    ["cannot be purchased if capacity is exceeded"] = "no se puede comprar si se excede la capacidad",
    ["can be used"] = "se puede usar",
    ["can be purchased with transferable Tibia Coins"] = "se puede comprar con Tibia Coins transferibles",
    ["maximum amount that can be owned by character: %s"] = "cantidad máxima que puede poseer un personaje: %s",
}

-- Mensajes del servidor (compras, errores, razones de bloqueo)
ES.messages = {
    ["The product is currently not available for this character. See the buy button tooltip for details."] = "El producto no está disponible actualmente para este personaje. Consulta la ayuda del botón de compra para más detalles.",
    ["The product is not available for this character:"] = "El producto no está disponible para este personaje:",
    ["Processing purchase."] = "Procesando compra.",
    ["Your purchase is being processed"] = "Tu compra se está procesando",
    ["not yet, UI missing"] = "todavía no, falta la interfaz",
    ["No data for store URL."] = "No hay datos para la URL de la tienda.",
    ["Error"] = "Error",
    ["(Including: "] = "(Incluyendo: ",
    ["Date"] = "Fecha",
    ["Balance"] = "Saldo",
    ["Description"] = "Descripción",
    ["Configurable"] = "Configurable",
    ["Disable"] = "Desactivar",
    ["Most Popular Fist"] = "Más populares primero",
    ["Alphabetically"] = "Alfabéticamente",
    ["Newest Fist"] = "Más nuevos primero",
    ["transferable coins"] = "monedas transferibles",
    ["regular coins"] = "monedas normales",
    ["Recently Added"] = "Añadidos recientemente",
    ["Amount to gift:"] = "Cantidad a regalar:",
    ["Purchase transaction error"] = "Error en la transacción de compra",
    ["Transaction error"] = "Error de transacción",
    ["Something went wrong. Your purchase has been cancelled."] = "Algo salió mal. Tu compra ha sido cancelada.",
    ["You don't have enough coins. Your purchase has been cancelled."] = "No tienes suficientes monedas. Tu compra ha sido cancelada.",
    ["You don't have this amount of coins."] = "No tienes esa cantidad de monedas.",
    ["This offer is unavailable [1]"] = "Esta oferta no está disponible [1]",
    ["This offer is unavailable [2]"] = "Esta oferta no está disponible [2]",
    ["The offer is fake."] = "La oferta no es válida.",
    ["You don't have any entries yet."] = "Todavía no tienes ningún registro.",
    ["You already have all Blessings."] = "Ya tienes todas las bendiciones.",
    ["You already have an active XP boost."] = "Ya tienes un potenciador de XP activo.",
    ["You already have charm expansion."] = "Ya tienes la expansión de amuletos.",
    ["You already have maximum of prey wildcards."] = "Ya tienes el máximo de comodines de presa.",
    ["You already have maximum of reward tokens."] = "Ya tienes el máximo de fichas de recompensa.",
    ["You already have the Permanent Weekly Task Expansion."] = "Ya tienes la Expansión permanente de tareas semanales.",
    ["You already have this addon."] = "Ya tienes este complemento.",
    ["You already have this mount."] = "Ya tienes esta montura.",
    ["You already have this outfit."] = "Ya tienes este atuendo.",
    ["You already have unlocked all prey slots."] = "Ya has desbloqueado todas las ranuras de presa.",
    ["You already own this mount."] = "Ya posees esta montura.",
    ["You already own this outfit."] = "Ya posees este atuendo.",
    ["You already have 3 slots released."] = "Ya tienes 3 ranuras desbloqueadas.",
    ["You already have bought the maximum number of allowed hirelings."] = "Ya has comprado el número máximo de mercenarios permitido.",
    ["You are exhausted."] = "Estás exhausto.",
    ["You are making many purchases simultaneously in a few moments."] = "Estás haciendo muchas compras seguidas en poco tiempo.",
    ["You can change name only in Protection Zone."] = "Solo puedes cambiar de nombre en una zona de protección.",
    ["You can't buy XP Boost for today."] = "Hoy ya no puedes comprar más potenciadores de XP.",
    ["You can't transfer coins to yourself."] = "No puedes transferirte monedas a ti mismo.",
    ["You can't use temple teleport in fight!"] = "¡No puedes usar el teletransporte al templo en combate!",
    ["You cannot transfer coin to a character in the same account."] = "No puedes transferir monedas a un personaje de la misma cuenta.",
    ["You don't have the outfit, you can't buy the addon."] = "No tienes el atuendo, no puedes comprar su complemento.",
    ["You must own the outfit before you can buy its addon."] = "Debes poseer el atuendo antes de poder comprar su complemento.",
    ["You have been teleported to your hometown."] = "Has sido teletransportado a tu ciudad natal.",
    ["You need to have a hireling."] = "Necesitas tener un mercenario.",
    ["You reached the maximum amount for this blessing."] = "Has alcanzado la cantidad máxima para esta bendición.",
    ["Your character has been renamed successfully."] = "Tu personaje ha sido renombrado correctamente.",
    ["Your hireling must be inside his/her lamp."] = "Tu mercenario debe estar dentro de su lámpara.",
    ["Your must select a hireling."] = "Debes seleccionar un mercenario.",
    ["We couldn't find that player."] = "No hemos encontrado a ese jugador.",
    ["This name is already used, please try again!"] = "Ese nombre ya está en uso, ¡inténtalo de nuevo!",
    ["This hireling outfit is already unlocked."] = "Este atuendo de mercenario ya está desbloqueado.",
    ["This skill is already unlocked."] = "Esta habilidad ya está desbloqueada.",
    ["This outfit seems not to suit your sex, we are sorry for that!"] = "Este atuendo no parece adecuado para tu sexo, ¡lo sentimos!",
    ["Permanent Weekly Task Expansion could not be unlocked."] = "No se pudo desbloquear la Expansión permanente de tareas semanales.",
    ["Permanent Weekly Task Expansion is unavailable."] = "La Expansión permanente de tareas semanales no está disponible.",
    ["Task Board is unavailable."] = "El tablón de tareas no está disponible.",
    ["No store inbox found."] = "No se encontró el buzón de la Tienda.",
    ["Error adding item to store inbox."] = "Error al añadir el objeto al buzón de la Tienda.",
    ["Error delivering your hireling lamp, try again later."] = "Error al entregar la lámpara de tu mercenario, inténtalo más tarde.",
    ["Please make sure you have enough free capacity to hold this item."] = "Asegúrate de tener capacidad libre suficiente para llevar este objeto.",
    ["Store don't have offers for rookgaard citizen."] = "La Tienda no tiene ofertas para ciudadanos de Rookgaard.",
    ["Your new name can't have consecutive spaces."] = "Tu nuevo nombre no puede tener espacios consecutivos.",
    ["Your new name can't have more than 2 spaces."] = "Tu nuevo nombre no puede tener más de 2 espacios.",
    ["Your new name can't have whitespace at the beginning."] = "Tu nuevo nombre no puede empezar con un espacio.",
    ["The length of your new name must be between 3 and 29 characters."] = "El nuevo nombre debe tener entre 3 y 29 caracteres.",
    ["The length of the hireling name must be between 3 and 18 characters."] = "El nombre del mercenario debe tener entre 3 y 18 caracteres.",
    ["The hireling name can't have whitespace at begin."] = "El nombre del mercenario no puede empezar con un espacio.",
    ["The hireling name has invalid characters"] = "El nombre del mercenario tiene caracteres no válidos.",
    ["The hireling name have more than 1 whitespace."] = "El nombre del mercenario tiene más de un espacio.",
    ["You cannot buy hirelings on client 10, please relog on client 12 and try again."] = "No puedes comprar mercenarios en el cliente 10; entra con el cliente 12 e inténtalo de nuevo.",
    ["You cannot buy hireling outfit on client 10, please relog on client 12 and try again."] = "No puedes comprar atuendos de mercenario en el cliente 10; entra con el cliente 12 e inténtalo de nuevo.",
    ["You cannot buy hireling skill on client 10, please relog on client 12 and try again."] = "No puedes comprar habilidades de mercenario en el cliente 10; entra con el cliente 12 e inténtalo de nuevo.",
    ["You cannot buy hireling change name on client 10, please relog on client 12 and try again."] = "No puedes cambiar el nombre de un mercenario en el cliente 10; entra con el cliente 12 e inténtalo de nuevo.",
    ["You cannot buy hireling change sex on client 10, please relog on client 12 and try again."] = "No puedes cambiar el sexo de un mercenario en el cliente 10; entra con el cliente 12 e inténtalo de nuevo.",
    ["A new hireling outfit has been added to all your hirelings"] = "Se ha añadido un nuevo atuendo a todos tus mercenarios",
    ["A new hireling skill has been added to all your hirelings"] = "Se ha añadido una nueva habilidad a todos tus mercenarios",
    ["Choose a Hireling"] = "Elige un mercenario",
    ["Select a hireling below"] = "Selecciona un mercenario abajo",
}

-- Patrones para mensajes con partes variables. %1, %2... son las capturas.
ES.messagePatterns = {
    { "^You have purchased (.+) for (%d+) coins%.$", function(n, c) return string.format("Has comprado %s por %s monedas.", ES.name(n), c) end },
    { "^You have successfully bought (.+)$", function(n) return "Has comprado correctamente " .. ES.name(n) end },
    { "^You have transfered (%d+) coins to (.+)%.?$", function(c, p) return string.format("Has transferido %s monedas a %s.", c, p) end },
    { "^You transferred this amount to (.+)$", function(p) return "Has transferido esta cantidad a " .. p end },
    { "^(.+) transferred you this amount%.$", function(p) return p .. " te ha transferido esta cantidad." end },
    { "^Do you want to buy the product \"(.+)\" for (%d+) (.+)%?$", function(n, c, t) return string.format("¿Quieres comprar el producto \"%s\" por %s %s?", n, c, ES.messages[t] or t) end },
    { "^Price: (%d+) (.+)$", function(c, t) return string.format("Precio: %s %s", c, ES.messages[t] or t) end },
    { "^Page (%d+)/(%d+)$", function(a, b) return string.format("Página %s/%s", a, b) end },
    { "^Buy (%d+)x$", function(n) return "Comprar " .. n .. "x" end },
    { "^%(Including: (.+)$", function(n) return "(Incluyendo: " .. n end },
    { "^Not enough free slots in your store inbox%. You need (%d+) more slot%(s%)%. Currently occupied: (%d+)/(%d+)$", function(a, b, c) return string.format("No hay suficientes espacios libres en tu buzón de la Tienda. Necesitas %s más. Ocupados actualmente: %s/%s", a, b, c) end },
    { "^(.+) has been renamed to (.+)$", function(a, b) return string.format("%s ha sido renombrado a %s", a, b) end },
    { "^You already have a (.+)$", function(a) return "Ya tienes un " .. a end },
    { "^You can't use word \"(.+)\" in your hireling name%.$", function(w) return string.format("No puedes usar la palabra \"%s\" en el nombre de tu mercenario.", w) end },
    { "^You can't use the word '(.+)' in your new name%.$", function(w) return string.format("No puedes usar la palabra '%s' en tu nuevo nombre.", w) end },
}

-- Nombres de productos: se rellena en store_es_names.lua
ES.names = {}
-- Líneas de descripción: se rellena en store_es_lines.lua y store_es_lore.lua
ES.lines = {}
-- Patrones para descripciones con nombres variables (monturas/atuendos)
ES.linePatterns = {}

local function lookup(map, s)
    if type(s) ~= "string" then return s end
    return map[s]
end

local function applyPatterns(patterns, s)
    for _, rule in ipairs(patterns) do
        local pattern, repl = rule[1], rule[2]
        if repl then
            local caps = { s:match(pattern) }
            if #caps > 0 then
                return repl(unpack(caps))
            end
        end
    end
    return nil
end

function ES.category(s)
    return lookup(ES.categories, s) or s
end

function ES.name(s)
    if type(s) ~= "string" then return s end
    local direct = ES.names[s] or ES.categories[s]
    if direct then return direct end
    -- "Full X Outfit"
    local outfit = s:match("^Full (.+) Outfit$")
    if outfit then
        return "Atuendo completo: " .. (ES.outfits and ES.outfits[outfit] or outfit)
    end
    return s
end

function ES.tag(s)
    return lookup(ES.tags, s) or s
end

function ES.message(s)
    if type(s) ~= "string" or s == "" then return s end
    local direct = ES.messages[s] or ES.categories[s]
    if direct then return direct end
    local viaPattern = applyPatterns(ES.messagePatterns, s)
    if viaPattern then return viaPattern end
    return s
end

function ES.line(s)
    if type(s) ~= "string" or s == "" then return s end
    s = s:gsub("^%-%s+", "- ")
    local direct = ES.lines[s]
    if direct then return direct end
    local viaPattern = applyPatterns(ES.linePatterns, s)
    if viaPattern then return viaPattern end
    return s
end

-- El cliente trabaja con texto en Latin-1 (cp1252), igual que data/locales/es.lua:
-- los diccionarios están en UTF-8 y se convierten al devolverlos.
local UTF8_PAIR = "([" .. string.char(194) .. string.char(195) .. "])([" .. string.char(128) .. "-" .. string.char(191) .. "])"
local function toLatin1(s)
    if type(s) ~= "string" then return s end
    return (s:gsub(UTF8_PAIR, function(a, b)
        return string.char((a:byte() - 192) * 64 + (b:byte() - 128))
    end))
end
ES.latin1 = toLatin1

for _, fname in ipairs({ "category", "name", "tag", "message", "line" }) do
    local raw = ES[fname]
    ES[fname] = function(s) return toLatin1(raw(s)) end
end

-- Instala las traducciones tr() en el idioma español (si es el activo)
function ES.install()
    if not (modules.client_locales and modules.client_locales.getInstalledLocales) then return end
    local installed = modules.client_locales.getInstalledLocales()
    local es = installed and installed['es']
    if not es then return end
    for k, v in pairs(ES.ui) do
        es.translation[k] = toLatin1(v)
    end
end

dofile 'store_es_names'
dofile 'store_es_lines'
dofile 'store_es_lore'
dofile 'store_es_lore2'

ES.install()
