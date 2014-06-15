-- EaActions
-- Author: Pazyryk
-- DateCreated: 1/31/2012 8:44:45 PM
--------------------------------------------------------------
print("Loading EaActions.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end


---------------------------------------------------------------
-- Local defines
---------------------------------------------------------------

--constants
local BUILDING_LIBRARY =					GameInfoTypes.BUILDING_LIBRARY
local BUILDING_TRADE_HOUSE =				GameInfoTypes.BUILDING_TRADE_HOUSE
local DOMAIN_LAND =							DomainTypes.DOMAIN_LAND
local DOMAIN_SEA =							DomainTypes.DOMAIN_SEA
local EA_ACTION_GO_TO_PLOT =				GameInfoTypes.EA_ACTION_GO_TO_PLOT
local EA_WONDER_ARCANE_TOWER =				GameInfoTypes.EA_WONDER_ARCANE_TOWER
local EACIV_NEZELIBA =						GameInfoTypes.EACIV_NEZELIBA
local IMPROVEMENT_ARCANE_TOWER =			GameInfoTypes.IMPROVEMENT_ARCANE_TOWER
local INVISIBLE_SUBMARINE =					GameInfoTypes.INVISIBLE_SUBMARINE
local LEADER_FAND =							GameInfoTypes.LEADER_FAND
local RELIGION_ANRA =						GameInfoTypes.RELIGION_ANRA
local RELIGION_AZZANDARAYASNA =				GameInfoTypes.RELIGION_AZZANDARAYASNA
local RELIGION_THE_WEAVE_OF_EA =			GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
local TECH_MALEFICIUM =						GameInfoTypes.TECH_MALEFICIUM
local UNITCOMBAT_MOUNTED =					GameInfoTypes.UNITCOMBAT_MOUNTED
local YIELD_CULTURE = 						GameInfoTypes.YIELD_CULTURE
local YIELD_FAITH = 						GameInfoTypes.YIELD_FAITH
local YIELD_GOLD = 							GameInfoTypes.YIELD_GOLD
local YIELD_PRODUCTION =					GameInfoTypes.YIELD_PRODUCTION
local YIELD_SCIENCE = 						GameInfoTypes.YIELD_SCIENCE

local MAX_MAJOR_CIVS =						GameDefines.MAX_MAJOR_CIVS
local ENEMY_HEAL_RATE =						GameDefines.ENEMY_HEAL_RATE
local NEUTRAL_HEAL_RATE =					GameDefines.NEUTRAL_HEAL_RATE
local FRIENDLY_HEAL_RATE =					GameDefines.FRIENDLY_HEAL_RATE

local UNIT_SUFFIXES =						UNIT_SUFFIXES
local NUM_UNIT_SUFFIXES =					#UNIT_SUFFIXES
local MOD_MEMORY_HALFLIFE =					MOD_MEMORY_HALFLIFE
local FIRST_SPELL_ID =						FIRST_SPELL_ID

--global tables
local GameInfoTypes =						GameInfoTypes
local MapModData =							MapModData
local fullCivs =							MapModData.fullCivs
local bFullCivAI =							MapModData.bFullCivAI
local gpRegisteredActions =					MapModData.gpRegisteredActions
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
local gg_minorPlayerByTypeID =				gg_minorPlayerByTypeID
local gg_playerPlotActionTargeted =			gg_playerPlotActionTargeted

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
local Turns = {}	--only tested if TurnsToComplete == nil

--file control
--	All applicable are calculated in TestEaAction any time we are in this file. Never change anywhere else!
--  Non-applicable variables will hold value from last call
local g_eaAction
local g_eaActionID
local g_bAIControl				--for AI control of unit (can be true for human if Autoplay)
local g_iActivePlayer = Game.GetActivePlayer()

local g_gameTurn = 0

local g_iPlayer
local g_eaPlayer
local g_player
local g_iTeam
local g_team
--local g_faith

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

local g_bInTowerOrTemple			--set only if g_eaAction.ConsiderTowerTemple

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

local EaActionsInfo = {}			-- Contains the entire table for speed (id < FIRST_SPELL_ID)
local cultRitualReligions = {}
for row in GameInfo.EaActions() do
	local id = row.ID
	if id < FIRST_SPELL_ID then
		EaActionsInfo[id] = row
		if row.FoundsSpreadsCult then
			cultRitualReligions[id] = GameInfoTypes[row.FoundsSpreadsCult]
		end
	end
end

---------------------------------------------------------------
-- Init
---------------------------------------------------------------

function EaActionsInit(bNewGame)
	for iPlayer, eaPlayer in pairs(fullCivs) do
		gg_playerPlotActionTargeted[iPlayer] = {}
	end
	for iPerson, eaPerson in pairs(gPeople) do
		local iPlayer = eaPerson.iPlayer
		if eaPerson.eaActionID > 0 then	
			local player = Players[iPlayer]
			local unit = player:GetUnitByID(eaPerson.iUnit)
			local iPlot = unit:GetPlot():GetPlotIndex()
			print("-setting gg_playerPlotActionTargeted for eaActionID ", iPlayer, iPlot, eaPerson.eaActionID, iPerson)
			gg_playerPlotActionTargeted[iPlayer][iPlot] = gg_playerPlotActionTargeted[iPlayer][iPlot] or {}
			gg_playerPlotActionTargeted[iPlayer][iPlot][eaPerson.eaActionID] = iPerson
		elseif eaPerson.gotoEaActionID > 0 then		--AI going to do something
			local gotoPlotIndex = eaPerson.gotoPlotIndex
			print("-setting gg_playerPlotActionTargeted for gotoEaActionID ", iPlayer, gotoPlotIndex, eaPerson.gotoEaActionID, iPerson)
			gg_playerPlotActionTargeted[iPlayer][gotoPlotIndex] = gg_playerPlotActionTargeted[iPlayer][gotoPlotIndex] or {}
			gg_playerPlotActionTargeted[iPlayer][gotoPlotIndex][eaPerson.gotoEaActionID] = iPerson
		end
		if iPerson > 0 then
			RegisterGPActions(iPerson)
		end
	end
end

---------------------------------------------------------------
-- Register GP actions (for classes, subclass or other things that don't usually change)
---------------------------------------------------------------

function RegisterGPActions(iPerson)
	print("RegisterGPActions ", iPerson)
	local eaPerson = gPeople[iPerson]
	local class1 = eaPerson.class1
	local class2 = eaPerson.class2
	local subclass = eaPerson.subclass
	print(class1, class2, subclass)
	gpRegisteredActions[iPerson] = {}
	local actions = gpRegisteredActions[iPerson]
	local number = 1
	for id = FIRST_GP_ACTION, FIRST_SPELL_ID - 1 do
		local eaAction = EaActionsInfo[id]
		if not eaAction.GPSubclass or eaAction.GPSubclass == subclass then
			if not eaAction.GPClass or eaAction.GPClass == class1 or eaAction.GPClass == class2 or (eaAction.OrGPClass and (eaAction.OrGPClass == class1 or eaAction.OrGPClass == class2)) then
				if not eaAction.ExcludeGPSubclass or eaAction.ExcludeGPSubclass ~= subclass then
					if not eaAction.NotGPClass or (eaAction.NotGPClass ~= class1 and eaAction.NotGPClass ~= class1) then
						actions[number] = id
						number = number + 1
					end
				end
			end
		end
	end
	print(#gpRegisteredActions[iPerson])
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

setmetatable(discountRateTable, OutOfRangeReturnZeroMetaTable)
setmetatable(discountCombatRateTable, OutOfRangeReturnZeroMetaTable)

--local function TimeDiscount(t, i, p, b)		--Not used currently
--	local numerator = b + discountRateTable[t - 1] * (i + p - discountRateTable[1] * (i + b))
--	if numerator < 0 then return 0 end
--	local denominator = 1 - discountRateTable[t]
--	return numerator / denominator
--end

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

local function FinishEaAction(eaActionID)		--only called from DoEaAction so file locals already set
	print("FinishEaAction", g_iPlayer, g_eaAction.Type)

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

	--Pantheism cult found or spread
	local cultType = g_eaAction.FoundsSpreadsCult
	if cultType then
		local cultID = GameInfoTypes[cultType]
		--if not g_eaPerson.cult then		--join and learn free spell the first time
		--	g_eaPerson.cult = cultID
			local freeSpellType = GameInfo.Religions[cultID].EaFreeCultSpell
			if freeSpellType then
				local spells = g_eaPerson.spells
				local numSpells = #spells
				local bLearnFreeSpell = true
				for i = 1, #numSpells do
					if spells[i] == spellID then	--already known
						bLearnFreeSpell = false
						break
					end	
				end
				if bLearnFreeSpell then
					spells[#numSpells + 1] = GameInfoTypes[freeSpellType]
				end
			end
		--end
		if gReligions[cultID] then		--already founded
			for i = -1, HIGHEST_RELIGION_ID do
				if g_tablePointer[i] > 0 then
					--need percentage (round up or down???)
					local convertPercent = Floor(1 + 100 * g_tablePointer[i] / g_city:GetNumFollowers(i))
					g_city:ConvertPercentFollowers(cultID, i, convertPercent)
				end
			end
		else
			FoundReligion(g_iPlayer, g_iCity, cultID)
			g_city:ConvertPercentFollowers(cultID, RELIGION_THE_WEAVE_OF_EA, 100)

		end
		UpdateCivReligion(g_iOwner)
	end

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

	if g_eaAction.EaWonder then		--Single -instance wonders only! Multiple-instance must be done in special function
		local wonderID = GameInfoTypes[g_eaAction.EaWonder]
		gWonders[wonderID] = {mod = g_mod, iPlot = g_iPlot, iPlayer = -1}	--iPlayer = -1 so it will update in UpdateUniqueWonder
		if g_eaAction.BuildsTemple then
			g_eaPerson.templeID = wonderID
			local temple = gWonders[wonderID]
			temple.iPerson = g_iPerson
			local wonderInfo = GameInfo.EaWonders[wonderID]
			temple.mod = wonderInfo.Mod
			temple[GameInfoTypes.EAMOD_DEVOTION] = wonderInfo.Devotion
			temple[GameInfoTypes.EAMOD_DIVINATION] = wonderInfo.Divi
			temple[GameInfoTypes.EAMOD_ABJURATION] = wonderInfo.Abju
			temple[GameInfoTypes.EAMOD_EVOCATION] = wonderInfo.Evoc
			temple[GameInfoTypes.EAMOD_TRANSMUTATION] = wonderInfo.Trans
			temple[GameInfoTypes.EAMOD_CONJURATION] = wonderInfo.Conj
			temple[GameInfoTypes.EAMOD_NECROMANCY] = wonderInfo.Necr
			temple[GameInfoTypes.EAMOD_ENCHANTMENT] = wonderInfo.Ench
			temple[GameInfoTypes.EAMOD_ILLUSION] = wonderInfo.Illu
		end
		UpdateUniqueWonder(g_iPlayer, wonderID)		--updates ownership, sets appropriate buildings in nearby city, and other effects
		--TO DO! need popup or notification
		--LuaEvents.EaImagePopupSpecial("EaWonder", artifactID)

	elseif g_eaAction.EaEpic then
		local epicID = GameInfoTypes[g_eaAction.EaEpic]
		gEpics[epicID] = {mod = g_mod, iPlayer = g_iPlayer}
		--TO DO! need popup or notification
		--LuaEvents.EaImagePopupSpecial("EaEpic", artifactID)
		--DEPRECIATE: g_eaPlayer.epicList[#g_eaPlayer.epicList + 1] = epicID

	elseif g_eaAction.EaArtifact then
		local artifactID = GameInfoTypes[g_eaAction.EaArtifact]
		gArtifacts[artifactID] = {mod = g_mod, iPlayer = -1, locationType = "iPlot", locationIndex = g_iPlot}	--iPlayer is -1 here so it will properly update in EaArtifacts.lua
		--TO DO! need popup or notification
		--Events.AudioPlay2DSound("AS2D_INTERFACE_NEW_ERA")
		--LuaEvents.EaImagePopupSpecial("EaArtifact", artifactID)
		--DEPRECIATE: g_eaPlayer.itemList[#g_eaPlayer.itemList + 1] = artifactID
		UpdateArtifact(artifactID)	--will figure out new owner from location and run any artifact specific "gain" effect

	end

	if g_eaAction.UniqueType then							--make NOT available permanently for any GP
		if g_eaAction.UniqueType == "World" then
			gWorldUniqueAction[eaActionID] = -1
		elseif g_eaAction.UniqueType == "National" then
			g_eaPlayer.nationalUniqueAction[eaActionID] = -1
		end
	end

	if g_eaAction.MeetGod then
		local iGod = gg_minorPlayerByTypeID[GameInfoTypes[g_eaAction.MeetGod] ]
		local god = Players[iGod]
		local iGodTeam = god:GetTeam()
		if not g_team:IsHasMet(iGodTeam) then
			g_team:Meet(iGodTeam, true)
		end
		--friendship boost for temple
		god:ChangeMinorCivFriendshipWithMajor(g_iPlayer, 100)
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

function TestEaActionForHumanUI(eaActionID, iPlayer, unit, iPerson, testX, testY)	--called from UnitPanel
	Dprint("TestEaActionForHumanUI ", eaActionID, iPlayer, unit, iPerson, testX, testY)
	--	MapModData.bShow	--> "Show" this button in UI.
	--	MapModData.bAllow	--> "Can do" (always equals Test return)
	--	MapModData.text	--> Displayed text when boolean1 = true (will display in red if boolean2 = false)
	g_bUICall = true
	g_bUniqueBlocked = false
	
	g_bAllTestsPassed = TestEaAction(eaActionID, iPlayer, unit, iPerson, testX, testY, false)
	MapModData.bAllow = g_bAllTestsPassed and not g_bSetDelayedFailForUI
	MapModData.bShow = g_bAllTestsPassed --or (g_bNonTargetTestsPassed and g_eaAction.UIType == "Build")	--may change below
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

	if g_eaAction.UnitUpgradeTypePrefix then
		if g_bAllTestsPassed then
			MapModData.bShow = true
			local upgradeUnitInfo = GameInfo.Units[g_int1]
			MapModData.text = "Upgrade the unit to " .. Locale.ConvertTextKey(upgradeUnitInfo.Description) .. ". This requires " .. g_int2 .. " [ICON_GOLD] Gold."
			if g_bSetDelayedFailForUI then
				if g_eaAction.LevelReq and g_unit:GetLevel() < g_eaAction.LevelReq then
					MapModData.text = MapModData.text .. "[NEWLINE][NEWLINE][COLOR_WARNING_TEXT]Your unit must be level " .. g_eaAction.LevelReq .. " or greater to upgrade.[ENDCOLOR]"
				end
				if g_iOwner ~= g_iPlayer then
					MapModData.text = MapModData.text .. "[NEWLINE][NEWLINE][COLOR_WARNING_TEXT]Your unit must be in friendly territory to upgrade.[ENDCOLOR]"
				end
				if g_player:GetGold() < g_int2 then
					MapModData.text = MapModData.text .. "[NEWLINE][NEWLINE][COLOR_WARNING_TEXT]You lack the necessary funds to upgrade this Unit.[ENDCOLOR]"
				end
				local resourceNeededTxt = ""
				for row in GameInfo.Unit_ResourceQuantityRequirements("UnitType = '" .. upgradeUnitInfo.Type .. "'") do
					local resourceInfo = GameInfo.Resources[row.ResourceType]
					if g_player:GetNumResourceAvailable(resourceInfo.ID) < 1 then
						if resourceNeededTxt ~= "" then
							resourceNeededTxt = resourceNeededTxt .. ","
						end
						resourceNeededTxt = resourceNeededTxt .. " 1 " .. resourceInfo.IconString .. " " .. Locale.ConvertTextKey(resourceInfo.Description)
					end
				end
				if resourceNeededTxt ~= "" then
					MapModData.text = MapModData.text .. "[NEWLINE][NEWLINE][COLOR_WARNING_TEXT]You need" .. resourceNeededTxt .. " to upgrade this Unit."
				end
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
--LuaEvents.EaActionsTestEaActionForHumanUI.Add(TestEaActionForHumanUI)
LuaEvents.EaActionsTestEaActionForHumanUI.Add(function(eaActionID, iPlayer, unit, iPerson, testX, testY) return HandleError61(TestEaActionForHumanUI, eaActionID, iPlayer, unit, iPerson, testX, testY) end)

function TestEaAction(eaActionID, iPlayer, unit, iPerson, testX, testY, bAINonTargetTest)
	--This function sets all file locals related to iPlayer and iPerson 
	--iPerson must have value if this is a great person
	--unit must be non-nil EXCEPT if this is a GP not on map
	g_eaAction = EaActionsInfo[eaActionID]
	g_eaActionID = g_eaAction.ID
	g_gameTurn = Game.GetGameTurn()
	
	--print("TestEaAction", eaActionID, iPlayer, unit, iPerson, testX, testY, bAINonTargetTest)
	--print("TestEaAction", g_eaAction.Type, iPlayer, unit, iPerson, testX, testY, bAINonTargetTest)

	g_bNonTargetTestsPassed = false
	g_testTargetSwitch = 0

	if g_eaAction.SpellClass then
		error("TestEaAction g_eaAction had a SpellClass")
	end

	if g_eaAction.ReqEaWonder and not gWonders[GameInfoTypes[g_eaAction.ReqEaWonder] ] then return false end
	if g_eaAction.ReligionNotFounded and gReligions[GameInfoTypes[g_eaAction.ReligionNotFounded] ] then return false end
	if g_eaAction.ReligionFounded and not gReligions[GameInfoTypes[g_eaAction.ReligionFounded] ] then return false end
	if g_eaAction.MaleficiumLearnedByAnyone and gWorld.maleficium ~= "Learned" then return false end

	if g_eaAction.MeetGod and not gg_minorPlayerByTypeID[GameInfoTypes[g_eaAction.MeetGod] ] then return false end	--god not in this game

	--print("pass a")

	g_eaPlayer = gPlayers[iPlayer]
	if g_eaAction.ExcludeFallen and g_eaPlayer.bIsFallen then return false end
	if g_eaAction.CivReligion and g_eaPlayer.religionID ~= GameInfoTypes[g_eaAction.CivReligion] then return false end

	g_player = Players[iPlayer]
	if g_eaAction.PolicyReq and not g_player:HasPolicy(GameInfoTypes[g_eaAction.PolicyReq]) and (not g_eaAction.OrPolicyReq or not g_player:HasPolicy(GameInfoTypes[g_eaAction.OrPolicyReq])) then return false end
	g_iTeam = g_player:GetTeam()
	g_team = Teams[g_iTeam]	
	if g_eaAction.TechReq then
		if not (g_eaAction.PolicyTrumpsTechReq and g_player:HasPolicy(GameInfoTypes[g_eaAction.PolicyTrumpsTechReq])) then
			if not g_team:IsHasTech(GameInfoTypes[g_eaAction.TechReq]) then
				if not g_eaAction.OrTechReq or not g_team:IsHasTech(GameInfoTypes[g_eaAction.OrTechReq]) then return false end
			end
			if g_eaAction.AndTechReq and not g_team:IsHasTech(GameInfoTypes[g_eaAction.AndTechReq]) then return false end
		end
	end
	if g_eaAction.TechDisallow and g_team:IsHasTech(GameInfoTypes[g_eaAction.TechDisallow]) then return false end

	--print("pass b")

	g_iPlayer = iPlayer

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

	--print("pass c")

	if g_eaAction.LevelReq and unit:GetLevel() < g_eaAction.LevelReq then
		if g_bUICall and g_eaAction.UnitUpgradeTypePrefix then
			g_bSetDelayedFailForUI = true
		else
			return false
		end
	end
	if g_eaAction.PromotionReq and not unit:IsHasPromotion(GameInfoTypes[g_eaAction.PromotionReq]) then return false end
	if g_eaAction.PromotionDisallow then
		if unit:IsHasPromotion(GameInfoTypes[g_eaAction.PromotionDisallow]) then return false end
		if g_eaAction.PromotionDisallow2 and unit:IsHasPromotion(GameInfoTypes[g_eaAction.PromotionDisallow2]) then return false end
		if g_eaAction.PromotionDisallow3 and unit:IsHasPromotion(GameInfoTypes[g_eaAction.PromotionDisallow3]) then return false end
	end
	if g_eaAction.UnitCombatType and GameInfoTypes[g_eaAction.UnitCombatType] ~= unit:GetUnitCombatType() then return false end
	if g_eaAction.NormalCombatUnit and (g_bGreatPerson or unit:GetUnitCombatType() == -1) then return false end
	
	--print("pass d")
			
	if g_eaAction.UnitTypePrefix1 then
		local bAllow = false
		for i = 1, NUM_UNIT_SUFFIXES do
			local suffix = UNIT_SUFFIXES[i]
			if GameInfoTypes[g_eaAction.UnitTypePrefix1 .. suffix] == g_unitTypeID then
				bAllow = true
				break
			elseif g_eaAction.UnitTypePrefix2 then
				if GameInfoTypes[g_eaAction.UnitTypePrefix2 .. suffix] == g_unitTypeID then
					bAllow = true
					break
				elseif g_eaAction.UnitTypePrefix3 then
					if GameInfoTypes[g_eaAction.UnitTypePrefix3 .. suffix] == g_unitTypeID then
						bAllow = true
						break
					end
				end					
			end
		end
		if not bAllow then return false end
	end

	if g_eaAction.UnitType and GameInfoTypes[g_eaAction.UnitType] ~= g_unitTypeID 
		and (not g_eaAction.OrUnitType or GameInfoTypes[g_eaAction.OrUnitType] ~= g_unitTypeID)
		and (not g_eaAction.OrUnitType2 or GameInfoTypes[g_eaAction.OrUnitType2] ~= g_unitTypeID) then return false end

	--print("pass e")

	--GP only
	if g_bGreatPerson then
		--all tests here are now in RegisterGPActions 
		g_subclass = g_eaPerson.subclass
		g_class1 = g_eaPerson.class1
		g_class2 = g_eaPerson.class2	--nil unless dual-class GP
	elseif g_eaAction.GPOnly then
		return false
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

	--print("pass g")

	--Specific action test (runs if it exists)
	if Test[eaActionID] and not Test[eaActionID]() then return false end

	--print("pass h")

	--All non-target tests have passed
	g_bNonTargetTestsPassed = true

	if not bAINonTargetTest then
		if not testX then
			testX, testY = g_unitX, g_unitY
		end
		if not TestEaActionTarget(eaActionID, testX, testY, false) then return false end
	end

	return true	
end					

function TestEaActionTarget(eaActionID, testX, testY, bAITargetTest)
	--This function sets all file locals related to the target plot
	--AI can call this directly but ONLY after a call to TestEaAction so that civ/caster file locals are correct

	--print("TestEaActionTarget",eaActionID, testX, testY, bAITargetTest)

	g_testTargetSwitch = 0
	g_bSomeoneElseDoingHere = false

	--Plot and city
	g_x, g_y = testX, testY
	g_iPlot = GetPlotIndexFromXY(testX, testY)

	--print("pass i")

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
			if targetPlotActions[eaActionID] and targetPlotActions[eaActionID] ~= g_iPerson then
				bBlock = true
			elseif g_eaAction.ImprovementType then		--any improvement blocks any other improvement
				for loopEaActionID, loopPersonIndex in pairs(targetPlotActions) do
					if loopEaActionID < FIRST_SPELL_ID and EaActionsInfo[loopEaActionID].ImprovementType and loopPersonIndex ~= g_iPerson then
						bBlock = true
						break
					end
				end
			end
			if bBlock then			--another AI GP is doing this or building improvement here (or on way for AI)
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

	--TO DO: if g_eaAction.ImprovementType then make sure no one else is building anything here

	--print("pass j")

	g_plot = GetPlotFromXY(testX, testY)
	if g_eaAction.BuildType and not g_plot:CanBuild(GameInfoTypes[g_eaAction.BuildType], g_iPlayer) then return false end
	g_iOwner = g_plot:GetOwner()

	if g_eaAction.OwnCityRadius then
		if not g_plot:IsPlayerCityRadius(g_iPlayer) then return false end
		--print("pass k")
		if g_eaAction.ReqNearbyCityReligion then
			if g_iOwner == g_iPlayer then
				local iCity = g_plot:GetCityPurchaseID()
				local city = g_player:GetCityByID(iCity)
				if city:GetReligiousMajority() ~= GameInfoTypes[g_eaAction.ReqNearbyCityReligion] then return false end
			else	--does any player city in radius have religion (faster to iterate cities or plots?)
				local religionID = GameInfoTypes[g_eaAction.ReqNearbyCityReligion]
				local bNoCity = true
				--print("pass l")
				for city in g_player:Cities() do
					if city:GetReligiousMajority() == religionID and PlotDistance(g_x, g_y, city:GetX(), city:GetY()) < 4 then
						bNoCity = false
						break
					end
				end
				if bNoCity then return false end
				--print("pass m")
			end
		end
	end

	--print("pass n")

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

	--print("pass o")

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

	--print("pass p")

	--Alt unit upgrades (we can set some file locals here to pass to human UI or other specific methods; these values could be changed in specific TestTarget method)
	if g_eaAction.UnitUpgradeTypePrefix then
		local unitInfo = GameInfo.Units[g_unitTypeID]
		local raceType = unitInfo.EaRace
		local upgradeUnitType = g_eaAction.UnitUpgradeTypePrefix
		if raceType == "EARACE_MAN" then
			upgradeUnitType = upgradeUnitType .. "_MAN"
		elseif raceType == "EARACE_SIDHE" then
			upgradeUnitType = upgradeUnitType .. "_SIDHE"
		elseif raceType == "EARACE_ORC" then
			upgradeUnitType = upgradeUnitType .. "_ORC"
		end
		g_int1 = GameInfoTypes[upgradeUnitType]	--upgrade unitID
		if not g_int1 then return false end
		g_int2 = g_unit:UpgradePrice(g_int1)	--upgrade cost
		if g_player:GetGold() < g_int2 then
			if g_bUICall then
				g_bSetDelayedFailForUI = true
			else
				return false
			end
		end
		for row in GameInfo.Unit_ResourceQuantityRequirements("UnitType = '" .. upgradeUnitType .. "'") do
			if g_player:GetNumResourceAvailable(GameInfoTypes[row.ResourceType]) < 1 then
				if g_bUICall then
					g_bSetDelayedFailForUI = true
				else
					return false
				end
			end
		end
	end

	--print("pass q")

	if TestTarget[eaActionID] and not TestTarget[eaActionID]() then return false end

	if g_bSomeoneElseDoingHere then return false end	--after TestTarget so special human UI can be shown if needed

	--print("pass r")

	--Tower/Temple test (stripped down version of EaSpells test used only for Learn Spell now)
	if g_eaAction.ConsiderTowerTemple then
		if gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson] then		--has tower
			if gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson].iPlot == g_iPlot then	--in tower
				g_bInTowerOrTemple = true
			else	--not in tower
				if g_eaAction.TowerTempleOnly then return false end
				g_bInTowerOrTemple = false
			end
		elseif g_eaPerson.templeID and gWonders[g_eaPerson.templeID].iPlot == g_iPlot then		--has temple and is in it
			g_bInTowerOrTemple = true
		else	
			if g_eaAction.TowerTempleOnly then return false end
			g_bInTowerOrTemple = false
		end
	else
		g_bInTowerOrTemple = false
	end

	--Caluculate turns to complete
	local turnsToComplete = g_eaAction.TurnsToComplete
	if not turnsToComplete then
		turnsToComplete = Turns[eaActionID]()
		g_eaPerson.turnsToComplete = turnsToComplete
	end

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

local function DoEaActionFromOtherState(eaActionID, iPlayer, unit, iPerson, targetX, targetY)	--UnitPanel.lua or WorldView.lua
	print("DoEaActionFromOtherState ", eaActionID, iPlayer, unit, iPerson, targetX, targetY)
	MapModData.bSuccess = DoEaAction(eaActionID, iPlayer, unit, iPerson, targetX, targetY)
end
LuaEvents.EaActionsDoEaActionFromOtherState.Add(function(eaActionID, iPlayer, unit, iPerson, targetX, targetY) return HandleError61(DoEaActionFromOtherState, eaActionID, iPlayer, unit, iPerson, targetX, targetY) end)

function DoEaAction(eaActionID, iPlayer, unit, iPerson, targetX, targetY)
	print("DoEaAction before test ", eaActionID, iPlayer, unit, iPerson, targetX, targetY)

	if eaActionID == 0 then		--special go to plot function; just do or fail and skip the rest of this method
		unit:SetInvisibleType(INVISIBLE_SUBMARINE)
		return DoGotoPlot(iPlayer, unit, iPerson, targetX, targetY) 	--if targetX, Y == nil, then destination is from eaPerson.gotoPlotIndex
	end

	local bTest = TestEaAction(eaActionID, iPlayer, unit, iPerson, targetX, targetY, false)	--this will set all file variables we need
	print("DoEaAction after test ", g_eaAction.Type, iPlayer, unit, iPerson, targetX, targetY, bTest)

	if g_bGreatPerson then
		g_eaPerson.gotoPlotIndex = -1	
		g_eaPerson.gotoEaActionID = -1	
		if g_eaPerson.eaActionID ~= -1 and g_eaPerson.eaActionID ~= eaActionID then					--GP had a previous action that needs to be interrupted
			InterruptEaAction(iPlayer, iPerson)
		elseif not bTest and g_eaPerson.eaActionID == eaActionID then								--this was an ongoing action that needs to be interrupted
			InterruptEaAction(iPlayer, iPerson)
			--ReappearGP(iPlayer, iPerson)
		end
	end
	if not bTest then return false end	--action cannot be done for some reason; GP will reappear for instructions (human or AI)

	--add generic table tag effects here

	if Do[eaActionID] then
		if not Do[eaActionID]() then	--this is the call to action-specific Do function if it exists
			print("!!!! Warning: TestEaAction said OK but action specific Do function did not return a true value")
			InterruptEaAction(iPlayer, g_iPerson)
			return false		--Warning! AI might go into infinite loop if Test keeps passing true (fail from Do only possible for DoMoveToPlot at this time)
		end
	end

	if g_bGreatPerson then
		--memory for AI specialization
		if g_eaAction.GPModType1 then
			if g_eaAction.GPModType1 ~= "EAMOD_LEADERSHIP" then
				local memValue = 2 ^ (g_gameTurn / MOD_MEMORY_HALFLIFE)
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

	--Alt unit upgrades
	if g_eaAction.UnitUpgradeTypePrefix then
		local newUnit = g_player:InitUnit(g_int1, g_x, g_y)
		MapModData.bBypassOnCanSaveUnit = true
		newUnit:Convert(g_unit, true)
		g_unit = newUnit		--this will finish moves below; watch out because g_unitTypeID is no longer correct
		g_player:ChangeGold(-g_int2)
	end

	--Effects on unit
	if g_eaAction.DoXP > 0 then
		g_unit:ChangeExperience(g_eaAction.DoXP)
	end
	if g_eaAction.DoGainPromotion then
		g_unit:SetHasPromotion(GameInfoTypes[g_eaAction.DoGainPromotion], true)
	end

	--Finish moves
	if g_eaAction.FinishMoves and g_unit then
		g_unit:FinishMoves()
	end

	--Don't get stuck on unit with no moves
	if g_iPlayer == g_iActivePlayer then
		if UI.GetHeadSelectedUnit() and UI.GetHeadSelectedUnit():MovesLeft() == 0 then
			print("EaAction.lua forcing unit cycle")
			Game.CycleUnits(true, true, false)	--move on to next unit
		end
	end

	--Ongoing actions with turnsToComplete > 0 (DoEaAction is called each turn of construction)
	local turnsToComplete = g_eaAction.TurnsToComplete
	if not turnsToComplete then
		turnsToComplete = Turns[eaActionID]()
		g_eaPerson.turnsToComplete = turnsToComplete
	end
	
	--Reserve this action at this plot (will cause TestEaActionTarget fail for other GPs)
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
				return FinishEaAction(eaActionID)
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
				return FinishEaAction(eaActionID)
			else
				progressTable[eaActionID] = progress
			end
		end

	end
	print("Reached end of DoEaAction, returning true")
	return true
end


function InterruptEaAction(iPlayer, iPerson)
	--Called from DoEaAction if there is a direct call to DoEaAction that returns false,
	--or for a previous (presumably in progress) eaActionID if a new DoEaAction is called with a different eaActionID 
	--May also be called directly for some reasons (e.g., a GP has been killed but has an eaActionID that we want to cancel)
	--WARNING! DO NOT USE FILE-LEVEL LOCALS FOR INTERRUPT FUNCTIONS! (Can be called externally or with "previous" eaActionID)
	--Does not reappear GP immediately (do that elsewhere if needed)
	print("InterruptEaAction", iPlayer, iPerson)
	local eaPerson = gPeople[iPerson]
	local eaActionID = eaPerson.eaActionID
	if eaActionID >= FIRST_SPELL_ID then
		InterruptEaSpell(iPlayer, iPerson)
		return
	end
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]

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
	local unit = player:GetUnitByID(eaPlayer.iUnit)
	if unit and not unit:IsDelayedDeath() then						--Could be interrupt for death, so no unit
		unit:SetInvisibleType(INVISIBLE_SUBMARINE)
	end


	print("end of InterruptEaAction")								
end
--LuaEvents.EaActionsInterruptEaAction.Add(InterruptEaAction)
LuaEvents.EaActionsInterruptEaAction.Add(function(iPlayer, iPerson) return HandleError21(InterruptEaAction, iPlayer, iPerson) end)

function ClearActionPlotTargetedForPerson(iPlayer, iPerson)
	--print("Running ClearActionPlotTargetedForPerson")
	--for eaActionID, actionTargets in pairs(eaPlayer.actionPlotTargeted) do
	--	for iPlot, iLoopPerson in pairs(actionTargets) do
	--		if iPerson == iLoopPerson then
	--			actionTargets[iPlot] = nil
	--		end
	--	end
	--end
	for iPlot, plotTargetActions in pairs(gg_playerPlotActionTargeted[iPlayer]) do
		for eaActionID, iLoopPerson in pairs(plotTargetActions) do
			if iPerson == iLoopPerson then
				plotTargetActions[eaActionID] = nil
			end			
		end
	end
end

local function SetWEAHelp(eaActionID, mod)
	Dprint("SetWEAHelp ", eaActionID, mod)
	MapModData.text = "no help text"
	g_bAllTestsPassed = true
	g_mod = mod
	if SetUI[eaActionID] then SetUI[eaActionID]() end
	if MapModData.text == "no help text" then
		local help = EaActionsInfo[eaActionID].Help
		if help then
			MapModData.text = help
		end
	end
end
LuaEvents.EaActionsSetWEAHelp.Add(function(eaActionID, mod) return HandleError21(SetWEAHelp, eaActionID, mod) end)

------------------------------------------------------------------------------------------------------------------------------
-- EA_ACTION_GO_TO_PLOT is special and handled here (no test, just do or fail)
------------------------------------------------------------------------------------------------------------------------------

function DoGotoPlot(iPlayer, unit, iPerson, gotoX, gotoY)
	local eaPerson = gPeople[iPerson]

	if 0 < eaPerson.eaActionID then			--was doing something before move order, interrupt it
		InterruptEaAction(iPlayer, iPerson)
	end	

	local gotoPlotIndex
	if gotoX then		--this is an initial call with destination
		gotoPlotIndex = GetPlotIndexFromXY(gotoX, gotoY)
		eaPerson.gotoPlotIndex = gotoPlotIndex
	else
		gotoPlotIndex = eaPerson.gotoPlotIndex
		if gotoPlotIndex == -1 then return false end
		gotoX, gotoY = GetXYFromPlotIndex(gotoPlotIndex)
	end



	--[[Stop if trying to enter enemy city!
	local plot = GetPlotFromXY(gotoX, gotoY)
	local city = plot:GetPlotCity()
	if city then
		local iCityOwner = city:GetOwner()
		if iCityOwner ~= iPlayer then
			if Teams[Players[iPlayer]:GetTeam()]:IsAtWar(Players[iCityOwner]:GetTeam()) then
				eaPerson.gotoPlotIndex = -1
				eaPerson.gotoEaActionID = -1
				eaPerson.eaActionID = -1
				return false
			end
		end
	end
	]]

	local unitPlot = unit:GetPlot()
	local unitX, unitY, unitPlotIndex = unitPlot:GetXYIndex()

	if unitPlotIndex == gotoPlotIndex then
		print("DoGotoPlot: GP is at destination...")
		eaPerson.eaActionID = -1					--OK FOR AI???
		return true
	end

	local movesBefore = unit:MovesLeft()
	if movesBefore == 0 then
		print("DoGotoPlot was called for unit with no moves")
		eaPerson.eaActionID = 0
		return true		--this is not a failed move
	end

	--local turns = EaPersonAStarTurns(iPlayer, iPerson, unitX, unitY, gotoX, gotoY)	--failed pathfinding returns 1000

	local turns = unit:TurnsToReachTarget(GetPlotFromXY(gotoX, gotoY), 1, 0, 0)
	print("Turns to target = ", turns)
	if turns > 100 then
		print("DoGotoPlot path > 100 turns")
		eaPerson.gotoPlotIndex = -1
		eaPerson.gotoEaActionID = -1
		eaPerson.eaActionID = -1
		return false
	end

	--UnJoinGP(iPlayer, eaPerson)

	--first try to approach directly
	unit:PopMission()
	unit:PushMission(MissionTypes.MISSION_MOVE_TO, gotoX, gotoY, 0, 0, 1)		--, MissionTypes.MISSION_MOVE_TO, unitPlot, unit)
	local movesAfter = unit:MovesLeft()
	if movesAfter < movesBefore then	--success!
		print("DoGotoPlot moved GP toward target plot")
		eaPerson.eaActionID = 0

		local gotoEaAction = EaActionsInfo[eaPerson.gotoEaActionID]
		if gotoEaAction then
			--modMemory (AI has decided it is worth moving to do some action)
			if gotoEaAction.GPModType1 then
				if gotoEaAction.GPModType1 ~= "EAMOD_LEADERSHIP" then
					local memValue = 2 ^ (g_gameTurn / MOD_MEMORY_HALFLIFE)
					local modID = GameInfoTypes[gotoEaAction.GPModType1]
					eaPerson.modMemory[modID] = (eaPerson.modMemory[modID] or 0) + memValue
				end
				if gotoEaAction.GPModType2 and gotoEaAction.GPModType2 ~= "EAMOD_LEADERSHIP" then
					local modID = GameInfoTypes[gotoEaAction.GPModType2]
					eaPerson.modMemory[modID] = (eaPerson.modMemory[modID] or 0) + memValue
				end
			end
		end

		return true
	end

	print("!!!! WARNING: DoGotoPlot could not move GP even though AStar thought there was a path")
	eaPerson.gotoPlotIndex = -1
	eaPerson.gotoEaActionID = -1
	eaPerson.eaActionID = -1
	return false

end

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-- Action-specific functions
-- If present, these provide additional criteria or effects beyond generic functions above
-- Test, TestTarget, SetUI, SetAIValues, Do, Interrupt, Finish
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

--TO DO: All SetUI statements need TXT_KEYs

------------------------------------------------------------------------------------------------------------------------------
-- Non-GP (SetAIValues doesn't work for these yet)
------------------------------------------------------------------------------------------------------------------------------
--EA_ACTION_SELL_SLAVES
Do[GameInfoTypes.EA_ACTION_SELL_SLAVES] = function()
	local sellGold = 30
	if g_eaPlayer.eaCivNameID == EACIV_NEZELIBA then
		sellGold = 36
	end
	g_player:ChangeGold(sellGold)
	MapModData.bBypassOnCanSaveUnit = true
	g_unit:Kill(true, -1)
	g_unit = nil
	return true
end

--EA_ACTION_RENDER_SLAVES
TestTarget[GameInfoTypes.EA_ACTION_RENDER_SLAVES] = function()
	--city must be constructing building or military unit
	orderType, g_int1 = g_city:GetOrderFromQueue(0)		--orderType, id
	if orderType == OrderTypes.ORDER_TRAIN then
		g_bool1 = true
		return true
	elseif orderType == OrderTypes.ORDER_CONSTRUCT then
		g_bool1 = false
		return true
	end
	return false
end

Do[GameInfoTypes.EA_ACTION_RENDER_SLAVES] = function()
	local renderProd = 20
	if g_eaPlayer.eaCivNameID == EACIV_NEZELIBA then
		renderProd = 24
	end
	if g_bool1 then
		g_city:ChangeUnitProduction(g_int1, renderProd)
	else
		g_city:ChangeBuildingProduction(g_int1, renderProd)
	end
	MapModData.bBypassOnCanSaveUnit = true
	g_unit:Kill(true, -1)
	g_unit = nil
	return true
end


--EA_ACTION_HIRE_OUT_MERC
TestTarget[GameInfoTypes.EA_ACTION_HIRE_OUT_MERC] = function()		--need to apply warrior scout filter
	if gg_bToCheapToHire[g_unitTypeID] then return false end
	g_int1, g_int2, g_int3 = GetMercenaryCosts(g_unit)	-- totalCost, upFront, gpt
	if g_int1 < 50 then return false end
	return true
end

SetUI[GameInfoTypes.EA_ACTION_HIRE_OUT_MERC] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Make unit available for hire (" .. g_int2 .. " gold advance; " .. g_int3 .. " gold per turn)"
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]This unit is not valuable enough to be hired[ENDCOLOR]"
	end
end

Do[GameInfoTypes.EA_ACTION_HIRE_OUT_MERC] = function()
	g_unit:SetHasPromotion(GameInfoTypes.PROMOTION_FOR_HIRE, true)
	return true
end

--EA_ACTION_CANC_HIRE_OUT_MERC
Do[GameInfoTypes.EA_ACTION_CANC_HIRE_OUT_MERC] = function()
	g_unit:SetHasPromotion(GameInfoTypes.PROMOTION_FOR_HIRE, false)
	return true
end

------------------------------------------------------------------------------------------------------------------------------
-- Common actions
------------------------------------------------------------------------------------------------------------------------------

--EA_ACTION_TAKE_LEADERSHIP
Test[GameInfoTypes.EA_ACTION_TAKE_LEADERSHIP] = function()
	return g_player:GetLeaderType() < LEADER_FAND
end

SetAIValues[GameInfoTypes.EA_ACTION_TAKE_LEADERSHIP] = function()
	gg_aiOptionValues.i = 10000	--do it!
end

SetUI[GameInfoTypes.EA_ACTION_TAKE_LEADERSHIP] = function()
	if g_bNonTargetTestsPassed then
		MapModData.bShow = true		--button will show if no leader (but will be disabled if not in capital)
	end
end

Do[GameInfoTypes.EA_ACTION_TAKE_LEADERSHIP] = function()
	MakeLeader(g_iPlayer, g_iPerson)
	return true
end

--EA_ACTION_TAKE_RESIDENCE
local classYields = {Warrior = -1, Engineer = YIELD_PRODUCTION, Merchant = YIELD_GOLD, Sage = YIELD_SCIENCE, Artist = YIELD_CULTURE, Devout = YIELD_FAITH, Thaumaturge = YIELD_FAITH}

TestTarget[GameInfoTypes.EA_ACTION_TAKE_RESIDENCE] = function()
	--print("TestTarget - EA_ACTION_TAKE_RESIDENCE", g_iPerson, g_eaCity.resident)
	if g_eaCity.resident ~= g_iPerson and g_eaCity.resident ~= -1 then
		--allow if leader and this is capital (will force AI non-leader to do something else)
		if g_iPerson ~= g_eaPlayer.leaderEaPersonIndex or not g_city:IsCapital() then
			g_testTargetSwitch = 1		--someone else is resident here
			return false
		end
	end

	local mod = g_mod
	local yield1ID = classYields[g_class1]
	local yield2ID = -99
	if g_class2 then yield2ID = classYields[g_class2] end		--dual class
	if yield2ID == yield1ID then yield2ID = -99 end
	if yield2ID == -99 then mod = mod * 2 end					--double mod for single class
	local boost1, boost2 = 0, 0
	if yield1ID ~= -1 then
		boost1 = mod * g_city:GetBaseYieldRate(yield1ID) / 100
		--boost1 = mod/2 < boost1 and boost1 or mod/2						--give +mod% or +mod/2, whichever is greater
	else
		boost1 = mod	--warrior (need to figure out if city making military)
	end

	if yield2ID ~= -99 then
		if yield2ID ~= -1 then
			boost2 = mod * g_city:GetBaseYieldRate(yield2ID) / 100
			--boost2 = mod/2 < boost2 and boost2 or mod/2
		else
			boost2 = mod
		end
	end

	if g_subclass == "SeaWarrior" then
		yield1ID = -2
	end

	g_int1 = yield1ID
	g_int2 = yield2ID
	g_int3 = boost1
	g_int4 = boost2
	g_int5 = mod
	g_testTargetSwitch = 2
	return true
end

SetUI[GameInfoTypes.EA_ACTION_TAKE_RESIDENCE] = function()

	if g_testTargetSwitch == 1 then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]Another great person is resident in this city[ENDCOLOR]"
	elseif g_testTargetSwitch == 2 then
		--MapModData.bShow = true
		MapModData.text = ""
	
		if g_int1 == -1 then
			MapModData.text = MapModData.text .. "Provide " .. g_int5 .." xp to all land units built in this city"
		elseif g_int1 == -2 then
			MapModData.text = MapModData.text .. "Provide " .. g_int5 .." xp to all sea units built in this city"
		elseif g_int1 == YIELD_PRODUCTION then
			MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city production (" .. g_int3 .. " total)"
		elseif g_int1 == YIELD_GOLD then
			MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city gold (" .. g_int3 .. " total)"
		elseif g_int1 == YIELD_SCIENCE then
			MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city science (" .. g_int3 .. " total)"
		elseif g_int1 == YIELD_CULTURE then
			MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city culture (" .. g_int3 .. " total)"
		elseif g_int1 == YIELD_FAITH then
			if g_eaPlayer.bUsesDivineFavor then
				MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city divine favor (" .. g_int3 .. " total)"
			else
				MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city mana (" .. g_int3 .. " total)"
			end
		end

		if g_int2 ~= -99 then
			if g_int2 == -1 then
				MapModData.text = MapModData.text .. "Provide " .. g_int5 .." xp to all land units built in this city"
			elseif g_int2 == -2 then
				MapModData.text = MapModData.text .. "Provide " .. g_int5 .." xp to all sea units built in this city"
			elseif g_int2 == YIELD_PRODUCTION then
				MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city production (" .. g_int4 .. " total)"
			elseif g_int2 == YIELD_GOLD then
				MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city gold (" .. g_int4 .. " total)"
			elseif g_int2 == YIELD_SCIENCE then
				MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city science (" .. g_int4 .. " total)"
			elseif g_int2 == YIELD_CULTURE then
				MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city culture (" .. g_int4 .. " total)"
			elseif g_int2 == YIELD_FAITH then
				if g_eaPlayer.bUsesDivineFavor then
					MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city divine favor (" .. g_int4 .. " total)"
				else
					MapModData.text = MapModData.text .. "Provide ".. g_int5 .."% boost to city mana (" .. g_int4 .. " total)"
				end
			end	
		else
			MapModData.text = MapModData.text .. "[NEWLINE]"
		end

	end
end

SetAIValues[GameInfoTypes.EA_ACTION_TAKE_RESIDENCE] = function()
	gg_aiOptionValues.b = g_int3 + g_int4	--per turn value during "build" turns
end

--local residentEffects = {[-2] = "residentSeaXP", [-1] = "residentLandXP", [YIELD_PRODUCTION] = "residentProduction", [YIELD_GOLD] = "residentGold", [YIELD_SCIENCE] = "residentScience", [YIELD_CULTURE] = "residentCulture", [YIELD_FAITH] = "residentManaOrFavor"}

Do[GameInfoTypes.EA_ACTION_TAKE_RESIDENCE] = function()
	--check for a previous resident
	local iOldResident = g_eaCity.resident
	if iOldResident ~= -1 and iOldResident ~= g_iPerson then
		local eaOldResident = gPeople[iOldResident]
		InterruptEaAction(g_iPlayer, iOldResident)	--cancel action, wake up and remove effects
		--ReappearGP(g_iPlayer, iOldResident)
	end

	g_eaCity.resident = g_iPerson

	if -1 < g_int1 then		--This is a regular yield
		if g_city:GetCityResidentYieldBoost(g_int1) ~= g_int5 then
			g_city:SetCityResidentYieldBoost(g_int1, g_int5)
		end
	elseif g_int1 == -1 then
		g_eaCity.residentLandXP = g_int5
	elseif g_int1 == -1 then
		g_eaCity.residentSeaXP = g_int5
	end
	if -1 < g_int2 then
		if g_city:GetCityResidentYieldBoost(g_int2) ~= g_int5 then
			g_city:SetCityResidentYieldBoost(g_int2, g_int5)
		end
	elseif g_int2 == -1 then
		g_eaCity.residentLandXP = g_int5
	elseif g_int2 == -1 then
		g_eaCity.residentSeaXP = g_int5
	end

	--if g_iPlayer == g_iActivePlayer then
	--	UpdateCityYields(g_iPlayer, g_iCity) 	--show effect in UI now
	--end
	g_eaPerson.eaActionData = g_iPlot
	return true
end

Interrupt[GameInfoTypes.EA_ACTION_TAKE_RESIDENCE] = function(iPlayer, iPerson)
	print("Interrupt - GameInfoTypes.EA_ACTION_TAKE_RESIDENCE", iPlayer, iPerson)
	local eaPerson = gPeople[iPerson]
	local eaCityIndex = eaPerson.eaActionData
	local eaCity = gCities[eaCityIndex]
	if eaCity then
		eaCity.resident = -1
		eaPerson.eaActionData = -1
		local city = GetPlotByIndex(eaCityIndex):GetPlotCity()
		if city then
			RemoveResidentEffects(city)
		end
	end
end

--EA_ACTION_HEAL	(This is for AI only, since active player can just press Heal button)
Test[GameInfoTypes.EA_ACTION_HEAL] = function()
	if not g_bAIControl then return false end
	g_int1 = g_unit:GetDamage()
	if 0 < g_int1 then
		g_int2 = FRIENDLY_HEAL_RATE + g_unit:GetExtraFriendlyHeal()
		g_int3 = NEUTRAL_HEAL_RATE + g_unit:GetExtraNeutralHeal()
		--g_int4 = ENEMY_HEAL_RATE + g_unit:GetExtraEnemyHeal()		--same as above
		g_bool1 = g_unit:HasMoved()
		return true
	end
	return false 
end

TestTarget[GameInfoTypes.EA_ACTION_HEAL] = function()
	if g_iOwner == -1 then
		g_int5 = g_int3
	elseif g_iOwner == g_iPlayer then
		g_int5 = g_int2
	else
		if g_iOwner < MAX_MAJOR_CIVS then
			g_int5 = Teams[Players[g_iOwner]:GetTeam()]:IsAllowsOpenBordersToTeam(g_iTeam) and g_int2 or g_int3
		else
			g_int5 = Players[g_iOwner]:IsFriends(g_iPlayer) and g_int2 or g_int3
		end
	end
	return true
end

SetAIValues[GameInfoTypes.EA_ACTION_HEAL] = function()
	local value = g_int5 * g_int1 / 10
	if g_unitX ~= g_x or g_unitY ~= g_y or g_bool1 then		--not this plot this turn
		value = value - 20
	end
	gg_aiOptionValues.i = value
end

Do[GameInfoTypes.EA_ACTION_HEAL] = function()
	if not g_bool1 then
		g_unit:ChangeDamage(-g_int5, -1)
	end
	return true
end

------------------------------------------------------------------------------------------------------------------------------
-- GP "Yield" Actions (always available in any of our cities)
------------------------------------------------------------------------------------------------------------------------------

--EA_ACTION_BUILD
TestTarget[GameInfoTypes.EA_ACTION_BUILD] = function()
	g_int1 = Floor(g_mod * (g_city:GetBaseYieldRateModifier(YIELD_PRODUCTION)) / 200 + 0.5)
	return true
end

SetUI[GameInfoTypes.EA_ACTION_BUILD] = function()
	if g_bAllTestsPassed then
		local cityProductionName = g_city:GetProductionNameKey()
		if cityProductionName then
			MapModData.text = "Provide " .. g_int1 .. " production per turn toward " .. Locale.ConvertTextKey(cityProductionName)
		else
			MapModData.text = "Provide " .. g_int1 .. " production per turn toward this city's next build selection"
		end
	end
end



SetAIValues[GameInfoTypes.EA_ACTION_BUILD] = function()
	gg_aiOptionValues.b = g_int1	
end

Do[GameInfoTypes.EA_ACTION_BUILD] = function()
	g_eaCity.gpProduction = g_eaCity.gpProduction or {}
	g_eaCity.gpProduction[g_iPerson] = g_int1
	g_eaPerson.eaActionData = g_iPlot
	g_unit:ChangeExperience(g_int1)
	if g_iPlayer == g_iActivePlayer then
		UpdateCityYields(g_iPlayer, g_iCity, "Production")	--instant UI update for human
	end
	return true
end

Interrupt[GameInfoTypes.EA_ACTION_BUILD] = function(iPlayer, iPerson)
	local eaPerson = gPeople[iPerson]
	local eaCityIndex = eaPerson.eaActionData
	local eaCity = gCities[eaCityIndex]
	eaPerson.eaActionData = -1
	if eaCity and eaCity.gpProduction then
		eaCity.gpProduction[iPerson] = nil
		if iPlayer == g_iActivePlayer then
			local iCity = GetPlotByIndex(eaCityIndex):GetPlotCity():GetID()
			UpdateCityYields(iPlayer, iCity, "Production")
		end
	end
end

--EA_ACTION_TRADE
TestTarget[GameInfoTypes.EA_ACTION_TRADE] = function()
	g_int1 = Floor(g_mod * (g_city:GetBaseYieldRateModifier(YIELD_GOLD)) / 200 + 0.5)
	return true
end

SetUI[GameInfoTypes.EA_ACTION_TRADE] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Provide " .. g_int1 .. " gold per turn to this city"
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_TRADE] = function()
	gg_aiOptionValues.b = g_int1	
