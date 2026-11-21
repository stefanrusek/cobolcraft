*> Block entity state (docs/protocol/31-block-entities-1-shared-model-and-containers.md §2, §8 to §13; core/src/be-31-1.cob);
*> EXTERNAL, one entry per live block entity (BE-USED 1), addressed by its index 1 to BE-MAX. BE-DIM 0 is a detached entity
*> (no level). The slots of the container types (27) hold item id, count and the patch handle of CSTACK.cpy; BE-NAME is a
*> custom name (plain text), BE-LOCK the item key of the lock predicate, BE-LOOT/BE-SEED the loot table and its seed.
*> BE-OPEN-* is the opener counter (section 8.2; the range in thousandths of a block), BE-STATUS/BE-PROGRESS the shulker box
*> animation (section 13), BE-LID/BE-LID-OLD/BE-SHOULD-OPEN the lid controller of the chest and ender chest (section 10.3).
 78 BE-MAX                VALUE 512.
 01 CORE-BE EXTERNAL.
    05 BE-ENTRY OCCURS 512 TIMES.
       10 BE-USED           BINARY-LONG.
       10 BE-DIM            BINARY-LONG.
       10 BE-X              BINARY-LONG.
       10 BE-Y              BINARY-LONG.
       10 BE-Z              BINARY-LONG.
       10 BE-TYPE           BINARY-LONG.
       10 BE-REMOVED        BINARY-LONG.
       10 BE-CHANGED        BINARY-LONG.
       10 BE-NAME-LENGTH    BINARY-LONG.
       10 BE-NAME           PIC X(64).
       10 BE-LOCK-LENGTH    BINARY-LONG.
       10 BE-LOCK           PIC X(48).
       10 BE-LOOT-LENGTH    BINARY-LONG.
       10 BE-LOOT           PIC X(64).
       10 BE-SEED           BINARY-DOUBLE SIGNED.
       10 BE-OPEN-COUNT     BINARY-LONG.
       10 BE-OPEN-RANGE     BINARY-LONG.
       10 BE-STATUS         BINARY-LONG.
       10 BE-PROGRESS       FLOAT-SHORT.
       10 BE-PROGRESS-OLD   FLOAT-SHORT.
       10 BE-LID            FLOAT-SHORT.
       10 BE-LID-OLD        FLOAT-SHORT.
       10 BE-SHOULD-OPEN    BINARY-LONG.
       10 BE-F-COOK         BINARY-LONG.            *> furnace family (31-2 section 3.2): cooking_time_spent, cooking_total_time,
       10 BE-F-COOK-TOTAL   BINARY-LONG.            *> lit_time_remaining, lit_total_time, speed_multiplier, RecipesUsed (recipe rows of RC-STORE and counts)
       10 BE-F-LIT          BINARY-LONG.
       10 BE-F-LIT-TOTAL    BINARY-LONG.
       10 BE-F-SPEED        FLOAT-SHORT.
       10 BE-F-USED OCCURS 4 TIMES.
          15 BE-F-USED-ROW   BINARY-LONG.
          15 BE-F-USED-COUNT BINARY-LONG.
       10 BE-OUTPUT         BINARY-LONG.            *> comparator OutputSignal (31-2 section 8)
       10 BE-COOLDOWN       BINARY-LONG.            *> hopper TransferCooldown (31-2 section 5.2) and chiseled bookshelf last_interacted_slot (10.1), -1 when fresh
       10 BE-SLOT OCCURS 27 TIMES.
          15 BE-SLOT-ITEM   BINARY-LONG.
          15 BE-SLOT-COUNT  BINARY-LONG.
          15 BE-SLOT-VAR    BINARY-LONG.
