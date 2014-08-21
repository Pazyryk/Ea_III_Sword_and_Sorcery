-------------------------------------------------
-- Help text for Info Objects (Units, Buildings, etc.)
-------------------------------------------------

--Paz: modified from G&K; roughly updated for BNW (added Processes but skipped Tourism)

--Paz add
------------------------------------------------
if MapModData then			--skips this from game setup, but works when file included from in-game UI
	MapModData.gT = MapModData.gT or {}
	gT = MapModData.gT
end

--localization (library functions changed to local in code below)
local insert =				table.insert
local ConvertTextKey =		Locale.ConvertTextKey
local ToUpper =				Locale.ToUpper

--cached info texts
local cached_Building_ResourceQuantity = {}
local cached_Building_LocalResourceOrs = {}
local cached_Building_ResourceYieldChanges = {}
local cached_Building_EaConvertImprovedResource = {}

local function ResetCashedBuildingStrings(bInit)	--called once for now; could be called for policy updates when those effects added
	print("Building cached info strings")

	print(" -cached_Building_ResourceQuantity")					--assume only one resource type per building 
	for row in GameInfo.Building_ResourceQuantity() do
		local buildingID = GameInfoTypes[row.BuildingType]
		local resourceInfo = GameInfo.Resources[row.ResourceType]
		local str = row.Quantity .. " " .. resourceInfo.IconString .. " " .. ConvertTextKey(resourceInfo.Description)
		str = ConvertTextKey("TXT_KEY_EA_PRODUCES_HELP_INFO", str)
		cached_Building_ResourceQuantity[buildingID] = str
	end

	print(" -cached_Building_LocalResourceOrs")
	local buildingLocalResourceOrs = {}
	for row in GameInfo.Building_LocalResourceOrs() do
		buildingLocalResourceOrs[row.BuildingType] = buildingLocalResourceOrs[row.BuildingType] or {count = 0}
		local resources = buildingLocalResourceOrs[row.BuildingType]
		resources.count = resources.count + 1
		resources[resources.count] = row.ResourceType
	end
	for buildingType, resources in pairs(buildingLocalResourceOrs) do
		local buildingID = GameInfoTypes[buildingType]
		local str
		for i = 1, resources.count do
			local resourceType = resources[i]
			--print("  *", buildingType, resourceType)
			local resourceInfo = GameInfo.Resources[resourceType]
			local resourceStr = resourceInfo.IconString .. " " .. ConvertTextKey(resourceInfo.Description)
			if i == 1 then
				str = resourceStr
			elseif i == resources.count then
				str = ConvertTextKey("TXT_KEY_EA_GENERIC_OR_CONNECTER", str, resourceStr)
			else
				str = str .. ", " .. resourceStr
			end
		end
		str = ConvertTextKey("TXT_KEY_EA_REQUIRES_NEARBY_HELP_INFO", str)
		cached_Building_LocalResourceOrs[buildingID] = str
	end

	print(" -cached_Building_ResourceYieldChanges")
	local buildingResourceYieldChanges = {}	--holds table for applicable building indexed by <yield per> text
	for row in GameInfo.Building_ResourceYieldChanges() do
		buildingResourceYieldChanges[row.BuildingType] = buildingResourceYieldChanges[row.BuildingType] or {}
		--"[ICON_BULLET]+1 [ICON_CULTURE] Culture from each ____, ____ and ____"
		local yieldInfo = GameInfo.Yields[row.YieldType]
		local yieldStr = "[ICON_BULLET]+" .. row.Yield .. " " .. yieldInfo.IconString .. " " .. ConvertTextKey(yieldInfo.Description)
		buildingResourceYieldChanges[row.BuildingType][yieldStr] = buildingResourceYieldChanges[row.BuildingType][yieldStr] or {count = 0}
		local resources = buildingResourceYieldChanges[row.BuildingType][yieldStr]
		resources.count = resources.count + 1
		resources[resources.count] = row.ResourceType
	end
	for buildingType, yieldResources in pairs(buildingResourceYieldChanges) do
		local buildingID = GameInfoTypes[buildingType]
		cached_Building_ResourceYieldChanges[buildingID] = cached_Building_ResourceYieldChanges[buildingID] or {}
		local cachedTable = cached_Building_ResourceYieldChanges[buildingID]
		for yieldStr, resources in pairs(yieldResources) do
			for i = 1, resources.count do
				local resourceType = resources[i]
				local resourceInfo = GameInfo.Resources[resourceType]
				local resourceStr = resourceInfo.IconString .. " " .. ConvertTextKey(resourceInfo.Description)
				if i == 1 then
					yieldStr = ConvertTextKey("TXT_KEY_EA_GENERIC_FOR_EACH_CONNECTER", yieldStr, resourceStr)
				elseif i == resources.count then
					yieldStr = ConvertTextKey("TXT_KEY_EA_GENERIC_AND_CONNECTER", yieldStr, resourceStr)
				else
					yieldStr = yieldStr .. ", " .. resourceStr
				end
			end
			--print("  *", buildingType, yieldStr)
			cachedTable[#cachedTable + 1] = yieldStr
		end
	end

	print(" -cached_Building_EaConvertImprovedResource")
	local buildingConvertImprovedResource = {}	--holds table for applicable building indexed by <resource per> text
	for row in GameInfo.Building_EaConvertImprovedResource() do
		buildingConvertImprovedResource[row.BuildingType] = buildingConvertImprovedResource[row.BuildingType] or {}
		--"[ICON_BULLET]Produces 1 [ICON_IVORY] Ivory for each improved ____, ____ and ____"
		local addResourceInfo = GameInfo.Resources[row.AddResource]
		local addResourceStr = "[ICON_BULLET]Produces 1 " .. addResourceInfo.IconString .. " " .. ConvertTextKey(addResourceInfo.Description)
		buildingConvertImprovedResource[row.BuildingType][addResourceStr] = buildingConvertImprovedResource[row.BuildingType][addResourceStr] or {count = 0}
		local resources = buildingConvertImprovedResource[row.BuildingType][addResourceStr]
		resources.count = resources.count + 1
		resources[resources.count] = row.ImprovedResource
	end
	for buildingType, improvedResources in pairs(buildingConvertImprovedResource) do
		local buildingID = GameInfoTypes[buildingType]
		cached_Building_EaConvertImprovedResource[buildingID] = cached_Building_EaConvertImprovedResource[buildingID] or {}
		local cachedTable = cached_Building_EaConvertImprovedResource[buildingID]
		for addResourceStr, resources in pairs(improvedResources) do
			for i = 1, resources.count do
				local resourceType = resources[i]
				local resourceInfo = GameInfo.Resources[resourceType]
				local resourceStr = resourceInfo.IconString .. " " .. ConvertTextKey(resourceInfo.Description)
				if i == 1 then
					addResourceStr = ConvertTextKey("TXT_KEY_EA_GENERIC_FOR_EACH_IMPROVED_CONNECTER", addResourceStr, resourceStr)
				elseif i == resources.count then
					addResourceStr = ConvertTextKey("TXT_KEY_EA_GENERIC_AND_CONNECTER", addResourceStr, resourceStr)
				else
					addResourceStr = addResourceStr .. ", " .. resourceStr
				end
			end
			--print("  *", buildingType, addResourceStr)
			cachedTable[#cachedTable + 1] = addResourceStr
		end
	end

end

if MapModData then ResetCashedBuildingStrings(true) end		--skips when file loads for setup screen

------------------------------------------------
--end Paz add


-- UNIT
function GetHelpTextForUnit(iUnitID, bIncludeRequirementsInfo)
	--print("PazDebug InfoTooltipInclude GetHelpTextForUnit")
	local pUnitInfo = GameInfo.Units[iUnitID];
	
	local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActiveTeam = Teams[Game.GetActiveTeam()];

	local strHelpText = "";
	
	-- Name
	strHelpText = strHelpText .. ToUpper(ConvertTextKey( pUnitInfo.Description ));
	
	-- Cost
	strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
	
	-- Skip cost if it's 0
	if(pUnitInfo.Cost > 0) then
		strHelpText = strHelpText .. ConvertTextKey("TXT_KEY_PRODUCTION_COST", pActivePlayer:GetUnitProductionNeeded(iUnitID));
		strHelpText = strHelpText .. "[NEWLINE]";
	end
	
	-- Moves
	strHelpText = strHelpText .. ConvertTextKey("TXT_KEY_PRODUCTION_MOVEMENT", pUnitInfo.Moves);
	
	-- Range
	local iRange = pUnitInfo.Range;
	if (iRange ~= 0) then
		strHelpText = strHelpText .. "[NEWLINE]";
		strHelpText = strHelpText .. ConvertTextKey("TXT_KEY_PRODUCTION_RANGE", iRange);
	end
	
	-- Ranged Strength
	local iRangedStrength = pUnitInfo.RangedCombat;
	if (iRangedStrength ~= 0) then
		strHelpText = strHelpText .. "[NEWLINE]";
		strHelpText = strHelpText .. ConvertTextKey("TXT_KEY_PRODUCTION_RANGED_STRENGTH", iRangedStrength);
	end
	
	-- Strength
	local iStrength = pUnitInfo.Combat;
	if (iStrength ~= 0) then
		strHelpText = strHelpText .. "[NEWLINE]";
		strHelpText = strHelpText .. ConvertTextKey("TXT_KEY_PRODUCTION_STRENGTH", iStrength);
	end
	
	-- Resource Requirements
	local iNumResourcesNeededSoFar = 0;
	local iNumResourceNeeded;
	local iResourceID;
	for pResource in GameInfo.Resources() do
		iResourceID = pResource.ID;
		iNumResourceNeeded = Game.GetNumResourceRequiredForUnit(iUnitID, iResourceID);
		if (iNumResourceNeeded > 0) then
			-- First resource required
			if (iNumResourcesNeededSoFar == 0) then
				strHelpText = strHelpText .. "[NEWLINE]";
				strHelpText = strHelpText .. ConvertTextKey("TXT_KEY_PRODUCTION_RESOURCES_REQUIRED");
				strHelpText = strHelpText .. " " .. iNumResourceNeeded .. " " .. pResource.IconString .. " " .. ConvertTextKey(pResource.Description);
			else
				strHelpText = strHelpText .. ", " .. iNumResourceNeeded .. " " .. pResource.IconString .. " " .. ConvertTextKey(pResource.Description);
			end
			
			-- JON: Not using this for now, the formatting is better when everything is on the same line
			--iNumResourcesNeededSoFar = iNumResourcesNeededSoFar + 1;
		end
 	end
	
	--Paz add: additional Tech requirements
	local matchStr = "UnitType = '" .. pUnitInfo.Type .. "'"
	local extraTechCount = 0
	for row in GameInfo.Unit_TechTypes(matchStr) do
		extraTechCount = extraTechCount + 1
		local techInfo = GameInfo.Technologies[row.TechType]
		if extraTechCount == 1 then
			strHelpText = strHelpText .. "[NEWLINE]" .. ConvertTextKey("TXT_KEY_EA_EXTRA_TECHS_REQUIRED")
			strHelpText = strHelpText .. " " .. ConvertTextKey(techInfo.Description)
		else
			strHelpText = strHelpText .. ", " .. ConvertTextKey(techInfo.Description)
		end
	end
	--end Paz add


	-- Pre-written Help text
	if (not pUnitInfo.Help) then
		print("Invalid unit help");
		print(strHelpText);
	else
		local strWrittenHelpText = ConvertTextKey( pUnitInfo.Help );
		if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
			-- Separator
			strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
			strHelpText = strHelpText .. strWrittenHelpText;
		end	
	end
	
	
	-- Requirements?
	if (bIncludeRequirementsInfo) then
		if (pUnitInfo.Requirements) then
			strHelpText = strHelpText .. ConvertTextKey( pUnitInfo.Requirements );
		end
	end
	
	return strHelpText;
	
end

-- BUILDING
function GetHelpTextForBuilding(iBuildingID, bExcludeName, bExcludeHeader, bNoMaintenance, pCity)
	--print("PazDebug InfoTooltipInclude GetHelpTextForBuilding")
	local pBuildingInfo = GameInfo.Buildings[iBuildingID];
	 
	local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActiveTeam = Teams[Game.GetActiveTeam()];
	
	local buildingClass = GameInfo.Buildings[iBuildingID].BuildingClass;
	local buildingClassID = GameInfo.BuildingClasses[buildingClass].ID;

	--Paz add
	local number = 1
	if pCity then
		number = pCity:GetNumBuilding(iBuildingID)
		number = number < 1 and 1 or number
	end
	local bUsesDivineFavor = false
	if gT and gT.gPlayers then
		local eaPlayer
		if pCity then
			eaPlayer = gT.gPlayers[pCity:GetOwner()]
		else
			eaPlayer = gT.gPlayers[Game.GetActivePlayer()]
		end
		bUsesDivineFavor = eaPlayer and eaPlayer.bUsesDivineFavor
	end
	--end Paz add

	--Paz modified code below by adding "* number" to most items

	local strHelpText = "";
	
	local lines = {};
	if (not bExcludeHeader) then
		
		if (not bExcludeName) then
			-- Name
			strHelpText = strHelpText .. ToUpper(ConvertTextKey( pBuildingInfo.Description ));
			strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
		end
		
		-- Cost
		--Only show cost info if the cost is greater than 0.
		if(pBuildingInfo.Cost > 0) then
			local iCost = pActivePlayer:GetBuildingProductionNeeded(iBuildingID);
			insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_COST", iCost));
		end
		
		-- Maintenance
		if (not bNoMaintenance) then
			local iMaintenance = pBuildingInfo.GoldMaintenance;
			if (iMaintenance ~= nil and iMaintenance ~= 0) then		
				insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_MAINTENANCE", iMaintenance * number));
			end
		end
		
	end
	
	-- Happiness (from all sources)
	local iHappinessTotal = 0;
	local iHappiness = pBuildingInfo.Happiness;
	if (iHappiness ~= nil) then
		iHappinessTotal = iHappinessTotal + iHappiness;
	end
	local iHappiness = pBuildingInfo.UnmoddedHappiness;
	if (iHappiness ~= nil) then
		iHappinessTotal = iHappinessTotal + iHappiness;
	end
	iHappinessTotal = iHappinessTotal + pActivePlayer:GetExtraBuildingHappinessFromPolicies(iBuildingID);
	if (pCity ~= nil) then
		iHappinessTotal = iHappinessTotal + pCity:GetReligionBuildingClassHappiness(buildingClassID) + pActivePlayer:GetPlayerBuildingClassHappiness(buildingClassID);
	end
	if (iHappinessTotal ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_HAPPINESS", iHappinessTotal * number));
	end
	
	-- Culture
	local iCulture = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_CULTURE);
	if (pCity ~= nil) then
		iCulture = iCulture + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_CULTURE) + pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_CULTURE);
	end
	if (iCulture ~= nil and iCulture ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_CULTURE", iCulture * number));
	end

	-- Faith
	local iFaith = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_FAITH);
	if (pCity ~= nil) then
		iFaith = iFaith + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FAITH) + pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FAITH);
	end
	if (iFaith ~= nil and iFaith ~= 0) then
		--Paz modified below: insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_FAITH", iFaith * number));
		if bUsesDivineFavor then
			insert(lines, ConvertTextKey("TXT_KEY_EA_PRODUCTION_BUILDING_DIVINE_FAVOR", iFaith * number))
		else
			insert(lines, ConvertTextKey("TXT_KEY_EA_PRODUCTION_BUILDING_MANA", iFaith * number))
		end
		--end Paz modified
	end
	
	-- Defense
	local iDefense = pBuildingInfo.Defense;
	if (iDefense ~= nil and iDefense ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_DEFENSE", iDefense * number / 100));
	end
	
	-- Hit Points
	local iHitPoints = pBuildingInfo.ExtraCityHitPoints;
	if (iHitPoints ~= nil and iHitPoints ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_HITPOINTS", iHitPoints * number));
	end
	
	-- Food
	local iFood = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_FOOD);
	if (pCity ~= nil) then
		iFood = iFood + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FOOD) + pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_FOOD);
	end
	if (iFood ~= nil and iFood ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_FOOD", iFood * number));
	end
	
	-- Gold Mod
	local iGold = Game.GetBuildingYieldModifier(iBuildingID, YieldTypes.YIELD_GOLD);
	iGold = iGold + pActivePlayer:GetPolicyBuildingClassYieldModifier(buildingClassID, YieldTypes.YIELD_GOLD);
	
	if (iGold ~= nil and iGold ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_GOLD", iGold * number));
	end
	
	-- Gold Change
	iGold = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_GOLD);
	if (pCity ~= nil) then
		iGold = iGold + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_GOLD) + pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_GOLD);
	end
	if (iGold ~= nil and iGold ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_GOLD_CHANGE", iGold * number));
	end
	
	-- Science
	local iScience = Game.GetBuildingYieldModifier(iBuildingID, YieldTypes.YIELD_SCIENCE);
	iScience = iScience + pActivePlayer:GetPolicyBuildingClassYieldModifier(buildingClassID, YieldTypes.YIELD_SCIENCE);
	if (iScience ~= nil and iScience ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_SCIENCE", iScience * number));
	end
	
	-- Science
	local iScienceChange = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_SCIENCE) + pActivePlayer:GetPolicyBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE);
	if (pCity ~= nil) then
		iScienceChange = iScienceChange + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE) + pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_SCIENCE);
	end
	if (iScienceChange ~= nil and iScienceChange ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_SCIENCE_CHANGE", iScienceChange * number));
	end
	
	-- Production
	local iProduction = Game.GetBuildingYieldModifier(iBuildingID, YieldTypes.YIELD_PRODUCTION);
	iProduction = iProduction + pActivePlayer:GetPolicyBuildingClassYieldModifier(buildingClassID, YieldTypes.YIELD_PRODUCTION);
	if (iProduction ~= nil and iProduction ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_PRODUCTION", iProduction * number));
	end

	-- Production Change
	local iProd = Game.GetBuildingYieldChange(iBuildingID, YieldTypes.YIELD_PRODUCTION);
	if (pCity ~= nil) then
		iProd = iProd + pCity:GetReligionBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_PRODUCTION) + pActivePlayer:GetPlayerBuildingClassYieldChange(buildingClassID, YieldTypes.YIELD_PRODUCTION);
	end
	if (iProd ~= nil and iProd ~= 0) then
		insert(lines, ConvertTextKey("TXT_KEY_PRODUCTION_BUILDING_PRODUCTION_CHANGE", iProd * number));
	end

	--Paz add: Health
	local iHealth = pBuildingInfo.EaHealth
	if iHealth > 0 then
		insert(lines, ConvertTextKey("TXT_KEY_EA_PRODUCTION_BUILDING_HEALTH_POSITIVE", iHealth * number))
	elseif iHealth < 0 then
		insert(lines, ConvertTextKey("TXT_KEY_EA_PRODUCTION_BUILDING_HEALTH_NEGATIVE", iHealth * number))
	end

	--end Paz add
	
	-- Great People
	local specialistType = pBuildingInfo.SpecialistType;
	if specialistType ~= nil then
		local iNumPoints = pBuildingInfo.GreatPeopleRateChange;
		if (iNumPoints > 0) then
			insert(lines, "[ICON_GREAT_PEOPLE] " .. ConvertTextKey(GameInfo.Specialists[specialistType].GreatPeopleTitle) .. " " .. iNumPoints); 
		
		end
		
		if(pBuildingInfo.SpecialistCount > 0) then
			-- Append a key such as TXT_KEY_SPECIALIST_ARTIST_SLOTS
			local specialistSlotsKey = GameInfo.Specialists[specialistType].Description .. "_SLOTS";
			insert(lines, "[ICON_GREAT_PEOPLE] " .. ConvertTextKey(specialistSlotsKey) .. " " .. pBuildingInfo.SpecialistCount);
		end
	end
	
	----------------------------------
	--Paz add

	--produces resource
	if cached_Building_ResourceQuantity[iBuildingID] then
		insert(lines, cached_Building_ResourceQuantity[iBuildingID])
	end

	--produces resource per improved resource
	if cached_Building_EaConvertImprovedResource[iBuildingID] then
		for i = 1, #cached_Building_EaConvertImprovedResource[iBuildingID] do
			insert(lines, cached_Building_EaConvertImprovedResource[iBuildingID][i])
		end
	end

	--yield per resource
	if cached_Building_ResourceYieldChanges[iBuildingID] then
		for i = 1, #cached_Building_ResourceYieldChanges[iBuildingID] do
			insert(lines, cached_Building_ResourceYieldChanges[iBuildingID][i])
		end
	end

	--nearby resource req
	if cached_Building_LocalResourceOrs[iBuildingID] then
		insert(lines, cached_Building_LocalResourceOrs[iBuildingID])
	end

	--policy req
	if pBuildingInfo.EaPrereqPolicy then
		local policyInfo = GameInfo.Policies[pBuildingInfo.EaPrereqPolicy]
		local policyStr = ConvertTextKey("TXT_KEY_EA_POLICY_REQUIRED") .. " " .. ConvertTextKey(policyInfo.Description)
		if pBuildingInfo.EaPrereqOrPolicy then
			local policyInfo = GameInfo.Policies[pBuildingInfo.EaPrereqPolicy]
			local policyStr = policyStr .. " or " .. ConvertTextKey(policyInfo.Description)
		end
		insert(lines, policyStr)
	end

	----------------------------------
	--end Paz add

	strHelpText = strHelpText .. table.concat(lines, "[NEWLINE]");
	
	-- Pre-written Help text
	if (pBuildingInfo.Help ~= nil) then
		local strWrittenHelpText = ConvertTextKey( pBuildingInfo.Help );
		if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
			-- Separator
			strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
			strHelpText = strHelpText .. strWrittenHelpText;
		end
	end
	
	return strHelpText;
	
end


-- IMPROVEMENT
function GetHelpTextForImprovement(iImprovementID, bExcludeName, bExcludeHeader, bNoMaintenance)
	local pImprovementInfo = GameInfo.Improvements[iImprovementID];
	
	local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActiveTeam = Teams[Game.GetActiveTeam()];
	
	local strHelpText = "";
	
	if (not bExcludeHeader) then
		
		if (not bExcludeName) then
			-- Name
			strHelpText = strHelpText .. ToUpper(ConvertTextKey( pImprovementInfo.Description ));
			strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
		end
				
	end
		
	-- if we end up having a lot of these we may need to add some more stuff here
	
	-- Pre-written Help text
	if (pImprovementInfo.Help ~= nil) then
		local strWrittenHelpText = ConvertTextKey( pImprovementInfo.Help );
		if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
			-- Separator
			-- strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
			strHelpText = strHelpText .. strWrittenHelpText;
		end
	end
	
	return strHelpText;
	
end

-- PROJECT
function GetHelpTextForProject(iProjectID, bIncludeRequirementsInfo)
	local pProjectInfo = GameInfo.Projects[iProjectID];
	
	local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActiveTeam = Teams[Game.GetActiveTeam()];
	
	local strHelpText = "";
	
	-- Name
	strHelpText = strHelpText .. ToUpper(ConvertTextKey( pProjectInfo.Description ));
	
	-- Cost
	local iCost = pActivePlayer:GetProjectProductionNeeded(iProjectID);
	strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
	strHelpText = strHelpText .. ConvertTextKey("TXT_KEY_PRODUCTION_COST", iCost);
	
	-- Pre-written Help text
	local strWrittenHelpText = ConvertTextKey( pProjectInfo.Help );
	if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
		-- Separator
		strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
		strHelpText = strHelpText .. strWrittenHelpText;
	end
	
	-- Requirements?
	if (bIncludeRequirementsInfo) then
		if (pProjectInfo.Requirements) then
			strHelpText = strHelpText .. ConvertTextKey( pProjectInfo.Requirements );
		end
	end
	
	return strHelpText;
	
end

-- PROCESS
function GetHelpTextForProcess(iProcessID, bIncludeRequirementsInfo)
	local pProcessInfo = GameInfo.Processes[iProcessID];
	local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActiveTeam = Teams[Game.GetActiveTeam()];
	
	local strHelpText = "";
	
	-- Name
	strHelpText = strHelpText .. ToUpper(ConvertTextKey(pProcessInfo.Description));
	
	-- Pre-written Help text
	local strWrittenHelpText = ConvertTextKey(pProcessInfo.Help);
	if (strWrittenHelpText ~= nil and strWrittenHelpText ~= "") then
		strHelpText = strHelpText .. "[NEWLINE]----------------[NEWLINE]";
		strHelpText = strHelpText .. strWrittenHelpText;
	end
	
	--[[Paz disabled
	-- League Project text
	if (not Game.IsOption("GAMEOPTION_NO_LEAGUES")) then
		local tProject = nil;
		
		for t in GameInfo.LeagueProjects() do
			if (iProcessID == GameInfo.Processes[t.Process].ID) then
				tProject = t;
				break;
			end
		end

		local pLeague = Game.GetActiveLeague();

		if (tProject ~= nil and pLeague ~= nil) then
			strHelpText = strHelpText .. "[NEWLINE][NEWLINE]";
			strHelpText = strHelpText .. pLeague:GetProjectDetails(GameInfo.LeagueProjects[tProject.Type].ID, Game.GetActivePlayer());
		end
	end
	]]

	return strHelpText;
end
-------------------------------------------------
-- Tooltips for Yield & Similar (e.g. Culture)
-------------------------------------------------

-- FOOD
function GetFoodTooltip(pCity)
	
	local iYieldType = YieldTypes.YIELD_FOOD;
	local strFoodToolTip = "";
	
	if (not OptionsManager.IsNoBasicHelp()) then
		strFoodToolTip = strFoodToolTip .. ConvertTextKey("TXT_KEY_FOOD_HELP_INFO");
		strFoodToolTip = strFoodToolTip .. "[NEWLINE][NEWLINE]";
	end
	
	local fFoodProgress = pCity:GetFoodTimes100() / 100;
	local iFoodNeeded = pCity:GrowthThreshold();
	
	strFoodToolTip = strFoodToolTip .. ConvertTextKey("TXT_KEY_FOOD_PROGRESS", fFoodProgress, iFoodNeeded);
	
	strFoodToolTip = strFoodToolTip .. "[NEWLINE][NEWLINE]";
	strFoodToolTip = strFoodToolTip .. GetYieldTooltipHelper(pCity, iYieldType, "[ICON_FOOD]");
	
	return strFoodToolTip;
end

-- GOLD
function GetGoldTooltip(pCity)
	
	local iYieldType = YieldTypes.YIELD_GOLD;

	local strGoldToolTip = "";
	if (not OptionsManager.IsNoBasicHelp()) then
		strGoldToolTip = strGoldToolTip .. ConvertTextKey("TXT_KEY_GOLD_HELP_INFO");
		strGoldToolTip = strGoldToolTip .. "[NEWLINE][NEWLINE]";
	end
	
	strGoldToolTip = strGoldToolTip .. GetYieldTooltipHelper(pCity, iYieldType, "[ICON_GOLD]");
	
	return strGoldToolTip;
end

-- SCIENCE
function GetScienceTooltip(pCity)
	
	local strScienceToolTip = "";

	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)) then
		strScienceToolTip = ConvertTextKey("TXT_KEY_TOP_PANEL_SCIENCE_OFF_TOOLTIP");
	else

		local iYieldType = YieldTypes.YIELD_SCIENCE;
	
		if (not OptionsManager.IsNoBasicHelp()) then
			strScienceToolTip = strScienceToolTip .. ConvertTextKey("TXT_KEY_SCIENCE_HELP_INFO");
			strScienceToolTip = strScienceToolTip .. "[NEWLINE][NEWLINE]";
		end
	
		strScienceToolTip = strScienceToolTip .. GetYieldTooltipHelper(pCity, iYieldType, "[ICON_RESEARCH]");
	end
	
	return strScienceToolTip;
