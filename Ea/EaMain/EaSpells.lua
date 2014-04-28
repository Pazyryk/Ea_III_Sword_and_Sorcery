-- EaSpells
-- Author: Pazyryk
-- DateCreated: 4/24/2014 4:19:25 PM
--------------------------------------------------------------

-- Top functions in this file are almost the same as EaActions
-- 
--------------------------------------------------------------
print("Loading EaActions.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end


---------------------------------------------------------------
-- Local defines
---------------------------------------------------------------

--constants
local DOMAIN_LAND =							DomainTypes.DOMAIN_LAND
local DOMAIN_SEA =							DomainTypes.DOMAIN_SEA
local EA_WONDER_ARCANE_TOWER =				GameInfoTypes.EA_WONDER_ARCANE_TOWER
local FEATURE_BLIGHT =	 					GameInfoTypes.FEATURE_BLIGHT
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
local RELIGION_THE_WEAVE_OF_EA =			GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
local TERRAIN_GRASS =						GameInfoTypes.TERRAIN_GRASS
local TERRAIN_PLAINS =						GameInfoTypes.TERRAIN_PLAINS
local TERRAIN_TUNDRA =						GameInfoTypes.TERRAIN_TUNDRA

local UNHAPPINESS_PER_CITY =				GameDefines.UNHAPPINESS_PER_CITY

local UNIT_SUFFIXES =						UNIT_SUFFIXES
local NUM_UNIT_SUFFIXES =					#UNIT_SUFFIXES
local MOD_MEMORY_HALFLIFE =					MOD_MEMORY_HALFLIFE

local MAX_RANGE =							MAX_RANGE
local FIRST_SPELL_ID =						FIRST_SPELL_ID

--global tables
local GameInfoTypes =						GameInfoTypes
local MapModData =							MapModData
local fullCivs =							MapModData.fullCivs
local bFullCivAI =							MapModData.bFullCivAI
local gWorld =								gWorld
local gCities =								gCities
local gPlayers =							gPlayers
local gPeople =								gPeople
local gReligions =							gReligions
local gWonders =							gWonders
local gg_aiOptionValues =					gg_aiOptionValues
local gg_playerValues =						gg_playerValues
local gg_bToCheapToHire =					gg_bToCheapToHire
local gg_bNormalCombatUnit =				gg_bNormalCombatUnit
local gg_bNormalLivingCombatUnit =			gg_bNormalLivingCombatUnit
local gg_normalizedUnitPower =				gg_normalizedUnitPower

--localized functions
local Floor =								math.floor
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

local g_bTarget						--true if targetX, targetY provided; otherwise, values are for g_unitX, g_unitY
local g_iPlot
local g_plot
local g_specialEffectsPlot			--same as g_plot unless changed in specific function
local g_iOwner
local g_x
local g_y

local g_bInTowerOrTemple			--these two are only set if g_eaAction.ConsiderTowerTemple
local g_modSpell					--g_mod plus plot Tower/Temple mod

local g_bIsCity		--if true then the following values are always calculated (follows target g_x, g_y if provided; otherwise g_unit g_x,g_y)
local g_iCity
local g_city
local g_eaCity

--human UI stuff (what is stopping us?)
local g_bUICall = false
local g_bUniqueBlocked = false
local g_bSomeoneElseDoingHere = false
local g_bNonTargetTestsPassed = false
local g_bAllTestsPassed = false
local g_bSufficientFaith = true
local g_bSetDelayedFailForUI = false

--communicate from TestTarget to SetUI or SetAIValues when needed
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
for row in GameInfo.EaActions() do
	local id = row.ID
	if id >= FIRST_SPELL_ID then
		EaActionsInfo[id] = row
	end
end

local gpTempTypeUnits = {}	--index by role, originalTypeID; holds tempTypeID
for unitInfo in GameInfo.Units() do
	if unitInfo.EaGPTempRole then
		local role = unitInfo.EaGPTempRole
		local tempType = unitInfo.Type
		local tempTypeID = unitInfo.ID
		for row in GameInfo.Unit_EaGPTempTypes() do
			if row.TempUnitType == tempType then
				local originalTypeID = GameInfoTypes[row.UnitType]
				gpTempTypeUnits[role] = gpTempTypeUnits[role] or {}
				gpTempTypeUnits[role][originalTypeID] = tempTypeID
			end
		end
	end
end

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
		g_plot:AddFloatUpMessage(Locale.Lookup(g_eaAction.Description), 1)
	end

	ClearActionPlotTargetedForPerson(g_eaPlayer, g_iPerson)
	g_eaPerson.eaActionID = -1		--will bring back to map on next turn

	--g_unit:SetInvisibleType(INVISIBLE_SUBMARINE)

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
	MapModData.bShow = g_bAllTestsPassed	--may change below
	MapModData.text = "no help text"		--will change below or take eaAction.Help value (if bShow)

	--By default, bShow follows bAllow and text will be from eaAction.Help. If we want bShow=true when bAllow=false,
	--then we must change below in g_bUniqueBlocked code or in action-specific SetUI function.

	--Set UI for unique builds (generic way; it can be overriden by specific SetUI funtion)
	if g_bUniqueBlocked then
		if g_eaAction.UniqueType == "World" then
			if gWorldUniqueAction[eaActionID] then
				if gWorldUniqueAction[eaActionID] ~= -1 then	--being built
					MapModData.bShow = true
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
					MapModData.bShow = true
					MapModData.text = "[COLOR_WARNING_TEXT]Another Great Person from your civilization is working on this...[ENDCOLOR]"
				end
			end
		end
	elseif g_bSomeoneElseDoingHere then		--true only if all other tests passed
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]You cannot do this in the same place as another great person from your civilization[ENDCOLOR]"	
	end

	if g_eaPerson.spells and g_eaPerson.spells[eaActionID] then
		MapModData.bShow = true
		if not g_bSufficientFaith then
			if g_faith < 1 then
				MapModData.text = "[COLOR_WARNING_TEXT]You do not have any mana or divine favor[ENDCOLOR]"
			else
				MapModData.text = "[COLOR_WARNING_TEXT]You do not have sufficient mana or divine favor to cast this spell (" .. g_eaAction.FixedFaith .. " needed)[ENDCOLOR]"
			end
		end
	end

	if SetUI[eaActionID] then
		SetUI[eaActionID]()	--always set MapModData.bShow and MapModData.text together (need specific function if we want to show disabled button)
	end

	if MapModData.bShow and MapModData.text == "no help text" and g_eaAction.Help then
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
	g_gameTurn = Game.GetGameTurn()

	print("TestEaSpell", eaActionID, iPlayer, unit, iPerson, testX, testY, bAINonTargetTest)

	g_bNonTargetTestsPassed = false
	g_testTargetSwitch = 0

	g_SpellClass = g_eaAction.SpellClass
	if not g_SpellClass then
		error("TestEaSpell g_eaAction did not have a SpellClass")
	end

	--skip all world and civ-level reqs (for spells, these only apply to learning not casting) except for FixedFaith
	if not iPerson then return false end	--we'll handle non-GP spellcasting later
	g_eaPerson = gPeople[iPerson]
	if not g_eaPerson.spells or not g_eaPerson.spells[eaActionID] then return false end		--don't have spells or this spell (most common exclude)
	g_iPlayer = iPlayer
	g_eaPlayer = gPlayers[iPlayer]
	g_player = Players[iPlayer]
		
	g_iTeam = g_player:GetTeam()
	g_team = Teams[g_iTeam]	


	if bAINonTargetTest then
		if g_eaPlayer.aiUniqueTargeted[eaActionID] and g_eaPlayer.aiUniqueTargeted[eaActionID] ~= iPerson then return false end	--ai specific exclude (someone on way to do this)
		g_bAIControl = true
	else
		g_bAIControl = bFullCivAI[iPlayer]
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

	g_faith = g_player:GetFaith()
	if g_faith < g_eaAction.FixedFaith then
		g_bSufficientFaith = false
	else
		g_bSufficientFaith = true
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
	--g_eaAction = EaActionsInfo[eaActionID]		--needed here in case function called directly by AI
	--print("TestEaSpellTarget",eaActionID, testX, testY, bAITargetTest)

	g_testTargetSwitch = 0
	g_bSomeoneElseDoingHere = false

	--Plot and city
	g_x, g_y = testX, testY
	g_iPlot = GetPlotIndexFromXY(testX, testY)

	--Action being done here (or GP on way for AI)? 
	if not g_eaAction.NoGPNumLimit then
		local plotTargeted = g_eaPlayer.actionPlotTargeted[eaActionID]
		if plotTargeted and plotTargeted[g_iPlot] and plotTargeted[g_iPlot] ~= g_iPerson then			--another AI GP is doing this here (or on way for AI)
			if g_bAIControl then
				print("TestEaSpellTarget returning false for AI becuase someone else has claimed this action at this plot")
				return false
			else
				g_bSomeoneElseDoingHere = true
				--will return false but delayed until below for human UI
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

	--set g_modSpell for Tower or Temple
	if g_eaAction.ConsiderTowerTemple then
		if gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson] and gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson].iPlot == g_iPlot then	--in tower
			g_modSpell = g_mod + gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson][GameInfoTypes[g_eaAction.GPModType1] ]		--Assume all spells have exactly one mod
			g_bInTowerOrTemple = true
		else		--not in tower
			if g_eaAction.TowerTempleOnly then return false end
			g_modSpell = g_mod
			g_bInTowerOrTemple = false
		end
	end

	if TestTarget[eaActionID] and not TestTarget[eaActionID]() then return false end

	if g_bSomeoneElseDoingHere then return false end	--after TestTarget so special human UI can be shown if needed

	--Caluculate turns to complete
	local turnsToComplete = g_eaAction.TurnsToComplete

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
		--Memory for AI specialization
		if g_eaAction.GPModType1 then
			local memValue = 2 ^ (g_gameTurn / MOD_MEMORY_HALFLIFE)
			local modID = GameInfoTypes[g_eaAction.GPModType1]
			g_eaPerson.modMemory[modID] = (g_eaPerson.modMemory[modID] or 0) + memValue
			if g_eaAction.GPModType2 then
				local modID = GameInfoTypes[g_eaAction.GPModType2]
				g_eaPerson.modMemory[modID] = (g_eaPerson.modMemory[modID] or 0) + memValue
			end
		end
	end

	if g_eaAction.StayInvisible then
		g_unit:SetInvisibleType(INVISIBLE_SUBMARINE)
	else 
		g_unit:SetInvisibleType(-1)
	end

	--effects on unit
	if g_eaAction.DoXP > 0 then
		g_unit:ChangeExperience(g_eaAction.DoXP)
	end
	if g_eaAction.DoGainPromotion then
		g_unit:SetHasPromotion(GameInfoTypes[g_eaAction.DoGainPromotion], true)
	end

	--Finish moves
	if g_eaAction.FinishMoves then
		g_unit:FinishMoves()
	end

	--Don't get stuck on unit with no moves
	if g_iPlayer == g_iActivePlayer then
		if UI.GetHeadSelectedUnit() and UI.GetHeadSelectedUnit():MovesLeft() == 0 then
			print("EaAction.lua forcing unit cycle")
			Game.CycleUnits(true, true, false)	--move on to next unit
		end
	end

	--Ongoing actions with turnsToComplete > 0 (DoEaSpell is called each turn of construction)
	local turnsToComplete = g_eaAction.TurnsToComplete
	
	--Reserve this action at this plot (will cause TestEaSpellTarget fail for other GPs)
	if 1 < turnsToComplete and not g_eaAction.NoGPNumLimit then
		g_eaPlayer.actionPlotTargeted[eaActionID] = g_eaPlayer.actionPlotTargeted[eaActionID] or {}
		g_eaPlayer.actionPlotTargeted[eaActionID][g_iPlot] = g_iPerson
	end

	if turnsToComplete == 1000 and g_bAIControl then turnsToComplete = 8 end	--AI will wake up and test other options
	if turnsToComplete == 1 then	--do it now!

		--Plot Float Up Text
		if not g_eaAction.NoFloatUpText or MapModData.bAutoplay then
			g_plot:AddFloatUpMessage(Locale.Lookup(g_eaAction.Description), 1)
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
			ClearActionPlotTargetedForPerson(g_eaPlayer, g_iPerson)
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
	ClearActionPlotTargetedForPerson(eaPlayer, iPerson)
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
	local unit = player:GetUnitByID(eaPlayer.iUnit)
	if unit and not unit:IsDelayedDeath() then						--Could be interrupt for death, so no unit
		unit:SetInvisibleType(INVISIBLE_SUBMARINE)
	end

	print("end of InterruptEaSpell")								
