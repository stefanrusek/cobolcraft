*> Acceptance test of the world spawn search of docs/protocol/33 section 6.2 wired into world creation and the join (specs 002 phase 41): the first column of the
*> first chunk with a respawn position becomes the world spawn (the highest block's top, at the cell's centre), a column whose surface is water over a lower floor
*> is skipped (the next column of the chunk, x outer and z inner), and a player who joins stands at the spawn. A standard world cannot be generated in a test, so the
*> world is opened as cobolcraft and its type is set to standard before the search is run through the production entry (CORE-WORLD-OPEN runs it for a new standard
*> world); the cobolcraft world has no water, so the test adds the liquid block to the block table.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-WORLDSIM-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "standard" TO CW-WORLD-TYPE
     MOVE "T" TO TL-MODE

     MOVE "acceptance US12 33 6.2 given a new world when the initial spawn is searched then it is the centre of the cell above the highest block of column (0, 0)"
         TO TL-CASE
     CALL "WORLDSIM-INITIAL-SPAWN"
     PERFORM TOP-OF-COLUMN-0-0
     MOVE CW-SPAWN-X TO WS-N
     COMPUTE WS-EDIT = CW-SPAWN-X * 10
     COMPUTE WS-EDIT2 = CW-SPAWN-Y
     COMPUTE WS-EDIT3 = CW-SPAWN-Z * 10
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-TOP TO WS-EDIT2
     MOVE SPACES TO TL-EXPECTED
     STRING "5 " FUNCTION TRIM(WS-EDIT2) " 5" DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 33 6.2 given water over the first column when the spawn is searched then that column is skipped and the next one of the chunk (z + 1) is used"
         TO TL-CASE
     PERFORM INSTALL-WATER
     MOVE 0 TO WS-X WS-Z
     MOVE WS-TOP TO WS-Y
     MOVE WS-WATER TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "WORLDSIM-INITIAL-SPAWN"
     COMPUTE WS-EDIT = CW-SPAWN-X * 10
     COMPUTE WS-EDIT3 = CW-SPAWN-Z * 10
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "5 15" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 33 6.2 given the world spawn when a player joins then she stands at it" TO TL-CASE
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     COMPUTE WS-EDIT = PL-X(WS-ROW) * 10
     COMPUTE WS-EDIT3 = PL-Z(WS-ROW) * 10
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT3) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "5 15" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-TOP: the y of the cell above the highest non-void block of column (0, 0), found from the top of the world.
 TOP-OF-COLUMN-0-0.
     MOVE 0 TO WS-X WS-Z
     COMPUTE WS-Y = DM-MIN-Y(WS-DIM) + DM-HEIGHT(WS-DIM) - 1
     MOVE 0 TO WS-STATE
     PERFORM UNTIL WS-STATE NOT = 0 OR WS-Y < DM-MIN-Y(WS-DIM)
         CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
         IF WS-STATE = 0
             SUBTRACT 1 FROM WS-Y
         END-IF
     END-PERFORM
     COMPUTE WS-TOP = WS-Y + 1.

 INSTALL-WATER.
     COMPUTE WS-N = CB-BLOCK-COUNT + 1
     MOVE "minecraft:water" TO CB-KEY(WS-N)
     MOVE 15 TO CB-KEY-LENGTH(WS-N)
     MOVE 0 TO CB-SOLID(WS-N) CB-OPAQUE(WS-N) CB-LIGHT(WS-N) CB-CLASS(WS-N) CB-TOOL-REQ(WS-N) CB-NEED-TIER(WS-N)
     MOVE -1 TO CB-BREAK-MS(WS-N)
     MOVE CB-STATE-COUNT TO WS-WATER
     MOVE WS-WATER TO CB-FIRST-STATE(WS-N) CB-DEFAULT-STATE(WS-N)
     MOVE 16 TO CB-STATES(WS-N)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
         COMPUTE CB-S-BLOCK(WS-WATER + WS-K) = WS-N - 1
         MOVE 0 TO CB-S-LIGHT(WS-WATER + WS-K)
     END-PERFORM
     ADD 1 TO CB-BLOCK-COUNT
     ADD 16 TO CB-STATE-COUNT
     ADD 1 TO CB-EPOCH.
 END PROGRAM ACC-US12-WORLDSIM-SPAWN.

 COPY CORETEST.
