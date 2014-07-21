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

local GameInfoTypes =					GameInfoTypes
local BUILDING_HARBOR =					GameInfoTypes.BUILDING_HARBOR
local EACIV_SISUKAS =					GameInfoTypes.EACIV_SISUKAS
local EARACE_MAN =						GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =					GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =				GameInfoTypes.EARACE_HELDEOFOL
local EA_WONDER_GREAT_LIBRARY =			GameInfoTypes.EA_WONDER_GREAT_LIBRARY
local EA_ARTIFACT_TOME_OF_TOMES =		GameInfoTypes.EA_ARTIFACT_TOME_OF_TOMES
local EA_EPIC_VAFTHRUTHNISMAL =			GameInfoTypes.EA_EPIC_VAFTHRUTHNISMAL

local POLICY_PANTHEISM =				GameInfoTypes.POLICY_PANTHEISM
local POLICY_SCHOLASTICISM = 			GameInfoTypes.POLICY_SCHOLASTICISM
local POLICY_ACADEMIC_TRADITION = 		GameInfoTypes.POLICY_ACADEMIC_TRADITION
local POLICY_RATIONALISM = 				GameInfoTypes.POLICY_RATIONALISM


--localized game and global tables
local Players = Players
local gPlayers = gPlayers
local playerType = MapModData.playerType
local fullCivs = MapModData.fullCivs
local realCivs =	MapModData.realCivs
local gg_fishingRange = gg_fishingRange
local gg_whalingRange = gg_whalingRange
local gg_campRange = gg_campRange
local gg_playerArcaneMod = gg_playerArcaneMod
local gg_regularCombatType = gg_regularCombatType
local gg_unitTier = gg_unitTier


--localized functions
local HandleError21 = HandleError21
local HandleError31 = HandleError31
local floor = math.floor

--file function tables
local OnTeamTechLearned = {}
local OnMajorPlayerTechLearned = {}
local TechReq = {}

--file shared
local g_iActivePlayer = Game.GetActivePlayer()

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
			if playerType[iPlayer] == "FullCiv" then
				if eaPlayer.race == EARACE_MAN then
					player:SetNumFreeTechs(1) --  works but without notification
					team:SetHasTech(GameInfoTypes.TECH_ALLOW_HORSE_TRADE, true)
				elseif eaPlayer.race == EARACE_SIDHE then
					eaPlayer.techCount = 2			-- 2 free given for race
					team:SetHasTech(GameInfoTypes.TECH_ALLOW_HORSE_TRADE, true)
				end
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
			ResetPlayerFavoredTechs(iPlayer)
		end

		for iPlayer, eaPlayer in pairs(realCivs) do
			local player = Players[iPlayer]
			local team = Teams[player:GetTeam()]
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

	--ResetTechCostMods(g_iActivePlayer)
end


--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function ResetTechCostMods(iPlayer)
	print("ResetTechCostMods ", iPlayer)
	if not fullCivs[iPlayer] then return end
	local player = Players[iPlayer]
	if not player:IsFoundedFirstCity() then return end
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer then return end

	--KM
	local techCount = eaPlayer.techCount
	local eaCivID = eaPlayer.eaCivNameID
	local kmPerTechPerCitizen = KM_PER_TECH_PER_CITIZEN
	if kmModifiers[eaCivID] then
		kmPerTechPerCitizen = kmPerTechPerCitizen * (100 + kmModifiers[eaCivID]) / 100
	end
	local totalPopulationForKM = player:GetTotalPopulation()
	g_playerKM[iPlayer] = floor(kmPerTechPerCitizen * techCount * totalPopulationForKM + 0.5)

	--Active player TopPanel UI info
	if iPlayer == g_iActivePlayer then
		MapModData.knowlMaint = g_playerKM[iPlayer]
		MapModData.techCount = techCount
		MapModData.kmPerTechPerCitizen = kmPerTechPerCitizen
		MapModData.totalPopulationForKM = totalPopulationForKM
		if kmPerTechPerCitizen ~= KM_PER_TECH_PER_CITIZEN then
			MapModData.KM_PER_TECH_PER_CITIZEN = KM_PER_TECH_PER_CITIZEN
		else
			MapModData.KM_PER_TECH_PER_CITIZEN = nil
		end
	end

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
					tomeMods[techID] = (tomeMods[techID] or 0) + floor(costChange * (tomeOfTomesMod * 0.2 + tomeMod) + 0.5)
				end
			end
		end
	end