end

function TestSpellLearnable(iPlayer, iPerson, spellID, spellClass)		--iPerson = nil to generate civ list; spellClass is optional restriction (used for separate UI panels)
	
	if not SetAIValues[spellID] then return false end	--Not really added yet, even if in table
	
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
		if spellInfo.PantheismCult then return false end		--TO DO: Reactivate these!
		if eaPerson.spells[spellID] then return false end	--already known
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
		if spellInfo.LevelReq and eaPerson.level < spellInfo.LevelReq then return false end
		if spellInfo.PromotionReq and not eaPerson.promotions[GameInfoTypes[spellInfo.PromotionReq] ] then return false end
	end
	if spellInfo.ReqEaWonder and not gWonders[GameInfoTypes[spellInfo.ReqEaWonder] ] then return false end
	return true
end


------------------------------------------------------------------------------------------------------------------------------
-- Spells go here...!
------------------------------------------------------------------------------------------------------------------------------
--Note: spells skip over generic civ and caster prereqs: Test function won't be called
--Use TestTarget, SetUI, SetAIValues, Do (for 1 turn completion) and Finish (for >1 turn completion)

-- Model "Summon" spell

local EA_SPELL_CONJURE_MONSTER =			GameInfoTypes.EA_SPELL_CONJURE_MONSTER
local EA_SPELL_RAISE_DEAD =					GameInfoTypes.EA_SPELL_RAISE_DEAD
local EA_SPELL_SUMMON_ABYSSAL_CREATURES =	GameInfoTypes.EA_SPELL_SUMMON_ABYSSAL_CREATURES
local EA_SPELL_SUMMON_DEMON =				GameInfoTypes.EA_SPELL_SUMMON_DEMON
local EA_SPELL_CALL_HEAVENS_GUARD =			GameInfoTypes.EA_SPELL_CALL_HEAVENS_GUARD
local EA_SPELL_CALL_ANGEL =					GameInfoTypes.EA_SPELL_CALL_ANGEL
local EA_SPELL_CALL_ANIMALS =				GameInfoTypes.EA_SPELL_CALL_ANIMALS
local EA_SPELL_CALL_TREE_ENTS =				GameInfoTypes.EA_SPELL_CALL_TREE_ENTS

