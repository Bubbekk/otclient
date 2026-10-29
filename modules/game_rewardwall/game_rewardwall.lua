-- chunkname: @/game_rewardwall/game_rewardwall.lua

rewardWallController = Controller:new()

-- Traducción al español (textos en Latin-1: \225 = á, \237 = í, etc., porque el cliente usa cp1252).
-- Los nombres de bonus llegan del servidor en inglés y el código los compara en inglés,
-- por eso solo se traducen al mostrarlos.
local BONUS_NAMES_ES = {
	["No bonus for first day"] = "Sin bonus el primer d\237a",
	["Hit Point Regeneration"] = "Regeneraci\243n de puntos de vida",
	["Mana Regeneration"] = "Regeneraci\243n de man\225",
	["Stamina Regeneration"] = "Regeneraci\243n de resistencia",
	["Double Hit Point Regeneration"] = "Doble regeneraci\243n de puntos de vida",
	["Double Mana Regeneration"] = "Doble regeneraci\243n de man\225",
	["Soul Points Regeneration"] = "Regeneraci\243n de puntos de alma",
}

local function bonusNameEs(name)
	return BONUS_NAMES_ES[name] or name
end

local function itemNameEs(name)
	if name == "Prey Wildcard" then
		return "Comod\237n de presa"
	end
	return name
end

local ServerPackets = {
	CloseRewardWall = 227,
	OpenRewardWall = 226,
	DailyRewardCollectionState = 222,
	ShowDialog = 237,
	DailyRewardHistory = 229,
	DailyRewardBasic = 228
}
local ClientPackets = {
	JokerResource = 21,
	OpenRewardWall = 216,
	CollectionResource = 20,
	SelectReward = 218,
	OpenRewardHistory = 217
}
local ButtonRewardWall, windowsPickWindow, generalBox
local bonuses = {}
local rewardStreakLevel = 0
local actualUsed = {}
local bonusShrine = 0
local DAILY_REWARD_CYCLE = 86400
local dailyRewardSlotTimerEvent, dailyRewardSlotTimerData, restingAreaTimerEvent, restingAreaTimerData
local claimPending = false
-- FIFO of outstanding client wall requests; true marks a quiet (store-triggered) refresh.
-- The server answers requests in send order, so each reply consumes the oldest entry.
local pendingWallRequests = {}
local claimCloseResetEvent
local serverErrorConnected = false

local function requestRewardWall(quiet)
	table.insert(pendingWallRequests, quiet == true)
	g_game.sendOpenRewardWall()
end

local COLORS = {
	BASE_1 = "#484848",
	BASE_2 = "#414141"
}
local ZONE = {
	RESTING_AREA_ZONE = 1,
	LAST_ZONE = -99,
	NUMERIC_ICON_ID = 30,
	ICON_ID = "condition_Rewards"
}
local bundleType = {
	XPBOOST = 3,
	PREY = 2,
	ITEMS = 1
}
local STATUS = {
	LOCKED = 3,
	ACTIVE = 2,
	COLLECTED = 1
}
local OPEN_WINDOWS = {
	SHRINE = 1,
	BUTTON_WIDGET = 0
}
local DailyRewardStatus = {
	DAILY_REWARD_COLLECTED = 0,
	DAILY_REWARD_NOTAVAILABLE = 2,
	DAILY_REWARD_NOTCOLLECTED = 1
}
local CONST_WINDOWS_BOX = {
	ALREADY = 1,
	NO_IRA = 4,
	RELEASE = 2
}
local BOX_CONFIGS = {
	[CONST_WINDOWS_BOX.ALREADY] = {
		title = "Aviso",
		content = "Lo sentimos, ya recogiste tu recompensa diaria o no puedes recogerla."
	},
	[CONST_WINDOWS_BOX.NO_IRA] = {
		title = "Aviso: no tienes Acceso instant\225neo a recompensas",
		content = "\161Recuerda! Siempre puedes recoger tu recompensa diaria gratis visitando un santuario de recompensas.\nNo tienes ning\250n Acceso instant\225neo a recompensas.\n\161Visita la Tienda para comprar m\225s!"
	}
}

local function destroyWindows(windows)
	if type(windows) == "table" then
		for _, window in pairs(windows) do
			if window and not window:isDestroyed() then
				window:destroy()
			end
		end
	elseif windows and not windows:isDestroyed() then
		windows:destroy()
	end

	return nil
end

local function getClaimUsedToken()
	if bonusShrine == OPEN_WINDOWS.SHRINE then
		return 0
	end

	return 1
end

local function getSelectedRewardItems()
	local selected = {}

	for itemId, count in pairs(actualUsed) do
		if count and count > 0 then
			selected[itemId] = count
		end
	end

	return selected
end

local function claimInstantDailyReward()
	g_game.requestGetRewardDaily(getClaimUsedToken(), getSelectedRewardItems())

	generalBox, windowsPickWindow = destroyWindows({
		generalBox,
		windowsPickWindow
	})
end

local function premiumStatusWindwos(isPremium)
	rewardWallController.ui.premiumStatus.premiumMessage:setText(isPremium and "\161Genial! Recibes las mejores recompensas y bonus posibles gracias a tu estado premium." or "Con una cuenta Premium obtendr\237as recompensas y bonus a\250n mejores.")
	rewardWallController.ui.premiumStatus.premiumButton:setOn(not isPremium)
	rewardWallController.ui.premiumStatus.premiumMessage:setMarginTop(-5)
	rewardWallController.ui.infoPanel.free:setColor(isPremium and "#909090" or "#FFFFFF")
	rewardWallController.ui.infoPanel.premium:setColor(isPremium and "#FFFFFF" or "#909090")
end

local function updateRestingAreaBonusIcons(dayStreakLevel)
	rewardStreakLevel = dayStreakLevel or 0

	local bonusIcons = rewardWallController.ui and rewardWallController.ui.restingAreaPanel and rewardWallController.ui.restingAreaPanel.bonusIcons

	if not bonusIcons then
		return
	end

	for i = 1, 6 do
		local widget = bonusIcons:getChildById("bonusIcon" .. i)

		if not widget then
			break
		end

		local requiredStreak = i + 1
		local locked = rewardStreakLevel < requiredStreak
		local dither = widget.ditherpattern or widget:getChildById("ditherpattern")

		if dither then
			dither:setVisible(locked)
		end

		local banner = widget.dayBanner or widget:getChildById("dayBanner")

		if banner then
			banner:setVisible(locked)
		end

		local bannerText = widget.dayBannerText or widget:getChildById("dayBannerText")

		if bannerText then
			bannerText:setVisible(locked)

			if locked then
				bannerText:setText(tostring(requiredStreak))
			end
		end
	end
end

local function convert_timestamp(timestamp)
	return os.date("%Y-%m-%d, %H:%M:%S", timestamp)
end

local function formatRewardTimeLeft(timeLeft)
	if not timeLeft or timeLeft == 0 then
		return ""
	end

	if timeLeft == 90001 then
		return "< 1 min"
	end

	return os.date("%H:%M", timeLeft)
end

