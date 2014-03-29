-- EaMagic
-- Author: Pazyryk
-- DateCreated: 3/28/2014 2:16:36 PM
--------------------------------------------------------------
print("Loading EaMagic.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------
--constants
local OBSERVER_TEAM = GameDefines.MAX_MAJOR_CIVS - 1
local UNIT_DUMMY_PLOT_EXPLODER =	GameInfoTypes.UNIT_DUMMY_PLOT_EXPLODER
local MISSION_RANGE_ATTACK =		GameInfoTypes.MISSION_RANGE_ATTACK

local HIGHLIGHT_COLOR = {
  WHITE =	{x=1.0, y=1.0, z=1.0, w=1.0},
  RED =		{x=1.0, y=0.0, z=0.0, w=1.0},
  GREEN =	{x=0.0, y=1.0, z=0.0, w=1.0},
  BLUE =	{x=0.0, y=0.0, z=1.0, w=1.0},
  CYAN =	{x=0.0, y=1.0, z=1.0, w=1.0},
  YELLOW =	{x=1.0, y=1.0, z=0.0, w=1.0},
  MAGENTA =	{x=1.0, y=0.0, z=1.0, w=1.0},
  GREY =	{x=0.5, y=0.5, z=0.5, w=1.0},
  BLACK =	{x=0.0, y=0.0, z=0.0, w=1.0}
}

--localized functions
local GetPlotByIndex =		Map.GetPlotByIndex
local GetPlotByXY =			Map.GetPlot
local GetPlotByIndex =		Map.GetPlotByIndex
local Rand =				Map.Rand
local Vector2 =				Vector2
local ToHexFromGrid =		ToHexFromGrid
local HandleError21 =		HandleError21

--file functions
local OnPlotEffect = {}

--file control
local g_iActivePlayer = Game.GetActivePlayer()
local g_activePlayer = Players[g_iActivePlayer]
local g_iActiveTeam = g_activePlayer:GetTeam()
local g_activeTeam = Teams[g_iActiveTeam]

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

--magic plot attack
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


--plot effect highlighting
local g_plotEffectsShowState = 0		--0, hide; 1, other player's; 2, ours

function UpdatePlotEffectHighlight(iPlot, newShowState)	--all plots if iPlot == nil
	print("UpdatePlotEffectHighlight ", iPlot, newShowState)
	if g_plotEffectsShowState == 0 and newShowState == nil then return end
	if newShowState then
		g_plotEffectsShowState = newShowState
	end

	if g_plotEffectsShowState == 0 then	--Hide plot effects
		print("Hiding plot effect highlights")
		Events.ClearHexHighlightStyle("")
	else
		local bShowOurs = g_plotEffectsShowState == 2		
		local bObserver = (not bShowOurs) and (g_iActiveTeam == OBSERVER_TEAM)
		local revealedPlotEffects = (not bShowOurs and not bObserver) and gPlayers[g_iActivePlayer].revealedPlotEffects

		if iPlot then
			print("Updating plot effect highlight for single plot", iPlot)
			local plot = GetPlotByIndex(iPlot)
			if plot:IsRevealed(g_iActiveTeam) then
				local effectID, effectStength, iEffectPlayer, iCaster = plot:GetPlotEffectData()
				local bOwnEffect = g_iActivePlayer == iEffectPlayer
				if effectID ~= -1 and ((bShowOurs and bOwnEffect) or (not bShowOurs and not bOwnEffect and (bObserver or revealedPlotEffects[iPlot]))) then	--show it
					local effectInfo = GameInfo.EaPlotEffects[effectID]
					local color = HIGHLIGHT_COLOR[effectInfo.HighlightColor]
					Events.SerialEventHexHighlight(ToHexFromGrid(Vector2(plot:GetX(), plot:GetY())), true, color)	
				else
					Events.SerialEventHexHighlight(ToHexFromGrid(Vector2(plot:GetX(), plot:GetY())), false, HIGHLIGHT_COLOR.GREEN)
				end
			end
		else
			print("Updating plot effect highlight for all revealed plots")
			Events.ClearHexHighlightStyle("")
			for iPlot = 0, Map.GetNumPlots() - 1 do
				local plot = GetPlotByIndex(iPlot)
				if plot:IsRevealed(g_iActiveTeam) then
					local effectID, effectStength, iEffectPlayer, iCaster = plot:GetPlotEffectData()
					local bOwnEffect = g_iActivePlayer == iEffectPlayer
					if effectID ~= -1 and ((bShowOurs and bOwnEffect) or (not bShowOurs and not bOwnEffect and (bObserver or revealedPlotEffects[iPlot]))) then	--show it
						local effectInfo = GameInfo.EaPlotEffects[effectID]
						local color = HIGHLIGHT_COLOR[effectInfo.HighlightColor]
						Events.SerialEventHexHighlight(ToHexFromGrid(Vector2(plot:GetX(), plot:GetY())), true, color)	
					else
						Events.SerialEventHexHighlight(ToHexFromGrid(Vector2(plot:GetX(), plot:GetY())), false, HIGHLIGHT_COLOR.GREEN)
					end
				end
			end
		end
	end
end
LuaEvents.EaMagicUpdatePlotEffectHighlight.Add(function(iPlot, newShowState) return HandleError21(UpdatePlotEffectHighlight, iPlot, newShowState) end)


--------------------------------------------------------------
-- GameEvents
--------------------------------------------------------------

--plot effects
local function OnUnitSetXYPlotEffect(iPlayer, iUnit, x, y, plotEffectID, plotEffectStrength, iPlotEffectPlayer, iPlotEffectCaster)
	print("OnUnitSetXYPlotEffect ", iPlayer, iUnit, x, y, plotEffectID, plotEffectStrength, iPlotEffectPlayer, iPlotEffectCaster)
	if OnPlotEffect[plotEffectID] then
		OnPlotEffect[plotEffectID](iPlayer, iUnit, x, y, plotEffectStrength, iPlotEffectPlayer, iPlotEffectCaster)
	end
end
GameEvents.UnitSetXYPlotEffect.Add(function(iPlayer, iUnit, x, y, plotEffectID, plotEffectStrength, iPlotEffectPlayer, iPlotEffectCaster) return HandleError(OnUnitSetXYPlotEffect, iPlayer, iUnit, x, y, plotEffectID, plotEffectStrength, iPlotEffectPlayer, iPlotEffectCaster) end)

OnPlotEffect[GameInfoTypes.EA_PLOTEFFECT_EXPLOSIVE_RUNES] = function(iPlayer, iUnit, x, y, plotEffectStrength, iPlotEffectPlayer, iPlotEffectCaster)
	local plotEffectPlayer = Players[iPlotEffectPlayer]
	if plotEffectPlayer:IsAlive() then
		local player = Players[iPlayer]
		if Teams[player:GetTeam()]:IsAtWar(plotEffectPlayer:GetTeam()) then
			print("Unit stepped on an Explosive Runes and teams are at war...")
			local plot = GetPlotByXY(x, y)
			plot:SetPlotEffectData(-1, -1, -1, -1)
			local unit = player:GetUnitByID(iUnit)
			local beforeDamage = unit:GetDamage()
			DoDummyUnitRangedAttack(iPlotEffectPlayer, x, y, plotEffectStrength)
			local afterDamage = unit and unit:GetDamage() or 100
			print("Damage to unit = ", afterDamage - beforeDamage)
			UseManaOrDivineFavor(iPlotEffectPlayer, iPlotEffectCaster, afterDamage - beforeDamage)	--safe to use if iPlotEffectCaster is dead
			LuaEvents.UpdatePlotEffectHighlight()
		else
			print("Unit stepped on an Explosive Runes, but teams are not at war...")
		end
	else
		print("Unit stepped on an Explosive Runes, but effect setter is dead; removing plot effect...")
		local plot = GetPlotByXY(x, y)
		plot:SetPlotEffectData(-1, -1, -1, -1)
		LuaEvents.UpdatePlotEffectHighlight()
	end
end

-- active player change
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
	g_activePlayer = Players[g_iActivePlayer]
	g_iActiveTeam = g_activePlayer:GetTeam()
	g_activeTeam = Teams[g_iActiveTeam]
	UpdatePlotEffectHighlight(nil, 0)
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)



--debug
function DebugSetPlotEffectAll(effectID, effectStength, iPlayer, iCaster)
	for iPlot = 0, Map.GetNumPlots() - 1 do
		local plot = GetPlotByIndex(iPlot)
		if plot:IsRevealed(g_iActiveTeam) then
			plot:SetPlotEffectData(effectID, effectStength, iPlayer, iCaster)
		end
	end
end

