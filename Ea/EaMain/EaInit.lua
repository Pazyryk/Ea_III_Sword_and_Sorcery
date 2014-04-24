-- EaInit
-- Author: Pazyryk
-- DateCreated: 1/15/2013 8:34:25 PM
--------------------------------------------------------------
print("Loading EaInit.lua...")

local playerType =	MapModData.playerType
local fullCivs =	MapModData.fullCivs
local cityStates =	MapModData.cityStates
local realCivs =	MapModData.realCivs



function OnLoadEaMain()   --Called from the bottom of EaMain after all included files have been processed

	--Missing File errors (terminate with error)
	local expectedTableFiles = {}
	local fileCount = 0
	for row in GameInfo.Ea_ExpectedTableFiles() do
		fileCount = fileCount + 1
		expectedTableFiles[fileCount] = row.FileName
	end
	local missingFiles = ""
	for i = 1, fileCount do
		local expectedFile = expectedTableFiles[i]
		local bLoaded = false
		for row in GameInfo.EaDebugTableCheck() do
			if expectedFile == row.FileName then
				bLoaded = true
				break
			end
		end
		if not bLoaded then
			print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			print("!!!! ERROR: "..expectedFile.." was not loaded to end of file !!!!")
			print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			missingFiles = missingFiles .. " " .. expectedFile
		end
	end
	if missingFiles == "" then
		print("All expected SQL and XML files loaded to end of file...")
	else
		error("MISSING FILES: " .. missingFiles .. ". This game is not playable!")
	end

	--Other DB errors (print warning)
	for row in GameInfo.Ea_DBErrors() do
		print("!!!! WARNGING: ", row.ErrorText, row.ItemText)
	end

	ContextPtr:SetInputHandler(InputHandler)

	local bNewGame = true
	local DBQuery = Modding.OpenSaveData().Query
	for row in DBQuery("SELECT name FROM sqlite_master WHERE name='Ea_Info'") do
		if row.name then bNewGame = false end	-- presence of Ea_Info tells us that game already in session
	end

	--if bNewGame then
	--	InitEaSpecialCivs()
	--end

	InitPlayerVariables()
	if bNewGame then
		print("Initializiing for new game...")
		TableSave(gT, "Ea")
	else
		print("Initializing for loaded game...")	
		TableLoad(gT, "Ea")
	end

	EaEncampmentsInit(bNewGame)
	EaCivsInit(bNewGame)
	EaCivNamingInit(bNewGame)
	EaPoliciesInit(bNewGame)
	EaTechsInit(bNewGame)
	EaPlotsInit(bNewGame)		--before cities
	EaPeopleInit(bNewGame)
	EaCityInit(bNewGame)
	EaYieldsInit(bNewGame)
	EaAIUnitsInit(bNewGame)
	EaUnitCombatInit(bNewGame)
	EaUnitsInit(bNewGame)
	AIMercInit(bNewGame)
	EaWondersInit(bNewGame)

end

function OnEnterGame()   --Runs when Begin or Countinue Your Journey pressed
	print("Player entering game ...")
	--Game.SetAIAutoPlay(0, 0)
	print("AIAutoplay = ", Game.GetAIAutoPlay())
	RegisterOnSaveCallback()
	EaPlotsInitialized()
	--FoundTheWeaveOfEa()
	LuaEvents.TopPanelInfoDirty()
end
Events.LoadScreenClose.Add(OnEnterGame)


----------------------------------------------------------------
-- Input Handler
----------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_F11 then
			TableSave(gT, "Ea")
		    print("Quicksaving...")
			UI.QuickSave()
        	return true
		--elseif wParam == Keys.S and UIManager:GetControl() then
		--	print("ctrl-s detected")
		--	OnSaveClicked()
		--	return true
		elseif wParam == Keys.VK_RETURN then	--called in AI turns?
			LuaEvents.ActionInfoPanelOnEndTurnClicked()
			return true
		end
	end
end

----------------------------------------------------------------
-- Game Save
----------------------------------------------------------------

function OnQuickSaveClicked()
	print("QuickSaveGame clicked")
	TableSave(gT, "Ea")
	UI.QuickSave()
end

function RegisterOnSaveCallback()
	local QuickSaveButton = ContextPtr:LookUpControl("/InGame/GameMenu/QuickSaveButton")
	QuickSaveButton:RegisterCallback( Mouse.eLClick, OnQuickSaveClicked )
	print ("SaveGame Buttons callbacks registered...")
end

----------------------------------------------------------------
-- Init eaPlayers
----------------------------------------------------------------

