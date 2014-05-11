
function Test()

end


--Model functions for Cult Rituals
local EA_ACTION_RITUAL_LEAVES =	GameInfoTypes.EA_ACTION_RITUAL_LEAVES
local EA_ACTION_RITUAL_CLEANSING =	GameInfoTypes.EA_ACTION_RITUAL_CLEANSING
local EA_ACTION_RITUAL_AEGIR =	GameInfoTypes.EA_ACTION_RITUAL_AEGIR
local EA_ACTION_RITUAL_EQUUS =	GameInfoTypes.EA_ACTION_RITUAL_EQUUS
local EA_ACTION_RITUAL_BAKKHEIA =	GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA

local cultRitualReligions = {	[EA_ACTION_RITUAL_LEAVES] = GameInfoTypes.RELIGION_CULT_OF_LEAVES,
								[EA_ACTION_RITUAL_CLEANSING] = GameInfoTypes.RELIGION_CULT_OF_PURE_WATERS,
								[EA_ACTION_RITUAL_AEGIR] = GameInfoTypes.RELIGION_CULT_OF_AEGIR,
								[EA_ACTION_RITUAL_EQUUS] = GameInfoTypes.RELIGION_CULT_OF_EPONA,
								[EA_ACTION_RITUAL_BAKKHEIA] = GameInfoTypes.RELIGION_CULT_OF_BAKKHEIA	}

local function ModelCultRitual_TestTarget()
	g_int1 = cultRitualReligions[g_eaActionID]

	--Can't do in foreign city unless we are founder
	if g_iOwner ~= g_iPlayer and (not gReligions[g_int1] or gReligions[g_int1].founder ~= g_iPlayer) then return false end

	--Test cult-specific city req
	if g_eaActionID == EA_ACTION_RITUAL_LEAVES then
		local totalLand, totalUnimprovedForestJungle = 0, 0
		local totalPlots = g_city:GetNumCityPlots()
		for i = 0, totalPlots - 1 do
			local plot = g_city:GetCityIndexPlot(i)
			if plot and plot:GetPlotType() ~= PLOT_OCEAN then
				totalLand = totalLand + 1
				local featureID = plot:GetFeatureType()
				if featureID == FEATURE_FOREST or featureID == FEATURE_JUNGLE then
					if plot:GetImprovementType() == -1 then
						totalUnimprovedForestJungle = totalUnimprovedForestJungle + 1
					end
				end
			end
		end
		if totalUnimprovedForestJungle / totalLand < 0.6 or totalLand / totalPlots < 0.5 then
			g_int4 = totalUnimprovedForestJungle
			g_int2 = totalLand
			g_int3 = totalPlots
			return false
		end
	elseif g_eaActionID == EA_ACTION_RITUAL_CLEANSING then
		local totalPureWater = 0
		local totalPlots = g_city:GetNumCityPlots()
		for i = 0, totalPlots - 1 do
			local plot = g_city:GetCityIndexPlot(i)
			if plot and (plot:IsRiver() or plot:IsLake() or plot:IsFreshWater() or plot:GetFeatureType() == FEATURE_MARSH) then
				totalPureWater = totalPureWater + 1
			end
		end
		if totalPureWater / totalPlots < 0.35 then return false end
	elseif g_eaActionID == EA_ACTION_RITUAL_AEGIR then
		local totalSea = 0
		local totalPlots = g_city:GetNumCityPlots()
		for i = 0, totalPlots - 1 do
			local plot = g_city:GetCityIndexPlot(i)
			if plot and plot:GetPlotType() == PLOT_OCEAN then
				totalSea = totalSea + 1
			end
		end
		if totalSea / totalPlots < 0.7 then return false end
	elseif g_eaActionID == EA_ACTION_RITUAL_EQUUS then
		local totalLand, totalGoodFlatland, totalHorses = 0, 0, 0
		local totalPlots = g_city:GetNumCityPlots()
		for i = 0, totalPlots - 1 do
			local plot = g_city:GetCityIndexPlot(i)
			if plot then 
				local plotTypeID = plot:GetPlotType()
				if plotTypeID ~= PLOT_OCEAN then
					totalLand = totalLand + 1
					if plot:GetResourceType(-1) == RESOURCE_HORSE then
						totalHorses = totalHorses + 1
						if totalHorses > 2 then break end
					end
					if plotTypeID == PLOT_LAND and plot:GetFeatureType() == -1 then
						local terrainID = plot:GetTerrainType()
						if terrainID == TERRAIN_GRASS or  terrainID == TERRAIN_PLAINS then
							totalGoodFlatland = totalGoodFlatland + 1
						end
					end
				end
			end
		end
		if totalHorses < 2 then
			return false
		elseif totalHorses < 3 then
			if totalGoodFlatland / totalLand < 0.5 then return false end
		end
	elseif g_eaActionID == EA_ACTION_RITUAL_BAKKHEIA then
		local boozeBuildings = g_city:GetNumBuilding(BUILDING_WINERY) + g_city:GetNumBuilding(BUILDING_BREWERY) + g_city:GetNumBuilding(BUILDING_DISTILLERY)
		if boozeBuildings < 2 then
			local totalWine = 0
			local totalPlots = g_city:GetNumCityPlots()
			for i = 0, totalPlots - 1 do
				local plot = g_city:GetCityIndexPlot(i)
				if plot and plot:GetResourceType(-1) == RESOURCE_WINE then
					totalWine = totalWine + 1
				end
			end
			if totalWine < 2 then return false end
		end	
	end

	--Get conversion or found info
	if gReligions[g_int1] then		--already founded
		local totalConversions, bFlip, religionConversionTable = GetConversionOutcome(g_city, g_int1, g_mod)
		if totalConversions == 0 then
			g_testTargetSwitch = 2
			return false
		end
		g_tablePointer = religionConversionTable
		g_bool1 = bFlip
		g_value = totalConversions + (bFlip and 10 or 0) --for AI; passing conversion threshold worth 10 citizens 
		if gReligions[g_int1].founder ~= g_iPlayer then
			g_value = g_value / 10
		end
	else	--found
		if g_city:IsHolyCityAnyReligion() then
			g_testTargetSwitch = 3
			return false
		end
		g_value = 500
	end

	return true
