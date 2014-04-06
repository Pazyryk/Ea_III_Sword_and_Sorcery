-- Contains Traits and subtables
-- Must load after Civilizations.sql

DELETE FROM Traits WHERE Type != 'TRAIT_LONG_COUNT';	--need this in the table or Dll gives effect to all
UPDATE Traits SET PrereqTech = NULL;

INSERT INTO Traits (Type, Description, ShortDescription)
SELECT DISTINCT TraitType, 'TXT_KEY_EA_NOTSHOWN', 'TXT_KEY_EA_NOTSHOWN' FROM Civilization_Traits UNION ALL
SELECT DISTINCT TraitType, 'TXT_KEY_EA_NOTSHOWN', 'TXT_KEY_EA_NOTSHOWN' FROM Leader_Traits;

--fixinator
CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM Traits ORDER BY ID;
UPDATE Traits SET ID =	( SELECT IDRemapper.id-1 FROM IDRemapper WHERE Traits.Type = IDRemapper.Type);
DROP TABLE IDRemapper;

--We now have a trait for each Race and one for each EaCiv, plus Generic; modify these as needed here
UPDATE Traits SET StaysAliveZeroCities = 1 WHERE Type IN ('TRAIT_THE_FAY', 'TRAIT_ANIMALS');

UPDATE Traits SET FreeBuilding = 'BUILDING_IKKOS' WHERE Type = 'TRAIT_IKKOS';
UPDATE Traits SET FreeBuilding = 'BUILDING_AB' WHERE Type = 'TRAIT_AB';
UPDATE Traits SET FreeBuilding = 'BUILDING_FOMHOIRE' WHERE Type = 'TRAIT_FOMHOIRE';
UPDATE Traits SET FreeBuilding = 'BUILDING_NEITH' WHERE Type = 'TRAIT_NEITH';
UPDATE Traits SET FreeBuilding = 'BUILDING_BREWERY' WHERE Type = 'TRAIT_NINKASI';
UPDATE Traits SET FreeBuilding = 'BUILDING_MONASTERY' WHERE Type = 'TRAIT_ANAPHORA';

UPDATE Traits SET FreeBuilding = 'BUILDING_MAMONAS' WHERE Type = 'TRAIT_MAMONAS';
UPDATE Traits SET FreeBuilding = 'BUILDING_MAYD' WHERE Type = 'TRAIT_MAYD';

UPDATE Traits SET FreeBuilding = 'BUILDING_MARKETPLACE' WHERE Type = 'TRAIT_TYRE';
UPDATE Traits SET FreeBuilding = 'BUILDING_FORGE' WHERE Type = 'TRAIT_GERZAH';
UPDATE Traits SET FreeBuilding = 'BUILDING_HARBOR' WHERE Type = 'TRAIT_HY_BREASIL';
UPDATE Traits SET FreeBuilding = 'BUILDING_SHRINE' WHERE Type = 'TRAIT_NETZACH';

UPDATE Traits SET FaithFromKills = 100 WHERE Type IN ('TRAIT_STYGIA', 'TRAIT_MORIQUENDI');


--






--


--subtables

DELETE FROM Trait_FreePromotionUnitCombats;
INSERT INTO Trait_FreePromotionUnitCombats (TraitType, UnitCombatType,	PromotionType) VALUES
('TRAIT_CRECY',			'UNITCOMBAT_ARCHER',		'PROMOTION_STRONG_ARCHER'	),
('TRAIT_CRECY',			'UNITCOMBAT_GUN',			'PROMOTION_STRONG_ARCHER'	),
('TRAIT_SISUKAS',		'UNITCOMBAT_MELEE',			'PROMOTION_STRONG_INFANTRY'	),
('TRAIT_PHRYGES',		'UNITCOMBAT_MOUNTED',		'PROMOTION_STRONG_CAVALRY'	),
('TRAIT_PHRYGES',		'UNITCOMBAT_GUN',			'PROMOTION_STRONG_CAVALRY'	);


DELETE FROM Trait_ImprovementYieldChanges;
INSERT INTO Trait_ImprovementYieldChanges (TraitType, ImprovementType, YieldType, Yield) VALUES
('TRAIT_FIR_BOLG',		'IMPROVEMENT_PASTURE',			'YIELD_PRODUCTION',	1	),
('TRAIT_FIR_BOLG',		'IMPROVEMENT_PASTURE',			'YIELD_GOLD',		1	),
('TRAIT_CRUITHNI',		'IMPROVEMENT_CAMP',				'YIELD_FOOD',		1	),
('TRAIT_CRUITHNI',		'IMPROVEMENT_CAMP',				'YIELD_PRODUCTION',	1	),
('TRAIT_ELEUTHERIOS',	'IMPROVEMENT_VINEYARD',			'YIELD_GOLD',		2	),
('TRAIT_ELEUTHERIOS',	'IMPROVEMENT_VINEYARD',			'YIELD_CULTURE',	2	),
('TRAIT_DAGGOO',		'IMPROVEMENT_WHALING_BOATS',	'YIELD_FOOD',		1	),
('TRAIT_DAGGOO',		'IMPROVEMENT_WHALING_BOATS',	'YIELD_PRODUCTION',	1	),
('TRAIT_DAGGOO',		'IMPROVEMENT_WHALING_BOATS',	'YIELD_CULTURE',	1	),
('TRAIT_ALDEBAR',		'IMPROVEMENT_E_PLANTATION',		'YIELD_CULTURE',	2	);


DELETE FROM Trait_MaintenanceModifierUnitCombats;
INSERT INTO Trait_MaintenanceModifierUnitCombats (TraitType,	UnitCombatType, MaintenanceModifier) VALUES
('TRAIT_PHRYGES',		'UNITCOMBAT_MOUNTED',		-33	),
('TRAIT_PHRYGES',		'UNITCOMBAT_GUN',			-33	);


DELETE FROM Trait_NoTrain;
INSERT INTO Trait_NoTrain (TraitType, UnitClassType) VALUES
('TRAIT_GENERIC',		'UNITCLASS_SETTLERS_MAN'),
('TRAIT_GENERIC',		'UNITCLASS_SETTLERS_SIDHE'),
('TRAIT_GENERIC',		'UNITCLASS_SETTLERS_ORC');







--unused:
DELETE FROM Trait_ExtraYieldThresholds;

DELETE FROM Trait_FreePromotions;	--not in dll
DELETE FROM Trait_FreeResourceFirstXCities;

DELETE FROM Trait_MovesChangeUnitCombats;

DELETE FROM Trait_ResourceQuantityModifiers;
DELETE FROM Trait_SpecialistYieldChanges;
DELETE FROM Trait_Terrains;
DELETE FROM Trait_UnimprovedFeatureYieldChanges;
DELETE FROM Trait_YieldChanges;
DELETE FROM Trait_YieldChangesIncomingTradeRoute;
DELETE FROM Trait_YieldChangesNaturalWonder;
DELETE FROM Trait_YieldChangesPerTradePartner;
DELETE FROM Trait_YieldChangesStrategicResources;
DELETE FROM Trait_YieldModifiers;


INSERT INTO EaDebugTableCheck(FileName) SELECT 'Traits.sql';