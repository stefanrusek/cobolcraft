*> The trunk placers of the tree feature (docs/protocol/35-worldgen-features-3-tree-placers.md section 4): FR-TRUNK places the soil, the logs and the foliage attachments of the trunk placer of a
*> feature row into the work area of TREEWORK.cpy (nothing is written to the level here). Supported: straight 4.1, forking 4.2, giant 4.3, mega jungle 4.4, dark oak 4.5, fancy 4.6.
*> placeLog (section 1) is FR-TREE-LOG: the position must be air or replaceable by trees in the level and not already a log of this tree (in the game the first log written makes the
*> position invalid for a second one, so the first axis stays). The fancy trunk uses the doubles of java.lang.Math (here the decimal arithmetic of the compiler, deterministic), the mega
*> jungle trunk the sine table of 11 section 4 (IP-MTH-SIN and IP-MTH-COS rounded to float).
*>
*> Entry points: FR-TRUNK USING state, feature row, x, y, z (the root origin), height (the clipped height of 2.2 step 8).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-F32.
*> USING value (FLOAT-LONG, in and out): the value rounded to the nearest single precision float (Java float arithmetic steps through this).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IN                  FLOAT-LONG.
 01 WS-OUT                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-VALUE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-VALUE.
     MOVE L-VALUE TO WS-IN
     CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-IN WS-OUT
     MOVE WS-OUT TO L-VALUE
     GOBACK.
 END PROGRAM FR-F32.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-LOG.
*> USING x, y, z, axis (the state offset: -1 x, 0 y, 1 z), placed out: placeLog (section 1) into the work area.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-CELL                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-AXIS L-PLACED.
     MOVE 0 TO L-PLACED
     CALL "FR-TREE-CELL" USING L-X L-Y L-Z WS-CELL
     IF WS-CELL > 0
         IF TW-GRID(WS-CELL) = 0
             CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
             CALL "FR-TREE-OK" USING TW-REPL-START TW-REPL-N WS-STATE L-PLACED
             IF L-PLACED = 0 AND TW-CGT-N > 0
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 CALL "FR-POOL-HAS" USING TW-CGT-START TW-CGT-N WS-BLOCK L-PLACED
             END-IF
             IF L-PLACED = 1
                 ADD 1 TO TW-NLOG
                 MOVE L-X TO TW-LOG-X(TW-NLOG)
                 MOVE L-Y TO TW-LOG-Y(TW-NLOG)
                 MOVE L-Z TO TW-LOG-Z(TW-NLOG)
                 MOVE L-AXIS TO TW-LOG-A(TW-NLOG)
                 MOVE 1 TO TW-GRID(WS-CELL)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-TREE-LOG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-SOIL.
*> USING feature row, x, y, z: placeBelowTrunkBlock (section 1) with the soil_beneath_tree provider: the soil state goes under the trunk unless the block is in cannot_replace_below_tree_trunk.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY TREEWORK.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z.
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     CALL "FR-POOL-HAS" USING TR-CANT-START(L-ROW) TR-CANT-N(L-ROW) WS-BLOCK WS-OK
     IF WS-OK = 0
         ADD 1 TO TW-NSOIL
         MOVE L-X TO TW-SOIL-X(TW-NSOIL)
         MOVE L-Y TO TW-SOIL-Y(TW-NSOIL)
         MOVE L-Z TO TW-SOIL-Z(TW-NSOIL)
     END-IF
     GOBACK.
 END PROGRAM FR-TREE-SOIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-ATT.
*> USING x, y, z, radius offset, double flag: adds a foliage attachment (1.1) to the work area.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-R                    BINARY-LONG.
 01 L-D                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-R L-D.
     ADD 1 TO TW-NATT
     MOVE L-X TO TW-ATT-X(TW-NATT)
     MOVE L-Y TO TW-ATT-Y(TW-NATT)
     MOVE L-Z TO TW-ATT-Z(TW-NATT)
     MOVE L-R TO TW-ATT-R(TW-NATT)
     MOVE L-D TO TW-ATT-D(TW-NATT)
     GOBACK.
 END PROGRAM FR-TREE-ATT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TREE-FREE.
