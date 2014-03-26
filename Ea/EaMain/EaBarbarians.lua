-- EaBarbarians (this file used in Ea)
-- Author: Pazyryk
-- DateCreated: 7/21/2013 8:27:13 AM
--------------------------------------------------------------
print("Loading EaBarbarians.lua...")

local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- Settings
--------------------------------------------------------------
local TURN_CEILING = 300						--stop increasing barb threat at this turn
local ENCAMPMENT_HEALING = 10

--Roaming land units
local ROAM_SPAWN_MULTIPLIER = 1.5				--Raise for faster spawning
local ROAM_TURN_EXPONENT = 1					--Raise to increase spawning as a function of turn number
local ROAM_DENSITY_FEEDBACK_EXPONENT = 3		--Raise to increase negative feedback from area density
local ROAM_POWER_FEEDBACK_EXPONENT = 2			--Raise to increase negative feedback from unit power (less ogers compared to goblins)

--Sea units
local SEA_SPAWN_MULTIPLIER = 1.5
local SEA_TURN_EXPONENT = 1					
local SEA_DENSITY_FEEDBACK_EXPONENT = 3	
local SEA_POWER_FEEDBACK_EXPONENT = 1.4
local USE_MINIMUM_PIRATE_COVE_NUMBER = 4
local USE_MAXIMUM_PIRATE_COVE_NUMBER = 10

if Game.IsOption(GameOptionTypes.GAMEOPTION_RAGING_BARBARIANS) then
	ROAM_SPAWN_MULTIPLIER = ROAM_SPAWN_MULTIPLIER * 2
	SEA_SPAWN_MULTIPLIER = SEA_SPAWN_MULTIPLIER * 2
	ROAM_TURN_EXPONENT = ROAM_TURN_EXPONENT * 1.5
	SEA_TURN_EXPONENT = SEA_TURN_EXPONENT * 1.5
	ROAM_DENSITY_FEEDBACK_EXPONENT = ROAM_DENSITY_FEEDBACK_EXPONENT / 1.5
	SEA_DENSITY_FEEDBACK_EXPONENT = SEA_DENSITY_FEEDBACK_EXPONENT / 1.5
	ROAM_POWER_FEEDBACK_EXPONENT = ROAM_POWER_FEEDBACK_EXPONENT / 1.5
	SEA_POWER_FEEDBACK_EXPONENT = SEA_POWER_FEEDBACK_EXPONENT / 1.5
end

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------

local BARB_PLAYER_INDEX =					BARB_PLAYER_INDEX

local IMPROVEMENT_BARBARIAN_CAMP =			GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP
local EA_ENCAMPMENT_ORCS =					GameInfoTypes.EA_ENCAMPMENT_ORCS

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

local Players =		Players
local gWorld =		gWorld

local Rand =					Map.Rand
local Floor =					math.floor
local GetPlotFromXY =			Map.GetPlot
local GetPlotByIndex =			Map.GetPlotByIndex
local GetXYFromPlotIndex =		GetXYFromPlotIndex
local PlotToRadiusIterator =	PlotToRadiusIterator




local g_barbTechs = {}					--index by techID; nil means not relevant for barbs, false means no one has yet, true means barbs have tech (or have it as far as mod is concered)
local g_encampmentsByArea = {}			--index by encampmentID, iArea; holds encampment number in area from that encampment type
--local g_barbsByArea = {}

local g_barbsByEncampmentTypeByArea = {}		--index by encampmentID, iArea; holds barb number in area from that encampment type

local g_currentBaseUnit1 = {}			--index by encampmentID; holds unitTypeID
local g_currentBaseUnit2 = {}
local g_currentRoamingUnit1 = {}
local g_currentRoamingUnit2 = {}
local g_currentSeaUnit1 = {}
local g_currentSeaUnit2 = {}

local numEncampmentTypes = 0

--------------------------------------------------------------
-- Cached Tables and Table Inits
--------------------------------------------------------------
--local techEncampments = {}				--index by techID, encampmentID;   =true

