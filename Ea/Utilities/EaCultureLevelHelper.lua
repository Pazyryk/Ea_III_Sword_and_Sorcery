-- EaCultureLevelHelper
-- Author: Pazyryk
-- DateCreated: 6/29/2013 7:21:19 PM
--------------------------------------------------------------
-- Used for Cultural Level calculations and UI
-- Consolotated here for mental health purposes

local MapModData = MapModData
MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT
local EaSettings = MapModData.EaSettings

--------------------------------------------------------------
--Settings
--------------------------------------------------------------
local CL_C_PER_POP_MULTIPLIER =		EaSettings.CL_C_PER_POP_MULTIPLIER		--policies as a function of culture generation / eaPlayer.maxPopEver
local CL_C_PER_POP_ADD =			EaSettings.CL_C_PER_POP_ADD				--extra policies you would get with no culture

local CL_APPROACH_FACTOR =			EaSettings.CL_APPROACH_FACTOR			--try to approach steady state level by this fraction of the difference each turn
local CL_TARGET_CHANGE =			EaSettings.CL_TARGET_CHANGE				--reduce or increase per turn change toward this level
local CL_CHANGE_DAMPING_EXPONENT =	EaSettings.CL_CHANGE_DAMPING_EXPONENT	--lower value pushes per turn change toward target change
--local CL_RECENCY_BIAS =				EaSettings.CL_RECENCY_BIAS
local CL_LOW_POP_FACTOR =			EaSettings.CL_LOW_POP_FACTOR

--------------------------------------------------------------
--File Locals
--------------------------------------------------------------
--Constants
local EA_EPIC_VOLUSPA =		GameInfoTypes.EA_EPIC_VOLUSPA

--Localized tables and methods
local Players = Players
local floor = math.floor

--aveCulturePerPop should be read as ave(CulturePerPop); so turn with 1 pop counts as much as turn with 100 pop


local function SteadyStateCL(cultureRate, maxPopEver)
	return (cultureRate + CL_LOW_POP_FACTOR) / (maxPopEver + CL_LOW_POP_FACTOR) * CL_C_PER_POP_MULTIPLIER + CL_C_PER_POP_ADD
end


local function GetCLChange(currentCL, steadyStateCL)
	local diff = steadyStateCL - currentCL
	local change = CL_APPROACH_FACTOR * diff
	change = change / CL_TARGET_CHANGE											--normalize to 1
	if 0 < change then
		change = (change ^ CL_CHANGE_DAMPING_EXPONENT) * CL_TARGET_CHANGE		--dampen toward 1, then un-normalize
		change = change < diff and change or diff								--don't overshoot
	else
		change = -(-change ^ CL_CHANGE_DAMPING_EXPONENT) * CL_TARGET_CHANGE
		change = diff < change and change or diff
	end
	return change
end

-- Per turn update (runs each turn after turn 0 from EaPolicies.lua)
function UpdateCulturalLevel(iPlayer, eaPlayer)
	local player = Players[iPlayer]
	if not player:IsFoundedFirstCity() then return end
	local population = player:GetTotalPopulation()
	eaPlayer.maxPopEver = eaPlayer.maxPopEver < population and population or eaPlayer.maxPopEver
	local cumCulture = player:GetJONSCulture()
	local cultureRate = cumCulture - eaPlayer.cumCulture	--now minus last turn
	eaPlayer.cumCulture = cumCulture
	local steadyStateCL = SteadyStateCL(cultureRate, eaPlayer.maxPopEver)
	--Voluspa
	if gT.gEpics[EA_EPIC_VOLUSPA] and gT.gEpics[EA_EPIC_VOLUSPA].iPlayer == iPlayer then
		steadyStateCL = steadyStateCL + gT.gEpics[EA_EPIC_VOLUSPA].mod / 10
	end
	eaPlayer.culturalLevel = eaPlayer.culturalLevel + GetCLChange(eaPlayer.culturalLevel, steadyStateCL)
end

-- UI for active player
MapModData.cultureLevel = 0
MapModData.nextCultureLevel = 1
MapModData.estCultureLevelChange = 0
MapModData.approachingCulturalLevel = 0
MapModData.cultureRate = 0

function UpdateCultureLevelInfoForUI(iActivePlayer)
	local player = Players[iActivePlayer]
	if not player:IsFoundedFirstCity() then return end
	local eaPlayer = gT.gPlayers[iActivePlayer]
	if not eaPlayer then return end

	local estCultureRate = player:GetTotalJONSCulturePerTurn() + (player:GetJONSCulture() - eaPlayer.cumCulture) + (eaPlayer.cultureManaFromWildlands or 0)
	local population = player:GetTotalPopulation()
	local maxPopEver = eaPlayer.maxPopEver < population and population or eaPlayer.maxPopEver
	local estNewSteadyStateCL = SteadyStateCL(estCultureRate, maxPopEver)
	if gT.gEpics[EA_EPIC_VOLUSPA] and gT.gEpics[EA_EPIC_VOLUSPA].iPlayer == iActivePlayer then	--Voluspa
		estNewSteadyStateCL = estNewSteadyStateCL + gT.gEpics[EA_EPIC_VOLUSPA].mod / 10
	end
	local estCLNextTurn = eaPlayer.culturalLevel + GetCLChange(eaPlayer.culturalLevel, estNewSteadyStateCL)

	MapModData.cultureLevel = eaPlayer.culturalLevel
	MapModData.nextCultureLevel = eaPlayer.policyCount + 1
	MapModData.cultureRate = estCultureRate
	MapModData.estCultureLevelChange = estCLNextTurn - eaPlayer.culturalLevel
	MapModData.approachingCulturalLevel = estNewSteadyStateCL
end