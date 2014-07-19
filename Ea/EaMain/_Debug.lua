-- _Debug
-- Author: Pazyryk
-- DateCreated: 3/24/2014 10:02:52 AM
--------------------------------------------------------------



local bHidden =			MapModData.bHidden

--function OnCanStartMission(iPlayer, iUnit, missionID)
--	print("CanStartMission ", iPlayer, iUnit, missionID)
--	return true
--end
--GameEvents.CanStartMission.Add(OnCanStartMission)




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


--[[
function ListenerTest1(...)
	print("GameplayFX", unpack(arg))
end
Events.GameplayFX.Add(ListenerTest1)

function ListenerTest2(...)
	print("UnitStateChangeDetected", unpack(arg))
end
Events.UnitStateChangeDetected.Add(ListenerTest2)



local i = 0

local function OnNewGameTurn(...)
	i = i + 1
	print("turnEventTest NewGameTurn", unpack(arg), i)
end
Events.NewGameTurn.Add(OnNewGameTurn)

local function OnActivePlayerTurnStart(...)
	i = i + 1
	print("turnEventTest ActivePlayerTurnStart", unpack(arg), i)
end
Events.ActivePlayerTurnStart.Add(OnActivePlayerTurnStart)

local function OnPlayerDoTurn(...)
	i = i + 1
	print("turnEventTest PlayerDoTurn", unpack(arg), i)
end
GameEvents.PlayerDoTurn.Add(OnPlayerDoTurn)

local function OnPlayerPreAIUnitUpdate(...)
	i = i + 1
	print("turnEventTest PlayerPreAIUnitUpdate", unpack(arg), i)
end
GameEvents.PlayerPreAIUnitUpdate.Add(OnPlayerPreAIUnitUpdate)

local function OnAIProcessingEndedForPlayer(...)
	i = i + 1
	print("turnEventTest AIProcessingEndedForPlayer", unpack(arg), i)
end
Events.AIProcessingEndedForPlayer.Add(OnAIProcessingEndedForPlayer)

local function OnActivePlayerTurnEnd(...)
	i = i + 1
	print("turnEventTest ActivePlayerTurnEnd", unpack(arg), i)
end
Events.ActivePlayerTurnEnd.Add(OnActivePlayerTurnEnd)

local function OnGameCoreTestVictory(...)
	i = i + 1
	print("turnEventTest GameCoreTestVictory", unpack(arg), i)
end
GameEvents.GameCoreTestVictory.Add(OnGameCoreTestVictory)


local function OnRunCombatSim(...)
	print("OnRunCombatSim ", unpack(arg))
end
Events.RunCombatSim.Add(OnRunCombatSim)

local function OnEndCombatSim(...)
	print("OnEndCombatSim ", unpack(arg))
end
Events.EndCombatSim.Add(OnEndCombatSim)


]]