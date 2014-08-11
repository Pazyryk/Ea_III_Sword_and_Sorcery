-- Cities
-- Author: Pazyryk
-- DateCreated: 6/28/2012 10:33:00 AM
--------------------------------------------------------------

print("Loading EaCities.lua...")
local print = ENABLE_PRINT and print or function() end

--------------------------------------------------------------
-- Settings
--------------------------------------------------------------

local MANA_CONSUMED_PER_ANRA_FOLLOWER_PER_TURN =	MapModData.EaSettings.MANA_CONSUMED_PER_ANRA_FOLLOWER_PER_TURN
local RACE_HATRED_FOR_RAZED_POP =					MapModData.EaSettings.RACE_HATRED_FOR_RAZED_POP		--eg, 0.5 for standard/standard

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

--constants				
local HIGHEST_RELIGION_ID =					HIGHEST_RELIGION_ID

local DOMAIN_LAND =							DomainTypes.DOMAIN_LAND
local DOMAIN_SEA =							DomainTypes.DOMAIN_SEA
local ORDER_MAINTAIN =						OrderTypes.ORDER_MAINTAIN
local ORDER_TRAIN =							OrderTypes.ORDER_TRAIN

local EACIV_GAZIYA =						GameInfoTypes.EACIV_GAZIYA

local EARACE_MAN =							GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =						GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =					GameInfoTypes.EARACE_HELDEOFOL
local SPECIALIST_SMITH =					GameInfoTypes.SPECIALIST_SMITH
local SPECIALIST_TRADER =					GameInfoTypes.SPECIALIST_TRADER
local SPECIALIST_SCRIBE =					GameInfoTypes.SPECIALIST_SCRIBE
local SPECIALIST_ARTISAN =					GameInfoTypes.SPECIALIST_ARTISAN
local SPECIALIST_DISCIPLE =					GameInfoTypes.SPECIALIST_DISCIPLE
local SPECIALIST_ADEPT =					GameInfoTypes.SPECIALIST_ADEPT
local BUILDING_MAN =						GameInfoTypes.BUILDING_MAN
local BUILDING_SIDHE =						GameInfoTypes.BUILDING_SIDHE
local BUILDING_HELDEOFOL =					GameInfoTypes.BUILDING_HELDEOFOL
local BUILDING_WINDMILL =					GameInfoTypes.BUILDING_WINDMILL
local BUILDING_WINDMILL_ALLOW =				GameInfoTypes.BUILDING_WINDMILL_ALLOW
local BUILDING_RACIAL_DISHARMONY =			GameInfoTypes.BUILDING_RACIAL_DISHARMONY
local BUILDING_FOREFATHERS_STATUE =			GameInfoTypes.BUILDING_FOREFATHERS_STATUE
local BUILDING_SLAVE_BREEDING_PEN =			GameInfoTypes.BUILDING_SLAVE_BREEDING_PEN
local BUILDING_HARBOR =						GameInfoTypes.BUILDING_HARBOR
local BUILDING_SMOKEHOUSE =					GameInfoTypes.BUILDING_SMOKEHOUSE
local BUILDING_WINERY =						GameInfoTypes.BUILDING_WINERY
local BUILDING_BREWERY =					GameInfoTypes.BUILDING_BREWERY
local BUILDING_DISTILLERY =					GameInfoTypes.BUILDING_DISTILLERY
local BUILDING_RIVER_DOCK =					GameInfoTypes.BUILDING_RIVER_DOCK
local BUILDING_CULT_LEAVES_1F1C =			GameInfoTypes.BUILDING_CULT_LEAVES_1F1C
local BUILDING_CULT_CAHRA_1F =				GameInfoTypes.BUILDING_CULT_CAHRA_1F

local PROCESS_WORLD_WEAVE =					GameInfoTypes.PROCESS_WORLD_WEAVE
local PROCESS_WORLD_SALVATION =				GameInfoTypes.PROCESS_WORLD_SALVATION
local PROCESS_WORLD_CORRUPTION =			GameInfoTypes.PROCESS_WORLD_CORRUPTION

local PROCESS_EA_BLESSINGS =				GameInfoTypes.PROCESS_EA_BLESSINGS
local PROCESS_MAJOR_SPIRITS_TRIBUTE =		GameInfoTypes.PROCESS_MAJOR_SPIRITS_TRIBUTE
local PROCESS_FAERIES_TRIBUTE =				GameInfoTypes.PROCESS_FAERIES_TRIBUTE
local PROCESS_WORLD_SALVATION =				GameInfoTypes.PROCESS_WORLD_SALVATION
local PROCESS_WORLD_CORRUPTION =			GameInfoTypes.PROCESS_WORLD_CORRUPTION
local PROCESS_OPPRESSION =					GameInfoTypes.PROCESS_OPPRESSION
local PROCESS_TRAINING_EXERCISES =			GameInfoTypes.PROCESS_TRAINING_EXERCISES
local PROCESS_THE_ARTS =					GameInfoTypes.PROCESS_THE_ARTS
local PROCESS_PATRONAGE =					GameInfoTypes.PROCESS_PATRONAGE

local FEATURE_FOREST = 						GameInfoTypes.FEATURE_FOREST
local FEATURE_JUNGLE = 						GameInfoTypes.FEATURE_JUNGLE
local FEATURE_MARSH =	 					GameInfoTypes.FEATURE_MARSH
local RESOURCE_DEER =						GameInfoTypes.RESOURCE_DEER
local RESOURCE_BOARS =						GameInfoTypes.RESOURCE_BOARS
local RESOURCE_FUR =						GameInfoTypes.RESOURCE_FUR
local RESOURCE_ELEPHANT =					GameInfoTypes.RESOURCE_ELEPHANT
local RESOURCE_FISH =						GameInfoTypes.RESOURCE_FISH
local RESOURCE_CRAB =						GameInfoTypes.RESOURCE_CRAB
local RESOURCE_PEARLS =						GameInfoTypes.RESOURCE_PEARLS
local RESOURCE_WHALE =						GameInfoTypes.RESOURCE_WHALE
local RESOURCE_HORSE =						GameInfoTypes.RESOURCE_HORSE
local RESOURCE_WINE =						GameInfoTypes.RESOURCE_WINE
local IMPROVEMENT_CAMP =					GameInfoTypes.IMPROVEMENT_CAMP
local IMPROVEMENT_FISHING_BOATS =			GameInfoTypes.IMPROVEMENT_FISHING_BOATS
local IMPROVEMENT_WHALING_BOATS =			GameInfoTypes.IMPROVEMENT_WHALING_BOATS
local TERRAIN_GRASS =						GameInfoTypes.TERRAIN_GRASS
local TERRAIN_PLAINS =						GameInfoTypes.TERRAIN_PLAINS
local TERRAIN_DESERT =						GameInfoTypes.TERRAIN_DESERT

local UNIT_FISHING_BOATS =					GameInfoTypes.UNIT_FISHING_BOATS
local UNIT_WHALING_BOATS =					GameInfoTypes.UNIT_WHALING_BOATS
local UNIT_HUNTERS =						GameInfoTypes.UNIT_HUNTERS
local UNIT_SETTLERS_MAN =					GameInfoTypes.UNIT_SETTLERS_MAN
local UNIT_SETTLERS_SIDHE =					GameInfoTypes.UNIT_SETTLERS_SIDHE
local UNIT_SETTLERS_ORC =					GameInfoTypes.UNIT_SETTLERS_ORC
local UNIT_SLAVES_MAN =						GameInfoTypes.UNIT_SLAVES_MAN
local UNIT_SLAVES_SIDHE =					GameInfoTypes.UNIT_SLAVES_SIDHE
local UNIT_SLAVES_ORC =						GameInfoTypes.UNIT_SLAVES_ORC
--local UNIT_CARAVAN =						GameInfoTypes.UNIT_CARAVAN
--local UNIT_CARGO_SHIP =						GameInfoTypes.UNIT_CARGO_SHIP

local RELIGION_ANRA =						GameInfoTypes.RELIGION_ANRA
local RELIGION_THE_WEAVE_OF_EA =			GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
local RELIGION_CULT_OF_LEAVES =				GameInfoTypes.RELIGION_CULT_OF_LEAVES
local RELIGION_CULT_OF_ABZU =				GameInfoTypes.RELIGION_CULT_OF_ABZU
local RELIGION_CULT_OF_AEGIR =				GameInfoTypes.RELIGION_CULT_OF_AEGIR
local RELIGION_CULT_OF_PLOUTON =			GameInfoTypes.RELIGION_CULT_OF_PLOUTON
local RELIGION_CULT_OF_CAHRA =				GameInfoTypes.RELIGION_CULT_OF_CAHRA
local RELIGION_CULT_OF_EPONA =				GameInfoTypes.RELIGION_CULT_OF_EPONA
local RELIGION_CULT_OF_BAKKHEIA =			GameInfoTypes.RELIGION_CULT_OF_BAKKHEIA


local POLICY_PANTHEISM =					GameInfoTypes.POLICY_PANTHEISM
local POLICY_SLAVE_RAIDERS =				GameInfoTypes.POLICY_SLAVE_RAIDERS

local TECH_MILLING =						GameInfoTypes.TECH_MILLING
local TECH_SAILING =						GameInfoTypes.TECH_SAILING

local YIELD_PRODUCTION =					GameInfoTypes.YIELD_PRODUCTION

local PLOT_LAND =							PlotTypes.PLOT_LAND
local PLOT_OCEAN =							PlotTypes.PLOT_OCEAN
local PLOT_HILLS =							PlotTypes.PLOT_HILLS
local PLOT_MOUNTAIN =						PlotTypes.PLOT_MOUNTAIN
local PROMOTION_SLAVE =						GameInfoTypes.PROMOTION_SLAVE
local PROMOTION_SLAVERAIDER =				GameInfoTypes.PROMOTION_SLAVERAIDER
--local EA_ACTION_TAKE_RESIDENCE =			GameInfoTypes.EA_ACTION_TAKE_RESIDENCE