local encampmentTech = {}
local techUpgradeFromEncampments = {}	--index by techID, fromEncampmentID
local useWorldDensity = {}
local barbUnitPower = {}	--use cost as proxy for unit power
--local unitEncampment = {}	--used to associate unitID back to encampmentID for density calculation (only need roaming and sea units here, which should have unique association)
--MapModData.unitEncampment = unitEncampment	--for UI

for encampmentInfo in GameInfo.EaEncampments() do
	local id = encampmentInfo.ID
	if encampmentInfo.PrereqTech then
		local techID = GameInfoTypes[encampmentInfo.PrereqTech]
		g_barbTechs[techID] = false		--sets this tech as relevant for barbs
		encampmentTech[id] = techID
		--techEncampments[techID] = techEncampments[techID] or {}
		--techEncampments[techID][encampmentInfo.ID] = true
		for row in GameInfo.EaEncampments_Upgrades() do	--find all encampments that could upgrade to this type
			if encampmentInfo.Type == row.UpgradeType then
				techUpgradeFromEncampments[techID] = techUpgradeFromEncampments[techID] or {}
				techUpgradeFromEncampments[techID][GameInfoTypes[row.EncampmentType]] = true
			end
		end
	end
	g_encampmentsByArea[id] = {}
	g_barbsByEncampmentTypeByArea[id] = {}
	useWorldDensity[id] = encampmentInfo.UseWorldDensity
end
for row in GameInfo.EaEncampments_BaseUnits() do
	if row.TechType then
		g_barbTechs[GameInfoTypes[row.TechType] ] = false
	end
	local unitTypeID = GameInfoTypes[row.UnitType]
	barbUnitPower[unitTypeID] = 1
end
for row in GameInfo.EaEncampments_RoamingUnits() do
	if row.TechType then
		g_barbTechs[GameInfoTypes[row.TechType] ] = false
	end
	local unitTypeID = GameInfoTypes[row.UnitType]
	barbUnitPower[unitTypeID] = 1
	--unitEncampment[unitTypeID] = GameInfoTypes[row.EncampmentType]
end
for row in GameInfo.EaEncampments_SeaUnits() do
	if row.TechType then
		g_barbTechs[GameInfoTypes[row.TechType] ] = false
	end
	local unitTypeID = GameInfoTypes[row.UnitType]
	barbUnitPower[unitTypeID] = 1
	--unitEncampment[unitTypeID] = GameInfoTypes[row.EncampmentType]
end

local numUnits, sumPower = 0, 0
for unitTypeID in pairs(barbUnitPower) do
	local unitInfo = GameInfo.Units[unitTypeID]
	barbUnitPower[unitTypeID] = unitInfo.Cost
	numUnits = numUnits + 1
	sumPower = sumPower + unitInfo.Cost
end
local avePower = sumPower / numUnits
for unitTypeID in pairs(barbUnitPower) do
	barbUnitPower[unitTypeID] = barbUnitPower[unitTypeID] / avePower
end
numUnits, sumPower, avePower = nil, nil, nil

for k, v in pairs(g_barbTechs) do
	print("g_barbTechs", GameInfo.Technologies[k].Type)
end

local techAwardByTurn = {}
for row in GameInfo.EaEncampments_TechAwardByTurn() do
	local adjTurn = Floor(row.Turn * GAME_SPEED_MULTIPLIER * MAP_SIZE_MULTIPLIER)
	techAwardByTurn[adjTurn] = GameInfoTypes[row.TechType]
end

--------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------

local function AddEncampmentBaseUnit(iPlot, encampmentID)
	local x, y = GetXYFromPlotIndex(iPlot)
	local player = Players[BARB_PLAYER_INDEX]
	local unitTypeID = g_currentBaseUnit1[encampmentID]
	if g_currentBaseUnit2[encampmentID] and Rand(2, "hello") < 1 then
		unitTypeID = g_currentBaseUnit2[encampmentID]
	end
	print("PazDebug Adding Encampment base unit ", unitTypeID, x, y, encampmentID, GameInfo.EaEncampments[encampmentID].Type, GameInfo.Units[unitTypeID].Type)
	local unit = player:InitUnit(unitTypeID, x, y)
	if unit then
		unit:SetScenarioData(encampmentID)
	end
