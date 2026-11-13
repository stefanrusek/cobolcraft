*> The chest family drawn by the chunk mesher (docs/protocol/52 section 3; T5001). The block model of a chest, a trapped chest, an
*> ender chest and a copper chest has no elements, so the shipped client draws them from the block entity renderer; here a state of
*> these blocks is baked from the entity model of 52 3.4 and 3.5, lid closed: CHEST-BAKE fills BM-STATE of the row with the quads of
*> the three cuboids (bottom, lid, lock) of the single, left or right model, turned to the facing, with the texture of 52 3.3 from
*> the chest atlas (atlases/chests.json, added to the block atlas by ATLAS-BUILD). CHEST-TEXTURE names the texture.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHEST-TEXTURE.
*> USING block name (PIC X(48), without namespace), type (PIC X(8): single, left, right), christmas (BINARY-LONG, 1 when the date is
*> December 24 to 26), sprite id out (PIC X(80)), its length: the sprite of 52 3.3: copper by weathering stage (waxing is not
*> distinguished), the ender chest, christmas over trapped, trapped, else normal; "_left" and "_right" for a half (the ender chest has none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                PIC X(24).
 01 WS-HITS                BINARY-LONG.
 01 WS-SUFFIX              PIC X(6).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(48).
 01 L-TYPE                 PIC X(8).
 01 L-CHRISTMAS            BINARY-LONG.
 01 L-ID                   PIC X(80).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-TYPE L-CHRISTMAS L-ID L-LENGTH.
     MOVE "normal" TO WS-BASE
     MOVE 0 TO WS-HITS
     INSPECT L-NAME TALLYING WS-HITS FOR ALL "copper_chest"
     EVALUATE TRUE
         WHEN WS-HITS > 0
             MOVE "copper" TO WS-BASE
             MOVE 0 TO WS-HITS
             INSPECT L-NAME TALLYING WS-HITS FOR ALL "exposed"
             IF WS-HITS > 0
                 MOVE "copper_exposed" TO WS-BASE
             END-IF
             MOVE 0 TO WS-HITS
             INSPECT L-NAME TALLYING WS-HITS FOR ALL "weathered"
             IF WS-HITS > 0
                 MOVE "copper_weathered" TO WS-BASE
             END-IF
             MOVE 0 TO WS-HITS
             INSPECT L-NAME TALLYING WS-HITS FOR ALL "oxidized"
             IF WS-HITS > 0
                 MOVE "copper_oxidized" TO WS-BASE
             END-IF
         WHEN L-NAME = "ender_chest"
             MOVE "ender" TO WS-BASE
         WHEN L-CHRISTMAS = 1
             MOVE "christmas" TO WS-BASE
         WHEN L-NAME = "trapped_chest"
             MOVE "trapped" TO WS-BASE
     END-EVALUATE
     MOVE SPACES TO WS-SUFFIX
     IF L-TYPE = "left" AND WS-BASE NOT = "ender"
         MOVE "_left" TO WS-SUFFIX
     END-IF
     IF L-TYPE = "right" AND WS-BASE NOT = "ender"
         MOVE "_right" TO WS-SUFFIX
     END-IF
     MOVE SPACES TO L-ID
     STRING "minecraft:entity/chest/" FUNCTION TRIM(WS-BASE) FUNCTION TRIM(WS-SUFFIX) DELIMITED BY SIZE INTO L-ID
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-ID)) TO L-LENGTH
     GOBACK.
 END PROGRAM CHEST-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CHEST-BAKE.
