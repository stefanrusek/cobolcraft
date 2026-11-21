*> Acceptance test of docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 3 as rule functions (lane 002-lane-p49j-b, T24200 range): the boat push rule, passenger limit, seats (V5), clamp rotation, ride height and the bubble column tick and effect.

*> The functions of core/src/q44-44-8.cob are not called by a tick (no entity engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-3-RULES.
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
     MOVE 1 TO WS-N1
     MOVE 64.3 TO WS-A
     MOVE 64 TO WS-B
     MOVE 64.5625 TO WS-C
     CALL "Q8-BOAT-PUSH" USING WS-N1 WS-A WS-B WS-C WS-N2
     MOVE "acceptance US15 44-8§3 3.2 another boat whose minY is below the boat's maxY pushes it" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 64.5625 TO WS-A
     MOVE 64 TO WS-B
     MOVE 64.5625 TO WS-C
     CALL "Q8-BOAT-PUSH" USING WS-N1 WS-A WS-B WS-C WS-N2
     MOVE "acceptance US15 44-8§3 3.2 another boat at the boat's maxY does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 64 TO WS-A
     MOVE 64 TO WS-B
     MOVE 64.5625 TO WS-C
     CALL "Q8-BOAT-PUSH" USING WS-N1 WS-A WS-B WS-C WS-N2
     MOVE "acceptance US15 44-8§3 3.2 another entity at the boat's minY pushes" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 64.1 TO WS-A
     MOVE 64 TO WS-B
     MOVE 64.5625 TO WS-C
     CALL "Q8-BOAT-PUSH" USING WS-N1 WS-A WS-B WS-C WS-N2
     MOVE "acceptance US15 44-8§3 3.2 another entity standing above the bottom does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BOAT-CAN-ADD" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§3 3.1 a boat with one passenger takes a second" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BOAT-CAN-ADD" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§3 3.1 a boat with two passengers is full" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BOAT-CAN-ADD" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§3 3.1 a chest boat is full with one" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BOAT-CAN-ADD" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§3 3.1 an empty chest boat takes one" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-BOAT-CAN-ADD" USING WS-N1 WS-N2 WS-N3 WS-N4
     MOVE "acceptance US15 44-8§3 3.1 a boat whose eye is in water takes none" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-BOAT-SEAT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-A
     MOVE "acceptance US15 44-8§3 3.6 V5 a player first of two: z 0.2 (thousandths)" TO WS-CASE
     MOVE 200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-BOAT-SEAT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-A
     MOVE "acceptance US15 44-8§3 3.6 V5 a cow second of two: -0.6 + 0.2 = -0.4" TO WS-CASE
     MOVE -400 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-BOAT-SEAT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-A
     MOVE "acceptance US15 44-8§3 3.6 a lone passenger sits at 0.0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-BOAT-SEAT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-A
     MOVE "acceptance US15 44-8§3 3.6 a lone Animal gets no bonus" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     CALL "Q8-BOAT-SEAT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-A
     MOVE "acceptance US15 44-8§3 3.6 a lone passenger of a chest boat sits at 0.15" TO WS-CASE
     MOVE 150 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-BOAT-SEAT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-A
     MOVE "acceptance US15 44-8§3 3.6 the first of two Animals: 0.2 + 0.2 = 0.4" TO WS-CASE
     MOVE 400 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     CALL "Q8-BOAT-SEAT" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-A
     MOVE "acceptance US15 44-8§3 3.6 the second non-Animal: -0.6" TO WS-CASE
     MOVE -600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     CALL "Q8-BOAT-RIDE-HEIGHT" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§3 3.6 ride height of a boat is 0.1875 (ten-thousandths)" TO WS-CASE
     MOVE 1875 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     CALL "Q8-BOAT-RIDE-HEIGHT" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§3 3.6 ride height of a raft is 0.5 (ten-thousandths)" TO WS-CASE
     MOVE 5000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 50 TO WS-B
     CALL "Q8-BOAT-CLAMP" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-8§3 3.6 a passenger looking 50 degrees off the bow is not changed" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE 150 TO WS-B
     CALL "Q8-BOAT-CLAMP" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-8§3 3.6 a passenger looking 150 degrees off is pulled back by 45" TO WS-CASE
     MOVE -45 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-A
     MOVE -150 TO WS-B
     CALL "Q8-BOAT-CLAMP" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-8§3 3.6 and -150 is pulled by +45" TO WS-CASE
     MOVE 45 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 170 TO WS-A
     MOVE -170 TO WS-B
     CALL "Q8-BOAT-CLAMP" USING WS-A WS-B WS-C
     MOVE "acceptance US15 44-8§3 3.6 the difference wraps (boat 170, passenger -170: delta 20, kept)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-C
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 30 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BOAT-BUBBLE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-8§3 3.7 no column: bubbleTime reset to 0" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BOAT-BUBBLE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-8§3 3.7 a column with time 0 does not act yet" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 59 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BOAT-BUBBLE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-8§3 3.7 time 59 counts down to 58 without acting" TO WS-CASE
     MOVE 58 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§3 3.7 no launch at 58" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     CALL "Q8-BOAT-BUBBLE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-8§3 3.7 at time 1 the push column acts: event 72" TO WS-CASE
     MOVE 72 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§3 3.7 and launches" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§3 3.7 a push column ejects nobody" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     CALL "Q8-BOAT-BUBBLE" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-8§3 3.7 a drag column acts at time 1: event 71" TO WS-CASE
     MOVE 71 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-8§3 3.7 and ejects the passengers" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N4
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-A
     CALL "Q8-BUBBLE-EFFECT" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§3 3.7 a drag column: vy -0.7 (thousandths)" TO WS-CASE
     MOVE -700 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE -0.3 TO WS-A
     CALL "Q8-BUBBLE-EFFECT" USING WS-N1 WS-A
     MOVE "acceptance US15 44-8§3 3.7 a push column: vy = 0.6 whatever it was" TO WS-CASE
     MOVE 600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-A * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-8-3-RULES.

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
