
--------------------------------------------------------------
-- Atlases
--------------------------------------------------------------

INSERT INTO IconTextureAtlases(Atlas,	IconSize,	Filename,					IconsPerRow,	IconsPerColumn)
SELECT 'EA_ACTION_ATLAS',				45,			'EaActionAtlas45.dds',		8,				8			UNION ALL
SELECT 'EA_ACTION_ATLAS',				64,			'EaActionAtlas64.dds',		8,				8			UNION ALL
SELECT 'EA_FLAG_ATLAS',					32,			'EaFlagAtlas32.dds',		8,				8			UNION ALL
SELECT 'EA_RELIGION_ATLAS',				80,			'EaReligionAtlas80.dds',	8,				4			UNION ALL
SELECT 'EA_RELIGION_ATLAS',				48,			'EaReligionAtlas48.dds',	8,				4			UNION ALL
SELECT 'EA_RELIGION_ATLAS',				32,			'EaReligionAtlas32.dds',	8,				4			UNION ALL
SELECT 'EA_RELIGION_STAR_ATLAS',		32,			'EaReligionStarAtlas32.dds',8,				4			;




--------------------------------------------------------------
-- Font Icons
--------------------------------------------------------------

INSERT INTO IconFontTextures(IconFontTexture, IconFontTextureFile)
SELECT 'EA_FONT_ICONS',	'EaFontIcons'	;

INSERT INTO  IconFontMapping(IconName, IconMapping, IconFontTexture)
SELECT 'ICON_RELIGION_AZZANDARAYASNA',	1,			'EA_FONT_ICONS'	UNION ALL
SELECT 'ICON_RELIGION_ANRA',			2,			'EA_FONT_ICONS'	UNION ALL
SELECT 'ICON_RELIGION_THE_WEAVE',		3,			'EA_FONT_ICONS'	UNION ALL
SELECT 'ICON_CULT_OF_LEAVES',			4,			'EA_FONT_ICONS'	UNION ALL
SELECT 'ICON_CULT_OF_BAKKHEIA',			5,			'EA_FONT_ICONS'	UNION ALL
SELECT 'ICON_CULT_OF_EPONA',			6,			'EA_FONT_ICONS'	UNION ALL
SELECT 'ICON_CULT_OF_PURE_WATERS',		7,			'EA_FONT_ICONS'	UNION ALL
SELECT 'ICON_CULT_OF_AEGIR',			8,			'EA_FONT_ICONS'	;


INSERT INTO EaDebugTableCheck(FileName) SELECT 'Icons.sql';