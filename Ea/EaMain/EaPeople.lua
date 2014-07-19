-- EaPeople
-- Author: Pazyryk
-- DateCreated: 2/11/2012 4:10:14 PM
--------------------------------------------------------------

print("Loading EaPeople.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- Local Defines
--------------------------------------------------------------
local FIRST_SPELL_ID =					FIRST_SPELL_ID
local HIGHEST_PROMOTION_ID =			HIGHEST_PROMOTION_ID
local MOD_MEMORY_HALFLIFE =				MOD_MEMORY_HALFLIFE

local EACIV_LJOSALFAR =					GameInfoTypes.EACIV_LJOSALFAR
local EAMOD_DEVOTION =					GameInfoTypes.EAMOD_DEVOTION

local EA_EPIC_GRIMNISMAL =				GameInfoTypes.EA_EPIC_GRIMNISMAL
local EA_WONDER_ARCANE_TOWER =			GameInfoTypes.EA_WONDER_ARCANE_TOWER

local INVISIBLE_SUBMARINE =				GameInfoTypes.INVISIBLE_SUBMARINE

local PROMOTION_SORCERER =				GameInfoTypes.PROMOTION_SORCERER
local PROMOTION_PROPHET =				GameInfoTypes.PROMOTION_PROPHET
local EA_ACTION_GO_TO_PLOT =			GameInfoTypes.EA_ACTION_GO_TO_PLOT

local UNIT_LICH =						GameInfoTypes.UNIT_LICH

local YIELD_PRODUCTION = 				GameInfoTypes.YIELD_PRODUCTION
local YIELD_GOLD = 						GameInfoTypes.YIELD_GOLD
local YIELD_SCIENCE =					GameInfoTypes.YIELD_SCIENCE
local YIELD_CULTURE = 					GameInfoTypes.YIELD_CULTURE
local YIELD_FAITH = 					GameInfoTypes.YIELD_FAITH

local fullCivs =						MapModData.fullCivs

local gPlayers =			gPlayers
local gPeople =				gPeople

local floor =				math.floor
local Rand =				Map.Rand
local GetPlotFromXY =		Map.GetPlot
local PlotDistance =		Map.PlotDistance
local GetPlotByIndex =		Map.GetPlotByIndex
local HandleError21 =		HandleError21

local tempInteger =		{_ = 0}		--holder used and recycled without nilling; _ is position
local int1 =			{}
local int2 =			{}

local g_iActivePlayer = Game.GetActivePlayer()
local g_bReservedGPs = not gWorld.bAllCivsHaveNames

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------
local modTypes = {}
local modTexts = {}
local modsPromotionTable = {}
--local modsMultiplier = {}
local modsProphetBonus = {}
local modsClassTable = {}
local modsSubclassTable = {}
local modsSubclassExcludeTable = {}
for modInfo in GameInfo.EaModifiers() do		--cache table values for speed
	local modType = modInfo.Type
	local id = modInfo.ID
	modTypes[id] = modType
	modTexts[id] = modInfo.Description
	modsPromotionTable[modType] = modInfo.PromotionPrefix	--nil for leadership
	modsProphetBonus[modType] = modInfo.ProphetBonus
	modsClassTable[modType] = modInfo.Class
	modsSubclassTable[modType] = modInfo.Subclass
	modsSubclassExcludeTable[modType] = modInfo.ExcludeSubclass
end
local maxModID = #modTypes

--modsForUI has fixed structure (and text, modType, modType2) for the game but values change
MapModData.modsForUI = MapModData.modsForUI or {}
local modsForUI = MapModData.modsForUI
for i = 0, maxModID do
	modsForUI[i] = {text = modTexts[i], value = 0}
end
modsForUI.firstMagicMod = maxModID - 7
modsForUI[maxModID + 1] = {text = "All Magic Schools", value = 0}
modsForUI[maxModID + 2] = {text = "Other Magic Schools", value = 0}

local reservedGPs = {}		--nil all entries after all civs gain names
for eaCivInfo in GameInfo.EaCivs() do
	if eaCivInfo.FoundingGPType then
		reservedGPs[GameInfoTypes[eaCivInfo.FoundingGPType] ] = true
	end
end

local nonTransferableGPPromos = {}
local numNonTransferableGPPromos = 0
for promoInfo in GameInfo.UnitPromotions() do
	if promoInfo.EaGPNonTransferable then
		numNonTransferableGPPromos = numNonTransferableGPPromos + 1
		nonTransferableGPPromos[numNonTransferableGPPromos] = promoInfo.ID
	end
end
--------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------
local function TestGPModValid(modType, class1, class2, subclass)
	local modClass = modsClassTable[modType]
	if modClass then
		if modClass == "Spellcaster" then
			return class1 == "Thaumaturge" or class2 == "Thaumaturge" or class1 == "Devout" or class2 == "Devout" 
		end
		if modClass == "Any" or modClass == class1 or modClass == class2 then
			if modsSubclassTable[modType] then
				return modsSubclassTable[modType] == subclass
			elseif modsSubclassExcludeTable[modType] then
				return modsSubclassExcludeTable[modType] ~= subclass
			end
			return true
		end
	end
	return false
end

--------------------------------------------------------------
-- UI Interface
--------------------------------------------------------------
local function SetGPModsTable(iPerson)	--used by EaImagePopup for showing GP mods
	Dprint("SetGPModsTable ", iPerson)
	local GetGPMod = GetGPMod
	local TestGPModValid = TestGPModValid
	local eaPerson = gPeople[iPerson]
	local class1 = eaPerson.class1
	local class2 = eaPerson.class2
	local subclass = eaPerson.subclass

	local bApplyMagicMods = false
	local bApplyDevotionMod = false
	local tower = gWonders[EA_WONDER_ARCANE_TOWER][iPerson]
	local temple
	if tower then
		local player = Players[eaPerson.iPlayer]
		local unit = player:GetUnitByID(eaPerson.iUnit)
		if unit:GetPlot():GetPlotIndex() == tower.iPlot then
			bApplyMagicMods = true
		end
	else
		temple = eaPerson.templeID and gWonders[eaPerson.templeID]
		if temple then
			local player = Players[eaPerson.iPlayer]
			local unit = player:GetUnitByID(eaPerson.iUnit)
			if unit:GetPlot():GetPlotIndex() == temple.iPlot then
				if 0 < temple[EAMOD_DEVOTION] then
					bApplyDevotionMod = true
				else
					tower = temple
					bApplyMagicMods = true
				end
			end
		end
	end
	modsForUI.bApplyMagicMods = bApplyMagicMods
	modsForUI.bApplyDevotionMod = bApplyDevotionMod

	local highestMagicSchool, lowestMagicSchool = 0, 99999
	for i = 0, maxModID do
		local modType = modTypes[i]
		local value = TestGPModValid(modType, class1, class2, subclass) and GetGPMod(iPerson, modType, nil) or 0
		if value > 0 then
			if i > maxModID - 8 then		--last 8 are always magic schools (and value always > 0 for all spellcasters)
				if bApplyMagicMods then
					value = value + tower[i]		--tower could really be temple from above
				end
				if highestMagicSchool < value then
					highestMagicSchool = value
				end
				if lowestMagicSchool > value then
					lowestMagicSchool = value
				end
			elseif bApplyDevotionMod and i == maxModID - 8  then	--Devotion
				value = value + temple[i]
			end
		end
		modsForUI[i].value = value
	end
	--Note: this is so we don't have to display all 8 spell modifiers, since 6 or 7 of them are likley to be the same for most casters
	if highestMagicSchool == 0 then
		modsForUI[maxModID + 1].value = 0	--"All Magic Schools"	(value = 0 means that this item won't display)
		modsForUI[maxModID + 2].value = 0	--"Other Magic Schools"
	elseif lowestMagicSchool == highestMagicSchool then
		for i = maxModID - 7, maxModID do
			modsForUI[i].value = 0
		end
		modsForUI[maxModID + 1].value = lowestMagicSchool	--"All Magic Schools"
		modsForUI[maxModID + 2].value = 0					--"Other Magic Schools"
	else
		for i = maxModID - 7, maxModID do
			if modsForUI[i].value == lowestMagicSchool then
				modsForUI[i].value = 0
			end
		end
		modsForUI[maxModID + 1].value = 0					--"All Magic Schools"
		modsForUI[maxModID + 2].value = lowestMagicSchool	--"Other Magic Schools"		
	end
end
LuaEvents.EaPeopleSetModsTable.Add(SetGPModsTable)
--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaPeopleInit(bNewGame)
	if bNewGame then
		gPeople[0] = {	iPlayer = FAY_PLAYER_INDEX,				--Queen of the Fay
						iUnit = -1,
						race = GameInfoTypes.EARACE_FAY,
						name = "TXT_KEY_EAPERSON_FAND",
						title = "TXT_KEY_EA_QUEEN",
						portrait = "Fand_SueMarino_0.70_636x944.dds",
						eaActionID = -1,
						gotoEaActionID = -1
						}
	end

	for iPerson, eaPerson in pairs(gPeople) do
		local eaPersonRowID = eaPerson.eaPersonRowID
		if eaPersonRowID then
			gg_peopleEverLivedByRowID[eaPersonRowID] = true
		end
	end
	for _, eaPerson in pairs(gDeadPeople) do
		local eaPersonRowID = eaPerson.eaPersonRowID
		if eaPersonRowID then
			gg_peopleEverLivedByRowID[eaPersonRowID] = true
		end
	end
end

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------


local gpIndexes = {}

function TestResyncGPIndexes()
	print("TestResyncGPIndexes")
	local errorString = ""
	local gpIndexCount = 0
	--Test all units for PersonIndex and update eaPerson.iUnit
	for iPlayer = 0, BARB_PLAYER_INDEX do
		local player = Players[iPlayer]
		if player:IsAlive() then
			for unit in player:Units() do
				local iPerson = unit:GetPersonIndex()
				if iPerson ~= -1 then
					for i = 1, gpIndexCount do
						if iPerson == gpIndexes[i] then
							errorString = errorString .. " extra unit with iPerson = " .. iPerson .. ";"
						end
					end
					gpIndexCount  = gpIndexCount + 1
					gpIndexes[gpIndexCount] = iPerson
					local eaPerson = gPeople[iPerson]
					if not eaPerson then
						if gDeadPeople[iPerson] then
							print("!!!! ERROR: Found unit:GetPersonIndex() matching dead person; killing unit; iPerson, iUnit = ", iPerson, iUnit)
							unit:Kill(false, -1)
						else
							error("unit:GetPersonIndex() did not match any iPerson living or dead: ", iPerson)
						end
					elseif eaPerson.iPlayer ~= iPlayer then
						errorString = errorString .. " eaPerson.iPlayer / unit:Owner() mismatch, = " .. eaPerson.iPlayer .. "/" .. iPlayer .. ";"
					else
						local iUnit = unit:GetID()
						if eaPerson.iUnit ~= iUnit then
							print("!!!! WARNING: eaPerson.iUnit wrong, updating; old/new = ", eaPerson.iUnit, iUnit)
							eaPerson.iUnit = iUnit
						else
							print(" -match iPlayer, iPerson, class1, class2, subclass, iUnit, unitType = ", iPlayer, iPerson, eaPerson.class1, eaPerson.class2, eaPerson.subclass, iUnit, GameInfo.Units[unit:GetUnitType()].Type)
						end
					end
				end
			end
		end
	end
	--Look for orphan GPs
	for iPerson, eaPerson in pairs(gPeople) do
		if iPerson ~= 0 then
			local bFound = false
			for i = 1, gpIndexCount do
				if iPerson == gpIndexes[i] then
					bFound = true
					break
				end
			end
			if not bFound then
				print("!!!! ERROR: found orphan GP not matched to any map unit, killing; iPlayer, iPerson, class1, class2, subclass = ", eaPerson.iPlayer, iPerson, eaPerson.class1, eaPerson.class2, eaPerson.subclass)
				KillPerson(eaPerson.iPlayer, iPerson)
			end
		end
	end
	if errorString ~= "" then
		error("Error(s) in TestResyncGPIndexes:" .. errorString)
	end
end



local g_skipActivePlayerPeople = {}

function PeoplePerCivTurn(iPlayer)
	--DebugFunctionExitTest("PeoplePerCivTurn", true)
	print("PeoplePerCivTurn")
	local eaPlayer = gPlayers[iPlayer]
	local player = Players[iPlayer]
	local bHumanPlayer = player:IsHuman()
	local classPoints = eaPlayer.classPoints
	local gameTurn = Game.GetGameTurn()
	local bLjosalfar = eaPlayer.eaCivNameID == EACIV_LJOSALFAR

	--GP Probability Generation
	local chance = CalculateGPSpawnChance(iPlayer)

	local dice = Rand(1000, "GP spawn")
	print("GP chance, dice, class points:", chance, dice, classPoints[1], classPoints[2], classPoints[3], classPoints[4], classPoints[5], classPoints[6], classPoints[7])

	if dice < chance then
		GenerateGreatPerson(iPlayer)
	end
	
	--Cycle through each GP
	tempInteger._ = 0
	print("begin GP cycle")

	for iPerson, eaPerson in pairs(gPeople) do
		if eaPerson.iPlayer == iPlayer then
			
			local age = gameTurn - eaPerson.birthYear

			if bHumanPlayer and not eaPerson.name then		--could be true after autoplay
				UngenericizePerson(iPlayer, iPerson, nil)
			end

			print("Cycle GP", iPerson, eaPerson.iUnit, eaPerson.name, (eaPerson.subclass or eaPerson.class1), eaPerson.eaActionID ~= -1 and GameInfo.EaActions[eaPerson.eaActionID].Type or -1)

			local unit = player:GetUnitByID(eaPerson.iUnit)

			local bKill = false

			if not unit then
				print("!!!! ERROR: No unit for GP; killing person")
				bKill = true
				--error("No unit for GP")
			end

			--Death by old age
			local bDieOfOldAge = false
			if eaPerson.predestinedAgeOfDeath and eaPerson.predestinedAgeOfDeath <= age then	--predestined thwarts game reload
				if eaPerson.eaActionID == -1 or eaPerson.eaActionID == 0 then
					bDieOfOldAge = true
				elseif not eaPerson.deathStayAction then
					local eaActionInfo = GameInfo.EaActions[eaPerson.eaActionID]
					local bDeathStay = eaActionInfo.TurnsToComplete ~= 1000		--sustained action
					if bDeathStay then
						eaPerson.deathStayAction = eaPerson.eaActionID
					else
						bDieOfOldAge = true
					end
				elseif eaPerson.deathStayAction ~= eaPerson.eaActionID then	--swapped to different action
					bDieOfOldAge = true
				end
				--lives as long as eaPerson.deathStayAction == eaPerson.eaActionID
			end

			if bDieOfOldAge then
				KillPerson(iPlayer, iPerson, unit, nil, "OldAge")
			elseif bKill then
				KillPerson(iPlayer, iPerson, nil, nil, nil)
			else

				--Do passive xp (Ljosalfar only)
				if bLjosalfar then
					if Rand(5, "hello") == 0 then		-- 1 in 5
						local xp = (iPerson == eaPlayer.leaderEaPersonIndex) and 10 or 5
						unit:ChangeExperience(xp)
					end
				end

				if not bHumanPlayer and unit:IsPromotionReady() then
					AIPickGPPromotion(iPlayer, iPerson, unit)
					unit:SetLevel(unit:GetLevel() + 1)
				end
				UpdateGreatPersonStatsFromUnit(unit, eaPerson)
	
				--Do or test action
				if eaPerson.eaActionID ~= -1 then
					if bHumanPlayer then	
						local eaActionID = eaPerson.eaActionID
						print("About to TestEaAction for human", eaActionID, iPlayer, unit, iPerson)
						if eaActionID == 0 then
							g_skipActivePlayerPeople[iPerson] = true
						elseif eaActionID < FIRST_SPELL_ID then
							if TestEaAction(eaActionID, iPlayer, unit, iPerson) then
								g_skipActivePlayerPeople[iPerson] = true
							else
								print("Human GP failed TestEaAction at start of turn")
								InterruptEaAction(iPlayer, iPerson)
							end
						else
							if TestEaSpell(eaActionID, iPlayer, unit, iPerson) then
								g_skipActivePlayerPeople[iPerson] = true
							else
								print("Human GP failed TestEaSpell at start of turn")
								InterruptEaSpell(iPlayer, iPerson)
							end
						end
					elseif not AIGPTestCombatInterrupt(iPlayer, iPerson, unit) then
						print("No combat interrupt for AI; about to do action ", eaPerson.eaActionID, iPlayer, unit, iPerson)
						print("eaPerson.gotoPlotIndex, .gotoEaActionID = ", eaPerson.gotoPlotIndex, eaPerson.gotoEaActionID)
						if eaPerson.eaActionID < FIRST_SPELL_ID then
							DoEaAction(eaPerson.eaActionID, iPlayer, unit, iPerson) 	--AI keeps doing action until done or fails
						else
							DoEaSpell(eaPerson.eaActionID, iPlayer, unit, iPerson)
						end
						print("eaPerson.gotoPlotIndex, .gotoEaActionID = ", eaPerson.gotoPlotIndex, eaPerson.gotoEaActionID)
					end
				end

				--Make AI do something if unit on map with movement
				if eaPerson.iUnit ~= -1 and not bHumanPlayer then
					unit = player:GetUnitByID(eaPerson.iUnit)
					local debugLoopCount = 0
					while unit and unit:GetMoves() > 0 and not unit:IsDead() and not unit:IsDelayedDeath() do					--repeat call since not all actions use movement or all movement

						unit = AIGPDoSomething(iPlayer, iPerson, unit)		--this function returns unit (if still on map) or nil
						print("after AIGPDoSomething from EaPeople", unit, unit and unit:GetMoves())

						--!!!! POSSIBLE INFINITE LOOP !!!!
						--If it happens, then it most likely due to a particular EaAction that is repeatable and does not reduce movement (which must be fixed)
						if debugLoopCount < 20 then
							debugLoopCount = debugLoopCount + 1
						else
							error("Possible infinite loop in AIGPDoSomething call")
						end
					end
				end
			end
		end
	end
	UpdateLeaderEffects(iPlayer)
end


local function SkipActivePlayerPeople()
	local player = Players[g_iActivePlayer]	
	if not player:IsHuman() then return end	--autoplay
	if MapModData.bAutoplay then
		error("Fix this!")
	end

    print("SkipActivePlayerPeople")

	for iPerson, bSkip in pairs(g_skipActivePlayerPeople) do
		if bSkip then
			local iUnit = gPeople[iPerson].iUnit
			local unit = player:GetUnitByID(iUnit)
			if unit then
				print("GP Moves before = ", unit:GetMoves())
				g_skipActivePlayerPeople[iPerson] = false
				unit:PopMission()
				unit:PushMission(MissionTypes.MISSION_SKIP, unit:GetX(), unit:GetY(), 0, 0, 1) --, MissionTypes.MISSION_SKIP, unit:GetPlot(), unit)
				print("GP Moves after skip = ", unit:GetMoves())
			end
		end
	end
end
Events.ActivePlayerTurnStart.Add(SkipActivePlayerPeople)


--TO DO: This could be done much better with new turn blocking types in dll


local g_iLastPlayerPeopleAfterTurn = -1

function PeopleAfterTurn(iPlayer, bActionInfoPanelCall)
	--Runs from ActionInfoPanel for human, and after turn for AI and human
	print("Running PeopleAfterTurn ", iPlayer, bActionInfoPanelCall, g_iLastPlayerPeopleAfterTurn)
	local player = Players[iPlayer]
	local bHumanPlayer = player:IsHuman()
	local bAllowHumanPlayerEndTurn = true	
	local gameTurn = Game.GetGameTurn()

	local eaPlayer = gPlayers[iPlayer]				

	for iPerson, eaPerson in pairs(gPeople) do
		if eaPerson.iPlayer == iPlayer then

			local unit = eaPerson.iUnit ~= -1 and player:GetUnitByID(eaPerson.iUnit)
			if not unit then
				print("!!!! ERROR: No unit for GP; killing person")
				KillPerson(iPlayer, iPerson, nil, nil, nil)
			else
				if bHumanPlayer and iPlayer ~= g_iLastPlayerPeopleAfterTurn then	--Human actions run automatically at turn end so that player can interupt
					if unit:GetMoves() > 0 then
						local eaActionID = eaPerson.eaActionID
						if eaActionID ~= -1 then
							local bActionSuccess
							if eaActionID < FIRST_SPELL_ID then
								bActionSuccess = DoEaAction(eaActionID, iPlayer, unit, iPerson)
							else
								bActionSuccess = DoEaSpell(eaActionID, iPlayer, unit, iPerson)
							end
							if bActionSuccess and eaPerson.activePlayerEndTurnXP and unit then
								unit:ChangeExperience(eaPerson.activePlayerEndTurnXP)
								eaPerson.activePlayerEndTurnXP = nil
							end

							if not bActionSuccess and unit and unit:GetMoves() > 0 and not unit:IsDelayedDeath() and not unit:IsDead() then
								print("PeopleAfterTurn blocking human end turn (if it's not too late) for GP with movement", eaActionID, iPlayer, iPerson)
								bAllowHumanPlayerEndTurn = false
							end
						end
					end
				end
			end
		end
	end

	g_iLastPlayerPeopleAfterTurn = iPlayer

	if bActionInfoPanelCall and bAllowHumanPlayerEndTurn then
		print("PeopleAfterTurn issuing Game.DoControl(GameInfoTypes.CONTROL_ENDTURN)")
		Game.DoControl(GameInfoTypes.CONTROL_ENDTURN)
	end
	print("End of PeopleAfterTurn")
end
--LuaEvents.EaPeoplePeopleAfterTurn.Add(PeopleAfterTurn)
LuaEvents.EaPeoplePeopleAfterTurn.Add(function(iPlayer, bActionInfoPanelCall) return HandleError21(PeopleAfterTurn, iPlayer, bActionInfoPanelCall) end)


--------------------------------------------------------------
-- GP Generation
--------------------------------------------------------------

local gpClassTable = {"Engineer", "Merchant", "Sage", "Artist", "Warrior", "Devout", "Thaumaturge"}

function GenerateGreatPerson(iPlayer, class, subclass, eaPersonRowID, bAsLeader, dualClass)	--returns iUnit for GP if successful (generates generic GP, then ungenericizes if human player)
	--for random generator call, use (iPlayer, nil, nil, nil)
	--for a specific class, use (iPlayer, class, nil, nil)
	--for a specific subclass, use (iPlayer, nil, subclass, nil)
	--for a specific person, use (iPlayer, nil, subclass, eaPersonRowID)	--must specify class/subclass/dualClass info!
	print("GenerateGreatPerson",iPlayer, class, subclass, eaPersonRowID)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	if not class and not subclass then	--use random generation
		local totalPoints = 0
		for i = 1, #gpClassTable do
			totalPoints = totalPoints + eaPlayer.classPoints[i]
		end
		local dice = Rand(totalPoints, "GP random class")		
		for i = 1, #gpClassTable do
			if dice < eaPlayer.classPoints[i] then
				class = gpClassTable[i]
				--reduce GP points for class
				local currentPts = eaPlayer.classPoints[i]
				local ptsReduction = floor(currentPts / 2) + 50
				ptsReduction = currentPts < ptsReduction and currentPts or ptsReduction
				eaPlayer.classPoints[i] = currentPts - ptsReduction
				if i == 5 then	--Warrior
					gg_combatPointDiff[iPlayer] = gg_combatPointDiff[iPlayer] + ptsReduction
				end
				break
			end
			dice = dice - eaPlayer.classPoints[i]
		end
	end

	subclass = subclass or PickSubclassForSpawnedClass(iPlayer, class)
	local unitTypeID, class1, class2 = GetInfoFromSubclassClass(subclass, class)
	class2 = class2 or dualClass
	--note: class1 always has value; class2 and subclass may be nil

	local capital = player:GetCapitalCity()
	if not capital then return end

	-- !!!!!!!!!!!!!!!!  INIT NEW EaPerson HERE !!!!!!!!!!!!!!!!

	--do eaPerson stuff first
	local iPerson = #gPeople + 1
	local eaPerson = {	iPlayer = iPlayer,			
						iUnit = -1,							-- need this!
						iUnitJoined = -1,
						unitTypeID = unitTypeID,
						subclass = subclass,
						class1 = class1,
						class2 = class2,
						level = 1,
						race = eaPlayer.race,		--takes civ race here; may change when ungenerisized (e.g., Heldeofol takes a subrace)
						birthYear = Game.GetGameTurn() - 20,
						disappearTurn = -1,	
						eaActionID = -1,
						eaActionData = -1,
						gotoPlotIndex = -1,
						gotoEaActionID = -1,
						moves = 0,	
						promotions = {},
						progress = {},
						modMemory = {}	}		
		
	gPeople[iPerson] = eaPerson
	RegisterGPActions(iPerson)		--only needs class1, class2 and subclass to work

	--init unit
	local unit = InitGPUnit(iPlayer, iPerson, capital:GetX(), capital:GetY(), nil, unitTypeID)
	local iUnit = unit:GetID()
	eaPerson.iUnit = iUnit

	UpdateGreatPersonStatsFromUnit(unit, eaPerson)		--x, y, moves, level, xp; fills promotions table
	if class1 == "Warrior" or class2 == "Warrior" then
		eaPerson.aiHasCombatRole = true
	end		
	if class1 == "Devout" or class2 == "Devout" or class1 == "Thaumaturge" or class2 == "Thaumaturge" then
		eaPerson.spells = {}		--presence of this table is cue that this is a spellcaster (used by AI and in level gains)
		eaPerson.learningSpellID = -1
		local spellID = FIRST_SPELL_ID
		local spellInfo = GameInfo.EaActions[spellID]
		while spellInfo do
			if spellInfo.FreeSpellSubclass == subclass then
				--eaPerson.spells[spellID] = true
				eaPerson.spells[#eaPerson.spells + 1] = spellID
				if spellInfo.AICombatRole then
					eaPerson.aiHasCombatRole = true
				end
			end
			spellID = spellID + 1
			spellInfo = GameInfo.EaActions[spellID]
		end
	end
		
	if eaPersonRowID or player:IsHuman() then
		UngenericizePerson(iPlayer, iPerson, eaPersonRowID)
	else
		ResetAgeOfDeath(iPerson)
	end

	unit:ChangeExperience(15 + Rand(10, "hello"))	

	if bAsLeader then
		MakeLeader(iPlayer, iPerson)
	end

	if iPlayer == g_iActivePlayer then
		local personType = bAsLeader and "NewPersonLeader" or "NewPerson"
		LuaEvents.EaImagePopup({type = personType, id = iPerson, sound = "AS2D_EVENT_NOTIFICATION_GOOD"})
	end

	unit:TestPromotionReady()

	return iPerson
end
--LuaEvents.EaPeopleGenerateGreatPerson.Add(GenerateGreatPerson)

function InitGPUnit(iPlayer, iPerson, x, y, convertUnit, unitTypeID, invisibilityID, morale)	--only first 4 args required
	local player = Players[iPlayer]
	local eaPerson = gPeople[iPerson]
	unitTypeID = unitTypeID or eaPerson.unitTypeID		--default if nil
	local facingDirection = convertUnit and convertUnit:GetFacingDirection() or nil

	local unit = player:InitUnit(unitTypeID, x, y, nil, facingDirection)
	eaPerson.iUnit = unit:GetID()
	unit:SetPersonIndex(iPerson)
	unit:SetBaseCombatStrength(GetGPMod(iPerson, "EAMOD_COMBAT"))
	unit:SetInvisibleType(INVISIBLE_SUBMARINE)
	unit:SetSeeInvisibleType(INVISIBLE_SUBMARINE)
	unit:SetMorale(morale or 0)
	if eaPerson.class1 == "Warrior" or eaPerson.class2 == "Warrior" then
		unit:SetGPAttackState(0)
	end
	if convertUnit then
		for i = 1, numNonTransferableGPPromos do
			convertUnit:SetHasPromotion(nonTransferablePromos[i] , false)
		end
		MapModData.bBypassOnCanSaveUnit = true
		unit:Convert(convertUnit, false)
	end
	return unit
end

function UpdateGreatPersonStatsFromUnit(unit, eaPerson)		--info we may need if unit dies (or for quick access without dll test)
	eaPerson.x = unit:GetX()
	eaPerson.y = unit:GetY()
	eaPerson.level = unit:GetLevel()
	eaPerson.xp = unit:GetExperience()

	--v4 hotfix c patch for save compatibility; TO DO: Remove
	eaPerson.promotions = eaPerson.promotions or {}

	local promotions = eaPerson.promotions
	for promotionID = 0, HIGHEST_PROMOTION_ID do
		if unit:IsHasPromotion(promotionID) then
			promotions[promotionID] = true
		else
			promotions[promotionID] = nil
		end
	end 
end


function ResetAgeOfDeath(iPerson)
	print("ResetAgeOfDeath", iPerson)
	--Set predestinedAgeOfDeath here to thwart avoidance by game reloading
	local eaPerson = gPeople[iPerson]
	local race = eaPerson.race
	local raceInfo = GameInfo.EaRaces[race]
	if raceInfo.NominalLifeSpan == -1 then return end	--Sidhe
	if eaPerson.unitTypeID == UNIT_LICH then return end

	local ageDeathReduction = 0
	local eaPersonRowID = eaPerson.eaPersonRowID	--nil if generic
	if eaPersonRowID then
		local personInfo = GameInfo.EaPeople[eaPersonRowID]
		ageDeathReduction = personInfo.AgeDeathReduction
		--could be increased further (e.g., to 100 for a new lich)
	end

	local nominalLifeSpan = raceInfo.NominalLifeSpan
	local veryOldChance = raceInfo.VeryOldDeathChance
	local ancientChance = raceInfo.AncientDeathChance
	
	if ageDeathReduction ~= 0 then
		veryOldChance = floor(veryOldChance * (100 - ageDeathReduction) / 100 + 0.5)
		ancientChance = floor(ancientChance * (100 - ageDeathReduction) / 100 + 0.5)
	end

	local age = floor(0.85 * nominalLifeSpan + 0.5)	--starts at "Very Old" (85% of nominal life span)

	if 0 < veryOldChance then
		while age < nominalLifeSpan do
			if Rand(1000, "death for very old") < veryOldChance then
				eaPerson.predestinedAgeOfDeath = age
				return
			end
			age = age + 1
		end
	end

	if 0 < ancientChance then
		while true do
			if Rand(1000, "death for ancient") < ancientChance then
				eaPerson.predestinedAgeOfDeath = age
				return
			end
			age = age + 1
		end
	end
	eaPerson.predestinedAgeOfDeath = nil	--if we are here then this person doesn't die from age for some reason (e.g., a lich)
	return
end

function GetInfoFromSubclassClass(subclass, class)	--class is ignored if subclass has a valid value
	--return unitTypeID, class1, class2
	if subclass == "Alchemist" then
		return GameInfoTypes.UNIT_ALCHEMIST, "Sage", nil
	elseif subclass == "Paladin" then
		return GameInfoTypes.UNIT_PALADIN, "Warrior", "Devout"
	elseif subclass == "Eidolon" then
		return GameInfoTypes.UNIT_EIDOLON, "Warrior", "Devout"
	elseif subclass == "Berserker" then
		return GameInfoTypes.UNIT_BERSERKER, "Warrior", nil
	elseif subclass == "Druid" then
		return GameInfoTypes.UNIT_DRUID, "Devout", "Thaumaturge"
	elseif subclass == "Priest" then
		return GameInfoTypes.UNIT_PRIEST, "Devout", nil
	elseif subclass == "FallenPriest" then
		return GameInfoTypes.UNIT_FALLENPRIEST, "Devout", "Thaumaturge"
	elseif subclass == "Witch" then
		return GameInfoTypes.UNIT_WITCH, "Thaumaturge", nil
	elseif subclass == "Sorcerer" then
		return GameInfoTypes.UNIT_SORCERER, "Thaumaturge", nil
	elseif subclass == "Necromancer" then
		return GameInfoTypes.UNIT_NECROMANCER, "Thaumaturge", nil
	elseif subclass == "Wizard" then
		return GameInfoTypes.UNIT_WIZARD, "Thaumaturge", nil
	elseif subclass == "Lich" then
		return GameInfoTypes.UNIT_LICH, "Thaumaturge", nil
	--"pure" classes
	elseif class == "Engineer" then
		return GameInfoTypes.UNIT_ENGINEER, "Engineer", nil
	elseif class == "Merchant" then
		return GameInfoTypes.UNIT_MERCHANT, "Merchant", nil
	elseif class == "Sage" then
		return GameInfoTypes.UNIT_SAGE, "Sage", nil
	elseif class == "Artist" then
		return GameInfoTypes.UNIT_ARTIST, "Artist", nil
	elseif class == "Warrior" then
		return GameInfoTypes.UNIT_WARRIOR, "Warrior", nil
	end
end

function UngenericizePerson(iPlayer, iPerson, eaPersonRowID)
	print("UngenericizePerson ", iPlayer, iPerson, eaPersonRowID)
	--always done for human player; done for AI under certain circumstances (e.g., person takes leadership)
	--3rd arg is optional (picked if nil)
	local eaPerson = gPeople[iPerson]
	if eaPerson.name then return end	--already ungenericized

	eaPersonRowID = eaPersonRowID or PickPersonRowByClassOrSubclass(iPlayer, eaPerson.subclass or eaPerson.class1)

	if eaPersonRowID then
		gg_peopleEverLivedByRowID[eaPersonRowID] = true
		local eaPersonRow = GameInfo.EaPeople[eaPersonRowID]
		eaPerson.race = GameInfoTypes[eaPersonRow.Race]
		local name = eaPersonRow.Description
		eaPerson.name = name
		eaPerson.eaPersonRowID = eaPersonRowID	--need this for portrait and AI personality (if becomes leader)
		local iUnit = eaPerson.iUnit
		if iUnit ~= -1 then	--name unit if on map
			local player = Players[iPlayer]
			local unit = player:GetUnitByID(iUnit)
			if unit then
				unit:SetName(Locale.ConvertTextKey(name))
			end
		end
		ResetAgeOfDeath(iPerson)
	else
		print("!!!! Error: could not ungenericize person ", iPlayer, iPerson)
	end
	--return eaPersonRowID
end

function PickPersonRowByClassOrSubclass(iPlayer, classOrSubclass, bAllowRedundant)	--returns EaPerson ID
	--3rd arg is only set if function calls itself (last ditch effort if no non-redundant can be found)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local race = eaPlayer.race
	local raceType = GameInfo.EaRaces[race].Type
	local bAllCivsHaveNames = gWorld.bAllCivsHaveNames
	
	--total points for classOrSubclass
	local totalPointsForSubclass = 0
	local firstRow = GameInfoTypes.EAPERSON_FAND + 1
	local rowID = firstRow
	local eaPersonRow = GameInfo.EaPeople[rowID]
	while eaPersonRow do
		if eaPersonRow[classOrSubclass] ~= -1 and not (g_bReservedGPs and reservedGPs[rowID]) and (not gg_peopleEverLivedByRowID[eaPersonRow.ID] or bAllowRedundant) and eaPersonRow.Race == raceType then
			int1[rowID] = eaPersonRow[classOrSubclass]
			totalPointsForSubclass = totalPointsForSubclass + eaPersonRow[classOrSubclass]
		else
			int1[rowID] = 0
		end		
		
		rowID = rowID + 1
		eaPersonRow = GameInfo.EaPeople[rowID]
	end

	if totalPointsForSubclass > 0 then
		local dice = Rand(totalPointsForSubclass, "hello") + 1
		for i = firstRow, rowID - 1 do
			if dice < int1[i] then
				return i
			else
				dice = dice - int1[i]
			end
		end
	else
		print("No more EaPeople with >0 points for this classOrSubclass, picking random valid")
		local validPeople = 0
		rowID = firstRow
		eaPersonRow = GameInfo.EaPeople[1]
		while eaPersonRow do
			if eaPersonRow[classOrSubclass] ~= -1 and not (g_bReservedGPs and reservedGPs[rowID]) and (not gg_peopleEverLivedByRowID[eaPersonRow.ID] or bAllowRedundant) and eaPersonRow.Race == raceType then
				validPeople = validPeople + 1
				int1[validPeople] = rowID
			end		
			rowID = rowID + 1
			eaPersonRow = GameInfo.EaPeople[rowID]
		end
		if validPeople > 0 then
			local dice = Rand(validPeople, "hello") + 1
			return int1[dice]
		end
	end

	if not bAllowRedundant then
		print("!!!! WARNING: Could not find any valid EaPeople; retrying allowing redundant persons")
		return PickPersonRowByClassOrSubclass(iPlayer, classOrSubclass, true)
	end

	print("!!!! ERROR: Could not find any valid EaPeople")

end

function UnlockReservedGPs()
	g_bReservedGPs = false
	reservedGPs = nil		--garbage collect cached table
end

--------------------------------------------------------------
-- Leader Functions
--------------------------------------------------------------

function MakeLeader(iPlayer, iPerson)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local eaPerson = gPeople[iPerson]
	if not eaPerson.name then					--AI GPs are generic unless they take leadership
		UngenericizePerson(iPlayer, iPerson)
	end
	eaPlayer.leaderEaPersonIndex = iPerson
	eaPerson.assumedLeadershipTurn = Game.GetGameTurn()

	local eaPersonInfo = GameInfo.EaPeople[eaPerson.eaPersonRowID]
	if eaPersonInfo.LeaderTitleOverride then
		eaPerson.title = eaPersonInfo.LeaderTitleOverride
	elseif eaPerson.subclass == "Priest" then
		if eaPersonInfo.Gender == "F" then
			eaPerson.title = "TXT_KEY_EA_MATRIARCH"
		else
			eaPerson.title = "TXT_KEY_EA_PATRIARCH"
		end
	else
		if eaPersonInfo.Gender == "F" then
			eaPerson.title = "TXT_KEY_EA_QUEEN"
		else
			eaPerson.title = "TXT_KEY_EA_KING"
		end
	end
	local newName = GetEaPersonFullTitle(eaPerson)

	local leaderType = eaPersonInfo.LeaderType
	local leaderID
	for leaderInfo in GameInfo.Leaders("Type='" .. leaderType .. "'") do
		leaderID = leaderInfo.ID
	end
	if not leaderID then
		error("Could not find LeaderID for eaPersonInfo")
	end

	player:ChangeLeaderType(leaderID)
	PreGame.SetLeaderName(iPlayer, newName)

	local iUnit = eaPerson.iUnit
	local unit = player:GetUnitByID(iUnit)
	unit:SetName(newName)
	unit:ChangeExperience(20)	--leader bonus
	--apply "leader promotion"?

	UpdateLeaderEffects(iPlayer)

	if iPlayer == g_iActivePlayer then
		if eaPerson.class1 ~= "Warrior" and eaPerson.class2 ~= "Warrior" then
			UpdateGlobalYields(iPlayer)
		end
		if eaPerson.class1 == "Warrior" or eaPerson.class2 == "Warrior" then
			UpdateCityYields(iPlayer)
		end
	end

end

function UpdateLeaderEffects(iPlayer)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]

	local class1
	local class2
	local subclass
	local mod
	local leaderProduction = 0
	local leaderGold = 0
	local leaderScience = 0
	local leaderCulture = 0
	local leaderManaOrFavor = 0
	local leaderLandXP
	local leaderSeaXP


	local iLeader = eaPlayer.leaderEaPersonIndex
	if iLeader ~= -1 then
		local eaPerson = gPeople[iLeader]
		mod = GetGPMod(iLeader, "EAMOD_LEADERSHIP", nil)
		--mod = eaPerson.modLeadership
		class1 = eaPerson.class1
		class2 = eaPerson.class2
		subclass = eaPerson.subclass
		
		--Check capital vicinity if not warrior
		--[[ Not sure if we want to do this or not
		if class1 ~= "Warrior" and class2 ~= "Warrior" then	--exceptions to capital vicinity rule
			local player = Players[iPlayer]
			local capital = player:GetCapitalCity()
			local capitalX, capitalY = capital:GetX(), capital:GetY()
			local iUnit = eaPerson.iUnit
			local unit, x, y
			if iUnit ~= -1 then unit = player:GetUnitByID(iUnit) end
			if unit then
				x, y = unit:GetX(), unit:GetY()
			else
				x, y = eaPerson.x, eaPerson.y
			end
			if Map.PlotDistance(x, y, capitalX, capitalY) > 3 then
				class1, class2, subclass = nil, nil, nil		--this will remove effects below
				if iPlayer == g_iActivePlayer then
					player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC,  "Your leader is not in the capital area and is not providing leadership benefits", -1, -1)
				end
			end
		end
		]]
	
	end

	if class2 then 	--nil unless dual-class
		mod = mod / 2
	end

	if class1 == "Engineer" then
		leaderProduction = mod
	elseif class1 == "Merchant" then
		leaderGold = mod
	elseif class1 == "Sage" then
		leaderScience = mod
	elseif class1 == "Artist" then
		leaderCulture = mod
	elseif class1 == "Warrior" then
		if subclass == "SeaWarrior" then
			leaderSeaXP = mod
		else
			leaderLandXP = mod
		end
	elseif class1 == "Devout" or class1 == "Thaumaturge" then
		leaderManaOrFavor = mod
	end

	if class2 then
		if class2 == "Engineer" then
			leaderProduction = leaderProduction + mod
		elseif class2 == "Merchant" then
			leaderGold = leaderGold + mod
		elseif class2 == "Sage" then
			leaderScience = leaderScience + mod
		elseif class2 == "Artist" then
			leaderCulture = leaderCulture + mod
		elseif class2 == "Warrior" then
			leaderLandXP = leaderLandXP + mod
		elseif class2 == "Devout" or class2 == "Thaumaturge" then
			leaderManaOrFavor = leaderManaOrFavor + mod
		end
	end

	if player:GetLeaderYieldBoost(YIELD_PRODUCTION) ~= leaderProduction then
		player:SetLeaderYieldBoost(YIELD_PRODUCTION, leaderProduction)
	end
	if player:GetLeaderYieldBoost(YIELD_GOLD) ~= leaderGold then
		player:SetLeaderYieldBoost(YIELD_GOLD, leaderGold)
	end
	if player:GetLeaderYieldBoost(YIELD_SCIENCE) ~= leaderScience then
		player:SetLeaderYieldBoost(YIELD_SCIENCE, leaderScience)
	end
	if player:GetLeaderYieldBoost(YIELD_CULTURE) ~= leaderCulture then
		player:SetLeaderYieldBoost(YIELD_CULTURE, leaderCulture)
	end
	if player:GetLeaderYieldBoost(YIELD_FAITH) ~= leaderManaOrFavor then
		player:SetLeaderYieldBoost(YIELD_FAITH, leaderManaOrFavor)
	end


	--eaPlayer.leaderProduction = leaderProduction	--these are nil when not needed
	--eaPlayer.leaderGold = leaderGold
	--eaPlayer.leaderScience = leaderScience
	--eaPlayer.leaderCulture = leaderCulture
	--eaPlayer.leaderManaOrFavor = leaderManaOrFavor
	eaPlayer.leaderLandXP = leaderLandXP
	eaPlayer.leaderSeaXP = leaderSeaXP

