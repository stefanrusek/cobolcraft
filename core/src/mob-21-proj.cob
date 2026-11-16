*> Generic projectile entities of the Nether and End mobs (002-lane-mobsfull-h19; docs/protocol/44 part 8 sections 6.4 and 6.5, 21 sections 5.1, 5.2, 6.2,
*> 19 section 20, 17 section 3.15). A projectile is a tracker row of the standard entity type of its kind: 1 fireball (the ghast's large fireball), 2 small_fireball
*> (the blaze's), 3 snowball (the snow golem's), 4 shulker_bullet, 5 llama_spit (the llama's, M44-LLAMA-SPIT). EN-ITEM holds the explosion power of a large fireball, EN-TARGET-ID the entity id of the owner
*> (0 none), EN-COOLDOWN the ticks flown (the hit margin of ARROW-FIND-HIT, which this file shares with the arrows), EN-WAY-X, EN-FLEE-X and EN-WAY-Z the position the
*> viewers were last told. The kind is found from the entity type (PROJ-KIND); no kind is stored.
*> Motion (44 part 8): a fireball starts at 0.1 along its direction and each tick v = (v + normalize(v) x 0.1) x 0.95 (the thrust accelerationPower 0.1 and the
*> inertia 0.95), the hit test follows the new velocity; a snowball takes gravity 0.03 then drag 0.99. The segment of a tick is tested in steps of at most 0.1 block
*> against solid cells and against the boxes of players and standard mobs other than the owner (ARROW-FIND-HIT).
*> Hits (every hit discards the projectile): a large fireball hurts the entity it meets for 6 and explodes with its power (EXPLODE-RUN at the last free point; blocks
*> go only with the game rule mob_griefing); a small fireball hurts for 5 and sets a mob on fire for 5 seconds (EN-BURN 100), and on a block, with an owner that is a
*> mob and mob_griefing on, puts a fire block in the free cell in front of the face; a snowball hurts a blaze for 3 and anything else for 0.
*> Approximations (open): water inertia 0.8 and bubbles, deflection by a player's hit (the reflected fireball of 21 section 5.1), setting a player on fire (the core has
*> no burning player), restoring the fire ticks when the hurt fails, the damage types fireball and thrown (a player hit by a projectile is hurt with CAUSE-MOB), the
*> shoot uncertainty of a snowball (0 here), block hits by sample steps and not an exact voxel clip.
*> A fireball whose owner entity is gone, or whose chunk is not loaded, is discarded by PROJECTILES-TICK (44 part 8 section 6.4 step 2).
*>
*> Entry points:
*>   PROJ-TYPE USING kind, type id out                      the entity type id of a kind (0 outside a standard world)
*>   PROJ-KIND USING type id, kind out                      the kind of an entity type, 0 for none
*>   PROJ-SPAWN USING kind, dim, x, y, z, dx, dy, dz (FLOAT-LONG, the direction), power, owner entity id, row out
*>   PROJ-HIT USING projectile row, entity row, player row, x, y, z (the last free point)      the hit of an entity (one of the rows 0)
*>   PROJ-STEP USING projectile row                         one tick
*>   PROJECTILES-TICK                                       every projectile (CORE-TICK, after the arrows)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEYS.
    05 FILLER              PIC X(112) VALUE "minecraft:fireball".
    05 FILLER              PIC X(112) VALUE "minecraft:small_fireball".
    05 FILLER              PIC X(112) VALUE "minecraft:snowball".
    05 FILLER              PIC X(112) VALUE "minecraft:shulker_bullet".
    05 FILLER              PIC X(112) VALUE "minecraft:llama_spit".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-KEY              PIC X(112) OCCURS 5 TIMES.
 01 WS-IDS.
    05 WS-ID               BINARY-LONG OCCURS 5 TIMES VALUE 0.
 01 WS-LOADED              BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-TYPE.
     MOVE 0 TO L-TYPE
     IF CT-OPEN = 0 OR CT-SET-TYPE = CT-TYPE-COBOLCRAFT OR CT-SET-TYPE = CT-TYPE-DEBUG
         GOBACK
     END-IF
     IF WS-LOADED = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY(WS-I) WS-ID(WS-I) WS-ROW WS-STATUS
         END-PERFORM
         MOVE 1 TO WS-LOADED
     END-IF
     MOVE WS-ID(L-KIND) TO L-TYPE
     GOBACK.
 END PROGRAM PROJ-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-KIND.
     MOVE 0 TO L-KIND
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
         CALL "PROJ-TYPE" USING WS-K WS-TYPE
         IF WS-TYPE > 0 AND WS-TYPE = L-TYPE
             MOVE WS-K TO L-KIND
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PROJ-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-OWNER.
*> USING projectile row, owner row out: the tracker row of the owner entity (EN-TARGET-ID), 0 when it has none or is gone.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-E                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-OWNER.
     MOVE 0 TO L-OWNER
     IF EN-TARGET-ID(L-ROW) > 0
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = EN-TARGET-ID(L-ROW)
                 MOVE WS-E TO L-OWNER
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PROJ-OWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-ROTATE.
*> USING projectile row: yaw and pitch along the velocity (protocol yaw as MOB-YAW-TOWARD, pitch positive downward).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-H                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-YAW(L-ROW) TO WS-YAW
     CALL "MOB-YAW-TOWARD" USING EN-VX(L-ROW) EN-VZ(L-ROW) WS-YAW
     MOVE WS-YAW TO EN-YAW(L-ROW)
     COMPUTE WS-H = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
     IF WS-H > 0
         COMPUTE EN-PITCH(L-ROW) = 0 - FUNCTION ATAN(EN-VY(L-ROW) / WS-H) * 180 / FUNCTION PI
     END-IF
     GOBACK.
 END PROGRAM PROJ-ROTATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-POWER                BINARY-LONG.
 01 L-OWNER                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
*> USING kind, dim, x, y, z, dx, dy, dz, power, owner entity id, row out: a projectile of that kind flying along (dx, dy, dz) (not zero): a fireball starts at 0.1, a
*> snowball at 1.6, a shulker bullet at rest.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-DX L-DY L-DZ L-POWER L-OWNER L-ROW.
     CALL "PROJ-TYPE" USING L-KIND WS-TYPE
     CALL "ENTITY-ALLOC" USING WS-ROW
     CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
     MOVE WS-TYPE TO EN-TYPE(WS-ROW)
     CALL "ENTITY-SET-UUID" USING WS-ROW
     MOVE L-DIM TO EN-DIM(WS-ROW)
     MOVE L-X TO EN-X(WS-ROW) EN-WAY-X(WS-ROW)
     MOVE L-Y TO EN-Y(WS-ROW) EN-FLEE-X(WS-ROW)
     MOVE L-Z TO EN-Z(WS-ROW) EN-WAY-Z(WS-ROW)
     MOVE L-POWER TO EN-ITEM(WS-ROW)
     MOVE L-OWNER TO EN-TARGET-ID(WS-ROW)
     EVALUATE L-KIND
         WHEN 1
         WHEN 2
             MOVE 0.1 TO WS-SPEED
         WHEN 3
             MOVE 1.6 TO WS-SPEED
         WHEN 5
             MOVE 1.5 TO WS-SPEED
         WHEN OTHER
*>           A shulker bullet starts at rest (BULLET-SELECT sets its aim).
             MOVE 0 TO WS-SPEED
     END-EVALUATE
     COMPUTE WS-LEN = FUNCTION SQRT(L-DX * L-DX + L-DY * L-DY + L-DZ * L-DZ)
     COMPUTE EN-VX(WS-ROW) = L-DX / WS-LEN * WS-SPEED
     COMPUTE EN-VY(WS-ROW) = L-DY / WS-LEN * WS-SPEED
     COMPUTE EN-VZ(WS-ROW) = L-DZ / WS-LEN * WS-SPEED
     CALL "PROJ-ROTATE" USING WS-ROW
     CALL "ENTITY-TRACK" USING WS-ROW
     MOVE WS-ROW TO L-ROW
     GOBACK.
 END PROGRAM PROJ-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-HIT.
*> USING projectile row, entity row, player row (one of them 0), x, y, z (FLOAT-LONG, the last free point): the hit of a player or a standard mob, by kind. The damage is
*> 6 (large fireball), 5 (small fireball), 4 (shulker bullet, which also gives a player Levitation for 200 ticks), 0 (snowball, 3 on a blaze); a player is hurt through HEALTH-HURT with CAUSE-MOB (the owner's name for the death message), a mob
*> in whole points through HEALTH-MOB-DAMAGE; a small fireball sets a mob burning for 100 ticks; a large fireball explodes at the point (EXPLODE-RUN, blocks only with
*> mob_griefing). The projectile is removed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-LEVITATION          BINARY-LONG VALUE 24.
 01 WS-AMPLIFIER           BINARY-LONG VALUE 0.
 01 WS-DURATION            BINARY-LONG VALUE 200.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-KIND                BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-MOB.
 01 WS-OWNER-ID            BINARY-LONG.
 01 WS-OWNER-ROW           BINARY-LONG.
 01 WS-OWNER-PLAYER        BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-POWER               FLOAT-LONG.
 01 WS-DESTROY             BINARY-LONG.
 01 WS-GRIEF-RULE          PIC X(40) VALUE "mob_griefing".
 01 WS-GRIEF               BINARY-DOUBLE.
 01 WS-SOURCE              BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY L-PLAYER L-X L-Y L-Z.
     CALL "PROJ-KIND" USING EN-TYPE(L-ROW) WS-KIND
     MOVE EN-TARGET-ID(L-ROW) TO WS-OWNER-ID
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE 0 TO WS-DAMAGE WS-OWNER-PLAYER
     EVALUATE WS-KIND
         WHEN 1
             MOVE 6 TO WS-DAMAGE
         WHEN 2
             MOVE 5 TO WS-DAMAGE
         WHEN 4
             MOVE 4 TO WS-DAMAGE
         WHEN 5
*>           The llama's spit hurts by 1 (21 section 8.14).
             MOVE 1 TO WS-DAMAGE
         WHEN 3
*>           The snowball hurts a blaze for 3 and nothing else (17 section 3.15).
             IF L-ENTITY > 0
                 CALL "STDMOB-INDEX" USING EN-TYPE(L-ENTITY) WS-M
                 IF SM-KEY(WS-M) = "blaze"
                     MOVE 3 TO WS-DAMAGE
                 END-IF
             END-IF
     END-EVALUATE
     CALL "PROJ-OWNER" USING L-ROW WS-OWNER-ROW
     IF WS-DAMAGE > 0
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
             IF WS-KIND = 4
                 CALL "EFFECT-ADD" USING L-PLAYER WS-LEVITATION WS-AMPLIFIER WS-DURATION WS-FLAGS
             END-IF
         ELSE
             MOVE 0 TO EN-HURT(L-ENTITY)
             CALL "HEALTH-MOB-DAMAGE" USING L-ENTITY WS-DAMAGE WS-CAUSE WS-OWNER-PLAYER
             IF WS-KIND = 2
                 MOVE 100 TO EN-BURN(L-ENTITY)
             END-IF
         END-IF
     END-IF
     MOVE EN-ITEM(L-ROW) TO WS-POWER
     CALL "ENTITY-REMOVE" USING L-ROW
     IF WS-KIND = 1
         CALL "BR-RULE-GET" USING WS-GRIEF-RULE WS-GRIEF
         MOVE WS-GRIEF TO WS-DESTROY
         CALL "EXPLODE-RUN" USING WS-DIM L-X L-Y L-Z WS-POWER WS-DESTROY WS-SOURCE
     END-IF
     GOBACK.
 END PROGRAM PROJ-HIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-BLOCK.
*> USING projectile row, x, y, z (FLOAT-LONG, the last free point before the solid cell): the hit of a block. A large fireball explodes there (power EN-ITEM, blocks only
*> with mob_griefing); a small fireball whose owner is a mob, with mob_griefing on, puts a fire block in that cell when it is air; the projectile is removed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-OWNER-ROW           BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-POWER               FLOAT-LONG.
 01 WS-DESTROY             BINARY-LONG.
 01 WS-GRIEF-RULE          PIC X(40) VALUE "mob_griefing".
 01 WS-GRIEF               BINARY-DOUBLE.
 01 WS-SOURCE              BINARY-LONG VALUE 0.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FIRE-KEY            PIC X(112) VALUE "minecraft:fire".
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-FIRE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     CALL "PROJ-KIND" USING EN-TYPE(L-ROW) WS-KIND
     CALL "PROJ-OWNER" USING L-ROW WS-OWNER-ROW
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE 0 TO WS-M
     IF WS-OWNER-ROW > 0
         CALL "STDMOB-INDEX" USING EN-TYPE(WS-OWNER-ROW) WS-M
     END-IF
     CALL "BR-RULE-GET" USING WS-GRIEF-RULE WS-GRIEF
     MOVE WS-GRIEF TO WS-DESTROY
     MOVE EN-ITEM(L-ROW) TO WS-POWER
     CALL "ENTITY-REMOVE" USING L-ROW
     IF WS-KIND = 1
         CALL "EXPLODE-RUN" USING WS-DIM L-X L-Y L-Z WS-POWER WS-DESTROY WS-SOURCE
     END-IF
     IF WS-KIND = 2 AND WS-M > 0 AND WS-DESTROY = 1
         COMPUTE WS-CX = FUNCTION INTEGER(L-X)
         COMPUTE WS-CY = FUNCTION INTEGER(L-Y)
         COMPUTE WS-CZ = FUNCTION INTEGER(L-Z)
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-CX WS-CY WS-CZ WS-STATE
         IF WS-STATE = 0
             IF WS-FIRE = 0
                 CALL "CONTENT-BLOCK-BY-KEY" USING WS-FIRE-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
                 MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
                 COMPUTE WS-FIRE = FUNCTION NUMVAL(WS-STATE-TEXT)
             END-IF
             CALL "BLOCK-CHANGE" USING WS-DIM WS-CX WS-CY WS-CZ WS-FIRE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PROJ-BLOCK.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. BULLET-TARGET.
*> USING bullet row, player row out: the player the bullet homes on (EN-FOE-ID is its entity id): alive, in the bullet's dimension and not a spectator; 0 when there is none
*> (EN-FOE-ID is then cleared).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER.
     MOVE 0 TO L-PLAYER
     IF EN-FOE-ID(L-ROW) > 0
         PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
             IF PL-USED(WS-P) = 1 AND PL-ENTITY-ID(WS-P) = EN-FOE-ID(L-ROW) AND PL-STATE(WS-P) = PS-ALIVE
                     AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND PL-MODE(WS-P) NOT = 3
                 MOVE WS-P TO L-PLAYER
             END-IF
         END-PERFORM
         IF L-PLAYER = 0
             MOVE 0 TO EN-FOE-ID(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BULLET-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BULLET-AIM.
*> USING bullet row: the velocity of a shulker bullet for this tick (44 part 9 section 11.2). EN-FOE-ID is the target player's entity id, EN-VARIANT the current move direction (0 none, 1 DOWN,
*> 2 UP, 3 NORTH, 4 SOUTH, 5 WEST, 6 EAST), EN-DELAY flightSteps, EN-WANDER-X, EN-FLEE-Z and EN-WANDER-Z targetDelta. With a target each targetDelta component becomes
*> clamp(d x 1.025, -1, 1) and the velocity moves a fifth of the way to it; without one the bullet takes gravity (0.04: the default of the class, open).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "BULLET-TARGET" USING L-ROW WS-P
     IF WS-P > 0
         COMPUTE EN-WANDER-X(L-ROW) = FUNCTION MAX(-1, FUNCTION MIN(1, EN-WANDER-X(L-ROW) * 1.025))
         COMPUTE EN-FLEE-Z(L-ROW) = FUNCTION MAX(-1, FUNCTION MIN(1, EN-FLEE-Z(L-ROW) * 1.025))
         COMPUTE EN-WANDER-Z(L-ROW) = FUNCTION MAX(-1, FUNCTION MIN(1, EN-WANDER-Z(L-ROW) * 1.025))
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + (EN-WANDER-X(L-ROW) - EN-VX(L-ROW)) * 0.2
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + (EN-FLEE-Z(L-ROW) - EN-VY(L-ROW)) * 0.2
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + (EN-WANDER-Z(L-ROW) - EN-VZ(L-ROW)) * 0.2
     ELSE
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) - 0.04
     END-IF
     GOBACK.
 END PROGRAM BULLET-AIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BULLET-SELECT.
*> USING bullet row, axis (BINARY-LONG: 0 none, 1 X, 2 Y, 3 Z): selectNextMoveDirection (44 part 9 section 11.2). T is the block of the target player's position + 0.9 in y; within 2.0 of
*> its centre the direction stays none and the aim is the point (T.x + 0.5, T.y + 0.9, T.z + 0.5). Else the candidates are, for each axis other than the given one in the order X, Y, Z,
*> the positive direction when the bullet's block coordinate is below T's and the cell beyond is air, else the negative when it is above and that cell is air. One direction is always
*> drawn (nextInt(6), the order DOWN, UP, NORTH, SOUTH, WEST, EAST); with no candidates it is redrawn up to 5 times while the cell it names is not air, else the direction is the candidate
*> nextInt(count). The aim is the bullet's position plus the step of the direction; targetDelta is the unit vector to the aim x 0.15; flightSteps is 10 + nextInt(5) x 10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 75.
 01 WS-B6                  BINARY-LONG VALUE 6.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-P                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCKS.
    05 WS-BP               BINARY-LONG OCCURS 3 TIMES.
 01 WS-TARGET-BLOCKS.
    05 WS-TB               BINARY-LONG OCCURS 3 TIMES.
 01 WS-CANDIDATES.
    05 WS-CAND             BINARY-LONG OCCURS 3 TIMES.
 01 WS-POS-DIRS.
    05 FILLER              BINARY-LONG VALUE 6.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 4.
 01 WS-POS-TABLE REDEFINES WS-POS-DIRS.
    05 WS-POS-DIR          BINARY-LONG OCCURS 3 TIMES.
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
    05 WS-STEP-OF OCCURS 6 TIMES.
       10 WS-SX            BINARY-LONG.
       10 WS-SY            BINARY-LONG.
       10 WS-SZ            BINARY-LONG.
 01 WS-DIST2               FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-CENTER-X            FLOAT-LONG.
 01 WS-CENTER-Y            FLOAT-LONG.
 01 WS-CENTER-Z            FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AXIS.
     CALL "BULLET-TARGET" USING L-ROW WS-P
     COMPUTE WS-BP(1) = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BP(2) = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BP(3) = FUNCTION INTEGER(EN-Z(L-ROW))
     COMPUTE WS-TB(1) = FUNCTION INTEGER(PL-X(WS-P))
     COMPUTE WS-TB(2) = FUNCTION INTEGER(PL-Y(WS-P) + 0.9)
     COMPUTE WS-TB(3) = FUNCTION INTEGER(PL-Z(WS-P))
     COMPUTE WS-CENTER-X = WS-TB(1) + 0.5
     COMPUTE WS-CENTER-Y = WS-TB(2) + 0.5
     COMPUTE WS-CENTER-Z = WS-TB(3) + 0.5
     COMPUTE WS-DIST2 = (WS-CENTER-X - EN-X(L-ROW)) ** 2 + (WS-CENTER-Y - EN-Y(L-ROW)) ** 2 + (WS-CENTER-Z - EN-Z(L-ROW)) ** 2
     MOVE 0 TO WS-DIR
     IF WS-DIST2 < 4
         MOVE WS-CENTER-X TO WS-AX
         COMPUTE WS-AY = WS-TB(2) + 0.9
         MOVE WS-CENTER-Z TO WS-AZ
     ELSE
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-A FROM 1 BY 1 UNTIL WS-A > 3
             IF WS-A NOT = L-AXIS
                 MOVE WS-POS-DIR(WS-A) TO WS-DIR
                 IF WS-BP(WS-A) > WS-TB(WS-A)
                     COMPUTE WS-DIR = WS-DIR - 1
                 END-IF
                 IF WS-BP(WS-A) NOT = WS-TB(WS-A)
                     COMPUTE WS-CX = WS-BP(1) + WS-SX(WS-DIR)
                     COMPUTE WS-CY = WS-BP(2) + WS-SY(WS-DIR)
                     COMPUTE WS-CZ = WS-BP(3) + WS-SZ(WS-DIR)
                     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-STATE
                     IF WS-STATE = 0
                         ADD 1 TO WS-COUNT
                         MOVE WS-DIR TO WS-CAND(WS-COUNT)
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         CALL "XP-RANDOM" USING WS-SALT WS-B6 WS-R
         COMPUTE WS-DIR = WS-R + 1
         IF WS-COUNT = 0
             MOVE 5 TO WS-TRIES
             PERFORM UNTIL WS-TRIES = 0
                 COMPUTE WS-CX = WS-BP(1) + WS-SX(WS-DIR)
                 COMPUTE WS-CY = WS-BP(2) + WS-SY(WS-DIR)
                 COMPUTE WS-CZ = WS-BP(3) + WS-SZ(WS-DIR)
                 CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-STATE
                 IF WS-STATE = 0
                     MOVE 0 TO WS-TRIES
                 ELSE
                     CALL "XP-RANDOM" USING WS-SALT WS-B6 WS-R
                     COMPUTE WS-DIR = WS-R + 1
                     SUBTRACT 1 FROM WS-TRIES
                 END-IF
             END-PERFORM
         ELSE
             CALL "XP-RANDOM" USING WS-SALT WS-COUNT WS-R
             MOVE WS-CAND(WS-R + 1) TO WS-DIR
         END-IF
         COMPUTE WS-AX = EN-X(L-ROW) + WS-SX(WS-DIR)
         COMPUTE WS-AY = EN-Y(L-ROW) + WS-SY(WS-DIR)
         COMPUTE WS-AZ = EN-Z(L-ROW) + WS-SZ(WS-DIR)
     END-IF
     COMPUTE WS-LEN = FUNCTION SQRT((WS-AX - EN-X(L-ROW)) ** 2 + (WS-AY - EN-Y(L-ROW)) ** 2 + (WS-AZ - EN-Z(L-ROW)) ** 2)
     COMPUTE EN-WANDER-X(L-ROW) = (WS-AX - EN-X(L-ROW)) / WS-LEN * 0.15
     COMPUTE EN-FLEE-Z(L-ROW) = (WS-AY - EN-Y(L-ROW)) / WS-LEN * 0.15
     COMPUTE EN-WANDER-Z(L-ROW) = (WS-AZ - EN-Z(L-ROW)) / WS-LEN * 0.15
     MOVE WS-DIR TO EN-VARIANT(L-ROW)
     CALL "XP-RANDOM" USING WS-SALT WS-B5 WS-R
     COMPUTE EN-DELAY(L-ROW) = 10 + WS-R * 10
     GOBACK.
 END PROGRAM BULLET-SELECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BULLET-AXIS.
*> USING direction (0 none, 1 DOWN, 2 UP, 3 NORTH, 4 SOUTH, 5 WEST, 6 EAST), axis out (0 none, 1 X, 2 Y, 3 Z).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-AXIS.
     EVALUATE L-DIR
         WHEN 0
             MOVE 0 TO L-AXIS
         WHEN 1
         WHEN 2
             MOVE 2 TO L-AXIS
         WHEN 3
         WHEN 4
             MOVE 3 TO L-AXIS
         WHEN OTHER
             MOVE 1 TO L-AXIS
     END-EVALUATE
     GOBACK.
 END PROGRAM BULLET-AXIS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BULLET-STEER.
*> USING bullet row: after a tick's move, with a target (44 part 9 section 11.2): flightSteps counts down and at 0 BULLET-SELECT runs with the axis of the current direction; then,
*> with a direction, a solid cell next to the bullet in that direction, or the bullet already in the target's block row on that axis, runs BULLET-SELECT again at once.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-SELECT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "BULLET-TARGET" USING L-ROW WS-P
     IF WS-P = 0
         GOBACK
     END-IF
     IF EN-DELAY(L-ROW) > 0
         SUBTRACT 1 FROM EN-DELAY(L-ROW)
         IF EN-DELAY(L-ROW) = 0
             CALL "BULLET-AXIS" USING EN-VARIANT(L-ROW) WS-AXIS
             CALL "BULLET-SELECT" USING L-ROW WS-AXIS
         END-IF
     END-IF
     IF EN-VARIANT(L-ROW) > 0
         CALL "BULLET-AXIS" USING EN-VARIANT(L-ROW) WS-AXIS
         COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
         MOVE WS-BX TO WS-CX
         MOVE WS-BY TO WS-CY
         MOVE WS-BZ TO WS-CZ
         EVALUATE EN-VARIANT(L-ROW)
             WHEN 1
                 SUBTRACT 1 FROM WS-CY
             WHEN 2
                 ADD 1 TO WS-CY
             WHEN 3
                 SUBTRACT 1 FROM WS-CZ
             WHEN 4
                 ADD 1 TO WS-CZ
             WHEN 5
                 SUBTRACT 1 FROM WS-CX
             WHEN OTHER
                 ADD 1 TO WS-CX
         END-EVALUATE
         CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
         COMPUTE WS-TX = FUNCTION INTEGER(PL-X(WS-P))
         COMPUTE WS-TY = FUNCTION INTEGER(PL-Y(WS-P) + 0.9)
         COMPUTE WS-TZ = FUNCTION INTEGER(PL-Z(WS-P))
         MOVE WS-SOLID TO WS-SELECT
         IF WS-AXIS = 1 AND WS-BX = WS-TX
             MOVE 1 TO WS-SELECT
         END-IF
         IF WS-AXIS = 2 AND WS-BY = WS-TY
             MOVE 1 TO WS-SELECT
         END-IF
         IF WS-AXIS = 3 AND WS-BZ = WS-TZ
             MOVE 1 TO WS-SELECT
         END-IF
         IF WS-SELECT = 1
             CALL "BULLET-SELECT" USING L-ROW WS-AXIS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BULLET-STEER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJ-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 128.
 01 WS-STEP                FLOAT-LONG VALUE 0.000122.
 01 WS-KIND                BINARY-LONG.
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
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PROJ-KIND" USING EN-TYPE(L-ROW) WS-KIND
     ADD 1 TO EN-COOLDOWN(L-ROW)
     EVALUATE WS-KIND
         WHEN 1
         WHEN 2
*>       applyInertia: v = (v + normalize(v) x 0.1) x 0.95 (the thrust of accelerationPower 0.1).
         COMPUTE WS-SPEED = FUNCTION SQRT(EN-VX(L-ROW) * EN-VX(L-ROW) + EN-VY(L-ROW) * EN-VY(L-ROW) + EN-VZ(L-ROW) * EN-VZ(L-ROW))
         COMPUTE EN-VX(L-ROW) = (EN-VX(L-ROW) + EN-VX(L-ROW) / WS-SPEED * 0.1) * 0.95
         COMPUTE EN-VY(L-ROW) = (EN-VY(L-ROW) + EN-VY(L-ROW) / WS-SPEED * 0.1) * 0.95
         COMPUTE EN-VZ(L-ROW) = (EN-VZ(L-ROW) + EN-VZ(L-ROW) / WS-SPEED * 0.1) * 0.95
         WHEN 3
*>       Thrown: gravity 0.03, then drag 0.99.
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.99
         COMPUTE EN-VY(L-ROW) = (EN-VY(L-ROW) - 0.03) * 0.99
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.99
         WHEN 5
*>       Llama spit: drag 0.99, then gravity 0.06 (21 section 8.14).
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) * 0.99
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) * 0.99 - 0.06
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) * 0.99
         WHEN OTHER
         CALL "BULLET-AIM" USING L-ROW
     END-EVALUATE
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
         CALL "PROJ-HIT" USING L-ROW WS-ENTITY WS-PLAYER WS-PX WS-PY WS-PZ
         GOBACK
     END-IF
     IF WS-DONE = 1
         CALL "PROJ-BLOCK" USING L-ROW WS-PX WS-PY WS-PZ
         GOBACK
     END-IF
     MOVE WS-PX TO EN-X(L-ROW)
     MOVE WS-PY TO EN-Y(L-ROW)
     MOVE WS-PZ TO EN-Z(L-ROW)
     IF WS-KIND = 4
         CALL "BULLET-STEER" USING L-ROW
     END-IF
     CALL "PROJ-ROTATE" USING L-ROW
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
 END PROGRAM PROJ-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PROJECTILES-TICK.
*> No parameters (CORE-TICK, after the arrows): PROJ-STEP for every projectile in a loaded chunk; a fireball (kind 1 or 2) whose owner entity is gone or whose chunk is not
*> loaded is removed (44 part 8 section 6.4 step 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CHUNK               BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1
             CALL "PROJ-KIND" USING EN-TYPE(WS-E) WS-KIND
             IF WS-KIND > 0
                 COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-E) / 16)
                 COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-E) / 16)
                 CALL "WORLD-FIND" USING EN-DIM(WS-E) WS-CX WS-CZ WS-CHUNK
                 CALL "PROJ-OWNER" USING WS-E WS-OWNER
                 IF WS-KIND <= 2 AND (WS-CHUNK = 0 OR (EN-TARGET-ID(WS-E) > 0 AND WS-OWNER = 0))
                     CALL "ENTITY-REMOVE" USING WS-E
                 ELSE
                     IF WS-CHUNK > 0
                         CALL "PROJ-STEP" USING WS-E
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PROJECTILES-TICK.
