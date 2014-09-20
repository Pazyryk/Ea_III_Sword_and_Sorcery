-- EaCivPopup
-- Author: Pazyryk
-- DateCreated: 4/18/2012 8:01:50 AM
--------------------------------------------------------------
print("Loading EaImagePopup.lua")

include ("EaErrorHandler.lua")
include ("EaImageScaling.lua")
include ("EaTextUtils.lua")
include("EaCivTextHelper.lua")

MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

MapModData.modsForUI = MapModData.modsForUI or {}
local modsForUI = MapModData.modsForUI

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------
local POLICY_PANTHEISM =				GameInfoTypes.POLICY_PANTHEISM
local EARACE_MAN =						GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =					GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =				GameInfoTypes.EARACE_HELDEOFOL

local HandleError10 =					HandleError10
local HandleError21 =					HandleError21

--------------------------------------------------------------
-- file control vars
--------------------------------------------------------------
--local m_PopupInfo

local g_isOpen = false
local g_popupQueue = {}
local g_queuePos = 0
local g_lastImageFrame
local g_artInfo


function ShowEaImagePopup(info)
	--info different then base popups; fields used: type, id, text, textKey, image, sound (not all required or used for all types)
	if g_isOpen then
		g_queuePos = g_queuePos + 1
		g_popupQueue[g_queuePos] = info
		return
	end
	g_isOpen = true
	if info.sound then
		Events.AudioPlay2DSound(info.sound)
	end
	ContextPtr:SetHide(false)

	if info.type == "Person" or info.type == "NewPerson" or info.type == "NewPersonLeader" then
		ShowPortrait(info)
	elseif info.type == "PersonDeath" then
		ShowDeath(info)
	elseif info.type == "CivNaming" then
		ShowCiv(info)
	elseif info.type == "Generic" then
		ShowGeneric(info)
	end
end
LuaEvents.EaImagePopup.Add(function(info) return HandleError10(ShowEaImagePopup, info) end)

local eaPortraitInfoByPersonRowID = {}
for eaPersonRow in GameInfo.EaPeople() do
	local eaPortraitType = string.gsub(eaPersonRow.Type, "EAPERSON", "EAPORTRAIT")
	local eaPortraitInfo = GameInfo.EaPortraits[eaPortraitType]
	eaPortraitInfoByPersonRowID[eaPersonRow.ID] = eaPortraitInfo
	print(eaPersonRow.Type, eaPortraitInfo, eaPortraitInfo and eaPortraitInfo.Type)
end

local g_otherPlayerDialog = false

function ShowHideEaLeaderForDialog(iOtherPlayer)
	print("ShowHideEaLeaderForDialog ", iOtherPlayer)

	if iOtherPlayer == g_otherPlayerDialog then return end
	g_otherPlayerDialog = iOtherPlayer

	if iOtherPlayer then
		if g_isOpen then
			if g_lastImageFrame then
				Controls[g_lastImageFrame]:SetHide(true)
				Controls[g_lastImageFrame]:UnloadTexture()
			end			
		end
		g_isOpen = false
		ContextPtr:SetHide(false)


		local eaOtherPlayer = gT.gPlayers[iOtherPlayer]
		local iPerson = eaOtherPlayer.leaderEaPersonIndex or 0
		
		local eaPerson = gT.gPeople[iPerson]
		local eaPersonRowID = eaPerson.eaPersonRowID
		if not eaPersonRowID then
			print("!!!! ERROR: Leader is generic?")
			 eaPersonRowID = 0
		end
		g_artInfo = eaPortraitInfoByPersonRowID[eaPerson.eaPersonRowID]
		local dds = g_artInfo.File
	
		local gridSize, gridOffset, imageFrame, imageSize, imageOffset = ScaleImage("Leader", dds, 0)
		print(imageFrame, imageSize.x, imageSize.y, imageOffset.x, imageOffset.y, gridSize.x, gridSize.y, gridOffset.x, gridOffset.y)

		if gridSize then
			Controls.TextBox:SetHide(true)
			Controls.ImageGrid:SetSize(gridSize)
			Controls.ImageGrid:SetOffsetVal(gridOffset.x, gridOffset.y)
			Controls.Trim:SetSize({x = gridSize.x - 20, y = 5})
			Controls[imageFrame]:SetHide(false)
			Controls[imageFrame]:SetTexture(dds)
			Controls[imageFrame]:SetSize(imageSize)
			Controls[imageFrame]:SetOffsetVal(imageOffset.x, imageOffset.y)
			--Controls[imageFrame]:SetToolTipCallback(ArtCreditToolTip)

			g_lastImageFrame = imageFrame
		end

	else
		if g_lastImageFrame then
			Controls[g_lastImageFrame]:SetHide(true)
			Controls[g_lastImageFrame]:UnloadTexture()
		end

		ContextPtr:SetHide(true)
	end

