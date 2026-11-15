*> Frog and tadpole (002-lane-mobsfull-h21; docs/protocol/19-mobs-land-friendly-and-neutral.md section 11; 44-residual-mob-questions-4-land-animals.md sections 1.4 and 10;
*> 44-residual-mob-questions-x2-continuation.md section 7.3).
*> - Tadpole: EN-TAD-AGE counts up by 1 a tick unless the age is locked (EN-LOCKED); at 24000 it becomes a frog at its position (TADPOLE-GROW). A slime ball (item tag frog_food) adds
*>   20 x (int)((ticksLeft / 20) x 0.1) ticks with ticksLeft = max(0, 24000 - age) and is used up; a golden dandelion toggles the lock (locking sets the age to 0), a locked tadpole is not fed.
*> - Frog tongue (ShootTongue): a slime or magma cube of size 1 (a cube of any other size is never food) within TONGUE-RANGE blocks becomes the tongue target (metadata 19, entity id + 1);
*>   the frog walks to it at its walk speed; below 1.75 blocks the target is pulled toward the frog (speed 0.75) and the 6-tick catch animation starts; after it the frog eats the target
*>   (10 damage, the attack damage of the frog) and the animation ends when its timer reaches 10; the target is dropped when it is gone or dead.
*> Open items: the range of the frog's attackable sensor (the docs give none; the follow range 16 stands in), the unreachable-target memory, variants by biome, the long jump, croaking,
*>   frogspawn laying and hatching, the froglight loot rule (the loot context has no frog attacker), the bucket, the tadpole's brain (it strolls like the other water animals).
*>
*> Entry points:
*>   TADPOLE-GROW USING row                    the tadpole row becomes a frog at the same place
*>   TADPOLE-TICK USING row, gone out          one tick of a tadpole; gone is 1 when it became a frog
*>   MOB-TADPOLE-USE USING player row, row     the main hand on a tadpole (slime ball, golden dandelion)
*>   FROG-TICK USING row, hx, hz, walk out     one tick of the frog's tongue; walk is 1 when hx and hz are this tick's walk

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TADPOLE-GROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:frog".
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-FROG                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     CALL "MOB-SPAWN" USING EN-DIM(L-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-FROG
     CALL "ENTITY-REMOVE" USING L-ROW
     GOBACK.
 END PROGRAM TADPOLE-GROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TADPOLE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-GONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-GONE.
     MOVE 0 TO L-GONE
     IF EN-LOCKED(L-ROW) = 0
         ADD 1 TO EN-TAD-AGE(L-ROW)
         IF EN-TAD-AGE(L-ROW) >= 24000
             CALL "TADPOLE-GROW" USING L-ROW
             MOVE 1 TO L-GONE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TADPOLE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-TADPOLE-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY48               PIC X(48).
 01 WS-LEFT                BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-SECONDS             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ENTITY.
     MOVE SPACES TO WS-KEY48
     IF PL-SLOT-COUNT(L-ROW, PL-HELD(L-ROW) + 1) > 0
         CALL "TOOLUSE-KEY" USING PL-SLOT-ITEM(L-ROW, PL-HELD(L-ROW) + 1) WS-KEY48
     END-IF
     EVALUATE TRUE
         WHEN WS-KEY48 = "golden_dandelion"
             COMPUTE EN-LOCKED(L-ENTITY) = 1 - EN-LOCKED(L-ENTITY)
             IF EN-LOCKED(L-ENTITY) = 1
                 MOVE 0 TO EN-TAD-AGE(L-ENTITY)
             END-IF
             CALL "MOB-DATA-SEND" USING L-ENTITY
         WHEN WS-KEY48 = "slime_ball" AND EN-LOCKED(L-ENTITY) = 0
             CALL "MOB-TAKE" USING L-ROW
             COMPUTE WS-LEFT = FUNCTION MAX(0, 24000 - EN-TAD-AGE(L-ENTITY))
             COMPUTE WS-STEPS = WS-LEFT / 20
             COMPUTE WS-SECONDS = FUNCTION INTEGER-PART(WS-STEPS * 0.1)
*>           The gain is at most a tenth of what is left, so a feeding never reaches 24000 itself.
             COMPUTE EN-TAD-AGE(L-ENTITY) = EN-TAD-AGE(L-ENTITY) + 20 * WS-SECONDS
     END-EVALUATE
     GOBACK.
 END PROGRAM MOB-TADPOLE-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FROG-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY RULES.
 01 WS-M                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 10.
 01 WS-NO-ATTACKER         BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
*>   No tongue target yet: the nearest slime or magma cube of size 1 within 16 blocks.
     IF EN-TONGUE(L-ROW) = 0
         MOVE 256 TO WS-BEST
         MOVE 0 TO WS-T
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0 AND EN-PLAYER(WS-E) = 0
                     AND EN-VARIANT(WS-E) <= 1
                 CALL "MOB-SPECIES-KEY" USING WS-E WS-KEY
                 IF WS-KEY = "slime" OR WS-KEY = "magma_cube"
                     COMPUTE WS-DX = EN-X(WS-E) - EN-X(L-ROW)
                     COMPUTE WS-DY = EN-Y(WS-E) - EN-Y(L-ROW)
                     COMPUTE WS-DZ = EN-Z(WS-E) - EN-Z(L-ROW)
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                     IF WS-D2 <= WS-BEST
                         MOVE WS-D2 TO WS-BEST
                         MOVE WS-E TO WS-T
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-T > 0
             MOVE 1 TO EN-TONGUE(L-ROW)
             MOVE 0 TO EN-TONGUE-T(L-ROW)
             MOVE WS-T TO EN-TONGUE-ROW(L-ROW)
             MOVE EN-ID(WS-T) TO EN-TONGUE-ID(L-ROW)
             CALL "MOB-DATA-SEND" USING L-ROW
         END-IF
     END-IF
     IF EN-TONGUE(L-ROW) = 0
         GOBACK
     END-IF
     MOVE EN-TONGUE-ROW(L-ROW) TO WS-T
     COMPUTE WS-DX = EN-X(L-ROW) - EN-X(WS-T)
     COMPUTE WS-DY = EN-Y(L-ROW) - EN-Y(WS-T)
     COMPUTE WS-DZ = EN-Z(L-ROW) - EN-Z(WS-T)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     EVALUATE TRUE
*>       Moving to the target: one that is gone, replaced or dead ends the tongue.
         WHEN EN-TONGUE(L-ROW) = 1 AND (EN-USED(WS-T) NOT = 1 OR EN-ID(WS-T) NOT = EN-TONGUE-ID(L-ROW) OR EN-HEALTH(WS-T) = 0)
             MOVE 0 TO EN-TONGUE(L-ROW) EN-TONGUE-ROW(L-ROW) EN-TONGUE-ID(L-ROW)
             CALL "MOB-DATA-SEND" USING L-ROW
         WHEN EN-TONGUE(L-ROW) = 1 AND WS-D2 < 3.0625
*>           Pulled toward the frog with speed 0.75.
             COMPUTE WS-LEN = FUNCTION SQRT(WS-D2)
             COMPUTE EN-VX(WS-T) = WS-DX / WS-LEN * 0.75
             COMPUTE EN-VY(WS-T) = WS-DY / WS-LEN * 0.75
             COMPUTE EN-VZ(WS-T) = WS-DZ / WS-LEN * 0.75
             MOVE 2 TO EN-TONGUE(L-ROW)
             MOVE 0 TO EN-TONGUE-T(L-ROW)
         WHEN EN-TONGUE(L-ROW) = 1
             COMPUTE WS-GX = FUNCTION INTEGER(EN-X(WS-T))
             COMPUTE WS-GY = FUNCTION INTEGER(EN-Y(WS-T))
             COMPUTE WS-GZ = FUNCTION INTEGER(EN-Z(WS-T))
             CALL "STDMOB-HEAD" USING L-ROW WS-M WS-GX WS-GY WS-GZ L-HX L-HZ WS-ARRIVED
             MOVE 1 TO L-WALK
         WHEN EN-TONGUE(L-ROW) = 2
             ADD 1 TO EN-TONGUE-T(L-ROW)
             IF EN-TONGUE-T(L-ROW) >= 6
                 MOVE 3 TO EN-TONGUE(L-ROW)
                 IF EN-USED(WS-T) = 1 AND EN-ID(WS-T) = EN-TONGUE-ID(L-ROW) AND EN-HEALTH(WS-T) > 0
                     CALL "HEALTH-MOB-DAMAGE" USING WS-T WS-AMOUNT CAUSE-GENERIC WS-NO-ATTACKER
                 END-IF
             END-IF
         WHEN EN-TONGUE-T(L-ROW) >= 10
             MOVE 0 TO EN-TONGUE(L-ROW) EN-TONGUE-ROW(L-ROW) EN-TONGUE-ID(L-ROW)
             CALL "MOB-DATA-SEND" USING L-ROW
         WHEN OTHER
             ADD 1 TO EN-TONGUE-T(L-ROW)
     END-EVALUATE
     GOBACK.
 END PROGRAM FROG-TICK.
