-- Techs
-- Author: Pazyryk
-- DateCreated: 6/28/2012 10:53:38 AM
--------------------------------------------------------------

print("Loading EaTechs.lua...")
local print = ENABLE_PRINT and print or function() end

--------------------------------------------------------------
-- Settings
--------------------------------------------------------------
--knowledge maintenence
local KM_PER_TECH_PER_CITIZEN =		EaSettings.KM_PER_TECH_PER_CITIZEN
local FAVORED_TECH_COST_REDUCTION = EaSettings.FAVORED_TECH_COST_REDUCTION

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------

--constants
local BARB_PLAYER_INDEX =				BARB_PLAYER_INDEX	
local AI_FREE_TECHS =					GameInfo.HandicapInfos[Game:GetHandicapType()].EaAIFreeTechs

local GameInfoTypes =					GameInfoTypes
local BUILDING_INTELLIGENT_ARCHIVE =	GameInfoTypes.BUILDING_INTELLIGENT_ARCHIVE
local EACIV_SISUKAS =					GameInfoTypes.EACIV_SISUKAS
local EARACE_MAN =						GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =					GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =				GameInfoTypes.EARACE_HELDEOFOL
local EA_ARTIFACT_TOME_OF_TOMES =		GameInfoTypes.EA_ARTIFACT_TOME_OF_TOMES
local EA_EPIC_VAFTHRUTHNISMAL =			GameInfoTypes.EA_EPIC_VAFTHRUTHNISMAL
local EA_WONDER_GREAT_LIBRARY =			GameInfoTypes.EA_WONDER_GREAT_LIBRARY
local EA_WONDER_ACADEMY_PHILOSOPHY =	GameInfoTypes.EA_WONDER_ACADEMY_PHILOSOPHY
local EA_WONDER_ACADEMY_LOGIC =			GameInfoTypes.EA_WONDER_ACADEMY_LOGIC
local EA_WONDER_ACADEMY_SEMIOTICS =		GameInfoTypes.EA_WONDER_ACADEMY_SEMIOTICS
local EA_WONDER_ACADEMY_METAPHYSICS =	GameInfoTypes.EA_WONDER_ACADEMY_METAPHYSICS
local EA_WONDER_ACADEMY_TRANS_THOUGHT =	GameInfoTypes.EA_WONDER_ACADEMY_TRANS_THOUGHT

local POLICY_PANTHEISM =				GameInfoTypes.POLICY_PANTHEISM

--localized game and global tables
local Players =					Players
local gPlayers =				gPlayers
local playerType =				MapModData.playerType
local fullCivs =				MapModData.fullCivs
local realCivs =				MapModData.realCivs
local gg_fishingRange =			gg_fishingRange
local gg_whalingRange =			gg_whalingRange
local gg_campRange =			gg_campRange
local gg_playerArcaneMod =		gg_playerArcaneMod
local gg_regularCombatType =	gg_regularCombatType
local gg_unitTier =				gg_unitTier
local gg_techTier =				gg_techTier
local gg_eaTechClass =			gg_eaTechClass

--localized functions
local HandleError10 =			HandleError10
local HandleError21 =			HandleError21
local HandleError31 =			HandleError31
local floor =					math.floor

--file shared
local g_iActivePlayer =			Game.GetActivePlayer()

--file tables
local g_playerKM = {}					--index by iPlayer
local g_kmByTech = {}					--index by iPlayer, techID
local g_playerTomeMods = {}				--index by iPlayer, techID
local g_playerFavoredTechMods = {}		--index by iPlayer, techID
local g_playerTechTierModifiers = {}	--index by iPlayer, tier

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------

local tomeTechs = {}		--index by artifactID, techIC
for row in GameInfo.EaArtifacts_TomeTechs() do
	local artifactID = GameInfoTypes[row.ArtifactType]
	local techID = GameInfoTypes[row.TechType]
	tomeTechs[artifactID] = tomeTechs[artifactID] or {}
	tomeTechs[artifactID][techID] = row.Change
