*> Acceptance test of docs/protocol/44-residual-mob-questions-x2-continuation.md section 15 as rule functions (lane 002-lane-p49j-b, T24400 range): ShootWhenStuck (15.1) and the cow milking rule (15.2). The other entries are dispositions and interface descriptions.

*> The functions of core/src/q44-44-x2.cob are not called by a tick (no engine for them yet, see the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X2-15.
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
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 0 TO WS-N6
     MOVE 1 TO WS-N7
     MOVE 0 TO WS-N8
     CALL "X2-SHOOT-WHEN-STUCK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7 WS-N8 WS-N9 WS-N10
     MOVE "acceptance US15 44-x2§15 15.1 ShootWhenStuck: a breeze in water starts and sets breeze_shoot for 60 ticks" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N9
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE "acceptance US15 44-x2§15 15.1 the expiry is 60" TO WS-CASE
     MOVE 60 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N10
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 1 TO WS-N6
     MOVE 0 TO WS-N7
     MOVE 0 TO WS-N8
     CALL "X2-SHOOT-WHEN-STUCK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7 WS-N8 WS-N9 WS-N10
     MOVE "acceptance US15 44-x2§15 15.1 a breeze that is a passenger starts" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N9
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 0 TO WS-N6
     MOVE 0 TO WS-N7
     MOVE 1 TO WS-N8
     CALL "X2-SHOOT-WHEN-STUCK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7 WS-N8 WS-N9 WS-N10
     MOVE "acceptance US15 44-x2§15 15.1 a levitating breeze starts" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N9
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 0 TO WS-N6
     MOVE 0 TO WS-N7
     MOVE 0 TO WS-N8
     CALL "X2-SHOOT-WHEN-STUCK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7 WS-N8 WS-N9 WS-N10
     MOVE "acceptance US15 44-x2§15 15.1 a free breeze (none of the three) does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N9
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 0 TO WS-N6
     MOVE 1 TO WS-N7
     MOVE 0 TO WS-N8
     CALL "X2-SHOOT-WHEN-STUCK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7 WS-N8 WS-N9 WS-N10
     MOVE "acceptance US15 44-x2§15 15.1 without an attack target it does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N9
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 0 TO WS-N6
     MOVE 1 TO WS-N7
     MOVE 0 TO WS-N8
     CALL "X2-SHOOT-WHEN-STUCK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7 WS-N8 WS-N9 WS-N10
     MOVE "acceptance US15 44-x2§15 15.1 while inhaling it does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N9
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 0 TO WS-N6
     MOVE 1 TO WS-N7
     MOVE 0 TO WS-N8
     CALL "X2-SHOOT-WHEN-STUCK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7 WS-N8 WS-N9 WS-N10
     MOVE "acceptance US15 44-x2§15 15.1 with a jump target it does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N9
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 1 TO WS-N4
     MOVE 0 TO WS-N5
     MOVE 0 TO WS-N6
     MOVE 1 TO WS-N7
     MOVE 0 TO WS-N8
     CALL "X2-SHOOT-WHEN-STUCK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7 WS-N8 WS-N9 WS-N10
     MOVE "acceptance US15 44-x2§15 15.1 with a walk target it does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N9
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 0 TO WS-N4
     MOVE 1 TO WS-N5
     MOVE 0 TO WS-N6
     MOVE 1 TO WS-N7
     MOVE 0 TO WS-N8
     CALL "X2-SHOOT-WHEN-STUCK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6 WS-N7 WS-N8 WS-N9 WS-N10
     MOVE "acceptance US15 44-x2§15 15.1 while breeze_shoot is present it does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N9
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 3 TO WS-N4
     CALL "X2-COW-MILK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-x2§15 15.2 milking an adult cow with a stack of 3 buckets: success and the stack loses one" TO WS-CASE
     MOVE 12 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5 * 10 + WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 1 TO WS-N3
     MOVE 3 TO WS-N4
     CALL "X2-COW-MILK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-x2§15 15.2 a creative player keeps the stack" TO WS-CASE
     MOVE 13 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5 * 10 + WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 1 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 3 TO WS-N4
     CALL "X2-COW-MILK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-x2§15 15.2 a baby cow gives no milk" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5 * 10 + WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-N2
     MOVE 0 TO WS-N3
     MOVE 3 TO WS-N4
     CALL "X2-COW-MILK" USING WS-N1 WS-N2 WS-N3 WS-N4 WS-N5 WS-N6
     MOVE "acceptance US15 44-x2§15 15.2 without a bucket there is no milking" TO WS-CASE
     MOVE 3 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N5 * 10 + WS-N6
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X2-15.

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
