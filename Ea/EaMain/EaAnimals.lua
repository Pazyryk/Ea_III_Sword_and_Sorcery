-- EaAnimals
-- Author: Pazyryk
-- DateCreated: 2/10/2014 6:16:43 PM
--------------------------------------------------------------

print("Loading EaAnimals.lua...")
local print = ENABLE_PRINT and print or function() end

-- Animal packs spawn in unowned / unviewed land and in the land of players with Feral Bond

-- Single-unit animals spawn next to GPs only if near pack

--------------------------------------------------------------
-- Settings
--------------------------------------------------------------

local ANIMAL_SPAWN_SPACER = 750		--animals spawn every [random(1 to value) plots * (number existing animals + 10) ^ 3 / 1000] plots from all available plots 
local ANIMAL_ONE_IN_DEATH_CHANCE = 20

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

local ANIMALS_PLAYER_INDEX =				ANIMALS_PLAYER_INDEX

local PLOT_OCEAN =							PlotTypes.PLOT_OCEAN
local PLOT_LAND =							PlotTypes.PLOT_LAND
local PLOT_HILLS =							PlotTypes.PLOT_HILLS
local PLOT_MOUNTAIN =						PlotTypes.PLOT_MOUNTAIN

local TERRAIN_GRASS =						GameInfoTypes.TERRAIN_GRASS
local TERRAIN_PLAINS =						GameInfoTypes.TERRAIN_PLAINS
local TERRAIN_TUNDRA =						GameInfoTypes.TERRAIN_TUNDRA
local TERRAIN_SNOW =						GameInfoTypes.TERRAIN_SNOW
local TERRAIN_DESERT =						GameInfoTypes.TERRAIN_DESERT

local FEATURE_ICE =							GameInfoTypes.FEATURE_ICE
local FEATURE_FOREST = 						GameInfoTypes.FEATURE_FOREST
local FEATURE_JUNGLE = 						GameInfoTypes.FEATURE_JUNGLE
local FEATURE_MARSH =	 					GameInfoTypes.FEATURE_MARSH

local UNIT_WOLVES =							GameInfoTypes.UNIT_WOLVES
local UNIT_GRIFFONS =						GameInfoTypes.UNIT_GRIFFONS
local UNIT_KRAKEN =							GameInfoTypes.UNIT_KRAKEN

local POLICY_FERAL_BOND =					GameInfoTypes.POLICY_FERAL_BOND
local POLICY_ANIMAL_MASTERS =				GameInfoTypes.POLICY_ANIMAL_MASTERS

local Players =								Players
local fullCivs =							MapModData.fullCivs
local gg_animalSpawnPlots =					gg_animalSpawnPlots
local gg_animalSpawnInhibitTeams =			gg_animalSpawnInhibitTeams

local Rand =								Map.Rand
local GetPlotByIndex =						Map.GetPlotByIndex
local floor =								math.floor

local g_prefScoreByAnimal = {}

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------

local animalUnitTypeIDs = {}
for unitInfo in GameInfo.Units() do
	if unitInfo.EaSpecial == "Animal" or unitInfo.EaSpecial == "Beast" then
		animalUnitTypeIDs[unitInfo.ID] = true
	end
end

local animalWeightByUnitByPref = {}
for row in GameInfo.EaAnimal_Prefs() do
	local unitTypeID = GameInfoTypes[row.UnitType]
	animalWeightByUnitByPref[unitTypeID] = animalWeightByUnitByPref[unitTypeID] or {}
	animalWeightByUnitByPref[unitTypeID][row.Preference] = row.Weight
	g_prefScoreByAnimal[unitTypeID] = 0
end
--------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------

local function GetAnimalForPlot(focalPlot)		-- Preferences set in EaAnimals.sql

	--quick answer if focalPlot limiting
	local focalPlotTypeID = focalPlot:GetPlotType()
	if focalPlotTypeID == PLOT_MOUNTAIN then
		return UNIT_GRIFFONS
	elseif focalPlotTypeID == PLOT_OCEAN then
		return UNIT_KRAKEN
	end

	--local nOcean = 0
	--local nCoast = 0
	local nMountain = 0
	--exclusive grouping 1
	local nDesert = 0
	local nColdTerrain = 0
	local nOpenGrassPlains = 0	--flat, no feature
	--exclusive grouping 2
	local nForest = 0
	local nJungle = 0

	for unitTypeID in pairs(g_prefScoreByAnimal) do
		g_prefScoreByAnimal[unitTypeID] = 0
	end

	for plot in PlotAreaSpiralIterator(focalPlot, 3, 1, true, false, true) do
		local plotTypeID = plot:GetPlotType()
		local terrainID = plot:GetTerrainType()
		local featureID = plot:GetFeatureType()
		if plotTypeID == PLOT_MOUNTAIN then
			nMountain = nMountain + 1
		else
			if terrainID == TERRAIN_DESERT then
				nDesert = nDesert + 1
			elseif terrainID == TERRAIN_TUNDRA or terrainID == TERRAIN_SNOW then
				nColdTerrain = nColdTerrain + 1
			elseif plotTypeID == PLOT_LAND and featureID == -1 and (terrainID == TERRAIN_GRASS or terrainID == TERRAIN_PLAINS) then
				nOpenGrassPlains = nOpenGrassPlains + 1
			end
			if featureID == FEATURE_FOREST then
				nForest = nForest + 1
			elseif featureID == FEATURE_JUNGLE then
				nJungle = nJungle + 1
			end		
		end

	end

	--print(" -nColdTerrain, nOpenGrassPlains, nForest, nJungle = ", nColdTerrain, nOpenGrassPlains, nForest, nJungle)

	for unitTypeID, prefs in pairs(animalWeightByUnitByPref) do
		for pref, weight in pairs(prefs) do
			if pref == "Mountain" then
				g_prefScoreByAnimal[unitTypeID] = g_prefScoreByAnimal[unitTypeID] + (nMountain * weight)
			elseif pref == "Desert" then
				g_prefScoreByAnimal[unitTypeID] = g_prefScoreByAnimal[unitTypeID] + (nDesert * weight)
			elseif pref == "ColdTerrain" then
				g_prefScoreByAnimal[unitTypeID] = g_prefScoreByAnimal[unitTypeID] + (nColdTerrain * weight)
			elseif pref == "OpenGrassPlains" then
				g_prefScoreByAnimal[unitTypeID] = g_prefScoreByAnimal[unitTypeID] + (nOpenGrassPlains * weight)
			elseif pref == "Forest" then
				g_prefScoreByAnimal[unitTypeID] = g_prefScoreByAnimal[unitTypeID] + (nForest * weight)
			elseif pref == "Jungle" then
				g_prefScoreByAnimal[unitTypeID] = g_prefScoreByAnimal[unitTypeID] + (nJungle * weight)
			end
		end
	end

	local bestUnitTypeID = UNIT_WOLVES			--fallback type
	local bestScore = -9999
	for unitTypeID, score in pairs(g_prefScoreByAnimal) do
		if bestScore < score then
			bestScore = score
			bestUnitTypeID = unitTypeID
		end
	end

	print(" -Best animal for plot is ", GameInfo.Units[bestUnitTypeID].Type)

	return bestUnitTypeID