local function resolveRemainingSeconds(nextRewardTime, elapsedSinceStart)
	if not nextRewardTime or nextRewardTime == 0 then
		return 0
	end

	if nextRewardTime == 90001 then
		return 59
	end

	if nextRewardTime > 1000000000 then
		return math.max(0, nextRewardTime - os.time())
	end

	elapsedSinceStart = elapsedSinceStart or 0

	return math.max(0, nextRewardTime - elapsedSinceStart)
end

local function formatCountdownHHMM(seconds)
	if seconds == 90001 then
		return "< 1 min"
	end

	if not seconds or seconds <= 0 then
		return "00:00"
	end

	local hours = math.floor(seconds / 3600)
	local minutes = math.floor(seconds % 3600 / 60)

	return string.format("%02d:%02d", hours, minutes)
end

local function getDailyRewardProgressPercent(remainingSeconds, useRemaining)
	if not remainingSeconds or remainingSeconds <= 0 then
		return useRemaining and 0 or 100
	end

	remainingSeconds = math.min(remainingSeconds, DAILY_REWARD_CYCLE)

	if useRemaining then
		return math.min(100, math.max(0, remainingSeconds / DAILY_REWARD_CYCLE * 100))
	end

	local elapsed = DAILY_REWARD_CYCLE - remainingSeconds

	return math.min(100, math.max(0, elapsed / DAILY_REWARD_CYCLE * 100))
end

local function stopDailyRewardSlotTimer()
	if dailyRewardSlotTimerEvent then
		removeEvent(dailyRewardSlotTimerEvent)

		dailyRewardSlotTimerEvent = nil
	end

	dailyRewardSlotTimerData = nil
end

local function stopRestingAreaTimer()
	if restingAreaTimerEvent then
		removeEvent(restingAreaTimerEvent)

		restingAreaTimerEvent = nil
	end

	restingAreaTimerData = nil
end

local function getDailyRewardProgressBar(overlay)
	if not overlay then
		return nil
	end

	if overlay.content and overlay.content.progress then
		return overlay.content.progress
	end

	return overlay:recursiveGetChildById("progress")
end

local function updateTimerOverlayUI(timerData)
	if not timerData then
		return false
	end

	local overlay = timerData.overlay

	if not overlay or overlay:isDestroyed() then
		return false
	end

	local nextRewardTime = timerData.nextRewardTime
	local elapsed = os.time() - timerData.startTime
	local useRemaining = timerData.useRemainingProgress == true
	local text, percent

	if nextRewardTime == 0 then
		text = "00:00"
		percent = useRemaining and 0 or 100
	elseif nextRewardTime == 90001 then
		text = "< 1 min"
		percent = getDailyRewardProgressPercent(59, useRemaining)
	else
		local remaining = resolveRemainingSeconds(nextRewardTime, elapsed)

		text = formatCountdownHHMM(remaining)
		percent = getDailyRewardProgressPercent(remaining, useRemaining)
	end

	if overlay.text then
		overlay.text:setText(text)
	end

	local progressBar = getDailyRewardProgressBar(overlay)

	if progressBar then
		progressBar:setPercent(percent)
	end

	return true
end

local function updateDailyRewardSlotTimerUI()
	if not dailyRewardSlotTimerData then
		return
	end

	local timerData = dailyRewardSlotTimerData

	if not updateTimerOverlayUI(timerData) then
		stopDailyRewardSlotTimer()

		return
	end

	-- Only refresh when a countdown that was running actually reached zero, to avoid request loops on stale times.
	if timerData.wasCounting and timerData.nextRewardTime ~= 90001 then
		local remaining = resolveRemainingSeconds(timerData.nextRewardTime, os.time() - timerData.startTime)

		if remaining <= 0 then
			stopDailyRewardSlotTimer()

			if rewardWallController.ui and rewardWallController.ui:isVisible() then
				requestRewardWall()
			end
		end
	end
end

local function updateRestingAreaTimerUI()
	if not restingAreaTimerData then
		return
	end

	if not updateTimerOverlayUI(restingAreaTimerData) then
		stopRestingAreaTimer()
	end
end

local function startDailyRewardSlotTimer(overlay, nextRewardTime)
	stopDailyRewardSlotTimer()

	if not overlay then
		return
	end

	nextRewardTime = nextRewardTime or 0

	dailyRewardSlotTimerData = {
		useRemainingProgress = true,
		overlay = overlay,
		nextRewardTime = nextRewardTime,
		startTime = os.time(),
		wasCounting = resolveRemainingSeconds(nextRewardTime, 0) > 0
	}

	updateDailyRewardSlotTimerUI()

	dailyRewardSlotTimerEvent = cycleEvent(updateDailyRewardSlotTimerUI, 1000)
end

local function startRestingAreaTimer(overlay, nextRewardTime)
	stopRestingAreaTimer()

	if not overlay then
		return
	end

	restingAreaTimerData = {
		useRemainingProgress = true,
		overlay = overlay,
		nextRewardTime = nextRewardTime or 0,
		startTime = os.time()
	}

	updateRestingAreaTimerUI()

	restingAreaTimerEvent = cycleEvent(updateRestingAreaTimerUI, 1000)
end

local function getBonusStrings(bonuses)
	local result = {}

	for _, bonus in ipairs(bonuses) do
		table.insert(result, bonusNameEs(bonus.name))
	end

	return table.concat(result, ", ")
end

local function visibleHistory(bool)
	for i, widget in ipairs(rewardWallController.ui:getChildren()) do
		if widget:getId() == "historyPanel" then
			widget:setVisible(bool)
		else
			widget:setVisible(not bool)
		end

		if i == 5 then
			break
		end
	end
end

local function resetHistoryView()
	if not rewardWallController.ui or not rewardWallController.ui.historyPanel:isVisible() then
		return
	end

	visibleHistory(false)
	rewardWallController.ui.footerPanel.historyButton:setText("Historial")
end

local REWARD_CONTAINER_ACTIVE = "/game_rewardwall/images/container-bonus-active"
local REWARD_CONTAINER_INACTIVE = "/game_rewardwall/images/container-bonus-inactive"
local REWARD_GOLD_CLIPS = {
	CHECK_BOTTOM = "0 40 66 20",
	LOCKED = "0 0 66 20",
	CHECK_TOP = "0 20 66 20",
	EMPTY = "0 60 66 20"
}
local REWARD_ARROW_CLIPS = {
	CURRENT_LEFT = "5 0 5 7",
	DEFAULT = "0 0 5 7"
}
local REWARD_BUTTON_MODE = {
	LOCKED = 3,
	WAITING = 2,
	COLLECTABLE = 1,
	COLLECTED = 4
}
local pendingRewardButton

local function setRewardDayButtonState(button, mode)
	if not button then
		return
	end

	button.rewardVisualMode = mode

	local dither = button.ditherpattern

	if mode == REWARD_BUTTON_MODE.COLLECTABLE then
		button:setImageSource(REWARD_CONTAINER_ACTIVE)
		button:setImageClip("0 0 66 66")

		if dither then
			dither:setVisible(false)
		end
	elseif mode == REWARD_BUTTON_MODE.WAITING then
		button:setImageSource(REWARD_CONTAINER_INACTIVE)
		button:setImageClip("0 0 66 66")

		if dither then
			dither:setVisible(false)
		end
	else
		button:setImageSource(REWARD_CONTAINER_INACTIVE)
		button:setImageClip("0 0 66 66")

		if dither then
			dither:setVisible(true)
		end
	end