end

Do[GameInfoTypes.EA_ACTION_TRADE] = function()
	g_eaCity.gpGold = g_eaCity.gpGold or {}
	g_eaCity.gpGold[g_iPerson] = g_int1
	g_eaPerson.eaActionData = g_iPlot
	g_unit:ChangeExperience(g_int1)
	if g_iPlayer == g_iActivePlayer then
		UpdateCityYields(g_iPlayer, g_iCity, "Gold")	--instant UI update for human
	end
	return true
end

Interrupt[GameInfoTypes.EA_ACTION_TRADE] = function(iPlayer, iPerson)
	local eaPerson = gPeople[iPerson]
	local eaCityIndex = eaPerson.eaActionData
	local eaCity = gCities[eaCityIndex]
	eaPerson.eaActionData = -1
	if eaCity and eaCity.gpGold then
		eaCity.gpGold[iPerson] = nil
		if iPlayer == g_iActivePlayer then
			local iCity = GetPlotByIndex(eaCityIndex):GetPlotCity():GetID()
			UpdateCityYields(iPlayer, iCity, "Gold")
		end
	end
end

--EA_ACTION_RESEARCH
TestTarget[GameInfoTypes.EA_ACTION_RESEARCH] = function()
	local scienceModifier = g_city:GetBaseYieldRateModifier(YIELD_SCIENCE)
	if scienceModifier >= 50 then
		g_bool1 = true
		g_int1 = Floor(g_mod * scienceModifier / 200 + 0.5)
	else
		g_int2 = g_player:GetCurrentResearch()
		if g_int2 == -1 then return false end
		g_bool1 = false
		g_int1 = Floor(g_mod / 4) + 1
	end
	return true
