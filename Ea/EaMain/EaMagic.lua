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
local OBSERVER_TEAM =				GameDefines.MAX_MAJOR_CIVS - 1
local BARB_PLAYER_INDEX =			BARB_PLAYER_INDEX
local UNIT_DUMMY_EXPLODER =			GameInfoTypes.UNIT_DUMMY_EXPLODER
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
local GetPlotIndexFromXY =	GetPlotIndexFromXY
local PlotDistance =		Map.PlotDistance
local Rand =				Map.Rand
local floor =				math.floor
local Vector2 =				Vector2
local ToHexFromGrid =		ToHexFromGrid
local HandleError21 =		HandleError21
local HandleError31 =		HandleError31

--file functions
local OnPlotEffect = {}

--file control
local g_iActivePlayer = Game.GetActivePlayer()
local g_activePlayer = Players[g_iActivePlayer]
local g_iActiveTeam = g_activePlayer:GetTeam()
local g_activeTeam = Teams[g_iActiveTeam]

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------

local xpBoostFromManaUse = {}
for eaCivInfo in GameInfo.EaCivs() do
	if eaCivInfo.XPBoostFromManaUse ~= 0 then
		xpBoostFromManaUse[eaCivInfo.ID] = eaCivInfo.XPBoostFromManaUse
	end
end

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------


MapModData.sharedIntegerList = MapModData.sharedIntegerList or {}
local sharedIntegerList = MapModData.sharedIntegerList

local function GenerateLearnableSpellList(iPlayer, iPerson, spellClass)	--iPerson = nil if this is civ test only; spellClass = nil for both 
	print("GenerateLearnableSpellList ", iPlayer, iPerson, spellClass)
	local TestSpellLearnable = TestSpellLearnable
	--This is used for human UI (Spell Panel)

	local numSpells = 0
	for spellID = FIRST_SPELL_ID, LAST_SPELL_ID do
		if TestSpellLearnable(iPlayer, iPerson, spellID, spellClass) then
			numSpells = numSpells + 1
			sharedIntegerList[numSpells] = spellID
		end
	end

	print("numSpells = ", numSpells)

	--trim recycled table for UI
	for i = #sharedIntegerList, numSpells + 1, -1 do
		sharedIntegerList[i] = nil
	end
end
LuaEvents.EaMagicGenerateLearnableSpellList.Add(function(iPlayer, iPerson, spellClass) return HandleError31(GenerateLearnableSpellList, iPlayer, iPerson, spellClass) end)


function UseManaOrDivineFavor(iPlayer, iPerson, pts, bNoDrain, consumedFloatUpPlot)
	print("UseManaOrDivineFavor ", iPlayer, iPerson, pts, bNoDrain, consumedFloatUpPlot)
	--All mana or divine favor use should go through here!

	--Reduces player faith, adds GP xp and depletes Ea's mana if appropriate
	--Returns false if player lacks sufficient mana or divine favor
	--If iPerson is nil (or dead) then no experience is given, but all other effects occur
	local player = Players[iPlayer]
	if not player:IsAlive() then return end

	local currentFaith = player:GetFaith()
	local eaPlayer = gPlayers[iPlayer]
	
	local bManaEaterFloatup = false
	if iPerson then
		local eaPerson = gPeople[iPerson]
		if eaPerson then
			local unit = player:GetUnitByID(eaPerson.iUnit)
			if unit then
				local xp = pts
				if xpBoostFromManaUse[eaPlayer.eaCivNameID] then
					xp = xp + floor(pts * xpBoostFromManaUse[eaPlayer.eaCivNameID] / 100)
				end
				unit:ChangeExperience(xp)
				if eaPlayer.bIsFallen then
					consumedFloatUpPlot = consumedFloatUpPlot or unit:GetPlot()
				end
			end
		end
	end

	if eaPlayer.bIsFallen or iPlayer == BARB_PLAYER_INDEX then
		gWorld.sumOfAllMana = gWorld.sumOfAllMana - pts
		eaPlayer.manaConsumed = (eaPlayer.manaConsumed or 0) + pts
		if not consumedFloatUpPlot then
			local capital = player:GetCapitalCity()
			if capital then
				consumedFloatUpPlot = capital:Plot()
			end
		end
		if consumedFloatUpPlot then
			consumedFloatUpPlot:AddFloatUpMessage(Locale.Lookup("TXT_KEY_EA_CONSUMED_MANA", pts), 3)
		end
	end

	if bNoDrain then
		return true
	else
		local newFaith = currentFaith - pts
		player:SetFaith(newFaith)
		return 0 <= newFaith	--deficit?
	end
end


