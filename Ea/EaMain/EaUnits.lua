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
local BARB_PLAYER_INDEX =							BARB_PLAYER_INDEX
local ANIMALS_PLAYER_INDEX =						ANIMALS_PLAYER_INDEX
local HIGHEST_PROMOTION_ID =						HIGHEST_PROMOTION_ID

local MAX_CITY_HIT_POINTS =							GameDefines.MAX_CITY_HIT_POINTS

local DOMAIN_LAND =									DomainTypes.DOMAIN_LAND
local DOMAIN_SEA =									DomainTypes.DOMAIN_SEA

local EACIV_MORRIGNA =								GameInfoTypes.EACIV_MORRIGNA
local EACIV_NEMEDIA =								GameInfoTypes.EACIV_NEMEDIA
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
local POLICY_WARSPIRIT =							GameInfoTypes.POLICY_WARSPIRIT
local POLICY_BERSERKER_RAGE =						GameInfoTypes.POLICY_BERSERKER_RAGE
local POLICY_MILITARISM_FINISHER =					GameInfoTypes.POLICY_MILITARISM_FINISHER
local PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY =	GameInfoTypes.PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY
local PROMOTION_OCEAN_IMPASSABLE =					GameInfoTypes.PROMOTION_OCEAN_IMPASSABLE
local PROMOTION_SLAVE =								GameInfoTypes.PROMOTION_SLAVE
local PROMOTION_FOR_HIRE =							GameInfoTypes.PROMOTION_FOR_HIRE
local PROMOTION_MERCENARY =							GameInfoTypes.PROMOTION_MERCENARY
local PROMOTION_STRONG_MERCENARY_INACTIVE =			GameInfoTypes.PROMOTION_STRONG_MERCENARY_INACTIVE
local PROMOTION_STRONG_MERCENARY =					GameInfoTypes.PROMOTION_STRONG_MERCENARY
local PROMOTION_EXTENDED_RANGE =					GameInfoTypes.PROMOTION_EXTENDED_RANGE
local PROMOTION_DRUNKARD =							GameInfoTypes.PROMOTION_DRUNKARD
local PROMOTION_STALLIONS_OF_EPONA =				GameInfoTypes.PROMOTION_STALLIONS_OF_EPONA
local PROMOTION_STUNNED =							GameInfoTypes.PROMOTION_STUNNED
local PROMOTION_STEEL_WEAPONS =						GameInfoTypes.PROMOTION_STEEL_WEAPONS
local PROMOTION_MITHRIL_WEAPONS =					GameInfoTypes.PROMOTION_MITHRIL_WEAPONS
local RELIGION_CULT_OF_EPONA =						GameInfoTypes.RELIGION_CULT_OF_EPONA
local RESOURCE_CITRUS =								GameInfoTypes.RESOURCE_CITRUS
local TECH_STEEL_WORKING = 							GameInfoTypes.TECH_STEEL_WORKING
local UNITCOMBAT_MOUNTED = 							GameInfoTypes.UNITCOMBAT_MOUNTED
local UNITCOMBAT_NAVAL =							GameInfoTypes.UNITCOMBAT_NAVAL
local UNIT_FISHING_BOATS =							GameInfoTypes.UNIT_FISHING_BOATS
local UNIT_WHALING_BOATS =							GameInfoTypes.UNIT_WHALING_BOATS
local UNIT_HUNTERS =								GameInfoTypes.UNIT_HUNTERS
local UNIT_GREAT_BOMBARDE =							GameInfoTypes.UNIT_GREAT_BOMBARDE

--state shared

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
local bHidden =						MapModData.bHidden
local realCivs =					MapModData.realCivs
local fullCivs =					MapModData.fullCivs
local cityStates =					MapModData.cityStates
local gg_regularCombatType =		gg_regularCombatType
local gg_combatPointDiff =			gg_combatPointDiff
local gg_unitPrefixUnitIDs =		gg_unitPrefixUnitIDs
local gg_fishingRange =				gg_fishingRange
local gg_whalingRange =				gg_whalingRange
local gg_campRange =				gg_campRange
local gg_eaSpecial =				gg_eaSpecial
local gg_unitTier =					gg_unitTier

