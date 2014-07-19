-- EaAIMercenaries
-- Author: Pazyryk
-- DateCreated: 5/17/2013 9:35:43 PM
--------------------------------------------------------------

print("Loading EaAIMercenaries.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--CS merc:	peace no threat, sell all; war or threat, keep 4; war and threat, keep all
--CS non-merc: buy up to 3 (peace) or 6 (war) if can afford it
--Full civ: mil civs always sell

--pPlayer:GetMilitaryMight() / pPlayer:GetScore()
--use might/score ratio?

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------
--constants
local POLICY_MERCENARIES =						GameInfoTypes.POLICY_MERCENARIES
local MINOR_TRAIT_MERCENARY =					GameInfoTypes.MINOR_TRAIT_MERCENARY
local PROMOTION_FOR_HIRE =						GameInfoTypes.PROMOTION_FOR_HIRE
local PROMOTION_MERCENARY =						GameInfoTypes.PROMOTION_MERCENARY
local PROMOTION_STRONG_MERCENARY_INACTIVE =		GameInfoTypes.PROMOTION_STRONG_MERCENARY_INACTIVE
local PROMOTION_STRONG_MERCENARY =				GameInfoTypes.PROMOTION_STRONG_MERCENARY
local PROMOTION_SLAVE =							GameInfoTypes.PROMOTION_SLAVE


local UNIT_WARRIORS =							GameInfoTypes.UNIT_WARRIORS
local UNIT_SCOUTS =								GameInfoTypes.UNIT_SCOUTS

--shared
local realCivs =			MapModData.realCivs
local fullCivs =			MapModData.fullCivs
local cityStates =			MapModData.cityStates
local gg_unitClusters =		gg_unitClusters
local gg_mercHireRate =		gg_mercHireRate
local gg_bToCheapToHire =	gg_bToCheapToHire

--localized functions
local floor = math.floor
local PlotDistance = Map.PlotDistance
local sort = table.sort

--file control
local g_relativeMight = {}
local g_mercsForHire = {}
local g_strategicResourceCount = {}
local g_mercDisbandConsideration = {}	--holds units
local g_mercSortingScore = {}			--consider disbanding low score first
setmetatable(g_mercSortingScore, WeakKeyMetatable)
local g_mercGPT = {}
setmetatable(g_mercGPT, WeakKeyMetatable)
local g_mercModDistTable = {}						--index by unit, holds discout corrected distance
setmetatable(g_mercModDistTable, WeakKeyMetatable)	--weak keys so table field is garbage collected after unit removed from game
local g_mercDiscountTable = {}					
setmetatable(g_mercDiscountTable, WeakKeyMetatable)

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------
local unitResourceReq = {}
local stategicResources = {}
local numStrategicResources = 0
for row in GameInfo.Unit_ResourceQuantityRequirements() do
	local unitTypeID = GameInfoTypes[row.UnitType]
	local resourceID = GameInfoTypes[row.ResourceType]
	unitResourceReq[unitTypeID] = unitResourceReq[unitTypeID] or {}
	local index = #unitResourceReq[unitTypeID] + 1
	unitResourceReq[unitTypeID][index] = resourceID
	local bAddStrategic = true
	for i = 1, numStrategicResources do
		if stategicResources[i] == resourceID then
			bAddStrategic = false
			break
		end
	end
	if bAddStrategic then
		numStrategicResources = numStrategicResources + 1
		stategicResources[numStrategicResources] = resourceID
	end
end

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------
function AIMercInit(bNewGame)
	for iPlayer, eaPlayer in pairs(realCivs) do
		local player = Players[iPlayer]
		if fullCivs[iPlayer] then
			local eaNameTrait = eaPlayer.eaCivNameID
			gg_mercHireRate[iPlayer] = eaNameTrait and GameInfo.EaCivs[eaNameTrait].AIMercHire or 0
		else
			local minorCivID = player:GetMinorCivType()
			gg_mercHireRate[iPlayer] = GameInfo.MinorCivilizations[minorCivID].EaMercHire
		end
	end
	AIMercenaryPerGameTurn()
end


function AIMercenaryPerGameTurn()
	print("AIMercenaryPerGameTurn assessing player relative might (iPlayer / relMight):")
	local fullCivMight, cityStateMight, numFullCivs, numCityStates = 0, 0, 0, 0
	for iPlayer, eaPlayer in pairs(realCivs) do
		local player = Players[iPlayer]
		if fullCivs[iPlayer] then
			numFullCivs = numFullCivs + 1
			local might = player:GetMilitaryMight() / player:GetScoreFromPopulation()		--relative to pop so big civ needs more military
			fullCivMight = fullCivMight + might
			g_relativeMight[iPlayer] = might
		else
			numCityStates = numCityStates + 1
			local might = player:GetMilitaryMight()
			cityStateMight = cityStateMight + might
			g_relativeMight[iPlayer] = might
		end
	end
	for iPlayer in pairs(g_relativeMight) do
		if not realCivs[iPlayer] then
			g_relativeMight[iPlayer] = nil		--clear out dead civs
		end
	end
	fullCivMight = fullCivMight / numFullCivs
	cityStateMight = cityStateMight / numCityStates
	for iPlayer, eaPlayer in pairs(realCivs) do
		local relMight = g_relativeMight[iPlayer]
		if 0 < relMight then
			if fullCivs[iPlayer] then
				g_relativeMight[iPlayer] = relMight / fullCivMight
			else
				g_relativeMight[iPlayer] = relMight / cityStateMight
			end
		end
		print(iPlayer, g_relativeMight[iPlayer])
	end
end



function AIMercenaryPerCivTurn(iPlayer)					--controls hiring and putting up for hire by CSs and Full Civs
	print("Running AIMercenaryPerCivTurn", iPlayer)
	local player = Players[iPlayer]
	local mercHire = gg_mercHireRate[iPlayer]

	if mercHire < 0 then	--supplier
		if fullCivs[iPlayer] and not player:HasPolicy(POLICY_MERCENARIES) then return end
		local relMight = g_relativeMight[iPlayer]
		if 0.5 < relMight then				--must be half-strength of average to consider
			for iPlayer, clusters in pairs(gg_unitClusters) do
				for i = 1, #clusters do
					local cluster = clusters[i]
					if cluster.iPlayerTarget == iPlayer then
						if cluster.intent == "Hostile" then
							print("CS detects hostile unit cluster")
							relMight = 0
							break
						elseif cluster.intent == "PossibleSneak" then
							print("CS detects possible sneak unit cluster")
							relMight = relMight - 0.5
						end
					end
				end
				if relMight < 0.5 then break end
			end
		end
		local numToHireOut = 0.5 < relMight and floor(player:GetNumMilitaryUnits() * (relMight - 0.5)) or 0		--put units up for hire to 1/2 ave city state might
		print("Merc supplier putting units up for hire; number = ", numToHireOut)
		local numForHire = 0
		for unit in player:Units() do
			if unit:IsCombatUnit() and not unit:IsHasPromotion(PROMOTION_SLAVE) and not unit:IsHasPromotion(PROMOTION_MERCENARY) then	--slave may have been gifted
				local unitTypeID = unit:GetUnitType()
				if not gg_bToCheapToHire[unitTypeID] then
					if numForHire < numToHireOut then
						numForHire = numForHire + 1
						unit:SetHasPromotion(PROMOTION_FOR_HIRE, true)
					else
						unit:SetHasPromotion(PROMOTION_FOR_HIRE, false)
					end
				end
			end
		end
	elseif 0 < mercHire then	--user
		local totalGold = player:GetGold()
		for i = 1, numStrategicResources do
			local resourceID = stategicResources[i]
			g_strategicResourceCount[resourceID] = player:GetNumResourceAvailable(resourceID, true)
		end

		if mercHire < totalGold then				--mercHire sets the minimum treasury value needed to consider hiring mercs
			local totalGPT = player:CalculateGoldRate()
			if 5 < totalGPT then
				local relMight = g_relativeMight[iPlayer]
				local bHostile, bSneak = false, false
				if relMight < 2 then				--adj relMight if there is a threat
					for iPlayer, clusters in pairs(gg_unitClusters) do
						for i = 1, #clusters do
							local cluster = clusters[i]
							if cluster.iPlayerTarget == iPlayer then
								if cluster.intent == "Hostile" then
									print("Civ detects hostile unit cluster")
									bHostile = true
									break
								elseif cluster.intent == "PossibleSneak" then
									print("Civ detects possible sneak unit cluster")
									bSneak = true
								end
							end
						end
						if bHostile then break end
					end
				end
				relMight = bHostile and relMight / 2 or (bSneak and relMight / 1.5 or relMight)
				if relMight < 1 then
					print("Merc user feels need for mercs; adjusted relative might = ", relMight)
					--find available for hire and sort by distance (modified by discount) only if within 10 plots	NEED PATH CHECK HERE !!!!
					local capital = player:GetCapitalCity()
					local numMercs = AISetAvailableMercenariesForHire(iPlayer, capital:GetX(), capital:GetY(), 10)		--sorted table to specified distance (nil if none)
					if 0 < numMercs then
						--try to hire to get us to might parity
						local might = player:GetMilitaryMight()
						local targetMight = might / relMight
						local i = 0
						while i < numMercs do
							i = i + 1
							local unit = g_mercsForHire[i]
							local discountLevel = g_mercDiscountTable[unit]
							local _, upFront, gpt = GetMercenaryCosts(unit, nil, discountLevel)	

							if upFront < totalGold and gpt < totalGPT then
								local bHasResourceReq = true
								local unitTypeID = unit:GetUnitType()
								local resourceReq = unitResourceReq[unitTypeID]
								if resourceReq then
									for j = 1, #resourceReq do
										local resourceID = resourceReq[j]
										if g_strategicResourceCount[resourceID] < 2 then	--keep one to spare
											bHasResourceReq = false
											break
										end
									end
								end
								if bHasResourceReq then
									HireMercenary(iPlayer, unit, upFront, gpt)
									totalGold = totalGold - upFront
									totalGPT = totalGPT - gpt
									if totalGold < 100 or totalGPT < 3 then break end		--quit hiring before we bottom out
									might = player:GetMilitaryMight()
									if might >= targetMight then break end
								end
							end
						end
					end
				end
			end
		end
		--consider disbanding
		local mercenaries = gPlayers[iPlayer].mercenaries
		if next(mercenaries) ~= nil then
			print("Player has mercenaries; testing dismiss conditions")
			local gptShortfall = totalGold < 100 and -player:CalculateGoldRate() or 0	-- 0 or negative will be ignored
			local bResourceShortfall = false
			for resourceID, quantity in pairs(g_strategicResourceCount) do
				if quantity < 0 then
					bResourceShortfall = true
					break
				end
			end
			if bResourceShortfall or 0 < gptShortfall then
				print("Player lacking resource or gold", bResourceShortfall, gptShortfall)
				local disbandConsiderNum = 0
				for iOriginalOwner, mercs in pairs(mercenaries) do
					for iUnit, gpt in pairs(mercs) do
						local unit = player:GetUnitByID(iUnit)
						if unit then
							disbandConsiderNum = disbandConsiderNum + 1
							g_mercDisbandConsideration[disbandConsiderNum] = unit
							g_mercSortingScore[unit] = unit:GetExperience() + (unit:IsHasPromotion(PROMOTION_STRONG_MERCENARY) and 100 or 0)
							g_mercGPT[unit] = gpt
						else
							mercs[iUnit] = nil
							if next(mercs) == nil then
								mercenaries[iOriginalOwner] = nil
							end
						end
					end
				end
				print("Number mercs found = ", disbandConsiderNum)
				if 0 < disbandConsiderNum then
					for i = #g_mercDisbandConsideration, disbandConsiderNum + 1, -1 do
						g_mercDisbandConsideration = nil
					end
					sort(g_mercDisbandConsideration, function(a, b) return g_mercSortingScore[a] < g_mercSortingScore[b] end)	--low score first
					--Disband by resource first (if that is a problem), then gpt
					if bResourceShortfall then
						for i = 1, disbandConsiderNum do
							local unit = g_mercDisbandConsideration[i]
							local unitTypeID = unit:GetUnitType()
							local resourceReq = unitResourceReq[unitTypeID]
							if resourceReq then
								for j = 1, #resourceReq do
									local resourceID = resourceReq[j]
									if g_strategicResourceCount[resourceID] < 0 then
										print("Dismissing mercenary due to resource shortfall (unitTypeID/resourceID/quantity)", unitTypeID, resourceID, g_strategicResourceCount[resourceID])
										gptShortfall = gptShortfall - g_mercGPT[unit]
										local iUnit = unit:GetID()
										DismissMercenary(iPlayer, iUnit)
										for k = 1, #resourceReq do
											local loopResourceID = resourceReq[k]
											g_strategicResourceCount[loopResourceID] = g_strategicResourceCount[loopResourceID] + 1
										end
										break
									end
								end
							end
						end
					end
					if 0 < gptShortfall then
						for i = 1, disbandConsiderNum do
							local unit = g_mercDisbandConsideration[i]
							local gpt = g_mercGPT[unit]
							print("Dismissing mercenary due to gpt shortfall (unitTypeID/mercGPT/gptShorfall)", unitTypeID, gpt, gptShortfall)
							gptShortfall = gptShortfall - gpt
							local iUnit = unit:GetID()
							DismissMercenary(iPlayer, iUnit)
							if gptShortfall <= 0 then break end
						end
					end
				end
			end
		end
	end
end





function AISetAvailableMercenariesForHire(iPlayer, x, y, maxDist)
	local player = Players[iPlayer]
	local bHasMercPolicy = not cityStates[iPlayer] and player:HasPolicy(POLICY_MERCENARIES)
	local numMercs = 0
	for iLoopPlayer, eaLoopPlayer in pairs(realCivs) do
		local loopPlayer = Players[iLoopPlayer]
		local bMayHaveMercs = false
		local discountLevel = 0
		if fullCivs[iLoopPlayer] then
			if loopPlayer:HasPolicy(POLICY_MERCENARIES) then
				if cityStates[iPlayer] then
					bMayHaveMercs = true
				else
					if bHasMercPolicy then
						bMayHaveMercs = true
						if player:IsFriends(iLoopPlayer) then
							discountLevel = 1
						end
					elseif player:IsFriends(iLoopPlayer) then
						bMayHaveMercs = true
					end
				end
			end
		elseif loopPlayer:GetMinorCivTrait() == MINOR_TRAIT_MERCENARY then
			if cityStates[iPlayer] then
				bMayHaveMercs = true
			else
				if bHasMercPolicy then
					bMayHaveMercs = true
					if loopPlayer:GetAlly() == iPlayer then
						discountLevel = 2
					elseif loopPlayer:IsFriends(iPlayer) then
						discountLevel = 1
					end
				elseif loopPlayer:IsFriends(iPlayer) then
					bMayHaveMercs = true
				end
			end
		end
		if bMayHaveMercs then
			for unit in loopPlayer:Units() do
				if unit:IsHasPromotion(PROMOTION_FOR_HIRE) then
					local dist = PlotDistance(x, y, unit:GetX(), unit:GetY())
					if dist <= maxDist then
						numMercs = numMercs + 1
						g_mercsForHire[numMercs] = unit
						g_mercModDistTable[unit] = dist * (1 - (0.3 * discountLevel) - (unit:IsHasPromotion(PROMOTION_STRONG_MERCENARY_INACTIVE) and 0.35 or 0))
						g_mercDiscountTable[unit] = discountLevel
					end
				end
			end
		end
	end
	print("AIGetMercenariesForHire number mercs found: ", numMercs)
	if numMercs == 0 then
		return 0		--won't access table in this case so no reason to clean up
	end
	for i = #g_mercsForHire, numMercs + 1, -1 do
		g_mercsForHire[i] = nil
	end

	sort(g_mercsForHire, function(a, b) return g_mercModDistTable[a] < g_mercModDistTable[b] end)

	return numMercs
end
