
-- Animal spawning preferences

CREATE TABLE EaAnimal_Prefs ('UnitType' TEXT, 'Preference' TEXT, 'Weight', INTEGER);	--Weight can be negative if we want an aversion

INSERT INTO EaAnimal_Prefs (UnitType, Preference, Weight) VALUES
('UNIT_WOLVES',			'ColdTerrain',		10	),
('UNIT_WOLVES',			'Forest',			10	),
('UNIT_LIONS',			'OpenGrassPlains',	5	),
('UNIT_LIONS',			'ColdTerrain',		-10	),
('UNIT_GIANT_SPIDER',	'Forest',			8	),
('UNIT_GIANT_SPIDER',	'Jungle',			15	),
('UNIT_GIANT_SPIDER',	'ColdTerrain',		-10	);





INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaAnimals.sql';
