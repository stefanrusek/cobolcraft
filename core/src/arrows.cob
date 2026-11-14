*> Arrows and bow mobs (002-lane-mobs2, T4120; docs/protocol/20 section 5 bow goal and shot, 44 section 7 AbstractArrow, 17 section 3.9).
*> An arrow is a tracker row of the standard entity type arrow (found by key): EN-VX to EN-VZ its velocity, EN-ITEM its base damage in thousandths,
*> EN-TARGET-ID the entity id of its owner (0 none), EN-ON-GROUND 1 once it sticks in a block, EN-AGE the ticks it has been stuck (removed at 1200),
*> EN-COOLDOWN its tick count; EN-WAY-X, EN-FLEE-X and EN-WAY-Z hold the position the viewers were last told (as the orbs of xp.cob).
*> A tick (ARROW-STEP): stuck arrows only age; a flying one moves by its velocity, the segment tested in steps of at most 0.1 block against solid
*> cells (it stops at the last free point and sticks) and against the boxes of players and standard mobs other than its owner (inflated by the
*> margin max(0, min(0.3, (tick - 2) / 20)) of 44 section 7.3); a hit does ceil(speed x base damage) (a player through HEALTH-HURT with CAUSE-ARROW, a
*> mob in whole points) and removes the arrow; then drag 0.99 and gravity 0.05.
*> Approximations (open): block hits use sample steps and not an exact voxel clip, water drag, critical arrows, piercing, Punch and Power, fire,
*> tipped arrows, pickup of stuck arrows and the arrow count of the victim are not modelled.
*>
*> Entry points:
*>   ARROW-TYPE USING type id out                       the entity type id of arrow, 0 outside a standard world
*>   ARROW-SPAWN USING dim, x, y, z, vx, vy, vz (FLOAT-LONG), base damage (thousandths), owner entity id, row out
*>   ARROW-STEP USING tracker row                       one tick of one arrow
*>   ARROWS-TICK                                        every arrow (CORE-TICK)
*>   STDMOB-SHOOT USING tracker row, table row, stop out   the bow goal of a skeleton (20 section 5)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARROW-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:arrow".
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 0.
 01 WS-LOADED              BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE.
     MOVE 0 TO L-TYPE
     IF CT-OPEN = 0 OR CT-SET-TYPE = CT-TYPE-COBOLCRAFT OR CT-SET-TYPE = CT-TYPE-DEBUG
         GOBACK
     END-IF
     IF WS-LOADED = 0
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ID WS-ROW WS-STATUS
         MOVE 1 TO WS-LOADED
     END-IF
     MOVE WS-ID TO L-TYPE
     GOBACK.
 END PROGRAM ARROW-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARROW-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-BASE                 BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
*> USING dim, x, y, z, vx, vy, vz, base damage (thousandths), owner entity id, row out: a new arrow with that velocity, facing along it.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-VX L-VY L-VZ L-BASE L-OWNER L-ROW.
     CALL "ARROW-TYPE" USING WS-TYPE
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     MOVE WS-TYPE TO EN-TYPE(WS-ROW)
     CALL "ENTITY-SET-UUID" USING WS-ROW
     MOVE L-DIM TO EN-DIM(WS-ROW)
     MOVE L-X TO EN-X(WS-ROW) EN-WAY-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW) EN-FLEE-X(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW) EN-WAY-Z(WS-ROW)
     MOVE L-VX TO EN-VX(WS-ROW)
     MOVE L-VY TO EN-VY(WS-ROW)
     MOVE L-VZ TO EN-VZ(WS-ROW)
     MOVE L-BASE TO EN-ITEM(WS-ROW)
     MOVE L-OWNER TO EN-TARGET-ID(WS-ROW)
     COMPUTE WS-H = FUNCTION SQRT(L-VX * L-VX + L-VZ * L-VZ)
     IF L-VZ = 0
         IF L-VX >= 0
             MOVE 90 TO EN-YAW(WS-ROW)
         ELSE
             MOVE -90 TO EN-YAW(WS-ROW)
         END-IF
     ELSE
         COMPUTE EN-YAW(WS-ROW) = FUNCTION ATAN(L-VX / L-VZ) * 180 / FUNCTION PI
         IF L-VZ < 0
             COMPUTE EN-YAW(WS-ROW) = EN-YAW(WS-ROW) + 180
         END-IF
     END-IF
     IF WS-H > 0
         COMPUTE EN-PITCH(WS-ROW) = FUNCTION ATAN(L-VY / WS-H) * 180 / FUNCTION PI
     END-IF
     CALL "ENTITY-TRACK" USING WS-ROW
     MOVE WS-ROW TO L-ROW
     GOBACK.
 END PROGRAM ARROW-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARROW-HIT.
