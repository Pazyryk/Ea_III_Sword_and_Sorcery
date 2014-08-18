-- EaAchievedCivNamePopup
-- Author: Pazyryk
-- DateCreated: 1/5/2014 11:20:27 AM
--------------------------------------------------------------
print("Loading EaAchievedCivNamePopup.lua...")

include("EaCivTextHelper.lua")

MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

local g_editMode = false
local g_eaCivID

function Show(iPlayer, eaCivID)
	g_eaCivID = eaCivID
	local eaPlayer = gT.gPlayers[iPlayer] 
	if not eaPlayer then return end
	local eaCivInfo = GameInfo.EaCivs[eaCivID]
	MapModData.editCivName = Locale.ConvertTextKey(eaCivInfo.Description)
	MapModData.editCivShortName = Locale.ConvertTextKey(eaCivInfo.ShortDescription)
	MapModData.editCivAdjective = Locale.ConvertTextKey(eaCivInfo.Adjective)

	local popupText = Locale.ConvertTextKey("TXT_KEY_EA_POPUP_CIV_NAMING", MapModData.editCivName)
	popupText = popupText .. "[NEWLINE][NEWLINE]" .. GetEaCivDiscriptionText(eaCivID, false, false, true, false)
	Controls.PopupText:SetText(popupText)

	ContextPtr:SetHide(false)
	ShowButtons()

	Controls.AcceptButton:RegisterCallback(Mouse.eLClick, function()
		ContextPtr:SetHide(true)
		eaPlayer.turnBlockEaCivNamingID = false		--removes turn block
		LuaEvents.EaCivNamingSetNewCivName(iPlayer, eaCivID)	
	end)

	Controls.RenameButton:RegisterCallback(Mouse.eLClick, ShowRename)

	Controls.NotYetButton:RegisterCallback(Mouse.eLClick, function()
		ContextPtr:SetHide(true)
	end)

	if eaPlayer.declinedNameID then
		Controls.DeclineButton:SetDisabled(true)
	else
		Controls.DeclineButton:SetDisabled(false)
		Controls.DeclineButton:RegisterCallback(Mouse.eLClick, function()
			eaPlayer.declinedNameID = eaCivID
			eaPlayer.turnBlockEaCivNamingID = false		--removes turn block
			ContextPtr:SetHide(true)
		end)
	end

	Controls.RenameCancelButton:RegisterCallback(Mouse.eLClick, OnRenameCancelButton)
	Controls.RenameAcceptButton:RegisterCallback(Mouse.eLClick, OnRenameAcceptButton)
end
LuaEvents.EaAchievedCivNamePopup.Add(Show)

function ShowButtons()
	Controls.AcceptButton:SetHide(false)
	Controls.RenameButton:SetHide(false)
	Controls.NotYetButton:SetHide(false)
	Controls.DeclineButton:SetHide(false)
	Controls.RenameBox:SetHide(true)
	Controls.ButtonStack:CalculateSize()
	Controls.ButtonStackFrame:DoAutoSize()
	g_editMode = false
	Events.KeyUpEvent.Remove(OnKeyUp)
end

function ShowRename()
	Controls.AcceptButton:SetHide(true)
	Controls.RenameButton:SetHide(true)
	Controls.NotYetButton:SetHide(true)
	Controls.DeclineButton:SetHide(true)
	Controls.RenameBox:SetHide(false)
	g_editMode = true
	Events.KeyUpEvent.Add(OnKeyUp)

	local iBoxHeight = 360		
	local frameSize = {}
	frameSize = Controls.RenameBox:GetSize()
	frameSize.y = iBoxHeight
	Controls.RenameBox:SetSize( frameSize )
	frameSize = Controls.BackgroundBox:GetSize()
	frameSize.y = iBoxHeight
	Controls.BackgroundBox:SetSize( frameSize )
	frameSize = Controls.FrameBox:GetSize()
	frameSize.y = iBoxHeight
	Controls.FrameBox:SetSize( frameSize )
	Controls.EditCivName:SetText(MapModData.editCivName)
	Controls.EditCivShortName:SetText(MapModData.editCivShortName)
	Controls.EditCivAdjective:SetText(MapModData.editCivAdjective)
    Controls.RenameAcceptButton:SetDisabled(true)	
	Controls.EditCivName:TakeFocus()
	Controls.ButtonStack:CalculateSize()
	Controls.ButtonStackFrame:DoAutoSize()
end

function OnRenameCancelButton()
	ShowButtons()
end

function OnRenameAcceptButton()

	MapModData.editCivName = Controls.EditCivName:GetText()
	MapModData.editCivShortName = Controls.EditCivShortName:GetText()
	MapModData.editCivAdjective = Controls.EditCivAdjective:GetText()

	local popupText = Locale.ConvertTextKey("TXT_KEY_EA_POPUP_CIV_NAMING", MapModData.editCivName)
	popupText = popupText .. "[NEWLINE][NEWLINE]" .. GetEaCivDiscriptionText(g_eaCivID, false, false, true, false)
	Controls.PopupText:SetText(popupText)

	ShowButtons()
