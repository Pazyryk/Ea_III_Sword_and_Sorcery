-- strict.lua
-- Author: Pazyryk
-- DateCreated: 8/13/2014
--------------------------------------------------------------
--
-- Modified from http://metalua.luaforge.net/src/lib/strict.lua.html
--
-- Checks uses of undeclared global variables, which often happens due to typos in your code.
--
-- If bTestMainBody = false, then global variables can be declared anywhere in your main body code (i.e., not inside
-- functions) by regular assignment. Even assigning nil will work. Assignment or access to an undeclared global
-- elswhere will cause an error (if bAssert = true) or print ERROR! <source, line#> to Lua.log (if
-- bAssert = false; note that assignment and access will still "work" as in normal lua without strict.lua).
--
-- If bTestMainBody = true, then strict.lua also will object to globals defined in main body after this file has been
-- included, ignoring global functions declared in the main body if bSkipFunctionsInMainBody = true or global
-- tables declared in the main body if bSkipTablesInMainBody = true). This is a useful way to implement strict.lua
-- becuase it forces you to declare all of your globals (other than "skipped" types) in one place BEFORE you include
-- this file.
-- 
-- Regardless of settings, a global name can be removed from strict.lua scrutiny anywhere at any time (after this file
-- has been included) by use of AddStrictLuaExceptions("globalName1", "globalName2", "globalName3", ...).
--
-- To work, user must enable the debug library by setting EnableLuaDebugLibrary = 1 in their config.ini file. Otherwise,
-- strict.lua is not operating, though it will do no harm and calls to included utility functions will do nothing safely.
-- 
-- Usage: Add this file to your mod, set VFS = true, and then include it from your mod's main body:
--
-- include("strict.lua")
--
-- Strict enforcement only starts after the include statement above. If bTestMainBody = true, then all your global
-- (non-function) values must be declared before the include. If bTestMainBody = false, then globals can be declared
-- anywhere in the main body of your code (i.e., not in a function) even after the include.
--
-- Includes three utility funcions:
--	
-- AddStrictLuaExceptions(...) allows user to declare global after this file is included (anywhere regardless of settings)
-- PrintStrictLuaErrors(bSkipRepeats) if bAssert = false, this will print all strict.lua errors that have occured
-- PrintGlobals(bSorted) allows user to see all globals and their contents in the current environment
--
--------------------------------------------------------------
-- Settings
--------------------------------------------------------------

local bAssert = false					--[true] assert error; [false] print ERROR! with source & line number to Lua.log
local bTestMainBody = true				--[true] test in main body; [false] test in functions only

--the next two matter only if bTestMainBody = true:
local bSkipFunctionsInMainBody = true	--don't object to global functions declared in main body after this file included
local bSkipTablesInMainBody = false		--don't object to global tables declared in main body after this file included

--------------------------------------------------------------
-- strict.lua for Civ5
--------------------------------------------------------------

function AddStrictLuaExceptions() end	--safely does nothing if debug library not enabled
function PrintStrictLuaErrors() return "Only works if debug library enabled by setting EnableLuaDebugLibrary = 1 in config.ini" end
function PrintGlobals() return "Only works if debug library enabled by setting EnableLuaDebugLibrary = 1 in config.ini" end

--bail out of this file if debug library not enabled (can't do anything)
if not debug then
	print("Could not use strict.lua because the debug library was not available! Set EnableLuaDebugLibrary = 1 in config.ini to use strict.lua.")
	return
end

print("Setting strict.lua!")

--get the environment and environment metatable
local _G = debug.getfenv(AddStrictLuaExceptions)
local mt = getmetatable(_G)
if mt == nil then
	mt = {}
	setmetatable(_G, mt)
end

--add a place to remember declared global names (and access attempts to keep print statements usable)
mt.__declared = {}
if not bAssert then
	mt.__accessAttempts = {}
end

--localized stuff
local getinfo = debug.getinfo
local rawset = debug.getfenv(pairs).rawset	--PM me if you have questions
local strictLuaErrors = {}
local errorLine = 0

--intercept undeclared assignments: global = x
mt.__newindex = function (t, k, v)
	if not mt.__declared[k] then
		local info = getinfo(2, "S")
		--print("__newindex ", info.what, k, v)
		if info.what ~= "C" and (info.what ~= "main" or (bTestMainBody
				and (not bSkipFunctionsInMainBody or type(v) ~= "function")
				and (not bSkipTablesInMainBody or type(v) ~= "table")  )) then
			info = getinfo(2, "Snl")
			local name = info.name or info.what or "<unknown>"
			local str = "(strict.lua) Assigned to an undeclared variable '" .. k .. "' in " .. name
			if bAssert then
				error(str)
			else
				errorLine = errorLine + 1
				strictLuaErrors[errorLine] = "ERROR! " .. str .. " at:"
				print(strictLuaErrors[errorLine])
				errorLine = errorLine + 1
				strictLuaErrors[errorLine] = string.format("  %s: %d", (info.source or "nil"), (info.currentline or "-1"))
				print(strictLuaErrors[errorLine])
			end
		end
		mt.__declared[k] = true
	end
	rawset(t, k, v)
end
  
--intercept undeclared accesses: x = global
mt.__index = function (t, k)
	if not mt.__declared[k] then
		local info = getinfo(2, "S")
		--print("__index ", info.what, k)
		if info.what ~= "C" then
			info = getinfo(2, "Snl")
			local name = info.name or info.what or "<unknown>"
			local str = "(strict.lua) Accessed an undeclared variable '" .. k .. "' in " .. name
			if bAssert then
				error(str)
			else
				local bRepeat = mt.__accessAttempts[k]
				if bRepeat then
					print("ERROR (repeat)!" .. str .. " at:")
					print(string.format("  %s: %d", (info.source or "nil"), (info.currentline or "-1")))
				else
					errorLine = errorLine + 1
					strictLuaErrors[errorLine] = (bRepeat and "ERROR (repeat)!" or "ERROR! ") .. str .. " at:"
					print(strictLuaErrors[errorLine])
					errorLine = errorLine + 1
					strictLuaErrors[errorLine] = string.format("  %s: %d", (info.source or "nil"), (info.currentline or "-1"))
					print(strictLuaErrors[errorLine])
				end
			end
		end
		if not bAssert then
			mt.__accessAttempts[k] = true		--so we don't keep seeing the same error
		end
	end
	return nil
end

--------------------------------------------------------------
-- utility functions for user
--------------------------------------------------------------

AddStrictLuaExceptions = function(...)	--allows declaration of globals after this file included
	for _, name in pairs({...}) do
		print("Global name will be ignored by strict.lua: ", name)
		mt.__declared[name] = true
	end
end

PrintStrictLuaErrors = function()
	if bAssert then
		print("We don't save errors if bAssert = true; check Lua.log for Runtime Errors")
	elseif errorLine == 0 then
		print("There have been no strict.lua errors")
	else
		for line = 1, errorLine do
			print(strictLuaErrors[line])
		end
	end
end

PrintGlobals = function()	--try it!
	local n = 0
	local names = {}
	for k, v in pairs(_G) do
		n = n + 1
		names[n] = k
	end
	table.sort(names)
	for i = 1, n do
		local k = names[i]
		print (k, _G[k])
	end
end

--this one caused in Fire Tuner, so exclude here
AddStrictLuaExceptions("_cmdr")
