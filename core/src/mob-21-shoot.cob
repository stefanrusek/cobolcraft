*> Projectile-shooting Nether mobs and the snow golem (002-lane-mobsfull-h19; docs/protocol/21 sections 5.1 and 5.2, 44 part 6 sections 9.1 and 9.2, 19 section 20). The rows
*> are core/copy/MOB21ROWS3.cpy (SM-RANGED 4 ghast, 5 blaze); the projectiles are core/src/mob-21-proj.cob.
*> Ghast: GHAST-TICK takes the nearest player of the follow range 100 whose height differs by at most 4 (the selector's |dy| <= 4, applied here to every tick and not only to the
*> choice), looks at it within 64 blocks (else along its velocity), GHAST-SHOOT charges and fires, GHAST-MOVE flies. EN-SHOOT-TIME is chargeTime, EN-VARIANT the charging flag
*> (metadata 16), EN-PH-TX to EN-PH-TZ and EN-PH-SET the wanted point of the move control, EN-PH-SCAN its floatDuration.
*> Blaze: BLAZE-ATTACK is BlazeAttackGoal (EN-SHOOT-TIME attackTime, EN-DRAW attackStep, EN-SWELL lastSeen, EN-VARIANT the charged flag, metadata 16 bit 0); BLAZE-HEIGHT the
*> height keeping (EN-WAKE the ticks to the next offset, EN-PH-HEIGHT allowedHeightOffset) and the glide of aiStep. The blaze walks to its target like any monster (STDMOB-STEP).
*> Snow golem: SNOW-GOLEM-TICK throws a snowball at the nearest monster within 10 blocks that it sees (EN-PET-CD the attack timer, 0 = not started).
*> Approximations (open): the ghast moves by its velocity against three sample heights (GHAST-SOLID), not the box; the 64 attempts of getSuitableFlyToPosition (the first point always
*> passes for distance 0) are left out; the move control is 44 part 6 section 9.1 (gain normalize(delta) x 0.1, floatDuration, the box sweep GHAST-CAN-REACH, the clamp GHAST-CLAMP;
*> lane p49s T38500); the blaze's eye is 1.53 (0.85 of its height),
*> its water avoidance, path maluses and fortress spawns are open; the snow golem's dy reads "target eye - 1.1 - snowball y" once (19 section 20 subtracts a y twice); the
*> snowball's shoot uncertainty is 0.
*>
*> Entry points:
*>   GHAST-SHOOT USING tracker row, table row                the shoot goal
*>   GHAST-MOVE USING tracker row                            the move control and one tick of flight
*>   GHAST-TICK USING tracker row, table row                 the whole tick of a ghast (STDMOB-STEP)
*>   BLAZE-ATTACK USING tracker row, table row               BlazeAttackGoal
*>   BLAZE-HEIGHT USING tracker row                          height keeping and glide
*>   SNOW-GOLEM-TICK USING tracker row, table row            the snow golem's ranged attack
*>   SHULKER-ATTACK USING tracker row, table row             the shulker's attack goal (bullets: BULLET-SELECT of core/src/mob-21-proj.cob)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GHAST-SHOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-POWER               BINARY-LONG VALUE 1.
 01 WS-DIM                 BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-FIREBALL            BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
