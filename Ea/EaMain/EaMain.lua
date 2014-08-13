-- EaMain
-- Author: Pazyryk
-- DateCreated: 8/16/2011 7:17:51 PM
--------------------------------------------------------------

local HOTFIX = "none"
local DLL_COMMIT = "90f1f21"
local DLL_DEBUG_BUILD = false
local EA_MEDIA_PACK_MIN_VERSION = 5

-------------------------------------------------------------------------------------------------------

include("EaErrorHandler.lua")

if not GameDefines.EA_DLL_VERSION then
	error("Mod does not see modded dll for some reason.")
end


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
				HandleError10(function() error("Ea Media Pack version is too old; download current v." .. EA_MEDIA_PACK_MIN_VERSION .. " to play") end)
			end
		end
	else
		print("Disabled: " .. modInfo.Name .. " (v " .. modInfo.Version .. ") " .. modInfo.ID)	
	end
end
print("")
print("hotfix          : " .. HOTFIX)
print("dll commit      : " .. DLL_COMMIT)
print("dll debug build : " .. tostring(DLL_DEBUG_BUILD))
print("****************************************************************")
print("")

-------------------------------------------------------------------------------------------------------
-- Includes
-------------------------------------------------------------------------------------------------------

--Utilities that don't need gT data
include("EaPlotUtils.lua")	
include("WhowardPlotIterators.lua")	
include("FLuaVector")
include("EaMathUtils.lua")
include("EaTableUtils.lua")
include("EaMiscUtils.lua")
include("RiverConnections.lua")

--Defines and initialization
include("EaDefines.lua")			--1st after utils (before any files that reference mod specific data)
include("TableSaverLoader.lua")		--2rd
include("EaInit.lua")				--3rd
include("_Debug.lua")

--Helpers
include("EaCultureLevelHelper.lua")
include("EaGPSpawnHelper.lua")
include("EaFaithHelper.lua")
include("EaHealthHelper.lua")
include("EaVictoriesHelper.lua")

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
include("EaNIMBY.lua")

include("EaDebugUtils.lua")

include("EaTextUtils.lua")

local print = ENABLE_PRINT and print or function() end	--set in EaDefines.lua

-------------------------------------------------------------------------------------------------------
-- File Locals
-------------------------------------------------------------------------------------------------------
local BARB_PLAYER_INDEX = BARB_PLAYER_INDEX

--localized game and global tables
local Players = Players
local gPlayers = gPlayers
local playerType = MapModData.playerType
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
local g_bHumanOrFirstInAutoplayTurn = false
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
		local newTime = Clock()
		timerTurn = newTime - oldTime
		oldTime = newTime
		print("Lua memory (Mb) = ", collectgarbage("count") / 1000)
		print("AIAutoPlay = ", Game.GetAIAutoPlay())
		print("Turn timers:")
		print("Turn,         ", timerTurn)
		print("Human,        ", timerHuman)
		print("PerTurnFunctions, ", timerAllPerTurnFunctions)
		print("PlotsPerTurn, ", timerPlotsPerTurn)
		print("------------------------------------------------------------------------------------------------------")
		print("------------------------------------------------------------------------------------------------------")
end

local function PrintNewTurnForPlayer(iPlayer, gameTurn)
	-------------------------------------------------------------------------------------------------------
	-- "New turn for player..."
	-------------------------------------------------------------------------------------------------------
	if playerType[iPlayer] == "FullCiv" or playerType[iPlayer] == "Fay" then
		local eaPlayer = gPlayers[iPlayer]
		local leaderName = Locale.ConvertTextKey(PreGame.GetLeaderName(iPlayer))
		local raceInfo = GameInfo.EaRaces[eaPlayer.race]
		local nameTrait = eaPlayer.eaCivNameID
		if nameTrait then
			print("------------------------  New turn for player ".. iPlayer .. ", " .. Locale.ConvertTextKey(PreGame.GetCivilizationShortDescription(iPlayer)) .. " ("..Locale.ConvertTextKey(raceInfo.Description).."), Leader: " .. leaderName  .. " (turn " .. gameTurn .. ") --------------")
		else
			print("------------------------  New turn for player ".. iPlayer .. ", " .. Locale.ConvertTextKey(PreGame.GetCivilizationShortDescription(iPlayer))  .. " (turn " .. gameTurn .. ") --------------")
		end
	elseif playerType[iPlayer] == "CityState" then
		local player = Players[iPlayer]
		print("------------------------  New turn for player ".. iPlayer .. ", City State: " .. player:GetName() .. " (turn " .. gameTurn .. ") --------------")
	elseif playerType[iPlayer] == "God" then
		local player = Players[iPlayer]
		print("------------------------  New turn for player ".. iPlayer .. ", God: " .. player:GetName() .. " (turn " .. gameTurn .. ") --------------")
	elseif playerType[iPlayer] == "Barbs" then
		print("------------------------  New turn for player ".. iPlayer .. ", Barbarians (turn " .. gameTurn .. ") --------------")
	end
end

