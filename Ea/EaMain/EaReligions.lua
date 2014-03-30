-- Religions
-- Author: Pazyryk
-- DateCreated: 8/3/2012 6:39:12 PM
--------------------------------------------------------------

print("Loading EaReligions.lua...")
local print = ENABLE_PRINT and print or function() end
local Dprint = DEBUG_PRINT and print or function() end

--------------------------------------------------------------
-- Settings
-------------------------------------------------------------

local MANA_CONSUMED_BY_ANRA_FOUNDING =		1000
local MANA_CONSUMED_BY_CIV_FALL =			200
local MANA_CONSUMED_PER_FOLLOWER_PER_TURN =	1

--------------------------------------------------------------
-- File Locals
--------------------------------------------------------------

--constants
local HIGHEST_RELIGION_ID =			HIGHEST_RELIGION_ID
local RELIGION_AZZANDARAYASNA =		GameInfoTypes.RELIGION_AZZANDARAYASNA
local RELIGION_ANRA =				GameInfoTypes.RELIGION_ANRA
local RELIGION_THE_WEAVE_OF_EA =	GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
local POLICY_BRANCH_THEISM =		GameInfoTypes.POLICY_BRANCH_THEISM
local POLICY_BRANCH_ANTI_THEISM =	GameInfoTypes.POLICY_BRANCH_ANTI_THEISM

local POLICY_THEISM =				GameInfoTypes.POLICY_THEISM
local POLICY_ANTI_THEISM =			GameInfoTypes.POLICY_ANTI_THEISM
local POLICY_THEISM_FINISHER =		GameInfoTypes.POLICY_THEISM_FINISHER
local POLICY_ANTI_THEISM_FINISHER =	GameInfoTypes.POLICY_ANTI_THEISM_FINISHER
local TECH_THAUMATURGY =			GameInfoTypes.TECH_THAUMATURGY

local PROMOTION_SORCERER =			GameInfoTypes.PROMOTION_SORCERER

local FALLEN_ID_SHIFT = POLICY_ANTI_THEISM - POLICY_THEISM
local HIGHEST_RELIGION_ID = HIGHEST_RELIGION_ID

--global tables
local Players =		Players
local MapModData =	MapModData
local playerType =	MapModData.playerType
local bHidden =		MapModData.bHidden
local realCivs =	MapModData.realCivs
local fullCivs =	MapModData.fullCivs
local gPlayers =	gPlayers
local gReligions =	gReligions
--local gg_religionFollowersByEaCityIndex = gg_religionFollowersByEaCityIndex

--functions
local Rand = Map.Rand
local Floor = math.floor

--file control
local g_iActivePlayer = Game.GetActivePlayer()


local integers = {}
local integers2 = {}


--------------------------------------------------------------
-- Cashed Tables
--------------------------------------------------------------

print("policyReligionBeliefTriggers:")
local policyReligionBeliefTriggers = {}
for beliefInfo in GameInfo.Beliefs() do
	local policyType = beliefInfo.EaPolicyTrigger
	if policyType then
		local beliefID = beliefInfo.ID
		local policyID = GameInfoTypes[policyType]
		policyReligionBeliefTriggers[policyID] = policyReligionBeliefTriggers[policyID] or {}
		for row in GameInfo.Religions_BeliefsInReligion("BeliefType = '" .. beliefInfo.Type .. "'") do
			local religionID = GameInfoTypes[row.ReligionType]
			policyReligionBeliefTriggers[policyID][religionID] = policyReligionBeliefTriggers[policyID][religionID] or {}
			policyReligionBeliefTriggers[policyID][religionID][beliefID] = true
			print(GameInfo.Policies[policyID].Type, GameInfo.Religions[religionID].Type, GameInfo.Beliefs[beliefID].Type)
		end
	end
end

--------------------------------------------------------------
-- Init
--------------------------------------------------------------

--------------------------------------------------------------
-- Religion functions
--------------------------------------------------------------

local conversionReligions =   {	[RELIGION_AZZANDARAYASNA] = "azzConvertNum",
								[RELIGION_ANRA] = "anraConvertNum",
								[RELIGION_THE_WEAVE_OF_EA] = "weaveConvertNum"	}

