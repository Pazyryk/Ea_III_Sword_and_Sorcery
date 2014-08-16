-- EaInit
-- Author: Pazyryk
-- DateCreated: 1/15/2013 8:34:25 PM
--------------------------------------------------------------
print("Loading EaInit.lua...")

local HandleError10 = HandleError10

local function InitForNewGame()

	--gWorld (nils listed for bookkeeping)
	gWorld.personCount =				0
	gWorld.sumOfAllMana =				EaSettings.STARTING_SUM_OF_ALL_MANA
	gWorld.armageddonStage =			0
	gWorld.armageddonSap =				0
	gWorld.bAllCivsHaveNames =			false
	gWorld.bSurfacerDiscoveredDeepMining = false
	gWorld.evilControl =				"NewGame"	--Ready, Open, Sealed
	gWorld.bAnraHolyCityExists =		false			--will be true after founding and then false if razed
	gWorld.bEnableEasyVaultSeal =		false
	gWorld.bEnableProtectorVC =			false
	gWorld.returnAsPlayer =				Game.GetActivePlayer()
	gWorld.azzConvertNum =				0
	gWorld.anraConvertNum =				0
	gWorld.weaveConvertNum =			0
	gWorld.livingTerrainConvertStr =	0
	gWorld.panCivsEver =				0
	gWorld.bActivePlayerTimeStop =		false
	gWorld.encampments =				{}
	gWorld.calledMajorSpirits =			{}

	--gRaceDiploMatrix; index by player1 (observer), player2 (subject); these are start values modified through game by city razing
	for row in GameInfo.EaRaces_InitialHatreds() do
		local observerRaceID = GameInfoTypes[row.ObserverRace]
		local subjectRaceID = GameInfoTypes[row.SubjectRace]
		gRaceDiploMatrix[observerRaceID] = gRaceDiploMatrix[observerRaceID] or {}
		gRaceDiploMatrix[observerRaceID][subjectRaceID] = row.Value
	end

	--gWonders
	gWonders[GameInfoTypes.EA_WONDER_ARCANE_TOWER] =	{}		--index by EaWonders ID;	= nil or {mod, iPlot} for built wonders
			
	--gPlayers
	for iPlayer = 0, BARB_PLAYER_INDEX do
		local player = Players[iPlayer]
		local eaPlayer = gPlayers[iPlayer]		--player tables added in EaDefines.lua
		if MapModData.playerType[iPlayer] == "FullCiv" then
			eaPlayer.eaCivNameID = false
			eaPlayer.bUsesDivineFavor = false
			eaPlayer.bIsFallen = false
			eaPlayer.bRenouncedMaleficium = false	
			eaPlayer.ImprovementsByID = {}
			eaPlayer.ImprovedResourcesByID = {}
			eaPlayer.resourcesInBorders = {}	--visible only; for AI and possibly traits
			eaPlayer.plotSpecialsInBorders = {}	--for AI and possibly traits
			eaPlayer.addedResources = {}
			eaPlayer.blockedUnitsByID = {}
			eaPlayer.blockedBuildingsByID = {}
			eaPlayer.sustainedPromotions = {}
			eaPlayer.religionID = -1
			eaPlayer.leaderEaPersonIndex = -1	--iPerson or -1 for No Leader
			eaPlayer.nationalUniqueAction = {}		--index by eaActionID; holds -1 while actively under construction, then 1 after built
			eaPlayer.itemList = {}	--holds EaArtifact IDs
			eaPlayer.epicList = {}	--holds EaEpic IDs
			eaPlayer.resourcesNearCapitalByID = {}
			eaPlayer.totalResourcePlots = 0
			eaPlayer.ownedPlots = 0
			eaPlayer.culturalLevel = 0
			eaPlayer.cumCulture = 0
			eaPlayer.aveCulturePerPop = 0
			eaPlayer.policyCount = 0
			eaPlayer.techs = {}
			eaPlayer.rpFromDiffusion = 0
			eaPlayer.rpFromConquest = 0
			eaPlayer.tradeTotals = {}	--index by other iPlayer; holds only base trade so we can calculate Trade Mission value
			eaPlayer.tradeMissions = {}	--index by other iPlayer, holds GP mod
			eaPlayer.aiUniqueTargeted = {}	--some AI values here so we don't have to nil check
			eaPlayer.aiMerchantTooSmallToConsider = 0
			eaPlayer.mercenaries = {}
			eaPlayer.revealedNWs = {}
			eaPlayer.revealedPlotEffects = {}	--indexed by iPlot
			eaPlayer.atWarWith = {[62] = true, [63] = true}
			eaPlayer.conquests = {}

			eaPlayer.manaForCultOfLeavesFounder = 0
			eaPlayer.manaForCultOfAbzuFounder = 0
			eaPlayer.manaForCultOfAegirFounder = 0
			eaPlayer.manaForCultOfPloutonFounder = 0
			eaPlayer.manaForCultOfCahraFounder = 0
			eaPlayer.manaForCultOfEponaFounder = 0
			eaPlayer.manaForCultOfBakkheiaFounder = 0
			eaPlayer.cultureManaFromWildlands = 0
			eaPlayer.leaderLandXP = 0
			eaPlayer.leaderSeaXP = 0
			eaPlayer.scienceDistributionCarryover = 0
			eaPlayer.foodDistributionCarryover = 0
			eaPlayer.productionDistributionCarryover = 0
			eaPlayer.goldDistributionCarryover = 0
			eaPlayer.aiNumTradeRoutesTargeted = 0
			eaPlayer.savedFaithFromManaDivineFavorSwap = 0
			eaPlayer.manaConsumed = 0
					
			eaPlayer.delayedGPclass = false
			eaPlayer.delayedGPsubclass = false
			eaPlayer.bHasDiscoveredAhrimansVault = false
			eaPlayer.livingTerrainStrengthAdded = false
			eaPlayer.livingTerrainAdded = false
			eaPlayer.fallenFollowersDestr = false
			eaPlayer.civsCorrectedProvisional = false
			eaPlayer.civsCorrected = false
			eaPlayer.protectorProphsRituals = false
			eaPlayer.declinedNameID = false
			eaPlayer.faerieTribute = false
			eaPlayer.majorSpiritsTribute = false
			eaPlayer.cityStatePatronage = false
			eaPlayer.trainingXP = false
			eaPlayer.aiSeekingName = false
			eaPlayer.aiStage = false
			eaPlayer.aiObsoletedCivPlans = false
			eaPlayer.aiCompletedCivPlans = false
			eaPlayer.aiContingency2Plans = false
			eaPlayer.aiFocusPlans = false
			eaPlayer.aiContingency1Plans = false
			eaPlayer.aiNamingPlans = false
			eaPlayer.aiStartPlans = false
			eaPlayer.aiWarriorsBlock = false
			eaPlayer.gpDivineScience = false
			eaPlayer.gpArcaneScience = false
			eaPlayer.manaToSealAhrimansVault = false

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
		elseif MapModData.playerType[iPlayer] == "Fay" then
			eaPlayer.bIsFallen = false
			eaPlayer.bRenouncedMaleficium = false
			eaPlayer.blockedBuildingsByID = {}
			eaPlayer.religionID = GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
			eaPlayer.race = GameInfoTypes.EARACE_FAY
			eaPlayer.eaCivNameID = -1		--any value here allows appearance in diplo list
			eaPlayer.leaderEaPersonIndex = GameInfoTypes.EAPERSON_FAND		-- Queen of the Fay
			eaPlayer.culturalLevel = 20		--used in Diplo relations
			eaPlayer.revealedNWs = {}
			eaPlayer.atWarWith = {[62] = true, [63] = true}
		elseif MapModData.playerType[iPlayer] == "CityState" then
			eaPlayer.eaCivNameID = false
			eaPlayer.bIsFallen = false
			eaPlayer.bRenouncedMaleficium = false
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
			eaPlayer.atWarWith = {[62] = true, [63] = true}
		elseif MapModData.playerType[iPlayer] == "God" then
			eaPlayer.bIsFallen = false
			eaPlayer.bRenouncedMaleficium = false
			eaPlayer.blockedBuildingsByID = {}
			eaPlayer.religionID = GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
			eaPlayer.atWarWith = {[62] = true, [63] = true}
		elseif MapModData.playerType[iPlayer] == "Animals" then
			eaPlayer.bIsFallen = false
			eaPlayer.bRenouncedMaleficium = false
			eaPlayer.sustainedPromotions = {}
			eaPlayer.atWarWith = {}
			for iLoopPlayer, loopPlayerType in pairs(MapModData.playerType) do
				if loopPlayerType ~= "Animals" and loopPlayerType ~= "Barbs" then
					eaPlayer.atWarWith[iLoopPlayer] = true
				end
			end
		elseif MapModData.playerType[iPlayer] == "Barbs" then
			eaPlayer.bIsFallen = false
			eaPlayer.bRenouncedMaleficium = false
			eaPlayer.sustainedPromotions = {}
			eaPlayer.atWarWith = {}
			for iLoopPlayer, loopPlayerType in pairs(MapModData.playerType) do
				if loopPlayerType ~= "Animals" and loopPlayerType ~= "Barbs" then
					eaPlayer.atWarWith[iLoopPlayer] = true
				end
			end
		end
	end