end

SetUI[GameInfoTypes.EA_ACTION_RESEARCH] = function()
	if g_bAllTestsPassed then
		if g_bool1 then
			MapModData.text = "Provide " .. g_int1 .. " research per turn to this city"
		else
			MapModData.text = "Provide " .. g_int1 .. " research (city research modifier no longer applies)"
		end
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]You must select a tech to conduct Research[ENDCOLOR]"
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_RESEARCH] = function()
	gg_aiOptionValues.b = g_int1	
end

Do[GameInfoTypes.EA_ACTION_RESEARCH] = function()
	if g_bool1 then
		g_eaCity.gpScience = g_eaCity.gpScience or {}
		g_eaCity.gpScience[g_iPerson] = g_int1
	else
		if g_eaCity.gpScience then
			g_eaCity.gpScience[g_iPerson] = nil
		end
		local teamTech = g_team:GetTeamTechs()
		teamTech:ChangeResearchProgress(g_int2, g_int1, g_iPlayer)	--apply directly to tech
		--need UI for this somehow
	end

	g_eaPerson.eaActionData = g_iPlot
	g_unit:ChangeExperience(g_int1)
	if g_iPlayer == g_iActivePlayer then
		UpdateCityYields(g_iPlayer, g_iCity, "Science")	--instant UI update for human
	end
	return true
