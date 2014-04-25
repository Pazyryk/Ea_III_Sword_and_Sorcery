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
local EAMOD_LEADERSHIP =				GameInfoTypes.EAMOD_LEADERSHIP

local EA_WONDER_ARCANE_TOWER =			GameInfoTypes.EA_WONDER_ARCANE_TOWER

local PROMOTION_LEARN_SPELL =			GameInfoTypes.PROMOTION_LEARN_SPELL
local PROMOTION_SORCERER =				GameInfoTypes.PROMOTION_SORCERER
local PROMOTION_PROPHET =				GameInfoTypes.PROMOTION_PROPHET
local EA_ACTION_GO_TO_PLOT =			GameInfoTypes.EA_ACTION_GO_TO_PLOT

local YIELD_PRODUCTION = 				GameInfoTypes.YIELD_PRODUCTION
local YIELD_GOLD = 						GameInfoTypes.YIELD_GOLD
local YIELD_SCIENCE =					GameInfoTypes.YIELD_SCIENCE
local YIELD_CULTURE = 					GameInfoTypes.YIELD_CULTURE
local YIELD_FAITH = 					GameInfoTypes.YIELD_FAITH

local bFullCivAI =						MapModData.bFullCivAI
local fullCivs =						MapModData.fullCivs

local gPlayers =			gPlayers
local gPeople =				gPeople

local Floor =				math.floor
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
	modTexts[id] = modInfo.Description			--make text key
	modsPromotionTable[modType] = modInfo.PromotionPrefix
	--modsMultiplier[modType] = modInfo.ModMultiplier
	modsProphetBonus[modType] = modInfo.ProphetBonus
	modsClassTable[modType] = modInfo.Class
	modsSubclassTable[modType] = modInfo.Subclass
	modsSubclassExcludeTable[modType] = modInfo.ExcludeSubclass
end
local numModTypes = #modTypes

--modsForUI has fixed structure (and text, modType, modType2) for the game but values change
MapModData.modsForUI = MapModData.modsForUI or {}
local modsForUI = MapModData.modsForUI
for i = 1, numModTypes do
	local modType = modTypes[i]
	modsForUI[i] = {text = modTexts[i], value = 0}
end
modsForUI.firstMagicMod = numModTypes - 7
modsForUI[numModTypes + 1] = {text = "All Magic Schools", value = 0}
modsForUI[numModTypes + 2] = {text = "Other Magic Schools", value = 0}

local reservedGPs = {}		--nil all entries after all civs gain names
for eaCivInfo in GameInfo.EaCivs() do
	if eaCivInfo.FoundingGPType then
		reservedGPs[GameInfoTypes[eaCivInfo.FoundingGPType] ] = true
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
	local bApplyTowerMods = false
	local tower = gWonders[EA_WONDER_ARCANE_TOWER][iPerson]
	if tower then
		local player = Players[eaPerson.iPlayer]
		local unit = player:GetUnitByID(eaPerson.iUnit)
		if unit:GetPlot():GetPlotIndex() == tower.iPlot then
			bApplyTowerMods = true
		end
	end
	modsForUI.bApplyTowerMods = bApplyTowerMods

	local highestMagicSchool, lowestMagicSchool = 0, 99999
	for i = 1, numModTypes do
		local modType = modTypes[i]
		local value = TestGPModValid(modType, class1, class2, subclass) and GetGPMod(iPerson, modType, nil) or 0

		if value > 0 and i > numModTypes - 8 then		--last 8 are always magic schools (and value always > 0 for all spellcasters)
			if bApplyTowerMods then
				value = value + tower[i]
			end
			if highestMagicSchool < value then
				highestMagicSchool = value
			end
			if lowestMagicSchool > value then
				lowestMagicSchool = value
			end
		end
		modsForUI[i].value = value

	end
	if highestMagicSchool == 0 then
		modsForUI[numModTypes + 1].value = 0	--"All Magic Schools"
		modsForUI[numModTypes + 2].value = 0	--"Other Magic Schools"
	elseif lowestMagicSchool == highestMagicSchool then
		for i = numModTypes - 7, numModTypes do
			modsForUI[i].value = 0
		end
		modsForUI[numModTypes + 1].value = lowestMagicSchool	--"All Magic Schools"
		modsForUI[numModTypes + 2].value = 0					--"Other Magic Schools"
	else
		for i = numModTypes - 7, numModTypes do
			if modsForUI[i].value == lowestMagicSchool then
				modsForUI[i].value = 0
			end
		end
		modsForUI[numModTypes + 1].value = 0					--"All Magic Schools"
		modsForUI[numModTypes + 2].value = lowestMagicSchool	--"Other Magic Schools"		
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
						}
	end

	for iPerson, eaPerson in pairs(gPeople) do
		local eaPersonRowID = eaPerson.eaPersonRowID
		if eaPersonRowID then
			gg_peopleEverLivedByRowID[eaPersonRowID] = iPerson
		end
	end