end

function SpawnNamesakeWarriorLeader(iPlayer)
	local eaPlayer = gPlayers[iPlayer]
	local iPerson = GenerateGreatPerson(iPlayer, "Warrior")
	UngenericizePerson(iPlayer, iPerson)
	eaPlayer.leaderEaPersonIndex = iPerson
	SetNewCivName(iPlayer, 0)	--this names the civ after its current leader
end


function RemoveLeaderEffects(iPlayer)
	local player = Players[iPlayer]
	player:SetLeaderYieldBoost(YIELD_PRODUCTION, 0)	--all but food
	player:SetLeaderYieldBoost(YIELD_GOLD, 0)
	player:SetLeaderYieldBoost(YIELD_SCIENCE, 0)
	player:SetLeaderYieldBoost(YIELD_CULTURE, 0)
	player:SetLeaderYieldBoost(YIELD_FAITH, 0)

	local eaPlayer = gPlayers[iPlayer]
	eaPlayer.leaderLandXP = nil
	eaPlayer.leaderSeaXP = nil
end

function RemoveResidentEffects(city)	--if replaced or walks away

	city:SetCityResidentYieldBoost(YIELD_PRODUCTION, 0)
	city:SetCityResidentYieldBoost(YIELD_GOLD, 0)
	city:SetCityResidentYieldBoost(YIELD_SCIENCE, 0)
	city:SetCityResidentYieldBoost(YIELD_CULTURE, 0)
	city:SetCityResidentYieldBoost(YIELD_FAITH, 0)

	local eaCity = gCities[city:Plot():GetPlotIndex()]
	eaCity.residentLandXP = nil
	eaCity.residentSeaXP = nil
