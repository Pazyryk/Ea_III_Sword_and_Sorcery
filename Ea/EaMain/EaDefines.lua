-- EaDefines
-- Author: Pazyryk
-- DateCreated: 8/16/2011 7:24:16 PM
--------------------------------------------------------------

print("Loading EaDefines.lua...")

--clear out MapModData in case this is a reload or map regeneration
for k, v in pairs(MapModData) do
	print("Clearing MapModData from map regenertion or in-game load ", k, v)
	MapModData[k] = nil
end

--------------------------------------------------------------
-- Debug / Under-Construction
--------------------------------------------------------------

ENABLE_PRINT = true
DEBUG_PRINT = false
MapModData.DEBUG_PRINT = DEBUG_PRINT
MapModData.bDebugShowHiddenBuildings = false
MapModData.bDisableEnabledPolicies = true

--------------------------------------------------------------
-- Game Speed and Map Size adjustments
--------------------------------------------------------------

local gameSpeedMultipliers = {	[GameInfoTypes.GAMESPEED_QUICK] =		2/3,
								[GameInfoTypes.GAMESPEED_STANDARD] =	1,
								[GameInfoTypes.GAMESPEED_EPIC] =		3/2,
								[GameInfoTypes.GAMESPEED_MARATHON] =	2	}

local mapSizeMultipliers = {	[GameInfoTypes.WORLDSIZE_DUEL] =		1/2,
								[GameInfoTypes.WORLDSIZE_TINY] =		1/2,
								[GameInfoTypes.WORLDSIZE_SMALL] =		2/3,
								[GameInfoTypes.WORLDSIZE_STANDARD] =	1,	
								[GameInfoTypes.WORLDSIZE_LARGE ] =		3/2,
								[GameInfoTypes.WORLDSIZE_HUGE ] =		2	}

GAME_SPEED = Game.GetGameSpeedType()
MAP_SIZE = Map.GetWorldSize()
GAME_SPEED_MULTIPLIER = gameSpeedMultipliers[GAME_SPEED]
MAP_SIZE_MULTIPLIER = mapSizeMultipliers[MAP_SIZE]

MapModData.GAME_SPEED = GAME_SPEED
MapModData.MAP_SIZE = MAP_SIZE
MapModData.GAME_SPEED_MULTIPLIER = GAME_SPEED_MULTIPLIER
MapModData.MAP_SIZE_MULTIPLIER = MAP_SIZE_MULTIPLIER

print("Game speed, map size, speed multiplier, size multiplier = ", GAME_SPEED, MAP_SIZE, GAME_SPEED_MULTIPLIER, MAP_SIZE_MULTIPLIER)

--------------------------------------------------------------
-- Settings
--------------------------------------------------------------

EaSettings = {}						--Find Ea gameplay settings in EaTables/_EaSettings.sql
MapModData.EaSettings = EaSettings	
print("Adjusted Ea Game Settings:")
for row in GameInfo.EaSettings() do
	local value = row.Value
	local multiplier = row.GameLengthExp and GAME_SPEED_MULTIPLIER ^ row.GameLengthExp or 1
	multiplier = multiplier * (row.MapSizeExp and MAP_SIZE_MULTIPLIER ^ row.MapSizeExp or 1)
	if multiplier ~= 1 then
		value = value * multiplier
		if row.RoundAdjVal == 1 then
			value = math.floor(value + 0.5)
		end
		if row.Max then
			value = row.Max < value and row.Max or value
		end
		if row.Min then
			value = value < row.Min and row.Min or value
		end
	end
	print(row.Name, value)
	EaSettings[row.Name] = value
end

--------------------------------------------------------------
-- Global Constants
--------------------------------------------------------------

WeakKeyMetatable = {__mode = "k"}
OutOfRangeReturnZeroMetaTable = {__index = function() return 0 end}	--return 0 rather than nil for out of range index


UNIT_SUFFIXES = {"_MAN", "_SIDHE", "_ORC"}