end

local function SpawnRoamingUnit(iPlot, unitTypeID, encampmentID)
	local x, y = GetXYFromPlotIndex(iPlot)
	for loopX, loopY in PlotToRadiusIterator(x, y, 1, nil, nil, false) do
		local loopPlot = GetPlotFromXY(loopX, loopY)
		if not loopPlot:IsUnit() and not loopPlot:IsWater() and loopPlot:GetPlotType() ~= PLOT_MOUNTAIN and not loopPlot:IsImpassable() then
			local player = Players[BARB_PLAYER_INDEX]
			print("PazDebug Adding Encampment roaming unit ", loopX, loopY, encampmentID, GameInfo.Units[unitTypeID].Type)
			local unit = player:InitUnit(unitTypeID, loopX, loopY)
			if unit then
				unit:SetScenarioData(encampmentID)
			end
			return
		end
	end
end

local function SpawnSeaUnit(iPlot, unitTypeID, encampmentID)
	local x, y = GetXYFromPlotIndex(iPlot)
	for loopX, loopY in PlotToRadiusIterator(x, y, 1, nil, nil, false) do
		local loopPlot = GetPlotFromXY(loopX, loopY)
		if not loopPlot:IsUnit() and loopPlot:IsWater() and not loopPlot:IsLake() and loopPlot:GetFeatureType() ~= FEATURE_ICE then
			local player = Players[BARB_PLAYER_INDEX]
			print("PazDebug Adding Encampment sea unit ", loopX, loopY, encampmentID, GameInfo.Units[unitTypeID].Type)
			local unit = player:InitUnit(unitTypeID, loopX, loopY)
			if unit then
				unit:SetScenarioData(encampmentID)
			end
			return
		end
	end
end

local function UpdateBaseUnit(encampmentID)			--kick out present unit if obsolete and replace with new
	print("UpdateBaseUnit for ", GameInfo.EaEncampments[encampmentID].Type)
	for iPlot, loopEncampmentID	in pairs(gWorld.encampments) do
		if loopEncampmentID == encampmentID then
			local plot = GetPlotByIndex(iPlot)
			local unitCount = plot:GetNumUnits()
			for i = 0, unitCount - 1 do
				local unit = plot:GetUnit(i)
				if unit:IsCombatUnit() and unit:GetOwner() == BARB_PLAYER_INDEX then	--we have the barb combat unit
					local unitTypeID = unit:GetUnitType()
					if unitTypeID ~= g_currentBaseUnit1[encampmentID] and unitTypeID ~= g_currentBaseUnit2[encampmentID] then	--check what's here; it might be OK
						print("Killing current encampment unit before replacement: ", GameInfo.Units[unitTypeID].Type)
						--unit:JumpToNearestValidPlot()
						MapModData.bBypassOnCanSaveUnit = true
						unit:Kill(true, -1)
						AddEncampmentBaseUnit(iPlot, encampmentID)
					end
					break
				end
			end
		end
	end
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaEncampmentsInit(bNewGame)
	print("Running EaEncampmentsInit")

	for encampmentInfo in GameInfo.EaEncampments() do
		local encampmentID = encampmentInfo.ID
		numEncampmentTypes = encampmentID
	end
	if not bNewGame then
		local team = Teams[BARB_PLAYER_INDEX]
		for techInfo in GameInfo.Technologies() do
			if g_barbTechs[techInfo.ID] == false then
				if team:IsHasTech(techInfo.ID) then
					g_barbTechs[techInfo.ID] = true
				end
			end
		end
		local gameTurn = Game.GetGameTurn()
		for row in GameInfo.EaEncampments_TechAwardByTurn() do
			for awardByTurn, techID in pairs(techAwardByTurn) do
				if awardByTurn <= gameTurn then
					g_barbTechs[techID] = true
				end
			end
		end
	end
	UpdateBarbTech(nil)
