-- EaDefines
-- Author: Pazyryk
-- DateCreated: 8/16/2011 7:24:16 PM
--------------------------------------------------------------

print("Loading EaDefines.lua...")

--------------------------------------------------------------
-- Debug
--------------------------------------------------------------

ENABLE_PRINT = true
DEBUG_PRINT = false
MapModData.DEBUG_PRINT = DEBUG_PRINT
MapModData.bDebugShowHiddenBuildings = true

--------------------------------------------------------------
-- Settings
--------------------------------------------------------------

MapModData.STARTING_SUM_OF_ALL_MANA = 1000000
MOD_MEMORY_HALFLIFE = 50	--What AI is doing now is twice as important as this many turns ago

--------------------------------------------------------------
-- Global Constants
--------------------------------------------------------------

WeakKeyMetatable = {__mode = "k"}


local gameSpeedMultipliers = {	[GameInfoTypes.GAMESPEED_QUICK] = 1,
								[GameInfoTypes.GAMESPEED_STANDARD] = 1.5,
								[GameInfoTypes.GAMESPEED_EPIC] = 2,
								[GameInfoTypes.GAMESPEED_MARATHON] = 3	}

local mapSizeMultipliers = {	[GameInfoTypes.WORLDSIZE_DUEL] = 1,
								[GameInfoTypes.WORLDSIZE_TINY] = 1,
								[GameInfoTypes.WORLDSIZE_SMALL] = 1,
								[GameInfoTypes.WORLDSIZE_STANDARD] = 1.1,	
								[GameInfoTypes.WORLDSIZE_LARGE ] = 1.2,
								[GameInfoTypes.WORLDSIZE_HUGE ] = 1.3	}

local gameSpeed = Game.GetGameSpeedType()
local mapSize = Map.GetWorldSize()
GAME_SPEED_MULTIPLIER = gameSpeedMultipliers[gameSpeed]
MAP_SIZE_MULTIPLIER = mapSizeMultipliers[mapSize]

print("Game speed, map size, speed multiplier, size multiplier = ", gameSpeed, mapSize, GAME_SPEED_MULTIPLIER, MAP_SIZE_MULTIPLIER)

UNIT_SUFFIXES = {"_MAN", "_SIDHE", "_ORC"}

GP_TXT_KEYS = {	Engineer = "TXT_KEY_EA_ENGINEER",
				Merchant = "TXT_KEY_EA_MERCHANT",
				Sage = "TXT_KEY_EA_SAGE",
				Artist = "TXT_KEY_EA_ARTIST",
				Warrior = "TXT_KEY_EA_WARRIOR",
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
				Summoner = "TXT_KEY_EA_SUMMONER",
				Necromancer = "TXT_KEY_EA_NECROMANCER",
				Lich = "TXT_KEY_EA_LICH"	}
MapModData.GP_TXT_KEYS = GP_TXT_KEYS

BARB_PLAYER_INDEX = GameDefines.BARBARIAN_PLAYER
local EaSetupDB = Modding.OpenUserData("EaSetupData", 1)
FAY_PLAYER_INDEX = EaSetupDB.GetValue("FAY_PLAYER_INDEX")
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

LEADER_XP = GameInfo.EaActions.EA_ACTION_TAKE_LEADERSHIP.DoXP


---------------------------------------------------------------
-- Cached Tables
---------------------------------------------------------------
gg_unitPrefixUnitIDs = {}
gg_bToCheapToHire = {}
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


gg_bNormalCombatUnit = {}
gg_bNormalLivingCombatUnit = {}
gg_gpTempType = {}
for unitInfo in GameInfo.Units() do
	if unitInfo.EaGPTempRole then
		gg_gpTempType[unitInfo.ID] = unitInfo.EaGPTempRole
	elseif not unitInfo.Special and unitInfo.CombatLimit == 100 then
		gg_bNormalCombatUnit[unitInfo.ID] = true
		if unitInfo.EaLiving then
			gg_bNormalLivingCombatUnit[unitInfo.ID] = true
		end
	end
end


gg_naturalWonders = {}	--index by featureID; filled in EaPlots Init
----------------------------------------------------------------------------------------------------------------------------
-- State Shared tables
----------------------------------------------------------------------------------------------------------------------------
--players
MapModData.playerType = MapModData.playerType or {}			-- index by iPlayer
MapModData.bFullCivAI = MapModData.bFullCivAI or {}			-- index by iPlayer; tells us if under AI control (inclues human under autoplay when all is working)
MapModData.bHidden = MapModData.bHidden or {}

