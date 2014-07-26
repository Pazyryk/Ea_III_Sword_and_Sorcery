-- EaSpells
-- Author: Pazyryk
-- DateCreated: 4/24/2014 4:19:25 PM
--------------------------------------------------------------

-- Top functions in this file are almost the same as EaActions
-- 
--------------------------------------------------------------
print("Loading EaSpells.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end


---------------------------------------------------------------
-- Local defines
---------------------------------------------------------------

--constants
local DOMAIN_LAND =							DomainTypes.DOMAIN_LAND
local DOMAIN_SEA =							DomainTypes.DOMAIN_SEA
local EAMOD_DEVOTION =						GameInfoTypes.EAMOD_DEVOTION
local EA_PLOTEFFECT_PROTECTIVE_WARD =		GameInfoTypes.EA_PLOTEFFECT_PROTECTIVE_WARD
local EA_WONDER_ARCANE_TOWER =				GameInfoTypes.EA_WONDER_ARCANE_TOWER
local FEATURE_BLIGHT =	 					GameInfoTypes.FEATURE_BLIGHT
local FEATURE_CRATER =	 					GameInfoTypes.FEATURE_CRATER
local FEATURE_FALLOUT =	 					GameInfoTypes.FEATURE_FALLOUT
local FEATURE_FOREST = 						GameInfoTypes.FEATURE_FOREST
local FEATURE_JUNGLE = 						GameInfoTypes.FEATURE_JUNGLE
local FEATURE_MARSH =	 					GameInfoTypes.FEATURE_MARSH
local INVISIBLE_SUBMARINE =					GameInfoTypes.INVISIBLE_SUBMARINE
local PLOT_LAND =							PlotTypes.PLOT_LAND
local PLOT_MOUNTAIN =						PlotTypes.PLOT_MOUNTAIN
local PLOT_OCEAN =							PlotTypes.PLOT_OCEAN
local PROMOTION_BLESSED =					GameInfoTypes.PROMOTION_BLESSED
local PROMOTION_CURSED =					GameInfoTypes.PROMOTION_CURSED
local PROMOTION_EVIL_EYE =					GameInfoTypes.PROMOTION_EVIL_EYE
local PROMOTION_FAIR_WINDS =				GameInfoTypes.PROMOTION_FAIR_WINDS
local PROMOTION_HEX =						GameInfoTypes.PROMOTION_HEX
local PROMOTION_PROTECTION_FROM_EVIL =		GameInfoTypes.PROMOTION_PROTECTION_FROM_EVIL
local PROMOTION_RIDE_LIKE_THE_WINDS =		GameInfoTypes.PROMOTION_RIDE_LIKE_THE_WINDS
local RELIGION_ANRA =						GameInfoTypes.RELIGION_ANRA
local RELIGION_THE_WEAVE_OF_EA =			GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
local TERRAIN_GRASS =						GameInfoTypes.TERRAIN_GRASS
local TERRAIN_PLAINS =						GameInfoTypes.TERRAIN_PLAINS
local TERRAIN_TUNDRA =						GameInfoTypes.TERRAIN_TUNDRA
local UNIT_LICH =							GameInfoTypes.UNIT_LICH
local UNITCOMBAT_GUN =						GameInfoTypes.UNITCOMBAT_GUN
local UNITCOMBAT_MOUNTED =					GameInfoTypes.UNITCOMBAT_MOUNTED

local UNHAPPINESS_PER_CITY =				GameDefines.UNHAPPINESS_PER_CITY
local UNIT_SUFFIXES =						UNIT_SUFFIXES
local NUM_UNIT_SUFFIXES =					#UNIT_SUFFIXES
local MOD_MEMORY_HALFLIFE =					MOD_MEMORY_HALFLIFE

local MAX_RANGE =							MAX_RANGE
local FIRST_SPELL_ID =						FIRST_SPELL_ID
local MAX_UNIT_HP =							100

--global tables
local GameInfoTypes =						GameInfoTypes
local MapModData =							MapModData
local fullCivs =							MapModData.fullCivs
local gods =								MapModData.gods
local gWorld =								gWorld
local gCities =								gCities
local gPlayers =							gPlayers
local gPeople =								gPeople
local gReligions =							gReligions
local gWonders =							gWonders
local gg_aiOptionValues =					gg_aiOptionValues
local gg_bToCheapToHire =					gg_bToCheapToHire
local gg_baseUnitPower =					gg_baseUnitPower
local gg_playerPlotActionTargeted =			gg_playerPlotActionTargeted
local gg_eaSpecial =						gg_eaSpecial
local gg_regularCombatType =				gg_regularCombatType

--localized functions
local floor =								math.floor
local GetPlotByIndex =						Map.GetPlotByIndex
local GetPlotFromXY =						Map.GetPlot
local PlotDistance =						Map.PlotDistance
local Rand =								Map.Rand
local HandleError61 =						HandleError61
local HandleError21 =						HandleError21

--local functions
local Test = {}
local TestTarget = {}
local SetUI = {}
local SetAIValues = {}
local Do = {}
local Interrupt = {}
local Finish = {}

--file control
--	All applicable are calculated in TestEaSpell any time we are in this file. Never change anywhere else!
--  Non-applicable variables will hold value from last call
local g_eaAction
local g_eaActionID
local g_SpellClass				-- nil, "Arcane" or "Devine"
local g_bAIControl				--for AI control of unit (can be true for human if Autoplay)
local g_iActivePlayer = Game.GetActivePlayer()

local g_gameTurn = 0

local g_iPlayer
local g_eaPlayer
local g_player
local g_iTeam
local g_team
local g_faith

local g_unit
local g_iUnit
local g_unitTypeID

local g_bGreatPerson				--if true then the following values are always calculated
local g_iPerson
local g_eaPerson
local g_mod
local g_subclass
local g_class1
local g_class2
local g_iUnitJoined
local g_joinedUnit

local g_unitX						--same as g_x, g_y below if no targetX,Y supplied in function call
local g_unitY
local g_bEmbarked

local g_bTarget						--true if targetX, targetY provided; otherwise, values are for g_unitX, g_unitY
local g_iPlot
local g_plot
local g_specialEffectsPlot			--same as g_plot unless changed in specific function
local g_iOwner
local g_x
local g_y

local g_bInTowerOrTemple			--these two are only set if g_eaAction.ConsiderTowerTemple
local g_modSpell					--g_mod plus plot Tower/Temple mod
local g_modSpellTimesTurns			--above times turns to cast (this is the "standard" mana use / xp gain)

local g_bIsCity		--if true then the following values are always calculated (follows target g_x, g_y if provided; otherwise g_unit g_x,g_y)
local g_iCity
local g_city
local g_eaCity

local g_worldManaDepletion			--0 - 1; use ful for many AI valueations so set once at end of TestEaSpell

--human UI stuff (what is stopping us?)
local g_bUICall = false
local g_bUniqueBlocked = false
local g_bSomeoneElseDoingHere = false
local g_bNonTargetTestsPassed = false
local g_bAllTestsPassed = false
local g_bSufficientFaith = true
local g_bSetDelayedFailForUI = false
--local g_bHasSpell = false

--communicate from TestTarget to SetUI or SetAIValues when needed (reset to 0 from Test)
local g_testTargetSwitch = 0

--use these values and table to pass among functions (e.g., from specific Test to specific Do function)
local g_count = 0
local g_value = 0
local g_int1, g_int2, g_int3, g_int4, g_int5 = 0, 0, 0, 0, 0
local g_bool1 = false
local g_text1 = ""
local g_obj1, g_obj2

local g_integers = {}
local g_integers2 = {}
local g_integersPos = 0
local g_table = {}	--anything else

local g_tradeAvailableTable = {}

---------------------------------------------------------------
-- Cached table values
---------------------------------------------------------------

local EaActionsInfo = {}			-- Contains the entire table for speed (for ID >= FIRST_SPELL_ID)
local spellLevel = {}				-- used only for AI valuation in choosing spell to learn
for eaActionInfo in GameInfo.EaActions() do
	local id = eaActionInfo.ID
	if id >= FIRST_SPELL_ID then
		EaActionsInfo[id] = eaActionInfo
		spellLevel[id] = 1
		if eaActionInfo.TechReq then
			local techInfo = GameInfo.Technologies[eaActionInfo.TechReq]
			spellLevel[id] = 0 < techInfo.GridX and techInfo.GridX + 1 or 1
		elseif eaActionInfo.PolicyReq then
			local policyInfo = GameInfo.Policies[eaActionInfo.PolicyReq]
			if policyInfo.PolicyBranchType then
				spellLevel[id] = 0 < policyInfo.GridY and policyInfo.GridY + 1 or 1
			elseif string.find(policyInfo.Type, "_FINISHER") then
				spellLevel[id] = 6
			end
		end
	end
end

local gpTempTypeUnits = {}	--index by role, originalTypeID; holds tempTypeID
local firstArchdemonID, firstArchangelID
local godUnits = {}
for unitInfo in GameInfo.Units() do
	if unitInfo.EaGPTempRole then
		local role = unitInfo.EaGPTempRole
		local baseUnitTypeID = GameInfoTypes[unitInfo.EaGPTempBaseUnit]
		gpTempTypeUnits[role] = gpTempTypeUnits[role] or {}
		gpTempTypeUnits[role][baseUnitTypeID] = unitInfo.ID
	end
	if unitInfo.EaSpecial then
		if unitInfo.EaSpecial == "Archdemon" then
			firstArchdemonID = firstArchdemonID or unitInfo.ID
		elseif unitInfo.EaSpecial == "Archangel" then
			firstArchangelID = firstArchangelID or unitInfo.ID
		elseif unitInfo.EaSpecial == "MajorSpirit" then
			local minorTypeID = GameInfoTypes[string.gsub(unitInfo.Type, "UNIT_", "MINOR_CIV_")]
			local iPlayer = gg_minorPlayerByTypeID[minorTypeID]		--nil if not in this game
			if iPlayer then
				godUnits[iPlayer] = unitInfo.ID
				print("iGodPlayer / unit = ", iPlayer, unitInfo.ID)
			end
		end
	end
end
print("firstArchdemonID, firstArchangelID = ", firstArchdemonID, firstArchangelID)

---------------------------------------------------------------
--Time Discout valuation
---------------------------------------------------------------
--Used in AI devaluation of future gains; see:
--http://forums.civfanatics.com/showpost.php?p=11452419&postcount=89

local TIME_DISCOUNT_RATE = 0.98623					--gives half-value at 50 turns
local TIME_DISCOUNT_RATE_COMBAT = 0.98623				--??? should be different ???
local TIME_DISCOUNT_RATE_COMBAT_NEXT_TURN = 0.98623		--??? 

local discountRateTable = {}
discountRateTable[0] = 1
for i = 1, 300 do						--pre-calculate rate powers for speed
	discountRateTable[i] = discountRateTable[i - 1] * TIME_DISCOUNT_RATE
end

local discountCombatRateTable = {}
discountCombatRateTable[0] = 1
discountCombatRateTable[1] = TIME_DISCOUNT_RATE_COMBAT_NEXT_TURN
for i = 2, 50 do						--pre-calculate rate powers for speed
	discountCombatRateTable[i] = discountCombatRateTable[i - 1] * TIME_DISCOUNT_RATE_COMBAT
end

local OutOfRangeReturnZeroMetaTable = {__index = function() return 0 end}	--return 0 rather than nil for out of range index
setmetatable(discountRateTable, OutOfRangeReturnZeroMetaTable)
setmetatable(discountCombatRateTable, OutOfRangeReturnZeroMetaTable)


----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	print("EaAction.lua OnActivePlayerChanged ", iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)

----------------------------------------------------------------
-- Local functions
----------------------------------------------------------------

local function SpecialEffects()
	print("Running SpecialEffects ", g_eaAction.Type, g_eaAction.HumanOnlyFX, g_eaAction.HumanVisibleFX, g_eaAction.HumanOnlySound, g_eaAction.HumanVisibleSound, g_eaAction.PlayAnywhereSound)
	local fx, sound
	if g_iPlayer == g_iActivePlayer then
		fx = g_eaAction.HumanOnlyFX or g_eaAction.HumanVisibleFX
		sound = g_eaAction.HumanOnlySound or g_eaAction.HumanVisibleSound
	elseif g_specialEffectsPlot:IsVisible(Game.GetActiveTeam(), false) then
		fx = g_eaAction.HumanVisibleFX
		sound = g_eaAction.HumanVisibleSound
	end
	local bLookAt = fx or sound
	sound = sound or g_eaAction.PlayAnywhereSound
	if bLookAt then
		UI.LookAt(g_specialEffectsPlot, 0)
	end
	if sound then
		Events.AudioPlay2DSound(sound)
	end
	if fx then
		local hex = ToHexFromGrid( Vector2(g_specialEffectsPlot:GetX(), g_specialEffectsPlot:GetY() ) )
		Events.GameplayFX(hex.x, hex.y, -1)
	end
end

function FinishEaSpell(eaActionID)		--only called from DoEaSpell so file locals already set
	print("FinishEaSpell", g_iPlayer, g_eaAction.Type)

	if g_eaAction.TurnsToComplete == 1000 and g_bAIControl then	--this is a sustained action interrupt (not really a "finish")
		InterruptEaAction(g_iPlayer, g_iPerson)		
		return true
	end

	--Plot Float Up Text
	if not g_eaAction.NoFloatUpText or MapModData.bAutoplay then
		g_plot:AddFloatUpMessage(Locale.Lookup(g_eaAction.Description), 2)
	end

	ClearActionPlotTargetedForPerson(g_iPlayer, g_iPerson)
	g_eaPerson.eaActionID = -1		--will bring back to map on next turn

	g_unit:SetInvisibleType(INVISIBLE_SUBMARINE)

	--Mana or divine favor
	if 0 < g_eaAction.FixedFaith then
		UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_eaAction.FixedFaith, false)
	end

	--XP
	if g_eaAction.FinishXP > 0 then
		g_unit:ChangeExperience(g_eaAction.FinishXP)
	end

	g_eaPlayer.aiUniqueTargeted[eaActionID] = nil

	--Effects
	if g_eaAction.ClaimsPlot and g_iOwner ~= g_iPlayer then
		local city = GetNewOwnerCityForPlot(g_iPlayer, g_iPlot, g_eaAction.ReqNearbyCityReligion and GameInfoTypes[g_eaAction.ReqNearbyCityReligion])
		g_plot:SetOwner(g_iPlayer, city:GetID())
	end

	if g_eaAction.ImprovementType then
		local improvementID = GameInfoTypes[g_eaAction.ImprovementType]
		g_plot:SetImprovementType(improvementID)
	end

	if g_eaAction.Building then
		local buildingID = GameInfoTypes[g_eaAction.Building]
		g_city:SetNumRealBuilding(buildingID, 1)
	end
	if g_eaAction.BuildingMod then
		local buildingID = GameInfoTypes[g_eaAction.BuildingMod]
		g_city:SetNumRealBuilding(buildingID, g_mod)
	end

	if g_eaAction.UniqueType then							--make NOT available permanently for any GP
		if g_eaAction.UniqueType == "World" then
			gWorldUniqueAction[eaActionID] = -1
		elseif g_eaAction.UniqueType == "National" then
			g_eaPlayer.nationalUniqueAction[eaActionID] = -1
		end
	end

	print("About to try action-specific Finish function, if any")
	if Finish[eaActionID] and not Finish[eaActionID]() then return false end	--this is the custom Finish call

	SpecialEffects()

	if g_eaPerson.timeStop and g_unit then
		CheckTimeStopUnit(g_unit, g_eaPerson)
	end

	return true
end

---------------------------------------------------------------
-- Top level (generic) Test, Do, Finish and Interrupt functions
---------------------------------------------------------------

--For actions with TurnsToComplete > 1, the Do function is called by Lua each turn (end of turn for human, beginning for AI). 
--Finish functions are for actions that take time, runs when completed (does generic function like building add, or calls custom function).


function TestEaSpellForHumanUI(eaActionID, iPlayer, unit, iPerson, testX, testY)	--called from UnitPanel
	Dprint("TestEaSpellForHumanUI ", eaActionID, iPlayer, unit, iPerson, testX, testY)
	--	MapModData.bShow	--> "Show" this button in UI.
	--	MapModData.bAllow	--> "Can do" (always equals Test return)
	--	MapModData.text	--> Displayed text when boolean1 = true (will display in red if boolean2 = false)
	g_bUICall = true
	g_bUniqueBlocked = false
	
	g_bAllTestsPassed = TestEaSpell(eaActionID, iPlayer, unit, iPerson, testX, testY, false)
	MapModData.bAllow = g_bAllTestsPassed and not g_bSetDelayedFailForUI
	MapModData.bShow = true				--this should always be the case for spells (search and destroy all other MapModData.bShow changes in this file!)
	MapModData.text = "no help text"	--will change below or take eaAction.Help value

	--By default, text will be from eaAction.Help. If we want something else, then we must change below or in action-specific SetUI function.


	if g_bEmbarked then
		MapModData.text = "[COLOR_WARNING_TEXT]Cannot cast spell while embarked[ENDCOLOR]"
	end

	--Set UI for unique builds (generic way; it can be overriden by specific SetUI funtion)
	if MapModData.text == "no help text" then
		if g_bUniqueBlocked then
			if g_eaAction.UniqueType == "World" then
				if gWorldUniqueAction[eaActionID] then
					if gWorldUniqueAction[eaActionID] ~= -1 then	--being built
						local bMyCiv = false
						for iPerson, eaPerson in pairs(gPeople) do
							if eaPerson.iPlayer == iPlayer and gWorldUniqueAction[eaActionID] == iPerson then
								bMyCiv = true
								break
							end
						end
						if bMyCiv then
							MapModData.text = "[COLOR_WARNING_TEXT]Another Great Person from your civilization is working on this...[ENDCOLOR]"
						else
							MapModData.text = "[COLOR_WARNING_TEXT]A Great Person from another civilization is working on this...[ENDCOLOR]"
						end
					end
				end		
			elseif g_eaAction.UniqueType == "National" then
				if g_eaPlayer.nationalUniqueAction[eaActionID] then
					if g_eaPlayer.nationalUniqueAction[eaActionID] ~= -1 then	--being built
						MapModData.text = "[COLOR_WARNING_TEXT]Another Great Person from your civilization is working on this...[ENDCOLOR]"
					end
				end
			end
		elseif g_bSomeoneElseDoingHere then		--true only if all other tests passed
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot do this in the same place as another great person from your civilization[ENDCOLOR]"	
		end
	end


	if MapModData.text == "no help text" and not g_bSufficientFaith then
		local magicStuff = g_eaPlayer.bUsesDivineFavor and "divine favor" or "mana"
		if g_faith < 1 then
			MapModData.text = "[COLOR_WARNING_TEXT]You do not have any " .. magicStuff .. "![ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]You do not have sufficient " .. magicStuff .. " to cast this spell (at least " .. g_value .. " needed, maybe more)[ENDCOLOR]"
		end
	end

	if not g_bEmbarked and SetUI[eaActionID] then
		SetUI[eaActionID]()
	end

	if MapModData.text == "no help text" and g_eaAction.Help then
		MapModData.text = Locale.ConvertTextKey(g_eaAction.Help)
		if not g_bAllTestsPassed or g_bSetDelayedFailForUI then
			MapModData.text = "[COLOR_WARNING_TEXT]" .. MapModData.text .. "[ENDCOLOR]"
		end
	end
	g_bUICall = false
	g_bSetDelayedFailForUI = false
