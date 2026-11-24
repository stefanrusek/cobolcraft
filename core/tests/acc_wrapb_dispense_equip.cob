*> Acceptance test (wrap agent B round 5, T29574; docs/protocol/30-redstone-4 sections 4.7, 4.8 and 4.9, 44 part 7 section 10.3.1): a dispenser puts one item that can be worn on the armor stand or the player in its
*> front cell whose slot is free (an armor stand with the slot disabled or taken, a spectator, a crouching player whose box is below the cell, an entity 3 blocks away: the item is dropped); a carved pumpkin
*> where a golem pattern is complete (snow, copper) is placed and the golem appears; a wither skeleton skull where the wither base pattern is complete is placed with the rotation of the facing and the
*> full pattern spawns the wither; with no pattern both are worn or, when nobody can wear them, stay in the dispenser with the failure click and are never dropped. The standard world of the generated
*> packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-DISPENSE-EQUIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY CMENU.
 COPY PROJSTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-dispense-equip-world".
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
 01 WS-BOOTS               BINARY-LONG.
 01 WS-HELMET              BINARY-LONG.
 01 WS-OTHER-HELMET        BINARY-LONG.
 01 WS-PUMPKIN             BINARY-LONG.
 01 WS-SKULL               BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-SUM-ED              PIC -(9)9.
 01 WS-A-ED                PIC -(9)9.
 01 WS-B-ED                PIC -(9)9.
 01 WS-C-ED                PIC -(9)9.
 01 WS-D-ED                PIC -(9)9.
 01 WS-HITS                BINARY-LONG.
 01 WS-HITS2               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LINE                PIC X(1040).
 01 WS-STAND-KEY           PIC X(112) VALUE "minecraft:armor_stand".
 01 WS-STAND-T             BINARY-LONG.
 01 WS-GOLEM-KEY           PIC X(112).
 01 WS-MOB-T               BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-STAND               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-STAND-X             FLOAT-LONG.
 01 WS-STAND-Y             FLOAT-LONG VALUE 101.0.
 01 WS-FLAG-I1             BINARY-LONG.
 01 WS-FLAG-I2             BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-MODE                PIC 9.
 01 WS-POSE                BINARY-LONG.
 01 WS-PRE-WORN            BINARY-LONG.
 01 WS-FACE                PIC X(8) VALUE "east".
 01 WS-FSX                 BINARY-LONG VALUE 1.
 01 WS-FSY                 BINARY-LONG VALUE 0.
 01 WS-FSZ                 BINARY-LONG VALUE 0.
 01 WS-SHIELD              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb dispense equip: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 46
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
     PERFORM PARK-ALICE
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "iron_boots" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-BOOTS
     MOVE "iron_helmet" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-HELMET
     MOVE "golden_helmet" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-OTHER-HELMET
     MOVE "carved_pumpkin" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-PUMPKIN
     MOVE "wither_skeleton_skull" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-SKULL
     MOVE "shield" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-SHIELD
     CALL "THROWN-TYPE" USING WS-STAND-KEY WS-STAND-T

*>   A. boots on an armor stand in the front cell: worn, one boots left, none dropped
     MOVE 0 TO WS-Z MOVE WS-BOOTS TO WS-ITEM MOVE 0 TO WS-FLAG-I1 WS-FLAG-I2 MOVE 4.5 TO WS-STAND-X
     PERFORM STAND-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 boots on the armor stand in the front cell: worn, one left, none dropped" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-OBS
*>   B. the head slot disabled (bit 4 of the disabled slots): dropped
     MOVE 1 TO WS-Z MOVE WS-HELMET TO WS-ITEM MOVE 0 TO WS-FLAG-I1 MOVE 16 TO WS-FLAG-I2 MOVE 4.5 TO WS-STAND-X
     PERFORM STAND-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 an armor stand with the head slot disabled does not take the helmet: dropped" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