local eligibleCitiesAtheists = {}
local eligibleCitiesOthers = {}
local followersByCity = {}
setmetatable(followersByCity, WeakKeyMetatable)

function ReligionPerGameTurn()
	print("Running ReligionPerGameTurn")

	--Conversions
	for religionID, convertKey in pairs(conversionReligions) do
		local convertNum = Floor(gWorld[convertKey])
		if convertNum >= 1 then
			print("Floor value for ", convertKey, " = ", convertNum)
			local numEligibleCitiesAtheists = 0
			local numEligibleCitiesOthers = 0
			for iPlayer, eaPlayer in pairs(realCivs) do
				local player = Players[iPlayer]
				for city in player:Cities() do
					local followers = city:GetNumFollowers(religionID)
					if religionID == RELIGION_THE_WEAVE_OF_EA then
						for i = religionID + 1, HIGHEST_RELIGION_ID do		--count cults too
							if gReligions[i] then
								followers = followers + city:GetNumFollowers(i)
							end
						end
					end
					if 0 < followers then
						print("Found follower in ", city:GetName(), followers)
						followersByCity[city] = followers
						if 0 < city:GetNumFollowers(-1) then			--atheists
							print(" --has atheist")
							numEligibleCitiesAtheists = numEligibleCitiesAtheists + 1
							eligibleCitiesAtheists[numEligibleCitiesAtheists] = city
						elseif followers < city:GetPopulation() then	--must be someone to convert
							print(" --has other religion")
							numEligibleCitiesOthers = numEligibleCitiesOthers + 1
							eligibleCitiesOthers[numEligibleCitiesOthers] = city
						end
					end
				end
			end
			local numConverted = 0
			if 0 < numEligibleCitiesAtheists then
				print("Found eligible atheists to convert")
				local indexList = GetRandomizedArrayIndexes(numEligibleCitiesAtheists)
				for i = 1, numEligibleCitiesAtheists do
					local index = indexList[i]
					local city = eligibleCitiesAtheists[index]
					local numAtheists = city:GetNumFollowers(-1)
					local numReligionBefore = city:GetNumFollowers(religionID)
					city:ConvertPercentFollowers(religionID, -1, Floor(100 / numAtheists + 0.5))
					local thisConversionNum = city:GetNumFollowers(religionID) - numReligionBefore
					numConverted = numConverted + thisConversionNum
					if thisConversionNum ~= 1 then
						print("!!!! WARNING: Conversion process did not convert exactly 1 citizen ", thisConversionNum, numReligionBefore)
					end
					print("Religion Conversion Process converted an atheist ", thisConversionNum, religionID, city:GetName())
					if numConverted >= convertNum then break end
				end
			end
			if 5 < convertNum - numConverted and 0 < numEligibleCitiesOthers then
				print("Found eligible other religious to convert")
				local indexList = GetRandomizedArrayIndexes(numEligibleCitiesOthers)
				for i = 1, numEligibleCitiesOthers do
					local index = indexList[i]
					local city = eligibleCitiesOthers[index]
					local otherFollowers = city:GetPopulation() - followersByCity[city]
					local citizenToConvert = Rand(otherFollowers, "hello")
					local citizenNumber = 0
					for loopReligionID = 1, HIGHEST_RELIGION_ID do
						if loopReligionID ~= religionID and gReligions[loopReligionID] then
							local loopFollowers = city:GetNumFollowers(loopReligionID)
							citizenNumber = citizenNumber + loopFollowers
							if citizenToConvert < citizenNumber then
								local numReligionBefore = city:GetNumFollowers(religionID)
								city:ConvertPercentFollowers(religionID, loopReligionID, Floor(100 / loopFollowers + 0.5))
								local thisConversionNum = city:GetNumFollowers(religionID) - numReligionBefore
								numConverted = numConverted + (thisConversionNum * 5)	--5x harder to convert from religion
								if thisConversionNum ~= 1 then
									print("!!!! WARNING: Conversion process did not convert exactly 1 citizen ", thisConversionNum, numReligionBefore)
								end
								print("Religion Conversion Process converted a citizen of another religion ", thisConversionNum, religionID, loopReligionID, city:GetName())
								break
							end
						end
						
					end
					if numConverted >= convertNum then break end
				end
			end
			gWorld[convertKey] = gWorld[convertKey] - numConverted
		end
	end
