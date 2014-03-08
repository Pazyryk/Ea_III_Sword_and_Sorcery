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

--------------------------------------------------------------
-- file control vars
--------------------------------------------------------------

local g_ReligionManager = InstanceManager:new( "ReligionInstance", "ReligionButton", Controls.ReligionStack)

local g_CurrentTab = "Pantheistic"


function Show()					--called from diplo corner
	print("Running Show for ReligionOverview.lua")
	ContextPtr:SetHide(false)
	TabSelect(g_CurrentTab)
end


function TabSelect(tab)
	if tab == "Pantheistic" then
		Controls.TheisticSelectHighlight:SetHide(true)
		Controls.PantheisticSelectHighlight:SetHide(false)
		RefreshReligions("Pantheistic")

	elseif tab == "Theistic" then
		Controls.PantheisticSelectHighlight:SetHide(true)
		Controls.TheisticSelectHighlight:SetHide(false)
		RefreshReligions("Theistic")

	end
	g_CurrentTab = tab
end
Controls.TabButtonPantheistic:RegisterCallback( Mouse.eLClick, function() TabSelect("Pantheistic") end)
Controls.TabButtonTheistic:RegisterCallback( Mouse.eLClick, function() TabSelect("Theistic") end )

local beliefsEnabledByID = {}
local beliefInfoTable = {}

function RefreshReligions(tab)
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
		religionEntry.ReligionTitle:LocalizeAndSetText(religionInfo.Description)
		religionEntry.ReligionBlurb:LocalizeAndSetText(religionInfo.Civilopedia)

		local text = ""
		local bFounded = gT.gReligions[id]
		if bFounded then
			if id == RELIGION_THE_WEAVE_OF_EA then
				text = text .. Locale.Lookup("TXT_KEY_EA_WEAVE_NO_FOUNDER")
			else
				local iFounder = Game.GetFounder(id, -1)
				local civName = gT.gPlayers[iFounder].civName
				local holyCity = Game.GetHolyCityForReligion(id, -1)
				local holyCityName = holyCity and holyCity:GetName() or Locale.Lookup("TXT_KEY_EA_HOLY_CITY_DESTROYED")
				text = text .. Locale.Lookup("TXT_KEY_EA_RELIGION_FOUNDER_HOLY_CITY", civName, holyCityName)

				if holyCity and holyCity:GetOwner() ~= iFounder then
					local ownerName = gT.gPlayers[holyCity:GetOwner()].civName
					text = text .. Locale.Lookup("TXT_KEY_EA_RELIGION_HOLY_CITY_OWNED_BY", ownerName)
				end
			end
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
			print("Religions_BeliefsInReligion:, ", row.ReligionType,	row.BeliefType)
			beliefCount = beliefCount + 1
			local beliefType = row.BeliefType
			local beliefInfo = GameInfo.Beliefs[BeliefType]
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
				text = text .. "[NEWLINE]" .. header
			else
				text = text .. "[NEWLINE][COLOR:100:100:100:255]" .. header .. "[/COLOR]"
			end
			for i = 1, beliefCount do
				local beliefInfo = beliefInfoTable[i]
				if beliefInfo.Founder then
					local beliefText = Locale.Lookup(beliefInfo.ShortDescription)
					if beliefsEnabledByID[beliefInfo.ID] then
						text = text .. "[NEWLINE]  [ICON_BULLET]" .. beliefText
					else
						if beliefInfo.EaPolicyTrigger then
							beliefText = beliefText .. Locale.Lookup("TXT_KEY_EA_RELIGION_ADDED_WITH_POLICY", Locale.Lookup(GameInfo.Policies[beliefInfo.EaPolicyTrigger].Description))
						end
						text = text .. "[NEWLINE][COLOR:100:100:100:255]  [ICON_BULLET]" .. beliefText .. "[/COLOR]"
					end
				end
			end
		end

		if bHasFollowerEffect then
			local header = Locale.Lookup("TXT_KEY_EA_RELIGION_FOLLOWER_EFFECTS")
			if bEnabledFollowerEffect then
				text = text .. "[NEWLINE]" .. header
			else
				text = text .. "[NEWLINE][COLOR:100:100:100:255]" .. header .. "[/COLOR]"
			end
			for i = 1, beliefCount do
				local beliefInfo = beliefInfoTable[i]
				if beliefInfo.Follower then
					local beliefText = Locale.Lookup(beliefInfo.ShortDescription)
					if beliefsEnabledByID[beliefInfo.ID] then
						text = text .. "[NEWLINE]  [ICON_BULLET]" .. beliefText
					else
						if beliefInfo.EaPolicyTrigger then
							beliefText = beliefText .. Locale.Lookup("TXT_KEY_EA_RELIGION_ADDED_WITH_POLICY", Locale.Lookup(GameInfo.Policies[beliefInfo.EaPolicyTrigger].Description))
						end
						text = text .. "[NEWLINE][COLOR:100:100:100:255]  [ICON_BULLET]" .. beliefText .. "[/COLOR]"
					end
				end
			end
		end

		if bHasEnhancerEffect then
			local header = Locale.Lookup("TXT_KEY_EA_RELIGION_ENHANCER_EFFECTS")
			if bEnabledEnhancerEffect then
				text = text .. "[NEWLINE]" .. header
			else
				text = text .. "[NEWLINE][COLOR:100:100:100:255]" .. header .. "[/COLOR]"
			end
			for i = 1, beliefCount do
				local beliefInfo = beliefInfoTable[i]
				if beliefInfo.Enhancer then
					local beliefText = Locale.Lookup(beliefInfo.ShortDescription)
					if beliefsEnabledByID[beliefInfo.ID] then
						text = text .. "[NEWLINE]  [ICON_BULLET]" .. beliefText
					else
						if beliefInfo.EaPolicyTrigger then
							beliefText = beliefText .. Locale.Lookup("TXT_KEY_EA_RELIGION_ADDED_WITH_POLICY", Locale.Lookup(GameInfo.Policies[beliefInfo.EaPolicyTrigger].Description))
						end
						text = text .. "[NEWLINE][COLOR:100:100:100:255]  [ICON_BULLET]" .. beliefText .. "[/COLOR]"
					end
				end
			end
		end

		religionEntry.ReligionText:SetText(text)

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

function OnClose()
    ContextPtr:SetHide(true)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--[[
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



-----------------------------------------------------------------
-- Add Religion Overview to Dropdown (if enabled)
-----------------------------------------------------------------
if(not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
	LuaEvents.AdditionalInformationDropdownGatherEntries.Add(function(entries)
		table.insert(entries, {
			text=Locale.Lookup("TXT_KEY_EA_RELIGION_POPUP"),
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
]]

--This adds popup to the Diplo Corner
function OnAdditionalInformationDropdownGatherEntries(additionalEntries)
	table.insert(additionalEntries, {	text = Locale.ConvertTextKey("TXT_KEY_EA_RELIGION_POPUP"), 
										call = Show		})
end
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(OnAdditionalInformationDropdownGatherEntries)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()


ContextPtr:SetHide(true)


