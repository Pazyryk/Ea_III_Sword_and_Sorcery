-- FOWUpdater
-- Author: Pazyryk
-- DateCreated: 4/12/2013 5:55:22 PM
--------------------------------------------------------------

--Keep southernmost 2 rows of map in unexplored state for human player

--Very strange, but fowType from listener is consistantly different than invoking value. In Tuner:

--  > Events.HexFOWStateChanged({x=51, y=15},1,false)
--  FOWUpdater: ListenerHexFOWStateChanged 	51	15	0	false

-- Above makes plot unexplored


-- invoked -> reported (effect)
--		0 -> 2 ("off" = visible)
--		1 -> 0 (unexplored)
--		2 -> 1 (not visible)
-- So 2 is reported when a plot becomes visible, but 0 is used to make plot visible, etc.
-- Use 1 to make plot unexplored when listener reports 2 or 1


--Disabled but keeping in case we ever want something like this
--[[
local function ListenerHexFOWStateChanged(vector2, fowType, bWholeMap)
	--print("ListenerHexFOWStateChanged ", vector2.x, vector2.y, fowType, bWholeMap)
	if  vector2.y < 3 and fowType ~= 0 then				--listener says off or not vis
		Events.HexFOWStateChanged(vector2, 1, false)	--invoker sets to unexplored (which will be 0 in resulting listener call)
	end
end
Events.HexFOWStateChanged.Add(ListenerHexFOWStateChanged)
]]
