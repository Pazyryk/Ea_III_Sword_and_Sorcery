
--These are the "standard" game length and map size adjustments:

-- GAMESPEED_QUICK		2/3
-- GAMESPEED_STANDARD	1
-- GAMESPEED_EPIC		3/2
-- GAMESPEED_MARATHON	2	

-- WORLDSIZE_DUEL		1/2
-- WORLDSIZE_TINY		1/2
-- WORLDSIZE_SMALL		2/3
-- WORLDSIZE_STANDARD	1
-- WORLDSIZE_LARGE		3/2
-- WORLDSIZE_HUGE		2	


-- GameLengthExp and MapSizeExp in table below are exponent on adjustment above, so:
-- 1 is multiply, -1 is divide, 0 is no effect; but any other exponent (including
-- fractional) can be used for greater or lesser adjustment.
--
-- E.g., to turn a 0.6667 adjustment to a "stronger" 0.5,
--       0.6667^x = 0.5
--       x = log 0.5 / log 0.6667
--       x = 1.7095

-- So use 1.7095 below if we wanted, for example, Small Map to adjust base value by 1/2
-- rather than 2/3, but all other map size adjustments would be amplified too.

CREATE TABLE EaSettings ('Name' TEXT NOT NULL,
						'Value' NUMERIC,			-- Type affinity in SQLite will allow text, but will attempt to convert it to number if it looks like one
						'GameLengthExp' NUMERIC,	-- 1 mulitply; -1 divide; 0 no effect (any other values allowed)
						'MapSizeExp' NUMERIC,		-- 1 mulitply; -1 divide; 0 no effect (any other values allowed)
						'RoundAdjVal' INTEGER,		-- 1 -> round after adjusments
						'Max' NUMERIC DEFAULT NULL,	-- Max, Min value after adjustment
						'Min' NUMERIC DEFAULT NULL);

-- Under Construction (most setting still at top of applicable Lua file)

INSERT INTO EaSettings (Name, Value, GameLengthExp, MapSizeExp, RoundAdjVal) VALUES

--Mana
('STARTING_SUM_OF_ALL_MANA',					300000,	1,	1,	1	),	--standard adj for game length & map size, then round to intenger 
('MANA_CONSUMED_PER_ANRA_FOLLOWER_PER_TURN',	1,		0,	0,	0	),
('MANA_CONSUMED_BY_ANRA_FOUNDING',				1000,	0,	1,	1	),
('MANA_CONSUMED_BY_CIV_FALL',					200,	0,	0,	0	),

--Living Terrain
('SPREAD_CHANCE_DENOMINATOR',					100,	1,	0,	1	),	--chance per turn = strength / this value (so smaller = faster)

--One with Nature VC (these numbers used to calculate actual thresholds based on initial map conditions)
('ONE_W_NATURE_VC_LT_COVERAGE',					45,		0,	0,	0	),	--% of valid plots not covered at game start that need to be
('ONE_W_NATURE_VC_LT_AVE_STR',					2.5,	0,	0,	0	),	--increase from initial average at map generation
('ONE_W_NATURE_PAN_CIV_RATIO_COVERAGE_EXTRA',	30,		0,	0,	0	),	--extra % needed mulitplied by fraction of civs that were pantheistic (result is capped at 80)
('ONE_W_NATURE_PAN_CIV_RATIO_AVE_STR_EXTRA',	10,		0,	0,	0	),	--extra ave str needed mulitplied by fraction of civs that were pantheistic
('ONE_W_NATURE_PLOT_NUMBER_NORMALIZER',			950,	1,	1,	0	),	--more valid plots, less coverage and ave str needed 

--Domination VC
('DOMINATION_VC_POPULATION_PERCENT',			60,		0,	0,	0	),	--% of world population
('DOMINATION_VC_LAND_PERCENT',					40,		0,	0,	0	),	--% of world land
('DOMINATION_VC_IMPROVED_LAND_PERCENT',			80,		0,	0,	0	),	--% of owned improveable land (could have something) that is improved

--Great People
('GP_TARGET_NUMBER',							3,		0,	1,	0	),

--Slaves
('SLAVE_SELL_PRICE',							30,		0,	0,	0	),
('SLAVE_RENDER_PRODUCTION',						20,		0,	0,	0	),
('SLAVE_UPGRD_TO_WARRIOR_COST',					50,		0,	0,	0	),
('SLAVE_BUY_PRICE_FROM_CS',						45,		0,	0,	0	),
('SLAVE_CS_FRIEND_DISCOUNT',					15,		0,	0,	0	),
('SLAVE_CS_ALLY_DISCOUNT',						35,		0,	0,	0	),

