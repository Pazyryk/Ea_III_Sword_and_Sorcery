

CREATE TABLE EaSettings ('Name' TEXT NOT NULL,
						'Value' NUMERIC,			-- Type affinity in SQLite will allow text, but will attempt to convert it to number if it looks like one
						'GameLengthExp' NUMERIC,	-- 1, mulitply; -1 divide; 0 no effect (any other values allowed)
						'MapSizeExp' NUMERIC,		-- 1, mulitply; -1 divide; 0 no effect (any other values allowed)
						'Int' INTEGER		);		-- 0, don't round; 1 round after adjusments


-- Under Construction (most setting still at top of applicable Lua file)

INSERT INTO EaSettings (Name, Value, GameLengthExp, MapSizeExp, Int) VALUES

--Mana
('STARTING_SUM_OF_ALL_MANA',					300000,	1,	1,	1	),	--standard adj for game length & map size, then round to intenger 
('MANA_CONSUMED_PER_ANRA_FOLLOWER_PER_TURN',	1,		0,	0,	0	),
('MANA_CONSUMED_BY_ANRA_FOUNDING',				1000,	0,	1,	1	),
('MANA_CONSUMED_BY_CIV_FALL',					200,	0,	0,	0	),

--Great People
('GP_TARGET_NUMBER',							3,		0,	1,	0	),

--Slaves
('SLAVE_SELL_PRICE',							30,		0,	0,	0	),
('SLAVE_RENDER_PRODUCTION',						20,		0,	0,	0	),
('SLAVE_UPGRD_TO_WARRIOR_COST',					50,		0,	0,	0	),
('SLAVE_BUY_PRICE_FROM_CS',						35,		0,	0,	0	),


--Resources
('TIMBER_DURATION_FROM_CHOP',					40,		1,	0,	1	),

--Techs / KM
('KM_PER_TECH_PER_CITIZEN',						0.1,	0,	0,	0	),	--bigger map means more citizens and more research points, so call it a wash for adjustments
('FAVORED_TECH_COST_REDUCTION',					-20,	0,	0,	0	),

--Culture Level / Policies
('POLICY_MULTIPLIER',							6,		0,	0,	0	),	--from 5 in v6
('POLICY_ADD',									5,		0,	0,	0	),	--from 4 in v6
('CL_APPROACH_FACTOR',							0.006,	-1,	0,	0	),
('CL_TARGET_CHANGE',							0.06,	-1,	0,	0	),
('CL_CHANGE_DAMPING_EXPONENT',					0.5,	0,	0,	0	),

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



INSERT INTO EaDebugTableCheck(FileName) SELECT '_EaSettings.sql';