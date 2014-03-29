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
local PLOT_OCEAN =							PlotTypes.PLOT_OCEAN
local PLOT_LAND =							PlotTypes.PLOT_LAND
local PLOT_MOUNTAIN =						PlotTypes.PLOT_MOUNTAIN
local TERRAIN_GRASS =						GameInfoTypes.TERRAIN_GRASS
local TERRAIN_PLAINS =						GameInfoTypes.TERRAIN_PLAINS
local TERRAIN_TUNDRA =						GameInfoTypes.TERRAIN_TUNDRA
local FEATURE_FOREST = 						GameInfoTypes.FEATURE_FOREST
local FEATURE_JUNGLE = 						GameInfoTypes.FEATURE_JUNGLE
local FEATURE_MARSH =	 					GameInfoTypes.FEATURE_MARSH
local FEATURE_BLIGHT =	 					GameInfoTypes.FEATURE_BLIGHT
local FEATURE_FALLOUT =	 					GameInfoTypes.FEATURE_FALLOUT
local IMPROVEMENT_BLIGHT =					GameInfoTypes.IMPROVEMENT_BLIGHT
local IMPROVEMENT_ARCANE_TOWER =			GameInfoTypes.IMPROVEMENT_ARCANE_TOWER
local INVISIBLE_SUBMARINE =					GameInfoTypes.INVISIBLE_SUBMARINE
local RESOURCE_BLIGHT =						GameInfoTypes.RESOURCE_BLIGHT

local LEADER_FAND =							GameInfoTypes.LEADER_FAND
local RESOURCE_HORSE =						GameInfoTypes.RESOURCE_HORSE
local RESOURCE_WINE =						GameInfoTypes.RESOURCE_WINE
local RELIGION_AZZANDARAYASNA =				GameInfoTypes.RELIGION_AZZANDARAYASNA
local RELIGION_ANRA =						GameInfoTypes.RELIGION_ANRA
local RELIGION_THE_WEAVE_OF_EA =			GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
local RELIGION_CULT_OF_LEAVES =				GameInfoTypes.RELIGION_CULT_OF_LEAVES
local RELIGION_CULT_OF_EPONA =				GameInfoTypes.RELIGION_CULT_OF_EPONA
local RELIGION_CULT_OF_PURE_WATERS =		GameInfoTypes.RELIGION_CULT_OF_PURE_WATERS
local RELIGION_CULT_OF_AEGIR =				GameInfoTypes.RELIGION_CULT_OF_AEGIR
local RELIGION_CULT_OF_BAKKHEIA =			GameInfoTypes.RELIGION_CULT_OF_BAKKHEIA
local POLICY_PANTHEISM =					GameInfoTypes.POLICY_PANTHEISM
local TECH_MALEFICIUM =						GameInfoTypes.TECH_MALEFICIUM
local BUILDING_LIBRARY =					GameInfoTypes.BUILDING_LIBRARY
local BUILDING_WINERY =						GameInfoTypes.BUILDING_WINERY
local BUILDING_BREWERY =					GameInfoTypes.BUILDING_BREWERY
local BUILDING_DISTILLERY =					GameInfoTypes.BUILDING_DISTILLERY
local BUILDING_TRADE_HOUSE =				GameInfoTypes.BUILDING_TRADE_HOUSE
local UNITCOMBAT_MOUNTED =					GameInfoTypes.UNITCOMBAT_MOUNTED
local PROMOTION_HEX =						GameInfoTypes.PROMOTION_HEX
local PROMOTION_BLESSED =					GameInfoTypes.PROMOTION_BLESSED
local PROMOTION_PROTECTION_FROM_EVIL =				GameInfoTypes.PROMOTION_PROTECTION_FROM_EVIL
local PROMOTION_CURSED =					GameInfoTypes.PROMOTION_CURSED
local PROMOTION_EVIL_EYE =					GameInfoTypes.PROMOTION_EVIL_EYE
local PROMOTION_RIDE_LIKE_THE_WINDS =		GameInfoTypes.PROMOTION_RIDE_LIKE_THE_WINDS
local PROMOTION_FAIR_WINDS =				GameInfoTypes.PROMOTION_FAIR_WINDS
local YIELD_PRODUCTION =					GameInfoTypes.YIELD_PRODUCTION
local YIELD_GOLD = 							GameInfoTypes.YIELD_GOLD
local YIELD_SCIENCE = 						GameInfoTypes.YIELD_SCIENCE
local YIELD_CULTURE = 						GameInfoTypes.YIELD_CULTURE
local YIELD_FAITH = 						GameInfoTypes.YIELD_FAITH
local DOMAIN_LAND =							DomainTypes.DOMAIN_LAND
local DOMAIN_SEA =							DomainTypes.DOMAIN_SEA
local EA_ACTION_GO_TO_PLOT =				GameInfoTypes.EA_ACTION_GO_TO_PLOT
local EA_WONDER_ARCANE_TOWER =				GameInfoTypes.EA_WONDER_ARCANE_TOWER

local MAX_MAJOR_CIVS =						GameDefines.MAX_MAJOR_CIVS
local UNHAPPINESS_PER_CITY =				GameDefines.UNHAPPINESS_PER_CITY
local ENEMY_HEAL_RATE =						GameDefines.ENEMY_HEAL_RATE
local NEUTRAL_HEAL_RATE =					GameDefines.NEUTRAL_HEAL_RATE
local FRIENDLY_HEAL_RATE =					GameDefines.FRIENDLY_HEAL_RATE

local UNIT_SUFFIXES =						UNIT_SUFFIXES
local NUM_UNIT_SUFFIXES =					#UNIT_SUFFIXES
local MOD_MEMORY_HALFLIFE =					MOD_MEMORY_HALFLIFE

local MAP_W, MAP_H =						Map.GetGridSize()
local MAX_RANGE =							Map.PlotDistance(0, 0, math.floor(MAP_W / 2 + 0.5), MAP_H - 1)	--other side of world (sort of)
local FIRST_SPELL_ID =						FIRST_SPELL_ID
local LAST_SPELL_ID =						LAST_SPELL_ID

--global tables
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


--localized functions
local FindOpenTradeRoute =					FindOpenTradeRoute		--in EaTrade
local IsLivingUnit =						IsLivingUnit
local Floor =								math.floor
local GetPlotByIndex =						Map.GetPlotByIndex
local GetPlotFromXY =						Map.GetPlot
local Distance =							Map.PlotDistance
local Rand =								Map.Rand
local HandleError =							HandleError
local HandleError21 =						HandleError21
local HandleError41 =						HandleError41


--local functions
local Test = {}
local TestTarget = {}
local SetUI = {}
local SetAIValues = {}
local Do = {}
local Interrupt = {}
local Finish = {}

--file control
--	All applicable are calculated in TestEaAction any time we are in this file. Never change anywhere else!
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

local g_bMapUnit		--if true then the following values are always calculated
local g_unit
local g_iUnit
local g_unitTypeID

local g_bGreatPerson	--if true then the following values are always calculated
local g_iPerson
local g_eaPerson
local g_mod
local g_subclass
local g_class1
local g_class2
local g_iUnitJoined
local g_joinedUnit

local g_unitX				--if g_bMapUnit then this is from g_unit; otherwise it is GP stat that may be from g_eaPerson.x, .y or from g_joinedUnit x,y
local g_unitY				--		(same as g_x, g_y below if no targetX,Y supplied in function call)

local g_bTarget			--true if targetX, targetY provided; otherwise, values are for g_unitX, g_unitY
local g_iPlot
local g_plot
local g_specialEffectsPlot			--same as g_plot unless changed in specific function
local g_iOwner
local g_x
local g_y

local g_bInTowerOrTemple	--these two are only set if g_eaAction.ApplyTowerTempleMod
local g_modSpell			--g_mod plus plot Tower/Temple mod

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

--local g_bAllowUnitCycle = true

--communicate from TestTarget to SetUI or SetAIValues when needed
local g_testTargetSwitch = 0

