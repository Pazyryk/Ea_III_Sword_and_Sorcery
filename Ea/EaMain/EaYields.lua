-- Yields
-- Author: Pazyryk
-- DateCreated: 6/28/2012 9:08:28 AM
--------------------------------------------------------------

print("Loading EaYields.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------

--constants

local EACIV_AB =								GameInfoTypes.EACIV_AB
local EACIV_MAMONAS =							GameInfoTypes.EACIV_MAMONAS
local EACIV_GOBANN =							GameInfoTypes.EACIV_GOBANN
local EACIV_VINCA =							GameInfoTypes.EACIV_VINCA

local ORDER_MAINTAIN =							OrderTypes.ORDER_MAINTAIN
local CITY_UPDATE_TYPE_PRODUCTION =				CityUpdateTypes.CITY_UPDATE_TYPE_PRODUCTION


local PROCESS_INDUSTRIAL_AGRICULTURE =			GameInfoTypes.PROCESS_INDUSTRIAL_AGRICULTURE
local PROCESS_AZZANDARAS_TRIBUTE =				GameInfoTypes.PROCESS_AZZANDARAS_TRIBUTE
local PROCESS_AHRIMANS_TRIBUTE =				GameInfoTypes.PROCESS_AHRIMANS_TRIBUTE
local PROCESS_THE_ARTS =						GameInfoTypes.PROCESS_THE_ARTS


local POLICY_INDUSTRIALIZATION =				GameInfoTypes.POLICY_INDUSTRIALIZATION
local POLICY_DOMINIONISM_FINISHER =				GameInfoTypes.POLICY_DOMINIONISM_FINISHER
local POLICY_SLAVE_CASTES =						GameInfoTypes.POLICY_SLAVE_CASTES
local POLICY_SLAVERY_FINISHER =					GameInfoTypes.POLICY_SLAVERY_FINISHER
local POLICY_COMMERCE_FINISHER =				GameInfoTypes.POLICY_COMMERCE_FINISHER
local POLICY_THE_ARTS =							GameInfoTypes.POLICY_THE_ARTS
local POLICY_TRADITION_FINISHER =				GameInfoTypes.POLICY_TRADITION_FINISHER
local POLICY_MERCENARIES =						GameInfoTypes.POLICY_MERCENARIES

local MINOR_TRAIT_MERCENARY =					GameInfoTypes.MINOR_TRAIT_MERCENARY
local RELIGION_AZZANDARAYASNA =					GameInfoTypes.RELIGION_AZZANDARAYASNA
local RELIGION_ANRA =							GameInfoTypes.RELIGION_ANRA
local RELIGION_CULT_OF_BAKKHEIA =				GameInfoTypes.RELIGION_CULT_OF_BAKKHEIA




local BUILDING_SMOKEHOUSE = 					GameInfoTypes.BUILDING_SMOKEHOUSE
local BUILDING_HUNTING_LODGE = 					GameInfoTypes.BUILDING_HUNTING_LODGE
local BUILDING_HARBOR = 						GameInfoTypes.BUILDING_HARBOR
local BUILDING_PORT = 							GameInfoTypes.BUILDING_PORT
local BUILDING_WHALERY = 						GameInfoTypes.BUILDING_WHALERY
local BUILDING_SLAVE_BREEDING_PEN =				GameInfoTypes.BUILDING_SLAVE_BREEDING_PEN
local BUILDING_NATIONAL_TREASURY =				GameInfoTypes.BUILDING_NATIONAL_TREASURY
local BUILDING_HANGING_GARDENS_MOD =			GameInfoTypes.BUILDING_HANGING_GARDENS_MOD

local BUILDING_PLUS_1_LOCAL_HAPPY =				GameInfoTypes.BUILDING_PLUS_1_LOCAL_HAPPY
local BUILDING_PLUS_1_UNHAPPINESS =				GameInfoTypes.BUILDING_PLUS_1_UNHAPPINESS

local BUILDING_PLUS_1_PERCENT_GLOBAL_CULTURE =	GameInfoTypes.BUILDING_PLUS_1_PERCENT_GLOBAL_CULTURE
local BUILDING_TRADE_PLUS_1_GOLD =				GameInfoTypes.BUILDING_TRADE_PLUS_1_GOLD
local BUILDING_PLUS_1_PERCENT_PRODUCTION =		GameInfoTypes.BUILDING_PLUS_1_PERCENT_PRODUCTION
local BUILDING_MINUS_1_PERCENT_PRODUCTION =		GameInfoTypes.BUILDING_MINUS_1_PERCENT_PRODUCTION
local BUILDING_PLUS_1_PERCENT_GOLD =			GameInfoTypes.BUILDING_PLUS_1_PERCENT_GOLD
local BUILDING_PLUS_1_PERCENT_SCIENCE =			GameInfoTypes.BUILDING_PLUS_1_PERCENT_SCIENCE
local BUILDING_PLUS_1_PERCENT_CULTURE =			GameInfoTypes.BUILDING_PLUS_1_PERCENT_CULTURE
local BUILDING_PLUS_1_FAITH =					GameInfoTypes.BUILDING_PLUS_1_FAITH
local BUILDING_REMOTE_RES_1_FOOD =				GameInfoTypes.BUILDING_REMOTE_RES_1_FOOD
local BUILDING_REMOTE_RES_1_PRODUCTION =		GameInfoTypes.BUILDING_REMOTE_RES_1_PRODUCTION
local BUILDING_REMOTE_RES_1_GOLD =				GameInfoTypes.BUILDING_REMOTE_RES_1_GOLD

local EA_WONDER_HANGING_GARDENS =				GameInfoTypes.EA_WONDER_HANGING_GARDENS
local EA_WONDER_MEGALOS_FAROS =					GameInfoTypes.EA_WONDER_MEGALOS_FAROS

--local BUILDING_PLUS_1_GLOBAL_XP =				GameInfoTypes.BUILDING_PLUS_1_GLOBAL_XP
local BUILDING_PLUS_1_LAND_XP =					GameInfoTypes.BUILDING_PLUS_1_LAND_XP
local BUILDING_PLUS_1_SEA_XP =					GameInfoTypes.BUILDING_PLUS_1_SEA_XP


local BUILDING_TRADE_HOUSE =					GameInfoTypes.BUILDING_TRADE_HOUSE
local BUILDING_MEGALOS_FAROS_MOD =				GameInfoTypes.BUILDING_MEGALOS_FAROS_MOD

local EA_ARTIFACT_TOME_OF_TOMES =				GameInfoTypes.EA_ARTIFACT_TOME_OF_TOMES

--local EAPERSON_PARTHOLON =						GameInfoTypes.EAPERSON_PARTHOLON
--local EAPERSON_FODLA =						GameInfoTypes.EAPERSON_FODLA

local IMPROVEMENT_CAMP =						GameInfoTypes.IMPROVEMENT_CAMP
local IMPROVEMENT_FISHING_BOATS =				GameInfoTypes.IMPROVEMENT_FISHING_BOATS
local IMPROVEMENT_WHALING_BOATS =				GameInfoTypes.IMPROVEMENT_WHALING_BOATS

local YIELD_FOOD =								GameInfoTypes.YIELD_FOOD
local YIELD_PRODUCTION = 						GameInfoTypes.YIELD_PRODUCTION
local YIELD_GOLD = 								GameInfoTypes.YIELD_GOLD
local YIELD_SCIENCE =							GameInfoTypes.YIELD_SCIENCE
local YIELD_CULTURE = 							GameInfoTypes.YIELD_CULTURE
local YIELD_FAITH = 							GameInfoTypes.YIELD_FAITH


local UNHAPPINESS_PER_OCCUPIED_POPULATION =		GameDefines.UNHAPPINESS_PER_OCCUPIED_POPULATION
local UNHAPPINESS_PER_CAPTURED_CITY =			GameDefines.UNHAPPINESS_PER_CAPTURED_CITY

--global tables
local MapModData =	MapModData
local playerType =	MapModData.playerType
local bFullCivAI =	MapModData.bFullCivAI
local realCivs =	MapModData.realCivs

--localized functions
local GetPlotByIndex = Map.GetPlotByIndex


--file control
local g_iActivePlayer = Game.GetActivePlayer()

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaYieldsInit(bNewGame)
	print("Running EaYieldsInit...")
	if not bNewGame then
		for iPlayer, eaPlayer in pairs(realCivs) do
			if playerType[iPlayer] == "FullCiv" then
				ResetYieldPolicies(iPlayer)
				UpdateGlobalYields(iPlayer)
			end
			UpdateCityYields(iPlayer)
		end
	end
end

--------------------------------------------------------------
-- Cached tables
--------------------------------------------------------------

local buildingOccupationMod = {}
for buildingInfo in GameInfo.Buildings() do
	if buildingInfo.EaOccupationUnhapReduction > 0 then
		buildingOccupationMod[buildingInfo.ID] = buildingInfo.EaOccupationUnhapReduction
	end
end

--global yield adjusts from hidden policies
local percentValues = {256,128,64,32,16,8,4,2,1}

local foodPlusPercentID = {
	GameInfoTypes.POLICY_FOOD_PLUS_PERCENT_0256,
	GameInfoTypes.POLICY_FOOD_PLUS_PERCENT_0128,
	GameInfoTypes.POLICY_FOOD_PLUS_PERCENT_0064,
	GameInfoTypes.POLICY_FOOD_PLUS_PERCENT_0032,
	GameInfoTypes.POLICY_FOOD_PLUS_PERCENT_0016,
	GameInfoTypes.POLICY_FOOD_PLUS_PERCENT_0008,
	GameInfoTypes.POLICY_FOOD_PLUS_PERCENT_0004,
	GameInfoTypes.POLICY_FOOD_PLUS_PERCENT_0002,
	GameInfoTypes.POLICY_FOOD_PLUS_PERCENT_0001	}
local foodMinusPercentID = {}
foodMinusPercentID[1] = GameInfoTypes.POLICY_FOOD_MINUS_PERCENT_0256
foodMinusPercentID[2] = GameInfoTypes.POLICY_FOOD_MINUS_PERCENT_0128
foodMinusPercentID[3] = GameInfoTypes.POLICY_FOOD_MINUS_PERCENT_0064
foodMinusPercentID[4] = GameInfoTypes.POLICY_FOOD_MINUS_PERCENT_0032
foodMinusPercentID[5] = GameInfoTypes.POLICY_FOOD_MINUS_PERCENT_0016
foodMinusPercentID[6] = GameInfoTypes.POLICY_FOOD_MINUS_PERCENT_0008
foodMinusPercentID[7] = GameInfoTypes.POLICY_FOOD_MINUS_PERCENT_0004
foodMinusPercentID[8] = GameInfoTypes.POLICY_FOOD_MINUS_PERCENT_0002
foodMinusPercentID[9] = GameInfoTypes.POLICY_FOOD_MINUS_PERCENT_0001

local productionPlusPercentID = {}
productionPlusPercentID[1] = GameInfoTypes.POLICY_PRODUCTION_PLUS_PERCENT_0256
productionPlusPercentID[2] = GameInfoTypes.POLICY_PRODUCTION_PLUS_PERCENT_0128
productionPlusPercentID[3] = GameInfoTypes.POLICY_PRODUCTION_PLUS_PERCENT_0064
productionPlusPercentID[4] = GameInfoTypes.POLICY_PRODUCTION_PLUS_PERCENT_0032
productionPlusPercentID[5] = GameInfoTypes.POLICY_PRODUCTION_PLUS_PERCENT_0016
productionPlusPercentID[6] = GameInfoTypes.POLICY_PRODUCTION_PLUS_PERCENT_0008
productionPlusPercentID[7] = GameInfoTypes.POLICY_PRODUCTION_PLUS_PERCENT_0004
productionPlusPercentID[8] = GameInfoTypes.POLICY_PRODUCTION_PLUS_PERCENT_0002
productionPlusPercentID[9] = GameInfoTypes.POLICY_PRODUCTION_PLUS_PERCENT_0001
local productionMinusPercentID = {}
productionMinusPercentID[1] = GameInfoTypes.POLICY_PRODUCTION_MINUS_PERCENT_0256
productionMinusPercentID[2] = GameInfoTypes.POLICY_PRODUCTION_MINUS_PERCENT_0128
productionMinusPercentID[3] = GameInfoTypes.POLICY_PRODUCTION_MINUS_PERCENT_0064
productionMinusPercentID[4] = GameInfoTypes.POLICY_PRODUCTION_MINUS_PERCENT_0032
productionMinusPercentID[5] = GameInfoTypes.POLICY_PRODUCTION_MINUS_PERCENT_0016
productionMinusPercentID[6] = GameInfoTypes.POLICY_PRODUCTION_MINUS_PERCENT_0008
productionMinusPercentID[7] = GameInfoTypes.POLICY_PRODUCTION_MINUS_PERCENT_0004
productionMinusPercentID[8] = GameInfoTypes.POLICY_PRODUCTION_MINUS_PERCENT_0002
productionMinusPercentID[9] = GameInfoTypes.POLICY_PRODUCTION_MINUS_PERCENT_0001

local goldPlusPercentID = {}
goldPlusPercentID[1] = GameInfoTypes.POLICY_GOLD_PLUS_PERCENT_0256
goldPlusPercentID[2] = GameInfoTypes.POLICY_GOLD_PLUS_PERCENT_0128
goldPlusPercentID[3] = GameInfoTypes.POLICY_GOLD_PLUS_PERCENT_0064
goldPlusPercentID[4] = GameInfoTypes.POLICY_GOLD_PLUS_PERCENT_0032
goldPlusPercentID[5] = GameInfoTypes.POLICY_GOLD_PLUS_PERCENT_0016
goldPlusPercentID[6] = GameInfoTypes.POLICY_GOLD_PLUS_PERCENT_0008
goldPlusPercentID[7] = GameInfoTypes.POLICY_GOLD_PLUS_PERCENT_0004
goldPlusPercentID[8] = GameInfoTypes.POLICY_GOLD_PLUS_PERCENT_0002
goldPlusPercentID[9] = GameInfoTypes.POLICY_GOLD_PLUS_PERCENT_0001
local goldMinusPercentID = {}
goldMinusPercentID[1] = GameInfoTypes.POLICY_GOLD_MINUS_PERCENT_0256
goldMinusPercentID[2] = GameInfoTypes.POLICY_GOLD_MINUS_PERCENT_0128
goldMinusPercentID[3] = GameInfoTypes.POLICY_GOLD_MINUS_PERCENT_0064
goldMinusPercentID[4] = GameInfoTypes.POLICY_GOLD_MINUS_PERCENT_0032
goldMinusPercentID[5] = GameInfoTypes.POLICY_GOLD_MINUS_PERCENT_0016
goldMinusPercentID[6] = GameInfoTypes.POLICY_GOLD_MINUS_PERCENT_0008
goldMinusPercentID[7] = GameInfoTypes.POLICY_GOLD_MINUS_PERCENT_0004
goldMinusPercentID[8] = GameInfoTypes.POLICY_GOLD_MINUS_PERCENT_0002
goldMinusPercentID[9] = GameInfoTypes.POLICY_GOLD_MINUS_PERCENT_0001

local sciencePlusPercentID = {}
sciencePlusPercentID[1] = GameInfoTypes.POLICY_SCIENCE_PLUS_PERCENT_0256
sciencePlusPercentID[2] = GameInfoTypes.POLICY_SCIENCE_PLUS_PERCENT_0128
sciencePlusPercentID[3] = GameInfoTypes.POLICY_SCIENCE_PLUS_PERCENT_0064
sciencePlusPercentID[4] = GameInfoTypes.POLICY_SCIENCE_PLUS_PERCENT_0032
sciencePlusPercentID[5] = GameInfoTypes.POLICY_SCIENCE_PLUS_PERCENT_0016
sciencePlusPercentID[6] = GameInfoTypes.POLICY_SCIENCE_PLUS_PERCENT_0008
sciencePlusPercentID[7] = GameInfoTypes.POLICY_SCIENCE_PLUS_PERCENT_0004
sciencePlusPercentID[8] = GameInfoTypes.POLICY_SCIENCE_PLUS_PERCENT_0002
sciencePlusPercentID[9] = GameInfoTypes.POLICY_SCIENCE_PLUS_PERCENT_0001
local scienceMinusPercentID = {}
scienceMinusPercentID[1] = GameInfoTypes.POLICY_SCIENCE_MINUS_PERCENT_0256
scienceMinusPercentID[2] = GameInfoTypes.POLICY_SCIENCE_MINUS_PERCENT_0128
scienceMinusPercentID[3] = GameInfoTypes.POLICY_SCIENCE_MINUS_PERCENT_0064
scienceMinusPercentID[4] = GameInfoTypes.POLICY_SCIENCE_MINUS_PERCENT_0032
scienceMinusPercentID[5] = GameInfoTypes.POLICY_SCIENCE_MINUS_PERCENT_0016
scienceMinusPercentID[6] = GameInfoTypes.POLICY_SCIENCE_MINUS_PERCENT_0008
scienceMinusPercentID[7] = GameInfoTypes.POLICY_SCIENCE_MINUS_PERCENT_0004
scienceMinusPercentID[8] = GameInfoTypes.POLICY_SCIENCE_MINUS_PERCENT_0002
scienceMinusPercentID[9] = GameInfoTypes.POLICY_SCIENCE_MINUS_PERCENT_0001

--don't need culture

local faithPlusPercentID = {}
faithPlusPercentID[1] = GameInfoTypes.POLICY_FAITH_PLUS_PERCENT_0256
faithPlusPercentID[2] = GameInfoTypes.POLICY_FAITH_PLUS_PERCENT_0128
faithPlusPercentID[3] = GameInfoTypes.POLICY_FAITH_PLUS_PERCENT_0064
faithPlusPercentID[4] = GameInfoTypes.POLICY_FAITH_PLUS_PERCENT_0032
faithPlusPercentID[5] = GameInfoTypes.POLICY_FAITH_PLUS_PERCENT_0016
faithPlusPercentID[6] = GameInfoTypes.POLICY_FAITH_PLUS_PERCENT_0008
faithPlusPercentID[7] = GameInfoTypes.POLICY_FAITH_PLUS_PERCENT_0004
faithPlusPercentID[8] = GameInfoTypes.POLICY_FAITH_PLUS_PERCENT_0002
faithPlusPercentID[9] = GameInfoTypes.POLICY_FAITH_PLUS_PERCENT_0001
local faithMinusPercentID = {}
faithMinusPercentID[1] = GameInfoTypes.POLICY_FAITH_MINUS_PERCENT_0256
faithMinusPercentID[2] = GameInfoTypes.POLICY_FAITH_MINUS_PERCENT_0128
faithMinusPercentID[3] = GameInfoTypes.POLICY_FAITH_MINUS_PERCENT_0064
faithMinusPercentID[4] = GameInfoTypes.POLICY_FAITH_MINUS_PERCENT_0032
faithMinusPercentID[5] = GameInfoTypes.POLICY_FAITH_MINUS_PERCENT_0016
faithMinusPercentID[6] = GameInfoTypes.POLICY_FAITH_MINUS_PERCENT_0008
faithMinusPercentID[7] = GameInfoTypes.POLICY_FAITH_MINUS_PERCENT_0004
faithMinusPercentID[8] = GameInfoTypes.POLICY_FAITH_MINUS_PERCENT_0002
faithMinusPercentID[9] = GameInfoTypes.POLICY_FAITH_MINUS_PERCENT_0001



--Tables below are dumped and reset on game load, so they are nil (treated as zero) before any changes.

local currentFoodPercentAdjByPlayer = {}
local currentProductionPercentAdjByPlayer = {}
local currentGoldPercentAdjByPlayer = {}
local currentSciencePercentAdjByPlayer = {}

local gg_playerValues = gg_playerValues



--Update functions called each turn and whenever something might have changed (so UI shows effect NOW). They can be called repeatedly without harm.

function UpdateGlobalYields(iPlayer, effectType, bPerTurnCall)	--City States only call effectType = "Gold"
	--function call can specify effectType or (if nil) all effectTypes are updated
	local Floor = math.floor
	print("UpdateGlobalYields", iPlayer, effectType)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local bFullCiv = playerType[iPlayer] == "FullCiv"
	local eaCivID = bFullCiv and eaPlayer.eaCivNameID or -1
	local bHuman = not bFullCivAI[iPlayer]

	if bHuman and bPerTurnCall then
		if gg_playerValues[iPlayer].goldDelayNotification then
			player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, "Great Person progress was delayed by gold shortfall!", -1, -1)
			gg_playerValues[iPlayer].goldDelayNotification = false
		end
		if gg_playerValues[iPlayer].productionDelayNotification then
			player:AddNotification(NotificationTypes.NOTIFICATION_GENERIC, "Great Person progress was delayed by production shortfall!", -1, -1)
			gg_playerValues[iPlayer].productionDelayNotification = false
		end
	end

	if effectType == nil or effectType == "Gold" then
		local mercenaryNet = 0
		local gpGoldBuildCost = 0
		for iOriginalOwner, myMercs in pairs(eaPlayer.mercenaries) do	--mercenaries we have hired
			for iMerc, gpt in pairs(myMercs) do
				local merc = player:GetUnitByID(iMerc)
				if merc then
					mercenaryNet = mercenaryNet - gpt
				else
					myMercs[iMerc] = nil		--clear out killed mercs
				end
			end
			if next(myMercs) == nil then
				eaPlayer.mercenaries[iOriginalOwner] = nil
			end
		end
		if bFullCiv then
			if player:HasPolicy(POLICY_MERCENARIES) then			--mercenaries we have hired out to other civs
				for iLoopPlayer, eaLoopPlayer in pairs(realCivs) do
					local myHiredMercs = eaLoopPlayer.mercenaries[iPlayer]
					if myHiredMercs then
						local loopPlayer = Players[iLoopPlayer]
						for iMerc, gpt in pairs(myHiredMercs) do
							local merc = loopPlayer:GetUnitByID(iMerc)
							if merc then
								mercenaryNet = mercenaryNet + gpt
							else							
								myHiredMercs[iMerc] = nil	--clear out killed mercs
							end
						end
						if next(myHiredMercs) == nil then
							eaLoopPlayer.mercenaries[iPlayer] = nil
						end
					end
				end
			end

			for iPerson, eaPerson in pairs(gPeople) do			--GP build costs
				if eaPerson.iPlayer == iPlayer then

					local eaActionID = eaPerson.eaActionID
					if eaActionID ~= -1 then
						local eaAction = GameInfo.EaActions[eaActionID]
						gpGoldBuildCost = gpGoldBuildCost + eaAction.GoldCostPerBuildTurn
					end
				end
			end
		elseif player:GetMinorCivTrait() == MINOR_TRAIT_MERCENARY then
			for iLoopPlayer, eaLoopPlayer in pairs(realCivs) do		--same loop as for full civ above
				local myHiredMercs = eaLoopPlayer.mercenaries[iPlayer]
				if myHiredMercs then
					local loopPlayer = Players[iLoopPlayer]
					for iMerc, gpt in pairs(myHiredMercs) do
						local merc = loopPlayer:GetUnitByID(iMerc)
						if merc then
							mercenaryNet = mercenaryNet + gpt
						else
							myHiredMercs[iMerc] = nil
						end
					end
					if next(myHiredMercs) == nil then
						eaLoopPlayer.mercenaries[iPlayer] = nil
					end
				end
			end
		end
		if bHuman then			--used to adjust top panel display only
			MapModData.gpGoldBuildCost = gpGoldBuildCost
			MapModData.mercenaryNet = mercenaryNet
		end
		if bPerTurnCall then	--do deduction from teasury and/or set shortfall
			player:ChangeGold(mercenaryNet)
			if bFullCiv then
				local gold = player:GetGold()
				if gpGoldBuildCost < gold then
					player:SetGold(gold - gpGoldBuildCost)
					eaPlayer.gpDelayChanceFromGoldShortfall = 0
				else
					player:SetGold(0)
					eaPlayer.gpDelayChanceFromGoldShortfall = Floor(1000 * (gpGoldBuildCost - gold) / gpGoldBuildCost + 0.5)	--chance in 1000 of no progress when DoEaAction rolls around
					print("Setting gpDelayChanceFromGoldShortfall (out of 1000)", eaPlayer.gpDelayChanceFromGoldShortfall)
				end
			end
		end
	end

	if effectType == nil or effectType == "FoodPercent" then
		--Hanging Gardens

		--TEST!
		local bHasHangingGardens = gWonders[EA_WONDER_HANGING_GARDENS] and Map.GetPlotByIndex(gWonders[EA_WONDER_HANGING_GARDENS].iPlot):GetOwner() == iPlayer
		local hangingGardensMod = bHasHangingGardens and gWonders[EA_WONDER_HANGING_GARDENS].mod or 0

		--[[
		for city in player:Cities() do
			hangingGardensMod = hangingGardensMod + city:GetNumBuilding(BUILDING_HANGING_GARDENS_MOD)
		end
		]]

		local foodPercent = Floor(hangingGardensMod + 0.5) 	--add everything and round to nearest 1%
		local lastFoodPercent = currentFoodPercentAdjByPlayer[iPlayer] or 0
		if foodPercent ~= lastFoodPercent then
			currentFoodPercentAdjByPlayer[iPlayer] = foodPercent
			if foodPercent >= 0 then
				for i = 1, 9 do
					local value = percentValues[i]
					if foodPercent >= value then
						player:SetHasPolicy(foodPlusPercentID[i], true)
						foodPercent = foodPercent - value
					else
						player:SetHasPolicy(foodPlusPercentID[i], false)
					end
					player:SetHasPolicy(foodMinusPercentID[i], false)
				end
			else
				for i = 1, 9 do
					local value = percentValues[i]
					if -foodPercent >= value then
						player:SetHasPolicy(foodMinusPercentID[i], true)
						foodPercent = foodPercent + value
					else
						player:SetHasPolicy(foodMinusPercentID[i], false)
					end
					player:SetHasPolicy(foodPlusPercentID[i], false)
				end
			end
		end
	end

	if effectType == nil or effectType == "CulturePercent" then
		local capital = player:GetCapitalCity()				-- NEED TO ACCOUNT FOR CHANGING CAPITAL !!!! (intercept? or cycle every city every turn)
		if capital then
			local leaderCulture = eaPlayer.leaderCulture or 0
			local culturePercent = Floor(leaderCulture + 0.5) 	--add everything and round to nearest 1%
			local prevCulturePercent = capital:GetNumBuilding(BUILDING_PLUS_1_PERCENT_GLOBAL_CULTURE)
			if culturePercent ~= prevCulturePercent then
				capital:SetNumRealBuilding(BUILDING_PLUS_1_PERCENT_GLOBAL_CULTURE, culturePercent)
			end
		end
	end
	
	if effectType == nil or effectType == "ProductionPercent" then
		local leaderProduction = eaPlayer.leaderProduction or 0
		local productionPercent = Floor(leaderProduction + 0.5) 	--add everything and round to nearest 1%
		local lastProductionPercent = currentProductionPercentAdjByPlayer[iPlayer] or 0
		if productionPercent ~= lastProductionPercent then
			currentProductionPercentAdjByPlayer[iPlayer] = productionPercent
			if productionPercent >= 0 then
				for i = 1, 9 do
					local value = percentValues[i]
					if productionPercent >= value then
						player:SetHasPolicy(productionPlusPercentID[i], true)
						productionPercent = productionPercent - value
					else
						player:SetHasPolicy(productionPlusPercentID[i], false)
					end
					player:SetHasPolicy(productionMinusPercentID[i], false)
				end
			else
				for i = 1, 9 do
					local value = percentValues[i]
					if -productionPercent >= value then
						player:SetHasPolicy(productionMinusPercentID[i], true)
						productionPercent = productionPercent + value
					else
						player:SetHasPolicy(productionMinusPercentID[i], false)
					end
					player:SetHasPolicy(productionPlusPercentID[i], false)
				end
			end
		end
	end

	if effectType == nil or effectType == "GoldPercent" then
		local leaderGold = eaPlayer.leaderGold or 0
		local goldPercent = Floor(leaderGold + 0.5) 	--add everything and round to nearest 1%
		local lastGoldPercent = currentGoldPercentAdjByPlayer[iPlayer] or 0
		if goldPercent ~= lastGoldPercent then
			currentGoldPercentAdjByPlayer[iPlayer] = goldPercent
			if goldPercent >= 0 then
				for i = 1, 9 do
					local value = percentValues[i]
					if goldPercent >= value then
						player:SetHasPolicy(goldPlusPercentID[i], true)
						goldPercent = goldPercent - value
					else
						player:SetHasPolicy(goldPlusPercentID[i], false)
					end
					player:SetHasPolicy(goldMinusPercentID[i], false)
				end
			else
				for i = 1, 9 do
					local value = percentValues[i]
					if -goldPercent >= value then
						player:SetHasPolicy(goldMinusPercentID[i], true)
						goldPercent = goldPercent + value
					else
						player:SetHasPolicy(goldMinusPercentID[i], false)
					end
					player:SetHasPolicy(goldPlusPercentID[i], false)
				end
			end
		end
	end

	if effectType == nil or effectType == "SciencePercent" then
		local leaderScience = eaPlayer.leaderScience or 0

		local sciencePercent = Floor(leaderScience + 0.5) 	--add everything and round to nearest 1%
		local lastSciencePercent = currentSciencePercentAdjByPlayer[iPlayer] or 0
		if sciencePercent ~= lastSciencePercent then
			currentSciencePercentAdjByPlayer[iPlayer] = sciencePercent
			if sciencePercent >= 0 then
				for i = 1, 9 do
					local value = percentValues[i]
					if sciencePercent >= value then
						player:SetHasPolicy(sciencePlusPercentID[i], true)
						sciencePercent = sciencePercent - value
					else
						player:SetHasPolicy(sciencePlusPercentID[i], false)
					end
					player:SetHasPolicy(scienceMinusPercentID[i], false)
				end
			else
				for i = 1, 9 do
					local value = percentValues[i]
					if -sciencePercent >= value then
						player:SetHasPolicy(scienceMinusPercentID[i], true)
						sciencePercent = sciencePercent + value
					else
						player:SetHasPolicy(scienceMinusPercentID[i], false)
					end
					player:SetHasPolicy(sciencePlusPercentID[i], false)
				end
			end
		end
	end

