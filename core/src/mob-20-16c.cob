*> The breeze's brain (lane 002-lane-p49u; docs/protocol/20 section 16.1, 16.4, 16.5): the wiring of the shoot, long jump, slide and idle behaviours that the programs of mob-20-16.cob and mob-20-16b.cob
*> compute. State: BZ-ENTRY of BREEZESTATE.cpy.
*>   BZ-FIND USING entity id, create, slot out: the state slot of a breeze (0 none; a free slot or one whose entity is gone is taken when create is 1).
*>   BREEZE-LIGHT-SCORE USING level (BINARY-LONG, the raw brightness), score out (FLOAT-LONG): getWalkTargetValue of a Monster as 20 section 16.5 states it: 0.5 minus the light-dependent magic
*>     value (b = level / 15, v = b / (4 - 3 b), the Overworld ambient light 0; 18 section 6.8 and 32 give the value as v minus 0.5: the two documents disagree on the sign, this follows 20).
*>   BREEZE-AWAY-BEST USING oks (10 BINARY-LONG), scores (10 FLOAT-LONG), best out: RandomPos.generateRandomPos over up to 10 candidates: the highest score wins (strictly greater), 0 when none is valid.
*>   BREEZE-BLOCKED USING dim, x, y, z, blocked out: the cell has a collision shape (every shape is a full cube here, as in CREAKING-CLIP).
*>   BREEZE-POS-STABLE USING dim, x, y, z, ok out: isStableDestination of ground navigation: the block below is a full opaque cube.
*>   BREEZE-DANGEROUS USING dim, x, y, z, dangerous out: EntityType.isBlockDangerous for the block below the cell (16.4 step 9): fire, soul fire, lava, magma block, lava cauldron, wither rose,
*>     sweet berry bush, cactus, powder snow. Not here: a lit campfire (the block state properties are not read here).
*>   BREEZE-LOS USING dim, from x, y, z, to x, y, z, limit (FLOAT-LONG), ok out: BreezeUtil.hasLineOfSight: the straight ray between the two points hits no block and the distance is at most limit.
*>     Approximation: the ray tests the cubes of CREAKING-CLIP (glass, bars and powder snow let it through).
*>   BREEZE-SNAP USING dim, point x, y, z, ok out, block x, y, z out: the surface snap of 16.4 step 8: a ray 10 blocks straight down (the first collider cell; hit at the start when the point is inside one),
*>     else 10 up; BlockPos.containing(hit location).above().
*>   BREEZE-REACHABLE USING dim, x, y, z, ok out: a walk target cell the breeze can path to: not inside a collider (the approximation of the failed path computation of MoveToTargetSink).
*>   BREEZE-AWAY-PICK USING breeze row, from x, z (FLOAT-LONG), ok out, block x, y, z out: DefaultRandomPos.getPosAway(breeze, 5, 5, from): up to 10 candidates of BREEZE-POS-AWAY, rejected unless stable
*>     and free of a malus (inside a collider, a dangerous block below, water in the cell), scored by BREEZE-LIGHT-SCORE of the cell's light, the best by BREEZE-AWAY-BEST.
*>   BREEZE-BRAIN USING breeze row, table row, hx, hz out (FLOAT-LONG), walk out: one tick of the brain (called by STDMOB-STEP in the place of BREEZE-SHOOT). walk 0 the mob strolls as usual, 1 it walks
*>     (hx, hz), 2 it stands (inhaling, flying), 3 it stands facing its target. Not here: the sounds, the look-at-target sink's head turn, the Jump Boost bonus, a Levitation effect for ShootWhenStuck,
*>     the vertical drag of a flight with discard friction, the hurt_by StartAttacking finder and the DoNothing pause group of the idle stroll (STDMOB-AGGRO and the generic stroll do those).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BZ-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BREEZESTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-LIVE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-CREATE               BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-CREATE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BZ-MAX OR L-SLOT > 0
         IF BZ-ID(WS-I) = L-ID
             MOVE WS-I TO L-SLOT
         END-IF
     END-PERFORM
     IF L-SLOT = 0 AND L-CREATE = 1
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BZ-MAX OR L-SLOT > 0
             MOVE 0 TO WS-LIVE
             IF BZ-ID(WS-I) > 0
                 PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-LIVE = 1
                     IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = BZ-ID(WS-I)
                         MOVE 1 TO WS-LIVE
                     END-IF
                 END-PERFORM
             END-IF
             IF WS-LIVE = 0
                 INITIALIZE BZ-ENTRY(WS-I)
                 MOVE L-ID TO BZ-ID(WS-I)
                 MOVE WS-I TO L-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM BZ-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-LIGHT-SCORE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-LEVEL                BINARY-LONG.
 01 L-SCORE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-LEVEL L-SCORE.
     COMPUTE WS-B = L-LEVEL / 15
     COMPUTE L-SCORE = 0.5 - WS-B / (4 - 3 * WS-B)
     GOBACK.
 END PROGRAM BREEZE-LIGHT-SCORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-AWAY-BEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-OKS.
    05 L-OK                BINARY-LONG OCCURS 10 TIMES.
 01 L-SCORES.
    05 L-SCORE             FLOAT-LONG OCCURS 10 TIMES.
 01 L-BEST                 BINARY-LONG.
 PROCEDURE DIVISION USING L-OKS L-SCORES L-BEST.
     MOVE 0 TO L-BEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         IF L-OK(WS-I) = 1
             IF L-BEST = 0
                 MOVE WS-I TO L-BEST
             ELSE
                 IF L-SCORE(WS-I) > L-SCORE(L-BEST)
                     MOVE WS-I TO L-BEST
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BREEZE-AWAY-BEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-BLOCKED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCKED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCKED.
     MOVE 0 TO L-BLOCKED
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0
         IF CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
             MOVE 1 TO L-BLOCKED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BREEZE-BLOCKED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-POS-STABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     MOVE 0 TO L-OK
     COMPUTE WS-BELOW = L-Y - 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-BELOW L-Z WS-STATE
     IF WS-STATE > 0
         IF CB-OPAQUE(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BREEZE-POS-STABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-DANGEROUS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 01 WS-FULL                PIC X(48).
 01 WS-BELOW               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DANGEROUS            BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-DANGEROUS.
     MOVE 0 TO L-DANGEROUS
     COMPUTE WS-BELOW = L-Y - 1
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-BELOW L-Z WS-STATE
     IF WS-STATE > 0
         CALL "KEY-NAMESPACED" USING CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) WS-FULL
         EVALUATE WS-FULL
             WHEN "minecraft:fire" WHEN "minecraft:soul_fire" WHEN "minecraft:lava" WHEN "minecraft:magma_block"
             WHEN "minecraft:lava_cauldron" WHEN "minecraft:wither_rose" WHEN "minecraft:sweet_berry_bush"
             WHEN "minecraft:cactus" WHEN "minecraft:powder_snow"
                 MOVE 1 TO L-DANGEROUS
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM BREEZE-DANGEROUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-LOS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HIT                 BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-L2                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-FX                   FLOAT-LONG.
 01 L-FY                   FLOAT-LONG.
 01 L-FZ                   FLOAT-LONG.
 01 L-TX                   FLOAT-LONG.
 01 L-TY                   FLOAT-LONG.
 01 L-TZ                   FLOAT-LONG.
 01 L-LIMIT                FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-FX L-FY L-FZ L-TX L-TY L-TZ L-LIMIT L-OK.
     MOVE 0 TO L-OK
     COMPUTE WS-D2 = (L-TX - L-FX) ** 2 + (L-TY - L-FY) ** 2 + (L-TZ - L-FZ) ** 2
     COMPUTE WS-L2 = L-LIMIT * L-LIMIT
     IF WS-D2 <= WS-L2
         CALL "CREAKING-CLIP" USING L-DIM L-FX L-FY L-FZ L-TX L-TY L-TZ WS-HIT
         IF WS-HIT = 0
             MOVE 1 TO L-OK
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BREEZE-LOS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-SNAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CY                  BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-END                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-PX                   FLOAT-LONG.
 01 L-PY                   FLOAT-LONG.
 01 L-PZ                   FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-PX L-PY L-PZ L-OK L-BX L-BY L-BZ.
     MOVE 0 TO L-OK L-BX L-BY L-BZ WS-DONE
     COMPUTE L-BX = FUNCTION INTEGER(L-PX)
     COMPUTE L-BZ = FUNCTION INTEGER(L-PZ)
     COMPUTE WS-CY = FUNCTION INTEGER(L-PY)