end

-- PRODUCTION
function GetProductionTooltip(pCity)

	local iBaseProductionPT = pCity:GetBaseYieldRate(YieldTypes.YIELD_PRODUCTION);
	local iProductionPerTurn = pCity:GetCurrentProductionDifferenceTimes100(false, false) / 100;--pCity:GetYieldRate(YieldTypes.YIELD_PRODUCTION);
	local strCodeToolTip = pCity:GetYieldModifierTooltip(YieldTypes.YIELD_PRODUCTION);
	
	local strProductionBreakdown = GetYieldTooltip(pCity, YieldTypes.YIELD_PRODUCTION, iBaseProductionPT, iProductionPerTurn, "[ICON_PRODUCTION]", strCodeToolTip);
	
	-- Basic explanation of production
	local strProductionHelp = "";
	if (not OptionsManager.IsNoBasicHelp()) then
		strProductionHelp = strProductionHelp .. ConvertTextKey("TXT_KEY_PRODUCTION_HELP_INFO");
		strProductionHelp = strProductionHelp .. "[NEWLINE][NEWLINE]";
		--Controls.ProductionButton:SetToolTipString(ConvertTextKey("TXT_KEY_CITYVIEW_CHANGE_PROD_TT"));
	else
		--Controls.ProductionButton:SetToolTipString(ConvertTextKey("TXT_KEY_CITYVIEW_CHANGE_PROD"));
	end
	
	return strProductionHelp .. strProductionBreakdown;