end

function UpdateCivReligion(iPlayer, bPerTurnCall)		--per turn and when update needed
	print("UpdateCivReligion ", iPlayer)
	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]

	if playerType[iPlayer] == "FullCiv" then
		--count total religious followers

		for i = 1, HIGHEST_RELIGION_ID do
			integers[i] = 0						--use integers table for follower number
			if gReligions[i] then
				for city in player:Cities() do
					integers[i] = integers[i] + city:GetNumFollowers(i)
				end
			end
		end

		--Mana consumption per Anra follower per turn
		if bPerTurnCall and 0 < integers[RELIGION_ANRA] then
			local consumedMana = integers[RELIGION_ANRA] * MANA_CONSUMED_PER_FOLLOWER_PER_TURN
			gWorld.sumOfAllMana = gWorld.sumOfAllMana - consumedMana
			if eaPlayer.bIsFallen then
				eaPlayer.manaConsumed = (eaPlayer.manaConsumed or 0) + consumedMana
			end
		end

		--The Weave gets credit for all cult followers
		for i = RELIGION_THE_WEAVE_OF_EA + 1, HIGHEST_RELIGION_ID do
			integers[RELIGION_THE_WEAVE_OF_EA] = integers[RELIGION_THE_WEAVE_OF_EA] + integers[i]
		end
		local population = player:GetTotalPopulation()
		local bHasCivReligion = false
		local oldReligion = eaPlayer.religionID
		for i = HIGHEST_RELIGION_ID, 1, -1 do		--backward so a specific cult majority will take priority over The Weave
			if population / 2 < integers[i] then
				eaPlayer.religionID = i
				bHasCivReligion = true
				break
			end
		end
		if not bHasCivReligion or (eaPlayer.religionID == RELIGION_AZZANDARAYASNA and eaPlayer.bIsFallen) then
			eaPlayer.religionID = -1
		end

		--Religion Changed
		if eaPlayer.religionID ~= oldReligion then
			print("Player changed religion", oldReligion, eaPlayer.religionID)
	
			if iPlayer == g_iActivePlayer then	--notification
				local text
				if eaPlayer.religionID < RELIGION_THE_WEAVE_OF_EA or oldReligion < RELIGION_THE_WEAVE_OF_EA then
					if eaPlayer.religionID ~= -1 then
						local newReligionStr = Locale.ConvertTextKey(GameInfo.Religions[eaPlayer.religionID].Description)
						text = Locale.ConvertTextKey("TXT_KEY_EA_RELIGIOUS_CONVERSION", newReligionStr)
					else
						text = Locale.ConvertTextKey("TXT_KEY_EA_LOST_DOMINANT_RELIGION")
					end
				else
					text = Locale.ConvertTextKey("TXT_KEY_EA_CULT_CHANGE")
				end
				player:AddNotification(NotificationTypes.NOTIFICATION_RELIGION_SPREAD_NATURAL, text, text, -1, -1)	--TO DO: test/change type
			end

			--mana/divine favor flip if needed
			if eaPlayer.bUsesDivineFavor then
				if eaPlayer.religionID ~= RELIGION_AZZANDARAYASNA then
					SetDivineFavorUse(iPlayer, false)
				end
			elseif eaPlayer.religionID == RELIGION_AZZANDARAYASNA then
				SetDivineFavorUse(iPlayer, true)
			end

		end

		if eaPlayer.religionID == RELIGION_ANRA and not eaPlayer.bIsFallen then
			BecomeFallen(iPlayer)
		end

	elseif playerType[iPlayer] == "CityState" then
		local capital = player:GetCapitalCity()
		if capital then
			eaPlayer.religionID = capital:GetReligiousMajority()
		else
			eaPlayer.religionID = -1
		end
		if bPerTurnCall and gReligions[RELIGION_ANRA] then
			local consumedMana = city:GetNumFollowers(RELIGION_ANRA) * MANA_CONSUMED_PER_FOLLOWER_PER_TURN
			gWorld.sumOfAllMana = gWorld.sumOfAllMana - consumedMana
		end
	end
end

