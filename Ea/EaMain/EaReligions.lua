-- Religions
-- Author: Pazyryk
-- DateCreated: 8/3/2012 6:39:12 PM
--------------------------------------------------------------

print("Loading EaReligions.lua...")
local print = ENABLE_PRINT and print or function() end

--------------------------------------------------------------
-- Settings
-------------------------------------------------------------

local MANA_CONSUMED_BY_ANRA_FOUNDING =	EaSettings.MANA_CONSUMED_BY_ANRA_FOUNDING
local MANA_CONSUMED_BY_CIV_FALL =		EaSettings.MANA_CONSUMED_BY_CIV_FALL

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
local gg_techTier =	gg_techTier

--functions
local Rand = Map.Rand
local floor = math.floor
local HandleError21 = HandleError21

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
-- Local functions
--------------------------------------------------------------

local function TestEnableProtectorConditions()

	local bAllow = true
	for iPlayer, eaPlayer in pairs(fullCivs) do
		if eaPlayer.bIsFallen and not eaPlayer.bRenouncedMaleficium then
			bAllow = false
			break
		end
	end
	if bAllow then
		print(" -there are currently no fallen civs that have not renounced maleficium")
		if not gReligions[RELIGION_ANRA] or (not Game.GetHolyCityForReligion(RELIGION_ANRA, -1) and Game.GetNumFollowers(RELIGION_ANRA) == 0) then
			print(" -everything is good... where are we with Prophecy of Simsum and Sealing the Vault?")
			if gWorld.evilControl == "Sealed" then
				gWorld.bEnableProtectorVC = true
				print(" -all Protector VCs met; should have victory now...")
				TestUpdateVictory(-1)				--will trigger VC
				return
			elseif gWorld.evilControl == "Open" then
				print(" -making Seal Ahriman's Vault easy now...")
				gWorld.bEnableEasyVaultSeal = true	--any GP can do it cheaply now
				return
			end
		end
	end
	gWorld.bEnableEasyVaultSeal = false		--conditions might have changed
end


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
		local convertNum = floor(gWorld[convertKey])
		if convertNum >= 1 then
			print("floor value for ", convertKey, " = ", convertNum)
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
					city:ConvertPercentFollowers(religionID, -1, floor(100 / numAtheists + 0.9))
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
								city:ConvertPercentFollowers(religionID, loopReligionID, floor(100 / loopFollowers + 0.9))
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

	--AI player who owns Anra Holy City might raze it
	local anraHolyCity = gReligions[RELIGION_ANRA] and Game.GetHolyCityForReligion(GameInfoTypes.RELIGION_ANRA, -1)
	if anraHolyCity then
		local iOwner = anraHolyCity:GetOwner()
		local eaOwner = gPlayers[iOwner]
		if not eaOwner.bIsFallen and not eaOwner.bRenouncedMaleficium then
			if iOwner ~= anraHolyCity:GetOriginalOwner() and not Players[iOwner]:IsHuman() then
				if not anraHolyCity:IsRazing() then
					anraHolyCity:ChangeRazingTurns(1000)
				end
			end
		end
	end

	TestEnableProtectorConditions()
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
	end
end

