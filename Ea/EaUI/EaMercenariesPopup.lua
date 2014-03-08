-- EaMercenariesPopup
-- Author: Pazyryk
-- DateCreated: 5/6/2013 9:11:59 PM
--------------------------------------------------------------
print("Loading EaMercenariesPopup.lua")

include( "IconSupport" )
include( "InstanceManager" )
include("EaMiscUtils.lua")

MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

MapModData.playerType = MapModData.playerType or {}
local playerType = MapModData.playerType

MapModData.realCivs = MapModData.realCivs or {}
MapModData.fullCivs = MapModData.fullCivs or {}


--------------------------------------------------------------
-- local defs
--------------------------------------------------------------
--constants
local POLICY_MERCENARIES =			GameInfoTypes.POLICY_MERCENARIES
local MINOR_TRAIT_MERCENARY =		GameInfoTypes.MINOR_TRAIT_MERCENARY
local PROMOTION_FOR_HIRE =			GameInfoTypes.PROMOTION_FOR_HIRE
local PROMOTION_MERCENARY =			GameInfoTypes.PROMOTION_MERCENARY
local EARACE_MAN =					GameInfoTypes.EARACE_MAN
local EARACE_SIDHE =				GameInfoTypes.EARACE_SIDHE
local EARACE_HELDEOFOL =			GameInfoTypes.EARACE_HELDEOFOL

--shared
local realCivs =					MapModData.realCivs
local fullCivs =					MapModData.fullCivs

--localized functions
local GetMercenaryCosts = GetMercenaryCosts

--file control
local g_UnitManager = InstanceManager:new( "UnitInstance", "UnitButton", Controls.UnitStack)

local g_CurrentTab = "Available"
local g_iActivePlayer = -1

local g_iSelectedCiv = -1			--iPlayer for city state if we got here via city state popup
local g_bCityStateAvailableOnly = false

local g_bActivePlayerHasMercPolicy = false
local g_bHasMercFriend = false

local g_unitTables = {	Available = {},
						Employed = {},
						YoursForHire = {}	}

local g_unitTableCurrentIndex = 1

local g_bNone = {	Available = false,
					Employed = false,
					YoursForHire = false	}

--Next four functions are the only entry points to mercenary popups

function Show()					--called from diplo corner or Shift F2
	print("Running Show for EaMercenariesPopup")
	ContextPtr:SetHide(false)
	Controls.MainPopup:SetHide(false)
	Controls.ViewOnMapPopup:SetHide(true)
	g_iActivePlayer = Game.GetActivePlayer()
	g_bActivePlayerHasMercPolicy = Players[g_iActivePlayer]:HasPolicy(POLICY_MERCENARIES)
	g_iSelectedCiv = -1
	g_bCityStateAvailableOnly = false
	--RefreshAllUnitTables()
	TabSelect()
end

function ShowCityStateMercenaries(iCityState)		-- L-Click from CS popup
	print("Running ShowCityStateMercenaries ", iCityState)
	ContextPtr:SetHide(false)
	Controls.MainPopup:SetHide(false)
	Controls.ViewOnMapPopup:SetHide(true)
	g_iActivePlayer = Game.GetActivePlayer()
	g_bActivePlayerHasMercPolicy = Players[g_iActivePlayer]:HasPolicy(POLICY_MERCENARIES)
	g_iSelectedCiv = iCityState
	g_bCityStateAvailableOnly = true
	--RefreshAllUnitTables()
	TabSelect("Available")
end
LuaEvents.ShowCityStateMercenariesPopup.Add(ShowCityStateMercenaries)

function ShowMercenaryOnMap()		--Shift F1
	print("Running ShowMercenaryOnMap")
	ContextPtr:SetHide(false)
	Controls.MainPopup:SetHide(true)
	Controls.ViewOnMapPopup:SetHide(false)
	g_iActivePlayer = Game.GetActivePlayer()
	g_bActivePlayerHasMercPolicy = Players[g_iActivePlayer]:HasPolicy(POLICY_MERCENARIES)
	g_iSelectedCiv = -1
	g_bCityStateAvailableOnly = false
	RefreshAllUnitTables()