end
--LuaEvents.EaFunctionsUpdateGlobalEffects.Add(UpdateGlobalYields)	--call when tech tree or tech popup closed

--local function UpdateGlobalEffectsDirty()
--	Dprint("UpdateGlobalEffectsDirty")
--	if MapModData.bRequestPlayerScienceUpdate then
--		MapModData.bRequestPlayerScienceUpdate = false
--		UpdateGlobalYields(g_iActivePlayer, "SciencePercent", false)
--	end
--end
--Events.SerialEventGameDataDirty.Add(UpdateGlobalEffectsDirty)


function UpdateCityYields(iPlayer, iSpecificCity, effectType, bPerTurnCall)
	--function call can specify iSpecificCity or (if nil) all cities are updated
	--function call can specify effectType or (if nil) all effectTypes are updated
	print("UpdateCityYields", iPlayer, iSpecificCity, effectType, bPerTurnCall)
	local Floor = math.floor
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local bFullCiv = playerType[iPlayer] == "FullCiv"
	if not effectType and not bFullCiv then
		effectType = "CityStateUpdate"
	end
	local bPerTurnFullCivUpdate = bFullCiv and bPerTurnCall
	--local cityList
	--if iCity then
	--	cityList = {[iCity] = eaPlayer.eaCityIndexByiCity[iCity]}
	--else
	--	cityList = eaPlayer.eaCityIndexByiCity
	--end
	local numCities = player:GetNumCities()

	local bHasMegalosFaros = gWonders[EA_WONDER_MEGALOS_FAROS] and Map.GetPlotByIndex(gWonders[EA_WONDER_MEGALOS_FAROS].iPlot):GetOwner() == iPlayer
	local megalosFarosMod = bHasMegalosFaros and gWonders[EA_WONDER_MEGALOS_FAROS].mod or 0
	local nameTrait = bFullCiv and eaPlayer.eaCivNameID
	local capital = player:GetCapitalCity()

	--Finishers and other effects distribute yield to cities
	local foodDistribution = 0
	local productionDistribution = 0
	local scienceDistribution = 0
	local goldDistribution = 0
	local cultureDistribution = 0
	local faithDistribution = 0

	if bFullCiv then
		if player:HasPolicy(POLICY_INDUSTRIALIZATION) then
			local food = eaPlayer.foodDistributionCarryover or 0
			for city in player:Cities() do
				local orderType, orderID = city:GetOrderFromQueue(0)
				if orderType == ORDER_MAINTAIN and orderID == PROCESS_INDUSTRIAL_AGRICULTURE then	
					food = food + city:GetYieldRate(YIELD_PRODUCTION) / 4
				end
			end
			if player:HasPolicy(POLICY_DOMINIONISM_FINISHER) then
				food = food + player:GetTotalJONSCulturePerTurn() / 3
			end		
			foodDistribution = Floor(food / numCities)
			if bPerTurnCall then										--no change if this is just a UI update
				eaPlayer.foodDistributionCarryover = food % numCities
			end
		end

		if player:HasPolicy(POLICY_SLAVE_CASTES) then
			local unhappiness = -player:GetExcessHappiness()
			unhappiness = unhappiness < 0 and 0 or unhappiness
			local production = (eaPlayer.productionDistributionCarryover or 0) + unhappiness
			if player:HasPolicy(POLICY_SLAVERY_FINISHER) then
				production = production + Floor(player:GetTotalJONSCulturePerTurn() / 3)
			end
			productionDistribution = Floor(production / numCities)
			eaPlayer.productionDistributionCarryover = bPerTurnCall and production % numCities or eaPlayer.productionDistributionCarryover	--dump remainder into unhappiness account even if it is from culture
		end

		if player:HasPolicy(POLICY_TRADITION_FINISHER) then
			local science = (eaPlayer.scienceDistributionCarryover or 0) + Floor(player:GetTotalJONSCulturePerTurn() / 3)
			scienceDistribution = Floor(science / numCities)
			eaPlayer.scienceDistributionCarryover = bPerTurnCall and science % numCities or eaPlayer.scienceDistributionCarryover	--no change if this is just a UI update
		end
	
		if player:HasPolicy(POLICY_COMMERCE_FINISHER) then
			local gold = (eaPlayer.goldDistributionCarryover or 0) + Floor(player:GetTotalJONSCulturePerTurn() / 3)
			goldDistribution = Floor(gold / numCities)
			eaPlayer.goldDistributionCarryover = bPerTurnCall and gold % numCities or eaPlayer.goldDistributionCarryover	--no change if this is just a UI update
		end
	end

	local faithFromGPs, faithFromAzzTribute, faithFromToAhrimanTribute = 0, 0, 0	--for top panel update
	
	--for iCity, eaCityIndex in pairs(cityList) do
	for city in player:Cities() do
		local iCity = city:GetID()
		if not iSpecificCity or iSpecificCity == iCity then
		 	local plot = city:Plot()
			local iPlot = plot:GetPlotIndex()
			local eaCity = gCities[iPlot]
			local population = city:GetPopulation()
			local followerReligion = city:GetReligiousMajority()

			if effectType == nil or effectType == "CityStateUpdate" or effectType == "RemoteResources" then
				local remotePlots = eaCity.remotePlots
				local numCampRes, numFishingRes, numWhales = 0, 0, 0
				for i = 1, #remotePlots do
					local iRemotePlot = remotePlots[i]
					local remotePlot = GetPlotByIndex(iRemotePlot)
					local improvementID = remotePlot:GetImprovementType()
					if improvementID == IMPROVEMENT_CAMP then
						numCampRes = numCampRes + 1
					elseif improvementID == IMPROVEMENT_FISHING_BOATS then
						numFishingRes = numFishingRes + 1
					elseif improvementID == IMPROVEMENT_WHALING_BOATS then
						numWhales = numWhales + 1
					end
				end
				local food, production, gold = 0, 0, 0
				if 0 < city:GetNumRealBuilding(BUILDING_SMOKEHOUSE) then
					food = food + numCampRes
				end
				if 0 < city:GetNumRealBuilding(BUILDING_HUNTING_LODGE) then
					food = food + numCampRes
					gold = gold + numCampRes
				end
				if 0 < city:GetNumRealBuilding(BUILDING_HARBOR) then
					food = food + numFishingRes + numWhales
				end
				if 0 < city:GetNumRealBuilding(BUILDING_PORT) then
					food = food + numFishingRes + numWhales
					gold = gold + numFishingRes + numWhales
				end
				if 0 < city:GetNumRealBuilding(BUILDING_WHALERY) then
					food = food + numWhales
					production = production + numWhales		
				end
				city:SetNumRealBuilding(BUILDING_REMOTE_RES_1_FOOD, food)
				city:SetNumRealBuilding(BUILDING_REMOTE_RES_1_PRODUCTION, production)
				city:SetNumRealBuilding(BUILDING_REMOTE_RES_1_GOLD, gold)
			end

			if effectType == nil or effectType == "CityStateUpdate" or effectType == "Trade" then


			end

			--if effectType == nil or effectType == "FoodPercent" then
			--end

			if effectType == nil or effectType == "ProductionPercent" then
				local residentProduction = eaCity.residentProduction or 0
				local prevProductionPercent = city:GetNumBuilding(BUILDING_PLUS_1_PERCENT_PRODUCTION) - city:GetNumBuilding(BUILDING_MINUS_1_PERCENT_PRODUCTION)

				--do gp production costs (take up to 80%)
				local gpProductionBuildCost = 0
	
				for iPerson, eaPerson in pairs(gPeople) do
					if eaPerson.iPlayer == iPlayer and eaPerson.eaActionID ~= -1 and eaPerson.x == city:GetX() and eaPerson.y == city:GetY() then
						local eaAction = GameInfo.EaActions[eaPerson.eaActionID]
						gpProductionBuildCost = gpProductionBuildCost + eaAction.ProductionCostPerBuildTurn
					end
				end
				local gpTakePercentForBuild = 0
				if gpProductionBuildCost > 0 then
					local baseProduction = city:GetBaseYieldRate(YIELD_PRODUCTION)
					local maxBuildPercentTake = city:GetBaseYieldRateModifier(YIELD_PRODUCTION) - prevProductionPercent + residentProduction - 20
					local percentNeeded = 100 * gpProductionBuildCost / baseProduction
					if percentNeeded <= maxBuildPercentTake then
						gpTakePercentForBuild = percentNeeded
					else
						gpTakePercentForBuild = maxBuildPercentTake
						eaCity.gpDelayChanceFromProductionShortfall = Floor(1000 * (1 - gpTakePercentForBuild / percentNeeded) + 0.5)	--chance in 1000 of no progress when DoEaAction rolls around
					end
				end


				--Total
				local productionPercent = Floor(residentProduction - gpTakePercentForBuild + 0.5) 	--add everything and round to nearest 1%
				if productionPercent ~= prevProductionPercent then
					if productionPercent > 0 then
						city:SetNumRealBuilding(BUILDING_PLUS_1_PERCENT_PRODUCTION, productionPercent)
						city:SetNumRealBuilding(BUILDING_MINUS_1_PERCENT_PRODUCTION, 0)
					else
						city:SetNumRealBuilding(BUILDING_PLUS_1_PERCENT_PRODUCTION, 0)
						city:SetNumRealBuilding(BUILDING_MINUS_1_PERCENT_PRODUCTION, -productionPercent)
					end
				end
			end

			if effectType == nil or effectType == "LandXP" then
				local residentLandXP = eaCity.residentLandXP or 0
				local leaderLandXP = eaPlayer.leaderLandXP or 0

				local xp = Floor(residentLandXP + leaderLandXP + 0.5) 	--add everything and round to nearest 1%
				local prevXP = city:GetNumBuilding(BUILDING_PLUS_1_LAND_XP)
				if xp ~= prevXP then
					city:SetNumRealBuilding(BUILDING_PLUS_1_LAND_XP, xp)
				end
			end

			if effectType == nil or effectType == "SeaXP" then
				local residentSeaXP = eaCity.residentSeaXP or 0
				local leaderSeaXP = eaPlayer.leaderSeaXP or 0

				local xp = Floor(residentSeaXP + leaderSeaXP + 0.5) 	--add everything and round to nearest 1%
				local prevXP = city:GetNumBuilding(BUILDING_PLUS_1_SEA_XP)
				if xp ~= prevXP then
					city:SetNumRealBuilding(BUILDING_PLUS_1_SEA_XP, xp)
				end
			end

			if effectType == nil or effectType == "GoldPercent" then
				local residentGold = eaCity.residentGold or 0
				local goldPercent = Floor(residentGold + 0.5) 	--add everything and round to nearest 1%
				local prevGoldPercent = city:GetNumBuilding(BUILDING_PLUS_1_PERCENT_GOLD)
				if goldPercent ~= prevGoldPercent then
					city:SetNumRealBuilding(BUILDING_PLUS_1_PERCENT_GOLD, goldPercent)
				end
			end

			if effectType == nil or effectType == "SciencePercent" then
				local residentScience = eaCity.residentScience or 0
				local sciencePercent = Floor(residentScience + 0.5) 	--add everything and round to nearest 1%
				local prevSciencePercent = city:GetNumBuilding(BUILDING_PLUS_1_PERCENT_SCIENCE)
				if sciencePercent ~= prevSciencePercent then
					city:SetNumRealBuilding(BUILDING_PLUS_1_PERCENT_SCIENCE, sciencePercent)
				end
			end

			if effectType == nil or effectType == "CulturePercent" then
				local residentCulture = eaCity.residentCulture or 0
				local newCulturePercent = Floor(residentCulture + 0.5) 	--add everything and round to nearest 1%
				local prevCulturePercent = eaCity.culturePercentBoost
				if newCulturePercent ~= prevCulturePercent then
					city:ChangeCultureRateModifier(newCulturePercent - prevCulturePercent)
					eaCity.culturePercentBoost = newCulturePercent
				end
			end

			if effectType == nil or effectType == "FaithPercent" then		--can only apply straight yield; apply resident and leader effects here
				local residentFaith = eaCity.residentManaOrFavor or 0
				local faithPoints = Floor(residentFaith * city:GetFaithPerTurn() / 100 + 0.5)

				if city == capital then
					local leaderFaith = eaPlayer.leaderManaOrFavor or 0
					local playerFaithPoints = player:GetFaithPerTurnFromCities() + player:GetFaithPerTurnFromReligion()
					faithPoints = faithPoints + Floor(leaderFaith * playerFaithPoints / 100 + 0.5)
				end

				local prevFaith = city:GetNumBuilding(BUILDING_PLUS_1_FAITH)
				if faithPoints ~= prevFaith then
					city:SetNumRealBuilding(BUILDING_PLUS_1_FAITH, faithPoints)
				end
			end

			if effectType == nil or effectType == "Food" then
				local newFood = foodDistribution
				if city:GetNumRealBuilding(BUILDING_SLAVE_BREEDING_PEN) == 1 then		--offsets unhappiness penalty
					local foodLost = 0
					local playerHappiness = player:GetHappiness()
					if playerHappiness <= VERY_UNHAPPY_THRESHOLD then
						foodLost = city:FoodDifferenceTimes100() / (100 + VERY_UNHAPPY_GROWTH_PENALTY)
					elseif playerHappiness < 0 then
						foodLost = city:FoodDifferenceTimes100() / (100 + UNHAPPY_GROWTH_PENALTY)
					end
					newFood = newFood + Floor(foodLost / 2 + 0.5)
				end
				--local prevFood = eaCity.foodBoost
				local prevFood = city:GetBaseYieldRateFromMisc(YIELD_FOOD)
				if newFood ~= prevFood then
					city:ChangeBaseYieldRateFromMisc(YIELD_FOOD, newFood - prevFood)
					--eaCity.foodBoost = newFood
				end
			end

			if effectType == nil or effectType == "Production" then
				local newProduction = productionDistribution
				if eaCity.gpProduction then
					for iPerson, production in pairs(eaCity.gpProduction) do
						newProduction = newProduction + production
					end
				end
				--local prevProduction = eaCity.productionBoost
				local prevProduction = city:GetBaseYieldRateFromMisc(YIELD_PRODUCTION)
				if newProduction ~= prevProduction then
					city:ChangeBaseYieldRateFromMisc(YIELD_PRODUCTION, newProduction - prevProduction)
				end
				--eaCity.productionBoost = newProduction
			end

			if effectType == nil or effectType == "Science" then
				local newScience = scienceDistribution
				if eaCity.gpScience then
					for iPerson, science in pairs(eaCity.gpScience) do
						newScience = newScience + science
					end
				end
				--local prevScience = eaCity.scienceBoost
				local prevScience = city:GetBaseYieldRateFromMisc(YIELD_SCIENCE) - population
				if newScience ~= prevScience then
					city:ChangeBaseYieldRateFromMisc(YIELD_SCIENCE, newScience - prevScience)
				end
				--eaCity.scienceBoost = newScience
			end

			if effectType == nil or effectType == "Gold" then
				local newGold = goldDistribution
				if eaCity.gpGold then
					for iPerson, gold in pairs(eaCity.gpGold) do
						newGold = newGold + gold
					end
				end
				if 0 < city:GetNumRealBuilding(BUILDING_NATIONAL_TREASURY) then
					newGold = newGold + Floor(player:GetGold() * city:GetNumRealBuilding(BUILDING_NATIONAL_TREASURY) / 2000 + 0.5)
				end
				if nameTrait == EACIV_MAMONAS and city == capital then
					newGold = newGold + Floor(player:GetGold() * 0.005 + 0.5)
				end
				--local prevGold = eaCity.goldBoost
				local prevGold = city:GetBaseYieldRateFromMisc(YIELD_GOLD)
				if newGold ~= prevGold then
					city:ChangeBaseYieldRateFromMisc(YIELD_GOLD, newGold - prevGold)
				end
				--eaCity.goldBoost = newGold
			end

			if effectType == nil or effectType == "Culture" then
				local newCulture = cultureDistribution
				local orderType, orderID = city:GetOrderFromQueue(0)
				if orderType == ORDER_MAINTAIN and orderID == PROCESS_THE_ARTS then
					newCulture = newCulture + Floor(city:GetYieldRate(YIELD_PRODUCTION) / 4)
				end
				if eaCity.gpCulture then
					for iPerson, culture in pairs(eaCity.gpCulture) do
						newCulture = newCulture + culture
					end
				end
				--local prevCulture = (eaCity.cultureBoost or 0)		--TO DO: "or 0" here for v11 hotfix gamesave compatibility
				local prevCulture = city:GetBaseYieldRateFromMisc(YIELD_CULTURE)
				if newCulture ~= prevCulture then
					city:ChangeBaseYieldRateFromMisc(YIELD_CULTURE, newCulture - prevCulture)		--WARNGING: This does nothing except hold the value!
					city:ChangeJONSCulturePerTurnFromSpecialists(newCulture - prevCulture)	--no misc; UI sorts out specialist effect by diff with above
				end
				--eaCity.cultureBoost = newCulture
			end

			if effectType == nil or effectType == "Faith" then
				local newFaith = faithDistribution
				local orderType, orderID = city:GetOrderFromQueue(0)
				if orderType == ORDER_MAINTAIN then
					if orderID == PROCESS_AZZANDARAS_TRIBUTE then
						local tribute = Floor(city:GetYieldRate(YIELD_PRODUCTION) / 4)
						newFaith = newFaith + tribute
						faithFromAzzTribute = faithFromAzzTribute + tribute
					elseif orderID == PROCESS_AHRIMANS_TRIBUTE then	
						local manaBurn = Floor(city:GetYieldRate(YIELD_PRODUCTION) / 4)		--does not change faith because it is imediately consummed
						faithFromToAhrimanTribute = faithFromToAhrimanTribute + manaBurn
						if bPerTurnFullCivUpdate then
							gWorld.sumOfAllMana = gWorld.sumOfAllMana - manaBurn
							eaPlayer.manaConsumed = (eaPlayer.manaConsumed or 0) + manaBurn
						end
					end
				end
				if eaCity.gpFaith then
					for iPerson, faith in pairs(eaCity.gpFaith) do
						newFaith = newFaith + faith
						faithFromGPs = faithFromGPs + faith
					end
				end
				local prevFaith = city:GetBaseYieldRateFromMisc(YIELD_FAITH)
				if newFaith ~= prevFaith then
					city:ChangeBaseYieldRateFromMisc(YIELD_FAITH, newFaith - prevFaith)		--WARNGING: This does nothing except hold the value!
				end
				if bPerTurnFullCivUpdate and newFaith ~= 0 then
					player:ChangeFaith(newFaith)		--this is the actual yield addition
				end
			end

			if effectType == nil or effectType == "Happiness" then		--includes unhappiness
				local happiness = 0
				if eaCity.gpHappiness then
					for iPerson, add in pairs(eaCity.gpHappiness) do
						happiness = happiness + add
					end
				end

				--Occupied happiness
				if city:IsOccupied() and not city:IsNoOccupiedUnhappiness() then
					local occupationUnhappiness = city:GetPopulation() * UNHAPPINESS_PER_OCCUPIED_POPULATION + UNHAPPINESS_PER_CAPTURED_CITY

					local reduction = 0
					for buildingID, value in pairs(buildingOccupationMod) do
						if city:GetNumBuilding(buildingID) > 0 then
							reduction = reduction + value
						end
					end
					reduction = reduction < 100 and reduction or 100
					happiness = happiness + Floor(occupationUnhappiness * reduction / 100)
				end

				--Anra followers
				if gReligions[RELIGION_ANRA] and gReligions[RELIGION_ANRA].founder ~= iPlayer then
					local anraFollowers = city:GetNumFollowers(RELIGION_ANRA)
					happiness = happiness - (eaPlayer.religionID == RELIGION_AZZANDARAYASNA and anraFollowers or Floor(anraFollowers / 2))
				end

				if happiness < 0 then
					city:SetNumRealBuilding(BUILDING_PLUS_1_LOCAL_HAPPY, 0)
					city:SetNumRealBuilding(BUILDING_PLUS_1_UNHAPPINESS, -happiness)
				else
					city:SetNumRealBuilding(BUILDING_PLUS_1_LOCAL_HAPPY, happiness)
					city:SetNumRealBuilding(BUILDING_PLUS_1_UNHAPPINESS, 0)
				end
			end

		end

	end
	if iPlayer == g_iActivePlayer and not iCity then			--Top Panel info for active player; run only for all-city update (iCity = nil)
		MapModData.faithFromGPs = faithFromGPs
		MapModData.faithFromAzzTribute = faithFromAzzTribute
		MapModData.faithFromToAhrimanTribute = faithFromToAhrimanTribute
	end