function DrainExperience(unit, xp)
	print("DrainExperience ", unit, xp)
	local oldLevel = unit:GetLevel()
	local oldXP = unit:GetExperience()
	local xpDrained = xp < oldXP and xp or oldXP
	unit:SetExperience(oldXP - xpDrained)
	local newLevel = 1
	unit:SetLevel(1)
	while unit:ExperienceNeeded() < 1 do
		newLevel = newLevel + 1
		unit:SetLevel(newLevel)
	end
	local levelsLost = oldLevel - newLevel
	if 0 < levelsLost then
		print("Lost levels = ", levelsLost)
		local promoRemoveList = {}
		for i = 1, levelsLost do		--remove a random earnable promotion (that is not required for any other promotion)
			print("Generating list of earnable, non-prereq promotions that might be removed")
			local numPromos = 0
			for promoInfo in GameInfo.UnitPromotions("CannotBeChosen = 0") do
				if unit:IsHasPromotion(promoInfo.ID) then
					local promoType = promoInfo.Type
					local bAllow = true
					for promoLoopInfo in GameInfo.UnitPromotions("CannotBeChosen = 0 AND PromotionPrereq = '" .. promoType .. "'") do
						if unit:IsHasPromotion(promoLoopInfo.ID) then
							bAllow = false
							break
						end
					end
					if bAllow then
						print(" *", promoInfo.ID, promoInfo.Type)
						numPromos = numPromos + 1
						promoRemoveList[numPromos] = promoInfo.ID
					end
				end
			end
			if numPromos == 0 then
				print("!!!! ERROR: Could not find any valid promotions to remove after level drain")
			else
				local dice = Rand(numPromos, "hello") + 1
				print("Removing this one from list above: ", promoRemoveList[dice])
				unit:SetHasPromotion(promoRemoveList[dice], false)
			end
		end
	end
	return xpDrained, oldLevel - newLevel
end

--magic plot attack
function DoDummyUnitRangedAttack(iPlayer, x, y, mod, dummyUnitID)
	print("DoDummyUnitRangedAttack ", iPlayer, x, y, mod, dummyUnitID)
	--Inits a suidide air unit that attacks x, y coordinates; assumes that there is an enemy of iPlayer there
	--roughly speaking, mod integer represents adjusted range strength for UNIT_DUMMY_EXPLODER
	--iPlayer for Animals or Barbarians doesn't work for some reason (barbs can't air attack?) 
	dummyUnitID = dummyUnitID or UNIT_DUMMY_EXPLODER

	local spawnPlot = GetPlotForSpawn(GetPlotByXY(x, y), iPlayer, 10, true, false, nil, true, true, true)
	if spawnPlot then
		local player = Players[iPlayer]
		local spawnX, spawnY = spawnPlot:GetXY()
		local dummyUnit = player:InitUnit(dummyUnitID, spawnX, spawnY)
		if mod then
			dummyUnit:SetMorale(mod * 10 - 100)
		end
		print("iUnit, CanRangeStrikeAt = ", dummyUnit:GetID(), dummyUnit:CanRangeStrikeAt(x, y))
		dummyUnit:RangeStrike(x, y)
			
		print("IsDead, IsDelayedDeath = ", dummyUnit:IsDead(), dummyUnit:IsDelayedDeath())
		return true
	end

	--works for nuke?
	--Try GameInfoTypes.MISSION_NUKE with x, y only (as per dll call); then try it with nuke from city



	print("!!!! WARNING: Did not find plot for dummy unit spawn")	--should not ever happen with 10 radius spiral search
	return false
end


--plot effect highlighting
local g_plotEffectsShowState = 0		--0, hide; 1, other player's; 2, ours

function UpdatePlotEffectHighlight(iPlot, newShowState, bForceFullUpdate)	--all plots if iPlot == nil
	print("UpdatePlotEffectHighlight ", iPlot, newShowState, bForceFullUpdate)
	if UI.IsCityScreenUp() then
		print("Clearing plot effect highlights for city screen")
		Events.ClearHexHighlightStyle("")
	else
		if g_plotEffectsShowState == 0 and newShowState == nil and not bForceFullUpdate then return end
		if newShowState and newShowState ~= g_plotEffectsShowState then
			bForceFullUpdate = true
			g_plotEffectsShowState = newShowState
		end

		if g_plotEffectsShowState == 0 then	--Hide plot effects
			print("Hiding plot effect highlights")
			Events.ClearHexHighlightStyle("")
		else
			local bShowOurs = g_plotEffectsShowState == 2		
			local bObserver = (not bShowOurs) and (g_iActiveTeam == OBSERVER_TEAM)
			local revealedPlotEffects = (not bShowOurs and not bObserver) and gPlayers[g_iActivePlayer].revealedPlotEffects

			if iPlot and not bForceFullUpdate then
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
end
LuaEvents.EaMagicUpdatePlotEffectHighlight.Add(function(iPlot, newShowState, bForceFullUpdate) return HandleError31(UpdatePlotEffectHighlight, iPlot, newShowState, bForceFullUpdate) end)

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

