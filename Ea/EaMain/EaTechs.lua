-- Techs
-- Author: Pazyryk
-- DateCreated: 6/28/2012 10:53:38 AM
--------------------------------------------------------------

print("Loading EaTechs.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- Settings
--------------------------------------------------------------
--knowledge maintenence
local KM_PER_TECH_PER_CITIZEN = 0.1
local FAVORED_TECH_COST_REDUCTION = -20


--local KM_PER_TECH = 4.5
--local KM_FREE_TECHS = 4
--local KM_DISCOUNT_FROM_KNOWLEGE_TECHS = 0.3

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------

--constants
local BARB_PLAYER_INDEX =					BARB_PLAYER_INDEX	
local AI_FREE_TECHS =					GameInfo.HandicapInfos[Game:GetHandicapType()].EaAIFreeTechs

local EARACE_MAN =						GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =					GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =				GameInfoTypes.EARACE_HELDEOFOL
local EACIV_YS =						GameInfoTypes.EACIV_YS
local POLICY_PANTHEISM =				GameInfoTypes.POLICY_PANTHEISM

local POLICY_SCHOLASTICISM = 			GameInfoTypes.POLICY_SCHOLASTICISM
local POLICY_ACADEMIC_TRADITION = 		GameInfoTypes.POLICY_ACADEMIC_TRADITION
local POLICY_RATIONALISM = 				GameInfoTypes.POLICY_RATIONALISM
local BUILDING_HARBOR =					GameInfoTypes.BUILDING_HARBOR

local EA_ARTIFACT_TOME_OF_TOMES =		GameInfoTypes.EA_ARTIFACT_TOME_OF_TOMES

--localized game and global tables
local playerType = MapModData.playerType
local bFullCivAI = MapModData.bFullCivAI
local fullCivs = MapModData.fullCivs
local realCivs =	MapModData.realCivs
local gg_fishingRange = gg_fishingRange
local gg_whalingRange = gg_whalingRange
local gg_campRange = gg_campRange


--localized functions
local HandleError21 = HandleError21
local HandleError31 = HandleError31
local Floor = math.floor

--file function tables
local OnTeamTechLearned = {}
local OnMajorPlayerTechLearned = {}
local TechReq = {}

--file shared
local bInitialized = false

--file tables
local playerKM = {}					--index by iPlayer
local playerTomeMods = {}			--index by iPlayer, techID
local playerFavoredTechMods = {}		--index by iPlayer, techID


--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------
local tomeTechs = {}
for row in GameInfo.EaArtifacts_TomeTechs() do
	local artifactID = GameInfoTypes[row.ArtifactType]
	local techID = GameInfoTypes[row.TechType]
	tomeTechs[artifactID] = tomeTechs[artifactID] or {}
	tomeTechs[artifactID][techID] = row.Change
end



--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaTechsInit(bNewGame)
	print("Running EaTechsInit...")
	for iPlayer, eaPlayer in pairs(fullCivs) do
		playerKM[iPlayer] = 0
		playerTomeMods[iPlayer] = {}
		playerFavoredTechMods[iPlayer] = {}
	end
	if bNewGame then
		for iPlayer, eaPlayer in pairs(realCivs) do
			local player = Players[iPlayer]
			local team = Teams[player:GetTeam()]
			--team:SetHasTech(GameInfoTypes.TECH_SLASH_BURN_FOREST, true)	--, iPlayer, false, false)
			gg_fishingRange[iPlayer] = 3
			gg_whalingRange[iPlayer] = 3
			gg_campRange[iPlayer] = 3
			local civID = player:GetCivilizationType()
			if playerType[iPlayer] == "FullCiv" and eaPlayer.race == EARACE_MAN then
				player:SetNumFreeTechs(1) --  works but without notification
			end
			if eaPlayer.race == EARACE_MAN or eaPlayer.race == EARACE_SIDHE then
				team:SetHasTech(GameInfoTypes.TECH_ALLOW_HORSE_TRADE, true)		--Heldeofol can't trade or use horses
			end
		end
	else
		for iPlayer, eaPlayer in pairs(realCivs) do
			local player = Players[iPlayer]
			local team = Teams[player:GetTeam()]
			ResetPlayerFavoredTechs(iPlayer)
			gg_fishingRange[iPlayer] = 3
			gg_whalingRange[iPlayer] = 3
			gg_campRange[iPlayer] = 3
			if team:IsHasTech(GameInfoTypes.TECH_NAVIGATION) then
				gg_fishingRange[iPlayer] = 9
				gg_whalingRange[iPlayer] = 9
			elseif team:IsHasTech(GameInfoTypes.TECH_SHIP_BUILDING) then
				gg_fishingRange[iPlayer] = 7
				gg_whalingRange[iPlayer] = 7
			elseif team:IsHasTech(GameInfoTypes.TECH_SAILING) then
				gg_fishingRange[iPlayer] = 5
				gg_whalingRange[iPlayer] = 5
			end
			if team:IsHasTech(GameInfoTypes.TECH_WHALING) then
				gg_whalingRange[iPlayer] = 11
			end
			if team:IsHasTech(GameInfoTypes.TECH_ANIMAL_MASTERY) then
				gg_campRange[iPlayer] = 7
			elseif team:IsHasTech(GameInfoTypes.TECH_TRACKING_TRAPPING) then
				gg_campRange[iPlayer] = 5
			end
		end
	end


	bInitialized = true
