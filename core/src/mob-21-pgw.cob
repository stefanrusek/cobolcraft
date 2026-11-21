*> The piglin's weapons (Mth.atan2 is MTH-ATAN2 of mth.cob) (docs/protocol/44-residual-mob-questions-6-nether.md sections 2.11, 5.7 and 5.8; 44-3 section 2.19 B; lane 002-lane-p49s, T38501 to T38515). A piglin holds a weapon
*> in EN-HAND (14 golden sword, 15 golden spear, 11 crossbow (the codes of the hand table of mob-20-3.cob), 1000 + an item id for anything picked up); PGBRAIN.cpy has the behaviour state (PG-SP-*, PG-XB-*, PG-USING).
*> Built: the main-hand kind (PGW-HAND-KIND), LandRandomPos.getPosAway (PGW-POS-AWAY: 10 attempts, the within-radians direction, stable and water tests, the walk-target value 0
*> of a piglin so the first survivor wins), the spawn weapon (PGW-FINALIZE: baby 0.2, else crossbow 0.5, golden spear 1/10 of the rest, else golden sword), SpearApproach, SpearAttack,
*> SpearRetreat (PGW-STEP, the start phase of every behaviour before the tick phase, as Brain.tick), BackUpIfTooClose(5, 0.75), the walk target of a crossbow user (stands within 8 when
*> it sees the target), and CrossbowAttack (PGW-STEP: UNCHARGED, CHARGING 25 ticks, CHARGED 20 + nextInt(20), READY_TO_ATTACK shoots an arrow at power 1.6, PGW-SHOOT).
*> Gaps (open): the kinetic damage a charging spear deals (17 section 3.12 gives three conditions, each with its own minimum speed, and the table lists one number per condition), the
*> using-item and charging-crossbow flags are not sent to the viewers, a navigation "done" is a position within a block, a target that is a mob (EN-FOE) is not handled here (only a
*> player target), the walk-target value of a piglin is 0 (getWalkTargetValue), a block with a path malus other than water or lava is not rejected by getPosAway.
*>   PGW-HAND-KIND USING row, main out (0 other, 1 crossbow, 2 spear), crossbow either hand out (0/1)
*>   PGW-POS-AWAY USING row, min range, max range (FLOAT-LONG), vertical range (BINARY-LONG), from x, from z (FLOAT-LONG), found out, x out, z out
*>   PGW-FINALIZE USING xoro state, row                    finalizeSpawn of a piglin
*>   PGW-SHOOT USING row, player row                       one crossbow arrow
*>   PGW-STEP USING row, hx out, hz out, acts out          the FIGHT behaviours of a piglin with a weapon and a player as target

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-HAND-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY PGBRAIN.
 01 WS-KEY                 PIC X(40).
 01 WS-LEN                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-OFF                 PIC X(48).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-MAIN                 BINARY-LONG.
 01 L-CROSSBOW             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-MAIN L-CROSSBOW.
     MOVE 0 TO L-MAIN L-CROSSBOW
     CALL "STDMOB-HAND-KEY" USING EN-HAND(L-ROW) WS-KEY
     IF WS-KEY = "minecraft:crossbow"
         MOVE 1 TO L-MAIN L-CROSSBOW
     END-IF
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-KEY))
     IF WS-LEN >= 6 AND WS-KEY NOT = SPACES
         IF WS-KEY(WS-LEN - 5:6) = "_spear"
             MOVE 2 TO L-MAIN
         END-IF
     END-IF
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         IF PG-OFFHAND(WS-SLOT) > 0 AND PG-OFFHAND(WS-SLOT) - 1 < IT-COUNT
             MOVE IT-KEY(PG-OFFHAND(WS-SLOT)) TO WS-OFF
             IF WS-OFF = "minecraft:crossbow" OR WS-OFF = "crossbow"
                 MOVE 1 TO L-CROSSBOW
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGW-HAND-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-LIQUID.
*> USING dim, x, y, z (BINARY-LONG), liquid out: 1 when the block at the cell is water or lava.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-LIQUID               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-LIQUID.
     MOVE 0 TO L-LIQUID
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLK
     IF CB-KEY(WS-BLK + 1) = "water" OR CB-KEY(WS-BLK + 1) = "minecraft:water"
             OR CB-KEY(WS-BLK + 1) = "lava" OR CB-KEY(WS-BLK + 1) = "minecraft:lava"
         MOVE 1 TO L-LIQUID
     END-IF
     GOBACK.
 END PROGRAM PGW-LIQUID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-POS-AWAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-SALT                BINARY-LONG VALUE 113.
 01 WS-BOUND               BINARY-LONG VALUE 1000000.
 01 WS-R                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-ATTEMPT             BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-OX                  FLOAT-LONG.
 01 WS-OZ                  FLOAT-LONG.
 01 WS-OFFX                BINARY-LONG.
 01 WS-OFFY                BINARY-LONG.
 01 WS-OFFZ                BINARY-LONG.
 01 WS-SPAN                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-LIQUID              BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-MIN                  FLOAT-LONG.
 01 L-MAX                  FLOAT-LONG.
 01 L-V                    BINARY-LONG.
 01 L-FX                   FLOAT-LONG.
 01 L-FZ                   FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