end

local function SetStrictTables()
	--after all keys are added for new or loaded game
	MakeTableStrict(gWorld)
	for _, eaPlayer in pairs(gPlayers) do
		MakeTableStrict(eaPlayer)
	end
	for _, eaPerson in pairs(gPeople) do
		MakeTableStrict(eaPerson)			--new people made strict in EaPeople.lua
	end
	for _, eaCity in pairs(gCities) do
		MakeTableStrict(eaCity)				--new cities made strict in EaCities.lua
	end
end

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

	--Load persisted Lua table data if it exists (else this is a new game)
	local bNewGame = not TableLoad(gT, "Ea")

	if bNewGame then
		print("Initializiing for new game...")
		InitForNewGame()
	else
		print("Initializing for loaded game...")	
	end

	SetStrictTables()

	--init Lua files
	--TestResyncGPIndexes()
	EaEncampmentsInit(bNewGame)
	EaCivsInit(bNewGame)
	EaCivNamingInit(bNewGame)
	EaPoliciesInit(bNewGame)
	EaTechsInit(bNewGame)
	EaPlotsInit(bNewGame)	
	EaPeopleInit(bNewGame)
	EaCityInit(bNewGame)		--after EaPlotsInit
	EaYieldsInit(bNewGame)
	EaAIActionsInit(bNewGame)	--after EaPlotsInit
	EaAIUnitsInit(bNewGame)
	EaUnitCombatInit(bNewGame)
	EaUnitsInit(bNewGame)
	EaMagicInit(bNewGame)
	AIMercInit(bNewGame)
	EaWondersInit(bNewGame)
	EaActionsInit(bNewGame)
	EaDiplomacyInit(bNewGame)

	gg_init.bModInited = true

	TableSave(gT, "Ea")		--first run is hardest with DB disk lag, so do it now rather than at first autosave (which can hang the game)

	PrintStrictLuaErrors()

	--This is the last thing to run at file load. Next to run is the function below when player enters the game.
end

local function OnEnterGame()   --Runs when Begin or Countinue Your Journey pressed
	print("Player entering game ...")

	--trim dead players (after file inits in case someone is resurected)
	for iPlayer in pairs(MapModData.realCivs) do
		if not Players[iPlayer]:IsAlive() then
			DeadPlayer(iPlayer, nil)
		end
	end

	gg_init.bEnteredGame = true
	MapModData.bEnteredGame = true

	if MapModData.error then			--move later?
		LuaEvents.EaErrorPopupDoErrorPopup(MapModData.error)		
	end


	print("Debug - end of OnEnterGame")

	--There is a exe autosave right after this, but GameEvents.GameSave is specifically disabled (in dll)
	--for first save since it causes an intermittent game hang in new games
end
local function X_OnEnterGame() return HandleError10(OnEnterGame) end
Events.LoadScreenClose.Add(X_OnEnterGame)

