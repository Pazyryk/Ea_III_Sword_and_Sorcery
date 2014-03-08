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
local POLICY_MULTIPLIER = 10			--Max policies as a function of culture generation / population
local POLICY_CULTURE_EXPONENT = 0.7
local POLICY_DENOMINATOR_ADD = 1300		--how quickly we move toward max policies (lower is faster)


--------------------------------------------------------------
--File Locals
--------------------------------------------------------------
--Constants
local EA_EPIC_VOLUSPA =		GameInfoTypes.EA_EPIC_VOLUSPA

--Localized tables and methods
local Players = Players
local Floor = math.floor

-- Per turn stats update (all full civs from EaPolicies.lua)
function UpdateCulturalLevel(iPlayer, eaPlayer)
	local player = Players[iPlayer]
	local lastCulturalLevel = eaPlayer.culturalLevel
	eaPlayer.cumPopTurns = eaPlayer.cumPopTurns + player:GetTotalPopulation()
	local culturalLevel = POLICY_MULTIPLIER * (((player:GetJONSCulture() + eaPlayer.cumPopTurns) / (eaPlayer.cumPopTurns + POLICY_DENOMINATOR_ADD)) ^ POLICY_CULTURE_EXPONENT)
	--Voluspa
	if gT.gEpics[EA_EPIC_VOLUSPA] and gT.gEpics[EA_EPIC_VOLUSPA].iPlayer == iPlayer then
		culturalLevel = culturalLevel + gT.gEpics[EA_EPIC_VOLUSPA].mod / 10
	end
	eaPlayer.culturalLevel = culturalLevel
	eaPlayer.culturalLevelChange = culturalLevel - lastCulturalLevel		--used by AI (not UI)
end

-- UI for active player
MapModData.cultureLevel = 0
MapModData.nextCultureLevel = 0
MapModData.estCultureLevelChange = 0
MapModData.approachingCulturalLevel = 0
MapModData.cultureRate = 0

function UpdateCultureLevelInfoForUI(iActivePlayer)
	local player = Players[iActivePlayer]
	local eaPlayer = gT.gPlayers[iActivePlayer]
	if not eaPlayer then return end
	local population = player:GetTotalPopulation()

	MapModData.cultureRate = player:GetTotalJONSCulturePerTurn() + (eaPlayer.cultureManaFromWildlands or 0)	--more?

	MapModData.cultureLevel = eaPlayer.culturalLevel
	MapModData.nextCultureLevel = eaPlayer.policyCount + 1 - player:GetNumFreePolicies()
	local estNextTurn = POLICY_MULTIPLIER * (((player:GetJONSCulture() + MapModData.cultureRate + eaPlayer.cumPopTurns + population) / (eaPlayer.cumPopTurns + POLICY_DENOMINATOR_ADD + population)) ^ POLICY_CULTURE_EXPONENT)
	if gT.gEpics[EA_EPIC_VOLUSPA] and gT.gEpics[EA_EPIC_VOLUSPA].iPlayer == iActivePlayer then	--Voluspa
		estNextTurn = estNextTurn + gT.gEpics[EA_EPIC_VOLUSPA].mod / 10
	end
	MapModData.estCultureLevelChange = estNextTurn - MapModData.cultureLevel
	MapModData.approachingCulturalLevel = POLICY_MULTIPLIER * (((MapModData.cultureRate + population) / population) ^ POLICY_CULTURE_EXPONENT)
end