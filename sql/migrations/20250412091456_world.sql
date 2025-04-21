DROP PROCEDURE IF EXISTS add_migration;
DELIMITER ??
CREATE PROCEDURE `add_migration`()
BEGIN
DECLARE v INT DEFAULT 1;
SET v = (SELECT COUNT(*) FROM `migrations` WHERE `id`='20250412091456');
IF v = 0 THEN
INSERT INTO `migrations` VALUES ('20250412091456');
-- Add your query below.

INSERT INTO `creature` (`guid`, `id`, `id2`, `id3`, `id4`, `id5`, `map`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecsmin`, `spawntimesecsmax`, `wander_distance`, `health_percent`, `mana_percent`, `movement_type`, `spawn_flags`, `visibility_mod`, `patch_min`, `patch_max`) VALUES 
(5331025, 16573, 0, 0, 0, 0, 533, 3291.26, -3502.08, 287.26, 2.14, 3520, 3520, 0, 100, 0, 0, 0, 0, 9, 10),
(5331026, 16573, 0, 0, 0, 0, 533, 3285.29, -3446.640, 287.26, 4.2, 3520, 3520, 0, 100, 0, 0, 0, 0, 9, 10);

INSERT INTO `creature_linking_template` (`entry`, `map`, `master_entry`, `flag`, `search_range`) VALUES 
(16573, 533, 15956, 17415, 0);

INSERT INTO `creature_ai_events` (`id`, `creature_id`, `condition_id`, `event_type`, `event_inverse_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `action1_script`, `action2_script`, `action3_script`, `comment`) VALUES 
(1657301, 16573, 0, 0, 0, 100, 1, 4000, 6000, 4000, 7000, 1657301, 0, 0, 'Crypt Guard - Cast Acid Spit'),
(1657302, 16573, 0, 0, 0, 100, 1, 7000, 9000, 7000, 9000, 1657302, 0, 0, 'Crypt Guard - Cast Cleave'),
(1657303, 16573, 0, 0, 0, 100, 1, 6000, 12000, 9000, 16000, 1657303, 0, 0, 'Crypt Guard - Cast Web'),
(1657304, 16573, 0, 2, 0, 100, 1, 50, 0, 12000, 12000, 1657304, 0, 0, 'Crypt Guard - Cast Enrage at 50% HP');

INSERT INTO `creature_ai_scripts` (`id`, `delay`, `priority`, `command`, `datalong`, `datalong2`, `datalong3`, `datalong4`, `target_param1`, `target_param2`, `target_type`, `data_flags`, `dataint`, `dataint2`, `dataint3`, `dataint4`, `x`, `y`, `z`, `o`, `condition_id`, `comments`) VALUES 
(1657301, 0, 0, 15, 28969, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Crypt Guard - Cast Acid Spit'),
(1657302, 0, 0, 15, 15579, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Crypt Guard - Cast Cleave'),
(1657303, 0, 0, 15, 28991, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Crypt Guard - Cast Web'),
(1657304, 0, 0, 15, 8269, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Crypt Guard - Cast Enrage at 50% HP');

UPDATE `creature_template` SET `ai_name` = 'EventAI' WHERE `entry`=16573;

INSERT INTO `spell_target_position` (`id`, `target_map`, `target_position_x`, `target_position_y`, `target_position_z`, `target_orientation`, `build_min`, `build_max`) VALUES 
(29508, 533, 3333.5, -3475.9, 287.1, 3.17, 5464, 5875);

INSERT INTO `spell_script_target` (`entry`, `type`, `targetEntry`, `conditionId`, `inverseEffectMask`, `build_min`, `build_max`) VALUES 
(29379, 1, 16573, 0, 4, 5464, 5875), -- Crypt Guards
(29379, 1, 16698, 0, 2, 5464, 5875); -- Corpse Scarabs

UPDATE `creature_template` SET `script_name`='' WHERE `entry` = 16573;

UPDATE `spell_template` SET `script_name` = 'spell_despawn_target' WHERE `entry` = 29379; -- Other entries will be added over different PRs for different bosses

-- End of migration.
END IF;
END??
DELIMITER ;
CALL add_migration();
DROP PROCEDURE IF EXISTS add_migration;
