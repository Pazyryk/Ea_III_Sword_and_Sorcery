-- CityGraphicUpdater
-- Author: Pazyryk
-- DateCreated: 1/18/2013 4:20:36 PM
--------------------------------------------------------------
print("Loading CityGraphicUpdater.lua...")

--DISABLED for now to see if this is the cause for some city UI glitches in conquered cities
--Renable by uncommenting Events below
--Hook up to Error Handler for safety


local ARTSTYLE_EUROPEAN =		GameInfoTypes.ARTSTYLE_EUROPEAN
local ARTSTYLE_ASIAN =			GameInfoTypes.ARTSTYLE_ASIAN
local ARTSTYLE_SOUTH_AMERICA =	GameInfoTypes.ARTSTYLE_SOUTH_AMERICA
local BUILDING_SIDHE =			GameInfoTypes.BUILDING_SIDHE
local BUILDING_HELDEOFOL =		GameInfoTypes.BUILDING_HELDEOFOL

local g_cityUpdateInfo = {}
local g_cityUpdateNum = 0
local function ListenerSerialEventCityCreated(vHexPos, iPlayer, iCity, artStyleType, eraType, continent, populationSize, size, fogState)
	--print("PazDebug ListenerSerialEventCityCreated", vHexPos, iPlayer, iCity, artStyleType, eraType, continent, populationSize, size, fogState)

	local player = Players[iPlayer]
	local city = player:GetCityByID(iCity)
	if city then
		local newArtStyleType = ARTSTYLE_EUROPEAN
		if city:GetNumRealBuilding(BUILDING_HELDEOFOL) == 1 then
			newArtStyleType = ARTSTYLE_SOUTH_AMERICA
		elseif city:GetNumRealBuilding(BUILDING_SIDHE) == 1 then
			newArtStyleType = ARTSTYLE_ASIAN
		end
		if artStyleType ~= newArtStyleType then
			g_cityUpdateNum = g_cityUpdateNum + 1
			g_cityUpdateInfo[g_cityUpdateNum] = g_cityUpdateInfo[g_cityUpdateNum] or {}
			local updateInfo = g_cityUpdateInfo[g_cityUpdateNum]
			updateInfo[1] = {x = vHexPos.x, y = vHexPos.y, z = vHexPos.z}
			updateInfo[2] = iPlayer
			updateInfo[3] = iCity
			updateInfo[4] = newArtStyleType
			updateInfo[5] = eraType
			updateInfo[6] = continent
			updateInfo[7] = populationSize
			updateInfo[8] = size
			updateInfo[9] = fogState
			--Warning! Infinite loop if new updateInfo causes an update!
		end
	end
end
--Events.SerialEventCityCreated.Add(ListenerSerialEventCityCreated)

local function UpdateCityGraphics()
	--print("PazDebug UpdateCityGraphics")
	if g_cityUpdateNum == 0 then return end
	--print("Running UpdateCityGraphics; number cached = ", g_cityUpdateNum)
	local bTrimCache = 10 < g_cityUpdateNum
	while 0 < g_cityUpdateNum do
		local updateInfo = g_cityUpdateInfo[g_cityUpdateNum]
		g_cityUpdateNum = g_cityUpdateNum - 1
		Events.SerialEventCityCreated(updateInfo[1], updateInfo[2], updateInfo[3], updateInfo[4], updateInfo[5], updateInfo[6], updateInfo[7], updateInfo[8], updateInfo[9])
	end
	if bTrimCache then
		local top = #g_cityUpdateInfo
		while 10 < top do
			g_cityUpdateInfo[top] = nil
			top = top - 1
		end
	end
end
--Events.SerialEventGameDataDirty.Add(UpdateCityGraphics)
--Events.SequenceGameInitComplete.Add(UpdateCityGraphics)
--Events.SerialEventCityCaptured.Add(UpdateCityGraphics)	--not sure if this happens before or after city art change

