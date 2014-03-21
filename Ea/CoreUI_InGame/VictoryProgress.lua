----------------------------------------------------------------
----------------------------------------------------------------
--Paz: This UI was recoded from scratch, so no "Paz" tags below

include("IconSupport")
include("SupportFunctions")
include("InstanceManager")
include("EaVictoriesHelper.lua")
include("EaTableUtils.lua")

include("EaErrorHandler.lua")


MapModData.gT = MapModData.gT or {}
local gT = MapModData.gT

local Floor = math.floor
local Sort = table.sort
local Format = string.format

local g_scores = {}
local g_numCivs = 0

local g_iActivePlayer = -1
local g_activePlayer
local g_bestModScore = 0
local g_bestScoreType = GameInfoTypes.VICTORY_SUBDUER


----------------------------------------------------------------
----------------------------------------------------------------

function SetupScreen(iPlayer)		--iPlayer only supplied to change player view from Fire Tuner for debugging
	if gT.gPlayers then		--game inited
		g_iActivePlayer = iPlayer or Game.GetActivePlayer()
		if not MapModData.fullCivs[g_iActivePlayer] then		--probably autoplay; set to some player so we can watch progress
			for i = 0, GameDefines.MAX_MAJOR_CIVS do
				if MapModData.fullCivs[i] then
					g_iActivePlayer = i
					break
				end
			end
		end

		if MapModData.fullCivs[g_iActivePlayer] then
			g_activePlayer = Players[g_iActivePlayer]
			SimpleCivIconHookup( g_iActivePlayer, 64, Controls.Icon )

			--trim the score table for dead players
			for iLoopPlayer in pairs(g_scores) do
				if not MapModData.fullCivs[iLoopPlayer] then
					g_scores[iLoopPlayer] = nil
				end
			end
			local numCivs = 0
			for iLoopPlayer in pairs(MapModData.fullCivs) do
				numCivs = numCivs + 1
			end
			g_numCivs = numCivs
			g_bestModScore = 0

			PopulateProtector()
			PopulateDestroyer()
			PopulateRestorer()
			PopulateSubduer()
			PopulateConqueror()
			PopulateScoreSummary()
		end
	end
end

function PopulateProtector()
	print("PopulateProtector")
	local score, bVictory, civsCorrected, sorcerersDestroyed, artifactsDestroyed = GetProtectorVictoryData(g_iActivePlayer)
	print(score, bVictory, civsCorrected, sorcerersDestroyed, artifactsDestroyed)

	if g_bestModScore < score then
		g_bestModScore = score
		g_bestScoreType = GameInfoTypes.VICTORY_PROTECTOR
	end

	Controls.ProtectorA:SetText(Format("%d", civsCorrected))
	Controls.ProtectorB:SetText(Format("%d", sorcerersDestroyed))
	Controls.ProtectorC:SetText(Format("%d", artifactsDestroyed))
	Controls.ProtectorScore:SetText(Format("%d", score))

	g_scores[g_iActivePlayer] = score
	for iPlayer in pairs(MapModData.fullCivs) do
		if iPlayer ~= g_iActivePlayer then
			g_scores[iPlayer] = GetProtectorVictoryData(iPlayer)
		end
	end
	
	local n = g_numCivs < 3 and g_numCivs or 3
	local top = GetBestAsTable(g_scores, n, true, false, nil)

	local iPlayer = top[1]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.ProtectorCiv1:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.ProtectorScore1:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.ProtectorCiv1:SetText("")
		Controls.ProtectorScore1:SetText("")
	end

	iPlayer = top[2]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.ProtectorCiv2:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.ProtectorScore2:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.ProtectorCiv2:SetText("")
		Controls.ProtectorScore2:SetText("")
	end

	iPlayer = top[3]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.ProtectorCiv3:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.ProtectorScore3:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.ProtectorCiv3:SetText("")
		Controls.ProtectorScore3:SetText("")
	end
end