*> USING row, min range, max range, vertical range v, from x, from z: LandRandomPos.getPosAway(mob, minH, maxH, v, from) (44-3 section 2.19 B). d = the mob's position minus from, replaced by a
*> random horizontal vector (two draws, once) when it is zero. Up to 10 attempts: angle = atan2(dz, dx) - pi/2 + (2 r - 1) pi/2, dist = lerp(sqrt(r), minH, maxH) x sqrt 2, x = -dist sin(angle),
*> z = dist cos(angle); beyond maxH on an axis the candidate is dropped with no y draw; y = nextInt(2v + 1) - v; the cell is the mob's cell moved by the floored offset; it must be inside the
*> height range, stand on a solid cell, and after moving up out of solid it must be no water or lava. The score is the walk-target value 0, so the first survivor wins. The answer is the
*> bottom centre of the cell, found 0 when no attempt survived. (The random source is the shared deterministic draw of XP-RANDOM, not the mob's own.)
 PROCEDURE DIVISION USING L-ROW L-MIN L-MAX L-V L-FX L-FZ L-FOUND L-X L-Z.
     MOVE 0 TO L-FOUND WS-STOP
     COMPUTE WS-DX = EN-X(L-ROW) - L-FX
     COMPUTE WS-DZ = EN-Z(L-ROW) - L-FZ
     IF WS-DX = 0 AND WS-DZ = 0
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
         COMPUTE WS-DX = WS-R / 1000000 - 0.5
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
         COMPUTE WS-DZ = WS-R / 1000000 - 0.5
     END-IF
     COMPUTE WS-SPAN = 2 * L-V + 1
     MOVE DM-MIN-Y(EN-DIM(L-ROW)) TO WS-LOW
     COMPUTE WS-HIGH = WS-LOW + DM-HEIGHT(EN-DIM(L-ROW))
     PERFORM VARYING WS-ATTEMPT FROM 1 BY 1 UNTIL WS-ATTEMPT > 10 OR WS-STOP = 1
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
         COMPUTE WS-W = 2 * (WS-R / 1000000) - 1
         CALL "MTH-ATAN2" USING WS-DZ WS-DX WS-ANGLE
         COMPUTE WS-ANGLE = WS-ANGLE - 1.5707963705062866 + WS-W * 1.5707963705062866
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
         COMPUTE WS-DIST = (L-MIN + FUNCTION SQRT(WS-R / 1000000) * (L-MAX - L-MIN)) * 1.41421354
         COMPUTE WS-OX = 0 - WS-DIST * FUNCTION SIN(WS-ANGLE)
         COMPUTE WS-OZ = WS-DIST * FUNCTION COS(WS-ANGLE)
         IF FUNCTION ABS(WS-OX) <= L-MAX AND FUNCTION ABS(WS-OZ) <= L-MAX
             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R
             COMPUTE WS-OFFY = FUNCTION INTEGER(WS-R / 1000000 * WS-SPAN) - L-V
             COMPUTE WS-OFFX = FUNCTION INTEGER(WS-OX)
             COMPUTE WS-OFFZ = FUNCTION INTEGER(WS-OZ)
             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW) + WS-OFFX)
             COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW) + WS-OFFY)
             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW) + WS-OFFZ)
             IF WS-CY >= WS-LOW AND WS-CY < WS-HIGH
                 COMPUTE WS-OFFY = WS-CY - 1
                 CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-OFFY WS-CZ WS-SOLID
                 IF WS-SOLID = 1
                     CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
                     PERFORM UNTIL WS-SOLID = 0 OR WS-CY >= WS-HIGH
                         ADD 1 TO WS-CY
                         CALL "GI-SOLID-CELL" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-SOLID
                     END-PERFORM
                     CALL "PGW-LIQUID" USING EN-DIM(L-ROW) WS-CX WS-CY WS-CZ WS-LIQUID
                     IF WS-LIQUID = 0
                         MOVE 1 TO L-FOUND WS-STOP
                         COMPUTE L-X = WS-CX + 0.5
                         COMPUTE L-Z = WS-CZ + 0.5
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PGW-POS-AWAY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-FINALIZE.
*> USING xoro state, row: Piglin.finalizeSpawn for an adult not placed by a structure (44-6 section 5.8 (a)): a baby with probability 0.2 (nextFloat() < 0.2); otherwise the spawn weapon
*> (createSpawnWeapon): nextFloat() < 0.5 a crossbow, else nextInt(10) = 0 a golden spear, else a golden sword, in the main hand.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   FLOAT-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-PICK                BINARY-LONG.
 COPY CORESTATE.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW.
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     IF WS-D < 0.2
         MOVE -24000 TO EN-MOBAGE(L-ROW)
         GOBACK
     END-IF
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     IF WS-D < 0.5
         MOVE 11 TO EN-HAND(L-ROW)
         GOBACK
     END-IF
     CALL "XORO-NEXT-INT" USING L-STATE WS-TEN WS-PICK
     IF WS-PICK = 0
         MOVE 15 TO EN-HAND(L-ROW)
     ELSE
         MOVE 14 TO EN-HAND(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM PGW-FINALIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-SHOOT.
*> USING piglin row, player row: CrossbowItem.performShooting by a piglin (44-6 section 5.8 READY_TO_ATTACK): an arrow from the eyes - 0.1 at power 1.6 toward a third of the target's
*> height (the vertical part plus 0.2 x the horizontal distance), each component varied by triangle(0, 0.0172275 x (14 - 4 x difficulty)); base damage 2.0 + triangle(0.11 x difficulty, 0.57425).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-SALT                BINARY-LONG VALUE 117.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-INACC               FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-P                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-P.
     COMPUTE WS-DX = PL-X(L-P) - EN-X(L-ROW)
     COMPUTE WS-DZ = PL-Z(L-P) - EN-Z(L-ROW)
     COMPUTE WS-AX = EN-X(L-ROW)
     COMPUTE WS-AY = EN-Y(L-ROW) + 1.69
     COMPUTE WS-AZ = EN-Z(L-ROW)
     COMPUTE WS-DY = PL-Y(L-P) + 0.6 - WS-AY
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     COMPUTE WS-DY = WS-DY + WS-H * 0.2
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     IF WS-LEN < 0.0001
         GOBACK
     END-IF
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
     COMPUTE WS-BASE = 2000 + 110 * BW-DIFFICULTY + (WS-R1 - WS-R2) * 0.57425
     MOVE EN-ID(L-ROW) TO WS-OWNER
     CALL "ARROW-SPAWN" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
     GOBACK.
 END PROGRAM PGW-SHOOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-HEAD.
*> USING row, point x, z (FLOAT-LONG), speed (FLOAT-LONG), hx out, hz out, done out: the step toward a point and 1 once it is within a block horizontally (the navigation is done).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PX L-PZ L-SPEED L-HX L-HZ L-DONE.
     COMPUTE WS-DX = L-PX - EN-X(L-ROW)
     COMPUTE WS-DZ = L-PZ - EN-Z(L-ROW)
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     MOVE 0 TO L-DONE
     IF WS-H < 1
         MOVE 1 TO L-DONE
     END-IF
     IF WS-H < 0.0001
         MOVE 0 TO L-HX L-HZ
     ELSE
         COMPUTE L-HX = WS-DX / WS-H * L-SPEED
         COMPUTE L-HZ = WS-DZ / WS-H * L-SPEED
     END-IF
     GOBACK.
 END PROGRAM PGW-HEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY PGBRAIN.
 COPY CONTENT.
 01 WS-M                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-MAIN                BINARY-LONG.
 01 WS-CROSSBOW            BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-MINR                FLOAT-LONG.
 01 WS-MAXR                FLOAT-LONG.
 01 WS-V                   BINARY-LONG VALUE 7.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY40               PIC X(40).
 01 WS-SALT                BINARY-LONG VALUE 119.
 01 WS-BOUND               BINARY-LONG VALUE 20.
 01 WS-DRAW                BINARY-LONG.
 01 WS-KFOUND              BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-DT                  BINARY-LONG.
 01 WS-DS                  BINARY-LONG.
 01 WS-KT                  BINARY-LONG.
 01 WS-KS                  BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-AS                  BINARY-LONG.
 01 WS-MULT                BINARY-LONG.
 01 WS-CHARGE              PIC X(8).
 01 WS-RANGE               PIC X(24).
 01 WS-START               BINARY-LONG.
 01 WS-STOPPED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-ACTS                 BINARY-LONG.
*> USING piglin row, hx out, hz out, acts out: the FIGHT behaviours of a piglin that has a player as its attack target and a spear or a crossbow (44-6 sections 2.11, 5.7, 5.8). acts 1: the
*> piglin's walk this tick is (hx, hz) (a zero vector stands still) and it faces the target; 0: the ordinary chase and melee apply. Like Brain.tick every behaviour first tries to start (in the order
*> BackUpIfTooClose, SpearApproach, SpearAttack, SpearRetreat, CrossbowAttack), then every running behaviour ticks or stops, so a stop that changes SPEAR_STATUS is seen by the start phase
*> of the next tick. A crossbow user stands within 8 blocks of a target it sees (the walk target is erased) and backs up at 0.75 within 5.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-ACTS.
     MOVE 0 TO L-HX L-HZ L-ACTS
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF SM-KEY(WS-M) NOT = "piglin"
         GOBACK
     END-IF
     CALL "PGW-HAND-KIND" USING L-ROW WS-MAIN WS-CROSSBOW
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-YES WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
*>   Without a target no behaviour can still be used (canStillUse): each running one stops with its stop effects.
     IF WS-P = 0
         EVALUATE PG-SP-RUN(WS-SLOT)
             WHEN 1
                 MOVE 2 TO PG-SP-STATUS(WS-SLOT)
             WHEN 2
                 MOVE 3 TO PG-SP-STATUS(WS-SLOT)
             WHEN 3
                 MOVE 0 TO PG-SP-STATUS(WS-SLOT)
         END-EVALUATE
         IF PG-SP-RUN(WS-SLOT) > 0
             MOVE 0 TO PG-SP-RUN(WS-SLOT) PG-USING(WS-SLOT) PG-SP-CSET(WS-SLOT) PG-SP-FSET(WS-SLOT) PG-SP-ENGAGE(WS-SLOT) PG-SP-FTIME(WS-SLOT)
         END-IF
         IF PG-XB-RUN(WS-SLOT) = 1
             MOVE 0 TO PG-XB-RUN(WS-SLOT) PG-USING(WS-SLOT) PG-XB-LOADED(WS-SLOT)
         END-IF
         GOBACK
     END-IF
