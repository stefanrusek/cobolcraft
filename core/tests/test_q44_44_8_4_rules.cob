*> Acceptance test of docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 4.6 as rule functions (lane 002-lane-p49j-b, T24200 range): the container cart comparator signal and slowdown factor, and the eight DismountHelper offsets for two directions.

*> The functions of core/src/q44-44-8.cob are not called by a tick (no entity engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-4-RULES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-CASE                PIC X(160).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-A                  FLOAT-LONG.
 01 WS-B                  FLOAT-LONG.
 01 WS-C                  FLOAT-LONG.
 01 WS-D                  FLOAT-LONG.
 01 WS-E                  FLOAT-LONG.
 01 WS-F                  FLOAT-LONG.
 01 WS-G                  FLOAT-LONG.
 01 WS-H                  FLOAT-LONG.
 01 WS-J                  FLOAT-LONG.
 01 WS-K                  FLOAT-LONG.
 01 WS-N1                 BINARY-LONG.
 01 WS-N2                 BINARY-LONG.
 01 WS-N3                 BINARY-LONG.
 01 WS-N4                 BINARY-LONG.
 01 WS-N5                 BINARY-LONG.
 01 WS-N6                 BINARY-LONG.
 01 WS-N7                 BINARY-LONG.
 01 WS-N8                 BINARY-LONG.
 01 WS-N9                 BINARY-LONG.
 01 WS-N10                 BINARY-LONG.
 01 WS-N11                 BINARY-LONG.
 01 WS-N12                 BINARY-LONG.
 01 WS-CHAIN.
    05 WS-LEVEL OCCURS 5 TIMES.
       10 WS-AMP            BINARY-LONG.
       10 WS-DUR            BINARY-LONG.
       10 WS-ACTIVE         BINARY-LONG.
 01 WS-TAB.
    05 WS-TN                BINARY-LONG.
    05 WS-TC OCCURS 6 TIMES.
       10 WS-TA             BINARY-LONG.
       10 WS-TB             BINARY-LONG.
       10 WS-TD             BINARY-LONG.
 01 WS-COL.
    05 WS-CELL OCCURS 14 TIMES.
       10 WS-CE             BINARY-LONG.
       10 WS-CF             BINARY-LONG.
 01 WS-S1                  PIC X(32).
 01 WS-S2                  PIC X(32).
 01 WS-S3                  PIC X(32).
 01 WS-S4                  PIC X(32).
 01 WS-S5                  PIC X(32).
 01 WS-S6                  PIC X(32).
 PROCEDURE DIVISION.
     MOVE 0 TO WS-A
     CALL "Q8-CART-SIGNAL" USING WS-A WS-N1
     MOVE "acceptance US15 44-8§4 4.6 an empty container gives signal 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0.0006 TO WS-A
     CALL "Q8-CART-SIGNAL" USING WS-A WS-N1
     MOVE "acceptance US15 44-8§4 4.6 one item in a 27-slot chest (1/27 x 1/64... fill 0.0006) gives 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-A
     CALL "Q8-CART-SIGNAL" USING WS-A WS-N1
     MOVE "acceptance US15 44-8§4 4.6 a full container gives 15" TO WS-CASE
     MOVE 15 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0.5 TO WS-A
     CALL "Q8-CART-SIGNAL" USING WS-A WS-N1
     MOVE "acceptance US15 44-8§4 4.6 half full: floor(14 x 0.5) + 1 = 8" TO WS-CASE
     MOVE 8 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N1
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 15 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-CART-FACTOR" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§4 4.6 a full cart (signal 15) slows at 0.98 (thousandths)" TO WS-CASE
     MOVE 980 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-CART-FACTOR" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§4 4.6 an empty cart (signal 0) slows at 0.995" TO WS-CASE
     MOVE 995 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 8 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-CART-FACTOR" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§4 4.6 signal 8: 0.98 + 7 x 0.001 = 0.987" TO WS-CASE
     MOVE 987 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-CART-FACTOR" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§4 4.6 a loot cart ignores the signal: 0.98" TO WS-CASE
     MOVE 980 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-CART-FACTOR" USING WS-N1 WS-N2 WS-N3 WS-A
     MOVE "acceptance US15 44-8§4 4.6 in water x 0.95: 0.995 x 0.95 = 0.94525 (hundred-thousandths)" TO WS-CASE
     MOVE 94525 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 100000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE -1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 1 for a cart moving north: dx 1 dz 0" TO WS-CASE
     MOVE 10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE -1 TO WS-N2
     MOVE 2 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 2 for a cart moving north: dx -1 dz 0" TO WS-CASE
     MOVE -10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE -1 TO WS-N2
     MOVE 3 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 3 for a cart moving north: dx 1 dz 1" TO WS-CASE
     MOVE 11 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE -1 TO WS-N2
     MOVE 4 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 4 for a cart moving north: dx -1 dz 1" TO WS-CASE
     MOVE -9 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE -1 TO WS-N2
     MOVE 5 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 5 for a cart moving north: dx 1 dz -1" TO WS-CASE
     MOVE 9 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE -1 TO WS-N2
     MOVE 6 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 6 for a cart moving north: dx -1 dz -1" TO WS-CASE
     MOVE -11 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE -1 TO WS-N2
     MOVE 7 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 7 for a cart moving north: dx 0 dz 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE -1 TO WS-N2
     MOVE 8 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 8 for a cart moving north: dx 0 dz -1" TO WS-CASE
     MOVE -1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 1 for a cart moving east: dx 0 dz 1" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 2 for a cart moving east: dx 0 dz -1" TO WS-CASE
     MOVE -1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 3 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 3 for a cart moving east: dx -1 dz 1" TO WS-CASE
     MOVE -9 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 4 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 4 for a cart moving east: dx -1 dz -1" TO WS-CASE
     MOVE -11 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 5 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 5 for a cart moving east: dx 1 dz 1" TO WS-CASE
     MOVE 11 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 6 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 6 for a cart moving east: dx 1 dz -1" TO WS-CASE
     MOVE 9 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 7 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 7 for a cart moving east: dx -1 dz 0" TO WS-CASE
     MOVE -10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 8 TO WS-N3
     CALL "Q8-DISMOUNT-OFFSET" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5
     MOVE "acceptance US15 44-8§4 4.6 dismount offset 8 for a cart moving east: dx 1 dz 0" TO WS-CASE
     MOVE 10 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4 * 10 + WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-8-4-RULES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CHK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 LINKAGE SECTION.
 01 L-CASE                 PIC X(160).
 01 L-EXPECTED             BINARY-LONG.
 01 L-OBSERVED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-EXPECTED L-OBSERVED.
     MOVE "N" TO TL-MODE
     MOVE L-CASE TO TL-CASE
     MOVE L-EXPECTED TO TL-EXPECTED-N
     MOVE L-OBSERVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-CHK.