end

local eaCivKMModifiers = {}		--index by eaCivID
for eaCivInfo in GameInfo.EaCivs() do
	if eaCivInfo.KnowlMaintModifier ~= 0 then
		eaCivKMModifiers[eaCivInfo.ID] = eaCivInfo.KnowlMaintModifier
	end
end

--------------------------------------------------------------
-- Local Functions
--------------------------------------------------------------

local function ResetTechCosts(iPlayer)		--stores both km and research cost effects in file tables (for lookup when asked)
	print("ResetTechCosts ", iPlayer)
	if not fullCivs[iPlayer] then return end
	local player = Players[iPlayer]
	if not player:IsFoundedFirstCity() then return end
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer then return end
	local bActivePlayer = iPlayer == g_iActivePlayer

	--global KM effects
	local population = player:GetTotalPopulation()
	local intelligentArchiveKMReduction = 0
	for city in player:Cities() do
		if city:GetNumBuilding(BUILDING_INTELLIGENT_ARCHIVE) == 1 then
			intelligentArchiveKMReduction = intelligentArchiveKMReduction + city:GetPopulation() / 3
		end
	end
	population = population - intelligentArchiveKMReduction

	local kmPerTech = KM_PER_TECH_PER_CITIZEN * population

	local civKMPercent = 0
	local civKMReduction = 0
	if eaCivKMModifiers[eaPlayer.eaCivNameID] then
		civKMPercent = -eaCivKMModifiers[eaPlayer.eaCivNameID]
		civKMReduction = kmPerTech * civKMPercent / 100
	end

	local greatLibraryKMPercent = 0
	local greatLibraryKMReduction = 0
	if gWonders[EA_WONDER_GREAT_LIBRARY] and gWonders[EA_WONDER_GREAT_LIBRARY].iPlayer == iPlayer then
		greatLibraryKMPercent = gWonders[EA_WONDER_GREAT_LIBRARY].mod
		greatLibraryKMReduction = kmPerTech * greatLibraryKMPercent / 100
	end

	local kmByTech = g_kmByTech[iPlayer]
	local favoredTechMods = g_playerFavoredTechMods[iPlayer]

	--tech counting and initial KM
	local techCount = 0
	for techID in pairs(eaPlayer.techs) do
		techCount = techCount + 1
		if favoredTechMods[techID] then
			kmByTech[techID] = kmPerTech * (100 + favoredTechMods[techID]) / 100 - civKMReduction - greatLibraryKMReduction
		else
			kmByTech[techID] = kmPerTech - civKMReduction - greatLibraryKMReduction
		end
	end

	--Academies
	local techTierModifiers = g_playerTechTierModifiers[iPlayer]
	if gWonders[EA_WONDER_ACADEMY_PHILOSOPHY] and gWonders[EA_WONDER_ACADEMY_PHILOSOPHY].iPlayer == iPlayer then
		local percentReduction = gWonders[EA_WONDER_ACADEMY_PHILOSOPHY].mod * 2
		techTierModifiers[3] = -percentReduction										--reduced tech cost for tier 3
		local kmPerTechReduction = kmPerTech * percentReduction / 100 
		for techID in pairs(eaPlayer.techs) do
			if gg_techTier[techID] == 2 then												--reduced km for tier 2
				kmByTech[techID] = kmByTech[techID] - kmPerTechReduction
			end
		end
	end
	if gWonders[EA_WONDER_ACADEMY_LOGIC] and gWonders[EA_WONDER_ACADEMY_LOGIC].iPlayer == iPlayer then
		local percentReduction = gWonders[EA_WONDER_ACADEMY_LOGIC].mod * 2
		techTierModifiers[4] = -percentReduction										--reduced tech cost for tier 4
		local kmPerTechReduction = kmPerTech * percentReduction / 100 
		for techID in pairs(eaPlayer.techs) do
			if gg_techTier[techID] == 3 then												--reduced km for tier 3
				kmByTech[techID] = kmByTech[techID] - kmPerTechReduction
			end
		end
	end
	if gWonders[EA_WONDER_ACADEMY_SEMIOTICS] and gWonders[EA_WONDER_ACADEMY_SEMIOTICS].iPlayer == iPlayer then
		local percentReduction = gWonders[EA_WONDER_ACADEMY_SEMIOTICS].mod * 2
		techTierModifiers[5] = -percentReduction										--reduced tech cost for tier 5
		local kmPerTechReduction = kmPerTech * percentReduction / 100 
		for techID in pairs(eaPlayer.techs) do
			if gg_techTier[techID] == 4 then												--reduced km for tier 4
				kmByTech[techID] = kmByTech[techID] - kmPerTechReduction
			end
		end
	end
	if gWonders[EA_WONDER_ACADEMY_METAPHYSICS] and gWonders[EA_WONDER_ACADEMY_METAPHYSICS].iPlayer == iPlayer then
		local percentReduction = gWonders[EA_WONDER_ACADEMY_METAPHYSICS].mod * 2
		techTierModifiers[6] = -percentReduction										--reduced tech cost for tier 6
		local kmPerTechReduction = kmPerTech * percentReduction / 100 
		for techID in pairs(eaPlayer.techs) do
			if gg_techTier[techID] == 5 then												--reduced km for tier 5
				kmByTech[techID] = kmByTech[techID] - kmPerTechReduction
			end
		end
	end
	if gWonders[EA_WONDER_ACADEMY_TRANS_THOUGHT] and gWonders[EA_WONDER_ACADEMY_TRANS_THOUGHT].iPlayer == iPlayer then
		local percentReduction = gWonders[EA_WONDER_ACADEMY_TRANS_THOUGHT].mod * 2
		techTierModifiers[7] = -percentReduction										--reduced tech cost for tier 7
		local kmPerTechReduction = kmPerTech * percentReduction / 100 
		for techID in pairs(eaPlayer.techs) do
			if gg_techTier[techID] == 6 then												--reduced km for tier 6
				kmByTech[techID] = kmByTech[techID] - kmPerTechReduction
			end
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
					local percentReduction = -costChange * (tomeMod + 0.2 * tomeOfTomesMod)
					tomeMods[techID] = (tomeMods[techID] or 0) - floor(percentReduction + 0.5)		--reduced tech cost
					if eaPlayer.techs[techID] then
						local kmPerTechReduction = kmPerTech * percentReduction / 100
						kmByTech[techID] = kmByTech[techID] - kmPerTechReduction					--reduced km
					end
				end
			end
		end
	end

	--sum up individual tech km's
	local totalKM = 0
	for techID in pairs(eaPlayer.techs) do
		totalKM = totalKM + kmByTech[techID]
	end
	totalKM = floor(totalKM + 0.5)

	g_playerKM[iPlayer] = totalKM

	--Active player TopPanel UI info
	if iPlayer == g_iActivePlayer then
		MapModData.knowlMaint = totalKM
		MapModData.techCount = techCount
		MapModData.totalPopulationForKM = population
		MapModData.intelligentArchiveKMReduction = intelligentArchiveKMReduction
		MapModData.kmPerTechPerCitizen = KM_PER_TECH_PER_CITIZEN
		MapModData.civKMPercent = civKMPercent
		MapModData.greatLibraryKMPercent = greatLibraryKMPercent
	end