*>   Nothing to do without a weapon, and a spear or crossbow that is put away stops its state.
     IF WS-MAIN NOT = 2
         MOVE 0 TO PG-SP-STATUS(WS-SLOT) PG-SP-RUN(WS-SLOT) PG-SP-ENGAGE(WS-SLOT) PG-SP-CSET(WS-SLOT) PG-SP-FSET(WS-SLOT)
     END-IF
     IF WS-MAIN NOT = 2 AND WS-CROSSBOW = 0
         GOBACK
     END-IF
     COMPUTE WS-SPEED = SM-WALK-MILLI(WS-M) / 1000
     MOVE PL-X(WS-P) TO WS-TX
     MOVE PL-Z(WS-P) TO WS-TZ
     MOVE PL-Y(WS-P) TO WS-TY
     COMPUTE WS-DX = WS-TX - EN-X(L-ROW)
     COMPUTE WS-DY = WS-TY - EN-Y(L-ROW)
     COMPUTE WS-DZ = WS-TZ - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     COMPUTE WS-D = FUNCTION SQRT(WS-D2)
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     MOVE EN-X(L-ROW) TO WS-AX
     COMPUTE WS-AY = EN-Y(L-ROW) + 1.79
     MOVE EN-Z(L-ROW) TO WS-AZ
     COMPUTE WS-DY = PL-Y(WS-P) + 1.62
     CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ WS-TX WS-DY WS-TZ WS-SEES