*> USING arrow row, entity row, player row (BINARY-LONG; one of them 0): the arrow hits a player or a mob (44 section 7.3 onHitEntity): damage =
*> ceil(speed x base damage); a player is hurt through HEALTH-HURT (CAUSE-ARROW, the shooter's name for the death message), a mob loses whole
*> points (HEALTH-MOB-DAMAGE; a player owner is the attacker for the loot and experience); the arrow is removed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-ARROW.
 01 WS-OWNER-ID            BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-OWNER-ROW           BINARY-LONG.
 01 WS-OWNER-PLAYER        BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ARROW                BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ARROW L-ENTITY L-PLAYER.
     COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(L-ARROW) * EN-VX(L-ARROW) + EN-VY(L-ARROW) * EN-VY(L-ARROW)
         + EN-VZ(L-ARROW) * EN-VZ(L-ARROW))
     COMPUTE WS-MILLI = FUNCTION INTEGER(WS-SPEED * EN-ITEM(L-ARROW) + 0.999)
     COMPUTE WS-DAMAGE = FUNCTION INTEGER((WS-MILLI + 999) / 1000)
     MOVE EN-TARGET-ID(L-ARROW) TO WS-OWNER-ID
     MOVE 0 TO WS-OWNER-ROW WS-OWNER-PLAYER
     PERFORM VARYING WS-O FROM 1 BY 1 UNTIL WS-O > EN-COUNT
         IF EN-USED(WS-O) = 1 AND EN-ID(WS-O) = WS-OWNER-ID AND WS-OWNER-ID > 0
             MOVE WS-O TO WS-OWNER-ROW
         END-IF
     END-PERFORM
     PERFORM VARYING WS-O FROM 1 BY 1 UNTIL WS-O > CORE-MAX-PLAYERS
         IF PL-USED(WS-O) = 1 AND PL-ENTITY-ID(WS-O) = WS-OWNER-ID AND WS-OWNER-ID > 0
             MOVE WS-O TO WS-OWNER-PLAYER
         END-IF
     END-PERFORM
     IF L-PLAYER > 0
         MOVE SPACES TO PL-KILLER-NAME(L-PLAYER)
         MOVE 0 TO PL-KILLER-LENGTH(L-PLAYER)
         IF WS-OWNER-ROW > 0
             CALL "STDMOB-NAME" USING EN-TYPE(WS-OWNER-ROW) WS-NAME WS-NAME-LENGTH
             MOVE WS-NAME TO PL-KILLER-NAME(L-PLAYER)
             MOVE WS-NAME-LENGTH TO PL-KILLER-LENGTH(L-PLAYER)
         END-IF
         COMPUTE WS-MILLI = WS-DAMAGE * 1000
         CALL "HEALTH-HURT" USING L-PLAYER WS-MILLI WS-CAUSE WS-OWNER-ID WS-OWNER-PLAYER WS-RESULT
     ELSE
         MOVE 0 TO EN-HURT(L-ENTITY)
         CALL "HEALTH-MOB-DAMAGE" USING L-ENTITY WS-DAMAGE WS-CAUSE WS-OWNER-PLAYER
     END-IF
     CALL "ENTITY-REMOVE" USING L-ARROW
     GOBACK.
 END PROGRAM ARROW-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARROW-FIND-HIT.
