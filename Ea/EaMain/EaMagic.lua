-- EaMagic
-- Author: Pazyryk
-- DateCreated: 3/28/2014 2:16:36 PM
--------------------------------------------------------------
print("Loading EaMagic.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end


--constants
local UNIT_DUMMY_PLOT_EXPLODER =	GameInfoTypes.UNIT_DUMMY_PLOT_EXPLODER
local MISSION_RANGE_ATTACK =		GameInfoTypes.MISSION_RANGE_ATTACK


--localized functions
local GetPlotByXY =			Map.GetPlot
local Rand =				Map.Rand



function DoDummyUnitRangedAttack(iPlayer, x, y, mod, dummyUnitID)
	--Assumes that there is an enemy of iPlayer at coordinates
	dummyUnitID = dummyUnitID or UNIT_DUMMY_PLOT_EXPLODER
	mod = mod or 5	--roughly speaking, this integer represents adjusted range strength for UNIT_DUMMY_PLOT_EXPLODER
	local player = Players[iPlayer]
	local targetPlot = GetPlotByXY(x, y)
	local sector = Rand(6, "hello") + 1
	for spawnPlot in PlotAreaSpiralIterator(targetPlot, 10, sector, false, false, false) do
		if spawnPlot:GetNumUnits() == 0 then
			local spawnX, spawnY = spawnPlot:GetXY()
			local dummyUnit = player:InitUnit(dummyUnitID, spawnX, spawnY)
			dummyUnit:SetMorale(mod * 10 - 100)
			dummyUnit:PushMission(MISSION_RANGE_ATTACK, x, y, 0, 0, 1)
			return true
		end
	end
	print("!!!! WARNING: Did not find plot for dummy unit spawn")	--should not ever happen with 10 radius spiral search
	return false
end