end

Interrupt[GameInfoTypes.EA_ACTION_RESEARCH] = function(iPlayer, iPerson)
	local eaPerson = gPeople[iPerson]
	local eaCityIndex = eaPerson.eaActionData
	local eaCity = gCities[eaCityIndex]
	eaPerson.eaActionData = -1
	if eaCity and eaCity.gpScience then
		eaCity.gpScience[iPerson] = nil
		if iPlayer == g_iActivePlayer then
			local iCity = GetPlotByIndex(eaCityIndex):GetPlotCity():GetID()
			UpdateCityYields(iPlayer, iCity, "Science")
		end
	end
end

--EA_ACTION_PERFORM
TestTarget[GameInfoTypes.EA_ACTION_PERFORM] = function()
	g_int1 = Floor(g_mod * (g_city:GetCultureRateModifier() + 100) / 200 + 0.5)
	return true
end

SetUI[GameInfoTypes.EA_ACTION_PERFORM] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Provide " .. g_int1 .. " culture per turn to this city"
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_PERFORM] = function()
	gg_aiOptionValues.b = g_int1	
end

Do[GameInfoTypes.EA_ACTION_PERFORM] = function()
	g_eaCity.gpCulture = g_eaCity.gpCulture or {}
	g_eaCity.gpCulture[g_iPerson] = g_int1
	g_eaPerson.eaActionData = g_iPlot
	g_unit:ChangeExperience(g_int1)
	if g_iPlayer == g_iActivePlayer then
		UpdateCityYields(g_iPlayer, g_iCity, "Culture")	--instant UI update for human
	end
	return true
end

Interrupt[GameInfoTypes.EA_ACTION_PERFORM] = function(iPlayer, iPerson)
	local eaPerson = gPeople[iPerson]
	local eaCityIndex = eaPerson.eaActionData
	local eaCity = gCities[eaCityIndex]
	eaPerson.eaActionData = -1
	if eaCity and eaCity.gpCulture then
		eaCity.gpCulture[iPerson] = nil
		if iPlayer == g_iActivePlayer then
			local iCity = GetPlotByIndex(eaCityIndex):GetPlotCity():GetID()
			UpdateCityYields(iPlayer, iCity, "Culture")
		end
	end
end

--EA_ACTION_WORSHIP
Test[GameInfoTypes.EA_ACTION_WORSHIP] = function()
	g_value = g_gameTurn / (g_player:GetFaith() + 5)		--AI prioritizes when low; doesn't try to hoard early
	return true
end

SetUI[GameInfoTypes.EA_ACTION_WORSHIP] = function()
	if g_bAllTestsPassed then
		local pts = Floor(g_mod / 2)
		local yieldText = g_eaPlayer.bUsesDivineFavor and "Divine Favor" or "Mana"
		MapModData.text = "Provide " .. pts .. " " .. yieldText .. " per turn"
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_WORSHIP] = function()
	gg_aiOptionValues.b = Floor(g_mod / 2) * g_value
end

Do[GameInfoTypes.EA_ACTION_WORSHIP] = function()
	local pts = Floor(g_mod / 2)
	g_eaCity.gpFaith = g_eaCity.gpFaith or {}
	g_eaCity.gpFaith[g_iPerson] = pts
	g_eaPerson.eaActionData = g_iPlot
	g_unit:ChangeExperience(pts)
	if g_iPlayer == g_iActivePlayer then
		UpdateCityYields(g_iPlayer, g_iCity, "Faith")	--instant UI update for human
	end
	return true
end

Interrupt[GameInfoTypes.EA_ACTION_WORSHIP] = function(iPlayer, iPerson)
	local eaPerson = gPeople[iPerson]
	local eaCityIndex = eaPerson.eaActionData
	local eaCity = gCities[eaCityIndex]
	eaPerson.eaActionData = -1
	if eaCity and eaCity.gpFaith then
		eaCity.gpFaith[iPerson] = nil
		if iPlayer == g_iActivePlayer then
			local iCity = GetPlotByIndex(eaCityIndex):GetPlotCity():GetID()
			UpdateCityYields(iPlayer, iCity, "Faith")
		end
	end
end

--EA_ACTION_CHANNEL 
Test[GameInfoTypes.EA_ACTION_CHANNEL] = function()
	g_value = g_gameTurn / (g_player:GetFaith() + 5)		--AI prioritizes when low; doesn't try to hoard early
	return true
end

TestTarget[GameInfoTypes.EA_ACTION_CHANNEL] = function()
	return gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson] and gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson].iPlot == g_iPlot 	--only in own tower
end

SetUI[GameInfoTypes.EA_ACTION_CHANNEL] = function()
	if g_bNonTargetTestsPassed then		--has spell so show it
		MapModData.bShow = true
		if g_bAllTestsPassed then
			local pts = Floor(g_mod / 2)
			local iCity = g_plot:GetCityPurchaseID()
			local city = g_player:GetCityByID(iCity)
			local cityName = city:GetName()
			MapModData.text = "Provide " .. pts .. " Mana per turn from " .. cityName
		else
			MapModData.text = "Thaumaturges can channel mana only from their own tower "
		end
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_CHANNEL] = function()
	gg_aiOptionValues.b = Floor(g_mod / 2) * g_value
end

Do[GameInfoTypes.EA_ACTION_CHANNEL] = function()
	local pts = Floor(g_mod / 2)
	local iCity = g_plot:GetCityPurchaseID()
	local city = g_player:GetCityByID(iCity)
	local eaCity = gCities[city:Plot():GetPlotIndex()]

	eaCity.gpFaith = eaCity.gpFaith or {}
	eaCity.gpFaith[g_iPerson] = pts
	g_eaPerson.eaActionData = g_iPlot
	g_unit:ChangeExperience(pts)
	if g_iPlayer == g_iActivePlayer then
		UpdateCityYields(g_iPlayer, iCity, "Faith")	--instant UI update for human
	end
	return true
end

Interrupt[GameInfoTypes.EA_ACTION_CHANNEL] = function(iPlayer, iPerson)
	local eaPerson = gPeople[iPerson]
	local eaCityIndex = eaPerson.eaActionData
	local eaCity = gCities[eaCityIndex]
	eaPerson.eaActionData = -1
	if eaCity and eaCity.gpFaith then
		eaCity.gpFaith[iPerson] = nil
		if iPlayer == g_iActivePlayer then
			local iCity = GetPlotByIndex(eaCityIndex):GetPlotCity():GetID()
			UpdateCityYields(iPlayer, iCity, "Faith")
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------
-- Warrior Actions (only show when available)
------------------------------------------------------------------------------------------------------------------------------