local function AfterEveryPlayerTurn(iPlayer)
	print("AfterEveryPlayerTurn ", iPlayer)

	if playerType[iPlayer] == "FullCiv" then
		AnalyzeUnitClusters(iPlayer)			--may need for barbs too if they get really nasty
		PeopleAfterTurn(iPlayer)
		if Players[iPlayer]:IsHuman() then
			OnPlayerAdoptPolicyDelayedEffect()
		end
	end
	if g_bHumanOrFirstInAutoplayTurn then
		timerHuman = Clock() - startHuman
		g_bHumanOrFirstInAutoplayTurn = false
	end
end

-------------------------------------------------------------------------------------------------------
-- Interface
-------------------------------------------------------------------------------------------------------

local function OnPlayerDoTurn(iPlayer)	-- Runs at begining of turn for all living players, starting at turn 1 for human and turn 2 for all AIs (depends on settler???)
	AfterEveryPlayerTurn(g_lastPlayerID)
	g_lastPlayerID = iPlayer
	print("OnPlayerDoTurn ", iPlayer)

	local gameTurn = Game.GetGameTurn()
	if gameTurn == 0 then return end

	timerAllPerTurnFunctionsStart = Clock()
	local player = Players[iPlayer]

	if g_lastTurn < gameTurn then
		g_lastTurn = gameTurn

		-------------------------------------------------------------------------------------------------------
		-- Pre-Lua per game turn functions
		-------------------------------------------------------------------------------------------------------
		if Game.GetAIAutoPlay() == 0 then
			MapModData.bAutoplay = false
		else
			g_bHumanOrFirstInAutoplayTurn = true
		end
		PrintGameTurn(iPlayer, gameTurn)
		timerAllPerTurnFunctions = 0
		TestResyncGPIndexes()
		UpdateNIMBYTurn(gameTurn)
		EaArmageddonPerTurn()
		AICivsPerGameTurn()
		AIMercenaryPerGameTurn()
		local startPlotsPerTurn = Clock()
		PlotsPerTurn()
		timerPlotsPerTurn = Clock() - startPlotsPerTurn
		BarbSpawnPerTurn()
		AnimalsPerTurn()
		ReligionPerGameTurn()
		TestEnableProtectorConditions()
	end

	g_bHumanOrFirstInAutoplayTurn = g_bHumanOrFirstInAutoplayTurn or iPlayer == g_iActivePlayer

	local startOtherPerTurn = Clock()
	PrintNewTurnForPlayer(iPlayer, gameTurn)

	-------------------------------------------------------------------------------------------------------
	-- Per turn functions
	-------------------------------------------------------------------------------------------------------
	if playerType[iPlayer] == "FullCiv" then
		--Full civs
		UnitPerCivTurn(iPlayer)						--must be before PeoplePerCivTurn(iPlayer)
		UpdateAllArtifacts()
		WondersPerCivTurn(iPlayer)
		CityPerCivTurn(iPlayer)						--must be before FullCivPerCivTurn (religion counting) and PeoplePerCivTurn (gp point counting)
		UpdateCivReligion(iPlayer, true)
		PolicyPerCivTurn(iPlayer)
		TechPerCivTurn(iPlayer)
		FullCivPerCivTurn(iPlayer)
		if not player:IsHuman() then
			AICivRun(iPlayer)
			AIMercenaryPerCivTurn(iPlayer)
		end
		if not gPlayers[iPlayer].eaCivNameID then
			TestAllCivNamingConditions(iPlayer)
		end
		DiploPerCivTurn(iPlayer)
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
		CityPerCivTurn(iPlayer)
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
	
	if g_bHumanOrFirstInAutoplayTurn then
		--if gameTurn % g_autoSaveFreq == 0 then
		--	EaAutoSave(gameTurn)
		--end
		startHuman = Clock()
	end
	timerAllPerTurnFunctions = timerAllPerTurnFunctions - timerAllPerTurnFunctionsStart + Clock()

end
local function X_OnPlayerDoTurn(iPlayer) return HandleError10(OnPlayerDoTurn, iPlayer) end
GameEvents.PlayerDoTurn.Add(X_OnPlayerDoTurn)

----------------------------------------------------------------
--Save 
----------------------------------------------------------------

local function OnGameSave()
	print("OnGameSave ")
	TableSave(gT, "Ea")
end
local function X_OnGameSave() return HandleError10(OnGameSave) end
GameEvents.GameSave.Add(X_OnGameSave)

----------------------------------------------------------------
-- Autoplay
----------------------------------------------------------------

function Autoplay(turns)
	turns = turns or 5
	turns = turns > 0 and turns or 5
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
-- Input Handler
----------------------------------------------------------------

local KeyEvents = KeyEvents
local Keys = Keys

function InputHandler(uiMsg, wParam, lParam)
	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_RETURN then
			print("Main context InputHandler is calling ActionInfoPanelOnEndTurnClicked")
			LuaEvents.ActionInfoPanelOnEndTurnClicked()
			return true
		end
	end
end
ContextPtr:SetInputHandler(InputHandler)

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
local OnLoadEaMain = OnLoadEaMain
HandleError10(OnLoadEaMain)		--in EaInit.lua
bInitialized = true