*> The inner loops of WORLDSIM-RANDOM (33 section 2.4) without decimal arithmetic (lane bugsw T10302): random_tick_speed 1000 made one tick cost hundreds of milliseconds, because each
*> randomBlockPos went through FUNCTION MOD and FUNCTION INTEGER (gmp). The level's randValue steps as randValue * 3 + 1013904223 in 32-bit wrapping arithmetic; here that is three additions and
*> a wrap by compare, and the position and the draw are read from the bytes of the new value (the machine's byte order is little-endian, as everywhere in the cells): with i = randValue >> 2, x is
*> bits 2 to 5 of the value, z bits 10 to 13 and y bits 18 to 21 (the mask 15 of a section), the draw nextInt(48) input is |randValue| >> 16 modulo 48. The results equal WL-RANDOM-POS's.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WL-PRECIP-RUN.
*> USING dimension, chunk x0, z0 (block coordinates of the chunk's west-north corner), count, raining (BINARY-LONG): count times one randomBlockPos step of the level's randValue (WSM-RAND) and the
*> 1 in 48 draw of it; a draw of 0 is a precipitation attempt at the position's column (WORLDSIM-PRECIPITATION), as the loop of WORLDSIM-RANDOM made it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY WSIM.
 01 WS-INIT                BINARY-LONG VALUE 0.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-W                   BINARY-DOUBLE.
 01 WS-C                   BINARY-DOUBLE VALUE 1013904223.
 01 WS-P32                 BINARY-DOUBLE VALUE 4294967296.
 01 WS-HIGH                BINARY-DOUBLE VALUE 2147483647.
 01 WS-LOW                 BINARY-DOUBLE VALUE -2147483648.
 01 WS-N                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-COUNTER             BINARY-LONG.
 01 WS-U                   BINARY-LONG UNSIGNED.
 01 WS-UB REDEFINES WS-U.
    05 WS-B0               BINARY-CHAR UNSIGNED.
    05 WS-B1               BINARY-CHAR UNSIGNED.
    05 WS-B2               BINARY-CHAR UNSIGNED.
    05 WS-B3               BINARY-CHAR UNSIGNED.
 01 WS-A                   BINARY-LONG UNSIGNED.
 01 WS-AH REDEFINES WS-A.
    05 WS-AL               BINARY-SHORT UNSIGNED.
    05 WS-A-HIGH           BINARY-SHORT UNSIGNED.
 01 WS-NIB-TABLE.
    05 WS-NIB              BINARY-CHAR UNSIGNED OCCURS 256 TIMES.
 01 WS-DRAW-TABLE.
    05 WS-DRAW             BINARY-CHAR UNSIGNED OCCURS 32769 TIMES.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-RAINING              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X0 L-Z0 L-COUNT L-RAINING.
     IF WS-INIT = 0
         MOVE 1 TO WS-INIT
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 255
             DIVIDE WS-K BY 4 GIVING WS-N
             DIVIDE WS-N BY 16 GIVING WS-R REMAINDER WS-N
             MOVE WS-N TO WS-NIB(WS-K + 1)
         END-PERFORM
         MOVE 0 TO WS-COUNTER
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 32769
             MOVE WS-COUNTER TO WS-DRAW(WS-K)
             ADD 1 TO WS-COUNTER
             IF WS-COUNTER = 48
                 MOVE 0 TO WS-COUNTER
             END-IF
         END-PERFORM
     END-IF
     MOVE WSM-RAND(L-DIM) TO WS-R
     PERFORM L-COUNT TIMES
         MOVE WS-R TO WS-V
         ADD WS-R TO WS-V
         ADD WS-R TO WS-V
         ADD WS-C TO WS-V
         PERFORM UNTIL WS-V <= WS-HIGH
             SUBTRACT WS-P32 FROM WS-V
         END-PERFORM
         PERFORM UNTIL WS-V >= WS-LOW
             ADD WS-P32 TO WS-V
         END-PERFORM
         MOVE WS-V TO WS-R
         MOVE WS-V TO WS-W
         IF WS-W < 0
             ADD WS-P32 TO WS-W
         END-IF
         MOVE WS-W TO WS-U
         MOVE WS-V TO WS-W
         IF WS-W < 0
             MULTIPLY -1 BY WS-W
         END-IF
         MOVE WS-W TO WS-A
         IF WS-DRAW(WS-A-HIGH + 1) = 0
             MOVE L-X0 TO WS-X
             ADD WS-NIB(WS-B0 + 1) TO WS-X
             MOVE L-Z0 TO WS-Z
             ADD WS-NIB(WS-B1 + 1) TO WS-Z
             CALL "WORLDSIM-PRECIPITATION" USING L-DIM WS-X WS-Z L-RAINING
         END-IF
     END-PERFORM
     MOVE WS-R TO WSM-RAND(L-DIM)
     GOBACK.
 END PROGRAM WL-PRECIP-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WL-SECTION-RUN.
*> USING dimension, chunk row (0 forgets the marks of the states, as BR-RANDOM-TICK-ROW does), section start x0, y0, z0 (block coordinates), count (BINARY-LONG): count times one randomBlockPos step
*> and, when the state in that cell has a random-ticking block or fluid (marks kept per state for the run), BR-RANDOM-TICK-ROW for the position, in the order the loop of WORLDSIM-RANDOM made them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CELLS.
 COPY WSIM.
 01 K-11B                  BINARY-LONG VALUE 11.
 01 K-13                   BINARY-LONG VALUE 13.
 01 WS-INIT                BINARY-LONG VALUE 0.
 01 WS-V                   BINARY-DOUBLE.
 01 WS-W                   BINARY-DOUBLE.
 01 WS-C                   BINARY-DOUBLE VALUE 1013904223.
 01 WS-P32                 BINARY-DOUBLE VALUE 4294967296.
 01 WS-HIGH                BINARY-DOUBLE VALUE 2147483647.
 01 WS-LOW                 BINARY-DOUBLE VALUE -2147483648.
 01 WS-N                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-U                   BINARY-LONG UNSIGNED.
 01 WS-UB REDEFINES WS-U.
    05 WS-B0               BINARY-CHAR UNSIGNED.
    05 WS-B1               BINARY-CHAR UNSIGNED.
    05 WS-B2               BINARY-CHAR UNSIGNED.
    05 WS-B3               BINARY-CHAR UNSIGNED.
 01 WS-X-TABLE.
    05 WS-NIB-X            BINARY-LONG OCCURS 256 TIMES.
 01 WS-Z-TABLE.
    05 WS-NIB-Z            BINARY-LONG OCCURS 256 TIMES.
 01 WS-Y-TABLE.
    05 WS-NIB-Y            BINARY-LONG OCCURS 256 TIMES.
 01 WS-MARKS.
    05 WS-MARK             BINARY-CHAR UNSIGNED OCCURS 65536 TIMES.
 01 WS-CELL                BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-MARKED              BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-ROW L-X0 L-Y0 L-Z0 L-COUNT L-MIN-Y.
     IF WS-INIT = 0
         MOVE 1 TO WS-INIT
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 255
             DIVIDE WS-K BY 4 GIVING WS-N
             DIVIDE WS-N BY 16 GIVING WS-R REMAINDER WS-N
             MOVE WS-N TO WS-NIB-X(WS-K + 1)
             COMPUTE WS-NIB-Z(WS-K + 1) = WS-N * 16
             COMPUTE WS-NIB-Y(WS-K + 1) = WS-N * 256
         END-PERFORM
     END-IF
     IF L-ROW = 0
         MOVE HIGH-VALUES TO WS-MARKS
         GOBACK
     END-IF
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
*>   The section's first cell: ((y0 - min_y) / 16) * 4096.
     COMPUTE WS-SECTION = (L-Y0 - L-MIN-Y) * 256
     MOVE WSM-RAND(L-DIM) TO WS-R
     PERFORM L-COUNT TIMES
         MOVE WS-R TO WS-V
         ADD WS-R TO WS-V
         ADD WS-R TO WS-V
         ADD WS-C TO WS-V
         PERFORM UNTIL WS-V <= WS-HIGH
             SUBTRACT WS-P32 FROM WS-V
         END-PERFORM
         PERFORM UNTIL WS-V >= WS-LOW
             ADD WS-P32 TO WS-V
         END-PERFORM
         MOVE WS-V TO WS-R
         IF WS-V < 0
             ADD WS-P32 TO WS-V
         END-IF
         MOVE WS-V TO WS-U
         MOVE WS-SECTION TO WS-CELL
         ADD 1 TO WS-CELL
         ADD WS-NIB-X(WS-B0 + 1) TO WS-CELL
         ADD WS-NIB-Z(WS-B1 + 1) TO WS-CELL
         ADD WS-NIB-Y(WS-B2 + 1) TO WS-CELL
         MOVE CE-STATE(WS-CELL) TO WS-STATE
         IF WS-MARK(WS-STATE + 1) = 255
             MOVE 0 TO WS-BITS
             CALL "BU-MARKED" USING K-11B WS-STATE WS-MARKED
             IF WS-MARKED = 1
                 ADD 1 TO WS-BITS
             END-IF
             CALL "BU-MARKED" USING K-13 WS-STATE WS-MARKED
             IF WS-MARKED = 1
                 ADD 2 TO WS-BITS
             END-IF
             MOVE WS-BITS TO WS-MARK(WS-STATE + 1)
         END-IF
         IF WS-MARK(WS-STATE + 1) NOT = 0
             MOVE WS-R TO WSM-RAND(L-DIM)
             COMPUTE WS-X = L-X0 + WS-NIB-X(WS-B0 + 1)
             COMPUTE WS-Z = L-Z0 + WS-NIB-Z(WS-B1 + 1) / 16
             COMPUTE WS-Y = L-Y0 + WS-NIB-Y(WS-B2 + 1) / 256
             CALL "BR-RANDOM-TICK-ROW" USING L-DIM L-ROW WS-X WS-Y WS-Z
         END-IF
     END-PERFORM
     MOVE WS-R TO WSM-RAND(L-DIM)
     GOBACK.
 END PROGRAM WL-SECTION-RUN.