end

local function ModelCultRitual_SetUI()
	if g_bNonTargetTestsPassed then
		MapModData.bShow = true
		if g_bAllTestsPassed then
			if gReligions[g_int1] then		--already founded
				local atheistsConverted = g_tablePointer[-1]
				if atheistsConverted > 0 then
					MapModData.text = "Will convert " .. atheistsConverted .. " non-followers[NEWLINE]"
				else
					MapModData.text = ""
				end
				for i = 0, HIGHEST_RELIGION_ID do
					local numConverted = g_tablePointer[i]
					if numConverted > 0 then
						MapModData.text = MapModData.text .. "Will convert ".. numConverted .. " followers of ".. Locale.ConvertTextKey(GameInfo.Religions[i].Description) .. "[NEWLINE]"
					end
				end
				if g_bool1 then
					local cultStr = Locale.Lookup(GameInfo.Religions[g_int1].Description)
					MapModData.text = MapModData.text .. cultStr .. " will become the city's dominant religion"
				end
			else
				local cultStr = Locale.Lookup(GameInfo.Religions[g_int1].Description)
				MapModData.text = "Will found the " .. cultStr .. " in this city"
			end
		elseif not g_bIsCity then
			local cultStr = Locale.Lookup(GameInfo.Religions[g_int1].Description)
			MapModData.text = cultStr .. " can be performed only in cities"
		elseif g_testTargetSwitch == 2 then
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot convert any population here (perhaps you need a higher Devotion level)[ENDCOLOR]"
		elseif g_testTargetSwitch == 3 then
			local cultStr = Locale.Lookup(GameInfo.Religions[g_int1].Description)
			MapModData.text = "[COLOR_WARNING_TEXT]You cannot perform the " .. cultStr .. " in a holy city[ENDCOLOR]"
		else	--failed for some cult-specific reason
			if g_eaActionID == EA_ACTION_RITUAL_LEAVES then
				local land = Floor(100 * g_int2 / g_int3)
				local forestJungle = Floor(100 * g_int4 / g_int2)
				MapModData.text = "[COLOR_WARNING_TEXT]City radius must be 50% land that is 60% unimproved forest or jungle (this city has "..land.."%, "..forestJungle.."%)[ENDCOLOR]"
			else
				--TO DO: Explanitory UI for all other cults
				MapModData.text = "[COLOR_WARNING_TEXT]You cannot perform this ritual in this city[ENDCOLOR]"
			end		
		end
	end
end

local function ModelCultRitual_SetAIValues()
	local majorityReligionID = g_city:GetReligiousMajority()
	local iMajorityFounder
	if majorityReligionID ~= -1 and majorityReligionID ~= RELIGION_THE_WEAVE_OF_EA and majorityReligionID ~= g_int1 then
		iMajorityFounder = gReligions[majorityReligionID].founder
	end
	if iMajorityFounder == g_iPlayer then	--don't do it if city has majority cult for which we are founder
		gg_aiOptionValues.i = 0
	elseif g_iOwner == g_iPlayer then
		gg_aiOptionValues.i = g_value * 2	--double value for converting our own
	else
		gg_aiOptionValues.i = g_value
	end
end

--EA_ACTION_RITUAL_LEAVES
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_LEAVES] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_LEAVES] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_LEAVES] = ModelCultRitual_SetAIValues

--EA_ACTION_RITUAL_CLEANSING
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_CLEANSING] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_CLEANSING] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_CLEANSING] = ModelCultRitual_SetAIValues

--EA_ACTION_RITUAL_AEGIR
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_AEGIR] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_AEGIR] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_AEGIR] = ModelCultRitual_SetAIValues

--EA_ACTION_RITUAL_EQUUS
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_EQUUS] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_EQUUS] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_EQUUS] = ModelCultRitual_SetAIValues

--EA_ACTION_RITUAL_BAKKHEIA
TestTarget[GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA] = ModelCultRitual_TestTarget
SetUI[GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA] = ModelCultRitual_SetUI
SetAIValues[GameInfoTypes.EA_ACTION_RITUAL_BAKKHEIA] = ModelCultRitual_SetAIValues
