-- Yields
-- Author: Pazyryk
-- DateCreated: 6/28/2012 9:08:28 AM
--------------------------------------------------------------

print("Loading EaYields.lua...")
local print = ENABLE_PRINT and print or function() end

--------------------------------------------------------------
-- Settings
--------------------------------------------------------------

local MAX_INTEREST_GPT =		EaSettings.MAX_INTEREST_GPT

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------

--constants

local EACIV_MAMONAS =							GameInfoTypes.EACIV_MAMONAS
local EACIV_MOR =								GameInfoTypes.EACIV_MOR

local ORDER_CONSTRUCT =							OrderTypes.ORDER_CONSTRUCT
local ORDER_MAINTAIN =							OrderTypes.ORDER_MAINTAIN
local ORDER_TRAIN =								OrderTypes.ORDER_TRAIN
local CITY_UPDATE_TYPE_PRODUCTION =				CityUpdateTypes.CITY_UPDATE_TYPE_PRODUCTION

local EA_ACTION_BUILD =							GameInfoTypes.EA_ACTION_BUILD
local EA_ACTION_RECRUIT =						GameInfoTypes.EA_ACTION_RECRUIT

local PROCESS_INDUSTRIAL_AGRICULTURE =			GameInfoTypes.PROCESS_INDUSTRIAL_AGRICULTURE
local PROCESS_AZZANDARAS_TRIBUTE =				GameInfoTypes.PROCESS_AZZANDARAS_TRIBUTE
local PROCESS_AHRIMANS_TRIBUTE =				GameInfoTypes.PROCESS_AHRIMANS_TRIBUTE
local PROCESS_THE_ARTS =						GameInfoTypes.PROCESS_THE_ARTS


local POLICY_INDUSTRIALIZATION =				GameInfoTypes.POLICY_INDUSTRIALIZATION
local POLICY_DOMINIONISM_FINISHER =				GameInfoTypes.POLICY_DOMINIONISM_FINISHER
local POLICY_SLAVE_CASTES =						GameInfoTypes.POLICY_SLAVE_CASTES
local POLICY_SLAVERY_FINISHER =					GameInfoTypes.POLICY_SLAVERY_FINISHER
local POLICY_COMMERCE_FINISHER =				GameInfoTypes.POLICY_COMMERCE_FINISHER
local POLICY_TRADITION_FINISHER =				GameInfoTypes.POLICY_TRADITION_FINISHER
local POLICY_MERCENARIES =						GameInfoTypes.POLICY_MERCENARIES

local MINOR_TRAIT_MERCENARY =					GameInfoTypes.MINOR_TRAIT_MERCENARY
local RELIGION_AZZANDARAYASNA =					GameInfoTypes.RELIGION_AZZANDARAYASNA
local RELIGION_ANRA =							GameInfoTypes.RELIGION_ANRA
local RELIGION_CULT_OF_BAKKHEIA =				GameInfoTypes.RELIGION_CULT_OF_BAKKHEIA

local BUILDING_SLAVE_BREEDING_PEN =				GameInfoTypes.BUILDING_SLAVE_BREEDING_PEN
local BUILDING_NATIONAL_TREASURY =				GameInfoTypes.BUILDING_NATIONAL_TREASURY
local BUILDING_HANGING_GARDENS_MOD =			GameInfoTypes.BUILDING_HANGING_GARDENS_MOD

local BUILDING_PLUS_1_LOCAL_HAPPY =				GameInfoTypes.BUILDING_PLUS_1_LOCAL_HAPPY
local BUILDING_PLUS_1_UNHAPPINESS =				GameInfoTypes.BUILDING_PLUS_1_UNHAPPINESS

local BUILDING_TRADE_PLUS_1_GOLD =				GameInfoTypes.BUILDING_TRADE_PLUS_1_GOLD

local BUILDING_REMOTE_RES_1_FOOD =				GameInfoTypes.BUILDING_REMOTE_RES_1_FOOD
local BUILDING_REMOTE_RES_1_PRODUCTION =		GameInfoTypes.BUILDING_REMOTE_RES_1_PRODUCTION
local BUILDING_REMOTE_RES_1_GOLD =				GameInfoTypes.BUILDING_REMOTE_RES_1_GOLD

