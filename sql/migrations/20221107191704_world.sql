DROP PROCEDURE IF EXISTS add_migration;
delimiter ??
CREATE PROCEDURE `add_migration`()
BEGIN
DECLARE v INT DEFAULT 1;
SET v = (SELECT COUNT(*) FROM `migrations` WHERE `id`='20221107191704');
IF v=0 THEN
INSERT INTO `migrations` VALUES ('20221107191704');
-- Add your query below.

INSERT INTO `conditions` (`condition_entry`, `type`, `value1`, `value2`, `value3`, `value4`, `flags`) VALUES 
(10997, 7, 202, 200, 0, 0, 0), -- Condition for Engineering skill of 200
(10994, 8, 3639, 0, 0, 0, 0), -- Condition for completing Show Your Work (goblin engineering)
(10995, 8, 3641, 0, 0, 0, 0), -- Condition for completing Show Your Work (gnomish engineering - alliance side) 
(10996, 8, 3643, 0, 0, 0, 0), -- Condition for completing Show Your Work (gnomish engineering - horde side) 
(10998, -2, 10994, 10995, 10996, 0, 0) -- Condition to return true if any of the above quests are complete
(10999, 17, 20219, 1, 0, 0, 0), -- Condition to return true if the player has NOT learnt Gnomish Engineering
(11000, 17, 20222, 1, 0, 0, 0), -- Condition to return true if the player has NOT learnt Goblin Engineering
(11001, -1, 10999, 11000, 0, 0, 0), -- Condition to return true if the player has NOT learnt Gnomish Engineering AND Goblin Engineering
-- Note: Condition 4018 corresponds to a condition checking if the current patch is 1.10 or higher
(11002, -1, 11001, 10998, 10997, 4018, 0), -- Condition to return true if the player doesn't have an Engineering specialisation, completed one of the Engineering specialisation quests, and has a skill of 200 Engineering, and the current patch is 1.10 or later
(11003, -1, 11001, 10995, 10997, 10994, 0), -- Same as above (missing patch requirement) but requires specifically completing Show Your Work (gnomish engineering - alliance side) or Show Your Work (goblin engineering) for gossip option
(11004, -1, 11001, 10996, 10997, 10994, 0), -- Same as above (missing patch requirement) but requires specifically completing Show Your Work (gnomish engineering - horde side) or Show Your Work (goblin engineering) for gossip option
(11005, -1, 11003, 4018, 0, 0, 0), -- Add patch requirement to alliance-side gossip condition
(11006, -1, 11004, 4018, 0, 0, 0), -- Add patch requirement to horde-side gossip condition
(11007, -1, 11002, A, 0, 0, 1), -- NAND gate for Leatherworking and Engineering requirements for Book "Soothsaying for Dummies" gossip (If the conditions for both Leatherworking and Engineering gossips are met then this condition allows to decide which one should be displayed)
(11008, -1, 11002, 11007, 0, 0, 0). -- Condition for 
(, 7, 165, 225, 0, 0, 0), -- Condition for Leatherworking skill of 225
(,

INSERT INTO `npc_text` (`ID`, `BroadcastTextID0`, `Probability0`, `BroadcastTextID1`, `Probability1`, `BroadcastTextID2`, `Probability2`, `BroadcastTextID3`, `Probability3`, `BroadcastTextID4`, `Probability4`, `BroadcastTextID5`, `Probability5`, `BroadcastTextID6`, `Probability6`, `BroadcastTextID7`, `Probability7`) VALUES 
(21000, 11880, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(21001, 11882, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(21002, 11884, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(21003, 11875, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),

INSERT INTO `gossip_menu` (`entry`, `text_id`, `script_id`, `condition_id`) VALUES
(1469, 21000, 0, 11002), -- Gossip for Nixx Sprocketspring
(1468, 21001, 0, 11003), -- Gossip for Tinkmaster Overspark
(1467, 21002, 0, 11004), -- Gossip for Oglethorpe Obnoticus
(7058, 21003, 0, 11002), - Gossip for Book "Soothslaying for Dummies" (Engineering)

INSERT INTO `gossip_scripts` (`id`, `delay`, `priority`, `command`, `datalong`, `datalong2`, `datalong3`, `datalong4`, `target_param1`, `target_param2`, `target_type`, `data_flags`, `dataint`, `dataint2`, `dataint3`, `dataint4`, `x`, `y`, `z`, `o`, `condition_id`, `comments`) VALUES 
(2861, 0, 0, 15, 20221, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Book "Soothsaying for Dummies" - Teach Goblin Engineering'),
(2862, 0, 0, 15, 20220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Book "Soothsaying for Dummies" - Teach Gnomish Engineering'),

INSERT INTO `gossip_menu_option` (`menu_id`, `id`, `option_icon`, `option_text`, `option_broadcast_text`, `option_id`, `npc_option_npcflag`, `action_menu_id`, `action_poi_id`, `action_script_id`, `box_coded`, `box_money`, `box_text`, `box_broadcast_text`, `condition_id`) VALUES 
(7058, 1, 0, 'I am 100% confident that I wish to learn in the ways of goblin engineering.', 11876, 1, 1, -1, 0, 2861, 0, 0, '', 0, 11005),
(7058, 2, 0, 'I am 100% confident that I wish to learn in the ways of gnomish engineering.', 11878, 1, 1, -1, 0, 2862, 0, 0, '', 0, 11005),


-- End of migration.
END IF;
END??
delimiter ; 
CALL add_migration();
DROP PROCEDURE IF EXISTS add_migration;