end

local function restoreRewardButtonVisual(button)
	if not button or button.rewardVisualMode ~= REWARD_BUTTON_MODE.COLLECTABLE then
		return
	end

	button:setImageSource(REWARD_CONTAINER_ACTIVE)
	button:setImageClip("0 0 66 66")
end

local function wireRewardButtonClick(button)
	if not button or button.rewardClickWired then
		return
	end

	button.rewardClickWired = true
	button.onClick = nil

	function button.onMousePress(widget, mousePos, mouseButton)
		if mouseButton ~= MouseLeftButton then
			return false
		end

		if widget.rewardVisualMode ~= REWARD_BUTTON_MODE.COLLECTABLE or claimPending then
			return true
		end

		pendingRewardButton = widget

		widget:setImageClip("66 0 66 66")

		return true
	end

	function button.onMouseRelease(widget, mousePos, mouseButton)
		if mouseButton ~= MouseLeftButton then
			return false
		end

		local wasPending = pendingRewardButton == widget

		pendingRewardButton = nil

		restoreRewardButtonVisual(widget)

		if widget.rewardVisualMode ~= REWARD_BUTTON_MODE.COLLECTABLE then
			return true
		end

		if not wasPending or claimPending then
			return true
		end

		if not widget:containsPoint(mousePos) then
			return true
		end

		onClickPickReward(widget)

		return true
	end
end

local function beginClaim()
	if claimPending then
		return false
	end

	claimPending = true

	return true
end

local function setRewardGoldSlotState(slot)
	if not slot then
		return
	end

	slot:setOn(false)
end

local function setupRewardGoldOverlay(slot, styleName)
	if not slot then
		return nil
	end

	slot:destroyChildren()

	local overlay = g_ui.createWidget(styleName, slot)

	overlay:setPhantom(true)

	return overlay
end

local function updateRewardGoldCollectableOverlay(overlay)
	if not overlay then
		return
	end

	local balance = 0
	local player = g_game.getLocalPlayer()

	if player then
		balance = player:getResourceBalance(ResourceTypes.DAILYREWARD_STREAK) or 0
	end

	if overlay.balance then
		overlay.balance:setText(tostring(balance))
	end
end

local function getRestingAreaTimeLeftFrame(widget)
	if not widget then
		return nil
	end

	return widget.frame or widget:getChildById("frame")
end

local function updateRestingAreaTimeLeft(notCollected, timeLeft)
	local timeLeftWidget = rewardWallController.ui.restingAreaPanel.restingAreaInfo.timeLeft

	if not timeLeftWidget then
		return
	end

	local frame = getRestingAreaTimeLeftFrame(timeLeftWidget)

	if notCollected then
		if frame then
			frame:setImageClip(REWARD_GOLD_CLIPS.EMPTY)
		end

		if timeLeftWidget.content then
			timeLeftWidget.content:setVisible(true)
		end

		if timeLeftWidget.text then
			timeLeftWidget.text:setVisible(true)
		end

		startRestingAreaTimer(timeLeftWidget, timeLeft)
	else
		stopRestingAreaTimer()

		if frame then
			frame:setImageClip(REWARD_GOLD_CLIPS.CHECK_TOP)
		end

		if timeLeftWidget.content then
			timeLeftWidget.content:setVisible(false)
		end

		if timeLeftWidget.text then
			timeLeftWidget.text:setVisible(false)
			timeLeftWidget.text:setText("")
		end
	end
end

local function initRewardGoldSlots()
	local panel = rewardWallController.ui and rewardWallController.ui.dailyRewardsPanel

	if not panel then
		return
	end

	for i = 1, 7 do
		local rewardWidget = panel:getChildById("reward" .. i)

		if rewardWidget then
			setRewardGoldSlotState(rewardWidget:getChildById("rewardGold" .. i))
		end
	end
end

local function updateDailyRewards(dayStreakDay, wasDailyRewardTaken, nextRewardTime, canGetReward, timeLeft)
	stopDailyRewardSlotTimer()
	stopRestingAreaTimer()

	if not dayStreakDay or dayStreakDay < 0 or dayStreakDay > 6 then
		dayStreakDay = 0
	end

	if not wasDailyRewardTaken or wasDailyRewardTaken < 0 then
		wasDailyRewardTaken = 0
	end

	-- Older client builds don't forward canGetReward; the reward is claimable whenever it hasn't been taken.
	local canClaim = canGetReward == 2 or (canGetReward == nil and wasDailyRewardTaken == 0)
	local currentIndex = dayStreakDay + 1
	local dailyRewardsPanel = rewardWallController.ui.dailyRewardsPanel

	for i = 1, 6 do
		local rewardArrow = dailyRewardsPanel:getChildById("arrow" .. i)

		if rewardArrow then
			if i < currentIndex then
				rewardArrow:setImageClip(REWARD_ARROW_CLIPS.CURRENT_LEFT)
			else
				rewardArrow:setImageClip(REWARD_ARROW_CLIPS.DEFAULT)
			end
		end
	end

	for i = 1, 7 do
		local rewardWidget = dailyRewardsPanel:getChildById("reward" .. i)

		if not rewardWidget then
			break
		end

		local rewardButton = rewardWidget:getChildById("rewardButton" .. i)
		local goldSlot = rewardWidget:getChildById("rewardGold" .. i)

		wireRewardButtonClick(rewardButton)

		if i < currentIndex then
			setupRewardGoldOverlay(goldSlot, "RewardGoldCollected")
			setRewardGoldSlotState(goldSlot)
			setRewardDayButtonState(rewardButton, REWARD_BUTTON_MODE.COLLECTED)

			goldSlot.status = STATUS.COLLECTED
		elseif i == currentIndex then
			setRewardGoldSlotState(goldSlot)

			if canClaim then
				local overlay = setupRewardGoldOverlay(goldSlot, "RewardGoldCollectable")

				updateRewardGoldCollectableOverlay(overlay)
				setRewardDayButtonState(rewardButton, REWARD_BUTTON_MODE.COLLECTABLE)
			else
				local overlay = setupRewardGoldOverlay(goldSlot, "RewardGoldContent")

				startDailyRewardSlotTimer(overlay, nextRewardTime)
				setRewardDayButtonState(rewardButton, REWARD_BUTTON_MODE.WAITING)
			end

			goldSlot.status = STATUS.ACTIVE
		else
			setupRewardGoldOverlay(goldSlot, "RewardGoldLocked")
			setRewardGoldSlotState(goldSlot)
			setRewardDayButtonState(rewardButton, REWARD_BUTTON_MODE.LOCKED)

			goldSlot.status = STATUS.LOCKED
		end
	end

	updateRestingAreaTimeLeft(canClaim, timeLeft)
end

local function getDayStreakIcon(dayStreakLevel)
	local IconConsecutiveDays = {
		[24] = "icon-rewardstreak-default",
		[49] = "icon-rewardstreak-bronze",
		[99] = "icon-rewardstreak-silver",
		[100] = "icon-rewardstreak-gold"
	}

	if dayStreakLevel <= 24 then
		return IconConsecutiveDays[24]
	elseif dayStreakLevel <= 49 then
		return IconConsecutiveDays[49]
	elseif dayStreakLevel <= 99 then
		return IconConsecutiveDays[99]
	else
		return IconConsecutiveDays[100]
	end