local EA_WONDER_HANGING_GARDENS =				GameInfoTypes.EA_WONDER_HANGING_GARDENS
local EA_WONDER_MEGALOS_FAROS =					GameInfoTypes.EA_WONDER_MEGALOS_FAROS

local BUILDING_PLUS_1_LAND_XP =					GameInfoTypes.BUILDING_PLUS_1_LAND_XP
local BUILDING_PLUS_1_SEA_XP =					GameInfoTypes.BUILDING_PLUS_1_SEA_XP

local EA_ARTIFACT_TOME_OF_TOMES =				GameInfoTypes.EA_ARTIFACT_TOME_OF_TOMES

local IMPROVEMENT_CAMP =						GameInfoTypes.IMPROVEMENT_CAMP
local IMPROVEMENT_FISHING_BOATS =				GameInfoTypes.IMPROVEMENT_FISHING_BOATS
local IMPROVEMENT_WHALING_BOATS =				GameInfoTypes.IMPROVEMENT_WHALING_BOATS

local YIELD_FOOD =								GameInfoTypes.YIELD_FOOD
local YIELD_PRODUCTION = 						GameInfoTypes.YIELD_PRODUCTION
local YIELD_GOLD = 								GameInfoTypes.YIELD_GOLD
local YIELD_SCIENCE =							GameInfoTypes.YIELD_SCIENCE
local YIELD_CULTURE = 							GameInfoTypes.YIELD_CULTURE
local YIELD_FAITH = 							GameInfoTypes.YIELD_FAITH

local VERY_UNHAPPY_THRESHOLD =					GameDefines.VERY_UNHAPPY_THRESHOLD
local VERY_UNHAPPY_THRESHOLD =					GameDefines.VERY_UNHAPPY_GROWTH_PENALTY
local VERY_UNHAPPY_THRESHOLD =					GameDefines.UNHAPPY_GROWTH_PENALTY

local UNHAPPINESS_PER_OCCUPIED_POPULATION =		GameDefines.UNHAPPINESS_PER_OCCUPIED_POPULATION
local UNHAPPINESS_PER_CAPTURED_CITY =			GameDefines.UNHAPPINESS_PER_CAPTURED_CITY

--global tables
local MapModData =	MapModData
local playerType =	MapModData.playerType
local realCivs =	MapModData.realCivs

local gg_regularCombatType = gg_regularCombatType
local gg_eaTechClass = gg_eaTechClass

--localized functions
local GetPlotByIndex = Map.GetPlotByIndex
local floor = math.floor
local HandleError31 = HandleError31
local HandleError41 = HandleError41

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



--Tables below are dumped and reset on game load, so they are nil (treated as zero) before any changes.

local currentFoodPercentAdjByPlayer = {}
local currentProductionPercentAdjByPlayer = {}
local currentGoldPercentAdjByPlayer = {}
local currentSciencePercentAdjByPlayer = {}


--Update functions called each turn and whenever something might have changed (so UI shows effect NOW). They can be called repeatedly without harm.

function UpdateGlobalYields(iPlayer, effectType, bPerTurnCall)	--City States only call effectType = "Gold"
	--function call can specify effectType or (if nil) all effectTypes are updated
	print("UpdateGlobalYields", iPlayer, effectType)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local bFullCiv = playerType[iPlayer] == "FullCiv"
	local eaCivID = bFullCiv and eaPlayer.eaCivNameID or -1
	local bHuman = player:IsHuman()

	if effectType == nil or effectType == "Gold" then
		local mercenaryCost = 0
		for iOriginalOwner, myMercs in pairs(eaPlayer.mercenaries) do	--mercenaries we have hired
			for iMerc, gpt in pairs(myMercs) do
				local merc = player:GetUnitByID(iMerc)
				if merc then
					mercenaryCost = mercenaryCost + gpt
				else
					myMercs[iMerc] = nil		--clear out killed mercs
				end
			end
			if next(myMercs) == nil then
				eaPlayer.mercenaries[iOriginalOwner] = nil
			end
		end

		local mercenaryIncome = 0
		if bFullCiv then
			if player:HasPolicy(POLICY_MERCENARIES) then			--mercenaries we have hired out to other civs
				for iLoopPlayer, eaLoopPlayer in pairs(realCivs) do
					local myHiredMercs = eaLoopPlayer.mercenaries[iPlayer]
					if myHiredMercs then
						local loopPlayer = Players[iLoopPlayer]
						for iMerc, gpt in pairs(myHiredMercs) do
							local merc = loopPlayer:GetUnitByID(iMerc)
							if merc then
								mercenaryIncome = mercenaryIncome + gpt
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
			if eaCivID == EACIV_MOR then
				mercenaryCost = floor(0.67 * mercenaryCost + 0.5)
				mercenaryIncome = floor(1.33 * mercenaryIncome + 0.5)
			end

		elseif player:GetMinorCivTrait() == MINOR_TRAIT_MERCENARY then
			for iLoopPlayer, eaLoopPlayer in pairs(realCivs) do		--same loop as for full civ above
				local myHiredMercs = eaLoopPlayer.mercenaries[iPlayer]
				if myHiredMercs then
					local loopPlayer = Players[iLoopPlayer]
					for iMerc, gpt in pairs(myHiredMercs) do
						local merc = loopPlayer:GetUnitByID(iMerc)
						if merc then
							mercenaryIncome = mercenaryIncome + gpt
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
			MapModData.mercenaryNet = mercenaryIncome - mercenaryCost
		end
		if bPerTurnCall then	--do deduction from teasury and/or set shortfall
			player:ChangeGold(mercenaryIncome - mercenaryCost)
		end
	end

