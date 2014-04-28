

--unique creations only (no national wonders!).
--Everything here is either created by a great person or placed by some specific game mechanic.
--Prereqs are controled entirely in EaActions.

CREATE TABLE EaWonders ('ID' INTEGER PRIMARY KEY AUTOINCREMENT,
						'Type' TEXT NOT NULL UNIQUE,
						'Description' TEXT DEFAULT NULL,
						'ImprovementType' TEXT DEFAULT NULL,
						'BuildingType' TEXT DEFAULT NULL,			--1 instance in owning city	
						'BuildingModType' TEXT DEFAULT NULL,		--mod instances in owning city
						'EaAction' TEXT DEFAULT NULL,
						'AzzFollowerOnly' BOOLEAN DEFAULT NULL,	--these 3 control wonder/ruins switch (prereqs in EaActions!)
						'FallenOnly' BOOLEAN DEFAULT NULL,
						'PantheisticOnly' BOOLEAN DEFAULT NULL,
						'IconIndex' INTEGER DEFAULT NULL,
						'IconAtlas' TEXT DEFAULT NULL);
						--Wonders are always associated with a specific iPlot (city iPlot if it is a city wonder) and can change ownership
						--gWonders[ID] = nil or {mod, iPlot} for built wonders
						--or, gWonders[ID][ID2] = {iPlot, ...} if it is a special instance wonder (ID2 is iPerson for Arcane Tower)



INSERT INTO EaWonders (Type,		Description,							ImprovementType,					BuildingType,					BuildingModType,			EaAction						) VALUES
('EA_WONDER_KOLOSSOS',				'TXT_KEY_EA_WONDER_KOLOSSOS',			NULL,								'BUILDING_KOLOSSOS',			NULL,						'EA_ACTION_KOLOSSOS'			),
('EA_WONDER_MEGALOS_FAROS',			'TXT_KEY_EA_WONDER_MEGALOS_FAROS',		NULL,								'BUILDING_MEGALOS_FAROS',		NULL,						'EA_ACTION_MEGALOS_FAROS'		),
('EA_WONDER_HANGING_GARDENS',		'TXT_KEY_EA_WONDER_HANGING_GARDENS',	NULL,								'BUILDING_HANGING_GARDENS',		NULL,						'EA_ACTION_HANGING_GARDENS'		),
('EA_WONDER_UUC_YABNAL',			'TXT_KEY_EA_WONDER_UUC_YABNAL',			NULL,								'BUILDING_UUC_YABNAL',			NULL,						'EA_ACTION_UUC_YABNAL'			),
('EA_WONDER_THE_LONG_WALL',			'TXT_KEY_EA_WONDER_THE_LONG_WALL',		NULL,								'BUILDING_THE_LONG_WALL',		NULL,						'EA_ACTION_THE_LONG_WALL'		),
('EA_WONDER_CLOG_MOR',				'TXT_KEY_EA_WONDER_CLOG_MOR',			NULL,								'BUILDING_CLOG_MOR',			NULL,						'EA_ACTION_CLOG_MOR'			),
('EA_WONDER_DA_BAOEN_SI',			'TXT_KEY_EA_WONDER_DA_BAOEN_SI',		NULL,								'BUILDING_DA_BAOEN_SI',			NULL,						'EA_ACTION_DA_BAOEN_SI'			),

