
-- Glyphs, Runes, Wards



CREATE TABLE EaPlotEffects ('ID' INTEGER PRIMARY KEY AUTOINCREMENT,
							'Type' TEXT NOT NULL UNIQUE,
							'Description' TEXT DEFAULT NULL,
							'Help' TEXT DEFAULT NULL	);

INSERT INTO EaPlotEffects (Type) VALUES
('EA_PLOTEFFECT_GLYPH_OF_PROTECTION'),
('EA_PLOTEFFECT_EXPLOSIVE_RUNES'),
('EA_PLOTEFFECT_DEATH_RUNES');





--Build out the table for dependent strings
UPDATE EaPlotEffects SET Description = 'TXT_KEY_' || Type, Help = 'TXT_KEY_' || Type || '_HELP';



INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaPlotEffects.sql';