*>   Down: the cells from the point's down to the one 10 blocks lower. The first collider cell is hit at its top face (y + 1), at the point itself when the point is inside it.
     COMPUTE WS-END = L-PY - 10
     COMPUTE WS-LAST = FUNCTION INTEGER(WS-END)
     PERFORM VARYING WS-Y FROM WS-CY BY -1 UNTIL WS-Y < WS-LAST OR WS-DONE = 1
         CALL "BREEZE-BLOCKED" USING L-DIM L-BX WS-Y L-BZ WS-BLOCKED
         IF WS-BLOCKED = 1
             MOVE 1 TO WS-DONE L-OK
             IF WS-Y = WS-CY
                 COMPUTE L-BY = WS-CY + 1
             ELSE
                 COMPUTE L-BY = WS-Y + 2
             END-IF
         END-IF
     END-PERFORM
*>   Up: the first collider cell is hit at its bottom face (y): containing is that cell, the result the one above.
     COMPUTE WS-END = L-PY + 10
     COMPUTE WS-LAST = FUNCTION INTEGER(WS-END)
     COMPUTE WS-Y = WS-CY + 1
     PERFORM VARYING WS-Y FROM WS-Y BY 1 UNTIL WS-Y > WS-LAST OR WS-DONE = 1
         CALL "BREEZE-BLOCKED" USING L-DIM L-BX WS-Y L-BZ WS-BLOCKED
         IF WS-BLOCKED = 1
             MOVE 1 TO WS-DONE L-OK
             COMPUTE L-BY = WS-Y + 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BREEZE-SNAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-REACHABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BLOCKED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-OK.
     CALL "BREEZE-BLOCKED" USING L-DIM L-X L-Y L-Z WS-BLOCKED
     COMPUTE L-OK = 1 - WS-BLOCKED
     GOBACK.
 END PROGRAM BREEZE-REACHABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-AWAY-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 96.
 01 WS-MILLION             BINARY-LONG VALUE 1000000.
 01 WS-ELEVEN              BINARY-LONG VALUE 11.
 01 WS-H                   BINARY-LONG VALUE 5.
 01 WS-V                   BINARY-LONG VALUE 5.
 01 WS-I                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-YDRAW               BINARY-LONG.
 01 WS-OKS.
    05 WS-OK-A             BINARY-LONG OCCURS 10 TIMES.
 01 WS-SCORES.
    05 WS-SCORE-A          FLOAT-LONG OCCURS 10 TIMES.
 01 WS-CELLS.
    05 WS-CELL             OCCURS 10 TIMES.
       10 WS-CX            BINARY-LONG.
       10 WS-CY            BINARY-LONG.
       10 WS-CZ            BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-MALUS               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FX                   FLOAT-LONG.
 01 L-FZ                   FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FX L-FZ L-OK L-BX L-BY L-BZ.
     MOVE 0 TO L-OK L-BX L-BY L-BZ
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE 0 TO WS-OK-A(WS-I)
         CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
         COMPUTE WS-ANGLE = WS-DRAW / 1000000
         CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
         COMPUTE WS-DIST = WS-DRAW / 1000000
         CALL "XP-RANDOM" USING WS-SALT WS-ELEVEN WS-YDRAW
         CALL "BREEZE-POS-AWAY" USING EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) L-FX L-FZ WS-H WS-V WS-ANGLE WS-DIST WS-YDRAW
             WS-OK WS-BX WS-BY WS-BZ
         IF WS-OK = 1
             CALL "BREEZE-POS-STABLE" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-OK
         END-IF