*> Data of the types of parts 31-3 to 31-5 (be-31-3.cob, be-31-4.cob, be-31-5.cob; BEX-DEFAULTS sets the defaults); the roles of the cells by type:
*>   sign, hanging sign (7, 8): XI 1 waxed, 2 allow_op_features, 3 editor set; side s (1 front, 2 back), b = 4 + 10 (s - 1): XI b colour id, b + 1 glowing,
*>        b + 2..b + 5 line lengths, b + 6..b + 9 filtered line lengths; XT 8 (s - 1) + 1..4 the lines, + 5..8 the filtered lines; XT 17 the editor's UUID
*>   banner (20): XI 1 layer count, XI 2.. dye ids of the layers; XT 1.. pattern ids. skull (16): XT 1 profile name, 2 note_block_sound, 4 profile id; XI 1 name
*>        length, 2 sound length, 3 profile id set, 4 animationTickCount, 5 isAnimating. decorated pot (41): XT 1..4 sherds back, left, right, front, XI 1..4 lengths,
*>        the item is slot 1. shelf (39): slots 1..3, XI 1 align_items_to_bottom
*>   campfire (32): slots 1..4, XI 1..4 cookingProgress, 5..8 cookingTime. lectern (29): slot 1 book, XI 1 page, 2 pageCount. jukebox (4): slot 1 record, XI 1 ticks,
*>        2 song playing, 3 song id. bell (30): XI 1 ticks, 2 shaking, 3 clickDirection (-1 none), 4 resonating, 5 resonationTicks, 6 lastRingTimestamp.
*>   enchanting table (13): XF 1 flip, 2 oFlip, 3 flipT, 4 flipA, 5 open, 6 oOpen, 7 rot, 8 oRot, 9 tRot; XI 1 time. brushable (40): XI 1 brushCount, 2 resets at,
*>        3 cooldown ends at, 4 hitDirection (-1 none), the item is slot 1. beehive (33): XI 1..4 flower_pos set and x, y, z, 5 bee count, bee i at 6 + 4 (i - 1):
*>        ticks_in_hive, min_ticks_in_hive, HasNectar, id length; XT i the entity id
*>   beacon (15): XT 1, 2 primary and secondary effect keys, XI 1, 2 their lengths, 3 levels, 4 lastCheckY, 5 section count, section i at 6 + 2 (i - 1): colour, height.
*>        conduit (25): XI 1 tickCount, 2 isActive, 3 isHunting, 4 frame block count, 5 nextAmbientSoundActivation, 6 target set, 7..10 the target UUID as 4 ints.
*>        end gateway (22): XI 1 Age, 2 exit_portal set, 3..5 x, y, z, 6 ExactTeleport, 7 teleportCooldown. creaking heart (10): XI 1 link set, 2 ticksExisted, 3 ticker,
*>        4 emitter, 5 outputSignal, 6..9 the UUID as 4 ints
*>   crafter (42): slots 1..9, XI 1 crafting_ticks_remaining, 2 triggered, 3..11 slot disabled. brewing stand (12): slots 1..5, XI 1 BrewTime, 2 total_brew_time,
*>        3 Fuel, 4 total_fuel, 6 remembered ingredient item, 7..9 bottle flags; XF 1 speed_multiplier
       10 BE-XI             BINARY-LONG OCCURS 64 TIMES.
       10 BE-XT             PIC X(64) OCCURS 20 TIMES.
       10 BE-XF             FLOAT-SHORT OCCURS 12 TIMES.
       10 BE-TIME2          BINARY-DOUBLE SIGNED.
       10 BE-XD             FLOAT-LONG OCCURS 8 TIMES.
       10 BE-UUID           BINARY-LONG OCCURS 640 TIMES.
       10 BE-CMD-LENGTH     BINARY-LONG.
       10 BE-CMD            PIC X(256).
