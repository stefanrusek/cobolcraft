*> The woodland mansion piece layout (docs/protocol/36-structures-7-woodland-mansion.md section 6, MansionPiecePlacer; 6.8 the name collections): the pieces are emitted as (template name, position,
*> rotation, mirror) into the list MN-ENTRY of core/copy/STRUCTMAN.cpy in the order of 6.2, from the grids MNG-BUILD made and the start random SP-RNG. Directions 0 north, 1 east, 2 south, 3 west;
*> a rotation is quarter turns, R.rotate(d) = (d + R) mod 4. struct-man-start.cob turns the list into template pieces.
*> Entry points: MNP-LAYOUT USING rotation, x, y, z of the origin (6.2); MNP-EMIT, MNP-REL, MNP-K, MNP-ADD-AT (positions); MNP-C-* (the wall cursors, 6.3), MNP-OUTER, MNP-ROOF, MNP-FLOOR-CORR and
*> MNP-FLOOR-ROOMS (6.6), MNP-NAME (6.8), MNP-ROOM-1X1, MNP-ROOM-1X2, MNP-ROOM-2X2, MNP-ROOM-2X2S (6.7).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-EMIT.
*> USING name (PIC X(24)), x, y, z, rotation, mirror: one entry at the end of the list (MN-LOST counts those over the table).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-MIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-X L-Y L-Z L-ROT L-MIR.
     IF MN-COUNT >= 1500
         ADD 1 TO MN-LOST
         GOBACK
     END-IF
     ADD 1 TO MN-COUNT
     MOVE L-NAME TO ME-NAME(MN-COUNT)
     MOVE L-X TO ME-X(MN-COUNT)
     MOVE L-Y TO ME-Y(MN-COUNT)
     MOVE L-Z TO ME-Z(MN-COUNT)
     MOVE L-ROT TO ME-ROT(MN-COUNT)
     MOVE L-MIR TO ME-MIR(MN-COUNT)
     GOBACK.
 END PROGRAM MNP-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-REL.
*> USING x, z, direction, n: pos.relative(direction, n) on the horizontal plane (2.1); n may be negative.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-DIR L-N.
     CALL "MNG-DIR-STEP" USING L-DIR WS-DX WS-DZ
     COMPUTE L-X = L-X + L-N * WS-DX
     COMPUTE L-Z = L-Z + L-N * WS-DZ
     GOBACK.
 END PROGRAM MNP-REL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-K.
*> USING grid x, grid y, x out, z out: the cell origin K(x, y) of 6.1 on the floor origin (the x and z of O; the floor's height is the caller's).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-SOUTH               BINARY-LONG.
 01 WS-EAST                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-GX                   BINARY-LONG.
 01 L-GY                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-GX L-GY L-X L-Z.
     MOVE MN-OX TO L-X
     MOVE MN-OZ TO L-Z
     COMPUTE WS-SOUTH = FUNCTION MOD(2 + MN-ROT, 4)
     COMPUTE WS-EAST = FUNCTION MOD(1 + MN-ROT, 4)
     COMPUTE WS-N = 8 * (L-GY - 4)
     CALL "MNP-REL" USING L-X L-Z WS-SOUTH WS-N
     COMPUTE WS-N = 8 * (L-GX - 8)
     CALL "MNP-REL" USING L-X L-Z WS-EAST WS-N
     GOBACK.
 END PROGRAM MNP-K.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-ADD-AT.
*> USING name, base x, y, base z, e, s, extra rotation, mirror: a piece at base.relative(R.EAST, e).relative(R.SOUTH, s) with the rotation R + extra.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SOUTH               BINARY-LONG.
 01 WS-EAST                BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-BX                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-EXTRA                BINARY-LONG.
 01 L-MIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-BX L-Y L-BZ L-E L-S L-EXTRA L-MIR.
     MOVE L-BX TO WS-X
     MOVE L-BZ TO WS-Z
     COMPUTE WS-EAST = FUNCTION MOD(1 + MN-ROT, 4)
     COMPUTE WS-SOUTH = FUNCTION MOD(2 + MN-ROT, 4)
     CALL "MNP-REL" USING WS-X WS-Z WS-EAST L-E
     CALL "MNP-REL" USING WS-X WS-Z WS-SOUTH L-S
     COMPUTE WS-ROT = FUNCTION MOD(MN-ROT + L-EXTRA, 4)
     CALL "MNP-EMIT" USING L-NAME WS-X L-Y WS-Z WS-ROT L-MIR
     GOBACK.
 END PROGRAM MNP-ADD-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-PUT.
*> USING name, base x, y, base z, e, s, extra rotation: MNP-ADD-AT without a mirror.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MIR                 BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 01 L-BX                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-EXTRA                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-BX L-Y L-BZ L-E L-S L-EXTRA.
     CALL "MNP-ADD-AT" USING L-NAME L-BX L-Y L-BZ L-E L-S L-EXTRA WS-MIR
     GOBACK.
 END PROGRAM MNP-PUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-C-WALL.
*> USING cursor: traverseWallPiece (6.3): the cursor's wall type at 7 east, the cursor 8 south.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-NAME                PIC X(24).
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C.
     MOVE "wall_flat" TO WS-NAME
     IF MN-CWALL(L-C) = 1
         MOVE "wall_window" TO WS-NAME
     END-IF
     MOVE MN-CX(L-C) TO WS-X
     MOVE MN-CZ(L-C) TO WS-Z
     COMPUTE WS-DIR = FUNCTION MOD(1 + MN-CROT(L-C), 4)
     MOVE 7 TO WS-N
     CALL "MNP-REL" USING WS-X WS-Z WS-DIR WS-N
     CALL "MNP-EMIT" USING WS-NAME WS-X MN-CY(L-C) WS-Z MN-CROT(L-C) WS-ZERO
     COMPUTE WS-DIR = FUNCTION MOD(2 + MN-CROT(L-C), 4)
     MOVE 8 TO WS-N
     CALL "MNP-REL" USING MN-CX(L-C) MN-CZ(L-C) WS-DIR WS-N
     GOBACK.
 END PROGRAM MNP-C-WALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-C-TURN.
