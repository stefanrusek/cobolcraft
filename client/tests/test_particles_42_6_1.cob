*> Acceptance test of docs/protocol/42-particles-6-emitters-blocks.md section 1 (Scheduling: `ClientLevel.animateTick`): the rules, table rows,
*> formulas and worked cases of the section with the document's numbers; every float case compares
*> the value times 100000 rounded. Draws are injected through the draw tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-6-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 COPY TESTLIB.
 01 WS-NAME                PIC X(160).
 01 WS-DRAWS.
    05 WS-D                FLOAT-LONG OCCURS 16 TIMES.
 01 WS-EDRAWS.
    05 WS-E                FLOAT-LONG OCCURS 16 TIMES.
 01 W1                     FLOAT-LONG.
 01 W2                     FLOAT-LONG.
 01 W3                     FLOAT-LONG.
 01 W4                     FLOAT-LONG.
 01 W5                     FLOAT-LONG.
 01 W6                     FLOAT-LONG.
 01 W7                     FLOAT-LONG.
 01 W8                     FLOAT-LONG.
 01 I1                     BINARY-LONG.
 01 I2                     BINARY-LONG.
 01 I3                     BINARY-LONG.
 01 I4                     BINARY-LONG.
 01 I5                     BINARY-LONG.
 01 B1                     BINARY-DOUBLE.
 01 T1                     PIC X(80).
 01 Z1                     FLOAT-LONG VALUE 0.
 01 Z2                     FLOAT-LONG VALUE 0.
 01 Z3                     FLOAT-LONG VALUE 0.
 01 Z4                     FLOAT-LONG VALUE 0.
 01 Z5                     FLOAT-LONG VALUE 0.
 01 Z6                     FLOAT-LONG VALUE 0.
 01 WS-POS.
    05 WS-PP               BINARY-LONG OCCURS 3 TIMES.
 01 WS-OUT.
    05 WS-O                FLOAT-LONG OCCURS 3 TIMES.
 01 WS-MODE               BINARY-LONG.
 01 WS-FA                 BINARY-LONG.
 01 WS-FB                 BINARY-LONG.
 01 WS-FC                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 1 TO I2
     CALL "P6-FACTS" USING I2 I1
     MOVE "1.2 667 iterations per call" TO WS-NAME
     MOVE 667 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 2 TO I2
     CALL "P6-FACTS" USING I2 I1
     MOVE "1.2 first radius 16" TO WS-NAME
     MOVE 16 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 3 TO I2
     CALL "P6-FACTS" USING I2 I1
     MOVE "1.2 second radius 32" TO WS-NAME
     MOVE 32 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 4 TO I2
     CALL "P6-FACTS" USING I2 I1
     MOVE "1.2 1334 samples per tick" TO WS-NAME
     MOVE 1334 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 5 TO I2
     CALL "P6-FACTS" USING I2 I1
     MOVE "1.2 three random sources: R, L and the thread-local block source" TO WS-NAME
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 6 TO I2
     CALL "P6-FACTS" USING I2 I1
     MOVE "1.2 the drip chance is 1 in 10" TO WS-NAME
     MOVE 10 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 9 TO I2
     CALL "P6-FACTS" USING I2 I1
     MOVE "an unknown fact gives 0" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 0.05 TO W1
     CALL "P6-DRIP-CHANCE" USING W1 I1
     MOVE "1.2 nextInt(10) = 0 spawns a drip (draw 0.05)" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 0.1 TO W1
     CALL "P6-DRIP-CHANCE" USING W1 I1
     MOVE "1.2 nextInt(10) = 1 does not (draw 0.1)" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-FA
     MOVE 0 TO WS-FB
     MOVE 0.5 TO W1
     MOVE 0 TO W2
     MOVE 0.5 TO W4
     MOVE 1 TO I1
     MOVE 0 TO I2
     CALL "P6-DRIP-PLACE" USING WS-FA W1 W2 I1 I2 W4 WS-FB WS-MODE W3
     MOVE "1.5 step 1: a fluid below stops it (mode 0)" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MODE
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-FA
     CALL "P6-DRIP-PLACE" USING WS-FA W1 W2 I1 I2 W4 WS-FB WS-MODE W3
     MOVE "1.5 step 3: top < 1 and sturdy: the unit square (mode 1)" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MODE
     PERFORM ASSERT-NUMBER
     MOVE "1.5 step 3: y = below.Y + 1 - 0.05 (offset 0.95)" TO WS-NAME
     MOVE 95000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W3) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 0 TO I1
     CALL "P6-DRIP-PLACE" USING WS-FA W1 W2 I1 I2 W4 WS-FB WS-MODE W3
     MOVE "1.5 step 3: top < 1 and not sturdy: nothing (mode 0)" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MODE
     PERFORM ASSERT-NUMBER
     MOVE 1.0 TO W1
     MOVE 1 TO I2
     CALL "P6-DRIP-PLACE" USING WS-FA W1 W2 I1 I2 W4 WS-FB WS-MODE W3
     MOVE "1.5 step 4: an impermeable block below stops it" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MODE
     PERFORM ASSERT-NUMBER
     MOVE 0 TO I2
     MOVE 0.25 TO W2
     CALL "P6-DRIP-PLACE" USING WS-FA W1 W2 I1 I2 W4 WS-FB WS-MODE W3
     MOVE "1.5 step 4: shape bottom > 0 uses the shape extents (mode 2)" TO WS-NAME
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MODE
     PERFORM ASSERT-NUMBER
     MOVE "1.5 step 4: y = below.Y + bottom - 0.05" TO WS-NAME
     MOVE 20000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W3) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 0 TO W2
     CALL "P6-DRIP-PLACE" USING WS-FA W1 W2 I1 I2 W4 WS-FB WS-MODE W3
     MOVE "1.5 bottom 0, under shape top < 1 and no fluid: mode 3" TO WS-NAME
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MODE
     PERFORM ASSERT-NUMBER
     MOVE "1.5 mode 3: y = below.Y - 0.05" TO WS-NAME
     MOVE -5000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W3) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 1.0 TO W4
     CALL "P6-DRIP-PLACE" USING WS-FA W1 W2 I1 I2 W4 WS-FB WS-MODE W3
     MOVE "1.5 under shape top >= 1: nothing" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MODE
     PERFORM ASSERT-NUMBER
     MOVE 0.5 TO W4
     MOVE 1 TO WS-FB
     CALL "P6-DRIP-PLACE" USING WS-FA W1 W2 I1 I2 W4 WS-FB WS-MODE W3
     MOVE "1.5 a fluid in the under block: nothing" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-MODE
     PERFORM ASSERT-NUMBER
     MOVE 10 TO WS-PP(1)
     MOVE 64 TO WS-PP(2)
     MOVE -3 TO WS-PP(3)
     MOVE 0.1 TO W1
     MOVE 0.9 TO W2
     MOVE -0.05 TO W3
     MOVE 0.25 TO W5
     MOVE 0.75 TO W6
     MOVE 0.5 TO W7
     MOVE 0.25 TO W8
     CALL "P6-DRIP-POS" USING WS-POS W1 W2 W5 W6 W7 W8 W3 WS-OUT
     MOVE "1.6 x = X + lerp(draw, minX, maxX)" TO WS-NAME
     MOVE 1050000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-O(1)) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "1.6 z = Z + lerp(draw, minZ, maxZ) (x draw first, z second)" TO WS-NAME
     MOVE -262500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-O(3)) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "1.6 y = Y + the y offset" TO WS-NAME
     MOVE 6395000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((WS-O(2)) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-6§1 Scheduling: `ClientLevel.animateTick`: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-6§1 Scheduling: `ClientLevel.animateTick`: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-6-1.
