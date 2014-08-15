-- _Debug
-- Author: Pazyryk
-- DateCreated: 3/24/2014 10:02:52 AM
--------------------------------------------------------------

local bHidden =			MapModData.bHidden

local tableByOrderType = {	[OrderTypes.ORDER_TRAIN] = "Units",
							[OrderTypes.ORDER_CONSTRUCT] = "Buildings",
							[OrderTypes.ORDER_CREATE] = "Projects",
							[OrderTypes.ORDER_MAINTAIN] = "Processes"	}

local function DebugOnPlayerPreAIUnitUpdate(iPlayer)
	if bHidden[iPlayer] then return end
	local player = Players[iPlayer]

	print("*************************************")
	print("DebugOnPlayerPreAIUnitUpdate ", iPlayer)
	for city in player:Cities() do
		local name = city:GetName()
		print("Build queue for ", name, ":")
		local qLength = city:GetOrderQueueLength()
		if qLength > 0 then
			for i = 0, qLength - 1 do
				local queuedOrderType, queuedData1, queuedData2, queuedSave, queuedRush = city:GetOrderFromQueue(i)
				print("* ", GameInfo[tableByOrderType[queuedOrderType]][queuedData1].Type)
			end
		else
			print("!!!! WARNING: Empty build queue !!!!")
			for row in GameInfo.Units() do
				if city:CanTrain(row.ID) then
					print("* City can train ", row.Type)
				end
			end
			for row in GameInfo.Buildings() do
				if city:CanConstruct(row.ID) then
					print("* City can construct ", row.Type)
				end
			end
			for row in GameInfo.Processes() do
				if city:CanMaintain(row.ID, 1) then
					print("* City can maintain ", row.Type)
				end
			end
		end
	end
	print("*************************************")
end
GameEvents.PlayerPreAIUnitUpdate.Add(function(iPlayer) return HandleError10(DebugOnPlayerPreAIUnitUpdate, iPlayer) end)

local function OnRunCombatSim(attackerPlayerID, attackerUnitID, attackerUnitDamage, attackerFinalUnitDamage, attackerMaxHitPoints, defenderPlayerID, defenderUnitID, defenderUnitDamage, defenderFinalUnitDamage, defenderMaxHitPoints,  bContinuation, attackerX, attackerY, defenderX, defenderY)
	print("RunCombatSim ", attackerPlayerID, attackerUnitID, attackerUnitDamage, attackerFinalUnitDamage, attackerMaxHitPoints, defenderPlayerID, defenderUnitID, defenderUnitDamage, defenderFinalUnitDamage, defenderMaxHitPoints,  bContinuation, attackerX, attackerY, defenderX, defenderY)	
	local attackerPlayer = Players[attackerPlayerID]
	local attackerUnit = attackerPlayer:GetUnitByID(attackerUnitID)
	local attackerUnitType = attackerUnit and GameInfo.Units[attackerUnit:GetUnitType()].Type or "nil"
	local defenderPlayer = Players[defenderPlayerID]
	local defenderUnit = defenderPlayer:GetUnitByID(defenderUnitID)
	local defenderUnitType = defenderUnit and GameInfo.Units[defenderUnit:GetUnitType()].Type or "nil"
	print("Attacker: " .. attackerUnitType .. "; Defender: " .. defenderUnitType)
end
Events.RunCombatSim.Add(OnRunCombatSim)

