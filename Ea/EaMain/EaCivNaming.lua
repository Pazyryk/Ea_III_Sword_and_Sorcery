-- EaCivNaming
-- Author: Pazyryk
-- DateCreated: 2/11/2012 4:09:12 PM
--------------------------------------------------------------

print("Loading EaCivNaming.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------

--constants
local EARACE_MAN =						GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =					GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =				GameInfoTypes.EARACE_HELDEOFOL


local gPlayers = gPlayers
local gPeople = gPeople

local gpClassTable = {"Engineer", "Merchant", "Sage", "Artist", "Warrior"}

--shared
local playerType = MapModData.playerType
local fullCivs = MapModData.fullCivs
local civNamesByRace = MapModData.civNamesByRace
local gg_eaNamePlayerTable = gg_eaNamePlayerTable

--localized functions
local HandleError10 = HandleError10
local HandleError21 = HandleError21


--file functions
local CivReq = {}	
local CivSet = {}

--file control
local bInited = false



--------------------------------------------------------------
-- Cached Tables
--------------------------------------------------------------


--------------------------------------------------------------
-- Init
--------------------------------------------------------------

function EaCivNamingInit(bNewGame)
	if not bNewGame then
		for iPlayer, eaPlayer in pairs(fullCivs) do
			if eaPlayer.eaCivNameID then
				gg_eaNamePlayerTable[eaPlayer.eaCivNameID] = iPlayer
			end
		end
	end
	bInited = true
end

--------------------------------------------------------------
-- File Functions
--------------------------------------------------------------

local function TestNameConditions(iPlayer, eaCivInfo)
	local eaPlayer = gPlayers[iPlayer]
	local player = Players[iPlayer]
	if eaCivInfo.AdoptedPolicy then
		if not player:HasPolicy(GameInfoTypes[eaCivInfo.AdoptedPolicy])	
			and (not eaCivInfo.OrAdoptedPolicy1 or not player:HasPolicy(GameInfoTypes[eaCivInfo.OrAdoptedPolicy1]))
			and (not eaCivInfo.OrAdoptedPolicy2 or not player:HasPolicy(GameInfoTypes[eaCivInfo.OrAdoptedPolicy2]))
			then return false end
		if eaCivInfo.AndAdoptedPolicy and not player:HasPolicy(GameInfoTypes[eaCivInfo.AndAdoptedPolicy]) then return false end
	end

	local team = Teams[player:GetTeam()]
	if eaCivInfo.KnownTech and not team:IsHasTech(GameInfoTypes[eaCivInfo.KnownTech]) then return false end
	if eaCivInfo.AndKnownTech and not team:IsHasTech(GameInfoTypes[eaCivInfo.AndKnownTech]) then return false end
	if eaCivInfo.BuildingType and player:CountNumBuildings(GameInfoTypes[eaCivInfo.BuildingType]) < 1 then return false end

	if eaCivInfo.ImprovementType then
		local improvementID = GameInfoTypes[eaCivInfo.ImprovementType]
		local qualifyingImprovements = eaPlayer.ImprovementsByID[improvementID] or 0
		if eaCivInfo.OrImprovementType then
			local improvementID2 = GameInfoTypes[eaCivInfo.OrImprovementType]
			qualifyingImprovements = qualifyingImprovements + (eaPlayer.ImprovementsByID[improvementID2] or 0)
		end
		if qualifyingImprovements < eaCivInfo.ImprovementNumber then return false end
	end
	if eaCivInfo.ImprovedResType then
		local resourceID = GameInfoTypes[eaCivInfo.ImprovedResType]
		local qualifyingResources = eaPlayer.ImprovedResourcesByID[resourceID] or 0
		if eaCivInfo.OrImprovedResType then
			local resourceID2 = GameInfoTypes[eaCivInfo.OrImprovedResType]
			qualifyingResources = qualifyingResources + (eaPlayer.ImprovementsByID[resourceID2] or 0)
		end
		if qualifyingResources < eaCivInfo.ImprovedResNumber then return false end
	end
	if eaCivInfo.CapitalNearbyResourceType then
		local resourceID = GameInfoTypes[eaCivInfo.CapitalNearbyResourceType]
		local qualifyingResources = eaPlayer.resourcesNearCapitalByID[resourceID] or 0
		if qualifyingResources < eaCivInfo.CapitalNearbyResourceNumber then return false end
	end
	if eaCivInfo.UnitClass then
		local unitNumber = player:GetUnitClassCount(GameInfoTypes[eaCivInfo.UnitClass])
		if eaCivInfo.OrUnitClass then
			unitNumber = unitNumber + player:GetUnitClassCount(GameInfoTypes[eaCivInfo.OrUnitClass])
			if eaCivInfo.OrUnitClass2 then
				unitNumber = unitNumber + player:GetUnitClassCount(GameInfoTypes[eaCivInfo.OrUnitClass2])
			end
		end
		if unitNumber < 1 then return false end
	end
	if CivReq[eaCivInfo.ID] and not CivReq[eaCivInfo.ID](iPlayer) then return false end
	return true
end



--------------------------------------------------------------
-- Interface
--------------------------------------------------------------
function TestAllCivNamingConditions(iPlayer)	--per civ turn and rerun after any change thay might qualify a name (e.g., AI picks a policy or human closes policy window)
	if not bInited then return end
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer then return end						--autoplay
	if eaPlayer.eaCivNameID then return end				--already has name
	print("TestAllCivNamingConditions")
	local raceID = eaPlayer.race
	local TestNameConditions = TestNameConditions
	for eaCivInfo in GameInfo.EaCivs() do
		local eaCivID = eaCivInfo.ID
		if civNamesByRace[raceID][eaCivID] and not gg_eaNamePlayerTable[eaCivID] and eaPlayer.declinedNameID ~= eaCivID and TestNameConditions(iPlayer, eaCivInfo) then
			if iPlayer == Game.GetActivePlayer() then
				eaPlayer.turnBlockEaCivNamingID = eaCivID		--blocks end turn until player decides what to do
				LuaEvents.EaAchievedCivNamePopup(iPlayer, eaCivID)
				return false
			else
				SetNewCivName(iPlayer, eaCivID)
				return true
			end
		end
	end
	return false
end
LuaEvents.EaCivNamingTestAllCivNamingConditions.Add(function(iPlayer) return HandleError10(TestAllCivNamingConditions, iPlayer) end)	--called from SocialPolicyPopup.lua on window closed

function SetNewCivName(iPlayer, eaCivID)
	-- !!!! THIS IS THE CIV-NAMING EVENT !!!!
	local eaCivInfo = GameInfo.EaCivs[eaCivID]
	print("SetNewCivName, iPlayer = "..iPlayer.."; EaTrait Type = "..eaCivInfo.Type)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	local team = Teams[player:GetTeam()]
	local capital = player:GetCapitalCity()

	eaPlayer.eaCivNameID = eaCivID

	if eaCivID == 0 then	--get info from leader for Heldeofol only ("Clan of ____" civs)
		-- not added yet
		
	else											--get info from EaTrait
		capital:SetName(Locale.ConvertTextKey(eaCivInfo.CapitalName), false)
	end

	team:SetHasTech(GameInfoTypes.TECH_GAIN_WITH_NAMING, true)	--allows open borders
	--BlockUnitMatch(iPlayer, "UNIT_SETTLERS", "NoName", false, nil)		--unblock settler

	local eaCivType = eaCivInfo.Type
	local newCivID
	for civInfo in GameInfo.Civilizations() do
		if civInfo.EaCivName == eaCivType and GameInfoTypes[civInfo.EaRace] == eaPlayer.race then
			newCivID = civInfo.ID
			break
		end
	end
	if not newCivID then
		error("Did not find Civilization for EaCivName and race")
	end
	local newCivInfo = GameInfo.Civilizations[newCivID]
	print("Changing player civilization to ", newCivInfo.Type)
	player:ChangeCivilizationType(newCivID)
	PreGame.SetCivilizationDescription(iPlayer, newCivInfo.Description)
	PreGame.SetCivilizationShortDescription(iPlayer, newCivInfo.ShortDescription)
	PreGame.SetCivilizationAdjective(iPlayer, newCivInfo.Adjective)

	gg_eaNamePlayerTable[eaCivID] = iPlayer

	player:SetPolicyBranchUnlocked(GameInfoTypes.POLICY_BRANCH_CIV_ENABLED, true)	--adopts opener policy
	gg_mercHireRate[iPlayer] = GameInfo.EaCivs[eaCivID].AIMercHire

	--Civ popup or notification
	if Game.GetActivePlayer() == iPlayer  then
		--Events.AudioPlay2DSound("AS2D_INTERFACE_NEW_ERA")
		LuaEvents.EaImagePopup({type = "CivNaming", id = eaCivID, sound = "AS2D_INTERFACE_NEW_ERA"})
	else
		local text = "Travelers tell of faraway " .. Locale.ConvertTextKey(newCivInfo.ShortDescription) .. "..."
		Players[Game.GetActivePlayer()]:AddNotification(NotificationTypes.NOTIFICATION_WONDER_COMPLETED, text, text, -1, -1)
		print(text)
	end

	--founding GPs and policy (delayed) GPs
	if eaCivInfo.FoundingGPClass or eaCivInfo.FoundingGPSubclass then
		local class = eaCivInfo.FoundingGPClass
		local subclass = (not class) and eaCivInfo.FoundingGPSubclass or nil
		local eaPersonRowID = eaCivInfo.FoundingGPType
		GenerateGreatPerson(iPlayer, class, subclass, eaPersonRowID, true)
		if class and class == eaPlayer.delayedGPclass then
			eaPlayer.delayedGPclass = nil
		end
		if subclass and subclass == eaPlayer.delayedGPsubclass then
			eaPlayer.delayedGPsubclass = nil
		end
	end
	if eaPlayer.delayedGPclass then
		GenerateGreatPerson(iPlayer, eaPlayer.delayedGPclass, nil)
		eaPlayer.delayedGPclass = nil
	elseif eaPlayer.delayedGPsubclass then
		GenerateGreatPerson(iPlayer, nil, eaPlayer.delayedGPsubclass)
		eaPlayer.delayedGPsubclass = nil
	end

	--Do civ-specific effects
	ResetPlayerFavoredTechs(iPlayer)

	CheckCapitalBuildings(iPlayer)		--will add Civ-specific capital buildings, if any

	if eaCivInfo.GainPolicy then
		player:SetHasPolicy(GameInfoTypes[eaCivInfo.GainPolicy], true)
	end

	if eaCivInfo.GainTech then
		team:SetHasTech(GameInfoTypes[eaCivInfo.GainTech], true)
	end

	if eaCivInfo.PopResourceNearCapital then
		local capital = player:GetCapitalCity()
		PlaceResourceNearCity(capital, GameInfoTypes[eaCivInfo.PopResourceNearCapital])
	end


	if CivSet[eaCivID] then CivSet[eaCivID](iPlayer) end

	--Safe to unlock researved GPs?
	local bAllCivsHaveNames = true
	for iLoopPlayer, eaLoopPlayer in pairs(fullCivs) do
		if not eaLoopPlayer.eaCivNameID then
			bAllCivsHaveNames = false
			break
		end
	end
	if bAllCivsHaveNames and not gWorld.bAllCivsHaveNames then
		print("All civs have names now; unlocking reserved GPs")
		gWorld.bAllCivsHaveNames = bAllCivsHaveNames
		UnlockReservedGPs()
	end

end
LuaEvents.EaCivNamingSetNewCivName.Add(function(iPlayer, eaCivID) return HandleError21(SetNewCivName, iPlayer, eaCivID) end)


--------------------------------------------------------------
-- Civ-specific Req and Set functions
--------------------------------------------------------------

CivSet[GameInfoTypes.EACIV_CRUITHNI] = function(iPlayer)	
	gg_campRange[iPlayer] = gg_campRange[iPlayer] + 1
end

CivSet[GameInfoTypes.EACIV_DAGGOO] = function(iPlayer)	
	gg_whalingRange[iPlayer] = gg_whalingRange[iPlayer] + 2
end

CivSet[GameInfoTypes.EACIV_LEMURIA] = function(iPlayer)	
	gg_playerArcaneMod[iPlayer] = gg_playerArcaneMod[iPlayer] - 20
end




--