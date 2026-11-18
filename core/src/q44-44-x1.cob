*> Rule functions of docs/protocol/44-residual-mob-questions-x1-continuation.md (lane 002-lane-p49j-b, tasks T24300 to T24399). Each program is one deterministic rule of the document with its
*> random draws and world facts passed in. The mobs, blocks and goals the rules belong to either live under other files (the effect tick, patrol, goat) or have no engine yet (brain memories,
*> sensors), so these functions are proven by tests but are not called by a tick (see the lane task list).

*> x1 2.1 oldDeltaY(v) = v / 0.98 + 0.08.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-HONEY-OLD-DY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V                    FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-V L-OUT.
     COMPUTE L-OUT = L-V / 0.9800000190734863 + 0.08
     GOBACK.
 END PROGRAM X1-HONEY-OLD-DY.

*> x1 2.1 newDeltaY(v) = (v - 0.08) x 0.98.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-HONEY-NEW-DY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-V                    FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-V L-OUT.
     COMPUTE L-OUT = (L-V - 0.08) * 0.9800000190734863
     GOBACK.
 END PROGRAM X1-HONEY-NEW-DY.

*> x1 2.1 isSlidingDown: not on the ground, feet below the top, oldDeltaY < -0.08, and dx or dz (centre distances, absolute) + 1e-7 above 0.4375 + width / 2.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-HONEY-SLIDING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-O  FLOAT-LONG.
 01 WS-LIMIT  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-GROUND               BINARY-LONG.
 01 L-EY                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-WIDTH                FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUND L-EY L-PY L-VY L-DX L-DZ L-WIDTH L-OUT.
     MOVE 0 TO L-OUT
     COMPUTE WS-O = L-VY / 0.9800000190734863 + 0.08
     COMPUTE WS-LIMIT = 0.4375 + L-WIDTH / 2
     IF L-GROUND = 0 AND L-EY <= L-PY + 0.9375 - 0.0000001 AND WS-O < -0.08
             AND (L-DX + 0.0000001 > WS-LIMIT OR L-DZ + 0.0000001 > WS-LIMIT)
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-HONEY-SLIDING.

*> x1 2.1 doSlideMovement: below -0.13 the horizontal speed scales by -0.05 / o; vy becomes newDeltaY(-0.05).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-HONEY-SLIDE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-O  FLOAT-LONG.
 01 WS-K  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-VX L-VY L-VZ.
     COMPUTE WS-O = L-VY / 0.9800000190734863 + 0.08
     IF WS-O < -0.13
         COMPUTE WS-K = -0.05 / WS-O
         COMPUTE L-VX = L-VX * WS-K
         COMPUTE L-VZ = L-VZ * WS-K
     END-IF
     COMPUTE L-VY = (-0.05 - 0.08) * 0.9800000190734863
     GOBACK.
 END PROGRAM X1-HONEY-SLIDE.

*> x1 2.2 canEntityWalkOnPowderSnow: the type is in powder_snow_walkable_mobs, or a living entity wearing leather boots.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-POWDER-WALKABLE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TAGGED               BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 01 L-BOOTS                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TAGGED L-LIVING L-BOOTS L-OUT.
     MOVE 0 TO L-OUT
     IF L-TAGGED = 1 OR (L-LIVING = 1 AND L-BOOTS = 1)
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-POWDER-WALKABLE.

*> x1 2.2 collision shape: 1 the falling box (0,0,0)-(1,0.9,1) when fallDistance > 2.5, 2 the normal shape, 0 empty (the entity sinks).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-POWDER-COLLISION.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FALL                 FLOAT-LONG.
 01 L-FALLING-BLOCK        BINARY-LONG.
 01 L-WALKABLE             BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-DESCENDING           BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FALL L-FALLING-BLOCK L-WALKABLE L-ABOVE L-DESCENDING L-OUT.
     EVALUATE TRUE
         WHEN L-FALL > 2.5
             MOVE 1 TO L-OUT
         WHEN L-FALLING-BLOCK = 1
             MOVE 2 TO L-OUT
         WHEN L-WALKABLE = 1 AND L-ABOVE = 1 AND L-DESCENDING = 0
             MOVE 2 TO L-OUT
         WHEN OTHER
             MOVE 0 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM X1-POWDER-COLLISION.