*>   BackUpIfTooClose(5, 0.75): a crossbow in either hand, the target seen and closer than 5: strafe back at 0.75.
     IF WS-CROSSBOW = 1 AND WS-SEES = 1 AND WS-D2 < 25 AND WS-H > 0.0001
         COMPUTE L-HX = 0 - WS-DX / WS-H * WS-SPEED * 0.75
         COMPUTE L-HZ = 0 - WS-DZ / WS-H * WS-SPEED * 0.75
         MOVE 1 TO L-ACTS
     END-IF
*>   The walk target of a crossbow user: it stands within 8 blocks of a target it sees.
     IF WS-MAIN = 1 AND WS-SEES = 1 AND WS-D2 < 64
         MOVE 1 TO L-ACTS
     END-IF

*>   The spear: starts first.
     IF WS-MAIN = 2
         MOVE 1 TO L-ACTS
         IF PG-SP-RUN(WS-SLOT) = 0 AND PG-SP-STATUS(WS-SLOT) = 0 AND PG-USING(WS-SLOT) = 0
             MOVE 1 TO PG-SP-STATUS(WS-SLOT)
             MOVE 1 TO PG-SP-RUN(WS-SLOT)
             MOVE 0 TO PG-SP-AGE(WS-SLOT)
         END-IF
         IF PG-SP-RUN(WS-SLOT) = 0 AND PG-SP-STATUS(WS-SLOT) = 2 AND PG-USING(WS-SLOT) = 0
             MOVE 2 TO PG-SP-RUN(WS-SLOT)
             MOVE 0 TO PG-SP-AGE(WS-SLOT) PG-SP-CSET(WS-SLOT)
             MOVE 1 TO PG-USING(WS-SLOT)
             CALL "STDMOB-HAND-KEY" USING EN-HAND(L-ROW) WS-KEY40
             MOVE WS-KEY40 TO WS-KEY
             CALL "TOOL-SPEAR-KINETIC" USING WS-KEY WS-KFOUND WS-DELAY WS-DT WS-DS WS-KT WS-KS WS-AT WS-AS WS-MULT WS-CHARGE WS-RANGE
             COMPUTE PG-SP-ENGAGE(WS-SLOT) = 0
             IF WS-KFOUND = 1
                 COMPUTE PG-SP-ENGAGE(WS-SLOT) = WS-DELAY + WS-AT
             END-IF
         END-IF
         IF PG-SP-RUN(WS-SLOT) = 0 AND PG-SP-STATUS(WS-SLOT) = 3 AND PG-USING(WS-SLOT) = 0
             COMPUTE WS-MINR = FUNCTION MAX(0, 9 - WS-D)
             COMPUTE WS-MAXR = FUNCTION MAX(1, 11 - WS-D)
             CALL "PGW-POS-AWAY" USING L-ROW WS-MINR WS-MAXR WS-V WS-TX WS-TZ WS-FOUND WS-FX WS-FZ
             IF WS-FOUND = 1
                 MOVE WS-FX TO PG-SP-FX(WS-SLOT)
                 MOVE WS-FZ TO PG-SP-FZ(WS-SLOT)
                 MOVE 1 TO PG-SP-FSET(WS-SLOT)
                 MOVE 3 TO PG-SP-RUN(WS-SLOT)
                 MOVE 0 TO PG-SP-FTIME(WS-SLOT) PG-SP-AGE(WS-SLOT)
             END-IF
         END-IF