*> USING tracker row, table row of a ghast: GhastShootFireballGoal (21 section 5.1). With a target within 64 blocks (distance squared below 4096) and a line of sight
*> chargeTime grows by 1 a tick and at 20 a large fireball of power 1 leaves from 4 blocks ahead (the view along the yaw) at half height + 0.5, aimed at the target's half height;
*> chargeTime becomes -40. Otherwise a positive chargeTime falls by 1. The charging flag is chargeTime > 10 and goes to the viewers when it changes.
 PROCEDURE DIVISION USING L-ROW L-M.
     MOVE EN-TARGET(L-ROW) TO WS-P
     MOVE 0 TO WS-VALID
     IF WS-P > 0
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
         COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
         IF WS-D2 < 4096
             MOVE EN-X(L-ROW) TO WS-EX
             COMPUTE WS-EY = EN-Y(L-ROW) + 2.6
             MOVE EN-Z(L-ROW) TO WS-EZ
             COMPUTE WS-TY = PL-Y(WS-P) + 1.62
             CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-EX WS-EY WS-EZ PL-X(WS-P) WS-TY PL-Z(WS-P) WS-SEES
             MOVE WS-SEES TO WS-VALID
         END-IF
     END-IF
     IF WS-VALID = 1
         ADD 1 TO EN-SHOOT-TIME(L-ROW)
         IF EN-SHOOT-TIME(L-ROW) = 20
             COMPUTE WS-RADIANS = EN-YAW(L-ROW) * FUNCTION PI / 180
             COMPUTE WS-VX = 0 - FUNCTION SIN(WS-RADIANS)
             COMPUTE WS-VZ = FUNCTION COS(WS-RADIANS)
             COMPUTE WS-SX = EN-X(L-ROW) + WS-VX * 4
             COMPUTE WS-SY = EN-Y(L-ROW) + 2.5
             COMPUTE WS-SZ = EN-Z(L-ROW) + WS-VZ * 4
             COMPUTE WS-DX = PL-X(WS-P) - WS-SX
             COMPUTE WS-DY = PL-Y(WS-P) + 0.9 - WS-SY
             COMPUTE WS-DZ = PL-Z(WS-P) - WS-SZ
             MOVE EN-DIM(L-ROW) TO WS-DIM
             MOVE EN-ID(L-ROW) TO WS-OWNER
             CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-SX WS-SY WS-SZ WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-FIREBALL
             MOVE -40 TO EN-SHOOT-TIME(L-ROW)
         END-IF
     ELSE
         IF EN-SHOOT-TIME(L-ROW) > 0
             SUBTRACT 1 FROM EN-SHOOT-TIME(L-ROW)
         END-IF
     END-IF
     MOVE 0 TO WS-FLAG
     IF EN-SHOOT-TIME(L-ROW) > 10
         MOVE 1 TO WS-FLAG
     END-IF
     IF WS-FLAG NOT = EN-VARIANT(L-ROW)
         MOVE WS-FLAG TO EN-VARIANT(L-ROW)
         CALL "STDMOB-VARIANT-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM GHAST-SHOOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GHAST-SOLID.
*> USING tracker row, x, y, z (FLOAT-LONG: a position of the mob's feet), solid out: 1 when the cell at the feet + 0.5, + 2 or + 3.5 (three heights of the 4 block box) is solid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-H                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-OFFSET              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SOLID                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-SOLID.
     MOVE 0 TO L-SOLID
     COMPUTE WS-CX = FUNCTION INTEGER(L-X)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z)
     PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 3
         COMPUTE WS-OFFSET = 0.5 + (WS-H - 1) * 1.5
         COMPUTE WS-CY = FUNCTION INTEGER(L-Y + WS-OFFSET)
         CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-S
         IF WS-S = 1
             MOVE 1 TO L-SOLID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GHAST-SOLID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GHAST-SEG-HITS.
*> USING centre (3 FLOAT-LONG), delta (3), box min (3), box max (3), hit out (BINARY-LONG): 1 when the segment from the centre to centre + delta passes through the inside of the
*> box (the slab method; a segment that only touches a face, or a zero movement, hits nothing). GHAST-CAN-REACH calls it with the cell inflated by the ghast's half extents,
*> which is the moving 4 x 4 x 4 box against the cell (44-6 section 9.1 collidedWithShapeMovingFrom; the arithmetic of the vanilla call is Open question 8, this is the exact sweep).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-T1                  FLOAT-LONG.
 01 WS-T2                  FLOAT-LONG.
 01 WS-TMP                 FLOAT-LONG.
 01 WS-EPS                 FLOAT-LONG VALUE 0.0000001.
 LINKAGE SECTION.
 01 L-C.
    05 L-CV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-D.
    05 L-DV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-MIN.
    05 L-MINV              FLOAT-LONG OCCURS 3 TIMES.
 01 L-MAX.
    05 L-MAXV              FLOAT-LONG OCCURS 3 TIMES.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-D L-MIN L-MAX L-HIT.
     MOVE 0 TO L-HIT
     MOVE 0 TO WS-LO
     MOVE 1 TO WS-HI
     PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
         IF FUNCTION ABS(L-DV(WS-A)) < WS-EPS
