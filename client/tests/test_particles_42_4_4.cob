*> Acceptance test of docs/protocol/42-particles-4-block-item-dust-ambient.md section 4 (Terrain particles): the rules, table rows,
*> formulas and worked cases of the section with the document's numbers; every float case compares
*> the value times 100000 rounded. Draws are injected through the draw tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-4-4.
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
 01 WS-INTS.
    05 WS-N                BINARY-LONG OCCURS 6 TIMES.
 01 WS-OUT.
    05 WS-OUTP             BINARY-LONG OCCURS 3 TIMES.
 01 WS-ITEM               PIC X(16).
 01 WS-F1                 BINARY-LONG.
 01 WS-F2                 BINARY-LONG.
 01 WS-F3                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0.5 TO W5
     MOVE 0.5 TO W6
     MOVE 5 TO W1
     MOVE 70 TO W2
     MOVE -3 TO W3
     CALL "P4-MARKER-NEW" USING PCL W1 W2 W3 W5 W6
     MOVE "marker lifetime is 80" TO WS-NAME
     MOVE 80 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-LIFETIME
     PERFORM ASSERT-NUMBER
     MOVE "marker gravity is 0" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-GRAVITY) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "marker has no physics" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-HAS-PHYSICS
     PERFORM ASSERT-NUMBER
     MOVE "marker friction stays 0.98" TO WS-NAME
     MOVE 98000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-FRICTION) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "marker colour is 1, 1, 1 and alpha 1" TO WS-NAME
     MOVE 400000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-RCOL + PC-GCOL + PC-BCOL + PC-ALPHA) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "marker velocity is zero" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-XD + PC-YD + PC-ZD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "marker position is the supplied one (y)" TO WS-NAME
     MOVE 7000000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-Y) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     CALL "P4-MARKER-SIZE" USING W4
     MOVE "getQuadSize is the constant 0.5 whatever the age" TO WS-NAME
     MOVE 50000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W4) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-F1
     MOVE 1 TO WS-F2
     MOVE "barrier" TO WS-ITEM
     CALL "P4-MARKER-TARGET" USING WS-F1 WS-ITEM WS-F2 I1
     MOVE "creative with a barrier block item targets barrier" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE "light" TO WS-ITEM
     CALL "P4-MARKER-TARGET" USING WS-F1 WS-ITEM WS-F2 I1
     MOVE "creative with a light block item targets light" TO WS-NAME
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 0 TO WS-F1
     CALL "P4-MARKER-TARGET" USING WS-F1 WS-ITEM WS-F2 I1
     MOVE "survival never targets" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 1 TO WS-F1
     MOVE "stick" TO WS-ITEM
     CALL "P4-MARKER-TARGET" USING WS-F1 WS-ITEM WS-F2 I1
     MOVE "creative with another item has no target" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE "barrier" TO WS-ITEM
     MOVE 0 TO WS-F2
     CALL "P4-MARKER-TARGET" USING WS-F1 WS-ITEM WS-F2 I1
     MOVE "the item must be a block item" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 1 TO I2
     CALL "P4-SAMPLE-INFO" USING I2 I1
     MOVE "667 iterations per client tick" TO WS-NAME
     MOVE 667 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 2 TO I2
     CALL "P4-SAMPLE-INFO" USING I2 I1
     MOVE "first radius 16" TO WS-NAME
     MOVE 16 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 3 TO I2
     CALL "P4-SAMPLE-INFO" USING I2 I1
     MOVE "second radius 32" TO WS-NAME
     MOVE 32 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 4 TO I2
     CALL "P4-SAMPLE-INFO" USING I2 I1
     MOVE "1334 sample positions per client tick" TO WS-NAME
     MOVE 1334 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 5 TO WS-N(1)
     MOVE 2 TO WS-N(2)
     MOVE 7 TO WS-N(3)
     MOVE 1 TO WS-N(4)
     MOVE 0 TO WS-N(5)
     MOVE 3 TO WS-N(6)
     MOVE 100 TO I1
     MOVE 64 TO I2
     MOVE 100 TO I3
     CALL "P4-SAMPLE-POS" USING I1 I2 I3 WS-INTS WS-OUT
     MOVE "sample x = x + nextInt(r) - nextInt(r)" TO WS-NAME
     MOVE 103 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTP(1)
     PERFORM ASSERT-NUMBER
     MOVE "sample y" TO WS-NAME
     MOVE 70 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTP(2)
     PERFORM ASSERT-NUMBER
     MOVE "sample z (the six draws in the order +x -x +y -y +z -z)" TO WS-NAME
     MOVE 97 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTP(3)
     PERFORM ASSERT-NUMBER
     MOVE 15 TO WS-N(1)
     MOVE 0 TO WS-N(2)
     CALL "P4-SAMPLE-POS" USING I1 I2 I3 WS-INTS WS-OUT
     MOVE "triangular offset reaches +(r - 1) = 15" TO WS-NAME
     MOVE 115 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OUTP(1)
     PERFORM ASSERT-NUMBER
     MOVE 10 TO WS-OUTP(1)
     MOVE 20 TO WS-OUTP(2)
     MOVE 30 TO WS-OUTP(3)
     CALL "P4-MARKER-CENTER" USING WS-OUT W1 W2 W3
     MOVE "the marker is spawned at the block centre (x + 0.5)" TO WS-NAME
     MOVE 1050000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W1) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "the marker is spawned at the block centre (z + 0.5)" TO WS-NAME
     MOVE 3050000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((W3) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-4§4 Terrain particles: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-4§4 Terrain particles: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-4-4.