--Resources
('TIMBER_DURATION_FROM_CHOP',					40,		1,	0,	1	),

--Techs / KM
('KM_PER_TECH_PER_CITIZEN',						0.1,	0,	0,	0	),	--bigger map means more citizens and more research points, so call it a wash for adjustments
('FAVORED_TECH_COST_REDUCTION',					-20,	0,	0,	0	),

--Culture Level / Policies
('CL_C_PER_POP_MULTIPLIER',						6,		0,	0,	0	),	--approach CL as a function of culture generation / maxPopEver
('CL_C_PER_POP_ADD',							5,		0,	0,	0	),	--extra policies (total you would get with no culture)
('CL_APPROACH_FACTOR',							0.005,	-1,	0,	0	),	--try to approach steady state level by this fraction of the difference each turn
('CL_TARGET_CHANGE',							0.05,	-1,	0,	0	),	--"tendency" for change/turn (next setting determines strength of this tendency)
('CL_CHANGE_DAMPING_EXPONENT',					0.75,	0,	0,	0	),	--at 0, rate = CL_TARGET_CHANGE; at 1, rate soley function of asymptotic function (gap & CL_APPROACH_FACTOR)
--('CL_RECENCY_BIAS',							0.05,	-0.5,-1,0	),	--DEPRECIATED in v7f
('CL_LOW_POP_FACTOR',							10,		0,	1,	0	),

--Barbs
('BARB_TURN_CEILING',							300,	0,	0,	0	),	--stop increasing barb threat at this turn
('ENCAMPMENT_HEALING',							10,		0,	0,	0	),
('ROAM_SPAWN_MULTIPLIER',						1.5,	0,	0,	0	),	--Raise for faster spawning
('ROAM_TURN_EXPONENT',							1,		0,	0,	0	),	--Raise to increase spawning as a function of turn number
('ROAM_DENSITY_FEEDBACK_EXPONENT',				3,		0,	0,	0	),	--Raise to increase negative feedback from area density
('ROAM_POWER_FEEDBACK_EXPONENT',				2,		0,	0,	0	),	--Raise to increase negative feedback from unit power (less ogers compared to goblins)
('SEA_SPAWN_MULTIPLIER',						1.5,	0,	0,	0	),
('SEA_TURN_EXPONENT',							1,		0,	0,	0	),
('SEA_DENSITY_FEEDBACK_EXPONENT',				3,		0,	0,	0	),
('SEA_POWER_FEEDBACK_EXPONENT',					1.4,	0,	0,	0	),
('USE_MINIMUM_PIRATE_COVE_NUMBER',				4,		0,	0,	0	),
('USE_MAXIMUM_PIRATE_COVE_NUMBER',				10,		0,	0,	0	),
('MAX_CAPTURED_PER_CIV_PER_ENCAMPMENT',			2,		0,	0,	0	),

--Animals
('ANIMAL_SPAWN_SPACER',							750,	0,	0,	0	),	--animals spawn every [random(1 to value) plots * (number existing animals + 10) ^ 3 / 1000] plots from all available plots
('ANIMAL_ONE_IN_DEATH_CHANCE',					20,		-1,	0,	1	),

--AI 
('CONTINGENCY_THRESHOLD',						40,		0,	0,	0	),
('CONTINGENCY_TURN_INTERVAL',					5,		0,	0,	0	),
('MOD_MEMORY_HALFLIFE',							30,		1,	0,	1	),	--What GP is doing now is twice as important as this many turns ago
('TRAVEL_TURNS_WITHIN_AREA',					4,		0,	0,	0	),

--Diplo
('FULL_WARMONGER_DISCOUNT_AT_PERCENT_MANA',		10,		0,	0,	0	),
('CITY_STATE_WARMONGER_DISCOUNT',				75,		0,	0,	0	),
('RACE_HATRED_FOR_RAZED_POP',					0.5,	-1,	-1,	0	);

--UPDATE EaSettings SET Max = 80 WHERE Type = 'ONE_W_NATURE_VC_LT_COVERAGE';

INSERT INTO EaDebugTableCheck(FileName) SELECT '_EaSettings.sql';