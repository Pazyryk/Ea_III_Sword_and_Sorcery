-- Load this file before EaPeople and EaCivs (may be needed for both)

CREATE TABLE EaRaces (	'ID' INTEGER PRIMARY KEY AUTOINCREMENT,		--info used for civ, city or person (not necessarily the same)
						'Type' TEXT NOT NULL UNIQUE,
						'Description' TEXT DEFAULT NULL,
						'PediaCategoryText' TEXT DEFAULT NULL,

						--City
						'IdentifierBuilding' TEXT DEFAULT NULL,
						'FirstCityName' TEXT DEFAULT NULL,

						--EaPeople
						'NominalLifeSpan' INTEGER DEFAULT -1,		-- -1 for ageless
						'VeryOldDeathChance' INTEGER DEFAULT NULL,	-- chance of old age death each year from 85% to 100% of nominal (out of 1000)
						'AncientDeathChance' INTEGER DEFAULT NULL);	-- chance of old age death each year at and after 100% of nominal (out of 1000)

--Civ & city races
INSERT INTO EaRaces (Type,	Description,			PediaCategoryText,	IdentifierBuilding,		FirstCityName,						NominalLifeSpan,	VeryOldDeathChance,	AncientDeathChance)
SELECT 'EARACE_MAN',		'TXT_KEY_EA_MAN',		'TXT_KEY_EA_MAN',	'BUILDING_MAN',			'TXT_KEY_EA_FIRST_CITY_MAN',		80,					55,					110		 UNION ALL
SELECT 'EARACE_SIDHE',		'TXT_KEY_EA_SIDHE',		'TXT_KEY_EA_SIDHE',	'BUILDING_SIDHE',		'TXT_KEY_EA_FIRST_CITY_SIDHE',		-1,					NULL,				NULL	 UNION ALL
SELECT 'EARACE_HELDEOFOL',	'TXT_KEY_EA_HELDEOFOL',	NULL,				'BUILDING_HELDEOFOL',	'TXT_KEY_EA_FIRST_CITY_HELDEOFOL',	50,					95,					190		 UNION ALL
SELECT 'EARACE_FAY',		'TXT_KEY_EA_FAY',		'TXT_KEY_EA_FAY',	NULL,					NULL,								-1,					NULL,				NULL	 ;

--non-Civ races (e.g., subraces of Heldeofol)
INSERT INTO EaRaces (Type,	Description,			PediaCategoryText,			NominalLifeSpan,	VeryOldDeathChance,	AncientDeathChance)
SELECT 'EARACE_ORC',	'TXT_KEY_EARACE_ORC',		'TXT_KEY_EA_ORC_SUB',		50,					95,					190		 UNION ALL
SELECT 'EARACE_GOBLIN',	'TXT_KEY_EARACE_GOBLIN',	'TXT_KEY_EA_GOBLIN_SUB',	60,					95,					190		 ;


INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaRaces.sql';