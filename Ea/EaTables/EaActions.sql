--Interface and AI notes:
--Available EaActions will appear in the unit panel as "action" or "build", even though they are neither. Those
--that appear as "builds" hijack the build progress graphics.

--The AI is totally Lua controlled for these. On each turn we cycle through people, then we:
-- * figure out available EaActions (not just this tile but anywhere)
-- * calculate net value, considering value and distance to valid target and progress (STRONGLY weight for current EaAction)
-- * pick one or continue current action
-- * drive unit to tile
-- * do EaAction


-- Tables
CREATE TABLE EaActions ('ID' INTEGER PRIMARY KEY AUTOINCREMENT,
						'Type' TEXT NOT NULL UNIQUE,
						'Description' TEXT DEFAULT NULL,
						'Help' TEXT DEFAULT NULL,			--Most help is provided in EaAction.lua; use this only if not set there
						--UI
						'UIType' TEXT DEFAULT NULL,		--Action, SecondaryAction, Build, [Spell, CityAction, CivAction]
						--'OrderPriority' INTEGER DEFAULT 0,
						'IconIndex' INTEGER DEFAULT -1,
						'IconAtlas' TEXT DEFAULT NULL,
						'NoFloatUpText' BOOLEAN DEFAULT NULL,
						--AI
						'AICombatRole' TEXT DEFAULT NULL,	-- =NULL,  "CityCapture", "CrowdControl", "Any"
						'AIDontCombatOverride' BOOLEAN DEFAULT NULL,	-- =NULL or 1 (eg, Citadel) Otherwise, GP with combat role will drop what they are doing (if <1/2 done) and go to a combat zone
						'AITarget'  TEXT DEFAULT NULL,		-- Search heuristic. See AITarget methods in EaAIActions.lua
						'AISimpleYield' INTEGER DEFAULT 0,	-- Sets the "per turn payoff" value (p); not needed if AI values set in specific SetAIValues function in EaAction.lua
						'AIAdHocValue' INTEGER DEFAULT 0,	-- Sets an "instant payoff" value (i); not needed if AI values set in specific SetAIValues function in EaAction.lua
						--Spells (if set, all "caster reqs" below are treated as "learn prereq"; they don't apply to casting)
						'SpellClass' TEXT DEFAULT NULL,	--'Divine', 'Arcane', 'Both' or NULL
						'FreeSpellSubclass' TEXT DEFAULT NULL,
						'FallenAltSpell' TEXT DEFAULT NULL,
						--Civ or world reqs
						'TechReq' TEXT DEFAULT NULL,
						'OrTechReq' TEXT DEFAULT NULL,
						'AndTechReq' TEXT DEFAULT NULL,
						'PolicyTrumpsTechReq' TEXT DEFAULT NULL,	--with this policy, the 3 tech reqs above are ignored
						'TechDisallow' TEXT DEFAULT NULL,
						'PolicyReq' TEXT DEFAULT NULL,
						'OrPolicyReq' TEXT DEFAULT NULL,
						'ReligionNotFounded' TEXT DEFAULT NULL,
						'ReligionFounded' TEXT DEFAULT NULL,
						'CivReligion' TEXT DEFAULT NULL,
						'MaleficiumLearnedByAnyone' BOOLEAN DEFAULT NULL,
						'ExcludeFallen' BOOLEAN DEFAULT NULL,
						'ReqEaWonder' TEXT DEFAULT NULL,

						--Unit reqs (any EaAction may also have a Lua req defined in EaActions.lua)
						'GPOnly' BOOLEAN DEFAULT NULL,
						'GPClass' TEXT DEFAULT NULL,	
						'NotGPClass' TEXT DEFAULT NULL,		
						'GPSubclass' TEXT DEFAULT NULL,	
						'OrGPSubclass' TEXT DEFAULT NULL,
						'ExcludeGPSubclass' TEXT DEFAULT NULL,	
						'LevelReq' INTEGER DEFAULT NULL,
						'PromotionReq' TEXT DEFAULT NULL,
						'PromotionDisallow' TEXT DEFAULT NULL,
						'PromotionDisallow2' TEXT DEFAULT NULL,
						'PromotionDisallow3' TEXT DEFAULT NULL,
						'PantheismCult' TEXT DEFAULT NULL,			--doesn't do anything now except restrict to pantheistic
						--non-GP caster prereqs
						'UnitCombatType' TEXT DEFAULT NULL,		
						'NormalCombatUnit' BOOLEAN DEFAULT NULL,		
						'UnitType' TEXT DEFAULT NULL,			
						'OrUnitType' TEXT DEFAULT NULL,			
						'OrUnitType2' TEXT DEFAULT NULL,		
						'UnitTypePrefix1' TEXT DEFAULT NULL,	
						'UnitTypePrefix2' TEXT DEFAULT NULL,	
						'UnitTypePrefix3' TEXT DEFAULT NULL,							
						--Target reqs
						'City' TEXT DEFAULT NULL,			--'Own', 'Foreign', 'Any', 'Not' or NULL
						'CapitalOnly' BOOLEAN DEFAULT NULL,
						'TowerTempleOnly' BOOLEAN DEFAULT NULL,	--Use for Spells only! Assumes ConsiderTowerTemple is true. Must be appropriate for caster (e.g., a Thaumaturge's own Tower)
						'BuildingReq' TEXT DEFAULT NULL,
						'OwnTerritory' BOOLEAN DEFAULT NULL,
						'OwnCityRadius' BOOLEAN DEFAULT NULL,
						'ReqNearbyCityReligion' TEXT DEFAULT NULL,	--Lua checks this only if OwnCityRadius = true
						--'HolyCityDisallow' BOOLEAN DEFAULT NULL,
						--Process
						'GPModType1' TEXT DEFAULT NULL,
						'GPModType2' TEXT DEFAULT NULL,
						'ConsiderTowerTemple' BOOLEAN DEFAULT NULL,	--Use only for Spells!
						'NoGPNumLimit' BOOLEAN DEFAULT NULL,
						'FinishMoves' BOOLEAN DEFAULT 1,
						'StayInvisible' BOOLEAN DEFAULT NULL,
						--'Disappear' BOOLEAN DEFAULT NULL,		--DEPRECIATED
						'TurnsToComplete' INTEGER DEFAULT 1,	--1 immediate; >1 will run until done; 1000 means run forever for human (changes to 8 for AI; so resident will wake up and look around)
						'ProgressHolder' TEXT DEFAULT NULL,			--Person, City or CityCiv or Plot
						'BuildType' TEXT DEFAULT NULL,				--if above is Plot then this should be a valid BuildType
						'UniqueType' TEXT DEFAULT NULL,			-- "National" or "World"
						'DoXP' INTEGER DEFAULT 0,
						'DoGainPromotion' TEXT DEFAULT NULL,
						'FixedFaith' INTEGER DEFAULT 0,
						--Do or Finish sound and FX
						'HumanOnlyFX' INTEGER DEFAULT NULL,		--only one FX now, so it is just a nil test (will be specific ID later)
						'HumanVisibleFX' INTEGER DEFAULT NULL,	--any player but must be visible plot (don't use at same time as above)
						'HumanOnlySound' TEXT DEFAULT NULL,		--"AS2D_INTERFACE_NEW_ERA" works
						'HumanVisibleSound' TEXT DEFAULT NULL,
						'PlayAnywhereSound' TEXT DEFAULT NULL,
						--Do effect (only works when TurnsToComplete = 1)
						'UnitUpgradeTypePrefix' TEXT DEFAULT NULL,	--don't use for Spell!
						--Finish effect (only works when TurnsToComplete > 1)
						'ImprovementType' TEXT DEFAULT NULL,		--must be set with BuildType; Don't use for Spells!
						'ClaimsPlot' BOOLEAN DEFAULT NULL,			--works to radius 10 for now
						'FoundsSpreadsCult' TEXT DEFAULT NULL,
						'Building' TEXT DEFAULT NULL,		--this building already present acts as target disallow
						'BuildingMod' TEXT DEFAULT NULL,	--adds mod instances of this building; this building already present acts as target disallow
						'EaWonder' TEXT DEFAULT NULL,		--Leave NULL for multiple instance wonders!
						'EaEpic' TEXT DEFAULT NULL,
						'EaArtifact' TEXT DEFAULT NULL,
						'BuildsTemple' BOOLEAN DEFAULT NULL,
						'MeetGod' TEXT DEFAULT NULL,		--Note: this is both a Req and Effect (req is that god must be present in game)
						'FinishXP' INTEGER DEFAULT 0);

INSERT INTO EaActions (ID,	Type,			Description,			GPOnly) VALUES
(0,	'EA_ACTION_GO_TO_PLOT',			'TXT_KEY_EA_NOTSHOWN',	1		);	--special action; must have ID = 0


--StayInvisible

--Order here is the order they will appear in actions or builds panel (all before core game actions and builds)

--Non-GP
INSERT INTO EaActions (Type,			Description,							Help,										UnitTypePrefix1,	NormalCombatUnit,	UIType,		AITarget,		City,	IconIndex,	IconAtlas) VALUES
('EA_ACTION_SELL_SLAVES',				'TXT_KEY_EA_ACTION_SELL_SLAVES',		'TXT_KEY_EA_ACTION_SELL_SLAVE_HELP',		'UNIT_SLAVES',		NULL,				'Action',	'OwnCities',	'Own',	17,			'TECH_ATLAS_1'	),
('EA_ACTION_RENDER_SLAVES',				'TXT_KEY_EA_ACTION_RENDER_SLAVES',		'TXT_KEY_EA_ACTION_RENDER_SLAVE_HELP',		'UNIT_SLAVES',		NULL,				'Action',	'OwnCities',	'Own',	5,			'TECH_ATLAS_1'	),
('EA_ACTION_HIRE_OUT_MERC',				'TXT_KEY_EA_ACTION_HIRE_OUT_MERC',		'TXT_KEY_EA_ACTION_HIRE_OUT_MERC_HELP',		NULL,				1,					'Action',	'Self',			NULL,	17,			'TECH_ATLAS_1'	),
('EA_ACTION_CANC_HIRE_OUT_MERC',		'TXT_KEY_EA_ACTION_CANC_HIRE_OUT_MERC',	'TXT_KEY_EA_ACTION_CANC_HIRE_OUT_MERC_HELP',NULL,				1,					'Action',	'Self',			NULL,	17,			'TECH_ATLAS_1'	);

UPDATE EaActions SET BuildingReq = 'BUILDING_SLAVE_MARKET' WHERE Type = 'EA_ACTION_SELL_SLAVES';
UPDATE EaActions SET BuildingReq = 'BUILDING_SLAVE_KNACKERY' WHERE Type = 'EA_ACTION_RENDER_SLAVES';
UPDATE EaActions SET FinishMoves = NULL, PolicyReq = 'POLICY_MERCENARIES', PromotionDisallow = 'PROMOTION_FOR_HIRE', PromotionDisallow2 = 'PROMOTION_MERCENARY', PromotionDisallow3 = 'PROMOTION_SLAVE' WHERE Type = 'EA_ACTION_HIRE_OUT_MERC';
UPDATE EaActions SET FinishMoves = NULL, PolicyReq = 'POLICY_MERCENARIES', PromotionReq = 'PROMOTION_FOR_HIRE' WHERE Type = 'EA_ACTION_CANC_HIRE_OUT_MERC';

--Non-GP alternate upgrades
INSERT INTO EaActions (Type,			Description,				UnitTypePrefix1,		UnitTypePrefix2,		UnitTypePrefix3,	TechReq,				UnitUpgradeTypePrefix) VALUES
('EA_ACTION_UPGRD_MED_INF',				'TXT_KEY_COMMAND_UPGRADE',	'UNIT_WARRIORS',		NULL,					NULL,				'TECH_IRON_WORKING',	'UNIT_MEDIUM_INFANTRY'	),
('EA_ACTION_UPGRD_HEAVY_INF',			'TXT_KEY_COMMAND_UPGRADE',	'UNIT_RANGERS',			NULL,					NULL,				'TECH_METAL_CASTING',	'UNIT_HEAVY_INFANTRY'	),
('EA_ACTION_UPGRD_IMMORTALS',			'TXT_KEY_COMMAND_UPGRADE',	'UNIT_WARRIORS',		'UNIT_LIGHT_INFANTRY',	'UNIT_RANGERS',		'TECH_MITHRIL_WORKING',	'UNIT_IMMORTALS'		),
('EA_ACTION_UPGRD_ARQUEBUSSMEN',		'TXT_KEY_COMMAND_UPGRADE',	'UNIT_ARCHERS',			NULL,					NULL,				'TECH_MACHINERY',		'UNIT_ARQUEBUSSMEN'		),
('EA_ACTION_UPGRD_BOWMEN',				'TXT_KEY_COMMAND_UPGRADE',	'UNIT_TRACKERS',		NULL,					NULL,				'TECH_BOWYERS',			'UNIT_BOWMEN'			),
('EA_ACTION_UPGRD_MARKSMEN',			'TXT_KEY_COMMAND_UPGRADE',	'UNIT_RANGERS',			NULL,					NULL,				'TECH_BOWYERS',			'UNIT_MARKSMEN'			),
('EA_ACTION_UPGRD_ARMORED_CAV',			'TXT_KEY_COMMAND_UPGRADE',	'UNIT_HORSEMEN',		NULL,					NULL,				'TECH_HORSEBACK_RIDING','UNIT_ARMORED_CAVALRY'	),
('EA_ACTION_UPGRD_CATAPHRACTS',			'TXT_KEY_COMMAND_UPGRADE',	'UNIT_EQUITES',			'UNIT_RANGERS',			NULL,				'TECH_WAR_HORSES',		'UNIT_CATAPHRACTS'		),
('EA_ACTION_UPGRD_CLIBANARII',			'TXT_KEY_COMMAND_UPGRADE',	'UNIT_EQUITES',			'UNIT_RANGERS',			NULL,				'TECH_WAR_HORSES',		'UNIT_CLIBANARII'		),
('EA_ACTION_UPGRD_F_CATAPULTS',			'TXT_KEY_COMMAND_UPGRADE',	'UNIT_CATAPULTS',		NULL,					NULL,				'TECH_MATHEMATICS',		'UNIT_FIRE_CATAPULTS'	),
('EA_ACTION_UPGRD_F_TREBUCHETS',		'TXT_KEY_COMMAND_UPGRADE',	'UNIT_TREBUCHETS',		NULL,					NULL,				'TECH_MECHANICS',		'UNIT_FIRE_TREBUCHETS'	),
('EA_ACTION_UPGRD_SLAVES_WARRIORS',		'TXT_KEY_COMMAND_UPGRADE',	'UNIT_SLAVES',			NULL,					NULL,				NULL,					'UNIT_WARRIORS'			);

UPDATE EaActions SET UIType = 'Action', AITarget = 'Self', OwnTerritory = 1, IconIndex = 44, IconAtlas = 'UNIT_ACTION_ATLAS' WHERE UnitUpgradeTypePrefix IS NOT NULL;
UPDATE EaActions SET NormalCombatUnit = 1 WHERE UnitUpgradeTypePrefix IS NOT NULL AND Type != 'EA_ACTION_UPGRD_SLAVES_WARRIORS';
UPDATE EaActions SET PolicyReq = 'POLICY_SLAVE_ARMIES' WHERE Type = 'EA_ACTION_UPGRD_SLAVES_WARRIORS';

--GP actions
--Lua assumes that EA_ACTION_TAKE_LEADERSHIP is the first GP action

--Common actions
INSERT INTO EaActions (Type,			Description,							Help,										GPOnly,	UIType,		AITarget,		City,	GPModType1,			ProgressHolder,	IconIndex,	IconAtlas) VALUES
('EA_ACTION_TAKE_LEADERSHIP',			'TXT_KEY_EA_ACTION_TAKE_LEADERSHIP',	'TXT_KEY_EA_ACTION_TAKE_LEADERSHIP_HELP',	1,		'Action',	'OwnCapital',	'Own',	'EAMOD_LEADERSHIP',	NULL,			0,			'EA_ACTION_ATLAS'	),
('EA_ACTION_TAKE_RESIDENCE',			'TXT_KEY_EA_ACTION_TAKE_RESIDENCE',		NULL,										1,		'Action',	'OwnCities',	'Own',	'EAMOD_LEADERSHIP',	'Person',		40,			'UNIT_ACTION_ATLAS'	),
--('EA_ACTION_JOIN',					'TXT_KEY_EA_ACTION_JOIN',				NULL,										1,		'Action',	NULL,			NULL,	NULL,				NULL,			18,			'UNIT_ACTION_ATLAS' ),
('EA_ACTION_HEAL',						'TXT_KEY_EA_ACTION_HEAL',				NULL,										1,		'Action',	'Self',			NULL,	NULL,				NULL,			40,			'UNIT_ACTION_ATLAS'	);

UPDATE EaActions SET CapitalOnly = 1 WHERE Type = 'EA_ACTION_TAKE_LEADERSHIP';
UPDATE EaActions SET TurnsToComplete = 1000 WHERE Type = 'EA_ACTION_TAKE_RESIDENCE';
UPDATE EaActions SET TurnsToComplete = 1, StayInvisible = 1 WHERE Type = 'EA_ACTION_HEAL';

--GP yield actions
INSERT INTO EaActions (Type,			Description,							Help,										GPOnly,	NoGPNumLimit,	UIType,		AITarget,			GPClass,		City,		GPModType1,				TurnsToComplete,	ProgressHolder,	IconIndex,	IconAtlas) VALUES
('EA_ACTION_BUILD',						'TXT_KEY_EA_ACTION_BUILD',				'TXT_KEY_EA_ACTION_BUILD_HELP',				1,		1,				'Action',	'OwnClosestCity',	'Engineer',		'Own',		'EAMOD_CONSTRUCTION',	1000,				'Person',		5,			'TECH_ATLAS_1'			),
('EA_ACTION_TRADE',						'TXT_KEY_EA_ACTION_TRADE',				'TXT_KEY_EA_ACTION_TRADE_HELP',				1,		1,				'Action',	'OwnClosestCity',	'Merchant',		'Own',		'EAMOD_TRADE',			1000,				'Person',		17,			'TECH_ATLAS_1'			),
('EA_ACTION_RESEARCH',					'TXT_KEY_EA_ACTION_RESEARCH',			'TXT_KEY_EA_ACTION_RESEARCH_HELP',			1,		1,				'Action',	'OwnClosestCity',	'Sage',			'Own',		'EAMOD_SCHOLARSHIP',	1000,				'Person',		11,			'BW_ATLAS_1'			),
('EA_ACTION_PERFORM',					'TXT_KEY_EA_ACTION_PERFORM',			'TXT_KEY_EA_ACTION_PERFORM_HELP',			1,		1,				'Action',	'OwnClosestCity',	'Artist',		'Own',		'EAMOD_BARDING',		1000,				'Person',		44,			'BW_ATLAS_1'			),
('EA_ACTION_WORSHIP',					'TXT_KEY_EA_ACTION_WORSHIP',			'TXT_KEY_EA_ACTION_WORSHIP_HELP',			1,		1,				'Action',	'OwnClosestCity',	'Devout',		'Own',		'EAMOD_DEVOTION',		1000,				'Person',		17,			'BW_ATLAS_2'			),
('EA_ACTION_CHANNEL',					'TXT_KEY_EA_ACTION_CHANNEL',			'TXT_KEY_EA_ACTION_CHANNEL_HELP',			1,		1,				'Action',	'OwnTower',			'Thaumaturge',	'Not',		'EAMOD_EVOCATION',		1000,				'Person',		17,			'BW_ATLAS_2'			);

UPDATE EaActions SET NotGPClass = 'Devout' WHERE Type = 'EA_ACTION_CHANNEL';


--Warrior actions
INSERT INTO EaActions (Type,			Description,							Help,										GPOnly,	UIType,		GPClass,		AITarget,		AICombatRole,	GPModType1,				TurnsToComplete,	HumanVisibleFX,	IconIndex,	IconAtlas) VALUES
('EA_ACTION_LEAD_CHARGE',				'TXT_KEY_EA_ACTION_LEAD_CHARGE',		'TXT_KEY_EA_ACTION_LEAD_CHARGE_HELP',		1,		'Action',	'Warrior',		NULL,			'Any',			'EAMOD_COMBAT',			1,					1,				6,			'BW_ATLAS_1'	),
('EA_ACTION_RALLY_TROOPS',				'TXT_KEY_EA_ACTION_RALLY_TROOPS',		'TXT_KEY_EA_ACTION_RALLY_TROOPS_HELP',		1,		'Action',	'Warrior',		NULL,			'Any',			'EAMOD_LEADERSHIP',		1,					1,				33,			'TECH_ATLAS_1'	),
--('EA_ACTION_FORTIFY_TROOPS',			'TXT_KEY_EA_ACTION_FORTIFY_TROOPS',		'TXT_KEY_EA_ACTION_FORTIFY_TROOPS_HELP',	1,		'Action',	'Warrior',		NULL,			'Any',			'EAMOD_LEADERSHIP',		1,					1,				6,			'BW_ATLAS_1'	),
('EA_ACTION_TRAIN_UNIT',				'TXT_KEY_EA_ACTION_TRAIN_UNIT',			'TXT_KEY_EA_ACTION_TRAIN_UNIT_HELP',		1,		'Action',	'Warrior',		'OwnLandUnits',	NULL,			'EAMOD_LEADERSHIP',		1000,				1,				5,			'BW_ATLAS_1'	);

UPDATE EaActions SET FinishMoves = NULL WHERE Type = 'EA_ACTION_LEAD_CHARGE';

--Misc actions
INSERT INTO EaActions (Type,			Description,							Help,										GPOnly,	UIType,		GPClass,		OwnTerritory,	AITarget,		AICombatRole,	GPModType1,				TurnsToComplete,	ProgressHolder,	HumanVisibleFX,	IconIndex,	IconAtlas		) VALUES
('EA_ACTION_OCCUPY_TOWER',				'TXT_KEY_EA_ACTION_OCCUPY_TOWER',		'TXT_KEY_EA_ACTION_OCCUPY_TOWER_HELP',		1,		'Action',	'Thaumaturge',	1,				'VacantTower',	NULL,			NULL,					3,					'Person',		1,				6,			'BW_ATLAS_1'	),
('EA_ACTION_OCCUPY_TEMPLE',				'TXT_KEY_EA_ACTION_OCCUPY_TEMPLE',		'TXT_KEY_EA_ACTION_OCCUPY_TEMPLE_HELP',		1,		'Action',	'Devout',		1,				'VacantTemple',	NULL,			NULL,					3,					'Person',		1,				6,			'BW_ATLAS_1'	);

UPDATE EaActions SET NotGPClass = 'Devout' WHERE Type = 'EA_ACTION_OCCUPY_TOWER';

--Prophecies
INSERT INTO EaActions (Type,			Description,								Help,											GPOnly,	UIType,		DoXP,	AITarget,		AIAdHocValue,	GPClass,	City,		UniqueType,	PlayAnywhereSound,					IconIndex,	IconAtlas) VALUES
('EA_ACTION_PROPHECY_AHURADHATA',		'TXT_KEY_EA_ACTION_PROPHECY_AHURADHATA',	'TXT_KEY_EA_ACTION_PROPHECY_AHURADHATA_HELP',	1,		'Spell',	100,	'OwnCities',	10000,			'Devout',	'Own',		'World',	'AS2D_EVENT_NOTIFICATION_GOOD',		16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_MITHRA',			'TXT_KEY_EA_ACTION_PROPHECY_MITHRA',		'TXT_KEY_EA_ACTION_PROPHECY_MITHRA_HELP',		1,		'Spell',	100,	'OwnCities',	10000,			'Devout',	'Own',		'World',	'AS2D_EVENT_NOTIFICATION_GOOD',		16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_MA',				'TXT_KEY_EA_ACTION_PROPHECY_MA',			'TXT_KEY_EA_ACTION_PROPHECY_MA_HELP',			1,		'Spell',	100,	'OwnCities',	0,				'Devout',	'Own',		'World',	'AS2D_EVENT_NOTIFICATION_GOOD',		16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_VA',				'TXT_KEY_EA_ACTION_PROPHECY_VA',			'TXT_KEY_EA_ACTION_PROPHECY_VA_HELP',			1,		'Spell',	100,	'Self',			0,				'Devout',	NULL,		'World',	'AS2D_EVENT_NOTIFICATION_VERY_BAD',	16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_ANRA',				'TXT_KEY_EA_ACTION_PROPHECY_ANRA',			'TXT_KEY_EA_ACTION_PROPHECY_ANRA_HELP',			1,		'Spell',	100,	'OwnCities',	10000,			'Devout',	'Own',		'World',	'AS2D_EVENT_NOTIFICATION_VERY_BAD',	16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_AESHEMA',			'TXT_KEY_EA_ACTION_PROPHECY_AESHEMA',		'TXT_KEY_EA_ACTION_PROPHECY_AESHEMA_HELP',		1,		'Spell',	100,	'Self',			0,				NULL,		NULL,		'World',	'AS2D_EVENT_NOTIFICATION_VERY_BAD',	16,			'EXPANSION_UNIT_ATLAS_1'			);

UPDATE EaActions SET ReligionNotFounded = 'RELIGION_AZZANDARAYASNA', PolicyReq = 'POLICY_THEISM', TechDisallow = 'TECH_MALEFICIUM', ExcludeFallen = 1 WHERE Type = 'EA_ACTION_PROPHECY_AHURADHATA';
UPDATE EaActions SET ReligionNotFounded = 'RELIGION_ANRA', TechReq = 'TECH_MALEFICIUM' WHERE Type = 'EA_ACTION_PROPHECY_ANRA';
UPDATE EaActions SET MaleficiumLearnedByAnyone = 1 WHERE Type = 'EA_ACTION_PROPHECY_VA';
UPDATE EaActions SET ReligionFounded = 'RELIGION_AZZANDARAYASNA', PolicyReq = 'POLICY_THEISM', TechDisallow = 'TECH_MALEFICIUM', CivReligion = 'RELIGION_AZZANDARAYASNA', ExcludeFallen = 1 WHERE Type = 'EA_ACTION_PROPHECY_MITHRA';
UPDATE EaActions SET DoGainPromotion = 'PROMOTION_PROPHET' WHERE Type GLOB 'EA_ACTION_PROPHECY_*';

--Wonders
INSERT INTO EaActions (Type,			Description,								GPOnly,	TechReq,					UIType,		FinishXP,	AITarget,			AIAdHocValue,	GPClass,		GPSubclass,	OrGPSubclass,	City,	OwnCityRadius,	ClaimsPlot,	GPModType1,				TurnsToComplete,	ProgressHolder,	BuildType,					ImprovementType,					UniqueType,	EaWonder,						MeetGod,						ReqEaWonder,					ReqNearbyCityReligion,			Building,					BuildingMod,					IconIndex,	IconAtlas) VALUES
('EA_ACTION_KOLOSSOS',					'TXT_KEY_EA_ACTION_KOLOSSOS',				1,		'TECH_BRONZE_WORKING',		'Build',	100,		'OwnCities',		0,				'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_KOLOSSOS',			NULL,							NULL,							NULL,							'BUILDING_KOLOSSOS',		'BUILDING_KOLOSSOS_MOD',		4,			'BW_ATLAS_2'				),
('EA_ACTION_MEGALOS_FAROS',				'TXT_KEY_EA_ACTION_MEGALOS_FAROS',			1,		'TECH_SAILING',				'Build',	100,		'OwnCities',		0,				'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_MEGALOS_FAROS',		NULL,							NULL,							NULL,							'BUILDING_MEGALOS_FAROS',	'BUILDING_MEGALOS_FAROS_MOD',	5,			'BW_ATLAS_2'				),
('EA_ACTION_HANGING_GARDENS',			'TXT_KEY_EA_ACTION_HANGING_GARDENS',		1,		'TECH_IRRIGATION',			'Build',	100,		'OwnCities',		0,				'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_HANGING_GARDENS',	NULL,							NULL,							NULL,							'BUILDING_HANGING_GARDENS',	'BUILDING_HANGING_GARDENS_MOD',	3,			'BW_ATLAS_2'				),
('EA_ACTION_UUC_YABNAL',				'TXT_KEY_EA_ACTION_UUC_YABNAL',				1,		'TECH_MASONRY',				'Build',	100,		'OwnCities',		0,				'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_UUC_YABNAL',			NULL,							NULL,							NULL,							'BUILDING_UUC_YABNAL',		'BUILDING_UUC_YABNAL_MOD',		12,			'BW_ATLAS_2'				),
('EA_ACTION_THE_LONG_WALL',				'TXT_KEY_EA_ACTION_THE_LONG_WALL',			1,		'TECH_CONSTRUCTION',		'Build',	100,		'OwnCities',		0,				'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_THE_LONG_WALL',		NULL,							NULL,							NULL,							'BUILDING_THE_LONG_WALL',	'BUILDING_THE_LONG_WALL_MOD',	7,			'BW_ATLAS_2'				),
('EA_ACTION_CLOG_MOR',					'TXT_KEY_EA_ACTION_CLOG_MOR',				1,		'TECH_MACHINERY',			'Build',	100,		'OwnCities',		0,				'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_CLOG_MOR',			NULL,							NULL,							NULL,							'BUILDING_CLOG_MOR',		'BUILDING_CLOG_MOR_MOD',		19,			'BW_ATLAS_2'				),
('EA_ACTION_DA_BAOEN_SI',				'TXT_KEY_EA_ACTION_DA_BAOEN_SI',			1,		'TECH_ARCHITECTURE',		'Build',	100,		'OwnCities',		0,				'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_DA_BAOEN_SI',		NULL,							NULL,							NULL,							'BUILDING_DA_BAOEN_SI',		'BUILDING_DA_BAOEN_SI_MOD',		16,			'BW_ATLAS_2'				),

('EA_ACTION_NATIONAL_TREASURY',			'TXT_KEY_EA_ACTION_NATIONAL_TREASURY',		1,		'TECH_COINAGE',				'Build',	100,		'OwnCities',		0,				'Merchant',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_TRADE',			25,					'City',			NULL,						NULL,								'National',	NULL,							NULL,							NULL,							NULL,							NULL,						'BUILDING_NATIONAL_TREASURY',	1,			'NEW_BLDG_ATLAS_DLC'		),

--plot wonders
('EA_ACTION_STANHENCG',					'TXT_KEY_EA_ACTION_STANHENCG',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	0,				'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_STANHENCG',			'IMPROVEMENT_STANHENCG',			'World',	'EA_WONDER_STANHENCG',			NULL,							NULL,							NULL,							NULL,						NULL,							2,			'BW_ATLAS_2'				),
('EA_ACTION_PYRAMID',					'TXT_KEY_EA_ACTION_PYRAMID',				1,		'TECH_MASONRY',				'Build',	100,		'WonderWorkPlot',	0,				'Engineer',		NULL,		NULL,			'Not',	1,				1,			'EAMOD_CONSTRUCTION',	25,					'Plot',			'BUILD_PYRAMID',			'IMPROVEMENT_PYRAMID',				'World',	'EA_WONDER_PYRAMID',			NULL,							NULL,							NULL,							NULL,						NULL,							0,			'BW_ATLAS_2'				),
('EA_ACTION_GREAT_LIBRARY',				'TXT_KEY_EA_ACTION_GREAT_LIBRARY',			1,		'TECH_PHILOSOPHY',			'Build',	100,		'WonderWorkPlot',	0,				'Sage',			NULL,		NULL,			'Not',	1,				1,			'EAMOD_SCHOLARSHIP',	25,					'Plot',			'BUILD_GREAT_LIBRARY',		'IMPROVEMENT_GREAT_LIBRARY',		'World',	'EA_WONDER_GREAT_LIBRARY',		NULL,							NULL,							NULL,							NULL,						NULL,							1,			'BW_ATLAS_2'				),
('EA_ACTION_ARCANE_TOWER',				'TXT_KEY_EA_ACTION_ARCANE_TOWER',			1,		'TECH_THAUMATURGY',			'Build',	100,		'WonderNoWorkPlot',	0,				'Thaumaturge',	NULL,		NULL,			'Not',	1,				1,			NULL,					25,					'Plot',			'BUILD_ARCANE_TOWER',		'IMPROVEMENT_ARCANE_TOWER',			NULL,		NULL,							NULL,							NULL,							NULL,							NULL,						NULL,							3,			'UNIT_ACTION_ATLAS_EXP2'	),
('EA_ACTION_TEMPLE_AZZANDARA_1',		'TXT_KEY_EA_ACTION_TEMPLE_AZZANDARA_1',		1,		'TECH_DIVINE_LITURGY',		'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_1',	'IMPROVEMENT_TEMPLE_AZZANDARA_1',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_1',	NULL,							NULL,							'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_2',		'TXT_KEY_EA_ACTION_TEMPLE_AZZANDARA_2',		1,		'TECH_DIVINE_VITALISM',		'Build',	100,		'WonderWorkPlot',	2000,			'Devout',		'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_2',	'IMPROVEMENT_TEMPLE_AZZANDARA_2',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_2',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_1',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_3',		'TXT_KEY_EA_ACTION_TEMPLE_AZZANDARA_3',		1,		'TECH_DIVINE_ESSENCE',		'Build',	100,		'WonderWorkPlot',	3000,			'Devout',		'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_3',	'IMPROVEMENT_TEMPLE_AZZANDARA_3',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_3',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_2',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_4',		'TXT_KEY_EA_ACTION_TEMPLE_AZZANDARA_4',		1,		'TECH_HEAVENLY_CYCLES',		'Build',	100,		'WonderWorkPlot',	5000,			'Devout',		'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_4',	'IMPROVEMENT_TEMPLE_AZZANDARA_4',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_4',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_3',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_5',		'TXT_KEY_EA_ACTION_TEMPLE_AZZANDARA_5',		1,		'TECH_CELESTIAL_KNOWLEDGE',	'Build',	100,		'WonderWorkPlot',	8000,			'Devout',		'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_5',	'IMPROVEMENT_TEMPLE_AZZANDARA_5',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_5',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_4',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_6',		'TXT_KEY_EA_ACTION_TEMPLE_AZZANDARA_6',		1,		'TECH_DIVINE_INTERVENTION',	'Build',	100,		'WonderWorkPlot',	9000,			'Devout',		'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_6',	'IMPROVEMENT_TEMPLE_AZZANDARA_6',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_6',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_5',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_7',		'TXT_KEY_EA_ACTION_TEMPLE_AZZANDARA_7',		1,		'TECH_KNOWLEDGE_OF_HEAVEN',	'Build',	100,		'WonderWorkPlot',	10000,			'Devout',		'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_7',	'IMPROVEMENT_TEMPLE_AZZANDARA_7',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_7',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_6',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_1',			'TXT_KEY_EA_ACTION_TEMPLE_AHRIMAN_1',		1,		'TECH_MALEFICIUM',			'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_1',	'IMPROVEMENT_TEMPLE_AHRIMAN_1',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_1',	NULL,							NULL,							'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_2',			'TXT_KEY_EA_ACTION_TEMPLE_AHRIMAN_2',		1,		'TECH_REANIMATION',			'Build',	100,		'WonderWorkPlot',	2000,			'Devout',		'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_2',	'IMPROVEMENT_TEMPLE_AHRIMAN_2',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_2',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_1',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_3',			'TXT_KEY_EA_ACTION_TEMPLE_AHRIMAN_3',		1,		'TECH_SORCERY',				'Build',	100,		'WonderWorkPlot',	3000,			'Devout',		'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_3',	'IMPROVEMENT_TEMPLE_AHRIMAN_3',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_3',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_2',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_4',			'TXT_KEY_EA_ACTION_TEMPLE_AHRIMAN_4',		1,		'TECH_NECROMANCY',			'Build',	100,		'WonderWorkPlot',	5000,			'Devout',		'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_4',	'IMPROVEMENT_TEMPLE_AHRIMAN_4',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_4',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_3',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_5',			'TXT_KEY_EA_ACTION_TEMPLE_AHRIMAN_5',		1,		'TECH_SUMMONING',			'Build',	100,		'WonderWorkPlot',	5000,			'Devout',		'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_5',	'IMPROVEMENT_TEMPLE_AHRIMAN_5',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_5',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_4',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_6',			'TXT_KEY_EA_ACTION_TEMPLE_AHRIMAN_6',		1,		'TECH_SOUL_BINDING',		'Build',	100,		'WonderWorkPlot',	8000,			'Devout',		'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_6',	'IMPROVEMENT_TEMPLE_AHRIMAN_6',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_6',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_5',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_7',			'TXT_KEY_EA_ACTION_TEMPLE_AHRIMAN_7',		1,		'TECH_INVOCATION',			'Build',	100,		'WonderWorkPlot',	8000,			'Devout',		'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_7',	'IMPROVEMENT_TEMPLE_AHRIMAN_7',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_7',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_6',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_8',			'TXT_KEY_EA_ACTION_TEMPLE_AHRIMAN_8',		1,		'TECH_BREACH',				'Build',	100,		'WonderWorkPlot',	9000,			'Devout',		'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_8',	'IMPROVEMENT_TEMPLE_AHRIMAN_8',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_8',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_7',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_9',			'TXT_KEY_EA_ACTION_TEMPLE_AHRIMAN_9',		1,		'TECH_ARMAGEDDON_RITUALS',	'Build',	100,		'WonderWorkPlot',	10000,			'Devout',		'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_9',	'IMPROVEMENT_TEMPLE_AHRIMAN_9',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_9',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_8',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_FAGUS',				'TXT_KEY_EA_ACTION_TEMPLE_FAGUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_FAGUS',		'IMPROVEMENT_TEMPLE_FAGUS',			'World',	'EA_WONDER_TEMPLE_FAGUS',		'MINOR_CIV_GOD_FAGUS',			NULL,							'RELIGION_CULT_OF_LEAVES',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ABELLIO',			'TXT_KEY_EA_ACTION_TEMPLE_ABELLIO',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ABELLIO',		'IMPROVEMENT_TEMPLE_ABELLIO',		'World',	'EA_WONDER_TEMPLE_ABELLIO',		'MINOR_CIV_GOD_ABELLIO',		NULL,							'RELIGION_CULT_OF_LEAVES',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_BUXENUS',			'TXT_KEY_EA_ACTION_TEMPLE_BUXENUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_BUXENUS',		'IMPROVEMENT_TEMPLE_BUXENUS',		'World',	'EA_WONDER_TEMPLE_BUXENUS',		'MINOR_CIV_GOD_BUXENUS',		NULL,							'RELIGION_CULT_OF_LEAVES',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ROBOR',				'TXT_KEY_EA_ACTION_TEMPLE_ROBOR',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ROBOR',		'IMPROVEMENT_TEMPLE_ROBOR',			'World',	'EA_WONDER_TEMPLE_ROBOR',		'MINOR_CIV_GOD_ROBOR',			NULL,							'RELIGION_CULT_OF_LEAVES',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ABNOAB',				'TXT_KEY_EA_ACTION_TEMPLE_ABNOAB',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ABNOAB',		'IMPROVEMENT_TEMPLE_ABNOAB',		'World',	'EA_WONDER_TEMPLE_ABNOAB',		'MINOR_CIV_GOD_ABNOAB',			NULL,							'RELIGION_CULT_OF_LEAVES',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_EPONA',				'TXT_KEY_EA_ACTION_TEMPLE_EPONA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_EPONA',		'IMPROVEMENT_TEMPLE_EPONA',			'World',	'EA_WONDER_TEMPLE_EPONA',		'MINOR_CIV_GOD_EPONA',			NULL,							'RELIGION_CULT_OF_EPONA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ATEPOMARUS',			'TXT_KEY_EA_ACTION_TEMPLE_ATEPOMARUS',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ATEPOMARUS',	'IMPROVEMENT_TEMPLE_ATEPOMARUS',	'World',	'EA_WONDER_TEMPLE_ATEPOMARUS',	'MINOR_CIV_GOD_ATEPOMARUS',		NULL,							'RELIGION_CULT_OF_EPONA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_SABAZIOS',			'TXT_KEY_EA_ACTION_TEMPLE_SABAZIOS',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_SABAZIOS',	'IMPROVEMENT_TEMPLE_SABAZIOS',		'World',	'EA_WONDER_TEMPLE_SABAZIOS',	'MINOR_CIV_GOD_SABAZIOS',		NULL,							'RELIGION_CULT_OF_EPONA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AVETA',				'TXT_KEY_EA_ACTION_TEMPLE_AVETA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AVETA',		'IMPROVEMENT_TEMPLE_AVETA',			'World',	'EA_WONDER_TEMPLE_AVETA',		'MINOR_CIV_GOD_AVETA',			NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_CONDATIS',			'TXT_KEY_EA_ACTION_TEMPLE_CONDATIS',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_CONDATIS',	'IMPROVEMENT_TEMPLE_CONDATIS',		'World',	'EA_WONDER_TEMPLE_CONDATIS',	'MINOR_CIV_GOD_CONDATIS',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ABANDINUS',			'TXT_KEY_EA_ACTION_TEMPLE_ABANDINUS',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ABANDINUS',	'IMPROVEMENT_TEMPLE_ABANDINUS',		'World',	'EA_WONDER_TEMPLE_ABANDINUS',	'MINOR_CIV_GOD_ABANDINUS',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ADSULLATA',			'TXT_KEY_EA_ACTION_TEMPLE_ADSULLATA',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ADSULLATA',	'IMPROVEMENT_TEMPLE_ADSULLATA',		'World',	'EA_WONDER_TEMPLE_ADSULLATA',	'MINOR_CIV_GOD_ADSULLATA',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ICAUNUS',			'TXT_KEY_EA_ACTION_TEMPLE_ICAUNUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ICAUNUS',		'IMPROVEMENT_TEMPLE_ICAUNUS',		'World',	'EA_WONDER_TEMPLE_ICAUNUS',		'MINOR_CIV_GOD_ICAUNUS',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_BELISAMA',			'TXT_KEY_EA_ACTION_TEMPLE_BELISAMA',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_BELISAMA',	'IMPROVEMENT_TEMPLE_BELISAMA',		'World',	'EA_WONDER_TEMPLE_BELISAMA',	'MINOR_CIV_GOD_BELISAMA',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_CLOTA',				'TXT_KEY_EA_ACTION_TEMPLE_CLOTA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_CLOTA',		'IMPROVEMENT_TEMPLE_CLOTA',			'World',	'EA_WONDER_TEMPLE_CLOTA',		'MINOR_CIV_GOD_CLOTA',			NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_SABRINA',			'TXT_KEY_EA_ACTION_TEMPLE_SABRINA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_SABRINA',		'IMPROVEMENT_TEMPLE_SABRINA',		'World',	'EA_WONDER_TEMPLE_SABRINA',		'MINOR_CIV_GOD_SABRINA',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_SEQUANA',			'TXT_KEY_EA_ACTION_TEMPLE_SEQUANA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_SEQUANA',		'IMPROVEMENT_TEMPLE_SEQUANA',		'World',	'EA_WONDER_TEMPLE_SEQUANA',		'MINOR_CIV_GOD_SEQUANA',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_VERBEIA',			'TXT_KEY_EA_ACTION_TEMPLE_VERBEIA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_VERBEIA',		'IMPROVEMENT_TEMPLE_VERBEIA',		'World',	'EA_WONDER_TEMPLE_VERBEIA',		'MINOR_CIV_GOD_VERBEIA',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_BORVO',				'TXT_KEY_EA_ACTION_TEMPLE_BORVO',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_BORVO',		'IMPROVEMENT_TEMPLE_BORVO',			'World',	'EA_WONDER_TEMPLE_BORVO',		'MINOR_CIV_GOD_BORVO',			NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AEGIR',				'TXT_KEY_EA_ACTION_TEMPLE_AEGIR',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AEGIR',		'IMPROVEMENT_TEMPLE_AEGIR',			'World',	'EA_WONDER_TEMPLE_AEGIR',		'MINOR_CIV_GOD_AEGIR',			NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_BARINTHUS',			'TXT_KEY_EA_ACTION_TEMPLE_BARINTHUS',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_BARINTHUS',	'IMPROVEMENT_TEMPLE_BARINTHUS',		'World',	'EA_WONDER_TEMPLE_BARINTHUS',	'MINOR_CIV_GOD_BARINTHUS',		NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_LIBAN',				'TXT_KEY_EA_ACTION_TEMPLE_LIBAN',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_LIBAN',		'IMPROVEMENT_TEMPLE_LIBAN',			'World',	'EA_WONDER_TEMPLE_LIBAN',		'MINOR_CIV_GOD_LIBAN',			NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_FIMAFENG',			'TXT_KEY_EA_ACTION_TEMPLE_FIMAFENG',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_FIMAFENG',	'IMPROVEMENT_TEMPLE_FIMAFENG',		'World',	'EA_WONDER_TEMPLE_FIMAFENG',	'MINOR_CIV_GOD_FIMAFENG',		NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ELDIR',				'TXT_KEY_EA_ACTION_TEMPLE_ELDIR',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ELDIR',		'IMPROVEMENT_TEMPLE_ELDIR',			'World',	'EA_WONDER_TEMPLE_ELDIR',		'MINOR_CIV_GOD_ELDIR',			NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_RITONA',				'TXT_KEY_EA_ACTION_TEMPLE_RITONA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_RITONA',		'IMPROVEMENT_TEMPLE_RITONA',		'World',	'EA_WONDER_TEMPLE_RITONA',		'MINOR_CIV_GOD_RITONA',			NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_BAKKHOS',			'TXT_KEY_EA_ACTION_TEMPLE_BAKKHOS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_BAKKHOS',		'IMPROVEMENT_TEMPLE_BAKKHOS',		'World',	'EA_WONDER_TEMPLE_BAKKHOS',		'MINOR_CIV_GOD_BAKKHOS',		NULL,							'RELIGION_CULT_OF_BAKKHEIA',	NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_PAN',				'TXT_KEY_EA_ACTION_TEMPLE_PAN',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_PAN',			'IMPROVEMENT_TEMPLE_PAN',			'World',	'EA_WONDER_TEMPLE_PAN',			'MINOR_CIV_GOD_PAN',			NULL,							'RELIGION_CULT_OF_BAKKHEIA',	NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_SILENUS',			'TXT_KEY_EA_ACTION_TEMPLE_SILENUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_SILENUS',		'IMPROVEMENT_TEMPLE_SILENUS',		'World',	'EA_WONDER_TEMPLE_SILENUS',		'MINOR_CIV_GOD_SILENUS',		NULL,							'RELIGION_CULT_OF_BAKKHEIA',	NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ERECURA',			'TXT_KEY_EA_ACTION_TEMPLE_ERECURA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ERECURA',		'IMPROVEMENT_TEMPLE_ERECURA',		'World',	'EA_WONDER_TEMPLE_ERECURA',		'MINOR_CIV_GOD_ERECURA',		NULL,							'RELIGION_CULT_OF_PLOUTON',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_VOSEGUS',			'TXT_KEY_EA_ACTION_TEMPLE_VOSEGUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_VOSEGUS',		'IMPROVEMENT_TEMPLE_VOSEGUS',		'World',	'EA_WONDER_TEMPLE_VOSEGUS',		'MINOR_CIV_GOD_VOSEGUS',		NULL,							'RELIGION_CULT_OF_PLOUTON',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_NANTOSUELTA',		'TXT_KEY_EA_ACTION_TEMPLE_NANTOSUELTA',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_NANTOSUELTA',	'IMPROVEMENT_TEMPLE_NANTOSUELTA',	'World',	'EA_WONDER_TEMPLE_NANTOSUELTA',	'MINOR_CIV_GOD_NANTOSUELTA',	NULL,							'RELIGION_CULT_OF_PLOUTON',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_DIS_PATER',			'TXT_KEY_EA_ACTION_TEMPLE_DIS_PATER',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_DIS_PATER',	'IMPROVEMENT_TEMPLE_DIS_PATER',		'World',	'EA_WONDER_TEMPLE_DIS_PATER',	'MINOR_CIV_GOD_DIS_PATER',		NULL,							'RELIGION_CULT_OF_PLOUTON',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_NERGAL',				'TXT_KEY_EA_ACTION_TEMPLE_NERGAL',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_NERGAL',		'IMPROVEMENT_TEMPLE_NERGAL',		'World',	'EA_WONDER_TEMPLE_NERGAL',		'MINOR_CIV_GOD_NERGAL',			NULL,							'RELIGION_CULT_OF_CAHRA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_WADD',				'TXT_KEY_EA_ACTION_TEMPLE_WADD',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_WADD',		'IMPROVEMENT_TEMPLE_WADD',			'World',	'EA_WONDER_TEMPLE_WADD',		'MINOR_CIV_GOD_WADD',			NULL,							'RELIGION_CULT_OF_CAHRA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ABGAL',				'TXT_KEY_EA_ACTION_TEMPLE_ABGAL',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ABGAL',		'IMPROVEMENT_TEMPLE_ABGAL',			'World',	'EA_WONDER_TEMPLE_ABGAL',		'MINOR_CIV_GOD_ABGAL',			NULL,							'RELIGION_CULT_OF_CAHRA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_NESR',				'TXT_KEY_EA_ACTION_TEMPLE_NESR',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			'Devout',		'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_NESR',		'IMPROVEMENT_TEMPLE_NESR',			'World',	'EA_WONDER_TEMPLE_NESR',		'MINOR_CIV_GOD_NESR',			NULL,							'RELIGION_CULT_OF_CAHRA',		NULL,						NULL,							37,			'BW_ATLAS_1'				);

UPDATE EaActions SET PolicyReq = 'POLICY_PANTHEISM' WHERE Type = 'EA_ACTION_STANHENCG';
UPDATE EaActions SET AndTechReq = 'TECH_MASONRY' WHERE Type = 'EA_ACTION_MEGALOS_FAROS';
UPDATE EaActions SET PolicyReq = 'POLICY_SLAVERY' WHERE Type = 'EA_ACTION_UUC_YABNAL';
UPDATE EaActions SET NotGPClass = 'Devout' WHERE Type = 'EA_ACTION_ARCANE_TOWER';
UPDATE EaActions SET BuildsTemple = 1, Help = 'TXT_KEY_' || Type || '_HELP' WHERE Type GLOB 'EA_ACTION_TEMPLE_*';

--Epics
INSERT INTO EaActions (Type,			Description,								Help,											GPOnly,	TechReq,				PolicyReq,			UIType,		FinishXP,	AITarget,			AIAdHocValue,	GPClass,	City,		GPModType1,			TurnsToComplete,	ProgressHolder,	UniqueType,	EaEpic,							IconIndex,	IconAtlas) VALUES
('EA_ACTION_EPIC_VOLUSPA',				'TXT_KEY_EA_ACTION_EPIC_VOLUSPA',			'TXT_KEY_EA_ACTION_EPIC_VOLUSPA_HELP',			1,		NULL,					'POLICY_TRADITION',	'Build',	100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Person',		'World',	'EA_EPIC_VOLUSPA',				32,			'BW_ATLAS_2'			),
('EA_ACTION_EPIC_HAVAMAL',				'TXT_KEY_EA_ACTION_EPIC_HAVAMAL',			'TXT_KEY_EA_ACTION_EPIC_HAVAMAL_HELP',			1,		NULL,					'POLICY_FOLKLORE',	'Build',	100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Person',		'World',	'EA_EPIC_HAVAMAL',				32,			'BW_ATLAS_2'			),
('EA_ACTION_EPIC_VAFTHRUTHNISMAL',		'TXT_KEY_EA_ACTION_EPIC_VAFTHRUTHNISMAL',	'TXT_KEY_EA_ACTION_EPIC_VAFTHRUTHNISMAL_HELP',	1,		'TECH_WRITING',			'POLICY_FOLKLORE',	'Build',	100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Person',		'World',	'EA_EPIC_VAFTHRUTHNISMAL',		32,			'BW_ATLAS_2'			),
('EA_ACTION_EPIC_GRIMNISMAL',			'TXT_KEY_EA_ACTION_EPIC_GRIMNISMAL',		'TXT_KEY_EA_ACTION_EPIC_GRIMNISMAL_HELP',		1,		'TECH_DRAMA',			'POLICY_FOLKLORE',	'Build',	100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Person',		'World',	'EA_EPIC_GRIMNISMAL',			32,			'BW_ATLAS_2'			),
('EA_ACTION_EPIC_HYMISKVITHA',			'TXT_KEY_EA_ACTION_EPIC_HYMISKVITHA',		'TXT_KEY_EA_ACTION_EPIC_HYMISKVITHA_HELP',		1,		'TECH_ZYMURGY',			'POLICY_FOLKLORE',	'Build',	100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Person',		'World',	'EA_EPIC_HYMISKVITHA',			32,			'BW_ATLAS_2'			),
('EA_ACTION_EPIC_NATIONAL',				'TXT_KEY_EA_ACTION_EPIC_NATIONAL',			'TXT_KEY_EA_ACTION_EPIC_NATIONAL_HELP',			1,		'TECH_LITERATURE',		NULL,				'Build',	100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Person',		'National',	NULL,							32,			'BW_ATLAS_2'			);

--Items
INSERT INTO EaActions (Type,			Description,								Help,											GPOnly,	TechReq,					AndTechReq,		BuildingReq,		UIType,		FinishXP,	AITarget,					AIAdHocValue,	GPClass,	City,	GPModType1,				TurnsToComplete,	ProgressHolder,	UniqueType,	EaArtifact,							IconIndex,	IconAtlas) VALUES
('EA_ACTION_TOME_OF_EQUUS',				'TXT_KEY_EA_ACTION_TOME_OF_EQUUS',			'TXT_KEY_EA_ACTION_TOME_OF_EQUUS_HELP',			1,		'TECH_HORSEBACK_RIDING',	'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Person',		'World',	'EA_ARTIFACT_TOME_OF_EQUUS',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_BEASTS',			'TXT_KEY_EA_ACTION_TOME_OF_BEASTS',			'TXT_KEY_EA_ACTION_TOME_OF_BEASTS_HELP',		1,		'TECH_ELEPHANT_TRAINING',	'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Person',		'World',	'EA_ARTIFACT_TOME_OF_BEASTS',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_THE_LEVIATHAN',		'TXT_KEY_EA_ACTION_TOME_OF_THE_LEVIATHAN',	'TXT_KEY_EA_ACTION_TOME_OF_THE_LEVIATHAN_HELP',	1,		'TECH_HARPOONS',			'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Person',		'World',	'EA_ARTIFACT_TOME_OF_THE_LEVIATHAN',2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_HARVESTS',			'TXT_KEY_EA_ACTION_TOME_OF_HARVESTS',		'TXT_KEY_EA_ACTION_TOME_OF_HARVESTS_HELP',		1,		'TECH_IRRIGATION',			'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Person',		'World',	'EA_ARTIFACT_TOME_OF_HARVESTS',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_TOMES',				'TXT_KEY_EA_ACTION_TOME_OF_TOMES',			'TXT_KEY_EA_ACTION_TOME_OF_TOMES_HELP',			1,		'TECH_PHILOSOPHY',			'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Person',		'World',	'EA_ARTIFACT_TOME_OF_TOMES',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_AESTHETICS',		'TXT_KEY_EA_ACTION_TOME_OF_AESTHETICS',		'TXT_KEY_EA_ACTION_TOME_OF_AESTHETICS_HELP',	1,		'TECH_DRAMA',				'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Person',		'World',	'EA_ARTIFACT_TOME_OF_AESTHETICS',	2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_AXIOMS',			'TXT_KEY_EA_ACTION_TOME_OF_AXIOMS',			'TXT_KEY_EA_ACTION_TOME_OF_AXIOMS_HELP',		1,		'TECH_MATHEMATICS',			'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Person',		'World',	'EA_ARTIFACT_TOME_OF_AXIOMS',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_FORM',				'TXT_KEY_EA_ACTION_TOME_OF_FORM',			'TXT_KEY_EA_ACTION_TOME_OF_FORM_HELP',			1,		'TECH_MASONRY',				'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Person',		'World',	'EA_ARTIFACT_TOME_OF_FORM',			2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_METALLURGY',		'TXT_KEY_EA_ACTION_TOME_OF_METALLURGY',		'TXT_KEY_EA_ACTION_TOME_OF_METALLURGY_HELP',	1,		'TECH_BRONZE_WORKING',		'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Person',		'World',	'EA_ARTIFACT_TOME_OF_METALLURGY',	2,			'EXPANSION_SCEN_TECH_ATLAS'			);

--GP non-unique builds
INSERT INTO EaActions (Type,			Description,							Help,								GPOnly,	UIType,		TechReq,				PolicyReq,				FinishXP,	AITarget,		AISimpleYield,	GPClass,	City,		GPModType1,		TurnsToComplete,	ProgressHolder,	Building,				BuildingMod,			HumanOnlySound,			IconIndex,	IconAtlas) VALUES
('EA_ACTION_FOUNDRY',					'TXT_KEY_EA_ACTION_FOUNDRY',			'TXT_KEY_EA_ACTION_FOUNDRY_HELP',	1,		'Build',	'TECH_IRON_WORKING',	NULL,					25,			'OwnCities',	3,				'Engineer',	'Own',		NULL,			8,					'City',			'BUILDING_FOUNDRY',		NULL,					'AS2D_BUILD_UNIT',		1,			'NEW_BLDG_ATLAS2_DLC'	),
('EA_ACTION_ACADEMY',					'TXT_KEY_EA_ACTION_ACADEMY',			'TXT_KEY_EA_ACTION_ACADEMY_HELP',	1,		'Build',	'TECH_PHILOSOPHY',		NULL,					25,			'OwnCities',	3,				'Sage',		'Own',		NULL,			8,					'City',			'BUILDING_ACADEMY',		NULL,					'AS2D_BUILD_UNIT',		1,			'BW_ATLAS_2'			),
('EA_ACTION_FESTIVAL',					'TXT_KEY_EA_ACTION_FESTIVAL',			'TXT_KEY_EA_ACTION_FESTIVAL_HELP',	1,		'Build',	'TECH_CALENDAR',		NULL,					25,			'OwnCities',	3,				'Artist',	'Own',		NULL,			8,					'City',			'BUILDING_FESTIVAL',	NULL,					'AS2D_BUILD_UNIT',		44,			'BW_ATLAS_1'			),
('EA_ACTION_TRADE_HOUSE',				'TXT_KEY_EA_ACTION_TRADE_HOUSE',		NULL,								1,		'Build',	NULL,					'POLICY_FREE_MARKETS',	25,			'OwnCities',	0,				'Merchant',	'Own',		'EAMOD_TRADE',	8,					'City',			NULL,					'BUILDING_TRADE_HOUSE',	'AS2D_BUILD_UNIT',		1,			'NEW_BLDG_ATLAS_DLC'	);

--Other GP builds
INSERT INTO EaActions (Type,			Description,							GPOnly,	UIType,		TechReq,			PolicyReq,				FinishXP,	AITarget,			GPClass,	GPSubclass,		FoundsSpreadsCult,	City,		GPModType1,				TurnsToComplete,	ProgressHolder,	HumanOnlySound,			PlayAnywhereSound,					IconIndex,	IconAtlas) VALUES
('EA_ACTION_LAND_TRADE_ROUTE',			'TXT_KEY_EA_ACTION_LAND_TRADE_ROUTE',	1,		'Action',	'TECH_CURRENCY',	NULL,					25,			'LandTradeCities',	'Merchant',	NULL,			NULL,				'Any',		NULL,					8,					'CityCiv',		'AS2D_BUILD_UNIT',		NULL,								0,			'UNIT_ACTION_ATLAS_TRADE'	),
('EA_ACTION_SEA_TRADE_ROUTE',			'TXT_KEY_EA_ACTION_SEA_TRADE_ROUTE',	1,		'Action',	'TECH_SAILING',		NULL,					25,			'SeaTradeCities',	'Merchant',	NULL,			NULL,				'Any',		NULL,					8,					'CityCiv',		'AS2D_BUILD_UNIT',		NULL,								0,			'UNIT_ACTION_ATLAS_TRADE'	),
('EA_ACTION_TRADE_MISSION',				'TXT_KEY_EA_ACTION_TRADE_MISSION',		1,		'Action',	NULL,				'POLICY_FREE_TRADE',	100,		'ForeignCapitals',	'Merchant',	NULL,			NULL,				'Foreign',	'EAMOD_TRADE',			25,					'CityCiv',		'AS2D_BUILD_UNIT',		NULL,								17,			'TECH_ATLAS_1'				);

UPDATE EaActions SET CapitalOnly = 1 WHERE Type = 'EA_ACTION_TRADE_MISSION';


--Religious conversion and cult founding
INSERT INTO EaActions (Type,			Description,							GPOnly,	UIType,		ReligionFounded,			FinishXP,	AITarget,			GPClass,	GPSubclass,		FoundsSpreadsCult,				City,		GPModType1,				TurnsToComplete,	ProgressHolder,	HumanOnlySound,			PlayAnywhereSound,					IconIndex,	IconAtlas) VALUES
('EA_ACTION_PROSELYTIZE',				'TXT_KEY_EA_ACTION_PROSELYTIZE',		1,		'Action',	'RELIGION_AZZANDARAYASNA',	25,			'AzzandaraSpread',	'Devout',	'Priest',		NULL,							'Any',		'EAMOD_PROSELYTISM',	8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		1,			'EXPANSION_UNIT_ACTION_ATLAS'	),
('EA_ACTION_ANTIPROSELYTIZE',			'TXT_KEY_EA_ACTION_PROSELYTIZE',		1,		'Action',	'RELIGION_ANRA',			25,			'AnraSpread',		'Devout',	'FallenPriest',	NULL,							'Any',		'EAMOD_PROSELYTISM',	8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_VERY_BAD',	1,			'EXPANSION_UNIT_ACTION_ATLAS'	),
('EA_ACTION_RITUAL_LEAVES',				'TXT_KEY_EA_ACTION_RITUAL_LEAVES',		1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		'Devout',	'Druid',		'RELIGION_CULT_OF_LEAVES',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		3,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_CLEANSING',			'TXT_KEY_EA_ACTION_RITUAL_CLEANSING',	1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		'Devout',	'Druid',		'RELIGION_CULT_OF_ABZU',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		6,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_AEGIR',				'TXT_KEY_EA_ACTION_RITUAL_AEGIR',		1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		'Devout',	'Druid',		'RELIGION_CULT_OF_AEGIR',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		7,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_STONES',				'TXT_KEY_EA_ACTION_RITUAL_STONES',		1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		'Devout',	'Druid',		'RELIGION_CULT_OF_PLOUTON',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		8,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_DESICCATION',		'TXT_KEY_EA_ACTION_RITUAL_DESICCATION',	1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		'Devout',	'Druid',		'RELIGION_CULT_OF_CAHRA',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		9,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_EQUUS',				'TXT_KEY_EA_ACTION_RITUAL_EQUUS',		1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		'Devout',	'Druid',		'RELIGION_CULT_OF_EPONA',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		5,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_BAKKHEIA',			'TXT_KEY_EA_ACTION_RITUAL_BAKKHEIA',	1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		'Devout',	'Druid',		'RELIGION_CULT_OF_BAKKHEIA',	'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		4,			'EA_RELIGION_ATLAS'				);

UPDATE EaActions SET OrGPSubclass = 'Paladin' WHERE Type = 'EA_ACTION_PROSELYTIZE';
UPDATE EaActions SET OrGPSubclass = 'Eidolon' WHERE Type = 'EA_ACTION_ANTIPROSELYTIZE';



-----------------------------------------------------------------------------------------
--Spells (MUST come last!)
-----------------------------------------------------------------------------------------
-- These are EaActions but treated in a special way: All non-target prereqs are only "learn" prereqs
-- The spell is always castable if it is known and target is valid and player has sufficient mana or divine favor.

--Arcane
INSERT INTO EaActions (Type,			SpellClass,	GPModType1,				TechReq,						City,	AITarget,			AICombatRole,	TurnsToComplete,	FixedFaith,	HumanVisibleFX,	IconIndex,	IconAtlas			) VALUES
('EA_SPELL_SCRYING',					'Arcane',	'EAMOD_DIVINATION',		'TECH_THAUMATURGY',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_SEEING_EYE_GLYPH',			'Arcane',	'EAMOD_DIVINATION',		'TECH_THAUMATURGY',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_DETECT_GLYPHS_RUNES_WARDS',	'Arcane',	'EAMOD_DIVINATION',		'TECH_THAUMATURGY',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_KNOW_WORLD',					'Arcane',	'EAMOD_DIVINATION',		'TECH_COSMOGONY',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_DISPEL_HEXES',				'Arcane',	'EAMOD_ABJURATION',		'TECH_ABJURATION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_DISPEL_GLYPHS_RUNES_WARDS',	'Arcane',	'EAMOD_ABJURATION',		'TECH_ABJURATION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_DISPEL_ILLUSIONS',			'Arcane',	'EAMOD_ABJURATION',		'TECH_ABJURATION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_BANISHMENT',					'Arcane',	'EAMOD_ABJURATION',		'TECH_ABJURATION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_PROTECTIVE_WARD',			'Arcane',	'EAMOD_ABJURATION',		'TECH_ABJURATION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_DISPEL_MAGIC',				'Arcane',	'EAMOD_ABJURATION',		'TECH_INVOCATION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_TIME_STOP',					'Arcane',	'EAMOD_ABJURATION',		'TECH_GREATER_ARCANA',			NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_MAGIC_MISSILE',				'Arcane',	'EAMOD_EVOCATION',		'TECH_THAUMATURGY',				NULL,	NULL,				'Any',			1,					0,			NULL,			0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_EXPLOSIVE_RUNE',				'Arcane',	'EAMOD_EVOCATION',		'TECH_EVOCATION',				'Not',	'BoobyTrap',		NULL,			3,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_MAGE_SWORD',					'Arcane',	'EAMOD_EVOCATION',		'TECH_EVOCATION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_BREACH',						'Arcane',	'EAMOD_EVOCATION',		'TECH_BREACH',					NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_WISH',						'Arcane',	'EAMOD_EVOCATION',		'TECH_ESOTERIC_ARCANA',			NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_SLOW',						'Arcane',	'EAMOD_EVOCATION',		'TECH_TRANSMUTATION',			NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_HASTE',						'Arcane',	'EAMOD_TRANSMUTATION',	'TECH_TRANSMUTATION',			NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_ENCHANT_WEAPONS',			'Arcane',	'EAMOD_TRANSMUTATION',	'TECH_TRANSMUTATION',			NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_POLYMORPH',					'Arcane',	'EAMOD_TRANSMUTATION',	'TECH_TRANSMUTATION',			NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_BLIGHT',						'Arcane',	'EAMOD_TRANSMUTATION',	'TECH_SORCERY',					'Not',	'NIMBY',			NULL,			5,					0,			1,				9,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_HEX',						'Arcane',	'EAMOD_CONJURATION',	'TECH_MALEFICIUM',				NULL,	NULL,				'Any',			1,					0,			1,				9,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CONJURE_MONSTER',			'Arcane',	'EAMOD_CONJURATION',	'TECH_CONJURATION',				NULL,	'SelfAndTower',		NULL,			3,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_TELEPORT',					'Arcane',	'EAMOD_CONJURATION',	'TECH_CONJURATION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_PHASE_DOOR',					'Arcane',	'EAMOD_CONJURATION',	'TECH_INVOCATION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_REANIMATE_DEAD',				'Arcane',	'EAMOD_NECROMANCY',		'TECH_REANIMATION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_RAISE_DEAD',					'Arcane',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				NULL,	'SelfAndTower',		NULL,			3,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_DEATH_RUNE',					'Arcane',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				'Not',	'BoobyTrap',		NULL,			3,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_VAMPIRIC_TOUCH',				'Arcane',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_DEATH_STAY',					'Arcane',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_BECOME_LICH',				'Arcane',	'EAMOD_NECROMANCY',		'TECH_SOUL_BINDING',			NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_FINGER_OF_DEATH',			'Arcane',	'EAMOD_NECROMANCY',		'TECH_SOUL_BINDING',			NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CHARM_MONSTER',				'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_MUSIC',					NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CAUSE_FEAR',					'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CAUSE_DISPAIR',				'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_SLEEP',						'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_DREAM',						'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_NIGHTMARE',					'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_LESSER_GEAS',				'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_GREATER_GEAS',				'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_PRESTIDIGITATION',			'Arcane',	'EAMOD_ILLUSION',		'TECH_ILLUSION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_OBSCURE_TERRAIN',			'Arcane',	'EAMOD_ILLUSION',		'TECH_ILLUSION',				NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_FOG_OF_WAR',					'Arcane',	'EAMOD_ILLUSION',		'TECH_GREATER_ILLUSION',		NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_SIMULACRUM',					'Arcane',	'EAMOD_ILLUSION',		'TECH_GREATER_ILLUSION',		NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_PHANTASMAGORIA',				'Arcane',	'EAMOD_ILLUSION',		'TECH_PHANTASMAGORIA',			NULL,	NULL,				NULL,			1,					0,			1,				0,			'EA_SPELLS_ATLAS'	);

--Both Arcane and Divine
INSERT INTO EaActions (Type,			SpellClass,	GPModType1,				TechReq,						City,	AITarget,			AICombatRole,	FallenAltSpell,					TurnsToComplete,	FixedFaith,	HumanVisibleFX,	IconIndex,	IconAtlas			) VALUES
('EA_SPELL_SUMMON_ABYSSAL_CREATURES',	'Both',		'EAMOD_CONJURATION',	'TECH_SORCERY',					NULL,	'SelfAndTower',		NULL,			'IsFallen',						3,					0,			1,				1,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_SUMMON_DEMON',				'Both',		'EAMOD_CONJURATION',	'TECH_SUMMONING',				NULL,	'SelfAndTower',		NULL,			'IsFallen',						3,					0,			1,				1,			'EA_SPELLS_ATLAS'	);


--Divine
INSERT INTO EaActions (Type,			SpellClass,	GPModType1,				TechReq,						City,	AITarget,			AICombatRole,	FallenAltSpell,					TurnsToComplete,	FixedFaith,	HumanVisibleFX,	IconIndex,	IconAtlas			) VALUES
('EA_SPELL_HEAL',						'Divine',	'EAMOD_NECROMANCY',		NULL,							NULL,	NULL,				'Any',			'EA_SPELL_HURT',				1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_BLESS',						'Divine',	'EAMOD_CONJURATION',	'TECH_DIVINE_LITURGY',			NULL,	NULL,				'Any',			'EA_SPELL_CURSE',				1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_PROTECTION_FROM_EVIL',		'Divine',	'EAMOD_ABJURATION',		'TECH_DIVINE_LITURGY',			NULL,	NULL,				'Any',			'EA_SPELL_EVIL_EYE',			1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_SANCTIFY',					'Divine',	'EAMOD_ABJURATION',		'TECH_DIVINE_VITALISM',			NULL,	NULL,				NULL,			'EA_SPELL_DEFILE',				1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_MASS_HEAL',					'Divine',	'EAMOD_NECROMANCY',		'TECH_DIVINE_VITALISM',			NULL,	NULL,				NULL,			'EA_SPELL_MASS_HURT',			1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CURE_DISEASE',				'Divine',	'EAMOD_NECROMANCY',		'TECH_DIVINE_VITALISM',			NULL,	NULL,				NULL,			'EA_SPELL_CAUSE_DISEASE',		1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CURE_PLAGUE',				'Divine',	'EAMOD_NECROMANCY',		'TECH_DIVINE_ESSENCE',			NULL,	NULL,				NULL,			'EA_SPELL_CAUSE_PLAGUE',		1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_COMMAND',					'Divine',	'EAMOD_ENCHANTMENT',	'TECH_DIVINE_ESSENCE',			NULL,	NULL,				NULL,			NULL,							1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_BANISH_UNDEAD',				'Divine',	'EAMOD_ABJURATION',		'TECH_HEAVENLY_CYCLES',			NULL,	NULL,				NULL,			'EA_SPELL_TURN_UNDEAD',			1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CONSECRATE',					'Divine',	'EAMOD_EVOCATION',		'TECH_HEAVENLY_CYCLES',			NULL,	NULL,				NULL,			'EA_SPELL_DESECRATE',			1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CALL_HEAVENS_GUARD',			'Divine',	'EAMOD_CONJURATION',	'TECH_HEAVENLY_CYCLES',			NULL,	'SelfAndTower',		NULL,			'EA_SPELL_SUMMON_ABYSSAL_CREATURES', 3,				0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CALL_ANGEL',					'Divine',	'EAMOD_CONJURATION',	'TECH_CELESTIAL_KNOWLEDGE',		NULL,	'SelfAndTower',		NULL,			'EA_SPELL_SUMMON_DEMON',		3,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_RESURRECTION',				'Divine',	'EAMOD_NECROMANCY',		'TECH_DIVINE_INTERVENTION',		NULL,	NULL,				NULL,			'EA_SPELL_GREATER_REANIMATION',	1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),

--fallen
('EA_SPELL_HURT',						'Divine',	'EAMOD_NECROMANCY',		NULL,							NULL,	NULL,				'Any',			'IsFallen',						1,					0,			1,				1,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CURSE',						'Divine',	'EAMOD_CONJURATION',	'TECH_MALEFICIUM',				NULL,	NULL,				'Any',			'IsFallen',						1,					0,			1,				1,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_EVIL_EYE',					'Divine',	'EAMOD_NECROMANCY',		'TECH_MALEFICIUM',				NULL,	NULL,				'Any',			'IsFallen',						1,					0,			1,				1,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_DEFILE',						'Divine',	'EAMOD_TRANSMUTATION',	'TECH_REANIMATION',				NULL,	NULL,				NULL,			'IsFallen',						1,					0,			1,				1,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_MASS_HURT',					'Divine',	'EAMOD_NECROMANCY',		'TECH_SORCERY',					NULL,	NULL,				NULL,			'IsFallen',						1,					0,			1,				1,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CAUSE_DISEASE',				'Divine',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				NULL,	NULL,				NULL,			'IsFallen',						1,					0,			1,				1,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CAUSE_PLAGUE',				'Divine',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				NULL,	NULL,				NULL,			'IsFallen',						1,					0,			1,				1,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_TURN_UNDEAD',				'Divine',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				NULL,	NULL,				NULL,			'IsFallen',						1,					0,			1,				1,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_DESECRATE',					'Divine',	'EAMOD_TRANSMUTATION',	'TECH_SUMMONING',				NULL,	NULL,				NULL,			'IsFallen',						1,					0,			1,				1,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_GREATER_REANIMATION',		'Divine',	'EAMOD_NECROMANCY',		'TECH_SOUL_BINDING',			NULL,	NULL,				NULL,			'IsFallen',						1,					0,			1,				1,			'EA_SPELLS_ATLAS'	);

--pantheism
INSERT INTO EaActions (Type,			SpellClass,	GPModType1,				PolicyReq,						City,	AITarget,			AICombatRole,	FallenAltSpell,					TurnsToComplete,	FixedFaith,	HumanVisibleFX,	IconIndex,	IconAtlas			) VALUES
('EA_SPELL_EAS_BLESSING',				'Divine',	'EAMOD_TRANSMUTATION',	'POLICY_WOODS_LORE',			'Not',	'NearbyLivTerrain',	NULL,			NULL,							3,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CALL_ANIMALS',				'Divine',	'EAMOD_CONJURATION',	'POLICY_FERAL_BOND',			'Not',	'SelfAndTower',		NULL,			NULL,							3,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_CALL_TREE_ENTS',				'Divine',	'EAMOD_CONJURATION',	'POLICY_FOREST_DOMINION',		'Not',	'SelfAndTower',		NULL,			NULL,							3,					0,			1,				2,			'EA_SPELLS_ATLAS'	);

--druid cult spells (learned from ritual)
INSERT INTO EaActions (Type,			SpellClass,	GPModType1,				PantheismCult,					City,	AITarget,			AICombatRole,		TurnsToComplete,	FixedFaith,	HumanVisibleFX,	IconIndex,	IconAtlas			) VALUES
('EA_SPELL_BLOOM',						'Divine',	'EAMOD_TRANSMUTATION',	'RELIGION_CULT_OF_LEAVES',		'Not',	'NearbyNonFeature',	NULL,				5,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_RIDE_LIKE_THE_WIND',			'Divine',	'EAMOD_CONJURATION',	'RELIGION_CULT_OF_EPONA',		NULL,	NULL,				'Any',				1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_PURIFY',						'Divine',	'EAMOD_CONJURATION',	'RELIGION_CULT_OF_ABZU',	NULL,	NULL,				'Any',				1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_FAIR_WINDS',					'Divine',	'EAMOD_CONJURATION',	'RELIGION_CULT_OF_AEGIR',		NULL,	'OwnNavalUnits',	NULL,				1,					0,			1,				2,			'EA_SPELLS_ATLAS'	),
('EA_SPELL_REVELRY',					'Divine',	'EAMOD_CONJURATION',	'RELIGION_CULT_OF_BAKKHEIA',	'Own',	'OwnClosestCity',	NULL,				1000,				0,			1,				2,			'EA_SPELLS_ATLAS'	);


--Build out the table for dependent strings
UPDATE EaActions SET Description = 'TXT_KEY_' || Type, Help = 'TXT_KEY_' || Type || '_HELP' WHERE SpellClass IS NOT NULL;
UPDATE EaActions SET GPOnly = 1, ConsiderTowerTemple = 1, UIType = 'Spell' WHERE SpellClass IS NOT NULL;
UPDATE EaActions SET ProgressHolder = 'Person' WHERE Type GLOB 'EA_SPELL_*' AND TurnsToComplete > 1;


UPDATE EaActions SET PolicyTrumpsTechReq = 'POLICY_WITCHCRAFT' WHERE Type IN ('EA_SPELL_SCRYING', 'EA_SPELL_SLOW', 'EA_SPELL_HEX', 'EA_SPELL_DEATH_STAY', 'EA_SPELL_SLEEP');
UPDATE EaActions SET GPModType2 = 'EAMOD_DEVOTION' WHERE SpellClass IN ('Divine', 'Both');

UPDATE EaActions SET FreeSpellSubclass = 'Priest' WHERE Type = 'EA_SPELL_HEAL';
UPDATE EaActions SET FreeSpellSubclass = 'FallenPriest' WHERE Type = 'EA_SPELL_HURT';


UPDATE EaActions SET ProgressHolder = 'Person' WHERE ProgressHolder IS NULL AND TurnsToComplete > 1;		--needs to be something

-----------------------------------------------------------------------------------------
-- DEBUG
-----------------------------------------------------------------------------------------
--UPDATE EaActions SET TechReq = NULL;
--UPDATE EaActions SET AndTechReq = NULL;
--UPDATE EaActions SET PolicyReq = NULL;
--UPDATE EaActions SET PantheismCult = NULL;
--UPDATE EaActions SET TechReq = NULL WHERE Type = 'EA_ACTION_TRADE_ROUTE';
--UPDATE EaActions SET BuildingReq = NULL, AITarget = 'OwnClosestCity' WHERE Type GLOB 'EA_ACTION_TOME_*';

--AutoplayDebug
--UPDATE EaActions SET TechReq = 'TECH_NEVER' WHERE Type IN ('EA_ACTION_PROSELYTIZE', 'EA_ACTION_ANTIPROSELYTIZE', 'EA_ACTION_PROPHECY_MITHRA',
--'EA_ACTION_PROPHECY_MA', 'EA_ACTION_PROPHECY_VA', 'EA_ACTION_PROPHECY_ANRA', 'EA_ACTION_PROPHECY_AESHEMA', 'EA_ACTION_WORSHIP');

-----------------------------------------------------------------------------------------
-- Subtables
-----------------------------------------------------------------------------------------




INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaActions.sql';