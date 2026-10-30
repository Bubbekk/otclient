-- Podiums (Tibia 12.90): Podium of Tenacity (bestiary), Podium of Vigour (bosstiary) and the outfit podium.
-- The server opens them with 0xC2 (monsters) and 0xC8 with try-outfit mode 5 (outfits).
local window = nil
local state = nil

local function capitalize(name)
    return (name:gsub("(%a)([%w']*)", function(first, rest)
        return first:upper() .. rest
    end))
end

local function currentEntry()
    local focused = window:getChildById('list'):getFocusedChild()
    return focused and focused.entry or nil
end

local function updatePreview()
    local entry = currentEntry()
    local preview = window:getChildById('preview')
    if not entry then
        preview:setOutfit({ type = 0 })
        window:getChildById('selectedName'):setText('')
        return
    end
    preview:setOutfit(entry.outfit)
    local creature = preview:getCreature()
    if creature then
        creature:setDirection(state.direction)
    end
    window:getChildById('selectedName'):setText(entry.name)
end

local function rebuildList()
    local list = window:getChildById('list')
    list:destroyChildren()
    local filter = window:getChildById('searchText'):getText():lower()
    local toFocus = nil
    for _, entry in ipairs(state.entries) do
        if filter == '' or entry.name:lower():find(filter, 1, true) then
            local row = g_ui.createWidget('PodiumListRow', list)
            row:setText(entry.name)
            row.entry = entry
            if not toFocus or entry.id == state.selectedId then
                toFocus = row
            end
        end
    end
    if toFocus then
        list:focusChild(toFocus, KeyboardFocusReason)
        list:ensureChildVisible(toFocus)
    end
    updatePreview()
end

local function show(title, displayLabel)
    window:setText(title)
    window:getChildById('displayVisible'):setText(displayLabel)
    window:getChildById('podiumVisible'):setChecked(state.podiumVisible)
    window:getChildById('displayVisible'):setChecked(state.displayVisible)
    window:getChildById('searchText'):setText('')
    rebuildList()
    window:show()
    window:raise()
    window:focus()
end

local function onOpenMonsterPodiumWindow(isBoss, monsters, position, itemId, stackpos, podiumVisible, monsterVisible, direction)
    local entries = {}
    for _, data in ipairs(monsters) do
        local raceId, name = data[1], data[2]
        local race = g_things.getRaceData(raceId)
        if race and race.raceId ~= 0 then
            if name == '' then
                name = race.name
            end
            entries[#entries + 1] = { id = raceId, name = capitalize(name), outfit = race.outfit }
        elseif name ~= '' then
            entries[#entries + 1] = { id = raceId, name = capitalize(name), outfit = { type = 0 } }
        end
    end
    table.sort(entries, function(a, b) return a.name < b.name end)

    state = {
        mode = 'monster',
        entries = entries,
        position = position,
        itemId = itemId,
        stackpos = stackpos,
        direction = direction,
        podiumVisible = podiumVisible,
        displayVisible = monsterVisible
    }
    if isBoss then
        show('Podio de jefes', 'Mostrar jefe')
    else
        show('Podio del bestiario', 'Mostrar criatura')
    end
    if #entries == 0 then
        window:getChildById('selectedName'):setText(isBoss and 'A\250n no has completado ning\250n jefe.' or 'A\250n no has completado ninguna criatura.')
    end
end

local function onOpenPodiumOutfitWindow(currentOutfit, outfitList, mountList, position, itemId, stackpos, podiumVisible, hasOutfit, direction)
    local player = g_game.getLocalPlayer()
    local colors = hasOutfit and currentOutfit or (player and player:getOutfit()) or {}
    local entries = {}
    for _, data in ipairs(outfitList) do
        local lookType, name, addons = data[1], data[2], data[3]
        entries[#entries + 1] = {
            id = lookType,
            name = name ~= '' and name or ('Outfit ' .. lookType),
            outfit = {
                type = lookType,
                head = colors.head or 0,
                body = colors.body or 0,
                legs = colors.legs or 0,
                feet = colors.feet or 0,
                addons = addons
            }
        }
    end
    table.sort(entries, function(a, b) return a.name < b.name end)

    state = {
        mode = 'outfit',
        entries = entries,
        selectedId = hasOutfit and currentOutfit.type or nil,
        position = position,
        itemId = itemId,
        stackpos = stackpos,
        direction = direction,
        podiumVisible = podiumVisible,
        displayVisible = hasOutfit
    }
    show('Podio de outfit', 'Mostrar outfit')
end

function rotate(step)
    if not state then
        return
    end
    state.direction = (state.direction + step) % 4
    updatePreview()
end

function confirm()
    if not state then
        return
    end
    local entry = currentEntry()
    local podiumVisible = window:getChildById('podiumVisible'):isChecked()
    local displayVisible = window:getChildById('displayVisible'):isChecked()

    if state.mode == 'monster' then
        g_game.setMonsterPodium(entry and entry.id or 0, state.position, state.itemId, state.stackpos, state.direction,
            podiumVisible, displayVisible and entry ~= nil)
    else
        -- An outfit podium shows nothing when no outfit is sent
        local outfit = (displayVisible and entry) and entry.outfit or { type = 0 }
        outfit.mount = 0
        g_game.setPodiumOutfit(outfit, state.position, state.itemId, state.stackpos, state.direction, podiumVisible)
    end
    close()
end

function close()
    if window then
        window:hide()
    end
    state = nil
end

function init()
    g_ui.importStyle('podium')
    window = g_ui.createWidget('PodiumWindow', rootWidget)
    window:hide()
    window:getChildById('searchText').onTextChange = function()
        if state then
            rebuildList()
        end
    end
    window:getChildById('list').onChildFocusChange = function()
        if state then
            updatePreview()
        end
    end

    connect(g_game, {
        onOpenMonsterPodiumWindow = onOpenMonsterPodiumWindow,
        onOpenPodiumOutfitWindow = onOpenPodiumOutfitWindow,
        onGameEnd = close
    })
end

function terminate()
    disconnect(g_game, {
        onOpenMonsterPodiumWindow = onOpenMonsterPodiumWindow,
        onOpenPodiumOutfitWindow = onOpenPodiumOutfitWindow,
        onGameEnd = close
    })
    if window then
        window:destroy()
        window = nil
    end
end
