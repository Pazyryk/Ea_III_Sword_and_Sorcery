-- EaSetupFunctions
-- Author: Pazyryk
-- DateCreated: 6/28/2013 4:32:34 PM
--------------------------------------------------------------
--Used by modified GameSetupScreen.lua and AdvancedSetup.lua

local EA_HIGHEST_PLAYABLE_CIV_TYPE_ID = 1

function LoadEaSettings()
	--Moves settings from EaSetupDB to PreGame
	print("Running LoadEaSettings...")
	
	local EaSetupDB = Modding.OpenUserData("EaSetupData", 1)

	local numMinorCivs = EaSetupDB.GetValue("NUMBER_MINOR_CIVS")
	if not numMinorCivs or numMinorCivs < 0 or numMinorCivs > 24 then
		numMinorCivs = GameInfo.Worlds[PreGame.GetWorldSize()].DefaultMinorCivs
	end
	PreGame.SetNumMinorCivs(numMinorCivs)

	local gameSpeed = EaSetupDB.GetValue("GAME_SPEED")
	if gameSpeed then
		PreGame.SetGameSpeed(gameSpeed)
	end
	
	local mapScript = EaSetupDB.GetValue("MAP_SCRIPT")
	if mapScript then
		PreGame.SetMapScript(mapScript)
	end

	local randomMapScript = EaSetupDB.GetValue("RANDOM_MAP_SCRIPT")
	if mapScript then
		PreGame.SetRandomMapScript(mapScript == 1)
	end

	local worldSize = EaSetupDB.GetValue("WORLD_SIZE")
	if worldSize then
		PreGame.SetWorldSize(worldSize)
	end

	local randomWorldSize = EaSetupDB.GetValue("RANDOM_WORLD_SIZE")
	if randomWorldSize then
		PreGame.SetRandomWorldSize(randomWorldSize == 1)
	end

	for victoryInfo in GameInfo.Victories() do
		local victoryType = victoryInfo.Type
		local bDisabled = EaSetupDB.GetValue(victoryType) == 0
		PreGame.SetVictory(victoryInfo.ID, not bDisabled)		--all checked by default
	end

	local maxTurns = EaSetupDB.GetValue("MAX_TURNS") or 0
	PreGame.SetMaxTurns(maxTurns)

	for optionInfo in GameInfo.GameOptions() do
		local optionType = optionInfo.Type
		if optionInfo.Visible then
			local bSet = EaSetupDB.GetValue(optionType) == 1
			PreGame.SetGameOption(optionType, bSet)		--set with true/false
		elseif optionType == "GAMEOPTION_NO_TUTORIAL" then
			PreGame.SetGameOption(optionType, true)
		else
			PreGame.SetGameOption(optionType, false)
		end
	end

	for i = 0, GameDefines.MAX_MAJOR_CIVS do
		local civilization = EaSetupDB.GetValue("CIVILIZATION_" .. i)
		if not civilization or civilization > EA_HIGHEST_PLAYABLE_CIV_TYPE_ID then
			civilization = -1
		end
		PreGame.SetCivilization(i, civilization)
		local handicap = EaSetupDB.GetValue("HANDICAP_" .. i)
		if handicap then
			PreGame.SetHandicap(i, handicap)
		end
	end

	--Any other non-setable settings here
	PreGame.SetEra(0)

end

