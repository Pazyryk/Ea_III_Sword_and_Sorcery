-- EaAIActions
-- Author: Pazyryk
-- DateCreated: 4/28/2012 1:24:29 PM
--------------------------------------------------------------
print("Loading EaAIActions.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end
--------------------------------------------------------------
-- Notes
--------------------------------------------------------------
--To have any idea what's going on here, you need to understand these two posts:
--http://forums.civfanatics.com/showpost.php?p=11452419&postcount=89
--http://forums.civfanatics.com/showpost.php?p=11454905&postcount=99

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------
--settings
local TRAVEL_TURNS_WITHIN_AREA = 4

--constants
local EA_ACTION_GO_TO_PLOT =				GameInfoTypes.EA_ACTION_GO_TO_PLOT		-- always = 0
local EA_ACTION_TAKE_LEADERSHIP =			GameInfoTypes.EA_ACTION_TAKE_LEADERSHIP
--local EA_ACTION_TAKE_RESIDENCE =			GameInfoTypes.EA_ACTION_TAKE_RESIDENCE
local EA_ACTION_LAND_TRADE_ROUTE =			GameInfoTypes.EA_ACTION_LAND_TRADE_ROUTE
local EA_ACTION_SEA_TRADE_ROUTE =			GameInfoTypes.EA_ACTION_SEA_TRADE_ROUTE
local BUILDING_LIBRARY =					GameInfoTypes.BUILDING_LIBRARY
local RELIGION_AZZANDARAYASNA =				GameInfoTypes.RELIGION_AZZANDARAYASNA
local RELIGION_ANRA =						GameInfoTypes.RELIGION_ANRA
local POLICY_PANTHEISM =					GameInfoTypes.POLICY_PANTHEISM

local DOMAIN_LAND =							DomainTypes.DOMAIN_LAND
local DOMAIN_SEA =							DomainTypes.DOMAIN_SEA
local PLOT_HILLS =							PlotTypes.PLOT_HILLS
local PLOT_MOUNTAIN =						PlotTypes.PLOT_MOUNTAIN
local PLOT_LAND =							PlotTypes.PLOT_LAND
local TERRAIN_GRASS =						GameInfoTypes.TERRAIN_GRASS
local TERRAIN_PLAINS =						GameInfoTypes.TERRAIN_PLAINS
local FEATURE_FOREST = 						GameInfoTypes.FEATURE_FOREST
local FEATURE_JUNGLE = 						GameInfoTypes.FEATURE_JUNGLE
local FEATURE_MARSH =	 					GameInfoTypes.FEATURE_MARSH

local EA_WONDER_ARCANE_TOWER =	 			GameInfoTypes.EA_WONDER_ARCANE_TOWER

local FIRST_GP_ACTION =						FIRST_GP_ACTION
local FIRST_COMBAT_ACTION_ID =				FIRST_COMBAT_ACTION_ID
local FIRST_SPELL_ID =						FIRST_SPELL_ID
local LAST_SPELL_ID =						LAST_SPELL_ID

--global tables
local fullCivs =							MapModData.fullCivs
local realCivs =							MapModData.realCivs
local gpRegisteredActions =					MapModData.gpRegisteredActions
local gWorld =								gWorld
local gPlayers =							gPlayers
local gPeople =								gPeople
local Players =								Players
local Teams =								Teams
local gg_aiOptionValues =					gg_aiOptionValues	--communicates with EaAction.lua
local gg_unitClusters =						gg_unitClusters	--values set in EaUnitsAI.lua; used here for GP threat assesment if GP has combat role
local gg_playerPlotActionTargeted =			gg_playerPlotActionTargeted
local gg_cachedMapPlots =					gg_cachedMapPlots


--localized functions
local TestEaAction =						TestEaAction
local TestEaActionTarget =					TestEaActionTarget
local DoEaAction =							DoEaAction
local TestEaSpell =							TestEaSpell
local TestEaSpellTarget =					TestEaSpellTarget
local DoEaSpell =							DoEaSpell
local PlotDistance =						Map.PlotDistance
local GetPlotFromXY =						Map.GetPlot
local Format =								string.format
local GetXYFromPlotIndex =					GetXYFromPlotIndex
local Rand =								Map.Rand

--file control
local g_options = {}
for i = 1, 250 do		--pre-inited tables for speed; we should never exceed about 100 options
	g_options[i] = {iPlot = 0, eaActionID = 0, numerator = 0, denominator = 0, vP = 0, vPP = 0, travelTurns = 0, actionTurns = 0, i = 0, p = 0, b = 0}
end
local g_optionsPos = 0
local g_areaOptions = {}
for _, area in Map.Areas() do 
	g_areaOptions[area:GetID()] = {pos = 0}	--holds indeces to options
end
local g_nonCombatCallCount = 0

local g_gameTurn
local g_iPlayer
local g_player
local g_eaPlayer
local g_iPerson
local g_eaPerson
local g_unit
local g_gpPlot
local g_gpPlotIndex
local g_gpX
local g_gpY
local g_eaActionID

local g_wonderPlotsCacheTurn = {}
local g_wonderWorkPlots = {}
local g_wonderNoWorkPlots = {}

---------------------------------------------------------------
-- Cached table values
---------------------------------------------------------------

local actionCombatRole = {}
for eaActionInfo in GameInfo.EaActions() do
	if eaActionInfo.AICombatRole then
		actionCombatRole[eaActionInfo.ID] = eaActionInfo.AICombatRole
	end
end

---------------------------------------------------------------
-- Interface AI GP functions not part of core control
---------------------------------------------------------------

function AIRecalculateNumTradeRoutesTargeted(iPlayer)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	if player:IsHuman() then
		eaPlayer.aiNumTradeRoutesTargeted = nil
	else
		eaPlayer.aiNumTradeRoutesTargeted = 0
		for iPerson, eaPerson in pairs(gPeople) do
			if eaPerson.iPlayer == iPlayer then
				if eaPerson.eaActionID == EA_ACTION_LAND_TRADE_ROUTE or eaPerson.gotoEaActionID == EA_ACTION_LAND_TRADE_ROUTE or eaPerson.eaActionID == EA_ACTION_SEA_TRADE_ROUTE or eaPerson.gotoEaActionID == EA_ACTION_SEA_TRADE_ROUTE then
					eaPlayer.aiNumTradeRoutesTargeted = eaPlayer.aiNumTradeRoutesTargeted + 1
				end
			end
		end
	end
end

---------------------------------------------------------------
-- Init
---------------------------------------------------------------

function EaAIActionsInit(bNewGame)

end

---------------------------------------------------------------
-- Core AI GP actions control
---------------------------------------------------------------

function MakeAIActionsPlotsDirty(iPlayer)
	if g_wonderPlotsCacheTurn[iPlayer] then
		g_wonderPlotsCacheTurn[iPlayer] = -1
	end
end

local function CitySpiralSearchForWonderPlot(iPlayer, city, bAvoidFarmable, bAvoidHill, bAvoidLivingTerrain, bAvoidImprovement, bAvoidResource)
	print("CitySpiralSearchForWonderPlot ", iPlayer, city, bAvoidFarmable, bAvoidHill, bAvoidLivingTerrain, bAvoidImprovement, bAvoidResource)
	local sector = Rand(6, "hello") + 1
	for plot in PlotAreaSpiralIterator(city:Plot(), 3, sector, false, false, false) do
		local iPlot = plot:GetPlotIndex()
		if not gg_playerPlotActionTargeted[iPlayer][iPlot] then		--not targeted by any other GPs (for anything)
			if not plot:IsWater() and not plot:IsImpassable() and not plot:IsCity() then
				--print("a")
				local iOwner = plot:GetOwner()
				if iOwner == -1 or iOwner == g_iPlayer then
					--print("b")
					local plotTypeID = plot:GetPlotType()
					if plotTypeID ~= PLOT_MOUNTAIN then
						--print("c")
						if not bAvoidHill or plotTypeID ~= PLOT_HILLS then
							--print("d")
							local terrainID = plot:GetTerrainType()
							if not bAvoidFarmable or not ((terrainID == TERRAIN_GRASS and (plotTypeID == PLOT_LAND or plot:IsFreshWater())) or (terrainID == TERRAIN_PLAINS and plot:IsFreshWater())) then
								--print("e")
								local featureID = plot:GetFeatureType()
								if not bAvoidLivingTerrain or (featureID ~= FEATURE_FOREST and featureID ~= FEATURE_JUNGLE and featureID ~= FEATURE_MARSH) then
									--print("f")
									if not bAvoidResource or plot:GetResourceType(-1) == -1 then
										--print("g")
										local improvementID = plot:GetImprovementType()
										if improvementID == -1 or (not bAvoidImprovement and not GameInfo.Improvements[improvementID].Permanent) then
											print(" * Returning ", plot:GetPlotIndex())
											return iPlot
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

local function CalculateAIActionsPlots(iPlayer)	--cache turn so we don't do this more than needed
	print("CalculateAIActionsPlots ", iPlayer, g_gameTurn)
	if not g_wonderPlotsCacheTurn[iPlayer] then		--init
		g_wonderWorkPlots[iPlayer] = {}
		g_wonderNoWorkPlots[iPlayer] = {}
	end
	g_wonderPlotsCacheTurn[iPlayer] = g_gameTurn
	local wonderWorkPlots = g_wonderWorkPlots[iPlayer]
	local wonderNoWorkPlots = g_wonderNoWorkPlots[iPlayer]

	wonderWorkPlots.pos = 0
	wonderNoWorkPlots.pos = 0

	--try to get one plot per city; check surplus food for work plots
	local player = Players[iPlayer]
	local bPantheistic = player:HasPolicy(POLICY_PANTHEISM)
	local bAvoidFarmable = not bPantheistic
	local bAvoidHill = not bPantheistic
	local bAvoidLivingTerrain =  not bPantheistic
	local bAvoidImprovement = true
	local bAvoidResource = true
	local bHaveWorkPlots = false
	local bHaveNoWorkPlots = false

	while true do
		for city in player:Cities() do
			--spiral out until satisfactory plot found
			--TO DO: Make g_wonderWorkPlots really strongly prefer cities with unemployed (meaning there is a food surplus relative to workable plots)	--city:GetSpecialistCount(SPECIALIST_CITIZEN)
			--TO DO: make more interersting with remote wonders?
			local iPlot = CitySpiralSearchForWonderPlot(iPlayer, city, bAvoidFarmable, bAvoidHill, bAvoidLivingTerrain, bAvoidImprovement, bAvoidResource)
			if iPlot then
				if not bHaveWorkPlots then
					wonderWorkPlots.pos = wonderWorkPlots.pos + 1
					wonderWorkPlots[wonderWorkPlots.pos] = iPlot
				end
				if not bHaveNoWorkPlots then
					wonderNoWorkPlots.pos = wonderNoWorkPlots.pos + 1
					wonderNoWorkPlots[wonderNoWorkPlots.pos] = iPlot
				end
			end
		end

		--print("wonderWorkPlots.pos, wonderNoWorkPlots.pos, bPantheistic,bAvoidFarmable,bAvoidHill,bAvoidLivingTerrain,bAvoidImprovement,bAvoidResource = ", wonderWorkPlots.pos, wonderNoWorkPlots.pos, bPantheistic,bAvoidFarmable,bAvoidHill,bAvoidLivingTerrain,bAvoidImprovement,bAvoidResource)

		bHaveWorkPlots = 0 < wonderWorkPlots.pos
		bHaveNoWorkPlots = 0 < wonderNoWorkPlots.pos

		if bHaveWorkPlots and bHaveNoWorkPlots then
			break
		else		--relax contsraints and try again
			if bAvoidHill then
				bAvoidHill = false
			elseif bAvoidFarmable then
				bAvoidFarmable = false
			elseif bAvoidImprovement then
				bAvoidImprovement = false
			else
				print("!!!! WARNING: Could not find wonderWorkPlots and/or wonderNoWorkPlots for AI")
				break
			end
		end
	end
end


--------------------------------------------------------------
-- AI options local control
--------------------------------------------------------------
local function TestAddOption(targetType, index1, index2, tieBreaker, g)
	--g (=travelTurns) is optional and will be calculated below if arg is nil
	--targetType = "Plot", index1 = x, index2 = y
	--targetType = "Unit", index1 = iPlayer, index2 = iUnit
	--targetType = "Person", index1 = iPerson

	--For time discout math see: 
	--http://forums.civfanatics.com/showpost.php?p=11452419&postcount=89
	local bTestTarget
	if g_eaActionID < FIRST_SPELL_ID then
		bTestTarget = TestEaActionTarget(g_eaActionID, index1, index2, true)
	else
		bTestTarget = TestEaSpellTarget(g_eaActionID, index1, index2, true)
	end

	if bTestTarget then		--gg_aiOptionValues will be set from either EaActions.lua or EaSpells.lua

		local t = gg_aiOptionValues.t					--turns to complete (integer > 0; t=1 for "instant" effect because all actions with value use up GP movement)
		local i = gg_aiOptionValues.i					--adjusted instant gain/loss when completed
		local p = gg_aiOptionValues.p					--adjusted per turn gain/loss after action
		local b = gg_aiOptionValues.b					--adjusted per turn gain/loss during "build" time
		local r = gg_aiOptionValues.r					--time discount rate table (high for combat actions)

		local numerator = b + r[t - 1] * (i + p - r[1] * (i + b))

		if 0 < numerator then
			local targetX, targetY
			if targetType == "Plot" then
				targetX, targetY = index1, index2
			end
			--g = g or EaPersonAStarTurns(g_iPlayer, g_iPerson, g_gpX, g_gpY, targetX, targetY)	--gets travel turns if we don't already have it (1000 if unreachable)
			g = g_unit:TurnsToReachTarget(GetPlotFromXY(targetX, targetY), 1, 0, 0)

			if g < 50 then

		
				local nextOptionIndex = g_optionsPos + 1
				local option = g_options[nextOptionIndex]
				local denominator = 1 - r[t]
				option.vP = (numerator + tieBreaker) / (denominator + 1/r[g] - 1)
				option.vPP = numerator / denominator						
				option.numerator = numerator
				option.denominator = denominator
				option.travelTurns = g
				option.actionTurns = t
				option.r = r
				--option.targetType = targetType
				option.iPlot = GetPlotIndexFromXY(targetX, targetY)
				option.eaActionID = g_eaActionID

				--next three added for debug print only
				option.i = i
				option.p = p
				option.b = b

				g_optionsPos = nextOptionIndex

				local plot = GetPlotFromXY(targetX, targetY)
				local iArea = plot:GetArea()
				local thisAreaOptions = g_areaOptions[iArea]
				thisAreaOptions.pos = thisAreaOptions.pos + 1
				thisAreaOptions[thisAreaOptions.pos] = nextOptionIndex
				
				print("Adding option; vP, vPP = ", option.vP, option.vPP)
			end

		else
			print("Skipping option; numerator = ", numerator)
		end
	end
end

local function Blacklist(eaActionID, iPlot)
	--For some reason GP AI thinks we can do it, but move or other action failed.
	--This function puts off limits for this particular GP. The option is added but then rejected (above) with a print statement.
	local eaAction = GameInfo.EaActions[eaActionID]
	print("Blacklisting action for this GP at this target", g_iPerson, eaActionID, iPlot)
	g_eaPerson.aiBlacklist = g_eaPerson.aiBlacklist or {}
	g_eaPerson.aiBlacklist[eaActionID] = g_eaPerson.aiBlacklist[eaActionID] or {}
	g_eaPerson.aiBlacklist[eaActionID][iPlot] = Game.GetGameTurn()	--we could reassess later, maybe
end

local function AddCombatOptions(rallyX, rallyY)
	--if supplied, rallyX and rallyY used for tiebreaker
	print("Running AddCombatOptions ", rallyX, rallyY)
	local PlotToRadiusIterator = PlotToRadiusIterator
	local PlotDistance = Map.PlotDistance
	local GetPlotIndexFromXY = GetPlotIndexFromXY
	local GetPlotFromXY = Map.GetPlot
	local TestAddOption = TestAddOption

	--cycle through all registered actions and then spells (if any)
	local testActions = gpRegisteredActions[g_iPerson]
	local lastAction = #testActions
	local i = 1
	g_eaActionID = testActions[1]
	while g_eaActionID do
		if actionCombatRole[g_eaActionID] then
			local bTest
			if g_eaActionID < FIRST_SPELL_ID then
				bTest = TestEaAction(g_eaActionID, g_iPlayer, g_unit, g_iPerson, nil, nil, true)
			else
				bTest = TestEaSpell(g_eaActionID, g_iPlayer, g_unit, g_iPerson, nil, nil, true)
			end
			if bTest then
				print("AI: Non-target tests passed for ", GameInfo.EaActions[g_eaActionID].Type)
				for x, y in PlotToRadiusIterator(g_gpX, g_gpY, 5) do
					local tieBreaker = rallyX and 5 / PlotDistance(x, y, rallyX, rallyY) or 0
					local iPlot = GetPlotIndexFromXY(x, y)
					local plot = GetPlotFromXY(x, y)
					TestAddOption("Plot", x, y, tieBreaker, nil)
				end
			end
		end
		i = i + 1
		if lastAction < i then
			if not g_eaPerson.spells or g_eaPerson.spells == testActions then		--done
				break
			else
				testActions = g_eaPerson.spells										--swap to spells and start from begining
				lastAction = #testActions
				i = 1
			end
		end
		g_eaActionID = testActions[i]
	end
	print("Finished with AddCombatOptions")
end

-------------------------------------------------------------------------------

local AITarget = {}

AITarget.Self = function()
	TestAddOption("Plot", g_gpX, g_gpY, 0, 0)		--targetType, index1, index2, tieBreaker, g
end

AITarget.OwnCapital = function()
	local capital = g_player:GetCapitalCity()
	TestAddOption("Plot", capital:GetX(), capital:GetY(), 0, nil)
end

AITarget.OwnCities = function()
	for city in g_player:Cities() do
		TestAddOption("Plot", city:GetX(), city:GetY(), 0, nil)
	end
end

AITarget.ForeignCities = function()
	for iLoopPlayer in pairs(realCivs) do
		if iLoopPlayer ~= g_iPlayer then
			local loopPlayer = Players[iLoopPlayer]
			for city in loopPlayer:Cities() do
				TestAddOption("Plot", city:GetX(), city:GetY(), 0, nil)
			end
		end
	end
end

AITarget.ForeignCapitals = function()
	for iLoopPlayer in pairs(realCivs) do
		if iLoopPlayer ~= g_iPlayer then
			local loopPlayer = Players[iLoopPlayer]
			local loopCapital = loopPlayer:GetCapitalCity()
			if loopCapital then
				TestAddOption("Plot", loopCapital:GetX(), loopCapital:GetY(), 0, nil)
			end		
		end	
	end
end

AITarget.AllCities = function()
	for iLoopPlayer in pairs(realCivs) do
		local loopPlayer = Players[iLoopPlayer]
		for city in loopPlayer:Cities() do
			TestAddOption("Plot", city:GetX(), city:GetY(), 0, nil)
		end
	end
end


AITarget.Purge = function()
	--really all cities but save time by checking main conditions here
	if gWorld.bAnraHolyCityExists == false and not g_eaPlayer.bIsFallen and not g_eaPlayer.bRenouncedMaleficium then
		for iLoopPlayer in pairs(realCivs) do
			local loopPlayer = Players[iLoopPlayer]
			for city in loopPlayer:Cities() do
				TestAddOption("Plot", city:GetX(), city:GetY(), 0, nil)
			end
		end
	end
end

AITarget.NearbyNonFeature = function()
	for x, y in PlotToRadiusIterator(g_gpX, g_gpY, 5) do
		local plot = GetPlotFromXY(x, y)
		if plot:GetFeatureType() == -1 then
			TestAddOption("Plot", plot:GetX(), plot:GetY(), 0, nil)
		end
	end
end

AITarget.NearbyLivTerrain = function()
	for x, y in PlotToRadiusIterator(g_gpX, g_gpY, 5) do
		local plot = GetPlotFromXY(x, y)
		local featureID = plot:GetFeatureType()
		if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE or featureID == FEATURE_MARSH then
			TestAddOption("Plot", plot:GetX(), plot:GetY(), 0, nil)
		end
	end
end

AITarget.TowerTemple = function()
	local tower = gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson]
	if tower then
		local x, y = GetXYFromPlotIndex(tower.iPlot)
		TestAddOption("Plot", x, y, 0, nil)
	elseif g_eaPerson.templeID then
		local temple = gWonders[g_eaPerson.templeID]
		local x, y = GetXYFromPlotIndex(temple.iPlot)
		TestAddOption("Plot", x, y, 0, nil)
	end