GP_TXT_KEYS = {	Engineer = "TXT_KEY_EA_ENGINEER",
				Merchant = "TXT_KEY_EA_MERCHANT",
				Sage = "TXT_KEY_EA_SAGE",
				Artist = "TXT_KEY_EA_ARTIST",
				Warrior = "TXT_KEY_EA_WARRIOR",
				Berserker = "TXT_KEY_EA_BERSERKER",
				Devout = "TXT_KEY_EA_DEVOUT",
				Thaumaturge = "TXT_KEY_EA_THAUMATURGE",
				Alchemist = "TXT_KEY_EA_ALCHEMIST",
				SeaWarrior = "TXT_KEY_EA_SEA_WARRIOR",
				Priest = "TXT_KEY_EA_PRIEST",
				Paladin = "TXT_KEY_EA_PALADIN",
				Druid = "TXT_KEY_EA_DRUID",
				FallenPriest = "TXT_KEY_EA_PRIEST",
				Eidolon = "TXT_KEY_EA_EIDOLON",
				Witch = "TXT_KEY_EA_WITCH",
				Wizard = "TXT_KEY_EA_WIZARD",
				Sorcerer = "TXT_KEY_EA_SORCERER",
				Necromancer = "TXT_KEY_EA_NECROMANCER",
				Mage = "TXT_KEY_EA_MAGE",
				Archmage = "TXT_KEY_EA_ARCHMAGE",
				Lich = "TXT_KEY_EA_LICH"	}
MapModData.GP_TXT_KEYS = GP_TXT_KEYS

BARB_PLAYER_INDEX = GameDefines.BARBARIAN_PLAYER
for iPlayer = 0, BARB_PLAYER_INDEX do
	local player = Players[iPlayer]
	if player:GetCivilizationType() == GameInfoTypes.CIVILIZATION_THE_FAY then
		FAY_PLAYER_INDEX = iPlayer
		break
	end	
end
--ANIMALS_PLAYER_INDEX = EaSetupDB.GetValue("ANIMALS_PLAYER_INDEX")
ANIMALS_PLAYER_INDEX = GameDefines.ANIMAL_PLAYER
OBSERVER_TEAM = GameDefines.MAX_MAJOR_CIVS - 1

HIGHEST_RELIGION_ID = 0
for religion in GameInfo.Religions() do
	HIGHEST_RELIGION_ID = religion.ID
end
MapModData.HIGHEST_RELIGION_ID = HIGHEST_RELIGION_ID

HIGHEST_PROMOTION_ID = 0
for promotion in GameInfo.UnitPromotions() do
	HIGHEST_PROMOTION_ID = promotion.ID
end
MapModData.HIGHEST_PROMOTION_ID = HIGHEST_PROMOTION_ID

FIRST_GP_ACTION = GameInfoTypes.EA_ACTION_TAKE_LEADERSHIP
FIRST_SPELL_ID = 0
FIRST_COMBAT_ACTION_ID = 0
for eaAction in GameInfo.EaActions() do
	if eaAction.AICombatRole and FIRST_COMBAT_ACTION_ID == 0 then
		FIRST_COMBAT_ACTION_ID = eaAction.ID
	end	
	if eaAction.SpellClass and FIRST_SPELL_ID == 0 then
		FIRST_SPELL_ID = eaAction.ID
	end
	LAST_SPELL_ID = eaAction.ID
end
MapModData.FIRST_SPELL_ID = FIRST_SPELL_ID
--print("FIRST_SPELL_ID", FIRST_SPELL_ID)
--print("FIRST_COMBAT_ACTION_ID", FIRST_COMBAT_ACTION_ID)

HIGHEST_PROMOTION_ID = 0
for promotionInfo in GameInfo.UnitPromotions() do
	local id = promotionInfo.ID
	if HIGHEST_PROMOTION_ID < id then
		HIGHEST_PROMOTION_ID = id
	end
end

MAP_W, MAP_H =		Map.GetGridSize()
MAX_RANGE =			Map.PlotDistance(0, 0, math.floor(MAP_W / 2 + 0.5), MAP_H - 1)	--other side of world (sort of)