local VERY_UNHAPPY_THRESHOLD =				GameDefines.VERY_UNHAPPY_THRESHOLD



--localized game and global tables
local realCivs =					MapModData.realCivs
local fullCivs =					MapModData.fullCivs
local cityStates =					MapModData.cityStates
local playerType =					MapModData.playerType
local bHidden =						MapModData.bHidden
local Players =						Players
local Teams =						Teams
local gPlayers =					gPlayers
local gCities =						gCities
local gWorld =						gWorld
local gRaceDiploMatrix =			gRaceDiploMatrix
local gg_unitPrefixUnitIDs =		gg_unitPrefixUnitIDs
local gg_playerCityPlotIndexes =	gg_playerCityPlotIndexes
local gg_cityPlotCoastalTest =		gg_cityPlotCoastalTest
local gg_campRange =				gg_campRange
local gg_fishingRange =				gg_fishingRange
local gg_whalingRange =				gg_whalingRange
local gg_remoteImprovePlot =		gg_remoteImprovePlot
local gg_cityRemoteImproveCount =	gg_cityRemoteImproveCount

--localized game and library functions
local gsub =		string.gsub
local Rand =				Map.Rand
local floor =				math.floor

--localized global functions
local HandleError21 =		HandleError21
local HandleError31 =		HandleError31
local HandleError41 =		HandleError41
local HandleError51 =		HandleError51
local HandleError61 =		HandleError61
local HandleError81 =		HandleError81
local GetMemoizedPlotIndexDistance = GetMemoizedPlotIndexDistance
local PlotDistance =			Map.PlotDistance
local GetPlotFromXY =		Map.GetPlot
local GetPlotByIndex =		Map.GetPlotByIndex
--local FindOpenTradeRoute =	FindOpenTradeRoute		--in EaTrade.lua

--file control
local bInitialized = false
local g_gameTurn = Game.GetGameTurn()
local g_handicapAIGrowthPercent = {}
local g_riverDockByPlotIndex = {}
local integers = {}

local g_iActivePlayer = Game.GetActivePlayer()

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------

local buildingOccupationMod = {}
local prohibitSellBuildings = {}
for buildingInfo in GameInfo.Buildings() do
	if buildingInfo.EaOccupationUnhapReduction > 0 then
		buildingOccupationMod[buildingInfo.ID] = buildingInfo.EaOccupationUnhapReduction
	end
	if buildingInfo.EaProhibitSell then
		prohibitSellBuildings[buildingInfo.ID] = true
	end
end

local religionFollowerBuildings = {}
for religionInfo in GameInfo.Religions() do
	local followerBuilding = religionInfo.EaFollowerBuilding
	if followerBuilding then
		religionFollowerBuildings[religionInfo.ID] = GameInfoTypes[followerBuilding]
	end
end

local remoteImproveBuildings = {}	--index by buildingID; holds all types; = enablingBuildingID 
local remoteImproveEnablingBuildings = {}	--index by buildingID; = enablingBuildingID
for row in GameInfo.Building_EaRemoteImproveTypes() do
	local buildingID = GameInfoTypes[row.BuildingType]
	local type = row.RemoteImproveType
	local enablingBuildingID = row.EnablingBuildingType and GameInfoTypes[row.EnablingBuildingType] or -1
	remoteImproveBuildings[buildingID] = remoteImproveBuildings[buildingID] or {}
	remoteImproveBuildings[buildingID][#remoteImproveBuildings[buildingID] + 1] = type
	remoteImproveEnablingBuildings[buildingID] = enablingBuildingID
end
for buildingID, table in pairs(remoteImproveBuildings) do
	table.size = #table
end
--------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------

local function JustSettled(iPlayer, city)
	--count and remember what's near the new capital (used for trait condition tests and initial AI tech priority)
	print("Running JustSettled", iPlayer, city:GetName())
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	city:SetFood(math.floor(city:GrowthThreshold() * 0.75))	-- fill food basket 3/4 (runs after SetPopulation)
	for x, y in PlotToRadiusIterator(city:GetX(), city:GetY(), 3) do
		local plot = Map.GetPlot(x, y)
		local resourceID = plot:GetResourceType(-1)
		if resourceID ~= -1 then
			eaPlayer.resourcesNearCapitalByID[resourceID] = (eaPlayer.resourcesNearCapitalByID[resourceID] or 0) + 1
		end
	end
	if not player:IsHuman() then
		AICivRun(iPlayer)
	end
	CheckCapitalBuildings(iPlayer)
end

local function AutoIndenture(city, eaCity, size, gameTurn)
	eaCity.conscriptTurn = gameTurn
	city:SetPopulation(size - 1, true)
	local raceID = GetCityRace(city)
	local unitID
	if raceID == EARACE_MAN then
		unitID = UNIT_SLAVES_MAN
	elseif raceID == EARACE_SIDHE then
		unitID = UNIT_SLAVES_SIDHE
	else 
		unitID = UNIT_SLAVES_ORC
	end
	local newUnit = player:InitUnit(unitID, city:GetX(), city:GetY() )
	--newUnit:JumpToNearestValidPlot()
	newUnit:SetHasPromotion(PROMOTION_SLAVE, true)
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaCityInit(bNewGame)
	for iPlayer, eaPlayer in pairs(fullCivs) do
		local player = Players[iPlayer]
		local playerHandicapID = player:GetHandicapType()
		g_handicapAIGrowthPercent[iPlayer] = GameInfo.HandicapInfos[playerHandicapID].AIGrowthPercent	--will only apply to AI players
	end
	for iPlayer, eaPlayer in pairs(realCivs) do
		gg_playerCityPlotIndexes[iPlayer] = {}
	end
	if bNewGame then
		for iPlayer, eaPlayer in pairs(realCivs) do
			BlockUnitMatch(iPlayer, "UNIT_SLAVES", "NonSlavery", true, nil)
		end
	else
		for iPlayer, eaPlayer in pairs(realCivs) do
			local player = Players[iPlayer]
			for city in player:Cities() do
				--AddCityToResDistanceMatrixes(iPlayer, city)
				InitCityPlotIndexGlobals(iPlayer, city:GetID())
			end
		end
		for iPlayer, eaPlayer in pairs(fullCivs) do
			local player = Players[iPlayer]
			for city in player:Cities() do
				if city:GetNumBuilding(BUILDING_RIVER_DOCK) > 0 then
					g_riverDockByPlotIndex[city:Plot():GetPlotIndex()] = true
				end
			end
		end
	end
	bInitialized = true
end

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function InitCityRemoteImproveCount(iPlayer, iCity)
	local cityRemoteImproveCount = {HuntingRes = 0, Lake = 0, FishingRes = 0, WhalingRes = 0, Mountain = 0}
	gg_cityRemoteImproveCount[iPlayer][iCity] = cityRemoteImproveCount
	return cityRemoteImproveCount
end

function InitCityPlotIndexGlobals(iPlayer, iCity)
	local iPlot = gg_playerCityPlotIndexes[iPlayer][iCity]
	if iPlot then
		return iPlot
	end
	local city = Players[iPlayer]:GetCityByID(iCity)
	iPlot = city:Plot():GetPlotIndex()
	if city:IsCoastal(5) then
		gg_cityPlotCoastalTest[iPlot] = true
	end

	--clean up any old cities at this plot (ie, conquered city)
	for iLoopPlayers, cityPlotTables in pairs(gg_playerCityPlotIndexes) do
		for iLoopCity, iLoopPlot in pairs(cityPlotTables) do
			if iLoopPlot == iPlot then
				cityPlotTables[iLoopCity] = nil
			end
		end
	end

	gg_playerCityPlotIndexes[iPlayer][iCity] = iPlot
	return iPlot
end

function GetNewOwnerCityForPlot(iPlayer, iPlot, requiredReligionID)
	local plot = GetPlotByIndex(iPlot)
	for radius = 1, 100 do
		local bestCity
		local biggestSize = 0
		for testPlot in PlotRingIterator(plot, radius, 1, false) do
			local testCity = testPlot:GetPlotCity()
			if testCity and testCity:GetOwner() == iPlayer and (not requiredReligionID or testCity:GetReligiousMajority() == requiredReligionID) then
				local size = testCity:GetPopulation()
				if biggestSize < size or (biggestSize == size and testCity:IsCapital()) then
					biggestSize = size
					bestCity = testCity
				end
			end
		end
		if bestCity then
			return bestCity
		end
	end
	error("Could not find city within 100 plots")
end


function GetCityRace(city)
	local race
	local debugCount = 0
	if city:GetNumBuilding(BUILDING_MAN) == 1 then
		race = EARACE_MAN
		debugCount = 1
	end
	if city:GetNumBuilding(BUILDING_SIDHE) == 1 then
		race = EARACE_SIDHE
		debugCount = debugCount + 1
	end
	if city:GetNumBuilding(BUILDING_HELDEOFOL) == 1 then
		race = EARACE_HELDEOFOL
		debugCount = debugCount + 1
	end
	if 1 < debugCount then
		error("City had >1 race; count, name, owner = " .. debugCount .. " " .. city:GetName() .. " " .. city:GetOwner())
	end
	if debugCount == 0 then
		--this shouldn't happen but does sometimes (on conquest? AI selling when it shouldn't?)
		local iOriginalOwner = city:GetOriginalOwner()
		print("!!!! ERROR: City had no race; name/owner/originalOwner = ", city:GetName(), city:GetOwner(), iOriginalOwner)
		local race = gPlayers[iOriginalOwner].race
		if race == EARACE_MAN then
			city:SetNumRealBuilding(BUILDING_MAN, 1)
			race = EARACE_MAN
		elseif race == EARACE_SIDHE then
			city:SetNumRealBuilding(BUILDING_SIDHE, 1)
			race = EARACE_SIDHE
		elseif race == EARACE_HELDEOFOL then
			city:SetNumRealBuilding(BUILDING_HELDEOFOL, 1)
			race = EARACE_HELDEOFOL
		else
			error("What race?")
		end
	end

	--Heldeofol not implemented yet...
	if race == EARACE_HELDEOFOL then
		error("City had race Heldeofol; name, owner = " .. city:GetName() .. " " .. city:GetOwner())
	end
	return race