end

AITarget.Temple = function()
	if g_eaPerson.templeID then
		local temple = gWonders[g_eaPerson.templeID]
		local x, y = GetXYFromPlotIndex(temple.iPlot)
		TestAddOption("Plot", x, y, 0, nil)
	end
end

AITarget.SelfTowerTemple = function()
	TestAddOption("Plot", g_gpX, g_gpY, 0, 0)
	local tower = gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson]
	if tower then
		local x, y = GetXYFromPlotIndex(tower.iPlot)
		if x ~= g_gpX or y ~= g_gpY then
			TestAddOption("Plot", x, y, 0, nil)
		end
	elseif g_eaPerson.templeID then
		local temple = gWonders[g_eaPerson.templeID]
		local x, y = GetXYFromPlotIndex(temple.iPlot)
		if x ~= g_gpX or y ~= g_gpY then
			TestAddOption("Plot", x, y, 0, nil)
		end
	end
end

AITarget.VacantTower = function()
	for iPerson, tower in pairs(gWonders[EA_WONDER_ARCANE_TOWER]) do
		if not gPeople[iPerson] then	--tower's last occupant is dead
			local x, y = GetXYFromPlotIndex(tower.iPlot)
			TestAddOption("Plot", x, y, 0, nil)
		end
	end
end

