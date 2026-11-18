*> Test of the conventions of the woodland mansion document (docs/protocol/36-structures-7-woodland-mansion.md section 2): horizontal steps, Direction.from2DDataValue and pos.relative (2.1),
*> BlockPos.rotate and the template transform with mirror (2.1, STRUCT-TX-POS, STRUCT-TX-BOX), and the random draws used by sections 3 to 6 (2.2: the legacy nextInt rules, nextInt(1) consumes a
*> draw, nextBoolean is next(1), Util.shuffle draws nextInt(i) for i from size down to 2). Expected draws and permutation come from an independent Java LCG model (seed 5).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-7-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-REF                 BINARY-DOUBLE UNSIGNED.
 01 WS-BEFORE              BINARY-DOUBLE UNSIGNED.
 01 WS-BITS31              BINARY-LONG VALUE 31.
 01 WS-BITS1               BINARY-LONG VALUE 1.
 01 WS-A                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-MILLION             BINARY-LONG VALUE 1000000.
 01 WS-BOUND               BINARY-LONG.
 01 WS-SX                  BINARY-LONG VALUE 5.
 01 WS-SY                  BINARY-LONG VALUE 3.
 01 WS-SZ                  BINARY-LONG VALUE 7.
 01 WS-ROT1                BINARY-LONG VALUE 1.
 01 WS-BOX.
    05 WS-BOX-V            BINARY-LONG OCCURS 6 TIMES.
 01 WS-LIST.
    05 WS-ITEM             BINARY-LONG OCCURS 5 TIMES.
 01 WS-SIZE                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   2.1 horizontal steps in the order north, east, south, west
     MOVE "acceptance US12 36-7§2.1 horizontal steps (x, z): north (0, -1), east (1, 0), south (0, 1), west (-1, 0)" TO TL-CASE
     MOVE 0 TO WS-K
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3
         CALL "MNG-DIR-STEP" USING WS-D WS-DX WS-DZ
         EVALUATE WS-D
             WHEN 0
                 IF WS-DX = 0 AND WS-DZ = -1
                     ADD 1 TO WS-K
                 END-IF
             WHEN 1
                 IF WS-DX = 1 AND WS-DZ = 0
                     ADD 1 TO WS-K
                 END-IF
             WHEN 2
                 IF WS-DX = 0 AND WS-DZ = 1
                     ADD 1 TO WS-K
                 END-IF
             WHEN OTHER
                 IF WS-DX = -1 AND WS-DZ = 0
                     ADD 1 TO WS-K
                 END-IF
         END-EVALUATE
     END-PERFORM
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-K TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Direction.from2DDataValue: 0 south, 1 west, 2 north, 3 east (as direction numbers 2, 3, 0, 1); the index is taken modulo 4
     MOVE 0 TO WS-N
     PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > 3
         CALL "MNG-DIR-2D" USING WS-A WS-D
         COMPUTE WS-N = WS-N * 10 + WS-D
     END-PERFORM
     MOVE "acceptance US12 36-7§2.1 from2DDataValue 0, 1, 2, 3 gives south, west, north, east (2 3 0 1)" TO TL-CASE
     MOVE 2301 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 6 TO WS-A
     CALL "MNG-DIR-2D" USING WS-A WS-D
     MOVE "acceptance US12 36-7§2.1 from2DDataValue takes the index modulo 4 (6 is north)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-D TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   pos.relative(d, n) with a negative n
     MOVE 10 TO WS-X
     MOVE 20 TO WS-Z
     MOVE 1 TO WS-D
     MOVE 3 TO WS-N
     CALL "MNP-REL" USING WS-X WS-Z WS-D WS-N
     MOVE 2 TO WS-D
     MOVE -4 TO WS-N
     CALL "MNP-REL" USING WS-X WS-Z WS-D WS-N
     MOVE "acceptance US12 36-7§2.1 relative(east, 3) then relative(south, -4) from (10, 20) is (13, 16)" TO TL-CASE
     MOVE 1316 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-X * 100 + WS-Z
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   BlockPos.rotate of (1, 2, 3): none (1, 2, 3); clockwise 90 (-z, y, x); clockwise 180 (-x, y, -z); counterclockwise 90 (z, y, -x)
     MOVE 1 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-Z
     MOVE 0 TO WS-M
     MOVE 0 TO WS-R
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-M WS-R WS-ZERO WS-ZERO2 WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-7§2.1 BlockPos.rotate NONE of (1, 2, 3) is (1, 2, 3)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = (WS-OX - 1) * 100 + (WS-OY - 2) * 10 + (WS-OZ - 3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-R
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-M WS-R WS-ZERO WS-ZERO2 WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-7§2.1 BlockPos.rotate CLOCKWISE_90 of (1, 2, 3) is (-3, 2, 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OX + 3) * 100 + (WS-OY - 2) * 10 + (WS-OZ - 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-R
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-M WS-R WS-ZERO WS-ZERO2 WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-7§2.1 BlockPos.rotate CLOCKWISE_180 of (1, 2, 3) is (-1, 2, -3)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OX + 1) * 100 + (WS-OY - 2) * 10 + (WS-OZ + 3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-R
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-M WS-R WS-ZERO WS-ZERO2 WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-7§2.1 BlockPos.rotate COUNTERCLOCKWISE_90 of (1, 2, 3) is (3, 2, -1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OX - 3) * 100 + (WS-OY - 2) * 10 + (WS-OZ + 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the template transform mirrors first: LEFT_RIGHT negates z, FRONT_BACK negates x, then rotates
     MOVE 1 TO WS-M
     MOVE 0 TO WS-R
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-M WS-R WS-ZERO WS-ZERO2 WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-7§2.1 transform LEFT_RIGHT of (1, 2, 3) is (1, 2, -3)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OX - 1) * 100 + (WS-OY - 2) * 10 + (WS-OZ + 3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-M
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-M WS-R WS-ZERO WS-ZERO2 WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-7§2.1 transform FRONT_BACK of (1, 2, 3) is (-1, 2, 3)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OX + 1) * 100 + (WS-OY - 2) * 10 + (WS-OZ - 3)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-M
     MOVE 1 TO WS-R
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-M WS-R WS-ZERO WS-ZERO2 WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-7§2.1 transform LEFT_RIGHT then CLOCKWISE_90 of (1, 2, 3): mirror to (1, 2, -3), rotate to (3, 2, 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OX - 3) * 100 + (WS-OY - 2) * 10 + (WS-OZ - 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-M
     MOVE 3 TO WS-R
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-M WS-R WS-ZERO WS-ZERO2 WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-7§2.1 transform FRONT_BACK then COUNTERCLOCKWISE_90 of (1, 2, 3): (-1, 2, 3) to (3, 2, 1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OX - 3) * 100 + (WS-OY - 2) * 10 + (WS-OZ - 1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the bounding box of a 5 x 3 x 7 template turned 90 degrees at (10, 20, 30): corners (0, 0, 0) and (-6, 2, 4) sorted, then moved
     MOVE 10 TO WS-OX
     MOVE 20 TO WS-OY
     MOVE 30 TO WS-OZ
     MOVE 0 TO WS-M
     CALL "STRUCT-TX-BOX" USING WS-SX WS-SY WS-SZ WS-M WS-ROT1 WS-ZERO WS-ZERO2 WS-OX WS-OY WS-OZ WS-BOX
     MOVE "acceptance US12 36-7§2.1 template bounding box of size (5, 3, 7) turned 90 at (10, 20, 30) is (4, 20, 30) to (10, 22, 34)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BOX-V(1) NOT = 4 OR WS-BOX-V(2) NOT = 20 OR WS-BOX-V(3) NOT = 30
         OR WS-BOX-V(4) NOT = 10 OR WS-BOX-V(5) NOT = 22 OR WS-BOX-V(6) NOT = 34
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2.2 nextBoolean is next(1) != 0 (model, seed 5: 1 0 0 1 0 1 0 1)
     CALL "JRAND-SET-SEED" USING SP-RNG WS-SEED
     MOVE 0 TO WS-N
     PERFORM 8 TIMES
         CALL "JRAND-NEXT" USING SP-RNG WS-BITS1 WS-B
         COMPUTE WS-N = WS-N * 2
         IF WS-B NOT = 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§2.2 nextBoolean is next(1) != 0: seed 5 gives 1 0 0 1 0 1 0 1" TO TL-CASE
     MOVE 149 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   nextInt(4) (a power of two, the high bits rule): 2 0 0 2 1 3
     CALL "JRAND-SET-SEED" USING SP-RNG WS-SEED
     MOVE 4 TO WS-BOUND
     MOVE 0 TO WS-N
     PERFORM 6 TIMES
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-V
         COMPUTE WS-N = WS-N * 10 + WS-V
     END-PERFORM
     MOVE "acceptance US12 36-7§2.2 nextInt(4) of seed 5 (the power-of-two rule) gives 2 0 0 2 1 3, also the rotation draw of Rotation.getRandom" TO TL-CASE
     MOVE 200213 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   nextInt(3) and nextInt(7) (the rejection rule): 2 1 2 2 0 2 and 1 5 5 5
     CALL "JRAND-SET-SEED" USING SP-RNG WS-SEED
     MOVE 3 TO WS-BOUND
     MOVE 0 TO WS-N
     PERFORM 6 TIMES
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-V
         COMPUTE WS-N = WS-N * 10 + WS-V
     END-PERFORM
     MOVE "acceptance US12 36-7§2.2 nextInt(3) of seed 5 (the rejection rule) gives 2 1 2 2 0 2" TO TL-CASE
     MOVE 212202 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-BOUND
     MOVE 0 TO WS-N
     PERFORM 4 TIMES
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-V
         COMPUTE WS-N = WS-N * 10 + WS-V
     END-PERFORM
     MOVE "acceptance US12 36-7§2.2 nextInt(7) after those six draws gives 1 5 5 5" TO TL-CASE
     MOVE 1555 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   nextInt(1) returns 0 and still consumes one next(31)
     CALL "JRAND-SET-SEED" USING SP-RNG WS-SEED
     MOVE 1 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-V
     MOVE WS-V TO WS-N
     MOVE SP-RNG TO WS-BEFORE
     CALL "JRAND-SET-SEED" USING WS-REF WS-SEED
     CALL "JRAND-NEXT" USING WS-REF WS-BITS31 WS-B
     MOVE "acceptance US12 36-7§2.2 nextInt(1) returns 0 and consumes exactly one next(31)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-BEFORE = WS-REF
         MOVE WS-N TO TL-OBSERVED-N
     ELSE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-MILLION WS-N
     MOVE "acceptance US12 36-7§2.2 the draw after nextInt(1) of seed 5 is 250092 (model)" TO TL-CASE
     MOVE 250092 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Util.shuffle of 1 to 5: for i from 5 down to 2 j = nextInt(i) and a swap: the order 4 2 5 1 3, then the stream continues at 914506
     CALL "JRAND-SET-SEED" USING SP-RNG WS-SEED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         MOVE WS-K TO WS-ITEM(WS-K)
     END-PERFORM
     MOVE 5 TO WS-SIZE
     CALL "F355-SHUFFLE" USING WS-LIST WS-SIZE SP-RNG
     MOVE "acceptance US12 36-7§2.2 Util.shuffle of 1 to 5 with seed 5 gives 4 2 5 1 3" TO TL-CASE
     MOVE 42513 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-ITEM(1) * 10000 + WS-ITEM(2) * 1000 + WS-ITEM(3) * 100 + WS-ITEM(4) * 10 + WS-ITEM(5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-MILLION WS-N
     MOVE "acceptance US12 36-7§2.2 Util.shuffle of five draws four times: the next draw is 914506" TO TL-CASE
     MOVE 914506 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a list of size 0 or 1 draws nothing
     CALL "JRAND-SET-SEED" USING SP-RNG WS-SEED
     MOVE SP-RNG TO WS-BEFORE
     MOVE 1 TO WS-SIZE
     CALL "F355-SHUFFLE" USING WS-LIST WS-SIZE SP-RNG
     MOVE 0 TO WS-SIZE
     CALL "F355-SHUFFLE" USING WS-LIST WS-SIZE SP-RNG
     MOVE "acceptance US12 36-7§2.2 Util.shuffle of a list of size 0 or 1 draws nothing" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF SP-RNG = WS-BEFORE
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-7-2.