--localized functions
local Rand = Map.Rand
local floor = math.floor
local PlotDistance = Map.PlotDistance
local gsub = string.gsub
local GetPlotFromXY =			Map.GetPlot
local PlotToRadiusIterator =	PlotToRadiusIterator
local HandleError31 =			HandleError31

--file functions
local UseUnit = {}
local UseAIUnit = {}
local SustainedPromotionDo = {}		--Function holder for sustained promotions (run each turn for each unit with promo)

--file control
local g_iActivePlayer = Game.GetActivePlayer()


local integers = {}
local bInitialized = false

---------------------------------------------------------------
-- Cached Tables
---------------------------------------------------------------

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
local faithMaintenance = {}
for unitInfo in GameInfo.Units() do
	if unitInfo.EaSpecial == "Animal" or unitInfo.EaSpecial == "Beast" then
		bAnimal[unitInfo.ID] = true
	end
	if unitInfo.EaFaithMaintenance ~= 0 then
		faithMaintenance[unitInfo.ID] = unitInfo.EaFaithMaintenance
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
						MapModData.bBypassOnCanSaveUnit = true
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
						MapModData.bBypassOnCanSaveUnit = true
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
			local newUnitType = gsub(unitType, fromStr, toStr)
			local newUnitTypeID = GameInfoTypes[newUnitType]
			local newUnit = player:InitUnit(newUnitTypeID, unit:GetX(), unit:GetY())
			MapModData.bBypassOnCanSaveUnit = true
			newUnit:Convert(unit)
		end
	end
end

function HireMercenary(iPlayer, unit, upFront, gpt)
	print("Running HireMercenary ", iPlayer, unit, upFront, gpt)
	local player = Players[iPlayer]
	local unitTypeID = unit:GetUnitType()
	local iOriginalOwner = unit:GetOriginalOwner()

	local spawnPlot = GetPlotForSpawn(unit:GetPlot(), iPlayer, 2, false, false, false, false, true, false, unit)
	if spawnPlot then
		local unitTypeID = unit:GetUnitType()
		local x, y = spawnPlot:GetXY()
		local newUnit = player:InitUnit(unitTypeID, x, y)
		if newUnit then
			newUnit:SetOriginalOwner(iOriginalOwner)
			local iNewUnit = newUnit:GetID()
			local mercenaries = gPlayers[iPlayer].mercenaries
			mercenaries[iOriginalOwner] = mercenaries[iOriginalOwner] or {}
			mercenaries[iOriginalOwner][iNewUnit] = gpt
			player:ChangeGold(-upFront)
			MapModData.bBypassOnCanSaveUnit = true
			newUnit:Convert(unit)		--sets xp, level, promotions (but not original owner)
			newUnit:SetHasPromotion(PROMOTION_MERCENARY, true)
			newUnit:SetHasPromotion(PROMOTION_FOR_HIRE, false)
			if newUnit:IsHasPromotion(PROMOTION_STRONG_MERCENARY_INACTIVE) then
				newUnit:SetHasPromotion(PROMOTION_STRONG_MERCENARY_INACTIVE, false)
				newUnit:SetHasPromotion(PROMOTION_STRONG_MERCENARY, true)
			end

			newUnit:FinishMoves()
			newUnit:SetMorale(0)
			if iPlayer == g_iActivePlayer then
				UI.SelectUnit(newUnit)
				UI.LookAtSelectionPlot(0)
				spawnPlot:AddFloatUpMessage("Hired mercenary!", 2)
			end
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
			local spawnPlot = GetPlotForSpawn(unit:GetPlot(), iOriginalOwner, 2, false, false, false, false, true, false, unit)
			if spawnPlot then
				local unitTypeID = unit:GetUnitType()
				local x, y = spawnPlot:GetXY()
				local newUnit = originalOwner:InitUnit(unitTypeID, x, y)
				if newUnit then
					bConverted = true
					MapModData.bBypassOnCanSaveUnit = true
					newUnit:Convert(unit)
					newUnit:SetOriginalOwner(iOriginalOwner)
					newUnit:SetHasPromotion(PROMOTION_MERCENARY, false)
					if newUnit:IsHasPromotion(PROMOTION_STRONG_MERCENARY) then
						newUnit:SetHasPromotion(PROMOTION_STRONG_MERCENARY, false)
						newUnit:SetHasPromotion(PROMOTION_STRONG_MERCENARY_INACTIVE, true)
					end
					print("Merc has been dismissed")
					if iOriginalOwner == g_iActivePlayer then
						spawnPlot:AddFloatUpMessage("Mercenary was dismissed", 1)
					elseif iPlayer == g_iActivePlayer then
						spawnPlot:AddFloatUpMessage("Dismissed mercenary", 1)
					end
				else
					print("!!!! WARNING: Merc was dismissed but original civ did not get it back !!!!")
				end
			end
		else
			print("Merc has been dismissed; original owner is no longer alive so unit destroyed")
		end
		if not bConverted then
			print("!!!! WARNING: Merc was dismissed and original owner exists, but unit could not be returned for some reason")
			MapModData.bBypassOnCanSaveUnit = true
			unit:Kill(true, -1)
		end
	end