*>       A malus: a collider in the cell (BLOCKED), a dangerous block below it, water in the cell.
         IF WS-OK = 1
             MOVE 0 TO WS-MALUS
             CALL "BREEZE-BLOCKED" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-MALUS
             IF WS-MALUS = 0
                 CALL "BREEZE-DANGEROUS" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-MALUS
             END-IF
             IF WS-MALUS = 0
                 CALL "FLUID-CELL" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
                     WS-SOLID WS-HOLDS
                 IF WS-FLUID > 0
                     MOVE 1 TO WS-MALUS
                 END-IF
             END-IF
             IF WS-MALUS = 0
                 MOVE 1 TO WS-OK-A(WS-I)
                 MOVE WS-BX TO WS-CX(WS-I)
                 MOVE WS-BY TO WS-CY(WS-I)
                 MOVE WS-BZ TO WS-CZ(WS-I)
                 CALL "STDMOB-LIGHTS" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-SKY WS-BLOCK
                 CALL "STDMOB-DARKEN" USING CW-TIME WS-DARK
                 COMPUTE WS-LEVEL = FUNCTION MAX(WS-BLOCK, WS-SKY - WS-DARK)
                 CALL "BREEZE-LIGHT-SCORE" USING WS-LEVEL WS-SCORE-A(WS-I)
             END-IF
         END-IF
     END-PERFORM
     CALL "BREEZE-AWAY-BEST" USING WS-OKS WS-SCORES WS-BEST
     IF WS-BEST > 0
         MOVE 1 TO L-OK
         MOVE WS-CX(WS-BEST) TO L-BX
         MOVE WS-CY(WS-BEST) TO L-BY
         MOVE WS-CZ(WS-BEST) TO L-BZ
     END-IF
     GOBACK.
 END PROGRAM BREEZE-AWAY-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-SLIDE-POINT.
