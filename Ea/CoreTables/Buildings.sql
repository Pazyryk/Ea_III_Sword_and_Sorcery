-- Contains Buildings, BuildingClasses and subtables

-------------------------------------------------------------------------------
-- Buildings
-------------------------------------------------------------------------------


DELETE FROM Buildings;
ALTER TABLE Buildings ADD COLUMN 'EaPrereqPolicy' TEXT DEFAULT NULL;
ALTER TABLE Buildings ADD COLUMN 'EaPrereqOrPolicy' TEXT DEFAULT NULL;
ALTER TABLE Buildings ADD COLUMN 'EaPrereqOrPolicy2' TEXT DEFAULT NULL;
ALTER TABLE Buildings ADD COLUMN 'EaOccupationUnhapReduction'  INTEGER DEFAULT 0;		-- % reduction occupation unhappiness
ALTER TABLE Buildings ADD COLUMN 'EaGreatPersonBuild' TEXT DEFAULT NULL;
ALTER TABLE Buildings ADD COLUMN 'EaHealth' INTEGER DEFAULT 0;
ALTER TABLE Buildings ADD COLUMN 'EaHidden' TEXT DEFAULT NULL;		--not used yet (text will allow some to be revealed under specific circumstances)
ALTER TABLE Buildings ADD COLUMN 'EaProhibitSell' BOOLEAN DEFAULT NULL;
ALTER TABLE Buildings ADD COLUMN 'EaSpecial' TEXT DEFAULT NULL;		--Arcane, Religious

-- 1st available
INSERT INTO Buildings (Type,			Cost,	FoodKept,	NeverCapture,	ArtDefineTag,				IconAtlas,				PortraitIndex) VALUES
('BUILDING_MONUMENT',					80,		0,			1,				'MONUMENT',					'BW_ATLAS_1',			21		),
('BUILDING_WARRENS',					150,	10,			1,				'ART_DEF_BUILDING_FORGE',	'NEW_BLDG_ATLAS2_DLC',	1		);
-- early specialist
INSERT INTO Buildings (Type,			Cost,	GoldMaintenance,	PrereqTech,					EaPrereqPolicy,		EaSpecial,		Happiness,	SpecialistType,			SpecialistCount,	NeverCapture,	ArtDefineTag,				IconAtlas,				PortraitIndex) VALUES
('BUILDING_MARKETPLACE',				150,	0,					'TECH_CURRENCY',			NULL,				NULL,			0,			'SPECIALIST_TRADER',	1,					0,				'ART_DEF_BUILDING_MARKET',	'BW_ATLAS_1',			16	),
('BUILDING_LIBRARY',					150,	1,					'TECH_WRITING',				NULL,				NULL,			0,			'SPECIALIST_SCRIBE',	1,					0,				'ART_DEF_BUILDING_LIBRARY',	'BW_ATLAS_1',			11	),
('BUILDING_AMPHITHEATER',				150,	1,					'TECH_DRAMA',				NULL,				NULL,			1,			'SPECIALIST_ARTISAN',	1,					0,				'COLESSEUM',				'EXPANSION_BW_ATLAS_1',	0	),
('BUILDING_WORKSHOP',					150,	1,					'TECH_MATHEMATICS',			NULL,				NULL,			0,			'SPECIALIST_SMITH',		1,					0,				'ART_DEF_BUILDING_FORGE',	'BW_ATLAS_1',			28	),
('BUILDING_FORGE',						150,	1,					'TECH_BRONZE_WORKING',		NULL,				NULL,			0,			'SPECIALIST_SMITH',		1,					0,				'ART_DEF_BUILDING_FORGE',	'BW_ATLAS_1',			2	),
('BUILDING_SHRINE',						150,	1,					NULL,						'POLICY_PANTHEISM',	'Religious',	0,			'SPECIALIST_DISCIPLE',	1,					1,				'TEMPLE',					'EXPANSION_BW_ATLAS_1',	9	),
('BUILDING_MAGE_SCHOOL',				150,	1,					'TECH_THAUMATURGY',			NULL,				'Arcane',		0,			'SPECIALIST_ADEPT',		1,					1,				'TEMPLE',					'EXPANSION_BW_ATLAS_1',	9	),
('BUILDING_PHARMAKEIA',					150,	1,					'TECH_MALEFICIUM',			NULL,				'Arcane',		0,			'SPECIALIST_ADEPT',		1,					1,				'TEMPLE',					'EXPANSION_BW_ATLAS_1',	9	);