end

local function getBonusDescription(bonusName, streakCount, activeBonuses)
	local isPremium = g_game.getLocalPlayer():isPremium()

	return string.format("Permite [color=#909090]%s[/color]%s\nEste bonus est\225 activo porque eres [color=%s]Premium[/color] y alcanzaste una racha de recompensas de al menos [color=#44AD25]%d[/color].%s", bonusNameEs(bonusName), isPremium and "" or "[color=#ff0000](Bloqueado)[/color]", isPremium and "#44AD25" or "#ff0000", streakCount, isPremium and ("\n\nBonus activos: [color=#909090]%s[/color]."):format(activeBonuses) or "")
end

local function checkRewards(data)
	local premium = g_game.getLocalPlayer():isPremium()
	local rewardType = premium and data.premiumRewards or data.freeRewards
	local altType = premium and data.freeRewards or data.premiumRewards

	for index = 1, #rewardType do
		local reward = rewardType[index]
		local altReward = altType[index]
		local freeReward = data.freeRewards[index]
		local premiumReward = data.premiumRewards[index]
		local rewardBundle = reward.bundleItems and reward.bundleItems[1]
		local altBundle = altReward and altReward.bundleItems and altReward.bundleItems[1]
		local bundle = rewardBundle or altBundle
		local freeBundle = freeReward and freeReward.bundleItems and freeReward.bundleItems[1]
		local premiumBundle = premiumReward and premiumReward.bundleItems and premiumReward.bundleItems[1]
		local rewardWidget = rewardWallController.ui.dailyRewardsPanel:getChildById("reward" .. index)

		if not rewardWidget then
			break
		end

		local rewardButton = rewardWidget:getChildById("rewardButton" .. index)

		if not rewardButton then
			break
		end

		local hasSelectableItems = reward.selectableItems and next(reward.selectableItems) ~= nil
		local iconWidget = rewardButton

		if hasSelectableItems then
			iconWidget:setIcon("game_rewardwall/images/icon-reward-pickitems")

			rewardButton.bundleType = bundleType.ITEMS
			rewardButton.rewardItem = reward.selectableItems
			rewardButton.itemsToSelect = {
				free = freeReward and freeReward.itemsToSelect or 0,
				premium = premiumReward and premiumReward.itemsToSelect or 0
			}
		elseif bundle and bundle.bundleType == bundleType.XPBOOST then
			iconWidget:setIcon("game_rewardwall/images/icon-reward-xpboost")

			rewardButton.bundleType = bundleType.XPBOOST
			rewardButton.itemsToSelect = {
				free = freeBundle and freeBundle.itemId or 0,
				premium = premiumBundle and premiumBundle.itemId or 0
			}
		elseif bundle then
			iconWidget:setIcon("game_rewardwall/images/icon-reward-fixeditems")

			rewardButton.bundleType = bundleType.PREY
			rewardButton.itemsToSelect = {
				free = freeBundle and freeBundle.count or 0,
				premium = premiumBundle and premiumBundle.count or 0
			}
			rewardButton.itemName = bundle.name or "Prey Wildcard"
		else
			rewardButton.bundleType = nil
			rewardButton.rewardItem = nil
			rewardButton.itemsToSelect = nil
			rewardButton.itemName = nil
			print("WARNING: Reward has no selectable items or bundle:", index)
		end
	end
end

local function onDailyRewardCollectionState(state)
	if not rewardWallController.ui then
		return
	end

	local text = {
		[DailyRewardStatus.DAILY_REWARD_COLLECTED] = "Ya reclamaste tu recompensa diaria.",
		[DailyRewardStatus.DAILY_REWARD_NOTCOLLECTED] = "No reclamaste tu recompensa diaria a tiempo.\n Si no la reclamas ahora, [color=#D33C3C]tu racha se reiniciar\225[/color].",
		[DailyRewardStatus.DAILY_REWARD_NOTAVAILABLE] = "Tu recompensa diaria no est\225 disponible en este momento."
	}

	if not text[state] then
		return
	end

	rewardWallController.ui.restingAreaPanel.streakWarning:parseColoredText(text[state], "#c0c0c0")
end

local function onRestingAreaState(zone, state, message)
	--updatePlayerRestingAreaState(zone, state, message)

	if ZONE.LAST_ZONE == zone then
		return
	end

	ZONE.LAST_ZONE = zone

	local gameInterface = modules.game_interface

	if zone == ZONE.RESTING_AREA_ZONE then
		gameInterface.processIcon(ZONE.NUMERIC_ICON_ID, function(icon)
			icon:setTooltip(message)
		end, true)
	else
		gameInterface.processIcon(ZONE.ICON_ID, function(icon)
			icon:destroy()
		end)
	end
end

local function onDailyReward(data)
	if not data then
		return
	end

	bonuses = data.bonuses or {}

	checkRewards(data)
end

local function onServerError(code, error)
	claimPending = false
	generalBox = destroyWindows(generalBox)

	local function cancelCallback()
		generalBox = destroyWindows(generalBox)

		requestRewardWall()
		rewardWallController.ui:show()
		rewardWallController.ui:raise()
        rewardWallController.ui:focus()
	end

	local standardButtons = {
		{
			text = "Aceptar",
			callback = cancelCallback
		}
	}

	generalBox = displayGeneralBox3(rewardWallController.ui:getText(), error, standardButtons)
end

local function connectOnServerError()
	if serverErrorConnected then
		return
	end

	connect(g_game, {
		onServerError = onServerError
	})

	serverErrorConnected = true
end

local function disconnectOnServerError()
	if not serverErrorConnected then
		return
	end

	disconnect(g_game, {
		onServerError = onServerError
	})

	serverErrorConnected = false
end

-- Instant Reward Access purchases don't push a balance update, so re-request the wall data
-- without pulling the wall in front of the store.
local function onStorePurchaseComplete()
	if rewardWallController.ui and rewardWallController.ui:isVisible() and not claimPending then
		requestRewardWall(true)
	end
end

local function onCloseRewardWall()
	if claimPending then
		hide(false)

		if claimCloseResetEvent then
			removeEvent(claimCloseResetEvent)
		end

		claimCloseResetEvent = scheduleEvent(function()
			claimCloseResetEvent = nil

			if claimPending then
				claimPending = false
			end

			if not rewardWallController.ui:isVisible() then
				disconnectOnServerError()
			end
		end, 2000)

		return
	end

	hide(true)
end

