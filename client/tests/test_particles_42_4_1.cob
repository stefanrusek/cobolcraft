*> Acceptance test of docs/protocol/42-particles-4-block-item-dust-ambient.md section 1 (): the rules, table rows,
*> formulas and worked cases of the section with the document's numbers; every float case compares
*> the value times 100000 rounded. Draws are injected through the draw tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-4-1.
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
 PROCEDURE DIVISION.
     PERFORM VARYING I1 FROM 1 BY 1 UNTIL I1 > 7
         MOVE 0.5 TO WS-D(I1)
     END-PERFORM
     MOVE 0 TO W1
     MOVE 0 TO W2
     MOVE 0 TO W3
     MOVE -0.375 TO W4
     COMPUTE W5 = -0.375
     COMPUTE W6 = -0.375
     CALL "P4-QUAD-VEL-NEW" USING PCL W1 W2 W3 W4 W5 W6 WS-DRAWS
     MOVE "burst: example 1 xd with a bias of -0.375" TO WS-NAME
     MOVE -6928 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-XD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "burst: example 1 yd carries the 0.1 constant" TO WS-NAME
     MOVE 3072 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-YD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "burst: example 1 zd" TO WS-NAME
     MOVE -6928 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-ZD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "quad size draw 0.5 gives 0.15 (0.1 * (r * 0.5 + 0.5) * 2)" TO WS-NAME
     MOVE 15000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-QUAD-SIZE) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "colour channels and alpha start at 1.0" TO WS-NAME
     MOVE 100000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-RCOL + PC-GCOL + PC-BCOL + PC-ALPHA - 3) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 1 TO I5
     CALL "P4-CONV-FACTS" USING I5 I1
     MOVE "the normalised burst has 6 draws" TO WS-NAME
     MOVE 6 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 2 TO I5
     CALL "P4-CONV-FACTS" USING I5 I1
     MOVE "SingleQuadParticle construction takes 1 draw" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 3 TO I5
     CALL "P4-CONV-FACTS" USING I5 I1
     MOVE "the position-only constructor has 2 draws (lifetime, quad size)" TO WS-NAME
     MOVE 2 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 4 TO I5
     CALL "P4-CONV-FACTS" USING I5 I1
     MOVE "the velocity constructor has 7 draws" TO WS-NAME
     MOVE 7 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I1
     PERFORM ASSERT-NUMBER
     MOVE 0.5 TO WS-D(1)
     CALL "PCL-NEW" USING PCL W1 W2 W3 WS-D(1)
     MOVE "position-only constructor has zero velocity (xd)" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-XD + PC-YD + PC-ZD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 0 TO PK-COUNT
     MOVE 100 TO W2
     CALL "PCL-NEW" USING PCL W1 W2 W3 WS-D(1)
     MOVE 1.0 TO PC-GRAVITY
     MOVE 10 TO PC-LIFETIME
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     MOVE "tick: yd -= 0.04 * gravity, move, then friction 0.98 (yd)" TO WS-NAME
     MOVE -3920 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-YD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "tick: the move used the velocity before friction (y)" TO WS-NAME
     MOVE 9996000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-Y) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "tick: age is incremented after the comparison" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PC-AGE
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-4§1 : " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-4§1 : " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-4-1.
