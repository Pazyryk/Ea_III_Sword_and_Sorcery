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
local POLICY_MULTIPLIER = 5										--policies as a function of culture generation / population
local POLICY_ADD = 0											--extra policies you would get with no culture
--local POLICY_DENOMINATOR_ADD = 100 * MapModData.GAME_SPEED		--how quickly we move toward max policies (lower is faster)

local CL_APPROACH_FACTOR = -0.02 / MapModData.GAME_SPEED		-- -0.02 gives CL very close to ApproachCL by turn 200
--------------------------------------------------------------
--File Locals
--------------------------------------------------------------
--Constants
local EA_EPIC_VOLUSPA =		GameInfoTypes.EA_EPIC_VOLUSPA

--Localized tables and methods
local Players = Players
local Floor = math.floor
local exp = math.exp

--aveCulturePerPop should be read as ave(CulturePerPop); so turn with 1 pop counts as much as turn with 100 pop


local function ApproachCL(aveCulturePerPop)
	return POLICY_MULTIPLIER * aveCulturePerPop + POLICY_ADD
end

local function CL(aveCulturePerPop, gameTurn)
	--return (POLICY_MULTIPLIER * aveCulturePerPop + POLICY_ADD) * gameTurn / (gameTurn + POLICY_DENOMINATOR_ADD)
	return ApproachCL(aveCulturePerPop) * (1 - exp(CL_APPROACH_FACTOR * gameTurn))
end

-- math.exp(myval) 

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
	local culturalLevel = CL(eaPlayer.aveCulturePerPop, gameTurn)

	--Voluspa
	if gT.gEpics[EA_EPIC_VOLUSPA] and gT.gEpics[EA_EPIC_VOLUSPA].iPlayer == iPlayer then
		culturalLevel = culturalLevel + gT.gEpics[EA_EPIC_VOLUSPA].mod / 10
	end
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

	MapModData.cultureLevel = eaPlayer.culturalLevel
	MapModData.nextCultureLevel = eaPlayer.policyCount + 1
	MapModData.cultureRate = player:GetTotalJONSCulturePerTurn() + (eaPlayer.cultureManaFromWildlands or 0)
	local culturePerPopNextTurn = MapModData.cultureRate / population
	local estNextTurn = CL((eaPlayer.aveCulturePerPop * gameTurn + culturePerPopNextTurn) / (gameTurn + 1), gameTurn + 1)
	if gT.gEpics[EA_EPIC_VOLUSPA] and gT.gEpics[EA_EPIC_VOLUSPA].iPlayer == iActivePlayer then	--Voluspa
		estNextTurn = estNextTurn + gT.gEpics[EA_EPIC_VOLUSPA].mod / 10
	end

	MapModData.estCultureLevelChange = estNextTurn - MapModData.cultureLevel
	MapModData.approachingCulturalLevel = ApproachCL(eaPlayer.aveCulturePerPop)

end