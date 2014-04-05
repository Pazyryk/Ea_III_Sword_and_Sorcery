-- Policies
-- Author: Pazyryk
-- DateCreated: 6/28/2012 8:41:16 AM
--------------------------------------------------------------

print("Loading EaPolicies.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

-- Cultural Level settings in EaCultureLevelHelper.lua

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

--constants
local EARACE_MAN =					GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =				GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =			GameInfoTypes.EARACE_HELDEOFOL

local POLICY_BRANCH_PANTHEISM =		GameInfoTypes.POLICY_BRANCH_PANTHEISM
local POLICY_BRANCH_THEISM =		GameInfoTypes.POLICY_BRANCH_THEISM
local POLICY_BRANCH_ANTI_THEISM =	GameInfoTypes.POLICY_BRANCH_ANTI_THEISM
local POLICY_BRANCH_ARCANA =		GameInfoTypes.POLICY_BRANCH_ARCANA
local POLICY_BRANCH_SLAVERY =		GameInfoTypes.POLICY_BRANCH_SLAVERY
local POLICY_BRANCH_MILITARISM =	GameInfoTypes.POLICY_BRANCH_MILITARISM
local POLICY_BRANCH_COMMERCE =		GameInfoTypes.POLICY_BRANCH_COMMERCE
local POLICY_BRANCH_TRADITION =		GameInfoTypes.POLICY_BRANCH_TRADITION

local POLICY_ARCANE_ELITE =			GameInfoTypes.POLICY_ARCANE_ELITE
local POLICY_SLAVE_RAIDERS =		GameInfoTypes.POLICY_SLAVE_RAIDERS
local POLICY_SLAVE_ARMIES =			GameInfoTypes.POLICY_SLAVE_ARMIES

local RELIGION_AZZANDARAYASNA =		GameInfoTypes.RELIGION_AZZANDARAYASNA
local RELIGION_THE_WEAVE_OF_EA =	GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
local TECH_SLAVERY =				GameInfoTypes.TECH_SLAVERY
local TECH_SLAVE_RAIDERS =			GameInfoTypes.TECH_SLAVE_RAIDERS
local TECH_SLAVE_ARMIES =			GameInfoTypes.TECH_SLAVE_ARMIES

local EACIV_SKOGR =					GameInfoTypes.EACIV_SKOGR
local EACIV_ERIU =					GameInfoTypes.EACIV_ERIU
local EACIV_NEMEDIA =				GameInfoTypes.EACIV_NEMEDIA
local EACIV_MOR =					GameInfoTypes.EACIV_MOR
local EACIV_MORD = 					GameInfoTypes.EACIV_MORD
local EACIV_PARTHOLON =				GameInfoTypes.EACIV_PARTHOLON
local EACIV_FODLA =					GameInfoTypes.EACIV_FODLA
local EACIV_THEANON =				GameInfoTypes.EACIV_THEANON
local EACIV_AES_DANA =				GameInfoTypes.EACIV_AES_DANA

--localized game and global tables
local Players =						Players
local Teams =						Teams
local gPlayers =					gPlayers
local gEpics =						gEpics
local bFullCivAI =					MapModData.bFullCivAI
local fullCivs =					MapModData.fullCivs
local cityStates =					MapModData.cityStates
local gg_animalSpawnInhibitTeams =	gg_animalSpawnInhibitTeams
local gg_slaveryPlayer =			gg_slaveryPlayer

--localized game and library functions
local Floor = math.floor

--localized global functions
local HandleError21 =	HandleError21

--file functions
local PolicyBranchReq = {}
local OnPolicyAdopted = {}

--file shared


--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------
local policiesByBranch = {}
for policyInfo in GameInfo.Policies() do
	local branchType = policyInfo.PolicyBranchType
	if branchType then
		local branchID = GameInfoTypes[branchType]
		policiesByBranch[branchID] = policiesByBranch[branchID] or {}
		local nextIndex = #policiesByBranch[branchID] + 1
		policiesByBranch[branchID][nextIndex] = policyInfo.ID
	end
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaPoliciesInit(bNewGame)
	print("Running EaPoliciesInit...")
	if bNewGame then
		for iPlayer, eaPlayer in pairs(fullCivs) do
			local player = Players[0]
			player:SetHasPolicy(GameInfoTypes.POLICY_ALL_FULL_CIVS, true)
			NRArrayAdd(gg_animalSpawnInhibitTeams, player:GetTeam())
		end
	else
		for iPlayer, eaPlayer in pairs(fullCivs) do
			local player = Players[iPlayer]
			if player:HasPolicy(GameInfoTypes.POLICY_PATRONAGE) then
				gg_bHasPatronage[iPlayer] = true
			end
			if player:HasPolicy(GameInfoTypes.POLICY_PANTHEISM) then
				local iTeam = player:GetTeam()
				gg_teamCanMeetGods[iTeam] = true
				if player:HasPolicy(GameInfoTypes.POLICY_THROUGH_THE_VEIL) then
					gg_teamCanMeetFay[iTeam] = true
				end
			end
			if not player:HasPolicy(GameInfoTypes.POLICY_FERAL_BOND) then
				NRArrayAdd(gg_animalSpawnInhibitTeams, player:GetTeam())
			end
			if player:HasPolicy(GameInfoTypes.POLICY_SLAVERY) then
				gg_slaveryPlayer[iPlayer] = true
			end
		end
	end
	for iPlayer, eaPlayer in pairs(cityStates) do
		local player = Players[iPlayer]
		if player:GetMinorCivTrait() == GameInfoTypes.MINOR_TRAIT_SLAVERS then
			gg_slaveryPlayer[iPlayer] = true
		end
	end
end

--gg_teamCanMeetGods = {}
--gg_teamCanMeetFay = {}

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------
function GetNumPoliciesInBranch(player, policyBranchID)		-- includes opener and finisher
	if not player:IsPolicyBranchUnlocked(policyBranchID) then
		return 0
	end
	local n = player:IsPolicyBranchFinished(policyBranchID) and 2 or 1
	local policies = policiesByBranch[policyBranchID]
	for i = 1, #policies do
		local policyID = policies[i]
		if player:HasPolicy(policyID) then
			n = n + 1
		end
	end
	return n
end


function PolicyPerCivTurn(iPlayer)
	print("PolicyPerCivTurn ", iPlayer)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]

	if player:HasPolicy(POLICY_ARCANE_ELITE) then
		eaPlayer.classPoints[7] = eaPlayer.classPoints[7] + 5	--Thaumaturge
	end

	UpdateCulturalLevel(iPlayer, eaPlayer)

	print("Level / policies / change / pop turns: ", eaPlayer.culturalLevel, eaPlayer.policyCount, eaPlayer.culturalLevelChange, eaPlayer.cumPopTurns)

	print("Test; eaPlayer.policyCount, GetNumPolicies, GetNumPolicyBranchesFinished = ", eaPlayer.policyCount, player:GetNumPolicies(), player:GetNumPolicyBranchesFinished())

	if eaPlayer.policyCount < Floor(eaPlayer.culturalLevel) then
		if bFullCivAI[iPlayer] then
			AIPickPolicy(iPlayer)
		else
			player:ChangeNumFreePolicies(1)
		end
		eaPlayer.policyCount = eaPlayer.policyCount + 1
	end
