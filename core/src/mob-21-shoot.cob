*> Projectile-shooting Nether mobs and the snow golem (002-lane-mobsfull-h19; docs/protocol/21 sections 5.1 and 5.2, 44 part 6 sections 9.1 and 9.2, 19 section 20). The rows
*> are core/copy/MOB21ROWS3.cpy (SM-RANGED 4 ghast, 5 blaze); the projectiles are core/src/mob-21-proj.cob.
*> Ghast: GHAST-TICK takes the nearest player of the follow range 100 whose height differs by at most 4 (the selector's |dy| <= 4, applied here to every tick and not only to the
*> choice), looks at it within 64 blocks (else along its velocity), GHAST-SHOOT charges and fires, GHAST-MOVE flies. EN-SHOOT-TIME is chargeTime, EN-VARIANT the charging flag
*> (metadata 16), EN-PH-TX to EN-PH-TZ and EN-PH-SET the wanted point of the move control, EN-PH-SCAN its floatDuration.
*> Blaze: BLAZE-ATTACK is BlazeAttackGoal (EN-SHOOT-TIME attackTime, EN-DRAW attackStep, EN-SWELL lastSeen, EN-VARIANT the charged flag, metadata 16 bit 0); BLAZE-HEIGHT the
*> height keeping (EN-WAKE the ticks to the next offset, EN-PH-HEIGHT allowedHeightOffset) and the glide of aiStep. The blaze walks to its target like any monster (STDMOB-STEP).
*> Snow golem: SNOW-GOLEM-TICK throws a snowball at the nearest monster within 10 blocks that it sees (EN-PET-CD the attack timer, 0 = not started).
*> Approximations (open): the ghast's canReach sweep samples the path at three heights every half block against whole solid cells and its box is one cell for collisions, the point
*> clamp over open void and the 64 attempts of getSuitableFlyToPosition (the first point always passes for distance 0) are left out; the thrust of the move control is along the
*> way to the wanted point (44 part 6 section 9.1 words it as the normalised current velocity, which would never start from rest); the blaze's eye is 1.53 (0.85 of its height),
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
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-QX                  FLOAT-LONG.
 01 WS-QY                  FLOAT-LONG.
 01 WS-QZ                  FLOAT-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-NX                  FLOAT-LONG.
 01 WS-NY                  FLOAT-LONG.
 01 WS-NZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
*> USING tracker row of a ghast: RandomFloatAroundGoal and GhastMoveControl (44 part 6 section 9.1) and the flight. Without a wanted point, or at one reached (distance squared below
*> 1) or too far (above 3600), a new point is drawn in the cube of half side 16 around the ghast. floatDuration falls by 1 a tick; at 0 it grows by nextInt(5) + 2 and the velocity
*> gains 0.1 (speed 0.06 x 5 / 3) along the way to the wanted point when that way is free (else the point is dropped). The ghast moves by its velocity unless a solid cell is there
*> (then its velocity is 0) and the velocity is multiplied by 0.91.
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
         MOVE 1 TO EN-PH-SET(L-ROW)
     END-IF
     SUBTRACT 1 FROM EN-PH-SCAN(L-ROW)
     IF EN-PH-SCAN(L-ROW) <= 0
         CALL "XP-RANDOM" USING WS-SALT WS-B5 WS-R
         COMPUTE EN-PH-SCAN(L-ROW) = EN-PH-SCAN(L-ROW) + WS-R + 2
         COMPUTE WS-DX = EN-PH-TX(L-ROW) - EN-X(L-ROW)
         COMPUTE WS-DY = EN-PH-TY(L-ROW) - EN-Y(L-ROW)
         COMPUTE WS-DZ = EN-PH-TZ(L-ROW) - EN-Z(L-ROW)
         COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
*>       canReach: the way sampled every half block.
         COMPUTE WS-N = FUNCTION INTEGER(WS-LEN * 2) + 1
         MOVE 0 TO WS-BLOCKED
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR WS-BLOCKED = 1
             COMPUTE WS-T = WS-I / WS-N
             COMPUTE WS-QX = EN-X(L-ROW) + WS-DX * WS-T
             COMPUTE WS-QY = EN-Y(L-ROW) + WS-DY * WS-T
             COMPUTE WS-QZ = EN-Z(L-ROW) + WS-DZ * WS-T
             CALL "GHAST-SOLID" USING L-ROW WS-QX WS-QY WS-QZ WS-SOLID
             IF WS-SOLID = 1
                 MOVE 1 TO WS-BLOCKED
             END-IF
         END-PERFORM
         IF WS-BLOCKED = 1
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
 PROGRAM-ID. SHULKER-PEEK-STEP.
*> USING tracker row: Shulker.updatePeekAmount (44-9 section 11): the current peek (EN-PEEK-CUR) moves 0.05 a tick toward the raw peek x 0.01 (EN-VARIANT / 100), clamped at it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TARGET              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-TARGET = EN-VARIANT(L-ROW) * 0.01
     IF EN-PEEK-CUR(L-ROW) > WS-TARGET
         COMPUTE EN-PEEK-CUR(L-ROW) = FUNCTION MAX(EN-PEEK-CUR(L-ROW) - 0.05, WS-TARGET)
     ELSE
         COMPUTE EN-PEEK-CUR(L-ROW) = FUNCTION MIN(EN-PEEK-CUR(L-ROW) + 0.05, WS-TARGET)
     END-IF
     GOBACK.
 END PROGRAM SHULKER-PEEK-STEP.

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
*> (BULLET-SELECT with the axis of the attach face, DOWN here, so Y) and attackTime is 20 + nextInt(10) x 10 (20 + (nextInt(10) x 20) / 2). The bullet starts at the centre of the shulker's current box
*> (21 section 6.2, the lid peek EN-PEEK-CUR moves 0.05 a tick), at rest, homing on the player (EN-FOE-ID).
 PROCEDURE DIVISION USING L-ROW L-M.
     CALL "SHULKER-PEEK-STEP" USING L-ROW
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
*>       The centre of the shulker's current box (21 section 6.2): attached to the floor the box is the unit cube extended up by physical(peek) = 0.5 - sin((0.5 + peek) pi) x 0.5.
         COMPUTE WS-Y = EN-Y(L-ROW) + (1 + 0.5 - FUNCTION SIN((0.5 + EN-PEEK-CUR(L-ROW)) * FUNCTION PI) * 0.5) / 2
         MOVE EN-Z(L-ROW) TO WS-Z
         CALL "PROJ-SPAWN" USING WS-KIND WS-DIM WS-X WS-Y WS-Z WS-UP WS-ZERO WS-ZERO2 WS-POWER WS-OWNER WS-BULLET
         MOVE EN-TARGET-ID(L-ROW) TO EN-FOE-ID(WS-BULLET)
         CALL "BULLET-SELECT" USING WS-BULLET WS-AXIS
         CALL "XP-RANDOM" USING WS-SALT WS-B10 WS-R
         COMPUTE EN-SHOOT-TIME(L-ROW) = 20 + WS-R * 10
     END-IF
     GOBACK.
 END PROGRAM SHULKER-ATTACK.