end

function BlockBuilding(iPlayer, buildingID, blockIndex, bBlock, city)	--city not implemented yet (blocks are civ-wide)
	print("Running BlockBuilding ", iPlayer, buildingID, blockIndex, bBlock, city)
	local eaPlayer = gPlayers[iPlayer]
	local blockingTable = eaPlayer.blockedBuildingsByID		-- = city and eaCity.blockedBuildingsByID or eaPlayer.blockedBuildingsByID
	if bBlock then
		blockingTable[buildingID] = blockingTable[buildingID] or {}		--presence of table blocks
		blockingTable[buildingID][blockIndex] = true
	elseif blockingTable[buildingID] then
		blockingTable[buildingID][blockIndex] = nil
		if next(blockingTable[buildingID]) == nil then					--table is empty so remove (will totally unblock)
			blockingTable[buildingID] = nil
		end
	end
end

function BlockUnit(iPlayer, unitID, blockIndex, bBlock, city)	--city not implemented yet (blocks are civ-wide)
	--print("Running BlockUnit ", iPlayer, unitID, blockIndex, bBlock, city)
	local eaPlayer = gPlayers[iPlayer]
	local blockingTable = eaPlayer.blockedUnitsByID		
	if bBlock then
		blockingTable[unitID] = blockingTable[unitID] or {}			--presence of table blocks
		blockingTable[unitID][blockIndex] = true
	elseif blockingTable[unitID] then
		blockingTable[unitID][blockIndex] = nil
		if next(blockingTable[unitID]) == nil then					--table is empty so remove (will totally unblock)
			blockingTable[unitID] = nil
		end
	end
end

local BlockUnit = BlockUnit

function BlockUnitMatch(iPlayer, unitPrefix, blockIndex, bBlock, city)	--city not implemented yet (blocks are civ-wide)
	--print("Running BlockUnitMatch ", iPlayer, unitPrefix, blockIndex, bBlock, city)
	local units = gg_unitPrefixUnitIDs[unitPrefix]
	if units then
		for i = 1, #units do
			local unitID = units[i]
			BlockUnit(iPlayer, unitID, blockIndex, bBlock, city)
		end
	else
		error("Found no units for unit prefix " .. unitPrefix)
	end
end

function ConvertUnitProductionByMatch(iPlayer, fromStr, toStr)
	print("Running ConvertUnitProductionByMatch ", iPlayer, fromStr, toStr)
	local player = Players[iPlayer]
	local fromMatches = gg_unitPrefixUnitIDs[fromStr]
	for i = 1, #fromMatches do
		local unitTypeID = fromMatches[i]
		for city in player:Cities() do
			local unitProd = city:GetUnitProduction(unitTypeID)
			if 0 < unitProd then
				local unitType = GameInfo.Units[unitTypeID].Type
				local newUnitType = gsub(unitType, fromStr, toStr)
				local newUnitTypeID = GameInfoTypes[newUnitType]
				city:SetUnitProduction(newUnitTypeID, unitProd)
				city:SetUnitProduction(unitTypeID, 0)
			end
			--force queue change
			local qLength = city:GetOrderQueueLength()
			for i = 0, qLength - 1 do
				local orderType, orderID = city:GetOrderFromQueue(i)
				if orderType == OrderTypes.ORDER_TRAIN and orderID == unitTypeID then
					print("Attempting to force queue change; iCity, position, unitTypeID, newUnitTypeID = ", city:GetID(), i, unitTypeID, newUnitTypeID)
					Game.CityPushOrder(city, orderType, newUnitTypeID, false, false, true)
				end
			end
		end
	end
end

function TestNaturalHarborForFreeHarbor(city)	--assumes proper tech
	if not city:IsCoastal(10) then return false end
	print("Testing city for natural harbor")
	local bHasNaturalHarbor = false
	for x, y in PlotToRadiusIterator(city:GetX(), city:GetY(), 1, nil, nil, true) do
		local plot = GetPlotFromXY(x, y)
		if plot:IsWater() and not plot:IsLake() then
			local adjLandPlots = 0
			for adjX, adjY in PlotToRadiusIterator(x, y, 1, nil, nil, true) do
				local adjPlot = GetPlotFromXY(adjX, adjY)
				if not adjPlot:IsWater() then
					adjLandPlots = adjLandPlots + 1
				end
			end
			print(" -number surrounding land = ", adjLandPlots)
			if 3 < adjLandPlots then --four or more adj. plots must be land
				bHasNaturalHarbor = true
				plot:SetOwner(city:GetOwner(), city:GetID())
			end
		end
	end
	if bHasNaturalHarbor then
		city:SetNumFreeBuilding(BUILDING_HARBOR, 1)
	end
end

function TestSetEligibleCityCults(city, eaCity, feedbackCultID)
	local totalPlots = city:GetNumCityPlots()
	local totalLand = 0
	local totalUnimprovedForestJungle = 0
	local totalFreshWater = 0
	local totalHillsMountains = 0
	local totalDesert = 0
	local totalGoodFlatland, totalHorses = 0, 0
	local totalWine = 0

	for i = 0, totalPlots - 1 do
		local plot = city:GetCityIndexPlot(i)
		if plot then
			local plotTypeID = plot:GetPlotType()
			if plotTypeID == PLOT_OCEAN then
				if plot:IsLake() then
					totalLand = totalLand + 1
					totalFreshWater = totalFreshWater + 1
				end	
			else
				totalLand = totalLand + 1
				if plotTypeID == PLOT_MOUNTAIN then
					totalHillsMountains = totalHillsMountains + 1
				else
					if plotTypeID == PLOT_HILLS then
						totalHillsMountains = totalHillsMountains + 1
					end
					local featureID = plot:GetFeatureType()
					if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE then
						if plot:GetImprovementType() == -1 then
							totalUnimprovedForestJungle = totalUnimprovedForestJungle + 1
						end
					end
					if plot:IsFreshWater() then
						totalFreshWater = totalFreshWater + 1
					end
					local resourceID = plot:GetResourceType(-1)
					if resourceID == RESOURCE_HORSE then
						totalHorses = totalHorses + 1
					elseif resourceID == RESOURCE_WINE then
						totalWine = totalWine + 1
					end
					local terrainID = plot:GetTerrainType()
					--print("plot test: ", terrainID, plotTypeID, featureID, resourceID)

					if terrainID == TERRAIN_DESERT then
						totalDesert = totalDesert + 1
					elseif terrainID == TERRAIN_GRASS or terrainID == TERRAIN_PLAINS then
						if plotTypeID == PLOT_LAND and featureID == -1 then
							totalGoodFlatland = totalGoodFlatland + 1
						end
					end
				end
			end
		end
	end
	
	local bSeaCity = totalLand / totalPlots < 0.4
	if bSeaCity then
		if city:IsCoastal(10) then
			eaCity.eligibleCults[RELIGION_CULT_OF_AEGIR] = true
		end
	else
		if totalUnimprovedForestJungle / totalLand >= 0.6 then
			eaCity.eligibleCults[RELIGION_CULT_OF_LEAVES] = true
		end
		if totalFreshWater / totalLand >= 0.35 then
			eaCity.eligibleCults[RELIGION_CULT_OF_ABZU] = true
		end
		if totalHillsMountains / totalLand >= 0.4 then
			eaCity.eligibleCults[RELIGION_CULT_OF_PLOUTON] = true
		end
		if totalDesert / totalLand >= 0.5 then
			eaCity.eligibleCults[RELIGION_CULT_OF_CAHRA] = true
		end
	end
	if totalHorses > 2 then
		eaCity.eligibleCults[RELIGION_CULT_OF_EPONA] = true
	elseif totalHorses > 1 then
		if totalGoodFlatland / totalLand >= 0.5 then
			eaCity.eligibleCults[RELIGION_CULT_OF_EPONA] = true
		end
	end
	local boozeBuildings = 0
	if totalWine > 1 then
		eaCity.eligibleCults[RELIGION_CULT_OF_BAKKHEIA] = true
	else
		boozeBuildings = city:GetNumBuilding(BUILDING_WINERY) + city:GetNumBuilding(BUILDING_BREWERY) + city:GetNumBuilding(BUILDING_DISTILLERY)
		if boozeBuildings > 1 then
			eaCity.eligibleCults[RELIGION_CULT_OF_BAKKHEIA] = true
		end
	end

	if feedbackCultID then	--for human UI test, only shows for disallowed cults after generic reasons exhausted (not city, holy city)
		if feedbackCultID == RELIGION_CULT_OF_EPONA then
			return "Must have 3 Horse plots, or 2 Horse plots and 50% open flatland (grass or plains); city has " .. totalHorses .. " Horses plots and " .. floor(100 * totalGoodFlatland / totalLand) .. "% qualified flatland"
		elseif  feedbackCultID == RELIGION_CULT_OF_BAKKHEIA then
			return "Must have 2 Wine or 2 spirits buildings (Winery, Brewery or Distillery); city has " .. totalWine .. " Wine and " .. boozeBuildings .. " spirits buildings"
		end

		if bSeaCity then
			if feedbackCultID == RELIGION_CULT_OF_LEAVES then
				return "This city is dominated by the sea (>60% surrounding plots)"
			elseif feedbackCultID == RELIGION_CULT_OF_ABZU then
				return "This city is dominated by the sea (>60% surrounding plots)"
			elseif feedbackCultID == RELIGION_CULT_OF_PLOUTON then
				return "This city is dominated by the sea (>60% surrounding plots)"
			elseif feedbackCultID == RELIGION_CULT_OF_CAHRA then
				return "This city is dominated by the sea (>60% surrounding plots)"
			elseif feedbackCultID == RELIGION_CULT_OF_AEGIR then
				return "Must be coastal"
			end
		else
			if feedbackCultID == RELIGION_CULT_OF_LEAVES then
				return "Surrounding land must include 60% unimproved forests or jungles; city has " .. floor(100 * totalUnimprovedForestJungle / totalLand) .. "%"
			elseif feedbackCultID == RELIGION_CULT_OF_ABZU then
				return "Surrounding land must include 35% fresh water plots; city has " .. floor(100 * totalFreshWater / totalLand) .. "%"
			elseif feedbackCultID == RELIGION_CULT_OF_PLOUTON then
				return "Surrounding land must include 40% hills or mountains; city has " .. floor(100 * totalFreshWater / totalLand) .. "%"
			elseif feedbackCultID == RELIGION_CULT_OF_CAHRA then
				return "Surrounding land must include 50% desert; city has " .. floor(100 * totalDesert / totalLand) .. "%"
			elseif feedbackCultID == RELIGION_CULT_OF_AEGIR then
				return "Must have >60% surrounding sea; city has " .. floor(100 * (1 - totalLand / totalPlots)) .. "%"
			end
		end
		return "REPORT AS BUG"
	end