end


--------------------------------------------------------------
-- GP Modifier Functions
--------------------------------------------------------------

local subclassModLevelModifier = {
	Witch = {		EAMOD_DIVINATION =		0.25,
					EAMOD_ENCHANTMENT =		0.25,
					EAMOD_ABJURATION =		0.1,
					EAMOD_EVOCATION =		0.1,
					EAMOD_TRANSMUTATION =	0.1,
					EAMOD_CONJURATION =		0.1,
					EAMOD_NECROMANCY =		0.1,
					EAMOD_ILLUSION =		0.1		},
	Wizard = {		EAMOD_DIVINATION =		0.2,
					EAMOD_ABJURATION =		0.2,
					EAMOD_EVOCATION =		0.2,
					EAMOD_TRANSMUTATION =	0.2,
					EAMOD_CONJURATION =		0.2,
					EAMOD_ENCHANTMENT =		0.2		},
	Sorcerer = {	EAMOD_DIVINATION =		0.2,
					EAMOD_EVOCATION =		0.2,
					EAMOD_TRANSMUTATION =	0.2,
					EAMOD_CONJURATION =		0.2,
					EAMOD_NECROMANCY =		0.2,
					EAMOD_ILLUSION =		0.2		},
	Necromancer = {	EAMOD_NECROMANCY =		0.5		},
	Illusionist = {	EAMOD_ILLUSION =		0.5		}
}

