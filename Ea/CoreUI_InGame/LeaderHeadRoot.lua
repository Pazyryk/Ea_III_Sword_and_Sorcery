----------------------------------------------------------------        
----------------------------------------------------------------        

include( "IconSupport" );
include( "GameplayUtilities" );
include( "InfoTooltipInclude" );

--Paz add
include ("EaImageScaling.lua")
include ("EaTextUtils.lua")
if not MapModData.gT then
	MapModData.gT = {}
end
local gT = MapModData.gT
--end Paz add

local g_iAIPlayer = -1;
local g_iAITeam = -1;

local g_DiploUIState = -1;

local g_iRootMode = 0;
local g_iTradeMode = 1;
local g_iDiscussionMode = 2;

local g_strLeaveScreenText = Locale.ConvertTextKey("TXT_KEY_DIPLOMACY_ANYTHING_ELSE");

local offsetOfString = 32;
local bonusPadding = 16
local innerFrameWidth = 654;
local outerFrameWidth = 650;
local offsetsBetweenFrames = 4;

----------------------------------------------------------------        
-- LEADER MESSAGE HANDLER
----------------------------------------------------------------        
function LeaderMessageHandler( iPlayer, iDiploUIState, szLeaderMessage, iAnimationAction, iData1 )
	print("LeaderHeadRoot LeaderMessageHandler ", iPlayer, iDiploUIState, szLeaderMessage, iAnimationAction, iData1 ) --Paz added
	
	g_DiploUIState = iDiploUIState;
	
	g_iAIPlayer = iPlayer;
	g_iAITeam = Players[g_iAIPlayer]:GetTeam();

	--Paz add
	local iActivePlayer = Game.GetActivePlayer()
	--local civText, strTitleText
	--[[
	if gT.gPlayers then
		if gT.gPlayers[iActivePlayer].leaderEaPersonIndex == -1 then
			print("Exiting LeaderHeadRoot because our civ has no leader")
			OnReturn()	--we both need leaders to communicate
			return
		end
		local eaPlayer = gT.gPlayers[iPlayer]
		local playerLeaderIndex = eaPlayer.leaderEaPersonIndex
		if playerLeaderIndex == -1 then
			print("Exiting LeaderHeadRoot because other civ has no leader")
			OnReturn()	--we both need leaders to communicate
			return	
		end
		strTitleText = GetEaPersonFullTitle(gT.gPeople[playerLeaderIndex])
		civText = Locale.ConvertTextKey(eaPlayer.civName)
	else		--mod not inited yet
		return
	end
	]]
	--end Paz add
	
	--Paz modified to line below: local pActivePlayer = Players[Game.GetActivePlayer()];
	local pActivePlayer = Players[iActivePlayer]

	local pActiveTeam = Teams[pActivePlayer:GetTeam()];
	
	CivIconHookup( iPlayer, 64, Controls.ThemSymbolShadow, Controls.CivIconBG, Controls.CivIconShadow, false, true );
		
	-- Update title even if we're not in this mode, as we could exit to it somehow
	--[[Paz modified below
	local player = Players[iPlayer];
	local strTitleText = GameplayUtilities.GetLocalizedLeaderTitle(player);
	
	Controls.TitleText:SetText(strTitleText);
	
	playerLeaderInfo = GameInfo.Leaders[player:GetLeaderType()];
	
	-- Mood
	local iApproach = pActivePlayer:GetApproachTowardsUsGuess(g_iAIPlayer);
	local strMoodText = Locale.ConvertTextKey("TXT_KEY_EMOTIONLESS");
	
	if (pActiveTeam:IsAtWar(g_iAITeam)) then
		strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR" );
	elseif (Players[g_iAIPlayer]:IsDenouncingPlayer(Game.GetActivePlayer())) then
		strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING" );	
	elseif (Players[g_iAIPlayer]:WasResurrectedThisTurnBy(iActivePlayer)) then
		strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED" );		
	else
		if( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_WAR_CAPS" );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE", playerLeaderInfo.Description  );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED", playerLeaderInfo.Description  );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID", playerLeaderInfo.Description  );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY", playerLeaderInfo.Description  );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL", playerLeaderInfo.Description );
		end
	end

	]]
	
	
	local strTitleText = Locale.ConvertTextKey(PreGame.GetLeaderName(iPlayer))
	
	Controls.TitleText:SetText(strTitleText);
	
	local civText = Locale.ConvertTextKey(PreGame.GetCivilizationDescription(iPlayer))
	
	-- Mood
	local iApproach = pActivePlayer:GetApproachTowardsUsGuess(g_iAIPlayer);
	local strMoodText = Locale.ConvertTextKey("TXT_KEY_EMOTIONLESS");
	
	if (pActiveTeam:IsAtWar(g_iAITeam)) then
		strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_WAR" );
	elseif (Players[g_iAIPlayer]:IsDenouncingPlayer(iActivePlayer)) then
		strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_DENOUNCING" );	
	elseif (Players[g_iAIPlayer]:WasResurrectedThisTurnBy(iActivePlayer)) then
		strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_LIBERATED" );		
	else
		if( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_WAR ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_WAR_CAPS" );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_HOSTILE ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_HOSTILE", strTitleText  );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_GUARDED ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_GUARDED", strTitleText  );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_AFRAID ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_AFRAID", strTitleText  );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_FRIENDLY ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_FRIENDLY", strTitleText  );
		elseif( iApproach == MajorCivApproachTypes.MAJOR_CIV_APPROACH_NEUTRAL ) then
			strMoodText = Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAJOR_CIV_DIPLO_STATE_NEUTRAL", strTitleText );
		end
	end

	--end Paz modified
	Controls.MoodText:SetText(strMoodText);
	
	local strMoodInfo = GetMoodInfo(g_iAIPlayer);
	Controls.MoodText:SetToolTipString(strMoodInfo);
	
	local bMyMode = false;
	
	-- See if we're in this screen
	if (g_DiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_DEFAULT_ROOT) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_WAR_DECLARED_BY_HUMAN) then
		bMyMode = true;
	elseif (iDiploUIState == DiploUIStateTypes.DIPLO_UI_STATE_PEACE_MADE_BY_HUMAN) then
		bMyMode = true;
	end
	
	-- Are we in this screen's mode?
	if (bMyMode) then
		UI.SetLeaderHeadRootUp( true );
	    UIManager:QueuePopup( ContextPtr, PopupPriority.LeaderHead );

		--[[Paz add: this is a wierd way to do this... (will need for all leaders if we do personality changes)
		TO DO: Edit ALL leader conversation texts! Ouch!
		local Sub = string.gsub
		szLeaderMessage = Sub(szLeaderMessage, "Rome", civText)
		szLeaderMessage = Sub(szLeaderMessage, "Augustus, Emperor and Pontifex Maximus", strTitleText)
		
		szLeaderMessage = Sub(szLeaderMessage, "Greece", civText)
		szLeaderMessage = Sub(szLeaderMessage, "Alexander, heir to Heracles and Zeus", strTitleText)
		szLeaderMessage = Sub(szLeaderMessage, "Alexander", strTitleText)

		szLeaderMessage = Sub(szLeaderMessage, "Ramkhamhaeng, king of Siam", strTitleText .. " of " .. civText)
		szLeaderMessage = Sub(szLeaderMessage, "Siam", civText)
		szLeaderMessage = Sub(szLeaderMessage, "Ramkhamhaeng", strTitleText)

		szLeaderMessage = Sub(szLeaderMessage, "the Iroquois", civText)
		szLeaderMessage = Sub(szLeaderMessage, "the mighty Iroquois", "the immortal " .. civText)
		szLeaderMessage = Sub(szLeaderMessage, "Hiawatha, speaker for", strTitleText .. " of")
		szLeaderMessage = Sub(szLeaderMessage, "Hiawatha, leader", strTitleText)
		]]
		--end Paz add
		
		print("Handling LeaderMessage: " .. iDiploUIState .. ", ".. szLeaderMessage);
		
		Controls.LeaderSpeech:SetText( szLeaderMessage );
		
		-- Resize the height of the box to fit the text
		local contentSize = Controls.LeaderSpeech:GetSize().y + offsetOfString + bonusPadding;
		Controls.LeaderSpeechBorderFrame:SetSizeY( contentSize );
		Controls.LeaderSpeechFrame:SetSizeY( contentSize - offsetsBetweenFrames );
		
	else
		Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else
		
	end
    