--plot wonders
('EA_WONDER_STANHENCG',				'TXT_KEY_EA_WONDER_STANHENCG',			'IMPROVEMENT_STANHENCG',			NULL,							'BUILDING_MOD_STANHENCG',	'EA_ACTION_STANHENCG'			),
('EA_WONDER_PYRAMID',				'TXT_KEY_EA_WONDER_PYRAMID',			'IMPROVEMENT_PYRAMID',				'BUILDING_PYRAMID',				NULL,						'EA_ACTION_PYRAMID'				),
('EA_WONDER_GREAT_LIBRARY',			'TXT_KEY_EA_WONDER_GREAT_LIBRARY',		'IMPROVEMENT_GREAT_LIBRARY',		'BUILDING_GREAT_LIBRARY',		NULL,						'EA_ACTION_GREAT_LIBRARY'		),
('EA_WONDER_ARCANE_TOWER',			'TXT_KEY_EA_WONDER_ARCANE_TOWER',		'IMPROVEMENT_ARCANE_TOWER',			NULL,							'BUILDING_MOD_ARCANE_TOWER','EA_ACTION_ARCANE_TOWER'		),
('EA_WONDER_TEMPLE_AZZANDARA_1',	'TXT_KEY_EA_WONDER_TEMPLE_AZZANDARA_1',	'IMPROVEMENT_TEMPLE_AZZANDARA_1',	'BUILDING_TEMPLE_AZZANDARA_1',	NULL,						'EA_ACTION_TEMPLE_AZZANDARA_1'	),
('EA_WONDER_TEMPLE_AZZANDARA_2',	'TXT_KEY_EA_WONDER_TEMPLE_AZZANDARA_2',	'IMPROVEMENT_TEMPLE_AZZANDARA_2',	'BUILDING_TEMPLE_AZZANDARA_2',	NULL,						'EA_ACTION_TEMPLE_AZZANDARA_2'	),
('EA_WONDER_TEMPLE_AZZANDARA_3',	'TXT_KEY_EA_WONDER_TEMPLE_AZZANDARA_3',	'IMPROVEMENT_TEMPLE_AZZANDARA_3',	'BUILDING_TEMPLE_AZZANDARA_3',	NULL,						'EA_ACTION_TEMPLE_AZZANDARA_3'	),
('EA_WONDER_TEMPLE_AZZANDARA_4',	'TXT_KEY_EA_WONDER_TEMPLE_AZZANDARA_4',	'IMPROVEMENT_TEMPLE_AZZANDARA_4',	'BUILDING_TEMPLE_AZZANDARA_4',	NULL,						'EA_ACTION_TEMPLE_AZZANDARA_4'	),
('EA_WONDER_TEMPLE_AZZANDARA_5',	'TXT_KEY_EA_WONDER_TEMPLE_AZZANDARA_5',	'IMPROVEMENT_TEMPLE_AZZANDARA_5',	'BUILDING_TEMPLE_AZZANDARA_5',	NULL,						'EA_ACTION_TEMPLE_AZZANDARA_5'	),
('EA_WONDER_TEMPLE_AZZANDARA_6',	'TXT_KEY_EA_WONDER_TEMPLE_AZZANDARA_6',	'IMPROVEMENT_TEMPLE_AZZANDARA_6',	'BUILDING_TEMPLE_AZZANDARA_6',	NULL,						'EA_ACTION_TEMPLE_AZZANDARA_6'	),
('EA_WONDER_TEMPLE_AZZANDARA_7',	'TXT_KEY_EA_WONDER_TEMPLE_AZZANDARA_7',	'IMPROVEMENT_TEMPLE_AZZANDARA_7',	'BUILDING_TEMPLE_AZZANDARA_7',	NULL,						'EA_ACTION_TEMPLE_AZZANDARA_7'	),
('EA_WONDER_TEMPLE_AHRIMAN_1',		'TXT_KEY_EA_WONDER_TEMPLE_AHRIMAN_1',	'IMPROVEMENT_TEMPLE_AHRIMAN_1',		'BUILDING_TEMPLE_AHRIMAN_1',	NULL,						'EA_ACTION_TEMPLE_AHRIMAN_1'	),
('EA_WONDER_TEMPLE_AHRIMAN_2',		'TXT_KEY_EA_WONDER_TEMPLE_AHRIMAN_2',	'IMPROVEMENT_TEMPLE_AHRIMAN_2',		'BUILDING_TEMPLE_AHRIMAN_2',	NULL,						'EA_ACTION_TEMPLE_AHRIMAN_2'	),
('EA_WONDER_TEMPLE_AHRIMAN_3',		'TXT_KEY_EA_WONDER_TEMPLE_AHRIMAN_3',	'IMPROVEMENT_TEMPLE_AHRIMAN_3',		'BUILDING_TEMPLE_AHRIMAN_3',	NULL,						'EA_ACTION_TEMPLE_AHRIMAN_3'	),
('EA_WONDER_TEMPLE_AHRIMAN_4',		'TXT_KEY_EA_WONDER_TEMPLE_AHRIMAN_4',	'IMPROVEMENT_TEMPLE_AHRIMAN_4',		'BUILDING_TEMPLE_AHRIMAN_4',	NULL,						'EA_ACTION_TEMPLE_AHRIMAN_4'	),
('EA_WONDER_TEMPLE_AHRIMAN_5',		'TXT_KEY_EA_WONDER_TEMPLE_AHRIMAN_5',	'IMPROVEMENT_TEMPLE_AHRIMAN_5',		'BUILDING_TEMPLE_AHRIMAN_5',	NULL,						'EA_ACTION_TEMPLE_AHRIMAN_5'	),
('EA_WONDER_TEMPLE_AHRIMAN_6',		'TXT_KEY_EA_WONDER_TEMPLE_AHRIMAN_6',	'IMPROVEMENT_TEMPLE_AHRIMAN_6',		'BUILDING_TEMPLE_AHRIMAN_6',	NULL,						'EA_ACTION_TEMPLE_AHRIMAN_6'	),
('EA_WONDER_TEMPLE_AHRIMAN_7',		'TXT_KEY_EA_WONDER_TEMPLE_AHRIMAN_7',	'IMPROVEMENT_TEMPLE_AHRIMAN_7',		'BUILDING_TEMPLE_AHRIMAN_7',	NULL,						'EA_ACTION_TEMPLE_AHRIMAN_7'	),
('EA_WONDER_TEMPLE_AHRIMAN_8',		'TXT_KEY_EA_WONDER_TEMPLE_AHRIMAN_8',	'IMPROVEMENT_TEMPLE_AHRIMAN_8',		'BUILDING_TEMPLE_AHRIMAN_8',	NULL,						'EA_ACTION_TEMPLE_AHRIMAN_8'	),
('EA_WONDER_TEMPLE_AHRIMAN_9',		'TXT_KEY_EA_WONDER_TEMPLE_AHRIMAN_9',	'IMPROVEMENT_TEMPLE_AHRIMAN_9',		'BUILDING_TEMPLE_AHRIMAN_9',	NULL,						'EA_ACTION_TEMPLE_AHRIMAN_9'	),
('EA_WONDER_TEMPLE_FAGUS',			'TXT_KEY_EA_WONDER_TEMPLE_FAGUS',		'IMPROVEMENT_TEMPLE_FAGUS',			'BUILDING_TEMPLE_FAGUS',		NULL,						'EA_ACTION_TEMPLE_FAGUS'		),
('EA_WONDER_TEMPLE_ABELLIO',		'TXT_KEY_EA_WONDER_TEMPLE_ABELLIO',		'IMPROVEMENT_TEMPLE_ABELLIO',		'BUILDING_TEMPLE_ABELLIO',		NULL,						'EA_ACTION_TEMPLE_ABELLIO'		),
('EA_WONDER_TEMPLE_BUXENUS',		'TXT_KEY_EA_WONDER_TEMPLE_BUXENUS',		'IMPROVEMENT_TEMPLE_BUXENUS',		'BUILDING_TEMPLE_BUXENUS',		NULL,						'EA_ACTION_TEMPLE_BUXENUS'		),
('EA_WONDER_TEMPLE_ROBOR',			'TXT_KEY_EA_WONDER_TEMPLE_ROBOR',		'IMPROVEMENT_TEMPLE_ROBOR',			'BUILDING_TEMPLE_ROBOR',		NULL,						'EA_ACTION_TEMPLE_ROBOR'		),
('EA_WONDER_TEMPLE_ABNOAB',			'TXT_KEY_EA_WONDER_TEMPLE_ABNOAB',		'IMPROVEMENT_TEMPLE_ABNOAB',		'BUILDING_TEMPLE_ABNOAB',		NULL,						'EA_ACTION_TEMPLE_ABNOAB'		),
('EA_WONDER_TEMPLE_EPONA',			'TXT_KEY_EA_WONDER_TEMPLE_EPONA',		'IMPROVEMENT_TEMPLE_EPONA',			'BUILDING_TEMPLE_EPONA',		NULL,						'EA_ACTION_TEMPLE_EPONA'		),
('EA_WONDER_TEMPLE_ATEPOMARUS',		'TXT_KEY_EA_WONDER_TEMPLE_ATEPOMARUS',	'IMPROVEMENT_TEMPLE_ATEPOMARUS',	'BUILDING_TEMPLE_ATEPOMARUS',	NULL,						'EA_ACTION_TEMPLE_ATEPOMARUS'	),
('EA_WONDER_TEMPLE_SABAZIOS',		'TXT_KEY_EA_WONDER_TEMPLE_SABAZIOS',	'IMPROVEMENT_TEMPLE_SABAZIOS',		'BUILDING_TEMPLE_SABAZIOS',		NULL,						'EA_ACTION_TEMPLE_SABAZIOS'		),
('EA_WONDER_TEMPLE_AVETA',			'TXT_KEY_EA_WONDER_TEMPLE_AVETA',		'IMPROVEMENT_TEMPLE_AVETA',			'BUILDING_TEMPLE_AVETA',		NULL,						'EA_ACTION_TEMPLE_AVETA'		),
('EA_WONDER_TEMPLE_CONDATIS',		'TXT_KEY_EA_WONDER_TEMPLE_CONDATIS',	'IMPROVEMENT_TEMPLE_CONDATIS',		'BUILDING_TEMPLE_CONDATIS',		NULL,						'EA_ACTION_TEMPLE_CONDATIS'		),
('EA_WONDER_TEMPLE_ABANDINUS',		'TXT_KEY_EA_WONDER_TEMPLE_ABANDINUS',	'IMPROVEMENT_TEMPLE_ABANDINUS',		'BUILDING_TEMPLE_ABANDINUS',	NULL,						'EA_ACTION_TEMPLE_ABANDINUS'	),
('EA_WONDER_TEMPLE_ADSULLATA',		'TXT_KEY_EA_WONDER_TEMPLE_ADSULLATA',	'IMPROVEMENT_TEMPLE_ADSULLATA',		'BUILDING_TEMPLE_ADSULLATA',	NULL,						'EA_ACTION_TEMPLE_ADSULLATA'	),
('EA_WONDER_TEMPLE_ICAUNUS',		'TXT_KEY_EA_WONDER_TEMPLE_ICAUNUS',		'IMPROVEMENT_TEMPLE_ICAUNUS',		'BUILDING_TEMPLE_ICAUNUS',		NULL,						'EA_ACTION_TEMPLE_ICAUNUS'		),
('EA_WONDER_TEMPLE_BELISAMA',		'TXT_KEY_EA_WONDER_TEMPLE_BELISAMA',	'IMPROVEMENT_TEMPLE_BELISAMA',		'BUILDING_TEMPLE_BELISAMA',		NULL,						'EA_ACTION_TEMPLE_BELISAMA'		),
('EA_WONDER_TEMPLE_CLOTA',			'TXT_KEY_EA_WONDER_TEMPLE_CLOTA',		'IMPROVEMENT_TEMPLE_CLOTA',			'BUILDING_TEMPLE_CLOTA',		NULL,						'EA_ACTION_TEMPLE_CLOTA'		),
('EA_WONDER_TEMPLE_SABRINA',		'TXT_KEY_EA_WONDER_TEMPLE_SABRINA',		'IMPROVEMENT_TEMPLE_SABRINA',		'BUILDING_TEMPLE_SABRINA',		NULL,						'EA_ACTION_TEMPLE_SABRINA'		),
('EA_WONDER_TEMPLE_SEQUANA',		'TXT_KEY_EA_WONDER_TEMPLE_SEQUANA',		'IMPROVEMENT_TEMPLE_SEQUANA',		'BUILDING_TEMPLE_SEQUANA',		NULL,						'EA_ACTION_TEMPLE_SEQUANA'		),
('EA_WONDER_TEMPLE_VERBEIA',		'TXT_KEY_EA_WONDER_TEMPLE_VERBEIA',		'IMPROVEMENT_TEMPLE_VERBEIA',		'BUILDING_TEMPLE_VERBEIA',		NULL,						'EA_ACTION_TEMPLE_VERBEIA'		),
('EA_WONDER_TEMPLE_BORVO',			'TXT_KEY_EA_WONDER_TEMPLE_BORVO',		'IMPROVEMENT_TEMPLE_BORVO',			'BUILDING_TEMPLE_BORVO',		NULL,						'EA_ACTION_TEMPLE_BORVO'		),
('EA_WONDER_TEMPLE_AEGIR',			'TXT_KEY_EA_WONDER_TEMPLE_AEGIR',		'IMPROVEMENT_TEMPLE_AEGIR',			'BUILDING_TEMPLE_AEGIR',		NULL,						'EA_ACTION_TEMPLE_AEGIR'		),
('EA_WONDER_TEMPLE_BARINTHUS',		'TXT_KEY_EA_WONDER_TEMPLE_BARINTHUS',	'IMPROVEMENT_TEMPLE_BARINTHUS',		'BUILDING_TEMPLE_BARINTHUS',	NULL,						'EA_ACTION_TEMPLE_BARINTHUS'	),
('EA_WONDER_TEMPLE_LIBAN',			'TXT_KEY_EA_WONDER_TEMPLE_LIBAN',		'IMPROVEMENT_TEMPLE_LIBAN',			'BUILDING_TEMPLE_LIBAN',		NULL,						'EA_ACTION_TEMPLE_LIBAN'		),
('EA_WONDER_TEMPLE_FIMAFENG',		'TXT_KEY_EA_WONDER_TEMPLE_FIMAFENG',	'IMPROVEMENT_TEMPLE_FIMAFENG',		'BUILDING_TEMPLE_FIMAFENG',		NULL,						'EA_ACTION_TEMPLE_FIMAFENG'		),
('EA_WONDER_TEMPLE_ELDIR',			'TXT_KEY_EA_WONDER_TEMPLE_ELDIR',		'IMPROVEMENT_TEMPLE_ELDIR',			'BUILDING_TEMPLE_ELDIR',		NULL,						'EA_ACTION_TEMPLE_ELDIR'		),
('EA_WONDER_TEMPLE_RITONA',			'TXT_KEY_EA_WONDER_TEMPLE_RITONA',		'IMPROVEMENT_TEMPLE_RITONA',		'BUILDING_TEMPLE_RITONA',		NULL,						'EA_ACTION_TEMPLE_RITONA'		),
('EA_WONDER_TEMPLE_BAKKHOS',		'TXT_KEY_EA_WONDER_TEMPLE_BAKKHOS',		'IMPROVEMENT_TEMPLE_BAKKHOS',		'BUILDING_TEMPLE_BAKKHOS',		NULL,						'EA_ACTION_TEMPLE_BAKKHOS'		),
('EA_WONDER_TEMPLE_PAN',			'TXT_KEY_EA_WONDER_TEMPLE_PAN',			'IMPROVEMENT_TEMPLE_PAN',			'BUILDING_TEMPLE_PAN',			NULL,						'EA_ACTION_TEMPLE_PAN'			),
('EA_WONDER_TEMPLE_SILENUS',		'TXT_KEY_EA_WONDER_TEMPLE_SILENUS',		'IMPROVEMENT_TEMPLE_SILENUS',		'BUILDING_TEMPLE_SILENUS',		NULL,						'EA_ACTION_TEMPLE_SILENUS'		),
('EA_WONDER_TEMPLE_ERECURA',		'TXT_KEY_EA_WONDER_TEMPLE_ERECURA',		'IMPROVEMENT_TEMPLE_ERECURA',		'BUILDING_TEMPLE_ERECURA',		NULL,						'EA_ACTION_TEMPLE_ERECURA'		),
('EA_WONDER_TEMPLE_VOSEGUS',		'TXT_KEY_EA_WONDER_TEMPLE_VOSEGUS',		'IMPROVEMENT_TEMPLE_VOSEGUS',		'BUILDING_TEMPLE_VOSEGUS',		NULL,						'EA_ACTION_TEMPLE_VOSEGUS'		),
('EA_WONDER_TEMPLE_NANTOSUELTA',	'TXT_KEY_EA_WONDER_TEMPLE_NANTOSUELTA',	'IMPROVEMENT_TEMPLE_NANTOSUELTA',	'BUILDING_TEMPLE_NANTOSUELTA',	NULL,						'EA_ACTION_TEMPLE_NANTOSUELTA'	),
('EA_WONDER_TEMPLE_DIS_PATER',		'TXT_KEY_EA_WONDER_TEMPLE_DIS_PATER',	'IMPROVEMENT_TEMPLE_DIS_PATER',		'BUILDING_TEMPLE_DIS_PATER',	NULL,						'EA_ACTION_TEMPLE_DIS_PATER'	),
('EA_WONDER_TEMPLE_NERGAL',			'TXT_KEY_EA_WONDER_TEMPLE_NERGAL',		'IMPROVEMENT_TEMPLE_NERGAL',		'BUILDING_TEMPLE_NERGAL',		NULL,						'EA_ACTION_TEMPLE_NERGAL'		),
('EA_WONDER_TEMPLE_WADD',			'TXT_KEY_EA_WONDER_TEMPLE_WADD',		'IMPROVEMENT_TEMPLE_WADD',			'BUILDING_TEMPLE_WADD',			NULL,						'EA_ACTION_TEMPLE_WADD'			),
('EA_WONDER_TEMPLE_ABGAL',			'TXT_KEY_EA_WONDER_TEMPLE_ABGAL',		'IMPROVEMENT_TEMPLE_ABGAL',			'BUILDING_TEMPLE_ABGAL',			NULL,						'EA_ACTION_TEMPLE_ABGAL'			),
('EA_WONDER_TEMPLE_NESR',			'TXT_KEY_EA_WONDER_TEMPLE_NESR',		'IMPROVEMENT_TEMPLE_NESR',			'BUILDING_TEMPLE_NESR',			NULL,						'EA_ACTION_TEMPLE_NESR'			);


UPDATE EaWonders SET AzzFollowerOnly = 1 WHERE Type GLOB 'EA_WONDER_TEMPLE_AZZANDARA_*';
UPDATE EaWonders SET FallenOnly = 1 WHERE Type GLOB 'EA_WONDER_TEMPLE_AHRIMAN_*';

UPDATE EaWonders SET IconIndex = (SELECT IconIndex FROM EaActions WHERE EaWonder = EaWonders.Type);
UPDATE EaWonders SET IconAtlas = (SELECT IconAtlas FROM EaActions WHERE EaWonder = EaWonders.Type);
UPDATE EaWonders SET IconIndex = 3, IconAtlas = 'UNIT_ACTION_ATLAS_EXP2' WHERE Type = 'EA_WONDER_ARCANE_TOWER';

INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaWonders.sql';