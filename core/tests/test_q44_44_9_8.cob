*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 8.2, lane 002-lane-p49j-a): the mannequin dimensions by pose (standing 0.6 x 1.8 eye 1.62, crouching 0.6 x 1.5 eye 1.27, swimming and fall flying 0.6 x 0.6 eye 0.4, sleeping 0.2 x 0.2 eye 0.2, dying 0.2 x 0.2 eye 1.62, unlisted poses stand). The cushion rules (8.1) and the mannequin entity have no core entity yet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WA                      BINARY-LONG.
 01 WB                      BINARY-LONG.
 01 WC                      BINARY-LONG.
 01 WD                      BINARY-LONG.
 01 WE                      BINARY-LONG.
 01 WF1                     FLOAT-LONG.
 01 WF2                     FLOAT-LONG.
 01 WF3                     FLOAT-LONG.
 01 WF4                     FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WA
     CALL "Q9-MAN-DIM" USING WA WF1 WF2 WF3
     MOVE "acceptance US15 44-9§8.2 8.2 standing: 1.8 high" TO WS-NAME
     MOVE 1800 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 1 TO WA
     CALL "Q9-MAN-DIM" USING WA WF1 WF2 WF3
     MOVE "acceptance US15 44-9§8.2 8.2 crouching: 1.5 high" TO WS-NAME
     MOVE 1500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 2 TO WA
     CALL "Q9-MAN-DIM" USING WA WF1 WF2 WF3
     MOVE "acceptance US15 44-9§8.2 8.2 swimming: 0.6 x 0.6, eye 0.4 (x1000: 600600400 / 1000)" TO WS-NAME
     MOVE 600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§8.2 8.2 swimming height 0.6" TO WS-NAME
     MOVE 600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§8.2 8.2 swimming eye 0.4" TO WS-NAME
     MOVE 400 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF3 * 1000
     PERFORM EXPECT
     MOVE 3 TO WA
     CALL "Q9-MAN-DIM" USING WA WF1 WF2 WF3
     MOVE "acceptance US15 44-9§8.2 8.2 fall flying has the swimming size (eye 0.4)" TO WS-NAME
     MOVE 400 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF3 * 1000
     PERFORM EXPECT
     MOVE 4 TO WA
     CALL "Q9-MAN-DIM" USING WA WF1 WF2 WF3
     MOVE "acceptance US15 44-9§8.2 8.2 sleeping: 0.2 x 0.2, eye 0.2" TO WS-NAME
     MOVE 200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF3 * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§8.2 8.2 sleeping width 0.2" TO WS-NAME
     MOVE 200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 1000
     PERFORM EXPECT
     MOVE 6 TO WA
     CALL "Q9-MAN-DIM" USING WA WF1 WF2 WF3
     MOVE "acceptance US15 44-9§8.2 8.2 dying: 0.2 x 0.2 with eye 1.62" TO WS-NAME
     MOVE 1620 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF3 * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§8.2 8.2 dying height 0.2" TO WS-NAME
     MOVE 200 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 9 TO WA
     CALL "Q9-MAN-DIM" USING WA WF1 WF2 WF3
     MOVE "acceptance US15 44-9§8.2 8.2 an unlisted pose (9) stands: height 1.8" TO WS-NAME
     MOVE 1800 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 1 TO WA
     CALL "Q9-MAN-DIM" USING WA WF1 WF2 WF3
     MOVE "acceptance US15 44-9§8.2 crouching eye height 1.27" TO WS-NAME
     MOVE 1270 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF3 * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-9§8.2 crouching width 0.6" TO WS-NAME
     MOVE 600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF1 * 1000
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-8.
