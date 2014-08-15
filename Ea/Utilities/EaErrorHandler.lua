-- EaErrorHandler
-- Author: Pazyryk
-- DateCreated: 1/15/2013 8:11:09 PM
--------------------------------------------------------------
--Best to set EnableLuaDebugLibrary = 1 in config.ini, but this will work either way
--Use whichever Error Handler you need; the first is fastest and the last the slowest

local getinfo = debug.getinfo
local format = string.format
local unpack = unpack
local xpcall = xpcall
local GetAIAutoPlay = Game.GetAIAutoPlay

local g_errorStr = "none"

local function Traceback(str)
	print(str)
	if not debug then return str end
	if str == g_errorStr then		--debug.getinfo is slow, so don't run 1000 times for the same error
		return str 
	end
	g_errorStr = str
	local level = 1		--level 1 is this function
	print("Stack traceback:")
	str = str .. "[NEWLINE]Stack traceback:"
	while true do
		local info = getinfo(level)
		if not info then break end
		local errorLine = ""
		if info.what == "C" then   -- is a C function?
			errorLine = string.format("%d: %s", level, "C function")
		elseif info.source == "=(tail call)" then
			errorLine = string.format("%d: %s", level, "Tail call")
		elseif not info.name or info.name == "" then
			errorLine = string.format("%d: %s: %d", level, (info.source or "nil"), (info.currentline or "-1"))
		else 
			errorLine = string.format("%d: %s %s: %d", level, (info.name or "nil"), (info.source or "nil"), (info.currentline or "-1"))
		end
		print(errorLine)
		str = str .. "[NEWLINE]" .. errorLine
		level = level + 1
	end
	return str
end

--The first function is here as a model or in case you are in a hurry. Unpack is very slow
--so it's better to use a function with a defined number of function and return args. Pick
--or make one with appropriate arg number (extra add miniscule overhead but work).
--[[
function HandleError(f, ...)	--f can have any number of args and return values
	local g = function() return f(...) end
	local result = {xpcall(g, Traceback)}
	if result[1] then
		return unpack(result, 2)
	end
	if GetAIAutoPlay() > 0 then
		LuaEvents.EaAutoplay(1)		--stop autoplay session
	end
	if MapModData.bEnteredGame then
		LuaEvents.EaErrorPopupDoErrorPopup(result[2])
	else
		MapModData.error = result[2]
	end
end
]]
function HandleError10(f, arg1)		--f can have 0 or 1 arg and no return value
	local g = function() return f(arg1) end
	local success, value = xpcall(g, Traceback)
	if success then
		return
	end
	if GetAIAutoPlay() > 0 then
		LuaEvents.EaAutoplay(1)		--stop autoplay session
	end
	if MapModData.bEnteredGame then
		LuaEvents.EaErrorPopupDoErrorPopup(value)
	else
		MapModData.error = value
	end
end

function HandleError21(f, arg1, arg2)	--f can have up to 2 args and 0 or 1 return value
	local g = function() return f(arg1, arg2) end
	local success, value = xpcall(g, Traceback)
	if success then
		return value
	end
	if GetAIAutoPlay() > 0 then
		LuaEvents.EaAutoplay(1)		--stop autoplay session
	end
	if MapModData.bEnteredGame then
		LuaEvents.EaErrorPopupDoErrorPopup(value)
	else
		MapModData.error = value
	end
end

function HandleError31(f, arg1, arg2, arg3)	--f can have up to 2 args and 0 or 1 return value
	local g = function() return f(arg1, arg2, arg3) end
	local success, value = xpcall(g, Traceback)
	if success then
		return value
	end
	if GetAIAutoPlay() > 0 then
		LuaEvents.EaAutoplay(1)		--stop autoplay session
	end
	if MapModData.bEnteredGame then
		LuaEvents.EaErrorPopupDoErrorPopup(value)
	else
		MapModData.error = value
	end
end

function HandleError41(f, arg1, arg2, arg3, arg4)	--f can have up to 4 args and 0 or 1 return value
	local g = function() return f(arg1, arg2, arg3, arg4) end
	local success, value = xpcall(g, Traceback)
	if success then
		return value
	end
	if GetAIAutoPlay() > 0 then
		LuaEvents.EaAutoplay(1)		--stop autoplay session
	end
	if MapModData.bEnteredGame then
		LuaEvents.EaErrorPopupDoErrorPopup(value)
	else
		MapModData.error = value
	end
end

function HandleError51(f, arg1, arg2, arg3, arg4, arg5)	--f can have up to 4 args and 0 or 1 return value
	local g = function() return f(arg1, arg2, arg3, arg4, arg5) end
	local success, value = xpcall(g, Traceback)
	if success then
		return value
	end
	if GetAIAutoPlay() > 0 then
		LuaEvents.EaAutoplay(1)		--stop autoplay session
	end
	if MapModData.bEnteredGame then
		LuaEvents.EaErrorPopupDoErrorPopup(value)
	else
		MapModData.error = value
	end
end

function HandleError61(f, arg1, arg2, arg3, arg4, arg5, arg6)	--f can have up to 6 args and 0 or 1 return value
	local g = function() return f(arg1, arg2, arg3, arg4, arg5, arg6) end
	local success, value = xpcall(g, Traceback)
	if success then
		return value
	end
	if GetAIAutoPlay() > 0 then
		LuaEvents.EaAutoplay(1)		--stop autoplay session
	end
	if MapModData.bEnteredGame then
		LuaEvents.EaErrorPopupDoErrorPopup(value)
	else
		MapModData.error = value
	end
end

function HandleError81(f, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)	--f can have up to 8 args and 0 or 1 return value
	local g = function() return f(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) end
	local success, value = xpcall(g, Traceback)
	if success then
		return value
	end
	if GetAIAutoPlay() > 0 then
		LuaEvents.EaAutoplay(1)		--stop autoplay session
	end
	if MapModData.bEnteredGame then
		LuaEvents.EaErrorPopupDoErrorPopup(value)
	else
		MapModData.error = value
	end
end

function HandleErrorF0(f, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15)	--f can have up to 15 args and no return value
	local g = function() return f(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15) end
	local success, value = xpcall(g, Traceback)
	if success then
		return
	end
	if GetAIAutoPlay() > 0 then
		LuaEvents.EaAutoplay(1)		--stop autoplay session
	end
	if MapModData.bEnteredGame then
		LuaEvents.EaErrorPopupDoErrorPopup(value)
	else
		MapModData.error = value
	end
end