end

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

local skipPeople = {}

function PeoplePerCivTurn(iPlayer)
	--DebugFunctionExitTest("PeoplePerCivTurn", true)
	print("PeoplePerCivTurn")
	local eaPlayer = gPlayers[iPlayer]
	local player = Players[iPlayer]
	local bHumanPlayer = not bFullCivAI[iPlayer]
	local classPoints = eaPlayer.classPoints
	local gameTurn = Game.GetGameTurn()
	local bExtraPassiveXP = eaPlayer.eaCivNameID == EACIV_LJOSALFAR

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
			if not unit then
				error("No unit for GP")
			end

			--Death by old age
			local bDieOfOldAge = eaPerson.predestinedAgeOfDeath and eaPerson.predestinedAgeOfDeath < age	--predestined thwarts game reload

			if bDieOfOldAge then
				KillPerson(iPlayer, iPerson, unit, nil, "OldAge")
			else
				local bIsLeader = iPerson == eaPlayer.leaderEaPersonIndex

				--Leader modMemory
				if bIsLeader then
					local memValue = 2 ^ (gameTurn / MOD_MEMORY_HALFLIFE)
					eaPerson.modMemory[EAMOD_LEADERSHIP] = eaPerson.modMemory[EAMOD_LEADERSHIP] + (memValue / 2)
				end

				--Do passive xp
				local chance = 100 - age
				chance = chance < 20 and 20 or chance
				if Rand(100, "hello") < chance then
					local xp = bIsLeader and 4 or 2
					if bExtraPassiveXP then
						xp = xp * 3
					end
					unit:ChangeExperience(xp)
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
							skipPeople[iPerson] = true
						elseif eaActionID < FIRST_SPELL_ID then
							if TestEaAction(eaActionID, iPlayer, unit, iPerson) then
								skipPeople[iPerson] = true
							else
								print("Human GP failed TestEaAction at start of turn")
								InterruptEaAction(iPlayer, iPerson)
							end
						else
							if TestEaSpell(eaActionID, iPlayer, unit, iPerson) then
								skipPeople[iPerson] = true
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
					while unit and unit:GetMoves() > 0 do					--repeat call since not all actions use movement or all movement

						unit = AIGPDoSomething(iPlayer, iPerson, unit)		--this function returns unit (if still on map) or nil
						print("after AIGPDoSomething from EaPeople", unit, unit and unit:GetMoves())

						--!!!! POSSIBLE INFINITE LOOP !!!!
						--If it happens, then it most likely due to a particular EaAction that is repeatable and does not reduce movement (which must be fixed)
						if debugLoopCount < 10 then
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


function SkipPeople()
	if bFullCivAI[g_iActivePlayer] then return end	--autoplay
    print("Running SkipPeople")
	local player = Players[g_iActivePlayer]
	for iPerson, boolean in pairs(skipPeople) do
		if boolean then
			local iUnit = gPeople[iPerson].iUnit
			local unit = player:GetUnitByID(iUnit)
			if unit then
				print("GP Moves before = ", unit:GetMoves())
				skipPeople[iPerson] = false
				unit:PopMission()
				unit:PushMission(MissionTypes.MISSION_SKIP, unit:GetX(), unit:GetY(), 0, 0, 1) --, MissionTypes.MISSION_SKIP, unit:GetPlot(), unit)
				print("GP Moves after skip = ", unit:GetMoves())
			end
		end
	end
end
Events.ActivePlayerTurnStart.Add(SkipPeople)


--TO DO: This could be done much better with new turn blocking types in dll


local bLastCallWasHumanPlayer = false

function PeopleAfterTurn(iPlayer, bActionInfoPanelCall)
	--Runs from ActionInfoPanel for human and after turn for AI and human
	print("Running PeopleAfterTurn ", bActionInfoPanelCall, bLastCallWasHumanPlayer)
	local bHumanPlayer = not bFullCivAI[iPlayer]
	local bAllowHumanPlayerEndTurn = true	
	local gameTurn = Game.GetGameTurn()
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]				
	local deadCount = 0

	for iPerson, eaPerson in pairs(gPeople) do
		if eaPerson.iPlayer == iPlayer then

			local unit = eaPerson.iUnit ~= -1 and player:GetUnitByID(eaPerson.iUnit)
			if not unit then
				error("No unit for GP")
			else
				if bHumanPlayer and not bLastCallWasHumanPlayer then	--Human actions run automatically at turn end so that player can interupt
					if unit:GetMoves() > 0 then
						local eaActionID = eaPerson.eaActionID
						if eaActionID ~= -1 then
							if eaActionID < FIRST_SPELL_ID then
								if not DoEaAction(eaActionID, iPlayer, unit, iPerson) then	--does action or cancels
									bAllowHumanPlayerEndTurn = false
								end
							else
								if not DoEaSpell(eaActionID, iPlayer, unit, iPerson) then
									bAllowHumanPlayerEndTurn = false
								end
							end
						else
							--clear whatever this unit thought it was doing (including skip)
							unit:PopMission()
							bAllowHumanPlayerEndTurn = false
						end
					end

				end

			end
		end
	end

	bLastCallWasHumanPlayer = bHumanPlayer

	if bActionInfoPanelCall and bAllowHumanPlayerEndTurn then
		print("About to issue Game.DoControl(GameInfoTypes.CONTROL_ENDTURN)")
		Game.DoControl(GameInfoTypes.CONTROL_ENDTURN)
	end
	print("End of PeapleAfterTurn")
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
				if eaPlayer.classPoints[i] > 50 then
					eaPlayer.classPoints[i] = eaPlayer.classPoints[i] - 50
					if i == 5 then	--Warrior
						gg_combatPointDiff[iPlayer] = gg_combatPointDiff[iPlayer] + 50
					end
				else
					if i == 5 then
						gg_combatPointDiff[iPlayer] = gg_combatPointDiff[iPlayer] + eaPlayer.classPoints[5]
					end
					eaPlayer.classPoints[i] = 0
				end
				break
			end
			dice = dice - eaPlayer.classPoints[i]
		end
	end

	subclass = subclass or PickSubclassForSpawnedClass(iPlayer, class)
	local unitTypeID, class1, class2 = GetInfoFromSubclassClass(subclass, class)
	class2 = class2 or dualClass
	--note: class1 always has value; subclass and/or class2 may be nil

	local capital = player:GetCapitalCity()
	if not capital then return end
	local iUnit, iPerson
	local unit = player:InitUnit(unitTypeID, capital:GetX(), capital:GetY())
	if unit then
		iUnit = unit:GetID()
		iPerson = #gPeople + 1
		local eaPerson = {	iPlayer = iPlayer,					-- !!!!!!!!!!!!!!!!  INIT NEW EaPerson HERE !!!!!!!!!!!!!!!!
							iUnit = iUnit,						-- -1 means not on map
							iUnitJoined = -1,
							unitTypeID = unitTypeID,
							subclass = subclass,
							class1 = class1,
							class2 = class2,
							race = eaPlayer.race,		--takes civ race here; may change when ungenerisized (e.g., Heldeofol takes a subrace)
							birthYear = Game.GetGameTurn() - 20,
							progress = {},
							disappearTurn = -1,		
							promotions = {},
							eaActionID = -1,
							eaActionData = -1,
							gotoPlotIndex = -1,
							gotoEaActionID = -1,
							moves = 0,
							modMemory = {}	}		
		
		gPeople[iPerson] = eaPerson
		unit:SetPersonIndex(iPerson)

		UpdateGreatPersonStatsFromUnit(unit, eaPerson)		--x, y, moves, level, xp; filles promotions table
		if class1 == "Warrior" or class2 == "Warrior" then
			eaPerson.aiHasCombatRole = true
			unit:SetGPAttackState(0)

		end		
		if class1 == "Devout" or class2 == "Devout" or class1 == "Thaumaturge" or class2 == "Thaumaturge" then
			eaPerson.spells = {}		--presence of this table is cue that this is a spellcaster (used by AI and in level gains)
			local spellID = FIRST_SPELL_ID
			local spellInfo = GameInfo.EaActions[spellID]
			while spellInfo do
				if spellInfo.FreeSpellSubclass == subclass then
					eaPerson.spells[spellID] = true
					if spellInfo.AICombatRole then
						eaPerson.aiHasCombatRole = true
					end
				end
				spellID = spellID + 1
				spellInfo = GameInfo.EaActions[spellID]
			end
		end
		
		unit:SetInvisibleType(GameInfoTypes.INVISIBLE_SUBMARINE)
		unit:SetSeeInvisibleType(GameInfoTypes.INVISIBLE_SUBMARINE)

	else
		error("Failed to init gp unit")
		
	end

	if eaPersonRowID or not bFullCivAI[iPlayer] then
		UngenericizePerson(iPlayer, iPerson, eaPersonRowID)
	else
		ResetAgeOfDeath(iPerson)
	end

	if bAsLeader then
		MakeLeader(iPlayer, iPerson)
	end

	if not bFullCivAI[iPlayer] then
		local personType = bAsLeader and "NewPersonLeader" or "NewPerson"
		LuaEvents.EaImagePopup({type = personType, id = iPerson, sound = "AS2D_EVENT_NOTIFICATION_GOOD"})
	end

	return iPerson
end
--LuaEvents.EaPeopleGenerateGreatPerson.Add(GenerateGreatPerson)


function UpdateGreatPersonStatsFromUnit(unit, eaPerson)	--must have unit
	eaPerson.x = unit:GetX()
	eaPerson.y = unit:GetY()
	eaPerson.direction = unit:GetFacingDirection()
	eaPerson.moves = unit:GetMoves()
	eaPerson.level = unit:GetLevel()
	eaPerson.xp = unit:GetExperience()

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
		veryOldChance = Floor(veryOldChance * (100 - ageDeathReduction) / 100 + 0.5)
		ancientChance = Floor(ancientChance * (100 - ageDeathReduction) / 100 + 0.5)
	end

	local age = Floor(0.85 * nominalLifeSpan + 0.5)	--starts at "Very Old" (85% of nominal life span)

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
		gg_peopleEverLivedByRowID[eaPersonRowID] = iPerson
		local eaPersonRow = GameInfo.EaPeople[eaPersonRowID]
		eaPerson.race = GameInfoTypes[eaPersonRow.Race]
		local name = eaPersonRow.Description
		eaPerson.name = name
		eaPerson.eaPersonRowID = eaPersonRowID	--need this for portrait and AI personality (if becomes leader)
		--local eaPortraitType = string.gsub(eaPersonRow.Type, "EAPERSON", "EAPORTRAIT")
		--eaPerson.portrait = GameInfo.EaPortraits[eaPortraitType] and GameInfo.EaPortraits[eaPortraitType].File
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

	--Since GP will stay leader from now on, adjust modMemory so they will take leadership promotions
	local totalModMemory = 0
	for modID, value in pairs(eaPerson.modMemory) do
		if modID ~= EAMOD_LEADERSHIP then
			totalModMemory = totalModMemory + value
		end
	end
	eaPerson.modMemory[EAMOD_LEADERSHIP] = eaPerson.modMemory[EAMOD_LEADERSHIP] or 0
	if eaPerson.modMemory[EAMOD_LEADERSHIP] < 0.667 * totalModMemory then
		eaPerson.modMemory[EAMOD_LEADERSHIP] = 0.667 * totalModMemory
	end

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
				if not bFullCivAI[iPlayer] then
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
	Witch = {		[GameInfoTypes.EAMOD_DIVINATION] =		0.25,
					[GameInfoTypes.EAMOD_ENCHANTMENT] =		0.25,
					[GameInfoTypes.EAMOD_ABJURATION] =		0.1,
					[GameInfoTypes.EAMOD_EVOCATION] =		0.1,
					[GameInfoTypes.EAMOD_TRANSMUTATION] =	0.1,
					[GameInfoTypes.EAMOD_CONJURATION] =		0.1,
					[GameInfoTypes.EAMOD_NECROMANCY] =		0.1,
					[GameInfoTypes.EAMOD_ILLUSION] =		0.1		},
	Wizard = {		[GameInfoTypes.EAMOD_DIVINATION] =		0.2,
					[GameInfoTypes.EAMOD_ABJURATION] =		0.2,
					[GameInfoTypes.EAMOD_EVOCATION] =		0.2,
					[GameInfoTypes.EAMOD_TRANSMUTATION] =	0.2,
					[GameInfoTypes.EAMOD_CONJURATION] =		0.2,
					[GameInfoTypes.EAMOD_ENCHANTMENT] =		0.2		},
	Sorcerer = {	[GameInfoTypes.EAMOD_DIVINATION] =		0.2,
					[GameInfoTypes.EAMOD_EVOCATION] =		0.2,
					[GameInfoTypes.EAMOD_TRANSMUTATION] =	0.2,
					[GameInfoTypes.EAMOD_CONJURATION] =		0.2,
					[GameInfoTypes.EAMOD_NECROMANCY] =		0.2,
					[GameInfoTypes.EAMOD_ILLUSION] =		0.2		},
	Necromancer = {	[GameInfoTypes.EAMOD_NECROMANCY] =		0.5		},
	Illusionist = {	[GameInfoTypes.EAMOD_ILLUSION] =		0.5		}
}

