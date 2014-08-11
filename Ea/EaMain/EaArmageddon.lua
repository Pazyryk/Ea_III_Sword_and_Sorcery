-- EaArmageddon
-- Author: Pazyryk
-- DateCreated: 4/13/2014 10:30:54 AM
--------------------------------------------------------------
print("Loading EaMagic.lua...")
local print = ENABLE_PRINT and print or function() end

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------
--constants
local STARTING_SUM_OF_ALL_MANA =		MapModData.EaSettings.STARTING_SUM_OF_ALL_MANA
local ARMAGEDDON_IMAGE_INFO =			GameInfo.EaPopups.EAPOPUP_DEATH_OTHER
local ARMAGEDDON_SOUND =				"AS2D_EVENT_NOTIFICATION_VERY_BAD"

--tables
local gWorld =			gWorld

--functions
local GetPlotByIndex =	Map.GetPlotByIndex
local Rand =			Map.Rand
local floor =			math.floor


--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function EaArmageddonPerTurn()
	local manaPercent = 100 * gWorld.sumOfAllMana / STARTING_SUM_OF_ALL_MANA
	local armageddonStage = gWorld.armageddonStage

	-- Warning popup. Civilizations begin to account for mana depletion in diplo relations.
	if 97.5 < manaPercent then return end
	if armageddonStage < 1 then
		gWorld.armageddonStage = 1
		print("Armageddon stage 1")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			local textKey = eaPlayer.bIsFallen and "TXT_KEY_EA_ARMAGEDDON_1B" or "TXT_KEY_EA_ARMAGEDDON_1A"
			LuaEvents.EaImagePopup({type = "Generic", textKey = textKey, imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
	end
	-- effect added in EaDiplomacy.lua

	-- Undead begin to spawn from old battlefields and city graveyards, and demons from breach
	-- plots (if any exist). 1% chance per plot per turn increasing to 10% as the Sum of All
	-- Mana depletes to zero.
	if 95 < manaPercent then return end
	if armageddonStage < 2 then
		gWorld.armageddonStage = 2
		print("Armageddon stage 2")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			LuaEvents.EaImagePopup({type = "Generic", textKey = "TXT_KEY_EA_ARMAGEDDON_2", imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
	end
	-- effect added in EaBarbarians.lua

	-- Begins to sap happiness and health from all civilizations. -2 for both increasing
	-- to -20 as the Sum of All Mana approaches zero.
	if 90 < manaPercent then return end
	if armageddonStage < 3 then
		gWorld.armageddonStage = 3
		print("Armageddon stage 3")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			LuaEvents.EaImagePopup({type = "Generic", textKey = "TXT_KEY_EA_ARMAGEDDON_3", imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
	end
	gWorld.armageddonSap = floor(0.2 * (90 - manaPercent) + 2)	--health sap applied in EaCities.lua and happiness sap in EaCivs.lua

	-- Blight begins to spread from already blighted plots, and breach from already breached
	-- plots. Blight spreads outward from existing blight (inhibited to some extent by living
	-- terrain). Breach, if present, spreads in fault-like patterns over land destroying
	-- everything in its path. The rate of spread increases as the Sum of All Mana
	-- depletes to zero.
	if 80 < manaPercent then return end
	if armageddonStage < 4 then
		gWorld.armageddonStage = 4
		print("Armageddon stage 4")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			LuaEvents.EaImagePopup({type = "Generic", textKey = "TXT_KEY_EA_ARMAGEDDON_4", imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
	end
	-- Spread stats changed in EaPlots.lua

	-- The world is corrupted by a surge of blight, affecting 1 out of every 20 plots.
	-- All mana accumulative processes are reduced by 33%, and reduced further toward 90% as
	-- the Sum of All Mana depletes to zero. (This does not affect divine favor.)
	if 70 < manaPercent then return end
	if armageddonStage < 5 then
		gWorld.armageddonStage = 5
		print("Armageddon stage 5")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			LuaEvents.EaImagePopup({type = "Generic", textKey = "TXT_KEY_EA_ARMAGEDDON_5", imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
		--blight surge
		for iPlot = 0, Map.GetNumPlots() - 1 do
			if Rand(20, "hello") == 0 then
				BlightPlot(GetPlotByIndex(iPlot))
			end
		end
	end
	-- TO DO: Implement mana effect!

	-- The fabric of the world begins to tear: 1 out of every 40 plots becomes Breached.
	-- Blight begins to appear spontaneously. 2.5% chance per unaffected plot per turn increasing
	-- to 10% as the Sum of All Mana depletes to zero.
	if 60 < manaPercent then return end
	if armageddonStage < 6 then
		gWorld.armageddonStage = 6
		print("Armageddon stage 6")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			LuaEvents.EaImagePopup({type = "Generic", textKey = "TXT_KEY_EA_ARMAGEDDON_6", imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
		--breach surge
		for iPlot = 0, Map.GetNumPlots() - 1 do
			if Rand(40, "hello") == 0 then
				BreachPlot(GetPlotByIndex(iPlot))
			end
		end
	end
	-- Spread stats changed in EaPlots.lua

	-- Pestilence, the first of the Four Horsemen, arrives riding a White Horse. He carries the
	-- Sickening Bow and the Plague Crown which cause (respectively) sickness in all units and
	-- plague in all cities that he attacks.
	if 50 < manaPercent then return end
	if armageddonStage < 7 then
		gWorld.armageddonStage = 7
		print("Armageddon stage 7")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			--LuaEvents.EaImagePopup({type = "Generic", textKey = "TXT_KEY_EA_ARMAGEDDON_7", imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
		--TO DO
	end

	-- War arrives riding a Red Horse. He carries a sword (also called War) that causes nearby
	-- civilizations to sever relationships and war upon each other, and the cities and units of
	-- larger civilizations to revolt and war upon their owners.
	if 40 < manaPercent then return end
	if armageddonStage < 8 then
		gWorld.armageddonStage = 8
		print("Armageddon stage 8")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			--LuaEvents.EaImagePopup({type = "Generic", textKey = "TXT_KEY_EA_ARMAGEDDON_8", imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
		--TO DO
	end

	-- Famine arrives riding a Black Horse. He carries the Scales of Insolvency which bring
	-- starvation to all nearby units and cities.
	if 30 < manaPercent then return end
	if armageddonStage < 9 then
		gWorld.armageddonStage = 9
		print("Armageddon stage 9")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			--LuaEvents.EaImagePopup({type = "Generic", textKey = "TXT_KEY_EA_ARMAGEDDON_9", imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
		--TO DO
	end

	-- Death arrives riding a Pale Horse. He carries no items but kills by sword, famine, plague
	-- and the enraged animals and beasts of Ea.
	if 20 < manaPercent then return end
	if armageddonStage < 10 then
		gWorld.armageddonStage = 10
		print("Armageddon stage 10")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			--LuaEvents.EaImagePopup({type = "Generic", textKey = "TXT_KEY_EA_ARMAGEDDON_10", imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
		--TO DO
	end

	-- Breach begins to appear spontaneously. Both breach and blight accelerate in their rate of
	-- spread. The spawning rate of demons (from breach) and undead (from killing fields left by
	-- the Four Horsemen) accelerates rapidly.
	if 5 < manaPercent then return end
	if armageddonStage < 11 then
		gWorld.armageddonStage = 11
		print("Armageddon stage 11")
		local eaPlayer = gPlayers[Game.GetActivePlayer()]
		if eaPlayer then			--will skip if autoplay
			LuaEvents.EaImagePopup({type = "Generic", textKey = "TXT_KEY_EA_ARMAGEDDON_11", imageInfo = ARMAGEDDON_IMAGE_INFO, sound = ARMAGEDDON_SOUND})
		end
	end
	-- effect added in EaPlots.lua

	-- The fabric of Ea unravels and the world ends in fiery Armageddon.
	if 1 < manaPercent then return end
	if armageddonStage < 12 then
		gWorld.armageddonStage = 12
		print("Armageddon stage 12")
		--To Do: EOTW fireworks
		TestUpdateVictory(Game.GetActivePlayer())		--ends game
	end

end


--EOTW (Emo Open To Wristcutting)

--nothing below works yet

local g_radius = -1
local g_minRadius = 0
local g_destroyerCapitalPlot

function EOTW(iDestroyerPlayer)
	local destroyerPlayer = Players[iDestroyerPlayer]
	local destroyerCapital = destroyerPlayer:GetCapitalCity()
	g_destroyerCapitalPlot = destroyerCapital:Plot()
	local bDestroyerIsActivePlayer = iDestroyerPerson == Game.GetActivePlayer()

	local cameraCenterPlot = bDestroyerIsActivePlayer and destroyerCapitalPlot or g_activePlayer:GetCapitalCity():Plot()
	local cameraX, cameraY = cameraCenterPlot:GetXY()
	local viewRadius = 10	--TO DO: calculate this
	local maxRadius = bDestroyerIsActivePlayer and viewRadius or PlotDistance(destroyerCapital:GetX(), destroyerCapital:GetY(), cameraX, cameraY) + floor(viewRadius / 2)
	g_minRadius = bDestroyerIsActivePlayer and 0 or maxRadius - viewRadius

	--ContextPtr:SetHide(false)					--lockout the active player so they can't move the camera XXXXX - DON'T DO IT IN EAMAIN CONTEXT!
	UI.LookAt(cameraCenterPlot, 2)				--look at capital, zoom out

	for radius = maxRadius, 1, -1 do
		local bExit = false
		for plot in PlotRingIterator(g_destroyerCapitalPlot, radius, 1, false) do
			local x, y = plot:GetXY()
			if PlotDistance(cameraX, cameraY, x, y) < viewRadius then
				if plot:IsVisible(g_iActiveTeam) then
					g_radius = radius
					bExit = true
					break
				end
			end
		end
		if bExit then break end
	end
	DelayedEOTW()
end

local EOTW_RING_DELAY = 500
local g_tickStop = 0
local g_bEOTWInitClock = true

function DelayedEOTW()
	if g_radius == 0 then
		local x, y = g_destroyerCapitalPlot:GetXY()
		DoDummyUnitRangedAttack(BARB_PLAYER_INDEX, x, y, nil, GameInfoTypes.UNIT_DUMMY_NUKE)
		--ContextPtr:SetHide(false)	--we're done
	else
		for plot in PlotRingIterator(g_destroyerCapitalPlot, g_radius, 1, false) do
			if plot:IsCity() then
				local x, y = plot:GetXY()
				DoDummyUnitRangedAttack(BARB_PLAYER_INDEX, x, y, nil, GameInfoTypes.UNIT_DUMMY_NUKE)
			else
				BreachPlot(plot)
			end
		end
		g_radius = g_radius - 1
		if g_radius == 0 then
			EOTW_RING_DELAY = EOTW_RING_DELAY * 5
		end
		if g_radius >= g_minRadius then
			g_bEOTWInitClock = true
			Events.LocalMachineAppUpdate.Add(EOTWRingDelay)	
		else
			--ContextPtr:SetHide(false)		--we're done
		end
	end
end

function EOTWRingDelay(tickCount, timeIncrement)		--DON'T LOCALIZE! Causes CTD with RemoveAll
	if g_bEOTWInitClock then
		g_tickStop = tickCount + EOTW_RING_DELAY
		g_bEOTWInitClock = false
		print("Start EOTWRingDelay ", tickCount, g_tickStop)
	elseif g_tickStop < tickCount then
		print("Stop EOTWRingDelay ", tickCount, g_tickStop)
		Events.LocalMachineAppUpdate.RemoveAll()	--also removes tutorial checks (good riddence!)
		DelayedEOTW()
	end
end

