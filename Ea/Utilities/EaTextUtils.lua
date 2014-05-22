-- EaTextUtils
-- Author: Pazyryk
-- DateCreated: 12/2/2012 10:11:40 AM
--------------------------------------------------------------
MapModData.gT =  MapModData.gT or {}
local gT = MapModData.gT

local IMPROVEMENT_BARBARIAN_CAMP =	GameInfoTypes.IMPROVEMENT_BARBARIAN_CAMP

function GetEaPersonFullTitle(eaPerson)
	local nameStr = Locale.ConvertTextKey(eaPerson.name)
	if eaPerson.title then
		nameStr = Locale.ConvertTextKey(eaPerson.title) .. " " .. nameStr
	end
	return nameStr
end

function GetEaUnitFullName(unit)
	local unitTypeID = unit:GetUnitType()
	local unitInfo = GameInfo.Units[unitTypeID]

	if unit:HasName() then
		return unit:GetNameNoDesc() .. " (" .. Locale.Lookup(unitInfo.Description) .. ")"
	end

	local iPlayer = unit:GetOwner()
	local race = unitInfo.EaRace
	local playerType = MapModData.playerType[iPlayer]
	local civAdj

	if playerType == "FullCiv" then
		local eaPlayer = gT.gPlayers[iPlayer]
		if not eaPlayer then return end	
		if eaPlayer.eaCivNameID then
			civAdj = Locale.Lookup(PreGame.GetCivilizationAdjective(iPlayer))
		end		
	elseif playerType == "Barbs" then	
		local encampmentID = unit:GetScenarioData()
		if encampmentID > 0 then
			local adjTxtKey = GameInfo.EaEncampments[encampmentID].TribeAdjective
			civAdj = adjTxtKey and Locale.Lookup(adjTxtKey)
		elseif encampmentID == 0 then
			civAdj = "Captured"
		end
	elseif playerType == "CityState" then	
		civAdj = Locale.ConvertTextKey(Players[iPlayer]:GetCivilizationAdjectiveKey())
	end		--no civAdj for Animals

	--logic below is to avoid things like "Orc Warriors (Orc)", "Wildmen Wildmen (Man)", etc.
	local unitName = unit:GetName()
	local str = unitName
	if civAdj and civAdj ~= unitName then
		 str = civAdj .. " " .. str
	end
	if race then
		local raceStr = Locale.Lookup(GameInfo.EaRaces[race].Description)
		if raceStr then
			str = str .. " (" .. raceStr .. ")"
		end
	end

	return str
end