local subclassModModifier = {
	Illusionist = {	[GameInfoTypes.EAMOD_DIVINATION] =		-2,
					[GameInfoTypes.EAMOD_ABJURATION] =		-2,
					[GameInfoTypes.EAMOD_EVOCATION] =		-2,
					[GameInfoTypes.EAMOD_TRANSMUTATION] =	-2,
					[GameInfoTypes.EAMOD_CONJURATION] =		-2,
					[GameInfoTypes.EAMOD_NECROMANCY] =		-2		}
}

function GetGPMod(iPerson, modType1, modType2)
	--need unit or iPerson; modType2 is optional; assumes mod is valid for class/subclass

	--TO DO: Memoize by turn so repeat calls aren't so expensive
	local eaPerson = gPeople[iPerson]
	local level = eaPerson.level
	local levelMod = 5 + Floor(level / 3)
	local promoMod = GetHighestPromotionLevel(modsPromotionTable[modType1], nil, iPerson)
	local bHasAnyLevelsMod1 = 0 < promoMod

	if modType2 then
		local promoMod2 = GetHighestPromotionLevel(modsPromotionTable[modType2], nil, iPerson)
		promoMod = promoMod + promoMod2
	end

	local bonuses = 0
	if eaPerson.promotions[PROMOTION_PROPHET] then
		bonuses = (modsProphetBonus[modType1] or (modType2 and modsProphetBonus[modType2])) and 2 or 0
	end
	local subclass = eaPerson.subclass
	if subclass then
		local modLevelModifier = subclassModLevelModifier[subclass]
		if modLevelModifier then
			local levelMod1 = modLevelModifier[modType1] or 0
			local levelMod2 = modLevelModifier[modType2] or 0
			bonuses = bonuses + (levelMod1 + levelMod2) * level
		end
		local modModifier = subclassModModifier[subclass]
		if modModifier then
			local mod1 = modModifier[modType1] or 0
			local mod2 = modModifier[modType2] or 0
			bonuses = bonuses + mod1 + mod2
		end
	end

	return Floor(levelMod + promoMod + bonuses), bHasAnyLevelsMod1		--2nd arg used for actions that require at least 1 promotion level to do