OnPlotEffect[GameInfoTypes.EA_PLOTEFFECT_EXPLOSIVE_RUNE] = function(iPlayer, iUnit, x, y, plotEffectStrength, iPlotEffectPlayer, iPlotEffectCaster)
	local plotEffectPlayer = Players[iPlotEffectPlayer]
	if plotEffectPlayer:IsAlive() then
		local player = Players[iPlayer]
		if Teams[player:GetTeam()]:IsAtWar(plotEffectPlayer:GetTeam()) then
			print("Unit stepped on an Explosive Rune and teams are at war...")
			local plot = GetPlotByXY(x, y)
			plot:SetPlotEffectData(-1, -1, -1, -1)
			local unit = player:GetUnitByID(iUnit)
			local unitTypeID = unit:GetUnitType()
			local maxHP = unit:GetMaxHitPoints()
			local beforeDamage = unit:GetDamage()
			DoDummyUnitRangedAttack(iPlotEffectPlayer, x, y, plotEffectStrength)
			local afterDamage = unit and unit:GetDamage() or maxHP
			local damage = afterDamage - beforeDamage
			print("Damage to unit = ", damage)
			local xpMana = CalculateXPManaForAttack(unitTypeId, damage, damage == maxHP)
			UseManaOrDivineFavor(iPlotEffectPlayer, iPlotEffectCaster, xpMana)	--safe to use if iPlotEffectCaster is dead
			local iPlot = GetPlotIndexFromXY(x, y) 
			UpdatePlotEffectHighlight(iPlot)
		else
			print("Unit stepped on an Explosive Rune, but teams are not at war...")
		end
	else
		print("Unit stepped on an Explosive Rune, but effect player is dead; removing plot effect...")
		local plot = GetPlotByXY(x, y)
		plot:SetPlotEffectData(-1, -1, -1, -1)
		local iPlot = GetPlotIndexFromXY(x, y)
		UpdatePlotEffectHighlight(iPlot)
	end
end

OnPlotEffect[GameInfoTypes.EA_PLOTEFFECT_DEATH_RUNE] = function(iPlayer, iUnit, x, y, plotEffectStrength, iPlotEffectPlayer, iPlotEffectCaster)
	local plotEffectPlayer = Players[iPlotEffectPlayer]
	if plotEffectPlayer:IsAlive() then
		local player = Players[iPlayer]
		if Teams[player:GetTeam()]:IsAtWar(plotEffectPlayer:GetTeam()) then
			print("Unit stepped on a Death Rune and teams are at war...")
			local plot = GetPlotByXY(x, y)
			plot:SetPlotEffectData(-1, -1, -1, -1)
			--special effects for active player
			if iPlayer == g_iActivePlayer or iPlotEffectPlayer == g_iActivePlayer or plot:IsVisible(g_iActiveTeam) then
				UI.LookAt(plot, 0)
				local hex = ToHexFromGrid(Vector2(plot:GetXY()))
				Events.GameplayFX(hex.x, hex.y, -1)
			end
			local unit = player:GetUnitByID(iUnit)
			local beforeDamage = unit:GetDamage()
			local experience = unit:GetExperience()
			local combat = unit:GetBaseCombatStrength()
			local ranged = unit:GetBaseRangedCombatStrength()
			local threshold = experience < combat and combat or experience
			threshold = threshold < ranged and ranged or threshold	--greatest of 3
			if threshold < plotEffectStrength then		--instant death
				--xp/mana should be the greater of threashold or the standard attack pts
				local hp = unit:GetMaxHitPoints() - beforeDamage
				local unitTypeID = unit:GetUnitType()
				MapModData.bBypassOnCanSaveUnit = true
				unit:Kill(true, iPlotEffectPlayer)
				local stdPts = CalculateXPManaForAttack(unitTypeId, hp, true)
				local xpMana = threshold < stdPts and stdPts or threshold
				print("Death Rune killed the unit; xp/mana = ", xpMana)
				UseManaOrDivineFavor(iPlotEffectPlayer, iPlotEffectCaster, xpMana)	--safe to use if iPlotEffectCaster is dead
			else
				local xpDrained, levelsDrained = DrainExperience(unit, plotEffectStrength)
				local xpMana = xpDrained + 5 * levelsDrained
				UseManaOrDivineFavor(iPlotEffectPlayer, iPlotEffectCaster, xpMana)
			end
			local iPlot = GetPlotIndexFromXY(x, y)
			UpdatePlotEffectHighlight(iPlot)
		else
			print("Unit stepped on an Death Rune, but teams are not at war...")
		end
	else
		print("Unit stepped on an Death Rune, but effect player is dead; removing plot effect...")
		local plot = GetPlotByXY(x, y)
		plot:SetPlotEffectData(-1, -1, -1, -1)
		local iPlot = GetPlotIndexFromXY(x, y)
		UpdatePlotEffectHighlight(iPlot)
	end
end

--------------------------------------------------------------
-- Active player change
--------------------------------------------------------------

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
	UpdatePlotEffectHighlight(nil)
end