end


--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

local function ResetTechCostMods(iPlayer)
	print("ResetTechCostMods ", iPlayer)
	if not fullCivs[iPlayer] then return end
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer then return end

	--KM
	local techCount = eaPlayer.techCount
	local eaCivID = eaPlayer.eaCivNameID
	if eaCivID == EACIV_YS then
		techCount = 0.667 * techCount
	end
	local pop = player:GetTotalPopulation()
	playerKM[iPlayer] = Floor(KM_PER_TECH_PER_CITIZEN * techCount * pop + 0.5)

	--Tomes
	local tomeMods = playerTomeMods[iPlayer]
	for techID in pairs(tomeMods) do
		tomeMods[techID] = 0
	end
	local tomeOfTomesMod = (gArtifacts[EA_ARTIFACT_TOME_OF_TOMES] and gArtifacts[EA_ARTIFACT_TOME_OF_TOMES].iPlayer == iPlayer) and gArtifacts[EA_ARTIFACT_TOME_OF_TOMES].mod or 0
	for artifactID, artifact in pairs(gArtifacts) do
		if tomeTechs[artifactID] then
			local tomeMod = artifact.iPlayer == iPlayer and artifact.mod or 0
			if tomeMod ~= 0 or tomeOfTomesMod ~= 0 then
				for techID, costChange in pairs(tomeTechs[artifactID]) do
					tomeMods[techID] = (tomeMods[techID] or 0) + Floor(costChange * (tomeOfTomesMod * 0.2 + tomeMod) + 0.5)
				end
			end
		end
	end
end
LuaEvents.EaTechsResetTechCostMods.Add(ResetTechCostMods)

function ResetPlayerFavoredTechs(iPlayer)	--only need at game load and once at naming, so no caching
	print("ResetPlayerFavoredTechs ", iPlayer)
	local eaPlayer = gPlayers[iPlayer]
	local eaCivID = eaPlayer.eaCivNameID
	if eaCivID then
		local eaCivType = GameInfo.EaCivs[eaCivID].Type
		local favoredTechMods = playerFavoredTechMods[iPlayer]
		for techID in pairs(favoredTechMods) do
			favoredTechMods[techID] = nil
		end
		for row in GameInfo.EaCiv_FavoredTechs("EaCivType='" .. eaCivType .. "'") do
			favoredTechMods[GameInfoTypes[row.TechType] ] = FAVORED_TECH_COST_REDUCTION
		end
	end
end

local function OnPlayerTechCostMod(iPlayer, techID)
	--print("OnPlayerTechCostMod ", iPlayer, techID)
	if not fullCivs[iPlayer] then return 0 end
	local mod = playerKM[iPlayer]
	if playerFavoredTechMods[iPlayer][techID] then
		mod = mod + playerFavoredTechMods[iPlayer][techID]
	end
	if playerTomeMods[iPlayer][techID] then
		mod = mod + playerTomeMods[iPlayer][techID]
	end
	return mod
end
GameEvents.PlayerTechCostMod.Add(OnPlayerTechCostMod)


function TechPerCivTurn(iPlayer)
	print("TechPerCivTurn")
	local Floor = math.floor
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local team = Teams[player:GetTeam()]
	local teamTechs = team:GetTeamTechs()
	local eaCivID = eaPlayer.eaCivNameID
	local bAI = bFullCivAI[iPlayer]
	local gameTurn = Game.GetGameTurn()
	--zeroing
	eaPlayer.rpFromDiffusion = 0	--these are only used for display
	eaPlayer.rpFromConquest = 0

	if bAI then
		if gameTurn % 49 == 0 and gameTurn / 50 < AI_FREE_TECHS then	--1 free tech at turn 49, 99, 149,... until all free techs given
			player:SetNumFreeTechs(1)		--TO DO: Prevent high tier techs? Mod isn't compatible with unlimited free
		end
	end

	ResetTechCostMods(iPlayer)

end

