
-----------------------------------------------------------------------------------------
-- Terrain
-----------------------------------------------------------------------------------------

INSERT INTO ArtDefine_LandmarkTypes (Type,	LandmarkType,	FriendlyName) VALUES
('ART_DEF_RESOURCE_POPPY',					'Resource',		'Poppy'		),
('ART_DEF_RESOURCE_TOBACCO',				'Resource',		'Tobacco'	),
('ART_DEF_RESOURCE_ALOEVERA',				'Resource',		'Moly'		),
('ART_DEF_RESOURCE_MANGANESE',				'Resource',		'Cinnabar'	),	--Paz adjusted colors
('ART_DEF_RESOURCE_BERRIES',				'Resource',		'Berries'	),
('ART_DEF_RESOURCE_TEA',					'Resource',		'Tea'		),
('ART_DEF_RESOURCE_LUBORIC',				'Resource',		'Jade'		),	--adjusted colors from G&K?
('ART_DEF_RESOURCE_TIN',					'Resource',		'Copper'	),	--Paz adjusted colors
('ART_DEF_IMPROVEMENT_FARM_FIX',			'Improvement',	'Farm Fix'	),
('ART_DEF_IMPROVEMENT_PYRAMID',				'Improvement',	'Pyramids'	),
('ART_DEF_IMPROVEMENT_STONEHENGE',			'Improvement',	'Stonehenge'),
('ART_DEF_IMPROVEMENT_BLIGHT',				'Improvement',	'Blight'	);

INSERT INTO ArtDefine_StrategicView (StrategicViewType, TileType, Asset) VALUES
('ART_DEF_RESOURCE_POPPY',				'Resource',		'SV_Poppy.dds'		),
('ART_DEF_RESOURCE_TOBACCO',			'Resource',		'sv_tobacco.dds'	),
('ART_DEF_RESOURCE_ALOEVERA',			'Resource',		'SV_Aloevera.dds'	),
('ART_DEF_RESOURCE_MANGANESE',			'Resource',		'SV_Manganese.dds'	),
('ART_DEF_RESOURCE_BERRIES',			'Resource',		'SV_Berries.dds'	),
('ART_DEF_RESOURCE_TEA',				'Resource',		'SV_Tea.dds'		),
('ART_DEF_RESOURCE_LUBORIC',			'Resource',		'sv_jade.dds'		),
('ART_DEF_RESOURCE_TIN',				'Resource',		'sv_newcopper.dds'	),
('ART_DEF_IMPROVEMENT_FARM_FIX',		'Improvement',	'SV_Farm.dds'		),
('ART_DEF_IMPROVEMENT_PYRAMID',			'Improvement',	'sv_landmark.dds'	),
('ART_DEF_IMPROVEMENT_STONEHENGE',		'Improvement',	'sv_landmark.dds'	),
('ART_DEF_IMPROVEMENT_BLIGHT',			'Improvement',	'sv_uranium.dds'	);

