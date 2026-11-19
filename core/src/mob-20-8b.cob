*> The enderman's carried block, the take-block and leave-block goals and its metadata 17 and 18 (docs/protocol/20 section 8.1; 002-lane-p49n). State: P49NSTATE.cpy (PN-CARRY: the block
*> state id carried, 0 none; PN-CREEPY and PN-STARED: the flags last sent as metadata 17 and 18).
*>
*>   ENDER-HOLDABLE USING block id, holdable out: the block is in the tag minecraft:enderman_holdable (a block tag of the open content set).
*>   ENDER-RAY-HITS USING dim, tracker row, x, y, z (the target cell), hit out: the ray from the centre of the enderman's block to the centre of the target block (outline context, fluids
*>     ignored) meets that block first (sampled every 0.02 block, the cells passed are tested in order; the enderman's own cell is skipped).
*>   ENDER-TAKE USING tracker row, x, y, z, taken out: Take block (20 section 8.1): needs no carried block, mob_griefing on, a holdable block at the cell and the ray hitting it; the block is
*>     removed and its default state carried.
*>   ENDER-LEAVE USING tracker row, x, y, z, placed out: Leave block: needs a carried block, mob_griefing on, air at the cell, a block below that is not air or bedrock and has a full
*>     collision shape, a carried state that can survive there and no player or mob in the cell; the block is placed and the carry ends.
*>   ENDER-OCCUPIED USING dim, x, y, z, hit out: a living entity's box overlaps the cell.
*>   ENDER-CARRY-TICK USING tracker row: both goals' draws of one tick: take with probability 1 / 20 at (x - 2 + nextDouble x 4, y + nextDouble x 3, z - 2 + nextDouble x 4) floored when not
*>     carrying; leave with probability 1 / 2000 at (x - 1 + nextDouble x 2, y + nextDouble x 2, z - 1 + nextDouble x 2) floored when carrying.
*>   ENDER-CARRIES USING tracker row, carries out: 1 for an enderman that carries a block (it never despawns, requiresCustomPersistence).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-HOLDABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REGISTRY            PIC X(48) VALUE "block".
 01 WS-TAG                 PIC X(112) VALUE "minecraft:enderman_holdable".
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-HOLDABLE             BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-HOLDABLE.
     CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-BLOCK L-HOLDABLE
     GOBACK.
 END PROGRAM ENDER-HOLDABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-RAY-HITS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-ROW L-X L-Y L-Z L-HIT.
     MOVE 0 TO L-HIT WS-DONE
     COMPUTE WS-HX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-HY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-HZ = FUNCTION INTEGER(EN-Z(L-ROW))
     COMPUTE WS-SX = WS-HX + 0.5
     COMPUTE WS-SY = WS-HY + 0.5
     COMPUTE WS-SZ = WS-HZ + 0.5
     COMPUTE WS-DX = L-X + 0.5 - WS-SX
     COMPUTE WS-DY = L-Y + 0.5 - WS-SY
     COMPUTE WS-DZ = L-Z + 0.5 - WS-SZ
     COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     COMPUTE WS-N = FUNCTION INTEGER(WS-LEN * 50) + 1
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-N OR WS-DONE = 1
         COMPUTE WS-T = WS-I / WS-N
         COMPUTE WS-CX = FUNCTION INTEGER(WS-SX + WS-DX * WS-T)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-SY + WS-DY * WS-T)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-SZ + WS-DZ * WS-T)
         IF NOT (WS-CX = WS-HX AND WS-CY = WS-HY AND WS-CZ = WS-HZ)
             CALL "ENDER-RAY-CELL" USING L-DIM WS-CX WS-CY WS-CZ WS-STATE
             IF WS-STATE = 1
                 MOVE 1 TO WS-DONE
                 IF WS-CX = L-X AND WS-CY = L-Y AND WS-CZ = L-Z
                     MOVE 1 TO L-HIT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENDER-RAY-HITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-RAY-CELL.