function OnTeamTechResearched(iTeam, techID, _)
	print("Running OnTeamTechResearched ", iTeam, techID, _)

	if iTeam == BARB_PLAYER_INDEX then
		UpdateBarbTech(techID)
	else
		if OnTeamTechLearned[techID] then
			OnTeamTechLearned[techID](iTeam)
		end
		if OnMajorPlayerTechLearned[techID] then
			for iPlayer, eaPlayer in pairs(fullCivs) do
				local player = Players[iPlayer]
				if player:GetTeam() == iTeam then
					OnMajorPlayerTechLearned[techID](iPlayer)
				end
			end
		end

		--count non-utility techs for Research Maint and scoring
		local techInfo = GameInfo.Technologies[techID]
		if not techInfo.Utility then
			--faster to cycle through players here then all techs every player turn
			for iPlayer, eaPlayer in pairs(fullCivs) do
				local player = Players[iPlayer]
				if player:GetTeam() == iTeam then
					Dprint("Adding to techCount for iPlayer ", iPlayer, eaPlayer.techCount + 1)
					eaPlayer.techCount = eaPlayer.techCount + 1
					if bFullCivAI[iPlayer] then
						if player:GetLengthResearchQueue() < 2 then			--still 1 in queue if just gained this one as free tech 
							AIPushTechsFromCivPlans(iPlayer, false)
						end
					end
				end
			end
		end
	end
end
GameEvents.TeamTechResearched.Add(function(iTeam, techID, _) return HandleError31(OnTeamTechResearched, iTeam, techID, _) end)

local function OnPlayerCanEverResearch(iPlayer, techTypeID)
	if not gPlayers[iPlayer] then return true end		--observer player during autoplay
	if TechReq[techTypeID] and not TechReq[techTypeID](iPlayer) then return false end
	return true
end
GameEvents.PlayerCanEverResearch.Add(function(iPlayer, techTypeID) return HandleError21(OnPlayerCanEverResearch, iPlayer, techTypeID) end)

--Use this?:
--GameEvents.PlayerCanResearch(playerID, techTypeID); (TestAll)
--------------------------------------------------------------
-- File Functions
--------------------------------------------------------------

OnTeamTechLearned[GameInfoTypes.TECH_SAILING] = function(iTeam)
	local team = Teams[iTeam]
	team:SetHasTech(GameInfoTypes.TECH_ALLOW_TIMBER_TRADE, true)
end
OnTeamTechLearned[GameInfoTypes.TECH_MATHEMATICS] = OnTeamTechLearned[GameInfoTypes.TECH_SAILING]
OnTeamTechLearned[GameInfoTypes.TECH_ARCHERY] = OnTeamTechLearned[GameInfoTypes.TECH_SAILING]


OnTeamTechLearned[GameInfoTypes.TECH_MALEFICIUM] = function(iTeam)
	gWorld.maleficium = "Learned"
end

--Pan/Non-Pan checks must be done on policy side too (for pan-swap after tech)
--[[
OnMajorPlayerTechLearned[GameInfoTypes.TECH_BRONZE_WORKING] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	team:SetHasTech(GameInfoTypes.TECH_SLASH_BURN_FOREST, false)
	if not player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_CHOP_FOREST, true)
		team:SetHasTech(GameInfoTypes.TECH_SLASH_BURN_JUNGLE, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_IRON_WORKING] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	team:SetHasTech(GameInfoTypes.TECH_SLASH_BURN_FOREST, false)
	team:SetHasTech(GameInfoTypes.TECH_SLASH_BURN_JUNGLE, false)
	if not player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_CHOP_JUNGLE, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_AGRICULTURE] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_AGRICULTURE_PAN, true)
		team:SetHasTech(GameInfoTypes.TECH_AGRICULTURE_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_AGRICULTURE_PAN, false)
		team:SetHasTech(GameInfoTypes.TECH_AGRICULTURE_NO_PAN, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_DOMESTICATION] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_DOMESTICATION_PAN, true)
		team:SetHasTech(GameInfoTypes.TECH_DOMESTICATION_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_DOMESTICATION_PAN, false)
		team:SetHasTech(GameInfoTypes.TECH_DOMESTICATION_NO_PAN, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_MINING] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_MINING_PAN, true)
		team:SetHasTech(GameInfoTypes.TECH_MINING_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_MINING_PAN, false)
		team:SetHasTech(GameInfoTypes.TECH_MINING_NO_PAN, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_MILLING] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_MILLING_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_MILLING_NO_PAN, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_WEAVING] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_WEAVING_PAN, true)
		team:SetHasTech(GameInfoTypes.TECH_WEAVING_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_WEAVING_PAN, false)
		team:SetHasTech(GameInfoTypes.TECH_WEAVING_NO_PAN, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_ZYMURGY] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_ZYMURGY_PAN, true)
		team:SetHasTech(GameInfoTypes.TECH_ZYMURGY_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_ZYMURGY_PAN, false)
		team:SetHasTech(GameInfoTypes.TECH_ZYMURGY_NO_PAN, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_IRRIGATION] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_IRRIGATION_PAN, true)
		team:SetHasTech(GameInfoTypes.TECH_IRRIGATION_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_IRRIGATION_PAN, false)
		team:SetHasTech(GameInfoTypes.TECH_IRRIGATION_NO_PAN, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_CALENDAR] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_CALENDAR_PAN, true)
		team:SetHasTech(GameInfoTypes.TECH_CALENDAR_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_CALENDAR_PAN, false)
		team:SetHasTech(GameInfoTypes.TECH_CALENDAR_NO_PAN, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_MASONRY] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_MASONRY_PAN, true)
		team:SetHasTech(GameInfoTypes.TECH_MASONRY_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_MASONRY_PAN, false)
		team:SetHasTech(GameInfoTypes.TECH_MASONRY_NO_PAN, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_CROP_ROTATION] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_CROP_ROTATION_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_CROP_ROTATION_NO_PAN, true)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_FORESTRY] = function(iPlayer)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	if player:HasPolicy(POLICY_PANTHEISM) then
		team:SetHasTech(GameInfoTypes.TECH_FORESTRY_NO_PAN, false)
	else
		team:SetHasTech(GameInfoTypes.TECH_FORESTRY_NO_PAN, true)
	end