*>       The tick phase.
         EVALUATE PG-SP-RUN(WS-SLOT)
             WHEN 1
*>               SpearApproach: while farther than 10 (squared 100): walk to the target; the stop makes CHARGING.
                 IF WS-D2 > 100
                     CALL "PGW-HEAD" USING L-ROW WS-TX WS-TZ WS-SPEED L-HX L-HZ WS-DONE
                 ELSE
                     MOVE 2 TO PG-SP-STATUS(WS-SLOT)
                     MOVE 0 TO PG-SP-RUN(WS-SLOT)
                 END-IF
             WHEN 2
*>               SpearAttack: engage time falls by 1; walk to the charge position, or to the target and pick a reposition point when closer than 2.
                 IF PG-SP-ENGAGE(WS-SLOT) > 0
                     SUBTRACT 1 FROM PG-SP-ENGAGE(WS-SLOT)
                     IF PG-SP-CSET(WS-SLOT) = 1
                         CALL "PGW-HEAD" USING L-ROW PG-SP-CX(WS-SLOT) PG-SP-CZ(WS-SLOT) WS-SPEED L-HX L-HZ WS-DONE
                         IF WS-DONE = 1
                             MOVE 0 TO PG-SP-CSET(WS-SLOT)
                         END-IF
                     ELSE
                         CALL "PGW-HEAD" USING L-ROW WS-TX WS-TZ WS-SPEED L-HX L-HZ WS-DONE
                         IF WS-D2 < 4
                             COMPUTE WS-MINR = 6 - WS-D
                             COMPUTE WS-MAXR = 7 - WS-D
                             CALL "PGW-POS-AWAY" USING L-ROW WS-MINR WS-MAXR WS-V WS-TX WS-TZ WS-FOUND WS-FX WS-FZ
                             IF WS-FOUND = 1
                                 MOVE WS-FX TO PG-SP-CX(WS-SLOT)
                                 MOVE WS-FZ TO PG-SP-CZ(WS-SLOT)
                                 MOVE 1 TO PG-SP-CSET(WS-SLOT)
                             END-IF
                         END-IF
                     END-IF
                 ELSE
                     MOVE 0 TO PG-USING(WS-SLOT) PG-SP-CSET(WS-SLOT) PG-SP-ENGAGE(WS-SLOT) PG-SP-RUN(WS-SLOT)
                     MOVE 3 TO PG-SP-STATUS(WS-SLOT)
                 END-IF
             WHEN 3
