*> Acceptance test of CC-0012, the player half (docs/protocol/29b part 2 section 9.3 trampling, 9.4 turnToBaseBlock, 9.5 pushEntitiesUp, 14.7): a player who lands on farmland with a
*> fall distance d tramples it when one draw of the level random is below d - 0.5 (so never at 0.4, half of the landings at 1.0, three in four at 1.25, always from 1.5; the game rule mob_griefing does not stop a player), the farmland
*> becomes dirt, the player standing on the top of the farmland (15/16) is lifted onto the dirt by a Player Position, and the crop above loses its ground and breaks. The level random
*> is seeded for each case (java.util.Random: the first nextFloat of the seeds 1000003, 7000021, 2000006 is 0.3745, 0.5815, 0.9399, computed independently). Alice is a survival player
*> in a world of the standard set; every case is a landing on its own farmland cell.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFARMTRAMPLE-PLAYER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY BRWORLD.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Y1                  BINARY-LONG VALUE 101.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-PAIRS               PIC X(160).
 01 WS-KEY                 PIC X(112).
 01 WS-FARM                BINARY-LONG.
 01 WS-WHEAT               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-D                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-IDS                 PIC X(1024).
 01 WS-BKEY                PIC X(48).
 01 WS-BLEN                BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-HP                  PIC 99.
 01 WS-TP                  BINARY-LONG.
 01 WS-TP-D                PIC 9.
 01 WS-TICKS               BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE "farmland" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-FARM
     MOVE "wheat" TO WS-KEY
     MOVE "age=7" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WHEAT