end
]]

OnMajorPlayerTechLearned[GameInfoTypes.TECH_MALEFICIUM] = function(iPlayer)
	if gWorldUniqueAction[EA_ACTION_PROPHECY_VA] == -1 then
		BecomeFallen(iPlayer)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_SAILING] = function(iPlayer)
	gg_fishingRange[iPlayer] = gg_fishingRange[iPlayer] < 5 and 5 or gg_fishingRange[iPlayer]
	gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] < 5 and 5 or gg_whalingRange[iPlayer]
	--city adjacent Natural Harbor gives plot ownership and harbor building
	local player = Players[iPlayer]
	for city in player:Cities() do
		if city:IsCoastal(5) then
			print("Testing city for natural harbor")
			local bHasNaturalHarbor = false
			for x, y in PlotToRadiusIterator(city:GetX(), city:GetY(), 1, nil, nil, true) do
				local plot = Map.GetPlot(x, y)
				print("plot x y = ", x, y)
				if plot:IsWater() and not plot:IsLake() then
					local adjLandPlots = 0
					for adjX, adjY in PlotToRadiusIterator(x, y, 1, nil, nil, true) do
						local adjPlot = Map.GetPlot(adjX, adjY)
						if not adjPlot:IsWater() then
							adjLandPlots = adjLandPlots + 1
						end
					end
					print(" -number surrounding land = ", adjLandPlots)
					if 3 < adjLandPlots then
						bHasNaturalHarbor = true
						plot:SetOwner(iPlayer, city:GetID())
					end
				end
			end
			if bHasNaturalHarbor then
				city:SetNumRealBuilding(BUILDING_HARBOR, 1)
			end
		end
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_SHIP_BUILDING] = function(iPlayer)
	gg_fishingRange[iPlayer] = gg_fishingRange[iPlayer] < 7 and 7 or gg_fishingRange[iPlayer]
	gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] < 7 and 7 or gg_whalingRange[iPlayer]
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_NAVIGATION] = function(iPlayer)
	gg_fishingRange[iPlayer] = gg_fishingRange[iPlayer] < 9 and 9 or gg_fishingRange[iPlayer]
	gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] < 9 and 9 or gg_whalingRange[iPlayer]
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_WHALING] = function(iPlayer)
	gg_whalingRange[iPlayer] = 11
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_TRACKING_TRAPPING] = function(iPlayer)
	gg_campRange[iPlayer] = gg_campRange[iPlayer] < 5 and 5 or gg_campRange[iPlayer]
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_ANIMAL_MASTERY] = function(iPlayer)
	gg_campRange[iPlayer] = gg_campRange[iPlayer] < 7 and 7 or gg_campRange[iPlayer]
end


TechReq[GameInfoTypes.TECH_DIVINE_LITURGY] = function(iPlayer)
	local eaPlayer = gPlayers[iPlayer]
	return eaPlayer.race == EARACE_MAN and not eaPlayer.bIsFallen
end

TechReq[GameInfoTypes.TECH_MALEFICIUM] = function(iPlayer)
	if gWorld.maleficium == "Blocked" then return false end
	return true
end

TechReq[GameInfoTypes.TECH_UNDERDARK_PATHS] = function(iPlayer)
	if gWorld.bSurfacerDiscoveredDeepMining then
		local eaPlayer = gPlayers[iPlayer]
		if eaPlayer.race ~= EARACE_HELDEOFOL then return false end
	end
	return false	--Disabled for now...
end

