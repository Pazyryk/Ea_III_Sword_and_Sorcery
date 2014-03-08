-- EaCivilizationsPopup
-- Author: Pazyryk
-- DateCreated: 1/1/2014 10:26:26 AM
--------------------------------------------------------------
print("Loading EaCivilizationsPopup.lua")

include( "IconSupport" )
include( "InstanceManager" )
include("EaCivTextHelper.lua")

MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT
MapModData.civNamesByRace = MapModData.civNamesByRace or {}
local civNamesByRace = MapModData.civNamesByRace
MapModData.fullCivs = MapModData.fullCivs or {}
local fullCivs = MapModData.fullCivs

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------


--------------------------------------------------------------
-- file control vars
--------------------------------------------------------------

local g_CivManager = InstanceManager:new( "CivInstance", "CivButton", Controls.CivStack)

local g_CurrentTab = "Available"
local g_spellID = -1
local g_iActivePlayer = -1
local g_activePlayerEaCivID


function Show()					--called from diplo corner pulldown or from diplo corner button
	print("Running Show for EaCivilizationsPopup")
	ContextPtr:SetHide(false)
	g_iActivePlayer = Game.GetActivePlayer()
	local eaPlayer = gT.gPlayers[g_iActivePlayer]
	if not eaPlayer then return end
	g_activePlayerEaCivID = eaPlayer.eaCivNameID
	if g_activePlayerEaCivID then
		g_CurrentTab = "Taken"
	else
		g_CurrentTab = "Available"
	end
	TabSelect(g_CurrentTab)
end
LuaEvents.ShowEaCivilizationsPopup.Add(Show)


function TabSelect(tab)
	if tab == "Available" then
		Controls.TakenSelectHighlight:SetHide(true)
		Controls.AvailableSelectHighlight:SetHide(false)
	elseif tab == "Taken"  then
		Controls.AvailableSelectHighlight:SetHide(true)
		Controls.TakenSelectHighlight:SetHide(false)
	end
	g_CurrentTab = tab
	RefreshCivs(tab)
end
Controls.TabButtonAvailable:RegisterCallback( Mouse.eLClick, function() TabSelect("Available") end)
Controls.TabButtonTaken:RegisterCallback( Mouse.eLClick, function() TabSelect("Taken") end )

function RefreshCivs(tab)
	g_CivManager:ResetInstances()
	local numCivs = 0
	local eaPlayer = gT.gPlayers[g_iActivePlayer]
	if not eaPlayer then return end
	local raceID = eaPlayer.race
	for eaCivInfo in GameInfo.EaCivs() do
		local eaCivID = eaCivInfo.ID
		local bInclude = false
		local bTaken = false
		for iPlayer, eaPlayer in pairs(fullCivs) do
			if eaPlayer.eaCivNameID == eaCivID then
				bTaken = true
				break
			end
		end
		if tab == "Available" then
			bInclude = civNamesByRace[raceID][eaCivID] and not bTaken
		else
			bInclude = bTaken
		end

		if bInclude then
			numCivs = numCivs + 1
			local triggerText = GetEaCivTriggerText(eaCivID)
			local strToolTip = GetEaCivDiscriptionText(eaCivID, true, true, true)
			local civName = Locale.Lookup(eaCivInfo.Description)
			if eaCivID == g_activePlayerEaCivID then
				civName = civName .. " (You)"
			end
			local civDescription = Locale.Lookup(eaCivInfo.Help)
			civDescription = string.gsub(civDescription, "%[ICON_BULLET%]", "")
			civDescription = string.gsub(civDescription, "%[NEWLINE%]", "; ")
			local civEntry = g_CivManager:GetInstance()
			civEntry.CivName:SetText(civName)
			civEntry.CivTrigger:SetText(triggerText)
			civEntry.CivDescription:SetText(civDescription)
			IconHookup(eaCivInfo.PortraitIndex, 45, eaCivInfo.IconAtlas, civEntry.civIcon)
			civEntry.CivButton:SetToolTipString(strToolTip)
		end
	end
	if numCivs > 0 then
		Controls.NoCivs:SetHide(true)
		Controls.ContentBox:SetHide(false)
		Controls.CivStack:CalculateSize()
		Controls.CivStack:ReprocessAnchoring()
		Controls.ScrollPanel:CalculateInternalSize()
	else
		Controls.ContentBox:SetHide(true)
		Controls.NoCivs:SetHide(false)
	end
end

function Close()
    ContextPtr:SetHide(true)
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

--This adds popup to the Diplo Corner
function OnAdditionalInformationDropdownGatherEntries(additionalEntries)
	table.insert(additionalEntries, {	text = Locale.ConvertTextKey("TXT_KEY_EA_CIVILIZATIONS_POPUP"), 
										call = Show		})
end
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(OnAdditionalInformationDropdownGatherEntries)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()

ContextPtr:SetHide(true)