--EA_ACTION_LEAD_CHARGE
Test[GameInfoTypes.EA_ACTION_LEAD_CHARGE] = function()
	g_int3 = g_unit:GetCurrHitPoints()
	if g_bAIControl then
		if g_int3 < 40 then		--TO DO: Adjust for berserker
			return false
		end
	end
	return true
end


--need prospective target here (for forced ai attack); also neeed to make sure we have melee and not ranged unit on plot
--g_obj1 is valid target unit; g_obj2 is same-plot melee unit

TestTarget[GameInfoTypes.EA_ACTION_LEAD_CHARGE] = function()
	--Must be melee attack unit on same plot and enemy in range

	local unitCount = g_plot:GetNumUnits()
	for i = 0, unitCount - 1 do
		local unit = g_plot:GetUnit(i)
		if unit ~= g_unit and unit:GetOwner() == g_iPlayer and not unit:IsOnlyDefensive() then
			local unitTypeID = unit:GetUnitType()
			if gg_bNormalLivingCombatUnit[unitTypeID] then
				print("EA_ACTION_LEAD_CHARGE has a same-plot melee unit")
				g_obj2 = unit
				g_int4 = unit:GetCurrHitPoints()
				g_int5 = unit:GetBaseCombatStrength()
				--Find best unit for attack (temp: score by damage + ranged - combat)
				local bestValue = -9999
				for x, y in PlotToRadiusIterator(g_x, g_y, 1, nil, nil, true) do
					local loopPlot = GetPlotFromXY(x, y)
					if loopPlot:IsVisibleEnemyDefender(unit) then
						print("Found enemy defender on adjacent plot")
						local loopUnitCount = loopPlot:GetNumUnits()	--TO DO: add city attack ability
						print(x, y, loopUnitCount)
						for j = 0, loopUnitCount - 1 do
							local loopUnit = loopPlot:GetUnit(j)
							if loopUnit:IsCombatUnit() and not loopUnit:IsGreatPerson() then
								print("Found adjacent combat unit") 
								if unit:CanMoveOrAttackInto(loopPlot) then
									print("Melee can attack enemy")
									local value = loopUnit:GetDamage() + 5 * loopUnit:GetBaseRangedCombatStrength() --	- loopUnit:GetBaseCombatStrength()
									print("TestTarget - EA_ACTION_LEAD_CHARGE has found potential target; value = ", value)
									if bestValue < value then
										bestValue = value
										g_obj1 = loopUnit
									end
								end
							end
						end
					end
				end
				if bestValue ~= -9999 then
					g_int1 = g_mod * 2
					g_int2 = bestValue + 100
					return true
				else
					return false
				end
			end
		end
	
	end
	return false
end

SetUI[GameInfoTypes.EA_ACTION_LEAD_CHARGE] = function()
	if g_bAllTestsPassed then
		local unitTypeID = g_obj2:GetUnitType()
		local unitText = Locale.ConvertTextKey(GameInfo.Units[unitTypeID].Description)
		MapModData.text = "Your " .. unitText .. " will follow their general's charge with +" .. g_int1 .. " morale boost"
		--MapModData.text = "Increase morale of " .. unitText .. " by " .. g_int1 .. " for next attack (" .. g_int2 .."% chance of death with attack)"
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_LEAD_CHARGE] = function()
	local raceMultiplier = 1
	if g_eaPlayer.race == EARACE_SIDHE then
		raceMultiplier = 0.3
	elseif g_eaPlayer.race == EARACE_HELDEOFOL then
		raceMultiplier = 2
	end
	gg_aiOptionValues.i = raceMultiplier * (g_mod * g_int3 * g_int4 * g_int5 / 10000 + g_int2)	
end

Do[GameInfoTypes.EA_ACTION_LEAD_CHARGE] = function()

	g_unit:SetInvisibleType(-1)
	g_unit:SetGPAttackState(1)


	if g_bAIControl then		--Carry out attack
		local targetX, targetY = g_obj1:GetX(), g_obj1:GetY()
		g_unit:PushMission(MissionTypes.MISSION_MOVE_TO, targetX, targetY)		--, 0, 0, 1)
		if g_unit and g_unit:MovesLeft() > 0  then
			error("AI GP has movement after Lead Charge! Did it not attack?")
		end
		--follow-up melee attack and GPAttackState reset will happen from OnCombatEnded

	elseif g_iPlayer == g_iActivePlayer then	--Put Warrior in forced interface
		MapModData.forcedUnitSelection = g_iUnit
		MapModData.forcedInterfaceMode = InterfaceModeTypes.INTERFACEMODE_ATTACK
		UI.SelectUnit(g_unit)
		UI.LookAtSelectionPlot(0)
		Events.SerialEventUnitInfoDirty()
	end

	return true
end


--EA_ACTION_RALLY_TROOPS
--TO DO: make this a single plot action
TestTarget[GameInfoTypes.EA_ACTION_RALLY_TROOPS] = function()
	--Must be melee attack unit with enemy in range in same or adjacent plot
	local numQualifiedUnits = 0
	local value = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if unit:GetOwner() == g_iPlayer and unit:IsCanAttack() then
				local unitTypeID = unit:GetUnitType()
				if gg_bNormalLivingCombatUnit[unitTypeID] and unit:IsEnemyInMovementRange(false, false) then
					numQualifiedUnits = numQualifiedUnits + 1
					g_table[numQualifiedUnits] = unit
					value = value + unit:GetPower()
				end
			end
		end
	end
	if numQualifiedUnits == 0 then
		return false
	end
	g_int1 = numQualifiedUnits
	g_value = value
	return true
end

SetUI[GameInfoTypes.EA_ACTION_RALLY_TROOPS] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increase morale for " .. g_int1 .. " nearby unit(s) by " .. (g_mod * 2)
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_RALLY_TROOPS] = function()
	gg_aiOptionValues.i = g_mod * g_value / 100			
end

Do[GameInfoTypes.EA_ACTION_RALLY_TROOPS] = function()
	for i = 1, g_int1 do
		local unit = g_table[i]
		local floatUp = "+" .. g_mod .. " [ICON_HAPPINESS_1] Morale"
		unit:GetPlot():AddFloatUpMessage(floatUp, 1)
		unit:ChangeMorale(g_mod)
	end
	local xp = Floor(g_mod * g_value / 1000)
	g_unit:ChangeExperience(xp)
	g_specialEffectsPlot = g_plot
	return true
end

--EA_ACTION_TRAIN_UNIT
TestTarget[GameInfoTypes.EA_ACTION_TRAIN_UNIT] = function()
	--Must be combat unit at plot
	local unitCount = g_plot:GetNumUnits()
	for i = 0, unitCount - 1 do
		local unit = g_plot:GetUnit(i)
		if unit:GetOwner() == g_iPlayer and unit:GetDamage() == 0 then
			local unitTypeID = unit:GetUnitType()
			if gg_bNormalLivingCombatUnit[unitTypeID] then
				g_obj1 = unit
				g_int1 = unitTypeID
				return true
			end
		end
	end
	return false
end

SetUI[GameInfoTypes.EA_ACTION_TRAIN_UNIT] = function()
	if g_bAllTestsPassed then
		local unitText = Locale.ConvertTextKey(GameInfo.Units[g_int1].Description)
		local xp = Floor(g_mod / 2)
		MapModData.text = "Provide " .. unitText .. " with " .. xp .. " experience per turn"
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_TRAIN_UNIT] = function()
	gg_aiOptionValues.i = g_mod * g_obj1:GetPower()			
end

Do[GameInfoTypes.EA_ACTION_TRAIN_UNIT] = function()
	local xp = Floor(g_mod / 2)	--give to unit and GP
	g_obj1:ChangeExperience(xp)
	g_unit:ChangeExperience(xp)
	return true
end

------------------------------------------------------------------------------------------------------------------------------
-- Misc Actions
------------------------------------------------------------------------------------------------------------------------------

--EA_ACTION_LEARN_SPELL
Test[GameInfoTypes.EA_ACTION_LEARN_SPELL] = function()
	if g_eaPerson.learningSpellID ~= -1 then return true end	--learning one now; don't retest

	--any currently learnable by caster? (pick one and value for AI)
	g_count = 0
	local bestSpell, bestValue = -1, 0
	local TestSpellLearnable = TestSpellLearnable
	for spellID = FIRST_SPELL_ID, LAST_SPELL_ID do
		local bLearnable, spellLevel, modType1, modType12 = TestSpellLearnable(g_iPlayer, g_iPerson, spellID, nil)
		if bLearnable then
			g_count = g_count + 1
			local mod = GetGPMod(g_iPerson, modType1, modType12)	--value by what caster is good at
			local value = mod * (spellLevel + 2) ^ 2		
			if bestValue < value then
				bestValue = value
				bestSpell = spellID
			end
		end
	end
	if bestValue == 0 then return false end
	g_int1 = bestSpell
	g_value = 0.1 * bestValue / (#g_eaPerson.spells + 0.1)
	return true
end

Turns[GameInfoTypes.EA_ACTION_LEARN_SPELL] = function()
	return g_bInTowerOrTemple and 4 or 8
end

SetUI[GameInfoTypes.EA_ACTION_LEARN_SPELL] = function()
	if g_eaPerson.learningSpellID == -1 then
		if g_bInTowerOrTemple then
			MapModData.text = "Learn a new spell"
		else
			MapModData.text = "Learn a new spell (learn twice as fast in the caster's Tower or Temple!)"
		end
	else
		local spellName = Locale.Lookup(GameInfo.EaActions[g_eaPerson.learningSpellID].Description)
		MapModData.text = "Continue learning " .. spellName
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_LEARN_SPELL] = function()
	gg_aiOptionValues.i = g_value
end

Do[GameInfoTypes.EA_ACTION_LEARN_SPELL] = function()
	if g_eaPerson.learningSpellID == -1 then	--this must be initial turn of action so we need to pick a spell
		if g_iPlayer == g_iActivePlayer then	--human, pass it off to UI
			LuaEvents.LearnSpellPopup(g_iPerson)
			return true
		else									--AI, set best spell
			g_eaPerson.learningSpellID = g_int1
		end
	end
	g_unit:FinishMoves()
	return true
end

Finish[GameInfoTypes.EA_ACTION_LEARN_SPELL] = function()
	if g_eaPerson.learningSpellID == -1 then
		error("What spell was being learned?")
	end
	g_eaPerson.spells[#g_eaPerson.spells + 1] = g_eaPerson.learningSpellID
	print("GP learned a spell: ", GameInfo.EaActions[g_eaPerson.learningSpellID].Type)
	g_eaPerson.learningSpellID = -1
	g_unit:FinishMoves()
end

Interrupt[GameInfoTypes.EA_ACTION_LEARN_SPELL] = function(iPlayer, iPerson)
	local eaPerson = gPeople[iPerson]
	eaPerson.learningSpellID = -1
	local progressTable = eaPerson.progress
	progressTable[GameInfoTypes.EA_ACTION_LEARN_SPELL] = nil
end

--EA_ACTION_OCCUPY_TOWER
Test[GameInfoTypes.EA_ACTION_OCCUPY_TOWER] = function()
	if g_eaPerson.bHasTower then return false end
	--do quick tally of vacant towers
	g_integersPos = 0
	for iPerson, tower in pairs(gWonders[EA_WONDER_ARCANE_TOWER]) do
		if not gPeople[iPerson] then	--last occupant is dead
			g_integersPos = g_integersPos + 1
			g_integers[g_integersPos] = iPerson
		end
	end
	return 0 < g_integersPos
end

TestTarget[GameInfoTypes.EA_ACTION_OCCUPY_TOWER] = function()
	if g_plot:GetImprovementType() ~= IMPROVEMENT_ARCANE_TOWER then return false end
	if g_iOwner ~= g_iPlayer and (g_iOwner ~= -1 or not g_plot:IsCityRadius(g_iPlayer)) then return false end
	--is it in vacant tower list?
	for i = 1, g_integersPos do
		local iPerson = g_integers[i]
		local tower = gWonders[EA_WONDER_ARCANE_TOWER][iPerson]
		if tower.iPlot == g_iPlot then
			g_int1 = iPerson

			g_value = 20	--TO DO: Calculate value as sum of tower mods 

			return true
		end
	end
	return false
end

SetUI[GameInfoTypes.EA_ACTION_OCCUPY_TOWER] = function()
	local improvementStr = g_plot:GetScriptData()
	MapModData.text = "Occupy " .. improvementStr .. " and make it your own"
end


SetAIValues[GameInfoTypes.EA_ACTION_OCCUPY_TOWER] = function()
	gg_aiOptionValues.i = g_value			
end

Finish[GameInfoTypes.EA_ACTION_OCCUPY_TOWER] = function()
	local tower = gWonders[EA_WONDER_ARCANE_TOWER][g_int1]
	gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson] = tower
	g_eaPerson.bHasTower = true
	gWonders[EA_WONDER_ARCANE_TOWER][g_int1] = nil
	SetTowerMods(g_iPlayer, g_iPerson)
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_value, false)
	g_specialEffectsPlot = g_plot
	UpdateInstanceWonder(g_iPlayer, EA_WONDER_ARCANE_TOWER)
end

--this is not table safe!
local EA_WONDER_TEMPLE_FAGUS =				GameInfoTypes.EA_WONDER_TEMPLE_FAGUS
local EA_WONDER_TEMPLE_NESR =				GameInfoTypes.EA_WONDER_TEMPLE_NESR
local EA_WONDER_TEMPLE_AZZANDARA_1 =				GameInfoTypes.EA_WONDER_TEMPLE_AZZANDARA_1
local EA_ACTION_TEMPLE_AHRIMAN_1 =				GameInfoTypes.EA_ACTION_TEMPLE_AHRIMAN_1
local IMPROVEMENT_TEMPLE_FAGUS =				GameInfoTypes.IMPROVEMENT_TEMPLE_FAGUS
local IMPROVEMENT_TEMPLE_AZZANDARA_1 =				GameInfoTypes.IMPROVEMENT_TEMPLE_AZZANDARA_1
local IMPROVEMENT_TEMPLE_AHRIMAN_1 =				GameInfoTypes.IMPROVEMENT_TEMPLE_AHRIMAN_1


--EA_ACTION_OCCUPY_TEMPLE
Test[GameInfoTypes.EA_ACTION_OCCUPY_TEMPLE] = function()
	local currentTempleMod = 0
	if g_eaPerson.templeID then
		currentTempleMod = gWonders[g_eaPerson.templeID].mod
	end
	--do quick tally of vacant temples applicable to this GP
	local first, last
	if g_eaPerson.subclass == "Druid" then
		first = EA_WONDER_TEMPLE_FAGUS
		last = EA_WONDER_TEMPLE_NESR
	elseif g_eaPerson.subclass == "Priest" or g_eaPerson.subclass == "Paladin" then
		first = EA_WONDER_TEMPLE_AZZANDARA_1
		last = EA_ACTION_TEMPLE_AHRIMAN_1 - 1	
	else
		first = EA_ACTION_TEMPLE_AHRIMAN_1
		last = EA_WONDER_TEMPLE_FAGUS - 1	
	end
	g_integersPos = 0
	for wonderID = first, last do
		local temple = gWonders[wonderID]
		if temple and currentTempleMod < temple.mod and not gPeople[temple.iPerson] then	--this is an upgrade and no occupant or last occupant is dead
			g_integersPos = g_integersPos + 1
			g_integers[g_integersPos] = wonderID
		end
	end
	if 0 < g_integersPos then
		g_int2 = currentTempleMod
		return true
	end
	return false
end

TestTarget[GameInfoTypes.EA_ACTION_OCCUPY_TEMPLE] = function()
	local improvementID = g_plot:GetImprovementType()
	if g_eaPerson.subclass == "Druid" then
		if improvementID < IMPROVEMENT_TEMPLE_FAGUS then return false end
	elseif g_eaPerson.subclass == "Priest" or g_eaPerson.subclass == "Paladin" then
		if improvementID < IMPROVEMENT_TEMPLE_AZZANDARA_1 or improvementID >= IMPROVEMENT_TEMPLE_AHRIMAN_1 then return false end
	else
		if improvementID < IMPROVEMENT_TEMPLE_AHRIMAN_1 or improvementID >= IMPROVEMENT_TEMPLE_FAGUS then return false end
	end

	if g_iOwner ~= g_iPlayer and (g_iOwner ~= -1 or not g_plot:IsCityRadius(g_iPlayer)) then return false end
	--is it in vacant temple list?
	for i = 1, g_integersPos do
		local wonderID = g_integers[i]
		local temple = gWonders[wonderID]
		if temple.iPlot == g_iPlot then
			g_int1 = wonderID

			g_value = temple.mod - g_int2	--how much better than previous temple

			return true
		end
	end
	return false
