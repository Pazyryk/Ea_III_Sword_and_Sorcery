
CREATE TABLE Ea_ExpectedTableFiles ('FileName' TEXT NOT NULL);

INSERT INTO Ea_ExpectedTableFiles (FileName) VALUES
	('EaImages.sql'),				--from Ea Media Pack
	('EaActions.sql'),
	('EaAI.sql'),
	('EaAnimals.sql'),
	('EaBarbarians.sql'),
	('EaCivilizations.sql'),
	('EaCreations.sql'),
	('EaDebug.sql'),
	('EaModifiers.sql'),
	('EaPeople.sql'),
	('EaPlotEffects.sql'),
	('EaRaces.sql'),
	('AI.sql'),
	('Buildings.sql'),
	('Civilizations.sql'),
	('GameInfo.sql'),
	('GlobalDefines.sql'),
	('Icons.sql'),
	('MinorCivs.sql'),
	('Policies.sql'),
	('Processes.sql'),
	('Religions.sql'),
	('Technologies.sql'),
	('Terrain.sql'),
	('UnitBuilds.sql'),
	('UnitPromotions.sql'),
	('Units.sql'),
	('EaText.sql'),
	('EaText_Actions.xml'),
	('EaText_Civs.xml'),
	('EaText_Help.xml'),
	('EaText_Misc.xml'),
	('EaText_Pedia.xml'),
	('EaText_People.xml'),
	('EaText_Units.xml'),
	('EaArtDefines.sql');

CREATE TABLE Ea_DBErrors ('ErrorText' TEXT NOT NULL, 'ItemText' TEXT DEFAULT NULL);

INSERT INTO Ea_DBErrors (ErrorText, ItemText)
SELECT 'Unit No AI', Type FROM Units WHERE Type NOT IN (SELECT UnitType FROM Unit_AITypes) AND Special IS NULL UNION ALL
SELECT 'Unit No Flavor', Type FROM Units WHERE Type NOT IN (SELECT UnitType FROM Unit_Flavors) AND Cost != -1 AND EaNoTrain IS NULL AND Special IS NULL UNION ALL
SELECT 'Building No Flavor', Type FROM Buildings WHERE Type NOT IN (SELECT BuildingType FROM Building_Flavors) AND Cost != -1;

INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaDebug.sql';