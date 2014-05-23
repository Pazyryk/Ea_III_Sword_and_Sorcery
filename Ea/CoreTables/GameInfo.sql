-- Contains GameInfo table changes except Policies and PolicyBranchTypes (in Policies.sql)


-------------------------------------------------------------------------
-- Eras 
-------------------------------------------------------------------------
DELETE FROM Eras WHERE Type NOT IN ('ERA_ANCIENT', 'ERA_CLASSICAL');
UPDATE Eras SET StartingDefenseUnits = 0;

UPDATE Era_Soundtracks SET EraType = 'ERA_ANCIENT' WHERE EraType IN ('ERA_CLASSICAL', 'ERA_MEDIEVAL');
DELETE FROM Era_Soundtracks WHERE EraType <> 'ERA_ANCIENT';

DELETE FROM Era_CitySoundscapes WHERE EraType NOT IN ('ERA_ANCIENT','ERA_CLASSICAL');
DELETE FROM Era_NewEraVOs WHERE EraType NOT IN ('ERA_ANCIENT', 'ERA_CLASSICAL');

--fixinator
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM Eras ORDER BY ID;
UPDATE Eras SET ID =	( SELECT IDRemapper.id-1 FROM IDRemapper WHERE Eras.Type = IDRemapper.Type);
DROP TABLE IDRemapper;

-------------------------------------------------------------------------
-- GoodyHuts 
-------------------------------------------------------------------------
DELETE FROM GoodyHuts WHERE Type IN ('GOODY_PANTHEON_FAITH', 'GOODY_PROPHET_FAITH', 'GOODY_TECH', 'GOODY_WARRIOR', 'GOODY_SETTLER', 'GOODY_SCOUT', 'GOODY_WORKER');
UPDATE GoodyHuts SET BarbarianUnitClass = 'UNITCLASS_WARRIORS_ORC' WHERE Type IN ('GOODY_BARBARIANS_WEAK', 'GOODY_BARBARIANS_STRONG');
--fixinator
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM GoodyHuts ORDER BY ID;
UPDATE GoodyHuts SET ID =	( SELECT IDRemapper.id-1 FROM IDRemapper WHERE GoodyHuts.Type = IDRemapper.Type);
DROP TABLE IDRemapper;

-------------------------------------------------------------------------
-- HandicapInfos 
-------------------------------------------------------------------------
ALTER TABLE HandicapInfos ADD COLUMN 'EaAIFreeTechs' INTEGER DEFAULT 0;		--Replaces HandicapInfo_AIFreeTechs bonuses
UPDATE HandicapInfos SET EaAIFreeTechs = ID - 3 WHERE Type IN ('HANDICAP_KING', 'HANDICAP_EMPEROR', 'HANDICAP_IMMORTAL', 'HANDICAP_DEITY');	-- 1-4 free techs (for King-Diety) given at turn 50, 100, 150, 200; these are free from KM


UPDATE HandicapInfos SET HappinessDefault = HappinessDefault - 4;	--impossible to add unhappiness later, so take it away here so we can give/withdraw extra happiness

DELETE FROM HandicapInfo_FreeTechs;		--empty in base
DELETE FROM HandicapInfo_AIFreeTechs;
DELETE FROM HandicapInfo_Goodies WHERE GoodyType IN ('GOODY_PANTHEON_FAITH', 'GOODY_PROPHET_FAITH', 'GOODY_TECH', 'GOODY_WARRIOR', 'GOODY_SETTLER', 'GOODY_SCOUT', 'GOODY_WORKER');


-------------------------------------------------------------------------
-- Projects 
-------------------------------------------------------------------------
DELETE FROM Projects;
DELETE FROM Project_Flavors;
DELETE FROM Project_Prereqs;
DELETE FROM Project_VictoryThresholds;
DELETE FROM Project_ResourceQuantityRequirements;



-------------------------------------------------------------------------
-- Specialists 
-------------------------------------------------------------------------
DELETE FROM Specialists;
DELETE FROM SpecialistYields;
--Note: SpecialistFlavors table is empty in base
INSERT INTO Specialists (Type, Description, Strategy, Visible, IconAtlas, PortraitIndex, CulturePerTurn)
SELECT 'SPECIALIST_CITIZEN',	'TXT_KEY_SPECIALIST_CITIZEN',		'TXT_KEY_SPECIALIST_CITIZEN_STRATEGY',		1, 'CITIZEN_ATLAS', 5, 0	UNION ALL
SELECT 'SPECIALIST_ARTISAN',	'TXT_KEY_EA_SPECIALIST_ARTISAN',	'TXT_KEY_EA_SPECIALIST_ARTISAN_STRATEGY',	1, 'CITIZEN_ATLAS', 4, 4	UNION ALL
SELECT 'SPECIALIST_SCRIBE',		'TXT_KEY_EA_SPECIALIST_SCRIBE',		'TXT_KEY_EA_SPECIALIST_SCRIBE_STRATEGY',	1, 'CITIZEN_ATLAS', 2, 0	UNION ALL
SELECT 'SPECIALIST_TRADER',		'TXT_KEY_EA_SPECIALIST_TRADER',		'TXT_KEY_EA_SPECIALIST_TRADER_STRATEGY',	1, 'CITIZEN_ATLAS', 3, 0	UNION ALL
SELECT 'SPECIALIST_SMITH',		'TXT_KEY_EA_SPECIALIST_SMITH',		'TXT_KEY_EA_SPECIALIST_SMITH_STRATEGY',		1, 'CITIZEN_ATLAS', 1, 0	UNION ALL
SELECT 'SPECIALIST_DISCIPLE',	'TXT_KEY_EA_SPECIALIST_DISCIPLE',	'TXT_KEY_EA_SPECIALIST_DISCIPLE_STRATEGY',	1, 'CITIZEN_ATLAS', 4, 0	UNION ALL
SELECT 'SPECIALIST_ADEPT',	'TXT_KEY_EA_SPECIALIST_ADEPT',	'TXT_KEY_EA_SPECIALIST_ADEPT_STRATEGY',	1, 'CITIZEN_ATLAS', 4, 0	;

