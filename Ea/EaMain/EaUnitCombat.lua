-- EaUnitCombat
-- Author: Pazyryk
-- DateCreated: 3/25/2014 9:38:36 AM
--------------------------------------------------------------

print("Loading EaUnitCombat.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

--constants
local BARB_PLAYER_INDEX =							BARB_PLAYER_INDEX
local ANIMALS_PLAYER_INDEX =						ANIMALS_PLAYER_INDEX

local DOMAIN_LAND =									DomainTypes.DOMAIN_LAND

local BUILDING_INTERNMENT_CAMP =					GameInfoTypes.BUILDING_INTERNMENT_CAMP
local EARACE_MAN =									GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =								GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =							GameInfoTypes.EARACE_HELDEOFOL
local INVISIBLE_SUBMARINE =							GameInfoTypes.INVISIBLE_SUBMARINE
local POLICY_SLAVERY =								GameInfoTypes.POLICY_SLAVERY
local PROMOTION_FOR_HIRE =							GameInfoTypes.PROMOTION_FOR_HIRE
local PROMOTION_MERCENARY =							GameInfoTypes.PROMOTION_MERCENARY
local PROMOTION_SLAVE =								GameInfoTypes.PROMOTION_SLAVE
local PROMOTION_SLAVERAIDER =						GameInfoTypes.PROMOTION_SLAVERAIDER
local PROMOTION_SLAVEMAKER =						GameInfoTypes.PROMOTION_SLAVEMAKER
local UNIT_SLAVES_MAN =								GameInfoTypes.UNIT_SLAVES_MAN
local UNIT_SLAVES_SIDHE =							GameInfoTypes.UNIT_SLAVES_SIDHE
local UNIT_SLAVES_ORC =								GameInfoTypes.UNIT_SLAVES_ORC
local UNIT_WORKERS_MAN =							GameInfoTypes.UNIT_WORKERS_MAN
local UNIT_WORKERS_SIDHE =							GameInfoTypes.UNIT_WORKERS_SIDHE
local UNIT_WORKERS_ORC =							GameInfoTypes.UNIT_WORKERS_ORC

--localized tables
local gPlayers =					gPlayers
local gPeople =						gPeople
local Players =						Players
local fullCivs =					MapModData.fullCivs
local gg_bNormalLivingCombatUnit =	gg_bNormalLivingCombatUnit

--localized functions
local HandleError =					HandleError
local HandleError10 =				HandleError10
local HandleError21 =				HandleError21


--file control
local g_bInitialized = false
local g_iActivePlayer = Game.GetActivePlayer()
local g_delayedAttacks = {pos = 0}
local g_iDefendingPlayer = -1
local g_iDefendingUnit = -1
local g_iAttackingPlayer = -1
local g_iAttackingUnit = -1


--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------


--------------------------------------------------------------
-- Init
--------------------------------------------------------------
function EaUnitCombatInit(bNewGame)
	g_bInitialized = true
end

--------------------------------------------------------------
-- Events DEPRECIATE!
--------------------------------------------------------------

--TO DO: Get rid of Events hook below. Replace with new GameEvents.

local function OnSerialEventUnitCreated(iPlayer, iUnit, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	Dprint("Running SerialEventUnitCreated ", iPlayer, iUnit, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	--WARNINGS:
	--unitType is not unitTypeID
	--runs for embark, disembark
	
		--what is unitType??? (...not unitTypeID)
	if not g_bInitialized then return end
	local player = Players[iPlayer]
	local unit = player:GetUnitByID(iUnit)
	if not unit then return end
	Dprint("Actual unitTypeID = ", unit:GetUnitType())

	if iPlayer == BARB_PLAYER_INDEX then	--includes new spawns and captured slaves
		--convert to slaves if spawned in or adjacent to border (i.e., rebels) and city has an internment camp
		local plot = unit:GetPlot()
		local city = plot:GetWorkingCity()
		if not city then
			for x, y in PlotToRadiusIterator(plot:GetX(), plot:GetY(), 1) do
				city = Map.GetPlot(x, y):GetWorkingCity()
				if city then break end
			end
		end
		if city and city:GetNumRealBuilding(BUILDING_INTERNMENT_CAMP) == 1 then
			unit:Kill(true, -1)	--unit:SetDamage(unit:GetMaxHitPoints())
			local raceID = GetCityRace(city)		--TO DO: make these unit race, not city race
			local unitID
			if raceID == EARACE_MAN then
				unitID = UNIT_SLAVES_MAN
			elseif raceID == EARACE_SIDHE then
				unitID = UNIT_SLAVES_SIDHE
			else 
				unitID = UNIT_SLAVES_ORC
			end
			local newUnit = player:InitUnit(unitID, city:GetX(), city:GetY() )
			newUnit:JumpToNearestValidPlot()
			newUnit:SetHasPromotion(PROMOTION_SLAVE, true)
		end
	else
		if unit:GetOriginalOwner() == iPlayer then	--these are built or possibly recaptured units
			--TO DO: Non-transferable promotions in case of recapture? (OK now because only Slave Armies civ can recapture a military unit)

			local unitTypeID = unit:GetUnitType()
			if (unitTypeID == UNIT_SLAVES_MAN or unitTypeID == UNIT_SLAVES_SIDHE or unitTypeID == UNIT_SLAVES_ORC) and not player:HasPolicy(POLICY_SLAVERY) then	--freed slave
				local convertID = GameInfoTypes.UNIT_WORKERS_MAN
				if unitTypeID == UNIT_SLAVES_SIDHE then
					convertID = GameInfoTypes.UNIT_WORKERS_SIDHE
				elseif unitTypeID == UNIT_SLAVES_ORC then
					convertID = GameInfoTypes.UNIT_WORKERS_ORC
				end
				local newUnit = player:InitUnit(convertID, unit:GetX(), unit:GetY() )
				newUnit:Convert(unit)
				unit:SetHasPromotion(PROMOTION_SLAVE, false)
			end
		else
			print("SerialEventUnitCreated: New unit does not belong to iPlayer (iPlayer, iUnit)", iPlayer, iUnit)
			for i = 1, numNonTransferablePromos do
				unit:SetHasPromotion(nonTransferablePromos[i] , false)
			end
			if unit:GetDomainType() == DOMAIN_LAND then	--must be captured land unit or hired mercenary (ship capture will be handled separately)
				if unit:GetUnitCombatType() == -1 then	--civilian so must be barb capture or a slave
					if iPlayer == BARB_PLAYER_INDEX then
						print("Barbs captured ", GameInfo.Units[unit:GetUnitType()].Type)
					elseif iPlayer == ANIMALS_PLAYER_INDEX then
						print("removing unit captured by animals ", GameInfo.Units[unit:GetUnitType()].Type)
						unit:Kill(true, -1)
					else
						local unitTypeID = unit:GetUnitType()
						
						if unitTypeID ~= UNIT_SLAVES_MAN and unitTypeID ~= UNIT_SLAVES_SIDHE and unitTypeID ~= UNIT_SLAVES_ORC then
							if unitTypeID == UNIT_WORKERS_MAN and unitTypeID == UNIT_WORKERS_SIDHE and unitTypeID == UNIT_WORKERS_ORC then
								print("!!!! ???? Recapture of a worker from barbs? ", GameInfo.Units[unitTypeID].Type)
							else
								error("Something went wrong with unit capture " .. GameInfo.Units[unitTypeID].Type)
							end
						end
					
						if player:HasPolicy(POLICY_SLAVERY) then
							print("Slavery civ captured a civilian slave")
							unit:SetHasPromotion(PROMOTION_SLAVE, true)
						else
							print("removing slave from non-eligable civ")
							unit:Kill(true, -1)
						end
					end
				else		--must be newly hired mercenary or captured military unit	
					local mercenaries = gPlayers[iPlayer].mercenaries
					for _, mercs in pairs(mercenaries) do
						if mercs[iUnit] then
							print("SerialEventUnitCreated found newly hired mercenary")
							return
						end
					end
					print("SerialEventUnitCreated found newly captured military unit; setting Slave promotion, removing non-compatable promotions")
					unit:SetHasPromotion(PROMOTION_FOR_HIRE , false)
					unit:SetHasPromotion(PROMOTION_MERCENARY , false)						
					unit:SetHasPromotion(PROMOTION_SLAVE, true)
					--ChangeUnitMorale(iPlayer, iUnit, -30, true)
					unit:SetMorale(-30)
				end
			end
		end
	end
end
Events.SerialEventUnitCreated.Add(function(iPlayer, iUnit, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible) return HandleError(OnSerialEventUnitCreated, iPlayer, iUnit, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible) end)

--------------------------------------------------------------
-- Combat GameEvents and supporting local functions
--------------------------------------------------------------

--Forced interface mode - Active player only: must do something specific or drop this interface mode
local function ResetForcedSelectionUnit()		--active player only
	print("ResetForcedSelectionUnit")
	local iUnit = MapModData.forcedUnitSelection
	local player = Players[g_iActivePlayer]
	local unit = player:GetUnitByID(iUnit)
	MapModData.forcedUnitSelection = -1
	MapModData.forcedInterfaceMode = -1
	if unit then
		if unit:GetGPAttackState() == 1 then
			unit:SetGPAttackState(0)
			unit:SetInvisibleType(INVISIBLE_SUBMARINE)
		end
	end

end
LuaEvents.EaUnitsResetForcedSelectionUnit.Add(function() return HandleError10(ResetForcedSelectionUnit) end)

local function DoForcedInterfaceMode()
	Dprint("DoForcedInterfaceMode")
	if MapModData.forcedUnitSelection == -1 then return end
	if not Players[g_iActivePlayer]:IsTurnActive() then return end
	--need active player current turn check?
	--if UI.GetInterfaceMode() == MapModData.forcedInterfaceMode then return end	--unlikely we have jumped to another unit and gotten into the same interface

	print("Running DoForcedInterfaceMode")

	local unit = Players[g_iActivePlayer]:GetUnitByID(MapModData.forcedUnitSelection)
	if unit then
		if unit ~= UI.GetHeadSelectedUnit() then
			print("!!!! Warning: Selected unit is not forcedUnitSelection; cancelling")
			ResetForcedSelectionUnit()
		elseif UI.GetInterfaceMode() ~= MapModData.forcedInterfaceMode then
			print("Setting interface mode")
			UI.SetInterfaceMode(MapModData.forcedInterfaceMode)
		end
	else
		print("!!!! ERROR: failed to obtain unit object from MapModData.forcedUnitSelection")
		ResetForcedSelectionUnit()
	end

end
Events.SerialEventGameDataDirty.Add(DoForcedInterfaceMode)
Events.SerialEventUnitInfoDirty.Add(DoForcedInterfaceMode)




--Melee attack resulting from Lead Charge has to be delayed
local function DoDelayedAttacks(iPlayer)	--called by OnPlayerPreAIUnitUpdate for AI or by a delayed timed event for human
	if g_delayedAttacks.pos == 0 then return end
	print("DoDelayedAttacks iPlayer")
	local player = Players[iPlayer]
	for i = 1, g_delayedAttacks.pos do
		local delayedAttack = g_delayedAttacks[i]
		local unit = player:GetUnitByID(delayedAttack.iUnit)
		if unit then

			local x, y = unit:GetX(), unit:GetY()
			print(unit:GetX(), unit:GetY(), delayedAttack.x, delayedAttack.y)
			unit:PushMission(MissionTypes.MISSION_MOVE_TO, delayedAttack.x, delayedAttack.y)
			local newX, newY = unit:GetX(), unit:GetY()

			--Reset Warrior
			local iPerson = delayedAttack.iPerson
			local eaPerson = gPeople[iPerson]
			if eaPerson then
				local iPersonUnit = eaPerson.iUnit
				local personUnit = player:GetUnitByID(iPersonUnit)
				if personUnit and not personUnit:IsDelayedDeath() then
					personUnit:SetGPAttackState(0)
					personUnit:SetInvisibleType(INVISIBLE_SUBMARINE)
					if newX ~= x or newY ~= y then
						print("teleporting GP to follow melee unit")
						personUnit:SetXY(newX, newY)
					end
				end
			end
		end
	end
	g_delayedAttacks.pos = 0
end

local MELEE_ATTACK_AFTER_THOUSANDTHS_SECONDS = 500
local bStart = false
local g_tickStart = 0
function TimeDelayForHumanMeleeCharge(tickCount, timeIncrement)		--DON'T LOCALIZE! Causes CTD with RemoveAll
	if bStart then
		if MELEE_ATTACK_AFTER_THOUSANDTHS_SECONDS < tickCount - tickStart then
			Events.LocalMachineAppUpdate.RemoveAll()	--also removes tutorial checks (good riddence!)
			print("TimeDelayForHumanMeleeCharge; delay in sec/1000 = ", tickCount - tickStart)
			print("os.clock() / tickCount : ", os.clock(), tickCount)
			DoDelayedAttacks(Game.GetActivePlayer())
		end
	else
		tickStart = tickCount
		bStart = true
	end
end

local function OnPlayerPreAIUnitUpdate(iPlayer)	--this fires for AI players after PlayerDoTurn (before unit orders I think)
	print("OnPlayerPreAIUnitUpdate ", iPlayer)
	DoDelayedAttacks(iPlayer)
end
GameEvents.PlayerPreAIUnitUpdate.Add(function(iPlayer) return HandleError10(OnPlayerPreAIUnitUpdate, iPlayer) end)


local function WarriorLeadCharge(iPlayer, attackingUnit, targetX, targetY)
	print("WarriorLeadCharge ", iPlayer, attackingUnit, targetX, targetY)
	local player = Players[iPlayer]
	local plot = attackingUnit:GetPlot()
	local unitCount = plot:GetNumUnits()
	for i = 0, unitCount - 1 do
		local unit = plot:GetUnit(i)
		if unit ~= attackingUnit and unit:GetOwner() == iPlayer and not unit:IsOnlyDefensive() then
			local unitTypeID = unit:GetUnitType()
			if gg_bNormalLivingCombatUnit[unitTypeID] then
				print("Found melee unit for Warrior charge ", unitTypeID)
				local iPerson = attackingUnit:GetPersonIndex()
				local moraleBoost = 2 * GetGPMod(iPerson, "EAMOD_COMBAT", nil)
				unit:ChangeMorale(moraleBoost)
				local floatUp = "+" .. moraleBoost .. " [ICON_HAPPINESS_1] Morale"
				plot:AddFloatUpMessage(floatUp)
				g_delayedAttacks.pos = g_delayedAttacks.pos + 1
				g_delayedAttacks[g_delayedAttacks.pos] = {iUnit = unit:GetID(), x = targetX, y = targetY, iPerson = iPerson}
				if player:IsHuman() then
					Events.LocalMachineAppUpdate.Add(TimeDelayForHumanMeleeCharge)
				end
				break
			end
		end
	end
	attackingUnit:SetGPAttackState(0)
end

local function UpdateWarriorPoints(iPlayer, bCombat)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local oldPoints = eaPlayer.classPoints[5]
	local newPoints = player:GetLifetimeCombatExperience() - gg_combatPointDiff[iPlayer]
	print("GetLifetimeCombatExperience= ", player:GetLifetimeCombatExperience())
	if bCombat and oldPoints == newPoints then		--must have been barb so add 1 point
		print("Must be barb combat; adding 1 pt")
		gg_combatPointDiff[iPlayer] = gg_combatPointDiff[iPlayer] - 1
		newPoints = newPoints + 1
	end
	eaPlayer.classPoints[5] = newPoints
end

local function OnCombatResult(iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP, iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, targetX, targetY)
	--As currently coded in dll, iAttackingPlayer = -1 for a city ranged attack
	print("OnCombatResult ", iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP, iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, targetX, targetY)
	g_iDefendingPlayer = iDefendingPlayer
	g_iDefendingUnit = iDefendingUnit
	g_iAttackingPlayer = iAttackingPlayer
	g_iAttackingUnit = iAttackingUnit		--keep all this info in case it is a GP that needs to be saved
	if iAttackingPlayer == -1 then return end
	local attackingPlayer = Players[iAttackingPlayer]
	local attackingUnit = attackingPlayer:GetUnitByID(iAttackingUnit)	--unit will be nil if dead
	local defendingPlayer = Players[iDefendingPlayer]
	local defendingUnit = defendingPlayer:GetUnitByID(iDefendingUnit)
	print("attackerX, Y = ", attackingUnit and attackingUnit:GetX(), attackingUnit and attackingUnit:GetY())

	if fullCivs[iAttackingPlayer] then	--if full civ then do various functions
		if attackingUnit then
	
			if attackingUnit:IsGreatPerson() then
				local attackState = attackingUnit:GetGPAttackState()
				if attackState == 1 then					--This is a Warrior Lead Charge
					WarriorLeadCharge(iAttackingPlayer, attackingUnit, targetX, targetY)
				elseif attackState == 2 then
	
				end
			end
		end
	end

	if defenderMaxHP == 200	then	--get from Defines
		
		--TO DO: get city race
		gg_defendingCityRace = EARACE_MAN		--use this in city conquest event for slaves
	else
		local defendingUnit = defendingPlayer:GetUnitByID(iDefendingUnit)	
		if defendingUnit then
			local unitTypeID = defendingUnit:GetUnitType()

			--TO DO: Get race from cached table
			g_defendingUnitRace = EARACE_MAN
		end
	end
end
GameEvents.CombatResult.Add(function(iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP, iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, targetX, targetY) return HandleError(OnCombatResult, iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP, iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, targetX, targetY) end)

local function OnCombatEnded(iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP, iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, plotX, plotY)
	print("OnCombatEnded ", iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP, iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, plotX, plotY)
	if iAttackingPlayer == -1 then return end
	local attackingPlayer = Players[iAttackingPlayer]
	local attackingUnit = attackingPlayer:GetUnitByID(iAttackingUnit)	--unit will be nil if dead
	local defendingPlayer = Players[iDefendingPlayer]
	local defendingUnit = defendingPlayer:GetUnitByID(iDefendingUnit)

	if fullCivs[iAttackingPlayer] then	--if full civ then do various functions
		if attackingUnit then

			UpdateWarriorPoints(iAttackingPlayer, true)		--attacker Warrior points
			if defenderMaxHP < defenderFinalDamage and defenderMaxHP == 100 then					--must have been a unit kill
				if attackingUnit:IsHasPromotion(PROMOTION_SLAVERAIDER) and not attackingUnit:IsHasPromotion(PROMOTION_SLAVEMAKER) then
					
					local slaveID = UNIT_SLAVES_MAN

					if g_defendingUnitRace == EARACE_SIDHE then
						slaveID = UNIT_SLAVES_SIDHE
					elseif g_defendingUnitRace == EARACE_HELDEOFOL then
						slaveID = UNIT_SLAVES_ORC
					end
					local newUnit = attackingPlayer:InitUnit(slaveID, attackingUnit:GetX(), attackingUnit:GetY() )
					newUnit:JumpToNearestValidPlot()
					newUnit:SetHasPromotion(PROMOTION_SLAVE, true)
				end
			end
		end
	end
	--archer city conquest test
	if iAttackingUnitDamage == 0 and attackingUnit and iAttackingPlayer < BARB_PLAYER_INDEX and not defendingUnit and defenderMaxHP - 1 <= defenderFinalDamage and defenderMaxHP == 200 then	--archer defeated city
		local plot = GetPlotFromXY(plotX, plotY)
		local city = plot:GetPlotCity()
		if city and city:GetDamage() >= MAX_CITY_HIT_POINTS - 1 then
			print("Detected archer attack with adjacent 1 hp enemy city; teleporting archer to city plot")
			attackingUnit:SetXY(plotX, plotY)			--conquers city!
		end
	end

	if fullCivs[iDefendingPlayer] and defendingUnit then	--defender Warrior points
		UpdateWarriorPoints(iDefendingPlayer, true)
	end

end
GameEvents.CombatEnded.Add(function(iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP, iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, plotX, plotY) return HandleError(OnCombatEnded, iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP, iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, plotX, plotY) end)

local function OnCanSaveUnit(iPlayer, iUnit)	--fires for combat and non-combat death (disband, settler settled, etc)
	--Uses and resets file locals set in OnCombatResult above; always fires after that function if this is a combat death
	--Note that file locals could be anything if this is not a combat death
	print("OnCanSaveUnit ", iPlayer, iUnit)
	
	local player = Players[iPlayer]
	local unit = player:GetUnitByID(iUnit)
	local iPerson = unit:GetPersonIndex()

	if iPerson == -1 then	--not a GP
		g_iDefendingPlayer, g_iDefendingUnit, g_iAttackingPlayer, g_iAttackingUnit = -1, -1, -1, -1
		return false
	end	

	if iPlayer ~= g_iDefendingPlayer or iUnit ~= g_iDefendingUnit then	--this was not a combat defender death
		local deathType
		if iPlayer == g_iAttackingPlayer and iUnit == g_iAttackingUnit then
			print("An attacking GP was killed in combat")
			deathType = "Attack"
		else
			print("A GP was killed for unknown reason; disbanded?")
			deathType = "Unknown"
		end
		KillPerson(iPlayer, iPerson, nil, nil, deathType)	--unit must be nil here because dll will finish it off!
		g_iDefendingPlayer, g_iDefendingUnit, g_iAttackingPlayer, g_iAttackingUnit = -1, -1, -1, -1
		return false
	end	
	
	print("This is a GP defender defeat; unitType = ", unit and GameInfo.Units[unit:GetUnitType()].Type or "nil")

	local attackingPlayer = Players[g_iAttackingPlayer]
	if attackingPlayer then
		local attackingUnit = attackingPlayer:GetUnitByID(iAttackingUnit)
		if attackingUnit and attackingUnit:IsGreatPerson() then
			print("A GP was killed by an attacking unit in GP layer")
			KillPerson(iPlayer, iPerson, nil, nil, "Killed by GP layer unit")
			g_iDefendingPlayer, g_iDefendingUnit, g_iAttackingPlayer, g_iAttackingUnit = -1, -1, -1, -1
			return false
		end
	end

	g_iDefendingPlayer, g_iDefendingUnit, g_iAttackingPlayer, g_iAttackingUnit = -1, -1, -1, -1

	print("Trying to save GP")
	local currentPlot = unit:GetPlot()
	local sector = Rand(6, "hello") + 1
	for testPlot in PlotAreaSpiralIterator(currentPlot, 15, sector, false, false, false) do
		if player:GetPlotDanger(testPlot) == 0 then								--is this plot out of danger?
			if unit:TurnsToReachTarget(testPlot, 1, 1, 1) < 100 then		--is this plot accessible?
				unit:SetXY(testPlot:GetX(), testPlot:GetY())
				unit:SetEmbarked(testPlot:IsWater())
				testPlot:AddFloatUpMessage("Great Person has escaped!")		--TO DO: txt key
				print("Great Person has escaped!")
				return true
			end
		end
	end
	print("!!!! WARNING: Could not find safe accessible plot for GP to escape to; GP will die!")
	KillPerson(iPlayer, iPerson, nil, nil, "Failed to save GP")
	return false

end
GameEvents.CanSaveUnit.Add(function(iPlayer, iUnit) return HandleError21(OnCanSaveUnit, iPlayer, iUnit) end)


--local function OnUnitKilledInCombat(iKillerPlayer, iKilledPlayer, unitTypeID)
--	--always right after OnCanSaveUnit if it was a combat kill
--end
--GameEvents.UnitKilledInCombat.Add(OnUnitKilledInCombat)




----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)