*>               SpearRetreat: walk to the fleeing point for at most 100 ticks; the stop erases the whole state (the cycle restarts with SpearApproach).
                 ADD 1 TO PG-SP-AGE(WS-SLOT)
                 IF PG-SP-FTIME(WS-SLOT) < 100 AND PG-SP-FSET(WS-SLOT) = 1 AND PG-SP-AGE(WS-SLOT) <= 100
                     ADD 1 TO PG-SP-FTIME(WS-SLOT)
                     CALL "PGW-HEAD" USING L-ROW PG-SP-FX(WS-SLOT) PG-SP-FZ(WS-SLOT) WS-SPEED L-HX L-HZ WS-DONE
                     IF WS-DONE = 1
                         MOVE 0 TO PG-SP-FSET(WS-SLOT)
                         MOVE 0 TO PG-USING(WS-SLOT) PG-SP-FTIME(WS-SLOT) PG-SP-STATUS(WS-SLOT) PG-SP-RUN(WS-SLOT)
                     END-IF
                 ELSE
                     MOVE 0 TO PG-USING(WS-SLOT) PG-SP-FTIME(WS-SLOT) PG-SP-FSET(WS-SLOT) PG-SP-STATUS(WS-SLOT) PG-SP-RUN(WS-SLOT)
                 END-IF
         END-EVALUATE
     END-IF

*>   CrossbowAttack.
     IF WS-CROSSBOW = 1
         MOVE 0 TO WS-START
         IF WS-SEES = 1 AND WS-MAIN = 1 AND WS-D2 < 64
             MOVE 1 TO WS-START
         END-IF
         IF PG-XB-RUN(WS-SLOT) = 0 AND WS-START = 1
             MOVE 1 TO PG-XB-RUN(WS-SLOT)
             MOVE 0 TO PG-XB-AGE(WS-SLOT)
         END-IF
         IF PG-XB-RUN(WS-SLOT) = 1
             ADD 1 TO PG-XB-AGE(WS-SLOT)
             MOVE 0 TO WS-STOPPED
             IF WS-START = 0 OR PG-XB-AGE(WS-SLOT) > 1200
                 MOVE 1 TO WS-STOPPED
             END-IF
             IF WS-STOPPED = 1
                 MOVE 0 TO PG-XB-RUN(WS-SLOT) PG-USING(WS-SLOT) PG-XB-LOADED(WS-SLOT)
             ELSE
                 EVALUATE PG-XB-STATE(WS-SLOT)
                     WHEN 0
                         MOVE 1 TO PG-USING(WS-SLOT)
                         MOVE 1 TO PG-XB-STATE(WS-SLOT)
                         MOVE 0 TO PG-XB-USED(WS-SLOT)
                     WHEN 1
                         IF PG-USING(WS-SLOT) = 0
                             MOVE 0 TO PG-XB-STATE(WS-SLOT)
                         END-IF
                         ADD 1 TO PG-XB-USED(WS-SLOT)
                         IF PG-XB-USED(WS-SLOT) >= 25 AND PG-XB-STATE(WS-SLOT) = 1
                             MOVE 1 TO PG-XB-LOADED(WS-SLOT)
                             MOVE 2 TO PG-XB-STATE(WS-SLOT)
                             MOVE 0 TO PG-USING(WS-SLOT)
                             CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
                             COMPUTE PG-XB-DELAY(WS-SLOT) = 20 + WS-DRAW
                         END-IF
                     WHEN 2
                         SUBTRACT 1 FROM PG-XB-DELAY(WS-SLOT)
                         IF PG-XB-DELAY(WS-SLOT) <= 0
                             MOVE 3 TO PG-XB-STATE(WS-SLOT)
                         END-IF
                     WHEN OTHER
                         CALL "PGW-SHOOT" USING L-ROW WS-P
                         MOVE 0 TO PG-XB-LOADED(WS-SLOT)
                         MOVE 0 TO PG-XB-STATE(WS-SLOT)
                 END-EVALUATE
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGW-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-ITEM-KEY.
*> USING item id (BINARY-LONG), key out (PIC X(32)): the key of the item without "minecraft:"; spaces for an unknown id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-FULL                PIC X(48).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-KEY                  PIC X(32).
 PROCEDURE DIVISION USING L-ITEM L-KEY.
     MOVE SPACES TO L-KEY
     IF L-ITEM >= 0 AND L-ITEM < IT-COUNT
         MOVE IT-KEY(L-ITEM + 1) TO WS-FULL
         INSPECT WS-FULL REPLACING FIRST "minecraft:" BY SPACES
         MOVE FUNCTION TRIM(WS-FULL LEADING) TO L-KEY
     END-IF
     GOBACK.
 END PROGRAM PGW-ITEM-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-PREFERRED.