end
local function X_ShowHideEaLeaderForDialog(iOtherPlayer) return HandleError10(ShowHideEaLeaderForDialog, iOtherPlayer) end
LuaEvents.ShowHideEaLeaderForDialog.Add(X_ShowHideEaLeaderForDialog)


function ShowGeneric(info)
	--provide imageInfo and text or textKey
	print("running ShowGeneric")

	g_artInfo = info.imageInfo
	local text = info.text or (info.textKey and Locale.Lookup(info.textKey) or "")

	local dds = g_artInfo.File
	
	local textRows = 4		--need to calculate!
	local gridSize, gridOffset, imageFrame, imageSize, imageOffset = ScaleImage("TextBox", dds, textRows)
	print(imageFrame, imageSize.x, imageSize.y, imageOffset.x, imageOffset.y, gridSize.x, gridSize.y, gridOffset.x, gridOffset.y)

	if gridSize then
		--Controls.ImageGrid:SetHide(false)
		Controls.ImageGrid:SetSize(gridSize)
		Controls.ImageGrid:SetOffsetVal(gridOffset.x, gridOffset.y)
		Controls.TextBox:SetHide(false)
		Controls.TextBox:SetSize({x = imageSize.x, y = 10 + 24 * textRows})
		Controls.Trim:SetSize({x = gridSize.x - 20, y = 5})
		Controls[imageFrame]:SetHide(false)
		Controls[imageFrame]:SetTexture(dds)
		Controls[imageFrame]:SetSize(imageSize)
		Controls[imageFrame]:SetOffsetVal(imageOffset.x, imageOffset.y)
		--Controls[imageFrame]:SetToolTipCallback(ArtCreditToolTip)
		Controls.DescriptionLabel:SetWrapWidth(imageSize.x - 200)
		Controls.DescriptionLabel:SetText(text)
		Controls.QuoteLabel:SetHide(true)
		g_lastImageFrame = imageFrame
	end
end

