-- Contains UnitClasses, Units, and all Units subtables; tables defined in base

-- Notes: Racial versions are given their own unitclasses. This is so that units maintain race regardless of owner.
-- The UnitClasses table is constructed entirely from the Units table

DELETE FROM Units WHERE Type NOT IN ('UNIT_MISSIONARY', 'UNIT_CARAVAN', 'UNIT_CARGO_SHIP');					--Missionary needed to prevent CTD after religion enhancement
UPDATE Units SET ID = 0, FaithCost = 999999 WHERE Type = 'UNIT_MISSIONARY';			--we also use it to detect errors in unit initing, since you get the id=0 unit if unitTypeID is nil

ALTER TABLE Units ADD COLUMN 'IsWorker' BOOLEAN DEFAULT NULL;
ALTER TABLE Units ADD COLUMN 'EaRace' TEXT DEFAULT NULL;
ALTER TABLE Units ADD COLUMN 'EaCityTrainRace' TEXT DEFAULT NULL;
ALTER TABLE Units ADD COLUMN 'EaSpecialWorker' TEXT DEFAULT NULL;
ALTER TABLE Units ADD COLUMN 'EaLiving' BOOLEAN DEFAULT NULL;
ALTER TABLE Units ADD COLUMN 'EaNoTrain' BOOLEAN DEFAULT NULL;
ALTER TABLE Units ADD COLUMN 'EaGPTempRole' TEXT DEFAULT NULL;
ALTER TABLE Units ADD COLUMN 'EaSpecial' TEXT DEFAULT NULL;			--Animal, Beast, Undead, Demon, Angel, Utility

----------------------------------------------------------------------------------------
-- Normal units (UnitClasses & Units)
----------------------------------------------------------------------------------------

--UNITCOMBAT_GUN for mounted ranged?