INSERT INTO SpecialistYields (SpecialistType, YieldType, Yield)
SELECT 'SPECIALIST_CITIZEN',	'YIELD_PRODUCTION', 1	UNION ALL
SELECT 'SPECIALIST_TRADER',		'YIELD_GOLD',		4	UNION ALL
SELECT 'SPECIALIST_SCRIBE',		'YIELD_SCIENCE',	4	UNION ALL
SELECT 'SPECIALIST_SMITH',		'YIELD_PRODUCTION', 4	UNION ALL
SELECT 'SPECIALIST_DISCIPLE',	'YIELD_FAITH',		4	UNION ALL
SELECT 'SPECIALIST_ADEPT',	'YIELD_FAITH',		4	;

--fixinator
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM Specialists ORDER BY ID;
UPDATE Specialists SET ID =	( SELECT IDRemapper.id-1 FROM IDRemapper WHERE Specialists.Type = IDRemapper.Type);
DROP TABLE IDRemapper;

-------------------------------------------------------------------------
-- Game Options
-------------------------------------------------------------------------
UPDATE GameOptions SET Visible = 0 WHERE Type NOT IN ('GAMEOPTION_NO_CITY_RAZING', 'GAMEOPTION_NO_BARBARIANS', 'GAMEOPTION_RAGING_BARBARIANS',
'GAMEOPTION_NEW_RANDOM_SEED', 'GAMEOPTION_COMPLETE_KILLS', 'GAMEOPTION_NO_GOODY_HUTS',
'GAMEOPTION_POLICY_SAVING', 'GAMEOPTION_PROMOTION_SAVING', 'GAMEOPTION_END_TURN_TIMER_ENABLED',
'GAMEOPTION_DISABLE_START_BIAS', 'GAMEOPTION_QUICK_MOVEMENT');		--All not visible will be automatically set
--not sure about GAMEOPTION_QUICK_COMBAT

-------------------------------------------------------------------------
-- Victories
-------------------------------------------------------------------------

DELETE FROM Victories;	-- WHERE Type != 'VICTORY_TIME';		--BNW crashes on gameload if only 1 victory
INSERT INTO Victories (Type, Description,				VictoryStatement,						VictoryBackground,		Civilopedia,							WinsGame, Audio) VALUES
('VICTORY_DESTROYER',	'TXT_KEY_EA_VICTORY_DESTROYER',	'TXT_KEY_EA_VICTORY_DESTROYER_BANG',	'Victory_Score.dds',	'TXT_KEY_EA_VICTORY_DESTROYER_PEDIA',	1,		'AS2D_VICTORY_SPEECH_ALTERNATE_CONQUEST_VICTORY'),
('VICTORY_PROTECTOR',	'TXT_KEY_EA_VICTORY_PROTECTOR',	'TXT_KEY_EA_VICTORY_PROTECTOR_BANG',	'Victory_Score.dds',	'TXT_KEY_EA_VICTORY_PROTECTOR_PEDIA',	1,		'AS2D_VICTORY_SPEECH_ALTERNATE_CONQUEST_VICTORY'),
('VICTORY_SUBDUER',		'TXT_KEY_EA_VICTORY_SUBDUER',	'TXT_KEY_EA_VICTORY_SUBDUER_BANG',		'Victory_Score.dds',	'TXT_KEY_EA_VICTORY_SUBDUER_PEDIA',		1,		'AS2D_VICTORY_SPEECH_ALTERNATE_CONQUEST_VICTORY'),
('VICTORY_RESTORER',	'TXT_KEY_EA_VICTORY_RESTORER',	'TXT_KEY_EA_VICTORY_RESTORER_BANG',		'Victory_Score.dds',	'TXT_KEY_EA_VICTORY_RESTORER_PEDIA',	1,		'AS2D_VICTORY_SPEECH_ALTERNATE_CONQUEST_VICTORY'),
('VICTORY_CONQUEROR',	'TXT_KEY_EA_VICTORY_CONQUEROR',	'TXT_KEY_EA_VICTORY_CONQUEROR_BANG',	'Victory_Score.dds',	'TXT_KEY_EA_VICTORY_CONQUEROR_PEDIA',	1,		'AS2D_VICTORY_SPEECH_ALTERNATE_CONQUEST_VICTORY');

UPDATE Victories SET Influential = 1;		--Should prevent from ever happening


--fixinator
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM Victories ORDER BY ID;
UPDATE Victories SET ID =	( SELECT IDRemapper.id-1 FROM IDRemapper WHERE Victories.Type = IDRemapper.Type);
DROP TABLE IDRemapper;

-------------------------------------------------------------------------
-- Worlds
-------------------------------------------------------------------------

UPDATE Worlds SET DefaultMinorCivs = DefaultPlayers;
UPDATE Worlds SET NumCitiesTechCostMod = 0;

--debug
INSERT INTO EaDebugTableCheck(FileName) SELECT 'GameInfo.sql';