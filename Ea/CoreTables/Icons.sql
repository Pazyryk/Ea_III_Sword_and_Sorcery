
--------------------------------------------------------------
-- Atlases
--------------------------------------------------------------

INSERT INTO IconTextureAtlases(Atlas,	IconSize,	Filename,					IconsPerRow,	IconsPerColumn) VALUES
('EA_ACTION_ATLAS',						45,			'EaActionAtlas45.dds',		8,				8			),
('EA_ACTION_ATLAS',						64,			'EaActionAtlas64.dds',		8,				8			),
('EA_FLAG_ATLAS',						32,			'EaFlagAtlas32.dds',		8,				8			),
('EA_RELIGION_ATLAS',					80,			'EaReligionAtlas80.dds',	8,				4			),
('EA_RELIGION_ATLAS',					48,			'EaReligionAtlas48.dds',	8,				4			),
('EA_RELIGION_ATLAS',					45,			'EaReligionAtlas45.dds',	8,				4			),
('EA_RELIGION_ATLAS',					32,			'EaReligionAtlas32.dds',	8,				4			),
('EA_RELIGION_STAR_ATLAS',				80,			'EaReligionStarAtlas32.dds',8,				4			),
('EA_RELIGION_STAR_ATLAS',				48,			'EaReligionStarAtlas32.dds',8,				4			),
('EA_RELIGION_STAR_ATLAS',				32,			'EaReligionStarAtlas32.dds',8,				4			),
('EA_SPELLS_ATLAS',						64,			'EaSpellsAtlas64.dds',		8,				4			),
('EA_SPELLS_ATLAS',						48,			'EaSpellsAtlas48.dds',		8,				4			),
('EA_SPELLS_ATLAS',						45,			'EaSpellsAtlas45.dds',		8,				4			);




--------------------------------------------------------------
-- Font Icons
--------------------------------------------------------------

INSERT INTO IconFontTextures(IconFontTexture, IconFontTextureFile) VALUES
('EA_FONT_ICONS',	'EaFontIcons'	);

INSERT INTO  IconFontMapping(IconName,	IconMapping,	IconFontTexture) VALUES
('ICON_RELIGION_AZZANDARAYASNA',		1,				'EA_FONT_ICONS'	),
('ICON_RELIGION_ANRA',					2,				'EA_FONT_ICONS'	),
('ICON_RELIGION_THE_WEAVE',				3,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_LEAVES',					4,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_BAKKHEIA',				5,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_EPONA',					6,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_ABZU',					7,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_AEGIR',					8,				'EA_FONT_ICONS'	),
('ICON_RELIGION_AZZANDARAYASNA_HC',		9,				'EA_FONT_ICONS'	),
('ICON_RELIGION_ANRA_HC',				10,				'EA_FONT_ICONS'	),
('ICON_RELIGION_THE_WEAVE_HC',			11,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_LEAVES_HC',				12,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_BAKKHEIA_HC',			13,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_EPONA_HC',				14,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_ABZU_HC',				15,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_AEGIR_HC',				16,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_PLOUTON',				17,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_CAHRA',					18,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_PLOUTON_HC',				25,				'EA_FONT_ICONS'	),
('ICON_CULT_OF_CAHRA_HC',				26,				'EA_FONT_ICONS'	);


INSERT INTO EaDebugTableCheck(FileName) SELECT 'Icons.sql';