end
LuaEvents.ShowMercenaryOnMapPopup.Add(ShowMercenaryOnMap)

function ShowCityStateMercenaryOnMap(iCityState)		-- R-Click from CS popup
	print("Running ShowCityStateMercenaryOnMap ", iCityState)
	ContextPtr:SetHide(false)
	Controls.MainPopup:SetHide(true)
	Controls.ViewOnMapPopup:SetHide(false)
	g_iActivePlayer = Game.GetActivePlayer()
	g_bActivePlayerHasMercPolicy = Players[g_iActivePlayer]:HasPolicy(POLICY_MERCENARIES)
	g_iSelectedCiv = iCityState
	g_bCityStateAvailableOnly = true
	RefreshAllUnitTables()
	g_CurrentTab = "Available"
end
LuaEvents.ShowCityStateMercenaryOnMapPopup.Add(ShowCityStateMercenaryOnMap)


function TabSelect(tab)
	tab = tab or g_CurrentTab
	if tab == "Available" then
		Controls.AvailableSelectHighlight:SetHide(false)
		Controls.EmployedSelectHighlight:SetHide(true)
		Controls.YoursSelectHighlight:SetHide(true)
		if g_iSelectedCiv == -1 then
			Controls.CityStateToggleButton:SetHide(true)
		else
			Controls.CityStateToggleButton:SetHide(false)
			if g_bCityStateAvailableOnly then
				Controls.CityStateToggleLabel:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_SHOW_ALL"))
			else
				local csName = Players[g_iSelectedCiv]:GetName()
				Controls.CityStateToggleLabel:SetText("Show " .. csName .. "'s")
			end
		end
	elseif tab == "Employed" then
		Controls.AvailableSelectHighlight:SetHide(true)
		Controls.EmployedSelectHighlight:SetHide(false)
		Controls.YoursSelectHighlight:SetHide(true)
		Controls.CityStateToggleButton:SetHide(true)
	elseif tab == "YoursForHire" then
		Controls.AvailableSelectHighlight:SetHide(true)
		Controls.EmployedSelectHighlight:SetHide(true)
		Controls.YoursSelectHighlight:SetHide(false)
		Controls.CityStateToggleButton:SetHide(true)
	end
	g_CurrentTab = tab
	RefreshUnits()
	UpdateMercenaryPanel()
end
Controls.TabButtonAvailable:RegisterCallback(Mouse.eLClick, function() TabSelect("Available") end)
Controls.TabButtonEmployed:RegisterCallback(Mouse.eLClick, function() TabSelect("Employed") end)
Controls.TabButtonYours:RegisterCallback(Mouse.eLClick, function() TabSelect("YoursForHire") end)

function RefreshAllUnitTables()
	RefreshUnits("Available")
	RefreshUnits("Employed")
	RefreshUnits("YoursForHire")
end