*>   C. the head slot taken: dropped, the old helmet stays
     MOVE 2 TO WS-Z MOVE WS-HELMET TO WS-ITEM MOVE 0 TO WS-FLAG-I1 WS-FLAG-I2 MOVE 4.5 TO WS-STAND-X
     MOVE WS-OTHER-HELMET TO WS-PRE-WORN
     PERFORM STAND-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 an armor stand that wears a helmet does not take another: dropped, the old one stays" TO WS-CASE
     MOVE "1 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
*>   D. a marker armor stand has no box but its point is inside the cell (half way up: a point on the floor of the cell is not inside it): worn
     MOVE 3 TO WS-Z MOVE WS-BOOTS TO WS-ITEM MOVE 16 TO WS-FLAG-I1 MOVE 0 TO WS-FLAG-I2 MOVE 4.5 TO WS-STAND-X MOVE 101.5 TO WS-STAND-Y
     PERFORM STAND-CASE
     MOVE 101.0 TO WS-STAND-Y
     MOVE "acceptance wrapb dispense 30-4 4.9 a marker armor stand whose point is in the front cell wears the boots" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-OBS
*>   E. a small armor stand: worn
     MOVE 4 TO WS-Z MOVE WS-BOOTS TO WS-ITEM MOVE 1 TO WS-FLAG-I1 MOVE 0 TO WS-FLAG-I2 MOVE 4.5 TO WS-STAND-X
     PERFORM STAND-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 a small armor stand in the front cell wears the boots" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-OBS
*>   F. an armor stand 3 blocks east of the front cell is not in the front box: dropped
     MOVE 5 TO WS-Z MOVE WS-BOOTS TO WS-ITEM MOVE 0 TO WS-FLAG-I1 WS-FLAG-I2 MOVE 7.5 TO WS-STAND-X
     PERFORM STAND-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 an armor stand 3 blocks east of the front cell is not reached: dropped" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
*>   G. a survival player standing in the front cell wears the boots (container slot 36)
     MOVE 7 TO WS-Z MOVE WS-BOOTS TO WS-ITEM MOVE 0 TO WS-MODE MOVE 101.0 TO WS-PY MOVE 0 TO WS-POSE MOVE 0 TO WS-PRE-WORN
     PERFORM PLAYER-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 a survival player in the front cell wears the boots: worn, one left, none dropped" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-OBS
*>   H. a standing player whose feet are 1.7 below the cell floor still reaches into it (box 1.8 high)
     MOVE 8 TO WS-Z MOVE WS-BOOTS TO WS-ITEM MOVE 0 TO WS-MODE MOVE 99.5 TO WS-PY MOVE 0 TO WS-POSE MOVE 0 TO WS-PRE-WORN
     PERFORM PLAYER-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 a standing player whose head reaches into the front cell wears the boots" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-OBS
*>   I. the same player crouching (box 1.5 high) does not reach it: dropped
     MOVE 9 TO WS-Z MOVE WS-BOOTS TO WS-ITEM MOVE 0 TO WS-MODE MOVE 99.5 TO WS-PY MOVE 5 TO WS-POSE MOVE 0 TO WS-PRE-WORN
     PERFORM PLAYER-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 a crouching player whose box ends below the front cell is not reached: dropped" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
*>   J. a spectator is skipped
     MOVE 10 TO WS-Z MOVE WS-BOOTS TO WS-ITEM MOVE 3 TO WS-MODE MOVE 101.0 TO WS-PY MOVE 0 TO WS-POSE MOVE 0 TO WS-PRE-WORN
     PERFORM PLAYER-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 a spectator in the front cell does not wear the boots: dropped" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
*>   K. a player whose boots slot is taken is skipped
     MOVE 11 TO WS-Z MOVE WS-BOOTS TO WS-ITEM MOVE 0 TO WS-MODE MOVE 101.0 TO WS-PY MOVE 0 TO WS-POSE MOVE WS-OTHER-HELMET TO WS-PRE-WORN
     PERFORM PLAYER-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 a player whose boots slot is taken does not wear another pair: dropped" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS

*>   L. a carved pumpkin on two snow blocks: placed, the pattern is built, the snow golem appears, the pumpkin is spent
     MOVE 12 TO WS-Z MOVE WS-PUMPKIN TO WS-ITEM
     PERFORM MAKE-DISPENSER
     MOVE 4 TO WS-X MOVE 100 TO WS-Y MOVE "snow_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 99 TO WS-Y PERFORM PUT-BLOCK
     MOVE "minecraft:snow_golem" TO WS-GOLEM-KEY
     PERFORM RUN-MOB-CASE
     MOVE "acceptance wrapb dispense 30-4 4.8 a carved pumpkin over two snow blocks is placed and the snow golem is built: cell air, one left, one golem" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
*>   M. a carved pumpkin on a copper block: placed, the copper chest takes the block, the golem appears
     MOVE 14 TO WS-Z MOVE WS-PUMPKIN TO WS-ITEM
     PERFORM MAKE-DISPENSER
     MOVE 4 TO WS-X MOVE 100 TO WS-Y MOVE "copper_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE "minecraft:copper_golem" TO WS-GOLEM-KEY
     PERFORM RUN-MOB-CASE
     MOVE "acceptance wrapb dispense 30-4 4.8 a carved pumpkin on a copper block is placed and the copper golem is built: cell air, one left, one golem" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
*>   N. a carved pumpkin with no pattern and nobody to wear it: it stays in the dispenser, the failure click 1001 and the smoke, nothing dropped
     MOVE 16 TO WS-Z MOVE WS-PUMPKIN TO WS-ITEM
     PERFORM MAKE-DISPENSER
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM COUNT-EVENTS
     PERFORM OBS-CELL
     MOVE "acceptance wrapb dispense 30-4 4.8 a carved pumpkin with no pattern and no wearer stays: cell air, two left, none dropped, events 1001 and 2000" TO WS-CASE
     MOVE "0 2 0 2" TO WS-EXP
     PERFORM ASSERT-OBS
*>   O. a carved pumpkin with an armor stand in the cell and no pattern: worn on the head
     MOVE 18 TO WS-Z MOVE WS-PUMPKIN TO WS-ITEM MOVE 0 TO WS-FLAG-I1 WS-FLAG-I2 MOVE 4.5 TO WS-STAND-X
     PERFORM STAND-CASE
     MOVE "acceptance wrapb dispense 30-4 4.8 a carved pumpkin with an armor stand in the front cell and no pattern: worn on the head, one left, none dropped" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-OBS

*>   P. a skull with the wither base (three soul sand in a row below, one under the middle, air beside it): placed with the rotation of the east facing (12), no full pattern
     MOVE 20 TO WS-Z MOVE WS-SKULL TO WS-ITEM
     PERFORM MAKE-DISPENSER
     PERFORM PUT-WITHER-BASE
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 4 TO WS-X MOVE 101 TO WS-Y PERFORM READ-PROPS
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-A-ED
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-PROPS) " " FUNCTION TRIM(WS-A-ED) DELIMITED BY SIZE INTO WS-OBS
     MOVE "acceptance wrapb dispense 30-4 4.7 a wither skeleton skull over the wither base is placed with rotation 12, one left" TO WS-CASE
     MOVE "powered=false,rotation=12 1" TO WS-EXP
     PERFORM ASSERT-OBS
*>   Q. the full pattern (two skulls beside the cell): the wither is built, the skull cell is air
     MOVE 24 TO WS-Z MOVE WS-SKULL TO WS-ITEM
     PERFORM MAKE-DISPENSER
     PERFORM PUT-WITHER-BASE
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "wither_skeleton_skull" TO WS-K MOVE "powered=false,rotation=0" TO WS-PR
     COMPUTE WS-Z = 25 PERFORM PUT-BLOCK
     COMPUTE WS-Z = 26 PERFORM PUT-BLOCK
     MOVE 24 TO WS-Z
     MOVE "minecraft:wither" TO WS-GOLEM-KEY
     PERFORM RUN-MOB-CASE
     MOVE "acceptance wrapb dispense 30-4 4.7 a skull that completes the wither pattern: the wither is built, cell air, one left, one wither" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
