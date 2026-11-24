*> Acceptance test (wrap agent B round 5, T29574; docs/protocol/30-redstone-4 section 4.15, 24 part 6 section 6.12): a dispenser with a shulker box places it in the cell in front of it when that cell can be
*> replaced and holds no entity: facing = the dispenser's facing when the cell under the front cell is air, else up. A cell that cannot be replaced, or an armor stand in it, keeps the box in the dispenser
*> with the failure click 1001 and drops nothing. The standard world of the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-DISPENSE-SHULKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-dispense-shulker-world".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXP                 PIC X(160).
 01 WS-OBS                 PIC X(160).
 01 WS-BE                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-SUM-ED              PIC -(9)9.
 01 WS-A-ED                PIC -(9)9.
 01 WS-B-ED                PIC -(9)9.
 01 WS-HITS                BINARY-LONG.
 01 WS-HITS2               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LINE                PIC X(1040).
 01 WS-STAND-KEY           PIC X(112) VALUE "minecraft:armor_stand".
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-STAND               BINARY-LONG.
 01 WS-PLAIN               BINARY-LONG.
 01 WS-FULL                PIC X(48).
 01 WS-BARE                PIC X(48).
 01 WS-RED                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb dispense shulker: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 12
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K MOVE SPACES TO WS-PR
             PERFORM PUT-BLOCK
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
                 MOVE "air" TO WS-K
                 PERFORM PUT-BLOCK
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-SX
     MOVE WS-SX TO PL-X(WS-ROW)
     MOVE 106.0 TO PL-Y(WS-ROW)
     MOVE 60.5 TO PL-Z(WS-ROW)
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "shulker_box" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-PLAIN
     MOVE "red_shulker_box" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-RED

*>   A. over air (the cell under the front cell is air): facing east like the dispenser, the box spent, nothing dropped
     MOVE 0 TO WS-Z MOVE WS-PLAIN TO WS-ITEM
     PERFORM MAKE-DISPENSER
     MOVE 4 TO WS-X MOVE 100 TO WS-Y MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CELL
     MOVE "acceptance wrapb dispense 30-4 4.15 a shulker box over air is placed facing like the dispenser (east): one left, none dropped" TO WS-CASE
     MOVE "facing=east 1 0" TO WS-EXP
     PERFORM ASSERT-OBS
*>   B. a solid block under the front cell: the box faces up; a dyed box is placed as the same block of its colour
     MOVE 2 TO WS-Z MOVE WS-RED TO WS-ITEM
     PERFORM MAKE-DISPENSER
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CELL
     MOVE "acceptance wrapb dispense 30-4 4.15 a red shulker box over a solid block is placed facing up: one left, none dropped" TO WS-CASE
     MOVE "facing=up 1 0" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-FULL
     CALL "KEY-BARE" USING WS-FULL WS-BARE
     MOVE WS-BARE TO WS-OBS
     MOVE "acceptance wrapb dispense 30-4 4.15 the block placed for the red shulker box item is the red shulker box" TO WS-CASE
     MOVE "red_shulker_box" TO WS-EXP
     PERFORM ASSERT-OBS
*>   C. water in the front cell is replaced
     MOVE 4 TO WS-Z MOVE WS-PLAIN TO WS-ITEM
     PERFORM MAKE-DISPENSER
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "water" TO WS-K MOVE "level=0" TO WS-PR PERFORM PUT-BLOCK
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CELL
     MOVE "acceptance wrapb dispense 30-4 4.15 a shulker box is placed in a cell of water (replaceable): facing up, one left" TO WS-CASE
     MOVE "facing=up 1 0" TO WS-EXP
     PERFORM ASSERT-OBS
*>   D. a cell that cannot be replaced: the box stays, the failure click 1001 and the smoke, nothing dropped
     MOVE 6 TO WS-Z MOVE WS-PLAIN TO WS-ITEM
     PERFORM MAKE-DISPENSER
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "stone" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM COUNT-EVENTS
     PERFORM OBS-CELL
     MOVE "acceptance wrapb dispense 30-4 4.15 a shulker box in front of stone stays: the stone, two left, none dropped, events 1001 and 2000" TO WS-CASE
     MOVE "stone 2 0 2" TO WS-EXP
     PERFORM ASSERT-OBS
