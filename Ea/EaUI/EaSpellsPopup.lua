-- EaLearnSpellPopup
-- Author: Pazyryk
-- DateCreated: 12/30/2012 6:19:19 PM
--------------------------------------------------------------
print("Loading EaSpellsPopup.lua")

include( "IconSupport" )
include( "InstanceManager" )

MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

MapModData.sharedIntegerList = MapModData.sharedIntegerList or {}
local sharedIntegerList = MapModData.sharedIntegerList

--------------------------------------------------------------
-- local defs
--------------------------------------------------------------


--------------------------------------------------------------
-- file control vars
--------------------------------------------------------------

local g_SpellManager = InstanceManager:new( "SpellInstance", "SpellButton", Controls.SpellStack)

local g_CurrentTab = "Arcane"
local g_spellID = -1
local g_iPlayer = -1
local g_iPerson = -1
local bLearnSpell = false
local bAllowArcane = false
local bAllowDivine = false


function Show()					--called from diplo corner
	print("Running Show for EaSpellsPopup")
	ContextPtr:SetHide(false)
	g_iPlayer = Game.GetActivePlayer()
	g_iPerson = -1
	g_spellID = -1
	bLearnSpell = false
	bAllowArcane = true
	bAllowDivine = true
	TabSelect(g_CurrentTab)
end

function LearnSpell(iPerson)		--called from Learn Spell promotion selection
	--info different then base popups; fields used: type, id, text, sound (not all required or used for all types)
	print("Running LearnSpell ", iPerson)
	ContextPtr:SetHide(false)
	g_iPlayer = Game.GetActivePlayer()
	g_iPerson = iPerson
	g_spellID = -1
	bLearnSpell = true
	local eaPerson = gT.gPeople[iPerson]
	local class1, class2 = eaPerson.class1, eaPerson.class2
	bAllowArcane = class1 == "Thaumaturge" or class2 == "Thaumaturge"
	bAllowDivine = class1 == "Devout" or class2 == "Devout"
	TabSelect(g_CurrentTab)
end
LuaEvents.LearnSpellPopup.Add(LearnSpell)

function TabSelect(tab)
	if not bAllowArcane then
		tab = "Divine"
	elseif not bAllowDivine then
		tab = "Arcane"
	end
	if tab == "Arcane" and bAllowArcane then
		Controls.DivineSelectHighlight:SetHide(true)
		Controls.ArcaneSelectHighlight:SetHide(false)
		RefreshSpells("Arcane")
	elseif tab == "Divine" and bAllowDivine then
		Controls.ArcaneSelectHighlight:SetHide(true)
		Controls.DivineSelectHighlight:SetHide(false)
		RefreshSpells("Divine")
	end
	g_CurrentTab = tab
end
Controls.TabButtonArcane:RegisterCallback( Mouse.eLClick, function() TabSelect("Arcane") end)
Controls.TabButtonDivine:RegisterCallback( Mouse.eLClick, function() TabSelect("Divine") end )

function RefreshSpells(spellClass)
	LuaEvents.EaMagicGenerateLearnableSpellList(g_iPlayer, bLearnSpell and g_iPerson, spellClass)		--call to EaActions.lua to generate learnable spell list
	g_SpellManager:ResetInstances()
	local numSpells = #sharedIntegerList
	for i = 1, numSpells do
		local spellID = sharedIntegerList[i]
		local spellInfo = GameInfo.EaActions[spellID]
		local spellEntry = g_SpellManager:GetInstance()
		spellEntry.SpellName:SetText(Locale.Lookup(spellInfo.Description))
		spellEntry.SpellDescription:SetText(Locale.Lookup(spellInfo.Help))
		IconHookup(spellInfo.IconIndex, 45, spellInfo.IconAtlas, spellEntry.SpellIcon)
		spellEntry.SpellButton:SetVoid1(spellID)
		spellEntry.SpellButton:RegisterCallback(Mouse.eLClick, SpellSelected)
		spellEntry.SpellButton:SetDisabled(not bLearnSpell)
	end
	if numSpells > 0 then
		Controls.NoAvailableSpells:SetHide(true)
		Controls.ScrollPanel:SetHide(false)
		Controls.SpellStack:CalculateSize()
		Controls.SpellStack:ReprocessAnchoring()
		Controls.ScrollPanel:CalculateInternalSize()
	else
		Controls.ScrollPanel:SetHide(true)
		if spellClass == "Arcane" then
			Controls.NoAvailableSpells:SetText(Locale.Lookup("TXT_KEY_EA_LEARN_SPELL_NO_ARCANE"))
		else
			Controls.NoAvailableSpells:SetText(Locale.Lookup("TXT_KEY_EA_LEARN_SPELL_NO_DIVINE"))
		end
		Controls.NoAvailableSpells:SetHide(false)
	end
end

function SpellSelected(spellID)
	g_spellID = spellID
	local spellInfo = GameInfo.EaActions[spellID]
	local str = "Learn " .. Locale.Lookup(spellInfo.Description) .. "?"
	Controls.SpellSelectConfirm:SetHide(false)
	Controls.ConfirmString:SetText(str)
end

function OnYes()
	Controls.SpellSelectConfirm:SetHide(true)
    ContextPtr:SetHide(true)
	local eaPerson = gT.gPeople[g_iPerson]
	eaPerson.spells[g_spellID] = true									--gives spell
	Events.SerialEventUnitInfoDirty()
end
Controls.Yes:RegisterCallback( Mouse.eLClick, OnYes )

function OnNo()
	g_spellID = -1
	Controls.SpellSelectConfirm:SetHide(true)
end
Controls.No:RegisterCallback( Mouse.eLClick, OnNo )

function Close()
    ContextPtr:SetHide(true)
	if g_iPerson ~= -1 then
		--dll has already given level when popup occured; take it away so player has promotion selection again
		local eaPerson = gT.gPeople[g_iPerson]
		local unit = Players[g_iPlayer]:GetUnitByID(eaPerson.iUnit)
		unit:SetLevel(unit:GetLevel() - 1)
		unit:TestPromotionReady()
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

--This adds popup to the Diplo Corner
function OnAdditionalInformationDropdownGatherEntries(additionalEntries)
	table.insert(additionalEntries, {	text = Locale.ConvertTextKey("TXT_KEY_EA_SPELLS_POPUP"), 
										call = Show		})
end
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(OnAdditionalInformationDropdownGatherEntries)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()

ContextPtr:SetHide(true)