--use these values and table to pass among functions (e.g., from specific Test to specific Do function)
local g_count = 0
local g_value = 0
local g_int1, g_int2, g_int3, g_int4, g_int5 = 0, 0, 0, 0, 0
local g_bool1, g_bool2, g_bool3, g_bool4, g_bool5 = false, false, false, false, false
local g_text1, g_text2, g_text3, g_text4, g_text5 = "", "", "", "", ""
local g_obj1, g_obj2

local g_integers = {}
local g_integers2 = {}
local g_integersPos = 0
local g_table = {}	--anything else

local g_tradeAvailableTable = {}

---------------------------------------------------------------
-- Cached table values
---------------------------------------------------------------

local EaActionsInfo = {}			-- Contains the entire table for speed
for row in GameInfo.EaActions() do
	local id = row.ID
	EaActionsInfo[id] = row
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

function TimeDiscount(t, i, p, b)		--used in multiple trade route valuation; AI has same calculation with travel time in AddOption
	local numerator = b + discountRateTable[t - 1] * (i + p - discountRateTable[1] * (i + b))
	if numerator < 0 then return 0 end
	local denominator = 1 - discountRateTable[t]
	return numerator / denominator
end
local TimeDiscount = TimeDiscount

----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	print("EaAction.lua OnActivePlayerChanged ", iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)

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

	if g_eaAction.SpellClass then
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
	elseif g_eaAction.UnitUpgradeTypePrefix then
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
LuaEvents.EaActionsTestEaActionForHumanUI.Add(function(eaActionID, iPlayer, unit, iPerson, testX, testY) return HandleError(TestEaActionForHumanUI, eaActionID, iPlayer, unit, iPerson, testX, testY) end)

function TestEaAction(eaActionID, iPlayer, unit, iPerson, testX, testY, bAINonTargetTest)
	--This function sets all file locals related to iPlayer and iPerson 
	--iPerson must have value if this is a great person
	--unit must be non-nil EXCEPT if this is a GP not on map
	g_eaAction = EaActionsInfo[eaActionID]
	g_gameTurn = Game.GetGameTurn()

	--print("TestEaAction", g_eaAction.Type, iPlayer, unit, iPerson, testX, testY, bAINonTargetTest)

	g_bNonTargetTestsPassed = false
	g_testTargetSwitch = 0

	--do return false end	--PazDebug

	g_SpellClass = g_eaAction.SpellClass
	if g_SpellClass then
		--skip all world and civ-level reqs (for spells, these only apply to learning not casting) except for FixedFaith
		if not iPerson then return false end	--we'll handle non-GP spellcasting later
		g_eaPerson = gPeople[iPerson]
		if not g_eaPerson.spells or not g_eaPerson.spells[eaActionID] then return false end		--don't have spells or this spell (most common exclude)
		g_iPlayer = iPlayer
		g_eaPlayer = gPlayers[iPlayer]
		g_player = Players[iPlayer]
		
		g_iTeam = g_player:GetTeam()
		g_team = Teams[g_iTeam]	
	else
		if g_eaAction.ReligionNotFounded and gReligions[GameInfoTypes[g_eaAction.ReligionNotFounded] ] then return false end
		if g_eaAction.ReligionFounded and not gReligions[GameInfoTypes[g_eaAction.ReligionFounded] ] then return false end
		if g_eaAction.MaleficiumLearnedByAnyone and gWorld.maleficium ~= "Learned" then return false end

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
		g_iPlayer = iPlayer
	end

	if bAINonTargetTest then
		if g_eaPlayer.aiUniqueTargeted[eaActionID] and g_eaPlayer.aiUniqueTargeted[eaActionID] ~= iPerson then return false end	--ai specific exclude (someone on way to do this)
		g_bAIControl = true
	else
		g_bAIControl = bFullCivAI[iPlayer]
	end

	--for GP, unit can be gotten from iPerson or visa versa; for non-GP, unit must be supplied
	if unit then
		g_bMapUnit = true
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
	elseif iPerson then
		g_bGreatPerson = true
		g_iPerson = iPerson
		g_eaPerson = gPeople[g_iPerson]
		g_iUnit = g_eaPerson.iUnit
		if g_iUnit == -1 then
			g_iUnitJoined = g_eaPerson.iUnitJoined
			--[[
			if g_iUnitJoined ~= -1 then
				g_joinedUnit = g_player:GetUnitByID(g_iUnitJoined)
				if g_joinedUnit then
					g_unitX, g_unitY = g_joinedUnit:GetX(), g_joinedUnit:GetY()
				else
					UnJoinGP(g_iPlayer, g_eaPerson)
					g_unit = ReappearGP(g_iPlayer, g_iPerson)
					g_iUnit = g_eaPerson.iUnit
					g_iUnitJoined = -1
				end
			else
				
			end
			]]
			g_unitX, g_unitY = g_eaPerson.x, g_eaPerson.y
		end
		if g_iUnit == -1 then
			g_bMapUnit = false
			g_unit = nil
		else
			g_bMapUnit = true
			unit = g_player:GetUnitByID(g_iUnit)
			g_unit = unit
			g_unitX, g_unitY = unit:GetX(), unit:GetY()
			g_unitTypeID = unit:GetUnitType()
			g_iUnitJoined = g_eaPerson.iUnitJoined
			if g_iUnitJoined ~= -1 then
				g_joinedUnit = g_player:GetUnitByID(g_iUnitJoined)
			end
		end
	else
		print("!!!! ERROR: TestEaAction called with both unit and iPerson = nil")
	end
	--print("2")
	--unit characteristics (or stored unit info if GP not on map)

	if g_SpellClass then
		g_faith = g_player:GetFaith()
		if g_faith < 1 or (g_faith < g_eaAction.FixedFaith and g_eaPerson.tempFaith ~= g_eaAction.FixedFaith) then
			g_bSufficientFaith = false
		else
			g_bSufficientFaith = true
		end
	else
		if g_bMapUnit then
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
		
		elseif g_bGreatPerson then		--for GP not on map
			if g_eaAction.LevelReq and g_eaPerson.level < g_eaAction.LevelReq then return false end
			if g_eaAction.PromotionReq and not g_eaPerson.promotions[GameInfoTypes[g_eaAction.PromotionReq] ] then return false end
			--shouldn't use others for GP
		end

		--GP only
		if g_bGreatPerson then

			g_subclass = g_eaPerson.subclass
			if g_eaAction.GPSubclass and g_eaAction.GPSubclass ~= g_subclass and g_eaAction.OrGPSubclass ~= g_subclass then return false end
			if g_eaAction.ExcludeGPSubclass and g_eaAction.ExcludeGPSubclass == g_subclass then return false end
			g_class1 = g_eaPerson.class1
			g_class2 = g_eaPerson.class2	--nil unless dual-class GP
			if g_eaAction.GPClass and g_eaAction.GPClass ~= g_class1 and g_eaAction.GPClass ~= g_class2 then return false end
			if g_eaAction.NotGPClass and (g_eaAction.NotGPClass == g_class1 or g_eaAction.NotGPClass == g_class2) then return false end
			--if g_eaAction.PantheismCult and (g_eaPerson.cult and g_eaPerson.cult ~= GameInfoTypes[g_eaAction.PantheismCult]) then return false end

			--if g_eaAction.GPClass then
			--	if g_eaAction.OrGPClass then
			--		if g_eaAction.GPClass ~= g_class1 and g_eaAction.GPClass ~= g_class2 and g_eaAction.OrGPClass ~= g_class1 and g_eaAction.OrGPClass ~= g_class2 then return false end
			--	else
			--		if g_eaAction.GPClass ~= g_class1 and g_eaAction.GPClass ~= g_class2 then return false end
			--	end
			--end

		elseif g_eaAction.GPOnly then
			return false
		end
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
		--g_mod = modType and (g_eaPerson[modType] or 0) or 0

		g_mod = modType1 and GetGPMod(g_iPerson, modType1, g_eaAction.GPModType2) or 0
		--print(g_mod)
	end

	--Specific action test (runs if it exists)
	if Test[eaActionID] and not Test[eaActionID]() then return false end

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
	--g_eaAction = EaActionsInfo[eaActionID]		--needed here in case function called directly by AI
	--print("TestEaActionTarget",eaActionID, testX, testY, bAITargetTest)

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
				print("TestEaActionTarget returning false for AI becuase someone else has claimed this action at this plot")
				return false
			else
				g_bSomeoneElseDoingHere = true
				--will return false but delayed until below for human UI
			end
		end
	end

	g_plot = GetPlotFromXY(testX, testY)
	--print("g_plot from TestTarget ", g_plot)

	if g_eaAction.OwnCityRadius and not g_plot:IsPlayerCityRadius(g_iPlayer) then return false end
	if g_eaAction.BuildType and not g_plot:CanBuild(GameInfoTypes[g_eaAction.BuildType], g_iPlayer) then return false end

	g_iOwner = g_plot:GetOwner()
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

	g_specialEffectsPlot = g_plot	--can be changed in TestTarget

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

	--set g_modSpell for Tower or Temple
	if g_eaAction.ApplyTowerTempleMod or g_eaAction.TowerTempleOnly then
		if gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson] and gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson].iPlot == g_iPlot then
			g_modSpell = g_mod + gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson][GameInfoTypes[g_eaAction.GPModType1] ]		--Assume all spells have exactly one mod
			g_bInTowerOrTemple = true
		else
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

