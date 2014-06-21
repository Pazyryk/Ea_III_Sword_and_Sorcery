-------------------------------
-- TopPanel.lua
-------------------------------
--Paz: did not do a careful update for BNW; just added trade route parts

--Paz add
include("EaCultureLevelHelper.lua")
include("EaGPSpawnHelper.lua")
include("EaFaithHelper.lua")

local MapModData = MapModData
MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

local EA_EPIC_VOLUSPA = GameInfoTypes.EA_EPIC_VOLUSPA
local EA_EPIC_HAVAMAL = GameInfoTypes.EA_EPIC_HAVAMAL



MapModData.faithFromCityStates = 0
MapModData.faithFromGPs = 0
MapModData.faithFromAzzTribute = 0
MapModData.faithFromToAhrimanTribute = 0
--end Paz add

function UpdateData()

	local iPlayerID = Game.GetActivePlayer();

	--Paz add
	if MapModData.DEBUG_PRINT then
		print("UpdateData for TopPanel.lua")
	end
	local gPlayers = gT.gPlayers
	local eaPlayer = gPlayers and gPlayers[iPlayerID]
	--end Paz add

	if( iPlayerID >= 0 ) then
		local pPlayer = Players[iPlayerID];
		local pTeam = Teams[pPlayer:GetTeam()];
		local pCity = UI.GetHeadSelectedCity();
		
		--Paz modified below: if (pPlayer:GetNumCities() > 0) then
		if (pPlayer:GetNumCities() > 0 and gPlayers) then	--gPlayers means that mod has been inited
			
			Controls.TopPanelInfoStack:SetHide(false);
			
			if (pCity ~= nil and UI.IsCityScreenUp()) then		
				Controls.MenuButton:SetText(Locale.ToUpper(Locale.ConvertTextKey("TXT_KEY_RETURN")));
				Controls.MenuButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_CITY_SCREEN_EXIT_TOOLTIP"));
			else
				Controls.MenuButton:SetText(Locale.ToUpper(Locale.ConvertTextKey("TXT_KEY_MENU")));
				Controls.MenuButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_MENU_TOOLTIP"));
			end
			-----------------------------
			-- Update science stats
			-----------------------------
			local strScienceText;
			
			if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)) then
				strScienceText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_SCIENCE_OFF");
			else
			
				local sciencePerTurn = pPlayer:GetScience();
			
				-- No Science
				if (sciencePerTurn <= 0) then
					strScienceText = string.format("[COLOR:255:60:60:255]" .. Locale.ConvertTextKey("TXT_KEY_NO_SCIENCE") .. "[/COLOR]");
				-- We have science
				else
					strScienceText = string.format("+%i", sciencePerTurn);

					local iGoldPerTurn = pPlayer:CalculateGoldRate();
					
					-- Gold being deducted from our Science
					if (pPlayer:GetGold() + iGoldPerTurn < 0) then
						strScienceText = "[COLOR:255:60:0:255]" .. strScienceText .. "[/COLOR]";
					-- Normal Science state
					else
						strScienceText = "[COLOR:33:190:247:255]" .. strScienceText .. "[/COLOR]";
					end
				end
			
				strScienceText = "[ICON_RESEARCH]" .. strScienceText;
			end

			--Paz add
			local fromDiffusion = eaPlayer.rpFromDiffusion
			local fromConquest = eaPlayer.rpFromConquest
			if fromDiffusion + fromConquest > 0 then
				strScienceText = strScienceText .. " [COLOR:33:190:247:255](" .. fromDiffusion .. " ," .. fromConquest .. ")[/COLOR]"
			end
			--end Paz add
			
			Controls.SciencePerTurn:SetText(strScienceText);
			
			-----------------------------
			-- Update gold stats
			-----------------------------
			local iTotalGold = pPlayer:GetGold();
			local iGoldPerTurn = pPlayer:CalculateGoldRate();

			--Paz add: these are deducted per turn so affect GPT (note that AI won't see these adjustments for trade purposes)
			iGoldPerTurn = iGoldPerTurn - MapModData.mercenaryNet
			--end Paz add
			
			-- Accounting for positive or negative GPT - there's obviously a better way to do this.  If you see this comment and know how, it's up to you ;)
			-- Text is White when you can buy a Plot
			--if (iTotalGold >= pPlayer:GetBuyPlotCost(-1,-1)) then
				--if (iGoldPerTurn >= 0) then
					--strGoldStr = string.format("[COLOR:255:255:255:255]%i (+%i)[/COLOR]", iTotalGold, iGoldPerTurn)
				--else
					--strGoldStr = string.format("[COLOR:255:255:255:255]%i (%i)[/COLOR]", iTotalGold, iGoldPerTurn)
				--end
			---- Text is Yellow or Red when you can't buy a Plot
			--else
			local strGoldStr = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_GOLD", iTotalGold, iGoldPerTurn);
			--end
			
			Controls.GoldPerTurn:SetText(strGoldStr);

			-----------------------------
			-- Update international trade routes
			-----------------------------
			local iUsedTradeRoutes = pPlayer:GetNumInternationalTradeRoutesUsed();
			local iAvailableTradeRoutes = pPlayer:GetNumInternationalTradeRoutesAvailable();
			local strInternationalTradeRoutes = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_INTERNATIONAL_TRADE_ROUTES", iUsedTradeRoutes, iAvailableTradeRoutes);
			Controls.InternationalTradeRoutes:SetText(strInternationalTradeRoutes);

			-----------------------------
			-- Update Happiness
			-----------------------------
			local strHappiness;
			
			if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS)) then
				strHappiness = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_HAPPINESS_OFF");
			else
				local iHappiness = pPlayer:GetExcessHappiness();
				local tHappinessTextColor;

				-- Empire is Happiness
				if (not pPlayer:IsEmpireUnhappy()) then
					strHappiness = string.format("[ICON_HAPPINESS_1][COLOR:60:255:60:255]%i[/COLOR]", iHappiness);
				
				-- Empire Really Unhappy
				elseif (pPlayer:IsEmpireVeryUnhappy()) then
					strHappiness = string.format("[ICON_HAPPINESS_4][COLOR:255:60:60:255]%i[/COLOR]", -iHappiness);
				
				-- Empire Unhappy
				else
					strHappiness = string.format("[ICON_HAPPINESS_3][COLOR:255:60:60:255]%i[/COLOR]", -iHappiness);
				end
			end
			
			Controls.HappinessString:SetText(strHappiness);
			
			-----------------------------
			-- Update Golden Age Info
			-----------------------------
			local strGoldenAgeStr;

			if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS)) then
				strGoldenAgeStr = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_GOLDEN_AGES_OFF");
			else
				if (pPlayer:GetGoldenAgeTurns() > 0) then
					strGoldenAgeStr = string.format(Locale.ToUpper(Locale.ConvertTextKey("TXT_KEY_GOLDEN_AGE_ANNOUNCE")) .. " (%i)", pPlayer:GetGoldenAgeTurns());
				else
					strGoldenAgeStr = string.format("%i/%i", pPlayer:GetGoldenAgeProgressMeter(), pPlayer:GetGoldenAgeProgressThreshold());
				end
			
				strGoldenAgeStr = "[ICON_GOLDEN_AGE][COLOR:255:255:255:255]" .. strGoldenAgeStr .. "[/COLOR]";
			end
			
			Controls.GoldenAgeString:SetText(strGoldenAgeStr);
			
			-----------------------------
			-- Update Culture
			-----------------------------

			local strCultureStr;
			
			if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES)) then
				strCultureStr = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_POLICIES_OFF");
			else
			
				--[[Paz modified below				
				if (pPlayer:GetNextPolicyCost() > 0) then
					strCultureStr = string.format("%i/%i (+%i)", pPlayer:GetJONSCulture(), pPlayer:GetNextPolicyCost(), pPlayer:GetTotalJONSCulturePerTurn());
				else
					strCultureStr = string.format("%i (+%i)", pPlayer:GetJONSCulture(), pPlayer:GetTotalJONSCulturePerTurn());
				end
				]]
				UpdateCultureLevelInfoForUI(iPlayerID)
				strCultureStr = string.format("%.2f/%.0f (%+.2f)", MapModData.cultureLevel, MapModData.nextCultureLevel, MapModData.estCultureLevelChange)

				--end Paz modified
				strCultureStr = "[ICON_CULTURE][COLOR:255:0:255:255]" .. strCultureStr .. "[/COLOR]";
			end
			
			Controls.CultureString:SetText(strCultureStr);
			
			-----------------------------
			-- Update Faith
			-----------------------------
			--[[Paz modified below
			local strFaithStr;
			if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
				strFaithStr = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_RELIGION_OFF");
			else
				strFaithStr = string.format("%i (+%i)", pPlayer:GetFaith(), pPlayer:GetTotalFaithPerTurn());
				strFaithStr = "[ICON_PEACE]" .. strFaithStr;
			end
			]]

			local strFaithStr = ""

			if MapModData.fullCivs[iPlayerID] then
				local totalFaith = pPlayer:GetFaith()
				local totalFaithPerTurn = GetTotalFaithPerTurnForUI(iPlayerID)
			
				if totalFaith ~= 0 or totalFaithPerTurn ~= 0 then
					local faithIcon = (eaPlayer and eaPlayer.bUsesDivineFavor) and "[ICON_PEACE]" or "[ICON_STAR]"
					strFaithStr = faithIcon .. string.format("%i (+%i)", totalFaith, totalFaithPerTurn)
				end
			end
			--end Paz modified
			Controls.FaithString:SetText(strFaithStr);

	
			-----------------------------
			-- Update Resources
			-----------------------------
			local pResource;
			local bShowResource;
			local iNumAvailable;
			local iNumUsed;
			local iNumTotal;
			
			local strResourceText = "";
			local strTempText = "";
			
			for pResource in GameInfo.Resources() do
				local iResourceLoop = pResource.ID;
				
				if (Game.GetResourceUsageType(iResourceLoop) == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC) then
					
					bShowResource = false;
					
					if (pTeam:GetTeamTechs():HasTech(GameInfoTypes[pResource.TechReveal])) then
						if (pTeam:GetTeamTechs():HasTech(GameInfoTypes[pResource.TechCityTrade])) then
							bShowResource = true;
						end
					end
					
					iNumAvailable = pPlayer:GetNumResourceAvailable(iResourceLoop, true);
					iNumUsed = pPlayer:GetNumResourceUsed(iResourceLoop);
					iNumTotal = pPlayer:GetNumResourceTotal(iResourceLoop, true);
					
					if (iNumUsed > 0) then
						bShowResource = true;
					end
							
					if (bShowResource) then
						local text = Locale.ConvertTextKey(pResource.IconString);
						strTempText = string.format("%i %s   ", iNumAvailable, text);
						
						-- Colorize for amount available
						if (iNumAvailable > 0) then
							strTempText = "[COLOR_POSITIVE_TEXT]" .. strTempText .. "[ENDCOLOR]";
						elseif (iNumAvailable < 0) then
							strTempText = "[COLOR_WARNING_TEXT]" .. strTempText .. "[ENDCOLOR]";
						end
						
						strResourceText = strResourceText .. strTempText;
					end
				end
			end
			
			Controls.ResourceString:SetText(strResourceText);
			
			--Paz add
			-----------------------------
			-- Update GPs
			-----------------------------
			local chance = CalculateGPSpawnChance(iPlayerID)
			--[[
			local ptsE, ptsM, ptsS, ptsA, ptsW, ptsD, ptsT = eaPlayer.classPoints[1], eaPlayer.classPoints[2], eaPlayer.classPoints[3], eaPlayer.classPoints[4], eaPlayer.classPoints[5], eaPlayer.classPoints[6], eaPlayer.classPoints[7]
			if not ptsE then
				ptsE, ptsM, ptsS, ptsA, ptsW, ptsD, ptsT = 0, 0, 0, 0, 0, 0, 0
			end
			local strGreatPeopleStr = "[ICON_GREAT_PEOPLE][COLOR:225:225:225:255]" .. chance/10 .. "% (E:"..ptsE.." M:"..ptsM.." S:"..ptsS.." A:"..ptsA.." W:"..ptsW.." D:"..ptsD.." T:"..ptsT..")[/COLOR]"
			]]
			local strGreatPeopleStr = "[ICON_GREAT_PEOPLE][COLOR:225:225:225:255]" .. chance/10 .. "%[/COLOR]"
			Controls.GreatPeopleString:SetText(strGreatPeopleStr)
			
			-----------------------------
			-- Update Sum of All Mana
			-----------------------------			
			--ICON_OMEGA
			
			
			
			
			--end Paz add

		-- No Cities, so hide science
		else
			
			Controls.TopPanelInfoStack:SetHide(true);
			
		end
		
		-- Update turn counter
		--[[Paz disabled
		local turn = Locale.ConvertTextKey("TXT_KEY_TP_TURN_COUNTER", Game.GetGameTurn());
		Controls.CurrentTurn:SetText(turn);
		]]

		-- Update Unit Supply
		local iUnitSupplyMod = pPlayer:GetUnitProductionMaintenanceMod();
		if (iUnitSupplyMod ~= 0) then
			local iUnitsSupplied = pPlayer:GetNumUnitsSupplied();
			local iUnitsOver = pPlayer:GetNumUnitsOutOfSupply();
			local strUnitSupplyToolTip = Locale.ConvertTextKey("TXT_KEY_UNIT_SUPPLY_REACHED_TOOLTIP", iUnitsSupplied, iUnitsOver, -iUnitSupplyMod);
			
			Controls.UnitSupplyString:SetToolTipString(strUnitSupplyToolTip);
			Controls.UnitSupplyString:SetHide(false);
		else
			Controls.UnitSupplyString:SetHide(true);
		end
		
		-- Update date
		--[[Paz modified below
		local date;
		local traditionalDate = Game.GetTurnString();
		
		if (pPlayer:IsUsingMayaCalendar()) then
			date = pPlayer:GetMayaCalendarString();
			local toolTipString = Locale.ConvertTextKey("TXT_KEY_MAYA_DATE_TOOLTIP", pPlayer:GetMayaCalendarLongString(), traditionalDate);
			Controls.CurrentDate:SetToolTipString(toolTipString);
		else
			date = traditionalDate;
		end
		]]
		local date = "Year " .. Game.GetGameTurn()
		--end Paz modified

		Controls.CurrentDate:SetText(date);
	
	
	--Paz add
	if MapModData.DEBUG_PRINT then
		print("End of UpdateData for TopPanel.lua")
	end
	--end Paz add
	
	end