local function onOpenRewardWall(bonusShrines, nextRewardTime, dayStreakDay, wasDailyRewardTaken, errorMessage, tokens, timeLeft, dayStreakLevel, canGetReward)
	local quietRefresh = table.remove(pendingWallRequests, 1) == true

	-- Quiet refreshes are only sent with no claim pending, so a pending claim here was started after
	-- the store refresh; its own reply follows. Also never reopen a dismissed wall.
	if quietRefresh and (claimPending or not rewardWallController.ui:isVisible()) then
		return
	end

	if claimCloseResetEvent then
		removeEvent(claimCloseResetEvent)

		claimCloseResetEvent = nil
	end

	claimPending = false
	pendingRewardButton = nil
	bonusShrine = bonusShrines

	updateDailyRewards(dayStreakDay, wasDailyRewardTaken, nextRewardTime, canGetReward, timeLeft)
	premiumStatusWindwos(g_game.getLocalPlayer():isPremium())
	rewardWallController.ui:show()
	vipRewardsRequestState()

	if not quietRefresh then
		rewardWallController.ui:raise()
		rewardWallController.ui:focus()
	end

	connectOnServerError()
	rewardWallController.ui.restingAreaPanel.restingAreaInfo.rewardStreakIcon:setText(dayStreakLevel)
	updateRestingAreaBonusIcons(dayStreakLevel)

	if tokens and tokens > 999999 then
		tokens = 0
	end

	rewardWallController.ui.restingAreaPanel.restingAreaInfo.restingAreaGold.text:setText(tokens or 0)
	rewardWallController.ui.footerPanel.footerGold1.text:setText(tokens or 0)
	rewardWallController.ui.restingAreaPanel.restingAreaInfo.rewardStreakIcon:setImageSource("/game_rewardwall/images/" .. getDayStreakIcon(dayStreakLevel))
	rewardWallController.ui.footerPanel.footerGold2.text:setText(g_game.getLocalPlayer():getResourceBalance(ResourceTypes.DAILYREWARD_STREAK))
end

local function historyDescriptionMarginTop(descriptionLabel, text)
	descriptionLabel:setText(text)
	descriptionLabel:setTextWrap(false)

	local wraps = descriptionLabel:getTextSize().width > descriptionLabel:getWidth()

	descriptionLabel:setTextWrap(true)

	return wraps and -3 or -16
end

local function onRewardHistory(rewardHistory)
	local transferHistory = rewardWallController.ui.historyPanel.historyList.List

	transferHistory:destroyChildren()

	local headerRow = g_ui.createWidget("historyData2", transferHistory)

	headerRow:setBackgroundColor("#363636")
	headerRow.date:setText("Fecha")
	headerRow.Balance:setText("Racha")
	headerRow.Description:setText("Evento")

	for i, data in ipairs(rewardHistory) do
		local row = g_ui.createWidget("historyData2", transferHistory)

		row:setHeight(30)
		row.date:setText(convert_timestamp(data[1]))
		row.date:setMarginTop(-16)
		row.Balance:setText(data[4])
		row.Balance:setMarginTop(-12)
		row.Balance:setTextOffset("-6 -2")
		row.Description:setMarginTop(historyDescriptionMarginTop(row.Description, data[3]))
		row:setBackgroundColor(i % 2 == 0 and "#ffffff12" or "#00000012")
	end
end

function show()
	if not rewardWallController.ui then
		return
	end

	if not rewardWallController.ui:isVisible() then
		requestRewardWall()
	end

	rewardWallController.ui:show()
	rewardWallController.ui:raise()
    rewardWallController.ui:focus()
	connectOnServerError()
	premiumStatusWindwos(g_game.getLocalPlayer():isPremium())
end

function hide(bool)
	if not rewardWallController.ui then
		return
	end

	stopDailyRewardSlotTimer()
	stopRestingAreaTimer()
	resetHistoryView()
	rewardWallController.ui:hide()

	if bool then
		disconnectOnServerError()
	end
end

function toggle()
	if not rewardWallController.ui then
		return
	end

	if rewardWallController.ui:isVisible() then
		if ButtonRewardWall then
			ButtonRewardWall:setOn(false)
		end

		return hide(true)
	end

	show()
end

local INFO_PANEL_COLOR = "#c0c0c0"

local function clearInfoPanel()
	if not rewardWallController.ui or not rewardWallController.ui.infoPanel then
		return
	end

	local infoPanel = rewardWallController.ui.infoPanel

	infoPanel.statusText:setText("")
	infoPanel.statusText:setVisible(true)
	infoPanel.free:setText("")
	infoPanel.free:setVisible(false)
	infoPanel.premium:setText("")
	infoPanel.premium:setVisible(false)
end

local function showInfoPanelDescription(text, colored)
	if not rewardWallController.ui or not rewardWallController.ui.infoPanel then
		return
	end

	local infoPanel = rewardWallController.ui.infoPanel

	infoPanel.free:setVisible(false)
	infoPanel.premium:setVisible(false)
	infoPanel.statusText:setVisible(true)
	infoPanel.statusText:raise()

	text = text or ""

	if colored then
		infoPanel.statusText:parseColoredText(text, INFO_PANEL_COLOR)
	else
		infoPanel.statusText:setText(text)
		infoPanel.statusText:setColor(INFO_PANEL_COLOR)
	end
end

local function showInfoPanelRewardSplit(freeText, premiumText)
	if not rewardWallController.ui or not rewardWallController.ui.infoPanel then
		return
	end

	local infoPanel = rewardWallController.ui.infoPanel

	infoPanel.statusText:setText("")
	infoPanel.statusText:setVisible(false)
	infoPanel.statusText:lower()
	infoPanel.free:setVisible(true)
	infoPanel.premium:setVisible(true)
	infoPanel.free:raise()
	infoPanel.premium:raise()
	infoPanel.free:setText(freeText or "")
	infoPanel.premium:setText(premiumText or "")
end

local function wireHover(widget, handler)
	if not widget then
		return
	end

	function widget:onHoverChange(hovered)
		handler({
			target = self,
			value = hovered
		})
	end
end

local function setupRewardWallHovers()
	local ui = rewardWallController.ui

	if not ui then
		return
	end

	local restingInfo = ui.restingAreaPanel.restingAreaInfo

	wireHover(restingInfo.rewardStreakIcon, function(e)
		rewardWallController:onhoverStatusPlayer(e)
	end)
	wireHover(restingInfo.timeLeft, function(e)
		rewardWallController:onhoverStatusPlayer(e)
	end)
	wireHover(restingInfo.restingAreaGold, function(e)
		rewardWallController:onhoverStatusPlayer(e)
	end)

	for i = 1, 6 do
		wireHover(ui.restingAreaPanel.bonusIcons:getChildById("bonusIcon" .. i), function(e)
			rewardWallController:onhoverBonus(e)
		end)
	end

	for i = 1, 7 do
		local rewardPanel = ui.dailyRewardsPanel:getChildById("reward" .. i)

		if rewardPanel then
			wireRewardButtonClick(rewardPanel:getChildById("rewardButton" .. i))
			wireHover(rewardPanel:getChildById("rewardButton" .. i), function(e)
				rewardWallController:onhoverRewardType(e)
			end)
			wireHover(rewardPanel:getChildById("rewardGold" .. i), function(e)
				rewardWallController:onhoverStatusReward(e)
			end)
		end
	end
end

local function setupRewardWallUi()
	rewardWallController.ui.footerPanel.footerGold1.text:setTextAlign(AlignRightCenter)
	clearInfoPanel()
	setupRewardWallHovers()
	initRewardGoldSlots()
end

function onHoverBonusChange(widget, hovered)
	rewardWallController:onhoverBonus({
		target = widget,
		value = hovered
	})
end

function onHoverStatusPlayerChange(widget, hovered)
	rewardWallController:onhoverStatusPlayer({
		target = widget,
		value = hovered
	})
end