function DoEaActionFromOtherState(eaActionID, iPlayer, unit, iPerson, targetX, targetY)	--UnitPanel.lua or WorldView.lua
	print("DoEaActionFromOtherState ", eaActionID, iPlayer, unit, iPerson, targetX, targetY)
	local bSuccess =  DoEaAction(eaActionID, iPlayer, unit, iPerson, targetX, targetY)
	MapModData.bSuccess = bSuccess

end
LuaEvents.EaActionsDoEaActionFromOtherState.Add(function(eaActionID, iPlayer, unit, iPerson, targetX, targetY) return HandleError(DoEaActionFromOtherState, eaActionID, iPlayer, unit, iPerson, targetX, targetY) end)

function DoEaAction(eaActionID, iPlayer, unit, iPerson, targetX, targetY)
	print("DoEaAction before test ", eaActionID, iPlayer, unit, iPerson, targetX, targetY)

	if eaActionID == 0 then		--special go to plot function; just do or fail and skip the rest of this method
		unit:SetInvisibleType(INVISIBLE_SUBMARINE)
		return DoGotoPlot(iPlayer, unit, iPerson, targetX, targetY) 	--if targetX, Y == nil, then destination is from eaPerson.gotoPlotIndex
	end

	local bTest = TestEaAction(eaActionID, iPlayer, unit, iPerson, targetX, targetY, false)	--this will set all file variables we need
	print("DoEaAction after test ", g_eaAction.Type, iPlayer, unit, iPerson, targetX, targetY, bTest)

	g_eaPerson.gotoPlotIndex = -1	
	g_eaPerson.gotoEaActionID = -1

	if g_bGreatPerson then
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

	--Alt unit upgrades
	if g_eaAction.UnitUpgradeTypePrefix then
		local newUnit = g_player:InitUnit(g_int1, g_x, g_y)
		MapModData.bBypassOnCanSaveUnit = true
		newUnit:Convert(g_unit, true)
		g_unit = newUnit		--this will finish moves below; watch out because g_unitTypeID is no longer correct
		g_player:ChangeGold(-g_int2)
	end

	--effects on GP
	if g_eaAction.DoXP > 0 then
		g_unit:ChangeExperience(g_eaAction.DoXP)
	end
	if g_eaAction.DoGainPromotion then
		g_unit:SetHasPromotion(GameInfoTypes[g_eaAction.DoGainPromotion], true)
	end

	--Dissapear and/or finish moves
	if g_bGreatPerson then
		if g_bMapUnit then
			if g_eaAction.FinishMoves then
				g_unit:FinishMoves()
			end
			--if g_eaAction.Disappear then
			--	DisappearGP(g_iPlayer, g_iPerson, g_unit)
			--end
		else
			error("GP g_bMapUnit = false")	--Depreciated disappear kludge
			--if g_eaAction.FinishMoves then
			--	g_eaPerson.moves = 0
			--	g_eaPerson.disappearTurn = Game.GetGameTurn()
			--end
		end
	else
		if g_eaAction.FinishMoves and g_unit then
			g_unit:FinishMoves()
		end
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
	
	--Reserve this action at this plot (will cause TestEaActionTarget fail for other GPs)
	if 1 < turnsToComplete and not g_eaAction.NoGPNumLimit then
		g_eaPlayer.actionPlotTargeted[eaActionID] = g_eaPlayer.actionPlotTargeted[eaActionID] or {}
		g_eaPlayer.actionPlotTargeted[eaActionID][g_iPlot] = g_iPerson
	end

	if turnsToComplete == 1000 and g_bAIControl then turnsToComplete = 8 end	--AI will wake up and test other options
	if turnsToComplete == 1 then	--do it now!

		--Plot Float Up Text
		if not g_eaAction.NoFloatUpText or MapModData.bAutoplay then
			g_plot:AddFloatUpMessage(Locale.Lookup(g_eaAction.Description))
		end

		if 0 < g_eaAction.FixedFaith then
			UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_eaAction.FixedFaith)
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

		--Show under construction for city wonder // THIS DOESN'T WORK!!!
		if g_eaAction.BuildingUnderConstruction then
			g_city:SetBuildingProduction(GameInfoTypes[g_eaAction.BuildingUnderConstruction], 290)	--all have arbitrary build cost 300
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

			if progress == 0 then	--this is first turn of multiturn action
				if 0 < g_eaAction.FixedFaith then
					g_eaPerson.tempFaith = g_eaAction.FixedFaith
					g_player:ChangeFaith(-g_eaAction.FixedFaith)
				end
			end

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
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local eaPerson = gPeople[iPerson]
	local eaActionID = eaPerson.eaActionID

	eaPerson.gotoPlotIndex = -1
	eaPerson.gotoEaActionID = -1
	ClearActionPlotTargetedForPerson(eaPlayer, iPerson)
	if eaActionID == -1 then return end

	eaPerson.eaActionID = -1

	--return tempFaith
	if eaPerson.tempFaith ~= 0 then
		player:ChangeFaith(eaPerson.tempFaith)
		eaPerson.tempFaith = 0
	end

	local eaAction = EaActionsInfo[eaActionID]

	if eaAction.SpellClass and 0 < eaPerson.tempFaith then	--give back and remove progress
		player:ChangeFaith(eaPerson.tempFaith)
		eaPerson.tempFaith = 0
		eaPerson.progress[eaActionID] = nil
	end

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

function ClearActionPlotTargetedForPerson(eaPlayer, iPerson)
	print("Running ClearActionPlotTargetedForPerson")
	for eaActionID, actionTargets in pairs(eaPlayer.actionPlotTargeted) do
		for iPlot, iLoopPerson in pairs(actionTargets) do
			if iPerson == iLoopPerson then
				actionTargets[iPlot] = nil
			end
		end
	end
end