end
local TestSetEligibleCityCults = TestSetEligibleCityCults

function CityPerCivTurn(iPlayer)		--Full civ only		TO DO: must be real civs so that remote plot system works
	local floor = math.floor
	print("CityPerCivTurn; City info (Name/Size/BuildQueue):")

	local gameTurn = Game.GetGameTurn()
	local eaPlayer = gPlayers[iPlayer]
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	local bFullCiv = fullCivs[iPlayer]
	local bActivePlayer = iPlayer == g_iActivePlayer
	local classPoints = bFullCiv and eaPlayer.classPoints
	local bIsPantheistic = bFullCiv and player:HasPolicy(POLICY_PANTHEISM)
	local bAI = not bFullCiv or not player:IsHuman()
	local bAnraFounded = gReligions[RELIGION_ANRA] ~= nil
	local bCheckWindy = team:IsHasTech(TECH_MILLING)
	local aiGrowthPercent = (bFullCiv and bAI) and g_handicapAIGrowthPercent[iPlayer] or nil
	local playerRemoteImproveCount = gg_cityRemoteImproveCount[iPlayer]

	local cityCount = 0
	--cycle through gCities
	for iPlot, eaCity in pairs(gCities) do
		if eaCity.iOwner == iPlayer then
			local plot = GetPlotByIndex(iPlot)
			local city = plot:GetPlotCity()
			if not city then
				error("No city for eaCity in CityPerCivTurn" .. iPlayer .. " " .. plot:GetPlotIndex())
				--Should always be caught by OnCityKilled; need to know otherwise
			elseif city:GetOwner() ~= iPlayer then
				error("eaCity owner disagrees with city owner" .. iPlayer .. " " .. city:GetOwner() .. " " .. city:GetName())
				--Need to detect and fix if this happens for any reason
			else
				local iCity = city:GetID()
				cityCount = cityCount + 1

				local size = city:GetPopulation()	
				local followerReligion = city:GetReligiousMajority()	
				local cityRaceID = GetCityRace(city)		

				--Disease/Plague: +values represent turns remaining for disease, -values represents turns remaining for plague
				if eaCity.disease == 0 then
					local health, diseaseChance, plagueChance = GetCityHealthInfo(city, eaCity, size, followerReligion, aiGrowthPercent, false)
					if 0 < plagueChance and Rand(100, "plague role") < plagueChance then
						eaCity.disease = -Rand(floor(0.66 * size), "hello") - 1
					elseif 0 < diseaseChance and Rand(100, "disease role") < diseaseChance then
						eaCity.disease = Rand(floor(0.33 * size), "hello") + 1
					end
				end
				if eaCity.disease ~= 0 then
					if 1 < size then
						city:ChangePopulation(-1, true)
						size = size - 1
					end
					if eaCity.disease < 0 then
						if bActivePlayer then
							local str = "Plague ravages " .. city:GetName() .. ". The city will lose one population point per turn for the next " .. -eaCity.disease .. " turn(s)"
							player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, str, -1, -1)
						end
						eaCity.disease = eaCity.disease + 1
					else
						if bActivePlayer then
							local str = "Disease ravages " .. city:GetName() .. ". The city will lose one population point per turn for the next " .. eaCity.disease .. " turn(s)"
							player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, str, -1, -1)
						end
						eaCity.disease = eaCity.disease - 1
					end

					--need plague spread
				end
				
				--gCities update
				eaCity.size = size	--is this used?

				--Remote Improves
				local cityRemoteImproveCount = playerRemoteImproveCount[iCity] or InitCityRemoteImproveCount(iPlayer, iCity)
				for buildingID, improveTypes in pairs(remoteImproveBuildings) do
					local count = 0
					for i = 1, improveTypes.size do
						local improveType = improveTypes[i]
						count = count + cityRemoteImproveCount[improveType]
					end
					--print("RemoteImproves Building/Count = ", GameInfo.Buildings[buildingID].Type, count)
					if 0 < city:GetNumFreeBuilding(buildingID) then	--true if ever given for free
						city:SetNumFreeBuilding(buildingID, count + 1)
						city:SetNumRealBuilding(buildingID, 0)
					elseif 0 < city:GetNumRealBuilding(buildingID) then	--true if ever built
						city:SetNumRealBuilding(buildingID, count + 1)
					else
						local enablingBuildingID = remoteImproveEnablingBuildings[buildingID]
						if enablingBuildingID ~= -1 then
							if count == 0 then
								city:SetNumRealBuilding(enablingBuildingID, 0)
							else
								city:SetNumRealBuilding(enablingBuildingID, 1)
							end
						end
					end
				end
				for improveType in pairs(cityRemoteImproveCount) do		--reset counts to 0 for this city (ready for PlotsPerTurn)
					cityRemoteImproveCount[improveType] = 0
				end

				--Cult eligibility (used in TestTarget for cult founding/spreading; calculate once per city here)
				TestSetEligibleCityCults(city, eaCity, nil)

				--Religion/Cult effects
				if bAnraFounded then
					local consumedMana = city:GetNumFollowers(RELIGION_ANRA) * MANA_CONSUMED_PER_ANRA_FOLLOWER_PER_TURN
					if 0 < consumedMana then
						gWorld.sumOfAllMana = gWorld.sumOfAllMana - consumedMana
						eaPlayer.manaConsumed = (eaPlayer.manaConsumed or 0) + consumedMana
						city:Plot():AddFloatUpMessage(Locale.Lookup("TXT_KEY_EA_CONSUMED_MANA", consumedMana))	
					end
				end
				for religionID, buildingID in pairs(religionFollowerBuildings) do
					if followerReligion == religionID then
						city:SetNumRealBuilding(buildingID, 1)
					else
						city:SetNumRealBuilding(buildingID, 0)
					end
				end

				--desertCahraFollower
				city:SetNumRealBuilding(BUILDING_CULT_LEAVES_1F1C, (followerReligion == RELIGION_CULT_OF_LEAVES) and floor(eaCity.unimprovedForestJungle / 3) or 0)
				city:SetNumRealBuilding(BUILDING_CULT_CAHRA_1F, (followerReligion == RELIGION_CULT_OF_CAHRA) and floor(eaCity.desertCahraFollower / 3) or 0)

				if followerReligion == RELIGION_CULT_OF_ABZU then
					if plot:IsFreshWater() then
						gg_counts.freshWaterAbzuFollowerCities = gg_counts.freshWaterAbzuFollowerCities + 1
					end
				elseif followerReligion == RELIGION_CULT_OF_AEGIR then
					if city:IsCoastal(10) then
						gg_counts.coastalAegirFollowerCities = gg_counts.coastalAegirFollowerCities + 1
					end
				elseif followerReligion == RELIGION_CULT_OF_BAKKHEIA then
					gg_counts.grapeAndSpiritsBuildingsBakkheiaFollowerCities = gg_counts.grapeAndSpiritsBuildingsBakkheiaFollowerCities + city:GetNumBuilding(BUILDING_WINERY) + city:GetNumBuilding(BUILDING_BREWERY) + city:GetNumBuilding(BUILDING_DISTILLERY)
				end
			
				--Processes (not implemented elsewhere)
				local orderType, orderID = city:GetOrderFromQueue(0)
				if orderType == ORDER_MAINTAIN then
					local productionYieldRate = city:GetYieldRate(YIELD_PRODUCTION)
					if orderID == PROCESS_WORLD_WEAVE then	
						gWorld.weaveConvertNum = gWorld.weaveConvertNum + productionYieldRate / 100
					elseif orderID == PROCESS_WORLD_SALVATION then	
						gWorld.azzConvertNum = gWorld.azzConvertNum + productionYieldRate / 100
					elseif orderID == PROCESS_WORLD_CORRUPTION then	
						gWorld.anraConvertNum = gWorld.anraConvertNum + productionYieldRate / 100
					elseif orderID == PROCESS_EA_BLESSINGS then	
						gWorld.livingTerrainConvertStr = gWorld.livingTerrainConvertStr + productionYieldRate / 10
					elseif orderID == PROCESS_FAERIES_TRIBUTE then			
						eaPlayer.faerieTribute = eaPlayer.faerieTribute or {}
						eaPlayer.faerieTribute[gameTurn] = productionYieldRate / 10
					elseif orderID == PROCESS_MAJOR_SPIRITS_TRIBUTE then	
						eaPlayer.majorSpiritsTribute = (eaPlayer.majorSpiritsTribute or 0) + productionYieldRate / 4
					elseif orderID == PROCESS_PATRONAGE then	
						eaPlayer.cityStatePatronage = (eaPlayer.cityStatePatronage or 0) + productionYieldRate / 4
					elseif orderID == PROCESS_TRAINING_EXERCISES then	
						eaPlayer.trainingXP = (eaPlayer.trainingXP or 0) + productionYieldRate / 4
					--elseif orderID == PROCESS_AHRIMANS_TRIBUTE then	
					--	local manaBurn = floor(productionYieldRate / 4)
					--	gWorld.sumOfAllMana = gWorld.sumOfAllMana - manaBurn
					--	eaPlayer.manaConsumed = (eaPlayer.manaConsumed or 0) + manaBurn
					end
				end

				--Spontanious appearance for The Weave
				if bIsPantheistic then
					if Rand(4, "hello") < 1 then
						city:ConvertPercentFollowers(RELIGION_THE_WEAVE_OF_EA, -1, 20)	--convert 20% of atheists to this religion
					end
				end

				--[[
				--Occupied happiness
				if city:IsOccupied() and not city:IsNoOccupiedUnhappiness() then
					local occupationUnhappiness = city:GetPopulation() * UNHAPPINESS_PER_OCCUPIED_POPULATION + UNHAPPINESS_PER_CAPTURED_CITY

					local reduction = 0
					for buildingID, value in pairs(buildingOccupationMod) do
						if city:GetNumBuilding(buildingID) > 0 then
							reduction = reduction + value
						end
					end
					reduction = reduction < 100 and reduction or 100
					city:SetNumRealBuilding(BUILDING_OCCUPIED_PLUS_1_HAPPY, floor(occupationUnhappiness * reduction / 100))
				else
					city:SetNumRealBuilding(BUILDING_OCCUPIED_PLUS_1_HAPPY, 0)
				end
				]]

				--River Dock?
				g_riverDockByPlotIndex[iPlot] = 0 < city:GetNumBuilding(BUILDING_RIVER_DOCK) or nil
			
				--Windy?
				if bCheckWindy and city:GetNumBuilding(BUILDING_WINDMILL) ~= 1 then
					local countWindBreak = 0
					for adjPlot in AdjacentPlotIterator(plot) do
						local plotTypeID = adjPlot:GetPlotType()
						if plotTypeID == PLOT_HILLS or plotTypeID == PLOT_MOUNTAIN then
							countWindBreak = countWindBreak + 1
							if 1 < countWindBreak then break end
						else
							local featureID = adjPlot:GetFeatureType()
							if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE then
								countWindBreak = countWindBreak + 1
								if 1 < countWindBreak then break end	
							end
						end
					end
					if countWindBreak < 2 then
						city:SetNumRealBuilding(BUILDING_WINDMILL_ALLOW, 1)
					else
						city:SetNumRealBuilding(BUILDING_WINDMILL_ALLOW, 0)
					end
				end

				--Race hatreds grow based on city razing
				if cityRaceID ~= eaPlayer.race and city:IsRazing() then
					if not bAnraFounded or (city:GetReligiousMajority() ~= RELIGION_ANRA and not city:IsHolyCityForReligion(RELIGION_ANRA)) then
						local addHate = RACE_HATRED_FOR_RAZED_POP
						gRaceDiploMatrix[cityRaceID][eaPlayer.race] = gRaceDiploMatrix[cityRaceID][eaPlayer.race] + addHate
					end
				end

				--Full civ only
				if bFullCiv then

					--GP point counting
					classPoints[1] = classPoints[1] + city:GetSpecialistCount(SPECIALIST_SMITH) * 2
					classPoints[2] = classPoints[2] + city:GetSpecialistCount(SPECIALIST_TRADER) * 2
					classPoints[3] = classPoints[3] + city:GetSpecialistCount(SPECIALIST_SCRIBE) * 2
					classPoints[4] = classPoints[4] + city:GetSpecialistCount(SPECIALIST_ARTISAN) * 2
					classPoints[6] = classPoints[6] + city:GetSpecialistCount(SPECIALIST_DISCIPLE) * 2
					classPoints[7] = classPoints[7] + city:GetSpecialistCount(SPECIALIST_ADEPT) * 2

					--update residence status and effects if GP walks away or dies
					if eaCity.resident ~= -1 then
						local x, y = city:GetX(), city:GetY()
						local iPerson = eaCity.resident
						local eaPerson = gPeople[iPerson]
						if eaPerson then
							local iUnit = eaPerson.iUnit
							if iUnit ~= -1 then
								local unit = player:GetUnitByID(iUnit)
								if unit then
									local personX, personY = unit:GetX(), unit:GetY()
									if personX ~= x or personY ~= y then
										InterruptEaAction(iPlayer, iPerson)
									end
								else
									error("No unit for GP")
								end
							else
								InterruptEaAction(iPlayer, iPerson)
							end
						else		--Person died, update city for no resident
							eaCity.resident = -1
							RemoveResidentEffects(city)
						end

					end

					--auto-indenture
					if eaCity.autoIndenturePop and eaCity.autoIndenturePop < size and eaCity.conscriptTurn ~= gameTurn then
						AutoIndenture(city, eaCity, size, gameTurn)
					end
				end
			end
		end
	end

	--debug
	local debugCityCount = 0
	for city in player:Cities() do
		debugCityCount = debugCityCount + 1
	end
	if debugCityCount ~= cityCount then
		error("City count error; gCities may be corrupt")
	end
