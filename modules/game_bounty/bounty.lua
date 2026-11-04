-- Bounty hunting (sicariato): the wanted list over the game screen with a live countdown, and the window
-- to put Tibia coins on a player's head. Server side: canary data/scripts/systems/bounty.lua (opcode 121).
local OPCODE = 121
local DURATIONS = { 1, 6, 12, 24, 48, 72 }
local DEFAULT_DURATION = 24
local FEE_PERCENT = 10
local MIN_REWARD = 50

local hud = nil
local window = nil
local hudButton = nil
local wanted = {} -- { name, reward, level, vocation, expiresAt (client clock) }
local tickEvent = nil

local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(seconds % 3600 / 60)
    if hours > 0 then
        return string.format('%dh %02dm', hours, minutes)
    end
    return string.format('%dm %02ds', minutes, seconds % 60)
end

local function decodeList(buffer)
    local list = {}
    local now = os.time()
    for chunk in buffer:gmatch('|([^|]+)') do
        local name, reward, seconds, level, vocation = chunk:match('^([^;]+);(%d+);(%d+);(%d+);(.*)$')
        if name then
            list[#list + 1] = {
                name = name,
                reward = tonumber(reward),
                level = tonumber(level),
                vocation = vocation,
                expiresAt = now + tonumber(seconds)
            }
        end
    end
    return list
end

local function isHudEnabled()
    return g_settings.getBoolean('bountyHudVisible', true)
end

