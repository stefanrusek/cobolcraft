*> Implementation test of a mob in water (core/src/mobs.cob MOB-PHYSICS; 18 section 3.2 travelInWater and the FloatGoal of 18 section 2.6): a mob whose box
*> touches water has no gravity: its vertical speed is (speed + 0.04 when the water is deeper than 0.4) x 0.8, less 0.005 while it is not rising, so it
*> floats up (the first tick from rest 0.032 up) and stops under a ceiling; its horizontal step is halved. A new test world has no liquids: the water
*> block is added to the block table. The sodgrazer stands on the turf at (9, 8) (top 55, standin 5.2) in a column of water of 4 cells with a stone ceiling above it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-SWIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG VALUE 2.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-BX                  BINARY-LONG VALUE 9.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG VALUE 8.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-G                   PIC 9.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-COUNT               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-R1                  PIC -(5)9.999.
 01 WS-R2                  PIC -(5)9.999.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "minecraft:water" TO WS-KEY
     MOVE 0 TO WS-SOLID
     MOVE 16 TO WS-COUNT
     PERFORM INSTALL
     MOVE WS-BASE TO WS-WATER
     PERFORM VARYING WS-BY FROM 55 BY 1 UNTIL WS-BY > 58
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     END-PERFORM
     MOVE 59 TO WS-BY
     MOVE 2 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE 9.5 TO WS-X
     MOVE 55 TO WS-Y
     MOVE 8.5 TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "T" TO TL-MODE
     MOVE "test mob swim given a sodgrazer at the bottom of 4 cells of water when a tick runs then it rises 0.032 and is off the ground" TO TL-CASE
     CALL "TEST-TICKS" USING WS-ONE
     COMPUTE WS-R1 ROUNDED = EN-Y(WS-ROW)
     MOVE EN-ON-GROUND(WS-ROW) TO WS-G
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-R1) " " WS-G DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "55.032 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 60 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     COMPUTE WS-R1 ROUNDED = EN-Y(WS-ROW)
     MOVE "test mob swim given 60 ticks then the sodgrazer is held under the stone ceiling at 59 (its box stops below it): between 57.0 and 58.5" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-Y(WS-ROW) >= 57.0 AND EN-Y(WS-ROW) <= 58.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Shallow: water one cell deep (top 55.889) with the mob's feet at 55.6: not deeper than 0.4, so no push up; it sinks by 0.005 a tick.
     MOVE 11 TO WS-BX
     MOVE 55 TO WS-BY
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
     MOVE 11.5 TO WS-X
     MOVE 55.6 TO WS-Y
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-TICKS" USING WS-ONE
     COMPUTE WS-R1 ROUNDED = EN-Y(WS-ROW)
     MOVE "test mob swim given a sodgrazer in water not deeper than 0.4 when a tick runs then it sinks 0.005 (55.595)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-R1) TO TL-OBSERVED
     MOVE "55.595" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Adds a block with the key WS-KEY and WS-COUNT states, solid or not (WS-SOLID), after the last block and state of the tables.
 INSTALL.
     COMPUTE WS-N = CB-BLOCK-COUNT + 1
     MOVE WS-KEY TO CB-KEY(WS-N)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO CB-KEY-LENGTH(WS-N)
     MOVE WS-SOLID TO CB-SOLID(WS-N) CB-OPAQUE(WS-N)
     MOVE 0 TO CB-LIGHT(WS-N) CB-CLASS(WS-N) CB-TOOL-REQ(WS-N) CB-NEED-TIER(WS-N)
     MOVE -1 TO CB-BREAK-MS(WS-N)
     MOVE CB-STATE-COUNT TO WS-BASE
     MOVE WS-BASE TO CB-FIRST-STATE(WS-N) CB-DEFAULT-STATE(WS-N)
     MOVE WS-COUNT TO CB-STATES(WS-N)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
         COMPUTE CB-S-BLOCK(WS-BASE + WS-K) = WS-N - 1
         MOVE 0 TO CB-S-LIGHT(WS-BASE + WS-K)
     END-PERFORM
     ADD 1 TO CB-BLOCK-COUNT
     ADD WS-COUNT TO CB-STATE-COUNT
     ADD 1 TO CB-EPOCH.
 END PROGRAM TEST-MOB-SWIM.

 COPY CORETEST.