function FinishEaAction(eaActionID)		--only called from DoEaAction so file locals already set
	print("FinishEaAction", g_iPlayer, g_eaAction.Type)


	if g_eaAction.TurnsToComplete == 1000 and g_bAIControl then	--this is a sustained action interrupt (not really a "finish")
		InterruptEaAction(g_iPlayer, g_iPerson)		
		return true
	end

	--Plot Float Up Text
	if not g_eaAction.NoFloatUpText or MapModData.bAutoplay then
		g_plot:AddFloatUpMessage(Locale.Lookup(g_eaAction.Description))
	end

	ClearActionPlotTargetedForPerson(g_eaPlayer, g_iPerson)
	g_eaPerson.eaActionID = -1		--will bring back to map on next turn

	--g_unit:SetInvisibleType(INVISIBLE_SUBMARINE)

	--Temp faith system (faith was "moved" to caster; use it now)
	local faithUsed = g_eaPerson.tempFaith
	if 0 < faithUsed then
		g_eaPerson.tempFaith = 0 
		g_unit:ChangeExperience(faithUsed)
		if g_eaPlayer.bIsFallen then
			gWorld.sumOfAllMana = gWorld.sumOfAllMana - faithUsed
		end
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
				g_eaPerson.spells[GameInfoTypes[freeSpellType] ] = true
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

	end

	--Effects
	if g_eaAction.ClaimsPlot and g_iOwner ~= g_iPlayer then		--claim plot for nearest city; size breaks ties
		local biggestCity	
		for radius = 1, 10 do
			local biggestCitySize = 0
			for loopPlot in PlotRingIterator(g_plot, radius, 1, false) do
				local loopCity = g_plot:PlotCity()
				if loopCity and loopCity:GetOwner() == g_iPlayer then
					local pop = loopCity:GetPopulation()
					if biggestCitySize < pop then
						biggestCitySize = pop
						biggestCity = loopCity
					elseif biggestCitySize == pop and loopCity:IsCapital() then		--capital wins
						biggestCity = loopCity
					end
				end
			end
			if biggestCity then break end
		end
		if biggestCity then
			g_plot:SetOwner(g_iPlayer, biggestCity:GetID())
		else
			error("Could not find city for plot ownership")
		end
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

	if g_eaAction.EaWonder then
		local wonderID = GameInfoTypes[g_eaAction.EaWonder]
		gWonders[wonderID] = {mod = g_mod, iPlot = g_iPlot}
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
	--if g_bAIControl and g_eaPlayer.aiGPDoingOrOnWay[eaActionID] then
	--	g_eaPlayer.aiGPDoingOrOnWay[eaActionID][g_iPlot] = nil
	--end

	print("About to try action-specific Finish function, if any")
	if Finish[eaActionID] and not Finish[eaActionID]() then return false end	--this is the custom Finish call

	SpecialEffects()
	return true
end

function SpecialEffects()
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

function TestSpellLearnable(iPlayer, iPerson, spellID, spellClass)		--iPerson = nil to generate civ list; spellClass is optional restriction (used for separate UI panels)
	
	if not SetAIValues[spellID] then return false end	--Spell hasn't really been added yet, even if in table
	
	local spellInfo = EaActionsInfo[spellID]
	if spellClass and spellClass ~= spellInfo.SpellClass then return false end
	--order exclusions by most common first for speed
	if iPerson then
		local eaPerson = gPeople[iPerson]
		if spellInfo.SpellClass == "Arcane" then
			if eaPerson.class1 ~= "Thaumaturge" and eaPerson.class2 ~= "Thaumaturge" then return false end
		elseif spellInfo.SpellClass == "Divine" then
			if eaPerson.class1 ~= "Devout" and eaPerson.class2 ~= "Devout" then return false end
		else
			error("spellID was not Arcane or Divine ", spellID)
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
	if spellInfo.PantheismCult and not player:HasPolicy(POLICY_PANTHEISM) then return end		--show cult spell only if Pantheistic
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
	return true
end

MapModData.sharedIntegerList = MapModData.sharedIntegerList or {}
local sharedIntegerList = MapModData.sharedIntegerList

function GenerateLearnableSpellList(iPlayer, iPerson, spellClass)	--iPerson = nil if this is civ test only; spellClass = nil for both 
	print("GenerateLearnableSpellList ", iPlayer, iPerson, spellClass)
	local TestSpellLearnable = TestSpellLearnable
	--This is used for human UI (Spell Panel)

	local numSpells = 0
	for spellID = FIRST_SPELL_ID, LAST_SPELL_ID do
		if TestSpellLearnable(iPlayer, iPerson, spellID, spellClass) then
			numSpells = numSpells + 1
			sharedIntegerList[numSpells] = spellID
		end
	end

	--trim recycled table for UI
	for i = #sharedIntegerList, numSpells + 1, -1 do
		sharedIntegerList[i] = nil
	end
end
LuaEvents.EaActionsGenerateLearnableSpellList.Add(function(iPlayer, iPerson, spellClass) return HandleError41(GenerateLearnableSpellList, iPlayer, iPerson, spellClass) end)

function SetWEAHelp(eaActionID, mod)
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
--LuaEvents.EaActionsSetWEAHelp.Add(SetWEAHelp)
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
		if gotoEaAction then	--AI has decided it is worth moving to do some action
			if gotoEaAction.GPModType1 then
				local memValue = 2 ^ (g_gameTurn / MOD_MEMORY_HALFLIFE)
				local modID = GameInfoTypes[gotoEaAction.GPModType1]
				eaPerson.modMemory[modID] = (eaPerson.modMemory[modID] or 0) + memValue
				if gotoEaAction.GPModType2 then
					local modID = GameInfoTypes[gotoEaAction.GPModType2]
					eaPerson.modMemory[modID] = (eaPerson.modMemory[modID] or 0) + memValue
				end
			end
		end

		return true
	end

	--[[
	--if close and destination is forbidden, just teleport
	local distance = Map.PlotDistance(unitX, unitY, gotoX, gotoY)
	if distance < 3 then
		unit:ChangeMoves(-30 * distance)
		unit:SetXY(gotoX, gotoY)
		print("DoGotoPlot teleported GP to destination tile; distance was", distance)
		eaPerson.eaActionID = -1		--we are done
		return true		
	end

	--try to approach adjacent plot
	for x, y in PlotToRadiusIterator(gotoX, gotoY, 1) do
		unit:PopMission()
		unit:PushMission(MissionTypes.MISSION_MOVE_TO, x, y, 0, 0, 1, MissionTypes.MISSION_MOVE_TO, plot, unit)
		local movesAfter = unit:MovesLeft()
		if movesAfter < movesBefore then
			print("DoGotoPlot moved GP toward target ADJACENT plot")
			eaPerson.eaActionID = 0
			return true
		end
	end

	--try to approach 2-tile distance plot
	for x, y in PlotToRadiusIterator(gotoX, gotoY, 2) do
		unit:PopMission()
		unit:PushMission(MissionTypes.MISSION_MOVE_TO, x, y, 0, 0, 1, MissionTypes.MISSION_MOVE_TO, plot, unit)
		local movesAfter = unit:MovesLeft()
		if movesAfter < movesBefore then
			print("DoGotoPlot moved GP toward target 2-TILE DISTANCE plot")
			eaPerson.eaActionID = 0
			return true
		end
	end
	]]

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

