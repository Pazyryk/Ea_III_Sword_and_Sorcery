-- EaAIUnits
-- Author: Pazyryk
-- DateCreated: 12/13/2012 7:16:50 PM
--------------------------------------------------------------
print("Loading EaAIUnits.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end


local fullCivs = MapModData.fullCivs
local gg_unitPositions = gg_unitPositions
local gg_unitClusters = gg_unitClusters
local gCities = gCities

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaAIUnitsInit(bNewGame)
	print("Running EaAIUnitsInit...")
	if not bNewGame then
		for iPlayer in pairs(fullCivs) do
			AnalyzeUnitClusters(iPlayer)		--sets gg_unitClusters info for all players
		end
	end
end




--------------------------------------------------------------
-- Unit Clustering
--------------------------------------------------------------
-- This function tries to figure out what iPlayer's units are up to and records this in gg_unitClusters
-- gg_unitClusters is used by GP AI logic to know if self is deploying somewhere or if other civ is threatening
-- We only look at major civ unit clusters (GP should join own unit cluster if attacking, but won't ever see CS unit cluster as threat)

function AnalyzeUnitClusters(iPlayer)	--called by AfterPlayerTurn
	print("Running AnalyzeUnitClusters for player ", iPlayer)
	local player = Players[iPlayer]
	local iTeam = player:GetTeam()
	local team = Teams[iTeam]
	local unitPositions = gg_unitPositions[iPlayer]
	local count = 0
	for unit in player:Units() do
		if unit:IsCombatUnit() then
			count = count + 1
			unitPositions[count] = {x = unit:GetX(), y = unit:GetY(), cluster = 0, boss = false}	--boss is threat even if not in cluster
		end
	end
	for i = #unitPositions, count + 1, -1 do
		unitPositions[i] = nil
	end

	--Get unit clusters and cluster<->city distance matrix (methods in EaMathUtils.lua)
	local clusters = DBSCAN_Cluster(unitPositions, 4, 4)	--last two are eps and minPts (see DBSCAN wiki)
	local clusterCityDistMatrix = GetDistanceMatrix(clusters, gCities)
	gg_unitClusters[iPlayer] = clusters

	--Cycle through each unit cluster and mark it Hostile or PossibleSneak with putative targets
	for i = 1, #clusters do
		print("Analyzing cluster # ", i)
		local cluster = clusters[i]
		local clusterCityDistances = clusterCityDistMatrix[i]
		local closestOwn, closestForeign, closestEnemy
		local closestOwnDist, closestForeignDist, closestEnemyDist = 1000, 1000, 1000
		for eaCityIndex = 1, #clusterCityDistances do		--has same dimention as gCities
			local eaCity = gCities[eaCityIndex]
			if 0 < eaCity.size then
				local distance = clusterCityDistances[eaCityIndex]
				local iOwner = eaCity.iOwner
				local iOwnerTeam = Players[iOwner]:GetTeam()
				if iOwnerTeam == iTeam then
					if distance < closestOwnDist then
						closestOwnDist = distance
						closestOwn = eaCityIndex
					end
				elseif team:IsAtWar(iOwnerTeam) then
					if distance < closestEnemyDist then
						closestEnemyDist = distance
						closestEnemy = eaCityIndex
					end
				else
					if distance < closestForeignDist then
						closestForeignDist = distance
						closestForeign = eaCityIndex
					end
				end
			end
		end

		--Threat logic here (AI GPs with any combat role look at gg_unitClusters)
		if closestEnemyDist < 10 or closestEnemyDist < closestOwnDist then
			cluster.intent = "Hostile"
			local eaCity = gCities[closestEnemy]
			cluster.iPlayerTarget = eaCity.iOwner
			cluster.iPlotTarget = closestEnemy
			print("Marking cluster as Hostile ", closestEnemyDist, closestOwnDist, cluster.iPlayerTarget, cluster.iPlotTarget)
		elseif closestForeignDist < 10 and closestForeignDist < closestOwnDist then
			cluster.intent = "PossibleSneak"
			local eaCity = gCities[closestForeign]
			cluster.iPlayerTarget = eaCity.iOwner
			cluster.iPlotTarget = closestForeign
			print("Marking cluster as PossibleSneak ", closestForeignDist, closestOwnDist, cluster.iPlayerTarget, cluster.iPlotTarget)
		else
			print("Cluster does not seem to be a threat to anyone")
		end
	end
end