end

local function OnPlayerCityFounded(iPlayer, x, y)
	if not bInitialized then
		print("WARNING!!!! running OnPlayerCityFounded before init")
		return
	end
	if not realCivs[iPlayer] then
		error("Non-civ founded a city " .. (playerType[iPlayer] or "nil") .. " " .. iPlayer)
	end
	print("PlayerCityFounded", iPlayer, x, y)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local iPlot = GetPlotIndexFromXY(x, y)
	local plot = Map.GetPlot(x, y)
	local city = plot:GetPlotCity()
	local iCity = city:GetID()

	InitCityPlotIndexGlobals(iPlayer, iCity)

	-- Ea city init
	local eaCity = {iOwner = iPlayer,	-- !!!!!!!!!!!!!!!!  INIT NEW EaCity HERE !!!!!!!!!!!!!!!!
					x = x,
					y = y,
					openLandTradeRoutes = {},	-- index by other eaCityIndex; holds other city owner (so trade route is open on re-conqest)
					openSeaTradeRoutes = {},	
					progress = {},
					civProgress = {},
					resident = -1,
					size = 1,				--updated per turn; used to know how much pop lost from conquest
					disease = 0,			-- +values represent turns remaining for disease, -values represents turns remaining for plague
					remotePlots = {},		--index by iPlot (holds true for now...)
					foodBoost = 0,
					productionBoost = 0,
					goldBoost = 0,
					scienceBoost = 0,
					cultureBoost = 0,
					culturePercentBoost = 0,
					eligibleCults = {},
					unimprovedForestJungle = 0,
					desertCahraFollower = 0
					}

	gCities[iPlot] = eaCity

	local raceInfo = GameInfo.EaRaces[eaPlayer.race]
	--Set race
	city:SetNumRealBuilding(GameInfoTypes[raceInfo.IdentifierBuilding], 1)

	--AddCityToResDistanceMatrixes(iPlayer, city)

	if playerType[iPlayer] == "FullCiv" then
		--City naming
		local namingTrait = eaPlayer.eaCivNameID
		if not namingTrait then			--not named yet so must be initial city
			JustSettled(iPlayer, city)
			--Naming from table not reliable, so set here if needed
			local firstCityName
			if eaPlayer.race == EARACE_MAN then
				firstCityName = Locale.Lookup("TXT_KEY_EA_FIRST_CITY_MAN_1")
			elseif eaPlayer.race == EARACE_SIDHE then
				firstCityName = Locale.Lookup("TXT_KEY_EA_FIRST_CITY_SIDHE_1")
			elseif eaPlayer.race == EARACE_HELDEOFOL then
				firstCityName = Locale.Lookup("TXT_KEY_EA_FIRST_CITY_HELDEOFOL_1")
			end
			if city:GetName() ~= firstCityName then
				city:SetName(firstCityName, false)
			end
		end
	end

	local team = Teams[player:GetTeam()]
	if team:IsHasTech(TECH_SAILING) then
		TestNaturalHarborForFreeHarbor(city)
	end

	print("New city", iPlayer, iPlot, x, y, iCity, city:GetName())
end
local function X_OnPlayerCityFounded(iPlayer, x, y) return HandleError31(OnPlayerCityFounded, iPlayer, x, y) end
GameEvents.PlayerCityFounded.Add(X_OnPlayerCityFounded)