*> Data of the types of parts 31-6 to 31-8 (be-31-6.cob, be-31-7.cob, be-31-8.cob; BEX-DEFAULTS sets the defaults). BE-CMD holds the command of a command block (the first 256 bytes).
*>   command block (23): XI 1 powered, 2 conditionMet, 3 auto, 4 successCount, 5 trackOutput, 6 lastOutput length, 7 updateLastExecution; XT 1 lastOutput; BE-SEED lastExecution (-1 never); BE-NAME the custom name
*>   structure block (21): XI 1..3 posX..Z, 4..6 sizeX..Z, 7 rotation, 8 mirror, 9 mode (0 SAVE, 1 LOAD, 2 CORNER, 3 DATA), 10 ignoreEntities, 11 strict, 12 powered, 13 showAir, 14 showBoundingBox,
*>        20, 21, 22 lengths of name, author, metadata; XT 1..3 those texts; XF 1 integrity; BE-SEED the seed. jigsaw (31): XI 1..4 lengths of name, target, pool, final_state, 5 joint (0 rollable,
*>        1 aligned), 6 placement priority, 7 selection priority, 8 front direction; XT 1..4. test block (45): XI 1 mode, 2 message length, 3 powered, 4 triggered; XT 1 message.
*>        test instance block (46): XI 1 test key length, 2..4 size, 5 rotation, 6 ignore_entities, 7 status, 8 error message length, 9 marker count, marker i (up to 4): XI 10 + 3 (i - 1).. x, y, z,
*>        XI 22 + i text length; XT 1 test, 2 error message, 2 + i marker text
*>   mob spawner (9): XI 1..7 Delay, MinSpawnDelay, MaxSpawnDelay, SpawnCount, MaxNearbyEntities, RequiredPlayerRange, SpawnRange; XI 8 SpawnData set, XT 1 its entity id, XI 9 the id length,
*>        XI 10..13 block light min, max, sky light min, max, XI 14 custom_spawn_rules set; XI 15 potentials count (0 = the default list), entry i (up to 8): XT 1 + i the entity id, XI 19 + i its
*>        length, XI 29 + i the weight. trial spawner (43): XI 1 registered players (UUIDs in BE-UUID 1..64), XI 2 current mobs (BE-UUID 65..320), XI 3 total_mobs_spawned, XI 4 spawn_data set,
*>        XT 1 its id, XI 5 the length, XI 6 ejecting_loot_table length, XT 2 the table, XI 7, 8 lengths of normal_config, ominous_config (XT 3, 4), XI 9 target_cooldown_length (36000),
*>        XI 10 required_player_range (14), XI 11 the config read failed, XI 12..15 and 16 the light limits and their set flag of spawn_data; BE-SEED cooldown_ends_at, BE-TIME2 next_mob_spawns_at.
*>        vault (44): XT 1 key_item id, XI 1 its length, XI 2 its count; XT 2 loot_table, XI 4 length; XT 3 override_loot_table_to_display, XI 5 length; XD 1 activation_range, 2 deactivation_range,
*>        3 connected_particles_range; XT 4 display item id, XI 6 length, XI 7 count; XI 8 connected players (BE-UUID 513..640); XI 25 rewarded players (BE-UUID 1..512, at most 128);
*>        XT 5..12 the items to eject (XI 59 their count, counts in BE-SLOT-COUNT 1..8, XI 60 total_ejections_needed, not saved); BE-SEED state_updating_resumes_at, BE-TIME2 lastInsertFailTimestamp
*>        (not saved); XI 61 shared data dirty, XI 62 server data dirty
*>   sculk sensor (34), calibrated sculk sensor (35), sculk shrieker (37): XI 1 last_vibration_frequency (warning_level of the shrieker); the vibration data of 31-8 section 3.4: XI 2 a vibration is in
*>        flight, XT 1 its game event key (XI 3 length), XF 1 distance, XD 1..3 position, XI 4 source UUID set (BE-UUID 1..4), XI 5 projectile owner set (BE-UUID 5..8), XI 6 travel time (event_delay);
*>        the selector: XI 7 a candidate is held, XT 2 its key (XI 8 length), XF 2 distance, XD 4..6 position, XI 9 source set (BE-UUID 9..12), XI 10 owner set (BE-UUID 13..16), BE-SEED its tick;
*>        XI 11 reloadVibrationParticle. sculk catalyst (36): XI 1 cursor count (at most 32), cursor i at BE-UUID 7 (i - 1) + 1..7: x, y, z, charge, decay_delay, update_delay, facings (-1 absent, else a
*>        bit mask of the six directions). potent sulfur (48): XI 1 countdown (-1), BE-TIME2 eruptionTick (-1, not saved)
*> The ender chest storage of each player (31-1 section 11, 45-3 section 5): one detached CORE-BE entity (dimension 0, type ender chest)
*> per player UUID, created on the first open or when the player file is read, and kept while the world is open.
 78 ENDER-MAX             VALUE 64.
 01 CORE-ENDER EXTERNAL.
    05 ENDER-ENTRY OCCURS 64 TIMES.
       10 ENDER-USED        BINARY-LONG.
       10 ENDER-UUID        PIC X(16).
       10 ENDER-BE          BINARY-LONG.
*> The shulker box being placed (31-1 section 13.4): BE-PLACE-STATE notes the patch of the held stack and the position, and BE-BLOCK-SET gives the new
*> entity the container component of that patch (BE-SHULKER-RESTORE).
 01 CORE-BE-PENDING EXTERNAL.
    05 BP-SET               BINARY-LONG.
    05 BP-DIM               BINARY-LONG.
    05 BP-X                 BINARY-LONG.
    05 BP-Y                 BINARY-LONG.
    05 BP-Z                 BINARY-LONG.
    05 BP-VAR               BINARY-LONG.
