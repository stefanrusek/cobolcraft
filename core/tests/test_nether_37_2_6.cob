*> Implementation test of the Nether's density grid and fill (core/src/nether-37-2.cob; T1645, T1646, T1647, T1648; docs/protocol/37-nether-2 sections 5.4, 6.1,
*> 6.2, 7 and the worked values 12.3 and 12.4, world seed 0): the corner values 0.64 * S of the column x = 0, z = 0 (1e-8), the squeezed densities
*> of the filled column (y 0, 7, 8, 31, 32, 63, 64, 100, 127), the solid runs of the columns (0, 0) and (5, 2), and the fill's blocks: netherrack where
*> solid, air above y 31 where not, lava below y 32 where not (a chunk searched for a lava block).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-2-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY NETHER.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SCALED              FLOAT-LONG.
 01 WS-DIFF                BINARY-DOUBLE.
 01 WS-WANT                BINARY-DOUBLE.
 01 WS-SOLID               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-GT                  BINARY-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ED                  PIC -(4)9.
 01 WS-TMP                 PIC X(240).
 01 WS-CELL                BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-BADS                BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-CHUNK               PIC X(304640).
 01 WS-CORNER-Y            BINARY-LONG OCCURS 11 TIMES.
 01 WS-CORNER-V            BINARY-DOUBLE OCCURS 11 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM NETHER-TABLES
     CALL "NETHER-SETUP" USING WS-SEED
     MOVE 0 TO WS-CX WS-CZ
     CALL "NETHER-CORNERS" USING WS-CX WS-CZ
     PERFORM CHECK-CORNERS
     MOVE 0 TO WS-LX WS-LZ
     CALL "NETHER-COLUMN" USING WS-LX WS-LZ
     PERFORM CHECK-DENSITIES
     MOVE 0 TO WS-FIRST
     PERFORM COUNT-RUNS
     MOVE "acceptance US12-core 37-2§12.4 column (0, 0) solid 0..75, air 76..94, solid 95..127 (solid blocks 76 + 33)" TO TL-CASE
     MOVE 109 TO TL-EXPECTED-N
     MOVE WS-SOLID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-core 37-2§12.4 column (0, 0) first air block is y 76" TO TL-CASE
     MOVE 76 TO TL-EXPECTED-N
     MOVE WS-FIRST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-core 37-2§12.4 column (0, 0) last air block is y 94" TO TL-CASE
     MOVE 94 TO TL-EXPECTED-N
     MOVE WS-LAST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-LX
     MOVE 2 TO WS-LZ
     CALL "NETHER-COLUMN" USING WS-LX WS-LZ
     PERFORM COUNT-RUNS
     MOVE "acceptance US12-core 37-2§12.4 column (5, 2) has 108 solid blocks" TO TL-CASE
     MOVE 108 TO TL-EXPECTED-N
     MOVE WS-SOLID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-core 37-2§12.4 column (5, 2) air 76..95" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 76 * 1000 + 95
     COMPUTE TL-OBSERVED-N = WS-FIRST * 1000 + WS-LAST
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM CHECK-FILL
     GOBACK.

 CHECK-CORNERS.
*>   y 0, 8, 16, 24, 32, 64, 96, 104, 112, 120, 128 at corner (0, 0): the corner index of row j is j + 1
     MOVE 0 TO WS-CORNER-Y(1)
     MOVE 125020325 TO WS-CORNER-V(1)
     MOVE 8 TO WS-CORNER-Y(2)
     MOVE 87121290 TO WS-CORNER-V(2)
     MOVE 16 TO WS-CORNER-Y(3)
     MOVE 49776480 TO WS-CORNER-V(3)
     MOVE 24 TO WS-CORNER-Y(4)
     MOVE 10184477 TO WS-CORNER-V(4)
     MOVE 32 TO WS-CORNER-Y(5)
     MOVE 12226027 TO WS-CORNER-V(5)
     MOVE 64 TO WS-CORNER-Y(6)
     MOVE 4698838 TO WS-CORNER-V(6)
     MOVE 96 TO WS-CORNER-Y(7)
     MOVE 2400769 TO WS-CORNER-V(7)
     MOVE 104 TO WS-CORNER-Y(8)
     MOVE 7534146 TO WS-CORNER-V(8)
     MOVE 112 TO WS-CORNER-Y(9)
     MOVE 17555980 TO WS-CORNER-V(9)
     MOVE 120 TO WS-CORNER-Y(10)
     MOVE 44122383 TO WS-CORNER-V(10)
     MOVE 128 TO WS-CORNER-Y(11)
     MOVE 59999996 TO WS-CORNER-V(11)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         COMPUTE WS-J = WS-CORNER-Y(WS-I) / 8 + 1
         MOVE SPACES TO TL-CASE
         MOVE WS-CORNER-Y(WS-I) TO WS-ED
         STRING "acceptance US12-core 37-2§12.3 corner value at y " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-CORNER-V(WS-I) TO TL-EXPECTED-N
         COMPUTE WS-SCALED = NH-CORNER(WS-J) * 100000000
         PERFORM COMPARE-SCALED
     END-PERFORM.

 CHECK-DENSITIES.
     MOVE 0 TO WS-Y
     MOVE 45833334 TO WS-WANT
     PERFORM CHECK-DENSITY
     MOVE 1 TO WS-Y
     MOVE 45833334 TO WS-WANT
     PERFORM CHECK-DENSITY
     MOVE 7 TO WS-Y
     MOVE 42699736 TO WS-WANT
     PERFORM CHECK-DENSITY
     MOVE 8 TO WS-Y
     MOVE 40805390 TO WS-WANT
     PERFORM CHECK-DENSITY
     MOVE 31 TO WS-Y
     MOVE 5978268 TO WS-WANT
     PERFORM CHECK-DENSITY
     MOVE 32 TO WS-Y
     MOVE 6105399 TO WS-WANT
     PERFORM CHECK-DENSITY
     MOVE 63 TO WS-Y
     MOVE 3319364 TO WS-WANT
     PERFORM CHECK-DENSITY
     MOVE 64 TO WS-Y
     MOVE 2348987 TO WS-WANT
     PERFORM CHECK-DENSITY
     MOVE 100 TO WS-Y
     MOVE 2483218 TO WS-WANT
     PERFORM CHECK-DENSITY
     MOVE 127 TO WS-Y
     MOVE 28194040 TO WS-WANT
     PERFORM CHECK-DENSITY.

 CHECK-DENSITY.
     MOVE SPACES TO TL-CASE
     MOVE WS-Y TO WS-ED
     STRING "acceptance US12-core 37-2§12.4 squeezed density of column (0, 0) at y " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT TO TL-EXPECTED-N
     COMPUTE WS-I = WS-Y + 1
     COMPUTE WS-SCALED = NH-COL(WS-I) * 100000000
     PERFORM COMPARE-SCALED.

 COMPARE-SCALED.
