-- Plots
-- Author: Pazyryk
-- DateCreated: 2/11/2012 4:53:42 PM
--------------------------------------------------------------

print("Loading EaPlots.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

--constants
local ANIMALS_PLAYER_INDEX =				ANIMALS_PLAYER_INDEX

local PLOT_OCEAN =							PlotTypes.PLOT_OCEAN
local PLOT_LAND =							PlotTypes.PLOT_LAND
local PLOT_HILLS =							PlotTypes.PLOT_HILLS
local PLOT_MOUNTAIN =						PlotTypes.PLOT_MOUNTAIN

local TERRAIN_GRASS =						GameInfoTypes.TERRAIN_GRASS
local TERRAIN_PLAINS =						GameInfoTypes.TERRAIN_PLAINS
local TERRAIN_TUNDRA =						GameInfoTypes.TERRAIN_TUNDRA

local FEATURE_ICE =							GameInfoTypes.FEATURE_ICE
local FEATURE_FOREST = 						GameInfoTypes.FEATURE_FOREST
local FEATURE_JUNGLE = 						GameInfoTypes.FEATURE_JUNGLE
local FEATURE_MARSH =	 					GameInfoTypes.FEATURE_MARSH

local RESOURCE_TIMBER =						GameInfoTypes.RESOURCE_TIMBER
local RESOURCE_IVORY =						GameInfoTypes.RESOURCE_IVORY
local RESOURCE_ELEPHANT =					GameInfoTypes.RESOURCE_ELEPHANT
local RESOURCE_DEER =						GameInfoTypes.RESOURCE_DEER
local RESOURCE_BOARS =						GameInfoTypes.RESOURCE_BOARS
local RESOURCE_FUR =						GameInfoTypes.RESOURCE_FUR
local RESOURCE_WHALE =						GameInfoTypes.RESOURCE_WHALE
local RESOURCE_FISH =						GameInfoTypes.RESOURCE_FISH
local RESOURCE_CRAB =						GameInfoTypes.RESOURCE_CRAB
local RESOURCE_PEARLS =						GameInfoTypes.RESOURCE_PEARLS
local RESOURCE_YEW =						GameInfoTypes.RESOURCE_YEW
local RESOURCE_BLIGHT =						GameInfoTypes.RESOURCE_BLIGHT

local IMPROVEMENT_BARBARIAN_CAMP =			GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP
local IMPROVEMENT_FARM =					GameInfoTypes.IMPROVEMENT_FARM
local IMPROVEMENT_VINEYARD =				GameInfoTypes.IMPROVEMENT_VINEYARD
local IMPROVEMENT_LUMBERMILL =				GameInfoTypes.IMPROVEMENT_LUMBERMILL
local IMPROVEMENT_BLIGHT =					GameInfoTypes.IMPROVEMENT_BLIGHT

local BUILDING_TIMBERYARD_ALLOW =			GameInfoTypes.BUILDING_TIMBERYARD_ALLOW
local BUILDING_TIMBERYARD =					GameInfoTypes.BUILDING_TIMBERYARD
local BUILDING_CULT_LEAVES_FOLLOWER_FOOD =	GameInfoTypes.BUILDING_CULT_LEAVES_FOLLOWER_FOOD

local TECH_BRONZE_WORKING =					GameInfoTypes.TECH_BRONZE_WORKING
local TECH_IRON_WORKING =					GameInfoTypes.TECH_IRON_WORKING
local TECH_FORESTRY =						GameInfoTypes.TECH_FORESTRY

local POLICY_PANTHEISM =					GameInfoTypes.POLICY_PANTHEISM
local POLICY_FERAL_BOND =					GameInfoTypes.POLICY_FERAL_BOND
local POLICY_COMMUNE_WITH_NATURE =			GameInfoTypes.POLICY_COMMUNE_WITH_NATURE
local POLICY_FOREST_DOMINION =				GameInfoTypes.POLICY_FOREST_DOMINION

local RELIGION_CULT_OF_LEAVES =				GameInfoTypes.RELIGION_CULT_OF_LEAVES
local RELIGION_CULT_OF_PURE_WATERS =		GameInfoTypes.RELIGION_CULT_OF_PURE_WATERS
local RELIGION_CULT_OF_BAKKHEIA =			GameInfoTypes.RELIGION_CULT_OF_BAKKHEIA

--global tables
local Players =		Players
local Team =		Teams
local gWorld =		gWorld
local gPlayers =	gPlayers
local playerType =	MapModData.playerType
local bHidden =		MapModData.bHidden
local realCivs =	MapModData.realCivs
local gg_animalSpawnPlots = gg_animalSpawnPlots
local gg_animalSpawnInhibitTeams = gg_animalSpawnInhibitTeams

--localized functions
local Distance = Map.PlotDistance
local GetPlotFromXY = Map.GetPlot
local Floor = math.floor
local StrChar = string.char
local HandleError41 = HandleError41
local HandleError61 = HandleError61



local Rand = Map.Rand
local GetPlotByIndex = Map.GetPlotByIndex

--file control
--local g_validForestJunglePlots = 0		--counted at init (grass + plains + tundra)
local g_bNotVisibleByResourceID = {}
local g_bBlockedByFeatureID = {}
local g_addResource = {}
local g_plotHolder = {}  --used and recycled by living terrain
local g_newGrowthHolder = {}
local g_hasTechBronze = {}
local g_hasTechIron = {}
local g_hasTechForestry = {}
local g_bIsPantheistic = {}
local g_hasFeralBond = {}

local g_wildlandsCountCommuneWithNature = {}
local g_forestDominionPlayers = {}
local g_nonImprovedLivingTerrainStr = {}		--index by iPlot, holds str but only for non-improved
	--city tables below indexed by city object (clear all after use)
local g_cityPlots = {}
local g_cityFollowerReligion = {}	
local g_cityUnimprovedForestJungle = {}	--count for Cult of Leaves only


local integers1 = {}
local integers2 = {}

local bInitialized = false

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------

local techRevealByResourceID = {}
for row in GameInfo.Resources() do
	if row.TechReveal then
		local techID = GameInfoTypes[row.TechReveal]
		techRevealByResourceID[row.ID] = techID
	end
end
local featureUnblockedByTech = {}
featureUnblockedByTech[FEATURE_MARSH] = GameInfoTypes.TECH_IRRIGATION
featureUnblockedByTech[FEATURE_JUNGLE] = GameInfoTypes.TECH_IRON_WORKING

--resource converting buildings (assumes each map resource has only one kind of conversion)
local resourceBuildingConverts = {}
for row in GameInfo.Building_EaConvertImprovedResource() do
	resourceBuildingConverts[GameInfoTypes[row.ImprovedResource]] = {building = GameInfoTypes[row.BuildingType], resource = GameInfoTypes[row.AddResource]}
end

local typeIDTable = {[FEATURE_FOREST]="forest"; [FEATURE_JUNGLE]="jungle"; [FEATURE_MARSH]="marsh"}

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaPlotsInit(bNewGame)
	print("Running EaPlotsInit...")
	--new map stuff
	if bNewGame then 
		local GetPlotByIndex = GetPlotByIndex
		local Distance = Map.PlotDistance

		local livingTerrainTypes = {[GameInfoTypes.FEATURE_FOREST] = 1,	--"forest",
									[GameInfoTypes.FEATURE_JUNGLE] = 2,	--"jungle",
									[GameInfoTypes.FEATURE_MARSH] = 3	}	--"marsh"

		local Distance = Map.PlotDistance
		local validForestJunglePlots = 0
		local originalForestJunglePlots = 0
		local ownablePlots = 0
		for iPlot = 0, Map.GetNumPlots() - 1 do
			local plot = Map.GetPlotByIndex(iPlot)
			local plotTypeID = plot:GetPlotType()
			local terrainID = plot:GetTerrainType()
			local featureID = plot:GetFeatureType()
			local resourceID = plot:GetResourceType(-1)
			local livingTerrainType = livingTerrainTypes[featureID]
			if livingTerrainType then
				local strength = Map.Rand(4, "Terrain Strength")	--give living terrain a random strength from 0 to 3
				plot:SetLivingTerrainData(livingTerrainType, true, strength, -100)	-- -100 chop turn means never
			end

			if plotTypeID ~= GameInfoTypes.PLOT_MOUNTAIN then
				if resourceID ~= -1 or not plot:IsWater() or plot:IsLake() then
					ownablePlots = ownablePlots + 1
				end
				if terrainID == TERRAIN_GRASS or terrainID == TERRAIN_PLAINS or terrainID == TERRAIN_TUNDRA then
					validForestJunglePlots = validForestJunglePlots + 1
					if featureID == GameInfoTypes.FEATURE_FOREST or featureID == GameInfoTypes.FEATURE_JUNGLE then
						originalForestJunglePlots = originalForestJunglePlots + 1
					end 
				end
			end 
			
		end
		print(" - originalForestJunglePlots, validForestJunglePlots, ownablePlots = ", originalForestJunglePlots, validForestJunglePlots, ownablePlots)
		MapModData.validForestJunglePlots = validForestJunglePlots
		MapModData.originalForestJunglePlots = originalForestJunglePlots
		MapModData.ownablePlots = ownablePlots
		local SaveDB = Modding.OpenSaveData()
		SaveDB.SetValue("ValidForestJunglePlots", validForestJunglePlots)
		SaveDB.SetValue("OriginalForestJunglePlots", originalForestJunglePlots)
		SaveDB.SetValue("OwnablePlots", ownablePlots)

		--Weaken to 0 around Man starting plot (3 radius); remove from 1 radius
		for iPlayer, eaPlayer in pairs(realCivs) do
			if eaPlayer.race == GameInfoTypes.EARACE_MAN then
				local player = Players[iPlayer]
				local startingPlot = player:GetStartingPlot()
				local startX, startY = startingPlot:GetX(), startingPlot:GetY()
				for x, y in PlotToRadiusIterator(startX, startY, 3) do
					local distance = Distance(x, y, startX, startY)
					local plot = GetPlotFromXY(x, y)
					if distance < 2 then
						plot:SetFeatureType(-1)
						plot:SetLivingTerrainData(-1, false, 0, -100)	--never existed
					else
						plot:SetLivingTerrainStrength(0)					
					end
				end
			end
		end
	else		--Loaded game
		local SaveDB = Modding.OpenSaveData()
		MapModData.validForestJunglePlots = SaveDB.GetValue("ValidForestJunglePlots", validForestJunglePlots)
		MapModData.originalForestJunglePlots = SaveDB.GetValue("OriginalForestJunglePlots", originalForestJunglePlots)
		MapModData.ownablePlots = SaveDB.GetValue("OwnablePlots", ownablePlots)
	end

	for iPlayer, eaPlayer in pairs(realCivs) do
		g_addResource[iPlayer] = {}
		g_bNotVisibleByResourceID[iPlayer] = {}
		g_bBlockedByFeatureID[iPlayer] = {}
	end

	--all plots cycle (new or loaded)

	local totalLivingTerrainStrength = 0
	local lakeCounter, fishingCounter, whaleCounter, campCounter = 0, 0, 0, 0
	for iPlot = 0, Map.GetNumPlots() - 1 do
		local x, y = GetXYFromPlotIndex(iPlot)
		local plot = GetPlotByIndex(iPlot)
		local plotTypeID = plot:GetPlotType()
		local terrainID = plot:GetTerrainType()
		local resourceID = plot:GetResourceType(-1)
		local featureID = plot:GetFeatureType()
		local type, present, strength, turnChopped = plot:GetLivingTerrainData()
		--remote resource/improvement tracking
		if resourceID ~= -1 then
			if resourceID == RESOURCE_WHALE then
				whaleCounter = whaleCounter + 1
				gg_whales[whaleCounter] = {x = x, y = y}
			elseif resourceID == RESOURCE_FISH or resourceID == RESOURCE_CRAB or resourceID == RESOURCE_PEARLS then
				fishingCounter = fishingCounter + 1
				gg_fishingBoatResources[fishingCounter] = {x = x, y = y}
			elseif resourceID == RESOURCE_DEER or resourceID == RESOURCE_BOARS or resourceID == RESOURCE_FUR or resourceID == RESOURCE_ELEPHANT then
				campCounter = campCounter + 1
				gg_campResources[campCounter] = {x = x, y = y}
			end
		end
		if plot:IsLake() then
			lakeCounter = lakeCounter + 1
			gg_lakes[lakeCounter] = {x = x, y = y}
		end
		--tracking for strength conversion
		local bNonImpLiving = true
		local featureID = plot:GetFeatureType()
		if typeIDTable[featureID] and plot:GetImprovementType() == -1 then
			g_nonImprovedLivingTerrainStr[iPlot] = plot:GetLivingTerrainStrength()
		else
			g_nonImprovedLivingTerrainStr[iPlot] = nil
		end
		--Natural Wonders
		if featureID ~= -1 then
			local featureInfo = GameInfo.Features[featureID]
			if featureInfo.NaturalWonder then
				local nwTable = {}
				nwTable.x = x
				nwTable.y = y
				if featureInfo.EaGod then
					local godID = GameInfoTypes[featureInfo.EaGod]
					--which player is this god?
					if godID then
						local iGod
						for iPlayer = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1 do
							local player = Players[iPlayer]
							if player:IsAlive() and player:GetMinorCivType() == godID then
								iGod = iPlayer
								break
							end
						end
						if iGod then
							nwTable.godID = godID
							nwTable.iGod = iGod
						end
					end
				end
				gg_naturalWonders[featureInfo.ID] = nwTable
			end
		end
		totalLivingTerrainStrength = totalLivingTerrainStrength + strength
	end

	MapModData.totalLivingTerrainStrength = totalLivingTerrainStrength
	print("Lakes, FishingResources, Whales, CampResources ", lakeCounter, fishingCounter, whaleCounter, campCounter)
end

function EaPlotsInitialized()	--delay until player in game
	bInitialized = true
end


--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function PlaceResourceNearCity(city, resourceID, bWater)
	print("Running PlaceResourceNearCity ", city, resourceID)
	local resourceInfo = GameInfo.Resources[resourceID]
	local cityX, cityY = city:GetX(), city:GetY()

	--find existing resource (pref based on distance to same)
	local numSameResource = 0
	for x, y in PlotToRadiusIterator(cityX, cityY, 3, nil, nil, false) do
		local plot = GetPlotFromXY(x, y)
		if plot:GetResourceType(-1) == resourceID then
			numSameResource = numSameResource + 1
			integers1[numSameResource] = x
			integers2[numSameResource] = y
		end
	end

	local distancePref = {4, 10, 8, 6, 4, 2, 0, 0, 0, 0, 0}
	local bestPlot
	local bestPlotScore = -1

	for x, y in PlotToRadiusIterator(cityX, cityY, 3, nil, nil, true) do
		local plot = GetPlotFromXY(x, y)
		local plotScore = 0
		if plot:GetResourceType(-1) == -1 and not plot:IsMountain() and not plot:IsLake() and not plot:IsWater() == not bWater then
			if plot:CanHaveResource(resourceID, false) then		--works???
				plotScore = plotScore + 1000
			end
			plotScore = plotScore + 3 - Distance(x, y, cityX, cityY)	--closer to city, all else equal
			for i = 1, numSameResource do
				local dist = Distance(x, y, integers1[i], integers2[i])
				plotScore = plotScore + distancePref[dist]
			end
		else
			plotScore = -100	--never allowed
		end
		if bestPlotScore < plotScore then
			bestPlotScore = plotScore
			bestPlot = plot
		end
	end
	if bestPlot then
		print("Placing resource; best plot score was: ", bestPlotScore)
		local number = 1
		for row in GameInfo.Resource_QuantityTypes("ResourceType = '" .. resourceInfo.Type .. "'") do
			number = row.Quantity		--will take last (and therefore smaller) value from table
		end
		ChangeResource(bestPlot, resourceID, number)
	end
	--spawn forest for Yew
end

function ChangeResource(plot, resourceID, number)	--modified from IGE (use resourceID = -1 to remove)
	print("Running ChangeResource ", plot, resourceID, number)
	local iOwner = plot:GetOwner()
	if iOwner ~= -1 then
		local city = plot:GetWorkingCity()
		local bWorking = false
		local bForced = false
  
		if city then
			bWorking = city:IsWorkingPlot(plot)
			if bWorking then
				bForced = city:IsForcedWorkingPlot(plot)
				city:AlterWorkingPlot(city:GetCityPlotIndex(plot))
			end
		end

		plot:SetOwner(-1)

		if resourceID == -1 then
			plot:SetResourceType(-1)
			LuaEvents.SerialEventRawResourceIconDestroyed(plot:GetX(), plot:GetY())
		else
			plot:SetResourceType(resourceID, number)
		end

		plot:SetOwner(iOwner)

		if bWorking then
			if bForced then
				city:AlterWorkingPlot(city:GetCityPlotIndex(plot))
			else
				Network.SendDoTask(city:GetID(), TaskTypes.TASK_CHANGE_WORKING_PLOT, 0)
			end
		end
	else
		if resourceID == -1 then
			plot:SetResourceType(-1)
			LuaEvents.SerialEventRawResourceIconDestroyed(plot:GetX(), plot:GetY())
		else
			plot:SetResourceType(resourceID, number)
		end
	end
end

function ChangePlotOwner(plot, iPlayer, iCity)
	print("Running ChangePlotOwner ", plot, iPlayer, iCity)
	plot:SetOwner(iPlayer, iCity)		--seems to be OK if iCity is nil
	--do we need to do something with resource dist matrixes?
end


function ChangeLivingTerrainStrengthWorldWide(changeValue, iPlayer)		--leave iPlayer nil if no one deserves credit or blame
	local totalStrengthAdded = 0
	for iPlot = 0, Map.GetNumPlots() - 1 do
		local plot = GetPlotByIndex(iPlot)
		local featureID = plot:GetFeatureType()
		if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE or featureID == FEATURE_MARSH then
			local type, present, strength, turnChopped = plot:GetLivingTerrainData()
			if type == -1 then
				strength = 0
				turnChopped = -100
				if featureID == FEATURE_FOREST then
					type = 1	--"forest"
				elseif featureID == FEATURE_JUNGLE then
					type = 2	--"jungle"
				else
					type = 3	--"marsh"
				end
			end
			plot:SetLivingTerrainData(type, true, strength + changeValue, turnChopped)
			totalStrengthAdded = totalStrengthAdded + changeValue
		end
	end
	-- give credit
	if iPlayer then
		local eaPlayer = gPlayers[iPlayer]
		eaPlayer.livingTerrainStrengthAdded = (eaPlayer.livingTerrainStrengthAdded or 0) + totalStrengthAdded
	end
	return totalStrengthAdded
end


--DEPRECIATE: Replace with function below when CityCanAcquirePlot comes on line
local function ListenerSerialEventHexCultureChanged(hexX, hexY, iPlayer, bUnknown)	--fires for all owned plots at game init too
	--print("ListenerSerialEventHexCultureChanged ", hexX, hexY, iPlayer, bUnknown)
	if bHidden[iPlayer] then	--these only ever own city plot
		local x, y = ToGridFromHex( hexX, hexY )
		local capital = Players[iPlayer]:GetCapitalCity()
		if x ~= capital:GetX() or y ~= capital:GetY() then
			Dprint("Cancelling hidden civ plot ownership")
			local plot = GetPlotFromXY(x,y)
			plot:SetOwner(-1, -1)
		end	
	elseif bInitialized then
		Dprint(string.format("Hex ownership change at hex coordinates: %d, %d for player: %d", hexX, hexY, iPlayer))
		if iPlayer ~= -1 then
			local x, y = ToGridFromHex( hexX, hexY )
			local plot = GetPlotFromXY(x,y)
			if plot:IsWater() and gg_bPreventWaterOwnership then			--hills & mountains?
				if plot:GetResourceType(-1) == -1 then	--allow if resource (can't seem to stop spread to these when city-adjacent)
					--print("Cancelling water ownership")
					plot:SetOwner(-1, -1)
				end
				gg_bPreventWaterOwnership = true
			end
		end
	end
end
Events.SerialEventHexCultureChanged.Add(ListenerSerialEventHexCultureChanged)


-- GameEvents

--[[	In preparation for CityCanAcquirePlot
local function OnCityCanAcquirePlot(iPlayer, iCity, x, y)
	print("OnCityCanAcquirePlot ", iPlayer, iCity, x, y)
	local plot = GetPlotFromXY(x,y)
	if plot:IsWater() then return false end
	if plot:IsMountain() then return false end
	return true
end
GameEvents.CityCanAcquirePlot.Add(OnCityCanAcquirePlot)
]]


local function OnUnitSetXYPlotEffect(iPlayer, iUnit, x, y, plotEffectID, plotEffectStrength)
	print("OnUnitSetXYPlotEffect ", iPlayer, iUnit, x, y, plotEffectID, plotEffectStrength)


end
GameEvents.UnitSetXYPlotEffect.Add(function(iPlayer, iUnit, x, y, plotEffectID, plotEffectStrength) return HandleError61(OnUnitSetXYPlotEffect, iPlayer, iUnit, x, y, plotEffectID, plotEffectStrength) end)

local function OnBuildFinished(iPlayer, x, y, improvementID)		--Is improvementID necessarily the one built, or is it any improvement that happens to be there???
	print("OnBuildFinished ", iPlayer, x, y, improvementID)
	if improvementID == -1 then
		local plot = GetPlotFromXY(x, y)
		if plot:GetImprovementType() == IMPROVEMENT_BLIGHT then
			print("Worker must have removed FEATURE_BLIGHT; now removing IMPROVEMENT_BLIGHT")
			plot:SetImprovementType(-1)
		end
		if plot:GetResourceType(-1) == RESOURCE_BLIGHT then
			print("Worker must have removed FEATURE_BLIGHT; now removing RESOURCE_BLIGHT")
			plot:SetResourceType(-1)
		end
	end
end
GameEvents.BuildFinished.Add(function(iPlayer, x, y, improvementID) return HandleError41(OnBuildFinished, iPlayer, x, y, improvementID) end)

--------------------------------------------------------------
-- Main Per Turn Plot Loop
--------------------------------------------------------------

local function DoLivingTerrainSpread()
	-- self-regeneration already done
	for iPlot, spreadType in pairs(g_newGrowthHolder) do
		--print("living terrain spreads ", iPlot, spreadType)
		local plot = GetPlotByIndex(iPlot)
		local type, present, strength, turnChopped = plot:GetLivingTerrainData()
		if type == -1 then	--"none"
			LivingTerrainGrowHere(iPlot, spreadType)
			plot:SetLivingTerrainData(spreadType, true, 0, -100)
			print("Living terrain has spread to an adjacent (non-living) tile: ", spreadType, iPlot)
		else
			if plot:GetFeatureType() == -1 then	--skip if feature here now (may have regenerated on its own)
				--may have conflict now between spread type and old (currently absent) type; don't want to kill a strong terrain
				if spreadType == type or strength > 2 then	--re-grow and keep old strength (respawns as its own type)
					LivingTerrainGrowHere(iPlot, type)	
					plot:SetLivingTerrainData(type, true, strength, turnChopped)
					print("Living terrain has re-awakened an adjacent tile: ", type, true, strength, turnChopped)
				else	--kind of weak so just replace (type must be consistent with current feature or chops get very messy)
					LivingTerrainGrowHere(iPlot, spreadType)	
					plot:SetLivingTerrainData(spreadType, true, 1, turnChopped)
					print("Living terrain has overcome an adjacent living tile.")
					print("Was, ", type, true, strength, turnChopped)
					print("Is now: ", spreadType, true, 1, turnChopped)
				end
			end
		end
		g_newGrowthHolder[iPlot] = nil
	end
end

local function UseAccumulatedLivingTerrainEffects()
	-- strengthen random unimproved Living Terrain for conversion process or other accumulated effects (this is behind conversion accumulation by 1 turn and for new growth by 2 but doesn't matter)
	local strengthPoints = Floor(gWorld.livingTerrainConvertStr)
	if 0 < strengthPoints then
		local pointsUsed = 0
		local numPlots = 0
		for iPlot, strength in pairs(g_nonImprovedLivingTerrainStr) do
			numPlots = numPlots + 1
			integers1[numPlots] = iPlot
		end
		print("Number of unimproved Living Terrain plots for possible strengthening = ", numPlots)
		if 0 < numPlots then
			while pointsUsed < strengthPoints do
				local index = Rand(numPlots, "hello") + 1
				local iPlot = integers1[index]
				local plot = GetPlotByIndex(iPlot)
				local type, present, strength, turnChopped = plot:GetLivingTerrainData()
				if type == -1 then
					strength = 0
					turnChopped = -100
					if featureID == FEATURE_FOREST then
						type = 1	--"forest"
					elseif featureID == FEATURE_JUNGLE then
						type = 2	--"jungle"
					else
						type = 3	--"marsh"
					end
				end
				plot:SetLivingTerrainData(type, true, strength + 1, turnChopped)
				pointsUsed = pointsUsed + 1
				print("Strengthened random valid plot (iPlot/type/oldStr): ", iPlot, type, strength)
			end
		end
		gWorld.livingTerrainConvertStr = gWorld.livingTerrainConvertStr - pointsUsed
	end
end

local function ResetTablesForPlotLoop()
	local numForestDominionPlayers = 0
	for iPlayer, eaPlayer in pairs(realCivs) do			--do we need all this for city states???

		for i, v in pairs(g_addResource[iPlayer]) do
			g_addResource[iPlayer][i] = 0
		end

		for i in pairs(eaPlayer.ImprovementsByID) do
			eaPlayer.ImprovementsByID[i] = 0
		end
		for i in pairs(eaPlayer.ImprovedResourcesByID) do
			eaPlayer.ImprovedResourcesByID[i] = 0
		end

		for i in pairs(eaPlayer.resourcesInBorders) do
			eaPlayer.resourcesInBorders[i] = 0
		end
		for i in pairs(eaPlayer.plotSpecialsInBorders) do
			eaPlayer.plotSpecialsInBorders[i] = 0
		end

		--set player flags so we don't have to check for every plot
		local player = Players[iPlayer]
		local team = Teams[player:GetTeam()]
		g_hasTechBronze[iPlayer] = team:IsHasTech(TECH_BRONZE_WORKING)
		g_hasTechIron[iPlayer] = team:IsHasTech(TECH_IRON_WORKING)
		g_hasTechForestry[iPlayer] = team:IsHasTech(TECH_FORESTRY)

		for resourceID, techID in pairs(techRevealByResourceID) do
			g_bNotVisibleByResourceID[iPlayer][resourceID] = not team:IsHasTech(techID)
		end
		for featureID, techID in pairs(featureUnblockedByTech) do
			g_bBlockedByFeatureID[iPlayer][featureID] = not team:IsHasTech(techID)
		end
		if playerType[iPlayer] == "FullCiv" and player:HasPolicy(POLICY_PANTHEISM) then
			g_bIsPantheistic[iPlayer] = true
			g_hasFeralBond[iPlayer] = player:HasPolicy(POLICY_FERAL_BOND)
			g_wildlandsCountCommuneWithNature[iPlayer] = player:HasPolicy(POLICY_COMMUNE_WITH_NATURE) and 0 or nil
			if player:HasPolicy(POLICY_FOREST_DOMINION) then
				numForestDominionPlayers = numForestDominionPlayers + 1
				g_forestDominionPlayers[numForestDominionPlayers] = iPlayer
			end
		else		--need code for pantheistic CSs
			g_bIsPantheistic[iPlayer] = false
			g_hasFeralBond[iPlayer] = false
			g_wildlandsCountCommuneWithNature[iPlayer] = nil
		end
	end
	for i = numForestDominionPlayers + 1, #g_forestDominionPlayers do
		g_forestDominionPlayers[i] = nil
	end
end

function PlotsPerTurn()
	print("Running PlotsPerTurn")
	local LivingTerrainGrowHere = LivingTerrainGrowHere
	local PlotToRadiusIterator = PlotToRadiusIterator
	local Floor = math.floor

	local encampments = gWorld.encampments

	local gameTurn = Game.GetGameTurn()

	ResetTablesForPlotLoop()

	local numForestDominionPlayers = #g_forestDominionPlayers
	local numAnimalSpawnInhibitTeams = #gg_animalSpawnInhibitTeams
	local numAnimalSpawnPlots = 0
	local totalLivingTerrainStrength = 0
	local forestPlots = 0
	local junglePlots = 0
	local waterWorkedByPureWatersFollower = 0
	local grapesWorkedByBakkeiaFollower = 0

	--Main plot loop
	for iPlot = 0, Map.GetNumPlots() - 1 do
		local x, y = GetXYFromPlotIndex(iPlot)
		local plot = GetPlotByIndex(iPlot)
		local type, present, strength, turnChopped = plot:GetLivingTerrainData()
		local plotTypeID = plot:GetPlotType()
		local featureID = plot:GetFeatureType()
		local improvementID = plot:GetImprovementType()
		local resourceID = plot:GetResourceType(-1)
		local iOwner = plot:GetOwner()
		local bIsCity = plot:IsCity()
		local bIsWater = plot:IsWater()
		local bIsImpassable = plot:IsImpassable()

		--Encampments
		if improvementID == IMPROVEMENT_BARBARIAN_CAMP then
			if not encampments[iPlot] then
				InitUpgradeEncampment(iPlot, x, y, plot)	--in EaBarbarians.lua
			end
		else
			encampments[iPlot] = nil
		end

		--Animals
		if not bIsWater and plotTypeID ~= PLOT_MOUNTAIN and not bIsCity and not bIsImpassable and (iOwner == -1 or g_hasFeralBond[iOwner]) and plot:GetNumUnits() == 0 then
			local bAllow = true
			for i = 1, numAnimalSpawnInhibitTeams do
				if 0 < plot:GetVisibilityCount(gg_animalSpawnInhibitTeams[i]) then
					bAllow = false
					break
				end
			end
			if bAllow then
				numAnimalSpawnPlots = numAnimalSpawnPlots + 1
				gg_animalSpawnPlots[numAnimalSpawnPlots] = iPlot
			end
		end

		--Simple world-wide counts
		totalLivingTerrainStrength = totalLivingTerrainStrength + (strength or 0)
		if plotTypeID ~= PLOT_MOUNTAIN then
			if featureID == FEATURE_FOREST then
				forestPlots = forestPlots + 1
			elseif featureID == FEATURE_JUNGLE then
				junglePlots = junglePlots + 1
			end
		end

		--Yew destroyed without forest or jungle
		if resourceID == RESOURCE_YEW and featureID ~= FEATURE_FOREST and featureID ~= FEATURE_JUNGLE then
			ChangeResource(plot, -1, nil)
			resourceID = -1
		end

		--living terrain
		if type ~= -1 then
			if present then								-- was present on last turn
				if featureID == -1 then				-- must have been removed last turn
					if iOwner ~= -1 then				--set turnChopped if forest or jungle owned and owner has chopping tech (used later for timber)
						if type == 1 then	-- "forest"	
							if g_hasTechBronze[iOwner] then turnChopped = gameTurn end
						elseif type == 2 then	--"jungle"
							if g_hasTechIron[iOwner] then turnChopped = gameTurn end
						end
					end
					if strength <= 1 then
						print("a living terrain has been killed. Previously: ", type, present, strength, turnChopped, featureID)
						type, present, strength = -1, false, 0						--finally killed
					else
						strength = strength - 1			--weaken it
						present = false					--it's not "present" for the time being
						print("a living terrain has been weakened. Now: ", type, present, strength, turnChopped, featureID)
					end
				elseif improvementID == -1 or (improvementID ~= IMPROVEMENT_LUMBERMILL and improvementID ~= IMPROVEMENT_FARM) or plot:IsImprovementPillaged() then	--these suppress living terrain
					if Rand(100, "living terrain spread") < strength then	 --successful spread (will spread if any valid adjacent tile)		
						local x = plot:GetX()
						local y = plot:GetY()
						for xAdj, yAdj in PlotToRadiusIterator(x, y, 1) do
							local plotAdj = GetPlotFromXY(xAdj, yAdj)
							local iPlotAdj = GetPlotIndexFromXY(xAdj, yAdj)
							if plotAdj and plotAdj:GetFeatureType() == -1 and not plotAdj:IsCity() then	--test for valid spread tile
								local adjPlotType = plotAdj:GetPlotType()
								if adjPlotType ~= PLOT_MOUNTAIN then
									local adjTerrainType = plotAdj:GetTerrainType()
									if type == 1 then	--"forest"
										if adjTerrainType == TERRAIN_GRASS or adjTerrainType == TERRAIN_PLAINS or adjTerrainType == TERRAIN_TUNDRA then
											g_plotHolder[#g_plotHolder + 1] = iPlotAdj
										end
									elseif type == 2 then	--"jungle"
										if adjTerrainType == TERRAIN_GRASS or adjTerrainType == TERRAIN_PLAINS then
											g_plotHolder[#g_plotHolder + 1] = iPlotAdj
										end								
									elseif type == 3 then	--"marsh"
										if adjTerrainType == TERRAIN_GRASS and adjPlotType == PlotTypes.PLOT_LAND then
											g_plotHolder[#g_plotHolder + 1] = iPlotAdj
										end		
									end
								end
							end
						end
						if #g_plotHolder > 0 then		--spread
							local dice = Rand(#g_plotHolder, "hello there!") + 1
							local iPlotChange = g_plotHolder[dice]
							g_newGrowthHolder[iPlotChange] = type		--go back and do after (need to resolve situation if this is already living or regenerates itself)
							for i = #g_plotHolder, 1, -1 do --recycle holder
								g_plotHolder[i] = nil
							end
						end
					end
					--Possible take-over by adjacent player with Forest Dominion policy
					if (featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE) and plot:IsAdjacentOwned() then
						if Rand(50, "Forest Dominion takeover") < 1 then		-- 2% chance if qualified plot
							local iNewOwner = -1
							for i = 1, numForestDominionPlayers do
								local iFDPlayer = g_forestDominionPlayers[i]
								if iOwner == iFDPlayer then
									iNewOwner = -1			--owner can defend with Forest Dominion
									break
								elseif plot:IsAdjacentPlayer(iFDPlayer, true) then		-- WORKS ????
									iNewOwner = iFDPlayer
								end
							end
							if iNewOwner ~= -1 then
								ChangePlotOwner(plot, iNewOwner, nil)
							end
						end
					end
				end
			else	--currently not present (ie, was remvoed in the past, will it regenerate?)
				if plot:IsCity() then	--permanently remove (possibly chopped)
					type, present, strength = -1, false, 0
					print("Living terrain removed for city")
				elseif featureID == -1 and Rand(100, "hello there!") < strength	then	--it's back!
					LivingTerrainGrowHere(iPlot, type)
					present = true
					print("Living terrain has self-generated: ", type, present, strength, turnChopped)
				end
			end
			--update script data if it has changed
			plot:SetLivingTerrainData(type, present, strength, turnChopped)
		end

		--track unimproved living terrain (just reassess after changes above)
		featureID = plot:GetFeatureType()
		if typeIDTable[featureID] and improvementID == -1 then
			g_nonImprovedLivingTerrainStr[iPlot] = plot:GetLivingTerrainStrength()
		else
			g_nonImprovedLivingTerrainStr[iPlot] = nil
		end

		--improvement and resource counting
		if iOwner ~= -1 then
			local eaOwner = gPlayers[iOwner]
			local owner = Players[iOwner]
			local iOwnerTeam = owner:GetTeam()	
			--local resourceID = plot:GetResourceType(iOwnerTeam)		--visable only
			--local improvementID = plot:GetImprovementType()

			-- plot special used for AI
			local resourceID = plot:GetResourceType(-1)
			if resourceID ~= -1 and not g_bNotVisibleByResourceID[iOwner][resourceID] and not g_bBlockedByFeatureID[iOwner][resourceID] then		--visible test is now useless???
				eaOwner.resourcesInBorders[resourceID] = (eaOwner.resourcesInBorders[resourceID] or 0) + 1
			end
			--local plotTypeID = plot:GetPlotType()
			--local terrainID = plot:GetTerrainType()
			local bFreshWater = plot:IsFreshWater()
			local plotSpecial
			if plotTypeID == PLOT_OCEAN then
				if featureID ~= FEATURE_ICE then plotSpecial = "Sea" end
			elseif plotTypeID == PLOT_MOUNTAIN then
				plotSpecial = "Mountain"
			elseif featureID == FEATURE_FOREST then
				plotSpecial = "Forest"
			elseif featureID == FEATURE_JUNGLE then
				plotSpecial = "Jungle"
			elseif featureID == FEATURE_MARSH then
				plotSpecial = "Marsh"
			elseif featureID == -1 then
				if plotTypeID == PLOT_HILLS then
					plotSpecial = "Hill"
				elseif bFreshWater and plotTypeID == PLOT_LAND then
					plotSpecial = "Irrigable"
				end
			end
			if plotSpecial then
				eaOwner.plotSpecialsInBorders[plotSpecial] = (eaOwner.plotSpecialsInBorders[plotSpecial] or 0) + 1
				--Error on line above probably means a hidden civ aquired land somehow
			end

			if improvementID == -1 then
				g_wildlandsCountCommuneWithNature[iOwner] = g_wildlandsCountCommuneWithNature[iOwner] and g_wildlandsCountCommuneWithNature[iOwner] + 1
			else
				-- add to player count
				eaOwner.ImprovementsByID[improvementID] = (eaOwner.ImprovementsByID[improvementID] or 0) + 1
			end

			--working city counts
			local workingCity = plot:GetWorkingCity()
			if workingCity then

				g_cityPlots[workingCity] = (g_cityPlots[workingCity] or 0) + 1

				g_cityFollowerReligion[workingCity] = g_cityFollowerReligion[workingCity] or workingCity:GetReligiousMajority()
				if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE then
					--timber and timberyard
					if workingCity:GetNumBuilding(BUILDING_TIMBERYARD) == 1 then
						if improvementID == IMPROVEMENT_LUMBERMILL then
							g_addResource[iOwner][RESOURCE_TIMBER] = (g_addResource[iOwner][RESOURCE_TIMBER] or 0) + (g_hasTechForestry[iOwner] and 1 or 0.5)
						elseif g_bIsPantheistic[iOwner] then
							g_addResource[iOwner][RESOURCE_TIMBER] = (g_addResource[iOwner][RESOURCE_TIMBER] or 0) + (g_hasTechForestry[iOwner] and 0.25 or 0.125)
						end
					else
						workingCity:SetNumRealBuilding(BUILDING_TIMBERYARD_ALLOW, 1)
					end
					--cult of leaves info
					if improvementID == -1 and g_cityFollowerReligion[workingCity] == RELIGION_CULT_OF_LEAVES then
						g_cityUnimprovedForestJungle[workingCity] = (g_cityUnimprovedForestJungle[workingCity] or 0) + 1
					end
				elseif featureID == FEATURE_OASIS or plot:IsLake() then
					if g_cityFollowerReligion[workingCity] == RELIGION_CULT_OF_PURE_WATERS then
						waterWorkedByPureWatersFollower = waterWorkedByPureWatersFollower + 1
					end
				end
				if improvementID == IMPROVEMENT_VINEYARD then
					if g_cityFollowerReligion[workingCity] == RELIGION_CULT_OF_BAKKHEIA then
						grapesWorkedByBakkeiaFollower = grapesWorkedByBakkeiaFollower + 1
					end
				end
			end

			--timber from recent chop
			if turnChopped and turnChopped > gameTurn - 20 then		--integer here sets the durration of a "timber pile"
				g_addResource[iOwner][RESOURCE_TIMBER] = (g_addResource[iOwner][RESOURCE_TIMBER] or 0) + (g_hasTechForestry[iOwner] and 2 or 1)
			end

			if resourceID ~= -1 and (improvementID ~= -1 or bIsCity) then
				eaOwner.ImprovedResourcesByID[resourceID] = (eaOwner.ImprovedResourcesByID[resourceID] or 0) + 1				-- add to player count
				
				--building conversion (replace ivory counting below)
				local resourceConvert = resourceBuildingConverts[resourceID]
				if resourceConvert then
					local workingCity = plot:GetWorkingCity()
					if workingCity and workingCity:GetNumBuilding(resourceConvert.building) > 0 then
						local newResourceID = resourceConvert.resource
						g_addResource[iOwner][newResourceID] = (g_addResource[iOwner][newResourceID] or 0) + 1
					end
				end				
			end
		end
	end		--end of main plot loop

	-- housekeeping
	gg_animalSpawnPlots.pos = numAnimalSpawnPlots
	MapModData.totalLivingTerrainStrength = totalLivingTerrainStrength

	-- apply resources or yields
	local iCultOfLeavesFounder = gReligions[RELIGION_CULT_OF_LEAVES] and gReligions[RELIGION_CULT_OF_LEAVES].founder
	local iCultOfPureWatersFounder = gReligions[RELIGION_CULT_OF_PURE_WATERS] and gReligions[RELIGION_CULT_OF_PURE_WATERS].founder
	local iCultOfBakkheiaFounder = gReligions[RELIGION_CULT_OF_BAKKHEIA] and gReligions[RELIGION_CULT_OF_BAKKHEIA].founder
	for iPlayer, eaPlayer in pairs(realCivs) do
		local player = Players[iPlayer]
		for resourceID, number in pairs(g_addResource[iPlayer]) do
			number = Floor(number)
			local change = number - (eaPlayer.addedResources[resourceID] or 0)
			if change ~= 0 then
				player:ChangeNumResourceTotal(resourceID, change)
				eaPlayer.addedResources[resourceID] = number
			end
		end

		if g_wildlandsCountCommuneWithNature[iPlayer] then
			eaPlayer.cultureManaFromWildlands = Floor(g_wildlandsCountCommuneWithNature[iPlayer] / 4)
		end
		if iPlayer == iCultOfLeavesFounder then
			local mana = Floor(100 * (forestPlots + junglePlots - MapModData.originalForestJunglePlots) / MapModData.validForestJunglePlots)
			if 0 < mana then
				eaPlayer.manaForCultOfLeavesFounder = mana
			end
		end
		if iPlayer == iCultOfPureWatersFounder then
			eaPlayer.manaForCultOfPureWatersFounder = waterWorkedByPureWatersFollower	--added to by EaCities.lua
		end
		if iPlayer == iCultOfBakkheiaFounder then
			eaPlayer.manaForCultOfBakkheiaFounder = grapesWorkedByBakkeiaFollower		--added to by EaCities.lua
		end
	end

	--city effects
	for city, unimprovedForestJungle in pairs(g_cityUnimprovedForestJungle) do
		local food = Floor(10 * unimprovedForestJungle / g_cityPlots[city])
		city:SetNumRealBuilding(BUILDING_CULT_LEAVES_FOLLOWER_FOOD, food)
		g_cityUnimprovedForestJungle[city] = nil		--recycle table
	end
	for city in pairs(g_cityFollowerReligion) do
		g_cityFollowerReligion[city] = nil
	end
	for city in pairs(g_cityPlots) do
		g_cityPlots[city] = nil
	end



	DoLivingTerrainSpread()
	UseAccumulatedLivingTerrainEffects()

end



function LivingTerrainGrowHere(iPlot, type)
	local plot = GetPlotByIndex(iPlot)
	if type == 1 then	--"forest"
		plot:SetFeatureType(FEATURE_FOREST)
	elseif type == 2 then	-- "jungle"
		plot:SetFeatureType(FEATURE_JUNGLE)
	elseif type == 3 then	--"marsh"
		plot:SetFeatureType(FEATURE_MARSH)
	end
end