local function OnSetPopulation(x, y, oldPopulation, newPopulation)
	if oldPopulation == newPopulation then return end
	if not bInitialized then
		print("WARNING!!!! running SetPopulation before init")
		return
	end
	--Warning! This fires before OnCityCaptureComplete. 
	local plot = Map.GetPlot(x, y)
	local city = plot:GetPlotCity()
	print("Population change ", x, y, city:GetName(), oldPopulation, newPopulation, city:GetOwner(), Players[city:GetOwner()]:IsAlive())


	--This may be our first indication of a resurected player; however, I'm not sure if GetOwner works yet,
	--so I'm duplicating this functionality in OnCityCaptureComplete to be safe.
	local iOwner = city:GetOwner()
	if 0 < newPopulation and iOwner ~= -1 and not realCivs[iOwner] then
		ResurectedPlayer(iOwner)
	end

	--[[  done by OnPlayerCityFounded or OnCityCaptureComplete so not needed here (I'm not sure if iOwner is updated anyway)
	--add/remove from gg_playerCityPlotIndexes
	if oldPopulation == 0 and iOwner ~= -1 then	--new city for this player
		InitCityPlotIndexGlobals(iOwner, city:GetID())	--this is probably first call; no harm in redundant calls
	end 
	]]

	if city:IsRazing() then
		local owner = Players[iOwner]
		if newPopulation < oldPopulation then
			--if Slave Raider policy then give them a slaves unit

			if owner:HasPolicy(POLICY_SLAVE_RAIDERS) then
				local raceID = GetCityRace(city)
				local unitID
				if raceID == EARACE_MAN then
					unitID = UNIT_SLAVES_MAN
				elseif raceID == EARACE_SIDHE then
					unitID = UNIT_SLAVES_SIDHE
				else 
					unitID = UNIT_SLAVES_ORC
				end			
				local newUnit = owner:InitUnit(unitID, x, y )
				--newUnit:JumpToNearestValidPlot()
				newUnit:SetHasPromotion(PROMOTION_SLAVE, true)
				local eaPlayer = gPlayers[iOwner]
				if eaPlayer.eaCivNameID == EACIV_GAZIYA and Rand(3, "hello") == 0 then	--extra 33%
					local newUnit = owner:InitUnit(unitID, x, y )
					--newUnit:JumpToNearestValidPlot()
					newUnit:SetHasPromotion(PROMOTION_SLAVE, true)				
				end

			end
		end
	elseif oldPopulation ~= 0 then	--not a new city
		local raceID = GetCityRace(city)
		local minBasketPercent = 30
		if raceID == EARACE_MAN then
			minBasketPercent = 50
		elseif raceID == EARACE_HELDEOFOL then
			minBasketPercent = 70
		end

		local minFoodBasket = math.floor(minBasketPercent * city:GrowthThreshold() / 100)
		if city:GetFood() < minFoodBasket then
			city:SetFood(minFoodBasket)		--food basket always has something after growth and starvation
		end
	end
end
local function X_OnSetPopulation(x, y, oldPopulation, newPopulation) return HandleError41(OnSetPopulation, x, y, oldPopulation, newPopulation) end
GameEvents.SetPopulation.Add(X_OnSetPopulation)

local function OnCityCaptureComplete(iPlayer, bCapital, x, y, iNewOwner, iOldPopulation, bConquest)

	--Function name is deceptive: this is really from CvPlayer::acquireCity. iNewOwner is trustworthy, but iPlayer could be
	--either owner before capture or liberator. In latter case, there is no indication in args of owner before capture.
	--This could even be a gift transfer (bGift is not passed by current GameEvents).

	--This could potentialy fire after OnCityKilled (for example in OCC capture; not sure if any other way)

	--iNewOwner might be a resurected player (may be detected by pop change first)

	local newOwner = Players[iNewOwner]
	local iPlot = GetPlotIndexFromXY(x, y)
	local plot = GetPlotByIndex(iPlot)
	local city = plot:GetPlotCity()
	print("CityCaptureComplete", iPlayer, bCapital, x, y, iNewOwner, iOldPopulation, bConquest, city and city:GetName() or "city was killed")

	if city then		--otherwise it should already have fired OnCityKilled before we got here

		local iCity = city:GetID()
		local eaCity = gCities[iPlot]
		local eaNewOwner = gPlayers[iNewOwner]

		--Figure out who previous owner and conquering player are, since they aren't necessarily iPlayer, iNewOwner, and bConquest is
		--untrustworthy because this could be liberation resulting from conquest (in which case bConquest = false)
		local iPreviousOwner = eaCity.iOwner
		local iConqueringPlayer, conqueringPlayer, eaConqueringPlayer
		if iPreviousOwner == iPlayer then
			if bConquest then
				iConqueringPlayer = iNewOwner
				eaConqueringPlayer = eaNewOwner
				print("This is a city conquest without liberation: iConqueringPlayer = " .. iConqueringPlayer .. "; iPreviousOwner = " .. iPreviousOwner)
			else
				print("This is a city gift")
			end
		else
			iConqueringPlayer = iPlayer
			eaConqueringPlayer = gPlayers[iPlayer]
			print("This is a city conquest WITH liberation: iConqueringPlayer = " .. iConqueringPlayer .. "; iPreviousOwner = " .. iPreviousOwner)
		end
		conqueringPlayer = iConqueringPlayer and Players[iConqueringPlayer]

		eaCity.iOwner = iNewOwner

		local previousOwner = Players[iPreviousOwner]

		if previousOwner:IsAlive() then
			if bCapital then
				CheckCapitalBuildings(iPreviousOwner)
			end
		else
			print("!!!! Dead player detected from OnCityCaptureComplete !!!!")
			DeadPlayer(iPreviousOwner, iConqueringPlayer)
		end

		--Resurected player (may be caught by OnSetPopulation but I'm not sure)
		if not realCivs[iNewOwner] then
			ResurectedPlayer(iNewOwner)
		end

		InitCityPlotIndexGlobals(iNewOwner, iCity)

		--Check race
		local newCivRace = eaNewOwner.race
		if newCivRace == GetCityRace(city) then
			city:SetNumRealBuilding(BUILDING_RACIAL_DISHARMONY, 0)
		else
			city:SetNumRealBuilding(BUILDING_RACIAL_DISHARMONY, 1)
		end

		--City size and pop killed
		local oldSize = eaCity.size
		local newSize = city:GetPopulation()
		eaCity.size = newSize
		local popKilled = oldSize - newSize

		--Conquest
		if iConqueringPlayer then

			--Credit for conquest
			eaConqueringPlayer.conquests = eaConqueringPlayer.conquests or {}
			local uniqueConquestStr = iPlot .. "-" .. city:GetGameTurnFounded()
			if not eaConqueringPlayer.conquests[uniqueConquestStr] then
				eaConqueringPlayer.conquests[uniqueConquestStr] = oldSize
			end

			--Slave Raider
			if conqueringPlayer:HasPolicy(POLICY_SLAVE_RAIDERS) then
				local raceID = GetCityRace(city)
				local unitID
				if raceID == EARACE_MAN then
					unitID = UNIT_SLAVES_MAN
				elseif raceID == EARACE_SIDHE then
					unitID = UNIT_SLAVES_SIDHE
				else 
					unitID = UNIT_SLAVES_ORC
				end
				if eaConqueringPlayer.eaCivNameID == EACIV_GAZIYA then
					popKilled = floor(popKilled / 3 + 0.5)
				end

				for j = 1, popKilled do
					local newUnit = newOwner:InitUnit(unitID, x, y)
					--newUnit:JumpToNearestValidPlot()
					newUnit:SetHasPromotion(PROMOTION_SLAVE, true)
				end
			end
		end

		local team = Teams[newOwner:GetTeam()]
		if team:IsHasTech(TECH_SAILING) then
			TestNaturalHarborForFreeHarbor(city)
		end
	end
end
local function X_OnCityCaptureComplete(iPlayer, bCapital, x, y, iNewOwner, iOldPopulation, bConquest) return HandleError81(OnCityCaptureComplete, iPlayer, bCapital, x, y, iNewOwner, iOldPopulation, bConquest) end
GameEvents.CityCaptureComplete.Add(X_OnCityCaptureComplete)

local function OnCityKilled(iPlayer, iCity, iPlot, bCapital)	--only after razed to ground (not called by acquireCity)
	print("OnCityKilled ", iPlayer, iCity, iPlot, bCapital)
	local eaCity = gCities[iPlot]
	if eaCity then
		if eaCity.iOwner ~= iPlayer then	--these should agree (except in OCC where OnCityKilled fires before OnCityCaptureComplete)
			print("!!!! ERROR: eaCity.iOwner did not agree with OnCityKilled iPlayer")
		end
		local eaPlayer = gPlayers[iPlayer]
		if eaCity.holyCityFor and eaCity.holyCityFor[RELIGION_ANRA] then
			gWorld.bAnraHolyCityExists = false			--can test ==false if we need to know if it ever existed
			if not eaPlayer.bIsFallen then
				eaPlayer.fallenFollowersDestr = (eaPlayer.fallenFollowersDestr or 0) + 50 --last owner gets credit for razing
			end
		end
		gCities[iPlot] = nil		--we don't keep any info on dead cities, for now...
		gg_playerCityPlotIndexes[iPlayer][iCity] = nil

	elseif gg_init.bEnteredGame then
		error("No eaCity for a city razed to ground")
	else
		print("City razed to ground before player entered game; must be The Fay")
	end
end
local function X_OnCityKilled(iPlayer, iCity, iPlot, bCapital) return HandleError41(OnCityKilled, iPlayer, iCity, iPlot, bCapital) end
GameEvents.CityKilled.Add(X_OnCityKilled)

--------------------------------------------------------------
-- River Connections
--------------------------------------------------------------
local function CityConnections(iPlayer, bDirect) return not bDirect end
GameEvents.CityConnections.Add(CityConnections)	--register testing for "non-direct" routes

local MAP_W, MAP_H = Map.GetGridSize()
local riverManager = RiverManager:new(function(iPlot) return true end)

local function OnCityConnected(iPlayer, iCityX, iCityY, iToCityX, iToCityY, bDirect)
	--print("OnCityConnected ", iPlayer, iCityX, iCityY, iToCityX, iToCityY, bDirect)
	if g_riverDockByPlotIndex[iCityY * MAP_W + iCityX] and g_riverDockByPlotIndex[iToCityY * MAP_W + iToCityX] then
		local fromRivers = riverManager:getRivers(iCityX, iCityY)
		local toRivers = riverManager:getRivers(iToCityX, iToCityY)
		for _, iFromRiver in pairs(fromRivers) do
			for _, iToRiver in pairs(toRivers) do
				if iFromRiver == iToRiver then
					return true
				end
			end
		end
	end
	return false	
end
local function X_OnCityConnected(iPlayer, iCityX, iCityY, iToCityX, iToCityY, bDirect) return HandleError61(OnCityConnected, iPlayer, iCityX, iCityY, iToCityX, iToCityY, bDirect) end
GameEvents.CityConnected.Add(X_OnCityConnected)

local function OnCanRazeOverride() return true end
GameEvents.CanRazeOverride.Add(OnCanRazeOverride)

--------------------------------------------------------------
-- City builds
--------------------------------------------------------------

local function OnPlayerCanConstruct(iPlayer, buildingTypeID)
	--print("PazDebug OnPlayerCanConstruct ", iPlayer, buildingTypeID)
	local buildingInfo = GameInfo.Buildings[buildingTypeID]
	if buildingInfo.EaGreatPersonBuild then return false end
	local player = Players[iPlayer]
	if buildingInfo.EaPrereqPolicy and not player:HasPolicy(GameInfoTypes[buildingInfo.EaPrereqPolicy])
		and (not buildingInfo.EaPrereqOrPolicy or not player:HasPolicy(GameInfoTypes[buildingInfo.EaPrereqOrPolicy]))
		and (not buildingInfo.EaPrereqOrPolicy2 or not player:HasPolicy(GameInfoTypes[buildingInfo.EaPrereqOrPolicy2]))
		then return false end
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer then return false end
	if eaPlayer.blockedBuildingsByID[buildingTypeID] then return false end
	return true
end
local function X_OnPlayerCanConstruct(iPlayer, buildingTypeID) return HandleError21(OnPlayerCanConstruct, iPlayer, buildingTypeID) end
GameEvents.PlayerCanConstruct.Add(X_OnPlayerCanConstruct)

local processPolicyReq = {}
for processInfo in GameInfo.Processes() do
	local policyType = processInfo.EaPolicyPrereq
	if policyType then
		processPolicyReq[processInfo.ID] = GameInfoTypes[policyType]
	end
end
conversionWorldKeyByProcess = {	[PROCESS_WORLD_WEAVE] = "weaveConvertNum",
								[PROCESS_WORLD_SALVATION] = "azzConvertNum",
								[PROCESS_WORLD_CORRUPTION] = "anraConvertNum",
								[PROCESS_EA_BLESSINGS] = "livingTerrainConvertStr"	}

local function OnPlayerCanMaintain(iPlayer, processTypeID)
	--print("PazDebug OnPlayerCanMaintain ", iPlayer, processTypeID)
	if fullCivs[iPlayer] then
		local policyReqID = processPolicyReq[processTypeID]
		if policyReqID and not Players[iPlayer]:HasPolicy(policyReqID) then return false end
		local key = conversionWorldKeyByProcess[processTypeID]
		if key and 80 < gWorld[key] then return false end	--"overfill" test; apparently nothing can be converted for now
		return true
	end
	return false
end
local function X_OnPlayerCanMaintain(iPlayer, processTypeID) return HandleError21(OnPlayerCanMaintain, iPlayer, processTypeID) end
GameEvents.PlayerCanMaintain.Add(X_OnPlayerCanMaintain)

local TestCityCanConstruct = {}
local function OnCityCanConstruct(iPlayer, iCity, buildingTypeID)
	--print("PazDebug OnCityCanConstruct ", iPlayer, iCity, buildingTypeID)
	if TestCityCanConstruct[buildingTypeID] then
		return TestCityCanConstruct[buildingTypeID](iPlayer, iCity)
	end
	return true
end
local function X_OnCityCanConstruct(iPlayer, iCity, buildingTypeID) return HandleError31(OnCityCanConstruct, iPlayer, iCity, buildingTypeID) end
GameEvents.CityCanConstruct.Add(X_OnCityCanConstruct)


TestCityCanConstruct[GameInfoTypes.BUILDING_FLOATING_GARDENS] = function(iPlayer, iCity)
	local city = Players[iPlayer]:GetCityByID(iCity)
	return city:GetReligiousMajority() == RELIGION_CULT_OF_ABZU
end

TestCityCanConstruct[GameInfoTypes.BUILDING_FOREFATHERS_STATUE] = function(iPlayer, iCity)
	local city = Players[iPlayer]:GetCityByID(iCity)
	return city:GetGameTurnAcquired() < Game.GetGameTurn() - 100	--can only build 100 turns after conquest
end

TestCityCanConstruct[GameInfoTypes.BUILDING_GOVERNORS_COMPOUND] = function(iPlayer, iCity)
	local city = Players[iPlayer]:GetCityByID(iCity)
	return city:IsOccupied() and not city:IsNoOccupiedUnhappiness()
end

TestCityCanConstruct[GameInfoTypes.BUILDING_SMOKEHOUSE] = function(iPlayer, iCity)
	local player = Players[iPlayer]
	local city = player:GetCityByID(iCity)
	if city:IsHasResourceLocal(RESOURCE_DEER, false) or city:IsHasResourceLocal(RESOURCE_BOARS, false) or city:IsHasResourceLocal(RESOURCE_FUR, false) or city:IsHasResourceLocal(RESOURCE_ELEPHANT, false) then
		return true
	end
	local eaCity = gCities[city:Plot():GetPlotIndex()]
	if not eaCity then return false end
	local bFoundRemote = false
	for iPlot in pairs(eaCity.remotePlots) do
		local plot = GetPlotByIndex(iPlot)
		if plot:GetImprovementType() == IMPROVEMENT_CAMP then
			bFoundRemote = true
			break
		end
	end
	if bFoundRemote then
		return true
	end
	return false
end

TestCityCanConstruct[GameInfoTypes.BUILDING_HUNTING_LODGE] = TestCityCanConstruct[GameInfoTypes.BUILDING_SMOKEHOUSE]

TestCityCanConstruct[GameInfoTypes.BUILDING_PORT] = function(iPlayer, iCity)
	local player = Players[iPlayer]
	local city = player:GetCityByID(iCity)
	if not city:IsHasResourceLocal(RESOURCE_FISH, false) or city:IsHasResourceLocal(RESOURCE_CRAB, false) or city:IsHasResourceLocal(RESOURCE_PEARLS, false) or city:IsHasResourceLocal(RESOURCE_WHALE, false) then
		return true
	end
	local eaCity = gCities[city:Plot():GetPlotIndex()]
	if not eaCity then return false end
	local bFoundRemote = false
	for iPlot in pairs(eaCity.remotePlots) do
		local plot = GetPlotByIndex(iPlot)
		local improvementID = plot:GetImprovementType()
		if improvementID == IMPROVEMENT_FISHING_BOATS or improvementID == IMPROVEMENT_WHALING_BOATS then
			bFoundRemote = true
			break
		end
	end
	if bFoundRemote then
		return true
	end
	return false
end

TestCityCanConstruct[GameInfoTypes.BUILDING_WHALERY] = function(iPlayer, iCity)
	local player = Players[iPlayer]
	local city = player:GetCityByID(iCity)
	if city:IsHasResourceLocal(RESOURCE_WHALE, false) then
		return true
	end
	local eaCity = gCities[city:Plot():GetPlotIndex()]
	if not eaCity then return false end
	local bFoundRemote = false
	for iPlot in pairs(eaCity.remotePlots) do	--remote ownership?
		local plot = GetPlotByIndex(iPlot)
		if plot:GetImprovementType() == IMPROVEMENT_WHALING_BOATS then
			bFoundRemote = true
			break
		end
	end
	if bFoundRemote then
		return true
	end
	return false
end


local function OnCityBuildingsIsBuildingSellable(iPlayer, buildingTypeID)
	--print("PazDebug OnCityBuildingsIsBuildingSellable ", iPlayer, buildingTypeID)
	if prohibitSellBuildings[buildingTypeID] then return false end
	return true
end
local function X_OnCityBuildingsIsBuildingSellable(iPlayer, buildingTypeID) return HandleError21(OnCityBuildingsIsBuildingSellable, iPlayer, buildingTypeID) end
GameEvents.CityBuildingsIsBuildingSellable.Add(X_OnCityBuildingsIsBuildingSellable)

g_numCaravansCanTrain = 0
g_numCargoShipsCanTrain = 0

--local TestPlayerCanTrain = {}
local function OnPlayerCanTrain(iPlayer, unitTypeID)
	--print("PazDebug OnPlayerCanTrain ", iPlayer, unitTypeID)
	if bHidden[iPlayer] then return false end		--blocks hidden civs from building any units
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer then return false end
	if eaPlayer.blockedUnitsByID[unitTypeID] then return false end

	--if unitTypeID == UNIT_CARAVAN then		--this always comes before OnCityCanTrain check so we use it to count for file local (to limit number can build in CityCanTrain)
	--	g_numCaravansCanTrain = FindOpenTradeRoute(iPlayer, DOMAIN_LAND, false)
	--	if g_numCaravansCanTrain == 0 then return false end			--most common situation
	--	g_numCaravansCanTrain = g_numCaravansCanTrain - Players[iPlayer]:GetNumAvailableTradeUnits(DOMAIN_LAND)
	--	if g_numCaravansCanTrain == 0 then return false end
	--elseif unitTypeID == UNIT_CARGO_SHIP then
	--	g_numCargoShipsCanTrain = FindOpenTradeRoute(iPlayer, DOMAIN_SEA, false)
	--	if g_numCargoShipsCanTrain == 0 then return false end	
	--	g_numCargoShipsCanTrain = g_numCargoShipsCanTrain - Players[iPlayer]:GetNumAvailableTradeUnits(DOMAIN_SEA)
	--	if g_numCargoShipsCanTrain == 0 then return false end
	--end

	--if TestPlayerCanTrain[unitTypeID] then
	--	return TestPlayerCanTrain[unitTypeID](iPlayer)
	--end
	return true
end
local function X_OnPlayerCanTrain(iPlayer, unitTypeID) return HandleError21(OnPlayerCanTrain, iPlayer, unitTypeID) end
GameEvents.PlayerCanTrain.Add(X_OnPlayerCanTrain)


local TestCityCanTrain = {}
local function OnCityCanTrain(iPlayer, iCity, unitTypeID)
	--print("PazDebug OnCityCanTrain ", iPlayer, iCity, unitTypeID)
	if TestCityCanTrain[unitTypeID] then
		return TestCityCanTrain[unitTypeID](iPlayer, iCity)
	end
	return true
end
local function X_OnCityCanTrain(iPlayer, iCity, unitTypeID) return HandleError31(OnCityCanTrain, iPlayer, iCity, unitTypeID) end
GameEvents.CityCanTrain.Add(X_OnCityCanTrain)

--[[
TestCityCanTrain[GameInfoTypes.UNIT_CARAVAN] = function(iPlayer, iCity)
	print("TestCityCanTrain[GameInfoTypes.UNIT_CARAVAN] ", iPlayer, iCity)
	--Fires after OnPlayerCanTrain; we count on this for g_numCaravansCanTrain
	--Always allow if already building, but count against allowed so other cities might be limited (note: probably not fool-proof for AI; consequence is extra trade unit which should show in Lua.log) 
	local player = Players[iPlayer]
	local city = player:GetCityByID(iCity)
	local orderType, orderID = city:GetOrderFromQueue(0)				--iterate over whole queue?
	if orderID == UNIT_CARAVAN and orderType == ORDER_TRAIN then
		g_numCaravansCanTrain = g_numCaravansCanTrain - 1
		return true
	end
	print("g_numCaravansCanTrain = ", g_numCaravansCanTrain)
	return 0 < g_numCaravansCanTrain
end

TestCityCanTrain[GameInfoTypes.UNIT_CARGO_SHIP] = function(iPlayer, iCity)
	print("TestCityCanTrain[GameInfoTypes.UNIT_CARGO_SHIP] ", iPlayer, iCity)
	local player = Players[iPlayer]
	local city = player:GetCityByID(iCity)
	local orderType, orderID = city:GetOrderFromQueue(0)				--iterate over whole queue?
	if orderID == UNIT_CARGO_SHIP and orderType == ORDER_TRAIN then
		g_numCargoShipsCanTrain = g_numCargoShipsCanTrain - 1
		return true
	end
	print("g_numCargoShipsCanTrain = ", g_numCargoShipsCanTrain)
	return 0 < g_numCargoShipsCanTrain
end
]]


TestCityCanTrain[GameInfoTypes.UNIT_SETTLERS_MAN] = function(iPlayer, iCity)
	local player = Players[iPlayer]
	if player:GetHappiness() <= VERY_UNHAPPY_THRESHOLD then		--TO DO: IS THIS RIGHT?????!!!!! (should do player test first to save time)
		local city = player:GetCityByID(iCity)
		if city:GetNumBuilding(BUILDING_SLAVE_BREEDING_PEN) < 1 then return false end
	end
	return true
end
TestCityCanTrain[GameInfoTypes.UNIT_SETTLERS_SIDHE] = TestCityCanTrain[GameInfoTypes.UNIT_SETTLERS_MAN]
TestCityCanTrain[GameInfoTypes.UNIT_SETTLERS_ORC] = TestCityCanTrain[GameInfoTypes.UNIT_SETTLERS_MAN]

TestCityCanTrain[GameInfoTypes.UNIT_HUNTERS] = function(iPlayer, iCity)
	local iCityPlot = gg_playerCityPlotIndexes[iPlayer][iCity] or InitCityPlotIndexGlobals(iPlayer, iCity)
	local campRange = gg_campRange[iPlayer]
	for iPlot, type in pairs(gg_remoteImprovePlot) do
		if type  == "HuntingRes" then
			local dist = GetMemoizedPlotIndexDistance(iPlot, iCityPlot)
			if dist <= campRange then
				local plot = GetPlotByIndex(iPlot)
				local iOwner = plot:GetOwner()
				if iOwner == -1 or (iOwner == iPlayer and plot:GetImprovementType() == -1) then
					return true
				end
				if dist < 4 then		--resource is nearby for this city, so could steal from a remote owner
					local iOwningCity = plot:GetCityPurchaseID()
					local iPlotOwningCity = gg_playerCityPlotIndexes[iOwner][iOwningCity] or InitCityPlotIndexGlobals(iOwner, iOwningCity)
					local ownerDist = GetMemoizedPlotIndexDistance(iPlot, iPlotOwningCity)
					if 3 < ownerDist then
						if iOwner == iPlayer then
							plot:SetOwner(iPlayer, iCity)	--transfer ownership to this city (should have happened elsewhere, but just in case)
						else
							return true		--steal from remote owner city
						end				
					end
				end
			end
		end
	end
	return false
end

TestCityCanTrain[GameInfoTypes.UNIT_FISHING_BOATS] = function(iPlayer, iCity)
	local iCityPlot = gg_playerCityPlotIndexes[iPlayer][iCity] or InitCityPlotIndexGlobals(iPlayer, iCity)
	local bCoastal = gg_cityPlotCoastalTest[iCityPlot]

	if not gg_cityPlotCoastalTest[iCityPlot] then return false end
	local fishingRange = gg_fishingRange[iPlayer]
	for iPlot, type in pairs(gg_remoteImprovePlot) do
		if type == "Lake" then		--no stealing
			local dist = GetMemoizedPlotIndexDistance(iPlot, iCityPlot)
			if dist < 4 and iOwner == -1 or (iOwner == iPlayer and plot:GetImprovementType() == -1) then
				return true
			end
		elseif bCoastal and type == "FishingRes" then
			local dist = GetMemoizedPlotIndexDistance(iPlot, iCityPlot)
			if dist <= fishingRange then
				local plot = GetPlotByIndex(iPlot)
				local iOwner = plot:GetOwner()
				if iOwner == -1 or (iOwner == iPlayer and plot:GetImprovementType() == -1) then
					return true
				end
				if dist < 4 then		--resource is nearby for this city, so could steal from a remote owner
					local iOwningCity = plot:GetCityPurchaseID()
					local iPlotOwningCity = gg_playerCityPlotIndexes[iOwner][iOwningCity] or InitCityPlotIndexGlobals(iOwner, iOwningCity)
					local ownerDist = GetMemoizedPlotIndexDistance(iPlot, iPlotOwningCity)
					if 3 < ownerDist then
						if iOwner == iPlayer then
							plot:SetOwner(iPlayer, iCity)	--transfer ownership to this city (should have happen elsewhere, but just in case)
						else
							return true		--steal from remote owner city
						end				
					end
				end
			end
		end
	end
	return false
end

TestCityCanTrain[GameInfoTypes.UNIT_WHALING_BOATS] = function(iPlayer, iCity)
	local iCityPlot = gg_playerCityPlotIndexes[iPlayer][iCity] or InitCityPlotIndexGlobals(iPlayer, iCity)
	if not gg_cityPlotCoastalTest[iCityPlot] then return false end
	local whalingRange = gg_whalingRange[iPlayer]
	for iPlot, type in pairs(gg_remoteImprovePlot) do
		if type == "WhalingRes" then
			local dist = GetMemoizedPlotIndexDistance(iPlot, iCityPlot)
			if dist <= whalingRange then
				local plot = GetPlotByIndex(iPlot)
				local iOwner = plot:GetOwner()
				if iOwner == -1 or (iOwner == iPlayer and plot:GetImprovementType() == -1) then
					return true
				end
				if dist < 4 then		--resource is nearby for this city, so could steal from a remote owner
					local iOwningCity = plot:GetCityPurchaseID()
					local iPlotOwningCity = gg_playerCityPlotIndexes[iOwner][iOwningCity] or InitCityPlotIndexGlobals(iOwner, iOwningCity)
					local ownerDist = GetMemoizedPlotIndexDistance(iPlot, iPlotOwningCity)
					if 3 < ownerDist then
						if iOwner == iPlayer then
							plot:SetOwner(iPlayer, iCity)	--transfer ownership to this city (should have happen elsewhere, but just in case)
						else
							return true		--steal from remote owner city
						end				
					end
				end
			end
		end
	end
	return false
end


--Some others we might use:
--GameEvents.PlayerCanMaintain(playerID, processTypeID); (TestAll)
--GameEvents.PlayerCanPrepare(playerID, specialistTypeID); (TestAll)
--GameEvents.PlayerCanCreate(playerID, projectTypeID); (TestAll)
--GameEvents.CityCanBuyAnyPlot(ownerID, cityID) (TestAll)
--GameEvents.CityCanBuyPlot(ownerID, cityID, plotX, plotY) (TestAll)
--GameEvents.CityCanCreate(ownerID, cityID, projectTypeID); (TestAll)
--GameEvents.CityCanMaintain(ownerID, cityID, processTypeID); (TestAll)
--GameEvents.CityCanPrepare(ownerID, cityID, specialistTypeID); (TestAll)
--GameEvents.CityCanTrain(ownerID, cityID, unitTypeID); (TestAll)






----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)