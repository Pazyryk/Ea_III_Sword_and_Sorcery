-------------------------------------------------
-- Main Menu
-------------------------------------------------

-------------------------------------------------
-- Exit Button Handler
-------------------------------------------------
function OnExitGame()
	print("OnExitGame") --Paz added
    --UIManager:QueuePopup( ContextPtr, PopupPriority.eUtmost );
	UIManager:PushModal( ContextPtr );
end
Events.UserRequestClose.Add( OnExitGame );

----------------------------------------------------------------        
----------------------------------------------------------------
function OnYes( )
	print("Player confirmed Yes") --Paz added

	--UIManager:DequeuePopup( ContextPtr );
	UIManager:PopModal( ContextPtr );

	--Paz add: undo hijacks
	local EaSetupDB = Modding.OpenUserData("EaSetupData", 1)
	--[[
	local eaAutoSaveFreq = EaSetupDB.GetValue("EA_AUTO_SAVE_FREQ")
	if eaAutoSaveFreq then
		if eaAutoSaveFreq == 999 then		--game crashed and we lost original value; set to 1 (better if mod players are confused than angry)
			eaAutoSaveFreq = 1
		end
		print("Restoring base autosave frequency ", eaAutoSaveFreq)
		OptionsManager.SetTurnsBetweenAutosave_Cached(eaAutoSaveFreq)	--restore to what it was

		print("Cached = ", OptionsManager.GetTurnsBetweenAutosave_Cached())
	end
	]]
	local autoUIAssets = EaSetupDB.GetValue("AUTO_UI_ASSETS_FOR_RESTORATION")
	local smallUIAssets = EaSetupDB.GetValue("SMALL_UI_ASSETS_FOR_RESTORATION")
	if autoUIAssets and smallUIAssets then
		print("Restoring AutoUIAssets and SmallUIAssets ", autoUIAssets, smallUIAssets)
		OptionsManager.SetAutoUIAssets_Cached(autoUIAssets == 1)
		OptionsManager.SetSmallUIAssets_Cached(smallUIAssets == 1)
	end

	OptionsManager.CommitGameOptions()

	--end Paz add

	UI.ExitGame();

end
Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes );


----------------------------------------------------------------        
----------------------------------------------------------------
function OnNo( )
	UIManager:PopModal( ContextPtr );
end
Controls.No:RegisterCallback( Mouse.eLClick, OnNo );

----------------------------------------------------------------  
----------------------------------------------------------------        
function OnShowHide( isHide, isInit )
	
	if(not isHide) then
	
		-- Update key depending on whether or not we're in a game.
		local inGame = ContextPtr:LookUpControl("/InGame");
		local bIsInGame = (inGame ~= nil);
		
		Controls.Message:LocalizeAndSetText(bIsInGame and "TXT_KEY_MENU_RETURN_EXIT_WARN" or "TXT_KEY_MENU_EXIT_WARN" );
	end	
end
ContextPtr:SetShowHideHandler( OnShowHide );


----------------------------------------------------------------        
----------------------------------------------------------------        
function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE then
            OnNo()
        end
    end
    return true;
end
ContextPtr:SetInputHandler( InputHandler );