*>           parallel to the slab: the centre must be strictly inside it
             IF L-CV(WS-A) < L-MINV(WS-A) + WS-EPS OR L-CV(WS-A) > L-MAXV(WS-A) - WS-EPS
                 MOVE 2 TO WS-HI
             END-IF
         ELSE
             COMPUTE WS-T1 = (L-MINV(WS-A) - L-CV(WS-A)) / L-DV(WS-A)
             COMPUTE WS-T2 = (L-MAXV(WS-A) - L-CV(WS-A)) / L-DV(WS-A)
             IF WS-T1 > WS-T2
                 MOVE WS-T1 TO WS-TMP
                 MOVE WS-T2 TO WS-T1
                 MOVE WS-TMP TO WS-T2
             END-IF
             IF WS-T1 > WS-LO
                 MOVE WS-T1 TO WS-LO
             END-IF
             IF WS-T2 < WS-HI
                 MOVE WS-T2 TO WS-HI
             END-IF
         END-IF
     END-PERFORM
     IF WS-HI <= 1 AND WS-HI - WS-LO > WS-EPS
         MOVE 1 TO L-HIT
     END-IF
     GOBACK.
 END PROGRAM GHAST-SEG-HITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GHAST-CAN-REACH.
*> USING tracker row, dx, dy, dz (FLOAT-LONG: the way to the wanted point), ok out (BINARY-LONG): canReach of GhastMoveControl with careful false (44-6 section 9.1). The box is 4 x 4 x 4
*> (feet at the position, half side 2). Every cell the box meets on its way (the box taken every 2 blocks along the way, cells within it) is passable when it is not solid (air, fluids,
*> plants) or when the current box already intersects it; a solid cell is passable only when the moving box does not pass through it (GHAST-SEG-HITS with the cell inflated by 2).
*> A cell is a whole cube here: the collision shape table is not consulted (partial shapes count as solid when GI-SOLID-CELL says so).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-EPS                 FLOAT-LONG VALUE 0.0000001.
 01 WS-CEN.
    05 WS-CEN-V            FLOAT-LONG OCCURS 3 TIMES.
 01 WS-DEL.
    05 WS-DEL-V            FLOAT-LONG OCCURS 3 TIMES.
 01 WS-MIN.
    05 WS-MIN-V            FLOAT-LONG OCCURS 3 TIMES.
 01 WS-MAX.
    05 WS-MAX-V            FLOAT-LONG OCCURS 3 TIMES.
 01 WS-FEET.
    05 WS-FEET-V           FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DX L-DY L-DZ L-OK.
     MOVE 1 TO L-OK
     COMPUTE WS-LEN = FUNCTION SQRT(L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ)
     MOVE EN-X(L-ROW) TO WS-FEET-V(1)
     MOVE EN-Y(L-ROW) TO WS-FEET-V(2)
     MOVE EN-Z(L-ROW) TO WS-FEET-V(3)
     MOVE WS-FEET-V(1) TO WS-CEN-V(1)
     COMPUTE WS-CEN-V(2) = WS-FEET-V(2) + 2
     MOVE WS-FEET-V(3) TO WS-CEN-V(3)
     MOVE L-DX TO WS-DEL-V(1)
     MOVE L-DY TO WS-DEL-V(2)
     MOVE L-DZ TO WS-DEL-V(3)
     COMPUTE WS-N = FUNCTION INTEGER(WS-LEN / 2) + 1
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > WS-N OR L-OK = 0
         COMPUTE WS-T = WS-S / WS-N
         COMPUTE WS-BX = WS-CEN-V(1) + L-DX * WS-T
         COMPUTE WS-BY = WS-CEN-V(2) + L-DY * WS-T
         COMPUTE WS-BZ = WS-CEN-V(3) + L-DZ * WS-T
         COMPUTE WS-X0 = FUNCTION INTEGER(WS-BX - 2)
         COMPUTE WS-X1 = FUNCTION INTEGER(WS-BX + 2)
         COMPUTE WS-Y0 = FUNCTION INTEGER(WS-BY - 2)
         COMPUTE WS-Y1 = FUNCTION INTEGER(WS-BY + 2)
         COMPUTE WS-Z0 = FUNCTION INTEGER(WS-BZ - 2)
         COMPUTE WS-Z1 = FUNCTION INTEGER(WS-BZ + 2)
         PERFORM VARYING WS-CX FROM WS-X0 BY 1 UNTIL WS-CX > WS-X1 OR L-OK = 0
             PERFORM VARYING WS-CY FROM WS-Y0 BY 1 UNTIL WS-CY > WS-Y1 OR L-OK = 0
                 PERFORM VARYING WS-CZ FROM WS-Z0 BY 1 UNTIL WS-CZ > WS-Z1 OR L-OK = 0
                     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
                     IF WS-SOLID = 1