*> USING arrow row, x, y, z (the sample point, FLOAT-LONG), entity row out, player row out (0 when none): the first player or standard mob (other than the
*> arrow's owner) whose box, inflated by the margin max(0, min(0.3, (tick - 2) / 20)), holds the point.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-MARGIN              FLOAT-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ARROW                BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ARROW L-X L-Y L-Z L-ENTITY L-PLAYER.
     MOVE 0 TO L-ENTITY L-PLAYER
     COMPUTE WS-MARGIN = FUNCTION MAX(0, FUNCTION MIN(0.3, (EN-COOLDOWN(L-ARROW) - 2) / 20))
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS OR L-PLAYER > 0
         IF PL-USED(WS-P) = 1 AND PL-ENTITY-ROW(WS-P) > 0 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ARROW)
                 AND PL-MODE(WS-P) < 3 AND PL-ENTITY-ID(WS-P) NOT = EN-TARGET-ID(L-ARROW)
                 AND FUNCTION ABS(L-X - PL-X(WS-P)) <= 0.3 + WS-MARGIN AND FUNCTION ABS(L-Z - PL-Z(WS-P)) <= 0.3 + WS-MARGIN
                 AND L-Y >= PL-Y(WS-P) - WS-MARGIN AND L-Y <= PL-Y(WS-P) + 1.8 + WS-MARGIN
             MOVE WS-P TO L-PLAYER
         END-IF
     END-PERFORM
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR L-PLAYER > 0 OR L-ENTITY > 0
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = EN-DIM(L-ARROW) AND EN-HEALTH(WS-E) > 0 AND EN-ID(WS-E) NOT = EN-TARGET-ID(L-ARROW)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
             IF WS-M > 0
                 COMPUTE WS-W = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
                 COMPUTE WS-H = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                 IF FUNCTION ABS(L-X - EN-X(WS-E)) <= WS-W + WS-MARGIN AND FUNCTION ABS(L-Z - EN-Z(WS-E)) <= WS-W + WS-MARGIN
                         AND L-Y >= EN-Y(WS-E) - WS-MARGIN AND L-Y <= EN-Y(WS-E) + WS-H + WS-MARGIN
                     MOVE WS-E TO L-ENTITY
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ARROW-FIND-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARROW-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-STEP                FLOAT-LONG VALUE 0.000122.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-QX                  FLOAT-LONG.
 01 WS-QY                  FLOAT-LONG.
 01 WS-QZ                  FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-ON-GROUND(L-ROW) = 1
         ADD 1 TO EN-AGE(L-ROW)
         IF EN-AGE(L-ROW) >= 1200
             CALL "ENTITY-REMOVE" USING L-ROW
         END-IF
         GOBACK
     END-IF
     ADD 1 TO EN-COOLDOWN(L-ROW)
     COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VY(L-ROW) * EN-VY(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     COMPUTE WS-STEPS = FUNCTION INTEGER(WS-SPEED / 0.1) + 1
     MOVE EN-X(L-ROW) TO WS-PX
     MOVE EN-Y(L-ROW) TO WS-PY
     MOVE EN-Z(L-ROW) TO WS-PZ
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-STEPS OR WS-DONE > 0
         COMPUTE WS-QX = EN-X(L-ROW) + EN-VX(L-ROW) * WS-S / WS-STEPS
         COMPUTE WS-QY = EN-Y(L-ROW) + EN-VY(L-ROW) * WS-S / WS-STEPS
         COMPUTE WS-QZ = EN-Z(L-ROW) + EN-VZ(L-ROW) * WS-S / WS-STEPS
         COMPUTE WS-CX = FUNCTION INTEGER(WS-QX)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-QY)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-QZ)
         CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
         IF WS-SOLID = 1
             MOVE 1 TO WS-DONE
         ELSE
             CALL "ARROW-FIND-HIT" USING L-ROW WS-QX WS-QY WS-QZ WS-ENTITY WS-PLAYER
             IF WS-ENTITY > 0 OR WS-PLAYER > 0
                 MOVE 2 TO WS-DONE
             ELSE
                 MOVE WS-QX TO WS-PX
                 MOVE WS-QY TO WS-PY
                 MOVE WS-QZ TO WS-PZ
             END-IF
         END-IF
     END-PERFORM
     IF WS-DONE = 2
         CALL "ARROW-HIT" USING L-ROW WS-ENTITY WS-PLAYER
         GOBACK
     END-IF
     IF WS-DONE = 1