*> USING cursor: traverseTurn (6.3), the convex corner: 1 north, the wall_corner, 7 north, 6 east, a quarter turn clockwise.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-NAME                PIC X(24) VALUE "wall_corner".
 01 WS-DIR                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C.
     COMPUTE WS-DIR = FUNCTION MOD(2 + MN-CROT(L-C), 4)
     MOVE -1 TO WS-N
     CALL "MNP-REL" USING MN-CX(L-C) MN-CZ(L-C) WS-DIR WS-N
     CALL "MNP-EMIT" USING WS-NAME MN-CX(L-C) MN-CY(L-C) MN-CZ(L-C) MN-CROT(L-C) WS-ZERO
     MOVE -7 TO WS-N
     CALL "MNP-REL" USING MN-CX(L-C) MN-CZ(L-C) WS-DIR WS-N
     COMPUTE WS-DIR = FUNCTION MOD(1 + MN-CROT(L-C), 4)
     MOVE 6 TO WS-N
     CALL "MNP-REL" USING MN-CX(L-C) MN-CZ(L-C) WS-DIR WS-N
     COMPUTE MN-CROT(L-C) = FUNCTION MOD(MN-CROT(L-C) + 1, 4)
     GOBACK.
 END PROGRAM MNP-C-TURN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-C-INNER.
*> USING cursor: traverseInnerTurn (6.3), the concave corner: 6 south, 8 east, a quarter turn counter-clockwise; no piece.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-DIR                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C.
     COMPUTE WS-DIR = FUNCTION MOD(2 + MN-CROT(L-C), 4)
     MOVE 6 TO WS-N
     CALL "MNP-REL" USING MN-CX(L-C) MN-CZ(L-C) WS-DIR WS-N
     COMPUTE WS-DIR = FUNCTION MOD(1 + MN-CROT(L-C), 4)
     MOVE 8 TO WS-N
     CALL "MNP-REL" USING MN-CX(L-C) MN-CZ(L-C) WS-DIR WS-N
     COMPUTE MN-CROT(L-C) = FUNCTION MOD(MN-CROT(L-C) + 3, 4)
     GOBACK.
 END PROGRAM MNP-C-INNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-C-ENTRANCE.
*> USING cursor: entrance (6.3): the entrance at 9 west of the cursor, the cursor 16 south.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-NAME                PIC X(24) VALUE "entrance".
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 PROCEDURE DIVISION USING L-C.
     MOVE MN-CX(L-C) TO WS-X
     MOVE MN-CZ(L-C) TO WS-Z
     COMPUTE WS-DIR = FUNCTION MOD(3 + MN-CROT(L-C), 4)
     MOVE 9 TO WS-N
     CALL "MNP-REL" USING WS-X WS-Z WS-DIR WS-N
     CALL "MNP-EMIT" USING WS-NAME WS-X MN-CY(L-C) WS-Z MN-CROT(L-C) WS-ZERO
     COMPUTE WS-DIR = FUNCTION MOD(2 + MN-CROT(L-C), 4)
     MOVE 16 TO WS-N
     CALL "MNP-REL" USING MN-CX(L-C) MN-CZ(L-C) WS-DIR WS-N
     GOBACK.
 END PROGRAM MNP-C-ENTRANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-OUTER.
