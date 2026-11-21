*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 11, lane 002-lane-p49j-a): the per-mob water control parameters table, the
*> turning speed factor out of water (1 - clamp((angle - 10) / 50, 0, 1)), the body-follows-head step of 4 degrees, WaterBoundPathNavigation (only a dolphin may breach)
*> and the dolphin's vertical drift (the control's +0.005 against the travel's -0.005). Functions only: the controls themselves (18 section 4.4) are not modelled.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-MAXX                BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-INW                 FLOAT-LONG.
 01 WS-OUT                 FLOAT-LONG.
 01 WS-GRAV                BINARY-LONG.
 01 WS-LOOK                BINARY-LONG.
 01 WS-BREACH              BINARY-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-LIQ                 BINARY-LONG.
 01 WS-TGT                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "dolphin" TO WS-KEY
     PERFORM CTRL
     MOVE "acceptance US15 44-7§11 dolphin SmoothSwimmingMoveControl(85, 10, 0.02, 0.1, true): 85 and 10" TO WS-NAME
     MOVE 8510 TO WS-EXP
     COMPUTE WS-OBS = WS-MAXX * 100 + WS-MAXY
     IF WS-MAXX = 85 AND WS-MAXY = 10
         MOVE 8510 TO WS-OBS
     END-IF
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§11 dolphin in-water modifier 0.02 (x1000)" TO WS-NAME
     MOVE 20 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-INW * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§11 dolphin outside modifier 0.1 (x1000)" TO WS-NAME
     MOVE 100 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-OUT * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§11 dolphin applyGravity true, look control SmoothSwimmingLookControl(10), navigation with breaching" TO WS-NAME
     MOVE 1110 TO WS-EXP
     COMPUTE WS-OBS = WS-GRAV * 1000 + WS-BREACH * 100 + WS-LOOK
     PERFORM EXPECT
     MOVE "nautilus" TO WS-KEY
     PERFORM CTRL
     MOVE "acceptance US15 44-7§11 nautilus (0.011, 0) in-water modifier 0.011 (x10000 = 110) and outside 0" TO WS-NAME
     MOVE 110 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-INW * 10000 + WS-OUT * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§11 nautilus applyGravity true, no breaching, look 10" TO WS-NAME
     MOVE 1010 TO WS-EXP
     COMPUTE WS-OBS = WS-GRAV * 1000 + WS-BREACH * 100 + WS-LOOK
     PERFORM EXPECT
     MOVE "zombie_nautilus" TO WS-KEY
     PERFORM CTRL
     MOVE "acceptance US15 44-7§11 zombie nautilus has the nautilus parameters (inherited)" TO WS-NAME
     COMPUTE WS-OBS = WS-GRAV * 1000 + WS-BREACH * 100 + WS-LOOK
     PERFORM EXPECT
     MOVE "axolotl" TO WS-KEY
     PERFORM CTRL
     MOVE "acceptance US15 44-7§11 axolotl AxolotlMoveControl(85, 10, 0.1, 0.5, false): gravity off, look 20, no breaching" TO WS-NAME
     MOVE 20 TO WS-EXP
     COMPUTE WS-OBS = WS-GRAV * 1000 + WS-BREACH * 100 + WS-LOOK
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§11 axolotl modifiers 0.1 in water and 0.5 outside (x1000)" TO WS-NAME
     MOVE 600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-INW * 1000 + WS-OUT * 1000
     PERFORM EXPECT