end

----------------------------------------------------------------
-- Input processing
----------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    if g_editMode and uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE then
            OnRenameCancelButton()
        elseif wParam == Keys.VK_RETURN then
            OnRenameAcceptButton() 
        end
    end
    return true
end
ContextPtr:SetInputHandler(InputHandler)

function OnKeyUp(wParam)
	if wParam == Keys.VK_CONTROL then
		print("Cntr key detected")
		CycleLastLetter()
	end
end


----------------------------------------------------------------
-- Edit processing
----------------------------------------------------------------

local c = string.char
local byte = string.byte
local sub = string.sub

local letters = {}
letters.a = {c(195,160),c(195,161),c(195,162),c(195,163),c(195,164),c(195,165),c(195,166)}
letters.e = {c(195,168),c(195,169),c(195,170),c(195,171)}
letters.i = {c(195,172),c(195,173),c(195,174),c(195,175)}
letters.o = {c(195,178),c(195,179),c(195,180),c(195,181),c(195,182),c(195,184),c(197,147)}
letters.u = {c(195,185),c(195,186),c(195,187),c(195,188)}
letters.y = {c(195,189)}
letters.t = {c(195,176),c(195,190)}
letters.n = {c(195,177)}
letters.c = {c(195,167)}
letters.r = {c(197,153)}
letters.A = {c(195,128),c(195,129),c(195,130),c(195,131),c(195,132),c(195,133),c(195,134)}
letters.E = {c(195,136),c(195,137),c(195,138),c(195,139)}
letters.I = {c(195,140),c(195,141),c(195,142),c(195,143)}
letters.O = {c(195,146),c(195,147),c(195,148),c(195,149),c(195,150),c(195,152),c(197,146)}
letters.U = {c(195,153),c(195,154),c(195,155),c(195,156)}
letters.Y = {c(195,157)}
letters.T = {c(195,144),c(195,158)}
letters.N = {c(195,145)}
letters.C = {c(195,135)}
letters.R = {c(197,152)}

local nextLetter = {}
for key, letterArray in pairs(letters) do
	nextLetter[key] = letterArray[1]
	local arraySize = #letterArray
	for i = 1, arraySize - 1 do
		nextLetter[letterArray[i] ] = letterArray[i + 1]
	end
	nextLetter[letterArray[arraySize] ] = key
end
letters = nil

--debug
--for k,v in pairs(nextLetter) do
--	print("nextLetter", k, v)
--end

function GetLastLetter(text)	--returns last letter string and number of bytes for that letter (1 or 2)
	local byteLength = #text
	if byteLength < 1 then return end
	local lastByte = byte(text, byteLength)
	local bOneByteLetter = lastByte < 128
	if bOneByteLetter then
		return c(lastByte), 1
	else
		return c(byte(text, byteLength - 1), lastByte), 2
	end
end

local g_editType = "EditCivName"

function CycleLastLetter()
	local text = Controls[g_editType]:GetText()
	local lastLetter, numLetterBytes = GetLastLetter(text)
	local newLetter = nextLetter[lastLetter]
	if newLetter then
		text = sub(text, 1, #text - numLetterBytes) .. newLetter
		Controls[g_editType]:ClearString()
		Controls[g_editType]:SetText(text)				--Needed or else cursor is left "between bytes"
		print("newText/#text = ", text, #text)
	end
end

function OnEdit(editType)
	g_editType = editType
	local text = Controls[editType]:GetText()
	print("OnEdit editType/text/#text = ", editType, text, #text)
	print("GetLastLetter(text) = ", GetLastLetter(text))
	

	--Validate for Accept button
	local bValid = ValidateText(Controls.EditCivShortName:GetText()) and ValidateText(Controls.EditCivName:GetText()) and ValidateText(Controls.EditCivAdjective:GetText())
	Controls.RenameAcceptButton:SetDisabled(not bValid)
end
Controls.EditCivName:RegisterCallback(function() return OnEdit("EditCivName") end)
Controls.EditCivShortName:RegisterCallback(function() return OnEdit("EditCivShortName") end)
Controls.EditCivAdjective:RegisterCallback(function() return OnEdit("EditCivAdjective") end)

function ValidateText(text)
	local isAllWhiteSpace = true;
	for i = 1, #text, 1 do
		if(string.byte(text, i) ~= 32) then
			isAllWhiteSpace = false;
			break;
		end
	end
	
	if(isAllWhiteSpace) then
		return false;
	end
	
	-- don't allow % character
	for i = 1, #text, 1 do
		if string.byte(text, i) == 37 then
			return false;
		end
	end
	
	local invalidCharArray = { '\"', '<', '>', '|', '\b', '\0', '\t', '\n', '/', '\\', '*', '?' };

	for i, ch in ipairs(invalidCharArray) do
		if(string.find(text, ch) ~= nil) then
			return false;
		end
	end
	
	-- don't allow control characters
	for i = 1, #text, 1 do
		if (string.byte(text, i) < 32) then
			return false;
		end
	end

	return true;
end


ContextPtr:SetHide(true)
