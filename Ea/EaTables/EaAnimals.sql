
-- Animal spawning preferences

CREATE TABLE EaAnimal_Prefs ('UnitType' TEXT, 'Preference' TEXT, 'Weight', INTEGER);	--Weight can be negative if we want an aversion

INSERT INTO EaAnimal_Prefs (UnitType, Preference, Weight) VALUES
('UNIT_WOLVES',				'ColdTerrain',		10	),
('UNIT_WOLVES',				'Forest',			10	),
('UNIT_LIONS',				'OpenGrassPlains',	5	),
('UNIT_LIONS',				'ColdTerrain',		-10	),
('UNIT_GRIFFONS',			'Mountain',			10	),

('UNIT_SCORPIONS_SAND',		'Desert',			15	),
('UNIT_SCORPIONS_SAND',		'ColdTerrain',		-10	),
('UNIT_SCORPIONS_BLACK',	'Desert',			14	),
('UNIT_SCORPIONS_BLACK',	'Forest',			1	),
('UNIT_SCORPIONS_BLACK',	'Jungle',			1	),
('UNIT_SCORPIONS_BLACK',	'ColdTerrain',		-10	),
('UNIT_SCORPIONS_WHITE',	'Desert',			-10	),
('UNIT_SCORPIONS_WHITE',	'ColdTerrain',		10	),

('UNIT_GIANT_SPIDER',		'Forest',			8	),
('UNIT_GIANT_SPIDER',		'Jungle',			15	),
('UNIT_GIANT_SPIDER',		'ColdTerrain',		-10	);





INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaAnimals.sql';