function onHoverRewardTypeChange(widget, hovered)
	rewardWallController:onhoverRewardType({
		target = widget,
		value = hovered
	})
end

function onHoverStatusRewardChange(widget, hovered)
	rewardWallController:onhoverStatusReward({
		target = widget,
		value = hovered
	})
end

function onClickPickReward(widget)
	rewardWallController:onClickDisplayWindowsPickRewardWindow({
		target = widget
	})
end

function rewardWallController:onInit()
	g_ui.importStyle("styles/style.otui")
	rewardWallController:loadUI("game_rewardwall")

	if not rewardWallController.ui then
		g_logger.error("[game_rewardwall] failed to load game_rewardwall.otui")

		return
	end

	rewardWallController.ui:hide()
	rewardWallController:registerEvents(g_game, {
		onOpenRewardWall = onOpenRewardWall,
		onCloseRewardWall = onCloseRewardWall,
		onDailyReward = onDailyReward,
		onRewardHistory = onRewardHistory,
		onRestingAreaState = onRestingAreaState,
		onDailyRewardCollectionState = onDailyRewardCollectionState,
		onParseStoreGetPurchaseStatus = onStorePurchaseComplete
	})
	setupRewardWallUi()
	vipRewardsInit()
end

function rewardWallController:onTerminate()
	vipRewardsTerminate()
	stopDailyRewardSlotTimer()
	stopRestingAreaTimer()

	generalBox, windowsPickWindow, ButtonRewardWall = destroyWindows({
		generalBox,
		windowsPickWindow,
		ButtonRewardWall
	})
end

function rewardWallController:onGameStart()
	if g_game.getClientVersion() > 1140 then
		if not ButtonRewardWall then
			ButtonRewardWall = modules.game_mainpanel.addToggleButton("rewardWall", tr("Abrir muro de recompensas"), "/images/options/button_reward_wall", toggle, false, 21)
		end
	else
		scheduleEvent(function()
			g_modules.getModule("game_rewardwall"):unload()
		end, 100)
	end
end

function rewardWallController:onGameEnd()
	vipRewardsReset()
	stopDailyRewardSlotTimer()
	stopRestingAreaTimer()
	disconnectOnServerError()

	if claimCloseResetEvent then
		removeEvent(claimCloseResetEvent)

		claimCloseResetEvent = nil
	end

	claimPending = false
	pendingWallRequests = {}
	resetHistoryView()

	if rewardWallController.ui:isVisible() then
		rewardWallController.ui:hide()

		if ButtonRewardWall then
			ButtonRewardWall:setOn(false)
		end
	end

	generalBox, windowsPickWindow = destroyWindows({
		generalBox,
		windowsPickWindow
	})
end

function rewardWallController:onClickshowHistory()
	visibleHistory(not rewardWallController.ui.historyPanel:isVisible())
	g_game.requestOpenRewardHistory()
	rewardWallController.ui.footerPanel.historyButton:setText(rewardWallController.ui.historyPanel:isVisible() and "Volver" or "Historial")
end

function rewardWallController:onClickToggle()
	toggle()
end

function rewardWallController:onClickSendStoreRewardWall()
	modules.game_store.toggle()
    g_game.sendRequestStorePremiumBoost()
end

function rewardWallController:onClickSendStoreJoker()
	modules.game_store.toggle()
    g_game.sendRequestUsefulThings(StoreConst.INSTANT_REWARD)
end

function rewardWallController:onClickDisplayWindowsPickRewardWindow(event)
	if event.target.rewardVisualMode ~= REWARD_BUTTON_MODE.COLLECTABLE or claimPending then
		return
	end

	if event.target.bundleType == bundleType.ITEMS then
		local isPremium = g_game.getLocalPlayer():isPremium()
		local itemsToSelect = event.target.itemsToSelect

		if not windowsPickWindow then
			if type(itemsToSelect) == "table" then
				itemsToSelect = itemsToSelect[isPremium and "premium" or "free"]
			else
				itemsToSelect = itemsToSelect or 1
			end

			windowsPickWindow = g_ui.displayUI("styles/pickreward")

			windowsPickWindow:show()
			windowsPickWindow:raise()
            windowsPickWindow:focus()
			windowsPickWindow:getChildById("capacity"):setText("Capacidad libre: " .. g_game:getLocalPlayer():getFreeCapacity() .. " oz")

			local text = string.format("Has seleccionado [color=#D33C3C]0[/color] de %d objetos de recompensa", itemsToSelect)

			windowsPickWindow:getChildById("rewardLabel"):parseColoredText(text, "#c0c0c0")

			for i, item in pairs(event.target.rewardItem) do
				local getItem = g_ui.createWidget("ItemReward", windowsPickWindow:getChildById("rewardList"))

				getItem:getChildById("item"):setItemId(item.itemId)
				getItem:getChildById("title"):setText(item.name)
				getItem:setBackgroundColor(i % 2 == 0 and COLORS.BASE_1 or COLORS.BASE_2)

				getItem.totalWeight = item.weight or 1
				getItem.itemsToSelect = itemsToSelect
			end

			actualUsed = {}

			scheduleEvent(function()
				refreshAllPickRewardRows()
			end, 1)
			hide()
		else
			windowsPickWindow:show()
			windowsPickWindow:raise()
            windowsPickWindow:focus()
		end
	elseif event.target.bundleType == bundleType.XPBOOST or event.target.bundleType == bundleType.PREY then
		local function claimReward()
			if not beginClaim() then
				return
			end

			hide()
			actualUsed = {}
			claimInstantDailyReward()
		end

		if getClaimUsedToken() == 1 then
			local buttons = {
				{
					text = "Cancelar",
					callback = function()
						generalBox = destroyWindows(generalBox)
					end
				},
				{
					text = "Aceptar",
					callback = claimReward
				}
			}

			generalBox = displayGeneralBox3("Confirmar recompensa diaria", "Reclamar esta recompensa usar\225 1 Acceso instant\225neo a recompensas. \191Continuar?", buttons)

			return
		end

		claimReward()
	end
end

function rewardWallController:onhoverBonus(event)
	if not event.value then
		clearInfoPanel()

		return
	end

	local id = event.target:getId()
	local index = tonumber(id:match("%d+"))
	local bonus = bonuses[index]

	if not bonus then
		showInfoPanelDescription("Bonus desconocido.", false)

		return
	end

	local isPremium = g_game.getLocalPlayer():isPremium()
	local requiresPremium = bonus.name ~= "Hit Point Regeneration" and bonus.name ~= "Mana Regeneration"
	local isLocked = rewardStreakLevel < bonus.id or (requiresPremium and not isPremium)
	local lockedTitle = isLocked and "[color=#ff0000](Bloqueado)[/color]" or ""
	local activeBonuses = isPremium and not isLocked and ("\n\nBonus activos: %s."):format(getBonusStrings(bonuses)) or ""
	local bonusText = ""

	if not requiresPremium then
		bonusText = string.format("%s %s\nEste bonus est\225 activo si alcanzaste una racha de recompensas de al menos [color=#44AD25]%d[/color].%s", bonusNameEs(bonus.name), lockedTitle, bonus.id, activeBonuses)
	else
		bonusText = string.format("%s %s\nEste bonus est\225 activo si eres [color=%s]Premium[/color] y alcanzaste una racha de recompensas de al menos [color=#44AD25]%d[/color].%s", bonusNameEs(bonus.name), lockedTitle, isPremium and "#44AD25" or "#ff0000", bonus.id, activeBonuses)
	end


	showInfoPanelDescription(bonusText, true)
