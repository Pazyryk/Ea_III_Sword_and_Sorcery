-------------------------------------------------
-- City List
-------------------------------------------------
include( "IconSupport" );
include( "SupportFunctions"  );
include( "InstanceManager" );
include( "InfoTooltipInclude" );
include( "CityStateStatusHelper" );

--Paz add
include("EaTextUtils.lua")
if not MapModData.gT then
	MapModData.gT = {}
end
local gT = MapModData.gT
MapModData.playerType = MapModData.playerType or {}
local playerType =	MapModData.playerType
--end Paz add

local m_PlayerTable = Matchmaking.GetPlayerList();
local m_PlayerNames = {};
for i = 1, #m_PlayerTable do
    m_PlayerNames[ m_PlayerTable[i].playerID ] = m_PlayerTable[i].playerName;
end

local g_LeaderButtonIM = InstanceManager:new( "LeaderButtonInstance", "LeaderButton", Controls.MajorStack );
local g_MinorCivButtonIM = InstanceManager:new( "CityStateInstance", "MinorButton", Controls.MinorStack );
local g_GodCivButtonIM = InstanceManager:new( "GodInstance", "GodButton", Controls.GodStack );					--Paz add


local g_iPlayer = Game.GetActivePlayer();
local g_pPlayer = Players[ g_iPlayer ];
local g_iTeam = g_pPlayer:GetTeam();
local g_pTeam = Teams[ g_iTeam ];
local g_WarTarget;

local g_bAlwaysWar = Game.IsOption( GameOptionTypes.GAMEOPTION_ALWAYS_WAR );
local g_bAlwaysPeace = Game.IsOption( GameOptionTypes.GAMEOPTION_ALWAYS_PEACE );
local g_bNoChangeWar = Game.IsOption( GameOptionTypes.GAMEOPTION_NO_CHANGING_WAR_PEACE );


-----------------------------------------------------------------
-- Adjust for resolution
-----------------------------------------------------------------
local TOP_COMPENSATION = Controls.OuterGrid:GetOffsetY();
local PANEL_OFFSET = Controls.ScrollPanel:GetOffsetY() + 48;
local BOTTOM_COMPENSATION = 226;
local _, screenY = UIManager:GetScreenSizeVal();
local MAX_SIZE = screenY - (TOP_COMPENSATION + BOTTOM_COMPENSATION);

Controls.OuterGrid:SetSizeY( MAX_SIZE );
Controls.ScrollPanel:SetSizeY( MAX_SIZE - PANEL_OFFSET );

Controls.ScrollPanel:CalculateInternalSize();
Controls.OuterGrid:ReprocessAnchoring();


----------------------------------------------------------------
-- Key Down Processing
----------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
	if uiMsg == KeyEvents.KeyDown then
	
		if wParam == Keys.VK_ESCAPE then
    	    if( Controls.WarConfirm:IsHidden() == false ) then
	            OnNo();
	        else
    			OnClose();
    	    end
			return true;
		end
    end
end
ContextPtr:SetInputHandler( InputHandler );


----------------------------------------------------------------
----------------------------------------------------------------
function OnYes()
	Network.SendChangeWar( g_WarTarget, true);
    Controls.WarConfirm:SetHide( true );
end
Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );


----------------------------------------------------------------
----------------------------------------------------------------
function OnNo()
    Controls.WarConfirm:SetHide( true );
end
Controls.No:RegisterCallback( Mouse.eLClick, OnNo );



----------------------------------------------------------------
----------------------------------------------------------------
function OnPopup( data )
	if( data.Type ~= ButtonPopupTypes.BUTTONPOPUP_DIPLOMACY ) then
	    return;
	end
	
	ContextPtr:SetHide( false );
end
Events.SerialEventGameMessagePopup.Add( OnPopup );

    

-------------------------------------------------
-------------------------------------------------
function ShowHideHandler( bIsHide )
    if( not bIsHide ) then
        UpdateDisplay();
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );


-------------------------------------------------
-------------------------------------------------
function OnClose( )
    ContextPtr:SetHide( true );
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnClose );


-------------------------------------------------
-------------------------------------------------
function OnDiploOverview()
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_DIPLOMATIC_OVERVIEW } );
end
Controls.DiplomaticOverviewButton:RegisterCallback( Mouse.eLClick, OnDiploOverview );


-------------------------------------------------
-- On Minor Selected
-------------------------------------------------
function MinorSelected ()
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_MINOR_CIVS_LIST, } );
end


-------------------------------------------------
-- On Leader Selected
-------------------------------------------------
function LeaderSelected( ePlayer )

    if( Players[ePlayer]:IsHuman() ) then
        Events.OpenPlayerDealScreenEvent( ePlayer );
    else
        
        UI.SetRepeatActionPlayer(ePlayer);
        UI.ChangeStartDiploRepeatCount(1);
    	Players[ePlayer]:DoBeginDiploWithHuman();    

	end
end


