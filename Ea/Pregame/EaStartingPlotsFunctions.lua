-- AssignEaHiddenCivs
-- Author: Pazyryk
-- DateCreated: 4/8/2013 11:25:36 PM
--------------------------------------------------------------
-- Called from end of AssignStartingPlots:PlaceResourcesAndCityStates() in AssignStartingPlots.lua

-- Note: file also loads repeatedly when exiting game to main menu, when GameDefines aren't defined

local nextCityStateID = (GameDefines.MAX_MAJOR_CIVS or 0) - 1
function GetNextCityStateID()
	while nextCityStateID < GameDefines.MAX_CIV_PLAYERS - 1 do
		nextCityStateID = nextCityStateID + 1
		local cityState = Players[nextCityStateID]
		local trait = cityState:GetMinorCivTrait()
		print("GetNextCityStateID ", nextCityStateID, cityState:GetMinorCivType(), trait)
		if trait ~= GameInfoTypes.MINOR_TRAIT_RELIGIOUS then
			print("GetNextCityStateID returning playerID ", nextCityStateID, Locale.ConvertTextKey(GameInfo.MinorCivilizations[cityState:GetMinorCivType()].Description))
			return nextCityStateID
		end
	end
	return nil		--there are no more to pick from
end


function GetMaxAvailableCityStates()
	nextCityStateID = GameDefines.MAX_MAJOR_CIVS - 1
	local maxNumber = 0
	while GetNextCityStateID() do
		maxNumber = maxNumber + 1
	end
	nextCityStateID = GameDefines.MAX_MAJOR_CIVS - 1
	return maxNumber
end


local nextGodID = (GameDefines.MAX_MAJOR_CIVS or 0) - 1
function GetNextGodID()
	while nextGodID < GameDefines.MAX_CIV_PLAYERS - 1 do
		nextGodID = nextGodID + 1
		local god = Players[nextGodID]
		local trait = god:GetMinorCivTrait()
		--print("GetNextCityStateID ", nextGodID, god:GetMinorCivType(), trait)
		if trait == GameInfoTypes.MINOR_TRAIT_RELIGIOUS then
			print("GetNextGodID returning playerID ", nextGodID, Locale.ConvertTextKey(GameInfo.MinorCivilizations[god:GetMinorCivType()].Description))
			return nextGodID
		end
	end
	return nil
end

function IsEaGodForNWInGame(featureInfo)
	local eaGodType = featureInfo.EaGod
	if eaGodType then
		eaGodID = GameInfoTypes[eaGodType]
		if eaGodID then
			local bInGame = false
			for iPlayer = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1 do
				local player = Players[iPlayer]
				if player:GetMinorCivType() == eaGodID then
					bInGame = true
					break
				end
			end
			return bInGame
		else
			return false	--mabye not added as minor civ yet
		end
	else
		return true		--no god needed for this one
	end
end

--Make sure Ahriman's Vault is in every game.
function PrioritizeAhrimansVault(NW_final_selections, wonder_list)	--self.wonder_list
	--debug
	local indexAhrimansVault
	for i, nw_number in ipairs(NW_final_selections) do
		local nw_type = wonder_list[nw_number]
		print(i, nw_number, nw_type)
		if nw_type == "FEATURE_SOLOMONS_MINES" then
			indexAhrimansVault = i
		end
	end
	if not indexAhrimansVault then
		error("FEATURE_SOLOMONS_MINES was not present in map generation; this map is not playable")
	end
	NW_final_selections[1], NW_final_selections[indexAhrimansVault] = NW_final_selections[indexAhrimansVault], NW_final_selections[1]
end


function EaMapAdjustments()
	print("-")
	print("--- EaMapAdjustments")
	print("-")
	local iW, iH = Map.GetGridSize()
	local azzandarasPyramidX, azzandarasPyramidY

	for y = 0, iH - 1 do
		for x = 0, iW - 1 do
			local plot = Map.GetPlot(x, y)

			--remove barries from desert
			if plot:GetResourceType(-1) == GameInfoTypes.RESOURCE_BERRIES then
				local terrainType = plot:GetTerrainType();
				if terrainType == TerrainTypes.TERRAIN_DESERT then
					print(" -removing berries from desert")
					plot:SetResourceType(-1)
				end
			end

			--find Azzandara's Pyramid
			if plot:GetFeatureType() == GameInfoTypes.FEATURE_EL_DORADO then
				print(" -found Azzandara's Pyramid")
				azzandarasPyramidX, azzandarasPyramidY = x, y
			end

		end
	end

	--if Azzandara's Pyramid exists, make sure a Man player is closest (if any exist)
	if azzandarasPyramidX then
		print("-")
		local shortestDist = 9999
		local closestPlayerIndex
		local closestPlot
		local manPlayerIndexes = {}
		local numMan = 0
		--
		for iPlayer = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
			local player = Players[iPlayer]
			local startingPlot = player:GetStartingPlot()
			if startingPlot then
				local dist = Map.PlotDistance(startingPlot:GetX(), startingPlot:GetY(), azzandarasPyramidX, azzandarasPyramidY)
				if dist < shortestDist then
					shortestDist = dist
					closestPlayerIndex = iPlayer
					closestPlot = startingPlot
				end
				if player:GetCivilizationType() == 0 then
					numMan = numMan + 1
					manPlayerIndexes[numMan] = iPlayer			
				end
			end
		end
		local closestPlayer = Players[closestPlayerIndex]
		if closestPlayer:GetCivilizationType() == 0 then
			print(" -closest player to Azzandara's Pyramid is Man; do nothing")
		elseif numMan > 0 then
			print("-")
			local iManPlayer = manPlayerIndexes[Map.Rand(numMan, "hello") + 1]
			local manPlayer = Players[iManPlayer]

			--swap
			print(" -closest player to Azzandara's Pyramid is not Man; swapping starting plots")
			closestPlayer:SetStartingPlot(manPlayer:GetStartingPlot())
			manPlayer:SetStartingPlot(closestPlot)
		end
	end
	print("-")
end