------------------------------------------------------------------------------------------------------------------------------
-- Non-GP (SetAIValues doesn't work for these yet)
------------------------------------------------------------------------------------------------------------------------------
--EA_ACTION_SELL_SLAVES
Do[GameInfoTypes.EA_ACTION_SELL_SLAVES] = function()
	g_player:ChangeGold(30)
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
	if g_bool1 then
		g_city:ChangeUnitProduction(g_int1, 20)
	else
		g_city:ChangeBuildingProduction(g_int1, 20)
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

SetUI[GameInfoTypes.EA_ACTION_CHANNEL] = function()
	if g_bAllTestsPassed then
		local pts = Floor(g_mod / 2)
		local iCity = g_plot:GetCityPurchaseID()
		local city = g_player:GetCityByID(iCity)
		local cityName = city:GetName()
		MapModData.text = "Provide " .. pts .. " Mana per turn from " .. cityName
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


	eaCity.gpFaith = g_eaCity.gpFaith or {}
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
					value = value + GameInfo.Units[unitTypeID].Cost * unit:GetCurrHitPoints()
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
	gg_aiOptionValues.i = g_mod * g_value / 1000				
end

Do[GameInfoTypes.EA_ACTION_RALLY_TROOPS] = function()
	for i = 1, g_int1 do
		local unit = g_table[i]
		local floatUp = "+" .. g_mod .. " [ICON_HAPPINESS_1] Morale"
		unit:GetPlot():AddFloatUpMessage(floatUp)
		unit:ChangeMorale(g_mod)
	end
	local xp = Floor(g_mod * g_value / 1000)
	g_unit:ChangeExperience(xp)
	g_specialEffectsPlot = g_plot
	return true
end

--EA_ACTION_TRAIN_UNIT
TestTarget[GameInfoTypes.EA_ACTION_TRAIN_UNIT] = function()
	--print("TestTarget EA_ACTION_TRAIN_UNIT")
	--Must be combat unit at plot
	local unitCount = g_plot:GetNumUnits()
	for i = 0, unitCount - 1 do
		local unit = g_plot:GetUnit(i)
		if unit:GetOwner() == g_iPlayer and unit:GetDamage() == 0 then
			local unitTypeID = unit:GetUnitType()
			if gg_bNormalLivingCombatUnit[unitTypeID] then
				g_obj1 = unit
				g_obj2 = GameInfo.Units[unitTypeID]
				print("return true")
				return true
			end
		end
	end
	--print("return false")	
	return false
end

SetUI[GameInfoTypes.EA_ACTION_TRAIN_UNIT] = function()
	--print("SetUI EA_ACTION_TRAIN_UNIT")
	if g_bAllTestsPassed then
		local unitText = Locale.ConvertTextKey(g_obj2.Description)
		local xp = Floor(g_mod / 2)
		MapModData.text = "Provide " .. unitText .. " with " .. xp .. " experience per turn"
	end
	--print("done")
end

SetAIValues[GameInfoTypes.EA_ACTION_TRAIN_UNIT] = function()
	--print("SetAIValues EA_ACTION_TRAIN_UNIT")
	gg_aiOptionValues.i = g_mod * g_obj2.Cost / 8			
	--print("done")
end

Do[GameInfoTypes.EA_ACTION_TRAIN_UNIT] = function()
	print("Do EA_ACTION_TRAIN_UNIT")
	local xp = Floor(g_mod / 2)	--give to unit and GP
	g_obj1:ChangeExperience(xp)
	g_unit:ChangeExperience(xp)
	print("return true")
	return true
end

------------------------------------------------------------------------------------------------------------------------------
-- Misc Actions
------------------------------------------------------------------------------------------------------------------------------
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
			return true
		end
	end
	return false
end

SetUI[GameInfoTypes.EA_ACTION_OCCUPY_TOWER] = function()
	local improvementStr = g_plot:GetScriptData()
	MapModData.text = "Occupy " .. improvementStr .. " and make it your own"
end

Finish[GameInfoTypes.EA_ACTION_OCCUPY_TOWER] = function()
	local tower = gWonders[EA_WONDER_ARCANE_TOWER][g_int1]
	gWonders[EA_WONDER_ARCANE_TOWER][g_iPlayer] = tower
	g_eaPerson.bHasTower = true
	gWonders[EA_WONDER_ARCANE_TOWER][g_int1] = nil
	g_unit:ChangeExperience(20)
	g_specialEffectsPlot = g_plot
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
								local distance = Distance(azzCenterX, azzCenterY, city:GetX(), city:GetY())
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

--EA_ACTION_STANHENCG
SetAIValues[GameInfoTypes.EA_ACTION_STANHENCG] = function()
	gg_aiOptionValues.p = g_mod		--this will be mod mana
end

SetUI[GameInfoTypes.EA_ACTION_STANHENCG] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Generates "..g_mod.." mana per turn"
	end
end

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
	return g_city:IsCoastal()
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


--[[EA_ACTION_GREAT_LIBRARY
SetAIValues[GameInfoTypes.EA_ACTION_GREAT_LIBRARY] = function()
	local culture = (g_city:GetCultureRateModifier() + 100) / 25	--4c
	local science = g_mod * (100 + g_city:GetBaseYieldRateModifier(YIELD_SCIENCE))/100
	gg_aiOptionValues.p = culture + science
	gg_aiOptionValues.i = 1000		--proxy
end

SetUI[GameInfoTypes.EA_ACTION_GREAT_LIBRARY] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increases science in all cities by "..g_mod.."%"
	end
end
]]

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
	gWonders[EA_WONDER_ARCANE_TOWER][g_iPerson] = {iPlot = g_iPlot, iNamedFor = g_iPerson}
	SetTowerMods(g_iPerson)
	if g_iOwner ~= g_iPlayer then
		local city = GetNewOwnerCityForPlot(g_iPlayer, g_iPlot)
		g_plot:SetOwner(g_iPlayer, city:GetID())
	end
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

--EA_ACTION_EPIC_VAFTHRUTHNISMAL
SetUI[GameInfoTypes.EA_ACTION_EPIC_VAFTHRUTHNISMAL] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increases research by " .. g_mod
	end
end

--EA_ACTION_EPIC_GRIMNISMAL
SetUI[GameInfoTypes.EA_ACTION_EPIC_GRIMNISMAL] = function()
	if g_bAllTestsPassed then
		MapModData.text = "Increases leader effects by " .. g_mod .. "%"
	end
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

Finish[GameInfoTypes.EA_ACTION_EPIC_NATIONAL] = function()
	
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
	g_tradeAvailableTable = g_player:GetTradeRoutesAvailable()
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
		print(g_city, route.ToCity, route.Domain, route.TurnsLeft)
		print(g_city:GetID(), route.ToCity:GetID())
		print(g_city:GetName(), route.ToCity:GetName())
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

	local unit = g_player:InitUnit(GameInfoTypes.UNIT_CARAVAN, fromCity:GetX(), fromCity:GetY())
	unit:PushMission(MissionTypes.MISSION_ESTABLISH_TRADE_ROUTE, g_iPlot, 0, 0, 0, 1)

	--open route in eaCity object
	local fromCityPlotIndex = fromCity:Plot():GetPlotIndex()
	local fromEaCity = gCities[fromCityPlotIndex]		

	fromEaCity.openLandTradeRoutes[g_iPlot] = bestRoute.ToID		--open route associated with particular eaCity and iPlayer (still there if city conquered and recaptured)
	EaTradeDataDirty()
	return true
end


--EA_ACTION_SEA_TRADE_ROUTE
Test[GameInfoTypes.EA_ACTION_SEA_TRADE_ROUTE] = function()
	--There is no test here; but we need to set g_tradeAvailableTable and gg_tradeAvailableTable
	g_tradeAvailableTable = g_player:GetTradeRoutesAvailable()
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

	local unit = g_player:InitUnit(GameInfoTypes.UNIT_CARGO_SHIP, fromCity:GetX(), fromCity:GetY())
	unit:PushMission(MissionTypes.MISSION_ESTABLISH_TRADE_ROUTE, g_iPlot, 2, 0, 0, 1)				--2nd arg?

	--open route in eaCity object
	local fromCityPlotIndex = fromCity:Plot():GetPlotIndex()
	local fromEaCity = gCities[fromCityPlotIndex]		

	fromEaCity.openSeaTradeRoutes[g_iPlot] = bestRoute.ToID		--open route associated with particular eaCity and iPlayer (still there if city conquered and recaptured)
	EaTradeDataDirty()
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

--EA_ACTION_RITUAL_LEAVES
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_LEAVES] = function()

	--Can't do in foreign city unless we are founder
	if g_iOwner ~= g_iPlayer and (not gReligions[RELIGION_CULT_OF_LEAVES] or gReligions[RELIGION_CULT_OF_LEAVES].founder ~= g_iPlayer) then return false end

	--Test cult-specific city req
	local totalLand, totalUnimprovedForestJungle = 0, 0
	local totalPlots = g_city:GetNumCityPlots()
	for i = 0, totalPlots - 1 do
		local plot = g_city:GetCityIndexPlot(i)
		if plot and plot:GetPlotType() ~= PLOT_OCEAN then
			totalLand = totalLand + 1
			local featureID = plot:GetFeatureType()
			if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE then
				if plot:GetImprovementType() == -1 then
					totalUnimprovedForestJungle = totalUnimprovedForestJungle + 1
				end
			end
		end
	end
	if totalUnimprovedForestJungle / totalLand < 0.6 or totalLand / totalPlots < 0.5 then
		g_testTargetSwitch = 1
		g_int1 = totalUnimprovedForestJungle
		g_int2 = totalLand
		g_int3 = totalPlots
		return false
	end
	--End cult-specific part

	if gReligions[RELIGION_CULT_OF_LEAVES] then		--already founded
		local totalConversions, bFlip, religionConversionTable = GetConversionOutcome(g_city, RELIGION_CULT_OF_LEAVES, g_mod)
		if totalConversions == 0 then
			g_testTargetSwitch = 2
			return false
		end
		g_tablePointer = religionConversionTable
		g_bool1 = bFlip
		g_value = totalConversions + (bFlip and 10 or 0) --for AI; passing conversion threshold worth 10 citizens 
		if gReligions[RELIGION_CULT_OF_LEAVES].founder ~= g_iPlayer then
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