-------------------------------------------------
-- On Open Player Deal Screen
-------------------------------------------------
function OnOpenPlayerDealScreen( iOtherPlayer )
	print("DiploList OnOpenPlayerDealScreen ", iOtherPlayer) --Paz add
    print( "here" );

    -- any time we're legitimately opening the pvp deal screen, make sure we hide the diplolist.
    local iOtherTeam = Players[iOtherPlayer]:GetTeam();
    local iProposalTo = UI.HasMadeProposal( g_iUs );
   
    -- this logic should match OnOpenPlayerDealScreen in TradeLogic.lua
    if( (g_pTeam:IsAtWar( iOtherTeam ) and (g_bAlwaysWar or g_bNoChangeWar) ) or
	    (iProposalTo ~= -1 and iProposalTo ~= iOtherPlayer) ) then
	    -- do nothing
	    return;
    else
        OnClose();
    end
end
Events.OpenPlayerDealScreenEvent.Add( OnOpenPlayerDealScreen );

-------------------------------------------------
-- On War Button Clicked
-------------------------------------------------
function OnWarButton( ePlayer )
	if (g_pTeam:CanDeclareWar(Players[ ePlayer ]:GetTeam())) then
		g_WarTarget = Players[ ePlayer ]:GetTeam();
		Controls.WarConfirm:SetHide( false );
	end	
end


