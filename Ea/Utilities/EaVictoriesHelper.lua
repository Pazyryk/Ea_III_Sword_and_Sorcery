-- EaVictoriesHelper
-- Author: Pazyryk
-- DateCreated: 2/14/2014 8:31:46 AM
--------------------------------------------------------------

MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT


local ONE_W_NATURE_VC_LT_COVERAGE =						MapModData.EaSettings.ONE_W_NATURE_VC_LT_COVERAGE
local ONE_W_NATURE_VC_LT_AVE_STR =						MapModData.EaSettings.ONE_W_NATURE_VC_LT_AVE_STR
local ONE_W_NATURE_PAN_CIV_RATIO_COVERAGE_EXTRA =		MapModData.EaSettings.ONE_W_NATURE_PAN_CIV_RATIO_COVERAGE_EXTRA
local ONE_W_NATURE_PAN_CIV_RATIO_AVE_STR_EXTRA =		MapModData.EaSettings.ONE_W_NATURE_PAN_CIV_RATIO_AVE_STR_EXTRA
local ONE_W_NATURE_PLOT_NUMBER_NORMALIZER =				MapModData.EaSettings.ONE_W_NATURE_PLOT_NUMBER_NORMALIZER

print("loading EaVictoriesHelper...")
print(ONE_W_NATURE_VC_LT_COVERAGE,ONE_W_NATURE_VC_LT_AVE_STR,ONE_W_NATURE_PAN_CIV_RATIO_COVERAGE_EXTRA,ONE_W_NATURE_PAN_CIV_RATIO_AVE_STR_EXTRA,ONE_W_NATURE_PLOT_NUMBER_NORMALIZER)

local DOMINATION_VC_POPULATION_PERCENT =				MapModData.EaSettings.DOMINATION_VC_POPULATION_PERCENT
local DOMINATION_VC_LAND_PERCENT =						MapModData.EaSettings.DOMINATION_VC_LAND_PERCENT
local DOMINATION_VC_IMPROVED_LAND_PERCENT =				MapModData.EaSettings.DOMINATION_VC_IMPROVED_LAND_PERCENT

local floor = math.floor

--Note: bVictory does not always mean THIS player wins. TestUpdateVictory tests other players in cases where score could determine winner.

local bInited = false

local function CalculateConstantsAfterInit()
	--transform some EaSettings into what we really need based on map initial conditions

	--normalize for plot number
	local normalizer = ONE_W_NATURE_PLOT_NUMBER_NORMALIZER / gT.gWorld.validForestJunglePlots	--more valid plots, easier criteria
	ONE_W_NATURE_VC_LT_COVERAGE = normalizer * ONE_W_NATURE_VC_LT_COVERAGE
	ONE_W_NATURE_VC_LT_AVE_STR = normalizer * ONE_W_NATURE_VC_LT_AVE_STR
	ONE_W_NATURE_PAN_CIV_RATIO_COVERAGE_EXTRA = normalizer * ONE_W_NATURE_PAN_CIV_RATIO_COVERAGE_EXTRA
	ONE_W_NATURE_PAN_CIV_RATIO_AVE_STR_EXTRA = normalizer * ONE_W_NATURE_PAN_CIV_RATIO_AVE_STR_EXTRA

	--original setting is really "what proportion of available valid (but not currently) LT plots"; now we need total proportion needed
	local initialCoverage = gT.gWorld.initialLivingTerrainPlots / gT.gWorld.validForestJunglePlots
	ONE_W_NATURE_VC_LT_COVERAGE = 100 * (initialCoverage + ONE_W_NATURE_VC_LT_COVERAGE * (1 - initialCoverage) / 100)
	ONE_W_NATURE_PAN_CIV_RATIO_COVERAGE_EXTRA = ONE_W_NATURE_PAN_CIV_RATIO_COVERAGE_EXTRA * (1 - initialCoverage)
	ONE_W_NATURE_VC_LT_AVE_STR = ONE_W_NATURE_VC_LT_AVE_STR + gT.gWorld.initialLivingTerrainAveStr	--how much to add to original

	--final coverage criteria will be capped below

	print("EaVictoriesHelper: CalculateConstantsAfterMapInit")
	print("normalizer, initialCoverage = ", normalizer, initialCoverage)
	print(ONE_W_NATURE_VC_LT_COVERAGE, ONE_W_NATURE_VC_LT_AVE_STR, ONE_W_NATURE_PAN_CIV_RATIO_COVERAGE_EXTRA, ONE_W_NATURE_PAN_CIV_RATIO_AVE_STR_EXTRA, ONE_W_NATURE_PLOT_NUMBER_NORMALIZER)

	--Caution! file included from >1 state, so needs to init in each
end

function GetProtectorVictoryData(iPlayer)
	local eaPlayer = gT.gPlayers[iPlayer]
	
	local protectorProphsRituals = eaPlayer.protectorProphsRituals or 0
	local civsCorrected = eaPlayer.civsCorrected or 0
	if eaPlayer.civsCorrectedProvisional then
		for iLoopPlayer, pts in pairs(eaPlayer.civsCorrectedProvisional) do
			civsCorrected = civsCorrected + pts
		end
	end
	local fallenFollowersDestr = eaPlayer.fallenFollowersDestr or 0

	--Generate score
	local score = protectorProphsRituals + civsCorrected + fallenFollowersDestr

	--Test victory conditions
	local bVictory = score > 0 and gT.gWorld.bEnableProtectorVC

	return score, bVictory, protectorProphsRituals, civsCorrected, fallenFollowersDestr
