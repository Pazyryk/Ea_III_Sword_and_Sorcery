include( "IconSupport" );
include( "UniqueBonuses" );

local iCivID = -1;
local g_bLoadComplete;

--Paz add
print("Loading modified LoadScreen.lua...")

local screenSizeX, screenSizeY = UIManager:GetScreenSizeVal()
local loadImageSize = {x = 1280, y = 820}
local loadImageName = "_LoadScreen_Segoy_JiaRuan_1280x820.dds"

local g_cachedMusicVolume = 0
local g_cachedSpeechVolume = 0


--This is used to delay the volume shift after load screen; othewise base G&K menu music comes back breifly before fading
local RETURN_MUSIC_VOLUME_THOUSANDTHS_SECONDS = 1000

local bStart = false
local g_tickStart = 0
function LocalMachineAppUpdateListener(tickCount, timeIncrement)
	if bStart then
		if RETURN_MUSIC_VOLUME_THOUSANDTHS_SECONDS < tickCount - tickStart then
			print("LoadScreen.lua is restoring music volume; delay in sec/1000 = ", tickCount - tickStart)
			print("os.clock() / tickCount : ", os.clock(), tickCount)
			SetVolumeKnobValue(GetVolumeKnobIDFromName("USER_VOLUME_MUSIC"), g_cachedMusicVolume)
			SetVolumeKnobValue(GetVolumeKnobIDFromName("USER_VOLUME_SPEECH"), g_cachedSpeechVolume)
			Events.SerialEventDawnOfManHide(iCivID)		--silences the DoM speach, which is really the loadscreen music
			Events.LocalMachineAppUpdate.RemoveAll()	--also removes tutorial checks (good riddence!)
		end
	else
		tickStart = tickCount
		bStart = true
	end
end
--added to Events.LocalMachineAppUpdate below
--end Paz add

function ShowHide( isHide, isInit )
	if ( not isInit ) then
		if ( isHide == true ) then
			UIManager:SetUICursor( 0 );
			Controls.Image:UnloadTexture();
			--print("Texture is unloaded");
			if (iCivID ~= -1) then
				--Paz disabled: Events.SerialEventDawnOfManHide(iCivID);
			end
		else
			OnInitScreen();
			UIManager:SetUICursor( 1 );
			if (iCivID ~= -1) then
				Events.SerialEventDawnOfManShow(iCivID);        
			end
		end
	end
end
ContextPtr:SetShowHideHandler( ShowHide );

Controls.ProgressBar:SetPercent( 1 );

function OnInitScreen()
	
	--Paz add
	print("LoadScreen.lua is killing music volume temporarily to play DoM track (which is really music)")
	local musicVolumeKnobID = GetVolumeKnobIDFromName("USER_VOLUME_MUSIC")
	local speechVolumeKnobID = GetVolumeKnobIDFromName("USER_VOLUME_SPEECH")
	g_cachedMusicVolume = GetVolumeKnobValue(musicVolumeKnobID)
	g_cachedSpeechVolume = GetVolumeKnobValue(speechVolumeKnobID)
	SetVolumeKnobValue(musicVolumeKnobID, 0)						--kill the menu music
	SetVolumeKnobValue(speechVolumeKnobID, g_cachedMusicVolume)		--get ready to play DoM (which is really music)
	--end Paz add

	g_bLoadComplete = false;
	
    Controls.AlphaAnim:SetToBeginning();
    --Paz disable: Controls.SlideAnim:SetToBeginning();
	Controls.ActivateButton:SetHide(true);

	print("OnInitScreen")
	
	local civIndex = PreGame.GetCivilization( Game:GetActivePlayer() );

	print("civIndex", civIndex)
    
    local civ = GameInfo.Civilizations[civIndex];

	print("civ", civ)
    
    if(civ == nil) then
		PreGame.SetCivilization(0, -1);
	end
    
    -- Sets up Selected Civ Slot
    if( civ ~= nil ) then
		--[[Paz disable		
        -- Use the Civilization_Leaders table to cross reference from this civ to the Leaders table
        local leader = GameInfo.Leaders[GameInfo.Civilization_Leaders( "CivilizationType = '" .. civ.Type .. "'" )().LeaderheadType];
        local leaderDescription = leader.Description;


		-- Set Leader & Civ Text
		Controls.Civilization:LocalizeAndSetText( civ.Description );
		Controls.Leader:LocalizeAndSetText( leaderDescription );
        
        -- Set Civ Leader Icon
		IconHookup( leader.PortraitIndex, 128, leader.IconAtlas, Controls.Portrait );
		
		-- Set Civ Icon
		--Paz disable: SimpleCivIconHookup( Game.GetActivePlayer(), 80, Controls.IconShadow );
		
		-- Sets Trait bonus Text
        local leaderTrait = GameInfo.Leader_Traits("LeaderType ='" .. leader.Type .. "'")();
        local trait = leaderTrait.TraitType;
        Controls.BonusTitle:SetText( Locale.ConvertTextKey( GameInfo.Traits[trait].ShortDescription ));
        Controls.BonusDescription:SetText( Locale.ConvertTextKey( GameInfo.Traits[trait].Description ));
        
         -- Sets Bonus Icons
        local bonusText = PopulateUniqueBonuses( Controls, civ, leader, false, true);
        
        Controls.BonusUnit:LocalizeAndSetText( bonusText[1] or "" );
        Controls.BonusBuilding:LocalizeAndSetText( bonusText[2] or "" );
        
        -- Sets Dawn of Man Quote
        Controls.Quote:LocalizeAndSetText(civ.DawnOfManQuote or "");
		
        -- Sets Dawn of Man Image
        Controls.Image:SetTexture(civ.DawnOfManImage);
		]]
		--Paz add:
		 Controls.Image:SetTexture(loadImageName)

		local scale = 1
		if screenSizeX < loadImageSize.x then
			scale = screenSizeX / loadImageSize.x
		end
		if screenSizeY < loadImageSize.y then
			local scaleY = screenSizeY / loadImageSize.y
			scale = scale < scaleY and scale or scaleY
		end
		if scale < 1 then
			local boxSize = {x = math.floor(loadImageSize.x * scale), y = math.floor(loadImageSize.y * scale)}
			Controls.LoadBox:SetSize(boxSize)
			Controls.Image:SetSize(boxSize)
		end
		--end Paz add

		iCivID = civ.ID;
        --print("iCivID: " .. iCivID);
	end
	
	
