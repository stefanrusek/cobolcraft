*> The shield (12 section 6.12; 54 section 22.3 rule 4 for the layers). SHIELD-ITEM tells the `shield` item. SHIELD-DRAW draws the model of ShieldModel.createLayer (64 x 64 texture, parts in
*> pixels): the plate (texture offset (0, 0), origin (-6, -11, -2), size 12 x 22 x 1) and the handle (offset (26, 0), origin (-1, -3, -1), size 2 x 6 x 6) after the item definition's
*> transformation L = scale (1, -1, -1), with the sprite `shield_base_nopattern` (the entity atlas slot of the row `shield`, code 0) when the stack has neither banner_patterns nor a base_color and
*> `shield_base` (code 9000) otherwise; a patterned shield then draws the model again for the base layer (the sprite `base`, code 9001, tinted by the diffuse colour of the base colour, white when
*> the stack has none, order 1) and for each of the first 16 layers (the pattern's sprite, code 9000 + the holder, tinted by the layer's dye, order i + 2), each 0.05 pixel nearer the front than the one
*> before (the opaque pipeline needs that to show them in order). The enchantment glint of a shield is not drawn. HAND-SHIELD is the first-person form (the layers of the stack in the hand's slot),
*> ENTITY-SHIELD-HELD the third-person one (the layers of EN-HB), HAND-SHIELD-SLOTS and ENTITY-SHIELD-SLOTS give the sprites their slots of the entity atlas.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHIELD-ITEM.
*> USING CLIENT-STATE, item id, flag out (1 for the item minecraft:shield, else 0; an unknown id and no item are 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-ITEM >= 0
         CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-KNOWN = 1 AND WS-NS = "minecraft" AND WS-PATH = "shield"
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHIELD-ITEM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHIELD-FIND-SLOT.
*> USING CLIENT-STATE, model row of `shield`, texture code, slot out (the entity atlas slot EA-MT of that model and code, 0 when it has none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-CODE                 BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-CODE L-SLOT.
     MOVE 0 TO L-SLOT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EA-MT-COUNT
         IF EA-MT-MODEL(WS-K) = L-ROW AND EA-MT-TEX(WS-K) = L-CODE
             MOVE WS-K TO L-SLOT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SHIELD-FIND-SLOT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHIELD-MODEL.
*> USING CLIENT-STATE, M (12 FLOAT-LONG: the pose with L), atlas slot, tint (3 FLOAT-LONG), light, mode (3 the hand mesh, 5 the entity mesh), order (BINARY-LONG): the plate and the handle
*> at the order's depth, 0.05 pixel per order toward the front (smaller z).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-GEOM.
    05 WS-GV               FLOAT-LONG OCCURS 15 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-SLOT                 BINARY-LONG.
 01 L-TINT.
    05 L-TV                FLOAT-LONG OCCURS 3 TIMES.
 01 L-LIGHT                FLOAT-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-ORDER                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-SLOT L-TINT L-LIGHT L-MODE L-ORDER.
     MOVE 0 TO WS-GV(1) WS-GV(2) WS-GV(3) WS-GV(4) WS-GV(13)
     MOVE 64 TO WS-GV(14) WS-GV(15)
     MOVE -6 TO WS-GV(5)
     MOVE -11 TO WS-GV(6)
     COMPUTE WS-GV(7) = -2 - 0.05 * L-ORDER
     MOVE 12 TO WS-GV(8)
     MOVE 22 TO WS-GV(9)
     MOVE 1 TO WS-GV(10)
     MOVE 0 TO WS-GV(11) WS-GV(12)
     CALL "HAND-CUBOID-MODE" USING CLIENT-STATE L-M L-SLOT WS-GEOM L-TINT L-LIGHT L-MODE
     MOVE -1 TO WS-GV(5)
     MOVE -3 TO WS-GV(6)
     COMPUTE WS-GV(7) = -1 - 0.05 * L-ORDER
     MOVE 2 TO WS-GV(8)
     MOVE 6 TO WS-GV(9) WS-GV(10)
     MOVE 26 TO WS-GV(11)
     CALL "HAND-CUBOID-MODE" USING CLIENT-STATE L-M L-SLOT WS-GEOM L-TINT L-LIGHT L-MODE
     GOBACK.
 END PROGRAM SHIELD-MODEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHIELD-DRAW.
*> USING CLIENT-STATE, M (12 FLOAT-LONG: the pose through the display transform and the recentring of the item), layers (BINARY-LONG count, 16 holders, 16 dyes, the base colour as dye id + 1
*> or 0 for none), light 0 to 1 (FLOAT-LONG), mode (3 the hand mesh, 5 the entity mesh): the plate and the handle, then the layers of a patterned shield.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24) VALUE "shield".
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ORDER               BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-PATTERNED           BINARY-LONG.
 01 WS-ARGB                BINARY-DOUBLE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-TINT.
    05 WS-TV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-SHIELD.
    05 L-COUNT             BINARY-LONG.
    05 L-PAT               BINARY-LONG OCCURS 16 TIMES.
    05 L-DYES              BINARY-LONG OCCURS 16 TIMES.
    05 L-BASE              BINARY-LONG.
 01 L-LIGHT                FLOAT-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-SHIELD L-LIGHT L-MODE.
     CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-ROW
     IF WS-ROW = 0 OR EA-W = 0 OR EA-H = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-PATTERNED
     IF L-COUNT > 0 OR L-BASE > 0
         MOVE 1 TO WS-PATTERNED
     END-IF
*>   The item definition's transformation L: scale (1, -1, -1), once.
     MOVE L-M TO WS-M
     MOVE 1 TO WS-X
     MOVE -1 TO WS-Y WS-Z
     CALL "HAND-M-SCALE" USING WS-M WS-X WS-Y WS-Z
     MOVE 1 TO WS-TV(1) WS-TV(2) WS-TV(3)
     MOVE 0 TO WS-CODE
     IF WS-PATTERNED = 1
         MOVE 9000 TO WS-CODE
     END-IF
     CALL "SHIELD-FIND-SLOT" USING CLIENT-STATE WS-ROW WS-CODE WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-ORDER
     CALL "SHIELD-MODEL" USING CLIENT-STATE WS-M WS-SLOT WS-TINT L-LIGHT L-MODE WS-ORDER
     IF WS-PATTERNED = 1
*>       The base colour layer (the sprite `base`, order 1), then each pattern (order 2 on, its dye).
         PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N > L-COUNT OR WS-N > 16
             IF WS-N = 0
                 MOVE 9001 TO WS-CODE
                 MOVE 0 TO WS-DYE
                 IF L-BASE > 0
                     COMPUTE WS-DYE = L-BASE - 1
                 END-IF
                 MOVE 1 TO WS-ORDER
             ELSE
                 COMPUTE WS-CODE = 9000 + L-PAT(WS-N)
                 MOVE L-DYES(WS-N) TO WS-DYE
                 COMPUTE WS-ORDER = WS-N + 1
             END-IF
             CALL "SHIELD-FIND-SLOT" USING CLIENT-STATE WS-ROW WS-CODE WS-SLOT
             IF WS-SLOT > 0
                 CALL "TINT-BANNER-LAYER" USING WS-ORDER WS-DYE WS-ARGB
                 COMPUTE WS-TV(1) = FUNCTION MOD(FUNCTION INTEGER(WS-ARGB / 65536), 256) / 255
                 COMPUTE WS-TV(2) = FUNCTION MOD(FUNCTION INTEGER(WS-ARGB / 256), 256) / 255
                 COMPUTE WS-TV(3) = FUNCTION MOD(WS-ARGB, 256) / 255
                 CALL "SHIELD-MODEL" USING CLIENT-STATE WS-M WS-SLOT WS-TINT L-LIGHT L-MODE WS-ORDER
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM SHIELD-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-SHIELD.
*> USING CLIENT-STATE, M (12 FLOAT-LONG: the pose through the display transform and the recentring of the item), hand (1 main, 2 off), light 0 to 1 (FLOAT-LONG): SHIELD-DRAW of the local
*> player's stack in that hand (PL-SLOT-BN) into the hand mesh.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 3.
 01 WS-N                   BINARY-LONG.
 01 WS-SHIELD.
    05 WS-COUNT            BINARY-LONG.
    05 WS-PAT              BINARY-LONG OCCURS 16 TIMES.
    05 WS-DYES             BINARY-LONG OCCURS 16 TIMES.
    05 WS-BASE             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-HAND                 BINARY-LONG.
 01 L-LIGHT                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-HAND L-LIGHT.
     IF L-HAND = 1
         COMPUTE WS-INDEX = PL-HELD + 1
     ELSE
         MOVE 37 TO WS-INDEX
     END-IF
     MOVE PL-SLOT-BN-COUNT(WS-INDEX) TO WS-COUNT
     MOVE PL-SLOT-BN-BASE(WS-INDEX) TO WS-BASE
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 16
         MOVE PL-SLOT-BN-PAT(WS-INDEX, WS-N) TO WS-PAT(WS-N)
         MOVE PL-SLOT-BN-DYE(WS-INDEX, WS-N) TO WS-DYES(WS-N)
     END-PERFORM
     CALL "SHIELD-DRAW" USING CLIENT-STATE L-M WS-SHIELD L-LIGHT WS-MODE
     GOBACK.
 END PROGRAM HAND-SHIELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SHIELD-SLOT-SET.
*> USING CLIENT-STATE, patterned (BINARY-LONG, 1 when the stack has layers or a base colour), layer count, holders (16 BINARY-LONG), new (BINARY-LONG, set to 1 when a slot's image changed):
*> the entity atlas slots of the sprites of one shield: `shield_base_nopattern` (code 0), and for a patterned one `shield_base` (9000), `base` (9001) and 9000 + the holder of each layer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24) VALUE "shield".
 01 WS-ROW                 BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-PATTERNED            BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-HOLDERS.
    05 L-HOLDER            BINARY-LONG OCCURS 16 TIMES.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-PATTERNED L-COUNT L-HOLDERS L-NEW.
     CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-ROW
     IF WS-ROW > 0
         IF L-PATTERNED = 0
             MOVE 0 TO WS-CODE
             CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
         ELSE
             MOVE 9000 TO WS-CODE
             CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
             MOVE 9001 TO WS-CODE
             CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > L-COUNT OR WS-N > 16
                 IF L-HOLDER(WS-N) >= 1 AND L-HOLDER(WS-N) <= 43
                     COMPUTE WS-CODE = 9000 + L-HOLDER(WS-N)
                     CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SHIELD-SLOT-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-SHIELD-SLOTS.
*> USING CLIENT-STATE, new (BINARY-LONG, set to 1 when a slot's image changed): the entity atlas slots of the shields in the local player's hands (the main hand's slot, the off hand's).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HAND                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-PATTERNED           BINARY-LONG.
 01 WS-HOLDERS.
    05 WS-HOLDER           BINARY-LONG OCCURS 16 TIMES.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NEW.
     PERFORM VARYING WS-HAND FROM 1 BY 1 UNTIL WS-HAND > 2
         MOVE 0 TO WS-FLAG
         IF WS-HAND = 1 AND CL-HAND-ITEM > 0
             COMPUTE WS-ITEM = CL-HAND-ITEM - 1
             CALL "SHIELD-ITEM" USING CLIENT-STATE WS-ITEM WS-FLAG
             COMPUTE WS-INDEX = PL-HELD + 1
         END-IF
         IF WS-HAND = 2 AND CL-OHAND-ITEM > 0
             COMPUTE WS-ITEM = CL-OHAND-ITEM - 1
             CALL "SHIELD-ITEM" USING CLIENT-STATE WS-ITEM WS-FLAG
             MOVE 37 TO WS-INDEX
         END-IF
         IF WS-FLAG = 1
             MOVE 0 TO WS-PATTERNED
             IF PL-SLOT-BN-COUNT(WS-INDEX) > 0 OR PL-SLOT-BN-BASE(WS-INDEX) > 0
                 MOVE 1 TO WS-PATTERNED
             END-IF
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 16
                 MOVE PL-SLOT-BN-PAT(WS-INDEX, WS-N) TO WS-HOLDER(WS-N)
             END-PERFORM
             CALL "SHIELD-SLOT-SET" USING CLIENT-STATE WS-PATTERNED PL-SLOT-BN-COUNT(WS-INDEX) WS-HOLDERS L-NEW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-SHIELD-SLOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SHIELD-SLOTS.
*> USING CLIENT-STATE, replica row, new (BINARY-LONG, set to 1 when a slot's image changed): the entity atlas slots of the sprites of the shields a mob or a player holds (EN-EQ slot 1 main hand,
*> 2 off hand; the layers of EN-HB).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-PATTERNED           BINARY-LONG.
 01 WS-HOLDERS.
    05 WS-HOLDER           BINARY-LONG OCCURS 16 TIMES.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-NEW.
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 2
         MOVE 0 TO WS-FLAG
         IF EN-EQ(L-ROW, WS-SLOT) > 0
             CALL "SHIELD-ITEM" USING CLIENT-STATE EN-EQ(L-ROW, WS-SLOT) WS-FLAG
         END-IF
         IF WS-FLAG = 1
             MOVE 0 TO WS-PATTERNED
             IF EN-HB-COUNT(L-ROW, WS-SLOT) > 0 OR EN-HB-BASE(L-ROW, WS-SLOT) >= 0
                 MOVE 1 TO WS-PATTERNED
             END-IF
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 16
                 MOVE EN-HB-PAT(L-ROW, WS-SLOT, WS-N) TO WS-HOLDER(WS-N)
             END-PERFORM
             CALL "SHIELD-SLOT-SET" USING CLIENT-STATE WS-PATTERNED EN-HB-COUNT(L-ROW, WS-SLOT) WS-HOLDERS L-NEW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-SHIELD-SLOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-SHIELD-HELD.
*> USING CLIENT-STATE, placement (12 FLOAT-LONG: the arm's frame turned and translated as for any held item), replica row, hand (1 right arm, 2 left arm), eye (3 FLOAT-LONG): a shield in the
*> hand of a mob or a player (12 section 6.12, third person): the display transform of the item model for thirdperson_righthand or thirdperson_lefthand, the left arm's entry mirrored once
*> more (translation x, rotation y and z negated), then SHIELD-DRAW into the entity mesh. Not blocking: rotation (0, 90, 0), translation (10, 6, -4) right and (10, 6, 12) left; blocking (the
*> hand uses the item, EN-LIVING bit 0 with the hand bit 1): rotation (45, 155, 0), translation (-3.49, 11, -2) right and (11.51, 7, 2.5) left; scale 1; then the recentring.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-DEG                 FLOAT-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 5.
 01 WS-LIGHT               FLOAT-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-BLOCKING            BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-SHIELD.
    05 WS-COUNT            BINARY-LONG.
    05 WS-PAT              BINARY-LONG OCCURS 16 TIMES.
    05 WS-DYES             BINARY-LONG OCCURS 16 TIMES.
    05 WS-BASE             BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-ROW                  BINARY-LONG.
 01 L-HAND                 BINARY-LONG.
 01 L-EYE-TABLE.
    05 L-EYE               FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-ROW L-HAND L-EYE-TABLE.
*>   The hand's stack: the main hand is the right arm unless the mob is left-handed (mob flags bit 2).
     MOVE L-HAND TO WS-SLOT
     IF FUNCTION MOD(FUNCTION INTEGER(EN-MOB-FLAGS(L-ROW) / 2), 2) = 1
         COMPUTE WS-SLOT = 3 - L-HAND
     END-IF
     CALL "ENTITY-BLOCKING" USING CLIENT-STATE L-ROW WS-SLOT WS-BLOCKING
     MOVE 1 TO WS-SIDE
     IF L-HAND = 2
         MOVE -1 TO WS-SIDE
     END-IF
     MOVE L-M TO WS-M
*>   The display transform of the item model: translate, rotate X, Y, Z, scale 1, translate (-0.5).
     IF WS-BLOCKING = 0
         COMPUTE WS-AX = 10 * WS-SIDE / 16
         COMPUTE WS-AY = 6 / 16
         IF L-HAND = 1
             COMPUTE WS-AZ = -4 / 16
         ELSE
             COMPUTE WS-AZ = 12 / 16
         END-IF
     ELSE
         IF L-HAND = 1
             COMPUTE WS-AX = -3.49 / 16
             COMPUTE WS-AY = 11 / 16
             COMPUTE WS-AZ = -2 / 16
         ELSE
             COMPUTE WS-AX = -11.51 / 16
             COMPUTE WS-AY = 7 / 16
             COMPUTE WS-AZ = 2.5 / 16
         END-IF
     END-IF
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
     IF WS-BLOCKING = 1
         MOVE 1 TO WS-AXIS
         MOVE 45 TO WS-DEG
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
         MOVE 2 TO WS-AXIS
         COMPUTE WS-DEG = 155 * WS-SIDE
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     ELSE
         MOVE 2 TO WS-AXIS
         COMPUTE WS-DEG = 90 * WS-SIDE
         CALL "HAND-M-ROTATE" USING WS-M WS-AXIS WS-DEG
     END-IF
     MOVE -0.5 TO WS-AX WS-AY WS-AZ
     CALL "HAND-M-TRANSLATE" USING WS-M WS-AX WS-AY WS-AZ
     MOVE EN-HB-COUNT(L-ROW, WS-SLOT) TO WS-COUNT
     COMPUTE WS-BASE = EN-HB-BASE(L-ROW, WS-SLOT) + 1
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 16
         MOVE EN-HB-PAT(L-ROW, WS-SLOT, WS-N) TO WS-PAT(WS-N)
         MOVE EN-HB-DYE(L-ROW, WS-SLOT, WS-N) TO WS-DYES(WS-N)
     END-PERFORM
     COMPUTE WS-CX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-CY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-CELL" USING CLIENT-STATE WS-CX WS-CY WS-CZ WS-STATE WS-SKY WS-BLK
     COMPUTE WS-LIGHT = FUNCTION MAX(FUNCTION MAX(WS-SKY * SK-U / 1000, WS-BLK) / 15, 0.1)
     CALL "SHIELD-DRAW" USING CLIENT-STATE WS-M WS-SHIELD WS-LIGHT WS-MODE
     GOBACK.
 END PROGRAM ENTITY-SHIELD-HELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BLOCKING.
*> USING CLIENT-STATE, replica row, hand slot (1 main, 2 off), flag out: 1 when the entity is blocking with the item in that hand: its living entity flags (EN-LIVING, entry 8) say it uses an item
*> (bit 0) with that hand (bit 1: 0 main, 1 off) and the item is a shield (the `block` use animation of a shield, 12 section 7.5 and 6.12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SHIELD              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-SLOT L-FLAG.
     MOVE 0 TO L-FLAG
     IF FUNCTION MOD(EN-LIVING(L-ROW), 2) = 1 AND FUNCTION MOD(FUNCTION INTEGER(EN-LIVING(L-ROW) / 2), 2) = L-SLOT - 1
             AND EN-EQ(L-ROW, L-SLOT) > 0
         CALL "SHIELD-ITEM" USING CLIENT-STATE EN-EQ(L-ROW, L-SLOT) WS-SHIELD
         MOVE WS-SHIELD TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM ENTITY-BLOCKING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HELD-ENTITY-PASS.
*> USING CLIENT-STATE, item id, flag out: 1 for an item that a mob or a player holds and that the entity pass draws as a model of its own (a banner, a shield), else 0 (the ground item pass draws it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DYE                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-FLAG.
     CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE L-ITEM WS-DYE
     MOVE 0 TO L-FLAG
     IF WS-DYE >= 0
         MOVE 1 TO L-FLAG
     ELSE
         CALL "SHIELD-ITEM" USING CLIENT-STATE L-ITEM L-FLAG
     END-IF
     GOBACK.
 END PROGRAM HELD-ENTITY-PASS.