SetUI[GameInfoTypes.EA_ACTION_RITUAL_LEAVES] = function()
	if g_bNonTargetTestsPassed and g_bIsCity then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			if gReligions[RELIGION_CULT_OF_LEAVES] then
				local atheistsConverted = g_tablePointer[-1]
				if atheistsConverted > 0 then
					MapModData.text = "Will convert " .. atheistsConverted .. " non-followers[NEWLINE]"
				else
					MapModData.text = ""
				end
				for i = 0, HIGHEST_RELIGION_ID do
					local numConverted = g_tablePointer[i]
					if numConverted > 0 then
						MapModData.text = MapModData.text .. "Will convert ".. numConverted .. " followers of ".. Locale.ConvertTextKey(GameInfo.Religions[i].Type) .. "[NEWLINE]"
					end
				end
				if g_bool1 then
					MapModData.text = MapModData.text .. "Cult of Leaves will become the city's dominant religion"
				end
			else
				MapModData.text = "Will found the Cult of Leaves in this city"
			end
			--if not g_eaPerson.cult then
			--	MapModData.text = MapModData.text .. "[NEWLINE]" .. GetEaPersonFullTitle(g_eaPerson) .. " will join the Cult of Leaves"
			--end
		else
			if g_testTargetSwitch == 1 then
				local land = Floor(100 * g_int2 / g_int3)
				local forestJungle = Floor(100 * g_int1 / g_int2)
				MapModData.text = "[COLOR_WARNING_TEXT]City radius must be 50% land that is 60% unimproved forest or jungle (is "..land.."%, "..forestJungle.."%)[ENDCOLOR]"

			elseif g_testTargetSwitch == 2 then
				MapModData.text = "[COLOR_WARNING_TEXT]You cannot convert any population here (perhaps you need a higher Ritualism level)[ENDCOLOR]"
			elseif g_testTargetSwitch == 3 then
				MapModData.text = "[COLOR_WARNING_TEXT]You cannot perform the Ritual of Leaves in a holy city[ENDCOLOR]"
			end
		
		end
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_LEAVES] = function()
	print("SetAIValues for EA_ACTION_RITUAL_LEAVES")
	local majorityReligionID = g_city:GetReligiousMajority()
	local iMajorityFounder
	if majorityReligionID ~= -1 and majorityReligionID ~= RELIGION_THE_WEAVE_OF_EA and majorityReligionID ~= RELIGION_CULT_OF_LEAVES then
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

Finish[GameInfoTypes.EA_ACTION_RITUAL_LEAVES] = function()
	UpdateCivReligion(g_iOwner)
	MeetRandomPantheisticGod(g_iPlayer, "CultFounding", RELIGION_CULT_OF_LEAVES)
	return true
end

--EA_ACTION_RITUAL_EQUUS
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_EQUUS] = function()

	--Can't do in foreign city unless we are founder
	if g_iOwner ~= g_iPlayer and (not gReligions[RELIGION_CULT_OF_EPONA] or gReligions[RELIGION_CULT_OF_EPONA].founder ~= g_iPlayer) then return false end

	--Test cult-specific city req
	local totalLand, totalGoodFlatland, totalHorses = 0, 0, 0
	local totalPlots = g_city:GetNumCityPlots()
	for i = 0, totalPlots - 1 do
		local plot = g_city:GetCityIndexPlot(i)
		if plot then 
			local plotTypeID = plot:GetPlotType()
			if plotTypeID ~= PLOT_OCEAN then
				totalLand = totalLand + 1
				if plot:GetResourceType(-1) == RESOURCE_HORSE then
					totalHorses = totalHorses + 1
					if totalHorses > 2 then break end
				end
				if plotTypeID == PLOT_LAND and plot:GetFeatureType() == -1 then
					local terrainID = plot:GetTerrainType()
					if terrainID == TERRAIN_GRASS or  terrainID == TERRAIN_PLAINS then
						totalGoodFlatland = totalGoodFlatland + 1
					end
				end
			end
		end
	end
	if totalHorses < 2 then
		return false
	elseif totalHorses < 3 then
		if totalGoodFlatland / totalLand < 0.5 then return false end
	end
	--End cult-specific part

	if gReligions[RELIGION_CULT_OF_EPONA] then		--already founded
		local totalConversions, bFlip, religionConversionTable = GetConversionOutcome(g_city, RELIGION_CULT_OF_EPONA, g_mod)
		if totalConversions == 0 then return false end
		g_tablePointer = religionConversionTable
		g_bool1 = bFlip
		g_value = totalConversions + (bFlip and 10 or 0) --for AI; passing conversion threshold worth 10 citizens 
		if gReligions[RELIGION_CULT_OF_EPONA].founder ~= g_iPlayer then
			g_value = g_value / 10
		end
	else	--found
		if g_city:IsHolyCityAnyReligion() then return false end
		g_value = 500
	end

	return true
end

SetUI[GameInfoTypes.EA_ACTION_RITUAL_EQUUS] = function()
	if g_bNonTargetTestsPassed and g_bIsCity then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			if gReligions[RELIGION_CULT_OF_EPONA] then
				local atheistsConverted = g_tablePointer[-1]
				if atheistsConverted > 0 then
					MapModData.text = "Will convert " .. atheistsConverted .. " non-followers[NEWLINE]"
				else
					MapModData.text = ""
				end
				for i = 0, HIGHEST_RELIGION_ID do
					local numConverted = g_tablePointer[i]
					if numConverted > 0 then
						MapModData.text = MapModData.text .. "Will convert ".. numConverted .. " followers of ".. Locale.ConvertTextKey(GameInfo.Religions[i].Type) .. "[NEWLINE]"
					end
				end
				if g_bool1 then
					MapModData.text = MapModData.text .. "Cult of Epona will become the city's dominant religion"
				end
			else
				MapModData.text = "Will found the Cult of Epona in this city"
			end
			--if not g_eaPerson.cult then
			--	MapModData.text = MapModData.text .. "[NEWLINE]" .. GetEaPersonFullTitle(g_eaPerson) .. " will join the Cult of Epona"
			--end
		else
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot perform the Ritual of Equus in this city[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_EQUUS] = function()
	print("SetAIValues for EA_ACTION_RITUAL_EQUUS")
	local majorityReligionID = g_city:GetReligiousMajority()
	local iMajorityFounder
	if majorityReligionID ~= -1 and majorityReligionID ~= RELIGION_THE_WEAVE_OF_EA and majorityReligionID ~= RELIGION_CULT_OF_EPONA then
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

Finish[GameInfoTypes.EA_ACTION_RITUAL_EQUUS] = function()
	UpdateCivReligion(g_iOwner)
	MeetRandomPantheisticGod(g_iPlayer, "CultFounding", RELIGION_CULT_OF_EPONA)
	return true
end

--EA_ACTION_RITUAL_CLEANSING
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_CLEANSING] = function()

	--Can't do in foreign city unless we are founder
	if g_iOwner ~= g_iPlayer and (not gReligions[RELIGION_CULT_OF_PURE_WATERS] or gReligions[RELIGION_CULT_OF_PURE_WATERS].founder ~= g_iPlayer) then return false end

	--Test cult-specific city req
	local totalPureWater = 0
	local totalPlots = g_city:GetNumCityPlots()
	for i = 0, totalPlots - 1 do
		local plot = g_city:GetCityIndexPlot(i)
		if plot and (plot:IsRiver() or plot:IsLake() or plot:IsFreshWater() or plot:GetFeatureType() == FEATURE_MARSH) then
			totalPureWater = totalPureWater + 1
		end
	end
	if totalPureWater / totalPlots < 0.35 then return false end
	--End cult-specific part

	if gReligions[RELIGION_CULT_OF_PURE_WATERS] then		--already founded
		local totalConversions, bFlip, religionConversionTable = GetConversionOutcome(g_city, RELIGION_CULT_OF_PURE_WATERS, g_mod)
		if totalConversions == 0 then return false end
		g_tablePointer = religionConversionTable
		g_bool1 = bFlip
		g_value = totalConversions + (bFlip and 10 or 0) --for AI; passing conversion threshold worth 10 citizens
		if gReligions[RELIGION_CULT_OF_PURE_WATERS].founder ~= g_iPlayer then
			g_value = g_value / 10
		end 
	else	--found
		if g_city:IsHolyCityAnyReligion() then return false end
		g_value = 500
	end

	return true
