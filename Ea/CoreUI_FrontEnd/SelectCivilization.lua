-------------------------------------------------
-- Select Civilization
-------------------------------------------------
--Paz: This file is a complete replacement using non-civ selection as template

include( "IconSupport" );

-------------------------------------------------
-------------------------------------------------
function OnBack()
    ContextPtr:SetHide( true );
    ContextPtr:LookUpControl( "../MainSelection" ):SetHide( false );
    ContextPtr:LookUpControl( ".." ):SetHide( false );
end
Controls.BackButton:RegisterCallback( Mouse.eLClick, OnBack );


----------------------------------------------------------------        
-- Input processing
----------------------------------------------------------------        
function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE then
            OnBack();
            return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler )


----------------------------------------------------------------        
-- set Race
----------------------------------------------------------------        
function EaRaceSelected( id )
    PreGame.SetCivilization( 0, id )
    OnBack()
end


----------------------------------------------------------------        
----------------------------------------------------------------        
function ShowHideHandler( bIsHide )
    if( not bIsHide ) then
        Controls.ScrollPanel:SetScrollValue( 0 )
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler )


----------------------------------------------------------------        
-- build the buttons (stop when EaRaceSelectionText is nil)
----------------------------------------------------------------        

local id = -1
local controlTable = {}
ContextPtr:BuildInstanceForControl( "ItemInstance", controlTable, Controls.Stack )
IconHookup( 22, 64, "LEADER_ATLAS", controlTable.Icon )
controlTable.Help:SetText( Locale.ConvertTextKey( "TXT_KEY_EA_RANDOM_RACE_HELP" ) )
controlTable.Name:SetText( Locale.ConvertTextKey( "TXT_KEY_EA_RANDOM_RACE" ) )
controlTable.Button:SetToolTipString( Locale.ConvertTextKey( "TXT_KEY_EA_RANDOM_RACE_HELP" ) )
controlTable.Button:SetVoid1( id )
controlTable.Button:RegisterCallback( Mouse.eLClick, EaRaceSelected )

while true do
	id = id + 1
	local info = GameInfo.Civilizations[id]
	if not (info and info.EaRaceSelectionText) then
		break
	end
	local controlTable = {}
	ContextPtr:BuildInstanceForControl( "ItemInstance", controlTable, Controls.Stack )
	IconHookup( info.PortraitIndex, 64, info.IconAtlas, controlTable.Icon )
	controlTable.Help:SetText( Locale.ConvertTextKey( info.EaRaceSelectionText ) )	
	controlTable.Name:SetText( Locale.ConvertTextKey( info.Description ) )
	controlTable.Button:SetToolTipString( Locale.ConvertTextKey( info.EaRaceSelectionText ) )	--TO DO: change to long pedia text when we have it
	controlTable.Button:SetVoid1( id )
	controlTable.Button:RegisterCallback( Mouse.eLClick, EaRaceSelected )
end

Controls.Stack:CalculateSize()
Controls.Stack:ReprocessAnchoring()
Controls.ScrollPanel:CalculateInternalSize()