local wideSearchRings = {2,4,6,9,12}

AITarget.SpacedRingsWide = function()
	TestAddOption("Plot", g_gpX, g_gpY, 0, 0)
	for _, radius in pairs(wideSearchRings) do
		for plot in PlotRingIterator(g_gpPlot, radius, 1, false) do
			if not plot:IsWater() then
				local x, y = plot:GetXY()
				TestAddOption("Plot", x, y, 0, nil)
			end
		end
	end
end


local getClosestCityCache = {callCount = 0}

AITarget.OwnClosestCity = function()
	--values are cached because we may have many actions asking for the nearest city
	local function GetClosestCity()
		if g_nonCombatCallCount == getClosestCityCache.callCount then
			print("GetClosestCity cached values", getClosestCityCache.travelTurns, getClosestCityCache.city)
			return getClosestCityCache.travelTurns, getClosestCityCache.city
		end
		local closestCity
		local closestTravelTurns = 50
		for city in g_player:Cities() do
			--local travelTurns = EaPersonAStarTurns(g_iPlayer, g_iPerson, g_gpX, g_gpY, city:GetX(), city:GetY())
			local travelTurns = g_unit:TurnsToReachTarget(city:Plot(), 1, 0, 0)
			if travelTurns < closestTravelTurns then
				closestCity = city
				closestTravelTurns = travelTurns
			end
		end	
		getClosestCityCache.callCount = g_nonCombatCallCount
		getClosestCityCache.city = closestCity
		getClosestCityCache.travelTurns = closestTravelTurns
		print("GetClosestCity new values", closestCity, closestTravelTurns)
		return closestTravelTurns, closestCity
	end
	local travelTurns, city = GetClosestCity()
	if city then
		TestAddOption("Plot", city:GetX(), city:GetY(), 0, travelTurns)
	end