end
LuaEvents.EaTechsResetTechCosts.Add(function(iPlayer) return HandleError10(ResetTechCosts, iPlayer) end)

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
	if gg_eaTechClass[techID] == "Arcane" or gg_eaTechClass[techID] == "ArcaneEvil" then
		mod = mod + gg_playerArcaneMod[iPlayer]					--arcane techs
	elseif gEpics[EA_EPIC_VAFTHRUTHNISMAL] and gEpics[EA_EPIC_VAFTHRUTHNISMAL].iPlayer == iPlayer then
		mod = mod - gEpics[EA_EPIC_VAFTHRUTHNISMAL].mod			--non-arcane techs only
	end

	if g_playerTechTierModifiers[iPlayer][gg_techTier[techID]] then
		mod = mod + g_playerTechTierModifiers[iPlayer][gg_techTier[techID]]
	end

	if mod < -50 then
		mod = -50 - 50 * (mod + 50) / mod		--below -50 becomes asymptotic to -100 (& dll sets min to -90)
	end

	return floor(mod)
end
local function X_OnPlayerTechCostMod(iPlayer, techID) return HandleError21(OnPlayerTechCostMod, iPlayer, techID) end
GameEvents.PlayerTechCostMod.Add(X_OnPlayerTechCostMod)

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaTechsInit(bNewGame)
	print("Running EaTechsInit...")
	for iPlayer, eaPlayer in pairs(fullCivs) do
		g_playerKM[iPlayer] = 0
		gg_playerArcaneMod[iPlayer] = 0
		g_kmByTech[iPlayer] = {}
		g_playerTomeMods[iPlayer] = {}
		g_playerFavoredTechMods[iPlayer] = {}
		g_playerTechTierModifiers[iPlayer] = {}
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
					eaPlayer.techs[GameInfoTypes.TECH_HUNTING] = true			-- 2 initial free techs don't fire OnTeamTechResearched, so set here
					eaPlayer.techs[GameInfoTypes.TECH_WRITING] = true
					team:SetHasTech(GameInfoTypes.TECH_ALLOW_HORSE_TRADE, true)
				end
			end
		end
	else
		for iPlayer, eaPlayer in pairs(fullCivs) do
			local player = Players[iPlayer]
			if player:HasPolicy(GameInfoTypes.POLICY_ARCANE_LORE) then
				gg_playerArcaneMod[iPlayer] = gg_playerArcaneMod[iPlayer] - 25
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

	--ResetTechCosts(g_iActivePlayer)