*> USING x, y, z, flag out: TrunkPlacer.isFree (section 1): validTreePos or a block of the tag logs.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-FLAG.
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FR-TREE-OK" USING TW-REPL-START TW-REPL-N WS-STATE L-FLAG
     IF L-FLAG = 0
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         CALL "FR-POOL-HAS" USING TW-LOGS-START TW-LOGS-N WS-BLOCK L-FLAG
     END-IF
     GOBACK.
 END PROGRAM FR-TREE-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK-STRAIGHT.
*> USING row, x, y, z, height: 4.1: the soil under the origin, H logs, the attachment on top (radius offset 0, single).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-H.
     COMPUTE WS-Y = L-Y - 1
     CALL "FR-TREE-SOIL" USING L-ROW L-X WS-Y L-Z
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-H
         COMPUTE WS-Y = L-Y + WS-I
         CALL "FR-TREE-LOG" USING L-X WS-Y L-Z WS-ZERO WS-PLACED
     END-PERFORM
     COMPUTE WS-Y = L-Y + L-H
     CALL "FR-TREE-ATT" USING L-X WS-Y L-Z WS-ZERO WS-ZERO2
     GOBACK.
 END PROGRAM FR-TRUNK-STRAIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK-GIANT.
*> USING row, x, y, z, height: 4.3: the soil under the four cells (origin, east, south, south east), then per layer the origin log and, below the top layer, the east, south east and south
*> logs; the attachment (o + H, radius offset 0) is a double trunk one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-H.
     COMPUTE WS-X1 = L-X + 1
     COMPUTE WS-Z1 = L-Z + 1
     COMPUTE WS-Y = L-Y - 1
     CALL "FR-TREE-SOIL" USING L-ROW L-X WS-Y L-Z
     CALL "FR-TREE-SOIL" USING L-ROW WS-X1 WS-Y L-Z
     CALL "FR-TREE-SOIL" USING L-ROW L-X WS-Y WS-Z1
     CALL "FR-TREE-SOIL" USING L-ROW WS-X1 WS-Y WS-Z1
     COMPUTE WS-LAST = L-H - 1
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-H
         COMPUTE WS-Y = L-Y + WS-I
         CALL "FR-TREE-LOG" USING L-X WS-Y L-Z WS-ZERO WS-PLACED
         IF WS-I < WS-LAST
             CALL "FR-TREE-LOG" USING WS-X1 WS-Y L-Z WS-ZERO WS-PLACED
             CALL "FR-TREE-LOG" USING WS-X1 WS-Y WS-Z1 WS-ZERO WS-PLACED
             CALL "FR-TREE-LOG" USING L-X WS-Y WS-Z1 WS-ZERO WS-PLACED
         END-IF
     END-PERFORM
     COMPUTE WS-Y = L-Y + L-H
     CALL "FR-TREE-ATT" USING L-X WS-Y L-Z WS-ZERO WS-ONE
     GOBACK.
 END PROGRAM FR-TRUNK-GIANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK-DARK.
