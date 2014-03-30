
-- Glyphs, Runes, Wards



CREATE TABLE EaPlotEffects ('ID' INTEGER PRIMARY KEY AUTOINCREMENT,
							'Type' TEXT NOT NULL UNIQUE,
							'Description' TEXT DEFAULT NULL,
							'Help' TEXT DEFAULT NULL,
							'TextColor' TEXT DEFAULT NULL,
							'HighlightColor' TEXT DEFAULT NULL,
							'CanOverwrite' BOOLEAN DEFAULT NULL	);		--can overwrite without a dispel (not yet implemented)

INSERT INTO EaPlotEffects (Type,		TextColor,				HighlightColor	) VALUES
('EA_PLOTEFFECT_PROTECTIVE_WARD',		'[COLOR_BLUE]',			'BLUE'			),
('EA_PLOTEFFECT_SEEING_EYE_GLYPH',		'[COLOR_YELLOW]',		'YELLOW'		),
('EA_PLOTEFFECT_EXPLOSIVE_RUNE',		'[COLOR_RED]',			'RED'			),
('EA_PLOTEFFECT_DEATH_RUNE',			'[COLOR_LIGHT_GREY]',	'BLACK'			);

UPDATE EaPlotEffects SET CanOverwrite = 1 WHERE Type = 'EA_PLOTEFFECT_SEEING_EYE_GLYPH';




--Build out the table for dependent strings
UPDATE EaPlotEffects SET Description = 'TXT_KEY_' || Type, Help = 'TXT_KEY_' || Type || '_HELP';



INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaPlotEffects.sql';