local monsters = {GameInfoTypes.UNIT_GIANT_SPIDER}
local undead = {GameInfoTypes.UNIT_ZOMBIES}
local abyssalCreatures = {GameInfoTypes.UNIT_HORMAGAUNT}
local demons = {GameInfoTypes.UNIT_LICTOR, GameInfoTypes.UNIT_HIVE_TYRANT}	--weakest first
local heavensGuard = {GameInfoTypes.UNIT_ANGEL_SPEARMAN}
local angels = {GameInfoTypes.UNIT_ANGEL}
local animals = {GameInfoTypes.UNIT_WOLVES, GameInfoTypes.UNIT_LIONS}	--weakest first
local treeEnts = {GameInfoTypes.UNIT_TREE_ENT}


local function ModelSummon_TestTarget()
	if g_faith < g_modSpell then
		g_testTargetSwitch = 1
		return false
	end

	local unitTable, numUnits
	local bLimitOneOnly = false
	g_int1 = g_eaAction.ID
	if g_int1 == EA_SPELL_CONJURE_MONSTER then
		unitTable = monsters
		numUnits = 1
		bLimitOneOnly = true
	elseif g_int1 == EA_SPELL_RAISE_DEAD then
		unitTable = undead
		numUnits = 1
	elseif g_int1 == EA_SPELL_SUMMON_ABYSSAL_CREATURES then
		unitTable = abyssalCreatures
		numUnits = 1
	elseif g_int1 == EA_SPELL_SUMMON_DEMON then
		unitTable = demons
		numUnits = 2
		bLimitOneOnly = true
	elseif g_int1 == EA_SPELL_CALL_HEAVENS_GUARD then
		unitTable = heavensGuard
		numUnits = 1
	elseif g_int1 == EA_SPELL_CALL_ANGEL then
		unitTable = angels
		numUnits = 1
		bLimitOneOnly = true
	elseif g_int1 == EA_SPELL_CALL_ANIMALS then
		unitTable = animals
		numUnits = 2
	elseif g_int1 == EA_SPELL_CALL_TREE_ENTS then
		unitTable = treeEnts
		numUnits = 1
	end

	--make our unit list here so we can share it with UI and AI
	g_count = 0		--number units can summon
	g_value = 0		--cumulative power of newly summoned units
	local remainingMod = g_modSpell
	local summonedUnits = g_eaPerson.summonedUnits
	local bHasSummonedUnit = false
	if summonedUnits then
		for iUnit, unitTypeID in pairs(summonedUnits) do
			for i = 1, numUnits do
				if unitTypeID == unitTable[i] then
					if bLimitOneOnly then
						g_testTargetSwitch = 2
						return false
					end
					bHasSummonedUnit = true		--if can't now, it's because there are already summoned units
					remainingMod = remainingMod - gg_normalizedUnitPower[unitTypeID]
				end
			end
		end
	end
	local weakestUnitPower = gg_normalizedUnitPower[unitTable[1] ]
	local i = numUnits		--start at strongest unit and work through backwards
	while weakestUnitPower < remainingMod do
		local unitTypeID = unitTable[i]
		local power = gg_normalizedUnitPower[unitTypeID]
		if power < remainingMod then	--add to list
			g_count = g_count + 1
			g_integers[g_count] = unitTypeID
			g_value = g_value + power
			if bLimitOneOnly then return true end	--done!
			remainingMod = remainingMod - power
		end
		i = i < 2 and i + numUnits - 1 or i - 1
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
	return true