end
LuaEvents.EaTechsResetTechCostMods.Add(ResetTechCostMods)


local function GetCostHelpForTech(iPlayer, techID)
	local str = ""
	if fullCivs[iPlayer] then	--allows tech tree view in autoplay

		--Favored Techs
		if g_playerFavoredTechMods[iPlayer][techID] then
			str = str .. "[NEWLINE][ICON_BULLET]Favored Tech: [COLOR_POSITIVE_TEXT]" .. g_playerFavoredTechMods[iPlayer][techID] .. "%[ENDCOLOR]"
		end

		--Tomes (complicated here to separate out Tome of Tomes)
		local tomeMods = g_playerTomeMods[iPlayer]
		if tomeMods[techID] and tomeMods[techID] ~= 0 then
			local tomeOfTomesStr = ""
			local tomeOfTomesMod = (gArtifacts[EA_ARTIFACT_TOME_OF_TOMES] and gArtifacts[EA_ARTIFACT_TOME_OF_TOMES].iPlayer == iPlayer) and gArtifacts[EA_ARTIFACT_TOME_OF_TOMES].mod or 0
			for artifactID, artifact in pairs(gArtifacts) do
				if tomeTechs[artifactID] then
					local tomeMod = artifact.iPlayer == iPlayer and artifact.mod or 0
					if tomeMod ~= 0 or tomeOfTomesMod ~= 0 then
						for testTechID, costChange in pairs(tomeTechs[artifactID]) do
							if testTechID == techID then
								if tomeMod ~= 0 then
									local costModFromTome = floor(costChange * tomeMod + 0.5)
									local tomeName = Locale.Lookup(GameInfo.EaArtifacts[artifactID].Description)
									str = str .. "[NEWLINE][ICON_BULLET]" .. tomeName .. ": [COLOR_POSITIVE_TEXT]" .. costModFromTome .. "%[ENDCOLOR]"
								end
								if tomeOfTomesMod ~= 0 then
									local costModFromTomeOfTomes = floor(costChange * (tomeOfTomesMod * 0.2) + 0.5)
									local tomeOfTomesName = Locale.Lookup(GameInfo.EaArtifacts[EA_ARTIFACT_TOME_OF_TOMES].Description)
									local tomeName = Locale.Lookup(GameInfo.EaArtifacts[artifactID].Description)
									tomeOfTomesStr = tomeOfTomesStr .. "[NEWLINE][ICON_BULLET]" .. tomeOfTomesName .. " (" .. tomeName .. "): [COLOR_POSITIVE_TEXT]" .. costModFromTomeOfTomes .. "%[ENDCOLOR]"
								end
								break
							end
						end
					end
				end
			end
			str = str .. tomeOfTomesStr
		end

		--Arcane bonuses
		if arcaneTechs[techID] then
			local player = Players[iPlayer]
			local eaPlayer = gPlayers[iPlayer]
			if player:HasPolicy(GameInfoTypes.POLICY_ARCANE_LORE) then
				str = str .. "[NEWLINE][ICON_BULLET]Arcane Lore: [COLOR_POSITIVE_TEXT]" .. -10 .. "%[ENDCOLOR]"
			end
			if player:HasPolicy(GameInfoTypes.POLICY_ARCANE_RESEARCH) then
				str = str .. "[NEWLINE][ICON_BULLET]Arcane Research: [COLOR_POSITIVE_TEXT]" .. -20 .. "%[ENDCOLOR]"
			end
			if eaPlayer.eaCivNameID == GameInfoTypes.EACIV_LEMURIA then
				str = str .. "[NEWLINE][ICON_BULLET]Arcane Tech (Lemuria): [COLOR_POSITIVE_TEXT]" .. -20 .. "%[ENDCOLOR]"
			end
	
		--Epic non-arcane bonus
		elseif gEpics[EA_EPIC_VAFTHRUTHNISMAL] and gEpics[EA_EPIC_VAFTHRUTHNISMAL].iPlayer == iPlayer then
			local epicName = Locale.Lookup(GameInfo.EaEpics[EA_EPIC_VAFTHRUTHNISMAL].Description)
			local costMod = - gEpics[EA_EPIC_VAFTHRUTHNISMAL].mod
			str = str .. "[NEWLINE][ICON_BULLET]" .. epicName .. ": [COLOR_POSITIVE_TEXT]" .. costMod .. "%[ENDCOLOR]"
		end

		--Great Library
		if gWonders[EA_WONDER_GREAT_LIBRARY] and gWonders[EA_WONDER_GREAT_LIBRARY].iPlayer == iPlayer then
			local wonderName = Locale.Lookup(GameInfo.EaWonders[EA_WONDER_GREAT_LIBRARY].Description)
			local costMod = -gWonders[EA_WONDER_GREAT_LIBRARY].mod
			str = str .. "[NEWLINE][ICON_BULLET]" .. wonderName .. ": [COLOR_POSITIVE_TEXT]" .. costMod .. "%[ENDCOLOR]"
		end

		--Total tech cost mod
		local totalTechCostMod = OnPlayerTechCostMod(iPlayer, techID)
		local colorCode = 0 < totalTechCostMod and "[COLOR_NEGATIVE_TEXT]" or "[COLOR_POSITIVE_TEXT]"
		str = str .. "[NEWLINE][ICON_BULLET]Total cost modifier including KM: " .. colorCode .. totalTechCostMod .. "%[ENDCOLOR]"
	end

	MapModData.costHelpForTech = str