*> USING CLIENT-STATE, BM-STATE row, block name (PIC X(48)), facing (PIC X(8)), type (PIC X(8)): bakes the closed chest of the state
*> into the row. The cuboid table is 52 3.5 in block pixels (the part pivots added to the origins, nine rows: single, right half,
*> left half, each bottom, lid, lock; the hidden face is the one at the seam); the faces, strips and vertex texture coordinates are
*> 34 section 1.3; facing south is the model as it stands, west, north and east turn it clockwise by 90, 180 and 270 degrees
*> (52 3.6). The date of the christmas texture is read from the clock (52 3.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLQUAD.
 01 WS-DEFS-DATA.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 14.
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 14.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 19.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 9.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 14.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 14.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 14.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 19.
       10 FILLER BINARY-LONG VALUE 6.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 9.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 14.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 6.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 6.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 10.
       10 FILLER BINARY-LONG VALUE 14.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 19.
       10 FILLER BINARY-LONG VALUE 5.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 9.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 14.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 5.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 15.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 5.
 01 WS-DEFS REDEFINES WS-DEFS-DATA.
    05 WS-DEF OCCURS 9 TIMES.
       10 WS-D-X BINARY-LONG.
       10 WS-D-Y BINARY-LONG.
       10 WS-D-Z BINARY-LONG.
       10 WS-D-W BINARY-LONG.
       10 WS-D-H BINARY-LONG.
       10 WS-D-D BINARY-LONG.
       10 WS-D-U BINARY-LONG.
       10 WS-D-V BINARY-LONG.
       10 WS-D-HIDE BINARY-LONG.
 01 WS-FACES-DATA.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 0.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 0.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 3.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 2.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 2.
    05 FILLER.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 6.
       10 FILLER BINARY-LONG VALUE 7.
       10 FILLER BINARY-LONG VALUE 8.
       10 FILLER BINARY-LONG VALUE 4.
       10 FILLER BINARY-LONG VALUE 1.
       10 FILLER BINARY-LONG VALUE 5.
       10 FILLER BINARY-LONG VALUE 2.
 01 WS-FACES REDEFINES WS-FACES-DATA.
    05 WS-FACE OCCURS 6 TIMES.
       10 WS-F-DIR BINARY-LONG.
       10 WS-F-C BINARY-LONG OCCURS 4 TIMES.
       10 WS-F-MINU BINARY-LONG.
       10 WS-F-MINV BINARY-LONG.
       10 WS-F-MAXU BINARY-LONG.
       10 WS-F-MAXV BINARY-LONG.
 01 WS-DATE                PIC X(21).
 01 WS-MMDD                PIC 9(4).
 01 WS-XMAS                BINARY-LONG.
 01 WS-ID                  PIC X(80).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-CUBOID              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-Y-ROT               BINARY-LONG.
 01 WS-NO-ROT              BINARY-LONG VALUE 0.
 01 WS-NO-ROT-Z            BINARY-LONG VALUE 0.
 01 WS-CORNER-X            FLOAT-LONG OCCURS 8 TIMES.
 01 WS-CORNER-Y            FLOAT-LONG OCCURS 8 TIMES.
 01 WS-CORNER-Z            FLOAT-LONG OCCURS 8 TIMES.
 01 WS-U                   BINARY-LONG OCCURS 6 TIMES.
 01 WS-V                   BINARY-LONG OCCURS 3 TIMES.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-VX                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-VY                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-VZ                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-VU                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-VV                  FLOAT-LONG OCCURS 4 TIMES.
 01 WS-J                   BINARY-LONG.
 01 WS-DOT                 FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-BX                  FLOAT-LONG.
 01 WS-BY                  FLOAT-LONG.
 01 WS-BZ                  FLOAT-LONG.
 01 WS-NORMAL              FLOAT-LONG.
 01 WS-ORDER               BINARY-LONG OCCURS 4 TIMES.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-S                    BINARY-LONG.
 01 L-NAME                 PIC X(48).
 01 L-FACING               PIC X(8).
 01 L-TYPE                 PIC X(8).
 PROCEDURE DIVISION USING CLIENT-STATE L-S L-NAME L-FACING L-TYPE.
     MOVE 0 TO BM-QUAD-COUNT(L-S)
     MOVE FUNCTION CURRENT-DATE TO WS-DATE
     MOVE WS-DATE(5:4) TO WS-MMDD
     MOVE 0 TO WS-XMAS
     IF WS-MMDD >= 1224 AND WS-MMDD <= 1226
         MOVE 1 TO WS-XMAS
     END-IF
     CALL "CHEST-TEXTURE" USING L-NAME L-TYPE WS-XMAS WS-ID WS-ID-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LENGTH WS-SPRITE
     IF WS-SPRITE = 0
         MOVE 1 TO WS-SPRITE
     END-IF
     MOVE 0 TO WS-BASE
     IF L-TYPE = "right" AND L-NAME NOT = "ender_chest"
         MOVE 3 TO WS-BASE
     END-IF
     IF L-TYPE = "left" AND L-NAME NOT = "ender_chest"
         MOVE 6 TO WS-BASE
     END-IF
     MOVE 0 TO WS-Y-ROT
     EVALUATE L-FACING
         WHEN "west"
             MOVE 90 TO WS-Y-ROT
         WHEN "north"
             MOVE 180 TO WS-Y-ROT
         WHEN "east"
             MOVE 270 TO WS-Y-ROT
     END-EVALUATE
     PERFORM VARYING WS-CUBOID FROM 1 BY 1 UNTIL WS-CUBOID > 3
         COMPUTE WS-I = WS-BASE + WS-CUBOID
*>       Strip coordinates (34 1.3 step 4) and the eight corners A to H (step 3).
         COMPUTE WS-U(1) = WS-D-U(WS-I)
         COMPUTE WS-U(2) = WS-D-U(WS-I) + WS-D-D(WS-I)
         COMPUTE WS-U(3) = WS-D-U(WS-I) + WS-D-D(WS-I) + WS-D-W(WS-I)
         COMPUTE WS-U(4) = WS-D-U(WS-I) + WS-D-D(WS-I) + 2 * WS-D-W(WS-I)
         COMPUTE WS-U(5) = WS-D-U(WS-I) + 2 * WS-D-D(WS-I) + WS-D-W(WS-I)
         COMPUTE WS-U(6) = WS-D-U(WS-I) + 2 * WS-D-D(WS-I) + 2 * WS-D-W(WS-I)
         COMPUTE WS-V(1) = WS-D-V(WS-I)
         COMPUTE WS-V(2) = WS-D-V(WS-I) + WS-D-D(WS-I)
         COMPUTE WS-V(3) = WS-D-V(WS-I) + WS-D-D(WS-I) + WS-D-H(WS-I)
         COMPUTE WS-X1 = WS-D-X(WS-I) + WS-D-W(WS-I)
         COMPUTE WS-Y1 = WS-D-Y(WS-I) + WS-D-H(WS-I)
         COMPUTE WS-Z1 = WS-D-Z(WS-I) + WS-D-D(WS-I)
         MOVE WS-D-X(WS-I) TO WS-CORNER-X(1) WS-CORNER-X(4) WS-CORNER-X(5) WS-CORNER-X(8)
         MOVE WS-X1 TO WS-CORNER-X(2) WS-CORNER-X(3) WS-CORNER-X(6) WS-CORNER-X(7)
*>       The artwork is laid out for a model with y down (the top rectangle belongs to the face the table calls DOWN): the letters
*>       take the opposite end of y, so the table's DOWN face is the top of the cuboid and its UP face the bottom (52 open question 1).
         MOVE WS-Y1 TO WS-CORNER-Y(1) WS-CORNER-Y(2) WS-CORNER-Y(5) WS-CORNER-Y(6)
         MOVE WS-D-Y(WS-I) TO WS-CORNER-Y(3) WS-CORNER-Y(4) WS-CORNER-Y(7) WS-CORNER-Y(8)
         MOVE WS-D-Z(WS-I) TO WS-CORNER-Z(1) WS-CORNER-Z(2) WS-CORNER-Z(3) WS-CORNER-Z(4)
         MOVE WS-Z1 TO WS-CORNER-Z(5) WS-CORNER-Z(6) WS-CORNER-Z(7) WS-CORNER-Z(8)
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             IF WS-F-DIR(WS-K) NOT = WS-D-HIDE(WS-I) AND BM-QUAD-COUNT(L-S) < CL-MAX-QUADS
*>               Vertex 0 to 3 of the face with texture corners (maxU, minV), (minU, minV), (minU, maxV), (maxU, maxV).
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
                     MOVE WS-F-C(WS-K, WS-J) TO WS-C
                     MOVE WS-CORNER-X(WS-C) TO WS-VX(WS-J)
                     MOVE WS-CORNER-Y(WS-C) TO WS-VY(WS-J)
                     MOVE WS-CORNER-Z(WS-C) TO WS-VZ(WS-J)
                 END-PERFORM
                 COMPUTE WS-VU(1) = WS-U(WS-F-MAXU(WS-K) + 1) * 16 / 64
                 COMPUTE WS-VU(2) = WS-U(WS-F-MINU(WS-K) + 1) * 16 / 64
                 COMPUTE WS-VU(3) = WS-U(WS-F-MINU(WS-K) + 1) * 16 / 64
                 COMPUTE WS-VU(4) = WS-U(WS-F-MAXU(WS-K) + 1) * 16 / 64
                 COMPUTE WS-VV(1) = WS-V(WS-F-MINV(WS-K) + 1) * 16 / 64
                 COMPUTE WS-VV(2) = WS-V(WS-F-MINV(WS-K) + 1) * 16 / 64
                 COMPUTE WS-VV(3) = WS-V(WS-F-MAXV(WS-K) + 1) * 16 / 64
                 COMPUTE WS-VV(4) = WS-V(WS-F-MAXV(WS-K) + 1) * 16 / 64
*>               The winding of the mesher (ELEMENT-BAKE): the cross product of the first two edges points into the block.
                 COMPUTE WS-AX = WS-VX(2) - WS-VX(1)
                 COMPUTE WS-AY = WS-VY(2) - WS-VY(1)
                 COMPUTE WS-AZ = WS-VZ(2) - WS-VZ(1)
                 COMPUTE WS-BX = WS-VX(3) - WS-VX(1)
                 COMPUTE WS-BY = WS-VY(3) - WS-VY(1)
                 COMPUTE WS-BZ = WS-VZ(3) - WS-VZ(1)
                 EVALUATE WS-F-DIR(WS-K)
                     WHEN DIR-DOWN
                         COMPUTE WS-DOT = 0 - (WS-AZ * WS-BX - WS-AX * WS-BZ)
                     WHEN DIR-UP
                         COMPUTE WS-DOT = WS-AZ * WS-BX - WS-AX * WS-BZ
                     WHEN DIR-NORTH
                         COMPUTE WS-DOT = 0 - (WS-AX * WS-BY - WS-AY * WS-BX)
                     WHEN DIR-SOUTH
                         COMPUTE WS-DOT = WS-AX * WS-BY - WS-AY * WS-BX
                     WHEN DIR-WEST
                         COMPUTE WS-DOT = 0 - (WS-AY * WS-BZ - WS-AZ * WS-BY)
                     WHEN DIR-EAST
                         COMPUTE WS-DOT = WS-AY * WS-BZ - WS-AZ * WS-BY
                 END-EVALUATE
                 MOVE 1 TO WS-ORDER(1)
                 MOVE 2 TO WS-ORDER(2)
                 MOVE 3 TO WS-ORDER(3)
                 MOVE 4 TO WS-ORDER(4)
                 IF WS-DOT > 0
                     MOVE 4 TO WS-ORDER(2)
                     MOVE 2 TO WS-ORDER(4)
                 END-IF
                 MOVE DIR-NONE TO QD-CULL
                 MOVE WS-F-DIR(WS-K) TO QD-SHADE
                 MOVE WS-SPRITE TO QD-SPRITE
                 MOVE -1 TO QD-TINT
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
                     MOVE WS-ORDER(WS-J) TO WS-C
                     COMPUTE QD-X(WS-J) = WS-VX(WS-C) / 16
                     COMPUTE QD-Y(WS-J) = WS-VY(WS-C) / 16
                     COMPUTE QD-Z(WS-J) = WS-VZ(WS-C) / 16
                     MOVE WS-VU(WS-C) TO QD-U(WS-J)
                     MOVE WS-VV(WS-C) TO QD-V(WS-J)
                 END-PERFORM
                 CALL "VARIANT-ROTATE" USING QUAD WS-NO-ROT WS-Y-ROT WS-NO-ROT-Z
                 ADD 1 TO BM-QUAD-COUNT(L-S)
                 MOVE QUAD TO BM-QUAD(L-S, BM-QUAD-COUNT(L-S))
                 MOVE BM-QUAD-COUNT(L-S) TO WS-N
                 PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
                     CALL "ATLAS-UV" USING CLIENT-STATE WS-SPRITE QD-U(WS-J) QD-V(WS-J)
                         BM-AU(L-S, WS-N, WS-J) BM-AV(L-S, WS-N, WS-J)
                     CALL "SIXTEENTHS" USING QD-X(WS-J) BM-IX(L-S, WS-N, WS-J)
                     CALL "SIXTEENTHS" USING QD-Y(WS-J) BM-IY(L-S, WS-N, WS-J)
                     CALL "SIXTEENTHS" USING QD-Z(WS-J) BM-IZ(L-S, WS-N, WS-J)
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CHEST-BAKE.