end
--LuaEvents.EaSpellsTestEaSpellForHumanUI.Add(TestEaSpellForHumanUI)
LuaEvents.EaSpellsTestEaSpellForHumanUI.Add(function(eaActionID, iPlayer, unit, iPerson, testX, testY) return HandleError61(TestEaSpellForHumanUI, eaActionID, iPlayer, unit, iPerson, testX, testY) end)

function TestEaSpell(eaActionID, iPlayer, unit, iPerson, testX, testY, bAINonTargetTest)
	--This function sets all file locals related to iPlayer and iPerson 
	--iPerson must have value if this is a great person
	--unit must be non-nil EXCEPT if this is a GP not on map
	g_eaAction = EaActionsInfo[eaActionID]
	g_eaActionID = g_eaAction.ID
	g_gameTurn = Game.GetGameTurn()

	--print("TestEaSpell", eaActionID, iPlayer, unit, iPerson, testX, testY, bAINonTargetTest)

	g_bNonTargetTestsPassed = false
	g_testTargetSwitch = 0

	g_SpellClass = g_eaAction.SpellClass
	if not g_SpellClass then
		error("TestEaSpell g_eaAction did not have a SpellClass")
	end

	g_bEmbarked = unit:IsEmbarked()
	if g_bEmbarked then return false end

	--skip all world and civ-level reqs (for spells, these only apply to learning not casting) except for FixedFaith
	if not iPerson then return false end	--we'll handle non-GP spellcasting later
	g_eaPerson = gPeople[iPerson]
	--if not g_eaPerson.spells or not g_eaPerson.spells[eaActionID] then	--don't have spells or this spell (most common exclude)
	--	g_bHasSpell = false
	--	return false
	--end	
	--g_bHasSpell = true
	g_iPlayer = iPlayer
	g_eaPlayer = gPlayers[iPlayer]
	g_player = Players[iPlayer]
		
	g_iTeam = g_player:GetTeam()
	g_team = Teams[g_iTeam]	


	if bAINonTargetTest then
		if g_eaPlayer.aiUniqueTargeted[eaActionID] and g_eaPlayer.aiUniqueTargeted[eaActionID] ~= iPerson then return false end	--ai specific exclude (someone on way to do this)
		g_bAIControl = true
	else
		g_bAIControl = not g_player:IsHuman()
	end

	g_unit = unit
	g_unitX, g_unitY = unit:GetX(), unit:GetY()
	g_iUnit = unit:GetID()
	g_unitTypeID = unit:GetUnitType()
	if unit:IsGreatPerson() then
		g_bGreatPerson = true
		g_iPerson = iPerson or unit:GetPersonIndex()
		g_eaPerson = gPeople[g_iPerson]
		g_iUnitJoined = g_eaPerson.iUnitJoined
		if g_iUnitJoined ~= -1 then
			g_joinedUnit = g_player:GetUnitByID(g_iUnitJoined)
		end
	else
		g_bGreatPerson = false
	end 

	--Unique already created or being created			TEST THIS!!!
	if g_bGreatPerson and g_eaAction.UniqueType then		--built or someone else building
		if (g_eaAction.UniqueType == "World" and gWorldUniqueAction[eaActionID] and gWorldUniqueAction[eaActionID] ~= iPerson)
			or (g_eaAction.UniqueType == "National" and g_eaPlayer.nationalUniqueAction[eaActionID] and g_eaPlayer.nationalUniqueAction[eaActionID] ~= iPerson) then
			g_bUniqueBlocked = true
			return false
		end
	end

	--Action Modifiers
	if g_bGreatPerson then
		local modType1 = g_eaAction.GPModType1
		g_mod = modType1 and GetGPMod(g_iPerson, modType1, g_eaAction.GPModType2) or 0
	end

	g_faith = g_player:GetFaith()
	if g_faith < g_eaAction.FixedFaith then
		g_bSufficientFaith = false
		g_value = g_eaAction.FixedFaith
		return false
	else
		local turnsToComplete = g_eaAction.TurnsToComplete
		g_modSpellTimesTurns = g_mod * turnsToComplete		--this will get set again in TestTargetEaSpell, just need quick value here for early faith bailout
		if g_faith < g_modSpellTimesTurns then
			g_bSufficientFaith = false
			g_value = g_modSpellTimesTurns
			return false
		else
			g_bSufficientFaith = true
		end
	end

	g_worldManaDepletion = 1 - gWorld.sumOfAllMana / MapModData.STARTING_SUM_OF_ALL_MANA

	--Specific action test (runs if it exists)
	if Test[eaActionID] and not Test[eaActionID]() then return false end

	--All non-target tests have passed
	g_bNonTargetTestsPassed = true

	if not bAINonTargetTest then
		if not testX then
			testX, testY = g_unitX, g_unitY
		end
		if not TestEaSpellTarget(eaActionID, testX, testY, false) then return false end
	end
	return true	
end					

function TestEaSpellTarget(eaActionID, testX, testY, bAITargetTest)
	--This function sets all file locals related to the target plot
	--AI can call this directly but ONLY after a call to TestEaSpell so that civ/caster file locals are correct
	--print("TestEaSpellTarget",eaActionID, testX, testY, bAITargetTest)

	g_testTargetSwitch = 0
	g_bSomeoneElseDoingHere = false

	--Plot and city
	g_x, g_y = testX, testY
	g_iPlot = GetPlotIndexFromXY(testX, testY)

	--Action being done here (or GP on way for AI)
	if not g_eaAction.NoGPNumLimit then
		--local plotTargeted = g_eaPlayer.actionPlotTargeted[eaActionID]
		--if plotTargeted and plotTargeted[g_iPlot] and plotTargeted[g_iPlot] ~= g_iPerson then			--another AI GP is doing this here (or on way for AI)
		--	if g_bAIControl then
		--		print("TestEaActionTarget returning false for AI becuase someone else has claimed this action at this plot")
		--		return false
		--	else
		--		g_bSomeoneElseDoingHere = true
		--		--will return false but delayed until below for human UI
		--	end
		--end

		local targetPlotActions = gg_playerPlotActionTargeted[g_iPlayer][g_iPlot]
		if targetPlotActions then
			local bBlock = false
			if targetPlotActions[eaActionID] and targetPlotActions[eaActionID] ~= g_iPerson then		--another AI GP is doing this or building improvement here (or on way for AI)
				if g_bAIControl then
					print("TestEaActionTarget returning false for AI becuase someone else has claimed this action at this plot")
					return false
				else
					g_bSomeoneElseDoingHere = true
					--will return false but delayed until below for human UI
				end
			end
		end
	end

	g_plot = GetPlotFromXY(testX, testY)
	if g_eaAction.BuildType and not g_plot:CanBuild(GameInfoTypes[g_eaAction.BuildType], g_iPlayer) then return false end
	g_iOwner = g_plot:GetOwner()

	if g_eaAction.OwnCityRadius then
		if not g_plot:IsPlayerCityRadius(g_iPlayer) then return false end
		if g_eaAction.ReqNearbyCityReligion then
			if g_iOwner == g_iPlayer then
				local iCity = g_plot:GetCityPurchaseID()
				local city = g_player:GetCityByID(iCity)
				if city:GetReligiousMajority() ~= GameInfoTypes[g_eaAction.ReqNearbyCityReligion] then return false end
			else	--does any player city in radius have religion (faster to iterate cities or plots?)
				local religionID = GameInfoTypes[g_eaAction.ReqNearbyCityReligion]
				local bNoCity = true
				for city in g_player:Cities() do
					if city:GetReligiousMajority() == religionID and PlotDistance(g_x, g_y, city:GetX(), city:GetY()) < 4 then
						bNoCity = false
						break
					end
				end
				if bNoCity then return false end
			end
		end
	end

	if g_eaAction.OwnTerritory and g_iOwner ~= g_iPlayer then
		if g_bUICall and g_eaAction.UnitUpgradeTypePrefix then
			g_bSetDelayedFailForUI = true
		else
			return false
		end
	end

	g_bIsCity = g_plot:IsCity()

	if g_eaAction.City then
		if g_eaAction.City == "Not" then
			if g_bIsCity then return false end
		else
			if not g_bIsCity then return false end
			if g_eaAction.FoundsSpreadsCult then	--Pantheism cult (can't do in foreign city unless we are founder)
				if g_iOwner ~= g_iPlayer then
					local cultID = GameInfoTypes[g_eaAction.FoundsSpreadsCult]
					if not gReligions[cultID] or gReligions[cultID].founder ~= g_iPlayer then return false end
				end
			elseif g_eaAction.City == "Own" then
				if g_iOwner ~= g_iPlayer then return false end
			elseif g_eaAction.City == "Foreign" then
				if g_iOwner == g_iPlayer then return false end
			end
		end
	end

	if g_bIsCity then
		if g_iOwner ~= g_iPlayer and g_team:IsAtWar(Players[g_iOwner]:GetTeam()) then return false end		--fail if enemy city
		g_city = g_plot:GetPlotCity()
		if g_eaAction.Building and g_city:GetNumBuilding(GameInfoTypes[g_eaAction.Building]) > 0 then return false end	--already has building
		if g_eaAction.BuildingMod and g_city:GetNumBuilding(GameInfoTypes[g_eaAction.BuildingMod]) > 0 then return false end
		g_iCity = g_city:GetID()
		g_eaCity = gCities[g_iPlot]
	end

	if g_eaAction.CapitalOnly and (not g_bIsCity or not g_city:IsCapital()) then return false end

	if g_eaAction.BuildingReq then
		if not g_bIsCity then return false end
		if g_city:GetNumBuilding(GameInfoTypes[g_eaAction.BuildingReq]) < 1 then return false end
	end

	g_specialEffectsPlot = g_plot	--can be changed in by action specific function

	--set g_modSpell from g_mod
	if g_eaAction.ConsiderTowerTemple then
		if gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson] then		--has tower
			if gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson].iPlot == g_iPlot then	--in tower
				g_bInTowerOrTemple = true
				g_modSpell = g_mod + gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson][GameInfoTypes[g_eaAction.GPModType1] ]		--Assume all spells have exactly one mod
			else	--not in tower
				if g_eaAction.TowerTempleOnly then return false end
				g_bInTowerOrTemple = false
				g_modSpell = g_mod
			end
		elseif g_eaPerson.templeID and gWonders[g_eaPerson.templeID].iPlot == g_iPlot then		--has temple and is in it
			g_bInTowerOrTemple = true
			local temple = gWonders[g_eaPerson.templeID]
			if 0 < temple[EAMOD_DEVOTION] then		--Azz temple, no magic schools
				g_modSpell = g_mod + temple[EAMOD_DEVOTION]
			else									--all other temples
				g_modSpell = g_mod + temple[GameInfoTypes[g_eaAction.GPModType1] ]
			end
		else	
			if g_eaAction.TowerTempleOnly then return false end
			g_bInTowerOrTemple = false
			g_modSpell = g_mod
		end
	else
		g_bInTowerOrTemple = false
		g_modSpell = g_mod
	end

	local turnsToComplete = g_eaAction.TurnsToComplete
	g_modSpellTimesTurns = g_modSpell * turnsToComplete
	if g_faith < g_modSpellTimesTurns then			--this is generic minimum; Test or TestTarget can fail on more restrictive value
		g_bSufficientFaith = false
		g_value = g_modSpellTimesTurns --for UI
		return false
	else
		g_bSufficientFaith = true
	end

	if TestTarget[eaActionID] and not TestTarget[eaActionID]() then return false end

	if g_bSomeoneElseDoingHere then return false end	--after TestTarget so special human UI can be shown if needed

	if turnsToComplete == 1000 and g_bAIControl then turnsToComplete = 8 end	--AI will wake up and test other options
	if turnsToComplete > 1 and turnsToComplete ~= 1000 then

		--Update progress
		local progressHolder = g_eaAction.ProgressHolder
		local progress
		if progressHolder == "Person" then
			progress = g_eaPerson.progress[eaActionID] or 0
		elseif progressHolder == "City" then
			progress = g_eaCity.progress[eaActionID] or 0
		elseif progressHolder == "CityCiv" then
			progress = g_eaCity.civProgress[g_iPlayer] and g_eaCity.civProgress[g_iPlayer][eaActionID] or 0
		elseif progressHolder == "Plot" then
			local buildID = GameInfoTypes[g_eaAction.BuildType]
			progress = g_plot:GetBuildProgress(buildID)
		end

		turnsToComplete = turnsToComplete - progress
	end

	print("All target tests passed")

	if bAITargetTest then
		gg_aiOptionValues.t = turnsToComplete															-- turns to complete (AI also uses turns to get to go to target, g)
		gg_aiOptionValues.i = g_eaAction.AIAdHocValue													-- instant value at completion
		gg_aiOptionValues.p = g_eaAction.AISimpleYield													-- per turn value after completion
		gg_aiOptionValues.b = 0																			-- per turn value during action
		gg_aiOptionValues.r = g_eaAction.AICombatRole and discountCombatRateTable or discountRateTable

		if SetAIValues[eaActionID] then SetAIValues[eaActionID]() end	-- SetAIValues function (if exists) can override values above as needed
	else
		MapModData.integer = (turnsToComplete == 1) and 0 or turnsToComplete	--pass 0 for one-turn action so Turns won't be shown
	end
	return true
end

local function DoEaSpellFromOtherState(eaActionID, iPlayer, unit, iPerson, targetX, targetY)	--UnitPanel.lua or WorldView.lua
	print("DoEaSpellFromOtherState ", eaActionID, iPlayer, unit, iPerson, targetX, targetY)
	MapModData.bSuccess = DoEaSpell(eaActionID, iPlayer, unit, iPerson, targetX, targetY)
end
LuaEvents.EaSpellsDoEaSpellFromOtherState.Add(function(eaActionID, iPlayer, unit, iPerson, targetX, targetY) return HandleError61(DoEaSpellFromOtherState, eaActionID, iPlayer, unit, iPerson, targetX, targetY) end)

function DoEaSpell(eaActionID, iPlayer, unit, iPerson, targetX, targetY)
	print("DoEaSpell before test ", eaActionID, iPlayer, unit, iPerson, targetX, targetY)

	local bTest = TestEaSpell(eaActionID, iPlayer, unit, iPerson, targetX, targetY, false)	--this will set all file variables we need
	print("DoEaSpell after test ", g_eaAction.Type, iPlayer, unit, iPerson, targetX, targetY, bTest)

	g_eaPerson.gotoPlotIndex = -1	
	g_eaPerson.gotoEaActionID = -1

	if g_bGreatPerson then
		if g_eaPerson.eaActionID ~= -1 and g_eaPerson.eaActionID ~= eaActionID then					--GP had a previous action that needs to be interrupted
			InterruptEaAction(iPlayer, iPerson)
		elseif not bTest and g_eaPerson.eaActionID == eaActionID then								--this was an ongoing action that needs to be interrupted
			InterruptEaSpell(iPlayer, iPerson)
			--ReappearGP(iPlayer, iPerson)
		end
	end
	if not bTest then return false end	--action cannot be done for some reason; GP will reappear for instructions (human or AI)

	--add generic table tag effects here

	if Do[eaActionID] then
		if not Do[eaActionID]() then	--this is the call to action-specific Do function if it exists
			print("!!!! Warning: TestEaSpell said OK but action specific Do function did not return a true value")
			InterruptEaAction(iPlayer, g_iPerson)
			return false		--Warning! AI might go into infinite loop if Test keeps passing true (fail from Do only possible for DoMoveToPlot at this time)
		end
	end

	if g_bGreatPerson then
		--memory for AI specialization
		if g_eaAction.GPModType1 then
			local memValue = 2 ^ (g_gameTurn / MOD_MEMORY_HALFLIFE)
			if g_eaAction.GPModType1 ~= "EAMOD_LEADERSHIP" then
				local modID = GameInfoTypes[g_eaAction.GPModType1]
				g_eaPerson.modMemory[modID] = (g_eaPerson.modMemory[modID] or 0) + memValue
			end
			if g_eaAction.GPModType2 and g_eaAction.GPModType2 ~= "EAMOD_LEADERSHIP" then
				local modID = GameInfoTypes[g_eaAction.GPModType2]
				g_eaPerson.modMemory[modID] = (g_eaPerson.modMemory[modID] or 0) + memValue
			end
		end
		--invisibility
		if g_eaAction.StayInvisible then
			g_unit:SetInvisibleType(INVISIBLE_SUBMARINE)
		else 
			g_unit:SetInvisibleType(-1)
		end	
	end

	--effects on unit
	if g_eaAction.DoXP > 0 then
		g_unit:ChangeExperience(g_eaAction.DoXP)
	end
	if g_eaAction.DoGainPromotion then
		g_unit:SetHasPromotion(GameInfoTypes[g_eaAction.DoGainPromotion], true)
	end

	--Finish moves
	if g_eaAction.FinishMoves and g_unit then
		g_unit:FinishMoves()

		--Don't get stuck on unit with no moves
		if g_iPlayer == g_iActivePlayer then
			if UI.GetHeadSelectedUnit() and UI.GetHeadSelectedUnit():MovesLeft() == 0 then
				print("EaAction.lua forcing unit cycle")
				Game.CycleUnits(true, true, false)	--move on to next unit
			end
		end
	end

	--Ongoing actions with turnsToComplete > 0 (DoEaSpell is called each turn of construction)
	local turnsToComplete = g_eaAction.TurnsToComplete
	
	--Reserve this action at this plot (will cause TestEaSpellTarget fail for other GPs)
	if 1 < turnsToComplete and not g_eaAction.NoGPNumLimit then
		--g_eaPlayer.actionPlotTargeted[eaActionID] = g_eaPlayer.actionPlotTargeted[eaActionID] or {}
		--g_eaPlayer.actionPlotTargeted[eaActionID][g_iPlot] = g_iPerson
		gg_playerPlotActionTargeted[g_iPlayer][g_iPlot] = gg_playerPlotActionTargeted[g_iPlayer][g_iPlot] or {}
		gg_playerPlotActionTargeted[g_iPlayer][g_iPlot][eaActionID] = g_iPerson
	end

	if turnsToComplete == 1000 and g_bAIControl then turnsToComplete = 8 end	--AI will wake up and test other options
	if turnsToComplete == 1 then	--do it now!

		--Plot Float Up Text
		if not g_eaAction.NoFloatUpText or MapModData.bAutoplay then
			g_plot:AddFloatUpMessage(Locale.Lookup(g_eaAction.Description), 2)
		end

		if 0 < g_eaAction.FixedFaith then
			UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_eaAction.FixedFaith, false)
		end

		if g_eaAction.UniqueType then							--make NOT available permanently for any GP
			if g_eaAction.UniqueType == "World" then
				gWorldUniqueAction[eaActionID] = -1
			elseif g_eaAction.UniqueType == "National" then
				g_eaPlayer.nationalUniqueAction[eaActionID] = -1
			end
		end
		if g_bGreatPerson then
			ClearActionPlotTargetedForPerson(g_iPlayer, g_iPerson)
		end
		SpecialEffects()

	elseif turnsToComplete == 1000 then		--keep doing without progress update (but will abort if test function fails on any turn)
		g_eaPerson.eaActionID = eaActionID
	else
		g_eaPerson.eaActionID = eaActionID	--this will cause person to keep calling this action each turn (AI at turn begin; human at turn end)

		--Make NOT available for other GPs
		local uniqueType = g_eaAction.UniqueType
		if uniqueType then							
			if uniqueType == "World" then
				gWorldUniqueAction[eaActionID] = iPerson
			elseif uniqueType == "National" then
				g_eaPlayer.nationalUniqueAction[eaActionID] = iPerson
			end
		end

		--Update progress
		local progressHolder = g_eaAction.ProgressHolder
		if progressHolder == "Plot" then
			local buildID = GameInfoTypes[g_eaAction.BuildType]
			local progress = g_plot:GetBuildProgress(buildID)
			if progress >= turnsToComplete - 1 then
				return FinishEaSpell(eaActionID)
			else
				g_plot:ChangeBuildProgress(buildID, 1, g_iTeam)
			end
		else
			local progressTable
			if progressHolder == "Person" then
				progressTable = g_eaPerson.progress
				print("getting progressTable from person ", progressTable, g_eaAction.Type)
			elseif progressHolder == "City" then
				progressTable = g_eaCity.progress
				print("getting progressTable from city ", progressTable, g_eaAction.Type)
			elseif progressHolder == "CityCiv" then
				if g_eaCity.civProgress[g_iPlayer] then
					progressTable = g_eaCity.civProgress[g_iPlayer]
				else
					progressTable = {}
					g_eaCity.civProgress[g_iPlayer] = progressTable	--this will never be deleted but that's OK
				end
				print("getting progressTable from CityCiv ", progressTable, g_eaAction.Type)
			end
			local progress = progressTable[eaActionID] or 0
			progress = progress + 1
			print("progress, turnsToComplete = ", progress, turnsToComplete)
			if progress >= turnsToComplete then
				progressTable[eaActionID] = nil
				return FinishEaSpell(eaActionID)
			else
				progressTable[eaActionID] = progress
			end
		end

	end

	if g_eaPerson.timeStop and g_unit then
		CheckTimeStopUnit(g_unit, g_eaPerson)
	end

	print("Reached end of DoEaSpell, returning true")
	return true