local subclassModModifier = {
	Illusionist = {	EAMOD_DIVINATION =		-2,
					EAMOD_ABJURATION =		-2,
					EAMOD_EVOCATION =		-2,
					EAMOD_TRANSMUTATION =	-2,
					EAMOD_CONJURATION =		-2,
					EAMOD_NECROMANCY =		-2		}
}

local cachedGPMod = {}

function ResetGPMods(iPerson)
	cachedGPMod[iPerson] = nil
end

function ResetPlayerGPMods(iPlayer)
	for iPerson, eaPerson in pairs(gPeople) do
		if eaPerson.iPlayer == iPlayer then
			cachedGPMod[iPerson] = nil
		end
	end
end

function GetGPMod(iPerson, modType1, modType2)
	--modType2 is optional; assumes mod is valid for class/subclass

	local eaPerson = gPeople[iPerson]
	local level = eaPerson.level

	local gpModTable = cachedGPMod[iPerson]
	if gpModTable and gpModTable.level == level then
		local mod1Table = gpModTable[modType1]
		if mod1Table then
			local mod = mod1Table[modType2 or "nil"]
			if mod then
				return mod		--return cached value (may happen 100s of times a turn)
			end
		else
			cachedGPMod[iPerson][modType1] = {}
		end
	else
		cachedGPMod[iPerson] = {level = level, [modType1] = {}}
	end

	local promos
	if modType1 == "EAMOD_LEADERSHIP" then
		promos = eaPerson.leaderLevel or 0		--counted as if promo level (so biggest bump early)
	else
		promos = GetHighestPromotionLevel(modsPromotionTable[modType1], nil, iPerson)
	end

	if modType2 then
		if modType2 == "EAMOD_LEADERSHIP" then
			promos = promos + (eaPerson.leaderLevel or 0)
		else
			promos = promos + GetHighestPromotionLevel(modsPromotionTable[modType2], nil, iPerson)
		end
	end

	local totalMod = 5 + (level / 3) + (promos * (1 + 10/(promos + 3)))
	--complicated promo effect gives this progression for I - XVIII (floored): +3 6 8 9 11 12 14 15 16 17 18 20 21 22 23 24 25 26

	--prophet	TO DO: something with this
	--if eaPerson.promotions[PROMOTION_PROPHET] and (modsProphetBonus[modType1] or (modType2 and modsProphetBonus[modType2])) then
	--	totalMod = totalMod + 2
	--end

	--subclass
	local subclass = eaPerson.subclass
	if subclass then
		local modLevelModifier = subclassModLevelModifier[subclass]
		if modLevelModifier then
			totalMod = totalMod + level * ((modLevelModifier[modType1] or 0) + (modLevelModifier[modType2] or 0))
		end
		local modModifier = subclassModModifier[subclass]
		if modModifier then
			totalMod = totalMod + (modModifier[modType1] or 0) + (modModifier[modType2] or 0)
		end
	end

	--age class (TO DO)


	if modType1 == "EAMOD_LEADERSHIP" or modType2 == "EAMOD_LEADERSHIP" then
		if gEpics[EA_EPIC_GRIMNISMAL] and gEpics[EA_EPIC_GRIMNISMAL].iPlayer == eaPerson.iPlayer then
			totalMod = totalMod * (100 + gEpics[EA_EPIC_GRIMNISMAL].mod) / 100
		end
	end

	totalMod = floor(totalMod)

	cachedGPMod[iPerson][modType1][modType2 or "nil"] = totalMod
	return totalMod
