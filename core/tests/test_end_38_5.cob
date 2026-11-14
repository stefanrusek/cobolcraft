*> Implementation test of the End's terrain fill (core/src/end-38.cob; T1729, T1730; docs/protocol/38-end.md section 5 and 13.1): the corner values
*> 0.64 * A_blend of the central island (S = 0.5625), and chunks of seed 0 made by END-GEN-CHUNK: only end_stone and air, nothing at y 128 and above
*> or at y 0 to 4 (constant air profile), the central island's column (0, 0) is solid in its middle and bounded below and above, the void
*> between the islands (chunk x 50) is empty, an outer island (chunk 187, -63) holds end_stone, and the result is deterministic.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-END-38-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY END.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-GOT                 BINARY-DOUBLE.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-TOL                 BINARY-LONG VALUE 20.
 01 WS-CHUNK               PIC X(304640).
 01 WS-CELL                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-COUNT2              BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-ED                  PIC -(5)9.
 01 WS-STATE               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM END-TABLES
     CALL "END-SETUP" USING WS-SEED
     MOVE 0.5625 TO WS-S
     MOVE 0 TO WS-Y
     MOVE -1500000 TO WS-WANT
     PERFORM CHECK-CORNER
     MOVE 4 TO WS-Y
     MOVE -1500000 TO WS-WANT
     PERFORM CHECK-CORNER
     MOVE 32 TO WS-Y
     MOVE 3600000 TO WS-WANT
     PERFORM CHECK-CORNER
     MOVE 56 TO WS-Y
     MOVE 3600000 TO WS-WANT
     PERFORM CHECK-CORNER
     MOVE 60 TO WS-Y
     MOVE 1200000 TO WS-WANT
     PERFORM CHECK-CORNER
     MOVE 64 TO WS-Y
     MOVE -1200000 TO WS-WANT
     PERFORM CHECK-CORNER
*>   the central island chunk
     MOVE 0 TO WS-CX WS-CZ
     CALL "END-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK
     PERFORM SCAN-CHUNK
     MOVE "acceptance US12 38§5 Terrain fill central chunk holds only end_stone and air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OTHER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§5 Terrain fill nothing at y 128 and above" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-HIGH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§5 Terrain fill nothing at y 0 to 4" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LOW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§5 Terrain fill marker y is -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WS-MARKER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 40 TO WS-Y
     PERFORM STATE-AT-8-8
     MOVE "acceptance US12 38§5 Terrain fill (8, 40, 8) of the central island is end_stone" TO TL-CASE
     MOVE 200 TO TL-EXPECTED-N
     MOVE WS-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COLUMN-BOUNDS
     MOVE "acceptance US12 38§5 Terrain fill the island's underside is above y 4" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BOTTOM > 4 AND WS-BOTTOM < 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§5 Terrain fill the island's top is between y 41 and 100" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TOP > 40 AND WS-TOP < 101
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   deterministic
     MOVE WS-COUNT TO WS-COUNT2
     CALL "END-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     PERFORM SCAN-CHUNK
     MOVE "acceptance US12 38§5 Terrain fill making a chunk twice gives the same solid count" TO TL-CASE
     MOVE WS-COUNT2 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the void between the islands
     MOVE 50 TO WS-CX
     CALL "END-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     PERFORM SCAN-CHUNK
     MOVE "acceptance US12 38§5 Terrain fill the void chunk (50, 0) is empty" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   an outer island
     MOVE 187 TO WS-CX
     MOVE -63 TO WS-CZ
     CALL "END-GEN-CHUNK" USING WS-SEED WS-CX WS-CZ WS-CHUNK WS-MARKER
     PERFORM SCAN-CHUNK
     MOVE "acceptance US12 38§5 Terrain fill the outer island chunk (187, -63) has end_stone" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 38§5 Terrain fill the outer island chunk has nothing at y 0 to 4 or 128 up" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-HIGH + WS-LOW + WS-OTHER
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 CHECK-CORNER.
     CALL "END-CORNER-VALUE" USING WS-Y WS-S WS-V
     MOVE WS-Y TO WS-ED
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 38§5 Terrain fill corner value 0.64 * A_blend at y " FUNCTION TRIM(WS-ED)
         " for S 0.5625" DELIMITED BY SIZE INTO TL-CASE
     PERFORM CHECK-V.
 SCAN-CHUNK.
     MOVE 0 TO WS-COUNT WS-OTHER WS-HIGH WS-LOW
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 65536
         IF CE-STATE(WS-CELL) NOT = 0
             COMPUTE WS-Y = (WS-CELL - 1) / 256
             IF CE-STATE(WS-CELL) = 200
                 ADD 1 TO WS-COUNT
             ELSE
                 ADD 1 TO WS-OTHER
             END-IF
             IF WS-Y > 127
                 ADD 1 TO WS-HIGH
             END-IF
             IF WS-Y < 5
                 ADD 1 TO WS-LOW
             END-IF
         END-IF
     END-PERFORM.
 STATE-AT-8-8.
     COMPUTE WS-CELL = WS-Y * 256 + 8 * 16 + 8 + 1
     MOVE CE-STATE(WS-CELL) TO WS-STATE.
 COLUMN-BOUNDS.
     MOVE 999 TO WS-BOTTOM
     MOVE -1 TO WS-TOP
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 255
         COMPUTE WS-CELL = WS-Y * 256 + 8 * 16 + 8 + 1
         IF CE-STATE(WS-CELL) NOT = 0
             IF WS-Y < WS-BOTTOM
                 MOVE WS-Y TO WS-BOTTOM
             END-IF
             MOVE WS-Y TO WS-TOP
         END-IF
     END-PERFORM.
 COPY ENDTEST.