*>   Nine farmland cells (x 20, 22, ... 36), each with a wheat crop above it.
     PERFORM VARYING WS-X FROM 20 BY 2 UNTIL WS-X > 36
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-FARM
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-WHEAT
     END-PERFORM
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS

     MOVE "acceptance CC-0012 given a survival player landing on farmland after a fall of 0.4 when the draw is 0.37 then the farmland stays (no trample at d <= 0.5)" TO TL-CASE
     MOVE 20 TO WS-X
     MOVE 0.4 TO WS-D
     MOVE 1000003 TO WS-SEED
     PERFORM LAND
     MOVE "farmland y 100938 tp 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given a landing after a fall of 1.0 when the draw is 0.37 (below 0.5) then the farmland becomes dirt and the player is lifted onto it by a Player Position" TO TL-CASE
     MOVE 22 TO WS-X
     MOVE 1.0 TO WS-D
     MOVE 1000003 TO WS-SEED
     PERFORM LAND
     MOVE "dirt y 101000 tp 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given a landing after a fall of 1.0 when the draw is 0.58 (not below 0.5) then the farmland stays" TO TL-CASE
     MOVE 24 TO WS-X
     MOVE 1.0 TO WS-D
     MOVE 7000021 TO WS-SEED
     PERFORM LAND
     MOVE "farmland y 100938 tp 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given a landing after a jump of 1.25 when the draw is 0.58 (below 0.75) then the farmland becomes dirt" TO TL-CASE
     MOVE 26 TO WS-X
     MOVE 1.25 TO WS-D
     MOVE 7000021 TO WS-SEED
     PERFORM LAND
     MOVE "dirt y 101000 tp 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given a landing after a fall of 1.25 when the draw is 0.94 (not below 0.75) then the farmland stays" TO TL-CASE
     MOVE 28 TO WS-X
     MOVE 1.25 TO WS-D
     MOVE 2000006 TO WS-SEED
     PERFORM LAND
     MOVE "farmland y 100938 tp 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given a landing after a fall of 4.0 when the draw is 0.94 then the farmland becomes dirt whatever the draw (d - 0.5 > 1) and the fall costs 1 health" TO TL-CASE
     MOVE 30 TO WS-X
     MOVE 4.0 TO WS-D
     MOVE 2000006 TO WS-SEED
     PERFORM LAND
     MOVE "dirt y 101000 tp 1 health 19" TO TL-EXPECTED
     PERFORM CHECK-HEALTH

     MOVE "acceptance CC-0012 given the farmland trampled by a fall of 2.0 then the wheat above it is gone once the block updates have run" TO TL-CASE
     MOVE 32 TO WS-X
     MOVE 2.0 TO WS-D
     MOVE 2000006 TO WS-SEED
     PERFORM LAND
     MOVE 5 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     COMPUTE WS-Y = 101
     CALL "IP-BLOCK-KEY" USING WS-DIM WS-X WS-Y WS-Z WS-BKEY WS-BLEN
     MOVE 100 TO WS-Y
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-BKEY) TO TL-OBSERVED
     MOVE "minecraft:air" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance CC-0012 given a creative player landing after a jump of 1.25 when the draw is 0.58 then the farmland becomes dirt as in vanilla (the fall distance is kept in creative)" TO TL-CASE
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 34 TO WS-X
     MOVE 1.25 TO WS-D
     MOVE 7000021 TO WS-SEED
     PERFORM LAND
     MOVE "dirt y 101000 tp 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given the game rule mob_griefing off when a survival player lands after a fall of 4.0 then the farmland becomes dirt (the rule stops mobs, not players; acc_bugfarmtrample_mobs)" TO TL-CASE
     MOVE 0 TO PL-MODE(WS-ROW)
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE 36 TO WS-X
     MOVE 4.0 TO WS-D
     MOVE 2000006 TO WS-SEED
     PERFORM LAND
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE "dirt y 101000 tp 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given a landing after a fall of 4.0 on a dirt path (the same 15/16 shape, no farmland) then the path stays and nothing is lifted" TO TL-CASE
     MOVE 38 TO WS-X
     MOVE "dirt_path" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 4.0 TO WS-D
     MOVE 2000006 TO WS-SEED
     PERFORM LAND
     MOVE "dirt_path y 100938 tp 0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> A landing of Alice on the farmland of cell x: she stands on it (feet at 100.9375), rises d, falls back; the level random is seeded before the last packet.
 LAND.
     CALL "TEST-ACCEPT-TELEPORT" USING WS-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     COMPUTE WS-FX = WS-X + 0.5
     MOVE 100.9375 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE
     COMPUTE WS-FY = 100.9375 + WS-D
     MOVE 0 TO WS-FLAGS
     PERFORM MOVE-ALICE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     CALL "LEVEL-RANDOM-SEED" USING WS-SEED
     MOVE 100.9375 TO WS-FY
     MOVE 1 TO WS-FLAGS
     PERFORM MOVE-ALICE.

 MOVE-ALICE.
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS.

 CHECK.
     PERFORM OBSERVE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 CHECK-HEALTH.
     PERFORM OBSERVE
     COMPUTE WS-HP = PL-HEALTH(WS-ROW)
     MOVE SPACES TO WS-IDS
     STRING FUNCTION TRIM(TL-OBSERVED) " health " WS-HP DELIMITED BY SIZE INTO WS-IDS
     MOVE WS-IDS TO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> "<farmland|dirt> y <milli> tp <1 when Player Position (id 73) was sent since the landing>": the observed text, asserted by CHECK.
 OBSERVE.
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     CALL "IP-BLOCK-KEY" USING WS-DIM WS-X WS-Y WS-Z WS-BKEY WS-BLEN
     COMPUTE WS-MILLI ROUNDED = PL-Y(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-EDIT
     MOVE 0 TO WS-TP
     INSPECT WS-IDS TALLYING WS-TP FOR ALL "73"
     IF WS-TP > 0
         MOVE 1 TO WS-TP
     END-IF
     MOVE WS-TP TO WS-TP-D
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-BKEY(11:)) " y " FUNCTION TRIM(WS-EDIT) " tp " WS-TP-D DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE.
 END PROGRAM ACC-BUGFARMTRAMPLE-PLAYER.

 COPY CORETEST.
