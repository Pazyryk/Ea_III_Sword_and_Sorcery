-- EaDebugUtils
-- Author: Pazyryk
-- DateCreated: 12/17/2012 12:34:24 PM
--------------------------------------------------------------



--[[	not needed anymore...
local debugExitTest = {}
function DebugFunctionExitTest(functionName, bStart)
	if bStart then
		if debugExitTest[functionName] then
			for i = 1, 20 do
				print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			end
			print("!!!! ERROR: Function  was not previously exited properly: ", functionName)
		end
		debugExitTest[functionName] = true
	else
		debugExitTest[functionName] = false
	end

end
]]



--------------------------------------------------------------
--------------------------------------------------------------
function BuggeredFunction()
	print("Running BuggeredFunction. You should now see an error...")
	nonexistentObject:NonexistentMethod()
	print("This will never print")
end
--------------------------------------------------------------
--------------------------------------------------------------

