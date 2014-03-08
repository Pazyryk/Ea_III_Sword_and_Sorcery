-- EaTrade
-- Author: Pazyryk
-- DateCreated: 12/1/2013 8:46:49 AM
--------------------------------------------------------------

local DOMAIN_LAND =							DomainTypes.DOMAIN_LAND
local DOMAIN_SEA =							DomainTypes.DOMAIN_SEA

local GetPlot = Map.GetPlot

local g_gameTurn = -1
local g_tradeAvailableTable = {}

function EaTradeUpdateTurn()
	g_gameTurn = Game.GetGameTurn()
end

function EaTradeDataDirty()
	g_gameTurn = -1
end
LuaEvents.EaTradeEaTradeDataDirty.Add(EaTradeDataDirty)

function FindOpenTradeRoute(iPlayer, domain, bReturnBestFromCity)
	if iPlayer ~= g_tradeAvailableTable.iPlayer or g_gameTurn ~= g_tradeAvailableTable.gameTurn then	--used cached table unless new player/turn or EaTradeDataDirty called
		local player = Players[iPlayer]		
		g_tradeAvailableTable = player:GetTradeRoutesAvailable()
		g_tradeAvailableTable.iPlayer = iPlayer
		g_tradeAvailableTable.gameTurn = g_gameTurn
	end

	--cycle all player eaCities to find all open
	local numberOpen = 0
	local bestYield = 0
	local bestCity
	for eaCityIndex, eaCity in pairs(gCities) do
		if eaCity.iOwner == iPlayer then
			local plot = GetPlot(eaCity.x, eaCity.y)
			local city = plot:GetPlotCity()
			local openTradeRoutes = domain == DOMAIN_LAND and eaCity.openLandTradeRoutes or eaCity.openSeaTradeRoutes
			for toEaCityIndex, toPlayerIndex in pairs(openTradeRoutes) do
				for i = 1, #g_tradeAvailableTable do						--g_tradeAvailableTable is updated by PlayerCanTrain check (always fires before this)
					local route = g_tradeAvailableTable[i]
					if route.FromCity == city and route.Domain == domain and route.ToID == toPlayerIndex and route.TurnsLeft == -1 then
						local toEaCity = gCities[toEaCityIndex]
						if route.ToCity:GetX() == toEaCity.x and route.ToCity:GetY() == toEaCity.y then
							numberOpen = numberOpen + 1
							if bReturnBestFromCity then
								local yield = route.FromGPT + route.FromScience + 1.5 * (route.ToFood + route.ToProduction)
								if bestYield < yield then
									bestYield = yield
									bestCity = city
								end
							end
						end
					end
				end
			end
		end
	end
	return numberOpen, bestCity, bestYield
end

--[[not used
function IsNeedForTradeUnit(iPlayer, domain)
	if iPlayer ~= g_tradeAvailableTable.iPlayer or g_gameTurn ~= g_tradeAvailableTable.gameTurn then	--used cached table unless new player/turn or EaTradeDataDirty called
		local player = Players[iPlayer]		
		g_tradeAvailableTable = player:GetTradeRoutesAvailable()
		g_tradeAvailableTable.iPlayer = iPlayer
		g_tradeAvailableTable.gameTurn = g_gameTurn
	end

	--how many trade units do we have?
	local numTradeUnits = player:GetNumAvailableTradeUnits(domain)

	--count all open until we exceed number of trade units
	local numberOpen = 0
	for eaCityIndex, eaCity in pairs(gCities) do
		if eaCity.iOwner == iPlayer then
			local plot = GetPlot(eaCity.x, eaCity.y)
			local city = plot:GetPlotCity()
			local openTradeRoutes = domain == DOMAIN_LAND and eaCity.openLandTradeRoutes or eaCity.openSeaTradeRoutes
			for toEaCityIndex, toPlayerIndex in pairs(openTradeRoutes) do
				for i = 1, #g_tradeAvailableTable do						--g_tradeAvailableTable is updated by PlayerCanTrain check (always fires before this)
					local route = g_tradeAvailableTable[i]
					if route.FromCity == city and route.Domain == domain and route.ToID == toPlayerIndex and route.TurnsLeft == -1 then
						local toEaCity = gCities[toEaCityIndex]
						if route.ToCity:GetX() == toEaCity.x and route.ToCity:GetY() == toEaCity.y then
							numberOpen = numberOpen + 1
							if numTradeUnits < numberOpen then
								return true
							end
						end
					end
				end
			end
		end
	end
	return false
end
]]
