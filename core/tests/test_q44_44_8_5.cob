*> Acceptance test of docs/protocol/44-residual-mob-questions-8-vehicles-and-projectiles.md section 5 as rule functions (lane 002-lane-p49j-b, T24200 range): the camel seat z (V18, 12.8) and the body anchor height with its sitting and standing transitions, expected values computed independently from the formulas of the document.

*> The functions of core/src/q44-44-8.cob are not called by a tick (no entity engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-8-5.
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
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-A
     CALL "Q8-CAMEL-SEAT-Z" USING WS-N1 WS-N2 WS-N3 WS-A WS-B
     MOVE "acceptance US15 44-8§5 5 V18 a single adult passenger sits at z 0.5 (thousandths)" TO WS-CASE
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-A
     CALL "Q8-CAMEL-SEAT-Z" USING WS-N1 WS-N2 WS-N3 WS-A WS-B
     MOVE "acceptance US15 44-8§5 5 a single Animal gets no bonus" TO WS-CASE
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-A
     CALL "Q8-CAMEL-SEAT-Z" USING WS-N1 WS-N2 WS-N3 WS-A WS-B
     MOVE "acceptance US15 44-8§5 5 two passengers: the first 0.5" TO WS-CASE
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-A
     CALL "Q8-CAMEL-SEAT-Z" USING WS-N1 WS-N2 WS-N3 WS-A WS-B
     MOVE "acceptance US15 44-8§5 5 two passengers: the second -0.7" TO WS-CASE
     MOVE -700 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-A
     CALL "Q8-CAMEL-SEAT-Z" USING WS-N1 WS-N2 WS-N3 WS-A WS-B
     MOVE "acceptance US15 44-8§5 5 two passengers: an Animal in front 0.7" TO WS-CASE
     MOVE 700 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 2 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-A
     CALL "Q8-CAMEL-SEAT-Z" USING WS-N1 WS-N2 WS-N3 WS-A WS-B
     MOVE "acceptance US15 44-8§5 5 two passengers: an Animal in the rear -0.5" TO WS-CASE
     MOVE -500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 3 TO WS-N1
     MOVE 2 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-A
     CALL "Q8-CAMEL-SEAT-Z" USING WS-N1 WS-N2 WS-N3 WS-A WS-B
     MOVE "acceptance US15 44-8§5 5 three passengers: the third seat is the rear seat -0.7" TO WS-CASE
     MOVE -700 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0.6 TO WS-A
     CALL "Q8-CAMEL-SEAT-Z" USING WS-N1 WS-N2 WS-N3 WS-A WS-B
     MOVE "acceptance US15 44-8§5 5 a baby (scale 0.6) single passenger: 0.3" TO WS-CASE
     MOVE 300 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-B * 1000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height 12.8 standing adult: 2.0" TO WS-CASE
     MOVE 20000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1.9 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height sitting, no transition (height 1.9): h + d2" TO WS-CASE
     MOVE 17250 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height sitting down, front seat, t = 0" TO WS-CASE
     MOVE 34300 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 14 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height sitting down, front seat, t = 14" TO WS-CASE
     MOVE 31225 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 28 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height sitting down, front seat, t = 28" TO WS-CASE
     MOVE 28150 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 34 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height sitting down, front seat, t = 34" TO WS-CASE
     MOVE 25075 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 40 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height sitting down, front seat, t = 40" TO WS-CASE
     MOVE 22000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 100 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height sitting down, front seat, t = 100 (clamped to 40)" TO WS-CASE
     MOVE 22000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE -5 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height sitting down, front seat, t = -5 (clamped to 0)" TO WS-CASE
     MOVE 34300 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 14 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height sitting down, rear seat, t = 14" TO WS-CASE
     MOVE 33685 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 30 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height sitting down, rear seat, t = 30" TO WS-CASE
     MOVE 31225 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 0 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height standing up, front seat, t = 0" TO WS-CASE
     MOVE 7700 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 12 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height standing up, front seat, t = 12" TO WS-CASE
     MOVE 11390 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 38 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height standing up, front seat, t = 38" TO WS-CASE
     MOVE 17540 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 52 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height standing up, front seat, t = 52" TO WS-CASE
     MOVE 20000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 16 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height standing up, rear seat, t = 16" TO WS-CASE
     MOVE 9853 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 2.375 TO WS-A
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 40 TO WS-B
     MOVE 1 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height standing up, rear seat, t = 40" TO WS-CASE
     MOVE 15203 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1.4 TO WS-A
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-B
     MOVE 0.6 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height baby (scale 0.6) standing, height 1.4" TO WS-CASE
     MOVE 13063 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1.4 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-B
     MOVE 0.6 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height baby sitting, no transition" TO WS-CASE
     MOVE 14263 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1.4 TO WS-A
     MOVE 1 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 14 TO WS-B
     MOVE 0.6 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height baby sitting down, front seat, t = 14" TO WS-CASE
     MOVE 19798 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 1.4 TO WS-A
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 20 TO WS-B
     MOVE 0.6 TO WS-C
     CALL "Q8-CAMEL-ANCHOR" USING WS-N1 WS-N2 WS-A WS-N3 WS-N4 WS-B WS-C WS-D
     MOVE "acceptance US15 44-8§5 5 camel seat height baby standing up, rear seat, t = 20" TO WS-CASE
     MOVE 7297 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 10000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-8-5.

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
