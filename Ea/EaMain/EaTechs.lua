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

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------

--constants
local BARB_PLAYER_INDEX =				BARB_PLAYER_INDEX	
local AI_FREE_TECHS =					GameInfo.HandicapInfos[Game:GetHandicapType()].EaAIFreeTechs

local EARACE_MAN =						GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =					GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =				GameInfoTypes.EARACE_HELDEOFOL
local EACIV_SISUKAS =					GameInfoTypes.EACIV_SISUKAS
local EA_WONDER_GREAT_LIBRARY =			GameInfoTypes.EA_WONDER_GREAT_LIBRARY
local EA_EPIC_VAFTHRUTHNISMAL =			GameInfoTypes.EA_EPIC_VAFTHRUTHNISMAL

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
local gg_playerArcaneMod = gg_playerArcaneMod


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
local g_playerKM = {}					--index by iPlayer

local g_playerTomeMods = {}				--index by iPlayer, techID
local g_playerFavoredTechMods = {}		--index by iPlayer, techID


--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------
local arcaneTechs = {}
for techInfo in GameInfo.Technologies() do
	if techInfo.EaArcane then
		arcaneTechs[techInfo.ID] = true
	end
end

local tomeTechs = {}
for row in GameInfo.EaArtifacts_TomeTechs() do
	local artifactID = GameInfoTypes[row.ArtifactType]
	local techID = GameInfoTypes[row.TechType]
	tomeTechs[artifactID] = tomeTechs[artifactID] or {}
	tomeTechs[artifactID][techID] = row.Change
end

local kmModifiers = {}
for eaCivInfo in GameInfo.EaCivs() do
	if eaCivInfo.KnowlMaintModifier ~= 0 then
		kmModifiers[eaCivInfo.ID] = eaCivInfo.KnowlMaintModifier
	end
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaTechsInit(bNewGame)
	print("Running EaTechsInit...")
	for iPlayer, eaPlayer in pairs(fullCivs) do
		g_playerKM[iPlayer] = 0
		gg_playerArcaneMod[iPlayer] = 0
		g_playerTomeMods[iPlayer] = {}
		g_playerFavoredTechMods[iPlayer] = {}
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
		for iPlayer, eaPlayer in pairs(fullCivs) do
			local player = Players[iPlayer]
			if player:HasPolicy(GameInfoTypes.POLICY_ARCANE_LORE) then
				gg_playerArcaneMod[iPlayer] = gg_playerArcaneMod[iPlayer] - 10
			end
			if player:HasPolicy(GameInfoTypes.POLICY_ARCANE_RESEARCH) then
				gg_playerArcaneMod[iPlayer] = gg_playerArcaneMod[iPlayer] - 20
			end
			if eaPlayer.eaCivNameID == GameInfoTypes.EACIV_LEMURIA then
				gg_playerArcaneMod[iPlayer] = gg_playerArcaneMod[iPlayer] - 20
			end
		end

		for iPlayer, eaPlayer in pairs(realCivs) do
			local player = Players[iPlayer]
			local team = Teams[player:GetTeam()]
			ResetPlayerFavoredTechs(iPlayer)
			gg_fishingRange[iPlayer] = 3
			gg_whalingRange[iPlayer] = 3
			gg_campRange[iPlayer] = 3
			if team:IsHasTech(GameInfoTypes.TECH_SHIP_BUILDING) then
				gg_fishingRange[iPlayer] = gg_fishingRange[iPlayer] + 2
				gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] + 2
			end
			if team:IsHasTech(GameInfoTypes.TECH_NAVIGATION) then
				gg_fishingRange[iPlayer] = gg_fishingRange[iPlayer] + 2
				gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] + 2
			end
			if team:IsHasTech(GameInfoTypes.TECH_WHALING) then
				gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] + 2
			end
			if team:IsHasTech(GameInfoTypes.TECH_TRACKING_TRAPPING) then
				gg_campRange[iPlayer] = gg_campRange[iPlayer] + 1
			end
			if team:IsHasTech(GameInfoTypes.TECH_ANIMAL_MASTERY) then
				gg_campRange[iPlayer] = gg_campRange[iPlayer] + 2
			end

			local nameID = eaPlayer.eaCivNameID
			if nameID == GameInfoTypes.EACIV_CRUITHNI then
				gg_campRange[iPlayer] = gg_campRange[iPlayer] + 1
			elseif nameID == GameInfoTypes.EACIV_DAGGOO then
				gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] + 2
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
	if kmModifiers[eaCivID] then
		techCount = techCount * (100 + kmModifiers[eaCivID]) / 100
	end
	local pop = player:GetTotalPopulation()
	g_playerKM[iPlayer] = Floor(KM_PER_TECH_PER_CITIZEN * techCount * pop + 0.5)

	--Tomes
	local tomeMods = g_playerTomeMods[iPlayer]
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
		local eaCivInfo = GameInfo.EaCivs[eaCivID]
		local eaCivType = eaCivInfo.Type
		local extraReduction = eaCivInfo.FavoredTechExtraReduction
		local favoredTechMods = g_playerFavoredTechMods[iPlayer]
		for techID in pairs(favoredTechMods) do
			favoredTechMods[techID] = nil
		end
		for row in GameInfo.EaCiv_FavoredTechs("EaCivType='" .. eaCivType .. "'") do
			favoredTechMods[GameInfoTypes[row.TechType] ] = FAVORED_TECH_COST_REDUCTION + extraReduction
		end
	end