end

function InterruptEaSpell(iPlayer, iPerson)
	--Called from DoEaSpell if there is a direct call to DoEaSpell that returns false,
	--or for a previous (presumably in progress) eaActionID if a new DoEaSpell is called with a different eaActionID 
	--May also be called directly for some reasons (e.g., a GP has been killed but has an eaActionID that we want to cancel)
	--WARNING! DO NOT USE FILE-LEVEL LOCALS FOR INTERRUPT FUNCTIONS! (Can be called externally or with "previous" eaActionID)
	--Does not reappear GP immediately (do that elsewhere if needed)
	print("InterruptEaSpell", iPlayer, iPerson)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local eaPerson = gPeople[iPerson]
	local eaActionID = eaPerson.eaActionID

	eaPerson.gotoPlotIndex = -1
	eaPerson.gotoEaActionID = -1
	ClearActionPlotTargetedForPerson(iPlayer, iPerson)
	if eaActionID == -1 then return end

	eaPerson.eaActionID = -1

	local eaAction = EaActionsInfo[eaActionID]

	if eaAction.UniqueType then							--make available for other GPs
		if eaAction.UniqueType == "World" then
			gWorldUniqueAction[eaActionID] = nil
		elseif eaAction.UniqueType == "National" then
			eaPlayer.nationalUniqueAction[eaActionID] = nil
		end
	end

	eaPlayer.aiUniqueTargeted[eaActionID] = nil

	if Interrupt[eaActionID] then Interrupt[eaActionID](iPlayer, iPerson) end	

	--Make invisible again
	local unit = player:GetUnitByID(eaPerson.iUnit)
	if unit and not unit:IsDelayedDeath() then						--Could be interrupt for death, so no unit
		unit:SetInvisibleType(INVISIBLE_SUBMARINE)
	end

	print("end of InterruptEaSpell")								
end

function TestSpellLearnable(iPlayer, iPerson, spellID, spellClass, bSuppressMinimumModToLearn)		--iPerson = nil to generate civ list; spellClass is optional restriction (used for separate UI panels)
	
	if not SetAIValues[spellID] then return false end	--Not really added yet, even if in table

	--MinimumModToLearn

	local spellInfo = EaActionsInfo[spellID]
	if spellClass and spellClass ~= spellInfo.SpellClass and spellInfo.SpellClass ~= "Both" then return false end
	--order exclusions by most common first for speed
	if iPerson then
		local eaPerson = gPeople[iPerson]
		if spellInfo.SpellClass == "Arcane" then
			if eaPerson.class1 ~= "Thaumaturge" and eaPerson.class2 ~= "Thaumaturge" then return false end
		elseif spellInfo.SpellClass == "Divine" then
			if eaPerson.class1 ~= "Devout" and eaPerson.class2 ~= "Devout" then return false end
		end
		if spellInfo.PantheismCult then return false end		--these are never chosen
		local spells = eaPerson.spells
		for i = 1, #spells do
			if spells[i] == spellID then return false end		--already known
		end
	end
	local eaPlayer = gPlayers[iPlayer]
	if eaPlayer.bIsFallen then
		if spellInfo.FallenAltSpell and spellInfo.FallenAltSpell ~= "IsFallen" then return false end
	else
		if spellInfo.FallenAltSpell == "IsFallen" then return false end
	end
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if spellInfo.TechReq then
		if not (spellInfo.PolicyTrumpsTechReq and player:HasPolicy(GameInfoTypes[spellInfo.PolicyTrumpsTechReq])) then
			if not team:IsHasTech(GameInfoTypes[spellInfo.TechReq]) then
				if not spellInfo.OrTechReq or not team:IsHasTech(GameInfoTypes[spellInfo.OrTechReq]) then return false end
			end
			if spellInfo.AndTechReq and not team:IsHasTech(GameInfoTypes[spellInfo.AndTechReq]) then return false end
		end
	end
	--TO DO: class and subclass checks (not used often but may happen)

	if spellInfo.PantheismCult and not player:HasPolicy(GameInfoTypes.POLICY_PANTHEISM) then return end		--show cult spell only if Pantheistic
	if spellInfo.ReligionNotFounded and gReligions[GameInfoTypes[spellInfo.ReligionNotFounded] ] then return false end
	if spellInfo.ReligionFounded and not gReligions[GameInfoTypes[spellInfo.ReligionFounded] ] then return false end
	if spellInfo.MaleficiumLearnedByAnyone and gWorld.maleficium ~= "Learned" then return false end
	if spellInfo.ExcludeFallen and eaPlayer.bIsFallen then return false end
	if spellInfo.CivReligion and eaPlayer.religionID ~= GameInfoTypes[spellInfo.CivReligion] then return false end
	if spellInfo.PolicyReq and not player:HasPolicy(GameInfoTypes[spellInfo.PolicyReq]) then return false end
	if spellInfo.TechDisallow and team:IsHasTech(GameInfoTypes[spellInfo.TechDisallow]) then return false end
	if iPerson and (spellInfo.LevelReq or spellInfo.PromotionReq) then
		local eaPerson = gPeople[iPerson]
		local unit = player:GetUnitByID(eaPerson.iUnit)
		if spellInfo.LevelReq and unit:GetLevel() < spellInfo.LevelReq then return false end
		if spellInfo.PromotionReq and not unit:IsHasPromotion(GameInfoTypes[spellInfo.PromotionReq]) then return false end
	end
	if spellInfo.ReqEaWonder and not gWonders[GameInfoTypes[spellInfo.ReqEaWonder] ] then return false end
	return true, spellLevel[spellID], spellInfo.GPModType1, spellInfo.GPModType2
end


------------------------------------------------------------------------------------------------------------------------------
-- Spells go here...!
------------------------------------------------------------------------------------------------------------------------------
--Note: spells skip over generic civ and caster prereqs; Test function is rarely used
--Use TestTarget, SetUI, SetAIValues, Do (for 1 turn completion) and Finish (for >1 turn completion)

----------------------------------------------------------------------------
-- Summon-type spells
----------------------------------------------------------------------------

local EA_SPELL_CONJURE_MONSTER =			GameInfoTypes.EA_SPELL_CONJURE_MONSTER
local EA_SPELL_REANIMATE_DEAD =				GameInfoTypes.EA_SPELL_REANIMATE_DEAD
local EA_SPELL_RAISE_DEAD =					GameInfoTypes.EA_SPELL_RAISE_DEAD
local EA_SPELL_SUMMON_ABYSSAL_CREATURES =	GameInfoTypes.EA_SPELL_SUMMON_ABYSSAL_CREATURES
local EA_SPELL_SUMMON_DEMON =				GameInfoTypes.EA_SPELL_SUMMON_DEMON
local EA_SPELL_SUMMON_ARCHDEMON =			GameInfoTypes.EA_SPELL_SUMMON_ARCHDEMON
local EA_SPELL_CALL_HEAVENS_GUARD =			GameInfoTypes.EA_SPELL_CALL_HEAVENS_GUARD
local EA_SPELL_CALL_ANGEL =					GameInfoTypes.EA_SPELL_CALL_ANGEL
local EA_SPELL_CALL_ARCHANGEL =				GameInfoTypes.EA_SPELL_CALL_ARCHANGEL
local EA_SPELL_CALL_ANIMALS =				GameInfoTypes.EA_SPELL_CALL_ANIMALS
local EA_SPELL_CALL_TREE_ENT =				GameInfoTypes.EA_SPELL_CALL_TREE_ENT
local EA_SPELL_CALL_MAJOR_SPIRIT =			GameInfoTypes.EA_SPELL_CALL_MAJOR_SPIRIT

local monsters = {GameInfoTypes.UNIT_GIANT_SPIDER, GameInfoTypes.UNIT_DRAKE_GREEN, GameInfoTypes.UNIT_DRAKE_BLUE, GameInfoTypes.UNIT_DRAKE_RED}	--weakest to strongest
local undead = {GameInfoTypes.UNIT_SKELETON_SWORDSMEN, GameInfoTypes.UNIT_ZOMBIES}
local abyssalCreatures = {GameInfoTypes.UNIT_HORMAGAUNT}
local demons = {GameInfoTypes.UNIT_DEMON_I, GameInfoTypes.UNIT_UNIT_DEMON_II}
local heavensGuard = {GameInfoTypes.UNIT_ANGEL_SPEARMAN}
local angels = {GameInfoTypes.UNIT_ANGEL}
local animals = {GameInfoTypes.UNIT_WOLVES, GameInfoTypes.UNIT_LIONS}
local treeEnts = {GameInfoTypes.UNIT_TREE_ENT}
--Remember to update numTableUnits below!

local function ModelSummon_TestTarget()
	print("ModelSummon_TestTarget")
	local unitTable, numTableUnits
	local bLimitOneOnly, bUnboundToCaster = false, false
	local archType = false
	if g_eaActionID == EA_SPELL_CONJURE_MONSTER then
		unitTable = monsters
		numTableUnits = 4
		bLimitOneOnly = true
	elseif g_eaActionID == EA_SPELL_REANIMATE_DEAD then
		unitTable = undead
		numTableUnits = 2
		bUnboundToCaster = true
	elseif g_eaActionID == EA_SPELL_RAISE_DEAD then
		unitTable = undead
		numTableUnits = 2
	elseif g_eaActionID == EA_SPELL_SUMMON_ABYSSAL_CREATURES then
		unitTable = abyssalCreatures
		numTableUnits = 1
	elseif g_eaActionID == EA_SPELL_SUMMON_DEMON then
		unitTable = demons
		numTableUnits = 2
		bLimitOneOnly = true
	elseif g_eaActionID == EA_SPELL_CALL_HEAVENS_GUARD then
		unitTable = heavensGuard
		numTableUnits = 1
	elseif g_eaActionID == EA_SPELL_CALL_ANGEL then
		unitTable = angels
		numTableUnits = 1
		bLimitOneOnly = true
	elseif g_eaActionID == EA_SPELL_CALL_ANIMALS then
		unitTable = animals
		numTableUnits = 2
	elseif g_eaActionID == EA_SPELL_CALL_TREE_ENT then
		local featureID = g_plot:GetFeatureType()
		if (featureID ~= FEATURE_FOREST and featureID ~= FEATURE_FOREST) or g_plot:GetLivingTerrainStrength() < 18 then
			g_testTargetSwitch = 20
			return false
		end
		unitTable = treeEnts
		bLimitOneOnly = true
		numTableUnits = 1
	elseif g_eaActionID == EA_SPELL_SUMMON_ARCHDEMON or g_eaActionID == EA_SPELL_CALL_ARCHANGEL or g_eaActionID == EA_SPELL_CALL_MAJOR_SPIRIT then
		archType = true
	end

	if archType then
		g_value = gg_baseUnitPower[g_int1]		--g_int1 was set to unitTypeID in specific Test function below
		print("archtype id, power = ", g_int1, g_value)
		if g_faith < g_value then
			g_testTargetSwitch = 5
			return false
		end
		g_obj1 = GetPlotForSpawn(g_plot, g_iPlayer, 1, false, false, false, false, true, false)
		if g_obj1 then
			return true
		else
			g_testTargetSwitch = 6
			return false
		end

	else
		--make our unit list here so we can share it with UI and AI
		g_count = 0		--number units can summon
		g_value = 0		--cumulative power of newly summoned units
		local remainingMod = g_modSpellTimesTurns
		local summonedUnits = not bUnboundToCaster and g_eaPerson.summonedUnits
		local bHasSummonedUnit = false
		if summonedUnits then
			for iUnit, unitTypeID in pairs(summonedUnits) do
				for i = 1, numTableUnits do
					if unitTypeID == unitTable[i] then
						if bLimitOneOnly then
							g_testTargetSwitch = 2
							return false
						end
						bHasSummonedUnit = true		--if can't now, it's because there are already summoned units
						remainingMod = remainingMod - gg_baseUnitPower[unitTypeID]
					end
				end
			end
		end
		local weakestUnitPower = gg_baseUnitPower[unitTable[1] ]
		print("weakest unit, weakestUnitPower = ", unitTable[1], weakestUnitPower)
		local i = numTableUnits		--start at strongest unit and work through backwards
		while weakestUnitPower < remainingMod do
			local unitTypeID = unitTable[i]
			local power = gg_baseUnitPower[unitTypeID]
			if power < remainingMod then	--add to list
				g_count = g_count + 1
				g_integers[g_count] = unitTypeID
				g_value = g_value + power
				if bLimitOneOnly then break end
				remainingMod = remainingMod - power
			end
			i = i < 2 and i + numTableUnits - 1 or i - 1
		end
		if g_count == 0 then
			if bHasSummonedUnit then
				g_testTargetSwitch = 3
				return false
			else
				g_testTargetSwitch = 4
				g_int2 = weakestUnitPower
				return false
			end
		end

		g_obj1 = GetPlotForSpawn(g_plot, g_iPlayer, 1, false, false, false, false, true, false)
		if g_obj1 then
			return true
		else
			g_testTargetSwitch = 6
			return false
		end
	end
end

local function ModelSummon_SetUI()
	if g_bNonTargetTestsPassed then
		--text for different spells

		if g_eaActionID == EA_SPELL_SUMMON_ARCHDEMON then
			if g_bAllTestsPassed then
				local name = Locale.Lookup(GameInfo.Units[g_int1].Description)
				MapModData.text = "Summon " .. name
			else
				if g_testTargetSwitch == 5 then
					local name = Locale.Lookup(GameInfo.Units[g_int1].Description)
					MapModData.text = "[COLOR_WARNING_TEXT]You need " .. g_value .. " mana to summon " .. name .. "[ENDCOLOR]"
				elseif g_testTargetSwitch == 6 then
					MapModData.text = "[COLOR_WARNING_TEXT]You cannont summon onto current or adjacent plots[ENDCOLOR]"
				elseif g_testTargetSwitch == 10 then
					local currentName = Locale.Lookup(GameInfo.Units[gg_summonedArchdemon[g_iPlayer] ].Description)
					MapModData.text = "[COLOR_WARNING_TEXT]You cannot summon another archdemon while " .. currentName .. " walks this world[ENDCOLOR]"
				elseif g_testTargetSwitch == 11 then
					MapModData.text = "[COLOR_WARNING_TEXT]All eight archdemons have been summoned; isn't it time to wrap this up...?[ENDCOLOR]"
				end
			end
			return
		elseif g_eaActionID == EA_SPELL_CALL_ARCHANGEL then
			if g_bAllTestsPassed then
				local name = Locale.Lookup(GameInfo.Units[g_int1].Description)
				MapModData.text = "Call " .. name
			else
				if g_testTargetSwitch == 5 then
					local name = Locale.Lookup(GameInfo.Units[g_int1].Description)
					MapModData.text = "[COLOR_WARNING_TEXT]You need " .. g_value .. " mana to call " .. name .. "[ENDCOLOR]"
				elseif g_testTargetSwitch == 6 then
					MapModData.text = "[COLOR_WARNING_TEXT]You cannont call onto current or adjacent plots[ENDCOLOR]"
				elseif g_testTargetSwitch == 10 then
					local currentName = Locale.Lookup(GameInfo.Units[gg_calledArchangel[g_iPlayer] ].Description)
					MapModData.text = "[COLOR_WARNING_TEXT]You cannot call another archangel while " .. currentName .. " walks this world[ENDCOLOR]"
				elseif g_testTargetSwitch == 11 then
					MapModData.text = "[COLOR_WARNING_TEXT]All twelve archangels have been summoned...[ENDCOLOR]"
				end
			end
			return
		elseif g_eaActionID == EA_SPELL_CALL_MAJOR_SPIRIT then
			if g_bAllTestsPassed then
				local name = Locale.Lookup(GameInfo.Units[g_int1].Description)
				MapModData.text = "Call " .. name
			else
				if g_testTargetSwitch == 5 then
					local name = Locale.Lookup(GameInfo.Units[g_int1].Description)
					MapModData.text = "[COLOR_WARNING_TEXT]You need " .. g_value .. " mana to call " .. name .. "[ENDCOLOR]"
				elseif g_testTargetSwitch == 6 then
					MapModData.text = "[COLOR_WARNING_TEXT]You cannont call onto current or adjacent plots[ENDCOLOR]"
				elseif g_testTargetSwitch == 10 then
					local currentName = Locale.Lookup(GameInfo.Units[gg_calledMajorSpirit[g_iPlayer] ].Description)
					MapModData.text = "[COLOR_WARNING_TEXT]You cannot call another major spirit while " .. currentName .. " walks this world[ENDCOLOR]"
				elseif g_testTargetSwitch == 11 then
					MapModData.text = "[COLOR_WARNING_TEXT]You must be allied and have friendship of 500 with a major spirit that has not been called[ENDCOLOR]"
				end
			end
			return
		end

		--all the rest
		local verb, verbCap, unitStr, unitPlurStr				-- apologies to who ever tries to localize this... 
		if g_eaActionID == EA_SPELL_CONJURE_MONSTER then
			verb, verbCap, unitStr, unitPlurStr = "conjure", "Conjure", "monster", "monsters"
		elseif g_eaActionID == EA_SPELL_REANIMATE_DEAD then
			verb, verbCap, unitStr, unitPlurStr = "reanimate", "Reanimate", "dead", "dead"
		elseif g_eaActionID == EA_SPELL_RAISE_DEAD then
			verb, verbCap, unitStr, unitPlurStr = "raise", "Raise", "dead", "dead"
		elseif g_eaActionID == EA_SPELL_SUMMON_ABYSSAL_CREATURES then
			verb, verbCap, unitStr, unitPlurStr = "summon", "Summon", "Abyssal Creatures", "Abyssal Creatures"
		elseif g_eaActionID == EA_SPELL_SUMMON_DEMON then
			verb, verbCap, unitStr, unitPlurStr = "summon", "Summon", "Demon", "Demons"
		elseif g_eaActionID == EA_SPELL_CALL_HEAVENS_GUARD then
			verb, verbCap, unitStr, unitPlurStr = "call", "Call", "Heaven's Guard", "Heaven's Guard"
		elseif g_eaActionID == EA_SPELL_CALL_ANGEL then
			verb, verbCap, unitStr, unitPlurStr = "call", "Call", "Angel", "Angels"
		elseif g_eaActionID == EA_SPELL_CALL_ANIMALS then
			verb, verbCap, unitStr, unitPlurStr = "call", "Call", "animals", "animals"
		elseif g_eaActionID == EA_SPELL_CALL_TREE_ENT then
			verb, verbCap, unitStr, unitPlurStr = "call", "Call", "Tree-Ent", "Tree-Ents"
		end

		if g_bAllTestsPassed then
			local unitCounts = {}	--index by unitTypeID
			for i = 1, g_count do
				local unitTypeID = g_integers[i]
				unitCounts[unitTypeID] = (unitCounts[unitTypeID] or 0) + 1
			end
			local str
			for unitTypeID, number in pairs(unitCounts) do
				str = str and "; " or ""
				local name = Locale.Lookup(GameInfo.Units[unitTypeID].Description)	--TO DO: plural cases
				str = str .. unitCounts[unitTypeID] .. " " .. name
			end
			if g_eaActionID == EA_SPELL_CALL_TREE_ENT then
				local featureStr = g_plot:GetFeatureType() == FEATURE_FOREST and "Forest" or "Jungle"
				str = str .. "; strength (18) will be taken from " .. featureStr
			end
			MapModData.text = verbCap .. " " .. str
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]You can only " .. verb .. " one unit with this spell[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]Not enough mana to " .. verb .. " additional " .. unitPlurStr .. "[ENDCOLOR]"
		elseif g_testTargetSwitch == 4 then
			MapModData.text = "[COLOR_WARNING_TEXT]Your current spell modifier (" .. g_modSpell .. ") is insufficient to " .. verb .. " any " .. unitPlurStr .. " (need " .. floor(g_int2 * g_modSpell / g_modSpellTimesTurns + 0.9999) .. ")[ENDCOLOR]"
		elseif g_testTargetSwitch == 6 then
			MapModData.text = "[COLOR_WARNING_TEXT]You cannont " .. verb .. " onto current or adjacent plots[ENDCOLOR]"
		elseif g_testTargetSwitch == 20 then
			MapModData.text = "[COLOR_WARNING_TEXT]Tree-Ent can be called only from Forest or Jungle with strength equal to or greater than 18[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]REPORT AS BUG[ENDCOLOR]"
		end
	end