end

function SetTowerMods(iPlayer, iPerson)
	local tower = gWonders[EA_WONDER_ARCANE_TOWER][iPerson]
	if not tower then return end
	print("SetTowerMods ", iPlayer, iPerson)
	if not tower[maxModID] then		--init tower mods
		for i = maxModID - 7, maxModID do
			tower[i] = 0
		end
	end

	local modSum = 0
	local bestCasterMod, bestTowerMod = 0, 0
	for i = maxModID - 7, maxModID do
		local casterMod = GetGPMod(iPerson, modTypes[i], nil)
		local towerMod = tower[i]
		if bestCasterMod < casterMod then
			bestCasterMod = casterMod
		end
		if bestTowerMod < towerMod then
			bestTowerMod = towerMod
		end
		local newMod = towerMod < casterMod and casterMod or towerMod
		tower[i] = newMod
		modSum = modSum + newMod
	end
	local newMod = floor(modSum / 8 + 0.5)		--average used for mana generation
	if newMod ~= tower.mod then
		tower.mod = newMod
		UpdateInstanceWonder(iPlayer, EA_WONDER_ARCANE_TOWER)
	end

	if tower.iNamedFor ~= iPerson and bestTowerMod < bestCasterMod then	--rename tower 
		print("Renaming tower for current occupant")
		local eaPerson = gPeople[iPerson]
		if not eaPerson.name then
			UngenericizePerson(eaPerson.iPlayer, iPerson, nil)
		end
		local str = Locale.Lookup(eaPerson.name)
		if string.sub(str, -1) == "s" then
			str = str .. "' Tower"
		else
			str = str .. "'s Tower"
		end
		local plot = GetPlotByIndex(tower.iPlot)
		plot:SetScriptData(str)
		tower.iNamedFor = iPlayer
	end