end

function OnTopPanelDirty()
	--Paz add
	--if 0 < Game.GetAIAutoPlay() then return end
	--end Paz add
	UpdateData();
end

-------------------------------------------------
-------------------------------------------------
function OnCivilopedia()	
	-- In City View, return to main game
	--if (UI.GetHeadSelectedCity() ~= nil) then
		--Events.SerialEventExitCityScreen();
	--end
	--
	-- opens the Civilopedia without changing its current state
	Events.SearchForPediaEntry("");
end
Controls.CivilopediaButton:RegisterCallback( Mouse.eLClick, OnCivilopedia );


-------------------------------------------------
-------------------------------------------------
function OnMenu()
	
	-- In City View, return to main game
	if (UI.GetHeadSelectedCity() ~= nil) then
		Events.SerialEventExitCityScreen();
		--UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION);
	-- In Main View, open Menu Popup
	else
	    UIManager:QueuePopup( LookUpControl( "/InGame/GameMenu" ), PopupPriority.InGameMenu );
	end
end
Controls.MenuButton:RegisterCallback( Mouse.eLClick, OnMenu );


-------------------------------------------------
-------------------------------------------------
function OnCultureClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY } );

end
Controls.CultureString:RegisterCallback( Mouse.eLClick, OnCultureClicked );


-------------------------------------------------
-------------------------------------------------
function OnTechClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_TECH_TREE, Data2 = -1} );

