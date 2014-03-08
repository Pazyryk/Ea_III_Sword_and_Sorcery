-------------------------------------------------
-- Religion Overview Popup
-------------------------------------------------
--Paz: This file and xml were recoded from scratch
print("Loading ReligionOverview.lua")

include( "IconSupport" )
include( "InstanceManager" )

MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------

local RELIGION_THE_WEAVE_OF_EA =	GameInfoTypes.RELIGION_THE_WEAVE_OF_EA
local RELIGION_ANRA =				GameInfoTypes.RELIGION_ANRA

local MapModData = MapModData

--------------------------------------------------------------
-- file control vars
--------------------------------------------------------------

local g_PopulationManager = InstanceManager:new( "ByPopulationInstance", "PopulationButton", Controls.YourReligionsByPopulationStack)
local g_CityManager = InstanceManager:new( "ByCityInstance", "CityButton", Controls.YourReligionsByCityStack)
local g_ReligionManager = InstanceManager:new( "ReligionInstance", "ReligionButton", Controls.ReligionStack)



local g_CurrentTab = "YourReligions"

-------------------------------------------------
-------------------------------------------------
function OnPopupMessage(popupInfo)
	
	local popupType = popupInfo.Type;
	if popupType ~= ButtonPopupTypes.BUTTONPOPUP_RELIGION_OVERVIEW then
		return
	end
	
	if(not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
		g_PopupInfo = popupInfo
	
		if( g_PopupInfo.Data1 == 1 ) then
    		if( ContextPtr:IsHidden() == false ) then
    			OnClose()
			else
        		UIManager:QueuePopup( ContextPtr, PopupPriority.InGameUtmost )
    		end
		else
			UIManager:QueuePopup( ContextPtr, PopupPriority.SocialPolicy )
		end   	
   	end
end
Events.SerialEventGameMessagePopup.Add( OnPopupMessage )

function TabSelect(tab)
	print("Running TabSelect ", tab)
	if tab == "YourReligions" then
		Controls.YourReligionsSelectHighlight:SetHide(false)
		Controls.TheisticSelectHighlight:SetHide(true)
		Controls.PantheisticSelectHighlight:SetHide(true)
		RefreshYourReligions()
	elseif tab == "Theistic" then
		Controls.YourReligionsSelectHighlight:SetHide(true)
		Controls.TheisticSelectHighlight:SetHide(false)
		Controls.PantheisticSelectHighlight:SetHide(true)
		RefreshReligions("Theistic")
	elseif tab == "Pantheistic" then
		Controls.YourReligionsSelectHighlight:SetHide(true)
		Controls.TheisticSelectHighlight:SetHide(true)
		Controls.PantheisticSelectHighlight:SetHide(false)
		RefreshReligions("Pantheistic")
	end
	g_CurrentTab = tab
end
Controls.TabButtonYourReligions:RegisterCallback( Mouse.eLClick, function() TabSelect("YourReligions") end)
Controls.TabButtonPantheistic:RegisterCallback( Mouse.eLClick, function() TabSelect("Pantheistic") end)
Controls.TabButtonTheistic:RegisterCallback( Mouse.eLClick, function() TabSelect("Theistic") end )


function RefreshYourReligions()
	print("Running RefreshYourReligions")

	Controls.ReligionsPanel:SetHide(true)

	local iPlayer = Game.GetActivePlayer()
	local player = Players[iPlayer]
	local eaPlayer = gT.gPlayers[iPlayer]
	if not eaPlayer then return end
	local gReligions = gT.gReligions

	local followersByReligion = {}
	local cityReligions = {}
	local cityCount = 0

	for city in player:Cities() do
		local majorityReligion = city:GetReligiousMajority()
		if majorityReligion ~= -1 then
			cityCount = cityCount + 1
			cityReligions[cityCount] = {iCity = city:GetID(), religion = majorityReligion, followers = city:GetNumFollowers(majorityReligion), population = city:GetPopulation()}
		end
		for religionID = 1, MapModData.HIGHEST_RELIGION_ID do
			if gReligions[religionID] then		--this is the founded test
				local followers = city:GetNumFollowers(religionID)
				if followers > 0 then
					followersByReligion[religionID] = (followersByReligion[religionID] or 0) + followers
				end
			end
		end
	end

	local religions = {}
	local religionsCount = 0
	for religionID = 1, MapModData.HIGHEST_RELIGION_ID do
		if followersByReligion[religionID] then
			religionsCount = religionsCount + 1
			religions[religionsCount] = religionID
		end
	end

	if religionsCount == 0 then
		print("No religious followers")
		Controls.YourReligionsPanel:SetHide(true)
		Controls.NoReligiousFollowers:SetHide(false)
	else
		print("Displaying your religions")
		Controls.YourReligionsPanel:SetHide(false)
		Controls.NoReligiousFollowers:SetHide(true)

		--Dominant Religion
		if eaPlayer.religionID == -1 then
			Controls.DominantReligionIcon:SetHide(true)
			Controls.DominantReligionText:SetOffsetX(25)
			Controls.DominantReligionText:LocalizeAndSetText("TXT_KEY_EA_NO_DOMINANT_RELIGION")
		else
			local religionInfo = GameInfo.Religions[eaPlayer.religionID]
			IconHookup(religionInfo.PortraitIndex, 80, religionInfo.IconAtlas, Controls.DominantReligionIcon)
			Controls.DominantReligionIcon:SetHide(false)
			local religionStr = Locale.Lookup(religionInfo.Description)
			Controls.DominantReligionText:SetOffsetX(90)
			Controls.DominantReligionText:LocalizeAndSetText("TXT_KEY_EA_DOMINANT_RELIGION", religionStr, followersByReligion[eaPlayer.religionID], player:GetTotalPopulation())
		end

		--By Population
		g_PopulationManager:ResetInstances()
		table.sort(religions, function(a, b) return followersByReligion[a] > followersByReligion[b] end)
		for i = 1, religionsCount do
			local religionID = religions[i]
			local religionInfo = GameInfo.Religions[religionID]
			local populationEntry = g_PopulationManager:GetInstance()
			IconHookup(religionInfo.PortraitIndex, 32, religionInfo.IconAtlas, populationEntry.PopulationReligionIcon)
			local religionName = Locale.Lookup(religionInfo.Description)
			populationEntry.PopulationReligionText:LocalizeAndSetText("TXT_KEY_EA_RELIGION_BY_POPULATION_ENTRY", religionName, followersByReligion[religionID])
		end
		Controls.YourReligionsByPopulationStack:CalculateSize()
		Controls.YourReligionsByPopulationStack:ReprocessAnchoring()

		--By City
		g_CityManager:ResetInstances()
		if cityCount > 0 then
			table.sort(cityReligions, function(a, b) return a.population > b.population end)
			for i = 1, cityCount do
				local cityData = cityReligions[i]
				local iCity = cityData.iCity
				local religionID = cityData.religion
				local religionInfo = GameInfo.Religions[religionID]
				local city = player:GetCityByID(iCity)
				local bIsHolyCityForReligion = city:IsHolyCityForReligion(religionID)
				local cityEntry = g_CityManager:GetInstance()
				local iconAtlas = bIsHolyCityForReligion and "EA_RELIGION_STAR_ATLAS" or "EA_RELIGION_ATLAS"
				IconHookup(religionInfo.PortraitIndex, 32, iconAtlas, cityEntry.CityReligionIcon)
				cityEntry.CityReligionText:LocalizeAndSetText("TXT_KEY_EA_RELIGION_BY_CITY_ENTRY", cityData.followers, cityData.population, city:GetName())
			end
		else
		
		end
		Controls.YourReligionsByCityStack:CalculateSize()
		Controls.YourReligionsByCityStack:ReprocessAnchoring()

		Controls.YourReligionsScrollPanel:CalculateInternalSize()
	end

end

local beliefsEnabledByID = {}
local beliefInfoTable = {}

function RefreshReligions(tab)
	print("Running RefreshReligions ", tab)

	Controls.YourReligionsPanel:SetHide(true)
	Controls.NoReligiousFollowers:SetHide(true)
	Controls.ReligionsPanel:SetHide(false)

	g_ReligionManager:ResetInstances()
	local sqlConditional
	if tab == "Pantheistic" then
		Controls.WorldViewBlurb:LocalizeAndSetText("TXT_KEY_EA_PANTHEISM_PEDIA")
		sqlConditional = "ID >= " .. RELIGION_THE_WEAVE_OF_EA
	else
		Controls.WorldViewBlurb:LocalizeAndSetText("TXT_KEY_EA_THEISM_PEDIA")
		sqlConditional = "ID > 0 AND ID < " .. RELIGION_THE_WEAVE_OF_EA
	end
	
	for religionInfo in GameInfo.Religions(sqlConditional) do
		local id = religionInfo.ID
		local religionEntry = g_ReligionManager:GetInstance()
		IconHookup(religionInfo.PortraitIndex, 80, religionInfo.IconAtlas, religionEntry.ReligionIcon)
		--in case we want to hook the botton to something:
		--religionEntry.ReligionButton:SetVoid1(id)
		--religionEntry.ReligionButton:RegisterCallback(Mouse.eLClick, ReligionSelected)
		--religionEntry.ReligionButton:SetDisabled(bDisabled)

		--religionEntry.ReligionTitle:LocalizeAndSetText(religionInfo.Description)
		religionEntry.ReligionTitle:SetText(Locale.ToUpper(Locale.Lookup(religionInfo.Description)))
		religionEntry.ReligionBlurb:LocalizeAndSetText(religionInfo.Civilopedia)

		local text = ""
		local bFounded = gT.gReligions[id]
		if bFounded then
			if id ~= RELIGION_THE_WEAVE_OF_EA then
				local iFounder = gT.gReligions[id].founder
				--local civName = Locale.Lookup(gT.gPlayers[iFounder].civName)
				local civName = Locale.Lookup(PreGame.GetCivilizationShortDescription(iFounder))
				local bIsAlive = Players[iFounder]:IsAlive()
				local bIsFallen = gT.gPlayers[iFounder].bIsFallen
				local founderTxt = Locale.Lookup("TXT_KEY_EA_RELIGION_FOUNDER", civName)
				if not bIsAlive then
					founderTxt = "[COLOR_NEGATIVE_TEXT]" .. founderTxt .. " (" .. Locale.Lookup("TXT_KEY_EA_RELIGION_DESTROYED") .. ")" .. "[ENDCOLOR]"
				elseif bIsFallen then
					founderTxt = "[COLOR_NEGATIVE_TEXT]" .. founderTxt .. " (" .. Locale.Lookup("TXT_KEY_EA_RELIGION_FALLEN") .. ")" .. "[ENDCOLOR]"
				else
					founderTxt = "[COLOR_POSITIVE_TEXT]" .. founderTxt .. "[ENDCOLOR]"
				end
				text = text .. founderTxt

				local holyCity = Game.GetHolyCityForReligion(id, -1)
				local holyCityName = holyCity and holyCity:GetName() or Locale.Lookup("TXT_KEY_EA_RELIGION_DESTROYED")
				local holyCityTxt = Locale.Lookup("TXT_KEY_EA_RELIGION_HOLY_CITY", holyCityName)

				if holyCity and holyCity:GetOwner() ~= iFounder then
					--local ownerName = Locale.Lookup(gT.gPlayers[holyCity:GetOwner()].civName)
					local ownerName = Locale.Lookup(PreGame.GetCivilizationShortDescription(holyCity:GetOwner()))
					holyCityTxt = holyCityTxt .. Locale.Lookup("TXT_KEY_EA_RELIGION_HOLY_CITY_OWNED_BY", ownerName)
				end
				if holyCity then
					if holyCity:GetReligiousMajority() == RELIGION_ANRA then
						holyCityTxt = "[COLOR_NEGATIVE_TEXT]" .. holyCityTxt .. " (" .. Locale.Lookup("TXT_KEY_EA_RELIGION_FALLEN") .. ")" .. "[ENDCOLOR]"
					else
						holyCityTxt = "[COLOR_POSITIVE_TEXT]" .. holyCityTxt .. "[ENDCOLOR]"
					end
				else
					holyCityTxt = "[COLOR_NEGATIVE_TEXT]" .. holyCityTxt .. " (" .. Locale.Lookup("TXT_KEY_EA_RELIGION_DESTROYED") .. ")" .. "[ENDCOLOR]"
				end

				text = text .. "        " .. holyCityTxt .. "        "
			end
			local worldFollowers = math.floor(100 * Game.GetNumFollowers(id) / Game.GetTotalPopulation() + 0.5)
			local followersTxt = Locale.Lookup("TXT_KEY_EA_RELIGION_WORLD_FOLLOWERS", worldFollowers)
			if id == RELIGION_ANRA then
				followersTxt = "[COLOR_NEGATIVE_TEXT]" .. followersTxt .. "[ENDCOLOR]"
			else
				followersTxt = "[COLOR_POSITIVE_TEXT]" .. followersTxt .. "[ENDCOLOR]"
			end
			text = text .. followersTxt
		else
			text = text .. Locale.Lookup("TXT_KEY_EA_RELIGION_NOT_FOUNDED")
		end
		if religionInfo.EaStrategy then
			text = text .. "[NEWLINE]" .. Locale.Lookup(religionInfo.EaStrategy)
		end
	
		if bFounded then
			for i, beliefID in ipairs(Game.GetBeliefsInReligion(id)) do
				local belief = GameInfo.Beliefs[beliefID]
				if belief then
					beliefsEnabledByID[beliefID] = true
				end
			end
		end

		local beliefCount = 0
		local bHasFounderEffect, bHasFollowerEffect, bHasEnhancerEffect = false, false, false
		local bEnabledFounderEffect, bEnabledFollowerEffect, bEnabledEnhancerEffect = false, false, false
		for row in GameInfo.Religions_BeliefsInReligion("ReligionType = '" .. religionInfo.Type .. "'") do
			--print("Religions_BeliefsInReligion: ", row.ReligionType,	row.BeliefType)
			beliefCount = beliefCount + 1
			local beliefInfo = GameInfo.Beliefs[row.BeliefType]
			if beliefInfo.Founder then
				bHasFounderEffect = true
				if beliefsEnabledByID[beliefInfo.ID] then
					bEnabledFounderEffect = true
				end
			elseif beliefInfo.Follower then
				bHasFollowerEffect = true
				if beliefsEnabledByID[beliefInfo.ID] then
					bEnabledFollowerEffect = true
				end
			elseif beliefInfo.Enhancer then
				bHasEnhancerEffect = true
				if beliefsEnabledByID[beliefInfo.ID] then
					bEnabledEnhancerEffect = true
				end
			end
			beliefInfoTable[beliefCount] = beliefInfo
		end
		
		if bHasFounderEffect then
			local header = Locale.Lookup("TXT_KEY_EA_RELIGION_FOUNDER_EFFECTS")
			if bEnabledFounderEffect then
				text = text .. "[NEWLINE][COLOR:255:255:200:255]" .. header .. "[/COLOR]"
			else
				text = text .. "[NEWLINE][COLOR:100:100:100:255]" .. header .. "[/COLOR]"
			end
			for i = 1, beliefCount do
				local beliefInfo = beliefInfoTable[i]
				if beliefInfo.Founder then
					local beliefText = Locale.Lookup(beliefInfo.ShortDescription)
					if beliefsEnabledByID[beliefInfo.ID] then
						text = text .. "[NEWLINE]  [ICON_BULLET][COLOR:255:255:200:255]" .. beliefText .. "[/COLOR]"
					else
						if beliefInfo.EaPolicyTrigger then
							local policyInfo = GameInfo.Policies[beliefInfo.EaPolicyTrigger]
							if policyInfo.PolicyBranchType == "POLICY_BRANCH_THEISM" then
								beliefText = beliefText .. " " .. Locale.Lookup("TXT_KEY_EA_RELIGION_ADDED_WITH_POLICY", Locale.Lookup("TXT_KEY_EA_RELIGION_NON_FALLEN"), Locale.Lookup(policyInfo.Description))
							elseif policyInfo.PolicyBranchType == "POLICY_BRANCH_ANTI_THEISM" then
								beliefText = beliefText .. " " .. Locale.Lookup("TXT_KEY_EA_RELIGION_ADDED_WITH_POLICY", Locale.Lookup("TXT_KEY_EA_RELIGION_FALLEN"), Locale.Lookup(policyInfo.Description))
							else
								--pantheistic if we add any
							end
						end
						text = text .. "[NEWLINE]  [ICON_BULLET][COLOR:100:100:100:255]" .. beliefText .. "[/COLOR]"
					end
				end
			end
		end

		if bHasFollowerEffect then
			local header = Locale.Lookup("TXT_KEY_EA_RELIGION_FOLLOWER_EFFECTS")
			if bEnabledFollowerEffect then
				text = text .. "[NEWLINE][COLOR:255:255:200:255]" .. header .. "[/COLOR]"
			else
				text = text .. "[NEWLINE][COLOR:100:100:100:255]" .. header .. "[/COLOR]"
			end
			for i = 1, beliefCount do
				local beliefInfo = beliefInfoTable[i]
				if beliefInfo.Follower then
					local beliefText = Locale.Lookup(beliefInfo.ShortDescription)
					if beliefsEnabledByID[beliefInfo.ID] then
						text = text .. "[NEWLINE]  [ICON_BULLET][COLOR:255:255:200:255]" .. beliefText .. "[/COLOR]"
					else
						if beliefInfo.EaPolicyTrigger then
							local policyInfo = GameInfo.Policies[beliefInfo.EaPolicyTrigger]
							if policyInfo.PolicyBranchType == "POLICY_BRANCH_THEISM" then
								beliefText = beliefText .. Locale.Lookup("TXT_KEY_EA_RELIGION_ADDED_WITH_POLICY", Locale.Lookup("TXT_KEY_EA_RELIGION_NON_FALLEN"), Locale.Lookup(policyInfo.Description))
							elseif policyInfo.PolicyBranchType == "POLICY_BRANCH_ANTI_THEISM" then
								beliefText = beliefText .. Locale.Lookup("TXT_KEY_EA_RELIGION_ADDED_WITH_POLICY", Locale.Lookup("TXT_KEY_EA_RELIGION_FALLEN"), Locale.Lookup(policyInfo.Description))
							else
								--pantheistic if we add any
							end
						end
						text = text .. "[NEWLINE]  [ICON_BULLET][COLOR:100:100:100:255]" .. beliefText .. "[/COLOR]"
					end
				end
			end
		end

		if bHasEnhancerEffect then
			local header = Locale.Lookup("TXT_KEY_EA_RELIGION_ENHANCER_EFFECTS")
			if bEnabledEnhancerEffect then
				text = text .. "[NEWLINE][COLOR:255:255:200:255]" .. header .. "[/COLOR]"
			else
				text = text .. "[NEWLINE][COLOR:100:100:100:255]" .. header .. "[/COLOR]"
			end
			for i = 1, beliefCount do
				local beliefInfo = beliefInfoTable[i]
				if beliefInfo.Enhancer then
					local beliefText = Locale.Lookup(beliefInfo.ShortDescription)
					if beliefsEnabledByID[beliefInfo.ID] then
						text = text .. "[NEWLINE]  [ICON_BULLET][COLOR:255:255:200:255]" .. beliefText .. "[/COLOR]"
					else
						if beliefInfo.EaPolicyTrigger then
							local policyInfo = GameInfo.Policies[beliefInfo.EaPolicyTrigger]
							if policyInfo.PolicyBranchType == "POLICY_BRANCH_THEISM" then
								beliefText = beliefText .. Locale.Lookup("TXT_KEY_EA_RELIGION_ADDED_WITH_POLICY", Locale.Lookup("TXT_KEY_EA_RELIGION_NON_FALLEN"), Locale.Lookup(policyInfo.Description))
							elseif policyInfo.PolicyBranchType == "POLICY_BRANCH_ANTI_THEISM" then
								beliefText = beliefText .. Locale.Lookup("TXT_KEY_EA_RELIGION_ADDED_WITH_POLICY", Locale.Lookup("TXT_KEY_EA_RELIGION_FALLEN"), Locale.Lookup(policyInfo.Description))
							else
								--pantheistic if we add any
							end
						end
						text = text .. "[NEWLINE]  [ICON_BULLET][COLOR:100:100:100:255]" .. beliefText .. "[/COLOR]"
					end
				end
			end
		end

		religionEntry.ReligionText:SetText(text)
		religionEntry.InstanceStack:CalculateSize()
		religionEntry.InstanceStack:ReprocessAnchoring()

		local stackSize = religionEntry.InstanceStack:GetSize()
		religionEntry.ReligionButton:SetSizeY(stackSize.y)

		--recycle table
		for key in pairs(beliefsEnabledByID) do
			beliefsEnabledByID[key] = false
		end
	end
	Controls.ReligionStack:CalculateSize()
	Controls.ReligionStack:ReprocessAnchoring()
	Controls.ScrollPanel:CalculateInternalSize()
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    ----------------------------------------------------------------        
    -- Key Down Processing
    ----------------------------------------------------------------        
    if(uiMsg == KeyEvents.KeyDown) then
        if (wParam == Keys.VK_ESCAPE) then
			OnClose();
			return true;
        end
        
        -- Do Nothing.
        if(wParam == Keys.VK_RETURN) then
			return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnClose()
	UIManager:DequeuePopup(ContextPtr);
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )
    if( not bInitState ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();  
        	Events.SerialEventGameMessagePopupShown(g_PopupInfo);
        	
        	TabSelect(g_CurrentTab);
        else
			if(g_PopupInfo ~= nil) then
				Events.SerialEventGameMessagePopupProcessed.CallImmediate(g_PopupInfo.Type, 0);
            end
            UI.decTurnTimerSemaphore();
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
function OnActivePlayerChanged()
	--if (not Controls.ChooseConfirm:IsHidden()) then
	--	Controls.ChooseConfirm:SetHide(true);
	--end
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged);

-----------------------------------------------------------------
-- Add Religion Overview to Dropdown (if enabled)
-----------------------------------------------------------------
if(not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
	LuaEvents.AdditionalInformationDropdownGatherEntries.Add(function(entries)
		table.insert(entries, {
			text=Locale.Lookup("TXT_KEY_RELIGION_OVERVIEW"),
			call=function() 
				Events.SerialEventGameMessagePopup{ 
					Type = ButtonPopupTypes.BUTTONPOPUP_RELIGION_OVERVIEW,
				};
			end,
		});
	end);

	-- Just in case :)
	LuaEvents.RequestRefreshAdditionalInformationDropdownEntries();
end

--TabSelect("Pantheistic");