end



function UnJoinGP(iPlayer, eaPerson)
	Dprint("UnJoinGP ", iPlayer, eaPerson)
	eaPerson.iUnitJoined = -1

	--Does nothing now

end

function AIInturruptGPsForLeadershipOpportunity(iPlayer)	--TO DO: Make this better by selecting best leader for civ
	local player = Players[iPlayer]
	local capital = player:GetCapitalCity()
	if not capital then return end
	local capitalX, capitalY = capital:GetX(), capital:GetY()
	local iClosestGP
	local closestDist = 15	--don't bother anyone past this; a new GP will appear eventually (Heldeofol should be able to take leadership at a distance if at war)
	for iPerson, eaPerson in pairs(gPeople) do
		if eaPerson.iPlayer == iPlayer then
			local gpUnit = player:GetUnitByID(eaPerson.iUnit)
			if gpUnit then
				local dist = PlotDistance(gpUnit:GetX(), gpUnit:GetY(), capitalX, capitalY)
				if dist < closestDist then
					closestDist = dist
					iClosestGP = iPerson
				end
			else
				print("!!!! ERROR: No unit for GP; killing person")
				KillPerson(iPlayer, iPerson, nil, nil, nil)
				--error("No unit for GP")
			end
		end
	end
	if iClosestGP then
		InterruptEaAction(iPlayer, iClosestGP)		--this person will go to capital and take leadership on her own; just needed to get attention
	end
