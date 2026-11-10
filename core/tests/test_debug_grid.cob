*> Implementation test of the debug world generator (core/src/worldgen-debug.cob; T0444; docs/design/debug-world.md
*> sections 2 to 5): over chunks (0, 0) to (23, 23) every block state of the standard set (35723 states of
*> 1286 blocks, 24 part 1 section 17 and 46) appears exactly once, at x = 2 * (s mod 192), y = 70,
*> z = 2 * (s div 192), in state-id order; every other block of y = 70 is air; the floor of stone at y = 69
*> covers chunks -1 to 24 and nothing is generated outside them; the biome is plains everywhere.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DEBUG-GRID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-MEM                 PIC X(304640).
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-NONAIR              BINARY-LONG.
 01 WS-SEEN-TABLE.
    05 WS-SEEN             BINARY-CHAR UNSIGNED OCCURS 35723 TIMES.
 01 WS-BLOCK-TABLE.
    05 WS-BLOCK-SEEN       BINARY-CHAR UNSIGNED OCCURS 1286 TIMES.
 01 WS-BLOCKS              BINARY-LONG.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DOUBLES             BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO CT-SET-TYPE
     MOVE 1 TO CT-OPEN
     CALL "CONTENT-SET-COUNTS"
     MOVE 0 TO CBI-COUNT
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-MEM

     MOVE "test debug grid the standard set has 1286 blocks and 35723 states" TO TL-CASE
     COMPUTE TL-OBSERVED-N = CT-BLOCK-COUNT * 100000 + CT-STATE-COUNT
     MOVE 128635723 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-BAD WS-NONAIR
     PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 23
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 23
             CALL "WORLDGEN-DEBUG-CHUNK" USING WS-CX WS-CZ WS-MEM WS-MARKER
             PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
                 PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
                     COMPUTE WS-X = WS-CX * 16 + WS-LX
                     COMPUTE WS-Z = WS-CZ * 16 + WS-LZ
                     COMPUTE WS-CELL = (70 + 64) * 256 + WS-LZ * 16 + WS-LX + 1
                     MOVE CE-STATE(WS-CELL) TO WS-STATE
                     MOVE 0 TO WS-EXPECT
                     IF FUNCTION MOD(WS-X, 2) = 0 AND FUNCTION MOD(WS-Z, 2) = 0
                         COMPUTE WS-COL = WS-X / 2
                         COMPUTE WS-ROW = WS-Z / 2
                         COMPUTE WS-EXPECT = WS-ROW * 192 + WS-COL
                         IF WS-COL >= 192 OR WS-EXPECT >= 35723
                             MOVE 0 TO WS-EXPECT
                         END-IF
                     END-IF
                     IF WS-STATE NOT = WS-EXPECT
                         ADD 1 TO WS-BAD
                     END-IF
                     IF WS-STATE > 0
                         ADD 1 TO WS-NONAIR
                         IF WS-STATE < 35723
                             ADD 1 TO WS-SEEN(WS-STATE + 1)
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM

     MOVE "test debug grid every cell of y = 70 is the state of the formula or air" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test debug grid 35722 non-air cells, every state 1 to 35722 exactly once" TO TL-CASE
     MOVE 0 TO WS-DOUBLES
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 35723
         IF WS-SEEN(WS-I) NOT = 1
             ADD 1 TO WS-DOUBLES
         END-IF
     END-PERFORM
     COMPUTE TL-OBSERVED-N = WS-NONAIR * 1000 + WS-DOUBLES
     MOVE 35722000 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test debug grid the states belong to all 1286 blocks" TO TL-CASE
     MOVE 0 TO WS-BLOCKS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 35722
         MOVE WS-I TO WS-STATE
         CALL "CONTENT-BLOCK-OF-STATE" USING WS-STATE WS-BLOCK-ID WS-INDEX WS-BLOCK-ROW WS-STATUS
         IF WS-BLOCK-SEEN(WS-BLOCK-ID + 1) = 0
             MOVE 1 TO WS-BLOCK-SEEN(WS-BLOCK-ID + 1)
             ADD 1 TO WS-BLOCKS
         END-IF
     END-PERFORM
     MOVE WS-BLOCKS TO TL-OBSERVED-N
     MOVE 1286 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Worked examples of 3.1: the last state, its chunk (1, 23), local (4, 6, 4).
     MOVE "test debug grid state 35722 is at (20, 70, 372), chunk (1, 23) local (4, 4)" TO TL-CASE
     MOVE 1 TO WS-CX
     MOVE 23 TO WS-CZ
     CALL "WORLDGEN-DEBUG-CHUNK" USING WS-CX WS-CZ WS-MEM WS-MARKER
     COMPUTE WS-CELL = (70 + 64) * 256 + 4 * 16 + 4 + 1
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     MOVE 35722 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test debug grid the cell after the last state (22, 70, 372) is air" TO TL-CASE
     COMPUTE WS-CELL = (70 + 64) * 256 + 4 * 16 + 6 + 1
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "test debug grid the cell next to state 35722 on the odd column (21, 70, 372) is air" TO TL-CASE
     COMPUTE WS-CELL = (70 + 64) * 256 + 4 * 16 + 5 + 1
     MOVE CE-STATE(WS-CELL) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The floor and the all-air chunk outside it.
     MOVE "test debug grid the floor of stone (state 1) at y = 69 in chunks -1 to 24" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-CX FROM -1 BY 1 UNTIL WS-CX > 24
         PERFORM VARYING WS-CZ FROM -1 BY 1 UNTIL WS-CZ > 24
             CALL "WORLDGEN-DEBUG-CHUNK" USING WS-CX WS-CZ WS-MEM WS-MARKER
             PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 255
                 COMPUTE WS-CELL = (69 + 64) * 256 + WS-I + 1
                 IF CE-STATE(WS-CELL) NOT = 1
                     ADD 1 TO WS-BAD
                 END-IF
                 COMPUTE WS-CELL = (68 + 64) * 256 + WS-I + 1
                 IF CE-STATE(WS-CELL) NOT = 0
                     ADD 1 TO WS-BAD
                 END-IF
                 COMPUTE WS-CELL = (71 + 64) * 256 + WS-I + 1
                 IF CE-STATE(WS-CELL) NOT = 0
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test debug grid chunks outside -1 to 24 are all air" TO TL-CASE
     MOVE 25 TO WS-CX
     MOVE 0 TO WS-CZ
     MOVE LOW-VALUES TO WS-MEM
     MOVE X"01" TO WS-MEM(1:1)
     CALL "WORLDGEN-DEBUG-CHUNK" USING WS-CX WS-CZ WS-MEM WS-MARKER
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 98304
         IF CE-STATE(WS-CELL) NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE -2 TO WS-CX
     MOVE -2 TO WS-CZ
     MOVE X"01" TO WS-MEM(1:1)
     CALL "WORLDGEN-DEBUG-CHUNK" USING WS-CX WS-CZ WS-MEM WS-MARKER
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 98304
         IF CE-STATE(WS-CELL) NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test debug grid biome cells hold plains of the biome table (registry row 7, id 6)" TO TL-CASE
     MOVE 8 TO CBI-COUNT
     MOVE "minecraft:plains" TO CBI-KEY(7)
     MOVE 16 TO CBI-KEY-LENGTH(7)
     MOVE 0 TO WS-CX WS-CZ
     CALL "WORLDGEN-DEBUG-CHUNK" USING WS-CX WS-CZ WS-MEM WS-MARKER
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         IF CE-BIOME(WS-I) NOT = 6
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test debug grid the marker out is -1 (no light source recorded)" TO TL-CASE
     MOVE WS-MARKER TO TL-OBSERVED-N
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DEBUG-GRID.
