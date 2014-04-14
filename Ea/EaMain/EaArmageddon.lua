-- EaArmageddon
-- Author: Pazyryk
-- DateCreated: 4/13/2014 10:30:54 AM
--------------------------------------------------------------
print("Loading EaMagic.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end


-- 90%	Warning (popup will explain the basic idea of mana depletion)
-- 80%	Undead begin to spawn from old battlefields and city graveyards, and demons from any blighted plots (1% chance per plot per turn increasing to 10% as Mana depletes to zero).
-- 66%	Begins to sap happiness and health from all civilizations (-5 for both increasing to -20 as Mana depletes to zero).
-- 50%	Blight now spreads from already blighted plots (1% chance per blight per turn increasing to 10% as Mana depletes to zero)
-- 33%	All mana accumulative processes are reduced by 33% (increasing to 90% as Mana depletes to zero). Does not affect Divine Favor.
-- 25%	Blight begins to appear spontaneously (0.5% chance per unaffected plot per turn increasing to 2% as Mana depletes to zero).
-- 20%	Pestilence, the first of the Four Horsemen, arrives riding a White Horse. He carries the Bow of Pestilence (causing disease in all units hit) and the Crown of Pestilence (causing disease or plague in all nearby cities). 
-- 15%	War arrives riding a Red Horse. He carries a sword called War that causes nearby civilizations and city states to declare war on each other and the cities and units of larger civilizations to revolt and war upon their owners.
-- 10%	Famine arrives riding a Black Horse. He carries the Scales of Want which bring starvation to all nearby units and cities.
-- 5%	Death arrives riding a Pale Horse. He carries no items but kills by sword, famine, plague and the enraged beasts and animals of Éa.
-- 1%	The fabric of Éa unravels and the world ends in fiery armageddon. The primary contributor to this (i.e., the civilization that consumed the most mana) wins the Destroyer Victory.



--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------
--constants






--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function EaArmageddonPerTurn()
	local manaPercent = 100 * gWorld.sumOfAllMana / MapModData.STARTING_SUM_OF_ALL_MANA
	local armageddonStage = gWorld.armageddonStage

	if 90 < manaPercent then return end
	if armageddonStage < 1 then
		gWorld.armageddonStage = 1
		print("Armageddon stage 1")
		--popup
	end
	if 80 < manaPercent then return end
	if armageddonStage < 2 then
		gWorld.armageddonStage = 2
		print("Armageddon stage 2")
	end
	if 66 < manaPercent then return end
	if armageddonStage < 3 then
		gWorld.armageddonStage = 3
		print("Armageddon stage 3")
	end
	if 50 < manaPercent then return end
	if armageddonStage < 4 then
		gWorld.armageddonStage = 4
		print("Armageddon stage 4")
	end
	if 33 < manaPercent then return end
	if armageddonStage < 5 then
		gWorld.armageddonStage = 5
		print("Armageddon stage 5")
	end
	if 25 < manaPercent then return end
	if armageddonStage < 6 then
		gWorld.armageddonStage = 6
		print("Armageddon stage 6")
	end
	if 20 < manaPercent then return end
	if armageddonStage < 7 then
		gWorld.armageddonStage = 7
		print("Armageddon stage 7")
	end
	if 15 < manaPercent then return end
	if armageddonStage < 8 then
		gWorld.armageddonStage = 8
		print("Armageddon stage 8")
	end
	if 10 < manaPercent then return end
	if armageddonStage < 9 then
		gWorld.armageddonStage = 9
		print("Armageddon stage 9")
	end
	if 5 < manaPercent then return end
	if armageddonStage < 10 then
		gWorld.armageddonStage = 10
		print("Armageddon stage 10")
	end
	if 1 < manaPercent then return end
	if armageddonStage < 11 then
		gWorld.armageddonStage = 11
		print("Armageddon stage 11")
	end

end


--EOTW (Emo Open To Wristcutting)

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
	local maxRadius = bDestroyerIsActivePlayer and viewRadius or PlotDistance(destroyerCapital:GetX(), destroyerCapital:GetY(), cameraX, cameraY) + Floor(viewRadius / 2)
	g_minRadius = bDestroyerIsActivePlayer and 0 or maxRadius - viewRadius

	ContextPtr:SetHide(false)					--lockout the active player so they can't move the camera
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
		ContextPtr:SetHide(false)	--we're done
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
			ContextPtr:SetHide(false)		--we're done
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