*> USING state, row, x, y, z, height: 4.5: the soil under the four cells; direction, lean (H - nextInt(4)) and steps (2 - nextInt(3)) are drawn in that order; per layer the column moves
*> along the direction once the layer reaches the lean while steps remain, and when the cell is air or leaves four logs are placed (the cell, east, south, south east); the top attachment is
*> a double trunk one; then the twelve cells around the 2 x 2 origin each keep a branch with probability 1/3, a branch being 2 to 4 logs hanging from the top and a single attachment.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-LEAN                BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-H.
     COMPUTE WS-X1 = L-X + 1
     COMPUTE WS-Z1 = L-Z + 1
     COMPUTE WS-Y = L-Y - 1
     CALL "FR-TREE-SOIL" USING L-ROW L-X WS-Y L-Z
     CALL "FR-TREE-SOIL" USING L-ROW WS-X1 WS-Y L-Z
     CALL "FR-TREE-SOIL" USING L-ROW L-X WS-Y WS-Z1
     CALL "FR-TREE-SOIL" USING L-ROW WS-X1 WS-Y WS-Z1
     CALL "F353-RANDOM-DIRECTION" USING L-STATE WS-DIR
     CALL "F353-STEP" USING WS-DIR WS-DX WS-DY WS-DZ
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR WS-DRAW
     COMPUTE WS-LEAN = L-H - WS-DRAW
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-THREE WS-DRAW
     COMPUTE WS-STEPS = 2 - WS-DRAW
     MOVE L-X TO WS-CX
     MOVE L-Z TO WS-CZ
     COMPUTE WS-TOP = L-Y + L-H - 1
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-H
         IF WS-I >= WS-LEAN AND WS-STEPS > 0
             ADD WS-DX TO WS-CX
             ADD WS-DZ TO WS-CZ
             SUBTRACT 1 FROM WS-STEPS
         END-IF
         COMPUTE WS-Y = L-Y + WS-I
         CALL "FL-GET-STATE" USING WS-CX WS-Y WS-CZ WS-STATE
         CALL "FR-TREE-OK" USING TW-LVS-START TW-LVS-N WS-STATE WS-OK
         IF WS-OK = 1
             COMPUTE WS-PX = WS-CX + 1
             COMPUTE WS-PZ = WS-CZ + 1
             CALL "FR-TREE-LOG" USING WS-CX WS-Y WS-CZ WS-ZERO WS-PLACED
             CALL "FR-TREE-LOG" USING WS-PX WS-Y WS-CZ WS-ZERO WS-PLACED
             CALL "FR-TREE-LOG" USING WS-CX WS-Y WS-PZ WS-ZERO WS-PLACED
             CALL "FR-TREE-LOG" USING WS-PX WS-Y WS-PZ WS-ZERO WS-PLACED
         END-IF
     END-PERFORM
     CALL "FR-TREE-ATT" USING WS-CX WS-TOP WS-CZ WS-ZERO WS-ONE
     PERFORM VARYING WS-A FROM -1 BY 1 UNTIL WS-A > 2
         PERFORM VARYING WS-B FROM -1 BY 1 UNTIL WS-B > 2
             IF WS-A < 0 OR WS-A > 1 OR WS-B < 0 OR WS-B > 1
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-THREE WS-DRAW
                 IF WS-DRAW = 0
                     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-THREE WS-DRAW
                     COMPUTE WS-N = WS-DRAW + 2
                     COMPUTE WS-PX = L-X + WS-A
                     COMPUTE WS-PZ = L-Z + WS-B
                     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= WS-N
                         COMPUTE WS-Y = WS-TOP - WS-K - 1
                         CALL "FR-TREE-LOG" USING WS-PX WS-Y WS-PZ WS-ZERO WS-PLACED
                     END-PERFORM
                     CALL "FR-TREE-ATT" USING WS-PX WS-TOP WS-PZ WS-ZERO WS-ZERO2
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM FR-TRUNK-DARK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK-MEGAJ.
*> USING state, row, x, y, z, height: 4.4: the giant trunk, then from y = H - 2 - nextInt(4) downwards (while y > H / 2, in steps of 2 + nextInt(4)) a branch of five logs along the angle
*> nextFloat() * 2 pi: log k at (1.5 + cos(a) k, y - 3 + k / 2, 1.5 + sin(a) k) cut to the integer toward zero (sine table, float arithmetic), and an attachment of radius offset -2 at its end.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KH                  BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-TAU                 FLOAT-LONG VALUE 6.2831854820251465.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-MINUS2              BINARY-LONG VALUE -2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-H.
     CALL "FR-TRUNK-GIANT" USING L-ROW L-X L-Y L-Z L-H
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR WS-DRAW
     COMPUTE WS-Y = L-H - 2 - WS-DRAW
     COMPUTE WS-HALF = L-H / 2
     PERFORM UNTIL WS-Y <= WS-HALF
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         COMPUTE WS-A = WS-F * WS-TAU
         CALL "FR-F32" USING WS-A
         CALL "IP-MTH-COS" USING WS-A WS-COS
         CALL "FR-F32" USING WS-COS
         CALL "IP-MTH-SIN" USING WS-A WS-SIN
         CALL "FR-F32" USING WS-SIN
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 4
             COMPUTE WS-P = WS-COS * WS-K
             CALL "FR-F32" USING WS-P
             COMPUTE WS-P = WS-P + 1.5
             CALL "FR-F32" USING WS-P
             COMPUTE WS-IX = FUNCTION INTEGER-PART(WS-P)
             COMPUTE WS-P = WS-SIN * WS-K
             CALL "FR-F32" USING WS-P
             COMPUTE WS-P = WS-P + 1.5
             CALL "FR-F32" USING WS-P
             COMPUTE WS-IZ = FUNCTION INTEGER-PART(WS-P)
             COMPUTE WS-PX = L-X + WS-IX
             DIVIDE WS-K BY 2 GIVING WS-KH
             COMPUTE WS-PY = L-Y + WS-Y - 3 + WS-KH
             COMPUTE WS-PZ = L-Z + WS-IZ
             CALL "FR-TREE-LOG" USING WS-PX WS-PY WS-PZ WS-ZERO WS-PLACED
         END-PERFORM
         COMPUTE WS-PY = L-Y + WS-Y
         CALL "FR-TREE-ATT" USING WS-PX WS-PY WS-PZ WS-MINUS2 WS-ZERO
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR WS-DRAW
         COMPUTE WS-Y = WS-Y - 2 - WS-DRAW
     END-PERFORM
     GOBACK.
 END PROGRAM FR-TRUNK-MEGAJ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK-FORK.
