-- EaVictoriesHelper
-- Author: Pazyryk
-- DateCreated: 2/14/2014 8:31:46 AM
--------------------------------------------------------------

MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

local floor = math.floor

--Note: bVictory does not always mean THIS player wins. TestUpdateVictory tests other players in cases where score could determine winner.

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
	
	local manaConsumed = eaPlayer.manaConsumed or 0
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
	local eaPlayer = gT.gPlayers[iPlayer]

	local livingTerrainAdded = eaPlayer.livingTerrainAdded or 0
	local livingTerrainStrengthAdded = eaPlayer.livingTerrainStrengthAdded or 0
	local aveWorldLivingTerrainStrength = MapModData.totalLivingTerrainStrength / MapModData.validForestJunglePlots
	local harmonicMean = (MapModData.validForestJunglePlots / MapModData.harmonicMeanDenominator) - 1
	local hmNeeded = (gT.gWorld.panCivsEver + 2) * 400 / MapModData.validForestJunglePlots


	--Generate score
	local score = floor(livingTerrainAdded + livingTerrainStrengthAdded / 5)

	--Test victory conditions
	local bVictory = score > 0 and harmonicMean >= hmNeeded

	return score, bVictory, livingTerrainAdded, livingTerrainStrengthAdded, harmonicMean, hmNeeded
end

function GetSubduerVictoryData(iPlayer)
	local player = Players[iPlayer]
	local eaPlayer = gT.gPlayers[iPlayer]

	local playerPopulation = player:GetTotalPopulation()
	local worldPopulation = 100 * playerPopulation / Game.GetTotalPopulation()
	local worldLand = 100 * player:GetTotalLand() / MapModData.ownablePlots
	local aveWorldLivingTerrainStrength = MapModData.totalLivingTerrainStrength / MapModData.validForestJunglePlots
	

	--Generate score
	local score = floor(playerPopulation + 10 * worldLand)

	--Test victory conditions
	local bVictory = worldPopulation > 70 and worldLand > 40 and aveWorldLivingTerrainStrength < 1 

	return score, bVictory, worldPopulation, worldLand, aveWorldLivingTerrainStrength
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