end

local getClosestLibraryCityCache = {callCount = 0}

AITarget.OwnClosestLibraryCity = function()
	--values are cached because we may have many actions asking for the nearest library city
	local function GetClosestLibraryCity()
		if g_nonCombatCallCount == getClosestLibraryCityCache.callCount then
			print("GetClosestLibraryCity cached values", getClosestLibraryCityCache.travelTurns, getClosestLibraryCityCache.city)
			return getClosestLibraryCityCache.travelTurns, getClosestLibraryCityCache.city
		end
		local closestCity
		local closestTravelTurns = 50
		for city in g_player:Cities() do
			if city:GetNumBuilding(BUILDING_LIBRARY) == 1 then
				--local travelTurns = EaPersonAStarTurns(g_iPlayer, g_iPerson, g_gpX, g_gpY, city:GetX(), city:GetY())
				local travelTurns = g_unit:TurnsToReachTarget(city:Plot(), 1, 0, 0)
				if travelTurns < closestTravelTurns then
					closestCity = city
					closestTravelTurns = travelTurns
				end
			end
		end	
		getClosestLibraryCityCache.callCount = g_nonCombatCallCount
		getClosestLibraryCityCache.city = closestCity
		getClosestLibraryCityCache.travelTurns = closestTravelTurns
		print("GetClosestLibraryCity new values", closestTravelTurns, closestCity)
		return closestTravelTurns, closestCity
	end
	local travelTurns, city = GetClosestLibraryCity()
	if city then
		TestAddOption("Plot", city:GetX(), city:GetY(), 0, travelTurns)
	end
end

AITarget.AzzandaraSpread = function()
	if gReligions[RELIGION_AZZANDARAYASNA] then
		local bFounder = g_iPlayer == gReligions[RELIGION_AZZANDARAYASNA].founder
		for iLoopPlayer in pairs(realCivs) do
			if bFounder or iLoopPlayer == g_iPlayer then
				local loopPlayer = Players[iLoopPlayer]
				for city in loopPlayer:Cities() do
					TestAddOption("Plot", city:GetX(), city:GetY(), 0, nil)
				end
			end
		end
	end
end

AITarget.AnraSpread = function()
	if gReligions[RELIGION_ANRA] then
		if g_iPlayer == gReligions[RELIGION_ANRA].founder then	--spread only if I'm the founder (change?)
			for iLoopPlayer in pairs(realCivs) do
				local loopPlayer = Players[iLoopPlayer]
				for city in loopPlayer:Cities() do
					TestAddOption("Plot", city:GetX(), city:GetY(), 0, nil)
				end
			end
		end
	end
end

AITarget.SeeingEyeGlyph = function()
	-- test ring 3-4 unowned and currently unseen plots (SetAIValue will test for good visibility plot)
	local iTeam = g_player:GetTeam()
	for radius = 3, 4 do
		for plot in PlotRingIterator(g_gpPlot, radius, 1, false) do
			if plot:GetOwner() ~= g_iPlayer and not plot:IsVisible(iTeam) and not plot:IsAdjacentVisible(iTeam) then
				local x, y = plot:GetXY()
				TestAddOption("Plot", x, y, 0, nil)
			end
		end
	end
end