end

function rewardWallController:onhoverStatusPlayer(event)
	if not event.value then
		clearInfoPanel()

		return
	end

	local playerStatus = {
		rewardStreakIcon = "Esta es tu racha de recompensas. Mientras reclames tu recompensa diaria una vez entre dos guardados del servidor, tu racha seguir\225 subiendo. Con una racha de al menos 2, tu personaje recibe bonus en las zonas de descanso. Las cuentas gratuitas alcanzan el bonus m\225ximo con una racha de 3. Los jugadores Premium con una racha de 7 o m\225s reciben los mejores bonus en las zonas de descanso.",
		timeLeft = "Aviso urgente: reclama tu recompensa diaria antes del pr\243ximo guardado del servidor para subir tu racha en 1. Si no lo haces, se usar\225n comodines de recompensa diaria para que tu racha no se reinicie. Sube tu racha para obtener bonus en las zonas de descanso.",
		restingAreaGold = "Los comodines de recompensa diaria te ayudan a mantener tu racha. Si alg\250n d\237a no puedes reclamar tu recompensa, se usa un comod\237n para continuar la racha. Cuantos m\225s comodines tengas, m\225s d\237as puedes cubrir.\nCada personaje recibe un comod\237n el primer d\237a de cada mes, hasta un m\225ximo de 3.\nPara ir sobre seguro, recuerda recoger tu recompensa todos los d\237as."
	}
	local DEFAULT_MESSAGE = "Bonus desconocido."
	local id = event.target:getId()
	local info = playerStatus[id]

	showInfoPanelDescription(info or DEFAULT_MESSAGE, true)
end

function rewardWallController:onhoverRewardType(event)
	if not event.value then
		clearInfoPanel()

		return
	end

	local itemsToSelect = event.target.itemsToSelect or {
		free = 1,
		premium = 1
	}
	local freeAmount = 0
	local premiumAmount = 0

	if type(itemsToSelect) == "table" then
		freeAmount = itemsToSelect.free or 0
		premiumAmount = itemsToSelect.premium or 0
	else
		freeAmount = itemsToSelect
		premiumAmount = itemsToSelect
	end

	local rewardType = event.target.bundleType
	local rewardTexts = {}

	if rewardType == bundleType.ITEMS then
		rewardTexts = {
			free = string.format("Recompensa para cuentas gratuitas:\nElige %d %s de la lista. Entre\notros incluye: una espada de\nentrenamiento, un arco de\nentrenamiento y unas vendas", freeAmount, freeAmount == 1 and "objeto" or "objetos"),
			premium = string.format("Recompensa para cuentas Premium:\nElige %d %s de la lista. Entre\notros incluye: una espada de\nentrenamiento, un arco de\nentrenamiento y unas vendas", premiumAmount, premiumAmount == 1 and "objeto" or "objetos")
		}
	elseif rewardType == bundleType.PREY then
		local itemName = event.target.itemName or "Prey Wildcard"

		rewardTexts = {
			free = string.format("Recompensa para cuentas gratuitas:\n %dx %s", freeAmount, itemNameEs(itemName)),
			premium = string.format("Recompensa para cuentas Premium:\n %dx %s", premiumAmount, itemNameEs(itemName))
		}
	elseif rewardType == bundleType.XPBOOST then
		rewardTexts = {
			free = string.format("Recompensa para cuentas gratuitas:\n %d minutos de Potenciador de XP del 50%%", freeAmount),
			premium = string.format("Recompensa para cuentas Premium:\n %d minutos de Potenciador de XP del 50%%", premiumAmount)
		}
	else
		print("WARNING: Unknown rewardType:", rewardType)

		return
	end

	showInfoPanelRewardSplit(rewardTexts.free, rewardTexts.premium)
end

function rewardWallController:onhoverStatusReward(event)
	local statusReward = {
		[STATUS.COLLECTED] = "Ya recogiste esta recompensa diaria.\nLas recompensas diarias siguen un ciclo: cada d\237a que reclamas, obtienes la siguiente recompensa. El ciclo se repite tras 7 recompensas reclamadas. Podr\225s volver a reclamar esta recompensa cuando llegues a esta posici\243n en el siguiente ciclo.",

		[STATUS.ACTIVE] = "Puedes reclamar esta recompensa diaria ahora.\nSi la reclamas desde aqu\237, te costar\225 1 Acceso instant\225neo a recompensas.\nRec\243gela gratis visitando un santuario de recompensas.",

		[STATUS.LOCKED] = "Esta recompensa diaria todav\237a est\225 bloqueada.\nPrimero recoge las recompensas anteriores de este ciclo."

	}

	if not event.value then
		clearInfoPanel()

		return
	end

	local status = event.target.status

	showInfoPanelDescription(statusReward[status] or "Estado de recompensa desconocido.", false)
end

function onClickBtnOk()
	if table.empty(getSelectedRewardItems()) or claimPending then
		return
	end

	if not beginClaim() then
		return
	end

	claimInstantDailyReward()
end

function destroyPickReward(bool)
	windowsPickWindow = destroyWindows(windowsPickWindow)

	if bool then
		requestRewardWall()
		rewardWallController.ui:show()
		rewardWallController.ui:raise()
        rewardWallController.ui:focus()
	end
end

local REWARD_ITEM_WEIGHT_SCALE = 100

local function formatRewardItemWeight(weightUnits)
	return string.format("%.2f oz", (weightUnits or 0) / REWARD_ITEM_WEIGHT_SCALE)
end

local function getPickRewardMaxAllowed(row, itemId)
	local thisPanelUsed = actualUsed[itemId] or 0
	local alreadyUsed = 0

	for _, count in pairs(actualUsed) do
		alreadyUsed = alreadyUsed + (count or 0)
	end

	return math.max(0, row.itemsToSelect - (alreadyUsed - thisPanelUsed))
end

local function resolvePickRewardRow(widget)
	local row = widget

	while row do
		if row.itemsToSelect then
			return row
		end

		row = row:getParent()
	end

	return nil
end

local function updatePickRewardQuantityUi(row)
	if not row or not row.itemsToSelect or not windowsPickWindow then
		return
	end

	local itemWidget = row:recursiveGetChildById("item")
	local quantity = row:recursiveGetChildById("quantity")

	if not itemWidget or not quantity then
		return
	end

	local itemId = itemWidget:getItemId()
	local maxAllowed = getPickRewardMaxAllowed(row, itemId)
	local value = math.min(actualUsed[itemId] or 0, maxAllowed)

	actualUsed[itemId] = value

	local numberValue = quantity:recursiveGetChildById("numberValue")
	local btnMin = quantity:getChildById("btnMin")
	local btnDec = quantity:getChildById("btnDec")
	local btnInc = quantity:getChildById("btnInc")
	local btnMax = quantity:getChildById("btnMax")

	if not numberValue or not btnMin or not btnDec or not btnInc or not btnMax then
		return
	end

	numberValue:setText(tostring(value))
	btnMin:setEnabled(value > 0)
	btnDec:setEnabled(value > 0)
	btnInc:setEnabled(value < maxAllowed)
	btnMax:setEnabled(value < maxAllowed)

	local weightLabel = row:recursiveGetChildById("weight")

	if weightLabel then
		weightLabel:setText(formatRewardItemWeight(value * row.totalWeight))
	end
