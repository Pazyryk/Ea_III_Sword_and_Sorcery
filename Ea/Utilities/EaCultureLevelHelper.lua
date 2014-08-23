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
local CL_TARGET_CHANGE =			EaSettings.CL_TARGET_CHANGE				--reduce or increase per turn change toward this level; IMPORTANT!!!: Update EXPECTED_CL_CHANGE in EaAICivPlanning.lua to match this
local CL_CHANGE_DAMPING_EXPONENT =	EaSettings.CL_CHANGE_DAMPING_EXPONENT	--lower value pushes per turn change toward target change
local CL_RECENCY_BIAS =				EaSettings.CL_RECENCY_BIAS
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


local function SteadyStateCL(aveCulturePerPop)
	return CL_C_PER_POP_MULTIPLIER * aveCulturePerPop + CL_C_PER_POP_ADD
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
	local gameTurn = Game.GetGameTurn()
	if eaPlayer.cumCulture == 0 and 1 < gameTurn then	--player didn't settle on first turn; make sure they don't take a culture hit for that 
		eaPlayer.aveCulturePerPop = 2	--what a player gets from newly founded capital
	end

	local population = player:GetTotalPopulation()
	eaPlayer.maxPopEver = eaPlayer.maxPopEver < population and population or eaPlayer.maxPopEver
	local aveCulturePerPopLastTurn = eaPlayer.aveCulturePerPop
	local cumCultureLastTurn = eaPlayer.cumCulture
	local culturalLevelLastTurn = eaPlayer.culturalLevel
	local cumCulture = player:GetJONSCulture()
	eaPlayer.cumCulture = cumCulture 
	local culturePerPopThisTurn = (cumCulture - cumCultureLastTurn + CL_LOW_POP_FACTOR) / (eaPlayer.maxPopEver + CL_LOW_POP_FACTOR)

	eaPlayer.aveCulturePerPop = (aveCulturePerPopLastTurn * (gameTurn - 1) + culturePerPopThisTurn * (1 + CL_RECENCY_BIAS)) / (gameTurn + CL_RECENCY_BIAS)

	local steadyStateCL = SteadyStateCL(eaPlayer.aveCulturePerPop)
	--Voluspa
	if gT.gEpics[EA_EPIC_VOLUSPA] and gT.gEpics[EA_EPIC_VOLUSPA].iPlayer == iPlayer then
		steadyStateCL = steadyStateCL + gT.gEpics[EA_EPIC_VOLUSPA].mod / 10
	end

	local culturalLevel = culturalLevelLastTurn + GetCLChange(culturalLevelLastTurn, steadyStateCL)

	eaPlayer.culturalLevel = culturalLevel
	
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
	local gameTurn = Game.GetGameTurn()
	local eaPlayer = gT.gPlayers[iActivePlayer]
	if not eaPlayer then return end
	--local population = player:GetTotalPopulation()
	local cultureChange = player:GetTotalJONSCulturePerTurn() + (player:GetJONSCulture() - eaPlayer.cumCulture) + (eaPlayer.cultureManaFromWildlands or 0)
	local culturePerPopNextTurn = cultureChange / eaPlayer.maxPopEver
	local aveCulturePerPopNextTurn = (eaPlayer.aveCulturePerPop * gameTurn + culturePerPopNextTurn) / (gameTurn + 1)

	local steadyStateCL = SteadyStateCL(aveCulturePerPopNextTurn)
	if gT.gEpics[EA_EPIC_VOLUSPA] and gT.gEpics[EA_EPIC_VOLUSPA].iPlayer == iActivePlayer then	--Voluspa
		steadyStateCL = steadyStateCL + gT.gEpics[EA_EPIC_VOLUSPA].mod / 10
	end

	local estimatedCLNextTurn = eaPlayer.culturalLevel + GetCLChange(eaPlayer.culturalLevel, steadyStateCL)

	MapModData.cultureLevel = eaPlayer.culturalLevel
	MapModData.nextCultureLevel = eaPlayer.policyCount + 1
	MapModData.cultureRate = cultureChange
	MapModData.estCultureLevelChange = estimatedCLNextTurn - eaPlayer.culturalLevel
	MapModData.approachingCulturalLevel = steadyStateCL
end