end

SetUI[GameInfoTypes.EA_ACTION_OCCUPY_TEMPLE] = function()
	local improvementStr = g_plot:GetScriptData()
	MapModData.text = "Occupy " .. improvementStr .. " and make it your own"
end


SetAIValues[GameInfoTypes.EA_ACTION_OCCUPY_TEMPLE] = function()
	gg_aiOptionValues.i = g_value			
end

Finish[GameInfoTypes.EA_ACTION_OCCUPY_TEMPLE] = function()
	local temple = gWonders[g_int1]
	temple.iPerson = g_iPerson
	g_eaPerson.templeID = g_int1
	--clear coccupancy of any other temple
	for wonderID = EA_WONDER_TEMPLE_AZZANDARA_1, EA_WONDER_TEMPLE_NESR do
		if wonderID ~= g_int1 and gWonder[wonderID] and gWonder[wonderID].iPerson == g_iPerson then
			gWonder[wonderID].iPerson = -1
		end
	end

	UseManaOrDivineFavor(g_iPlayer, g_iPerson, 20, false)	--20 mana or divine favor
	g_specialEffectsPlot = g_plot
	UpdateUniqueWonder(g_iPlayer, g_int1)
end
------------------------------------------------------------------------------------------------------------------------------
-- Prophecies
------------------------------------------------------------------------------------------------------------------------------
--Test, TestTarget, SetUI, SetAIValues, Do, Interrupt, Finish
--Caution! Calls to most religion methods cause CTD if religionID has not been founded yet

--EA_ACTION_PROPHECY_AHURADHATA
TestTarget[GameInfoTypes.EA_ACTION_PROPHECY_AHURADHATA] = function()
	--generic test fails before this if it is not city and our city
	return not g_city:IsHolyCityAnyReligion()
end

--[[
SetUI[GameInfoTypes.EA_ACTION_PROPHECY_AHURADHATA] = function()
	if g_bNonTargetTestsPassed and not g_bAllTestsPassed then
		MapModData.bShow = true
		MapModData.text = "You can make this prophecy in any non-holy city that you own"
	end
end
]]

Do[GameInfoTypes.EA_ACTION_PROPHECY_AHURADHATA] = function()
	FoundReligion(g_iPlayer, g_iCity, RELIGION_AZZANDARAYASNA)
	return true
end

--EA_ACTION_PROPHECY_MITHRA
--If holy city razed, then it can be founded by any Azzandara follower (making this city the new holy city)
--If holy city exists, then it caon only be made in the holy city
--For UI eye candy, the button should always show (disabled) if civ-req met and (holy city is razed or owned by non-Azz follower)
Test[GameInfoTypes.EA_ACTION_PROPHECY_MITHRA] = function()
	--If we are here then the religion has been founded and I am a follower
	local azzHolyCity = Game.GetHolyCityForReligion(RELIGION_AZZANDARAYASNA, -1)
	if azzHolyCity then
		return g_iPlayer ~= gReligions[RELIGION_AZZANDARAYASNA].founder	--holy city exists so player can't be founder
	else
		return true		--holy city razed so we can make a new one in any qualified city
	end
end

TestTarget[GameInfoTypes.EA_ACTION_PROPHECY_MITHRA] = function()
	--If we are here then we must be in a city of our own (otherwise, g_TestTargetSwitch = 0)
	local azzHolyCity = Game.GetHolyCityForReligion(RELIGION_AZZANDARAYASNA, -1)
	if azzHolyCity then
		if g_city == azzHolyCity then
			g_TestTargetSwitch = 1		--this is the holy city (and we own it) so we can do it here
			return true
		else
			g_TestTargetSwitch = 2		--holy city exists and we are not in it
			return false
		end
	else
		if g_city:IsHolyCityAnyReligion() then
			g_TestTargetSwitch = 3		--we could do it here if this were not a holy city
			return false
		else
			g_TestTargetSwitch = 4		--holy city razed so we can do it here
			return true
		end
	end
end

SetUI[GameInfoTypes.EA_ACTION_PROPHECY_MITHRA] = function()
	if g_TestTargetSwitch == 1 then
		MapModData.text = "Become the Azzandarayasna founder reborn"
	elseif g_TestTargetSwitch == 4 then
		MapModData.text = "Become the Azzandarayasna founder reborn in the Holy City Mithra"
	else
		--Change bShow only if 1) we are qualified and 2) holy city is not in the hands of an Azz follower; extra show logic is just UI candy
		if g_bNonTargetTestsPassed then
			local azzHolyCity = Game.GetHolyCityForReligion(RELIGION_AZZANDARAYASNA, -1)
			if azzHolyCity then
				local iOwner = azzHolyCity:GetOwner()
				if iOwner == g_iPlayer then
					MapModData.bShow = true
					MapModData.text = "[COLOR_WARNING_TEXT]Become the Azzandarayasna founder reborn; make this prophecy in the Holy City " .. azzHolyCity:GetName() .. "[ENDCOLOR]"
				elseif gPlayers[iOwner].religionID ~= RELIGION_AZZANDARAYASNA then
					MapModData.bShow = true
					MapModData.text = "[COLOR_WARNING_TEXT]Become the Azzandarayasna founder reborn; conquer the Holy City " .. azzHolyCity:GetName() .. " and make this prophecy there[ENDCOLOR]"
				end
			else
				MapModData.bShow = true
				MapModData.text = "[COLOR_WARNING_TEXT]Become the Azzandarayasna founder reborn; make this prophecy in any of your cities that is not another religion's holy city[ENDCOLOR]"
			end	
		end
	end
end

Do[GameInfoTypes.EA_ACTION_PROPHECY_MITHRA] = function()
	Game.SetFounder(RELIGION_AZZANDARAYASNA, g_iPlayer)
	if not Game.GetHolyCityForReligion(RELIGION_AZZANDARAYASNA, -1) then	--no holy city
		Game.SetHolyCity(RELIGION_AZZANDARAYASNA, g_city)					--	make this the new one
		g_city:SetName("TXT_KEY_EACITY_MITHRA", false)						--	rename it to Mithra
	end

	--convert all Anra to Azz
	if gReligions[RELIGION_ANRA] then
		for city in g_player:Cities() do
			city:ConvertPercentFollowers(RELIGION_AZZANDARAYASNA, RELIGION_ANRA, 100)
		end
	end
	UpdateCivReligion(g_iPlayer)
	return true
end

--EA_ACTION_PROPHECY_MA
Test[GameInfoTypes.EA_ACTION_PROPHECY_MA] = function()
	return false
end

Do[GameInfoTypes.EA_ACTION_PROPHECY_MA] = function()
	return true
end

--EA_ACTION_PROPHECY_VA
--displays EaAction.Help, "All civilizations that know Maleficium will fall"
SetAIValues[GameInfoTypes.EA_ACTION_PROPHECY_VA] = function()
	gg_aiOptionValues.i = 100							--Game.GetGameTurn() / 4 - 25	--will happen sometime after turn 100
end

Do[GameInfoTypes.EA_ACTION_PROPHECY_VA] = function()	--All civs with Maleficium will fall
	print("Prophecy of Va")
	if gReligions[RELIGION_AZZANDARAYASNA] and not gReligions[RELIGION_ANRA] then	
		--Azz is founded but Anra is not; maybe Anra will be founded now
		local anraHolyCity

		--First, if Azz Holy City Falls then that is the new Anra Holy city
		local azzHolyCity = Game.GetHolyCityForReligion(RELIGION_AZZANDARAYASNA, -1)
		local iAzzHolyCityOwner = -1
		if azzHolyCity then
			iAzzHolyCityOwner = azzHolyCity:GetOwner()
			local azzHolyCityOwner = Players[iAzzHolyCityOwner]
			if Teams[azzHolyCityOwner:GetTeam()]:IsHasTech(TECH_MALEFICIUM) then
				print("Azzandarayasna Holy City will fall")
				anraHolyCity = azzHolyCity
			end
		end

		--Otherwise, Anra may or may not arize elsewhere
		if not anraHolyCity then
			if azzHolyCity then
				print("Picking Falling city that is farthest from Azz Holy City as new Anra Holy City")
				local azzCenterX, azzCenterY = azzHolyCity:GetX(), azzHolyCity:GetY()
				local farthestCityDistance = 0
				for iLoopPlayer, eaLoopPlayer in pairs(fullCivs) do
					local loopPlayer = Players[iLoopPlayer]
					local loopTeam = Teams[loopPlayer:GetTeam()]
					if loopTeam:IsHasTech(TECH_MALEFICIUM) then
						for city in loopPlayer:Cities() do
							if not city:IsHolyCityAnyReligion() and city:GetReligiousMajority() == RELIGION_AZZANDARAYASNA then
								local distance = PlotDistance(azzCenterX, azzCenterY, city:GetX(), city:GetY())
								if farthestCityDistance < distance then
									anraHolyCity = city
									farthestCityDistance = distance
								end
							end
						end
					end
				end
			else
				print("Picking Falling city with most Azz followers as new Anra Holy City")
				local mostFollowers = 0
				for iLoopPlayer, eaLoopPlayer in pairs(fullCivs) do
					local loopPlayer = Players[iLoopPlayer]
					local loopTeam = Teams[loopPlayer:GetTeam()]
					if loopTeam:IsHasTech(TECH_MALEFICIUM) then
						for city in loopPlayer:Cities() do
							if not city:IsHolyCityAnyReligion() and city:GetReligiousMajority() == RELIGION_AZZANDARAYASNA then
								local followers = city:GetNumFollowers(RELIGION_AZZANDARAYASNA)
								if mostFollowers < followers then
									mostFollowers = followers
									anraHolyCity = city
								end
							end
						end
					end
				end			
			end
		end

		--If we have determined a new Anra holy city, then found it (otherwise, it is not founded)
		if anraHolyCity then
			FoundReligion(anraHolyCity:GetOwner(), anraHolyCity:GetID(), RELIGION_ANRA)
		end
	end

	--All who know Maleficium become Fallen (can happen with or without Anra founding)
	for iLoopPlayer, eaLoopPlayer in pairs(fullCivs) do	
		local loopPlayer = Players[iLoopPlayer]
		local loopTeam = Teams[loopPlayer:GetTeam()]
		if loopTeam:IsHasTech(TECH_MALEFICIUM) then
			BecomeFallen(iLoopPlayer)
		end
		UpdateCivReligion(iLoopPlayer)
	end
	return true
end

--EA_ACTION_PROPHECY_ANRA
TestTarget[GameInfoTypes.EA_ACTION_PROPHECY_ANRA] = function()
	return not g_city:IsHolyCityAnyReligion()
end




Do[GameInfoTypes.EA_ACTION_PROPHECY_ANRA] = function()
	FoundReligion(g_iPlayer, g_iCity, RELIGION_ANRA)
	BecomeFallen(g_iPlayer)
	return true
end

--EA_ACTION_PROPHECY_AESHEMA
Test[GameInfoTypes.EA_ACTION_PROPHECY_AESHEMA] = function()
	return false
end

Do[GameInfoTypes.EA_ACTION_PROPHECY_AESHEMA] = function()
	return true
end

------------------------------------------------------------------------------------------------------------------------------
-- Wonders
------------------------------------------------------------------------------------------------------------------------------

--EA_ACTION_KOLOSSOS
SetAIValues[GameInfoTypes.EA_ACTION_KOLOSSOS] = function()
	local culture = (g_city:GetCultureRateModifier() + 100) / 25	--4c
	gg_aiOptionValues.p = culture
	gg_aiOptionValues.i = g_mod * 100		--proxy instant value for +mod% str/rng for all military units (land and sea)
end

SetUI[GameInfoTypes.EA_ACTION_KOLOSSOS] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increases experience of units built in city by "..g_mod
	end
end

--EA_ACTION_MEGALOS_FAROS
TestTarget[GameInfoTypes.EA_ACTION_MEGALOS_FAROS] = function()
	return g_city:IsCoastal(10)
end

SetUI[GameInfoTypes.EA_ACTION_MEGALOS_FAROS] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increases revenue from all foreign trade routes by "..g_mod.."%"
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_MEGALOS_FAROS] = function()
	local culture = (g_city:GetCultureRateModifier() + 100) / 25	--4c
	gg_aiOptionValues.p = culture + g_mod * 1.5	--proxy per turn value for +mod% gold from all trade routes in all cities
end

--EA_ACTION_HANGING_GARDENS
SetAIValues[GameInfoTypes.EA_ACTION_HANGING_GARDENS] = function()
	local culture = (g_city:GetCultureRateModifier() + 100) / 25	--4c
	gg_aiOptionValues.p = culture + g_mod * 1.5	--proxy
end

SetUI[GameInfoTypes.EA_ACTION_HANGING_GARDENS] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increases culture in city by "..g_mod.."%[NEWLINE]Increase food in all cities by "..g_mod.."%"
	end
end


--EA_ACTION_UUC_YABNAL
SetAIValues[GameInfoTypes.EA_ACTION_UUC_YABNAL] = function()
	local culture = (g_city:GetCultureRateModifier() + 100) / 25	--4c
	local production = g_mod * (100 + g_city:GetBaseYieldRateModifier(YIELD_PRODUCTION))/100
	gg_aiOptionValues.p = culture + production + 5	-- +5 is proxy for +20% work rate
end

SetUI[GameInfoTypes.EA_ACTION_UUC_YABNAL] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Slaves work 25% faster[NEWLINE]Increases production in city by "..g_mod.."%"
	end
end


--EA_ACTION_THE_LONG_WALL
SetAIValues[GameInfoTypes.EA_ACTION_THE_LONG_WALL] = function()
	local culture = (g_city:GetCultureRateModifier() + 100) / 25	--4c
	local proxy = g_mod * 100		--instant value for mod x 10% chance that enemies lose one movement point each turn within your borders
	gg_aiOptionValues.p = culture + proxy
end

SetUI[GameInfoTypes.EA_ACTION_THE_LONG_WALL] = function()
	if g_bAllTestsPassed then
		if g_mod < 10 then
			MapModData.text = "May cause enemy units to loose 1 movement point when in borders (".. (10 * g_mod) .."% chance)"
		else
			local extraPoints = g_mod % 10 
			local pointsLost = (g_mod - extraPoints) / 10
			MapModData.text = "Cause enemy units to loose "..pointsLost.." movement point(s) when in borders; may cause them to loose 1 additional movement point (".. (10 * extraPoints) .."% chance)"
		end
	end
end


--EA_ACTION_CLOG_MOR
SetAIValues[GameInfoTypes.EA_ACTION_CLOG_MOR] = function()
	local culture = (g_city:GetCultureRateModifier() + 100) / 25	--4c
	local proxy = g_mod * 1.5		--per turn value for -mod% purchase cost for all buildings
	gg_aiOptionValues.p = culture + proxy
end

SetUI[GameInfoTypes.EA_ACTION_CLOG_MOR] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Reduces purchase cost for all buildings by "..g_mod.."%"
	end
end


--EA_ACTION_DA_BAOEN_SI
SetAIValues[GameInfoTypes.EA_ACTION_DA_BAOEN_SI] = function()
	local culture = g_mod * (g_city:GetCultureRateModifier() + 100) / 100
	local proxy = g_mod * 2		--per turn value for +mod happiness
	gg_aiOptionValues.p = culture + proxy
end

SetUI[GameInfoTypes.EA_ACTION_DA_BAOEN_SI] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Provides "..g_mod.." happiness"
	end
end

