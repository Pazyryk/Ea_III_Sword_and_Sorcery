-- EaTrade
-- Author: Pazyryk
-- DateCreated: 12/1/2013 8:46:49 AM
--------------------------------------------------------------

local DOMAIN_LAND =							DomainTypes.DOMAIN_LAND

local HandleError51 = HandleError51

local function OnCanCreateTradeRoute(iOriginPlot, iDestPlot, iDestPlayer, eDomain, eConnectionType)
	--print("OnCanCreateTradeRoute ", iOriginPlot, iDestPlot, iDestPlayer, eDomain, eConnectionType)
	if MapModData.bBypassOnCanCreateTradeRoute then return true end
	if not gCities[iOriginPlot] then return false end --ls612: cheap hack, city exists in the DLL but not in lua
	local bIsOpenRoute = gCities[iOriginPlot].iOwner == iDestPlayer
	if not bIsOpenRoute then
		local iOpenRouteDestPlayer = (eDomain == DOMAIN_LAND) and gCities[iOriginPlot].openLandTradeRoutes[iDestPlot] or gCities[iOriginPlot].openSeaTradeRoutes[iDestPlot]
		bIsOpenRoute = iOpenRouteDestPlayer == iDestPlayer
	end
	if MapModData.bReverseOnCanCreateTradeRoute then
		return not bIsOpenRoute
	else
		return bIsOpenRoute
	end
end
GameEvents.CanCreateTradeRoute.Add(function(iOriginPlot, iDestPlot, iDestPlayer, eDomain, eConnectionType) return HandleError51(OnCanCreateTradeRoute, iOriginPlot, iDestPlot, iDestPlayer, eDomain, eConnectionType) end)