end

local function ModelSummon_SetUI()
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
		--text for different spells
		local verb, verbCap, unitStr, unitPlurStr
		if g_int1 == EA_SPELL_CONJURE_MONSTER then
			verb, verbCap, unitStr, unitPlurStr = "conjure", "Conjure", "monster", "monsters"
		elseif g_int1 == EA_SPELL_RAISE_DEAD then
			verb, verbCap, unitStr, unitPlurStr = "raise", "Raise", "undead", "undead"
		elseif g_int1 == EA_SPELL_SUMMON_ABYSSAL_CREATURES then
			verb, verbCap, unitStr, unitPlurStr = "summon", "Summon", "Abyssal Creatures", "Abyssal Creatures"
		elseif g_int1 == EA_SPELL_SUMMON_DEMON then
			verb, verbCap, unitStr, unitPlurStr = "summon", "Summon", "Demon", "Demons"
		elseif g_int1 == EA_SPELL_CALL_HEAVENS_GUARD then
			verb, verbCap, unitStr, unitPlurStr = "call", "Call", "Heaven's Guard", "Heaven's Guard"
		elseif g_int1 == EA_SPELL_CALL_ANGEL then
			verb, verbCap, unitStr, unitPlurStr = "call", "Call", "Angel", "Angels"
		elseif g_int1 == EA_SPELL_CALL_ANIMALS then
			verb, verbCap, unitStr, unitPlurStr = "call", "Call", "animals", "animals"
		elseif g_int1 == EA_SPELL_CALL_TREE_ENTS then
			verb, verbCap, unitStr, unitPlurStr = "call", "Call", "Tree-Ent", "Tree-Ents"
		end

		if g_bAllTestsPassed then
			--count demon types for UI
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
			MapModData.text = verbCap .. " " .. str
		elseif g_testTargetSwitch == 1 then
			MapModData.text = "Not enough mana to cast this spell"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "You can only " .. verb .. " one unit with this spell"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "Not enough mana to " .. verb .. " additional " .. unitPlurStr
		elseif g_testTargetSwitch == 4 then
			MapModData.text = "Your current spell modifier (" .. g_modSpell .. ") is insufficient to " .. verb .. " any " .. unitStr .. " (power: " .. g_int2 .. ")"
		else
			MapModData.text = "You cannot cast this spell currently"	--why not?
		end
	end
