
CREATE TABLE EaModifiers (	'ID' INTEGER PRIMARY KEY AUTOINCREMENT,
							'Type' TEXT NOT NULL UNIQUE,
							'Description' TEXT NOT NULL,
							'Class' TEXT DEFAULT NULL,
							'Subclass' TEXT DEFAULT NULL,
							'ExcludeSubclass' TEXT DEFAULT NULL,
							'PromotionPrefix' TEXT DEFAULT NULL,
							--'ModMultiplier' FLOAT DEFAULT 1,
							'ProphetBonus' BOOLEAN DEFAULT NULL);

INSERT INTO EaModifiers(ID,	Type, Description,			Class) VALUES
(0,	'EAMOD_LEADERSHIP',			'Leadership',			'Any');				--Special, Lua assumes ID=0; only leadership can have PromotionPrefix = NULL


INSERT INTO EaModifiers(Type,	Description,			Class,			PromotionPrefix					) VALUES
('EAMOD_COMBAT',				'Combat',				'Warrior',		'PROMOTION_GP_COMBAT'			),
('EAMOD_LOGISTICS',				'Logistics',			'Warrior',		'PROMOTION_LOGISTICS'			),
('EAMOD_CONSTRUCTION',			'Construction',			'Engineer',		'PROMOTION_CONSTRUCTION'		),
('EAMOD_COMBAT_ENGINEERING',	'Combat Engineering',	'Engineer',		'PROMOTION_COMBAT_ENGINEERING'	),
('EAMOD_TRADE',					'Trade',				'Merchant',		'PROMOTION_TRADE'				),
('EAMOD_ESPIONAGE',				'Espionage',			'Merchant',		'PROMOTION_ESPIONAGE'			),
('EAMOD_SCHOLARSHIP',			'Scholarship',			'Sage',			'PROMOTION_SCHOLARSHIP'			),
('EAMOD_BARDING',				'Barding',				'Artist',		'PROMOTION_BARDING'				),
('EAMOD_PROSELYTISM',			'Proselytism',			'Devout',		'PROMOTION_PROSELYTISM'			),

--Lua expects last 9 to be Devotion followed by 8 magic schools
('EAMOD_DEVOTION',				'Devotion',				'Devout',		'PROMOTION_DEVOTION'			),
('EAMOD_DIVINATION',			'Divination',			'Thaumaturge',	'PROMOTION_DIVINATION'			),
('EAMOD_ABJURATION',			'Abjuration',			'Thaumaturge',	'PROMOTION_ABJURATION'			),
('EAMOD_EVOCATION',				'Evocation',			'Thaumaturge',	'PROMOTION_EVOCATION'			),
('EAMOD_TRANSMUTATION',			'Transmutation',		'Thaumaturge',	'PROMOTION_TRANSMUTATION'		),
('EAMOD_CONJURATION',			'Conjuration',			'Thaumaturge',	'PROMOTION_CONJURATION'			),
('EAMOD_NECROMANCY',			'Necromancy',			'Thaumaturge',	'PROMOTION_NECROMANCY'			),
('EAMOD_ENCHANTMENT',			'Enchantment',			'Thaumaturge',	'PROMOTION_ENCHANTMENT'			),
('EAMOD_ILLUSION',				'Illusion',				'Thaumaturge',	'PROMOTION_ILLUSION'			);

UPDATE EaModifiers SET ExcludeSubclass = 'Druid' WHERE Type = 'EAMOD_PROSELYTISM';
UPDATE EaModifiers SET ProphetBonus = 1 WHERE Type IN ('EAMOD_PROSELYTISM','EAMOD_DEVOTION');


/*
CREATE TABLE EaModifiers_ModifiesModifier (	'ModType' TEXT NOT NULL, 'ModifiesType' TEXT NOT NULL);
INSERT INTO EaModifiers_ModifiesModifier (ModType, ModifiesType)
SELECT 'EAMOD_BATTLE_MAGERY',	'EAMOD_THAUMATURGY' UNION ALL
SELECT 'EAMOD_TERRAFORMING',	'EAMOD_THAUMATURGY' UNION ALL
SELECT 'EAMOD_TERRAFORMING',	'EAMOD_DEVOTION'	UNION ALL
SELECT 'EAMOD_BENEVOLENCE',		'EAMOD_DEVOTION'	UNION ALL
SELECT 'EAMOD_MALUS',			'EAMOD_THAUMATURGY' UNION ALL
SELECT 'EAMOD_MALUS',			'EAMOD_DEVOTION'	;
*/




INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaModifiers.sql';