end
Events.AILeaderMessage.Add( LeaderMessageHandler );


----------------------------------------------------------------        
-- BACK
----------------------------------------------------------------        
function OnReturn()
	--UI.SetNextGameState( GameStates.MainGameView, g_iAIPlayer );
    UIManager:DequeuePopup( ContextPtr );
	UI.SetLeaderHeadRootUp( false );
	UI.RequestLeaveLeader();
end
Controls.BackButton:RegisterCallback( Mouse.eLClick, OnReturn );


----------------------------------------------------------------        
----------------------------------------------------------------        
function OnLeavingLeader()
    -- we shouldn't be able to leave without this already being set to false, 
    -- but just in case...
	UI.SetLeaderHeadRootUp( false );
    UIManager:DequeuePopup( ContextPtr );
end
Events.LeavingLeaderViewMode.Add( OnLeavingLeader );


local oldCursor = 0;

--Paz add
local lastImageFrame
--end Paz add

----------------------------------------------------------------        
-- SHOW/HIDE
----------------------------------------------------------------        
function OnShowHide( bHide )
	--print("PazDebug LeaderHeadRood OnShowHide")
	--Paz add: overlays EaLeader on Civ5 leaderhead (Civ5 "leaderhead" used here as race background)
	if g_iAIPlayer ~= -1 then
		local dds
		if MapModData.fullCivs[g_iAIPlayer] or MapModData.playerType[g_iAIPlayer] == "Fay" then		--major civ or Fay
			--local iLeader = gT.gPlayers[g_iAIPlayer].leaderEaPersonIndex
			--local eaLeader = gT.gPeople[iLeader]
			--dds = eaLeader and eaLeader.portrait or nil
			local aiPlayer = Players[g_iAIPlayer]
			local leaderID = aiPlayer:GetLeaderType()
			if leaderID >= GameInfoTypes.LEADER_FAND then		--Not a "No Leader" Type
				local leaderType = GameInfo.Leaders[leaderID].Type
				local eaPortraitType = string.gsub(leaderType, "LEADER", "EAPORTRAIT")
				dds = GameInfo.EaPortraits[eaPortraitType].File			--We want the error if this doesn't exist (TO DO: check these on game init)
			end
		end
		if not bHide and dds then
	
			local gridSize, gridOffset, imageFrame, imageSize, imageOffset = ScaleImage("Leader", dds)
			print(dds, imageFrame, imageSize.x, imageSize.y, imageOffset.x, imageOffset.y, gridSize.x, gridSize.y, gridOffset.x, gridOffset.y)

			if gridSize then
				Controls.EaLeaderGrid:SetHide(false)
				Controls.EaLeaderGrid:SetSize(gridSize)
				Controls.EaLeaderGrid:SetOffsetVal(gridOffset.x, gridOffset.y)
				Controls[imageFrame]:SetHide(false)
				Controls[imageFrame]:SetTexture(dds)
				Controls[imageFrame]:SetSize(imageSize)
				Controls[imageFrame]:SetOffsetVal(imageOffset.x, imageOffset.y)
				lastImageFrame = imageFrame
			end
		elseif bHide then
			--is this needed?
			Controls.EaLeaderGrid:SetHide(true)
			if lastImageFrame then
				Controls[lastImageFrame]:SetHide(true)
				Controls[lastImageFrame]:UnloadTexture()
			end
		end
	end
	--end Paz add
	
	-- Showing Screen
	if (not bHide) then
		local pActiveTeam = Teams[Game.GetActiveTeam()];
		
		-- Hide or show war/peace button
		if (not pActiveTeam:CanChangeWarPeace(g_iAITeam)) then
			Controls.WarButton:SetHide(true);
		else
			Controls.WarButton:SetHide(false);
		end
		
		-- Hide or show the demand button
		if (Game.GetActiveTeam() == g_iAITeam) then
			Controls.DemandButton:SetHide(true);
		else
			Controls.DemandButton:SetHide(false);
		end
		
		oldCursor = UIManager:SetUICursor(0); -- make sure we start with the default cursor
		
	    if (g_iAITeam ~= -1) then
			local bAtWar = pActiveTeam:IsAtWar(g_iAITeam);
			
			if (bAtWar) then
				Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE" ));
				Controls.TradeButton:SetDisabled(true);
				Controls.DemandButton:SetDisabled(true);
				Controls.DiscussButton:SetDisabled(true);
				
				local iLockedWarTurns = pActiveTeam:GetNumTurnsLockedIntoWar(g_iAITeam);
				
				-- Not locked into war
				if (iLockedWarTurns == 0) then
					Controls.WarButton:SetDisabled(false);
					Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_TT" ));
				-- Locked into war
				else
					Controls.WarButton:SetDisabled(true);
					Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE_BLOCKED_TT", iLockedWarTurns ));
				end
			else
				Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARE_WAR" ));
				Controls.TradeButton:SetDisabled(false);
				Controls.DemandButton:SetDisabled(false);
				Controls.DiscussButton:SetDisabled(false);
				
				if (pActiveTeam:IsForcePeace(g_iAITeam)) then
					Controls.WarButton:SetDisabled(true);
					Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK" ));
				elseif (not pActiveTeam:CanDeclareWar(g_iAITeam)) then
					Controls.WarButton:SetDisabled(true);
					Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_MAY_NOT_ATTACK_MOD" ));
				else
					Controls.WarButton:SetDisabled(false);
					Controls.WarButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARES_WAR_TT" ));
				end
				
			end
		end
		
	-- Hiding Screen
	else
		UIManager:SetUICursor(oldCursor); -- make sure we retrun the cursor to the previous state
		--Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else
	
	end
