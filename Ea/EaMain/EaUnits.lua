-- EaUnits
-- Author: Pazyryk
-- DateCreated: 6/28/2012 10:24:38 AM
--------------------------------------------------------------

print("Loading EaUnits.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

--constants
local BARB_PLAYER_INDEX =								BARB_PLAYER_INDEX
local HIGHEST_PROMOTION_ID =						HIGHEST_PROMOTION_ID

local MAX_CITY_HIT_POINTS =							GameDefines.MAX_CITY_HIT_POINTS

local DOMAIN_LAND =									DomainTypes.DOMAIN_LAND
local DOMAIN_SEA =									DomainTypes.DOMAIN_SEA

local BUILDING_INTERNMENT_CAMP =					GameInfoTypes.BUILDING_INTERNMENT_CAMP

local EAMOD_DEVOTION =								GameInfoTypes.EAMOD_DEVOTION
local EAMOD_CONJURATION =							GameInfoTypes.EAMOD_CONJURATION
local EAMOD_EVOCATION =								GameInfoTypes.EAMOD_EVOCATION
local EAMOD_ABJURATION =							GameInfoTypes.EAMOD_ABJURATION
local EAMOD_TRANSMUTATION =							GameInfoTypes.EAMOD_TRANSMUTATION




local EARACE_MAN =									GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =								GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =							GameInfoTypes.EARACE_HELDEOFOL
local EACIV_IKKOS = 								GameInfoTypes.EACIV_IKKOS
local EACIV_HIPPUS = 								GameInfoTypes.EACIV_HIPPUS
local EACIV_FOMHOIRE =								GameInfoTypes.EACIV_FOMHOIRE
local EA_WONDER_THE_LONG_WALL =						GameInfoTypes.EA_WONDER_THE_LONG_WALL
local IMPROVEMENT_FISHING_BOATS =					GameInfoTypes.IMPROVEMENT_FISHING_BOATS
local IMPROVEMENT_WHALING_BOATS =					GameInfoTypes.IMPROVEMENT_WHALING_BOATS
local IMPROVEMENT_CAMP =							GameInfoTypes.IMPROVEMENT_CAMP
local MINOR_TRAIT_MERCENARY =						GameInfoTypes.MINOR_TRAIT_MERCENARY
local POLICY_PANTHEISM =							GameInfoTypes.POLICY_PANTHEISM
local POLICY_SLAVERY =								GameInfoTypes.POLICY_SLAVERY
local POLICY_WARSPIRIT =							GameInfoTypes.POLICY_WARSPIRIT
local POLICY_BERSERKER_RAGE =						GameInfoTypes.POLICY_BERSERKER_RAGE
local POLICY_MILITARISM_FINISHER =					GameInfoTypes.POLICY_MILITARISM_FINISHER
local PROMOTION_LEARN_SPELL =						GameInfoTypes.PROMOTION_LEARN_SPELL
local PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY =	GameInfoTypes.PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY
local PROMOTION_OCEAN_IMPASSABLE =					GameInfoTypes.PROMOTION_OCEAN_IMPASSABLE
local PROMOTION_SLAVE =								GameInfoTypes.PROMOTION_SLAVE
local PROMOTION_SLAVERAIDER =						GameInfoTypes.PROMOTION_SLAVERAIDER
local PROMOTION_SLAVEMAKER =						GameInfoTypes.PROMOTION_SLAVEMAKER
local PROMOTION_FOR_HIRE =							GameInfoTypes.PROMOTION_FOR_HIRE
local PROMOTION_MERCENARY =							GameInfoTypes.PROMOTION_MERCENARY
local PROMOTION_STRONG_MERCENARY_INACTIVE =			GameInfoTypes.PROMOTION_STRONG_MERCENARY_INACTIVE
local PROMOTION_STRONG_MERCENARY =					GameInfoTypes.PROMOTION_STRONG_MERCENARY
local PROMOTION_EXTENDED_RANGE =					GameInfoTypes.PROMOTION_EXTENDED_RANGE
local PROMOTION_DRUNKARD =							GameInfoTypes.PROMOTION_DRUNKARD
local PROMOTION_STALLIONS_OF_EPONA =				GameInfoTypes.PROMOTION_STALLIONS_OF_EPONA
local RELIGION_CULT_OF_EPONA =						GameInfoTypes.RELIGION_CULT_OF_EPONA


local RESOURCE_CITRUS =								GameInfoTypes.RESOURCE_CITRUS
local UNITCOMBAT_MOUNTED = 							GameInfoTypes.UNITCOMBAT_MOUNTED
local UNITCOMBAT_NAVAL =							GameInfoTypes.UNITCOMBAT_NAVAL
local UNIT_FISHING_BOATS =							GameInfoTypes.UNIT_FISHING_BOATS
local UNIT_WHALING_BOATS =							GameInfoTypes.UNIT_WHALING_BOATS
local UNIT_HUNTERS =								GameInfoTypes.UNIT_HUNTERS
local UNIT_SLAVES_MAN =								GameInfoTypes.UNIT_SLAVES_MAN
local UNIT_SLAVES_SIDHE =							GameInfoTypes.UNIT_SLAVES_SIDHE
local UNIT_SLAVES_ORC =								GameInfoTypes.UNIT_SLAVES_ORC
local UNIT_GREAT_BOMBARDE =							GameInfoTypes.UNIT_GREAT_BOMBARDE



--state shared
--local unitMorale = MapModData.unitMorale

--localized game and global tables
local gWorld =						gWorld
local gPlayers =					gPlayers
local gWonders =					gWonders
local gReligions =					gReligions
local gPeople =						gPeople

local Players =						Players
local Teams =						Teams
local MapModData =					MapModData
local playerType =					MapModData.playerType
local bFullCivAI =					MapModData.bFullCivAI
local bHidden =						MapModData.bHidden
local realCivs =					MapModData.realCivs
local fullCivs =					MapModData.fullCivs
local cityStates =					MapModData.cityStates
local gg_combatPointDiff =			gg_combatPointDiff
local gg_unitPrefixUnitIDs =		gg_unitPrefixUnitIDs
--local gg_gpAttackUnits =			gg_gpAttackUnits
--local gg_gpAttackUnitsRemovedUnit =		gg_gpAttackUnitsRemovedUnit


local gg_cityLakesDistMatrix =		gg_cityLakesDistMatrix
local gg_cityFishingDistMatrix =	gg_cityFishingDistMatrix
local gg_cityWhalingDistMatrix =	gg_cityWhalingDistMatrix
local gg_cityCampResDistMatrix =	gg_cityCampResDistMatrix
local gg_fishingRange =				gg_fishingRange
local gg_whalingRange =				gg_whalingRange
local gg_campRange =				gg_campRange

--localized functions
local Rand = Map.Rand
local Floor = math.floor
local Distance = Map.PlotDistance
local StrSubstitute = string.gsub
local GetPlotFromXY =			Map.GetPlot
local PlotToRadiusIterator =	PlotToRadiusIterator
local HandleError31 =			HandleError31

--file functions
local RemoveOwnedFishingResourcePlot
local RemoveOwnedWhalePlot
local RemoveOwnedLakePlot
local RemoveOwnedCampPlot
local UseUnit = {}
local UseAIUnit = {}
local SustainedPromotionDo = {}		--Function holder for sustained promotions (run each turn for each unit with promo)

--file control
local g_iActivePlayer = Game.GetActivePlayer()
local g_delayedAttacks = {pos = 0}
local g_iDefendingPlayer = -1
local g_iDefendingUnit = -1
local g_iAttackingPlayer = -1
local g_iAttackingUnit = -1

local integers = {}
local bInitialized = false

---------------------------------------------------------------
-- Cached Tables
---------------------------------------------------------------
local bNormalCombatUnit = {}
local bNormalLivingCombatUnit = {}
local eaGPCombatRoleByID = {}
for unitInfo in GameInfo.Units() do
	if unitInfo.EaGPCombatRole then
		eaGPCombatRoleByID[unitInfo.ID] = unitInfo.EaGPCombatRole
	elseif unitInfo.CombatLimit == 100 then
		bNormalCombatUnit[unitInfo.ID] = true
		if unitInfo.EaLiving then
			bNormalLivingCombatUnit[unitInfo.ID] = true
		end
	end
end

local nonTransferablePromos = {}
local numNonTransferablePromos = 0
for promoInfo in GameInfo.UnitPromotions() do
	if promoInfo.EaNonTransferable then
		numNonTransferablePromos = numNonTransferablePromos + 1
		nonTransferablePromos[numNonTransferablePromos] = promoInfo.ID
	end
end

local bHorseMounted = {}	--mounted including archer types (but no chariots)
for row in GameInfo.Unit_ResourceQuantityRequirements() do
	if row.ResourceType == "RESOURCE_HORSE" then
		local unitTypeID = GameInfoTypes[row.UnitType]
		local unitInfo = GameInfo.Units[unitTypeID]
		if not unitInfo.Mechanized then
			bHorseMounted[unitTypeID] = true
		end
	end
end

local bAnimal = {}
for unitInfo in GameInfo.Units() do
	if unitInfo.EaAnimal then
		bAnimal[unitInfo.ID] = true
	end
end

--Store promotions that have levels (i.e., any that end with "_" then digits)
function GetPromoPrefixLevelFromType(promoType)
	local suffixStart, suffixEnd = string.find(promoType, "_%d+$")	--match _digits only at end of string
	if suffixStart then
		local prefix = string.sub(promoType, 1, suffixStart - 1)
		local level = tonumber(string.sub(promoType, suffixStart + 1, suffixEnd))
		return prefix, level
	end
end


local promotionLevels = {}		--promotionLevels[prefixStr][level] = ID; promotionLevels[prefixStr][0] = numLevels
for promotion in GameInfo.UnitPromotions() do
	local prefix, level = GetPromoPrefixLevelFromType(promotion.Type)
	if prefix then
		promotionLevels[prefix] = promotionLevels[prefix] or {}
		promotionLevels[prefix][level] = promotion.ID
	end
end
for _, levels in pairs(promotionLevels) do
	local maxLevel = 0
	for level, id in pairs(levels) do
		if level > maxLevel then maxLevel = level end
	end
	levels.max = maxLevel
end



--------------------------------------------------------------
-- Init
--------------------------------------------------------------
function EaUnitsInit(bNewGame)
	print("Running EaUnitsInit...")
	if bNewGame then
		--Fix race for extra AI units placed for high difficulty (dll seems to grab first melee and recon, which are man) 
		for iPlayer, eaPlayer in pairs(fullCivs) do
			if eaPlayer.race == EARACE_SIDHE then
				local player = Players[iPlayer]
				for unit in player:Units() do
					local unitTypeID = unit:GetUnitType()
					local newUnitTypeID
					if unitTypeID == GameInfoTypes.UNIT_WARRIORS_MAN then
						newUnitTypeID = GameInfoTypes.UNIT_WARRIORS_SIDHE
					elseif unitTypeID == GameInfoTypes.UNIT_SCOUTS_MAN then
						newUnitTypeID = GameInfoTypes.UNIT_SCOUTS_SIDHE
					elseif unitTypeID == GameInfoTypes.UNIT_WORKERS_MAN then
						newUnitTypeID = GameInfoTypes.UNIT_WORKERS_SIDHE
					end
					if newUnitTypeID then
						local newUnit = player:InitUnit(newUnitTypeID, unit:GetX(), unit:GetY())
						newUnit:Convert(unit)
					end
				end
			elseif eaPlayer.race == EARACE_HELDEOFOL then
				local player = Players[iPlayer]
				for unit in player:Units() do
					local unitTypeID = unit:GetUnitType()
					local newUnitTypeID
					if unitTypeID == GameInfoTypes.UNIT_WARRIORS_MAN then
						newUnitTypeID = GameInfoTypes.UNIT_WARRIORS_ORC
					elseif unitTypeID == GameInfoTypes.UNIT_SCOUTS_MAN then
						newUnitTypeID = GameInfoTypes.UNIT_SCOUTS_ORC
					elseif unitTypeID == GameInfoTypes.UNIT_WORKERS_MAN then
						newUnitTypeID = GameInfoTypes.UNIT_WORKERS_ORC
					end
					if newUnitTypeID then
						local newUnit = player:InitUnit(newUnitTypeID, unit:GetX(), unit:GetY())
						newUnit:Convert(unit)
					end
				end
			end
		end
	end

	for iPlayer, eaPlayer in pairs(realCivs) do
		if playerType[iPlayer] == "FullCiv" then
			local player = Players[iPlayer]
			gg_combatPointDiff[iPlayer] = player:GetLifetimeCombatExperience() - eaPlayer.classPoints[5]
		end
	end
	if not bNewGame then
		--clean up sustainedPromotions (may contain tables that are empty or point to non-existing units; these are harmless but no longer needed)
		for iPlayer, eaPlayer in pairs(gPlayers) do
			if not bHidden[iPlayer] then		--Full Civs, CSs and barbs
				local player = Players[iPlayer]
				local removeCount = 0
				for iUnit, unitSustainedPromotions in pairs(eaPlayer.sustainedPromotions) do
					local unit = player:GetUnitByID(iUnit)
					if not unit or next(unitSustainedPromotions) == nil then		--no unit or table is empty
						removeCount = removeCount + 1
						integers[removeCount] = iUnit
					end
				end
				for i = 1, removeCount do
					local iUnit = integers[i]
					eaPlayer.sustainedPromotions[iUnit] = nil
				end
			end
		end
	end
	bInitialized = true
end


--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function ConvertUnitsByMatch(iPlayer, fromStr, toStr)	--preserves race (e.g., UNIT_WORKERS_MAN to UNIT_SLAVES_MAN)
	local player = Players[iPlayer]
	local fromMatches = gg_unitPrefixUnitIDs[fromStr]
	local numFromMatches = #fromMatches
	for unit in player:Units() do
		local unitTypeID = unit:GetUnitType()
		local bConvert = false
		for i = 1, numFromMatches do
			if unitTypeID == fromMatches[i] then
				bConvert = true
				break
			end
		end
		if bConvert then
			local unitType = GameInfo.Units[unitTypeID].Type
			local newUnitType = StrSubstitute(unitType, fromStr, toStr)
			local newUnitTypeID = GameInfoTypes[newUnitType]
			local newUnit = player:InitUnit(newUnitTypeID, unit:GetX(), unit:GetY())
			newUnit:Convert(unit)
		end
	end
end

function HireMercenary(iPlayer, unit, upFront, gpt)
	print("Running HireMercenary ", iPlayer, unit, upFront, gpt)
	local player = Players[iPlayer]
	local unitTypeID = unit:GetUnitType()
	local iOriginalOwner = unit:GetOriginalOwner()
	local newUnit = player:InitUnit(unitTypeID, unit:GetX(), unit:GetY())
	if newUnit then
		newUnit:SetOriginalOwner(iOriginalOwner)
		local iNewUnit = newUnit:GetID()
		local mercenaries = gPlayers[iPlayer].mercenaries
		mercenaries[iOriginalOwner] = mercenaries[iOriginalOwner] or {}
		mercenaries[iOriginalOwner][iNewUnit] = gpt
		player:ChangeGold(-upFront)
		newUnit:Convert(unit)		--sets xp, level, promotions (but not original owner)
		newUnit:SetHasPromotion(PROMOTION_MERCENARY, true)
		newUnit:SetHasPromotion(PROMOTION_FOR_HIRE, false)
		if newUnit:IsHasPromotion(PROMOTION_STRONG_MERCENARY_INACTIVE) then
			newUnit:SetHasPromotion(PROMOTION_STRONG_MERCENARY_INACTIVE, false)
			newUnit:SetHasPromotion(PROMOTION_STRONG_MERCENARY, true)
		end
		newUnit:JumpToNearestValidPlot()
		newUnit:FinishMoves()
		--ChangeUnitMorale(iPlayer, iNewUnit, 0, true)
		newUnit:SetMorale(0)
		if iPlayer == g_iActivePlayer then
			UI.SelectUnit(newUnit)
			UI.LookAtSelectionPlot(0)
			local hex = ToHexFromGrid(Vector2(newUnit:GetX(), newUnit:GetY()))
			Events.GameplayFX(hex.x, hex.y, -1)
		end
	end
end
LuaEvents.EaUnitsHireMercenary.Add(HireMercenary)

function DismissMercenary(iPlayer, iUnit)
	print("Running DismissMercenary", iPlayer, iUnit)
	local player = Players[iPlayer]
	local unit = player:GetUnitByID(iUnit)
	if unit then
		local mercenaries = gPlayers[iPlayer].mercenaries
		local iOriginalOwner = unit:GetOriginalOwner()
		if mercenaries[iOriginalOwner] then
			mercenaries[iOriginalOwner][iUnit] = nil
			if next(mercenaries[iOriginalOwner]) == nil then
				mercenaries[iOriginalOwner] = nil
			end
		end

		local originalOwner = Players[iOriginalOwner]
		local bConverted = false
		if originalOwner and originalOwner:IsAlive() then
			local unitTypeID = unit:GetUnitType()
			local newUnit = originalOwner:InitUnit(unitTypeID, unit:GetX(), unit:GetY())
			if newUnit then
				print("Merc has been dismissed")				
				bConverted = true
				newUnit:Convert(unit)
				newUnit:SetHasPromotion(PROMOTION_MERCENARY, false)
				if newUnit:IsHasPromotion(PROMOTION_STRONG_MERCENARY) then
					newUnit:SetHasPromotion(PROMOTION_STRONG_MERCENARY, false)
					newUnit:SetHasPromotion(PROMOTION_STRONG_MERCENARY_INACTIVE, true)
				end
				newUnit:JumpToNearestValidPlot()
			else
				print("!!!! WARNING: Merc was dismissed but original civ did not get it back !!!!")
			end
		else
			print("Merc has been dismissed; original owner is no longer alive so unit destroyed")
		end
		if not bConverted then
			print("!!!! WARNING: Merc was dismissed and original owner exists, but unit could not be returned for some reason")
			unit:Kill(true, -1)	--unit:SetDamage(unit:GetMaxHitPoints())
		end
	end
end
LuaEvents.EaUnitsDismissMercenary.Add(DismissMercenary)

function UnitPerCivTurn(iPlayer)	--runs for full civs and city states
	print("UnitPerCivTurn")
	local Rand = Rand
	local Floor = Floor
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local team = Teams[player:GetTeam()]
	local bBarbs = iPlayer == BARB_PLAYER_INDEX
	local bAnimals = iPlayer == ANIMALS_PLAYER_INDEX
	local bFullCiv = fullCivs[iPlayer] ~= nil
	local bAI = bFullCivAI[iPlayer] or not bFullCiv
	local nameTraitID = bFullCiv and eaPlayer.eaCivNameID or -1
	--local bMercenaryCityState = not bFullCiv and player:GetMinorCivTrait() == MINOR_TRAIT_MERCENARY

	local playerHappiness = bFullCiv and player:GetExcessHappiness() or 0


	local sustainedPromotions = eaPlayer.sustainedPromotions
	local bHorseMountedXP = nameTraitID == EACIV_IKKOS
	local bHorseMountedStrongMerc = nameTraitID == EACIV_HIPPUS
	--local bRemoveOceanBlock = bFullCiv and eaPlayer.eaCivNameID == EACIV_FOMHOIRE

	local iLongWallOwner = gWonders[EA_WONDER_THE_LONG_WALL] and Map.GetPlotByIndex(gWonders[EA_WONDER_THE_LONG_WALL].iPlot):GetOwner()
	local bMayBeSlowedByLongWall = iLongWallOwner and team:IsAtWar(Players[iLongWallOwner]:GetTeam())
	local longWallMod = iLongWallOwner and gWonders[EA_WONDER_THE_LONG_WALL].mod
	local bNoCitrus = bFullCiv and player:GetNumResourceAvailable(RESOURCE_CITRUS, true) < 1
	local bHasWarspirit = bFullCiv and player:HasPolicy(POLICY_WARSPIRIT)
	local bHasBerserkerRage = bHasWarspirit and player:HasPolicy(POLICY_BERSERKER_RAGE) or false

	g_iDefendingPlayer = -1
	g_iDefendingUnit = -1
	g_iAttackingPlayer = -1
	g_iAttackingUnit = -1

	local countCombatUnits = 0
	for unit in player:Units() do
		local iUnit = unit:GetID()
		local plot = unit:GetPlot()
		local iPlotOwner = plot:GetOwner()
		local x, y, iPlot = plot:GetXYIndex()
		local unitTypeID = unit:GetUnitType()

		--Debug
		if unitTypeID == 0 then
			error("Found an ID=0 unit; most likely there was a player:UnitInit() with an invalid unitTypeID")
		end
		if unit:IsGreatPerson() then
			local iPerson = unit:GetPersonIndex()
			if not gPeople[iPerson] then
				print("!!!! WARNING: Found an orphan GP; iPlayer, unitTypeID, iPlot = " .. iPlayer .. ", " .. GameInfo.Units[unitTypeID].Type .. ", " .. iPlot)
				AttemptToReconectGP(nil, unit)
			end
		end
		
		if bAnimals then
			--
		elseif bBarbs then
			--
		else	--Full civs and city states
			local bSlave = unit:IsHasPromotion(PROMOTION_SLAVE)
			local bMercenary = unit:IsHasPromotion(PROMOTION_MERCENARY)

			if bNormalCombatUnit[unitTypeID] then
				countCombatUnits = countCombatUnits + 1
				--Temp Attack Morale
				--if eaPlayer.tempAttackMorale[iUnit] then
				--	RemoveTempAttackMorale(iPlayer, iUnit)
				--end

				--Morale decays toward baseline (= civ happiness; -30 for slaves; 0 for mercenary; -20 for merc at war with original owner)
				--local prevMorale = unitMorale[iPlayer][iUnit] or 0
				local baselineMoral = playerHappiness
				if bSlave then
					baselineMoral = -30
				else
					if bMercenary then
						if team:IsAtWar(Players[unit:GetOriginalOwner()]:GetTeam()) then	--TO DO: check that this is safe for killed civ
							baselineMoral = -20
						else
							baselineMoral = 0
						end
					elseif bHasWarspirit then
						baselineMoral = baselineMoral + 10
						if bHasBerserkerRage then
							baselineMoral = baselineMoral + unit:GetDamage()
						end
					end
					if unit:IsHasPromotion(PROMOTION_DRUNKARD) then
						baselineMoral = baselineMoral + 10
					end
				end

				--[[
				local diff = baselineMoral - prevMorale
				diff = 0 < diff and diff + 1 or diff
				local changeMorale = Floor(diff / 2)
				if changeMorale ~= 0 then
					ChangeUnitMorale(iPlayer, iUnit, changeMorale)
				end
				]]
				unit:DecayMorale(baselineMoral)

				--combat unit level promotions
				if unitTypeID == UNIT_GREAT_BOMBARDE and 4 < unit:GetLevel() then
					unit:SetHasPromotion(PROMOTION_EXTENDED_RANGE, true)
				end
			end
			--unit type or civ effects
			local unitDomainTypeID = unit:GetDomainType()
			if UseUnit[unitTypeID] then							--functions for units that are used up (like caravans, fishing boats, etc)
				UseUnit[unitTypeID](iPlayer, unit)
			elseif UseAIUnit[unitTypeID] then	
				if bAI then		
					UseAIUnit[unitTypeID](iPlayer, unit)
				end
			elseif unitDomainTypeID == DOMAIN_SEA then
				--scurvy
				if bNoCitrus then
					local bScurvy = true
					if iPlotOwner ~= -1 then
						if iPlotOwner == iPlayer then
							bScurvy = false
						elseif fullCivs[iPlotOwner] then	--friendship
							if player:IsFriends(iPlotOwner) then bScurvy = false end
						elseif cityStates[iPlotOwner] then		--CS ally
							if Players[iPlotOwner]:GetAlly() == iPlayer then bScurvy = false end
						end	
					end	
					if bScurvy and Rand(100, "scurvy") < 15 then	--15% chance for damage (but never reduced below 1 hp)
						local currentHP = unit:GetCurrHitPoints()
						if currentHP < 11 then
							unit:SetDamage(unit:GetDamage() + currentHP - 1, -1)	--, iPlayer, true?
						else
							unit:SetDamage(10, -1)
						end
					end
				end
			elseif bHorseMounted[unitTypeID] then
				if unit:IsHasPromotion(PROMOTION_STALLIONS_OF_EPONA) then
					gWorld.stallionsOfEpona = gWorld.stallionsOfEpona + 1
				end
				if bHorseMountedXP then
					local dice = Rand(5, "hello there!")
					if dice == 0 then
						unit:ChangeExperience(1)
						print("IKKOS applied xp to mounted")
						eaPlayer.classPoints[5] = eaPlayer.classPoints[5] + 1		--Warrior
					end
				end
				if bHorseMountedStrongMerc and not (bSlave or bMercenary) then
					unit:SetHasPromotion(PROMOTION_STRONG_MERCENARY_INACTIVE, true)
				end

			--elseif unitCombatTypeID == UNITCOMBAT_NAVAL then
			--	if bRemoveOceanBlock then
			--		unit:SetHasPromotion(PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY, false)
			--		unit:SetHasPromotion(PROMOTION_OCEAN_IMPASSABLE, false)
			--	end
			end
		end


		--All units including barbs
		--Sustained promotions
		if sustainedPromotions[iUnit] then
			local unitSustainedPromotions = sustainedPromotions[iUnit]
			local deleteNum = 0
			for promotionID, iCaster in pairs(unitSustainedPromotions) do
				if unit:IsHasPromotion(promotionID) then
					local bKeep = false
					if SustainedPromotionDo[promotionID] then
						bKeep = SustainedPromotionDo[promotionID](player, unit, iCaster)
					else
						print("!!!! ERROR: Missing SustainedPromotionDo function for ", GameInfo.UnitPromotions[promotionID].Type)
					end
					if not bKeep then
						unit:SetHasPromotion(promotionID, false)
						deleteNum = deleteNum + 1
						integers[deleteNum] = promotionID
					end
				else	--promotion was lost somehow so remove from sustained table
					deleteNum = deleteNum + 1
					integers[deleteNum] = promotionID
				end
			end
			for i = 1, deleteNum do
				local promotionID = integers[i]
				unitSustainedPromotions[promotionID] = nil
			end
		end

		--slowed by The Long Wall? (always leave 1 move)
		if bMayBeSlowedByLongWall and iPlotOwner == iLongWallOwner then
			local extraChance = longWallMod % 10 
			local movesLost = (longWallMod - extraChance) * 3	--this is 30-based number!
			if Rand(100, "Long Wall chance") < extraChance then
				movesLost = movesLost + 30
			end
			if movesLost > 0 then
				local beforeMoves = unit:GetMoves()
				if movesLost >= beforeMoves - 30 then
					unit:SetMoves(30)
				else
					unit:SetMoves(beforeMoves - movesLost)
				end
			end
		end
	end

	--XP from process or finisher
	if bFullCiv then
		if player:HasPolicy(POLICY_MILITARISM_FINISHER) then
			eaPlayer.trainingXP = (eaPlayer.trainingXP or 0) + player:GetTotalJONSCulturePerTurn() / 3
		end
		if eaPlayer.trainingXP and 10 < eaPlayer.trainingXP and 0 < countCombatUnits then
			local distributeXP = Floor(eaPlayer.trainingXP / countCombatUnits)
			if 0 < distributeXP then
				print("Adding XP to combat units for Training Exercises Process and/or Militarism Finisher (#units / unitXP): ", countCombatUnits, distributeXP)
				for unit in player:Units() do
					local unitTypeID = unit:GetUnitType()
					if bNormalCombatUnit[unitTypeID] then
						unit:ChangeExperience(distributeXP)
					end
				end				
				eaPlayer.trainingXP = eaPlayer.trainingXP - distributeXP * countCombatUnits
			end
		end
	end

	--UpdateWarriorPoints(iPlayer)

end

--------------------------------------------------------------
-- Event Functions
--------------------------------------------------------------
--TO DO: Get rid of all Events hooks here. Use existing or add new GameEvents!

Events.SerialEventUnitCreated.Add(function(iPlayer, iUnit, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	Dprint("Running SerialEventUnitCreated ", iPlayer, iUnit, hexVec, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, selected, military, notInvisible)
	--WARNINGS:
	--unitType is not unitTypeID
	--runs for embark, disembark
	
		--what is unitType??? (...not unitTypeID)
	if not bInitialized then return end
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
end)


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
			unit:SetInvisibleType(GameInfoTypes.INVISIBLE_SUBMARINE)
		end
	end

end
LuaEvents.EaUnitsResetForcedSelectionUnit.Add(ResetForcedSelectionUnit)

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
function DoDelayedAttacks(iPlayer)	--called by OnPlayerPreAIUnitUpdate for AI or by a delayed timed event for human
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
				if personUnit then
					personUnit:SetGPAttackState(0)
					personUnit:SetInvisibleType(GameInfoTypes.INVISIBLE_SUBMARINE)
					if newX ~= x or newY ~= y then
						print("teleporting GP to follow melee unit")
						personUnit:SetXY(newX, newY)
					end
				else	--probably died in charge
					KillPerson(iPlayer, iPerson)
				end
			end
		end
	end
	g_delayedAttacks.pos = 0
end

local MELEE_ATTACK_AFTER_THOUSANDTHS_SECONDS = 500
local bStart = false
local g_tickStart = 0
function TimeDelayForHumanMeleeCharge(tickCount, timeIncrement)
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
			if bNormalLivingCombatUnit[unitTypeID] then
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
GameEvents.CombatResult.Add(OnCombatResult)

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
GameEvents.CombatEnded.Add(OnCombatEnded)


local function SaveGreatPerson(defendingPlayer, defendingUnit)
	print("SaveGreatPerson")
	local currentPlot = defendingUnit:GetPlot()
	local sector = Rand(6, "hello") + 1
	for testPlot in PlotAreaSpiralIterator(currentPlot, 15, sector, false, false, false) do
		if defendingPlayer:GetPlotDanger(testPlot) == 0 then								--is this plot out of danger?
			if defendingUnit:TurnsToReachTarget(testPlot, 1, 1, 1) < 100 then		--is this plot accessible?
				defendingUnit:SetXY(testPlot:GetX(), testPlot:GetY())
				defendingUnit:SetEmbarked(testPlot:IsWater())
				testPlot:AddFloatUpMessage("Great Person has escaped!")		--TO DO: txt key
				print("Great Person has escaped!")
				return true
			end
		end
	end
	print("!!!! WARNING: Could not find safe accessible plot for GP to escape to; GP will die!")
	return false
end



local function OnCanSaveUnit(iPlayer, iUnit)	--fires for combat and non-combat death (disband, settler settled, etc)
	print("OnCanSaveUnit ", iPlayer, iUnit)

	if iPlayer ~= g_iDefendingPlayer or iUnit ~= g_iDefendingUnit then return false end		--this was not a combat defender death
	
	local defendingPlayer = Players[g_iDefendingPlayer]
	local defendingUnit = defendingPlayer:GetUnitByID(g_iDefendingUnit)

	print("This is a combat defeat; unitType = ", defendingUnit and GameInfo.Units[defendingUnit:GetUnitType()].Type or "nil")

	if not (defendingUnit and defendingUnit:IsGreatPerson()) then return false end	--was not a GP defender

	print("Defending unit was a GP")

	local attackingPlayer = Players[g_iAttackingPlayer]
	if attackingPlayer then
		local attackingUnit = attackingPlayer:GetUnitByID(iAttackingUnit)
		if attackingUnit and attackingUnit:IsGreatPerson() then
			print("Attacker was in GP layer, so we will allow kill")
			return false
		end	--attacker was in GP layer, so allow defender GP death
	end
	return SaveGreatPerson(defendingPlayer, defendingUnit)	--save the GP

end
GameEvents.CanSaveUnit.Add(OnCanSaveUnit)


local function OnUnitKilledInCombat(iKillerPlayer, iKilledPlayer, unitTypeID)
	--always right after OnCanSaveUnit if it was a combat kill
	--Slaves

end
GameEvents.UnitKilledInCombat.Add(OnUnitKilledInCombat)


local function OnUnitTakingPromotion(iPlayer, iUnit, promotionID)
	print("OnUnitTakingPromotion ", iPlayer, iUnit, promotionID)
	local player = Players[iPlayer]
	local unit = player:GetUnitByID(iUnit)
	if player:IsHuman() then
		if promotionID == PROMOTION_LEARN_SPELL then
			local iPerson = unit:GetPersonIndex()
			LuaEvents.LearnSpellPopup(iPerson)
			return false
		else
			if unit:IsGreatPerson() then	--quick access promo levels
				local prefix, level = GetPromoPrefixLevelFromType(promoInfo.Type)
				if prefix then
					local iPerson = unit:GetPersonIndex()
					gPeople[iPerson][prefix] = level
				end
			end
			return true		--allow whatever human player picks
		end
	else
		if unit:IsGreatPerson() then
			local iPerson = unit:GetPersonIndex()
			AIPickGPPromotion(iPlayer, iPerson, unit)
			return false
		else
			return true
		end
	end
end
GameEvents.UnitTakingPromotion.Add(function(iPlayer, iUnit, promotionID) return HandleError31(OnUnitTakingPromotion, iPlayer, iUnit, promotionID) end)


function AttemptToReconectGP(iPerson, unit)		--have either iPerson or unit but not both
	print("AttemptToReconectGP ", iPerson, unit)

	--Just kill for now; may want to try to reconect if needed (saw one possible case of a Slaver CS capturing a Warrior GP)
	if unit then
		print("Just kill unit for now. Info:")
		print("Type = ", GameInfo.Units[unit:GetUnitType()].Type)
		print("Original owner = ", unit:GetOriginalOwner())
		print("Name = ", unit:GetName())

		unit:Kill(true, -1)
	else
		print("Just kill person for now. Info:")
		local eaPerson = gPeople[iPerson]
		print("iPlayer = ", eaPerson.iPlayer)
		print("iUnit = ", eaPerson.iUnit)
		print("unitTypeID = ", eaPerson.unitTypeID, GameInfo.Units[eaPerson.unitTypeID].Type)
		print("subclass = ", eaPerson.subclass)
		print("class1 = ", eaPerson.class1)
		print("class2 = ", eaPerson.class2)
		print("race = ", eaPerson.race)
		print("name = ", eaPerson.name)

		KillPerson(eaPerson.iPlayer, iPerson)
	end
end


--------------------------------------------------------------
-- Promotion utilities
--------------------------------------------------------------

function GetHighestPromotionLevel(prefixStr, unit, iPerson)		--unit is not used if iPerson supplied
	--e.g., if 1st arg is "PROMOTION_COMBAT", then return 7 if unit has PROMOTION_COMBAT_7

	if iPerson then		--for quick access, levels are kept in eaPlayer (faster than testing all promos)
		local eaPerson = gPeople[iPerson]
		local level = eaPerson[prefixStr] or 0

		--debug
		--local unit = Players[eaPerson.iPlayer]:GetUnitByID(eaPerson.iUnit)
		--local debugUnitLevel = GetHighestPromotionLevel(prefixStr, unit, nil)
		--if debugUnitLevel ~= level then
		--	error("promo level from eaPerson not same as from unit: " .. prefixStr .. " " .. level .. " " .. debugUnitLevel)
		--end
		--

		return level
	end

	local levels = promotionLevels[prefixStr]
	if not levels then return 0 end
	for i = levels.max, 1, -1 do		--work down from highest level
		if unit:IsHasPromotion(levels[i]) then
			return i
		end
	end
	return 0
end


--------------------------------------------------------------
-- File Functions
--------------------------------------------------------------

--fishing and whaling boats
UseUnit[GameInfoTypes.UNIT_FISHING_BOATS] = function(iPlayer, unit)
	print("Running UseFishingBoats ", iPlayer, unit)
	--priority is water resource w/in 3-radius, then lake w/in 3, then water resource (by distance)
	local plot = unit:GetPlot()
	local city = plot:GetPlotCity()
	if not city then
		error("Found fishing boat that was not in city")
	end
	local iCity = city:GetID()
	local iPlot = plot:GetPlotIndex()
	local eaCity = gCities[iPlot]
	local fishingResources = gg_cityFishingDistMatrix[iPlayer][iCity]
	local iNearestResourcePlot
	local nearestResourceDist = 10000
	if fishingResources then
		for iPlot, distance in pairs(fishingResources) do
			if distance < nearestResourceDist then
				nearestResourceDist = distance
				iNearestResourcePlot = iPlot
			end
		end
	end
	print("Nearest fishing resource distance = ", nearestResourceDist)
	if 3 < nearestResourceDist and gg_cityLakesDistMatrix[iPlayer][iCity] then	--use available lake
		print("Use lake instead")
		local lakes = gg_cityLakesDistMatrix[iPlayer][iCity]
		local iNearestLakePlot
		local nearestDist = 4
		for iPlot, distance in pairs(lakes) do
			if distance < nearestDist then
				nearestDist = distance
				iNearestLakePlot = iPlot
			end
		end
		print("Nearest lake distance = ", nearestDist)
		local lakePlot = Map.GetPlotByIndex(iNearestLakePlot)
		lakePlot:SetOwner(iPlayer, iCity)
		lakePlot:SetImprovementType(IMPROVEMENT_FISHING_BOATS)
		RemoveOwnedLakePlot(iNearestLakePlot, iPlayer, iCity)
		--Do notification and special effect
	elseif nearestResourceDist <= gg_fishingRange[iPlayer] then		--improve resource
		local resourcePlot = Map.GetPlotByIndex(iNearestResourcePlot)
		resourcePlot:SetOwner(iPlayer, iCity)
		resourcePlot:SetImprovementType(IMPROVEMENT_FISHING_BOATS)
		RemoveOwnedFishingResourcePlot(iNearestResourcePlot, iPlayer, iCity)
		if 3 < nearestResourceDist then
			eaCity.remotePlots[iNearestResourcePlot] = true
		end
		--Do notification and special effect

	else
		print("!!!! Warning: Fishingboats built but can't be used")
	end
	unit:Kill(true, -1)	--unit:SetDamage(unit:GetMaxHitPoints())	--remove fishing boats unit
end

UseUnit[GameInfoTypes.UNIT_WHALING_BOATS] = function(iPlayer, unit)
	print("Running UseWhalingBoats ", iPlayer, unit)
	--priority is simply closest available by distance (there are no lake whales)
	local plot = unit:GetPlot()
	local city = plot:GetPlotCity()
	if not city then
		error("Found fishing boat that was not in city")
	end
	local iCity = city:GetID()
	local iPlot = plot:GetPlotIndex()
	local eaCity = gCities[iPlot]
	local whales = gg_cityWhalingDistMatrix[iPlayer][iCity]
	local iNearestWhalePlot
	local nearestWhaleDist = 10000
	if whales then
		for iPlot, distance in pairs(whales) do
			if distance < nearestWhaleDist then
				nearestWhaleDist = distance
				iNearestWhalePlot = iPlot
			end
		end
	end
	if nearestWhaleDist <= gg_whalingRange[iPlayer] then
		local whalePlot = Map.GetPlotByIndex(iNearestWhalePlot)
		whalePlot:SetOwner(iPlayer, iCity)
		whalePlot:SetImprovementType(IMPROVEMENT_WHALING_BOATS)
		RemoveOwnedWhalePlot(iNearestWhalePlot, iPlayer, iCity)
		if 3 < nearestWhaleDist then
			eaCity.remotePlots[iNearestWhalePlot] = true
		end
		--Do notification and special effect
	else
		print("!!!! Warning: Whaling Boats built but can't be used")
	end
	unit:Kill(true, -1)	--unit:SetDamage(unit:GetMaxHitPoints())	--remove whaling boats unit
end

UseUnit[GameInfoTypes.UNIT_HUNTERS] = function(iPlayer, unit)
	print("Running UseHunters ", iPlayer, unit)
	--priority is closest available by distance
	local plot = unit:GetPlot()
	local city = plot:GetPlotCity()
	if not city then
		error("Found Hunters that was not in city")
	end
	local iCity = city:GetID()
	local iPlot = plot:GetPlotIndex()
	local eaCity = gCities[iPlot]
	local campResources = gg_cityCampResDistMatrix[iPlayer][iCity]
	local iNearestCampResPlot
	local nearestCampResDist = 10000
	if campResources then
		for iPlot, distance in pairs(campResources) do
			if distance < nearestCampResDist then
				nearestCampResDist = distance
				iNearestCampResPlot = iPlot
			end						--need to add prioritization or randomization for ties
		end
	end
	if nearestCampResDist <= gg_campRange[iPlayer] then
		local campPlot = Map.GetPlotByIndex(iNearestCampResPlot)
		campPlot:SetOwner(iPlayer, iCity)
		campPlot:SetImprovementType(IMPROVEMENT_CAMP)
		RemoveOwnedCampPlot(iNearestCampResPlot, iPlayer, iCity)
		if 3 < nearestCampResDist then
			eaCity.remotePlots[iNearestCampResPlot] = true
		end
		--Do notification and special effect
	else
		print("!!!! Warning: Hunters built but can't be used")
	end
	unit:Kill(true, -1)	--unit:SetDamage(unit:GetMaxHitPoints())	--remove unit
end

UseAIUnit[GameInfoTypes.UNIT_CARAVAN] = function(iPlayer, unit)
	--happens when AI route expires
	--need logic to cance
	print("UseAIUnit[GameInfoTypes.UNIT_CARAVAN]", iPlayer, unit)
	local numberOpen, bestCity, bestYield = FindOpenTradeRoute(iPlayer, DOMAIN_LAND, true)
	if 0 < numberOpen then
		local plot = unit:GetPlot()
		local city = plot:GetPlotCity()
		if city ~= bestCity then
			--do instant teleport for AI (it's a small ai cheat that prevents log jam of all units going to same city)
			print("Teleporting AI caravan to better FromCity")
			plot = bestCity:Plot()
			unit:SetXY(plot:GetX(), plot:GetY())

			--Game.SelectionListGameNetMessage(GameMessageTypes.GAMEMESSAGE_PUSH_MISSION, MissionTypes.MISSION_CHANGE_TRADE_UNIT_HOME_CITY, g_selectedPlotX, g_selectedPlotY, 0, false, bShift);
			--unit:PushMission(MissionTypes.MISSION_CHANGE_TRADE_UNIT_HOME_CITY, bestCity:GetX(), bestCity:GetY(), 0, 0, 1)
		end
		unit:PushMission(MissionTypes.MISSION_ESTABLISH_TRADE_ROUTE, plot:GetPlotIndex(), 0, 0, 0, 1)		--TradeConnectionType (3rd arg) is 0 for land!!!! must test for sea
	else
		print("!!!! WARNING: player has caravan but no open and available trade routes")
	end
end



UseAIUnit[GameInfoTypes.UNIT_CARGO_SHIP] = function(iPlayer, unit)
	print("UseAIUnit[GameInfoTypes.UNIT_CARGO_SHIP]", iPlayer, unit)


end

RemoveOwnedFishingResourcePlot = function(iPlot, iOwnerPlayer, iOwnerCity)
	for iPlayer in pairs(realCivs) do
		for city in Players[iPlayer]:Cities() do
			local iCity = city:GetID()
			local fishingResources = gg_cityFishingDistMatrix[iPlayer][iCity]
			if fishingResources and fishingResources[iPlot] then
				if 3 < fishingResources[iPlot] or (iPlayer == iOwnerPlayer and iCity == iOwnerCity) then
					fishingResources[iPlot] = nil
					if next(fishingResources) == nil then		--table empty
						gg_cityFishingDistMatrix[iPlayer][iCity] = nil
					end
				end
			end
		end
	end
	for _, eaCity in pairs(gCities) do
		eaCity.remotePlots[iPlot] = nil					--remove from all here; will be added to new owner after this function
	end
end

RemoveOwnedWhalePlot = function(iPlot, iOwnerPlayer, iOwnerCity)
	for iPlayer in pairs(realCivs) do
		for city in Players[iPlayer]:Cities() do
			local iCity = city:GetID()
			local whales = gg_cityWhalingDistMatrix[iPlayer][iCity]
			if whales and whales[iPlot] then
				if 3 < whales[iPlot] or (iPlayer == iOwnerPlayer and iCity == iOwnerCity) then
					whales[iPlot] = nil
					if next(whales) == nil then		--table empty
						gg_cityWhalingDistMatrix[iPlayer][iCity] = nil
					end
				end
			end
		end
	end
	for _, eaCity in pairs(gCities) do
		eaCity.remotePlots[iPlot] = nil					--remove from all here; will be added to new owner after this function
	end
end

RemoveOwnedLakePlot = function(iPlot, iOwnerPlayer, iOwnerCity)
	for iPlayer in pairs(realCivs) do
		for city in Players[iPlayer]:Cities() do
			local iCity = city:GetID()
			local lakes = gg_cityLakesDistMatrix[iPlayer][iCity]
			if lakes and lakes[iPlot] then
				lakes[iPlot] = nil
				if next(lakes) == nil then		--table empty
					gg_cityLakesDistMatrix[iPlayer][iCity] = nil
				end
			end
		end
	end
end

RemoveOwnedCampPlot = function(iPlot, iOwnerPlayer, iOwnerCity)
	for iPlayer in pairs(realCivs) do
		for city in Players[iPlayer]:Cities() do
			local iCity = city:GetID()
			local campResources = gg_cityCampResDistMatrix[iPlayer][iCity]
			if campResources and campResources[iPlot] then
				if 3 < campResources[iPlot] or (iPlayer == iOwnerPlayer and iCity == iOwnerCity) then
					campResources[iPlot] = nil
					if next(campResources) == nil then		--table empty
						gg_cityCampResDistMatrix[iPlayer][iCity] = nil
					end
				end
			end
		end
	end
	for _, eaCity in pairs(gCities) do
		eaCity.remotePlots[iPlot] = nil					--remove from all here; will be added to new owner after this function
	end
end

--sustained promotion system

SustainedPromotionDo[GameInfoTypes.PROMOTION_HEX] = function(player, unit, iCaster)
	local eaPerson = gPeople[iCaster]
	if not eaPerson then return false end	--caster died
	local mod = GetGPMod(iPerson, EAMOD_CONJURATION, nil)
	if Rand(mod, "hello") == 0 then return false end	--1/mod chance to wear off each turn
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)		--wear off if caster has no more mana or divine favor
end

SustainedPromotionDo[GameInfoTypes.PROMOTION_BLESSED] = function(player, unit, iCaster)
	local eaPerson = gPeople[iCaster]
	if not eaPerson then return false end	--caster died
	local mod = GetGPMod(iPerson, EAMOD_DEVOTION, EAMOD_EVOCATION)
	if Rand(mod, "hello") == 0 then return false end	--1/mod chance to wear off each turn
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)		--wear off if caster has no more mana or divine favor
end

SustainedPromotionDo[GameInfoTypes.PROMOTION_PROTECTION_FROM_EVIL] = function(player, unit, iCaster)
	local eaPerson = gPeople[iCaster]
	if not eaPerson then return false end	--caster died
	local mod = GetGPMod(iPerson, EAMOD_DEVOTION, EAMOD_ABJURATION)
	if Rand(mod, "hello") == 0 then return false end	--1/mod chance to wear off each turn
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)		--wear off if caster has no more mana or divine favor
end

SustainedPromotionDo[GameInfoTypes.PROMOTION_CURSED] = function(player, unit, iCaster)
	local eaPerson = gPeople[iCaster]
	if not eaPerson then return false end	--caster died
	local mod = GetGPMod(iPerson, EAMOD_DEVOTION, EAMOD_ABJURATION)
	if Rand(mod, "hello") == 0 then return false end	--1/mod chance to wear off each turn
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)		--wear off if caster has no more mana or divine favor
end

SustainedPromotionDo[GameInfoTypes.PROMOTION_RIDE_LIKE_THE_WINDS] = function(player, unit, iCaster)
	local eaPerson = gPeople[iCaster]
	if eaPerson.deathTurn then return false end
	local gpX, gpY = GetGPXY(eaPerson)
	if eaPerson.modDevotion < Distance(gpX, gpY, unit:GetX(), unit:GetY()) then return false end
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)
end

----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)