end

local function refreshPickRewardSummary(referenceRow)
	if not windowsPickWindow or not referenceRow or not referenceRow.itemsToSelect then
		return
	end

	local alreadyUsed = 0

	for _, count in pairs(actualUsed) do
		alreadyUsed = alreadyUsed + (count or 0)
	end

	local color = alreadyUsed == 0 and "#D33C3C" or "#00FF00"

	windowsPickWindow:getChildById("btnOk"):setEnabled(alreadyUsed > 0)

	local text = string.format("Has seleccionado [color=%s]%d[/color] de %d objetos de recompensa", color, alreadyUsed, referenceRow.itemsToSelect)

	windowsPickWindow:getChildById("rewardLabel"):parseColoredText(text, "#c0c0c0")

	local totalWeight = 0

	for _, widget in pairs(windowsPickWindow:getChildById("rewardList"):getChildren()) do
		if widget.itemsToSelect and widget.totalWeight then
			local itemWidget = widget:recursiveGetChildById("item")

			if itemWidget then
				local id = itemWidget:getItemId()

				totalWeight = totalWeight + (actualUsed[id] or 0) * widget.totalWeight
			end
		end
	end

	local weightLabel = windowsPickWindow:getChildById("weight")

	weightLabel:setText(string.format("Peso total: %s", formatRewardItemWeight(totalWeight)))
	weightLabel:resizeToText()
end

function refreshAllPickRewardRows()
	if not windowsPickWindow then
		return
	end

	local rewardList = windowsPickWindow:getChildById("rewardList")
	local referenceRow

	for _, row in pairs(rewardList:getChildren()) do
		if row.itemsToSelect and row:recursiveGetChildById("quantity") then
			referenceRow = row

			updatePickRewardQuantityUi(row)
		end
	end

	if referenceRow then
		refreshPickRewardSummary(referenceRow)
	end
end

function onPickRewardQtyClick(widget, action)
	local row = resolvePickRewardRow(widget)

	if not row then
		return
	end

	local itemWidget = row:recursiveGetChildById("item")

	if not itemWidget then
		return
	end

	local itemId = itemWidget:getItemId()
	local value = actualUsed[itemId] or 0
	local maxAllowed = getPickRewardMaxAllowed(row, itemId)

	if action == "min" then
		value = 0
	elseif action == "dec" then
		value = math.max(0, value - 1)
	elseif action == "inc" then
		value = math.min(maxAllowed, value + 1)
	elseif action == "max" then
		value = maxAllowed
	end

	actualUsed[itemId] = value

	refreshAllPickRewardRows()
end

function displayGeneralBox3(title, message, buttons, onEnterCallback, onEscapeCallback)
	if generalBox then
		generalBox = destroyWindows(generalBox)
	end

	generalBox = g_ui.createWidget("MessageBoxWindow", rootWidget)

	if not generalBox then
		return nil
	end

	local titleWidget = generalBox:getChildById("title")

	if titleWidget then
		titleWidget:setText(title)
	end

	local holder = generalBox:getChildById("holder")

	if holder and buttons then
		for i = 1, #buttons do
			local button = g_ui.createWidget("Button", holder)
			local buttonId = buttons[i].text:lower():gsub(" ", "_")

			button:setId(buttonId)
			button:setText(buttons[i].text)
			button:setWidth(math.max(86, 10 + string.len(buttons[i].text) * 8))
			button:setHeight(20)
			button:setMarginTop(-5)

			if i == 1 then
				button:addAnchor(AnchorTop, "parent", AnchorTop)
				button:addAnchor(AnchorRight, "parent", AnchorRight)
			else
				button:addAnchor(AnchorTop, "parent", AnchorTop)
				button:addAnchor(AnchorRight, "prev", AnchorLeft)
				button:setMarginRight(5)
			end

			button.onClick = buttons[i].callback
		end
	end

	if onEnterCallback then
		generalBox.onEnter = onEnterCallback
	end

	if onEscapeCallback then
		generalBox.onEscape = onEscapeCallback
	end

	local content = generalBox:getChildById("content")

	if not content then
		generalBox = destroyWindows(generalBox)

		return nil
	end

	content:setText(message)
	content:resizeToText()

	local contentWidth = content:getWidth() + 32
	local contentHeight = content:getHeight() + 42 + (holder and holder:getHeight() or 0)

	generalBox:setWidth(math.min(916, math.max(300, contentWidth)))
	generalBox:setHeight(math.min(616, math.max(119, contentHeight)))

	function generalBox:setContent(newMessage)
		local content = generalBox:getChildById("content")

		if not content then
			return
		end

		content:setText(newMessage)
		content:resizeToText()
		content:setTextWrap(false)
		content:setTextAutoResize(false)

		local holder = generalBox:getChildById("holder")

		if not holder then
			return
		end

		local contentWidth = content:getWidth() + 32
		local contentHeight = content:getHeight() + 50 + holder:getHeight()

		generalBox:setWidth(math.min(736, math.max(300, contentWidth)))
		generalBox:setHeight(math.min(300, math.max(89, contentHeight)))
	end

	function generalBox:setTitle(newTitle)
		local titleWidget = generalBox:getChildById("title")

		if not titleWidget then
			return
		end

		titleWidget:setText(newTitle)
	end

	function generalBox:modifyButton(buttonId, newText, newCallback)
		local holder = generalBox:getChildById("holder")

		if not holder then
			return nil
		end

		local button = holder:getChildById(buttonId)

		if button then
			if newText then
				button:setText(newText)
				button:setWidth(math.max(86, 10 + string.len(newText) * 8))
			end

			if newCallback then
				disconnect(button, {
					onClick = button.onClick
				})
				connect(button, {
					onClick = newCallback
				})

				button.onClick = newCallback
			end
		end

		return button
	end

	generalBox:show()
	generalBox:raise()
    generalBox:focus()

	return generalBox
end

function managerMessageBoxWindow(id)
	local config = BOX_CONFIGS[id]

	if not config then
		return
	end

	local function cancelCallback()
		generalBox, windowsPickWindow = destroyWindows({
			generalBox,
			windowsPickWindow
		})

		requestRewardWall()
		rewardWallController.ui:show()
		rewardWallController.ui:raise()
        rewardWallController.ui:focus()
	end

	local okCallback = config.okCallback or function()
		generalBox, windowsPickWindow = destroyWindows({
			generalBox,
			windowsPickWindow
		})

		requestRewardWall()
		rewardWallController.ui:show()
        rewardWallController.ui:raise()
        rewardWallController.ui:focus()
	end
	local standardButtons = {
		{
			text = "Cancelar",
			callback = cancelCallback
		},
		{
			text = "Aceptar",
			callback = okCallback
		}
	}

	generalBox = displayGeneralBox3(config.title, config.content, standardButtons)

	rewardWallController.ui:hide()

	if windowsPickWindow then
		windowsPickWindow = destroyWindows(windowsPickWindow)
	end
end
