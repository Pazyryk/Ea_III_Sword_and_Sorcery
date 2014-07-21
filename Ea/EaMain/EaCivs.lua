-- EaCivs
-- Author: Pazyryk
-- DateCreated: 6/28/2012 11:10:02 AM
--------------------------------------------------------------

print("Loading EaCivs.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

--constants
local MAX_MAJOR_CIVS =							GameDefines.MAX_MAJOR_CIVS	

local EACIV_DAIRINE =							GameInfoTypes.EACIV_DAIRINE
local EACIV_PARTHOLON =							GameInfoTypes.EACIV_PARTHOLON
local EACIV_SKOGR =								GameInfoTypes.EACIV_SKOGR
local EA_EPIC_HAVAMAL =							GameInfoTypes.EA_EPIC_HAVAMAL

local POLICY_PANTHEISM =						GameInfoTypes.POLICY_PANTHEISM
local POLICY_PATRONAGE =						GameInfoTypes.POLICY_PATRONAGE
local MINOR_TRAIT_ARCANE =						GameInfoTypes.MINOR_TRAIT_ARCANE
local MINOR_TRAIT_HOLY =						GameInfoTypes.MINOR_TRAIT_HOLY
local RELIGION_AZZANDARAYASNA =					GameInfoTypes.RELIGION_AZZANDARAYASNA
local RELIGION_ANRA =							GameInfoTypes.RELIGION_ANRA
local RELIGION_CULT_OF_ABZU =					GameInfoTypes.RELIGION_CULT_OF_ABZU
local RELIGION_CULT_OF_AEGIR =					GameInfoTypes.RELIGION_CULT_OF_AEGIR
local RELIGION_CULT_OF_PLOUTON =				GameInfoTypes.RELIGION_CULT_OF_PLOUTON
local RELIGION_CULT_OF_EPONA =					GameInfoTypes.RELIGION_CULT_OF_EPONA
local RELIGION_CULT_OF_BAKKHEIA =				GameInfoTypes.RELIGION_CULT_OF_BAKKHEIA

local FEATURE_CRATER =							GameInfoTypes.FEATURE_CRATER
local FEATURE_SOLOMONS_MINES =					GameInfoTypes.FEATURE_SOLOMONS_MINES

local MINOR_CIV_PERSONALITY_HOSTILE =			MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_HOSTILE

local bHidden = MapModData.bHidden
local playerType = MapModData.playerType

--functions
local floor = math.floor
local Rand = Map.Rand

--localized tables
local Players =		Players
local Teams =		Teams
local gPlayers =	gPlayers
local gWorld =		gWorld

--shared
local gg_bHasPatronage = gg_bHasPatronage
local gg_teamCanMeetGods = gg_teamCanMeetGods
local gg_teamCanMeetFay = gg_teamCanMeetFay
local gg_naturalWonders = gg_naturalWonders

--state shared
local fullCivs =	MapModData.fullCivs
local cityStates =	MapModData.cityStates
local realCivs =	MapModData.realCivs
local playerType =	MapModData.playerType
local bHidden =		MapModData.bHidden


--file control
local integers = {}
local integers2 = {}

local g_iActivePlayer = Game.GetActivePlayer()
local g_animalsTeam
local g_fayTeam

--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------

local specialistTypeInt = {	SPECIALIST_SMITH = 1,
							SPECIALIST_TRADER = 2,
							SPECIALIST_SCRIBE = 3,
							SPECIALIST_ARTISAN = 4,
							SPECIALIST_DISCIPLE = 6,
							SPECIALIST_ADEPT = 7	}

local classTypeInt = {	Engineer = 1,
						Merchant = 2,
						Sage = 3,
						Artist = 4,
						Warrior = 5,
						Devout = 6,
						Thaumaturge = 7	}

local csBaselineRelationshipByRace = {
	[GameInfoTypes.EARACE_MAN] = {			[GameInfoTypes.EARACE_MAN] = 10,
											[GameInfoTypes.EARACE_SIDHE] = -20,
											[GameInfoTypes.EARACE_HELDEOFOL] = -50	},
	[GameInfoTypes.EARACE_SIDHE] = {		[GameInfoTypes.EARACE_MAN] = -20,
											[GameInfoTypes.EARACE_SIDHE] = 10,
											[GameInfoTypes.EARACE_HELDEOFOL] = -50	},
	[GameInfoTypes.EARACE_HELDEOFOL] = {	[GameInfoTypes.EARACE_MAN] = -50,
											[GameInfoTypes.EARACE_SIDHE] = -50,
											[GameInfoTypes.EARACE_HELDEOFOL] = -20	}	}

local godTempleID = {}	--index by god iPlayer, holds temple wonderID
for wonderInfo in GameInfo.EaWonders() do
	if wonderInfo.God then
		local minorCivTypeID = GameInfoTypes[wonderInfo.God]
		local iGod = gg_minorPlayerByTypeID[minorCivTypeID]
		if iGod then
			godTempleID[iGod] = wonderInfo.ID
		end
	end
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaCivsInit(bNewGame)
	print("Running EaCivsInit ", bNewGame)

	g_animalsTeam = Players[ANIMALS_PLAYER_INDEX]:GetTeam()
	g_fayTeam = Players[FAY_PLAYER_INDEX]:GetTeam()

	if bNewGame then
		--Set CS baseline friendship by race
		for iPlayer, eaPlayer in pairs(fullCivs) do
			for iCS, eaCS in pairs(cityStates) do
				local raceBaseline = csBaselineRelationshipByRace[eaPlayer.race][eaCS.race]
				if raceBaseline then
					Players[iCS]:ChangeMinorCivFriendshipWithMajor(iPlayer, raceBaseline)
				end
			end
		end

		--Init units for City States (can't do in Civilizations due to gods being Minors)
		--TO DO: Delayed addition of city states?
		for iPlayer, eaPlayer in pairs(cityStates) do
			local player = Players[iPlayer]
			local race = eaPlayer.race
			local plot = player:GetStartingPlot()
			local unitTypeID = GameInfoTypes.UNIT_WARRIORS_MAN
			if race == EARACE_SIDHE then
				unitTypeID = GameInfoTypes.UNIT_WARRIORS_SIDHE
			elseif race == EARACE_HELDEOFOL then
				unitTypeID = GameInfoTypes.UNIT_WARRIORS_ORC
			end
			player:InitUnit(unitTypeID, plot:GetX(), plot:GetY())
			--player:InitUnit(GameInfoTypes.UNITCLASS_SETTLERS_MINOR, plot:GetX(), plot:GetY())
		end

		--Hidded civs init
		for iPlayer = 1, BARB_PLAYER_INDEX do
			if playerType[iPlayer] == "God" then			---or playerType[iPlayer] == "Fay" then
			--if bHidden[iPlayer] then
				local player = Players[iPlayer]
				--local startingPlot = player:GetStartingPlot()
				--startingPlot:SetFeatureType(-1)
				--local city = player:InitCity(startingPlot:GetX(), startingPlot:GetY())		--these are not in gCities
				--print("hidden city player name / x / y: ", player:GetName(), city, city:GetX(), city:GetY())

				for unit in player:Units() do
					print("Killing hidden civ unit / x / y: ", unit, unit:GetX(), unit:GetY())
					MapModData.bBypassOnCanSaveUnit = true
					unit:Kill(true, -1)
				end

			end
		end

		--The Fay - Init city, found The Weave, then kill city (suppress notifications) - it's the easiest way unfortunately...
		print("Initing The Fay")
		local fay = Players[FAY_PLAYER_INDEX]	
		local fayStartPlot = Map.GetPlot(0, 0)
		fay:SetStartingPlot(fayStartPlot)		--mod init code will sweep up units and init city
		fayStartPlot:SetFeatureType(-1)
		local fayTempCity = fay:InitCity(fayStartPlot:GetX(), fayStartPlot:GetY())
		fay:SetPolicyBranchUnlocked(GameInfoTypes.POLICY_BRANCH_PANTHEISM, true)
		fay:SetHasPolicy(GameInfoTypes.POLICY_PANTHEISM, true)
		OnPlayerAdoptPolicyBranch(FAY_PLAYER_INDEX, GameInfoTypes.POLICY_BRANCH_PANTHEISM)		--This will found The Weave
		fayTempCity:Kill()

		fay:ChangeNumResourceTotal(GameInfoTypes.RESOURCE_GEMS, 5) 
		fay:ChangeNumResourceTotal(GameInfoTypes.RESOURCE_GOLD, 5) 
		fay:ChangeNumResourceTotal(GameInfoTypes.RESOURCE_SILVER, 5) 
		fay:ChangeNumResourceTotal(GameInfoTypes.RESOURCE_PEARLS, 5) 
		fay:ChangeNumResourceTotal(GameInfoTypes.RESOURCE_IRON, 5) 
		fay:ChangeNumResourceTotal(GameInfoTypes.RESOURCE_YEW, 5)

		for iPlayer = MAX_MAJOR_CIVS, BARB_PLAYER_INDEX - 1 do
			if playerType[iPlayer] == "God" then
				local player = Players[iPlayer]
				local minorCivID = player:GetMinorCivType()
				local minorCivType = GameInfo.MinorCivilizations[minorCivID].Type
				for row in GameInfo.MinorCivilization_GodResources() do
					if row.MinorCivType == minorCivType then
						player:ChangeNumResourceTotal(GameInfoTypes[row.ResourceType], row.ResourceNumber)				
					end
				end 
			end
		end

		--Debug hidden
		for iPlayer = 1, BARB_PLAYER_INDEX do
			if bHidden[iPlayer] then
				local player = Players[iPlayer]
				for unit in player:Units() do

					print("!!!! WARNING: Hidded civ had unit at EaCivsInit; iPlayer/unitTypeID = " .. iPlayer .. ", " .. unit:GetUnitType())
					--error("Hidded civ had unit at EaCivsInit; iPlayer/unitTypeID = " .. iPlayer .. ", " .. unit:GetUnitType())
			
				end
				if not player:IsAlive() then
					error("Hidded civ was not alive; iPlayer = " .. iPlayer)
				end
			end
		end

		--Animals
		--local animalsTeam = Teams[g_animalsTeam]
		--for iPlayer, eaPlayer in pairs(realCivs) do		--Start at war with full civs and CSs
		--	local iTeam = Players[iPlayer]:GetTeam()
		--	animalsTeam:DeclareWar(iTeam)
		--end
		--animalsTeam:MakePeace(Players[BARB_PLAYER_INDEX]:GetTeam())		--At peace with barbs
	end
end

--------------------------------------------------------------
-- File Functions
--------------------------------------------------------------

local OnNWFound = {}

local function TestSetNaturalWonderEffects(iPlayer, x, y)	--if x, y nil then check all
	local player = Players[iPlayer]
	local iTeam = player:GetTeam()
	local eaPlayer = gPlayers[iPlayer]
	local revealedNWs = eaPlayer.revealedNWs
	for featureID, nwTable in pairs(gg_naturalWonders) do
		if not x or (x == nwTable.x and y == nwTable.y) then
			if not revealedNWs[featureID] then
				--Is it revealed now?
				local plot = Map.GetPlot(nwTable.x, nwTable.y)
				if plot:IsRevealed(iTeam, false) then
					print("TestSetNaturalWonderEffects found new NW: ", GameInfo.Features[featureID].Type)
					revealedNWs[featureID] = true
					local bPantheistic = player:HasPolicy(POLICY_PANTHEISM)
					if bPantheistic and nwTable.iGod then
						Teams[iTeam]:Meet(Players[nwTable.iGod]:GetTeam(), true)
					end
					if OnNWFound[featureID] then
						OnNWFound[featureID](iPlayer, bPantheistic)
					end
				end
			end
		end
	end
end
LuaEvents.EaCivsTestSetNaturalWonderEffects.Add(TestSetNaturalWonderEffects)	--call from popup for immediate effect


OnNWFound[GameInfoTypes.FEATURE_SOLOMONS_MINES] = function(iPlayer, bPantheistic)	--Ahriman's Vault
	--unhappiness properly counted in dll, but we need this for good UI (so Ahriman's Vault adds negative rather than subtracting from positive)
	gPlayers[iPlayer].bHasDiscoveredAhrimansVault = true
end


--------------------------------------------------------------
-- Interface
--------------------------------------------------------------

function DeadPlayer(iPlayer)
	print("DeadPlayer ", iPlayer)
	realCivs[iPlayer] = nil
	fullCivs[iPlayer] = nil
	cityStates[iPlayer] = nil
end

function ResurectedPlayer(iPlayer)
	realCivs[iPlayer] = gPlayers[iPlayer]
	if iOwner < MAX_MAJOR_CIVS then
		fullCivs[iPlayer] = gPlayers[iPlayer]
	else
		cityStates[iPlayer] = gPlayers[iPlayer]
	end
end

function CityStatePerCivTurn(iPlayer)	-- called for true city states only
	print("CityStatePerCivTurn ", iPlayer)
	local player = Players[iPlayer]
	local minorTrait = player:GetMinorCivTrait()

	-- Happy/Unhappy effects
	if 2 < gWorld.armageddonStage then
		player:SetUnhappinessFromMod(gWorld.armageddonSap)
	end

	-- Holy CS accumulats Azz followers
	if minorTrait == MINOR_TRAIT_HOLY then
		local eaPlayer = gPlayers[iPlayer]
		if gReligions[RELIGION_AZZANDARAYASNA] and eaPlayer.religionID ~= RELIGION_ANRA then
			if Rand(10, "hello") < 1 then	--10% chance for gaining one follower
				local city = player:GetCapitalCity()
				local atheists = city:GetNumFollowers(-1)
				if 0 < atheists then
					print("Converting 1 citizen in Holy City State")
					local convertPercent = floor(100 / atheists + 1)
					city:ConvertPercentFollowers(RELIGION_AZZANDARAYASNA, -1, convertPercent)
				end
			end
		end
	end
end

function ResetHappyUnhappyFromMod(iPlayer)
	print("ResetHappyUnhappyFromMod ", iPlayer)
	local modHappiness = 0
	local player = Players[iPlayer]
	if gEpics[EA_EPIC_HAVAMAL] and gEpics[EA_EPIC_HAVAMAL].iPlayer == iPlayer then
		modHappiness = modHappiness + gEpics[EA_EPIC_HAVAMAL].mod
	end
	if modHappiness ~= 0 then
		player:SetHappinessFromMod(modHappiness)
	end

	local modUnhappiness = 0
	if 2 < gWorld.armageddonStage then
		modUnhappiness = modUnhappiness + gWorld.armageddonSap
	end
	if modUnhappiness ~= 0 then
		player:SetUnhappinessFromMod(modUnhappiness)
	end
end


function FullCivPerCivTurn(iPlayer)		-- called for full civs only
	print("FullCivPerCivTurn", iPlayer)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local team = Teams[player:GetTeam()]
	local nameTrait = eaPlayer.eaCivNameID
	local classPoints = eaPlayer.classPoints

	-- Mod Happy/Unhappy effects
	ResetHappyUnhappyFromMod(iPlayer)

	--GP point counting for civ
	if nameTrait then
		--if Map.Rand(4, "one-quarter chance") == 0 then
			local nameTraitInfo = GameInfo.EaCivs[nameTrait]
			local favoredClass = nameTraitInfo.FavoredGPClass
			if favoredClass then
				local i = classTypeInt[favoredClass]
				print("Adding GP point for civ favored class: ", favoredClass, i)
				classPoints[i] = classPoints[i] + 1
			end
		--end
	end

	--GP points for buildings and specialists
	for buildingInfo in GameInfo.Buildings() do
		local specialistType = buildingInfo.SpecialistType
		if specialistType then
			local count = player:CountNumBuildings(buildingInfo.ID)
			if count > 0 then
				local i = specialistTypeInt[specialistType]
				classPoints[i] = classPoints[i] + count * buildingInfo.SpecialistCount	--building gives 1; specialist gives 2
			end
		end
	end

	--City State patronage (from city process)
	local patronageDistribution = 0
	local bPatronageDistributionFriendsOnly = false
	if eaPlayer.cityStatePatronage and 10 < eaPlayer.cityStatePatronage then
		local numCSContacted, numCSFriends = 0, 0
		for iCSPlayer, eaCSPlayer in pairs(cityStates) do
			local csPlayer = Players[iCSPlayer]
			if team:IsHasMet(csPlayer:GetTeam()) then
				numCSContacted = numCSContacted + 1
				if csPlayer:IsFriends(iPlayer) then
					bPatronageDistributionFriendsOnly = true
					numCSFriends = numCSFriends + 1
				end
			end
		end
		if 0 < numCSContacted then
			if bPatronageDistributionFriendsOnly then
				patronageDistribution = floor(eaPlayer.cityStatePatronage / numCSFriends)
				eaPlayer.cityStatePatronage = eaPlayer.cityStatePatronage - patronageDistribution * numCSFriends
			else
				patronageDistribution = floor(eaPlayer.cityStatePatronage / numCSContacted)
				eaPlayer.cityStatePatronage = eaPlayer.cityStatePatronage - patronageDistribution * numCSContacted
			end
		end
	
		--distribute it
		if 0 < patronageDistribution then
			for iCSPlayer, eaCSPlayer in pairs(cityStates) do
				local csPlayer = Players[iCSPlayer]
				if 0 < patronageDistribution and team:IsHasMet(csPlayer:GetTeam()) then
					if bPatronageDistributionFriendsOnly then
						if csPlayer:IsFriends(iPlayer) then
							csPlayer:ChangeMinorCivFriendshipWithMajor(iPlayer, patronageDistribution)
						end
					else
						csPlayer:ChangeMinorCivFriendshipWithMajor(iPlayer, patronageDistribution)
					end
				end
			end
		end
	end

	--Civ-wide culture and faith adds
	local faithFromCityStates = GetFaithFromEaCityStates(iPlayer)	--Faith from actual CSs (not Gods)
	local faithFromPolicyFinisher = GetFaithFromPolicyFinisher(player)
	local cultureManaFromWildlands = eaPlayer.cultureManaFromWildlands or 0

	local cultFounderMana = eaPlayer.manaForCultOfLeavesFounder or 0	--calculated in EaPlots.lua
	cultFounderMana = cultFounderMana + (eaPlayer.manaForCultOfCahraFounder or 0)

	if gReligions[RELIGION_CULT_OF_ABZU] and iPlayer == gReligions[RELIGION_CULT_OF_ABZU].founder then
		eaPlayer.manaForCultOfAbzuFounder = gg_counts.freshWaterAbzuFollowerCities
		gg_counts.freshWaterAbzuFollowerCities = 0
		cultFounderMana = cultFounderMana + eaPlayer.manaForCultOfAbzuFounder
	end
	if gReligions[RELIGION_CULT_OF_AEGIR] and iPlayer == gReligions[RELIGION_CULT_OF_AEGIR].founder then
		eaPlayer.manaForCultOfAegirFounder = 2 * gg_counts.coastalAegirFollowerCities
		gg_counts.coastalAegirFollowerCities = 0
		cultFounderMana = cultFounderMana + eaPlayer.manaForCultOfAegirFounder
	end
	if gReligions[RELIGION_CULT_OF_PLOUTON] and iPlayer == gReligions[RELIGION_CULT_OF_PLOUTON].founder then
		eaPlayer.manaForCultOfPloutonFounder = floor(gg_counts.earthResWorkedByPloutonFollower / 2)
		cultFounderMana = cultFounderMana + eaPlayer.manaForCultOfPloutonFounder
	end
	if gReligions[RELIGION_CULT_OF_EPONA] and iPlayer == gReligions[RELIGION_CULT_OF_EPONA].founder then
		eaPlayer.manaForCultOfEponaFounder = gg_counts.stallionsOfEpona
		gg_counts.stallionsOfEpona = 0
		cultFounderMana = cultFounderMana + eaPlayer.manaForCultOfEponaFounder
	end
	if gReligions[RELIGION_CULT_OF_BAKKHEIA] and iPlayer == gReligions[RELIGION_CULT_OF_BAKKHEIA].founder then
		eaPlayer.manaForCultOfBakkheiaFounder = gg_counts.grapeAndSpiritsBuildingsBakkheiaFollowerCities	--added to in EaCities and EaPlots
		gg_counts.grapeAndSpiritsBuildingsBakkheiaFollowerCities = 0
		cultFounderMana = cultFounderMana + eaPlayer.manaForCultOfBakkheiaFounder
	end

	local totalFaith = faithFromCityStates + faithFromPolicyFinisher + cultureManaFromWildlands + cultFounderMana
	if 0 < totalFaith then
		player:ChangeFaith(totalFaith)
	end
	if 0 < cultureManaFromWildlands then
		player:ChangeJONSCulture(cultureManaFromWildlands)
	end

	--Gods tribute (from city process)
	if eaPlayer.majorSpiritsTribute and 10 < eaPlayer.majorSpiritsTribute then
		local tributeDistribution = 0
		local bTributeDistributionFriendsOnly = false
		local numContacted, numFriends = 0, 0
		local relationshipChange = 0
		for iGodPlayer, eaGodPlayer in pairs(gPlayers) do
			if playerType[iGodPlayer] == "God" then
				local godPlayer = Players[iGodPlayer]
				if team:IsHasMet(godPlayer:GetTeam()) then
					numContacted = numContacted + 1
					if godPlayer:IsFriends(iPlayer) then
						bTributeDistributionFriendsOnly = true
						numFriends = numFriends + 1
					end
				end
			end
		end
		if 0 < numContacted then
			if bTributeDistributionFriendsOnly then
				tributeDistribution = floor(eaPlayer.majorSpiritsTribute / numFriends)
				eaPlayer.majorSpiritsTribute = eaPlayer.majorSpiritsTribute - tributeDistribution * numFriends
			else
				tributeDistribution = floor(eaPlayer.majorSpiritsTribute / numContacted)
				eaPlayer.majorSpiritsTribute = eaPlayer.majorSpiritsTribute - tributeDistribution * numContacted
			end
		end
		if 0 < tributeDistribution then
			for iGodPlayer, eaGodPlayer in pairs(gPlayers) do
				if playerType[iGodPlayer] == "God" then
					local godPlayer = Players[iGodPlayer]
					if team:IsHasMet(godPlayer:GetTeam()) then		
						if bTributeDistributionFriendsOnly then
							if godPlayer:IsFriends(iPlayer) then
								relationshipChange = tributeDistribution
							end
						else
							relationshipChange = tributeDistribution
						end
						if relationshipChange ~= 0 then
							godPlayer:ChangeMinorCivFriendshipWithMajor(iPlayer, relationshipChange)
						end
					end
				end
			end
		end
	end

	--Faerie Tribute
	if eaPlayer.faerieTribute then
		local gameTurn = Game.GetGameTurn()
		local beginTurn = 1
		if 100 < gameTurn then
			beginTurn = gameTurn - 100
			eaPlayer.faerieTribute[beginTurn - 1] = nil					--don't need this anymore
		end
		local sum = 0
		for i = beginTurn, gameTurn do
			sum = sum + (eaPlayer.faerieTribute[i] or 0)
		end
		eaPlayer.faerieTribute.ave = floor(sum / (gameTurn - beginTurn))		--used in EaDiplomacy.lua
	end

	--Natural Wonders
	TestSetNaturalWonderEffects(iPlayer)

	--UI
	if iPlayer == g_iActivePlayer then
		MapModData.faithFromCityStates = faithFromCityStates
	end
end

--------------------------------------------------------------
-- GameEvents
--------------------------------------------------------------

local function OnPlayerMinorFriendshipAnchor(iMajorPlayer, iMinorPlayer)
	--print("OnPlayerMinorFriendshipAnchor ", iMajorPlayer, iMinorPlayer)

	if cityStates[iMinorPlayer] then	--City States
		if bHidden[iMajorPlayer] then
			return 0
		else
			local eaMajorPlayer = gPlayers[iMajorPlayer]
			local eaMinorPlayer = gPlayers[iMinorPlayer]
			local anchor = csBaselineRelationshipByRace[eaMajorPlayer.race][eaMinorPlayer.race]
			if eaMajorPlayer.eaCivNameID == EACIV_PARTHOLON or eaMajorPlayer.eaCivNameID == EACIV_DAIRINE then
				anchor = anchor + 15
			end
			return anchor
		end
	else	-- God
		if playerType[iMajorPlayer] == "Fay" then
			return 40
		else
			local eaMajorPlayer = gPlayers[iMajorPlayer]
			if eaMajorPlayer.eaCivNameID == EACIV_SKOGR then
				return 15		
			end
			return 0
		end
	end
end
GameEvents.PlayerMinorFriendshipAnchor.Add(OnPlayerMinorFriendshipAnchor)

local function OnPlayerMinorFriendshipDecayMod(iMajorPlayer, iMinorPlayer)
	print("OnPlayerMinorFriendshipDecayMod ", iMajorPlayer, iMinorPlayer)
	if cityStates[iMinorPlayer] then	--City States
		if gg_bHasPatronage[iMajorPlayer] then
			return -50
		end
		return 0
	else	-- God
		local templeWonderID = godTempleID[iMinorPlayer]
		if templeWonderID and gWonders[templeWonderID] and gWonders[templeWonderID].iPlayer == iMajorPlayer then
			return -33
		end
		return 0
	end
end
GameEvents.PlayerMinorFriendshipDecayMod.Add(OnPlayerMinorFriendshipDecayMod)

local function OnPlayerMinorFriendshipRecoveryMod(iMajorPlayer, iMinorPlayer)
	print("OnPlayerMinorFriendshipRecoveryMod ", iMajorPlayer, iMinorPlayer)
	if cityStates[iMinorPlayer] then	--City States
		if gg_bHasPatronage[iMajorPlayer] then
			return 50
		else
			return 0
		end
	else	-- God
		return 0
	end
end
GameEvents.PlayerMinorFriendshipRecoveryMod.Add(OnPlayerMinorFriendshipRecoveryMod)

function CheckCapitalBuildings(iPlayer)
	local eaPlayer = gPlayers[iPlayer]
	local nameID = eaPlayer.eaCivNameID
	if nameID then
		local nameInfo = GameInfo.EaCivs[nameID]
		if nameInfo.GainCapitalBuilding then
			local player = Players[iPlayer]	
			local buildingID = GameInfoTypes[nameInfo.GainCapitalBuilding]
			for city in player:Cities() do
				if city:IsCapital() then
					city:SetNumRealBuilding(buildingID, 1)
				else
					city:SetNumRealBuilding(buildingID, 0)
				end
			end
		end
	end
end

function UpdateFaithFromEaCityStatesForUI()
	if fullCivs[g_iActivePlayer] then
		MapModData.faithFromCityStates = GetFaithFromEaCityStates(g_iActivePlayer)
	end
end
LuaEvents.EaCivsUpdateFaithFromEaCityStatesForUI.Add(UpdateFaithFromEaCityStatesForUI)	--called when Arcane or Holy CS popup closed

function GetFaithFromEaCityStates(iPlayer)		--For Arcane, Holy and Unholy CSs; game engine only sees faith comming from Gods because only Gods are MINOR_TRAIT_RELIGIOUS
	local eaPlayer = gPlayers[iPlayer]
	local bUsesDivineFavor = eaPlayer.bUsesDivineFavor
	local faithFromCityStates = 0
	for iCSPlayer, eaCSPlayer in pairs(cityStates) do	--would team:IsHasMet check make this faster or slower?
		local csPlayer = Players[iCSPlayer]
		local minorTrait = csPlayer:GetMinorCivTrait()
		if minorTrait == MINOR_TRAIT_ARCANE then
			if not bUsesDivineFavor and eaCSPlayer.religionID ~= RELIGION_AZZANDARAYASNA then
				if csPlayer:GetAlly() == iPlayer then
					faithFromCityStates = faithFromCityStates + 8
				elseif csPlayer:IsFriends(iPlayer) then
					faithFromCityStates = faithFromCityStates + 4					
				end
			end
		elseif minorTrait == MINOR_TRAIT_HOLY then
			if eaCSPlayer.religionID == RELIGION_ANRA then
				if eaPlayer.bIsFallen then
					if csPlayer:GetAlly() == iPlayer then
						faithFromCityStates = faithFromCityStates + 8
					elseif csPlayer:IsFriends(iPlayer) then
						faithFromCityStates = faithFromCityStates + 4					
					end
				end
			elseif bUsesDivineFavor then
				if csPlayer:GetAlly() == iPlayer then
					faithFromCityStates = faithFromCityStates + 8						
				elseif csPlayer:IsFriends(iPlayer) then
					faithFromCityStates = faithFromCityStates + 4					
				end
			end
		end
	end
	return faithFromCityStates
end

--[[
function MeetRandomPantheisticGod(iPlayer, triggerType, id)
	--compile eligible into integers table
	local team = Teams[Players[iPlayer]:GetTeam()]
	local numGods = 0
	if triggerType == "CultFounding" then	--cult associated god only
		for iGod in pairs(gPlayers) do
			if playerType[iGod] == "God" then
				local bAllow = true
				for _, nwTable in pairs(gg_naturalWonders) do		--disallow if this god is represented by a natural wonder
					if nwTable.iGod == iGod then
						bAllow = false
						break 
					end
				end
				if bAllow then
					local god = Players[iGod]
					if not team:IsHasMet(god:GetTeam()) then
						local minorCivID = god:GetMinorCivType()
						local minorCivInfo = GameInfo.MinorCivilizations[minorCivID]
						local godCultType = minorCivInfo.EaCult
						if GameInfoTypes[godCultType] == id then
							numGods = numGods + 1
							integers[numGods] = iGod
						end
					end
				end
			end
		end
	elseif  triggerType == "PantheisticPolicy" then	--any god (should tie into sphere somehow)
		for iGod in pairs(gPlayers) do
			if playerType[iGod] == "God" then
				local bAllow = true
				for _, nwTable in pairs(gg_naturalWonders) do		--disallow if this god is represented by a natural wonder
					if nwTable.iGod == iGod then
						bAllow = false
						break 
					end
				end
				if bAllow then
					local god = Players[iGod]
					if not team:IsHasMet(god:GetTeam()) then
						numGods = numGods + 1
						integers[numGods] = iGod
					end
				end
			end
		end	
	end
	if 0 < numGods then
		local dice = Map.Rand(numGods, "God selection") + 1
		local iGod = integers[dice]
		team:Meet(Players[iGod]:GetTeam(), true)
	end
end
]]

local function TeemMeetListener(iActiveTeam, iMetTeam)	--player or team?
	print("TeemMeetListener: ", iActiveTeam, iMetTeam)	--returning true did not prevent meeting (contrary to wiki)
	

end
GameEvents.TeamMeet.Add(TeemMeetListener)


local function OnCanMeetTeam(iTeam1, iTeam2)
	print("OnCanMeetTeam ", iTeam1, iTeam2)
	if iTeam1 == g_animalsTeam or iTeam2 == g_animalsTeam then return false end

	if iTeam1 == g_fayTeam then
		if not gg_teamCanMeetFay[iTeam2] then return false end
	elseif iTeam2 == g_fayTeam then
		if not gg_teamCanMeetFay[iTeam1] then return false end
	elseif bHidden[iTeam1] then
		if not gg_teamCanMeetGods[iTeam2] then return false end
	elseif bHidden[iTeam2] then
		if not gg_teamCanMeetGods[iTeam1] then return false end
	end

	return true
end
GameEvents.CanMeetTeam.Add(OnCanMeetTeam)

local function WarStateChangedHandler(iTeam1, iTeam2, bWar)
	--just testing for now
	print("WarStateChangedHandler", iTeam1, iTeam2, bWar)
	local iActiveTeam = Game.GetActiveTeam()
	if iTeam1 ~= iActiveTeam and iTeam2 ~= iActiveTeam then
		print("Neither team was the active team!")
		local activeTeam = Teams[iActiveTeam]
		if not activeTeam:IsHasMet(iTeam1) and not activeTeam:IsHasMet(iTeam1) then
			print("Neither team has met the active team!")
		end
	end

	--EaTradeDataDirty()
end
Events.WarStateChanged.Add(WarStateChangedHandler)




local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	print("Active player change (new/old): ", iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)