-- EaTraditionGenericPopup
-- Author: Pazyryk
-- DateCreated: 9/8/2012 7:51:26 AM
--------------------------------------------------------------
--included by this added line in GenericPopup.lua:
--files = include("EaGenericPopup")


--NOT USED NOW; left here as template for new generic popup

-- This popup occurs when a player opens Tradition (and is not getting trait-specific GP from it)
PopupLayouts[ButtonPopupTypes.BUTTONPOPUP_MODDER_0] = function(popupInfo)
	
	-- Initialize popup text.	
	SetPopupText("Chose a Sage or an Artist")
	
	-- Initialize 'Sage' button.
	local OnSageClicked = function()
		MapModData.class = "Sage"
		print("OnSageClicked")
		LuaEvents.EaPeopleGenerateGreatPerson(Game.GetActivePlayer(), "Sage", nil)
	end
	
	AddButton("Sage", OnSageClicked)

	-- Initialize 'Artist' button.
	local OnArtistClicked = function()
		MapModData.class = "Artist"
		print("OnArtistClicked")
		LuaEvents.EaPeopleGenerateGreatPerson(Game.GetActivePlayer(), "Artist", nil)
	end
	
	AddButton("Artist", OnArtistClicked)
	
	Controls.CloseButton:SetHide( false );

end

--[[
----------------------------------------------------------------        
-- Key Down Processing
----------------------------------------------------------------        
PopupInputHandlers[ButtonPopupTypes.BUTTONPOPUP_MODDER_0] = function( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if( wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN ) then
			HideWindow();
            return true;
        end
    end
end

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
Events.GameplaySetActivePlayer.Add(HideWindow);
]]