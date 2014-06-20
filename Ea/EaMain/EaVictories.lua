-- EaVictories
-- Author: Pazyryk
-- DateCreated: 2/14/2014 8:32:30 AM
--------------------------------------------------------------



local fullCivs =			MapModData.fullCivs

local Floor =				math.floor
local Sort =				table.sort

local g_playerScores = {}
local g_sortedScores = {}


local function AchieveVictory(iPlayer, victoryTypeID, modScore)
	local player = Players[iPlayer]
	--Final score update for victory type
	local oldScore = player:GetScoreFromScenario1()
	if modScore ~= oldScore then
		player:ChangeScoreFromScenario1(modScore - oldScore)
	end

	print("!!!!! Player wins ", GameInfo.Victories[victoryTypeID].Type, " !!!!!")
	Game.SetWinner(player:GetTeam(), victoryTypeID)

end

--TO DO: Use this???
local function OnGameCoreTestVictory()
	print("OnGameCoreTestVictory")

end
GameEvents.GameCoreTestVictory.Add(OnGameCoreTestVictory)


function TestUpdateVictory(iPlayer)
	print("VictoryPerCivTurn ", iPlayer)
	if Game.GetWinner() ~= -1 then
		print("Someone already won; no longer testing victory conditions or adjusting mod scores")
		if Game.GetAIAutoPlay() > 1 then
			Autoplay(1)		--stop autoplay session
		end
		return
	end

	local player = Players[iPlayer]
	local eaPlayer = gPlayers[iPlayer]
	if not eaPlayer then		--iPlayer might be autoplay observer, so pick anyone alive and do test
		for iLoopPlayer, eaLoopPlayer in pairs(fullCivs) do
			local loopPlayer = Players[iPlayer]
			if loopPlayer and loopPlayer:IsAlive() then
				iPlayer, eaPlayer, player = iLoopPlayer, eaLoopPlayer, loopPlayer
				break
			end
		end
	end

	local modScore = 0

	--Protector
	local protectorScore, bProtectorVictory = GetProtectorVictoryData(iPlayer)
	if bProtectorVictory then		--Test for qualified victor with higher score
		local bestScore = protectorScore
		local iWinner = iPlayer
		for iLoopPlayer in pairs(fullCivs) do
			if iLoopPlayer ~= iPlayer then
				local loopScore, bLoopVictory = GetProtectorVictoryData(iLoopPlayer)
				if bLoopVictory and bestScore < loopScore then
					bestScore = loopScore
					iWinner = iLoopPlayer
				end
			end
		end
		AchieveVictory(iWinner, GameInfoTypes.VICTORY_PROTECTOR, modScore)
		return
	end
	modScore = modScore < protectorScore and protectorScore or modScore

	--Destroyer
	local destroyerScore, bDestroyerVictory = GetDestroyerVictoryData(iPlayer)
	if bDestroyerVictory then		--Test for qualified victor with higher score
		local bestScore = destroyerScore
		local iWinner = iPlayer
		for iLoopPlayer in pairs(fullCivs) do
			if iLoopPlayer ~= iPlayer then
				local loopScore, bLoopVictory = GetDestroyerVictoryData(iLoopPlayer)
				if bLoopVictory and bestScore < loopScore then
					bestScore = loopScore
					iWinner = iLoopPlayer
				end
			end
		end
		AchieveVictory(iWinner, GameInfoTypes.VICTORY_DESTROYER, modScore)
		return
	end
	modScore = modScore < destroyerScore and destroyerScore or modScore

	--Restorer
	local restorerScore, bRestorerVictory = GetRestorerVictoryData(iPlayer)
	if bRestorerVictory then		--Test for qualified victor with higher score
		local bestScore = restorerScore
		local iWinner = iPlayer
		for iLoopPlayer in pairs(fullCivs) do
			if iLoopPlayer ~= iPlayer then
				local loopScore, bLoopVictory = GetRestorerVictoryData(iLoopPlayer)
				if bLoopVictory and bestScore < loopScore then
					bestScore = loopScore
					iWinner = iLoopPlayer
				end
			end
		end
		AchieveVictory(iWinner, GameInfoTypes.VICTORY_RESTORER, modScore)
		return
	end
	modScore = modScore < restorerScore and restorerScore or modScore

	--Subduer
	local subduerScore, bSubduerVictory = GetSubduerVictoryData(iPlayer)
	if bSubduerVictory then
		AchieveVictory(iPlayer, GameInfoTypes.VICTORY_SUBDUER, modScore)
		return
	end
	modScore = modScore < subduerScore and subduerScore or modScore

	--Conqueror
	local conquerorScore, bConquerorVictory = GetConquerorVictoryData(iPlayer)
	if bConquerorVictory then
		AchieveVictory(iPlayer, GameInfoTypes.VICTORY_CONQUEROR, modScore)
		return
	end
	modScore = modScore < conquerorScore and conquerorScore or modScore

	--Extra mod score is best from above
	local oldScore = player:GetScoreFromScenario1()
	if modScore ~= oldScore then
		player:ChangeScoreFromScenario1(modScore - oldScore)
	end

	g_playerScores[iPlayer] = player:GetScore()
end

function UpdateFayScore(iPlayer)
	--Set The Fay score based on player scores and world situation; this is purely cosmetic
	local player = Players[iPlayer]
	--Get average from top half, and adjust down
	local nPlayers = 0
	for iLoopPlayer in pairs(fullCivs) do
		local score = g_playerScores[iPlayer] or Players[iLoopPlayer]:GetScore()
		nPlayers = nPlayers + 1
		g_sortedScores[nPlayers] = score
	end
	for i = nPlayers + 1, #g_sortedScores do
		g_sortedScores[i] = nil
	end
	Sort(g_sortedScores)
	local n = Floor(nPlayers / 2 + 1)	--half living civs rounded up
	local sum = 0
	for i = nPlayers - n + 1, nPlayers do	--top n scores
		sum = sum + g_sortedScores[i]
	end
	local fayScore = Floor(sum / n)

	--TO DO: Adjust this down for land development and mana depletion

	player:ChangeScoreFromScenario1(fayScore - player:GetScore())
end