function SaveEaSettings()
	--Moves settings from PreGame to EaSetupDB and sets any mod required options for play
	--Note: SetValue will convert booleans to 0 or 1 with type number; text and numbers retain type
	print("Running SaveEaSettings...")

	local EaSetupDB = Modding.OpenUserData("EaSetupData", 1)
	
	local numMinorCivs = PreGame.GetNumMinorCivs()
	if not numMinorCivs or numMinorCivs < 0 or numMinorCivs > 40 then
		numMinorCivs = GameInfo.Worlds[PreGame.GetWorldSize()].DefaultMinorCivs
	end
	EaSetupDB.SetValue("NUMBER_MINOR_CIVS", numMinorCivs)
	EaSetupDB.SetValue("GAME_SPEED", PreGame.GetGameSpeed())
	EaSetupDB.SetValue("MAP_SCRIPT", PreGame.GetMapScript())
	EaSetupDB.SetValue("RANDOM_MAP_SCRIPT", PreGame.IsRandomMapScript())
	EaSetupDB.SetValue("WORLD_SIZE", PreGame.GetWorldSize())
	EaSetupDB.SetValue("RANDOM_WORLD_SIZE", PreGame.IsRandomWorldSize())
	for victoryInfo in GameInfo.Victories() do
		local victoryType = victoryInfo.Type
		EaSetupDB.SetValue(victoryType, PreGame.IsVictory(victoryType))
	end
	EaSetupDB.SetValue("MAX_TURNS", PreGame.GetMaxTurns())
	for optionInfo in GameInfo.GameOptions() do
		local optionType = optionInfo.Type
		if optionInfo.Visible then
			EaSetupDB.SetValue(optionType, PreGame.GetGameOption(optionType))
		end
	end
	for i = 0, GameDefines.MAX_MAJOR_CIVS do
		EaSetupDB.SetValue("CIVILIZATION_" .. i, PreGame.GetCivilization(i))
		EaSetupDB.SetValue("HANDICAP_" .. i, PreGame.GetHandicap(i))
	end

end

function SetEaRequiredOptions()
	local EaSetupDB = Modding.OpenUserData("EaSetupData", 1)
	EaSetupDB.SetValue("AUTO_UI_ASSETS_FOR_RESTORATION", OptionsManager.GetAutoUIAssets_Cached())
	EaSetupDB.SetValue("SMALL_UI_ASSETS_FOR_RESTORATION", OptionsManager.GetSmallUIAssets_Cached())
	OptionsManager.SetAutoUIAssets_Cached(false)
	OptionsManager.SetSmallUIAssets_Cached(true)
	OptionsManager.CommitGameOptions()
end

local randNumber = 0
function GetPseudoRand10000()					--middle square
	randNumber = randNumber > 1000 and randNumber or os.clock() * 100
	print("GetPseudoRand10000; seed = ", randNumber)
	while randNumber < 1000 do
		randNumber = (randNumber + 11) ^ 2
	end
	randNumber = randNumber ^ 2
	randNumber = math.floor(randNumber / 100)
	randNumber = randNumber % 10000
	print("result = ", randNumber)
	return randNumber
end

local function GetNextAvailablePlayerTeamIndexes()		
	for iPlayer = 1, GameDefines.MAX_MAJOR_CIVS - 1 do
		if PreGame.GetSlotStatus(iPlayer) == SlotStatus.SS_OBSERVER then
			print("GetNextAvailablePlayerTeamIndexes returning ", iPlayer, iPlayer)	--use iTeam = iPlayer for now
			return iPlayer, iPlayer
		end
	end
	error("GetNextAvailablePlayerIndex could not find available iPlayer or iTeam for extra Ea civs; too many players?")
end


