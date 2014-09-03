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
						'ShowInTechTree' BOOLEAN DEFAULT NULL,
						--AI
						'AICombatRole' TEXT DEFAULT NULL,	-- Planned: "CityCapture", "CrowdControl", "Any"; Types don't matter now: any non-NULL understood as having combat role
						'AIDontCombatOverride' BOOLEAN DEFAULT NULL,	-- =NULL or 1 (eg, Citadel) Otherwise, GP with combat role will drop what they are doing (if <1/2 done) and go to a combat zone
						'AITarget' TEXT DEFAULT NULL,		-- Search heuristic. See AITarget methods in EaAIActions.lua
						'AITarget2' TEXT DEFAULT NULL,	
						'AISimpleYield' INTEGER DEFAULT 0,	-- Sets the "per turn payoff" value (p); not needed if AI values set in specific SetAIValues function in EaAction.lua
						'AIAdHocValue' INTEGER DEFAULT 0,	-- Sets an "instant payoff" value (i); not needed if AI values set in specific SetAIValues function in EaAction.lua
						--Spells (if set, all "caster reqs" below are treated as "learn prereq"; they don't apply to casting)
						'SpellClass' TEXT DEFAULT NULL,	--'Divine', 'Arcane', 'Both' or NULL
						'FreeSpellSubclass' TEXT DEFAULT NULL,
						'FallenAltSpell' TEXT DEFAULT NULL,
						--'MinimumModToLearn' INTEGER DEFAULT 0,	--spells only
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
						'ExcludeFallen' BOOLEAN DEFAULT NULL,
						'ReqEaWonder' TEXT DEFAULT NULL,
						'AhrimansVaultMatters' BOOLEAN DEFAULT NULL,		-- blocked for Fallen when Ahriman's Vault is sealed (always for spells)

						--Unit reqs (any EaAction may also have a Lua req defined in EaActions.lua)
						'GPOnly' BOOLEAN DEFAULT NULL,
						'GPClass' TEXT DEFAULT NULL,	
						'OrGPClass' TEXT DEFAULT NULL,	
						'NotGPClass' TEXT DEFAULT NULL,		
						'GPSubclass' TEXT DEFAULT NULL,	
						'OrGPSubclass' TEXT DEFAULT NULL,
						'ExcludeGPSubclass' TEXT DEFAULT NULL,
						'ExcludeGPSubclass2' TEXT DEFAULT NULL,
						'RestrictedToGPSubclass' TEXT DEFAULT NULL,	--only added for spell now
						'LevelReq' INTEGER DEFAULT NULL,
						'PromotionReq' TEXT DEFAULT NULL,
						'PromotionDisallow' TEXT DEFAULT NULL,
						'PromotionDisallow2' TEXT DEFAULT NULL,
						'PromotionDisallow3' TEXT DEFAULT NULL,
						'PantheismCult' TEXT DEFAULT NULL,			--doesn't do anything now except restrict to pantheistic
						'KnowsSpell' TEXT DEFAULT NULL,				--only works for spell learning
						--non-GP caster prereqs
						'UnitCombatType' TEXT DEFAULT NULL,		
						'NormalCombatUnit' BOOLEAN DEFAULT NULL,		
						'UnitType' TEXT DEFAULT NULL,			
						'OrUnitType' TEXT DEFAULT NULL,			
						'OrUnitType2' TEXT DEFAULT NULL,		
						'UnitTypePrefix1' TEXT DEFAULT NULL,	
						'UnitTypePrefix2' TEXT DEFAULT NULL,	
						'UnitTypePrefix3' TEXT DEFAULT NULL,	
						'AIBlacklist' BOOLEAN DEFAULT NULL,		--NOT IMPLEMENTED!					
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
						'ConsiderTowerTemple' BOOLEAN DEFAULT NULL,
						'NoGPNumLimit' BOOLEAN DEFAULT NULL,
						'FinishMoves' BOOLEAN DEFAULT 1,
						'StayInvisible' BOOLEAN DEFAULT NULL,
						'TurnsToComplete' INTEGER DEFAULT 1,	--1 immediate; >1 will run until done; 1000 means run forever for human (changes to 8 for AI so they will wake up and look around)
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

INSERT INTO EaActions (ID,	Type,	GPOnly,	IconIndex,	IconAtlas			) VALUES
(-1,	'EA_ACTION_CANCEL',			1,		39,			'UNIT_ACTION_ATLAS'	),	--human only (dll doesn't know about these actions, so we need our own cancel)
(0,		'EA_ACTION_GO_TO_PLOT',		1,		-1,			NULL				);	--special action; must have ID = 0


--StayInvisible

--Order here is the order they will appear in actions or builds panel (all before core game actions and builds)

--Non-GP
INSERT INTO EaActions (Type,			UnitTypePrefix1,	NormalCombatUnit,	UIType,		AITarget,		City,	IconIndex,	IconAtlas		) VALUES
('EA_ACTION_SELL_SLAVES',				'UNIT_SLAVES',		NULL,				'Action',	'OwnCities',	'Own',	17,			'TECH_ATLAS_1'	),
('EA_ACTION_RENDER_SLAVES',				'UNIT_SLAVES',		NULL,				'Action',	'OwnCities',	'Own',	5,			'TECH_ATLAS_1'	),
('EA_ACTION_HIRE_OUT_MERC',				NULL,				1,					'Action',	'Self',			NULL,	17,			'TECH_ATLAS_1'	),
('EA_ACTION_CANC_HIRE_OUT_MERC',		NULL,				1,					'Action',	'Self',			NULL,	17,			'TECH_ATLAS_1'	);

UPDATE EaActions SET BuildingReq = 'BUILDING_SLAVE_MARKET' WHERE Type = 'EA_ACTION_SELL_SLAVES';
UPDATE EaActions SET BuildingReq = 'BUILDING_SLAVE_KNACKERY' WHERE Type = 'EA_ACTION_RENDER_SLAVES';
UPDATE EaActions SET FinishMoves = NULL, PolicyReq = 'POLICY_MERCENARIES', PromotionDisallow = 'PROMOTION_FOR_HIRE', PromotionDisallow2 = 'PROMOTION_MERCENARY', PromotionDisallow3 = 'PROMOTION_SLAVE' WHERE Type = 'EA_ACTION_HIRE_OUT_MERC';
UPDATE EaActions SET FinishMoves = NULL, PolicyReq = 'POLICY_MERCENARIES', PromotionReq = 'PROMOTION_FOR_HIRE' WHERE Type = 'EA_ACTION_CANC_HIRE_OUT_MERC';

--Non-GP alternate upgrades
INSERT INTO EaActions (Type,			UnitTypePrefix1,		UnitTypePrefix2,		UnitTypePrefix3,	TechReq,				UnitUpgradeTypePrefix	) VALUES
('EA_ACTION_UPGRD_MED_INF',				'UNIT_WARRIORS',		NULL,					NULL,				'TECH_IRON_WORKING',	'UNIT_MEDIUM_INFANTRY'	),
('EA_ACTION_UPGRD_HEAVY_INF',			'UNIT_RANGERS',			NULL,					NULL,				'TECH_METAL_CASTING',	'UNIT_HEAVY_INFANTRY'	),
('EA_ACTION_UPGRD_IMMORTALS',			'UNIT_WARRIORS',		'UNIT_LIGHT_INFANTRY',	'UNIT_RANGERS',		'TECH_MITHRIL_WORKING',	'UNIT_IMMORTALS'		),
('EA_ACTION_UPGRD_ARQUEBUSSMEN',		'UNIT_ARCHERS',			NULL,					NULL,				'TECH_MACHINERY',		'UNIT_ARQUEBUSSMEN'		),
('EA_ACTION_UPGRD_BOWMEN',				'UNIT_TRACKERS',		NULL,					NULL,				'TECH_BOWYERS',			'UNIT_BOWMEN'			),
('EA_ACTION_UPGRD_MARKSMEN',			'UNIT_RANGERS',			NULL,					NULL,				'TECH_MARKSMANSHIP',	'UNIT_MARKSMEN'			),
('EA_ACTION_UPGRD_ARMORED_CAV',			'UNIT_HORSEMEN',		NULL,					NULL,				'TECH_STIRRUPS',		'UNIT_ARMORED_CAVALRY'	),
('EA_ACTION_UPGRD_CATAPHRACTS',			'UNIT_EQUITES',			'UNIT_RANGERS',			NULL,				'TECH_WAR_HORSES',		'UNIT_CATAPHRACTS'		),
('EA_ACTION_UPGRD_CLIBANARII',			'UNIT_EQUITES',			'UNIT_RANGERS',			NULL,				'TECH_MITHRIL_WORKING',	'UNIT_CLIBANARII'		),
('EA_ACTION_UPGRD_F_CATAPULTS',			'UNIT_CATAPULTS',		NULL,					NULL,				'TECH_MATHEMATICS',		'UNIT_FIRE_CATAPULTS'	),
('EA_ACTION_UPGRD_F_TREBUCHETS',		'UNIT_TREBUCHETS',		NULL,					NULL,				'TECH_MECHANICS',		'UNIT_FIRE_TREBUCHETS'	),
('EA_ACTION_UPGRD_SLAVES_WARRIORS',		'UNIT_SLAVES',			NULL,					NULL,				NULL,					'UNIT_WARRIORS'			);

UPDATE EaActions SET Description = 'TXT_KEY_COMMAND_UPGRADE' WHERE Type GLOB 'EA_ACTION_UPGRD_*';
UPDATE EaActions SET UIType = 'Action', AITarget = 'Self', OwnTerritory = 1, IconIndex = 44, IconAtlas = 'UNIT_ACTION_ATLAS' WHERE UnitUpgradeTypePrefix IS NOT NULL;
UPDATE EaActions SET AndTechReq = 'TECH_CHEMISTRY' WHERE Type = 'EA_ACTION_UPGRD_ARQUEBUSSMEN';
UPDATE EaActions SET AndTechReq = 'TECH_WAR_HORSES' WHERE Type = 'EA_ACTION_UPGRD_CLIBANARII';
UPDATE EaActions SET NormalCombatUnit = 1 WHERE UnitUpgradeTypePrefix IS NOT NULL AND Type != 'EA_ACTION_UPGRD_SLAVES_WARRIORS';
UPDATE EaActions SET PolicyReq = 'POLICY_SLAVE_ARMIES' WHERE Type = 'EA_ACTION_UPGRD_SLAVES_WARRIORS';

--
--GP actions
--Lua assumes that EA_ACTION_TAKE_LEADERSHIP is the first GP action

--Common actions
INSERT INTO EaActions (Type,			GPOnly,	UIType,		AITarget,		City,	GPModType1,			ProgressHolder,	IconIndex,	IconAtlas			) VALUES
('EA_ACTION_TAKE_LEADERSHIP',			1,		'Action',	'OwnCapital',	'Own',	'EAMOD_LEADERSHIP',	NULL,			0,			'EA_ACTION_ATLAS'	),
--('EA_ACTION_JOIN',					1,		'Action',	NULL,			NULL,	NULL,				NULL,			18,			'UNIT_ACTION_ATLAS' ),
('EA_ACTION_HEAL',						1,		'Action',	'Self',			NULL,	NULL,				NULL,			40,			'UNIT_ACTION_ATLAS'	);

UPDATE EaActions SET CapitalOnly = 1 WHERE Type = 'EA_ACTION_TAKE_LEADERSHIP';
UPDATE EaActions SET TurnsToComplete = 1, StayInvisible = 1 WHERE Type = 'EA_ACTION_HEAL';

--GP yield actions
INSERT INTO EaActions (Type,			GPOnly,	NoGPNumLimit,	UIType,		AITarget,			GPClass,		City,		GPModType1,				TurnsToComplete,	ProgressHolder,	IconIndex,	IconAtlas				) VALUES
('EA_ACTION_BUILD',						1,		1,				'Action',	'OwnCities',		'Engineer',		'Own',		NULL,					1000,				'Self',		5,			'TECH_ATLAS_1'			),
('EA_ACTION_TRADE',						1,		1,				'Action',	'OwnCities',		'Merchant',		'Own',		'EAMOD_TRADE',			1000,				'Self',		17,			'TECH_ATLAS_1'			),
('EA_ACTION_RESEARCH',					1,		1,				'Action',	'OwnCities',		'Sage',			'Own',		'EAMOD_SCHOLARSHIP',	1000,				'Self',		11,			'BW_ATLAS_1'			),
('EA_ACTION_PERFORM',					1,		1,				'Action',	'OwnCities',		'Artist',		'Own',		'EAMOD_BARDING',		1000,				'Self',		44,			'BW_ATLAS_1'			),
('EA_ACTION_RECRUIT',					1,		1,				'Action',	'OwnCities',		'Warrior',		'Own',		'EAMOD_LOGISTICS',		1000,				'Self',		5,			'BW_ATLAS_1'			),
('EA_ACTION_WORSHIP',					1,		1,				'Action',	'OwnCities',		'Devout',		'Own',		'EAMOD_DEVOTION',		1000,				'Self',		17,			'BW_ATLAS_2'			),
('EA_ACTION_CHANNEL',					1,		1,				'Action',	'TowerTemple',		'Thaumaturge',	'Not',		'EAMOD_EVOCATION',		1000,				'Self',		17,			'BW_ATLAS_2'			);

UPDATE EaActions SET NotGPClass = 'Devout' WHERE Type = 'EA_ACTION_CHANNEL';
UPDATE EaActions SET FinishMoves = NULL WHERE Type IN ('EA_ACTION_BUILD', 'EA_ACTION_RECRUIT');
UPDATE EaActions SET AhrimansVaultMatters = 1 WHERE Type IN ('EA_ACTION_WORSHIP', 'EA_ACTION_CHANNEL');

--Warrior actions & similar
INSERT INTO EaActions (Type,			GPOnly,	UIType,		GPClass,		AITarget,		AICombatRole,	GPModType1,				TurnsToComplete,	HumanVisibleFX,	IconIndex,	IconAtlas		) VALUES
('EA_ACTION_LEAD_CHARGE',				1,		'Action',	'Warrior',		NULL,			'Any',			'EAMOD_COMBAT',			1,					1,				6,			'BW_ATLAS_1'	),
('EA_ACTION_RALLY_TROOPS',				1,		'Action',	'Warrior',		NULL,			'Any',			'EAMOD_LEADERSHIP',		1,					1,				33,			'TECH_ATLAS_1'	),
--('EA_ACTION_FORTIFY_TROOPS',			1,		'Action',	'Warrior',		NULL,			'Any',			'EAMOD_LOGISTICS',		1,					1,				6,			'BW_ATLAS_1'	),
('EA_ACTION_SHRUG_OFF_INJURIES',		1,		'Action',	'Warrior',		'Self',			NULL,			'EAMOD_COMBAT',			1,					1,				40,			'UNIT_ACTION_ATLAS'	),
('EA_ACTION_RESTORE_TROOPS',			1,		'Action',	'Warrior',		'OwnTroops',	NULL,			'EAMOD_LOGISTICS',		1,					1,				40,			'UNIT_ACTION_ATLAS'	),
('EA_ACTION_REPAIR_WAR_CONSTRUCTS',		1,		'Action',	'Engineer',		'OwnConstructs',NULL,			'EAMOD_COMBAT_ENGINEERING',1,				1,				40,			'UNIT_ACTION_ATLAS'	),
('EA_ACTION_REPAIR_SHIPS',				1,		'Action',	'Engineer',		'OwnShips'	,	NULL,			'EAMOD_LOGISTICS',		1,					1,				40,			'UNIT_ACTION_ATLAS'	),
('EA_ACTION_TRAIN',						1,		'Action',	'Warrior',		'OwnTroops',	NULL,			'EAMOD_LOGISTICS',		1000,				1,				5,			'BW_ATLAS_1'	);

UPDATE EaActions SET FinishMoves = NULL, GPModType2 = 'EAMOD_LEADERSHIP' WHERE Type = 'EA_ACTION_LEAD_CHARGE';
UPDATE EaActions SET GPSubclass = 'SeaWarrior' WHERE Type = 'EA_ACTION_REPAIR_SHIPS';

--Misc actions
INSERT INTO EaActions (Type,			GPOnly,	UIType,		GPClass,		OwnTerritory,	AITarget,		AICombatRole,	GPModType1,	AhrimansVaultMatters,	TurnsToComplete,	ProgressHolder,	HumanVisibleFX,	IconIndex,	IconAtlas					) VALUES
('EA_ACTION_LEARN_SPELL',				1,		'Action',	'Thaumaturge',	NULL,			'SelfTowerTemple',NULL,			NULL,		1,						NULL,				'Self',			1,				2,			'EXPANSION_SCEN_TECH_ATLAS'	),
('EA_ACTION_OCCUPY_TOWER',				1,		'Action',	'Thaumaturge',	1,				'VacantTower',	NULL,			NULL,		1,						3,					'Self',			1,				6,			'BW_ATLAS_1'				),
('EA_ACTION_OCCUPY_TEMPLE',				1,		'Action',	'Devout',		1,				'VacantTemple',	NULL,			NULL,		1,						3,					'Self',			1,				6,			'BW_ATLAS_1'				),
('EA_ACTION_BECOME_MAGE',				1,		'Action',	'Thaumaturge',	1,				'Self',			NULL,			NULL,		NULL,					1,					NULL,			1,				44,			'UNIT_ACTION_ATLAS'			),
('EA_ACTION_BECOME_ARCHMAGE',			1,		'Action',	'Thaumaturge',	1,				'Self',			NULL,			NULL,		NULL,					1,					NULL,			1,				44,			'UNIT_ACTION_ATLAS'			),
('EA_ACTION_PURGE',						1,		'Action',	NULL,			NULL,			'Purge',		NULL,			NULL,		NULL,					3,					'CityCiv',		1,				6,			'BW_ATLAS_1'				);

UPDATE EaActions SET OrGPClass = 'Devout', ConsiderTowerTemple = 1, FinishMoves = NULL, NoGPNumLimit = 1 WHERE Type = 'EA_ACTION_LEARN_SPELL';
UPDATE EaActions SET NotGPClass = 'Devout' WHERE Type = 'EA_ACTION_OCCUPY_TOWER';
UPDATE EaActions SET OrGPClass = 'Sage', NotGPClass = 'Devout', ExcludeGPSubclass = 'Mage', ExcludeGPSubclass2 = 'Archmage', PolicyReq = 'POLICY_MAGERY' WHERE Type = 'EA_ACTION_BECOME_MAGE';
UPDATE EaActions SET OrGPClass = 'Sage', NotGPClass = 'Devout', ExcludeGPSubclass = 'Archmage', PolicyReq = 'POLICY_MAGERY', LevelReq = 15 WHERE Type = 'EA_ACTION_BECOME_ARCHMAGE';

--Prophecies
INSERT INTO EaActions (Type,			GPOnly,	TechReq,					DoXP,	AITarget,		AIAdHocValue,	GPClass,	City,	AhrimansVaultMatters,	UniqueType,	PlayAnywhereSound,					IconIndex,	IconAtlas							) VALUES
('EA_ACTION_PROPHECY_YAZATAS',			1,		NULL,						100,	'OwnCities',	10000,			'Devout',	'Own',	NULL,					'World',	'AS2D_EVENT_NOTIFICATION_GOOD',		16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_MITHRA',			1,		NULL,						100,	'OwnCities',	10000,			'Devout',	'Own',	NULL,					'World',	'AS2D_EVENT_NOTIFICATION_GOOD',		16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_TZIMTZUM',			1,		NULL,						100,	'Self',			0,				'Devout',	NULL,	NULL,					'World',	'AS2D_EVENT_NOTIFICATION_VERY_BAD',	16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_ANRA',				1,		'TECH_MALEFICIUM',			100,	'OwnCities',	10000,			'Devout',	'Own',	1,						'World',	'AS2D_EVENT_NOTIFICATION_VERY_BAD',	16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_AESHEMA',			1,		NULL,						100,	'Self',			0,				NULL,		NULL,	1,						'World',	'AS2D_EVENT_NOTIFICATION_VERY_BAD',	16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_ORDO_SALUTIS',		1,		'TECH_KNOWLEDGE_OF_HEAVEN',	NULL,	'Self',			0,				'Devout',	NULL,	NULL,					'World',	'AS2D_EVENT_NOTIFICATION_VERY_BAD',	16,			'EXPANSION_UNIT_ATLAS_1'			),
('EA_ACTION_PROPHECY_ORDO_DAMNATIO',	1,		'TECH_ARMAGEDDON_RITUALS',	NULL,	'Self',			0,				'Devout',	NULL,	1,						'World',	'AS2D_EVENT_NOTIFICATION_VERY_BAD',	16,			'EXPANSION_UNIT_ATLAS_1'			);

UPDATE EaActions SET DoGainPromotion = 'PROMOTION_PROPHET', UIType = 'Spell' WHERE Type GLOB 'EA_ACTION_PROPHECY_*';
UPDATE EaActions SET ReligionNotFounded = 'RELIGION_AZZANDARAYASNA', PolicyReq = 'POLICY_THEISM', TechDisallow = 'TECH_MALEFICIUM', ExcludeFallen = 1 WHERE Type = 'EA_ACTION_PROPHECY_YAZATAS';
UPDATE EaActions SET ReligionNotFounded = 'RELIGION_ANRA' WHERE Type = 'EA_ACTION_PROPHECY_ANRA';
UPDATE EaActions SET ReligionFounded = 'RELIGION_AZZANDARAYASNA', PolicyReq = 'POLICY_THEISM', TechDisallow = 'TECH_MALEFICIUM', CivReligion = 'RELIGION_AZZANDARAYASNA', ExcludeFallen = 1 WHERE Type = 'EA_ACTION_PROPHECY_MITHRA';

--Wonders
INSERT INTO EaActions (Type,			GPOnly,	TechReq,					UIType,		FinishXP,	AITarget,			AIAdHocValue,	AhrimansVaultMatters,	GPClass,		GPSubclass,	OrGPSubclass,	City,	OwnCityRadius,	ClaimsPlot,	GPModType1,				TurnsToComplete,	ProgressHolder,	BuildType,					ImprovementType,					UniqueType,	EaWonder,						MeetGod,						ReqEaWonder,					ReqNearbyCityReligion,			Building,					BuildingMod,					IconIndex,	IconAtlas					) VALUES
('EA_ACTION_KOLOSSOS',					1,		'TECH_BRONZE_WORKING',		'Build',	100,		'OwnCities',		0,				NULL,					'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_KOLOSSOS',			NULL,							NULL,							NULL,							'BUILDING_KOLOSSOS',		'BUILDING_KOLOSSOS_MOD',		4,			'BW_ATLAS_2'				),
('EA_ACTION_MEGALOS_FAROS',				1,		'TECH_SAILING',				'Build',	100,		'OwnCities',		0,				NULL,					'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_MEGALOS_FAROS',		NULL,							NULL,							NULL,							'BUILDING_MEGALOS_FAROS',	'BUILDING_MEGALOS_FAROS_MOD',	5,			'BW_ATLAS_2'				),
('EA_ACTION_HANGING_GARDENS',			1,		'TECH_IRRIGATION',			'Build',	100,		'OwnCities',		0,				NULL,					'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_HANGING_GARDENS',	NULL,							NULL,							NULL,							'BUILDING_HANGING_GARDENS',	'BUILDING_HANGING_GARDENS_MOD',	3,			'BW_ATLAS_2'				),
('EA_ACTION_UUC_YABNAL',				1,		'TECH_MASONRY',				'Build',	100,		'OwnCities',		0,				NULL,					'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_UUC_YABNAL',			NULL,							NULL,							NULL,							'BUILDING_UUC_YABNAL',		'BUILDING_UUC_YABNAL_MOD',		12,			'BW_ATLAS_2'				),
('EA_ACTION_THE_LONG_WALL',				1,		'TECH_CONSTRUCTION',		'Build',	100,		'OwnCities',		0,				NULL,					'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_THE_LONG_WALL',		NULL,							NULL,							NULL,							'BUILDING_THE_LONG_WALL',	'BUILDING_THE_LONG_WALL_MOD',	7,			'BW_ATLAS_2'				),
('EA_ACTION_CLOG_MOR',					1,		'TECH_MACHINERY',			'Build',	100,		'OwnCities',		0,				NULL,					'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_CLOG_MOR',			NULL,							NULL,							NULL,							'BUILDING_CLOG_MOR',		'BUILDING_CLOG_MOR_MOD',		19,			'BW_ATLAS_2'				),
('EA_ACTION_DA_BAOEN_SI',				1,		'TECH_ARCHITECTURE',		'Build',	100,		'OwnCities',		0,				NULL,					'Engineer',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_CONSTRUCTION',	25,					'City',			NULL,						NULL,								'World',	'EA_WONDER_DA_BAOEN_SI',		NULL,							NULL,							NULL,							'BUILDING_DA_BAOEN_SI',		'BUILDING_DA_BAOEN_SI_MOD',		16,			'BW_ATLAS_2'				),

('EA_ACTION_NATIONAL_TREASURY',			1,		'TECH_COINAGE',				'Build',	100,		'OwnCities',		0,				NULL,					'Merchant',		NULL,		NULL,			'Own',	NULL,			NULL,		'EAMOD_TRADE',			25,					'City',			NULL,						NULL,								'National',	NULL,							NULL,							NULL,							NULL,							NULL,						'BUILDING_NATIONAL_TREASURY',	1,			'NEW_BLDG_ATLAS_DLC'		),

--plot wonders
('EA_ACTION_STANHENCG',					1,		NULL,						'Build',	100,		'WonderWorkPlot',	0,				1,						NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_STANHENCG',			'IMPROVEMENT_STANHENCG',			'World',	'EA_WONDER_STANHENCG',			NULL,							NULL,							NULL,							NULL,						NULL,							2,			'BW_ATLAS_2'				),
('EA_ACTION_PYRAMID',					1,		'TECH_MASONRY',				'Build',	100,		'WonderWorkPlot',	0,				NULL,					'Engineer',		NULL,		NULL,			'Not',	1,				1,			'EAMOD_CONSTRUCTION',	25,					'Plot',			'BUILD_PYRAMID',			'IMPROVEMENT_PYRAMID',				'World',	'EA_WONDER_PYRAMID',			NULL,							NULL,							NULL,							NULL,						NULL,							0,			'BW_ATLAS_2'				),
('EA_ACTION_GREAT_LIBRARY',				1,		'TECH_PHILOSOPHY',			'Build',	100,		'WonderWorkPlot',	0,				NULL,					'Sage',			NULL,		NULL,			'Not',	1,				1,			'EAMOD_SCHOLARSHIP',	25,					'Plot',			'BUILD_GREAT_LIBRARY',		'IMPROVEMENT_GREAT_LIBRARY',		'World',	'EA_WONDER_GREAT_LIBRARY',		NULL,							NULL,							NULL,							NULL,						NULL,							1,			'BW_ATLAS_2'				),
('EA_ACTION_ACADEMY_PHILOSOPHY',		1,		'TECH_PHILOSOPHY',			'Build',	100,		'WonderWorkPlot',	0,				NULL,					'Sage',			NULL,		NULL,			'Not',	1,				1,			'EAMOD_SCHOLARSHIP',	25,					'Plot',			'BUILD_ACADEMY_PHILOSOPHY',	'IMPROVEMENT_ACADEMY_PHILOSOPHY',	'World',	'EA_WONDER_ACADEMY_PHILOSOPHY',	NULL,							NULL,							NULL,							NULL,						NULL,							1,			'BW_ATLAS_2'				),
('EA_ACTION_ACADEMY_LOGIC',				1,		'TECH_LOGIC',				'Build',	100,		'WonderWorkPlot',	0,				NULL,					'Sage',			NULL,		NULL,			'Not',	1,				1,			'EAMOD_SCHOLARSHIP',	25,					'Plot',			'BUILD_ACADEMY_LOGIC',		'IMPROVEMENT_ACADEMY_LOGIC',		'World',	'EA_WONDER_ACADEMY_LOGIC',		NULL,							NULL,							NULL,							NULL,						NULL,							1,			'BW_ATLAS_2'				),
('EA_ACTION_ACADEMY_SEMIOTICS',			1,		'TECH_SEMIOTICS',			'Build',	100,		'WonderWorkPlot',	0,				NULL,					'Sage',			NULL,		NULL,			'Not',	1,				1,			'EAMOD_SCHOLARSHIP',	25,					'Plot',			'BUILD_ACADEMY_SEMIOTICS',	'IMPROVEMENT_ACADEMY_SEMIOTICS',	'World',	'EA_WONDER_ACADEMY_SEMIOTICS',	NULL,							NULL,							NULL,							NULL,						NULL,							1,			'BW_ATLAS_2'				),
('EA_ACTION_ACADEMY_METAPHYSICS',		1,		'TECH_METAPHYSICS',			'Build',	100,		'WonderWorkPlot',	0,				NULL,					'Sage',			NULL,		NULL,			'Not',	1,				1,			'EAMOD_SCHOLARSHIP',	25,					'Plot',			'BUILD_ACADEMY_METAPHYSICS','IMPROVEMENT_ACADEMY_METAPHYSICS',	'World',	'EA_WONDER_ACADEMY_METAPHYSICS',NULL,							NULL,							NULL,							NULL,						NULL,							1,			'BW_ATLAS_2'				),
('EA_ACTION_ACADEMY_TRANS_THOUGHT',		1,		'TECH_TRANSCENDENTAL_THOUGHT','Build',	100,		'WonderWorkPlot',	0,				NULL,					'Sage',			NULL,		NULL,			'Not',	1,				1,			'EAMOD_SCHOLARSHIP',	25,					'Plot',			'BUILD_ACADEMY_TRANS_THOUGHT','IMPROVEMENT_ACADEMY_TRANS_THOUGHT','World',	'EA_WONDER_ACADEMY_TRANS_THOUGHT',NULL,							NULL,							NULL,							NULL,						NULL,							1,			'BW_ATLAS_2'				),

('EA_ACTION_ARCANE_TOWER',				1,		'TECH_THAUMATURGY',			'Build',	100,		'WonderNoWorkPlot',	0,				1,						'Thaumaturge',	NULL,		NULL,			'Not',	1,				1,			NULL,					25,					'Plot',			'BUILD_ARCANE_TOWER',		'IMPROVEMENT_ARCANE_TOWER',			NULL,		NULL,							NULL,							NULL,							NULL,							NULL,						NULL,							3,			'UNIT_ACTION_ATLAS_EXP2'	),
('EA_ACTION_TEMPLE_AZZANDARA_1',		1,		'TECH_DIVINE_LITURGY',		'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_1',	'IMPROVEMENT_TEMPLE_AZZANDARA_1',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_1',	NULL,							NULL,							'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_2',		1,		'TECH_DIVINE_VITALISM',		'Build',	100,		'WonderWorkPlot',	2000,			NULL,					NULL,			'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_2',	'IMPROVEMENT_TEMPLE_AZZANDARA_2',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_2',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_1',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_3',		1,		'TECH_DIVINE_ESSENCE',		'Build',	100,		'WonderWorkPlot',	3000,			NULL,					NULL,			'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_3',	'IMPROVEMENT_TEMPLE_AZZANDARA_3',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_3',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_2',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_4',		1,		'TECH_HEAVENLY_CYCLES',		'Build',	100,		'WonderWorkPlot',	5000,			NULL,					NULL,			'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_4',	'IMPROVEMENT_TEMPLE_AZZANDARA_4',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_4',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_3',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_5',		1,		'TECH_CELESTIAL_KNOWLEDGE',	'Build',	100,		'WonderWorkPlot',	8000,			NULL,					NULL,			'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_5',	'IMPROVEMENT_TEMPLE_AZZANDARA_5',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_5',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_4',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_6',		1,		'TECH_DIVINE_INTERVENTION',	'Build',	100,		'WonderWorkPlot',	9000,			NULL,					NULL,			'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_6',	'IMPROVEMENT_TEMPLE_AZZANDARA_6',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_6',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_5',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AZZANDARA_7',		1,		'TECH_KNOWLEDGE_OF_HEAVEN',	'Build',	100,		'WonderWorkPlot',	10000,			NULL,					NULL,			'Priest',	'Paladin',		'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AZZANDARA_7',	'IMPROVEMENT_TEMPLE_AZZANDARA_7',	'World',	'EA_WONDER_TEMPLE_AZZANDARA_7',	NULL,							'EA_WONDER_TEMPLE_AZZANDARA_6',	'RELIGION_AZZANDARAYASNA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_1',			1,		'TECH_MALEFICIUM',			'Build',	100,		'WonderWorkPlot',	1000,			1,						NULL,			'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_1',	'IMPROVEMENT_TEMPLE_AHRIMAN_1',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_1',	NULL,							NULL,							'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_2',			1,		'TECH_REANIMATION',			'Build',	100,		'WonderWorkPlot',	2000,			1,						NULL,			'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_2',	'IMPROVEMENT_TEMPLE_AHRIMAN_2',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_2',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_1',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_3',			1,		'TECH_SORCERY',				'Build',	100,		'WonderWorkPlot',	3000,			1,						NULL,			'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_3',	'IMPROVEMENT_TEMPLE_AHRIMAN_3',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_3',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_2',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_4',			1,		'TECH_NECROMANCY',			'Build',	100,		'WonderWorkPlot',	5000,			1,						NULL,			'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_4',	'IMPROVEMENT_TEMPLE_AHRIMAN_4',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_4',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_3',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_5',			1,		'TECH_SUMMONING',			'Build',	100,		'WonderWorkPlot',	5000,			1,						NULL,			'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_5',	'IMPROVEMENT_TEMPLE_AHRIMAN_5',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_5',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_4',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_6',			1,		'TECH_SOUL_BINDING',		'Build',	100,		'WonderWorkPlot',	8000,			1,						NULL,			'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_6',	'IMPROVEMENT_TEMPLE_AHRIMAN_6',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_6',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_5',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_7',			1,		'TECH_INVOCATION',			'Build',	100,		'WonderWorkPlot',	8000,			1,						NULL,			'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_7',	'IMPROVEMENT_TEMPLE_AHRIMAN_7',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_7',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_6',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_8',			1,		'TECH_BREACH',				'Build',	100,		'WonderWorkPlot',	9000,			1,						NULL,			'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_8',	'IMPROVEMENT_TEMPLE_AHRIMAN_8',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_8',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_7',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AHRIMAN_9',			1,		'TECH_ARMAGEDDON_RITUALS',	'Build',	100,		'WonderWorkPlot',	10000,			1,						NULL,			'FallenPriest','Eidolon',	'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AHRIMAN_9',	'IMPROVEMENT_TEMPLE_AHRIMAN_9',		'World',	'EA_WONDER_TEMPLE_AHRIMAN_9',	NULL,							'EA_WONDER_TEMPLE_AHRIMAN_8',	'RELIGION_ANRA',				NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_FAGUS',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_FAGUS',		'IMPROVEMENT_TEMPLE_FAGUS',			'World',	'EA_WONDER_TEMPLE_FAGUS',		'MINOR_CIV_GOD_FAGUS',			NULL,							'RELIGION_CULT_OF_LEAVES',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ABELLIO',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ABELLIO',		'IMPROVEMENT_TEMPLE_ABELLIO',		'World',	'EA_WONDER_TEMPLE_ABELLIO',		'MINOR_CIV_GOD_ABELLIO',		NULL,							'RELIGION_CULT_OF_LEAVES',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_BUXENUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_BUXENUS',		'IMPROVEMENT_TEMPLE_BUXENUS',		'World',	'EA_WONDER_TEMPLE_BUXENUS',		'MINOR_CIV_GOD_BUXENUS',		NULL,							'RELIGION_CULT_OF_LEAVES',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ROBOR',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ROBOR',		'IMPROVEMENT_TEMPLE_ROBOR',			'World',	'EA_WONDER_TEMPLE_ROBOR',		'MINOR_CIV_GOD_ROBOR',			NULL,							'RELIGION_CULT_OF_LEAVES',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ABNOAB',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ABNOAB',		'IMPROVEMENT_TEMPLE_ABNOAB',		'World',	'EA_WONDER_TEMPLE_ABNOAB',		'MINOR_CIV_GOD_ABNOAB',			NULL,							'RELIGION_CULT_OF_LEAVES',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_EPONA',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_EPONA',		'IMPROVEMENT_TEMPLE_EPONA',			'World',	'EA_WONDER_TEMPLE_EPONA',		'MINOR_CIV_GOD_EPONA',			NULL,							'RELIGION_CULT_OF_EPONA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ATEPOMARUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ATEPOMARUS',	'IMPROVEMENT_TEMPLE_ATEPOMARUS',	'World',	'EA_WONDER_TEMPLE_ATEPOMARUS',	'MINOR_CIV_GOD_ATEPOMARUS',		NULL,							'RELIGION_CULT_OF_EPONA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_SABAZIOS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_SABAZIOS',	'IMPROVEMENT_TEMPLE_SABAZIOS',		'World',	'EA_WONDER_TEMPLE_SABAZIOS',	'MINOR_CIV_GOD_SABAZIOS',		NULL,							'RELIGION_CULT_OF_EPONA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AVETA',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AVETA',		'IMPROVEMENT_TEMPLE_AVETA',			'World',	'EA_WONDER_TEMPLE_AVETA',		'MINOR_CIV_GOD_AVETA',			NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_CONDATIS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_CONDATIS',	'IMPROVEMENT_TEMPLE_CONDATIS',		'World',	'EA_WONDER_TEMPLE_CONDATIS',	'MINOR_CIV_GOD_CONDATIS',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ABANDINUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ABANDINUS',	'IMPROVEMENT_TEMPLE_ABANDINUS',		'World',	'EA_WONDER_TEMPLE_ABANDINUS',	'MINOR_CIV_GOD_ABANDINUS',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ADSULLATA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ADSULLATA',	'IMPROVEMENT_TEMPLE_ADSULLATA',		'World',	'EA_WONDER_TEMPLE_ADSULLATA',	'MINOR_CIV_GOD_ADSULLATA',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ICAUNUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ICAUNUS',		'IMPROVEMENT_TEMPLE_ICAUNUS',		'World',	'EA_WONDER_TEMPLE_ICAUNUS',		'MINOR_CIV_GOD_ICAUNUS',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_BELISAMA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_BELISAMA',	'IMPROVEMENT_TEMPLE_BELISAMA',		'World',	'EA_WONDER_TEMPLE_BELISAMA',	'MINOR_CIV_GOD_BELISAMA',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_CLOTA',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_CLOTA',		'IMPROVEMENT_TEMPLE_CLOTA',			'World',	'EA_WONDER_TEMPLE_CLOTA',		'MINOR_CIV_GOD_CLOTA',			NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_SABRINA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_SABRINA',		'IMPROVEMENT_TEMPLE_SABRINA',		'World',	'EA_WONDER_TEMPLE_SABRINA',		'MINOR_CIV_GOD_SABRINA',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_SEQUANA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_SEQUANA',		'IMPROVEMENT_TEMPLE_SEQUANA',		'World',	'EA_WONDER_TEMPLE_SEQUANA',		'MINOR_CIV_GOD_SEQUANA',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_VERBEIA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_VERBEIA',		'IMPROVEMENT_TEMPLE_VERBEIA',		'World',	'EA_WONDER_TEMPLE_VERBEIA',		'MINOR_CIV_GOD_VERBEIA',		NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_BORVO',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_BORVO',		'IMPROVEMENT_TEMPLE_BORVO',			'World',	'EA_WONDER_TEMPLE_BORVO',		'MINOR_CIV_GOD_BORVO',			NULL,							'RELIGION_CULT_OF_ABZU',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_AEGIR',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_AEGIR',		'IMPROVEMENT_TEMPLE_AEGIR',			'World',	'EA_WONDER_TEMPLE_AEGIR',		'MINOR_CIV_GOD_AEGIR',			NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_BARINTHUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_BARINTHUS',	'IMPROVEMENT_TEMPLE_BARINTHUS',		'World',	'EA_WONDER_TEMPLE_BARINTHUS',	'MINOR_CIV_GOD_BARINTHUS',		NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_LIBAN',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_LIBAN',		'IMPROVEMENT_TEMPLE_LIBAN',			'World',	'EA_WONDER_TEMPLE_LIBAN',		'MINOR_CIV_GOD_LIBAN',			NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_FIMAFENG',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_FIMAFENG',	'IMPROVEMENT_TEMPLE_FIMAFENG',		'World',	'EA_WONDER_TEMPLE_FIMAFENG',	'MINOR_CIV_GOD_FIMAFENG',		NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ELDIR',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ELDIR',		'IMPROVEMENT_TEMPLE_ELDIR',			'World',	'EA_WONDER_TEMPLE_ELDIR',		'MINOR_CIV_GOD_ELDIR',			NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_RITONA',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_RITONA',		'IMPROVEMENT_TEMPLE_RITONA',		'World',	'EA_WONDER_TEMPLE_RITONA',		'MINOR_CIV_GOD_RITONA',			NULL,							'RELIGION_CULT_OF_AEGIR',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_BAKKHOS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_BAKKHOS',		'IMPROVEMENT_TEMPLE_BAKKHOS',		'World',	'EA_WONDER_TEMPLE_BAKKHOS',		'MINOR_CIV_GOD_BAKKHOS',		NULL,							'RELIGION_CULT_OF_BAKKHEIA',	NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_PAN',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_PAN',			'IMPROVEMENT_TEMPLE_PAN',			'World',	'EA_WONDER_TEMPLE_PAN',			'MINOR_CIV_GOD_PAN',			NULL,							'RELIGION_CULT_OF_BAKKHEIA',	NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_SILENUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_SILENUS',		'IMPROVEMENT_TEMPLE_SILENUS',		'World',	'EA_WONDER_TEMPLE_SILENUS',		'MINOR_CIV_GOD_SILENUS',		NULL,							'RELIGION_CULT_OF_BAKKHEIA',	NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ERECURA',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ERECURA',		'IMPROVEMENT_TEMPLE_ERECURA',		'World',	'EA_WONDER_TEMPLE_ERECURA',		'MINOR_CIV_GOD_ERECURA',		NULL,							'RELIGION_CULT_OF_PLOUTON',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_VOSEGUS',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_VOSEGUS',		'IMPROVEMENT_TEMPLE_VOSEGUS',		'World',	'EA_WONDER_TEMPLE_VOSEGUS',		'MINOR_CIV_GOD_VOSEGUS',		NULL,							'RELIGION_CULT_OF_PLOUTON',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_NANTOSUELTA',		1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_NANTOSUELTA',	'IMPROVEMENT_TEMPLE_NANTOSUELTA',	'World',	'EA_WONDER_TEMPLE_NANTOSUELTA',	'MINOR_CIV_GOD_NANTOSUELTA',	NULL,							'RELIGION_CULT_OF_PLOUTON',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_DIS_PATER',			1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_DIS_PATER',	'IMPROVEMENT_TEMPLE_DIS_PATER',		'World',	'EA_WONDER_TEMPLE_DIS_PATER',	'MINOR_CIV_GOD_DIS_PATER',		NULL,							'RELIGION_CULT_OF_PLOUTON',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_NERGAL',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_NERGAL',		'IMPROVEMENT_TEMPLE_NERGAL',		'World',	'EA_WONDER_TEMPLE_NERGAL',		'MINOR_CIV_GOD_NERGAL',			NULL,							'RELIGION_CULT_OF_CAHRA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_WADD',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_WADD',		'IMPROVEMENT_TEMPLE_WADD',			'World',	'EA_WONDER_TEMPLE_WADD',		'MINOR_CIV_GOD_WADD',			NULL,							'RELIGION_CULT_OF_CAHRA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_ABGAL',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_ABGAL',		'IMPROVEMENT_TEMPLE_ABGAL',			'World',	'EA_WONDER_TEMPLE_ABGAL',		'MINOR_CIV_GOD_ABGAL',			NULL,							'RELIGION_CULT_OF_CAHRA',		NULL,						NULL,							37,			'BW_ATLAS_1'				),
('EA_ACTION_TEMPLE_NESR',				1,		NULL,						'Build',	100,		'WonderWorkPlot',	1000,			NULL,					NULL,			'Druid',	NULL,			'Not',	1,				1,			'EAMOD_DEVOTION',		25,					'Plot',			'BUILD_TEMPLE_NESR',		'IMPROVEMENT_TEMPLE_NESR',			'World',	'EA_WONDER_TEMPLE_NESR',		'MINOR_CIV_GOD_NESR',			NULL,							'RELIGION_CULT_OF_CAHRA',		NULL,						NULL,							37,			'BW_ATLAS_1'				);

UPDATE EaActions SET PolicyReq = 'POLICY_PANTHEISM' WHERE Type = 'EA_ACTION_STANHENCG';
UPDATE EaActions SET AndTechReq = 'TECH_MASONRY' WHERE Type = 'EA_ACTION_MEGALOS_FAROS';
UPDATE EaActions SET PolicyReq = 'POLICY_SLAVERY' WHERE Type = 'EA_ACTION_UUC_YABNAL';
UPDATE EaActions SET NotGPClass = 'Devout' WHERE Type = 'EA_ACTION_ARCANE_TOWER';
UPDATE EaActions SET BuildsTemple = 1 WHERE Type GLOB 'EA_ACTION_TEMPLE_*';

--Epics
INSERT INTO EaActions (Type,			GPOnly,	TechReq,				PolicyReq,			UIType,		ShowInTechTree,	FinishXP,	AITarget,			AIAdHocValue,	GPClass,	City,		GPModType1,			TurnsToComplete,	ProgressHolder,	UniqueType,	EaEpic,							IconIndex,	IconAtlas				) VALUES
('EA_ACTION_EPIC_VOLUSPA',				1,		'TECH_AESTHETICS',		'POLICY_FOLKLORE',	'Build',	1,				100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Self',			'World',	'EA_EPIC_VOLUSPA',				32,			'BW_ATLAS_2'			),
('EA_ACTION_EPIC_HAVAMAL',				1,		'TECH_MUSIC',			'POLICY_FOLKLORE',	'Build',	1,				100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Self',			'World',	'EA_EPIC_HAVAMAL',				32,			'BW_ATLAS_2'			),
('EA_ACTION_EPIC_VAFTHRUTHNISMAL',		1,		'TECH_WRITING',			'POLICY_FOLKLORE',	'Build',	1,				100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Self',			'World',	'EA_EPIC_VAFTHRUTHNISMAL',		32,			'BW_ATLAS_2'			),
('EA_ACTION_EPIC_GRIMNISMAL',			1,		'TECH_DRAMA',			'POLICY_FOLKLORE',	'Build',	1,				100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Self',			'World',	'EA_EPIC_GRIMNISMAL',			32,			'BW_ATLAS_2'			),
('EA_ACTION_EPIC_HYMISKVITHA',			1,		'TECH_ZYMURGY',			'POLICY_FOLKLORE',	'Build',	1,				100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Self',			'World',	'EA_EPIC_HYMISKVITHA',			32,			'BW_ATLAS_2'			),
('EA_ACTION_EPIC_NATIONAL',				1,		'TECH_LITERATURE',		NULL,				'Build',	1,				100,		'OwnClosestCity',	1000,			'Artist',	'Any',		'EAMOD_BARDING',	25,					'Self',			'National',	NULL,							32,			'BW_ATLAS_2'			);

--Items
INSERT INTO EaActions (Type,			GPOnly,	TechReq,					AndTechReq,		BuildingReq,		UIType,		ShowInTechTree,	FinishXP,	AITarget,					AIAdHocValue,	GPClass,	City,	GPModType1,				TurnsToComplete,	ProgressHolder,	UniqueType,	EaArtifact,							IconIndex,	IconAtlas							) VALUES
('EA_ACTION_TOME_OF_EQUUS',				1,		'TECH_HORSEBACK_RIDING',	'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_OF_EQUUS',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_BEASTS',			1,		'TECH_ELEPHANT_LABOR',		'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_OF_BEASTS',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_THE_LEVIATHAN',		1,		'TECH_HARPOONS',			'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_OF_THE_LEVIATHAN',2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_HARVESTS',			1,		'TECH_IRRIGATION',			'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_OF_HARVESTS',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_TOMES',				1,		'TECH_PHILOSOPHY',			'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_OF_TOMES',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_AESTHETICS',		1,		'TECH_DRAMA',				'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_OF_AESTHETICS',	2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_AXIOMS',			1,		'TECH_MATHEMATICS',			'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_OF_AXIOMS',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_FORM',				1,		'TECH_MASONRY',				'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_OF_FORM',			2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_OF_METALLURGY',		1,		'TECH_BRONZE_WORKING',		'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_OF_METALLURGY',	2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_CORPUS_HERMETICUM',	1,		'TECH_DIVINE_LITURGY',		'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_CORPUS_HERMETICUM',2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_NECRONOMICON',			1,		'TECH_REANIMATION',			'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_NECRONOMICON',	2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_ARS_GOETIA',			1,		'TECH_SORCERY',				'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_ARS_GOETIA',		2,			'EXPANSION_SCEN_TECH_ATLAS'			),
('EA_ACTION_TOME_BOOK_OF_EIBON',		1,		'TECH_THAUMATURGY',			'TECH_WRITING',	'BUILDING_LIBRARY',	'Build',	1,				100,		'OwnClosestLibraryCity',	1000,			'Sage',		'Own',	'EAMOD_SCHOLARSHIP',	25,					'Self',			'World',	'EA_ARTIFACT_TOME_BOOK_OF_EIBON',	2,			'EXPANSION_SCEN_TECH_ATLAS'			);

UPDATE EaActions SET GPSubclass = 'Priest' WHERE Type = 'EA_ACTION_TOME_CORPUS_HERMETICUM';
UPDATE EaActions SET AhrimansVaultMatters = 1, GPSubclass = 'Necromancer' WHERE Type = 'EA_ACTION_TOME_NECRONOMICON';
UPDATE EaActions SET AhrimansVaultMatters = 1 WHERE Type = 'EA_ACTION_TOME_ARS_GOETIA';

--GP non-unique builds
INSERT INTO EaActions (Type,			GPOnly,	UIType,		TechReq,				PolicyReq,				FinishXP,	AITarget,		AISimpleYield,	GPClass,	City,		GPModType1,		TurnsToComplete,	ProgressHolder,	Building,				BuildingMod,			HumanOnlySound,			IconIndex,	IconAtlas				) VALUES
('EA_ACTION_FOUNDRY',					1,		'Build',	'TECH_IRON_WORKING',	NULL,					25,			'OwnCities',	3,				'Engineer',	'Own',		NULL,			8,					'City',			'BUILDING_FOUNDRY',		NULL,					'AS2D_BUILD_UNIT',		1,			'NEW_BLDG_ATLAS2_DLC'	),
('EA_ACTION_FESTIVAL',					1,		'Build',	'TECH_CALENDAR',		NULL,					25,			'OwnCities',	3,				'Artist',	'Own',		NULL,			8,					'City',			'BUILDING_FESTIVAL',	NULL,					'AS2D_BUILD_UNIT',		44,			'BW_ATLAS_1'			),
('EA_ACTION_TRADE_HOUSE',				1,		'Build',	NULL,					'POLICY_FREE_MARKETS',	25,			'OwnCities',	0,				'Merchant',	'Own',		'EAMOD_TRADE',	8,					'City',			NULL,					'BUILDING_TRADE_HOUSE',	'AS2D_BUILD_UNIT',		1,			'NEW_BLDG_ATLAS_DLC'	);

--Other GP builds
INSERT INTO EaActions (Type,			GPOnly,	UIType,		TechReq,			PolicyReq,				FinishXP,	AITarget,			GPClass,	City,		GPModType1,				TurnsToComplete,	ProgressHolder,	HumanOnlySound,			PlayAnywhereSound,					IconIndex,	IconAtlas					) VALUES
('EA_ACTION_LAND_TRADE_ROUTE',			1,		'Action',	'TECH_CURRENCY',	NULL,					25,			'LandTradeCities',	'Merchant',	'Any',		NULL,					8,					'CityCiv',		'AS2D_BUILD_UNIT',		NULL,								0,			'UNIT_ACTION_ATLAS_TRADE'	),
('EA_ACTION_SEA_TRADE_ROUTE',			1,		'Action',	'TECH_SAILING',		NULL,					25,			'SeaTradeCities',	'Merchant',	'Any',		NULL,					8,					'CityCiv',		'AS2D_BUILD_UNIT',		NULL,								0,			'UNIT_ACTION_ATLAS_TRADE'	),
('EA_ACTION_TRADE_MISSION',				1,		'Action',	NULL,				'POLICY_FREE_TRADE',	100,		'ForeignCapitals',	'Merchant',	'Foreign',	'EAMOD_TRADE',			25,					'CityCiv',		'AS2D_BUILD_UNIT',		NULL,								17,			'TECH_ATLAS_1'				);

UPDATE EaActions SET CapitalOnly = 1 WHERE Type = 'EA_ACTION_TRADE_MISSION';

--Religious conversion and cult founding
INSERT INTO EaActions (Type,			GPOnly,	UIType,		ReligionFounded,			FinishXP,	AITarget,			GPClass,	GPSubclass,		FoundsSpreadsCult,				City,		GPModType1,				TurnsToComplete,	ProgressHolder,	HumanOnlySound,			PlayAnywhereSound,					IconIndex,	IconAtlas						) VALUES
('EA_ACTION_PROSELYTIZE',				1,		'Action',	'RELIGION_AZZANDARAYASNA',	25,			'AzzandaraSpread',	NULL,		'Priest',		NULL,							'Any',		'EAMOD_PROSELYTISM',	8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		1,			'EXPANSION_UNIT_ACTION_ATLAS'	),
('EA_ACTION_ANTIPROSELYTIZE',			1,		'Action',	'RELIGION_ANRA',			25,			'AnraSpread',		NULL,		'FallenPriest',	NULL,							'Any',		'EAMOD_PROSELYTISM',	8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_VERY_BAD',	1,			'EXPANSION_UNIT_ACTION_ATLAS'	),
('EA_ACTION_RITUAL_LEAVES',				1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		NULL,		'Druid',		'RELIGION_CULT_OF_LEAVES',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		3,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_CLEANSING',			1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		NULL,		'Druid',		'RELIGION_CULT_OF_ABZU',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		6,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_AEGIR',				1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		NULL,		'Druid',		'RELIGION_CULT_OF_AEGIR',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		7,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_STONES',				1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		NULL,		'Druid',		'RELIGION_CULT_OF_PLOUTON',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		8,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_DESICCATION',		1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		NULL,		'Druid',		'RELIGION_CULT_OF_CAHRA',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		9,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_EQUUS',				1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		NULL,		'Druid',		'RELIGION_CULT_OF_EPONA',		'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		5,			'EA_RELIGION_ATLAS'				),
('EA_ACTION_RITUAL_BAKKHEIA',			1,		'Spell',	'RELIGION_THE_WEAVE_OF_EA',	25,			'AllCities',		NULL,		'Druid',		'RELIGION_CULT_OF_BAKKHEIA',	'Any',		'EAMOD_DEVOTION',		8,					'City',			NULL,					'AS2D_EVENT_NOTIFICATION_GOOD',		4,			'EA_RELIGION_ATLAS'				);

UPDATE EaActions SET OrGPSubclass = 'Paladin' WHERE Type = 'EA_ACTION_PROSELYTIZE';
UPDATE EaActions SET AhrimansVaultMatters = 1, OrGPSubclass = 'Eidolon' WHERE Type = 'EA_ACTION_ANTIPROSELYTIZE';

--Other rituals
INSERT INTO EaActions (Type,				GPOnly,	UIType,		TechReq,						AhrimansVaultMatters,	AITarget,			GPClass,	OrGPClass,		TurnsToComplete,	ProgressHolder,	PlayAnywhereSound,					IconIndex,	IconAtlas		) VALUES
('EA_ACTION_RITUAL_AHRIMANS_EXCHANGE',		1,		'Spell',	'TECH_BREACH',					1,						'TowerTemple',		'Devout',	'Thaumaturge',	8,					'Self',			'AS2D_EVENT_NOTIFICATION_VERY_BAD',	9,			'TECH_ATLAS_2'	),
('EA_ACTION_RITUAL_CONSUME_SOULS',			1,		'Spell',	'TECH_ARMAGEDDON_RITUALS',		1,						'TowerTemple',		'Devout',	'Thaumaturge',	8,					'Self',			'AS2D_EVENT_NOTIFICATION_VERY_BAD',	9,			'TECH_ATLAS_2'	),
('EA_ACTION_RITUAL_CONSUME_SELF',			1,		'Spell',	'TECH_ARMAGEDDON_RITUALS',		1,						'Self',				'Devout',	'Thaumaturge',	8,					'Self',			'AS2D_EVENT_NOTIFICATION_VERY_BAD',	9,			'TECH_ATLAS_2'	),
('EA_ACTION_RITUAL_SEAL_AHRIMANS_VAULT',	1,		'Spell',	NULL,							NULL,					'AhrimansVault',	NULL,		NULL,			8,					'Self',			'AS2D_EVENT_NOTIFICATION_VERY_BAD',	9,			'TECH_ATLAS_2'	);

UPDATE EaActions SET AITarget2 = 'AllCities' WHERE Type = 'EA_ACTION_RITUAL_CONSUME_SOULS';

--Build out the table for dependent strings
UPDATE EaActions SET Description = 'TXT_KEY_' || Type, Help = 'TXT_KEY_' || Type || '_HELP' WHERE Description IS NULL;

-----------------------------------------------------------------------------------------
--Spells (MUST come last!)
-----------------------------------------------------------------------------------------
-- These are EaActions but treated in a special way: All non-target prereqs are only "learn" prereqs
-- The spell is always castable if it is known and target is valid and player has sufficient mana or divine favor.

-- Class/subclass restrictions not fully implemented for learning spell. Only ExcludeGPSubclass works.

--Arcane
INSERT INTO EaActions (Type,			SpellClass,	GPModType1,				TechReq,						FinishMoves,	City,	AITarget,			AICombatRole,	TurnsToComplete,	HumanVisibleFX,	IconIndex,	IconAtlas					) VALUES
('EA_SPELL_LECTIO_OCCULTUS',			'Arcane',	'EAMOD_DIVINATION',		'TECH_THAUMATURGY',				1,				'Not',	'TowerTemple',		NULL,			1000,				NULL,			1,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_GREATER_LECTIO_OCCULTUS',	'Arcane',	'EAMOD_DIVINATION',		NULL,							1,				'Not',	'TowerTemple',		NULL,			1000,				NULL,			1,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_SCRYING',					'Arcane',	'EAMOD_DIVINATION',		'TECH_THAUMATURGY',				NULL,			NULL,	NULL,				NULL,			2,					1,				6,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_SEEING_EYE_GLYPH',			'Arcane',	'EAMOD_DIVINATION',		'TECH_THAUMATURGY',				1,				'Not',	'SeeingEyeGlyph',	NULL,			2,					1,				4,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_DETECT_GLYPHS_RUNES_WARDS',	'Arcane',	'EAMOD_DIVINATION',		'TECH_THAUMATURGY',				1,				NULL,	'Self',				NULL,			1,					1,				5,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_KNOW_WORLD',					'Arcane',	'EAMOD_DIVINATION',		'TECH_TRANSCENDENTAL_THOUGHT',	1,				NULL,	NULL,				NULL,			1,					1,				2,			'EA_SPELLS_ATLAS_ARCANE1'	),

('EA_SPELL_DISPEL_HEXES',				'Arcane',	'EAMOD_ABJURATION',		'TECH_ABJURATION',				1,				NULL,	NULL,				NULL,			1,					1,				23,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_DISPEL_GLYPHS_RUNES_WARDS',	'Arcane',	'EAMOD_ABJURATION',		'TECH_ABJURATION',				1,				'Not',	'RevealedGRWs',		NULL,			2,					1,				20,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_DISPEL_ILLUSIONS',			'Arcane',	'EAMOD_ABJURATION',		'TECH_ABJURATION',				1,				NULL,	NULL,				NULL,			1,					1,				21,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_BANISH',						'Arcane',	'EAMOD_ABJURATION',		'TECH_ABJURATION',				1,				NULL,	'Self',				NULL,			2,					1,				17,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_PROTECTIVE_WARD',			'Arcane',	'EAMOD_ABJURATION',		'TECH_ABJURATION',				1,				'Not',	'HomelandProtection',NULL,			2,					1,				19,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_DISPEL_MAGIC',				'Arcane',	'EAMOD_ABJURATION',		'TECH_INVOCATION',				1,				NULL,	NULL,				NULL,			1,					1,				22,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_TIME_STOP',					'Arcane',	'EAMOD_ABJURATION',		'TECH_GREATER_ARCANA',			NULL,			NULL,	NULL,				'Any',			1,					1,				18,			'EA_SPELLS_ATLAS_ARCANE1'	),

('EA_SPELL_EXPLOSIVE_RUNE',				'Arcane',	'EAMOD_EVOCATION',		'TECH_EVOCATION',				1,				'Not',	'HomelandProtection',NULL,			2,					1,				9,			'EA_SPELLS_ATLAS_ARCANE2'	),
('EA_SPELL_FIREBALL',					'Arcane',	'EAMOD_EVOCATION',		'TECH_EVOCATION',				NULL,			NULL,	NULL,				'Any',			1,					NULL,			15,			'EA_SPELLS_ATLAS_ARCANE2'	),
('EA_SPELL_PLASMA_BOLT',				'Arcane',	'EAMOD_EVOCATION',		'TECH_INVOCATION',				NULL,			NULL,	NULL,				'Any',			1,					NULL,			10,			'EA_SPELLS_ATLAS_ARCANE2'	),
('EA_SPELL_BREACH',						'Arcane',	'EAMOD_EVOCATION',		'TECH_BREACH',					1,				'Not',	'TowerTemple',		NULL,			10,					1,				12,			'EA_SPELLS_ATLAS_ARCANE2'	),
('EA_SPELL_PLASMA_STORM',				'Arcane',	'EAMOD_EVOCATION',		'TECH_ESOTERIC_ARCANA',			NULL,			NULL,	NULL,				'Any',			1,					NULL,			14,			'EA_SPELLS_ATLAS_ARCANE2'	),
('EA_SPELL_WISH',						'Arcane',	'EAMOD_EVOCATION',		'TECH_ESOTERIC_ARCANA',			1,				NULL,	NULL,				NULL,			10,					1,				13,			'EA_SPELLS_ATLAS_ARCANE2'	),

('EA_SPELL_SLOW',						'Arcane',	'EAMOD_TRANSMUTATION',	'TECH_TRANSMUTATION',			1,				NULL,	NULL,				'Any',			1,					1,				1,			'EA_SPELLS_ATLAS_ARCANE2'	),
('EA_SPELL_HASTE',						'Arcane',	'EAMOD_TRANSMUTATION',	'TECH_TRANSMUTATION',			1,				NULL,	NULL,				'Any',			1,					1,				7,			'EA_SPELLS_ATLAS_ARCANE2'	),
('EA_SPELL_ENCHANT_WEAPONS',			'Arcane',	'EAMOD_TRANSMUTATION',	'TECH_TRANSMUTATION',			1,				NULL,	NULL,				'Any',			1,					1,				4,			'EA_SPELLS_ATLAS_ARCANE2'	),
('EA_SPELL_POLYMORPH',					'Arcane',	'EAMOD_TRANSMUTATION',	'TECH_TRANSMUTATION',			1,				NULL,	NULL,				NULL,			1,					1,				7,			'EA_SPELLS_ATLAS_ARCANE2'	),
('EA_SPELL_BLIGHT',						'Arcane',	'EAMOD_TRANSMUTATION',	'TECH_SORCERY',					1,				'Not',	'TowerTemple',		NULL,			3,					1,				2,			'EA_SPELLS_ATLAS_ARCANE2'	),
('EA_SPELL_BURNING_HANDS',				'Arcane',	'EAMOD_TRANSMUTATION',	'TECH_SORCERY',					NULL,			NULL,	NULL,				'Any',			1,					NULL,			7,			'EA_SPELLS_ATLAS_ARCANE2'	),

('EA_SPELL_HEX',						'Arcane',	'EAMOD_CONJURATION',	'TECH_MALEFICIUM',				1,				NULL,	NULL,				'Any',			1,					1,				31,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_MAGE_SWORD',					'Arcane',	'EAMOD_CONJURATION',	'TECH_EVOCATION',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_MAGIC_MISSILE',				'Arcane',	'EAMOD_CONJURATION',	'TECH_CONJURATION',				NULL,			NULL,	NULL,				'Any',			1,					NULL,			26,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_CONJURE_MONSTER',			'Arcane',	'EAMOD_CONJURATION',	'TECH_CONJURATION',				1,				NULL,	'SelfTowerTemple',	NULL,			3,					1,				25,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_TELEPORT',					'Arcane',	'EAMOD_CONJURATION',	'TECH_CONJURATION',				1,				NULL,	NULL,				NULL,			1,					1,				24,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_SUMMON_ABYSSAL_CREATURES',	'Arcane',	'EAMOD_CONJURATION',	'TECH_SORCERY',					1,				NULL,	'SelfTowerTemple',	NULL,			3,					1,				29,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_SUMMON_DEMON',				'Arcane',	'EAMOD_CONJURATION',	'TECH_SUMMONING',				1,				NULL,	'SelfTowerTemple',	NULL,			3,					1,				28,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_PHASE_DOOR',					'Arcane',	'EAMOD_CONJURATION',	'TECH_INVOCATION',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_HAIL_OF_PROJECTILES',		'Arcane',	'EAMOD_CONJURATION',	'TECH_GREATER_ARCANA',			NULL,			NULL,	NULL,				'Any',			1,					NULL,			30,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_SUMMON_ARCHDEMON',			'Arcane',	'EAMOD_CONJURATION',	'TECH_BREACH',					1,				NULL,	'SelfTowerTemple',	NULL,			15,					1,				27,			'EA_SPELLS_ATLAS_ARCANE1'	),

('EA_SPELL_REANIMATE_DEAD',				'Arcane',	'EAMOD_NECROMANCY',		'TECH_REANIMATION',				1,				NULL,	'SelfTowerTemple',	NULL,			2,					1,				15,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_RAISE_DEAD',					'Arcane',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				1,				NULL,	'SelfTowerTemple',	NULL,			3,					1,				15,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_DEATH_RUNE',					'Arcane',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				1,				'Not',	'HomelandProtection',NULL,			2,					1,				9,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_VAMPIRIC_TOUCH',				'Arcane',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				1,				NULL,	NULL,				NULL,			1,					1,				15,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_DEATH_STAY',					'Arcane',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				1,				NULL,	NULL,				NULL,			1,					1,				15,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_BECOME_LICH',				'Arcane',	'EAMOD_NECROMANCY',		'TECH_SOUL_BINDING',			1,				'Not',	'TowerTemple',		NULL,			15,					1,				8,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_FINGER_OF_DEATH',			'Arcane',	'EAMOD_NECROMANCY',		'TECH_SOUL_BINDING',			1,				NULL,	NULL,				NULL,			1,					1,				15,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_ENERGY_DRAIN',				'Arcane',	'EAMOD_NECROMANCY',		'TECH_SOUL_BINDING',			NULL,			NULL,	NULL,				'Any',			1,					1,				15,			'EA_SPELLS_ATLAS_ARCANE1'	),
('EA_SPELL_MASS_ENERGY_DRAIN',			'Arcane',	'EAMOD_NECROMANCY',		'TECH_ARMAGEDDON_RITUALS',		NULL,			NULL,	NULL,				'Any',			1,					1,				15,			'EA_SPELLS_ATLAS_ARCANE1'	),

('EA_SPELL_CHARM_MONSTER',				'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_MUSIC',					1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	);
--('EA_SPELL_CAUSE_FEAR',				'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),
--('EA_SPELL_CAUSE_DISPAIR',			'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),
--('EA_SPELL_SLEEP',					'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),
--('EA_SPELL_DREAM',					'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),
--('EA_SPELL_NIGHTMARE',				'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),
--('EA_SPELL_LESSER_GEAS',				'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),
--('EA_SPELL_GREATER_GEAS',				'Arcane',	'EAMOD_ENCHANTMENT',	'TECH_ENCHANTMENT',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),

--('EA_SPELL_PRESTIDIGITATION',			'Arcane',	'EAMOD_ILLUSION',		'TECH_ILLUSION',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),
--('EA_SPELL_OBSCURE_TERRAIN',			'Arcane',	'EAMOD_ILLUSION',		'TECH_ILLUSION',				1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),
--('EA_SPELL_FOG_OF_WAR',				'Arcane',	'EAMOD_ILLUSION',		'TECH_GREATER_ILLUSION',		1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),
--('EA_SPELL_SIMULACRUM',				'Arcane',	'EAMOD_ILLUSION',		'TECH_GREATER_ILLUSION',		1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	),
--('EA_SPELL_PHANTASMAGORIA',			'Arcane',	'EAMOD_ILLUSION',		'TECH_PHANTASMAGORIA',			1,				NULL,	NULL,				NULL,			1,					1,				0,			'EA_SPELLS_ATLAS_ARCANE2'	);

UPDATE EaActions SET AITarget2 = 'SpacedRingsWide' WHERE Type IN ('EA_SPELL_BREACH', 'EA_SPELL_BLIGHT');
UPDATE EaActions SET TowerTempleOnly = 1 WHERE Type IN ('EA_SPELL_LECTIO_OCCULTUS', 'EA_SPELL_GREATER_LECTIO_OCCULTUS');
UPDATE EaActions SET RestrictedToGPSubclass = 'Archmage' WHERE Type = 'EA_SPELL_GREATER_LECTIO_OCCULTUS';


--UPDATE EaActions SET MinimumModToLearn = 15 WHERE Type = 'EA_SPELL_TIME_STOP';

--Divine
INSERT INTO EaActions (Type,			SpellClass,	GPModType1,				TechReq,						FinishMoves,	City,	AITarget,			AICombatRole,	FallenAltSpell,					TurnsToComplete,	HumanVisibleFX,	IconIndex,	IconAtlas					) VALUES
('EA_SPELL_HEAL',						'Divine',	'EAMOD_NECROMANCY',		NULL,							1,				NULL,	NULL,				'Any',			'EA_SPELL_HURT',				1,					1,				0,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_LECTIO_DIVINA',				'Divine',	'EAMOD_DIVINATION',		'TECH_DIVINE_LITURGY',			1,				'Not',	'Temple',			NULL,			'EA_SPELL_LECTIO_OCCULTUS',		1000,				NULL,			8,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_GREATER_LECTIO_DIVINA',		'Divine',	'EAMOD_DIVINATION',		NULL,							1,				'Not',	'Temple',			NULL,			'EA_SPELL_LECTIO_OCCULTUS',		1000,				NULL,			8,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_BLESS',						'Divine',	'EAMOD_CONJURATION',	'TECH_DIVINE_LITURGY',			1,				NULL,	NULL,				'Any',			'EA_SPELL_CURSE',				1,					1,				1,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_PROTECTION_FROM_EVIL',		'Divine',	'EAMOD_ABJURATION',		'TECH_DIVINE_LITURGY',			1,				NULL,	NULL,				'Any',			'EA_SPELL_EVIL_EYE',			1,					1,				2,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_SANCTIFY',					'Divine',	'EAMOD_ABJURATION',		'TECH_DIVINE_VITALISM',			1,				NULL,	NULL,				NULL,			'EA_SPELL_DEFILE',				1,					1,				3,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_MASS_HEAL',					'Divine',	'EAMOD_NECROMANCY',		'TECH_DIVINE_VITALISM',			1,				NULL,	NULL,				NULL,			'EA_SPELL_MASS_HURT',			1,					1,				4,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_CURE_DISEASE',				'Divine',	'EAMOD_NECROMANCY',		'TECH_DIVINE_VITALISM',			1,				NULL,	NULL,				NULL,			'EA_SPELL_CAUSE_DISEASE',		1,					1,				5,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_CURE_PLAGUE',				'Divine',	'EAMOD_NECROMANCY',		'TECH_DIVINE_ESSENCE',			1,				NULL,	NULL,				NULL,			'EA_SPELL_CAUSE_PLAGUE',		1,					1,				6,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_COMMAND',					'Divine',	'EAMOD_ENCHANTMENT',	'TECH_DIVINE_ESSENCE',			1,				NULL,	NULL,				NULL,			NULL,							1,					1,				16,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_BANISH_UNDEAD',				'Divine',	'EAMOD_ABJURATION',		'TECH_DIVINE_ESSENCE',			1,				NULL,	'Self',				NULL,			'EA_SPELL_TURN_UNDEAD',			2,					1,				9,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_BANISH_DEMONS',				'Divine',	'EAMOD_ABJURATION',		'TECH_DIVINE_ESSENCE',			1,				NULL,	'Self',				NULL,			'EA_SPELL_BANISH_ANGELS',		2,					1,				10,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_CONSECRATE',					'Divine',	'EAMOD_EVOCATION',		'TECH_HEAVENLY_CYCLES',			1,				NULL,	NULL,				NULL,			'EA_SPELL_DESECRATE',			1,					1,				11,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_CALL_HEAVENS_GUARD',			'Divine',	'EAMOD_CONJURATION',	'TECH_HEAVENLY_CYCLES',			1,				NULL,	'SelfTowerTemple',	NULL,			'EA_SPELL_SUMMON_ABYSSAL_CREATURES', 3,				1,				12,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_CALL_ANGEL',					'Divine',	'EAMOD_CONJURATION',	'TECH_CELESTIAL_KNOWLEDGE',		1,				NULL,	'SelfTowerTemple',	NULL,			'EA_SPELL_SUMMON_DEMON',		3,					1,				13,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_CALL_ARCHANGEL',				'Divine',	'EAMOD_CONJURATION',	'TECH_DIVINE_INTERVENTION',		1,				NULL,	'SelfTowerTemple',	NULL,			'EA_SPELL_SUMMON_ARCHDEMON',	15,					1,				15,			'EA_SPELLS_ATLAS_DIVINE1'	),
('EA_SPELL_RESURRECTION',				'Divine',	'EAMOD_NECROMANCY',		'TECH_DIVINE_INTERVENTION',		1,				NULL,	NULL,				NULL,			'EA_SPELL_GREATER_REANIMATION',	1,					1,				14,			'EA_SPELLS_ATLAS_DIVINE1'	),

--fallen
('EA_SPELL_HURT',						'Divine',	'EAMOD_NECROMANCY',		NULL,							1,				NULL,	NULL,				'Any',			'IsFallen',						1,					1,				0,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_CURSE',						'Divine',	'EAMOD_CONJURATION',	'TECH_MALEFICIUM',				1,				NULL,	NULL,				'Any',			'IsFallen',						1,					1,				1,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_EVIL_EYE',					'Divine',	'EAMOD_NECROMANCY',		'TECH_MALEFICIUM',				1,				NULL,	NULL,				'Any',			'IsFallen',						1,					1,				2,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_DEFILE',						'Divine',	'EAMOD_TRANSMUTATION',	'TECH_REANIMATION',				1,				NULL,	NULL,				NULL,			'IsFallen',						1,					1,				3,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_MASS_HURT',					'Divine',	'EAMOD_NECROMANCY',		'TECH_SORCERY',					1,				NULL,	NULL,				NULL,			'IsFallen',						1,					1,				4,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_CAUSE_DISEASE',				'Divine',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				1,				NULL,	NULL,				NULL,			'IsFallen',						1,					1,				5,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_CAUSE_PLAGUE',				'Divine',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				1,				NULL,	NULL,				NULL,			'IsFallen',						1,					1,				6,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_TURN_UNDEAD',				'Divine',	'EAMOD_NECROMANCY',		'TECH_NECROMANCY',				1,				NULL,	'Self',				NULL,			'IsFallen',						2,					1,				7,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_BANISH_ANGELS',				'Divine',	'EAMOD_ABJURATION',		'TECH_SUMMONING',				1,				NULL,	'Self',				NULL,			'IsFallen',						2,					1,				8,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_DESECRATE',					'Divine',	'EAMOD_TRANSMUTATION',	'TECH_SUMMONING',				1,				NULL,	NULL,				NULL,			'IsFallen',						1,					1,				9,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_GREATER_REANIMATION',		'Divine',	'EAMOD_NECROMANCY',		'TECH_SOUL_BINDING',			1,				NULL,	NULL,				NULL,			'IsFallen',						1,					1,				12,			'EA_SPELLS_ATLAS_DIVINE2'	);

--pantheism
INSERT INTO EaActions (Type,			SpellClass,	GPModType1,				PolicyReq,						FinishMoves,	City,	AITarget,			AICombatRole,	FallenAltSpell,					TurnsToComplete,	HumanVisibleFX,	IconIndex,	IconAtlas					) VALUES
('EA_SPELL_EAS_BLESSING',				'Divine',	'EAMOD_TRANSMUTATION',	'POLICY_WOODS_LORE',			1,				'Not',	'NearbyLivTerrain',	NULL,			NULL,							3,					1,				16,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_CALL_ANIMALS',				'Divine',	'EAMOD_CONJURATION',	'POLICY_FERAL_BOND',			1,				NULL,	'SelfTowerTemple',	NULL,			NULL,							3,					1,				17,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_CALL_TREE_ENT',				'Divine',	'EAMOD_CONJURATION',	'POLICY_FOREST_DOMINION',		1,				NULL,	'NearbyStrongWoods',NULL,			NULL,							3,					1,				18,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_CALL_MAJOR_SPIRIT',			'Divine',	'EAMOD_CONJURATION',	'POLICY_PANTHEISM_FINISHER',	1,				NULL,	'SelfTowerTemple',	NULL,			NULL,							15,					1,				19,			'EA_SPELLS_ATLAS_DIVINE2'	);

--druid cult spells (learned from ritual)
INSERT INTO EaActions (Type,			SpellClass,	GPModType1,				PantheismCult,					FinishMoves,	City,	AITarget,			AICombatRole,		TurnsToComplete,	HumanVisibleFX,	IconIndex,	IconAtlas					) VALUES
('EA_SPELL_BLOOM',						'Divine',	'EAMOD_TRANSMUTATION',	'RELIGION_CULT_OF_LEAVES',		1,				'Not',	'NearbyNonFeature',	NULL,				5,					1,				20,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_RIDE_LIKE_THE_WIND',			'Divine',	'EAMOD_CONJURATION',	'RELIGION_CULT_OF_EPONA',		1,				NULL,	NULL,				'Any',				1,					1,				21,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_PURIFY',						'Divine',	'EAMOD_CONJURATION',	'RELIGION_CULT_OF_ABZU',		1,				NULL,	NULL,				'Any',				1,					1,				22,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_FAIR_WINDS',					'Divine',	'EAMOD_CONJURATION',	'RELIGION_CULT_OF_AEGIR',		1,				NULL,	'OwnShips',			NULL,				1,					1,				23,			'EA_SPELLS_ATLAS_DIVINE2'	),
('EA_SPELL_REVELRY',					'Divine',	'EAMOD_CONJURATION',	'RELIGION_CULT_OF_BAKKHEIA',	1,				'Own',	'OwnClosestCity',	NULL,				1000,				1,				24,			'EA_SPELLS_ATLAS_DIVINE2'	);


--Build out the table for dependent strings
UPDATE EaActions SET Description = 'TXT_KEY_' || Type, Help = 'TXT_KEY_' || Type || '_HELP' WHERE SpellClass IS NOT NULL;
UPDATE EaActions SET GPOnly = 1, ConsiderTowerTemple = 1, AhrimansVaultMatters = 1, UIType = 'Spell' WHERE SpellClass IS NOT NULL;
UPDATE EaActions SET ProgressHolder = 'Self' WHERE SpellClass IS NOT NULL AND TurnsToComplete > 1;

UPDATE EaActions SET TowerTempleOnly = 1, ExcludeGPSubclass = 'Druid' WHERE Type IN ('EA_SPELL_LECTIO_DIVINA', 'EA_SPELL_GREATER_LECTIO_DIVINA');
UPDATE EaActions SET RestrictedToGPSubclass = 'Priest', LevelReq = 15 WHERE Type = 'EA_SPELL_GREATER_LECTIO_DIVINA';


UPDATE EaActions SET PolicyTrumpsTechReq = 'POLICY_WITCHCRAFT' WHERE Type IN ('EA_SPELL_SCRYING', 'EA_SPELL_SLOW', 'EA_SPELL_HEX', 'EA_SPELL_DEATH_STAY', 'EA_SPELL_SLEEP');
UPDATE EaActions SET GPModType2 = 'EAMOD_DEVOTION' WHERE SpellClass IN ('Divine', 'Both');

UPDATE EaActions SET FreeSpellSubclass = 'Priest' WHERE Type = 'EA_SPELL_HEAL';
UPDATE EaActions SET FreeSpellSubclass = 'FallenPriest' WHERE Type = 'EA_SPELL_HURT';


UPDATE EaActions SET ProgressHolder = 'Self' WHERE ProgressHolder IS NULL AND TurnsToComplete > 1;		--needs to be something

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
--'EA_ACTION_PROPHECY_TZIMTZUM', 'EA_ACTION_PROPHECY_ANRA', 'EA_ACTION_PROPHECY_AESHEMA', 'EA_ACTION_WORSHIP');

-----------------------------------------------------------------------------------------
-- Subtables
-----------------------------------------------------------------------------------------




INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaActions.sql';