-------------------------------------------------
-- Update the list of other civs
-------------------------------------------------
function UpdateDisplay()
	--print("PazDebug DiploList UpdateDisplay")
	-- Clear buttons
	g_LeaderButtonIM:ResetInstances();
	
	-- Your Score Info
	local strMyScore = g_pPlayer:GetScore();
	Controls.MyScore:SetText(strMyScore);
	
	local strMyScoreTooltip = "";
	strMyScoreTooltip = strMyScoreTooltip .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MY_SCORE_CITIES", g_pPlayer:GetScoreFromCities());
	strMyScoreTooltip = strMyScoreTooltip .. "[NEWLINE]";
	strMyScoreTooltip = strMyScoreTooltip .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MY_SCORE_POPULATION", g_pPlayer:GetScoreFromPopulation());
	strMyScoreTooltip = strMyScoreTooltip .. "[NEWLINE]";
	strMyScoreTooltip = strMyScoreTooltip .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MY_SCORE_LAND", g_pPlayer:GetScoreFromLand());
	strMyScoreTooltip = strMyScoreTooltip .. "[NEWLINE]";
	strMyScoreTooltip = strMyScoreTooltip .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MY_SCORE_WONDERS", g_pPlayer:GetScoreFromWonders());
	strMyScoreTooltip = strMyScoreTooltip .. "[NEWLINE]";
	strMyScoreTooltip = strMyScoreTooltip .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MY_SCORE_TECH", g_pPlayer:GetScoreFromTechs());
	strMyScoreTooltip = strMyScoreTooltip .. "[NEWLINE]";
	strMyScoreTooltip = strMyScoreTooltip .. Locale.ConvertTextKey("TXT_KEY_DIPLO_MY_SCORE_FUTURE_TECH", g_pPlayer:GetScoreFromFutureTech());
	
	Controls.MyScore:SetToolTipString(strMyScoreTooltip);

	local myCivType = g_pPlayer:GetCivilizationType();
	local myCivInfo = GameInfo.Civilizations[myCivType];
	
	local myLeaderType = g_pPlayer:GetLeaderType();
	local myLeaderInfo = GameInfo.Leaders[myLeaderType];
	
	--Paz disable: CivIconHookup( g_iPlayer, 32, Controls.MyCivIcon, Controls.CivIconBG, Controls.CivIconShadow, false, true );

	local leaderDescription = myLeaderInfo.Description;

	--Paz add
	local gPlayers = gT.gPlayers
	local eaPlayer
	if gPlayers then
		eaPlayer = gT.gPlayers[g_iPlayer]
	end
	--end Paz add

	local textBoxSize = Controls.NameBox:GetSizeX() - Controls.LeaderName:GetOffsetX();

	
	if(g_pPlayer:GetNickName() ~= "" and Game.IsGameMultiPlayer()) then
		TruncateString(Controls.LeaderName, textBoxSize, g_pPlayer:GetNickName()); 
	elseif(PreGame.GetLeaderName(g_iPlayer) ~= "") then
		TruncateString(Controls.LeaderName, textBoxSize, Locale.ConvertTextKey( PreGame.GetLeaderName( g_iPlayer ) ));	--Paz: pulled this out: , "  (" .. Locale.ConvertTextKey( "TXT_KEY_YOU" ) .. ")"
	else
		TruncateString(Controls.LeaderName, textBoxSize, Locale.ConvertTextKey( leaderDescription ));	--Paz: pulled this out: , "  (" .. Locale.ConvertTextKey( "TXT_KEY_YOU" ) .. ")"
	end
	
	if( g_pTeam:GetNumMembers() > 1 ) then
	    Controls.TeamID:LocalizeAndSetText( "TXT_KEY_MULTIPLAYER_DEFAULT_TEAM_NAME", g_pTeam:GetID() + 1 );
    else
	    Controls.TeamID:SetText( "" );
	end

	--Paz old modify:
	--local strEaCivRace = ""
	--if eaPlayer then
	--	if eaPlayer.eaCivNameID then
	--		local raceName = GameInfo.EaRaces[eaPlayer.race].Description
	--		strEaCivRace = Locale.ConvertTextKey(eaPlayer.civName).." ("..Locale.ConvertTextKey(raceName)..")"
	--	else
	--		strEaCivRace = Locale.ConvertTextKey(eaPlayer.civName)
	--	end
	--	TruncateString(Controls.LeaderName, textBoxSize, strEaCivRace)
	--end

		
	local textBoxSize = Controls.NameBox:GetSizeX() - Controls.CivName:GetOffsetX() - 120;


	if(PreGame.GetCivilizationShortDescription(g_iPlayer) ~= "") then
		TruncateString(Controls.CivName, textBoxSize, Locale.ConvertTextKey(PreGame.GetCivilizationShortDescription(g_iPlayer)), "  (" .. Locale.ConvertTextKey( "TXT_KEY_YOU" ) .. ")");	--Paz added "you" 4th arg
	else
		TruncateString(Controls.CivName, textBoxSize, Locale.ConvertTextKey(myCivInfo.ShortDescription), "  (" .. Locale.ConvertTextKey( "TXT_KEY_YOU" ) .. ")");	--Paz added "you" 4th arg
	end


	--Paz old modify:
	--local leaderName = Locale.ConvertTextKey("TXT_KEY_EA_NO_LEADER")
	--if eaPlayer and eaPlayer.leaderEaPersonIndex ~= -1 then
	--	leaderName = GetEaPersonFullTitle(gT.gPeople[eaPlayer.leaderEaPersonIndex])
	--end
	--TruncateString(Controls.CivName, textBoxSize, leaderName)

	
	--Paz note: below line will need to reflect EaCiv
	--Paz disable: IconHookup( myLeaderInfo.PortraitIndex, 64, myLeaderInfo.IconAtlas, Controls.LeaderIcon );

	--Paz add
	if not eaPlayer or eaPlayer.religionID == -1 then
		Controls.MyReligionIcon:SetHide(true)
	else
		local myReligionInfo = GameInfo.Religions[eaPlayer.religionID]
		IconHookup( myReligionInfo.PortraitIndex, 48, myReligionInfo.IconAtlas, Controls.MyReligionIcon )
		Controls.MyReligionIcon:SetHide(false)
	end
	--end Paz add
	
	local iMajorMetCount = 0;
    local iProposalTo = UI.HasMadeProposal( g_iUs );
    --------------------------------------------------------------------
	-- Loop through all the Majors the active player knows
    --------------------------------------------------------------------
	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		
		local pOtherPlayer = Players[iPlayerLoop];
		local iOtherTeam = pOtherPlayer:GetTeam();
		local pOtherTeam = Teams[ iOtherTeam ];
		
		-- Valid player? - Can't be us, and has to be alive
		if (iPlayerLoop ~= g_iPlayer and pOtherPlayer:IsAlive()) then

			--Paz add
			local eaPlayerLoop = gT.gPlayers[iPlayerLoop]
			--local nameTrait = eaPlayerLoop.eaCivNameID
			--end Paz add

			-- Met this player?
			--Paz modified on line below: if (g_pTeam:IsHasMet(iOtherTeam)) then
			if (g_pTeam:IsHasMet(iOtherTeam)) and eaPlayerLoop.eaCivNameID then
			    iMajorMetCount = iMajorMetCount + 1;
				local controlTable = g_LeaderButtonIM:GetInstance();

				local primaryColor, secondaryColor = pOtherPlayer:GetPlayerColors();
				local textColor = {x = primaryColor.x, y = primaryColor.y, z = primaryColor.z, w = 1};
				local textBoxSize = controlTable.NameBox:GetSizeX() - controlTable.LeaderName:GetOffsetX();

				if(pOtherPlayer:GetNickName() ~= "" and Game.IsGameMultiPlayer()) then
					TruncateString(controlTable.LeaderName, textBoxSize, pOtherPlayer:GetNickName()); 
				else
					--Paz add (use EaCiv in place of leader for large text)
					--local raceName = GameInfo.EaRaces[eaPlayerLoop.race].Description
					--local strEaCivRace = Locale.ConvertTextKey(eaPlayerLoop.civName).." ("..Locale.ConvertTextKey(raceName)..")"
					--controlTable.LeaderName:SetText(strEaCivRace)	--Paz: this is really the Civ name

					TruncateString(controlTable.LeaderName, textBoxSize, Locale.ConvertTextKey( PreGame.GetLeaderName( iPlayerLoop ) ))

					--end Paz add
					--Paz disable: controlTable.LeaderName:SetText( pOtherPlayer:GetName() );
				end
				
				local civType = pOtherPlayer:GetCivilizationType();
				local civInfo = GameInfo.Civilizations[civType];
				--Paz disable: local strCiv = Locale.ConvertTextKey(civInfo.ShortDescription);
				
				local otherLeaderType = pOtherPlayer:GetLeaderType();
				local otherLeaderInfo = GameInfo.Leaders[otherLeaderType];

				--Paz add (use EaLeader in place of civ for small text)
				--local eaLeaderName
				--if eaPlayerLoop.leaderEaPersonIndex == -1 then
				--	eaLeaderName = Locale.ConvertTextKey("TXT_KEY_EA_NO_LEADER")
				--else
				--	eaLeaderName = GetEaPersonFullTitle(gT.gPeople[eaPlayerLoop.leaderEaPersonIndex])
				--end
				--controlTable.CivName:SetText(eaLeaderName)	--Paz: this is really the Leader name

				local strCiv = Locale.ConvertTextKey(PreGame.GetCivilizationShortDescription(iPlayerLoop))
				local strRace = Locale.ConvertTextKey(GameInfo.EaRaces[eaPlayerLoop.race].Description)
				
				TruncateString(controlTable.CivName, textBoxSize, strCiv .. " (" .. strRace .. ")")


				--end Paz add
				--Paz disable: controlTable.CivName:SetText(strCiv);
				--Paz disable: CivIconHookup( iPlayerLoop, 32, controlTable.CivSymbol, controlTable.CivIconBG, controlTable.CivIconShadow, false, true );
				--Paz disable: IconHookup( otherLeaderInfo.PortraitIndex, 64, otherLeaderInfo.IconAtlas, controlTable.LeaderPortrait );			
				
				--Paz add
				local religionID = eaPlayerLoop.religionID
				if religionID == -1 then
					controlTable.ReligionIcon:SetHide(true)
				else
					
					local religionInfo = GameInfo.Religions[religionID]
					local iconAtlas = "EA_RELIGION_ATLAS"
					-- if founder with holy city, use star atlas
					if gT.gReligions[religionID].founder == iPlayerLoop then
						local holyCity = Game.GetHolyCityForReligion(religionID, iPlayerLoop)
						if holyCity and holyCity:GetOwner() == iPlayerLoop then
							iconAtlas = "EA_RELIGION_STAR_ATLAS"
						end
					end
					IconHookup( religionInfo.PortraitIndex, 48, iconAtlas, controlTable.ReligionIcon )
					controlTable.ReligionIcon:SetHide(false)
				end
				--end Paz add


				-- team indicator
            	if( pOtherTeam:GetNumMembers() > 1 ) then
            	    controlTable.TeamID:LocalizeAndSetText( "TXT_KEY_MULTIPLAYER_DEFAULT_TEAM_NAME", pOtherTeam:GetID() + 1 );
            	    controlTable.TeamID:SetHide( false );
                else
            	    controlTable.TeamID:SetHide( true );
            	end

                -- Status
        	    local statusString;
				controlTable.DiploState:SetHide( false );
            	if( iOtherTeam == g_iTeam ) then
            	    -- team mate
            		local currentTech = pOtherPlayer:GetCurrentResearch();
                    if( currentTech ~= -1 and 
                        GameInfo.Technologies[currentTech] ~= nil and
                        not Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)) then
                	    statusString = "[ICON_RESEARCH] " .. Locale.ConvertTextKey( GameInfo.Technologies[currentTech].Description );
                    end
                    
            	else
    				if( g_pTeam:IsAtWar( iOtherTeam ) ) then
    					if (g_bAlwaysWar) then
    						controlTable.LeaderButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_ALWAYS_WAR_TT"));
    					end
        				statusString = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR" );
					elseif (pOtherPlayer:IsDenouncingPlayer(g_iPlayer)) then
						statusString = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING" );							
					elseif (pOtherPlayer:WasResurrectedThisTurnBy(g_iPlayer)) then
						statusString = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED" );
    				elseif (pOtherPlayer:IsHuman() or pOtherTeam:IsHuman()) then
						controlTable.DiploState:SetToolTipString(" ");
    				else
    					local eApproachGuess = g_pPlayer:GetApproachTowardsUsGuess( iPlayerLoop );
    					
						if( eApproachGuess == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR ) then
							statusString = Locale.ConvertTextKey( "TXT_KEY_WAR_CAPS" );
						elseif( eApproachGuess == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE ) then
							statusString = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE", otherLeaderInfo.Description );
						elseif( eApproachGuess == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED ) then
							statusString = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED", otherLeaderInfo.Description );
						elseif( eApproachGuess == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID ) then
							statusString = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID", otherLeaderInfo.Description);
						elseif( eApproachGuess == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY ) then
							statusString = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY", otherLeaderInfo.Description );
						elseif( eApproachGuess == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL ) then
							statusString = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL", otherLeaderInfo.Description );
						end
					end
					
					local strMoodInfo = GetMoodInfo(iPlayerLoop);
					controlTable.DiploState:SetToolTipString(strMoodInfo);
				end
				
				if( statusString ~= nil ) then
    				controlTable.DiploState:SetHide( false );
            		TruncateString( controlTable.DiploState, controlTable.StatusBox:GetSizeX(), statusString );
        		else
    				controlTable.DiploState:SetHide( true );
				end

				controlTable.Score:SetText( pOtherPlayer:GetScore() );

				controlTable.LeaderButton:SetVoid1( iPlayerLoop ); -- indicates type
				controlTable.LeaderButton:RegisterCallback( Mouse.eLClick, LeaderSelected );


                if( pOtherPlayer:IsHuman() ) then
                    -- don't open trade if we're at war and war status cannot be changed
                    if( not( g_pTeam:IsAtWar( pOtherPlayer:GetTeam() ) and (g_bAlwaysWar or g_bNoChangeWar) ) ) then                    
                        controlTable.LeaderButton:SetDisabled( true );
                    else
                        controlTable.LeaderButton:SetDisabled( false );
                    end
                    
    				-- Show or hide war button if it's a human
    				if( not g_bAlwaysWar and not g_bAlwaysPeace and not g_bNoChangeWar and
    				    not g_pTeam:IsAtWar( pOtherPlayer:GetTeam()) and g_pTeam:CanDeclareWar(pOtherPlayer:GetTeam()) and
    				    g_iTeam ~= iOtherTeam ) then
    					controlTable.WarButton:SetHide(false);
    					
        				controlTable.WarButton:SetVoid1( iPlayerLoop ); -- indicates type
        				controlTable.WarButton:RegisterCallback( Mouse.eLClick, OnWarButton );
    				else
    					controlTable.WarButton:SetHide(true);
    				end
    			else
    				controlTable.WarButton:SetHide(true);    			
				end
				
				controlTable.StatusStack:CalculateSize();
				controlTable.StatusStack:ReprocessAnchoring();


				-----------------------------------------------------------------------------
			    -- disable the button if this is a human, and we have a pending deal, and
			    -- the deal is not with this player
				-----------------------------------------------------------------------------
				local bCanOpenDeal = true;
				if( iProposalTo ~= -1 and
				    iProposalTo ~= iPlayerLoop ) then
				    bCanOpenDeal = false;
				end

				--Paz add: disable contact if no leader (need to stop ai trade elsewhere)
				--if eaPlayerLoop.leaderEaPersonIndex == -1 or eaPlayer.leaderEaPersonIndex == -1 then
				--	bCanOpenDeal = false
				--end
				--end Paz add

				controlTable.LeaderButton:SetDisabled( not bCanOpenDeal );
				
			end
		end
	end

	if( iMajorMetCount > 0 ) then
		Controls.MajorButton:SetHide( false );
	else
		Controls.MajorButton:SetHide( true );
	end
	
	InitMinorCivList();
	InitGodList();							--Paz added
	
	Controls.MinorStack:CalculateSize();
	Controls.GodStack:CalculateSize();		--Paz added
	Controls.MajorStack:CalculateSize();
	
	RecalcPanelSize();