function PopulateDestroyer()
	print("PopulateDestroyer")
	local score, bVictory, manaConsumed, manaStored, sumOfAllMana = GetDestroyerVictoryData(g_iActivePlayer)
	print(score, bVictory, manaConsumed, manaStored, sumOfAllMana)

	if g_bestModScore < score then
		g_bestModScore = score
		g_bestScoreType = GameInfoTypes.VICTORY_DESTROYER
	end

	local strSumOfAllMana
	if sumOfAllMana < 10000 then
		strSumOfAllMana = tostring(sumOfAllMana)
	elseif sumOfAllMana < 99500 then
		strSumOfAllMana = (Floor(sumOfAllMana / 100 + 0.5) / 10) .. "K"
	elseif sumOfAllMana < 999500 then
		strSumOfAllMana = (Floor(sumOfAllMana / 1000 + 0.5)) .. "K"
	else
		strSumOfAllMana = (Floor(sumOfAllMana / 1000000 + 0.5)) .. "M"
	end

	Controls.DestroyerA:SetText(Format("%d", manaConsumed))
	Controls.DestroyerB:SetText(Format("%d", manaStored))
	Controls.DestroyerC:SetText(strSumOfAllMana)
	Controls.DestroyerScore:SetText(Format("%d", score))

	g_scores[g_iActivePlayer] = score
	for iPlayer in pairs(MapModData.fullCivs) do
		if iPlayer ~= g_iActivePlayer then
			g_scores[iPlayer] = GetDestroyerVictoryData(iPlayer)
		end
	end
	
	local n = g_numCivs < 3 and g_numCivs or 3
	local top = GetBestAsTable(g_scores, n, true, false, nil)

	local iPlayer = top[1]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.DestroyerCiv1:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.DestroyerScore1:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.DestroyerCiv1:SetText("")
		Controls.DestroyerScore1:SetText("")
	end

	iPlayer = top[2]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.DestroyerCiv2:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.DestroyerScore2:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.DestroyerCiv2:SetText("")
		Controls.DestroyerScore2:SetText("")
	end

	iPlayer = top[3]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.DestroyerCiv3:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.DestroyerScore3:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.DestroyerCiv3:SetText("")
		Controls.DestroyerScore3:SetText("")
	end
end

function PopulateRestorer()
	print("PopulateRestorer")
	local score, bVictory, livingTerrainAdded, livingTerrainStrengthAdded, aveWorldLivingTerrainStrength = GetRestorerVictoryData(g_iActivePlayer)
	print(score, bVictory, livingTerrainAdded, livingTerrainStrengthAdded, aveWorldLivingTerrainStrength)

	if g_bestModScore < score then
		g_bestModScore = score
		g_bestScoreType = GameInfoTypes.VICTORY_RESTORER
	end

	Controls.RestorerA:SetText(Format("%d", livingTerrainAdded))
	Controls.RestorerB:SetText(Format("%d", livingTerrainStrengthAdded))
	Controls.RestorerC:SetText(Format("%.2f", aveWorldLivingTerrainStrength))
	Controls.RestorerScore:SetText(Format("%d", score))

	g_scores[g_iActivePlayer] = score
	for iPlayer in pairs(MapModData.fullCivs) do
		if iPlayer ~= g_iActivePlayer then
			g_scores[iPlayer] = GetRestorerVictoryData(iPlayer)
		end
	end
	
	local n = g_numCivs < 3 and g_numCivs or 3
	local top = GetBestAsTable(g_scores, n, true, false, nil)

	local iPlayer = top[1]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.RestorerCiv1:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.RestorerScore1:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.RestorerCiv1:SetText("")
		Controls.RestorerScore1:SetText("")
	end

	iPlayer = top[2]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.RestorerCiv2:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.RestorerScore2:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.RestorerCiv2:SetText("")
		Controls.RestorerScore2:SetText("")
	end

	iPlayer = top[3]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.RestorerCiv3:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.RestorerScore3:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.RestorerCiv3:SetText("")
		Controls.RestorerScore3:SetText("")
	end
end

function PopulateSubduer()
	print("PopulateSubduer")
	local score, bVictory, worldPopulation, worldLand, aveWorldLivingTerrainStrength = GetSubduerVictoryData(g_iActivePlayer)
	print(score, bVictory, worldPopulation, worldLand, aveWorldLivingTerrainStrength)

	if g_bestModScore < score then
		g_bestModScore = score
		g_bestScoreType = GameInfoTypes.VICTORY_SUBDUER
	end

	Controls.SubduerA:SetText(Format("%d%%", worldPopulation))
	Controls.SubduerB:SetText(Format("%d%%", worldLand))
	Controls.SubduerC:SetText(Format("%.2f", aveWorldLivingTerrainStrength))
	Controls.SubduerScore:SetText(Format("%d", score))

	g_scores[g_iActivePlayer] = score
	for iPlayer in pairs(MapModData.fullCivs) do
		if iPlayer ~= g_iActivePlayer then
			g_scores[iPlayer] = GetSubduerVictoryData(iPlayer)
		end
	end
	
	local n = g_numCivs < 3 and g_numCivs or 3
	local top = GetBestAsTable(g_scores, n, true, false, nil)

	local iPlayer = top[1]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.SubduerCiv1:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.SubduerScore1:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.SubduerCiv1:SetText("")
		Controls.SubduerScore1:SetText("")
	end

	iPlayer = top[2]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.SubduerCiv2:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.SubduerScore2:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.SubduerCiv2:SetText("")
		Controls.SubduerScore2:SetText("")
	end

	iPlayer = top[3]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.SubduerCiv3:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.SubduerScore3:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.SubduerCiv3:SetText("")
		Controls.SubduerScore3:SetText("")
	end
