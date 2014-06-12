-- EaGPSpawnHelper
-- Author: Pazyryk
-- DateCreated: 6/29/2013 10:24:10 PM
--------------------------------------------------------------
-- Used for GP spawn calculation for PeoplePerTurn and for Top Panel UI

local MapModData = MapModData
MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

--Settings
local GP_TARGET_NUMBER = 3


--Constants


--Localized tables and methods
local Players = Players
local Floor = math.floor

--Cached tables
local gpClassTable = {"Engineer", "Merchant", "Sage", "Artist", "Warrior", "Devout", "Thaumaturge"}
local numberGPClasses = #gpClassTable

local raceChanceBoost = {}
for raceInfo in GameInfo.EaRaces() do
	local lifespan = raceInfo.NominalLifeSpan
	if lifespan ~= -1 then
		raceChanceBoost[raceInfo.ID] = (1 - 0.5 ^ (2 / lifespan)) * 1000 * GP_TARGET_NUMBER
	else
		raceChanceBoost[raceInfo.ID] = 0
	end
end


MapModData.totalGreatPersonPoints = 0
MapModData.numberGreatPeople = 0

function CalculateGPSpawnChance(iPlayer)
	--print("PazDebug CalculateGPSpawnChance")
	local player = Players[iPlayer]
	local eaPlayer = gT.gPlayers[iPlayer]
	if not eaPlayer then return 0 end
	local chance = 0
	local eaCivID = eaPlayer.eaCivNameID
	if eaCivID then						--no GPs before civ naming

		local n = 0
		for iPerson, eaPerson in pairs(gT.gPeople) do
			if eaPerson.iPlayer == iPlayer then
				n = n + 1
			end
		end

		--adj for map, NE
		local totalPoints = 0
		for i = 1, numberGPClasses do
			totalPoints = totalPoints + eaPlayer.classPoints[i]
		end

		if totalPoints > 0 then
			local targetNumber = GP_TARGET_NUMBER * totalPoints / (totalPoints + 50)	--asymptotic; totalPoints = 50 gives 50%, 100 gives 75%, etc... (of GP_TARGET_NUMBER)
			chance = 150 / (1 + 2.72 ^ (n - targetNumber + 1))	--logistic function with max 150 (=15%)
			-- (n - targetNumber) = -3, -2, -1, 0, 1, 2, 3 gives 13%, 11%, 7.5%, 4.0%, 1.8%, 0.7%, 0.2%
			chance = Floor(chance + raceChanceBoost[eaPlayer.race])
		end							
		
		MapModData.totalGreatPersonPoints = totalPoints		--used for UI
		MapModData.numberGreatPeople = n
	end

	return chance		--out of 1000
end


local POLICY_PANTHEISM =			GameInfoTypes.POLICY_PANTHEISM
local POLICY_THEISM =				GameInfoTypes.POLICY_THEISM
local POLICY_HOLY_ORDER =			GameInfoTypes.POLICY_HOLY_ORDER
local POLICY_ANTI_HOLY_ORDER =		GameInfoTypes.POLICY_ANTI_HOLY_ORDER
local POLICY_BERSERKER_RAGE =		GameInfoTypes.POLICY_BERSERKER_RAGE
local RELIGION_ANRA =				GameInfoTypes.RELIGION_ANRA
local RELIGION_AZZANDARAYASNA =		GameInfoTypes.RELIGION_AZZANDARAYASNA
local TECH_ALCHEMY =				GameInfoTypes.TECH_ALCHEMY
local TECH_DIVINE_LITURGY =			GameInfoTypes.TECH_DIVINE_LITURGY
local TECH_SORCERY =				GameInfoTypes.TECH_SORCERY
local TECH_THAUMATURGY =			GameInfoTypes.TECH_THAUMATURGY
local TECH_NECROMANCY =				GameInfoTypes.TECH_NECROMANCY
local EACIV_GRAEAE =				GameInfoTypes.EACIV_GRAEAE

function PickSubclassForSpawnedClass(iPlayer, class)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	local eaPlayer = gT.gPlayers[iPlayer]
	if not eaPlayer then return end
	if class == "Sage" then
		if team:IsHasTech(TECH_ALCHEMY) then
			return "Alchemist"
		end
	elseif class == "Warrior" then
		if eaPlayer.religionID == RELIGION_AZZANDARAYASNA and player:HasPolicy(POLICY_HOLY_ORDER) then
			return "Paladin"
		elseif eaPlayer.religionID == RELIGION_ANRA and player:HasPolicy(POLICY_ANTI_HOLY_ORDER) then
			return "Eidolon"
		elseif player:HasPolicy(POLICY_BERSERKER_RAGE) then
			return "Berserker"
		end
	elseif class == "Devout" then
		if player:HasPolicy(POLICY_PANTHEISM) then
			return "Druid"
		elseif eaPlayer.bIsFallen then
			return "FallenPriest"
		elseif player:HasPolicy(POLICY_THEISM) or team:IsHasTech(TECH_DIVINE_LITURGY) then
			return "Priest"
		else				--not sure how this would happen, but just in case
			return "Druid"
		end
	elseif class == "Thaumaturge" then
		if eaPlayer.eaCivNameID == EACIV_GRAEAE then
			return "Witch"
		elseif team:IsHasTech(TECH_NECROMANCY) then
			return "Necromancer"
		elseif team:IsHasTech(TECH_SORCERY) then
			return "Sorcerer"
		elseif team:IsHasTech(TECH_THAUMATURGY) then
			return "Wizard"
		else
			return "Witch"
		end
	end
	return nil
end