end

-- CULTURE
function GetCultureTooltip(pCity)
	--print("PazDebug InfoTooltipInclude GetCultureTooltip")
	local strCultureToolTip = "";
	
	if (not OptionsManager.IsNoBasicHelp()) then
		strCultureToolTip = strCultureToolTip .. ConvertTextKey("TXT_KEY_CULTURE_HELP_INFO");
		strCultureToolTip = strCultureToolTip .. "[NEWLINE][NEWLINE]";
	end
	
	local bFirst = true;
	
	-- Culture from Buildings
	local iCultureFromBuildings = pCity:GetJONSCulturePerTurnFromBuildings();
	if (iCultureFromBuildings ~= 0) then
		
		-- Spacing
		if (bFirst) then
			bFirst = false;
		else
			strCultureToolTip = strCultureToolTip .. "[NEWLINE]";
		end
		
		strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_CULTURE_FROM_BUILDINGS", iCultureFromBuildings);
	end
	
	-- Culture from Policies
	local iCultureFromPolicies = pCity:GetJONSCulturePerTurnFromPolicies();
	if (iCultureFromPolicies ~= 0) then
		
		-- Spacing
		if (bFirst) then
			bFirst = false;
		else
			strCultureToolTip = strCultureToolTip .. "[NEWLINE]";
		end
		
		strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_CULTURE_FROM_POLICIES", iCultureFromPolicies);
	end
	
	-- Culture from Specialists
	local iCultureFromSpecialists = pCity:GetJONSCulturePerTurnFromSpecialists();
	--Paz add
	iCultureFromSpecialists = iCultureFromSpecialists - pCity:GetBaseYieldRateFromMisc(YieldTypes.YIELD_CULTURE)
	--end Paz add
	if (iCultureFromSpecialists ~= 0) then
		
		-- Spacing
		if (bFirst) then
			bFirst = false;
		else
			strCultureToolTip = strCultureToolTip .. "[NEWLINE]";
		end
		
		strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_CULTURE_FROM_SPECIALISTS", iCultureFromSpecialists);
	end
	
	-- Culture from Religion
	local iCultureFromReligion = pCity:GetJONSCulturePerTurnFromReligion();
	if ( iCultureFromReligion ~= 0) then
		
		-- Spacing
		if (bFirst) then
			bFirst = false;
		else
			strCultureToolTip = strCultureToolTip .. "[NEWLINE]";
		end
		
		strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_CULTURE_FROM_RELIGION", iCultureFromReligion);
	end
	
	--Paz add: Culture from GPs
	local iCultureFromGPs = pCity:GetBaseYieldRateFromMisc(YieldTypes.YIELD_CULTURE)
	if (iCultureFromGPs ~= 0) then
		
		-- Spacing
		if (bFirst) then
			bFirst = false;
		else
			strCultureToolTip = strCultureToolTip .. "[NEWLINE]";
		end
		
		strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_EA_FAITH_FROM_GPS", iCultureFromGPs);
	end
	--end Paz add

	-- Culture from Terrain
	local iCultureFromTerrain = pCity:GetBaseYieldRateFromTerrain(YieldTypes.YIELD_CULTURE);
	if (iCultureFromTerrain ~= 0) then
		
		-- Spacing
		if (bFirst) then
			bFirst = false;
		else
			strCultureToolTip = strCultureToolTip .. "[NEWLINE]";
		end
		
		strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_CULTURE_FROM_TERRAIN", iCultureFromTerrain);
	end

	-- Culture from Traits
	local iCultureFromTraits = pCity:GetJONSCulturePerTurnFromTraits();
	if (iCultureFromTraits ~= 0) then
		
		-- Spacing
		if (bFirst) then
			bFirst = false;
		else
			strCultureToolTip = strCultureToolTip .. "[NEWLINE]";
		end
		
		strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_CULTURE_FROM_TRAITS", iCultureFromTraits);
	end
	
	-- Empire Culture modifier
	local iAmount = Players[pCity:GetOwner()]:GetCultureCityModifier();
	if (iAmount ~= 0) then
		strCultureToolTip = strCultureToolTip .. "[NEWLINE][NEWLINE]";
		strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_CULTURE_PLAYER_MOD", iAmount);
	end
	
	-- City Culture modifier
	local iAmount = pCity:GetCultureRateModifier();
	if (iAmount ~= 0) then
		strCultureToolTip = strCultureToolTip .. "[NEWLINE][NEWLINE]";
		strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_CULTURE_CITY_MOD", iAmount);
	end
	
	-- Culture Wonders modifier
	if (pCity:GetNumWorldWonders() > 0) then
		iAmount = Players[pCity:GetOwner()]:GetCultureWonderMultiplier();
		
		if (iAmount ~= 0) then
			strCultureToolTip = strCultureToolTip .. "[NEWLINE][NEWLINE]";
			strCultureToolTip = strCultureToolTip .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_CULTURE_WONDER_BONUS", iAmount);
		end
	end

	--Paz add
	-- Leader
	local iLeaderMod = Players[pCity:GetOwner()]:GetLeaderYieldBoost(YieldTypes.YIELD_CULTURE)
	if iLeaderMod ~= 0 then
		strCultureToolTip = strCultureToolTip .. "[NEWLINE]";
		strCultureToolTip = strCultureToolTip .. ConvertTextKey("TXT_KEY_EA_PRODMOD_YIELD_LEADER", iLeaderMod);
	end
	--end Paz add
	
	-- Puppet modifier
	if (pCity:IsPuppet()) then
		iAmount = GameDefines.PUPPET_CULTURE_MODIFIER;
		
		if (iAmount ~= 0) then
			strCultureToolTip = strCultureToolTip .. "[NEWLINE]";
			strCultureToolTip = strCultureToolTip .. ConvertTextKey("TXT_KEY_PRODMOD_PUPPET", iAmount);
		end
	end
	
	-- Tile growth
	local iCulturePerTurn = pCity:GetJONSCulturePerTurn();
	local iCultureStored = pCity:GetJONSCultureStored();
	local iCultureNeeded = pCity:GetJONSCultureThreshold();

	strCultureToolTip = strCultureToolTip .. "[NEWLINE][NEWLINE]";
	strCultureToolTip = strCultureToolTip .. ConvertTextKey("TXT_KEY_CULTURE_INFO", iCultureStored, iCultureNeeded);
	
	if iCulturePerTurn > 0 then
		local iCultureDiff = iCultureNeeded - iCultureStored;
		local iCultureTurns = math.ceil(iCultureDiff / iCulturePerTurn);
		strCultureToolTip = strCultureToolTip .. " " .. ConvertTextKey("TXT_KEY_CULTURE_TURNS", iCultureTurns);
	end
	
	return strCultureToolTip;
