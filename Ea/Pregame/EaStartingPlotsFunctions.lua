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