*>   E. an armor stand in the cell blocks the placement (the box would meet it)
     MOVE 8 TO WS-Z MOVE WS-PLAIN TO WS-ITEM
     PERFORM MAKE-DISPENSER
     MOVE 4.5 TO WS-SX MOVE 101.0 TO WS-SY COMPUTE WS-SZ = WS-Z + 0.5
     MOVE 0 TO WS-STAND
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-SX WS-SY WS-SZ WS-YAW WS-STAND
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM COUNT-EVENTS
     PERFORM OBS-CELL
     MOVE "acceptance wrapb dispense 30-4 4.15 a shulker box where an armor stand stands is not placed: air, two left, none dropped, events 1001 and 2000" TO WS-CASE
     MOVE "air 2 0 2" TO WS-EXP
     PERFORM ASSERT-OBS
     STOP RUN.

 MAKE-DISPENSER.
*>   a dispenser facing east at (3, 101, WS-Z) holding 2 of item WS-ITEM in its first slot, its block entity in WS-BE
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "dispenser" TO WS-K MOVE "facing=east,triggered=false" TO WS-PR PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1).

 OBS-CELL.
*>   WS-OBS = "<the properties of the block in the front cell, or its key when it has none> <the dispenser's count> <the box items dropped in the row>" and, after COUNT-EVENTS, the Level Events
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-PROPS
     IF WS-PROPS = SPACES
         MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-FULL
         CALL "KEY-BARE" USING WS-FULL WS-BARE
         MOVE WS-BARE TO WS-PROPS
     END-IF
     PERFORM SUM-ENTITIES-OF
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-A-ED
     MOVE SPACES TO WS-OBS
     IF WS-HITS > 0
         MOVE WS-HITS TO WS-B-ED
         STRING FUNCTION TRIM(WS-PROPS) " " FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-SUM-ED) " " FUNCTION TRIM(WS-B-ED) DELIMITED BY SIZE INTO WS-OBS
     ELSE
         STRING FUNCTION TRIM(WS-PROPS) " " FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-SUM-ED) DELIMITED BY SIZE INTO WS-OBS
     END-IF.

 POWER-ON.
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK.

 ASSERT-OBS.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SUM-ENTITIES-OF.
*>   the item entities of item WS-ITEM within the row WS-Z: the count in WS-SUM and WS-SUM-ED
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-ITEM
                 AND EN-Z(WS-I) >= WS-Z AND EN-Z(WS-I) < WS-Z + 1
             ADD EN-ITEM-COUNT(WS-I) TO WS-SUM
         END-IF
     END-PERFORM
     MOVE WS-SUM TO WS-SUM-ED.

 COUNT-EVENTS.
*>   the Level Event packets (id 47) in the ids drained into WS-TEXT, a run "47x2" counting twice
     MOVE SPACES TO WS-LINE
     STRING " " FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO WS-LINE
     MOVE 0 TO WS-HITS WS-HITS2
     INSPECT WS-LINE TALLYING WS-HITS FOR ALL " 47 "
     INSPECT WS-LINE TALLYING WS-HITS2 FOR ALL " 47x2 "
     COMPUTE WS-HITS = WS-HITS + 2 * WS-HITS2.

 READ-PROPS.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS.

 CLEAR-ROW.
*>   air on x 0 to 8 at heights 101 to 104 of row WS-Z, stone at 100 again
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
         MOVE 100 TO WS-Y
         MOVE "stone" TO WS-K MOVE SPACES TO WS-PR
         PERFORM PUT-BLOCK
         PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
             MOVE "air" TO WS-K
             PERFORM PUT-BLOCK
         END-PERFORM
     END-PERFORM.

 PUT-BLOCK.
*>   the block of key WS-K and property pairs WS-PR at (WS-X, WS-Y, WS-Z), written with flags 3
     CALL "PT-STATE" USING WS-K WS-PR WS-ST
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 END PROGRAM ACC-WRAPB-DISPENSE-SHULKER.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