*>   R. a skull with no pattern and nobody: stays with the failure click
     MOVE 28 TO WS-Z MOVE WS-SKULL TO WS-ITEM
     PERFORM MAKE-DISPENSER
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM COUNT-EVENTS
     PERFORM OBS-CELL
     MOVE "acceptance wrapb dispense 30-4 4.7 a wither skeleton skull with no pattern and no wearer stays: cell air, two left, none dropped, events 1001 and 2000" TO WS-CASE
     MOVE "0 2 0 2" TO WS-EXP
     PERFORM ASSERT-OBS
*>   S. a skull and an armor stand in the cell: worn on the head
     MOVE 30 TO WS-Z MOVE WS-SKULL TO WS-ITEM MOVE 0 TO WS-FLAG-I1 WS-FLAG-I2 MOVE 4.5 TO WS-STAND-X
     PERFORM STAND-CASE
     MOVE "acceptance wrapb dispense 30-4 4.7 a wither skeleton skull with an armor stand in the front cell and no pattern: worn on the head" TO WS-CASE
     MOVE "1 1 0" TO WS-EXP
     PERFORM ASSERT-OBS
*>   T. a shield is not worn by the dispenser (the off-hand is not one of its slots): dropped
     MOVE 32 TO WS-Z MOVE WS-SHIELD TO WS-ITEM MOVE 0 TO WS-FLAG-I1 WS-FLAG-I2 MOVE 4.5 TO WS-STAND-X
     PERFORM STAND-CASE
     MOVE "acceptance wrapb dispense 30-4 4.9 a shield in front of an armor stand is dropped, not worn" TO WS-CASE
     MOVE "0 1 1" TO WS-EXP
     PERFORM ASSERT-OBS
*>   U to W. the rotation segment of a skull placed by a dispenser facing north (8), west (4) and down (0)
     MOVE 34 TO WS-Z MOVE "north" TO WS-FACE MOVE 0 TO WS-FSX MOVE 0 TO WS-FSY MOVE -1 TO WS-FSZ
     PERFORM FACE-CASE
     MOVE "acceptance wrapb dispense 30-4 4.7 a skull placed by a dispenser facing north gets rotation 8" TO WS-CASE
     MOVE "powered=false,rotation=8" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE 38 TO WS-Z MOVE "west" TO WS-FACE MOVE -1 TO WS-FSX MOVE 0 TO WS-FSY MOVE 0 TO WS-FSZ
     PERFORM FACE-CASE
     MOVE "acceptance wrapb dispense 30-4 4.7 a skull placed by a dispenser facing west gets rotation 4" TO WS-CASE
     MOVE "powered=false,rotation=4" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE 42 TO WS-Z MOVE "down" TO WS-FACE MOVE 0 TO WS-FSX MOVE -1 TO WS-FSY MOVE 0 TO WS-FSZ
     PERFORM FACE-CASE
     MOVE "acceptance wrapb dispense 30-4 4.7 a skull placed by a dispenser facing down gets rotation 0" TO WS-CASE
     MOVE "powered=false,rotation=0" TO WS-EXP
     PERFORM ASSERT-OBS
     STOP RUN.

 FACE-CASE.
*>   a dispenser of the facing WS-FACE with a wither skeleton skull over the wither base of the row WS-Z; WS-OBS = the properties of the placed skull; the facing is east again afterwards
     MOVE WS-SKULL TO WS-ITEM
     PERFORM MAKE-DISPENSER
     PERFORM PUT-WITHER-BASE
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 4 TO WS-X MOVE 101 TO WS-Y PERFORM READ-PROPS
     MOVE WS-PROPS TO WS-OBS
     MOVE "east" TO WS-FACE MOVE 1 TO WS-FSX MOVE 0 TO WS-FSY MOVE 0 TO WS-FSZ.

 MAKE-DISPENSER.