end

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

local encampmentUnitInteger = {}

function UpdateBarbTech(techID)
	if techID then
		if g_barbTechs[techID] == nil then return end		--nil means not relevant; false means don't have yet
		g_barbTechs[techID] = true
	end

	print("UpdateBarbTech for ", techID and GameInfo.Technologies[techID].Type)

	--Upgrade encampments
	if techID and techUpgradeFromEncampments[techID] then
		local encampments = gWorld.encampments
		for iPlot, encampmentID in pairs(encampments) do
			if techUpgradeFromEncampments[techID][encampmentID] then	--test all encampments that could possibly upgrade from this tech
				local x, y = GetXYFromPlotIndex(iPlot)
				local plot = GetPlotByIndex(iPlot)
				InitUpgradeEncampment(iPlot, x, y, plot, techID)
			end
		end
	end


	--Upgrade the unit types for each encampment type
	for i = 1, numEncampmentTypes do
		encampmentUnitInteger[i] = 1
	end
	for row in GameInfo.EaEncampments_BaseUnits() do
		if not row.TechType or g_barbTechs[GameInfoTypes[row.TechType]] then
			local encampmentID = GameInfoTypes[row.EncampmentType]
			local unitTypeID = GameInfoTypes[row.UnitType]
			local bUpdateBaseUnit = false
			if encampmentUnitInteger[encampmentID] == 1 then
				if g_currentBaseUnit1[encampmentID] ~= unitTypeID then
					g_currentBaseUnit1[encampmentID] = unitTypeID
					print(row.EncampmentType, ": Base Unit 1: ", row.UnitType)
					bUpdateBaseUnit = true
				end
				encampmentUnitInteger[encampmentID] = 2
			elseif encampmentUnitInteger[encampmentID] == 2 then
				g_currentBaseUnit2[encampmentID] = GameInfoTypes[row.UnitType]
				print(row.EncampmentType, ": Base Unit 2: ", row.UnitType)
				encampmentUnitInteger[encampmentID] = 3
			end
			if bUpdateBaseUnit then
				UpdateBaseUnit(encampmentID)
			end
		end
	end
	for i = 1, numEncampmentTypes do
		encampmentUnitInteger[i] = 1
	end
	for row in GameInfo.EaEncampments_RoamingUnits() do
		if not row.TechType or g_barbTechs[GameInfoTypes[row.TechType]] then
			local encampmentID = GameInfoTypes[row.EncampmentType]
			if encampmentUnitInteger[encampmentID] == 1 then
				g_currentRoamingUnit1[encampmentID] = GameInfoTypes[row.UnitType]
				print(row.EncampmentType, ": Roaming Unit 1: ", row.UnitType)
				encampmentUnitInteger[encampmentID] = 2
			elseif encampmentUnitInteger[encampmentID] == 2 then
				g_currentRoamingUnit2[encampmentID] = GameInfoTypes[row.UnitType]
				print(row.EncampmentType, ": Roaming Unit 2: ", row.UnitType)
				encampmentUnitInteger[encampmentID] = 3
			end
		end
	end
	for i = 1, numEncampmentTypes do
		encampmentUnitInteger[i] = 1
	end
	for row in GameInfo.EaEncampments_SeaUnits() do
		if not row.TechType or g_barbTechs[GameInfoTypes[row.TechType]] then
			local encampmentID = GameInfoTypes[row.EncampmentType]
			if encampmentUnitInteger[encampmentID] == 1 then
				g_currentSeaUnit1[encampmentID] = GameInfoTypes[row.UnitType]
				print(row.EncampmentType, ": Sea Unit 1: ", row.UnitType)
				encampmentUnitInteger[encampmentID] = 2
			elseif encampmentUnitInteger[encampmentID] == 2 then
				g_currentSeaUnit2[encampmentID] = GameInfoTypes[row.UnitType]
				print(row.EncampmentType, ": Sea Unit 2: ", row.UnitType)
				encampmentUnitInteger[encampmentID] = 3
			end
		end
	end


end