function RefreshUnits(tab)		--tab can be nil (will use g_CurrentTab)
	print("RefreshUnits ", tab)
	tab = tab or g_CurrentTab
	local unitTable = g_unitTables[tab]
	local activePlayer = Players[g_iActivePlayer]
	local activeTeam = Teams[activePlayer:GetTeam()]
	--add everything into table so we can sort it by header (add code for that later)
	for i = #unitTable, 1, -1 do
		unitTable[i] = nil
	end
	local numUnits = 0
	g_bHasMercFriend = false
	for iPlayer, eaPlayer in pairs(realCivs) do		--loops through full civs and city states
		local bAllow = false
		local discountLevel = 0		--1 for friend, 2 for ally
		local player = Players[iPlayer]
		if tab == "YoursForHire" then
			bAllow = g_bActivePlayerHasMercPolicy and iPlayer == g_iActivePlayer
		elseif tab == "Employed" then
			bAllow = iPlayer == g_iActivePlayer
		elseif iPlayer ~= g_iActivePlayer and (not g_bCityStateAvailableOnly or g_iSelectedCiv == iPlayer) then
			if activeTeam:IsHasMet(player:GetTeam()) then
				bAllow, discountLevel = GetAllowAndDiscountLevel(iPlayer)
			end
		end
		if bAllow then
			for unit in player:Units() do
				if (tab ~= "Employed" and unit:IsHasPromotion(PROMOTION_FOR_HIRE)) or (tab == "Employed" and unit:IsHasPromotion(PROMOTION_MERCENARY)) then
					numUnits = numUnits + 1
					local unitTypeID = unit:GetUnitType()
					local unitInfo = GameInfo.Units[unitTypeID]
					local unitStr = Locale.Lookup(unitInfo.Description)
					unitStr = string.gsub(unitStr, "Light", "L.")	--some abreviations here
					unitStr = string.gsub(unitStr, "Medium", "M.")
					unitStr = string.gsub(unitStr, "Heavy", "H.")
					unitStr = string.gsub(unitStr, "Cavalry", "Cav.")
					unitStr = string.gsub(unitStr, "Arquebussmen", "Arquebuss.")
					local raceStr = unitInfo.EaRace and Locale.Lookup(GameInfo.EaRaces[unitInfo.EaRace].Description) or "-"
					local supportStr = "1[ICON_GOLD]"
					local dbQuery = "UnitType = '" .. unitInfo.Type .. "'"
					for row in GameInfo.Unit_ResourceQuantityRequirements(dbQuery) do
						resourceInfo = GameInfo.Resources[row.ResourceType]
						supportStr = supportStr .. "1" .. resourceInfo.IconString
					end
					local strength = unit:GetBaseCombatStrength()
					local statsStr = strength .. "[ICON_STRENGTH]"
					local ranged = unit:GetBaseRangedCombatStrength()
					if ranged > 0 then
						statsStr = statsStr .. ranged .. "[ICON_RANGE_STRENGTH]"
					end
					local moves = unit:MaxMoves() / GameDefines.MOVE_DENOMINATOR
					statsStr = statsStr .. moves .. "[ICON_MOVES]"

					local promotions, numPromotions = {}, 0
					for promoInfo in GameInfo.UnitPromotions() do
						local promoID = promoInfo.ID
						if promoID ~= PROMOTION_FOR_HIRE and promoID ~= PROMOTION_MERCENARY then			--include others not to show here
							if unit:IsHasPromotion(promoID) then
								numPromotions = numPromotions + 1
								promotions[numPromotions] = promoInfo.ID
							end
						end
					end
					local originStr = fullCivs[iPlayer] and Locale.Lookup(PreGame.GetCivilizationShortDescription(iPlayer)) or player:GetName()


					local totalCost, upFront, gpt = GetMercenaryCosts(unit, nil, discountLevel)
					local priceStr = upFront .. "[ICON_GOLD]" .. gpt .. "[ICON_GOLD]/turn"
					if discountLevel == 1 then
						priceStr = priceStr .. "*"
					elseif discountLevel == 2 then
						priceStr = priceStr .. "**"
					end
					local unitData = {	iOwner = unit:GetOwner(),
										iUnit = unit:GetID(),
										unitInfo = unitInfo,
										totalCost = totalCost,							--use for sorting (display priceStr)
										upFront = upFront,
										gpt = gpt,
										unitStr = unitStr,								--from here down all displayed
										raceStr = raceStr,
										statsStr = statsStr,
										level = unit:GetLevel(),
										promotions = "",								--temp
										originStr = originStr,
										priceStr = priceStr,
										supportStr = supportStr		}
					unitTable[numUnits] = unitData
				end
			end
		end
	end

	--do a table sort here (default by area?; player indicates which sort function by clicking header)

	if numUnits > 0 then
		g_bNone[tab] = false
		return true
	else
		g_bNone[tab] = true
		return false
	end
end