end

local function ModelSummon_SetAIValues()
	gg_aiOptionValues.i = g_value		--AI should always want this maxed out
end

local function ModelSummon_Finish()
	print("ModelSummon_Finish")
	local bUnboundToCaster = false
	if g_eaActionID == EA_SPELL_REANIMATE_DEAD then
		bUnboundToCaster = true
	elseif g_eaActionID == EA_SPELL_SUMMON_ARCHDEMON then
		gWorld.archdemonID = g_int1
		gg_summonedArchdemon[g_iPlayer] = g_int1
		g_count = 1
		g_integers[1] = g_int1		--ugly; just stuffing unit here so I can use generic summon code below
	elseif g_eaActionID == EA_SPELL_CALL_ARCHANGEL then
		gWorld.archangelID = g_int1
		gg_calledArchangel[g_iPlayer] = g_int1
		g_count = 1
		g_integers[1] = g_int1	
	elseif g_eaActionID == EA_SPELL_CALL_MAJOR_SPIRIT then
		gWorld.calledMajorSpirits[g_int1] = true
		gg_calledMajorSpirit[g_iPlayer] = g_int1
		g_count = 1
		g_integers[1] = g_int1	
	elseif g_eaActionID == EA_SPELL_CALL_TREE_ENT then
		g_plot:SetLivingTerrainStrength(g_plot:GetLivingTerrainStrength() - 18)
	end

	g_eaPerson.summonedUnits = g_eaPerson.summonedUnits or {}
	local summonedUnits = g_eaPerson.summonedUnits

	for i = 1, g_count do
		local summonPlot = (i == 1) and g_obj1 or GetPlotForSpawn(g_plot, g_iPlayer, 2, false, false, false, false, false, false)
		if summonPlot then
			local unitTypeID = g_integers[i]
			local x, y = summonPlot:GetXY()
			local newUnit = g_player:InitUnit(unitTypeID, x, y)
			local iUnit = newUnit:GetID()
			if bUnboundToCaster then
				newUnit:SetSummonerIndex(-99)
			else
				summonedUnits[iUnit] = unitTypeID
				newUnit:SetSummonerIndex(g_iPerson)
			end
		end
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_value, false)
	return true
end

--EA_SPELL_CONJURE_MONSTER
TestTarget[GameInfoTypes.EA_SPELL_CONJURE_MONSTER] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_CONJURE_MONSTER] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_CONJURE_MONSTER] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_CONJURE_MONSTER] = ModelSummon_Finish

--EA_SPELL_REANIMATE_DEAD
TestTarget[GameInfoTypes.EA_SPELL_REANIMATE_DEAD] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_REANIMATE_DEAD] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_REANIMATE_DEAD] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_REANIMATE_DEAD] = ModelSummon_Finish

--EA_SPELL_RAISE_DEAD
TestTarget[GameInfoTypes.EA_SPELL_RAISE_DEAD] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_RAISE_DEAD] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_RAISE_DEAD] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_RAISE_DEAD] = ModelSummon_Finish

--EA_SPELL_SUMMON_ABYSSAL_CREATURES
TestTarget[GameInfoTypes.EA_SPELL_SUMMON_ABYSSAL_CREATURES] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_SUMMON_ABYSSAL_CREATURES] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_SUMMON_ABYSSAL_CREATURES] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_SUMMON_ABYSSAL_CREATURES] = ModelSummon_Finish

--EA_SPELL_SUMMON_DEMON
TestTarget[GameInfoTypes.EA_SPELL_SUMMON_DEMON] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_SUMMON_DEMON] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_SUMMON_DEMON] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_SUMMON_DEMON] = ModelSummon_Finish

--EA_SPELL_CALL_HEAVENS_GUARD
TestTarget[GameInfoTypes.EA_SPELL_CALL_HEAVENS_GUARD] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_CALL_HEAVENS_GUARD] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_CALL_HEAVENS_GUARD] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_CALL_HEAVENS_GUARD] = ModelSummon_Finish

--EA_SPELL_CALL_ANGEL
TestTarget[GameInfoTypes.EA_SPELL_CALL_ANGEL] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_CALL_ANGEL] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_CALL_ANGEL] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_CALL_ANGEL] = ModelSummon_Finish

--EA_SPELL_CALL_ANIMALS
TestTarget[GameInfoTypes.EA_SPELL_CALL_ANIMALS] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_CALL_ANIMALS] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_CALL_ANIMALS] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_CALL_ANIMALS] = ModelSummon_Finish

--EA_SPELL_CALL_TREE_ENT
TestTarget[GameInfoTypes.EA_SPELL_CALL_TREE_ENT] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_CALL_TREE_ENT] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_CALL_TREE_ENT] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_CALL_TREE_ENT] = ModelSummon_Finish

--EA_SPELL_SUMMON_ARCHDEMON
Test[GameInfoTypes.EA_SPELL_SUMMON_ARCHDEMON] = function()
	print("Test[GameInfoTypes.EA_SPELL_SUMMON_ARCHDEMON]")
	if gg_summonedArchdemon[g_iPlayer] then
		g_testTargetSwitch = 10						--player can have only 1 at a time
		return false
	end
	if gWorld.archdemonID then
		if gWorld.archdemonID < firstArchdemonID + 7 then
			g_int1 = gWorld.archdemonID + 1
		else
			g_testTargetSwitch = 11						--all 8 have been summoned
			return false
		end
	else
		g_int1 = firstArchdemonID
	end
	print("-g_int1 = ", g_int1, GameInfo.Units[g_int1].Type)
	return true
end
TestTarget[GameInfoTypes.EA_SPELL_SUMMON_ARCHDEMON] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_SUMMON_ARCHDEMON] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_SUMMON_ARCHDEMON] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_SUMMON_ARCHDEMON] = ModelSummon_Finish

--EA_SPELL_CALL_ARCHANGEL
Test[GameInfoTypes.EA_SPELL_CALL_ARCHANGEL] = function()
	print("Test[GameInfoTypes.EA_SPELL_CALL_ARCHANGEL]")
	if gg_calledArchangel[g_iPlayer] then
		g_testTargetSwitch = 10						--player can have only 1 at a time
		return false
	end
	if gWorld.archangelID then
		if gWorld.archangelID < firstArchangelID + 11 then
			g_int1 = gWorld.archangelID + 1
		else
			g_testTargetSwitch = 11						--all 12 have been summoned
			return false
		end
	else
		g_int1 = firstArchangelID
	end
	print("-g_int1 = ", g_int1, GameInfo.Units[g_int1].Type)
	return true
end
TestTarget[GameInfoTypes.EA_SPELL_CALL_ARCHANGEL] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_CALL_ARCHANGEL] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_CALL_ARCHANGEL] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_CALL_ARCHANGEL] = ModelSummon_Finish

--EA_SPELL_CALL_MAJOR_SPIRIT
Test[GameInfoTypes.EA_SPELL_CALL_MAJOR_SPIRIT] = function()
	print("Test[GameInfoTypes.EA_SPELL_CALL_MAJOR_SPIRIT]")
	if gg_calledMajorSpirit[g_iPlayer] then
		g_testTargetSwitch = 10						--player can have only 1 at a time
		return false
	end
	--must have 500 relationship with god; pick best
	local bestGodFriendship = 0
	local bestGodUnitID
	local calledMajorSpirits = gWorld.calledMajorSpirits
	for iGod in pairs(gods) do
		local godUnitID = godUnits[iGod]
		if not calledMajorSpirits[godUnitID] then		--already called?
			local god = Players[iGod]
			if god:GetAlly() == g_iPlayer then
				local friendship = god:GetMinorCivFriendshipWithMajor(g_iPlayer)
				if bestGodFriendship < friendship then
					bestGodFriendship = friendship
					bestGodUnitID = godUnitID
				end
			end
		end
	end
	if bestGodFriendship < 500 then
		g_testTargetSwitch = 11						--there are none that can be called
		return false
	end
	g_int1 = bestGodUnitID
	print("-g_int1 = ", g_int1, GameInfo.Units[g_int1].Type)
	return true
end
TestTarget[GameInfoTypes.EA_SPELL_CALL_MAJOR_SPIRIT] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_CALL_MAJOR_SPIRIT] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_CALL_MAJOR_SPIRIT] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_CALL_MAJOR_SPIRIT] = ModelSummon_Finish

----------------------------------------------------------------------------
-- Ranged attack spells
----------------------------------------------------------------------------
local EA_SPELL_BURNING_HANDS =			GameInfoTypes.EA_SPELL_BURNING_HANDS
local EA_SPELL_MAGIC_MISSILE =			GameInfoTypes.EA_SPELL_MAGIC_MISSILE
local EA_SPELL_FIREBALL =				GameInfoTypes.EA_SPELL_FIREBALL
local EA_SPELL_PLASMA_BOLT =			GameInfoTypes.EA_SPELL_PLASMA_BOLT
local EA_SPELL_PLASMA_STORM =			GameInfoTypes.EA_SPELL_PLASMA_STORM
local EA_SPELL_HAIL_OF_PROJECTILES =	GameInfoTypes.EA_SPELL_HAIL_OF_PROJECTILES
local EA_SPELL_ENERGY_DRAIN =				GameInfoTypes.EA_SPELL_ENERGY_DRAIN
local EA_SPELL_MASS_ENERGY_DRAIN =		GameInfoTypes.EA_SPELL_MASS_ENERGY_DRAIN

local livingUnitOrGP = {}
for unitInfo in GameInfo.Units() do
	if unitInfo.EaLiving then
		livingUnitOrGP[unitInfo.ID] = true
	end
end

local function ModelRanged_TestTarget()	--TO DO: need better AI targeting logic (for now, value goes up with existing damage)
	local range = 2
	local bIndirectFire = false
	local bAutoTargetAll = false
	local bLivingOnly = false
	local bAllowCity = true
	local bValueDamaged = true

	if g_eaActionID == EA_SPELL_BURNING_HANDS then
		range = 1
		bAllowCity = false
	elseif g_eaActionID == EA_SPELL_MAGIC_MISSILE then
		bIndirectFire = true
	elseif g_eaActionID == EA_SPELL_PLASMA_STORM then
		bAutoTargetAll = true
	elseif g_eaActionID == EA_SPELL_HAIL_OF_PROJECTILES then
		bIndirectFire = true
		bAutoTargetAll = true
	elseif g_eaActionID == EA_SPELL_ENERGY_DRAIN then
		bLivingOnly = true
		bAllowCity = false
		bValueDamaged = false
	elseif g_eaActionID == EA_SPELL_MASS_ENERGY_DRAIN then
		range = 3
		bAutoTargetAll = true
		bLivingOnly = true
		bAllowCity = false
		bValueDamaged = false
	end

	print("ModelRanged_TestTarget", g_eaActionID)
	local maxValue, sumValue, count = 0, 0, 0								--Any target makes valid, but AI will value based on current target damage
	for plot in PlotAreaSpiralIterator(g_plot, range, 1, false, false, false) do
		if plot:IsCity() then
			if bAllowCity and (bIndirectFire or g_plot:CanSeePlot(plot, g_iTeam, range, -1)) and g_team:IsAtWar(Players[plot:GetOwner()]:GetTeam()) then
				count = count + 1
				local value = plot:GetPlotCity():GetDamage()
				if bAutoTargetAll then
					sumValue = sumValue + 1
					g_table[count] = plot
				elseif maxValue < value then	
					maxValue = value
					g_obj1 = plot
				end				
			end
		elseif plot:IsVisibleEnemyUnit(g_iPlayer) then
			print("visible enemy unit")
			if bIndirectFire or g_plot:CanSeePlot(plot, g_iTeam, range, -1) then
				local unitCount = plot:GetNumUnits()
				for i = 0, unitCount - 1 do
					local unit = plot:GetUnit(i)
					if not bLivingOnly or livingUnitOrGP[unit:GetUnitType()] then
						if g_team:IsAtWar(Players[unit:GetOwner()]:GetTeam()) then	--combat unit that we are at war with (need to cache at-war players for speed!)
							count = count + 1
							local value = unit:IsCombatUnit() and (bValueDamaged and 100 + unit:GetDamage() or 150) or 1
							if bAutoTargetAll then
								sumValue = sumValue + 1
								g_table[count] = plot
							elseif maxValue < value then	
								maxValue = value
								g_obj1 = plot
							end
						end
					end
				end
			end
		end
	end
	if count == 0 then return false end	--no targets found
	if bAutoTargetAll then
		g_count = count
		g_value = sumValue
	else
		g_value = maxValue
	end

	return true
end

local function ModelRanged_SetUI()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			if g_eaActionID == EA_SPELL_BURNING_HANDS then
				MapModData.text = "Use Burning Hands on adjacent unit with ranged strength " .. g_modSpell
			elseif g_eaActionID == EA_SPELL_MAGIC_MISSILE then
				MapModData.text = "Fire Magic Missiles up to range 2 with strength " .. floor(20 * g_modSpell / 3) / 10
			elseif g_eaActionID == EA_SPELL_FIREBALL then
				MapModData.text = "Shoot Fireball up to range 2 with strength " .. g_modSpell
			elseif g_eaActionID == EA_SPELL_PLASMA_BOLT then
				MapModData.text = "Shoot Plasma Bolt up to range 2 with strength " .. g_modSpell .. "; may stun target for one turn"
			elseif g_eaActionID == EA_SPELL_PLASMA_STORM then
				MapModData.text = "Shoot Plasma Bolts at all hostile targets up to range 2; each has strength " .. g_modSpell .. " and may stun target for one turn"
			elseif g_eaActionID == EA_SPELL_HAIL_OF_PROJECTILES then
				MapModData.text = "Cause a Hail of Projectiles to damage all hostile targets up to range 2; each projectile has strength " .. g_modSpell
			elseif g_eaActionID == EA_SPELL_ENERGY_DRAIN then
				MapModData.text = "Drain life energy from one living unit up to range 2; will drain " .. g_modSpell .. " points first from target experence and then from target hit points, transfering that amount to caster experience"
			elseif g_eaActionID == EA_SPELL_MASS_ENERGY_DRAIN then
				MapModData.text = "Cause Energy Drain for all hostile living units up to range 3; each will drain " .. g_modSpell .. " points first from target experence and then from target hit points, transfering that amount to caster experience"
			end			
		else
			MapModData.text = "[COLOR_WARNING_TEXT]No valid target in range[ENDCOLOR]"
		end
	end
end

local function ModelRanged_SetAIValues()
	gg_aiOptionValues.i = g_value
end

