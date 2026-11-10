*> Implementation test (T0446; docs/design/debug-world.md section 6): a chunk of a `debug` world, asked
*> through the generator dispatch of the standard overworld (WORLDGEN-DIM-CHUNK, the world type from the
*> settings), runs no noise, climate, density, aquifer, surface, carver, ore or feature stage (the stage
*> counters of GENSTAGE.cpy stay 0, the noise store stays empty), and a chunk outside the grid is empty.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DEBUG-NO-TERRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY NOISE.
 COPY GENSTAGE.
 COPY CELLS.
 01 WS-MEM                 PIC X(304640).
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "debug" TO CS-WORLD-TYPE
     MOVE CORE-SETTINGS TO CW-SETTINGS
     INITIALIZE GEN-STAGES
     CALL "NOISE-RESET"
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-MEM

     MOVE "test debug no terrain the dispatch of a debug chunk builds the grid chunk (floor 1, state 7704 at its corner)" TO TL-CASE
     MOVE 3 TO WS-CX
     MOVE 5 TO WS-CZ
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
     COMPUTE WS-CELL = (69 + 64) * 256 + 1
     COMPUTE TL-OBSERVED-N = CE-STATE(WS-CELL) * 1000 + CE-STATE((70 + 64) * 256 + 1)
     MOVE 8704 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test debug no terrain no stage counter moved" TO TL-CASE
     COMPUTE TL-OBSERVED-N = GS-NOISE + GS-CLIMATE + GS-DENSITY + GS-AQUIFER + GS-SURFACE
         + GS-CARVER + GS-ORE + GS-FEATURE
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test debug no terrain the noise store is still empty" TO TL-CASE
     COMPUTE TL-OBSERVED-N = NZ-PERLIN-COUNT + NZ-LAYER-COUNT + NZ-NOISE-COUNT
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test debug no terrain a chunk outside the grid is empty" TO TL-CASE
     MOVE 100 TO WS-CX
     MOVE -100 TO WS-CZ
     MOVE X"01" TO WS-MEM(1:1)
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 98304
         ADD CE-STATE(WS-I) TO WS-SUM
     END-PERFORM
     MOVE WS-SUM TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test debug no terrain a standard world type gets the void placeholder, not the grid" TO TL-CASE
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE 3 TO WS-CX
     MOVE 5 TO WS-CZ
     CALL "WORLDGEN-DIM-CHUNK" USING WS-DIM WS-CX WS-CZ WS-MEM WS-MARKER
     MOVE CE-STATE((69 + 64) * 256 + 1) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DEBUG-NO-TERRAIN.

 COPY CORETEST.
