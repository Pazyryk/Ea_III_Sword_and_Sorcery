-- EaMain
-- Author: Pazyryk
-- DateCreated: 8/16/2011 7:17:51 PM
--------------------------------------------------------------

local EA_MEDIA_PACK_MIN_VERSION = 4

include("EaErrorHandler.lua")

print("Loading EaMain.lua...")
print("")
print("****************************************************************")
print("Installed mods:")
local unsortedInstalledMods = Modding.GetInstalledMods()
for key, modInfo in pairs(unsortedInstalledMods) do
	if modInfo.Enabled then
		print("*ENABLED: " .. modInfo.Name .. " (v " .. modInfo.Version .. ") " .. modInfo.ID)
		if modInfo.ID == "7a7395e6-ad0d-47c0-87f8-af9d8f6c94e9" then
			if modInfo.Version < EA_MEDIA_PACK_MIN_VERSION then
				HandleError10(function() error("Ea Media Pack version is too old; download v." .. EA_MEDIA_PACK_MIN_VERSION) end)
			end
		end
	else
		print("Disabled: " .. modInfo.Name .. " (v " .. modInfo.Version .. ") " .. modInfo.ID)	
	end
end
print("****************************************************************")
print("")

-------------------------------------------------------------------------------------------------------
-- Includes
-------------------------------------------------------------------------------------------------------


include("EaPlotUtils.lua")	
include("WhowardPlotIterators.lua")	

include("FLuaVector")
include("EaMathUtils.lua")
include("EaTableUtils.lua")
include("EaMiscUtils.lua")
include("EaCultureLevelHelper.lua")
include("EaGPSpawnHelper.lua")
include("EaFaithHelper.lua")
include("EaHealthHelper.lua")
include("EaVictoriesHelper.lua")
include("RiverConnections.lua")

include("EaDefines.lua")			--1st after utils (before any files that reference mod specific data)
include("TableSaverLoader.lua")		--2rd
include("EaInit.lua")				--3rd

include("_Debug.lua")
include("EaActions.lua")
include("EaSpells.lua")
include("EaAIActions.lua")			--depends on EaActions and EaSpells
include("EaAIPeople.lua")
include("EaAICivPlanning.lua")
include("EaAIStrategy.lua")

include("EaAIMercenaries.lua")
include("EaTrade.lua")
include("EaAnimals.lua")
include("EaArmageddon.lua")
include("EaArtifacts.lua")
include("EaBarbarians.lua")
include("EaCities.lua")			--depends on EaTrade
include("EaCivs.lua")
include("EaMagic.lua")
include("EaPeople.lua")			--depends on EaAIActions
include("EaPlots.lua")
include("EaPolicies.lua")
include("EaReligions.lua")
include("EaTechs.lua")
include("EaCivNaming.lua")

include("EaUnitCombat.lua")
include("EaUnits.lua")
include("EaWonders.lua")
include("EaYields.lua")
include("EaDiplomacy.lua")			--depends on EaPolicies
include("EaVictories.lua")

include("EaAIUnits.lua")
include("EaDebugUtils.lua")

include("EaTextUtils.lua")

local print = ENABLE_PRINT and print or function() end	--set in EaDefines.lua
local Dprint = DEBUG_PRINT and print or function() end	

-------------------------------------------------------------------------------------------------------
-- File Locals
-------------------------------------------------------------------------------------------------------
local BARB_PLAYER_INDEX = BARB_PLAYER_INDEX

--localized game and global tables
local Players = Players
local gPlayers = gPlayers
local playerType = MapModData.playerType
local bFullCivAI = MapModData.bFullCivAI
local fullCivs = MapModData.fullCivs

--localized game and library functions
local Clock = os.clock

