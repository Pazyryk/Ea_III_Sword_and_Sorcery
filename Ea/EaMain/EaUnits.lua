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
local RELIGION_CULT_OF_EPONA =						GameInfoTypes.RELIGION_CULT_OF_EPONA
local RESOURCE_CITRUS =								GameInfoTypes.RESOURCE_CITRUS
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
local bFullCivAI =					MapModData.bFullCivAI
local bHidden =						MapModData.bHidden
local realCivs =					MapModData.realCivs
local fullCivs =					MapModData.fullCivs
local cityStates =					MapModData.cityStates
local gg_bNormalCombatUnit =		gg_bNormalCombatUnit
local gg_combatPointDiff =			gg_combatPointDiff
local gg_unitPrefixUnitIDs =		gg_unitPrefixUnitIDs
local gg_cityLakesDistMatrix =		gg_cityLakesDistMatrix
local gg_cityFishingDistMatrix =	gg_cityFishingDistMatrix
local gg_cityWhalingDistMatrix =	gg_cityWhalingDistMatrix
local gg_cityCampResDistMatrix =	gg_cityCampResDistMatrix
local gg_fishingRange =				gg_fishingRange
local gg_whalingRange =				gg_whalingRange
local gg_campRange =				gg_campRange
local gg_eaSpecial =				gg_eaSpecial

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
			local newUnitType = StrSubstitute(unitType, fromStr, toStr)
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
	local bRemoveOceanBlock = bFullCiv and eaPlayer.eaCivNameID == EACIV_FOMHOIRE

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

		--Debug
		if unitTypeID == 0 then
			error("Found an ID=0 unit; most likely there was a player:UnitInit() with an invalid unitTypeID")
		end
		if unit:IsGreatPerson() and not unit:IsDelayedDeath() then
			local iPerson = unit:GetPersonIndex()
			if not gPeople[iPerson] then
				error("!!!! WARNING: Found an orphan GP; iPlayer, unitTypeID, iPlot = " .. iPlayer .. ", " .. GameInfo.Units[unitTypeID].Type .. ", " .. iPlot)
			end
		end

		--Stunned units lose movement one turn
		if unit:IsHasPromotion(PROMOTION_STUNNED) then
			unit:FinishMoves()
			unit:SetHasPromotion(PROMOTION_STUNNED, false)
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

			if gg_bNormalCombatUnit[unitTypeID] then
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
							baselineMoral = baselineMoral + Floor(unit:GetDamage() / 2)
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
			local distributeXP = Floor(eaPlayer.trainingXP / countCombatUnits)
			if 0 < distributeXP then
				print("Adding XP to combat units for Training Exercises Process and/or Militarism Finisher (#units / unitXP): ", countCombatUnits, distributeXP)
				for unit in player:Units() do
					local unitTypeID = unit:GetUnitType()
					if gg_bNormalCombatUnit[unitTypeID] then
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
				eaPerson.leaderLevel = Floor((Game.GetGameTurn() - eaPerson.assumedLeadershipTurn) / 20)	--intentional that this only updates w/ leveling (game interest and works better for mod caching)
			end
			eaPerson.level = unit:GetLevel()
			--eaPerson.promotions[promotionID] = true

			SetTowerMods(iPlayer, iPerson)
		end
		return true		--allow whatever human player picks
	else	--AI
		if iPerson ~= -1 then
			local eaPerson = gPeople[iPerson]
			promotionID = AIPickGPPromotion(iPlayer, iPerson, unit)
			if eaPerson.assumedLeadershipTurn then
				eaPerson.leaderLevel = Floor((Game.GetGameTurn() - eaPerson.assumedLeadershipTurn) / 20)
			end
			eaPerson.level = unit:GetLevel()
			--eaPerson.promotions[promotionID] = true

			SetTowerMods(iPlayer, iPerson)
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
	MapModData.bBypassOnCanSaveUnit = true
	unit:Kill(true, -1)		--remove fishing boats unit
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
	MapModData.bBypassOnCanSaveUnit = true
	unit:Kill(true, -1)		--remove whaling boats unit
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
	if mod < Distance(caster:GetX(), caster:GetY(), unit:GetX(), unit:GetY()) then return false end
	return UseManaOrDivineFavor(eaPerson.iPlayer, iCaster, 1)
end

----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)