*>   a dispenser facing WS-FACE (the step WS-FSX, WS-FSY, WS-FSZ: east 1 0 0) one cell behind the front cell (4, 101, WS-Z) holding 2 of item WS-ITEM in its first slot, its block entity in WS-BE
     PERFORM CLEAR-ROW
     COMPUTE WS-X = 4 - WS-FSX
     COMPUTE WS-Y = 101 - WS-FSY
     COMPUTE WS-Z = WS-Z - WS-FSZ
     MOVE "dispenser" TO WS-K
     MOVE SPACES TO WS-PR
     STRING "facing=" FUNCTION TRIM(WS-FACE) ",triggered=false" DELIMITED BY SIZE INTO WS-PR
     PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     COMPUTE WS-Z = WS-Z + WS-FSZ
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1).

 STAND-CASE.
*>   MAKE-DISPENSER, an armor stand at x WS-STAND-X of the row with the flags WS-FLAG-I1 and WS-FLAG-I2 (and WS-PRE-WORN in its head slot when > 0), powered;
*>   WS-OBS = "<1 when its slot of the item holds the item or the pre-worn item> <the dispenser's count> <the items dropped in the row>"
     PERFORM MAKE-DISPENSER
     MOVE WS-STAND-X TO WS-SX
     MOVE WS-STAND-Y TO WS-SY
     COMPUTE WS-SZ = WS-Z + 0.5
     MOVE 0 TO WS-STAND
     CALL "ARMOR-STAND-SPAWN" USING WS-DIM WS-SX WS-SY WS-SZ WS-YAW WS-STAND
     CALL "PJ-FIND" USING EN-ID(WS-STAND) WS-SLOT
     MOVE WS-FLAG-I1 TO PJ-I1(WS-SLOT)
     MOVE WS-FLAG-I2 TO PJ-I2(WS-SLOT)
     IF WS-PRE-WORN > 0
         MOVE WS-PRE-WORN TO PJ-EQ(WS-SLOT, 5)
     END-IF
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM SUM-ENTITIES-OF
     MOVE 0 TO WS-A-ED
     EVALUATE TRUE
         WHEN WS-PRE-WORN > 0 AND PJ-EQ(WS-SLOT, 5) = WS-PRE-WORN
             MOVE 1 TO WS-A-ED
         WHEN WS-PRE-WORN = 0 AND (PJ-EQ(WS-SLOT, 2) = WS-ITEM OR PJ-EQ(WS-SLOT, 5) = WS-ITEM)
             MOVE 1 TO WS-A-ED
     END-EVALUATE
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B-ED
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-SUM-ED) DELIMITED BY SIZE INTO WS-OBS
     MOVE 0 TO WS-PRE-WORN.

 PLAYER-CASE.