local plotSpecialCounts = {	Cold = 0,
							Lake = 0,
							Sea = 0,
							Mountain = 0,
							Forest = 0,
							Jungle = 0,
							Marsh = 0,
							Hill = 0,
							Desert = 0,
							Flatland = 0	}


local numberResources = {}
function InitUpgradeEncampment(iPlot, x, y, plot, upgradeTechID)	--called from PlotsPerTurn() when we discover a new encampment not present in gWorld.encampments (or below if tech upgrade)
	print("InitUpgradeEncampment ", iPlot, x, y, plot)
	--local plot = GetPlotByIndex(iPlot)
	--local x, y = plot:GetX(), plot:GetY()
	local prevEncampmentID = gWorld.encampments[iPlot]

	--score all encampment types
	local bCoastal = plot:IsCoastalLand()
	for loopX, loopY in PlotToRadiusIterator(x, y, 3) do
		local loopPlot = GetPlotFromXY(loopX, loopY)
		local plotTypeID = loopPlot:GetPlotType()
		local terrainID = loopPlot:GetTerrainType()
		local featureID = loopPlot:GetFeatureType()
		local resourceID = loopPlot:GetResourceType(-1)
		if resourceID ~= -1 then
			numberResources[resourceID] = (numberResources[resourceID] or 0) + 1
		end
		local plotSpecial
		if terrainID == TERRAIN_TUNDRA or terrainID == TERRAIN_SNOW or featureID == FEATURE_ICE then
			plotSpecialCounts.Cold = plotSpecialCounts.Cold + 1
		elseif loopPlot:IsLake() then
			plotSpecialCounts.Lake = plotSpecialCounts.Lake + 1
		elseif plotTypeID == PLOT_OCEAN then
			if bCoastal then
				plotSpecialCounts.Sea = plotSpecialCounts.Sea + 1	
			end	
		elseif plotTypeID == PLOT_MOUNTAIN then
			plotSpecialCounts.Mountain = plotSpecialCounts.Mountain + 1
		elseif featureID == FEATURE_FOREST then
			plotSpecialCounts.Forest = plotSpecialCounts.Forest + 1
		elseif featureID == FEATURE_JUNGLE then
			plotSpecialCounts.Jungle = plotSpecialCounts.Jungle + 1
		elseif featureID == FEATURE_MARSH then
			plotSpecialCounts.Marsh = plotSpecialCounts.Marsh + 1
		elseif plotTypeID == PLOT_HILLS then
			plotSpecialCounts.Hill = plotSpecialCounts.Hill + 1
		elseif terrainID == TERRAIN_DESERT then
			plotSpecialCounts.Desert = plotSpecialCounts.Desert + 1
		elseif plotTypeID == PLOT_LAND then	--must be plains/grass open flatland at this point
			plotSpecialCounts.Flatland = plotSpecialCounts.Flatland + 1
		end
	end

	--debug
	--for k, v in pairs(plotSpecialCounts) do
	--	print(v, k)
	--end

	--

	--pick best encampment type
	local encampmentID = prevEncampmentID or EA_ENCAMPMENT_ORCS		--fallback id; any valid can replace this
	local bestScore = -1
	for encampmentInfo in GameInfo.EaEncampments() do
		if not upgradeTechID or encampmentTech[encampmentInfo.ID] == upgradeTechID then
			local reqResourceID = encampmentInfo.RequiredResource and GameInfoTypes[encampmentInfo.RequiredResource]
			if (bCoastal or not encampmentInfo.RequiresCoastal) and (not reqResourceID or numberResources[reqResourceID]) then
				local score = 0
				local techType = encampmentInfo.PrereqTech
				if not techType or g_barbTechs[GameInfoTypes[techType]] then
					if encampmentInfo.NearbyPlotSpecial1 then
						score = score + (plotSpecialCounts[encampmentInfo.NearbyPlotSpecial1] or 0)
					end
					if encampmentInfo.NearbyPlotSpecial2 then
						score = score + (plotSpecialCounts[encampmentInfo.NearbyPlotSpecial2] or 0)
					end
					if encampmentInfo.NearbyPlotSpecial3 then
						score = score + (plotSpecialCounts[encampmentInfo.NearbyPlotSpecial3] or 0)
					end
					if encampmentInfo.NearbyPlotSpecial4 then
						score = score + (plotSpecialCounts[encampmentInfo.NearbyPlotSpecial4] or 0)
					end
					if reqResourceID then
						score = score + numberResources[reqResourceID] * encampmentInfo.ResourceWeight
					end
					score = score + encampmentInfo.AdHocScore
				end
				--[[
				for preEncampmentInfo in GameInfo.EaEncampments() do		--early encampment type gets preferences of later upgrade
					if preEncampmentInfo.UpgradeFrom == encampmentInfo.Type and not g_barbTechs[GameInfoTypes[preEncampmentInfo.PrereqTech] ] then
						local reqResourceID = preEncampmentInfo.RequiredResource and GameInfoTypes[preEncampmentInfo.RequiredResource]
						if (bCoastal or not preEncampmentInfo.RequiresCoastal) and (not reqResourceID or numberResources[reqResourceID]) then
							if preEncampmentInfo.NearbyPlotSpecial1 then
								score = score + (plotSpecialCounts[preEncampmentInfo.NearbyPlotSpecial1] or 0)
							end
							if preEncampmentInfo.NearbyPlotSpecial2 then
								score = score + (plotSpecialCounts[preEncampmentInfo.NearbyPlotSpecial2] or 0)
							end
							if preEncampmentInfo.NearbyPlotSpecial3 then
								score = score + (plotSpecialCounts[preEncampmentInfo.NearbyPlotSpecial3] or 0)
							end
							if preEncampmentInfo.NearbyPlotSpecial4 then
								score = score + (plotSpecialCounts[preEncampmentInfo.NearbyPlotSpecial4] or 0)
							end
							if reqResourceID then
								score = score + numberResources[reqResourceID] * preEncampmentInfo.ResourceWeight
							end
						end
					end
				end
				]]
				if bestScore < score then
					bestScore = score
					encampmentID = encampmentInfo.ID
				end
			end
		end
	end

	--[[get name for encampmentID
	local encampmentTxtKeys = gWorld.encampmentTxtKeys
	local encampmentInfo = GameInfo.EaEncampments[encampmentID]
	local encampmentAdj = encampmentInfo.Description
	if not encampmentAdj then
		local encampmentType = encampmentInfo.Type
		local sql = "EncampmentType = '" .. encampmentType .. "'"
		--Try to get currently not used adj; or use first in list
		for row in GameInfo.EaEncampments_TribeAdjectives(sql) do
			local adj = row.Adjective
			local bNotUsed = true
			for _, testAdj in pairs(encampmentTxtKeys) do
				if testAdj == adj then
					bNotUsed = false
					break
				end
			end
			if bNotUsed then
				encampmentAdj = adj
			end
		end
		if not encampmentAdj then	--just use 1st in list
			for row in GameInfo.EaEncampments_TribeAdjectives(sql) do
				encampmentAdj = row.Adjective
			end
		end
		if not encampmentAdj then
			encampmentAdj = "TXT_KEY_BARBARIAN"
		end
	end
	]]

	print(" -score/type/adjective: ", bestScore, GameInfo.EaEncampments[encampmentID].Type)

	--set type and init first unit
	gWorld.encampments[iPlot] = encampmentID
	--gWorld.encampmentTxtKeys[iPlot] = encampmentAdj
	--if USE_PLOT_SCRIPTDATA then
	--	plot:SetScriptData(tostring(encampmentID) .. encampmentAdj)
	--end
	if not prevEncampmentID then							--new encampment init
		AddEncampmentBaseUnit(iPlot, encampmentID)
	elseif prevEncampmentID ~= encampmentID then



	end

	--recycle tables
	for key in pairs(plotSpecialCounts) do
		plotSpecialCounts[key] = 0
	end
	for key in pairs(numberResources) do
		numberResources[key] = false
	end
