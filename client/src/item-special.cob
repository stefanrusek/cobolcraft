*> The items whose item definition is a code-drawn "minecraft:special" model (lane bugbeitems; docs/protocol/52 sections 3.5, 3.10, 4.2 to 4.5, 6.4, 6.7): the chest family (chest,
*> trapped chest, ender chest and the copper chests: the model of `minecraft:chest`), the shulker boxes (`minecraft:shulker_box`) and the banners (`minecraft:banner`). Their item model
*> has no elements, only a particle texture, so the generic path drew a dropped chest as a flat square of the planks. SPECIAL-ITEM-KIND names the kind of an item and the sprites of
*> its texture, SPECIAL-ITEM-QUADS builds the quads of its model (SQ-TABLE of CLSQ.cpy, in the unit cell after the item definition's transformation) from the cuboids of the document
*> with SPECIAL-CUBOID, SPECIAL-ITEM-DISPLAY gives the display transforms of the model (item-special-draw.cob draws the quads on the ground, in the GUI and in the hand).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-DYE-OF.
*> USING name (PIC X(40)), suffix (PIC X(16), what follows the dye in the name: "_banner", "_shulker_box"), dye out: the dye of 43 section 8 (white 0 to black 15) when the name is
*> <dye><suffix>, else -1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DYES-DATA.
    05 FILLER PIC X(12) VALUE "white".
    05 FILLER PIC X(12) VALUE "orange".
    05 FILLER PIC X(12) VALUE "magenta".
    05 FILLER PIC X(12) VALUE "light_blue".
    05 FILLER PIC X(12) VALUE "yellow".
    05 FILLER PIC X(12) VALUE "lime".
    05 FILLER PIC X(12) VALUE "pink".
    05 FILLER PIC X(12) VALUE "gray".
    05 FILLER PIC X(12) VALUE "light_gray".
    05 FILLER PIC X(12) VALUE "cyan".
    05 FILLER PIC X(12) VALUE "purple".
    05 FILLER PIC X(12) VALUE "blue".
    05 FILLER PIC X(12) VALUE "brown".
    05 FILLER PIC X(12) VALUE "green".
    05 FILLER PIC X(12) VALUE "red".
    05 FILLER PIC X(12) VALUE "black".
 01 WS-DYES REDEFINES WS-DYES-DATA.
    05 WS-DYE              PIC X(12) OCCURS 16 TIMES.
 01 WS-D                   BINARY-LONG.
 01 WS-FULL                PIC X(40).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-SUFFIX               PIC X(16).
 01 L-DYE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-SUFFIX L-DYE.
     MOVE -1 TO L-DYE
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 16
         MOVE SPACES TO WS-FULL
         STRING FUNCTION TRIM(WS-DYE(WS-D)) FUNCTION TRIM(L-SUFFIX) DELIMITED BY SIZE INTO WS-FULL
         IF WS-FULL = L-NAME
             COMPUTE L-DYE = WS-D - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPECIAL-DYE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-ITEM-KIND.
*> USING CLIENT-STATE, item id, kind out (0 an item drawn from its icon or block model, 1 the chest family, 2 a shulker box, 3 a banner, 4 a head, 5 a bed: a composite of two block
*> models, 52 5.4, whose ids come back as id 1 (the head half) and id 2 (the foot half) with dye 1 for the straw bed), sprite id 1 and its length, sprite id 2 and
*> its length (PIC X(80) ids of the block atlas: the chest texture of 52 3.3 (the date of the christmas texture is read from the clock) or the shulker texture of 4.1, or the banner's
*> pole and cloth `banner_base` and the white `base` layer the dye tints, 6.3), dye out (the shulker box's dye with 16 undyed, the banner's dye). The standard set's item names are
*> the keys (a set of the cobolcraft world type has none of these).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-NS                  PIC X(16).
 01 WS-NAME                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-SUFFIX              PIC X(16).
 01 WS-DATE                PIC X(21).
 01 WS-MMDD                PIC 9(4).
 01 WS-XMAS                BINARY-LONG.
 01 WS-BLOCK-NAME          PIC X(48).
 01 WS-TYPE                PIC X(8) VALUE "single".
 01 WS-DYES-DATA.
    05 FILLER PIC X(12) VALUE "white".
    05 FILLER PIC X(12) VALUE "orange".
    05 FILLER PIC X(12) VALUE "magenta".
    05 FILLER PIC X(12) VALUE "light_blue".
    05 FILLER PIC X(12) VALUE "yellow".
    05 FILLER PIC X(12) VALUE "lime".
    05 FILLER PIC X(12) VALUE "pink".
    05 FILLER PIC X(12) VALUE "gray".
    05 FILLER PIC X(12) VALUE "light_gray".
    05 FILLER PIC X(12) VALUE "cyan".
    05 FILLER PIC X(12) VALUE "purple".
    05 FILLER PIC X(12) VALUE "blue".
    05 FILLER PIC X(12) VALUE "brown".
    05 FILLER PIC X(12) VALUE "green".
    05 FILLER PIC X(12) VALUE "red".
    05 FILLER PIC X(12) VALUE "black".
 01 WS-DYES REDEFINES WS-DYES-DATA.
    05 WS-DYE              PIC X(12) OCCURS 16 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ID1                  PIC X(80).
 01 L-LEN1                 BINARY-LONG.
 01 L-ID2                  PIC X(80).
 01 L-LEN2                 BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-KIND L-ID1 L-LEN1 L-ID2 L-LEN2 L-DYE.
     MOVE 0 TO L-KIND L-LEN1 L-LEN2 L-DYE
     MOVE SPACES TO L-ID1 L-ID2
     IF L-ITEM < 0 OR NOT (CT-OPEN = 1 AND CT-STATE-COUNT > 0 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT)
         GOBACK
     END-IF
     CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-NAME WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
     IF WS-KNOWN NOT = 1 OR WS-NS NOT = "minecraft"
         GOBACK
     END-IF
     MOVE 0 TO WS-HITS
     INSPECT WS-NAME TALLYING WS-HITS FOR ALL "copper_chest"
     EVALUATE TRUE
         WHEN WS-NAME = "chest" OR WS-NAME = "trapped_chest" OR WS-NAME = "ender_chest" OR WS-HITS > 0
             MOVE 1 TO L-KIND
             MOVE WS-NAME TO WS-BLOCK-NAME
             MOVE FUNCTION CURRENT-DATE TO WS-DATE
             MOVE WS-DATE(5:4) TO WS-MMDD
             CALL "CHEST-CHRISTMAS" USING WS-MMDD WS-XMAS
             CALL "CHEST-TEXTURE" USING WS-BLOCK-NAME WS-TYPE WS-XMAS L-ID1 L-LEN1
         WHEN WS-NAME = "skeleton_skull" OR WS-NAME = "wither_skeleton_skull" OR WS-NAME = "creeper_head" OR WS-NAME = "zombie_head"
                 OR WS-NAME = "player_head"
*>           A head (34-2 1.6.1): the kind 4, the model in L-DYE (0 skeleton, 1 wither skeleton, 2 creeper: the mob head of 64 x 32; 3 zombie, 4 player: the humanoid head with its hat of 64 x 64)
*>           and the entity texture the atlas holds for it (the player's is the default skin of 47 section 2, entry 6).
             MOVE 4 TO L-KIND
             EVALUATE WS-NAME
                 WHEN "skeleton_skull"
                     MOVE 0 TO L-DYE
                     MOVE "minecraft:entity/skeleton/skeleton" TO L-ID1
                     MOVE 34 TO L-LEN1
                 WHEN "wither_skeleton_skull"
                     MOVE 1 TO L-DYE
                     MOVE "minecraft:entity/skeleton/wither_skeleton" TO L-ID1
                     MOVE 41 TO L-LEN1
                 WHEN "creeper_head"
                     MOVE 2 TO L-DYE
                     MOVE "minecraft:entity/creeper/creeper" TO L-ID1
                     MOVE 32 TO L-LEN1
                 WHEN "zombie_head"
                     MOVE 3 TO L-DYE
                     MOVE "minecraft:entity/zombie/zombie" TO L-ID1
                     MOVE 30 TO L-LEN1
                 WHEN OTHER
                     MOVE 4 TO L-DYE
                     MOVE "minecraft:entity/player/slim/steve" TO L-ID1
                     MOVE 34 TO L-LEN1
             END-EVALUATE
         WHEN WS-NAME = "shulker_box"
             MOVE 2 TO L-KIND
             MOVE 16 TO L-DYE
             MOVE "minecraft:entity/shulker/shulker" TO L-ID1
             MOVE 32 TO L-LEN1
         WHEN OTHER
             MOVE "_shulker_box" TO WS-SUFFIX
             CALL "SPECIAL-DYE-OF" USING WS-NAME WS-SUFFIX L-DYE
             IF L-DYE >= 0
                 MOVE 2 TO L-KIND
                 STRING "minecraft:entity/shulker/shulker_" FUNCTION TRIM(WS-DYE(L-DYE + 1)) DELIMITED BY SIZE INTO L-ID1
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(L-ID1)) TO L-LEN1
             ELSE
                 MOVE "_banner" TO WS-SUFFIX
                 CALL "SPECIAL-DYE-OF" USING WS-NAME WS-SUFFIX L-DYE
                 IF L-DYE >= 0
                     MOVE 3 TO L-KIND
                     MOVE "minecraft:entity/banner/banner_base" TO L-ID1
                     MOVE 35 TO L-LEN1
                     MOVE "minecraft:entity/banner/base" TO L-ID2
                     MOVE 28 TO L-LEN2
                 ELSE
*>                   A bed (52 5.4, 5.5): the item definition is a composite of the block models <name>_head and <name>_foot, the straw bed's turned (L-DYE 1).
                     MOVE "_bed" TO WS-SUFFIX
                     CALL "SPECIAL-DYE-OF" USING WS-NAME WS-SUFFIX L-DYE
                     IF L-DYE >= 0 OR WS-NAME = "straw_bed"
                         MOVE 5 TO L-KIND
                         STRING "minecraft:block/" FUNCTION TRIM(WS-NAME) "_head" DELIMITED BY SIZE INTO L-ID1
                         MOVE FUNCTION LENGTH(FUNCTION TRIM(L-ID1)) TO L-LEN1
                         STRING "minecraft:block/" FUNCTION TRIM(WS-NAME) "_foot" DELIMITED BY SIZE INTO L-ID2
                         MOVE FUNCTION LENGTH(FUNCTION TRIM(L-ID2)) TO L-LEN2
                         MOVE 0 TO L-DYE
                         IF WS-NAME = "straw_bed"
                             MOVE 1 TO L-DYE
                         END-IF
                     ELSE
                         MOVE 0 TO L-DYE
                     END-IF
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM SPECIAL-ITEM-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-CUBOID.
*> USING CLIENT-STATE, SQ-TABLE, SQ-PART (CLSQ.cpy): appends the quads of one cuboid. The unwrap is 34 section 1.3: the eight corners A to H (SP-EXCH 1 takes the two ends of y the
*> other way round, the chest's artwork of 52 open question 1), the strip U0..U5 and V0..V2 of the texture offset and size, the six faces of its table with their corners, rectangles and
*> the texture corners (maxU, minV), (minU, minV), (minU, maxV), (maxU, maxV) of vertex 0 to 3. The pixel corners (origin + shift, the faces' ends grown by SP-GROW hundredths) are turned
*> about the pivot (X by SP-RX, then Z by SP-RZ degrees) and go to T + S p / 16. The quads wind clockwise seen from outside (the terrain's winding): the letters of a model with y down wind
*> the other way, so those faces take the vertices 0, 3, 2, 1, each with its own texture corner. The normal is the outward unit normal. The table holds 48 quads.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FACE-DATA.
    05 FILLER PIC X(8) VALUE "65121021".
    05 FILLER PIC X(8) VALUE "34872130".
    05 FILLER PIC X(8) VALUE "15840112".
    05 FILLER PIC X(8) VALUE "21431122".
    05 FILLER PIC X(8) VALUE "62372142".
    05 FILLER PIC X(8) VALUE "56784152".
 01 WS-FACE-TABLE REDEFINES WS-FACE-DATA.
    05 WS-FACE OCCURS 6 TIMES.
       10 WS-FC            PIC 9 OCCURS 4 TIMES.
       10 WS-FMINU         PIC 9.
       10 WS-FMINV         PIC 9.
       10 WS-FMAXU         PIC 9.
       10 WS-FMAXV         PIC 9.
 01 WS-ORDER-DATA          PIC X(8) VALUE "12341432".
 01 WS-ORDER-TABLE REDEFINES WS-ORDER-DATA.
    05 WS-ORD              PIC 9 OCCURS 8 TIMES.
 01 WS-U                   BINARY-LONG OCCURS 6 TIMES.
 01 WS-V                   BINARY-LONG OCCURS 3 TIMES.
 01 WS-GROW                FLOAT-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-YA                  FLOAT-LONG.
 01 WS-YB                  FLOAT-LONG.
 01 WS-CX                  FLOAT-LONG OCCURS 8 TIMES.
 01 WS-CY                  FLOAT-LONG OCCURS 8 TIMES.
 01 WS-CZ                  FLOAT-LONG OCCURS 8 TIMES.
 01 WS-CA                  FLOAT-LONG.
 01 WS-SA                  FLOAT-LONG.
 01 WS-CB                  FLOAT-LONG.
 01 WS-SB                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-U16                 FLOAT-SHORT.
 01 WS-V16                 FLOAT-SHORT.
 01 WS-P                   FLOAT-LONG OCCURS 12 TIMES.
 01 WS-PU                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-PV                  BINARY-LONG OCCURS 4 TIMES.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-NV                  FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY CLSQ.
 COPY CLSQP.
 PROCEDURE DIVISION USING CLIENT-STATE SQ-TABLE SQ-PART.
     COMPUTE WS-U(1) = SP-TEX(1)
     COMPUTE WS-U(2) = SP-TEX(1) + SP-SIZE(3)
     COMPUTE WS-U(3) = SP-TEX(1) + SP-SIZE(3) + SP-SIZE(1)
     COMPUTE WS-U(4) = SP-TEX(1) + SP-SIZE(3) + 2 * SP-SIZE(1)
     COMPUTE WS-U(5) = SP-TEX(1) + 2 * SP-SIZE(3) + SP-SIZE(1)
     COMPUTE WS-U(6) = SP-TEX(1) + 2 * SP-SIZE(3) + 2 * SP-SIZE(1)
     COMPUTE WS-V(1) = SP-TEX(2)
     COMPUTE WS-V(2) = SP-TEX(2) + SP-SIZE(3)
     COMPUTE WS-V(3) = SP-TEX(2) + SP-SIZE(3) + SP-SIZE(2)
     COMPUTE WS-GROW = SP-GROW / 100
     COMPUTE WS-X0 = SP-ORIGIN(1) + SP-SHIFT(1) - WS-GROW
     COMPUTE WS-X1 = SP-ORIGIN(1) + SP-SHIFT(1) + SP-SIZE(1) + WS-GROW
     COMPUTE WS-Y0 = SP-ORIGIN(2) + SP-SHIFT(2) - WS-GROW
     COMPUTE WS-Y1 = SP-ORIGIN(2) + SP-SHIFT(2) + SP-SIZE(2) + WS-GROW
     COMPUTE WS-Z0 = SP-ORIGIN(3) + SP-SHIFT(3) - WS-GROW
     COMPUTE WS-Z1 = SP-ORIGIN(3) + SP-SHIFT(3) + SP-SIZE(3) + WS-GROW
     MOVE WS-Y0 TO WS-YA
     MOVE WS-Y1 TO WS-YB
     IF SP-EXCH = 1
         MOVE WS-Y1 TO WS-YA
         MOVE WS-Y0 TO WS-YB
     END-IF
     MOVE WS-X0 TO WS-CX(1) WS-CX(4) WS-CX(5) WS-CX(8)
     MOVE WS-X1 TO WS-CX(2) WS-CX(3) WS-CX(6) WS-CX(7)
     MOVE WS-YA TO WS-CY(1) WS-CY(2) WS-CY(5) WS-CY(6)
     MOVE WS-YB TO WS-CY(3) WS-CY(4) WS-CY(7) WS-CY(8)
     MOVE WS-Z0 TO WS-CZ(1) WS-CZ(2) WS-CZ(3) WS-CZ(4)
     MOVE WS-Z1 TO WS-CZ(5) WS-CZ(6) WS-CZ(7) WS-CZ(8)
     COMPUTE WS-CA = FUNCTION COS(SP-RX * FUNCTION PI / 180)
     COMPUTE WS-SA = FUNCTION SIN(SP-RX * FUNCTION PI / 180)
     COMPUTE WS-CB = FUNCTION COS(SP-RZ * FUNCTION PI / 180)
     COMPUTE WS-SB = FUNCTION SIN(SP-RZ * FUNCTION PI / 180)
*>   Each corner turned about the pivot (X, then Z) and taken into the unit cell.
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 8
         COMPUTE WS-DX = WS-CX(WS-C) - SP-RPIV(1)
         COMPUTE WS-DY = WS-CY(WS-C) - SP-RPIV(2)
         COMPUTE WS-DZ = WS-CZ(WS-C) - SP-RPIV(3)
         COMPUTE WS-EY = WS-DY * WS-CA - WS-DZ * WS-SA
         COMPUTE WS-EZ = WS-DY * WS-SA + WS-DZ * WS-CA
         COMPUTE WS-EX = WS-DX * WS-CB - WS-EY * WS-SB
         COMPUTE WS-EY = WS-DX * WS-SB + WS-EY * WS-CB
         COMPUTE WS-CX(WS-C) = SP-T(1) + SP-S(1) * (SP-RPIV(1) + WS-EX) / 16
         COMPUTE WS-CY(WS-C) = SP-T(2) + SP-S(2) * (SP-RPIV(2) + WS-EY) / 16
         COMPUTE WS-CZ(WS-C) = SP-T(3) + SP-S(3) * (SP-RPIV(3) + WS-EZ) / 16
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         COMPUTE WS-W = 2 ** (WS-K - 1)
         COMPUTE WS-Q = SP-HIDE / WS-W
         IF FUNCTION MOD(WS-Q, 2) = 0 AND SQ-COUNT < 48
             ADD 1 TO SQ-COUNT
*>           The vertices in the order they are drawn: 0 1 2 3, or 0 3 2 1 for a model with y down.
             MOVE 1 TO WS-O
             IF SP-EXCH = 0
                 MOVE 5 TO WS-O
             END-IF
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
                 MOVE WS-ORD(WS-O + WS-J - 1) TO WS-N
                 MOVE WS-FC(WS-K, WS-N) TO WS-C
                 COMPUTE WS-P((WS-J - 1) * 3 + 1) = WS-CX(WS-C)
                 COMPUTE WS-P((WS-J - 1) * 3 + 2) = WS-CY(WS-C)
                 COMPUTE WS-P((WS-J - 1) * 3 + 3) = WS-CZ(WS-C)
                 MOVE WS-P((WS-J - 1) * 3 + 1) TO SQ-C(SQ-COUNT, (WS-J - 1) * 3 + 1)
                 MOVE WS-P((WS-J - 1) * 3 + 2) TO SQ-C(SQ-COUNT, (WS-J - 1) * 3 + 2)
                 MOVE WS-P((WS-J - 1) * 3 + 3) TO SQ-C(SQ-COUNT, (WS-J - 1) * 3 + 3)
*>               The texture corner of vertex N: 1 (maxU, minV), 2 (minU, minV), 3 (minU, maxV), 4 (maxU, maxV).
                 EVALUATE WS-N
                     WHEN 1
                         COMPUTE WS-U16 = WS-U(WS-FMAXU(WS-K) + 1) * 16 / SP-TSIZE
                         COMPUTE WS-V16 = WS-V(WS-FMINV(WS-K) + 1) * 16 / SP-THEIGHT
                     WHEN 2
                         COMPUTE WS-U16 = WS-U(WS-FMINU(WS-K) + 1) * 16 / SP-TSIZE
                         COMPUTE WS-V16 = WS-V(WS-FMINV(WS-K) + 1) * 16 / SP-THEIGHT
                     WHEN 3
                         COMPUTE WS-U16 = WS-U(WS-FMINU(WS-K) + 1) * 16 / SP-TSIZE
                         COMPUTE WS-V16 = WS-V(WS-FMAXV(WS-K) + 1) * 16 / SP-THEIGHT
                     WHEN OTHER
                         COMPUTE WS-U16 = WS-U(WS-FMAXU(WS-K) + 1) * 16 / SP-TSIZE
                         COMPUTE WS-V16 = WS-V(WS-FMAXV(WS-K) + 1) * 16 / SP-THEIGHT
                 END-EVALUATE
                 CALL "ATLAS-UV" USING CLIENT-STATE SP-SPRITE WS-U16 WS-V16 SQ-U(SQ-COUNT, WS-J) SQ-V(SQ-COUNT, WS-J)
             END-PERFORM
*>           The outward normal: the cross product of the first two edges points into the model.
             COMPUTE WS-DX = WS-P(4) - WS-P(1)
             COMPUTE WS-DY = WS-P(5) - WS-P(2)
             COMPUTE WS-DZ = WS-P(6) - WS-P(3)
             COMPUTE WS-EX = WS-P(7) - WS-P(4)
             COMPUTE WS-EY = WS-P(8) - WS-P(5)
             COMPUTE WS-EZ = WS-P(9) - WS-P(6)
             COMPUTE WS-NV(1) = WS-DZ * WS-EY - WS-DY * WS-EZ
             COMPUTE WS-NV(2) = WS-DX * WS-EZ - WS-DZ * WS-EX
             COMPUTE WS-NV(3) = WS-DY * WS-EX - WS-DX * WS-EY
             COMPUTE WS-LEN = FUNCTION SQRT(WS-NV(1) * WS-NV(1) + WS-NV(2) * WS-NV(2) + WS-NV(3) * WS-NV(3))
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
                 COMPUTE SQ-N(SQ-COUNT, WS-J) = WS-NV(WS-J) / WS-LEN
                 MOVE SP-TINT(WS-J) TO SQ-T(SQ-COUNT, WS-J)
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SPECIAL-CUBOID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-ROW-PART.
*> USING row (PIC X(95): 19 numbers of five characters, sign and four digits), SQ-PART (CLSQP.cpy): the cuboid of a model row: origin (3), size (3), texture offset (2), shift (3), rotation
*> pivot (3), rotation about X and about Z in hundredths of a degree, the hidden faces, the grow in hundredths of a pixel, and SP-SPRITE the row's sprite slot. The caller sets the
*> rest (texture size, y convention, translation, scale, tint, the sprite).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW.
    05 L-F                 PIC S9(4) SIGN LEADING SEPARATE OCCURS 19 TIMES.
 COPY CLSQP.
 PROCEDURE DIVISION USING L-ROW SQ-PART.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         MOVE L-F(WS-K) TO SP-ORIGIN(WS-K)
         MOVE L-F(WS-K + 3) TO SP-SIZE(WS-K)
         MOVE L-F(WS-K + 8) TO SP-SHIFT(WS-K)
         MOVE L-F(WS-K + 11) TO SP-RPIV(WS-K)
     END-PERFORM
     MOVE L-F(7) TO SP-TEX(1)
     MOVE L-F(8) TO SP-TEX(2)
     COMPUTE SP-RX = L-F(15) / 100
     COMPUTE SP-RZ = L-F(16) / 100
     MOVE L-F(17) TO SP-HIDE
     MOVE L-F(18) TO SP-GROW
     MOVE L-F(19) TO SP-SPRITE
     GOBACK.
 END PROGRAM SPECIAL-ROW-PART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SPECIAL-ITEM-QUADS.
*> USING CLIENT-STATE, item id, SQ-TABLE (CLSQ.cpy): the quads of the item's model, SQ-COUNT 0 for an item that is not code-drawn (SPECIAL-ITEM-KIND). The cuboids are the rows of 52:
*> the chest 3.5 (bottom, lid, lock of the single chest, closed, y up; the faces inside the closed chest are left out: the bottom's top and the lid's bottom), the shulker box 4.2 with
*> the local transformation of 4.5 (T (0.5, 1.4995, 0.5), S (0.9995, -0.9995, -0.9995), y down: lid, base; the faces inside the box are left out), the banner 6.4 with 6.7 (T (0.5, 0, 0.5), S
*> (2/3, -2/3, -2/3): pole, bar, the flag at the phase 0 of 6.5, and the flag again 0.05 pixel larger with the white `base` sprite tinted by the dye, 6.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS-DATA.
    05 FILLER PIC X(95) VALUE "+0001+0000+0001+0014+0010+0014+0000+0019+0000+0000+0000+0000+0000+0000+0000+0000+0001+0000+0001".
    05 FILLER PIC X(95) VALUE "+0001+0000+0000+0014+0005+0014+0000+0000+0000+0009+0001+0000+0009+0001+0000+0000+0002+0000+0001".
    05 FILLER PIC X(95) VALUE "+0007-0002+0014+0002+0004+0001+0000+0000+0000+0009+0001+0000+0009+0001+0000+0000+0000+0000+0001".
    05 FILLER PIC X(95) VALUE "-0008-0016-0008+0016+0012+0016+0000+0000+0000+0024+0000+0000+0024+0000+0000+0000+0002+0000+0001".
    05 FILLER PIC X(95) VALUE "-0008-0008-0008+0016+0008+0016+0000+0028+0000+0024+0000+0000+0024+0000+0000+0000+0001+0000+0001".
    05 FILLER PIC X(95) VALUE "-0001-0042-0001+0002+0042+0002+0044+0000+0000+0000+0000+0000+0000+0000+0000+0000+0000+0000+0001".
    05 FILLER PIC X(95) VALUE "-0010-0044-0001+0020+0002+0002+0000+0042+0000+0000+0000+0000+0000+0000+0000+0000+0000+0000+0001".
    05 FILLER PIC X(95) VALUE "-0010+0000-0002+0020+0040+0001+0000+0000+0000-0044+0000+0000-0044+0000-0045+0000+0000+0000+0001".
    05 FILLER PIC X(95) VALUE "-0010+0000-0002+0020+0040+0001+0000+0000+0000-0044+0000+0000-0044+0000-0045+0000+0000+0005+0002".
    05 FILLER PIC X(95) VALUE "-0004-0008-0004+0008+0008+0008+0000+0000+0000+0000+0000+0000+0000+0000+0000+0000+0000+0000+0001".
    05 FILLER PIC X(95) VALUE "-0004-0008-0004+0008+0008+0008+0032+0000+0000+0000+0000+0000+0000+0000+0000+0000+0000+0025+0001".
 01 WS-ROWS REDEFINES WS-ROWS-DATA.
    05 WS-ROW OCCURS 11 TIMES.
       10 WS-F             PIC S9(4) SIGN LEADING SEPARATE OCCURS 19 TIMES.
*> The diffuse colour of each dye (52 6.3), red green blue as three digits each.
 01 WS-COLOURS-DATA        PIC X(144) VALUE "249255254249128029199078189058179218254216061128199031243139170071079082157157151022156156137050184060068170131084050094124022176046038029029033".
 01 WS-COLOURS REDEFINES WS-COLOURS-DATA.
    05 WS-COLOUR OCCURS 16 TIMES.
       10 WS-RGB           PIC 999 OCCURS 3 TIMES.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID1                 PIC X(80).
 01 WS-LEN1                BINARY-LONG.
 01 WS-ID2                 PIC X(80).
 01 WS-LEN2                BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-SPRITE1             BINARY-LONG.
 01 WS-SPRITE2             BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-EXCH                BINARY-LONG.
 01 WS-THEIGHT             BINARY-LONG.
 01 WS-TX                  FLOAT-LONG OCCURS 3 TIMES.
 01 WS-SX                  FLOAT-LONG OCCURS 3 TIMES.
 COPY CLSQP.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 COPY CLSQ.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM SQ-TABLE.
     MOVE 0 TO SQ-COUNT
     CALL "SPECIAL-ITEM-KIND" USING CLIENT-STATE L-ITEM WS-KIND WS-ID1 WS-LEN1 WS-ID2 WS-LEN2 WS-DYE
     IF WS-KIND = 0
         GOBACK
     END-IF
*>   A bed is the quads of its two block models, not cuboids of a texture strip.
     IF WS-KIND = 5
         CALL "SPECIAL-BED-QUADS" USING CLIENT-STATE WS-ID1 WS-LEN1 WS-ID2 WS-LEN2 WS-DYE SQ-TABLE
         GOBACK
     END-IF
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID1 WS-LEN1 WS-SPRITE1
     IF WS-SPRITE1 = 0
         MOVE 1 TO WS-SPRITE1
     END-IF
     MOVE 1 TO WS-SPRITE2
     IF WS-LEN2 > 0
         CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID2 WS-LEN2 WS-SPRITE2
         IF WS-SPRITE2 = 0
             MOVE 1 TO WS-SPRITE2
         END-IF
     END-IF
     MOVE 0 TO WS-TX(1) WS-TX(2) WS-TX(3)
     MOVE 1 TO WS-SX(1) WS-SX(2) WS-SX(3)
     MOVE 64 TO WS-THEIGHT
     MOVE 1 TO WS-FIRST WS-EXCH
     MOVE 3 TO WS-LAST
     EVALUATE WS-KIND
         WHEN 2
             MOVE 4 TO WS-FIRST
             MOVE 5 TO WS-LAST
             MOVE 0 TO WS-EXCH
             MOVE 0.5 TO WS-TX(1) WS-TX(3)
             MOVE 1.4995 TO WS-TX(2)
             MOVE 0.9995 TO WS-SX(1)
             MOVE -0.9995 TO WS-SX(2) WS-SX(3)
         WHEN 4
*>           The head is the first row, the hat of a humanoid head the second (grown 0.25 pixel); y down like the banner, the item's own transformation T (0.5, 0, 0.5), S (1, -1, -1).
             MOVE 10 TO WS-FIRST
             MOVE 10 TO WS-LAST
             MOVE 32 TO WS-THEIGHT
             IF WS-DYE >= 3
                 MOVE 11 TO WS-LAST
                 MOVE 64 TO WS-THEIGHT
             END-IF
             MOVE 0 TO WS-EXCH
             MOVE 0.5 TO WS-TX(1) WS-TX(3)
             MOVE -1 TO WS-SX(2) WS-SX(3)
         WHEN 3
             MOVE 6 TO WS-FIRST
             MOVE 9 TO WS-LAST
             MOVE 0 TO WS-EXCH
             MOVE 0.5 TO WS-TX(1) WS-TX(3)
             MOVE 0.6666667 TO WS-SX(1)
             MOVE -0.6666667 TO WS-SX(2) WS-SX(3)
     END-EVALUATE
     PERFORM VARYING WS-R FROM WS-FIRST BY 1 UNTIL WS-R > WS-LAST
         CALL "SPECIAL-ROW-PART" USING WS-ROW(WS-R) SQ-PART
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
             MOVE WS-TX(WS-K) TO SP-T(WS-K)
             MOVE WS-SX(WS-K) TO SP-S(WS-K)
             MOVE 1 TO SP-TINT(WS-K)
         END-PERFORM
         MOVE 64 TO SP-TSIZE
         MOVE WS-THEIGHT TO SP-THEIGHT
         MOVE WS-EXCH TO SP-EXCH
         IF SP-SPRITE = 2
             MOVE WS-SPRITE2 TO SP-SPRITE
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
                 COMPUTE SP-TINT(WS-K) = WS-RGB(WS-DYE + 1, WS-K) / 255
             END-PERFORM
         ELSE
             MOVE WS-SPRITE1 TO SP-SPRITE
         END-IF
         CALL "SPECIAL-CUBOID" USING CLIENT-STATE SQ-TABLE SQ-PART
     END-PERFORM
     GOBACK.
 END PROGRAM SPECIAL-ITEM-QUADS.