*>                       a cell the current box intersects (positive overlap on every axis) is passable
                         MOVE 1 TO WS-HIT
                         IF WS-CX < WS-FEET-V(1) + 2 - WS-EPS AND WS-CX + 1 > WS-FEET-V(1) - 2 + WS-EPS
                                 AND WS-CY < WS-FEET-V(2) + 4 - WS-EPS AND WS-CY + 1 > WS-FEET-V(2) + WS-EPS
                                 AND WS-CZ < WS-FEET-V(3) + 2 - WS-EPS AND WS-CZ + 1 > WS-FEET-V(3) - 2 + WS-EPS
                             MOVE 0 TO WS-HIT
                         END-IF
                         IF WS-HIT = 1
                             COMPUTE WS-MIN-V(1) = WS-CX - 2
                             COMPUTE WS-MAX-V(1) = WS-CX + 3
                             COMPUTE WS-MIN-V(2) = WS-CY - 2
                             COMPUTE WS-MAX-V(2) = WS-CY + 3
                             COMPUTE WS-MIN-V(3) = WS-CZ - 2
                             COMPUTE WS-MAX-V(3) = WS-CZ + 3
                             CALL "GHAST-SEG-HITS" USING WS-CEN WS-DEL WS-MIN WS-MAX WS-HIT
                             IF WS-HIT = 1
                                 MOVE 0 TO L-OK
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM GHAST-CAN-REACH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GHAST-CLAMP.
*> USING tracker row, x, y, z (FLOAT-LONG, y in out): the end of RandomFloatAroundGoal (44-6 section 9.1): when the MOTION_BLOCKING height of the point's column (the Y above its
*> topmost block that blocks motion or holds a fluid) is below the point's block Y and above the dimension's minimum Y, the point's Y becomes mobY - |mobY - pointY| (so the ghast does not
*> float over open void); x and z stay.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-CHUNK-X             BINARY-LONG.
 01 WS-CHUNK-Z             BINARY-LONG.
 01 WS-CROW                BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-BLOCKS              BINARY-LONG.
 01 WS-DY                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     COMPUTE WS-CX = FUNCTION INTEGER(L-X)
     COMPUTE WS-CY = FUNCTION INTEGER(L-Y)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z)
     MOVE DM-MIN-Y(EN-DIM(L-ROW)) TO WS-MIN
     COMPUTE WS-TOP = WS-MIN + DM-HEIGHT(EN-DIM(L-ROW)) - 1
     MOVE WS-MIN TO WS-HEIGHT
     MOVE 0 TO WS-DONE
     COMPUTE WS-CHUNK-X = (WS-CX - FUNCTION MOD(WS-CX, 16)) / 16
     COMPUTE WS-CHUNK-Z = (WS-CZ - FUNCTION MOD(WS-CZ, 16)) / 16
     CALL "WORLD-FIND" USING EN-DIM(L-ROW) WS-CHUNK-X WS-CHUNK-Z WS-CROW
     IF WS-CROW > 0
         PERFORM VARYING WS-CY FROM WS-TOP BY -1 UNTIL WS-CY < WS-MIN OR WS-DONE = 1
             CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-STATE
             MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLK
             MOVE CB-SOLID(WS-BLK + 1) TO WS-BLOCKS
             IF CB-KEY(WS-BLK + 1) = "water" OR CB-KEY(WS-BLK + 1) = "minecraft:water"
                     OR CB-KEY(WS-BLK + 1) = "lava" OR CB-KEY(WS-BLK + 1) = "minecraft:lava"
                 MOVE 1 TO WS-BLOCKS
             END-IF
             IF WS-BLOCKS = 1
                 COMPUTE WS-HEIGHT = WS-CY + 1
                 MOVE 1 TO WS-DONE
             END-IF
         END-PERFORM
     END-IF
     COMPUTE WS-CY = FUNCTION INTEGER(L-Y)
     IF WS-HEIGHT < WS-CY AND WS-HEIGHT > WS-MIN
         COMPUTE WS-DY = FUNCTION ABS(EN-Y(L-ROW) - L-Y)
         COMPUTE L-Y = EN-Y(L-ROW) - WS-DY
     END-IF
     GOBACK.
 END PROGRAM GHAST-CLAMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GHAST-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 71.
 01 WS-B1000               BINARY-LONG VALUE 1000.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-R                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-REACH               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