end
Events.SerialEventScoreDirty.Add( UpdateDisplay );
Events.SerialEventCityInfoDirty.Add(UpdateDisplay);

   
-------------------------------------------------
-- Look for the CityStates we've met	
-------------------------------------------------
function InitMinorCivList()
	--print("PazDebug DiploList InitMinorCivList")
	-- Clear buttons
	g_MinorCivButtonIM:ResetInstances();
	
    -------------------------------------------------
    -- Look for the CityStates we've met	
    -------------------------------------------------
	local iMinorMetCount = 0;
	
	for iPlayerLoop = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS-1, 1 do
		
		pOtherPlayer = Players[iPlayerLoop];
		iOtherTeam = pOtherPlayer:GetTeam();
		
		if( pOtherPlayer:IsMinorCiv() and 
			playerType[iPlayerLoop] == "CityState" and		--Paz added
		    g_iTeam ~= iOtherTeam     and 
		    pOtherPlayer:IsAlive()    and
			g_pTeam:IsHasMet( iOtherTeam ) ) then

			-- Update colors
			local _, primaryColor = pOtherPlayer:GetPlayerColors();
			local color = Vector4(primaryColor.x, primaryColor.y, primaryColor.z, 1);
			
			
			iMinorMetCount = iMinorMetCount + 1;
			local controlTable = g_MinorCivButtonIM:GetInstance();
			
			local minorCivType = pOtherPlayer:GetMinorCivType();
			local civInfo = GameInfo.MinorCivilizations[minorCivType];
			
			--Paz modified below: controlTable.MinorName:SetText( Locale.ConvertTextKey( civInfo.Description ) );
			local eaPlayer = gT.gPlayers[iPlayerLoop]
			local raceTextKey = GameInfo.EaRaces[eaPlayer.race].Description
			local nameText = Locale.ConvertTextKey( civInfo.Description ) .. " (" .. Locale.ConvertTextKey( raceTextKey ) .. ")"
			controlTable.MinorName:SetText( nameText )
			--end Paz modified

			controlTable.MinorName:SetColor( color, 0 );

			local strDiploState = "";
			if (g_pTeam:IsAtWar(iOtherTeam)) then
			    if (g_bAlwaysWar) then
    				controlTable.MinorButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_ALWAYS_WAR_TT"));
    			end
			
				strDiploState = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR" )
			end
			controlTable.StatusText:SetText( strDiploState);
			
	
        	local iTrait = pOtherPlayer:GetMinorCivTrait();
			--[[Paz modified below
        	if( iTrait == MinorCivTraitTypes.MINOR_CIV_TRAIT_CULTURED ) then
        		controlTable.MinorType:LocalizeAndSetText( "TXT_KEY_CITY_STATE_CULTURED_ADJECTIVE" );
        	elseif( iTrait == MinorCivTraitTypes.MINOR_CIV_TRAIT_MILITARISTIC ) then
        		controlTable.MinorType:LocalizeAndSetText( "TXT_KEY_CITY_STATE_MILITARISTIC_ADJECTIVE" );
        	elseif( iTrait == MinorCivTraitTypes.MINOR_CIV_TRAIT_MARITIME ) then
        		controlTable.MinorType:LocalizeAndSetText( "TXT_KEY_CITY_STATE_MARITIME_ADJECTIVE" );
        	elseif(iTrait == MinorCivTraitTypes.MINOR_CIV_TRAIT_MERCANTILE) then
        		controlTable.MinorType:LocalizeAndSetText( "TXT_KEY_CITY_STATE_MERCANTILE_ADJECTIVE" );
        	elseif(iTrait == MinorCivTraitTypes.MINOR_TRAIT_RELIGIOUS) then
        		controlTable.MinorType:LocalizeAndSetText( "TXT_KEY_CITY_STATE_RELIGIOUS_ADJECTIVE" );
        	end
			]]
			
			if iTrait == GameInfoTypes.MINOR_TRAIT_HOLY and eaPlayer.religionID == GameInfoTypes.RELIGION_ANRA then
				controlTable.MinorType:LocalizeAndSetText("TXT_KEY_EA_MINOR_TRAIT_UNHOLY")
				controlTable.MinorType:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_EA_MINOR_TRAIT_UNHOLY_HELP"))
			else
				local traitInfo = GameInfo.MinorCivTraits[iTrait]
				controlTable.MinorType:LocalizeAndSetText(traitInfo.Description)
				controlTable.MinorType:SetToolTipString(Locale.ConvertTextKey(traitInfo.EaHelp))
			end
			--end Paz modified

			civType = pOtherPlayer:GetCivilizationType();
			civInfo = GameInfo.Civilizations[civType];

			--Paz disable: IconHookup( civInfo.PortraitIndex, 32, civInfo.AlphaIconAtlas, controlTable.LeaderPortrait );
			--Paz disable: controlTable.LeaderPortrait:SetColor( color );

			--Paz add
			if eaPlayer.religionID == -1 then
				controlTable.ReligionIcon:SetHide(true)
			else
				local religionInfo = GameInfo.Religions[eaPlayer.religionID]
				IconHookup( religionInfo.PortraitIndex, 48, religionInfo.IconAtlas, controlTable.ReligionIcon )
				controlTable.ReligionIcon:SetHide(false)
			end
			--end Paz add

					
			controlTable.MinorButton:SetVoid1( iPlayerLoop );
			controlTable.MinorButton:SetVoid2(  pOtherPlayer:GetCapitalCity() );
			controlTable.MinorButton:RegisterCallback( Mouse.eLClick, MinorSelected );
			controlTable.QuestIcon:SetVoid1( iPlayerLoop );
			controlTable.QuestIcon:RegisterCallback( Mouse.eLClick, OnQuestIconClicked );
			
			local bWar = Teams[Game.GetActiveTeam()]:IsAtWar(pOtherPlayer:GetTeam());
			
			local sMinorCivType = pOtherPlayer:GetMinorCivType();
			local strStatusTT = GetCityStateStatusToolTip(g_iPlayer, iPlayerLoop, true);
			local trait = GameInfo.MinorCivilizations[sMinorCivType].MinorCivTrait;
			UpdateCityStateStatusUI(g_iPlayer, iPlayerLoop, controlTable.PositiveStatusMeter, controlTable.NegativeStatusMeter, controlTable.StatusMeterMarker, controlTable.StatusIconBG);
			controlTable.StatusIcon:SetTexture(GameInfo.MinorCivTraits[trait].TraitIcon);
			controlTable.StatusIcon:SetColor( {x=1, y=1, z=1, w=1 } );
			if (GetCityStateStatusType(g_iPlayer, iPlayerLoop) == "MINOR_FRIENDSHIP_STATUS_NEUTRAL" and color) then
				controlTable.StatusIcon:SetColor(color);
			end
			controlTable.StatusIconBG:SetToolTipString(strStatusTT);
			
			
			------------------------------------------------------
    		-- Quests
    	
    		-- Hide the quest icon if there are no quests OR the City State is at war with you.
    	    if( ( pOtherPlayer:GetMinorCivNumActiveQuestsForPlayer(g_iPlayer) == 0 and not pOtherPlayer:IsThreateningBarbariansEventActiveForPlayer(g_iPlayer) )
    			or g_pTeam:IsAtWar(iOtherTeam)) then
    			controlTable.QuestIcon:SetHide( true );
    	    else
    			local sIconText = GetActiveQuestText(g_iPlayer, iPlayerLoop);
    			local sToolTipText = GetActiveQuestToolTip(g_iPlayer, iPlayerLoop);
    			
    			controlTable.QuestIcon:SetHide( false );
    			controlTable.QuestIcon:SetText(sIconText);
    			controlTable.QuestIcon:SetToolTipString(sToolTipText);
    		end
			
		end
	end		

	if( iMinorMetCount > 0 ) then
		Controls.MinorButton:SetHide( false );
	else
		Controls.MinorButton:SetHide( true );
	end
