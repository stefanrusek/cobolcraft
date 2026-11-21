*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 5.1 to 5.3, lane 002-lane-p49j-a): the check interval (every 100 ticks), the coexist rule, and the rendered item yaw of a frame; the survival, placement, interaction and damage rules of frames and paintings are proven by acc_us16_frames (44-9 5.3 and 5.4 cases).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-5.
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
     MOVE 98 TO WA
     CALL "Q9-CHECK-TICK" USING WA WB
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.1 the 99th tick of the interval is not due" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 99 TO WA
     CALL "Q9-CHECK-TICK" USING WA WB
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.1 the 100th tick is due" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WB
     PERFORM EXPECT
     MOVE 99 TO WA
     CALL "Q9-CHECK-TICK" USING WA WB
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.1 and the counter is reset to 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WA
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 0 TO WB
     MOVE 0 TO WC
     CALL "Q9-HANG-CONFLICT" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.2 a same-type painting in another direction conflicts when the type rule applies" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 1 TO WA
     MOVE 0 TO WB
     MOVE 1 TO WC
     CALL "Q9-HANG-CONFLICT" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.2 the same type is ignored when ignoreType is true (item frames, canCoexist(true))" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 1 TO WB
     MOVE 1 TO WC
     CALL "Q9-HANG-CONFLICT" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.2 the same direction always conflicts" TO WS-NAME
     MOVE 1 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 0 TO WB
     MOVE 0 TO WC
     CALL "Q9-HANG-CONFLICT" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.2 a different type and direction does not" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 0 TO WB
     MOVE 0 TO WC
     CALL "Q9-FRAME-YAW" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.3 SOUTH rotation 0 renders at yaw -180" TO WS-NAME
     MOVE -180 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 1 TO WA
     CALL "Q9-FRAME-YAW" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.3 WEST rotation 0: -90" TO WS-NAME
     MOVE -90 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 2 TO WA
     CALL "Q9-FRAME-YAW" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.3 NORTH rotation 0: 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 3 TO WA
     CALL "Q9-FRAME-YAW" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.3 EAST rotation 0: 90" TO WS-NAME
     MOVE 90 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE -1 TO WA
     MOVE 1 TO WB
     CALL "Q9-FRAME-YAW" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.3 UP (d2 -1, step +1) rotation 0: -180" TO WS-NAME
     MOVE -180 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE -1 TO WA
     MOVE -1 TO WB
     CALL "Q9-FRAME-YAW" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.3 DOWN (d2 -1, step -1) rotation 0: 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     MOVE 0 TO WA
     MOVE 0 TO WB
     MOVE 3 TO WC
     CALL "Q9-FRAME-YAW" USING WA WB WC WD
     MOVE "acceptance US15 44-9§5.1 to 5.3 5.3 a SOUTH frame at rotation 3: 180 + 135 = 315 wraps to -45" TO WS-NAME
     MOVE -45 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WD
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-5.
