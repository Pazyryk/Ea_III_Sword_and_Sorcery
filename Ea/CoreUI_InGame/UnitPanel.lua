------------------------------------------------
-- Unit Panel Screen 
-------------------------------------------------
include( "IconSupport" );
include( "InstanceManager" );

--Paz add
--include("Ea___API_Include.lua")
include ("EaPlotUtils.lua")
local MapModData = MapModData
MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT
MapModData.gpRegisteredActions = MapModData.gpRegisteredActions or {}
local gpRegisteredActions = MapModData.gpRegisteredActions


local cachedNonGPActions = {}
local numNonGPActions = 0
for eaActionInfo in GameInfo.EaActions() do
	if not eaActionInfo.GPOnly then
		numNonGPActions = numNonGPActions + 1
		cachedNonGPActions[numNonGPActions] = eaActionInfo.ID
	end
end
--end Paz add

local g_PrimaryIM    = InstanceManager:new( "UnitAction",  "UnitActionButton", Controls.PrimaryStack );
local g_SecondaryIM  = InstanceManager:new( "UnitAction",  "UnitActionButton", Controls.SecondaryStack );
local g_BuildIM      = InstanceManager:new( "UnitAction",  "UnitActionButton", Controls.WorkerActionPanel );
local g_SpellIM      = InstanceManager:new( "Spell",  "SpellButton", Controls.SpellPanel );	--Paz add
local g_PromotionIM  = InstanceManager:new( "UnitAction",  "UnitActionButton", Controls.WorkerActionPanel );
local g_EarnedPromotionIM   = InstanceManager:new( "EarnedPromotionInstance", "UnitPromotionImage", Controls.EarnedPromotionStack );

    
local g_CurrentActions = {};    --CurrentActions associated with each button
local g_lastUnitID = -1;        -- Used to determine if a different unit has been selected.
local g_ActionButtons = {};
local g_PromotionsOpen = false;
local g_SecondaryOpen = false;
local g_bWorkerActionPanelOpen = false;	--Paz added "b"
local g_bSpellPanelOpen = false;		--Paz add

local MaxDamage = GameDefines.MAX_HIT_POINTS;

local promotionsTexture = "Promotions512.dds";

local unitPortraitSize = Controls.UnitPortrait:GetSize().x;
local actionIconSize = 64;
if OptionsManager.GetSmallUIAssets() then
	actionIconSize = 45;
end

--------------------------------------------------------------------------------
-- this maps from the normal instance names to the build city control names
-- so we can use the same code to set it up
--------------------------------------------------------------------------------
local g_BuildCityControlMap = { 
    UnitActionButton    = Controls.BuildCityButton,
    --UnitActionMouseover = Controls.BuildCityMouseover,
    --UnitActionText      = Controls.BuildCityText,
    --UnitActionHotKey    = Controls.BuildCityHotKey,
    --UnitActionHelp      = Controls.BuildCityHelp,
};


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function OnPromotionButton()
    g_PromotionsOpen = not g_PromotionsOpen;
    
    if g_PromotionsOpen then
        Controls.PromotionStack:SetHide( false );
    else
        Controls.PromotionStack:SetHide( true );
    end
end
Controls.PromotionButton:RegisterCallback( Mouse.eLClick, OnPromotionButton );


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function OnSecondaryButton()
    g_SecondaryOpen = not g_SecondaryOpen;
    
    if g_SecondaryOpen then
        Controls.SecondaryStack:SetHide( false );
        Controls.SecondaryStretchy:SetHide( false );
        Controls.SecondaryImageOpen:SetHide( true );
        Controls.SecondaryImageClosed:SetHide( false );
        Controls.SecondaryButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_SECONDARY_O_TEXT" ));

    else
        Controls.SecondaryStack:SetHide( true );
        Controls.SecondaryStretchy:SetHide( true );
        Controls.SecondaryImageOpen:SetHide( false );
        Controls.SecondaryImageClosed:SetHide( true );
        Controls.SecondaryButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_SECONDARY_C_TEXT" ));
    end
end
Controls.SecondaryButton:RegisterCallback( Mouse.eLClick, OnSecondaryButton );


local GetActionIconIndexAndAtlas = {
	[ActionSubTypes.ACTIONSUBTYPE_PROMOTION] = function(action)
		local thisPromotion = GameInfo.UnitPromotions[action.CommandData];
		return thisPromotion.PortraitIndex, thisPromotion.IconAtlas;
	end,
	
	[ActionSubTypes.ACTIONSUBTYPE_INTERFACEMODE] = function(action)
		local info = GameInfo.InterfaceModes[action.Type];
		return info.IconIndex, info.IconAtlas;
	end,
	
	[ActionSubTypes.ACTIONSUBTYPE_MISSION] = function(action)
		local info = GameInfo.Missions[action.Type];
		return info.IconIndex, info.IconAtlas;
	end,
	
	[ActionSubTypes.ACTIONSUBTYPE_COMMAND] = function(action)
		local info = GameInfo.Commands[action.Type];
		return info.IconIndex, info.IconAtlas;
	end,
	
	[ActionSubTypes.ACTIONSUBTYPE_AUTOMATE] = function(action)
		local info = GameInfo.Automates[action.Type];
		return info.IconIndex, info.IconAtlas;
	end,
	
	[ActionSubTypes.ACTIONSUBTYPE_BUILD] = function(action)
		local info = GameInfo.Builds[action.Type];
		return info.IconIndex, info.IconAtlas;
	end,
	
	[ActionSubTypes.ACTIONSUBTYPE_CONTROL] = function(action)
		local info = GameInfo.Controls[action.Type];
		return info.IconIndex, info.IconAtlas;
	end,
};

function HookupActionIcon(action, actionIconSize, icon)

	local f = GetActionIconIndexAndAtlas[action.SubType];
	if(f ~= nil) then
		local iconIndex, iconAtlas = f(action);
		IconHookup(iconIndex, actionIconSize, iconAtlas, icon);
	else
		print(action.Type);
		print(action.SubType);
		error("Could not find method to obtain action icon.");
	end