*> USING dim, x, y, z, blocking out: 1 when the cell holds a block that has an outline (air and fluids have none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-BLOCKING             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-BLOCKING.
     MOVE 0 TO L-BLOCKING
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0
         MOVE 1 TO L-BLOCKING
         IF CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) = "minecraft:water" OR "minecraft:lava" OR "minecraft:bubble_column"
                 OR "minecraft:cave_air" OR "minecraft:void_air" OR "water" OR "lava" OR "bubble_column" OR "cave_air" OR "void_air"
             MOVE 0 TO L-BLOCKING
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENDER-RAY-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-TAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY P49NSTATE.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-HOLDABLE            BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-MOVED               BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TAKEN                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-TAKEN.
     MOVE 0 TO L-TAKEN
     CALL "PN-ROW-OPEN" USING L-ROW
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF PN-CARRY(L-ROW) NOT = 0 OR WS-RULE = 0
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) L-X L-Y L-Z WS-STATE
     IF WS-STATE = 0
         GOBACK
     END-IF
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "ENDER-HOLDABLE" USING WS-BLOCK WS-HOLDABLE
     IF WS-HOLDABLE = 0
         GOBACK
     END-IF
     CALL "ENDER-RAY-HITS" USING EN-DIM(L-ROW) L-ROW L-X L-Y L-Z WS-HIT
     IF WS-HIT = 0
         GOBACK
     END-IF
     CALL "LEVEL-REMOVE-BLOCK" USING EN-DIM(L-ROW) L-X L-Y L-Z WS-MOVED WS-RESULT
     MOVE CB-DEFAULT-STATE(WS-BLOCK + 1) TO PN-CARRY(L-ROW)
     MOVE 1 TO L-TAKEN
     CALL "STDMOB-FLAGS-SEND" USING L-ROW
     GOBACK.
 END PROGRAM ENDER-TAKE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-LEAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY P49NSTATE.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_griefing".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-STATE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-BELOW-Y             BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-PLACED.
     MOVE 0 TO L-PLACED
     CALL "PN-ROW-OPEN" USING L-ROW
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF PN-CARRY(L-ROW) = 0 OR WS-RULE = 0
         GOBACK
     END-IF
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) L-X L-Y L-Z WS-STATE
     IF WS-STATE NOT = 0
         GOBACK
     END-IF
     COMPUTE WS-BELOW-Y = L-Y - 1
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) L-X WS-BELOW-Y L-Z WS-BELOW
     IF WS-BELOW = 0
         GOBACK
     END-IF
     MOVE CB-KEY(CB-S-BLOCK(WS-BELOW + 1) + 1) TO WS-KEY
     IF WS-KEY = "minecraft:bedrock" OR "bedrock" OR CB-SOLID(CB-S-BLOCK(WS-BELOW + 1) + 1) = 0
         GOBACK
     END-IF
     CALL "SUP-SURVIVES" USING EN-DIM(L-ROW) L-X L-Y L-Z PN-CARRY(L-ROW) WS-OK
     IF WS-OK = 0
         GOBACK
     END-IF
     CALL "ENDER-OCCUPIED" USING EN-DIM(L-ROW) L-X L-Y L-Z WS-HIT
     IF WS-HIT = 1
         GOBACK
     END-IF
     CALL "BLOCK-CHANGE" USING EN-DIM(L-ROW) L-X L-Y L-Z PN-CARRY(L-ROW)
     MOVE 0 TO PN-CARRY(L-ROW)
     MOVE 1 TO L-PLACED
     CALL "STDMOB-FLAGS-SEND" USING L-ROW
     GOBACK.
 END PROGRAM ENDER-LEAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-OCCUPIED.