end

function PopulateConqueror()
	print("PopulateConqueror")
	local score, bVictory, conqueredPopulation, conqueredCities, uncontrolledCities = GetConquerorVictoryData(g_iActivePlayer)
	print(score, bVictory, conqueredPopulation, conqueredCities, uncontrolledCities)

	if g_bestModScore < score then
		g_bestModScore = score
		g_bestScoreType = GameInfoTypes.VICTORY_CONQUEROR
	end

	Controls.ConquerorA:SetText(Format("%d", conqueredPopulation))
	Controls.ConquerorB:SetText(Format("%d", conqueredCities))
	Controls.ConquerorC:SetText(Format("%d", uncontrolledCities))
	Controls.ConquerorScore:SetText(Format("%d", score))

	g_scores[g_iActivePlayer] = score
	for iPlayer in pairs(MapModData.fullCivs) do
		if iPlayer ~= g_iActivePlayer then
			g_scores[iPlayer] = GetConquerorVictoryData(iPlayer)
		end
	end
	
	local n = g_numCivs < 3 and g_numCivs or 3
	local top = GetBestAsTable(g_scores, n, true, false, nil)

	local iPlayer = top[1]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.ConquerorCiv1:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.ConquerorScore1:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.ConquerorCiv1:SetText("")
		Controls.ConquerorScore1:SetText("")
	end

	iPlayer = top[2]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.ConquerorCiv2:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.ConquerorScore2:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.ConquerorCiv2:SetText("")
		Controls.ConquerorScore2:SetText("")
	end

	iPlayer = top[3]
	if iPlayer and g_scores[iPlayer] > 0 then
		Controls.ConquerorCiv3:LocalizeAndSetText(PreGame.GetCivilizationShortDescription(iPlayer))
		Controls.ConquerorScore3:SetText(Format("%d", g_scores[iPlayer]))
	else
		Controls.ConquerorCiv3:SetText("")
		Controls.ConquerorScore3:SetText("")
	end	
end

function PopulateScoreSummary()
	local bestModVictoryStr = Locale.ToUpper(Locale.Lookup(GameInfo.Victories[g_bestScoreType].Description))
	Controls.BestScoreType:SetText(bestModVictoryStr .. ":")
	Controls.BestModScore:SetText(Format("%d", g_bestModScore))
	Controls.PopulationScore:SetText(Format("%d", g_activePlayer:GetScoreFromPopulation()))
	Controls.CitiesScore:SetText(Format("%d", g_activePlayer:GetScoreFromCities()))
	Controls.LandScore:SetText(Format("%d", g_activePlayer:GetScoreFromLand()))
	Controls.WondersScore:SetText(Format("%d", g_activePlayer:GetScoreFromWonders()))
	Controls.TechsScore:SetText(Format("%d", g_activePlayer:GetScoreFromTechs()))
	Controls.PoliciesScore:SetText(Format("%d", g_activePlayer:GetScoreFromPolicies()))
	Controls.ReligionScore:SetText(Format("%d", g_activePlayer:GetScoreFromReligion()))
	Controls.TotalScore:SetText(Format("%d", g_activePlayer:GetScore()))
end


-------------------------------------------------
-- On Popup
-------------------------------------------------
function OnPopup( popupInfo )
	if popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_VICTORY_INFO then
		m_PopupInfo = popupInfo
		if m_PopupInfo.Data1 == 1 then
        	if ContextPtr:IsHidden() == false then
        	    OnClose()
            else
            	UIManager:QueuePopup( ContextPtr, PopupPriority.eUtmost )
        	end
    	else
        	UIManager:QueuePopup( ContextPtr, PopupPriority.VictoryProgress )
    	end
	end
end
Events.SerialEventGameMessagePopup.Add( OnPopup )

----------------------------------------------------------------
-- Key Down Processing
----------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_RETURN or wParam == Keys.VK_ESCAPE then
			OnClose()
            return true
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );


----------------------------------------------------------------        
----------------------------------------------------------------        
function ShowHideHandler( bIsHide, bIsInit )
    
    if not bIsInit then
        if not bIsHide then
			HandleError10(SetupScreen)
            UI.incTurnTimerSemaphore()
        else
			Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_VICTORY_INFO, 0)
            UI.decTurnTimerSemaphore()
        end
    end

end
ContextPtr:SetShowHideHandler( ShowHideHandler )

function OnClose()
	UIManager:DequeuePopup( ContextPtr )
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnClose )

