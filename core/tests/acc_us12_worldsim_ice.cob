*> Acceptance test of ice and snow (specs 002 phase 41; docs/protocol/33 section 4.4, 2.4 step 1, 4.5): the random ticks of a chunk that a player has in view try
*> tickPrecipitation on columns of their chunk, one attempt in 48 for each of random_tick_speed draws a tick. On a platform high above the sea in an upland chunk (base
*> temperature 0.3, so the air above y = 192 is below 0.15) a water source freezes to ice (not one surrounded by water; the freeze updates the neighbours, so water that then flows freezes too) and, while it rains, air above the platform gets a snow
*> layer. The cobolcraft world has neither water, ice nor snow, so the test adds them to the block table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-WORLDSIM-ICE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-WATER               BINARY-LONG.
 01 WS-ICE                 BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-ICE-AT-WATER        BINARY-LONG.
 01 WS-ICE-ELSEWHERE       BINARY-LONG.
 01 WS-SNOWS               BINARY-LONG.
 01 WS-STONE               BINARY-LONG VALUE 2.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-ENTITY-ROW(WS-ROW) TO WS-K
     MOVE -88.5 TO PL-X(WS-ROW) EN-X(WS-K)
     MOVE 8.5 TO PL-Z(WS-ROW) EN-Z(WS-K)
     MOVE -6 TO PL-CENTER-X(WS-ROW)
     MOVE 0 TO PL-CENTER-Z(WS-ROW)
     MOVE "T" TO TL-MODE
     MOVE "minecraft:water" TO WS-KEY
     MOVE 0 TO WS-SOLID
     MOVE 16 TO WS-COUNT
     PERFORM INSTALL
     MOVE WS-BASE TO WS-WATER
     MOVE "minecraft:ice" TO WS-KEY
     MOVE 1 TO WS-SOLID
     MOVE 1 TO WS-COUNT
     PERFORM INSTALL
     MOVE WS-BASE TO WS-ICE
     MOVE "minecraft:snow" TO WS-KEY
     MOVE 0 TO WS-SOLID
     PERFORM INSTALL
     MOVE WS-BASE TO WS-SNOW
*>   A platform at y 190 over chunk (-6, 0), water sources on every second cell at y 191 (written without hooks, so nothing flows).
     PERFORM VARYING WS-X FROM -96 BY 1 UNTIL WS-X > -81
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             MOVE 190 TO WS-Y
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
             IF FUNCTION MOD(WS-X + WS-Z, 2) = 0
                 MOVE 191 TO WS-Y
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WATER
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 1 TO CW-RAINING
     MOVE 900000 TO CW-RAIN-TIME CW-THUNDER-TIME
     MOVE 1.0 TO CW-RAIN-LEVEL(1)
     MOVE 1.0 TO CW-RAIN-LEVEL-OLD(1)

     MOVE "acceptance US12 33 4.4 given rain over a cold platform when 1500 ticks pass then some water sources have frozen and the air has snow layers"
         & " (water that melted its neighbours' ticks flowed on and froze too)" TO TL-CASE
     MOVE 1500 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 0 TO WS-ICE-AT-WATER WS-ICE-ELSEWHERE WS-SNOWS
     MOVE 191 TO WS-Y
     PERFORM VARYING WS-X FROM -96 BY 1 UNTIL WS-X > -81
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
             IF WS-STATE = WS-ICE
                 IF FUNCTION MOD(WS-X + WS-Z, 2) = 0
                     ADD 1 TO WS-ICE-AT-WATER
                 ELSE
                     ADD 1 TO WS-ICE-ELSEWHERE
                 END-IF
             END-IF
             IF WS-STATE = WS-SNOW
                 ADD 1 TO WS-SNOWS
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE SPACES TO TL-OBSERVED
     MOVE "no ice" TO TL-OBSERVED
     IF WS-ICE-AT-WATER > 0 AND WS-SNOWS > 0
         MOVE "ice and snow" TO TL-OBSERVED
     END-IF
     MOVE "ice and snow" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

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
 END PROGRAM ACC-US12-WORLDSIM-ICE.

 COPY CORETEST.