end

-- FAITH
function GetFaithTooltip(pCity)
	--print("PazDebug InfoTooltipInclude GetFaithTooltip")
	local faithTips = {};
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
		insert(faithTips, ConvertTextKey("TXT_KEY_TOP_PANEL_RELIGION_OFF_TOOLTIP"));
	else

		if (not OptionsManager.IsNoBasicHelp()) then
			insert(faithTips, ConvertTextKey("TXT_KEY_EA_FAVOR_HELP_INFO"));		--Paz changed from TXT_KEY_FAITH_HELP_INFO
		end
	
		-- Faith from Buildings
		local iFaithFromBuildings = pCity:GetFaithPerTurnFromBuildings();
		if (iFaithFromBuildings ~= 0) then
		
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_FAITH_FROM_BUILDINGS", iFaithFromBuildings));
		end
	
		-- Faith from Traits
		local iFaithFromTraits = pCity:GetFaithPerTurnFromTraits();
		if (iFaithFromTraits ~= 0) then
				
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_FAITH_FROM_TRAITS", iFaithFromTraits));
		end
	
		-- Faith from Terrain
		local iFaithFromTerrain = pCity:GetBaseYieldRateFromTerrain(YieldTypes.YIELD_FAITH);
		if (iFaithFromTerrain ~= 0) then
				
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_FAITH_FROM_TERRAIN", iFaithFromTerrain));
		end

		-- Faith from Policies
		local iFaithFromPolicies = pCity:GetFaithPerTurnFromPolicies();
		if (iFaithFromPolicies ~= 0) then
					
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_FAITH_FROM_POLICIES", iFaithFromPolicies));
		end

		-- Faith from Religion
		local iFaithFromReligion = pCity:GetFaithPerTurnFromReligion();
		if (iFaithFromReligion ~= 0) then
				
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_FAITH_FROM_RELIGION", iFaithFromReligion));
		end

		--Paz add

		-- Faith from Specialists
		local iFaithFromSpecialists = pCity:GetFaithPerTurnFromSpecialists()
		if (iFaithFromSpecialists ~= 0) then
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_EA_FAITH_FROM_SPECIALISTS", iFaithFromSpecialists));
		end

		--Faith from GPs 
		local iFaithFromGPs = pCity:GetBaseYieldRateFromMisc(YieldTypes.YIELD_FAITH)
		if (iFaithFromGPs ~= 0) then
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_EA_FAITH_FROM_GPS", iFaithFromGPs));
		end

		-- Leader
		local iLeaderMod = Players[pCity:GetOwner()]:GetLeaderYieldBoost(YieldTypes.YIELD_FAITH)
		if iLeaderMod ~= 0 then
			insert(faithTips, ConvertTextKey("TXT_KEY_EA_PRODMOD_YIELD_LEADER", iLeaderMod));
		end
		--end Paz add

		-- Puppet modifier
		if (pCity:IsPuppet()) then
			iAmount = GameDefines.PUPPET_FAITH_MODIFIER;
		
			if (iAmount ~= 0) then
				insert(faithTips, ConvertTextKey("TXT_KEY_PRODMOD_PUPPET", iAmount));
			end
		end
	
		-- Citizens breakdown
		insert(faithTips, "----------------");

		--Paz disabled: insert(faithTips, GetReligionTooltip(pCity));
	end
	
	local strFaithToolTip = table.concat(faithTips, "[NEWLINE]");
	return strFaithToolTip;