end
--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function AnimalsPerTurn()	--Runs after PlotsPerTurn() so we have current info in gg_animalSpawnPlots
	print("Running AnimalsPerTurn")
	local animals = Players[ANIMALS_PLAYER_INDEX]
	local numAnimalSpawnPlots = gg_animalSpawnPlots.pos
	local numAnimals = 0
	for unit in animals:Units() do
		if Rand(ANIMAL_ONE_IN_DEATH_CHANCE, "hello") < 1 then
			-- We have a death chance for animals so they don't build up too much in isolated areas; but they only die out of sight
			local plot = unit:GetPlot()
			local bKill = true
			for i = 1, #gg_animalSpawnInhibitTeams do	--make sure no enemy full civs can see
				if 0 < plot:GetVisibilityCount(gg_animalSpawnInhibitTeams[i]) then
					bKill = false
					break
				end
			end
			if bKill then
				unit:Kill(true, -1)
			else
				numAnimals = numAnimals + 1
			end
		else
			if 0 < unit:GetDamage() then
				-- Heal 5 hp if no enemies can see
				local plot = unit:GetPlot()
				local bHeal = true
				for i = 1, #gg_animalSpawnInhibitTeams do	--make sure no enemy full civs can see
					if 0 < plot:GetVisibilityCount(gg_animalSpawnInhibitTeams[i]) then
						bHeal = false
						break
					end
				end
				if bHeal then
					unit:ChangeDamage(-5, -1)
					print("Animal trying to heal; damage, moves = ", unit:GetDamage(), unit:GetMoves())
					unit:FinishMoves()			--this might not work since not animal turn yet
				end
			end
			numAnimals = numAnimals + 1		
		end
	end
	for iPlayer, eaPlayer in pairs(fullCivs) do			-- count captured animals against the total
		local player = Players[iPlayer]
		if player:HasPolicy(POLICY_FERAL_BOND) or player:HasPolicy(POLICY_ANIMAL_MASTERS) then	--only these civs could ever own an animal unit
			for unit in player:Units() do
				if animalUnitTypeIDs[unit:GetUnitType()] then
					numAnimals = numAnimals + 1	
				end
			end
		end
	end

	-- Pick plots from gg_animalSpawnPlots randomly, then figure out what to spawn by local geography
	local maxSpawnSpacing = floor(ANIMAL_SPAWN_SPACER * (numAnimals + 10) ^ 3 / 1000)
	print("Number available spawn plots / number animals / maxSpawnSpacing = ", numAnimalSpawnPlots, numAnimals, maxSpawnSpacing)

	local plotNumber = Rand(maxSpawnSpacing, "hello") + 1
	while plotNumber <= numAnimalSpawnPlots do
		local iPlot = gg_animalSpawnPlots[plotNumber]
		local plot = GetPlotByIndex(iPlot)
		if GetPlotForSpawn(plot, ANIMALS_PLAYER_INDEX, 0, false, false, plot:IsWater(), true, false, true) then	--safety test
			local x, y = plot:GetXY()
			local animalUnitTypeID = GetAnimalForPlot(plot)
			animals:InitUnit(animalUnitTypeID, x, y)
		end
		plotNumber = plotNumber + Rand(maxSpawnSpacing, "hello") + 1
	end
end


--team:
--	DeclareWar(TeamID team)
--  MakePeace(TeamID team)
--
--  int	GetAtWarCount(bool ignoreMinors)
--  SetPermanentWarPeace(TeamID index, bool newValue)
--
--
--plot:
--  int	GetNumVisibleEnemyDefenders(Unit unit)
--  int	GetNumVisiblePotentialEnemyDefenders(Unit unit)
--  bool	IsAdjacentNonvisible(TeamID team)
--  bool	IsAdjacentVisible(TeamID team, bool debug)
--  int	IsVisible(TeamID team, bool debug)
--  int	IsVisibleEnemyUnit(PlayerID player)
--  bool	IsVisibleOtherUnit(PlayerID player)
--
--  int GetVisibilityCount(iTeam)