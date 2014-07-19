-- EaNIMBY
-- Author: Pazyryk
-- DateCreated: 5/20/2014 10:10:47 PM
--------------------------------------------------------------
print("Loading EaNIMBY.lua...")

--This is a low overhead system to value a plot based on distance from us and proximity to others (weighted by city sizes)

local Players = Players
local Teams = Teams
local gCities = gCities
local realCivs = MapModData.realCivs
local fullCivs = MapModData.fullCivs

local PlotDistance = Map.PlotDistance
local floor = math.floor

local iW, iH = Map.GetGridSize()
local iW5, iH5 = floor(iW/5) + 1, floor(iH/5) + 1

local g_playerCacheTurn = {}
local g_malus = {}
setmetatable(g_malus, OutOfRangeReturnZeroMetaTable)	--small chance for nil index between player kill and table update
local g_playerNimbyGrids = {}			--25x reduced map of the world for each player that needs it

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

	--get normalized player scores (full civs only)
	local aveScore, numFullCivs = 0, 0
	for iLoopPlayer, eaLoopPlayer in pairs(realCivs) do
		if iLoopPlayer ~= iPlayer then
			local loopPlayer = Players[iLoopPlayer]
			local score = loopPlayer:GetScore()
			g_malus[iLoopPlayer] = score
			aveScore = aveScore + score
			numFullCivs = numFullCivs + 1
		end
	end
	aveScore = aveScore / numFullCivs

	--update malus
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	for iLoopPlayer, eaLoopPlayer in pairs(realCivs) do
		if iLoopPlayer == iPlayer then
			g_malus[iLoopPlayer] = -10
		else
			local loopPlayer = Players[iLoopPlayer]
			if fullCivs[iLoopPlayer] then
				g_malus[iLoopPlayer] = g_malus[iLoopPlayer] / aveScore		--malus now = normalized score for other full civs
				if team:IsAtWar(loopPlayer:GetTeam()) then
					g_malus[iLoopPlayer] = g_malus[iLoopPlayer] * 3
				end
			else	--CSs
				local iCSAlly = loopPlayer:GetAlly()
				if iCSAlly ~= -1 then
					g_malus[iLoopPlayer] = g_malus[iCSAlly] / 2		--half as good as the player themselves
					if team:IsAtWar(Players[iCSAlly]:GetTeam()) then
						g_malus[iLoopPlayer] = g_malus[iLoopPlayer] * 2
					end
				else
					g_malus[iLoopPlayer] = 0
				end
			end
		end
	end

	--update the nimby grid
	local nimbyGrid = g_playerNimbyGrids[iPlayer]
	for x5 = 1, iW5 do
		for y5 = 1, iH5 do
			nimbyGrid[x5][y5] = 0
			for iPlot, eaCity in pairs(gCities) do
			
				local x, y = iPlot % iW, floor(iPlot / iW)
				local dist = PlotDistance(x, y, (x5-1)*5, (y5-1)*5)
				nimbyGrid[x5][y5] = nimbyGrid[x5][y5] + g_malus[eaCity.iOwner] * eaCity.size / (dist + 3)
			
			end
			print("nimbyGrid (x, y, value) = ", x5*5, y5*5, nimbyGrid[x5][y5])
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
	local nimby = g_playerNimbyGrids[iPlayer][floor(x/5) + 1][floor(y/5) + 1]
	if not nimby then
		error("nimby = nil")
	end
	return nimby
end

-- Typical return values for game turn 200 with size 10ish cities, no war:
--  Near my capital: -20 to -30
--  Around my borders: -11
--  Open ocean (most plots): -1 to 3 range
--  Other civs (top 10%): 5 to 10 
															