end
LuaEvents.EaUnitsDismissMercenary.Add(DismissMercenary)

function UnitPerCivTurn(iPlayer)	--runs for full civs and city states
	print("UnitPerCivTurn")
	local Rand = Rand
	local floor = floor
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local team = Teams[player:GetTeam()]
	local bBarbs = iPlayer == BARB_PLAYER_INDEX
	local bAnimals = iPlayer == ANIMALS_PLAYER_INDEX
	local bFullCiv = fullCivs[iPlayer]
	local bAI = not bFullCiv or not player:IsHuman()
	local nameTraitID = bFullCiv and eaPlayer.eaCivNameID or -1
	--local bMercenaryCityState = not bFullCiv and player:GetMinorCivTrait() == MINOR_TRAIT_MERCENARY

	local playerHappiness = bFullCiv and player:GetExcessHappiness() or 0


	local sustainedPromotions = eaPlayer.sustainedPromotions
	local bHorseMountedXP = nameTraitID == EACIV_IKKOS
	local bHorseMountedStrongMerc = nameTraitID == EACIV_HIPPUS
	local bRemoveOceanBlock = bFullCiv and eaPlayer.eaCivNameID == EACIV_FOMHOIRE
	local bHasSteelWorking = team:IsHasTech(TECH_STEEL_WORKING)
	local bHasMithrilWorking = team:IsHasTech(TECH_MITHRIL_WORKING)
	local iLongWallOwner = gWonders[EA_WONDER_THE_LONG_WALL] and Map.GetPlotByIndex(gWonders[EA_WONDER_THE_LONG_WALL].iPlot):GetOwner()
	local bMayBeSlowedByLongWall = iLongWallOwner and team:IsAtWar(Players[iLongWallOwner]:GetTeam())
	local longWallMod = iLongWallOwner and gWonders[EA_WONDER_THE_LONG_WALL].mod
	local bNoCitrus = bFullCiv and player:GetNumResourceAvailable(RESOURCE_CITRUS, true) < 1
	local bHasWarspirit = bFullCiv and player:HasPolicy(POLICY_WARSPIRIT)
	local bHasBerserkerRage = bHasWarspirit and player:HasPolicy(POLICY_BERSERKER_RAGE) or false
	local bMoraleFloor = (nameTraitID == EACIV_NEMEDIA or nameTraitID == EACIV_MORRIGNA)


	local countCombatUnits = 0
	for unit in player:Units() do
		local iUnit = unit:GetID()
		local plot = unit:GetPlot()
		local iPlot = plot:GetPlotIndex()
		local iPlotOwner = plot:GetOwner()
		local unitTypeID = unit:GetUnitType()
		local iPerson = unit:GetPersonIndex()	-- -1 if not a GP

		--Debug
		if unitTypeID == 0 then
			error("Found an ID=0 unit; most likely there was a player:UnitInit() with an invalid unitTypeID")
		end
		if iPerson ~= -1 and not unit:IsDelayedDeath() then
			if not gPeople[iPerson] then
				error("!!!! WARNING: Found an orphan GP; iPlayer, unitTypeID, iPlot = " .. iPlayer .. ", " .. GameInfo.Units[unitTypeID].Type .. ", " .. iPlot)
			end
		end

		--Stunned units lose movement one turn
		if unit:IsHasPromotion(PROMOTION_STUNNED) then
			unit:FinishMoves()
			unit:SetHasPromotion(PROMOTION_STUNNED, false)
		end

		--Warrior gains best movement from adjacent/same-plot "troops" units (TO DO: this will become an automatic conversion to mounted GP unit)
		if iPerson ~= -1 then
			local eaPerson = gPeople[iPerson]
			if eaPerson.class1 == "Warrior" or eaPerson.class2 == "Warrior" then
				local bestMoves = 120
				for loopPlot in AdjacentPlotIterator(plot, false, true) do
					local unitCount = loopPlot:GetNumUnits()
					for i = 0, unitCount - 1 do
						local loopUnit = loopPlot:GetUnit(i)
						local loopUnitTypeID = loopUnit:GetUnitType()
						if gg_regularCombatType[loopUnitTypeID] == "troops" then
							local moves = loopUnit:GetMoves()
							if bestMoves < moves then
								bestMoves = moves
							end
						end
					end
				end
				if bestMoves > 120 and unit:GetMoves() >= 120 then	--make sure GP has normal movement at turn start (isn't restricted by some spell)
					print("Giving Warrior extra movement from troops ", bestMoves)
					unit:SetMoves(bestMoves)
				end
			end
		end
	
		if bAnimals then
			--
		elseif bBarbs then
			if faithMaintenance[unitTypeID] then
				UseManaOrDivineFavor(BARB_PLAYER_INDEX, nil, faithMaintenance[unitTypeID], true, plot)
			end
		else	--Full civs and city states
			if faithMaintenance[unitTypeID] then
				UseManaOrDivineFavor(iPlayer, nil, faithMaintenance[unitTypeID], false, plot)
			end


			local bSlave
			local bMercenary

			if gg_regularCombatType[unitTypeID] then
				countCombatUnits = countCombatUnits + 1

				bSlave = unit:IsHasPromotion(PROMOTION_SLAVE)
				bMercenary = unit:IsHasPromotion(PROMOTION_MERCENARY)

				--Morale decays toward baseline (= civ happiness; -30 for slaves; 0 for mercenary; -20 for merc at war with original owner)
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
							baselineMoral = baselineMoral + floor(unit:GetDamage() / 2)
						end
					end
					if unit:IsHasPromotion(PROMOTION_DRUNKARD) then
						baselineMoral = baselineMoral + 10
					end
				end
				if bMoraleFloor and baselineMoral < -15 then
					baselineMoral = -15
				end
				
				unit:DecayMorale(baselineMoral)

				--combat unit level promotions
				if unitTypeID == UNIT_GREAT_BOMBARDE and 4 < unit:GetLevel() then
					unit:SetHasPromotion(PROMOTION_EXTENDED_RANGE, true)
				end
			elseif gg_eaSpecial[unitTypeID] == "Undead" then
				local iSummoner = unit:GetSummonerIndex()
				if iSummoner == -99 or not gPeople[iSummoner] then
					local dice = Rand(15, "hello")
					if dice == 0 then
						local spawnPlot = GetPlotForSpawn(plot, BARB_PLAYER_INDEX, 2, false, false, false, false, false, false, unit)
						if spawnPlot then
							local x, y = spawnPlot:GetXY()
							MapModData.bBypassOnCanSaveUnit = true
							local newUnit = Players[BARB_PLAYER_INDEX]:InitUnit(unitTypeID, x, y)
							newUnit:Convert(unit, false)
							iUnit = newUnit:GetID()
							unit = newUnit			
							spawnPlot:AddFloatUpMessage("Unbound dead has gone hostile!", 1)
						else
							MapModData.bBypassOnCanSaveUnit = true
							unit:Kill(true, -1)
							plot:AddFloatUpMessage("Unbound dead has un-animated", 1)						
						end
					--elseif dice < 3 then
					--	MapModData.bBypassOnCanSaveUnit = true
					--	unit:Kill(true, -1)
					--	plot:AddFloatUpMessage("Unbound dead has un-animated", 1)
					end				
				end
			end

			--Steel/Mithril Weopons
			if bHasSteelWorking and gg_regularCombatType[unitTypeID] == "troops" then
				if bHasMithrilWorking and 4 < gg_unitTier[unitTypeID] then
					if not unit:IsHasPromotion(PROMOTION_MITHRIL_WEAPONS) then
						if unit:IsHasPromotion(PROMOTION_STEEL_WEAPONS) then
							unit:SetHasPromotion(PROMOTION_STEEL_WEAPONS, false)
							unit:SetBaseCombatStrength(unit:GetBaseCombatStrength() + 2)
						else
							unit:SetBaseCombatStrength(unit:GetBaseCombatStrength() + 4)
						end
						unit:SetHasPromotion(PROMOTION_MITHRIL_WEAPONS, true)
					end
				elseif 2 < gg_unitTier[unitTypeID] then
					if not unit:IsHasPromotion(PROMOTION_STEEL_WEAPONS) and not unit:IsHasPromotion(PROMOTION_MITHRIL_WEAPONS) then
						unit:SetBaseCombatStrength(unit:GetBaseCombatStrength() + 2)
						unit:SetHasPromotion(PROMOTION_STEEL_WEAPONS, true)
					end
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
						unit:GetPlot():AddFloatUpMessage("Damaged by Scurvy!", 2)
						local currentHP = unit:GetCurrHitPoints()
						if currentHP < 11 then
							unit:SetDamage(unit:GetDamage() + currentHP - 1, -1)	--, iPlayer, true?
						else
							unit:SetDamage(10, -1)
						end
					end
				end
				if unitCombatTypeID == UNITCOMBAT_NAVAL then
					if bRemoveOceanBlock then
						unit:SetHasPromotion(PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY, false)
						unit:SetHasPromotion(PROMOTION_OCEAN_IMPASSABLE, false)
					end
				end
			elseif bHorseMounted[unitTypeID] then
				if unit:IsHasPromotion(PROMOTION_STALLIONS_OF_EPONA) then
					gg_counts.stallionsOfEpona = gg_counts.stallionsOfEpona + 1
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
			local distributeXP = floor(eaPlayer.trainingXP / countCombatUnits)
			if 0 < distributeXP then
				print("Adding XP to combat units for Training Exercises Process and/or Militarism Finisher (#units / unitXP): ", countCombatUnits, distributeXP)
				for unit in player:Units() do
					local unitTypeID = unit:GetUnitType()
					if gg_regularCombatType[unitTypeID] then
						unit:ChangeExperience(distributeXP)
					end
				end				
				eaPlayer.trainingXP = eaPlayer.trainingXP - distributeXP * countCombatUnits
			end
		end
	end

	--UpdateWarriorPoints(iPlayer)

end

local function OnUnitTakingPromotion(iPlayer, iUnit, promotionID)
	print("OnUnitTakingPromotion ", iPlayer, iUnit, promotionID)
	local player = Players[iPlayer]
	local unit = player:GetUnitByID(iUnit)
	local iPerson = unit:GetPersonIndex() 
	if player:IsHuman() then
		if iPerson ~= -1 then	--quick access promo levels
			local eaPerson = gPeople[iPerson]
			local promoInfo = GameInfo.UnitPromotions[promotionID]
			local prefix, level = GetPromoPrefixLevelFromType(promoInfo.Type)
			if prefix then
				eaPerson[prefix] = level
			end
			if eaPerson.assumedLeadershipTurn then
				eaPerson.leaderLevel = floor((Game.GetGameTurn() - eaPerson.assumedLeadershipTurn) / 20)	--intentional that this only updates w/ leveling (game interest and works better for mod caching)
			end
			eaPerson.level = unit:GetLevel()
			--eaPerson.promotions[promotionID] = true

			SetTowerMods(iPlayer, iPerson)
			unit:SetBaseCombatStrength(GetGPMod(iPerson, "EAMOD_COMBAT"))
		end
		return true		--allow whatever human player picks
	else	--AI
		if iPerson ~= -1 then
			local eaPerson = gPeople[iPerson]
			promotionID = AIPickGPPromotion(iPlayer, iPerson, unit)
			if eaPerson.assumedLeadershipTurn then
				eaPerson.leaderLevel = floor((Game.GetGameTurn() - eaPerson.assumedLeadershipTurn) / 20)
			end
			eaPerson.level = unit:GetLevel()
			--eaPerson.promotions[promotionID] = true

			SetTowerMods(iPlayer, iPerson)
			unit:SetBaseCombatStrength(GetGPMod(iPerson, "EAMOD_COMBAT"))
			return false				--We are cancelling whatever dll picked for GP
		else
			return true
		end
	end
end
GameEvents.UnitTakingPromotion.Add(function(iPlayer, iUnit, promotionID) return HandleError31(OnUnitTakingPromotion, iPlayer, iUnit, promotionID) end)

--------------------------------------------------------------
-- Promotion utilities
--------------------------------------------------------------

function GetHighestPromotionLevel(prefixStr, unit, iPerson)		--unit is not used if iPerson supplied
	--e.g., if 1st arg is "PROMOTION_COMBAT", then return 7 if unit has PROMOTION_COMBAT_7

	if iPerson then		--for quick access, levels are kept in eaPlayer (faster than testing all promos)
		local eaPerson = gPeople[iPerson]
		local level = eaPerson[prefixStr] or 0
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

UseUnit[GameInfoTypes.UNIT_HUNTERS] = function(iPlayer, unit)
	print("Running Running UseUnit - Hunters ", iPlayer, unit)
	--priority is closest available by distance
	local plot = unit:GetPlot()
	local iPlot = plot:GetPlotIndex()
	local city = plot:GetPlotCity()
	if not city then
		error("Found Hunters that was not in city")
	end
	local sector = Rand(6, "hello") + 1
	local plotToImprove
	for radius = 1, gg_campRange[iPlayer] do
		for testPlot in PlotRingIterator(plot, radius, sector, false) do
			local iTestPlot = testPlot:GetPlotIndex()
			if gg_remoteImprovePlot[iTestPlot] == "HuntingRes" then
				local iOwner = testPlot:GetOwner()
				if iOwner == -1 then
					testPlot:SetOwner(iPlayer, city:GetID())
					plotToImprove = testPlot
					break
				elseif iOwner == iPlayer and testPlot:GetImprovementType() == -1 then
					plotToImprove = testPlot
					break
				end
				if radius < 4 then	--may steal plot if owner is remote
					local iOwningCity = testPlot:GetCityPurchaseID()
					local iPlotOwningCity = gg_playerCityPlotIndexes[iOwner][iOwningCity] or InitCityPlotIndexGlobals(iOwner, iOwningCity)			
					local ownerDist = GetMemoizedPlotIndexDistance(iTestPlot, iPlotOwningCity)
					if 3 < ownerDist then
						if iOwner == iPlayer then
							testPlot:SetOwner(iPlayer, city:GetID())	--transfer ownership to this city (should have happen elsewhere, but just in case)
						else
							testPlot:SetOwner(iPlayer, city:GetID())
							plotToImprove = testPlot		--steal from remote owner city
							break
						end				
					end
				end
			end
		end
	end
	if plotToImprove then
		plotToImprove:SetImprovementType(IMPROVEMENT_CAMP)
	else
		print("!!!! Warning: Hunters built but can't be used; killing unit")
	end
	MapModData.bBypassOnCanSaveUnit = true
	unit:Kill(true, -1)		--remove unit
end

UseUnit[GameInfoTypes.UNIT_FISHING_BOATS] = function(iPlayer, unit)
	print("Running UseUnit - Fishing Boats ", iPlayer, unit)
	--priority is closest available by distance
	local plot = unit:GetPlot()
	local iPlot = plot:GetPlotIndex()
	local city = plot:GetPlotCity()
	if not city then
		error("Found Whaling Boats that was not in city")
	end
	local bCoastal = gg_cityPlotCoastalTest[iPlot]
	local range = bCoastal and gg_fishingRange[iPlayer] or 3
	local sector = Rand(6, "hello") + 1
	local plotToImprove
	for radius = 1, range do
		for testPlot in PlotRingIterator(plot, radius, sector, false) do
			local iTestPlot = testPlot:GetPlotIndex()
			if gg_remoteImprovePlot[iTestPlot] == "Lake" or (bCoastal and gg_remoteImprovePlot[iTestPlot] == "FishingRes") then
				local iOwner = testPlot:GetOwner()
				if iOwner == -1 then
					testPlot:SetOwner(iPlayer, city:GetID())
					plotToImprove = testPlot
					break
				elseif iOwner == iPlayer and testPlot:GetImprovementType() == -1 then
					plotToImprove = testPlot
					break
				end
				if radius < 4 and gg_remoteImprovePlot[iTestPlot] == "FishingRes" then	--may steal plot if owner is remote
					local iOwningCity = testPlot:GetCityPurchaseID()
					local iPlotOwningCity = gg_playerCityPlotIndexes[iOwner][iOwningCity] or InitCityPlotIndexGlobals(iOwner, iOwningCity)			
					local ownerDist = GetMemoizedPlotIndexDistance(iTestPlot, iPlotOwningCity)
					if 3 < ownerDist then
						if iOwner == iPlayer then
							testPlot:SetOwner(iPlayer, city:GetID())	--transfer ownership to this city (should have happen elsewhere, but just in case)
						else
							testPlot:SetOwner(iPlayer, city:GetID())
							plotToImprove = testPlot		--steal from remote owner city
							break
						end				
					end
				end
			end
		end
	end
	if plotToImprove then
		plotToImprove:SetImprovementType(IMPROVEMENT_FISHING_BOATS)
	else
		print("!!!! Warning: Whaling Boats built but can't be used; killing unit")
	end
	MapModData.bBypassOnCanSaveUnit = true
	unit:Kill(true, -1)		--remove unit
end

UseUnit[GameInfoTypes.UNIT_WHALING_BOATS] = function(iPlayer, unit)
	print("Running UseUnit - Whaling Boats ", iPlayer, unit)
	--priority is closest available by distance
	local plot = unit:GetPlot()
	local iPlot = plot:GetPlotIndex()
	local city = plot:GetPlotCity()
	if not city then
		error("Found Whaling Boats that was not in city")
	end
	local sector = Rand(6, "hello") + 1
	local plotToImprove
	for radius = 1, gg_whalingRange[iPlayer] do
		for testPlot in PlotRingIterator(plot, radius, sector, false) do
			local iTestPlot = testPlot:GetPlotIndex()
			if gg_remoteImprovePlot[iTestPlot] == "WhalingRes" then
				local iOwner = testPlot:GetOwner()
				if iOwner == -1 then
					testPlot:SetOwner(iPlayer, city:GetID())
					plotToImprove = testPlot
					break
				elseif iOwner == iPlayer and testPlot:GetImprovementType() == -1 then
					plotToImprove = testPlot
					break
				end
				if radius < 4 then	--may steal plot if owner is remote
					local iOwningCity = testPlot:GetCityPurchaseID()
					local iPlotOwningCity = gg_playerCityPlotIndexes[iOwner][iOwningCity] or InitCityPlotIndexGlobals(iOwner, iOwningCity)		
					local ownerDist = GetMemoizedPlotIndexDistance(iTestPlot, iPlotOwningCity)
					if 3 < ownerDist then
						if iOwner == iPlayer then
							testPlot:SetOwner(iPlayer, city:GetID())	--transfer ownership to this city (should have happen elsewhere, but just in case)
						else
							testPlot:SetOwner(iPlayer, city:GetID())
							plotToImprove = testPlot		--steal from remote owner city
							break
						end				
					end
				end
			end
		end
	end
	if plotToImprove then
		plotToImprove:SetImprovementType(IMPROVEMENT_WHALING_BOATS)
	else
		print("!!!! Warning: Whaling Boats built but can't be used; killing unit")
	end
	MapModData.bBypassOnCanSaveUnit = true
	unit:Kill(true, -1)		--remove unit
end

--[[
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
]]


--sustained promotion system

SustainedPromotionDo[GameInfoTypes.PROMOTION_HEX] = function(player, unit, iCaster)
	local eaPerson = gPeople[iCaster]
	if not eaPerson then return false end	--caster died
	local mod = GetGPMod(iCaster, "EAMOD_CONJURATION", nil)
	if Rand(mod, "hello") == 0 then return false end	--1/mod chance to wear off each turn
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)		--wear off if caster has no more mana or divine favor
end