end


function UpdateCityYields(iPlayer, iSpecificCity, effectType, bPerTurnCall)
	--function call can specify iSpecificCity or (if nil) all cities are updated
	--function call can specify effectType or (if nil) all effectTypes are updated
	print("UpdateCityYields", iPlayer, iSpecificCity, effectType, bPerTurnCall)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local bFullCiv = playerType[iPlayer] == "FullCiv"
	if not effectType and not bFullCiv then
		effectType = "CityStateUpdate"
	end
	local bPerTurnFullCivUpdate = bFullCiv and bPerTurnCall
	local numCities = player:GetNumCities()
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
		if effectType == nil or effectType == "Food" then
			if player:HasPolicy(POLICY_INDUSTRIALIZATION) then
				local food = eaPlayer.foodDistributionCarryover
				for city in player:Cities() do
					local orderType, orderID = city:GetOrderFromQueue(0)
					if orderType == ORDER_MAINTAIN and orderID == PROCESS_INDUSTRIAL_AGRICULTURE then	
						food = food + city:GetYieldRate(YIELD_PRODUCTION) / 4
					end
				end
				if player:HasPolicy(POLICY_DOMINIONISM_FINISHER) then
					food = food + player:GetTotalJONSCulturePerTurn() / 3
				end		
				foodDistribution = floor(food / numCities)
				if bPerTurnCall then										--no change if this is just a UI update
					eaPlayer.foodDistributionCarryover = food % numCities
				end
			end
		end

		if effectType == nil or effectType == "Production" then
			if player:HasPolicy(POLICY_SLAVE_CASTES) then
				local unhappiness = -player:GetExcessHappiness()
				unhappiness = unhappiness < 0 and 0 or unhappiness
				local production = eaPlayer.productionDistributionCarryover + unhappiness
				if player:HasPolicy(POLICY_SLAVERY_FINISHER) then
					production = production + floor(player:GetTotalJONSCulturePerTurn() / 3)
				end
				productionDistribution = floor(production / numCities)
				eaPlayer.productionDistributionCarryover = bPerTurnCall and production % numCities or eaPlayer.productionDistributionCarryover	--dump remainder into unhappiness account even if it is from culture
			end
		end

		if effectType == nil or effectType == "Science" then
			local science = eaPlayer.scienceDistributionCarryover
			if player:HasPolicy(POLICY_TRADITION_FINISHER) then
				science = science + floor(player:GetTotalJONSCulturePerTurn() / 3)
			end
			if science ~= 0 then
				scienceDistribution = floor(science / numCities)
				eaPlayer.scienceDistributionCarryover = bPerTurnCall and science % numCities or eaPlayer.scienceDistributionCarryover	--no change if this is just a UI update
			end
		end
		--[[
		if effectType == nil or effectType == "Culture" then
			local culture = eaPlayer.cultureDistributionCarryover
			if player:HasPolicy(POLICY_TRADITION_FINISHER) then
				culture = culture + floor(player:GetTotalJONSCulturePerTurn() / 6)
			end
			if culture ~= 0 then
				cultureDistribution = floor(culture / numCities)
				eaPlayer.cultureDistributionCarryover = bPerTurnCall and culture % numCities or eaPlayer.cultureDistributionCarryover	--no change if this is just a UI update
			end
		end
		]]	
		if effectType == nil or effectType == "Gold" then
			if player:HasPolicy(POLICY_COMMERCE_FINISHER) then
				local gold = eaPlayer.goldDistributionCarryover + floor(player:GetTotalJONSCulturePerTurn() / 3)
				goldDistribution = floor(gold / numCities)
				eaPlayer.goldDistributionCarryover = bPerTurnCall and gold % numCities or eaPlayer.goldDistributionCarryover	--no change if this is just a UI update
			end
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

			if effectType == nil or effectType == "LandXP" or effectType == "Training" then
				local xp = eaPlayer.leaderLandXP
				if eaCity.gpTraining then
					for iPerson, trainingXP in pairs(eaCity.gpTraining) do
						xp = xp + trainingXP
					end
				end
				local xp = floor(xp + 0.5)				--round to nearest 1%
				city:SetNumRealBuilding(BUILDING_PLUS_1_LAND_XP, floor(xp + 0.5))
			end

			--[[
			if effectType == nil or effectType == "SeaXP" or effectType == "Training" then
				local xp = eaPlayer.leaderSeaXP
				if eaCity.gpTraining then
					for iPerson, trainingXP in pairs(eaCity.gpTraining) do
						xp = xp + trainingXP
					end
				end
				city:SetNumRealBuilding(BUILDING_PLUS_1_SEA_XP, floor(xp + 0.5))
			end
			]]

			if effectType == nil or effectType == "Food" then
				local newFood = foodDistribution
				if city:GetNumBuilding(BUILDING_SLAVE_BREEDING_PEN) == 1 then		--offsets unhappiness penalty
					local foodLost = 0
					local playerHappiness = player:GetHappiness()
					if playerHappiness <= VERY_UNHAPPY_THRESHOLD then
						foodLost = city:FoodDifferenceTimes100() / (100 + VERY_UNHAPPY_GROWTH_PENALTY)
					elseif playerHappiness < 0 then
						foodLost = city:FoodDifferenceTimes100() / (100 + UNHAPPY_GROWTH_PENALTY)
					end
					newFood = newFood + floor(foodLost / 2 + 0.5)
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
				if 0 < city:GetNumBuilding(BUILDING_NATIONAL_TREASURY) then
					local interestGold = floor(player:GetGold() * city:GetNumBuilding(BUILDING_NATIONAL_TREASURY) / 2000 + 0.5)
					interestGold = interestGold < MAX_INTEREST_GPT and interestGold or MAX_INTEREST_GPT
					newGold = newGold + interestGold
				end
				if nameTrait == EACIV_MAMONAS and city == capital then
					local interestGold = floor(player:GetGold() * 0.005 + 0.5)
					interestGold = interestGold < MAX_INTEREST_GPT and interestGold or MAX_INTEREST_GPT
					newGold = newGold + interestGold
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
					newCulture = newCulture + floor(city:GetYieldRate(YIELD_PRODUCTION) / 4)
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
						local tribute = floor(city:GetYieldRate(YIELD_PRODUCTION) / 4)
						newFaith = newFaith + tribute
						faithFromAzzTribute = faithFromAzzTribute + tribute
					elseif orderID == PROCESS_AHRIMANS_TRIBUTE then	
						local manaBurn = floor(city:GetYieldRate(YIELD_PRODUCTION) / 4)		--does not change faith because it is imediately consummed
						faithFromToAhrimanTribute = faithFromToAhrimanTribute + manaBurn
						if bPerTurnFullCivUpdate then
							gWorld.sumOfAllMana = gWorld.sumOfAllMana - manaBurn
							eaPlayer.manaConsumed = eaPlayer.manaConsumed + manaBurn
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
					happiness = happiness + floor(occupationUnhappiness * reduction / 100)
				end

				--Anra followers
				if gReligions[RELIGION_ANRA] and gReligions[RELIGION_ANRA].founder ~= iPlayer then
					local anraFollowers = city:GetNumFollowers(RELIGION_ANRA)
					happiness = happiness - (eaPlayer.religionID == RELIGION_AZZANDARAYASNA and anraFollowers or floor(anraFollowers / 2))
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
	if iPlayer == g_iActivePlayer then
		if not bPerTurnCall then
			Events.SerialEventCityInfoDirty()	--update city banner if production changed
		end
		if not iSpecificCity then			--Top Panel info for active player; run only for all-city update (iCity = nil)
			MapModData.faithFromGPs = faithFromGPs
			MapModData.faithFromAzzTribute = faithFromAzzTribute
			MapModData.faithFromToAhrimanTribute = faithFromToAhrimanTribute
		end
	end
