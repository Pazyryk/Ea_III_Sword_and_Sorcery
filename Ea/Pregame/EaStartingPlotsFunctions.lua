-- AssignEaHiddenCivs
-- Author: Pazyryk
-- DateCreated: 4/8/2013 11:25:36 PM
--------------------------------------------------------------
-- Called from end of AssignStartingPlots:PlaceResourcesAndCityStates() in AssignStartingPlots.lua

--[[
function AddHiddenMapRegion(iW, iH)
	--build a mountain wall at y=1 and 0 (need to make this jagged for appearance); y=0 will later be cleared for hidden civs 
	print("*********************************************************************")
	print("Running AddHiddenMapRegion... ", iW, iH)
	for x = 0, iW - 1 do
		local plotEdge = Map.GetPlot(x, 2)
		if plotEdge:GetPlotType() == PlotTypes.PLOT_OCEAN then
			plotEdge:SetTerrainType(GameInfoTypes.TERRAIN_COAST , false, false)
		else
			plotEdge:SetTerrainType(GameInfoTypes.TERRAIN_SNOW , false, false)
		end
		plotEdge:SetResourceType(-1)
		plotEdge:SetFeatureType(GameInfoTypes.FEATURE_ICE, -1)
		plotEdge:SetImprovementType(-1)
		plotEdge:SetContinentArtType(3)
		local plotWall = Map.GetPlot(x, 1)
		plotWall:SetPlotType(PlotTypes.PLOT_LAND, false, false)
		plotWall:SetTerrainType(GameInfoTypes.TERRAIN_SNOW , false, false)
		plotWall:SetResourceType(-1)
		plotWall:SetFeatureType(GameInfoTypes.FEATURE_ICE, -1)
		plotWall:SetImprovementType(-1)
		--plotWall:SetContinentArtType(3)
		--print("Wall plot: ", plotWall:GetX(), plotWall:GetY(), plotWall:GetPlotType(), plotWall:GetTerrainType(), plotWall:GetResourceType(-1), plotWall:GetFeatureType(), plotWall:GetContinentArtType())
		local plotHidden = Map.GetPlot(x, 0)
		plotHidden:SetPlotType(PlotTypes.PLOT_LAND, false, false)
		plotHidden:SetTerrainType(GameInfoTypes.TERRAIN_SNOW , false, false)
		plotHidden:SetResourceType(-1)
		plotHidden:SetFeatureType(GameInfoTypes.FEATURE_ICE, -1)
		plotHidden:SetImprovementType(-1)
		plotHidden:SetContinentArtType(3)
	end
end

function AddEaHiddenCivs(iW, iH)
	print("*********************************************************************")
	print("Running AddEaHiddenCivs...")
	for x = 0, iW - 1 do
		--remake wall in case it was deconstructed by some other code (e.g., for starting plots balance)
		local plotEdge = Map.GetPlot(x, 2)
		if plotEdge:GetPlotType() == PlotTypes.PLOT_OCEAN then
			plotEdge:SetTerrainType(GameInfoTypes.TERRAIN_COAST , false, false)
		else
			plotEdge:SetTerrainType(GameInfoTypes.TERRAIN_SNOW , false, false)
		end
		plotEdge:SetResourceType(-1)
		plotEdge:SetFeatureType(GameInfoTypes.FEATURE_ICE, -1)
		plotEdge:SetImprovementType(-1)
		plotEdge:SetContinentArtType(3)
		local plotWall = Map.GetPlot(x, 1)
		plotWall:SetPlotType(PlotTypes.PLOT_LAND, false, false)
		plotWall:SetTerrainType(GameInfoTypes.TERRAIN_SNOW , false, false)
		plotWall:SetResourceType(-1)
		plotWall:SetFeatureType(GameInfoTypes.FEATURE_ICE, -1)
		plotWall:SetImprovementType(-1)
		plotWall:SetContinentArtType(3)
		local plotHidden = Map.GetPlot(x, 0)
		plotHidden:SetPlotType(PlotTypes.PLOT_LAND, false, false)
		plotHidden:SetTerrainType(GameInfoTypes.TERRAIN_SNOW , false, false)
		plotHidden:SetResourceType(-1)
		plotHidden:SetFeatureType(GameInfoTypes.FEATURE_ICE, -1)
		plotHidden:SetImprovementType(-1)
		plotHidden:SetContinentArtType(3)
	end
	local numCivs, numCityStates, player_ID_list, bTeamGame, teams_with_major_civs, number_civs_per_team = GetPlayerAndTeamInfo()
	print("GetPlayerAndTeamInfo: ", numCivs, numCityStates, player_ID_list, bTeamGame, teams_with_major_civs, number_civs_per_team)

	--Add The Fay
	--local EaSetupDB = Modding.OpenUserData("EaSetupData", 1)
	--local iFayPlayer = EaSetupDB.GetValue("FAY_PLAYER_INDEX")
	--local fayPlayer = Players[iFayPlayer]
	--local fayStartPlot = Map.GetPlot(0, 0)
	--fayPlayer:SetStartingPlot(fayStartPlot)		--mod init code will sweep up units and init city
	--print("Added The Fay (iPlayer/player/x/y): ",  iFayPlayer, fayPlayer, fayStartPlot:GetX(), fayStartPlot:GetY())

	--Add Gods until we run out of space or gods
	local x = 4
	local iGod = GetNextGodID()
	while iGod and x < iW - 3 do
		local god = Players[iGod]
		local godStartPlot = Map.GetPlot(x, 0)
		god:SetStartingPlot(godStartPlot)	
		print("Added a god (iPlayer/player/x/y): ",  iGod, god, godStartPlot:GetX(), godStartPlot:GetY())
		x = x + 1
		iGod = GetNextGodID()
	end
end 
]]

local nextCityStateID = GameDefines.MAX_MAJOR_CIVS - 1
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


local nextGodID = GameDefines.MAX_MAJOR_CIVS - 1
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