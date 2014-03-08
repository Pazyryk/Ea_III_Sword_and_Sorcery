-- EaErrorPopup
-- Author: Pazyryk
-- DateCreated: 1/15/2013 8:17:14 PM
--------------------------------------------------------------

local g_bUpdateErrorPopup = true

function DoErrorPopup(str)
	if g_bUpdateErrorPopup then
		local text = "There have been one or more program errors:[NEWLINE][NEWLINE]" .. (str or "")
			.. "[NEWLINE][NEWLINE](If you have set LoggingEnabled = 1 in your config.ini, then this messege has been printed in the Lua.log)"
		if not debug then
			text = text .. "[NEWLINE][NEWLINE](Please also set EnableLuaDebugLibrary = 1 for more informative error reporting; it is currently set to 0)"
		end
		text = text ..  "[NEWLINE][NEWLINE]Please relax, post your Lua.log on the mod thread, and go have a beer..."
		Controls.DescriptionLabel:SetText(text)
		ContextPtr:SetHide(false)
		g_bUpdateErrorPopup = false
	end
end
LuaEvents.EaErrorPopupDoErrorPopup.Add(DoErrorPopup)

function CloseErrorPopup()
	g_bUpdateErrorPopup = true
	ContextPtr:SetHide(true)
end
Controls.CloseErrorButton:RegisterCallback(Mouse.eLClick, CloseErrorPopup)

ContextPtr:SetHide(true)