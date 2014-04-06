-- EaCivTooltipHelper
-- Author: Pazyryk
-- DateCreated: 1/3/2014 4:03:30 PM
--------------------------------------------------------------

local g_triggerText = ""

function GetEaCivTriggerText(eaCivID)
	local eaCivInfo = GameInfo.EaCivs[eaCivID]

	local triggerText
	if eaCivInfo.KnownTech then
		triggerText = "Discover " .. Locale.Lookup(GameInfo.Technologies[eaCivInfo.KnownTech].Description)
		if eaCivInfo.AndKnownTech then
			triggerText = triggerText .. " and " .. Locale.Lookup(GameInfo.Technologies[eaCivInfo.AndKnownTech].Description)
		end
	end
	if eaCivInfo.AdoptedPolicy then
		triggerText = triggerText and triggerText .. "; adopt " or "Adopt "
		triggerText = triggerText .. Locale.Lookup(GameInfo.Policies[eaCivInfo.AdoptedPolicy].Description)
		if eaCivInfo.OrAdoptedPolicy1 then
			if eaCivInfo.OrAdoptedPolicy2 then
				triggerText = triggerText .. ", " .. Locale.Lookup(GameInfo.Policies[eaCivInfo.OrAdoptedPolicy1].Description) .. " or " .. Locale.Lookup(GameInfo.Policies[eaCivInfo.OrAdoptedPolicy2].Description)
			else
				triggerText = triggerText .. " or " .. Locale.Lookup(GameInfo.Policies[eaCivInfo.OrAdoptedPolicy1].Description)
			end
		end
		if eaCivInfo.AndAdoptedPolicy then
			triggerText = triggerText .. " and " .. Locale.Lookup(GameInfo.Policies[eaCivInfo.AndAdoptedPolicy].Description)
		end
	end
	if eaCivInfo.BuildingType then
		triggerText = triggerText and triggerText .. "; construct " or "Construct "
		triggerText = triggerText .. Locale.Lookup(GameInfo.Buildings[eaCivInfo.BuildingType].Description)
	end
	if eaCivInfo.UnitClass then
		triggerText = triggerText and triggerText .. "; train " or "Train "
		triggerText = triggerText .. Locale.Lookup(GameInfo.UnitClasses[eaCivInfo.UnitClass].Description)
	end
	if eaCivInfo.CapitalNearbyResourceType then
		triggerText = triggerText and triggerText .. ";  " or ""
		triggerText = triggerText .. eaCivInfo.CapitalNearbyResourceNumber .. " nearby " .. Locale.Lookup(GameInfo.Resources[eaCivInfo.CapitalNearbyResourceType].Description)
	end
	if eaCivInfo.ImprovedResType then
		triggerText = triggerText and triggerText .. ";  " or ""
		triggerText = triggerText .. eaCivInfo.ImprovedResNumber .. " nearby improved " .. Locale.Lookup(GameInfo.Resources[eaCivInfo.ImprovedResType].Description)
		if eaCivInfo.OrImprovedResType then
			triggerText = triggerText .. " or " .. Locale.Lookup(GameInfo.Resources[eaCivInfo.OrImprovedResType].Description)
		end
	end
	if eaCivInfo.ImprovementType then
		triggerText = triggerText and triggerText .. ";  " or ""
		triggerText = triggerText .. eaCivInfo.ImprovementNumber .. " nearby " .. Locale.Lookup(GameInfo.Improvements[eaCivInfo.ImprovementType].Description)
		if eaCivInfo.OrImprovementType then
			triggerText = triggerText .. " or " .. Locale.Lookup(GameInfo.Improvements[eaCivInfo.OrImprovementType].Description)
		end
	end
	if eaCivInfo.SpecialTriggerText then
		triggerText = triggerText and triggerText .. ";  " or ""
		triggerText = triggerText .. Locale.Lookup(eaCivInfo.SpecialTriggerText)
	end
	triggerText = triggerText or "Oops!"
	g_triggerText = triggerText
	return triggerText
end


function GetEaCivDiscriptionText(eaCivID, bIncludeCivName, bIncludeQuote, bUseCachedTrigger)		-- supply triggerText if already known
	local triggerText = bUseCachedTrigger and g_triggerText or GetEaCivTriggerText(eaCivID)
	local eaCivInfo = GameInfo.EaCivs[eaCivID]
	local eaCivType = eaCivInfo.Type
	local sqlSearch = "EaCivType = '" .. eaCivType .. "'"
	local civName = Locale.Lookup(eaCivInfo.Description)
	local civQuote = bIncludeQuote and eaCivInfo.Quote and Locale.Lookup(eaCivInfo.Quote)
	local civHelp = Locale.Lookup(eaCivInfo.Help)

	local foundingGP
	if eaCivInfo.FoundingGPClass or eaCivInfo.FoundingGPSubclass then
		local classText = eaCivInfo.FoundingGPSubclass or eaCivInfo.FoundingGPClass
		if eaCivInfo.FoundingGPType then
			foundingGP = Locale.Lookup(GameInfo.EaPeople[eaCivInfo.FoundingGPType].Description) .. " (" .. classText .. ")"
		else
			foundingGP = classText
		end
	end

	local favoredTechs
	for row in GameInfo.EaCiv_FavoredTechs(sqlSearch) do
		favoredTechs = favoredTechs and favoredTechs .. ", " or ""
		favoredTechs = favoredTechs .. Locale.Lookup(GameInfo.Technologies[row.TechType].Description)
	end

	local enabledPolicies
	if not MapModData.bDisableEnabledPolicies then
		for row in GameInfo.EaCiv_EnabledPolicies(sqlSearch) do
			enabledPolicies = enabledPolicies and enabledPolicies .. ", " or ""
			enabledPolicies = enabledPolicies .. Locale.Lookup(GameInfo.Policies[row.PolicyType].Description)
		end
	end

	local favoredGPClass = eaCivInfo.FavoredGPClass

	local strToolTip = ""
	if bIncludeCivName then
		strToolTip = strToolTip .. "[COLOR_POSITIVE_TEXT]" .. civName .. "[ENDCOLOR][NEWLINE][NEWLINE]"
	end
	if civQuote then
		strToolTip = strToolTip .. civQuote .. "[NEWLINE][NEWLINE]"
	end
	strToolTip = strToolTip .. "[ICON_BULLET][COLOR_POSITIVE_TEXT]Naming Conditions: [ENDCOLOR]" .. triggerText
	strToolTip = strToolTip .. "[NEWLINE]" .. civHelp
	if foundingGP then
		strToolTip = strToolTip .. "[NEWLINE][ICON_BULLET][COLOR_POSITIVE_TEXT]Founding Great Person: [ENDCOLOR]" .. foundingGP
	end
	if favoredGPClass then
		strToolTip = strToolTip .. "[NEWLINE][ICON_BULLET][COLOR_POSITIVE_TEXT]Favored Class: [ENDCOLOR]" .. favoredGPClass
	end
	if favoredTechs then
		strToolTip = strToolTip .. "[NEWLINE][ICON_BULLET][COLOR_POSITIVE_TEXT]Favored Techs: [ENDCOLOR]" .. favoredTechs
	end
	if enabledPolicies then
		strToolTip = strToolTip .. "[NEWLINE][ICON_BULLET][COLOR_POSITIVE_TEXT]Enabled Policies: [ENDCOLOR]" .. enabledPolicies
	end

	return strToolTip
end