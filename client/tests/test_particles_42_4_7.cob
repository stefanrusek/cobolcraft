*> Acceptance test of docs/protocol/42-particles-4-block-item-dust-ambient.md section 7 (Item break particles): the rules, table rows,
*> formulas and worked cases of the section with the document's numbers; every float case compares
*> the value times 100000 rounded. Draws are injected through the draw tables.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-4-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 COPY CLP4X.
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
 01 WS-NAME8              PIC X(32).
 01 WS-F1                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING I1 FROM 1 BY 1 UNTIL I1 > 16
         MOVE 0.5 TO WS-D(I1)
     END-PERFORM
     MOVE 0.75 TO WS-D(2)
     MOVE 0 TO W1
     CALL "P4-ITEM-CORE-NEW" USING PCL P4X Z1 Z2 Z3 WS-DRAWS
     MOVE "7.1 core: the burst is full size (xd = 0.12)" TO WS-NAME
     MOVE 12000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-XD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "7.1 core: yd carries the 0.1 constant" TO WS-NAME
     MOVE 10000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-YD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "7.1 core: gravity 1.0" TO WS-NAME
     MOVE 100000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-GRAVITY) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "7.1 core: quad size halved (0.15 / 2)" TO WS-NAME
     MOVE 7500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-QUAD-SIZE) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "7.1 core: uo = nextFloat * 3" TO WS-NAME
     MOVE 150000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((X4-UO) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "7.1 core: vo = nextFloat * 3" TO WS-NAME
     MOVE 150000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((X4-VO) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 0.5 TO W2
     MOVE 1.0 TO W3
     MOVE -0.5 TO W4
     CALL "P4-ITEM-VEL-NEW" USING PCL P4X Z1 Z2 Z3 W2 W3 W4 WS-DRAWS
     MOVE "7.1 velocity constructor: xd = burst * 0.1 + vx" TO WS-NAME
     MOVE 51200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-XD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "7.1 velocity constructor: yd = burst * 0.1 + vy" TO WS-NAME
     MOVE 101000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-YD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE "7.1 velocity constructor: zd = 0 * 0.1 + vz" TO WS-NAME
     MOVE -50000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER((PC-ZD) * 100000 + 0.5)
     PERFORM ASSERT-NUMBER
     MOVE 2 TO I2
     MOVE 0.5 TO W5
     CALL "P4-ITEM-PICK" USING I2 W5 I3 WS-F1
     MOVE "7.2 two active layers: one nextInt(2) draw, 0.5 gives index 1" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I3
     PERFORM ASSERT-NUMBER
     MOVE "7.2 the draw was consumed" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-F1
     PERFORM ASSERT-NUMBER
     MOVE 1 TO I2
     CALL "P4-ITEM-PICK" USING I2 W5 I3 WS-F1
     MOVE "7.2 a single-layer item still consumes one draw" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-F1
     PERFORM ASSERT-NUMBER
     MOVE "7.2 and picks layer 0" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I3
     PERFORM ASSERT-NUMBER
     MOVE 0 TO I2
     CALL "P4-ITEM-PICK" USING I2 W5 I3 WS-F1
     MOVE "7.2 no active layer consumes no draw" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-F1
     PERFORM ASSERT-NUMBER
     MOVE "7.2 and gives no index (-1, the missing sprite)" TO WS-NAME
     MOVE -1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = I3
     PERFORM ASSERT-NUMBER
     MOVE 62 TO I2
     CALL "P4-ITEM-TEMPLATE" USING I2 WS-NAME8 WS-F1
     MOVE "7.3 item_slime builds a slime_ball" TO WS-NAME
     MOVE "slime_ball" TO TL-EXPECTED
     MOVE WS-NAME8 TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "7.3 item_slime ignores the supplied velocity" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-F1
     PERFORM ASSERT-NUMBER
     MOVE 63 TO I2
     CALL "P4-ITEM-TEMPLATE" USING I2 WS-NAME8 WS-F1
     MOVE "7.3 item_cobweb builds a cobweb" TO WS-NAME
     MOVE "cobweb" TO TL-EXPECTED
     MOVE WS-NAME8 TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 64 TO I2
     CALL "P4-ITEM-TEMPLATE" USING I2 WS-NAME8 WS-F1
     MOVE "7.3 item_snowball builds a snowball" TO WS-NAME
     MOVE "snowball" TO TL-EXPECTED
     MOVE WS-NAME8 TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE 127 TO I2
     CALL "P4-ITEM-TEMPLATE" USING I2 WS-NAME8 WS-F1
     MOVE "7.4 sulfur_cube_goo has no item template (sprite set)" TO WS-NAME
     MOVE "    " TO TL-EXPECTED
     MOVE WS-NAME8 TO TL-OBSERVED
     PERFORM ASSERT-TEXT
     MOVE "7.4 sulfur_cube_goo ignores the supplied velocity" TO WS-NAME
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-F1
     PERFORM ASSERT-NUMBER
     MOVE 57 TO I2
     CALL "P4-ITEM-TEMPLATE" USING I2 WS-NAME8 WS-F1
     MOVE "7.2 the item particle uses the velocity constructor" TO WS-NAME
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-F1
     PERFORM ASSERT-NUMBER
     STOP RUN.

 ASSERT-NUMBER.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-4§7 Item break particles: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-4§7 Item break particles: " FUNCTION TRIM(WS-NAME)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-4-7.
