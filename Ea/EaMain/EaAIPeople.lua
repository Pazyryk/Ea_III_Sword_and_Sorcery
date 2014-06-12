-- EaAIPeople
-- Author: Pazyryk
-- DateCreated: 1/17/2013 6:27:36 PM
--------------------------------------------------------------
print("Loading EaAIPeople.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- Local Defines
--------------------------------------------------------------

local EAMOD_LEADERSHIP =					GameInfoTypes.EAMOD_LEADERSHIP

local FIRST_SPELL_ID =						FIRST_SPELL_ID
local LAST_SPELL_ID =						LAST_SPELL_ID

local Rand = Map.Rand


--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------
local sortedMods = {}
for modInfo in GameInfo.EaModifiers() do
	if modInfo.Type ~= "EAMOD_LEADERSHIP" then
		sortedMods[modInfo.ID] = modInfo.ID
	end
end

local spellList = {}

function AIPickGPPromotion(iPlayer, iPerson, unit)
	print("Running AIPickGPPromotion ", iPlayer, iPerson, unit)
	local eaPerson = gPeople[iPerson]

	--AI GP wants to match promotion progress to modMemory, so 3:1:0 past mod use matches 3:1:0 promotion level
	
	--local bIsLeader = iPerson == gPlayers[iPlayer].leaderEaPersonIndex 

	local modMemory = eaPerson.modMemory
	table.sort(sortedMods, function(idA, idB) return (modMemory[idB] or 0) < (modMemory[idA] or 0) end)		--sort modIDs by this person's modMemory, highest to lowest
	local i = 2
	local id1 = sortedMods[1]
	local id2 = sortedMods[2]
	local mem1 = (modMemory[id1] or 0)
	local mem2 = (modMemory[id2] or 0)
	local promoPrefix1 = GameInfo.EaModifiers[id1].PromotionPrefix
	local promoPrefix2 = GameInfo.EaModifiers[id2].PromotionPrefix
	local level1 = GetHighestPromotionLevel(promoPrefix1, nil, iPerson)
	local level2 = GetHighestPromotionLevel(promoPrefix2, nil, iPerson)
	print("ModMemory; id, value, promoPrefix, currentLevel:")
	print("   -", id1, mem1, promoPrefix1, level1)

	while 0 < mem1 do
		print("   -", id2, mem2, promoPrefix2, level2)
		if level1 / (level2 + 1) < mem1 / (mem2 + 1) and level1 < 18 then		--promo levels need to catch up with modMemory values
			local nextPromoType = promoPrefix1 .. "_" .. (level1 + 1)
			local promoID = GameInfoTypes[nextPromoType]
			if promoID then
				if unit:CanAcquirePromotion(promoID) then
					print("AI taking promotion ", nextPromoType)
					unit:SetHasPromotion(promoID, true)
					eaPerson[promoPrefix1] = level1 + 1
					return
				else
					print("!!!! WARNING: GP not able to take best promotion based on modMemory: ", nextPromoType)
				end
			else
				error("No promoID for " .. (nextPromoType))
			end
		end
		mem1, promoPrefix1, level1 = mem2, promoPrefix2, level2
		i = i + 1
		id2 = sortedMods[i]
		mem2 = (modMemory[id2] or 0)
		promoPrefix2 = GameInfo.EaModifiers[id2].PromotionPrefix
		level2 = GetHighestPromotionLevel(promoPrefix2, nil, iPerson)
	end

	print("!!!! WARNING: GP did not gain any promotion from modMemory algorithm; picking first that can be acquired")
	for promoInfo in GameInfo.UnitPromotions() do
		if unit:CanAcquirePromotion(promoInfo.ID) then
			print("AI taking promotion ", promoInfo.Type)
			unit:SetHasPromotion(promoInfo.ID, true)
			local prefix, level = GetPromoPrefixLevelFromType(promoInfo.Type)
			if prefix then
				eaPerson[prefix] = level
			end
			return
		end
	end

	error("AI had no valid promotions to select")		--TO DO: Change this to warning after debuging (with 18 promo levels it should not happen for a long time)

end


