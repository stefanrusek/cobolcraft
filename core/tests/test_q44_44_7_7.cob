*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 7 and worked case 13.14, lane 002-lane-p49j-a): the dolphin jump goal: one chance in 5,
*> six steps (0, 1, 4, 5, 6, 7) that each need water and two air blocks above, canContinueToUse, the start velocity and the pitch rule (57.2957763671875). The goal is proven as
*> functions; the dolphin tick of mob-21-4.cob does not run goals, the treasure and swim-with-player goals and the item goals (7.1, 7.2) are gaps.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-W                   PIC X(8).
 01 WS-A1                  PIC X(8).
 01 WS-A2                  PIC X(8).
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-XROT                FLOAT-LONG.
 01 WS-YAW                 FLOAT-LONG.
 01 WS-INWATER             BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "11111111" TO WS-W WS-A1 WS-A2
     MOVE 0 TO WS-DRAW
     CALL "Q7-JUMP-CAN-USE" USING WS-DRAW WS-W WS-A1 WS-A2 WS-OBS
     MOVE "acceptance US15 44-7§7 13.14 draw 0 with clear water and air at all six steps: the goal starts" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-DRAW
     CALL "Q7-JUMP-CAN-USE" USING WS-DRAW WS-W WS-A1 WS-A2 WS-OBS
     MOVE "acceptance US15 44-7§7 a draw other than 0 (1 chance in 5, nextInt(5) == 0) does not" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-DRAW
     MOVE "11110111" TO WS-W
     CALL "Q7-JUMP-CAN-USE" USING WS-DRAW WS-W WS-A1 WS-A2 WS-OBS
     MOVE "acceptance US15 44-7§7 13.14 stone instead of water at offset 4 fails the goal" TO WS-NAME
     PERFORM EXPECT
     MOVE "11111111" TO WS-W
     MOVE "11111011" TO WS-A1
     CALL "Q7-JUMP-CAN-USE" USING WS-DRAW WS-W WS-A1 WS-A2 WS-OBS
     MOVE "acceptance US15 44-7§7 13.14 a block at +1 above offset 6 also fails it" TO WS-NAME
     PERFORM EXPECT
     MOVE "11111111" TO WS-A1
     MOVE "11111110" TO WS-A2
     CALL "Q7-JUMP-CAN-USE" USING WS-DRAW WS-W WS-A1 WS-A2 WS-OBS
     MOVE "acceptance US15 44-7§7 a block at +2 above offset 7 fails it" TO WS-NAME
     PERFORM EXPECT
*>   Offsets 2 and 3 are not in STEPS_TO_CHECK: a wall there is fine.
     MOVE "11111111" TO WS-A2
     MOVE "11001111" TO WS-W
     MOVE "11001111" TO WS-A1
     CALL "Q7-JUMP-CAN-USE" USING WS-DRAW WS-W WS-A1 WS-A2 WS-OBS
     MOVE "acceptance US15 44-7§7 offsets 2 and 3 are not checked (STEPS_TO_CHECK is 0 1 4 5 6 7)" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE "01111111" TO WS-W
     MOVE "11111111" TO WS-A1
     CALL "Q7-JUMP-CAN-USE" USING WS-DRAW WS-W WS-A1 WS-A2 WS-OBS
     MOVE "acceptance US15 44-7§7 offset 0 (the dolphin's own block) must be water too" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
*>   Facing: yaw 0 south (+z), 90 west, 180 north, 270 east; the start velocity (0.6, 0.7, 0) east.
     MOVE 270 TO WS-YAW
     CALL "Q7-JUMP-FACING" USING WS-YAW WS-DX WS-DZ
     MOVE "acceptance US15 44-7§7 facing east (yaw 270): dx 1" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-DX TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-VX WS-VY WS-VZ
     CALL "Q7-JUMP-START" USING WS-DX WS-DZ WS-VX WS-VY WS-VZ
     MOVE "acceptance US15 44-7§7 13.14 start: vx + 0.6 (x1000)" TO WS-NAME
     MOVE 600 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-VX * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§7 13.14 start: vy + 0.7 (x1000)" TO WS-NAME
     MOVE 700 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-VY * 1000
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§7 13.14 start: vz + 0 for an east dolphin" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-VZ * 1000
     PERFORM EXPECT
     MOVE 90 TO WS-YAW
     CALL "Q7-JUMP-FACING" USING WS-YAW WS-DX WS-DZ
     MOVE "acceptance US15 44-7§7 facing west (yaw 90): dx -1" TO WS-NAME
     MOVE -1 TO WS-EXP
     MOVE WS-DX TO WS-OBS
     PERFORM EXPECT
     MOVE 0 TO WS-YAW
     CALL "Q7-JUMP-FACING" USING WS-YAW WS-DX WS-DZ
     MOVE "acceptance US15 44-7§7 facing south (yaw 0): dz 1" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-DZ TO WS-OBS
     PERFORM EXPECT
     MOVE 200 TO WS-YAW
     CALL "Q7-JUMP-FACING" USING WS-YAW WS-DX WS-DZ
     MOVE "acceptance US15 44-7§7 yaw 200 is nearest north: dz -1" TO WS-NAME
     MOVE -1 TO WS-EXP
     MOVE WS-DZ TO WS-OBS
     PERFORM EXPECT
