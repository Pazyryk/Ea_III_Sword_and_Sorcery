-- EaWonders
-- Author: Pazyryk
-- DateCreated: 4/21/2014 9:38:56 AM
--------------------------------------------------------------
print("Loading EaWonders.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------
--constants
local EA_WONDER_ARCANE_TOWER =		GameInfoTypes.EA_WONDER_ARCANE_TOWER
local IMPROVEMENT_RUINS =			GameInfoTypes.IMPROVEMENT_RUINS
local POLICY_ARCANA =				GameInfoTypes.POLICY_ARCANA
local POLICY_PANTHEISM =			GameInfoTypes.POLICY_PANTHEISM
local RELIGION_AZZANDARAYASNA =		GameInfoTypes.RELIGION_AZZANDARAYASNA
local TECH_MALEFICIUM =				GameInfoTypes.TECH_MALEFICIUM
local TECH_THAUMATURGY =			GameInfoTypes.TECH_THAUMATURGY

--localized tables
local Players = Players
local gWonders = gWonders
local fullCivs = MapModData.fullCivs

--localized functions
local GetPlotByIndex =		Map.GetPlotByIndex

--file control
local DoPerTurnUniqueWonder = {}

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------
local wonderImprovement = {}	--index by wonderID
local wonderBuilding = {}
local wonderBuildingMod = {}
local bPantheisticOnly = {}
local bAzzFollowerOnly = {}
local bFallenOnly = {}
local improvementWonder = {}	--index by improvementID
for wonderInfo in GameInfo.EaWonders() do
	if wonderInfo.ImprovementType then
		local improvementID = GameInfoTypes[wonderInfo.ImprovementType]
		wonderImprovement[wonderInfo.ID] = improvementID
		improvementWonder[improvementID] = wonderInfo.ID
	end
	if wonderInfo.BuildingType then
		wonderBuilding[wonderInfo.ID] = GameInfoTypes[wonderInfo.BuildingType]
	end
	if wonderInfo.BuildingModType then
		wonderBuildingMod[wonderInfo.ID] = GameInfoTypes[wonderInfo.BuildingModType]
	end
	if wonderInfo.PantheisticOnly then
		bPantheisticOnly[wonderInfo.ID] = true
	end
	if wonderInfo.AzzFollowerOnly then
		bAzzFollowerOnly[wonderInfo.ID] = true
	end
	if wonderInfo.FallenOnly then
		bFallenOnly[wonderInfo.ID] = true
	end
end

--------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------

local function IsWonderAppropriate(iPlayer, wonderID)
	if not fullCivs[iPlayer] then return false end
	local player = Players[iPlayer]
	if bPantheisticOnly[wonderID] and not player:HasPolicy(POLICY_PANTHEISM) then return false end
	local eaPlayer = gPlayers[iPlayer]
	if bAzzFollowerOnly[wonderID] and eaPlayer.religionID ~= RELIGION_AZZANDARAYASNA then return false end
	if bFallenOnly[wonderID] and not eaPlayer.bIsFallen then return false end
	if wonderID == EA_WONDER_ARCANE_TOWER then
		if not player:HasPolicy(POLICY_ARCANA) then
			local team = Teams[player:GetTeam()]
			if not team:IsHasTech(TECH_THAUMATURGY) and not team:IsHasTech(TECH_MALEFICIUM) then return false end
		end
	end
	return true
end

local function UpdateWonderRuins(plot, wonderID, bAppropriate)
	local wonderImprovementID = wonderImprovement[wonderID]
	if wonderImprovementID then
		if plot:GetImprovementType() == IMPROVEMENT_RUINS then
			if bAppropriate then	--convert from ruins to pillaged wonder
				plot:SetImprovementType(wonderImprovementID)
				plot:SetImprovementPillaged(true)
			end
			return false		--wonder is either in ruins or pillaged so not active
		else
			if not bAppropriate then	--convert to ruins
				if wonderID ~= EA_WONDER_ARCANE_TOWER then
					local str = Locale.Lookup(GameInfo.EaWonders[wonderID].Description)
					plot:SetScriptData(str)	--we keep wonder name in ScriptData so we can easily build plot UI, e.g.: "Great Library (Ruins)"; it's already there for Arcane Tower
				end			
				plot:SetImprovementPillaged(false)
				plot:SetImprovementType(IMPROVEMENT_RUINS)
				return false	--wonder is in ruins so not active
			elseif plot:IsImprovementPillaged() then
				return false	--wonder is pillaged so not active
			else
				return true		--wonder is active
			end
		end
	else	--must be city wonder
		return true
	end
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaWondersInit(bNewGame)

end

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function UpdateUniqueWonder(iPlayer, wonderID, bPerTurnCall)	--full Civ only
	local wonder = gWonders[wonderID]
	if not wonder.iPlot then
		error("Wonder had no iPlot; did we acidentally send a multiple-instance wonder to this function?")
	end
	if wonder.iPlayer == -99 then return end	--permanently destroyed
	local plot = GetPlotByIndex(wonder.iPlot)
	local iOwner = plot:GetOwner()
	if iPlayer ~= iOwner and iOwner == wonder.iPlayer then return end	--nothing to do here

	local buildingID = wonderBuilding[wonderID]
	local buildingModID = wonderBuildingMod[wonderID]

	--if owner change, cancel effects for previous owner and set to ruins if no current owner
	if iOwner ~= wonder.iPlayer then
		local oldOwner = Players[wonder.iPlayer]
		if oldOwner and oldOwner:IsAlive() then
			for city in oldOwner:Cities() do
				if buildingID then
					city:SetNumFreeBuilding(buildingID, 0)
				end
				if buildingModID then
					city:SetNumFreeBuilding(buildingModID, 0)
				end		
			end
		end
		--wonderImprovement
		if iOwner == -1 and not wonderImprovement[wonderID] then		--this is a city wonder and the city has been raized
			wonder.iPlayer = -99
			return
		end
		if not fullCivs[iOwner] then			-- minor
			UpdateWonderRuins(plot, wonderID, false)
		end
		wonder.iPlayer = iOwner
	end

	if iPlayer ~= iOwner then return end

	--update effects for iPlayer (current owner)
	local player = Players[iPlayer]
	local bAppropriate = IsWonderAppropriate(iPlayer, wonderID)
	local bActive = UpdateWonderRuins(plot, wonderID, bAppropriate)
	if bActive then
		local iCity = plot:GetCityPurchaseID()
		local city = player:GetCityByID(iCity)
		if buildingID then
			city:SetNumFreeBuilding(buildingID, 1)
		end
		if buildingModID then
			city:SetNumFreeBuilding(buildingModID, wonder.mod)		--some wonder mods change, so update each turn is ok
		end
		--specific per turn effects
		if bPerTurnCall and DoPerTurnUniqueWonder[wonderID] then
			 DoPerTurnUniqueWonder[wonderID](iPlayer, plot)
		end
	else
		for city in player:Cities() do
			if buildingID then
				city:SetNumFreeBuilding(buildingID, 0)
			end
			if buildingModID then
				city:SetNumFreeBuilding(buildingModID, 0)
			end		
		end
	end
end
local UpdateUniqueWonder = UpdateUniqueWonder

DoPerTurnUniqueWonder[GameInfoTypes.EA_WONDER_TEMPLE_AHRIMAN_1] = function(iPlayer, plot)
	UseManaOrDivineFavor(iPlayer, nil, 169, true, plot)
end

DoPerTurnUniqueWonder[GameInfoTypes.EA_WONDER_TEMPLE_AHRIMAN_2] = function(iPlayer, plot)
	UseManaOrDivineFavor(iPlayer, nil, 289, true, plot)
end

DoPerTurnUniqueWonder[GameInfoTypes.EA_WONDER_TEMPLE_AHRIMAN_3] = function(iPlayer, plot)
	UseManaOrDivineFavor(iPlayer, nil, 361, true, plot)
end

DoPerTurnUniqueWonder[GameInfoTypes.EA_WONDER_TEMPLE_AHRIMAN_4] = function(iPlayer, plot)
	UseManaOrDivineFavor(iPlayer, nil, 529, true, plot)
end

DoPerTurnUniqueWonder[GameInfoTypes.EA_WONDER_TEMPLE_AHRIMAN_5] = function(iPlayer, plot)
	UseManaOrDivineFavor(iPlayer, nil, 841, true, plot)
end

DoPerTurnUniqueWonder[GameInfoTypes.EA_WONDER_TEMPLE_AHRIMAN_6] = function(iPlayer, plot)
	UseManaOrDivineFavor(iPlayer, nil, 961, true, plot)
end

DoPerTurnUniqueWonder[GameInfoTypes.EA_WONDER_TEMPLE_AHRIMAN_7] = function(iPlayer, plot)
	UseManaOrDivineFavor(iPlayer, nil, 1369, true, plot)
end

DoPerTurnUniqueWonder[GameInfoTypes.EA_WONDER_TEMPLE_AHRIMAN_8] = function(iPlayer, plot)
	UseManaOrDivineFavor(iPlayer, nil, 1681, true, plot)
end

DoPerTurnUniqueWonder[GameInfoTypes.EA_WONDER_TEMPLE_AHRIMAN_9] = function(iPlayer, plot)
	UseManaOrDivineFavor(iPlayer, nil, 1849, true, plot)
end

local cityModSum = {}
function UpdateInstanceWonder(iPlayer, wonderID, bPerTurnCall)
	local player = Players[iPlayer]
	local bIsFallen = gPlayers[iPlayer].bIsFallen
	local bAppropriate = IsWonderAppropriate(iPlayer, wonderID)
	local buildingID = wonderBuilding[wonderID]
	local buildingModID = wonderBuildingMod[wonderID]
	for instanceID, wonderInstance in pairs(gWonders[wonderID]) do
		local plot = GetPlotByIndex(wonderInstance.iPlot)
		local iOwner = plot:GetOwner()
		if iOwner == iPlayer then
			wonderInstance.iPlayer = iOwner		--simpler than above since we check every player city every turn
			local bIsActive = UpdateWonderRuins(iOwner, plot, wonderID, bAppropriate)
			if bIsActive then
				local iCity = plot:GetCityPurchaseID()
				cityModSum[iCity] = (cityModSum[iCity] or 0) + wonderInstance.mod
				if bIsFallen and wonderID == EA_WONDER_ARCANE_TOWER then
					UseManaOrDivineFavor(iPlayer, nil, wonderInstance.mod, true, plot)
				end
			end
		end
	end

	for city in player:Cities() do
		local iCity = city:GetID()
		if buildingID then
			city:SetNumFreeBuilding(buildingID, (cityModSum[iCity] and 0 < cityModSum[iCity]) and 1 or 0)
		end
		if buildingModID then
			city:SetNumFreeBuilding(buildingModID, cityModSum[iCity] or 0)
		end		
	end

	--recycle table
	for iCity in pairs(cityModSum) do
		cityModSum[iCity] = nil
	end
end
local UpdateInstanceWonder = UpdateInstanceWonder

function WondersPerCivTurn(iPlayer)
	--Update all wonders
	for wonderID, wonder in pairs(gWonders) do
		if wonder.iPlot then
			UpdateUniqueWonder(iPlayer, wonderID, true)
		else
			UpdateInstanceWonder(iPlayer, wonderID, true)
		end
	end
end

function CheckUpdatePlotWonder(iPlayer, improvementID)		--called after build that may have been repair
	local wonderID = improvementWonder[improvementID]
	if wonderID then
		if gWonders[wonderID].iPlot then
			UpdateUniqueWonder(iPlayer, wonderID)
		else
			UpdateInstanceWonder(iPlayer, wonderID)
		end
	end
end