

CREATE TABLE EaEpics (	'ID' INTEGER PRIMARY KEY AUTOINCREMENT,
						'Type' TEXT NOT NULL UNIQUE,
						'Description' TEXT DEFAULT NULL,
						'EaAction' TEXT DEFAULT NULL,
						'IconIndex' INTEGER DEFAULT NULL,
						'IconAtlas' TEXT DEFAULT NULL);
						--Epics are always associated with a specific iPlayer and never change ownership
						--gEpics[ID] = nil or {mod, iPlayer} for created epics


INSERT INTO EaEpics (Type,			Description,						EaAction							) VALUES	--world uniques only
('EA_EPIC_VOLUSPA',					'TXT_KEY_EA_EPIC_VOLUSPA',			'EA_ACTION_EPIC_VOLUSPA'			),
('EA_EPIC_HAVAMAL',					'TXT_KEY_EA_EPIC_HAVAMAL',			'EA_ACTION_EPIC_HAVAMAL'			),
('EA_EPIC_VAFTHRUTHNISMAL',			'TXT_KEY_EA_EPIC_VAFTHRUTHNISMAL',	'EA_ACTION_EPIC_VAFTHRUTHNISMAL'	),
('EA_EPIC_GRIMNISMAL',				'TXT_KEY_EA_EPIC_GRIMNISMAL',		'EA_ACTION_EPIC_GRIMNISMAL'			),
('EA_EPIC_HYMISKVITHA',				'TXT_KEY_EA_EPIC_HYMISKVITHA',		'EA_ACTION_EPIC_HYMISKVITHA'		);

UPDATE EaEpics SET IconIndex = (SELECT IconIndex FROM EaActions WHERE EaEpic = EaEpics.Type);
UPDATE EaEpics SET IconAtlas = (SELECT IconAtlas FROM EaActions WHERE EaEpic = EaEpics.Type);
--UPDATE EaEpics SET Description = (SELECT Description FROM EaActions WHERE EaEpic = EaEpics.Type);





INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaEpics.sql';