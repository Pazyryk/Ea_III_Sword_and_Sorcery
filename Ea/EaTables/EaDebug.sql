
CREATE TABLE Ea_ExpectedTableFiles ('FileName' TEXT NOT NULL);

INSERT INTO Ea_ExpectedTableFiles (FileName) VALUES
	('EaImages.sql'),				--from Ea Media Pack
	('EaSounds.sql'),				--from Ea Media Pack
	('EaActions.sql'),
	('EaAI.sql'),
	('EaAnimals.sql'),
	('EaBarbarians.sql'),
	('EaCivilizations.sql'),
	('EaDebug.sql'),
	('EaModifiers.sql'),
	('EaPeople.sql'),
	('EaPlotEffects.sql'),
	('EaRaces.sql'),
	('EaArtifacts.sql'),
	('EaEpics.sql'),
	('EaWonders.sql'),
	('AI.sql'),
	('Buildings.sql'),
	('Civilizations.sql'),
	('Traits.sql'),
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
	('EaText__UI.xml'),
	('EaText_Buildings.xml'),
	('EaText_Civilizations.xml'),
	('EaText_EaActions.xml'),
	('EaText_EaBarbarians.xml'),
	('EaText_EaCivilizations.xml'),
	('EaText_EaCreations.xml'),
	('EaText_EaPeople.xml'),
	('EaText_EaPlotEffects.xml'),
	('EaText_EaRaces.xml'),
	('EaText_EaSpells.xml'),
	('EaText_GameInfo.xml'),
	('EaText_MinorCivs.xml'),
	('EaText_Policies.xml'),
	('EaText_Processes.xml'),
	('EaText_Religions.xml'),
	('EaText_Technologies.xml'),
	('EaText_Terrain.xml'),
	('EaText_Help.xml'),
	('EaText_UnitBuilds.xml'),
	('EaText_UnitPromotions.xml'),
	('EaText_Units.xml'),

	('EaArtDefines.sql');

CREATE TABLE Ea_DBErrors ('ErrorText' TEXT NOT NULL, 'ItemText' TEXT DEFAULT NULL);

INSERT INTO Ea_DBErrors (ErrorText, ItemText)
SELECT 'Unit No AI', Type FROM Units WHERE Type NOT IN (SELECT UnitType FROM Unit_AITypes) AND Special IS NULL UNION ALL
SELECT 'Unit No Flavor', Type FROM Units WHERE Type NOT IN (SELECT UnitType FROM Unit_Flavors) AND Cost != -1 AND EaNoTrain IS NULL AND Special IS NULL UNION ALL
SELECT 'Building No Flavor', Type FROM Buildings WHERE Type NOT IN (SELECT BuildingType FROM Building_Flavors) AND Cost != -1;

INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaDebug.sql';