*>   MAKE-DISPENSER, Alice in the front cell with feet at WS-PY in the mode WS-MODE and the pose WS-POSE (WS-PRE-WORN in her boots slot when > 0), powered;
*>   WS-OBS = "<1 when her boots slot holds the item> <the dispenser's count> <the items dropped in the row>"
     PERFORM MAKE-DISPENSER
     MOVE 4.5 TO WS-PX
     COMPUTE WS-PZ = WS-Z + 0.5
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE WS-PY TO PL-Y(WS-ROW)
     MOVE WS-PZ TO PL-Z(WS-ROW)
     MOVE WS-MODE TO PL-MODE(WS-ROW)
     MOVE WS-POSE TO PL-POSE(WS-ROW)
     MOVE 0 TO MN-EQUIP-COUNT(WS-ROW, 1) MN-EQUIP-ITEM(WS-ROW, 1)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-COUNT(WS-ROW, WS-I)
     END-PERFORM
     IF WS-PRE-WORN > 0
         MOVE WS-PRE-WORN TO MN-EQUIP-ITEM(WS-ROW, 1)
         MOVE 1 TO MN-EQUIP-COUNT(WS-ROW, 1)
     END-IF
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM SUM-ENTITIES-OF
*>   an item dropped into the cell is picked up by the player standing in it: it counts as dropped where it lies, in the row or in her inventory
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-COUNT(WS-ROW, WS-I) > 0 AND PL-SLOT-ITEM(WS-ROW, WS-I) = WS-ITEM
             ADD PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-SUM
         END-IF
     END-PERFORM
     MOVE WS-SUM TO WS-SUM-ED
     MOVE 0 TO WS-A-ED
     IF MN-EQUIP-COUNT(WS-ROW, 1) = 1 AND MN-EQUIP-ITEM(WS-ROW, 1) = WS-ITEM
         MOVE 1 TO WS-A-ED
     END-IF
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B-ED
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-SUM-ED) DELIMITED BY SIZE INTO WS-OBS
     MOVE 0 TO MN-EQUIP-COUNT(WS-ROW, 1) MN-EQUIP-ITEM(WS-ROW, 1)
     MOVE 0 TO WS-PRE-WORN
     PERFORM PARK-ALICE.

 PARK-ALICE.
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 0 TO PL-POSE(WS-ROW)
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 106.0 TO PL-Y(WS-ROW)
     MOVE 60.5 TO PL-Z(WS-ROW).

 RUN-MOB-CASE.
*>   power the dispenser and run; WS-OBS = "<the state of the front cell> <the dispenser's count> <the mobs of key WS-GOLEM-KEY within the 3 rows of WS-Z>"
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     CALL "THROWN-TYPE" USING WS-GOLEM-KEY WS-MOB-T
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-MOB-T AND EN-Z(WS-I) >= WS-Z AND EN-Z(WS-I) < WS-Z + 3
             ADD 1 TO WS-SUM
         END-IF
     END-PERFORM
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-A-ED
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B-ED
     MOVE WS-SUM TO WS-C-ED
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-C-ED) DELIMITED BY SIZE INTO WS-OBS.

 PUT-WITHER-BASE.
*>   soul sand in a row of three below the skull cell (4, 100, WS-Z to WS-Z + 2), one under the middle and air beside it
     MOVE 4 TO WS-X MOVE 100 TO WS-Y MOVE "soul_sand" TO WS-K MOVE SPACES TO WS-PR
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
         COMPUTE WS-Z = WS-Z + WS-I
         PERFORM PUT-BLOCK
         COMPUTE WS-Z = WS-Z - WS-I
     END-PERFORM
     MOVE 99 TO WS-Y
     COMPUTE WS-Z = WS-Z + 1
     PERFORM PUT-BLOCK
     MOVE "air" TO WS-K
     COMPUTE WS-Z = WS-Z - 1
     PERFORM PUT-BLOCK
     COMPUTE WS-Z = WS-Z + 2
     PERFORM PUT-BLOCK
     COMPUTE WS-Z = WS-Z - 2.

 OBS-CELL.
*>   WS-OBS = "<the state of the front cell> <the dispenser's count> <the items dropped in the row> <the Level Event packets WS-HITS>"
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-A-ED
     PERFORM SUM-ENTITIES-OF
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-B-ED
     MOVE WS-HITS TO WS-C-ED
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-A-ED) " " FUNCTION TRIM(WS-B-ED) " " FUNCTION TRIM(WS-SUM-ED) " " FUNCTION TRIM(WS-C-ED) DELIMITED BY SIZE INTO WS-OBS.

 POWER-ON.
     COMPUTE WS-X = 4 - 2 * WS-FSX
     COMPUTE WS-Y = 101 - 2 * WS-FSY
     COMPUTE WS-Z = WS-Z - 2 * WS-FSZ
     MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR
     PERFORM PUT-BLOCK
     COMPUTE WS-Z = WS-Z + 2 * WS-FSZ.

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
*>   air on x 0 to 8 at heights 101 to 104 of row WS-Z
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
             MOVE "air" TO WS-K MOVE SPACES TO WS-PR
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

 END PROGRAM ACC-WRAPB-DISPENSE-EQUIP.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