end
ContextPtr:SetShowHideHandler( OnShowHide );


----------------------------------------------------------------        
-- Key Down Processing
----------------------------------------------------------------        
function InputHandler( uiMsg, wParam, lParam )
    if( uiMsg == KeyEvents.KeyDown )
    then
        if( wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN ) then
			if(Controls.WarConfirm:IsHidden())then
	            OnReturn();
			else
				Controls.WarConfirm:SetHide(true);
			end
        end
    end
    return true;
end
ContextPtr:SetInputHandler( InputHandler );



----------------------------------------------------------------        
----------------------------------------------------------------        
function OnDiscuss()
	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else
		
	Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_WANTS_DISCUSSION, g_iAIPlayer, 0, 0 );
end
Controls.DiscussButton:RegisterCallback( Mouse.eLClick, OnDiscuss );


----------------------------------------------------------------        
----------------------------------------------------------------        
function OnTrade()
	-- This calls into CvDealAI and sets up the initial state of the UI
	Players[g_iAIPlayer]:DoTradeScreenOpened();
	
	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else
	
    UI.OnHumanOpenedTradeScreen(g_iAIPlayer);
end
Controls.TradeButton:RegisterCallback( Mouse.eLClick, OnTrade );


----------------------------------------------------------------        
----------------------------------------------------------------        
function OnDemand()
	
	Controls.LeaderSpeech:SetText( g_strLeaveScreenText );		-- Seed the text box with something reasonable so that we don't get leftovers from somewhere else
	
    UI.OnHumanDemand(g_iAIPlayer);
