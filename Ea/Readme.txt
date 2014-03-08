This repository tracks changes for Ea III Sword & Sorcery

Current build requires Ea Media Pack 20140305, download project at:
http://ge.tt/8CNVC3P1/v/0?c


Mod info and credits: http://forums.civfanatics.com/showthread.php?t=483622

-----------------------------------------------------------------------------
Overall Mod organization by folder:

_MoveToMediaPack	--will move to next version of Ea Media Pack
CoreTables		--modification of existing DB tables, plus some added subtables

CoreUI			--core UI Lua/XML files overwritten by VFS=true
	_font_mod_only	--minor modification to xml files to use Ea font set 
	_FrontEnd	--FrontEnd core UI
	_InGame		--InGame core UI

EaMain			--contains EaMain.lua and included files that run only in the EaMain state
EaTables		--tables created by the mod
EaUI			--UI Lua/XML files added by the mod
EventsDrivers		--Lua files that listen and send graphic instructions via Events
Pregame			--contains AssignStartingPlots.lua and Ea helper file
Temp
Text			--mod text xml files
Utilities		--contains utility Lua files that are safe to include from multiple states


-----------------------------------------------------------------------------
Lua naming conventions follow Firaxis in part, but are much more consist within the mod:

BARB_PLAYER_INDEX		--constants (could be global or local; usually but not always integer)
iPlayer, iUnit, iPlot		--object index number (sometimes use "___Index" instead for clarity)
buildingID, policyID		--IDs for DB items ("unitTypeID" used for additional disambiguation)
buildingType, policyType	--Type string for DB items
buildingInfo, policyInfo	--row from DB ID/Type table (sometimes violated by dropping "Info")
g_player, g_iPlayer		--file level control structures (shared among functions in some files)
gg_unitMorale			--global tables (not preserved so must be inited)
gPlayers, gPeople, gCities	--global tables contained in gT so preserved through save/reload
eaPlayer, eaPerson, eaCity	--an object from above (ideally, these should be collapsed into DLL objects)
SetAIValue			--either a function or a table of functions (global or local)
bFullCivAI			--either a boolean or a table of booleans
player, row, name, i, x, y	--anything else; type is almost always self-evident

-----------------------------------------------------------------------------
Lua file organization is a work in progress, but here is the way they are supposed to be by section:

Settings. Defines constants used by file for debuging, balance or AI calibration

File Locals. Defines new locals and localizes global values (of any kind) that will be used in the file.
	GameInfoTypes values that are needed often are localized into constants named after the key (see
	example below; this could be confusing when you see it used in code).

	local BARB_PLAYER_INDEX = BARB_PLAYER_INDEX		--localized global constant
	local UNIT_WORKBOAT = GameInfoTypes.UNIT_WORKBOAT	--only what we need often in this file
	local Distance = Map.PlotDistance
	local Floor = math.floor
	local gPlayers = gPlayers
	local Players = Players		--Players and Teams keep Firaxis format so violate mod naming conventions
	local policyPrereqs = {}	--cached DB values filled in next section below
	local GetMorale			--local function defined in File Functions section below

Cached Tables. This is where DB table info needed often (or in a more useful structure) is cached into local
	tables, or hard-coded table data is added. Mostly consists of "for loops" that run at file loading. May
	define temporary local functions that are used and then nilled.

Init. If present, a single function called by OnLoadGame (in EaInit.lua) after the whole mod has loaded.

Interface. Contains global functions called from other files and local functions called by Events,
	GameEvents, LuaEvents or UI controls.

File Functions. Contains functions used only within this file. Names are defined in File Locals, but the
	functions themselves are defined and assigned to names here.