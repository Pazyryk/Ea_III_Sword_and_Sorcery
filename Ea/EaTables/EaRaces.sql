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
INSERT INTO EaRaces (Type,	Description,		PediaCategoryText,	IdentifierBuilding,		FirstCityName,						NominalLifeSpan,	VeryOldDeathChance,	AncientDeathChance) VALUES
('EARACE_MAN',			'TXT_KEY_EA_MAN',		'TXT_KEY_EA_MAN',	'BUILDING_MAN',			'TXT_KEY_EA_FIRST_CITY_MAN',		80,					55,					110		 ),
('EARACE_SIDHE',		'TXT_KEY_EA_SIDHE',		'TXT_KEY_EA_SIDHE',	'BUILDING_SIDHE',		'TXT_KEY_EA_FIRST_CITY_SIDHE',		-1,					NULL,				NULL	 ),
('EARACE_HELDEOFOL',	'TXT_KEY_EA_HELDEOFOL',	NULL,				'BUILDING_HELDEOFOL',	'TXT_KEY_EA_FIRST_CITY_HELDEOFOL',	50,					95,					190		 ),
('EARACE_FAY',			'TXT_KEY_EA_FAY',		'TXT_KEY_EA_FAY',	NULL,					NULL,								-1,					NULL,				NULL	 );

--non-Civ races (e.g., subraces of Heldeofol)
INSERT INTO EaRaces (Type,	Description,		PediaCategoryText,			NominalLifeSpan,	VeryOldDeathChance,	AncientDeathChance) VALUES
('EARACE_ORC',		'TXT_KEY_EARACE_ORC',		'TXT_KEY_EA_ORC_SUB',		50,					95,					190		 ),
('EARACE_GOBLIN',	'TXT_KEY_EARACE_GOBLIN',	'TXT_KEY_EA_GOBLIN_SUB',	60,					95,					190		 );


CREATE TABLE EaRaces_InitialHatreds (	'ObserverRace' TEXT,
										'SubjectRace' TEXT,
										'Value' INTEGER		);

--Civ races only
INSERT INTO EaRaces_InitialHatreds (ObserverRace, SubjectRace, Value) VALUES
('EARACE_MAN',			'EARACE_MAN',		0	),
('EARACE_MAN',			'EARACE_SIDHE',		3	),
('EARACE_MAN',			'EARACE_HELDEOFOL',	6	),
('EARACE_MAN',			'EARACE_FAY',		2	),
('EARACE_SIDHE',		'EARACE_MAN',		3	),
('EARACE_SIDHE',		'EARACE_SIDHE',		0	),
('EARACE_SIDHE',		'EARACE_HELDEOFOL',	6	),
('EARACE_SIDHE',		'EARACE_FAY',		0	),
('EARACE_HELDEOFOL',	'EARACE_MAN',		6	),
('EARACE_HELDEOFOL',	'EARACE_SIDHE',		6	),
('EARACE_HELDEOFOL',	'EARACE_HELDEOFOL',	3	),
('EARACE_HELDEOFOL',	'EARACE_FAY',		3	),
('EARACE_FAY',			'EARACE_MAN',		2	),
('EARACE_FAY',			'EARACE_SIDHE',		0	),
('EARACE_FAY',			'EARACE_HELDEOFOL',	3	),
('EARACE_FAY',			'EARACE_FAY',		0	);

INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaRaces.sql';