*> USING tracker row of a ghast: RandomFloatAroundGoal and GhastMoveControl (44 part 6 section 9.1) and the flight. Without a wanted point, or at one reached (distance squared below
*> 1) or too far (above 3600), a new point is drawn in the cube of half side 16 around the ghast and clamped over open ground (GHAST-CLAMP). The control: floatDuration falls by 1 every
*> tick and only when it was <= 0 before the fall it grows by nextInt(5) + 2 (so 1 to 5) and acts: when the box can reach the point (GHAST-CAN-REACH) the velocity gains
*> normalize(delta) x 0.1 (the flying speed 0.06 x 5 / 3; the way to the point, not the current velocity, so there is no start velocity), else the point is dropped. The ghast moves by
*> its velocity unless a solid cell is there (then its velocity is 0) and the velocity is multiplied by 0.91.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-DX = EN-PH-TX(L-ROW) - EN-X(L-ROW)
     COMPUTE WS-DY = EN-PH-TY(L-ROW) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-PH-TZ(L-ROW) - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     IF EN-PH-SET(L-ROW) = 0 OR WS-D2 < 1 OR WS-D2 > 3600
         CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R
         COMPUTE EN-PH-TX(L-ROW) = EN-X(L-ROW) + (WS-R / 500 - 1) * 16
         CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R
         COMPUTE EN-PH-TY(L-ROW) = EN-Y(L-ROW) + (WS-R / 500 - 1) * 16
         CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R
         COMPUTE EN-PH-TZ(L-ROW) = EN-Z(L-ROW) + (WS-R / 500 - 1) * 16
         CALL "GHAST-CLAMP" USING L-ROW EN-PH-TX(L-ROW) EN-PH-TY(L-ROW) EN-PH-TZ(L-ROW)
         MOVE 1 TO EN-PH-SET(L-ROW)
     END-IF
     MOVE EN-PH-SCAN(L-ROW) TO WS-OLD
     SUBTRACT 1 FROM EN-PH-SCAN(L-ROW)
     IF WS-OLD <= 0
         CALL "XP-RANDOM" USING WS-SALT WS-B5 WS-R
         COMPUTE EN-PH-SCAN(L-ROW) = EN-PH-SCAN(L-ROW) + WS-R + 2
         COMPUTE WS-DX = EN-PH-TX(L-ROW) - EN-X(L-ROW)
         COMPUTE WS-DY = EN-PH-TY(L-ROW) - EN-Y(L-ROW)
         COMPUTE WS-DZ = EN-PH-TZ(L-ROW) - EN-Z(L-ROW)
         COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
         CALL "GHAST-CAN-REACH" USING L-ROW WS-DX WS-DY WS-DZ WS-REACH
         IF WS-REACH = 0
             MOVE 0 TO EN-PH-SET(L-ROW)
         ELSE
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + WS-DX / WS-LEN * 0.1
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + WS-DY / WS-LEN * 0.1
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + WS-DZ / WS-LEN * 0.1
         END-IF
     END-IF
     COMPUTE WS-NX = EN-X(L-ROW) + EN-VX(L-ROW)
     COMPUTE WS-NY = EN-Y(L-ROW) + EN-VY(L-ROW)
     COMPUTE WS-NZ = EN-Z(L-ROW) + EN-VZ(L-ROW)
     CALL "GHAST-SOLID" USING L-ROW WS-NX WS-NY WS-NZ WS-SOLID
     IF WS-SOLID = 1
         MOVE 0 TO EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
         MOVE EN-X(L-ROW) TO WS-NX
         MOVE EN-Y(L-ROW) TO WS-NY
         MOVE EN-Z(L-ROW) TO WS-NZ
     END-IF
     MOVE EN-YAW(L-ROW) TO WS-YAW
     MOVE EN-PITCH(L-ROW) TO WS-PITCH
     CALL "ENTITY-MOVE" USING L-ROW WS-NX WS-NY WS-NZ WS-YAW WS-PITCH WS-GROUND
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.91
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.91
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.91
     GOBACK.
 END PROGRAM GHAST-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GHAST-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