end
local function X_UpdateCityYields(iPlayer, iSpecificCity, effectType, bPerTurnCall) return HandleError41(UpdateCityYields, iPlayer, iSpecificCity, effectType, bPerTurnCall) end
LuaEvents.EaYieldsUpdateCityYields.Add(X_UpdateCityYields)

--------------------------------------------------------------
-- Event functions
--------------------------------------------------------------


local prevOrderType = {}	--index by iCity, use to know if changed
local prevOrderID = {}
local function ActivePlayerCityBuildQueueChange(iPlayer, iCity, updateTypeID)
	if iPlayer == g_iActivePlayer and updateTypeID == CITY_UPDATE_TYPE_PRODUCTION then	-- This provides immediate UI feedback when a city changes processes		
		local player = Players[iPlayer]
		local city = player:GetCityByID(iCity)
		if city then
			local orderType, orderID = city:GetOrderFromQueue(0)
			print("CityBuildQueueChange ", orderType, orderID)

			if orderType ~= prevOrderType[iCity] or orderID ~= prevOrderID[iCity] then	--changed

				--process changes
				if orderType == ORDER_MAINTAIN then
					if orderID == PROCESS_INDUSTRIAL_AGRICULTURE then
						UpdateCityYields(iPlayer, iCity, "Food")
					elseif orderID == PROCESS_THE_ARTS then
						UpdateCityYields(iPlayer, iCity, "Culture")
					elseif orderID == PROCESS_AZZANDARAS_TRIBUTE or orderID == PROCESS_AHRIMANS_TRIBUTE then
						UpdateCityYields(iPlayer, iCity, "Faith")
					end

				end
				if prevOrderType[iCity] == ORDER_MAINTAIN then
					if prevOrderID[iCity] == PROCESS_INDUSTRIAL_AGRICULTURE then
						UpdateCityYields(iPlayer, iCity, "Food")
					elseif prevOrderID[iCity] == PROCESS_THE_ARTS then
						UpdateCityYields(iPlayer, iCity, "Culture")
					elseif prevOrderID[iCity] == PROCESS_AZZANDARAS_TRIBUTE or orderID == PROCESS_AHRIMANS_TRIBUTE then
						UpdateCityYields(iPlayer, iCity, "Faith")
					end
				end

				--change that invalidates Engineer Build or Warrior Train action (wake GP for new orders)
				local iPlot = city:Plot():GetPlotIndex()
				for iPerson, eaPerson in pairs(gPeople) do
					if eaPerson.eaActionData == iPlot then
						local bInterrupt = false
						if eaPerson.eaActionID == EA_ACTION_BUILD then
							if orderType ~= ORDER_CONSTRUCT and (orderType ~= ORDER_TRAIN or gg_regularCombatType[orderID] ~= "construct") then
								bInterrupt = true
							end
						elseif eaPerson.eaActionID == EA_ACTION_RECRUIT then
							if orderType ~= ORDER_TRAIN or gg_regularCombatType[orderID] ~= "troops" then
								bInterrupt = true
							end
						end
						if bInterrupt then
							InterruptEaAction(eaPerson.iPlayer, iPerson)	--this will call UpdateCityYields
							local unit = player:GetUnitByID(eaPerson.iUnit)
							if unit then
								UI.SelectUnit(unit)
							end
						end
					end
				end

				prevOrderType[iCity] = orderType
				prevOrderID[iCity] = orderID
			end
		end
	end
end
local function X_ActivePlayerCityBuildQueueChange(iPlayer, iCity, updateTypeID) return HandleError31(ActivePlayerCityBuildQueueChange, iPlayer, iCity, updateTypeID) end
Events.SpecificCityInfoDirty.Add(X_ActivePlayerCityBuildQueueChange)


----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)