*>       Stuck: at the last free point, no velocity (44 section 7.5).
         MOVE WS-PX TO EN-X(L-ROW)
         MOVE WS-PY TO EN-Y(L-ROW)
         MOVE WS-PZ TO EN-Z(L-ROW)
         MOVE 0 TO EN-VX(L-ROW) EN-VY(L-ROW) EN-VZ(L-ROW)
         MOVE 1 TO EN-ON-GROUND(L-ROW)
         MOVE 0 TO EN-AGE(L-ROW)
     ELSE
         MOVE WS-PX TO EN-X(L-ROW)
         MOVE WS-PY TO EN-Y(L-ROW)
         MOVE WS-PZ TO EN-Z(L-ROW)
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.99
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.99 - 0.05
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.99
         COMPUTE WS-H = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
         IF WS-H > 0
             COMPUTE WS-PITCH = FUNCTION ATAN(EN-VY(L-ROW) / WS-H) * 180 / FUNCTION PI
             MOVE WS-PITCH TO EN-PITCH(L-ROW)
         END-IF
     END-IF
     IF FUNCTION ABS(EN-X(L-ROW) - EN-WAY-X(L-ROW)) >= WS-STEP OR FUNCTION ABS(EN-Y(L-ROW) - EN-FLEE-X(L-ROW)) >= WS-STEP
             OR FUNCTION ABS(EN-Z(L-ROW) - EN-WAY-Z(L-ROW)) >= WS-STEP
         IF WS-READY = 0
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             MOVE 1 TO WS-READY
         END-IF
         CALL "PB-RESET" USING PB-BUFFER
         CALL "TELEPORT-ENTITY-BUILD" USING EN-ID(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) EN-VX(L-ROW) EN-VY(L-ROW)
             EN-VZ(L-ROW) EN-YAW(L-ROW) EN-PITCH(L-ROW) EN-ON-GROUND(L-ROW) PB-BUFFER
         CALL "GI-VIEWERS-SEND" USING L-ROW PB-BUFFER
         MOVE EN-X(L-ROW) TO EN-WAY-X(L-ROW)
         MOVE EN-Y(L-ROW) TO EN-FLEE-X(L-ROW)
         MOVE EN-Z(L-ROW) TO EN-WAY-Z(L-ROW)
         CALL "ENTITY-TRACK" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM ARROW-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ARROWS-TICK.