function ShowPortrait(info)
	print("Running ShowPortrait")
	local iPerson = info.id
	local eaPerson = gT.gPeople[iPerson]
	local eaPersonRow = GameInfo.EaPeople[eaPerson.eaPersonRowID]
	g_artInfo = GameInfo.EaPortraits[string.gsub(eaPersonRow.Type, "EAPERSON", "EAPORTRAIT")]

	local level = eaPerson.level
	local classTitle = eaPerson.subclass
	classTitle = classTitle == "FallenPriest" and "Priest" or classTitle
	if not classTitle then
		classTitle = eaPerson.class1
		if eaPerson.class2 then
			classTitle = classTitle .. "/" .. eaPerson.class2
		end
	end
	local age = Game.GetGameTurn() - eaPerson.birthYear
	local text = ""
	local textRows = 1
	if info.type == "Person" then
		text = GetEaPersonFullTitle(eaPerson) .. ", Level " .. level .. " " .. classTitle .. " (" .. age .. " years)"
	elseif info.type == "NewPerson" then
		text = GetEaPersonFullTitle(eaPerson) .. " has risen to greatness...[NEWLINE]Level " .. level .. " " .. classTitle .. " (" .. age .. " years)"
		textRows = textRows + 1
	elseif info.type == "NewPersonLeader" then
		text = GetEaPersonFullTitle(eaPerson) .. " has risen to lead your civilization...[NEWLINE]Level " .. level .. " " .. classTitle .. " (" .. age .. " years)"
		textRows = textRows + 1			
	end

	--Action/Spell modifiers
	LuaEvents.EaPeopleSetModsTable(iPerson)		--TO DO: move to helper file
	for i = 0, #modsForUI do
		local mod = modsForUI[i].value
		if 0 < mod then
			text = text .. "[NEWLINE]   " .. modsForUI[i].text .. ": " .. mod
			if (modsForUI.bApplyMagicMods and i >= modsForUI.firstMagicMod) or (modsForUI.bApplyDevotionMod and i == modsForUI.firstMagicMod - 1) then
				text = text .. "*"
			end
			textRows = textRows + 1			
		end
	end

	--Tower/Temple info
	local towerTempleName
	if eaPerson.templeID then
		towerTempleName = Locale.Lookup(GameInfo.EaWonders[eaPerson.templeID].Description)
	else
		local tower = gT.gWonders[GameInfoTypes.EA_WONDER_ARCANE_TOWER][iPerson]
		if tower then
			local plot = Map.GetPlotByIndex(tower.iPlot)
			towerTempleName = plot:GetScriptData()	
		end
	end
	if towerTempleName then
		if modsForUI.bApplyMagicMods then
			text = text .. "[NEWLINE]*Includes modifiers from " .. towerTempleName
			textRows = textRows + 1	
		elseif modsForUI.bApplyDevotionMod then
			text = text .. "[NEWLINE]*Includes modifier from " .. towerTempleName
			textRows = textRows + 1	
		elseif eaPerson.templeID then
			text = text .. "[NEWLINE]Head priest at the " .. towerTempleName .. " (boosts spell modifiers)"
			textRows = textRows + 1	
		else
			text = text .. "[NEWLINE]Owns " .. towerTempleName .. " (boosts spell modifiers)"
			textRows = textRows + 1	
		end
	elseif modsForUI.bApplyMagicMods or modsForUI.bApplyDevotionMod then
		error("GP seems to have spell mods but didn't find name for tower or temple")
	end

	--Process image
	local dds = g_artInfo.File
	local gridSize, gridOffset, imageFrame, imageSize, imageOffset = ScaleImage("TextBox", dds, textRows)
	print(imageFrame, imageSize.x, imageSize.y, imageOffset.x, imageOffset.y, gridSize.x, gridSize.y, gridOffset.x, gridOffset.y)

	if gridSize then
		--Controls.ImageGrid:SetHide(false)
		Controls.ImageGrid:SetSize(gridSize)
		Controls.ImageGrid:SetOffsetVal(gridOffset.x, gridOffset.y)
		Controls.TextBox:SetHide(false)
		Controls.TextBox:SetSize({x = imageSize.x, y = 10 + 24 * textRows})
		Controls.Trim:SetSize({x = gridSize.x - 20, y = 5})
		Controls[imageFrame]:SetHide(false)
		Controls[imageFrame]:SetTexture(dds)
		Controls[imageFrame]:SetSize(imageSize)
		Controls[imageFrame]:SetOffsetVal(imageOffset.x, imageOffset.y)
		--Controls[imageFrame]:SetToolTipCallback(ArtCreditToolTip)
		Controls.DescriptionLabel:SetText(text)
		Controls.QuoteLabel:SetHide(true)
		g_lastImageFrame = imageFrame
	end
end

function ShowDeath(info)
	print("running ShowDeath")
	local iPlayer = Game.GetActivePlayer()
	local player = Players[iPlayer]
	local eaPlayer = gT.gPlayers[iPlayer]
	if not eaPlayer then return end
	local eaPerson = gT.gPeople[info.id]
	--ls612: This is a cheap hack for now to fix the errors with multiple death popups making 
	--the popups unclosable
	--Paz, you will want to look at the cause of this when you get back
	if not eaPerson then return end
	local name = GetEaPersonFullTitle(eaPerson)
	local gender = GameInfo.EaPeople[eaPerson.eaPersonRowID].Gender

	local text = ""
	if eaPlayer.bUsesDivineFavor then
		g_artInfo = GameInfo.EaPopups.EAPOPUP_DEATH_AZZ
		local pronoun = gender == "F" and "her" or "his"
		text = "The angels mourn the passing of " .. name .. "..."
	elseif player:HasPolicy(POLICY_PANTHEISM) then
		g_artInfo = GameInfo.EaPopups.EAPOPUP_DEATH_OTHER
		if eaPlayer.race == EARACE_SIDHE then
			text = "An eternal gift lost; " .. name .. " passes into the Weave..."
		else
			text = "Your people mourn as " .. name .. " passes into the Weave..."
		end
	elseif eaPlayer.race == EARACE_MAN then
		g_artInfo = GameInfo.EaPopups.EAPOPUP_DEATH_MAN
		text = "Your people mourn the passing of " .. name .. "..." 
	else
		g_artInfo = GameInfo.EaPopups.EAPOPUP_DEATH_OTHER
		text = name .. " has died..."
	end

	local dds = g_artInfo.File
			
	local gridSize, gridOffset, imageFrame, imageSize, imageOffset = ScaleImage("TextBox", dds, 2)
	print(imageFrame, imageSize.x, imageSize.y, imageOffset.x, imageOffset.y, gridSize.x, gridSize.y, gridOffset.x, gridOffset.y)

	if gridSize then
		--Controls.ImageGrid:SetHide(false)
		Controls.ImageGrid:SetSize(gridSize)
		Controls.ImageGrid:SetOffsetVal(gridOffset.x, gridOffset.y)
		Controls.TextBox:SetHide(false)
		Controls.TextBox:SetSize({x = imageSize.x, y = 60})
		Controls.Trim:SetSize({x = gridSize.x - 20, y = 5})
		Controls[imageFrame]:SetHide(false)
		Controls[imageFrame]:SetTexture(dds)
		Controls[imageFrame]:SetSize(imageSize)
		Controls[imageFrame]:SetOffsetVal(imageOffset.x, imageOffset.y)
		--Controls[imageFrame]:SetToolTipCallback(ArtCreditToolTip)
		Controls.DescriptionLabel:SetText(text)
		Controls.QuoteLabel:SetHide(true)
		g_lastImageFrame = imageFrame
	end