local function refreshHud()
    if not hud then
        return
    end
    local now = os.time()
    local visible = {}
    for _, entry in ipairs(wanted) do
        if entry.expiresAt > now then
            visible[#visible + 1] = entry
        end
    end

    for _, child in ipairs(hud:getChildren()) do
        if child:getId() ~= 'title' then
            child:destroy()
        end
    end

    hud:getChildById('title'):setText(#visible > 0 and 'M\225s buscados' or 'M\225s buscados: sin recompensas')
    for index, entry in ipairs(visible) do
        local row = g_ui.createWidget('BountyHudRow', hud)
        row:setText(string.format('%d. %s (%d) - %d TC - %s', index, entry.name, entry.level, entry.reward, formatTime(entry.expiresAt - now)))
        row:setTooltip(entry.vocation ~= '' and entry.vocation or nil)
        if index == 1 then
            row:setColor('#ffd04f')
        end
    end
    hud:setVisible(isHudEnabled() and g_game.isOnline())
end

local function updateSummary()
    if not window then
        return
    end
    local amount = tonumber(window:getChildById('amount'):getText()) or 0
    local fee = math.floor(amount * FEE_PERCENT / 100)
    local text
    if amount < MIN_REWARD then
        text = string.format('M\237nimo %d Tibia coins. Comisi\243n del %d%%, no reembolsable.', MIN_REWARD, FEE_PERCENT)
    else
        text = string.format('Pagas %d. Comisi\243n %d. Recompensa para los cazadores: %d. Si nadie lo caza a tiempo te devolvemos %d.', amount, fee, amount - fee, amount - fee)
    end
    window:getChildById('summary'):setText(text)
end

local function onBountyOpcode(protocol, opcode, buffer)
    local kind = buffer:sub(1, 1)
    if kind == 'L' then
        wanted = decodeList(buffer)
        refreshHud()
    elseif kind == 'M' then
        local text = buffer:sub(3)
        if window and window:isVisible() then
            window:getChildById('status'):setText(text)
        end
    end
end

function openWindow(targetName)
    if not window then
        return
    end
    window:getChildById('targetName'):setText(targetName or '')
    window:getChildById('status'):setText('')
    updateSummary()
    window:show()
    window:raise()
    window:focus()
    if targetName and targetName ~= '' then
        window:getChildById('amount'):focus()
    else
        window:getChildById('targetName'):focus()
    end
end

function closeWindow()
    if window then
        window:hide()
    end
end

function submit()
    local protocol = g_game.getProtocolGame()
    if not protocol or not window then
        return
    end
    local name = window:getChildById('targetName'):getText():trim()
    local amount = tonumber(window:getChildById('amount'):getText())
    local hours = window:getChildById('duration'):getCurrentOption().data or DEFAULT_DURATION
    local status = window:getChildById('status')
    if name == '' then
        status:setText('Escribe el nombre del personaje.')
        return
    end
    if not amount or amount < MIN_REWARD then
        status:setText(string.format('La recompensa m\237nima es %d Tibia coins.', MIN_REWARD))
        return
    end
    status:setText('Enviando...')
    protocol:sendExtendedOpcode(OPCODE, string.format('place|%s|%d|%d', name, amount, hours))
end

local function toggleHud()
    g_settings.set('bountyHudVisible', not isHudEnabled())
    if hudButton then
        hudButton:setOn(isHudEnabled())
    end
    refreshHud()
end

local function onGameStart()
    hudButton = modules.game_mainpanel.addToggleButton('bountyButton', 'Recompensas (clic: poner recompensa, clic derecho: mostrar/ocultar lista)', '/images/options/button_frags', function()
        openWindow()
    end)
    if hudButton then
        hudButton:setOn(isHudEnabled())
        hudButton.onMouseRelease = function(widget, mousePos, mouseButton)
            if not widget:containsPoint(mousePos) then
                return false
            end
            if mouseButton == MouseRightButton then
                toggleHud()
            else
                openWindow()
            end
            return true
        end
    end

    if hud and not hud:getParent() then
        local mapPanel = modules.game_interface.getMapPanel()
        if mapPanel then
            mapPanel:addChild(hud)
        end
    end
    local protocol = g_game.getProtocolGame()
    if protocol then
        protocol:sendExtendedOpcode(OPCODE, 'list')
    end
    removeEvent(tickEvent)
    tickEvent = cycleEvent(refreshHud, 1000)
    refreshHud()
end

local function onGameEnd()
    removeEvent(tickEvent)
    tickEvent = nil
    wanted = {}
    if hud then
        hud:hide()
    end
    closeWindow()
end

function init()
    g_ui.importStyle('bounty')

    hud = g_ui.createWidget('BountyHud')
    hud:hide()
    local mapPanel = modules.game_interface.getMapPanel()
    if mapPanel then
        mapPanel:addChild(hud)
    end
    hud:addAnchor(AnchorTop, 'parent', AnchorTop)
    hud:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    hud:setMarginTop(6)
    hud:setMarginLeft(6)

    window = g_ui.createWidget('BountyWindow', rootWidget)
    window:hide()
    local duration = window:getChildById('duration')
    for _, hours in ipairs(DURATIONS) do
        duration:addOption(string.format('%d hora%s', hours, hours == 1 and '' or 's'), hours)
    end
    duration:setCurrentOptionByData(DEFAULT_DURATION)
    window:getChildById('amount').onTextChange = updateSummary

    modules.game_interface.addMenuHook('bounty', 'Poner recompensa', function(menuPosition, lookThing, useThing, creatureThing)
        openWindow(creatureThing:getName())
    end, function(menuPosition, lookThing, useThing, creatureThing)
        return creatureThing and creatureThing:isPlayer() and not creatureThing:isLocalPlayer()
    end)

    Keybind.new('Windows', 'Show/hide wanted list', '', '')
    Keybind.bind('Windows', 'Show/hide wanted list', { { type = KEY_DOWN, callback = toggleHud } })

    ProtocolGame.registerExtendedOpcode(OPCODE, onBountyOpcode)
    connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    if g_game.isOnline() then
        onGameStart()
    end
end

function terminate()
    disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
    ProtocolGame.unregisterExtendedOpcode(OPCODE)
    modules.game_interface.removeMenuHook('bounty')
    Keybind.delete('Windows', 'Show/hide wanted list')
    removeEvent(tickEvent)
    tickEvent = nil
    if hudButton then
        hudButton:destroy()
        hudButton = nil
    end
    if hud then
        hud:destroy()
        hud = nil
    end
    if window then
        window:destroy()
        window = nil
    end
end