end

local function ModelSummon_SetAIValues()
	gg_aiOptionValues.i = g_value		--AI should always want this maxed out
end

local function ModelSummon_Finish()
	g_eaPerson.summonedUnits = g_eaPerson.summonedUnits or {}
	local summonedUnits = g_eaPerson.summonedUnits
	local bOverStacked = false
	for i = 1, g_count do
		local unitTypeID = g_integers[i]
		local newUnit = g_player:InitUnit(unitTypeID, g_x, g_y)
		local iUnit = newUnit:GetID()
		summonedUnits[iUnit] = unitTypeID
		newUnit:SetSummonerIndex(g_iPerson)
		if bOverStacked then
			newUnit:JumpToNearestValidPlot()
		elseif g_plot:GetNumFriendlyUnitsOfType(newUnit) > 1 then
			bOverStacked = true
			newUnit:JumpToNearestValidPlot()
		end
	end
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_value, false)
end

--EA_SPELL_CONJURE_MONSTER
TestTarget[GameInfoTypes.EA_SPELL_CONJURE_MONSTER] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_CONJURE_MONSTER] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_CONJURE_MONSTER] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_CONJURE_MONSTER] = ModelSummon_Finish

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

--EA_SPELL_CALL_TREE_ENTS
TestTarget[GameInfoTypes.EA_SPELL_CALL_TREE_ENTS] = ModelSummon_TestTarget
SetUI[GameInfoTypes.EA_SPELL_CALL_TREE_ENTS] = ModelSummon_SetUI
SetAIValues[GameInfoTypes.EA_SPELL_CALL_TREE_ENTS] = ModelSummon_SetAIValues
Finish[GameInfoTypes.EA_SPELL_CALL_TREE_ENTS] = ModelSummon_Finish


--EA_SPELL_SCRYING
--EA_SPELL_SEEING_EYE_GLYPH
--EA_SPELL_DETECT_GLYPHS_RUNES_WARDS
--EA_SPELL_KNOW_WORLD
--EA_SPELL_DISPEL_HEXES
--EA_SPELL_DESPEL_GLYPHS_RUNES_WARDS
--EA_SPELL_DISPEL_ILLUSIONS
--EA_SPELL_BANISHMENT
--EA_SPELL_PROTECTIVE_WARD
--EA_SPELL_DISPEL_MAGIC
--EA_SPELL_TIME_STOP


