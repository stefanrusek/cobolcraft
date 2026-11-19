*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-9-end-bosses-decorations.md section 1 (1.2 step 5), lane 002-lane-p49j-a): the strafe path creation offset yOffset = min(0.4000000059604645 + dist / 80 - 1, 10); the rest of section 1 (hooks, strafe tick, findNewTarget) is proven by acc_us16_dragon_phase and acc_us16_dragon_life (44-9 1.1 and 1.2 cases).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-9-1.
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
     MOVE 40 TO WF1
     CALL "Q9-STRAFE-YOFFSET" USING WF1 WF2
     MOVE "acceptance US15 44-9§1 (1.2 step 5) 1.2 a player at horizontal distance 40: yOffset = 0.4 + 0.5 - 1 = -0.1 (x1000)" TO WS-NAME
     MOVE -100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 160 TO WF1
     CALL "Q9-STRAFE-YOFFSET" USING WF1 WF2
     MOVE "acceptance US15 44-9§1 (1.2 step 5) 1.2 at distance 160: 0.4 + 2 - 1 = 1.4 (x1000)" TO WS-NAME
     MOVE 1400 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 1000 TO WF1
     CALL "Q9-STRAFE-YOFFSET" USING WF1 WF2
     MOVE "acceptance US15 44-9§1 (1.2 step 5) 1.2 the offset is capped at 10 (distance 1000)" TO WS-NAME
     MOVE 10000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     MOVE 0 TO WF1
     CALL "Q9-STRAFE-YOFFSET" USING WF1 WF2
     MOVE "acceptance US15 44-9§1 (1.2 step 5) 1.2 at distance 0 the offset is -0.6 (x1000)" TO WS-NAME
     MOVE -600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WF2 * 1000
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-9-1.
