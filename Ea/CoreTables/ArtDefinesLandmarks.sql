
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

INSERT INTO ArtDefine_Landmarks (Era, State, Scale,	ImprovementType,					LayoutHandler,	ResourceType,								Model,								TerrainContour) VALUES
('Any',		'Any',				0.9399999976158142,	'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_POPPY',					'Resource_Poppy.fxsxml',			1	),
('Ancient',	'UnderConstruction',0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_POPPY',					'HB_Plantation_MID_Poppy.fxsxml',	1	),
('Ancient',	'Constructed',		0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_POPPY',					'Plantation_MID_Poppy.fxsxml',		1	),
('Ancient',	'Pillaged',			0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_POPPY',					'PL_Plantation_MID_Poppy.fxsxml',	1	),
('Any',		'Any',				0.9800000190734863,	'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TOBACCO',					'Resource_Tobacco.fxsxml',			1	),
('Ancient',	'UnderConstruction',0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TOBACCO',					'HB_Plantation_MID_Tobacco.fxsxml',	1	),
('Ancient',	'Constructed',		0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TOBACCO',					'Plantation_MID_Tobacco.fxsxml',	1	),
('Ancient',	'Pillaged',			0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TOBACCO',					'PL_Plantation_MID_Tobacco.fxsxml',	1	),
('Any',		'Any',				0.9399999976158142,	'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_ALOEVERA',				'Resource_Aloevera.fxsxml',			1	),
('Ancient',	'UnderConstruction',0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALOEVERA',				'HB_Plantation_MID_Aloevera.fxsxml',1	),
('Ancient',	'Constructed',		0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALOEVERA',				'Plantation_MID_Aloevera.fxsxml',	1	),
('Ancient',	'Pillaged',			0.9599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_ALOEVERA',				'PL_Plantation_MID_Aloevera.fxsxml',1	),
('Any',		'Any',				1,					'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_MANGANESE',				'Manganese.fxsxml',					1	),
('Ancient',	'UnderConstruction',1,					'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_MANGANESE',				'HB_MED_Mine_Manganese.fxsxml',		1	),
('Ancient',	'Constructed',		1,					'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_MANGANESE',				'MED_Mine_Manganese.fxsxml',		1	),
('Ancient',	'Pillaged',			1,					'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_MANGANESE',				'PL_MED_Mine_Manganese.fxsxml',		1	),
('Any',		'Any',				1,					'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_BERRIES',					'Resource_Berries.fxsxml',			1	),
('Ancient',	'UnderConstruction',1,					'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_BERRIES',					'HB_Plantation_MID_Berries.fxsxml',	1	),
('Ancient',	'Constructed',		1,					'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_BERRIES',					'Plantation_MID_Berries.fxsxml',	1	),
('Ancient',	'Pillaged',			1,					'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_BERRIES',					'PL_Plantation_MID_Berries.fxsxml',	1	),
('Any',		'Any',				0.7399999976158142,	'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TEA',						'Resource_Tea.fxsxml',				1	),
('Ancient',	'UnderConstruction',0.7599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TEA',						'HB_Plantation_MID_Tea.fxsxml',		1	),
('Ancient',	'Constructed',		0.7599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TEA',						'Plantation_MID_Tea.fxsxml',		1	),
('Ancient',	'Pillaged',			0.7599999785423279,	'ART_DEF_IMPROVEMENT_PLANTATION',	'SNAPSHOT',		'ART_DEF_RESOURCE_TEA',						'APL_Plantation_MID_Tea.fxsxml',	1	),
('Any',		'Any',				1.0,				'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_LUBORIC',					'luboric.fxsxml',					1	),
('Ancient',	'UnderConstruction',1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_LUBORIC',					'hb_med_luboric_mine.fxsxml',		1	),
('Ancient',	'Constructed',		1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_LUBORIC',					'med_mine_luboric.fxsxml',			1	),
--('Ancient',	'Pillaged',			1.0,			'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_LUBORIC',					'pl_med_mine_luboric.fxsxml',		1	),
--('Any',		'Any',				1.0,			'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TIN',						'tin.fxsxml',						1	),
--('Ancient',	'UnderConstruction',1.0,			'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TIN',						'hb_med_tin_mine.fxsxml',			1	),
--('Ancient',	'Constructed',		1.0,			'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TIN',						'med_mine_tin.fxsxml',				1	),
--('Ancient',	'Pillaged',			1.0,			'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_TIN',						'pl_med_mine_tin.fxsxml',			1	),

('Any',		'Any',				1.0,				'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER',				'copper.fxsxml',					1	),
('Ancient',	'UnderConstruction',1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER',				'hb_med_mine_copper.fxsxml',		1	),
('Ancient',	'Constructed',		1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER',				'med_mine_copper.fxsxml',			1	),
('Ancient',	'Pillaged',			1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER',				'pl_med_mine_copper.fxsxml',		1	),

('Any',		'Any',				1.0,				'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_HEAVY',			'copper_heavy.fxsxml',				1	),
('Ancient',	'UnderConstruction',1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_HEAVY',			'hb_med_mine_copper_heavy.fxsxml',	1	),
('Ancient',	'Constructed',		1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_HEAVY',			'med_mine_copper_heavy.fxsxml',		1	),
('Ancient',	'Pillaged',			1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_HEAVY',			'pl_med_mine_copper_heavy.fxsxml',	1	),

('Any',		'Any',				1.0,				'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_MARSH',			'copper_marsh.fxsxml',				1	),
('Ancient',	'UnderConstruction',1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_MARSH',			'hb_med_mine_copper.fxsxml',		1	),
('Ancient',	'Constructed',		1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_MARSH',			'med_mine_copper.fxsxml',			1	),
('Ancient',	'Pillaged',			1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_MARSH',			'pl_med_mine_copper.fxsxml',		1	),

('Any',		'Any',				1.0,				'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_HEAVY_MARSH',	'copper_heavy_marsh.fxsxml',		1	),
('Ancient',	'UnderConstruction',1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_HEAVY_MARSH',	'hb_med_mine_copper_heavy.fxsxml',	1	),
('Ancient',	'Constructed',		1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_HEAVY_MARSH',	'med_mine_copper_heavy.fxsxml',		1	),
('Ancient',	'Pillaged',			1.0,				'ART_DEF_IMPROVEMENT_MINE',			'SNAPSHOT',		'ART_DEF_RESOURCE_NEWCOPPER_HEAVY_MARSH',	'pl_med_mine_copper_heavy.fxsxml',	1	),



--alt farm graphic since base farm is hardcoded to "IMPROVEMENT_FARM"
('Any', 'UnderConstruction',	1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',					'HBfarmfix01.fxsxml',				1	),
('Any', 'Constructed',			1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',					'farmwheat01.fxsxml',				1	),
('Any', 'Pillaged',				1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',					'PLfarmfix01.fxsxml',				1	),
('Any', 'UnderConstruction',	1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',					'HBfarmfix02.fxsxml',				1	),
('Any', 'Constructed',			1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',					'farmwheat02.fxsxml',				1	),
('Any', 'Pillaged',				1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',					'PLfarmfix02.fxsxml',				1	),
('Any', 'UnderConstruction',	1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',					'HBfarmfix03.fxsxml',				1	),
('Any', 'Constructed',			1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',					'farmwheat03.fxsxml',				1	),
('Any', 'Pillaged',				1.35,  				'ART_DEF_IMPROVEMENT_FARM_FIX',		'RANDOM',		'ART_DEF_RESOURCE_WHEAT',					'PLfarmfix03.fxsxml',				1	),
--fishing on lakes
('Any',	'Any',					0.07000000029802322,'ART_DEF_IMPROVEMENT_FISHING_BOATS','ANIMATED',		'ART_DEF_RESOURCE_NONE',					'Fish.fxsxml',						1	),
--Wonder improvements
('Any', 'UnderConstruction',	1,  				'ART_DEF_IMPROVEMENT_PYRAMID',		'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',					'PyramidsTI_hb.fxsxml',				1	),	--hb_pyramidsTI.fxsxml
('Any', 'Constructed',			1,  				'ART_DEF_IMPROVEMENT_PYRAMID',		'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',					'PyramidsTI_B.fxsxml',				1	),	--pyramidsTI.fxsxml
('Any', 'Pillaged',				1,  				'ART_DEF_IMPROVEMENT_PYRAMID',		'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',					'PyramidsTI_pl.fxsxml',				1	),	--pl_pyramidsTI.fxsxml
('Any', 'UnderConstruction',	1,  				'ART_DEF_IMPROVEMENT_STONEHENGE',	'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',					'stonehengeTI_hb.fxsxml',			1	),	--hb_stonehengeTI.fxsxml
('Any', 'Constructed',			1,  				'ART_DEF_IMPROVEMENT_STONEHENGE',	'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',					'stonehengeTI_B.fxsxml',			1	),	--stonehengeTI.fxsxml
('Any', 'Pillaged',				1,  				'ART_DEF_IMPROVEMENT_STONEHENGE',	'SNAPSHOT',		'ART_DEF_RESOURCE_NONE',					'stonehengeTI_pl.fxsxml',			1	),	--pl_stonehengeTI.fxsxml

--Blight
('Any',	'Any',					1.45,				'ART_DEF_IMPROVEMENT_BLIGHT',		'SNAPSHOT',		'ART_DEF_RESOURCE_ALL',						'blight.fxsxml',					0	),
('Any',	'Any',					1.45,				'ART_DEF_IMPROVEMENT_NONE',			'SNAPSHOT',		'ART_DEF_RESOURCE_BLIGHT',					'blight.fxsxml',					0	),
('Any',	'Any',					1.45,				'ART_DEF_IMPROVEMENT_HALICARNASSUS','SNAPSHOT',		'ART_DEF_RESOURCE_BLIGHT',					'blight.fxsxml',					0	);	--Arcane Tower


INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaArtDefinesLandmarks.sql';