*> USING breeze row, target player row, point x, y, z out (FLOAT-LONG): Slide.start's candidate (16.5): within the inner circle of the target (horizontal distance below 4 and a height
*> difference below 10 from the breeze block's centre) the getPosAway(5, 5) cell when it is in sight and farther from the target than the breeze; else nextBoolean: the point behind the target
*> or the point in the middle circle (a draw each).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SALT                BINARY-LONG VALUE 97.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-MILLION             BINARY-LONG VALUE 1000000.
 01 WS-LIMIT               FLOAT-LONG VALUE 50.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-SET                 BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AY4                 FLOAT-LONG.
 01 WS-SEE-A               BINARY-LONG.
 01 WS-SEE-B               BINARY-LONG.
 01 WS-DA                  FLOAT-LONG.
 01 WS-DB                  FLOAT-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-U1                  FLOAT-LONG.
 01 WS-U2                  FLOAT-LONG.
 01 WS-GAUSS               FLOAT-LONG.
 01 WS-HEAD                FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-P                    BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-P L-X L-Y L-Z.
     MOVE 0 TO WS-SET
     MOVE PL-X(L-P) TO WS-TX
     MOVE PL-Y(L-P) TO WS-TY
     MOVE PL-Z(L-P) TO WS-TZ
     COMPUTE WS-DX = WS-TX - (FUNCTION INTEGER(EN-X(L-ROW)) + 0.5)
     COMPUTE WS-DY = WS-TY - (FUNCTION INTEGER(EN-Y(L-ROW)) + 0.5)
     COMPUTE WS-DZ = WS-TZ - (FUNCTION INTEGER(EN-Z(L-ROW)) + 0.5)
     IF WS-DX * WS-DX + WS-DZ * WS-DZ < 16 AND FUNCTION ABS(WS-DY) < 10
         CALL "BREEZE-AWAY-PICK" USING L-ROW WS-TX WS-TZ WS-OK WS-BX WS-BY WS-BZ
         IF WS-OK = 1
             COMPUTE WS-AX = WS-BX + 0.5
             COMPUTE WS-AY = WS-BY + 0.5
             COMPUTE WS-AZ = WS-BZ + 0.5
             COMPUTE WS-AY4 = WS-AY + 4
             CALL "BREEZE-LOS" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-AX WS-AY WS-AZ WS-LIMIT WS-SEE-A
             CALL "BREEZE-LOS" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-AX WS-AY4 WS-AZ WS-LIMIT WS-SEE-B
             COMPUTE WS-DA = (WS-TX - WS-AX) ** 2 + (WS-TY - WS-BY) ** 2 + (WS-TZ - WS-AZ) ** 2
             COMPUTE WS-DB = (WS-TX - EN-X(L-ROW)) ** 2 + (WS-TY - EN-Y(L-ROW)) ** 2 + (WS-TZ - EN-Z(L-ROW)) ** 2
             IF FUNCTION MAX(WS-SEE-A, WS-SEE-B) = 1 AND WS-DA > WS-DB
                 MOVE 1 TO WS-SET
                 MOVE WS-AX TO L-X
                 MOVE WS-BY TO L-Y
                 MOVE WS-AZ TO L-Z
             END-IF
         END-IF
     END-IF
     IF WS-SET = 0
         CALL "XP-RANDOM" USING WS-SALT WS-TWO WS-DRAW
         IF WS-DRAW = 1