local function ModelRanged_Do()
	print("ModelRanged_Do")
	UpdateGreatPersonStatsFromUnit(g_unit, g_eaPerson)
	local oldUnitTypeID = g_unit:GetUnitType()
	local newUnitTypeID
	local bAutoTargetAll = false
	local modX10 = g_modSpell * 10
	if g_eaActionID == EA_SPELL_BURNING_HANDS then
		newUnitTypeID = gpTempTypeUnits.BurningHands[oldUnitTypeID] or GameInfoTypes.UNIT_WIZARD_BURNING_HANDS
	elseif g_eaActionID == EA_SPELL_MAGIC_MISSILE then
		newUnitTypeID = gpTempTypeUnits.MagicMissle[oldUnitTypeID] or GameInfoTypes.UNIT_WIZARD_MAGIC_MISSLE	--fallback to wizard if we haven't added tempType unit yet
		modX10 = floor(2 * modX10 / 3)
	elseif g_eaActionID == EA_SPELL_FIREBALL then
		newUnitTypeID = gpTempTypeUnits.Fireball[oldUnitTypeID] or GameInfoTypes.UNIT_WIZARD_FIREBALL
	elseif g_eaActionID == EA_SPELL_PLASMA_BOLT then
		newUnitTypeID = gpTempTypeUnits.PlasmaBurst[oldUnitTypeID] or GameInfoTypes.UNIT_WIZARD_PLASMA_BURST
	elseif g_eaActionID == EA_SPELL_PLASMA_STORM then
		newUnitTypeID = gpTempTypeUnits.PlasmaBurst[oldUnitTypeID] or GameInfoTypes.UNIT_WIZARD_PLASMA_BURST
		bAutoTargetAll = true
	elseif g_eaActionID == EA_SPELL_HAIL_OF_PROJECTILES then
		newUnitTypeID = gpTempTypeUnits.Rocket[oldUnitTypeID] or GameInfoTypes.UNIT_WIZARD_MAGIC_MISSLE
		bAutoTargetAll = true
	elseif g_eaActionID == EA_SPELL_ENERGY_DRAIN then
		newUnitTypeID = gpTempTypeUnits.EnergyDrain[oldUnitTypeID] or GameInfoTypes.UNIT_WIZARD_ENERGY_DRAIN
	elseif g_eaActionID == EA_SPELL_MASS_ENERGY_DRAIN then
		newUnitTypeID = gpTempTypeUnits.EnergyDrain[oldUnitTypeID] or GameInfoTypes.UNIT_WIZARD_ENERGY_DRAIN
		bAutoTargetAll = true
	end	

	--init and convert to ranged attack unit
	g_unit = InitGPUnit(g_iPlayer, g_iPerson, g_x, g_y, g_unit, newUnitTypeID, -1, modX10 - 100)

	if bAutoTargetAll then					--same for human and AI; targets already determined in ModelRanged_TestTarget
		g_eaPerson.autoAttack = true

		local indexList = GetRandomizedArrayIndexes(g_count)

		local pos = gg_sequencedAttacks.pos
		for i = 1, g_count do
			local plot = g_table[indexList[i] ]
			gg_sequencedAttacks[pos + i] = {attackingUnit = g_unit, defendingPlot = plot, bRanged = true}
		end
		gg_sequencedAttacks[pos + g_count].bEndAutoAttack = true	--stop the madness!
		gg_sequencedAttacks.pos = pos + g_count
		g_unit:SetMoves(60 * g_count)
		DoSequencedAttacks()

		--TO DO: Sequenced attacks!
		--{attackingUnit, defendingPlot or defendingUnit [use plot unless must be unit], bRanged, bMoveIfNoEnemy, bEndAutoAttack}

		

		if g_unit:MovesLeft() > 0  then
			error("AI GP has movement after magic chained range attack!")
		end
	elseif g_bAIControl then		--Carry out attack
		local x, y = g_obj1:GetXY()
		g_unit:RangeStrike(x, y)
		if g_unit:MovesLeft() > 0  then
			error("AI GP has movement after magic ranged attack! Did it not fire?")
		end
	elseif g_iPlayer == g_iActivePlayer then
		MapModData.forcedUnitSelection = g_unit:GetID()
		MapModData.forcedInterfaceMode = InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK
		UI.SelectUnit(g_unit)
		UI.LookAtSelectionPlot(0)
	end
	return true
end

--EA_SPELL_BURNING_HANDS
TestTarget[GameInfoTypes.EA_SPELL_BURNING_HANDS] = ModelRanged_TestTarget
SetUI[GameInfoTypes.EA_SPELL_BURNING_HANDS] = ModelRanged_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_BURNING_HANDS] = ModelRanged_SetAIValues
Do[GameInfoTypes.EA_SPELL_BURNING_HANDS] = ModelRanged_Do

--EA_SPELL_MAGIC_MISSILE
TestTarget[GameInfoTypes.EA_SPELL_MAGIC_MISSILE] = ModelRanged_TestTarget
SetUI[GameInfoTypes.EA_SPELL_MAGIC_MISSILE] = ModelRanged_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_MAGIC_MISSILE] = ModelRanged_SetAIValues
Do[GameInfoTypes.EA_SPELL_MAGIC_MISSILE] = ModelRanged_Do

--EA_SPELL_FIREBALL
TestTarget[GameInfoTypes.EA_SPELL_FIREBALL] = ModelRanged_TestTarget
SetUI[GameInfoTypes.EA_SPELL_FIREBALL] = ModelRanged_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_FIREBALL] = ModelRanged_SetAIValues
Do[GameInfoTypes.EA_SPELL_FIREBALL] = ModelRanged_Do

--EA_SPELL_PLASMA_BOLT
TestTarget[GameInfoTypes.EA_SPELL_PLASMA_BOLT] = ModelRanged_TestTarget
SetUI[GameInfoTypes.EA_SPELL_PLASMA_BOLT] = ModelRanged_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_PLASMA_BOLT] = ModelRanged_SetAIValues
Do[GameInfoTypes.EA_SPELL_PLASMA_BOLT] = ModelRanged_Do

--EA_SPELL_PLASMA_STORM
TestTarget[GameInfoTypes.EA_SPELL_PLASMA_STORM] = ModelRanged_TestTarget
SetUI[GameInfoTypes.EA_SPELL_PLASMA_STORM] = ModelRanged_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_PLASMA_STORM] = ModelRanged_SetAIValues
Do[GameInfoTypes.EA_SPELL_PLASMA_STORM] = ModelRanged_Do

--EA_SPELL_HAIL_OF_PROJECTILES
TestTarget[GameInfoTypes.EA_SPELL_HAIL_OF_PROJECTILES] = ModelRanged_TestTarget
SetUI[GameInfoTypes.EA_SPELL_HAIL_OF_PROJECTILES] = ModelRanged_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_HAIL_OF_PROJECTILES] = ModelRanged_SetAIValues
Do[GameInfoTypes.EA_SPELL_HAIL_OF_PROJECTILES] = ModelRanged_Do

--EA_SPELL_ENERGY_DRAIN
TestTarget[GameInfoTypes.EA_SPELL_ENERGY_DRAIN] = ModelRanged_TestTarget
SetUI[GameInfoTypes.EA_SPELL_ENERGY_DRAIN] = ModelRanged_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_ENERGY_DRAIN] = ModelRanged_SetAIValues
Do[GameInfoTypes.EA_SPELL_ENERGY_DRAIN] = ModelRanged_Do

--EA_SPELL_MASS_ENERGY_DRAIN
TestTarget[GameInfoTypes.EA_SPELL_MASS_ENERGY_DRAIN] = ModelRanged_TestTarget
SetUI[GameInfoTypes.EA_SPELL_MASS_ENERGY_DRAIN] = ModelRanged_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_MASS_ENERGY_DRAIN] = ModelRanged_SetAIValues
Do[GameInfoTypes.EA_SPELL_MASS_ENERGY_DRAIN] = ModelRanged_Do


----------------------------------------------------------------------------
-- Glyphs, Runes and Wards
----------------------------------------------------------------------------

--EA_SPELL_SEEING_EYE_GLYPH
TestTarget[GameInfoTypes.EA_SPELL_SEEING_EYE_GLYPH] = function()
	g_int1, g_int2, g_int3, g_int4 = g_plot:GetPlotEffectData()	--effectID, effectStength, iEffectPlayer, iCaster
	if g_int1 ~= -1 then
		if g_int3 == g_iPlayer then
			g_testTargetSwitch = 2
			return false			
		end
		--need more logic here for overwriteable effects
		g_testTargetSwitch = 3
		return false
	end
	return true
end

SetUI[GameInfoTypes.EA_SPELL_SEEING_EYE_GLYPH] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Inscribe a Seeing Eye Glyph on this plot (will provide visibility to range " .. floor(g_modSpell / 5) .. ")"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]Your civilization has already placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]Another civilization has placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_SEEING_EYE_GLYPH] = function()
	local range = floor(g_modSpell / 5)
	local addedVisibility = g_plot:IsVisible(g_iTeam) and 0 or 1
	for radius = 1, range do
		for plot in PlotRingIterator(g_plot, radius, 1, false) do
			if not plot:IsVisible(g_iTeam) and (radius == 1 or g_plot:CanSeePlot(plot, g_iTeam, radius, -1)) then
				addedVisibility = addedVisibility + 1
			end
		end
	end
	gg_aiOptionValues.i = addedVisibility / 20
end

Finish[GameInfoTypes.EA_SPELL_SEEING_EYE_GLYPH] = function()
	g_plot:SetPlotEffectData(GameInfoTypes.EA_PLOTEFFECT_SEEING_EYE_GLYPH, g_modSpell, g_iPlayer, g_iPerson)	--effectID, effectStength, iPlayer, iCaster
	if g_iPlayer == g_iActivePlayer then
		UpdatePlotEffectHighlight(g_iPlot, 2)
	else
		UpdatePlotEffectHighlight(g_iPlot)
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_modSpellTimesTurns)
	return true
end

--EA_SPELL_EXPLOSIVE_RUNE
TestTarget[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNE] = function()
	g_int1, g_int2, g_int3, g_int4 = g_plot:GetPlotEffectData()	--effectID, effectStength, iEffectPlayer, iCaster
	if g_int1 ~= -1 then
		if g_int3 == g_iPlayer then
			g_testTargetSwitch = 2
			return false			
		end
		--need more logic here for overwriteable effects
		g_testTargetSwitch = 3
		return false
	end
	return true
end

SetUI[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNE] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Inscribe an Explosive Rune on this plot"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]Your civilization has already placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]Another civilization has placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNE] = function()	--already restricted by AI heuristic to capital 3 radius and other city 1 radius
	gg_aiOptionValues.i = -GetNIMBY(g_iPlayer, g_x, g_y)		--reverse NIMBY: will be in 10 to 30 range in and around my civ
end

Finish[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNE] = function()
	g_plot:SetPlotEffectData(GameInfoTypes.EA_PLOTEFFECT_EXPLOSIVE_RUNE, g_modSpell, g_iPlayer, g_iPerson)	--effectID, effectStength, iPlayer, iCaster
	if g_iPlayer == g_iActivePlayer then
		UpdatePlotEffectHighlight(g_iPlot, 2)
	else
		UpdatePlotEffectHighlight(g_iPlot)
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_modSpellTimesTurns)
	return true
end

--EA_SPELL_DEATH_RUNE
TestTarget[GameInfoTypes.EA_SPELL_DEATH_RUNE] = function()
	g_int1, g_int2, g_int3, g_int4 = g_plot:GetPlotEffectData()	--effectID, effectStength, iEffectPlayer, iCaster
	if g_int1 ~= -1 then
		if g_int3 == g_iPlayer then
			g_testTargetSwitch = 2
			return false			
		end
		--need more logic here for overwriteable effects
		g_testTargetSwitch = 3
		return false
	end
	return true
end

SetUI[GameInfoTypes.EA_SPELL_DEATH_RUNE] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Inscribe a Death Rune on this plot"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]Your civilization has already placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]Another civilization has placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_DEATH_RUNE] = function()		--already restricted by AI heuristic to capital 3 radius and other city 1 radius
	gg_aiOptionValues.i = -GetNIMBY(g_iPlayer, g_x, g_y)		--reverse NIMBY: will be in 10 to 30 range in and around my civ
end

Finish[GameInfoTypes.EA_SPELL_DEATH_RUNE] = function()
	g_plot:SetPlotEffectData(GameInfoTypes.EA_PLOTEFFECT_DEATH_RUNE, g_modSpell, g_iPlayer, g_iPerson)	--effectID, effectStength, iPlayer, iCaster
	if g_iPlayer == g_iActivePlayer then
		UpdatePlotEffectHighlight(g_iPlot, 2)
	else
		UpdatePlotEffectHighlight(g_iPlot)
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_modSpellTimesTurns)
	return true
end

--EA_SPELL_PROTECTIVE_WARD
TestTarget[GameInfoTypes.EA_SPELL_PROTECTIVE_WARD] = function()
	g_int1, g_int2, g_int3, g_int4 = g_plot:GetPlotEffectData()	--effectID, effectStength, iEffectPlayer, iCaster
	if g_int1 ~= -1 then
		if g_int3 == g_iPlayer then
			g_testTargetSwitch = 2
			return false			
		end
		--need more logic here for overwriteable effects
		g_testTargetSwitch = 3
		return false
	end
	return true
end

SetUI[GameInfoTypes.EA_SPELL_PROTECTIVE_WARD] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Inscribe a Protective Ward on this plot"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]Your civilization has already placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]Another civilization has placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_PROTECTIVE_WARD] = function()		--already restricted by AI heuristic to capital 3 radius and other city 1 radius
	gg_aiOptionValues.i = -GetNIMBY(g_iPlayer, g_x, g_y) * g_worldManaDepletion * 10		--as good as explosive when 10% mana depletion			
end

Finish[GameInfoTypes.EA_SPELL_PROTECTIVE_WARD] = function()
	g_plot:SetPlotEffectData(EA_PLOTEFFECT_PROTECTIVE_WARD, g_modSpell, g_iPlayer, g_iPerson)	--effectID, effectStength, iPlayer, iCaster
	if g_iPlayer == g_iActivePlayer then
		UpdatePlotEffectHighlight(g_iPlot, 2)
	else
		UpdatePlotEffectHighlight(g_iPlot)
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_modSpellTimesTurns)
	return true
end

--EA_SPELL_DETECT_GLYPHS_RUNES_WARDS
TestTarget[GameInfoTypes.EA_SPELL_DETECT_GLYPHS_RUNES_WARDS] = function()
	local revealedPlotEffects = g_eaPlayer.revealedPlotEffects
	local numPlots = 0
	local numRevealed = 1
	for plot in PlotAreaSpiralIterator(g_plot, g_modSpell, 1, false, false, true) do
		local iPlot = plot:GetPlotIndex()
		if not revealedPlotEffects[iPlot] then
			local effectID, effectStength, iEffectPlayer, iCaster = plot:GetPlotEffectData()
			if effectID ~= -1 and iEffectPlayer ~= g_iPlayer then
				numRevealed = numRevealed + 1
				g_integers[numRevealed] = iPlot
			end
		end
		numPlots = numPlots + 1
		if g_modSpell < numPlots then break end
	end
	if numPlots == 0 then return false end
	g_count = numRevealed
	return false
end

SetUI[GameInfoTypes.EA_SPELL_DETECT_GLYPHS_RUNES_WARDS] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Reveal nearby Glyphs, Runes or Wards"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]There are no nearby Glyphs, Runes or Wards to reveal[ENDCOLOR]"
		end
	end
end


SetAIValues[GameInfoTypes.EA_SPELL_DETECT_GLYPHS_RUNES_WARDS] = function()
	gg_aiOptionValues.i = g_count		
end

Finish[GameInfoTypes.EA_SPELL_DETECT_GLYPHS_RUNES_WARDS] = function()
	local revealedPlotEffects = g_eaPlayer.revealedPlotEffects
	for i = 1, g_count do
		local iPlot = g_integers[i]
		revealedPlotEffects[iPlot] = true
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_count)
	if g_iPlayer == g_iActivePlayer then
		UpdatePlotEffectHighlight(nil, 1, true)	--puts UI in "show other players's effects" state, forces update
	end
	return true
end

--EA_SPELL_DISPEL_GLYPHS_RUNES_WARDS
TestTarget[GameInfoTypes.EA_SPELL_DISPEL_GLYPHS_RUNES_WARDS] = function()
	if not g_eaPlayer.revealedPlotEffects[g_iPlot] then
		if g_iPlayer == g_iActivePlayer then
			local effectID, effectStength, iEffectPlayer, iCaster = g_plot:GetPlotEffectData()
			if effectID == -1 or iEffectPlayer ~= g_iPlayer then return false end					--human player can Dispel their own
			g_testTargetSwitch = 1
		else
			return false
		end
	end

	--see if there really is one here (otherwise update revealedPlotEffects)
	local effectID, effectStength, iEffectPlayer, iCaster = g_plot:GetPlotEffectData()
	if effectID == -1 or iEffectPlayer == g_iPlayer then		--update revealedPlotEffects (it's wrong) and bail out unless this is human dispelling their own
		g_eaPlayer.revealedPlotEffects[g_iPlot] = nil
		if effectID == -1 or g_iPlayer ~= g_iActivePlayer then return false end
		g_testTargetSwitch = 1
	end

	--are we strong enough to dispel? (must be equal so human caster can dispel their own)
	if g_modSpell < effectStength then
		g_testTargetSwitch = 2
		return false
	end

	--we can do it; load up info for AI valuation
	g_int1 = effectID
	g_int2 = effectStength
	g_int3 = iEffectPlayer
	return true
end

SetUI[GameInfoTypes.EA_SPELL_DISPEL_GLYPHS_RUNES_WARDS] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			local name = Locale.Lookup(GameInfo.EaPlotEffects[g_int1].Description)
			if g_testTargetSwitch == 1 then
				MapModData.text = "Dispel the " .. name .. " at this plot (WARING: This is your own plot effect!)"
			else
				MapModData.text = "Dispel the " .. name .. " at this plot"
			end
		elseif g_testTargetSwitch == 2 then
			local name = Locale.Lookup(GameInfo.EaPlotEffects[g_int1].Description)
			MapModData.text = "[COLOR_WARNING_TEXT]You do not have sufficiently high Abjuration Modifier to Dispel the " .. name .. " at this plot (need " .. g_int2 .. ")[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]There are no revealed Glyphs, Runes or Wards here[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_DISPEL_GLYPHS_RUNES_WARDS] = function()
	-- AI wants to do it if at war with player or (Anra follower and Protective Ward and g_worldManaDepletion kicking in)
	if g_int1 == EA_PLOTEFFECT_PROTECTIVE_WARD then
		if g_eaPlayer.religionID == RELIGION_ANRA then
			gg_aiOptionValues.i = g_worldManaDepletion * GetNIMBY() * 5		--gets us into the range of 25 in foreign lands as depletion goes >0.5
		end
	else
		if g_team:IsAtWar(Players[g_int3]:GetTeam()) then
			gg_aiOptionValues.i = g_int2				--stonger is better since we can dispel; AI will prioritize mostly by proximity
		else
			gg_aiOptionValues.i = 0	
		end
	end
end

Finish[GameInfoTypes.EA_SPELL_DISPEL_GLYPHS_RUNES_WARDS] = function()
	g_plot:SetPlotEffectData(-1, -1, -1, -1)
	g_eaPlayer.revealedPlotEffects[g_iPlot] = nil
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_int2 * 2)
	UpdatePlotEffectHighlight(g_iPlot)
	return true
end

----------------------------------------------------------------------------
-- Banish-type and Turn Undead 
----------------------------------------------------------------------------

--EA_SPELL_BANISH_UNDEAD
TestTarget[GameInfoTypes.EA_SPELL_BANISH] = function()
	--are enemy conjured, summoned or called units in 3-plot range?
	local bCanBanish = false
	local remainingMod = g_modSpellTimesTurns
	g_count = 0
	g_value = 0
	g_int1 = 99999
	local sector = Rand(6, "hello")	+ 1	--won't affect test, but randomizes who if >1
	for plot in PlotAreaSpiralIterator(g_plot, 3, sector, false, false, false) do
		if plot:IsVisibleEnemyUnit(g_iPlayer) then
			local unitCount = plot:GetNumUnits()
			for i = 0, unitCount - 1 do
				local unit = plot:GetUnit(i)
				if unit:GetSummonerIndex() ~= -1 then
					local unitTypeID = unit:GetUnitType()
					if gg_eaSpecial[unitTypeID] ~= "Undead" then
						--have qualified unit; are we strong enough?
						g_testTargetSwitch = 1
						local power = gg_baseUnitPower[unitTypeID] * unit:GetCurrHitPoints() / MAX_UNIT_HP
						if remainingMod >= power then
							bCanBanish = true
							remainingMod = remainingMod - power
							g_value = g_value + power
							g_count = g_count + 1
							g_table[g_count] = unit
						else
							g_int1 = power < g_int1 and power or g_int1 --what we needed if spell fails
						end
					end
				end
			end
		end
	end
	return bCanBanish