end

function OnPlayerAdoptPolicyBranch(iPlayer, policyBranchTypeID)					--called by EaAICiv.lua for AI
	print("Running OnPlayerAdoptPolicyBranch", iPlayer, policyBranchTypeID)

	--g_policyBranchOpened = policyBranchTypeID
	--g_iPlayer = iPlayer
	--g_turn = Game.GetGameTurn()

	--change everything to delayed effect (as for policies below) and function calls

	if policyBranchTypeID == POLICY_BRANCH_THEISM then
		local eaPlayer = gPlayers[iPlayer]
		if eaPlayer.religionID == -1 or eaPlayer.religionID == RELIGION_AZZANDARAYASNA then
			SetDivineFavorUse(iPlayer, true)		--provisionally allowed for non-relgious civ; will be reversed if any other religion becomes dominent
		end

	elseif policyBranchTypeID == POLICY_BRANCH_PANTHEISM then
		local player = Players[iPlayer]
		local iTeam = player:GetTeam()
		local team = Teams[iTeam]
		local eaPlayer = gPlayers[iPlayer]
		local capital = player:GetCapitalCity()
		--Religion
		if gReligions[RELIGION_THE_WEAVE_OF_EA] then
			if capital then
				capital:ConvertPercentFollowers(RELIGION_THE_WEAVE_OF_EA, -1, 80)	--convert 80% of atheists to this religion
			end
		else
			
			--error("The Weave of Ea wasn't already founded")
			iCapitalCity = capital:GetID()
			FoundReligion(iPlayer, iCapitalCity, RELIGION_THE_WEAVE_OF_EA)	--always The Fay
		end
		--Techs
		team:SetHasTech(GameInfoTypes.TECH_PANTHEISM, true)

		--Meet gods represented by Natural Wonders already discovered
		gg_teamCanMeetGods[iTeam] = true
		for featureID in pairs(eaPlayer.revealedNWs) do
			local nwTable = gg_naturalWonders[featureID]
			local iGod = nwTable.iGod
			if iGod then
				team:Meet(Players[iGod]:GetTeam(), true)
			end
		end

	elseif policyBranchTypeID == POLICY_BRANCH_ARCANA then

		local team = Teams[Players[iPlayer]:GetTeam()]
		team:SetHasTech(GameInfoTypes.TECH_MOLY_VISIBLE, true)
	
	elseif policyBranchTypeID == POLICY_BRANCH_SLAVERY then
		local player = Players[iPlayer]
		local eaPlayer = gPlayers[iPlayer]
		
		gg_slaveryPlayer[iPlayer] = true

		--need to know if opener is already adopted when this event fires:
		print("Opened Slavery branch; has Slavery?:", iPlayer, player:HasPolicy(GameInfoTypes.POLICY_SLAVERY))

		ConvertUnitsByMatch(iPlayer, "UNIT_WORKERS", "UNIT_SLAVES")
		BlockUnitMatch(iPlayer, "UNIT_SLAVES", "NonSlavery", false, nil)
		ConvertUnitProductionByMatch(iPlayer, "UNIT_WORKERS", "UNIT_SLAVES")
		BlockUnitMatch(iPlayer, "UNIT_WORKERS", "Slavery", true, nil)

		-- free slave
		local unitTypeStr = "UNIT_SLAVES"
		--if player:HasPolicy(GameInfoTypes.POLICY_PANTHEISM) then
		--	unitTypeStr = unitTypeStr .. "_PAN"
		--end
		if eaPlayer.race == EARACE_MAN then
			unitTypeStr = unitTypeStr .. "_MAN"
		elseif eaPlayer.race == EARACE_SIDHE then
			unitTypeStr = unitTypeStr .. "_SIDHE"
		elseif eaPlayer.race == EARACE_HELDEOFOL then
			unitTypeStr = unitTypeStr .. "_ORC"
		end
		local capital = player:GetCapitalCity()
		player:InitUnit(GameInfoTypes[unitTypeStr], capital:GetX(), capital:GetY())
	end

