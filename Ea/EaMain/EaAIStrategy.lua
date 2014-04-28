-- EaAIStrategy
-- Author: Pazyryk
-- DateCreated: 2/16/2014 10:00:48 PM
--------------------------------------------------------------
print("Loading EaAIStrategy.lua...")
local print = ENABLE_PRINT and print or function() end

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

local ECONOMICAISTRATEGY_NEED_HAPPINESS =			GameInfoTypes.ECONOMICAISTRATEGY_NEED_HAPPINESS
local ECONOMICAISTRATEGY_NEED_HAPPINESS_CRITICAL =	GameInfoTypes.ECONOMICAISTRATEGY_NEED_HAPPINESS_CRITICAL


local g_weLikeBeingUnhappy = {}	--1, kind of; 2, seriously


--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function WeLikeBeingUnhappy(iPlayer, level)
	if not g_weLikeBeingUnhappy[iPlayer] or g_weLikeBeingUnhappy[iPlayer] < level then
		g_weLikeBeingUnhappy[iPlayer] = level
	end
end


function OnCityStrategyCanActivate(strategyID, iPlayer, iCity)
	print("->>CityStrategyCanActivate ", iPlayer, iCity, GameInfo.AICityStrategies[strategyID].Type)
	return true
end
GameEvents.CityStrategyCanActivate.Add(OnCityStrategyCanActivate)

function OnEconomicStrategyCanActivate(strategyID, iPlayer)
	print("->>EconomicStrategyCanActivate ", iPlayer, GameInfo.AIEconomicStrategies[strategyID].Type)
	if strategyID == ECONOMICAISTRATEGY_NEED_HAPPINESS then
		if g_weLikeBeingUnhappy[iPlayer] then return false end
	elseif strategyID == ECONOMICAISTRATEGY_NEED_HAPPINESS_CRITICAL then
		if g_weLikeBeingUnhappy[iPlayer] and g_weLikeBeingUnhappy[iPlayer] > 1 then return false end
	end
	return true
end
GameEvents.EconomicStrategyCanActivate.Add(OnEconomicStrategyCanActivate)

function OnMilitaryStrategyCanActivate(strategyID, iPlayer)
	print("->>MilitaryStrategyCanActivate ", iPlayer, GameInfo.AIMilitaryStrategies[strategyID].Type)
	return true
end
GameEvents.MilitaryStrategyCanActivate.Add(OnMilitaryStrategyCanActivate)

--
--
--CityStrategyCanActivate( strategyID, playerID, cityID ) --> true/false
--EconomicStrategyCanActivate( strategyID, playerID ) --> true/false
--MilitaryStrategyCanActivate( strategyID, playerID ) --> true/false