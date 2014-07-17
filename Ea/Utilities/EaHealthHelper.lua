-- HealthHelper
-- Author: Pazyryk
-- DateCreated: 5/19/2014 2:39:19 PM
--------------------------------------------------------------

MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

local RELIGION_ANRA =		GameInfoTypes.RELIGION_ANRA

local Floor =		math.floor

local BASE_HEALTH_FROM_HANDICAP = 5		--TO DO: Add to handicap table 


local buildingHealthMod = {}
for buildingInfo in GameInfo.Buildings() do
	if buildingInfo.EaHealth ~= 0 then
		buildingHealthMod[buildingInfo.ID] = buildingInfo.EaHealth
	end
end

function GetCityHealthForUI(city, bToolTip)
	local player = Players[city:GetOwner()]
	local iPlot = city:Plot():GetPlotIndex()
	local eaCity = gT.gCities[iPlot]
	local size = city:GetPopulation()	
	local followerReligion = city:GetReligiousMajority()	
	local aiGrowthPercent
	if not player:IsHuman() then
		local playerHandicapID = player:GetHandicapType()
		aiGrowthPercent = GameInfo.HandicapInfos[playerHandicapID].AIGrowthPercent
	end
	return GetCityHealthInfo(city, eaCity, size, followerReligion, aiGrowthPercent, bToolTip)
end

function GetCityHealthInfo(city, eaCity, size, followerReligion, aiGrowthPercent, bToolTip)

	local healthFromBuildings = 0
	for buildingID, healthMod in pairs(buildingHealthMod) do
		healthFromBuildings = healthFromBuildings + (healthMod * city:GetNumBuilding(buildingID))
	end

	local healthFromAIHandicap = 0
	if aiGrowthPercent then			-- 160 (settler); 110 (warlord); 100 (prince); 60 (diety)
		healthFromAIHandicap = healthFromAIHandicap + (aiGrowthPercent - 100) / 10
	end

	local healthFromAnra = (followerReligion == RELIGION_ANRA) and -2 or 0

	local healthFromArmageddon = (gT.gWorld.armageddonStage < 3) and 0 or -gT.gWorld.armageddonSap

	local health = Floor(BASE_HEALTH_FROM_HANDICAP + healthFromAIHandicap + healthFromBuildings + healthFromAnra + healthFromArmageddon - size)

	local diseaseChance = -health
	local plagueChance = diseaseChance - 5
	diseaseChance = diseaseChance < 0 and 0 or diseaseChance
	plagueChance = plagueChance < 0 and 0 or plagueChance

	if bToolTip then
		local str = "This city can support up to " .. health + size .. " citizens without risk of disease or starting a plague."

		if eaCity.disease > 0 then
			str = str .. " It is currently experiencing disease and will lose one population point per turn for the next " .. eaCity.disease .. " turn(s)."
		elseif eaCity.disease < 0 then
			str = str .. " It is currently experiencing plague and will lose one population point per turn for the next " .. -eaCity.disease .. " turn(s). There is a " .. diseaseChance .. "% chance per turn that this will spread to any other cities that are close (< 6 plots) or share a trade route."
		elseif health < 0 then
			str = str .. " Current excess of " .. -health .. " citizens is causing a " .. diseaseChance .. "% chance of disease and a " .. plagueChance .. "% chance of plague per turn."
		end
		str = str .. "[NEWLINE]"

		if BASE_HEALTH_FROM_HANDICAP ~= 0 then
			str = str .. "[NEWLINE][ICON_BULLET]+" .. BASE_HEALTH_FROM_HANDICAP .. " [ICON_HEALTH] " .. Locale.ConvertTextKey("TXT_KEY_HEALTH_FROM_HANDICAP")
		end
		if healthFromAIHandicap < 0 then
			str = str .. "[NEWLINE][ICON_BULLET]" .. healthFromAIHandicap .. " [ICON_UNHEALTH] " .. Locale.ConvertTextKey("TXT_KEY_HEALTH_FROM_AI_HANDICAP")
		elseif healthFromAIHandicap > 0 then
			str = str .. "[NEWLINE][ICON_BULLET]+" .. healthFromAIHandicap .. " [ICON_HEALTH] " .. Locale.ConvertTextKey("TXT_KEY_HEALTH_FROM_AI_HANDICAP")	
		end
		if healthFromBuildings < 0 then
			str = str .. "[NEWLINE][ICON_BULLET]" .. healthFromBuildings .. " [ICON_UNHEALTH] " .. Locale.ConvertTextKey("TXT_KEY_HEALTH_FROM_BUILDINGS")
		elseif healthFromBuildings > 0 then
			str = str .. "[NEWLINE][ICON_BULLET]+" .. healthFromBuildings .. " [ICON_HEALTH] " .. Locale.ConvertTextKey("TXT_KEY_HEALTH_FROM_BUILDINGS")		
		end
		if healthFromAnra ~= 0 then
			str = str .. "[NEWLINE][ICON_BULLET]" .. healthFromAnra .. " [ICON_UNHEALTH] " .. Locale.ConvertTextKey("TXT_KEY_HEALTH_FROM_ANRA")
		end
		if healthFromArmageddon ~= 0 then
			str = str .. "[NEWLINE][ICON_BULLET]" .. healthFromArmageddon .. " [ICON_UNHEALTH] " .. Locale.ConvertTextKey("TXT_KEY_HEALTH_FROM_ARMAGEDDON")
		end

		str = str .. "[NEWLINE][ICON_BULLET]" .. -size .. " [ICON_UNHEALTH] " .. Locale.ConvertTextKey("TXT_KEY_HEALTH_FROM_POPULATION")

		return str
	else
		return health, diseaseChance, plagueChance
	end

end
