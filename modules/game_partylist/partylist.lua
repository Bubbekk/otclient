-- Party list (Tibia 12.20): lists the party members the client can see, with health and mana.
-- The server only sends party shields for creatures on screen, so members out of view are not listed.
local PARTY_SHIELDS = {
    [ShieldBlue] = true,
    [ShieldYellow] = true,
    [ShieldBlueSharedExp] = true,
    [ShieldYellowSharedExp] = true,
    [ShieldBlueNoSharedExpBlink] = true,
    [ShieldYellowNoSharedExpBlink] = true,
    [ShieldBlueNoSharedExp] = true,
    [ShieldYellowNoSharedExp] = true
}

local LEADER_SHIELDS = {
    [ShieldYellow] = true,
    [ShieldYellowSharedExp] = true,
    [ShieldYellowNoSharedExpBlink] = true,
    [ShieldYellowNoSharedExp] = true
}

local REFRESH_INTERVAL = 250

local partyWindow = nil
local partyButton = nil
local refreshEvent = nil
local rows = {}

local function isPartyMember(creature)
    return creature and creature:isPlayer() and PARTY_SHIELDS[creature:getShield()] == true
end

local function healthColor(percent)
    if percent > 92 then
        return '#00bc00'
    elseif percent > 60 then
        return '#50a150'
    elseif percent > 30 then
        return '#a1a100'
    elseif percent > 8 then
        return '#bf0a0a'
    end
    return '#910f0f'
end

local function collectMembers()
    local player = g_game.getLocalPlayer()
    if not player or not isPartyMember(player) then
        return {}
    end

    local members = {}
    for _, creature in ipairs(g_map.getSpectators(player:getPosition(), true)) do
        if isPartyMember(creature) then
            members[#members + 1] = creature
        end
    end

    -- Leader first, then the local player, then by name
    table.sort(members, function(a, b)
        local aLeader, bLeader = LEADER_SHIELDS[a:getShield()] == true, LEADER_SHIELDS[b:getShield()] == true
        if aLeader ~= bLeader then
            return aLeader
        end
        if a:isLocalPlayer() ~= b:isLocalPlayer() then
            return a:isLocalPlayer()
        end
        return a:getName():lower() < b:getName():lower()
    end)
    return members
end

local function onRowMousePress(row, mousePos, mouseButton)
    local creature = row.creature
    if not creature then
        return false
    end
    if mouseButton == MouseRightButton then
        modules.game_interface.createThingMenu(mousePos, nil, nil, creature)
        return true
    end
    if mouseButton == MouseLeftButton and not creature:isLocalPlayer() then
        g_game.follow(creature)
        return true
    end
    return false
end

local function updateRow(row, creature)
    row.creature = creature
    local name = creature:getName()
    if LEADER_SHIELDS[creature:getShield()] then
        name = name .. ' (l\237der)'
    end
    row.name:setText(name)
    row.name:setColor(creature:isLocalPlayer() and '#ffffff' or '#c0c0c0')

    local health = creature:getHealthPercent()
    row.health:setPercent(health)
    row.health:setBackgroundColor(healthColor(health))

    local mana = creature:getManaPercent()
    row.mana:setVisible(mana ~= nil and mana >= 0)
    if mana ~= nil and mana >= 0 then
        row.mana:setPercent(mana)
    end
end

local function refresh()
    if not partyWindow or not partyWindow:isVisible() then
        return
    end

    local contents = partyWindow:getChildById('contentsPanel')
    local members = collectMembers()

    for index, creature in ipairs(members) do
        local row = rows[index]
        if not row then
            row = g_ui.createWidget('PartyMemberRow', contents)
            row.onMousePress = onRowMousePress
            rows[index] = row
        end
        row:setVisible(true)
        updateRow(row, creature)
    end

    for index = #members + 1, #rows do
        rows[index].creature = nil
        rows[index]:setVisible(false)
    end

    contents:getChildById('emptyLabel'):setVisible(#members == 0)
end

local function startRefresh()
    removeEvent(refreshEvent)
    refreshEvent = cycleEvent(refresh, REFRESH_INTERVAL)
    refresh()
end

local function stopRefresh()
    removeEvent(refreshEvent)
    refreshEvent = nil
end

function toggle()
    if not partyWindow then
        return
    end
    if partyButton and partyButton:isOn() then
        partyWindow:close()
        return
    end
    if not partyWindow:getParent() then
        local panel = modules.game_interface.findContentPanelAvailable(partyWindow, partyWindow:getMinimumHeight())
        if not panel then
            return
        end
        panel:addChild(partyWindow)
    end
    partyWindow:open()
end

function onMiniWindowOpen()
    if partyButton then
        partyButton:setOn(true)
    end
    startRefresh()
end

function onMiniWindowClose()
    if partyButton then
        partyButton:setOn(false)
    end
    stopRefresh()
end

local function onGameStart()
    partyButton = modules.game_mainpanel.addToggleButton('partyListButton', 'Grupo', '/images/options/button_battlelist', toggle)
    partyWindow:setupOnStart()
    if partyWindow:isVisible() then
        startRefresh()
    end
end

local function onGameEnd()
    stopRefresh()
    for _, row in ipairs(rows) do
        row.creature = nil
    end
end

function init()
    g_ui.importStyle('partylist')
    partyWindow = g_ui.createWidget('PartyListWindow', modules.game_interface.getRightPanel())
    partyWindow:setContentMinimumHeight(40)

    for _, id in ipairs({ 'toggleFilterButton', 'newWindowButton', 'contextMenuButton' }) do
        local button = partyWindow:recursiveGetChildById(id)
        if button then
            button:setVisible(false)
        end
    end

    partyWindow:setup()
    partyWindow:hide()

    Keybind.new('Windows', 'Show/hide party list', '', '')
    Keybind.bind('Windows', 'Show/hide party list', { { type = KEY_DOWN, callback = toggle } })

    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    stopRefresh()
    Keybind.delete('Windows', 'Show/hide party list')
    rows = {}
    if partyButton then
        partyButton:destroy()
        partyButton = nil
    end
    if partyWindow then
        partyWindow:destroy()
        partyWindow = nil
    end
end