end      

function OnActivateButtonClicked ()
	print("Activate button clicked!");		--Paz re-enabled for debugging
	Events.LoadScreenClose();
	if (not PreGame.IsMultiplayerGame() and not PreGame.IsHotSeatGame()) then
		Game.SetPausePlayer(-1);
	end
	--Paz add
	print("Adding LocalMachineAppUpdateListener for sound control")
	Events.LocalMachineAppUpdate.Add(LocalMachineAppUpdateListener)
	--end Paz add
	--UI.SetNextGameState( GameStates.MainGameView, g_iAIPlayer );
end
Controls.ActivateButton:RegisterCallback( Mouse.eLClick, OnActivateButtonClicked );


----------------------------------------------------------------        
-- Key Down Processing
----------------------------------------------------------------        
function InputHandler( uiMsg, wParam, lParam )
    if( uiMsg == KeyEvents.KeyDown )
    then
        if( wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN ) then
			if (g_bLoadComplete) then
				OnActivateButtonClicked();
			end
        end
    end
    return true;
end
ContextPtr:SetInputHandler( InputHandler );

function HideBackgrounds ()
	Controls.AlphaAnim:Play();
	--Paz disable: Controls.SlideAnim:Play();
end

function OnSequenceGameInitComplete ()

	--Paz debug
	print("OnSequenceGameInitComplete")
	--end Paz debug
	
	g_bLoadComplete = true;	
	
	if (PreGame.IsMultiplayerGame() or PreGame.IsHotSeatGame()) then
		OnActivateButtonClicked();
	else
		Game.SetPausePlayer(Game.GetActivePlayer());
		local strGameButtonName;
		if (not UI:IsLoadedGame()) then
			strGameButtonName = Locale.ConvertTextKey("TXT_KEY_BEGIN_GAME_BUTTON");
		else
			strGameButtonName = Locale.ConvertTextKey("TXT_KEY_BEGIN_GAME_BUTTON_CONTINUE");
		end
	
		Controls.ActivateButtonText:SetText(strGameButtonName);
		Controls.ActivateButton:SetHide(false);
		HideBackgrounds();
        UIManager:SetUICursor( 0 );	
        
		--[[Paz disabled
        -- Update Icons to now have tooltips.
        local civIndex = PreGame.GetCivilization( Game:GetActivePlayer() );
        local civ = GameInfo.Civilizations[civIndex];
    
		-- Sets up Selected Civ Slot
		if( civ ~= nil ) then
			
			-- Use the Civilization_Leaders table to cross reference from this civ to the Leaders table
			local leader = GameInfo.Leaders[GameInfo.Civilization_Leaders( "CivilizationType = '" .. civ.Type .. "'" )().LeaderheadType];

			 -- Sets Bonus Icons
			local bonusText = PopulateUniqueBonuses( Controls, civ, leader, true, false);
		end
		]]
	end
end

Events.SequenceGameInitComplete.Add( OnSequenceGameInitComplete );