AITarget.NearbyStrongWoods = function()
	-- test to radius 6 including center
	for plot in PlotAreaSpiralIterator(g_gpPlot, 6, 1, false, false, true) do
		local featureID = plot:GetFeatureType()
		if (featureID == FEATURE_FOREST or featureID == FEATURE_FOREST) and 17 < plot:GetLivingTerrainStrength() then		
			local x, y = plot:GetXY()
			TestAddOption("Plot", x, y, 0, nil)
		end
	end
end

AITarget.OwnTroops = function()
	for loopUnit in g_player:Units() do
		local unitTypeID = loopUnit:GetUnitType()
		if gg_regularCombatType[unitTypeID] == "troops" then
			local x, y = loopUnit:GetPlot():GetXY()
			TestAddOption("Plot", x, y, 0, nil)
		end
	end
end

AITarget.OwnConstructs = function()
	for loopUnit in g_player:Units() do
		local unitTypeID = loopUnit:GetUnitType()
		if gg_regularCombatType[unitTypeID] == "construct" then
			local x, y = loopUnit:GetPlot():GetXY()
			TestAddOption("Plot", x, y, 0, nil)
		end
	end
end

AITarget.OwnShips = function()
	for loopUnit in g_player:Units() do
		local unitTypeID = loopUnit:GetUnitType()
		if gg_regularCombatType[unitTypeID] == "ship" then
			local x, y = loopUnit:GetPlot():GetXY()
			TestAddOption("Plot", x, y, 0, nil)
		end
	end
end



local testedCityList = {}
--setmetatable(testedCityList, WeakKeyMetatable)

AITarget.LandTradeCities = function()
	--gg_tradeAvailableTable will be updated by Test function before we get here

	if 0 < #gg_tradeAvailableTable then
		for key in pairs(testedCityList) do
			testedCityList[key] = nil
		end
		for i = 1, #gg_tradeAvailableTable do
			local route = gg_tradeAvailableTable[i]
			local toCity = route.ToCity
			if route.Domain == DOMAIN_LAND and not testedCityList[toCity] then
				testedCityList[toCity] = true
				TestAddOption("Plot", toCity:GetX(), toCity:GetY(), 0, nil)				--redundant test (maybe we need AddOption that bypasses Test?)
			end
		end
	end
end

AITarget.SeaTradeCities = function()

	if 0 < #gg_tradeAvailableTable then
		for key in pairs(testedCityList) do
			testedCityList[key] = nil
		end
		for i = 1, #gg_tradeAvailableTable do
			local route = gg_tradeAvailableTable[i]
			local toCity = route.ToCity
			if route.Domain == DOMAIN_SEA and not testedCityList[toCity] then
				testedCityList[toCity] = true
				TestAddOption("Plot", toCity:GetX(), toCity:GetY(), 0, nil)				--redundant test (maybe we need AddOption that bypasses Test?)
			end
		end
	end
end

AITarget.WonderNoWorkPlot = function()			--Ideally, 1 plot per city that is good to develop assuming it won't be worked
	if g_wonderPlotsCacheTurn[g_iPlayer] ~= g_gameTurn then
		CalculateAIActionsPlots(g_iPlayer)
	end
	local wonderPlots = g_wonderNoWorkPlots[g_iPlayer]
	for i = 1, wonderPlots.pos do
		local x, y = GetXYFromPlotIndex(wonderPlots[i])
		TestAddOption("Plot", x, y, 0, nil)
	end
end

AITarget.WonderWorkPlot = function()			--Ideally, 1 plot per city that is good to develop assuming it will be worked and not supply food (so city must support it)
	if g_wonderPlotsCacheTurn[g_iPlayer] ~= g_gameTurn then
		CalculateAIActionsPlots(g_iPlayer)
	end
	local wonderPlots = g_wonderWorkPlots[g_iPlayer]
	for i = 1, wonderPlots.pos do
		local x, y = GetXYFromPlotIndex(wonderPlots[i])
		TestAddOption("Plot", x, y, 0, nil)
	end
end

AITarget.HomelandProtection = function()		--heuristic for testing Explosive Rune and Death Rune
	for city in g_player:Cities() do
		if city:IsCapital() then
			for x, y in PlotToRadiusIterator(city:GetX(), city:GetY(), 3, nil, nil, false) do
				TestAddOption("Plot", x, y, 0, nil)
			end
		else
			for x, y in PlotToRadiusIterator(city:GetX(), city:GetY(), 1, nil, nil, false) do
				TestAddOption("Plot", x, y, 0, nil)
			end
		end
	end
end

AITarget.RevealedGRWs = function()		--for Dispel Glyphs, Runes and Wards
	for iPlot in pairs(g_eaPlayer.revealedPlotEffects) do
		local x, y = GetXYFromPlotIndex(iPlot)
		TestAddOption("Plot", x, y, 0, nil)
	end
end

AITarget.AhrimansVault = function()
	for iPlot in pairs(gg_cachedMapPlots.accessAhrimansVault) do
		local x, y = GetXYFromPlotIndex(iPlot)
		TestAddOption("Plot", x, y, 0, nil)
	end
end
-------------------------------------------------------------------------------

local function AddNonCombatOptions()
	g_nonCombatCallCount = g_nonCombatCallCount + 1
	print("Running AddNonCombatOptions")
	local TestAddOption = TestAddOption

	--cycle through all registered actions and then spells (if any)
	local testActions = gpRegisteredActions[g_iPerson]
	local lastAction = #testActions
	local i = 1
	g_eaActionID = testActions[1]
	while g_eaActionID do
		if not actionCombatRole[g_eaActionID] then
			local bTest
			if g_eaActionID < FIRST_SPELL_ID then
				bTest = TestEaAction(g_eaActionID, g_iPlayer, g_unit, g_iPerson, nil, nil, true)	--this will set player/person file locals
			else
				bTest = TestEaSpell(g_eaActionID, g_iPlayer, g_unit, g_iPerson, nil, nil, true)
			end
			if bTest then
				local eaAction = GameInfo.EaActions[g_eaActionID]
				print("AI: Non-target tests passed for ", eaAction.Type)
				if AITarget[eaAction.AITarget] then
					AITarget[eaAction.AITarget]()
				end
				if AITarget[eaAction.AITarget2] then
					AITarget[eaAction.AITarget2]()
				end
			end
		end
		i = i + 1
		if lastAction < i then
			if not g_eaPerson.spells or g_eaPerson.spells == testActions then		--done
				break
			else
				testActions = g_eaPerson.spells										--swap to spells and start from begining
				lastAction = #testActions
				i = 1
			end
		end
		g_eaActionID = testActions[i]
	end
end

-------------------------------------------------------------------------------

local vP = {index = 0, value = 0}
local vPP2 = {index = 0, value = 0}
local vPP3 = {index = 0, value = 0}
local vPP4 = {index = 0, value = 0}
local vPP5 = {index = 0, value = 0}
local vPPX = {index = 0, value = 0}