SustainedPromotionDo[GameInfoTypes.PROMOTION_BLESSED] = function(player, unit, iCaster)
	local eaPerson = gPeople[iCaster]
	if not eaPerson then return false end	--caster died
	local mod = GetGPMod(iCaster, "EAMOD_DEVOTION", "EAMOD_EVOCATION")
	if Rand(mod, "hello") == 0 then return false end	--1/mod chance to wear off each turn
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)		--wear off if caster has no more mana or divine favor
end

SustainedPromotionDo[GameInfoTypes.PROMOTION_PROTECTION_FROM_EVIL] = function(player, unit, iCaster)
	local eaPerson = gPeople[iCaster]
	if not eaPerson then return false end	--caster died
	local mod = GetGPMod(iCaster, "EAMOD_DEVOTION", "EAMOD_ABJURATION")
	if Rand(mod, "hello") == 0 then return false end	--1/mod chance to wear off each turn
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)		--wear off if caster has no more mana or divine favor
end

SustainedPromotionDo[GameInfoTypes.PROMOTION_CURSED] = function(player, unit, iCaster)
	local eaPerson = gPeople[iCaster]
	if not eaPerson then return false end	--caster died
	local mod = GetGPMod(iCaster, "EAMOD_DEVOTION", "EAMOD_ABJURATION")
	if Rand(mod, "hello") == 0 then return false end	--1/mod chance to wear off each turn
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)		--wear off if caster has no more mana or divine favor
end

SustainedPromotionDo[GameInfoTypes.PROMOTION_RIDE_LIKE_THE_WINDS] = function(player, unit, iCaster)
	local eaPerson = gPeople[iCaster]
	if not eaPerson then return false end	--caster died
	local mod = GetGPMod(iCaster, "EAMOD_DEVOTION", "EAMOD_CONJURATION")
	local caster = Players[eaPerson.iPlayer]:GetUnitByID(eaPerson.iUnit)
	if mod < PlotDistance(caster:GetX(), caster:GetY(), unit:GetX(), unit:GetY()) then return false end
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)
end

----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)