end

-- Paz add: MANA
function GetManaTooltip(pCity)
	--print("PazDebug InfoTooltipInclude GetManaTooltip")
	local faithTips = {};
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
		insert(faithTips, ConvertTextKey("TXT_KEY_TOP_PANEL_RELIGION_OFF_TOOLTIP"));
	else

		if (not OptionsManager.IsNoBasicHelp()) then
			insert(faithTips, ConvertTextKey("TXT_KEY_EA_MANA_HELP_INFO"));
		end
	
		-- Faith from Buildings
		local iFaithFromBuildings = pCity:GetFaithPerTurnFromBuildings();
		if (iFaithFromBuildings ~= 0) then
		
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_FAITH_FROM_BUILDINGS", iFaithFromBuildings));
		end
	
		-- Faith from Traits
		local iFaithFromTraits = pCity:GetFaithPerTurnFromTraits();
		if (iFaithFromTraits ~= 0) then
				
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_FAITH_FROM_TRAITS", iFaithFromTraits));
		end
	
		-- Faith from Terrain
		local iFaithFromTerrain = pCity:GetBaseYieldRateFromTerrain(YieldTypes.YIELD_FAITH);
		if (iFaithFromTerrain ~= 0) then
				
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_FAITH_FROM_TERRAIN", iFaithFromTerrain));
		end

		-- Faith from Policies
		local iFaithFromPolicies = pCity:GetFaithPerTurnFromPolicies();
		if (iFaithFromPolicies ~= 0) then
					
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_FAITH_FROM_POLICIES", iFaithFromPolicies));
		end

		-- Faith from Religion
		local iFaithFromReligion = pCity:GetFaithPerTurnFromReligion();
		if (iFaithFromReligion ~= 0) then
				
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_FAITH_FROM_RELIGION", iFaithFromReligion));
		end

		-- Faith from Specialists
		local iFaithFromSpecialists = pCity:GetFaithPerTurnFromSpecialists()
		if (iFaithFromSpecialists ~= 0) then
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_EA_FAITH_FROM_SPECIALISTS", iFaithFromSpecialists));
		end
	
		-- Faith from GPs ()
		local iFaithFromGPs = pCity:GetBaseYieldRateFromMisc(YieldTypes.YIELD_FAITH)
		if (iFaithFromGPs ~= 0) then
				
			insert(faithTips, "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_EA_FAITH_FROM_GPS", iFaithFromGPs));
		end

		-- Leader
		local iLeaderMod = Players[pCity:GetOwner()]:GetLeaderYieldBoost(YieldTypes.YIELD_FAITH)
		if iLeaderMod ~= 0 then
			insert(faithTips, ConvertTextKey("TXT_KEY_EA_PRODMOD_YIELD_LEADER", iLeaderMod));
		end

		-- Puppet modifier
		if (pCity:IsPuppet()) then
			iAmount = GameDefines.PUPPET_FAITH_MODIFIER;
		
			if (iAmount ~= 0) then
				insert(faithTips, ConvertTextKey("TXT_KEY_PRODMOD_PUPPET", iAmount));
			end
		end
	
		-- Citizens breakdown
		insert(faithTips, "----------------");

		
	end
	
	local strFaithToolTip = table.concat(faithTips, "[NEWLINE]");

	strFaithToolTip = string.gsub(strFaithToolTip, "%[ICON_PEACE%]", "%[ICON_STAR%]")		--messy, but works

	return strFaithToolTip;