end
Controls.SciencePerTurn:RegisterCallback( Mouse.eLClick, OnTechClicked );

-------------------------------------------------
-------------------------------------------------
function OnFaithClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_RELIGION_OVERVIEW } );

end
Controls.FaithString:RegisterCallback( Mouse.eLClick, OnFaithClicked );

-------------------------------------------------
-------------------------------------------------
function OnTradeRouteClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_TRADE_ROUTE_OVERVIEW } );

end
Controls.InternationalTradeRoutes:RegisterCallback( Mouse.eLClick, OnTradeRouteClicked );



-------------------------------------------------
-- TOOLTIPS
-------------------------------------------------


-- Tooltip init
function DoInitTooltips()
	Controls.SciencePerTurn:SetToolTipCallback( ScienceTipHandler );
	Controls.GoldPerTurn:SetToolTipCallback( GoldTipHandler );
	Controls.HappinessString:SetToolTipCallback( HappinessTipHandler );
	Controls.GoldenAgeString:SetToolTipCallback( GoldenAgeTipHandler );
	Controls.CultureString:SetToolTipCallback( CultureTipHandler );
	Controls.FaithString:SetToolTipCallback( FaithTipHandler );
	Controls.GreatPeopleString:SetToolTipCallback( GreatPeopleTipHandler );		--Paz added
	Controls.ResourceString:SetToolTipCallback( ResourcesTipHandler );
	Controls.InternationalTradeRoutes:SetToolTipCallback( InternationalTradeRoutesTipHandler );
end