*> USING key (PIC X(32), no prefix), adult (1/0), preferred out, in tag out: the item tag piglin_preferred_weapons (crossbow, golden_spear) holds the key (only for an adult: a baby has no preferred
*> weapon type); preferred is "loved (piglin_loved) or in the tag" (44-6 section 3.2 step 6b).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOVED               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(32).
 01 L-ADULT                BINARY-LONG.
 01 L-PREFERRED            BINARY-LONG.
 01 L-IN-TAG               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ADULT L-PREFERRED L-IN-TAG.
     MOVE 0 TO L-IN-TAG
     IF L-ADULT = 1 AND (L-KEY = "crossbow" OR L-KEY = "golden_spear")
         MOVE 1 TO L-IN-TAG
     END-IF
     CALL "PIGLIN-LOVED" USING L-KEY WS-LOVED
     MOVE L-IN-TAG TO L-PREFERRED
     IF WS-LOVED = 1
         MOVE 1 TO L-PREFERRED
     END-IF
     GOBACK.
 END PROGRAM PGW-PREFERRED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-DAMAGE.
*> USING key (PIC X(32), no prefix), modifier out (BINARY-LONG, 1/10000): the attack damage modifier an item adds in the main hand (the attack damage of TOOL-ITEM-STATS less the player's 1);
*> 0 for an item with no attack_damage component. The mob's base value is the same for both items of a comparison, so it cancels (getApproximateAttributeWith, ADD_VALUE only).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY48               PIC X(48).
 01 WS-FOUND               BINARY-LONG.
 01 WS-DURABILITY          BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-SPEED               BINARY-LONG.
 01 WS-COOLDOWN            BINARY-LONG.
 01 WS-MINING              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(32).
 01 L-MODIFIER             BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-MODIFIER.
     MOVE 0 TO L-MODIFIER
     MOVE SPACES TO WS-KEY48
     MOVE L-KEY TO WS-KEY48
     CALL "TOOL-ITEM-STATS" USING WS-KEY48 WS-FOUND WS-DURABILITY WS-DAMAGE WS-SPEED WS-COOLDOWN WS-MINING
     IF WS-FOUND = 1
         COMPUTE L-MODIFIER = WS-DAMAGE - 10000
     END-IF
     GOBACK.
 END PROGRAM PGW-DAMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-CAN-REPLACE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ADULT               BINARY-LONG.
 01 WS-CAND-KEY            PIC X(32).
 01 WS-CUR-KEY40           PIC X(40).
 01 WS-CUR-KEY             PIC X(32).
 01 WS-EMPTY               BINARY-LONG.
 01 WS-CAND-PREF           BINARY-LONG.
 01 WS-CAND-TAG            BINARY-LONG.
 01 WS-CUR-PREF            BINARY-LONG.
 01 WS-CUR-TAG             BINARY-LONG.
 01 WS-DC                  BINARY-LONG.
 01 WS-DO                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-YES                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-YES.
*> USING piglin row, candidate item id, yes out: Piglin.canReplaceCurrentItem(candidate) for the main hand (44-6 section 3.2 step 6; 44-1 RQ-1.3). The candidate's slot is the main hand (armour has no
*> model on a piglin: the caller leaves it). The three-argument rule: a preferred candidate (loved, or in piglin_preferred_weapons for an adult) replaces a current item that is not preferred; a
*> candidate that is not preferred never replaces a preferred one; otherwise an empty hand is replaced, then compareWeapons (the preferred tag, then the attack damage, then the tie-break, which
*> has no enchantments, wear or names to compare here and says no).
     MOVE 0 TO L-YES
     MOVE 1 TO WS-ADULT
     IF EN-MOBAGE(L-ROW) < 0
         MOVE 0 TO WS-ADULT
     END-IF
     CALL "PGW-ITEM-KEY" USING L-ITEM WS-CAND-KEY
     CALL "PGW-PREFERRED" USING WS-CAND-KEY WS-ADULT WS-CAND-PREF WS-CAND-TAG
     MOVE 0 TO WS-EMPTY WS-CUR-PREF WS-CUR-TAG
     MOVE SPACES TO WS-CUR-KEY
     CALL "STDMOB-HAND-KEY" USING EN-HAND(L-ROW) WS-CUR-KEY40
     IF WS-CUR-KEY40 = SPACES
         MOVE 1 TO WS-EMPTY
     ELSE
         INSPECT WS-CUR-KEY40 REPLACING FIRST "minecraft:" BY SPACES
         MOVE FUNCTION TRIM(WS-CUR-KEY40 LEADING) TO WS-CUR-KEY
         CALL "PGW-PREFERRED" USING WS-CUR-KEY WS-ADULT WS-CUR-PREF WS-CUR-TAG
     END-IF
     EVALUATE TRUE
         WHEN WS-CAND-PREF = 1 AND WS-CUR-PREF = 0
             MOVE 1 TO L-YES
         WHEN WS-CAND-PREF = 0 AND WS-CUR-PREF = 1
             MOVE 0 TO L-YES
         WHEN WS-EMPTY = 1
             MOVE 1 TO L-YES
         WHEN WS-CUR-TAG = 1 AND WS-CAND-TAG = 0
             MOVE 0 TO L-YES
         WHEN WS-CUR-TAG = 0 AND WS-CAND-TAG = 1
             MOVE 1 TO L-YES
         WHEN OTHER
             CALL "PGW-DAMAGE" USING WS-CAND-KEY WS-DC
             CALL "PGW-DAMAGE" USING WS-CUR-KEY WS-DO
             IF WS-DC > WS-DO
                 MOVE 1 TO L-YES
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PGW-CAN-REPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGW-EQUIP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-CAN                 BINARY-LONG.
 01 WS-KEY40               PIC X(40).
 01 WS-KEY                 PIC X(112).
 01 WS-OLD                 BINARY-LONG.
 01 WS-ROWDATA             PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 123.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-DRAW                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-DROP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-EQUIPPED             BINARY-LONG.
