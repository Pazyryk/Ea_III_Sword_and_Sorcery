This repository tracks changes for Ea III Sword & Sorcery

Current build requires Ea Media Pack (v 5); see readme one level up for link

Mod info and credits: http://forums.civfanatics.com/showthread.php?t=483622

-----------------------------------------------------------------------------
Ea API
New GameDefines, GameEvents and Lua methods by class

--------------------------------------------------------------
-- GameDefines
--------------------------------------------------------------

EA_DLL_VERSION	(=1)
ANIMAL_PLAYER	(=62)
ANIMAL_TEAM		(=62)

--------------------------------------------------------------
-- GameEvents
--------------------------------------------------------------

--CallHook
GameSave()
CombatResult(iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP,iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, plotX, plotY)
CombatEnded(iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP,iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, plotX, plotY)
UnitSetXYPlotEffect(iPlayer, iUnit, x, y, plotEffectID, plotEffectStrength, plotEffectPlayer, plotEffectCaster)
UnitCaptured(iPlayer, iUnit)
BarbExperienceDenied(iPlayer, iUnit, iSummoner, iExperience)	--unmodded experience unit would get if not barb

--CallTestAll
CanAutoSave(bInitial, bPostTurn)
MustAbortAttack(iAttackingPlayer, iAttackingUnit, attackerDamage, attackerFinalDamage, attackerMaxHP,iDefendingPlayer, iDefendingUnit, defenderDamage, defenderFinalDamage, defenderMaxHP, iInterceptingPlayer, iInterceptingUnit, interceptorDamage, plotX, plotY)
CanMeetTeam(iTeam1, iTeam2)
CanContactMajorTeam(iTeam1, iTeam2)
CityCanAcquirePlot(iPlayer, iCity, x, y)
UnitTakingPromotion(iPlayer, iUnit, promotionID)
CanCaptureCivilian(iPlayer, iUnit)				--not used because it won't allow recapture & civilian returns (used UnitCaptured instead)
CanChangeExperience(iPlayer, iUnit, iSummoner, iExperience, iMax, bFromCombat, bInBorders, bUpdateGlobal)	--false prevents xp change to summoned unit
CanCreateTradeRoute(iOriginPlot, iDestPlot, iDestPlayer, eDomain, eConnectionType)

--CallAccumulator
PlayerTechCostMod(iPlayer, techID)
PlayerMinorFriendshipAnchor(eMajor, eMinor)


--Added but currently disabled:
//CityCanRangeStrikeAt(iAttacker, iCity, x, y)	CallTestAll

--------------------------------------------------------------
-- Game
--------------------------------------------------------------

int		GetUnitPower(unitTypeID)	--returns CvUnitEntry::GetPower() for supplied ID 
bool	CanCreateTradeRoute(pOriginCity, pDestCity, DomainTypes, TradeConnectionType, bIgnoreExisting, bCheckPath)

--------------------------------------------------------------
-- City
--------------------------------------------------------------

int		GetCityResidentYieldBoost(int yieldTypeID)
void	SetCityResidentYieldBoost(int yieldTypeID, iNewValue)
void	SetNumFreeBuilding(BuildingTypes iIndex, int iNewValue)
int		GetFaithPerTurnFromSpecialists()

--------------------------------------------------------------
-- Player
--------------------------------------------------------------
void	ChangeCivilizationType(eNewCivType)
void	ChangeLeaderType(eNewLeaderType)
void	SetFoundedFirstCity()
int		GetLeaderYieldBoost(int yieldTypeID)
void	SetLeaderYieldBoost(int yieldTypeID, iNewValue)
bool	IsYieldFromSpecialPlotsOnly()
void	SetYieldFromSpecialPlotsOnly(bool bValue)	--used to restrict plot yields for Pantheistic civs
int		GetNumRealPolicies()						--counts only non-Utility policies
int		GetHappinessFromMod()						--persisted happy and unhappy from mod
void	SetHappinessFromMod(int)
int		GetUnhappinessFromMod()
void	SetUnhappinessFromMod(int)
int		GetWarmongerModifier()		--returns the penalty to warmonger levels OTHER players gain for taking actions against THIS player (default 0)
void	SetWarmongerModifier(int)	--100 means actions against this player create NO warmonger effect for anyone