end

--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function TechPerCivTurn(iPlayer)
	print("TechPerCivTurn", iPlayer)
	local floor = math.floor
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local team = Teams[player:GetTeam()]
	local teamTechs = team:GetTeamTechs()
	local eaCivID = eaPlayer.eaCivNameID
	local bAI = not player:IsHuman()
	local gameTurn = Game.GetGameTurn()

	--v7a patch for negative progress
	for techID in pairs(gg_techTier) do
		if teamTechs:GetResearchProgress(techID) < 0 then
			print("!!!! ERROR: teamTechs had negative research progress (reseting to 0): ", teamTechs:GetResearchProgress(techID))
			teamTechs:SetResearchProgress(techID, 0, iPlayer)
		end
	end

	--zeroing
	eaPlayer.rpFromDiffusion = 0	--these are only used for display
	eaPlayer.rpFromConquest = 0

	if bAI then
		if (gameTurn + 1) % 50 == 0 and gameTurn / 50 <= AI_FREE_TECHS then	--1 free tech at turn 49, 99, 149,... until all free techs given
			
			player:SetNumFreeTechs(1)		--TO DO: Prevent high tier techs? Mod isn't compatible with unlimited free
		end
	end

	ResetTechCosts(iPlayer)

end

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

--------------------------------------------------------------
-- UI Interface
--------------------------------------------------------------

local NAME_ACADEMY_PHILOSOPHY = Locale.Lookup(GameInfo.EaWonders[EA_WONDER_ACADEMY_PHILOSOPHY].Description)
local NAME_ACADEMY_LOGIC = Locale.Lookup(GameInfo.EaWonders[EA_WONDER_ACADEMY_LOGIC].Description)
local NAME_ACADEMY_SEMIOTICS = Locale.Lookup(GameInfo.EaWonders[EA_WONDER_ACADEMY_SEMIOTICS].Description)
local NAME_ACADEMY_METAPHYSICS = Locale.Lookup(GameInfo.EaWonders[EA_WONDER_ACADEMY_METAPHYSICS].Description)
local NAME_ACADEMY_TRANS_THOUGHT = Locale.Lookup(GameInfo.EaWonders[EA_WONDER_ACADEMY_TRANS_THOUGHT].Description)
local NAME_TOME_OF_TOMES = Locale.Lookup(GameInfo.EaArtifacts[EA_ARTIFACT_TOME_OF_TOMES].Description)