--localized global functions
local HandleError10 =				HandleError10
local AICivsPerGameTurn =			AICivsPerGameTurn
local AIMercenaryPerGameTurn =		AIMercenaryPerGameTurn
local PlotsPerTurn =				PlotsPerTurn
local UnitPerCivTurn =				UnitPerCivTurn
local UpdateAllArtifacts =			UpdateAllArtifacts
local WondersPerCivTurn =			WondersPerCivTurn
local CityPerCivTurn =				CityPerCivTurn
local FullCivPerCivTurn =			FullCivPerCivTurn
local PolicyPerCivTurn =			PolicyPerCivTurn
local TechPerCivTurn =				TechPerCivTurn
local TestAllCivNamingConditions =	TestAllCivNamingConditions
local AICivRun =					AICivRun
local PeoplePerCivTurn =			PeoplePerCivTurn
local UpdateGlobalYields =			UpdateGlobalYields
local UpdateCityYields =			UpdateCityYields
local PeopleAfterTurn =				PeopleAfterTurn

--shared
local MapModData = MapModData

--file control
local g_lastPlayerID = -1
local g_lastTurn = 0		--this causes per turn functions to skip on turn 0 (so no animals)
local oldTime = Clock()
local startHuman = 0
local timerHuman = 0
local timerTurn = 0
local timerPlotsPerTurn = 0
local timerAllPerTurnFunctions = 0
local bInitialized = false

local g_iActivePlayer = Game.GetActivePlayer()
local g_autoSaveFreq = 5

-------------------------------------------------------------------------------------------------------
-- File Functions
-------------------------------------------------------------------------------------------------------

local function DebugHidden(iPlayer)
	local player = Players[iPlayer]
	for unit in player:Units() do
		print("!!!! ERROR: Hidden civ got a unit; gifted by AI? iPlayer/iUnit = ", iPlayer, unit:GetID())
		MapModData.bBypassOnCanSaveUnit = true
		unit:Kill(true, -1)
	end
end

local function PrintGameTurn(iPlayer, gameTurn)
		--New turn processing
		print("")
		print("")
		print("------------------------------------------------------------------------------------------------------")
		print("----------------------------------------- NEW GAME TURN: " .. gameTurn .. " ------------------------------------------")
		--TableSave(gT, "Ea")	--moved here from OnEndTurn()
		local newTime = Clock()
		timerTurn = newTime - oldTime
		oldTime = newTime
		print("AIAutoPlay = ", Game.GetAIAutoPlay())
		print("Turn timers:")
		print("Turn,         ", timerTurn)
		print("Human,        ", timerHuman)
		print("PerTurnFunctions, ", timerAllPerTurnFunctions)
		print("PlotsPerTurn, ", timerPlotsPerTurn)
		print("------------------------------------------------------------------------------------------------------")
		print("------------------------------------------------------------------------------------------------------")
end

local function PrintNewTurnForPlayer(iPlayer)
	-------------------------------------------------------------------------------------------------------
	-- "New turn for player..."
	-------------------------------------------------------------------------------------------------------
	if playerType[iPlayer] == "FullCiv" or playerType[iPlayer] == "Fay" then
		local eaPlayer = gPlayers[iPlayer]
		local leaderName = Locale.ConvertTextKey(PreGame.GetLeaderName(iPlayer))
		local raceInfo = GameInfo.EaRaces[eaPlayer.race]
		local nameTrait = eaPlayer.eaCivNameID
		if nameTrait then
			print("------------------------  New turn for player ".. iPlayer .. ", " .. Locale.ConvertTextKey(PreGame.GetCivilizationShortDescription(iPlayer)) .. " ("..Locale.ConvertTextKey(raceInfo.Description).."), Leader: " .. leaderName  .. " ------------------------")
		else
			print("------------------------  New turn for player ".. iPlayer .. ", " .. Locale.ConvertTextKey(PreGame.GetCivilizationShortDescription(iPlayer))  .. " ------------------------")
		end
	elseif playerType[iPlayer] == "CityState" then
		local player = Players[iPlayer]
		print("------------------------  New turn for player ".. iPlayer .. ", City State: " .. player:GetName() .. " ------------------------")
	elseif playerType[iPlayer] == "God" then
		local player = Players[iPlayer]
		print("------------------------  New turn for player ".. iPlayer .. ", God: " .. player:GetName() .. " ------------------------")
	elseif playerType[iPlayer] == "Barbs" then
		print("------------------------  New turn for player ".. iPlayer .. ", Barbarians ------------------------")
	end