end

function ShowCiv(info)
	local eaTrait = GameInfo.EaCivs[info.id]
	local dds = eaTrait.PopupImage
	local name = Locale.Lookup(eaTrait.Description)
	local quote = eaTrait.Quote and Locale.Lookup(eaTrait.Quote) or name
	local textRows = 2
	if string.find(quote, "TXT_KEY") then
		quote = ""
	else
		local _, newlines = string.gsub(quote, "%[NEWLINE%]", "%[NEWLINE%]")
		textRows = newlines + 2
	end
			
	local gridSize, gridOffset, imageFrame, imageSize, imageOffset = ScaleImage("TextBox", dds, textRows)
	print(imageFrame, imageSize.x, imageSize.y, imageOffset.x, imageOffset.y, gridSize.x, gridSize.y, gridOffset.x, gridOffset.y)

	if gridSize then
		--Controls.ImageGrid:SetHide(false)


		Controls.ImageGrid:SetSize(gridSize)
		Controls.ImageGrid:SetOffsetVal(gridOffset.x, gridOffset.y)
		Controls.TextBox:SetHide(false)
		Controls.TextBox:SetSize({x = imageSize.x, y = 10 + 24 * textRows})
		Controls.Trim:SetSize({x = gridSize.x - 20, y = 5})

		--Controls.TextBox:SetSize({x = imageSize.x, y = 60})

		Controls[imageFrame]:SetHide(false)
		Controls[imageFrame]:SetTexture(dds)
		Controls[imageFrame]:SetSize(imageSize)
		Controls[imageFrame]:SetOffsetVal(imageOffset.x, imageOffset.y)
		Controls.DescriptionLabel:SetText(name)
		Controls.QuoteLabel:SetWrapWidth(gridSize.x - 200)
		Controls.QuoteLabel:SetText(quote)
		Controls.QuoteLabel:SetHide(false)

		g_lastImageFrame = imageFrame
	end
end


--[[
local tipControlTable = {}
TTManager:GetTypeControlTable( "TooltipTypeTopPanel", tipControlTable )

function ArtCreditToolTip( control )

	local strText = ""
	if g_artInfo.UseType == "ByPermission" then
		strText = "Image used by permission,[NEWLINE]copyright " .. g_artInfo.Artist

	elseif g_artInfo.UseType == "WikiCommons" then
		strText = "Image by " .. g_artInfo.Artist .. "[NEWLINE](Wikimedia Commons)"
	end

	tipControlTable.TooltipLabel:SetText( strText )
	tipControlTable.TopPanelMouseover:SetHide(false)
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize()
end
]]

function Close()

	--tipControlTable.TopPanelMouseover:SetHide(true)
	if g_lastImageFrame then
		Controls[g_lastImageFrame]:SetHide(true)
		Controls[g_lastImageFrame]:UnloadTexture()
	end

	--UIManager:DequeuePopup( ContextPtr )

	g_isOpen = false

	if g_queuePos > 0 then
		ShowEaImagePopup(g_popupQueue[g_queuePos])
		g_queuePos = g_queuePos - 1

	else
		ContextPtr:SetHide(true)
	end

end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, Close)

function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
            Close()
            return true
        end
    end
end
ContextPtr:SetInputHandler(InputHandler)

ContextPtr:SetHide(true)