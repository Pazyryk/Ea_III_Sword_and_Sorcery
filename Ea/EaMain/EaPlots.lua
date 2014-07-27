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

local EA_PLOTEFFECT_PROTECTIVE_WARD =		GameInfoTypes.EA_PLOTEFFECT_PROTECTIVE_WARD

local PlotTypes =							PlotTypes
local PLOT_OCEAN =							PlotTypes.PLOT_OCEAN
local PLOT_LAND =							PlotTypes.PLOT_LAND
local PLOT_HILLS =							PlotTypes.PLOT_HILLS
local PLOT_MOUNTAIN =						PlotTypes.PLOT_MOUNTAIN

local TERRAIN_GRASS =						GameInfoTypes.TERRAIN_GRASS
local TERRAIN_PLAINS =						GameInfoTypes.TERRAIN_PLAINS
local TERRAIN_TUNDRA =						GameInfoTypes.TERRAIN_TUNDRA
local TERRAIN_DESERT =						GameInfoTypes.TERRAIN_DESERT

local FEATURE_ATOLL =						GameInfoTypes.FEATURE_ATOLL
local FEATURE_ICE =							GameInfoTypes.FEATURE_ICE
local FEATURE_FOREST = 						GameInfoTypes.FEATURE_FOREST
local FEATURE_JUNGLE = 						GameInfoTypes.FEATURE_JUNGLE
local FEATURE_MARSH =	 					GameInfoTypes.FEATURE_MARSH
local FEATURE_BLIGHT =	 					GameInfoTypes.FEATURE_BLIGHT
local FEATURE_FALLOUT =	 					GameInfoTypes.FEATURE_FALLOUT
local FEATURE_CRATER =	 					GameInfoTypes.FEATURE_CRATER		--1st Natural Wonder

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

local TECH_BRONZE_WORKING =					GameInfoTypes.TECH_BRONZE_WORKING
local TECH_IRON_WORKING =					GameInfoTypes.TECH_IRON_WORKING
local TECH_FORESTRY =						GameInfoTypes.TECH_FORESTRY

local POLICY_PANTHEISM =					GameInfoTypes.POLICY_PANTHEISM
local POLICY_FERAL_BOND =					GameInfoTypes.POLICY_FERAL_BOND
local POLICY_COMMUNE_WITH_NATURE =			GameInfoTypes.POLICY_COMMUNE_WITH_NATURE
local POLICY_FOREST_DOMINION =				GameInfoTypes.POLICY_FOREST_DOMINION

local RELIGION_CULT_OF_LEAVES =				GameInfoTypes.RELIGION_CULT_OF_LEAVES
local RELIGION_CULT_OF_PLOUTON =			GameInfoTypes.RELIGION_CULT_OF_PLOUTON
local RELIGION_CULT_OF_CAHRA =				GameInfoTypes.RELIGION_CULT_OF_CAHRA
local RELIGION_CULT_OF_BAKKHEIA =			GameInfoTypes.RELIGION_CULT_OF_BAKKHEIA

local SPREAD_CHANCE_DENOMINATOR = 300 * GAME_SPEED_MULTIPLIER
print("SPREAD_CHANCE_DENOMINATOR = ", SPREAD_CHANCE_DENOMINATOR)

--global tables
local Players =		Players
local Team =		Teams
local gWorld =		gWorld
local gPlayers =	gPlayers
local playerType =	MapModData.playerType
local bHidden =		MapModData.bHidden
local fullCivs =	MapModData.fullCivs
local realCivs =	MapModData.realCivs
local gg_init =						gg_init
local gg_animalSpawnPlots =			gg_animalSpawnPlots
local gg_animalSpawnInhibitTeams =	gg_animalSpawnInhibitTeams
local gg_undeadSpawnPlots =			gg_undeadSpawnPlots
local gg_demonSpawnPlots =			gg_demonSpawnPlots
local gg_playerCityPlotIndexes =	gg_playerCityPlotIndexes
local gg_remoteImprovePlot =		gg_remoteImprovePlot
local gg_cityRemoteImproveCount =	gg_cityRemoteImproveCount
local gg_naturalWonders =			gg_naturalWonders

--localized functions
local Rand = Map.Rand
local PlotDistance = Map.PlotDistance
local GetPlotFromXY = Map.GetPlot
local GetPlotByIndex = Map.GetPlotByIndex
local GetPlotIndexFromXY = GetPlotIndexFromXY
local floor = math.floor
local HandleError41 = HandleError41
local HandleError = HandleError

--file control
local g_bNotVisibleByResourceID = {}
local g_bBlockedByFeatureID = {}
local g_addResource = {}
local g_hasTechBronze = {}
local g_hasTechIron = {}
local g_hasTechForestry = {}
local g_bIsPantheistic = {}
local g_hasFeralBond = {}

local g_wildlandsCountCommuneWithNature = {}
local g_forestDominionPlayers = {}
local g_nonImprovedLivingTerrainStr = {}		--index by iPlot, holds str but only for non-improved

--city tables below indexed by city object (clear all after use)
local g_cityFollowerReligion = {}	
local g_cityUnimprovedForestJungle = {}	--count for Cult of Leaves only
local g_cityDesertCahraFollower = {}	--count for Cult of Cahra only


local integers1 = {}
local integers2 = {}
local g_plotList = {}


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

local livTerTypeByID = {[FEATURE_FOREST]="forest"; [FEATURE_JUNGLE]="jungle"; [FEATURE_MARSH]="marsh"}
local livTerFeatureIDByType = {FEATURE_FOREST, FEATURE_JUNGLE, FEATURE_MARSH}	--1, 2, 3

local blightSafeImprovement = {}
for improvementInfo in GameInfo.Improvements() do
	if improvementInfo.EaBlightSafe then
		blightSafeImprovement[improvementInfo.ID] = true
	end
end

local resourceClass = {}
for resourceInfo in GameInfo.Resources() do
	resourceClass[resourceInfo.ID] = resourceInfo.EaClass
end

--------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------

