*> Acceptance test of docs/protocol/16-commands-catalog.md §13 the gamerule table (59 rules, one group of cases per rule: name, type, default, range) and §14 aliases. Each rule is queried at its default (commands.gamerule.query shows
*> true/false for a boolean and the integer for an integer rule), a boolean refuses a word that is no boolean, an integer rule refuses a value one below its minimum and (when the maximum is not 2147483647) one above its maximum.
*> The aliases of 14 are tested with their commands: tell and w in test_cmd_msg, tp in test_cmd_teleport, tm in test_cmd_teammsg (xp waits for experience, a command of another lane).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-GAMERULES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY BRCMDA.
 01 WS-ID-OPAL        BINARY-LONG.
 01 WS-ID-ALICE        BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-TICKS               BINARY-LONG.
 01 WS-WANTED              BINARY-LONG.
 01 WS-OBSERVED-N          BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-TEXT
     MOVE 0 TO WS-TICKS
     MOVE "acceptance US13 gamerule table advance_time is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule advance_time" TO WS-LINE
     MOVE "commands.gamerule.query(advance_time,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table advance_time takes true or false only" TO TL-CASE
     MOVE "gamerule advance_time maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table advance_weather is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule advance_weather" TO WS-LINE
     MOVE "commands.gamerule.query(advance_weather,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table advance_weather takes true or false only" TO TL-CASE
     MOVE "gamerule advance_weather maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table allow_entering_nether_using_portals is a boolean rule with " & "default true" TO TL-CASE
     MOVE "gamerule allow_entering_nether_using_portals" TO WS-LINE
     MOVE "commands.gamerule.query(allow_entering_nether_using_portals,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table allow_entering_nether_using_portals takes true or false onl" & "y" TO TL-CASE
     MOVE "gamerule allow_entering_nether_using_portals maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table block_drops is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule block_drops" TO WS-LINE
     MOVE "commands.gamerule.query(block_drops,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table block_drops takes true or false only" TO TL-CASE
     MOVE "gamerule block_drops maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table block_explosion_drop_decay is a boolean rule with default t" & "rue" TO TL-CASE
     MOVE "gamerule block_explosion_drop_decay" TO WS-LINE
     MOVE "commands.gamerule.query(block_explosion_drop_decay,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table block_explosion_drop_decay takes true or false only" TO TL-CASE
     MOVE "gamerule block_explosion_drop_decay maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table command_blocks_work is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule command_blocks_work" TO WS-LINE
     MOVE "commands.gamerule.query(command_blocks_work,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table command_blocks_work takes true or false only" TO TL-CASE
     MOVE "gamerule command_blocks_work maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table command_block_output is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule command_block_output" TO WS-LINE
     MOVE "commands.gamerule.query(command_block_output,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table command_block_output takes true or false only" TO TL-CASE
     MOVE "gamerule command_block_output maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table drowning_damage is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule drowning_damage" TO WS-LINE
     MOVE "commands.gamerule.query(drowning_damage,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table drowning_damage takes true or false only" TO TL-CASE
     MOVE "gamerule drowning_damage maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table elytra_movement_check is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule elytra_movement_check" TO WS-LINE
     MOVE "commands.gamerule.query(elytra_movement_check,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table elytra_movement_check takes true or false only" TO TL-CASE
     MOVE "gamerule elytra_movement_check maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table ender_pearls_vanish_on_death is a boolean rule with default" & " true" TO TL-CASE
     MOVE "gamerule ender_pearls_vanish_on_death" TO WS-LINE
     MOVE "commands.gamerule.query(ender_pearls_vanish_on_death,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table ender_pearls_vanish_on_death takes true or false only" TO TL-CASE
     MOVE "gamerule ender_pearls_vanish_on_death maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table entity_drops is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule entity_drops" TO WS-LINE
     MOVE "commands.gamerule.query(entity_drops,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table entity_drops takes true or false only" TO TL-CASE
     MOVE "gamerule entity_drops maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table fall_damage is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule fall_damage" TO WS-LINE
     MOVE "commands.gamerule.query(fall_damage,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table fall_damage takes true or false only" TO TL-CASE
     MOVE "gamerule fall_damage maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table fire_damage is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule fire_damage" TO WS-LINE
     MOVE "commands.gamerule.query(fire_damage,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table fire_damage takes true or false only" TO TL-CASE
     MOVE "gamerule fire_damage maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table fire_spread_radius_around_player is an integer rule with de" & "fault 128" TO TL-CASE
     MOVE "gamerule fire_spread_radius_around_player" TO WS-LINE
     MOVE "commands.gamerule.query(fire_spread_radius_around_player,128)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table fire_spread_radius_around_player minimum -1" TO TL-CASE
     MOVE "gamerule fire_spread_radius_around_player -2" TO WS-LINE
     MOVE "argument.integer.low(-1,-2) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table forgive_dead_players is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule forgive_dead_players" TO WS-LINE
     MOVE "commands.gamerule.query(forgive_dead_players,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table forgive_dead_players takes true or false only" TO TL-CASE
     MOVE "gamerule forgive_dead_players maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table freeze_damage is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule freeze_damage" TO WS-LINE
     MOVE "commands.gamerule.query(freeze_damage,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table freeze_damage takes true or false only" TO TL-CASE
     MOVE "gamerule freeze_damage maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table global_sound_events is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule global_sound_events" TO WS-LINE
     MOVE "commands.gamerule.query(global_sound_events,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table global_sound_events takes true or false only" TO TL-CASE
     MOVE "gamerule global_sound_events maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table immediate_respawn is a boolean rule with default false" TO TL-CASE
     MOVE "gamerule immediate_respawn" TO WS-LINE
     MOVE "commands.gamerule.query(immediate_respawn,false)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table immediate_respawn takes true or false only" TO TL-CASE
     MOVE "gamerule immediate_respawn maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table keep_inventory is a boolean rule with default false" TO TL-CASE
     MOVE "gamerule keep_inventory" TO WS-LINE
     MOVE "commands.gamerule.query(keep_inventory,false)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table keep_inventory takes true or false only" TO TL-CASE
     MOVE "gamerule keep_inventory maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table lava_source_conversion is a boolean rule with default false" TO TL-CASE
     MOVE "gamerule lava_source_conversion" TO WS-LINE
     MOVE "commands.gamerule.query(lava_source_conversion,false)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table lava_source_conversion takes true or false only" TO TL-CASE
     MOVE "gamerule lava_source_conversion maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table limited_crafting is a boolean rule with default false" TO TL-CASE
     MOVE "gamerule limited_crafting" TO WS-LINE
     MOVE "commands.gamerule.query(limited_crafting,false)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table limited_crafting takes true or false only" TO TL-CASE
     MOVE "gamerule limited_crafting maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table locator_bar is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule locator_bar" TO WS-LINE
     MOVE "commands.gamerule.query(locator_bar,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table locator_bar takes true or false only" TO TL-CASE
     MOVE "gamerule locator_bar maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table log_admin_commands is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule log_admin_commands" TO WS-LINE
     MOVE "commands.gamerule.query(log_admin_commands,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table log_admin_commands takes true or false only" TO TL-CASE
     MOVE "gamerule log_admin_commands maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_block_modifications is an integer rule with default 327" & "68" TO TL-CASE
     MOVE "gamerule max_block_modifications" TO WS-LINE
     MOVE "commands.gamerule.query(max_block_modifications,32768)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_block_modifications minimum 1" TO TL-CASE
     MOVE "gamerule max_block_modifications 0" TO WS-LINE
     MOVE "argument.integer.low(1,0) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_command_forks is an integer rule with default 65536" TO TL-CASE
     MOVE "gamerule max_command_forks" TO WS-LINE
     MOVE "commands.gamerule.query(max_command_forks,65536)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_command_forks minimum 0" TO TL-CASE
     MOVE "gamerule max_command_forks -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_command_sequence_length is an integer rule with default" & " 65536" TO TL-CASE
     MOVE "gamerule max_command_sequence_length" TO WS-LINE
     MOVE "commands.gamerule.query(max_command_sequence_length,65536)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_command_sequence_length minimum 0" TO TL-CASE
     MOVE "gamerule max_command_sequence_length -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_entity_cramming is an integer rule with default 24" TO TL-CASE
     MOVE "gamerule max_entity_cramming" TO WS-LINE
     MOVE "commands.gamerule.query(max_entity_cramming,24)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_entity_cramming minimum 0" TO TL-CASE
     MOVE "gamerule max_entity_cramming -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_minecart_speed is an integer rule with default 8" TO TL-CASE
     MOVE "gamerule max_minecart_speed" TO WS-LINE
     MOVE "commands.gamerule.query(max_minecart_speed,8)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_minecart_speed minimum 1" TO TL-CASE
     MOVE "gamerule max_minecart_speed 0" TO WS-LINE
     MOVE "argument.integer.low(1,0) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_minecart_speed maximum 1000" TO TL-CASE
     MOVE "gamerule max_minecart_speed 1001" TO WS-LINE
     MOVE "argument.integer.big(1000,1001) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_snow_accumulation_height is an integer rule with defaul" & "t 1" TO TL-CASE
     MOVE "gamerule max_snow_accumulation_height" TO WS-LINE
     MOVE "commands.gamerule.query(max_snow_accumulation_height,1)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_snow_accumulation_height minimum 0" TO TL-CASE
     MOVE "gamerule max_snow_accumulation_height -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table max_snow_accumulation_height maximum 8" TO TL-CASE
     MOVE "gamerule max_snow_accumulation_height 9" TO WS-LINE
     MOVE "argument.integer.big(8,9) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table mob_drops is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule mob_drops" TO WS-LINE
     MOVE "commands.gamerule.query(mob_drops,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table mob_drops takes true or false only" TO TL-CASE
     MOVE "gamerule mob_drops maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table mob_explosion_drop_decay is a boolean rule with default tru" & "e" TO TL-CASE
     MOVE "gamerule mob_explosion_drop_decay" TO WS-LINE
     MOVE "commands.gamerule.query(mob_explosion_drop_decay,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table mob_explosion_drop_decay takes true or false only" TO TL-CASE
     MOVE "gamerule mob_explosion_drop_decay maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table mob_griefing is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule mob_griefing" TO WS-LINE
     MOVE "commands.gamerule.query(mob_griefing,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table mob_griefing takes true or false only" TO TL-CASE
     MOVE "gamerule mob_griefing maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table natural_health_regeneration is a boolean rule with default " & "true" TO TL-CASE
     MOVE "gamerule natural_health_regeneration" TO WS-LINE
     MOVE "commands.gamerule.query(natural_health_regeneration,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table natural_health_regeneration takes true or false only" TO TL-CASE
     MOVE "gamerule natural_health_regeneration maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table player_movement_check is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule player_movement_check" TO WS-LINE
     MOVE "commands.gamerule.query(player_movement_check,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table player_movement_check takes true or false only" TO TL-CASE
     MOVE "gamerule player_movement_check maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table players_nether_portal_creative_delay is an integer rule wit" & "h default 0" TO TL-CASE
     MOVE "gamerule players_nether_portal_creative_delay" TO WS-LINE
     MOVE "commands.gamerule.query(players_nether_portal_creative_delay,0)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table players_nether_portal_creative_delay minimum 0" TO TL-CASE
     MOVE "gamerule players_nether_portal_creative_delay -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table players_nether_portal_default_delay is an integer rule with" & " default 80" TO TL-CASE
     MOVE "gamerule players_nether_portal_default_delay" TO WS-LINE
     MOVE "commands.gamerule.query(players_nether_portal_default_delay,80)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table players_nether_portal_default_delay minimum 0" TO TL-CASE
     MOVE "gamerule players_nether_portal_default_delay -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table players_sleeping_percentage is an integer rule with default" & " 100" TO TL-CASE
     MOVE "gamerule players_sleeping_percentage" TO WS-LINE
     MOVE "commands.gamerule.query(players_sleeping_percentage,100)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table players_sleeping_percentage minimum 0" TO TL-CASE
     MOVE "gamerule players_sleeping_percentage -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table projectiles_can_break_blocks is a boolean rule with default" & " true" TO TL-CASE
     MOVE "gamerule projectiles_can_break_blocks" TO WS-LINE
     MOVE "commands.gamerule.query(projectiles_can_break_blocks,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table projectiles_can_break_blocks takes true or false only" TO TL-CASE
     MOVE "gamerule projectiles_can_break_blocks maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table pvp is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule pvp" TO WS-LINE
     MOVE "commands.gamerule.query(pvp,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table pvp takes true or false only" TO TL-CASE
     MOVE "gamerule pvp maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table raids is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule raids" TO WS-LINE
     MOVE "commands.gamerule.query(raids,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table raids takes true or false only" TO TL-CASE
     MOVE "gamerule raids maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table random_tick_speed is an integer rule with default 3" TO TL-CASE
     MOVE "gamerule random_tick_speed" TO WS-LINE
     MOVE "commands.gamerule.query(random_tick_speed,3)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table random_tick_speed minimum 0" TO TL-CASE
     MOVE "gamerule random_tick_speed -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table reduced_debug_info is a boolean rule with default false" TO TL-CASE
     MOVE "gamerule reduced_debug_info" TO WS-LINE
     MOVE "commands.gamerule.query(reduced_debug_info,false)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table reduced_debug_info takes true or false only" TO TL-CASE
     MOVE "gamerule reduced_debug_info maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table respawn_radius is an integer rule with default 10" TO TL-CASE
     MOVE "gamerule respawn_radius" TO WS-LINE
     MOVE "commands.gamerule.query(respawn_radius,10)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table respawn_radius minimum 0" TO TL-CASE
     MOVE "gamerule respawn_radius -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table send_command_feedback is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule send_command_feedback" TO WS-LINE
     MOVE "commands.gamerule.query(send_command_feedback,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table send_command_feedback takes true or false only" TO TL-CASE
     MOVE "gamerule send_command_feedback maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table show_advancement_messages is a boolean rule with default tr" & "ue" TO TL-CASE
     MOVE "gamerule show_advancement_messages" TO WS-LINE
     MOVE "commands.gamerule.query(show_advancement_messages,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table show_advancement_messages takes true or false only" TO TL-CASE
     MOVE "gamerule show_advancement_messages maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table show_death_messages is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule show_death_messages" TO WS-LINE
     MOVE "commands.gamerule.query(show_death_messages,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table show_death_messages takes true or false only" TO TL-CASE
     MOVE "gamerule show_death_messages maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawner_blocks_work is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule spawner_blocks_work" TO WS-LINE
     MOVE "commands.gamerule.query(spawner_blocks_work,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawner_blocks_work takes true or false only" TO TL-CASE
     MOVE "gamerule spawner_blocks_work maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_mobs is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule spawn_mobs" TO WS-LINE
     MOVE "commands.gamerule.query(spawn_mobs,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_mobs takes true or false only" TO TL-CASE
     MOVE "gamerule spawn_mobs maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_monsters is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule spawn_monsters" TO WS-LINE
     MOVE "commands.gamerule.query(spawn_monsters,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_monsters takes true or false only" TO TL-CASE
     MOVE "gamerule spawn_monsters maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_patrols is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule spawn_patrols" TO WS-LINE
     MOVE "commands.gamerule.query(spawn_patrols,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_patrols takes true or false only" TO TL-CASE
     MOVE "gamerule spawn_patrols maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_phantoms is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule spawn_phantoms" TO WS-LINE
     MOVE "commands.gamerule.query(spawn_phantoms,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_phantoms takes true or false only" TO TL-CASE
     MOVE "gamerule spawn_phantoms maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_wandering_traders is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule spawn_wandering_traders" TO WS-LINE
     MOVE "commands.gamerule.query(spawn_wandering_traders,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_wandering_traders takes true or false only" TO TL-CASE
     MOVE "gamerule spawn_wandering_traders maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_wardens is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule spawn_wardens" TO WS-LINE
     MOVE "commands.gamerule.query(spawn_wardens,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spawn_wardens takes true or false only" TO TL-CASE
     MOVE "gamerule spawn_wardens maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spectators_generate_chunks is a boolean rule with default t" & "rue" TO TL-CASE
     MOVE "gamerule spectators_generate_chunks" TO WS-LINE
     MOVE "commands.gamerule.query(spectators_generate_chunks,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spectators_generate_chunks takes true or false only" TO TL-CASE
     MOVE "gamerule spectators_generate_chunks maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spread_vines is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule spread_vines" TO WS-LINE
     MOVE "commands.gamerule.query(spread_vines,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table spread_vines takes true or false only" TO TL-CASE
     MOVE "gamerule spread_vines maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table tnt_explodes is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule tnt_explodes" TO WS-LINE
     MOVE "commands.gamerule.query(tnt_explodes,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table tnt_explodes takes true or false only" TO TL-CASE
     MOVE "gamerule tnt_explodes maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table tnt_explosion_drop_decay is a boolean rule with default fal" & "se" TO TL-CASE
     MOVE "gamerule tnt_explosion_drop_decay" TO WS-LINE
     MOVE "commands.gamerule.query(tnt_explosion_drop_decay,false)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table tnt_explosion_drop_decay takes true or false only" TO TL-CASE
     MOVE "gamerule tnt_explosion_drop_decay maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table universal_anger is a boolean rule with default false" TO TL-CASE
     MOVE "gamerule universal_anger" TO WS-LINE
     MOVE "commands.gamerule.query(universal_anger,false)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table universal_anger takes true or false only" TO TL-CASE
     MOVE "gamerule universal_anger maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table water_source_conversion is a boolean rule with default true" TO TL-CASE
     MOVE "gamerule water_source_conversion" TO WS-LINE
     MOVE "commands.gamerule.query(water_source_conversion,true)" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table water_source_conversion takes true or false only" TO TL-CASE
     MOVE "gamerule water_source_conversion maybe" TO WS-LINE
     MOVE "parsing.bool.invalid(maybe) |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-OPAL TL-CASE WS-LINE WS-EXPECTED
     MOVE "acceptance US13 gamerule table a player without permission level 2 does not know it" TO TL-CASE
     MOVE "gamerule pvp" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TA-CHECK" USING WS-ID-ALICE TL-CASE WS-LINE WS-EXPECTED
     GOBACK.
 END PROGRAM TEST-CMD-GAMERULES.

 COPY CORETEST.
 COPY CMDTEST.
 COPY CMDTESTA.
