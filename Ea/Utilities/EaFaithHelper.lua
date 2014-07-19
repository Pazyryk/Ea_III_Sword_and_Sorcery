-- EaFaithHelper
-- Author: Pazyryk
-- DateCreated: 6/30/2013 9:07:26 AM
--------------------------------------------------------------
-- Calculates certain faith yields (i.e., mana or divine favor) for FullCivPerCivTurn and Top Panel UI

local MapModData = MapModData
MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

--constants
local POLICY_PANTHEISM_FINISHER =				GameInfoTypes.POLICY_PANTHEISM_FINISHER
local POLICY_THEISM_FINISHER =					GameInfoTypes.POLICY_THEISM_FINISHER
local POLICY_ANTI_THEISM_FINISHER =				GameInfoTypes.POLICY_ANTI_THEISM_FINISHER
local POLICY_ARCANA_FINISHER =					GameInfoTypes.POLICY_ARCANA_FINISHER


--localized tables and functions
local Players = Players
local floor = math.floor


MapModData.faithFromCityStates = 0
MapModData.faithFromGPs = 0
MapModData.faithFromAzzTribute = 0


function GetTotalFaithPerTurnForUI(iPlayer)
	--print("PazDebug GetTotalFaithPerTurnForUI")
	local player = Players[iPlayer]
	local eaPlayer = gT.gPlayers[iPlayer]
	if not eaPlayer then return end

	--copy from TopPanel.lua FaithTipHandler()
	local faithFromCities = player:GetFaithPerTurnFromCities()
	local faithFromGods = player:GetFaithPerTurnFromMinorCivs()	--game engine only sees this from Gods
	local faithFromReligion = player:GetFaithPerTurnFromReligion()				--for Azz and Anra only since these use base follower counting mechanism
	local faithFromLeader = player:GetLeaderYieldBoost(GameInfoTypes.YIELD_FAITH) * (faithFromGods + faithFromReligion) / 100
	local manaForCultOfLeavesFounder = eaPlayer.manaForCultOfLeavesFounder or 0
	local manaForCultOfAbzuFounder = eaPlayer.manaForCultOfAbzuFounder or 0
	local manaForCultOfAegirFounder = eaPlayer.manaForCultOfAegirFounder or 0
	local manaForCultOfPloutonFounder = eaPlayer.manaForCultOfPloutonFounder or 0
	local manaForCultOfCahraFounder = eaPlayer.manaForCultOfCahraFounder or 0
	local manaForCultOfEponaFounder = eaPlayer.manaForCultOfEponaFounder or 0
	local manaForCultOfBakkheiaFounder = eaPlayer.manaForCultOfBakkheiaFounder or 0
	local manaFromWildlands = eaPlayer.cultureManaFromWildlands or 0
	local faithFromCityStates = MapModData.faithFromCityStates
	local faithFromAzzTribute = MapModData.faithFromAzzTribute
	local faithFromToAhrimanTribute = MapModData.faithFromToAhrimanTribute
	local faithFromGPs = MapModData.faithFromGPs
	local faithFromFinishedPolicyBranches = GetFaithFromPolicyFinisher(player)
	local faithRate = faithFromCities + faithFromGods + faithFromReligion + faithFromLeader + manaForCultOfLeavesFounder + manaForCultOfAbzuFounder + manaForCultOfAegirFounder + manaForCultOfPloutonFounder + manaForCultOfCahraFounder + manaForCultOfEponaFounder + manaForCultOfBakkheiaFounder + manaFromWildlands + faithFromCityStates + faithFromAzzTribute + faithFromGPs + faithFromFinishedPolicyBranches

	return faithRate

	--return player:GetTotalFaithPerTurn() + (eaPlayer.cultureManaFromWildlands or 0) + GetFaithFromPolicyFinisher(player) + MapModData.faithFromCityStates + MapModData.faithFromGPs + MapModData.faithFromAzzTribute
end

function GetFaithFromPolicyFinisher(player)
	local faithFinishers = 0
	if player:HasPolicy(POLICY_PANTHEISM_FINISHER) or player:HasPolicy(POLICY_THEISM_FINISHER) or player:HasPolicy(POLICY_ANTI_THEISM_FINISHER) then
		faithFinishers = 1		
	end
	if player:HasPolicy(POLICY_ARCANA_FINISHER) then
		faithFinishers = faithFinishers + 1		
	end
	if 0 < faithFinishers then
		return floor(faithFinishers * player:GetTotalJONSCulturePerTurn() / 3)
	else
		return 0
	end
end



--need faith notification for individual CSs