*> USING tracker row, table row of a ghast (STDMOB-STEP after the environment): the target (STDMOB-AGGRO, then dropped when the player's feet differ in height by more than 4), GhastLookGoal
*> (yaw toward a target within 64 blocks, else along the velocity), GHAST-SHOOT and GHAST-MOVE.
 PROCEDURE DIVISION USING L-ROW L-M.
     CALL "STDMOB-AGGRO" USING L-ROW L-M
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
         IF FUNCTION ABS(WS-DY) > 4
             MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW) WS-P
         END-IF
     END-IF
     MOVE EN-VX(L-ROW) TO WS-DX
     MOVE EN-VZ(L-ROW) TO WS-DZ
     IF WS-P > 0
         COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
     END-IF
     MOVE EN-YAW(L-ROW) TO WS-YAW
     CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-YAW
     MOVE WS-YAW TO EN-YAW(L-ROW)
     CALL "GHAST-SHOOT" USING L-ROW L-M
     CALL "GHAST-MOVE" USING L-ROW
     GOBACK.
 END PROGRAM GHAST-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLAZE-FIRE.
*> USING tracker row, player row, distance squared (FLOAT-LONG): one small fireball at the target (21 section 5.2): the direction (triangle(dx, 2.297 f), dy, triangle(dz, 2.297 f))
*> with f = sqrt(sqrt(d2)) x 0.5, dy between the half heights, from the blaze's half height + 0.5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 72.
 01 WS-B1000               BINARY-LONG VALUE 1000.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-KIND                BINARY-LONG VALUE 2.
 01 WS-POWER               BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-FIREBALL            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-D2                   FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-P L-D2.
     COMPUTE WS-F = FUNCTION SQRT(FUNCTION SQRT(L-D2)) * 0.5
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R1
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R2
     COMPUTE WS-DX = PL-X(L-P) - EN-X(L-ROW) + 2.297 * WS-F * (WS-R1 - WS-R2) / 1000
     COMPUTE WS-DY = PL-Y(L-P) + 0.9 - (EN-Y(L-ROW) + 0.9)
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R1
     CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R2
     COMPUTE WS-DZ = PL-Z(L-P) - EN-Z(L-ROW) + 2.297 * WS-F * (WS-R1 - WS-R2) / 1000
     COMPUTE WS-SY = EN-Y(L-ROW) + 1.4
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-ID(L-ROW) TO WS-OWNER
     CALL "PROJ-SPAWN" USING WS-KIND WS-DIM EN-X(L-ROW) WS-SY EN-Z(L-ROW) WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-FIREBALL
     GOBACK.
 END PROGRAM BLAZE-FIRE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLAZE-ATTACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
*> USING tracker row, table row of a blaze: BlazeAttackGoal (21 section 5.2). attackTime (EN-SHOOT-TIME) falls by 1 a tick; lastSeen (EN-SWELL) counts the ticks without a line of sight.
*> Within 2 blocks (distance squared below 4) it hits in melee when attackTime is 0 (then 20). Else within the follow range and in sight, at attackTime 0 attackStep (EN-DRAW) grows:
*> step 1 attackTime 60 and the charged flag, steps 2 to 4 attackTime 6, step 5 attackTime 100, step 0 and the flag off; steps 2 to 4 fire a small fireball (BLAZE-FIRE). Without a
*> target the charged flag is off.
 PROCEDURE DIVISION USING L-ROW L-M.
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P = 0
         IF EN-VARIANT(L-ROW) = 1
             MOVE 0 TO EN-VARIANT(L-ROW)
             CALL "STDMOB-VARIANT-SEND" USING L-ROW
         END-IF
         GOBACK
     END-IF
     SUBTRACT 1 FROM EN-SHOOT-TIME(L-ROW)
     COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
     MOVE EN-X(L-ROW) TO WS-EX
     COMPUTE WS-EY = EN-Y(L-ROW) + 1.53
     MOVE EN-Z(L-ROW) TO WS-EZ
     COMPUTE WS-TY = PL-Y(WS-P) + 1.62
     CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-EX WS-EY WS-EZ PL-X(WS-P) WS-TY PL-Z(WS-P) WS-SEES
     IF WS-SEES = 1
         MOVE 0 TO EN-SWELL(L-ROW)
     ELSE
         ADD 1 TO EN-SWELL(L-ROW)
     END-IF
     COMPUTE WS-LIMIT = SM-FOLLOW(L-M) * SM-FOLLOW(L-M)
     EVALUATE TRUE
         WHEN WS-D2 < 4
             IF EN-SHOOT-TIME(L-ROW) <= 0
                 MOVE 20 TO EN-SHOOT-TIME(L-ROW)
                 CALL "STDMOB-ATTACK-DAMAGE" USING L-ROW L-M WS-DAMAGE
                 CALL "HEALTH-MOB-HIT" USING WS-P WS-DAMAGE L-ROW
             END-IF
         WHEN WS-D2 < WS-LIMIT AND WS-SEES = 1
             IF EN-SHOOT-TIME(L-ROW) <= 0
                 ADD 1 TO EN-DRAW(L-ROW)
                 EVALUATE TRUE
                     WHEN EN-DRAW(L-ROW) = 1
                         MOVE 60 TO EN-SHOOT-TIME(L-ROW)
                         MOVE 1 TO WS-FLAG
                     WHEN EN-DRAW(L-ROW) <= 4
                         MOVE 6 TO EN-SHOOT-TIME(L-ROW)
                         MOVE 1 TO WS-FLAG
                     WHEN OTHER
                         MOVE 100 TO EN-SHOOT-TIME(L-ROW)
                         MOVE 0 TO EN-DRAW(L-ROW) WS-FLAG
                 END-EVALUATE
                 IF WS-FLAG NOT = EN-VARIANT(L-ROW)
                     MOVE WS-FLAG TO EN-VARIANT(L-ROW)
                     CALL "STDMOB-VARIANT-SEND" USING L-ROW
                 END-IF
                 IF EN-DRAW(L-ROW) > 1
                     CALL "BLAZE-FIRE" USING L-ROW WS-P WS-D2
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM BLAZE-ATTACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BLAZE-HEIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 73.
 01 WS-B1000               BINARY-LONG VALUE 1000.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
