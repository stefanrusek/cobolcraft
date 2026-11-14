*> The registry sources behind CONTENT-REGISTRY-COUNT and CONTENT-REGISTRY-ENTRY for registries that are not among the
*> 51 loaded world registries (T0281; content-api section 2; docs/protocol/15-commands-framework.md 6.7 and
*> 16-commands-catalog.md 13: the registries the argument types of the commands complete against). A source answers
*> the same questions as a loaded registry (count; key of an id in id order) for both content sets:
*>   block, item, entity_type  the rows of the set (generated tables, or the built-in layer of the cobolcraft set);
*>   the static registries of 46 (mob_effect, attribute, particle_type, sound_event, potion, game_event, ...)
*>                             the vanilla numbering in both sets (world-types WT-9);
*>   game_rule                 the rules of 16 section 13, both sets;
*>   the synchronized registries of the cobolcraft set (cobolcraft-standard-core.md sections 2 and 3: 3 biomes, 8 chat
*>   types, 13 variant placeholders, 2 dimension types, 52 damage types, 1 enchantment, 1 clock, 2 timelines): keys
*>   only, and every other world registry of the 51 is empty (count 0, CT-OK).
*> Entries of a source carry no payload (length 0). The cobolcraft synchronized registries are the exception:
*> CONTENT-REGISTRY-ENTRY asks the built-in entries (builtin-registry.cob) first, and the keys here fix their order.
*> Keys carry their namespace: a generated row key without one is "minecraft:" plus the key.
*>
*> DOCUMENTED ASSUMPTIONS (no document states them):
*>  A1. The id of a game rule is its position in the table of 16 section 13 (the document gives no registration
*>      order and 46 has no game_rule table).
*>  A2. The registries that the reloadable layer owns (recipe, advancement, loot_table, predicate, item_modifier)
*>      are not served here: their loaders (recipes.cob, later phases) own them, and CONTENT-OPEN does not load them.
*>  A3. A registry named with a namespace other than minecraft is unknown (the registry slot names are protocol
*>      vocabulary, standin section 0).
*>  A4. The static registries of the cobolcraft set are the same as the standard set's, as WT-9 says; game rules
*>      follow it.
*>  A5. Payload-free entries: the keys of the cobolcraft synchronized registries are listed without the entry data;
*>      the payloads of core section 3 come from builtin-registry.cob.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-GAME-RULE-AT.
*> USING registry name (PIC X(48), ignored: the caller asks for game_rule only), id (BINARY-LONG, 0 or more), key out
*> (PIC X(112), written when the id exists), count out (BINARY-LONG, 59). Rules of 16 section 13, table order (A1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RULES.
    05 FILLER PIC X(40) VALUE "advance_time".
    05 FILLER PIC X(40) VALUE "advance_weather".
    05 FILLER PIC X(40) VALUE "allow_entering_nether_using_portals".
    05 FILLER PIC X(40) VALUE "block_drops".
    05 FILLER PIC X(40) VALUE "block_explosion_drop_decay".
    05 FILLER PIC X(40) VALUE "command_blocks_work".
    05 FILLER PIC X(40) VALUE "command_block_output".
    05 FILLER PIC X(40) VALUE "drowning_damage".
    05 FILLER PIC X(40) VALUE "elytra_movement_check".
    05 FILLER PIC X(40) VALUE "ender_pearls_vanish_on_death".
    05 FILLER PIC X(40) VALUE "entity_drops".
    05 FILLER PIC X(40) VALUE "fall_damage".
    05 FILLER PIC X(40) VALUE "fire_damage".
    05 FILLER PIC X(40) VALUE "fire_spread_radius_around_player".
    05 FILLER PIC X(40) VALUE "forgive_dead_players".
    05 FILLER PIC X(40) VALUE "freeze_damage".
    05 FILLER PIC X(40) VALUE "global_sound_events".
    05 FILLER PIC X(40) VALUE "immediate_respawn".
    05 FILLER PIC X(40) VALUE "keep_inventory".
    05 FILLER PIC X(40) VALUE "lava_source_conversion".
    05 FILLER PIC X(40) VALUE "limited_crafting".
    05 FILLER PIC X(40) VALUE "locator_bar".
    05 FILLER PIC X(40) VALUE "log_admin_commands".
    05 FILLER PIC X(40) VALUE "max_block_modifications".
    05 FILLER PIC X(40) VALUE "max_command_forks".
    05 FILLER PIC X(40) VALUE "max_command_sequence_length".
    05 FILLER PIC X(40) VALUE "max_entity_cramming".
    05 FILLER PIC X(40) VALUE "max_minecart_speed".
    05 FILLER PIC X(40) VALUE "max_snow_accumulation_height".
    05 FILLER PIC X(40) VALUE "mob_drops".
    05 FILLER PIC X(40) VALUE "mob_explosion_drop_decay".
    05 FILLER PIC X(40) VALUE "mob_griefing".
    05 FILLER PIC X(40) VALUE "natural_health_regeneration".
    05 FILLER PIC X(40) VALUE "player_movement_check".
    05 FILLER PIC X(40) VALUE "players_nether_portal_creative_delay".
    05 FILLER PIC X(40) VALUE "players_nether_portal_default_delay".
    05 FILLER PIC X(40) VALUE "players_sleeping_percentage".
    05 FILLER PIC X(40) VALUE "projectiles_can_break_blocks".
    05 FILLER PIC X(40) VALUE "pvp".
    05 FILLER PIC X(40) VALUE "raids".
    05 FILLER PIC X(40) VALUE "random_tick_speed".
    05 FILLER PIC X(40) VALUE "reduced_debug_info".
    05 FILLER PIC X(40) VALUE "respawn_radius".
    05 FILLER PIC X(40) VALUE "send_command_feedback".
    05 FILLER PIC X(40) VALUE "show_advancement_messages".
    05 FILLER PIC X(40) VALUE "show_death_messages".
    05 FILLER PIC X(40) VALUE "spawner_blocks_work".
    05 FILLER PIC X(40) VALUE "spawn_mobs".
    05 FILLER PIC X(40) VALUE "spawn_monsters".
    05 FILLER PIC X(40) VALUE "spawn_patrols".
    05 FILLER PIC X(40) VALUE "spawn_phantoms".
    05 FILLER PIC X(40) VALUE "spawn_wandering_traders".
    05 FILLER PIC X(40) VALUE "spawn_wardens".
    05 FILLER PIC X(40) VALUE "spectators_generate_chunks".
    05 FILLER PIC X(40) VALUE "spread_vines".
    05 FILLER PIC X(40) VALUE "tnt_explodes".
    05 FILLER PIC X(40) VALUE "tnt_explosion_drop_decay".
    05 FILLER PIC X(40) VALUE "universal_anger".
    05 FILLER PIC X(40) VALUE "water_source_conversion".
 01 WS-RULE-TABLE REDEFINES WS-RULES.
    05 WS-RULE             PIC X(40) OCCURS 59 TIMES.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID L-KEY L-COUNT.
     MOVE 59 TO L-COUNT
     IF L-ID < 59
         COMPUTE WS-INDEX = L-ID + 1
         MOVE WS-RULE(WS-INDEX) TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM REGISTRY-GAME-RULE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-STATIC-AT.
*> Same parameters as REGISTRY-GAME-RULE-AT: the static registries of 46 (content/copy/gen/staticids.cpy), the key as
*> the table writes it (without namespace unless it has one, e.g. brigadier:bool); count -1 for a name the table does
*> not hold.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STATICIDS.
 01 WS-I                   BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-KEY-START           BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID L-KEY L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= GEN-STATIC-ROWS
         COMPUTE WS-START = WS-I * GEN-STATIC-ROW-WIDTH + 1
         IF GEN-STATIC-DATA(WS-START:GEN-STATIC-W-REGISTRY) = L-NAME
             IF L-COUNT = L-ID
                 COMPUTE WS-KEY-START = WS-START + GEN-STATIC-OFF-KEY
                 MOVE GEN-STATIC-DATA(WS-KEY-START:GEN-STATIC-W-KEY) TO L-KEY
             END-IF
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     IF L-COUNT = 0
         MOVE -1 TO L-COUNT
     END-IF
     GOBACK.
 END PROGRAM REGISTRY-STATIC-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-COBOLCRAFT-AT.
*> Same parameters as REGISTRY-GAME-RULE-AT: the synchronized registries of the cobolcraft set (keys in id order,
*> core sections 3.1 to 3.7 and standin 4.5), and 0 for each other of the 51 world registries (core section 2);
*> -1 for a name that is none of them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(72) VALUE "worldgen/biome                  minecraft:plains".
    05 FILLER PIC X(72) VALUE "worldgen/biome                  cobolcraft:upland".
    05 FILLER PIC X(72) VALUE "worldgen/biome                  cobolcraft:ash_flats".
    05 FILLER PIC X(72) VALUE "chat_type                       minecraft:chat".
    05 FILLER PIC X(72) VALUE "chat_type                       minecraft:emote_command".
    05 FILLER PIC X(72) VALUE "chat_type                       minecraft:msg_command_incoming".
    05 FILLER PIC X(72) VALUE "chat_type                       minecraft:msg_command_outgoing".
    05 FILLER PIC X(72) VALUE "chat_type                       cobolcraft:say".
    05 FILLER PIC X(72) VALUE "chat_type                       minecraft:say_command".
    05 FILLER PIC X(72) VALUE "chat_type                       minecraft:team_msg_command_incoming".
    05 FILLER PIC X(72) VALUE "chat_type                       minecraft:team_msg_command_outgoing".
    05 FILLER PIC X(72) VALUE "wolf_variant                    cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "wolf_sound_variant              cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "pig_variant                     cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "pig_sound_variant               cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "frog_variant                    cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "cat_variant                     cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "cat_sound_variant               cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "cow_sound_variant               cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "cow_variant                     cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "chicken_sound_variant           cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "chicken_variant                 cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "zombie_nautilus_variant         cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "painting_variant                cobolcraft:placeholder".
    05 FILLER PIC X(72) VALUE "dimension_type                  cobolcraft:surface".
    05 FILLER PIC X(72) VALUE "dimension_type                  cobolcraft:sunless".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:arrow".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:bad_respawn_point".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:cactus".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:campfire".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:cramming".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:dragon_breath".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:drown".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:dry_out".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:ender_pearl".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:explosion".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:fall".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:falling_anvil".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:falling_block".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:falling_stalactite".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:fireball".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:fireworks".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:fly_into_wall".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:freeze".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:generic".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:generic_kill".
    05 FILLER PIC X(72) VALUE "damage_type                     cobolcraft:hail".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:hot_floor".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:in_fire".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:in_wall".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:indirect_magic".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:lava".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:lightning_bolt".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:mace_smash".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:magic".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:mob_attack".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:mob_attack_no_aggro".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:mob_projectile".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:on_fire".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:out_of_world".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:outside_border".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:player_attack".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:player_explosion".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:sonic_boom".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:spear".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:spit".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:stalagmite".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:starve".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:sting".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:sulfur_cube_hot".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:sweet_berry_bush".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:thorns".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:thrown".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:trident".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:unattributed_fireball".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:wind_charge".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:wither".
    05 FILLER PIC X(72) VALUE "damage_type                     minecraft:wither_skull".
    05 FILLER PIC X(72) VALUE "enchantment                     minecraft:efficiency".
    05 FILLER PIC X(72) VALUE "world_clock                     minecraft:overworld".
    05 FILLER PIC X(72) VALUE "timeline                        minecraft:day".
    05 FILLER PIC X(72) VALUE "timeline                        minecraft:moon".
 01 WS-ROW-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 82 TIMES.
       10 WS-ROW-REGISTRY  PIC X(32).
       10 WS-ROW-KEY       PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-WORLD-NAME          PIC X(48).
 01 WS-WORLD-FLAG          PIC X.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID L-KEY L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 82
         IF WS-ROW-REGISTRY(WS-I) = L-NAME
             IF L-COUNT = L-ID
                 MOVE WS-ROW-KEY(WS-I) TO L-KEY
             END-IF
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     IF L-COUNT > 0
         GOBACK
     END-IF
     MOVE -1 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 51
         CALL "REGISTRY-NAME-AT" USING WS-I WS-WORLD-NAME WS-WORLD-FLAG
         IF WS-WORLD-NAME = L-NAME
             MOVE 0 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REGISTRY-COBOLCRAFT-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGISTRY-SOURCE-AT.
*> USING registry (PIC X(112), "minecraft:" optional), id (BINARY-LONG; -1 asks only for the count), key out (PIC X(112),
*> with namespace, written when the id exists), key length out (BINARY-LONG), count out (BINARY-LONG; 0 for an unknown
*> registry), status out (CT-OK; CT-NOT-FOUND for an unknown registry, or an id outside 0 to count - 1 with the count
*> given). Caller checks CT-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-FULL                PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-ASK                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-COLONS              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-BLOCK-VIEW REDEFINES WS-BLOCK-ROW.
    05 FILLER              PIC X(4).
    05 WS-B-KEY            PIC X(35).
    05 FILLER              PIC X(780).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-ITEM-VIEW REDEFINES WS-ITEM-ROW.
    05 FILLER              PIC X(4).
    05 WS-I-KEY            PIC X(38).
    05 FILLER              PIC X(228).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ENTITY-VIEW REDEFINES WS-ENTITY-ROW.
    05 FILLER              PIC X(3).
    05 WS-E-KEY            PIC X(22).
    05 FILLER              PIC X(41).
 01 WS-ROW-STATUS          BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY             PIC X(112).
 01 L-ID                   BINARY-LONG.
 01 L-KEY                  PIC X(112).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-ID L-KEY L-KEY-LENGTH L-COUNT L-STATUS.
     MOVE 0 TO L-COUNT L-KEY-LENGTH
     MOVE CT-NOT-FOUND TO L-STATUS
     MOVE L-REGISTRY TO WS-FULL
     IF WS-FULL(1:10) = "minecraft:"
         MOVE WS-FULL(11:54) TO WS-NAME
     ELSE
         MOVE WS-FULL TO WS-NAME
     END-IF
     MOVE 0 TO WS-COLONS
     INSPECT WS-NAME TALLYING WS-COLONS FOR ALL ":"
     IF WS-COLONS > 0
         GOBACK
     END-IF
     MOVE L-ID TO WS-ASK
     IF WS-ASK < 0
         MOVE 0 TO WS-ASK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE -1 TO WS-COUNT
     EVALUATE WS-NAME
         WHEN "block"
             CALL "BLOCK-ROW-AT" USING WS-ASK WS-BLOCK-ROW WS-ROW-STATUS WS-COUNT
             MOVE WS-B-KEY TO WS-KEY
         WHEN "item"
             CALL "ITEM-ROW-AT" USING WS-ASK WS-ITEM-ROW WS-ROW-STATUS WS-COUNT
             MOVE WS-I-KEY TO WS-KEY
         WHEN "entity_type"
             CALL "ENTITY-ROW-AT" USING WS-ASK WS-ENTITY-ROW WS-ROW-STATUS WS-COUNT
             MOVE WS-E-KEY TO WS-KEY
         WHEN "game_rule"
             CALL "REGISTRY-GAME-RULE-AT" USING WS-NAME WS-ASK WS-KEY WS-COUNT
         WHEN OTHER
             CALL "REGISTRY-STATIC-AT" USING WS-NAME WS-ASK WS-KEY WS-COUNT
             IF WS-COUNT < 0 AND CT-SET-TYPE = CT-TYPE-COBOLCRAFT
                 CALL "REGISTRY-COBOLCRAFT-AT" USING WS-NAME WS-ASK WS-KEY WS-COUNT
             END-IF
     END-EVALUATE
     IF WS-COUNT < 0
         GOBACK
     END-IF
     MOVE WS-COUNT TO L-COUNT
     IF L-ID < 0
         MOVE CT-OK TO L-STATUS
         GOBACK
     END-IF
     IF L-ID >= WS-COUNT
         GOBACK
     END-IF
     MOVE 0 TO WS-COLONS
     INSPECT WS-KEY TALLYING WS-COLONS FOR ALL ":"
     IF WS-COLONS = 0
         MOVE SPACES TO L-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO L-KEY
     ELSE
         MOVE WS-KEY TO L-KEY
     END-IF
     MOVE 0 TO L-KEY-LENGTH
     INSPECT L-KEY TALLYING L-KEY-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
     MOVE CT-OK TO L-STATUS
     GOBACK.
 END PROGRAM REGISTRY-SOURCE-AT.