-- Non-race & currently generic
INSERT INTO Units (Type,		PrereqTech,					Cost,	Combat,	RangedCombat,	Range,	Moves,	CombatClass,				Domain,			DefaultUnitAI,			Pillage,	MilitarySupport,	MilitaryProduction,	ObsoleteTech,		Mechanized,	UnitArtInfo,							IconAtlas,					PortraitIndex,	UnitFlagAtlas,					UnitFlagIconOffset,	MoveRate		) VALUES
('UNIT_FISHING_BOATS',			'TECH_FISHING',				80,		0,		0,				0,		0,		NULL,						'DOMAIN_AIR',	'UNITAI_WORKER_SEA',	0,			0,					0,					NULL,				1,			'ART_DEF_UNIT_WORKBOAT',				'UNIT_ATLAS_1',				2,				'UNIT_FLAG_ATLAS',				2,					'WOODEN_BOAT'	),
('UNIT_WHALING_BOATS',			'TECH_HARPOONS',			80,		0,		0,				0,		0,		NULL,						'DOMAIN_AIR',	'UNITAI_WORKER_SEA',	0,			0,					0,					NULL,				1,			'ART_DEF_UNIT_WORKBOAT',				'UNIT_ATLAS_1',				2,				'UNIT_FLAG_ATLAS',				2,					'WOODEN_BOAT'	),
('UNIT_HUNTERS',				'TECH_HUNTING',				80,		0,		0,				0,		0,		NULL,						'DOMAIN_AIR',	'UNITAI_WORKER',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT_SCOUT',					'UNIT_ATLAS_1',				5,				'UNIT_FLAG_ATLAS',				5,					'BIPED'			),
('UNIT_SETTLERS_MINOR',			'TECH_NEVER',				0,		0,		0,				0,		2,		NULL,						'DOMAIN_LAND',	'UNITAI_SETTLE',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT__SETTLER',				'UNIT_ATLAS_1',				0,				'UNIT_FLAG_ATLAS',				0,					'BIPED'			),

--('UNIT_CARAVAN',				'TECH_CURRENCY',			100,	0,		0,				0,		1,		NULL,						'DOMAIN_LAND',	'UNITAI_WORKER',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT_CARAVAN',					'EXPANSION2_UNIT_ATLAS',	3,				'EXPANSION2_UNIT_FLAG_ATLAS',	3,					'BIPED'			),
--('UNIT_CARGO_SHIP',				'TECH_SAILING',				100,	0,		0,				0,		1,		NULL,						'DOMAIN_SEA',	'UNITAI_WORKER',		0,			0,					0,					NULL,				1,			'ART_DEF_UNIT_CARGO_SHIP',				'EXPANSION2_UNIT_ATLAS',	4,				'EXPANSION2_UNIT_FLAG_ATLAS',	4,					'BIPED'			),

('UNIT_BIREMES',				'TECH_SAILING',				180,	9,		0,				0,		3,		'UNITCOMBAT_NAVALMELEE',	'DOMAIN_SEA',	'UNITAI_ATTACK_SEA',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_TRIREME',					'UNIT_ATLAS_1',				24,				'UNIT_FLAG_ATLAS',				24,					'WOODEN_BOAT'	),
('UNIT_TRIREMES',				'TECH_SHIP_BUILDING',		240,	12,		0,				0,		3,		'UNITCOMBAT_NAVALMELEE',	'DOMAIN_SEA',	'UNITAI_ATTACK_SEA',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_TRIREME',					'UNIT_ATLAS_1',				24,				'UNIT_FLAG_ATLAS',				24,					'WOODEN_BOAT'	),
('UNIT_QUINQUEREMES',			'TECH_SHIP_BUILDING',		300,	15,		0,				0,		3,		'UNITCOMBAT_NAVALMELEE',	'DOMAIN_SEA',	'UNITAI_ATTACK_SEA',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_U_CARTHAGE_QUINQUEREME',	'EXPANSION_UNIT_ATLAS_1',	11,				'EXPANSION_UNIT_FLAG_ATLAS',	11,					'WOODEN_BOAT'	),
('UNIT_CARAVELS',				'TECH_ASTRONOMY',			200,	10,		0,				0,		5,		'UNITCOMBAT_NAVALMELEE',	'DOMAIN_SEA',	'UNITAI_ATTACK_SEA',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_CARAVEL',					'UNIT_ATLAS_1',				43,				'UNIT_FLAG_ATLAS',				42,					'BOAT'			),

('UNIT_DROMONS',				'TECH_NAVIGATION',			240,	12,		12,				2,		4,		'UNITCOMBAT_NAVALRANGED',	'DOMAIN_SEA',	'UNITAI_ATTACK_SEA',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_U_BYZANTIUM_DROMON',		'EXPANSION_UNIT_ATLAS_1',	5,				'EXPANSION_UNIT_FLAG_ATLAS',	5,					'WOODEN_BOAT'	),
('UNIT_CARRACKS',				'TECH_NAVAL_ENGINEERING',	300,	15,		15,				2,		4,		'UNITCOMBAT_NAVALRANGED',	'DOMAIN_SEA',	'UNITAI_ATTACK_SEA',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_TRIREME',					'UNIT_ATLAS_1',				24,				'UNIT_FLAG_ATLAS',				24,					'WOODEN_BOAT'	),
('UNIT_GALLEONS',				'TECH_ADV_NAVAL_ENGINEERING',360,	18,		18,				2,		4,		'UNITCOMBAT_NAVALRANGED',	'DOMAIN_SEA',	'UNITAI_ATTACK_SEA',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_FRIGATE',					'UNIT_ATLAS_2',				8,				'UNIT_FLAG_ATLAS',				51,					'WOODEN_BOAT'	),
('UNIT_IRONCLADS',				'TECH_STEAM_POWER',			360,	18,		18,				2,		2,		'UNITCOMBAT_NAVALRANGED',	'DOMAIN_SEA',	'UNITAI_ATTACK_SEA',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_IRONCLAD',				'UNIT_ATLAS_2',				10,				'UNIT_FLAG_ATLAS',				53,					'BOAT'			),

('UNIT_BALLISTAE',				'TECH_ARCHERY',				200,	8,		10,				2,		2,		'UNITCOMBAT_SIEGE',			'DOMAIN_LAND',	'UNITAI_CITY_BOMBARD',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_U_ROMAN_BALLISTA',		'UNIT_ATLAS_2',				22,				'UNIT_FLAG_ATLAS',				22,					'ARTILLERY'		),
('UNIT_CATAPULTS',				'TECH_MATHEMATICS',			180,	6,		9,				2,		2,		'UNITCOMBAT_SIEGE',			'DOMAIN_LAND',	'UNITAI_CITY_BOMBARD',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_CATAPULT',				'UNIT_ATLAS_1',				21,				'UNIT_FLAG_ATLAS',				21,					'ARTILLERY'		),
('UNIT_TREBUCHETS',				'TECH_MECHANICS',			240,	9,		12,				2,		2,		'UNITCOMBAT_SIEGE',			'DOMAIN_LAND',	'UNITAI_CITY_BOMBARD',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_TREBUCHET',				'UNIT_ATLAS_1',				42,				'UNIT_FLAG_ATLAS',				41,					'ARTILLERY'		),
('UNIT_FIRE_CATAPULTS',			'TECH_MATHEMATICS',			220,	8,		11,				2,		2,		'UNITCOMBAT_SIEGE',			'DOMAIN_LAND',	'UNITAI_CITY_BOMBARD',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_CATAPULT',				'UNIT_ATLAS_1',				21,				'UNIT_FLAG_ATLAS',				21,					'ARTILLERY'		),
('UNIT_FIRE_TREBUCHETS',		'TECH_MECHANICS',			280,	11,		14,				2,		2,		'UNITCOMBAT_SIEGE',			'DOMAIN_LAND',	'UNITAI_CITY_BOMBARD',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_TREBUCHET',				'UNIT_ATLAS_1',				42,				'UNIT_FLAG_ATLAS',				41,					'ARTILLERY'		),
('UNIT_BOMBARDS',				'TECH_IRON_WORKING',		300,	12,		15,				2,		2,		'UNITCOMBAT_SIEGE',			'DOMAIN_LAND',	'UNITAI_CITY_BOMBARD',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_CANNON',					'UNIT_ATLAS_2',				0,				'UNIT_FLAG_ATLAS',				43,					'ARTILLERY'		),
('UNIT_GREAT_BOMBARDE',			'TECH_METAL_CASTING',		300,	9,		15,				2,		1,		'UNITCOMBAT_SIEGE',			'DOMAIN_LAND',	'UNITAI_CITY_BOMBARD',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_CANNON',					'UNIT_ATLAS_2',				0,				'UNIT_FLAG_ATLAS',				43,					'ARTILLERY'		),

('UNIT_MOUNTED_ELEPHANTS',		'TECH_ELEPHANT_TRAINING',	320,	15,		15,				1,		2,		'UNITCOMBAT_ARMOR',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_SIAMESE_WARELEPHANT',	'UNIT_ATLAS_1',				29,				'UNIT_FLAG_ATLAS',				28,					'PHANT'			),
('UNIT_WAR_ELEPHANTS',			'TECH_WAR_ELEPHANTS',		380,	18,		18,				1,		2,		'UNITCOMBAT_ARMOR',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_SIAMESE_WARELEPHANT',	'UNIT_ATLAS_1',				29,				'UNIT_FLAG_ATLAS',				28,					'PHANT'			),
('UNIT_MUMAKIL',				'TECH_MUMAKIL_RIDING',		500,	24,		24,				1,		2,		'UNITCOMBAT_ARMOR',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_SIAMESE_WARELEPHANT',	'UNIT_ATLAS_1',				29,				'UNIT_FLAG_ATLAS',				28,					'PHANT'			),

-- Man
('UNIT_SETTLERS_MAN',			NULL,						0,		0,		0,				0,		2,		NULL,						'DOMAIN_LAND',	'UNITAI_SETTLE',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT__SETTLER',				'UNIT_ATLAS_1',				0,				'UNIT_FLAG_ATLAS',				0,					'BIPED'			),
('UNIT_WORKERS_MAN',			NULL,						100,	0,		0,				0,		2,		NULL,						'DOMAIN_LAND',	'UNITAI_WORKER',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT__WORKER',					'UNIT_ATLAS_1',				1,				'UNIT_FLAG_ATLAS',				1,					'BIPED'			),
('UNIT_SLAVES_MAN',				NULL,						70,		0,		0,				0,		2,		NULL,						'DOMAIN_LAND',	'UNITAI_WORKER',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT__WORKER',					'UNIT_ATLAS_1',				1,				'UNIT_FLAG_ATLAS',				1,					'BIPED'			),

('UNIT_SCOUTS_MAN',				'TECH_HUNTING',				80,		4,		0,				0,		2,		'UNITCOMBAT_RECON',			'DOMAIN_LAND',	'UNITAI_EXPLORE',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SCOUT',					'UNIT_ATLAS_1',				5,				'UNIT_FLAG_ATLAS',				5,					'BIPED'			),
('UNIT_TRACKERS_MAN',			'TECH_TRACKING_TRAPPING',	160,	8,		0,				0,		2,		'UNITCOMBAT_RECON',			'DOMAIN_LAND',	'UNITAI_EXPLORE',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SCOUT',					'UNIT_ATLAS_1',				5,				'UNIT_FLAG_ATLAS',				5,					'BIPED'			),
('UNIT_RANGERS_MAN',			'TECH_ANIMAL_MASTERY',		240,	12,		0,				0,		2,		'UNITCOMBAT_RECON',			'DOMAIN_LAND',	'UNITAI_EXPLORE',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SCOUT',					'UNIT_ATLAS_1',				5,				'UNIT_FLAG_ATLAS',				5,					'BIPED'			),

('UNIT_WARRIORS_MAN',			NULL,						120,	6,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT__WARRIOR',				'UNIT_ATLAS_1',				3,				'UNIT_FLAG_ATLAS',				3,					'BIPED'			),
('UNIT_LIGHT_INFANTRY_MAN',		'TECH_BRONZE_WORKING',		180,	9,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SPEARMAN',				'UNIT_ATLAS_1',				9,				'UNIT_FLAG_ATLAS',				9,					'BIPED'			),
('UNIT_MEDIUM_INFANTRY_MAN',	'TECH_IRON_WORKING',		240,	12,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SWORDSMAN',				'UNIT_ATLAS_1',				14,				'UNIT_FLAG_ATLAS',				14,					'HEAVY_BIPED'	),
('UNIT_HEAVY_INFANTRY_MAN',		'TECH_METAL_CASTING',		300,	15,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_ROMAN_LEGION',			'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'HEAVY_BIPED'	),
('UNIT_IMMORTALS_MAN',			'TECH_MITHRIL_WORKING',		420,	21,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_LONGSWORDSMAN',			'UNIT_ATLAS_1',				36,				'UNIT_FLAG_ATLAS',				35,					'BIPED'			),

('UNIT_CHARIOTS_MAN',			NULL,						160,	7,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					'TECH_WAR_HORSES',	1,			'ART_DEF_UNIT_MAN_CHARIOT',				'UNIT_ATLAS_1',				17,				'UNIT_FLAG_ATLAS',				17,					'QUADRUPED'		),
('UNIT_HORSEMEN_MAN',			'TECH_HORSEBACK_RIDING',	200,	9,		0,				0,		4,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					'TECH_WAR_HORSES',	0,			'ART_DEF_UNIT_HORSEMAN',				'UNIT_ATLAS_1',				17,				'UNIT_FLAG_ATLAS',				17,					'QUADRUPED'		),
('UNIT_EQUITES_MAN',			'TECH_STIRRUPS',			260,	12,		0,				0,		4,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_HORSEMAN',				'UNIT_ATLAS_1',				17,				'UNIT_FLAG_ATLAS',				17,					'QUADRUPED'		),
('UNIT_ARMORED_CAVALRY_MAN',	'TECH_STIRRUPS',			280,	13,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					'TECH_WAR_HORSES',	0,			'ART_DEF_UNIT_KNIGHT',					'UNIT_ATLAS_1',				26,				'UNIT_FLAG_ATLAS',				25,					'QUADRUPED'		),
('UNIT_CATAPHRACTS_MAN',		'TECH_WAR_HORSES',			340,	16,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_KNIGHT',					'UNIT_ATLAS_1',				26,				'UNIT_FLAG_ATLAS',				25,					'QUADRUPED'		),
('UNIT_CLIBANARII_MAN',			'TECH_MITHRIL_WORKING',		460,	22,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_KNIGHT',					'UNIT_ATLAS_1',				26,				'UNIT_FLAG_ATLAS',				25,					'QUADRUPED'		),

('UNIT_ARCHERS_MAN',			'TECH_ARCHERY',				180,	8,		8,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_ARCHER',					'UNIT_ATLAS_1',				6,				'UNIT_FLAG_ATLAS',				6,					'BIPED'			),
('UNIT_BOWMEN_MAN',				'TECH_BOWYERS',				260,	12,		12,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_COMPOSITE_BOWMAN',		'EXPANSION_UNIT_ATLAS_1',	13,				'EXPANSION_UNIT_FLAG_ATLAS',	13,					'BIPED'			),
('UNIT_MARKSMEN_MAN',			'TECH_MARKSMANSHIP',		360,	17,		17,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_COMPOSITE_BOWMAN',		'EXPANSION_UNIT_ATLAS_1',	13,				'EXPANSION_UNIT_FLAG_ATLAS',	13,					'BIPED'			),
('UNIT_CROSSBOWMEN_MAN',		'TECH_MECHANICS',			180,	8,		8,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_CROSSBOWMAN',				'UNIT_ATLAS_1',				30,				'UNIT_FLAG_ATLAS',				29,					'BIPED'			),
('UNIT_ARQUEBUSSMEN_MAN',		'TECH_MACHINERY',			320,	15,		15,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_MUSKETMAN',				'UNIT_ATLAS_1',				38,				'UNIT_FLAG_ATLAS',				37,					'BIPED'			),

('UNIT_CHARIOT_ARCHERS_MAN',	'TECH_ARCHERY',				160,	7,		7,				1,		3,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_CHARIOT_ARCHER',			'UNIT_ATLAS_1',				12,				'UNIT_FLAG_ATLAS',				12,					'WHEELED'		),
('UNIT_HORSE_ARCHERS_MAN',		'TECH_HORSEBACK_RIDING',	200,	9,		9,				1,		4,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_MONGOLIAN_KESHIK',		'GENGHIS_UNIT_ATLAS',		0,				'GENGHIS_UNIT_FLAG_ATLAS',		0,					'BIPED'			),
('UNIT_BOWED_CAVALRY_MAN',		'TECH_STIRRUPS',			260,	12,		12,				1,		4,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_MONGOLIAN_KESHIK',		'GENGHIS_UNIT_ATLAS',		0,				'GENGHIS_UNIT_FLAG_ATLAS',		0,					'BIPED'			),
('UNIT_SAGITARII_MAN',			'TECH_WAR_HORSES',			260,	12,		12,				1,		4,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_MONGOLIAN_KESHIK',		'GENGHIS_UNIT_ATLAS',		0,				'GENGHIS_UNIT_FLAG_ATLAS',		0,					'BIPED'			),

-- Sidhe
('UNIT_SETTLERS_SIDHE',			NULL,						0,		0,		0,				0,		2,		NULL,						'DOMAIN_LAND',	'UNITAI_SETTLE',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT__SETTLER',				'UNIT_ATLAS_1',				0,				'UNIT_FLAG_ATLAS',				0,					'BIPED'			),
('UNIT_WORKERS_SIDHE',			NULL,						100,	0,		0,				0,		2,		NULL,						'DOMAIN_LAND',	'UNITAI_WORKER',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT__WORKER',					'UNIT_ATLAS_1',				1,				'UNIT_FLAG_ATLAS',				1,					'BIPED'			),
('UNIT_SLAVES_SIDHE',			NULL,						70,		0,		0,				0,		2,		NULL,						'DOMAIN_LAND',	'UNITAI_WORKER',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT__WORKER',					'UNIT_ATLAS_1',				1,				'UNIT_FLAG_ATLAS',				1,					'BIPED'			),

('UNIT_SCOUTS_SIDHE',			'TECH_HUNTING',				80,		4,		0,				0,		2,		'UNITCOMBAT_RECON',			'DOMAIN_LAND',	'UNITAI_EXPLORE',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SCOUT',					'UNIT_ATLAS_1',				5,				'UNIT_FLAG_ATLAS',				5,					'BIPED'			),
('UNIT_TRACKERS_SIDHE',			'TECH_TRACKING_TRAPPING',	160,	8,		0,				0,		2,		'UNITCOMBAT_RECON',			'DOMAIN_LAND',	'UNITAI_EXPLORE',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SCOUT',					'UNIT_ATLAS_1',				5,				'UNIT_FLAG_ATLAS',				5,					'BIPED'			),
('UNIT_RANGERS_SIDHE',			'TECH_ANIMAL_MASTERY',		240,	12,		0,				0,		2,		'UNITCOMBAT_RECON',			'DOMAIN_LAND',	'UNITAI_EXPLORE',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SCOUT',					'UNIT_ATLAS_1',				5,				'UNIT_FLAG_ATLAS',				5,					'BIPED'			),

('UNIT_WARRIORS_SIDHE',			NULL,						120,	6,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT__WARRIOR',				'UNIT_ATLAS_1',				3,				'UNIT_FLAG_ATLAS',				3,					'BIPED'			),
('UNIT_LIGHT_INFANTRY_SIDHE',	'TECH_BRONZE_WORKING',		180,	9,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SPEARMAN',				'UNIT_ATLAS_1',				9,				'UNIT_FLAG_ATLAS',				9,					'BIPED'			),
('UNIT_MEDIUM_INFANTRY_SIDHE',	'TECH_IRON_WORKING',		240,	12,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SWORDSMAN',				'UNIT_ATLAS_1',				14,				'UNIT_FLAG_ATLAS',				14,					'HEAVY_BIPED'	),
('UNIT_HEAVY_INFANTRY_SIDHE',	'TECH_METAL_CASTING',		300,	15,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_ROMAN_LEGION',			'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'HEAVY_BIPED'	),
('UNIT_IMMORTALS_SIDHE',		'TECH_MITHRIL_WORKING',		420,	21,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_LONGSWORDSMAN',			'UNIT_ATLAS_1',				36,				'UNIT_FLAG_ATLAS',				35,					'BIPED'			),

('UNIT_CHARIOTS_SIDHE',			NULL,						160,	7,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					'TECH_WAR_HORSES',	1,			'ART_DEF_UNIT_MAN_CHARIOT',				'UNIT_ATLAS_1',				17,				'UNIT_FLAG_ATLAS',				17,					'QUADRUPED'		),
('UNIT_HORSEMEN_SIDHE',			'TECH_HORSEBACK_RIDING',	200,	9,		0,				0,		4,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					'TECH_WAR_HORSES',	0,			'ART_DEF_UNIT_HORSEMAN',				'UNIT_ATLAS_1',				17,				'UNIT_FLAG_ATLAS',				17,					'QUADRUPED'		),
('UNIT_EQUITES_SIDHE',			'TECH_STIRRUPS',			260,	12,		0,				0,		4,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_HORSEMAN',				'UNIT_ATLAS_1',				17,				'UNIT_FLAG_ATLAS',				17,					'QUADRUPED'		),
('UNIT_ARMORED_CAVALRY_SIDHE',	'TECH_STIRRUPS',			280,	13,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					'TECH_WAR_HORSES',	0,			'ART_DEF_UNIT_KNIGHT',					'UNIT_ATLAS_1',				26,				'UNIT_FLAG_ATLAS',				25,					'QUADRUPED'		),
('UNIT_CATAPHRACTS_SIDHE',		'TECH_WAR_HORSES',			340,	16,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_KNIGHT',					'UNIT_ATLAS_1',				26,				'UNIT_FLAG_ATLAS',				25,					'QUADRUPED'		),
('UNIT_CLIBANARII_SIDHE',		'TECH_MITHRIL_WORKING',		460,	22,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_KNIGHT',					'UNIT_ATLAS_1',				26,				'UNIT_FLAG_ATLAS',				25,					'QUADRUPED'		),

('UNIT_ARCHERS_SIDHE',			'TECH_ARCHERY',				180,	8,		8,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_ARCHER',					'UNIT_ATLAS_1',				6,				'UNIT_FLAG_ATLAS',				6,					'BIPED'			),
('UNIT_BOWMEN_SIDHE',			'TECH_BOWYERS',				260,	12,		12,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_COMPOSITE_BOWMAN',		'EXPANSION_UNIT_ATLAS_1',	13,				'EXPANSION_UNIT_FLAG_ATLAS',	13,					'BIPED'			),
('UNIT_MARKSMEN_SIDHE',			'TECH_MARKSMANSHIP',		360,	17,		17,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_COMPOSITE_BOWMAN',		'EXPANSION_UNIT_ATLAS_1',	13,				'EXPANSION_UNIT_FLAG_ATLAS',	13,					'BIPED'			),
('UNIT_CROSSBOWMEN_SIDHE',		'TECH_MECHANICS',			180,	8,		8,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_CROSSBOWMAN',				'UNIT_ATLAS_1',				30,				'UNIT_FLAG_ATLAS',				29,					'BIPED'			),
('UNIT_ARQUEBUSSMEN_SIDHE',		'TECH_MACHINERY',			320,	15,		15,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_MUSKETMAN',				'UNIT_ATLAS_1',				38,				'UNIT_FLAG_ATLAS',				37,					'BIPED'			),

('UNIT_CHARIOT_ARCHERS_SIDHE',	'TECH_ARCHERY',				160,	7,		7,				1,		3,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_CHARIOT_ARCHER',			'UNIT_ATLAS_1',				12,				'UNIT_FLAG_ATLAS',				12,					'WHEELED'		),
('UNIT_HORSE_ARCHERS_SIDHE',	'TECH_HORSEBACK_RIDING',	200,	9,		9,				1,		4,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_MONGOLIAN_KESHIK',		'GENGHIS_UNIT_ATLAS',		0,				'GENGHIS_UNIT_FLAG_ATLAS',		0,					'BIPED'			),
('UNIT_BOWED_CAVALRY_SIDHE',	'TECH_STIRRUPS',			260,	12,		12,				1,		4,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_MONGOLIAN_KESHIK',		'GENGHIS_UNIT_ATLAS',		0,				'GENGHIS_UNIT_FLAG_ATLAS',		0,					'BIPED'			),
('UNIT_SAGITARII_SIDHE',		'TECH_WAR_HORSES',			260,	12,		12,				1,		4,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_MONGOLIAN_KESHIK',		'GENGHIS_UNIT_ATLAS',		0,				'GENGHIS_UNIT_FLAG_ATLAS',		0,					'BIPED'			),

-- Heldeofol
('UNIT_SETTLERS_ORC',			NULL,						0,		0,		0,				0,		2,		NULL,						'DOMAIN_LAND',	'UNITAI_SETTLE',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT__SETTLER',				'UNIT_ATLAS_1',				0,				'UNIT_FLAG_ATLAS',				0,					'BIPED'			),
('UNIT_WORKERS_ORC',			NULL,						100,	0,		0,				0,		2,		NULL,						'DOMAIN_LAND',	'UNITAI_WORKER',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT__WORKER',					'UNIT_ATLAS_1',				1,				'UNIT_FLAG_ATLAS',				1,					'BIPED'			),
('UNIT_SLAVES_ORC',				NULL,						70,		0,		0,				0,		2,		NULL,						'DOMAIN_LAND',	'UNITAI_WORKER',		0,			0,					0,					NULL,				0,			'ART_DEF_UNIT__WORKER',					'UNIT_ATLAS_1',				1,				'UNIT_FLAG_ATLAS',				1,					'BIPED'			),

('UNIT_SCOUTS_ORC',				'TECH_HUNTING',				80,		4,		0,				0,		2,		'UNITCOMBAT_RECON',			'DOMAIN_LAND',	'UNITAI_EXPLORE',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SCOUT',					'UNIT_ATLAS_1',				5,				'UNIT_FLAG_ATLAS',				5,					'BIPED'			),
('UNIT_TRACKERS_ORC',			'TECH_TRACKING_TRAPPING',	160,	8,		0,				0,		2,		'UNITCOMBAT_RECON',			'DOMAIN_LAND',	'UNITAI_EXPLORE',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SCOUT',					'UNIT_ATLAS_1',				5,				'UNIT_FLAG_ATLAS',				5,					'BIPED'			),
('UNIT_RANGERS_ORC',			'TECH_ANIMAL_MASTERY',		240,	12,		0,				0,		2,		'UNITCOMBAT_RECON',			'DOMAIN_LAND',	'UNITAI_EXPLORE',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SCOUT',					'UNIT_ATLAS_1',				5,				'UNIT_FLAG_ATLAS',				5,					'BIPED'			),

('UNIT_WARRIORS_ORC',			NULL,						120,	6,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_ORC_SPEARMAN',			'UNIT_ATLAS_1',				3,				'UNIT_FLAG_ATLAS',				3,					'BIPED'			),
('UNIT_LIGHT_INFANTRY_ORC',		'TECH_BRONZE_WORKING',		180,	9,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SPEARMAN',				'UNIT_ATLAS_1',				9,				'UNIT_FLAG_ATLAS',				9,					'BIPED'			),
('UNIT_MEDIUM_INFANTRY_ORC',	'TECH_IRON_WORKING',		240,	12,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_SWORDSMAN',				'UNIT_ATLAS_1',				14,				'UNIT_FLAG_ATLAS',				14,					'HEAVY_BIPED'	),
('UNIT_HEAVY_INFANTRY_ORC',		'TECH_METAL_CASTING',		300,	15,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_ROMAN_LEGION',			'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'HEAVY_BIPED'	),
('UNIT_IMMORTALS_ORC',			'TECH_MITHRIL_WORKING',		420,	21,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_LONGSWORDSMAN',			'UNIT_ATLAS_1',				36,				'UNIT_FLAG_ATLAS',				35,					'BIPED'			),
--note: will remove horse units later
('UNIT_CHARIOTS_ORC',			NULL,						160,	7,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					'TECH_WAR_HORSES',	1,			'ART_DEF_UNIT_MAN_CHARIOT',				'UNIT_ATLAS_1',				17,				'UNIT_FLAG_ATLAS',				17,					'QUADRUPED'		),
('UNIT_HORSEMEN_ORC',			'TECH_HORSEBACK_RIDING',	200,	9,		0,				0,		4,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					'TECH_WAR_HORSES',	0,			'ART_DEF_UNIT_HORSEMAN',				'UNIT_ATLAS_1',				17,				'UNIT_FLAG_ATLAS',				17,					'QUADRUPED'		),
('UNIT_EQUITES_ORC',			'TECH_STIRRUPS',			260,	12,		0,				0,		4,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_HORSEMAN',				'UNIT_ATLAS_1',				17,				'UNIT_FLAG_ATLAS',				17,					'QUADRUPED'		),
('UNIT_ARMORED_CAVALRY_ORC',	'TECH_STIRRUPS',			280,	13,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					'TECH_WAR_HORSES',	0,			'ART_DEF_UNIT_KNIGHT',					'UNIT_ATLAS_1',				26,				'UNIT_FLAG_ATLAS',				25,					'QUADRUPED'		),
('UNIT_CATAPHRACTS_ORC',		'TECH_WAR_HORSES',			340,	16,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_KNIGHT',					'UNIT_ATLAS_1',				26,				'UNIT_FLAG_ATLAS',				25,					'QUADRUPED'		),
('UNIT_CLIBANARII_ORC',			'TECH_MITHRIL_WORKING',		460,	22,		0,				0,		3,		'UNITCOMBAT_MOUNTED',		'DOMAIN_LAND',	'UNITAI_FAST_ATTACK',	1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_KNIGHT',					'UNIT_ATLAS_1',				26,				'UNIT_FLAG_ATLAS',				25,					'QUADRUPED'		),

('UNIT_ARCHERS_ORC',			'TECH_ARCHERY',				180,	8,		8,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_ARCHER',					'UNIT_ATLAS_1',				6,				'UNIT_FLAG_ATLAS',				6,					'BIPED'			),
('UNIT_BOWMEN_ORC',				'TECH_BOWYERS',				260,	12,		12,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_COMPOSITE_BOWMAN',		'EXPANSION_UNIT_ATLAS_1',	13,				'EXPANSION_UNIT_FLAG_ATLAS',	13,					'BIPED'			),
('UNIT_MARKSMEN_ORC',			'TECH_MARKSMANSHIP',		360,	17,		17,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_COMPOSITE_BOWMAN',		'EXPANSION_UNIT_ATLAS_1',	13,				'EXPANSION_UNIT_FLAG_ATLAS',	13,					'BIPED'			),
('UNIT_CROSSBOWMEN_ORC',		'TECH_MECHANICS',			180,	8,		8,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_CROSSBOWMAN',				'UNIT_ATLAS_1',				30,				'UNIT_FLAG_ATLAS',				29,					'BIPED'			),
('UNIT_ARQUEBUSSMEN_ORC',		'TECH_MACHINERY',			320,	15,		15,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_MUSKETMAN',				'UNIT_ATLAS_1',				38,				'UNIT_FLAG_ATLAS',				37,					'BIPED'			),

('UNIT_CHARIOT_ARCHERS_ORC',	'TECH_ARCHERY',				160,	7,		7,				1,		3,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_CHARIOT_ARCHER',			'UNIT_ATLAS_1',				12,				'UNIT_FLAG_ATLAS',				12,					'WHEELED'		),
('UNIT_HORSE_ARCHERS_ORC',		'TECH_HORSEBACK_RIDING',	200,	9,		9,				1,		4,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_MONGOLIAN_KESHIK',		'GENGHIS_UNIT_ATLAS',		0,				'GENGHIS_UNIT_FLAG_ATLAS',		0,					'BIPED'			),
('UNIT_BOWED_CAVALRY_ORC',		'TECH_STIRRUPS',			260,	12,		12,				1,		4,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_MONGOLIAN_KESHIK',		'GENGHIS_UNIT_ATLAS',		0,				'GENGHIS_UNIT_FLAG_ATLAS',		0,					'BIPED'			),
('UNIT_SAGITARII_ORC',			'TECH_WAR_HORSES',			260,	12,		12,				1,		4,		'UNITCOMBAT_GUN',			'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_U_MONGOLIAN_KESHIK',		'GENGHIS_UNIT_ATLAS',		0,				'GENGHIS_UNIT_FLAG_ATLAS',		0,					'BIPED'			);

--Barb Only
INSERT INTO Units (Type,		PrereqTech,					Cost,	Combat,	RangedCombat,	Range,	Moves,	CombatClass,				Domain,			DefaultUnitAI,			Pillage,	MilitarySupport,	MilitaryProduction,	ObsoleteTech,		Mechanized,	UnitArtInfo,							IconAtlas,					PortraitIndex,	UnitFlagAtlas,					UnitFlagIconOffset,	MoveRate,		EaNoTrain	) VALUES
('UNIT_GALLEYS_PIRATES',		NULL,						-1,		9,		0,				0,		3,		'UNITCOMBAT_NAVALMELEE',	'DOMAIN_SEA',	'UNITAI_ATTACK_SEA',	1,			1,					1,					NULL,				1,			'ART_DEF_UNIT_BARBARIAN_GALLEY',		'UNIT_ATLAS_1',				23,				'UNIT_FLAG_ATLAS',				23,					'WOODEN_BOAT',	1			),
('UNIT_WARRIORS_BARB',			NULL,						-1,		7,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_BARBARIAN_EURO',			'UNIT_ATLAS_1',				25,				'UNIT_FLAG_ATLAS',				3,					'BIPED',		1			),
('UNIT_LIGHT_INFANTRY_BARB',	NULL,						-1,		9,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_BARBARIAN_SPEARMAN',		'UNIT_ATLAS_1',				9,				'UNIT_FLAG_ATLAS',				9,					'BIPED',		1			),
('UNIT_MEDIUM_INFANTRY_BARB',	NULL,						-1,		12,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_BARBARIAN_SWORDSMAN',		'UNIT_ATLAS_1',				14,				'UNIT_FLAG_ATLAS',				14,					'HEAVY_BIPED',	1			),
('UNIT_ARCHERS_BARB',			NULL,						-1,		8,		8,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_BARBARIAN_ARCHER',		'UNIT_ATLAS_1',				6,				'UNIT_FLAG_ATLAS',				6,					'BIPED',		1			),
('UNIT_AXMAN_BARB',				NULL,						-1,		8,		8,				1,		2,		'UNITCOMBAT_ARCHER',		'DOMAIN_LAND',	'UNITAI_RANGED',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_HAND_AXE_BARBARIAN',		'EXPANSION2_UNIT_ATLAS',	9,				'EXPANSION2_UNIT_FLAG_ATLAS',	9,					'BIPED',		1			),
('UNIT_OGRES',					NULL,						-1,		15,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_STONESKIN_OGRE',			'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'BIPED',		1			),
('UNIT_HOBGOBLINS',				NULL,						-1,		12,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			1,					1,					NULL,				0,			'ART_DEF_UNIT_OGRE',					'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'BIPED',		1			);

--Animals and Beasts
INSERT INTO Units (Type,		PrereqTech,					Cost,	Combat,	RangedCombat,	Range,	Moves,	CombatClass,				Domain,			DefaultUnitAI,			Pillage,	MilitarySupport,	MilitaryProduction,	ObsoleteTech,		Mechanized,	UnitArtInfo,							IconAtlas,					PortraitIndex,	UnitFlagAtlas,					UnitFlagIconOffset,	MoveRate,		EaNoTrain,	EaSpecial	) VALUES
('UNIT_WOLVES',					NULL,						-1,		6,		0,				0,		4,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		0,			0,					1,					NULL,				0,			'ART_DEF_UNIT_WOLVES',					'UNIT_ATLAS_1',				4,				'UNIT_FLAG_ATLAS',				4,					'BIPED',		1,			'Animal'	),
('UNIT_LIONS',					NULL,						-1,		9,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		0,			0,					1,					NULL,				0,			'ART_DEF_UNIT_LIONS',					'UNIT_ATLAS_1',				4,				'UNIT_FLAG_ATLAS',				4,					'BIPED',		1,			'Animal'	),
('UNIT_GIANT_SPIDER',			NULL,						-1,		9,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		0,			0,					1,					NULL,				0,			'ART_DEF_UNIT_GIANT_SPIDER',			'UNIT_ATLAS_1',				4,				'UNIT_FLAG_ATLAS',				4,					'BIPED',		1,			'Beast'		);

--Summoned, called or raised
INSERT INTO Units (Type,		PrereqTech,					Cost,	Combat,	RangedCombat,	Range,	Moves,	CombatClass,				Domain,			DefaultUnitAI,			Pillage,	MilitarySupport,	MilitaryProduction,	ObsoleteTech,		Mechanized,	UnitArtInfo,							IconAtlas,					PortraitIndex,	UnitFlagAtlas,					UnitFlagIconOffset,	MoveRate,		EaNoTrain,	EaSpecial	) VALUES
('UNIT_TREE_ENT',				NULL,						-1,		15,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			0,					1,					NULL,				0,			'ART_DEF_UNIT_TREE_ENT',				'UNIT_ATLAS_1',				4,				'UNIT_FLAG_ATLAS',				4,					'BIPED',		1,			'Tree'		),
('UNIT_ZOMBIES',				NULL,						-1,		9,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			0,					1,					NULL,				0,			'ART_DEF_UNIT_ZOMBIE',					'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'BIPED',		1,			'Undead'	),
('UNIT_GREAT_UNCLEAN_ONE',		NULL,						-1,		24,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			0,					1,					NULL,				0,			'ART_DEF_UNIT_GREAT_UNCLEAN_ONE',		'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'BIPED',		1,			'Demon'		),
('UNIT_HIVE_TYRANT',			NULL,						-1,		15,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			0,					1,					NULL,				0,			'ART_DEF_UNIT_HIVE_TYRANT',				'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'BIPED',		1,			'Demon'		),
('UNIT_LICTOR',					NULL,						-1,		12,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			0,					1,					NULL,				0,			'ART_DEF_UNIT_LICTOR',					'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'BIPED',		1,			'Demon'		),
('UNIT_HORMAGAUNT',				NULL,						-1,		8,		0,				0,		3,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			0,					1,					NULL,				0,			'ART_DEF_UNIT_HORMAGAUNT',				'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'BIPED',		1,			'Demon'		),
--('UNIT_CARNIFEX',				NULL,						-1,		12,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			0,					1,					NULL,				0,			'ART_DEF_UNIT_CARNIFEX',				'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'BIPED',		1,			'Demon'		),
('UNIT_ANGEL_SPEARMAN',			NULL,						-1,		12,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			0,					1,					NULL,				0,			'ART_DEF_UNIT_ANGEL_SPEARMAN',			'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'BIPED',		1,			'Angel'		),
('UNIT_ANGEL',					NULL,						-1,		18,		0,				0,		2,		'UNITCOMBAT_MELEE',			'DOMAIN_LAND',	'UNITAI_ATTACK',		1,			0,					1,					NULL,				0,			'ART_DEF_UNIT_ANGEL',					'UNIT_ATLAS_1',				15,				'UNIT_FLAG_ATLAS',				15,					'BIPED',		1,			'Angel'		);



--Utility (don't show anywhere)
INSERT INTO Units (Type,		PrereqTech,					Cost,	Combat,	RangedCombat,	NukeDamageLevel,	Range,	Moves,	Immobile,	NoMaintenance,	Special,				CombatClass,	Domain,			DefaultUnitAI,			Suicide,	MilitarySupport,	Mechanized,	AirUnitCap,	CombatLimit,	RangedCombatLimit,	UnitArtInfo,					IconAtlas,			PortraitIndex,	UnitFlagAtlas,		UnitFlagIconOffset,	MoveRate,		EaNoTrain,	EaSpecial	) VALUES
--All dummy air strike units should have Suicide = 1; use RangedCombat = 10 if it will be modified by mod (and not a nuke)
('UNIT_DUMMY_EXPLODER',			'TECH_NEVER',				-1,		0,		10,				-1,					10,		2,		1,			1,				'SPECIALUNIT_MISSILE',	NULL,			'DOMAIN_AIR',	'UNITAI_MISSILE_AIR',	1,			0,					1,			1,			0,				100,				'ART_DEF_UNIT_GUIDED_MISSILE',	'UNIT_ATLAS_2',		30,				'UNIT_FLAG_ATLAS',	77,					'AIR_REBASE',	1,			'Utility'	),
('UNIT_DUMMY_NUKE',				'TECH_NEVER',				-1,		0,		0,				2,					10,		2,		1,			1,				'SPECIALUNIT_MISSILE',	NULL,			'DOMAIN_AIR',	'UNITAI_ICBM',			1,			0,					1,			1,			0,				100,				'ART_DEF_UNIT_NUCLEAR_MISSILE',	'UNIT_ATLAS_2',		30,				'UNIT_FLAG_ATLAS',	77,					'AIR_REBASE',	1,			'Utility'	);
--IMPORTANT! Make sure these get PROMOTION_DUMMY_AIR_STRIKE in Unit_FreePromotions below

UPDATE Units SET IsWorker = 1 WHERE Type GLOB 'UNIT_WORKERS_*' OR Type GLOB 'UNIT_SLAVES_*';
UPDATE Units SET EaRace = 'EARACE_MAN', EaCityTrainRace = 'EARACE_MAN' WHERE Type GLOB '*_MAN' OR Type GLOB '*_BARB';
UPDATE Units SET EaRace = 'EARACE_SIDHE', EaCityTrainRace = 'EARACE_SIDHE' WHERE Type GLOB '*_SIDHE';
UPDATE Units SET EaRace = 'EARACE_ORC', EaCityTrainRace = 'EARACE_HELDEOFOL' WHERE Type GLOB '*_ORC';
UPDATE Units SET EaLiving = 1 WHERE (Mechanized = 0 OR Type GLOB 'UNIT_CHARIOT*') AND (EaSpecial IS NULL OR EaSpecial IN ('Animal', 'Beast'));
UPDATE Units SET NoMaintenance = 1 WHERE Type GLOB 'UNIT_WARRIORS_*' OR Type GLOB 'UNIT_SCOUTS_*';
UPDATE Units SET CombatLimit = 0, Food = 1, Found = 1, CivilianAttackPriority = 'CIVILIAN_ATTACK_PRIORITY_HIGH_EARLY_GAME_ONLY' WHERE Type GLOB 'UNIT_SETTLERS_*';
UPDATE Units SET CombatLimit = 0, WorkRate = 100, CivilianAttackPriority = 'CIVILIAN_ATTACK_PRIORITY_LOW' WHERE Type GLOB 'UNIT_WORKERS_*';
UPDATE Units SET CombatLimit = 0, WorkRate = 70, CivilianAttackPriority = 'CIVILIAN_ATTACK_PRIORITY_LOW', NoMaintenance=1 WHERE Type GLOB 'UNIT_SLAVES_*';
UPDATE Units SET CombatLimit = 0, Immobile = 1 WHERE Type IN ('UNIT_FISHING_BOATS','UNIT_WHALING_BOATS','UNIT_HUNTERS');
--UPDATE Units SET CombatLimit = 0, Immobile = 1, Trade = 1, NoMaintenance = 1, CivilianAttackPriority = 'CIVILIAN_ATTACK_PRIORITY_LOW' WHERE Type IN ('UNIT_CARAVAN','UNITCLASS_CARGO_SHIP');
UPDATE Units SET Capture = 'UNITCLASS_SLAVES_MAN' WHERE Type IN ('UNIT_SETTLERS_MAN','UNIT_WORKERS_MAN','UNIT_SLAVES_MAN'); 
UPDATE Units SET Capture = 'UNITCLASS_SLAVES_SIDHE' WHERE Type IN ('UNIT_SETTLERS_SIDHE','UNIT_WORKERS_SIDHE','UNIT_SLAVES_SIDHE');
UPDATE Units SET Capture = 'UNITCLASS_SLAVES_ORC' WHERE Type IN ('UNIT_SETTLERS_ORC','UNIT_WORKERS_ORC','UNIT_SLAVES_ORC');
UPDATE Units SET XPValueAttack=3, XPValueDefense=3;
UPDATE Units SET MinAreaSize=20 WHERE CombatClass = 'UNITCOMBAT_NAVAL';
UPDATE Units SET PrereqTech = 'TECH_CURRENCY' WHERE Type = 'UNIT_CARAVAN';
UPDATE Units SET PrereqTech = 'TECH_SAILING' WHERE Type = 'UNIT_CARGO_SHIP';

--BALANCE
UPDATE Units SET Cost = Cost / 2 WHERE Cost != -1;


-- specific adds: NoBadGoodies, GoodyHutUpgradeUnitClass

----------------------------------------------------------------------------------------
-- People
----------------------------------------------------------------------------------------

INSERT INTO Units (Type, UnitArtInfo,				IconAtlas,					PortraitIndex,	UnitFlagAtlas,			UnitFlagIconOffset,	Special) VALUES
('UNIT_ENGINEER',		'ART_DEF_UNIT_EA_ENGINEER',	'UNIT_ATLAS_2',				47,				'UNIT_FLAG_ATLAS',		89,					'SPECIALUNIT_PEOPLE'	),
('UNIT_MERCHANT',		'ART_DEF_UNIT_EA_MERCHANT',	'UNIT_ATLAS_2',				46,				'UNIT_FLAG_ATLAS',		92,					'SPECIALUNIT_PEOPLE'	),
('UNIT_SAGE',			'ART_DEF_UNIT_EA_SAGE',		'UNIT_ATLAS_2',				45,				'EA_FLAG_ATLAS',		0,					'SPECIALUNIT_PEOPLE'	),
('UNIT_ALCHEMIST',		'ART_DEF_UNIT_EA_SAGE',		'UNIT_ATLAS_2',				45,				'UNIT_FLAG_ATLAS',		91,					'SPECIALUNIT_PEOPLE'	),
('UNIT_ARTIST',			'ART_DEF_UNIT_EA_ARTIST',	'UNIT_ATLAS_2',				44,				'UNIT_FLAG_ATLAS',		88,					'SPECIALUNIT_PEOPLE'	),
('UNIT_WARRIOR',		'ART_DEF_UNIT_EA_WARRIOR',	'UNIT_ATLAS_2',				48,				'UNIT_FLAG_ATLAS',		90,					'SPECIALUNIT_PEOPLE'	),
('UNIT_BERSERKER',		'ART_DEF_UNIT_EA_WARRIOR',	'UNIT_ATLAS_2',				48,				'UNIT_FLAG_ATLAS',		90,					'SPECIALUNIT_PEOPLE'	),
('UNIT_PRIEST',			'ART_DEF_UNIT_EA_PRIEST',	'EXPANSION_UNIT_ATLAS_1',	20,				'EA_FLAG_ATLAS',		3,					'SPECIALUNIT_PEOPLE'	),
('UNIT_FALLENPRIEST',	'ART_DEF_UNIT_EA_PRIEST',	'EXPANSION_UNIT_ATLAS_1',	20,				'EA_FLAG_ATLAS',		3,					'SPECIALUNIT_PEOPLE'	),
('UNIT_PALADIN',		'ART_DEF_UNIT_EA_PALADIN',	'UNIT_ATLAS_2',				48,				'UNIT_FLAG_ATLAS',		90,					'SPECIALUNIT_PEOPLE'	),
('UNIT_EIDOLON',		'ART_DEF_UNIT_EA_PALADIN',	'UNIT_ATLAS_2',				48,				'EA_FLAG_ATLAS',		6,					'SPECIALUNIT_PEOPLE'	),
('UNIT_DRUID',			'ART_DEF_UNIT_EA_DRUID',	'EXPANSION_UNIT_ATLAS_1',	17,				'EA_FLAG_ATLAS',		2,					'SPECIALUNIT_PEOPLE'	),
('UNIT_WITCH',			'ART_DEF_UNIT_INQUISITOR',	'EXPANSION_UNIT_ATLAS_1',	17,				'EA_FLAG_ATLAS',		1,					'SPECIALUNIT_PEOPLE'	),
('UNIT_WIZARD',			'ART_DEF_UNIT_INQUISITOR',	'EXPANSION_UNIT_ATLAS_1',	17,				'EA_FLAG_ATLAS',		5,					'SPECIALUNIT_PEOPLE'	),
('UNIT_SORCERER',		'ART_DEF_UNIT_INQUISITOR',	'EXPANSION_UNIT_ATLAS_1',	17,				'EA_FLAG_ATLAS',		8,					'SPECIALUNIT_PEOPLE'	),
('UNIT_NECROMANCER',	'ART_DEF_UNIT_INQUISITOR',	'EXPANSION_UNIT_ATLAS_1',	17,				'EA_FLAG_ATLAS',		8,					'SPECIALUNIT_PEOPLE'	),
('UNIT_LICH',			'ART_DEF_UNIT_INQUISITOR',	'EXPANSION_UNIT_ATLAS_1',	17,				'EA_FLAG_ATLAS',		8,					'SPECIALUNIT_PEOPLE'	);

UPDATE Units SET Cost = -1, AdvancedStartCost = -1, Domain = 'DOMAIN_LAND', Moves = 2, MoveRate = 'GREAT_PERSON', WorkRate = 100, Combat = 5, CombatLimit = 100, CombatClass = 'UNITCOMBAT_MELEE', RivalTerritory = 1, NoMaintenance = 1, XPValueAttack = 3, XPValueDefense = 3 WHERE Special = 'SPECIALUNIT_PEOPLE';

----------------------------------------------------------------------------------------
--Build out the Units table for dependent strings (more below)
UPDATE Units SET Description = 'TXT_KEY_EA_' || Type;
UPDATE Units SET Description = REPLACE(Description, '_MAN', '');
UPDATE Units SET Description = REPLACE(Description, '_SIDHE', '');
UPDATE Units SET Description = REPLACE(Description, '_ORC', '');
UPDATE Units SET Civilopedia = Description || '_PEDIA', Strategy = Description || '_STRATEGY', Help = Description || '_HELP';


----------------------------------------------------------------------------------------
-- People temp type units
----------------------------------------------------------------------------------------

INSERT INTO Units (Type,		Description,			EaGPTempRole,	Combat,	RangedCombat,	Range,	Moves,	Immobile,	CombatClass,			DefaultUnitAI,			UnitArtInfo,							IconAtlas,					PortraitIndex,	UnitFlagIconOffset,	Special					) VALUES
('UNIT_DRUID_MAGIC_MISSLE',		'TXT_KEY_UNIT_DRUID',	'MagicMissle',	5,		10,				2,		2,		1,			'UNITCOMBAT_ARCHER',	'UNITAI_RANGED',		'ART_DEF_UNIT_EA_DRUID_MAGIC_MISSLE',	'EXPANSION_UNIT_ATLAS_1',	17,				17,					'SPECIALUNIT_PEOPLE'	),
('UNIT_PRIEST_MAGIC_MISSLE',	'TXT_KEY_UNIT_DRUID',	'MagicMissle',	5,		10,				2,		2,		1,			'UNITCOMBAT_ARCHER',	'UNITAI_RANGED',		'ART_DEF_UNIT_EA_PRIEST_MAGIC_MISSLE',	'EXPANSION_UNIT_ATLAS_1',	20,				20,					'SPECIALUNIT_PEOPLE'	);

UPDATE Units SET Cost = -1, AdvancedStartCost = -1, Domain = 'DOMAIN_LAND', Moves = 2, MoveRate = 'GREAT_PERSON', CombatLimit = 100, RivalTerritory = 1, NoMaintenance = 1, XPValueAttack = 3, XPValueDefense = 3 WHERE EaGPTempRole IS NOT NULL;

CREATE TABLE Unit_EaGPTempTypes (UnitType, TempUnitType);
INSERT INTO Unit_EaGPTempTypes (UnitType, TempUnitType) VALUES
('UNIT_DRUID', 'UNIT_DRUID_MAGIC_MISSLE'),		--Lua will fallback to something if no match here
('UNIT_FALLENPRIEST', 'UNIT_PRIEST_MAGIC_MISSLE');



----------------------------------------------------------------------------------------
--Build out the Units table for dependent strings
UPDATE Units SET Class = REPLACE(Type, 'UNIT_', 'UNITCLASS_');


----------------------------------------------------------------------------------------
-- UnitClasses (this is soooooo much easier...)
----------------------------------------------------------------------------------------
DELETE FROM UnitClasses;
INSERT INTO UnitClasses (Type, Description, DefaultUnit) SELECT Class, Description, Type FROM Units;

----------------------------------------------------------------------------------------
-- Unit subtables
----------------------------------------------------------------------------------------

DELETE FROM Unit_Buildings;
DELETE FROM Unit_ProductionModifierBuildings;
DELETE FROM Unit_GreatPersons;
DELETE FROM Unit_UniqueNames;
DELETE FROM Unit_YieldFromKills;
DELETE FROM Unit_NotAITypes;
DELETE FROM Unit_ProductionTraits;

DELETE FROM Unit_ClassUpgrades;
INSERT INTO Unit_ClassUpgrades (UnitType, UnitClassType)	--alter dll to allow alternate upgrade paths?

--SELECT 'UNIT_LONGSHIPS', 'UNITCLASS_BIREMES' UNION ALL
SELECT 'UNIT_BIREMES', 'UNITCLASS_TRIREMES' UNION ALL
SELECT 'UNIT_TRIREMES', 'UNITCLASS_QUINQUEREMES' UNION ALL

SELECT 'UNIT_DROMONS', 'UNITCLASS_CARRACKS' UNION ALL
SELECT 'UNIT_CARRACKS', 'UNITCLASS_GALLEONS' UNION ALL
SELECT 'UNIT_BALLISTAE', 'UNITCLASS_TREBUCHETS' UNION ALL
SELECT 'UNIT_CATAPULTS', 'UNITCLASS_TREBUCHETS' UNION ALL
SELECT 'UNIT_TREBUCHETS', 'UNITCLASS_BOMBARDS' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'UNITCLASS_FIRE_TREBUCHETS' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'UNITCLASS_BOMBARDS' UNION ALL
SELECT 'UNIT_MOUNTED_ELEPHANTS', 'UNITCLASS_WAR_ELEPHANTS' UNION ALL
SELECT 'UNIT_WAR_ELEPHANTS', 'UNITCLASS_MUMAKIL' UNION ALL

SELECT 'UNIT_SCOUTS_MAN', 'UNITCLASS_TRACKERS_MAN' UNION ALL
SELECT 'UNIT_TRACKERS_MAN', 'UNITCLASS_RANGERS_MAN' UNION ALL
SELECT 'UNIT_WARRIORS_MAN', 'UNITCLASS_LIGHT_INFANTRY_MAN' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_MAN', 'UNITCLASS_MEDIUM_INFANTRY_MAN' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_MAN', 'UNITCLASS_HEAVY_INFANTRY_MAN' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_MAN', 'UNITCLASS_IMMORTALS_MAN' UNION ALL
SELECT 'UNIT_CHARIOTS_MAN', 'UNITCLASS_HORSEMEN_MAN' UNION ALL
SELECT 'UNIT_HORSEMEN_MAN', 'UNITCLASS_EQUITES_MAN' UNION ALL
SELECT 'UNIT_EQUITES_MAN', 'UNITCLASS_CATAPHRACTS_MAN' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'UNITCLASS_CATAPHRACTS_MAN' UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'UNITCLASS_CLIBANARII_MAN' UNION ALL
SELECT 'UNIT_ARCHERS_MAN', 'UNITCLASS_BOWMEN_MAN' UNION ALL
--SELECT 'UNIT_BOWMEN_MAN', 'UNITCLASS_MARKSMEN_MAN' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'UNITCLASS_HORSE_ARCHERS_MAN' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'UNITCLASS_BOWED_CAVALRY_MAN' UNION ALL
--SELECT 'UNIT_BOWED_CAVALRY_MAN', 'UNITCLASS_SAGITARII_MAN' UNION ALL

SELECT 'UNIT_SCOUTS_SIDHE', 'UNITCLASS_TRACKERS_SIDHE' UNION ALL
SELECT 'UNIT_TRACKERS_SIDHE', 'UNITCLASS_RANGERS_SIDHE' UNION ALL
SELECT 'UNIT_WARRIORS_SIDHE', 'UNITCLASS_LIGHT_INFANTRY_SIDHE' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_SIDHE', 'UNITCLASS_MEDIUM_INFANTRY_SIDHE' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_SIDHE', 'UNITCLASS_HEAVY_INFANTRY_SIDHE' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_SIDHE', 'UNITCLASS_IMMORTALS_SIDHE' UNION ALL
SELECT 'UNIT_CHARIOTS_SIDHE', 'UNITCLASS_HORSEMEN_SIDHE' UNION ALL
SELECT 'UNIT_HORSEMEN_SIDHE', 'UNITCLASS_EQUITES_SIDHE' UNION ALL
SELECT 'UNIT_EQUITES_SIDHE', 'UNITCLASS_CATAPHRACTS_SIDHE' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'UNITCLASS_CATAPHRACTS_SIDHE' UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'UNITCLASS_CLIBANARII_SIDHE' UNION ALL
SELECT 'UNIT_ARCHERS_SIDHE', 'UNITCLASS_BOWMEN_SIDHE' UNION ALL
--SELECT 'UNIT_BOWMEN_SIDHE', 'UNITCLASS_MARKSMEN_SIDHE' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'UNITCLASS_HORSE_ARCHERS_SIDHE' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'UNITCLASS_BOWED_CAVALRY_SIDHE' UNION ALL
--SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'UNITCLASS_SAGITARII_SIDHE' UNION ALL

SELECT 'UNIT_SCOUTS_ORC', 'UNITCLASS_TRACKERS_ORC' UNION ALL
SELECT 'UNIT_TRACKERS_ORC', 'UNITCLASS_RANGERS_ORC' UNION ALL
SELECT 'UNIT_WARRIORS_ORC', 'UNITCLASS_LIGHT_INFANTRY_ORC' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_ORC', 'UNITCLASS_MEDIUM_INFANTRY_ORC' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_ORC', 'UNITCLASS_HEAVY_INFANTRY_ORC' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_ORC', 'UNITCLASS_IMMORTALS_ORC' UNION ALL
SELECT 'UNIT_CHARIOTS_ORC', 'UNITCLASS_HORSEMEN_ORC' UNION ALL
SELECT 'UNIT_HORSEMEN_ORC', 'UNITCLASS_EQUITES_ORC' UNION ALL
SELECT 'UNIT_EQUITES_ORC', 'UNITCLASS_CATAPHRACTS_ORC' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'UNITCLASS_CATAPHRACTS_ORC' UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'UNITCLASS_CLIBANARII_ORC' UNION ALL
SELECT 'UNIT_ARCHERS_ORC', 'UNITCLASS_BOWMEN_ORC' UNION ALL
--SELECT 'UNIT_BOWMEN_ORC', 'UNITCLASS_MARKSMEN_ORC' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'UNITCLASS_HORSE_ARCHERS_ORC' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'UNITCLASS_BOWED_CAVALRY_ORC' ;
--SELECT 'UNIT_BOWED_CAVALRY_ORC', 'UNITCLASS_SAGITARII_ORC' ;

DELETE FROM Unit_AITypes;

--AUTOMATE THIS!
--DefaultUnitAI = 'UNITAI_SETTLE'	-> UNITAI_SETTLE
--DefaultUnitAI = 'UNITAI_WORKER'	-> UNITAI_WORKER
--DefaultUnitAI = 'UNITAI_WORKER_SEA'	-> UNITAI_WORKER_SEA

--CombatClass = 'UNITCOMBAT_NAVALMELEE'	-> UNITAI_ATTACK_SEA, UNITAI_RESERVE_SEA, UNITAI_ESCORT_SEA, UNITAI_EXPLORE_SEA
--CombatClass = 'UNITCOMBAT_NAVALRANGED'	-> UNITAI_ASSAULT_SEA, UNITAI_RESERVE_SEA, UNITAI_ESCORT_SEA, UNITAI_EXPLORE_SEA
--CombatClass = 'UNITCOMBAT_SIEGE'	-> UNITAI_CITY_BOMBARD, UNITAI_RANGED
--CombatClass = 'UNITCOMBAT_RECON'	-> UNITAI_EXPLORE (UNITAI_ATTACK if Combat > 9)
--CombatClass = 'UNITCOMBAT_MELEE'	-> UNITAI_ATTACK, UNITAI_DEFENSE (& UNITAI_EXPLORE if Combat < 9)
--CombatClass = 'UNITCOMBAT_ARCHER'	-> UNITAI_RANGED
--CombatClass = 'UNITCOMBAT_MOUNTED'	-> UNITAI_FAST_ATTACK, UNITAI_DEFENSE

--CombatClass = 'UNITCOMBAT_GUN'	-> UNITAI_FAST_ATTACK, UNITAI_RANGED
--CombatClass = 'UNITCOMBAT_ARMOR'	-> UNITAI_ATTACK, UNITAI_DEFENSE, UNITAI_EXPLORE

--Base is a little inconsistent on whether DefaultUnitAI (from Units table) needs to be in this table or not. I'll add to be safe.

INSERT INTO Unit_AITypes (UnitType, UnitAIType)
--barb only units
SELECT 'UNIT_GALLEYS_PIRATES', 'UNITAI_ATTACK_SEA' UNION ALL	--melee ship only
SELECT 'UNIT_GALLEYS_PIRATES', 'UNITAI_RESERVE_SEA' UNION ALL
SELECT 'UNIT_GALLEYS_PIRATES', 'UNITAI_ESCORT_SEA' UNION ALL
SELECT 'UNIT_GALLEYS_PIRATES', 'UNITAI_EXPLORE_SEA' UNION ALL
SELECT 'UNIT_WARRIORS_BARB', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_WARRIORS_BARB', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_BARB', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_BARB', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_BARB', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_BARB', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_ARCHERS_BARB', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_AXMAN_BARB', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_OGRES', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_OGRES', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_HOBGOBLINS', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_HOBGOBLINS', 'UNITAI_DEFENSE' UNION ALL

--animals and beasts
SELECT 'UNIT_WOLVES', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_LIONS', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_GIANT_SPIDER', 'UNITAI_ATTACK' UNION ALL

--summoned only
SELECT 'UNIT_TREE_ENT', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_ZOMBIES', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_GREAT_UNCLEAN_ONE', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_HIVE_TYRANT', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_LICTOR', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_HORMAGAUNT', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_ANGEL_SPEARMAN', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_ANGEL', 'UNITAI_ATTACK' UNION ALL

--civs
SELECT 'UNIT_FISHING_BOATS', 'UNITAI_WORKER_SEA' UNION ALL	--needed?
SELECT 'UNIT_WHALING_BOATS', 'UNITAI_WORKER_SEA' UNION ALL
SELECT 'UNIT_HUNTERS', 'UNITAI_WORKER' UNION ALL
SELECT 'UNIT_SETTLERS_MINOR', 'UNITAI_SETTLE' UNION ALL

SELECT 'UNIT_BIREMES', 'UNITAI_ATTACK_SEA' UNION ALL	--melee ship only
SELECT 'UNIT_BIREMES', 'UNITAI_RESERVE_SEA' UNION ALL
SELECT 'UNIT_BIREMES', 'UNITAI_ESCORT_SEA' UNION ALL
SELECT 'UNIT_BIREMES', 'UNITAI_EXPLORE_SEA' UNION ALL
SELECT 'UNIT_TRIREMES', 'UNITAI_ATTACK_SEA' UNION ALL
SELECT 'UNIT_TRIREMES', 'UNITAI_RESERVE_SEA' UNION ALL
SELECT 'UNIT_TRIREMES', 'UNITAI_ESCORT_SEA' UNION ALL
SELECT 'UNIT_TRIREMES', 'UNITAI_EXPLORE_SEA' UNION ALL
SELECT 'UNIT_QUINQUEREMES', 'UNITAI_ATTACK_SEA' UNION ALL
SELECT 'UNIT_QUINQUEREMES', 'UNITAI_RESERVE_SEA' UNION ALL
SELECT 'UNIT_QUINQUEREMES', 'UNITAI_ESCORT_SEA' UNION ALL
SELECT 'UNIT_QUINQUEREMES', 'UNITAI_EXPLORE_SEA' UNION ALL
SELECT 'UNIT_CARAVELS', 'UNITAI_ATTACK_SEA' UNION ALL
SELECT 'UNIT_CARAVELS', 'UNITAI_RESERVE_SEA' UNION ALL
SELECT 'UNIT_CARAVELS', 'UNITAI_ESCORT_SEA' UNION ALL
SELECT 'UNIT_CARAVELS', 'UNITAI_EXPLORE_SEA' UNION ALL

SELECT 'UNIT_DROMONS', 'UNITAI_ASSAULT_SEA' UNION ALL	--naval ranged only
SELECT 'UNIT_DROMONS', 'UNITAI_RESERVE_SEA' UNION ALL
SELECT 'UNIT_DROMONS', 'UNITAI_ESCORT_SEA' UNION ALL
SELECT 'UNIT_DROMONS', 'UNITAI_EXPLORE_SEA' UNION ALL
SELECT 'UNIT_CARRACKS', 'UNITAI_ASSAULT_SEA' UNION ALL
SELECT 'UNIT_CARRACKS', 'UNITAI_RESERVE_SEA' UNION ALL
SELECT 'UNIT_CARRACKS', 'UNITAI_ESCORT_SEA' UNION ALL
SELECT 'UNIT_CARRACKS', 'UNITAI_EXPLORE_SEA' UNION ALL
SELECT 'UNIT_GALLEONS', 'UNITAI_ASSAULT_SEA' UNION ALL
SELECT 'UNIT_GALLEONS', 'UNITAI_RESERVE_SEA' UNION ALL
SELECT 'UNIT_GALLEONS', 'UNITAI_ESCORT_SEA' UNION ALL
SELECT 'UNIT_GALLEONS', 'UNITAI_EXPLORE_SEA' UNION ALL
SELECT 'UNIT_IRONCLADS', 'UNITAI_ASSAULT_SEA' UNION ALL
SELECT 'UNIT_IRONCLADS', 'UNITAI_RESERVE_SEA' UNION ALL
SELECT 'UNIT_IRONCLADS', 'UNITAI_ESCORT_SEA' UNION ALL

SELECT 'UNIT_BALLISTAE', 'UNITAI_CITY_BOMBARD' UNION ALL
SELECT 'UNIT_BALLISTAE', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_CATAPULTS', 'UNITAI_CITY_BOMBARD' UNION ALL
SELECT 'UNIT_CATAPULTS', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_TREBUCHETS', 'UNITAI_CITY_BOMBARD' UNION ALL
SELECT 'UNIT_TREBUCHETS', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'UNITAI_CITY_BOMBARD' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'UNITAI_CITY_BOMBARD' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_BOMBARDS', 'UNITAI_CITY_BOMBARD' UNION ALL
SELECT 'UNIT_BOMBARDS', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'UNITAI_CITY_BOMBARD' UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'UNITAI_RANGED' UNION ALL

SELECT 'UNIT_MOUNTED_ELEPHANTS', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_MOUNTED_ELEPHANTS', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_MOUNTED_ELEPHANTS', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_WAR_ELEPHANTS', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_WAR_ELEPHANTS', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_MUMAKIL', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_MUMAKIL', 'UNITAI_DEFENSE' UNION ALL

SELECT 'UNIT_SETTLERS_MAN', 'UNITAI_SETTLE' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'UNITAI_WORKER' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'UNITAI_WORKER' UNION ALL

SELECT 'UNIT_SCOUTS_MAN', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_TRACKERS_MAN', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_RANGERS_MAN', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_RANGERS_MAN', 'UNITAI_ATTACK' UNION ALL

SELECT 'UNIT_WARRIORS_MAN', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_WARRIORS_MAN', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_WARRIORS_MAN', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_MAN', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_MAN', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_MAN', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_MAN', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_MAN', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_MAN', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_MAN', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_IMMORTALS_MAN', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_IMMORTALS_MAN', 'UNITAI_DEFENSE' UNION ALL

SELECT 'UNIT_CHARIOTS_MAN', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CHARIOTS_MAN', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_HORSEMEN_MAN', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_HORSEMEN_MAN', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_EQUITES_MAN', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_EQUITES_MAN', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'UNITAI_DEFENSE' UNION ALL

SELECT 'UNIT_ARCHERS_MAN', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_BOWMEN_MAN', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_MARKSMEN_MAN', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_MAN', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_MAN', 'UNITAI_RANGED' UNION ALL

SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'UNITAI_RANGED' UNION ALL


SELECT 'UNIT_SETTLERS_SIDHE', 'UNITAI_SETTLE' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'UNITAI_WORKER' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'UNITAI_WORKER' UNION ALL

SELECT 'UNIT_SCOUTS_SIDHE', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_TRACKERS_SIDHE', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_RANGERS_SIDHE', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_RANGERS_SIDHE', 'UNITAI_ATTACK' UNION ALL

SELECT 'UNIT_WARRIORS_SIDHE', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_WARRIORS_SIDHE', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_WARRIORS_SIDHE', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_SIDHE', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_SIDHE', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_SIDHE', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_SIDHE', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_SIDHE', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_SIDHE', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_SIDHE', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_IMMORTALS_SIDHE', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_IMMORTALS_SIDHE', 'UNITAI_DEFENSE' UNION ALL

SELECT 'UNIT_CHARIOTS_SIDHE', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CHARIOTS_SIDHE', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_HORSEMEN_SIDHE', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_HORSEMEN_SIDHE', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_EQUITES_SIDHE', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_EQUITES_SIDHE', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'UNITAI_DEFENSE' UNION ALL

SELECT 'UNIT_ARCHERS_SIDHE', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_BOWMEN_SIDHE', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_MARKSMEN_SIDHE', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_SIDHE', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_SIDHE', 'UNITAI_RANGED' UNION ALL

SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'UNITAI_RANGED' UNION ALL


SELECT 'UNIT_SETTLERS_ORC', 'UNITAI_SETTLE' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'UNITAI_WORKER' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'UNITAI_WORKER' UNION ALL

SELECT 'UNIT_SCOUTS_ORC', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_TRACKERS_ORC', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_RANGERS_ORC', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_RANGERS_ORC', 'UNITAI_ATTACK' UNION ALL

SELECT 'UNIT_WARRIORS_ORC', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_WARRIORS_ORC', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_WARRIORS_ORC', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_ORC', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_ORC', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_ORC', 'UNITAI_EXPLORE' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_ORC', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_ORC', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_ORC', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_ORC', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_IMMORTALS_ORC', 'UNITAI_ATTACK' UNION ALL
SELECT 'UNIT_IMMORTALS_ORC', 'UNITAI_DEFENSE' UNION ALL

SELECT 'UNIT_CHARIOTS_ORC', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CHARIOTS_ORC', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_HORSEMEN_ORC', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_HORSEMEN_ORC', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_EQUITES_ORC', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_EQUITES_ORC', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'UNITAI_DEFENSE' UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'UNITAI_DEFENSE' UNION ALL

SELECT 'UNIT_ARCHERS_ORC', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_BOWMEN_ORC', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_MARKSMEN_ORC', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_ORC', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_ORC', 'UNITAI_RANGED' UNION ALL

SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'UNITAI_FAST_ATTACK' UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'UNITAI_RANGED' UNION ALL

SELECT 'UNIT_DRUID_MAGIC_MISSLE', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_PRIEST_MAGIC_MISSLE', 'UNITAI_RANGED' UNION ALL
SELECT 'UNIT_WARRIOR_ATTACK', 'UNITAI_ATTACK' UNION ALL

-- GPs (needed?)
SELECT 'UNIT_ENGINEER', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_MERCHANT', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_SAGE', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_ALCHEMIST', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_ARTIST', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_WARRIOR', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_BERSERKER', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_PRIEST', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_PALADIN', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_DRUID', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_WITCH', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_WIZARD', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_SORCERER', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_NECROMANCER', 'UNITAI_GENERAL' UNION ALL
SELECT 'UNIT_LICH', 'UNITAI_GENERAL' ;

DELETE FROM Unit_BuildingClassRequireds;
INSERT INTO Unit_BuildingClassRequireds (UnitType, BuildingClassType)
SELECT Type, 'BUILDINGCLASS_MAN' FROM Units WHERE Type GLOB '*_MAN' UNION ALL
SELECT Type, 'BUILDINGCLASS_SIDHE' FROM Units WHERE Type GLOB '*_SIDHE' UNION ALL
SELECT Type, 'BUILDINGCLASS_HELDEOFOL' FROM Units WHERE Type GLOB '*_ORC';


DELETE FROM Unit_Builds;	
INSERT INTO Unit_Builds (UnitType, BuildType)	--see Builds in UnitBuilds.sql

--debug testing
--SELECT 'UNIT_WORKERS_MAN', 'BUILD_PYRAMID' UNION ALL
--SELECT 'UNIT_WORKERS_MAN', 'BUILD_STONEHENGE' UNION ALL

SELECT 'UNIT_WORKERS_MAN', 'BUILD_ROAD' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_RAILROAD' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_LUMBERMILL' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_BOWYERS_CAMP' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_GATHERERS_HUT' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_REPAIR' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_REMOVE_ROUTE' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_FARM' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_MINE' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_PASTURE' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_E_PLANTATION' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_T_PLANTATION' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_VINEYARD' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_ORCHARD' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_QUARRY' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_LUMBERMILL_2' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_FARM_2' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_MINE_2' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_SLASH_BURN_FOREST' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_SLASH_BURN_JUNGLE' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_CHOP_FOREST' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_CHOP_JUNGLE' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_REMOVE_MARSH' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_FARM_PAN' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_MINE_PAN' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_PASTURE_PAN' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_E_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_T_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_VINEYARD_PAN' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_ORCHARD_PAN' UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'BUILD_QUARRY_PAN' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_ROAD' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_RAILROAD' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_LUMBERMILL' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_BOWYERS_CAMP' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_GATHERERS_HUT' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_REPAIR' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_REMOVE_ROUTE' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_FARM' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_MINE' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_PASTURE' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_E_PLANTATION' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_T_PLANTATION' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_VINEYARD' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_ORCHARD' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_QUARRY' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_LUMBERMILL_2' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_FARM_2' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_MINE_2' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_SLASH_BURN_FOREST' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_SLASH_BURN_JUNGLE' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_CHOP_FOREST' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_CHOP_JUNGLE' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_REMOVE_MARSH' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_FARM_PAN' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_MINE_PAN' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_PASTURE_PAN' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_E_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_T_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_VINEYARD_PAN' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_ORCHARD_PAN' UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'BUILD_QUARRY_PAN' UNION ALL



SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_ROAD' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_RAILROAD' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_LUMBERMILL' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_BOWYERS_CAMP' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_GATHERERS_HUT' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_REPAIR' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_REMOVE_ROUTE' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_FARM' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_MINE' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_PASTURE' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_E_PLANTATION' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_T_PLANTATION' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_VINEYARD' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_ORCHARD' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_QUARRY' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_LUMBERMILL_2' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_FARM_2' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_MINE_2' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_SLASH_BURN_FOREST' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_SLASH_BURN_JUNGLE' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_CHOP_FOREST' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_CHOP_JUNGLE' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_REMOVE_MARSH' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_FARM_PAN' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_MINE_PAN' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_PASTURE_PAN' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_E_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_T_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_VINEYARD_PAN' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_ORCHARD_PAN' UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'BUILD_QUARRY_PAN' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_ROAD' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_RAILROAD' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_LUMBERMILL' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_BOWYERS_CAMP' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_GATHERERS_HUT' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_REPAIR' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_REMOVE_ROUTE' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_FARM' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_MINE' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_PASTURE' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_E_PLANTATION' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_T_PLANTATION' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_VINEYARD' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_ORCHARD' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_QUARRY' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_LUMBERMILL_2' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_FARM_2' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_MINE_2' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_SLASH_BURN_FOREST' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_SLASH_BURN_JUNGLE' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_CHOP_FOREST' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_CHOP_JUNGLE' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_REMOVE_MARSH' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_FARM_PAN' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_MINE_PAN' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_PASTURE_PAN' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_E_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_T_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_VINEYARD_PAN' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_ORCHARD_PAN' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'BUILD_QUARRY_PAN' UNION ALL



SELECT 'UNIT_WORKERS_ORC', 'BUILD_ROAD' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_RAILROAD' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_LUMBERMILL' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_BOWYERS_CAMP' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_GATHERERS_HUT' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_REPAIR' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_REMOVE_ROUTE' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_FARM' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_MINE' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_PASTURE' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_E_PLANTATION' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_T_PLANTATION' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_VINEYARD' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_ORCHARD' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_QUARRY' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_LUMBERMILL_2' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_FARM_2' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_MINE_2' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_SLASH_BURN_FOREST' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_SLASH_BURN_JUNGLE' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_CHOP_FOREST' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_CHOP_JUNGLE' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_REMOVE_MARSH' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_FARM_PAN' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_MINE_PAN' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_PASTURE_PAN' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_E_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_T_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_VINEYARD_PAN' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_ORCHARD_PAN' UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'BUILD_QUARRY_PAN' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_ROAD' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_RAILROAD' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_LUMBERMILL' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_BOWYERS_CAMP' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_GATHERERS_HUT' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_REPAIR' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_REMOVE_ROUTE' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_FARM' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_MINE' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_PASTURE' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_E_PLANTATION' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_T_PLANTATION' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_VINEYARD' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_ORCHARD' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_QUARRY' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_LUMBERMILL_2' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_FARM_2' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_MINE_2' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_SLASH_BURN_FOREST' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_SLASH_BURN_JUNGLE' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_CHOP_FOREST' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_CHOP_JUNGLE' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_REMOVE_MARSH' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_FARM_PAN' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_MINE_PAN' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_PASTURE_PAN' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_E_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_T_PLANTATION_PAN' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_VINEYARD_PAN' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_ORCHARD_PAN' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'BUILD_QUARRY_PAN' ;



--
DELETE FROM Unit_FreePromotions;
INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT 'UNIT_SLAVES_MAN', 'PROMOTION_SLAVE' UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'PROMOTION_SLAVE' UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'PROMOTION_SLAVE' UNION ALL

SELECT 'UNIT_CARAVAN', 'PROMOTION_SIGHT_PENALTY' UNION ALL
SELECT 'UNIT_CARGO_SHIP', 'PROMOTION_SIGHT_PENALTY' UNION ALL

SELECT 'UNIT_BIREMES', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_BIREMES', 'PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY' UNION ALL
SELECT 'UNIT_TRIREMES', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_TRIREMES', 'PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY' UNION ALL
SELECT 'UNIT_QUINQUEREMES', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_QUINQUEREMES', 'PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY' UNION ALL
SELECT 'UNIT_CARAVELS', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_DROMONS', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_DROMONS', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_DROMONS', 'PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY' UNION ALL
SELECT 'UNIT_CARRACKS', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_CARRACKS', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CARRACKS', 'PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY' UNION ALL
SELECT 'UNIT_GALLEONS', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_IRONCLADS', 'PROMOTION_METAL' UNION ALL
SELECT 'UNIT_IRONCLADS', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_IRONCLADS', 'PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY' UNION ALL
SELECT 'UNIT_IRONCLADS', 'PROMOTION_STEAM_POWERED' UNION ALL

SELECT 'UNIT_BALLISTAE', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_BALLISTAE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_BALLISTAE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_BALLISTAE', 'PROMOTION_MUST_SET_UP' UNION ALL
SELECT 'UNIT_BALLISTAE', 'PROMOTION_SIGHT_PENALTY' UNION ALL
SELECT 'UNIT_CATAPULTS', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_CATAPULTS', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CATAPULTS', 'PROMOTION_CITY_SIEGE' UNION ALL
SELECT 'UNIT_CATAPULTS', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CATAPULTS', 'PROMOTION_MUST_SET_UP' UNION ALL
SELECT 'UNIT_CATAPULTS', 'PROMOTION_SIGHT_PENALTY' UNION ALL
SELECT 'UNIT_TREBUCHETS', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_TREBUCHETS', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_TREBUCHETS', 'PROMOTION_CITY_SIEGE' UNION ALL
SELECT 'UNIT_TREBUCHETS', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_TREBUCHETS', 'PROMOTION_MUST_SET_UP' UNION ALL
SELECT 'UNIT_TREBUCHETS', 'PROMOTION_SIGHT_PENALTY' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'PROMOTION_CITY_SIEGE' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'PROMOTION_MUST_SET_UP' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'PROMOTION_SIGHT_PENALTY' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'PROMOTION_CITY_SIEGE' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'PROMOTION_MUST_SET_UP' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'PROMOTION_SIGHT_PENALTY' UNION ALL
SELECT 'UNIT_BOMBARDS', 'PROMOTION_METAL' UNION ALL
SELECT 'UNIT_BOMBARDS', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_BOMBARDS', 'PROMOTION_CITY_SIEGE' UNION ALL
SELECT 'UNIT_BOMBARDS', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_BOMBARDS', 'PROMOTION_MUST_SET_UP' UNION ALL
SELECT 'UNIT_BOMBARDS', 'PROMOTION_SIGHT_PENALTY' UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'PROMOTION_METAL' UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'PROMOTION_GREAT_BOMBARDE' UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'PROMOTION_MUST_SET_UP' UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'PROMOTION_SIGHT_PENALTY' UNION ALL

SELECT 'UNIT_MOUNTED_ELEPHANTS', 'PROMOTION_ELEPHANT' UNION ALL
SELECT 'UNIT_MOUNTED_ELEPHANTS', 'PROMOTION_FEARED_ELEPHANT' UNION ALL
SELECT 'UNIT_WAR_ELEPHANTS', 'PROMOTION_ELEPHANT' UNION ALL
SELECT 'UNIT_WAR_ELEPHANTS', 'PROMOTION_FEARED_ELEPHANT' UNION ALL
SELECT 'UNIT_MUMAKIL', 'PROMOTION_ELEPHANT' UNION ALL
SELECT 'UNIT_MUMAKIL', 'PROMOTION_FEARED_ELEPHANT' UNION ALL

SELECT 'UNIT_SCOUTS_MAN', 'PROMOTION_RECON' UNION ALL
SELECT 'UNIT_TRACKERS_MAN', 'PROMOTION_RECON' UNION ALL
SELECT 'UNIT_RANGERS_MAN', 'PROMOTION_RECON' UNION ALL
SELECT 'UNIT_WARRIORS_MAN', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_MAN', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_MAN', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_MAN', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_IMMORTALS_MAN', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_CHARIOTS_MAN', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_CHARIOTS_MAN', 'PROMOTION_ROUGH_TERRAIN_ENDS_TURN' UNION ALL
SELECT 'UNIT_CHARIOTS_MAN', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CHARIOTS_MAN', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_HORSEMEN_MAN', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_HORSEMEN_MAN', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_HORSEMEN_MAN', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_EQUITES_MAN', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_EQUITES_MAN', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_EQUITES_MAN', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_ARCHERS_MAN', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_ARCHERS_MAN', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_BOWMEN_MAN', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_BOWMEN_MAN', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_MARKSMEN_MAN', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_MARKSMEN_MAN', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_MAN', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_MAN', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_MAN', 'PROMOTION_PIERCING_1' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_MAN', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_MAN', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_MAN', 'PROMOTION_PIERCING_1' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_MAN', 'PROMOTION_PIERCING_2' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'PROMOTION_ROUGH_TERRAIN_ENDS_TURN' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL

SELECT 'UNIT_SCOUTS_SIDHE', 'PROMOTION_RECON' UNION ALL
SELECT 'UNIT_TRACKERS_SIDHE', 'PROMOTION_RECON' UNION ALL
SELECT 'UNIT_RANGERS_SIDHE', 'PROMOTION_RECON' UNION ALL
SELECT 'UNIT_WARRIORS_SIDHE', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_SIDHE', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_SIDHE', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_SIDHE', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_IMMORTALS_SIDHE', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_CHARIOTS_SIDHE', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_CHARIOTS_SIDHE', 'PROMOTION_ROUGH_TERRAIN_ENDS_TURN' UNION ALL
SELECT 'UNIT_CHARIOTS_SIDHE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CHARIOTS_SIDHE', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_HORSEMEN_SIDHE', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_HORSEMEN_SIDHE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_HORSEMEN_SIDHE', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_EQUITES_SIDHE', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_EQUITES_SIDHE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_EQUITES_SIDHE', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_ARCHERS_SIDHE', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_ARCHERS_SIDHE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_BOWMEN_SIDHE', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_BOWMEN_SIDHE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_MARKSMEN_SIDHE', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_MARKSMEN_SIDHE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_SIDHE', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_SIDHE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_SIDHE', 'PROMOTION_PIERCING_1' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_SIDHE', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_SIDHE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_SIDHE', 'PROMOTION_PIERCING_1' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_SIDHE', 'PROMOTION_PIERCING_2' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'PROMOTION_ROUGH_TERRAIN_ENDS_TURN' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL

SELECT 'UNIT_SCOUTS_ORC', 'PROMOTION_RECON' UNION ALL
SELECT 'UNIT_TRACKERS_ORC', 'PROMOTION_RECON' UNION ALL
SELECT 'UNIT_RANGERS_ORC', 'PROMOTION_RECON' UNION ALL
SELECT 'UNIT_WARRIORS_ORC', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_ORC', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_ORC', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_ORC', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_IMMORTALS_ORC', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_CHARIOTS_ORC', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_CHARIOTS_ORC', 'PROMOTION_ROUGH_TERRAIN_ENDS_TURN' UNION ALL
SELECT 'UNIT_CHARIOTS_ORC', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CHARIOTS_ORC', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_HORSEMEN_ORC', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_HORSEMEN_ORC', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_HORSEMEN_ORC', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_EQUITES_ORC', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_EQUITES_ORC', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_EQUITES_ORC', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_ARCHERS_ORC', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_ARCHERS_ORC', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_BOWMEN_ORC', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_BOWMEN_ORC', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_MARKSMEN_ORC', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_MARKSMEN_ORC', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_ORC', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_ORC', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CROSSBOWMEN_ORC', 'PROMOTION_PIERCING_1' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_ORC', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_ORC', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_ORC', 'PROMOTION_PIERCING_1' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_ORC', 'PROMOTION_PIERCING_2' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'PROMOTION_ROUGH_TERRAIN_ENDS_TURN' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'PROMOTION_HORSE_MOUNTED' UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'PROMOTION_NO_DEFENSIVE_BONUSES' UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'PROMOTION_MOVEMENT_TO_GENERAL' UNION ALL

SELECT 'UNIT_GALLEYS_PIRATES', 'PROMOTION_WOODEN' UNION ALL
SELECT 'UNIT_GALLEYS_PIRATES', 'PROMOTION_OCEAN_IMPASSABLE_UNTIL_ASTRONOMY' UNION ALL
SELECT 'UNIT_WARRIORS_BARB', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_BARB', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_BARB', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_ARCHERS_BARB', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_AXMAN_BARB', 'PROMOTION_UNMOUNTED_ARCHER' UNION ALL
SELECT 'UNIT_OGRES', 'PROMOTION_INFANTRY' UNION ALL
SELECT 'UNIT_HOBGOBLINS', 'PROMOTION_INFANTRY' UNION ALL

SELECT 'UNIT_WOLVES', 'PROMOTION_ANIMAL' UNION ALL
SELECT 'UNIT_LIONS', 'PROMOTION_ANIMAL' UNION ALL
SELECT 'UNIT_GIANT_SPIDER', 'PROMOTION_ANIMAL' UNION ALL

-- all GPs can move rival terrain
SELECT 'UNIT_ENGINEER', 'PROMOTION_ENGINEER' UNION ALL
SELECT 'UNIT_ENGINEER', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_MERCHANT', 'PROMOTION_MERCHANT' UNION ALL
SELECT 'UNIT_MERCHANT', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_SAGE', 'PROMOTION_SAGE' UNION ALL
SELECT 'UNIT_SAGE', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_ALCHEMIST', 'PROMOTION_SAGE' UNION ALL
SELECT 'UNIT_ALCHEMIST', 'PROMOTION_ALCHEMIST' UNION ALL
SELECT 'UNIT_ALCHEMIST', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_ARTIST', 'PROMOTION_ARTIST' UNION ALL
SELECT 'UNIT_ARTIST', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_WARRIOR', 'PROMOTION_WARRIOR' UNION ALL
SELECT 'UNIT_WARRIOR', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_BERSERKER', 'PROMOTION_WARRIOR' UNION ALL
SELECT 'UNIT_BERSERKER', 'PROMOTION_BERSERKER' UNION ALL
SELECT 'UNIT_BERSERKER', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_PRIEST', 'PROMOTION_DEVOUT' UNION ALL
SELECT 'UNIT_PRIEST', 'PROMOTION_PRIEST' UNION ALL
SELECT 'UNIT_PRIEST', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_FALLENPRIEST', 'PROMOTION_DEVOUT' UNION ALL
SELECT 'UNIT_FALLENPRIEST', 'PROMOTION_THAUMATURGE' UNION ALL
SELECT 'UNIT_FALLENPRIEST', 'PROMOTION_FALLENPRIEST' UNION ALL
SELECT 'UNIT_FALLENPRIEST', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_PALADIN', 'PROMOTION_WARRIOR' UNION ALL
SELECT 'UNIT_PALADIN', 'PROMOTION_DEVOUT' UNION ALL
SELECT 'UNIT_PALADIN', 'PROMOTION_PALADIN' UNION ALL
SELECT 'UNIT_PALADIN', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_EIDOLON', 'PROMOTION_WARRIOR' UNION ALL
SELECT 'UNIT_EIDOLON', 'PROMOTION_DEVOUT' UNION ALL
SELECT 'UNIT_EIDOLON', 'PROMOTION_EIDOLON' UNION ALL
SELECT 'UNIT_EIDOLON', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_DRUID', 'PROMOTION_DEVOUT' UNION ALL
SELECT 'UNIT_DRUID', 'PROMOTION_THAUMATURGE' UNION ALL
SELECT 'UNIT_DRUID', 'PROMOTION_DRUID' UNION ALL
SELECT 'UNIT_DRUID', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_WITCH', 'PROMOTION_THAUMATURGE' UNION ALL
SELECT 'UNIT_WITCH', 'PROMOTION_WITCH' UNION ALL
SELECT 'UNIT_WITCH', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_WIZARD', 'PROMOTION_THAUMATURGE' UNION ALL
SELECT 'UNIT_WIZARD', 'PROMOTION_WIZARD' UNION ALL
SELECT 'UNIT_WIZARD', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_SORCERER', 'PROMOTION_THAUMATURGE' UNION ALL
SELECT 'UNIT_SORCERER', 'PROMOTION_SORCERER' UNION ALL
SELECT 'UNIT_SORCERER', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_NECROMANCER', 'PROMOTION_THAUMATURGE' UNION ALL
SELECT 'UNIT_NECROMANCER', 'PROMOTION_NECROMANCER' UNION ALL
SELECT 'UNIT_NECROMANCER', 'PROMOTION_RIVAL_TERRITORY' UNION ALL
SELECT 'UNIT_LICH', 'PROMOTION_THAUMATURGE' UNION ALL
SELECT 'UNIT_LICH', 'PROMOTION_LICH' UNION ALL
SELECT 'UNIT_LICH', 'PROMOTION_RIVAL_TERRITORY' UNION ALL

SELECT 'UNIT_DRUID_MAGIC_MISSLE', 'PROMOTION_INDIRECT_FIRE' UNION ALL
SELECT 'UNIT_DRUID_MAGIC_MISSLE', 'PROMOTION_ONLY_DEFENSIVE' UNION ALL
SELECT 'UNIT_PRIEST_MAGIC_MISSLE', 'PROMOTION_INDIRECT_FIRE' UNION ALL
SELECT 'UNIT_PRIEST_MAGIC_MISSLE', 'PROMOTION_ONLY_DEFENSIVE' ;

--SELECT 'UNIT_DUMMY_EXPLODER', 'PROMOTION_DUMMY_AIR_STRIKE' UNION ALL
--SELECT 'UNIT_DUMMY_NUKE', 'PROMOTION_DUMMY_AIR_STRIKE' ;


DELETE FROM Unit_Flavors;
INSERT INTO Unit_Flavors (UnitType, FlavorType, Flavor)
SELECT 'UNIT_FISHING_BOATS', 'FLAVOR_NAVAL_TILE_IMPROVEMENT', 100 UNION ALL
SELECT 'UNIT_FISHING_BOATS', 'FLAVOR_TILE_IMPROVEMENT', 100 UNION ALL
SELECT 'UNIT_FISHING_BOATS', 'FLAVOR_EXPANSION', 100 UNION ALL
SELECT 'UNIT_WHALING_BOATS', 'FLAVOR_NAVAL_TILE_IMPROVEMENT', 100 UNION ALL
SELECT 'UNIT_WHALING_BOATS', 'FLAVOR_EXPANSION', 100 UNION ALL
SELECT 'UNIT_HUNTERS', 'FLAVOR_TILE_IMPROVEMENT', 100 UNION ALL
SELECT 'UNIT_HUNTERS', 'FLAVOR_EXPANSION', 100 UNION ALL

SELECT 'UNIT_CARAVAN', 'FLAVOR_I_LAND_TRADE_ROUTE', 40 UNION ALL
SELECT 'UNIT_CARAVAN', 'FLAVOR_GOLD', 20 UNION ALL
SELECT 'UNIT_CARGO_SHIP', 'FLAVOR_I_SEA_TRADE_ROUTE', 40 UNION ALL
SELECT 'UNIT_CARGO_SHIP', 'FLAVOR_GOLD', 40 UNION ALL

SELECT 'UNIT_BIREMES', 'FLAVOR_NAVAL', 8 UNION ALL
SELECT 'UNIT_BIREMES', 'FLAVOR_NAVAL_RECON', 12 UNION ALL
SELECT 'UNIT_TRIREMES', 'FLAVOR_NAVAL', 24 UNION ALL
SELECT 'UNIT_TRIREMES', 'FLAVOR_NAVAL_RECON', 8 UNION ALL
SELECT 'UNIT_QUINQUEREMES', 'FLAVOR_NAVAL', 30 UNION ALL
SELECT 'UNIT_QUINQUEREMES', 'FLAVOR_NAVAL_RECON', 8 UNION ALL
SELECT 'UNIT_DROMONS', 'FLAVOR_NAVAL', 24 UNION ALL
SELECT 'UNIT_DROMONS', 'FLAVOR_NAVAL_RECON', 12 UNION ALL
SELECT 'UNIT_CARRACKS', 'FLAVOR_NAVAL', 30 UNION ALL
SELECT 'UNIT_CARRACKS', 'FLAVOR_NAVAL_RECON', 8 UNION ALL
SELECT 'UNIT_CARAVELS', 'FLAVOR_NAVAL', 4 UNION ALL
SELECT 'UNIT_CARAVELS', 'FLAVOR_NAVAL_RECON', 20 UNION ALL
SELECT 'UNIT_GALLEONS', 'FLAVOR_NAVAL', 36 UNION ALL
SELECT 'UNIT_GALLEONS', 'FLAVOR_NAVAL_RECON', 12 UNION ALL
SELECT 'UNIT_IRONCLADS', 'FLAVOR_NAVAL', 36 UNION ALL

SELECT 'UNIT_BALLISTAE', 'FLAVOR_OFFENSE', 8 UNION ALL
SELECT 'UNIT_BALLISTAE', 'FLAVOR_DEFENSE', 14 UNION ALL
SELECT 'UNIT_BALLISTAE', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_CATAPULTS', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_CATAPULTS', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_CATAPULTS', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_TREBUCHETS', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_TREBUCHETS', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_TREBUCHETS', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_BOMBARDS', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_BOMBARDS', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_BOMBARDS', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'FLAVOR_RANGED', 14 UNION ALL

SELECT 'UNIT_MOUNTED_ELEPHANTS', 'FLAVOR_OFFENSE', 20 UNION ALL
SELECT 'UNIT_MOUNTED_ELEPHANTS', 'FLAVOR_DEFENSE', 20 UNION ALL
SELECT 'UNIT_WAR_ELEPHANTS', 'FLAVOR_OFFENSE', 30 UNION ALL
SELECT 'UNIT_WAR_ELEPHANTS', 'FLAVOR_DEFENSE', 30 UNION ALL
SELECT 'UNIT_MUMAKIL', 'FLAVOR_OFFENSE', 40 UNION ALL
SELECT 'UNIT_MUMAKIL', 'FLAVOR_DEFENSE', 40 UNION ALL

SELECT 'UNIT_SETTLERS_MAN', 'FLAVOR_EXPANSION', 21 UNION ALL
SELECT 'UNIT_WORKERS_MAN', 'FLAVOR_TILE_IMPROVEMENT', 30 UNION ALL
SELECT 'UNIT_SLAVES_MAN', 'FLAVOR_TILE_IMPROVEMENT', 30 UNION ALL

SELECT 'UNIT_SCOUTS_MAN', 'FLAVOR_RECON', 14 UNION ALL
SELECT 'UNIT_TRACKERS_MAN', 'FLAVOR_RECON', 14 UNION ALL
SELECT 'UNIT_TRACKERS_MAN', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_TRACKERS_MAN', 'FLAVOR_DEFENSE', 10 UNION ALL
SELECT 'UNIT_RANGERS_MAN', 'FLAVOR_RECON', 18 UNION ALL
SELECT 'UNIT_RANGERS_MAN', 'FLAVOR_OFFENSE', 8 UNION ALL
SELECT 'UNIT_RANGERS_MAN', 'FLAVOR_DEFENSE', 12 UNION ALL

SELECT 'UNIT_WARRIORS_MAN', 'FLAVOR_RECON', 4 UNION ALL
SELECT 'UNIT_WARRIORS_MAN', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_WARRIORS_MAN', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_MAN', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_MAN', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_MAN', 'FLAVOR_OFFENSE', 18 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_MAN', 'FLAVOR_DEFENSE', 14 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_MAN', 'FLAVOR_OFFENSE', 24 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_MAN', 'FLAVOR_DEFENSE', 20 UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_MAN', 'FLAVOR_OFFENSE', 30 UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_MAN', 'FLAVOR_DEFENSE', 26 UNION ALL
SELECT 'UNIT_IMMORTALS_MAN', 'FLAVOR_OFFENSE', 36 UNION ALL
SELECT 'UNIT_IMMORTALS_MAN', 'FLAVOR_DEFENSE', 36 UNION ALL

SELECT 'UNIT_CHARIOTS_MAN', 'FLAVOR_OFFENSE', 8 UNION ALL
SELECT 'UNIT_CHARIOTS_MAN', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_CHARIOTS_MAN', 'FLAVOR_MOBILE', 4 UNION ALL
SELECT 'UNIT_HORSEMEN_MAN', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_HORSEMEN_MAN', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_HORSEMEN_MAN', 'FLAVOR_MOBILE', 8 UNION ALL
SELECT 'UNIT_EQUITES_MAN', 'FLAVOR_OFFENSE', 20 UNION ALL
SELECT 'UNIT_EQUITES_MAN', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_EQUITES_MAN', 'FLAVOR_MOBILE', 18 UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'FLAVOR_OFFENSE', 20 UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'FLAVOR_MOBILE', 14 UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'FLAVOR_OFFENSE', 24 UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'FLAVOR_MOBILE', 18 UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'FLAVOR_OFFENSE', 30 UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'FLAVOR_DEFENSE', 24 UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'FLAVOR_MOBILE', 30 UNION ALL

SELECT 'UNIT_ARCHERS_MAN', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_ARCHERS_MAN', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_ARCHERS_MAN', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_BOWMEN_MAN', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_BOWMEN_MAN', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_BOWMEN_MAN', 'FLAVOR_RANGED', 26 UNION ALL
SELECT 'UNIT_MARKSMEN_MAN', 'FLAVOR_OFFENSE', 16 UNION ALL
SELECT 'UNIT_MARKSMEN_MAN', 'FLAVOR_DEFENSE', 20 UNION ALL
SELECT 'UNIT_MARKSMEN_MAN', 'FLAVOR_RANGED', 36 UNION ALL
SELECT 'UNIT_CROSSBOWMEN_MAN', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_CROSSBOWMEN_MAN', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_CROSSBOWMEN_MAN', 'FLAVOR_RANGED', 26 UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_MAN', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_MAN', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_MAN', 'FLAVOR_RANGED', 23 UNION ALL

SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'FLAVOR_DEFENSE', 2 UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'FLAVOR_RANGED', 8 UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'FLAVOR_MOBILE', 2 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'FLAVOR_OFFENSE', 10 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'FLAVOR_MOBILE', 14 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'FLAVOR_OFFENSE', 14 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'FLAVOR_RANGED', 24 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'FLAVOR_MOBILE', 24 UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'FLAVOR_OFFENSE', 24 UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'FLAVOR_DEFENSE', 20 UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'FLAVOR_RANGED', 36 UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'FLAVOR_MOBILE', 36 UNION ALL


SELECT 'UNIT_SETTLERS_SIDHE', 'FLAVOR_EXPANSION', 21 UNION ALL
SELECT 'UNIT_WORKERS_SIDHE', 'FLAVOR_TILE_IMPROVEMENT', 30 UNION ALL
SELECT 'UNIT_SLAVES_SIDHE', 'FLAVOR_TILE_IMPROVEMENT', 30 UNION ALL

SELECT 'UNIT_SCOUTS_SIDHE', 'FLAVOR_RECON', 14 UNION ALL
SELECT 'UNIT_TRACKERS_SIDHE', 'FLAVOR_RECON', 14 UNION ALL
SELECT 'UNIT_TRACKERS_SIDHE', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_TRACKERS_SIDHE', 'FLAVOR_DEFENSE', 10 UNION ALL
SELECT 'UNIT_RANGERS_SIDHE', 'FLAVOR_RECON', 18 UNION ALL
SELECT 'UNIT_RANGERS_SIDHE', 'FLAVOR_OFFENSE', 8 UNION ALL
SELECT 'UNIT_RANGERS_SIDHE', 'FLAVOR_DEFENSE', 12 UNION ALL

SELECT 'UNIT_WARRIORS_SIDHE', 'FLAVOR_RECON', 4 UNION ALL
SELECT 'UNIT_WARRIORS_SIDHE', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_WARRIORS_SIDHE', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_SIDHE', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_SIDHE', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_SIDHE', 'FLAVOR_OFFENSE', 18 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_SIDHE', 'FLAVOR_DEFENSE', 14 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_SIDHE', 'FLAVOR_OFFENSE', 24 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_SIDHE', 'FLAVOR_DEFENSE', 20 UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_SIDHE', 'FLAVOR_OFFENSE', 30 UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_SIDHE', 'FLAVOR_DEFENSE', 26 UNION ALL
SELECT 'UNIT_IMMORTALS_SIDHE', 'FLAVOR_OFFENSE', 36 UNION ALL
SELECT 'UNIT_IMMORTALS_SIDHE', 'FLAVOR_DEFENSE', 36 UNION ALL

SELECT 'UNIT_CHARIOTS_SIDHE', 'FLAVOR_OFFENSE', 8 UNION ALL
SELECT 'UNIT_CHARIOTS_SIDHE', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_CHARIOTS_SIDHE', 'FLAVOR_MOBILE', 4 UNION ALL
SELECT 'UNIT_HORSEMEN_SIDHE', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_HORSEMEN_SIDHE', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_HORSEMEN_SIDHE', 'FLAVOR_MOBILE', 8 UNION ALL
SELECT 'UNIT_EQUITES_SIDHE', 'FLAVOR_OFFENSE', 20 UNION ALL
SELECT 'UNIT_EQUITES_SIDHE', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_EQUITES_SIDHE', 'FLAVOR_MOBILE', 18 UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'FLAVOR_OFFENSE', 20 UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'FLAVOR_MOBILE', 14 UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'FLAVOR_OFFENSE', 24 UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'FLAVOR_MOBILE', 18 UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'FLAVOR_OFFENSE', 30 UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'FLAVOR_DEFENSE', 24 UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'FLAVOR_MOBILE', 30 UNION ALL

SELECT 'UNIT_ARCHERS_SIDHE', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_ARCHERS_SIDHE', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_ARCHERS_SIDHE', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_BOWMEN_SIDHE', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_BOWMEN_SIDHE', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_BOWMEN_SIDHE', 'FLAVOR_RANGED', 26 UNION ALL
SELECT 'UNIT_MARKSMEN_SIDHE', 'FLAVOR_OFFENSE', 16 UNION ALL
SELECT 'UNIT_MARKSMEN_SIDHE', 'FLAVOR_DEFENSE', 20 UNION ALL
SELECT 'UNIT_MARKSMEN_SIDHE', 'FLAVOR_RANGED', 36 UNION ALL
SELECT 'UNIT_CROSSBOWMEN_SIDHE', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_CROSSBOWMEN_SIDHE', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_CROSSBOWMEN_SIDHE', 'FLAVOR_RANGED', 26 UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_SIDHE', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_SIDHE', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_SIDHE', 'FLAVOR_RANGED', 23 UNION ALL

SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'FLAVOR_DEFENSE', 2 UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'FLAVOR_RANGED', 8 UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'FLAVOR_MOBILE', 2 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'FLAVOR_OFFENSE', 10 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'FLAVOR_MOBILE', 14 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'FLAVOR_OFFENSE', 14 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'FLAVOR_RANGED', 24 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'FLAVOR_MOBILE', 24 UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'FLAVOR_OFFENSE', 24 UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'FLAVOR_DEFENSE', 20 UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'FLAVOR_RANGED', 36 UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'FLAVOR_MOBILE', 36 UNION ALL


SELECT 'UNIT_SETTLERS_ORC', 'FLAVOR_EXPANSION', 21 UNION ALL
SELECT 'UNIT_WORKERS_ORC', 'FLAVOR_TILE_IMPROVEMENT', 30 UNION ALL
SELECT 'UNIT_SLAVES_ORC', 'FLAVOR_TILE_IMPROVEMENT', 30 UNION ALL

SELECT 'UNIT_SCOUTS_ORC', 'FLAVOR_RECON', 14 UNION ALL
SELECT 'UNIT_TRACKERS_ORC', 'FLAVOR_RECON', 14 UNION ALL
SELECT 'UNIT_TRACKERS_ORC', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_TRACKERS_ORC', 'FLAVOR_DEFENSE', 10 UNION ALL
SELECT 'UNIT_RANGERS_ORC', 'FLAVOR_RECON', 18 UNION ALL
SELECT 'UNIT_RANGERS_ORC', 'FLAVOR_OFFENSE', 8 UNION ALL
SELECT 'UNIT_RANGERS_ORC', 'FLAVOR_DEFENSE', 12 UNION ALL

SELECT 'UNIT_WARRIORS_ORC', 'FLAVOR_RECON', 4 UNION ALL
SELECT 'UNIT_WARRIORS_ORC', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_WARRIORS_ORC', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_ORC', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_LIGHT_INFANTRY_ORC', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_ORC', 'FLAVOR_OFFENSE', 18 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_ORC', 'FLAVOR_DEFENSE', 14 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_ORC', 'FLAVOR_OFFENSE', 24 UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_ORC', 'FLAVOR_DEFENSE', 20 UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_ORC', 'FLAVOR_OFFENSE', 30 UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_ORC', 'FLAVOR_DEFENSE', 26 UNION ALL
SELECT 'UNIT_IMMORTALS_ORC', 'FLAVOR_OFFENSE', 36 UNION ALL
SELECT 'UNIT_IMMORTALS_ORC', 'FLAVOR_DEFENSE', 36 UNION ALL

SELECT 'UNIT_CHARIOTS_ORC', 'FLAVOR_OFFENSE', 8 UNION ALL
SELECT 'UNIT_CHARIOTS_ORC', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_CHARIOTS_ORC', 'FLAVOR_MOBILE', 4 UNION ALL
SELECT 'UNIT_HORSEMEN_ORC', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_HORSEMEN_ORC', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_HORSEMEN_ORC', 'FLAVOR_MOBILE', 8 UNION ALL
SELECT 'UNIT_EQUITES_ORC', 'FLAVOR_OFFENSE', 20 UNION ALL
SELECT 'UNIT_EQUITES_ORC', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_EQUITES_ORC', 'FLAVOR_MOBILE', 18 UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'FLAVOR_OFFENSE', 20 UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'FLAVOR_DEFENSE', 12 UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'FLAVOR_MOBILE', 14 UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'FLAVOR_OFFENSE', 24 UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'FLAVOR_MOBILE', 18 UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'FLAVOR_OFFENSE', 30 UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'FLAVOR_DEFENSE', 24 UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'FLAVOR_MOBILE', 30 UNION ALL

SELECT 'UNIT_ARCHERS_ORC', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_ARCHERS_ORC', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_ARCHERS_ORC', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_BOWMEN_ORC', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_BOWMEN_ORC', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_BOWMEN_ORC', 'FLAVOR_RANGED', 26 UNION ALL
SELECT 'UNIT_MARKSMEN_ORC', 'FLAVOR_OFFENSE', 16 UNION ALL
SELECT 'UNIT_MARKSMEN_ORC', 'FLAVOR_DEFENSE', 20 UNION ALL
SELECT 'UNIT_MARKSMEN_ORC', 'FLAVOR_RANGED', 36 UNION ALL
SELECT 'UNIT_CROSSBOWMEN_ORC', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_CROSSBOWMEN_ORC', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_CROSSBOWMEN_ORC', 'FLAVOR_RANGED', 26 UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_ORC', 'FLAVOR_OFFENSE', 12 UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_ORC', 'FLAVOR_DEFENSE', 16 UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_ORC', 'FLAVOR_RANGED', 23 UNION ALL

SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'FLAVOR_OFFENSE', 4 UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'FLAVOR_DEFENSE', 2 UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'FLAVOR_RANGED', 8 UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'FLAVOR_MOBILE', 2 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'FLAVOR_OFFENSE', 10 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'FLAVOR_RANGED', 14 UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'FLAVOR_MOBILE', 14 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'FLAVOR_OFFENSE', 14 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'FLAVOR_DEFENSE', 4 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'FLAVOR_RANGED', 24 UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'FLAVOR_MOBILE', 24 UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'FLAVOR_OFFENSE', 24 UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'FLAVOR_DEFENSE', 20 UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'FLAVOR_RANGED', 36 UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'FLAVOR_MOBILE', 36 ;


DELETE FROM Unit_ResourceQuantityRequirements;
INSERT INTO Unit_ResourceQuantityRequirements (UnitType, ResourceType)
SELECT 'UNIT_BIREMES', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_TRIREMES', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_TRIREMES', 'RESOURCE_COPPER' UNION ALL
SELECT 'UNIT_QUINQUEREMES', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_QUINQUEREMES', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_DROMONS', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_DROMONS', 'RESOURCE_NAPHTHA' UNION ALL
SELECT 'UNIT_CARAVELS', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_CARRACKS', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_CARRACKS', 'RESOURCE_IRON' UNION ALL
--SELECT 'UNIT_CARRACKS', 'RESOURCE_BLASTING_POWDER' UNION ALL
SELECT 'UNIT_GALLEONS', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_GALLEONS', 'RESOURCE_IRON' UNION ALL
--SELECT 'UNIT_GALLEONS', 'RESOURCE_BLASTING_POWDER' UNION ALL
SELECT 'UNIT_IRONCLADS', 'RESOURCE_IRON' UNION ALL
--SELECT 'UNIT_IRONCLADS', 'RESOURCE_BLASTING_POWDER' UNION ALL

SELECT 'UNIT_BALLISTAE', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_CATAPULTS', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_TREBUCHETS', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_FIRE_CATAPULTS', 'RESOURCE_NAPHTHA' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'RESOURCE_TIMBER' UNION ALL
SELECT 'UNIT_FIRE_TREBUCHETS', 'RESOURCE_NAPHTHA' UNION ALL
SELECT 'UNIT_BOMBARDS', 'RESOURCE_IRON' UNION ALL
--SELECT 'UNIT_BOMBARDS', 'RESOURCE_BLASTING_POWDER' UNION ALL
SELECT 'UNIT_GREAT_BOMBARDE', 'RESOURCE_IRON' UNION ALL
--SELECT 'UNIT_GREAT_BOMBARDE', 'RESOURCE_BLASTING_POWDER' UNION ALL

SELECT 'UNIT_MOUNTED_ELEPHANTS', 'RESOURCE_ELEPHANT' UNION ALL
SELECT 'UNIT_WAR_ELEPHANTS', 'RESOURCE_ELEPHANT' UNION ALL
SELECT 'UNIT_MUMAKIL', 'RESOURCE_ELEPHANT' UNION ALL

SELECT 'UNIT_LIGHT_INFANTRY_MAN', 'RESOURCE_COPPER' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_MAN', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_MAN', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_IMMORTALS_MAN', 'RESOURCE_MITHRIL' UNION ALL
SELECT 'UNIT_CHARIOTS_MAN', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_HORSEMEN_MAN', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_EQUITES_MAN', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_MAN', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_CATAPHRACTS_MAN', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'RESOURCE_MITHRIL' UNION ALL
SELECT 'UNIT_BOWMEN_MAN', 'RESOURCE_YEW' UNION ALL
SELECT 'UNIT_MARKSMEN_MAN', 'RESOURCE_YEW' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_MAN', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_MAN', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'RESOURCE_YEW' UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'RESOURCE_YEW' UNION ALL

SELECT 'UNIT_LIGHT_INFANTRY_SIDHE', 'RESOURCE_COPPER' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_SIDHE', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_SIDHE', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_IMMORTALS_SIDHE', 'RESOURCE_MITHRIL' UNION ALL
SELECT 'UNIT_CHARIOTS_SIDHE', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_HORSEMEN_SIDHE', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_EQUITES_SIDHE', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_SIDHE', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_CATAPHRACTS_SIDHE', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'RESOURCE_MITHRIL' UNION ALL
SELECT 'UNIT_BOWMEN_SIDHE', 'RESOURCE_YEW' UNION ALL
SELECT 'UNIT_MARKSMEN_SIDHE', 'RESOURCE_YEW' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_SIDHE', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'RESOURCE_YEW' UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'RESOURCE_YEW' UNION ALL

SELECT 'UNIT_LIGHT_INFANTRY_ORC', 'RESOURCE_COPPER' UNION ALL
SELECT 'UNIT_MEDIUM_INFANTRY_ORC', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_HEAVY_INFANTRY_ORC', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_IMMORTALS_ORC', 'RESOURCE_MITHRIL' UNION ALL
SELECT 'UNIT_CHARIOTS_ORC', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_HORSEMEN_ORC', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_EQUITES_ORC', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_ARMORED_CAVALRY_ORC', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_CATAPHRACTS_ORC', 'RESOURCE_IRON' UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'RESOURCE_MITHRIL' UNION ALL
SELECT 'UNIT_BOWMEN_ORC', 'RESOURCE_YEW' UNION ALL
SELECT 'UNIT_MARKSMEN_ORC', 'RESOURCE_YEW' UNION ALL
SELECT 'UNIT_CHARIOT_ARCHERS_ORC', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'RESOURCE_YEW' UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'RESOURCE_HORSE' UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'RESOURCE_YEW' ;

DELETE FROM Unit_TechTypes;		--and techs (main table determines where shown in tech tree)
INSERT INTO Unit_TechTypes (UnitType, TechType)			

SELECT 'UNIT_GREAT_BOMBARDE', 'TECH_CHEMISTRY' UNION ALL
SELECT 'UNIT_BOMBARDS', 'TECH_CHEMISTRY' UNION ALL
SELECT 'UNIT_CARRACKS', 'TECH_CHEMISTRY' UNION ALL
SELECT 'UNIT_GALLEONS', 'TECH_CHEMISTRY' UNION ALL
SELECT 'UNIT_IRONCLADS', 'TECH_CHEMISTRY' UNION ALL
SELECT 'UNIT_CARAVELS', 'TECH_SHIP_BUILDING' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_MAN', 'TECH_CHEMISTRY' UNION ALL

SELECT 'UNIT_HORSE_ARCHERS_MAN', 'TECH_ARCHERY' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_MAN', 'TECH_BOWYERS' UNION ALL
SELECT 'UNIT_SAGITARII_MAN', 'TECH_MARKSMANSHIP' UNION ALL
SELECT 'UNIT_CLIBANARII_MAN', 'TECH_WAR_HORSES' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_SIDHE', 'TECH_CHEMISTRY' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_SIDHE', 'TECH_ARCHERY' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_SIDHE', 'TECH_BOWYERS' UNION ALL
SELECT 'UNIT_SAGITARII_SIDHE', 'TECH_MARKSMANSHIP' UNION ALL
SELECT 'UNIT_CLIBANARII_SIDHE', 'TECH_WAR_HORSES' UNION ALL
SELECT 'UNIT_ARQUEBUSSMEN_ORC', 'TECH_CHEMISTRY' UNION ALL
SELECT 'UNIT_HORSE_ARCHERS_ORC', 'TECH_ARCHERY' UNION ALL
SELECT 'UNIT_BOWED_CAVALRY_ORC', 'TECH_BOWYERS' UNION ALL
SELECT 'UNIT_SAGITARII_ORC', 'TECH_MARKSMANSHIP' UNION ALL
SELECT 'UNIT_CLIBANARII_ORC', 'TECH_WAR_HORSES' ;


--fixinator
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM UnitClasses ORDER BY ID;
UPDATE UnitClasses SET ID =	( SELECT IDRemapper.id-1 FROM IDRemapper WHERE UnitClasses.Type = IDRemapper.Type);
DROP TABLE IDRemapper;
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM Units ORDER BY ID;
UPDATE Units SET ID =	( SELECT IDRemapper.id-1 FROM IDRemapper WHERE Units.Type = IDRemapper.Type);
DROP TABLE IDRemapper;


INSERT INTO EaDebugTableCheck(FileName) SELECT 'Units.sql';