end

SetUI[GameInfoTypes.EA_ACTION_RITUAL_CLEANSING] = function()
	if g_bNonTargetTestsPassed and g_bIsCity then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			if gReligions[RELIGION_CULT_OF_PURE_WATERS] then
				local atheistsConverted = g_tablePointer[-1]
				if atheistsConverted > 0 then
					MapModData.text = "Will convert " .. atheistsConverted .. " non-followers[NEWLINE]"
				else
					MapModData.text = ""
				end
				for i = 0, HIGHEST_RELIGION_ID do
					local numConverted = g_tablePointer[i]
					if numConverted > 0 then
						MapModData.text = MapModData.text .. "Will convert ".. numConverted .. " followers of ".. Locale.ConvertTextKey(GameInfo.Religions[i].Type) .. "[NEWLINE]"
					end
				end
				if g_bool1 then
					MapModData.text = MapModData.text .. "Cult of Pure Waters will become the city's dominant religion"
				end
			else
				MapModData.text = "Will found the Cult of Pure Waters in this city"
			end
			--if not g_eaPerson.cult then
			--	MapModData.text = MapModData.text .. "[NEWLINE]" .. GetEaPersonFullTitle(g_eaPerson) .. " will join the Cult of Pure Waters"
			--end
		else
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot perform the Ritual of Cleansing in this city[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_CLEANSING] = function()
	print("SetAIValues for EA_ACTION_RITUAL_CLEANSING")
	local majorityReligionID = g_city:GetReligiousMajority()
	local iMajorityFounder
	if majorityReligionID ~= -1 and majorityReligionID ~= RELIGION_THE_WEAVE_OF_EA and majorityReligionID ~= RELIGION_CULT_OF_PURE_WATERS then
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

Finish[GameInfoTypes.EA_ACTION_RITUAL_CLEANSING] = function()
	UpdateCivReligion(g_iOwner)
	MeetRandomPantheisticGod(g_iPlayer, "CultFounding", RELIGION_CULT_OF_PURE_WATERS)
	return true
end

--EA_ACTION_RITUAL_AEGIR
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_AEGIR] = function()

	--Can't do in foreign city unless we are founder
	if g_iOwner ~= g_iPlayer and (not gReligions[RELIGION_CULT_OF_AEGIR] or gReligions[RELIGION_CULT_OF_AEGIR].founder ~= g_iPlayer) then return false end

	--Test cult-specific city req
	local totalSea = 0
	local totalPlots = g_city:GetNumCityPlots()
	for i = 0, totalPlots - 1 do
		local plot = g_city:GetCityIndexPlot(i)
		if plot and plot:GetPlotType() == PLOT_OCEAN then
			totalSea = totalSea + 1
		end
	end
	if totalSea / totalPlots < 0.7 then return false end
	--End cult-specific part

	if gReligions[RELIGION_CULT_OF_AEGIR] then		--already founded
		local totalConversions, bFlip, religionConversionTable = GetConversionOutcome(g_city, RELIGION_CULT_OF_AEGIR, g_mod)
		if totalConversions == 0 then return false end
		g_tablePointer = religionConversionTable
		g_bool1 = bFlip
		g_value = totalConversions + (bFlip and 10 or 0) --for AI; passing conversion threshold worth 10 citizens 
		if gReligions[RELIGION_CULT_OF_AEGIR].founder ~= g_iPlayer then
			g_value = g_value / 10
		end
	else	--found
		if g_city:IsHolyCityAnyReligion() then return false end
		g_value = 500
	end

	return true
end

SetUI[GameInfoTypes.EA_ACTION_RITUAL_AEGIR] = function()
	if g_bNonTargetTestsPassed and g_bIsCity then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			if gReligions[RELIGION_CULT_OF_AEGIR] then
				local atheistsConverted = g_tablePointer[-1]
				if atheistsConverted > 0 then
					MapModData.text = "Will convert " .. atheistsConverted .. " non-followers[NEWLINE]"
				else
					MapModData.text = ""
				end
				for i = 0, HIGHEST_RELIGION_ID do
					local numConverted = g_tablePointer[i]
					if numConverted > 0 then
						MapModData.text = MapModData.text .. "Will convert ".. numConverted .. " followers of ".. Locale.ConvertTextKey(GameInfo.Religions[i].Type) .. "[NEWLINE]"
					end
				end
				if g_bool1 then
					MapModData.text = MapModData.text .. "Cult of Aegir will become the city's dominant religion"
				end
			else
				MapModData.text = "Will found the Cult of Aegir in this city"
			end
			--if not g_eaPerson.cult then
			--	MapModData.text = MapModData.text .. "[NEWLINE]" .. GetEaPersonFullTitle(g_eaPerson) .. " will join the Cult of Aegire"
			--end
		else
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot perform the Ritual of Aegir in this city[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_AEGIR] = function()
	print("SetAIValues for EA_ACTION_RITUAL_AEGIR")
	local majorityReligionID = g_city:GetReligiousMajority()
	local iMajorityFounder
	if majorityReligionID ~= -1 and majorityReligionID ~= RELIGION_THE_WEAVE_OF_EA and majorityReligionID ~= RELIGION_CULT_OF_AEGIR then
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

Finish[GameInfoTypes.EA_ACTION_RITUAL_AEGIR] = function()
	UpdateCivReligion(g_iOwner)
	MeetRandomPantheisticGod(g_iPlayer, "CultFounding", RELIGION_CULT_OF_AEGIR)
	return true
end

--EA_ACTION_RITUAL_BAKKHEIA
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA] = function()

	--Can't do in foreign city unless we are founder
	if g_iOwner ~= g_iPlayer and (not gReligions[RELIGION_CULT_OF_BAKKHEIA] or gReligions[RELIGION_CULT_OF_BAKKHEIA].founder ~= g_iPlayer) then return false end

	--Test cult-specific city req
	local boozeBuildings = g_city:GetNumBuilding(BUILDING_WINERY) + g_city:GetNumBuilding(BUILDING_BREWERY) + g_city:GetNumBuilding(BUILDING_DISTILLERY)
	if boozeBuildings < 2 then
		local totalWine = 0
		local totalPlots = g_city:GetNumCityPlots()
		for i = 0, totalPlots - 1 do
			local plot = g_city:GetCityIndexPlot(i)
			if plot and plot:GetResourceType(-1) == RESOURCE_WINE then
				totalWine = totalWine + 1
			end
		end
		if totalWine < 2 then return false end
	end
	--End cult-specific part

	if gReligions[RELIGION_CULT_OF_BAKKHEIA] then		--already founded
		local totalConversions, bFlip, religionConversionTable = GetConversionOutcome(g_city, RELIGION_CULT_OF_BAKKHEIA, g_mod)
		if totalConversions == 0 then return false end
		g_tablePointer = religionConversionTable
		g_bool1 = bFlip
		g_value = totalConversions + (bFlip and 10 or 0) --for AI; passing conversion threshold worth 10 citizens 
		if gReligions[RELIGION_CULT_OF_BAKKHEIA].founder ~= g_iPlayer then
			g_value = g_value / 10
		end
	else	--found
		if g_city:IsHolyCityAnyReligion() then return false end
		g_value = 500
	end

	return true
end

SetUI[GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA] = function()
	if g_bNonTargetTestsPassed and g_bIsCity then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			if gReligions[RELIGION_CULT_OF_BAKKHEIA] then
				local atheistsConverted = g_tablePointer[-1]
				if atheistsConverted > 0 then
					MapModData.text = "Will convert " .. atheistsConverted .. " non-followers[NEWLINE]"
				else
					MapModData.text = ""
				end
				for i = 0, HIGHEST_RELIGION_ID do
					local numConverted = g_tablePointer[i]
					if numConverted > 0 then
						MapModData.text = MapModData.text .. "Will convert ".. numConverted .. " followers of ".. Locale.ConvertTextKey(GameInfo.Religions[i].Type) .. "[NEWLINE]"
					end
				end
				if g_bool1 then
					MapModData.text = MapModData.text .. "Cult of Bakkheia will become the city's dominant religion"
				end
			else
				MapModData.text = "Will found the Cult of Bakkheia in this city"
			end
			--if not g_eaPerson.cult then
			--	MapModData.text = MapModData.text .. "[NEWLINE]" .. GetEaPersonFullTitle(g_eaPerson) .. " will join the Cult of Bakkheia"
			--end
		else
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot perform the Ritual of Bakkheia in this city[ENDCOLOR]"
		end
	end
