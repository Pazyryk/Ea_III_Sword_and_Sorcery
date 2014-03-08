-- EaGenericPopupConscript
-- Author: Pazyryk
-- DateCreated: 11/28/2012 5:56:11 AM
--------------------------------------------------------------
--included by this added line in GenericPopup.lua:
--files = include("EaGenericPopup")

-- This popup occurs when a player clicks the Conscript/Indenture button in the city view
local MapModData = MapModData
MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

PopupLayouts[ButtonPopupTypes.BUTTONPOPUP_MODDER_1] = function(popupInfo)

	local city = UI.GetHeadSelectedCity()
	if not city then return end

	local iPlayer = Game.GetActivePlayer()
	local player = Players[iPlayer]

	local plot = city:Plot()
	local iPlot = plot:GetPlotIndex()
	local eaCity = gT.gCities[iPlot]
	local population = city:GetPopulation()
	
	-- Initialize popup text
	SetPopupText("Choose to conscript or indenture population")

	-- Indenture button
	if population > 1 and eaCity.conscriptTurn ~= Game.GetGameTurn() then
		
		local OnIndentureClicked = function()
			print("OnIndentureClicked")
			eaCity.conscriptTurn = Game.GetGameTurn()
			city:SetPopulation(population - 1, true)
			local unitID
			if city:GetNumBuilding(GameInfoTypes.BUILDING_MAN) == 1 then
				unitID = GameInfoTypes.UNIT_SLAVES_MAN
			elseif city:GetNumBuilding(GameInfoTypes.BUILDING_SIDHE) == 1 then
				unitID = GameInfoTypes.UNIT_SLAVES_SIDHE
			else
				unitID = GameInfoTypes.UNIT_SLAVES_ORC
			end


			local newUnit = player:InitUnit(unitID, city:GetX(), city:GetY() )
			newUnit:JumpToNearestValidPlot()
			newUnit:SetHasPromotion(GameInfoTypes.PROMOTION_SLAVE, true)

		end
		AddButton("Indenture population", OnIndentureClicked)
	end

	-- Auto-indenture to current pop button
	if eaCity.autoIndenturePop then
		local OnStopAutoIndentureClicked = function()
			print("OnStopAutoIndentureClicked")
			eaCity.autoIndenturePop = nil
		end
		AddButton("Stop automatatic indenture", OnStopAutoIndentureClicked)
	else
		local OnAutoIndentureClicked = function()
			print("OnAutoIndentureClicked")
			eaCity.autoIndenturePop = population
		end
		AddButton("Indenture to maintain current pop.", OnAutoIndentureClicked)
	end
	
	Controls.CloseButton:SetHide( false )
end