function InitPlayerVariables()
	for iPlayer = 0, BARB_PLAYER_INDEX do
		local player = Players[iPlayer]
		if playerType[iPlayer] == "FullCiv" then
			local eaPlayer = {}
			gPlayers[iPlayer] = eaPlayer
			fullCivs[iPlayer] = eaPlayer		--shortlist so we don't always have to cycle through the long gPlayers
			realCivs[iPlayer] = eaPlayer
			gg_playerValues[iPlayer] = {}
			gg_unitPositions[iPlayer] = {}
			eaPlayer.eaCivNameID = nil
			eaPlayer.ImprovementsByID = {}
			eaPlayer.ImprovedResourcesByID = {}
			eaPlayer.resourcesInBorders = {}	--visible only; for AI and possibly traits
			eaPlayer.plotSpecialsInBorders = {}	--for AI and possibly traits
			eaPlayer.addedResources = {}
			eaPlayer.blockedUnitsByID = {}
			eaPlayer.blockedBuildingsByID = {}
			eaPlayer.sustainedPromotions = {}
			eaPlayer.unitAttackAtRiskPerson = {}
			eaPlayer.religionID = -1
			eaPlayer.leaderEaPersonIndex = -1	--iPerson or -1 for No Leader
			eaPlayer.nationalUniqueAction = {}		--index by eaActionID; holds -1 while actively under construction, then 1 after built
			eaPlayer.itemList = {}	--holds EaArtifact IDs
			eaPlayer.epicList = {}	--holds EaEpic IDs
			eaPlayer.resourcesNearCapitalByID = {}
			eaPlayer.totalResourcePlots = 0
			eaPlayer.ownedPlots = 0
			eaPlayer.culturalLevel = 0
			eaPlayer.policyCount = 0
			eaPlayer.cumPopTurns = 0
			eaPlayer.techCount = 0
			eaPlayer.rpFromDiffusion = 0
			eaPlayer.rpFromConquest = 0
			eaPlayer.tradeTotals = {}	--index by other iPlayer; holds only base trade so we can calculate Trade Mission value
			eaPlayer.tradeMissions = {}	--index by other iPlayer, holds GP mod
			eaPlayer.aiUniqueTargeted = {}	--some AI values here so we don't have to nil check
			eaPlayer.actionPlotTargeted = {}
			eaPlayer.aiMerchantTooSmallToConsider = 0
			eaPlayer.mercenaries = {}
			eaPlayer.revealedNWs = {}
			eaPlayer.revealedPlotEffects = {}	--indexed by iPlot
			local civID = player:GetCivilizationType()	 
			local civRace = GameInfo.Civilizations[civID].EaRace
			if civRace == "EARACE_SIDHE" then
				eaPlayer.race = GameInfoTypes.EARACE_SIDHE
				eaPlayer.classPoints = {1, 1, 1, 1, 1, 0, 0}		--Engineer, Merchant, Sage, Artist, Warrior, Devout, Thaumaturge
			elseif civRace == "EARACE_HELDEOFOL" then
				eaPlayer.race = GameInfoTypes.EARACE_HELDEOFOL
				eaPlayer.classPoints = {1, 0, 0, 0, 1, 0, 0}
				eaPlayer.firstKillByOrcs = false		--used???
			else	--man
				eaPlayer.race = GameInfoTypes.EARACE_MAN
				eaPlayer.classPoints = {1, 1, 1, 1, 1, 0, 0}
			end
		elseif playerType[iPlayer] == "Fay" then
			local eaPlayer = {}
			gPlayers[iPlayer] = eaPlayer
			gg_playerValues[iPlayer] = {}
			eaPlayer.blockedBuildingsByID = {}
			eaPlayer.religionID = GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
			eaPlayer.race = GameInfoTypes.EARACE_FAY
			eaPlayer.eaCivNameID = -1		--any value here allows appearance in diplo list
			eaPlayer.leaderEaPersonIndex = GameInfoTypes.EAPERSON_FAND		-- Queen of the Fay
			eaPlayer.culturalLevel = 20		--used in Diplo relations
			eaPlayer.revealedNWs = {}
		elseif playerType[iPlayer] == "CityState" then
			local eaPlayer = {}
			gPlayers[iPlayer] = eaPlayer
			cityStates[iPlayer] = eaPlayer
			realCivs[iPlayer] = eaPlayer
			gg_playerValues[iPlayer] = {}
			eaPlayer.ImprovementsByID = {}
			eaPlayer.ImprovedResourcesByID = {}
			eaPlayer.resourcesInBorders = {}	--visible only; for AI and possibly traits
			eaPlayer.plotSpecialsInBorders = {}	--for AI and possibly traits
			eaPlayer.addedResources = {}
			eaPlayer.blockedUnitsByID = {}
			eaPlayer.blockedBuildingsByID = {}
			eaPlayer.sustainedPromotions = {}
			eaPlayer.religionID = -1
			local minorCivInfo = GameInfo.MinorCivilizations[player:GetMinorCivType()]
			eaPlayer.race = GameInfoTypes[minorCivInfo.EaRace]
			eaPlayer.mercenaries = {}
		elseif playerType[iPlayer] == "God" then
			local eaPlayer = {}
			gPlayers[iPlayer] = eaPlayer
			gg_playerValues[iPlayer] = {}
			eaPlayer.blockedBuildingsByID = {}
			eaPlayer.religionID = GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
		elseif playerType[iPlayer] == "Animals" then
			local eaPlayer = {}
			gPlayers[iPlayer] = eaPlayer
			gg_playerValues[iPlayer] = {}
			eaPlayer.sustainedPromotions = {}
		elseif playerType[iPlayer] == "Barbs" then
			local eaPlayer = {}
			gPlayers[iPlayer] = eaPlayer
			gg_playerValues[iPlayer] = {}
			eaPlayer.sustainedPromotions = {}
		end
	end
end