local playerType = MapModData.playerType
local bFullCivAI = MapModData.bFullCivAI
local bHidden = MapModData.bHidden
print("Player Types by ID at game init:")
for iPlayer = 0, BARB_PLAYER_INDEX do
	local player = Players[iPlayer]
	if iPlayer == FAY_PLAYER_INDEX then
		print(iPlayer, ": Fay")
		playerType[iPlayer] = "Fay"
		bHidden[iPlayer] = true
	elseif iPlayer == ANIMALS_PLAYER_INDEX then
		print(iPlayer, ": Animals")
		playerType[iPlayer] = "Animals"
		bHidden[iPlayer] = true
	elseif iPlayer == BARB_PLAYER_INDEX then
		print(iPlayer, ": Barbs")
		playerType[iPlayer] = "Barbs"
	elseif player and player:IsAlive() then
		if iPlayer < GameDefines.MAX_MAJOR_CIVS then
			print(iPlayer, ": FullCiv")
			playerType[iPlayer] = "FullCiv"
			bFullCivAI[iPlayer] = not (iPlayer == Game.GetActivePlayer())		--fix for multiplayer
		elseif player:GetMinorCivTrait() == GameInfoTypes.MINOR_TRAIT_RELIGIOUS then
			print(iPlayer, ": God")
			playerType[iPlayer] = "God"
			bHidden[iPlayer] = true
		else
			print(iPlayer, ": CityState")
			playerType[iPlayer] = "CityState"
		end
	end
end

--These are set in Init
MapModData.fullCivs = MapModData.fullCivs or {}	
MapModData.cityStates = MapModData.cityStates or {}				
MapModData.realCivs = MapModData.realCivs or {}		


--yields for human UI
MapModData.mercenaryNet = 0

--misc
MapModData.forcedUnitSelection = -1
MapModData.forcedInterfaceMode = -1
MapModData.integer = 0

----------------------------------------------------------------------------------------------------------------------------
-- Non-preserved globals 
----------------------------------------------------------------------------------------------------------------------------

--tables indexed 1st by iPlayer
gg_playerValues = {}
gg_combatPointDiff = {}
gg_unitPositions = {}
gg_unitClusters = {}
gg_mercHireRate = {}
gg_cityLakesDistMatrix = {}
gg_cityFishingDistMatrix = {}
gg_cityWhalingDistMatrix = {}
gg_cityCampResDistMatrix = {}
gg_fishingRange = {}
gg_whalingRange = {}
gg_campRange = {}
gg_slaveryPlayer = {[BARB_PLAYER_INDEX] = true}

--other tables using iPlayer
gg_eaNamePlayerTable = {}

--other tables
gg_aiOptionValues = {}
gg_peopleEverLivedByRowID = {}
gg_lakes = {}				--each is table with .x, .y
gg_fishingBoatResources = {}
gg_whales = {}
gg_campResources = {}
gg_tradeAvailableTable = {}
gg_bHasPatronage = {}
gg_teamCanMeetGods = {}
gg_teamCanMeetFay = {}
gg_animalSpawnPlots = {pos = 0}
gg_animalSpawnInhibitTeams = {}

----------------------------------------------------------------------------------------------------------------------------
-- gT and referenced tables that are saved/restored through game save/loads
----------------------------------------------------------------------------------------------------------------------------

MapModData.gT = MapModData.gT or {} --use these 2 lines in any other state that needs gT so that run order doesn't matter
gT = MapModData.gT

gWorld = {	sumOfAllMana =				MapModData.STARTING_SUM_OF_ALL_MANA,
			bAllCivsHaveNames =			false,
			returnAsPlayer =			Game.GetActivePlayer(),
			encampments =				{},
			azzConvertNum =				0,
			anraConvertNum =			0,
			weaveConvertNum =			0,
			livingTerrainConvertStr =	0,
			stallionsOfEpona =			0,
			riverSideCultOfPureWatersFollowerCities = 0,
			coastalCultOfAegirFollowerCities = 0,
			bakkheiaMana = 0
			}



gPlayers = {}			--idx by iPlayer
gPeople = {}			--arbitrary index
gDeadPeople = {}
gReligions = {}			--index by religionID (holds a table if founded; empty for now...)
gCities = {}			--arbitrary but unique index
gWorldUniqueAction = {}		--index by eaActionID; holds iPlayer while actively under construction, then -1 after built
gWonders = {[GameInfoTypes.EA_WONDER_ARCANE_TOWER] =	{}		--index by EaWonders ID;	= nil or {mod, iPlot} for built wonders
			
			}	

gEpics = {}				--index by EaEpics ID;		= nil or {mod, iPlayer} for created epics
gArtifacts = {}				--index by EaItmes ID;		= nil or {mod, iPlayer, locationType, locationIndex}, where locationType = "iPlot", "iPerson", or "iUnit"


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







-- Init tables and define initial values
-- TableLoad will add/modify values if this is a loaded game, but not delete any values