end

--end Paz add

-- Yield Tooltip Helper
function GetYieldTooltipHelper(pCity, iYieldType, strIcon)
	
	local strModifiers = "";
	
	-- Base Yield
	local iBaseYield = pCity:GetBaseYieldRate(iYieldType);

	local iYieldPerPop = pCity:GetYieldPerPopTimes100(iYieldType);
	if (iYieldPerPop ~= 0) then
		iYieldPerPop = iYieldPerPop * pCity:GetPopulation();
		iYieldPerPop = iYieldPerPop / 100;
		
		iBaseYield = iBaseYield + iYieldPerPop;
	end

	-- Total Yield
	local iTotalYield;
	
	-- Food is special
	if (iYieldType == YieldTypes.YIELD_FOOD) then
		iTotalYield = pCity:FoodDifferenceTimes100() / 100;
	else
		iTotalYield = pCity:GetYieldRateTimes100(iYieldType) / 100;
	end
	
	-- Yield modifiers string
	strModifiers = strModifiers .. pCity:GetYieldModifierTooltip(iYieldType);
	
	-- Build tooltip
	local strYieldToolTip = GetYieldTooltip(pCity, iYieldType, iBaseYield, iTotalYield, strIcon, strModifiers);
	
	return strYieldToolTip;

end


------------------------------
-- Helper function to build yield tooltip string
function GetYieldTooltip(pCity, iYieldType, iBase, iTotal, strIconString, strModifiersString)
	
	local strYieldBreakdown = "";
	
	-- Base Yield from terrain
	local iYieldFromTerrain = pCity:GetBaseYieldRateFromTerrain(iYieldType);
	if (iYieldFromTerrain ~= 0) then
		strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_YIELD_FROM_TERRAIN", iYieldFromTerrain, strIconString);
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]";
	end
	
	-- Base Yield from Buildings
	local iYieldFromBuildings = pCity:GetBaseYieldRateFromBuildings(iYieldType);
	if (iYieldFromBuildings ~= 0) then
		strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_YIELD_FROM_BUILDINGS", iYieldFromBuildings, strIconString);
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]";
	end
	
	-- Base Yield from Specialists
	local iYieldFromSpecialists = pCity:GetBaseYieldRateFromSpecialists(iYieldType);
	if (iYieldFromSpecialists ~= 0) then
		strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_YIELD_FROM_SPECIALISTS", iYieldFromSpecialists, strIconString);
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]";
	end
	
	-- Base Yield from Misc
	local iYieldFromMisc = pCity:GetBaseYieldRateFromMisc(iYieldType);
	if (iYieldFromMisc ~= 0) then
		if (iYieldType == YieldTypes.YIELD_SCIENCE) then
			strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_YIELD_FROM_POP", iYieldFromMisc, strIconString);
		else
			strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_YIELD_FROM_MISC", iYieldFromMisc, strIconString);
		end
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]";
	end
	
	-- Base Yield from Pop
	local iYieldPerPop = pCity:GetYieldPerPopTimes100(iYieldType);
	if (iYieldPerPop ~= 0) then
		local iYieldFromPop = iYieldPerPop * pCity:GetPopulation();
		iYieldFromPop = iYieldFromPop / 100;
		
		strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_YIELD_FROM_POP_EXTRA", iYieldFromPop, strIconString);
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]";
	end
	
	-- Base Yield from Religion
	local iYieldFromReligion = pCity:GetBaseYieldRateFromReligion(iYieldType);
	if (iYieldFromReligion ~= 0) then
		strYieldBreakdown = strYieldBreakdown .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_YIELD_FROM_RELIGION", iYieldFromReligion, strIconString);
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]";
	end
	
	local strExtraBaseString = "";
	
	-- Food eaten by pop
	local iYieldEaten = 0;
	if (iYieldType == YieldTypes.YIELD_FOOD) then
		iYieldEaten = pCity:FoodConsumption(true, 0);
		if (iYieldEaten ~= 0) then
			--strModifiers = strModifiers .. "[NEWLINE]";
			--strModifiers = strModifiers .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_YIELD_EATEN_BY_POP", iYieldEaten, "[ICON_FOOD]");
			--strModifiers = strModifiers .. "[NEWLINE]----------------[NEWLINE]";
			
			strExtraBaseString = strExtraBaseString .. "   " .. ConvertTextKey("TXT_KEY_FOOD_USAGE", iBase, iYieldEaten);
			
			local iFoodSurplus = pCity:GetYieldRate(YieldTypes.YIELD_FOOD) - iYieldEaten;
			iBase = iFoodSurplus;
			
			--if (iFoodSurplus >= 0) then
				--strModifiers = strModifiers .. ConvertTextKey("TXT_KEY_YIELD_AFTER_EATEN", iFoodSurplus, "[ICON_FOOD]");
			--else
				--strModifiers = strModifiers .. ConvertTextKey("TXT_KEY_YIELD_AFTER_EATEN_NEGATIVE", iFoodSurplus, "[ICON_FOOD]");
			--end
		end
	end
	
	local strTotal;
	if (iTotal >= 0) then
		strTotal = ConvertTextKey("TXT_KEY_YIELD_TOTAL", iTotal, strIconString);
	else
		strTotal = ConvertTextKey("TXT_KEY_YIELD_TOTAL_NEGATIVE", iTotal, strIconString);
	end
	
	strYieldBreakdown = strYieldBreakdown .. "----------------";
	
	-- Build combined string
	if (iBase ~= iTotal or strExtraBaseString ~= "") then
		local strBase = ConvertTextKey("TXT_KEY_YIELD_BASE", iBase, strIconString) .. strExtraBaseString;
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]" .. strBase;
	end
	
	-- Modifiers
	if (strModifiersString ~= "") then
		strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]----------------" .. strModifiersString .. "[NEWLINE]----------------";
	end
	strYieldBreakdown = strYieldBreakdown .. "[NEWLINE]" .. strTotal;
	
	return strYieldBreakdown;

