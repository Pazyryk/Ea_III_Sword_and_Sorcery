-- EaNIMBY
-- Author: Pazyryk
-- DateCreated: 5/20/2014 10:10:47 PM
--------------------------------------------------------------
print("Loading EaNIMBY.lua...")

--This is a low overhead system to value a plot based on distance from us and proximity to others (weighted by city sizes)

local gCities = gCities
local fullCivs = MapModData.fullCivs

local PlotDistance = Map.PlotDistance
local Floor = math.floor

local iW, iH = Map.GetGridSize()
local iW5, iH5 = Floor(iW/5), Floor(iH/5)

local g_playerNimbyGrids = {}			--25x reduced map of the world for each player that needs it
local g_playerCacheTurn = {}
local g_gameTurn = -1

function UpdateNIMBYTurn(turn)
	g_gameTurn = turn
end

local function InitPlayerNIMBY(iPlayer)
	local nimbyGrid = {}
	for x5 = 1, iW5 do
		nimbyGrid[x5] = {}
	end
	g_playerNimbyGrids[iPlayer] = nimbyGrid
end

local function UpdateNIMBY(iPlayer)
	print("UpdateNIMBY ", iPlayer)
	g_playerCacheTurn[iPlayer] = g_gameTurn
	local nimbyGrid = g_playerNimbyGrids[iPlayer]
	for x5 = 1, iW5 do
		for y5 = 1, iH5 do
			nimbyGrid[x5][y5] = 0
			for iPlot, eaCity in pairs(gCities) do
				if fullCivs[eaCity.iOwner] then			--ignore CSs
					local x, y = iPlot % iW, Floor(iPlot / iW)
					local dist = PlotDistance(x, y, x5*5, y5*5)
					nimbyGrid[x5][y5] = nimbyGrid[x5][y5] + (eaCity.iOwner == iPlayer and -eaCity.size / dist or eaCity.size / dist)
				end
			end
			--print("nimbyGrid (x, y, value) = ", x5*5, y5*5, nimbyGrid[x5][y5])
		end
	end
end

function GetNIMBY(iPlayer, x, y)
	if g_playerCacheTurn[iPlayer] then
		if g_playerCacheTurn[iPlayer] < g_gameTurn - 10 then
			UpdateNIMBY(iPlayer)
		end
	else
		InitPlayerNIMBY(iPlayer)
		UpdateNIMBY(iPlayer)
	end
	return g_playerNimbyGrids[iPlayer][Floor(x/5)][Floor(y/5)] - 2		-- -2 gets us safely away from our big cities and avoids empty land
end																		-- return value is 1-3 for moderately populated foreign lands, up to 8 or more