*>           randomPointBehindTarget: nextGaussian (a Box-Muller pair of draws) then nextFloat.
             CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
             COMPUTE WS-U1 = (WS-DRAW + 1) / 1000001
             CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
             COMPUTE WS-U2 = WS-DRAW / 1000000
             COMPUTE WS-GAUSS = FUNCTION SQRT(-2 * FUNCTION LOG(WS-U1)) * FUNCTION COS(2 * FUNCTION PI * WS-U2)
             CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
             COMPUTE WS-U1 = WS-DRAW / 1000000
             MOVE PL-YAW(L-P) TO WS-HEAD
             CALL "BREEZE-POINT-BEHIND" USING WS-TX WS-TY WS-TZ WS-HEAD WS-GAUSS WS-U1 L-X L-Y L-Z
         ELSE
             CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
             COMPUTE WS-U1 = WS-DRAW / 1000000
             CALL "BREEZE-POINT-MIDDLE" USING EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-TX WS-TY WS-TZ WS-U1 L-X L-Y L-Z
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BREEZE-SLIDE-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BREEZE-BRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY STDMOBS.
 COPY BREEZESTATE.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SALT                BINARY-LONG VALUE 98.
 01 WS-MILLION             BINARY-LONG VALUE 1000000.
 01 WS-B21                 BINARY-LONG VALUE 21.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-B4                  BINARY-LONG VALUE 4.
 01 WS-B3                  BINARY-LONG VALUE 3.
 01 WS-B2                  BINARY-LONG VALUE 2.
 01 WS-LIMIT               FLOAT-LONG VALUE 50.
 01 WS-FOLLOW              FLOAT-LONG.
 01 WS-GRAVITY             FLOAT-LONG VALUE 0.08.
 01 WS-SLOT                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DRAWS.
    05 WS-DRAW-A           BINARY-LONG OCCURS 4 TIMES.
 01 WS-WET                 BINARY-LONG.
 01 WS-GO                  BINARY-LONG.
 01 WS-STARTED             BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DRAW-BEFORE         BINARY-LONG.
 01 WS-ARRIVED             BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEE-A               BINARY-LONG.
 01 WS-SEE-B               BINARY-LONG.
 01 WS-DANGER              BINARY-LONG.
 01 WS-BLOCKED             BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLUID               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-EYE-Y               BINARY-LONG.
 01 WS-FULL                PIC X(48).
 01 WS-HEAD                FLOAT-LONG.
 01 WS-GAUSS               FLOAT-LONG.
 01 WS-U1                  FLOAT-LONG.
 01 WS-U2                  FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-QX                  FLOAT-LONG.
 01 WS-QY                  FLOAT-LONG.
 01 WS-QZ                  FLOAT-LONG.
 01 WS-CY4                 FLOAT-LONG.
 01 WS-CELL-Y              BINARY-LONG.
 01 WS-ANGLE               BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK
     CALL "BZ-FIND" USING EN-ID(L-ROW) WS-ONE WS-SLOT
*>   Memories count down at the start of a tick.
     IF BZ-SHOOT(WS-SLOT) > 0
         SUBTRACT 1 FROM BZ-SHOOT(WS-SLOT)
     END-IF
     IF BZ-CD(WS-SLOT) > 0
         SUBTRACT 1 FROM BZ-CD(WS-SLOT)
     END-IF
     IF BZ-INHALE(WS-SLOT) > 0
         SUBTRACT 1 FROM BZ-INHALE(WS-SLOT)
     END-IF
*>   StartAttacking (done by STDMOB-AGGRO) erased the cant-reach memory when it set the target.
     IF EN-TARGET(L-ROW) > 0 AND BZ-HAD(WS-SLOT) = 0
         MOVE 0 TO BZ-CANT-ON(WS-SLOT)
     END-IF
     IF BZ-ACT(WS-SLOT) = 2
*>       IDLE: the slide sink (16.1): it starts with the pose SLIDING and a run of 20 to 40 ticks, walks to the walk target and, when it stops, arms the shot.
         IF BZ-WALK(WS-SLOT) = 1
             IF BZ-SINK(WS-SLOT) = 0
                 MOVE 1 TO BZ-SINK(WS-SLOT)
                 MOVE 3 TO BZ-POSE(WS-SLOT)
                 CALL "XP-RANDOM" USING WS-SALT WS-B21 WS-DRAW
                 COMPUTE BZ-SLIDE(WS-SLOT) = 20 + WS-DRAW
             END-IF
             SUBTRACT 1 FROM BZ-SLIDE(WS-SLOT)
             CALL "STDMOB-HEAD" USING L-ROW L-M BZ-WX(WS-SLOT) BZ-WY(WS-SLOT) BZ-WZ(WS-SLOT) L-HX L-HZ WS-ARRIVED