function SetDivineFavorUse(iPlayer, bDivineFavor)
	print("SetDivineFavorUse ", iPlayer, bDivineFavor)
	--Always set eaPlayer.bUsesDivineFavor here so we can do all associated changes in one place!

	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer.bUsesDivineFavor == not bDivineFavor then return end	--already done (not's used to make nil and false equivelent)

	--this value controls all game rules and UI
	eaPlayer.bUsesDivineFavor = bDivineFavor

	--save old accumulation in case flips back
	local player = Players[iPlayer]
	local saveFaith = player:GetFaith()
	player:SetFaith(eaPlayer.savedFaithFromManaDivineFavorSwap)
	eaPlayer.savedFaithFromManaDivineFavorSwap = 0 < saveFaith and saveFaith or 0

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

	--hidden policies
	player:SetHasPolicy(GameInfoTypes.POLICY_USES_DIVINE_FAVOR, bDivineFavor)
	player:SetHasPolicy(GameInfoTypes.POLICY_USES_MANA, not bDivineFavor)

end

function FoundReligion(iPlayer, iCity, religionID)	--call should make sure that this is a valid city
	print("FoundReligion ", iPlayer, iCity, religionID)
	local player = Players[iPlayer]
	local city = player:GetCityByID(iCity)
	local eaCity = gCities[city:Plot():GetPlotIndex()]
	local eaPlayer = gPlayers[iPlayer]
	local religion = GameInfo.Religions[religionID]
	gReligions[religionID] = {founder = iPlayer}		--use table existance to know religion is founded (no game function for this)
	local beliefID = religion.EaInitialBelief and GameInfoTypes[religion.EaInitialBelief] or -1
	local belief2ID = religion.EaInitialBelief2 and GameInfoTypes[religion.EaInitialBelief2] or -1
	local belief3ID = religion.EaInitialBelief3 and GameInfoTypes[religion.EaInitialBelief3] or -1

	if religionID == RELIGION_ANRA and gWorld.evilControl == "Sealed" then return end	--don't know how but maybe

	--get credit for converting Anra followers
	local anraFollowersBefore = not eaPlayer.bIsFallen and gReligions[RELIGION_ANRA] and city:GetNumFollowers(RELIGION_ANRA) or 0

	Game.FoundReligion(iPlayer, religionID, nil, beliefID, belief2ID, belief3ID, -1, city)
	if not city:IsHolyCityForReligion(religionID) then
		error("city isn't Holy City after religion founding")
	end

	if eaCity then		--doesn't exist for initail Fay founding of the Weave
		eaCity.holyCityFor = eaCity.holyCityFor or {}
		eaCity.holyCityFor[religionID] = true		--need this to figure out if an eaCity was HC after it has been razed to ground
	end

	while city:GetReligiousMajority() ~= religionID do	--make it so
		local convertID, followers
		repeat
			convertID = Rand(HIGHEST_RELIGION_ID + 2, "hello") - 1
			if convertID ~= religionID then
				followers = (convertID == -1 or gReligions[convertID]) and city:GetNumFollowers(convertID)
			end
		until followers
		print("Converting random religions until founded is majority; converting religionID = ", convertID)
		local convertPercent = floor(100 / followers + 0.9)
		city:ConvertPercentFollowers(religionID, convertID, convertPercent)
	end


	if not eaPlayer.bIsFallen then		--tally up conversion credit
		local anraFollowersAfter = gReligions[RELIGION_ANRA] and city:GetNumFollowers(RELIGION_ANRA) or 0
		if anraFollowersAfter < anraFollowersBefore then
			eaPlayer.fallenFollowersDestr = (eaPlayer.fallenFollowersDestr or 0) + 2 * (anraFollowersAfter - anraFollowersBefore)
		end
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
		gWorld.bAnraHolyCityExists = true

		--Burn a good chunk of mana
		gWorld.sumOfAllMana = gWorld.sumOfAllMana - MANA_CONSUMED_BY_ANRA_FOUNDING
		eaPlayer.manaConsumed = eaPlayer.manaConsumed + MANA_CONSUMED_BY_ANRA_FOUNDING
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

function ChangeMaleficiumLevelWithTests(iPlayer, change)
	--some checks here to make sure we're not doing this wrong
	if not fullCivs[iPlayer] then return end
	local eaPlayer = gPlayers[iPlayer]
	if eaPlayer.bRenouncedMaleficium then return end		--these guys never go positive or negative, so won't offer or ask for Renounce Maleficium
	if change < 0 then
		if not eaPlayer.bIsFallen then
			local player = Players[iPlayer]
			local maleficiumLevel = player:GetMaleficiumLevel()
			maleficiumLevel = maleficiumLevel > 0 and 0 or maleficiumLevel	--max 0, then change
			maleficiumLevel = maleficiumLevel + change
			player:SetMaleficiumLevel(maleficiumLevel)
		end
	elseif change > 0 then
		if eaPlayer.bIsFallen then
			local player = Players[iPlayer]
			local maleficiumLevel = player:GetMaleficiumLevel()
			maleficiumLevel = maleficiumLevel < 0 and 0 or maleficiumLevel	--min 0, then change
			maleficiumLevel = maleficiumLevel + change
			player:SetMaleficiumLevel(maleficiumLevel)	
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
	player:SetHasPolicy(GameInfoTypes.POLICY_IS_FALLEN, true)

	--MaleficiumLevel; figure this out from scratch since bad effects weren't given before civ was Fallen
	local maleficiumLevel = 1

	--techs
	for techID, eaTechType in pairs(gg_eaTechClass) do
		if eaPlayer.techs[techID] then
			if eaTechType == "ArcaneEvil" then
				maleficiumLevel = maleficiumLevel + gg_techTier[techID]
			elseif eaTechType == "Arcane" then
				maleficiumLevel = maleficiumLevel + floor(gg_techTier[techID] / 2)
			end
		end
	end

	--Mirror Theism branch; this WON'T call OnPlayerAdoptPolicyBranch & OnPlayerAdoptPolicy so do anything we need to do here
	if player:HasPolicy(POLICY_THEISM) then
		print("Converting Theism policies to mirror policies")
		player:SetPolicyBranchUnlocked(POLICY_BRANCH_ANTI_THEISM, true)
		player:SetHasPolicy(POLICY_ANTI_THEISM, true)
		maleficiumLevel = maleficiumLevel + 2
		for policy in GameInfo.Policies() do
			if policy.PolicyBranchType == "POLICY_BRANCH_THEISM" then
				if player:HasPolicy(policy.ID) then
					player:SetHasPolicy(policy.ID, false)
					player:SetHasPolicy(policy.ID + FALLEN_ID_SHIFT, true)
					maleficiumLevel = maleficiumLevel + 2
				end
			end
		end
		player:SetHasPolicy(POLICY_THEISM, false)
		if player:HasPolicy(POLICY_THEISM_FINISHER) then
			player:SetHasPolicy(POLICY_THEISM_FINISHER, false)
			player:SetHasPolicy(POLICY_ANTI_THEISM_FINISHER, true)
			maleficiumLevel = maleficiumLevel + 2
		end
		player:SetPolicyBranchUnlocked(POLICY_BRANCH_THEISM, false)
	end

	ChangeMaleficiumLevelWithTests(iPlayer, maleficiumLevel)

	--All spellcasters become Sorcerers
	for iPerson, eaPerson in pairs(gPeople) do
		if eaPerson.iPlayer == iPlayer then

			local class1, class2 = eaPerson.class1, eaPerson.class2
			if eaPerson.spells then
				print("Converting spellcaster")
				local unit = player:GetUnitByID(eaPerson.iUnit)
				unit:SetHasPromotion(PROMOTION_SORCERER, true)

				--convert spells "in-place"
				local spells = eaPerson.spells
				for i = 1, #spells do
					local spellID = spells[i]
					local alt = GameInfo.EaActions[spellID].FallenAltSpell
					if alt and alt ~= "IsFallen" then
						local altSpellID = GameInfoTypes[alt]
						spells[i] = altSpellID
					end
				end

				--convert subclass and reinit unit
				if eaPerson.subclass == "Priest" then
					eaPerson.subclass = "FallenPriest"
					eaPerson.class1 = "Devout"
					eaPerson.class2 = "Thaumaturge"
					RegisterGPActions(iPerson)
					eaPerson.unitTypeID = GameInfoTypes.UNIT_FALLENPRIEST
					InitGPUnit(iPlayer, iPerson, unit:GetX(), unit:GetY(), unit, nil, nil, nil, nil, true)
				elseif eaPerson.subclass == "Paladin" then
					eaPerson.subclass = "Eidolon"
					RegisterGPActions(iPerson)
					eaPerson.unitTypeID = GameInfoTypes.UNIT_EIDOLON
					InitGPUnit(iPlayer, iPerson, unit:GetX(), unit:GetY(), unit, nil, nil, nil, nil, true)
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
	if gWorld.evilControl ~= "Sealed" then
		gWorld.sumOfAllMana = gWorld.sumOfAllMana - MANA_CONSUMED_BY_CIV_FALL
		eaPlayer.manaConsumed = eaPlayer.manaConsumed + MANA_CONSUMED_BY_CIV_FALL
	end
end


local religionConversionTable = {[-1] = 0}
local religionPopTable = {[-1] = 0}
for religion in GameInfo.Religions() do
	religionConversionTable[religion.ID] = 0
	religionPopTable[religion.ID] = 0
end

function GetConversionOutcome(city, religionID, mod)
	--print("GetConversionOutcome ", city, religionID, mod)
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

function StripCreditMaleficium(iPlayer, iOtherPlayer, bRenounce)	--we're here because an evil civ has either Renounced Maleficium or been killed
	print("StripCreditMaleficium ", iPlayer, iOtherPlayer, bRenounce)
	local player = Players[iPlayer]
	local team = Teams[player:GetTeam()]
	local eaPlayer = gPlayers[iPlayer]

	local fallenFollowersDestr = 0
	local civsCorrectedPts = 0		--given permanently or provisionally depending on bRenounce (killed credit reversed if civ resurected)

	--remove techs (note: if we ever have teams, then this probably would break the team)
	for techID, eaTechClass in pairs(gg_eaTechClass) do
		if eaTechClass == "ArcaneEvil" then
			if team:IsHasTech(techID) then
				print(" -counting tech ", GameInfo.Technologies[techID].Type)
				civsCorrectedPts = civsCorrectedPts + (5 * gg_techTier[techID])
				if bRenounce then
					eaPlayer.techs[techID] = nil
					team:SetHasTech(techID, false)
				end
			end
		end
	end

	--remove policies; CL will be reduced but this is only temporary setback since Approach CL is unaffected
	local loseCLs = 0
	for policyInfo in GameInfo.Policies() do
		if policyInfo.PolicyBranchType == "POLICY_BRANCH_ANTI_THEISM" then
			if player:HasPolicy(policyInfo.ID) then
				print(" -counting policy ", GameInfo.Policies[policyInfo.ID].Type)
				civsCorrectedPts = civsCorrectedPts + 10
				if bRenounce then
					loseCLs = loseCLs + 1
					player:SetHasPolicy(policyInfo.ID, false)
				end
			end
		end
	end
	if player:IsPolicyBranchUnlocked(GameInfoTypes.POLICY_BRANCH_ANTI_THEISM) then
		print(" -counting Anti-Theism opener/finisher policies and locking the branch")
		if player:HasPolicy(GameInfoTypes.POLICY_ANTI_THEISM_FINISHER) then	--don't count for CL reduction
			civsCorrectedPts = civsCorrectedPts + 10
			if bRenounce then
				player:SetHasPolicy(GameInfoTypes.POLICY_ANTI_THEISM_FINISHER, false)
			end
		end
		civsCorrectedPts = civsCorrectedPts + 10
		if bRenounce then
			loseCLs = loseCLs + 1
			player:SetHasPolicy(GameInfoTypes.POLICY_ANTI_THEISM, false)
			player:SetPolicyBranchUnlocked(GameInfoTypes.POLICY_BRANCH_ANTI_THEISM, false)
		end
	end
	eaPlayer.culturalLevel = eaPlayer.culturalLevel - loseCLs

	--spellcasters flee even if civ not fallen (Prophecy of Va may not be made yet, but we don't want spellcasters reanimating dead)
	for iPerson, eaPerson in pairs(gPeople) do
		if eaPerson.iPlayer == iPlayer and eaPerson.spells then
			fallenFollowersDestr = fallenFollowersDestr + 2 * eaPerson.level
			KillPerson(iPlayer, iPerson, nil, -1, "Renounce Maleficium")	--individual death notification suppressed
		end
	end

	--only full civs get credit and only if not fallen
	if fullCivs[iOtherPlayer] then
		local eaOtherPlayer = gPlayers[iOtherPlayer]
		if not eaOtherPlayer.bIsFallen then
			if bRenounce then		--credit is permanent
				eaOtherPlayer.civsCorrected = (eaOtherPlayer.civsCorrected or 0) + civsCorrectedPts
			else		--iPlayer was killed; credit is given provisionally and may be revoked if player resurected into world where Ahriman's Vault has not been sealed
				eaOtherPlayer.civsCorrectedProvisional = eaOtherPlayer.civsCorrectedProvisional or {}
				eaOtherPlayer.civsCorrectedProvisional[iPlayer] = (eaOtherPlayer.civsCorrectedProvisional[iPlayer] or 0) + civsCorrectedPts
			end
			eaOtherPlayer.fallenFollowersDestr = (eaOtherPlayer.fallenFollowersDestr or 0) + fallenFollowersDestr
		end
	end

	--can we enable protector victory now?
	TestEnableProtectorConditions()

end

local function OnRenounceMaleficium(iPlayer1, iPlayer2)
	print("OnRenounceMaleficium ", iPlayer1, iPlayer2)
	--one player must be persuing Maleficium or anti-Theism and the other not; use that to figure out who is renouncing
	local player, otherPlayer = Players[iPlayer1], Players[iPlayer2]
	local malLevel = player:GetMaleficiumLevel()
	local iPlayer, iOtherPlayer
	if (malLevel > 0) == (otherPlayer:GetMaleficiumLevel() > 0) then
		error("Renounce maleficium by or to wrong player " .. iPlayer1 .. " " .. iPlayer2 .. " " .. malLevel .. " " .. malLevelOther)
	end
	if malLevel > 0 then
		iPlayer, iOtherPlayer = iPlayer1, iPlayer2
	else
		player, otherPlayer = otherPlayer, player
		iPlayer, iOtherPlayer = iPlayer2, iPlayer1
	end
	print(" -player " .. iPlayer .. " renounces with GetMaleficiumLevel = ", player:GetMaleficiumLevel())
	local eaPlayer = gPlayers[iPlayer]

	--mark as renounced to restrict techs/policies; set MaleficiumLevel to 0 forever so this item will never be offered or asked for
	eaPlayer.bRenouncedMaleficium = true
	player:SetMaleficiumLevel(0)

	--remove maleficium and give credit
	StripCreditMaleficium(iPlayer, iOtherPlayer, true)

	--player may or may not be fallen; we can undo that here unless they are Anra religion (may become fallen again via Anra)
	if eaPlayer.religionID ~= RELIGION_ANRA then
		eaPlayer.bIsFallen = false
	end

	--update Top Panel for active player
	if iPlayer == g_iActivePlayer then
		LuaEvents.TopPanelInfoDirty()
	end
end
local function X_OnRenounceMaleficium(iPlayer1, iPlayer2) return HandleError21(OnRenounceMaleficium, iPlayer1, iPlayer2) end
GameEvents.RenounceMaleficium.Add(X_OnRenounceMaleficium)



----------------------------------------------------------------
-- Player change
----------------------------------------------------------------
local function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_iActivePlayer = iActivePlayer
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)