end

SetUI[GameInfoTypes.EA_SPELL_BANISH] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Banish one or more nearby conjured, summoned or called units"
		elseif g_testTargetSwitch == 1 then
			local modNeeded = floor(g_int1 * g_modSpell / g_modSpellTimesTurns + 0.5)
			MapModData.text = "[COLOR_WARNING_TEXT]There are conjured, summoned or called units nearby, but you do not have sufficient Abjuration Mod to Banish them (need " .. modNeeded .. ")[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]There are no conjured, summoned or called units nearby[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_BANISH] = function()
	gg_aiOptionValues.i = g_value * 2
end

Finish[GameInfoTypes.EA_SPELL_BANISH] = function()
	for i = 1, g_count do
		local unit = g_table[i]
		local plot = unit:GetPlot()
		MapModData.bBypassOnCanSaveUnit = true
		unit:Kill(true, g_iPlayer)
		plot:AddFloatUpMessage("Banished!", 2)
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_value * 2)
	return true
end

--EA_SPELL_BANISH_UNDEAD
TestTarget[GameInfoTypes.EA_SPELL_BANISH_UNDEAD] = function()
	--are any of these in 3-plot range? Pick first in spiral that we can banish
	local bCanBanish = false
	local remainingMod = g_modSpellTimesTurns
	g_count = 0
	g_value = 0
	g_int1 = 99999
	local sector = Rand(6, "hello")	+ 1	--won't affect test, but randomizes who if >1
	for plot in PlotAreaSpiralIterator(g_plot, 3, sector, false, false, false) do
		if plot:IsVisibleEnemyUnit(g_iPlayer) then
			local unitCount = plot:GetNumUnits()
			for i = 0, unitCount - 1 do
				local unit = plot:GetUnit(i)
				local unitTypeID = unit:GetUnitType()
				if gg_eaSpecial[unitTypeID] == "Undead" then
					--have qualified unit; are we strong enough?
					g_testTargetSwitch = 1
					local power = gg_baseUnitPower[unitTypeID] * unit:GetCurrHitPoints() / MAX_UNIT_HP
					if remainingMod >= power then
						bCanBanish = true
						remainingMod = remainingMod - power
						g_value = g_value + power
						g_count = g_count + 1
						g_table[g_count] = unit
					else
						g_int1 = power < g_int1 and power or g_int1 --what we needed if spell fails
					end
				end
			end
		end
	end
	return bCanBanish
end

SetUI[GameInfoTypes.EA_SPELL_BANISH_UNDEAD] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Banish one or more nearby undead"
		elseif g_testTargetSwitch == 1 then
			local modNeeded = floor(g_int1 * g_modSpell / g_modSpellTimesTurns + 0.5)
			MapModData.text = "[COLOR_WARNING_TEXT]There are undead nearby, but you do not have sufficient Spell Modifier to Banish them (need " .. modNeeded .. ")[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]There are no undead units nearby[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_BANISH_UNDEAD] = function()
	gg_aiOptionValues.i = g_value * 2
end

Finish[GameInfoTypes.EA_SPELL_BANISH_UNDEAD] = function()
	for i = 1, g_count do
		local unit = g_table[i]
		local plot = unit:GetPlot()
		MapModData.bBypassOnCanSaveUnit = true
		unit:Kill(true, g_iPlayer)
		plot:AddFloatUpMessage("Banished!", 2)
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_value * 2)
	return true
end

--EA_SPELL_TURN_UNDEAD
TestTarget[GameInfoTypes.EA_SPELL_TURN_UNDEAD] = function()
	--are any of these in 3-plot range? Pick first in spiral that we can banish
	local bCanTurn = false
	local remainingMod = g_modSpellTimesTurns
	g_count = 0
	g_value = 0
	g_int1 = 99999
	local sector = Rand(6, "hello")	+ 1	--won't affect test, but randomizes who if >1
	for plot in PlotAreaSpiralIterator(g_plot, 3, sector, false, false, false) do
		if plot:IsVisibleEnemyUnit(g_iPlayer) then
			local unitCount = plot:GetNumUnits()
			for i = 0, unitCount - 1 do
				local unit = plot:GetUnit(i)
				local unitTypeID = unit:GetUnitType()
				if gg_eaSpecial[unitTypeID] == "Undead" then
					--have qualified unit; are we strong enough?
					g_testTargetSwitch = 1
					local power = gg_baseUnitPower[unitTypeID] * unit:GetCurrHitPoints() / MAX_UNIT_HP
					if remainingMod >= power then
						bCanTurn = true
						remainingMod = remainingMod - power
						g_value = g_value + power
						g_count = g_count + 1
						g_table[g_count] = unit
					else
						g_int1 = power < g_int1 and power or g_int1 --what we needed if spell fails
					end
				end
			end
		end
	end
	return bCanTurn
end

SetUI[GameInfoTypes.EA_SPELL_TURN_UNDEAD] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Turn one or more nearby undead"
		elseif g_testTargetSwitch == 1 then
			local modNeeded = floor(g_int1 * g_modSpell / g_modSpellTimesTurns + 0.5)
			MapModData.text = "[COLOR_WARNING_TEXT]There are undead nearby, but you do not have sufficient Spell Modifier to Turn them (need " .. modNeeded .. ")[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]There are no undead units nearby[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_TURN_UNDEAD] = function()
	gg_aiOptionValues.i = g_value * 2
end

Finish[GameInfoTypes.EA_SPELL_TURN_UNDEAD] = function()
	for i = 1, g_count do
		local unit = g_table[i]
		local turnPlot = GetPlotForSpawn(unit:GetPlot(), g_iPlayer, 2, false, false, false, false, false, false, unit)
		if turnPlot then
			local x, y = turnPlot:GetXY()
			local unitTypeID = unit:GetUnitType()
			local newUnit = g_player:InitUnit(unitTypeID, x, y)
			newUnit:SetSummonerIndex(-99)
			MapModData.bBypassOnCanSaveUnit = true
			newUnit:Convert(unit, false)
			turnPlot:AddFloatUpMessage("Turned Undead!", 2)
		else
			MapModData.bBypassOnCanSaveUnit = true
			unit:Kill(true, g_iPlayer)
			unit:GetPlot():AddFloatUpMessage("Turned Undead!", 2)
		end
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_value * 2)
	return true
end

--EA_SPELL_BANISH_DEMONS
TestTarget[GameInfoTypes.EA_SPELL_BANISH_DEMONS] = function()
	--are any of these in 3-plot range? Pick first in spiral that we can banish
	local bCanBanish = false
	local remainingMod = g_modSpellTimesTurns
	g_count = 0
	g_value = 0
	g_int1 = 99999
	local sector = Rand(6, "hello")	+ 1	--won't affect test, but randomizes who if >1
	for plot in PlotAreaSpiralIterator(g_plot, 3, sector, false, false, false) do
		if plot:IsVisibleEnemyUnit(g_iPlayer) then
			local unitCount = plot:GetNumUnits()
			for i = 0, unitCount - 1 do
				local unit = plot:GetUnit(i)
				local unitTypeID = unit:GetUnitType()
				if gg_eaSpecial[unitTypeID] == "Demon" or gg_eaSpecial[unitTypeID] == "Archdemon" then
					--have qualified unit; are we strong enough?
					g_testTargetSwitch = 1
					local power = gg_baseUnitPower[unitTypeID] * unit:GetCurrHitPoints() / MAX_UNIT_HP
					if remainingMod >= power then
						bCanBanish = true
						remainingMod = remainingMod - power
						g_value = g_value + power
						g_count = g_count + 1
						g_table[g_count] = unit
					else
						g_int1 = power < g_int1 and power or g_int1 --what we needed if spell fails
					end
				end
			end
		end
	end
	return bCanBanish
end

SetUI[GameInfoTypes.EA_SPELL_BANISH_DEMONS] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Banish one or more nearby demons"
		elseif g_testTargetSwitch == 1 then
			local modNeeded = floor(g_int1 * g_modSpell / g_modSpellTimesTurns + 0.5)
			MapModData.text = "[COLOR_WARNING_TEXT]There are demons nearby, but you do not have sufficient Spell Modifier to Banish them (need " .. modNeeded .. ")[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]There are no demons nearby[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_BANISH_DEMONS] = function()
	gg_aiOptionValues.i = g_value * 2
end

Finish[GameInfoTypes.EA_SPELL_BANISH_DEMONS] = function()
	for i = 1, g_count do
		local unit = g_table[i]
		local plot = unit:GetPlot()
		MapModData.bBypassOnCanSaveUnit = true
		unit:Kill(true, g_iPlayer)
		plot:AddFloatUpMessage("Banished!", 2)
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_value * 2)
	return true
end

--EA_SPELL_BANISH_ANGELS
TestTarget[GameInfoTypes.EA_SPELL_BANISH_ANGELS] = function()
	--are any angels in 3-plot range?
	local bCanBanish = false
	local remainingMod = g_modSpellTimesTurns
	g_count = 0
	g_value = 0
	g_int1 = 99999
	local sector = Rand(6, "hello")	+ 1	--won't affect test, but randomizes who if >1
	for plot in PlotAreaSpiralIterator(g_plot, 3, sector, false, false, false) do
		if plot:IsVisibleEnemyUnit(g_iPlayer) then
			local unitCount = plot:GetNumUnits()
			for i = 0, unitCount - 1 do
				local unit = plot:GetUnit(i)
				local unitTypeID = unit:GetUnitType()
				if gg_eaSpecial[unitTypeID] == "Angel" or gg_eaSpecial[unitTypeID] == "Archangel" then
					--have qualified unit; are we strong enough?
					g_testTargetSwitch = 1
					local power = gg_baseUnitPower[unitTypeID] * unit:GetCurrHitPoints() / MAX_UNIT_HP
					if remainingMod >= power then
						bCanBanish = true
						remainingMod = remainingMod - power
						g_value = g_value + power
						g_count = g_count + 1
						g_table[g_count] = unit
					else
						g_int1 = power < g_int1 and power or g_int1 --what we needed if spell fails
					end
				end
			end
		end
	end
	return bCanBanish
end

SetUI[GameInfoTypes.EA_SPELL_BANISH_ANGELS] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Banish one or more nearby angels"
		elseif g_testTargetSwitch == 1 then
			local modNeeded = floor(g_int1 * g_modSpell / g_modSpellTimesTurns + 0.5)
			MapModData.text = "[COLOR_WARNING_TEXT]There are angels nearby, but you do not have sufficient Spell Modifier to Banish them (need " .. modNeeded .. ")[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]There are no angels nearby[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_BANISH_ANGELS] = function()
	gg_aiOptionValues.i = g_value * 2
end

Finish[GameInfoTypes.EA_SPELL_BANISH_ANGELS] = function()
	for i = 1, g_count do
		local unit = g_table[i]
		local plot = unit:GetPlot()
		MapModData.bBypassOnCanSaveUnit = true
		unit:Kill(true, g_iPlayer)
		plot:AddFloatUpMessage("Banished!", 2)
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_value * 2)
	return true
end

--EA_SPELL_SCRYING
TestTarget[GameInfoTypes.EA_SPELL_SCRYING] = function()
	--pre-select best scry plot and value for AI (AI mostly wants to explore with this spell)
	local maxValue = 0
	for radius = 2, g_modSpell do
		for plot in PlotRingIterator(g_plot, radius, 1, false) do
			if plot:IsRevealed(g_iTeam) then
				local value = 0
				for adjPlot in AdjacentPlotIterator(plot) do
					if not adjPlot:IsRevealed(g_iTeam) then
						value = value + 1					
					elseif not adjPlot:IsVisible(g_iTeam) then
						value = value + 0.1
					end
				end
				if 0 < value then
					if plot:IsWater() then
						value = value * 0.6
					else
						value = value * plot:SeeThroughLevel(false)	--SeeThroughLevel same as SeeFromLevel without recon complication (1 flat; 2 hill; 3 mountain)
					end
					if maxValue < value then
						maxValue = value
						g_obj1 = plot
					end 
				end
			end
		end
	end
	if maxValue == 0 then return false end
	g_value = maxValue
	return true
end

SetUI[GameInfoTypes.EA_SPELL_SCRYING] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			if g_unit:GetReconPlot() then
				MapModData.text = "Create visibility from any revealed plot up to range " .. g_modSpell .. " (will cancel existing Scry)"
			else
				MapModData.text = "Create visibility from any revealed plot up to range " .. g_modSpell
			end
		else
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot extend your current visibility with this spell[ENDCOLOR]"
		end
	end
end

--SetAIValues[GameInfoTypes.EA_SPELL_SCRYING] = function()
--	gg_aiOptionValues.i = g_value
--end

Finish[GameInfoTypes.EA_SPELL_SCRYING] = function()
	--if g_bAIControl then	--do it
		g_unit:SetReconPlot(g_obj1)
		g_unit:FinishMoves()
	--elseif g_iPlayer == g_iActivePlayer then
	--	MapModData.forcedUnitSelection = g_iUnit
	--	MapModData.forcedInterfaceMode = InterfaceModeTypes.INTERFACEMODE_SELECTION
	--	UI.SelectUnit(g_iUnit)
	--	UI.LookAtSelectionPlot(0)
	--end

	return true
end



--EA_SPELL_KNOW_WORLD
--EA_SPELL_DISPEL_HEXES

--EA_SPELL_DISPEL_ILLUSIONS

--EA_SPELL_DISPEL_MAGIC

--EA_SPELL_TIME_STOP
TestTarget[GameInfoTypes.EA_SPELL_TIME_STOP] = function()
	if g_bAIControl then
		if g_x ~= g_unitX or g_y ~= g_unitY then return false end		--it's a combat action but AI should only test self
	end
	if g_eaPerson.timeStop then
		g_testTargetSwitch = 1
		return false
	end
	g_int1 = floor(g_modSpell / 15)
	if g_int1 < 1 then
		g_testTargetSwitch = 2
		return false
	elseif g_faith < g_int1 * 100 then
		g_testTargetSwitch = 3
		return false	
	end
	return true
end

SetUI[GameInfoTypes.EA_SPELL_TIME_STOP] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Stop time for " .. g_int1 .. " turn(s) (will use " .. (g_int1 * 100) .. "mana)"
		elseif g_testTargetSwitch == 1 then
			MapModData.text = "[COLOR_WARNING_TEXT]Time is already stopped![ENDCOLOR]"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]You do not have sufficient Abjuration Modifier to cast this spell (need 15)[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]You do not have sufficient mana to cast this spell (need " .. (g_int1 * 100) .. ")[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_TIME_STOP] = function()
	gg_aiOptionValues.i = g_faith / 1000	--only if AI has mana to burn
end

Do[GameInfoTypes.EA_SPELL_TIME_STOP] = function()
	g_eaPerson.timeStop = g_int1
	if g_iPlayer == g_iActivePlayer then
		gg_bActivePlayerTimeStop = true
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_int1 * 100, false)
	return true
end





--EA_SPELL_MAGE_SWORD

--EA_SPELL_BREACH
TestTarget[GameInfoTypes.EA_SPELL_BREACH] = function()
	--copied from Blight with one major change: this spell either overcomes protection or not (does not weaken)

	--if true, then:
	--g_obj1 = affected plot (this plot or distant plot from tower/temple)
	--g_int2 = terrainStrength
	--g_int3 = radius (tower/temple only)
	--g_int4 = ownPlotsInDanger (tower/temple only)
	--g_int5 = totalPlotsInDanger (tower/temple only)

	if g_bInTowerOrTemple then	--Can distant plot be blighted? (max range = mod)
		local BreachPlot = BreachPlot
		--random sector/direction, spiral in until valid plot found
		local sector = Rand(6, "hello") + 1
		local anticlock = Rand(2, "hello") == 0
		local maxRadius = g_modSpell < MAX_RANGE and g_modSpell or MAX_RANGE
		for radius = maxRadius, 1, -1 do	--test one full ring at a time (we test whole ring so AI can account for own plots in danger)
			g_obj1 = nil
			local ownPlotsInDanger, totalPlotsInDanger = 0, 0
			for plot in PlotRingIterator(g_plot, radius, sector, anticlock) do
				if BreachPlot(plot, g_iPlayer, g_iPerson, g_modSpell, true) then		--tests whether spell mod can overcome protection
					totalPlotsInDanger = totalPlotsInDanger + 1
					if plot:IsPlayerCityRadius(g_iPlayer) then
						ownPlotsInDanger = ownPlotsInDanger + 1
					end	
					g_int2 = 0
					g_obj1 = plot
				end
			end
			if g_obj1 then
				g_int3 = radius
				g_int4 = ownPlotsInDanger
				g_int5 = totalPlotsInDanger
				return true
			end
		end
		return false
	else	--Can THIS plot be Breached?
		if not BreachPlot(g_plot, g_iPlayer, g_iPerson, g_modSpell, true) then return false end	--tests whether spell mod can overcome protection

		g_obj1 = g_plot
		return true
	end
end

SetUI[GameInfoTypes.EA_SPELL_BREACH] = function()
	if g_bAllTestsPassed then
		if g_bInTowerOrTemple then
			MapModData.text = "Breach land at range " .. g_int3
		else
			MapModData.text = "Breach this land"
		end			
	elseif g_bNonTargetTestsPassed then
		if g_bInTowerOrTemple then
			MapModData.text = "[COLOR_WARNING_TEXT]No land within the caster's " .. g_modSpell .. "-plot range can be breached[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]This plot cannot be breached[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_BREACH] = function()
	if g_bInTowerOrTemple then
		gg_aiOptionValues.i = 200 * g_modSpell * (0.05 - g_int4 / g_int5)		--goes negative if 5% of plots our ours
	elseif not g_plot:IsPlayerCityRadius(g_iPlayer) then	--no value if in our city's 3-plot radius (really should check distance to any of our cities)
		gg_aiOptionValues.i = 50 * GetNIMBY(g_iPlayer, g_x, g_y)	--so in range of 500 for foreign lands (we really want AI to do this)
	end	
end

Finish[GameInfoTypes.EA_SPELL_BREACH] = function()
	print("Finish[GameInfoTypes.EA_SPELL_BREACH] ", g_obj1, g_iPlayer, g_iPerson, g_modSpell)
	g_specialEffectsPlot = g_obj1
	BreachPlot(g_obj1, g_iPlayer, g_iPerson, g_modSpell)	--this will give xp and use mana if success (more than if failure below)
	return true
end

--EA_SPELL_WISH
--EA_SPELL_SLOW
--EA_SPELL_HASTE
--EA_SPELL_ENCHANT_WEAPONS
--EA_SPELL_POLYMORPH