end
local OnPlayerAdoptPolicyBranch = OnPlayerAdoptPolicyBranch
GameEvents.PlayerAdoptPolicyBranch.Add(function(iPlayer, policyBranchTypeID) return HandleError21(OnPlayerAdoptPolicyBranch, iPlayer, policyBranchTypeID) end)

local policyDelayedEffectID = {}
local policyDelayedEffectPlayerIndex = {}
local policyDelayedEffectNum = 0

function OnPlayerAdoptPolicy(iPlayer, policyID)				--called by EaAICiv.lua for AI; Does not fire for openers! (or finishers???)
	print("Called OnPlayerAdoptPolicy", iPlayer, policyID)
	policyDelayedEffectNum = policyDelayedEffectNum + 1
	policyDelayedEffectID[policyDelayedEffectNum] = policyID
	policyDelayedEffectPlayerIndex[policyDelayedEffectNum] = iPlayer
	
	if bFullCivAI[iPlayer] then
		OnPlayerAdoptPolicyDelayedEffect()
	end
end
local OnPlayerAdoptPolicy = OnPlayerAdoptPolicy
GameEvents.PlayerAdoptPolicy.Add(function(iPlayer, policyID) return HandleError21(OnPlayerAdoptPolicy, iPlayer, policyID) end)

function OnPlayerAdoptPolicyDelayedEffect()		--called by closing policy window and end turn (just in case) for human player
	Dprint("OnPlayerAdoptPolicyDelayedEffect")
	--effects delayed until after trait test; for human player until policy window closed (cached in case >1 policy gained before window closed)
	local i = 1
	while i <= policyDelayedEffectNum do
		local policyID = policyDelayedEffectID[i]
		local iPlayer = policyDelayedEffectPlayerIndex[i]
		local policyInfo = GameInfo.Policies[policyID]

		--Meet pantheistic god
		if policyInfo.PolicyBranchType == "POLICY_BRANCH_PANTHEISM" then
			MeetRandomPantheisticGod(iPlayer, "PantheisticPolicy", policyID)
		end

		RefreshBeliefs(policyID)

		if iPlayer == Game.GetActivePlayer() then
			UpdateCityYields(iPlayer)		--update UI (e.g., from finisher yield conversions)
		end

		--GPs
		if policyInfo.EaFirstInBranchGPClass or policyInfo.EaFirstInBranchGPSubclass then
			local player = Players[iPlayer]
			local eaPlayer = gPlayers[iPlayer]
			local bFirstInBranch = true
			local sqlSearch = "PolicyBranchType = '" .. policyInfo.PolicyBranchType .. "'"
			for loopPolicy in GameInfo.Policies(sqlSearch) do
				local loopPolicyID = loopPolicy.ID
				if loopPolicyID ~= policyID and player:HasPolicy(loopPolicyID) then
					bFirstInBranch = false
					break
				end
			end
			if bFirstInBranch then
				if eaPlayer.eaCivNameID then
					GenerateGreatPerson(iPlayer, policyInfo.EaFirstInBranchGPClass, policyInfo.EaFirstInBranchGPSubclass)
				else
					eaPlayer.delayedGPclass = policyInfo.EaFirstInBranchGPClass			--Will spawn after civ naming
					eaPlayer.delayedGPsubclass = policyInfo.EaFirstInBranchGPSubclass 
				end
			end
		end

		--Specific Lua functions
		if OnPolicyAdopted[policyID] then
			OnPolicyAdopted[policyID](iPlayer)
		end

		i = i + 1
	end
	policyDelayedEffectNum = 0	

