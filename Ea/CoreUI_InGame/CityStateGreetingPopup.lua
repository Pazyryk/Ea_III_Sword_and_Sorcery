-------------------------------------------------
-- City State Greeting Popup
-------------------------------------------------
include( "IconSupport" );
include( "InfoTooltipInclude" );
include( "CityStateStatusHelper" );


--Paz add
local MapModData = MapModData
MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

local g_minorCivTrait = -1
--end Paz add

local m_PopupInfo = nil;
local lastBackgroundImage = "citystatebackgroundculture.dds"

-------------------------------------------------
-------------------------------------------------
function OnPopup( popupInfo )
	--print("PazDebug CityStateGreetingPopup OnPopup")
	local bGreeting = popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_GREETING;
	local bMessage = popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_MESSAGE;
	local bDiplo = popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_DIPLO;
	
	if (not bGreeting) then
		return;
	end
	
	--------------------------
	-- City State saying hi for the first time
	--------------------------
	
	m_PopupInfo = popupInfo;	
	
    local iPlayer = popupInfo.Data1;
    local pPlayer = Players[iPlayer];
	--Paz add
	local eaPlayer = gT.gPlayers[iPlayer]
	if not eaPlayer then return end
	g_minorCivTrait = pPlayer:GetMinorCivTrait()
	--end Paz add
	
	local strNameKey = pPlayer:GetCivilizationShortDescriptionKey();

	local strTitle = "";
	local strDescription = "";
	
	-- Set Title Icon
	local sMinorCivType = pPlayer:GetMinorCivType();
	local trait = GameInfo.MinorCivilizations[sMinorCivType].MinorCivTrait;
	Controls.TitleIcon:SetTexture(GameInfo.MinorCivTraits[trait].TraitTitleIcon);
	
	-- Set Background Image
	lastBackgroundImage = GameInfo.MinorCivTraits[trait].BackgroundImage;
	Controls.BackgroundImage:SetTexture(lastBackgroundImage);
	
	-- Update colors
	local primaryColor, secondaryColor = pPlayer:GetPlayerColors();
	primaryColor, secondaryColor = secondaryColor, primaryColor;
	local textColor = {x = primaryColor.x, y = primaryColor.y, z = primaryColor.z, w = 1};
	
	civType = pPlayer:GetCivilizationType();
	civInfo = GameInfo.Civilizations[civType];
	
	local iconColor = textColor;
	IconHookup( civInfo.PortraitIndex, 32, civInfo.AlphaIconAtlas, Controls.CivIcon );
	Controls.CivIcon:SetColor(iconColor);
	
	local strShortDescKey = pPlayer:GetCivilizationShortDescriptionKey();
	
	-- Title
	strTitle = Locale.ConvertTextKey("{" .. strShortDescKey.. ":upper}");
	--Paz add
	if MapModData.playerType[iPlayer] == "CityState" then
		local raceStr = Locale.ConvertTextKey(GameInfo.EaRaces[eaPlayer.race].Description)
		strTitle = strTitle .. " (" .. raceStr .. ")"
	end
	--end Paz add

	local iActivePlayer = Game.GetActivePlayer();
	
	if (bMessage) then
		
		local strStatusText = GetCityStateStatusText(iActivePlayer, iPlayer);
		local strStatusTT = GetCityStateStatusToolTip(iActivePlayer, iPlayer, true);
		Controls.StatusIcon:SetTexture(GameInfo.MinorCivTraits[trait].TraitIcon);
		UpdateCityStateStatusUI(iActivePlayer, iPlayer, Controls.PositiveStatusMeter, Controls.NegativeStatusMeter, Controls.StatusMeterMarker, Controls.StatusIconBG);
		Controls.StatusInfo:SetText(strStatusText);
		Controls.StatusInfo:SetToolTipString(strStatusTT);
		Controls.StatusLabel:SetToolTipString(strStatusTT);
		Controls.StatusIconBG:SetToolTipString(strStatusTT);
		Controls.PositiveStatusMeter:SetToolTipString(strStatusTT);
		Controls.NegativeStatusMeter:SetToolTipString(strStatusTT);
		
		Controls.CityStateMeterThingy:SetHide(false);
		UpdateActiveQuests();
		Controls.QuestLabel:SetHide(false);
	
	-- Greeting popup - don't show status or quests here
	else
		Controls.CityStateMeterThingy:SetHide(true);
		Controls.QuestLabel:SetHide(true);
	end
		
	-- Info on their Trait
	--Paz disabled: local strTraitText = GetCityStateTraitText(iPlayer);
	--Paz disabled: local strTraitTT = GetCityStateTraitToolTip(iPlayer);
	--Paz add
	local strTraitText, strTraitTT

	if MapModData.playerType[iPlayer] == "CityState" then
		local traitInfo = GameInfo.MinorCivTraits[g_minorCivTrait]
		if traitInfo.Type == "MINOR_TRAIT_HOLY" and eaPlayer.religionID == GameInfoTypes.RELIGION_ANRA then
			strTraitText = Locale.ConvertTextKey("TXT_KEY_EA_MINOR_TRAIT_UNHOLY")
			strTraitTT = Locale.ConvertTextKey("TXT_KEY_EA_MINOR_TRAIT_UNHOLY_HELP")
		else
			strTraitText = Locale.ConvertTextKey(traitInfo.Description)
			strTraitTT = Locale.ConvertTextKey(traitInfo.EaHelp)
		end
		Controls.TraitLabel:LocalizeAndSetText("TXT_KEY_POP_CSTATE_TRAIT")
		Controls.FindOnMapButton:SetHide(false)
	elseif MapModData.playerType[iPlayer] == "God" then
		local minorCivType = pPlayer:GetMinorCivType()
		local civInfo = GameInfo.MinorCivilizations[minorCivType]
		local godType = civInfo.Type
		strTraitText = ""
		for row in GameInfo.MinorCivilization_GodSpheres() do
			if row.MinorCivType == godType then
				if strTraitText == "" then
					strTraitText = Locale.ConvertTextKey(row.SphereText)
				else
					strTraitText = strTraitText .. ", " .. Locale.ConvertTextKey(row.SphereText)
				end
			end
		end
		strTraitTT = Locale.ConvertTextKey("TXT_KEY_EA_GOD_SPHERES_HELP")
		Controls.TraitLabel:SetText(Locale.ConvertTextKey("TXT_KEY_EA_GOD_SPHERES"))
		Controls.FindOnMapButton:SetHide(true)
	end
	--end Paz add

	strTraitText = "[COLOR_POSITIVE_TEXT]" .. strTraitText .. "[ENDCOLOR]";
	
	Controls.TraitInfo:SetText(strTraitText);
	Controls.TraitInfo:SetToolTipString(strTraitTT);
	Controls.TraitLabel:SetToolTipString(strTraitTT);
	
	-- Personality
	local strPersonalityText = "";
	local strPersonalityTT = "";
	local iPersonality = pPlayer:GetPersonality();
	if (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_FRIENDLY) then
		strPersonalityText = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY");
		strPersonalityTT = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_PERSONALITY_FRIENDLY_TT");
	elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_NEUTRAL) then
		strPersonalityText = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL");
		strPersonalityTT = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_PERSONALITY_NEUTRAL_TT");
	elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_HOSTILE) then
		strPersonalityText = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_PERSONALITY_HOSTILE");
		strPersonalityTT = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_PERSONALITY_HOSTILE_TT");
	elseif (iPersonality == MinorCivPersonalityTypes.MINOR_CIV_PERSONALITY_IRRATIONAL) then
		strPersonalityText = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_PERSONALITY_IRRATIONAL");
		strPersonalityTT = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_PERSONALITY_IRRATIONAL_TT");
	end
	
	strPersonalityText = "[COLOR_POSITIVE_TEXT]" .. strPersonalityText .. "[ENDCOLOR]";
	
	Controls.PersonalityInfo:SetText(strPersonalityText);
	Controls.PersonalityInfo:SetToolTipString(strPersonalityTT);
	Controls.PersonalityLabel:SetToolTipString(strPersonalityTT);
	
	-- Ally Status
	local iAlly = pPlayer:GetAlly();
	local strAllyTT = "";
	local bHideIcon = true;
	local bHideText = true;
	if (iAlly ~= nil and iAlly ~= -1) then
		local iAllyInf = pPlayer:GetMinorCivFriendshipWithMajor(iAlly);
		local iActivePlayerInf = pPlayer:GetMinorCivFriendshipWithMajor(iActivePlayer);
	
		if (iAlly ~= iActivePlayer) then
			if (Teams[Players[iAlly]:GetTeam()]:IsHasMet(Game.GetActiveTeam())) then
				local iInfUntilAllied = iAllyInf - iActivePlayerInf + 1; -- needs to pass up the current ally, not just match
				strAllyTT = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_ALLY_TT", Players[iAlly]:GetCivilizationShortDescriptionKey(), iInfUntilAllied);
				bHideIcon = false;
				CivIconHookup(iAlly, 32, Controls.AllyIcon, Controls.AllyIconBG, Controls.AllyIconShadow, false, true);
			else
				local iInfUntilAllied = iAllyInf - iActivePlayerInf + 1; -- needs to pass up the current ally, not just match
				strAllyTT = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_ALLY_UNKNOWN_TT", iInfUntilAllied);
				bHideIcon = false;
				CivIconHookup(-1, 32, Controls.AllyIcon, Controls.AllyIconBG, Controls.AllyIconShadow, false, true);
			end
		else
			strAllyTT = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_ALLY_ACTIVE_PLAYER_TT");
			bHideText = false;
			Controls.AllyText:SetText("[COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_YOU") .. "[ENDCOLOR]");
		end
	else
		local iActivePlayerInf = pPlayer:GetMinorCivFriendshipWithMajor(iActivePlayer);
		local iInfUntilAllied = GameDefines["FRIENDSHIP_THRESHOLD_ALLIES"] - iActivePlayerInf;
		strAllyTT = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_ALLY_NOBODY_TT", iInfUntilAllied);
		bHideText = false;
		Controls.AllyText:SetText(Locale.ConvertTextKey("TXT_KEY_CITY_STATE_NOBODY"));
	end
	Controls.AllyIcon:SetToolTipString(strAllyTT);
	Controls.AllyIconBG:SetToolTipString(strAllyTT);
	Controls.AllyIconShadow:SetToolTipString(strAllyTT);
	Controls.AllyText:SetToolTipString(strAllyTT);
	Controls.AllyLabel:SetToolTipString(strAllyTT);
	
	Controls.AllyIconContainer:SetHide(bHideIcon);
	Controls.AllyText:SetHide(bHideText);

	--Paz add
	local playerType = MapModData.playerType[iPlayer]
	--end Paz add
	
	-- Nearby Resources
	local pCapital = pPlayer:GetCapitalCity();
	--Paz modifed in next line: if (pCapital ~= nil) then
	if pCapital or playerType == "God" then
		
		local strResourceText = "";
		
		local iNumResourcesFound = 0;

		--Paz add
		local tResourceList = {};

		if playerType == "God" then
			for resourceInfo in GameInfo.Resources() do
				local numResource = pPlayer:GetNumResourceTotal(resourceInfo.ID, false)
				if numResource > 0 then
					tResourceList[resourceInfo.ID] = (tResourceList[resourceInfo.ID] or 0) + numResource
				end
			end

		elseif playerType == "CityState" then

			--Paz: this code was outside of playerType conditional
			local thisX = pCapital:GetX();
			local thisY = pCapital:GetY();
		
			local iRange = GameDefines["MINOR_CIV_RESOURCE_SEARCH_RADIUS"]; --5
			local iCloseRange = math.floor(iRange/2); --2
			--Paz moved to above: local tResourceList = {};
		
			for iDX = -iRange, iRange, 1 do
				for iDY = -iRange, iRange, 1 do
					local pTargetPlot = Map.GetPlotXY(thisX, thisY, iDX, iDY);
				
					if pTargetPlot ~= nil then
					
						local iOwner = pTargetPlot:GetOwner();
					
						if (iOwner == iPlayer or iOwner == -1) then
							local plotX = pTargetPlot:GetX();
							local plotY = pTargetPlot:GetY();
							local plotDistance = Map.PlotDistance(thisX, thisY, plotX, plotY);
						
							if (plotDistance <= iRange and (plotDistance <= iCloseRange or iOwner == iPlayer)) then
							
								local iResourceType = pTargetPlot:GetResourceType(Game.GetActiveTeam());
							
								if (iResourceType ~= -1) then
								
									if (Game.GetResourceUsageType(iResourceType) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS) then
									
										if (tResourceList[iResourceType] == nil) then
											tResourceList[iResourceType] = 0;
										end
									
										tResourceList[iResourceType] = tResourceList[iResourceType] + pTargetPlot:GetNumResource();
									
									end
								end
							end
						end
					
					end
				end
			end	--Paz: end code that was previously outside playerType conditional

		end
		
		for iResourceType, iAmount in pairs(tResourceList) do
			if (iNumResourcesFound > 0) then
				strResourceText = strResourceText .. ", ";
			end
			local pResource = GameInfo.Resources[iResourceType];
			strResourceText = strResourceText .. pResource.IconString .. " [COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey(pResource.Description) .. " (" .. iAmount .. ") [ENDCOLOR]";
			iNumResourcesFound = iNumResourcesFound + 1;
		end	
		
		Controls.ResourcesInfo:SetText(strResourceText);
		
		Controls.ResourcesLabel:SetHide(false);
		Controls.ResourcesInfo:SetHide(false);
		
		local strResourceTextTT = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_RESOURCES_TT");
		Controls.ResourcesInfo:SetToolTipString(strResourceTextTT);
		Controls.ResourcesLabel:SetToolTipString(strResourceTextTT);
		
	else
		Controls.ResourcesLabel:SetHide(true);
		Controls.ResourcesInfo:SetHide(true);
	end

	-- Gifts
	local iGoldGift = popupInfo.Data2;
	local iFaithGift = popupInfo.Data3;
	local bFirstMajorCiv = popupInfo.Option1;
	local strGiftString = "";
	
	if (iGoldGift > 0) then
		if (bFirstMajorCiv) then
			strGiftString = strGiftString .. Locale.ConvertTextKey("TXT_KEY_CITY_STATE_GIFT_FIRST", iGoldGift);
		else
			strGiftString = strGiftString .. Locale.ConvertTextKey("TXT_KEY_CITY_STATE_GIFT_OTHER", iGoldGift);
		end
	end
	
	if (iFaithGift > 0) then
		if (iGoldGift > 0) then
			strGiftString = strGiftString .. " ";
		end
		
		if (bFirstMajorCiv) then
			strGiftString = strGiftString .. Locale.ConvertTextKey("TXT_KEY_EA_CITY_STATE_GIFT_FAITH_FIRST", iFaithGift);
		else
			strGiftString = strGiftString .. Locale.ConvertTextKey("TXT_KEY_EA_CITY_STATE_GIFT_FAITH_OTHER", iFaithGift);
		end
	end
	
	local strSpeakAgainString = Locale.ConvertTextKey("TXT_KEY_MINOR_SPEAK_AGAIN", strNameKey);
	
	strDescription = Locale.ConvertTextKey("TXT_KEY_CITY_STATE_MEETING", strNameKey, strGiftString, strSpeakAgainString);

	--Paz add
	if iFaithGift > 0 then			--only happens for gods
		if bFirstMajorCiv then
			strGiftString = Locale.ConvertTextKey("TXT_KEY_EA_GOD_GIFT_FIRST", iGoldGift, iFaithGift)
		else
			strGiftString = Locale.ConvertTextKey("TXT_KEY_EA_GOD_GIFT_OTHER", iGoldGift, iFaithGift)
		end
		strSpeakAgainString = Locale.ConvertTextKey("TXT_KEY_EA_GOD_SPEAK_AGAIN", strNameKey)
		strDescription = Locale.ConvertTextKey("TXT_KEY_EA_GOD_MEETING", strNameKey, strGiftString, strSpeakAgainString)
	end
	--end Paz add
	
	Controls.TitleLabel:SetText(strTitle);
	Controls.TitleLabel:SetColor(textColor, 0);
	Controls.DescriptionLabel:SetText(strDescription);
	
	UIManager:QueuePopup( ContextPtr, PopupPriority.CityStateGreeting );
