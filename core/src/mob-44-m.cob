*> The frog's long jump (002-lane-mobsa4; docs/protocol/44-residual-mob-questions-4-land-animals.md sections 1.1, 10 and 19 example 1).
*> - M44-JUMP-VECTOR USING dim, px, py, pz (the mob), tx, ty, tz (the centre of the target block), gravity, max speed (FLOAT-LONG), angle (degrees, BINARY-LONG), collide (1 checks the arc),
*>   vx, vy, vz out (FLOAT-LONG), found out: calculateJumpVectorForAngle: aim half a block short, v squared = A g / (H sin 2 theta - 2 dy cos squared theta), none when negative or above the
*>   maximum speed; with collide the arc is sampled (n = 2 ceil(H / vh) points) and every step of 0.9 x 0.5 blocks must be free for a 0.5 x 0.5 box (stand-in for the LONG_JUMPING pose
*>   dimensions, not given: the frog's 0.5 x 0.5); the result is 0.95 x (vh cos phi, vy, vh sin phi).
*> - M44-FROG-LANDING USING dim, x, y, z, ok out: the frog landing test: the block below, the cell and the one above hold no fluid (water or lava); acceptable when the block below or the cell is
*>   a lily pad or big dripleaf (frog_prefer_jump_to), else when the block below is solid. The trapdoor path-type exceptions and the path malus of the default test are not modelled (gap).
*> - M44-FROG-JUMP USING row (called by FROG-TICK; EN-FROG-JS): LongJumpToPreferredBlock and LongJumpMidJump. Idle: the cooldown EN-FROG-CD counts down; at 0 the behaviour starts when the frog is on
*>   the ground, not in water or lava and not in love (else the cooldown becomes half a sample of U(100, 140)): 20 tries, the start block, a preferred roll (chance 0.5). Each tick of the preparation
*>   (time-out 200, ends when the frog leaves its start block, the tries run out or it is in water, with half a sample as the cooldown) takes a try and picks candidates from the box x +- 4, y +- 2,
*>   z +- 4 (not its own block) by weight ceil(distance squared), the preferred ones first when it wants one (a lily pad or big dripleaf below), up to 64 a tick (the doc loops until none is left across
*>   ticks and remembers the rejected ones: gap); a candidate is accepted when it is not in the frog's column, passes the landing test and has a jump vector for the angles 65, 70, 75, 80 in a random order
*>   (maximum speed jump_strength 0.41999998688697815 x 3.5714288, gravity 0.08). The walking path test that rejects a reachable candidate is not modelled (gap). 40 ticks after the choice the frog
*>   is launched with the vector as its motion (no ground friction while mid-jump, STDMOB-STEP); mid-jump (time-out 100) it lands when it is on the ground for at least 2 ticks: horizontal motion x 0.1,
*>   cooldown a full sample. The jump and landing sounds and the pose are not sent (gap).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-JUMP-CLEAR.
*> USING dim, x, y, z (FLOAT-LONG), clear out: no solid cell under a 0.5 x 0.5 box standing at the position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-CLEAR                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-CLEAR.
     MOVE 1 TO L-CLEAR
     COMPUTE WS-T = L-X - 0.25
     COMPUTE WS-X0 = FUNCTION INTEGER(WS-T)
     COMPUTE WS-T = L-X + 0.25
     COMPUTE WS-X1 = FUNCTION INTEGER(WS-T)
     COMPUTE WS-T = L-Z - 0.25
     COMPUTE WS-Z0 = FUNCTION INTEGER(WS-T)
     COMPUTE WS-T = L-Z + 0.25
     COMPUTE WS-Z1 = FUNCTION INTEGER(WS-T)
     COMPUTE WS-Y0 = FUNCTION INTEGER(L-Y + 0.0001)
     COMPUTE WS-T = L-Y + 0.4999
     COMPUTE WS-Y1 = FUNCTION INTEGER(WS-T)
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
         PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
             PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z1
                 CALL "GI-SOLID-CELL" USING L-DIM WS-X WS-Y WS-Z WS-SOLID
                 IF WS-SOLID = 1
                     MOVE 0 TO L-CLEAR
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM M44-JUMP-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-JUMP-VECTOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-THETA               FLOAT-LONG.
 01 WS-PHI                 FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-DEN                 FLOAT-LONG.
 01 WS-V2                  FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-VH                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-COS2                FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-QX                  FLOAT-LONG.
 01 WS-QY                  FLOAT-LONG.
 01 WS-QZ                  FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-SEG                 FLOAT-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-CLEAR               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PI                  FLOAT-LONG.
 01 WS-COSPHI              FLOAT-LONG.
 01 WS-SINPHI              FLOAT-LONG.
 01 WS-Y-ONE               FLOAT-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 01 L-TX                   FLOAT-LONG.
 01 L-TY                   FLOAT-LONG.
 01 L-TZ                   FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 01 L-ANGLE                BINARY-LONG.
 01 L-COLLIDE              BINARY-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-PX L-PY L-PZ L-TX L-TY L-TZ L-G L-MAX L-ANGLE L-COLLIDE L-VX L-VY L-VZ L-FOUND.
     MOVE 0 TO L-FOUND L-VX L-VY L-VZ
     COMPUTE WS-DX = L-TX - L-PX
     COMPUTE WS-DZ = L-TZ - L-PZ
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     IF WS-LEN = 0
         GOBACK
     END-IF
     COMPUTE WS-RX = L-TX - WS-DX / WS-LEN * 0.5 - L-PX
     COMPUTE WS-RY = L-TY - L-PY
     COMPUTE WS-RZ = L-TZ - WS-DZ / WS-LEN * 0.5 - L-PZ
     COMPUTE WS-THETA = L-ANGLE * FUNCTION PI / 180
     CALL "ATAN2-DEGREES" USING WS-RZ WS-RX WS-PHI
     COMPUTE WS-PHI = WS-PHI * FUNCTION PI / 180
     COMPUTE WS-A = WS-RX * WS-RX + WS-RZ * WS-RZ
     COMPUTE WS-H = FUNCTION SQRT(WS-A)
     COMPUTE WS-COS2 = FUNCTION COS(WS-THETA) ** 2
     COMPUTE WS-DEN = WS-H * FUNCTION SIN(2 * WS-THETA) - 2 * WS-RY * WS-COS2
     IF WS-DEN <= 0
         GOBACK
     END-IF
     COMPUTE WS-V2 = WS-A * L-G / WS-DEN
     COMPUTE WS-V = FUNCTION SQRT(WS-V2)
     IF WS-V > L-MAX
         GOBACK
     END-IF
     COMPUTE WS-VH = WS-V * FUNCTION COS(WS-THETA)
     COMPUTE WS-VY = WS-V * FUNCTION SIN(WS-THETA)
     COMPUTE WS-COSPHI = FUNCTION COS(WS-PHI)
     COMPUTE WS-SINPHI = FUNCTION SIN(WS-PHI)
     MOVE 1 TO WS-OK
     IF L-COLLIDE = 1
         COMPUTE WS-N = 2 * FUNCTION INTEGER-PART(WS-H / WS-VH + 0.999999)
         MOVE L-PX TO WS-FX
         MOVE L-PY TO WS-FY
         MOVE L-PZ TO WS-FZ
         MOVE 0 TO WS-T
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-N - 2 OR WS-OK = 0
             COMPUTE WS-T = WS-T + WS-H / WS-N
             COMPUTE WS-Y = FUNCTION TAN(WS-THETA) * WS-T - WS-T * WS-T * L-G / (2 * WS-V2 * WS-COS2)
             COMPUTE WS-QX = L-PX + WS-T * WS-COSPHI
             COMPUTE WS-QY = L-PY + WS-Y
             COMPUTE WS-QZ = L-PZ + WS-T * WS-SINPHI
             PERFORM CHECK-TRANSITION
             MOVE WS-QX TO WS-FX
             MOVE WS-QY TO WS-FY
             MOVE WS-QZ TO WS-FZ
         END-PERFORM
     END-IF
     IF WS-OK = 1
         MOVE 1 TO L-FOUND
         COMPUTE L-VX = 0.95 * WS-VH * WS-COSPHI
         COMPUTE L-VY = 0.95 * WS-VY
         COMPUTE L-VZ = 0.95 * WS-VH * WS-SINPHI
     END-IF
     GOBACK.

 CHECK-TRANSITION.
     COMPUTE WS-SEG = FUNCTION SQRT((WS-QX - WS-FX) ** 2 + (WS-QY - WS-FY) ** 2 + (WS-QZ - WS-FZ) ** 2)
     COMPUTE WS-STEPS = FUNCTION INTEGER-PART(WS-SEG / 0.5 + 0.999999)
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-STEPS OR WS-OK = 0
         COMPUTE WS-S = 0.45 * WS-K
         IF WS-K = WS-STEPS OR WS-S > WS-SEG
             MOVE WS-SEG TO WS-S
         END-IF
         COMPUTE WS-DX = WS-FX + (WS-QX - WS-FX) * WS-S / WS-SEG
         COMPUTE WS-DEN = WS-FY + (WS-QY - WS-FY) * WS-S / WS-SEG
         COMPUTE WS-DZ = WS-FZ + (WS-QZ - WS-FZ) * WS-S / WS-SEG
         CALL "M44-JUMP-CLEAR" USING L-DIM WS-DX WS-DEN WS-DZ WS-CLEAR
         IF WS-CLEAR = 0
             MOVE 0 TO WS-OK
         END-IF
     END-PERFORM.
 END PROGRAM M44-JUMP-VECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FROG-LANDING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY-B               PIC X(48).
 01 WS-KEY-S               PIC X(48).
 01 WS-KEY-A               PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-Y-B                 BINARY-LONG.
 01 WS-Y-A                 BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     COMPUTE WS-Y-B = L-Y - 1
     COMPUTE WS-Y-A = L-Y + 1
     CALL "IP-BLOCK-KEY" USING L-DIM L-X WS-Y-B L-Z WS-KEY-B WS-LENGTH
     CALL "IP-BLOCK-KEY" USING L-DIM L-X L-Y L-Z WS-KEY-S WS-LENGTH
     CALL "IP-BLOCK-KEY" USING L-DIM L-X WS-Y-A L-Z WS-KEY-A WS-LENGTH
     IF NOT (WS-KEY-B = "minecraft:water" OR WS-KEY-B = "minecraft:lava" OR WS-KEY-S = "minecraft:water" OR WS-KEY-S = "minecraft:lava"
             OR WS-KEY-A = "minecraft:water" OR WS-KEY-A = "minecraft:lava")
         IF WS-KEY-B = "minecraft:lily_pad" OR WS-KEY-B = "minecraft:big_dripleaf" OR WS-KEY-S = "minecraft:lily_pad"
                 OR WS-KEY-S = "minecraft:big_dripleaf"
             MOVE 1 TO L-OK
         ELSE
             CALL "GI-SOLID-CELL" USING L-DIM L-X WS-Y-B L-Z WS-SOLID
             MOVE WS-SOLID TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-FROG-LANDING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-FROG-JUMP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT-C              BINARY-LONG VALUE 130.
 01 WS-BOUND-C             BINARY-LONG VALUE 41.
 01 WS-SALT-P              BINARY-LONG VALUE 131.
 01 WS-BOUND-P             BINARY-LONG VALUE 2.
 01 WS-SALT-W              BINARY-LONG VALUE 132.
 01 WS-SALT-S              BINARY-LONG VALUE 133.
 01 WS-DRAW                BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-CANDS.
    05 WS-CAND OCCURS 405 TIMES.
       10 WS-C-X           BINARY-LONG.
       10 WS-C-Y           BINARY-LONG.
       10 WS-C-Z           BINARY-LONG.
       10 WS-C-W           BINARY-LONG.
       10 WS-C-PREF        BINARY-LONG.
       10 WS-C-USED        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-Y-B                 BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-PREF-TOTAL          BINARY-LONG.
 01 WS-ATTEMPTS            BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-ACC                 BINARY-LONG.
 01 WS-LAND                BINARY-LONG.
 01 WS-ANGLES.
    05 WS-ANGLE            BINARY-LONG OCCURS 4 TIMES.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-TMP                 BINARY-LONG.
 01 WS-BOUND-S             BINARY-LONG.
 01 WS-G                   FLOAT-LONG VALUE 0.08.
 01 WS-MAX                 FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     EVALUATE TRUE
         WHEN EN-FROG-JS(L-ROW) = 3
             PERFORM MID-JUMP
         WHEN EN-FROG-JS(L-ROW) = 1
             PERFORM PREPARE
         WHEN EN-FROG-CD(L-ROW) > 0
             SUBTRACT 1 FROM EN-FROG-CD(L-ROW)
         WHEN OTHER
             PERFORM START-CHECK
     END-EVALUATE
     GOBACK.

 SAMPLE-COOLDOWN.
     CALL "XP-RANDOM" USING WS-SALT-C WS-BOUND-C WS-DRAW
     COMPUTE WS-DRAW = 100 + WS-DRAW.

 FEET-WET.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "IP-BLOCK-KEY" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-KEY WS-LENGTH
     MOVE 0 TO WS-WET
     IF WS-KEY = "minecraft:water" OR WS-KEY = "minecraft:lava" OR WS-KEY = "minecraft:honey_block"
         MOVE 1 TO WS-WET
     END-IF.

 START-CHECK.
     IF EN-LOVE(L-ROW) > 0
         EXIT PARAGRAPH
     END-IF
     PERFORM FEET-WET
     IF EN-ON-GROUND(L-ROW) = 1 AND WS-WET = 0
         MOVE 1 TO EN-FROG-JS(L-ROW)
         MOVE 0 TO EN-FROG-CH(L-ROW) EN-FROG-JT(L-ROW) EN-FROG-LIFE(L-ROW)
         MOVE 20 TO EN-FROG-TRIES(L-ROW)
         MOVE WS-BX TO EN-FROG-SX(L-ROW)
         MOVE WS-BY TO EN-FROG-SY(L-ROW)
         MOVE WS-BZ TO EN-FROG-SZ(L-ROW)
         CALL "XP-RANDOM" USING WS-SALT-P WS-BOUND-P WS-DRAW
         MOVE WS-DRAW TO EN-FROG-PREF(L-ROW)
     ELSE
         PERFORM SAMPLE-COOLDOWN
         COMPUTE EN-FROG-CD(L-ROW) = WS-DRAW / 2
     END-IF.

 END-PREPARATION.
     PERFORM SAMPLE-COOLDOWN
     COMPUTE EN-FROG-CD(L-ROW) = WS-DRAW / 2
     MOVE 0 TO EN-FROG-JS(L-ROW) EN-FROG-CH(L-ROW).

 PREPARE.
     ADD 1 TO EN-FROG-LIFE(L-ROW)
     PERFORM FEET-WET
     IF EN-FROG-LIFE(L-ROW) > 200 OR WS-WET = 1 OR WS-BX NOT = EN-FROG-SX(L-ROW) OR WS-BY NOT = EN-FROG-SY(L-ROW)
             OR WS-BZ NOT = EN-FROG-SZ(L-ROW) OR EN-FROG-TRIES(L-ROW) <= 0
         PERFORM END-PREPARATION
         EXIT PARAGRAPH
     END-IF
     IF EN-FROG-CH(L-ROW) = 0
         SUBTRACT 1 FROM EN-FROG-TRIES(L-ROW)
         PERFORM PICK-CANDIDATE
         EXIT PARAGRAPH
     END-IF
     ADD 1 TO EN-FROG-JT(L-ROW)
     IF EN-FROG-JT(L-ROW) >= 40
         MOVE EN-FROG-JVX(L-ROW) TO EN-VX(L-ROW)
         MOVE EN-FROG-JVY(L-ROW) TO EN-VY(L-ROW)
         MOVE EN-FROG-JVZ(L-ROW) TO EN-VZ(L-ROW)
         MOVE 0 TO EN-ON-GROUND(L-ROW)
         MOVE 3 TO EN-FROG-JS(L-ROW)
         MOVE 0 TO EN-FROG-MIDT(L-ROW)
     END-IF.

 MID-JUMP.
     ADD 1 TO EN-FROG-MIDT(L-ROW)
     IF (EN-ON-GROUND(L-ROW) = 1 AND EN-FROG-MIDT(L-ROW) >= 2) OR EN-FROG-MIDT(L-ROW) >= 100
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.1
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.1
         PERFORM SAMPLE-COOLDOWN
         MOVE WS-DRAW TO EN-FROG-CD(L-ROW)
         MOVE 0 TO EN-FROG-JS(L-ROW) EN-FROG-CH(L-ROW)
     END-IF.

 PICK-CANDIDATE.
*>   The box of candidates with the weight ceil(distance squared to the frog's block) and the preferred flag (a lily pad or big dripleaf below).
     MOVE 0 TO WS-COUNT WS-TOTAL WS-PREF-TOTAL
     PERFORM VARYING WS-DX FROM -4 BY 1 UNTIL WS-DX > 4
         PERFORM VARYING WS-DY FROM -2 BY 1 UNTIL WS-DY > 2
             PERFORM VARYING WS-DZ FROM -4 BY 1 UNTIL WS-DZ > 4
                 IF WS-DX NOT = 0 OR WS-DY NOT = 0 OR WS-DZ NOT = 0
                     ADD 1 TO WS-COUNT
                     COMPUTE WS-C-X(WS-COUNT) = EN-FROG-SX(L-ROW) + WS-DX
                     COMPUTE WS-C-Y(WS-COUNT) = EN-FROG-SY(L-ROW) + WS-DY
                     COMPUTE WS-C-Z(WS-COUNT) = EN-FROG-SZ(L-ROW) + WS-DZ
                     COMPUTE WS-C-W(WS-COUNT) = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                     MOVE 0 TO WS-C-USED(WS-COUNT) WS-C-PREF(WS-COUNT)
                     ADD WS-C-W(WS-COUNT) TO WS-TOTAL
                     IF EN-FROG-PREF(L-ROW) = 1
                         COMPUTE WS-Y-B = WS-C-Y(WS-COUNT) - 1
                         CALL "IP-BLOCK-KEY" USING EN-DIM(L-ROW) WS-C-X(WS-COUNT) WS-Y-B WS-C-Z(WS-COUNT) WS-KEY WS-LENGTH
                         IF WS-KEY = "minecraft:lily_pad" OR WS-KEY = "minecraft:big_dripleaf"
                             MOVE 1 TO WS-C-PREF(WS-COUNT)
                             ADD WS-C-W(WS-COUNT) TO WS-PREF-TOTAL
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-ATTEMPTS
     PERFORM UNTIL WS-ATTEMPTS >= 64 OR WS-TOTAL <= 0 OR EN-FROG-CH(L-ROW) = 1
         ADD 1 TO WS-ATTEMPTS
         PERFORM DRAW-ONE
         PERFORM TRY-CANDIDATE
     END-PERFORM.

 DRAW-ONE.
*>   A weighted draw without replacement; the preferred candidates first while there are some.
     IF WS-PREF-TOTAL > 0
         CALL "XP-RANDOM" USING WS-SALT-W WS-PREF-TOTAL WS-DRAW
     ELSE
         CALL "XP-RANDOM" USING WS-SALT-W WS-TOTAL WS-DRAW
     END-IF
     MOVE 0 TO WS-PICK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR WS-PICK > 0
         IF WS-C-USED(WS-I) = 0 AND (WS-PREF-TOTAL = 0 OR WS-C-PREF(WS-I) = 1)
             IF WS-DRAW < WS-C-W(WS-I)
                 MOVE WS-I TO WS-PICK
             ELSE
                 SUBTRACT WS-C-W(WS-I) FROM WS-DRAW
             END-IF
         END-IF
     END-PERFORM
     MOVE 1 TO WS-C-USED(WS-PICK)
     SUBTRACT WS-C-W(WS-PICK) FROM WS-TOTAL
     IF WS-C-PREF(WS-PICK) = 1
         SUBTRACT WS-C-W(WS-PICK) FROM WS-PREF-TOTAL
     END-IF.

 TRY-CANDIDATE.
     IF WS-C-X(WS-PICK) = EN-FROG-SX(L-ROW) AND WS-C-Z(WS-PICK) = EN-FROG-SZ(L-ROW)
         EXIT PARAGRAPH
     END-IF
     CALL "M44-FROG-LANDING" USING EN-DIM(L-ROW) WS-C-X(WS-PICK) WS-C-Y(WS-PICK) WS-C-Z(WS-PICK) WS-LAND
     IF WS-LAND = 0
         EXIT PARAGRAPH
     END-IF
     MOVE EN-X(L-ROW) TO WS-PX
     MOVE EN-Y(L-ROW) TO WS-PY
     MOVE EN-Z(L-ROW) TO WS-PZ
     COMPUTE WS-TX = WS-C-X(WS-PICK) + 0.5
     COMPUTE WS-TY = WS-C-Y(WS-PICK) + 0.5
     COMPUTE WS-TZ = WS-C-Z(WS-PICK) + 0.5
*>   0.41999998688697815 x 3.5714288 (a literal that long does not survive a COMPUTE in a float field).
     COMPUTE WS-MAX = 1.50000005
     MOVE 65 TO WS-ANGLE(1)
     MOVE 70 TO WS-ANGLE(2)
     MOVE 75 TO WS-ANGLE(3)
     MOVE 80 TO WS-ANGLE(4)
     PERFORM VARYING WS-J FROM 4 BY -1 UNTIL WS-J < 2
         MOVE WS-J TO WS-BOUND-S
         CALL "XP-RANDOM" USING WS-SALT-S WS-BOUND-S WS-K
         ADD 1 TO WS-K
         MOVE WS-ANGLE(WS-J) TO WS-TMP
         MOVE WS-ANGLE(WS-K) TO WS-ANGLE(WS-J)
         MOVE WS-TMP TO WS-ANGLE(WS-K)
     END-PERFORM
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4 OR WS-FOUND = 1
         CALL "M44-JUMP-VECTOR" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-TX WS-TY WS-TZ WS-G WS-MAX WS-ANGLE(WS-J) WS-ONE
             WS-VX WS-VY WS-VZ WS-FOUND
     END-PERFORM
     IF WS-FOUND = 1
         MOVE 1 TO EN-FROG-CH(L-ROW)
         MOVE 0 TO EN-FROG-JT(L-ROW)
         MOVE WS-C-X(WS-PICK) TO EN-FROG-TX(L-ROW)
         MOVE WS-C-Y(WS-PICK) TO EN-FROG-TY(L-ROW)
         MOVE WS-C-Z(WS-PICK) TO EN-FROG-TZ(L-ROW)
         MOVE WS-VX TO EN-FROG-JVX(L-ROW)
         MOVE WS-VY TO EN-FROG-JVY(L-ROW)
         MOVE WS-VZ TO EN-FROG-JVZ(L-ROW)
     END-IF.
 END PROGRAM M44-FROG-JUMP.