*> USING cursor, grid, direction, x, y, end x, end y: traverseOuterWalls (6.3): the clockwise walk of the outline until the walker is back at the end cell with the starting heading.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KX                  BINARY-LONG.
 01 WS-KZ                  BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-C                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-EX                   BINARY-LONG.
 01 L-EY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-C L-G L-DIR L-X L-Y L-EX L-EY.
     MOVE L-X TO WS-X
     MOVE L-Y TO WS-Y
     MOVE L-DIR TO WS-DIR WS-START
     MOVE 0 TO WS-END
     PERFORM WITH TEST AFTER UNTIL WS-END = 1
         CALL "MNG-DIR-STEP" USING WS-DIR WS-DX WS-DZ
         COMPUTE WS-AX = WS-X + WS-DX
         COMPUTE WS-AY = WS-Y + WS-DZ
         CALL "MNG-HOUSE" USING L-G WS-AX WS-AY WS-H
         MOVE 0 TO WS-H2
         IF WS-H = 1
             COMPUTE WS-K = FUNCTION MOD(WS-DIR + 3, 4)
             CALL "MNG-DIR-STEP" USING WS-K WS-KX WS-KZ
             COMPUTE WS-BX = WS-AX + WS-KX
             COMPUTE WS-BY = WS-AY + WS-KZ
             CALL "MNG-HOUSE" USING L-G WS-BX WS-BY WS-H2
         END-IF
         EVALUATE TRUE
             WHEN WS-H = 0
                 CALL "MNP-C-TURN" USING L-C
                 COMPUTE WS-DIR = FUNCTION MOD(WS-DIR + 1, 4)
                 IF NOT (WS-X = L-EX AND WS-Y = L-EY AND WS-DIR = WS-START)
                     CALL "MNP-C-WALL" USING L-C
                 END-IF
             WHEN WS-H2 = 1
                 CALL "MNP-C-INNER" USING L-C
                 MOVE WS-AX TO WS-X
                 MOVE WS-AY TO WS-Y
                 MOVE WS-K TO WS-DIR
             WHEN OTHER
                 MOVE WS-AX TO WS-X
                 MOVE WS-AY TO WS-Y
                 IF NOT (WS-X = L-EX AND WS-Y = L-EY AND WS-DIR = WS-START)
                     CALL "MNP-C-WALL" USING L-C
                 END-IF
         END-EVALUATE
         IF WS-X = L-EX AND WS-Y = L-EY AND WS-DIR = WS-START
             MOVE 1 TO WS-END
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MNP-OUTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-NEIGH.
*> USING grid, x, y, flags (8 BINARY-LONG: east, west, north, south, south-east, north-east, south-west, north-west): isHouse of the eight neighbours.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-TABLE.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE -1.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE -1.
    05 FILLER              PIC S9 VALUE -1.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE 0.
    05 FILLER              PIC S9 VALUE -1.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE -1.
    05 FILLER              PIC S9 VALUE 1.
    05 FILLER              PIC S9 VALUE -1.
 01 WS-OFFS REDEFINES WS-TABLE.
    05 WS-OFF              PIC S9 OCCURS 16 TIMES.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-FLAGS.
    05 L-FLAG              BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION USING L-G L-X L-Y L-FLAGS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE WS-NX = L-X + WS-OFF(WS-I)
         COMPUTE WS-NY = L-Y + WS-OFF(WS-I + 8)
         CALL "MNG-HOUSE" USING L-G WS-NX WS-NY L-FLAG(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM MNP-NEIGH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-ROOF.
*> USING y of the roof origin, grid, upper grid (0 none): createRoof (6.5), the passes A (roofs and fronts), B (small walls over an upper floor) and C (roof corners).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-PASS                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-KX                  BINARY-LONG.
 01 WS-KZ                  BINARY-LONG.
 01 WS-HOUSE               BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-NB.
    05 WS-H                BINARY-LONG OCCURS 8 TIMES.
 01 WS-NAME                PIC X(24).
 01 WS-Y3                  BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-G                    BINARY-LONG.
 01 L-UG                   BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-G L-UG.
     PERFORM VARYING WS-PASS FROM 1 BY 1 UNTIL WS-PASS > 3
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
                 CALL "MNG-HOUSE" USING L-G WS-X WS-Y WS-HOUSE
                 MOVE 0 TO WS-UP
                 IF L-UG > 0
                     CALL "MNG-HOUSE" USING L-UG WS-X WS-Y WS-UP
                 END-IF
                 IF WS-HOUSE = 1
                     CALL "MNP-K" USING WS-X WS-Y WS-KX WS-KZ
                     CALL "MNP-NEIGH" USING L-G WS-X WS-Y WS-NB
                     EVALUATE TRUE
                         WHEN WS-PASS = 1 AND WS-UP = 0
                             MOVE "roof" TO WS-NAME
                             COMPUTE WS-Y3 = L-Y + 3
                             MOVE 0 TO WS-E WS-S WS-X1
                             CALL "MNP-PUT" USING WS-NAME WS-KX WS-Y3 WS-KZ WS-E WS-S WS-X1
                             MOVE "roof_front" TO WS-NAME
                             IF WS-H(1) = 0
                                 MOVE 6 TO WS-E
                                 MOVE 0 TO WS-S WS-X1
                                 CALL "MNP-PUT" USING WS-NAME WS-KX L-Y WS-KZ WS-E WS-S WS-X1
                             END-IF
                             IF WS-H(2) = 0
                                 MOVE 0 TO WS-E
                                 MOVE 7 TO WS-S
                                 MOVE 2 TO WS-X1
                                 CALL "MNP-PUT" USING WS-NAME WS-KX L-Y WS-KZ WS-E WS-S WS-X1
                             END-IF
                             IF WS-H(3) = 0
                                 MOVE -1 TO WS-E
                                 MOVE 0 TO WS-S
                                 MOVE 3 TO WS-X1
                                 CALL "MNP-PUT" USING WS-NAME WS-KX L-Y WS-KZ WS-E WS-S WS-X1
                             END-IF
                             IF WS-H(4) = 0
                                 MOVE 6 TO WS-E
                                 MOVE 6 TO WS-S
                                 MOVE 1 TO WS-X1
                                 CALL "MNP-PUT" USING WS-NAME WS-KX L-Y WS-KZ WS-E WS-S WS-X1
                             END-IF
                         WHEN WS-PASS = 2 AND WS-UP = 1
                             CALL "MNP-ROOF-SMALL" USING L-Y WS-KX WS-KZ WS-NB
                         WHEN WS-PASS = 3 AND WS-UP = 0
                             CALL "MNP-ROOF-CORNER" USING L-Y WS-KX WS-KZ WS-NB
                         WHEN OTHER
                             CONTINUE
                     END-EVALUATE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MNP-ROOF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-ROOF-SMALL.
*> USING y, kx, kz, neighbour flags: pass B of 6.5 for one cell: the small walls on the exposed sides and the small wall corners.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-KX                   BINARY-LONG.
 01 L-KZ                   BINARY-LONG.
 01 L-H.
    05 L-FLAG              BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION USING L-Y L-KX L-KZ L-H.
     MOVE "small_wall" TO WS-NAME
     IF L-FLAG(1) = 0
         MOVE 7 TO WS-E
         MOVE 0 TO WS-S WS-X1
         CALL "MNP-PUT" USING WS-NAME L-KX L-Y L-KZ WS-E WS-S WS-X1
     END-IF
     IF L-FLAG(2) = 0
         MOVE -1 TO WS-E
         MOVE 6 TO WS-S
         MOVE 2 TO WS-X1
         CALL "MNP-PUT" USING WS-NAME L-KX L-Y L-KZ WS-E WS-S WS-X1
     END-IF
     IF L-FLAG(3) = 0
         MOVE 0 TO WS-E
         MOVE -1 TO WS-S
         MOVE 3 TO WS-X1
         CALL "MNP-PUT" USING WS-NAME L-KX L-Y L-KZ WS-E WS-S WS-X1
     END-IF
     IF L-FLAG(4) = 0
         MOVE 6 TO WS-E
         MOVE 7 TO WS-S
         MOVE 1 TO WS-X1
         CALL "MNP-PUT" USING WS-NAME L-KX L-Y L-KZ WS-E WS-S WS-X1
     END-IF
     MOVE "small_wall_corner" TO WS-NAME
     IF L-FLAG(1) = 0 AND L-FLAG(3) = 0
         MOVE 7 TO WS-E
         MOVE -2 TO WS-S
         MOVE 0 TO WS-X1
         CALL "MNP-PUT" USING WS-NAME L-KX L-Y L-KZ WS-E WS-S WS-X1
     END-IF
     IF L-FLAG(1) = 0 AND L-FLAG(4) = 0
         MOVE 8 TO WS-E
         MOVE 7 TO WS-S
         MOVE 1 TO WS-X1
         CALL "MNP-PUT" USING WS-NAME L-KX L-Y L-KZ WS-E WS-S WS-X1
     END-IF
     IF L-FLAG(2) = 0 AND L-FLAG(3) = 0
         MOVE -2 TO WS-E
         MOVE -1 TO WS-S
         MOVE 3 TO WS-X1
         CALL "MNP-PUT" USING WS-NAME L-KX L-Y L-KZ WS-E WS-S WS-X1
     END-IF
     IF L-FLAG(2) = 0 AND L-FLAG(4) = 0
         MOVE -1 TO WS-E
         MOVE 8 TO WS-S
         MOVE 2 TO WS-X1
         CALL "MNP-PUT" USING WS-NAME L-KX L-Y L-KZ WS-E WS-S WS-X1
     END-IF
     GOBACK.
 END PROGRAM MNP-ROOF-SMALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-ROOF-CORNER.
*> USING y, kx, kz, neighbour flags: pass C of 6.5 for one cell: the roof corners and inner corners of the east block then the west block (flags 1 east, 2 west, 3 north, 4 south, 5 south-east, 6 north-east, 7 south-west, 8 north-west).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CORNER              PIC X(24) VALUE "roof_corner".
 01 WS-INNER               PIC X(24) VALUE "roof_inner_corner".
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-KX                   BINARY-LONG.
 01 L-KZ                   BINARY-LONG.
 01 L-H.
    05 L-FLAG              BINARY-LONG OCCURS 8 TIMES.
 PROCEDURE DIVISION USING L-Y L-KX L-KZ L-H.
     IF L-FLAG(1) = 0
         IF L-FLAG(4) = 0
             MOVE 6 TO WS-E
             MOVE 6 TO WS-S
             MOVE 0 TO WS-X1
             CALL "MNP-PUT" USING WS-CORNER L-KX L-Y L-KZ WS-E WS-S WS-X1
         ELSE
             IF L-FLAG(5) = 1
                 MOVE 6 TO WS-E
                 MOVE 5 TO WS-S
                 MOVE 0 TO WS-X1
                 CALL "MNP-PUT" USING WS-INNER L-KX L-Y L-KZ WS-E WS-S WS-X1
             END-IF
         END-IF
         IF L-FLAG(3) = 0
             MOVE 6 TO WS-E
             MOVE 0 TO WS-S
             MOVE 3 TO WS-X1
             CALL "MNP-PUT" USING WS-CORNER L-KX L-Y L-KZ WS-E WS-S WS-X1
         ELSE
             IF L-FLAG(6) = 1
                 MOVE 9 TO WS-E
                 MOVE -2 TO WS-S
                 MOVE 1 TO WS-X1
                 CALL "MNP-PUT" USING WS-INNER L-KX L-Y L-KZ WS-E WS-S WS-X1
             END-IF
         END-IF
     END-IF
     IF L-FLAG(2) = 0
         IF L-FLAG(4) = 0
             MOVE 0 TO WS-E
             MOVE 6 TO WS-S
             MOVE 1 TO WS-X1
             CALL "MNP-PUT" USING WS-CORNER L-KX L-Y L-KZ WS-E WS-S WS-X1
         ELSE
             IF L-FLAG(7) = 1
                 MOVE -3 TO WS-E
                 MOVE 8 TO WS-S
                 MOVE 3 TO WS-X1
                 CALL "MNP-PUT" USING WS-INNER L-KX L-Y L-KZ WS-E WS-S WS-X1
             END-IF
         END-IF
         IF L-FLAG(3) = 0
             MOVE 0 TO WS-E
             MOVE 0 TO WS-S
             MOVE 2 TO WS-X1
             CALL "MNP-PUT" USING WS-CORNER L-KX L-Y L-KZ WS-E WS-S WS-X1
         ELSE
             IF L-FLAG(8) = 1
                 MOVE 0 TO WS-E
                 MOVE 1 TO WS-S
                 MOVE 2 TO WS-X1
                 CALL "MNP-PUT" USING WS-INNER L-KX L-Y L-KZ WS-E WS-S WS-X1
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MNP-ROOF-CORNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-NAME.
*> USING kind (1 1x1, 2 1x1 secret, 3 1x2 side entrance, 4 1x2 front entrance, 5 1x2 secret, 6 2x2), floor (0 to 2), stairs flag, name out: the FloorRoomCollection of 6.8 (draws from SP-RNG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-PREFIX              PIC X(16).
 01 WS-DRAWN               BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-FLOOR                BINARY-LONG.
 01 L-STAIRS               BINARY-LONG.
 01 L-NAME                 PIC X(24).
 PROCEDURE DIVISION USING L-KIND L-FLOOR L-STAIRS L-NAME.
     MOVE SPACES TO L-NAME
     MOVE 1 TO WS-DRAWN
     EVALUATE TRUE
         WHEN L-KIND = 1 AND L-FLOOR = 0
             MOVE "1x1_a" TO WS-PREFIX
             MOVE 5 TO WS-BOUND
         WHEN L-KIND = 1
             MOVE "1x1_b" TO WS-PREFIX
             MOVE 5 TO WS-BOUND
         WHEN L-KIND = 2
             MOVE "1x1_as" TO WS-PREFIX
             MOVE 4 TO WS-BOUND
         WHEN L-KIND = 3 AND L-FLOOR = 0
             MOVE "1x2_a" TO WS-PREFIX
             MOVE 9 TO WS-BOUND
         WHEN L-KIND = 3 AND L-STAIRS = 1
             MOVE "1x2_c_stairs" TO L-NAME
             MOVE 0 TO WS-DRAWN
         WHEN L-KIND = 3
             MOVE "1x2_c" TO WS-PREFIX
             MOVE 4 TO WS-BOUND
         WHEN L-KIND = 4 AND L-FLOOR = 0
             MOVE "1x2_b" TO WS-PREFIX
             MOVE 5 TO WS-BOUND
         WHEN L-KIND = 4 AND L-STAIRS = 1
             MOVE "1x2_d_stairs" TO L-NAME
             MOVE 0 TO WS-DRAWN
         WHEN L-KIND = 4
             MOVE "1x2_d" TO WS-PREFIX
             MOVE 5 TO WS-BOUND
         WHEN L-KIND = 5 AND L-FLOOR = 0
             MOVE "1x2_s" TO WS-PREFIX
             MOVE 2 TO WS-BOUND
         WHEN L-KIND = 5
             MOVE "1x2_se" TO WS-PREFIX
             MOVE 1 TO WS-BOUND
         WHEN L-FLOOR = 0
             MOVE "2x2_a" TO WS-PREFIX
             MOVE 4 TO WS-BOUND
         WHEN OTHER
             MOVE "2x2_b" TO WS-PREFIX
             MOVE 5 TO WS-BOUND
     END-EVALUATE
     IF WS-DRAWN = 1
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-DRAW
         COMPUTE WS-DIGIT = WS-DRAW + 1
         STRING FUNCTION TRIM(WS-PREFIX) WS-DIGIT DELIMITED BY SIZE INTO L-NAME
     END-IF
     GOBACK.
 END PROGRAM MNP-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-ROOM-1X1.
*> USING q x, y, q z, rotation R, door direction (0 to 3, 4 none/secret), floor: addRoom1x1 (6.7): the name is drawn, a secret room draws a second name.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-NAME                PIC X(24).
 01 WS-KIND                BINARY-LONG VALUE 1.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-QX                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-DOOR                 BINARY-LONG.
 01 L-FLOOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-QX L-Y L-QZ L-ROT L-DOOR L-FLOOR.
     MOVE L-ROT TO MN-ROT
     MOVE 1 TO WS-KIND
     CALL "MNP-NAME" USING WS-KIND L-FLOOR WS-NO WS-NAME
     MOVE 1 TO WS-E
     MOVE 0 TO WS-S WS-EXTRA
     EVALUATE L-DOOR
         WHEN 0
             MOVE 6 TO WS-S
             MOVE 3 TO WS-EXTRA
         WHEN 3
             MOVE 7 TO WS-E
             MOVE 6 TO WS-S
             MOVE 2 TO WS-EXTRA
         WHEN 2
             MOVE 7 TO WS-E
             MOVE 1 TO WS-EXTRA
         WHEN 4
             MOVE 2 TO WS-KIND
             CALL "MNP-NAME" USING WS-KIND L-FLOOR WS-NO WS-NAME
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     CALL "MNP-PUT" USING WS-NAME L-QX L-Y L-QZ WS-E WS-S WS-EXTRA
     GOBACK.
 END PROGRAM MNP-ROOM-1X1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-ROOM-1X2.
*> USING q x, y, q z, door direction, room direction, floor, stairs: addRoom1x2 (6.7): the first matching row of the 14, the name by the row's kind, nothing when no row matches.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-ROWS.
    05 FILLER              PIC X(24) VALUE "1 2 1 1 0 0 0".
    05 FILLER              PIC X(24) VALUE "1 0 1 1 6 0 1".
    05 FILLER              PIC X(24) VALUE "3 0 1 7 6 2 0".
    05 FILLER              PIC X(24) VALUE "3 2 1 7 0 0 2".
    05 FILLER              PIC X(24) VALUE "2 1 1 1 0 1 1".
    05 FILLER              PIC X(24) VALUE "2 3 1 7 0 1 0".
    05 FILLER              PIC X(24) VALUE "0 3 1 7 6 1 2".
    05 FILLER              PIC X(24) VALUE "0 1 1 1 6 3 0".
    05 FILLER              PIC X(24) VALUE "2 0 2 1 -8 0 0".
    05 FILLER              PIC X(24) VALUE "0 2 2 7 14 2 0".
    05 FILLER              PIC X(24) VALUE "3 1 2 15 0 1 0".
    05 FILLER              PIC X(24) VALUE "1 3 2 -7 6 3 0".
    05 FILLER              PIC X(24) VALUE "4 1 3 15 0 1 0".
    05 FILLER              PIC X(24) VALUE "4 2 3 1 0 0 0".
 01 WS-TAB REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(24) OCCURS 14 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-T                   PIC X(4) OCCURS 7 TIMES.
 01 WS-DOOR                BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-MIR                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 LINKAGE SECTION.
 01 L-QX                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 01 L-DOOR                 BINARY-LONG.
 01 L-ROOM                 BINARY-LONG.
 01 L-FLOOR                BINARY-LONG.
 01 L-STAIRS               BINARY-LONG.
 PROCEDURE DIVISION USING L-QX L-Y L-QZ L-DOOR L-ROOM L-FLOOR L-STAIRS.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14 OR WS-FOUND = 1
         UNSTRING WS-ROW(WS-I) DELIMITED BY ALL SPACE INTO WS-T(1) WS-T(2) WS-T(3) WS-T(4) WS-T(5) WS-T(6) WS-T(7)
         COMPUTE WS-DOOR = FUNCTION NUMVAL(WS-T(1))
         COMPUTE WS-ROOM = FUNCTION NUMVAL(WS-T(2))
         IF WS-DOOR = L-DOOR AND WS-ROOM = L-ROOM
             MOVE 1 TO WS-FOUND
             COMPUTE WS-KIND = FUNCTION NUMVAL(WS-T(3)) + 2
             COMPUTE WS-E = FUNCTION NUMVAL(WS-T(4))
             COMPUTE WS-S = FUNCTION NUMVAL(WS-T(5))
             COMPUTE WS-EXTRA = FUNCTION NUMVAL(WS-T(6))
             COMPUTE WS-MIR = FUNCTION NUMVAL(WS-T(7))
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         GOBACK
     END-IF
*>   the table's kind 1 side entrance, 2 front entrance, 3 secret are the name kinds 3, 4 and 5
     CALL "MNP-NAME" USING WS-KIND L-FLOOR L-STAIRS WS-NAME
     CALL "MNP-ADD-AT" USING WS-NAME L-QX L-Y L-QZ WS-E WS-S WS-EXTRA WS-MIR
     GOBACK.
 END PROGRAM MNP-ROOM-1X2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-ROOM-2X2.
*> USING q x, y, q z, door direction, side direction, floor: addRoom2x2 (6.7): the row of the pair (the default row when none) and the name drawn after it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-ROWS.
    05 FILLER              PIC X(24) VALUE "1 2 -7 0 0 0".
    05 FILLER              PIC X(24) VALUE "1 0 -7 6 0 1".
    05 FILLER              PIC X(24) VALUE "0 1 1 14 3 0".
    05 FILLER              PIC X(24) VALUE "0 3 7 14 3 1".
    05 FILLER              PIC X(24) VALUE "2 3 7 -8 1 0".
    05 FILLER              PIC X(24) VALUE "2 1 1 -8 1 1".
    05 FILLER              PIC X(24) VALUE "3 0 15 6 2 0".
    05 FILLER              PIC X(24) VALUE "3 2 15 0 0 2".
 01 WS-TAB REDEFINES WS-ROWS.
    05 WS-ROW              PIC X(24) OCCURS 8 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-T                   PIC X(4) OCCURS 6 TIMES.
 01 WS-DOOR                BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE 6.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-EXTRA               BINARY-LONG.
 01 WS-MIR                 BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-QX                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 01 L-DOOR                 BINARY-LONG.
 01 L-SIDE                 BINARY-LONG.
 01 L-FLOOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-QX L-Y L-QZ L-DOOR L-SIDE L-FLOOR.
     MOVE 0 TO WS-FOUND WS-E WS-S WS-EXTRA WS-MIR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8 OR WS-FOUND = 1
         UNSTRING WS-ROW(WS-I) DELIMITED BY ALL SPACE INTO WS-T(1) WS-T(2) WS-T(3) WS-T(4) WS-T(5) WS-T(6)
         COMPUTE WS-DOOR = FUNCTION NUMVAL(WS-T(1))
         COMPUTE WS-SIDE = FUNCTION NUMVAL(WS-T(2))
         IF WS-DOOR = L-DOOR AND WS-SIDE = L-SIDE
             MOVE 1 TO WS-FOUND
             COMPUTE WS-E = FUNCTION NUMVAL(WS-T(3))
             COMPUTE WS-S = FUNCTION NUMVAL(WS-T(4))
             COMPUTE WS-EXTRA = FUNCTION NUMVAL(WS-T(5))
             COMPUTE WS-MIR = FUNCTION NUMVAL(WS-T(6))
         END-IF
     END-PERFORM
     CALL "MNP-NAME" USING WS-KIND L-FLOOR WS-NO WS-NAME
     CALL "MNP-ADD-AT" USING WS-NAME L-QX L-Y L-QZ WS-E WS-S WS-EXTRA WS-MIR
     GOBACK.
 END PROGRAM MNP-ROOM-2X2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-ROOM-2X2S.
*> USING q x, y, q z: addRoom2x2Secret (6.7): 2x2_s1 at 1 east of q, no draw.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24) VALUE "2x2_s1".
 01 WS-E                   BINARY-LONG VALUE 1.
 01 WS-S                   BINARY-LONG VALUE 0.
 01 WS-X1                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-QX                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-QX L-Y L-QZ.
     CALL "MNP-PUT" USING WS-NAME L-QX L-Y L-QZ WS-E WS-S WS-X1
     GOBACK.
 END PROGRAM MNP-ROOM-2X2S.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-FLOOR-CORR.
*> USING floor: pass 1 of 6.6: the corridor floors of the corridor cells and the carpets on the sides next to a corridor or an entrance side (corridor flag).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-G                   BINARY-LONG.
 01 WS-FR                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-KX                  BINARY-LONG.
 01 WS-KZ                  BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ORIGIN              BINARY-LONG.
 01 WS-DOOR                BINARY-LONG.
 01 WS-STAIRS              BINARY-LONG.
 01 WS-CORR                BINARY-LONG.
 01 WS-CARPET              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-SUFFIX              PIC 9.
 LINKAGE SECTION.
 01 L-FLOOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLOOR.
     COMPUTE WS-FY = MN-OY + 8 * L-FLOOR
     MOVE 1 TO WS-G
     IF L-FLOOR = 2
         ADD 3 TO WS-FY
         MOVE 2 TO WS-G
     END-IF
     COMPUTE WS-FR = 3 + L-FLOOR
     MOVE 2 TO WS-SUFFIX
     IF L-FLOOR = 0
         MOVE 1 TO WS-SUFFIX
     END-IF
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             CALL "MNG-GET" USING WS-G WS-X WS-Y WS-V
             IF WS-V = 1
                 CALL "MNP-K" USING WS-X WS-Y WS-KX WS-KZ
                 MOVE "corridor_floor" TO WS-NAME
                 MOVE 0 TO WS-E WS-S WS-X1
                 CALL "MNP-PUT" USING WS-NAME WS-KX WS-FY WS-KZ WS-E WS-S WS-X1
                 PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3
                     CALL "MNG-DIR-STEP" USING WS-D WS-DX WS-DZ
                     COMPUTE WS-NX = WS-X + WS-DX
                     COMPUTE WS-NY = WS-Y + WS-DZ
                     CALL "MNG-GET" USING WS-G WS-NX WS-NY WS-N
                     CALL "MNG-GET" USING WS-FR WS-NX WS-NY WS-CARPET
                     CALL "MNG-BITS" USING WS-CARPET WS-ID WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
                     IF WS-N = 1 OR WS-CORR = 1
                         COMPUTE WS-Y1 = WS-FY
                         MOVE SPACES TO WS-NAME
                         MOVE 0 TO WS-X1
                         EVALUATE WS-D
                             WHEN 0
                                 MOVE "carpet_north" TO WS-NAME
                                 MOVE 1 TO WS-E
                                 MOVE 0 TO WS-S
                                 ADD 1 TO WS-Y1
                             WHEN 1
                                 MOVE "carpet_east" TO WS-NAME
                                 MOVE 5 TO WS-E
                                 MOVE 1 TO WS-S
                                 ADD 1 TO WS-Y1
                             WHEN 2
                                 STRING "carpet_south_" WS-SUFFIX DELIMITED BY SIZE INTO WS-NAME
                                 MOVE -1 TO WS-E
                                 MOVE 5 TO WS-S
                             WHEN OTHER
                                 STRING "carpet_west_" WS-SUFFIX DELIMITED BY SIZE INTO WS-NAME
                                 MOVE -1 TO WS-E
                                 MOVE -1 TO WS-S
                         END-EVALUATE
                         CALL "MNP-PUT" USING WS-NAME WS-KX WS-Y1 WS-KZ WS-E WS-S WS-X1
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MNP-FLOOR-CORR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-IWALL.
*> USING floor, door flag (1 door piece, 0 wall piece), q x, y, q z, e, s, extra rotation: one indoor wall or door piece (6.6 step 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(24).
 01 WS-SUFFIX              PIC 9.
 LINKAGE SECTION.
 01 L-FLOOR                BINARY-LONG.
 01 L-DOOR                 BINARY-LONG.
 01 L-QX                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-QZ                   BINARY-LONG.
 01 L-E                    BINARY-LONG.
 01 L-S                    BINARY-LONG.
 01 L-EXTRA                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLOOR L-DOOR L-QX L-Y L-QZ L-E L-S L-EXTRA.
     MOVE 2 TO WS-SUFFIX
     IF L-FLOOR = 0
         MOVE 1 TO WS-SUFFIX
     END-IF
     MOVE SPACES TO WS-NAME
     IF L-DOOR = 1
         STRING "indoors_door_" WS-SUFFIX DELIMITED BY SIZE INTO WS-NAME
     ELSE
         STRING "indoors_wall_" WS-SUFFIX DELIMITED BY SIZE INTO WS-NAME
     END-IF
     CALL "MNP-PUT" USING WS-NAME L-QX L-Y L-QZ L-E L-S L-EXTRA
     GOBACK.
 END PROGRAM MNP-IWALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-CELL.
*> USING floor, y of the floor, grid x, grid y: pass 2 of 6.6 for one cell that is a room cell or a stair cell: the door draw, the indoor walls and the room pieces.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 COPY STRUCTPIECE.
 01 WS-G                   BINARY-LONG.
 01 WS-FR                  BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ORIGIN              BINARY-LONG.
 01 WS-DOOR                BINARY-LONG.
 01 WS-STAIRS              BINARY-LONG.
 01 WS-CORR                BINARY-LONG.
 01 WS-STAIR-CELL          BINARY-LONG.
 01 WS-DIRS.
    05 WS-DIR              BINARY-LONG OCCURS 4 TIMES.
 01 WS-ND                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-DOORDIR             BINARY-LONG.
 01 WS-KX                  BINARY-LONG.
 01 WS-KZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-WEST                BINARY-LONG.
 01 WS-HOUSE               BINARY-LONG.
 01 WS-NID                 BINARY-LONG.
 01 WS-IS-DOOR             BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-ROOMDIR             BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-STAIRS-ROOM         BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLOOR                BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-GY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FLOOR L-Y L-X L-GY.
     MOVE 1 TO WS-G
     IF L-FLOOR = 2
         MOVE 2 TO WS-G
     END-IF
     COMPUTE WS-FR = 3 + L-FLOOR
     CALL "MNG-GET" USING WS-G L-X L-GY WS-V
     MOVE 0 TO WS-STAIR-CELL
     IF L-FLOOR = 2 AND WS-V = 3
         MOVE 1 TO WS-STAIR-CELL
     END-IF
     IF WS-V NOT = 2 AND WS-STAIR-CELL = 0
         GOBACK
     END-IF
     CALL "MNG-GET" USING WS-FR L-X L-GY WS-CODE
     CALL "MNG-BITS" USING WS-CODE WS-ID WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
     IF WS-STAIR-CELL = 1 AND WS-CORR = 0
         MOVE 0 TO WS-STAIR-CELL
     END-IF
*>   the door direction: a corridor side of a door-bearing origin (a draw), up for a door-less origin, 9 none
     MOVE 0 TO WS-ND
     IF WS-DOOR = 1
         PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3
             CALL "MNG-DIR-STEP" USING WS-D WS-DX WS-DZ
             COMPUTE WS-NX = L-X + WS-DX
             COMPUTE WS-NY = L-GY + WS-DZ
             CALL "MNG-GET" USING WS-G WS-NX WS-NY WS-V
             IF WS-V = 1
                 ADD 1 TO WS-ND
                 MOVE WS-D TO WS-DIR(WS-ND)
             END-IF
         END-PERFORM
     END-IF
     MOVE 9 TO WS-DOORDIR
     IF WS-ND > 0
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-ND WS-DRAW
         COMPUTE WS-D = WS-DRAW + 1
         MOVE WS-DIR(WS-D) TO WS-DOORDIR
     ELSE
         IF WS-ORIGIN = 1
             MOVE 4 TO WS-DOORDIR
         END-IF
     END-IF
     CALL "MNP-K" USING L-X L-GY WS-KX WS-KZ
     MOVE WS-KX TO WS-QX
     MOVE WS-KZ TO WS-QZ
     COMPUTE WS-WEST = FUNCTION MOD(3 + MN-ROT, 4)
     MOVE 1 TO WS-D
     CALL "MNP-REL" USING WS-QX WS-QZ WS-WEST WS-D
*>   the indoor walls: west and south against any house cell of another room, east and north against corridors
     COMPUTE WS-NX = L-X - 1
     CALL "MNG-HOUSE" USING WS-G WS-NX L-GY WS-HOUSE
     CALL "MNG-GET" USING WS-FR WS-NX L-GY WS-V
     COMPUTE WS-NID = FUNCTION MOD(WS-V, 65536)
     IF WS-HOUSE = 1 AND WS-NID NOT = WS-ID
         MOVE 0 TO WS-IS-DOOR
         IF WS-DOORDIR = 3
             MOVE 1 TO WS-IS-DOOR
         END-IF
         MOVE 0 TO WS-E WS-S WS-X1
         CALL "MNP-IWALL" USING L-FLOOR WS-IS-DOOR WS-QX L-Y WS-QZ WS-E WS-S WS-X1
     END-IF
     COMPUTE WS-NX = L-X + 1
     CALL "MNG-GET" USING WS-G WS-NX L-GY WS-V
     IF WS-V = 1 AND WS-STAIR-CELL = 0
         MOVE 0 TO WS-IS-DOOR
         IF WS-DOORDIR = 1
             MOVE 1 TO WS-IS-DOOR
         END-IF
         MOVE 8 TO WS-E
         MOVE 0 TO WS-S WS-X1
         CALL "MNP-IWALL" USING L-FLOOR WS-IS-DOOR WS-QX L-Y WS-QZ WS-E WS-S WS-X1
     END-IF
     COMPUTE WS-NY = L-GY + 1
     CALL "MNG-HOUSE" USING WS-G L-X WS-NY WS-HOUSE
     CALL "MNG-GET" USING WS-FR L-X WS-NY WS-V
     COMPUTE WS-NID = FUNCTION MOD(WS-V, 65536)
     IF WS-HOUSE = 1 AND WS-NID NOT = WS-ID
         MOVE 0 TO WS-IS-DOOR
         IF WS-DOORDIR = 2
             MOVE 1 TO WS-IS-DOOR
         END-IF
         MOVE 7 TO WS-E WS-S
         MOVE 1 TO WS-X1
         CALL "MNP-IWALL" USING L-FLOOR WS-IS-DOOR WS-QX L-Y WS-QZ WS-E WS-S WS-X1
     END-IF
     COMPUTE WS-NY = L-GY - 1
     CALL "MNG-GET" USING WS-G L-X WS-NY WS-V
     IF WS-V = 1 AND WS-STAIR-CELL = 0
         MOVE 0 TO WS-IS-DOOR
         IF WS-DOORDIR = 0
             MOVE 1 TO WS-IS-DOOR
         END-IF
         MOVE 7 TO WS-E
         MOVE -1 TO WS-S
         MOVE 1 TO WS-X1
         CALL "MNP-IWALL" USING L-FLOOR WS-IS-DOOR WS-QX L-Y WS-QZ WS-E WS-S WS-X1
     END-IF
*>   the rooms
     EVALUATE TRUE
         WHEN WS-TYPE = 1
             CALL "MNP-ROOM-1X1" USING WS-QX L-Y WS-QZ MN-ROT WS-DOORDIR L-FLOOR
         WHEN WS-TYPE = 2 AND WS-DOORDIR NOT = 9
             CALL "MNG-ROOM-DIR" USING WS-FR L-X L-GY WS-ID WS-ROOMDIR
             MOVE WS-STAIRS TO WS-STAIRS-ROOM
             CALL "MNP-ROOM-1X2" USING WS-QX L-Y WS-QZ WS-DOORDIR WS-ROOMDIR L-FLOOR WS-STAIRS-ROOM
         WHEN WS-TYPE = 4 AND WS-DOORDIR NOT = 9 AND WS-DOORDIR NOT = 4
             COMPUTE WS-SIDE = FUNCTION MOD(WS-DOORDIR + 1, 4)
             CALL "MNG-DIR-STEP" USING WS-SIDE WS-DX WS-DZ
             COMPUTE WS-NX = L-X + WS-DX
             COMPUTE WS-NY = L-GY + WS-DZ
             CALL "MNG-GET" USING WS-FR WS-NX WS-NY WS-V
             COMPUTE WS-NID = FUNCTION MOD(WS-V, 65536)
             IF WS-NID NOT = WS-ID
                 COMPUTE WS-SIDE = FUNCTION MOD(WS-SIDE + 2, 4)
             END-IF
             CALL "MNP-ROOM-2X2" USING WS-QX L-Y WS-QZ WS-DOORDIR WS-SIDE L-FLOOR
         WHEN WS-TYPE = 4 AND WS-DOORDIR = 4
             CALL "MNP-ROOM-2X2S" USING WS-QX L-Y WS-QZ
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM MNP-CELL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-FLOOR-ROOMS.
*> USING floor: pass 2 of 6.6 over the cells of the floor's grid in y-outer, x-inner order (MNP-CELL).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-FY                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLOOR                BINARY-LONG.
 PROCEDURE DIVISION USING L-FLOOR.
     COMPUTE WS-FY = MN-OY + 8 * L-FLOOR
     IF L-FLOOR = 2
         ADD 3 TO WS-FY
     END-IF
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             CALL "MNP-CELL" USING L-FLOOR WS-FY WS-X WS-Y
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MNP-FLOOR-ROOMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNP-LAYOUT.
*> USING rotation, x, y, z of the origin: createMansion (6.2) over the grids MNG-BUILD made: the entrance, the outer walls of the first and second floor, the third floor's walls, the three roofs and
*> the floors; the list is MN-ENTRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-HOUSE               BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-C1                  BINARY-LONG VALUE 1.
 01 WS-C2                  BINARY-LONG VALUE 2.
 01 WS-C3                  BINARY-LONG VALUE 3.
 01 WS-BASE                BINARY-LONG VALUE 1.
 01 WS-THIRD               BINARY-LONG VALUE 2.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-SOUTH               BINARY-LONG VALUE 2.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-EX                  BINARY-LONG.
 01 WS-EY                  BINARY-LONG.
 01 WS-RY                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROT                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROT L-X L-Y L-Z.
     MOVE 0 TO MN-COUNT MN-LOST
     MOVE L-ROT TO MN-ROT
     MOVE L-X TO MN-OX
     MOVE L-Y TO MN-OY
     MOVE L-Z TO MN-OZ
     MOVE L-X TO MN-CX(1)
     MOVE L-Y TO MN-CY(1)
     MOVE L-Z TO MN-CZ(1)
     MOVE L-ROT TO MN-CROT(1)
     MOVE 0 TO MN-CWALL(1)
     CALL "MNP-C-ENTRANCE" USING WS-C1
     MOVE MN-CX(1) TO MN-CX(2)
     COMPUTE MN-CY(2) = MN-CY(1) + 8
     MOVE MN-CZ(1) TO MN-CZ(2)
     MOVE MN-CROT(1) TO MN-CROT(2)
     MOVE 1 TO MN-CWALL(2)
     MOVE 8 TO WS-SX
     MOVE 5 TO WS-SY
     MOVE 8 TO WS-EX
     MOVE 4 TO WS-EY
     CALL "MNP-OUTER" USING WS-C1 WS-BASE WS-SOUTH WS-SX WS-SY WS-EX WS-EY
     CALL "MNP-OUTER" USING WS-C2 WS-BASE WS-SOUTH WS-SX WS-SY WS-EX WS-EY
*>   the third floor's wall starts at the first house cell of the third grid (y outer, x from 10 down)
     MOVE MN-CX(1) TO MN-CX(3)
     COMPUTE MN-CY(3) = MN-CY(1) + 19
     MOVE MN-CZ(1) TO MN-CZ(3)
     MOVE MN-ROT TO MN-CROT(3)
     MOVE 1 TO MN-CWALL(3)
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10 OR WS-FOUND = 1
         PERFORM VARYING WS-X FROM 10 BY -1 UNTIL WS-X < 0 OR WS-FOUND = 1
             CALL "MNG-HOUSE" USING WS-THIRD WS-X WS-Y WS-HOUSE
             IF WS-HOUSE = 1
                 MOVE 1 TO WS-FOUND
                 MOVE WS-X TO WS-TX
                 MOVE WS-Y TO WS-TY
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-FOUND = 1
         COMPUTE WS-DIR = FUNCTION MOD(2 + MN-ROT, 4)
         COMPUTE WS-N = 8 + (WS-TY - 5) * 8
         CALL "MNP-REL" USING MN-CX(3) MN-CZ(3) WS-DIR WS-N
         COMPUTE WS-DIR = FUNCTION MOD(1 + MN-ROT, 4)
         COMPUTE WS-N = (WS-TX - 8) * 8
         CALL "MNP-REL" USING MN-CX(3) MN-CZ(3) WS-DIR WS-N
         CALL "MNP-C-WALL" USING WS-C3
         MOVE WS-TX TO WS-EX
         MOVE WS-TY TO WS-EY
         CALL "MNP-OUTER" USING WS-C3 WS-THIRD WS-SOUTH WS-TX WS-TY WS-EX WS-EY
     END-IF
     COMPUTE WS-RY = L-Y + 16
     CALL "MNP-ROOF" USING WS-RY WS-BASE WS-THIRD
     COMPUTE WS-RY = L-Y + 27
     CALL "MNP-ROOF" USING WS-RY WS-THIRD WS-NONE
     PERFORM VARYING WS-FLOOR FROM 0 BY 1 UNTIL WS-FLOOR > 2
         CALL "MNP-FLOOR-CORR" USING WS-FLOOR
         CALL "MNP-FLOOR-ROOMS" USING WS-FLOOR
     END-PERFORM
     GOBACK.
 END PROGRAM MNP-LAYOUT.