*> USING piglin row, item id, equipped out: Mob.equipItemIfPossible for the main hand (44-6 section 3.2): when PGW-CAN-REPLACE says yes the old main-hand item, if there is one, is dropped as an
*> item with the probability that max(nextFloat - 0.1, 0) < 0.085 (the draw is made only for a non-empty hand) and otherwise lost; the new item (one of it) is held (EN-HAND 1000 + the id) and the
*> viewers get Set Equipment. The persistence and guaranteed-drop flags are not kept (open).
 PROCEDURE DIVISION USING L-ROW L-ITEM L-EQUIPPED.
     MOVE 0 TO L-EQUIPPED
     CALL "PGW-CAN-REPLACE" USING L-ROW L-ITEM WS-CAN
     IF WS-CAN = 0
         GOBACK
     END-IF
     IF EN-HAND(L-ROW) NOT = 0
         CALL "STDMOB-HAND-KEY" USING EN-HAND(L-ROW) WS-KEY40
         MOVE SPACES TO WS-KEY
         MOVE WS-KEY40 TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-OLD WS-ROWDATA WS-STATUS
         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-DRAW
         IF WS-STATUS = CT-OK AND WS-DRAW < 185
             MOVE EN-X(L-ROW) TO WS-X
             COMPUTE WS-Y = EN-Y(L-ROW) + 1
             MOVE EN-Z(L-ROW) TO WS-Z
             CALL "GI-SPAWN-RANDOM" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-OLD WS-ONE WS-ZERO WS-DELAY WS-DROP
         END-IF
     END-IF
     COMPUTE EN-HAND(L-ROW) = 1000 + L-ITEM
     CALL "STDMOB-EQUIP-SEND" USING L-ROW
     MOVE 1 TO L-EQUIPPED
     GOBACK.
 END PROGRAM PGW-EQUIP.