local function GetTechCostHelp(iPlayer, techID, bKnown)
	--print("GetTechCostHelp ", iPlayer, techID, bKnown, g_kmByTech[iPlayer][techID])
	local tier = gg_techTier[techID]
	if not tier then return end		--Utility tech so it won't display anyway

	local str = ""
	if fullCivs[iPlayer] then	--allows tech tree view in autoplay

		if bKnown then			--show Knowledge Maintenance resulting from this tech
			if g_kmByTech[iPlayer][techID] then									--might not exist yet if player took free tech while in screen
				local km = floor(100 * g_kmByTech[iPlayer][techID]) / 100
				str = "[NEWLINE][ICON_BULLET]Knowledge Maintenance (this tech): [COLOR_NEGATIVE_TEXT]" .. km .. "%[ENDCOLOR]"
			end
		else					--show research cost modifiers in detail

			--Favored Techs
			if g_playerFavoredTechMods[iPlayer][techID] then
				str = str .. "[NEWLINE][ICON_BULLET]Favored Tech: [COLOR_POSITIVE_TEXT]" .. g_playerFavoredTechMods[iPlayer][techID] .. "%[ENDCOLOR]"
			end

			--Academies
			if tier == 3 then
				if gWonders[EA_WONDER_ACADEMY_PHILOSOPHY] and gWonders[EA_WONDER_ACADEMY_PHILOSOPHY].iPlayer == iPlayer then
					local percentReduction = gWonders[EA_WONDER_ACADEMY_PHILOSOPHY].mod * 2
					str = str .. "[NEWLINE][ICON_BULLET]" .. NAME_ACADEMY_PHILOSOPHY .. ": [COLOR_POSITIVE_TEXT]" .. -percentReduction .. "%[ENDCOLOR]"
				end
			elseif tier == 4 then
				if gWonders[EA_WONDER_ACADEMY_LOGIC] and gWonders[EA_WONDER_ACADEMY_LOGIC].iPlayer == iPlayer then
					local percentReduction = gWonders[EA_WONDER_ACADEMY_LOGIC].mod * 2
					str = str .. "[NEWLINE][ICON_BULLET]" .. NAME_ACADEMY_LOGIC .. ": [COLOR_POSITIVE_TEXT]" .. -percentReduction .. "%[ENDCOLOR]"
				end
			elseif tier == 5 then
				if gWonders[EA_WONDER_ACADEMY_SEMIOTICS] and gWonders[EA_WONDER_ACADEMY_SEMIOTICS].iPlayer == iPlayer then
					local percentReduction = gWonders[EA_WONDER_ACADEMY_SEMIOTICS].mod * 2
					str = str .. "[NEWLINE][ICON_BULLET]" .. NAME_ACADEMY_SEMIOTICS .. ": [COLOR_POSITIVE_TEXT]" .. -percentReduction .. "%[ENDCOLOR]"
				end
			elseif tier == 6 then
				if gWonders[EA_WONDER_ACADEMY_METAPHYSICS] and gWonders[EA_WONDER_ACADEMY_METAPHYSICS].iPlayer == iPlayer then
					local percentReduction = gWonders[EA_WONDER_ACADEMY_METAPHYSICS].mod * 2
					str = str .. "[NEWLINE][ICON_BULLET]" .. NAME_ACADEMY_METAPHYSICS .. ": [COLOR_POSITIVE_TEXT]" .. -percentReduction .. "%[ENDCOLOR]"
				end
			elseif tier == 7 then
				if gWonders[EA_WONDER_ACADEMY_TRANS_THOUGHT] and gWonders[EA_WONDER_ACADEMY_TRANS_THOUGHT].iPlayer == iPlayer then
					local percentReduction = gWonders[EA_WONDER_ACADEMY_TRANS_THOUGHT].mod * 2
					str = str .. "[NEWLINE][ICON_BULLET]" .. NAME_ACADEMY_TRANS_THOUGHT .. ": [COLOR_POSITIVE_TEXT]" .. -percentReduction .. "%[ENDCOLOR]"
				end
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
										local tomeName = Locale.Lookup(GameInfo.EaArtifacts[artifactID].Description)
										tomeOfTomesStr = tomeOfTomesStr .. "[NEWLINE][ICON_BULLET]" .. NAME_TOME_OF_TOMES .. " (" .. tomeName .. "): [COLOR_POSITIVE_TEXT]" .. costModFromTomeOfTomes .. "%[ENDCOLOR]"
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
			if gg_eaTechClass[techID] == "Arcane" or gg_eaTechClass[techID] == "ArcaneEvil" then
				local player = Players[iPlayer]
				local eaPlayer = gPlayers[iPlayer]
				if player:HasPolicy(GameInfoTypes.POLICY_ARCANE_LORE) then
					str = str .. "[NEWLINE][ICON_BULLET]Arcane Lore: [COLOR_POSITIVE_TEXT]" .. -25 .. "%[ENDCOLOR]"
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

			--Total tech cost mod
			local totalTechCostMod = OnPlayerTechCostMod(iPlayer, techID)
			local colorCode = 0 < totalTechCostMod and "[COLOR_NEGATIVE_TEXT]" or "[COLOR_POSITIVE_TEXT]"
			str = str .. "[NEWLINE][ICON_BULLET]Total cost modifier including KM: " .. colorCode .. totalTechCostMod .. "%[ENDCOLOR]"
		end
	end

	MapModData.techCostHelp = str