local formatOptionStr = "OPTION    %4d %35.35s %9d %5d %3d %3d %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f"
local formatBlkLstStr = "BLACKLIST %4d %35.35s %9d %5d %3d %3d %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f"

local function CompareOptions()
	print("Running CompareOptions; iPerson, iPlot = ", g_iPerson, g_gpPlotIndex)
	print("          #                       Option          iArea   iPlot   g   t      i          p          b      numerator denominator    vPP         vP")
	--    "OPTION dddd ttttttttttttt 35 tttttttttttttttttt ddddddddd ddddd ddd ddd 00000.0000 00000.0000 00000.0000 00000.0000 00000.0000 00000.0000 00000.0000"
	--Setup blacklists (goto's or other actions that didn't work for some reason)
	local blacklist = g_eaPerson.aiBlacklist
	local blacklistGoto = blacklist and blacklist[EA_ACTION_GO_TO_PLOT]

	--Calculate area boosts and find best v
	local bestV = 0
	local bestVoption = 0

	for _, area in Map.Areas() do 
		local iArea = area:GetID()
		local thisAreaOptions = g_areaOptions[iArea]
		if thisAreaOptions.pos > 0 then

			vP.index, vP.value = 0, 0
			vPP2.index, vPP2.value = 0, 0
			vPP3.index, vPP3.value = 0, 0
			vPP4.index, vPP4.value = 0, 0
			vPP5.index, vPP5.value = 0, 0
			vPPX.index, vPPX.value = 0, 0

			for j = 1, thisAreaOptions.pos do
				local index = thisAreaOptions[j]
				local option = g_options[index]
				local eaActionType = GameInfo.EaActions[option.eaActionID].Type
				local blacklistGotoTurn = blacklistGoto and blacklistGoto[option.iPlot]
				local blacklistActionTurn = blacklist and blacklist[option.eaActionID] and blacklist[option.eaActionID][option.iPlot]
				if blacklistGotoTurn and Game.GetGameTurn() < blacklistGotoTurn + 30 then
					print(Format(formatBlkLstStr, index, eaActionType, iArea, option.iPlot, option.travelTurns, option.actionTurns, option.i, option.p, option.b, option.numerator, option.denominator, option.vPP, option.vP), "Blacklist goto turn = ", blacklistGotoTurn)
				elseif blacklistActionTurn then
					print(Format(formatBlkLstStr, index, eaActionType, iArea, option.iPlot, option.travelTurns, option.actionTurns, option.i, option.p, option.b, option.numerator, option.denominator, option.vPP, option.vP), "Blacklist action turn = ", blacklistGotoTurn)
				else
					print(Format(formatOptionStr, index, eaActionType, iArea, option.iPlot, option.travelTurns, option.actionTurns, option.i, option.p, option.b, option.numerator, option.denominator, option.vPP, option.vP))

					--find best vP
					if option.vP > vP.value then
						vP.value = option.vP
						vP.index = index
					end

					--find best 5 vPP (will use top 4 excluding best vP above)
					if option.vPP > vPPX.value then			
						vPPX.value = option.vPP
						vPPX.index = thisAreaOptions[j]
						if vPPX.value > vPP5.value then
							vPP5, vPPX = vPPX, vPP5
							if vPP5.value > vPP4.value then
								vPP4, vPP5 = vPP5, vPP4
								if vPP4.value > vPP3.value then
									vPP3, vPP4 = vPP4, vPP3
									if vPP3.value > vPP2.value then
										vPP2, vPP3 = vPP3, vPP2
									end
								end
							end
						end
					end
				end
			end

			--best vP set, now remove from vPP's
			if vPP2.index == vP.index then
				vPP2, vPP3, vPP4, vPP5 = vPP3, vPP4, vPP5, vPPX
			elseif vPP3.index == vP.index then
				vPP3, vPP4, vPP5 = vPP4, vPP5, vPPX
			elseif vPP4.index == vP.index then
				vPP4, vPP5 = vPP5, vPPX
			elseif vPP5.index == vP.index then
				vPP5 = vPPX
			end

			--caluculate areaValue from vPP's
			local op1 = g_options[vP.index]
			local op2 = g_options[vPP2.index]	--nil if wasn't set
			local op3 = g_options[vPP3.index]
			local op4 = g_options[vPP4.index]
			local op5 = g_options[vPP5.index]

			local g2 = op1 and op1.travelTurns + op1.actionTurns + TRAVEL_TURNS_WITHIN_AREA or 0
			local g3 = op2 and g2 + op2.actionTurns + TRAVEL_TURNS_WITHIN_AREA or 0
			local g4 = op3 and g3 + op3.actionTurns + TRAVEL_TURNS_WITHIN_AREA or 0
			local g5 = op4 and g4 + op4.actionTurns + TRAVEL_TURNS_WITHIN_AREA or 0

			local areaValue = (op2 and op2.numerator / (op2.denominator + 1 / op2.r[g2] + 1) or 0)
				+ (op3 and op3.numerator / (op3.denominator + 1 / op3.r[g3] + 1) or 0)
				+ (op4 and op4.numerator / (op4.denominator + 1 / op4.r[g4] + 1) or 0)
				+ (op5 and op5.numerator / (op5.denominator + 1 / op5.r[g5] + 1) or 0)

			local v = vP.value + areaValue	--this is the final marginal value
			if v > bestV then
				bestV = v
				bestVoption = vP.index
			end
		end
	end
	print("AI sorted options", bestV, bestVoption)

	return bestVoption	--nil if none found
end

