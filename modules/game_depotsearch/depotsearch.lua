-- Search Locker (Tibia 12.20): lists every item kept in the depot, inbox and stash of the open locker,
-- and lets the player retrieve all units of one item at once. Server side lives in Canary (0x92-0x95, 0x29).
local window = nil
local results = {}
local selected = nil
local searchButtons = {}

local function itemName(itemId)
    local thingType = g_things.getThingType(itemId, ThingCategoryItem)
    local name = thingType and thingType:getName() or ''
    if name == '' then
        local market = thingType and thingType:getMarketData()
        name = market and market.name or ''
    end
    return name ~= '' and name or ('item ' .. itemId)
end

local function setStatus(text)
    if window then
        window:getChildById('status'):setText(text or '')
    end
end

local function clearDetail()
    selected = nil
    window:getChildById('detailItem'):setItemId(0)
    window:getChildById('detailName'):setText('Selecciona un \237tem para ver d\243nde est\225.')
    window:getChildById('detailCounts'):setText('')
    window:getChildById('retrieveDepot'):setEnabled(false)
    window:getChildById('retrieveInbox'):setEnabled(false)
end

local function onSlotClick(slot)
    selected = { id = slot.itemId, tier = slot.tier }
    window:getChildById('detailItem'):setItemId(slot.itemId)
    local name = itemName(slot.itemId)
    if slot.tier > 0 then
        name = name .. ' (tier ' .. slot.tier .. ')'
    end
    window:getChildById('detailName'):setText(name)
    window:getChildById('detailCounts'):setText('Buscando...')
    g_game.requestDepotSearchItem(slot.itemId, slot.tier)
end

local function rebuildList()
    if not window then
        return
    end
    local panel = window:getChildById('itemsPanel')
    panel:destroyChildren()

    local filter = window:getChildById('searchText'):getText():lower()
    local shown = 0
    for _, entry in ipairs(results) do
        if filter == '' or entry.name:lower():find(filter, 1, true) then
            local slot = g_ui.createWidget('DepotSearchSlot', panel)
            slot.itemId = entry.id
            slot.tier = entry.tier
            local item = slot:getChildById('item')
            item:setItemId(entry.id)
            item:setItemCount(entry.count)
            slot:setTooltip(entry.name .. ' (' .. entry.count .. ')')
            slot.onClick = onSlotClick
            shown = shown + 1
        end
    end
    setStatus(shown .. ' de ' .. #results .. ' \237tems')
end

local function onDepotSearchResults(items)
    results = {}
    for _, data in ipairs(items) do
        local id, tier, count = data[1], data[2], data[3]
        results[#results + 1] = { id = id, tier = tier, count = count, name = itemName(id) }
    end
    table.sort(results, function(a, b)
        if a.name == b.name then
            return a.tier < b.tier
        end
        return a.name < b.name
    end)

    if not window:isVisible() then
        window:show()
        window:raise()
        window:focus()
        clearDetail()
    end
    rebuildList()
end

local function onDepotSearchDetail(itemId, tier, depotCount, depotItems, inboxCount, inboxItems, stashCount)
    if not window or not selected or selected.id ~= itemId then
        return
    end
    window:getChildById('detailCounts'):setText(string.format('Depot: %d   Buz\243n: %d   Stash: %d', depotCount, inboxCount, stashCount))
    window:getChildById('retrieveDepot'):setEnabled(depotCount > 0)
    window:getChildById('retrieveInbox'):setEnabled(inboxCount > 0)
end

local function onCloseDepotSearch()
    if window then
        window:hide()
    end
    results = {}
    selected = nil
end

local function onContainerDepotSearch(containerId, available)
    local container = g_game.getContainer(containerId)
    if not container or not container.window then
        return
    end

    local button = searchButtons[containerId]
    if button and not button:isDestroyed() then
        button:destroy()
    end
    searchButtons[containerId] = nil
    if not available then
        return
    end

    local containerWindow = container.window
    button = g_ui.createWidget('Button', containerWindow)
    button:setText('Buscar')
    button:setTooltip('Buscar \237tems en el depot')
    button:setSize({ width = 44, height = 14 })
    button:setFont('verdana-11px-rounded')
    button:addAnchor(AnchorTop, 'parent', AnchorTop)
    button:addAnchor(AnchorRight, 'parent', AnchorRight)
    button:setMarginTop(2)
    button:setMarginRight(72)
    button.onClick = function()
        g_game.openDepotSearch()
    end
    searchButtons[containerId] = button
end

local function onContainerClose(container)
    for id, button in pairs(searchButtons) do
        if button:isDestroyed() or not g_game.getContainer(id) then
            if not button:isDestroyed() then
                button:destroy()
            end
            searchButtons[id] = nil
        end
    end
end

function retrieve(type)
    if not selected then
        return
    end
    g_game.retrieveDepotSearch(selected.id, selected.tier, type)
    setStatus('Retirando...')
end

function close()
    if window and window:isVisible() then
        window:hide()
        g_game.closeDepotSearch()
    end
end

local function onGameEnd()
    if window then
        window:hide()
    end
    results = {}
    selected = nil
    searchButtons = {}
end

function init()
    g_ui.importStyle('depotsearch')
    window = g_ui.createWidget('DepotSearchWindow', rootWidget)
    window:hide()
    window:getChildById('searchText').onTextChange = rebuildList

    connect(g_game, {
        onDepotSearchResults = onDepotSearchResults,
        onDepotSearchDetail = onDepotSearchDetail,
        onCloseDepotSearch = onCloseDepotSearch,
        onContainerDepotSearch = onContainerDepotSearch,
        onGameEnd = onGameEnd
    })
    connect(Container, { onClose = onContainerClose })
end

function terminate()
    disconnect(g_game, {
        onDepotSearchResults = onDepotSearchResults,
        onDepotSearchDetail = onDepotSearchDetail,
        onCloseDepotSearch = onCloseDepotSearch,
        onContainerDepotSearch = onContainerDepotSearch,
        onGameEnd = onGameEnd
    })
    disconnect(Container, { onClose = onContainerClose })
    for _, button in pairs(searchButtons) do
        if not button:isDestroyed() then
            button:destroy()
        end
    end
    searchButtons = {}
    if window then
        window:destroy()
        window = nil
    end
end