*>   the document's values are printed with 8 digits and came from a reference script: tolerate 3e-8
     COMPUTE TL-OBSERVED-N ROUNDED = WS-SCALED
     COMPUTE WS-DIFF = TL-OBSERVED-N - TL-EXPECTED-N
     IF WS-DIFF >= -3 AND WS-DIFF <= 3
         MOVE TL-EXPECTED-N TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 COUNT-RUNS.
     MOVE 0 TO WS-SOLID
     MOVE -1 TO WS-FIRST WS-LAST
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 127
         COMPUTE WS-I = WS-Y + 1
         CALL "FCMP-GT" USING NH-COL(WS-I) WS-ZERO WS-GT
         IF WS-GT = 1
             ADD 1 TO WS-SOLID
         ELSE
             IF WS-FIRST < 0
                 MOVE WS-Y TO WS-FIRST
             END-IF
             MOVE WS-Y TO WS-LAST
         END-IF
     END-PERFORM.

 CHECK-FILL.
*>   chunk (0, 0) filled: column (5, 2) matches its density, air above y 31 is state 0, and every empty block below y 32 is lava
     MOVE LOW-VALUES TO WS-CHUNK
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK
     CALL "NETHER-FILL" USING WS-CHUNK
     MOVE 0 TO WS-BADS WS-LAVA
     MOVE 5 TO WS-LX
     MOVE 2 TO WS-LZ
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 127
         COMPUTE WS-CELL = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
         IF WS-Y >= 76 AND WS-Y <= 95
             IF CE-STATE(WS-CELL) NOT = 0
                 ADD 1 TO WS-BADS
             END-IF
         ELSE
             IF CE-STATE(WS-CELL) NOT = 100
                 ADD 1 TO WS-BADS
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12-core 37-2§6.3 fill of column (5, 2): netherrack 0..75 and 96..127, air 76..95" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BADS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the first chunk of a 6 x 6 area that holds a lava block (the chunk (0, 0) is solid below y 32)
     MOVE 0 TO WS-LAVA
     PERFORM VARYING WS-CX FROM -2 BY 1 UNTIL WS-CX > 3 OR WS-LAVA > 0
         PERFORM VARYING WS-CZ FROM -2 BY 1 UNTIL WS-CZ > 3 OR WS-LAVA > 0
             CALL "NETHER-CORNERS" USING WS-CX WS-CZ
             MOVE LOW-VALUES TO WS-CHUNK
             CALL "NETHER-FILL" USING WS-CHUNK
             PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 32768
                 IF CE-STATE(WS-CELL) = 102
                     ADD 1 TO WS-LAVA
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-BADS
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 32768
         EVALUATE CE-STATE(WS-CELL)
             WHEN 0
                 COMPUTE WS-Y = (WS-CELL - 1) / 256
                 IF WS-Y < 32
                     ADD 1 TO WS-BADS
                 END-IF
             WHEN 102
                 COMPUTE WS-Y = (WS-CELL - 1) / 256
                 IF WS-Y >= 32
                     ADD 1 TO WS-BADS
                 END-IF
             WHEN 100
                 CONTINUE
             WHEN OTHER
                 ADD 1 TO WS-BADS
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US12-core 37-2§7 fill: no air below y 32, lava only below y 32, no other block" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BADS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12-core 37-2§7 a chunk of the area 6 x 6 around the origin has a lava sea (lava blocks above 0)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LAVA > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 COPY NETHERTEST.
 END PROGRAM TEST-NETHER-37-2-6.