end

--GodButton
--g_GodCivButtonIM

--Paz add: Gods list is almost exactly copy of city state
function InitGodList()
	--print("PazDebug DiploList InitGodList")
	-- Clear buttons
	g_GodCivButtonIM:ResetInstances();
	
    -------------------------------------------------
    -- Look for the CityStates we've met	
    -------------------------------------------------
	local iGodMetCount = 0;
	
	for iPlayerLoop = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS-1, 1 do
		
		pOtherPlayer = Players[iPlayerLoop];
		iOtherTeam = pOtherPlayer:GetTeam();
		
		if( pOtherPlayer:IsMinorCiv() and 
			playerType[iPlayerLoop] == "God" and
		    g_iTeam ~= iOtherTeam     and 
		    pOtherPlayer:IsAlive()    and
			g_pTeam:IsHasMet( iOtherTeam ) ) then
			

			-- Update colors
			local _, primaryColor = pOtherPlayer:GetPlayerColors();
			local color = Vector4(primaryColor.x, primaryColor.y, primaryColor.z, 1);
			
			
			iGodMetCount = iGodMetCount + 1;
			local controlTable = g_GodCivButtonIM:GetInstance();
			
			local minorCivType = pOtherPlayer:GetMinorCivType();
			local civInfo = GameInfo.MinorCivilizations[minorCivType];
			
			controlTable.GodName:SetText( Locale.ConvertTextKey( civInfo.Description ) );

			controlTable.GodName:SetColor( color, 0 );

			local strDiploState = "";
			if (g_pTeam:IsAtWar(iOtherTeam)) then
			    if (g_bAlwaysWar) then
    				controlTable.GodButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_ALWAYS_WAR_TT"));
    			end
			
				strDiploState = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR" )
			end
			controlTable.StatusText:SetText( strDiploState);
			
			local godType = civInfo.Type
			local spheresTxt = ""
			for row in GameInfo.MinorCivilization_GodSpheres() do
				if row.MinorCivType == godType then
					if spheresTxt == "" then
						spheresTxt = Locale.ConvertTextKey(row.SphereText)
					else
						spheresTxt = spheresTxt .. ", " .. Locale.ConvertTextKey(row.SphereText)
					end
				end
			end
			controlTable.GodType:SetText(spheresTxt);

			civType = pOtherPlayer:GetCivilizationType();
			civInfo = GameInfo.Civilizations[civType];

			--Paz disable: IconHookup( civInfo.PortraitIndex, 32, civInfo.AlphaIconAtlas, controlTable.LeaderPortrait );
			--Paz disable: controlTable.LeaderPortrait:SetColor( color );

			local eaPlayer = gT.gPlayers[iPlayerLoop]
			if eaPlayer.religionID == -1 then
				controlTable.ReligionIcon:SetHide(true)
			else
				local religionInfo = GameInfo.Religions[eaPlayer.religionID]
				IconHookup( religionInfo.PortraitIndex, 48, religionInfo.IconAtlas, controlTable.ReligionIcon )
				controlTable.ReligionIcon:SetHide(false)
			end
			
			controlTable.GodButton:SetVoid1( iPlayerLoop );
			controlTable.GodButton:SetVoid2(  pOtherPlayer:GetCapitalCity() );
			controlTable.GodButton:RegisterCallback( Mouse.eLClick, MinorSelected );
			controlTable.QuestIcon:SetVoid1( iPlayerLoop );
			controlTable.QuestIcon:RegisterCallback( Mouse.eLClick, OnQuestIconClicked );
			
			local bWar = Teams[Game.GetActiveTeam()]:IsAtWar(pOtherPlayer:GetTeam());
			
			local sMinorCivType = pOtherPlayer:GetMinorCivType();
			local strStatusTT = GetCityStateStatusToolTip(g_iPlayer, iPlayerLoop, true);
			local trait = GameInfo.MinorCivilizations[sMinorCivType].MinorCivTrait;
			UpdateCityStateStatusUI(g_iPlayer, iPlayerLoop, controlTable.PositiveStatusMeter, controlTable.NegativeStatusMeter, controlTable.StatusMeterMarker, controlTable.StatusIconBG);
			controlTable.StatusIcon:SetTexture(GameInfo.MinorCivTraits[trait].TraitIcon);
			controlTable.StatusIcon:SetColor( {x=1, y=1, z=1, w=1 } );
			if (GetCityStateStatusType(g_iPlayer, iPlayerLoop) == "MINOR_FRIENDSHIP_STATUS_NEUTRAL" and color) then
				controlTable.StatusIcon:SetColor(color);
			end
			controlTable.StatusIconBG:SetToolTipString(strStatusTT);
			
			
			------------------------------------------------------
    		-- Quests
    	
    		-- Hide the quest icon if there are no quests OR the City State is at war with you.
    	    if( ( pOtherPlayer:GetMinorCivNumActiveQuestsForPlayer(g_iPlayer) == 0 and not pOtherPlayer:IsThreateningBarbariansEventActiveForPlayer(g_iPlayer) )
    			or g_pTeam:IsAtWar(iOtherTeam)) then
    			controlTable.QuestIcon:SetHide( true );
    	    else
    			local sIconText = GetActiveQuestText(g_iPlayer, iPlayerLoop);
    			local sToolTipText = GetActiveQuestToolTip(g_iPlayer, iPlayerLoop);
    			
    			controlTable.QuestIcon:SetHide( false );
    			controlTable.QuestIcon:SetText(sIconText);
    			controlTable.QuestIcon:SetToolTipString(sToolTipText);
    		end
			
		end
	end		

	if( iGodMetCount > 0 ) then
		Controls.GodButton:SetHide( false );
	else
		Controls.GodButton:SetHide( true );
	end