end
Controls.DemandButton:RegisterCallback( Mouse.eLClick, OnDemand );


----------------------------------------------------------------        
----------------------------------------------------------------        
function OnWarOrPeace()
	
    local bAtWar = Teams[Game.GetActiveTeam()]:IsAtWar(g_iAITeam);
    
	-- Asking for Peace (currently at war) - bring up the trade screen
    if (bAtWar) then
	    Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_NEGOTIATE_PEACE, g_iAIPlayer, 0, 0 );
		
    -- Declaring War (currently at peace)
	else
		Controls.WarConfirm:SetHide(false);
	    --Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DECLARES_WAR, g_iAIPlayer, 0, 0 );
    end
    
end
Controls.WarButton:RegisterCallback( Mouse.eLClick, OnWarOrPeace );


----------------------------------------------------------------        
----------------------------------------------------------------        
function WarStateChangedHandler( iTeam1, iTeam2, bWar )
	
	-- Active player changed war state with this AI
	if (iTeam1 == Game.GetActiveTeam() and iTeam2 == g_iAITeam) then
		
		if (bWar) then
			Controls.WarButton:SetText( Locale.ConvertTextKey( "TXT_KEY_DIPLO_NEGOTIATE_PEACE" ));
			Controls.TradeButton:SetDisabled(true);
			Controls.DemandButton:SetDisabled(true);
			Controls.DiscussButton:SetDisabled(true);
		else
			Controls.WarButton:SetText(Locale.ConvertTextKey( "TXT_KEY_DIPLO_DECLARE_WAR" ));
			Controls.TradeButton:SetDisabled(false);
			Controls.DemandButton:SetDisabled(false);
			Controls.DiscussButton:SetDisabled(false);
		end
		
	end
	
end
Events.WarStateChanged.Add( WarStateChangedHandler );

function OnYes( )
	Controls.WarConfirm:SetHide(true);
	
	Game.DoFromUIDiploEvent( FromUIDiploEventTypes.FROM_UI_DIPLO_EVENT_HUMAN_DECLARES_WAR, g_iAIPlayer, 0, 0 );
end
Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );

function OnNo( )
	Controls.WarConfirm:SetHide(true);
end
Controls.No:RegisterCallback( Mouse.eLClick, OnNo );
---------------------------------------------------------------------------------------
-- Support for Modded Add-in UI's
---------------------------------------------------------------------------------------
g_uiAddins = {};
for addin in Modding.GetActivatedModEntryPoints("DiplomacyUIAddin") do
	local addinFile = Modding.GetEvaluatedFilePath(addin.ModID, addin.Version, addin.File);
	local addinPath = addinFile.EvaluatedPath;
	
	-- Get the absolute path and filename without extension.
	local extension = Path.GetExtension(addinPath);
	local path = string.sub(addinPath, 1, #addinPath - #extension);
	
	table.insert(g_uiAddins, ContextPtr:LoadNewContext(path));
end
