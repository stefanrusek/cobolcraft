*> Acceptance test of CC-0012, the mob half (docs/protocol/29b part 2 section 9.3 trampling, 9.4 turnToBaseBlock, 9.5 pushEntitiesUp, 14.7): a living entity that lands on farmland after a fall of
*> 2.5 blocks (d - 0.5 is above 1, so the draw does not matter) tramples it when the game rule mob_griefing is on and its box satisfies width x width x height > 0.512: a zombie (0.6 x 1.95),
*> a cow (0.9 x 1.4) and a villager (0.6 x 1.95) turn the cell into dirt and are lifted onto it (feet 100.9375 to 101.0). A chicken (0.4 x 0.7), a baby cow and a baby zombie (half size) never
*> do, an item never does, and with mob_griefing off a zombie does not either (the player half, acc_bugfarmtrample_player, shows the rule does not stop a player). Each mob falls onto its own
*> 5 x 5 patch of farmland (a mob that wanders on the patch does not change the count of the first landing, which is observed in the tick it lands).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFARMTRAMPLE-MOBS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY BRWORLD.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-PAIRS               PIC X(160).
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-FARM                BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG VALUE 24.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG VALUE 103.4375.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-VX                  FLOAT-LONG VALUE 0.
 01 WS-VY                  FLOAT-LONG VALUE 0.
 01 WS-VZ                  FLOAT-LONG VALUE 0.
 01 WS-IID                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 40.
 01 WS-BKEY                PIC X(48).
 01 WS-BLEN                BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-TICKS               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ND                 PIC 99.
 01 WS-LANDED              BINARY-LONG.
 01 WS-BABY                BINARY-LONG VALUE 0.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "farmland" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-FARM
     MOVE "dirt" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-DIRT
     MOVE 18000 TO CW-TIME
     MOVE 1 TO BW-DIFFICULTY
     MOVE "N" TO TL-MODE

     MOVE "acceptance CC-0012 given a zombie falling 2.5 blocks onto farmland when mob_griefing is on then the cell becomes dirt and the zombie stands on it" TO TL-CASE
     MOVE 4 TO WS-X0
     MOVE "zombie" TO WS-KEY
     PERFORM FALL
     MOVE "dirt 01 y 101000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given a cow falling 2.5 blocks onto farmland then the cell becomes dirt and the cow stands on it" TO TL-CASE
     MOVE 12 TO WS-X0
     MOVE "cow" TO WS-KEY
     PERFORM FALL
     MOVE "dirt 01 y 101000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given a villager falling 2.5 blocks onto farmland then the cell becomes dirt and the villager stands on it" TO TL-CASE
     MOVE 20 TO WS-X0
     MOVE "villager" TO WS-KEY
     PERFORM FALL
     MOVE "dirt 01 y 101000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given a chicken (0.4 x 0.7, below the size threshold) falling 2.5 blocks onto farmland then the farmland stays" TO TL-CASE
     MOVE 28 TO WS-X0
     MOVE "chicken" TO WS-KEY
     PERFORM FALL
     MOVE "dirt 00 y 100938" TO TL-EXPECTED
     PERFORM CHECK

     ADD 8 TO WS-Z0
     MOVE "acceptance CC-0012 given a baby cow (half size) falling 2.5 blocks onto farmland then the farmland stays" TO TL-CASE
     MOVE 4 TO WS-X0
     MOVE "cow" TO WS-KEY
     MOVE 1 TO WS-BABY
     PERFORM FALL
     MOVE "dirt 00 y 100938" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given a baby zombie (half size) falling 2.5 blocks onto farmland then the farmland stays" TO TL-CASE
     MOVE 12 TO WS-X0
     MOVE "zombie" TO WS-KEY
     PERFORM FALL
     MOVE "dirt 00 y 100938" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 0 TO WS-BABY

     MOVE "acceptance CC-0012 given a dropped item landing on farmland (it rests on it at 100.9375) then the farmland stays (an item is no LivingEntity)" TO TL-CASE
     MOVE 20 TO WS-X0
     PERFORM PATCH
     MOVE "stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-IID WS-ITEM-ROW WS-STATUS
     COMPUTE WS-FX = WS-X0 + 0.5
     COMPUTE WS-FZ = WS-Z0 + 0.5
     CALL "GI-SPAWN" USING WS-DIM WS-FX WS-FY WS-FZ WS-VX WS-VY WS-VZ WS-IID WS-COUNT WS-DELAY WS-ROW
     MOVE 30 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE "dirt 00 y 100938" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance CC-0012 given the game rule mob_griefing off when a zombie falls 2.5 blocks onto farmland then the farmland stays" TO TL-CASE
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     MOVE 28 TO WS-X0
     MOVE "zombie" TO WS-KEY
     PERFORM FALL
     MOVE "dirt 00 y 100938" TO TL-EXPECTED
     PERFORM CHECK
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     STOP RUN.

*> Lays the 5 x 5 patch of farmland centred on (X0, Z0) at y 100.
 PATCH.
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 4
             COMPUTE WS-BX = WS-X0 - 2 + WS-X
             COMPUTE WS-BZ = WS-Z0 - 2 + WS-Z
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-Y WS-BZ WS-FARM
         END-PERFORM
     END-PERFORM.

*> One mob (the key, a baby when WS-BABY is 1) spawned 2.5 blocks above the middle of the patch; the ticks run until it has landed (on the ground below 101.5).
 FALL.
     PERFORM PATCH
     MOVE SPACES TO WS-BKEY
     STRING "minecraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-BKEY
     MOVE WS-BKEY TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-X0 + 0.5
     COMPUTE WS-FZ = WS-Z0 + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
     IF WS-BABY = 1
         MOVE 1 TO EN-VARIANT(WS-ROW)
         MOVE -24000 TO EN-MOBAGE(WS-ROW)
     END-IF
     MOVE 1 TO WS-TICKS
     MOVE 0 TO WS-LANDED
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 40 OR WS-LANDED = 1
         CALL "TEST-TICKS" USING WS-TICKS
         IF EN-ON-GROUND(WS-ROW) = 1 AND EN-Y(WS-ROW) < 101.5
             MOVE 1 TO WS-LANDED
         END-IF
     END-PERFORM.

*> Counts the cells of the patch that are dirt: WS-N.
 COUNT-DIRT.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 4
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 4
             COMPUTE WS-BX = WS-X0 - 2 + WS-X
             COMPUTE WS-BZ = WS-Z0 - 2 + WS-Z
             CALL "IP-BLOCK-KEY" USING WS-DIM WS-BX WS-Y WS-BZ WS-BKEY WS-BLEN
             IF WS-BLEN = 14 AND WS-BKEY(1:14) = "minecraft:dirt"
                 ADD 1 TO WS-N
             END-IF
         END-PERFORM
     END-PERFORM.

 CHECK.
     PERFORM COUNT-DIRT
     COMPUTE WS-MILLI ROUNDED = EN-Y(WS-ROW) * 1000
     MOVE WS-MILLI TO WS-EDIT
     MOVE WS-N TO WS-ND
     MOVE SPACES TO TL-OBSERVED
     STRING "dirt " WS-ND " y " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE.
 END PROGRAM ACC-BUGFARMTRAMPLE-MOBS.

 COPY CORETEST.
