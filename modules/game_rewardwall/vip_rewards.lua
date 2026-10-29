-- Fila "Recompensas VIP" del muro de recompensas.
-- El servidor (data/scripts/systems/vip_daily_reward.lua) es quien decide y entrega;
-- aquí solo se muestra el estado y se envía la petición. Opcode extendido 120.
-- Textos en Latin-1 (\225 = á, \237 = í, ...) porque el cliente usa cp1252.

local VIP_OPCODE = 120

-- Debe coincidir con REWARDS del servidor (mismo orden de días y de opciones)
local VIP_REWARDS = {
	{ item = 236, text = "25 pociones fuertes de vida o de man\225 (a elegir)", choices = { "Vida (25)", "Man\225 (25)" } },
	{ image = "/images/game/prey/prey_wildcard", text = "2 comodines de presa" },
	{ item = 28552, text = "Arma de entrenamiento de 500 cargas (a elegir)", choices = { "Espada", "Hacha", "Maza", "Arco", "Vara", "Varita" } },
	{ image = "/game_rewardwall/images/icon-reward-xpboost", text = "30 minutos de Potenciador de XP del 50%" },
	{ image = "/game_rewardwall/images/instant-reward-access-icon", text = "1 Acceso instant\225neo a recompensas" },
	{ item = 28555, text = "Arma de entrenamiento de 500 cargas (a elegir)", choices = { "Espada", "Hacha", "Maza", "Arco", "Vara", "Varita" } },
	{ image = "/game_rewardwall/images/icon-reward-fixeditems", text = "Cofre VIP: 1 hora de Potenciador de XP, 5 Tibia Coins y 1 Acceso instant\225neo a recompensas" },
}

local vipState = { vip = false, day = 1, canClaim = false, atShrine = false }

local function vipPanel()
	return rewardWallController.ui and rewardWallController.ui.vipRewardsPanel
end

local function buildVipSlots()
	local panel = vipPanel()
	if not panel or panel.vipSlots:getChildCount() > 0 then
		return
	end
	for day, reward in ipairs(VIP_REWARDS) do
		local slot = g_ui.createWidget("UIWidget", panel.vipSlots)
		slot:setId("vipSlot" .. day)
		slot:setSize({ width = 51, height = 76 })
		slot:setBorderWidth(1)
		slot:setBorderColor("#00000077")
		slot:setBackgroundColor("#2a2a2a")
		slot:setTooltip(string.format("D\237a %d: %s", day, reward.text))

		local icon
		if reward.item then
			icon = g_ui.createWidget("Item", slot)
			icon:setItemId(reward.item)
			icon:setVirtual(true)
		else
			icon = g_ui.createWidget("UIWidget", slot)
			icon:setImageSource(reward.image)
			icon:setSize({ width = 32, height = 32 })
		end
		icon:setId("icon")
		icon:setPhantom(true)
		icon:addAnchor(AnchorTop, "parent", AnchorTop)
		icon:addAnchor(AnchorHorizontalCenter, "parent", AnchorHorizontalCenter)
		icon:setMarginTop(8)

		local label = g_ui.createWidget("Label", slot)
		label:setId("label")
		label:setText(string.format("D\237a %d", day))
		label:setTextAlign(AlignCenter)
		label:setPhantom(true)
		label:addAnchor(AnchorBottom, "parent", AnchorBottom)
		label:addAnchor(AnchorLeft, "parent", AnchorLeft)
		label:addAnchor(AnchorRight, "parent", AnchorRight)
		label:setMarginBottom(6)
	end
end

local function updateVipPanel()
	local panel = vipPanel()
	if not panel then
		return
	end
	buildVipSlots()

	for day = 1, #VIP_REWARDS do
		local slot = panel.vipSlots:getChildById("vipSlot" .. day)
		if slot then
			local isCurrent = vipState.vip and day == vipState.day
			slot:setBorderColor(isCurrent and (vipState.canClaim and "#44AD25" or "#909090") or "#00000077")
			slot:setOpacity(vipState.vip and (day < vipState.day and 0.45 or 1) or 0.4)
			slot.label:setColor(isCurrent and "#e0b030" or "#c0c0c0")
		end
	end

	local reward = VIP_REWARDS[vipState.day]
	local status
	if not vipState.vip then
		status = "Hazte VIP para desbloquear estas recompensas."
	elseif not vipState.canClaim then
		status = "Ya reclamaste la recompensa VIP de hoy. Vuelve ma\241ana."
	elseif not vipState.atShrine then
		status = "Recl\225mala en un santuario de recompensas."
	else
		status = string.format("Hoy puedes reclamar la recompensa del d\237a %d.", vipState.day)
	end
	panel.vipStatus:setText(status)

	local showChoices = vipState.vip and vipState.canClaim and reward and reward.choices ~= nil
	panel.vipChoice:setVisible(showChoices)
	if showChoices then
		panel.vipChoice:clearOptions()
		for index, text in ipairs(reward.choices) do
			panel.vipChoice:addOption(text, index)
		end
	end
	panel.vipClaimButton:setEnabled(vipState.vip and vipState.canClaim and vipState.atShrine)
end

local function onVipOpcode(protocol, opcode, buffer)
	local kind, rest = buffer:match("^(%a)|(.*)$")
	if kind == "S" then
		local vip, day, canClaim, atShrine = rest:match("^(%d)|(%d+)|(%d)|(%d)$")
		if not vip then
			return
		end
		vipState.vip = vip == "1"
		vipState.day = math.max(1, math.min(#VIP_REWARDS, tonumber(day)))
		vipState.canClaim = canClaim == "1"
		vipState.atShrine = atShrine == "1"
		updateVipPanel()
	elseif kind == "M" then
		local panel = vipPanel()
		if panel then
			panel.vipStatus:setText(rest)
		end
	end
end

function vipRewardsRequestState()
	local protocol = g_game.getProtocolGame()
	if protocol and g_game.isOnline() then
		protocol:sendExtendedOpcode(VIP_OPCODE, "state")
	end
	updateVipPanel()
end

function vipRewardsClaim()
	local panel = vipPanel()
	local protocol = g_game.getProtocolGame()
	if not panel or not protocol then
		return
	end
	local choice = 1
	local reward = VIP_REWARDS[vipState.day]
	if reward and reward.choices then
		local option = panel.vipChoice:getCurrentOption()
		choice = option and tonumber(option.data) or 1
	end
	panel.vipClaimButton:setEnabled(false)
	protocol:sendExtendedOpcode(VIP_OPCODE, "claim:" .. choice)
end

function vipRewardsInit()
	ProtocolGame.registerExtendedOpcode(VIP_OPCODE, onVipOpcode)
end

function vipRewardsTerminate()
	ProtocolGame.unregisterExtendedOpcode(VIP_OPCODE)
end

function vipRewardsReset()
	vipState = { vip = false, day = 1, canClaim = false, atShrine = false }
end