end

function SetTowerMods(iPerson)
	local tower = gWonders[EA_WONDER_ARCANE_TOWER][iPerson]
	if not tower then return end
	print("SetTowerMods ", iPerson)
	if not tower[numModTypes] then		--init tower mods
		for i = numModTypes - 7, numModTypes do
			tower[i] = 0
		end
	end

	local modSum = 0
	local bestCasterMod, bestTowerMod = 0, 0
	for i = numModTypes - 7, numModTypes do
		local casterMod = GetGPMod(iPerson, i, nil)
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
	tower.mod = Floor(modSum / 8 + 0.5)		--average used for mana generation
	UpdateBuildingsForPlotWonder(EA_WONDER_ARCANE_TOWER, iPerson)

	if tower.iNamedFor ~= iPlayer and bestTowerMod < bestCasterMod then	--rename tower 
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

function AIInturruptGPsForLeadershipOpportunity(iPlayer)	--TO DO: Make this better by selecting good leader for civ
	local player = Players[iPlayer]
	local capital = player:GetCapitalCity()
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
				error("No unit for GP")
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
	skipPeople[iPerson] = nil
	if eaPerson.gotoEaActionID ~= -1 then
		eaPlayer.aiUniqueTargeted[eaPerson.gotoEaActionID] = nil
	end
	ClearActionPlotTargetedForPerson(eaPlayer, iPerson)	--just to be safe
	if eaPerson.eaActionID ~= -1 then
		InterruptEaAction(iPlayer, iPerson)
	end

	--leader
	if eaPlayer.leaderEaPersonIndex == iPerson then
		print("Person was leader; changing player leader to No Leader")
		eaPlayer.leaderEaPersonIndex = -1
		if eaPlayer.race == GameInfoTypes.EARACE_MAN then
			player:ChangeLeaderType(GameInfoTypes.LEADER_NO_LEADER_MAN)
		elseif eaPlayer.race == GameInfoTypes.EARACE_SIDHE then
			player:ChangeLeaderType(GameInfoTypes.LEADER_NO_LEADER_SIDHE)
		elseif eaPlayer.race == GameInfoTypes.EARACE_HELDEOFOL then
			player:ChangeLeaderType(GameInfoTypes.LEADER_NO_LEADER_HELDEOFOL)
		end
		PreGame.SetLeaderName(iPlayer, "TXT_KEY_EA_NO_LEADER")

		RemoveLeaderEffects(iPlayer)
		UpdateGlobalYields(iPlayer)
		if bFullCivAI[iPlayer] then
			AIInturruptGPsForLeadershipOpportunity(iPlayer)
		end
	end

	--remove unit if supplied
	if unit then
		MapModData.bBypassOnCanSaveUnit = true
		unit:Kill(true, iKillerPlayer)
	end

	--debug: test all units to make sure no one else has this person index



	
	--move person info over to gDeadPeople
	eaPerson.deathTurn = Game.GetGameTurn()
	--keep: eaPersonRowID, subclass, class1, class1, name, level

	eaPerson.iUnit = nil
	eaPerson.iUnitJoined = nil
	--eaPerson.progress = nil

	eaPerson.moves = nil
	eaPerson.xp = nil
	--eaPerson.promotions = nil
	eaPerson.eaActionID = nil
	eaPerson.eaActionData = nil
	eaPerson.gotoPlotIndex = nil
	eaPerson.gotoEaActionID = nil

	gDeadPeople[#gDeadPeople + 1] = eaPerson
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