--EA_SPELL_BLIGHT
TestTarget[GameInfoTypes.EA_SPELL_BLIGHT] = function()

	--if true, then:
	--g_obj1 = affected plot (this plot or distant plot from tower/temple)
	--g_int2 = terrainStrength
	--g_int3 = radius (tower/temple only)
	--g_int4 = ownPlotsInDanger (tower/temple only)
	--g_int5 = totalPlotsInDanger (tower/temple only)

	if g_bInTowerOrTemple then	--Can distant plot be blighted? (max range = mod)
		local BlightPlot = BlightPlot
		--random sector/direction, spiral in until valid plot found
		local sector = Rand(6, "hello") + 1
		local anticlock = Rand(2, "hello") == 0
		local maxRadius = g_modSpell < MAX_RANGE and g_modSpell or MAX_RANGE
		for radius = maxRadius, 1, -1 do	--test one full ring at a time (we test whole ring so AI can account for own plots in danger)
			g_obj1 = nil
			local ownPlotsInDanger, totalPlotsInDanger = 0, 0
			for plot in PlotRingIterator(g_plot, radius, sector, anticlock) do
				if BlightPlot(plot, g_iPlayer, g_iPerson, 0, true) then		--just a casting test
					totalPlotsInDanger = totalPlotsInDanger + 1
					if plot:IsPlayerCityRadius(g_iPlayer) then
						ownPlotsInDanger = ownPlotsInDanger + 1
					end	
					g_int2 = 0
					g_obj1 = plot
				end
			end
			if g_obj1 then
				g_int3 = radius
				g_int4 = ownPlotsInDanger
				g_int5 = totalPlotsInDanger
				return true
			end
		end
		return false
	else	--Can THIS plot be blighted (or at least weakened)?
		if not BlightPlot(g_plot, g_iPlayer, g_iPerson, 0, true) then return false end	--just a casting test

		--spell can "work" even if blocked, but only to weaken; best AI value is to blight AND weaken
		local strengthNeeded = 0
		if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE or featureID == FEATURE_MARSH then	--Must overpower any living terrain here
			strengthNeeded = strengthNeeded + g_plot:GetLivingTerrainStrength()
		end
		local effectID, effectStength, iEffectPlayer, iEffectCaster = g_plot:GetPlotEffectData()
		if effectID == EA_PLOTEFFECT_PROTECTIVE_WARD then
			strengthNeeded = strengthNeeded + effectStength
		end
		if g_modSpell < strengthNeeded then
			g_value = g_modSpell
			g_int1 = strengthNeeded
			g_testTargetSwitch = 1
		elseif strengthNeeded > 0 then
			g_value = g_modSpell + 20
			g_int1 = strengthNeeded
			g_testTargetSwitch = 2
		else
			g_value = 20
		end

		g_obj1 = g_plot
		return true
	end
end

SetUI[GameInfoTypes.EA_SPELL_BLIGHT] = function()
	if g_bAllTestsPassed then
		if g_bInTowerOrTemple then
			MapModData.text = "Blight land at range " .. g_int3
		else
			if g_testTargetSwitch == 1 then
				MapModData.text = "You cannot overcome terrain and/or ward strength at this plot (" .. g_int1 .. "); however, the spell will weaken this protection by " .. g_modSpell
			elseif g_testTargetSwitch == 2 then
				MapModData.text = "Blight this land (overcome terrain and/or ward strength " .. g_int1 .. ")"
			else
				MapModData.text = "Blight this land"
			end
		end			
	elseif g_bNonTargetTestsPassed then
		if g_bInTowerOrTemple then
			MapModData.text = "[COLOR_WARNING_TEXT]No land within the caster's " .. g_modSpell .. "-plot range can be blighted[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]This plot cannot be blighted[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_BLIGHT] = function()
	if g_bInTowerOrTemple then
		gg_aiOptionValues.i = 10 * g_modSpell * (0.2 - g_int4 / g_int5)		--goes negative if 20% of plots our ours
	elseif not g_plot:IsPlayerCityRadius(g_iPlayer) then	--no value if in our city's 3-plot radius (really should check distance to any of our cities)
		gg_aiOptionValues.i = g_value * GetNIMBY(g_iPlayer, g_x, g_y) / 20		--10ish around foreign lands
	end	
end

Finish[GameInfoTypes.EA_SPELL_BLIGHT] = function()
	g_specialEffectsPlot = g_obj1
	local bSuccess = BlightPlot(g_obj1, g_iPlayer, g_iPerson, g_modSpell)	--this will give xp and use mana if success (more than if failure below)
	if not bSuccess then
		UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_modSpell, false)
	end
	return true
end


--EA_SPELL_HEX
TestTarget[GameInfoTypes.EA_SPELL_HEX] = function()
	--Priority: strongest adjacent enemy (cost x current hp)
	--g_obj1 = unit
	--g_value = unit cost for AI
	local value = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1, nil, nil, false) do
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if not unit:IsHasPromotion(PROMOTION_HEX) and not unit:IsHasPromotion(PROMOTION_PROTECTION_FROM_EVIL) then
				if g_team:IsAtWar(Players[unit:GetOwner()]:GetTeam()) then
					local unitTypeID = unit:GetUnitType()	
					if gg_regularCombatType[unitTypeID] == "troops" then
						local power = unit:GetPower()
						if value < power then
							g_obj1 = unit
							value = power
						end
					end
				end
			end
		end
	end
	if value == 0 then return false end	--no valid target
	g_value = value
	return true
end

SetUI[GameInfoTypes.EA_SPELL_HEX] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			local unitTypeInfo = GameInfo.Units[g_obj1:GetUnitType()]
			local unitText = Locale.ConvertTextKey(unitTypeInfo.Description)
			MapModData.text = "Hex adjacent " .. unitText
		else
			MapModData.text = "[COLOR_WARNING_TEXT]No valid target[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_HEX] = function()
	gg_aiOptionValues.i = g_value / 10
end

Do[GameInfoTypes.EA_SPELL_HEX] = function()
	g_obj1:SetHasPromotion(PROMOTION_HEX, true)
	local iOtherPlayer = g_obj1:GetOwner()
	local iOtherUnit = g_obj1:GetID()
	local sustainedPromotions = gPlayers[iOtherPlayer].sustainedPromotions
	sustainedPromotions[iOtherUnit] = sustainedPromotions[iOtherUnit] or {}
	sustainedPromotions[iOtherUnit][PROMOTION_HEX] = g_iPerson
	g_specialEffectsPlot = g_obj1:GetPlot()
	return true
end

--EA_SPELL_TELEPORT
--EA_SPELL_PHASE_DOOR


--EA_SPELL_VAMPIRIC_TOUCH
--EA_SPELL_DEATH_STAY

--EA_SPELL_BECOME_LICH
TestTarget[GameInfoTypes.EA_SPELL_BECOME_LICH] = function()
	if g_eaPerson.unitTypeID == UNIT_LICH then
		g_testTargetSwitch = 1
		return false
	end
	if gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson] and gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson].iPlot == g_iPlot then	--only in own tower
		if g_modSpell < g_unit:GetLevel() then
			g_testTargetSwitch = 2
			return false
		else
			return true
		end
	end
	return false
end

SetUI[GameInfoTypes.EA_SPELL_BECOME_LICH] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "You will become a Lich, ageless and immortal (will regenerate in Tower if killed)"
		elseif g_testTargetSwitch == 1 then
			MapModData.text = "[COLOR_WARNING_TEXT]You are already a Lich![ENDCOLOR]"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]You do not have sufficient Necromancy Modifier to cast this spell (need " .. g_unit:GetLevel() .. ")[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]This spell can be cast only from your Tower[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_BECOME_LICH] = function()
	gg_aiOptionValues.i = 1000
end

Finish[GameInfoTypes.EA_SPELL_BECOME_LICH] = function()
	local pts = g_unit:GetLevel() * 100
	g_eaPerson.unitTypeID = UNIT_LICH
	g_eaPerson.predestinedAgeOfDeath = nil
	InitGPUnit(g_iPlayer, g_iPerson, g_x, g_y, g_unit, UNIT_LICH, -1)
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, pts * 100)
	return true
end






--EA_SPELL_FINGER_OF_DEATH
--EA_SPELL_CHARM_MONSTER
--EA_SPELL_CAUSE_FEAR
--EA_SPELL_CAUSE_DISPAIR
--EA_SPELL_SLEEP
--EA_SPELL_DREAM
--EA_SPELL_NIGHTMARE
--EA_SPELL_LESSER_GEAS
--EA_SPELL_GREATER_GEAS
--EA_SPELL_PRESTIDIGITATION
--EA_SPELL_OBSCURE_TERRAIN
--EA_SPELL_FOG_OF_WAR
--EA_SPELL_SIMULACRUM
--EA_SPELL_PHANTASMAGORIA


--EA_SPELL_HEAL
TestTarget[GameInfoTypes.EA_SPELL_HEAL] = function()
	--Heal same plot or adjacent living unit from my team. Priority:
	--2. Heal unit that can use full healing effect
	--1. Heal unit that needs less than full ealing effect

	--Use g_testTargetSwitch to step through priority level (initial 0 means no target)
	--Within category 1-2, pick costliest unit
	--g_int1 = hp heal
	--g_obj1 = unit

	local pts = g_modSpell < g_faith and g_modSpell or g_faith
	if pts == 0 then return false end
	local power = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			local unitTypeID = unit:GetUnitType()
			if gg_regularCombatType[unitTypeID] == "troops" then
				local damage = unit:GetDamage()
				local maxHP = unit:GetMaxHitPoints()
				local maxPower = unit:GetPower() * maxHP / (maxHP - damage)
				if 0 < damage and Players[unit:GetOwner()]:GetTeam() == g_iTeam then
					if damage < pts then --partial use of heal potential
						if g_testTargetSwitch == 0 then
							g_obj1 = unit
							g_int1 = damage
							power = maxPower
							g_testTargetSwitch = 1
						elseif g_testTargetSwitch == 1 and power < maxPower then
							g_obj1 = unit
							g_int1 = damage
							power = maxPower
						end
					else	--full use of heal potential
						if g_testTargetSwitch < 2 then
							g_obj1 = unit
							g_int1 = pts
							power = maxPower
							g_testTargetSwitch = 2
						elseif power < maxPower then
							g_obj1 = unit
							g_int1 = pts
							power = maxPower
						end
					end
				end
			end
		end
	end
	if g_testTargetSwitch == 0 then return false end	--no valid target

	g_int2 = power	--for AI

	return true
end

SetUI[GameInfoTypes.EA_SPELL_HEAL] = function()
	if g_bNonTargetTestsPassed then
		if g_testTargetSwitch == 0 then
			local pts = g_modSpell < g_faith and g_modSpell or g_faith
			if pts == 0 then
				MapModData.text = "[COLOR_WARNING_TEXT]Heal friendly unit on this or adjacent plot (no mana or divine favor)[ENDCOLOR]"
			else
				MapModData.text = "[COLOR_WARNING_TEXT]Heal friendly unit on this or adjacent plot by " .. pts .. " HP (no valid target)[ENDCOLOR]"
			end
		else
			local unitTypeInfo = GameInfo.Units[g_obj1:GetUnitType()]
			local unitText = Locale.ConvertTextKey(unitTypeInfo.Description)
			if g_testTargetSwitch == 1 then
				MapModData.text = "Fully heal " .. unitText .. " (" .. g_int1 .. " hp)"
			else
				MapModData.text = "Partially heal " .. unitText .. " (" .. g_int1 .. " hp)"
			end
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_HEAL] = function()
	--The AI value for a Heal spell is an instant payoff (i) = hp * power / 10; use this as baseline for other spell values
	gg_aiOptionValues.i = g_int1 * g_int2 / 10
	--print("AI value for Heal spell= ", gg_aiOptionValues.i)
end

Do[GameInfoTypes.EA_SPELL_HEAL] = function()
	--GetCurrHitPoints, GetMaxHitPoints, GetDamage, SetDamage
	g_obj1:SetDamage(g_obj1:GetDamage() - g_int1, -1)		-- heal
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_int1)
	g_specialEffectsPlot = g_obj1:GetPlot()
	return true
end

--EA_SPELL_BLESS
TestTarget[GameInfoTypes.EA_SPELL_BLESS] = function()
	--Priority: strongest same-tile oradjacent ally (cost x current hp)
	--g_obj1 = unit
	--g_value = unit cost for AI
	local value = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if unit:GetOwner() == g_iPlayer then		--change to allied
				if not unit:IsHasPromotion(PROMOTION_BLESSED) and not unit:IsHasPromotion(PROMOTION_EVIL_EYE) then
					local unitTypeID = unit:GetUnitType()	
					if gg_regularCombatType[unitTypeID] == "troops" then
						local power = unit:GetPower()
						if value < power then
							g_obj1 = unit
							value = power
						end
					end
				end
			end
		end
	end
	if value == 0 then return false end	--no valid target
	g_value = value
	return true
end

SetUI[GameInfoTypes.EA_SPELL_BLESS] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			local unitTypeInfo = GameInfo.Units[g_obj1:GetUnitType()]
			local unitText = Locale.ConvertTextKey(unitTypeInfo.Description)
			MapModData.text = "Bless adjacent " .. unitText
		else
			MapModData.text = "[COLOR_WARNING_TEXT]No valid target[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_BLESS] = function()
	gg_aiOptionValues.i = g_modSpell * g_value / 10
end

Do[GameInfoTypes.EA_SPELL_BLESS] = function()
	g_obj1:SetHasPromotion(PROMOTION_BLESSED, true)
	local iOtherPlayer = g_obj1:GetOwner()
	local iOtherUnit = g_obj1:GetID()
	local sustainedPromotions = gPlayers[iOtherPlayer].sustainedPromotions
	sustainedPromotions[iOtherUnit] = sustainedPromotions[iOtherUnit] or {}
	sustainedPromotions[iOtherUnit][PROMOTION_BLESSED] = g_iPerson
	g_specialEffectsPlot = g_obj1:GetPlot()
	return true
end

--EA_SPELL_PROTECTION_FROM_EVIL
TestTarget[GameInfoTypes.EA_SPELL_PROTECTION_FROM_EVIL] = function()
	--Priority: strongest same-tile oradjacent ally (cost x current hp)
	--g_obj1 = unit
	--g_value = unit cost for AI
	local value = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if unit:GetOwner() == g_iPlayer then		--change to allied
				if not unit:IsHasPromotion(PROMOTION_PROTECTION_FROM_EVIL) and not unit:IsHasPromotion(PROMOTION_EVIL_EYE) then
					local unitTypeID = unit:GetUnitType()	
					if gg_regularCombatType[unitTypeID] == "troops" then
						local power = unit:GetPower()
						if value < power then
							g_obj1 = unit
							value = power
						end
					end
				end
			end
		end
	end
	if value == 0 then return false end	--no valid target
	g_value = value
	return true
end

SetUI[GameInfoTypes.EA_SPELL_PROTECTION_FROM_EVIL] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			local unitTypeInfo = GameInfo.Units[g_obj1:GetUnitType()]
			local unitText = Locale.ConvertTextKey(unitTypeInfo.Description)
			MapModData.text = "Give Protection frm Evil to adjacent " .. unitText
		else
			MapModData.text = "[COLOR_WARNING_TEXT]No valid target[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_PROTECTION_FROM_EVIL] = function()
	gg_aiOptionValues.i = g_modSpell * g_value / 10
end

Do[GameInfoTypes.EA_SPELL_PROTECTION_FROM_EVIL] = function()
	g_obj1:SetHasPromotion(PROMOTION_PROTECTION_FROM_EVIL, true)
	local iOtherPlayer = g_obj1:GetOwner()
	local iOtherUnit = g_obj1:GetID()
	local sustainedPromotions = gPlayers[iOtherPlayer].sustainedPromotions
	sustainedPromotions[iOtherUnit] = sustainedPromotions[iOtherUnit] or {}
	sustainedPromotions[iOtherUnit][PROMOTION_PROTECTION_FROM_EVIL] = g_iPerson
	g_specialEffectsPlot = g_obj1:GetPlot()
	return true
end

--EA_SPELL_HURT
TestTarget[GameInfoTypes.EA_SPELL_HURT] = function()
	--Hurt same plot or adjacent living unit enemy team. Priority:
	--2. Hurt unit that will be killed
	--1. Hurt unit that won't be killed

	--Use g_testTargetSwitch to step through priority level (initial 0 means no target)
	--Within category 1-2, pick costliest unit
	--g_int1 = hp hurt
	--g_obj1 = unit

	local pts = g_modSpell < g_faith and g_modSpell or g_faith
	if pts == 0 then return false end				--make this a generic test?
	local power = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if g_team:IsAtWar(Players[unit:GetOwner()]:GetTeam()) then
				local unitTypeID = unit:GetUnitType()	
				if gg_regularCombatType[unitTypeID] == "troops" then
					local currentHP = unit:GetCurrHitPoints()
					local maxHP = unit:GetMaxHitPoints()
					local maxPower = unit:GetPower() * maxHP / currentHP
					if pts < currentHP then --won't kill
						if g_testTargetSwitch == 0 then
							g_obj1 = unit
							g_int1 = pts
							power = maxPower
							g_testTargetSwitch = 1
						elseif g_testTargetSwitch == 1 and power < maxPower then
							g_obj1 = unit
							g_int1 = pts
							power = maxPower
						end
					else					--will kill
						if g_testTargetSwitch < 2 then
							g_obj1 = unit
							g_int1 = currentHP
							power = maxPower
							g_testTargetSwitch = 2
						elseif power < maxPower then
							g_obj1 = unit
							g_int1 = currentHP
							power = maxPower
						end
					end
				end
			end
		end
	end
	if g_testTargetSwitch == 0 then return false end	--no valid target

	g_int2 = power	--for AI

	return true
end

SetUI[GameInfoTypes.EA_SPELL_HURT] = function()
	if g_bNonTargetTestsPassed then
		if g_testTargetSwitch == 0 then
			local pts = g_modSpell < g_faith and g_modSpell or g_faith
			if pts == 0 then
				MapModData.text = "[COLOR_WARNING_TEXT]Hurt enemy unit on this or adjacent plot (no mana or divine favor)[ENDCOLOR]"
			else
				MapModData.text = "[COLOR_WARNING_TEXT]Hurt enemy unit on this or adjacent plot by " .. pts .. " HP (no valid target)[ENDCOLOR]"
			end
		else
			local unitTypeInfo = GameInfo.Units[g_obj1:GetUnitType()]
			local unitText = Locale.ConvertTextKey(unitTypeInfo.Description)
			if g_testTargetSwitch == 1 then
				MapModData.text = "Hurt " .. unitText .. " (" .. g_int1 .. " hp; will kill unit)"
			else
				MapModData.text = "Hurt " .. unitText .. " (" .. g_int1 .. " hp)"
			end
			print("SetUI for EA_SPELL_HEAL", g_int1, g_int2, g_obj1)
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_HURT] = function()
	--The AI value for a Heal spell is an instant payoff (i) = hp * power / 100; use this as baseline for other spell values
	gg_aiOptionValues.i = g_int1 * g_int2 / 10
	--print("AI value for Heal spell= ", gg_aiOptionValues.i)
end

Do[GameInfoTypes.EA_SPELL_HURT] = function()
	--GetCurrHitPoints, GetMaxHitPoints, GetDamage, SetDamage
	g_obj1:SetDamage(g_obj1:GetDamage() + g_int1, g_iPlayer)		-- hurt
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_int1)
	g_specialEffectsPlot = g_obj1:GetPlot()
	return true
end

--EA_SPELL_CURSE
TestTarget[GameInfoTypes.EA_SPELL_CURSE] = function()
	--Priority: strongest adjacent enemy (cost x current hp)
	--g_obj1 = unit
	--g_value = unit cost for AI
	local value = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if not unit:IsHasPromotion(PROMOTION_CURSED) and not unit:IsHasPromotion(PROMOTION_PROTECTION_FROM_EVIL) then
				if g_team:IsAtWar(Players[unit:GetOwner()]:GetTeam()) then
					local unitTypeID = unit:GetUnitType()	
					if gg_regularCombatType[unitTypeID] == "troops" then
						local power = unit:GetPower()
						if value < power then
							g_obj1 = unit
							value = power
						end
					end
				end
			end
		end
	end
	if value == 0 then return false end	--no valid target
	g_value = value
	return true