*>   canContinueToUse.
     MOVE 0 TO WS-GROUND
     MOVE 1 TO WS-INWATER
     MOVE 0.5 TO WS-VY
     MOVE 30 TO WS-XROT
     CALL "Q7-JUMP-CONTINUE" USING WS-GROUND WS-VY WS-XROT WS-INWATER WS-OBS
     MOVE "acceptance US15 44-7§7 in the air: the jump continues" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 1 TO WS-GROUND
     CALL "Q7-JUMP-CONTINUE" USING WS-GROUND WS-VY WS-XROT WS-INWATER WS-OBS
     MOVE "acceptance US15 44-7§7 on the ground: it ends" TO WS-NAME
     MOVE 0 TO WS-EXP
     PERFORM EXPECT
     MOVE 0 TO WS-GROUND
     MOVE 0.1 TO WS-VY
     MOVE 5 TO WS-XROT
     CALL "Q7-JUMP-CONTINUE" USING WS-GROUND WS-VY WS-XROT WS-INWATER WS-OBS
     MOVE "acceptance US15 44-7§7 back in water, vy^2 < 0.03, |pitch| 5 (nonzero, below 10): it ends" TO WS-NAME
     PERFORM EXPECT
     MOVE 0 TO WS-XROT
     CALL "Q7-JUMP-CONTINUE" USING WS-GROUND WS-VY WS-XROT WS-INWATER WS-OBS
     MOVE "acceptance US15 44-7§7 a pitch of exactly 0 does not end it" TO WS-NAME
     MOVE 1 TO WS-EXP
     PERFORM EXPECT
     MOVE 5 TO WS-XROT
     MOVE 0 TO WS-INWATER
     CALL "Q7-JUMP-CONTINUE" USING WS-GROUND WS-VY WS-XROT WS-INWATER WS-OBS
     MOVE "acceptance US15 44-7§7 out of water the small pitch does not end it" TO WS-NAME
     PERFORM EXPECT
     MOVE 1 TO WS-INWATER
     MOVE 12 TO WS-XROT
     CALL "Q7-JUMP-CONTINUE" USING WS-GROUND WS-VY WS-XROT WS-INWATER WS-OBS
     MOVE "acceptance US15 44-7§7 a pitch of 12 (not below 10) does not end it" TO WS-NAME
     PERFORM EXPECT
*>   Pitch rule: along the velocity with the constant 57.2957763671875, or 20% toward 0 when nearly level.
     MOVE 0.3 TO WS-VX
     MOVE 0.5 TO WS-VY
     MOVE 0 TO WS-VZ
     MOVE 0 TO WS-XROT
     CALL "Q7-JUMP-PITCH" USING WS-VX WS-VY WS-VZ WS-XROT
     MOVE "acceptance US15 44-7§7 rising velocity (0.3, 0.5): pitch = atan2(-0.5, 0.3) x 57.2957763671875 = -59.04 (x100)" TO WS-NAME
     MOVE -5904 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-XROT * 100
     PERFORM EXPECT
     MOVE 0.3 TO WS-VX
     MOVE 0.1 TO WS-VY
     MOVE 10 TO WS-XROT
     CALL "Q7-JUMP-PITCH" USING WS-VX WS-VY WS-VZ WS-XROT
     MOVE "acceptance US15 44-7§7 nearly level velocity with pitch 10: rotLerp 0.2 gives 8" TO WS-NAME
     MOVE 8 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-XROT
     PERFORM EXPECT
     MOVE 0.3 TO WS-VX
     MOVE -0.5 TO WS-VY
     MOVE 0 TO WS-XROT
     CALL "Q7-JUMP-PITCH" USING WS-VX WS-VY WS-VZ WS-XROT
     MOVE "acceptance US15 44-7§7 falling velocity (0.3, -0.5): pitch +59.04 (x100)" TO WS-NAME
     MOVE 5904 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-XROT * 100
     PERFORM EXPECT
     MOVE 0 TO WS-VX WS-VY WS-VZ
     MOVE 33 TO WS-XROT
     CALL "Q7-JUMP-PITCH" USING WS-VX WS-VY WS-VZ WS-XROT
     MOVE "acceptance US15 44-7§7 the 0.2 step applies only with a nonzero pitch: a still dolphin at pitch 33 goes to 26.4 (x10)" TO WS-NAME
     MOVE 264 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-XROT * 10
     PERFORM EXPECT
     MOVE 0 TO WS-XROT
     CALL "Q7-JUMP-PITCH" USING WS-VX WS-VY WS-VZ WS-XROT
     MOVE "acceptance US15 44-7§7 a still velocity (length below 1.0E-5) with pitch 0 leaves the pitch alone" TO WS-NAME
     MOVE 0 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-XROT
     PERFORM EXPECT
     MOVE 0 TO WS-VX WS-VZ
     MOVE 1 TO WS-VY
     MOVE 0 TO WS-XROT
     CALL "Q7-JUMP-PITCH" USING WS-VX WS-VY WS-VZ WS-XROT
     MOVE "acceptance US15 44-7§7 straight up (horizontal speed 0): pitch -90 (x10)" TO WS-NAME
     MOVE -900 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-XROT * 10
     PERFORM EXPECT
     MOVE -1 TO WS-VY
     CALL "Q7-JUMP-PITCH" USING WS-VX WS-VY WS-VZ WS-XROT
     MOVE "acceptance US15 44-7§7 straight down: pitch +90 (x10)" TO WS-NAME
     MOVE 900 TO WS-EXP
     COMPUTE WS-OBS ROUNDED = WS-XROT * 10
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-7-7.