end


----------------------------------------------------------------        
-- MOOD INFO
----------------------------------------------------------------        
function GetMoodInfo(iOtherPlayer)
	
	local strInfo = "";
	
	-- Always war!
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_ALWAYS_WAR)) then
		return "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_ALWAYS_WAR_TT");
	end
	
	local iActivePlayer = Game.GetActivePlayer();
	local pActivePlayer = Players[iActivePlayer];
	local pActiveTeam = Teams[pActivePlayer:GetTeam()];
	local pOtherPlayer = Players[iOtherPlayer];
	local iOtherTeam = pOtherPlayer:GetTeam();
	local pOtherTeam = Teams[iOtherTeam];
	
	--local iVisibleApproach = Players[iActivePlayer]:GetApproachTowardsUsGuess(iOtherPlayer);
	
	-- At war right now
	--[[if (pActiveTeam:IsAtWar(iOtherTeam)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_AT_WAR") .. "[NEWLINE]";
		
	-- Not at war right now
	else
		
		-- We've fought before
		if (pActivePlayer:GetNumWarsFought(iOtherPlayer) > 0) then
			-- They don't appear to be mad
			if (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY or 
				iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL) then
				strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_PAST_WAR_NEUTRAL") .. "[NEWLINE]";
			-- They aren't happy with us
			else
				strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_PAST_WAR_BAD") .. "[NEWLINE]";
			end
		end
	end]]--
		
	-- Neutral things
	--[[if (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_AFRAID") .. "[NEWLINE]";
	end]]--
		
	-- Good things
	--[[if (pOtherPlayer:WasResurrectedBy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_RESURRECTED") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:IsDoF(iOtherPlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_DOF") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:IsPlayerDoFwithAnyFriend(iOtherPlayer)) then		-- Human has a mutual friend with the AI
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_MUTUAL_DOF") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:IsPlayerDenouncedEnemy(iOtherPlayer)) then		-- Human has denounced an enemy of the AI
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_MUTUAL_ENEMY") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNumCiviliansReturnedToMe(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_CIVILIANS_RETURNED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherTeam:HasEmbassyAtTeam(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_HAS_EMBASSY") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNumTimesIntrigueSharedBy(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_SHARED_INTRIGUE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerForgivenForSpying(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_FORGAVE_FOR_SPYING") .. "[NEWLINE]";
	end]]--
	
	-- Bad things
	--[[if (pOtherPlayer:IsFriendDeclaredWarOnUs(iActivePlayer)) then		-- Human was a friend and declared war on us
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_HUMAN_FRIEND_DECLARED_WAR") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsFriendDenouncedUs(iActivePlayer)) then			-- Human was a friend and denounced us
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_HUMAN_FRIEND_DENOUNCED") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:GetWeDeclaredWarOnFriendCount() > 0) then		-- Human declared war on friends
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DECLARED_WAR_ON_FRIENDS") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:GetWeDenouncedFriendCount() > 0) then			-- Human has denounced his friends
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DENOUNCED_FRIENDS") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:GetNumFriendsDenouncedBy() > 0) then			-- Human has been denounced by friends
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DENOUNCED_BY_FRIENDS") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:IsDenouncedPlayer(iOtherPlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_DENOUNCED_BY_US") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsDenouncedPlayer(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_DENOUNCED_BY_THEM") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerDoFwithAnyEnemy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DOF_WITH_ENEMY") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerDenouncedFriend(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_HUMAN_DENOUNCED_FRIEND") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerNoSettleRequestEverAsked(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_NO_SETTLE_ASKED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerStopSpyingRequestEverAsked(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_STOP_SPYING_ASKED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsDemandEverMade(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_TRADE_DEMAND") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNumTimesRobbedBy(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_CAUGHT_STEALING") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNumTimesCultureBombed(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_CULTURE_BOMB") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNegativeReligiousConversionPoints(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_RELIGIOUS_CONVERSIONS") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:HasOthersReligionInMostCities(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_ADOPTING_MY_RELIGION") .. "[NEWLINE]";
	end]]--
	--[[if (pActivePlayer:HasOthersReligionInMostCities(iOtherPlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_ADOPTING_HIS_RELIGION") .. "[NEWLINE]";
	end]]--
	--[[local myLateGamePolicies = pActivePlayer:GetLateGamePolicyTree();
	local otherLateGamePolicies = pOtherPlayer:GetLateGamePolicyTree();
	if (myLateGamePolicies ~= PolicyBranchTypes.NO_POLICY_BRANCH_TYPE and otherLateGamePolicies ~= PolicyBranchTypes.NO_POLICY_BRANCH_TYPE) then
	    local myPoliciesStr = ConvertTextKey(GameInfo.PolicyBranchTypes[myLateGamePolicies].Description);
	    print (myPoliciesStr);
		if (myLateGamePolicies == otherLateGamePolicies) then
			strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_SAME_LATE_POLICY_TREES", myPoliciesStr) .. "[NEWLINE]";
		else
			local otherPoliciesStr = ConvertTextKey(GameInfo.PolicyBranchTypes[otherLateGamePolicies].Description);
			strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_DIFFERENT_LATE_POLICY_TREES", myPoliciesStr, otherPoliciesStr) .. "[NEWLINE]";
		end
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenMilitaryPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_MILITARY_PROMISE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredMilitaryPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_MILITARY_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenExpansionPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_EXPANSION_PROMISE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredExpansionPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_EXPANSION_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenBorderPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_BORDER_PROMISE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredBorderPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_BORDER_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenAttackCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_CITY_STATE_PROMISE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredAttackCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_CITY_STATE_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenBullyCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_BULLY_CITY_STATE_PROMISE_BROKEN") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredBullyCityStatePromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_BULLY_CITY_STATE_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenSpyPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_SPY_PROMISE_BROKEN") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredSpyPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_SPY_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenNoConvertPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_NO_CONVERT_PROMISE_BROKEN") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerIgnoredNoConvertPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_NO_CONVERT_PROMISE_IGNORED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerBrokenCoopWarPromise(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_COOP_WAR_PROMISE") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsPlayerRecklessExpander(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_RECKLESS_EXPANDER") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetNumRequestsRefused(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_REFUSED_REQUESTS") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:GetRecentTradeValue(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_TRADE_PARTNER") .. "[NEWLINE]";	
	end]]--
	--[[if (pOtherPlayer:GetCommonFoeValue(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_COMMON_FOE") .. "[NEWLINE]";	
	end]]--
	--[[if (pOtherPlayer:GetRecentAssistValue(iActivePlayer) > 0) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_ASSISTANCE_TO_THEM") .. "[NEWLINE]";	
	end	]]--
	--[[if (pOtherPlayer:IsLiberatedCapital(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_LIBERATED_CAPITAL") .. "[NEWLINE]";	
	end]]--
	--[[if (pOtherPlayer:IsLiberatedCity(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_LIBERATED_CITY") .. "[NEWLINE]";	
	end	]]--
	--[[if (pOtherPlayer:IsGaveAssistanceTo(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_ASSISTANCE_FROM_THEM") .. "[NEWLINE]";	
	end	]]--	
	--[[if (pOtherPlayer:IsHasPaidTributeTo(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_PAID_TRIBUTE") .. "[NEWLINE]";	
	end	]]--
	--[[if (pOtherPlayer:IsNukedBy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_NUKED") .. "[NEWLINE]";	
	end]]--	
	--[[if (pOtherPlayer:IsCapitalCapturedBy(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_CAPTURED_CAPITAL") .. "[NEWLINE]";	
	end	]]--

	-- Protected Minors
	--[[if (pOtherPlayer:IsAngryAboutProtectedMinorKilled(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_PROTECTED_MINORS_KILLED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsAngryAboutProtectedMinorAttacked(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_PROTECTED_MINORS_ATTACKED") .. "[NEWLINE]";
	end]]--
	--[[if (pOtherPlayer:IsAngryAboutProtectedMinorBullied(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_PROTECTED_MINORS_BULLIED") .. "[NEWLINE]";
	end]]--
	
	-- Bullied Minors
	--[[if (pOtherPlayer:IsAngryAboutSidedWithTheirProtectedMinor(iActivePlayer)) then
		strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_SIDED_WITH_MINOR") .. "[NEWLINE]";
	end]]--
	
	--local iActualApproach = pOtherPlayer:GetMajorCivApproach(iActivePlayer)
	
	-- MOVED TO LUAPLAYER
	--[[
	-- Bad things we don't want visible if someone is friendly (acting or truthfully)
	if (iVisibleApproach ~= MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY) then-- and
		--iActualApproach ~= MajorCivApproachTypes.MAJOR_CIV_APPROACH_DECEPTIVE) then
		if (pOtherPlayer:GetLandDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_LAND_DISPUTE") .. "[NEWLINE]";
		end
		--if (pOtherPlayer:GetVictoryDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			--strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_VICTORY_DISPUTE") .. "[NEWLINE]";
		--end
		if (pOtherPlayer:GetWonderDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_WONDER_DISPUTE") .. "[NEWLINE]";
		end
		if (pOtherPlayer:GetMinorCivDisputeLevel(iActivePlayer) > DisputeLevelTypes.DISPUTE_LEVEL_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_MINOR_CIV_DISPUTE") .. "[NEWLINE]";
		end
		if (pOtherPlayer:GetWarmongerThreat(iActivePlayer) > ThreatTypes.THREAT_NONE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_WARMONGER_THREAT") .. "[NEWLINE]";
		end
	end
	]]--
	
	local aOpinion = pOtherPlayer:GetOpinionTable(iActivePlayer);
	--local aOpinionList = {};
	for i,v in ipairs(aOpinion) do
		--aOpinionList[i] = "[ICON_BULLET]" .. v .. "[NEWLINE]";
		strInfo = strInfo .. "[ICON_BULLET]" .. v .. "[NEWLINE]";
	end
	--strInfo = table.cat(aOpinionList, "[NEWLINE]");

	--  No specific events - let's see what string we should use
	if (strInfo == "") then
		
		-- Appears Friendly
		if (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY) then
			strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_FRIENDLY");
		-- Appears Guarded
		elseif (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED) then
			strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_GUARDED");
		-- Appears Hostile
		elseif (iVisibleApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE) then
			strInfo = strInfo .. "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_HOSTILE");
		-- Neutral - default string
		else
			strInfo = "[ICON_BULLET]" .. ConvertTextKey("TXT_KEY_DIPLO_DEFAULT_STATUS");
		end
	end
	
	-- Remove extra newline off the end if we have one
	if (Locale.EndsWith(strInfo, "[NEWLINE]")) then
		local iNewLength = Locale.Length(strInfo)-9;
		strInfo = Locale.Substring(strInfo, 1, iNewLength);
	end
	
	return strInfo;
	
end
------------------------------
-- Helper function to build religion tooltip string
function GetReligionTooltip(city)

	local religionToolTip = "";
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
		return religionToolTip;
	end

	local bFoundAFollower = false;
	local eReligion = city:GetReligiousMajority();
	local bFirst = true;
	
	if (eReligion >= 0) then
		bFoundAFollower = true;
		local religion = GameInfo.Religions[eReligion];
		local strReligion = ConvertTextKey(Game.GetReligionName(eReligion));
	    local strIcon = religion.IconString;
		local strPressure = "";
			
		if (city:IsHolyCityForReligion(eReligion)) then
			if (not bFirst) then
				religionToolTip = religionToolTip .. "[NEWLINE]";
			else
				bFirst = false;
			end
			religionToolTip = religionToolTip .. ConvertTextKey("TXT_KEY_HOLY_CITY_TOOLTIP_LINE", strIcon, strReligion);			
		end

		local iPressure = city:GetPressurePerTurn(eReligion);
		if (iPressure > 0) then
			strPressure = ConvertTextKey("TXT_KEY_RELIGIOUS_PRESSURE_STRING", iPressure);
		end
			
		local iFollowers = city:GetNumFollowers(eReligion)			
		if (not bFirst) then
			religionToolTip = religionToolTip .. "[NEWLINE]";
		else
			bFirst = false;
		end
		religionToolTip = religionToolTip .. ConvertTextKey("TXT_KEY_RELIGION_TOOLTIP_LINE", strIcon, iFollowers, strPressure);
	end	
		
	local iReligionID;
	for pReligion in GameInfo.Religions() do
		iReligionID = pReligion.ID;
		
		if (iReligionID >= 0 and iReligionID ~= eReligion and city:GetNumFollowers(iReligionID) > 0) then
			bFoundAFollower = true;
			local religion = GameInfo.Religions[iReligionID];
			local strReligion = ConvertTextKey(Game.GetReligionName(iReligionID));
			local strIcon = religion.IconString;
			local strPressure = "";

			if (city:IsHolyCityForReligion(iReligionID)) then
				if (not bFirst) then
					religionToolTip = religionToolTip .. "[NEWLINE]";
				else
					bFirst = false;
				end
				religionToolTip = religionToolTip .. ConvertTextKey("TXT_KEY_HOLY_CITY_TOOLTIP_LINE", strIcon, strReligion);			
			end
				
			local iPressure = city:GetPressurePerTurn(iReligionID);
			if (iPressure > 0) then
				strPressure = ConvertTextKey("TXT_KEY_RELIGIOUS_PRESSURE_STRING", iPressure);
			end
			
			local iFollowers = city:GetNumFollowers(iReligionID)			
			if (not bFirst) then
				religionToolTip = religionToolTip .. "[NEWLINE]";
			else
				bFirst = false;
			end
			religionToolTip = religionToolTip .. ConvertTextKey("TXT_KEY_RELIGION_TOOLTIP_LINE", strIcon, iFollowers, strPressure);
		end
	end
	
	if (not bFoundAFollower) then
		religionToolTip = religionToolTip .. ConvertTextKey("TXT_KEY_RELIGION_NO_FOLLOWERS");
	end
		
	return religionToolTip;
end