-- early resource
INSERT INTO Buildings (Type,			Cost,	GoldMaintenance,	PrereqTech,					Happiness,	NeverCapture,	ArtDefineTag,				IconAtlas,						PortraitIndex,	DisplayPosition) VALUES
('BUILDING_SMOKEHOUSE',					200,	1,					'TECH_HUNTING',				0,			0,				'ART_DEF_BUILDING_FORGE',	'BW_ATLAS_1',					57,				0	),
('BUILDING_TANNERY',					200,	1,					'TECH_ANIMAL_INDUSTRY',		0,			0,				'ART_DEF_BUILDING_FORGE',	'BW_ATLAS_1',					57,				0	),
('BUILDING_IVORYWORKS',					200,	1,					'TECH_HUNTING',				0,			0,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',					24,				0	),
('BUILDING_GRANARY',					200,	1,					'TECH_AGRICULTURE',			0,			0,				'ART_DEF_BUILDING_GRANARY',	'BW_ATLAS_1',					0,				0	),
('BUILDING_SALTWORKS',					200,	1,					'TECH_MINING',				0,			0,				'ART_DEF_BUILDING_FORGE',	'NEW_BLDG_ATLAS2_DLC',			1,				0	),
('BUILDING_STABLE',						200,	1,					'TECH_HORSEBACK_RIDING',	0,			0,				'ART_DEF_BUILDING_STABLE',	'BW_ATLAS_1',					7,				0	),
('BUILDING_ELEPHANT_STOCKADE',			200,	1,					'TECH_ELEPHANT_LABOR',		0,			0,				'ART_DEF_BUILDING_GARDEN',	'EXPANSION2_BUILDING_ATLAS2',	0,				0	),
('BUILDING_HUNTING_LODGE',				200,	0,					'TECH_TRACKING_TRAPPING',	0,			0,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',					24,				0	),
('BUILDING_ABATTOIR',					200,	1,					'TECH_ANIMAL_HUSBANDRY',	0,			0,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',					24,				0	),
('BUILDING_KNACKERY',					200,	1,					'TECH_ANIMAL_INDUSTRY',		0,			0,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',					24,				0	),
('BUILDING_HARBOR',						200,	0,					'TECH_SAILING',				0,			0,				'HARBOR',					'BW_ATLAS_1',					26,				16	),
('BUILDING_TIMBERYARD',					200,	1,					'TECH_ALLOW_TIMBER_TRADE',	0,			0,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',					24,				0	),
('BUILDING_COTTON_GIN',					200,	1,					'TECH_WEAVING',				0,			0,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',					24,				0	),
('BUILDING_WINERY',						200,	1,					'TECH_OENOLOGY',			0,			0,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',					24,				0	),
('BUILDING_BREWERY',					200,	1,					'TECH_ZYMURGY',				0,			0,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',					24,				0	),
('BUILDING_FAIR',						200,	1,					'TECH_DRAMA',				1,			0,				'ART_DEF_BUILDING_CIRCUS',	'BW_ATLAS_1',					44,				0	),
('BUILDING_MINT',						200,	0,					'TECH_COINAGE',				0,			0,				'ART_DEF_BUILDING_BANK',	'BW_ATLAS_1',					34,				0	),
('BUILDING_STONE_WORKS',				200,	1,					'TECH_MASONRY',				0,			0,				'ART_DEF_BUILDING_FORGE',	'NEW_BLDG_ATLAS2_DLC',			1,				0	);

-- early policy dependent
INSERT INTO Buildings (Type,			Cost,	GoldMaintenance,	PrereqTech,					EaPrereqPolicy,				EaSpecial,		Happiness,	EaOccupationUnhapReduction,	NeverCapture,	ArtDefineTag,				IconAtlas,				PortraitIndex,	DisplayPosition) VALUES
('BUILDING_MOUNDS',						200,	0,					NULL,						'POLICY_PANTHEISM',			'Religious',	0,			0,							1,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',			24,				0	),
('BUILDING_GALLOWS',					200,	1,					NULL,						'POLICY_SLAVERY',			NULL,			0,			10,							1,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',			24,				0	),
('BUILDING_DEBTORS_COURT',				200,	0,					'TECH_CURRENCY',			'POLICY_DEBT_BONDAGE',		NULL,			0,			0,							1,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',			24,				0	),
('BUILDING_GOVERNORS_COMPOUND',			200,	0,					'TECH_PHILOSOPHY',			'POLICY_MILITARISM',		NULL,			0,			40,							1,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',			24,				0	),
('BUILDING_TRIBAL_COUNCIL',				200,	1,					NULL,						'POLICY_TRADITION',			NULL,			0,			0,							1,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',			24,				0	),
('BUILDING_FOREFATHERS_STATUE',			200,	1,					NULL,						'POLICY_TRADITION',			NULL,			0,			0,							1,				'ART_DEF_BUILDING_GARDEN',	'BW_ATLAS_1',			24,				0	),
('BUILDING_JEWELLER',					350,	1,					'TECH_CURRENCY',			'POLICY_TRADITION',			NULL,			1,			0,							1,				'ART_DEF_BUILDING_BARRACKS','BW_ATLAS_1',			61,				0	);

-- other early
INSERT INTO Buildings (Type,			Cost,	GoldMaintenance,	PrereqTech,					NeverCapture,	ArtDefineTag,				IconAtlas,				PortraitIndex,	DisplayPosition) VALUES
('BUILDING_RIVER_DOCK',					200,	0,					'TECH_FISHING',				0,				'MONUMENT',					'BW_ATLAS_1',			26,				0	),
('BUILDING_LIGHTHOUSE',					200,	0,					'TECH_NAVIGATION',			0,				'LIGHTHOUSE',				'BW_ATLAS_1',			36,				8	),
('BUILDING_WATERMILL',					200,	1,					'TECH_MILLING',				0,				'ART_DEF_BUILDING_WATERMILL','BW_ATLAS_1',			29,				0	),
('BUILDING_WINDMILL',					200,	1,					'TECH_MILLING',				0,				'ART_DEF_BUILDING_FORGE',	'BW_ATLAS_1',			1,				0	),
('BUILDING_SILOS',						200,	1,					'TECH_CALENDAR',			0,				'ART_DEF_BUILDING_GRANARY',	'BW_ATLAS_1',			0,				0	),
('BUILDING_COURTHOUSE',					200,	1,					'TECH_PHILOSOPHY',			1,				'COURTHOUSE',				'BW_ATLAS_1',			63,				0	),
('BUILDING_WALLS',						200,	1,					'TECH_MASONRY',				0,				'ART_DEF_BUILDING_WALLS',	'BW_ATLAS_1',			32,				0	);

-- advanced specialist
INSERT INTO Buildings (Type,			Cost,	GoldMaintenance,	PrereqTech,					EaPrereqPolicy,				EaSpecial,		Happiness,	SpecialistType,			SpecialistCount,	NeverCapture,	ArtDefineTag,					IconAtlas,				PortraitIndex,	DisplayPosition) VALUES
('BUILDING_SMITHS_GUILD',				200,	1,					NULL,						'POLICY_GUILDS',			NULL,			0,			'SPECIALIST_SMITH',		1,					1,				'COURTHOUSE',					'BW_ATLAS_1',			63,				0		),
('BUILDING_TRADERS_GUILD',				200,	1,					NULL,						'POLICY_GUILDS',			NULL,			0,			'SPECIALIST_TRADER',	1,					1,				'COURTHOUSE',					'BW_ATLAS_1',			63,				0		),
('BUILDING_SCRIBES_GUILD',				200,	1,					NULL,						'POLICY_GUILDS',			NULL,			0,			'SPECIALIST_SCRIBE',	1,					1,				'COURTHOUSE',					'BW_ATLAS_1',			63,				0		),
('BUILDING_ARTISANS_GUILD',				200,	1,					NULL,						'POLICY_GUILDS',			NULL,			0,			'SPECIALIST_ARTISAN',	1,					1,				'COURTHOUSE',					'BW_ATLAS_1',			63,				0		),
('BUILDING_DISCIPLES_GUILD',			200,	1,					NULL,						'POLICY_GUILDS',			'Religious',	0,			'SPECIALIST_DISCIPLE',	1,					1,				'COURTHOUSE',					'BW_ATLAS_1',			63,				0		),
('BUILDING_ADEPTS_GUILD',				200,	1,					'TECH_THAUMATURGY',			'POLICY_GUILDS',			'Arcane',		0,			'SPECIALIST_ADEPT',		1,					1,				'COURTHOUSE',					'BW_ATLAS_1',			63,				0		),
('BUILDING_APOTHECARY',					200,	1,					NULL,						'POLICY_ARCANE_TRADITION',	'Arcane',		0,			'SPECIALIST_ADEPT',		1,					0,				'ART_DEF_BUILDING_GARDEN',		'BW_ATLAS_1',			24,				0		),
('BUILDING_FACTORY',					400,	1,					'TECH_MACHINERY',			NULL,						NULL,			0,			'SPECIALIST_SMITH',		1,					0,				'ART_DEF_BUILDING_FACTORY',		'BW_ATLAS_1',			3,				0		),
('BUILDING_MONASTIC_SCHOOL',			200,	1,					'TECH_DIVINE_VITALISM',		NULL,						'Religious',	0,			'SPECIALIST_SCRIBE',	1,					1,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			61,				0		),
('BUILDING_UNIVERSITY',					300,	1,					'TECH_LOGIC',				NULL,						NULL,			0,			'SPECIALIST_SCRIBE',	1,					0,				'ART_DEF_BUILDING_UNIVERSITY',	'BW_ATLAS_1',			13,				0		),
('BUILDING_BANK',						300,	1,					'TECH_BANKING',				NULL,						NULL,			0,			'SPECIALIST_TRADER',	1,					1,				'ART_DEF_BUILDING_BANK',		'BW_ATLAS_1',			18,				0		),
('BUILDING_LABORATORY',					400,	1,					'TECH_CHEMISTRY',			NULL,						NULL,			0,			'SPECIALIST_SCRIBE',	1,					0,				'ART_DEF_BUILDING_LABORATORY',	'BW_ATLAS_1',			15,				0		),
('BUILDING_INTELLIGENT_ARCHIVE',		400,	1,					'TECH_SEMIOTICS',			NULL,						NULL,			0,			'SPECIALIST_SCRIBE',	1,					0,				'ART_DEF_BUILDING_UNIVERSITY',	'BW_ATLAS_1',			13,				0		),
('BUILDING_THEATRE',					300,	1,					'TECH_LITERATURE',			NULL,						NULL,			1,			'SPECIALIST_ARTISAN',	1,					0,				'THEATRE',						'BW_ATLAS_1',			20,				0		),
('BUILDING_OPERA_HOUSE',				300,	1,					'TECH_MUSIC',				NULL,						NULL,			1,			'SPECIALIST_ARTISAN',	1,					0,				'OPERA_HOUSE',					'BW_ATLAS_1',			49,				0		),
('BUILDING_MONASTERY',					400,	1,					'TECH_DIVINE_LITURGY',		NULL,						'Religious',	0,			'SPECIALIST_DISCIPLE',	0,					0,				'MONASTERY',					'BW_ATLAS_1',			38,				0		),
('BUILDING_MUSEUM',						400,	1,					'TECH_AESTHETICS',			NULL,						NULL,			1,			'SPECIALIST_ARTISAN',	1,					0,				'MUSEUM',						'BW_ATLAS_1',			22,				0		);

-- advanced resource
INSERT INTO Buildings (Type,			Cost,	GoldMaintenance,	PrereqTech,					EaSpecial,		NeverCapture,	ArtDefineTag,					IconAtlas,				PortraitIndex,	DisplayPosition) VALUES
('BUILDING_BREEDING_PEN',				300,	1,					'TECH_ANIMAL_BREEDING',		NULL,			0,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			5,				0		),
('BUILDING_BOWYER',						300,	1,					'TECH_BOWYERS',				NULL,			0,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			5,				0		),
('BUILDING_ROASTING_FURNACE',			300,	1,					'TECH_ALCHEMY',				NULL,			0,				'ART_DEF_BUILDING_LABORATORY',	'BW_ATLAS_1',			15,				0		),
('BUILDING_CHRYSOPOEIA_REACTOR',		300,	1,					'TECH_ALCHEMY',				'Arcane',		0,				'ART_DEF_BUILDING_LABORATORY',	'BW_ATLAS_1',			15,				0		),
('BUILDING_ARGENTOPOEIA_REACTOR',		300,	1,					'TECH_ALCHEMY',				'Arcane',		0,				'ART_DEF_BUILDING_LABORATORY',	'BW_ATLAS_1',			15,				0		),
('BUILDING_DISTILLERY',					300,	1,					'TECH_CHEMISTRY',			NULL,			0,				'ART_DEF_BUILDING_LABORATORY',	'BW_ATLAS_1',			15,				0		),
('BUILDING_PORT',						400,	0,					'TECH_NAVIGATION',			NULL,			0,				'ART_DEF_BUILDING_SEAPORT',		'BW_ATLAS_1',			48,				0		),
('BUILDING_WHALERY',					300,	0,					'TECH_WHALING',				NULL,			0,				'ART_DEF_BUILDING_SEAPORT',		'BW_ATLAS_1',			48,				0		),
('BUILDING_ARMORY',						300,	1,					'TECH_IRON_WORKING',		NULL,			0,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			6,				0		),
('BUILDING_ARSENAL',					400,	1,					'TECH_STEEL_WORKING',		NULL,			0,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			6,				0		),
('BUILDING_TEXTILE_MILL',				400,	1,					'TECH_FINE_TEXTILES',		NULL,			0,				'ART_DEF_BUILDING_FACTORY',		'BW_ATLAS_1',			3,				0		);

-- advanced policy dependent
INSERT INTO Buildings (Type,			Cost,	GoldMaintenance,	PrereqTech,					EaPrereqPolicy,					NeverCapture,	ArtDefineTag,					IconAtlas,				PortraitIndex,	DisplayPosition) VALUES
('BUILDING_SLAVE_MARKET',				250,	0,					'TECH_CURRENCY',			'POLICY_SLAVE_TRADE',			1,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			61,				0		),
('BUILDING_SLAVE_KNACKERY',				250,	1,					NULL,						'POLICY_SLAVE_CASTES',			1,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			61,				0		),
('BUILDING_SLAVE_STOCKADE',				250,	1,					NULL,						'POLICY_SLAVE_RAIDERS',			1,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			61,				0		),
('BUILDING_SLAVE_BREEDING_PEN',			350,	1,					NULL,						'POLICY_SLAVE_BREEDING',		1,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			61,				0		),
('BUILDING_INTERNMENT_CAMP',			400,	1,					NULL,						'POLICY_SERVI_AETERNAM',		1,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			61,				0		),
('BUILDING_BARRACKS',					250,	1,					'TECH_BRONZE_WORKING',		'POLICY_DISCIPLINE',			1,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			5,				0		),
('BUILDING_PAPERMILL',					300,	1,					'TECH_LITERATURE',			'POLICY_SCHOLASTICISM',			1,				'ART_DEF_BUILDING_PAPER_MAKER',	'BW_ATLAS_1',			59,				0		),
('BUILDING_KILN',						350,	1,					'TECH_CONSTRUCTION',		'POLICY_CRAFTING',				1,				'ART_DEF_BUILDING_BARRACKS',	'BW_ATLAS_1',			61,				0		);

-- advanced other
INSERT INTO Buildings (Type,			Cost,	GoldMaintenance,	PrereqTech,					Happiness,	NeverCapture,	ArtDefineTag,					IconAtlas,						PortraitIndex,	DisplayPosition) VALUES
('BUILDING_STRONGHOLD',					300,	1,					'TECH_CONSTRUCTION',		0,			0,				'ART_DEF_BUILDING_CASTLE',		'BW_ATLAS_1',					39,				0		),
('BUILDING_CASTLE',						300,	1,					'TECH_CONSTRUCTION',		0,			0,				'CASTLE',						'BW_ATLAS_1',					33,				1		),
('BUILDING_AQUEDUCT',					300,	1,					'TECH_CONSTRUCTION',		0,			0,				'ART_DEF_BUILDING_HOSPITAL',	'NEW_BLDG_ATLAS2_DLC',			0,				0		),
('BUILDING_WAREHOUSES',					300,	1,					'TECH_CONSTRUCTION',		0,			0,				'ART_DEF_BUILDING_FORGE',		'BW_ATLAS_1',					28,				0		),
('BUILDING_PUBLIC_BATHS',				300,	1,					'TECH_SANITATION',			1,			0,				'ART_DEF_BUILDING_HOSPITAL',	'EXPANSION2_BUILDING_ATLAS',	11,				0		),
('BUILDING_COLOSSEUM',					400,	1,					'TECH_ENGINEERING',			2,			0,				'COLESSEUM',					'BW_ATLAS_1',					23,				2		),
('BUILDING_SEWERS',						400,	1,					'TECH_ENGINEERING',			0,			0,				'ART_DEF_BUILDING_HOSPITAL',	'NEW_BLDG_ATLAS2_DLC',			0,				0		),
('BUILDING_PRINTING_PRESS',				400,	1,					'TECH_MACHINERY',			0,			0,				'ART_DEF_BUILDING_PAPER_MAKER',	'BW_ATLAS_1',					59,				0		),
('BUILDING_OBSERVATORY',				300,	1,					'TECH_ASTRONOMY',			0,			0,				'ART_DEF_BUILDING_OBSERVATORY',	'BW_ATLAS_1',					42,				0		),
('BUILDING_CHAMBER_THOUGHT',			400,	1,					'TECH_METAPHYSICS',			0,			0,				'ART_DEF_BUILDING_OBSERVATORY',	'BW_ATLAS_1',					42,				0		),
('BUILDING_CONSCIOUSNESS_ENGINE',		500,	1,					'TECH_TRANSCENDENTAL_THOUGHT',0,		0,				'ART_DEF_BUILDING_OBSERVATORY',	'BW_ATLAS_1',					42,				0		),
('BUILDING_SHIPYARD',					300,	1,					'TECH_SHIP_BUILDING',		0,			0,				'ART_DEF_BUILDING_SEAPORT',		'BW_ATLAS_1',					48,				0		),
('BUILDING_HOSPITAL',					500,	1,					'TECH_MEDICINE',			0,			0,				'ART_DEF_BUILDING_HOSPITAL',	'BW_ATLAS_1',					45,				0		),
('BUILDING_DEEP_FARMS',					300,	0,					'TECH_UNDERDARK_PATHS',		0,			1,				'ART_DEF_BUILDING_FORGE',		'NEW_BLDG_ATLAS2_DLC',			1,				0		),
('BUILDING_FLOATING_GARDENS',			200,	0,					NULL,						0,			1,				'ART_DEF_BUILDING_FORGE',		'NEW_BLDG_ATLAS2_DLC',			1,				0		);

-- minor GP builds
INSERT INTO Buildings (Type,			Cost,	Happiness,	NeverCapture,	ArtDefineTag,							IconAtlas,				PortraitIndex,	DisplayPosition) VALUES
('BUILDING_FOUNDRY',					-1,		0,			1,				'ART_DEF_BUILDING_FORGE',				'NEW_BLDG_ATLAS2_DLC',	1,				0		),
('BUILDING_FESTIVAL',					-1,		0,			1,				'ART_DEF_BUILDING_CIRCUS',				'BW_ATLAS_1',			44,				0		);

-- major GP builds  (multiple instances used to tailor effect to GP mod)
INSERT INTO Buildings (Type,			Cost,	Happiness,	NeverCapture,	ArtDefineTag,							IconAtlas,				PortraitIndex,	DisplayPosition) VALUES
('BUILDING_CATHEDRAL',					-1,		0,			1,				'TEMPLE',								'BW_ATLAS_1',			37,				0		),
('BUILDING_TRADE_HOUSE',				-1,		0,			1,				'ART_DEF_BUILDING_NATIONAL_TREASURY',	'NEW_BLDG_ATLAS_DLC',	1,				0		),
('BUILDING_MILITARY_ACADEMY',			-1,		0,			1,				'ART_DEF_BUILDING_MILITARY_ACADEMY',	'BW_ATLAS_1',			8,				0		),
('BUILDING_NAVAL_ACADEMY',				-1,		0,			1,				'ART_DEF_BUILDING_SEAPORT',				'BW_ATLAS_1',			48,				0		),
('BUILDING_NATIONAL_TREASURY',			-1,		0,			1,				'ART_DEF_BUILDING_NATIONAL_TREASURY',	'NEW_BLDG_ATLAS_DLC',	1,				0		);

-- hidden (utility function)
INSERT INTO Buildings (Type,			Cost,	NeverCapture,	ArtDefineTag,	IconAtlas,		PortraitIndex,	FreeStartEra,	EaHidden) VALUES
('BUILDING_MAN',						-1,		0,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),	--Always capture so city race conserved
('BUILDING_SIDHE',						-1,		0,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_HELDEOFOL',					-1,		0,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_TIMBERYARD_ALLOW',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_WINDMILL_ALLOW',				-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_RACIAL_DISHARMONY',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_CULT_LEAVES_1F1C',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_CULT_CAHRA_1F',				-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_PLUS_1_UNHAPPINESS',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_PLUS_1_LOCAL_HAPPY',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_TRADE_PLUS_1_GOLD',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_PLUS_1_LAND_XP',				-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_PLUS_1_SEA_XP',				-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_REMOTE_RES_1_FOOD',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_REMOTE_RES_1_PRODUCTION',	-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_REMOTE_RES_1_GOLD',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_ANRA_FOLLOWER',				-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_CULT_OF_EPONA_FOLLOWER',		-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_CULT_OF_BAKKHEIA_FOLLOWER',	-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),

('BUILDING_IKKOS',						-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_AB',							-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_NEITH',						-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_MAMONAS',					-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),

('BUILDING_1C_ANIMAL_RESOURCES',		-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_1C_PLANT_RESOURCES',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_1C_EARTH_RESOURCES',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),

('BUILDING_1C_VARIOUS_RESOURCES',		-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),

('BUILDING_KOLOSSOS_MOD',				-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_MEGALOS_FAROS_MOD',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_HANGING_GARDENS_MOD',		-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_UUC_YABNAL_MOD',				-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_THE_LONG_WALL_MOD',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_CLOG_MOR_MOD',				-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_DA_BAOEN_SI_MOD',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),

('BUILDING_HUNTING_LODGE_ENABLE',		-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_PORT_ENABLE',				-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_WHALERY_ENABLE',				-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_FLOATING_GARDENS_ENABLE',	-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	),
('BUILDING_DEEP_FARMS_ENABLE',			-1,		1,				'MONUMENT',		'BW_ATLAS_1',	1,				NULL,			'Util'	);

-- palaces
INSERT INTO Buildings (Type,			Cost,	PrereqTech,		EaGreatPersonBuild,	Happiness,	NeverCapture,	ArtDefineTag,	IconAtlas,		PortraitIndex,	DisplayPosition,	ArtInfoCulturalVariation,	Capital	) VALUES
('BUILDING_PALACE',						0,		NULL,			NULL,				0,			1,				'PALACE',		'BW_ATLAS_1',	19,				32,					1,							1		);

--Build out the Buildings table for dependent strings
UPDATE Buildings SET Description = 'TXT_KEY_EA_' || Type;
UPDATE Buildings SET Help = Description || '_HELP', Civilopedia = Description || '_PEDIA', Strategy = Description || '_STRATEGY' WHERE EaHidden IS NULL;


-- city wonders
INSERT INTO Buildings (Type,			Cost,	PrereqTech,		EaGreatPersonBuild,	Happiness,	NeverCapture,	ConquestProb,	ArtDefineTag,					IconAtlas,		PortraitIndex,	DisplayPosition	) VALUES
('BUILDING_KOLOSSOS',					300,	NULL,			'Engineer',			0,			0,				100,			'MONUMENT',						'BW_ATLAS_2',	4,				0				),
('BUILDING_MEGALOS_FAROS',				300,	NULL,			'Engineer',			0,			0,				100,			'MONUMENT',						'BW_ATLAS_2',	5,				0				),
('BUILDING_HANGING_GARDENS',			300,	NULL,			'Engineer',			0,			0,				100,			'MONUMENT',						'BW_ATLAS_2',	3,				0				),
('BUILDING_UUC_YABNAL',					300,	NULL,			'Engineer',			0,			0,				100,			'MONUMENT',						'BW_ATLAS_2',	12,				0				),
('BUILDING_THE_LONG_WALL',				300,	NULL,			'Engineer',			0,			0,				100,			'MONUMENT',						'BW_ATLAS_2',	7,				0				),
('BUILDING_CLOG_MOR',					300,	NULL,			'Engineer',			0,			0,				100,			'MONUMENT',						'BW_ATLAS_2',	19,				0				),
('BUILDING_DA_BAOEN_SI',				300,	NULL,			'Engineer',			0,			0,				100,			'MONUMENT',						'BW_ATLAS_2',	16,				0				),
-- plot wonders
('BUILDING_MOD_STANHENCG',				-1,		NULL,			'Druid',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_2',	2,				0				),
('BUILDING_PYRAMID',					-1,		NULL,			'Engineer',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_2',	0,				0				),
('BUILDING_GREAT_LIBRARY',				-1,		NULL,			'Sage',				0,			1,				0,				'MONUMENT',						'BW_ATLAS_2',	1,				0				),
('BUILDING_ACADEMY_PHILOSOPHY',			-1,		NULL,			'Sage',				0,			1,				0,				'MONUMENT',						'BW_ATLAS_2',	1,				0				),
('BUILDING_ACADEMY_LOGIC',				-1,		NULL,			'Sage',				0,			1,				0,				'MONUMENT',						'BW_ATLAS_2',	1,				0				),
('BUILDING_ACADEMY_SEMIOTICS',			-1,		NULL,			'Sage',				0,			1,				0,				'MONUMENT',						'BW_ATLAS_2',	1,				0				),
('BUILDING_ACADEMY_METAPHYSICS',		-1,		NULL,			'Sage',				0,			1,				0,				'MONUMENT',						'BW_ATLAS_2',	1,				0				),
('BUILDING_ACADEMY_TRANS_THOUGHT',		-1,		NULL,			'Sage',				0,			1,				0,				'MONUMENT',						'BW_ATLAS_2',	1,				0				),

('BUILDING_MOD_ARCANE_TOWER',			-1,		NULL,			'Thaumaturge',		0,			1,				0,				'MONUMENT',						'BW_ATLAS_2',	1,				0				),
('BUILDING_TEMPLE_AZZANDARA_1',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AZZANDARA_2',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AZZANDARA_3',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AZZANDARA_4',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AZZANDARA_5',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AZZANDARA_6',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AZZANDARA_7',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AHRIMAN_1',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AHRIMAN_2',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AHRIMAN_3',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AHRIMAN_4',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AHRIMAN_5',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AHRIMAN_6',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AHRIMAN_7',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AHRIMAN_8',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				),
('BUILDING_TEMPLE_AHRIMAN_9',			-1,		NULL,			'Devout',			0,			1,				0,				'MONUMENT',						'BW_ATLAS_1',	37,				0				);

--Build out Wonders for dependent strings (use existing wonder txt keys)
UPDATE Buildings SET Description = REPLACE(Type, 'BUILDING_', 'TXT_KEY_EA_WONDER_') WHERE Description IS NULL;
UPDATE Buildings SET Help = Description || '_HELP', Civilopedia = Description || '_PEDIA', Strategy = Description || '_STRATEGY' WHERE EaHidden IS NULL AND Civilopedia IS NULL;


UPDATE Buildings SET Help = 'TXT_KEY_EA_NOTSHOWN', Civilopedia = 'TXT_KEY_EA_NOTSHOWN', Strategy = 'TXT_KEY_EA_NOTSHOWN' WHERE EaHidden IS NOT NULL;

--BuildingClass
UPDATE Buildings SET BuildingClass = REPLACE(Type, 'BUILDING_', 'BUILDINGCLASS_');
UPDATE Buildings SET BuildingClass = 'BUILDINGCLASS_CASTLE' WHERE Type = 'BUILDING_STRONGHOLD';

UPDATE Buildings SET ArtInfoCulturalVariation = 1 WHERE Type IN ('BUILDING_COLOSSEUM', 'BUILDING_CASTLE', 'BUILDING_PALACE');
UPDATE Buildings SET ArtInfoEraVariation = 1 WHERE Type IN ('BUILDING_HARBOR', 'BUILDING_LIGHTHOUSE');
UPDATE Buildings SET MinAreaSize = -1;
UPDATE Buildings SET MinAreaSize = 10 WHERE Type IN ('BUILDING_HARBOR', 'BUILDING_LIGHTHOUSE', 'BUILDING_PORT', 'BUILDING_WHALERY', 'BUILDING_SHIPYARD');
UPDATE Buildings SET Water = 1 WHERE Type IN ('BUILDING_HARBOR', 'BUILDING_LIGHTHOUSE', 'BUILDING_PORT', 'BUILDING_WHALERY', 'BUILDING_SHIPYARD');
UPDATE Buildings SET FoodKept = 10 WHERE TYPE IN ('BUILDING_WARRENS', 'BUILDING_GRANARY');
UPDATE Buildings SET BuildingProductionModifier = 10 WHERE Type = 'BUILDING_WORKSHOP';
UPDATE Buildings SET EaPrereqOrPolicy = 'POLICY_THEISM', EaPrereqOrPolicy2 = 'POLICY_ANTI_THEISM' WHERE Type = 'BUILDING_SHRINE';
UPDATE Buildings SET MutuallyExclusiveGroup = 1 WHERE Type = 'BUILDING_FOREFATHERS_STATUE';		--exclusive with BUILDING_RACIAL_DISHARMONY, so only buildable in differing race city
UPDATE Buildings SET NoOccupiedUnhappiness = 1 WHERE Type = 'BUILDING_FOREFATHERS_STATUE';
UPDATE Buildings SET CityConnectionTradeRouteModifier = 20 WHERE Type = 'BUILDING_LIGHTHOUSE';	
UPDATE Buildings SET Happiness = 1, EaOccupationUnhapReduction = 30 WHERE Type = 'BUILDING_COURTHOUSE';
UPDATE Buildings SET Defense = 200 WHERE Type = 'BUILDING_PALACE';
UPDATE Buildings SET Defense = 500, AllowsRangeStrike = 1, CityWall = 1 WHERE Type = 'BUILDING_WALLS';
UPDATE Buildings SET Defense = 200, AllowsRangeStrike = 1 WHERE Type = 'BUILDING_ARMORY';
UPDATE Buildings SET Defense = 200, AllowsRangeStrike = 1 WHERE Type = 'BUILDING_ARSENAL';
UPDATE Buildings SET Defense = 700, AllowsRangeStrike = 1 WHERE Type = 'BUILDING_CASTLE';
UPDATE Buildings SET Defense = 800, AllowsRangeStrike = 1 WHERE Type = 'BUILDING_STRONGHOLD';
UPDATE Buildings SET AllowsWaterRoutes = 1 WHERE Type = 'BUILDING_HARBOR';
UPDATE Buildings SET EaHealth = 2 WHERE Type = 'BUILDING_APOTHECARY';
UPDATE Buildings SET EaHealth = 4 WHERE Type = 'BUILDING_AQUEDUCT';
UPDATE Buildings SET AllowsFoodTradeRoutes = 1 WHERE Type = 'BUILDING_SILOS';
UPDATE Buildings SET AllowsProductionTradeRoutes = 1 WHERE Type = 'BUILDING_WAREHOUSES';
UPDATE Buildings SET EaHealth = 2 WHERE Type = 'BUILDING_PUBLIC_BATHS';
UPDATE Buildings SET EaHealth = 6 WHERE Type = 'BUILDING_SEWERS';
UPDATE Buildings SET EaHealth = 6 WHERE Type = 'BUILDING_HOSPITAL';
UPDATE Buildings SET EaHealth = -4 WHERE Type = 'BUILDING_ROASTING_FURNACE';
UPDATE Buildings SET River = 1 WHERE Type IN ('BUILDING_WATERMILL', 'BUILDING_RIVER_DOCK');
UPDATE Buildings SET Mountain = 1 WHERE Type = 'BUILDING_OBSERVATORY';
UPDATE Buildings SET TrainedFreePromotion = 'PROMOTION_STALLIONS_OF_EPONA' WHERE Type = 'BUILDING_CULT_OF_EPONA_FOLLOWER';
UPDATE Buildings SET TrainedFreePromotion = 'PROMOTION_DRUNKARD' WHERE Type = 'BUILDING_CULT_OF_BAKKHEIA_FOLLOWER';
UPDATE Buildings SET UnmoddedHappiness = -2, MutuallyExclusiveGroup = 1 WHERE Type = 'BUILDING_RACIAL_DISHARMONY';
UPDATE Buildings SET Happiness = 1 WHERE Type = 'BUILDING_PLUS_1_LOCAL_HAPPY';

--check these:
UPDATE Buildings SET CultureRateModifier = 25 WHERE Type = 'BUILDING_MUSEUM';
UPDATE Buildings SET CultureRateModifier = 25 WHERE Type = 'BUILDING_THEATRE';
UPDATE Buildings SET CultureRateModifier = 25 WHERE Type = 'BUILDING_OPERA_HOUSE';

UPDATE Buildings SET GoldMaintenance = 0, EaProhibitSell = 1, ConquestProb = 100, FoodKept = 50 WHERE Type = 'BUILDING_MAN';
UPDATE Buildings SET GoldMaintenance = 0, EaProhibitSell = 1, ConquestProb = 100, FoodKept = 30 WHERE Type = 'BUILDING_SIDHE';
UPDATE Buildings SET GoldMaintenance = 0, EaProhibitSell = 1, ConquestProb = 100, FoodKept = 70 WHERE Type = 'BUILDING_HELDEOFOL';

UPDATE Buildings SET Experience = 1 WHERE Type = 'BUILDING_KOLOSSOS_MOD';
UPDATE Buildings SET WorkerSpeedModifier = 1 WHERE Type = 'BUILDING_UUC_YABNAL_MOD';
UPDATE Buildings SET UnmoddedHappiness = 1 WHERE Type = 'BUILDING_DA_BAOEN_SI_MOD';
UPDATE Buildings SET TradeRouteSeaDistanceModifier = 1, TradeRouteSeaGoldBonus = 1 WHERE Type = 'BUILDING_MEGALOS_FAROS_MOD';



--DEBUG
--UPDATE Buildings SET EaHidden = NULL;
--UPDATE Buildings SET PrereqTech = NULL, EaPrereqPolicy = NULL;

--UPDATE Buildings SET FreeBuilding='BUILDINGCLASS_SHRINE' WHERE Type='BUILDING_MAN';

--fixinator
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM Buildings ORDER BY ID;
UPDATE Buildings SET ID =	( SELECT IDRemapper.id-1 FROM IDRemapper WHERE Buildings.Type = IDRemapper.Type);
DROP TABLE IDRemapper;

-------------------------------------------------------------------------------
-- BuildingClasses (autogenerate)
-------------------------------------------------------------------------------

DELETE FROM BuildingClasses;
INSERT INTO BuildingClasses (Type, DefaultBuilding, Description) SELECT BuildingClass, Type, Description FROM Buildings GROUP BY BuildingClass ORDER BY ID;
--Above line will use last listed Building of a BuildingClass as the DefaultBuilding and Description

UPDATE BuildingClasses SET MaxPlayerInstances = 1 WHERE Type = 'BUILDINGCLASS_PALACE';
UPDATE BuildingClasses SET MaxGlobalInstances = 1 WHERE Type IN ('BUILDINGCLASS_KOLOSSOS', 'BUILDINGCLASS_MEGALOS_FAROS', 'BUILDINGCLASS_HANGING_GARDENS', 'BUILDINGCLASS_UUC_YABNAL', 'BUILDINGCLASS_THE_LONG_WALL', 'BUILDINGCLASS_CLOG_MOR', 'BUILDINGCLASS_DA_BAOEN_SI');
--TO DO: Add plot wonders if we know they are safe (for score) 'BUILDINGCLASS_STANHENCG', , 'BUILDINGCLASS_GREAT_LIBRARY'

DELETE FROM BuildingClass_VictoryThresholds;

--fixinator
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM BuildingClasses ORDER BY ID;
UPDATE BuildingClasses SET ID =	( SELECT IDRemapper.id-1 FROM IDRemapper WHERE BuildingClasses.Type = IDRemapper.Type);
DROP TABLE IDRemapper;

-------------------------------------------------------------------------------
--Added subtables
-------------------------------------------------------------------------------

CREATE TABLE Building_EaConvertImprovedResource (	'BuildingType' TEXT DEFAULT NULL,
													'ImprovedResource' TEXT DEFAULT NULL,	--Warning: Lua assumes that this field is unique!
													'AddResource' TEXT DEFAULT NULL);

INSERT INTO Building_EaConvertImprovedResource (BuildingType,	ImprovedResource,	AddResource) VALUES
('BUILDING_TANNERY',			'RESOURCE_COW',			'RESOURCE_LEATHER'	),
('BUILDING_TANNERY',			'RESOURCE_DEER',		'RESOURCE_LEATHER'	),
('BUILDING_TANNERY',			'RESOURCE_BOARS',		'RESOURCE_LEATHER'	),
('BUILDING_TANNERY',			'RESOURCE_HORSE',		'RESOURCE_LEATHER'	),
('BUILDING_IVORYWORKS',			'RESOURCE_ELEPHANT',	'RESOURCE_IVORY'	),
('BUILDING_IVORYWORKS',			'RESOURCE_WHALE',		'RESOURCE_IVORY'	),
('BUILDING_DISTILLERY',			'RESOURCE_SUGAR',		'RESOURCE_SPIRITS'	),
('BUILDING_DISTILLERY',			'RESOURCE_BANANA',		'RESOURCE_SPIRITS'	);



CREATE TABLE Building_EaRemoteImproveTypes  (	'BuildingType' TEXT DEFAULT NULL,
												'EnablingBuildingType' TEXT DEFAULT NULL,
												'RemoteImproveType' TEXT DEFAULT NULL);

INSERT INTO Building_EaRemoteImproveTypes (BuildingType,	EnablingBuildingType,	RemoteImproveType) VALUES
('BUILDING_HUNTING_LODGE',		'BUILDING_HUNTING_LODGE_ENABLE',	'HuntingRes'	),
('BUILDING_HARBOR',				NULL,								'FishingRes'	),	--1st two columns should be consistent if appearing in >1 row
('BUILDING_HARBOR',				NULL,								'WhalingRes'	),
('BUILDING_PORT',				'BUILDING_PORT_ENABLE',				'FishingRes'	),
('BUILDING_PORT',				'BUILDING_PORT_ENABLE',				'WhalingRes'	),
('BUILDING_WHALERY',			'BUILDING_WHALERY_ENABLE',			'WhalingRes'	),
('BUILDING_FLOATING_GARDENS',	'BUILDING_FLOATING_GARDENS_ENABLE',	'Lake'			),
('BUILDING_DEEP_FARMS',			'BUILDING_DEEP_FARMS_ENABLE',		'Mountain'		);


--Remember to add this to Building_ClassesNeededInCity!

-------------------------------------------------------------------------------
--Building subtables
-------------------------------------------------------------------------------

DELETE FROM Building_AreaYieldModifiers;
DELETE FROM Building_BuildingClassHappiness;
DELETE FROM Building_BuildingClassYieldChanges;
DELETE FROM Building_FreeSpecialistCounts;
DELETE FROM Building_FreeUnits;
DELETE FROM Building_LockedBuildingClasses;
DELETE FROM Building_PrereqBuildingClasses;		--TO DO
DELETE FROM Building_ResourceCultureChanges;	--still present in G&K, though empty
DELETE FROM Building_ResourceFaithChanges;		--???
DELETE FROM Building_ResourceYieldModifiers;
DELETE FROM Building_RiverPlotYieldChanges;
DELETE FROM Building_SeaPlotYieldChanges;
DELETE FROM Building_SpecialistYieldChanges;
DELETE FROM Building_TerrainYieldChanges;
DELETE FROM Building_TechEnhancedYieldChanges;	--works with EnhancedYieldTech


DELETE FROM Building_FeatureYieldChanges;
INSERT INTO Building_FeatureYieldChanges (BuildingType, FeatureType, YieldType, Yield) VALUES
('BUILDING_TEMPLE_AZZANDARA_3',	'FEATURE_OASIS',	'YIELD_FOOD',	1),
('BUILDING_TEMPLE_AZZANDARA_3',	'FEATURE_ATOLL',	'YIELD_FOOD',	1);

DELETE FROM Building_LakePlotYieldChanges;
INSERT INTO Building_LakePlotYieldChanges (BuildingType, YieldType, Yield) VALUES
('BUILDING_TEMPLE_AZZANDARA_3',	'YIELD_FOOD',	1);



DELETE FROM Building_ResourceQuantityRequirements;
INSERT INTO Building_ResourceQuantityRequirements (BuildingType, ResourceType, Cost) VALUES
('BUILDING_CHRYSOPOEIA_REACTOR',	'RESOURCE_QUICKSILVER',		1	),
('BUILDING_ARGENTOPOEIA_REACTOR',	'RESOURCE_QUICKSILVER',		1	);

DELETE FROM Building_ResourceQuantity;
INSERT INTO Building_ResourceQuantity (BuildingType, ResourceType, Quantity) VALUES
('BUILDING_BREWERY',				'RESOURCE_ALE',				1	),
('BUILDING_TIMBERYARD',				'RESOURCE_TIMBER',			1	),
('BUILDING_JEWELLER',				'RESOURCE_JEWELRY',			1	),
('BUILDING_KILN',					'RESOURCE_PORCELAIN',		1	),
('BUILDING_CHRYSOPOEIA_REACTOR',	'RESOURCE_GOLD',			1	),
('BUILDING_ARGENTOPOEIA_REACTOR',	'RESOURCE_SILVER',			1	),
('BUILDING_ROASTING_FURNACE',		'RESOURCE_QUICKSILVER',		2	);


DELETE FROM Building_ClassesNeededInCity;
INSERT INTO Building_ClassesNeededInCity (BuildingType, BuildingClassType) VALUES
--first batch from Building_EaRemoteImproveTypes table
('BUILDING_HUNTING_LODGE',		'BUILDINGCLASS_HUNTING_LODGE_ENABLE'	),
('BUILDING_PORT',				'BUILDINGCLASS_PORT_ENABLE'				),
('BUILDING_WHALERY',			'BUILDINGCLASS_WHALERY_ENABLE'			),
('BUILDING_FLOATING_GARDENS',	'BUILDINGCLASS_FLOATING_GARDENS_ENABLE'	),

('BUILDING_FACTORY',			'BUILDINGCLASS_FORGE'			),
('BUILDING_UNIVERSITY',			'BUILDINGCLASS_LIBRARY'			),
('BUILDING_THEATRE',			'BUILDINGCLASS_AMPHITHEATER'	),
('BUILDING_OPERA_HOUSE',		'BUILDINGCLASS_AMPHITHEATER'	),
('BUILDING_PORT',				'BUILDINGCLASS_HARBOR'			),
('BUILDING_ARMORY',				'BUILDINGCLASS_FORGE'			),
('BUILDING_ARSENAL',			'BUILDINGCLASS_ARMORY'			),
('BUILDING_WHALERY',			'BUILDINGCLASS_HARBOR'			),
('BUILDING_SHIPYARD',			'BUILDINGCLASS_HARBOR'			),
('BUILDING_PUBLIC_BATHS',		'BUILDINGCLASS_AQUEDUCT'		),
('BUILDING_SEWERS',				'BUILDINGCLASS_AQUEDUCT'		),
('BUILDING_TIMBERYARD',			'BUILDINGCLASS_TIMBERYARD_ALLOW'),
('BUILDING_WINDMILL',			'BUILDINGCLASS_WINDMILL_ALLOW'	),
('BUILDING_TRIBAL_COUNCIL',		'BUILDINGCLASS_RACIAL_DISHARMONY');

DELETE FROM Building_Flavors;
INSERT INTO Building_Flavors (BuildingType,	FlavorType,	Flavor) VALUES
('BUILDING_PALACE',				'FLAVOR_GOLD',				10 ),
('BUILDING_PALACE',				'FLAVOR_SCIENCE',			10 ),
('BUILDING_PALACE',				'FLAVOR_CULTURE',			10 ),
('BUILDING_MONUMENT',			'FLAVOR_CULTURE',			20 ),
('BUILDING_WARRENS',			'FLAVOR_GROWTH',			40 ),
('BUILDING_LIBRARY',			'FLAVOR_SCIENCE',			20 ),
('BUILDING_LIBRARY',			'FLAVOR_CULTURE',			5 ),
('BUILDING_LIBRARY',			'FLAVOR_GREAT_PEOPLE',		5 ),
('BUILDING_MARKETPLACE',		'FLAVOR_GOLD',				40 ),
('BUILDING_MARKETPLACE',		'FLAVOR_CULTURE',			10 ),
('BUILDING_MARKETPLACE',		'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_FAIR',				'FLAVOR_CULTURE',			20 ),
('BUILDING_FAIR',				'FLAVOR_HAPPINESS',			10 ),
('BUILDING_AMPHITHEATER',		'FLAVOR_CULTURE',			10 ),
('BUILDING_AMPHITHEATER',		'FLAVOR_HAPPINESS',			10 ),
('BUILDING_AMPHITHEATER',		'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_WORKSHOP',			'FLAVOR_PRODUCTION',		20 ),
('BUILDING_WORKSHOP',			'FLAVOR_MILITARY_TRAINING',	10 ),
('BUILDING_WORKSHOP',			'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_FORGE',				'FLAVOR_PRODUCTION',		20 ),
('BUILDING_FORGE',				'FLAVOR_MILITARY_TRAINING',	20 ),
('BUILDING_FORGE',				'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_SHRINE',				'FLAVOR_RELIGION',			20 ),
('BUILDING_SHRINE',				'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_MAGE_SCHOOL',		'FLAVOR_RELIGION',			20 ),
('BUILDING_MAGE_SCHOOL',		'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_PHARMAKEIA',			'FLAVOR_RELIGION',			20 ),
('BUILDING_PHARMAKEIA',			'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_SMOKEHOUSE',			'FLAVOR_GROWTH',			50 ),
('BUILDING_TANNERY',			'FLAVOR_PRODUCTION',		20 ),
('BUILDING_TANNERY',			'FLAVOR_HAPPINESS',			10 ),
('BUILDING_IVORYWORKS',			'FLAVOR_CULTURE',			20 ),
('BUILDING_IVORYWORKS',			'FLAVOR_HAPPINESS',			10 ),
('BUILDING_GRANARY',			'FLAVOR_GROWTH',			40 ),
('BUILDING_SALTWORKS',			'FLAVOR_GROWTH',			40 ),
('BUILDING_SALTWORKS',			'FLAVOR_GOLD',				10 ),
('BUILDING_SALTWORKS',			'FLAVOR_HAPPINESS',			10 ),
('BUILDING_STABLE',				'FLAVOR_MILITARY_TRAINING',	30 ),
('BUILDING_STABLE',				'FLAVOR_PRODUCTION',		10 ),
('BUILDING_ELEPHANT_STOCKADE',	'FLAVOR_MILITARY_TRAINING',	30 ),
('BUILDING_ELEPHANT_STOCKADE',	'FLAVOR_PRODUCTION',		10 ),
('BUILDING_HUNTING_LODGE',		'FLAVOR_GROWTH',			30 ),
('BUILDING_HUNTING_LODGE',		'FLAVOR_GOLD',				20 ),
('BUILDING_ABATTOIR',			'FLAVOR_GROWTH',			40 ),
('BUILDING_KNACKERY',			'FLAVOR_PRODUCTION',		40 ),
('BUILDING_HARBOR',				'FLAVOR_GROWTH',			30 ),
('BUILDING_HARBOR',				'FLAVOR_GOLD',				20 ),
('BUILDING_HARBOR',				'FLAVOR_WATER_CONNECTION',	40 ),
('BUILDING_TIMBERYARD',			'FLAVOR_PRODUCTION',		20 ),
('BUILDING_TIMBERYARD',			'FLAVOR_NAVAL',				40 ),
('BUILDING_COTTON_GIN',			'FLAVOR_PRODUCTION',		15 ),
('BUILDING_COTTON_GIN',			'FLAVOR_CULTURE',			15 ),
('BUILDING_WINERY',				'FLAVOR_GOLD',				15 ),
('BUILDING_WINERY',				'FLAVOR_CULTURE',			15 ),
('BUILDING_BREWERY',			'FLAVOR_HAPPINESS',			20 ),
('BUILDING_BREWERY',			'FLAVOR_CULTURE',			10 ),
('BUILDING_SILOS',				'FLAVOR_GROWTH',			30 ),
('BUILDING_SILOS',				'FLAVOR_EXPANSION',			10 ),
('BUILDING_SILOS',				'FLAVOR_I_LAND_TRADE_ROUTE',5 ),
('BUILDING_SILOS',				'FLAVOR_I_SEA_TRADE_ROUTE',	5 ),
('BUILDING_APOTHECARY',			'FLAVOR_SCIENCE',			20 ),
('BUILDING_APOTHECARY',			'FLAVOR_GROWTH',			10 ),
('BUILDING_APOTHECARY',			'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_MINT',				'FLAVOR_GOLD',				30 ),
('BUILDING_STONE_WORKS',		'FLAVOR_PRODUCTION',		10 ),
('BUILDING_STONE_WORKS',		'FLAVOR_CULTURE',			20 ),
('BUILDING_MOUNDS',				'FLAVOR_RELIGION',			30 ),
('BUILDING_GALLOWS',			'FLAVOR_PRODUCTION',		10 ),
('BUILDING_GALLOWS',			'FLAVOR_HAPPINESS',			10 ),
('BUILDING_DEBTORS_COURT',		'FLAVOR_HAPPINESS',			10 ),
('BUILDING_DEBTORS_COURT',		'FLAVOR_GOLD',				10 ),
('BUILDING_GOVERNORS_COMPOUND',	'FLAVOR_GOLD',				10 ),
('BUILDING_GOVERNORS_COMPOUND',	'FLAVOR_HAPPINESS',			10 ),
('BUILDING_TRIBAL_COUNCIL',		'FLAVOR_HAPPINESS',			30 ),
('BUILDING_FOREFATHERS_STATUE',	'FLAVOR_HAPPINESS',			30 ),
('BUILDING_RIVER_DOCK',			'FLAVOR_PRODUCTION',		10 ),
('BUILDING_RIVER_DOCK',			'FLAVOR_GOLD',				20 ),
('BUILDING_LIGHTHOUSE',			'FLAVOR_GOLD',				10 ),
('BUILDING_WINDMILL',			'FLAVOR_GROWTH',			15 ),
('BUILDING_WINDMILL',			'FLAVOR_PRODUCTION',		15 ),
('BUILDING_WATERMILL',			'FLAVOR_GROWTH',			15 ),
('BUILDING_WATERMILL',			'FLAVOR_PRODUCTION',		15 ),
('BUILDING_COURTHOUSE',			'FLAVOR_HAPPINESS',			30 ),
('BUILDING_WALLS',				'FLAVOR_CITY_DEFENSE',		20 ),
('BUILDING_SMITHS_GUILD',		'FLAVOR_PRODUCTION',		10 ),
('BUILDING_SMITHS_GUILD',		'FLAVOR_GREAT_PEOPLE',		20 ),
('BUILDING_TRADERS_GUILD',		'FLAVOR_GOLD',				10 ),
('BUILDING_TRADERS_GUILD',		'FLAVOR_GREAT_PEOPLE',		20 ),
('BUILDING_SCRIBES_GUILD',		'FLAVOR_SCIENCE',			10 ),
('BUILDING_SCRIBES_GUILD',		'FLAVOR_GREAT_PEOPLE',		20 ),
('BUILDING_ARTISANS_GUILD',		'FLAVOR_CULTURE',			10 ),
('BUILDING_ARTISANS_GUILD',		'FLAVOR_GREAT_PEOPLE',		20 ),
('BUILDING_DISCIPLES_GUILD',	'FLAVOR_RELIGION',			10 ),
('BUILDING_DISCIPLES_GUILD',	'FLAVOR_GREAT_PEOPLE',		20 ),
('BUILDING_ADEPTS_GUILD',		'FLAVOR_RELIGION',			10 ),
('BUILDING_ADEPTS_GUILD',		'FLAVOR_GREAT_PEOPLE',		20 ),
('BUILDING_FACTORY',			'FLAVOR_PRODUCTION',		30 ),
('BUILDING_FACTORY',			'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_BANK',				'FLAVOR_GOLD',				30 ),
('BUILDING_BANK',				'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_UNIVERSITY',			'FLAVOR_SCIENCE',			30 ),
('BUILDING_UNIVERSITY',			'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_LABORATORY',			'FLAVOR_SCIENCE',			30 ),
('BUILDING_LABORATORY',			'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_INTELLIGENT_ARCHIVE',			'FLAVOR_SCIENCE',			40 ),
('BUILDING_INTELLIGENT_ARCHIVE',			'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_MUSEUM',				'FLAVOR_CULTURE',			30 ),
('BUILDING_MUSEUM',				'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_THEATRE',			'FLAVOR_HAPPINESS',			20 ),
('BUILDING_THEATRE',			'FLAVOR_CULTURE',			30 ),
('BUILDING_THEATRE',			'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_OPERA_HOUSE',		'FLAVOR_HAPPINESS',			20 ),
('BUILDING_OPERA_HOUSE',		'FLAVOR_CULTURE',			30 ),
('BUILDING_OPERA_HOUSE',		'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_MONASTERY',			'FLAVOR_RELIGION',			20 ),
('BUILDING_MONASTERY',			'FLAVOR_CULTURE',			20 ),
('BUILDING_MONASTERY',			'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_BREEDING_PEN',		'FLAVOR_PRODUCTION',		20 ),
('BUILDING_BREEDING_PEN',		'FLAVOR_GROWTH',			20 ),
('BUILDING_BOWYER',				'FLAVOR_PRODUCTION',		10 ),
('BUILDING_BOWYER',				'FLAVOR_CULTURE',			10 ),
('BUILDING_BOWYER',				'FLAVOR_MILITARY_TRAINING',	20 ),
('BUILDING_DISTILLERY',			'FLAVOR_HAPPINESS',			20 ),
('BUILDING_DISTILLERY',			'FLAVOR_CULTURE',			10 ),
('BUILDING_PORT',				'FLAVOR_GOLD',				30 ),
('BUILDING_PORT',				'FLAVOR_GROWTH',			30 ),
('BUILDING_WHALERY',			'FLAVOR_GOLD',				20 ),
('BUILDING_WHALERY',			'FLAVOR_PRODUCTION',		20 ),
('BUILDING_ARMORY',				'FLAVOR_MILITARY_TRAINING',	20 ),
('BUILDING_ARMORY',				'FLAVOR_PRODUCTION',		20 ),
('BUILDING_ROASTING_FURNACE',	'FLAVOR_RELIGION',			20 ),
('BUILDING_ROASTING_FURNACE',	'FLAVOR_PRODUCTION',		10 ),
('BUILDING_ROASTING_FURNACE',	'FLAVOR_GOLD',				10 ),
('BUILDING_CHRYSOPOEIA_REACTOR','FLAVOR_HAPPINESS',			20 ),
('BUILDING_CHRYSOPOEIA_REACTOR','FLAVOR_GOLD',				20 ),
('BUILDING_ARGENTOPOEIA_REACTOR','FLAVOR_HAPPINESS',		20 ),
('BUILDING_ARGENTOPOEIA_REACTOR','FLAVOR_GOLD',				20 ),
('BUILDING_ARSENAL',			'FLAVOR_MILITARY_TRAINING',	20 ),
('BUILDING_ARSENAL',			'FLAVOR_PRODUCTION',		20 ),
('BUILDING_TEXTILE_MILL',		'FLAVOR_GOLD',				20 ),
('BUILDING_TEXTILE_MILL',		'FLAVOR_CULTURE',			20 ),
('BUILDING_MONASTIC_SCHOOL',	'FLAVOR_SCIENCE',			10 ),
('BUILDING_MONASTIC_SCHOOL',	'FLAVOR_GREAT_PEOPLE',		10 ),
('BUILDING_SLAVE_MARKET',		'FLAVOR_GOLD',				30 ),
('BUILDING_SLAVE_KNACKERY',		'FLAVOR_PRODUCTION',		30 ),
('BUILDING_SLAVE_STOCKADE',		'FLAVOR_PRODUCTION',		20 ),
('BUILDING_SLAVE_BREEDING_PEN',	'FLAVOR_HAPPINESS',			30 ),
('BUILDING_SLAVE_BREEDING_PEN',	'FLAVOR_GROWTH',			30 ),
('BUILDING_INTERNMENT_CAMP',	'FLAVOR_HAPPINESS',			20 ),
('BUILDING_INTERNMENT_CAMP',	'FLAVOR_PRODUCTION',		20 ),
('BUILDING_BARRACKS',			'FLAVOR_MILITARY_TRAINING',	10 ),
('BUILDING_JEWELLER',			'FLAVOR_HAPPINESS',			20 ),
('BUILDING_JEWELLER',			'FLAVOR_GOLD',				20 ),
('BUILDING_JEWELLER',			'FLAVOR_CULTURE',			20 ),
('BUILDING_KILN',				'FLAVOR_HAPPINESS',			10 ),
('BUILDING_KILN',				'FLAVOR_GOLD',				10 ),
('BUILDING_KILN',				'FLAVOR_CULTURE',			10 ),
('BUILDING_CASTLE',				'FLAVOR_CITY_DEFENSE',		30 ),
('BUILDING_CASTLE',				'FLAVOR_GOLD',				5 ),
('BUILDING_CASTLE',				'FLAVOR_CULTURE',			5 ),
('BUILDING_STRONGHOLD',			'FLAVOR_CITY_DEFENSE',		40 ),
('BUILDING_PAPERMILL',			'FLAVOR_SCIENCE',			10 ),
('BUILDING_AQUEDUCT',			'FLAVOR_GROWTH',			20 ),
('BUILDING_WAREHOUSES',			'FLAVOR_PRODUCTION',		30 ),
('BUILDING_WAREHOUSES',			'FLAVOR_EXPANSION',			10 ),
('BUILDING_WAREHOUSES',			'FLAVOR_I_LAND_TRADE_ROUTE',5 ),
('BUILDING_WAREHOUSES',			'FLAVOR_I_SEA_TRADE_ROUTE',	5 ),
('BUILDING_PUBLIC_BATHS',		'FLAVOR_HAPPINESS',			15 ),
('BUILDING_PUBLIC_BATHS',		'FLAVOR_GROWTH',			25 ),
('BUILDING_COLOSSEUM',			'FLAVOR_HAPPINESS',			30 ),
('BUILDING_COLOSSEUM',			'FLAVOR_CULTURE',			20 ),
('BUILDING_SEWERS',				'FLAVOR_GROWTH',			30 ),
('BUILDING_PRINTING_PRESS',		'FLAVOR_SCIENCE',			30 ),
('BUILDING_OBSERVATORY',		'FLAVOR_SCIENCE',			30 ),
('BUILDING_CHAMBER_THOUGHT',	'FLAVOR_SCIENCE',			40 ),
('BUILDING_CONSCIOUSNESS_ENGINE','FLAVOR_SCIENCE',			50 ),
('BUILDING_SHIPYARD',			'FLAVOR_PRODUCTION',		20 ),
('BUILDING_SHIPYARD',			'FLAVOR_NAVAL',				20 ),
('BUILDING_HOSPITAL',			'FLAVOR_GROWTH',			40 ),
('BUILDING_DEEP_FARMS',			'FLAVOR_GROWTH',			40 ),
('BUILDING_FLOATING_GARDENS',	'FLAVOR_GROWTH',			30 );

DELETE FROM Building_GlobalYieldModifiers;		--adds straight yield, not percent

DELETE FROM Building_HurryModifiers;
INSERT INTO Building_HurryModifiers (BuildingType, HurryType, HurryCostModifier) VALUES
('BUILDING_CLOG_MOR_MOD',	'HURRY_GOLD',		-1 );

DELETE FROM Building_LocalResourceAnds;
DELETE FROM Building_LocalResourceOrs;
INSERT INTO Building_LocalResourceOrs (BuildingType, ResourceType) VALUES
('BUILDING_TANNERY',		'RESOURCE_COW'		),
('BUILDING_TANNERY',		'RESOURCE_HORSE'	),
('BUILDING_TANNERY',		'RESOURCE_DEER'		),
('BUILDING_TANNERY',		'RESOURCE_BOARS'	),
('BUILDING_IVORYWORKS',		'RESOURCE_WHALE'	),
('BUILDING_IVORYWORKS',		'RESOURCE_ELEPHANT' ),
('BUILDING_SALTWORKS',		'RESOURCE_SALT'		),
('BUILDING_STABLE',			'RESOURCE_HORSE'	),
('BUILDING_ELEPHANT_STOCKADE','RESOURCE_ELEPHANT'),
('BUILDING_ABATTOIR',		'RESOURCE_COW'		),
('BUILDING_ABATTOIR',		'RESOURCE_HORSE'	),
('BUILDING_ABATTOIR',		'RESOURCE_WOOL'		),
('BUILDING_KNACKERY',		'RESOURCE_COW'		),
('BUILDING_KNACKERY',		'RESOURCE_HORSE'	),
('BUILDING_KNACKERY',		'RESOURCE_WOOL'		),
('BUILDING_COTTON_GIN',		'RESOURCE_COTTON'	),
('BUILDING_WINERY',			'RESOURCE_WINE'		),
('BUILDING_BREWERY',		'RESOURCE_WHEAT'	),
('BUILDING_APOTHECARY',		'RESOURCE_QUICKSILVER'),
('BUILDING_APOTHECARY',		'RESOURCE_MOLY'		),
('BUILDING_APOTHECARY',		'RESOURCE_GEMS'		),
('BUILDING_APOTHECARY',		'RESOURCE_NAPHTHA'	),
('BUILDING_FAIR',			'RESOURCE_DYE'		),
('BUILDING_FAIR',			'RESOURCE_SILK'		),
('BUILDING_FAIR',			'RESOURCE_SPICES'	),
('BUILDING_FAIR',			'RESOURCE_WINE'		),
('BUILDING_FAIR',			'RESOURCE_INCENCE'	),
('BUILDING_MINT',			'RESOURCE_GOLD'		),
('BUILDING_MINT',			'RESOURCE_SILVER'	),
('BUILDING_STONE_WORKS',	'RESOURCE_MARBLE'	),
('BUILDING_STONE_WORKS',	'RESOURCE_STONE'	),
('BUILDING_BREEDING_PEN',	'RESOURCE_COW'		),
('BUILDING_BREEDING_PEN',	'RESOURCE_HORSE'	),
('BUILDING_BREEDING_PEN',	'RESOURCE_WOOL'		),
('BUILDING_BOWYER',			'RESOURCE_YEW'		),
('BUILDING_ROASTING_FURNACE','RESOURCE_QUICKSILVER'),
('BUILDING_DISTILLERY',		'RESOURCE_SUGAR'	),
('BUILDING_DISTILLERY',		'RESOURCE_BANANA'	),
('BUILDING_TEXTILE_MILL',	'RESOURCE_WOOL'		),
('BUILDING_TEXTILE_MILL',	'RESOURCE_DYE'		),
('BUILDING_TEXTILE_MILL',	'RESOURCE_SILK'		),
('BUILDING_TEXTILE_MILL',	'RESOURCE_COTTON'	),
('BUILDING_JEWELLER',		'RESOURCE_GOLD'		),
('BUILDING_JEWELLER',		'RESOURCE_SILVER'	),
('BUILDING_JEWELLER',		'RESOURCE_GEMS'		),
('BUILDING_JEWELLER',		'RESOURCE_JADE'		),
('BUILDING_JEWELLER',		'RESOURCE_PEARLS'	);

DELETE FROM Building_SeaResourceYieldChanges;
--INSERT INTO Building_SeaResourceYieldChanges (BuildingType,	YieldType,	Yield) VALUES
--('BUILDING_MAYD',			'YIELD_FOOD',			1  ),
--('BUILDING_MAYD',			'YIELD_PRODUCTION',		1  );

DELETE FROM Building_ResourceYieldChanges;
INSERT INTO Building_ResourceYieldChanges (BuildingType, ResourceType, YieldType, Yield) VALUES
('BUILDING_MARKETPLACE',	'RESOURCE_COPPER',			'YIELD_GOLD',		1	), 
('BUILDING_MARKETPLACE',	'RESOURCE_IRON',			'YIELD_GOLD',		1	), 
('BUILDING_MARKETPLACE',	'RESOURCE_MITHRIL',			'YIELD_GOLD',		1	), 
('BUILDING_MARKETPLACE',	'RESOURCE_NAPHTHA',			'YIELD_GOLD',		1	), 
('BUILDING_MARKETPLACE',	'RESOURCE_GOLD',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_SILVER',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_GEMS',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_JADE',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_SALT',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_STONE',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_MARBLE',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_FISH',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_PEARLS',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_CRAB',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_WHALE',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_DEER',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_BOARS',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_FUR',				'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_ELEPHANT',		'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_HORSE',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_COW',				'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_WOOL',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_WHEAT',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_BANANA',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_DYE',				'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_SILK',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_COTTON',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_SPICES',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_SUGAR',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_CITRUS',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_WINE',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_INCENCE',			'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_QUICKSILVER',		'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_MOLY',			'YIELD_GOLD',		1	),
--('BUILDING_MARKETPLACE',	'RESOURCE_BLASTING_POWDER',	'YIELD_GOLD',		1	),
('BUILDING_MARKETPLACE',	'RESOURCE_YEW',				'YIELD_GOLD',		1	),
('BUILDING_FAIR',			'RESOURCE_DYE',				'YIELD_CULTURE',	1	),
('BUILDING_FAIR',			'RESOURCE_SILK',			'YIELD_CULTURE',	1	),
('BUILDING_FAIR',			'RESOURCE_SPICES',			'YIELD_CULTURE',	1	),
('BUILDING_FAIR',			'RESOURCE_WINE',			'YIELD_CULTURE',	1	),
('BUILDING_FAIR',			'RESOURCE_INCENCE',			'YIELD_CULTURE',	1	), 
('BUILDING_WORKSHOP',		'RESOURCE_NAPHTHA',			'YIELD_PRODUCTION',	1	),
--('BUILDING_WORKSHOP',		'RESOURCE_BLASTING_POWDER',	'YIELD_PRODUCTION',	1	),
('BUILDING_FORGE',			'RESOURCE_COPPER',			'YIELD_PRODUCTION',	1	), 
('BUILDING_FORGE',			'RESOURCE_IRON',			'YIELD_PRODUCTION', 1	), 
('BUILDING_FORGE',			'RESOURCE_MITHRIL',			'YIELD_PRODUCTION', 1	), 
('BUILDING_SMOKEHOUSE',		'RESOURCE_DEER',			'YIELD_FOOD',		1	),
('BUILDING_SMOKEHOUSE',		'RESOURCE_BOARS',			'YIELD_FOOD',		1	),
('BUILDING_SMOKEHOUSE',		'RESOURCE_FUR',				'YIELD_FOOD',		1	),
('BUILDING_SMOKEHOUSE',		'RESOURCE_ELEPHANT',		'YIELD_FOOD',		1	),
('BUILDING_TANNERY',		'RESOURCE_COW',				'YIELD_PRODUCTION',	1	),
('BUILDING_TANNERY',		'RESOURCE_HORSE',			'YIELD_PRODUCTION',	1	),
('BUILDING_TANNERY',		'RESOURCE_DEER',			'YIELD_PRODUCTION',	1	),
('BUILDING_TANNERY',		'RESOURCE_BOARS',			'YIELD_PRODUCTION',	1	),
('BUILDING_IVORYWORKS',		'RESOURCE_ELEPHANT',		'YIELD_CULTURE',	1	),
('BUILDING_IVORYWORKS',		'RESOURCE_WHALE',			'YIELD_CULTURE',	1	),
('BUILDING_GRANARY',		'RESOURCE_WHEAT',			'YIELD_FOOD',		1	),
('BUILDING_SALTWORKS',		'RESOURCE_SALT',			'YIELD_GOLD',		1	),
('BUILDING_STABLE',			'RESOURCE_HORSE',			'YIELD_PRODUCTION',	1	),
('BUILDING_ELEPHANT_STOCKADE','RESOURCE_ELEPHANT',		'YIELD_PRODUCTION',	1	),
('BUILDING_ABATTOIR',		'RESOURCE_COW',				'YIELD_FOOD',		1	),
('BUILDING_ABATTOIR',		'RESOURCE_HORSE',			'YIELD_FOOD',		1	),
('BUILDING_ABATTOIR',		'RESOURCE_WOOL',			'YIELD_FOOD',		1	),
('BUILDING_KNACKERY',		'RESOURCE_COW',				'YIELD_PRODUCTION',	1	),
('BUILDING_KNACKERY',		'RESOURCE_HORSE',			'YIELD_PRODUCTION',	1	),
('BUILDING_KNACKERY',		'RESOURCE_WOOL',			'YIELD_PRODUCTION',	1	),
('BUILDING_BREEDING_PEN',	'RESOURCE_COW',				'YIELD_FOOD',		1	),
('BUILDING_BREEDING_PEN',	'RESOURCE_HORSE',			'YIELD_FOOD',		1	),
('BUILDING_BREEDING_PEN',	'RESOURCE_WOOL',			'YIELD_FOOD',		1	),
('BUILDING_BREEDING_PEN',	'RESOURCE_COW',				'YIELD_PRODUCTION',	1	),
('BUILDING_BREEDING_PEN',	'RESOURCE_HORSE',			'YIELD_PRODUCTION',	1	),
('BUILDING_BREEDING_PEN',	'RESOURCE_WOOL',			'YIELD_PRODUCTION',	1	),
('BUILDING_COTTON_GIN',		'RESOURCE_COTTON',			'YIELD_PRODUCTION',	1	),
('BUILDING_WINERY',			'RESOURCE_WINE',			'YIELD_GOLD',		1	),
('BUILDING_BREWERY',		'RESOURCE_WHEAT',			'YIELD_CULTURE',	1	),
('BUILDING_APOTHECARY',		'RESOURCE_QUICKSILVER',		'YIELD_SCIENCE',	1	),
('BUILDING_APOTHECARY',		'RESOURCE_QUICKSILVER',		'YIELD_FAITH',		1	),
('BUILDING_APOTHECARY',		'RESOURCE_MOLY',			'YIELD_SCIENCE',	1	),
('BUILDING_APOTHECARY',		'RESOURCE_MOLY',			'YIELD_FAITH',		1	),
('BUILDING_APOTHECARY',		'RESOURCE_GEMS',			'YIELD_SCIENCE',	1	),
('BUILDING_APOTHECARY',		'RESOURCE_GEMS',			'YIELD_FAITH',		1	),
('BUILDING_APOTHECARY',		'RESOURCE_NAPHTHA',			'YIELD_SCIENCE',	1	),
('BUILDING_APOTHECARY',		'RESOURCE_NAPHTHA',			'YIELD_FAITH',		1	),
('BUILDING_ROASTING_FURNACE','RESOURCE_QUICKSILVER',	'YIELD_GOLD',		1	),
('BUILDING_ROASTING_FURNACE','RESOURCE_QUICKSILVER',	'YIELD_SCIENCE',	1	),
('BUILDING_MINT',			'RESOURCE_GOLD',			'YIELD_GOLD',		1	),
('BUILDING_MINT',			'RESOURCE_SILVER',			'YIELD_GOLD',		1	),
('BUILDING_STONE_WORKS',	'RESOURCE_STONE',			'YIELD_PRODUCTION', 1	), 
('BUILDING_STONE_WORKS',	'RESOURCE_STONE',			'YIELD_CULTURE',	1	), 
('BUILDING_STONE_WORKS',	'RESOURCE_MARBLE',			'YIELD_PRODUCTION', 1	),
('BUILDING_STONE_WORKS',	'RESOURCE_MARBLE',			'YIELD_CULTURE',	1	),
('BUILDING_MONASTERY',		'RESOURCE_WINE',			'YIELD_CULTURE',	1	),
('BUILDING_MONASTERY',		'RESOURCE_INCENCE',			'YIELD_CULTURE',	1	),
('BUILDING_BOWYER',			'RESOURCE_YEW',				'YIELD_PRODUCTION',	1	),
('BUILDING_BOWYER',			'RESOURCE_YEW',				'YIELD_CULTURE',	1	),
('BUILDING_DISTILLERY',		'RESOURCE_SUGAR',			'YIELD_CULTURE',	1	),
('BUILDING_DISTILLERY',		'RESOURCE_BANANA',			'YIELD_CULTURE',	1	),
('BUILDING_ARMORY',			'RESOURCE_COPPER',			'YIELD_PRODUCTION',	1	),
('BUILDING_ARMORY',			'RESOURCE_IRON',			'YIELD_PRODUCTION',	1	),
('BUILDING_ARMORY',			'RESOURCE_MITHRIL',			'YIELD_PRODUCTION',	1	),
('BUILDING_ARSENAL',		'RESOURCE_COPPER',			'YIELD_PRODUCTION',	1	),
('BUILDING_ARSENAL',		'RESOURCE_IRON',			'YIELD_PRODUCTION',	1	),
('BUILDING_ARSENAL',		'RESOURCE_MITHRIL',			'YIELD_PRODUCTION',	1	),
('BUILDING_LABORATORY',		'RESOURCE_NAPHTHA',			'YIELD_SCIENCE',	2	),
('BUILDING_LABORATORY',		'RESOURCE_MITHRIL',			'YIELD_SCIENCE',	2	),
('BUILDING_TEXTILE_MILL',	'RESOURCE_WOOL',			'YIELD_GOLD',		1	),
('BUILDING_TEXTILE_MILL',	'RESOURCE_COTTON',			'YIELD_GOLD',		1	),
('BUILDING_TEXTILE_MILL',	'RESOURCE_DYE',				'YIELD_GOLD',		1	),
('BUILDING_TEXTILE_MILL',	'RESOURCE_SILK',			'YIELD_GOLD',		1	),
('BUILDING_TEXTILE_MILL',	'RESOURCE_WOOL',			'YIELD_CULTURE',	1	),
('BUILDING_TEXTILE_MILL',	'RESOURCE_COTTON',			'YIELD_CULTURE',	1	),
('BUILDING_TEXTILE_MILL',	'RESOURCE_DYE',				'YIELD_CULTURE',	1	),
('BUILDING_TEXTILE_MILL',	'RESOURCE_SILK',			'YIELD_CULTURE',	1	),
('BUILDING_JEWELLER',		'RESOURCE_GOLD',			'YIELD_CULTURE',	1	),
('BUILDING_JEWELLER',		'RESOURCE_SILVER',			'YIELD_CULTURE',	1	),
('BUILDING_JEWELLER',		'RESOURCE_GEMS',			'YIELD_CULTURE',	1	),
('BUILDING_JEWELLER',		'RESOURCE_JADE',			'YIELD_CULTURE',	1	),
('BUILDING_JEWELLER',		'RESOURCE_PEARLS',			'YIELD_CULTURE',	1	),

('BUILDING_MAMONAS',		'RESOURCE_GOLD',			'YIELD_GOLD',		1	),
('BUILDING_MAMONAS',		'RESOURCE_SILVER',			'YIELD_GOLD',		1	),
('BUILDING_IKKOS',			'RESOURCE_HORSE',			'YIELD_CULTURE',	3	),
('BUILDING_AB',				'RESOURCE_ELEPHANT',		'YIELD_PRODUCTION',	1	),
('BUILDING_AB',				'RESOURCE_ELEPHANT',		'YIELD_CULTURE',	2	),
('BUILDING_NEITH',			'RESOURCE_COTTON',			'YIELD_GOLD',		1	),
('BUILDING_NEITH',			'RESOURCE_COTTON',			'YIELD_CULTURE',	1	),
('BUILDING_NEITH',			'RESOURCE_DYE',				'YIELD_GOLD',		1	),
('BUILDING_NEITH',			'RESOURCE_DYE',				'YIELD_CULTURE',	1	),
('BUILDING_NEITH',			'RESOURCE_SILK',			'YIELD_GOLD',		1	),
('BUILDING_NEITH',			'RESOURCE_SILK',			'YIELD_CULTURE',	1	),
('BUILDING_NEITH',			'RESOURCE_WOOL',			'YIELD_GOLD',		1	),
('BUILDING_NEITH',			'RESOURCE_WOOL',			'YIELD_CULTURE',	1	),

('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_BOARS',		'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_COW',			'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_CRAB',		'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_DEER',		'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_ELEPHANT',	'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_FISH',		'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_FUR',			'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_HORSE',		'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_PEARLS',		'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_SILK',		'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_WHALE',		'YIELD_CULTURE',	1	),
('BUILDING_1C_ANIMAL_RESOURCES','RESOURCE_WOOL',		'YIELD_CULTURE',	1	),

('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_BANANA',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_BERRIES',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_CITRUS',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_COTTON',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_DYE',			'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_INCENSE',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_MOLY',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_OPIUM',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_SPICES',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_SUGAR',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_TEA',			'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_TOBACCO',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_WHEAT',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_WINE',		'YIELD_CULTURE',	1	),
('BUILDING_1C_PLANT_RESOURCES',	'RESOURCE_YEW',			'YIELD_CULTURE',	1	),

('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_COPPER',		'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_GEMS',		'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_GOLD',		'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_IRON',		'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_JADE',		'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_MARBLE',		'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_MITHRIL',		'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_NAPHTHA',		'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_QUICKSILVER',	'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_SALT',		'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_SILVER',		'YIELD_CULTURE',	1	),
('BUILDING_1C_EARTH_RESOURCES',	'RESOURCE_STONE',		'YIELD_CULTURE',	1	),

('BUILDING_1C_VARIOUS_RESOURCES','RESOURCE_DYE',		'YIELD_CULTURE',	1	),
('BUILDING_1C_VARIOUS_RESOURCES','RESOURCE_MARBLE',		'YIELD_CULTURE',	1	),
('BUILDING_1C_VARIOUS_RESOURCES','RESOURCE_PEARLS',		'YIELD_CULTURE',	1	),
('BUILDING_1C_VARIOUS_RESOURCES','RESOURCE_GEMS',		'YIELD_CULTURE',	1	),
('BUILDING_1C_VARIOUS_RESOURCES','RESOURCE_JADE',		'YIELD_CULTURE',	1	),
('BUILDING_1C_VARIOUS_RESOURCES','RESOURCE_COPPER',		'YIELD_CULTURE',	1	),
('BUILDING_1C_VARIOUS_RESOURCES','RESOURCE_GOLD',		'YIELD_CULTURE',	1	),
('BUILDING_1C_VARIOUS_RESOURCES','RESOURCE_SILVER',		'YIELD_CULTURE',	1	),

('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_BANANA',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_BERRIES',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_CITRUS',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_COTTON',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_DYE',			'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_INCENSE',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_MOLY',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_OPIUM',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_SPICES',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_SUGAR',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_TEA',			'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_TOBACCO',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_WHEAT',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_WINE',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_1',	'RESOURCE_YEW',			'YIELD_FOOD',		1	),

('BUILDING_TEMPLE_AZZANDARA_2',	'RESOURCE_BOARS',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_2',	'RESOURCE_COW',			'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_2',	'RESOURCE_DEER',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_2',	'RESOURCE_ELEPHANT',	'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_2',	'RESOURCE_FUR',			'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_2',	'RESOURCE_HORSE',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_2',	'RESOURCE_SILK',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_2',	'RESOURCE_WOOL',		'YIELD_FOOD',		1	),

('BUILDING_TEMPLE_AZZANDARA_3',	'RESOURCE_CRAB',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_3',	'RESOURCE_FISH',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_3',	'RESOURCE_PEARLS',		'YIELD_FOOD',		1	),
('BUILDING_TEMPLE_AZZANDARA_3',	'RESOURCE_WHALE',		'YIELD_FOOD',		1	),

('BUILDING_TEMPLE_AZZANDARA_4',	'RESOURCE_STONE',		'YIELD_PRODUCTION',	1	),
('BUILDING_TEMPLE_AZZANDARA_4',	'RESOURCE_MARBLE',		'YIELD_PRODUCTION',	1	),
('BUILDING_TEMPLE_AZZANDARA_4',	'RESOURCE_JADE',		'YIELD_PRODUCTION',	1	),
('BUILDING_TEMPLE_AZZANDARA_4',	'RESOURCE_GEMS',		'YIELD_PRODUCTION',	1	),
('BUILDING_TEMPLE_AZZANDARA_4',	'RESOURCE_SALT',		'YIELD_PRODUCTION',	1	),

('BUILDING_TEMPLE_AZZANDARA_5',	'RESOURCE_NAPHTHA',		'YIELD_SCIENCE',	4	),

('BUILDING_TEMPLE_AZZANDARA_6',	'RESOURCE_COPPER',		'YIELD_PRODUCTION',	1	),
('BUILDING_TEMPLE_AZZANDARA_6',	'RESOURCE_IRON',		'YIELD_PRODUCTION',	1	),
('BUILDING_TEMPLE_AZZANDARA_6',	'RESOURCE_MITHRIL',		'YIELD_PRODUCTION',	1	),
('BUILDING_TEMPLE_AZZANDARA_6',	'RESOURCE_QUICKSILVER',	'YIELD_PRODUCTION',	1	),
('BUILDING_TEMPLE_AZZANDARA_6',	'RESOURCE_SILVER',		'YIELD_PRODUCTION',	1	),
('BUILDING_TEMPLE_AZZANDARA_6',	'RESOURCE_GOLD',		'YIELD_PRODUCTION',	1	);



DELETE FROM Building_DomainFreeExperiences;
INSERT INTO Building_DomainFreeExperiences(BuildingType, DomainType, Experience) VALUES
('BUILDING_BARRACKS',					'DOMAIN_LAND',				5	),
('BUILDING_SHIPYARD',					'DOMAIN_SEA',				5	);

DELETE FROM Building_DomainProductionModifiers;
--INSERT INTO Building_DomainProductionModifiers(BuildingType, DomainType, Modifier) VALUES
--('BUILDING_SHIPYARD', 'DOMAIN_SEA', 20 );

DELETE FROM Building_UnitCombatFreeExperiences;
INSERT INTO Building_UnitCombatFreeExperiences (BuildingType, UnitCombatType, Experience) VALUES
('BUILDING_BOWYER',						'UNITCOMBAT_ARCHER',		5	),
('BUILDING_ARMORY',						'UNITCOMBAT_MELEE',			5	),
('BUILDING_ARSENAL',					'UNITCOMBAT_MELEE',			5	),

('BUILDING_PLUS_1_LAND_XP',				'UNITCOMBAT_RECON',			1	),
('BUILDING_PLUS_1_LAND_XP',				'UNITCOMBAT_ARCHER',		1	),
('BUILDING_PLUS_1_LAND_XP',				'UNITCOMBAT_MOUNTED',		1	),
('BUILDING_PLUS_1_LAND_XP',				'UNITCOMBAT_MELEE',			1	),
('BUILDING_PLUS_1_LAND_XP',				'UNITCOMBAT_SIEGE',			1	),
('BUILDING_PLUS_1_LAND_XP',				'UNITCOMBAT_ARMOR',			1	),
('BUILDING_PLUS_1_SEA_XP',				'UNITCOMBAT_NAVALRANGED',	1	),
('BUILDING_PLUS_1_SEA_XP',				'UNITCOMBAT_NAVALMELEE',	1	);

DELETE FROM Building_UnitCombatProductionModifiers;
INSERT INTO Building_UnitCombatProductionModifiers(BuildingType, UnitCombatType, Modifier) VALUES
('BUILDING_WORKSHOP',					'UNITCOMBAT_SIEGE',			10	),
('BUILDING_FORGE',						'UNITCOMBAT_MELEE',			10	),
('BUILDING_STABLE',						'UNITCOMBAT_MOUNTED',		30	),
('BUILDING_ELEPHANT_STOCKADE',			'UNITCOMBAT_ARMOR',			20	),
('BUILDING_BOWYER',						'UNITCOMBAT_ARCHER',		20	),
('BUILDING_ARMORY',						'UNITCOMBAT_MELEE',			5	),
('BUILDING_ARSENAL',					'UNITCOMBAT_MELEE',			5	),
('BUILDING_SHIPYARD',					'UNITCOMBAT_NAVALRANGED',	20	),
('BUILDING_SHIPYARD',					'UNITCOMBAT_NAVALMELEE',	20	);

DELETE FROM Building_TechAndPrereqs;
INSERT INTO Building_TechAndPrereqs(BuildingType, TechType) VALUES
('BUILDING_LIGHTHOUSE', 'TECH_MASONRY' );

DELETE FROM Building_YieldChanges;
INSERT INTO Building_YieldChanges (BuildingType,	YieldType,	Yield) VALUES
('BUILDING_PALACE',						'YIELD_CULTURE',	2	),
('BUILDING_PALACE',						'YIELD_FOOD',		2	),
('BUILDING_PALACE',						'YIELD_PRODUCTION',	2	),
('BUILDING_PALACE',						'YIELD_GOLD',		2	),
('BUILDING_PALACE',						'YIELD_SCIENCE',	2	),
('BUILDING_MONUMENT',					'YIELD_CULTURE',	1	),
('BUILDING_WARRENS',					'YIELD_FOOD',		3 	),
('BUILDING_LIBRARY',					'YIELD_CULTURE',	1	),
('BUILDING_MARKETPLACE',				'YIELD_CULTURE',	1	),
('BUILDING_AMPHITHEATER',				'YIELD_CULTURE',	1	),
('BUILDING_WORKSHOP',					'YIELD_PRODUCTION',	1	),
('BUILDING_SHRINE',						'YIELD_FAITH',		2	),
('BUILDING_MAGE_SCHOOL',				'YIELD_FAITH',		2	),
('BUILDING_PHARMAKEIA',					'YIELD_FAITH',		2	),
('BUILDING_HUNTING_LODGE',				'YIELD_FOOD',		1	),
('BUILDING_HUNTING_LODGE',				'YIELD_GOLD',		1	),
('BUILDING_HARBOR',						'YIELD_FOOD',		1	),
('BUILDING_HARBOR',						'YIELD_GOLD',		1	),

('BUILDING_MOUNDS',						'YIELD_FAITH',		2	),
('BUILDING_RIVER_DOCK',					'YIELD_FOOD',		1	),
('BUILDING_RIVER_DOCK',					'YIELD_PRODUCTION',	1	),
('BUILDING_LIGHTHOUSE',					'YIELD_GOLD',		2	),
('BUILDING_MINT',						'YIELD_GOLD',		2	),
('BUILDING_WATERMILL',					'YIELD_FOOD',		2	),
('BUILDING_WATERMILL',					'YIELD_PRODUCTION',	2	),
('BUILDING_WINDMILL',					'YIELD_FOOD',		2	),
('BUILDING_WINDMILL',					'YIELD_PRODUCTION',	2	),
('BUILDING_WINERY',						'YIELD_CULTURE',	1	),
('BUILDING_SILOS',						'YIELD_FOOD',		2	),
('BUILDING_SMITHS_GUILD',				'YIELD_PRODUCTION',	1	),
('BUILDING_TRADERS_GUILD',				'YIELD_GOLD',		1	),
('BUILDING_SCRIBES_GUILD',				'YIELD_SCIENCE',	1	),
('BUILDING_ARTISANS_GUILD',				'YIELD_CULTURE',	1	),
('BUILDING_DISCIPLES_GUILD',			'YIELD_FAITH',		1	),
('BUILDING_ADEPTS_GUILD',				'YIELD_FAITH',		1	),
('BUILDING_MONASTIC_SCHOOL',			'YIELD_SCIENCE',	2	),
('BUILDING_UNIVERSITY',					'YIELD_CULTURE',	1	),
('BUILDING_UNIVERSITY',					'YIELD_SCIENCE',	4	),
('BUILDING_THEATRE',					'YIELD_CULTURE',	1	),
('BUILDING_OPERA_HOUSE',				'YIELD_CULTURE',	1	),
('BUILDING_MONASTERY',					'YIELD_CULTURE',	2	),
('BUILDING_MONASTERY',					'YIELD_FAITH',		2	),
('BUILDING_LABORATORY',					'YIELD_SCIENCE',	4	),
('BUILDING_GALLOWS',					'YIELD_PRODUCTION',	2	),
('BUILDING_DEBTORS_COURT',				'YIELD_GOLD',		2	),
('BUILDING_SLAVE_MARKET',				'YIELD_GOLD',		2	),
('BUILDING_SLAVE_KNACKERY',				'YIELD_PRODUCTION',	2	),
('BUILDING_SLAVE_STOCKADE',				'YIELD_PRODUCTION',	2	),
('BUILDING_SLAVE_BREEDING_PEN',			'YIELD_FOOD',		2	),
('BUILDING_PORT',						'YIELD_FOOD',		1	),
('BUILDING_PORT',						'YIELD_GOLD',		1	),
('BUILDING_WHALERY',					'YIELD_PRODUCTION',	1	),
('BUILDING_WHALERY',					'YIELD_GOLD',		1	),
('BUILDING_INTERNMENT_CAMP',			'YIELD_PRODUCTION',	2	),
('BUILDING_PAPERMILL',					'YIELD_SCIENCE',	2	),
('BUILDING_PAPERMILL',					'YIELD_CULTURE',	2	),
('BUILDING_JEWELLER',					'YIELD_GOLD',		1	),
('BUILDING_KILN',						'YIELD_GOLD',		1	),
('BUILDING_KILN',						'YIELD_CULTURE',	1	),
('BUILDING_CASTLE',						'YIELD_GOLD',		1	),
('BUILDING_CASTLE',						'YIELD_CULTURE',	1	),
('BUILDING_WAREHOUSES',					'YIELD_PRODUCTION',	2	),
('BUILDING_COLOSSEUM',					'YIELD_CULTURE',	1	),
('BUILDING_PRINTING_PRESS',				'YIELD_SCIENCE',	4	),
('BUILDING_OBSERVATORY',				'YIELD_SCIENCE',	6	),
('BUILDING_CHAMBER_THOUGHT',			'YIELD_SCIENCE',	5	),
('BUILDING_CONSCIOUSNESS_ENGINE',		'YIELD_SCIENCE',	8	),
('BUILDING_DEEP_FARMS',					'YIELD_FOOD',		2	),
('BUILDING_FLOATING_GARDENS',			'YIELD_FOOD',		1	),
('BUILDING_FOUNDRY',					'YIELD_PRODUCTION',	3	),
('BUILDING_FESTIVAL',					'YIELD_CULTURE',	3	),
('BUILDING_CULT_LEAVES_1F1C',			'YIELD_FOOD',		1 	),
('BUILDING_CULT_LEAVES_1F1C',			'YIELD_CULTURE',	1 	),
('BUILDING_CULT_CAHRA_1F',				'YIELD_FOOD',		1 	),
('BUILDING_TRADE_PLUS_1_GOLD',			'YIELD_GOLD',		1 	),
('BUILDING_REMOTE_RES_1_FOOD',			'YIELD_FOOD',		1 	),
('BUILDING_REMOTE_RES_1_PRODUCTION',	'YIELD_PRODUCTION', 1 	),
('BUILDING_REMOTE_RES_1_GOLD',			'YIELD_GOLD',		1 	),

('BUILDING_KOLOSSOS',					'YIELD_CULTURE',	4	),
('BUILDING_MEGALOS_FAROS',				'YIELD_CULTURE',	4	),
('BUILDING_UUC_YABNAL',					'YIELD_CULTURE',	4	),
('BUILDING_THE_LONG_WALL',				'YIELD_CULTURE',	4	),
('BUILDING_CLOG_MOR',					'YIELD_CULTURE',	4	),
('BUILDING_HANGING_GARDENS_MOD',		'YIELD_CULTURE',	1	),
('BUILDING_DA_BAOEN_SI_MOD',			'YIELD_CULTURE',	1	),

('BUILDING_MOD_STANHENCG',				'YIELD_FAITH',		1	),
('BUILDING_MOD_ARCANE_TOWER',			'YIELD_FAITH',		1	),

('BUILDING_TEMPLE_AZZANDARA_1',			'YIELD_CULTURE',	3	),
('BUILDING_TEMPLE_AZZANDARA_1',			'YIELD_FAITH',		3	),
('BUILDING_TEMPLE_AZZANDARA_2',			'YIELD_CULTURE',	5	),
('BUILDING_TEMPLE_AZZANDARA_2',			'YIELD_FAITH',		5	),
('BUILDING_TEMPLE_AZZANDARA_3',			'YIELD_CULTURE',	8	),
('BUILDING_TEMPLE_AZZANDARA_3',			'YIELD_FAITH',		8	),
('BUILDING_TEMPLE_AZZANDARA_4',			'YIELD_CULTURE',	13	),
('BUILDING_TEMPLE_AZZANDARA_4',			'YIELD_FAITH',		13	),
('BUILDING_TEMPLE_AZZANDARA_5',			'YIELD_CULTURE',	21	),
('BUILDING_TEMPLE_AZZANDARA_5',			'YIELD_FAITH',		21	),
('BUILDING_TEMPLE_AZZANDARA_6',			'YIELD_CULTURE',	34	),
('BUILDING_TEMPLE_AZZANDARA_6',			'YIELD_FAITH',		34	),
('BUILDING_TEMPLE_AZZANDARA_7',			'YIELD_CULTURE',	55	),
('BUILDING_TEMPLE_AZZANDARA_7',			'YIELD_FAITH',		55	),

('BUILDING_TEMPLE_AHRIMAN_1',			'YIELD_SCIENCE',	13	),
('BUILDING_TEMPLE_AHRIMAN_1',			'YIELD_FAITH',		13	),
('BUILDING_TEMPLE_AHRIMAN_2',			'YIELD_SCIENCE',	17	),
('BUILDING_TEMPLE_AHRIMAN_2',			'YIELD_FAITH',		17	),
('BUILDING_TEMPLE_AHRIMAN_3',			'YIELD_SCIENCE',	19	),
('BUILDING_TEMPLE_AHRIMAN_3',			'YIELD_FAITH',		19	),
('BUILDING_TEMPLE_AHRIMAN_4',			'YIELD_SCIENCE',	23	),
('BUILDING_TEMPLE_AHRIMAN_4',			'YIELD_FAITH',		23	),
('BUILDING_TEMPLE_AHRIMAN_5',			'YIELD_SCIENCE',	29	),
('BUILDING_TEMPLE_AHRIMAN_5',			'YIELD_FAITH',		29	),
('BUILDING_TEMPLE_AHRIMAN_6',			'YIELD_SCIENCE',	31	),
('BUILDING_TEMPLE_AHRIMAN_6',			'YIELD_FAITH',		31	),
('BUILDING_TEMPLE_AHRIMAN_7',			'YIELD_SCIENCE',	37	),
('BUILDING_TEMPLE_AHRIMAN_7',			'YIELD_FAITH',		37	),
('BUILDING_TEMPLE_AHRIMAN_8',			'YIELD_SCIENCE',	41	),
('BUILDING_TEMPLE_AHRIMAN_8',			'YIELD_FAITH',		41	),
('BUILDING_TEMPLE_AHRIMAN_9',			'YIELD_SCIENCE',	43	),
('BUILDING_TEMPLE_AHRIMAN_9',			'YIELD_FAITH',		43	);


DELETE FROM Building_YieldChangesPerPop;
INSERT INTO Building_YieldChangesPerPop (BuildingType,	YieldType,	Yield) VALUES
('BUILDING_LIBRARY',					'YIELD_SCIENCE',		50	),
('BUILDING_MAN',						'YIELD_PRODUCTION',		100	),
('BUILDING_SIDHE',						'YIELD_PRODUCTION',		100	),
('BUILDING_HELDEOFOL',					'YIELD_PRODUCTION',		100	);
--('BUILDING_MAN',						'YIELD_GOLD',			100	),
--('BUILDING_SIDHE',					'YIELD_GOLD',			100	),
--('BUILDING_HELDEOFOL',				'YIELD_GOLD',			100 );

DELETE FROM Building_YieldModifiers;	--warning! culture & faith don't work
INSERT INTO Building_YieldModifiers (BuildingType, YieldType, Yield) VALUES
('BUILDING_SALTWORKS',					'YIELD_FOOD',			10	),
('BUILDING_SALTWORKS',					'YIELD_FOOD',			10	),
('BUILDING_FACTORY',					'YIELD_PRODUCTION',		10	),
('BUILDING_BANK',						'YIELD_GOLD',			10	),

('BUILDING_LIBRARY',					'YIELD_SCIENCE',		5	),
('BUILDING_APOTHECARY',					'YIELD_SCIENCE',		2	),
('BUILDING_SCRIBES_GUILD',				'YIELD_SCIENCE',		1	),
('BUILDING_MONASTIC_SCHOOL',			'YIELD_SCIENCE',		2	),
('BUILDING_PAPERMILL',					'YIELD_SCIENCE',		5	),
('BUILDING_UNIVERSITY',					'YIELD_SCIENCE',		10	),

('BUILDING_PRINTING_PRESS',				'YIELD_SCIENCE',		5	),
('BUILDING_OBSERVATORY',				'YIELD_SCIENCE',		5	),
('BUILDING_CHAMBER_THOUGHT',			'YIELD_SCIENCE',		25	),
('BUILDING_CONSCIOUSNESS_ENGINE',		'YIELD_SCIENCE',		40	),
('BUILDING_LABORATORY',					'YIELD_SCIENCE',		5	),
('BUILDING_MUSEUM',						'YIELD_SCIENCE',		2	),

('BUILDING_ANRA_FOLLOWER',				'YIELD_FOOD',			-25	),
('BUILDING_CULT_OF_BAKKHEIA_FOLLOWER',	'YIELD_PRODUCTION',		-15	),

('BUILDING_UUC_YABNAL_MOD',				'YIELD_PRODUCTION',		1	);



INSERT INTO EaDebugTableCheck(FileName) SELECT 'Buildings.sql';