end

function EncampmentsPerTurn()		--called right after PlotsPerTurn()
	print("Running EncampmentsPerTurn")
	local player = Players[BARB_PLAYER_INDEX]
	local encampments = gWorld.encampments
	local adjGameTurn = Game.GetGameTurn()

	--TO DO: adjust for game speed 
	adjGameTurn = adjGameTurn < TURN_CEILING and adjGameTurn or TURN_CEILING

	--Ad hoc tech awarding (in case no one ever researches)
	if techAwardByTurn[adjGameTurn] then
		local techID = techAwardByTurn[adjGameTurn]
		if not g_barbTechs[techID] then
			UpdateBarbTech(techID)
		end
	end

	--zero counts
	for encampmentID = 1, numEncampmentTypes do
		local campsByArea = g_encampmentsByArea[encampmentID]
		for iArea in pairs(campsByArea) do
			campsByArea[iArea] = 0
		end
		local barbsByArea = g_barbsByEncampmentTypeByArea[encampmentID]
		for iArea in pairs(barbsByArea) do
			barbsByArea[iArea] = 0
		end
	end
	--encampment counting
	for iPlot, encampmentID in pairs(encampments) do
		local iArea = useWorldDensity[encampmentID] and -1 or GetPlotByIndex(iPlot):GetArea()
		local campsByArea = g_encampmentsByArea[encampmentID]
		campsByArea[iArea] = (campsByArea[iArea] or 0) + 1
	end
	--unit counting and healing at encampment
	for unit in player:Units() do
		local unitTypeID = unit:GetUnitType()
		if barbUnitPower[unitTypeID] then			--not a captured unit
			local plot = unit:GetPlot()
			if plot:GetImprovementType() == IMPROVEMENT_BARBARIAN_CAMP then		--encampment healing
				local damage = unit:GetDamage()
				if 0 < damage then
					damage = damage < ENCAMPMENT_HEALING and damage or ENCAMPMENT_HEALING
					unit:ChangeDamage(-damage, -1)
				end
			else
			
				local encampmentID = unit:GetScenarioData() --unitEncampment[unitTypeID]
				if encampmentID ~= 0 then				--must be a roaming or sea unit	
					local iArea = plot:IsWater() and -1 or plot:GetArea()	-- plot:GetNearestLandArea()
					local barbsByArea = g_barbsByEncampmentTypeByArea[encampmentID]
					barbsByArea[iArea] = (barbsByArea[iArea] or 0) + 1
				end
				
			end
		end
	end

	--debug prints
	for encampmentInfo in GameInfo.EaEncampments() do
		local id = encampmentInfo.ID
		print(encampmentInfo.Type .. ":")
		print("g_currentBaseUnit1   ", g_currentBaseUnit1[id] and GameInfo.Units[g_currentBaseUnit1[id]].Type or nil)
		print("g_currentBaseUnit2   ", g_currentBaseUnit2[id] and GameInfo.Units[g_currentBaseUnit2[id]].Type or nil)
		print("g_currentRoamingUnit1", g_currentRoamingUnit1[id] and GameInfo.Units[g_currentRoamingUnit1[id]].Type or nil)
		print("g_currentRoamingUnit2", g_currentRoamingUnit2[id] and GameInfo.Units[g_currentRoamingUnit2[id]].Type or nil)
		print("g_currentSeaUnit1    ", g_currentSeaUnit1[id] and GameInfo.Units[g_currentSeaUnit1[id]].Type or nil)
		print("g_currentSeaUnit2    ", g_currentSeaUnit2[id] and GameInfo.Units[g_currentSeaUnit2[id]].Type or nil)
	end
	for encampmentID, byArea in pairs(g_encampmentsByArea) do
		local encampmentType = GameInfo.EaEncampments[encampmentID].Type
		for iArea, number in pairs(byArea) do
			print("Encampment count (number/type/iArea: ", byArea[iArea], encampmentType, iArea)
		end
	end
	
	for encampmentID, byArea in pairs(g_barbsByEncampmentTypeByArea) do
		local encampmentType = GameInfo.EaEncampments[encampmentID].Type
		for iArea, number in pairs(byArea) do
			print("Roaming/sea count (number/source/iArea: ", byArea[iArea], encampmentType, iArea)
		end
	end
	

	--Cycle all encampments
	print("Cycling through all encampments")
	for iPlot, encampmentID in pairs(encampments) do
		local plot = GetPlotByIndex(iPlot)
		local iArea = useWorldDensity[encampmentID] and -1 or plot:GetArea()

		print(GameInfo.EaEncampments[encampmentID].Type, iArea)
		
		--Update roaming units
		local roamUnit1 = g_currentRoamingUnit1[encampmentID]
		if roamUnit1 then
			local roamUnit2 = g_currentRoamingUnit2[encampmentID]
			local unitPower = barbUnitPower[roamUnit1]
			if roamUnit2 then
				unitPower = (unitPower + barbUnitPower[roamUnit2]) / 2
			end
			local unitNumber = g_barbsByEncampmentTypeByArea[encampmentID][iArea] or 0
			local encampmentNumber = g_encampmentsByArea[encampmentID][iArea] or 1
			if iArea == -1 then
				if encampmentNumber < USE_MINIMUM_PIRATE_COVE_NUMBER then
					encampmentNumber = USE_MINIMUM_PIRATE_COVE_NUMBER
				elseif USE_MAXIMUM_PIRATE_COVE_NUMBER < encampmentNumber then
					encampmentNumber = USE_MAXIMUM_PIRATE_COVE_NUMBER
				end
			end
			local density = unitNumber / encampmentNumber
			local chance = ROAM_SPAWN_MULTIPLIER * adjGameTurn ^ ROAM_TURN_EXPONENT / (unitPower ^ ROAM_POWER_FEEDBACK_EXPONENT * (density + 1) ^ ROAM_DENSITY_FEEDBACK_EXPONENT)
			--print("raw chance = ", chance)
			chance = 300 < chance and 300 or chance		--max ever is 30%
			local dice = Rand(1000, "hello")
			print("Roam chance/roll/unitPower/density ", chance, dice, unitPower, density)
			if dice < chance then
				local unitTypeID = roamUnit1
				if roamUnit2 and Rand(2, "hello") < 1 then
					unitTypeID = roamUnit2
				end
				print("PazDebug Trying to add roaming unit ", iPlot, GameInfo.EaEncampments[encampmentID].Type, GameInfo.Units[unitTypeID].Type)
				SpawnRoamingUnit(iPlot, unitTypeID, encampmentID)
			end
		end

		--Update sea units
		local seaUnit1 = g_currentSeaUnit1[encampmentID]
		if seaUnit1 then
			local seaUnit2 = g_currentSeaUnit2[encampmentID]
			local unitPower = barbUnitPower[seaUnit1]
			if seaUnit2 then
				unitPower = (unitPower + barbUnitPower[seaUnit2]) / 2
			end
			local density = (g_barbsByEncampmentTypeByArea[encampmentID][iArea] or 0) / (g_encampmentsByArea[encampmentID][iArea] or 1)
			local chance = SEA_SPAWN_MULTIPLIER * adjGameTurn ^ SEA_TURN_EXPONENT / (unitPower ^ SEA_POWER_FEEDBACK_EXPONENT * (density + 1) ^ SEA_DENSITY_FEEDBACK_EXPONENT)
			--print("raw chance = ", chance)
			chance = 300 < chance and 300 or chance		--max ever is 30%
			local dice = Rand(1000, "hello")
			print("Sea chance/roll/unitPower/density ", chance, dice, unitPower, density)
			if dice < chance then
				local unitTypeID = seaUnit1
				if seaUnit2 and Rand(2, "hello") < 1 then
					unitTypeID = seaUnit2
				end
				print("PazDebug Trying to add sea unit ", iPlot, GameInfo.EaEncampments[encampmentID].Type, GameInfo.Units[unitTypeID].Type)
				SpawnSeaUnit(iPlot, unitTypeID, encampmentID)
			end
		end
	end
end