end
--end Paz add

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function MinorSelected( PlayerID )
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_DIPLO, Data1 = PlayerID; } );
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnQuestIconClicked( PlayerID )
	local pMinor = Players[PlayerID];
	if (pMinor) then
		if (pMinor:IsMinorCivActiveQuestForPlayer(g_iPlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP)) then
			local iQuestData1 = pMinor:GetQuestData1(g_iPlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP);
			local iQuestData2 = pMinor:GetQuestData2(g_iPlayer, MinorCivQuestTypes.MINOR_CIV_QUEST_KILL_CAMP);
			local pPlot = Map.GetPlot(iQuestData1, iQuestData2);
			if (pPlot) then
				UI.LookAt(pPlot, 0);
				local hex = ToHexFromGrid(Vector2(pPlot:GetX(), pPlot:GetY()));
				Events.GameplayFX(hex.x, hex.y, -1);
			end
		end
	end
end

-----------------------------------------------------------------
-----------------------------------------------------------------
function RecalcPanelSize()
	Controls.OuterStack:CalculateSize();
	local size = math.min( MAX_SIZE, Controls.OuterStack:GetSizeY() + 250 );
    Controls.OuterGrid:SetSizeY( size );
    Controls.ScrollPanel:SetSizeY( size - PANEL_OFFSET );
	Controls.ScrollPanel:CalculateInternalSize();
	Controls.ScrollPanel:ReprocessAnchoring();