--EA_SPELL_MAGIC_MISSILE
TestTarget[GameInfoTypes.EA_SPELL_MAGIC_MISSILE] = function()	--TO DO: need better AI targeting logic (for now, value goes up with existing damage)

	g_bool1 = g_faith < g_modSpell
	if g_bool1 then return false end
	local maxDamage = -1								--Any target makes valid, but AI will value based on current target damage
	for x, y in PlotToRadiusIterator(g_x, g_y, 2, nil, nil, true) do	--excludes center
		local plot = GetPlotFromXY(x, y)
		if plot:IsCity() then
			if g_team:IsAtWar(Players[plot:GetOwner()]:GetTeam()) then
				local damage = plot:GetPlotCity():GetDamage()
				if maxDamage < damage then	
					maxDamage = damage
					g_obj1 = plot
				end				
			end
		elseif plot:IsVisibleEnemyUnit(g_iPlayer) then
			local unitCount = plot:GetNumUnits()
			for i = 0, unitCount - 1 do
				local unit = plot:GetUnit(i)
				local unitTypeID = unit:GetUnitType()
				if gg_bNormalCombatUnit[unitTypeID] and g_team:IsAtWar(Players[unit:GetOwner()]:GetTeam()) then	--combat unit that we are at war with (need to cache at-war players for speed!)
					local damage = unit:GetDamage()
					if maxDamage < damage then	
						maxDamage = damage
						g_obj1 = plot
					end
				end
			end
		end
	end
	if maxDamage == -1 then return false end	--no targets found
	--if target found, then g_obj1 now holds plot for best potential target for AI
	g_value = 100 + maxDamage
	return true
end

SetUI[GameInfoTypes.EA_SPELL_MAGIC_MISSILE] = function()
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
		if g_bAllTestsPassed then
			MapModData.text = "Magic Missile attack (ranged strength " .. g_modSpell .. ")"
		else
			if g_bool1 then
				MapModData.text = "[COLOR_WARNING_TEXT]You do not have sufficent mana (requres " .. g_modSpell .. ")[ENDCOLOR]"
			else
				MapModData.text = "[COLOR_WARNING_TEXT]No valid target in range[ENDCOLOR]"
			end
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_MAGIC_MISSILE] = function()
	gg_aiOptionValues.i = g_value
end

Do[GameInfoTypes.EA_SPELL_MAGIC_MISSILE] = function()
	--convert to ranged unit 
	UpdateGreatPersonStatsFromUnit(g_unit, g_eaPerson)

	local direction = g_unit:GetFacingDirection()
	local newUnitTypeID = gpTempTypeUnits.MagicMissle[g_unit:GetUnitType()] or GameInfoTypes.UNIT_DRUID_MAGIC_MISSLE	--fallback to druid if we haven't added tempType unit yet

	local newUnit = g_player:InitUnit(newUnitTypeID, g_x, g_y, nil, direction)
	MapModData.bBypassOnCanSaveUnit = true
	newUnit:Convert(g_unit, false)
	newUnit:SetPersonIndex(g_iPerson)
	local iNewUnit = newUnit:GetID()
	g_eaPerson.iUnit = iNewUnit

	newUnit:SetMorale(g_modSpell * 10 - 100)	--Use morale to modify up or down from ranged strength 10 (can't change ranged strength)

	if g_bAIControl then		--Carry out attack
		newUnit:PushMission(MissionTypes.MISSION_RANGE_ATTACK, g_obj1:GetX(), g_obj1:GetY(), 0, 0, 1)
		if newUnit:MovesLeft() > 0  then
			error("AI GP has movement after Magic Missile! Did it not fire?")
		end
	elseif g_iPlayer == g_iActivePlayer then
		MapModData.forcedUnitSelection = iNewUnit
		MapModData.forcedInterfaceMode = InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK
		UI.SelectUnit(newUnit)
		UI.LookAtSelectionPlot(0)
	end

	return true
end

--EA_SPELL_EXPLOSIVE_RUNE
TestTarget[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNE] = function()
	if g_faith < g_modSpell then
		g_testTargetSwitch = 1
		return false
	end
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
		if g_bAllTestsPassed then
			MapModData.text = "Place Explosive Runes on this plot"
		elseif g_testTargetSwitch == 1 then
			MapModData.text = "[COLOR_WARNING_TEXT]You do not have sufficent mana (requres " .. g_modSpell .. ")[ENDCOLOR]"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]Your civilization has already placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]Another civilization has placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNE] = function()	--already restricted by AI heuristic; just value good defence plot
	gg_aiOptionValues.i = 10		--placeholder
end

Finish[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNE] = function()
	g_plot:SetPlotEffectData(GameInfoTypes.EA_PLOTEFFECT_EXPLOSIVE_RUNE, g_modSpell, g_iPlayer, g_iPerson)	--effectID, effectStength, iPlayer, iCaster
	UpdatePlotEffectHighlight(g_iPlot)
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, 1)
	return true
end