end

SetUI[GameInfoTypes.EA_SPELL_CURSE] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			local unitTypeInfo = GameInfo.Units[g_obj1:GetUnitType()]
			local unitText = Locale.ConvertTextKey(unitTypeInfo.Description)
			MapModData.text = "Curse adjacent " .. unitText
		else
			MapModData.text = "[COLOR_WARNING_TEXT]No valid target[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_CURSE] = function()
	gg_aiOptionValues.i = g_modSpell * g_value / 10
end

Do[GameInfoTypes.EA_SPELL_CURSE] = function()
	g_obj1:SetHasPromotion(PROMOTION_CURSED, true)
	local iOtherPlayer = g_obj1:GetOwner()
	local iOtherUnit = g_obj1:GetID()
	local sustainedPromotions = gPlayers[iOtherPlayer].sustainedPromotions
	sustainedPromotions[iOtherUnit] = sustainedPromotions[iOtherUnit] or {}
	sustainedPromotions[iOtherUnit][PROMOTION_CURSED] = g_iPerson
	g_specialEffectsPlot = g_obj1:GetPlot()
	return true
end

--EA_SPELL_EVIL_EYE
TestTarget[GameInfoTypes.EA_SPELL_EVIL_EYE] = function()
	--Priority: strongest adjacent enemy (cost x current hp)
	--g_obj1 = unit
	--g_value = unit cost for AI
	local value = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if not unit:IsHasPromotion(PROMOTION_EVIL_EYE) and not unit:IsHasPromotion(PROMOTION_PROTECTION_FROM_EVIL) then
				if g_team:IsAtWar(Players[unit:GetOwner()]:GetTeam()) then
					local unitTypeID = unit:GetUnitType()	
					if gg_regularCombatType[unitTypeID] == "troops" then
						local power = unit:GetPower()
						if value < power then
							g_obj1 = unit
							value = power
						end
					end
				end
			end
		end
	end
	if value == 0 then return false end	--no valid target
	g_value = value
	return true
end

SetUI[GameInfoTypes.EA_SPELL_EVIL_EYE] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			local unitTypeInfo = GameInfo.Units[g_obj1:GetUnitType()]
			local unitText = Locale.ConvertTextKey(unitTypeInfo.Description)
			MapModData.text = "Cast Evil-Eye on adjacent " .. unitText
		else
			MapModData.text = "[COLOR_WARNING_TEXT]No valid target[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_EVIL_EYE] = function()
	gg_aiOptionValues.i = g_modSpell * g_value / 10
end

Do[GameInfoTypes.EA_SPELL_EVIL_EYE] = function()
	g_obj1:SetHasPromotion(PROMOTION_EVIL_EYE, true)
	local iOtherPlayer = g_obj1:GetOwner()
	local iOtherUnit = g_obj1:GetID()
	local sustainedPromotions = gPlayers[iOtherPlayer].sustainedPromotions
	sustainedPromotions[iOtherUnit] = sustainedPromotions[iOtherUnit] or {}
	sustainedPromotions[iOtherUnit][PROMOTION_EVIL_EYE] = g_iPerson
	g_specialEffectsPlot = g_obj1:GetPlot()
	return true
end

--EA_SPELL_EAS_BLESSING
TestTarget[GameInfoTypes.EA_SPELL_EAS_BLESSING] = function()
	local featureID = g_plot:GetFeatureType()
	if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE or featureID == FEATURE_MARSH then
		g_int2 = featureID
		return true
	end
	return false
end

SetUI[GameInfoTypes.EA_SPELL_EAS_BLESSING] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			local featureInfo = GameInfo.Features[g_int2]
			local featureName = Locale.ConvertTextKey(featureInfo.Description)
			MapModData.text = "Increase spreading and regeneration strength of " .. featureName .. " by " .. g_modSpell
		else
			MapModData.text = "[COLOR_WARNING_TEXT]Plot must be Living Terrain (Forest, Jungle or Marsh)[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_EAS_BLESSING] = function()
	local countCanSpreadAdj = 0
	for x, y in  PlotToRadiusIterator(g_x, g_y, 1, nil, nil, true) do
		local adjPlot = GetPlotFromXY(x, y)
		if adjPlot:GetFeatureType() == -1 and adjPlot:GetImprovementType() == -1 and not adjPlot:IsCity() then
			local terrainID = adjPlot:GetTerrainType()
			if g_int2 == FEATURE_FOREST then
				if terrainID == TERRAIN_GRASS or terrainID == TERRAIN_PLAINS or terrainID == TERRAIN_TUNDRA then
					countCanSpreadAdj = countCanSpreadAdj + 1
				end
			elseif g_int2 == FEATURE_JUNGLE then
				if terrainID == TERRAIN_GRASS or terrainID == TERRAIN_PLAINS then
					countCanSpreadAdj = countCanSpreadAdj + 1
				end
			elseif g_int2 == FEATURE_MARSH then
				if terrainID == TERRAIN_GRASS and adjPlot:GetPlotType() == PLOT_LAND then
					countCanSpreadAdj = countCanSpreadAdj + 1
				end
			end
		end
	end
	local strength = g_plot:GetLivingTerrainStrength()
	gg_aiOptionValues.i = g_modSpell * (countCanSpreadAdj + 0.1) / (strength + 1)		--tiny positive even if it can't spread
end

Finish[GameInfoTypes.EA_SPELL_EAS_BLESSING] = function()
	local type, present, strength, turnChopped = g_plot:GetLivingTerrainData()
	if type == -1 then
		if g_int2 == FEATURE_FOREST then
			type = 1	--"forest"
		elseif g_int2 == FEATURE_JUNGLE then
			type = 2	--"jungle"
		else
			type = 3	--"marsh"
		end
		present = true
		strength = 0
		turnChopped = -100
	end
	strength = strength + g_modSpell
	g_plot:SetLivingTerrainData(type, present, strength, turnChopped)
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_modSpellTimesTurns)
	g_eaPlayer.livingTerrainStrengthAdded = (g_eaPlayer.livingTerrainStrengthAdded or 0) + g_modSpell
	return true
end


--EA_SPELL_BLOOM
TestTarget[GameInfoTypes.EA_SPELL_BLOOM] = function()
	--target tests (must be valid terrain type without feature or improvement and adjacent to forest or jungle)
	if g_bIsCity then return false end
	if g_plot:GetFeatureType() ~= -1 then return false end
	local terrainID = g_plot:GetTerrainType()
	if terrainID ~= TERRAIN_GRASS and terrainID ~= TERRAIN_PLAINS and terrainID ~= TERRAIN_TUNDRA then return false end
	local imprID = g_plot:GetImprovementType()
	if imprID ~= -1 then return false end
	local forestCount, jungleCount = 0, 0
	for x, y in  PlotToRadiusIterator(g_x, g_y, 1, nil, nil, true) do
		local adjPlot = GetPlotFromXY(x, y)
		local adjFeature = adjPlot:GetFeatureType()
		if adjFeature == FEATURE_FOREST then
			forestCount = forestCount + 1
		elseif adjFeature == FEATURE_JUNGLE then
			jungleCount = jungleCount + 1
		end
	end
	if forestCount == 0 and jungleCount == 0 then return false end

	if terrainID ~= TERRAIN_PLAINS or terrainID ~= TERRAIN_TUNDRA then
		g_bool1 = true	--forest
		return true
	end
	g_bool1 = jungleCount < forestCount	--forest or jungle
	return true
end

SetUI[GameInfoTypes.EA_SPELL_BLOOM] = function()
	if g_bNonTargetTestsPassed then		--has spell so show it
		if g_bAllTestsPassed then
			if g_bool1 then
				MapModData.text = "Grow a forest on this plot"
			else
				MapModData.text = "Grow a jungle on this plot"
			end
		else
			MapModData.text = "[COLOR_WARNING_TEXT]Plot must be unimproved grass, plains or tundra next to existing forest or jungle[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_BLOOM] = function()
	local countCanSpreadAdj = 1
	for x, y in  PlotToRadiusIterator(g_x, g_y, 1, nil, nil, true) do
		local adjPlot = GetPlotFromXY(x, y)
		if adjPlot:GetFeatureType() == -1 and adjPlot:GetImprovementType() == -1 and not adjPlot:IsCity() then
			local terrainID = adjPlot:GetTerrainType()
			if g_bool1 then		--will be forest
				if terrainID == TERRAIN_GRASS or terrainID == TERRAIN_PLAINS or terrainID == TERRAIN_TUNDRA then
					countCanSpreadAdj = countCanSpreadAdj + 1
				end
			else	--will be jungle
				if terrainID == TERRAIN_GRASS or terrainID == TERRAIN_PLAINS then
					countCanSpreadAdj = countCanSpreadAdj + 1
				end
			end
		end
	end
	gg_aiOptionValues.i = g_modSpell * countCanSpreadAdj 		--always better than Ea's Blessing
end

Finish[GameInfoTypes.EA_SPELL_BLOOM] = function()
	local type = g_bool1 and 1 or 2	--"forest" or "jungle"
	LivingTerrainGrowHere(g_iPlot, type)
	g_plot:SetLivingTerrainData(type, true, g_modSpell, -100)

	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_modSpellTimesTurns)
	g_eaPlayer.livingTerrainAdded = (g_eaPlayer.livingTerrainAdded or 0) + 1
	g_eaPlayer.livingTerrainStrengthAdded = (g_eaPlayer.livingTerrainStrengthAdded or 0) + g_modSpell
	return true
end

--EA_SPELL_RIDE_LIKE_THE_WIND
TestTarget[GameInfoTypes.EA_SPELL_RIDE_LIKE_THE_WIND] = function()
	--Affects all adjacent: value each = cost x current hp
	--g_int1 = numQualifiedUnits
	--g_table holds potentially affected units
	--g_value = cummulative
	local numQualifiedUnits = 0
	local value = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if unit:GetOwner() == g_iPlayer then
				local unitTypeID = unit:GetUnitType()	
				if gg_regularCombatType[unitTypeID] == "troops" then
					local unitCombatID = unit:GetUnitCombatType()
					if unitCombatID == UNITCOMBAT_MOUNTED or unitCombatID == UNITCOMBAT_GUN then
						if not unit:IsHasPromotion(PROMOTION_RIDE_LIKE_THE_WINDS) and not unit:IsHasPromotion(PROMOTION_EVIL_EYE) then
							numQualifiedUnits = numQualifiedUnits + 1
							g_table[numQualifiedUnits] = unit
							value = value + unit:GetPower()
						end
					end
				end
			end
		end
	end
	if value == 0 then return false end	--no valid target
	g_int1 = numQualifiedUnits
	g_value = value
	return true
end

SetUI[GameInfoTypes.EA_SPELL_RIDE_LIKE_THE_WIND] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			MapModData.text = "Increase movement of " .. g_int1 .. " nearby horse-mounted unit(s) by 2"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]No valid targets[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_RIDE_LIKE_THE_WIND] = function()
	gg_aiOptionValues.i = g_modSpell * g_value / 10
end

Do[GameInfoTypes.EA_SPELL_RIDE_LIKE_THE_WIND] = function()
	for i = 1, g_int1 do
		local unit = g_table[i]
		unit:SetHasPromotion(PROMOTION_RIDE_LIKE_THE_WINDS, true)
		local iOtherPlayer = unit:GetOwner()
		local iOtherUnit = unit:GetID()
		local sustainedPromotions = gPlayers[iOtherPlayer].sustainedPromotions
		sustainedPromotions[iOtherUnit] = sustainedPromotions[iOtherUnit] or {}
		sustainedPromotions[iOtherUnit][PROMOTION_RIDE_LIKE_THE_WINDS] = g_iPerson
	end
	return true
end

local removedByPurify = {PROMOTION_HEX, PROMOTION_CURSED, PROMOTION_EVIL_EYE}
local numRemovedByPurify = #removedByPurify

--EA_SPELL_PURIFY
TestTarget[GameInfoTypes.EA_SPELL_PURIFY] = function()
	--Priority: best effect
	--g_obj1 = unit
	--g_value = unit cost for AI
	local pts = g_modSpell < g_faith and g_modSpell or g_faith
	local healHP = floor(pts * 0.667)
	local bestValue = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if unit:GetOwner() == g_iPlayer then	
				local unitTypeID = unit:GetUnitType()	
				if gg_regularCombatType[unitTypeID] == "troops" then
					local damage = unit:GetDamage()
					local hpHealed = healHP < damage and healHP or damage
					local removeBonus = 0
					for j = 1, numRemovedByPurify do
						local promoID = removedByPurify[j]
						if unit:IsHasPromotion(promoID) then
							removeBonus = removeBonus + 20
						end
					end
					local power = unit:GetPower()
					local value = power * (hpHealed + removeBonus)
					if bestValue < value then
						g_obj1 = unit
						bestValue = value
					end
				end
			end
		end
	end
	if bestValue == 0 then return false end	--no valid target
	g_value = bestValue
	return true
end

SetUI[GameInfoTypes.EA_SPELL_PURIFY] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			local unitTypeInfo = GameInfo.Units[g_obj1:GetUnitType()]
			local unitText = Locale.ConvertTextKey(unitTypeInfo.Description)
			--recalculate what we need as above
			local pts = g_modSpell < g_faith and g_modSpell or g_faith
			local healHP = floor(pts * 0.667)
			local damage = g_obj1:GetDamage()
			local hpHealed = healHP < damage and healHP or damage
			local healText = ""
			if hpHealed > 0 then
				healText = "heal " .. hpHealed .. " hp"
			end
			local removeText = ""
			local removeCount = 0
			local lastItem = ""
			for i = 1, numRemovedByPurify do
				local promoID = removedByPurify[i]
				if g_obj1:IsHasPromotion(promoID) then
					removeCount = removeCount + 1
					local promoInfo = GameInfo.UnitPromotions[promoID]
					if removeCount == 1 then
						removeText = (healText == "" and "remove " or "; remove ") .. Locale.ConvertTextKey(promoInfo.Description)
					else
						if removeCount > 2 then
							removeText = removeText .. ", " .. lastItem
						end
						lastItem = Locale.ConvertTextKey(promoInfo.Description)
					end
				end
			end
			if removeCount > 1 then
				removeText = removeText .. " and " .. lastItem
			end

			MapModData.text = "Purify adjacent " .. unitText .. " (" .. healText .. removeText .. ")"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]No valid target[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_PURIFY] = function()
	gg_aiOptionValues.i = g_modSpell * g_value / 10
end

Do[GameInfoTypes.EA_SPELL_PURIFY] = function()
	local pts = g_modSpell < g_faith and g_modSpell or g_faith
	local healHP = floor(pts * 0.667)
	local damage = g_obj1:GetDamage()
	local hpHealed = healHP < damage and healHP or damage
	g_obj1:SetDamage(g_obj1:GetDamage() - hpHealed, -1)

	local removeCount = 0
	for i = 1, numRemovedByPurify do
		local promoID = removedByPurify[i]
		if g_obj1:IsHasPromotion(promoID) then
			removeCount = removeCount + 1
			g_obj1:SetHasPromotion(promoID, false)
		end
	end
	pts = pts + removeCount
	pts = pts < g_faith and pts or g_faith
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, 5)
	g_specialEffectsPlot = g_obj1:GetPlot()
	return true
end

--EA_SPELL_FAIR_WINDS
TestTarget[GameInfoTypes.EA_SPELL_FAIR_WINDS] = function()
	--Priority: strongest adjacent enemy (cost x current hp)
	--g_obj1 = unit
	--g_value = unit cost for AI
	local value = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if unit:GetOwner() == g_iPlayer then
				local unitTypeID = unit:GetUnitType()	
				if gg_regularCombatType[unitTypeID] == "ship" then
					if not unit:IsHasPromotion(PROMOTION_FAIR_WINDS) then
						local power = unit:GetPower()
						if value < power then
							g_obj1 = unit
							value = power
						end
					end
				end	
			end
		end
	end
	if value == 0 then return false end	--no valid target
	g_value = value
	return true
end

SetUI[GameInfoTypes.EA_SPELL_FAIR_WINDS] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			local unitTypeInfo = GameInfo.Units[g_obj1:GetUnitType()]
			local unitText = Locale.ConvertTextKey(unitTypeInfo.Description)
			MapModData.text = "Permanently increase movement of adjacent " .. unitText .. " by 1"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]No valid target[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_FAIR_WINDS] = function()
	gg_aiOptionValues.i = g_value / 10
end

Do[GameInfoTypes.EA_SPELL_FAIR_WINDS] = function()
	g_obj1:SetHasPromotion(PROMOTION_FAIR_WINDS, true)
	g_specialEffectsPlot = g_obj1:GetPlot()
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, 5)
	g_specialEffectsPlot = g_obj1:GetPlot()
	return true
end

--EA_SPELL_REVELRY
TestTarget[GameInfoTypes.EA_SPELL_REVELRY] = function()
	g_int1 = UNHAPPINESS_PER_CITY + g_city:GetPopulation() - g_city:GetLocalHappiness() 	--CHECK THIS !!!!	
	return 0 < g_int1
end

SetUI[GameInfoTypes.EA_SPELL_REVELRY] = function()
	if g_bNonTargetTestsPassed then
		if g_bAllTestsPassed then
			local pts = floor(g_modSpell / 2)
			pts = pts < g_int1 and pts or g_int1
			MapModData.text = "Increase happiness by " .. pts
		elseif g_bIsCity and g_iOwner == g_iPlayer then
			MapModData.text = "[COLOR_WARNING_TEXT]This city is generating maximum happiness for its population already[ENDCOLOR]"
		else
			MapModData.text = "[COLOR_WARNING_TEXT]Must be in one of your cities[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_REVELRY] = function()
	local pts = floor(g_modSpell / 2)
	pts = pts < g_int1 and pts or g_int1
	gg_aiOptionValues.b = pts
end

Do[GameInfoTypes.EA_SPELL_REVELRY] = function()
	local pts = floor(g_modSpell / 2)
	pts = pts < g_int1 and pts or g_int1
	g_eaCity.gpHappiness = g_eaCity.gpHappiness or {}
	g_eaCity.gpHappiness[g_iPerson] = pts
	g_eaPerson.eaActionData = g_iPlot
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, pts)
	if g_iPlayer == g_iActivePlayer then
		UpdateCityYields(g_iPlayer, g_iCity, "Happiness")	--instant UI update for human
	end
	return true
end

Interrupt[GameInfoTypes.EA_SPELL_REVELRY] = function(iPlayer, iPerson)
	local eaPerson = gPeople[iPerson]
	local eaCityIndex = eaPerson.eaActionData
	local eaCity = gCities[eaCityIndex]
	if eaCity then
		eaCity.gpHappiness[iPerson] = nil
		eaPerson.eaActionData = -1
		if iPlayer == g_iActivePlayer then
			local iCity = GetPlotByIndex(eaCityIndex):GetPlotCity():GetID()
			UpdateCityYields(iPlayer, iCity, "Happiness")
		end
	end
end