end
Events.SerialEventGameMessagePopup.Add( OnPopup );


function UpdateActiveQuests()
	local iActivePlayer = Game.GetActivePlayer();
    local iPlayer = m_PopupInfo.Data1;
	local sIconText = GetActiveQuestText(iActivePlayer, iPlayer);
	local sToolTipText = GetActiveQuestToolTip(iActivePlayer, iPlayer);
	
	Controls.QuestInfo:SetText(sIconText);
	Controls.QuestInfo:SetToolTipString(sToolTipText);
	Controls.QuestLabel:SetToolTipString(sToolTipText);
end

----------------------------------------------------------------        
-- Input processing
----------------------------------------------------------------        
function OnCloseButtonClicked ()
    UIManager:DequeuePopup( ContextPtr );

	--Paz add
	if g_minorCivTrait == GameInfoTypes.MINOR_TRAIT_ARCANE or g_minorCivTrait == GameInfoTypes.MINOR_TRAIT_HOLY then 
		LuaEvents.EaCivsUpdateFaithFromEaCityStatesForUI()
		LuaEvents.TopPanelInfoDirty()
	end
	--end Paz add
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnCloseButtonClicked );
Controls.ScreenButton:RegisterCallback( Mouse.eRClick, OnCloseButtonClicked );

----------------------------------------------------------------
-- Find On Map
----------------------------------------------------------------
function OnFindOnMapButtonClicked ()
	local iPlayer = m_PopupInfo.Data1;
	local pPlayer = Players[iPlayer];
	if (pPlayer) then
		local pCity = pPlayer:GetCapitalCity();
		if (pCity) then
			local pPlot = pCity:Plot();
			if (pPlot) then
				UI.LookAt(pPlot, 0);
			end
		end
	end
end
Controls.FindOnMapButton:RegisterCallback( Mouse.eLClick, OnFindOnMapButtonClicked );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
            OnCloseButtonClicked();
            return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )
    if( not bInitState ) then
		Controls.BackgroundImage:UnloadTexture();
        if( not bIsHide ) then
			Controls.BackgroundImage:SetTexture(lastBackgroundImage);
        	UI.incTurnTimerSemaphore();
        	Events.SerialEventGameMessagePopupShown(m_PopupInfo);
        else
            UI.decTurnTimerSemaphore();
            Events.SerialEventGameMessagePopupProcessed.CallImmediate(m_PopupInfo.Type, 0);
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
Events.GameplaySetActivePlayer.Add(OnCloseButtonClicked);
