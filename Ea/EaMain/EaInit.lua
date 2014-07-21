-- EaInit
-- Author: Pazyryk
-- DateCreated: 1/15/2013 8:34:25 PM
--------------------------------------------------------------
print("Loading EaInit.lua...")

local function InitForNewGame()

	--gWorld
	gWorld.sumOfAllMana =				MapModData.STARTING_SUM_OF_ALL_MANA
	gWorld.armageddonStage =			0
	gWorld.armageddonSap =				0
	gWorld.bAllCivsHaveNames =			false
	gWorld.returnAsPlayer =				Game.GetActivePlayer()
	gWorld.encampments =				{}
	gWorld.azzConvertNum =				0
	gWorld.anraConvertNum =				0
	gWorld.weaveConvertNum =			0
	gWorld.livingTerrainConvertStr =	0
	gWorld.calledMajorSpirits =			{}
	gWorld.panCivsEver =				0
	
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
			eaPlayer.eaCivNameID = nil
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
			eaPlayer.culturalLevelChange = 0
			eaPlayer.policyCount = 0

			--eaPlayer.cumPopTurns = 0
			eaPlayer.techCount = 0
			eaPlayer.rpFromDiffusion = 0
			eaPlayer.rpFromConquest = 0
			eaPlayer.tradeTotals = {}	--index by other iPlayer; holds only base trade so we can calculate Trade Mission value
			eaPlayer.tradeMissions = {}	--index by other iPlayer, holds GP mod
			eaPlayer.aiUniqueTargeted = {}	--some AI values here so we don't have to nil check
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
		elseif MapModData.playerType[iPlayer] == "Fay" then
			eaPlayer.blockedBuildingsByID = {}
			eaPlayer.religionID = GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
			eaPlayer.race = GameInfoTypes.EARACE_FAY
			eaPlayer.eaCivNameID = -1		--any value here allows appearance in diplo list
			eaPlayer.leaderEaPersonIndex = GameInfoTypes.EAPERSON_FAND		-- Queen of the Fay
			eaPlayer.culturalLevel = 20		--used in Diplo relations
			eaPlayer.revealedNWs = {}
		elseif MapModData.playerType[iPlayer] == "CityState" then
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
		elseif MapModData.playerType[iPlayer] == "God" then
			eaPlayer.blockedBuildingsByID = {}
			eaPlayer.religionID = GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
		elseif MapModData.playerType[iPlayer] == "Animals" then
			eaPlayer.sustainedPromotions = {}
		elseif MapModData.playerType[iPlayer] == "Barbs" then
			eaPlayer.sustainedPromotions = {}
		end
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

	--init Lua files
	TestResyncGPIndexes()
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
	EaMagicInit(bNewGame)
	AIMercInit(bNewGame)
	EaWondersInit(bNewGame)
	EaActionsInit(bNewGame)

	gg_init.bModInited = true
end

local function OnEnterGame()   --Runs when Begin or Countinue Your Journey pressed
	print("Player entering game ...")

	--trim dead players (after file inits in case someone is resurected)
	for iPlayer in pairs(MapModData.realCivs) do
		if not Players[iPlayer]:IsAlive() then
			DeadPlayer(iPlayer)
		end
	end

	gg_init.bEnteredGame = true
	print("Debug - end of OnEnterGame")
end
Events.LoadScreenClose.Add(OnEnterGame)