function UpdateMercenaryPanel()
	print("UpdateMercenaryPanel", g_CurrentTab)
	local unitTable = g_unitTables[g_CurrentTab]
	g_UnitManager:ResetInstances()
	local numUnits = #unitTable
	if numUnits > 0 then
		for i = 1, numUnits do
			local unitData = unitTable[i]
			local unitInfo = unitData.unitInfo
			local unitEntry = g_UnitManager:GetInstance()
			unitEntry.UnitName:SetText(unitData.unitStr)
			unitEntry.UnitRace:SetText(unitData.raceStr)
			unitEntry.UnitStats:SetText(unitData.statsStr)
			unitEntry.UnitLevel:SetText(tostring(unitData.level))
			unitEntry.UnitPromotions:SetText(unitData.promotions)
			unitEntry.UnitOrigin:SetText(unitData.originStr)
			unitEntry.UnitPrice:SetText(unitData.priceStr)
			unitEntry.UnitSupport:SetText(unitData.supportStr)
			IconHookup(unitInfo.PortraitIndex, 45, unitInfo.IconAtlas, unitEntry.UnitIcon)
			unitEntry.UnitButton:SetVoid1(i)
			unitEntry.UnitButton:RegisterCallback(Mouse.eLClick, UnitSelected)
			unitEntry.UnitButton:RegisterCallback(Mouse.eRClick, OnViewOnMap)	--take us straght to View On Map
			unitEntry.UnitButton:SetDisabled(false)
		end
		Controls.NoAvailableMercenaries:SetHide(true)
		Controls.ScrollPanel:SetHide(false)
		Controls.UnitStack:CalculateSize()
		Controls.UnitStack:ReprocessAnchoring()
		Controls.ScrollPanel:CalculateInternalSize()
		if g_bActivePlayerHasMercPolicy and g_CurrentTab == "Available" then
			Controls.DiscountFootnote:SetHide(false)
		else
			Controls.DiscountFootnote:SetHide(true)
		end
	else
		Controls.ScrollPanel:SetHide(true)
		local noMercStr
		if g_CurrentTab == "Employed" then
			noMercStr = "TXT_KEY_EA_MERCENARIES_NONE_6"
		elseif g_CurrentTab == "YoursForHire" then
			if g_bActivePlayerHasMercPolicy then
				noMercStr = "TXT_KEY_EA_MERCENARIES_NONE_5"
			else
				noMercStr = "TXT_KEY_EA_MERCENARIES_NONE_4"
			end
		else
			if g_bActivePlayerHasMercPolicy then
				noMercStr = "TXT_KEY_EA_MERCENARIES_NONE_3"
			elseif g_bHasMercFriend then
				noMercStr = "TXT_KEY_EA_MERCENARIES_NONE_2"
			else
				noMercStr = "TXT_KEY_EA_MERCENARIES_NONE_1"
			end		
		end
		print(noMercStr)
		Controls.NoAvailableMercenaries:SetText(Locale.Lookup(noMercStr))
		Controls.NoAvailableMercenaries:SetHide(false)
		Controls.DiscountFootnote:SetHide(true)	
	end
end

function GetAllowAndDiscountLevel(iPlayer)			
	local activePlayer = Players[g_iActivePlayer]
	local player = Players[iPlayer]
	local bAllow = false
	local discountLevel = 0
	if playerType[iPlayer] == "FullCiv" then
		if player:HasPolicy(POLICY_MERCENARIES) then
			if g_bActivePlayerHasMercPolicy then					--can hire & get discount
				bAllow = true
				if activePlayer:GetTeam() == player:GetTeam() then
					discountLevel = 2
				elseif player:IsFriends(g_iActivePlayer) then
					discountLevel = 1
				end
			elseif player:IsFriends(g_iActivePlayer) then			--must be friends if we don't have policy
				g_bHasMercFriend = true		--used for "None Available" UI
				bAllow = true
			end
		end
	elseif player:GetMinorCivTrait() == MINOR_TRAIT_MERCENARY then
		if g_bActivePlayerHasMercPolicy then
			bAllow = true
			if player:GetAlly() == g_iActivePlayer then
				discountLevel = 2
			elseif player:IsFriends(g_iActivePlayer) then		--works in this direction only!
				discountLevel = 1
			end
			--discountLevel = player:GetMinorCivFriendshipLevelWithMajor(g_iActivePlayer)
		elseif player:IsFriends(g_iActivePlayer) then		--must be friends; no discount
			bAllow = true
			g_bHasMercFriend = true		--used for "None Available" UI
		end
	end
	return bAllow, discountLevel
end


