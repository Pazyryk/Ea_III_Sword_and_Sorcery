-- EaDiplomacy
-- Author: Pazyryk
-- DateCreated: 2/1/2013 3:18:19 PM
--------------------------------------------------------------
-- Handles full civs only (including The Fay); minor civ adjustments handled in EaCivs.lua 


print("Loading EaDiplomacy.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

--constants
local FAY_PLAYER_INDEX =				FAY_PLAYER_INDEX
local STARTING_SUM_OF_ALL_MANA =		MapModData.STARTING_SUM_OF_ALL_MANA
local EARACE_MAN =						GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =					GameInfoTypes.EARACE_SIDHE
local EACIV_SKOGR =						GameInfoTypes.EACIV_SKOGR
local POLICY_BRANCH_DOMINIONISM =		GameInfoTypes.POLICY_BRANCH_DOMINIONISM
local POLICY_BRANCH_PANTHEISM =			GameInfoTypes.POLICY_BRANCH_PANTHEISM
local POLICY_BRANCH_THEISM =			GameInfoTypes.POLICY_BRANCH_THEISM
local POLICY_BRANCH_ANTI_THEISM =		GameInfoTypes.POLICY_BRANCH_ANTI_THEISM
local POLICY_BRANCH_SLAVERY =			GameInfoTypes.POLICY_BRANCH_SLAVERY
local TECH_MALEFICIUM =					GameInfoTypes.TECH_MALEFICIUM
local TECH_DIVINE_LITURGY =				GameInfoTypes.TECH_DIVINE_LITURGY
local RELIGION_AZZANDARAYASNA =			GameInfoTypes.RELIGION_AZZANDARAYASNA
local RELIGION_ANRA =					GameInfoTypes.RELIGION_ANRA

local gRaceDiploMatrix = gRaceDiploMatrix
local fullCivs = MapModData.fullCivs

--functions
local HandleError21 = HandleError21
local floor = math.floor
local Ln = math.log
local GetNumPoliciesInBranch = GetNumPoliciesInBranch

--file control
local g_yourKindPenalty = 0		--calculated in OnGetScenarioDiploModifier1; return value for OnGetScenarioDiploModifier2
local g_admirationBonus = 0		--calculated in OnGetScenarioDiploModifier1; return value for OnGetScenarioDiploModifier3

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------


--------------------------------------------------------------
-- Interface
--------------------------------------------------------------
function DiploPerCivTurn(iPlayer)	--full civs only

	local eaPlayer = gPlayers[iPlayer]
	if 0 < gWorld.armageddonStage and eaPlayer.manaConsumed and (eaPlayer.race == EARACE_MAN or eaPlayer.race == EARACE_SIDHE) then	--Heldeofol are already fully discounted for warmonger penalty, so can't get worse
		local iWarmongerDiscout = floor(300 * eaPlayer.manaConsumed / STARTING_SUM_OF_ALL_MANA)
		iWarmongerDiscout = iWarmongerDiscout < 100 and iWarmongerDiscout or 100
		print("SetWarmongerModifier; iPlayer, iWarmongerDiscout = ", iPlayer, iWarmongerDiscout)
		player:SetWarmongerModifier(iWarmongerDiscout)
	end
end

--------------------------------------------------------------
-- DiploModifier GameEvents
--------------------------------------------------------------
--Note: these 3 GameEvents are always called sequentially: 1, 2, 3. We take advantage of this to avoid duplicated calculations.
--Modifier1: "You are evil" combines hatred for the fallen and slavery
--Modifier2: "We do not like your kind" combines all other negatives including race, religion, policies, and city razing history
--Modifier3: "We admire your accomplishments" combines all positives including shared high culture, shared religion and some policy/tech positives

local function OnGetScenarioDiploModifier1(iPlayer1, iPlayer2)	--player2 is the "subject" (human or AI); player1 is the "observer" (always AI)
	Dprint("OnGetScenarioDiploModifier1 ", iPlayer1, iPlayer2)
	--Calculate all modifiers here; save values for OnGetScenarioDiploModifier2 and 3 in file locals
	--print("Diplomacy modifiers for player " .. iPlayer1 .. " toward player " .. iPlayer2 .. ":")

	local player1, player2 = Players[iPlayer1], Players[iPlayer2]
	local eaPlayer1, eaPlayer2 = gPlayers[iPlayer1], gPlayers[iPlayer2]
	local team2 = Teams[player2:GetTeam()]

	--diplo factors for subject (needed by all or most observers)
	local azzandarayasnaInteger = eaPlayer2.religionID == RELIGION_AZZANDARAYASNA and 1 or 0
	local anraInteger = eaPlayer2.religionID == RELIGION_ANRA and 1 or 0
	local pantheismPolicies = GetNumPoliciesInBranch(player2, POLICY_BRANCH_PANTHEISM)
	local theismPolicies = GetNumPoliciesInBranch(player2, POLICY_BRANCH_THEISM)
	local divineLiturgyTechs = team2:IsHasTech(TECH_DIVINE_LITURGY) and 1 or 0	--these will become counts later (when downstream are added)
	local maleficiumTechs = team2:IsHasTech(TECH_MALEFICIUM) and 1 or 0
	local manaEaterPts = 0
	if eaPlayer2.manaConsumed and 0 < gWorld.armageddonStage then
		manaEaterPts = 100 * eaPlayer2.manaConsumed / MapModData.STARTING_SUM_OF_ALL_MANA	--mod by observer class
	end

	--return value for OnGetScenarioDiploModifier1 (others use file locals)
	local evilPenalty = 0

	--diplo effects by observer category
	if eaPlayer1.religionID == RELIGION_AZZANDARAYASNA then										--observer is Azzandarayasna
		local fallenInteger = eaPlayer2.bIsFallen and 1 or 0
		local antiTheismPolicies = GetNumPoliciesInBranch(player2, POLICY_BRANCH_ANTI_THEISM)
		local thaumaturgyTechs = team2:IsHasTech(TECH_MALEFICIUM) and 1 or 0
		print("player1 is Azzandarayasna ", azzandarayasnaInteger,anraInteger,pantheismPolicies,theismPolicies,divineLiturgyTechs,maleficiumTechs,fallenInteger,antiTheismPolicies,thaumaturgyTechs)
		evilPenalty = 16 * anraInteger + 8 * fallenInteger + 4 * (antiTheismPolicies + maleficiumTechs) + 2 * manaEaterPts
		g_yourKindPenalty = thaumaturgyTechs + 2 * pantheismPolicies
		g_admirationBonus = 3 * azzandarayasnaInteger + theismPolicies + divineLiturgyTechs
	elseif eaPlayer1.religionID == RELIGION_ANRA then											--observer is Anra
		local fallenInteger = eaPlayer2.bIsFallen and 1 or 0
		local antiTheismPolicies = GetNumPoliciesInBranch(player2, POLICY_BRANCH_ANTI_THEISM)
		print("player1 is Anra ", azzandarayasnaInteger,anraInteger,pantheismPolicies,theismPolicies,divineLiturgyTechs,maleficiumTechs,fallenInteger,antiTheismPolicies)
		g_yourKindPenalty = 8 * azzandarayasnaInteger + 2 * (theismPolicies + divineLiturgyTechs) + pantheismPolicies
		g_admirationBonus = 3 * anraInteger + 0.5 * (antiTheismPolicies + fallenInteger + maleficiumTechs)
	elseif eaPlayer1.bIsFallen then																--observer is Fallen (not Anra)
		print("player1 is Fallen ", azzandarayasnaInteger,anraInteger,pantheismPolicies,theismPolicies,divineLiturgyTechs,maleficiumTechs)
		evilPenalty = 0.5 * manaEaterPts
		g_yourKindPenalty = 8 * azzandarayasnaInteger + 2 * (theismPolicies + divineLiturgyTechs) + 0.5 * pantheismPolicies
		g_admirationBonus = 0.5 * maleficiumTechs
	elseif player1:IsPolicyBranchUnlocked(POLICY_BRANCH_PANTHEISM) then							--observer is Pantheistic (not Anra or Fallen)
		local fallenInteger = eaPlayer2.bIsFallen and 1 or 0
		local antiTheismPolicies = GetNumPoliciesInBranch(player2, POLICY_BRANCH_ANTI_THEISM)
		local agPolicies = GetNumPoliciesInBranch(player2, POLICY_BRANCH_DOMINIONISM)
		print("player1 is Pantheistic ", azzandarayasnaInteger,anraInteger,pantheismPolicies,theismPolicies,divineLiturgyTechs,maleficiumTechs,fallenInteger,antiTheismPolicies,agPolicies)
		evilPenalty = 12 * anraInteger + 6 * fallenInteger + 2 * (antiTheismPolicies + maleficiumTechs + manaEaterPts)
		g_yourKindPenalty = 4 * azzandarayasnaInteger + agPolicies + theismPolicies + divineLiturgyTechs
		g_admirationBonus = pantheismPolicies
		if iPlayer1 == FAY_PLAYER_INDEX and eaPlayer2.faerieTribute then
			g_admirationBonus = g_admirationBonus + eaPlayer2.faerieTribute.ave
		end
	else																						--observer is none of the above
		local antiTheismPolicies = GetNumPoliciesInBranch(player2, POLICY_BRANCH_ANTI_THEISM)
		local thaumaturgyTechs = team2:IsHasTech(TECH_MALEFICIUM) and 1 or 0
		print("player1 is none of the above ", azzandarayasnaInteger,anraInteger,pantheismPolicies,theismPolicies,divineLiturgyTechs,maleficiumTechs,antiTheismPolicies,thaumaturgyTechs)
		evilPenalty = 8 * anraInteger + antiTheismPolicies + maleficiumTechs + 0.5 * manaEaterPts
		g_yourKindPenalty = 0.5 * (azzandarayasnaInteger + pantheismPolicies + theismPolicies + divineLiturgyTechs + thaumaturgyTechs)
		g_admirationBonus = 0
	end

	--slavery
	if player2:HasPolicy(POLICY_SLAVERY) and not eaPlayer1.bIsFallen then		--the Fallen never have "You are evil" feelings
		local slaveryPenalty = GetNumPoliciesInBranch(player2, POLICY_BRANCH_SLAVERY) - (3 * GetNumPoliciesInBranch(player1, POLICY_BRANCH_SLAVERY)) - 1
		slaveryPenalty = slaveryPenalty < 0 and 0 or slaveryPenalty
		evilPenalty = evilPenalty + slaveryPenalty
	end

	--racial adjustments
	g_yourKindPenalty = floor(g_yourKindPenalty + gRaceDiploMatrix[eaPlayer1.race][eaPlayer2.race])
	if iPlayer1 == FAY_PLAYER_INDEX and eaPlayer2.eaCivNameID == EACIV_SKOGR then
		g_yourKindPenalty = g_yourKindPenalty - 2		--negates normal penalty for Man from The Fay
	end

	--high culture admiration for high culture
	g_admirationBonus = floor(g_admirationBonus + eaPlayer2.culturalLevel * Ln(eaPlayer1.culturalLevel) / 10)
	g_admirationBonus = g_admirationBonus < 0 and 0 or g_admirationBonus

	evilPenalty = floor(evilPenalty)

	print("DiploModifier1: You are evil: ", iPlayer1, iPlayer2, evilPenalty)

	return evilPenalty
end
GameEvents.GetScenarioDiploModifier1.Add(OnGetScenarioDiploModifier1)

local function OnGetScenarioDiploModifier2(iPlayer1, iPlayer2)
	print("DiploModifier2: We don't like your kind: ", iPlayer1, iPlayer2, g_yourKindPenalty)
	return g_yourKindPenalty
end
GameEvents.GetScenarioDiploModifier2.Add(OnGetScenarioDiploModifier2)

local function OnGetScenarioDiploModifier3(iPlayer1, iPlayer2)
	print("DiploModifier3: We admire your accomplishments: ", iPlayer1, iPlayer2, g_admirationBonus)
	return -g_admirationBonus
end
GameEvents.GetScenarioDiploModifier3.Add(OnGetScenarioDiploModifier3)


local function OnCanContactMajorTeam(iTeam1, iTeam2)
	--Both must have leaders; for now, assume one player per team		--TO DO: Change this GameEvents to player rather than team
	for iPlayer, eaPlayer in pairs(fullCivs) do
		local player = Players[iPlayer]
		local iTeam = player:GetTeam()
		if iTeam == iTeam1 or iTeam == iTeam2 then
			if player:GetLeaderType() < GameInfoTypes.LEADER_FAND then	--don't have leader right now
				print("OnCanContactMajorTeam ", iTeam1, iTeam2, "returning: ", false)
				return false
			end
		end
	end
	print("OnCanContactMajorTeam ", iTeam1, iTeam2, "returning: ", true)
	return true
end
GameEvents.CanContactMajorTeam.Add(OnCanContactMajorTeam) --new Ea API