

--City growth equation

--food needed = 15 + 8 (n - 1) + (n - 1)^1.5 rounded down to the next integer. (n=# of cities)
--food needed = t + m (n - 1) + (n - 1)^x
-- t = BASE_CITY_GROWTH_THRESHOLD
-- m = CITY_GROWTH_MULTIPLIER
-- x = CITY_GROWTH_EXPONENT
-- n = #cities

-----------------------------------------------------------------------------------------
-- Defines
-----------------------------------------------------------------------------------------
--city growth overhaul
UPDATE Defines SET Value = 3 WHERE Name = 'FOOD_CONSUMPTION_PER_POPULATION';
UPDATE Defines SET Value = 149 WHERE Name = 'BASE_CITY_GROWTH_THRESHOLD';
UPDATE Defines SET Value = 0 WHERE Name = 'CITY_GROWTH_MULTIPLIER';
UPDATE Defines SET Value = 0 WHERE Name = 'CITY_GROWTH_EXPONENT';

--stop water culture spread
UPDATE Defines SET Value = 10000 WHERE Name = 'PLOT_INFLUENCE_WATER_COST';
UPDATE Defines SET Value = 100 WHERE Name = 'PLOT_INFLUENCE_NO_ADJACENT_OWNED_COST';
--UPDATE Defines SET Value = -5 WHERE Name = 'PLOT_INFLUENCE_RESOURCE_COST';	--105

--religious spread (base too strong, perhaps due to extra city clustering)
UPDATE Defines SET Value = 1000 WHERE Name = 'RELIGION_ATHEISM_PRESSURE_PER_POP';		--1000 BNW
UPDATE Defines SET Value = 5000 WHERE Name = 'RELIGION_INITIAL_FOUNDING_CITY_PRESSURE';	--5000
UPDATE Defines SET Value = 5 WHERE Name = 'RELIGION_PER_TURN_FOUNDING_CITY_PRESSURE';	--5
UPDATE Defines SET Value = 8 WHERE Name = 'RELIGION_ADJACENT_CITY_DISTANCE';			--10

--happiness
UPDATE Defines SET Value = 0 WHERE Name = 'UNHAPPINESS_PER_CITY';					--but there is a racial disharmonly penalty
UPDATE Defines SET Value = 0 WHERE Name = 'VERY_UNHAPPY_CANT_TRAIN_SETTLERS';
UPDATE Defines SET Value = -33 WHERE Name = 'VERY_UNHAPPY_PRODUCTION_PENALTY';		--reduced from -50
UPDATE Defines SET Value = -50 WHERE Name = 'UNHAPPY_GROWTH_PENALTY';
UPDATE Defines SET Value = -75 WHERE Name = 'VERY_UNHAPPY_GROWTH_PENALTY';

UPDATE Defines SET Value = 0 WHERE Name = 'VERY_UNHAPPY_COMBAT_PENALTY_PER_UNHAPPY';
UPDATE Defines SET Value = 0 WHERE Name = 'VERY_UNHAPPY_MAX_COMBAT_PENALTY';

--city defense
UPDATE Defines SET Value = 1 WHERE Name = 'CITY_ATTACK_RANGE';				--2
UPDATE Defines SET Value = 0 WHERE Name = 'CITY_STRENGTH_TECH_BASE';		--5.5
UPDATE Defines SET Value = 0 WHERE Name = 'CITY_STRENGTH_TECH_EXPONENT';	--2.8
UPDATE Defines SET Value = 0 WHERE Name = 'CITY_STRENGTH_TECH_MULTIPLIER';	--1

--other city stuff
UPDATE Defines SET Value = 1 WHERE Name = 'MIN_CITY_RANGE';					--3
UPDATE Defines SET Value = 1 WHERE Name = 'CAN_WORK_WATER_FROM_GAME_START';		--I don't think this does anything

--units & combat
UPDATE Defines SET Value = 100 WHERE Name = 'RANGE_ATTACK_RANGED_DEFENDER_MOD';						--changed from 125 in G&K (was 100 in vanilla)
UPDATE Defines SET Value = 1800 WHERE Name = 'RANGE_ATTACK_SAME_STRENGTH_MIN_DAMAGE';				--changed from 2400 in G&K
UPDATE Defines SET Value = 900 WHERE Name = 'RANGE_ATTACK_SAME_STRENGTH_POSSIBLE_EXTRA_DAMAGE';		--changed from 1200 in G&K
UPDATE Defines SET Value = -30 WHERE Name = 'STRATEGIC_RESOURCE_EXHAUSTED_PENALTY';		--changed from -50
UPDATE Defines SET Value = 3 WHERE Name = 'RECON_VISIBILITY_RANGE';		--changed from 6

--barbs
UPDATE Defines SET Value = 75 WHERE Name = 'BARBARIAN_TECH_PERCENT';		--75
UPDATE Defines SET Value = 150 WHERE Name = 'BARBARIAN_MAX_XP_VALUE';		--30



--AI
INSERT INTO Defines (Name, Value) VALUES
('AI_RENOUNCE_MALEFICIUM_BASE_VALUE',		120	),	--these control the trade item valuation in EaDLL
('AI_RENOUNCE_MALEFICIUM_PEACE_MULTIPLIER',	2	),
('AI_RENOUNCE_MALEFICIUM_RECEIVER_VALUE',	100	);

UPDATE Defines SET Value = 5 WHERE Name = 'NUM_POLICY_BRANCHES_ALLOWED';	--this should not matter

--disables
UPDATE Defines SET Value = 999999 WHERE Name = 'BASE_POLICY_COST';
UPDATE Defines SET Value = 99999 WHERE Name = 'RELIGION_MIN_FAITH_FIRST_PANTHEON';
UPDATE Defines SET Value = 999999 WHERE Name = 'RELIGION_MIN_FAITH_FIRST_PROPHET';
UPDATE Defines SET Value = 999999 WHERE Name = 'RELIGION_MIN_FAITH_FIRST_GREAT_PERSON';

-----------------------------------------------------------------------------------------
-- PostDefines
-----------------------------------------------------------------------------------------

INSERT INTO PostDefines (Name, Key, "Table") VALUES
('ANIMALS_CIVILIZATION', 'CIVILIZATION_ANIMALS', 'Civilizations'),
('THE_FAY_CIVILIZATION', 'CIVILIZATION_THE_FAY', 'Civilizations');

UPDATE PostDefines SET Key = 'CALENDAR_YEARS' WHERE Name = 'STANDARD_CALENDAR';	--


INSERT INTO EaDebugTableCheck(FileName) SELECT 'GlobalDefines.sql';