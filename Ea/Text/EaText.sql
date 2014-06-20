

--Caution! Duplications crash silently



REPLACE INTO Language_en_US (Tag, Text) VALUES ('TXT_KEY_SPECIFIC_DIPLO_STRING_1', 'You are evil');
REPLACE INTO Language_en_US (Tag, Text) VALUES ('TXT_KEY_SPECIFIC_DIPLO_STRING_2', 'We do not like your kind');
REPLACE INTO Language_en_US (Tag, Text) VALUES ('TXT_KEY_SPECIFIC_DIPLO_STRING_3', 'We admire your accomplishments');


REPLACE INTO Language_en_US (Tag, Text) VALUES ('TXT_KEY_LEADER_BARBARIAN', 'Animals');




INSERT INTO EaDebugTableCheck(FileName) SELECT 'EaText.sql';