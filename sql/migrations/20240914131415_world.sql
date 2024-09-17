DROP PROCEDURE IF EXISTS add_migration;
delimiter ??
CREATE PROCEDURE `add_migration`()
BEGIN
DECLARE v INT DEFAULT 1;
SET v = (SELECT COUNT(*) FROM `migrations` WHERE `id`='20240914131415');
IF v=0 THEN
INSERT INTO `migrations` VALUES ('20240914131415');
-- Add your query below.

-- Remove patch 1.10 requirement for Book Soothsaying for dummies and various gossips
UPDATE `conditions` SET `value4` = 0 WHERE `condition_entry` = 11002;
UPDATE `conditions` SET `value4` = 0 WHERE `condition_entry` = 11023;

-- Remove patch 1.10 requirement for certain relevant gossips
UPDATE `gossip_menu` SET `condition_id` = 11003 WHERE `entry` = 1468;
UPDATE `gossip_menu` SET `condition_id` = 11004 WHERE `entry` = 1467;

INSERT INTO `conditions` (`condition_entry`, `type`, `value1`, `value2`, `value3`, `value4`, `flags`) VALUES 
(11043, 8, 5284, 0, 0, 0, 0), -- Condition to check if the player has completed "The Way of the Weaponsmith" (Alliance)
(11044, 8, 5301, 0, 0, 0, 0), -- Condition to check if the player has completed "The Art of the Armorsmith" (Horde)
(11045, 8, 5302, 0, 0, 0, 0), -- Condition to check if the player has completed "The Way of the Weaponsmith" (Horde)
(11046, -2, 11042, 11044, 0, 0, 0), -- Condition to check if the player has completed "The Art of the Armorsmith" (Both factions)
(11047, -2, 11043, 11045, 0, 0, 0), -- Condition to check if the player has completed "The Way of the Weaponsmith" (Both factions)
-- Note: Condition 178 corresponds to a condition checking if the player is level 40 or higher
-- Note: Condition 368 corresponds to a condition checking if the player has a Blacksmithing skill of 200
-- Note: Condition 1356 corresponds to a condition checking if the player has NOT learnt Armorsmith AND has NOT learnt Weaponsmith
(11048, -1, 178, 368, 1356, 11046, 0), -- Condition for respecialisation gossip by Bengus Deepforge (Alliance) and Krathok Moltenfist (Horde) for players who were previously armorsmiths
(11049, -1, 178, 368, 1356, 11047, 0), -- Condition for respecialisation gossip by Bengus Deepforge (Alliance) and Krathok Moltenfist (Horde) for players who were previously weaponsmiths
(11050, 8, 5305, 0, 0, 0, 0), -- Condition to check if the player has completed "Sweet Serenity" (Hammersmith sub-specialisation)
(11051, 8, 5306, 0, 0, 0, 0), -- Condition to check if the player has completed "Snakestone of the Shadow Huntress" (Axesmith sub-specialisation)
(11052, 8, 5307, 0, 0, 0, 0), -- Condition to check if the player has completed "Corruption" (Swordsmith sub-specialisation)
(11053, -2, 11050, 11051, 11052, 0, 0), -- Condition to check if the player has completed any of the above quests
-- Note: Condition 1351 corresponds to a condition checking if the player has a Blacksmithing skill of 250
-- Note: Condition 1352 corresponds to a condition checking if the player has learnt Artisan Weaponsmith
-- Note: Condition 1364 corresponds to a condition checking if the player has NOT learnt any of the weaponsmith sub-specialisations
(11054, -1, 1351, 1352, 1364, 11053, 0), -- Condition for respecialisation for weaponsmith sub-specialisations
(11056, -2, 11048, 11049, 0, 0, 0); -- Condition to check if the player meets requirements for respecialisation

INSERT INTO `gossip_scripts` (`id`, `delay`, `priority`, `command`, `datalong`, `datalong2`, `datalong3`, `datalong4`, `target_param1`, `target_param2`, `target_type`, `data_flags`, `dataint`, `dataint2`, `dataint3`, `dataint4`, `x`, `y`, `z`, `o`, `condition_id`, `comments`) VALUES
(318203, 0, 0, 15, 9790, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11056, 'Cast Artisan Armorsmith'),
(318204, 0, 0, 15, 9789, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 11056, 'Cast Artisan Weaponsmith');

-- Update respecialisation gossip for sub-specialisations only for respecialisation
UPDATE `gossip_menu_option` SET `condition_id` = 11054 WHERE `menu_id` = 6089 AND `id` = 0;
UPDATE `gossip_menu_option` SET `condition_id` = 11054 WHERE `menu_id` = 6090 AND `id` = 0;
UPDATE `gossip_menu_option` SET `condition_id` = 11054 WHERE `menu_id` = 6091 AND `id` = 0;

INSERT INTO `gossip_menu_option` (`menu_id`, `id`, `option_icon`, `option_text`, `option_broadcast_text`, `option_id`, `npc_option_npcflag`, `action_menu_id`, `action_poi_id`, `action_script_id`, `box_coded`, `box_money`, `box_text`, `box_broadcast_text`, `condition_id`) VALUES 
(3182, 2, 0, 'Myolor, I was once an armorsmith and wish to retake the hammer once more! Teach me the way of the armorsmith.', 8892, 1, 3, -1, 0, 318203, 0, 0, '', 0, 11048),
(3182, 3, 0, 'Myolor, I was once a weaponsmith and wish to retake the hammer once more! Teach me the way of the weaponsmith!', 8893, 1, 3, -1, 0, 318204, 0, 0, '', 0, 11049), -- Interesting to note this the only option to have 2 exclamation marks, an odd inconsistency by Blizzard.
(3182, 4, 0, 'Myolor, I was once an armorsmith and wish to instead learn the way of the weaponsmith. Will you teach me?', 10895, 1, 3, -1, 0, 318204, 0, 0, '', 0, 11048),
(3182, 5, 0, 'Myolor, I was once a weaponsmith and wish to instead learn the way of the armorsmith. Will you teach me?', 10896, 1, 3, -1, 0, 318203, 0, 0, '', 0, 11049),
(3187, 2, 0, 'Krathok, I was once an armorsmith and wish to retake the hammer once more! Teach me the way of the armorsmith.', 8894, 1, 3, -1, 0, 318203, 0, 0, '', 0, 11048),
(3187, 3, 0, 'Krathok, I was once a weaponsmith and wish to retake the hammer once more! Teach me the way of the weaponsmith.', 8895, 1, 3, -1, 0, 318204, 0, 0, '', 0, 11049),
(3187, 4, 0, 'Krathok, I was once an armorsmith and wish to instead learn the ways of the weaponsmith. Will you train me?', 10897, 1, 3, -1, 0, 318204, 0, 0, '', 0, 11048),
(3187, 5, 0, 'Krathok, I was once a weaponsmith and wish to instead learn the ways of the armorsmith. Will you train me?', 10898, 1, 3, -1, 0, 318203, 0, 0, '', 0, 11049);

-- Update respecialisation gossip for sub-specialisations only for respecialisation
UPDATE `gossip_menu_option` SET `condition_id` = 11054 WHERE `menu_id` = 6089 AND `id` = 0;
UPDATE `gossip_menu_option` SET `condition_id` = 11054 WHERE `menu_id` = 6090 AND `id` = 0;
UPDATE `gossip_menu_option` SET `condition_id` = 11054 WHERE `menu_id` = 6091 AND `id` = 0;

-- End of migration.
END IF;
END??
delimiter ; 
CALL add_migration();
DROP PROCEDURE IF EXISTS add_migration;