*> x1 2.2 fallOn: nothing below 4 or for a non-living entity; the small fall sound (1) below 7, else the big one (2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-POWDER-LAND.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FALL                 FLOAT-LONG.
 01 L-LIVING               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FALL L-LIVING L-OUT.
     MOVE 0 TO L-OUT
     IF L-LIVING = 1 AND L-FALL >= 4.0
         MOVE 2 TO L-OUT
         IF L-FALL < 7.0
             MOVE 1 TO L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X1-POWDER-LAND.

*> x1 2.3 handleOnAboveBubbleColumn: drag column max(-0.9, vy - 0.03), push column min(1.8, vy + 0.1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-BUBBLE-ABOVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DOWN                 BINARY-LONG.
 01 L-VY                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DOWN L-VY.
     IF L-DOWN = 1
         COMPUTE L-VY = FUNCTION MAX(-0.9, L-VY - 0.03)
     ELSE
         COMPUTE L-VY = FUNCTION MIN(1.8, L-VY + 0.1)
     END-IF
     GOBACK.
 END PROGRAM X1-BUBBLE-ABOVE.

*> x1 2.3 handleOnInsideBubbleColumn: drag column max(-0.3, vy - 0.03), push column min(0.7, vy + 0.06).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-BUBBLE-INSIDE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DOWN                 BINARY-LONG.
 01 L-VY                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DOWN L-VY.
     IF L-DOWN = 1
         COMPUTE L-VY = FUNCTION MAX(-0.3, L-VY - 0.03)
     ELSE
         COMPUTE L-VY = FUNCTION MIN(0.7, L-VY + 0.06)
     END-IF
     GOBACK.
 END PROGRAM X1-BUBBLE-INSIDE.

*> x1 2.3 getColumnState: below 1 a column (result 1: the state below), 2 in enables_bubble_column_push_up (2: column up), 3 drag_down source (3: column down); else a column here gives 4 (plain water), else 5 (current unchanged).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-BUBBLE-STATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BELOW                BINARY-LONG.
 01 L-CURRENT-COLUMN       BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BELOW L-CURRENT-COLUMN L-OUT.
     EVALUATE TRUE
         WHEN L-BELOW = 1
             MOVE 1 TO L-OUT
         WHEN L-BELOW = 2
             MOVE 2 TO L-OUT
         WHEN L-BELOW = 3
             MOVE 3 TO L-OUT
         WHEN L-CURRENT-COLUMN = 1
             MOVE 4 TO L-OUT
         WHEN OTHER
             MOVE 5 TO L-OUT
     END-EVALUATE
     GOBACK.
 END PROGRAM X1-BUBBLE-STATE.

*> x1 2.3 canOccupy: already a bubble column, or a full water source in a liquid block (not waterlogged).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-BUBBLE-OCCUPY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COLUMN               BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 01 L-WATER-TAG            BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COLUMN L-LIQUID L-WATER-TAG L-SOURCE L-AMOUNT L-OUT.
     MOVE 0 TO L-OUT
     IF L-COLUMN = 1 OR (L-WATER-TAG = 1 AND L-LIQUID = 1 AND L-SOURCE = 1 AND L-AMOUNT >= 8)
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-BUBBLE-OCCUPY.

*> x1 2.3 entityInside: the above handler when the cell above has no collision and no fluid, else the inside handler.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-BUBBLE-AFFECT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DOWN                 BINARY-LONG.
 01 L-ABOVE-FREE           BINARY-LONG.
 01 L-VY                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-DOWN L-ABOVE-FREE L-VY.
     IF L-ABOVE-FREE = 1
         CALL "X1-BUBBLE-ABOVE" USING L-DOWN L-VY
     ELSE
         CALL "X1-BUBBLE-INSIDE" USING L-DOWN L-VY
     END-IF
     GOBACK.
 END PROGRAM X1-BUBBLE-AFFECT.

*> x1 2.4 campfire entityInside: a lit campfire hurts a living entity for 1.0 (soul campfire 2.0), in thousandths.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-CAMPFIRE-DAMAGE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SOUL                 BINARY-LONG.
 01 L-LIT                  BINARY-LONG.
 01 L-LIVING               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SOUL L-LIT L-LIVING L-OUT.
     MOVE 0 TO L-OUT
     IF L-LIT = 1 AND L-LIVING = 1
         MOVE 1000 TO L-OUT
         IF L-SOUL = 1
             MOVE 2000 TO L-OUT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X1-CAMPFIRE-DAMAGE.

*> x1 2.4 cobweb stuck multiplier (mx, my, mx): (0.25, 0.05, 0.25), (0.5, 0.25, 0.5) with Weaving.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-WEB-MULT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WEAVING              BINARY-LONG.
 01 L-MX                   FLOAT-LONG.
 01 L-MY                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-WEAVING L-MX L-MY.
     MOVE 0.25 TO L-MX
     MOVE 0.05000000074505806 TO L-MY
     IF L-WEAVING = 1
         MOVE 0.5 TO L-MX
         MOVE 0.25 TO L-MY
     END-IF
     GOBACK.
 END PROGRAM X1-WEB-MULT.

*> x1 3 Mob.finalizeSpawn: the follow_range random_spawn_bonus triangle(0, 0.11485) when absent (two nextDouble draws, first minus second), then left-handed when nextFloat < 0.05.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-FINALIZE-DEFAULTS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAS-BONUS            BINARY-LONG.
 01 L-D1                   FLOAT-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-FLOAT-DRAW           FLOAT-LONG.
 01 L-BONUS                FLOAT-LONG.
 01 L-LEFT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HAS-BONUS L-D1 L-D2 L-FLOAT-DRAW L-BONUS L-LEFT.
     MOVE 0 TO L-BONUS L-LEFT
     IF L-HAS-BONUS = 0
         COMPUTE L-BONUS = 0.11485000000000001 * (L-D1 - L-D2)
     END-IF
     IF L-FLOAT-DRAW < 0.05
         MOVE 1 TO L-LEFT
     END-IF
     GOBACK.
 END PROGRAM X1-FINALIZE-DEFAULTS.

*> x1 6.1 touchingTarget: squared distance to the move target point below 4.0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-PHANTOM-TOUCH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D2                   FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-OUT.
     MOVE 0 TO L-OUT
     IF L-D2 < 4.0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-PHANTOM-TOUCH.

*> x1 6.2 VexMoveControl: closer than the box size: WAIT (the velocity is halved by the caller); else the velocity grows by v / len x speed x 0.05 (dx, dy, dz out).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-VEX-MOVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LEN                  FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-WAIT                 BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-LEN L-SIZE L-SPEED L-VX L-VY L-VZ L-WAIT L-DX L-DY L-DZ.
     MOVE 0 TO L-DX L-DY L-DZ
     IF L-LEN < L-SIZE
         MOVE 1 TO L-WAIT
     ELSE
         MOVE 0 TO L-WAIT
         COMPUTE L-DX = L-VX / L-LEN * L-SPEED * 0.05
         COMPUTE L-DY = L-VY / L-LEN * L-SPEED * 0.05
         COMPUTE L-DZ = L-VZ / L-LEN * L-SPEED * 0.05
     END-IF
     GOBACK.
 END PROGRAM X1-VEX-MOVE.

*> x1 6.2 yaw = -atan2(dx, dz) x 57.295776 (a standard atan2: not bit-exact with Mth.atan2, Open question 6).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-VEX-YAW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-YAW                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-DX L-DZ L-YAW.
     EVALUATE TRUE
         WHEN L-DZ > 0
             COMPUTE WS-A = FUNCTION ATAN(L-DX / L-DZ)
         WHEN L-DZ < 0 AND L-DX >= 0
             COMPUTE WS-A = FUNCTION ATAN(L-DX / L-DZ) + FUNCTION PI
         WHEN L-DZ < 0
             COMPUTE WS-A = FUNCTION ATAN(L-DX / L-DZ) - FUNCTION PI
         WHEN L-DX > 0
             COMPUTE WS-A = FUNCTION PI / 2
         WHEN L-DX < 0
             COMPUTE WS-A = 0 - FUNCTION PI / 2
         WHEN OTHER
             MOVE 0 TO WS-A
     END-EVALUATE
     COMPUTE L-YAW = 0 - WS-A * 57.295776
     GOBACK.
 END PROGRAM X1-VEX-YAW.

*> x1 6.3 patrol aim point: tc = patrol block bottom centre, d = pos - tc rotated by 90 RADIANS (x' = x cos + z sin, z' = z cos - x sin), tc2 = tc + 0.4 x d', aim = pos + 10 x normalize(tc2 - pos) (x and z).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-PATROL-AIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX  FLOAT-LONG.
 01 WS-CZ  FLOAT-LONG.
 01 WS-DX  FLOAT-LONG.
 01 WS-DZ  FLOAT-LONG.
 01 WS-RX  FLOAT-LONG.
 01 WS-RZ  FLOAT-LONG.
 01 WS-EX  FLOAT-LONG.
 01 WS-EZ  FLOAT-LONG.
 01 WS-LEN  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PX                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TZ                   BINARY-LONG.
 01 L-AX                   FLOAT-LONG.
 01 L-AZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-PX L-PZ L-TX L-TZ L-AX L-AZ.
     COMPUTE WS-CX = L-TX + 0.5
     COMPUTE WS-CZ = L-TZ + 0.5
     COMPUTE WS-DX = L-PX - WS-CX
     COMPUTE WS-DZ = L-PZ - WS-CZ
     COMPUTE WS-RX = WS-DX * FUNCTION COS(90) + WS-DZ * FUNCTION SIN(90)
     COMPUTE WS-RZ = WS-DZ * FUNCTION COS(90) - WS-DX * FUNCTION SIN(90)
     COMPUTE WS-EX = WS-CX + 0.4 * WS-RX - L-PX
     COMPUTE WS-EZ = WS-CZ + 0.4 * WS-RZ - L-PZ
     COMPUTE WS-LEN = FUNCTION SQRT(WS-EX * WS-EX + WS-EZ * WS-EZ)
     COMPUTE L-AX = L-PX + 10 * WS-EX / WS-LEN
     COMPUTE L-AZ = L-PZ + 10 * WS-EZ / WS-LEN
     GOBACK.
 END PROGRAM X1-PATROL-AIM.

*> x1 8.8 stroll aim point: as the patrol aim without the rotation (tc2 = tc + 0.4 x d).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-STROLL-AIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX  FLOAT-LONG.
 01 WS-CZ  FLOAT-LONG.
 01 WS-EX  FLOAT-LONG.
 01 WS-EZ  FLOAT-LONG.
 01 WS-LEN  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-PX                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TZ                   BINARY-LONG.
 01 L-AX                   FLOAT-LONG.
 01 L-AZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-PX L-PZ L-TX L-TZ L-AX L-AZ.
     COMPUTE WS-CX = L-TX + 0.5
     COMPUTE WS-CZ = L-TZ + 0.5
     COMPUTE WS-EX = WS-CX + 0.4 * (L-PX - WS-CX) - L-PX
     COMPUTE WS-EZ = WS-CZ + 0.4 * (L-PZ - WS-CZ) - L-PZ
     COMPUTE WS-LEN = FUNCTION SQRT(WS-EX * WS-EX + WS-EZ * WS-EZ)
     COMPUTE L-AX = L-PX + 10 * WS-EX / WS-LEN
     COMPUTE L-AZ = L-PZ + 10 * WS-EZ / WS-LEN
     GOBACK.
 END PROGRAM X1-STROLL-AIM.

*> x1 6.3 removeWhenFarAway: not patrolling, or farther than 128 blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-PATROL-REMOVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PATROLLING           BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PATROLLING L-D2 L-OUT.
     MOVE 0 TO L-OUT
     IF L-PATROLLING = 0 OR L-D2 > 16384.0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-PATROL-REMOVE.

*> x1 6.3 finalizeSpawn: unless the reason is PATROL, EVENT or STRUCTURE (REASON 1), nextFloat < 0.06 and canBeLeader makes the leader.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-PATROL-LEADER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-REASON               BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-CAN-LEAD             BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-REASON L-DRAW L-CAN-LEAD L-OUT.
     MOVE 0 TO L-OUT
     IF L-REASON = 0 AND L-DRAW < 0.06 AND L-CAN-LEAD = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-PATROL-LEADER.

*> x1 6.3 canUse: gameTime >= cooldownUntil, patrolling, no attack target, no controlling passenger, has a patrol target.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-PATROL-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-TIME                 BINARY-LONG.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-PATROLLING           BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-PASSENGER            BINARY-LONG.
 01 L-HAS-TARGET           BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-TIME L-COOLDOWN L-PATROLLING L-TARGET L-PASSENGER L-HAS-TARGET L-OUT.
     MOVE 0 TO L-OUT
     IF L-TIME >= L-COOLDOWN AND L-PATROLLING = 1 AND L-TARGET = 0 AND L-PASSENGER = 0 AND L-HAS-TARGET = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-PATROL-CAN-USE.

*> x1 5.2 NearestHealableRaiderTargetGoal.canUse: cooldown 0, the coin flip true, an active raid and a target found.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-HEAL-CAN-USE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-COIN                 BINARY-LONG.
 01 L-RAID                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COOLDOWN L-COIN L-RAID L-FOUND L-OUT.
     MOVE 0 TO L-OUT
     IF L-COOLDOWN <= 0 AND L-COIN = 1 AND L-RAID = 1 AND L-FOUND = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-HEAL-CAN-USE.

*> x1 5.2 Witch.aiStep: the player-target goal may attack while the heal cooldown is 0 or less.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-WITCH-CAN-ATTACK.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COOLDOWN             BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COOLDOWN L-OUT.
     MOVE 0 TO L-OUT
     IF L-COOLDOWN <= 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-WITCH-CAN-ATTACK.

*> x1 5.1 AdultSensorAnyType match: in followable_friendly_mobs and not a baby.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-ADULT-MATCH.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN-TAG               BINARY-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-IN-TAG L-BABY L-OUT.
     MOVE 0 TO L-OUT
     IF L-IN-TAG = 1 AND L-BABY = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-ADULT-MATCH.

*> x1 8.1 TargetingConditions: the range rule only applies when range > 0 (the default is -1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-TC-RANGE-APPLIES.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-RANGE                FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-RANGE L-OUT.
     MOVE 0 TO L-OUT
     IF L-RANGE > 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-TC-RANGE-APPLIES.

*> x1 8.3 BackUpIfTooClose: attack target present, no walk target, the target visible and strictly closer than the distance.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-BACKUP-TEST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTACK               BINARY-LONG.
 01 L-WALK                 BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 01 L-DIST                 FLOAT-LONG.
 01 L-LIMIT                FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACK L-WALK L-VISIBLE L-DIST L-LIMIT L-OUT.
     MOVE 0 TO L-OUT
     IF L-ATTACK = 1 AND L-WALK = 0 AND L-VISIBLE = 1 AND L-DIST < L-LIMIT
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-BACKUP-TEST.

*> x1 8.3 Mth.rotateIfNecessary(a, b, m) = b - clamp(degreesDifference(a, b), -m, m); with m = 0 the head yaw.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-ROTATE-IF-NECESSARY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-YAW                  FLOAT-LONG.
 01 L-HEAD                 FLOAT-LONG.
 01 L-M                    FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-YAW L-HEAD L-M L-OUT.
     COMPUTE WS-D = FUNCTION MOD(L-HEAD - L-YAW + 540, 360) - 180
     COMPUTE L-OUT = L-HEAD - FUNCTION MAX(0 - L-M, FUNCTION MIN(L-M, WS-D))
     GOBACK.
 END PROGRAM X1-ROTATE-IF-NECESSARY.

*> x1 8.4 BecomePassiveIfMemoryPresent: attack target registered, PACIFIED absent, the memory present.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-PASSIVE-TEST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATTACK               BINARY-LONG.
 01 L-PACIFIED             BINARY-LONG.
 01 L-MEMORY               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ATTACK L-PACIFIED L-MEMORY L-OUT.
     MOVE 0 TO L-OUT
     IF L-ATTACK = 1 AND L-PACIFIED = 0 AND L-MEMORY = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-PASSIVE-TEST.

*> x1 8.5 BabyFollowAdult: a baby acts when the adult is closer than max + 1 and not closer than min; the completion radius is min - 1.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-BABY-FOLLOW.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                 BINARY-LONG.
 01 L-DIST                 FLOAT-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-ACT                  BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-BABY L-DIST L-MIN L-MAX L-ACT L-RADIUS.
     MOVE 0 TO L-ACT
     COMPUTE L-RADIUS = L-MIN - 1
     IF L-BABY = 1 AND L-DIST < L-MAX + 1 AND NOT L-DIST < L-MIN
         MOVE 1 TO L-ACT
     END-IF
     GOBACK.
 END PROGRAM X1-BABY-FOLLOW.

*> x1 8.6 SetEntityLookTargetSometimes Ticker: at 0 the counter becomes sample - 1 and the check fails; else it counts down and passes at 0.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-LOOK-TIMER.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNTER              BINARY-LONG.
 01 L-SAMPLE               BINARY-LONG.
 01 L-PASS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNTER L-SAMPLE L-PASS.
     MOVE 0 TO L-PASS
     IF L-COUNTER = 0
         COMPUTE L-COUNTER = L-SAMPLE - 1
     ELSE
         SUBTRACT 1 FROM L-COUNTER
         IF L-COUNTER = 0
             MOVE 1 TO L-PASS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X1-LOOK-TIMER.

*> x1 8.6 candidate: squared distance <= maxDistance squared.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-LOOK-CANDIDATE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-D2                   FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-D2 L-MAX L-OUT.
     MOVE 0 TO L-OUT
     IF L-D2 <= L-MAX * L-MAX
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-LOOK-CANDIDATE.

*> x1 8.7 FoxFloatGoal.canUse: fluid deeper than 0.25, or in lava.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-FOX-FLOAT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DEPTH                FLOAT-LONG.
 01 L-LAVA                 BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DEPTH L-LAVA L-OUT.
     MOVE 0 TO L-OUT
     IF L-DEPTH > 0.25 OR L-LAVA = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-FOX-FLOAT.

*> x1 8.7 FaceplantGoal.canContinueToUse: faceplanted and the countdown above 0 (start sets 40, tick subtracts 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-FACEPLANT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FACEPLANTED          BINARY-LONG.
 01 L-COUNTDOWN            BINARY-LONG.
 01 L-CONTINUE             BINARY-LONG.
 PROCEDURE DIVISION USING L-FACEPLANTED L-COUNTDOWN L-CONTINUE.
     MOVE 0 TO L-CONTINUE
     IF L-FACEPLANTED = 1 AND L-COUNTDOWN > 0
         MOVE 1 TO L-CONTINUE
     END-IF
     GOBACK.
 END PROGRAM X1-FACEPLANT.

*> x1 8.7 FoxStrollThroughVillageGoal.canUse: the base goal and not sleeping, sitting, defending, and no attack target.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-FOX-STROLL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BASE                 BINARY-LONG.
 01 L-SLEEPING             BINARY-LONG.
 01 L-SITTING              BINARY-LONG.
 01 L-DEFENDING            BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE L-SLEEPING L-SITTING L-DEFENDING L-TARGET L-OUT.
     MOVE 0 TO L-OUT
     IF L-BASE = 1 AND L-SLEEPING = 0 AND L-SITTING = 0 AND L-DEFENDING = 0 AND L-TARGET = 0
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-FOX-STROLL.

*> x1 8.8 canUse: no controlling passenger, not bright outside, nextInt(interval) == 0 (ROLL is the draw), close to a village, a position found.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-STROLL-CAN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PASSENGER            BINARY-LONG.
 01 L-BRIGHT               BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-PASSENGER L-BRIGHT L-ROLL L-CLOSE L-FOUND L-OUT.
     MOVE 0 TO L-OUT
     IF L-PASSENGER = 0 AND L-BRIGHT = 0 AND L-ROLL = 0 AND L-CLOSE = 1 AND L-FOUND = 1
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-STROLL-CAN.

*> x1 8.8 moveRandomly: offset (nextInt(16) - 8, 0, nextInt(16) - 8), x then z.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-STROLL-RANDOM.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R1                   BINARY-LONG.
 01 L-R2                   BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-R1 L-R2 L-DX L-DZ.
     COMPUTE L-DX = L-R1 - 8
     COMPUTE L-DZ = L-R2 - 8
     GOBACK.
 END PROGRAM X1-STROLL-RANDOM.

*> x1 8.9 CollisionContext.isAbove: entity bottom > pos.y + shape.maxY - 9.999999747378752E-6.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-ABOVE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BOTTOM               FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-MAXY                 FLOAT-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BOTTOM L-PY L-MAXY L-OUT.
     MOVE 0 TO L-OUT
     IF L-BOTTOM > L-PY + L-MAXY - 0.000009999999747378752
         MOVE 1 TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM X1-ABOVE.

*> x1 8.10 Goat.finalizeSpawn: screaming when nextDouble < 0.02; an adult with nextFloat < 0.1 loses one horn (nextBoolean true: left, false: right).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-GOAT-FINALIZE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREAM-DRAW          FLOAT-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-HORN-DRAW            FLOAT-LONG.
 01 L-BOOL                 BINARY-LONG.
 01 L-SCREAMING            BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-RIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREAM-DRAW L-BABY L-HORN-DRAW L-BOOL L-SCREAMING L-LEFT L-RIGHT.
     MOVE 0 TO L-SCREAMING
     MOVE 1 TO L-LEFT L-RIGHT
     IF L-SCREAM-DRAW < 0.02
         MOVE 1 TO L-SCREAMING
     END-IF
     IF L-BABY = 0 AND L-HORN-DRAW < 0.10000000149011612
         IF L-BOOL = 1
             MOVE 0 TO L-LEFT
         ELSE
             MOVE 0 TO L-RIGHT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM X1-GOAT-FINALIZE.

*> x1 8.10 getBreedOffspring: screaming when the chosen parent is, else nextDouble < 0.02 (horns are not inherited).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-GOAT-BREED.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PARENT-SCREAMING     BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-SCREAMING            BINARY-LONG.
 PROCEDURE DIVISION USING L-PARENT-SCREAMING L-DRAW L-SCREAMING.
     MOVE 0 TO L-SCREAMING
     IF L-PARENT-SCREAMING = 1 OR L-DRAW < 0.02
         MOVE 1 TO L-SCREAMING
     END-IF
     GOBACK.
 END PROGRAM X1-GOAT-BREED.

*> x1 8.10 dropHorn: false for a baby or with both horns gone; one horn left is the one removed; both: nextBoolean true picks left.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-GOAT-DROP.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BABY                 BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 01 L-RIGHT                BINARY-LONG.
 01 L-BOOL                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-BABY L-LEFT L-RIGHT L-BOOL L-OK.
     MOVE 0 TO L-OK
     IF L-BABY = 0 AND (L-LEFT = 1 OR L-RIGHT = 1)
         MOVE 1 TO L-OK
         EVALUATE TRUE
             WHEN L-LEFT = 1 AND L-RIGHT = 0
                 MOVE 0 TO L-LEFT
             WHEN L-LEFT = 0
                 MOVE 0 TO L-RIGHT
             WHEN L-BOOL = 1
                 MOVE 0 TO L-LEFT
             WHEN OTHER
                 MOVE 0 TO L-RIGHT
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM X1-GOAT-DROP.

*> x1 8.10 the horn item velocity (rand(-0.2, 0.2), rand(0.3, 0.7), rand(-0.2, 0.2)) from three draws of [0, 1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-GOAT-HORN-VEL.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R1                   FLOAT-LONG.
 01 L-R2                   FLOAT-LONG.
 01 L-R3                   FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-R1 L-R2 L-R3 L-VX L-VY L-VZ.
     COMPUTE L-VX = -0.2 + L-R1 * 0.4
     COMPUTE L-VY = 0.3 + L-R2 * 0.4
     COMPUTE L-VZ = -0.2 + L-R3 * 0.4
     GOBACK.
 END PROGRAM X1-GOAT-HORN-VEL.

*> x1 8.2 MobEffectInstance.update (a hidden chain of at most four below the active effect): CHAIN is the table, level 1 the active instance, levels 2 to 5 the hidden ones (the flags of a hidden level are not kept) (ACTIVE 1 when present); duration -1 is infinite.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. X1-EFFECT-UPDATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-L                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-SHORTER-OTHER       BINARY-LONG.
 01 WS-SHORTER-THIS        BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHAIN.
    05 L-LEVEL OCCURS 5 TIMES.
       10 L-AMP            BINARY-LONG.
       10 L-DUR            BINARY-LONG.
       10 L-ACTIVE         BINARY-LONG.
 01 L-AMBIENT              BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 01 L-ICON                 BINARY-LONG.
 01 L-OAMP                 BINARY-LONG.
 01 L-ODUR                 BINARY-LONG.
 01 L-OAMBIENT             BINARY-LONG.
 01 L-OVISIBLE             BINARY-LONG.
 01 L-OICON                BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-CHAIN L-AMBIENT L-VISIBLE L-ICON L-OAMP L-ODUR L-OAMBIENT L-OVISIBLE L-OICON L-CHANGED.
     MOVE 0 TO L-CHANGED
     MOVE 1 TO WS-L
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         MOVE 0 TO WS-SHORTER-OTHER WS-SHORTER-THIS
         IF L-ODUR NOT = -1 AND (L-ODUR < L-DUR(WS-L) OR L-DUR(WS-L) = -1)
             MOVE 1 TO WS-SHORTER-OTHER
         END-IF
         IF L-DUR(WS-L) NOT = -1 AND (L-DUR(WS-L) < L-ODUR OR L-ODUR = -1)
             MOVE 1 TO WS-SHORTER-THIS
         END-IF
         EVALUATE TRUE
             WHEN L-OAMP > L-AMP(WS-L)
                 IF WS-SHORTER-OTHER = 1
                     PERFORM VARYING WS-I FROM 5 BY -1 UNTIL WS-I <= WS-L
                         MOVE L-AMP(WS-I - 1) TO L-AMP(WS-I)
                         MOVE L-DUR(WS-I - 1) TO L-DUR(WS-I)
                         MOVE L-ACTIVE(WS-I - 1) TO L-ACTIVE(WS-I)
                     END-PERFORM
                     MOVE 1 TO L-ACTIVE(WS-L + 1)
                 END-IF
                 MOVE L-OAMP TO L-AMP(WS-L)
                 MOVE L-ODUR TO L-DUR(WS-L)
                 MOVE 1 TO WS-DONE
                 IF WS-L = 1
                     MOVE 1 TO L-CHANGED
                 END-IF
             WHEN WS-SHORTER-THIS = 1 AND L-OAMP = L-AMP(WS-L)
                 MOVE L-ODUR TO L-DUR(WS-L)
                 MOVE 1 TO WS-DONE
                 IF WS-L = 1
                     MOVE 1 TO L-CHANGED
                 END-IF
             WHEN WS-SHORTER-THIS = 1
                 IF L-ACTIVE(WS-L + 1) = 0
                     MOVE L-OAMP TO L-AMP(WS-L + 1)
                     MOVE L-ODUR TO L-DUR(WS-L + 1)
                     MOVE 1 TO L-ACTIVE(WS-L + 1)
                     MOVE 1 TO WS-DONE
                 ELSE
                     ADD 1 TO WS-L
                 END-IF
             WHEN OTHER
                 MOVE 1 TO WS-DONE
         END-EVALUATE
     END-PERFORM
     IF (L-OAMBIENT = 0 AND L-AMBIENT = 1) OR L-CHANGED = 1
         MOVE L-OAMBIENT TO L-AMBIENT
         MOVE 1 TO L-CHANGED
     END-IF
     IF L-VISIBLE NOT = L-OVISIBLE
         MOVE L-OVISIBLE TO L-VISIBLE
         MOVE 1 TO L-CHANGED
     END-IF
     IF L-ICON NOT = L-OICON
         MOVE L-OICON TO L-ICON
         MOVE 1 TO L-CHANGED
     END-IF
     GOBACK.
 END PROGRAM X1-EFFECT-UPDATE.