local function OnEndCombatSim(attackerPlayerID, attackerUnitID, attackerUnitDamage, attackerFinalUnitDamage, attackerMaxHitPoints, defenderPlayerID, defenderUnitID, defenderUnitDamage, defenderFinalUnitDamage, defenderMaxHitPoints, attackerX, attackerY, defenderX, defenderY)
	print("EndCombatSim ", attackerPlayerID, attackerUnitID, attackerUnitDamage, attackerFinalUnitDamage, attackerMaxHitPoints, defenderPlayerID, defenderUnitID, defenderUnitDamage, defenderFinalUnitDamage, defenderMaxHitPoints, attackerX, attackerY, defenderX, defenderY)
	local attackerPlayer = Players[attackerPlayerID]
	local attackerUnit = attackerPlayer:GetUnitByID(attackerUnitID)
	local attackerUnitType = attackerUnit and GameInfo.Units[attackerUnit:GetUnitType()].Type or "nil"
	local defenderPlayer = Players[defenderPlayerID]
	local defenderUnit = defenderPlayer:GetUnitByID(defenderUnitID)
	local defenderUnitType = defenderUnit and GameInfo.Units[defenderUnit:GetUnitType()].Type or "nil"
	print("Attacker: " .. attackerUnitType .. "; Defender: " .. defenderUnitType)
end
Events.EndCombatSim.Add(OnEndCombatSim)

function DebugSpellCaster()
	local iCaster = GenerateGreatPerson(0, nil, "Druid", nil, false)
	local spells = gPeople[iCaster].spells
	for eaActionInfo in GameInfo.EaActions() do
		if eaActionInfo.SpellClass and (eaActionInfo.AITarget or eaActionInfo.AICombatRole) then
			spells[#spells + 1] = eaActionInfo.ID
		end
	end
end


--Listener tests

--function OnCanStartMission(iPlayer, iUnit, missionID)
--	print("CanStartMission ", iPlayer, iUnit, missionID)
--	return true
--end
--GameEvents.CanStartMission.Add(OnCanStartMission)





--[[
function ListenerTest1(...)
	print("GameplayFX", ...)
end
Events.GameplayFX.Add(ListenerTest1)

function ListenerTest2(...)
	print("UnitStateChangeDetected", ...)
end
Events.UnitStateChangeDetected.Add(ListenerTest2)

]]
--[[

local i = 0

local function OnNewGameTurn(...)
	i = i + 1
	print("turnEventTest NewGameTurn", ..., i)
end
Events.NewGameTurn.Add(OnNewGameTurn)

local function OnActivePlayerTurnStart(...)
	i = i + 1
	print("turnEventTest ActivePlayerTurnStart", ..., i)
end
Events.ActivePlayerTurnStart.Add(OnActivePlayerTurnStart)

local function OnPlayerDoTurn(...)
	i = i + 1
	print("turnEventTest PlayerDoTurn", ..., i)
end
GameEvents.PlayerDoTurn.Add(OnPlayerDoTurn)

local function OnPlayerPreAIUnitUpdate(...)
	i = i + 1
	print("turnEventTest PlayerPreAIUnitUpdate", ..., i)
end
GameEvents.PlayerPreAIUnitUpdate.Add(OnPlayerPreAIUnitUpdate)

local function OnAIProcessingStartedForPlayer(...)
	i = i + 1
	print("turnEventTest AIProcessingStartedForPlayer", ..., i)
end
Events.AIProcessingStartedForPlayer.Add(OnAIProcessingStartedForPlayer)

local function OnAIProcessingEndedForPlayer(...)
	i = i + 1
	print("turnEventTest AIProcessingEndedForPlayer", ..., i)
end
Events.AIProcessingEndedForPlayer.Add(OnAIProcessingEndedForPlayer)

local function OnActivePlayerTurnEnd(...)
	i = i + 1
	print("turnEventTest ActivePlayerTurnEnd", ..., i)
end
Events.ActivePlayerTurnEnd.Add(OnActivePlayerTurnEnd)

local function OnGameCoreTestVictory(...)
	i = i + 1
	print("turnEventTest GameCoreTestVictory", ..., i)
end
GameEvents.GameCoreTestVictory.Add(OnGameCoreTestVictory)

]]



--Events.ParticleEffectReloadRequested, ParticleEffectStatsRequested, ParticleEffectStatsResponse


--[[

]]