*> USING tracker row of a blaze: customServerAiStep and the glide of aiStep (21 section 5.2). The counter EN-WAKE falls by 1 a tick; at 0 it is 100 again and allowedHeightOffset (EN-PH-HEIGHT)
*> is drawn as triangle(0.5, 6.891). With a target whose eyes (feet + 1.62) are above the blaze's eyes (feet + 1.53) + the offset, vy gains (0.3 - vy) x 0.3. Not on the ground and
*> falling, vy is multiplied by 0.6.
 PROCEDURE DIVISION USING L-ROW.
     SUBTRACT 1 FROM EN-WAKE(L-ROW)
     IF EN-WAKE(L-ROW) <= 0
         MOVE 100 TO EN-WAKE(L-ROW)
         CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R1
         CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-R2
         COMPUTE EN-PH-HEIGHT(L-ROW) = 0.5 + 6.891 * (WS-R1 - WS-R2) / 1000
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         IF PL-Y(WS-P) + 1.62 > EN-Y(L-ROW) + 1.53 + EN-PH-HEIGHT(L-ROW)
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + (0.3 - EN-VY(L-ROW)) * 0.3
         END-IF
     END-IF
     IF EN-ON-GROUND(L-ROW) = 0 AND EN-VY(L-ROW) < 0
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.6
     END-IF
     GOBACK.
 END PROGRAM BLAZE-HEIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SNOW-GOLEM-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY CITEMS.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-ARC                 FLOAT-LONG.
 01 WS-KIND                BINARY-LONG VALUE 3.
 01 WS-POWER               BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-SNOWBALL            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
