*> Landing rules of blocks (lane bugbounce, T61201 to T61204). Sources: docs/protocol/44-residual-mob-questions-5 section 4.3 (Entity.restituteMovementAfterCollisions), 41 section 3.3
*> (block restitution values), 24-5 (slime_block and hay_block rows, Block.fallOn default), 24-2 (beds), 44-x1 section 2.1 (honey block landing), 17 section 4.11 (the fall damage formula).
*>
*> A block's bounceRestitution: slime_block 1.0, shelf_mushroom and every <colour>_bed 0.75, every other block 0. The fall rules of fallOn: slime_block never hurts (damage multiplier 0; a
*> player who suppresses the bounce by sneaking does not get the fall damage either: the doc's method returns without calling causeFallDamage), hay_block and honey_block pass the
*> distance on with the damage multiplier 0.2, a bed and shelf_mushroom take half the fall distance (fallDistanceReduction 0.5), every other block 1 and 1.
*>
*> Entry points:
*>   BOUNCE-OF-KEY USING key (PIC X(48), with or without minecraft:), restitution out (FLOAT-LONG)
*>   FALL-ON-KEY USING key (PIC X(48)), distance factor out, damage multiplier out (FLOAT-LONG)
*>   LV-RESTITUTE USING vy (the velocity of the move, before the collision), moved y (the collided distance), restitution (block value), suppress (BINARY-LONG, 1 for a sneaking
*>     player), vy out: the vertical velocity of a living entity after a downward collision
*>   FALL-LANDING-RULE USING dim, feet x, y, z (FLOAT-LONG), distance factor out, damage multiplier out: FALL-ON-KEY of the block 0.2 below the feet (getOnPosLegacy)
*>   MOB-LAND-BOUNCE USING dim, x, y (the feet on top of the floor), z, vy (in: before the collision, out: after), moved y, legacy flag: a mob's landing

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FALL-KEY-NAME.
*> USING key (PIC X(48)), name out (PIC X(48)), length out: the key without a leading minecraft: and its length (0 for blank).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-NAME                 PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-NAME L-LENGTH.
     MOVE SPACES TO L-NAME
     MOVE 0 TO L-LENGTH
     IF L-KEY NOT = SPACES
         COMPUTE L-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(L-KEY TRAILING))
         MOVE L-KEY TO L-NAME
         IF L-LENGTH > 10 AND L-KEY(1:10) = "minecraft:"
             COMPUTE WS-REST = L-LENGTH - 10
             MOVE L-KEY(11:WS-REST) TO L-NAME
             MOVE WS-REST TO L-LENGTH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FALL-KEY-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOUNCE-OF-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NAME                PIC X(48).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-RESTITUTION          FLOAT-LONG.
 PROCEDURE DIVISION USING L-KEY L-RESTITUTION.
     CALL "FALL-KEY-NAME" USING L-KEY WS-NAME WS-LENGTH
     MOVE 0 TO L-RESTITUTION
     EVALUATE TRUE
         WHEN WS-NAME = "slime_block"
             MOVE 1 TO L-RESTITUTION
         WHEN WS-NAME = "shelf_mushroom"
             MOVE 0.75 TO L-RESTITUTION
         WHEN WS-LENGTH > 4 AND WS-NAME(WS-LENGTH - 3:4) = "_bed"
             MOVE 0.75 TO L-RESTITUTION
     END-EVALUATE
     GOBACK.
 END PROGRAM BOUNCE-OF-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FALL-ON-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RESTITUTION         FLOAT-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-FACTOR               FLOAT-LONG.
 01 L-MULTIPLIER           FLOAT-LONG.
 PROCEDURE DIVISION USING L-KEY L-FACTOR L-MULTIPLIER.
     MOVE 1 TO L-FACTOR L-MULTIPLIER
     CALL "FALL-KEY-NAME" USING L-KEY WS-NAME WS-LENGTH
     CALL "BOUNCE-OF-KEY" USING L-KEY WS-RESTITUTION
     EVALUATE TRUE
         WHEN WS-NAME = "slime_block"
             MOVE 0 TO L-MULTIPLIER
         WHEN WS-NAME = "hay_block"
         WHEN WS-NAME = "honey_block"
             MOVE 0.2 TO L-MULTIPLIER
         WHEN WS-RESTITUTION > 0
*>           The bed family and shelf_mushroom: fallDistanceReduction 0.5.
             MOVE 0.5 TO L-FACTOR
     END-EVALUATE
     GOBACK.
 END PROGRAM FALL-ON-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LV-RESTITUTE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RATIO               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VY                   FLOAT-LONG.
 01 L-MOVED                FLOAT-LONG.
 01 L-BLOCK                FLOAT-LONG.
 01 L-SUPPRESS             BINARY-LONG.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-VY L-MOVED L-BLOCK L-SUPPRESS L-RESULT.
     MOVE 0 TO L-RESULT
*>   No bounce for a slow landing (the downward speed not above the gravity 0.08), a sneaking player or a block without restitution.
     IF L-SUPPRESS = 0 AND L-BLOCK > 0 AND 0 - L-VY > 0.08
         COMPUTE WS-RATIO = L-MOVED / L-VY
         COMPUTE L-RESULT = (WS-RATIO * 0.08 - L-VY) * (1 + WS-RATIO * (0.98 - 1)) * L-BLOCK
     END-IF
     GOBACK.
 END PROGRAM LV-RESTITUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LAND-BOUNCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RESTITUTION         FLOAT-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-RESULT              FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-MOVED                FLOAT-LONG.
 01 L-LEGACY               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-VY L-MOVED L-LEGACY.
     MOVE 0 TO WS-RESULT
*>   A cobolcraft-set mob keeps the stand-in rule (standin 12.2): the landing zeroes the speed.
     IF L-LEGACY = 0 AND L-VY < 0
         CALL "IP-BOUNCINESS" USING L-DIM L-X L-Y L-Z WS-RESTITUTION
         CALL "LV-RESTITUTE" USING L-VY L-MOVED WS-RESTITUTION WS-NO WS-RESULT
     END-IF
     MOVE WS-RESULT TO L-VY
     GOBACK.
 END PROGRAM MOB-LAND-BOUNCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FALL-LANDING-RULE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-FACTOR               FLOAT-LONG.
 01 L-MULTIPLIER           FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACTOR L-MULTIPLIER.
     MOVE 1 TO L-FACTOR L-MULTIPLIER
     COMPUTE WS-CX = FUNCTION INTEGER(L-X)
     COMPUTE WS-CY = FUNCTION INTEGER(L-Y - 0.2)
     COMPUTE WS-CZ = FUNCTION INTEGER(L-Z)
     CALL "IP-BLOCK-KEY" USING L-DIM WS-CX WS-CY WS-CZ WS-KEY WS-LENGTH
     IF WS-LENGTH > 0
         CALL "FALL-ON-KEY" USING WS-KEY L-FACTOR L-MULTIPLIER
     END-IF
     GOBACK.
 END PROGRAM FALL-LANDING-RULE.