---------------------------------------------------------------
-- Cached Tables
---------------------------------------------------------------

gg_unitPrefixUnitIDs = {}
gg_bToCheapToHire = {}
gg_eaSpecial = {}
gg_baseUnitPower = {}
gg_normalizedUnitPower = {}
gg_gpTempType = {}
gg_regularCombatType = {}		--"troops", "ship", "construct" (siege, landship, dirigible); these are all regular units
gg_unitTier = {}

for unitInfo in GameInfo.Units() do
	for i = 1, #UNIT_SUFFIXES do
		local suffix = UNIT_SUFFIXES[i]
		local unitPrefix, count = string.gsub(unitInfo.Type, suffix, "")
		if count == 1 then
			--print(unitPrefix, unitInfo.Type)
			gg_unitPrefixUnitIDs[unitPrefix] = gg_unitPrefixUnitIDs[unitPrefix] or {}
			gg_unitPrefixUnitIDs[unitPrefix][#gg_unitPrefixUnitIDs[unitPrefix] + 1] = unitInfo.ID
			break
		end
	end
	local unitType = unitInfo.Type
	if string.find(unitType, "UNIT_WARRIORS") or string.find(unitType, "UNIT_SCOUTS") then
		gg_bToCheapToHire[unitInfo.ID] = true
		gg_unitTier[unitInfo.ID] = 1
	end
	if unitInfo.PrereqTech then
		local techInfo = GameInfo.Technologies[unitInfo.PrereqTech]
		gg_unitTier[unitInfo.ID] = techInfo.GridX + 1
	end


	gg_eaSpecial[unitInfo.ID] = unitInfo.EaSpecial
	gg_baseUnitPower[unitInfo.ID] = Game.GetUnitPower(unitInfo.ID)
	gg_normalizedUnitPower[unitInfo.ID] = math.floor(gg_baseUnitPower[unitInfo.ID] ^ 0.6667)
	if unitInfo.EaGPTempRole then
		gg_gpTempType[unitInfo.ID] = unitInfo.EaGPTempRole
	elseif not unitInfo.Special and not unitInfo.EaSpecial and unitInfo.CombatLimit == 100 then
		if unitInfo.EaLiving then
			gg_regularCombatType[unitInfo.ID] = "troops"
		elseif unitInfo.Domain == "DOMAIN_SEA" then
			gg_regularCombatType[unitInfo.ID] = "ship"
		else
			gg_regularCombatType[unitInfo.ID] = "construct"
		end
	end
end

gg_techTier = {}
gg_eaTechClass = {}
for techInfo in GameInfo.Technologies() do
	if not techInfo.Utility then
		gg_techTier[techInfo.ID] = techInfo.GridX + 1
		if techInfo.EaTechClass then
			gg_eaTechClass[techInfo.ID] = techInfo.EaTechClass
		end
	end
end


MapModData.civNamesByRace = MapModData.civNamesByRace or {}
local civNamesByRace = MapModData.civNamesByRace
for row in GameInfo.EaCiv_Races() do
	local nameID = GameInfoTypes[row.EaCivNameType]
	if nameID then
		local raceID = GameInfoTypes[row.EaRace]
		civNamesByRace[raceID] = civNamesByRace[raceID] or {}
		civNamesByRace[raceID][nameID] = true
	else
		print("!!!! WARNING: EaCiv_Races references non-existent civ name: ", row.EaCivNameType)
	end
end

--filled in EaPlotsInit
gg_naturalWonders = {}	--index by featureID; holds table with some NW info
gg_cachedMapPlots = {}	--keep some specific plot tables here that don't change (most =true so we can do index test)
----------------------------------------------------------------------------------------------------------------------------
-- Non-preserved globals 
----------------------------------------------------------------------------------------------------------------------------

gg_init = {}

--tables indexed 1st by iPlayer
gg_combatPointDiff = {}
gg_unitClusters = {}
gg_mercHireRate = {}
gg_campRange = {}
gg_fishingRange = {}
gg_whalingRange = {}
gg_slaveryPlayer = {[BARB_PLAYER_INDEX] = true}
gg_playerArcaneMod = {}
gg_playerCityPlotIndexes = {}
gg_cityRemoteImproveCount = {}	--index by iPlayer, iCity, type

--other tables using iPlayer
gg_eaNamePlayerTable = {}

--other tables
gg_aiOptionValues = {}
gg_peopleEverLivedByRowID = {}
gg_tradeAvailableTable = {}
gg_bHasPatronage = {}
gg_teamCanMeetGods = {}
gg_teamCanMeetFay = {}
gg_animalSpawnPlots = {pos = 0}
gg_animalSpawnInhibitTeams = {}
gg_playerPlotActionTargeted = {}	--index by iPlayer, iPlot, eaActionID, =iPerson
gg_summonedArchdemon = {}			--index by iPlayer but nil if none (= unitTypeID; can only have one at any time)
gg_calledArchangel = {}				--as above
gg_calledMajorSpirit = {}			--as above
gg_undeadSpawnPlots = {pos = 0}
gg_demonSpawnPlots = {pos = 0}
gg_sequencedAttacks = {pos = 0}
gg_cityPlotCoastalTest = {}
gg_remoteImprovePlot = {}		--index by iPlot; = "Lake", "FishingRes", "HuntingRes", "WhalingRes" [, "Mountain"]

--misc counts
gg_counts = {	freshWaterAbzuFollowerCities = 0,
				coastalAegirFollowerCities = 0,
				earthResWorkedByPloutonFollower = 0,
				stallionsOfEpona = 0,
				grapeAndSpiritsBuildingsBakkheiaFollowerCities = 0
}

----------------------------------------------------------------------------------------------------------------------------
-- State Shared tables
----------------------------------------------------------------------------------------------------------------------------

--Other shared tables
MapModData.gpRegisteredActions = MapModData.gpRegisteredActions or {}

--Active player UI
MapModData.knowlMaint = 0
MapModData.techCount = 0
MapModData.totalPopulationForKM = 0
MapModData.intelligentArchiveKMReduction = 0
MapModData.kmPerTechPerCitizen = 0
MapModData.civKMPercent = 0
MapModData.greatLibraryKMPercent = 0
MapModData.mercenaryNet = 0
MapModData.cultureLevel = 0
MapModData.nextCultureLevel = 0
MapModData.estCultureLevelChange = 0
MapModData.approachingCulturalLevel = 0
MapModData.cultureRate = 0
MapModData.faithFromCityStates = 0
MapModData.faithFromAzzTribute = 0
MapModData.faithFromToAhrimanTribute = 0
MapModData.faithFromGPs = 0
MapModData.numberGreatPeople = 0
MapModData.totalGreatPersonPoints = 0
MapModData.totalLivingTerrainStrength = 0
--MapModData.validForestJunglePlots = 0
--MapModData.originalForestJunglePlots = 0
MapModData.totalLivingTerrainPlots = 0
--MapModData.ownablePlots = 0
MapModData.techCostHelp = ""
--Unit Panel UI
MapModData.bShow = false
MapModData.bAllow = false
MapModData.text = ""
MapModData.integer = 0
--Misc control
MapModData.bAutoplay = false
MapModData.bBypassOnCanCreateTradeRoute = false
MapModData.bReverseOnCanCreateTradeRoute = false
MapModData.forcedUnitSelection = -1
MapModData.forcedInterfaceMode = -1

----------------------------------------------------------------------------------------------------------------------------
-- gT and referenced tables that are saved/restored through game save/loads
----------------------------------------------------------------------------------------------------------------------------

MapModData.gT = MapModData.gT or {} --use these 2 lines in any other state that needs gT so that run order doesn't matter
gT = MapModData.gT

gWorld = {}
gPlayers = {}			--idx by iPlayer
gPeople = {}			--arbitrary index
gDeadPeople = {}
gReligions = {}			--index by religionID (holds a table if founded; empty for now...)
gCities = {}			--arbitrary but unique index
gWorldUniqueAction = {}		--index by eaActionID; holds iPlayer while actively under construction, then -1 after built
gWonders = {}	
gEpics = {}				--index by EaEpics ID;		= nil or {mod, iPlayer} for created epics
gArtifacts = {}			--index by EaItmes ID;		= nil or {mod, iPlayer, locationType, locationIndex}, where locationType = "iPlot", "iPerson", or "iUnit"
gRaceDiploMatrix = {}	--index by player1 (observer), player2 (subject)


gT.gWorld = gWorld
gT.gPlayers = gPlayers
gT.gPeople = gPeople
gT.gDeadPeople = gDeadPeople
gT.gReligions = gReligions
gT.gCities = gCities
gT.gWorldUniqueAction = gWorldUniqueAction
gT.gWonders = gWonders
gT.gEpics = gEpics
gT.gArtifacts = gArtifacts
gT.gRaceDiploMatrix = gRaceDiploMatrix

----------------------------------------------------------------------------------------------------------------------------
-- Players
----------------------------------------------------------------------------------------------------------------------------

MapModData.playerType = MapModData.playerType or {}			-- index by iPlayer
MapModData.bHidden = MapModData.bHidden or {}
MapModData.realCivs = MapModData.realCivs or {}		--full plus CSs
MapModData.fullCivs = MapModData.fullCivs or {}	
MapModData.cityStates = MapModData.cityStates or {}
MapModData.gods = MapModData.gods or {}

local playerType = MapModData.playerType
local bHidden = MapModData.bHidden
gg_minorPlayerByTypeID = {}
print("Player Types by ID at game init:")
for iPlayer = 0, BARB_PLAYER_INDEX do
	local player = Players[iPlayer]
	if iPlayer == FAY_PLAYER_INDEX then
		print(iPlayer, ": Fay")
		gPlayers[iPlayer] = {}
		MapModData.playerType[iPlayer] = "Fay"
		MapModData.bHidden[iPlayer] = true
	elseif iPlayer == ANIMALS_PLAYER_INDEX then
		print(iPlayer, ": Animals")
		gPlayers[iPlayer] = {}
		MapModData.playerType[iPlayer] = "Animals"
		MapModData.bHidden[iPlayer] = true
	elseif iPlayer == BARB_PLAYER_INDEX then
		print(iPlayer, ": Barbs")
		gPlayers[iPlayer] = {}
		MapModData.playerType[iPlayer] = "Barbs"
	elseif iPlayer < GameDefines.MAX_MAJOR_CIVS then
		if player:GetStartingPlot() then
			print(iPlayer, ": FullCiv")
			local eaPlayer = {}
			gPlayers[iPlayer] = eaPlayer
			MapModData.playerType[iPlayer] = "FullCiv"
			MapModData.fullCivs[iPlayer] = eaPlayer		--shortlist so we don't always have to cycle through the long gPlayers
			MapModData.realCivs[iPlayer] = eaPlayer
		end
	elseif player:GetMinorCivTrait() == GameInfoTypes.MINOR_TRAIT_RELIGIOUS then
		print(iPlayer, ": God")
		local eaPlayer = {}
		gPlayers[iPlayer] = eaPlayer
		MapModData.playerType[iPlayer] = "God"
		MapModData.bHidden[iPlayer] = true
		MapModData.gods[iPlayer] = eaPlayer
		gg_minorPlayerByTypeID[player:GetMinorCivType()] = iPlayer
	elseif player:GetStartingPlot() then		--can't use IsEverAlive for CSs, but this works
		print(iPlayer, ": CityState")
		local eaPlayer = {}
		gPlayers[iPlayer] = eaPlayer
		MapModData.playerType[iPlayer] = "CityState"
		MapModData.cityStates[iPlayer] = eaPlayer
		MapModData.realCivs[iPlayer] = eaPlayer
		gg_minorPlayerByTypeID[player:GetMinorCivType()] = iPlayer
	end
end