end

--------------------------------------------------------------
-- Event functions
--------------------------------------------------------------
local prevProcessOrderType = {}	--index by iCity, use to know if changed
local prevProcessOrderID = {}
local function UpdateUIForProcessChange(iPlayer, iCity, updateTypeID)
	if iPlayer == g_iActivePlayer and updateTypeID == CITY_UPDATE_TYPE_PRODUCTION then	-- This provides immediate UI feedback when a city changes processes
		Dprint("UpdateUIForProcessChange ", iPlayer, iCity, updateTypeID)		
		--print("UpdateUIForProcessChange ", iPlayer, iCity, updateTypeID)
		local city = Players[iPlayer]:GetCityByID(iCity)
		if city then
			local orderType, orderID = city:GetOrderFromQueue(0)
			print(orderType, orderID)
			if orderType ~= prevProcessOrderType[iCity] or orderID ~= prevProcessOrderID[iCity] then	--changed
				--if (orderType == ORDER_MAINTAIN and orderID == PROCESS_INDUSTRIAL_AGRICULTURE) or (prevProcessOrderType[iCity] == ORDER_MAINTAIN and prevProcessOrderID[iCity] == PROCESS_INDUSTRIAL_AGRICULTURE) then
				--	UpdateCityYields(iPlayer, iCity, "Food")
				--end

				if orderType == ORDER_MAINTAIN then
					if orderID == PROCESS_INDUSTRIAL_AGRICULTURE then
						UpdateCityYields(iPlayer, iCity, "Food")
					elseif orderID == PROCESS_THE_ARTS then
						UpdateCityYields(iPlayer, iCity, "Culture")
					elseif orderID == PROCESS_AZZANDARAS_TRIBUTE or orderID == PROCESS_AHRIMANS_TRIBUTE then
						UpdateCityYields(iPlayer, iCity, "Faith")
					end

				end
				if prevProcessOrderType[iCity] == ORDER_MAINTAIN then
					if prevProcessOrderID[iCity] == PROCESS_INDUSTRIAL_AGRICULTURE then
						UpdateCityYields(iPlayer, iCity, "Food")
					elseif prevProcessOrderID[iCity] == PROCESS_THE_ARTS then
						UpdateCityYields(iPlayer, iCity, "Culture")
					elseif prevProcessOrderID[iCity] == PROCESS_AZZANDARAS_TRIBUTE or orderID == PROCESS_AHRIMANS_TRIBUTE then
						UpdateCityYields(iPlayer, iCity, "Faith")
					end
				end

				prevProcessOrderType[iCity] = orderType
				prevProcessOrderID[iCity] = orderID
			end
		end
	end
end
Events.SpecificCityInfoDirty.Add(UpdateUIForProcessChange)

function ResetYieldPolicies(iPlayer)
	local player = Players[iPlayer]
	for i = 1, #percentValues do
		player:SetHasPolicy(foodPlusPercentID[i], false)
		player:SetHasPolicy(foodMinusPercentID[i], false)
		player:SetHasPolicy(productionPlusPercentID[i], false)
		player:SetHasPolicy(productionMinusPercentID[i], false)
		player:SetHasPolicy(goldPlusPercentID[i], false)
		player:SetHasPolicy(goldMinusPercentID[i], false)
		player:SetHasPolicy(sciencePlusPercentID[i], false)
		player:SetHasPolicy(scienceMinusPercentID[i], false)
		player:SetHasPolicy(faithPlusPercentID[i], false)
		player:SetHasPolicy(faithMinusPercentID[i], false)
	end
end

----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)