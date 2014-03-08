-- EaAICivPlanning
-- Author: Pazyryk
-- DateCreated: 1/30/2012 3:03:41 PM
--------------------------------------------------------------

print("Loading EaAICivPlanning.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end


--------------------------------------------------------------
-- Settings
--------------------------------------------------------------
local CONTINGENCY_THRESHOLD = 40				--Lower makes it easier to add contingency plan
local CONTINGENCY_TURN_INTERVAL = 5

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

--constants
local EARACE_MAN =					GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =				GameInfoTypes.EARACE_SIDHE
local PLOT_OCEAN =					PlotTypes.PLOT_OCEAN
local PLOT_LAND =					PlotTypes.PLOT_LAND
local PLOT_HILLS =					PlotTypes.PLOT_HILLS
local PLOT_MOUNTAIN =				PlotTypes.PLOT_MOUNTAIN
local FEATURE_ICE =					GameInfoTypes.FEATURE_ICE
local FEATURE_FOREST = 				GameInfoTypes.FEATURE_FOREST
local FEATURE_JUNGLE = 				GameInfoTypes.FEATURE_JUNGLE
local FEATURE_MARSH =	 			GameInfoTypes.FEATURE_MARSH

local POLICY_DOMINIONISM =			GameInfoTypes.POLICY_DOMINIONISM
local POLICY_PANTHEISM =			GameInfoTypes.POLICY_PANTHEISM
local POLICY_THEISM =				GameInfoTypes.POLICY_THEISM

local RELIGION_AZZANDARAYASNA =		GameInfoTypes.RELIGION_AZZANDARAYASNA
local RELIGION_ANRA =				GameInfoTypes.RELIGION_ANRA


local TECH_ARCHERY =				GameInfoTypes.TECH_ARCHERY
local TECH_MILLING =				GameInfoTypes.TECH_MILLING
local TECH_HORSEBACK_RIDING =		GameInfoTypes.TECH_HORSEBACK_RIDING
local TECH_ELEPHANT_TRAINING =		GameInfoTypes.TECH_ELEPHANT_TRAINING
local TECH_BRONZE_WORKING =			GameInfoTypes.TECH_BRONZE_WORKING
local TECH_MACHINERY =				GameInfoTypes.TECH_MACHINERY
local TECH_IRON_WORKING =			GameInfoTypes.TECH_IRON_WORKING
local TECH_MITHRIL_WORKING =		GameInfoTypes.TECH_MITHRIL_WORKING
local RESOURCE_HORSE =				GameInfoTypes.RESOURCE_HORSE
local RESOURCE_ELEPHANT =			GameInfoTypes.RESOURCE_ELEPHANT
local RESOURCE_COPPER =				GameInfoTypes.RESOURCE_COPPER
local RESOURCE_IRON =				GameInfoTypes.RESOURCE_IRON
local RESOURCE_MITHRIL =			GameInfoTypes.RESOURCE_MITHRIL

local EACIVPLAN_GENERIC =			GameInfoTypes.EACIVPLAN_GENERIC
local EACIVPLAN_PANTHEISTIC =		GameInfoTypes.EACIVPLAN_PANTHEISTIC
local EACIVPLAN_HOLY_CONTINGENT =	GameInfoTypes.EACIVPLAN_HOLY_CONTINGENT
local EACIVPLAN_UNHOLY_CONTINGENT =	GameInfoTypes.EACIVPLAN_UNHOLY_CONTINGENT


local FALLEN_ID_SHIFT =				GameInfoTypes.POLICY_ANTI_THEISM - GameInfoTypes.POLICY_THEISM

--localized game and global tables
local fullCivs = MapModData.fullCivs
local bFullCivAI = MapModData.bFullCivAI
local civNamesByRace = MapModData.civNamesByRace
local Players = Players
local Teams = Teams
local gPlayers = gPlayers
local gReligions = gReligions
local gg_eaNamePlayerTable = gg_eaNamePlayerTable


--localized game and library functions
local Distance = Map.PlotDistance
local GetPlotByXY = Map.GetPlot
local Floor = math.floor
local Max = math.max
local StrFind = string.find
local StrSubstitute = string.gsub
local Sort = table.sort

--localized global functions
local Clone = Clone
local Union = Union
local GetBestOne = GetBestOne
local GetBestTwo = GetBestTwo

--file functions
local TestWarriorsBlock
local DebugPrintAICivInfo
local TreatAsPantheistic
local GetResearchNeededForTechList
local GetResearchNeededForPlans
local GetCultureLevelNeededForPolicyList
local GetCultureLevelNeededForPlans
local IsFinishedPlanTechsPolicies
--local IsFinishedPlansBySet
--local InitCivPlan
local TestDoPlans
--local CancelCivPlan
--local PrependPlan
--local AppendPlan
local AddFocusPlan
local RemoveAllPlans
local SetPlansForStart
local PickBestAvailableNamingPlan
local ResetTargetName
local GetCurrentlyResearchableTechsForPlans
local TestTakeFreeTechs
local TestSetContingencyPlans

local InitPlan = {}
local DoPlan = {}
local FinishPlan = {}
local CancelPlan = {}

--file control
local g_prioritizeHolyPlan = true		--true, false or iPlayer
local g_prioritizeUnholyPlan = false


local int1 = {}
local int2 = {}
local str1 = {}
local count = 0

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------

local planSets = {"aiStartPlans", "aiNamingPlans", "aiContingency1Plans", "aiFocusPlans", "aiContingency2Plans"}	--this sets order of plan execution
local numPlanSets = #planSets

local policyPrereqs = {}			--indexed by policyID, holds arrays of all prereqs including opener
local openerPolicyBranch = {}		--indexed by opener policyID, holds branchID
local function CachePolicyPrereqsRecursionByType(policyType)
	for row in GameInfo.Policy_PrereqPolicies() do
		if row.PolicyType == policyType then
			local prereqPolicy = row.PrereqPolicy
			local bAdd = true
			for i = 1, count do
				if prereqPolicy == str1[i] then
					bAdd = false
					break
				end
			end
			if bAdd then
				count = count + 1
				str1[count] = prereqPolicy
				CachePolicyPrereqsRecursionByType(prereqPolicy)
			end
		end
	end
end

local fallenPolicySwap = {}
for policyInfo in GameInfo.Policies() do
	local branchType = policyInfo.PolicyBranchType	--nil if opener, finisher or utility
	if branchType then
		--print("Prereqs for ", policyInfo.Type)
		local prereqs = {}
		local branchInfo = GameInfo.PolicyBranchTypes[branchType]
		local openerID = GameInfoTypes[branchInfo.FreePolicy]
		openerPolicyBranch[openerID] = branchInfo.ID
		prereqs[1] = openerID
		count = 0
		CachePolicyPrereqsRecursionByType(policyInfo.Type)	--caution: str1 must be empty
		--print(unpack(str1))
		for i = 1, count do
			prereqs[i + 1] = GameInfoTypes[str1[i] ]
			str1[i] = nil
		end
		policyPrereqs[policyInfo.ID] = prereqs
	
	
	end

	if branchType == "POLICY_BRANCH_THEISM" or policyInfo.Type == "POLICY_THEISM" or policyInfo.Type == "POLICY_THEISM_FINISHER" then
		fallenPolicySwap[policyInfo.ID] = policyInfo.ID + FALLEN_ID_SHIFT
	end


end
CachePolicyPrereqsRecursionByType = nil		

for policyBranchInfo in GameInfo.PolicyBranchTypes() do		--finishers have prereqs too so they can be used to tell AI to finish a branch
	local finisher = policyBranchInfo.FreeFinishingPolicy
	if finisher then
		finisherID = GameInfoTypes[finisher]
		branchType = policyBranchInfo.Type
		openerID = GameInfoTypes[policyBranchInfo.FreePolicy]
		local prereqs = {}
		count = 1
		prereqs[1] = openerID
		for policyInfo in GameInfo.Policies() do
			local policyBranchType = policyInfo.PolicyBranchType
			if policyBranchType == branchType then
				count = count +1
				prereqs[count] = policyInfo.ID
			end
		end
		policyPrereqs[finisherID] = prereqs
	end
end

--[[debug
for policyInfo in GameInfo.Policies() do
	local prereqs = policyPrereqs[policyInfo.ID]
	if prereqs then
		print("Prereqs for ", policyInfo.Type)
		for i = 1, #prereqs do
			policyID = prereqs[i]
			print(" * ", GameInfo.Policies[policyID].Type)
		end
	else
		print("No prereqs for ", policyInfo.Type)
	end
end
]]

local excludedPolicyBranchesByBranchID = {}
for row in GameInfo.PolicyBranch_Disables() do
	b1 = GameInfoTypes[row.PolicyBranchType]
	b2 = GameInfoTypes[row.PolicyBranchDisable]
	excludedPolicyBranchesByBranchID[b1] = excludedPolicyBranchesByBranchID[b1] or {}
	local index = #excludedPolicyBranchesByBranchID[b1] + 1
	excludedPolicyBranchesByBranchID[b1][index] = b2
end

local techPrereqs = {}				--indexed by techID, holds arrays of all prereqs
local function CacheTechPrereqsRecursionByType(techType)
	for row in GameInfo.Technology_PrereqTechs() do
		if row.TechType == techType then
			local prereqTech = row.PrereqTech
			local bAdd = true
			for i = 1, count do
				if prereqTech == str1[i] then
					bAdd = false
					break
				end
			end
			if bAdd then
				count = count + 1
				str1[count] = prereqTech
				CacheTechPrereqsRecursionByType(prereqTech)
			end
		end
	end
end

for techInfo in GameInfo.Technologies() do
	if not techInfo.Utility then
		--print("Prereqs for ", techInfo.Type)
		local prereqs = {}
		count = 0
		CacheTechPrereqsRecursionByType(techInfo.Type)	--caution: str1 must be empty
		if 0 < count then
			--print(unpack(str1))
			for i = 1, count do
				prereqs[i] = GameInfoTypes[str1[i] ]
				str1[i] = nil
			end
			techPrereqs[techInfo.ID] = prereqs
		end
	end
end
CacheTechPrereqsRecursionByType = nil

local unholyPlans = {[GameInfoTypes.EACIVPLAN_UNHOLY_CONTINGENT] = true, [GameInfoTypes.EACIVPLAN_UNHOLY] = true, [GameInfoTypes.EACIVPLAN_STYGIA] = true}
local holyPlans = {}

local policiesByPlan = {}
local techsByPlan = {}
local buildInstructionsByPlan = {}

for planInfo in GameInfo.EaCivPlans() do
	local techModule = planInfo.TechModule
	if techModule then
		local techs = {}
		local singleTechID = GameInfoTypes[techModule]
		if singleTechID then
			techs[1] = singleTechID
		else
			local techNum = 0
			for row in GameInfo.EaCivPlans_TechModules() do
				if row.TechModule == techModule then
					techNum = techNum + 1
					techs[techNum] = GameInfoTypes[row.TechType]
				end
			end
			if techNum == 0 then
				error("There was no TechModule in EaCivPlans_TechModules matching " .. techModule)
			end
		end
		techsByPlan[planInfo.ID] = techs
	end

	local policyModule = planInfo.PolicyModule
	if policyModule then
		local policies = {}
		local singlePolicyID = GameInfoTypes[policyModule]
		if singlePolicyID then
			policies[1] = singlePolicyID
			local policyInfo = GameInfo.Policies[singlePolicyID]
			if policyInfo.PolicyBranchType == GameInfoTypes.POLICY_BRANCH_THEISM and not unholyPlans[planInfo.ID] then
				holyPlans[planInfo.ID] = true
			end
		else
			local policyNum = 0
			for row in GameInfo.EaCivPlans_PolicyModules() do
				if row.PolicyModule == policyModule then
					policyNum = policyNum + 1
					policies[policyNum] = GameInfoTypes[row.PolicyType]
				end
			end
			if policyNum == 0 then
				error("There was no PolicyModule in EaCivPlans_PolicyModules matching " .. policyModule)
			end
			if policyModule == "HolyUnholy" and not unholyPlans[planInfo.ID] then
				holyPlans[planInfo.ID] = true
			end
		end
		policiesByPlan[planInfo.ID] = policies
	end

	local buildModule = planInfo.BuildModule
	if buildModule then
		--print("Build instructions for plan ", planInfo.Type)
		local build = {}
		if StrFind(buildModule, "BUILDING") then
			build[1] = {instruction = "Capital", type = "Building", item = buildModule}
			--print(build[1].instruction, build[1].type, build[1].item)
		elseif StrFind(buildModule, "UNIT") then
			local str, count = StrSubstitute(buildModule, "%*", "")
			if count == 1 then
				build[1] = {instruction = "Capital", type = "UnitMatch", item = str}
			else
				build[1] = {instruction = "Capital", type = "Unit", item = str}
			end
			--print(build[1].instruction, build[1].type, build[1].item)
		else
			local buildNum = 0
			for row in GameInfo.EaCivPlans_BuildModules() do
				if row.BuildModule == buildModule then
					buildNum = buildNum + 1
					local item = row.Item
					if StrFind(item, "BUILDING") then
						build[buildNum] = {instruction = row.Instruction, type = "Building", item = item}
					elseif StrFind(item, "UNIT") then
						local item, count = StrSubstitute(item, "%*", "")
						if count == 1 then
							build[buildNum] = {instruction = row.Instruction, type = "UnitMatch", item = item}
						else
							build[buildNum] = {instruction = row.Instruction, type = "Unit", item = item}
						end
					else
						error("Didn't recocnize Item in EaCivPlans_BuildModules " .. item)
					end
					--print(build[buildNum].instruction, build[buildNum].type, build[buildNum].item)
				end
			end
			if buildNum == 0 then
				error("There was no BuildModule in EaCivPlans_BuildModules matching " .. buildModule)
			end
		end
		buildInstructionsByPlan[planInfo.ID] = build
	end
end

local planFunctions = {}
for planInfo in GameInfo.EaCivPlans() do
	planFunctions[planInfo.ID] = planInfo.Function
end

local agStartPlansByResource = {}
for row in GameInfo.EaCivPlans_AgStartPlansByResource() do
	agStartPlansByResource[GameInfoTypes[row.ResourceType] ] = GameInfoTypes[row.PlanType]
end

local panStartPlansByResource = {}
for row in GameInfo.EaCivPlans_PanStartPlansByResource() do
	panStartPlansByResource[GameInfoTypes[row.ResourceType] ] = GameInfoTypes[row.PlanType]
end

local agContingencyScoreByResourcePlan = {}
local panContingencyScoreByResourcePlan = {}
for row in GameInfo.EaCivPlans_ContingentResourceScores() do
	local resourceID = GameInfoTypes[row.ResourceType]
	local planID = GameInfoTypes[row.PlanType]
	local devType = row.DevType
	if not devType or devType == "Ag" then
		agContingencyScoreByResourcePlan[resourceID] = agContingencyScoreByResourcePlan[resourceID] or {}
		agContingencyScoreByResourcePlan[resourceID][planID] = row.Score
	end
	if not devType or devType == "Pan" then
		panContingencyScoreByResourcePlan[resourceID] = panContingencyScoreByResourcePlan[resourceID] or {}
		panContingencyScoreByResourcePlan[resourceID][planID] = row.Score
	end
end

local agContingencyScoreByPlotSpecialPlan = {}
local panContingencyScoreByPlotSpecialPlan = {}
for row in GameInfo.EaCivPlans_ContingentPlotSpecialScores() do
	local plotSpecial = row.PlotSpecial
	local planID = GameInfoTypes[row.PlanType]
	local devType = row.DevType
	if not devType or devType == "Ag" then
		agContingencyScoreByPlotSpecialPlan[plotSpecial] = agContingencyScoreByPlotSpecialPlan[plotSpecial] or {}
		agContingencyScoreByPlotSpecialPlan[plotSpecial][planID] = row.Score
	end
	if not devType or devType == "Pan" then
		panContingencyScoreByPlotSpecialPlan[plotSpecial] = panContingencyScoreByPlotSpecialPlan[plotSpecial] or {}
		panContingencyScoreByPlotSpecialPlan[plotSpecial][planID] = row.Score
	end
end



--[[debug
print("Ag start plans by resource:")
for resourceID, planID in pairs(agStartPlansByResource) do
	print(GameInfo.Resources[resourceID].Type, GameInfo.EaCivPlans[planID].Type)
end
print("Pan start plans by resource:")
for resourceID, planID in pairs(panStartPlansByResource) do
	print(GameInfo.Resources[resourceID].Type, GameInfo.EaCivPlans[planID].Type)
end
print("Ag contingency resource, plan, score:")
for resourceID, planTable in pairs(agContingencyScoreByResourcePlan) do
	for planID, score in pairs(planTable) do
		print(GameInfo.Resources[resourceID].Type, GameInfo.EaCivPlans[planID].Type, score)
	end
end
print("Pan contingency resource, plan, score:")
for resourceID, planTable in pairs(panContingencyScoreByResourcePlan) do
	for planID, score in pairs(planTable) do
		print(GameInfo.Resources[resourceID].Type, GameInfo.EaCivPlans[planID].Type, score)
	end
end
print("Ag contingency plotSpecial, plan, score:")
for plotSpecial, planTable in pairs(agContingencyScoreByPlotSpecialPlan) do
	for planID, score in pairs(planTable) do
		print(plotSpecial, GameInfo.EaCivPlans[planID].Type, score)
	end
end
print("Pan contingency plotSpecial, plan, score:")
for plotSpecial, planTable in pairs(panContingencyScoreByPlotSpecialPlan) do
	for planID, score in pairs(planTable) do
		print(plotSpecial, GameInfo.EaCivPlans[planID].Type, score)
	end
end
]]


--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function AICivsPerGameTurn()
	print("Running AICivsPerGameTurn")
	g_prioritizeHolyPlan = not gReligions[RELIGION_AZZANDARAYASNA]
	g_prioritizeUnholyPlan = gReligions[RELIGION_AZZANDARAYASNA] and not gReligions[RELIGION_ANRA]
	if g_prioritizeHolyPlan or g_prioritizeUnholyPlan then		--this will shut off after a while so no overhead on late game
		for iPlayer, eaPlayer in pairs(fullCivs) do
			if bFullCivAI[iPlayer] then
				for i = 1, numPlanSets do
					local planSet = planSets[i]
					local plans = eaPlayer[planSet]
					if plans then
						for j = 1, #plans do
							local planID = plans[j]
							if holyPlans[planID] then
								g_prioritizeHolyPlan = iPlayer
							elseif unholyPlans[planID] then
								g_prioritizeUnholyPlan = iPlayer
							end
						end
					end
				end
			end
		end
	end
	print("g_prioritizeHolyPlan = ", g_prioritizeHolyPlan, "g_prioritizeUnholyPlan = ", g_prioritizeUnholyPlan)
end

function AIPushTechsFromCivPlans(iPlayer, bReset)	--called from above and when tech researched and player:GetLengthResearchQueue() < 1
	print("Running AIPushTechsFromCivPlans ", iPlayer, bReset)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	local eaPlayer = gPlayers[iPlayer]
	if bReset then player:ClearResearchQueue() end

	local planSetNum, planNum = 1, 1
	local planSet = planSets[1]
	local plans = eaPlayer[planSet]
	local planID = plans[1]	
	while true do
		if planID then
			local techs = techsByPlan[planID]
			if techs then
				for i = 1, #techs do
					local techID = techs[i]
					if not team:IsHasTech(techID) and player:CanEverResearch(techID) and player:GetQueuePosition( techID ) == -1 then
						print("Attempting to push tech ", techID, GameInfo.Technologies[techID].Type)
						player:PushResearch(techID, false)
						print("Queue length / position of last push ", player:GetLengthResearchQueue(), player:GetQueuePosition(techID))
					end
				end
				if player:GetLengthResearchQueue() > 0 then break end
			end
			planNum = planNum + 1
			planID = plans[planNum]
			if not planID then
				if planSet == "aiFocusPlans" then		--try to add plan to this planSet
					planID = AddFocusPlan(iPlayer)
				end
			end
		else	--done with this plan set
			if planSetNum < numPlanSets then
				planSetNum = planSetNum + 1
				planSet = planSets[planSetNum]
				plans = eaPlayer[planSet]
				planNum = 1
				planID = plans[1]
			else
				local b1change, b2change = TestSetContingencyPlans(iPlayer)
				if b1change or b2change then
					planSetNum = b1change and 3 or 5		--backup to cont1 or cont2
					planSet = planSets[planSetNum]
					plans = eaPlayer[planSet]
					planNum = 1
					planID = plans[1]
				else 
					planID = EACIVPLAN_GENERIC
					print("!!!! WARNING: AI resorting to generic plan for techs !!!!")
				end
			end
		end
	end
end
local AIPushTechsFromCivPlans = AIPushTechsFromCivPlans

function AIPickPolicy(iPlayer)	--called from EaPolicies.lua
	print("Running AIpickPolicy", iPlayer)
	--DebugPrintAICivInfo(iPlayer)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer.eaCivNameID then
		ResetTargetName(iPlayer)	--probably we can get a name NOW, so reassess (AI will prioritize what it can get now vs later)
	end
	local bIsFallen = eaPlayer.bIsFallen
	player:ChangeNumFreePolicies(1)		--this makes player:CanUnlockPolicyBranch & CanAdoptPolicy work

	local planSetNum, planNum = 1, 1
	local planSet = planSets[1]
	local plans = eaPlayer[planSet]
	local planID = plans[1]	

	while true do
		if planID then
			local policies = policiesByPlan[planID]
			if policies then
				for i = 1, #policies do
					local policyID = policies[i]
					local prereqs = policyPrereqs[policyID]
					policyID = (bIsFallen and fallenPolicySwap[policyID]) and fallenPolicySwap[policyID] or policyID
					if not player:HasPolicy(policyID) then
						--try this policy and all its prereqs before we move on to next policy in plan
						local j = 0

						while policyID do
							--try original policyID first and then work through its prereqs, if any
							policyID = (bIsFallen and fallenPolicySwap[policyID]) and fallenPolicySwap[policyID] or policyID
							if not player:HasPolicy(policyID) then


								--Note: This should be modified to handle finishers. That way finishers can be added to EaCivAI.sql
								--and we won't have to worry about forgetting to add a policy when we want AI to complete branch.


								local branchIDForOpener = openerPolicyBranch[policyID]	--nil if not an opener
								if branchIDForOpener then

									--Exclusive branch check (TO DO: Retest IsPolicyBranchBlocked to see if we can make that work. Does Lua policy adopting prevent blocks?)
									local bExcludedBranch = false
									local excludedBranches = excludedPolicyBranchesByBranchID[branchIDForOpener]
									if excludedBranches then
										for k = 1, #excludedBranches do
											if player:IsPolicyBranchUnlocked(excludedBranches[k]) then
												bExcludedBranch = true
												break
											end
										end
									end
									if bExcludedBranch then
										break		--stop checking this policy and its prereqs
									end
						
									if player:CanUnlockPolicyBranch(branchIDForOpener) then
										print("Opening policy branch ", GameInfo.PolicyBranchTypes[branchIDForOpener].Type)
										player:ChangeNumFreePolicies(-1)
										player:SetPolicyBranchUnlocked(branchIDForOpener, true)
										player:SetHasPolicy(policyID, true)
										OnPlayerAdoptPolicyBranch(iPlayer, branchIDForOpener)
										return
									end
								else
									if player:CanAdoptPolicy(policyID) then
										print("Adopting policy ", GameInfo.Policies[policyID].Type)
										player:ChangeNumFreePolicies(-1)
										player:SetHasPolicy(policyID, true)
										OnPlayerAdoptPolicy(iPlayer, policyID)
										return
									end
								end
							end
							j = j + 1
							policyID = prereqs and prereqs[j]
						end
					end
				end
			end
			planNum = planNum + 1
			planID = plans[planNum]
			if not planID then
				if planSet == "aiFocusPlans" then		--try to add plan to this planSet
					planID = AddFocusPlan(iPlayer)
				end
			end
		else	--done with this plan set
			if planSetNum < numPlanSets then
				planSetNum = planSetNum + 1
				planSet = planSets[planSetNum]
				plans = eaPlayer[planSet]
				planNum = 1
				planID = plans[1]
			else
				local b1change, b2change = TestSetContingencyPlans(iPlayer)
				if b1change or b2change then
					planSetNum = b1change and 3 or 5		--backup to cont1 or cont2
					planSet = planSets[planSetNum]
					plans = eaPlayer[planSet]
					planNum = 1
					planID = plans[1]
				else 
					planID = EACIVPLAN_GENERIC
					print("!!!! WARNING: AI resorting to generic plan for policies !!!!")
				end
			end
		end
	end
end

function AICivRun(iPlayer)		--called per turn and re-called if free tech or plan change after run
	print("****  Begin AICivRun for player " .. iPlayer .. "  ****")
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local bResetTechQueue = false
	local bRunAgain = false
	local bTestContingencies = Game.GetGameTurn() % CONTINGENCY_TURN_INTERVAL == 0

	--------------------------------------------------------------
	-- The following sections are a sequence that the AI steps through.
	-- It should handle the case where a human player becomes an AI in the middle of a game.
	--------------------------------------------------------------

	if eaPlayer.aiStage == nil then					--Init as AI civ if city founded
		if not player:IsFoundedFirstCity() then return end
		for i = 1, numPlanSets do
			eaPlayer[planSets[i]] = {}	--planSets = {"aiStartPlans", "aiNamingPlans", "aiContingency1Plans", "aiFocusPlans", "aiContingency1Plans"}
		end
		eaPlayer.aiCompletedCivPlans = {}
		eaPlayer.aiObsoletedCivPlans = {}
		eaPlayer.aiStage = "Start"
	end
	--------------------------------------------------------------
	if eaPlayer.aiStage == "Start" then				--Add Start plans and (if there were any) set a tentative target name
		print("AI stage: Start")
		local bNewStarts = SetPlansForStart(iPlayer)
		if eaPlayer.eaCivNameID then
			eaPlayer.aiStage = "AchievedName"
		elseif bNewStarts then
			ResetTargetName(iPlayer)			--may be needed even now in case we need additional tech/policy direction not provided by start plans
			bResetTechQueue = true
			eaPlayer.aiStage = "WaitForStart"
		else
			eaPlayer.aiStage = "TargetName"
		end
		bTestContingencies = true
	end
	--------------------------------------------------------------
	if eaPlayer.aiStage == "WaitForStart" then			--Wait for finish of Start plans
		print("AI stage: WaitForStart")
		if eaPlayer.eaCivNameID then
			eaPlayer.aiStage = "AchievedName"
		elseif #eaPlayer.aiStartPlans == 0 then
			eaPlayer.aiStage = "TargetName"
		end
	end
	--------------------------------------------------------------
	if eaPlayer.aiStage == "TargetName" then			--Score best available naming trait based on current conditions and persue it
		print("AI stage: TargetName")
		if eaPlayer.eaCivNameID then
			eaPlayer.aiStage = "AchievedName"
		else	
			ResetTargetName(iPlayer)
			bResetTechQueue = true
			eaPlayer.aiStage = "WaitForName"	
		end
		bTestContingencies = true
	end
	--------------------------------------------------------------
	if eaPlayer.aiStage == "WaitForName" then			--Stay here until target name earned (reset target if someone else got it)
		print("AI stage: WaitForName")
		if eaPlayer.eaCivNameID then
			eaPlayer.aiStage = "AchievedName"
		elseif gg_eaNamePlayerTable[eaPlayer.aiSeekingName] then
			print("AI was beaten to name by another civ...")
			ResetTargetName(iPlayer)
			bResetTechQueue = true
		end
	end
	--------------------------------------------------------------
	if eaPlayer.aiStage == "AchievedName" then			--Achieved name; check for new Start plans and add focus plan
		print("AI stage: AchievedName")
		eaPlayer.aiSeekingName = nil
		RemoveAllPlans(iPlayer)		--removes all
		SetPlansForStart(iPlayer)	--may not have finished above, or a different start may be needed due to ag/pan switch
		AddFocusPlan(iPlayer)
		bTestContingencies = true
		bResetTechQueue = true
		eaPlayer.aiStage = "CivFocus"
	end
	--------------------------------------------------------------
	if eaPlayer.aiStage == "CivFocus" then				--Nothing but contingency checks (Focus plans added as needed by tech/policy gains)
		print("AI stage: CivFocus")
	end
	--------------------------------------------------------------
	if eaPlayer.aiStage == "TargetVictory" then			--Something will go here, eventually
		print("AI stage: TargetVictory")
	end
	--------------------------------------------------------------
	local bFreeTechsTaken = TestTakeFreeTechs(player)
	bResetTechQueue = bResetTechQueue or bFreeTechsTaken

	if bTestContingencies and not bFreeTechsTaken then		--free tech will have already caused this
		local b1change, b2change = TestSetContingencyPlans(iPlayer)		--checked at intervals and at some transitions
		bResetTechQueue = bResetTechQueue or b1change or b2change	
	end
	
	local bPlanFinished = TestDoPlans(iPlayer)
	bRunAgain = bFreeTechsTaken or bPlanFinished
	if bResetTechQueue then
		AIPushTechsFromCivPlans(iPlayer, true)
	end
	if bRunAgain then
		print("AICivRun calling itself")
		AICivRun(iPlayer)					--tail call, not recursion
	else
		--warrior block
		local bWarriorsBlock = TestWarriorsBlock(player)
		print("AI blocked for warriors ", bWarriorsBlock)
		if not eaPlayer.aiWarriorsBlock ~= not bWarriorsBlock then		--changed (double not so nil == false)
			eaPlayer.aiWarriorsBlock = bWarriorsBlock
			BlockUnitMatch(iPlayer, "UNIT_WARRIORS", "WarriorBlock", bWarriorsBlock, nil)
		end


		if player:GetCurrentResearch() == -1 then
			AIPushTechsFromCivPlans(iPlayer, true)
			if player:GetCurrentResearch() == -1 then
				error("AI civ exiting AICivRun with GetCurrentResearch = " .. (player:GetCurrentResearch() or "nil"))
			end
		end

		DebugPrintAICivInfo(iPlayer)
		print("****  End of AICivRun  ****")
	end	
end
--------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------

TestWarriorsBlock = function(player)
	--return true if we have alternative military
	local team = Teams[player:GetTeam()]
	if team:IsHasTech(TECH_ARCHERY) then return true end
	if team:IsHasTech(TECH_MILLING) then return true end
	if team:IsHasTech(TECH_HORSEBACK_RIDING) then
		if player:GetNumResourceAvailable(RESOURCE_HORSE, false) > 0 then return true end
	end
	if team:IsHasTech(TECH_ELEPHANT_TRAINING) then
		if player:GetNumResourceAvailable(RESOURCE_ELEPHANT, false) > 0 then return true end
	end
	if team:IsHasTech(TECH_BRONZE_WORKING) then
		if player:GetNumResourceAvailable(RESOURCE_COPPER, false) > 0 then
			return true
		elseif team:IsHasTech(TECH_MACHINERY) then
			return true	
		elseif team:IsHasTech(TECH_IRON_WORKING) then
			if player:GetNumResourceAvailable(RESOURCE_IRON, false) > 0 then
				return true
			elseif team:IsHasTech(TECH_MITHRIL_WORKING) then
				if player:GetNumResourceAvailable(RESOURCE_MITHRIL, false) > 0 then return true end
			end
		end
	end
	return false
end


local planScores = {}	--these tables used and recycled
local newPlans = {}		--build up this table, then sort, then replace old plans if different
TestSetContingencyPlans = function(iPlayer)
	--Contingency1 means better than CONTINGENCY_THRESHOLD
	--Contingency2 means <= CONTINGENCY_THRESHOLD; used only if we are desperate for plan
	print("Running TestSetContingencyPlans ", iPlayer, bContingency2)
	local eaPlayer = gPlayers[iPlayer]
	local cont1Plans = eaPlayer.aiContingency1Plans
	local numCont1 = #cont1Plans
	local cont2Plans = eaPlayer.aiContingency2Plans
	local numCont2 = #cont2Plans
	local completedPlans = eaPlayer.aiCompletedCivPlans
	local numCompleted = #completedPlans
	local obsoletedPlans = eaPlayer.aiObsoletedCivPlans
	local numObsoleted = #obsoletedPlans
	local bPantheistic = TreatAsPantheistic(iPlayer)

	if bPantheistic then
		planScores[EACIVPLAN_PANTHEISTIC] = CONTINGENCY_THRESHOLD * 10
	elseif g_prioritizeHolyPlan == true or g_prioritizeHolyPlan == iPlayer then
		if eaPlayer.race == EARACE_MAN then
			planScores[EACIVPLAN_HOLY_CONTINGENT] = CONTINGENCY_THRESHOLD + 1
		end
	elseif g_prioritizeUnholyPlan == true or g_prioritizeUnholyPlan == iPlayer then		--Azz must be founded already
		if eaPlayer.race == EARACE_MAN then
			local gameTurn = Game.GetGameTurn()
			if gameTurn > 200 then
				planScores[EACIVPLAN_UNHOLY_CONTINGENT] = CONTINGENCY_THRESHOLD + 1
			elseif gameTurn > 150 then
				if iPlayer ~= gReligions[RELIGION_AZZANDARAYASNA].founder then
					planScores[EACIVPLAN_UNHOLY_CONTINGENT] = CONTINGENCY_THRESHOLD + 1
				end
			elseif gameTurn > 100 then
				if iPlayer ~= gReligions[RELIGION_AZZANDARAYASNA].founder and Players[iPlayer]:HasPolicy(POLICY_THEISM) then
					planScores[EACIVPLAN_UNHOLY_CONTINGENT] = CONTINGENCY_THRESHOLD + 1
				end
			end

		end		
	end
	
	local resourceScores = bPantheistic and panContingencyScoreByResourcePlan or agContingencyScoreByResourcePlan
	for resourceID, number in pairs(eaPlayer.resourcesInBorders) do
		if 0 < number then
			local scores = resourceScores[resourceID]
			if scores then
				for planID, score in pairs(scores) do
					planScores[planID] = (planScores[planID] or 0) + score * number
					print("resource / number / plan / cum. score : ", GameInfo.Resources[resourceID].Type, number, GameInfo.EaCivPlans[planID].Type, planScores[planID])
				end
			end
		end
	end
	local plotSpecialScores = bPantheistic and panContingencyScoreByPlotSpecialPlan or agContingencyScoreByPlotSpecialPlan
	for plotSpecial, number in pairs(eaPlayer.plotSpecialsInBorders) do
		if 0 < number then
			local scores = plotSpecialScores[resourceID]
			if scores then
				for planID, score in pairs(scores) do
					planScores[planID] = (planScores[planID] or 0) + score * number
					print("plotSpecial / number / plan / cum. score : ", plotSpecial, number, GameInfo.EaCivPlans[planID].Type, planScores[planID])
				end
			end
		end
	end

	--add plan if is not previously obsoleted and is not currently obsolete
	local numNewPlans = 0
	for planID, score in pairs(planScores) do
		local bAdd = true
		for i = 1, numCompleted do
			if completedPlans[i] == planID then		--completed
				bAdd = false
				break
			end
		end
		if bAdd then
			for i = 1, numObsoleted do
				if obsoletedPlans[i] == planID then		--obsoleted (in previous test)
					bAdd = false
					break
				end
			end
			if bAdd then
				if IsFinishedPlanTechsPolicies(iPlayer, planID) then		--obsolete (add to list)
					numObsoleted = numObsoleted + 1
					obsoletedPlans[numObsoleted] = planID			--plan is obsolete; add to obsolete list so we don't test prereqs again
				else
					print("Contingency plan passed / score : ", GameInfo.EaCivPlans[planID].Type, planScores[planID])
					numNewPlans = numNewPlans + 1
					newPlans[numNewPlans] = planID
				end
			end
		end
	end

	for i = #newPlans, numNewPlans + 1, -1 do	--trim back to present list size
		newPlans[i] = nil
	end

	Sort(newPlans, function(a, b) return planScores[b] < planScores[a] end)

	--debug
	local text = "Old Contingency 1 Plans:"
	for i, v in ipairs(cont1Plans) do text = text .. " " .. GameInfo.EaCivPlans[v].Type end
	print(text)
	text = "Old Contingency 2 Plans:"
	for i, v in ipairs(cont2Plans) do text = text .. " " .. GameInfo.EaCivPlans[v].Type end
	print(text)

	local planNumber = 1
	local planID = newPlans[1]
	local score = planScores[planID]
	local b1change, b2change = false, false
	while planID and CONTINGENCY_THRESHOLD < score do
		if cont1Plans[planNumber] ~= newPlans[planNumber] then
			cont1Plans[planNumber] = newPlans[planNumber]
			b1change = true
		end
		cont1Plans[planNumber] = newPlans[planNumber]
		planNumber = planNumber + 1
		planID = newPlans[planNumber]
		score = planScores[planID]
	end
	for i = numCont1, planNumber, -1 do		--trim extra
		cont1Plans[i] = nil
		b1change = true
	end
	local cont2number = 1
	while planID do
		if cont2Plans[cont2number] ~= newPlans[planNumber] then
			cont2Plans[cont2number] = newPlans[planNumber]
			b2change = true
		end
		cont2Plans[cont2number] = newPlans[planNumber]
		cont2number = cont2number + 1
		planNumber = planNumber + 1
		planID = newPlans[planNumber]
	end
	for i = numCont2, cont2number, -1 do		--trim extra
		cont2Plans[i] = nil
		b2change = true
	end
	
	--debug
	local text = "New Contingency 1 Plans:"
	for i, v in ipairs(cont1Plans) do text = text .. " " .. GameInfo.EaCivPlans[v].Type end
	print(text)
	text = "New Contingency 2 Plans:"
	for i, v in ipairs(cont2Plans) do text = text .. " " .. GameInfo.EaCivPlans[v].Type end
	print(text)

	for key in pairs(planScores) do
		planScores[key] = nil		--emptied for next use	
	end

	return b1change, b2change
end

TreatAsPantheistic = function(iPlayer)
	local player = Players[iPlayer]
	if player:HasPolicy(POLICY_PANTHEISM) then return true end
	if player:HasPolicy(POLICY_DOMINIONISM) then return false end
	local eaPlayer = gPlayers[iPlayer]
	if eaPlayer.race == EARACE_MAN then
		--if eaPlayer.aiSeekingName == GameInfoTypes.EACIV_SKOGR then return true end
		return false
	elseif eaPlayer.race == EARACE_SIDHE then
		--if eaPlayer.aiSeekingName == GameInfoTypes.EACIV_MORIQUENDI then return false end
		return true
	else
		error("Player has unknown race " .. (eaPlayer.race or "nil"))
	end
end

DebugPrintAICivInfo = function(iPlayer)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	if eaPlayer.aiStage then
		print("AI stage: ", eaPlayer.aiStage)
		print("Current name trait: ", eaPlayer.eaCivNameID and GameInfo.EaCivs[eaPlayer.eaCivNameID ].Type or nil)
		print("Current name target: ", eaPlayer.aiSeekingName and GameInfo.EaCivs[eaPlayer.aiSeekingName].Type or nil)

		for i = 1, numPlanSets do
			local planSet = planSets[i]
			local text = planSet .. ":"
			local plans = eaPlayer[planSet]
			for k, v in ipairs(plans) do
				text = text .. " " .. GameInfo.EaCivPlans[v].Type
			end
			print(text)
		end
		
		local queueLength = 0
		for techInfo in GameInfo.Technologies() do
			local queuePosition = player:GetQueuePosition(techInfo.ID)
			if queuePosition ~= -1 then
				queueLength = queueLength < queuePosition and queuePosition or queueLength
				str1[queuePosition] = techInfo.Type
			end
		end
		local text = "Tech Queue:"
		for i = 1, queueLength do
			text = text .. " " .. str1[i]
		end
		print(text)
	end	
end

GetResearchNeededForTechList = function(teamTechs, techList)
	--computes combined costs considering existing research and prereq redendancy (OK if techList has redundancy)
	--accumulate tech and all prereqs in int1 table

	--Dprint("GetResearchNeededForTechList ", teamTechs, techList)
	local numTechs = 1
	int1[1] = techList[1]		--1st tech and its prereqs can be added without worry of redundancy
	local prereqs = techPrereqs[techList[1] ]
	if prereqs then
		for i = 1, #prereqs do
			local prereqTechID = prereqs[i]
			numTechs = numTechs + 1
			int1[numTechs] = prereqTechID
		end
	end
	for i = 2, #techList do
		local techID = techList[i]
		local bAdd = true
		for j = 1, numTechs do
			if techID == int1[j] then
				bAdd = false
				break
			end
		end
		if bAdd then
			local prevTop = numTechs
			numTechs = numTechs + 1
			int1[numTechs] = techID
			local prereqs = techPrereqs[techID]
			if prereqs then
				for j = 1, #prereqs do
					local prereqTechID = prereqs[j]
					local bAdd = true
					for k = 1, prevTop do
						if prereqTechID == int1[k] then
							bAdd = false
							break
						end
					end
					if bAdd then
						numTechs = numTechs + 1
						int1[numTechs] = prereqTechID
					end
				end
			end
		end
	end

	--sum up cost considering existing progress
	local cost = 0
	for i = 1, numTechs do
		local techID = int1[i]
		if not teamTechs:HasTech(techID) then
			cost = cost + teamTechs:GetResearchCost(techID) - teamTechs:GetResearchProgress(techID)
		end
	end
	return cost
end

GetResearchNeededForPlans = function(teamTechs, planID, plan2ID)
	local techs1 = techsByPlan[planID]
	local techs2 = plan2ID and techsByPlan[plan2ID]
	if not techs1 then
		if techs2 then
			techs1, techs2 = techs2, nil
		else
			return 0
		end
	end
	local techList = techs2 and Union(techs1, techs2) or Clone(techs1)
	return GetResearchNeededForTechList(teamTechs, techList)
end

GetCultureLevelNeededForPolicyList = function(iPlayer, policyList)
	--does not calculate prereqs! (unlike tech above) so list must be complete
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local numberNeeded = 0
	for i = 1, #policyList do
		local policyID = policyList[i]
		if not player:HasPolicy(policyID) then
			numberNeeded = numberNeeded + 1
		end
		local prereqs = policyPrereqs[policyID]
		if prereqs then
			for j = 1, #prereqs do
				local prereqPolicyID = prereqs[j]
				if not player:HasPolicy(prereqPolicyID) then
					numberNeeded = numberNeeded + 1
				end
			end
		end
	end
	local cultureLevelNeeded = eaPlayer.policyCount + numberNeeded - eaPlayer.culturalLevel
	return 0 < cultureLevelNeeded and cultureLevelNeeded or 0
end

GetCultureLevelNeededForPlans = function(iPlayer, planID, plan2ID)
	local policyList = plan2ID and Union(policiesByPlan[planID], policiesByPlan[plan2ID]) or Clone(policiesByPlan[planID])
	return GetCultureLevelNeededForPolicyList(iPlayer, policyList)
end

IsFinishedPlanTechsPolicies = function(iPlayer, planID)
	--just checks techs and policies
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	local techs = techsByPlan[planID]
	if techs then
		for i = 1, #techs do
			local techID = techs[i]
			if not team:IsHasTech(techID) then
				return false
			end
		end
	end
	local policies = policiesByPlan[planID]
	if policies then
		for i = 1, #policies do
			local policyID = policies[i]
			if not player:HasPolicy(policyID) then
				return false
			end
		end
	end
	return true
end

--[[
IsFinishedPlansBySet = function(iPlayer, planSet)


end


IsFinishedPlansByFunction = function(iPlayer, planFunction)
	local civPlans = gPlayers[iPlayer].aiCivPlans
	for i = 1, #civPlans do
		local planID = civPlans[i]
		if GameInfo.EaCivPlans[planID].Function == planFunction then
			return false
		end
	end
	return true
end

PrependPlan = function(iPlayer, planID, plan2ID)		--plan should only be added by PrependPlan or AppendPlan
	print("Running PrependPlan ", iPlayer, planID, plan2ID)
	local civPlans = gPlayers[iPlayer].aiCivPlans
	if plan2ID then
		for i = 1, #civPlans do
			civPlans[i + 2] = civPlans[i]
		end
		civPlans[1], civPlans[2] = planID, plan2ID
	else
		for i = 1, #civPlans do
			civPlans[i + 1] = civPlans[i]
		end
		civPlans[1] = planID
	end
	InitCivPlan(iPlayer, planID)
end

AppendPlan = function(iPlayer, planID)
	local civPlans = gPlayers[iPlayer].aiCivPlans
	civPlans[#civPlans + 1] = planID
	if holyPlans[planID] then
		g_prioritizeHolyPlan = iPlayer
	elseif unholyPlans[planID] then
		g_prioritizeUnholyPlan = iPlayer
	end
	InitCivPlan(iPlayer, planID)
end

InitCivPlan = function(iPlayer, planID)
	--for now, only build blocking checked
	--buildInstructionsByPlan[planID] = {instruction, type, item}
	local buildInstructions = buildInstructionsByPlan[planID]
	if buildInstructions then
		for i = 1, #buildInstructions do
			local buildInstruction = buildInstructions[i]
			if buildInstruction.instruction == "CivBlock" then
				if buildInstruction.type == "Building" then
					local buildingID = GameInfoTypes[buildInstruction.item]
					BlockBuilding(iPlayer, buildingID, planID, true, nil)
				elseif buildInstruction.type == "Unit" then
					local unitID = GameInfoTypes[buildInstruction.item]
					BlockUnit(iPlayer, unitID, planID, true, nil)
				elseif buildInstruction.type == "UnitMatch" then
					BlockUnitMatch(iPlayer, buildInstruction.item, planID, true, nil)
				end
			end
		end
	end
	if InitPlan[planID] then
		InitPlan[planID](iPlayer)
	end
end

CancelCivPlan = function(iPlayer, planID)
	local buildInstructions = buildInstructionsByPlan[planID]
	if buildInstructions then
		for i = 1, #buildInstructions do
			local buildInstruction = buildInstructions[i]
			if buildInstruction.instruction == "CivBlock" then
				if buildInstruction.type == "Building" then
					local buildingID = GameInfoTypes[buildInstruction.item]
					BlockBuilding(iPlayer, buildingID, planID, false, nil)
				elseif buildInstruction.type == "Unit" then
					local unitID = GameInfoTypes[buildInstruction.item]
					BlockUnit(iPlayer, unitID, planID, false, nil)
				elseif buildInstruction.type == "UnitMatch" then
					BlockUnitMatch(iPlayer, buildInstruction.item, planID, false, nil)
				end
			end
		end
	end
	if CancelPlan[planID] then
		CancelPlan[planID](iPlayer)
	end
end
]]

AddFocusPlan = function(iPlayer)	--call as needed when we are short on techs or policy
	--appends focus plan based on actual or targeted civ name
	print("AddFocusPlan ", iPlayer)
	local eaPlayer = gPlayers[iPlayer]	
	local traitID = eaPlayer.eaCivNameID or eaPlayer.aiSeekingName
	local planID
	if traitID then
		local traitType = GameInfo.EaCivs[traitID].Type
		local focusPlans = eaPlayer.aiFocusPlans
		local numFocusPlans = #focusPlans
		local planCount, pointCount = 0, 0

		for row in GameInfo.EaCivPlans_FocusPlansByEaTrait() do
			if row.EaTrait == traitType then
				local testPlanID = GameInfoTypes[row.PlanType]
				local bAllow = true
				for i = 1, numFocusPlans do
					if testPlanID == focusPlans[i] then
						bAllow = false
						break
					end
				end
				if bAllow then
					if row.Priority == 100 then
						planID = testPlanID
						break
					end
					planCount = planCount + 1
					int1[planCount] = testPlanID
					int2[planCount] = row.Priority
					pointCount = pointCount + row.Priority
				end
			end
		end
		if not planID then				--planID here only if there was a priority 100 plan; otherwise, dice role based on summed priorities 
			if planCount == 1 then
				planID = int1[1]
			elseif planCount > 1 then
				local dice = Map.Rand(pointCount, "hello")
				for i = 1, planCount do
					if dice < int2[i] then
						planID = int1[i]
						break
					end
					dice = dice - int2[i]
				end
			end
		end
		focusPlans[#focusPlans + 1] = planID		--always append
		return planID
	end
end

RemoveAllPlans = function(iPlayer)
	print("Running RemoveAllPlans ", iPlayer)
	local eaPlayer = gPlayers[iPlayer]
	for i = 1, numPlanSets do
		local planSet = planSets[i]
		local plans = eaPlayer[planSet]
		for j = #plans, 1, -1 do
			plans[j] = nil
		end
	end
end

--[[
RemovePlans = function(iPlayer, planFunction)
	print("Running RemovePlans ", iPlayer, planFunction)
	local civPlans = gPlayers[iPlayer].aiCivPlans
	local size = #civPlans
	if planFunction then
		local i = 1
		while i <= size do
			local planID = civPlans[i]
			if GameInfo.EaCivPlans[planID].Function == planFunction then	--shift table left
				CancelCivPlan(iPlayer, planID)
				for j = i, size - 1 do
					civPlans[j] = civPlans[j + 1]
				end
				civPlans[size] = nil
				size = size - 1
			else
				i = i + 1
			end
		end
	else
		for i = size, 1, -1 do
			CancelCivPlan(iPlayer, civPlans[i])
			civPlans[i] = nil
		end
	end
end
]]

SetPlansForStart = function(iPlayer)
	--use what we have in 1st/2nd ring; may add nothing if there are no food plots around
	print("Running SetPlansForStart ", iPlayer)
	local Distance = Distance
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local team = Teams[player:GetTeam()]
	local teamTechs = team:GetTeamTechs()
	local capital = player:GetCapitalCity()
	local capitalX, capitalY = capital:GetX(), capital:GetY()
	local bStartPantheistic = TreatAsPantheistic(iPlayer)
	local cachedPlansByResource = bStartPantheistic and panStartPlansByResource or agStartPlansByResource
	local scoreByPlanID = {}
	for x, y in PlotToRadiusIterator(capitalX, capitalY, 3, nil, nil, false) do
		local plot = GetPlotByXY(x, y)
		local resourceID = plot:GetResourceType(-1)
		if resourceID ~= -1 then
			local ring = Distance(x, y, capitalX, capitalY)
			local value = 2 ^ (1 - ring)		--1, 0.5, 0.25 for ring 1, 2, 3
			local planID = cachedPlansByResource[resourceID]
			if planID then
				scoreByPlanID[planID] = (scoreByPlanID[planID] or 0) + value
			end
		end
	end

	local plan1, plan2 = GetBestTwo(scoreByPlanID, true)	--return indexes for largest two values in table 
	print("Best two plans by ID: ", plan1, plan2)

	--replace existing start plans and return true if start plans still needed
	--RemovePlans(iPlayer, "Start")

	if plan1 then
		if plan2 then
			if IsFinishedPlanTechsPolicies(iPlayer, plan2) then
				plan2 = nil			
			else	--add 2nd plan if combined costs not too high
				local cost = GetResearchNeededForPlans(teamTechs, plan1, plan2)
				print("Cost for two start plans (max allowed = 300): ", cost)
				if cost > 300 then
					plan2 = nil
				end
			end
		end
		if IsFinishedPlanTechsPolicies(iPlayer, plan1) then
			plan1, plan2 = plan2, nil
		end
		local startPlans = eaPlayer.aiStartPlans
		startPlans[1], startPlans[2] = plan1, plan2		--only two plans here at most
		if plan1 then
			--print("Prepending plans ", plan1 and GameInfo.EaCivPlans[plan1].Type or "nil", plan2 and GameInfo.EaCivPlans[plan2].Type or "nil")
			--PrependPlan(iPlayer, plan1, plan2)
			return true
		end
	end
	return false				--false means we are done with start plans (there was nothing to add), ready to move on...
end

PickBestAvailableNamingPlan = function(iPlayer)
	print("Running PickBestAvailableNamingPlan ", iPlayer)
	local Distance = Distance
	local Max = Max
	local Floor = Floor
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local race = eaPlayer.race
	local raceType = GameInfo.EaRaces[race].Type
	local team = Teams[player:GetTeam()]
	local teamTechs = team:GetTeamTechs()
	local gameTurn = Game.GetGameTurn()

	--gather info on nearby resources and plots
	local resourcesToRadius3 = eaPlayer.resourcesNearCapitalByID	--x5 score value; index by resourceID
	local resourcesToRadius6 = {}									--x3 score value
	local resourcesToRadius10 = {}									--x1 score value
	local plotSpecialsToRadius3 = {}								--x1 score value; index by plotSpecial text string
	local plotSpecialsToRadius6 = {}								--/3 score value
	local plotSpecialsToRadius10 = {}								--/10 score value
			--PlotSpecials: Sea, Mountain, Forest, Jungle, Marsh, Hill, Irrigable (assinged in that order)
		
	local capital = player:GetCapitalCity()
	local capitalX, capitalY = capital:GetX(), capital:GetY()
	for x, y in PlotToRadiusIterator(capitalX, capitalY, 10) do
		local plot = Map.GetPlot(x, y)
		local radius = Distance(capitalX, capitalY, x, y)
		local resourceID = plot:GetResourceType(-1)
		local featureID = plot:GetFeatureType()
		local plotTypeID = plot:GetPlotType()
		local terrainID = plot:GetTerrainType()
		local bFreshWater = plot:IsFreshWater()
		local plotSpecial
		if plotTypeID == PLOT_OCEAN then
			if featureID ~= FEATURE_ICE then plotSpecial = "Sea" end
		elseif plotTypeID == PLOT_MOUNTAIN then
			plotSpecial = "Mountain"
		elseif featureID == FEATURE_MARSH then
			plotSpecial = "Forest"
		elseif featureID == FEATURE_JUNGLE then
			plotSpecial = "Jungle"
		elseif featureID == FEATURE_FOREST then
			plotSpecial = "Marsh"
		elseif featureID == -1 then
			if plotTypeID == PLOT_HILLS then
				plotSpecial = "Hill"
			elseif bFreshWater and plotTypeID == PLOT_LAND then
				plotSpecial = "Irrigable"
			end
		end

		--debug
		--print(x, y, radius,	resourceID ~= -1 and GameInfo.Resources[resourceID].Type or -1, 
		--					featureID ~= -1 and GameInfo.Features[featureID].Type or -1,
		--					plotTypeID,
		--					terrainID ~= -1 and GameInfo.Terrains[terrainID].Type or -1,
		--					bFreshWater, plotSpecial)
	

		if radius > 6 then
			if resourceID ~= -1 then
				resourcesToRadius10[resourceID] = (resourcesToRadius10[resourceID] or 0) + 1
			end
			if plotSpecial then
				plotSpecialsToRadius10[plotSpecial] = (plotSpecialsToRadius10[plotSpecial] or 0) + 1
			end
		elseif radius > 3 then
			if resourceID ~= -1 then
				resourcesToRadius6[resourceID] = (resourcesToRadius6[resourceID] or 0) + 1
			end
			if plotSpecial then
				plotSpecialsToRadius6[plotSpecial] = (plotSpecialsToRadius6[plotSpecial] or 0) + 1
			end
		else	--resources within 3 tiles already counted
			if plotSpecial then
				plotSpecialsToRadius3[plotSpecial] = (plotSpecialsToRadius3[plotSpecial] or 0) + 1
			end
		end
	end

	--score each available naming plan
	local scoreByPlanID = {}
	for traitInfo in GameInfo.EaCivs() do
		local traitID = traitInfo.ID
		if civNamesByRace[race][traitID] then
			if not gg_eaNamePlayerTable[traitID] then	--available
				--convert to plan

				local planType = StrSubstitute(traitInfo.Type, "EACIV", "EACIVPLAN")	--EaCivPlans that target names have the same Type suffix as their corresponding EaTrait
				local planInfo = GameInfo.EaCivPlans[planType]
				if not planInfo then
					error("Did not find corresponding naming plan for name traitInfo " .. traitInfo.Type)
				end
				local planID = planInfo.ID

				print("* Scoring for civ-naming traitInfo / plan type:", traitInfo.Type, planType)

				--nearby resources bunus
				local resourceScore = 0
				for row in GameInfo.EaCivPlans_NamingResourceScores() do
					if row.PlanType == planType then
						local resourceID = GameInfoTypes[row.ResourceType]
						if resourcesToRadius3[resourceID] then
							resourceScore = resourceScore + row.Score * resourcesToRadius3[resourceID] * 5
						end
						if resourcesToRadius6[resourceID] then
							resourceScore = resourceScore + row.Score * resourcesToRadius6[resourceID] * 3
						end
						if resourcesToRadius10[resourceID] then
							resourceScore = resourceScore + row.Score * resourcesToRadius10[resourceID]
						end
					end
				end
				if 0 < resourceScore then
					print("  ...resource score:", resourceScore)
				end

				--plot special bonus
				local plotSpecialScore = 0
				for row in GameInfo.EaCivPlans_NamingPlotSpecialScores() do
					if row.PlanType == planType then
						local plotSpecial = row.PlotSpecial
						if plotSpecialsToRadius3[plotSpecial] then
							plotSpecialScore = plotSpecialScore + row.Score * plotSpecialsToRadius3[plotSpecial]
						end
						if plotSpecialsToRadius6[plotSpecial] then
							plotSpecialScore = plotSpecialScore + row.Score * plotSpecialsToRadius6[plotSpecial] / 3
						end
						if plotSpecialsToRadius10[plotSpecial] then
							plotSpecialScore = plotSpecialScore + row.Score * plotSpecialsToRadius10[plotSpecial] / 10
						end
					end
				end
				if 0 < plotSpecialScore then
					print("  ...plot special score:", plotSpecialScore)
				end

				--ad hoc bonus
				local adHocScore = planInfo.AdHocNamingValue
				if 0 < adHocScore then
					print("  ...ad hoc score:", adHocScore)
				end

				--invisible hand bonus
				local invisibleHandScore = 0
				if (g_prioritizeHolyPlan == true or g_prioritizeHolyPlan == iPlayer) and 15 < gameTurn then
					invisibleHandScore = planInfo.PrioritizeHolyValue
				end
				if 0 < invisibleHandScore then
					print("  ...invisible hand score:", invisibleHandScore)
				end

				--penalize for tech req cost
				local turnsForTech = 0
				if traitInfo.KnownTech then
					local techID = GameInfoTypes[traitInfo.KnownTech]
					local tech2ID = traitInfo.AndKnownTech and GameInfoTypes[traitInfo.AndKnownTech] or nil
					local researchNeeded = GetResearchNeededForTechList(teamTechs, {techID, tech2ID})
					local sciencePerTurn = player:GetScience()
					sciencePerTurn = sciencePerTurn < 1 and 1 or sciencePerTurn
					turnsForTech = researchNeeded / sciencePerTurn
				end
				print("  ...estimated turns for research:", turnsForTech)

				--penalize for policy req cost
				local turnsForPolicy = 0
				if traitInfo.AdoptedPolicy then
					local policyID = GameInfoTypes[traitInfo.AdoptedPolicy]
					local policy2ID = traitInfo.AndAdoptedPolicy and GameInfoTypes[traitInfo.AndAdoptedPolicy] or nil
					local cultureLevelNeeded = GetCultureLevelNeededForPolicyList(iPlayer, {policyID, policy2ID})
					local cultureChange = eaPlayer.culturalLevelChange or 0.02	--may be nil at game start
					if cultureChange < 0.0001 then
						cultureChange = 0.0001
					elseif cultureChange > 0.4 then	--don't beleive it; probably just popped a culture goody
						cultureChange = 0.05
					end
					turnsForPolicy = cultureLevelNeeded / cultureChange
				end
				print("  ...estimated turns for policy(s):", turnsForPolicy)

				--Temp: make all other traitInfo conditions prohibitive until we add logic for them
				local turnsForDebugProhibit = 0
				if traitInfo.CapitalNearbyResourceType or traitInfo.BuildingType or traitInfo.UnitClass or traitInfo.ImprovementType then
					turnsForDebugProhibit = 100000
				end
				print("  ...debug turn prohibitor:", turnsForDebugProhibit)

				local score = resourceScore + plotSpecialScore + adHocScore + invisibleHandScore
				local turns = Max(turnsForTech, turnsForPolicy, turnsForDebugProhibit)
				local finalScore = score / (turns + 1)		--anything we can take now will have a massive advantage
				print("  ...Final score/max(turns) =", finalScore)
				scoreByPlanID[planID] = finalScore
			end
		end
	end
	return GetBestOne(scoreByPlanID, true)		--return index of highest value in table
end

ResetTargetName = function(iPlayer)
	print("Running ResetTargetName", iPlayer)
	local eaPlayer = gPlayers[iPlayer]
	local namingPlanID = PickBestAvailableNamingPlan(iPlayer)
	local planType = GameInfo.EaCivPlans[namingPlanID].Type
	local traitType = StrSubstitute(planType, "EACIVPLAN", "EACIV")	--EaCivPlans that target names have the same Type suffix as their corresponding EaTrait
	local traitID = GameInfoTypes[traitType]
	if not traitID then
		error("Did not get plan or trait from ResetTargetName " .. (planType or "nil") .. " " .. (traitType or "nil"))
	end
	eaPlayer.aiSeekingName = traitID
	print("Adding new name target ", planType, traitType)
	eaPlayer.aiNamingPlans[1] = namingPlanID


	--AppendPlan(iPlayer, namingPlanID)
end

GetCurrentlyResearchableTechsForPlans = function(iPlayer, min)
	print("Running GetCurrentlyResearchableTechsForPlans ", iPlayer, min)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local team = Teams[player:GetTeam()]
	local techList = {}
	local numTechs = 0

	local planSetNum, planNum = 1, 1
	local planSet = planSets[1]
	local plans = eaPlayer[planSet]
	local planID = plans[1]	
	while true do
		if planID then
			local techs = techsByPlan[planID]
			if techs then
				for i = 1, #techs do
					local techID = techs[i]
					if not team:IsHasTech(techID) then
						if player:CanResearch(techID) then	
							local bAdd = true
							for j = 1, numTechs do
								if techID == techList[j] then
									bAdd = false
									break
								end
							end
							if bAdd then
								numTechs = numTechs + 1
								techList[numTechs] = techID
							end
						elseif player:CanEverResearch(techID) then
							local prereqs = techPrereqs[techID]
							if prereqs then
								for i = 1, #prereqs do
									local prereqTechID = prereqs[i]
									if player:CanResearch(prereqTechID) then
										local bAdd = true
										for j = 1, numTechs do
											if prereqTechID == techList[j] then
												bAdd = false
												break
											end
										end
										if bAdd then
											numTechs = numTechs + 1
											techList[numTechs] = prereqTechID
										end						
									end
								end
							end
						end
					end
				end
			end
			planNum = planNum + 1
			planID = plans[planNum]
			if not planID then
				if planSet == "aiFocusPlans" then		--try to add plan to this planSet
					planID = AddFocusPlan(iPlayer)
				end
			end
		else	--done with this plan set
			if planSetNum < numPlanSets then
				planSetNum = planSetNum + 1
				planSet = planSets[planSetNum]
				plans = eaPlayer[planSet]
				planNum = 1
				planID = plans[1]
			else
				if numTechs >= min then
					break
				end
				planID = EACIVPLAN_GENERIC
				print("!!!! WARNING: AI resorting to generic plan for free techs !!!!")
			end
		end
	end
	return techList
end

TestTakeFreeTechs = function(player)
	--Strategy here is to take most expensive tech that is in our plans (that's what I would do)
	--AI prohibited from taking Tier 6 or 7; TO DO: stop human in UI if there is ever a free tech situation other than game start
	local freeTechs = player:GetNumFreeTechs()
	if freeTechs < 1 then return false end
	local iPlayer = player:GetID()
	TestSetContingencyPlans(iPlayer)

	print("Player has free tech(s); picking most expensive in current plans ", iPlayer, freeTechs)
	local iTeam = player:GetTeam()
	local team = Teams[iTeam]
	local teamTechs = team:GetTeamTechs()

	--not often >1, so no no need to optimize for that
	while 0 < freeTechs do
		local techList = GetCurrentlyResearchableTechsForPlans(iPlayer, freeTechs)
		--remove tier >5 from list (GridX >4)
		for index, techID in pairs(techList) do
			local techInfo = GameInfo.Technologies[techID]
			if techInfo.GridX > 4 then
				techList[index] = nil		--this breaks array sequence for techList, but that's OK because we don't need array below
			end
		end
		local GetResearchNeeded = function(techID)
			return teamTechs:GetResearchCost(techID) - teamTechs:GetResearchProgress(techID)
		end
		local bestTechID = GetBestOne(techList, false, false, GetResearchNeeded)
		team:SetHasTech(bestTechID, true)	
		freeTechs = freeTechs - 1	
	end
	player:SetNumFreeTechs(0)
	return true
end


TestDoPlans = function(iPlayer)					--clears out old plans (may do active stuff later)
	print("Running TestDoPlans ", iPlayer)
	local eaPlayer = gPlayers[iPlayer]
	local completedPlans = eaPlayer.aiCompletedCivPlans

	local bPlanFinished = false

	local planSetNum, planNum = 1, 1
	local planSet = planSets[1]
	local plans = eaPlayer[planSet]
	local planID = plans[1]	
	while true do
		if planID then
			if IsFinishedPlanTechsPolicies(iPlayer, planID) then		--and (not FinishPlan[planID] or FinishPlan[planID](iPlayer)) then
				--do generic finish stuff (build queues!)
				local numPlans = #plans
				for i = planNum, numPlans - 1 do
					plans[i] = plans[i + 1]
				end
				plans[numPlans] = nil
				completedPlans[#completedPlans + 1] = planID
				bPlanFinished = true
			else
				--do generic plan stuff (build queues!)
			end
			planNum = planNum + 1
			planID = plans[planNum]			
		else
			if planSetNum < numPlanSets then
				planSetNum = planSetNum + 1
				planSet = planSets[planSetNum]
				plans = eaPlayer[planSet]
				planNum = 1
				planID = plans[1]
			else
				break
			end		
		end
	end
	return bPlanFinished
end


--add specific InitPlan, CancelPlan, DoPlan or FinishPlan functions if needed
--DoPlan: return false if we need to reject and delete this plan for some reason; otherwise, do something (if needed) and return true
--FinishPlan: return false to prevent plan from finishing even if techs, policies done; otherwise, do something (if needed) and return true