end


-----------------------------------------------------------------
-----------------------------------------------------------------
function OnMajorsButton()
    if( Controls.MajorStack:IsHidden() ) then
        Controls.MajorButton:SetText( "[ICON_MINUS]" .. Locale.ConvertTextKey( "{TXT_KEY_CIVILIZATION_SECTION_1:upper}" ) );
        Controls.MajorStack:SetHide( false );
    else
        Controls.MajorButton:SetText( "[ICON_PLUS]" .. Locale.ConvertTextKey( "{TXT_KEY_CIVILIZATION_SECTION_1:upper}" ) );
        Controls.MajorStack:SetHide( true );
    end
    
    RecalcPanelSize();
end
Controls.MajorButton:RegisterCallback( Mouse.eLClick, OnMajorsButton );


-----------------------------------------------------------------
-----------------------------------------------------------------
function OnMinorsButton()
    if( Controls.MinorStack:IsHidden() ) then
        Controls.MinorButton:SetText( "[ICON_MINUS]" .. Locale.ConvertTextKey( "{TXT_KEY_PEDIA_CATEGORY_11_LABEL:upper}" ) );
        Controls.MinorStack:SetHide( false );
    else
        Controls.MinorButton:SetText( "[ICON_PLUS]" .. Locale.ConvertTextKey( "{TXT_KEY_PEDIA_CATEGORY_11_LABEL:upper}" ) );
        Controls.MinorStack:SetHide( true );
    end
    
    RecalcPanelSize();