*> No parameters (CORE-TICK, after the orbs): ARROW-STEP for every arrow in a loaded chunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-TYPE                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "ARROW-TYPE" USING WS-TYPE
     IF WS-TYPE = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE
             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-E) / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-E) / 16)
             CALL "WORLD-FIND" USING EN-DIM(WS-E) WS-CX WS-CZ WS-CHUNK
             IF WS-CHUNK > 0
                 CALL "ARROW-STEP" USING WS-E
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ARROWS-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-SEES.
*> USING dim, x1 y1 z1 (the eye of the looker), x2 y2 z2 (the eye of the target) (FLOAT-LONG), sees out (BINARY-LONG): 1 when no solid cell lies on the
*> segment (18 Sensing.hasLineOfSight: a collider ray cast between the eyes, fluids ignored). Approximation (open): samples every 0.1 block against
*> whole solid cells, not an exact voxel traversal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X1                   FLOAT-LONG.
 01 L-Y1                   FLOAT-LONG.
 01 L-Z1                   FLOAT-LONG.
 01 L-X2                   FLOAT-LONG.
 01 L-Y2                   FLOAT-LONG.
 01 L-Z2                   FLOAT-LONG.
 01 L-SEES                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X1 L-Y1 L-Z1 L-X2 L-Y2 L-Z2 L-SEES.
     MOVE 1 TO L-SEES
     COMPUTE WS-D = FUNCTION SQRT((L-X2 - L-X1) * (L-X2 - L-X1) + (L-Y2 - L-Y1) * (L-Y2 - L-Y1) + (L-Z2 - L-Z1) * (L-Z2 - L-Z1))
     COMPUTE WS-N = FUNCTION INTEGER(WS-D * 10) + 1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I >= WS-N OR L-SEES = 0
         COMPUTE WS-T = WS-I / WS-N
         COMPUTE WS-CX = FUNCTION INTEGER(L-X1 + (L-X2 - L-X1) * WS-T)
         COMPUTE WS-CY = FUNCTION INTEGER(L-Y1 + (L-Y2 - L-Y1) * WS-T)
         COMPUTE WS-CZ = FUNCTION INTEGER(L-Z1 + (L-Z2 - L-Z1) * WS-T)
         CALL "GI-SOLID-CELL" USING L-DIM WS-CX WS-CY WS-CZ WS-SOLID
         IF WS-SOLID = 1
             MOVE 0 TO L-SEES
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-SEES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SHOOT.
*> USING tracker row, table row of a bow mob (SM-RANGED 1), stop out (BINARY-LONG): the bow goal (20 section 5). With a target the seeTime (EN-SWELL) grows by 1
*> a tick (the line of sight is not tested yet: open); within 15 blocks and with seeTime 20 the mob stands still (stop 1; strafing is open). Without a
*> target the goal resets. attackTime (EN-SHOOT-TIME) falls by 1 a tick while the bow is not drawn and at 0 the bow is drawn (EN-DRAW = 1 + ticks used);
*> after 20 ticks the arrow is released with power 1 and attackTime becomes the interval (40, 20 on Hard).
*> The shot: arrow at the eyes - 0.1 (feet + 1.64), speed 1.6, aimed at a third of the target's height with the vertical part plus 0.2 x the horizontal
*> distance, each component varied by triangle(0, 0.0172275 x (14 - 4 x difficulty)); base damage 2.0 + triangle(0.11 x difficulty, 0.57425).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY BRWORLD.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-INACC               FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 6.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-INTERVAL            BINARY-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-SPD                 FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-STOP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-STOP.
     MOVE 0 TO L-STOP
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P = 0
         MOVE 0 TO EN-SWELL(L-ROW) EN-DRAW(L-ROW)
         GOBACK
     END-IF
     COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
     COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
     COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
*>   Step 1: sees = line of sight between the eyes (skeleton eye feet + 1.74, player eye feet + 1.62); a change of sees resets seeTime to 0 first.
     COMPUTE WS-AX = EN-X(L-ROW)
     COMPUTE WS-AY = EN-Y(L-ROW) + 1.74
     COMPUTE WS-AZ = EN-Z(L-ROW)
     COMPUTE WS-TY = PL-Y(WS-P) + 1.62
     CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ PL-X(WS-P) WS-TY PL-Z(WS-P) WS-SEES
     IF (WS-SEES = 1 AND EN-SWELL(L-ROW) <= 0) OR (WS-SEES = 0 AND EN-SWELL(L-ROW) > 0)
         MOVE 0 TO EN-SWELL(L-ROW)
     END-IF
     IF WS-SEES = 1
         ADD 1 TO EN-SWELL(L-ROW)
     ELSE
         SUBTRACT 1 FROM EN-SWELL(L-ROW)
     END-IF
*>   Steps 2 to 4: in range with seeTime 20 it stands and strafes, else it paths to the target.
     MOVE 0 TO EN-STRAFE-X(L-ROW) EN-STRAFE-Z(L-ROW)
     IF WS-D2 <= 225 AND EN-SWELL(L-ROW) >= 20
         MOVE 1 TO L-STOP
         ADD 1 TO EN-STRAFE-TIME(L-ROW)
     ELSE
         MOVE -1 TO EN-STRAFE-TIME(L-ROW)
     END-IF
     IF EN-STRAFE-TIME(L-ROW) >= 20
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
         IF WS-R1 < 300
             COMPUTE EN-STRAFE-CW(L-ROW) = 1 - EN-STRAFE-CW(L-ROW)
         END-IF
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
         IF WS-R1 < 300
             COMPUTE EN-STRAFE-BACK(L-ROW) = 1 - EN-STRAFE-BACK(L-ROW)
         END-IF
         MOVE 0 TO EN-STRAFE-TIME(L-ROW)
     END-IF
     IF EN-STRAFE-TIME(L-ROW) > -1
         IF WS-D2 > 168.75
             MOVE 0 TO EN-STRAFE-BACK(L-ROW)
         ELSE
             IF WS-D2 < 56.25
                 MOVE 1 TO EN-STRAFE-BACK(L-ROW)
             END-IF
         END-IF