end
LuaEvents.EaTechsGetTechCostHelp.Add(function(iPlayer, techID, bKnown) return HandleError31(GetTechCostHelp, iPlayer, techID, bKnown) end)

--------------------------------------------------------------
-- GameEvents
--------------------------------------------------------------

-- On tech dicovery

local OnTeamTechLearned = {}
local OnMajorPlayerTechLearned = {}

local function OnTeamTechResearched(iTeam, techID, iLearned)
	print("Running OnTeamTechResearched ", iTeam, techID, iLearned)

	if iLearned ~= 1 then return end		-- -1 for removed tech
	local tier = gg_techTier[techID]
	if not tier then return end				-- well exit for any Utility tech

	if iTeam == BARB_PLAYER_INDEX then
		UpdateBarbTech(techID)
	else
		if OnTeamTechLearned[techID] then
			OnTeamTechLearned[techID](iTeam)
		end

		for iPlayer, eaPlayer in pairs(fullCivs) do
			local player = Players[iPlayer]
			if player:GetTeam() == iTeam then

				--remember non-utility techs for quick KM calculation
				eaPlayer.techs[techID] = true
				if not player:IsHuman() then
					if player:GetLengthResearchQueue() < 2 then			--still 1 in queue if just gained this one as free tech 
						AIPushTechsFromCivPlans(iPlayer, false)
					end
				end

				--maleficium changes
				if gg_eaTechClass[techID] == "ArcaneEvil" then
					ChangeMaleficiumLevelWithTests(iPlayer, tier)
				elseif gg_eaTechClass[techID] == "Divine" then			--  -1 for each teir level learned
					ChangeMaleficiumLevelWithTests(iPlayer, -tier)
				elseif gg_eaTechClass[techID] == "Arcane" then
					ChangeMaleficiumLevelWithTests(iPlayer, -floor(tier / 1.5))		-- function will give only the apropriate + or - effect
					ChangeMaleficiumLevelWithTests(iPlayer, floor(tier / 2))
				else
					ChangeMaleficiumLevelWithTests(iPlayer, -floor(tier / 2.5))	
				end

				--tech-specific effects
				if OnMajorPlayerTechLearned[techID] then
					OnMajorPlayerTechLearned[techID](iPlayer)
				end
			end
		end

	end
