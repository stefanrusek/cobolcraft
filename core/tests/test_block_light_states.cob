*> Implementation test of the block light table of the standard set (lane bugtorch T30010; docs/protocol/24 parts 2, 3, 7 and 8, the light column and the light notes of each row): the light
*> every state of the state-dependent emitters gives off, read from CB-S-LIGHT of the state that BLOCKS-STATE-OF names (a state is named by all of its properties). Redstone torches, redstone ore,
*> smokers, blast furnaces, campfires, candles, copper bulbs, sea pickles, respawn anchors, cave vines, light blocks, trial spawners and vaults all emit by their state; a furnace only when lit.
*> Skipped as a pass without the generated packs (CC_GENERATED_DIR, default /tmp/cc-test/generated).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCK-LIGHT-STATES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1100).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-STATE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-ROWS.
    05 FILLER PIC X(32) VALUE "torch".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC X(32) VALUE "soul_torch".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(32) VALUE "copper_torch".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC X(32) VALUE "wall_torch".
    05 FILLER PIC X(100) VALUE "facing=east".
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC X(32) VALUE "soul_wall_torch".
    05 FILLER PIC X(100) VALUE "facing=east".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(32) VALUE "copper_wall_torch".
    05 FILLER PIC X(100) VALUE "facing=east".
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC X(32) VALUE "redstone_torch".
    05 FILLER PIC X(100) VALUE "lit=true".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(32) VALUE "redstone_torch".
    05 FILLER PIC X(100) VALUE "lit=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "redstone_wall_torch".
    05 FILLER PIC X(100) VALUE "facing=north,lit=true".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(32) VALUE "redstone_wall_torch".
    05 FILLER PIC X(100) VALUE "facing=west,lit=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "furnace".
    05 FILLER PIC X(100) VALUE "facing=north,lit=true".
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC X(32) VALUE "furnace".
    05 FILLER PIC X(100) VALUE "facing=south,lit=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "smoker".
    05 FILLER PIC X(100) VALUE "facing=north,lit=true".
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC X(32) VALUE "smoker".
    05 FILLER PIC X(100) VALUE "facing=south,lit=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "blast_furnace".
    05 FILLER PIC X(100) VALUE "facing=north,lit=true".
    05 FILLER PIC 99 VALUE 13.
    05 FILLER PIC X(32) VALUE "blast_furnace".
    05 FILLER PIC X(100) VALUE "facing=south,lit=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "redstone_ore".
    05 FILLER PIC X(100) VALUE "lit=true".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(32) VALUE "redstone_ore".
    05 FILLER PIC X(100) VALUE "lit=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "deepslate_redstone_ore".
    05 FILLER PIC X(100) VALUE "lit=true".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(32) VALUE "deepslate_redstone_ore".
    05 FILLER PIC X(100) VALUE "lit=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "campfire".
    05 FILLER PIC X(100) VALUE "facing=north,lit=true,signal_fire=false,waterlogged=false".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "campfire".
    05 FILLER PIC X(100) VALUE "facing=east,lit=false,signal_fire=false,waterlogged=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "soul_campfire".
    05 FILLER PIC X(100) VALUE "facing=north,lit=true,signal_fire=false,waterlogged=false".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(32) VALUE "soul_campfire".
    05 FILLER PIC X(100) VALUE "facing=east,lit=false,signal_fire=false,waterlogged=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "redstone_lamp".
    05 FILLER PIC X(100) VALUE "lit=true".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "redstone_lamp".
    05 FILLER PIC X(100) VALUE "lit=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "candle".
    05 FILLER PIC X(100) VALUE "candles=1,lit=true,waterlogged=false".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(32) VALUE "candle".
    05 FILLER PIC X(100) VALUE "candles=4,lit=true,waterlogged=false".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(32) VALUE "red_candle".
    05 FILLER PIC X(100) VALUE "candles=3,lit=true,waterlogged=true".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(32) VALUE "candle".
    05 FILLER PIC X(100) VALUE "candles=2,lit=false,waterlogged=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "candle_cake".
    05 FILLER PIC X(100) VALUE "lit=true".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(32) VALUE "candle_cake".
    05 FILLER PIC X(100) VALUE "lit=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "black_candle_cake".
    05 FILLER PIC X(100) VALUE "lit=true".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(32) VALUE "copper_bulb".
    05 FILLER PIC X(100) VALUE "lit=true,powered=false".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "exposed_copper_bulb".
    05 FILLER PIC X(100) VALUE "lit=true,powered=false".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(32) VALUE "weathered_copper_bulb".
    05 FILLER PIC X(100) VALUE "lit=true,powered=false".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(32) VALUE "oxidized_copper_bulb".
    05 FILLER PIC X(100) VALUE "lit=true,powered=false".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "waxed_copper_bulb".
    05 FILLER PIC X(100) VALUE "lit=true,powered=false".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "waxed_exposed_copper_bulb".
    05 FILLER PIC X(100) VALUE "lit=true,powered=false".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(32) VALUE "waxed_weathered_copper_bulb".
    05 FILLER PIC X(100) VALUE "lit=true,powered=false".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(32) VALUE "waxed_oxidized_copper_bulb".
    05 FILLER PIC X(100) VALUE "lit=true,powered=false".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "copper_bulb".
    05 FILLER PIC X(100) VALUE "lit=false,powered=true".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "oxidized_copper_bulb".
    05 FILLER PIC X(100) VALUE "lit=false,powered=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "sea_pickle".
    05 FILLER PIC X(100) VALUE "pickles=1,waterlogged=true".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(32) VALUE "sea_pickle".
    05 FILLER PIC X(100) VALUE "pickles=4,waterlogged=true".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "sea_pickle".
    05 FILLER PIC X(100) VALUE "pickles=3,waterlogged=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "respawn_anchor".
    05 FILLER PIC X(100) VALUE "charges=0".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "respawn_anchor".
    05 FILLER PIC X(100) VALUE "charges=1".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(32) VALUE "respawn_anchor".
    05 FILLER PIC X(100) VALUE "charges=2".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(32) VALUE "respawn_anchor".
    05 FILLER PIC X(100) VALUE "charges=3".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(32) VALUE "respawn_anchor".
    05 FILLER PIC X(100) VALUE "charges=4".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "cave_vines".
    05 FILLER PIC X(100) VALUE "age=0,berries=true".
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC X(32) VALUE "cave_vines".
    05 FILLER PIC X(100) VALUE "age=25,berries=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "cave_vines_plant".
    05 FILLER PIC X(100) VALUE "berries=true".
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC X(32) VALUE "cave_vines_plant".
    05 FILLER PIC X(100) VALUE "berries=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "light".
    05 FILLER PIC X(100) VALUE "level=0,waterlogged=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "light".
    05 FILLER PIC X(100) VALUE "level=7,waterlogged=false".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(32) VALUE "light".
    05 FILLER PIC X(100) VALUE "level=15,waterlogged=false".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "trial_spawner".
    05 FILLER PIC X(100) VALUE "ominous=false,trial_spawner_state=inactive".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "trial_spawner".
    05 FILLER PIC X(100) VALUE "ominous=false,trial_spawner_state=waiting_for_players".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "trial_spawner".
    05 FILLER PIC X(100) VALUE "ominous=false,trial_spawner_state=active".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(32) VALUE "trial_spawner".
    05 FILLER PIC X(100) VALUE "ominous=false,trial_spawner_state=waiting_for_reward_ejection".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(32) VALUE "trial_spawner".
    05 FILLER PIC X(100) VALUE "ominous=false,trial_spawner_state=ejecting_reward".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(32) VALUE "trial_spawner".
    05 FILLER PIC X(100) VALUE "ominous=false,trial_spawner_state=cooldown".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "vault".
    05 FILLER PIC X(100) VALUE "facing=north,ominous=false,vault_state=inactive".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(32) VALUE "vault".
    05 FILLER PIC X(100) VALUE "facing=north,ominous=false,vault_state=active".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(32) VALUE "vault".
    05 FILLER PIC X(100) VALUE "facing=north,ominous=false,vault_state=unlocking".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(32) VALUE "vault".
    05 FILLER PIC X(100) VALUE "facing=north,ominous=false,vault_state=ejecting".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(32) VALUE "glow_lichen".
    05 FILLER PIC X(100) VALUE "down=false,east=false,north=false,south=false,up=false,waterlogged=false,west=false".
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "glow_lichen".
    05 FILLER PIC X(100) VALUE "down=false,east=false,north=false,south=false,up=true,waterlogged=false,west=false".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(32) VALUE "lantern".
    05 FILLER PIC X(100) VALUE "hanging=false,waterlogged=false".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "soul_lantern".
    05 FILLER PIC X(100) VALUE "hanging=true,waterlogged=false".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(32) VALUE "end_rod".
    05 FILLER PIC X(100) VALUE "facing=up".
    05 FILLER PIC 99 VALUE 14.
    05 FILLER PIC X(32) VALUE "sea_lantern".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "glowstone".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "jack_o_lantern".
    05 FILLER PIC X(100) VALUE "facing=north".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "magma_block".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(32) VALUE "crying_obsidian".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(32) VALUE "shroomlight".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "ochre_froglight".
    05 FILLER PIC X(100) VALUE "axis=y".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "sculk_catalyst".
    05 FILLER PIC X(100) VALUE "bloom=false".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(32) VALUE "enchanting_table".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(32) VALUE "ender_chest".
    05 FILLER PIC X(100) VALUE "facing=north,waterlogged=false".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(32) VALUE "nether_portal".
    05 FILLER PIC X(100) VALUE "axis=x".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(32) VALUE "beacon".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "conduit".
    05 FILLER PIC X(100) VALUE "waterlogged=false".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "lava".
    05 FILLER PIC X(100) VALUE "level=0".
    05 FILLER PIC 99 VALUE 15.
    05 FILLER PIC X(32) VALUE "soul_fire".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(32) VALUE "amethyst_cluster".
    05 FILLER PIC X(100) VALUE "facing=up,waterlogged=false".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(32) VALUE "large_amethyst_bud".
    05 FILLER PIC X(100) VALUE "facing=up,waterlogged=false".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(32) VALUE "stone".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 0.
    05 FILLER PIC X(32) VALUE "oak_planks".
    05 FILLER PIC X(100) VALUE SPACES.
    05 FILLER PIC 99 VALUE 0.
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 92 TIMES.
       10 WS-R-KEY         PIC X(32).
       10 WS-R-PAIRS       PIC X(100).
       10 WS-R-LIGHT       PIC 99.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "block light states no generated packs here, skipped" TO TL-CASE
         MOVE "ok" TO TL-EXPECTED
         MOVE "ok" TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     CALL "BLOCKS-OPEN"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 92
         MOVE SPACES TO WS-KEY WS-PAIRS
         MOVE WS-R-KEY(WS-I) TO WS-KEY
         MOVE WS-R-PAIRS(WS-I) TO WS-PAIRS
         CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
         MOVE SPACES TO TL-CASE
         STRING "block light states " FUNCTION TRIM(WS-R-KEY(WS-I)) " " FUNCTION TRIM(WS-R-PAIRS(WS-I)) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-R-LIGHT(WS-I) TO WS-ED
         MOVE FUNCTION TRIM(WS-ED) TO TL-EXPECTED
         MOVE SPACES TO TL-OBSERVED
         IF WS-STATE = 0 AND WS-R-PAIRS(WS-I) NOT = SPACES
             MOVE "no such state" TO TL-OBSERVED
         ELSE
             MOVE CB-S-LIGHT(WS-STATE + 1) TO WS-ED
             MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-BLOCK-LIGHT-STATES.