*> USING dim, x, y, z (the cell), hit out: 1 when the box of a living entity (a player or a mob with health, the enderman itself included) overlaps the unit cube with positive volume
*> (faces within 1e-7 only touch; a ground item is no obstacle).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-E                   BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-EPSILON             FLOAT-LONG VALUE 0.0000001.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-HIT.
     MOVE 0 TO L-HIT
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR L-HIT = 1
         IF EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = L-DIM AND (EN-PLAYER(WS-E) > 0 OR EN-HEALTH(WS-E) > 0)
             COMPUTE WS-HALF = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
             COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
             IF L-X < EN-X(WS-E) + WS-HALF - WS-EPSILON
                     AND L-X + 1 > EN-X(WS-E) - WS-HALF + WS-EPSILON
                     AND L-Y < EN-Y(WS-E) + WS-HEIGHT - WS-EPSILON
                     AND L-Y + 1 > EN-Y(WS-E) + WS-EPSILON
                     AND L-Z < EN-Z(WS-E) + WS-HALF - WS-EPSILON
                     AND L-Z + 1 > EN-Z(WS-E) - WS-HALF + WS-EPSILON
                 MOVE 1 TO L-HIT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENDER-OCCUPIED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-CARRY-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 COPY XORO.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-ROLL                BINARY-LONG.
 01 WS-TWENTY              BINARY-LONG VALUE 20.
 01 WS-2000                BINARY-LONG VALUE 2000.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-ROW-OPEN" USING L-ROW
     COMPUTE WS-SEED = EN-ID(L-ROW) * 1000003 + CW-TICKS * 7 + 3
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     IF PN-CARRY(L-ROW) = 0
         CALL "XORO-NEXT-INT" USING XR-STATE WS-TWENTY WS-ROLL
         IF WS-ROLL = 0
             CALL "XORO-NEXT-DOUBLE" USING XR-STATE WS-DRAW
             COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW) - 2 + WS-DRAW * 4)
             CALL "XORO-NEXT-DOUBLE" USING XR-STATE WS-DRAW
             COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW) + WS-DRAW * 3)
             CALL "XORO-NEXT-DOUBLE" USING XR-STATE WS-DRAW
             COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW) - 2 + WS-DRAW * 4)
             CALL "ENDER-TAKE" USING L-ROW WS-X WS-Y WS-Z WS-DONE
         END-IF
     ELSE
         CALL "XORO-NEXT-INT" USING XR-STATE WS-2000 WS-ROLL
         IF WS-ROLL = 0
             CALL "XORO-NEXT-DOUBLE" USING XR-STATE WS-DRAW
             COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW) - 1 + WS-DRAW * 2)
             CALL "XORO-NEXT-DOUBLE" USING XR-STATE WS-DRAW
             COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW) + WS-DRAW * 2)
             CALL "XORO-NEXT-DOUBLE" USING XR-STATE WS-DRAW
             COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW) - 1 + WS-DRAW * 2)
             CALL "ENDER-LEAVE" USING L-ROW WS-X WS-Y WS-Z WS-DONE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ENDER-CARRY-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-CARRIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-CARRIES              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-CARRIES.
     MOVE 0 TO L-CARRIES
     IF PN-ID(L-ROW) = EN-ID(L-ROW) AND PN-CARRY(L-ROW) NOT = 0
         MOVE 1 TO L-CARRIES
     END-IF
     GOBACK.
 END PROGRAM ENDER-CARRIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-STARED-SET.
*> USING tracker row: the enderman took a target because it was stared at (20 section 8.1): metadata 18 goes true with the next ENDER-FLAGS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-ROW-OPEN" USING L-ROW
     MOVE 1 TO PN-STARE-WANT(L-ROW)
     GOBACK.
 END PROGRAM ENDER-STARED-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENDER-FLAGS-TICK.
*> USING tracker row: metadata 17 (creepy) follows "has a target"; 18 (stared at) is set when the target was taken by a stare (ENDER-STARED-SET) and goes false with the target
*> (20 section 8.1); a change of either is sent as Set Entity Data.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 01 WS-CREEPY              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-ROW-OPEN" USING L-ROW
     MOVE 0 TO WS-CREEPY
     IF EN-TARGET(L-ROW) > 0
         MOVE 1 TO WS-CREEPY
     ELSE
         MOVE 0 TO PN-STARE-WANT(L-ROW)
     END-IF
     IF PN-CREEPY(L-ROW) NOT = WS-CREEPY OR PN-STARED(L-ROW) NOT = PN-STARE-WANT(L-ROW)
         MOVE WS-CREEPY TO PN-CREEPY(L-ROW)
         MOVE PN-STARE-WANT(L-ROW) TO PN-STARED(L-ROW)
         CALL "STDMOB-FLAGS-SEND" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM ENDER-FLAGS-TICK.