end

local function OnPlayerTechCostMod(iPlayer, techID)		--Ea API
	--print("OnPlayerTechCostMod ", iPlayer, techID)
	if not fullCivs[iPlayer] then return 0 end
	local mod = g_playerKM[iPlayer]
	if g_playerFavoredTechMods[iPlayer][techID] then
		mod = mod + g_playerFavoredTechMods[iPlayer][techID]
	end
	if g_playerTomeMods[iPlayer][techID] then
		mod = mod + g_playerTomeMods[iPlayer][techID]
	end
	if arcaneTechs[techID] then
		mod = mod + gg_playerArcaneMod[iPlayer]
	elseif gEpics[EA_EPIC_VAFTHRUTHNISMAL] and gEpics[EA_EPIC_VAFTHRUTHNISMAL].iPlayer == iPlayer then
		mod = mod - gEpics[EA_EPIC_VAFTHRUTHNISMAL].mod
	end
	local greatLibrary = gWonders[EA_WONDER_GREAT_LIBRARY]
	if greatLibrary and greatLibrary.iPlayer == iPlayer then
		mod = mod - greatLibrary.mod
	end

	if mod < -50 then
		mod = -50 - Floor(50 * (mod + 50) / mod)		--below -50 becomes asymptotic to -100 (& dll sets min to -90)
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

	--debug
	print("DEBUG: eaPlayer.techCount, teamTechs:GetNumRealTechsKnown() = ", eaPlayer.techCount, teamTechs:GetNumRealTechsKnown())

	--zeroing
	eaPlayer.rpFromDiffusion = 0	--these are only used for display
	eaPlayer.rpFromConquest = 0

	if bAI then
		if (gameTurn + 1) % 50 == 0 and gameTurn / 50 <= AI_FREE_TECHS then	--1 free tech at turn 49, 99, 149,... until all free techs given
			
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



OnMajorPlayerTechLearned[GameInfoTypes.TECH_MALEFICIUM] = function(iPlayer)
	if gWorldUniqueAction[EA_ACTION_PROPHECY_VA] == -1 then
		BecomeFallen(iPlayer)
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_IRON_WORKING] = function(iPlayer)
	if gPlayers[iPlayer].eaCivNameID == EACIV_SISUKAS then
		local race = eaPlayer.race
		local unitTypeID
		if race == EARACE_MAN then
			unitTypeID = GameInfoTypes.UNIT_MEDIUM_INFANTRY_MAN
		elseif race == EARACE_SIDHE then
			unitTypeID = GameInfoTypes.UNIT_MEDIUM_INFANTRY_SIDHE
		elseif race == EARACE_HELDEOFOL then
			unitTypeID = GameInfoTypes.UNIT_MEDIUM_INFANTRY_ORC
		end
		local player = Players[iPlayer]
		local capital = player:GetCapitalCity()
		player:InitUnit(unitTypeID, capital:GetX(), capital:GetY())
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_METAL_CASTING] = function(iPlayer)
	if gPlayers[iPlayer].eaCivNameID == EACIV_SISUKAS then
		local race = eaPlayer.race
		local unitTypeID
		if race == EARACE_MAN then
			unitTypeID = GameInfoTypes.UNIT_HEAVY_INFANTRY_MAN
		elseif race == EARACE_SIDHE then
			unitTypeID = GameInfoTypes.UNIT_HEAVY_INFANTRY_SIDHE
		elseif race == EARACE_HELDEOFOL then
			unitTypeID = GameInfoTypes.UNIT_HEAVY_INFANTRY_ORC
		end
		local player = Players[iPlayer]
		local capital = player:GetCapitalCity()
		player:InitUnit(unitTypeID, capital:GetX(), capital:GetY())
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_MITHRIL_WORKING] = function(iPlayer)
	if gPlayers[iPlayer].eaCivNameID == EACIV_SISUKAS then
		local race = eaPlayer.race
		local unitTypeID
		if race == EARACE_MAN then
			unitTypeID = GameInfoTypes.UNIT_IMMORTALS_MAN
		elseif race == EARACE_SIDHE then
			unitTypeID = GameInfoTypes.UNIT_IMMORTALS_SIDHE
		elseif race == EARACE_HELDEOFOL then
			unitTypeID = GameInfoTypes.UUNIT_IMMORTALS_ORC
		end
		local player = Players[iPlayer]
		local capital = player:GetCapitalCity()
		player:InitUnit(unitTypeID, capital:GetX(), capital:GetY())
	end
end


OnMajorPlayerTechLearned[GameInfoTypes.TECH_SAILING] = function(iPlayer)
	local player = Players[iPlayer]
	for city in player:Cities() do
		TestNaturalHarborForFreeHarbor(city)	--city adjacent Natural Harbor gives plot ownership and harbor building
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_SHIP_BUILDING] = function(iPlayer)
	gg_fishingRange[iPlayer] = gg_fishingRange[iPlayer] + 2
	gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] + 2
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_NAVIGATION] = function(iPlayer)
	gg_fishingRange[iPlayer] = gg_fishingRange[iPlayer] + 2
	gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] + 2
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_WHALING] = function(iPlayer)
	gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] + 2
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_TRACKING_TRAPPING] = function(iPlayer)
	gg_campRange[iPlayer] = gg_campRange[iPlayer] + 1
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_ANIMAL_MASTERY] = function(iPlayer)
	gg_campRange[iPlayer] = gg_campRange[iPlayer] + 2
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