--EA_ACTION_NATIONAL_TREASURY
SetUI[GameInfoTypes.EA_ACTION_NATIONAL_TREASURY] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Will provide " .. g_mod/2 .. "% interest on your treasury at this city"
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_NATIONAL_TREASURY] = function()
	local treasury = g_player:GetGold()
	local treasuryMin = Game.GetGameTurn() * 2	--assume this minimum ammount (likely to be small at first, better to go do trade route)
	treasury = treasury < treasuryMin and treasuryMin or treasury
	gg_aiOptionValues.p = g_mod * treasury / 200		--mod x 0.5% interest
end

Finish[GameInfoTypes.EA_ACTION_NATIONAL_TREASURY] = function()
	if g_iPlayer == g_iActivePlayer then
		UpdateCityYields(g_iPlayer, g_iCity, "Gold")
	end
	return true
end

--EA_ACTION_STANHENCG
SetAIValues[GameInfoTypes.EA_ACTION_STANHENCG] = function()
	gg_aiOptionValues.p = g_mod		--this will be mod mana
end

SetUI[GameInfoTypes.EA_ACTION_STANHENCG] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Generates "..g_mod.." mana per turn"
	end
end

--EA_WONDER_PYRAMID
SetAIValues[GameInfoTypes.EA_WONDER_PYRAMID] = function()
	gg_aiOptionValues.p = g_mod		--proxy
end

SetUI[GameInfoTypes.EA_WONDER_PYRAMID] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increases the apparent size of your civilization and military might by "..g_mod.."%"
	end
end

--EA_ACTION_GREAT_LIBRARY
SetAIValues[GameInfoTypes.EA_ACTION_GREAT_LIBRARY] = function()
	gg_aiOptionValues.p = g_mod		--proxy
end

SetUI[GameInfoTypes.EA_ACTION_GREAT_LIBRARY] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Reduces research cost of all techs by "..g_mod.."%"
	end
end

--EA_ACTION_ARCANE_TOWER
Test[GameInfoTypes.EA_ACTION_ARCANE_TOWER] = function()
	return not g_eaPerson.bHasTower
end

SetUI[GameInfoTypes.EA_ACTION_ARCANE_TOWER] = function()
	if g_bAllTestsPassed then
		if not g_eaPerson.name then
			UngenericizePerson(g_iPlayer, g_iPerson, nil)
		end
		local str = Locale.Lookup(g_eaPerson.name)
		if string.sub(str, -1) == "s" then
			str = str .. "' Tower"
		else
			str = str .. "'s Tower"
		end
		MapModData.text = str .. " will gain spell modifiers and level up with its owner; these modifiers will combine with the caster's own when casting from the Tower"
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_ARCANE_TOWER] = function()
	gg_aiOptionValues.p = g_eaPerson.level * 10 
end

Finish[GameInfoTypes.EA_ACTION_ARCANE_TOWER] = function()
	g_eaPerson.bHasTower = true
	if not g_eaPerson.name then
		UngenericizePerson(g_iPlayer, g_iPerson, nil)
	end
	local str = Locale.Lookup(g_eaPerson.name)
	if string.sub(str, -1) == "s" then
		str = str .. "' Tower"
	else
		str = str .. "'s Tower"
	end
	g_plot:SetScriptData(str)
	gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson] = {iPlot = g_iPlot, iNamedFor = g_iPerson, iPlayer = -1}
	SetTowerMods(g_iPlayer, g_iPerson)
	UpdateInstanceWonder(g_iPlayer, EA_WONDER_ARCANE_TOWER)
	return true
end



------------------------------------------------------------------------------------------------------------------------------
-- Epics
------------------------------------------------------------------------------------------------------------------------------

--EA_ACTION_EPIC_VOLUSPA
SetUI[GameInfoTypes.EA_ACTION_EPIC_VOLUSPA] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increases Cultural Level by " .. g_mod/10
	end
end

--EA_ACTION_EPIC_HAVAMAL
SetUI[GameInfoTypes.EA_ACTION_EPIC_HAVAMAL] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increases happiness by " .. g_mod
	end
end

Finish[GameInfoTypes.EA_ACTION_EPIC_HAVAMAL] = function()
	ResetHappyUnhappyFromMod(g_iPlayer)
end

--EA_ACTION_EPIC_VAFTHRUTHNISMAL
SetUI[GameInfoTypes.EA_ACTION_EPIC_VAFTHRUTHNISMAL] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Decreases the cost of non-Arcane techs by " .. g_mod .. "%"
	end
end

--EA_ACTION_EPIC_GRIMNISMAL
SetUI[GameInfoTypes.EA_ACTION_EPIC_GRIMNISMAL] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increases leader effects by " .. g_mod .. "%"
	end
end

Finish[GameInfoTypes.EA_ACTION_EPIC_GRIMNISMAL] = function()
	ResetPlayerGPMods(g_iPlayer)
end

--EA_ACTION_EPIC_HYMISKVITHA
SetUI[GameInfoTypes.EA_ACTION_EPIC_HYMISKVITHA] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Each Winery, Brewery and Distillery increases city culture by " .. g_mod .. "%"
	end
end

--EA_ACTION_EPIC_NATIONAL
Test[GameInfoTypes.EA_ACTION_EPIC_NATIONAL] = function()
	return false
end

------------------------------------------------------------------------------------------------------------------------------
-- Artifacts
------------------------------------------------------------------------------------------------------------------------------

--EA_ACTION_TOME_OF_EQUUS
SetUI[GameInfoTypes.EA_ACTION_TOME_OF_EQUUS] = function()
	if g_bAllTestsPassed then
		MapModData.text = (g_mod * 2).."% faster research for Horseback Riding and War Horses[NEWLINE]"..Floor(g_mod/2).. "experience for horse-mounted units"
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]Tomes can be written in cities with a library[ENDCOLOR]"
	end
end

Finish[GameInfoTypes.EA_ACTION_TOME_OF_EQUUS] = function()
	--Creator gets xp boost for existing horse-mounted (thereafter, only given for new units)
	local xpChange = Floor(g_mod/2)
	for unit in g_player:Units() do
		if unit:GetUnitCombatType() == UNITCOMBAT_MOUNTED then
			unit:ChangeExperience(xpChange)
		end
	end
	
end

--EA_ACTION_TOME_OF_BEASTS
SetUI[GameInfoTypes.EA_ACTION_TOME_OF_BEASTS] = function()
	if g_bAllTestsPassed then
		MapModData.text = (g_mod * 1.5).."% faster research for Mounted Elephants, War Elephants, Domestication, Animal Breeding, Tracking, Animal Mastery and Beast Breeding"
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]Tomes can be written in cities with a library[ENDCOLOR]"
	end
end

--EA_ACTION_TOME_OF_THE_LEVIATHAN
SetUI[GameInfoTypes.EA_ACTION_TOME_OF_THE_LEVIATHAN] = function()
	if g_bAllTestsPassed then
		MapModData.text = (g_mod * 2).."% faster research for Harpoons, Sailing, Shipbuilding and Whaling[NEWLINE]+2 research from Whales"
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]Tomes can be written in cities with a library[ENDCOLOR]"
	end
end

--EA_ACTION_TOME_OF_HARVESTS
SetUI[GameInfoTypes.EA_ACTION_TOME_OF_HARVESTS] = function()
	if g_bAllTestsPassed then
		MapModData.text = (g_mod * 2).."% faster research for Milling, Zymurgy, Irrigation, Calendar, Crop Rotation and Forestry[NEWLINE]+1 food from improved Wheat, Wine, Sugar and Citrus"
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]Tomes can be written in cities with a library[ENDCOLOR]"
	end
end

--EA_ACTION_TOME_OF_TOMES
SetUI[GameInfoTypes.EA_ACTION_TOME_OF_TOMES] = function()
	if g_bAllTestsPassed then
		MapModData.text = (g_mod * 2).."% faster research for Logic, Metaphysics and Transcendental Thought[NEWLINE]Provides 1/3 benifit from all other existing Tomes"
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]Tomes can be written in cities with a library[ENDCOLOR]"
	end
end

--EA_ACTION_TOME_OF_AESTHETICS
SetUI[GameInfoTypes.EA_ACTION_TOME_OF_AESTHETICS] = function()
	if g_bAllTestsPassed then
		MapModData.text = (g_mod * 2).."% faster research for Drama, Literature, Music and Æsthetics[NEWLINE]+"..g_mod.."% culture in all cities"
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]Tomes can be written in cities with a library[ENDCOLOR]"
	end
end

--EA_ACTION_TOME_OF_AXIOMS
SetUI[GameInfoTypes.EA_ACTION_TOME_OF_AXIOMS] = function()
	if g_bAllTestsPassed then
		MapModData.text = (g_mod * 2).."% faster research for Mathematics, Physics, Chemistry, Astronomy, Alchemy and Medicine[NEWLINE]+5% research from Universities"
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]Tomes can be written in cities with a library"
	end
end

--EA_ACTION_TOME_OF_FORM
SetUI[GameInfoTypes.EA_ACTION_TOME_OF_FORM] = function()
	if g_bAllTestsPassed then
		MapModData.text = (g_mod * 2).."% faster research for Masonry, Construction, Engineering and Architecture[NEWLINE]+"..g_mod.."% construction all buildings and wonders"
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]Tomes can be written in cities with a library[ENDCOLOR]"
	end
end

--EA_ACTION_TOME_OF_METALLURGY
SetUI[GameInfoTypes.EA_ACTION_TOME_OF_METALLURGY] = function()
	if g_bAllTestsPassed then
		MapModData.text = (g_mod * 2).."% faster research for Bronze Working, Iron Working, Metal Casting and Mithril Working[NEWLINE]+1p from mined copper, iron, mithril[NEWLINE]+1g from mined silver, gold"
	elseif g_bNonTargetTestsPassed then
		MapModData.bShow = true
		MapModData.text = "[COLOR_WARNING_TEXT]Tomes can be written in cities with a library[ENDCOLOR]"
	end
end

------------------------------------------------------------------------------------------------------------------------------
-- Other Great Works
------------------------------------------------------------------------------------------------------------------------------
--EA_ACTION_LAND_TRADE_ROUTE
Test[GameInfoTypes.EA_ACTION_LAND_TRADE_ROUTE] = function()
	--There is no test here; but we need to set g_tradeAvailableTable and gg_tradeAvailableTable
	MapModData.bBypassOnCanCreateTradeRoute = true
	g_tradeAvailableTable = g_player:GetTradeRoutesAvailable()
	MapModData.bBypassOnCanCreateTradeRoute = false
	print("Refreshing g_tradeAvailableTable from Test[GameInfoTypes.EA_ACTION_LAND_TRADE_ROUTE]")
	local numRoutes = #g_tradeAvailableTable

	--Update global gg_tradeAvailableTable used by EaAIActions.lua
	for i = 1, numRoutes do
		gg_tradeAvailableTable[i] = g_tradeAvailableTable[i]
	end
	for i = numRoutes + 1, #gg_tradeAvailableTable do
		gg_tradeAvailableTable[i] = nil
	end
	return true
end

TestTarget[GameInfoTypes.EA_ACTION_LAND_TRADE_ROUTE] = function()
	print("TestTarget[GameInfoTypes.EA_ACTION_LAND_TRADE_ROUTE]")
	for i = g_integersPos, 1, -1 do
		g_integers[i] = nil
	end
	g_integersPos = 0
	for i = 1, #g_tradeAvailableTable do
		local route = g_tradeAvailableTable[i]
		--print(g_city, route.ToCity, route.Domain, route.TurnsLeft)
		--print(g_city:GetID(), route.ToCity:GetID())
		--print(g_city:GetName(), route.ToCity:GetName())
		if route.ToCity == g_city and route.Domain == DOMAIN_LAND then
			if route.TurnsLeft == -1 then
				local fromCity = route.FromCity
				local fromCityPlotIndex = fromCity:Plot():GetPlotIndex()
				local fromEaCity = gCities[fromCityPlotIndex]		
				if fromEaCity.openLandTradeRoutes[g_iPlot] ~= route.ToID then		--a merchant hasn't already opend this route
					g_integersPos = g_integersPos + 1
					g_integers[g_integersPos] = i
				else
					g_testTargetSwitch = 1	--at least 1 trade route already established with this city at some time
				end
			else
				g_testTargetSwitch = 1
			end
		end
	end
	print("#g_tradeAvailableTable, g_integersPos = ", #g_tradeAvailableTable, g_integersPos)

	if 0 < g_integersPos then
		--disallow if someone else from my civ making one now
		for iTestPerson, eaTestPerson in pairs(gPeople) do
			if eaTestPerson.iPlayer == g_iPlayer and iTestPerson ~= g_iPerson then
				if eaTestPerson.x == g_x and eaTestPerson.y == g_y and eaTestPerson.eaActionID == g_eaAction.ID then
					g_testTargetSwitch = 3	--"Another Merchant from your civilization is currently establishing a trade route in this city"
					return false
				end
			end
		end
		return true
	else
		if g_testTargetSwitch == 0 then
			g_testTargetSwitch = 2	--"No Trade Routes can be established with this city"
		end
		return false
	end
end

SetUI[GameInfoTypes.EA_ACTION_LAND_TRADE_ROUTE] = function()
	if g_bNonTargetTestsPassed and g_bIsCity then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			MapModData.text = "Open Trade Route with " .. g_tradeAvailableTable[g_integers[1] ].ToCityName
			if 1 < g_integersPos then
				for i = 2, g_integersPos - 1 do
					MapModData.text = MapModData.text .. ", " .. g_tradeAvailableTable[g_integers[i] ].ToCityName
				end
				MapModData.text = MapModData.text .. " or " .. g_tradeAvailableTable[g_integers[g_integersPos] ].ToCityName
			end
		elseif g_testTargetSwitch == 1 then
			MapModData.text = "[COLOR_WARNING_TEXT]No additional Trade Routes can be established with this city[ENDCOLOR]"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]No Trade Routes can be established with this city[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]Only one Merchant at a time can establish Trade Routes in a particular city[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_LAND_TRADE_ROUTE] = function()
	--gives value based on best possible route and all possible routes to this city (should draw merchant to great trade destination city)
	local summedValue = 0
	local bestValue = 0
	for i = 1, g_integersPos do
		local route = g_tradeAvailableTable[g_integers[i] ]
		local valueThisRoute = route.FromGPT + route.FromScience + 1.5 * (route.ToFood + route.ToProduction)
		summedValue = summedValue + valueThisRoute
		if bestValue < valueThisRoute then
			bestValue = valueThisRoute
		end
	end

	gg_aiOptionValues.p = bestValue / 100 + summedValue / 300
end

Finish[GameInfoTypes.EA_ACTION_LAND_TRADE_ROUTE] = function()

	--TO DO: human pops UI to choose FromCity

	--AI logic for now
	local bestRoute
	local bestValue = 0
	for i = 1, g_integersPos do
		local route = g_tradeAvailableTable[g_integers[i] ]
		local valueThisRoute = route.FromGPT + route.FromScience + 1.5 * (route.ToFood + route.ToProduction)
		if bestValue < valueThisRoute then
			bestValue = valueThisRoute
			bestRoute = route
		end
	end
	local fromCity = bestRoute.FromCity

	--debug
	local toX, toY = bestRoute.ToCity:GetX(), bestRoute.ToCity:GetY()
	if g_x ~= toX or g_y ~= toY then
		print("!!!Warning: trade rounte missmatch ", g_x, toX, g_y, toY)
	end

	--open route in eaCity object
	local fromCityPlot = fromCity:Plot()
	local fromEaCity = gCities[fromCityPlot:GetPlotIndex()]
	fromEaCity.openLandTradeRoutes[g_iPlot] = bestRoute.ToID		--open route associated with particular eaCity and iPlayer (still there if city conquered and recaptured)

	--free caravan starts the route
	g_specialEffectsPlot = fromCityPlot
	local unit = g_player:InitUnit(GameInfoTypes.UNIT_CARAVAN, fromCity:GetX(), fromCity:GetY())
	unit:PushMission(MissionTypes.MISSION_ESTABLISH_TRADE_ROUTE, g_iPlot, 0, 0, 0, 1)
	return true
end


