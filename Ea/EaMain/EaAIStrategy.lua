-- EaAIStrategy
-- Author: Pazyryk
-- DateCreated: 2/16/2014 10:00:48 PM
--------------------------------------------------------------


function OnCityStrategyCanActivate(strategyID, iPlayer, iCity)
	print("->>CityStrategyCanActivate ", iPlayer, iCity, GameInfo.AICityStrategies[strategyID].Type)
	return true
end
GameEvents.CityStrategyCanActivate.Add(OnCityStrategyCanActivate)

function OnEconomicStrategyCanActivate(strategyID, iPlayer)
	print("->>EconomicStrategyCanActivate ", iPlayer, GameInfo.AIEconomicStrategies[strategyID].Type)
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