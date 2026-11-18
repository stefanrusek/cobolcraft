*> Acceptance test of docs/protocol/44-residual-mob-questions-x1-continuation.md section 3, Mob.finalizeSpawn defaults as a rule function (lane 002-lane-p49j-b, T24300 range): the random_spawn_bonus
*> triangle on follow_range (only when the modifier is absent) and the left-handed draw (nextFloat < 0.05). X1-FINALIZE-DEFAULTS is not yet called by STDMOB-FINALIZE: the two draws would shift every
*> seeded spawn test (blocker recorded in the lane task list).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-X1-3.
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
 01 WS-CHAIN.
    05 WS-LEVEL OCCURS 5 TIMES.
       10 WS-AMP            BINARY-LONG.
       10 WS-DUR            BINARY-LONG.
       10 WS-ACTIVE         BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-N1
     MOVE 0.9 TO WS-A
     MOVE 0.1 TO WS-B
     MOVE 0.5 TO WS-C
     CALL "X1-FINALIZE-DEFAULTS" USING WS-N1 WS-A WS-B WS-C WS-D WS-N2
     MOVE "acceptance US15 44-x1§3 the follow_range bonus triangle(0, 0.11485) of draws 0.9 and 0.1 (hundred-thousandths)" TO WS-CASE
     MOVE 9188 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 100000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 0.5 TO WS-C
     CALL "X1-FINALIZE-DEFAULTS" USING WS-N1 WS-A WS-B WS-C WS-D WS-N2
     MOVE "acceptance US15 44-x1§3 the draws 1 and 0 give the upper bound 0.11485 (hundred-thousandths)" TO WS-CASE
     MOVE 11485 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 100000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     MOVE 0.5 TO WS-C
     CALL "X1-FINALIZE-DEFAULTS" USING WS-N1 WS-A WS-B WS-C WS-D WS-N2
     MOVE "acceptance US15 44-x1§3 the draws 0 and 1 give the lower bound -0.11485 (hundred-thousandths)" TO WS-CASE
     MOVE -11485 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 100000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0.9 TO WS-A
     MOVE 0.1 TO WS-B
     MOVE 0.5 TO WS-C
     CALL "X1-FINALIZE-DEFAULTS" USING WS-N1 WS-A WS-B WS-C WS-D WS-N2
     MOVE "acceptance US15 44-x1§3 a mob that already has the modifier gets no bonus" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-D * 100000
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0.5 TO WS-A
     MOVE 0.5 TO WS-B
     MOVE 0.049 TO WS-C
     CALL "X1-FINALIZE-DEFAULTS" USING WS-N1 WS-A WS-B WS-C WS-D WS-N2
     MOVE "acceptance US15 44-x1§3 nextFloat 0.049 makes it left-handed" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0.5 TO WS-A
     MOVE 0.5 TO WS-B
     MOVE 0.05 TO WS-C
     CALL "X1-FINALIZE-DEFAULTS" USING WS-N1 WS-A WS-B WS-C WS-D WS-N2
     MOVE "acceptance US15 44-x1§3 nextFloat 0.05 does not (strict comparison)" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 0 TO WS-N1
     MOVE 0.5 TO WS-A
     MOVE 0.5 TO WS-B
     MOVE 0.9 TO WS-C
     CALL "X1-FINALIZE-DEFAULTS" USING WS-N1 WS-A WS-B WS-C WS-D WS-N2
     MOVE "acceptance US15 44-x1§3 nextFloat 0.9 does not" TO WS-CASE
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     MOVE 1 TO WS-N1
     MOVE 0.5 TO WS-A
     MOVE 0.5 TO WS-B
     MOVE 0.01 TO WS-C
     CALL "X1-FINALIZE-DEFAULTS" USING WS-N1 WS-A WS-B WS-C WS-D WS-N2
     MOVE "acceptance US15 44-x1§3 the left-handed draw is taken even when the modifier is present" TO WS-CASE
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-N2
     CALL "TEST-CHK" USING WS-CASE WS-EXP WS-OBS
     STOP RUN.
 END PROGRAM TEST-Q44-44-X1-3.

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