end
local function X_OnTeamTechResearched(iTeam, techID, _) return HandleError31(OnTeamTechResearched, iTeam, techID, _) end
GameEvents.TeamTechResearched.Add(X_OnTeamTechResearched)



OnTeamTechLearned[GameInfoTypes.TECH_SAILING] = function(iTeam)
	local team = Teams[iTeam]
	team:SetHasTech(GameInfoTypes.TECH_ALLOW_TIMBER_TRADE, true)
end
OnTeamTechLearned[GameInfoTypes.TECH_MATHEMATICS] = OnTeamTechLearned[GameInfoTypes.TECH_SAILING]
OnTeamTechLearned[GameInfoTypes.TECH_ARCHERY] = OnTeamTechLearned[GameInfoTypes.TECH_SAILING]

OnTeamTechLearned[GameInfoTypes.TECH_REANIMATION] = function(iTeam)
	if gWorld.evilControl == "NewGame" then
		gWorld.evilControl = "Ready"
	end
end
OnTeamTechLearned[GameInfoTypes.TECH_SORCERY] = OnTeamTechLearned[GameInfoTypes.TECH_REANIMATION]

OnMajorPlayerTechLearned[GameInfoTypes.TECH_MALEFICIUM] = function(iPlayer)
	if gWorld.evilControl == "Open" then
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
		if gg_regularCombatType[unitTypeID] == "troops" and gg_unitTier[unitTypeID] and 2 < gg_unitTier[unitTypeID] then
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
		if gg_regularCombatType[unitTypeID] == "troops" and gg_unitTier[unitTypeID] and 4 < gg_unitTier[unitTypeID] then
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

OnMajorPlayerTechLearned[GameInfoTypes.TECH_KNOWLEDGE_OF_HEAVEN] = function(iPlayer)
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer.manaToSealAhrimansVault or eaPlayer.manaToSealAhrimansVault > 10000 then
		eaPlayer.manaToSealAhrimansVault = 10000
	end
end

OnMajorPlayerTechLearned[GameInfoTypes.TECH_ESOTERIC_ARCANA] = function(iPlayer)
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer.manaToSealAhrimansVault or eaPlayer.manaToSealAhrimansVault > 10000 then
		eaPlayer.manaToSealAhrimansVault = 10000
	end
end

-- Tech prereq control

--[[
local TechReq = {}
local function OnPlayerCanResearch(iPlayer, techID)
	if not gPlayers[iPlayer] then return true end		--observer player during autoplay



	if TechReq[techID] and not TechReq[techID](iPlayer) then return false end
	return true
end
local function X_OnPlayerCanResearch(iPlayer, techID) return HandleError21(OnPlayerCanResearch, iPlayer, techID) end
GameEvents.PlayerCanResearch.Add(X_OnPlayerCanResearch)
]]


local EverTechReq = {}

local function OnPlayerCanEverResearch(iPlayer, techID)
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer then return true end		--observer player during autoplay

	--eaTechClass blocks
	if gg_eaTechClass[techID] == "ArcaneEvil" then
		if eaPlayer.bRenouncedMaleficium then return false end
		if 3 < gg_techTier[techID] and gWorld.evilControl ~= "Open" then return false end
		if gWorld.evilControl == "Sealed" then return false end
	elseif gg_eaTechClass[techID] == "Divine" then
		if not eaPlayer.bUsesDivineFavor then return false end
	end

	if EverTechReq[techID] and not EverTechReq[techID](iPlayer) then return false end
	return true
end
local function X_OnPlayerCanEverResearch(iPlayer, techID) return HandleError21(OnPlayerCanEverResearch, iPlayer, techID) end
GameEvents.PlayerCanEverResearch.Add(X_OnPlayerCanEverResearch)


EverTechReq[GameInfoTypes.TECH_UNDERDARK_PATHS] = function(iPlayer)
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