*>           The sink walks at 0.6: the motion goes with the square of the speed against the table's 0.63.
             COMPUTE L-HX = L-HX * 0.36
             COMPUTE L-HZ = L-HZ * 0.36
             MOVE 1 TO L-WALK
             IF WS-ARRIVED = 1 OR BZ-SLIDE(WS-SLOT) <= 0
                 MOVE 0 TO BZ-POSE(WS-SLOT) BZ-WALK(WS-SLOT) BZ-SINK(WS-SLOT)
                 IF EN-TARGET(L-ROW) > 0
                     MOVE 60 TO BZ-SHOOT(WS-SLOT)
                 END-IF
             END-IF
         END-IF
     ELSE
*>       FIGHT: the stop rule first (priority 0).
         CALL "BREEZE-STOP-CHECK" USING L-ROW
         MOVE EN-TARGET(L-ROW) TO WS-P
         CALL "FLUID-TOUCHES-WATER" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-WET
         EVALUATE TRUE
             WHEN BZ-POSE(WS-SLOT) = 1 AND BZ-INHALE(WS-SLOT) > 0
*>               Inhaling.
                 MOVE 2 TO L-WALK
             WHEN BZ-POSE(WS-SLOT) = 1
*>               Finished inhaling: the jump vector from the jump cell's bottom centre (16.4); none: back to STANDING, the memories cleared, no cooldown.
                 MOVE EN-X(L-ROW) TO WS-PX
                 MOVE EN-Y(L-ROW) TO WS-PY
                 MOVE EN-Z(L-ROW) TO WS-PZ
                 COMPUTE WS-QX = BZ-JX(WS-SLOT) + 0.5
                 MOVE BZ-JY(WS-SLOT) TO WS-QY
                 COMPUTE WS-QZ = BZ-JZ(WS-SLOT) + 0.5
                 MOVE SM-FOLLOW(L-M) TO WS-FOLLOW
                 CALL "XP-RANDOM" USING WS-SALT WS-B5 WS-DRAW-A(1)
                 CALL "XP-RANDOM" USING WS-SALT WS-B4 WS-DRAW-A(2)
                 CALL "XP-RANDOM" USING WS-SALT WS-B3 WS-DRAW-A(3)
                 CALL "XP-RANDOM" USING WS-SALT WS-B2 WS-DRAW-A(4)
                 CALL "BREEZE-JUMP-PICK" USING WS-PX WS-PY WS-PZ WS-QX WS-QY WS-QZ WS-FOLLOW WS-GRAVITY WS-DRAWS WS-ANGLE WS-OK
                     WS-VX WS-VY WS-VZ
                 IF WS-OK = 1
                     MOVE 2 TO BZ-POSE(WS-SLOT)
                     MOVE 0 TO BZ-RUN(WS-SLOT)
                     MOVE WS-VX TO BZ-JVX(WS-SLOT) EN-VX(L-ROW)
                     MOVE WS-VZ TO BZ-JVZ(WS-SLOT) EN-VZ(L-ROW)
                     MOVE WS-VY TO EN-VY(L-ROW)
                 ELSE
                     MOVE 0 TO BZ-POSE(WS-SLOT) BZ-JSET(WS-SLOT)
                 END-IF
                 MOVE 2 TO L-WALK
             WHEN BZ-POSE(WS-SLOT) = 2 AND EN-ON-GROUND(L-ROW) = 1
*>               Finished jumping: the jump cooldown 2 ticks with the hurt_by memory (a hit by a player in the last 100 ticks), else 10, and a shot armed for 100.
                 MOVE 0 TO BZ-POSE(WS-SLOT) BZ-JSET(WS-SLOT)
                 MOVE 10 TO BZ-CD(WS-SLOT)
                 IF EN-KILLER-AGE(L-ROW) > 0
                     MOVE 2 TO BZ-CD(WS-SLOT)
                 END-IF
                 MOVE 100 TO BZ-SHOOT(WS-SLOT)
                 MOVE 0 TO BZ-JVX(WS-SLOT) BZ-JVZ(WS-SLOT)
                 MOVE 3 TO L-WALK
             WHEN BZ-POSE(WS-SLOT) = 2
*>               In flight: no horizontal friction (the velocity is set again every tick); the behaviour lasts 200 ticks at most.
                 ADD 1 TO BZ-RUN(WS-SLOT)
                 MOVE BZ-JVX(WS-SLOT) TO EN-VX(L-ROW)
                 MOVE BZ-JVZ(WS-SLOT) TO EN-VZ(L-ROW)
                 IF BZ-RUN(WS-SLOT) > 200
                     MOVE 0 TO BZ-POSE(WS-SLOT) BZ-JSET(WS-SLOT)
                 END-IF
                 MOVE 2 TO L-WALK
             WHEN OTHER
