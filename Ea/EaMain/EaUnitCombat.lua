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

local BUILDING_INTERNMENT_CAMP =					GameInfoTypes.BUILDING_INTERNMENT_CAMP
local DOMAIN_LAND =									DomainTypes.DOMAIN_LAND
local EACIV_GAZIYA =								GameInfoTypes.EACIV_GAZIYA
local EARACE_MAN =									GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =								GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =							GameInfoTypes.EARACE_HELDEOFOL
local EA_WONDER_ARCANE_TOWER =						GameInfoTypes.EA_WONDER_ARCANE_TOWER
local INVISIBLE_SUBMARINE =							GameInfoTypes.INVISIBLE_SUBMARINE
local POLICY_SLAVERY =								GameInfoTypes.POLICY_SLAVERY
local PROMOTION_FOR_HIRE =							GameInfoTypes.PROMOTION_FOR_HIRE
local PROMOTION_MERCENARY =							GameInfoTypes.PROMOTION_MERCENARY
local PROMOTION_SLAVE =								GameInfoTypes.PROMOTION_SLAVE
local PROMOTION_SLAVERAIDER =						GameInfoTypes.PROMOTION_SLAVERAIDER
local PROMOTION_SLAVEMAKER =						GameInfoTypes.PROMOTION_SLAVEMAKER
local PROMOTION_STUNNED =							GameInfoTypes.PROMOTION_STUNNED
local UNIT_LICH =									GameInfoTypes.UNIT_LICH
local UNIT_SLAVES_MAN =								GameInfoTypes.UNIT_SLAVES_MAN
local UNIT_SLAVES_SIDHE =							GameInfoTypes.UNIT_SLAVES_SIDHE
local UNIT_SLAVES_ORC =								GameInfoTypes.UNIT_SLAVES_ORC
local UNIT_WORKERS_MAN =							GameInfoTypes.UNIT_WORKERS_MAN
local UNIT_WORKERS_SIDHE =							GameInfoTypes.UNIT_WORKERS_SIDHE
local UNIT_WORKERS_ORC =							GameInfoTypes.UNIT_WORKERS_ORC

--localized tables
local MapModData =					MapModData
local gPlayers =					gPlayers
local gPeople =						gPeople
local Players =						Players
local fullCivs =					MapModData.fullCivs
local gg_bNormalLivingCombatUnit =	gg_bNormalLivingCombatUnit
local gg_slaveryPlayer =			gg_slaveryPlayer
local gg_gpTempType =				gg_gpTempType
local gg_eaSpecial =				gg_eaSpecial

--localized functions
local HandleError =					HandleError
local HandleError10 =				HandleError10
local HandleError21 =				HandleError21
local HandleError31 =				HandleError31
local Floor =						math.floor
local Rand =						Map.Rand


--file control
local g_bInitialized = false
local g_iActivePlayer = Game.GetActivePlayer()
local g_delayedAttacks = {pos = 0}
local g_iDefendingPlayer = -1
local g_iDefendingUnit = -1
local g_iAttackingPlayer = -1
local g_iAttackingUnit = -1
local g_defendingUnitTypeID = -1
local g_defendingUnitXP = -1

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------
local nonTransferablePromos = {}
local numNonTransferablePromos = 0
for promoInfo in GameInfo.UnitPromotions() do
	if promoInfo.EaNonTransferable then
		numNonTransferablePromos = numNonTransferablePromos + 1
		nonTransferablePromos[numNonTransferablePromos] = promoInfo.ID
	end
end

local dummyUnit = {}
local eaSpecialUnit = {}
for unitInfo in GameInfo.Units() do
	if string.find(unitInfo.Type, "UNIT_DUMMY_") == 1 then
		dummyUnit[unitInfo.ID] = true
	end
	if unitInfo.EaSpecial then
		eaSpecialUnit[unitInfo.ID] = unitInfo.EaSpecial
	end
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------
function EaUnitCombatInit(bNewGame)
	g_bInitialized = true
end

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function CalculateXPManaForAttack(unitTypeId, damage, bKill)
	local basePower = gg_normalizedUnitPower[unitTypeId] or 18			--city treated as unit with power 18
	return Floor((damage + (bKill and 50 or 0)) * basePower / 18)		-- 1 pt per 2 hp for a Warriors unit; kill is worth an additional 33 hp