end
Controls.MinorButton:RegisterCallback( Mouse.eLClick, OnMinorsButton );

--Paz add
function OnGodsButton()
    if( Controls.GodStack:IsHidden() ) then
        Controls.GodButton:SetText( "[ICON_MINUS]" .. Locale.ConvertTextKey( "TXT_KEY_EA_GODS_CAPITALS" ) );
        Controls.GodStack:SetHide( false );
    else
        Controls.GodButton:SetText( "[ICON_PLUS]" .. Locale.ConvertTextKey( "TXT_KEY_EA_GODS_CAPITALS" ) );
        Controls.GodStack:SetHide( true );
    end
    
    RecalcPanelSize();
end
Controls.GodButton:RegisterCallback( Mouse.eLClick, OnGodsButton );
--end Paz add
----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
function OnDiploListActivePlayerChanged( iActivePlayer, iPrevActivePlayer )
	g_iPlayer = Game.GetActivePlayer();
	g_pPlayer = Players[ g_iPlayer ];
	g_iTeam = g_pPlayer:GetTeam();
	g_pTeam = Teams[ g_iTeam ];
end
Events.GameplaySetActivePlayer.Add(OnDiploListActivePlayerChanged);

OnMajorsButton();
OnGodsButton();			--Paz add
OnMinorsButton();