end

local function AfterEveryPlayerTurn(iPlayer)	-- Runs at begining of next player's turn (iPlayer is the last player)
	print("Running AfterEveryPlayerTurn ", iPlayer)
	--if playerType[iPlayer] == "FullCiv" then
		AnalyzeUnitClusters(iPlayer)			--may need for barbs too if they get really nasty
		PeopleAfterTurn(iPlayer)
		if not bFullCivAI[iPlayer] then
			OnPlayerAdoptPolicyDelayedEffect()
		end
	--end
end

-------------------------------------------------------------------------------------------------------
-- Interface
-------------------------------------------------------------------------------------------------------




local function OnPlayerDoTurn(iPlayer)	-- Runs at begining of turn for all living players, starting at turn 1 for human and turn 2 for all AIs (depends on settler???)
	print("OnPlayerDoTurn ", iPlayer)
	local gameTurn = Game.GetGameTurn()
	
	timerAllPerTurnFunctionsStart = Clock()
	local player = Players[iPlayer]

	if g_lastTurn < gameTurn then
	-------------------------------------------------------------------------------------------------------
	-- Per game turn functions
	-------------------------------------------------------------------------------------------------------
		g_lastTurn = gameTurn
		if Game.GetAIAutoPlay() == 0 then
			MapModData.bAutoplay = false
			bFullCivAI[g_iActivePlayer] = false
		end
		PrintGameTurn(iPlayer, gameTurn)
		timerAllPerTurnFunctions = 0

		EaArmageddonPerTurn()
		AICivsPerGameTurn()
		AIMercenaryPerGameTurn()
		local startPlotsPerTurn = Clock()
		PlotsPerTurn()
		timerPlotsPerTurn = Clock() - startPlotsPerTurn
		EncampmentsPerTurn()
		AnimalsPerTurn()
		ReligionPerGameTurn()
		CityStateFollowerCityCounting()

	elseif iPlayer == 1 then
		timerHuman = Clock() - startHuman
	end

	--if gameTurn < 2 then		--just plan on it not working first 2 turns
	--	return
	--end

	if playerType[g_lastPlayerID] == "FullCiv" then 
		AfterEveryPlayerTurn(g_lastPlayerID)
	end
	g_lastPlayerID = iPlayer
	local startOtherPerTurn = Clock()
	PrintNewTurnForPlayer(iPlayer)

	-------------------------------------------------------------------------------------------------------
	-- Per turn functions
	-------------------------------------------------------------------------------------------------------
	if playerType[iPlayer] == "FullCiv" then
		--Full civs
		local eaPlayer = gPlayers[iPlayer]
		UnitPerCivTurn(iPlayer)						--must be before PeoplePerCivTurn(iPlayer)
		UpdateAllArtifacts()
		WondersPerCivTurn(iPlayer)
		CityPerCivTurn(iPlayer)						--must be before FullCivPerCivTurn (religion counting) and PeoplePerCivTurn (gp point counting)
		UpdateCivReligion(iPlayer, true)
		PolicyPerCivTurn(iPlayer)
		TechPerCivTurn(iPlayer)
		FullCivPerCivTurn(iPlayer)
		if bFullCivAI[iPlayer] then
			AICivRun(iPlayer)
			AIMercenaryPerCivTurn(iPlayer)
		end
		if not eaPlayer.eaCivNameID then
			if TestAllCivNamingConditions(iPlayer) then
				--g_lastPlayerID = -1
				--print("TestAllCivNamingConditions returned true; aborting OnPlayerDoTurn (we should never see this iPlayer again)")
				--return
			end
		end


		PeoplePerCivTurn(iPlayer)					--needs to be before global and city updates
		UpdateGlobalYields(iPlayer, nil, true)		--for now, only GP effects so only full players
		UpdateCityYields(iPlayer, nil, nil, true)
		TestUpdateVictory(iPlayer)
		print("****  Finished Lua functions for major player " .. iPlayer .. "  ****")
	elseif playerType[iPlayer] == "Fay" then
		--The Fay
		UpdateFayScore(iPlayer)
		DebugHidden(iPlayer)
	elseif playerType[iPlayer] == "CityState" then
		--City states
		UnitPerCivTurn(iPlayer)
		UpdateCivReligion(iPlayer, true)
		CityStatePerCivTurn(iPlayer)
		AIMercenaryPerCivTurn(iPlayer)
		UpdateGlobalYields(iPlayer, "Gold", true)
		UpdateCityYields(iPlayer, nil, nil, true)
	elseif playerType[iPlayer] == "God" then
		--Gods
		DebugHidden(iPlayer)
	else	--Barbs and Animals
		UnitPerCivTurn(iPlayer)
	end
	
	if iPlayer == Game.GetActivePlayer() then		--won't autosave during Autoplay (TO DO: find out when autosave happens during Autoplay and fix!)
		--if gameTurn % g_autoSaveFreq == 0 then
		--	EaAutoSave(gameTurn)
		--end
		startHuman = Clock()		
	end
	timerAllPerTurnFunctions = timerAllPerTurnFunctions - timerAllPerTurnFunctionsStart + Clock()

