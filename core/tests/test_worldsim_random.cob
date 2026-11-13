*> Test of WORLDSIM-RANDOM (core/src/worldsim-33.cob; 33 section 2.4 random ticks): on a world of the test fixtures, one layer of
*> randomly ticking blocks in a section of each chunk near the player and a raised random_tick_speed, one run of the
*> random ticks draws the same positions from the level's random in the same order and ticks the same ones as before the
*> loop was made cheaper (the golden values below were taken from the loop that called BR-VISIT, BT-CHUNK-TICKS and
*> BR-RANDOM-TICK for every chunk and position): the level's random value after the run and the hooks called.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLDSIM-RANDOM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY BUSTATE.
 COPY WSIM.
 COPY PROTO.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 40.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-GS                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG VALUE 0.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-L                  BINARY-LONG.
 01 WS-LS                 BINARY-LONG.
 01 WS-ROWNO               BINARY-LONG.
 01 WS-ZERO-ROW            BINARY-LONG VALUE 0.
 01 WS-TRACE-A             PIC X(512).
 01 WS-TRACE-B             PIC X(512).
 01 WS-LEN-B               BINARY-LONG.
 01 WS-LEN-A               BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CR-GREYSTONE TO WS-G
     MOVE CB-DEFAULT-STATE(WS-G + 1) TO WS-GS
     CALL "BU-ENSURE"
     MOVE 11 TO WS-KIND
     CALL "BU-RULE-ADD" USING WS-KIND WS-G WS-EFFECT WS-ARG WS-FLAGS
     CALL "WORLDSIM-ENSURE"
     MOVE 400 TO WSM-SPEED
     MOVE 1013904223 TO WSM-RAND(1)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
*>   A layer of 16 x 16 ticking blocks at y 40 in each chunk of the 5 x 5 chunks around the origin.
     PERFORM VARYING WS-AX FROM -2 BY 1 UNTIL WS-AX > 2
         PERFORM VARYING WS-AZ FROM -2 BY 1 UNTIL WS-AZ > 2
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
                     COMPUTE WS-BX = WS-AX * 16 + WS-X
                     COMPUTE WS-BZ = WS-AZ * 16 + WS-Z
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-Y WS-BZ WS-GS
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "BU-RESET-TRACE"
     MOVE 1 TO BU-TRACE-ON
     CALL "WORLDSIM-RANDOM" USING WS-DIM
     MOVE 0 TO BU-TRACE-ON
     MOVE WSM-RAND(1) TO WS-E1
     MOVE BU-TRACE-LENGTH TO WS-E2
     MOVE "worldsim-random given 25 chunks with a layer of ticking blocks and 400 positions a section when one run of the "
         & "random ticks is done then the level random and the hook count are the golden ones" TO TL-CASE
     MOVE "T" TO TL-MODE
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "-469635457 16384" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   BR-RANDOM-TICK-ROW calls the same hooks as BR-RANDOM-TICK for a ticking block and for air (which has no rule).
     MOVE 0 TO WS-BX
     MOVE 0 TO WS-BZ
     MOVE 0 TO WS-AX WS-AZ
     CALL "WORLD-FIND" USING WS-DIM WS-AX WS-AZ WS-ROWNO
     CALL "BR-RANDOM-TICK-ROW" USING WS-DIM WS-ZERO-ROW WS-BX WS-Y WS-BZ
     CALL "BU-RESET-TRACE"
     MOVE 1 TO BU-TRACE-ON
     CALL "BR-RANDOM-TICK" USING WS-DIM WS-BX WS-Y WS-BZ
     MOVE SPACES TO WS-TRACE-A
     MOVE BU-TRACE(1:BU-TRACE-LENGTH) TO WS-TRACE-A
     MOVE BU-TRACE-LENGTH TO WS-LEN-A
     MOVE 41 TO WS-Y
     CALL "BR-RANDOM-TICK" USING WS-DIM WS-BX WS-Y WS-BZ
     MOVE 0 TO BU-TRACE-ON
     MOVE SPACES TO WS-TRACE-B
     MOVE BU-TRACE(WS-LEN-A + 1:BU-TRACE-LENGTH - WS-LEN-A) TO WS-TRACE-B
     COMPUTE WS-LEN-B = BU-TRACE-LENGTH - WS-LEN-A
     CALL "BU-RESET-TRACE"
     MOVE 1 TO BU-TRACE-ON
     MOVE 40 TO WS-Y
     CALL "BR-RANDOM-TICK-ROW" USING WS-DIM WS-ROWNO WS-BX WS-Y WS-BZ
     CALL "BR-RANDOM-TICK-ROW" USING WS-DIM WS-ROWNO WS-BX WS-Y WS-BZ
     MOVE 41 TO WS-Y
     CALL "BR-RANDOM-TICK-ROW" USING WS-DIM WS-ROWNO WS-BX WS-Y WS-BZ
     MOVE 0 TO BU-TRACE-ON
     MOVE "worldsim-random given a ticking block and air when BR-RANDOM-TICK-ROW ticks them (the block twice, the second from "
         & "the kept marks) then the hooks called are those of BR-RANDOM-TICK, twice for the block" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     STRING WS-TRACE-A(1:WS-LEN-A) WS-TRACE-A(1:WS-LEN-A) WS-TRACE-B(1:WS-LEN-B) DELIMITED BY SIZE
         INTO TL-EXPECTED
     MOVE BU-TRACE(1:BU-TRACE-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A fluid that ticks: the second hook (the fluid's) is called too, as BR-RANDOM-TICK calls it.
     MOVE 13 TO WS-KIND
     MOVE CR-LUCITE TO WS-L
     CALL "BU-RULE-ADD" USING WS-KIND WS-L WS-EFFECT WS-ARG WS-FLAGS
     MOVE CB-DEFAULT-STATE(WS-L + 1) TO WS-LS
     MOVE 2 TO WS-BX
     MOVE 2 TO WS-BZ
     MOVE 40 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-Y WS-BZ WS-LS
     CALL "BR-RANDOM-TICK-ROW" USING WS-DIM WS-ZERO-ROW WS-BX WS-Y WS-BZ
     CALL "BU-RESET-TRACE"
     MOVE 1 TO BU-TRACE-ON
     CALL "BR-RANDOM-TICK" USING WS-DIM WS-BX WS-Y WS-BZ
     MOVE 0 TO BU-TRACE-ON
     MOVE SPACES TO WS-TRACE-A
     MOVE BU-TRACE(1:BU-TRACE-LENGTH) TO WS-TRACE-A
     MOVE BU-TRACE-LENGTH TO WS-LEN-A
     CALL "BU-RESET-TRACE"
     MOVE 1 TO BU-TRACE-ON
     CALL "BR-RANDOM-TICK-ROW" USING WS-DIM WS-ROWNO WS-BX WS-Y WS-BZ
     MOVE 0 TO BU-TRACE-ON
     MOVE "worldsim-random given a block whose fluid ticks when BR-RANDOM-TICK-ROW ticks it then the hooks called are those of "
         & "BR-RANDOM-TICK (the block's and the fluid's)" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE WS-TRACE-A(1:WS-LEN-A) TO TL-EXPECTED
     MOVE BU-TRACE(1:BU-TRACE-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-WORLDSIM-RANDOM.

 COPY CORETEST.
