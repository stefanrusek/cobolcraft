*> Acceptance test of the spawn area and the loading-screen state (docs/protocol/50 sections 4, 5; docs/design/generation-worker.md): after the spawn search the
*> 7 x 7 chunks around the spawn chunk are made before a held client joins; GEN-LOAD-PROGRESS gives the state, the chunks ready and the progress in
*> thousandths (0 while the search runs, then floor((10 + ready) * 1000 / 59), 1000 at the end); GEN-LOAD-GRID gives the status code of each cell of the
*> 35 x 35 grid around the focus chunk (0 none, 1 EMPTY for a chunk of the area still to be made, 10 FULL for a loaded chunk).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-GEN-LOAD-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY GENQUEUE.
 COPY GENSTAGE.
 COPY PROTO.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-WORKERS             BINARY-LONG VALUE 1.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MAX                 BINARY-LONG VALUE 16.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-PATH                PIC X(256).
 01 WS-STATE               BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-PERMILLE            BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-GRID                PIC X(1225).
 01 WS-I                   BINARY-LONG.
 01 WS-FULLS               BINARY-LONG.
 01 WS-EMPTIES             BINARY-LONG.
 01 WS-OTHERS              BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-LOADED              BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-GEN-FIXTURE"
     MOVE "standard" TO CW-WORLD-TYPE
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "WORLDSIM-NEW-WORLD-SPAWN"

     CALL "GEN-LOAD-PROGRESS" USING WS-STATE WS-READY WS-TOTAL WS-PERMILLE WS-FX WS-FZ
     MOVE "acceptance gen load given the search just begun then the state is 1, nothing ready, progress 0, focus the origin chunk" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-STATE * 1000000 + WS-READY * 10000 + WS-PERMILLE * 10 + WS-FX + WS-FZ
     MOVE 1000000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM CONFIGURE-CLIENT
     MOVE 0 TO WS-TICKS WS-SEEN
     PERFORM UNTIL GQ-SP-STATE NOT = 1 OR WS-TICKS > 3000
         CALL "GEN-QUEUE-TICK"
         CALL "GEN-SPAWN-TICK"
         ADD 1 TO WS-TICKS
     END-PERFORM
     CALL "GEN-LOAD-PROGRESS" USING WS-STATE WS-READY WS-TOTAL WS-PERMILLE WS-FX WS-FZ
     MOVE "acceptance gen load given the spawn found when the search ends then the spawn area is being made: state 2, 49 chunks in all, the client still held" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-STATE * 1000 + WS-TOTAL * 10 + FUNCTION MIN(CN-PHASE(WS-CONN), 9)
     COMPUTE TL-EXPECTED-N = 2000 + 490 + PH-CONFIG
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance gen load given the spawn chunk when the area starts then the focus is the chunk of the spawn" TO TL-CASE
     COMPUTE WS-CX = FUNCTION INTEGER(CW-SPAWN-X / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(CW-SPAWN-Z / 16)
     COMPUTE TL-OBSERVED-N = (WS-FX - WS-CX) * 10 + (WS-FZ - WS-CZ)
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   tick by tick: the progress follows the chunks ready, the grid shows each chunk of the area as EMPTY or FULL, the client stays held until the last chunk
     MOVE 0 TO WS-TICKS
     MOVE 0 TO WS-SEEN
     PERFORM UNTIL GQ-SP-STATE = 0 OR WS-TICKS > 3000
         CALL "GEN-LOAD-PROGRESS" USING WS-STATE WS-READY WS-TOTAL WS-PERMILLE WS-FX WS-FZ
         COMPUTE WS-EXPECT = (10 + WS-READY) * 1000 / 59
         IF WS-PERMILLE NOT = WS-EXPECT
             ADD 1 TO WS-SEEN
         END-IF
         IF CN-PHASE(WS-CONN) NOT = PH-CONFIG
             ADD 1 TO WS-SEEN
         END-IF
         CALL "GEN-LOAD-GRID" USING WS-GRID
         PERFORM COUNT-GRID
         IF WS-FULLS NOT = WS-READY OR WS-FULLS + WS-EMPTIES NOT = 49 OR WS-OTHERS NOT = 0
             ADD 1 TO WS-SEEN
         END-IF
         CALL "GEN-QUEUE-TICK"
         CALL "GEN-SPAWN-TICK"
         ADD 1 TO WS-TICKS
     END-PERFORM
     MOVE "acceptance gen load given the area being made when each tick passes then progress, ready count and grid agree and the client stays held" TO TL-CASE
     MOVE WS-SEEN TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the end: all 49 loaded, the client let go on to play, progress 1000
     PERFORM FINISH-CLIENT
     MOVE 0 TO WS-LOADED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 49
         CALL "WP-SPIRAL" USING WS-I WS-CX WS-CZ
         COMPUTE WS-CX = WS-CX + WS-FX
         COMPUTE WS-CZ = WS-CZ + WS-FZ
         CALL "WORLD-FIND" USING CW-DIM(1) WS-CX WS-CZ WS-ROW
         IF WS-ROW > 0
             ADD 1 TO WS-LOADED
         END-IF
     END-PERFORM
     MOVE "acceptance gen load given the area done when the last chunk is loaded then all 49 chunks are loaded and the client is in play" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-LOADED * 10 + CN-PHASE(WS-CONN)
     COMPUTE TL-EXPECTED-N = 490 + PH-PLAY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GEN-LOAD-PROGRESS" USING WS-STATE WS-READY WS-TOTAL WS-PERMILLE WS-FX WS-FZ
     MOVE "acceptance gen load given the area done then the state is 0 and the progress 1000" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-STATE * 10000 + WS-PERMILLE
     MOVE 1000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the grid during the search shows the chunk being searched as EMPTY
     CALL "TEST-GEN-FIXTURE"
     MOVE "standard" TO CW-WORLD-TYPE
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "WORLDSIM-NEW-WORLD-SPAWN"
     CALL "GEN-LOAD-GRID" USING WS-GRID
     PERFORM COUNT-GRID
     MOVE "acceptance gen load given the search begun when the grid is read then the chunks looked at are EMPTY and the others none" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-FULLS * 10000 + WS-EMPTIES * 100 + WS-OTHERS
     MOVE 100 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   an existing world: its spawn area is made too (no search), around the chunk of the world spawn, before a held client joins; with no workers nothing is held
     CALL "TEST-GEN-FIXTURE"
     MOVE "standard" TO CW-WORLD-TYPE
     MOVE 40.5 TO CW-SPAWN-X
     MOVE 64 TO CW-SPAWN-Y
     MOVE -20.5 TO CW-SPAWN-Z
     MOVE 0 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "GEN-SPAWN-OPEN"
     MOVE "acceptance gen load given no workers when an existing world opens then no spawn area is held" TO TL-CASE
     MOVE GQ-SP-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-WORKERS
     CALL "GEN-WORKERS-CONFIG" USING WS-WORKERS
     CALL "GEN-SPAWN-OPEN"
     CALL "GEN-LOAD-PROGRESS" USING WS-STATE WS-READY WS-TOTAL WS-PERMILLE WS-FX WS-FZ
     MOVE "acceptance gen load given workers when an existing world opens then the spawn area around the chunk of the world spawn is made: state 2, focus (2, -2)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-STATE * 10000 + (WS-FX + 10) * 100 + WS-FZ + 10
     COMPUTE TL-EXPECTED-N = 20000 + 1200 + 8
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CONFIGURE-CLIENT
     MOVE 0 TO WS-TICKS
     PERFORM UNTIL GQ-SP-STATE = 0 OR WS-TICKS > 3000
         CALL "GEN-QUEUE-TICK"
         CALL "GEN-SPAWN-TICK"
         ADD 1 TO WS-TICKS
     END-PERFORM
     PERFORM FINISH-CLIENT
     MOVE 0 TO WS-LOADED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 49
         CALL "WP-SPIRAL" USING WS-I WS-CX WS-CZ
         COMPUTE WS-CX = WS-CX + 2
         COMPUTE WS-CZ = WS-CZ - 2
         CALL "WORLD-FIND" USING CW-DIM(1) WS-CX WS-CZ WS-ROW
         IF WS-ROW > 0
             ADD 1 TO WS-LOADED
         END-IF
     END-PERFORM
     MOVE "acceptance gen load given the area of an existing world done then all 49 chunks are loaded and the held client is in play" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-LOADED * 10 + CN-PHASE(WS-CONN)
     COMPUTE TL-EXPECTED-N = 490 + PH-PLAY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-FULLS, WS-EMPTIES: cells of code 10 and 1; WS-OTHERS: cells of any other code than 0.
 COUNT-GRID.
     MOVE 0 TO WS-FULLS WS-EMPTIES WS-OTHERS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1225
         COMPUTE WS-CODE = FUNCTION ORD(WS-GRID(WS-I:1)) - 1
         EVALUATE TRUE
             WHEN WS-CODE = 10
                 ADD 1 TO WS-FULLS
             WHEN WS-CODE = 1
                 ADD 1 TO WS-EMPTIES
             WHEN WS-CODE NOT = 0
                 ADD 1 TO WS-OTHERS
         END-EVALUATE
     END-PERFORM.

 FINISH-CLIENT.
     MOVE "contract/fixtures/wire/config-c2s-03-finish-configuration.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH.

 CONFIGURE-CLIENT.
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-CONN
     MOVE "contract/fixtures/wire/handshake-c2s-00-intention-login.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-STRING" USING PB-BUFFER WS-NAME WS-NAME-LENGTH WS-MAX
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER
     MOVE "contract/fixtures/wire/login-c2s-03-login-acknowledged.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-02-custom-payload-brand.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-00-client-information.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     MOVE "contract/fixtures/wire/config-c2s-07-select-known-packs.hex" TO WS-PATH
     CALL "TEST-FEED" USING WS-CONN WS-PATH
     CALL "PB-FREE" USING PB-BUFFER.
 END PROGRAM ACC-GEN-LOAD-STATE.
 COPY CORETEST.
 COPY GENFIXTURE.
