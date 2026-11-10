*> Acceptance test of Differences from the stand-in rules (T0356; docs/protocol/41-item-entity-physics.md section 8; FR-037): one case
*> per row of the table, each showing the standard value: the pickup delays 10, 40 and 0, gravity 0.04 and the drag 0.98, the throw
*> velocity of 2.3, the lifetime 6000 that counts with no player near, merging, the pickup box, the thrower that may pick its own
*> throw up again, the statistics and the restitution of a landing. Alice stands at (4.5, 54, 8.5) on the ground; the items far from
*> her are at (20.5, 100, 20.5) over a stone floor.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEMPHYS-41-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMPHYS.
 COPY CITEMS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 01 WS-C                   PIC X(16).
 01 WS-T1                  PIC X(64).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-VAR                 BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG VALUE 20.
 01 WS-BY                  BINARY-LONG VALUE 98.
 01 WS-BZ                  BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-BLOCK               BINARY-LONG VALUE 2.
 01 WS-FACING              BINARY-LONG VALUE 5.
 01 WS-X                   FLOAT-LONG VALUE 20.5.
 01 WS-Y                   FLOAT-LONG VALUE 100.
 01 WS-Z                   FLOAT-LONG VALUE 20.5.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-V3                  FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-LONG VALUE 0.
 01 WS-PITCH               FLOAT-LONG VALUE 0.
 01 WS-R1                  FLOAT-LONG VALUE 0.5.
 01 WS-R2                  FLOAT-LONG VALUE 0.5.
 01 WS-R3                  FLOAT-LONG VALUE 0.5.
 01 WS-R4                  FLOAT-LONG VALUE 0.5.
 01 WS-MOVED               FLOAT-LONG VALUE -0.3.
 01 WS-VY                  FLOAT-LONG VALUE -0.5.
 01 WS-RESTITUTION         FLOAT-LONG VALUE 1.
 01 WS-RESULT              FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE

*>   Pickup delay: block break 10 (stand-in 6), throw and death 40 (30), dispenser 0.
     CALL "GI-BLOCK-YIELD" USING WS-DIM WS-BX WS-BY WS-BZ WS-BLOCK
     PERFORM FIND-LAST
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-A
     CALL "GI-THROW-STACK-X" USING WS-PLAYER WS-ITEM WS-COUNT WS-VAR
     PERFORM FIND-LAST
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-B
     CALL "GI-DISPENSE" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACING WS-ITEM WS-ROW
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-C
     MOVE "acceptance US2 41§8 Differences from the stand-in rules the pickup delays are 10 for a block break, 40 for a throw and 0 "
         & "for a dispenser" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "10 40 0" TO WS-EXPECTED
     PERFORM CHECK
     PERFORM CLEAR-ITEMS

*>   Gravity 0.04 and drag 0.98 (stand-in 0.035 and 0.97): one tick of a fall.
     PERFORM SPAWN
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE "acceptance US2 41§8 Differences from the stand-in rules a falling item gains 0.04 of speed per tick and keeps 0.98 of it "
         & "(vy -0.0392 after one tick)" TO WS-CASE
     CALL "ITT-F" USING EN-VY(WS-ROW) WS-OBSERVED
     MOVE "-0.03920" TO WS-EXPECTED
     PERFORM CHECK

*>   Throw velocity: scale 0.3 plus the random circle (stand-in 0.25 and 0.12 lift).
     CALL "IP-THROW-MOTION" USING WS-YAW WS-PITCH WS-R1 WS-R2 WS-R3 WS-R4 WS-V1 WS-V2 WS-V3
     CALL "ITT-V3" USING WS-V1 WS-V2 WS-V3 WS-T1
     MOVE "acceptance US2 41§8 Differences from the stand-in rules a throw looking along +z has speed 0.3 with the random circle and "
         & "a lift of 0.1: (-0.01, 0.1, 0.3) for the draws 0.5" TO WS-CASE
     MOVE WS-T1 TO WS-OBSERVED
     MOVE "-0.01000,0.10000,0.30000" TO WS-EXPECTED
     PERFORM CHECK