*> USING state, row, x, y, z, height: 4.2: the soil under the origin; direction, lean (H - nextInt(4) - 1) and steps (3 - nextInt(3)); the first limb places H logs, shifting one cell along the
*> direction at every layer from the lean on while steps remain, and gives an attachment (radius offset 1) above its last placed log; a second direction (drawn always) different from
*> the first gives a second limb of at most min(len, H - j0) logs from layer j0 = lean - nextInt(2) - 1 (len = 1 + nextInt(3)), one cell off the origin column and moving along its direction,
*> with an attachment (radius offset 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-DIR2                BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-LEAN                BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-J0                  BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-H.
     COMPUTE WS-Y = L-Y - 1
     CALL "FR-TREE-SOIL" USING L-ROW L-X WS-Y L-Z
     CALL "F353-RANDOM-DIRECTION" USING L-STATE WS-DIR
     CALL "F353-STEP" USING WS-DIR WS-DX WS-DY WS-DZ
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-FOUR WS-DRAW
     COMPUTE WS-LEAN = L-H - WS-DRAW - 1
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-THREE WS-DRAW
     COMPUTE WS-STEPS = 3 - WS-DRAW
     MOVE L-X TO WS-CX
     MOVE L-Z TO WS-CZ
     MOVE -99999 TO WS-TOP
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-H
         COMPUTE WS-Y = L-Y + WS-I
         IF WS-I >= WS-LEAN AND WS-STEPS > 0
             ADD WS-DX TO WS-CX
             ADD WS-DZ TO WS-CZ
             SUBTRACT 1 FROM WS-STEPS
         END-IF
         CALL "FR-TREE-LOG" USING WS-CX WS-Y WS-CZ WS-ZERO WS-PLACED
         IF WS-PLACED = 1
             COMPUTE WS-TOP = WS-Y + 1
         END-IF
     END-PERFORM
     IF WS-TOP > -99999
         CALL "FR-TREE-ATT" USING WS-CX WS-TOP WS-CZ WS-ONE WS-ZERO
     END-IF
     MOVE L-X TO WS-CX
     MOVE L-Z TO WS-CZ
     CALL "F353-RANDOM-DIRECTION" USING L-STATE WS-DIR2
     IF WS-DIR2 NOT = WS-DIR
         CALL "F353-STEP" USING WS-DIR2 WS-DX WS-DY WS-DZ
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TWO WS-DRAW
         COMPUTE WS-J0 = WS-LEAN - WS-DRAW - 1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-THREE WS-DRAW
         COMPUTE WS-LEN = 1 + WS-DRAW
         MOVE -99999 TO WS-TOP
         COMPUTE WS-N = FUNCTION MAX(FUNCTION MIN(WS-LEN, L-H - WS-J0), 0)
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-N
             COMPUTE WS-J = WS-J0 + WS-I
             IF WS-J >= 1
                 COMPUTE WS-Y = L-Y + WS-J
                 ADD WS-DX TO WS-CX
                 ADD WS-DZ TO WS-CZ
                 CALL "FR-TREE-LOG" USING WS-CX WS-Y WS-CZ WS-ZERO WS-PLACED
                 IF WS-PLACED = 1
                     COMPUTE WS-TOP = WS-Y + 1
                 END-IF
             END-IF
         END-PERFORM
         IF WS-TOP > -99999
             CALL "FR-TREE-ATT" USING WS-CX WS-TOP WS-CZ WS-ZERO WS-ZERO2
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FR-TRUNK-FORK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FANCY-SHAPE.
*> USING T, y, shape out (FLOAT-LONG): treeShape (4.6) in float arithmetic: -1 below 0.3 T, 0 beyond the half height, else half the root of half^2 - d^2 (half at d = 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C03                 FLOAT-LONG VALUE 0.30000001192092896.
 01 WS-LIM                 FLOAT-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-SHAPE                FLOAT-LONG.
 PROCEDURE DIVISION USING L-T L-Y L-SHAPE.
     COMPUTE WS-LIM = L-T * WS-C03
     CALL "FR-F32" USING WS-LIM
     COMPUTE WS-HALF = L-T / 2
     COMPUTE WS-D = WS-HALF - L-Y
     MOVE 0 TO L-SHAPE
     EVALUATE TRUE
         WHEN L-Y < WS-LIM
             MOVE -1 TO L-SHAPE
         WHEN WS-D = 0
             COMPUTE L-SHAPE = WS-HALF * 0.5
         WHEN FUNCTION ABS(WS-D) < WS-HALF
             COMPUTE WS-V = FUNCTION SQRT(WS-HALF * WS-HALF - WS-D * WS-D)
             CALL "FR-F32" USING WS-V
             COMPUTE L-SHAPE = WS-V * 0.5
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-FANCY-SHAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-FANCY-LIMB.
*> USING ax, ay, az, bx, by, bz, place, ok out: makeLimb (4.6): the cells a + floor(0.5 + j s) for j = 0 .. n, n the largest axis distance, s the float step; placing mode places logs with the
*> axis of the largest horizontal offset (y when there is none); checking mode stops at the first cell that is not free and returns 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-FREE                BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-SX                  FLOAT-LONG.
 01 WS-SY                  FLOAT-LONG.
 01 WS-SZ                  FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-AX                   BINARY-LONG.
 01 L-AY                   BINARY-LONG.
 01 L-AZ                   BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-PLACE                BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-AX L-AY L-AZ L-BX L-BY L-BZ L-PLACE L-OK.
     MOVE 1 TO L-OK
     COMPUTE WS-DX = L-BX - L-AX
     COMPUTE WS-DY = L-BY - L-AY
     COMPUTE WS-DZ = L-BZ - L-AZ
     COMPUTE WS-N = FUNCTION MAX(FUNCTION ABS(WS-DX), FUNCTION ABS(WS-DY), FUNCTION ABS(WS-DZ))
     MOVE 0 TO WS-SX WS-SY WS-SZ
     IF WS-N > 0
         COMPUTE WS-SX = WS-DX / WS-N
         CALL "FR-F32" USING WS-SX
         COMPUTE WS-SY = WS-DY / WS-N
         CALL "FR-F32" USING WS-SY
         COMPUTE WS-SZ = WS-DZ / WS-N
         CALL "FR-F32" USING WS-SZ
     END-IF
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > WS-N OR L-OK = 0
         COMPUTE WS-P = WS-J * WS-SX
         CALL "FR-F32" USING WS-P
         COMPUTE WS-P = WS-P + 0.5
         CALL "FR-F32" USING WS-P
         COMPUTE WS-OX = FUNCTION INTEGER(WS-P)
         COMPUTE WS-P = WS-J * WS-SY
         CALL "FR-F32" USING WS-P
         COMPUTE WS-P = WS-P + 0.5
         CALL "FR-F32" USING WS-P
         COMPUTE WS-PY = L-AY + FUNCTION INTEGER(WS-P)
         COMPUTE WS-P = WS-J * WS-SZ
         CALL "FR-F32" USING WS-P
         COMPUTE WS-P = WS-P + 0.5
         CALL "FR-F32" USING WS-P
         COMPUTE WS-OZ = FUNCTION INTEGER(WS-P)
         COMPUTE WS-PX = L-AX + WS-OX
         COMPUTE WS-PZ = L-AZ + WS-OZ
         IF L-PLACE = 1
             COMPUTE WS-M = FUNCTION MAX(FUNCTION ABS(WS-OX), FUNCTION ABS(WS-OZ))
             MOVE 0 TO WS-AXIS
             IF WS-M > 0
                 MOVE 1 TO WS-AXIS
                 IF FUNCTION ABS(WS-OX) = WS-M
                     MOVE -1 TO WS-AXIS
                 END-IF
             END-IF
             CALL "FR-TREE-LOG" USING WS-PX WS-PY WS-PZ WS-AXIS WS-PLACED
         ELSE
             CALL "FR-TREE-FREE" USING WS-PX WS-PY WS-PZ WS-FREE
             IF WS-FREE = 0
                 MOVE 0 TO L-OK
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-FANCY-LIMB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK-FANCY.
*> USING state, row, x, y, z, height: 4.6 (one cluster, as the cluster count is always 1): T = H + 2, trunkTop = floor(0.618 T); the soil under the origin; from layer T - 5 down to 0 every layer
*> with a tree shape >= 0 draws a radius and an angle (two nextFloat, in that order) and, when its end column (5 cells) and its branch to the trunk are free, adds a branch end; then the trunk
*> (o to o + trunkTop), then each branch whose base is at least 0.2 T above the origin and differs from its end; the attachments are those branch ends.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TREEWORK.
 01 WS-T                   BINARY-LONG.
 01 WS-TT                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-YY                  BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EY                  BINARY-LONG.
 01 WS-EZ                  BINARY-LONG.
 01 WS-TOPY                BINARY-LONG.
 01 WS-BI                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-REL                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-EX2                 BINARY-LONG.
 01 WS-EZ2                 BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-OK2                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-SH                  FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-RAD                 FLOAT-LONG.
 01 WS-ANG                 FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-H.
     COMPUTE WS-T = L-H + 2
     COMPUTE WS-TT = WS-T * 618 / 1000
     COMPUTE WS-TY = L-Y + WS-TT
     COMPUTE WS-Y = L-Y - 1
     CALL "FR-TREE-SOIL" USING L-ROW L-X WS-Y L-Z
     MOVE 1 TO TW-NFC
     MOVE L-X TO TW-FC-X(1)
     COMPUTE TW-FC-Y(1) = L-Y + WS-T - 5
     MOVE L-Z TO TW-FC-Z(1)
     MOVE WS-TY TO TW-FC-B(1)
     COMPUTE WS-FROM = WS-T - 5
     PERFORM VARYING WS-YY FROM WS-FROM BY -1 UNTIL WS-YY < 0
         CALL "FR-FANCY-SHAPE" USING WS-T WS-YY WS-SH
         IF WS-SH >= 0
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             COMPUTE WS-RAD = WS-SH * (WS-F + 0.328)
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             COMPUTE WS-ANG = WS-F * 2 * FUNCTION PI
             COMPUTE WS-FX = WS-RAD * FUNCTION SIN(WS-ANG) + 0.5
             COMPUTE WS-FZ = WS-RAD * FUNCTION COS(WS-ANG) + 0.5
             COMPUTE WS-EX = L-X + FUNCTION INTEGER(WS-FX)
             COMPUTE WS-EY = L-Y + WS-YY - 1
             COMPUTE WS-EZ = L-Z + FUNCTION INTEGER(WS-FZ)
             COMPUTE WS-TOPY = WS-EY + 5
             MOVE WS-EX TO WS-EX2
             MOVE WS-EZ TO WS-EZ2
             CALL "FR-FANCY-LIMB" USING WS-EX WS-EY WS-EZ WS-EX2 WS-TOPY WS-EZ2 WS-ZERO WS-OK
             IF WS-OK = 1
                 COMPUTE WS-DX = L-X - WS-EX
                 COMPUTE WS-DZ = L-Z - WS-EZ
                 COMPUTE WS-BY = WS-EY - FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ) * 0.381
                 IF WS-BY > WS-TY
                     MOVE WS-TY TO WS-BI
                 ELSE
                     COMPUTE WS-BI = FUNCTION INTEGER-PART(WS-BY)
                 END-IF
                 CALL "FR-FANCY-LIMB" USING L-X WS-BI L-Z WS-EX WS-EY WS-EZ WS-ZERO WS-OK2
                 IF WS-OK2 = 1
                     ADD 1 TO TW-NFC
                     MOVE WS-EX TO TW-FC-X(TW-NFC)
                     MOVE WS-EY TO TW-FC-Y(TW-NFC)
                     MOVE WS-EZ TO TW-FC-Z(TW-NFC)
                     MOVE WS-BI TO TW-FC-B(TW-NFC)
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE L-X TO WS-X2
     MOVE L-Z TO WS-Z2
     CALL "FR-FANCY-LIMB" USING L-X L-Y L-Z WS-X2 WS-TY WS-Z2 WS-ONE WS-OK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > TW-NFC
         COMPUTE WS-REL = TW-FC-B(WS-I) - L-Y
         IF WS-REL * 5 >= WS-T
             IF TW-FC-X(WS-I) NOT = L-X OR TW-FC-Y(WS-I) NOT = TW-FC-B(WS-I) OR TW-FC-Z(WS-I) NOT = L-Z
                 CALL "FR-FANCY-LIMB" USING L-X TW-FC-B(WS-I) L-Z TW-FC-X(WS-I) TW-FC-Y(WS-I) TW-FC-Z(WS-I) WS-ONE WS-OK
             END-IF
             CALL "FR-TREE-ATT" USING TW-FC-X(WS-I) TW-FC-Y(WS-I) TW-FC-Z(WS-I) WS-ZERO WS-ZERO2
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM FR-TRUNK-FANCY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-TRUNK.
*> USING state, feature row, x, y, z, height: runs the trunk placer of the row (TR-TKIND 1 straight, 2 fancy, 3 dark oak, 4 giant, 5 mega jungle, 6 forking, 7 upwards branching in feat-tree-root.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-X L-Y L-Z L-H.
     EVALUATE TR-TKIND(L-ROW)
         WHEN 1
             CALL "FR-TRUNK-STRAIGHT" USING L-ROW L-X L-Y L-Z L-H
         WHEN 2
             CALL "FR-TRUNK-FANCY" USING L-STATE L-ROW L-X L-Y L-Z L-H
         WHEN 3
             CALL "FR-TRUNK-DARK" USING L-STATE L-ROW L-X L-Y L-Z L-H
         WHEN 4
             CALL "FR-TRUNK-GIANT" USING L-ROW L-X L-Y L-Z L-H
         WHEN 5
             CALL "FR-TRUNK-MEGAJ" USING L-STATE L-ROW L-X L-Y L-Z L-H
         WHEN 7
             CALL "FR-TRUNK-UP" USING L-STATE L-ROW L-X L-Y L-Z L-H
         WHEN OTHER
             CALL "FR-TRUNK-FORK" USING L-STATE L-ROW L-X L-Y L-Z L-H
     END-EVALUATE
     GOBACK.
 END PROGRAM FR-TRUNK.