function UnitSelected(index)
	g_unitTableCurrentIndex = index
	local unitTable = g_unitTables[g_CurrentTab]
	local activePlayer = Players[g_iActivePlayer]
	local unitData = unitTable[index]
	if g_CurrentTab == "Available" then
		local headerStr = "Hire " .. Locale.Lookup(unitData.unitInfo.Description) .. " for " .. unitData.priceStr .. " (also requires " .. unitData.supportStr .." per turn)?"
		Controls.ConfirmString:SetText(headerStr)
		if activePlayer:GetGold() >= unitData.upFront and activePlayer:CalculateGoldRate() >= unitData.gpt then
			Controls.Response1:SetDisabled(false)
		else
			Controls.Response1:SetDisabled(true)
		end
		Controls.ResponseLabel1:SetText(Locale.Lookup("TXT_KEY_YES_BUTTON"))
		Controls.ResponseLabel2:SetText(Locale.Lookup("TXT_KEY_NO_BUTTON"))
		Controls.ResponseLabel3:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_SHOW_ON_MAP"))
	else
		local headerStr = Locale.Lookup("TXT_KEY_EA_MERCENARIES_WHAT_WOULD_YOU_LIKE_TO_DO")
		Controls.Response1:SetDisabled(false)
		Controls.ResponseLabel1:SetText(Locale.Lookup("TXT_KEY_EA_ACTION_CANC_HIRE_OUT_MERC"))
		Controls.ResponseLabel2:SetText(Locale.Lookup("TXT_KEY_BACK_BUTTON"))
		Controls.ResponseLabel3:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_SHOW_ON_MAP"))
	end
	Controls.UnitSelectConfirm:SetHide(false)
end

function OnConfirmResponse(responseInt)
	Controls.UnitSelectConfirm:SetHide(true)
	if responseInt == 1 then
		if g_CurrentTab == "Available" then		--Hire
			OnClose()
			Hire()
		else									--Cancel Hire Out Order
			CancelHireOrder()
			RefreshUnits()
			UpdateMercenaryPanel()
		end
	elseif responseInt == 3 then				--View On Map
		OnViewOnMap(g_unitTableCurrentIndex)
	end
	--responseInt == 2 will simply hide this window
end
Controls.Response1:RegisterCallback( Mouse.eLClick, function() OnConfirmResponse(1) end )
Controls.Response2:RegisterCallback( Mouse.eLClick, function() OnConfirmResponse(2) end )
Controls.Response3:RegisterCallback( Mouse.eLClick, function() OnConfirmResponse(3) end )