*> USING tracker row, table row of a snow golem: the target is the nearest alive monster (SM-KIND 1) of its dimension within 10 blocks that it sees (golem eyes feet + 1.7, the target's
*> eyes 0.85 of its height); without one the timer EN-PET-CD is 0. RangedAttackGoal (19 section 20, interval 20): the first tick with a target sets the timer to 20, then it counts down
*> and at 0 a snowball is thrown (speed 1.6 from the eyes - 0.1 = feet + 1.6: dy = target eyes - 1.1 - 1.6 - feet + sqrt(dx^2 + dz^2) x 0.2) and the timer is 20 again.
 PROCEDURE DIVISION USING L-ROW L-M.
     MOVE 0 TO WS-BEST
     MOVE EN-X(L-ROW) TO WS-EX
     COMPUTE WS-EY = EN-Y(L-ROW) + 1.7
     MOVE EN-Z(L-ROW) TO WS-EZ
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
             COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
             IF WS-S > 0 AND WS-D2 <= 100 AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                 IF SM-KIND(WS-S) = 1
                     COMPUTE WS-TY = EN-Y(WS-N) + ET-HEIGHT-MILLI(EN-TYPE(WS-N) + 1) * 0.00085
                     CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-EX WS-EY WS-EZ EN-X(WS-N) WS-TY EN-Z(WS-N) WS-SEES
                     IF WS-SEES = 1
                         MOVE WS-N TO WS-BEST
                         MOVE WS-D2 TO WS-BEST-D2
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-BEST = 0
         MOVE 0 TO EN-PET-CD(L-ROW)
         GOBACK
     END-IF
     IF EN-PET-CD(L-ROW) = 0
         MOVE 20 TO EN-PET-CD(L-ROW)
         GOBACK
     END-IF
     SUBTRACT 1 FROM EN-PET-CD(L-ROW)
     IF EN-PET-CD(L-ROW) = 0
         COMPUTE WS-SY = EN-Y(L-ROW) + 1.6
         COMPUTE WS-DX = EN-X(WS-BEST) - EN-X(L-ROW)
         COMPUTE WS-DZ = EN-Z(WS-BEST) - EN-Z(L-ROW)
         COMPUTE WS-ARC = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ) * 0.2
         COMPUTE WS-TY = EN-Y(WS-BEST) + ET-HEIGHT-MILLI(EN-TYPE(WS-BEST) + 1) * 0.00085
         COMPUTE WS-DY = WS-TY - 1.1 - WS-SY + WS-ARC
         MOVE EN-DIM(L-ROW) TO WS-DIM
         MOVE EN-ID(L-ROW) TO WS-OWNER
         CALL "PROJ-SPAWN" USING WS-KIND WS-DIM EN-X(L-ROW) WS-SY EN-Z(L-ROW) WS-DX WS-DY WS-DZ WS-POWER WS-OWNER WS-SNOWBALL
         MOVE 20 TO EN-PET-CD(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM SNOW-GOLEM-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHULKER-ATTACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 74.
 01 WS-B10                 BINARY-LONG VALUE 10.
 01 WS-R                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 4.
 01 WS-POWER               BINARY-LONG VALUE 0.
 01 WS-AXIS                BINARY-LONG VALUE 2.
 01 WS-DIM                 BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-UP                  FLOAT-LONG VALUE 1.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-BULLET              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
*> USING tracker row, table row of a shulker: ShulkerAttackGoal (21 section 6.2). A target at distance squared 400 or more (20 blocks) is dropped. Without a target the lid closes (raw
*> peek EN-VARIANT 0). The first tick with a target opens the lid (raw peek 100) and sets attackTime (EN-SHOOT-TIME) to 20; then it counts down and at 0 a bullet leaves
*> (BULLET-SELECT with the axis of the attach face, DOWN here, so Y) and attackTime is 20 + nextInt(10) x 10 (20 + (nextInt(10) x 20) / 2). The bullet starts at the shulker's
*> middle (feet + 0.5; open: the exact start is not in the docs), at rest, homing on the player (EN-FOE-ID).
 PROCEDURE DIVISION USING L-ROW L-M.
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
         IF WS-D2 >= 400
             MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW) WS-P
         END-IF
     END-IF
     IF WS-P = 0
         IF EN-VARIANT(L-ROW) NOT = 0
             MOVE 0 TO EN-VARIANT(L-ROW)
             CALL "STDMOB-VARIANT-SEND" USING L-ROW
         END-IF
         GOBACK
     END-IF
     IF EN-VARIANT(L-ROW) = 0
         MOVE 100 TO EN-VARIANT(L-ROW)
         MOVE 20 TO EN-SHOOT-TIME(L-ROW)
         CALL "STDMOB-VARIANT-SEND" USING L-ROW
         GOBACK
     END-IF
     SUBTRACT 1 FROM EN-SHOOT-TIME(L-ROW)
     IF EN-SHOOT-TIME(L-ROW) <= 0
         MOVE EN-DIM(L-ROW) TO WS-DIM
         MOVE EN-ID(L-ROW) TO WS-OWNER
         MOVE EN-X(L-ROW) TO WS-X
         COMPUTE WS-Y = EN-Y(L-ROW) + 0.5
         MOVE EN-Z(L-ROW) TO WS-Z
         CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-UP WS-ZERO WS-ZERO2 WS-POWER WS-OWNER WS-BULLET
         MOVE EN-TARGET-ID(L-ROW) TO EN-FOE-ID(WS-BULLET)
         CALL "BULLET-SELECT" USING WS-BULLET WS-AXIS
         CALL "XP-RANDOM" USING WS-SALT WS-B10 WS-R
         COMPUTE EN-SHOOT-TIME(L-ROW) = 20 + WS-R * 10
     END-IF
     GOBACK.
 END PROGRAM SHULKER-ATTACK.