*>               Standing: Shoot (priority 1) when armed or running, then the behaviours that need the shot not running.
                 MOVE EN-DRAW(L-ROW) TO WS-DRAW-BEFORE
                 IF EN-DRAW(L-ROW) > 0 OR (BZ-SHOOT(WS-SLOT) > 0 AND WS-P > 0 AND BZ-WALK(WS-SLOT) = 0)
                     CALL "BREEZE-SHOOT" USING L-ROW L-M
*>                   Shoot.stop erases breeze_shoot.
                     IF (WS-DRAW-BEFORE = 1 OR WS-DRAW-BEFORE = 2) AND (EN-DRAW(L-ROW) = 0 OR EN-DRAW(L-ROW) = 3)
                         MOVE 0 TO BZ-SHOOT(WS-SLOT)
                     END-IF
                 END-IF
                 MOVE 0 TO WS-STARTED
                 IF (EN-DRAW(L-ROW) = 0 OR EN-DRAW(L-ROW) = 3) AND WS-P > 0 AND BZ-WALK(WS-SLOT) = 0 AND BZ-SHOOT(WS-SLOT) = 0
*>                   LongJump (priority 2): canRun, its conditions in the order of 16.4.
                     MOVE 1 TO WS-GO
                     COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Y(WS-P) - EN-Y(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
                     COMPUTE WS-EYE-Y = FUNCTION INTEGER(EN-Y(L-ROW) + 1.3452)
                     COMPUTE WS-K = FUNCTION INTEGER(EN-X(L-ROW))
                     COMPUTE WS-BX = FUNCTION INTEGER(EN-Z(L-ROW))
                     CALL "FLUID-CELL" USING EN-DIM(L-ROW) WS-K WS-EYE-Y WS-BX WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
                         WS-SOLID WS-HOLDS
*>                   1 and 2: cooldown, on the ground or in water, no fluid at the eye (deeper than the fluid jump threshold) and not in lava.
                     IF BZ-CD(WS-SLOT) > 0 OR (EN-ON-GROUND(L-ROW) = 0 AND WS-WET = 0) OR WS-FLUID > 0
                         MOVE 0 TO WS-GO
                     END-IF
*>                   5: not within the follow range 24: the attack target is erased.
                     IF WS-GO = 1 AND WS-D2 >= 576
                         MOVE 0 TO WS-GO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW)
                     END-IF
*>                   6: too close (the float distance less 4.0 at most 0).
                     IF WS-GO = 1 AND WS-D2 <= 16
                         MOVE 0 TO WS-GO
                     END-IF
*>                   7: not honey, and the four blocks above the breeze's block are air or water.
                     IF WS-GO = 1
                         COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
                         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-K WS-BY WS-BX WS-STATE
                         IF WS-STATE > 0
                             CALL "KEY-NAMESPACED" USING CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) WS-FULL
                             IF WS-FULL = "minecraft:honey_block"
                                 MOVE 0 TO WS-GO
                             END-IF
                         END-IF
                         PERFORM VARYING WS-CELL-Y FROM 1 BY 1 UNTIL WS-CELL-Y > 4
                             COMPUTE WS-EYE-Y = WS-BY + WS-CELL-Y
                             CALL "FLUID-CELL" USING EN-DIM(L-ROW) WS-K WS-EYE-Y WS-BX WS-STATE WS-FLUID WS-KIND WS-AMOUNT WS-FALLING
                                 WS-SOLID WS-HOLDS
                             IF WS-HOLDS = 0 AND WS-FLUID NOT = 1
                                 MOVE 0 TO WS-GO
                             END-IF
                         END-PERFORM
                     END-IF