function OnViewOnMap(index)				--can get here via confirm dialog or directly with R click
	index = index or g_unitTableCurrentIndex
	g_unitTableCurrentIndex = index
	local unitTable = g_unitTables[g_CurrentTab]
	local unitData = unitTable[index]
	local unit = Players[unitData.iOwner]:GetUnitByID(unitData.iUnit)
	if unit then
		Controls.MainPopup:SetHide(true)
		Controls.ViewOnMapPopup:SetHide(false)
		Controls.ViewOnMapResponse1:SetDisabled(false)
		if g_CurrentTab == "Available" then
			Controls.ViewOnMapResponseLabel1:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_HIRE"))
			Controls.ViewOnMapResponseLabel3:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_VIEW_EMPLOYED"))
			Controls.ViewOnMapResponse3:SetDisabled(g_bNone.Employed)
			if g_bCityStateAvailableOnly then
				Controls.ViewOnMapResponseLabel2:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_VIEW_ALL_AVAILABLE"))
				Controls.ViewOnMapResponse2:SetDisabled(false)
			else
				local player = Players[g_iSelectedCiv]
				if player then
					Controls.ViewOnMapResponseLabel2:SetText("View " .. player:GetName() .. "'s")
					Controls.ViewOnMapResponse2:SetDisabled(false)
				else
					Controls.ViewOnMapResponseLabel2:SetText("-")
					Controls.ViewOnMapResponse2:SetDisabled(true)
				end
			end

		elseif g_CurrentTab == "Employed" then
			UI.SelectUnit(unit)
			Controls.ViewOnMapResponseLabel1:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_DISMISS"))
			Controls.ViewOnMapResponseLabel2:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_VIEW_AVAILABLE"))
			Controls.ViewOnMapResponseLabel3:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_VIEW_YOURS"))
			Controls.ViewOnMapResponse2:SetDisabled(g_bNone.Available)
			Controls.ViewOnMapResponse3:SetDisabled(g_bNone.YoursForHire)
		else
			UI.SelectUnit(unit)
			Controls.ViewOnMapResponseLabel1:SetText(Locale.Lookup("TXT_KEY_EA_ACTION_CANC_HIRE_OUT_MERC"))
			Controls.ViewOnMapResponseLabel2:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_VIEW_AVAILABLE"))
			Controls.ViewOnMapResponseLabel3:SetText(Locale.Lookup("TXT_KEY_EA_MERCENARIES_VIEW_EMPLOYED"))
			Controls.ViewOnMapResponse2:SetDisabled(g_bNone.Available)
			Controls.ViewOnMapResponse3:SetDisabled(g_bNone.Employed)
		end

		Controls.ViewOnMapResponseLabel4:SetText(Locale.Lookup("TXT_KEY_BACK_BUTTON"))
		Controls.ViewOnMapResponseLabel5:SetText(Locale.Lookup("TXT_KEY_CLOSE"))

		Controls.ViewOnMapString1:SetText("  ")
		local infoStr = Locale.Lookup("TXT_KEY_EA_MERCENARIES_HEADER_UNIT") .. ": " .. unitData.unitStr .. "[NEWLINE]" ..
						Locale.Lookup("TXT_KEY_EA_MERCENARIES_HEADER_RACE") .. ": " .. unitData.raceStr .. "[NEWLINE]" ..
						Locale.Lookup("TXT_KEY_EA_MERCENARIES_HEADER_STATS") .. ": " .. unitData.statsStr .. "[NEWLINE]" ..
						Locale.Lookup("TXT_KEY_EA_MERCENARIES_HEADER_LEVEL") .. ": " .. tostring(unitData.level) .. "[NEWLINE]" ..
						Locale.Lookup("TXT_KEY_EA_MERCENARIES_HEADER_PROMOTIONS") .. ": " .. "placeholder" .. "[NEWLINE]" ..
						Locale.Lookup("TXT_KEY_EA_MERCENARIES_HEADER_ORIGIN") .. ": " .. unitData.originStr .. "[NEWLINE]" ..
						Locale.Lookup("TXT_KEY_EA_MERCENARIES_HEADER_PRICE") .. ": " .. unitData.priceStr .. "[NEWLINE]" ..
						Locale.Lookup("TXT_KEY_EA_MERCENARIES_HEADER_SUPPORT") .. ": " .. unitData.supportStr

		Controls.ViewOnMapString2:SetText(infoStr)

		local plot = unit:GetPlot()


		UI.LookAt(plot, 0)
		local hex = ToHexFromGrid(Vector2(plot:GetX(), plot:GetY()))
		Events.GameplayFX(hex.x, hex.y, -1)
	end
end

function OnViewOnMapResponse(responseInt)
	local unitTable = g_unitTables[g_CurrentTab]
	if responseInt == 1 then
		Controls.ViewOnMapResponse1:SetDisabled(true)
		if g_CurrentTab == "Available" then		--Hire
			Hire()
			Controls.ViewOnMapString1:SetText("Hired!")
		elseif g_CurrentTab == "Employed" then		--Dismiss
			Dismiss()
			Controls.ViewOnMapString1:SetText("Dismissed!")
		else									--Cancel Hire Out Order
			CancelHireOrder()
			Controls.ViewOnMapString1:SetText("Canceled Hire Out Order!")
		end
		table.remove(unitTable, g_unitTableCurrentIndex)
		g_unitTableCurrentIndex = g_unitTableCurrentIndex - 1	--sets up for next cycle right

	elseif responseInt == 2 then	--toggle all or specific civ available
		local oldUnitIndex = g_unitTableCurrentIndex
		g_bCityStateAvailableOnly = not g_bCityStateAvailableOnly
		local bAnyUnits = RefreshUnits()
		if bAnyUnits then		
			OnViewOnMap(1)
		else
			g_bCityStateAvailableOnly = not g_bCityStateAvailableOnly
			RefreshUnits()
			OnViewOnMap()				--back to where we are now
		end
	elseif responseInt == 3 then	--change list
		if g_CurrentTab == "Employed" then
			g_CurrentTab = "YoursForHire"
		else
			g_CurrentTab = "Employed"
		end
		local bAnyUnits = RefreshUnits()
		if bAnyUnits then
			OnViewOnMap(1)
		else
			if g_CurrentTab == "Employed" then		--switch back and disable button
				g_CurrentTab = "YoursForHire"
			else
				g_CurrentTab = "Employed"
			end
			RefreshUnits()
			OnViewOnMap()				--back to where we are now
		end
	elseif responseInt == 4 then	--Back
		--RefreshUnits()
		TabSelect()
		Controls.MainPopup:SetHide(false)
		Controls.ViewOnMapPopup:SetHide(true)		
	elseif responseInt == 5 then	--Close
		OnClose()
	elseif responseInt == 6 then	--cycle left
		local tableSize = #unitTable
		if tableSize ~= 0 then
			local index = g_unitTableCurrentIndex - 1
			if index < 1 then
				index = tableSize
			end
			OnViewOnMap(index)
		end
	elseif responseInt == 7 then	--cycle right
		local tableSize = #unitTable
		if tableSize ~= 0 then
			local index = g_unitTableCurrentIndex + 1
			if index > tableSize then
				index = 1
			end
			OnViewOnMap(index)
		end
	end