end

SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA] = function()
	print("SetAIValues for EA_ACTION_RITUAL_BAKKHEIA")
	local majorityReligionID = g_city:GetReligiousMajority()
	local iMajorityFounder
	if majorityReligionID ~= -1 and majorityReligionID ~= RELIGION_THE_WEAVE_OF_EA and majorityReligionID ~= RELIGION_CULT_OF_BAKKHEIA then
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

Finish[GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA] = function()
	UpdateCivReligion(g_iOwner)
	MeetRandomPantheisticGod(g_iPlayer, "CultFounding", RELIGION_CULT_OF_BAKKHEIA)
	return true
end


------------------------------------------------------------------------------------------------------------------------------
-- Spells go here...!
------------------------------------------------------------------------------------------------------------------------------
--Note: spells skip over generic civ and caster prereqs: Test function won't be called
--Use TestTarget, SetUI, SetAIValues, Do (for 1 turn completion) and Finish (for >1 turn completion)


--EA_SPELL_SCRYING
--EA_SPELL_GLYPH_OF_SEEING
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
	--EaUnitCombat.lua detects attack and does xp, mana and unit reversion

	return true
end

--EA_SPELL_EXPLOSIVE_RUNES
TestTarget[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNES] = function()
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

SetUI[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNES] = function()
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

SetAIValues[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNES] = function()	--already restricted by AI heuristic; just value good defence plot
	gg_aiOptionValues.i = 10		--placeholder
end

Finish[GameInfoTypes.EA_SPELL_EXPLOSIVE_RUNES] = function()
	g_plot:SetPlotEffectData(GameInfoTypes.EA_PLOTEFFECT_EXPLOSIVE_RUNES, g_modSpell, g_iPlayer, g_iPerson)	--effectID, effectStength, iPlayer, iCaster
	UseManaOrDivineFavor(g_iPlayer, g_iPerson, g_modSpell)
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
						local unitTypeInfo = GameInfo.Units[unitTypeID]
						if value < unitTypeInfo.Cost * unit:GetCurrHitPoints() then
							g_obj1 = unit
							value = unitTypeInfo.Cost
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
	gg_aiOptionValues.i = g_value / 100
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

--EA_SPELL_SUMMON_MONSTER
--EA_SPELL_TELEPORT
--EA_SPELL_SUMMON_MINOR_DEMON
--EA_SPELL_PHASE_DOOR
--EA_SPELL_REANIMATE_DEAD
--EA_SPELL_RAISE_DEAD
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
	local unitCost = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			local unitTypeID = unit:GetUnitType()
			if gg_bNormalLivingCombatUnit[unitTypeID] then
				local damage = unit:GetDamage()
				if 0 < damage and Players[unit:GetOwner()]:GetTeam() == g_iTeam then
					local unitTypeInfo = GameInfo.Units[unitTypeID]
					if damage < pts then --partial use of heal potential
						if g_testTargetSwitch == 0 then
							g_obj1 = unit
							g_int1 = damage
							unitCost = unitTypeInfo.Cost
							g_testTargetSwitch = 1
						elseif g_testTargetSwitch == 1 and unitCost < unitTypeInfo.Cost then
							g_obj1 = unit
							g_int1 = damage
							unitCost = unitTypeInfo.Cost
						end
					else	--full use of heal potential
						if g_testTargetSwitch < 2 then
							g_obj1 = unit
							g_int1 = pts
							unitCost = unitTypeInfo.Cost
							g_testTargetSwitch = 2
						elseif unitCost < unitTypeInfo.Cost then
							g_obj1 = unit
							g_int1 = pts
							unitCost = unitTypeInfo.Cost
						end
					end
				end
			end
		end
	end
	if g_testTargetSwitch == 0 then return false end	--no valid target

	g_int2 = unitCost	--for AI

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
	--The AI value for a Heal spell is an instant payoff (i) = hp * unitCost / 100; use this as baseline for other spell values
	gg_aiOptionValues.i = g_int1 * g_int2 / 100
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
						local unitTypeInfo = GameInfo.Units[unitTypeID]
						if value < unitTypeInfo.Cost * unit:GetCurrHitPoints() then
							g_obj1 = unit
							value = unitTypeInfo.Cost
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
	gg_aiOptionValues.i = g_modSpell * g_value / 1000
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
						local unitTypeInfo = GameInfo.Units[unitTypeID]
						if value < unitTypeInfo.Cost * unit:GetCurrHitPoints() then
							g_obj1 = unit
							value = unitTypeInfo.Cost
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
	gg_aiOptionValues.i = g_modSpell * g_value / 1000
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
	local unitCost = 0
	for x, y in PlotToRadiusIterator(g_x, g_y, 1) do	--includes center
		local plot = GetPlotFromXY(x, y)
		local unitCount = plot:GetNumUnits()
		for i = 0, unitCount - 1 do
			local unit = plot:GetUnit(i)
			if g_team:IsAtWar(Players[unit:GetOwner()]:GetTeam()) then
				local unitTypeID = unit:GetUnitType()	
				if gg_bNormalLivingCombatUnit[unitTypeID] then
					local unitTypeInfo = GameInfo.Units[unitTypeID]
					local currentHP = unit:GetCurrHitPoints()
					if pts < currentHP then --won't kill
						if g_testTargetSwitch == 0 then
							g_obj1 = unit
							g_int1 = pts
							unitCost = unitTypeInfo.Cost
							g_testTargetSwitch = 1
						elseif g_testTargetSwitch == 1 and unitCost < unitTypeInfo.Cost then
							g_obj1 = unit
							g_int1 = pts
							unitCost = unitTypeInfo.Cost
						end
					else					--will kill
						if g_testTargetSwitch < 2 then
							g_obj1 = unit
							g_int1 = currentHP
							unitCost = unitTypeInfo.Cost
							g_testTargetSwitch = 2
						elseif unitCost < unitTypeInfo.Cost then
							g_obj1 = unit
							g_int1 = currentHP
							unitCost = unitTypeInfo.Cost
						end
					end
				end
			end
		end
	end
	if g_testTargetSwitch == 0 then return false end	--no valid target

	g_int2 = unitCost	--for AI

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
	--The AI value for a Heal spell is an instant payoff (i) = hp * unitCost / 100; use this as baseline for other spell values
	gg_aiOptionValues.i = g_int1 * g_int2 / 100
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
						local unitTypeInfo = GameInfo.Units[unitTypeID]
						if value < unitTypeInfo.Cost * unit:GetCurrHitPoints() then
							g_obj1 = unit
							value = unitTypeInfo.Cost
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
	gg_aiOptionValues.i = g_modSpell * g_value / 1000
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
						local unitTypeInfo = GameInfo.Units[unitTypeID]
						if value < unitTypeInfo.Cost * unit:GetCurrHitPoints() then
							g_obj1 = unit
							value = unitTypeInfo.Cost
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
	gg_aiOptionValues.i = g_modSpell * g_value / 1000
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
						value = value + GameInfo.Units[unitTypeID].Cost * unit:GetCurrHitPoints()
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
	gg_aiOptionValues.i = g_modSpell * g_value / 1000
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
			if unit:GetOwner() == g_iPlayer then		--change to allied
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
					local unitTypeInfo = GameInfo.Units[unitTypeID]
					local value = unitTypeInfo.Cost * (hpHealed + removeBonus)
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
	gg_aiOptionValues.i = g_modSpell * g_value / 1000
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
						local unitTypeInfo = GameInfo.Units[unitTypeID]
						if value < unitTypeInfo.Cost then
							g_obj1 = unit
							value = unitTypeInfo.Cost
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
	gg_aiOptionValues.i = g_value / 100
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