-- Science Tooltip
local tipControlTable = {};
TTManager:GetTypeControlTable( "TooltipTypeTopPanel", tipControlTable );
function ScienceTipHandler( control )

	local strText = "";
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)) then
		strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_SCIENCE_OFF_TOOLTIP");
	else
	
		local iPlayerID = Game.GetActivePlayer();
		local pPlayer = Players[iPlayerID];
		local pTeam = Teams[pPlayer:GetTeam()];
		local pCity = UI.GetHeadSelectedCity();
	
		local iSciencePerTurn = pPlayer:GetScience();
	
		-- Science
		if (not OptionsManager.IsNoBasicHelp()) then
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE", iSciencePerTurn);
		
			if (pPlayer:GetNumCities() > 0) then
				strText = strText .. "[NEWLINE][NEWLINE]";
			end
		end
	
		local bFirstEntry = true;
	
		-- Science LOSS from Budget Deficits
		local iScienceFromBudgetDeficit = pPlayer:GetScienceFromBudgetDeficitTimes100();
		if (iScienceFromBudgetDeficit ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end

			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_BUDGET_DEFICIT", iScienceFromBudgetDeficit / 100);
			strText = strText .. "[NEWLINE]";
		end
	
		-- Science from Cities
		local iScienceFromCities = pPlayer:GetScienceFromCitiesTimes100();
		if (iScienceFromCities ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end

			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_CITIES", iScienceFromCities / 100);
		end
	
		-- Science from Other Players
		local iScienceFromOtherPlayers = pPlayer:GetScienceFromOtherPlayersTimes100();
		if (iScienceFromOtherPlayers ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end

			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_MINORS", iScienceFromOtherPlayers / 100);
		end
	
		-- Science from Happiness
		local iScienceFromHappiness = pPlayer:GetScienceFromHappinessTimes100();
		if (iScienceFromHappiness ~= 0) then
			
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end
	
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_HAPPINESS", iScienceFromHappiness / 100);
		end
	
		-- Science from Research Agreements
		local iScienceFromRAs = pPlayer:GetScienceFromResearchAgreementsTimes100();
		if (iScienceFromRAs ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end
	
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_RESEARCH_AGREEMENTS", iScienceFromRAs / 100);
		end

		--Paz add
		--Science from Leader
		local iScienceFromLeader = pPlayer:GetLeaderYieldBoost(GameInfoTypes.YIELD_SCIENCE) * (iScienceFromOtherPlayers + iScienceFromHappiness + iScienceFromRAs) / 100
		if (iScienceFromLeader ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end
	
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_EA_TP_SCIENCE_FROM_LEADER", iScienceFromLeader / 100);
		end

		--Knowledge Maintenance blurb
		local civInsert = ""
		if MapModData.KM_PER_TECH_PER_CITIZEN then
			local civName = Locale.Lookup(PreGame.GetCivilizationShortDescription(iPlayerID))
			local baseKMString = string.format("%.3f", MapModData.KM_PER_TECH_PER_CITIZEN)
			civInsert = " " .. Locale.Lookup("TXT_KEY_EA_TP_KNOWLEDGE_MAINT_ADJUSMENT_INSERT", civName, MapModData.KM_PER_TECH_PER_CITIZEN)
		end
		local kmPerTechPerCitizen = math.floor(1000 * MapModData.kmPerTechPerCitizen + 0.5) / 1000
		local kmBlurb = Locale.Lookup("TXT_KEY_EA_TP_KNOWLEDGE_MAINT", MapModData.knowlMaint, MapModData.techCount, MapModData.totalPopulationForKM, kmPerTechPerCitizen, civInsert)

		strText = strText .. "[NEWLINE][NEWLINE]" .. kmBlurb
		--end Paz add

	end
	
	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- Gold Tooltip
function GoldTipHandler( control )

	local strText = "";
	local iPlayerID = Game.GetActivePlayer();
	local pPlayer = Players[iPlayerID];
	local pTeam = Teams[pPlayer:GetTeam()];
	local pCity = UI.GetHeadSelectedCity();
	
	local iTotalGold = pPlayer:GetGold();

	local iGoldPerTurnFromOtherPlayers = pPlayer:GetGoldPerTurnFromDiplomacy();
	local iGoldPerTurnToOtherPlayers = 0;
	if (iGoldPerTurnFromOtherPlayers < 0) then
		iGoldPerTurnToOtherPlayers = -iGoldPerTurnFromOtherPlayers;
		iGoldPerTurnFromOtherPlayers = 0;
	end

	--Paz add
	local iGoldFromMercenaries = MapModData.mercenaryNet
	local iGoldForMercenaries = 0
	if iGoldFromMercenaries < 0 then
		iGoldForMercenaries = -iGoldFromMercenaries
		iGoldFromMercenaries = 0
	end
	--end Paz add
	
	local iGoldPerTurnFromReligion = pPlayer:GetGoldPerTurnFromReligion();

	local fGoldPerTurnFromCities = pPlayer:GetGoldFromCitiesTimes100() / 100;
	local fCityConnectionGold = pPlayer:GetCityConnectionGoldTimes100() / 100;

	--[[Paz modified below
	local fTotalIncome = fGoldPerTurnFromCities + iGoldPerTurnFromOtherPlayers + fCityConnectionGold + iGoldPerTurnFromReligion;
	]]
	local fNonCityLeaderGold = pPlayer:GetLeaderYieldBoost(GameInfoTypes.YIELD_GOLD) * (iGoldPerTurnFromOtherPlayers + fCityConnectionGold + iGoldPerTurnFromReligion) / 100

	local fTotalIncome = fGoldPerTurnFromCities + iGoldPerTurnFromOtherPlayers + fCityConnectionGold + iGoldPerTurnFromReligion + fNonCityLeaderGold + iGoldFromMercenaries;	--Paz added iGoldFromMercenaries
	--end Paz modified

	if (not OptionsManager.IsNoBasicHelp()) then
		strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_AVAILABLE_GOLD", iTotalGold);
		strText = strText .. "[NEWLINE][NEWLINE]";
	end
	
	strText = strText .. "[COLOR:150:255:150:255]";
	strText = strText .. "+" .. Locale.ConvertTextKey("TXT_KEY_TP_TOTAL_INCOME", math.floor(fTotalIncome));
	strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_CITY_OUTPUT", fGoldPerTurnFromCities);
	strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_FROM_TR", math.floor(fCityConnectionGold));
	if (iGoldPerTurnFromOtherPlayers > 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_FROM_OTHERS", iGoldPerTurnFromOtherPlayers);
	end
	--Paz add
	if iGoldFromMercenaries > 0 then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_GOLD_FROM_MERCENARIES", iGoldFromMercenaries);
	end
	--end Paz add
	if (iGoldPerTurnFromReligion > 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_FROM_RELIGION", iGoldPerTurnFromReligion);
	end
	--Paz add
	if fNonCityLeaderGold > 0 then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_GOLD_FROM_LEADER", fNonCityLeaderGold);
	end
	--end Paz add
	strText = strText .. "[/COLOR]";
	
	local iUnitCost = pPlayer:CalculateUnitCost();
	local iUnitSupply = pPlayer:CalculateUnitSupply();
	local iBuildingMaintenance = pPlayer:GetBuildingGoldMaintenance();
	local iImprovementMaintenance = pPlayer:GetImprovementGoldMaintenance();
	local iTotalExpenses = iUnitCost + iUnitSupply + iBuildingMaintenance + iImprovementMaintenance + iGoldPerTurnToOtherPlayers;
	
	strText = strText .. "[NEWLINE]";
	strText = strText .. "[COLOR:255:150:150:255]";
	strText = strText .. "[NEWLINE]-" .. Locale.ConvertTextKey("TXT_KEY_TP_TOTAL_EXPENSES", iTotalExpenses);
	if (iUnitCost ~= 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNIT_MAINT", iUnitCost);
	end
	if (iUnitSupply ~= 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_UNIT_SUPPLY", iUnitSupply);
	end
	--Paz add
	if iGoldForMercenaries > 0 then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_GOLD_FOR_MERCENARIES", iGoldForMercenaries);
	end
	--end Paz add
	if (iBuildingMaintenance ~= 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_BUILDING_MAINT", iBuildingMaintenance);
	end

	if (iImprovementMaintenance ~= 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_TILE_MAINT", iImprovementMaintenance);
	end
	if (iGoldPerTurnToOtherPlayers > 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_TO_OTHERS", iGoldPerTurnToOtherPlayers);
	end
	strText = strText .. "[/COLOR]";
	
	if (fTotalIncome + iTotalGold < 0) then
		strText = strText .. "[NEWLINE][COLOR:255:60:60:255]" .. Locale.ConvertTextKey("TXT_KEY_TP_LOSING_SCIENCE_FROM_DEFICIT") .. "[/COLOR]";
	end
	
	-- Basic explanation of Happiness
	if (not OptionsManager.IsNoBasicHelp()) then
		strText = strText .. "[NEWLINE][NEWLINE]";
		strText = strText ..  Locale.ConvertTextKey("TXT_KEY_TP_GOLD_EXPLANATION");
	end
	
	--Controls.GoldPerTurn:SetToolTipString(strText);
	
	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- Happiness Tooltip
function HappinessTipHandler( control )

	local strText;
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS)) then
		strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_HAPPINESS_OFF_TOOLTIP");
	else
		local iPlayerID = Game.GetActivePlayer();
		local pPlayer = Players[iPlayerID];
		local pTeam = Teams[pPlayer:GetTeam()];
		local pCity = UI.GetHeadSelectedCity();
	
		local iHappiness = pPlayer:GetExcessHappiness();

		if (not pPlayer:IsEmpireUnhappy()) then
			strText = Locale.ConvertTextKey("TXT_KEY_TP_TOTAL_HAPPINESS", iHappiness);
		elseif (pPlayer:IsEmpireVeryUnhappy()) then
			strText = Locale.ConvertTextKey("TXT_KEY_TP_TOTAL_UNHAPPINESS", "[ICON_HAPPINESS_4]", -iHappiness);
		else
			strText = Locale.ConvertTextKey("TXT_KEY_TP_TOTAL_UNHAPPINESS", "[ICON_HAPPINESS_3]", -iHappiness);
		end

		--Paz add: 
		local eaPlayer = gT.gPlayers[iPlayerID]
		
		
		--these don't change totals, but are used to move particular sources around (e.g., from hidden buildings to proper mod cause)
		local iRacialDisharmony = 2 * pPlayer:CountNumBuildings(GameInfoTypes.BUILDING_RACIAL_DISHARMONY)
		local iAhrimansVaultUnhappiness = (eaPlayer and eaPlayer.bHasDiscoveredAhrimansVault) and 2 or 0
		--end Paz add
	
		local iPoliciesHappiness = pPlayer:GetHappinessFromPolicies();
		local iResourcesHappiness = pPlayer:GetHappinessFromResources();
		local iExtraLuxuryHappiness = pPlayer:GetExtraHappinessPerLuxury();
		local iCityHappiness = pPlayer:GetHappinessFromCities();
		local iBuildingHappiness = pPlayer:GetHappinessFromBuildings() + iRacialDisharmony;	--Paz: iRacialDisharmony
		local iTradeRouteHappiness = pPlayer:GetHappinessFromTradeRoutes();
		local iReligionHappiness = pPlayer:GetHappinessFromReligion();
		local iNaturalWonderHappiness = pPlayer:GetHappinessFromNaturalWonders() + iAhrimansVaultUnhappiness;		--Paz: iAhrimansVaultUnhappiness
		local iExtraHappinessPerCity = pPlayer:GetExtraHappinessPerCity() * pPlayer:GetNumCities();
		local iMinorCivHappiness = pPlayer:GetHappinessFromMinorCivs();
		--Paz add
		local iHavamalEpic = (gT.gEpics[EA_EPIC_HAVAMAL] and gT.gEpics[EA_EPIC_HAVAMAL].iPlayer == iPlayerID) and gT.gEpics[EA_EPIC_HAVAMAL].mod or 0
		--end Paz add
	
		local iHandicapHappiness = pPlayer:GetHappiness() - iPoliciesHappiness - iResourcesHappiness - iCityHappiness - iBuildingHappiness - iTradeRouteHappiness - iReligionHappiness - iNaturalWonderHappiness - iMinorCivHappiness - iExtraHappinessPerCity;
		--Paz add
		iHandicapHappiness = iHandicapHappiness + iRacialDisharmony + iAhrimansVaultUnhappiness - iHavamalEpic
		--end Paz add

		if (pPlayer:IsEmpireVeryUnhappy()) then
		
			if (pPlayer:IsEmpireSuperUnhappy()) then
				strText = strText .. "[NEWLINE][NEWLINE]";
				strText = strText .. "[COLOR:255:60:60:255]" .. Locale.ConvertTextKey("TXT_KEY_TP_EMPIRE_SUPER_UNHAPPY") .. "[/COLOR]";
			end
		
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText .. "[COLOR:255:60:60:255]" .. Locale.ConvertTextKey("TXT_KEY_TP_EMPIRE_VERY_UNHAPPY") .. "[/COLOR]";
		elseif (pPlayer:IsEmpireUnhappy()) then
		
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText .. "[COLOR:255:60:60:255]" .. Locale.ConvertTextKey("TXT_KEY_TP_EMPIRE_UNHAPPY") .. "[/COLOR]";
		end
	
		local iTotalHappiness = iPoliciesHappiness + iResourcesHappiness + iCityHappiness + iBuildingHappiness + iMinorCivHappiness + iHandicapHappiness + iTradeRouteHappiness + iReligionHappiness + iNaturalWonderHappiness + iExtraHappinessPerCity;
	
		strText = strText .. "[NEWLINE][NEWLINE]";
		strText = strText .. "[COLOR:150:255:150:255]";
		strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_SOURCES", iTotalHappiness);
	
		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_FROM_RESOURCES", iResourcesHappiness);
	
		-- Individual Resource Info
	
		local iBaseHappinessFromResources = 0;
		local iNumHappinessResources = 0;

		for resource in GameInfo.Resources() do
			local resourceID = resource.ID;
			local iHappiness = pPlayer:GetHappinessFromLuxury(resourceID);
			if (iHappiness > 0) then
				strText = strText .. "[NEWLINE]";
				strText = strText .. "          +" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_EACH_RESOURCE", iHappiness, resource.IconString, resource.Description);
				iNumHappinessResources = iNumHappinessResources + 1;
				iBaseHappinessFromResources = iBaseHappinessFromResources + resource.Happiness;
			end
		end
	
		-- Happiness from Luxury Variety
		local iHappinessFromExtraResources = pPlayer:GetHappinessFromResourceVariety();
		if (iHappinessFromExtraResources > 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "          +" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_RESOURCE_VARIETY", iHappinessFromExtraResources);
		end
	
		-- Extra Happiness from each Luxury
		if (iExtraLuxuryHappiness >= 1) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "          +" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_EXTRA_PER_RESOURCE", iExtraLuxuryHappiness, iNumHappinessResources);
		end
	
		-- Misc Happiness from Resources
		local iMiscHappiness = iResourcesHappiness - iBaseHappinessFromResources - iHappinessFromExtraResources - (iExtraLuxuryHappiness * iNumHappinessResources);
		if (iMiscHappiness > 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "          +" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_OTHER_SOURCES", iMiscHappiness);
		end
	
		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_CITIES", iCityHappiness);
		if (iPoliciesHappiness >= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_POLICIES", iPoliciesHappiness);
		end
		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_BUILDINGS", iBuildingHappiness);
		if (iTradeRouteHappiness ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_CONNECTED_CITIES", iTradeRouteHappiness);
		end
		if (iReligionHappiness ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_STATE_RELIGION", iReligionHappiness);
		end
		if (iNaturalWonderHappiness ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_NATURAL_WONDERS", iNaturalWonderHappiness);
		end
		if (iExtraHappinessPerCity ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_CITY_COUNT", iExtraHappinessPerCity);
		end
		if (iMinorCivHappiness ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_CITY_STATE_FRIENDSHIP", iMinorCivHappiness);
		end
		--Paz add
		if (iHavamalEpic ~= 0) then
			strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_UNHAPPINESS_FROM_HAVAMAL_EPIC", iHavamalEpic);
		end
		--end Paz add

		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_DIFFICULTY_LEVEL", iHandicapHappiness);
		strText = strText .. "[/COLOR]";
	
		-- Unhappiness
		local iTotalUnhappiness = pPlayer:GetUnhappiness()  + iRacialDisharmony + iAhrimansVaultUnhappiness;	--Paz added modifiers
		local iUnhappinessFromUnits = Locale.ToNumber( pPlayer:GetUnhappinessFromUnits() / 100, "#.##" );
		local iUnhappinessFromCityCount = Locale.ToNumber(pPlayer:GetUnhappinessFromCityCount() / 100 + iRacialDisharmony, "#.##" );	--Paz:  - iRacialDisharmony
		local iUnhappinessFromCapturedCityCount = Locale.ToNumber( pPlayer:GetUnhappinessFromCapturedCityCount() / 100, "#.##" );
		
		local iUnhappinessFromPupetCities = pPlayer:GetUnhappinessFromPuppetCityPopulation();
		local unhappinessFromSpecialists = pPlayer:GetUnhappinessFromCitySpecialists();
		local unhappinessFromPop = pPlayer:GetUnhappinessFromCityPopulation() - unhappinessFromSpecialists - iUnhappinessFromPupetCities;
			
		local iUnhappinessFromPop = Locale.ToNumber( unhappinessFromPop / 100, "#.##" );
		local iUnhappinessFromOccupiedCities = Locale.ToNumber( pPlayer:GetUnhappinessFromOccupiedCities() / 100, "#.##" );
		--Paz add
		local iUnhappinessFromArmageddon = (gT.gWorld.armageddonStage < 3) and 0 or gT.gWorld.armageddonSap
		--end Paz add

		strText = strText .. "[NEWLINE][NEWLINE]";
		strText = strText .. "[COLOR:255:150:150:255]";
		strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_TOTAL", iTotalUnhappiness);
		--Paz disabled: strText = strText .. "[NEWLINE]";

		--Paz: put iUnhappinessFromCityCount in if test and marked as BUG (mod should never have any)
		if iUnhappinessFromCityCount ~= "0" then
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_CITY_COUNT", iUnhappinessFromCityCount);
			strText = strText .. " THIS IS A MOD BUG: No unhappiness from cities"
		end
		if (iUnhappinessFromCapturedCityCount ~= "0") then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_CAPTURED_CITY_COUNT", iUnhappinessFromCapturedCityCount);
		end
		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_POPULATION", iUnhappinessFromPop);
		
		if(iUnhappinessFromPupetCities > 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_PUPPET_CITIES", iUnhappinessFromPupetCities / 100);
		end
		
		if(unhappinessFromSpecialists > 0) then
			strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_SPECIALISTS", unhappinessFromSpecialists / 100);
		end
		
		if (iUnhappinessFromOccupiedCities ~= "0") then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_OCCUPIED_POPULATION", iUnhappinessFromOccupiedCities);
		end

		--Paz add: Ahrimans Vault is the only NW that gives Unhappiness; we show here as negative so that we can show all positives above
		if(iAhrimansVaultUnhappiness > 0) then
			strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_UNHAPPINESS_FROM_NATURAL_WONDERS", iAhrimansVaultUnhappiness);
		end	
		if(iUnhappinessFromArmageddon > 0) then
			strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_UNHAPPINESS_FROM_ARMAGEDDON", iUnhappinessFromArmageddon);
		end	
		
		--end Paz add

		if (iUnhappinessFromUnits ~= "0") then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_UNITS", iUnhappinessFromUnits);
		end
		if (iPoliciesHappiness < 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_POLICIES", iPoliciesHappiness);
		end		
		strText = strText .. "[/COLOR]";
	
		-- Basic explanation of Happiness
		if (not OptionsManager.IsNoBasicHelp()) then
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText ..  Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_EXPLANATION");
		end
	end
	
	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- Golden Age Tooltip
function GoldenAgeTipHandler( control )

	local strText;
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS)) then
		strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_HAPPINESS_OFF_TOOLTIP");
	else
		local iPlayerID = Game.GetActivePlayer();
		local pPlayer = Players[iPlayerID];
		local pTeam = Teams[pPlayer:GetTeam()];
		local pCity = UI.GetHeadSelectedCity();
	
		if (pPlayer:GetGoldenAgeTurns() > 0) then
			strText = Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_NOW", pPlayer:GetGoldenAgeTurns());
		else
			local iHappiness = pPlayer:GetExcessHappiness();

			strText = Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_PROGRESS", pPlayer:GetGoldenAgeProgressMeter(), pPlayer:GetGoldenAgeProgressThreshold());
			strText = strText .. "[NEWLINE]";
		
			if (iHappiness >= 0) then
				strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_ADDITION", iHappiness);
			else
				strText = strText .. "[COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_LOSS", -iHappiness) .. "[ENDCOLOR]";
			end
		end
	
		strText = strText .. "[NEWLINE][NEWLINE]";
		if (pPlayer:IsGoldenAgeCultureBonusDisabled()) then
			strText = strText ..  Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_EFFECT_NO_CULTURE");		
		else
			strText = strText ..  Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_EFFECT");		
		end
	end
	
	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- Culture Tooltip
function CultureTipHandler( control )

	local strText = "";
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES)) then
		strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_POLICIES_OFF_TOOLTIP");
	else
	
		local iPlayerID = Game.GetActivePlayer();
		local pPlayer = Players[iPlayerID];
		
		--[[Paz disabled
	    local iTurns;
		local iCultureNeeded = pPlayer:GetNextPolicyCost() - pPlayer:GetJONSCulture();
	    if (iCultureNeeded <= 0) then
			iTurns = 0;
		else
			if (pPlayer:GetTotalJONSCulturePerTurn() == 0) then
				iTurns = "?";
			else
				iTurns = iCultureNeeded / pPlayer:GetTotalJONSCulturePerTurn();
				iTurns = iTurns + 1;
				iTurns = math.floor(iTurns);
			end
	    end
		strText = strText .. Locale.ConvertTextKey("TXT_KEY_NEXT_POLICY_TURN_LABEL", iTurns);
	
		if (not OptionsManager.IsNoBasicHelp()) then
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_ACCUMULATED", pPlayer:GetJONSCulture());
			strText = strText .. "[NEWLINE]";
		
			if (pPlayer:GetNextPolicyCost() > 0) then
				strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_NEXT_POLICY", pPlayer:GetNextPolicyCost());
			end
		end
		]]
		--Paz add
		local eaPlayer = gT.gPlayers[iPlayerID]
		if not eaPlayer then return end
		UpdateCultureLevelInfoForUI(iPlayerID)

		strText = Locale.ConvertTextKey("TXT_KEY_EA_TP_CULTURE_LEVEL", string.format("%.2f", MapModData.cultureLevel)) .. "[NEWLINE][NEWLINE]"
			.. Locale.ConvertTextKey("TXT_KEY_EA_TP_CULTURE_LEVEL_SUMMARY", MapModData.nextCultureLevel, string.format("%+.2f", MapModData.estCultureLevelChange), string.format("%.2f", MapModData.approachingCulturalLevel)) .. "[NEWLINE][NEWLINE]"
			.. Locale.ConvertTextKey("TXT_KEY_EA_TP_CULTURE_GENERATION", MapModData.cultureRate)
		--end Paz add

		local bFirstEntry = true;
		
		-- Culture for Free
		local iCultureForFree = pPlayer:GetJONSCulturePerTurnForFree();
		if (iCultureForFree ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FOR_FREE", iCultureForFree);
		end
	
		-- Culture from Cities
		local iCultureFromCities = pPlayer:GetJONSCulturePerTurnFromCities();
		if (iCultureFromCities ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_CITIES", iCultureFromCities);
		end
	
		-- Culture from Excess Happiness
		local iCultureFromHappiness = pPlayer:GetJONSCulturePerTurnFromExcessHappiness();
		if (iCultureFromHappiness ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_HAPPINESS", iCultureFromHappiness);
		end
	
		-- Culture from Minor Civs
		local iCultureFromMinors = pPlayer:GetCulturePerTurnFromMinorCivs();
		if (iCultureFromMinors ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_MINORS", iCultureFromMinors);
		end

		-- Culture from Religion
		local iCultureFromReligion = pPlayer:GetCulturePerTurnFromReligion();
		if (iCultureFromReligion ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_RELIGION", iCultureFromReligion);
		end

		--Paz add: Culture from Leader
		local iCultureFromLeader = pPlayer:GetLeaderYieldBoost(GameInfoTypes.YIELD_CULTURE) * (iCultureFromHappiness + iCultureForFree + iCultureFromMinors + iCultureFromReligion) / 100
		if (iCultureFromLeader ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_EA_TP_CULTURE_FROM_LEADER", iCultureFromLeader);
		end

		--end Paz add
		
		-- Culture from Golden Age
		local iCultureFromGoldenAge = pPlayer:GetTotalJONSCulturePerTurn() - iCultureForFree - iCultureFromCities - iCultureFromHappiness - iCultureFromMinors - iCultureFromReligion - iCultureFromLeader; --Paz deducted iCultureFromLeader
		if (iCultureFromGoldenAge ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_GOLDEN_AGE", iCultureFromGoldenAge);
		end

		--Paz add: Culture from Wildlands
		local iCultureFromWildlands = eaPlayer.cultureManaFromWildlands or 0
		if (iCultureFromWildlands ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]"
				bFirstEntry = false
			end

			strText = strText .. "[NEWLINE]"
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_EA_TP_CULTURE_FROM_WILDLANDS", iCultureFromWildlands);
		end
		--end Paz add

		-- Let people know that building more cities makes policies harder to get
		--[[Paz disabled
		if (not OptionsManager.IsNoBasicHelp()) then
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_CITY_COST", Game.GetNumCitiesPolicyCostMod());
		end
		]]
	end
	
	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- FaithTooltip
function FaithTipHandler( control )

	local strText = "";

	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
		strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_RELIGION_OFF_TOOLTIP");
	else
	
		local iPlayerID = Game.GetActivePlayer();
		--Paz add
		if not MapModData.fullCivs[iPlayerID] then
			return
		end
		print("FaithTipHandler for TopPanel.lua")
		--end Paz add
		local pPlayer = Players[iPlayerID];

		--Paz disabled: strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_ACCUMULATED", pPlayer:GetFaith());
		--Paz disabled: strText = strText .. "[NEWLINE]";

		--Paz add: almost entirely recoded
		local eaPlayer = gT.gPlayers[iPlayerID]
		if not eaPlayer then return end

		if eaPlayer.bUsesDivineFavor then
			strText = Locale.ConvertTextKey("TXT_KEY_EA_TP_DIVINE_FAVOR", pPlayer:GetFaith())
		else
			strText = Locale.ConvertTextKey("TXT_KEY_EA_TP_MANA", pPlayer:GetFaith())
		end

		if eaPlayer.bIsFallen then
			local consumed = eaPlayer.manaConsumed or 0
			local percentStr
			if consumed == 0 then
				percentStr = "0"
			else
				local percentConsumed = 100 * consumed / MapModData.STARTING_SUM_OF_ALL_MANA
				local decimalPlaces = math.floor(1 - math.log10(percentConsumed))
				decimalPlaces = decimalPlaces < 0 and 0 or decimalPlaces
				percentStr = string.format("%.".. decimalPlaces .. "f", percentConsumed)
			end
			strText = strText .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_MANA_CONSUMED", consumed, percentStr)
		end
		
		local faithFromCities = pPlayer:GetFaithPerTurnFromCities()
		local faithFromGods = pPlayer:GetFaithPerTurnFromMinorCivs()	--game engine only sees this from Gods
		local faithFromReligion = pPlayer:GetFaithPerTurnFromReligion()				--for Azz and Anra only since these use base follower counting mechanism
		local faithFromLeader = pPlayer:GetLeaderYieldBoost(GameInfoTypes.YIELD_FAITH) * (faithFromGods + faithFromReligion) / 100	
		local manaForCultOfLeavesFounder = eaPlayer.manaForCultOfLeavesFounder or 0
		local manaForCultOfAbzuFounder = eaPlayer.manaForCultOfAbzuFounder or 0
		local manaForCultOfAegirFounder = eaPlayer.manaForCultOfAegirFounder or 0
		local manaForCultOfPloutonFounder = eaPlayer.manaForCultOfPloutonFounder or 0
		local manaForCultOfCahraFounder = eaPlayer.manaForCultOfCahraFounder or 0
		local manaForCultOfEponaFounder = eaPlayer.manaForCultOfEponaFounder or 0
		local manaForCultOfBakkheiaFounder = eaPlayer.manaForCultOfBakkheiaFounder or 0
		local manaFromWildlands = eaPlayer.cultureManaFromWildlands or 0
		local faithFromCityStates = MapModData.faithFromCityStates
		local faithFromAzzTribute = MapModData.faithFromAzzTribute
		local faithFromToAhrimanTribute = MapModData.faithFromToAhrimanTribute
		local faithFromGPs = MapModData.faithFromGPs
		local faithFromFinishedPolicyBranches = GetFaithFromPolicyFinisher(pPlayer)
		local faithRate = faithFromCities + faithFromGods + faithFromReligion + faithFromLeader + manaForCultOfLeavesFounder + manaForCultOfAbzuFounder + manaForCultOfAegirFounder + manaForCultOfPloutonFounder + manaForCultOfCahraFounder + manaForCultOfEponaFounder + manaForCultOfBakkheiaFounder + manaFromWildlands + faithFromCityStates + faithFromAzzTribute + faithFromGPs + faithFromFinishedPolicyBranches

		if faithRate + faithFromToAhrimanTribute ~= 0 then
			if eaPlayer.bUsesDivineFavor then
				strText = strText .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_DIVINE_FAVOR_SOURCES", faithRate) .. "[NEWLINE]"
			else
				strText = strText .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_MANA_SOURCES", faithRate) .. "[NEWLINE]"
			end
		end

		if faithFromCities ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_FROM_CITIES", faithFromCities)
		end
	
		if faithFromGods ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_GODS", faithFromGods)
		end
		
		if faithFromReligion ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_FROM_RELIGION", faithFromReligion)
		end	
			
		if faithFromLeader ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_LEADER", faithFromLeader)
		end

		if manaForCultOfLeavesFounder ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_CULT_OF_LEAVES_FOUNDER", manaForCultOfLeavesFounder)
		end

		if manaForCultOfAbzuFounder ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_CULT_OF_ABZU_FOUNDER", manaForCultOfAbzuFounder)
		end

		if manaForCultOfAegirFounder ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_CULT_OF_AEGIR_FOUNDER", manaForCultOfAegirFounder)
		end

		if manaForCultOfPloutonFounder ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_CULT_OF_PLOUTON_FOUNDER", manaForCultOfPloutonFounder)
		end

		if manaForCultOfCahraFounder ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_CULT_OF_CAHRA_FOUNDER", manaForCultOfCahraFounder)
		end

		if manaForCultOfEponaFounder ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_CULT_OF_EPONA_FOUNDER", manaForCultOfEponaFounder)
		end

		if manaForCultOfBakkheiaFounder ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_CULT_OF_BAKKHEIA_FOUNDER", manaForCultOfBakkheiaFounder)
		end

		if manaFromWildlands ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_WILDLANDS", manaFromWildlands)
		end

		if faithFromCityStates ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_FROM_MINORS", faithFromCityStates)
		end
	
		if faithFromAzzTribute ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_AZZ_TRIBUTE", faithFromAzzTribute)
		end	

		if faithFromToAhrimanTribute ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_AHRIMAN_TRIBUTE", faithFromToAhrimanTribute)
		end	

		if faithFromGPs ~= 0 then
			strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_GPS", faithFromGPs)
		end	

		if faithFromFinishedPolicyBranches ~= 0 then
			local branchName, branchName2
			if pPlayer:HasPolicy(GameInfoTypes.POLICY_PANTHEISM_FINISHER) then
				branchName = Locale.ConvertTextKey("TXT_KEY_EA_POLICY_PANTHEISM")
			elseif pPlayer:HasPolicy(GameInfoTypes.POLICY_THEISM_FINISHER) or pPlayer:HasPolicy(GameInfoTypes.POLICY_ANTI_THEISM_FINISHER) then
				branchName = Locale.ConvertTextKey("TXT_KEY_EA_POLICY_THEISM")
			end
			if pPlayer:HasPolicy(GameInfoTypes.POLICY_ARCANA_FINISHER) then
				if branchName then
					branchName2 = Locale.ConvertTextKey("TXT_KEY_EA_POLICY_ARCANA")
				else
					branchName = Locale.ConvertTextKey("TXT_KEY_EA_POLICY_ARCANA")
				end
			end
			if branchName2 then
				strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_POLICY_BRANCHES", faithFromFinishedPolicyBranches / 2, branchName)
				strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_POLICY_BRANCHES", faithFromFinishedPolicyBranches / 2, branchName2)
			else
				strText = strText .. "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_FROM_POLICY_BRANCHES", faithFromFinishedPolicyBranches, branchName)
			end
		end

		if faithFromToAhrimanTribute ~= 0 then
			strText = strText .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_FAITH_TO_AHRIMAN_TRIBUTE", faithFromToAhrimanTribute)
		end

		--end Paz add
	

		--[[Paz disabled
		-- Faith from Cities
		local iFaithFromCities = pPlayer:GetFaithPerTurnFromCities();
		if (iFaithFromCities ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_FROM_CITIES", iFaithFromCities);
		end
	
		-- Faith from Minor Civs (Paz note: this is really only Gods)
		local iFaithFromMinorCivs = pPlayer:GetFaithPerTurnFromMinorCivs();
		if (iFaithFromMinorCivs ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_FROM_MINORS", iFaithFromMinorCivs);
		end

		-- Faith from Religion
		local iFaithFromReligion = pPlayer:GetFaithPerTurnFromReligion();
		if (iFaithFromReligion ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_FROM_RELIGION", iFaithFromReligion);
		end
		
		if (iFaithFromCities ~= 0 or iFaithFromMinorCivs ~= 0 or iFaithFromReligion ~= 0) then
			strText = strText .. "[NEWLINE]";
		end

		strText = strText .. "[NEWLINE]";

		if (pPlayer:HasCreatedPantheon()) then
			if (Game.GetNumReligionsStillToFound() > 0 or pPlayer:HasCreatedReligion()) then
				if (pPlayer:GetCurrentEra() < GameInfo.Eras["ERA_INDUSTRIAL"].ID) then
					strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_NEXT_PROPHET", pPlayer:GetMinimumFaithNextGreatProphet());
					strText = strText .. "[NEWLINE]";
					strText = strText .. "[NEWLINE]";
				end
			end
		else
			if (pPlayer:CanCreatePantheon(false)) then
				strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_NEXT_PANTHEON", Game.GetMinimumFaithNextPantheon());
				strText = strText .. "[NEWLINE]";
			else
				strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_PANTHEONS_LOCKED");
				strText = strText .. "[NEWLINE]";
			end
			strText = strText .. "[NEWLINE]";
		end

		if (Game.GetNumReligionsStillToFound() < 0) then
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_RELIGIONS_LEFT", 0);
		else
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_RELIGIONS_LEFT", Game.GetNumReligionsStillToFound());
		end

		if (pPlayer:GetCurrentEra() >= GameInfo.Eras["ERA_INDUSTRIAL"].ID) then
		    local bAnyFound = false;
			strText = strText .. "[NEWLINE]";		
			strText = strText .. "[NEWLINE]";		
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_NEXT_GREAT_PERSON", pPlayer:GetMinimumFaithNextGreatProphet());	
			for info in GameInfo.Units{Special = "SPECIALUNIT_PEOPLE"} do
				if (info.ID == GameInfo.Units["UNIT_MERCHANT"].ID and pPlayer:IsPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_COMMERCE"].ID) and not pPlayer:IsPolicyBranchBlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_COMMERCE"].ID)) then	
					strText = strText .. "[NEWLINE]";
					strText = strText .. "[ICON_BULLET]" .. Locale.ConvertTextKey(info.Description);
					bAnyFound = true;
				end
				if (info.ID == GameInfo.Units["UNIT_SCIENTIST"].ID and pPlayer:IsPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_RATIONALISM"].ID) and not pPlayer:IsPolicyBranchBlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_RATIONALISM"].ID)) then	
					strText = strText .. "[NEWLINE]";
					strText = strText .. "[ICON_BULLET]" .. Locale.ConvertTextKey(info.Description);
					bAnyFound = true;
				end
				if (info.ID == GameInfo.Units["UNIT_ARTIST"].ID and pPlayer:IsPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_FREEDOM"].ID) and not pPlayer:IsPolicyBranchBlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_FREEDOM"].ID)) then	
					strText = strText .. "[NEWLINE]";
					strText = strText .. "[ICON_BULLET]" .. Locale.ConvertTextKey(info.Description);
					bAnyFound = true;
				end
				if (info.ID == GameInfo.Units["UNIT_GREAT_GENERAL"].ID and pPlayer:IsPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_AUTOCRACY"].ID) and not pPlayer:IsPolicyBranchBlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_AUTOCRACY"].ID)) then	
					strText = strText .. "[NEWLINE]";
					strText = strText .. "[ICON_BULLET]" .. Locale.ConvertTextKey(info.Description);
					bAnyFound = true;
				end
				if (info.ID == GameInfo.Units["UNIT_GREAT_ADMIRAL"].ID and pPlayer:IsPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_AUTOCRACY"].ID) and not pPlayer:IsPolicyBranchBlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_AUTOCRACY"].ID)) then	
					strText = strText .. "[NEWLINE]";
					strText = strText .. "[ICON_BULLET]" .. Locale.ConvertTextKey(info.Description);
					bAnyFound = true;
				end
				if (info.ID == GameInfo.Units["UNIT_ENGINEER"].ID and pPlayer:IsPolicyBranchUnlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_ORDER"].ID) and not pPlayer:IsPolicyBranchBlocked(GameInfo.PolicyBranchTypes["POLICY_BRANCH_ORDER"].ID)) then	
					strText = strText .. "[NEWLINE]";
					strText = strText .. "[ICON_BULLET]" .. Locale.ConvertTextKey(info.Description);
					bAnyFound = true;
				end
			end
			if (not bAnyFound) then
				strText = strText .. "[NEWLINE]";
				strText = strText .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_RO_YR_NO_GREAT_PEOPLE");
			end
		end
		]]
	end

	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

--Paz add: Great People Tooltip
local gpClassTable = {"Engineer", "Merchant", "Sage", "Artist", "Warrior", "Devout", "Thaumaturge"}
local numberGPClasses = #gpClassTable


function GreatPeopleTipHandler(control)
	local strText
	local iPlayer = Game.GetActivePlayer()
	local player = Players[iPlayer]
	local eaPlayer = gT.gPlayers[iPlayer]
	if not eaPlayer then return end

	if eaPlayer.eaCivNameID then
		local chance = CalculateGPSpawnChance(iPlayer)
		strText = Locale.ConvertTextKey("TXT_KEY_EA_TP_GREAT_PEOPLE", chance/10, MapModData.numberGreatPeople, MapModData.totalGreatPersonPoints)
	else
		strText = Locale.ConvertTextKey("TXT_KEY_EA_TP_GREAT_PEOPLE_NO_NAME")
	end
	strText = strText .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_EA_TP_GREAT_PEOPLE_POINTS").. "[NEWLINE]"
	
	for i = 1, numberGPClasses do
		local points = eaPlayer.classPoints[i]
		local class = gpClassTable[i]
		local classTxt = Locale.ConvertTextKey(MapModData.GP_TXT_KEYS[class])
		strText = strText .. "[NEWLINE] [ICON_BULLET][COLOR_POSITIVE_TEXT]" .. points .. "[ENDCOLOR] : " .. classTxt
		if points > 0 then
			local subclass = PickSubclassForSpawnedClass(iPlayer, class)	--nil if non-subclass will spawn
			if subclass then
				local subclassTxt = Locale.ConvertTextKey(MapModData.GP_TXT_KEYS[subclass])
				strText = strText .. " (" .. subclassTxt .. ")"
			end
		end
	end

	tipControlTable.TooltipLabel:SetText( strText )
	tipControlTable.TopPanelMouseover:SetHide(false)
    tipControlTable.TopPanelMouseover:DoAutoSize()
end
--end Paz add


-- Resources Tooltip
function ResourcesTipHandler( control )

	local strText;
	local iPlayerID = Game.GetActivePlayer();
	local pPlayer = Players[iPlayerID];
	local pTeam = Teams[pPlayer:GetTeam()];
	local pCity = UI.GetHeadSelectedCity();
	
	strText = "";
	
	local pResource;
	local bShowResource;
	local bThisIsFirstResourceShown = true;
	local iNumAvailable;
	local iNumUsed;
	local iNumTotal;
	
	for pResource in GameInfo.Resources() do
		local iResourceLoop = pResource.ID;
		
		if (Game.GetResourceUsageType(iResourceLoop) == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC) then
			
			bShowResource = false;
			
			if (pTeam:GetTeamTechs():HasTech(GameInfoTypes[pResource.TechReveal])) then
				if (pTeam:GetTeamTechs():HasTech(GameInfoTypes[pResource.TechCityTrade])) then
					bShowResource = true;
				end
			end
			
			if (bShowResource) then
				iNumAvailable = pPlayer:GetNumResourceAvailable(iResourceLoop, true);
				iNumUsed = pPlayer:GetNumResourceUsed(iResourceLoop);
				iNumTotal = pPlayer:GetNumResourceTotal(iResourceLoop, true);
				
				-- Add newline to the front of all entries that AREN'T the first
				if (bThisIsFirstResourceShown) then
					strText = "";
					bThisIsFirstResourceShown = false;
				else
					strText = strText .. "[NEWLINE]";
				end
				
				strText = strText .. iNumAvailable .. " " .. pResource.IconString .. " " .. Locale.ConvertTextKey(pResource.Description);
				
				-- Details
				if (iNumUsed ~= 0 or iNumTotal ~= 0) then
					strText = strText .. ": ";
					strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_RESOURCE_INFO", iNumTotal, iNumUsed);
				end
				
			end
		end
	end
	
	print(strText);
	if(strText ~= "") then
		tipControlTable.TopPanelMouseover:SetHide(false);
		tipControlTable.TooltipLabel:SetText( strText );
	else
		tipControlTable.TopPanelMouseover:SetHide(true);
	end
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- International Trade Route Tooltip
function InternationalTradeRoutesTipHandler( control )

	local iPlayerID = Game.GetActivePlayer();
	local pPlayer = Players[iPlayerID];
	
	local strTT = "";
	
	local iNumLandTradeUnitsAvail = pPlayer:GetNumAvailableTradeUnits(DomainTypes.DOMAIN_LAND);
	if (iNumLandTradeUnitsAvail > 0) then
		local iTradeUnitType = pPlayer:GetTradeUnitType(DomainTypes.DOMAIN_LAND);
		local strUnusedTradeUnitWarning = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_INTERNATIONAL_TRADE_ROUTES_TT_UNASSIGNED", iNumLandTradeUnitsAvail, GameInfo.Units[iTradeUnitType].Description);
		strTT = strTT .. strUnusedTradeUnitWarning;
	end
	
	local iNumSeaTradeUnitsAvail = pPlayer:GetNumAvailableTradeUnits(DomainTypes.DOMAIN_SEA);
	if (iNumSeaTradeUnitsAvail > 0) then
		local iTradeUnitType = pPlayer:GetTradeUnitType(DomainTypes.DOMAIN_SEA);
		local strUnusedTradeUnitWarning = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_INTERNATIONAL_TRADE_ROUTES_TT_UNASSIGNED", iNumLandTradeUnitsAvail, GameInfo.Units[iTradeUnitType].Description);	
		strTT = strTT .. strUnusedTradeUnitWarning;
	end
	
	if (strTT ~= "") then
		strTT = strTT .. "[NEWLINE]";
	end
	
	local iUsedTradeRoutes = pPlayer:GetNumInternationalTradeRoutesUsed();
	local iAvailableTradeRoutes = pPlayer:GetNumInternationalTradeRoutesAvailable();
	
	local strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_INTERNATIONAL_TRADE_ROUTES_TT", iUsedTradeRoutes, iAvailableTradeRoutes);
	strTT = strTT .. strText;
	
	local strYourTradeRoutes = pPlayer:GetTradeYourRoutesTTString();
	if (strYourTradeRoutes ~= "") then
		strTT = strTT .. "[NEWLINE][NEWLINE]"
		strTT = strTT .. Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_ITR_ESTABLISHED_BY_PLAYER_TT");
		strTT = strTT .. "[NEWLINE]";
		strTT = strTT .. strYourTradeRoutes;
	end

	local strToYouTradeRoutes = pPlayer:GetTradeToYouRoutesTTString();
	if (strToYouTradeRoutes ~= "") then
		strTT = strTT .. "[NEWLINE][NEWLINE]"
		strTT = strTT .. Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_ITR_ESTABLISHED_BY_OTHER_TT");
		strTT = strTT .. "[NEWLINE]";
		strTT = strTT .. strToYouTradeRoutes;
	end
	
	--print(strText);
	if(strText ~= "") then
		tipControlTable.TopPanelMouseover:SetHide(false);
		tipControlTable.TooltipLabel:SetText( strTT );
	else
		tipControlTable.TopPanelMouseover:SetHide(true);
	end
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
end


-------------------------------------------------
-- On Top Panel mouseover exited
-------------------------------------------------
--function HelpClose()
	---- Hide the help text box
	--Controls.HelpTextBox:SetHide( true );
--end


-- Register Events
Events.SerialEventGameDataDirty.Add(OnTopPanelDirty);
Events.SerialEventTurnTimerDirty.Add(OnTopPanelDirty);
Events.SerialEventCityInfoDirty.Add(OnTopPanelDirty);
LuaEvents.TopPanelInfoDirty.Add(OnTopPanelDirty)		--Paz added

-- Update data at initialization
UpdateData();
DoInitTooltips();