end
Controls.ViewOnMapResponse1:RegisterCallback( Mouse.eLClick, function() OnViewOnMapResponse(1) end )
Controls.ViewOnMapResponse2:RegisterCallback( Mouse.eLClick, function() OnViewOnMapResponse(2) end )
Controls.ViewOnMapResponse3:RegisterCallback( Mouse.eLClick, function() OnViewOnMapResponse(3) end )
Controls.ViewOnMapResponse4:RegisterCallback( Mouse.eLClick, function() OnViewOnMapResponse(4) end )
Controls.ViewOnMapResponse5:RegisterCallback( Mouse.eLClick, function() OnViewOnMapResponse(5) end )
Controls.ViewOnMapCycleLeft:RegisterCallback( Mouse.eLClick, function() OnViewOnMapResponse(6) end )
Controls.ViewOnMapCycleRight:RegisterCallback( Mouse.eLClick, function() OnViewOnMapResponse(7) end )

function Hire()
	local unitTable = g_unitTables[g_CurrentTab]
	local activePlayer = Players[g_iActivePlayer]
	local unitData = unitTable[g_unitTableCurrentIndex]
	local unit = Players[unitData.iOwner]:GetUnitByID(unitData.iUnit)
	if unit then
		LuaEvents.EaUnitsHireMercenary(g_iActivePlayer, unit, unitData.upFront, unitData.gpt)
		g_bNone.Employed = false
	end
end

function Dismiss()
	local unitTable = g_unitTables[g_CurrentTab]
	local unitData = unitTable[g_unitTableCurrentIndex]
	LuaEvents.EaUnitsDismissMercenary(g_iActivePlayer, unitData.iUnit)
end

function CancelHireOrder()
	local unitTable = g_unitTables[g_CurrentTab]
	local unitData = unitTable[g_unitTableCurrentIndex]
	local unit = Players[unitData.iOwner]:GetUnitByID(unitData.iUnit)
	if unit then
		unit:SetHasPromotion(PROMOTION_FOR_HIRE , false)
	end
end

function OnCityStateToggle()	--only present if we got here through city state and are on Available tab
	g_bCityStateAvailableOnly = not g_bCityStateAvailableOnly
	g_CurrentTab = "Available"
	--RefreshUnits()
	TabSelect()
end
Controls.CityStateToggleButton:RegisterCallback(Mouse.eLClick, OnCityStateToggle)


function OnClose()
    ContextPtr:SetHide(true)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)

function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
            OnClose()
            return true
        end
    end
end
ContextPtr:SetInputHandler(InputHandler)

--This adds popup to the Diplo Corner
function OnAdditionalInformationDropdownGatherEntries(additionalEntries)
	table.insert(additionalEntries, {	text = Locale.ConvertTextKey("TXT_KEY_EA_MERCENARIES_POPUP"), 
										call = Show		})
end
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(OnAdditionalInformationDropdownGatherEntries)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()

ContextPtr:SetHide(true)