end

function GetDestroyerVictoryData(iPlayer)
	local eaPlayer = gT.gPlayers[iPlayer]
	
	local manaConsumed = eaPlayer.manaConsumed
	local manaStored = 0
	if not eaPlayer.bUsesDivineFavor then
		manaStored = Players[iPlayer]:GetFaith()
	end
	local sumOfAllMana = gT.gWorld.sumOfAllMana

	--Generate score
	local score = floor(manaConsumed ^ 0.5)

	--Test victory conditions (< 1% mana remaining)
	local bVictory = score > 0 and gT.gWorld.armageddonStage == 12

	return score, bVictory, manaConsumed, manaStored, sumOfAllMana
end

function GetRestorerVictoryData(iPlayer)

	if not bInited then
		CalculateConstantsAfterInit()
		bInited = true
	end

	local eaPlayer = gT.gPlayers[iPlayer]
	
	local fractionPanCivsEver = gT.gWorld.panCivsEver / gT.gWorld.fullCivsEver
	local wldWideLivTerrainVC = floor(ONE_W_NATURE_VC_LT_COVERAGE + ONE_W_NATURE_PAN_CIV_RATIO_COVERAGE_EXTRA * fractionPanCivsEver)
	wldWideLivTerrainVC = wldWideLivTerrainVC < 80 and wldWideLivTerrainVC or 80
	local wldWideLTAveStrVC = ONE_W_NATURE_VC_LT_AVE_STR + ONE_W_NATURE_PAN_CIV_RATIO_AVE_STR_EXTRA * fractionPanCivsEver

	local livingTerrainAdded = eaPlayer.livingTerrainAdded or 0
	local livingTerrainStrengthAdded = eaPlayer.livingTerrainStrengthAdded or 0

	local wldWideLivTerrain = 100 * MapModData.totalLivingTerrainPlots / gT.gWorld.validForestJunglePlots
	local wldWideLTAveStr = MapModData.totalLivingTerrainStrength / gT.gWorld.validForestJunglePlots

	--Generate score
	local score = floor(livingTerrainAdded + livingTerrainStrengthAdded / 5)

	--Test victory conditions
	local bVictory = score > 0 and wldWideLivTerrain >= wldWideLivTerrainVC and wldWideLTAveStr >= wldWideLTAveStrVC

	--score, bVictory, livingTerrainStrengthAdded, wldWideLivTerrain, wldWideLTAveStr, wldWideLivTerrainVC, wldWideLTAveStrVC
	return score, bVictory, livingTerrainStrengthAdded, wldWideLivTerrain, wldWideLTAveStr, wldWideLivTerrainVC, wldWideLTAveStrVC
end

function GetSubduerVictoryData(iPlayer)
	local player = Players[iPlayer]
	local eaPlayer = gT.gPlayers[iPlayer]

	local playerPopulation = player:GetTotalPopulation()
	local totalWorldPopulation = Game.GetTotalPopulation()
	totalWorldPopulation = totalWorldPopulation < 1 and 1 or totalWorldPopulation
	local worldPopulation = 100 * playerPopulation / totalWorldPopulation
	local worldLand = 100 * player:GetTotalLand() / gT.gWorld.ownablePlots
	local ownImproved = 100 * eaPlayer.improvedPlots / eaPlayer.improvablePlots
	--local aveWorldLivingTerrainStrength = MapModData.totalLivingTerrainStrength / gT.gWorld.validForestJunglePlots
	
	--Generate score
	local score = floor(playerPopulation + 10 * worldLand)

	--Test victory conditions
	local bVictory = worldPopulation >= DOMINATION_VC_POPULATION_PERCENT and worldLand >= DOMINATION_VC_LAND_PERCENT and ownImproved >= DOMINATION_VC_IMPROVED_LAND_PERCENT 

	return score, bVictory, worldPopulation, worldLand, ownImproved, DOMINATION_VC_POPULATION_PERCENT, DOMINATION_VC_LAND_PERCENT, DOMINATION_VC_IMPROVED_LAND_PERCENT
end

function GetConquerorVictoryData(iPlayer)
	local eaPlayer = gT.gPlayers[iPlayer]

	local conqueredPopulation = 0
	local conqueredCities = 0

	for key, population in pairs(eaPlayer.conquests) do
		conqueredPopulation = conqueredPopulation + population
		conqueredCities = conqueredCities + 1
	end
	
	local uncontrolledCities = 0
	for iLoopPlayer in pairs(MapModData.fullCivs) do
		if iLoopPlayer ~= iPlayer then
			local loopPlayer = Players[iLoopPlayer]
			uncontrolledCities = uncontrolledCities + loopPlayer:GetNumCities()
		end
	end
	for iLoopPlayer in pairs(MapModData.cityStates) do
		local loopPlayer = Players[iLoopPlayer]
		if loopPlayer:GetAlly() == iPlayer then
			uncontrolledCities = uncontrolledCities + loopPlayer:GetNumCities()
		end
	end

	--Generate score
	local score = 50 * conqueredCities + 10 * conqueredPopulation

	--Test victory conditions
	local bVictory = uncontrolledCities < 1 and Game.GetGameTurn() > 5

	return score, bVictory, conqueredPopulation, conqueredCities, uncontrolledCities
end