*>       Forward +-0.5 along the facing (to the target), sideways +-0.5 to its right (facing (dx, dz) the right is (-dz, dx)).
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
         IF WS-H > 0
             COMPUTE WS-SPD = SM-WALK-MILLI(L-M) / 1000 * 0.5
             COMPUTE WS-FX = WS-DX / WS-H
             COMPUTE WS-FZ = WS-DZ / WS-H
             IF EN-STRAFE-BACK(L-ROW) = 1
                 COMPUTE WS-FX = 0 - WS-FX
                 COMPUTE WS-FZ = 0 - WS-FZ
             END-IF
             COMPUTE WS-SX = 0 - WS-DZ / WS-H
             COMPUTE WS-SZ = WS-DX / WS-H
             IF EN-STRAFE-CW(L-ROW) = 0
                 COMPUTE WS-SX = 0 - WS-SX
                 COMPUTE WS-SZ = 0 - WS-SZ
             END-IF
             COMPUTE EN-STRAFE-X(L-ROW) = (WS-FX + WS-SX) * WS-SPD
             COMPUTE EN-STRAFE-Z(L-ROW) = (WS-FZ + WS-SZ) * WS-SPD
         END-IF
     END-IF
     IF EN-DRAW(L-ROW) > 0
         ADD 1 TO EN-DRAW(L-ROW)
         IF WS-SEES = 0 AND EN-SWELL(L-ROW) < -60
             MOVE 0 TO EN-DRAW(L-ROW)
         END-IF
         IF EN-DRAW(L-ROW) > 21 AND WS-SEES = 1
             MOVE EN-DIM(L-ROW) TO WS-DIM
             MOVE EN-ID(L-ROW) TO WS-OWNER
             COMPUTE WS-AX = EN-X(L-ROW)
             COMPUTE WS-AY = EN-Y(L-ROW) + 1.64
             COMPUTE WS-AZ = EN-Z(L-ROW)
             COMPUTE WS-DY = PL-Y(WS-P) + 0.6 - WS-AY
             COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
             COMPUTE WS-DY = WS-DY + WS-H * 0.2
             COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
             COMPUTE WS-INACC = 0.0172275 * (14 - 4 * BW-DIFFICULTY)
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
             COMPUTE WS-VX = (WS-DX / WS-LEN + (WS-R1 - WS-R2) / 1000 * WS-INACC) * 1.6
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
             COMPUTE WS-VY = (WS-DY / WS-LEN + (WS-R1 - WS-R2) / 1000 * WS-INACC) * 1.6
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
             COMPUTE WS-VZ = (WS-DZ / WS-LEN + (WS-R1 - WS-R2) / 1000 * WS-INACC) * 1.6
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
             COMPUTE WS-BASE = 2000 + BW-DIFFICULTY * 110 + (WS-R1 - WS-R2) * 0.57425
             CALL "ARROW-SPAWN" USING WS-DIM WS-AX WS-AY WS-AZ WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
             MOVE 0 TO EN-DRAW(L-ROW)
             MOVE 40 TO WS-INTERVAL
             IF BW-DIFFICULTY >= 3
                 MOVE 20 TO WS-INTERVAL
             END-IF
             MOVE WS-INTERVAL TO EN-SHOOT-TIME(L-ROW)
         END-IF
     ELSE
         SUBTRACT 1 FROM EN-SHOOT-TIME(L-ROW)
         IF EN-SHOOT-TIME(L-ROW) <= 0 AND EN-SWELL(L-ROW) >= -60
             MOVE 1 TO EN-DRAW(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM STDMOB-SHOOT.