local function DoOrGotoBestOption(bestVoption)
	print("Running DoOrGotoBestOption ", bestVoption)
	--DebugFunctionExitTest("DoOrGotoBestOption", true)
	--ClearActionPlotTargetedForPerson(g_iPlayer, iPerson)

	local option = g_options[bestVoption]
	local targetPlotIndex = option.iPlot
	local bSuccess = false

	if targetPlotIndex then
		if targetPlotIndex == g_gpPlotIndex then	--GP is here so do it
			print("AI GP at target; attempting to do option:", bestVoption)
			if option.eaActionID < FIRST_SPELL_ID then
				bSuccess = DoEaAction(option.eaActionID, g_iPlayer, g_unit, g_iPerson)
			else
				bSuccess = DoEaSpell(option.eaActionID, g_iPlayer, g_unit, g_iPerson)
			end
			if not bSuccess then				
				Blacklist(option.eaActionID, targetPlotIndex)			--don't try this again
			end
		else								--GP needs to move to plot
			print("AI GP attempting to go to target for option:", bestVoption, option.travelTurns)
			local targetX, targetY = GetXYFromPlotIndex(targetPlotIndex)
			
			if DoEaAction(EA_ACTION_GO_TO_PLOT, g_iPlayer, g_unit, g_iPerson, targetX, targetY) then	--true if unit moved (will set gotoPlotIndex since we supplied targetX, Y here)
				bSuccess = true
				local gotoEaActionID = option.eaActionID
				g_eaPerson.gotoEaActionID = gotoEaActionID
				local eaAction = GameInfo.EaActions[gotoEaActionID]
				if eaAction.UniqueType then		
					g_eaPlayer.aiUniqueTargeted[gotoEaActionID] = g_iPerson		--other GPs won't consider while this GP in transit 
				end
				if not eaAction.NoGPNumLimit then
					--g_eaPlayer.actionPlotTargeted[gotoEaActionID] = g_eaPlayer.actionPlotTargeted[gotoEaActionID] or {}
					--g_eaPlayer.actionPlotTargeted[gotoEaActionID][targetPlotIndex] = g_iPerson

					gg_playerPlotActionTargeted[g_iPlayer][targetPlotIndex] = gg_playerPlotActionTargeted[g_iPlayer][targetPlotIndex] or {}
					gg_playerPlotActionTargeted[g_iPlayer][targetPlotIndex][gotoEaActionID] = g_iPerson
				end
				print("g_eaPerson.gotoPlotIndex, .gotoEaActionID = ", g_eaPerson.gotoPlotIndex, g_eaPerson.gotoEaActionID)
			else		--if we didn't move, then we need to blacklist this targetPlot for a while	
				Blacklist(EA_ACTION_GO_TO_PLOT, option.iPlot)	--GP won't try to go to this city for a while
				g_eaPerson.gotoEaActionID = -1
			end
		end
	end

	--DebugFunctionExitTest("DoOrGotoBestOption")
	return bSuccess
end

--------------------------------------------------------------
-- Entry Functions for GP action control
--------------------------------------------------------------

function AIGPDoSomething(iPlayer, iPerson, unit)		--unit cannot be nil
	--We are here because the GP is on the map with some movement and not currently doing anything: eaPerson.eaActionID == -1
	--Functions imediately above this one can interup a GP that is presently doing something (for now, only TestCombatInterrupt)
	--DebugFunctionExitTest("AIGPDoSomething", true)

	g_gameTurn = Game.GetGameTurn()

	g_eaPlayer = gPlayers[iPlayer]
	g_eaPerson = gPeople[iPerson]

	g_player = Players[iPlayer]
	g_iPlayer = iPlayer
	g_iPerson = iPerson
	g_unit = unit
	g_gpPlot = unit:GetPlot()
	g_gpX, g_gpY, g_gpPlotIndex = g_gpPlot:GetXYIndex()

	print("Running AIGPDoSomething", iPerson, g_eaPerson.name, g_gpPlotIndex, g_eaPerson.gotoPlotIndex, g_eaPerson.gotoEaActionID, g_eaPerson.eaActionID)

	if g_eaPerson.eaActionID ~= -1 then
		print("!!!! Warning: GP has eaActionID but calling AIGPDoSomething")
	end

	--ClearActionPlotTargetedForPerson(iPlayer, iPerson)

	--Are we at our destination?
	if g_gpPlotIndex == g_eaPerson.gotoPlotIndex then
		local doNowEaActionID = g_eaPerson.gotoEaActionID
		print("GP has reached gotoPlotIndex; gotoEaActionID = ", doNowEaActionID)
		if doNowEaActionID == -1 then
			InterruptEaAction(iPlayer, iPerson)	--cleans everything up so GP can look for something below
		else
			g_eaPlayer.aiUniqueTargeted[doNowEaActionID] = nil	--in case we were blocking a unique (DoEaAction will now block)
			if doNowEaActionID < FIRST_SPELL_ID then
				if DoEaAction(doNowEaActionID, iPlayer, unit, iPerson) then return end
			else
				if DoEaSpell(doNowEaActionID, iPlayer, unit, iPerson) then return end
			end
			print("!!!! Warning: GP tried to do action at destination, but failed; will look for something else to do...")
		end	
	elseif g_eaPerson.gotoEaActionID ~= -1 then	--Something went wrong and we didn't get to plot to do action; reassess from here
		print("!!!! Warning: GP waiting for instructions, but has gotoEaActionID", g_eaPerson.gotoEaActionID)
		g_eaPlayer.aiUniqueTargeted[g_eaPerson.gotoEaActionID] = nil	--in case we were blocking a unique
		g_eaPerson.eaActionID = -1
		g_eaPerson.gotoPlotIndex = -1	
		g_eaPerson.gotoEaActionID = -1
	end

	--local bIsLeader = g_eaPlayer.leaderEaPersonIndex == iPerson
	--local bIsConstrainedLeader = bIsLeader and g_bAfterTurn120 and g_eaPerson.class1 ~= "Warrior" and g_eaPerson.class2 ~= "Warrior"

	--Reset option tables
	g_optionsPos = 0
	for _, area in Map.Areas() do 
		g_areaOptions[area:GetID()].pos = 0
	end

	AddNonCombatOptions()
	if g_eaPerson.aiHasCombatRole then
		print("GP has combat role; checking for nearby hostile units or territory")
		local GetPlotFromXY = Map.GetPlot
		local team = Teams[g_player:GetTeam()]
		local bNearbyEnemy = false
		for x, y in PlotToRadiusIterator(g_gpX, g_gpY, 5) do
			local plot = GetPlotFromXY(x, y)
			if plot:IsVisibleEnemyUnit(iPlayer) or (plot:IsOwned() and team:IsAtWar(Players[plot:GetOwner()]:GetTeam())) then
				bNearbyEnemy = true
				break
			end
		end
		if bNearbyEnemy then
			print("Found nearby hostile unit or territory; adding combat options")
			AddCombatOptions(nil, nil)
		end
	end
	local bestVoption = CompareOptions(g_eaPerson)
	if bestVoption == 0 then
		print("!!!! AI found no options for GP", iPlayer, iPerson, "!!!!")
		unit:FinishMoves()	--stop infinite loop
	else
		DoOrGotoBestOption(bestVoption, iPlayer, g_eaPlayer, iPerson, g_eaPerson, unit, g_gpPlotIndex)
	end

	--DebugFunctionExitTest("AIGPDoSomething")
	return g_eaPerson.iUnit ~= -1 and g_player:GetUnitByID(g_eaPerson.iUnit)	--unit may have been converted, so recalculated here
end