local function DoLivingTerrainSpread(fromPlot, toPlot, fromType, fromStrength)
	local toType, toPresent, toStrength, toTurnChopped = toPlot:GetLivingTerrainData()
	if toType == -1 or toStrength < 5 then	
		LivingTerrainGrowHere(toPlot:GetPlotIndex(), fromType)
		toPlot:SetLivingTerrainData(fromType, true, 1, -100)
		fromStrength = fromStrength - 1
		fromPlot:SetLivingTerrainData(fromStrength)
		print("Living terrain has spread to an adjacent (non-living or not very strong) tile ", fromPlot:GetPlotIndex(), toPlot:GetPlotIndex())
	else
		--may have conflict between spread type and old (currently absent) type; don't want to kill a stronger terrain that was just chopped, so regrow it as own type
		if fromType == toType or fromStrength < toStrength + 5 then	--re-grow as own type
			LivingTerrainGrowHere(toPlot:GetPlotIndex(), toType)	
			toPlot:SetLivingTerrainData(toType, true, toStrength, toTurnChopped)
			print("Living terrain has re-awakened an adjacent tile: ", fromPlot:GetPlotIndex(), toPlot:GetPlotIndex())
		else	--type must be consistent with current feature or chops get very messy
			LivingTerrainGrowHere(toPlot:GetPlotIndex(), fromType)	
			toPlot:SetLivingTerrainData(fromType, true, toStrength + 1, toTurnChopped)
			fromStrength = fromStrength - 1
			fromPlot:SetLivingTerrainData(fromStrength)
			print("Living terrain has awakened and converted an adjacent (currently absent) living tile ", fromPlot:GetPlotIndex(), toPlot:GetPlotIndex())
			print("Was, ", toType, true, toStrength, toTurnChopped)
			print("Is now: ", fromType, true, toStrength+1, toTurnChopped)
		end
	end
	return fromStrength
end

local function DoLivingTerrainSpreadOrStrengthTransfer(plot, type, strength)
	print("Living Terrain wants to spread; iPlot, type, strength ", iPlot, type, strength)
	for adjPlot in AdjacentPlotIterator(plot, true) do	--randomized order
		if not adjPlot:IsCity() and adjPlot:GetImprovementType() == -1 then
			local adjPlotTypeID = adjPlot:GetPlotType()
			if adjPlotTypeID == PLOT_LAND or adjPlotTypeID == PLOT_HILLS then
				local adjFeatureID = adjPlot:GetFeatureType()
				if adjFeatureID == -1 then									--may grow new feature if plot is suitable
					local adjTerrainType = adjPlot:GetTerrainType()
					if (type == 1 and (adjTerrainType == TERRAIN_GRASS or adjTerrainType == TERRAIN_PLAINS or adjTerrainType == TERRAIN_TUNDRA))
								or (type == 2 and adjTerrainType == TERRAIN_GRASS)
								or (type == 3 and adjTerrainType == TERRAIN_GRASS and adjPlotTypeID == PLOT_LAND) then
						strength = DoLivingTerrainSpread(plot, adjPlot, type, strength)
						break
					end	
				elseif livTerFeatureIDByType[type] == adjFeatureID then		--spread some strength
					local transferStrength = 1
					if 5 < strength then
						transferStrength = Rand(floor(strength / 3), "hello") + 1
					end
					strength = strength - transferStrength
					plot:SetLivingTerrainStrength(strength)
					adjPlot:SetLivingTerrainStrength(adjPlot:GetLivingTerrainStrength() + transferStrength)
					print("A living terrain transfered strength", iPlot, adjPlot:GetPlotIndex(), type, transferStrength)
					break
				end
			end
		end
	end
	return strength
end