end



--------------------------------------------------------------
-- Events DEPRECIATE!
--------------------------------------------------------------

--TO DO: Depreciate Events hook below. Replace with new GameEvents.

local function OnSerialEventUnitCreated(iPlayer, iUnit, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	Dprint("Running SerialEventUnitCreated ", iPlayer, iUnit, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	--WARNINGS:
	--unitType is not unitTypeID
	--runs for embark, disembark
	
	if not g_bInitialized then return end
	local player = Players[iPlayer]
	local unit = player:GetUnitByID(iUnit)
	if not unit then return end
	Dprint("Actual unitTypeID = ", unit:GetUnitType())

	if iPlayer == BARB_PLAYER_INDEX then	--includes new spawns and captured slaves
		if unit:IsGreatPerson() then
			error("Barb captured a GP?!")
		end

		--convert to slaves if spawned in or adjacent to border (i.e., rebels) and city has an internment camp
		local plot = unit:GetPlot()
		local city = plot:GetWorkingCity()
		if not city then
			for x, y in PlotToRadiusIterator(plot:GetX(), plot:GetY(), 1) do
				city = Map.GetPlot(x, y):GetWorkingCity()
				if city then break end
			end
		end
		if city and city:GetNumBuilding(BUILDING_INTERNMENT_CAMP) == 1 then
			local plot = unit:GetPlot()
			MapModData.bBypassOnCanSaveUnit = true
			unit:Kill(true, -1)
			local raceID = GetCityRace(city)		--TO DO: make these unit race, not city race
			local unitID
			if raceID == EARACE_MAN then
				unitID = UNIT_SLAVES_MAN
			elseif raceID == EARACE_SIDHE then
				unitID = UNIT_SLAVES_SIDHE
			else 
				unitID = UNIT_SLAVES_ORC
			end
			local newUnit = player:InitUnit(unitID, plot:GetX(), plot:GetY() )
			newUnit:JumpToNearestValidPlot()
			newUnit:SetHasPromotion(PROMOTION_SLAVE, true)
		end
	end
end
Events.SerialEventUnitCreated.Add(function(iPlayer, iUnit, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible) return HandleError(OnSerialEventUnitCreated, iPlayer, iUnit, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible) end)

--------------------------------------------------------------
-- Combat GameEvents and supporting local functions
--------------------------------------------------------------

local function OnUnitCaptured(iPlayer, iUnit)
	local player = Players[iPlayer]
	local unit = player:GetUnitByID(iUnit)
	local unitTypeID = unit:GetUnitType()
	print("OnUnitCaptured ", iPlayer, iUnit, GameInfo.Units[unitTypeID].Type)
	if unit:IsCombatUnit() then
		if unit:GetDomainType() == DOMAIN_LAND then	--must be captured land combat unit (only Slave Maker can do this)
			print("Captured combat land unit")
			unit:SetHasPromotion(PROMOTION_FOR_HIRE , false)
			unit:SetHasPromotion(PROMOTION_MERCENARY , false)
			unit:SetHasPromotion(PROMOTION_SLAVE, true)
			unit:SetMorale(-30)
		end
		for i = 1, numNonTransferablePromos do
			unit:SetHasPromotion(nonTransferablePromos[i] , false)
		end
	else	--civilian
		local iOriginalOwner = unit:GetOriginalOwner()
		if iOriginalOwner == iPlayer then
			print("Recaptured a civilian")
		elseif gg_slaveryPlayer[iPlayer] then
			print("Slavery civ captured a civilian")
		elseif player:IsHuman() then	
			local originalOwner = Players[iOriginalOwner]
			if not originalOwner:IsAlive() or Teams[player:GetTeam()]:IsAtWar(originalOwner:GetTeam()) then
				print("Non-Slavery human player captured a civilian that can't be returned to original owner; killing")
				MapModData.bBypassOnCanSaveUnit = true
				unit:Kill(true, -1)
				return
			else
				print("Non-Slavery human player captured a civilian; ReturnCivilianPopup will kill unit if not returned")
				return
			end				
		else
			print("Non-Slavery computer player captured a civilian that wasn't returned; killing")
			MapModData.bBypassOnCanSaveUnit = true
			unit:Kill(true, -1)
			return
		end
		--get slave promo to proper state
		if unitTypeID == UNIT_SLAVES_MAN or unitTypeID == UNIT_SLAVES_SIDHE or unitTypeID == UNIT_SLAVES_ORC then
			unit:SetHasPromotion(PROMOTION_SLAVE, true)
		else
			unit:SetHasPromotion(PROMOTION_SLAVE, false)
		end
	end
end
GameEvents.UnitCaptured.Add(function(iPlayer, iUnit) return HandleError21(OnUnitCaptured, iPlayer, iUnit) end)

--Forced interface mode: The Active player must do some something specific (e.g., use Magic Missile) or drop this interface mode and reset unit
local function ResetForcedSelectionUnit()		--resets temp attack unit if player fiddles around rather than attacking
	print("ResetForcedSelectionUnit")
	local iUnit = MapModData.forcedUnitSelection
	local player = Players[g_iActivePlayer]
	local unit = player:GetUnitByID(iUnit)
	MapModData.forcedUnitSelection = -1
	MapModData.forcedInterfaceMode = -1
	if unit then
		local unitTypeID = unit:GetUnitType()
		if gg_gpTempType[unitTypeID] then						--was Magic Missile unit or something similar
			local iPerson = unit:GetPersonIndex()
			local eaPerson = gPeople[iPerson]
			local restoredUnitTypeID = eaPerson.unitTypeID
			local restoredUnit = player:InitUnit(restoredUnitTypeID, unit:GetX(), unit:GetY(), nil, unit:GetFacingDirection())
			MapModData.bBypassOnCanSaveUnit = true
			restoredUnit:Convert(unit, false)
			restoredUnit:SetPersonIndex(iPerson)
			local iRestoredUnit = restoredUnit:GetID()
			eaPerson.iUnit = iRestoredUnit
			restoredUnit:SetMorale(0)
			restoredUnit:SetInvisibleType(INVISIBLE_SUBMARINE)
		elseif unit:GetGPAttackState() == 1 then				--was a Warrior Lead Charge
			unit:SetGPAttackState(0)
			unit:SetInvisibleType(INVISIBLE_SUBMARINE)
		end
	end

end
LuaEvents.EaUnitCombatResetForcedSelectionUnit.Add(function() return HandleError10(ResetForcedSelectionUnit) end)

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
local g_bStart = false
local g_tickStart = 0
function TimeDelayForHumanMeleeCharge(tickCount, timeIncrement)		--DON'T LOCALIZE! Causes CTD with RemoveAll
	if g_bStart then
		if MELEE_ATTACK_AFTER_THOUSANDTHS_SECONDS < tickCount - g_tickStart then
			Events.LocalMachineAppUpdate.RemoveAll()	--also removes tutorial checks (good riddence!)
			print("TimeDelayForHumanMeleeCharge; delay in sec/1000 = ", tickCount - g_tickStart)
			print("os.clock() / tickCount : ", os.clock(), tickCount)
			DoDelayedAttacks(Game.GetActivePlayer())
		end
	else
		g_tickStart = tickCount
		g_bStart = true
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
				plot:AddFloatUpMessage(floatUp, 1)
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

local function UpdateWarriorPoints(iPlayer, bCombat, bBlockWarriorPts)
	print("UpdateWarriorPoints ", iPlayer, bCombat, bBlockWarriorPts)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local oldPoints = eaPlayer.classPoints[5]
	local newPoints = player:GetLifetimeCombatExperience() - gg_combatPointDiff[iPlayer]
	print("GetLifetimeCombatExperience= ", player:GetLifetimeCombatExperience())
	if bBlockWarriorPts then
		gg_combatPointDiff[iPlayer] = oldPoints - newPoints
		newPoints = oldPoints
	elseif bCombat and oldPoints == newPoints then		--must have been barb so add 1 point
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

	g_defendingUnitTypeID = -1
	g_defendingUnitXP = -1
	if defenderMaxHP == 200	then	--city; TO DO: get hp from Defines
		--TO DO: get city race
		gg_defendingCityRace = EARACE_MAN		--use this in city conquest event for slaves
	else
		local defendingUnit = defendingPlayer:GetUnitByID(iDefendingUnit)	
		if defendingUnit then
			g_defendingUnitTypeID = defendingUnit:GetUnitType()
			g_defendingUnitXP = defendingUnit:GetExperience()

			--TO DO: Get race from cached table
			g_defendingUnitRace = EARACE_MAN
		end
	end

	if fullCivs[iAttackingPlayer] then	--if full civ then do various functions
		if attackingUnit then
			if attackingUnit:IsGreatPerson() then
				local attackState = attackingUnit:GetGPAttackState()
				if attackState == 1 then					--This is a Warrior Lead Charge
					local bKill = defenderMaxHP <= defenderFinalDamage
					local pts = CalculateXPManaForAttack(g_defendingUnitTypeID, defenderDamage, bKill)
					attackingUnit:ChangeExperience(pts)
					WarriorLeadCharge(iAttackingPlayer, attackingUnit, targetX, targetY)
				elseif attackState == 2 then
					--Callenge; not yet implemented
				end
			end
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
			
			local attackingUnitTypeID = attackingUnit:GetUnitType()
			if gg_gpTempType[attackingUnitTypeID] then					--was a special GP attack (e.g., Magic Missile)
				local bEnergyDrain = gg_gpTempType[attackingUnitTypeID] == "EnergyDrain"
				local bStunChance = gg_gpTempType[attackingUnitTypeID] == "PlasmaBurst"
				local iPerson = attackingUnit:GetPersonIndex()
				local eaPerson = gPeople[iPerson]
				if not eaPerson.autoAttack then
					local restoredUnitTypeID = eaPerson.unitTypeID
					local restoredUnit = attackingPlayer:InitUnit(restoredUnitTypeID, attackingUnit:GetX(), attackingUnit:GetY(), nil, attackingUnit:GetFacingDirection())
					MapModData.bBypassOnCanSaveUnit = true		--yikes!!! Check that this is OK if combat kill happens
					restoredUnit:Convert(attackingUnit, false)
					UI.SelectUnit(restoredUnit)
					restoredUnit:SetPersonIndex(iPerson)
					local iRestoredUnit = restoredUnit:GetID()
					eaPerson.iUnit = iRestoredUnit
					restoredUnit:SetMorale(0)
				end
				local bDefenderKilled = (g_defendingUnitTypeID ~= -1) and (not defendingUnit or defendingUnit:IsDelayedDeath())
				local pts
				if bEnergyDrain and -1 < g_defendingUnitXP then
					local mod = GetGPMod(iPerson, "EAMOD_NECROMANCY", nil)
					print("Death Ray attack: mod, power, xp = ", mod, gg_baseUnitPower[g_defendingUnitTypeID], g_defendingUnitXP)
					if defendingUnit and not bDefenderKilled then
						local xpDrain = g_defendingUnitXP < mod and g_defendingUnitXP or mod
						if 0 < xpDrain then
							DrainExperience(defendingUnit, xpDrain)
							defendingUnit:GetPlot():AddFloatUpMessage(xpDrain .. " experience was drained!", 2)
						end
						local doDamage = mod - xpDrain
						if 0 < doDamage then
							local remainingHP = defenderMaxHP - defenderFinalDamage
							doDamage = doDamage < remainingHP and doDamage or remainingHP
							defendingUnit:GetPlot():AddFloatUpMessage(doDamage .. " hit points were drained!", 3)
							defendingUnit:ChangeDamage(doDamage, iAttackingPlayer)
						end
						pts = xpDrain + doDamage
					else
						pts = 5		--killed by ranged strength 1 attack?
					end
				else
					pts = CalculateXPManaForAttack(g_defendingUnitTypeID, defenderDamage, bDefenderKilled)
					if bStunChance and defendingUnit and not bDefenderKilled then
						local mod = GetGPMod(iPerson, "EAMOD_EVOCATION", nil)
						local power = gg_baseUnitPower[g_defendingUnitTypeID]
						print("Plasma Bolt attack: mod, power, xp = ", mod, power, g_defendingUnitXP)
						power = power < g_defendingUnitXP and g_defendingUnitXP or power
						local bStun = mod >= power
						if not bStun then
							if Floor(power, "hello") < mod then
								bStun = true
							end
						end
						if bStun then
							defendingUnit:SetHasPromotion(PROMOTION_STUNNED, true)
							defendingUnit:GetPlot():AddFloatUpMessage("Stunned!", 2)
							pts = pts + 10
						end
					end
				end
				UseManaOrDivineFavor(iAttackingPlayer, iPerson, pts)
				--restoredUnit:SetInvisibleType(INVISIBLE_SUBMARINE)
			elseif dummyUnit[attackingUnitTypeID] then
				UpdateWarriorPoints(iAttackingPlayer, false, true)	
			else
				UpdateWarriorPoints(iAttackingPlayer, true)		--attacker Warrior points
				if defenderMaxHP < defenderFinalDamage and defenderMaxHP == 100 then					--must have been a unit kill
					if attackingUnit:IsHasPromotion(PROMOTION_SLAVERAIDER) then
						--50% base chance to generate slave
						local chance = 50
						local eaPlayer = gPlayers[iAttackingPlayer]
						if eaPlayer.eaCivNameID == EACIV_GAZIYA then
							chance = 67
						end
						if Rand(100, "hello") < chance then
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
		end
	end
	--archer city conquest test
	if iAttackingUnitDamage == 0 and attackingUnit and iAttackingPlayer < BARB_PLAYER_INDEX and not defendingUnit and defenderMaxHP - 1 <= defenderFinalDamage and defenderMaxHP == 200 and not gg_gpTempType[attackingUnitTypeID] then	--archer defeated city
		local plot = GetPlotFromXY(plotX, plotY)
		local city = plot:GetPlotCity()
		if city and city:GetDamage() >= MAX_CITY_HIT_POINTS - 1 then
			print("Detected archer attack with adjacent 1 hp enemy city; teleporting archer to city plot")
			attackingUnit:SetXY(plotX, plotY)			--conquers city!
		end
	end

	if fullCivs[iDefendingPlayer] and defendingUnit then	--defender Warrior points
		if dummyUnit[attackingUnitTypeID] then
			UpdateWarriorPoints(iDefendingPlayer, false, true)
		else
			UpdateWarriorPoints(iDefendingPlayer, true)
		end
	end

end
GameEvents.CombatEnded.Add(function(iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP, iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, plotX, plotY) return HandleError(OnCombatEnded, iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP, iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, plotX, plotY) end)

local function OnCanSaveUnit(iPlayer, iUnit, bDelay)	--fires for combat and non-combat death (disband, settler settled, etc)
	--Uses and resets file locals set in OnCombatResult above; always fires after that function if this is a combat death
	--Note that file locals could be anything if this is not a combat death
	--Note: Fires twice for delayed death!
	print("OnCanSaveUnit ", iPlayer, iUnit, bDelay)

	local unit, player

	--cleanup for summoned unit (ok to fire twice)
	if fullCivs[iPlayer] then
		player = Players[iPlayer]
		unit = player:GetUnitByID(iUnit)
		
		local iSummoner = unit:GetSummonerIndex()
		if iSummoner ~= -1 then
			local eaSummoner = gPeople[iSummoner]
			if eaSummoner then			--nil if dead or this is an unbound summoned (-99)
				local summonedUnits = eaSummoner.summonedUnits
				if summonedUnits then
					summonedUnits[iUnit] = nil
				end
			end
			local unitTypeID = unit:GetUnitType()
			if eaSpecialUnit[unitTypeID] then
				if eaSpecialUnit[unitTypeID] == "Archdemon" then
					if gg_summonedArchdemon[iPlayer] == unitTypeID then
						gg_summonedArchdemon[iPlayer] = nil			--opens it up so they can summon another
					end
				elseif eaSpecialUnit[unitTypeID] == "Archangel" then
					if gg_calledArchangel[iPlayer] == unitTypeID then
						gg_calledArchangel[iPlayer] = nil
					end
				elseif eaSpecialUnit[unitTypeID] == "MajorSpirit" then
					if gg_calledMajorSpirit[iPlayer] == unitTypeID then
						gg_calledMajorSpirit[iPlayer] = nil
					end
				end
			end
		end
	end

	--for everything below, we only want first call for delayed death
	if not bDelay then return false end		-- too late now!

	if MapModData.bBypassOnCanSaveUnit then
		MapModData.bBypassOnCanSaveUnit = false
		g_iDefendingPlayer, g_iDefendingUnit, g_iAttackingPlayer, g_iAttackingUnit = -1, -1, -1, -1
		return false
	end

	player = player or Players[iPlayer]	
	unit = unit or player:GetUnitByID(iUnit)
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

		if unit:GetUnitType() == UNIT_LICH and gWonders[EA_WONDER_ARCANE_TOWER][iPerson] then
			SaveLich(unit)
			return true
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

			if unit:GetUnitType() == UNIT_LICH and gWonders[EA_WONDER_ARCANE_TOWER][iPerson] then
				SaveLich(unit)
				return true
			end

			KillPerson(iPlayer, iPerson, nil, nil, "Killed by GP layer unit")
			g_iDefendingPlayer, g_iDefendingUnit, g_iAttackingPlayer, g_iAttackingUnit = -1, -1, -1, -1
			return false
		end
	end

	g_iDefendingPlayer, g_iDefendingUnit, g_iAttackingPlayer, g_iAttackingUnit = -1, -1, -1, -1

	print("Trying to save GP")
	local currentPlot = unit:GetPlot()
	local sector = Map.Rand(6, "hello") + 1
	for testPlot in PlotAreaSpiralIterator(currentPlot, 15, sector, false, false, false) do
		if player:GetPlotDanger(testPlot) == 0 then								--is this plot out of danger?
			if unit:TurnsToReachTarget(testPlot, 1, 1, 1) < 100 then		--is this plot accessible?
				unit:SetXY(testPlot:GetX(), testPlot:GetY())
				unit:SetEmbarked(testPlot:IsWater())
				testPlot:AddFloatUpMessage("Great Person has escaped!", 1)		--TO DO: txt key
				print("Great Person has escaped!")
				return true
			end
		end
	end
	print("!!!! WARNING: Could not find safe accessible plot for GP to escape to; GP will die!")

	if unit:GetUnitType() == UNIT_LICH and gWonders[EA_WONDER_ARCANE_TOWER][iPerson] then
		SaveLich(unit)
		return true
	end

	KillPerson(iPlayer, iPerson, nil, nil, "Failed to save GP")
	return false

end
GameEvents.CanSaveUnit.Add(function(iPlayer, iUnit, bDelay) return HandleError31(OnCanSaveUnit, iPlayer, iUnit, bDelay) end)

function SaveLich(unit)
	local iPlayer = unit:GetOwner()
	local iPerson = unit:GetPersonIndex()
	local iPlot = gWonders[EA_WONDER_ARCANE_TOWER][iPerson].iPlot
	local x, y = GetXYFromPlotIndex(iPlot)
	--TO DO: need to make Lich "dormant" if tower in ruins

	unit:SetXY(x, y)
	if unit:GetPlot():GetOwner() ~= iPlayer then
		unit:JumpToNearestValidPlot()		--only kicks out of tower, but the idea is clear
	end

	UseManaOrDivineFavor(iPlayer, iPerson, unit:GetLevel() * 10)
end


local function OnCanChangeExperience(iPlayer, iUnit, iSummoner, iExperience, iMax, bFromCombat, bInBorders, bUpdateGlobal)
	print("OnCanChangeExperience ", iPlayer, iUnit, iSummoner, iExperience, iMax, bFromCombat, bInBorders, bUpdateGlobal)
	if iSummoner ~= -1 then
		--iSummoner is iPerson belonging to iPlayer
		UseManaOrDivineFavor(iPlayer, iSummoner, iExperience, false)
		local unit = Players[iPlayer]:GetUnitByID(iUnit)
		local unitTypeID = unit:GetUnitType()
		if gg_eaSpecial[unitTypeID] == "Undead" then
			return false
		end
	end
	return true
end
GameEvents.CanChangeExperience.Add(function (iPlayer, iUnit, iSummoner, iExperience, iMax, bFromCombat, bInBorders, bUpdateGlobal) return HandleError(OnCanChangeExperience, iPlayer, iUnit, iSummoner, iExperience, iMax, bFromCombat, bInBorders, bUpdateGlobal) end)

local function OnBarbExperienceDenied(iPlayer, iUnit, iSummoner, iExperience)
	print("OnBarbExperienceDenied ", iPlayer, iUnit, iSummoner, iExperience)
	if iSummoner ~= -1 then
		--iSummoner is iPlayer (used to credit mana drain)
		UseManaOrDivineFavor(iSummoner, nil, iExperience, true)
	end
end
GameEvents.BarbExperienceDenied.Add(function (iPlayer, iUnit, iSummoner, iExperience) return HandleError41(OnBarbExperienceDenied, iPlayer, iUnit, iSummoner, iExperience) end)




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