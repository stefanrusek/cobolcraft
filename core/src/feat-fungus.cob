*> The huge fungus (docs/protocol/35-worldgen-features-4-decorators-and-vegetation.md section 11.5; registry id 22 huge_fungus; crimson_fungus, warped_fungus and the planted forms):
*> FD-FUNGUS-NODE USING doc, node, row out takes a row of FD-WA: WA-I(1) valid_base_block (a state; only its block matters), (2) stem_state, (3) hat_state, (4) decor_state, (5) planted (0, 1),
*> (6) 1 when the hat block is nether_wart_block, (7) to (9) the weeping_vines head states of age 23, 24, 25 and (10) the weeping_vines_plant state (only when the hat is a wart block), WA-PR(1)
*> replaceable_blocks. A missing member, a state of an unknown block or a missing predicate makes the feature unsupported (FD-BAD).
*> FR-FUNGUS USING state, feature, x, y, z, result out: the block below the origin must be the valid base block; H = 4 + nextInt(10), doubled on nextInt(12) = 0; a feature that is not planted gives
*> false when y + H + 1 >= the generation depth (deviation, recorded: the generation depth is the height of the level, FL-HEIGHT: 384 in the overworld and 128 in the Nether, the noise settings value
*> of each); thick = nextFloat < 0.06 (not planted only); the origin becomes air; the stem; the hat with its decor, wart and weeping vines. Cells outside the chunk read as air and the writes
*> go to the overflow list of the level (feat-level.cob). "canBeReplaced" is air or a block flagged replaceable in the block table (CB-REPLACEABLE); destroying a block sets air (no drops in
*> world generation). Every probability is the float constant of the document (rounded to single precision), except the 0.15 of placeHatDropBlock which the document compares as a double.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-FUNGUS-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 COPY CBLOCKS.
 01 WS-K-BASE              PIC X(40) VALUE "valid_base_block".
 01 WS-K-STEM              PIC X(40) VALUE "stem_state".
 01 WS-K-HAT               PIC X(40) VALUE "hat_state".
 01 WS-K-DECOR             PIC X(40) VALUE "decor_state".
 01 WS-K-REPL              PIC X(40) VALUE "replaceable_blocks".
 01 WS-K-PLANTED           PIC X(40) VALUE "planted".
 01 WS-WART                PIC X(48) VALUE "minecraft:nether_wart_block".
 01 WS-VINES               PIC X(48) VALUE "minecraft:weeping_vines".
 01 WS-PLANT               PIC X(48) VALUE "minecraft:weeping_vines_plant".
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-WARTB               BINARY-LONG.
 01 WS-VB                  BINARY-LONG.
 01 WS-PB                  BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-AGETXT              PIC 99.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-BASE WS-E
     CALL "FD-J-STATE" USING JSON-DOC WS-E WA-I(WS-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-STEM WS-E
     CALL "FD-J-STATE" USING JSON-DOC WS-E WA-I(WS-ROW, 2) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-HAT WS-E
     CALL "FD-J-STATE" USING JSON-DOC WS-E WA-I(WS-ROW, 3) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-DECOR WS-E
     CALL "FD-J-STATE" USING JSON-DOC WS-E WA-I(WS-ROW, 4) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-PLANTED WS-E
     IF WS-E > 0
         IF JN-TYPE(WS-E) = JT-TRUE
             MOVE 1 TO WA-I(WS-ROW, 5)
         END-IF
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-K-REPL WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(WS-ROW, 1)
*>   a wart hat: the weeping vines states of tryPlaceWeepingVines
     CALL "FL-BLOCK-OF" USING WA-I(WS-ROW, 3) WS-BLOCK
     CALL "FD-BLOCK-INDEX" USING WS-WART WS-WARTB
     IF WS-BLOCK > 0 AND WS-BLOCK = WS-WARTB
         MOVE 1 TO WA-I(WS-ROW, 6)
         CALL "FD-BLOCK-INDEX" USING WS-VINES WS-VB
         CALL "FD-BLOCK-INDEX" USING WS-PLANT WS-PB
         IF WS-VB > 0
             MOVE SPACES TO WS-KEY
             MOVE CB-KEY(WS-VB) TO WS-KEY
             PERFORM VARYING WS-AGE FROM 23 BY 1 UNTIL WS-AGE > 25
                 MOVE WS-AGE TO WS-AGETXT
                 MOVE SPACES TO WS-PAIRS
                 STRING "age=" WS-AGETXT DELIMITED BY SIZE INTO WS-PAIRS
                 CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WA-I(WS-ROW, WS-AGE - 16)
             END-PERFORM
         END-IF
         IF WS-PB > 0
             MOVE CB-DEFAULT-STATE(WS-PB) TO WA-I(WS-ROW, 10)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FD-FUNGUS-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FUNGUS.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY CBLOCKS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLANTED             BINARY-LONG.
 01 WS-WART                BINARY-LONG.
 01 WS-THICK               BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-B10                 BINARY-LONG VALUE 10.
 01 WS-B12                 BINARY-LONG VALUE 12.
 01 WS-B3                  BINARY-LONG VALUE 3.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-B7                  BINARY-LONG VALUE 7.
 01 WS-B11                 BINARY-LONG VALUE 11.
 01 WS-BOUND               BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BASEB               BINARY-LONG.
 01 WS-HATB                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS3              BINARY-LONG VALUE 3.
 01 WS-FLAGS2              BINARY-LONG VALUE 2.
 01 WS-FLAGS260            BINARY-LONG VALUE 260.
 01 WS-F                   FLOAT-LONG.
 01 WS-C006                FLOAT-LONG.
 01 WS-C01                 FLOAT-LONG.
 01 WS-C02                 FLOAT-LONG.
 01 WS-C0001               FLOAT-LONG.
 01 WS-C001                FLOAT-LONG.
 01 WS-C07                 FLOAT-LONG.
 01 WS-C0083               FLOAT-LONG.
 01 WS-C00005              FLOAT-LONG.
 01 WS-C098                FLOAT-LONG.
 01 WS-C007                FLOAT-LONG.
 01 WS-C015                FLOAT-LONG.
 01 WS-CD                  FLOAT-LONG.
 01 WS-CH                  FLOAT-LONG.
 01 WS-CV                  FLOAT-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-WITHPRED            BINARY-LONG.
 01 WS-REPL                BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-NOTAIR              BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-NR                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-CORNER              BINARY-LONG.
 01 WS-HATH                BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-EDGEX               BINARY-LONG.
 01 WS-EDGEZ               BINARY-LONG.
 01 WS-INNER               BINARY-LONG.
 01 WS-LOWRING             BINARY-LONG.
 01 WS-SETSTATE            BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CUR-Y               BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-CELL-Y              BINARY-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VY                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     MOVE WA-I(WS-ROW, 5) TO WS-PLANTED
     MOVE WA-I(WS-ROW, 6) TO WS-WART
*>   1. the block below is the valid base block
     COMPUTE WS-YB = L-Y - 1
     CALL "FL-GET-STATE" USING L-X WS-YB L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     MOVE WA-I(WS-ROW, 1) TO WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BASEB
     IF WS-BLOCK NOT = WS-BASEB
         GOBACK
     END-IF
     PERFORM INIT-CONSTANTS
*>   2. the height
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B10 WS-DRAW
     COMPUTE WS-H = 4 + WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B12 WS-DRAW
     IF WS-DRAW = 0
         COMPUTE WS-H = WS-H * 2
     END-IF
*>   3. the generation depth
     IF WS-PLANTED = 0 AND L-Y + WS-H + 1 >= FL-HEIGHT
         GOBACK
     END-IF
*>   4. thick
     MOVE 0 TO WS-THICK
     IF WS-PLANTED = 0
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         IF WS-F < WS-C006
             MOVE 1 TO WS-THICK
         END-IF
     END-IF
*>   5. the origin, the stem, the hat
     CALL "FL-SET-STATE" USING L-X L-Y L-Z FL-S-AIR WS-FLAGS260 WS-WRITTEN
     PERFORM PLACE-STEM
     PERFORM PLACE-HAT
     MOVE 1 TO L-RESULT
     GOBACK.
*> INIT-CONSTANTS: the float constants of the document rounded to single precision
 INIT-CONSTANTS.
     MOVE 0.06 TO WS-C006
     MOVE 0.1 TO WS-C01
     MOVE 0.2 TO WS-C02
     MOVE 0.01 TO WS-C001
     MOVE 0.7 TO WS-C07
     MOVE 0.083 TO WS-C0083
     MOVE 0.0005 TO WS-C00005
     MOVE 0.98 TO WS-C098
     MOVE 0.07 TO WS-C007
     CALL "FR-F32" USING WS-C006
     CALL "FR-F32" USING WS-C01
     CALL "FR-F32" USING WS-C02
     CALL "FR-F32" USING WS-C001
     CALL "FR-F32" USING WS-C07
     CALL "FR-F32" USING WS-C0083
     CALL "FR-F32" USING WS-C00005
     CALL "FR-F32" USING WS-C098
     CALL "FR-F32" USING WS-C007
     MOVE 0.15 TO WS-C015
     .
*> IS-REPLACEABLE: WS-REPL = 1 when the cell (WS-PX, WS-PY, WS-PZ) is air or a replaceable block, or (WS-WITHPRED = 1) matches replaceable_blocks
 IS-REPLACEABLE.
     MOVE 0 TO WS-REPL
     CALL "FL-GET-STATE" USING WS-PX WS-PY WS-PZ WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-CLASS = 1
         MOVE 1 TO WS-REPL
     ELSE
         IF WS-BLOCK > 0 AND CB-REPLACEABLE(WS-BLOCK) = 1
             MOVE 1 TO WS-REPL
         ELSE
             IF WS-WITHPRED = 1
                 CALL "FR-PRED-TEST" USING WA-PR(WS-ROW, 1) WS-PX WS-PY WS-PZ WS-TEST
                 MOVE WS-TEST TO WS-REPL
             END-IF
         END-IF
     END-IF
     .
*> BELOW-NOT-AIR: WS-NOTAIR = 1 when the block below (WS-PX, WS-PY, WS-PZ) is not air
 BELOW-NOT-AIR.
     COMPUTE WS-YB = WS-PY - 1
     CALL "FL-GET-STATE" USING WS-PX WS-YB WS-PZ WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     MOVE 0 TO WS-NOTAIR
     IF WS-CLASS NOT = 1
         MOVE 1 TO WS-NOTAIR
     END-IF
     .
 PLACE-STEM.
     IF WS-THICK = 1
         MOVE 1 TO WS-R
     ELSE
         MOVE 0 TO WS-R
     END-IF
     COMPUTE WS-NR = 0 - WS-R
     PERFORM VARYING WS-DX FROM WS-NR BY 1 UNTIL WS-DX > WS-R
         PERFORM VARYING WS-DZ FROM WS-NR BY 1 UNTIL WS-DZ > WS-R
             MOVE 0 TO WS-CORNER
             IF WS-THICK = 1 AND FUNCTION ABS(WS-DX) = WS-R AND FUNCTION ABS(WS-DZ) = WS-R
                 MOVE 1 TO WS-CORNER
             END-IF
             PERFORM VARYING WS-DY FROM 0 BY 1 UNTIL WS-DY >= WS-H
                 COMPUTE WS-PX = L-X + WS-DX
                 COMPUTE WS-PY = L-Y + WS-DY
                 COMPUTE WS-PZ = L-Z + WS-DZ
                 MOVE 1 TO WS-WITHPRED
                 PERFORM IS-REPLACEABLE
                 IF WS-REPL = 1
                     PERFORM STEM-CELL
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
 STEM-CELL.
     MOVE WA-I(WS-ROW, 2) TO WS-SETSTATE
     IF WS-PLANTED = 1
         PERFORM BELOW-NOT-AIR
         IF WS-NOTAIR = 1
             CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ FL-S-AIR WS-FLAGS3 WS-WRITTEN
         END-IF
         CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-SETSTATE WS-FLAGS3 WS-WRITTEN
     ELSE
         IF WS-CORNER = 1
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             IF WS-F < WS-C01
                 CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-SETSTATE WS-FLAGS3 WS-WRITTEN
             END-IF
         ELSE
             CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-SETSTATE WS-FLAGS3 WS-WRITTEN
         END-IF
     END-IF
     .
 PLACE-HAT.
     MOVE WA-I(WS-ROW, 3) TO WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-HATB
     COMPUTE WS-BOUND = 1 + WS-H / 3
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
     COMPUTE WS-HATH = WS-DRAW + 5
     IF WS-HATH > WS-H
         MOVE WS-H TO WS-HATH
     END-IF
     COMPUTE WS-BOTTOM = WS-H - WS-HATH
     PERFORM VARYING WS-LAYER FROM WS-BOTTOM BY 1 UNTIL WS-LAYER > WS-H
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B3 WS-DRAW
         IF WS-LAYER < WS-H - WS-DRAW
             MOVE 2 TO WS-R
         ELSE
             MOVE 1 TO WS-R
         END-IF
         IF WS-HATH > 8 AND WS-LAYER < WS-BOTTOM + 4
             MOVE 3 TO WS-R
         END-IF
         IF WS-THICK = 1
             ADD 1 TO WS-R
         END-IF
         COMPUTE WS-NR = 0 - WS-R
         PERFORM VARYING WS-DX FROM WS-NR BY 1 UNTIL WS-DX > WS-R
             PERFORM VARYING WS-DZ FROM WS-NR BY 1 UNTIL WS-DZ > WS-R
                 PERFORM HAT-CELL
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .
*> HAT-CELL: the cell (dx, WS-LAYER, dz) of the hat
 HAT-CELL.
     MOVE 0 TO WS-EDGEX WS-EDGEZ WS-INNER WS-CORNER WS-LOWRING
     IF FUNCTION ABS(WS-DX) = WS-R
         MOVE 1 TO WS-EDGEX
     END-IF
     IF FUNCTION ABS(WS-DZ) = WS-R
         MOVE 1 TO WS-EDGEZ
     END-IF
     IF WS-EDGEX = 0 AND WS-EDGEZ = 0 AND WS-LAYER NOT = WS-H
         MOVE 1 TO WS-INNER
     END-IF
     IF WS-EDGEX = 1 AND WS-EDGEZ = 1
         MOVE 1 TO WS-CORNER
     END-IF
     IF WS-LAYER < WS-BOTTOM + 3
         MOVE 1 TO WS-LOWRING
     END-IF
     COMPUTE WS-PX = L-X + WS-DX
     COMPUTE WS-PY = L-Y + WS-LAYER
     COMPUTE WS-PZ = L-Z + WS-DZ
     MOVE 0 TO WS-WITHPRED
     PERFORM IS-REPLACEABLE
     IF WS-REPL = 0
         EXIT PARAGRAPH
     END-IF
     IF WS-PLANTED = 1
         PERFORM BELOW-NOT-AIR
         IF WS-NOTAIR = 1
             CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ FL-S-AIR WS-FLAGS3 WS-WRITTEN
         END-IF
     END-IF
     EVALUATE TRUE
         WHEN WS-LOWRING = 1
             IF WS-INNER = 0
                 PERFORM HAT-DROP-BLOCK
             END-IF
         WHEN WS-INNER = 1
             MOVE WS-C01 TO WS-CD
             MOVE WS-C02 TO WS-CH
             MOVE 0 TO WS-CV
             IF WS-WART = 1
                 MOVE WS-C01 TO WS-CV
             END-IF
             PERFORM HAT-BLOCK
         WHEN WS-CORNER = 1
             MOVE WS-C001 TO WS-CD
             MOVE WS-C07 TO WS-CH
             MOVE 0 TO WS-CV
             IF WS-WART = 1
                 MOVE WS-C0083 TO WS-CV
             END-IF
             PERFORM HAT-BLOCK
         WHEN OTHER
             MOVE WS-C00005 TO WS-CD
             MOVE WS-C098 TO WS-CH
             MOVE 0 TO WS-CV
             IF WS-WART = 1
                 MOVE WS-C007 TO WS-CV
             END-IF
             PERFORM HAT-BLOCK
     END-EVALUATE
     .
*> HAT-BLOCK: placeHatBlock at (WS-PX, WS-PY, WS-PZ) with the chances WS-CD (decor), WS-CH (hat), WS-CV (vines)
 HAT-BLOCK.
     CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
     IF WS-F < WS-CD
         MOVE WA-I(WS-ROW, 4) TO WS-SETSTATE
         CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-SETSTATE WS-FLAGS3 WS-WRITTEN
     ELSE
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         IF WS-F < WS-CH
             MOVE WA-I(WS-ROW, 3) TO WS-SETSTATE
             CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-SETSTATE WS-FLAGS3 WS-WRITTEN
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             IF WS-F < WS-CV
                 PERFORM WEEPING-VINES
             END-IF
         END-IF
     END-IF
     .
*> HAT-DROP-BLOCK: placeHatDropBlock at (WS-PX, WS-PY, WS-PZ)
 HAT-DROP-BLOCK.
     COMPUTE WS-YB = WS-PY - 1
     CALL "FL-GET-STATE" USING WS-PX WS-YB WS-PZ WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK = WS-HATB
         MOVE WA-I(WS-ROW, 3) TO WS-SETSTATE
         CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-SETSTATE WS-FLAGS3 WS-WRITTEN
     ELSE
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         IF WS-F < WS-C015
             MOVE WA-I(WS-ROW, 3) TO WS-SETSTATE
             CALL "FL-SET-STATE" USING WS-PX WS-PY WS-PZ WS-SETSTATE WS-FLAGS3 WS-WRITTEN
             IF WS-WART = 1
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B11 WS-DRAW
                 IF WS-DRAW = 0
                     PERFORM WEEPING-VINES
                 END-IF
             END-IF
         END-IF
     END-IF
     .
*> WEEPING-VINES: tryPlaceWeepingVines below (WS-PX, WS-PY, WS-PZ)
 WEEPING-VINES.
     MOVE WS-PX TO WS-VX
     COMPUTE WS-VY = WS-PY - 1
     MOVE WS-PZ TO WS-VZ
     CALL "FL-GET-STATE" USING WS-VX WS-VY WS-VZ WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS NOT = 1
         EXIT PARAGRAPH
     END-IF
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-DRAW
     COMPUTE WS-LEN = 1 + WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B7 WS-DRAW
     IF WS-DRAW = 0
         COMPUTE WS-LEN = WS-LEN * 2
     END-IF
     MOVE 0 TO WS-STOP
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-LEN OR WS-STOP = 1
         CALL "FL-GET-STATE" USING WS-VX WS-VY WS-VZ WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS = 1
             COMPUTE WS-YB = WS-VY - 1
             CALL "FL-GET-STATE" USING WS-VX WS-YB WS-VZ WS-STATE
             CALL "FL-CLASS" USING WS-STATE WS-CLASS
             IF WS-I = WS-LEN OR WS-CLASS NOT = 1
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B3 WS-DRAW
                 MOVE WA-I(WS-ROW, 7 + WS-DRAW) TO WS-SETSTATE
                 CALL "FL-SET-STATE" USING WS-VX WS-VY WS-VZ WS-SETSTATE WS-FLAGS2 WS-WRITTEN
                 MOVE 1 TO WS-STOP
             ELSE
                 MOVE WA-I(WS-ROW, 10) TO WS-SETSTATE
                 CALL "FL-SET-STATE" USING WS-VX WS-VY WS-VZ WS-SETSTATE WS-FLAGS2 WS-WRITTEN
             END-IF
         END-IF
         SUBTRACT 1 FROM WS-VY
     END-PERFORM
     .
 END PROGRAM FR-FUNGUS.