INSERT INTO ArtDefine_Landmarks (Era, State, Scale,	ImprovementType,					LayoutHandler,	ResourceType,					Model,								TerrainContour) VALUES
('Any',		'Any',				0.9399999976158142,	'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_POPPY',		'Resource_Poppy.fxsxml',			1	),
('Ancient',	'UnderConstruction',0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_POPPY',		'HB_Plantation_MID_Poppy.fxsxml',	1	),
('Ancient',	'Constructed',		0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_POPPY',		'Plantation_MID_Poppy.fxsxml',		1	),
('Ancient',	'Pillaged',			0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_POPPY',		'PL_Plantation_MID_Poppy.fxsxml',	1	),
('Any',		'Any',				0.9800000190734863,	'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TOBACCO',		'Resource_Tobacco.fxsxml',			1	),
('Ancient',	'UnderConstruction',0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TOBACCO',		'HB_Plantation_MID_Tobacco.fxsxml',	1	),
('Ancient',	'Constructed',		0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TOBACCO',		'Plantation_MID_Tobacco.fxsxml',	1	),
('Ancient',	'Pillaged',			0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TOBACCO',		'PL_Plantation_MID_Tobacco.fxsxml',	1	),
('Any',		'Any',				0.9399999976158142,	'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_ALOEVERA',	'Resource_Aloevera.fxsxml',			1	),
('Ancient',	'UnderConstruction',0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALOEVERA',	'HB_Plantation_MID_Aloevera.fxsxml',1	),
('Ancient',	'Constructed',		0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALOEVERA',	'Plantation_MID_Aloevera.fxsxml',	1	),
('Ancient',	'Pillaged',			0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALOEVERA',	'PL_Plantation_MID_Aloevera.fxsxml',1	),
('Any',		'Any',				1,					'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_MANGANESE',	'Manganese.fxsxml',					1	),
('Ancient',	'UnderConstruction',1,					'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_MANGANESE',	'HB_MED_Mine_Manganese.fxsxml',		1	),
('Ancient',	'Constructed',		1,					'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_MANGANESE',	'MED_Mine_Manganese.fxsxml',		1	),
('Ancient',	'Pillaged',			1,					'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_MANGANESE',	'PL_MED_Mine_Manganese.fxsxml',		1	),
('Any',		'Any',				1,					'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_BERRIES',		'Resource_Berries.fxsxml',			1	),
('Ancient',	'UnderConstruction',1,					'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_BERRIES',		'HB_Plantation_MID_Berries.fxsxml',	1	),
('Ancient',	'Constructed',		1,					'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_BERRIES',		'Plantation_MID_Berries.fxsxml',	1	),
('Ancient',	'Pillaged',			1,					'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_BERRIES',		'PL_Plantation_MID_Berries.fxsxml',	1	),
('Any',		'Any',				0.7399999976158142,	'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TEA',			'Resource_Tea.fxsxml',				1	),
('Ancient',	'UnderConstruction',0.7599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TEA',			'HB_Plantation_MID_Tea.fxsxml',		1	),
('Ancient',	'Constructed',		0.7599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TEA',			'Plantation_MID_Tea.fxsxml',		1	),
('Ancient',	'Pillaged',			0.7599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TEA',			'APL_Plantation_MID_Tea.fxsxml',	1	),
('Any',		'Any',				1.0,				'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_LUBORIC',		'luboric.fxsxml',					1	),
('Ancient',	'UnderConstruction',1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_LUBORIC',		'hb_med_luboric_mine.fxsxml',		1	),
('Ancient',	'Constructed',		1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_LUBORIC',		'med_mine_luboric.fxsxml',			1	),
('Ancient',	'Pillaged',			1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_LUBORIC',		'pl_med_mine_luboric.fxsxml',		1	),
('Any',		'Any',				1.0,				'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TIN',			'tin.fxsxml',						1	),
('Ancient',	'UnderConstruction',1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TIN',			'hb_med_tin_mine.fxsxml',			1	),
('Ancient',	'Constructed',		1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TIN',			'med_tin_mine.fxsxml',				1	),
('Ancient',	'Pillaged',			1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TIN',			'pl_med_mine_tin.fxsxml',			1	),
--alt farm graphic since base farm is hardcoded to "IMPROVEMENT_FARM"
('Any', 'UnderConstruction',	1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',		'HBfarmfix01.fxsxml',				1	),
('Any', 'Constructed',			1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',		'farmwheat01.fxsxml',				1	),
('Any', 'Pillaged',				1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',		'PLfarmfix01.fxsxml',				1	),
('Any', 'UnderConstruction',	1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',		'HBfarmfix02.fxsxml',				1	),
('Any', 'Constructed',			1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',		'farmwheat02.fxsxml',				1	),
('Any', 'Pillaged',				1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',		'PLfarmfix02.fxsxml',				1	),
('Any', 'UnderConstruction',	1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',		'HBfarmfix03.fxsxml',				1	),
('Any', 'Constructed',			1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',		'farmwheat03.fxsxml',				1	),
('Any', 'Pillaged',				1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',		'PLfarmfix03.fxsxml',				1	),
--fishing on lakes
('Any',	'Any',					0.07000000029802322,'ART_DEF_IMPROVEMENT_FISHING_BOATS','ANIMATED',		'ART_DEF_RESOURCE_NONE',		'Fish.fxsxml',						1	),
--Wonder improvements
('Any', 'UnderConstruction',	1,  				'ART_DEF_IMPROVEMENT_PYRAMID',		'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',		'hb_pyramidsTI.fxsxml',				1	),
('Any', 'Constructed',			1,  				'ART_DEF_IMPROVEMENT_PYRAMID',		'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',		'pyramidsTI.fxsxml',				1	),
('Any', 'Pillaged',				1,  				'ART_DEF_IMPROVEMENT_PYRAMID',		'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',		'pl_pyramidsTI.fxsxml',				1	),
('Any', 'UnderConstruction',	1,  				'ART_DEF_IMPROVEMENT_STONEHENGE',	'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',		'hb_stonehengeTI.fxsxml',			1	),
('Any', 'Constructed',			1,  				'ART_DEF_IMPROVEMENT_STONEHENGE',	'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',		'stonehengeTI.fxsxml',				1	),
('Any', 'Pillaged',				1,  				'ART_DEF_IMPROVEMENT_STONEHENGE',	'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',		'pl_stonehengeTI.fxsxml',			1	),

--Blight
('Any',	'Any',					1.45,				'ART_DEF_IMPROVEMENT_BLIGHT',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',			'blight.fxsxml',					0	),
('Any',	'Any',					1.45,				'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_BLIGHT',		'blight.fxsxml',					0	),
('Any',	'Any',					1.45,				'ART_DEF_IMPROVEMENT_CHATEAU',		'SNAPSHOT',		'ART_DEF_RESOURCE_BLIGHT',		'blight.fxsxml',					0	);	--Arcane Tower


-----------------------------------------------------------------------------------------
-- Units
-----------------------------------------------------------------------------------------

INSERT INTO ArtDefine_StrategicView(StrategicViewType, TileType, Asset) VALUES
--animals
('ART_DEF_UNIT_WOLF',				'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_WOLVES',				'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_LION',				'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_LIONS',				'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_GRIFFON',			'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_GRIFFONS',			'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_SCORPION_SAND',		'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_SCORPIONS_SAND',		'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_SCORPION_BLACK',		'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_SCORPIONS_BLACK',	'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_SCORPION_WHITE',		'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_SCORPIONS_WHITE',	'Unit',	'SV_Jaguar.dds'		),
--beasts
('ART_DEF_UNIT_KRAKEN',				'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_GIANT_SPIDER',		'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_DRAKE_GREEN',		'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_DRAKE_BLUE',		'Unit',	'SV_Jaguar.dds'		),
('ART_DEF_UNIT_DRAKE_RED',			'Unit',	'SV_Jaguar.dds'		),
--barbs
('ART_DEF_UNIT_OGRE',				'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_STONESKIN_OGRE',		'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_NAGA_GREEN',			'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_NAGA_BLUE',			'Unit',	'SV_Maori.dds'		),
--regulars
('ART_DEF_UNIT_MAN_CHARIOT',		'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_ORC_SPEARMAN',		'Unit',	'SV_Spearman.dds'	),
('ART_DEF_UNIT_GOBLIN_WARRIOR',		'Unit',	'SV_Spearman.dds'	),
('ART_DEF_UNIT_GOBLIN_ARCHER',		'Unit',	'SV_Spearman.dds'	),
('ART_DEF_UNIT_GOBLIN_CROSSBOWMAN',	'Unit',	'SV_Spearman.dds'	),
('ART_DEF_UNIT_GOBLIN_SCOUT',		'Unit',	'SV_Spearman.dds'	),
('ART_DEF_UNIT_GOBLIN_TRACKER',		'Unit',	'SV_Spearman.dds'	),
('ART_DEF_UNIT_GOBLIN_WOLF_RIDER',	'Unit',	'SV_Spearman.dds'	),
--summoned/called
('ART_DEF_UNIT_TREE_ENT',			'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_SKELETON_SWORDSMAN',	'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_ZOMBIE',				'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_GREAT_UNCLEAN_ONE',	'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_HIVE_TYRANT',		'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_LICTOR',				'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_HORMAGAUNT',			'Unit',	'SV_Maori.dds'		),
--('ART_DEF_UNIT_CARNIFEX',			'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_ANGEL_SPEARMAN',		'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_ANGEL',				'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_ARCHANGEL',			'Unit',	'SV_Maori.dds'		),
('ART_DEF_UNIT_STORM_GIANT',		'Unit',	'SV_Maori.dds'		);


INSERT INTO ArtDefine_UnitInfos (Type,	DamageStates,	Formation) VALUES
--animals
('ART_DEF_UNIT_WOLF',					1,				''					),
('ART_DEF_UNIT_WOLVES',					1,				'Barbarian'			),
('ART_DEF_UNIT_LION',					1,				''					),
('ART_DEF_UNIT_LIONS',					1,				'Barbarian'			),
('ART_DEF_UNIT_GRIFFON',				1,				''					),
('ART_DEF_UNIT_GRIFFONS',				1,				'Barbarian'			),
('ART_DEF_UNIT_SCORPION_SAND',			1,				''					),
('ART_DEF_UNIT_SCORPIONS_SAND',			1,				'Barbarian'			),
('ART_DEF_UNIT_SCORPION_BLACK',			1,				''					),
('ART_DEF_UNIT_SCORPIONS_BLACK',		1,				'Barbarian'			),
('ART_DEF_UNIT_SCORPION_WHITE',			1,				''					),
('ART_DEF_UNIT_SCORPIONS_WHITE',		1,				'Barbarian'			),
--beasts
--('ART_DEF_UNIT_SPIDER',				1,				''					),
--('ART_DEF_UNIT_SPIDERS',				1,				'Barbarian'			),
('ART_DEF_UNIT_KRAKEN',					1,				''					),
('ART_DEF_UNIT_GIANT_SPIDER',			1,				''					),
('ART_DEF_UNIT_DRAKE_GREEN',			1,				''					),
('ART_DEF_UNIT_DRAKE_BLUE',			1,				''					),
('ART_DEF_UNIT_DRAKE_RED',				1,				''					),
--barbs
('ART_DEF_UNIT_OGRE',					1,				'UnFormed'			),	--Hobgoblins
('ART_DEF_UNIT_STONESKIN_OGRE',			1,				'UnFormed'			),	--Ogres
('ART_DEF_UNIT_NAGA_GREEN',				1,				'Barbarian'			),	
('ART_DEF_UNIT_NAGA_BLUE',				1,				'Barbarian'			),	
--regulars
('ART_DEF_UNIT_MAN_CHARIOT',			1,				'ChariotElephant'	),
('ART_DEF_UNIT_ORC_SPEARMAN',			1,				'Barbarian'			),
('ART_DEF_UNIT_GOBLIN_WARRIOR',			1,				'Barbarian'			),
('ART_DEF_UNIT_GOBLIN_ARCHER',			1,				'Archer'			),
('ART_DEF_UNIT_GOBLIN_CROSSBOWMAN',		1,				'Archer'			),
('ART_DEF_UNIT_GOBLIN_SCOUT',			1,				'Scout'				),
('ART_DEF_UNIT_GOBLIN_TRACKER',			1,				'Scout'				),
('ART_DEF_UNIT_GOBLIN_WOLF_RIDER',		1,				'DefaultCavalry'	),
--summoned/called
('ART_DEF_UNIT_TREE_ENT',				1,				''					),
('ART_DEF_UNIT_SKELETON_SWORDSMAN',		1,				'Barbarian'			),
('ART_DEF_UNIT_ZOMBIE',					1,				'Barbarian'			),
('ART_DEF_UNIT_GREAT_UNCLEAN_ONE',		1,				''					),
('ART_DEF_UNIT_HIVE_TYRANT',			1,				''					),
('ART_DEF_UNIT_LICTOR',					1,				''					),
('ART_DEF_UNIT_HORMAGAUNT',				1,				'Barbarian'			),
--('ART_DEF_UNIT_CARNIFEX',				1,				''					),
('ART_DEF_UNIT_ANGEL_SPEARMAN',			1,				'Phalanx'			),
('ART_DEF_UNIT_ANGEL',					1,				''					),
('ART_DEF_UNIT_ARCHANGEL',				1,				''					),
('ART_DEF_UNIT_STORM_GIANT',			1,				''					),


('ART_DEF_UNIT_EA_ENGINEER',			1,				''					),
('ART_DEF_UNIT_EA_MERCHANT',			1,				''					),
('ART_DEF_UNIT_EA_SAGE',				1,				''					),
('ART_DEF_UNIT_EA_ARTIST',				1,				''					),
('ART_DEF_UNIT_EA_WARRIOR',				1,				''					),
('ART_DEF_UNIT_EA_PALADIN',				1,				''					),
('ART_DEF_UNIT_EA_EIDOLON',				1,				''					),
('ART_DEF_UNIT_EA_DRUID',				1,				''					),
('ART_DEF_UNIT_EA_PRIEST',				1,				''					),
('ART_DEF_UNIT_EA_DRUID_MAGIC_MISSLE',	1,				''					),
('ART_DEF_UNIT_EA_PRIEST_MAGIC_MISSLE',	1,				''					);

INSERT INTO ArtDefine_UnitInfoMemberInfos (UnitInfoType,	UnitMemberInfoType,		NumMembers) VALUES
--animals
('ART_DEF_UNIT_WOLF',					'ART_DEF_UNIT_MEMBER_DIREWOLF',				1		),
('ART_DEF_UNIT_WOLVES',					'ART_DEF_UNIT_MEMBER_DIREWOLF',				7		),
--('ART_DEF_UNIT_WOLVES',					'ART_DEF_UNIT_MEMBER_DIREWOLF_DARK',		3		),
('ART_DEF_UNIT_LION',					'ART_DEF_UNIT_MEMBER_LION',					1		),
('ART_DEF_UNIT_LIONS',					'ART_DEF_UNIT_MEMBER_LION',					4		),
('ART_DEF_UNIT_GRIFFON',				'ART_DEF_UNIT_MEMBER_GRIFFON',				1		),
('ART_DEF_UNIT_GRIFFONS',				'ART_DEF_UNIT_MEMBER_GRIFFON',				4		),
('ART_DEF_UNIT_SCORPION_SAND',			'ART_DEF_UNIT_MEMBER_SCORPION_SAND',		1		),
('ART_DEF_UNIT_SCORPIONS_SAND',			'ART_DEF_UNIT_MEMBER_SCORPION_SAND',		6		),
('ART_DEF_UNIT_SCORPION_BLACK',			'ART_DEF_UNIT_MEMBER_SCORPION_BLACK',		1		),
('ART_DEF_UNIT_SCORPIONS_BLACK',		'ART_DEF_UNIT_MEMBER_SCORPION_BLACK',		6		),
('ART_DEF_UNIT_SCORPION_WHITE',			'ART_DEF_UNIT_MEMBER_SCORPION_WHITE',		1		),
('ART_DEF_UNIT_SCORPIONS_WHITE',		'ART_DEF_UNIT_MEMBER_SCORPION_WHITE',		6		),
--beasts
('ART_DEF_UNIT_KRAKEN',					'ART_DEF_UNIT_MEMBER_KRAKEN',				1		),
('ART_DEF_UNIT_GIANT_SPIDER',			'ART_DEF_UNIT_MEMBER_GIANT_SPIDER',			1		),
('ART_DEF_UNIT_DRAKE_GREEN',			'ART_DEF_UNIT_MEMBER_DRAKE_GREEN',			1		),
('ART_DEF_UNIT_DRAKE_BLUE',			'ART_DEF_UNIT_MEMBER_DRAKE_BLUE',			1		),
('ART_DEF_UNIT_DRAKE_RED',				'ART_DEF_UNIT_MEMBER_DRAKE_RED',			1		),
--barbs
('ART_DEF_UNIT_OGRE',					'ART_DEF_UNIT_MEMBER_OGRE',					10		),
('ART_DEF_UNIT_STONESKIN_OGRE',			'ART_DEF_UNIT_MEMBER_STONESKIN_OGRE',		1		),
('ART_DEF_UNIT_STONESKIN_OGRE',			'ART_DEF_UNIT_MEMBER_STONESKIN_OGRE_2',		1		),
('ART_DEF_UNIT_STONESKIN_OGRE',			'ART_DEF_UNIT_MEMBER_STONESKIN_OGRE',		1		),
('ART_DEF_UNIT_STONESKIN_OGRE',			'ART_DEF_UNIT_MEMBER_STONESKIN_OGRE_2',		1		),
('ART_DEF_UNIT_STONESKIN_OGRE',			'ART_DEF_UNIT_MEMBER_STONESKIN_OGRE',		1		),

('ART_DEF_UNIT_NAGA_GREEN',				'ART_DEF_UNIT_MEMBER_NAGA_GREEN',			6		),
('ART_DEF_UNIT_NAGA_BLUE',				'ART_DEF_UNIT_MEMBER_NAGA_BLUE',			6		),
--regulars
('ART_DEF_UNIT_MAN_CHARIOT',			'ART_DEF_UNIT_MEMBER_MAN_CHARIOT',			2		),
('ART_DEF_UNIT_ORC_SPEARMAN',			'ART_DEF_UNIT_MEMBER_ORC_SPEARMAN',			12		),
('ART_DEF_UNIT_GOBLIN_WARRIOR',			'ART_DEF_UNIT_MEMBER_GOBLIN_WARRIOR',		18		),
('ART_DEF_UNIT_GOBLIN_ARCHER',			'ART_DEF_UNIT_MEMBER_GOBLIN_ARCHER',		12		),
('ART_DEF_UNIT_GOBLIN_CROSSBOWMAN',		'ART_DEF_UNIT_MEMBER_GOBLIN_CROSSBOWMAN',	12		),
('ART_DEF_UNIT_GOBLIN_SCOUT',			'ART_DEF_UNIT_MEMBER_GOBLIN_SCOUT',			8		),
('ART_DEF_UNIT_GOBLIN_TRACKER',			'ART_DEF_UNIT_MEMBER_GOBLIN_TRACKER',		8		),
('ART_DEF_UNIT_GOBLIN_WOLF_RIDER',		'ART_DEF_UNIT_MEMBER_GOBLIN_WOLF_RIDER',	10		),
--summoned/called
('ART_DEF_UNIT_TREE_ENT',				'ART_DEF_UNIT_MEMBER_TREE_ENT',				1		),
('ART_DEF_UNIT_SKELETON_SWORDSMAN',		'ART_DEF_UNIT_MEMBER_SKELETON_SWORDSMAN',	11		),
('ART_DEF_UNIT_ZOMBIE',					'ART_DEF_UNIT_MEMBER_ZOMBIE',				11		),
('ART_DEF_UNIT_GREAT_UNCLEAN_ONE',		'ART_DEF_UNIT_MEMBER_GREAT_UNCLEAN_ONE',	1		),
('ART_DEF_UNIT_HIVE_TYRANT',			'ART_DEF_UNIT_MEMBER_HIVE_TYRANT',			1		),
('ART_DEF_UNIT_LICTOR',					'ART_DEF_UNIT_MEMBER_LICTOR',				1		),
('ART_DEF_UNIT_HORMAGAUNT',				'ART_DEF_UNIT_MEMBER_HORMAGAUNT',			8		),
--('ART_DEF_UNIT_CARNIFEX',				'ART_DEF_UNIT_MEMBER_CARNIFEX',				1		),
('ART_DEF_UNIT_ANGEL_SPEARMAN',			'ART_DEF_UNIT_MEMBER_ANGEL_SPEARMAN',		12		),
('ART_DEF_UNIT_ANGEL',					'ART_DEF_UNIT_MEMBER_ANGEL',				1		),
('ART_DEF_UNIT_ARCHANGEL',				'ART_DEF_UNIT_MEMBER_ARCHANGEL',			1		),
('ART_DEF_UNIT_STORM_GIANT',			'ART_DEF_UNIT_MEMBER_STORM_GIANT',			1		),

('ART_DEF_UNIT_EA_ENGINEER',			'ART_DEF_UNIT_MEMBER_EA_ENGINEER',			1		),
('ART_DEF_UNIT_EA_MERCHANT',			'ART_DEF_UNIT_MEMBER_EA_MERCHANT',			1		),
('ART_DEF_UNIT_EA_SAGE',				'ART_DEF_UNIT_MEMBER_EA_SAGE',				1		),
('ART_DEF_UNIT_EA_ARTIST',				'ART_DEF_UNIT_MEMBER_EA_ARTIST',			1		),
('ART_DEF_UNIT_EA_WARRIOR',				'ART_DEF_UNIT_MEMBER_EA_WARRIOR',			1		),
('ART_DEF_UNIT_EA_PALADIN',				'ART_DEF_UNIT_MEMBER_EA_PALADIN',			1		),
('ART_DEF_UNIT_EA_DRUID',				'ART_DEF_UNIT_MEMBER_EA_DRUID',				1		),
('ART_DEF_UNIT_EA_PRIEST',				'ART_DEF_UNIT_MEMBER_EA_PRIEST',			1		),
('ART_DEF_UNIT_EA_DRUID_MAGIC_MISSLE',	'ART_DEF_UNIT_MEMBER_EA_MAGIC_MISSILE',		1		),
('ART_DEF_UNIT_EA_DRUID_MAGIC_MISSLE',	'ART_DEF_UNIT_MEMBER_EA_DRUID',				1		),
('ART_DEF_UNIT_EA_PRIEST_MAGIC_MISSLE',	'ART_DEF_UNIT_MEMBER_EA_MAGIC_MISSILE',		1		),
('ART_DEF_UNIT_EA_PRIEST_MAGIC_MISSLE',	'ART_DEF_UNIT_MEMBER_EA_PRIEST',			1		);


INSERT INTO ArtDefine_UnitMemberInfos (Type,Scale,	Domain,		Model,							MaterialTypeTag,	MaterialTypeSoundOverrideTag) VALUES
--animals
('ART_DEF_UNIT_MEMBER_DIREWOLF',			2,		'',			'direwolf.fxsxml',				'CLOTH',			'FLESH'			),
--('ART_DEF_UNIT_MEMBER_DIREWOLF_DARK',		2,		'',			'direwolf_dark.fxsxml',			'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_LION',				2.5,	'',			'lion.fxsxml',					'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_GRIFFON',				2.5,	'Hover',	'griffon.fxsxml',				'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_SCORPION_SAND',		0.2,	'',			'Scorpion_Sand.fxsxml',			'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_SCORPION_BLACK',		0.2,	'',			'Scorpion_Black.fxsxml',		'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_SCORPION_WHITE',		0.2,	'',			'Scorpion_White.fxsxml',		'CLOTH',			'FLESH'			),
--beasts
('ART_DEF_UNIT_MEMBER_KRAKEN',				1,		'Sea',		'kraken.fxsxml',				'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_GIANT_SPIDER',		1,		'',			'spider.fxsxml',				'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_DRAKE_GREEN',			45,		'Hover',	'emerald_drake.fxsxml',			'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_DRAKE_BLUE',			50,		'Hover',	'storm_drake.fxsxml',			'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_DRAKE_RED',			55,		'Hover',	'red_drake.fxsxml',				'CLOTH',			'FLESH'			),
--barbs
('ART_DEF_UNIT_MEMBER_OGRE',				0.14,	'',			'ogre.fxsxml',					'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_STONESKIN_OGRE',		0.2,	'',			'stoneskin_ogre_tall.fxsxml',	'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_STONESKIN_OGRE_2',	0.2,	'',			'stoneskin_ogre_short.fxsxml',	'CLOTH',			'FLESH'			),

('ART_DEF_UNIT_MEMBER_NAGA_GREEN',			0.14,	'',			'Naga_Green.fxsxml',			'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_NAGA_BLUE',			0.14,	'',			'Naga_Blue.dds',				'CLOTH',			'FLESH'			),
--regulars
('ART_DEF_UNIT_MEMBER_MAN_CHARIOT',			0.13,	'',			'Chariot_Viking.fxsxml',		'CLOTH',			'WOODSM'		),
('ART_DEF_UNIT_MEMBER_ORC_SPEARMAN',		0.14,	'',			'orc_spearman.fxsxml',			'CLOTH',			'FLESH'			),

('ART_DEF_UNIT_MEMBER_GOBLIN_WARRIOR',		0.1,	'',			'Goblin_Warrior.fxsxml',		'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_GOBLIN_ARCHER',		0.1,	'',			'Goblin_Archer.fxsxml',			'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_GOBLIN_CROSSBOWMAN',	0.1,	'',			'Goblin_Crossbowman.fxsxml',	'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_GOBLIN_SCOUT',		0.1,	'',			'Goblin_Scout.fxsxml',			'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_GOBLIN_TRACKER',		0.1,	'',			'Goblin_Hunter.fxsxml',			'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_GOBLIN_WOLF_RIDER',	0.1,	'',			'Goblin_Wolfrider.fxsxml',		'CLOTH',			'FLESH'			),
--summoned/called
('ART_DEF_UNIT_MEMBER_TREE_ENT',			1,		'',			'tree.fxsxml',					'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_SKELETON_SWORDSMAN',	0.125,	'',			'skeleton_swordsman.fxsxml',	'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_ZOMBIE',				0.14,	'',			'zombie.fxsxml',				'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_GREAT_UNCLEAN_ONE',	6,		'',			'guo.fxsxml',					'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_HIVE_TYRANT',			6,		'',			'hive_tyrant.fxsxml',			'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_LICTOR',				6,		'',			'lictor.fxsxml',				'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_HORMAGAUNT',			6,		'',			'hormagaunt.fxsxml',			'CLOTH',			'FLESH'			),
--('ART_DEF_UNIT_MEMBER_CARNIFEX',			6,		'',			'carnifex.fxsxml',				'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_ANGEL_SPEARMAN',		0.15,	'',			'angel_spearman.fxsxml',		'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_ANGEL',				0.35,	'',			'angel_spearman.fxsxml',		'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_ARCHANGEL',			0.7,	'',			'angel_spearman.fxsxml',		'CLOTH',			'FLESH'			),
('ART_DEF_UNIT_MEMBER_STORM_GIANT',			0.7,	'',			'giant.fxsxml',					'CLOTH',			'FLESH'			);
										-- use 0.7 for archangel

INSERT INTO ArtDefine_UnitMemberCombats (UnitMemberType, DisableActions, EnableActions,																		ShortMoveRadius,	ShortMoveRate,		TargetHeight,	HasRefaceAfterCombat,	ReformBeforeCombat	) VALUES
--animals
('ART_DEF_UNIT_MEMBER_DIREWOLF',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
--('ART_DEF_UNIT_MEMBER_DIREWOLF_DARK',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_LION',				'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_GRIFFON',				'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_SCORPION_SAND',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_SCORPION_BLACK',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_SCORPION_WHITE',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
--beasts
('ART_DEF_UNIT_MEMBER_KRAKEN',				'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_GIANT_SPIDER',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_DRAKE_GREEN',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady',						NULL,				NULL,				NULL,			1,						NULL				),
('ART_DEF_UNIT_MEMBER_DRAKE_BLUE',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady',						NULL,				NULL,				NULL,			1,						NULL				),
('ART_DEF_UNIT_MEMBER_DRAKE_RED',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady',						NULL,				NULL,				NULL,			1,						NULL				),
--barbs
('ART_DEF_UNIT_MEMBER_OGRE',				'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_STONESKIN_OGRE',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_STONESKIN_OGRE_2',	'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),

('ART_DEF_UNIT_MEMBER_NAGA_GREEN',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_NAGA_BLUE',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
--regulars
('ART_DEF_UNIT_MEMBER_MAN_CHARIOT',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk',				24.0,				0.349999994039536,	12,				1,						2					),
('ART_DEF_UNIT_MEMBER_ORC_SPEARMAN',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_GOBLIN_WARRIOR',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_GOBLIN_ARCHER',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_GOBLIN_CROSSBOWMAN',	'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_GOBLIN_SCOUT',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						NULL				),
('ART_DEF_UNIT_MEMBER_GOBLIN_TRACKER',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_GOBLIN_WOLF_RIDER',	'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk',				24.0,				0.349999994039536,	12,				1,						2					),
--summoned/called
('ART_DEF_UNIT_MEMBER_TREE_ENT',			'',	'Idle Attack RunCharge Death Run Fortify CombatReady Walk AttackCharge',									12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_SKELETON_SWORDSMAN',	'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_ZOMBIE',				'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_GREAT_UNCLEAN_ONE',	'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_HIVE_TYRANT',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_LICTOR',				'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_HORMAGAUNT',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
--('ART_DEF_UNIT_MEMBER_CARNIFEX',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_ANGEL_SPEARMAN',		'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_ANGEL',				'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_ARCHANGEL',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					),
('ART_DEF_UNIT_MEMBER_STORM_GIANT',			'',	'Idle Attack RunCharge AttackCity Bombard Death BombardDefend Run Fortify CombatReady Walk AttackCharge',	12.0,				0.349999994039536,	8,				1,						1					);



UPDATE ArtDefine_UnitMemberCombats SET TurnRateMin = 0.5, TurnRateMax = 0.75, TurnFacingRateMin = 15, TurnFacingRateMax = 20, HasStationaryMelee = 1, OnlyTurnInMovementActions = 1, RushAttackFormation = 'DefaultCavalry' WHERE UnitMemberType IN
('ART_DEF_UNIT_MEMBER_MAN_CHARIOT', 'ART_DEF_UNIT_MEMBER_GOBLIN_WOLF_RIDER');

UPDATE ArtDefine_UnitMemberCombats SET HasShortRangedAttack = 1, HasLongRangedAttack = 1 WHERE UnitMemberType IN
('ART_DEF_UNIT_MEMBER_GOBLIN_ARCHER', 'ART_DEF_UNIT_MEMBER_GOBLIN_CROSSBOWMAN');

UPDATE ArtDefine_UnitMemberCombats SET HasShortRangedAttack = 1 WHERE UnitMemberType IN
('ART_DEF_UNIT_MEMBER_DRAKE_GREEN', 'ART_DEF_UNIT_MEMBER_DRAKE_BLUE', 'ART_DEF_UNIT_MEMBER_DRAKE_RED');

UPDATE ArtDefine_UnitMemberCombats SET RushAttackFormation = '' WHERE RushAttackFormation IS NULL;	--not sure if needed but this matches base units

INSERT INTO ArtDefine_UnitMemberCombatWeapons(UnitMemberType,	"Index",	SubIndex,	"ID",	WeaponTypeTag,		WeaponTypeSoundOverrideTag,	VisKillStrengthMin,	VisKillStrengthMax,	MissTargetSlopRadius,	HitEffect	) VALUES
--animals
--('ART_DEF_UNIT_MEMBER_WOLF',									0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
--('ART_DEF_UNIT_MEMBER_WOLF',									1,			0,			'',		'FLAMING_ARROW',	'',							10.0,				20.0,				10.0,					''			),
--('ART_DEF_UNIT_MEMBER_LION',									0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
--('ART_DEF_UNIT_MEMBER_LION',									1,			0,			'',		'FLAMING_ARROW',	'',							10.0,				20.0,				10.0,					''			),
--('ART_DEF_UNIT_MEMBER_GRIFFON',								0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
--('ART_DEF_UNIT_MEMBER_GRIFFON',								1,			0,			'',		'FLAMING_ARROW',	'',							10.0,				20.0,				10.0,					''			),
--('ART_DEF_UNIT_MEMBER_GIANT_SPIDER',							0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
--('ART_DEF_UNIT_MEMBER_GIANT_SPIDER',							1,			0,			'',		'FLAMING_ARROW',	'',							10.0,				20.0,				10.0,					''			),



('ART_DEF_UNIT_MEMBER_DIREWOLF',								0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
--('ART_DEF_UNIT_MEMBER_DIREWOLF_DARK',							0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_LION',									0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_GRIFFON',									0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_SCORPION_SAND',							0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_SCORPION_BLACK',							0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_SCORPION_WHITE',							0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
--beasts
('ART_DEF_UNIT_MEMBER_KRAKEN',									0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_GIANT_SPIDER',							0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),

('ART_DEF_UNIT_MEMBER_DRAKE_GREEN',								0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_DRAKE_BLUE',								0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_DRAKE_RED',								0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),


--barbs
('ART_DEF_UNIT_MEMBER_OGRE',									0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_OGRE',									1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_STONESKIN_OGRE',							0,			0,			'',		'METAL',			'SWORD',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_STONESKIN_OGRE',							1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_STONESKIN_OGRE_2',						0,			0,			'',		'METAL',			'SWORD',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_STONESKIN_OGRE_2',						1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),

('ART_DEF_UNIT_MEMBER_NAGA_GREEN',								0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_NAGA_BLUE',								0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),

--regulars
('ART_DEF_UNIT_MEMBER_MAN_CHARIOT',								0,			0,			'',		'METAL',			'SWORD',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_MAN_CHARIOT',								1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_ORC_SPEARMAN',							0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_ORC_SPEARMAN',							1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),

('ART_DEF_UNIT_MEMBER_GOBLIN_WARRIOR',							0,			0,			'',		'BLUNT',			'BLUNT',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_GOBLIN_WARRIOR',							1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),

('ART_DEF_UNIT_MEMBER_GOBLIN_ARCHER',							0,			0,			'',		'ARROW',			'ARROW',					NULL,				NULL,				10,						''			),
('ART_DEF_UNIT_MEMBER_GOBLIN_ARCHER',							1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),

('ART_DEF_UNIT_MEMBER_GOBLIN_CROSSBOWMAN',						0,			0,			'',		'ARROW',			'ARROW',					NULL,				NULL,				10,						''			),
('ART_DEF_UNIT_MEMBER_GOBLIN_CROSSBOWMAN',						1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),

('ART_DEF_UNIT_MEMBER_GOBLIN_SCOUT',							0,			0,			'',		'BLUNT',			'SPEAR',					NULL,				NULL,				NULL,					''			),

('ART_DEF_UNIT_MEMBER_GOBLIN_TRACKER',							0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_GOBLIN_TRACKER',							1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),

('ART_DEF_UNIT_MEMBER_GOBLIN_WOLF_RIDER',						0,			0,			'',		'METAL',			'SWORD',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_GOBLIN_WOLF_RIDER',						1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),


--summoned/called
('ART_DEF_UNIT_MEMBER_TREE_ENT',								0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_TREE_ENT',								1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_SKELETON_SWORDSMAN',						0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_SKELETON_SWORDSMAN',						1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_ZOMBIE',									0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_ZOMBIE',									1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_GREAT_UNCLEAN_ONE',						0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_GREAT_UNCLEAN_ONE',						1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_HIVE_TYRANT',								0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_HIVE_TYRANT',								1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_LICTOR',									0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_LICTOR',									1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_HORMAGAUNT',								0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_HORMAGAUNT',								1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
--('ART_DEF_UNIT_MEMBER_CARNIFEX',								0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
--('ART_DEF_UNIT_MEMBER_CARNIFEX',								1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_ANGEL_SPEARMAN',							0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_ANGEL_SPEARMAN',							1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_ANGEL',									0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_ANGEL',									1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_ARCHANGEL',								0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_ARCHANGEL',								1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			),
('ART_DEF_UNIT_MEMBER_STORM_GIANT',								0,			0,			'',		'METAL',			'SPEAR',					NULL,				NULL,				NULL,					''			),
('ART_DEF_UNIT_MEMBER_STORM_GIANT',								1,			0,			'',		'FLAMING_ARROW',	'',							10,					20,					10,						''			);



--GPs or other units dirived from existing members
CREATE TABLE TempList ('ExistingMember' TEXT);
INSERT INTO TempList (ExistingMember) VALUES
('ART_DEF_UNIT_MEMBER_GREATENGINEER_EARLY'			),
('ART_DEF_UNIT_MEMBER_GREATMERCHANT_EARLY_LEADER'	),
('ART_DEF_UNIT_MEMBER_GREATSCIENTIST_EARLY'			),
('ART_DEF_UNIT_MEMBER_GREATARTIST_EARLY_TAMBOURINE' ),
('ART_DEF_UNIT_MEMBER_SWORDSMAN'					),
('ART_DEF_UNIT_MEMBER_LONGSWORDSMAN'				),
('ART_DEF_UNIT_MEMBER_MISSIONARY_01'				),
('ART_DEF_UNIT_MEMBER_BARBARIAN_EURO_ALPHA'			),
('ART_DEF_UNIT_MEMBER_ROCKETARTILLERY'				);

--ART_DEF_UNIT_MEMBER_GREATARTIST_EARLY_TAMBOURINE	-F
--ART_DEF_UNIT_MEMBER_GREATARTIST_EARLY_FLUTE		-M
--ART_DEF_UNIT_MEMBER_GREATENGINEER_EARLY
--ART_DEF_UNIT_MEMBER_GREATMERCHANT_EARLY_LEADER
--ART_DEF_UNIT_MEMBER_GREATSCIENTIST_EARLY				--looks more like a wizard
--ART_DEF_UNIT_MEMBER_SWORDSMAN
--ART_DEF_UNIT_MEMBER_LONGSWORDSMAN


CREATE TABLE ArtDefine_UnitMemberInfos_Temp AS SELECT * FROM ArtDefine_UnitMemberInfos WHERE Type IN (SELECT ExistingMember FROM TempList);
UPDATE ArtDefine_UnitMemberInfos_Temp SET Type = 'ART_DEF_UNIT_MEMBER_EA_ENGINEER', Scale = Scale * 1.4 WHERE Type = 'ART_DEF_UNIT_MEMBER_GREATENGINEER_EARLY';
UPDATE ArtDefine_UnitMemberInfos_Temp SET Type = 'ART_DEF_UNIT_MEMBER_EA_MERCHANT', Scale = Scale * 1.4 WHERE Type = 'ART_DEF_UNIT_MEMBER_GREATMERCHANT_EARLY_LEADER';
UPDATE ArtDefine_UnitMemberInfos_Temp SET Type = 'ART_DEF_UNIT_MEMBER_EA_SAGE', Scale = Scale * 1.4 WHERE Type = 'ART_DEF_UNIT_MEMBER_GREATSCIENTIST_EARLY';
UPDATE ArtDefine_UnitMemberInfos_Temp SET Type = 'ART_DEF_UNIT_MEMBER_EA_ARTIST', Scale = Scale * 1.4 WHERE Type = 'ART_DEF_UNIT_MEMBER_GREATARTIST_EARLY_TAMBOURINE';
UPDATE ArtDefine_UnitMemberInfos_Temp SET Type = 'ART_DEF_UNIT_MEMBER_EA_WARRIOR', Scale = Scale * 1.4 WHERE Type = 'ART_DEF_UNIT_MEMBER_SWORDSMAN';
UPDATE ArtDefine_UnitMemberInfos_Temp SET Type = 'ART_DEF_UNIT_MEMBER_EA_PALADIN', Scale = Scale * 1.4 WHERE Type = 'ART_DEF_UNIT_MEMBER_LONGSWORDSMAN';
UPDATE ArtDefine_UnitMemberInfos_Temp SET Type = 'ART_DEF_UNIT_MEMBER_EA_DRUID', Scale = Scale * 1.4 WHERE Type = 'ART_DEF_UNIT_MEMBER_BARBARIAN_EURO_ALPHA';
UPDATE ArtDefine_UnitMemberInfos_Temp SET Type = 'ART_DEF_UNIT_MEMBER_EA_PRIEST', Scale = Scale * 1.4 WHERE Type = 'ART_DEF_UNIT_MEMBER_MISSIONARY_01';
UPDATE ArtDefine_UnitMemberInfos_Temp SET Type = 'ART_DEF_UNIT_MEMBER_EA_MAGIC_MISSILE',  Model = 'rocketartillery2.fxsxml', Scale = 0.06 WHERE Type = 'ART_DEF_UNIT_MEMBER_ROCKETARTILLERY';
INSERT INTO ArtDefine_UnitMemberInfos SELECT * FROM ArtDefine_UnitMemberInfos_Temp;


CREATE TABLE ArtDefine_UnitMemberCombats_Temp AS SELECT * FROM ArtDefine_UnitMemberCombats WHERE UnitMemberType IN (SELECT ExistingMember FROM TempList);
UPDATE ArtDefine_UnitMemberCombats_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_ENGINEER' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GREATENGINEER_EARLY';
UPDATE ArtDefine_UnitMemberCombats_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_MERCHANT' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GREATMERCHANT_EARLY_LEADER';
UPDATE ArtDefine_UnitMemberCombats_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_SAGE' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GREATSCIENTIST_EARLY';
UPDATE ArtDefine_UnitMemberCombats_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_ARTIST' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GREATARTIST_EARLY_TAMBOURINE';
UPDATE ArtDefine_UnitMemberCombats_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_WARRIOR' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_SWORDSMAN';
UPDATE ArtDefine_UnitMemberCombats_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_PALADIN' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_LONGSWORDSMAN';
UPDATE ArtDefine_UnitMemberCombats_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_DRUID', EnableActions = 'Idle Bombard Death BombardDefend Fortify CombatReady Walk' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_BARBARIAN_EURO_ALPHA';
UPDATE ArtDefine_UnitMemberCombats_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_PRIEST' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_MISSIONARY_01';
UPDATE ArtDefine_UnitMemberCombats_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_MAGIC_MISSILE' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_ROCKETARTILLERY';
INSERT INTO ArtDefine_UnitMemberCombats SELECT * FROM ArtDefine_UnitMemberCombats_Temp;


CREATE TABLE ArtDefine_UnitMemberCombatWeapons_Temp AS SELECT * FROM ArtDefine_UnitMemberCombatWeapons WHERE UnitMemberType IN (SELECT ExistingMember FROM TempList);
UPDATE ArtDefine_UnitMemberCombatWeapons_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_ENGINEER' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GREATENGINEER_EARLY';
UPDATE ArtDefine_UnitMemberCombatWeapons_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_MERCHANT' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GREATMERCHANT_EARLY_LEADER';
UPDATE ArtDefine_UnitMemberCombatWeapons_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_SAGE' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GREATSCIENTIST_EARLY';
UPDATE ArtDefine_UnitMemberCombatWeapons_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_ARTIST' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_GREATARTIST_EARLY_TAMBOURINE';
UPDATE ArtDefine_UnitMemberCombatWeapons_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_WARRIOR' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_SWORDSMAN';
UPDATE ArtDefine_UnitMemberCombatWeapons_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_PALADIN' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_LONGSWORDSMAN';
UPDATE ArtDefine_UnitMemberCombatWeapons_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_DRUID' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_BARBARIAN_EURO_ALPHA';
UPDATE ArtDefine_UnitMemberCombatWeapons_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_PRIEST' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_MISSIONARY_01';
UPDATE ArtDefine_UnitMemberCombatWeapons_Temp SET UnitMemberType = 'ART_DEF_UNIT_MEMBER_EA_MAGIC_MISSILE' WHERE UnitMemberType = 'ART_DEF_UNIT_MEMBER_ROCKETARTILLERY';
INSERT INTO ArtDefine_UnitMemberCombatWeapons SELECT * FROM ArtDefine_UnitMemberCombatWeapons_Temp;

DROP TABLE TempList;
DROP TABLE ArtDefine_UnitMemberInfos_Temp;
DROP TABLE ArtDefine_UnitMemberCombats_Temp;
DROP TABLE ArtDefine_UnitMemberCombatWeapons_Temp;



INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaArtDefines.sql';