end
LuaEvents.EaPoliciesOnPlayerAdoptPolicyDelayedEffect.Add(OnPlayerAdoptPolicyDelayedEffect)

local function OnPlayerCanAdoptPolicyBranch(iPlayer, policyBranchTypeID)
	Dprint("OnPlayerCanAdoptPolicyBranch ", iPlayer, policyBranchTypeID)
	if policyBranchTypeID == POLICY_BRANCH_THEISM then
		local eaPlayer = gPlayers[iPlayer]
		return not eaPlayer.bIsFallen and eaPlayer.race == EARACE_MAN
	elseif policyBranchTypeID == POLICY_BRANCH_ANTI_THEISM then
		local eaPlayer = gPlayers[iPlayer]
		return eaPlayer.bIsFallen and eaPlayer.race == EARACE_MAN
	end
	return true
end
GameEvents.PlayerCanAdoptPolicyBranch.Add(function(iPlayer, policyBranchTypeID) return HandleError21(OnPlayerCanAdoptPolicyBranch, iPlayer, policyBranchTypeID) end)

--Disabled below because it doesn't allow for capture returns
--local function OnCanCaptureCivilian(iPlayer, iUnit)
--	return gg_slaveryPlayer[iPlayer]
--end
--GameEvents.CanCaptureCivilian.Add(function(iPlayer, iUnit) return HandleError21(OnCanCaptureCivilian, iPlayer, iUnit) end)

--------------------------------------------------------------
-- Policy-specific
--------------------------------------------------------------

OnPolicyAdopted[GameInfoTypes.POLICY_FOREST_DOMINION] = function(iPlayer)
	local totalStrengthAdded = ChangeLivingTerrainStrengthWorldWide(1, iPlayer)
	--TO DO: Player notification for totalStrengthAdded
end

OnPolicyAdopted[GameInfoTypes.POLICY_FERAL_BOND] = function(iPlayer)
	local iTeam = Players[iPlayer]:GetTeam()
	local team = Teams[iTeam]
	team:MakePeace(Players[ANIMALS_PLAYER_INDEX]:GetTeam())
	NRArrayRemove(gg_animalSpawnInhibitTeams, iTeam)
end

OnPolicyAdopted[GameInfoTypes.POLICY_THROUGH_THE_VEIL] = function(iPlayer)
	local iTeam = Players[iPlayer]:GetTeam()
	local team = Teams[iTeam]
	gg_teamCanMeetFay[iTeam] = true
	team:Meet(Players[FAY_PLAYER_INDEX]:GetTeam(), true)
end

OnPolicyAdopted[GameInfoTypes.POLICY_ARCANE_LORE] = function(iPlayer)
	gg_playerArcaneMod[iPlayer] = gg_playerArcaneMod[iPlayer] - 10
end

OnPolicyAdopted[GameInfoTypes.POLICY_ARCANE_RESEARCH] = function(iPlayer)
	gg_playerArcaneMod[iPlayer] = gg_playerArcaneMod[iPlayer] - 20
end

OnPolicyAdopted[GameInfoTypes.POLICY_SLAVE_RAIDERS] = function(iPlayer)
	local team = Teams[Players[iPlayer]:GetTeam()]
	team:SetHasTech(TECH_SLAVE_RAIDERS, true)
end

OnPolicyAdopted[GameInfoTypes.POLICY_SLAVE_RAIDERS] = function(iPlayer)
	local team = Teams[Players[iPlayer]:GetTeam()]
	team:SetHasTech(TECH_SLAVE_ARMIES, true)
end

OnPolicyAdopted[GameInfoTypes.POLICY_WOODS_LORE] = function(iPlayer)
	local team = Teams[Players[iPlayer]:GetTeam()]
	team:SetHasTech(GameInfoTypes.TECH_MOLY_VISIBLE, true)
end

OnPolicyAdopted[GameInfoTypes.POLICY_PATRONAGE] = function(iPlayer)
	gg_bHasPatronage[iPlayer] = true
end





OnPolicyAdopted[GameInfoTypes.POLICY_WITCHCRAFT] = OnPolicyAdopted[GameInfoTypes.POLICY_WOODS_LORE]