*>                   8 to 10: the snapped cell behind the target, the block below it not dangerous, a line of sight from the feet to its centre or the centre 4 above.
                     IF WS-GO = 1
                         CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
                         COMPUTE WS-U1 = (WS-DRAW + 1) / 1000001
                         CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
                         COMPUTE WS-U2 = WS-DRAW / 1000000
                         COMPUTE WS-GAUSS = FUNCTION SQRT(-2 * FUNCTION LOG(WS-U1)) * FUNCTION COS(2 * FUNCTION PI * WS-U2)
                         CALL "XP-RANDOM" USING WS-SALT WS-MILLION WS-DRAW
                         COMPUTE WS-U1 = WS-DRAW / 1000000
                         MOVE PL-X(WS-P) TO WS-QX
                         MOVE PL-Y(WS-P) TO WS-QY
                         MOVE PL-Z(WS-P) TO WS-QZ
                         MOVE PL-YAW(WS-P) TO WS-HEAD
                         CALL "BREEZE-POINT-BEHIND" USING WS-QX WS-QY WS-QZ WS-HEAD WS-GAUSS WS-U1 WS-PX WS-PY WS-PZ
                         CALL "BREEZE-SNAP" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-OK WS-BX WS-BY WS-BZ
                         CALL "BREEZE-DANGEROUS" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-DANGER
                         COMPUTE WS-PX = WS-BX + 0.5
                         COMPUTE WS-PY = WS-BY + 0.5
                         COMPUTE WS-PZ = WS-BZ + 0.5
                         COMPUTE WS-CY4 = WS-PY + 4
                         CALL "BREEZE-LOS" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-PX WS-PY WS-PZ WS-LIMIT WS-SEE-A
                         CALL "BREEZE-LOS" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-PX WS-CY4 WS-PZ WS-LIMIT WS-SEE-B
                         IF WS-OK = 0 OR WS-DANGER = 1 OR FUNCTION MAX(WS-SEE-A, WS-SEE-B) = 0
                             MOVE 0 TO WS-GO
                         END-IF
                     END-IF
*>                   11: the jump cell is remembered; the start: inhale for 10 ticks, pose INHALING.
                     IF WS-GO = 1
                         MOVE 1 TO BZ-JSET(WS-SLOT) BZ-POSE(WS-SLOT) WS-STARTED
                         MOVE WS-BX TO BZ-JX(WS-SLOT)
                         MOVE WS-BY TO BZ-JY(WS-SLOT)
                         MOVE WS-BZ TO BZ-JZ(WS-SLOT)
                         MOVE 10 TO BZ-INHALE(WS-SLOT)
                         MOVE 2 TO L-WALK
                     END-IF
*>                   ShootWhenStuck (priority 3): in water or riding, with no jump: one shot armed for 60 ticks.
                     IF WS-STARTED = 0 AND (WS-WET = 1 OR EN-MOUNT(L-ROW) > 0)
                         MOVE 60 TO BZ-SHOOT(WS-SLOT)
                         MOVE 1 TO WS-STARTED
                     END-IF
*>                   Slide (priority 4): on the ground, not in water, no cooldown: a walk target at 0.6.
                     IF WS-STARTED = 0 AND BZ-CD(WS-SLOT) = 0 AND EN-ON-GROUND(L-ROW) = 1 AND WS-WET = 0
                         CALL "BREEZE-SLIDE-POINT" USING L-ROW WS-P WS-PX WS-PY WS-PZ
                         COMPUTE BZ-WX(WS-SLOT) = FUNCTION INTEGER(WS-PX)
                         COMPUTE BZ-WY(WS-SLOT) = FUNCTION INTEGER(WS-PY)
                         COMPUTE BZ-WZ(WS-SLOT) = FUNCTION INTEGER(WS-PZ)
                         MOVE 1 TO BZ-WALK(WS-SLOT)
                         CALL "BREEZE-REACHABLE" USING EN-DIM(L-ROW) BZ-WX(WS-SLOT) BZ-WY(WS-SLOT) BZ-WZ(WS-SLOT) WS-OK
                         IF WS-OK = 0 AND BZ-CANT-ON(WS-SLOT) = 0
                             MOVE 1 TO BZ-CANT-ON(WS-SLOT)
                             MOVE CW-TICKS TO BZ-CANT-AT(WS-SLOT)
                         END-IF
                     END-IF
                 END-IF
*>               Standing with a target: face it (the look-at-target sink).
                 IF L-WALK = 0 AND WS-P > 0
                     MOVE 3 TO L-WALK
                 END-IF
         END-EVALUATE
     END-IF
*>   The activity is chosen at the end of the tick: FIGHT with an attack target and no walk target, else IDLE.
     MOVE 2 TO BZ-ACT(WS-SLOT)
     MOVE 0 TO BZ-HAD(WS-SLOT)
     IF EN-TARGET(L-ROW) > 0
         MOVE 1 TO BZ-HAD(WS-SLOT)
         IF BZ-WALK(WS-SLOT) = 0
             MOVE 1 TO BZ-ACT(WS-SLOT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BREEZE-BRAIN.