end
LuaEvents.EaTechsGetCostHelpForTech.Add(GetCostHelpForTech)

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

function OnPlayerTechCostMod(iPlayer, techID)		--Ea API
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
		mod = -50 - floor(50 * (mod + 50) / mod)		--below -50 becomes asymptotic to -100 (& dll sets min to -90)
	end

	return mod
end
GameEvents.PlayerTechCostMod.Add(OnPlayerTechCostMod)


function TechPerCivTurn(iPlayer)
	print("TechPerCivTurn")
	local floor = math.floor
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local team = Teams[player:GetTeam()]
	local teamTechs = team:GetTeamTechs()
	local eaCivID = eaPlayer.eaCivNameID
	local bAI = not player:IsHuman()
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
					if not player:IsHuman() then
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

OnMajorPlayerTechLearned[GameInfoTypes.TECH_STEEL_WORKING] = function(iPlayer)
	local player = Players[iPlayer]
	for unit in player:Units() do
		local unitTypeID = unit:GetUnitType()
		if gg_regularCombatType[unitTypeID] == "troops" and 2 < gg_unitTier[unitTypeID] then
			if not unit:IsHasPromotion(GameInfoTypes.PROMOTION_STEEL_WEAPONS) and not unit:IsHasPromotion(GameInfoTypes.PROMOTION_MITHRIL_WEAPONS) then
				unit:SetBaseCombatStrength(unit:GetBaseCombatStrength() + 2)
				unit:SetHasPromotion(GameInfoTypes.PROMOTION_STEEL_WEAPONS, true)
			end
		end
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_MITHRIL_WORKING] = function(iPlayer)
	local player = Players[iPlayer]
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
		local capital = player:GetCapitalCity()
		player:InitUnit(unitTypeID, capital:GetX(), capital:GetY())
	end
	for unit in player:Units() do
		local unitTypeID = unit:GetUnitType()
		if gg_regularCombatType[unitTypeID] == "troops" and 4 < gg_unitTier[unitTypeID] then
			if not unit:IsHasPromotion(GameInfoTypes.PROMOTION_MITHRIL_WEAPONS) then
				if unit:IsHasPromotion(GameInfoTypes.PROMOTION_STEEL_WEAPONS) then
					unit:SetHasPromotion(GameInfoTypes.PROMOTION_STEEL_WEAPONS, false)
					unit:SetBaseCombatStrength(unit:GetBaseCombatStrength() + 2)
				else
					unit:SetBaseCombatStrength(unit:GetBaseCombatStrength() + 4)
				end
				unit:SetHasPromotion(GameInfoTypes.PROMOTION_MITHRIL_WEAPONS, true)
			end
		end
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

--------------------------------------------------
-- Active Player change
--------------------------------------------------

local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)