end
--------------------------------------------------------------------------------
-- Refresh unit actions
--------------------------------------------------------------------------------
function UpdateUnitActions( unit )

	--Paz add

	local iPlayer = Game.GetActivePlayer()
	local pActivePlayer = Players[iPlayer]
	local plot = unit:GetPlot()
	local iUnit = unit:GetID()
	local bGreatPerson = unit:IsGreatPerson()
	local unitTypeInfo = GameInfo.Units[unit:GetUnitType()]
	local eaGPTempType = unitTypeInfo.EaGPTempRole
	local iPerson, eaPerson
	local inProgressEaActionID = -1	

	if bGreatPerson then
		iPerson = unit:GetPersonIndex()

		eaPerson = gT.gPeople[iPerson]
		inProgressEaActionID = eaPerson.eaActionID

		Controls.WorkerText:SetText(Locale.ConvertTextKey("TXT_KEY_EA_UNIT_PANEL_BUILDS_GREAT_WORKS"))
	else
		Controls.WorkerText:SetText(Locale.ConvertTextKey("TXT_KEY_WORKERACTION_TEXT"))
	end

	--print("UpdateUnitActions", iPerson, inProgressEaActionID)
	--end Paz add

    g_PrimaryIM:ResetInstances();
    g_SecondaryIM:ResetInstances();
    g_BuildIM:ResetInstances();
    g_SpellIM:ResetInstances();		--Paz add
    g_PromotionIM:ResetInstances();
    Controls.BuildCityButton:SetHide( true );
    Controls.WorkerActionPanel:SetHide(true);
    --Paz disabled: local pActivePlayer = Players[Game.GetActivePlayer()];
    
    local bShowActionButton;
    local bUnitHasMovesLeft = unit:MovesLeft() > 0;
    
    -- Text that tells the player this Unit's out of moves this turn
    if (not bUnitHasMovesLeft) then
		Controls.UnitStatusInfo:SetHide(false);
		Controls.SecondaryButton:SetHide(true);
	else
		Controls.UnitStatusInfo:SetHide(true);
		Controls.SecondaryButton:SetHide(false);
    end
    
    local hasPromotion = false;
	local bBuild = false;
	local bPromotion = false;
	local iBuildID;

    Controls.BackgroundCivFrame:SetHide( false );
   
	local numBuildActions = 0;
	local numPromotions = 0;
	local numPrimaryActions = 0;
	local numSecondaryActions = 0;
	--Paz add
	local numSpells = 0;		--Paz add
	local bRitual = false
	local bProphecy = false
	--end Paz add
	
	local numberOfButtonsPerRow = 4;
	local buttonSize = 60;
	local buttonPadding = 8;
	local buttonOffsetX = 16;
	local buttonOffsetY = 40;
	local workerPanelSizeOffsetY = 104;
	if OptionsManager.GetSmallUIAssets() then
		numberOfButtonsPerRow = 6;
		buttonSize = 40;
		buttonPadding = 6;
		workerPanelSizeOffsetY = 86;
	end

    local recommendedBuild = nil;
    
    local buildCityButtonActive = false;
   
       -- loop over all the game actions
    for iAction = 0, #GameInfoActions, 1 do
        local action = GameInfoActions[iAction];
        
		-- test CanHandleAction w/ visible flag (ie COULD train if ... )
        if(action.Visible and Game.CanHandleAction( iAction, 0, 1 ) ) then
           	if( action.SubType == ActionSubTypes.ACTIONSUBTYPE_PROMOTION ) then
                hasPromotion = true;                
			end
        end
    end

 	--Paz add	********************************************************************************************************
	if bGreatPerson then

		--loop over all EaActions for Great People (these don't overlap with GameInfoActions, but use same UI)
		if bUnitHasMovesLeft then
			local x, y = plot:GetX(), plot:GetY()

			--This is done the same as EaAIActions.lua: loop through all registered actions, then swap in spell list
			local testActions = gpRegisteredActions[iPerson]
			local lastAction = #testActions
			local i = 1
			eaActionID = testActions[1]
			while eaActionID do
				local eaAction = GameInfo.EaActions[eaActionID]
				if eaActionID < MapModData.FIRST_SPELL_ID then
					LuaEvents.EaActionsTestEaActionForHumanUI(eaActionID, iPlayer, unit, iPerson, x, y)
				else
					LuaEvents.EaSpellsTestEaSpellForHumanUI(eaActionID, iPlayer, unit, iPerson, x, y)
				end
				local bShow = MapModData.bShow
				local bDisabled = not MapModData.bAllow
				local uiType = eaAction.UIType
				if bShow then
					local instance, spellInstance      
					local uiType = eaAction.UIType
					if uiType == "Build" then
						if not hasPromotion then
							instance = g_BuildIM:GetInstance()
							instance.UnitActionButton:SetAnchor( "L,B" )
							instance.UnitActionButton:SetOffsetVal( (numBuildActions % numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetX, math.floor(numBuildActions / numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetY )	
							numBuildActions = numBuildActions + 1
						end
					elseif uiType == "Spell" then
						if not hasPromotion then
							spellInstance = g_SpellIM:GetInstance()
							spellInstance.SpellButton:SetAnchor( "L,B" )
							spellInstance.SpellButton:SetOffsetVal( (numSpells % numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetX, math.floor(numSpells / numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetY )	
							numSpells = numSpells + 1
							if not bRitual and string.find(eaAction.Type, "^EA_ACTION_RITUAL_") then
								bRitual = true
							end
							if not bProphecy and string.find(eaAction.Type, "^EA_ACTION_PROPHECY_") then
								bProphecy = true
							end
						end
					elseif uiType == "Action" then
						instance = g_PrimaryIM:GetInstance()
						numPrimaryActions = numPrimaryActions + 1
					elseif uiType == "SecondaryAction" then
						instance = g_SecondaryIM:GetInstance()
					end
					if instance then
						if bDisabled then
							instance.UnitActionButton:SetAlpha( 0.4 )           
							instance.UnitActionButton:SetDisabled( true )                
						else
							instance.UnitActionButton:SetAlpha( 1.0 )
							instance.UnitActionButton:SetDisabled( false )                
						end

						if instance.UnitActionIcon ~= nil then
							--HookupActionIcon(action, actionIconSize, instance.UnitActionIcon)
							IconHookup(eaAction.IconIndex, actionIconSize, eaAction.IconAtlas, instance.UnitActionIcon)
						end

						instance.UnitActionButton:RegisterCallback( Mouse.eLClick, OnEaActionClicked )
						instance.UnitActionButton:SetVoid1( eaAction.ID )
						instance.UnitActionButton:SetToolTipCallback( EaTipHandler )
					elseif spellInstance then
						if bDisabled then
							spellInstance.SpellButton:SetAlpha( 0.4 )           
							spellInstance.SpellButton:SetDisabled( true )                
						else
							spellInstance.SpellButton:SetAlpha( 1.0 )
							spellInstance.SpellButton:SetDisabled( false )                
						end

						if spellInstance.SpellIcon ~= nil then
							IconHookup(eaAction.IconIndex, actionIconSize, eaAction.IconAtlas, spellInstance.SpellIcon)
						end

						spellInstance.SpellButton:RegisterCallback( Mouse.eLClick, OnEaActionClicked )
						spellInstance.SpellButton:SetVoid1( eaAction.ID )
						spellInstance.SpellButton:SetToolTipCallback( EaTipHandler )					
					end
				end
				i = i + 1
				if lastAction < i then
					if not eaPerson.spells or eaPerson.spells == testActions then		--done
						break
					else
						testActions = eaPerson.spells									--swap to spells and start from begining
						lastAction = #testActions
						i = 1
					end
				end
				eaActionID = testActions[i]
			end
		end
		if eaPerson.eaActionID > 0 then
			local eaAction = GameInfo.EaActions[-1]
			local instance = g_PrimaryIM:GetInstance()
			numPrimaryActions = numPrimaryActions + 1
			instance.UnitActionButton:SetAlpha( 1.0 )
			instance.UnitActionButton:SetDisabled( false )                
			if instance.UnitActionIcon ~= nil then
				IconHookup(eaAction.IconIndex, actionIconSize, eaAction.IconAtlas, instance.UnitActionIcon)
			end
			instance.UnitActionButton:RegisterCallback( Mouse.eLClick, OnEaActionClicked )
			instance.UnitActionButton:SetVoid1( eaAction.ID )
			instance.UnitActionButton:SetToolTipCallback( EaTipHandler )
		end
	elseif bUnitHasMovesLeft then		--non-GP mod added actions
		for i = 1, numNonGPActions do
			local eaActionID = cachedNonGPActions[i]
			local eaAction = GameInfo.EaActions[eaActionID]
			if eaActionID < MapModData.FIRST_SPELL_ID then
				LuaEvents.EaActionsTestEaActionForHumanUI(eaActionID, iPlayer, unit, nil, x, y)
			else
				LuaEvents.EaSpellsTestEaSpellForHumanUI(eaActionID, iPlayer, unit, nil, x, y)
			end
			local bShow = MapModData.bShow
			local bDisabled = not MapModData.bAllow
			local uiType = eaAction.UIType
			if bShow then
				local instance       
				local uiType = eaAction.UIType
				if uiType == "Build" then
					if not hasPromotion then
						instance = g_BuildIM:GetInstance()
						instance.UnitActionButton:SetAnchor( "L,B" )
						instance.UnitActionButton:SetOffsetVal( (numBuildActions % numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetX, math.floor(numBuildActions / numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetY )	
						numBuildActions = numBuildActions + 1
					end
				elseif uiType == "Action" then
					instance = g_PrimaryIM:GetInstance()
					numPrimaryActions = numPrimaryActions + 1
				elseif uiType == "SecondaryAction" then
					instance = g_SecondaryIM:GetInstance()
				end
				if instance then
					if bDisabled then
						instance.UnitActionButton:SetAlpha( 0.4 )           
						instance.UnitActionButton:SetDisabled( true )                
					else
						instance.UnitActionButton:SetAlpha( 1.0 )
						instance.UnitActionButton:SetDisabled( false )                
					end

					if instance.UnitActionIcon ~= nil then
						--HookupActionIcon(action, actionIconSize, instance.UnitActionIcon)
						IconHookup(eaAction.IconIndex, actionIconSize, eaAction.IconAtlas, instance.UnitActionIcon)
					end

					instance.UnitActionButton:RegisterCallback( Mouse.eLClick, OnEaActionClicked )
					instance.UnitActionButton:SetVoid1( eaAction.ID )
					instance.UnitActionButton:SetToolTipCallback( EaTipHandler )
				end
			end
		end	
	end
	--end Paz add********************************************************************************************************

    -- loop over all the game actions
    for iAction = 0, #GameInfoActions, 1 
    do
        local action = GameInfoActions[iAction];
        
        local bBuild = false;
        local bPromotion = false;
        local bDisabled = false;
        
        -- We hide the Action buttons when Units are out of moves so new players aren't confused
        if (bUnitHasMovesLeft or action.Type == "COMMAND_CANCEL" or action.Type == "COMMAND_STOP_AUTOMATION" or action.SubType == ActionSubTypes.ACTIONSUBTYPE_PROMOTION) then
			bShowActionButton = true;
		else
			bShowActionButton = false;
        end
        
		--Paz add
		bShowActionButton = not eaGPTempType and bShowActionButton
		if bShowActionButton and bGreatPerson then
			if action.Type == "COMMAND_WAKE" or action.Type == "COMMAND_AUTOMATE" or action.Type == "MISSION_SLEEP" or action.Type == "MISSION_ALERT" or action.Type == "MISSION_FORTIFY" or action.Type == "AUTOMATE_EXPLORE" then
				bShowActionButton = false
			end
		end
		--end Paz add

		-- test CanHandleAction w/ visible flag (ie COULD train if ... )
        if( bShowActionButton and action.Visible and Game.CanHandleAction( iAction, 0, 1 ) ) 
        then
            local instance;
            if( action.Type == "MISSION_FOUND" ) then
                instance = g_BuildCityControlMap;
                Controls.BuildCityButton:SetHide( false );
                buildCityButtonActive = true;
                
            elseif( action.SubType == ActionSubTypes.ACTIONSUBTYPE_PROMOTION ) then
				bPromotion = true;
                instance = g_PromotionIM:GetInstance();
                instance.UnitActionButton:SetAnchor( "L,B" );
				instance.UnitActionButton:SetOffsetVal( (numBuildActions % numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetX, math.floor(numBuildActions / numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetY );				
                numBuildActions = numBuildActions + 1;
                
            elseif( (action.SubType == ActionSubTypes.ACTIONSUBTYPE_BUILD or action.Type == "INTERFACEMODE_ROUTE_TO") and hasPromotion == false) then
            
				bBuild = true;
				iBuildID = action.MissionData;
				instance = g_BuildIM:GetInstance();
				instance.UnitActionButton:SetAnchor( "L,B" );
				instance.UnitActionButton:SetOffsetVal( (numBuildActions % numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetX, math.floor(numBuildActions / numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetY );				
				numBuildActions = numBuildActions + 1;
				if recommendedBuild == nil and unit:IsActionRecommended( iAction ) then
				
					recommendedBuild = iAction;
					
					local buildInfo = GameInfo.Builds[action.Type];				
					IconHookup( buildInfo.IconIndex, actionIconSize, buildInfo.IconAtlas, Controls.RecommendedActionImage );
					Controls.RecommendedActionButton:RegisterCallback( Mouse.eLClick, OnUnitActionClicked );
					Controls.RecommendedActionButton:SetVoid1( iAction );
					Controls.RecommendedActionButton:SetToolTipCallback( TipHandler );
					local text = action.TextKey or action.Type or "Action"..(buttonIndex - 1);
					local convertedKey = Locale.ConvertTextKey( text );

					Controls.RecommendedActionLabel:SetText( convertedKey );
				end
               
            elseif( action.OrderPriority > 100 ) then
                instance = g_PrimaryIM:GetInstance();
                numPrimaryActions = numPrimaryActions + 1;
                
            else
                instance = g_SecondaryIM:GetInstance();
                numSecondaryActions = numSecondaryActions + 1;
            end
            
			-- test w/o visible flag (ie can train right now)

			--[[Paz modified below
			if not Game.CanHandleAction( iAction ) then
				bDisabled = true;
				instance.UnitActionButton:SetAlpha( 0.4 );                
				instance.UnitActionButton:SetDisabled( true );                
			else
				instance.UnitActionButton:SetAlpha( 1.0 );
				instance.UnitActionButton:SetDisabled( false );                
			end
			]]
			bDisabled = bDisabled or not Game.CanHandleAction( iAction )
			if bDisabled then
				instance.UnitActionButton:SetAlpha( 0.4 );                
				instance.UnitActionButton:SetDisabled( true );                
			else
				instance.UnitActionButton:SetAlpha( 1.0 );
				instance.UnitActionButton:SetDisabled( false );                
			end
			--end Paz modified			



            if(instance.UnitActionIcon ~= nil) then
				HookupActionIcon(action, actionIconSize, instance.UnitActionIcon);	
            end
            instance.UnitActionButton:RegisterCallback( Mouse.eLClick, OnUnitActionClicked );
            instance.UnitActionButton:SetVoid1( iAction );
			instance.UnitActionButton:SetToolTipCallback( TipHandler )
           
        end
    end

    --if hasPromotion == true then
        --Controls.PromotionButton:SetHide( false );
    --else
        --Controls.PromotionButton:SetHide( true );
    --end
    Controls.PromotionStack:SetHide( true );
    
    g_PromotionsOpen = false;
    
    Controls.PrimaryStack:CalculateSize();
    Controls.PrimaryStack:ReprocessAnchoring();
    
    local stackSize = Controls.PrimaryStack:GetSize();
    local stretchySize = Controls.PrimaryStretchy:GetSize();
    local buildCityButtonSize = 0;
    if buildCityButtonActive then
		if OptionsManager.GetSmallUIAssets() then
			buildCityButtonSize = 36;
		else
			buildCityButtonSize = 60;
		end
    end
    Controls.PrimaryStretchy:SetSizeVal( stretchySize.x, stackSize.y + buildCityButtonSize + 348 );
    
    if (numPrimaryActions > 0) then
        Controls.PrimaryStack:SetHide( false );
        Controls.PrimaryStretchy:SetHide( false );
        Controls.SecondaryButton:SetHide( false );
      	Controls.SecondaryButton:SetDisabled(numSecondaryActions == 0);
    else
        Controls.PrimaryStack:SetHide( true );
        Controls.PrimaryStretchy:SetHide( true );
        Controls.SecondaryButton:SetHide( true );
    end
    
    if(numSecondaryActions == 0) then
		Controls.SecondaryStack:SetHide(true);
		Controls.SecondaryStretchy:SetHide(true);
    end
    
    Controls.SecondaryStack:CalculateSize();
    Controls.SecondaryStack:ReprocessAnchoring();
    
    stackSize = Controls.SecondaryStack:GetSize();
    stretchySize = Controls.SecondaryStretchy:GetSize();
    Controls.SecondaryStretchy:SetSizeVal( stretchySize.x, stackSize.y + 290 );

    --Controls.BuildStack:CalculateSize();
    --Controls.BuildStack:ReprocessAnchoring();
	--Paz add
	local buildActionsY = 45
	--end Paz add
    if numBuildActions > 0 or hasPromotion then
		Controls.WorkerActionPanel:SetHide( false );
		g_bWorkerActionPanelOpen = true;
		stackSize = Controls.WorkerActionPanel:GetSize();
		local rbOffset = 0;
		if recommendedBuild then
			rbOffset = 60;
			if OptionsManager.GetSmallUIAssets() then
				rbOffset = 60;
			end
			Controls.RecommendedActionDivider:SetHide( false );
			Controls.RecommendedActionButton:SetHide( false );
		else
			rbOffset = 0;
			Controls.RecommendedActionDivider:SetHide( true );
			Controls.RecommendedActionButton:SetHide( true );
		end
		if hasPromotion then
			Controls.WorkerText:SetHide(true);
			Controls.PromotionText:SetHide(false);
			Controls.PromotionAnimation:SetHide(false);
			Controls.EditButton:SetHide(false);
		else
			Controls.WorkerText:SetHide(false);
			Controls.PromotionText:SetHide(true);
			Controls.PromotionAnimation:SetHide(true);
			Controls.EditButton:SetHide(true);
		end
		--Paz modified below: Controls.WorkerActionPanel:SetSizeVal( stackSize.x, math.floor((numBuildActions-1) / numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetY + rbOffset + workerPanelSizeOffsetY );
		buildActionsY = math.floor((numBuildActions-1) / numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetY + rbOffset + workerPanelSizeOffsetY
		Controls.WorkerActionPanel:SetSizeVal(stackSize.x, buildActionsY)
		--end Paz modified
    else
		Controls.WorkerActionPanel:SetHide( true );
		g_bWorkerActionPanelOpen = false;
    end

	--Paz add
    if numSpells > 0 then
		Controls.SpellPanel:SetHide( false );
		g_bSpellPanelOpen = true;
		Controls.SpellPanel:SetOffsetVal(53, 80 + buildActionsY)
		stackSize = Controls.SpellPanel:GetSize();
		Controls.SpellPanel:SetSizeVal( stackSize.x, math.floor((numSpells-1) / numberOfButtonsPerRow) * buttonSize + buttonPadding + buttonOffsetY + workerPanelSizeOffsetY );
		if bProphecy then
			Controls.SpellsRitualsPropheciesText:LocalizeAndSetText("TXT_KEY_EA_UNIT_PANEL_SPELLS_PROPHECIES")
		elseif bRitual then
			Controls.SpellsRitualsPropheciesText:LocalizeAndSetText("TXT_KEY_EA_UNIT_PANEL_SPELLS_RITUALS")
		else
			Controls.SpellsRitualsPropheciesText:LocalizeAndSetText("TXT_KEY_EA_UNIT_PANEL_SPELLS")
		end
	else
		Controls.SpellPanel:SetHide( true );
		g_bSpellPanelOpen = false;
    end
	--end Paz add
    
    local buildType = unit:GetBuildType();
    if (buildType ~= -1) then -- this is a worker who is actively building something
		--Paz note: this won't fire for Ea City builds or Personal actions; these handled in elseif's below
		local thisBuild = GameInfo.Builds[buildType];
		--print("thisBuild.Type:"..tostring(thisBuild.Type));
		local civilianUnitStr = Locale.ConvertTextKey(thisBuild.Description);
		local iTurnsLeft = unit:GetPlot():GetBuildTurnsLeft(buildType, Game.GetActivePlayer(),  0, 0);	
		local iTurnsTotal = unit:GetPlot():GetBuildTurnsTotal(buildType);	
		if (iTurnsLeft < 4000 and iTurnsLeft > 0) then
			civilianUnitStr = civilianUnitStr.." ("..tostring(iTurnsLeft)..")";
		end
		IconHookup( thisBuild.IconIndex, 45, thisBuild.IconAtlas, Controls.WorkerProgressIcon ); 		
		Controls.WorkerProgressLabel:SetText( civilianUnitStr );
		local percent = (iTurnsTotal - iTurnsLeft) / iTurnsTotal;
		Controls.WorkerProgressBar:SetPercent( percent );
		Controls.WorkerProgressIconFrame:SetHide( false );
		Controls.WorkerProgressFrame:SetHide( false );

	--Paz add ******************************************************************************************************************************
	elseif inProgressEaActionID > 1 then
		local eaAction = GameInfo.EaActions[inProgressEaActionID]
		local totalTurns = eaAction.TurnsToComplete or eaPerson.turnsToComplete


		local civilianUnitStr = Locale.ConvertTextKey(eaAction.Description)
		if totalTurns < 1000 then
			local progressHolder = eaAction.ProgressHolder
			local progress
			if progressHolder == "Person" then
				local progressTable = eaPerson.progress
				progress = progressTable[inProgressEaActionID] or 0
			elseif progressHolder == "City" then
				local iPlot = plot:GetPlotIndex()
				local eaCity = gT.gCities[iPlot]
				local progressTable = eaCity.progress
				progress = progressTable[inProgressEaActionID] or 0
			elseif progressHolder == "CityCiv" then
				local iPlot = plot:GetPlotIndex()
				local eaCity = gT.gCities[iPlot]
				eaCity.civProgress[iPlayer] = eaCity.civProgress[iPlayer] or {}	--this will never be deleted but that's OK
				local progressTable = eaCity.civProgress[iPlayer]
				progress = progressTable[inProgressEaActionID] or 0
			elseif progressHolder == "Plot" then
				local buildID = GameInfoTypes[eaAction.BuildType]
				progress = plot:GetBuildProgress(buildID)			
			end
			
			
			if totalTurns > progress then
				civilianUnitStr = civilianUnitStr.." ("..tostring(totalTurns - progress)..")"
			end
			IconHookup( eaAction.IconIndex, 45, eaAction.IconAtlas, Controls.WorkerProgressIcon )
			Controls.WorkerProgressLabel:SetText( civilianUnitStr )
			local percent = progress / totalTurns
			Controls.WorkerProgressBar:SetPercent( percent )
			Controls.WorkerProgressIconFrame:SetHide( false )
			Controls.WorkerProgressFrame:SetHide( false )

		else
			IconHookup( eaAction.IconIndex, 45, eaAction.IconAtlas, Controls.WorkerProgressIcon )
			Controls.WorkerProgressLabel:SetText( civilianUnitStr )
			Controls.WorkerProgressBar:SetPercent( 0 )
			Controls.WorkerProgressIconFrame:SetHide( false )
			Controls.WorkerProgressFrame:SetHide( false )
			civilianUnitStr = civilianUnitStr.." (sustained)"
			Controls.WorkerProgressLabel:SetText( civilianUnitStr )
		end

	
		

	--end Paz add ************************************************************************************************************************

	else
		Controls.WorkerProgressIconFrame:SetHide( true );
		Controls.WorkerProgressFrame:SetHide( true );
	end
    
    Controls.PromotionStack:CalculateSize();
    Controls.PromotionStack:ReprocessAnchoring();
end

local defaultErrorTextureSheet = "TechAtlasSmall.dds";
local nullOffset = Vector2( 0, 0 );

--------------------------------------------------------------------------------
-- Refresh unit portrait and name
--------------------------------------------------------------------------------
function UpdateUnitPortrait( unit )
    local name = unit:GetName();
    name = Locale.ToUpper(name);
    --local name = unit:GetNameKey();
    local convertedKey = Locale.ConvertTextKey(name);
    convertedKey = Locale.ToUpper(convertedKey);

    Controls.UnitName:SetText(convertedKey);    
    Controls.UnitName:SetFontByName("EaTwCnMT24");   --Paz modded fonts
    
    local name_length = Controls.UnitName:GetSizeVal();
    local box_length = Controls.UnitNameButton:GetSizeVal();
    
    if (name_length > (box_length - 50)) then
	    Controls.UnitName:SetFontByName("EaTwCnMT20");   
	end
	
	name_length = Controls.UnitName:GetSizeVal();
	
	if(name_length > (box_length - 50)) then
		Controls.UnitName:SetFontByName("EaTwCnMT14");
	end
    
    -- Tool tip
    local strToolTip = Locale.ConvertTextKey("TXT_KEY_CURRENTLY_SELECTED_UNIT");
    
    if unit:IsCombatUnit() or unit:GetDomainType() == DomainTypes.DOMAIN_AIR then
	--Paz undo change: if unit:IsCombatUnit() or unit:IsGreatPerson() or unit:GetDomainType() == DomainTypes.DOMAIN_AIR then
		local iExperience = unit:GetExperience();
	    
		local iLevel = unit:GetLevel();
		local iExperienceNeeded = unit:ExperienceNeeded();
		local xpString = Locale.ConvertTextKey("TXT_KEY_UNIT_EXPERIENCE_INFO", iLevel, iExperience, iExperienceNeeded);
		Controls.XPMeter:SetToolTipString( xpString );
		Controls.XPMeter:SetPercent( iExperience / iExperienceNeeded );
			
		if (iExperience > 0) then
			strToolTip = strToolTip .. "[NEWLINE][NEWLINE]" .. xpString;
		end
		Controls.XPFrame:SetHide( false );
	else
 		Controls.XPFrame:SetHide( true );
   end
	
	Controls.UnitPortrait:SetToolTipString(strToolTip);
    
    local thisUnitInfo = GameInfo.Units[unit:GetUnitType()];
    local unitFlagOffset = thisUnitInfo.UnitFlagIconOffset;
    
    local textureOffset, textureAtlas = IconLookup( thisUnitInfo.UnitFlagIconOffset, 32, thisUnitInfo.UnitFlagAtlas );
    Controls.UnitIcon:SetTexture(textureAtlas);
    Controls.UnitIconShadow:SetTexture(textureAtlas);
    Controls.UnitIcon:SetTextureOffset(textureOffset);
    Controls.UnitIconShadow:SetTextureOffset(textureOffset);
    
    local pPlayer = Players[ unit:GetOwner() ];
    if (pPlayer ~= nil) then
		local iconColor, flagColor = pPlayer:GetPlayerColors();
	        
		if( pPlayer:IsMinorCiv() ) then
			flagColor, iconColor = flagColor, iconColor;
		end

		Controls.UnitIcon:SetColor( iconColor );
		Controls.UnitIconBackground:SetColor( flagColor );
	end    
    
    textureOffset, textureAtlas = IconLookup( thisUnitInfo.PortraitIndex, unitPortraitSize, thisUnitInfo.IconAtlas );
    if textureOffset == nil then
		textureOffset = nullOffset;
		textureAtlas = defaultErrorTextureSheet;
    end
    Controls.UnitPortrait:SetTexture(textureAtlas);
    Controls.UnitPortrait:SetTextureOffset(textureOffset);
    
    --These controls are potentially hidden if the previous selection was a city.
	Controls.UnitTypeFrame:SetHide(false);
	Controls.CycleLeft:SetHide(false);
	Controls.CycleRight:SetHide(false);
    Controls.UnitMovementBox:SetHide(false);
 	--Paz add
	--Controls.GPCycle:SetHide( false )
	--end Paz add  
end

function UpdateCityPortrait(city)
    local name = city:GetName();
    name = Locale.ToUpper(name);
    --local name = unit:GetNameKey();
    local convertedKey = Locale.ConvertTextKey(name);
    convertedKey = Locale.ToUpper(convertedKey);

    Controls.UnitName:SetText(convertedKey);    
    Controls.UnitName:SetFontByName("EaTwCnMT24");   
    
    local name_length = Controls.UnitName:GetSizeVal();
    local box_length = Controls.UnitNameButton:GetSizeVal();
    
    if (name_length > (box_length - 50)) then
	    Controls.UnitName:SetFontByName("EaTwCnMT20");   
	end
	
	name_length = Controls.UnitName:GetSizeVal();
	
	if(name_length > (box_length - 50)) then
		Controls.UnitName:SetFontByName("EaTwCnMT14");
	end
    
	Controls.UnitPortrait:SetToolTipString(nil);
    
    local textureOffset, textureAtlas = IconLookup( 0, unitPortraitSize, "CITY_ATLAS" );
    if textureOffset == nil then
		textureOffset = nullOffset;
		textureAtlas = defaultErrorTextureSheet;
    end
    Controls.UnitPortrait:SetTexture(textureAtlas);
    Controls.UnitPortrait:SetTextureOffset(textureOffset);
    
        
    --Hide various aspects of Unit Panel since they don't apply to the city.
    --Clear promotions
    g_EarnedPromotionIM:ResetInstances();
    
    Controls.UnitTypeFrame:SetHide(true);
    Controls.CycleLeft:SetHide(true);
    Controls.CycleRight:SetHide(true);
    Controls.XPFrame:SetHide( true );
    Controls.SecondaryButton:SetHide(true);
    Controls.UnitMovementBox:SetHide(true);
    Controls.UnitStrengthBox:SetHide(true);
    --Paz disabled: Controls.UnitRangedAttackBox:SetHide(true);
    Controls.WorkerActionPanel:SetHide(true);
	Controls.PrimaryStack:SetHide( true );
	Controls.PrimaryStretchy:SetHide( true );
	Controls.SecondaryStack:SetHide( true );
	Controls.SecondaryStretchy:SetHide( true );
	Controls.SecondaryImageOpen:SetHide( false );
	Controls.SecondaryImageClosed:SetHide( true );
	Controls.WorkerProgressIconFrame:SetHide( true );
	Controls.WorkerProgressFrame:SetHide( true );
	g_bWorkerActionPanelOpen = false;
	g_bSpellPanelOpen = false;	--Paz add
	g_PromotionsOpen = false;
	g_SecondaryOpen = false;

	--Paz add
	--Controls.GPCycle:SetHide( false )
	--end Paz add

end


--------------------------------------------------------------------------------
-- Refresh unit promotions
--------------------------------------------------------------------------------
function UpdateUnitPromotions(unit)
    
    g_EarnedPromotionIM:ResetInstances();
    local controlTable;
    
    --For each avail promotion, display the icon
	--[[Paz modified below
    for unitPromotion in GameInfo.UnitPromotions() do

        local unitPromotionID = unitPromotion.ID;
        
		--Paz modified below: --if (unit:IsHasPromotion(unitPromotionID)) then
		if unit:IsHasPromotion(unitPromotionID) and not unitPromotion.EaHidden then
            
            controlTable = g_EarnedPromotionIM:GetInstance();
			IconHookup( unitPromotion.PortraitIndex, 32, unitPromotion.IconAtlas, controlTable.UnitPromotionImage );

            -- Tooltip
            local strToolTip = Locale.ConvertTextKey(unitPromotion.Description);
            strToolTip = strToolTip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey(unitPromotion.Help)
            controlTable.UnitPromotionImage:SetToolTipString(strToolTip);
            
        end
    end
	]]
	local lastPromoPrefix = ""
	for unitPromotionID = MapModData.HIGHEST_PROMOTION_ID, 0, -1 do
		if unit:IsHasPromotion(unitPromotionID) then
			local unitPromotion = GameInfo.UnitPromotions[unitPromotionID]
			if not unitPromotion.EaHidden then
				local unitPromotionType = unitPromotion.Type
				local suffixStart, suffixEnd = string.find(unitPromotionType, "_%d+$")	--match _digits only at end of string
				local prefix = suffixStart and string.sub(unitPromotionType, 1, suffixStart - 1)
				if prefix ~= lastPromoPrefix then		-- "" ~= nil
					lastPromoPrefix = prefix or ""

					--from base code:
					controlTable = g_EarnedPromotionIM:GetInstance();
					IconHookup( unitPromotion.PortraitIndex, 32, unitPromotion.IconAtlas, controlTable.UnitPromotionImage );

					-- Tooltip
					local strToolTip = Locale.ConvertTextKey(unitPromotion.Description);
					strToolTip = strToolTip .. "[NEWLINE][NEWLINE]" .. Locale.ConvertTextKey(unitPromotion.Help)
					controlTable.UnitPromotionImage:SetToolTipString(strToolTip);

				end
			end
		end
	end
	--end Paz modified
end

---------------------------------------------------
---- Promotion Help
---------------------------------------------------
--function PromotionHelpOpen(iPromotionID)
    --local pPromotionInfo = GameInfo.UnitPromotions[iPromotionID];
    --local promotionHelp = Locale.ConvertTextKey(pPromotionInfo.Description);
    --Controls.HelpText:SetText(promotionHelp);
--end

--------------------------------------------------------------------------------
-- Refresh unit stats
--------------------------------------------------------------------------------
function UpdateUnitStats(unit)
    
    -- update the background image (update this if we get icons for the minors)
    local civType = unit:GetCivilizationType();
	local civInfo = GameInfo.Civilizations[civType];
	local civPortraitIndex = civInfo.PortraitIndex;
    if civPortraitIndex < 0 or civPortraitIndex > 21 then
        civPortraitIndex = 22;
    end
    
    IconHookup( civPortraitIndex, 128, civInfo.IconAtlas, Controls.BackgroundCivSymbol );
  
    -- Movement
    if unit:GetDomainType() == DomainTypes.DOMAIN_AIR then
		local iRange = unit:Range();
		local szMoveStr = iRange .. " [ICON_MOVES]";	    
		Controls.UnitStatMovement:SetText(szMoveStr);
		--Paz disabled: Controls.UnitStatNameMovement:LocalizeAndSetText("TXT_KEY_UPANEL_RANGEMOVEMENT");
		
		local rebaseRange = iRange * GameDefines.AIR_UNIT_REBASE_RANGE_MULTIPLIER;
		rebaseRange = rebaseRange / 100;
		
		szMoveStr = Locale.ConvertTextKey( "TXT_KEY_UPANEL_UNIT_MAY_STRIKE_REBASE", iRange, rebaseRange );
		--Paz disabled: Controls.UnitStatNameMovement:SetToolTipString(szMoveStr);
		Controls.UnitStatMovement:SetToolTipString(szMoveStr);

    else
		local move_denominator = GameDefines["MOVE_DENOMINATOR"];
		local moves_left = unit:MovesLeft() / move_denominator;
		local max_moves = unit:MaxMoves() / move_denominator;
		local szMoveStr = math.floor(moves_left) .. "/" .. math.floor(max_moves) .. " [ICON_MOVES]";
	    
		Controls.UnitStatMovement:SetText(szMoveStr);
	    
		szMoveStr = Locale.ConvertTextKey( "TXT_KEY_UPANEL_UNIT_MAY_MOVE", moves_left );
		--Paz disabled:  Controls.UnitStatNameMovement:LocalizeAndSetText("TXT_KEY_UPANEL_MOVEMENT");
		--Paz disabled: Controls.UnitStatNameMovement:SetToolTipString(szMoveStr);
		Controls.UnitStatMovement:SetToolTipString(szMoveStr);
    end
    
	--Paz add: Rewrite most of this
	--	we don't need religious conversion stuff
	--	use UnitStrengthBox for Strength, Ranged and Morale

    local strength, ranged, morale = 0, 0, 0
    if(unit:GetDomainType() == DomainTypes.DOMAIN_AIR) then
        strength, morale = 0, 0
		ranged = unit:GetBaseRangedCombatStrength()
	elseif not unit:IsEmbarked() and not unit:IsGreatPerson() and not GameInfo.Units[unit:GetUnitType()].EaGPTempRole then
        strength = unit:GetBaseCombatStrength()
		ranged = unit:GetBaseRangedCombatStrength()
		morale = unit:GetMorale()
    end
	local strengthText = strength == 0 and "" or strength .. " [ICON_STRENGTH]"
	local rangedText = ranged == 0 and "" or "  " .. ranged .. " [ICON_RANGE_STRENGTH]"
	local moraleText = ""
	if morale ~= 0 then
		if morale < 0 then
			moraleText = "  [COLOR_WARNING_TEXT]" .. morale .. "%[ENDCOLOR] [ICON_HAPPINESS_4]"
		else
			moraleText = "  [COLOR_POSITIVE_TEXT]+" .. morale .. "%[ENDCOLOR] [ICON_HAPPINESS_1]"
		end
	end

	local strengthBoxText = strengthText .. rangedText .. moraleText
	if strengthBoxText ~= "" then
        Controls.UnitStrengthBox:SetHide(false)
        Controls.UnitStatStrength:SetText(strengthBoxText)
        local strengthTT = Locale.ConvertTextKey( "TXT_KEY_EA_UPANEL_STRENGTH_TT" )
        Controls.UnitStatStrength:SetToolTipString(strengthTT)
        --Controls.UnitStatNameStrength:SetToolTipString(strengthTT)
	else
		Controls.UnitStrengthBox:SetHide(true)
	end


	--end Paz add

	--[[Paz disable
    -- Strength
    local strength = 0;
    if(unit:GetDomainType() == DomainTypes.DOMAIN_AIR) then
        strength = unit:GetBaseRangedCombatStrength();
    elseif (not unit:IsEmbarked()) then
        strength = unit:GetBaseCombatStrength();
    end
    if(strength > 0) then
        strength = strength .. " [ICON_STRENGTH]";
        Controls.UnitStrengthBox:SetHide(false);
        Controls.UnitStatStrength:SetText(strength);
        local strengthTT = Locale.ConvertTextKey( "TXT_KEY_UPANEL_STRENGTH_TT" );
        Controls.UnitStatStrength:SetToolTipString(strengthTT);
        Controls.UnitStatNameStrength:SetToolTipString(strengthTT);
    -- Religious units
    elseif (unit:GetSpreadsLeft() > 0) then
        strength = unit:GetConversionStrength() .. " [ICON_PEACE]";
        Controls.UnitStrengthBox:SetHide(false);
        Controls.UnitStatStrength:SetText(strength);    
        local strengthTT = Locale.ConvertTextKey( "TXT_KEY_UPANEL_RELIGIOUS_STRENGTH_TT" );
        Controls.UnitStatStrength:SetToolTipString(strengthTT);
        Controls.UnitStatNameStrength:SetToolTipString(strengthTT);
    else
        Controls.UnitStrengthBox:SetHide(true);
    end        
    
    -- Ranged Strength
    local iRangedStrength = 0;
    if(unit:GetDomainType() ~= DomainTypes.DOMAIN_AIR) then
        iRangedStrength = unit:GetBaseRangedCombatStrength();
    else
        iRangedStrength = 0;
    end
    if(iRangedStrength > 0) then
        local szRangedStrength = iRangedStrength .. " [ICON_RANGE_STRENGTH]";
        Controls.UnitRangedAttackBox:SetHide(false);
        local rangeStrengthStr = Locale.ConvertTextKey( "TXT_KEY_UPANEL_RANGED_ATTACK" );
        Controls.UnitStatNameRangedAttack:SetText(rangeStrengthStr);
        Controls.UnitStatRangedAttack:SetText(szRangedStrength);
        local rangeStrengthTT = Locale.ConvertTextKey( "TXT_KEY_UPANEL_RANGED_ATTACK_TT" );
        Controls.UnitStatRangedAttack:SetToolTipString(rangeStrengthTT);
        Controls.UnitStatNameRangedAttack:SetToolTipString(rangeStrengthTT);
    -- Religious unit
    elseif (unit:GetSpreadsLeft() > 0) then
        iRangedStrength = unit:GetSpreadsLeft() .. "      ";
        Controls.UnitRangedAttackBox:SetHide(false);
        local rangeStrengthStr = Locale.ConvertTextKey( "TXT_KEY_UPANEL_SPREAD_RELIGION_USES" );
        Controls.UnitStatNameRangedAttack:SetText(rangeStrengthStr);
        Controls.UnitStatRangedAttack:SetText(iRangedStrength);    
        local rangeStrengthTT = Locale.ConvertTextKey( "TXT_KEY_UPANEL_SPREAD_RELIGION_USES_TT" );
        Controls.UnitStatRangedAttack:SetToolTipString(rangeStrengthTT);
        Controls.UnitStatNameRangedAttack:SetToolTipString(rangeStrengthTT);
    elseif (GameInfo.Units[unit:GetUnitType()].RemoveHeresy) then
        iRangedStrength = 1;
        Controls.UnitRangedAttackBox:SetHide(false);
        local rangeStrengthStr = Locale.ConvertTextKey( "TXT_KEY_UPANEL_REMOVE_HERESY_USES" );
        Controls.UnitStatNameRangedAttack:SetText(rangeStrengthStr);
        Controls.UnitStatRangedAttack:SetText(iRangedStrength);    
        local rangeStrengthTT = Locale.ConvertTextKey( "TXT_KEY_UPANEL_REMOVE_HERESY_USES_TT" );
        Controls.UnitStatRangedAttack:SetToolTipString(rangeStrengthTT);
        Controls.UnitStatNameRangedAttack:SetToolTipString(rangeStrengthTT);
    else
        Controls.UnitRangedAttackBox:SetHide(true);
    end        
    ]]
end

--------------------------------------------------------------------------------
-- Refresh unit health bar
--------------------------------------------------------------------------------
function UpdateUnitHealthBar(unit)
	-- note that this doesn't use the bar type
	local damage = unit:GetDamage();
	if damage == 0 then
		Controls.HealthBar:SetHide(true);	
	else	
		local healthPercent = 1.0 - (damage / MaxDamage);
		local healthTimes100 =  math.floor(100 * healthPercent + 0.5);
		local barSize = { x = 9, y = math.floor(123 * healthPercent) };
		if healthTimes100 <= 33 then
			Controls.RedBar:SetSize(barSize);
			Controls.RedAnim:SetSize(barSize);
			Controls.GreenBar:SetHide(true);
			Controls.YellowBar:SetHide(true);
			Controls.RedBar:SetHide(false);
		elseif healthTimes100 <= 66 then
			Controls.YellowBar:SetSize(barSize);
			Controls.GreenBar:SetHide(true);
			Controls.YellowBar:SetHide(false);
			Controls.RedBar:SetHide(true);
		else
			Controls.GreenBar:SetSize(barSize);
			Controls.GreenBar:SetHide(false);
			Controls.YellowBar:SetHide(true);
			Controls.RedBar:SetHide(true);
		end
		
		Controls.HealthBar:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_UPANEL_SET_HITPOINTS_TT",(MaxDamage-damage), MaxDamage ) );
		--Controls.HealthBar:SetToolTipString(healthPercent.." Hit Points");
		
		Controls.HealthBar:SetHide(false);
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- CycleLeft clicked event handler
--------------------------------------------------------------------------------
function OnCycleLeftClicked()
	--Paz add
	--LuaEvents.EaFunctionsDisappearBusyGPs(Game.GetActivePlayer())
	--end Paz add
    -- Cycle to next selection.
    Game.CycleUnits(true, true, false);
end
Controls.CycleLeft:RegisterCallback( Mouse.eLClick, OnCycleLeftClicked );


--------------------------------------------------------------------------------
-- CycleRight clicked event handler
--------------------------------------------------------------------------------
function OnCycleRightClicked()
	--Paz add
	--LuaEvents.EaFunctionsDisappearBusyGPs(Game.GetActivePlayer())
	--end Paz add
	-- Cycle to previous selection.
    Game.CycleUnits(true, false, false);
end
Controls.CycleRight:RegisterCallback( Mouse.eLClick, OnCycleRightClicked );

--------------------------------------------------------------------------------
-- Unit Name clicked event handler
--------------------------------------------------------------------------------
function OnUnitNameClicked()
	--Paz add:
	local unit = UI.GetHeadSelectedUnit();
	if unit then
		if unit:IsGreatPerson() then
			local iPerson = unit:GetPersonIndex()
			LuaEvents.EaImagePopup({type = "Person", id = iPerson})
			--Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_MODDER_1, Data1 = 1, Data2 = iPerson} )
			return
		end
	end
	--end Paz add

    -- go to this unit
    UI.LookAtSelectionPlot(0);
end
Controls.UnitNameButton:RegisterCallback( Mouse.eLClick, OnUnitNameClicked );
Controls.UnitPortraitButton:RegisterCallback( Mouse.eLClick, OnUnitNameClicked );



function OnUnitRClicked()
	local unit = UI.GetHeadSelectedUnit();
	if unit then

		--Paz add:
		if unit:IsGreatPerson() then
			local iPerson = unit:GetPersonIndex()
			LuaEvents.EaImagePopup({type = "Person", id = iPerson})
			--Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_MODDER_1, Data1 = 1, Data2 = iPerson} )
			return
		end
		--end Paz add

		-- search by name
		local searchString = Locale.ConvertTextKey( unit:GetNameKey() );
		Events.SearchForPediaEntry( searchString );
	end
end
Controls.UnitPortraitButton:RegisterCallback( Mouse.eRClick, OnUnitRClicked );

--------------------------------------------------------------------------------
-- InfoPane is now dirty.
--------------------------------------------------------------------------------
function OnInfoPaneDirty()
    --print("PazDebug UnitPanel OnInfoPanelDirty")
    -- Retrieve the currently selected unit.
    local unit = UI.GetHeadSelectedUnit();
    local name = unit and unit:GetNameKey() or "unit is nil";
    local convertedKey = Locale.ConvertTextKey(name);

    local unitID = unit and unit:GetID() or -1;

    -- Unit is different than last unit.
    if(unitID ~= g_lastUnitID) then
        local playerID = Game.GetActivePlayer();
        local unitPosition = {
            x = unit and unit:GetX() or 0,
            y = unit and unit:GetY() or 0,
        };
        local hexPosition = ToHexFromGrid(unitPosition);
        
        if(g_lastUnitID ~= -1) then
            Events.UnitSelectionChanged(playerID, g_lastUnitID, 0, 0, 0, false, false);
        end
        
        if(unitID ~= -1) then
            Events.UnitSelectionChanged(playerID, unitID, hexPosition.x, hexPosition.y, 0, true, false);
        end
        
        g_SecondaryOpen = false;
        Controls.PrimaryStack:SetHide( true );
        Controls.PrimaryStretchy:SetHide( true );
        Controls.SecondaryStack:SetHide( true );
        Controls.SecondaryStretchy:SetHide( true );
        Controls.SecondaryImageOpen:SetHide( false );
        Controls.SecondaryImageClosed:SetHide( true );
        Controls.SecondaryButton:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_SECONDARY_C_TEXT" ));
    end
    g_lastUnitID = unitID;
    
    if (unit ~= nil) then
        UpdateUnitActions(unit);
        UpdateUnitPortrait(unit);
        UpdateUnitPromotions(unit);
        UpdateUnitStats(unit);
        UpdateUnitHealthBar(unit);
        ContextPtr:SetHide( false );

    else

		-- Attempt to show currently selected city.
		local city = UI.GetHeadSelectedCity();
		if(city ~= nil) then
	
			UpdateCityPortrait(city);
				
		    ContextPtr:SetHide( false );
    	else
		    ContextPtr:SetHide( true );
    	end
    
    end
    
end
Events.SerialEventUnitInfoDirty.Add(OnInfoPaneDirty);


local g_iPortraitSize = 256;
local bOkayToProcess = true;

--Paz add
function OnEaActionClicked(eaActionID)
	if bOkayToProcess then
		local unit = UI.GetHeadSelectedUnit()
		local iPerson = unit:IsGreatPerson() and unit:GetPersonIndex() or nil
		if eaActionID == -1 then
			LuaEvents.EaActionsInterruptEaAction(unit:GetOwner(), iPerson)
			unit:DoCommand(CommandTypes.COMMAND_WAKE)
			Events.SerialEventUnitInfoDirty()
		elseif eaActionID < MapModData.FIRST_SPELL_ID then
			LuaEvents.EaActionsDoEaActionFromOtherState(eaActionID, unit:GetOwner(), unit, iPerson, unit:GetX(), unit:GetY())
		else
			LuaEvents.EaSpellsDoEaSpellFromOtherState(eaActionID, unit:GetOwner(), unit, iPerson, unit:GetX(), unit:GetY())
		end
	end
end
--end Paz add

--------------------------------------------------------------------------------
-- UnitAction<idx> was clicked.
--------------------------------------------------------------------------------
function OnUnitActionClicked( action )
	if bOkayToProcess then
		if (GameInfoActions[action].SubType == ActionSubTypes.ACTIONSUBTYPE_PROMOTION) then
			Events.AudioPlay2DSound("AS2D_INTERFACE_UNIT_PROMOTION");	
		end

		Game.HandleAction( action );
    end
end

function OnActivePlayerTurnEnd()
	bOkayToProcess = false;
end
Events.ActivePlayerTurnEnd.Add( OnActivePlayerTurnEnd );

function OnActivePlayerTurnStart()
	bOkayToProcess = true;
end
Events.ActivePlayerTurnStart.Add( OnActivePlayerTurnStart );

-------------------------------------------------
-------------------------------------------------
function OnEditNameClick()
	
	if UI.GetHeadSelectedUnit() then
		local popupInfo = {
				Type = ButtonPopupTypes.BUTTONPOPUP_RENAME_UNIT,
				Data1 = UI.GetHeadSelectedUnit():GetID(),
				Data2 = -1,
				Data3 = -1,
				Option1 = false,
				Option2 = false;
			}
		Events.SerialEventGameMessagePopup(popupInfo);
	end
end
Controls.EditButton:RegisterCallback( Mouse.eLClick, OnEditNameClick );

------------------------------------------------------
------------------------------------------------------
local tipControlTable = {};
TTManager:GetTypeControlTable( "TypeUnitAction", tipControlTable );

--Paz add
function EaTipHandler(control)
	local unit = UI.GetHeadSelectedUnit()
	if not unit then return	end
	local iPlayer = unit:GetOwner()
	local eaActionID = control:GetVoid1()
	local eaAction = GameInfo.EaActions[eaActionID]
	local iPerson = unit:IsGreatPerson() and unit:GetPersonIndex() or nil

	if eaActionID < MapModData.FIRST_SPELL_ID then
		LuaEvents.EaActionsTestEaActionForHumanUI(eaActionID, iPlayer, unit, iPerson, unit:GetX(), unit:GetY())
	else
		LuaEvents.EaSpellsTestEaSpellForHumanUI(eaActionID, iPlayer, unit, iPerson, unit:GetX(), unit:GetY())
	end
	local bAllow = MapModData.bAllow

	--print("EaTipHandler", eaActionID, bShow)

	tipControlTable.UnitActionHelp:SetText( "[NEWLINE]" .. MapModData.text )

	-- Title
    local text = eaAction.Description
	local turns = MapModData.integer
    local strTitleString = "[COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey( text ) .. "[ENDCOLOR]"
	if bAllow then
		if turns == 1000 then
			strTitleString = strTitleString .. " (Sustained)"
		elseif turns > 0 then
			strTitleString = strTitleString .. " ... " .. turns .. " Turns"
		end
	end

    tipControlTable.UnitActionText:SetText( strTitleString )
    
    -- HotKey
    
    --tipControlTable.UnitActionHotKey:SetText( "J" )

    -- Autosize tooltip
    tipControlTable.UnitActionMouseover:DoAutoSize()
    local mouseoverSize = tipControlTable.UnitActionMouseover:GetSize()
    if mouseoverSize.x < 350 then
		tipControlTable.UnitActionMouseover:SetSizeVal( 350, mouseoverSize.y )
    end
end

--end Paz add

function TipHandler( control )
	
	local unit = UI.GetHeadSelectedUnit();
	if not unit then
		return
	end
	
	local iAction = control:GetVoid1();
    local action = GameInfoActions[iAction];
    
    local iActivePlayer = Game.GetActivePlayer();
    local pActivePlayer = Players[iActivePlayer];
    local iActiveTeam = Game.GetActiveTeam();
    local pActiveTeam = Teams[iActiveTeam];
    
    local pPlot = unit:GetPlot();
    
    local bBuild = false;

    local bDisabled = false;
	
	-- Build data
	local iBuildID = action.MissionData;
	local pBuild = GameInfo.Builds[iBuildID];
	local strBuildType= "";
	if (pBuild) then
		strBuildType = pBuild.Type;
	end
	
	-- Improvement data
	local iImprovement = -1;
	local pImprovement;
	
	if (pBuild) then
		iImprovement = pBuild.ImprovementType;
		
		if (iImprovement and iImprovement ~= "NONE") then
			pImprovement = GameInfo.Improvements[iImprovement];
			iImprovement = pImprovement.ID;
		end
	end
    
    -- Feature data
	local iFeature = unit:GetPlot():GetFeatureType();
	local pFeature = GameInfo.Features[iFeature];
	local strFeatureType;
	if (pFeature) then
		strFeatureType = pFeature.Type;
	end
	
	-- Route data
	local iRoute = -1;
	local pRoute;
	
	if (pBuild) then
		iRoute = pBuild.RouteType
		
		if (iRoute and iRoute ~= "NONE") then
			pRoute = GameInfo.Routes[iRoute];
			iRoute = pRoute.ID;
		end
	end
	
	local strBuildTurnsString = "";
	local strBuildResourceConnectionString = "";
	local strClearFeatureString = "";
	local strBuildYieldString = "";
	
	local bFirstEntry = true;
	
	local strToolTip = "";
	
    local strDisabledString = "";
    
    local strActionHelp = "";
    
    -- Not able to perform action
    if not Game.CanHandleAction( iAction ) then
		bDisabled = true;
	end
    
    -- Upgrade has special help text
    if (action.Type == "COMMAND_UPGRADE") then
		
		-- Add spacing for all entries after the first
		if (bFirstEntry) then
			bFirstEntry = false;
		elseif (not bFirstEntry) then
			strActionHelp = strActionHelp .. "[NEWLINE]";
		end
		
		strActionHelp = strActionHelp .. "[NEWLINE]";
		
		local iUnitType = unit:GetUpgradeUnitType();
		local iGoldToUpgrade = unit:UpgradePrice(iUnitType);
		strActionHelp = strActionHelp .. Locale.ConvertTextKey("TXT_KEY_UPGRADE_HELP", GameInfo.Units[iUnitType].Description, iGoldToUpgrade);
		
        strToolTip = strToolTip .. strActionHelp;
        
		if bDisabled then
			
			local pActivePlayer = Players[Game.GetActivePlayer()];
			
			-- Can't upgrade because we're outside our territory
			if (pPlot:GetOwner() ~= unit:GetOwner()) then
				
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					bFirstEntry = false;
				elseif (not bFirstEntry) then
					strDisabledString = strDisabledString .. "[NEWLINE][NEWLINE]";
				end
				
				strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_UPGRADE_HELP_DISABLED_TERRITORY");
			end
			
			-- Can't upgrade because we're outside of a city
			if (unit:GetDomainType() == DomainTypes.DOMAIN_AIR and not pPlot:IsCity()) then
				
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					bFirstEntry = false;
				elseif (not bFirstEntry) then
					strDisabledString = strDisabledString .. "[NEWLINE][NEWLINE]";
				end
				
				strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_UPGRADE_HELP_DISABLED_CITY");
			end
			
			-- Can't upgrade because we lack the Gold
			if (iGoldToUpgrade > pActivePlayer:GetGold()) then
				
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					bFirstEntry = false;
				elseif (not bFirstEntry) then
					strDisabledString = strDisabledString .. "[NEWLINE][NEWLINE]";
				end
				
				strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_UPGRADE_HELP_DISABLED_GOLD");
			end
			
			-- Can't upgrade because we lack the Resources
			local strResourcesNeeded = "";
			
			local iNumResourceNeededToUpgrade;
			local iResourceLoop;
			
			-- Loop through all resources to see how many we need. If it's > 0 then add to the string
			for pResource in GameInfo.Resources() do
				iResourceLoop = pResource.ID;
				
				iNumResourceNeededToUpgrade = unit:GetNumResourceNeededToUpgrade(iResourceLoop);
				
				if (iNumResourceNeededToUpgrade > 0 and iNumResourceNeededToUpgrade > pActivePlayer:GetNumResourceAvailable(iResourceLoop)) then
					-- Add separator for non-initial entries
					if (strResourcesNeeded ~= "") then
						strResourcesNeeded = strResourcesNeeded .. ", ";
					end
					
					strResourcesNeeded = strResourcesNeeded .. iNumResourceNeededToUpgrade .. " " .. pResource.IconString .. " " .. Locale.ConvertTextKey(pResource.Description);
				end
			end
			
			-- Build resources required string
			if (strResourcesNeeded ~= "") then
				
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					bFirstEntry = false;
				elseif (not bFirstEntry) then
					strDisabledString = strDisabledString .. "[NEWLINE][NEWLINE]";
				end
				
				strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_UPGRADE_HELP_DISABLED_RESOURCES", strResourcesNeeded);
			end
    
    	        -- if we can't upgrade due to stacking
	        if (pPlot:GetNumFriendlyUnitsOfType(unit) > 1) then
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					bFirstEntry = false;
				elseif (not bFirstEntry) then
					strDisabledString = strDisabledString .. "[NEWLINE][NEWLINE]";
				end
				
				strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_UPGRADE_HELP_DISABLED_STACKING");

	        end
    
	        strDisabledString = "[COLOR_WARNING_TEXT]" .. strDisabledString .. "[ENDCOLOR]";	        
		end
    end
    
    if (action.Type == "MISSION_ALERT" and not unit:IsEverFortifyable()) then
		-- Add spacing for all entries after the first
		if (bFirstEntry) then
			bFirstEntry = false;
		elseif (not bFirstEntry) then
			strActionHelp = strActionHelp .. "[NEWLINE]";
		end

		strActionHelp = "[NEWLINE]" .. Locale.ConvertTextKey("TXT_KEY_MISSION_ALERT_NO_FORTIFY_HELP");
		strToolTip = strToolTip .. strActionHelp;

    -- Golden Age has special help text
    elseif (action.Type == "MISSION_GOLDEN_AGE") then
		-- Add spacing for all entries after the first
		if (bFirstEntry) then
			bFirstEntry = false;
		elseif (not bFirstEntry) then
			strActionHelp = strActionHelp .. "[NEWLINE]";
		end
		
		local iGALength = unit:GetGoldenAgeTurns();
		strActionHelp = "[NEWLINE]" .. Locale.ConvertTextKey( "TXT_KEY_MISSION_START_GOLDENAGE_HELP", iGALength );
        strToolTip = strToolTip .. strActionHelp;
		
    -- Spread Religion has special help text
    elseif (action.Type == "MISSION_SPREAD_RELIGION") then
    
		local iNumFollowers = unit:GetNumFollowersAfterSpread();
		local religionName = Game.GetReligionName(unit:GetReligion());
		
        strToolTip = strToolTip .. Locale.ConvertTextKey("TXT_KEY_MISSION_SPREAD_RELIGION_HELP");
        strToolTip = strToolTip .. "[NEWLINE]----------------[NEWLINE]";
        strToolTip = strToolTip .. Locale.ConvertTextKey("TXT_KEY_MISSION_SPREAD_RELIGION_RESULT", religionName, iNumFollowers);
		strToolTip = strToolTip .. " ";  
		    
 		local eMajorityReligion = unit:GetMajorityReligionAfterSpread();
        if (eMajorityReligion < ReligionTypes.RELIGION_PANTHEON) then
			strToolTip = strToolTip .. Locale.ConvertTextKey("TXT_KEY_MISSION_MAJORITY_RELIGION_NONE");
		else
			local majorityReligionName = Locale.Lookup(Game.GetReligionName(eMajorityReligion));
			strToolTip = strToolTip .. Locale.ConvertTextKey("TXT_KEY_MISSION_MAJORITY_RELIGION", majorityReligionName);		
		end

    -- Help text
    elseif (action.Help and action.Help ~= "") then
		
		-- Add spacing for all entries after the first
		if (bFirstEntry) then
			bFirstEntry = false;
		elseif (not bFirstEntry) then
			strActionHelp = strActionHelp .. "[NEWLINE]";
		end
		
		strActionHelp = "[NEWLINE]" .. Locale.ConvertTextKey( action.Help );
        strToolTip = strToolTip .. strActionHelp;
	end
    
    -- Delete has special help text
    if (action.Type == "COMMAND_DELETE") then
		
		strActionHelp = "";
		
		-- Add spacing for all entries after the first
		if (bFirstEntry) then
			bFirstEntry = false;
		elseif (not bFirstEntry) then
			strActionHelp = strActionHelp .. "[NEWLINE]";
		end
		
		strActionHelp = strActionHelp .. "[NEWLINE]";
		
		local iGoldToScrap = unit:GetScrapGold();
		
		strActionHelp = strActionHelp .. Locale.ConvertTextKey("TXT_KEY_SCRAP_HELP", iGoldToScrap);
		
        strToolTip = strToolTip .. strActionHelp;
	end
	
	-- Build?
    if (action.SubType == ActionSubTypes.ACTIONSUBTYPE_BUILD) then
		bBuild = true;
	end
	
    -- Not able to perform action
    if (bDisabled) then
		
		-- Worker build
		if (bBuild) then
			
			-- Figure out what the name of the thing is that we're looking at
			local strImpRouteKey = "";
			if (pImprovement) then
				strImpRouteKey = pImprovement.Description;
			elseif (pRoute) then
				strImpRouteKey = pRoute.Description;
			end
			
			-- Don't have Tech for Build?
			if (pBuild.PrereqTech ~= nil) then
				local pPrereqTech = GameInfo.Technologies[pBuild.PrereqTech];
				local iPrereqTech = pPrereqTech.ID;
				if (iPrereqTech ~= -1 and not pActiveTeam:GetTeamTechs():HasTech(iPrereqTech)) then
					
					-- Must not be a build which constructs something
					if (pImprovement or pRoute) then
						
						-- Add spacing for all entries after the first
						if (bFirstEntry) then
							bFirstEntry = false;
						elseif (not bFirstEntry) then
							strDisabledString = strDisabledString .. "[NEWLINE]";
						end
						
						strDisabledString = strDisabledString .. "[NEWLINE]";
						strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_BUILD_BLOCKED_PREREQ_TECH", pPrereqTech.Description, strImpRouteKey);
					end
				end
			end
			
			-- Trying to build something and are not adjacent to our territory?
			if (pImprovement and pImprovement.InAdjacentFriendly) then
				if (pPlot:GetTeam() ~= unit:GetTeam()) then
					if (not pPlot:IsAdjacentTeam(unit:GetTeam(), true)) then

					
						-- Add spacing for all entries after the first
						if (bFirstEntry) then
							bFirstEntry = false;
						elseif (not bFirstEntry) then
							strDisabledString = strDisabledString .. "[NEWLINE]";
						end
					
						strDisabledString = strDisabledString .. "[NEWLINE]";
						strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_BUILD_BLOCKED_NOT_IN_ADJACENT_TERRITORY", strImpRouteKey);
					end
				end

			-- Trying to build something outside of our territory?
			elseif (pImprovement and not pImprovement.OutsideBorders) then
				if (pPlot:GetTeam() ~= unit:GetTeam()) then
				
					
					-- Add spacing for all entries after the first
					if (bFirstEntry) then
						bFirstEntry = false;
					elseif (not bFirstEntry) then
						strDisabledString = strDisabledString .. "[NEWLINE]";
					end
					
					strDisabledString = strDisabledString .. "[NEWLINE]";
					strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_BUILD_BLOCKED_OUTSIDE_TERRITORY", strImpRouteKey);
				end
			end
			
			-- Build blocked by a feature here?
			if (pActivePlayer:IsBuildBlockedByFeature(iBuildID, iFeature)) then
				local iFeatureTech;
				
				local filter = "BuildType = '" .. strBuildType .. "' and FeatureType = '" .. strFeatureType .. "'";
				for row in GameInfo.BuildFeatures(filter) do
					iFeatureTech = GameInfo.Technologies[row.PrereqTech].ID;
				end
				
				local pFeatureTech = GameInfo.Technologies[iFeatureTech];
				
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					bFirstEntry = false;
				elseif (not bFirstEntry) then
					strDisabledString = strDisabledString .. "[NEWLINE]";
				end
				
				strDisabledString = strDisabledString .. "[NEWLINE]";
				strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_BUILD_BLOCKED_BY_FEATURE", pFeatureTech.Description, pFeature.Description);
			end
			
		-- Not a Worker build, use normal disabled help from XML
		else
			
            if (action.Type == "MISSION_FOUND" and pActivePlayer:IsEmpireVeryUnhappy()) then
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					bFirstEntry = false;
				elseif (not bFirstEntry) then
					strDisabledString = strDisabledString .. "[NEWLINE][NEWLINE]";
				end
				
				strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_MISSION_BUILD_CITY_DISABLED_UNHAPPY");
			
            elseif (action.Type == "MISSION_CULTURE_BOMB" and pActivePlayer:GetCultureBombTimer() > 0) then
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					bFirstEntry = false;
				elseif (not bFirstEntry) then
					strDisabledString = strDisabledString .. "[NEWLINE][NEWLINE]";
				end
				
				strDisabledString = strDisabledString .. Locale.ConvertTextKey("TXT_KEY_MISSION_CULTURE_BOMB_DISABLED_COOLDOWN", pActivePlayer:GetCultureBombTimer());
				
			elseif (action.DisabledHelp and action.DisabledHelp ~= "") then
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					bFirstEntry = false;
				elseif (not bFirstEntry) then
					strDisabledString = strDisabledString .. "[NEWLINE][NEWLINE]";
				end
				
				strDisabledString = strDisabledString .. Locale.ConvertTextKey(action.DisabledHelp);
			end
		end
		
        strDisabledString = "[COLOR_WARNING_TEXT]" .. strDisabledString .. "[ENDCOLOR]";
        strToolTip = strToolTip .. strDisabledString;
        
    end
    
	-- Is this a Worker build?
	if (bBuild) then
		
		local iExtraBuildRate = 0;
		
		-- Are we building anything right now?
		local iCurrentBuildID = unit:GetBuildType();
		if (iCurrentBuildID == -1 or iBuildID ~= iCurrentBuildID) then
			iExtraBuildRate = unit:WorkRate(true, iBuildID);
		end
		
		local iBuildTurns = pPlot:GetBuildTurnsLeft(iBuildID, Game.GetActivePlayer(), iExtraBuildRate, iExtraBuildRate);
		--print("iBuildTurns: " .. iBuildTurns);
		if (iBuildTurns > 1) then
			strBuildTurnsString = " ... " .. Locale.ConvertTextKey("TXT_KEY_BUILD_NUM_TURNS", iBuildTurns);
		end
		
		-- Extra Yield from this build
		local iYieldChange;
		
		local bFirstYield = true;
		
		for iYield = 0, YieldTypes.NUM_YIELD_TYPES-1, 1 
		do
			iYieldChange = pPlot:GetYieldWithBuild(iBuildID, iYield, false, iActivePlayer);
			iYieldChange = iYieldChange - pPlot:CalculateYield(iYield);
			
			if (iYieldChange ~= 0) then
				
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					--strBuildYieldString = strBuildYieldString .. "[NEWLINE]";
					bFirstEntry = false;
				elseif (not bFirstEntry and bFirstYield) then
					strBuildYieldString = strBuildYieldString .. "[NEWLINE]";
				end
				
				strBuildYieldString = strBuildYieldString .. "[NEWLINE]";
				
				-- Positive or negative change?
				if (iYieldChange > -1) then
					strBuildYieldString = strBuildYieldString .. "[COLOR_POSITIVE_TEXT]+";
				else
					strBuildYieldString = strBuildYieldString .. "[COLOR_NEGATIVE_TEXT]";
				end
				
				if (iYield == YieldTypes.YIELD_FOOD) then
					strBuildYieldString = strBuildYieldString .. Locale.ConvertTextKey("TXT_KEY_BUILD_FOOD_STRING", iYieldChange);
				elseif (iYield == YieldTypes.YIELD_PRODUCTION) then
					strBuildYieldString = strBuildYieldString .. Locale.ConvertTextKey("TXT_KEY_BUILD_PRODUCTION_STRING", iYieldChange);
				elseif (iYield == YieldTypes.YIELD_GOLD) then
					strBuildYieldString = strBuildYieldString .. Locale.ConvertTextKey("TXT_KEY_BUILD_GOLD_STRING", iYieldChange);
				elseif (iYield == YieldTypes.YIELD_SCIENCE) then
					strBuildYieldString = strBuildYieldString .. Locale.ConvertTextKey("TXT_KEY_BUILD_SCIENCE_STRING", iYieldChange);
				elseif (iYield == YieldTypes.YIELD_CULTURE) then
					strBuildYieldString = strBuildYieldString .. Locale.ConvertTextKey("TXT_KEY_BUILD_CULTURE_STRING", iYieldChange);
				elseif (iYield == YieldTypes.YIELD_FAITH) then
					strBuildYieldString = strBuildYieldString .. Locale.ConvertTextKey("TXT_KEY_BUILD_FAITH_STRING", iYieldChange);
				end
				
				bFirstYield = false;
			end
		end
		
        strToolTip = strToolTip .. strBuildYieldString;
		
		-- Resource connection
		if (pImprovement) then 
			local iResourceID = pPlot:GetResourceType(iActiveTeam);
			if (iResourceID ~= -1) then
				if (pPlot:IsResourceConnectedByImprovement(iImprovement)) then
					if (Game.GetResourceUsageType(iResourceID) ~= ResourceUsageTypes.RESOURCEUSAGE_BONUS) then
						local pResource = GameInfo.Resources[pPlot:GetResourceType(iActiveTeam)];
						local strResourceString = pResource.Description;
						
						-- Add spacing for all entries after the first
						if (bFirstEntry) then
							bFirstEntry = false;
						elseif (not bFirstEntry) then
							strBuildResourceConnectionString = strBuildResourceConnectionString .. "[NEWLINE]";
						end
						
						strBuildResourceConnectionString = strBuildResourceConnectionString .. "[NEWLINE]";
						strBuildResourceConnectionString = strBuildResourceConnectionString .. Locale.ConvertTextKey("TXT_KEY_BUILD_CONNECTS_RESOURCE", pResource.IconString, strResourceString);
						
						strToolTip = strToolTip .. strBuildResourceConnectionString;
					end
				end
			end
		end
		
		-- Production for clearing a feature
		if (pFeature) then
			local bFeatureRemoved = pPlot:IsBuildRemovesFeature(iBuildID);
			if (bFeatureRemoved) then
				
				-- Add spacing for all entries after the first
				if (bFirstEntry) then
					bFirstEntry = false;
				elseif (not bFirstEntry) then
					strClearFeatureString = strClearFeatureString .. "[NEWLINE]";
				end
				
				strClearFeatureString = strClearFeatureString .. "[NEWLINE]";
				strClearFeatureString = strClearFeatureString .. Locale.ConvertTextKey("TXT_KEY_BUILD_FEATURE_CLEARED", pFeature.Description);
			end
			
			local iFeatureProduction = pPlot:GetFeatureProduction(iBuildID, iActiveTeam);
			if (iFeatureProduction > 0) then
				strClearFeatureString = strClearFeatureString .. Locale.ConvertTextKey("TXT_KEY_BUILD_FEATURE_PRODUCTION", iFeatureProduction);
				
			-- Add period to end if we're not going to append info about feature production
			elseif (bFeatureRemoved) then
				strClearFeatureString = strClearFeatureString .. ".";
			end
			
			strToolTip = strToolTip .. strClearFeatureString;
		end
	end
    
    -- Tooltip
    if (strToolTip and strToolTip ~= "") then
        tipControlTable.UnitActionHelp:SetText( strToolTip );
    end
	
	-- Title
    local text = action.TextKey or action.Type or "Action"..(buttonIndex - 1);
    local strTitleString = "[COLOR_POSITIVE_TEXT]" .. Locale.ConvertTextKey( text ) .. "[ENDCOLOR]".. strBuildTurnsString;
    tipControlTable.UnitActionText:SetText( strTitleString );
    
    -- HotKey
    if action.SubType == ActionSubTypes.ACTIONSUBTYPE_PROMOTION then
        tipControlTable.UnitActionHotKey:SetText( "" );
    elseif action.HotKey and action.HotKey ~= "" then
        tipControlTable.UnitActionHotKey:SetText( "("..tostring(action.HotKey)..")" );
    else
        tipControlTable.UnitActionHotKey:SetText( "" );
    end
    
    -- Autosize tooltip
    tipControlTable.UnitActionMouseover:DoAutoSize();
    local mouseoverSize = tipControlTable.UnitActionMouseover:GetSize();
    if mouseoverSize.x < 350 then
		tipControlTable.UnitActionMouseover:SetSizeVal( 350, mouseoverSize.y );
    end

end


function ShowHideHandler( bIshide, bIsInit )
    if( bIshide ) then
        local EnemyUnitPanel = ContextPtr:LookUpControl( "/InGame/WorldView/EnemyUnitPanel" );
        if( EnemyUnitPanel ~= nil ) then
            EnemyUnitPanel:SetHide( true );
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
function OnActivePlayerChanged(iActivePlayer, iPrevActivePlayer)
	g_lastUnitID = -1;
	OnInfoPaneDirty();
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged);

function OnEnemyPanelHide( bIsEnemyPanelHide )
    if( g_bWorkerActionPanelOpen ) then
        Controls.WorkerActionPanel:SetHide( not bIsEnemyPanelHide );
    end
	--Paz add
    if( g_bSpellPanelOpen ) then
        Controls.SpellPanel:SetHide( not bIsEnemyPanelHide );
    end
	--end Paz add
end
LuaEvents.EnemyPanelHide.Add( OnEnemyPanelHide );

OnInfoPaneDirty();