--------------------------------------------------------------
-- Plots
--------------------------------------------------------------
void				AddFloatUpMessage(sMessage, fDelay, iShowPlayer)	--last two optional	
int, int			GetXY()
int, int, int		GetXYIndex()
int					GetLivingTerrainType()
void				SetLivingTerrainType(int)
int					GetLivingTerrainStrength()
void				SetLivingTerrainStrength(int)
int					GetLivingTerrainChopTurn()
void				SetLivingTerrainChopTurn(int)
bool				GetLivingTerrainPresent()
void				SetLivingTerrainPresent(bool)
int, bool, int, int	GetLivingTerrainData()
void				SetLivingTerrainData(int, bool, int, int)
void				SetPlotEffectData(effectID, effectStength, iPlayer, iCaster)
int, int, int, int	GetPlotEffectData()								--args above

--------------------------------------------------------------
-- TeamTechs
--------------------------------------------------------------
int					GetNumRealTechsKnown()	--counts only non-Utility techs

--------------------------------------------------------------
-- Unit
--------------------------------------------------------------
int					GetPersonIndex()
void				SetPersonIndex(int iIndex)
int					GetSummonerIndex()
void				SetSummonerIndex(int iIndex)
int					GetMorale()
void				SetMorale(int iMorale)
void				ChangeMorale(int iChange)
void				DecayMorale(int iDecayTo)
int InvisibleTypes	SetInvisibleType()
int InvisibleTypes	SetSeeInvisibleType()
int					GetGPAttackState()
void				SetGPAttackState(int iIndex)
void				TestPromotionReady()
int					TurnsToReachTarget(Plot targetPlot, bool bReusePaths, bool bIgnoreUnits, bool bIgnoreStacking)		--0 means can reach with movement left; returns 2147483647 if no path
int					GetPower()
void				SetTurnProcessed(bool bValue)		--added by mistake (has something to do with AI processing)

--------------------------------------------------------------
API Notes:
1. PersonIndex has no effect on dll side; only used by Lua.
2. Morale is used on dll side to modify combat strength.
3. GPAttackState is set on Lua side but used by dll to control combat rules:
	 -1  GP Default: can only attack other GPs; weak defender for defender unit selection
	  0  Warrior Default: strong defender if attack is from GP; otherwise weak defender
	  1  Warrior Charge (temp): must be a normal combat unit to attack
	  2  Warrior Challenge (temp): must be a Warrior GP to attack
4. Get/SetBaseCombatStrength are useful now because combat value is persisted and Get returns actual unit value rather than table value. 





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

BARB_PLAYER_INDEX			--constants (could be global or local; usually but not always integer)
iPlayer, iUnit, iPlot		--object index number (sometimes use "___Index" instead for clarity)
buildingID, policyID		--IDs for DB items ("unitTypeID" used for additional disambiguation)
buildingType, policyType	--Type string for DB items
buildingInfo, policyInfo	--row from DB ID/Type table (sometimes violated by dropping "Info")
g_player, g_iPlayer			--file level control structures (shared among functions in some files)
gg_unitMorale				--global tables (not preserved so must be inited)
gPlayers, gPeople, gCities	--global tables contained in gT so preserved through save/reload
eaPlayer, eaPerson, eaCity	--an object from above (ideally, these should be collapsed into DLL objects)
SetAIValue					--either a function or a table of functions (global or local)
bAllow						--either a boolean or a table of booleans
player, row, name, i, x, y	--anything else; type is almost always self-evident

-----------------------------------------------------------------------------
Lua file organization is a work in progress, but here is the way they are supposed to be by section:

Settings. Defines constants used by file for debuging, balance or AI calibration

File Locals. Defines new locals and localizes global values (of any kind) that will be used in the file.
	GameInfoTypes values that are needed often are localized into constants named after the key (see
	example below; this could be confusing when you see it used in code).

	local BARB_PLAYER_INDEX = BARB_PLAYER_INDEX		--localized global constant
	local UNIT_WORKBOAT = GameInfoTypes.UNIT_WORKBOAT	--only what we need often in this file
	local PlotDistance = Map.PlotDistance
	local floor = math.floor
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