--EA_ACTION_SEA_TRADE_ROUTE
Test[GameInfoTypes.EA_ACTION_SEA_TRADE_ROUTE] = function()
	--There is no test here; but we need to set g_tradeAvailableTable and gg_tradeAvailableTable
	MapModData.bBypassOnCanCreateTradeRoute = true
	g_tradeAvailableTable = g_player:GetTradeRoutesAvailable()
	MapModData.bBypassOnCanCreateTradeRoute = false
	print("Refreshing g_tradeAvailableTable from Test[GameInfoTypes.EA_ACTION_SEA_TRADE_ROUTE]")
	local numRoutes = #g_tradeAvailableTable

	--Update global gg_tradeAvailableTable used by EaAIActions.lua
	for i = 1, numRoutes do
		gg_tradeAvailableTable[i] = g_tradeAvailableTable[i]
	end
	for i = numRoutes + 1, #gg_tradeAvailableTable do
		gg_tradeAvailableTable[i] = nil
	end
	return true
end

TestTarget[GameInfoTypes.EA_ACTION_SEA_TRADE_ROUTE] = function()
	print("TestTarget[GameInfoTypes.EA_ACTION_SEA_TRADE_ROUTE]")
	for i = g_integersPos, 1, -1 do
		g_integers[i] = nil
	end
	g_integersPos = 0
	for i = 1, #g_tradeAvailableTable do
		local route = g_tradeAvailableTable[i]
		print(g_city, route.ToCity, route.Domain, route.TurnsLeft)
		print(g_city:GetID(), route.ToCity:GetID())
		print(g_city:GetName(), route.ToCity:GetName())
		if route.ToCity == g_city and route.Domain == DOMAIN_SEA then
			if route.TurnsLeft == -1 then
				local fromCity = route.FromCity
				local fromCityPlotIndex = fromCity:Plot():GetPlotIndex()
				local fromEaCity = gCities[fromCityPlotIndex]		
				if fromEaCity.openSeaTradeRoutes[g_iPlot] ~= route.ToID then		--a merchant hasn't already opend this route
					g_integersPos = g_integersPos + 1
					g_integers[g_integersPos] = i
				else
					g_testTargetSwitch = 1	--at least 1 trade route already established with this city at some time
				end
			else
				g_testTargetSwitch = 1
			end
		end
	end
	print("#g_tradeAvailableTable, g_integersPos = ", #g_tradeAvailableTable, g_integersPos)

	if 0 < g_integersPos then
		--disallow if someone else from my civ making one now
		for iTestPerson, eaTestPerson in pairs(gPeople) do
			if eaTestPerson.iPlayer == g_iPlayer and iTestPerson ~= g_iPerson then
				if eaTestPerson.x == g_x and eaTestPerson.y == g_y and eaTestPerson.eaActionID == g_eaAction.ID then
					g_testTargetSwitch = 3	--"Another Merchant from your civilization is currently establishing a trade route in this city"
					return false
				end
			end
		end
		return true
	else
		if g_testTargetSwitch == 0 then
			g_testTargetSwitch = 2	--"No Trade Routes can be established with this city"
		end
		return false
	end
end

SetUI[GameInfoTypes.EA_ACTION_SEA_TRADE_ROUTE] = function()
	if g_bNonTargetTestsPassed and g_bIsCity then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			MapModData.text = "Open Trade Route with " .. g_tradeAvailableTable[g_integers[1] ].ToCityName
			if 1 < g_integersPos then
				for i = 2, g_integersPos - 1 do
					MapModData.text = MapModData.text .. ", " .. g_tradeAvailableTable[g_integers[i] ].ToCityName
				end
				MapModData.text = MapModData.text .. " or " .. g_tradeAvailableTable[g_integers[g_integersPos] ].ToCityName
			end
		elseif g_testTargetSwitch == 1 then
			MapModData.text = "[COLOR_WARNING_TEXT]No additional Trade Routes can be established with this city[ENDCOLOR]"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]No Trade Routes can be established with this city[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]Only one Merchant at a time can establish Trade Routes in a particular city[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_SEA_TRADE_ROUTE] = function()
	--gives value based on best possible route and all possible routes to this city (should draw merchant to great trade destination city)
	local summedValue = 0
	local bestValue = 0
	for i = 1, g_integersPos do
		local route = g_tradeAvailableTable[g_integers[i] ]
		local valueThisRoute = route.FromGPT + route.FromScience + 1.5 * (route.ToFood + route.ToProduction)
		summedValue = summedValue + valueThisRoute
		if bestValue < valueThisRoute then
			bestValue = valueThisRoute
		end
	end

	gg_aiOptionValues.p = bestValue / 100 + summedValue / 300
end

Finish[GameInfoTypes.EA_ACTION_SEA_TRADE_ROUTE] = function()
	--human pops UI to choose FromCity

	--AI logic for now
	local bestRoute
	local bestValue = 0
	for i = 1, g_integersPos do
		local route = g_tradeAvailableTable[g_integers[i] ]
		local valueThisRoute = route.FromGPT + route.FromScience + 1.5 * (route.ToFood + route.ToProduction)
		if bestValue < valueThisRoute then
			bestValue = valueThisRoute
			bestRoute = route
		end
	end
	local fromCity = bestRoute.FromCity

	--debug
	local toX, toY = bestRoute.ToCity:GetX(), bestRoute.ToCity:GetY()
	if g_x ~= toX or g_y ~= toY then
		print("!!!Warning: trade rounte missmatch ", g_x, toX, g_y, toY)
	end

	--open route in eaCity object
	local fromCityPlot = fromCity:Plot()
	local fromEaCity = gCities[fromCityPlot:GetPlotIndex()]
	fromEaCity.openSeaTradeRoutes[g_iPlot] = bestRoute.ToID		--open route associated with particular eaCity and iPlayer (still there if city conquered and recaptured)
	
	--free cargo ship starts the route
	g_specialEffectsPlot = fromCityPlot
	local unit = g_player:InitUnit(GameInfoTypes.UNIT_CARGO_SHIP, fromCity:GetX(), fromCity:GetY())
	unit:PushMission(MissionTypes.MISSION_ESTABLISH_TRADE_ROUTE, g_iPlot, 2, 0, 0, 1)				--2nd arg?
	return true
end


--EA_ACTION_TRADE_HOUSE
TestTarget[GameInfoTypes.EA_ACTION_TRADE_HOUSE] = function()
	return false	--rebuild for BNW

end


--EA_ACTION_TRADE_MISSION
TestTarget[GameInfoTypes.EA_ACTION_TRADE_MISSION] = function()
	return false	--rebuild for BNW

end





------------------------------------------------------------------------------------------------------------------------------
-- Theistic religion spread
------------------------------------------------------------------------------------------------------------------------------

--EA_ACTION_PROSELYTIZE
TestTarget[GameInfoTypes.EA_ACTION_PROSELYTIZE] = function()
	local totalConversions, bFlip, religionConversionTable = GetConversionOutcome(g_city, RELIGION_AZZANDARAYASNA, g_mod)
	--print("GetConversionOutcome", totalConversions, bFlip, religionConversionTable)
	if totalConversions == 0 then return false end
	g_tablePointer = religionConversionTable
	g_bool1 = bFlip
	g_value = 10 * totalConversions + (bFlip and 100 or 0) --for AI; passing conversion threshold worth 10 citizens 
	--print(g_value)
	return true
end

SetUI[GameInfoTypes.EA_ACTION_PROSELYTIZE] = function()
	if g_bNonTargetTestsPassed and g_bIsCity then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			local atheistsConverted = g_tablePointer[-1]
			if atheistsConverted > 0 then
				MapModData.text = "Will convert " .. atheistsConverted .. " non-followers[NEWLINE]"
			else
				MapModData.text = ""
			end
			for i = 0, HIGHEST_RELIGION_ID do
				local numConverted = g_tablePointer[i]
				if numConverted > 0 then
					MapModData.text = MapModData.text .. "Will convert ".. numConverted .. " followers of ".. Locale.ConvertTextKey(GameInfo.Religions[i].Description) .. "[NEWLINE]"
				end
			end
			if g_bool1 then
				MapModData.text = MapModData.text .. "Azzandarayasna will become the city's dominant religion"
			end
		else
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot convert any citizens in this city[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_PROSELYTIZE] = function()
	if g_iOwner == g_iPlayer then
		gg_aiOptionValues.i = g_value * 2	--double value for converting our own
	else
		gg_aiOptionValues.i = g_value
	end
end

Finish[GameInfoTypes.EA_ACTION_PROSELYTIZE] = function()
	print("Finish EA_ACTION_PROSELYTIZE")
	for i = -1, HIGHEST_RELIGION_ID do
		if g_tablePointer[i] > 0 then
			print("about to convert", i, g_tablePointer[i])
			--need percentage (round up or down???)
			local convertPercent = Floor(1 + 100 * g_tablePointer[i] / g_city:GetNumFollowers(i))
			g_city:ConvertPercentFollowers(RELIGION_AZZANDARAYASNA, i, convertPercent)
		end
	end
	UpdateCivReligion(g_iOwner)
	return true
end

--EA_ACTION_ANTIPROSELYTIZE
TestTarget[GameInfoTypes.EA_ACTION_ANTIPROSELYTIZE] = function()
	local totalConversions, bFlip, religionConversionTable = GetConversionOutcome(g_city, RELIGION_ANRA, g_mod)
	--print("GetConversionOutcome", totalConversions, bFlip, religionConversionTable)
	if totalConversions == 0 then return false end
	g_tablePointer = religionConversionTable
	g_bool1 = bFlip
	g_value = 10 * totalConversions + (bFlip and 100 or 0) --for AI; passing conversion threshold worth 10 citizens 
	--print(g_value)
	return true
end

SetUI[GameInfoTypes.EA_ACTION_ANTIPROSELYTIZE] = function()
	if g_bNonTargetTestsPassed and g_bIsCity then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			local atheistsConverted = g_tablePointer[-1]
			if atheistsConverted > 0 then
				MapModData.text = "Will convert " .. atheistsConverted .. " non-followers[NEWLINE]"
			else
				MapModData.text = ""
			end
			for i = 0, HIGHEST_RELIGION_ID do
				local numConverted = g_tablePointer[i]
				if numConverted > 0 then
					MapModData.text = MapModData.text .. "Will convert ".. numConverted .. " followers of ".. Locale.ConvertTextKey(GameInfo.Religions[i].Description) .. "[NEWLINE]"
				end
			end
			if g_bool1 then
				MapModData.text = MapModData.text .. "Anra will become the city's dominant religion"
			end
		else
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot convert any citizens in this city[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_ANTIPROSELYTIZE] = function()
	if g_iOwner == g_iPlayer then
		gg_aiOptionValues.i = g_value * 2	--double value for converting our own
	else
		gg_aiOptionValues.i = g_value
	end
end

Finish[GameInfoTypes.EA_ACTION_ANTIPROSELYTIZE] = function()
	for i = -1, HIGHEST_RELIGION_ID do
		if g_tablePointer[i] > 0 then
			--need percentage (round up or down???)
			local convertPercent = Floor(1 + 100 * g_tablePointer[i] / g_city:GetNumFollowers(i))
			g_city:ConvertPercentFollowers(RELIGION_ANRA, i, convertPercent)
		end
	end
	UpdateCivReligion(g_iOwner)
	return true
end

------------------------------------------------------------------------------------------------------------------------------
-- Pantheistic cult founding and spread
------------------------------------------------------------------------------------------------------------------------------
--Methods are identical for all cults except for the "Test cult-specific city req" section (and cult name and various texts)

--Model functions for Cult Rituals

local function ModelCultRitual_TestTarget()
	g_int1 = cultRitualReligions[g_eaActionID]

	--Can't do in foreign city unless we are founder
	if g_iOwner ~= g_iPlayer and (not gReligions[g_int1] or gReligions[g_int1].founder ~= g_iPlayer) then return false end

	--Test cult-specific city eligibility
	if not g_eaCity.eligibleCults[g_int1] then
		g_testTargetSwitch = 1
		return false
	end

	--Get conversion or found info
	if gReligions[g_int1] then		--already founded
		local totalConversions, bFlip, religionConversionTable = GetConversionOutcome(g_city, g_int1, g_mod)
		if totalConversions == 0 then
			g_testTargetSwitch = 2
			return false
		end
		g_tablePointer = religionConversionTable
		g_bool1 = bFlip
		g_value = totalConversions + (bFlip and 10 or 0) --for AI; passing conversion threshold worth 10 citizens 
		if gReligions[g_int1].founder ~= g_iPlayer then
			g_value = g_value / 10
		end
	else	--found
		if g_city:IsHolyCityAnyReligion() then
			g_testTargetSwitch = 3
			return false
		end
		g_value = 500
	end

	return true
end

local function ModelCultRitual_SetUI()
	if g_bNonTargetTestsPassed then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			if gReligions[g_int1] then		--already founded
				local atheistsConverted = g_tablePointer[-1]
				if atheistsConverted > 0 then
					MapModData.text = "Will convert " .. atheistsConverted .. " non-followers[NEWLINE]"
				else
					MapModData.text = ""
				end
				for i = 0, HIGHEST_RELIGION_ID do
					local numConverted = g_tablePointer[i]
					if numConverted > 0 then
						MapModData.text = MapModData.text .. "Will convert ".. numConverted .. " followers of ".. Locale.ConvertTextKey(GameInfo.Religions[i].Description) .. "[NEWLINE]"
					end
				end
				if g_bool1 then
					local cultStr = Locale.Lookup(GameInfo.Religions[g_int1].Description)
					MapModData.text = MapModData.text .. cultStr .. " will become the city's dominant religion"
				end
			else
				local cultStr = Locale.Lookup(GameInfo.Religions[g_int1].Description)
				MapModData.text = "Will found the " .. cultStr .. " in this city"
			end
		elseif not g_bIsCity then
			MapModData.text = "[COLOR_WARNING_TEXT]Cult founding/spreading rituals can be performed only in cities[ENDCOLOR]"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot convert any population here (perhaps you need a higher Devotion level)[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot perform cult founding/spreading rituals in a holy city[ENDCOLOR]"
		elseif g_testTargetSwitch == 1 then	--city not eligible for some reason
			local failReason = TestSetEligibleCityCults(g_city, g_eaCity, g_int1)
			MapModData.text = "[COLOR_WARNING_TEXT]" .. failReason .. "[ENDCOLOR]"	
		else
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot perform this ritual here[ENDCOLOR]"
		end
	end
end

local function ModelCultRitual_SetAIValues()
	local majorityReligionID = g_city:GetReligiousMajority()
	local iMajorityFounder
	if majorityReligionID ~= -1 and majorityReligionID ~= RELIGION_THE_WEAVE_OF_EA and majorityReligionID ~= g_int1 then
		iMajorityFounder = gReligions[majorityReligionID].founder
	end
	if iMajorityFounder == g_iPlayer then	--don't do it if city has majority cult for which we are founder
		gg_aiOptionValues.i = 0
	elseif g_iOwner == g_iPlayer then
		gg_aiOptionValues.i = g_value * 2	--double value for converting our own
	else
		gg_aiOptionValues.i = g_value
	end
end

--EA_ACTION_RITUAL_LEAVES
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_LEAVES] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_LEAVES] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_LEAVES] = ModelCultRitual_SetAIValues

--EA_ACTION_RITUAL_CLEANSING
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_CLEANSING] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_CLEANSING] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_CLEANSING] = ModelCultRitual_SetAIValues

--EA_ACTION_RITUAL_AEGIR
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_AEGIR] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_AEGIR] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_AEGIR] = ModelCultRitual_SetAIValues

--EA_ACTION_RITUAL_STONES
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_STONES] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_STONES] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_STONES] = ModelCultRitual_SetAIValues

--EA_ACTION_RITUAL_DESICCATION
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_DESICCATION] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_DESICCATION] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_DESICCATION] = ModelCultRitual_SetAIValues

--EA_ACTION_RITUAL_EQUUS
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_EQUUS] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_EQUUS] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_EQUUS] = ModelCultRitual_SetAIValues

--EA_ACTION_RITUAL_BAKKHEIA
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA] = ModelCultRitual_SetAIValues

------------------------------------------------------------------------------------------------------------------------------
-- Spells go in EaSpells.lua...