local function UseAccumulatedLivingTerrainEffects()
	-- strengthen random unimproved Living Terrain for conversion process or other accumulated effects (this is behind conversion accumulation by 1 turn and for new growth by 2 but doesn't matter)
	local strengthPoints = floor(gWorld.livingTerrainConvertStr)
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

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaPlotsInit(bNewGame)
	print("Running EaPlotsInit...")
	--new map stuff
	if bNewGame then 
		local GetPlotByIndex = GetPlotByIndex
		local PlotDistance = Map.PlotDistance

		local livingTerrainTypes = {[GameInfoTypes.FEATURE_FOREST] = 1,	--"forest",
									[GameInfoTypes.FEATURE_JUNGLE] = 2,	--"jungle",
									[GameInfoTypes.FEATURE_MARSH] = 3	}	--"marsh"

		local validForestJunglePlots = 0
		local originalForestJunglePlots = 0
		local ownablePlots = 0
		for iPlot = 0, Map.GetNumPlots() - 1 do
			local plot = GetPlotByIndex(iPlot)
			local plotTypeID = plot:GetPlotType()
			local terrainID = plot:GetTerrainType()
			local featureID = plot:GetFeatureType()
			local resourceID = plot:GetResourceType(-1)
			local livingTerrainType = livingTerrainTypes[featureID]
			if livingTerrainType then
				local strength = Map.Rand(4, "Terrain Strength")	--give living terrain a random strength from 0 to 3
				plot:SetLivingTerrainData(livingTerrainType, true, strength, -100)	-- -100 chop turn means never
			end

			if plotTypeID ~= PlotTypes.PLOT_MOUNTAIN then
				if resourceID ~= -1 or not plot:IsWater() or plot:IsLake() then
					ownablePlots = ownablePlots + 1
				end
				if terrainID == TERRAIN_GRASS or terrainID == TERRAIN_PLAINS or terrainID == TERRAIN_TUNDRA then
					validForestJunglePlots = validForestJunglePlots + 1
					if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE then
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
					local distance = PlotDistance(x, y, startX, startY)
					local plot = GetPlotFromXY(x, y)
					local featureID = plot:GetFeatureType()
					if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE or featureID == FEATURE_MARSH then
						if distance < 2 then
							plot:SetFeatureType(-1)
							plot:SetLivingTerrainData(-1, false, 0, -100)	--never existed
						else
							plot:SetLivingTerrainStrength(0)					
						end
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
		gg_cityRemoteImproveCount[iPlayer] = {}
	end

	--all plots cycle (new or loaded)

	local totalLivingTerrainStrength = 0
	local harmonicMeanDenominator = 0
	--local lakeCounter, fishingCounter, whaleCounter, campCounter = 0, 0, 0, 0
	for iPlot = 0, Map.GetNumPlots() - 1 do
		local x, y = GetXYFromPlotIndex(iPlot)
		local plot = GetPlotByIndex(iPlot)
		local plotTypeID = plot:GetPlotType()
		local terrainID = plot:GetTerrainType()
		local resourceID = plot:GetResourceType(-1)
		local featureID = plot:GetFeatureType()
		local improvementID = plot:GetImprovementType()
		local type, present, strength, turnChopped = plot:GetLivingTerrainData()
		--remote resource/improvement tracking
		if resourceID ~= -1 then
			if resourceID == RESOURCE_WHALE then
				gg_remoteImprovePlot[iPlot] = "WhalingRes"
			elseif resourceID == RESOURCE_FISH or resourceID == RESOURCE_CRAB or resourceID == RESOURCE_PEARLS then
				gg_remoteImprovePlot[iPlot] = "FishingRes"
			elseif resourceID == RESOURCE_DEER or resourceID == RESOURCE_BOARS or resourceID == RESOURCE_FUR or resourceID == RESOURCE_ELEPHANT then
				gg_remoteImprovePlot[iPlot] = "HuntingRes"
			end
		end
		if plot:IsLake() then
			gg_remoteImprovePlot[iPlot] = "Lake"
		end
		--tracking for strength conversion
		local featureID = plot:GetFeatureType()
		if livTerTypeByID[featureID] and improvementID == -1 then
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
		totalLivingTerrainStrength = totalLivingTerrainStrength + (improvementID == -1 and strength or strength/3)
		if plotTypeID ~= PlotTypes.PLOT_MOUNTAIN and (terrainID == TERRAIN_GRASS or terrainID == TERRAIN_PLAINS or terrainID == TERRAIN_TUNDRA) then
			harmonicMeanDenominator = harmonicMeanDenominator + (livTerTypeByID[featureID] and 1/(strength + 2) or 1)
		end
	end
	
	MapModData.totalLivingTerrainStrength = floor(totalLivingTerrainStrength)
	MapModData.harmonicMeanDenominator = harmonicMeanDenominator
	--print("Lakes, FishingResources, Whales, CampResources ", lakeCounter, fishingCounter, whaleCounter, campCounter)
end

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

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

function GetPlotForSpawn(focalPlot, iPlayer, maxRange, bExcludeFocalPlot, bIgnoreOwn1UPT, bWaterSpawn, bAllowMountain, bRandomize, bIgnoreOpenBorders, ignoreUnit)
	-- use maxRange = 0 if you just want a "safety test" for focal plot
	print("GetPlotForSpawn ", focalPlot, iPlayer, maxRange, bExcludeFocalPlot, bIgnoreOwn1UPT, bWaterSpawn, bAllowMountain, bRandomize, bIgnoreOpenBorders, ignoreUnit)

	maxRange = maxRange or 1
	local player, team
	if not bIgnoreOpenBorders then
		player = Players[iPlayer]
		team = Teams[player:GetTeam()]
	end

	if not bExcludeFocalPlot and (bWaterSpawn == nil or bWaterSpawn == focalPlot:IsWater()) and (not focalPlot:IsCity() or focalPlot:GetOwner() == iPlayer) and (bAllowMountain or not focalPlot:IsMountain()) and not focalPlot:IsImpassable() then
		local bAllow = true
		if not bIgnoreOpenBorders then
			local iPlotOwner = focalPlot:GetOwner()
			if iPlotOwner ~= -1 and iPlotOwner ~= iPlayer and fullCivs[iPlotOwner] and not player:IsPlayerHasOpenBorders(iPlotOwner) and not team:IsAtWar(Players[iPlotOwner]:GetTeam()) then
				bAllow = false		
			end		
		end
		if bAllow then
			local unitCount = focalPlot:GetNumUnits()
			local bAllow = true
			for i = 0, unitCount - 1 do
				local unit = focalPlot:GetUnit(i)
				if unit ~= ignoreUnit and (unit:GetOwner() ~= iPlayer or (not bIgnoreOwn1UPT and unit:IsCombatUnit() and not unit:IsGreatPerson())) then
					bAllow = false
					break
				end
			end	
			if bAllow then
				print(" -returning focal plot")
				return focalPlot
			end
		end
	end

	--need for speed (special case adjacent iterator is faster)
	if maxRange == 1 and not bRandomize then
		for testPlot in AdjacentPlotIterator(focalPlot) do
			if (bWaterSpawn == nil or bWaterSpawn == testPlot:IsWater()) and (not testPlot:IsCity() or testPlot:GetOwner() == iPlayer) and (bAllowMountain or not testPlot:IsMountain()) and not testPlot:IsImpassable() then
				local bAllow = true
				if not bIgnoreOpenBorders then
					local iPlotOwner = testPlot:GetOwner()
					if iPlotOwner ~= -1 and iPlotOwner ~= iPlayer and fullCivs[iPlotOwner] and not player:IsPlayerHasOpenBorders(iPlotOwner) and not team:IsAtWar(Players[iPlotOwner]:GetTeam()) then
						bAllow = false		
					end		
				end
				if bAllow then
					local unitCount = testPlot:GetNumUnits()
					local bAllow = true
					for i = 0, unitCount - 1 do
						local unit = testPlot:GetUnit(i)
						if unit ~= ignoreUnit and (unit:GetOwner() ~= iPlayer or (not bIgnoreOwn1UPT and unit:IsCombatUnit() and not unit:IsGreatPerson())) then
							bAllow = false
							break
						end
					end	
					if bAllow then
						print(" -returning plot at range 1")
						return testPlot
					end
				end
			end			
		end
		return
	end

	if 0 < maxRange then
		local sector = bRandomize and Rand(6, "hello") + 1 or 1
		for radius = 1, maxRange do
			for testPlot in PlotRingIterator(focalPlot, radius, sector, false) do
				if (bWaterSpawn == nil or bWaterSpawn == testPlot:IsWater()) and (not testPlot:IsCity() or testPlot:GetOwner() == iPlayer) and (bAllowMountain or not testPlot:IsMountain()) and not testPlot:IsImpassable() then
					local bAllow = true
					if not bIgnoreOpenBorders then
						local iPlotOwner = testPlot:GetOwner()
						if iPlotOwner ~= -1 and iPlotOwner ~= iPlayer and fullCivs[iPlotOwner] and not player:IsPlayerHasOpenBorders(iPlotOwner) and not team:IsAtWar(Players[iPlotOwner]:GetTeam()) then
							bAllow = false		
						end		
					end
					if bAllow then
						local unitCount = testPlot:GetNumUnits()
						local bAllow = true
						for i = 0, unitCount - 1 do
							local unit = testPlot:GetUnit(i)
							if unit ~= ignoreUnit and (unit:GetOwner() ~= iPlayer or (not bIgnoreOwn1UPT and unit:IsCombatUnit() and not unit:IsGreatPerson())) then
								bAllow = false
								break
							end
						end	
						if bAllow then
							print(" -returning plot at range: ", radius)
							return testPlot
						end
					end
				end			
			end
		end
	end
	--returns nil if no qualified plot
end

function BlightPlot(plot, iPlayer, iPerson, strength, bTestCanCast)		--last 4 are optional
	print("BlightPlot ", plot, iPlayer, iPerson, strength, bTestCanCast)
	local featureID = plot:GetFeatureType()
	if featureID == FEATURE_BLIGHT or featureID == FEATURE_FALLOUT or featureID >= FEATURE_CRATER or plot:IsCity() then return false end
	if plot:IsWater() and featureID ~= FEATURE_ATOLL and not plot:IsLake() and plot:GetResourceType(-1) == -1 and not plot:IsAdjacentToLand() then return false end

	if bTestCanCast then return true end

	--if no strength supplied then this is a spread; give it a random strength
	strength = strength or Rand(20, "hello") + 1

	local manaConsumed = 20		--minimum

	--protected by living terrain?
	local livingTerrainStrength = plot:GetLivingTerrainStrength()
	if livingTerrainStrength > 0 then
		if strength < livingTerrainStrength then
			plot:SetLivingTerrainStrength(livingTerrainStrength - strength)
			plot:AddFloatUpMessage(Locale.Lookup("TXT_KEY_EA_PLOT_PROTECTED_BY_LIVING_TERRAIN"))
			return false
		else
			plot:SetLivingTerrainStrength(0)
			strength = strength - livingTerrainStrength
			manaConsumed = manaConsumed + livingTerrainStrength
		end
	end

	--protected by ward?
	local effectID, effectStength, iEffectPlayer, iEffectCaster = plot:GetPlotEffectData()
	if effectID == EA_PLOTEFFECT_PROTECTIVE_WARD then
		if strength < effectStength then
			plot:SetPlotEffectData(effectID, effectStength - strength, iEffectPlayer, iEffectCaster)
			plot:AddFloatUpMessage(Locale.Lookup("TXT_KEY_EA_PLOT_PROTECTED_BY_WARD"))
			return false
		else
			plot:SetPlotEffectData(-1,-1,-1,-1)
			strength = strength - effectStength
			manaConsumed = manaConsumed + effectStength
		end
	end	

	--OK to Blight!
	local improvementID = plot:GetImprovementType()
	local resourceID = plot:GetResourceType(-1)

	if improvementID ~= IMPROVEMENT_BLIGHT and resourceID ~= RESOURCE_BLIGHT then
		if improvementID == -1 or not blightSafeImprovement[improvementID] then
			plot:SetImprovementType(IMPROVEMENT_BLIGHT)
		else
			if resourceID ~= -1 then
				ChangeResource(plot, -1)
			end
			ChangeResource(plot, RESOURCE_BLIGHT, 1)
		end
	end

	local player = iPlayer and Players[iPlayer]
	if player and player:IsAlive() then		
		UseManaOrDivineFavor(iPlayer, iPerson, manaConsumed, false)
	else
		gWorld.sumOfAllMana = gWorld.sumOfAllMana - manaConsumed
		plot:AddFloatUpMessage(Locale.Lookup("TXT_KEY_EA_CONSUMED_MANA", manaConsumed), 1)
	end

	print("Blighting iPlot ", plot:GetPlotIndex())
	plot:SetFeatureType(FEATURE_BLIGHT)
	return true
end

function BreachPlot(plot, iPlayer, iPerson, strength, bTestCanBreach)		--last 4 are optional
	print("BreachPlot ", plot, iPlayer, iPerson, strength, bTestCanBreach)
	if plot:IsWater() or plot:IsMountain() or plot:IsCity() then return false end
	local featureID = plot:GetFeatureType()
	if featureID == FEATURE_FALLOUT or featureID >= FEATURE_CRATER then return false end
	local improvementID = plot:GetImprovementType()
	if blightSafeImprovement[improvementID] then return false end		--saves us trouble for now

	--breach spreads in fault-like pattern; doesn't want 2 adjacent
	local bOneAdj = false
	for testPlot in AdjacentPlotIterator(plot) do
		if testPlot:GetFeatureType() == FEATURE_FALLOUT then
			if bOneAdj then return false end
			bOneAdj = true
		end
	end

	--if no strength supplied then this is a spread; give it a random strength
	strength = strength or Rand(40, "hello") + 1

	local manaConsumed = 100		--minimum

	--protected by living terrain?
	local livingTerrainStrength = plot:GetLivingTerrainStrength()
	if livingTerrainStrength > 0 then
		if strength < livingTerrainStrength then
			if not bTestCanBreach then
				plot:SetLivingTerrainStrength(livingTerrainStrength - strength)
				plot:AddFloatUpMessage(Locale.Lookup("TXT_KEY_EA_PLOT_PROTECTED_BY_LIVING_TERRAIN"))
			end
			return false
		else
			if not bTestCanBreach then
				plot:SetLivingTerrainStrength(0)
			end
			strength = strength - livingTerrainStrength
			manaConsumed = manaConsumed + livingTerrainStrength
		end
	end

	--protected by ward?
	local effectID, effectStength, iEffectPlayer, iEffectCaster = plot:GetPlotEffectData()
	if effectID == EA_PLOTEFFECT_PROTECTIVE_WARD then
		if strength < effectStength then
			if not bTestCanBreach then
				plot:SetPlotEffectData(effectID, effectStength - strength, iEffectPlayer, iEffectCaster)
				plot:AddFloatUpMessage(Locale.Lookup("TXT_KEY_EA_PLOT_PROTECTED_BY_WARD"))
			end
			return false
		else
			if not bTestCanBreach then
				plot:SetPlotEffectData(-1,-1,-1,-1)
				strength = strength - effectStength
				manaConsumed = manaConsumed + effectStength
			end
		end
	end

	if bTestCanBreach then return true end

	--OK to Breach!
	plot:SetImprovementType(-1)

	local resourceID = plot:GetResourceType(-1)
	if resourceID ~= RESOURCE_BLIGHT then
		if resourceID ~= -1 then
			ChangeResource(plot, -1, nil)
		end
		ChangeResource(plot, RESOURCE_BLIGHT, 1)
	end

	local player = iPlayer and Players[iPlayer]

	if player and player:IsAlive() then
		UseManaOrDivineFavor(iPlayer, iPerson, manaConsumed, false)
	else
		gWorld.sumOfAllMana = gWorld.sumOfAllMana - manaConsumed
		plot:AddFloatUpMessage(Locale.Lookup("TXT_KEY_EA_CONSUMED_MANA", manaConsumed), 1)
	end

	print("Breaching iPlot ", plot:GetPlotIndex())
	plot:SetFeatureType(FEATURE_FALLOUT)
	plot:SetPlotEffectData(-1,-1,-1,-1)	--just cancel out any spell effects

	--blight plots out to 3 radius
	for radius = 1, 2 do
		for loopPlot in PlotRingIterator(plot, radius, 1, false) do
			if radius < 2 or Rand(2, "hello") < 1 then
				BlightPlot(loopPlot, nil, nil, (3 - radius) * (Rand(5, "hello") + 5))	--strength is 10-20 (radius 1) to 5-10 (radius 2)
			end
		end
	end
	return true
end

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
			plotScore = plotScore + 3 - PlotDistance(x, y, cityX, cityY)	--closer to city, all else equal
			for i = 1, numSameResource do
				local dist = PlotDistance(x, y, integers1[i], integers2[i])
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
	local oldResourceID = plot:GetResourceType(-1)
	if oldResourceID ~= -1 and resourceID ~= -1 and oldResourceID ~= resourceID then
		ChangeResource(plot, -1)
		oldResourceID = -1
	end
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

		local iOwningCity = plot:GetCityPurchaseID()

		plot:SetOwner(-1)

		if resourceID == -1 then
			plot:SetResourceType(-1)
			LuaEvents.SerialEventRawResourceIconDestroyed(plot:GetX(), plot:GetY())
		else
			plot:SetResourceType(resourceID, number)
		end

		plot:SetOwner(iOwner, iOwningCity)

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
	
	--update mod resource plot tables
	if resourceID ~= oldResourceID then
		if resourceID == RESOURCE_DEER or resourceID == RESOURCE_BOARS or resourceID == RESOURCE_FUR or resourceID == RESOURCE_ELEPHANT then
			gg_remoteImprovePlot[plot:GetPlotIndex()] = "HuntingRes"
		elseif oldResourceID == RESOURCE_DEER or oldResourceID == RESOURCE_BOARS or oldResourceID == RESOURCE_FUR or oldResourceID == RESOURCE_ELEPHANT then
			gg_remoteImprovePlot[plot:GetPlotIndex()] = nil
		elseif resourceID == RESOURCE_FISH or resourceID == RESOURCE_CRAB or resourceID == RESOURCE_PEARLS then
			gg_remoteImprovePlot[plot:GetPlotIndex()] = "FishingRes"
		elseif oldResourceID == RESOURCE_FISH or oldResourceID == RESOURCE_CRAB or oldResourceID == RESOURCE_PEARLS then
			gg_remoteImprovePlot[plot:GetPlotIndex()] = nil
		elseif resourceID == RESOURCE_WHALE then
			gg_remoteImprovePlot[plot:GetPlotIndex()] = "WhalingRes"
		elseif oldResourceID == RESOURCE_WHALE then
			gg_remoteImprovePlot[plot:GetPlotIndex()] = nil
		end
	end
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

--------------------------------------------------------------
-- PlotsPerTurn and supporting local per turn functions
--------------------------------------------------------------

local function GetArmageddonPlotStats()
	local armageddonStage = gWorld.armageddonStage
	local manaDepletion = 1 - (gWorld.sumOfAllMana / MapModData.STARTING_SUM_OF_ALL_MANA)
	local blightBreachSpread = 0
	local blightSpawn = 0
	local breachSpawn = 0
	if 10 < armageddonStage then
		blightBreachSpread = 100 * manaDepletion 
		blightSpawn = 10 * (manaDepletion - 0.6667) + 2.5	--2.5% to 10%
		breachSpawn = 2 * blightSpawn						--20% (but only qualified plots)
	elseif 5 < armageddonStage then
		blightBreachSpread = 30 * manaDepletion
		blightSpawn = 10 * (manaDepletion - 0.6667) + 2.5	--2.5% to 10%
	elseif 3 < armageddonStage then
		blightBreachSpread = 30 * manaDepletion 
	end
	print("blightBreachSpread, blightSpawn, breachSpawn = ", blightBreachSpread, blightSpawn, breachSpawn)
	return blightBreachSpread, blightSpawn, breachSpawn
end

local function DoVariousPlotUpdates()
	local totalUnimprovedForestJungle = 0
	for city, unimprovedForestJungle in pairs(g_cityUnimprovedForestJungle) do
		local eaCity = gCities[city:Plot():GetPlotIndex()]
		eaCity.unimprovedForestJungle = unimprovedForestJungle
		totalUnimprovedForestJungle = totalUnimprovedForestJungle + unimprovedForestJungle
		g_cityUnimprovedForestJungle[city] = nil		--recycle table
	end
	local totalDesertCahraFollower = 0
	for city, desertCahraFollower in pairs(g_cityDesertCahraFollower) do
		local eaCity = gCities[city:Plot():GetPlotIndex()]
		eaCity.desertCahraFollower = desertCahraFollower
		totalDesertCahraFollower = totalDesertCahraFollower + desertCahraFollower
		g_cityDesertCahraFollower[city] = nil		--recycle table
	end

	local iCultOfLeavesFounder = gReligions[RELIGION_CULT_OF_LEAVES] and gReligions[RELIGION_CULT_OF_LEAVES].founder
	local iCultOfCahraFounder = gReligions[RELIGION_CULT_OF_CAHRA] and gReligions[RELIGION_CULT_OF_CAHRA].founder

	for iPlayer, eaPlayer in pairs(realCivs) do
		local player = Players[iPlayer]
		for resourceID, number in pairs(g_addResource[iPlayer]) do
			number = floor(number)
			local change = number - (eaPlayer.addedResources[resourceID] or 0)
			if change ~= 0 then
				player:ChangeNumResourceTotal(resourceID, change)
				eaPlayer.addedResources[resourceID] = number
			end
		end
		if iPlayer == iCultOfLeavesFounder then
			eaPlayer.manaForCultOfLeavesFounder = floor(totalUnimprovedForestJungle / 10)
		end
		if iPlayer == iCultOfCahraFounder then
			eaPlayer.manaForCultOfCahraFounder = floor(totalDesertCahraFollower / 10)
		end
		if g_wildlandsCountCommuneWithNature[iPlayer] then
			eaPlayer.cultureManaFromWildlands = floor(g_wildlandsCountCommuneWithNature[iPlayer] / 4)
		end

	end
end



function PlotsPerTurn()
	--This function is really pushing the 60 upvalue limit, but it is also one we want to run very fast
	--Watch for "Syntax Error: function at line xxx has more than 60 upvalues" when adding stuff

	print("Running PlotsPerTurn")
	local PlotToRadiusIterator = PlotToRadiusIterator
	local encampments = gWorld.encampments
	local gameTurn = Game.GetGameTurn()

	ResetTablesForPlotLoop()

	local numForestDominionPlayers = #g_forestDominionPlayers
	local numAnimalSpawnInhibitTeams = #gg_animalSpawnInhibitTeams
	local numAnimalSpawnPlots = 0
	local totalLivingTerrainStrength = 0
	local harmonicMeanDenominator = 0
	local forestPlots = 0
	local junglePlots = 0
	local grapesWorkedByBakkeiaFollower = 0
	local earthResWorkedByPloutonFollower = 0
	gg_undeadSpawnPlots.pos = 0
	gg_demonSpawnPlots.pos = 0

	--undead/demon spawning and breach/blight spread
	local blightBreachSpread, blightSpawn, breachSpawn = GetArmageddonPlotStats()

	--Main plot loop
	for iPlot = 0, Map.GetNumPlots() - 1 do
		local x, y = GetXYFromPlotIndex(iPlot)
		local plot = GetPlotByIndex(iPlot)
		local bIsCity = plot:IsCity()
		local bIsWater = plot:IsWater()
		local bIsImpassable = plot:IsImpassable()

		--be careful to update any below if changed so subsequent operations are acting on correct info
		local type, present, strength, turnChopped = plot:GetLivingTerrainData()
		local plotTypeID = plot:GetPlotType()
		local terrainID = plot:GetTerrainType()
		local featureID = plot:GetFeatureType()
		local improvementID = plot:GetImprovementType()
		local resourceID = plot:GetResourceType(-1)
		local iOwner = plot:GetOwner()

		--Breach/Blight effects
		if featureID == FEATURE_FALLOUT then

			--spread
			if 0 < blightBreachSpread then
				local d100 = Rand(SPREAD_CHANCE_DENOMINATOR, "hello")
				if d100 < blightBreachSpread then
					local spreadPlot = GetRandomAdjacentPlot(plot)
					if spreadPlot then
						BreachPlot(spreadPlot)
					end
					if d100 < blightBreachSpread - 10 then
						--TO DO: jump 10 plots so we can hit islands
					end
				end
			end 
		elseif featureID == FEATURE_BLIGHT then
			if 0 < blightBreachSpread then
				if Rand(SPREAD_CHANCE_DENOMINATOR, "hello") < blightBreachSpread then
					local spreadPlot = GetRandomAdjacentPlot(plot)
					if spreadPlot then
						BlightPlot(spreadPlot)
					end
				end
			end 
		end
		if bIsCity then		--temp until graveyards/battlefields is implemented
			gg_undeadSpawnPlots.pos = gg_undeadSpawnPlots.pos + 1
			gg_undeadSpawnPlots[gg_undeadSpawnPlots.pos] = iPlot
		end

		--Encampments
		if improvementID == IMPROVEMENT_BARBARIAN_CAMP then
			if not encampments[iPlot] then
				InitUpgradeEncampment(iPlot, x, y, plot)	--in EaBarbarians.lua
			end
		else
			encampments[iPlot] = nil
		end

		--Animals
		if not bIsCity and not bIsImpassable and (iOwner == -1 or g_hasFeralBond[iOwner]) and plot:GetNumUnits() == 0 then
			if plotTypeID ~= PlotTypes.PLOT_OCEAN or (iPlot % 7 == 0 and not plot:IsLake()) then	--allow 1/7th of sea plots to be tested
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
		end

		--Simple world-wide counts
		totalLivingTerrainStrength = totalLivingTerrainStrength + (improvementID == -1 and strength or strength/3)
		if plotTypeID ~= PlotTypes.PLOT_MOUNTAIN and (terrainID == TERRAIN_GRASS or terrainID == TERRAIN_PLAINS or terrainID == TERRAIN_TUNDRA) then
			harmonicMeanDenominator = harmonicMeanDenominator + (livTerTypeByID[featureID] and 1/(strength + 2) or 1)
		end
		if plotTypeID ~= PlotTypes.PLOT_MOUNTAIN then
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

		--Living Terrain
		if type ~= -1 then
			if present then							-- was present on last turn
				if featureID == -1 then				-- must have been removed last turn
					if iOwner ~= -1 then			--set turnChopped if forest or jungle owned and owner has chopping tech (used later for timber)
						if bIsCity then		--permanently remove
							type, present, strength, turnChopped = -1, false, 0, -100
							plot:SetLivingTerrainData(type, present, strength, turnChopped)
							print("Living terrain removed for city", iPlot, type, present, strength, turnChopped)
						elseif type == 1 then	-- "forest"	
							present = false
							strength = strength - 1
							turnChopped = g_hasTechBronze[iOwner] and gameTurn or -100
							plot:SetLivingTerrainData(type, present, strength, turnChopped)
							print("A living forest was chopped", iPlot, type, present, strength, turnChopped)
						elseif type == 2 then	--"jungle"
							present = false
							strength = strength - 1
							turnChopped = g_hasTechIron[iOwner] and gameTurn or -100
							plot:SetLivingTerrainData(type, present, strength, turnChopped)
							print("A living jungle was chopped", iPlot, type, present, strength, turnChopped)
						else
							present = false
							strength = strength - 1
							turnChopped = -100
							plot:SetLivingTerrainData(type, present, strength, turnChopped)
							print("A living marsh was removed", iPlot, type, present, strength, turnChopped)
						end
					end

				elseif improvementID == -1 or (improvementID ~= IMPROVEMENT_LUMBERMILL and improvementID ~= IMPROVEMENT_FARM) or plot:IsImprovementPillaged() then	--these suppress living terrain
					if Rand(SPREAD_CHANCE_DENOMINATOR, "living terrain spread") < strength then	  --spread or transfer strength		
						strength = DoLivingTerrainSpreadOrStrengthTransfer(plot, type, strength)
					end
					--Possible take-over by adjacent player with Forest Dominion policy
					if (featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE) and plot:IsAdjacentOwned() then
						if Rand(SPREAD_CHANCE_DENOMINATOR, "hello") < 1 then		-- 1% chance if qualified plot
							local iNewOwner = -1
							for i = 1, numForestDominionPlayers do
								local iFDPlayer = g_forestDominionPlayers[i]
								if iOwner == iFDPlayer then
									iNewOwner = -1			--owner can defend with Forest Dominion
									break
								elseif plot:IsAdjacentPlayer(iFDPlayer, true) then
									iNewOwner = iFDPlayer
								end
							end
							if iNewOwner ~= -1 then
								print("Forest Dominion plot takeover; iPlot/iNewOwner/iOldOwner", iPlot, iNewOwner, iOwner)
								local newOwnerCity = GetNewOwnerCityForPlot(iNewOwner, iPlot)
								if newOwnerCity then
									plot:SetOwner(iNewOwner, newOwnerCity:GetID())
									iOwner = iNewOwner
								end
							end
						end
					end
				end
			else	--currently not present (ie, was remvoed in the past, will it regenerate?)
				if bIsCity then		--permanently remove
					type, present, strength, turnChopped = -1, false, 0, -100
					plot:SetLivingTerrainData(type, present, strength, turnChopped)
					print("Living terrain removed for city", iPlot)
				elseif featureID == -1 and 0 < strength and Rand(SPREAD_CHANCE_DENOMINATOR, "hello") < strength	then	--it's back!
					LivingTerrainGrowHere(iPlot, type)
					present = true
					plot:SetLivingTerrainData(type, present, strength, turnChopped)
					print("Living terrain has regenerated on its own: ", iPlot, type, present, strength, turnChopped)
				end
			end

		end

		--track unimproved living terrain
		featureID = plot:GetFeatureType()		--just reassess after possible changes above
		if livTerTypeByID[featureID] and improvementID == -1 then
			g_nonImprovedLivingTerrainStr[iPlot] = plot:GetLivingTerrainStrength()
		else
			g_nonImprovedLivingTerrainStr[iPlot] = nil
		end

		--improvement and resource counting
		if iOwner ~= -1 then

			local eaOwner = gPlayers[iOwner]
			local owner = Players[iOwner]
			local iOwningCity = plot:GetCityPurchaseID()
			local owningCity = owner:GetCityByID(iOwningCity)
			if owningCity then

				-- plot special used for AI
				local resourceID = plot:GetResourceType(-1)
				if resourceID ~= -1 and not g_bNotVisibleByResourceID[iOwner][resourceID] and not g_bBlockedByFeatureID[iOwner][resourceID] then		--visible test is now useless???
					eaOwner.resourcesInBorders[resourceID] = (eaOwner.resourcesInBorders[resourceID] or 0) + 1
				end
				local bFreshWater = plot:IsFreshWater()
				local plotSpecial
				if plotTypeID == PlotTypes.PLOT_OCEAN then
					if featureID ~= FEATURE_ICE then plotSpecial = "Sea" end
				elseif plotTypeID == PlotTypes.PLOT_MOUNTAIN then
					plotSpecial = "Mountain"
				elseif featureID == FEATURE_FOREST then
					plotSpecial = "Forest"
				elseif featureID == FEATURE_JUNGLE then
					plotSpecial = "Jungle"
				elseif featureID == FEATURE_MARSH then
					plotSpecial = "Marsh"
				elseif featureID == -1 then
					if plotTypeID == PlotTypes.PLOT_HILLS then
						plotSpecial = "Hill"
					elseif bFreshWater and plotTypeID == PlotTypes.PLOT_LAND then
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

				--owning city counts
				if gg_remoteImprovePlot[iPlot] then		--increment count for owning city
					local cityRemoteImproveCount = gg_cityRemoteImproveCount[iOwner][iOwningCity] or InitCityRemoteImproveCount(iOwner, iOwningCity)
					local type = gg_remoteImprovePlot[iPlot]
					cityRemoteImproveCount[type] = cityRemoteImproveCount[type] + 1
				end


				g_cityFollowerReligion[owningCity] = g_cityFollowerReligion[owningCity] or owningCity:GetReligiousMajority()
				if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE then
					--timber and timberyard
					if owningCity:GetNumBuilding(BUILDING_TIMBERYARD) == 1 then
						if improvementID == IMPROVEMENT_LUMBERMILL then
							g_addResource[iOwner][RESOURCE_TIMBER] = (g_addResource[iOwner][RESOURCE_TIMBER] or 0) + (g_hasTechForestry[iOwner] and 1 or 0.5)
						elseif g_bIsPantheistic[iOwner] then
							g_addResource[iOwner][RESOURCE_TIMBER] = (g_addResource[iOwner][RESOURCE_TIMBER] or 0) + (g_hasTechForestry[iOwner] and 0.25 or 0.125)
						end
					else
						owningCity:SetNumRealBuilding(BUILDING_TIMBERYARD_ALLOW, 1)
					end
				end
				if improvementID == IMPROVEMENT_VINEYARD then
					if g_cityFollowerReligion[owningCity] == RELIGION_CULT_OF_BAKKHEIA then
						grapesWorkedByBakkeiaFollower = grapesWorkedByBakkeiaFollower + 1
					end
				end
				if resourceID ~= -1 and resourceClass[resourceID] == "Earth" then
					if g_cityFollowerReligion[owningCity] == RELIGION_CULT_OF_PLOUTON then
						earthResWorkedByPloutonFollower = earthResWorkedByPloutonFollower + 1
					end
				end
			
				--Cult effects for owned plots
				if terrainID == TERRAIN_DESERT then
					g_cityFollowerReligion[owningCity] = g_cityFollowerReligion[owningCity] or owningCity:GetReligiousMajority()
					if g_cityFollowerReligion[owningCity] == RELIGION_CULT_OF_CAHRA then
						g_cityDesertCahraFollower[owningCity] = (g_cityDesertCahraFollower[owningCity] or 0) + 1
					end
				elseif (featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE) and improvementID == -1 then
					g_cityFollowerReligion[owningCity] = g_cityFollowerReligion[owningCity] or owningCity:GetReligiousMajority()
					if g_cityFollowerReligion[owningCity] == RELIGION_CULT_OF_LEAVES then
						g_cityUnimprovedForestJungle[owningCity] = (g_cityUnimprovedForestJungle[owningCity] or 0) + 1
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
						if owningCity:GetNumBuilding(resourceConvert.building) > 0 then
							local newResourceID = resourceConvert.resource
							g_addResource[iOwner][newResourceID] = (g_addResource[iOwner][newResourceID] or 0) + 1
						end
					end				
				end
			else
				print("!!!! ERROR: owned plot appears to have no owning city! ", iOwner, plot:GetOwner())
			end
		end
	end		--end of main plot loop

	-- housekeeping
	gg_animalSpawnPlots.pos = numAnimalSpawnPlots
	MapModData.totalLivingTerrainStrength = floor(totalLivingTerrainStrength)
	MapModData.harmonicMeanDenominator = harmonicMeanDenominator

	gg_counts.grapeAndSpiritsBuildingsBakkheiaFollowerCities = gg_counts.grapeAndSpiritsBuildingsBakkheiaFollowerCities + grapesWorkedByBakkeiaFollower
	gg_counts.earthResWorkedByPloutonFollower = earthResWorkedByPloutonFollower

	DoVariousPlotUpdates()

	--recycle table
	for city in pairs(g_cityFollowerReligion) do
		g_cityFollowerReligion[city] = nil
	end

	UseAccumulatedLivingTerrainEffects()
end


--------------------------------------------------------------
-- GameEvents
--------------------------------------------------------------

local function OnCityCanAcquirePlot(iPlayer, iCity, x, y)
	--print("OnCityCanAcquirePlot ", iPlayer, iCity, x, y)
	local plot = GetPlotFromXY(x, y)
	local featureID = plot:GetFeatureType()
	if featureID ~= -1 and featureID ~= FEATURE_ICE and featureID ~= FEATURE_BLIGHT and featureID ~= FEATURE_FALLOUT then return true end	--atoll or any natural wonder is OK for border spread
	if plot:IsWater() then
		if plot:GetResourceType(-1) ~= -1 then return true end	--any resource is ownable (all are visible for now; otherwise we'll need iTeam)
		return false
	end
	if plot:IsMountain() then return false end
	return true
end
GameEvents.CityCanAcquirePlot.Add(OnCityCanAcquirePlot)

function ListenerSerialEventHexCultureChanged(hexX, hexY, iPlayer, bUnknown)	--fires for all owned plots at game init too
	if gg_init.bEnteredGame and iPlayer ~= -1 then
		--print(string.format("Hex ownership change at hex coordinates: %d, %d for player: %d", hexX, hexY, iPlayer))

		--Use this Events to make sure certain resources are owned by nearby city (if exists) rather than same-civ remote city; timing is not critical
	
		local x, y = ToGridFromHex( hexX, hexY )
		local iPlot = GetPlotIndexFromXY(x, y)

		if gg_remoteImprovePlot[iPlot] then
			local plot = GetPlotFromXY(x, y)
			--debug
			if plot:GetOwner() ~= iPlayer then
				error("plot:GetOwner() ~= iPlayer for SerialEventHexCultureChanged")
			end

			if plot:IsPlayerCityRadius(iPlayer) then
				local iOwningCity = plot:GetCityPurchaseID()
				local iPlotOwningCity = gg_playerCityPlotIndexes[iPlayer][iOwningCity]
				if not iPlotOwningCity then
					iPlotOwningCity = Players[iPlayer]:GetCityByID(iOwningCity):Plot():GetPlotIndex()
					gg_playerCityPlotIndexes[iPlayer][iOwningCity] = iPlotOwningCity
				end						
				local ownerDist = GetMemoizedPlotIndexDistance(iPlot, iPlotOwningCity)
				if 3 < ownerDist then	--it's close to a player city, but not the owning city; find closest and tranfer ownership
					for loopPlot in PlotAreaSpiralIterator(plot, 3, 1, false, false, false) do
						local city = loopPlot:GetPlotCity()
						if city and city:GetOwner() == iPlayer then
							print("SerialEventHexCultureChanged: Resource plot ownership being tranfered from remote city to nearby city")
							plot:SetOwner(iPlayer, city:GetID())
							break
						end
					end
				else
					print("SerialEventHexCultureChanged: Resource plot ownership verified to be for nearby city")
				end
			else
				print("SerialEventHexCultureChanged: Resource plot ownership by remote city; no nearby city for same player")
			end
		end
	end
end
Events.SerialEventHexCultureChanged.Add(ListenerSerialEventHexCultureChanged)


local function OnBuildFinished(iPlayer, x, y, improvementID)		--improvementID for newly built only (e.g., -1 if this is a repair)
	print("OnBuildFinished ", iPlayer, x, y, improvementID)
	if improvementID == -1 then
		local plot = GetPlotFromXY(x, y)
		if plot:GetResourceType(-1) == RESOURCE_BLIGHT then
			print("Worker must have removed FEATURE_BLIGHT; now removing RESOURCE_BLIGHT")
			ChangeResource(plot, -1)
		end
		local currentImprovementID = plot:GetImprovementType()
		if currentImprovementID ~= -1 then
			if currentImprovementID == IMPROVEMENT_BLIGHT then
				print("Worker must have removed FEATURE_BLIGHT; now removing IMPROVEMENT_BLIGHT")
				plot:SetImprovementType(-1)
			else
				CheckUpdatePlotWonder(iPlayer, currentImprovementID)	--could be a repair
			end
		end
	end
end
GameEvents.BuildFinished.Add(function(iPlayer, x, y, improvementID) return HandleError41(OnBuildFinished, iPlayer, x, y, improvementID) end)