end

function KillPerson(iPlayer, iPerson, unit, iKillerPlayer, deathType)
	--Important! Supply unit if unit needs to be killed! iKillerPlayer is optional but only matters only if unit supplied
	print("KillPerson(iPlayer, iPerson, unit, iKillerPlayer, deathType) ", iPlayer, iPerson, unit, iKillerPlayer, deathType)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local eaPerson = gPeople[iPerson]

	--debug info
	if unit then
		print("Type = ", GameInfo.Units[unit:GetUnitType()].Type)
		print("Original owner = ", unit:GetOriginalOwner())
		print("Name = ", unit:GetName())
	end
	print("eaPerson.iPlayer = ", eaPerson.iPlayer)
	print("eaPerson.iUnit = ", eaPerson.iUnit)
	print("eaPerson.unitTypeID = ", eaPerson.unitTypeID, GameInfo.Units[eaPerson.unitTypeID].Type)
	print("subclass = ", eaPerson.subclass)
	print("class1 = ", eaPerson.class1)
	print("class2 = ", eaPerson.class2)
	print("race = ", eaPerson.race)
	print("name = ", eaPerson.name)
	
	--notification
	if iPlayer == g_iActivePlayer then
		LuaEvents.EaImagePopup({type = "PersonDeath", id = iPerson, sound = "AS2D_EVENT_NOTIFICATION_BAD"})	--TO DO! find unit killed sound
	end

	--housekeeping
	g_skipActivePlayerPeople[iPerson] = nil
	if eaPerson.gotoEaActionID ~= -1 then
		eaPlayer.aiUniqueTargeted[eaPerson.gotoEaActionID] = nil
	end
	ClearActionPlotTargetedForPerson(iPlayer, iPerson)	--just to be safe
	if eaPerson.eaActionID ~= -1 then
		InterruptEaAction(iPlayer, iPerson)
	end

	--leader
	if eaPlayer.leaderEaPersonIndex == iPerson then
		print("Person was leader; changing player leader to No Leader")
		eaPlayer.leaderEaPersonIndex = -1
		if eaPlayer.race == GameInfoTypes.EARACE_MAN then
			player:ChangeLeaderType(GameInfoTypes.LEADER_NO_LDR_MAN)
		elseif eaPlayer.race == GameInfoTypes.EARACE_SIDHE then
			player:ChangeLeaderType(GameInfoTypes.LEADER_NO_LDR_SIDHE)
		elseif eaPlayer.race == GameInfoTypes.EARACE_HELDEOFOL then
			player:ChangeLeaderType(GameInfoTypes.LEADER_NO_LDR_HELDEOFOL)
		end
		PreGame.SetLeaderName(iPlayer, "TXT_KEY_EA_NO_LEADER")

		RemoveLeaderEffects(iPlayer)
		UpdateGlobalYields(iPlayer)
		if not player:IsHuman() then
			AIInturruptGPsForLeadershipOpportunity(iPlayer)
		end
	end

	--remove unit if supplied
	if unit then
		MapModData.bBypassOnCanSaveUnit = true
		unit:Kill(true, iKillerPlayer)
	end

	--debug: test all units to make sure no one else has this person index


	--move person info we may want over to gDeadPeople; keep: eaPersonRowID, subclass, class1, class1, name, level

	--creat dead person table and transfer data we may need later (not table pointers! they break TableSaverLoader!)
	local eaDeadPerson = {}
	eaDeadPerson.deathTurn = Game.GetGameTurn()
	eaDeadPerson.unitTypeID = eaPerson.unitTypeID
	eaDeadPerson.subclass = eaPerson.subclass
	eaDeadPerson.class1 = eaPerson.class1
	eaDeadPerson.class2 = eaPerson.class2
	eaDeadPerson.race = eaPerson.race
	eaDeadPerson.birthYear = eaPerson.birthYear
	eaDeadPerson.modMemory = {}
	for k, v in pairs(eaPerson.modMemory) do
		eaDeadPerson.modMemory[k] = v
	end
	
	eaDeadPerson.x = eaPerson.x			--maybe we want to know where they died?
	eaDeadPerson.y = eaPerson.y
	eaDeadPerson.level = eaPerson.level

	--spells
	if eaPerson.spells then
		eaDeadPerson.spells = {}
		for k, v in pairs(eaPerson.spells) do
			eaDeadPerson.spells[k] = v
		end
	end

	eaDeadPerson.promotions = {}
	for k, v in pairs(eaPerson.promotions) do
		eaDeadPerson.promotions[k] = v
	end

	gDeadPeople[#gDeadPeople + 1] = eaDeadPerson
	gPeople[iPerson] = nil

	print("finished KillPerson")
end




----------------------------------------------------------------
-- Player change
----------------------------------------------------------------

local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)