function SetDivineFavorUse(iPlayer, bDivineFavor)
	print("SetDivineFavorUse ", iPlayer, bDivineFavor)
	--Always set eaPlayer.bUsesDivineFavor here so we can keep track of everything in one place
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer.bUsesDivineFavor == not bDivineFavor then return end	--already done (not's used to make nil and false equivelent)

	--this value controls all game rules and UI
	eaPlayer.bUsesDivineFavor = bDivineFavor

	--save old accumulation in case flips back
	local player = Players[iPlayer]
	local saveFaith = player:GetFaith()
	player:SetFaith(eaPlayer.savedFaithFromManaDivineFavorSwap or 0)
	eaPlayer.savedFaithFromManaDivineFavorSwap = 0 < saveFaith and saveFaith or nil

	--notification
	if iPlayer == g_iActivePlayer and 0 < saveFaith then
		local text
		if bDivineFavor then
			text = Locale.ConvertTextKey("TXT_KEY_EA_LOST_MANA", saveFaith)
		else
			text = Locale.ConvertTextKey("TXT_KEY_EA_LOST_DIVINE_FAVOR", saveFaith)
		end
		player:AddNotification(NotificationTypes.NOTIFICATION_RELIGION_ERROR, text, text, -1, -1)
	end

	--hidden techs
	local team = Teams[player:GetTeam()]
	team:SetHasTech(GameInfoTypes.TECH_ALLOW_DIVINE_FAVOR_YIELDS, bDivineFavor)
	team:SetHasTech(GameInfoTypes.TECH_ALLOW_MANA_YIELDS, not bDivineFavor)

end

function FoundReligion(iPlayer, iCity, religionID)	--call should make sure that this is a valid city
	print("FoundReligion ", iPlayer, iCity, religionID)
	local player = Players[iPlayer]
	local city = player:GetCityByID(iCity)
	local eaPlayer = gPlayers[iPlayer]
	local religion = GameInfo.Religions[religionID]
	gReligions[religionID] = {founder = iPlayer}		--use table existance to know religion is founded (no game function for this)
	local beliefID = religion.EaInitialBelief and GameInfoTypes[religion.EaInitialBelief] or -1
	local belief2ID = religion.EaInitialBelief2 and GameInfoTypes[religion.EaInitialBelief2] or -1
	local belief3ID = religion.EaInitialBelief3 and GameInfoTypes[religion.EaInitialBelief3] or -1

	Game.FoundReligion(iPlayer, religionID, nil, beliefID, belief2ID, belief3ID, -1, city)

	while city:GetReligiousMajority() ~= religionID do	--make it so
		local convertID, followers
		repeat
			convertID = Rand(HIGHEST_RELIGION_ID + 2, "hello") - 1
			followers = (convertID == -1 or gReligions[convertID]) and city:GetNumFollowers(convertID)
		until followers
		print("Converting random religions until founded is majority; converting religionID = ", convertID)
		local convertPercent = Floor(1 + 100 / followers)
		city:ConvertPercentFollowers(religionID, convertID, convertPercent)
	end

	if religionID == RELIGION_ANRA and not eaPlayer.bIsFallen then
		BecomeFallen(iPlayer)
	else
		UpdateCivReligion(iPlayer)
		if religionID == RELIGION_AZZANDARAYASNA or religionID == RELIGION_ANRA then
			RefreshBeliefs()
		end
	end

	if religionID == RELIGION_ANRA then
		--Burn a good chunk of mana
		gWorld.sumOfAllMana = gWorld.sumOfAllMana - MANA_CONSUMED_BY_ANRA_FOUNDING
		eaPlayer.manaConsumed = (eaPlayer.manaConsumed or 0) + MANA_CONSUMED_BY_ANRA_FOUNDING
	end
end


function RefreshBeliefs(policyID)	--if policyID is nil then checks all policies adopted by all players
	
	print("Running RefreshBeliefs ", policyID)

	if policyID then
		local religionBeliefTriggers = policyReligionBeliefTriggers[policyID]
		if religionBeliefTriggers then
			for religionID, beliefTriggers in pairs(religionBeliefTriggers) do
				if gReligions[religionID] then	--religion founded
					local beliefsInReligion = Game.GetBeliefsInReligion(religionID)
					local numBeliefsInReligion = #beliefsInReligion
					for beliefID in pairs(beliefTriggers) do
						local bNewBeleif = true
						for i = 1, numBeliefsInReligion do
							if beliefsInReligion[i] == beliefID then
								bNewBeleif = false
								break
							end
						end
						if bNewBeleif then
							local iFounder = gReligions[religionID].founder
							print("Enhancing Religion ", iFounder, religionID, beliefID)
							Game.EnhanceReligion(iFounder, religionID, beliefID, -1)
							--Network.SendEnhanceReligion(iFounder, religionID, nil, beliefID, -1, nil, nil)
						else
							print("Would enhance religion now but belief already exists ", religionID, beliefID)
						end
					end
				end
			end
		end
	else
		for policyInfo in GameInfo.Policies("PolicyBranchType IS NOT NULL") do
			local policyID = policyInfo.ID
			local religionBeliefTriggers = policyReligionBeliefTriggers[policyID]
			if religionBeliefTriggers then
				local bSomeoneHasPolicy = false
				for iPlayer, eaPlayer in pairs(fullCivs) do
					local player = Players[iPlayer]
					if player:HasPolicy(policyID) then
						bSomeoneHasPolicy = true
						break
					end
				end
				if bSomeoneHasPolicy then
					for religionID, beliefTriggers in pairs(religionBeliefTriggers) do
						if gReligions[religionID] then	--religion founded
							local beliefsInReligion = Game.GetBeliefsInReligion(religionID)
							local numBeliefsInReligion = #beliefsInReligion
							for beliefID in pairs(beliefTriggers) do
								local bNewBeleif = true
								for i = 1, numBeliefsInReligion do
									if beliefsInReligion[i] == beliefID then
										bNewBeleif = false
										break
									end
								end
								if bNewBeleif then
									local iFounder = gReligions[religionID].founder
									print("Enhancing Religion ", iFounder, religionID, beliefID)
									Game.EnhanceReligion(iFounder, religionID, beliefID, -1)
									--Network.SendEnhanceReligion(iFounder, religionID, nil, beliefID, -1, nil, nil)
								else
									print("Would enhance religion now but belief already exists ", religionID, beliefID)
								end
							end
						end
					end
				end
			end
		end
	end
end

function BecomeFallen(iPlayer)		--this could happen before, during or after the founding of Anra
	local eaPlayer = gPlayers[iPlayer]
	if eaPlayer.bIsFallen then return end
	print("Civilization has fallen!", iPlayer)

	local player = Players[iPlayer]
	eaPlayer.bIsFallen = true
	SetDivineFavorUse(iPlayer, false)

	--"Mirror" Theism branch
	if player:HasPolicy(POLICY_THEISM) then
		print("Converting Theism policies to mirror policies")
		player:SetPolicyBranchUnlocked(POLICY_BRANCH_ANTI_THEISM, true)
		player:SetHasPolicy(POLICY_ANTI_THEISM, true)
		for policy in GameInfo.Policies() do
			if policy.PolicyBranchType == "POLICY_BRANCH_THEISM" then
				if player:HasPolicy(policy.ID) then
					player:SetHasPolicy(policy.ID, false)
					player:SetHasPolicy(policy.ID + FALLEN_ID_SHIFT, true)
				end
			end
		end
		player:SetHasPolicy(POLICY_THEISM, false)
		if player:HasPolicy(POLICY_THEISM_FINISHER) then
			player:SetHasPolicy(POLICY_THEISM_FINISHER, false)
			player:SetHasPolicy(POLICY_ANTI_THEISM_FINISHER, true)
		end
		player:SetPolicyBranchUnlocked(POLICY_BRANCH_THEISM, false)
	end

	--All spellcasters become Sorcerers
	for iPerson, eaPerson in pairs(gPeople) do
		if eaPerson.iPlayer == iPlayer then

			local class1, class2 = eaPerson.class1, eaPerson.class2
			if eaPerson.spells then
				print("Converting spellcaster")
				local unit = player:GetUnitByID(eaPerson.iUnit)
				unit:SetHasPromotion(PROMOTION_SORCERER, true)
				--convert spells
				local numConvert = 0
				for spellID in pairs(eaPerson.spells) do
					local alt = GameInfo.EaActions[spellID].FallenAltSpell
					if alt and alt ~= "IsFallen" then
						numConvert = numConvert + 1
						integers[numConvert] = spellID
						eaPerson.spells[GameInfoTypes[alt] ] = true
					end
				end
				for j = 1, numConvert do
					eaPerson.spells[integers[j] ] = nil
				end

				--convert subclass
				if eaPerson.subclass == "Priest" then	--still uses priest unitType, but gains thaumaturge class
					eaPerson.subclass = "FallenPriest"
					eaPerson.class2 = "Thaumaturge"
					eaPerson.unitTypeID = GameInfoTypes.UNIT_FALLENPRIEST
					local newUnit = player:InitUnit(GameInfoTypes.UNIT_FALLENPRIEST, unit:GetX(), unit:GetY())
					MapModData.bBypassOnCanSaveUnit = true
					newUnit:Convert(unit, false)
					newUnit:SetPersonIndex(iPerson)
					eaPerson.iUnit = newUnit:GetID()
				elseif eaPerson.subclass == "Paladin" then
					eaPerson.subclass = "Eidolon"
					eaPerson.unitTypeID = GameInfoTypes.UNIT_EIDOLON
					local newUnit = player:InitUnit(GameInfoTypes.UNIT_EIDOLON, unit:GetX(), unit:GetY())
					MapModData.bBypassOnCanSaveUnit = true
					newUnit:Convert(unit, false)
					newUnit:SetPersonIndex(iPerson)
					eaPerson.iUnit = newUnit:GetID()
				end
			end
		end
	end

	--Azzandara city conversion
	if gReligions[RELIGION_AZZANDARAYASNA] and gReligions[RELIGION_ANRA] then	-- all Azzandara followers convert to Anra
		for city in player:Cities() do
			city:ConvertPercentFollowers(RELIGION_ANRA, RELIGION_AZZANDARAYASNA, 100)
		end
	end

	UpdateCivReligion(iPlayer)
	RefreshBeliefs()	--may or may not be redundant with FoundReligion call, but that's OK

	--Burn a little mana at no cost to civ
	gWorld.sumOfAllMana = gWorld.sumOfAllMana - MANA_CONSUMED_BY_CIV_FALL
	eaPlayer.manaConsumed = (eaPlayer.manaConsumed or 0) + MANA_CONSUMED_BY_CIV_FALL
end

local religionConversionTable = {[-1] = 0}
local religionPopTable = {[-1] = 0}
for religion in GameInfo.Religions() do
	religionConversionTable[religion.ID] = 0
	religionPopTable[religion.ID] = 0
end

function GetConversionOutcome(city, religionID, mod)
	Dprint("GetConversionOutcome ", city, religionID, mod)
	--Priority is non-religious first, then reverse order by ID
	for i = -1, HIGHEST_RELIGION_ID do
		religionConversionTable[i] = 0
		if i == -1 or gReligions[i] then
			religionPopTable[i] = city:GetNumFollowers(i)
		end
	end
	local population = city:GetPopulation()
	local totalConversions = 0

	if mod <= religionPopTable[-1] then
		religionConversionTable[-1] = mod
		totalConversions = mod
	else
		religionConversionTable[-1] = religionPopTable[-1]
		totalConversions = religionPopTable[-1]
		mod = mod - religionPopTable[-1]
		local remainingPop = population  - religionPopTable[-1] - religionPopTable[religionID]
		while mod > 6 and remainingPop > 0 do
			for i = HIGHEST_RELIGION_ID, 0, -1 do
				if i ~= religionID and religionPopTable[i] > 0 then
					religionConversionTable[i] = religionConversionTable[i] + 1
					religionPopTable[i] = religionPopTable[i] - 1
					remainingPop = remainingPop - 1
					totalConversions = totalConversions + 1
					mod = mod - 6
				end
			end
		end
	end

	local bFlip = false
	if city:GetReligiousMajority() ~= religionID then
		local fractionTimesTwo = 2 * (religionPopTable[religionID] + totalConversions) / population
		if fractionTimesTwo > 1 or (fractionTimesTwo == 1 and city:GetPressurePerTurn(religionID) > 0) then
			bFlip = true
		end
	end

	return totalConversions, bFlip, religionConversionTable
end

----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)