function AIGPTestCombatInterrupt(iPlayer, iPerson, unit)		--called each turn (unit may be nil if GP not on map)
	--Scan unit clusters for something we might need to attend to; if nothing, go about what we were doing
	print("Running AIGPTestCombatInterrupt ", iPlayer, iPerson, unit)
	--DebugFunctionExitTest("AIGPTestCombatInterrupt", true)
	g_eaPerson = gPeople[iPerson]
	if not g_eaPerson.aiHasCombatRole then
		--DebugFunctionExitTest("AIGPTestCombatInterrupt")
		return false
	end
	if GameInfo.EaActions[g_eaPerson.eaActionID].AICombatRole then	--currently doing combat action
		--DebugFunctionExitTest("AIGPTestCombatInterrupt")
		return false
	end

	local PlotDistance = Map.PlotDistance
	local GetPlotFromXY = Map.GetPlot

	print("GP has combat role and is not currently doing combat action")


	g_eaPlayer = gPlayers[iPlayer]
	--local bIsLeader = g_eaPlayer.leaderEaPersonIndex == iPerson
	--local bIsConstrainedLeader = bIsLeader and g_bAfterTurn120 and g_eaPerson.class1 ~= "Warrior" and g_eaPerson.class2 ~= "Warrior"

	local gpPlot, gpX, gpY, gpPlotIndex
	if unit then
		gpPlot = unit:GetPlot()
		gpX, gpY, gpPlotIndex = gpPlot:GetXYIndex()
	else
		gpX, gpY = g_eaPerson.x, g_eaPerson.y
		gpPlotIndex = GetPlotIndexFromXY(gpX, gpY)
		gpPlot = GetPlotFromXY(gpX, gpY)
	end
	
	local rallyPlot
	
	-- Set rallyPlot if Hostile cluster < 12 travel turns or PossibleSneak cluster < 6 travel turns
	-- If rallyPlot, then
	--		look around for current combat possibilities; if not then
	--		move toward rallyPlot; if can't move or already close then
	--		cancel interrupt

	local nearestHostileDist, nearestSneakDist = 13, 7	--won't interrupt unless smallest travel time is less than one of these values
	local nearestHostilePlot, nearestSneakPlot
	for iLoopPlayer, eaLoopPlayer in pairs(fullCivs) do
		local clusters = gg_unitClusters[iLoopPlayer]
		for i = 1, #clusters do
			print("Examining iPlayer, unit cluster ", iLoopPlayer, i)
			local cluster = clusters[i]
			if iLoopPlayer == iPlayer then		--Our unit cluster (maybe we are on the move)
				if cluster.iPlayerTarget then
					if cluster.intent == "Hostile" then
						if PlotDistance(gpX, gpY, cluster.x, cluster.y) < 24 then	--"pre-screen" here to prevent excessive AStar pathfinding
							--local tt = EaPersonAStarTurns(iPlayer, iPerson, gpX, gpY, cluster.x, cluster.y)
							local tt = unit:TurnsToReachTarget(GetPlotFromXY(cluster.x, cluster.y), 1, 1, 1)
							if tt < nearestHostileDist then
								nearestHostilePlot = GetPlotIndexFromXY(cluster.x, cluster.y)	--head for our unit cluster rather than suspected target
								nearestHostileDist = tt
							end
						end
					else
						if PlotDistance(gpX, gpY, cluster.x, cluster.y) < 12 then
							--local tt = EaPersonAStarTurns(iPlayer, iPerson, gpX, gpY, cluster.x, cluster.y)
							local tt = unit:TurnsToReachTarget(GetPlotFromXY(cluster.x, cluster.y), 1, 1, 1)
							if tt < nearestSneakDist then
								nearestSneakPlot = GetPlotIndexFromXY(cluster.x, cluster.y)
								nearestSneakDist = tt
							end
						end								
					end
				end
			elseif cluster.iPlayerTarget == iPlayer then			--Threat to us
				if cluster.intent == "Hostile" then
					if PlotDistance(gpX, gpY, cluster.x, cluster.y) < 24 then
						--local tt = EaPersonAStarTurns(iPlayer, iPerson, gpX, gpY, cluster.x, cluster.y)
						local tt = unit:TurnsToReachTarget(GetPlotFromXY(cluster.x, cluster.y), 1, 1, 1)
						if tt < nearestHostileDist then
							nearestHostilePlot = cluster.iPlotTarget	--head for suspected target city plot (should get us close enough to the action)
							nearestHostileDist = tt
						end
					end
				else
					if PlotDistance(gpX, gpY, cluster.x, cluster.y) < 12 then
						--local tt = EaPersonAStarTurns(iPlayer, iPerson, gpX, gpY, cluster.x, cluster.y)
						local tt = unit:TurnsToReachTarget(GetPlotFromXY(cluster.x, cluster.y), 1, 1, 1)
						if tt < nearestSneakDist then
							nearestSneakPlot = cluster.iPlotTarget
							nearestSneakDist = tt
						end
					end								
				end
			end
		end
	end
	rallyPlot = nearestHostilePlot or nearestSneakPlot

	if not rallyPlot then
		print("Found no rally plot for GP; moving on...")
		--DebugFunctionExitTest("AIGPTestCombatInterrupt")
		return false
	end

	local rallyX, rallyY = GetXYFromPlotIndex(rallyPlot)
	print("Found rally plot for GP ", rallyPlot, rallyX, rallyY)

	--Reset option tables
	g_optionsPos = 0
	for _, area in Map.Areas() do 
		g_areaOptions[area:GetID()].pos = 0
	end

	--Test and do current available combat action
	g_player = Players[iPlayer]
	local team = Teams[g_player:GetTeam()]
	local bNearbyEnemy = false
	for x, y in PlotToRadiusIterator(gpX, gpY, 5) do
		local plot = GetPlotFromXY(x, y)
		if plot:IsVisibleEnemyUnit(iPlayer) or (plot:IsOwned() and team:IsAtWar(Players[plot:GetOwner()]:GetTeam())) then
			bNearbyEnemy = true
			break
		end
	end
	if bNearbyEnemy then
		--set file locals
		g_iPlayer = iPlayer
		g_iPerson = iPerson
		g_unit = unit
		g_gpPlot = gpPlot
		g_gpPlotIndex = gpPlotIndex
		g_gpX = gpX
		g_gpY = gpY

		print("GP sees nearby hostile unit or territory; adding combat options")
		AddCombatOptions(rallyX, rallyY)
		if g_optionsPos ~= 0 then
			local bestVoption = CompareOptions(g_eaPerson)
			if bestVoption ~= 0 then
				print("GP found combat option with some value; will now attempt it")
				if DoOrGotoBestOption(bestVoption) then
					--DebugFunctionExitTest("AIGPTestCombatInterrupt")
					return true
				end
			end
		end
	end

	--No combat action was done so move toward rallyPlot
	if 4 < PlotDistance(gpX, gpY, rallyX, rallyY) then
		print("GP is >3 plots from rally plot; will now attempt to move to it")
		--ClearActionPlotTargetedForPerson(iPlayer, iPerson)
		DoEaAction(EA_ACTION_GO_TO_PLOT, iPlayer, unit, iPerson, rallyX, rallyY) 	--will interrupt whatever GP was doing before
		return true
	end

	--Note: if GP within 3 plots of rallyPoint and has no combat options, then it will be alowed to carry out non-combat options (but may be interupted again if it moves away)

	return false
end