--EA_SPELL_MAGE_SWORD
--EA_SPELL_BREACH
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

		--random sector/direction, spiral in until valid plot found
		local sector = Rand(6, "hello") + 1
		local anticlock = Rand(2, "hello") == 0
		local maxRadius = g_modSpell < MAX_RANGE and g_modSpell or MAX_RANGE
		for radius = maxRadius, 1, -1 do	--test one full ring at a time (we test whole ring so AI can account for own plots in danger)
			g_obj1 = nil
			local ownPlotsInDanger, totalPlotsInDanger = 0, 0
			for plot in PlotRingIterator(g_plot, radius, sector, anticlock) do	
				if not (plot:IsWater() or plot:IsMountain() or plot:IsImpassable()) then
					local featureID = plot:GetFeatureType()
					if not (featureID == FEATURE_BLIGHT or featureID == FEATURE_FALLOUT) then
						if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE or featureID == FEATURE_MARSH then	--Must overpower any living terrain here (subtract range from mod)
							local terrainStrength = plot:GetLivingTerrainStrength()
							if g_modSpell - radius > terrainStrength then
								totalPlotsInDanger = totalPlotsInDanger + 1
								if plot:IsPlayerCityRadius(g_iPlayer) then
									ownPlotsInDanger = ownPlotsInDanger + 1
								end		
								g_int2 = terrainStrength		
								g_obj1 = plot
							end
						else
							totalPlotsInDanger = totalPlotsInDanger + 1
							if plot:IsPlayerCityRadius(g_iPlayer) then
								ownPlotsInDanger = ownPlotsInDanger + 1
							end	
							g_int2 = 0
							g_obj1 = plot
						end
					end
				end
			end
			if g_obj1 then
				g_int3 = radius
				g_int4 = ownPlotsInDanger
				g_int5 = totalPlotsInDanger
				return true
			else
				return false
			end
		end
	else	--Can this plot be blighted?
		if g_plot:IsWater() or g_plot:IsMountain() or g_plot:IsImpassable() then return false end	--IsImpassable protects Natural Wonders (unless they become passible) 
		local featureID = g_plot:GetFeatureType()
		if featureID == FEATURE_BLIGHT or featureID == FEATURE_FALLOUT then return false end
		if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE or featureID == FEATURE_MARSH then	--Must overpower any living terrain here
			g_int2 = g_plot:GetLivingTerrainStrength()
			if g_modSpell < g_int2 then
				return false
			end
		else
			g_int2 = 0	
		end
		g_obj1 = g_plot
		return true
	end
end

SetUI[GameInfoTypes.EA_SPELL_BLIGHT] = function()
	if g_bNonTargetTestsPassed then		--has spell so show it
		if g_bAllTestsPassed then
			if g_bInTowerOrTemple then
				MapModData.text = "Blight land at range " .. g_int3
			else
				if g_int2 > 0 then
					MapModData.text = "Blight this land (overcome terrain strength " .. g_int2 .. ")"
				else
					MapModData.text = "Blight this land"
				end
			end			
		else
			if g_bInTowerOrTemple then
				MapModData.text = "No land within the caster's " .. g_modSpell .. "-plot range can be blighted"
			else
				if g_testTargetSwitch == 1 then
					MapModData.text = "You cannot overcome this land's strength (" .. g_int2 .. ")"
				else
					MapModData.text = "This plot cannot be blighted"
				end
			end
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_BLIGHT] = function()
	if g_bInTowerOrTemple then
		gg_aiOptionValues.i = g_modSpell * (1 - g_int4 / g_int5)	-- deduct for proportion of possibly affected plots in own city's 3-plot radius
	elseif not g_plot:IsPlayerCityRadius(g_iPlayer) then
		gg_aiOptionValues.i = g_modSpell + g_int2	--prefer to kill strongest living terrain possible
	end		--no value if in our city's 3-plot radius
end

Finish[GameInfoTypes.EA_SPELL_BLIGHT] = function()
	g_specialEffectsPlot = g_obj1
	BlightPlot(g_obj1, g_iPlayer, g_iPerson)	--player doesn't lose mana, but gets credit for mana consummed
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
					if gg_bNormalCombatUnit[unitTypeID] then
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
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
--EA_SPELL_REANIMATE_DEAD


--EA_SPELL_DEATH_RUNE			(almost a copy of EA_SPELL_EXPLOSIVE_RUNE)
TestTarget[GameInfoTypes.EA_SPELL_DEATH_RUNE] = function()
	if g_faith < g_modSpell then
		g_testTargetSwitch = 1
		return false
	end
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
		if g_bAllTestsPassed then
			MapModData.text = "Place Explosive Runes on this plot"
		elseif g_testTargetSwitch == 1 then
			MapModData.text = "[COLOR_WARNING_TEXT]You do not have sufficent mana (requres " .. g_modSpell .. ")[ENDCOLOR]"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]Your civilization has already placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]Another civilization has placed a Glyph, Rune or Ward on this plot[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_SPELL_DEATH_RUNE] = function()	--already restricted by AI heuristic; just value good defence plot
	gg_aiOptionValues.i = 10		--placeholder
end

