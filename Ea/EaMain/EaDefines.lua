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
-- Debug
--------------------------------------------------------------

ENABLE_PRINT = true
DEBUG_PRINT = false
MapModData.DEBUG_PRINT = DEBUG_PRINT
MapModData.bDebugShowHiddenBuildings = true

MapModData.bDisableEnabledPolicies = true

--------------------------------------------------------------
-- Settings
--------------------------------------------------------------

UNADJUSTED_STARTING_SUM_OF_ALL_MANA = 300000
MOD_MEMORY_HALFLIFE = 30	--What AI is doing now is twice as important as this many turns ago

--------------------------------------------------------------
-- Global Constants
--------------------------------------------------------------

WeakKeyMetatable = {__mode = "k"}
OutOfRangeReturnZeroMetaTable = {__index = function() return 0 end}	--return 0 rather than nil for out of range index

local gameSpeedMultipliers = {	[GameInfoTypes.GAMESPEED_QUICK] = 0.67,
								[GameInfoTypes.GAMESPEED_STANDARD] = 1,
								[GameInfoTypes.GAMESPEED_EPIC] = 1.33,
								[GameInfoTypes.GAMESPEED_MARATHON] = 2	}

local mapSizeMultipliers = {	[GameInfoTypes.WORLDSIZE_DUEL] = 0.5,
								[GameInfoTypes.WORLDSIZE_TINY] = 0.5,
								[GameInfoTypes.WORLDSIZE_SMALL] = 0.67,
								[GameInfoTypes.WORLDSIZE_STANDARD] = 1,	
								[GameInfoTypes.WORLDSIZE_LARGE ] = 1.33,
								[GameInfoTypes.WORLDSIZE_HUGE ] = 2	}

GAME_SPEED = Game.GetGameSpeedType()
MAP_SIZE = Map.GetWorldSize()
GAME_SPEED_MULTIPLIER = gameSpeedMultipliers[GAME_SPEED]
MAP_SIZE_MULTIPLIER = mapSizeMultipliers[MAP_SIZE]

MapModData.GAME_SPEED = GAME_SPEED
MapModData.MAP_SIZE = MAP_SIZE
MapModData.GAME_SPEED_MULTIPLIER = GAME_SPEED_MULTIPLIER
MapModData.MAP_SIZE_MULTIPLIER = MAP_SIZE_MULTIPLIER

print("Game speed, map size, speed multiplier, size multiplier = ", gameSpeed, mapSize, GAME_SPEED_MULTIPLIER, MAP_SIZE_MULTIPLIER)

MapModData.STARTING_SUM_OF_ALL_MANA = math.floor(UNADJUSTED_STARTING_SUM_OF_ALL_MANA * GAME_SPEED_MULTIPLIER * MAP_SIZE_MULTIPLIER)

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
gg_bNormalCombatUnit = {}
gg_bNormalLivingCombatUnit = {}
gg_gpTempType = {}

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
	gg_eaSpecial[unitInfo.ID] = unitInfo.EaSpecial
	gg_baseUnitPower[unitInfo.ID] = Game.GetUnitPower(unitInfo.ID)
	gg_normalizedUnitPower[unitInfo.ID] = math.floor(gg_baseUnitPower[unitInfo.ID] ^ 0.6667)
	if unitInfo.EaGPTempRole then
		gg_gpTempType[unitInfo.ID] = unitInfo.EaGPTempRole
	elseif not unitInfo.Special and not unitInfo.EaSpecial and unitInfo.CombatLimit == 100 then
		gg_bNormalCombatUnit[unitInfo.ID] = true
		if unitInfo.EaLiving then
			gg_bNormalLivingCombatUnit[unitInfo.ID] = true
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

gg_naturalWonders = {}	--index by featureID; filled in EaPlots Init

----------------------------------------------------------------------------------------------------------------------------
-- Non-preserved globals 
----------------------------------------------------------------------------------------------------------------------------

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

--yields for human UI
MapModData.mercenaryNet = 0

--misc
MapModData.forcedUnitSelection = -1
MapModData.forcedInterfaceMode = -1
MapModData.integer = 0

----------------------------------------------------------------------------------------------------------------------------
-- gT and referenced tables that are saved/restored through game save/loads
----------------------------------------------------------------------------------------------------------------------------

MapModData.gT = MapModData.gT or {} --use these 2 lines in any other state that needs gT so that run order doesn't matter
gT = MapModData.gT

gWorld = {	sumOfAllMana =				MapModData.STARTING_SUM_OF_ALL_MANA,
			armageddonStage =			0,
			armageddonSap =				0,
			bAllCivsHaveNames =			false,
			returnAsPlayer =			Game.GetActivePlayer(),
			encampments =				{},
			azzConvertNum =				0,
			anraConvertNum =			0,
			weaveConvertNum =			0,
			livingTerrainConvertStr =	0,
			calledMajorSpirits =		{},
			panCivsEver =				0
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
