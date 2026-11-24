*> The dolphin's swim-with-player and jump goals (lane p49d; docs/protocol/21 section 4.6 with 44 part 7 sections 7 and 7.2). STDMOB-AQUATIC-STEP calls DOLPHIN-TICK for a dolphin.
*> Tracker fields it uses: EN-FOE = the swimming player's entity row (0 none), EN-PH-SET = 1 while a jump runs (the goal is "not interruptible"), EN-PITCH = xRot in degrees.
*> Entry points:
*>   DOLPHIN-JUMP-CLEAR USING row, ok out: DolphinJumpGoal.canUse without its draw: for each offset s of 0, 1, 4, 5, 6, 7 along the horizontal facing, the block p + s is water (not a
*>     motion-blocking block) and the two blocks above it are air.
*>   DOLPHIN-JUMP-START USING row: velocity + (dx x 0.6, 0.7, dz x 0.6) along the facing; the jump is running (EN-PH-SET 1).
*>   DOLPHIN-JUMP-PITCH USING row: the pitch of a jump tick: a level velocity (vy squared below 0.03) with a pitch moves it 20 % toward 0; otherwise the nose follows the velocity,
*>     atan2(-vy, horizontal speed) x 57.2957763671875.
*>   DOLPHIN-TICK USING row, table row, in water: the running jump; DolphinSwimWithPlayerGoal (the nearest player within 10 blocks who is swimming; Dolphin's Grace for 100 ticks at the
*>     start and with chance 1 / 6 a tick; follow at modifier 4.0, stand within 2.5 blocks; ends when the player stops swimming or is 16 blocks away); a jump with chance 1 / 5 a tick
*>     when the water ahead is clear; otherwise the stroll (AQUA-SWIM).
*> Gaps: the treasure goal, the item goals, BreathAirGoal and the Guardian avoidance, the jump sound, and a dolphin with an attack target of the player (swim-with-player skips that case only
*> through the dolphin never having an attack target here).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOLPHIN-FACING.
*> USING row, dx out, dz out (BINARY-LONG): the horizontal Direction nearest the yaw (yaw 0 faces +z, 90 faces -x).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DX L-DZ.
     COMPUTE WS-Q = FUNCTION MOD(FUNCTION INTEGER(EN-YAW(L-ROW) / 90 + 0.5), 4)
     EVALUATE WS-Q
         WHEN 0
             MOVE 0 TO L-DX
             MOVE 1 TO L-DZ
         WHEN 1
             MOVE -1 TO L-DX
             MOVE 0 TO L-DZ
         WHEN 2
             MOVE 0 TO L-DX
             MOVE -1 TO L-DZ
         WHEN OTHER
             MOVE 1 TO L-DX
             MOVE 0 TO L-DZ
     END-EVALUATE
     GOBACK.
 END PROGRAM DOLPHIN-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOLPHIN-JUMP-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-STEPS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              BINARY-LONG VALUE 5.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 7.
 01 WS-STEP-TABLE REDEFINES WS-STEPS.
    05 WS-STEP             BINARY-LONG OCCURS 6 TIMES.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OK.
     MOVE 1 TO L-OK
     CALL "DOLPHIN-FACING" USING L-ROW WS-DX WS-DZ
     COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-X = WS-PX + WS-DX * WS-STEP(WS-I)
         COMPUTE WS-Z = WS-PZ + WS-DZ * WS-STEP(WS-I)
         CALL "MS6-BLOCK-KIND" USING EN-DIM(L-ROW) WS-X WS-PY WS-Z WS-KIND
         IF WS-KIND NOT = 2
             MOVE 0 TO L-OK
         END-IF
         COMPUTE WS-ABOVE = WS-PY + 1
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-ABOVE WS-Z WS-STATE
         IF WS-STATE NOT = 0
             MOVE 0 TO L-OK
         END-IF
         COMPUTE WS-ABOVE = WS-PY + 2
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-ABOVE WS-Z WS-STATE
         IF WS-STATE NOT = 0
             MOVE 0 TO L-OK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM DOLPHIN-JUMP-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOLPHIN-JUMP-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "DOLPHIN-FACING" USING L-ROW WS-DX WS-DZ
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + WS-DX * 0.6
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + 0.7
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + WS-DZ * 0.6
     MOVE 1 TO EN-PH-SET(L-ROW)
     GOBACK.
 END PROGRAM DOLPHIN-JUMP-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOLPHIN-JUMP-PITCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HS                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-PITCH(L-ROW) TO WS-PITCH
     COMPUTE WS-HS = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     COMPUTE WS-LEN = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VY(L-ROW) * EN-VY(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     EVALUATE TRUE
         WHEN EN-VY(L-ROW) * EN-VY(L-ROW) < 0.03 AND WS-PITCH NOT = 0
             COMPUTE WS-PITCH = WS-PITCH + 0.2 * (0 - WS-PITCH)
         WHEN WS-LEN > 0.00001 AND WS-HS > 0
             COMPUTE WS-PITCH = FUNCTION ATAN(0 - EN-VY(L-ROW) / WS-HS) * 57.2957763671875
         WHEN WS-LEN > 0.00001 AND EN-VY(L-ROW) > 0
             MOVE -90 TO WS-PITCH
         WHEN WS-LEN > 0.00001
             MOVE 90 TO WS-PITCH
     END-EVALUATE
     MOVE WS-PITCH TO EN-PITCH(L-ROW)
     GOBACK.
 END PROGRAM DOLPHIN-JUMP-PITCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOLPHIN-GRACE.
*> USING player row: Dolphin's Grace (effect 29) for 100 ticks, amplifier 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GRACE               BINARY-LONG VALUE 29.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 100.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER.
     CALL "EFFECT-ADD" USING L-PLAYER WS-GRACE WS-AMP WS-DUR WS-FLAGS
     GOBACK.
 END PROGRAM DOLPHIN-GRACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DOLPHIN-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-P                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-KEEP                BINARY-LONG.
 01 WS-SALT                BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-WET.
*>   A running jump goes on while the dolphin is off the ground and not yet level in water; then the goal stops (xRot 0).
     IF EN-PH-SET(L-ROW) = 1
         IF EN-ON-GROUND(L-ROW) = 0 AND NOT (EN-VY(L-ROW) * EN-VY(L-ROW) < 0.03 AND EN-PITCH(L-ROW) NOT = 0
                 AND FUNCTION ABS(EN-PITCH(L-ROW)) < 10 AND L-WET = 1)
             CALL "DOLPHIN-JUMP-PITCH" USING L-ROW
             GOBACK
         END-IF
         MOVE 0 TO EN-PH-SET(L-ROW) EN-PITCH(L-ROW)
     END-IF
     IF L-WET = 0
         GOBACK
     END-IF
*>   The player of DolphinSwimWithPlayerGoal: kept while it swims within 16 blocks, else the nearest swimming player within 10 blocks.
     MOVE EN-FOE(L-ROW) TO WS-Q
     MOVE 0 TO WS-KEEP
     IF WS-Q > 0
         MOVE EN-PLAYER(WS-Q) TO WS-P
         IF WS-P > 0
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             IF PL-USED(WS-P) = 1 AND PL-SWIMMING(WS-P) = 1 AND WS-D2 < 256
                 MOVE 1 TO WS-KEEP
             END-IF
         END-IF
         IF WS-KEEP = 0
             MOVE 0 TO EN-FOE(L-ROW)
             MOVE 0 TO EN-SWIM-SPEED(L-ROW)
         END-IF
     END-IF
     IF WS-KEEP = 0
         MOVE 101 TO WS-BEST
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-MODE(WS-P) NOT = 3 AND PL-ENTITY-ROW(WS-P) > 0
                 COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
                 IF WS-D2 <= 100 AND WS-D2 < WS-BEST
                     MOVE WS-D2 TO WS-BEST
                     MOVE WS-P TO WS-Q
                 END-IF
             END-IF
         END-PERFORM
         IF WS-BEST < 101 AND PL-SWIMMING(WS-Q) = 1
             MOVE PL-ENTITY-ROW(WS-Q) TO EN-FOE(L-ROW)
             CALL "DOLPHIN-GRACE" USING WS-Q
             MOVE 1 TO WS-KEEP
         END-IF
     END-IF
     IF WS-KEEP = 1
         MOVE EN-PLAYER(EN-FOE(L-ROW)) TO WS-P
         COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
         IF WS-D2 < 6.25
             MOVE 0 TO EN-SWIM-SPEED(L-ROW)
         ELSE
             MOVE PL-X(WS-P) TO WS-X
             MOVE PL-Y(WS-P) TO WS-Y
             MOVE PL-Z(WS-P) TO WS-Z
             COMPUTE WS-SPEED = SM-WALK-MILLI(L-M) / 1000 * 4.0
             CALL "AQUA-CHASE" USING L-ROW WS-X WS-Y WS-Z WS-SPEED
         END-IF
         MOVE 23 TO WS-SALT
         CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
         COMPUTE WS-DRAW = FUNCTION INTEGER(WS-R * 6)
         IF WS-DRAW = 0
             CALL "DOLPHIN-GRACE" USING WS-P
         END-IF
         GOBACK
     END-IF
*>   No player to swim with: a jump with chance 1 / 5 a tick when the water ahead is clear, else the stroll.
     IF EN-COOLDOWN(L-ROW) = 0
         MOVE 24 TO WS-SALT
         CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
         COMPUTE WS-DRAW = FUNCTION INTEGER(WS-R * 5)
         IF WS-DRAW = 0
             CALL "DOLPHIN-JUMP-CLEAR" USING L-ROW WS-OK
             IF WS-OK = 1
                 CALL "DOLPHIN-JUMP-START" USING L-ROW
                 CALL "DOLPHIN-JUMP-PITCH" USING L-ROW
                 GOBACK
             END-IF
         END-IF
     END-IF
     CALL "AQUA-SWIM" USING L-ROW L-M
     GOBACK.
 END PROGRAM DOLPHIN-TICK.