Finish[GameInfoTypes.EA_SPELL_DEATH_RUNE] = function()
	g_plot:SetPlotEffectData(GameInfoTypes.EA_PLOTEFFECT_DEATH_RUNE, g_modSpell, g_iPlayer, g_iPerson)	--effectID, effectStength, iPlayer, iCaster
	UpdatePlotEffectHighlight(g_iPlot)
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, 1)
	return true
end



--EA_SPELL_VAMPIRIC_TOUCH
--EA_SPELL_DEATH_STAY
--EA_SPELL_BECOME_LICH
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
			if gg_bNormalLivingCombatUnit[unitTypeID] then
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
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
					if gg_bNormalLivingCombatUnit[unitTypeID] then
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
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
					if gg_bNormalLivingCombatUnit[unitTypeID] then
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
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
				if gg_bNormalLivingCombatUnit[unitTypeID] then
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
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
					if gg_bNormalLivingCombatUnit[unitTypeID] then
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
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
					if gg_bNormalCombatUnit[unitTypeID] then
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
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
		g_int1 = g_modSpell < g_faith and g_modSpell or g_faith
		g_int2 = featureID
		return true
	end
	return false
end

SetUI[GameInfoTypes.EA_SPELL_EAS_BLESSING] = function()
	if g_bNonTargetTestsPassed then		--has spell so show it
		if g_bAllTestsPassed then
			local featureInfo = GameInfo.Features[g_int2]
			local featureName = Locale.ConvertTextKey(featureInfo.Description)
			MapModData.text = "Increase spreading and regeneration strength of " .. featureName .. " by " .. g_int1
		else
			MapModData.text = "Plot must be Living Terrain (Forest, Jungle or Marsh)"
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
	gg_aiOptionValues.i = g_int1 * (countCanSpreadAdj + 0.1) / (strength + 1)		--tiny positive even if it can't spread
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
	strength = strength + g_int1
	g_plot:SetLivingTerrainData(type, present, strength, turnChopped)
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_int1)
	g_eaPlayer.livingTerrainStrengthAdded = (g_eaPlayer.livingTerrainStrengthAdded or 0) + g_int1
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
	g_int1 = g_modSpell < g_faith and g_modSpell or g_faith
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
			MapModData.text = "Plot must be unimproved grass, plains or tundra next to existing forest or jungle"
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
	gg_aiOptionValues.i = g_int1 * countCanSpreadAdj 		--always better than Ea's Blessing
end

Finish[GameInfoTypes.EA_SPELL_BLOOM] = function()
	local type = g_bool1 and 1 or 2	--"forest" or "jungle"
	LivingTerrainGrowHere(g_iPlot, type)
	g_plot:SetLivingTerrainData(type, true, g_int1, -100)

	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_int1)
	g_eaPlayer.livingTerrainAdded = (g_eaPlayer.livingTerrainAdded or 0) + 1
	g_eaPlayer.livingTerrainStrengthAdded = (g_eaPlayer.livingTerrainStrengthAdded or 0) + g_int1
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
				if not unit:IsHasPromotion(PROMOTION_RIDE_LIKE_THE_WINDS) and not unit:IsHasPromotion(PROMOTION_EVIL_EYE) then
					local unitTypeID = unit:GetUnitType()	
					if gg_bNormalCombatUnit[unitTypeID] then
						local unitTypeInfo = GameInfo.Units[unitTypeID]
						numQualifiedUnits = numQualifiedUnits + 1
						g_table[numQualifiedUnits] = unit
						value = value + unit:GetPower()
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
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
	local healHP = Floor(pts * 0.667)
	local bestValue = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if unit:GetOwner() == g_iPlayer then	
				local unitTypeID = unit:GetUnitType()	
				if gg_bNormalLivingCombatUnit[unitTypeID] then
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
		if g_bAllTestsPassed then
			local unitTypeInfo = GameInfo.Units[g_obj1:GetUnitType()]
			local unitText = Locale.ConvertTextKey(unitTypeInfo.Description)
			--recalculate what we need as above
			local pts = g_modSpell < g_faith and g_modSpell or g_faith
			local healHP = Floor(pts * 0.667)
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
	local healHP = Floor(pts * 0.667)
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
			if unit:GetDomainType() == DOMAIN_SEA and unit:GetOwner() == g_iPlayer then
				if not unit:IsHasPromotion(PROMOTION_FAIR_WINDS) then
					local unitTypeID = unit:GetUnitType()	
					if gg_bNormalCombatUnit[unitTypeID] then
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
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
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
		if g_bAllTestsPassed then
			local pts = Floor(g_modSpell / 2)
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
	local pts = Floor(g_modSpell / 2)
	pts = pts < g_int1 and pts or g_int1
	gg_aiOptionValues.b = pts
end

Do[GameInfoTypes.EA_SPELL_REVELRY] = function()
	local pts = Floor(g_modSpell / 2)
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