end
GameEvents.PlayerDoTurn.Add(function(iPlayer) return HandleError10(OnPlayerDoTurn, iPlayer) end)

----------------------------------------------------------------
--AutoSave 
----------------------------------------------------------------


local function OnCanAutoSave(bInitial, bPostTurn)
	print("Intercepting base game autosave to preserve Lua data")
	TableSave(gT, "Ea")
	local saveStr
	if bInitial then
		saveStr = "auto/AutoSave_Initial_Ea Year " .. Game.GetGameTurn()
	else
		saveStr = "auto/AutoSave_Ea Year " .. Game.GetGameTurn()
	end
	print("Saving game as ", saveStr)
	UI.SaveGame(saveStr)
	return false
end
GameEvents.CanAutoSave.Add(OnCanAutoSave)


--TO DO: The initial game engine autosaves are corrupt for mod data (and name wrong anyway); get rid of them.
--AutoSave_0000 BC-4000.Civ5Save
--AutoSave_Initial_0000 BC-4000.Civ5Save

----------------------------------------------------------------
-- Autoplay
----------------------------------------------------------------

function Autoplay(turns)
	turns = turns or 5
	turns = turns > 0 and turns or 5
	bFullCivAI[g_iActivePlayer] = true
	print("Starting Autoplay; turns/returnAsPlayer = ", turns, gWorld.returnAsPlayer)
	MapModData.bAutoplay = true
	Game.SetAIAutoPlay(turns, gWorld.returnAsPlayer)
	local iNewActivePlayer = Game.GetActivePlayer()
	--gPlayers[iNewActivePlayer] = gPlayers[gWorld.returnAsPlayer]		--for UI during Autoplay

	print("Active player ID = ", Game.GetActivePlayer())
	print("Player slots in Autoplay; iPlayer/GetSlotStatus/GetSlotClaim/GetCivilization = ")
	
	--Debug: give observer all the resource reveal techs so we can see them
	--Note that this affects CS techs, so it's not game-effect neutral
	local observerTeam = Teams[OBSERVER_TEAM]
	observerTeam:SetHasTech(GameInfoTypes.TECH_MINING, true)
	observerTeam:SetHasTech(GameInfoTypes.TECH_EARTH_DIVINATION, true)
	observerTeam:SetHasTech(GameInfoTypes.TECH_MATHEMATICS, true)
	observerTeam:SetHasTech(GameInfoTypes.TECH_MOLY_VISIBLE, true)

end
LuaEvents.EaAutoplay.Add(Autoplay)


----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	print("Active player change (new/old): ", iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)

----------------------------------------------------------------
-- Init
----------------------------------------------------------------
HandleError10(OnLoadEaMain)
--OnLoadEaMain()		--in EaInit.lua
bInitialized = true