*>   Lifetime 6000 counting with no player near (stand-in 4800 near a player): 4800 survives a tick, 5999 does not.
     PERFORM CLEAR-ITEMS
     PERFORM SPAWN
     MOVE 4800 TO EN-AGE(WS-ROW)
     MOVE WS-ROW TO WS-ROW2
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE EN-USED(WS-ROW2) TO WS-I
     CALL "ITT-I" USING WS-I WS-A
     CALL "ITT-I" USING EN-AGE(WS-ROW2) WS-B
     MOVE 5999 TO EN-AGE(WS-ROW2)
     CALL "TEST-TICKS" USING WS-N
     MOVE EN-USED(WS-ROW2) TO WS-I
     CALL "ITT-I" USING WS-I WS-C
     MOVE "acceptance US2 41§8 Differences from the stand-in rules an item lives 6000 ticks whether or not a player is near: age "
         & "4800 is still there, age 5999 goes in the next tick" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "1 4801 0" TO WS-EXPECTED
     PERFORM CHECK

*>   Merging (stand-in: never): 20 and 30 side by side merge into one entity of 50.
     PERFORM CLEAR-ITEMS
     MOVE 20 TO WS-COUNT
     PERFORM SPAWN
     MOVE WS-ROW TO WS-ROW2
     MOVE 21.0 TO WS-X
     MOVE 30 TO WS-COUNT
     PERFORM SPAWN
     CALL "IP-MERGE" USING WS-ROW2
     MOVE "acceptance US2 41§8 Differences from the stand-in rules two stacks of 20 and 30 of one item side by side merge into 50" TO WS-CASE
     MOVE EN-USED(WS-ROW2) TO WS-I
     CALL "ITT-I" USING WS-I WS-A
     CALL "ITT-I" USING EN-ITEM-COUNT(WS-ROW) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "0 50" TO WS-EXPECTED
     PERFORM CHECK
     PERFORM CLEAR-ITEMS
     MOVE 1 TO WS-COUNT

*>   Pickup box (1.0 and 0.5 around the player, the stand-in 0.75 and 0.25): an item 1.4 away is taken. The thrower picks its own
*>   throw up again once the delay of 40 is over (no owner is set by a throw), and the statistics are awarded.
     MOVE 90 TO PL-PITCH(WS-PLAYER)
     MOVE 4.5 TO PL-X(WS-PLAYER)
     MOVE 54 TO PL-Y(WS-PLAYER)
     MOVE 8.5 TO PL-Z(WS-PLAYER)
     CALL "GI-THROW-STACK-X" USING WS-PLAYER WS-ITEM WS-COUNT WS-VAR
     PERFORM FIND-LAST
     MOVE 40 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-A
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-B
     MOVE "acceptance US2 41§8 Differences from the stand-in rules the thrower can pick its own throw up again after the delay of 40: "
         & "still there after 40 ticks, taken in the 41st" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "1 0" TO WS-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US2 41§8 Differences from the stand-in rules the pickup and the throw award item_picked_up, item_dropped and the "
         & "custom stat drop" TO WS-CASE
     CALL "IP-STAT-GET" USING WS-PLAYER IP-STAT-PICKED WS-ITEM WS-I
     CALL "ITT-I" USING WS-I WS-A
     CALL "IP-STAT-GET" USING WS-PLAYER IP-STAT-DROPPED WS-ITEM WS-I
     CALL "ITT-I" USING WS-I WS-B
     MOVE IP-S-DROP-ACTIONS(WS-PLAYER) TO WS-I
     CALL "ITT-I" USING WS-I WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "1 2 2" TO WS-EXPECTED
     PERFORM CHECK

*>   Landing: a restitution step (stand-in: not specified): 0.8 of the block value on slime.
     CALL "IP-RESTITUTE" USING WS-VY WS-MOVED WS-RESTITUTION WS-RESULT
     MOVE "acceptance US2 41§8 Differences from the stand-in rules an item landing on a slime block at vy -0.5 leaves with 0.4141696 "
         & "(0.8 of the block's restitution)" TO WS-CASE
     CALL "ITT-F" USING WS-RESULT WS-OBSERVED
     MOVE "0.41417" TO WS-EXPECTED
     PERFORM CHECK
     STOP RUN.

 SPAWN.
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V1 WS-V2 WS-V3 WS-ITEM WS-COUNT WS-DELAY WS-ROW.

 FIND-LAST.
     MOVE EN-COUNT TO WS-ROW
     PERFORM UNTIL EN-USED(WS-ROW) = 1 AND EN-TYPE(WS-ROW) = CR-LOOSE-ITEM
         SUBTRACT 1 FROM WS-ROW
     END-PERFORM.

 CLEAR-ITEMS.
     MOVE 20.5 TO WS-X
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM.

 CHECK.
     CALL "ITT-CHECK" USING WS-CASE WS-EXPECTED WS-OBSERVED.
 END PROGRAM TEST-ITEMPHYS-41-8.

 COPY CORETEST.
 COPY ITEMTEST.
