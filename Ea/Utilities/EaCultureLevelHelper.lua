-- EaCultureLevelHelper
-- Author: Pazyryk
-- DateCreated: 6/29/2013 7:21:19 PM
--------------------------------------------------------------
-- Used for Cultural Level calculations and UI
-- Consolotated here for mental health purposes

local MapModData = MapModData
MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

--------------------------------------------------------------
--Settings
--------------------------------------------------------------
local POLICY_MULTIPLIER = 5												--policies as a function of culture generation / population
local POLICY_ADD = 4													--extra policies you would get with no culture

local CL_APPROACH_FACTOR = 0.006 / MapModData.GAME_SPEED_MULTIPLIER		--try to approach steady state level by this fraction of the difference each turn
local CL_TARGET_CHANGE = 0.06 / MapModData.GAME_SPEED_MULTIPLIER		--reduce or increase per turn change toward this level
local CL_CHANGE_DAMPING_EXPONENT = 1/2									--lower value pushes per turn change toward target change


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
	return POLICY_MULTIPLIER * aveCulturePerPop + POLICY_ADD
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
	local gameTurn = Game.GetGameTurn()
	local player = Players[iPlayer]
	local population = player:GetTotalPopulation()
	local aveCulturePerPopLastTurn = eaPlayer.aveCulturePerPop
	local cumCultureLastTurn = eaPlayer.cumCulture
	local culturalLevelLastTurn = eaPlayer.culturalLevel
	local cumCulture = player:GetJONSCulture()
	local culturePerPopThisTurn = (cumCulture - cumCultureLastTurn) / population
	eaPlayer.cumCulture = cumCulture 
	eaPlayer.aveCulturePerPop = (aveCulturePerPopLastTurn * (gameTurn - 1) + culturePerPopThisTurn) / gameTurn

	local steadyStateCL = SteadyStateCL(eaPlayer.aveCulturePerPop)
	--Voluspa
	if gT.gEpics[EA_EPIC_VOLUSPA] and gT.gEpics[EA_EPIC_VOLUSPA].iPlayer == iPlayer then
		steadyStateCL = steadyStateCL + gT.gEpics[EA_EPIC_VOLUSPA].mod / 10
	end

	local culturalLevel = culturalLevelLastTurn + GetCLChange(culturalLevelLastTurn, steadyStateCL)

	eaPlayer.culturalLevel = culturalLevel
	eaPlayer.culturalLevelChange = culturalLevel - culturalLevelLastTurn		--used by AI (not UI)
end

-- UI for active player
MapModData.cultureLevel = 0
MapModData.nextCultureLevel = 0
MapModData.estCultureLevelChange = 0
MapModData.approachingCulturalLevel = 0
MapModData.cultureRate = 0

function UpdateCultureLevelInfoForUI(iActivePlayer)
	local gameTurn = Game.GetGameTurn()
	local player = Players[iActivePlayer]
	local eaPlayer = gT.gPlayers[iActivePlayer]
	if not eaPlayer then return end
	local population = player:GetTotalPopulation()
	local cultureChange = player:GetTotalJONSCulturePerTurn() + (player:GetJONSCulture() - eaPlayer.cumCulture) + (eaPlayer.cultureManaFromWildlands or 0)
	local culturePerPopNextTurn = cultureChange / population
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