function SetEaCivs()
	print("Running SetEaCivs...")
	print("Player slots before SetEaCivs (iPlayer/GetSlotStatus/GetSlotClaim/GetCivilization):")
	for i = 0, GameDefines.MAX_PLAYERS - 1 do
		print(i, PreGame.GetSlotStatus(i), PreGame.GetSlotClaim(i), PreGame.GetCivilization(i))
	end

	local EaSetupDB = Modding.OpenUserData("EaSetupData", 1)

	--this will give us more Man than Sidhe but with some slots left random
	--local eaRandCivAddOrder = {0, 1, -1,  0, -1,  0, 1,  0, -1,  0, 1,  0, -1,  0, 1,  0, -1,  0, 1,  0, -1,  0, 1,  0, -1,  0, 1} -- 0 Man; 1 Sidhe; -1 Random
	--local eaRandCivAddOrder = {0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0} -- 0 Man; 1 Sidhe; -1 Random
	--local randCivNum = 0

	for iPlayer = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		PreGame.SetTeam(iPlayer, iPlayer)
		if PreGame.GetSlotStatus(iPlayer) == SlotStatus.SS_COMPUTER then
			PreGame.SetSlotClaim(iPlayer, SlotClaim.SLOTCLAIM_ASSIGNED)	--Advanced settup screws this up (or maybe it doesn't matter?)
		end

		if PreGame.GetSlotStatus(iPlayer) == SlotStatus.SS_COMPUTER then
			if PreGame.GetCivilization(iPlayer) == -1 then
				local civID = 0						--Man
				local rand = GetPseudoRand10000()
				if rand < 3333 then
					civID = 1						--Sidhe
				end
				print("Ea start picking civ for random slot: ", iPlayer, civID)
				PreGame.SetCivilization(iPlayer, civID)
			end
			local civID = PreGame.GetCivilization(iPlayer)
			if civID == 0 then
				PreGame.SetCivilizationDescription(iPlayer, "TXT_KEY_EA_MAN_TRIBE")
				PreGame.SetCivilizationShortDescription(iPlayer, "TXT_KEY_EA_MAN_TRIBE")
				PreGame.SetCivilizationAdjective(iPlayer, "TXT_KEY_EA_MAN")
			elseif civID == 1 then
				PreGame.SetCivilizationDescription(iPlayer, "TXT_KEY_EA_SIDHE_TRIBE")
				PreGame.SetCivilizationShortDescription(iPlayer, "TXT_KEY_EA_SIDHE_TRIBE")
				PreGame.SetCivilizationAdjective(iPlayer, "TXT_KEY_EA_SIDHE")
			elseif civID == 2 then
				PreGame.SetCivilizationDescription(iPlayer, "TXT_KEY_EA_HELDEOFOL_TRIBE")
				PreGame.SetCivilizationShortDescription(iPlayer, "TXT_KEY_EA_HELDEOFOL_TRIBE")
				PreGame.SetCivilizationAdjective(iPlayer, "TXT_KEY_EA_HELDEOFOL")
			end
			PreGame.SetLeaderName(iPlayer, "TXT_KEY_EA_NO_LEADER")
		--elseif PreGame.GetSlotStatus(iPlayer) == SlotStatus.SS_OBSERVER then
			--Add The Fay player here and move up observer; always one more civ than the player or map asks for

		--	break		
		end

	end

	--The Fay
	local iPlayer, iTeam = GetNextAvailablePlayerTeamIndexes()
	EaSetupDB.SetValue("FAY_PLAYER_INDEX", iPlayer)
	PreGame.SetSlotStatus(iPlayer, SlotStatus.SS_COMPUTER)
	PreGame.SetCivilization(iPlayer, 3)			--This will be The Fay civ 
	PreGame.SetSlotClaim(iPlayer, SlotClaim.SLOTCLAIM_ASSIGNED)	--matters?
	--PreGame.SetSlotStatus(iPlayer + 1, SlotStatus.SS_OBSERVER)
	PreGame.SetCivilizationDescription(iPlayer, "TXT_KEY_EA_CIV_THE_FAY")
	PreGame.SetCivilizationShortDescription(iPlayer, "TXT_KEY_EA_CIV_THE_FAY")
	PreGame.SetCivilizationAdjective(iPlayer, "TXT_KEY_EA_CIV_THE_FAY")
	PreGame.SetLeaderName(iPlayer, "TXT_KEY_EAPERSON_FAND")

	--Animals
	--[[ Added in dll
	local iPlayer, iTeam = GetNextAvailablePlayerTeamIndexes()
	EaSetupDB.SetValue("ANIMALS_PLAYER_INDEX", iPlayer)
	PreGame.SetSlotStatus(iPlayer, SlotStatus.SS_COMPUTER)
	PreGame.SetCivilization(iPlayer, 4)			--This will be the Animals 
	PreGame.SetSlotClaim(iPlayer, SlotClaim.SLOTCLAIM_ASSIGNED)	--matters?
	PreGame.SetCivilizationDescription(iPlayer, "TXT_KEY_EA_NOTSHOWN")
	PreGame.SetCivilizationShortDescription(iPlayer, "TXT_KEY_EA_NOTSHOWN")
	PreGame.SetCivilizationAdjective(iPlayer, "TXT_KEY_EA_NOTSHOWN")
	PreGame.SetLeaderName(iPlayer, "TXT_KEY_THE_LION_KING")
	]]

	print("Player slots after SetEaCivs (iPlayer/GetSlotStatus/GetSlotClaim/GetCivilization):")
	for i = 0, GameDefines.MAX_PLAYERS - 1 do
		print(i, PreGame.GetSlotStatus(i), PreGame.GetSlotClaim(i), PreGame.GetCivilization(i))
	end

	PreGame.SetNumMinorCivs(41)

end