*>   the turning speed factor.
     MOVE 10 TO WS-ANGLE
     CALL "Q7-TURN-FACTOR" USING WS-ANGLE WS-F
     MOVE "acceptance US15 44-7§11 turning factor at an angle of 10: 1.0 (x1000)" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-F * 1000
     PERFORM EXPECT
     MOVE 35 TO WS-ANGLE
     CALL "Q7-TURN-FACTOR" USING WS-ANGLE WS-F
     MOVE "acceptance US15 44-7§11 turning factor at 35: 1 - 25 / 50 = 0.5" TO WS-NAME
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-F * 1000
     PERFORM EXPECT
     MOVE 60 TO WS-ANGLE
     CALL "Q7-TURN-FACTOR" USING WS-ANGLE WS-F
     MOVE "acceptance US15 44-7§11 turning factor at 60: 0" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-F * 1000
     PERFORM EXPECT
     MOVE 120 TO WS-ANGLE
     CALL "Q7-TURN-FACTOR" USING WS-ANGLE WS-F
     MOVE "acceptance US15 44-7§11 and it stays 0 beyond (the stop threshold constant is unused)" TO WS-NAME
     COMPUTE WS-OBS ROUNDED = WS-F * 1000
     PERFORM EXPECT
     MOVE 3 TO WS-ANGLE
     CALL "Q7-TURN-FACTOR" USING WS-ANGLE WS-F
     MOVE "acceptance US15 44-7§11 an angle below 10 is clamped to 1.0" TO WS-NAME
     MOVE 1000 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-F * 1000
     PERFORM EXPECT
*>   body follows the head by 4 degrees when it is beyond maxYRotFromCenter.
     MOVE 10 TO WS-MAX
     MOVE -11 TO WS-DIFF
     CALL "Q7-BODY-TURN" USING WS-DIFF WS-MAX WS-OBS
     MOVE "acceptance US15 44-7§11 head 11 degrees left of the body (limit 10): the body yaw decreases by 4" TO WS-NAME
     MOVE -4 TO WS-EXP
     PERFORM EXPECT
     MOVE 11 TO WS-DIFF
     CALL "Q7-BODY-TURN" USING WS-DIFF WS-MAX WS-OBS
     MOVE "acceptance US15 44-7§11 head 11 degrees right: the body yaw increases by 4" TO WS-NAME
     MOVE 4 TO WS-EXP
     PERFORM EXPECT
     MOVE 10 TO WS-DIFF
     CALL "Q7-BODY-TURN" USING WS-DIFF WS-MAX WS-OBS
     MOVE "acceptance US15 44-7§11 exactly at the limit: no change" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
*>   navigation: canUpdatePath is breaching allowed or in liquid.
     MOVE 1 TO WS-BREACH
     MOVE 0 TO WS-LIQ
     CALL "Q7-CAN-UPDATE-PATH" USING WS-BREACH WS-LIQ WS-OBS
     MOVE "acceptance US15 44-7§11 a dolphin (breaching) can re-path in the air" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-BREACH
     CALL "Q7-CAN-UPDATE-PATH" USING WS-BREACH WS-LIQ WS-OBS
     MOVE "acceptance US15 44-7§11 the others only in liquid: not in the air" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-LIQ
     CALL "Q7-CAN-UPDATE-PATH" USING WS-BREACH WS-LIQ WS-OBS
     MOVE "acceptance US15 44-7§11 and in liquid yes" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
*>   4.2 vertical drift of a dolphin.
     MOVE 0 TO WS-TGT
     CALL "Q7-DOLPHIN-VY" USING WS-TGT WS-F
     MOVE "acceptance US15 44-7§4.2 an idle dolphin: the control's +0.005 and travel's -0.005 cancel (0)" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-F * 100000
     PERFORM EXPECT
     MOVE 1 TO WS-TGT
     CALL "Q7-DOLPHIN-VY" USING WS-TGT WS-F
     MOVE "acceptance US15 44-7§4.2 with an attack target only the +0.005 remains (x100000 = 500)" TO WS-NAME
     MOVE 500 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-F * 100000
     PERFORM EXPECT
     STOP RUN.
 CTRL.
     CALL "Q7-CTRL" USING WS-KEY WS-MAXX WS-MAXY WS-INW WS-OUT WS-GRAV WS-LOOK WS-BREACH.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-7-11.
