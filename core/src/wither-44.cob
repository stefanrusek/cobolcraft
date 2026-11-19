*> The Wither and its skulls (docs/protocol/21 section 7; lane 002-lane-mobsb6, T9012), PJ-KIND 14 (the boss) and 15 (the skull). Boss: PJ-I1 invulnerable ticks (220 at the spawn), PJ-I2 the main
*> target's entity id, PJ-I3 destroyBlocksTick, PJ-I4 and PJ-I5 the next head update (side heads 1 and 2), PJ-I6 and PJ-I7 their idle head updates, PJ-DUR the ranged attack timer of head 0. Health is
*> EN-HEALTH in points (maximum 300). The skull: PJ-I1 dangerous, owner the wither.
*> Build (WITHER-BUILD, called after a block is placed): a wither skull over three soul sand or soul soil over a soul sand base with air beside it, in a row along x or z, not in Peaceful: the seven
*> blocks become air and the wither appears at the base cell's centre, y + 0.55, with 220 invulnerable ticks and 100 health.
*> Gaps: the boss bar (no Boss Event packets), the nearest player is the only target (HurtByTarget, the wither_friends tag, the random living target of the side heads), eye
*> height of the explosion (y + 3.0), block drops of the destroyed blocks, wither_immune is the block tag of the data pack (CONTENT-TAG-HAS), the owner's heal on a kill, the dangerous skull's
*> explosion resistance cap and 0.73 inertia is used but the cap is not, pathfinding (it flies straight), the metadata 16 to 19, sounds, the criteria,
*> look and head turning.
*>
*>   WITHER-CLASS USING dim, x, y, z, class out (1 wither skull, 2 soul sand or soul soil, 3 air, 0 other)
*>   WITHER-BUILD USING dim, x, y, z (the placed block): the pattern search of 21 section 7.1.1, nine cells cleared, yaw by the axis of forwards (lane p49t)
*>   WITHER-CAN-SPAWN USING dim, x, y, z, can out (the base pattern: the dispenser's canSpawnMob; the dispenser itself does not place skull blocks in this core)
*>   WITHER-FIND USING dim, x, y, z, full, found out, forwards out, up out, origin x, y, z out
*>   WITHER-SPAWN USING dim, x, y, z (FLOAT-LONG, the feet), row out
*>   WITHER-SHOOT USING wither row, head, target x y z (FLOAT-LONG), dangerous, skull row out
*>   WSKULL-STEP USING skull row
*>   WITHER-STEP USING wither row
*>   WITHER-HURT USING wither row, amount, cause, handled out (called by HEALTH-MOB-DAMAGE)
*>   WITHER-DEATH USING row, handled out (called by MOB-DEFEAT)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-CLASS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-PATH                PIC X(48).
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CLASS                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-CLASS.
     MOVE 0 TO L-CLASS
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         MOVE 3 TO L-CLASS
         GOBACK
     END-IF
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-KEY
     IF WS-KEY(1:10) = "minecraft:"
         MOVE WS-KEY(11:38) TO WS-PATH
     ELSE
         MOVE WS-KEY TO WS-PATH
     END-IF
     EVALUATE WS-PATH
         WHEN "wither_skeleton_skull" WHEN "wither_skeleton_wall_skull"
             MOVE 1 TO L-CLASS
         WHEN "soul_sand" WHEN "soul_soil"
             MOVE 2 TO L-CLASS
     END-EVALUATE
     GOBACK.
 END PROGRAM WITHER-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:wither".
 01 WS-KIND                BINARY-LONG VALUE 14.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW.
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-NONE L-ROW
     IF L-ROW > 0
         MOVE 100 TO EN-HEALTH(L-ROW)
         CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
         MOVE 220 TO PJ-I1(WS-SLOT)
         MOVE 0 TO PJ-I2(WS-SLOT)
     END-IF
     GOBACK.
 END PROGRAM WITHER-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-CELL.
*> USING origin x, y, z, forwards, up (1 DOWN, 2 UP, 3 NORTH, 4 SOUTH, 5 WEST, 6 EAST), column, row, cell x, y, z out (BINARY-LONG): origin + column x (forwards x up) - row x up (21 section 7.1.1; one aisle).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEPS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-STEP-TABLE REDEFINES WS-STEPS.
    05 WS-STEP-OF          OCCURS 6 TIMES.
       10 WS-SX            BINARY-LONG.
       10 WS-SY            BINARY-LONG.
       10 WS-SZ            BINARY-LONG.
 01 WS-CROSS-X             BINARY-LONG.
 01 WS-CROSS-Y             BINARY-LONG.
 01 WS-CROSS-Z             BINARY-LONG.
 LINKAGE SECTION.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-FWD                  BINARY-LONG.
 01 L-UP                   BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-OX L-OY L-OZ L-FWD L-UP L-C L-R L-X L-Y L-Z.
     COMPUTE WS-CROSS-X = WS-SY(L-FWD) * WS-SZ(L-UP) - WS-SZ(L-FWD) * WS-SY(L-UP)
     COMPUTE WS-CROSS-Y = WS-SZ(L-FWD) * WS-SX(L-UP) - WS-SX(L-FWD) * WS-SZ(L-UP)
     COMPUTE WS-CROSS-Z = WS-SX(L-FWD) * WS-SY(L-UP) - WS-SY(L-FWD) * WS-SX(L-UP)
     COMPUTE L-X = L-OX + L-C * WS-CROSS-X - L-R * WS-SX(L-UP)
     COMPUTE L-Y = L-OY + L-C * WS-CROSS-Y - L-R * WS-SY(L-UP)
     COMPUTE L-Z = L-OZ + L-C * WS-CROSS-Z - L-R * WS-SZ(L-UP)
     GOBACK.
 END PROGRAM WITHER-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-MATCH.
*> USING dim, origin x, y, z, forwards, up, full (1 the full pattern ^^^ / ### / ~#~, 0 the base pattern with a blank top row), ok out: the nine cells against the predicates of 21 section 7.1.1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 01 L-FWD                  BINARY-LONG.
 01 L-UP                   BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-OX L-OY L-OZ L-FWD L-UP L-FULL L-OK.
     MOVE 1 TO L-OK
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 2
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 2
             CALL "WITHER-CELL" USING L-OX L-OY L-OZ L-FWD L-UP WS-C WS-R WS-X WS-Y WS-Z
             CALL "WITHER-CLASS" USING L-DIM WS-X WS-Y WS-Z WS-CLASS
             IF WS-R = 0 AND L-FULL = 1 AND WS-CLASS NOT = 1
                 MOVE 0 TO L-OK
             END-IF
             IF WS-R = 1 AND WS-CLASS NOT = 2
                 MOVE 0 TO L-OK
             END-IF
             IF WS-R = 2 AND WS-C = 1 AND WS-CLASS NOT = 2
                 MOVE 0 TO L-OK
             END-IF
             IF WS-R = 2 AND WS-C NOT = 1 AND WS-CLASS NOT = 3
                 MOVE 0 TO L-OK
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM WITHER-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-FIND.
*> USING dim, x, y, z, full (1 or 0), found out, forwards out, up out, origin x, y, z out: BlockPattern.find (21 section 7.1.1): the origins from the position to position + (2, 2, 2) (x fastest, then y, then
*> z), for each every (forwards, up) of the six directions in the order DOWN, UP, NORTH, SOUTH, WEST, EAST (forwards outer) except up equal to forwards or to its opposite; the first that matches.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-OPPOSITE            BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-FWD                  BINARY-LONG.
 01 L-UP                   BINARY-LONG.
 01 L-OX                   BINARY-LONG.
 01 L-OY                   BINARY-LONG.
 01 L-OZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FULL L-FOUND L-FWD L-UP L-OX L-OY L-OZ.
     MOVE 0 TO L-FOUND
     PERFORM VARYING WS-OZ FROM L-Z BY 1 UNTIL WS-OZ > L-Z + 2 OR L-FOUND = 1
         PERFORM VARYING WS-OY FROM L-Y BY 1 UNTIL WS-OY > L-Y + 2 OR L-FOUND = 1
             PERFORM VARYING WS-OX FROM L-X BY 1 UNTIL WS-OX > L-X + 2 OR L-FOUND = 1
                 PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > 6 OR L-FOUND = 1
                     IF FUNCTION MOD(WS-F, 2) = 1
                         COMPUTE WS-OPPOSITE = WS-F + 1
                     ELSE
                         COMPUTE WS-OPPOSITE = WS-F - 1
                     END-IF
                     PERFORM VARYING WS-U FROM 1 BY 1 UNTIL WS-U > 6 OR L-FOUND = 1
                         IF WS-U NOT = WS-F AND WS-U NOT = WS-OPPOSITE
                             CALL "WITHER-MATCH" USING L-DIM WS-OX WS-OY WS-OZ WS-F WS-U L-FULL WS-OK
                             IF WS-OK = 1
                                 MOVE 1 TO L-FOUND
                                 MOVE WS-F TO L-FWD
                                 MOVE WS-U TO L-UP
                                 MOVE WS-OX TO L-OX
                                 MOVE WS-OY TO L-OY
                                 MOVE WS-OZ TO L-OZ
                             END-IF
                         END-IF
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM WITHER-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-CAN-SPAWN.
*> USING dim, x, y, z, can out: WitherSkullBlock.canSpawnMob (21 section 7.1.1, the dispenser's test): not Peaceful, y at least the dimension's minimum + 2 and the base pattern found around the position.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRWORLD.
 COPY DIMENSIONS.
 01 WS-FULL                BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FWD                 BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-CAN                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-CAN.
     MOVE 0 TO L-CAN
     IF BW-DIFFICULTY = 0 OR L-Y < DM-MIN-Y(L-DIM) + 2
         GOBACK
     END-IF
     CALL "WITHER-FIND" USING L-DIM L-X L-Y L-Z WS-FULL WS-FOUND WS-FWD WS-UP WS-OX WS-OY WS-OZ
     MOVE WS-FOUND TO L-CAN
     GOBACK.
 END PROGRAM WITHER-CAN-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-BUILD.
*> USING dim, x, y, z (the placed block): WitherSkullBlock.checkSpawn (21 section 7.1): a wither skull at the cell, not Peaceful, y at least the minimum, and the full pattern found around it; then every
*> one of the nine cells is cleared (column by column, row by row, with level event 2001 carrying the old state) and the wither appears at the middle cell of the bottom row (+ 0.5, + 0.55, + 0.5), yaw
*> 0 when the axis of forwards is X and 90 otherwise.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRWORLD.
 COPY DIMENSIONS.
 COPY CORESTATE.
 01 WS-CLASS               BINARY-LONG.
 01 WS-FULL                BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FWD                 BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-EVENT               BINARY-LONG VALUE 2001.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     IF BW-DIFFICULTY = 0 OR L-Y < DM-MIN-Y(L-DIM)
         GOBACK
     END-IF
     CALL "WITHER-CLASS" USING L-DIM L-X L-Y L-Z WS-CLASS
     IF WS-CLASS NOT = 1
         GOBACK
     END-IF
     CALL "WITHER-FIND" USING L-DIM L-X L-Y L-Z WS-FULL WS-FOUND WS-FWD WS-UP WS-OX WS-OY WS-OZ
     IF WS-FOUND = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 2
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R > 2
             CALL "WITHER-CELL" USING WS-OX WS-OY WS-OZ WS-FWD WS-UP WS-C WS-R WS-CX WS-CY WS-CZ
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-CX WS-CY WS-CZ WS-OLD
             CALL "BLOCK-CHANGE" USING L-DIM WS-CX WS-CY WS-CZ WS-AIR
             CALL "LEVEL-EVENT" USING L-DIM WS-EVENT WS-CX WS-CY WS-CZ WS-OLD WS-NONE
             IF WS-C = 1 AND WS-R = 2
                 MOVE WS-CX TO WS-MX
                 MOVE WS-CY TO WS-MY
                 MOVE WS-CZ TO WS-MZ
             END-IF
         END-PERFORM
     END-PERFORM
     COMPUTE WS-X = WS-MX + 0.5
     COMPUTE WS-Y = WS-MY + 0.55
     COMPUTE WS-Z = WS-MZ + 0.5
     CALL "WITHER-SPAWN" USING L-DIM WS-X WS-Y WS-Z WS-ROW
     IF WS-ROW > 0
         MOVE 90 TO EN-YAW(WS-ROW)
         IF WS-FWD = 5 OR WS-FWD = 6
             MOVE 0 TO EN-YAW(WS-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WITHER-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-SHOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:wither_skull".
 01 WS-KIND                BINARY-LONG VALUE 15.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HY                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 1024.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HEAD                 BINARY-LONG.
 01 L-TX                   FLOAT-LONG.
 01 L-TY                   FLOAT-LONG.
 01 L-TZ                   FLOAT-LONG.
 01 L-DANGEROUS            BINARY-LONG.
 01 L-SKULL                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HEAD L-TX L-TY L-TZ L-DANGEROUS L-SKULL.
     MOVE 0 TO L-SKULL
     MOVE EN-X(L-ROW) TO WS-HX
     MOVE EN-Z(L-ROW) TO WS-HZ
     COMPUTE WS-HY = EN-Y(L-ROW) + 3.0
     IF L-HEAD > 0
         COMPUTE WS-ANGLE = (EN-YAW(L-ROW) + 180 * (L-HEAD - 1)) * FUNCTION PI / 180
         COMPUTE WS-HX = EN-X(L-ROW) - FUNCTION SIN(WS-ANGLE) * 1.3
         COMPUTE WS-HZ = EN-Z(L-ROW) + FUNCTION COS(WS-ANGLE) * 1.3
         COMPUTE WS-HY = EN-Y(L-ROW) + 2.2
     END-IF
     COMPUTE WS-DX = L-TX - WS-HX
     COMPUTE WS-DY = L-TY - WS-HY
     COMPUTE WS-DZ = L-TZ - WS-HZ
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     IF WS-LEN = 0
         MOVE 1 TO WS-LEN
     END-IF
     COMPUTE WS-VX = WS-DX / WS-LEN * 0.1
     COMPUTE WS-VY = WS-DY / WS-LEN * 0.1
     COMPUTE WS-VZ = WS-DZ / WS-LEN * 0.1
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY EN-DIM(L-ROW) WS-HX WS-HY WS-HZ WS-VX WS-VY WS-VZ EN-ID(L-ROW) L-SKULL
     IF L-SKULL > 0
         CALL "PJ-FIND" USING EN-ID(L-SKULL) WS-SLOT
         MOVE L-DANGEROUS TO PJ-I1(WS-SLOT)
     END-IF
     COMPUTE WS-CX = FUNCTION INTEGER(WS-HX)
     COMPUTE WS-CY = FUNCTION INTEGER(WS-HY)
     COMPUTE WS-CZ = FUNCTION INTEGER(WS-HZ)
     CALL "LEVEL-EVENT" USING EN-DIM(L-ROW) WS-EVENT WS-CX WS-CY WS-CZ WS-NONE WS-NONE2
     GOBACK.
 END PROGRAM WITHER-SHOOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WSKULL-HIT.
*> USING skull row, entity row, player row (one 0): the hit (21 section 7.2): 8 damage and the Wither effect (amplifier 1, 20 x s ticks, s 0 Easy, 10 Normal, 40 Hard), then the explosion of radius 1.0
*> at the skull (blocks only with mob_griefing) and the skull is gone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY RULES.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-MOB.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-MILLI               BINARY-LONG VALUE 8000.
 01 WS-POINTS              BINARY-LONG VALUE 8.
 01 WS-DUR                 BINARY-LONG.
 01 WS-AMP                 BINARY-LONG VALUE 1.
 01 WS-FX                  BINARY-LONG VALUE 19.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-DESTROY             BINARY-LONG.
 01 WS-POWER               FLOAT-LONG VALUE 1.0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ATTACKER            BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-PLAYER.
     MOVE 0 TO WS-DUR
     EVALUATE BW-DIFFICULTY
         WHEN 2
             MOVE 200 TO WS-DUR
         WHEN 3
             MOVE 800 TO WS-DUR
     END-EVALUATE
     IF L-PLAYER > 0
         CALL "HEALTH-HURT" USING L-PLAYER WS-MILLI WS-CAUSE WS-NONE WS-NONE2 WS-RESULT
         IF WS-DUR > 0
             CALL "THROWN-EFFECT-ADD" USING WS-NONE L-PLAYER WS-FX WS-AMP WS-DUR
         END-IF
     END-IF
     IF L-ENTITY > 0
         MOVE 0 TO EN-HURT(L-ENTITY)
         CALL "HEALTH-MOB-DAMAGE" USING L-ENTITY WS-POINTS WS-CAUSE WS-NONE
         IF WS-DUR > 0
             CALL "THROWN-EFFECT-ADD" USING L-ENTITY WS-NONE WS-FX WS-AMP WS-DUR
         END-IF
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     MOVE 0 TO WS-DESTROY
     IF WS-RULE NOT = 0
         MOVE 1 TO WS-DESTROY
     END-IF
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "PJ-DROP" USING L-ROW
     CALL "EXPLODE-RUN" USING WS-DIM WS-X WS-Y WS-Z WS-POWER WS-DESTROY WS-ATTACKER
     GOBACK.
 END PROGRAM WSKULL-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WSKULL-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-INERTIA             FLOAT-LONG.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-HIT                 BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE 0.95 TO WS-INERTIA
     IF PJ-I1(WS-SLOT) = 1
         MOVE 0.73 TO WS-INERTIA
     END-IF
     COMPUTE WS-LEN = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VY(L-ROW) * EN-VY(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     IF WS-LEN > 0
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + EN-VX(L-ROW) / WS-LEN * 0.1
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + EN-VY(L-ROW) / WS-LEN * 0.1
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + EN-VZ(L-ROW) / WS-LEN * 0.1
     END-IF
     CALL "THROWN-FLY2" USING L-ROW WS-ZERO WS-INERTIA WS-HIT WS-ENTITY WS-PLAYER
     IF WS-HIT > 0
         CALL "WSKULL-HIT" USING L-ROW WS-ENTITY WS-PLAYER
     END-IF
     GOBACK.
 END PROGRAM WSKULL-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY RULES.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT L-CAUSE L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0 OR PJ-KIND(WS-SLOT) NOT = 14
         GOBACK
     END-IF
     EVALUATE TRUE
         WHEN PJ-I1(WS-SLOT) > 0
             MOVE 1 TO L-HANDLED
         WHEN EN-HEALTH(L-ROW) <= 150 AND L-CAUSE = CAUSE-ARROW
             MOVE 1 TO L-HANDLED
         WHEN OTHER
             IF PJ-I3(WS-SLOT) <= 0
                 MOVE 20 TO PJ-I3(WS-SLOT)
             END-IF
             ADD 3 TO PJ-I6(WS-SLOT)
             ADD 3 TO PJ-I7(WS-SLOT)
     END-EVALUATE
     GOBACK.
 END PROGRAM WITHER-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-DEATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:nether_star".
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-XP                  BINARY-LONG VALUE 50.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-STAR-ROW            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0 OR PJ-KIND(WS-SLOT) NOT = 14
         GOBACK
     END-IF
     MOVE 1 TO L-HANDLED
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "WITHER-BAR-END" USING L-ROW WS-SLOT
     CALL "PJ-DROP" USING L-ROW
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-ITEM WS-ONE WS-DELAY WS-STAR-ROW
*>   dropCustomDeathLoot: setExtendedLifetime (age -6000: the star lives 12000 ticks, 41 section 5.1).
     IF WS-STAR-ROW > 0
         MOVE -6000 TO EN-AGE(WS-STAR-ROW)
     END-IF
     CALL "XP-AWARD" USING WS-DIM WS-X WS-Y WS-Z WS-XP
     GOBACK.
 END PROGRAM WITHER-DEATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-TARGET.
*> USING wither row, target player row out (0 none), the nearest living survival or adventure player within 40 blocks.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TARGET.
     MOVE 0 TO L-TARGET
     MOVE 1600 TO WS-BEST
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                 AND (PL-MODE(WS-P) = 0 OR PL-MODE(WS-P) = 2)
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             IF WS-D2 <= WS-BEST
                 MOVE WS-D2 TO WS-BEST
                 MOVE WS-P TO L-TARGET
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WITHER-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-HEADS.
*> USING wither row, slot, target player row: the side head logic of 7.2 (Server AI): each head updates when the tick reaches its next update.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY BRWORLD.
 01 WS-H                   BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9131.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-TWENTY              BINARY-LONG VALUE 20.
 01 WS-R                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-IDLE                BINARY-LONG.
 01 WS-HEAD                BINARY-LONG.
 01 WS-DANGEROUS           BINARY-LONG.
 01 WS-SKULL               BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-TWENTYONE           BINARY-LONG VALUE 21.
 01 WS-ELEVEN              BINARY-LONG VALUE 11.
 01 WS-NEXTBASE            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-TARGET.
     PERFORM VARYING WS-H FROM 1 BY 1 UNTIL WS-H > 2
         IF WS-H = 1
             MOVE PJ-I4(L-SLOT) TO WS-NEXT
             MOVE PJ-I6(L-SLOT) TO WS-IDLE
         ELSE
             MOVE PJ-I5(L-SLOT) TO WS-NEXT
             MOVE PJ-I7(L-SLOT) TO WS-IDLE
         END-IF
         IF PJ-TICK(L-SLOT) >= WS-NEXT
             CALL "XP-RANDOM" USING WS-SALT WS-TEN WS-R
             COMPUTE WS-NEXT = PJ-TICK(L-SLOT) + 10 + WS-R
             IF BW-DIFFICULTY >= 2
                 ADD 1 TO WS-IDLE
                 IF WS-IDLE > 15
                     CALL "XP-RANDOM" USING WS-SALT WS-TWENTYONE WS-R
                     COMPUTE WS-TX = EN-X(L-ROW) + WS-R - 10
                     CALL "XP-RANDOM" USING WS-SALT WS-ELEVEN WS-R
                     COMPUTE WS-TY = EN-Y(L-ROW) + WS-R - 5
                     CALL "XP-RANDOM" USING WS-SALT WS-TWENTYONE WS-R
                     COMPUTE WS-TZ = EN-Z(L-ROW) + WS-R - 10
                     COMPUTE WS-HEAD = WS-H + 1
                     MOVE 1 TO WS-DANGEROUS
                     CALL "WITHER-SHOOT" USING L-ROW WS-HEAD WS-TX WS-TY WS-TZ WS-DANGEROUS WS-SKULL
                     MOVE 0 TO WS-IDLE
                 END-IF
             END-IF
             IF L-TARGET > 0
                 COMPUTE WS-D2 = (PL-X(L-TARGET) - EN-X(L-ROW)) ** 2 + (PL-Y(L-TARGET) - EN-Y(L-ROW)) ** 2 + (PL-Z(L-TARGET) - EN-Z(L-ROW)) ** 2
                 COMPUTE WS-EY = PL-Y(L-TARGET) + 1.62
                 COMPUTE WS-EX = EN-Y(L-ROW) + 3.0
                 MOVE PL-X(L-TARGET) TO WS-TX
                 MOVE PL-Z(L-TARGET) TO WS-TZ
                 CALL "MOB-SEES" USING EN-DIM(L-ROW) EN-X(L-ROW) WS-EX EN-Z(L-ROW) WS-TX WS-EY WS-TZ WS-SEES
                 IF WS-D2 <= 900 AND WS-SEES = 1
                     COMPUTE WS-HEAD = WS-H + 1
                     MOVE 0 TO WS-DANGEROUS
                     COMPUTE WS-TY = PL-Y(L-TARGET) + 0.81
                     CALL "WITHER-SHOOT" USING L-ROW WS-HEAD WS-TX WS-TY WS-TZ WS-DANGEROUS WS-SKULL
                     CALL "XP-RANDOM" USING WS-SALT WS-TWENTY WS-R
                     COMPUTE WS-NEXT = PJ-TICK(L-SLOT) + 40 + WS-R
                     MOVE 0 TO WS-IDLE
                 END-IF
             END-IF
         END-IF
         IF WS-H = 1
             MOVE WS-NEXT TO PJ-I4(L-SLOT)
             MOVE WS-IDLE TO PJ-I6(L-SLOT)
         ELSE
             MOVE WS-NEXT TO PJ-I5(L-SLOT)
             MOVE WS-IDLE TO PJ-I7(L-SLOT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WITHER-HEADS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-DESTROY.
*> USING wither row: the blocks in the box (x - w, y, z - w) to (x + w, y + h, z + w), w = floor(width / 2 + 1), h = floor(height), that are not air and not wither_immune are destroyed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:wither_immune".
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-IMMUNE              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-ANY                 BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 1022.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-X0 = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y0 = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z0 = FUNCTION INTEGER(EN-Z(L-ROW))
     MOVE 0 TO WS-ANY
     PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X0 + 1 + 0
         PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z0 + 1 + 0
             PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y0 + 3
                 CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-STATE
                 IF WS-STATE > 0
                     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
                     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG WS-BLOCK WS-IMMUNE
                     IF WS-IMMUNE = 0
                         CALL "BLOCK-CHANGE" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-AIR
                         MOVE 1 TO WS-ANY
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-ANY = 1
         CALL "LEVEL-EVENT" USING EN-DIM(L-ROW) WS-EVENT WS-X0 WS-Y0 WS-Z0 WS-NONE WS-NONE2
     END-IF
     GOBACK.
 END PROGRAM WITHER-DESTROY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-DESTROY             BINARY-LONG.
 01 WS-POWER               FLOAT-LONG VALUE 7.0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-ATTACKER            BINARY-LONG VALUE 0.
 01 WS-EVENT               BINARY-LONG VALUE 1023.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-POWERED             BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-HEAD0               BINARY-LONG VALUE 0.
 01 WS-DANGEROUS           BINARY-LONG VALUE 0.
 01 WS-SKULL               BINARY-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-TEYE                FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 9132.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     ADD 1 TO PJ-TICK(WS-SLOT)
     CALL "WITHER-BAR" USING L-ROW WS-SLOT
     IF PJ-I1(WS-SLOT) > 0
         COMPUTE WS-N = PJ-I1(WS-SLOT) - 1
         IF WS-N <= 0
             CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
             MOVE 0 TO WS-DESTROY
             IF WS-RULE NOT = 0
                 MOVE 1 TO WS-DESTROY
             END-IF
             MOVE EN-DIM(L-ROW) TO WS-DIM
             MOVE EN-X(L-ROW) TO WS-EX
             COMPUTE WS-EY = EN-Y(L-ROW) + 3.0
             MOVE EN-Z(L-ROW) TO WS-EZ
             CALL "EXPLODE-RUN" USING WS-DIM WS-EX WS-EY WS-EZ WS-POWER WS-DESTROY WS-ATTACKER
             COMPUTE WS-CX = FUNCTION INTEGER(WS-EX)
             COMPUTE WS-CY = FUNCTION INTEGER(WS-EY)
             COMPUTE WS-CZ = FUNCTION INTEGER(WS-EZ)
             CALL "END-GLOBAL-EVENT" USING WS-EVENT WS-CX WS-CY WS-CZ
         END-IF
         MOVE WS-N TO PJ-I1(WS-SLOT)
         IF FUNCTION MOD(PJ-TICK(WS-SLOT), 10) = 0
             COMPUTE EN-HEALTH(L-ROW) = FUNCTION MIN(300, EN-HEALTH(L-ROW) + 10)
         END-IF
         GOBACK
     END-IF
     IF FUNCTION MOD(PJ-TICK(WS-SLOT), 20) = 0
         COMPUTE EN-HEALTH(L-ROW) = FUNCTION MIN(300, EN-HEALTH(L-ROW) + 1)
     END-IF
     MOVE 0 TO WS-POWERED
     IF EN-HEALTH(L-ROW) <= 150
         MOVE 1 TO WS-POWERED
     END-IF
     IF PJ-I3(WS-SLOT) > 0
         SUBTRACT 1 FROM PJ-I3(WS-SLOT)
         IF PJ-I3(WS-SLOT) = 0
             CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
             IF WS-RULE NOT = 0
                 CALL "WITHER-DESTROY" USING L-ROW
             END-IF
         END-IF
     END-IF
     CALL "WITHER-TARGET" USING L-ROW WS-TARGET
     IF WS-TARGET = 0
         MOVE 0 TO PJ-I2(WS-SLOT)
     ELSE
         MOVE PL-ENTITY-ID(WS-TARGET) TO PJ-I2(WS-SLOT)
     END-IF
*>   Flight (aiStep).
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.6
     IF WS-TARGET > 0
         IF EN-Y(L-ROW) < PL-Y(WS-TARGET) OR (WS-POWERED = 0 AND EN-Y(L-ROW) < PL-Y(WS-TARGET) + 5)
             COMPUTE EN-VY(L-ROW) = FUNCTION MAX(0, EN-VY(L-ROW))
             COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + 0.3 - EN-VY(L-ROW) * 0.6
         END-IF
         COMPUTE WS-DX = PL-X(WS-TARGET) - EN-X(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-TARGET) - EN-Z(L-ROW)
         COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
         IF WS-D2 > 9
             COMPUTE WS-H = FUNCTION SQRT(WS-D2)
             COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + WS-DX / WS-H * 0.3 - EN-VX(L-ROW) * 0.6
             COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + WS-DZ / WS-H * 0.3 - EN-VZ(L-ROW) * 0.6
         END-IF
     END-IF
     COMPUTE EN-X(L-ROW) = EN-X(L-ROW) + EN-VX(L-ROW)
     COMPUTE EN-Y(L-ROW) = EN-Y(L-ROW) + EN-VY(L-ROW)
     COMPUTE EN-Z(L-ROW) = EN-Z(L-ROW) + EN-VZ(L-ROW)
*>   Head 0: the ranged attack every 40 ticks at a target within 20 blocks.
     IF PJ-DUR(WS-SLOT) > 0
         SUBTRACT 1 FROM PJ-DUR(WS-SLOT)
     ELSE
         IF WS-TARGET > 0
             COMPUTE WS-D2 = (PL-X(WS-TARGET) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-TARGET) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-TARGET) - EN-Z(L-ROW)) ** 2
             COMPUTE WS-EYE = EN-Y(L-ROW) + 3.0
             COMPUTE WS-TEYE = PL-Y(WS-TARGET) + 1.62
             MOVE PL-X(WS-TARGET) TO WS-TX
             MOVE PL-Z(WS-TARGET) TO WS-TZ
             CALL "MOB-SEES" USING EN-DIM(L-ROW) EN-X(L-ROW) WS-EYE EN-Z(L-ROW) WS-TX WS-TEYE WS-TZ WS-SEES
             IF WS-D2 <= 400 AND WS-SEES = 1
                 COMPUTE WS-TY = PL-Y(WS-TARGET) + 0.81
                 CALL "WITHER-SHOOT" USING L-ROW WS-HEAD0 WS-TX WS-TY WS-TZ WS-DANGEROUS WS-SKULL
                 MOVE 40 TO PJ-DUR(WS-SLOT)
             END-IF
         END-IF
     END-IF
     CALL "WITHER-HEADS" USING L-ROW WS-SLOT WS-TARGET
     CALL "THROWN-SYNC" USING L-ROW
     GOBACK.
 END PROGRAM WITHER-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-BAR-PACKET.
*> USING wither entity id, operation (0 ADD, 1 REMOVE, 2 UPDATE_PROGRESS), progress (thousandths), player row: Boss Event 0x09 (05a) to one player; the bar's uuid is 12 zero bytes and the entity id;
*> title the translation entity.minecraft.wither, purple (5), progress overlay (0), flag darken screen (0x01) (21 section 7.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ID                  BINARY-LONG VALUE 9.
 01 WS-UUID                PIC X(16).
 01 WS-PROGRESS            FLOAT-SHORT.
 01 WS-COLOR               BINARY-LONG VALUE 5.
 01 WS-STYLE               BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 1.
 01 WS-B                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ENTITY               BINARY-LONG.
 01 L-OP                   BINARY-LONG.
 01 L-PROGRESS             BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTITY L-OP L-PROGRESS L-PLAYER.
     MOVE LOW-VALUES TO WS-UUID
     MOVE L-ENTITY TO WS-Q
     COMPUTE WS-B = FUNCTION MOD(WS-Q, 256)
     MOVE FUNCTION CHAR(WS-B + 1) TO WS-UUID(16:1)
     COMPUTE WS-Q = WS-Q / 256
     COMPUTE WS-B = FUNCTION MOD(WS-Q, 256)
     MOVE FUNCTION CHAR(WS-B + 1) TO WS-UUID(15:1)
     COMPUTE WS-Q = WS-Q / 256
     COMPUTE WS-B = FUNCTION MOD(WS-Q, 256)
     MOVE FUNCTION CHAR(WS-B + 1) TO WS-UUID(14:1)
     COMPUTE WS-PROGRESS = L-PROGRESS / 1000
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-OP
     IF L-OP = 0
         INITIALIZE PB-TEXT
         MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
         MOVE "entity.minecraft.wither" TO PB-TX-VALUE
         MOVE 23 TO PB-TX-LENGTH
         CALL "PB-PUT-TEXT" USING PB-BUFFER PB-TEXT
         CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PROGRESS
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COLOR
         CALL "PB-PUT-VARINT" USING PB-BUFFER WS-STYLE
         CALL "PB-PUT-UBYTE" USING PB-BUFFER WS-FLAGS
     END-IF
     IF L-OP = 2
         CALL "PB-PUT-FLOAT" USING PB-BUFFER WS-PROGRESS
     END-IF
     CALL "CORE-SEND" USING PL-CONN(L-PLAYER) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM WITHER-BAR-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-BAR.
*> USING wither row, slot: the bar's members (PJ-V-ENT, player rows: alive players of the dimension within 160 blocks), ADD and REMOVE as they come and go, and UPDATE_PROGRESS when the progress
*> (1 - (remaining - 1) / 220 while spawning, else health / 300; PJ-I8 holds the last sent + 1) changed. Gaps: the bar's name follows no custom name, the wither's tracking range (160) stands for
*> startSeenByPlayer and stopSeenByPlayer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-PROG                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-OP-ADD              BINARY-LONG VALUE 0.
 01 WS-OP-REMOVE           BINARY-LONG VALUE 1.
 01 WS-OP-PROGRESS         BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF PJ-I1(L-SLOT) > 0
         COMPUTE WS-N = PJ-I1(L-SLOT) - 1
         COMPUTE WS-PROG = (220 - WS-N) * 1000 / 220
     ELSE
         COMPUTE WS-PROG = EN-HEALTH(L-ROW) * 1000 / 300
     END-IF
     COMPUTE WS-PROG = FUNCTION MAX(0, FUNCTION MIN(1000, WS-PROG))
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0
             MOVE 0 TO WS-VALID
             IF PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                 IF (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2 <= 25600
                     MOVE 1 TO WS-VALID
                 END-IF
             END-IF
             MOVE 0 TO WS-IN WS-FREE
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 16
                 IF PJ-V-ENT(L-SLOT, WS-J) = WS-P
                     MOVE WS-J TO WS-IN
                 END-IF
                 IF PJ-V-ENT(L-SLOT, WS-J) = 0 AND WS-FREE = 0
                     MOVE WS-J TO WS-FREE
                 END-IF
             END-PERFORM
             IF WS-VALID = 1 AND WS-IN = 0 AND WS-FREE > 0
                 MOVE WS-P TO PJ-V-ENT(L-SLOT, WS-FREE)
                 CALL "WITHER-BAR-PACKET" USING EN-ID(L-ROW) WS-OP-ADD WS-PROG WS-P
             END-IF
             IF WS-VALID = 0 AND WS-IN > 0
                 MOVE 0 TO PJ-V-ENT(L-SLOT, WS-IN)
                 CALL "WITHER-BAR-PACKET" USING EN-ID(L-ROW) WS-OP-REMOVE WS-PROG WS-P
             END-IF
         END-IF
     END-PERFORM
     IF PJ-I8(L-SLOT) NOT = WS-PROG + 1
         MOVE WS-PROG TO WS-N
         COMPUTE PJ-I8(L-SLOT) = WS-PROG + 1
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 16
             IF PJ-V-ENT(L-SLOT, WS-J) > 0
                 CALL "WITHER-BAR-PACKET" USING EN-ID(L-ROW) WS-OP-PROGRESS WS-N PJ-V-ENT(L-SLOT, WS-J)
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM WITHER-BAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WITHER-BAR-END.
*> USING wither row, slot: REMOVE to every member of the bar and the member list is cleared.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-J                   BINARY-LONG.
 01 WS-OP-REMOVE           BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 16
         IF PJ-V-ENT(L-SLOT, WS-J) > 0
             MOVE PJ-V-ENT(L-SLOT, WS-J) TO WS-P
             CALL "WITHER-BAR-PACKET" USING EN-ID(L-ROW) WS-OP-REMOVE WS-ZERO WS-P
             MOVE 0 TO PJ-V-ENT(L-SLOT, WS-J)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WITHER-BAR-END.
