*> A banner item held in first person (54 section 22.3 for the layers, 52 section 6 for the model and the item form). STACK-BANNER keeps banner_patterns (74) of a stack (PL-STACK-BN, then
*> PL-SLOT-BN of its slot). HAND-BANNER-COLOUR names the dye of a `<colour>_banner` item (-1 for any other item), BANNER-PATTERN-NAME the pattern of a holder (the 43 ids of 31-3 section 3 in the
*> order the registry loader gives them, sorted by identifier: the holder value is the position + 1). HAND-BANNER-SLOTS gives the sprites a held banner draws their slots of the entity atlas
*> (`banner_base` for the pole, the bar and the unpatterned flag; the base layer's `base` and each pattern's sprite under the code 9000 + the holder). HAND-BANNER draws the model of 52 section 6.4
*> through HAND-CUBOID: M x translate (0.5, 0, 0.5) x scale (2/3, -2/3, -2/3), the pole and the bar of the standing banner and the flag (pivot (0, -44, 0), turned about X by -0.0025 pi, the item's
*> phase 0), the flag once more for the base colour (the sprite `base`, tinted by the dye's diffuse colour, order 1) and once for each of the first 16 patterns (order 2 on, tinted by the
*> layer's dye; TINT-BANNER-LAYER); a layer lies 0.05 pixel nearer the viewer than the one before it, which the opaque pipeline needs to show them in order. A layer of an inline pattern is not drawn.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STACK-BANNER.
*> USING PB-ITEMSTACK-X, banner record out (PL-STACK-BN: the layer count, 16 pattern holders, 16 dye ids): banner_patterns 74 of the stack: a VarInt count, then per layer the holder (a VarInt: 0 and two
*> Strings for an inline pattern, else the registry position + 1) and the dye id (a VarInt). At most 16 layers are kept; a count of 128 or more (a two-byte VarInt) reads as 16 layers that are not walked
*> (no holder), none for a stack without the component.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-BANNER.
    05 L-COUNT             BINARY-LONG.
    05 L-PAT               BINARY-LONG OCCURS 16 TIMES.
    05 L-DYE               BINARY-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PB-ITEMSTACK-X L-BANNER.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > PB-ISX-ADDED-COUNT
         IF PB-ISX-TYPE(WS-K) = 74 AND PB-ISX-VALUE-LENGTH(WS-K) > 0
             MOVE PB-ISX-VALUE-LENGTH(WS-K) TO WS-LEN
             COMPUTE WS-COUNT = FUNCTION ORD(PB-ISX-VALUE(WS-K)(1:1)) - 1
             MOVE 2 TO WS-P
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-COUNT OR WS-N > 16 OR WS-P > WS-LEN OR WS-COUNT >= 128
                 COMPUTE WS-B = FUNCTION ORD(PB-ISX-VALUE(WS-K)(WS-P:1)) - 1
                 ADD 1 TO WS-P
                 MOVE WS-B TO L-PAT(WS-N)
                 IF WS-B = 0
*>                   An inline pattern: two Strings (a one-byte length each), skipped.
                     PERFORM 2 TIMES
                         IF WS-P <= WS-LEN
                             COMPUTE WS-L = FUNCTION ORD(PB-ISX-VALUE(WS-K)(WS-P:1)) - 1
                             COMPUTE WS-P = WS-P + 1 + WS-L
                         END-IF
                     END-PERFORM
                 END-IF
                 IF WS-P <= WS-LEN
                     COMPUTE L-DYE(WS-N) = FUNCTION ORD(PB-ISX-VALUE(WS-K)(WS-P:1)) - 1
                     ADD 1 TO WS-P
                     ADD 1 TO L-COUNT
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STACK-BANNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-BANNER-COLOUR.
*> USING CLIENT-STATE, item id, dye out (the dye id 0 to 15 of a `<colour>_banner` item, 43 section 8 order; -1 for any other item, a wall banner and an unknown id).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NS                  PIC X(16).
 01 WS-PATH                PIC X(40).
 01 WS-MAX                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TOOL                PIC X.
 01 WS-FOOD                BINARY-LONG.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-NAMES-DATA.
    05 FILLER PIC X(96) VALUE "white       orange      magenta     light_blue  yellow      lime        pink        gray        ".
    05 FILLER PIC X(96) VALUE "light_gray  cyan        purple      blue        brown       green       red         black       ".
 01 WS-NAMES REDEFINES WS-NAMES-DATA.
    05 WS-NAME             PIC X(12) OCCURS 16 TIMES.
 01 WS-COLOUR              PIC X(40).
 01 WS-REST                PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-DYE.
     MOVE -1 TO L-DYE
     IF L-ITEM >= 0
         CALL "CL-ITEM-INFO" USING CLIENT-STATE L-ITEM WS-NS WS-PATH WS-MAX WS-BLOCK WS-TOOL WS-FOOD WS-KNOWN
         IF WS-KNOWN = 1 AND WS-NS = "minecraft"
             MOVE SPACES TO WS-COLOUR WS-REST
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-POS
             IF WS-POS > 7
                 IF WS-PATH(WS-POS - 6:7) = "_banner"
                     MOVE WS-PATH(1:WS-POS - 7) TO WS-COLOUR
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
                         IF WS-NAME(WS-I) = WS-COLOUR
                             COMPUTE L-DYE = WS-I - 1
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM HAND-BANNER-COLOUR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BANNER-PATTERN-NAME.
*> USING holder (1 to 43: the registry position + 1), name out (PIC X(24), spaces for a holder outside 1 to 43): the pattern id of 31-3 section 3, `base` the first.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES-DATA.
    05 FILLER PIC X(240) VALUE "base                    border                  bricks                  circle                  creeper                 cross                   curly_border            diagonal_left           diagonal_right          diagonal_up_left        ".
    05 FILLER PIC X(240) VALUE "diagonal_up_right       flow                    flower                  globe                   gradient                gradient_up             guster                  half_horizontal         half_horizontal_bottom  half_vertical           ".
    05 FILLER PIC X(240) VALUE "half_vertical_right     mojang                  piglin                  rhombus                 skull                   small_stripes           square_bottom_left      square_bottom_right     square_top_left         square_top_right        ".
    05 FILLER PIC X(240) VALUE "straight_cross          stripe_bottom           stripe_center           stripe_downleft         stripe_downright        stripe_left             stripe_middle           stripe_right            stripe_top              triangle_bottom         ".
    05 FILLER PIC X(72) VALUE "triangle_top            triangles_bottom        triangles_top           ".
 01 WS-NAMES REDEFINES WS-NAMES-DATA.
    05 WS-NAME             PIC X(24) OCCURS 43 TIMES.
 LINKAGE SECTION.
 01 L-HOLDER               BINARY-LONG.
 01 L-NAME                 PIC X(24).
 PROCEDURE DIVISION USING L-HOLDER L-NAME.
     MOVE SPACES TO L-NAME
     IF L-HOLDER >= 1 AND L-HOLDER <= 43
         MOVE WS-NAME(L-HOLDER) TO L-NAME
     END-IF
     GOBACK.
 END PROGRAM BANNER-PATTERN-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-BANNER-SLOTS.
*> USING CLIENT-STATE, new (BINARY-LONG, set to 1 when a slot's image changed): the entity atlas slots of the sprites the banners in the hands draw: the model row `banner` with the code 0 (`banner_base`),
*> the code 9001 (`base`, the flag's base colour) and 9000 + the holder of each pattern layer of the held stacks (the main hand's slot, the off hand's), for a hand whose shown item is a banner.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24) VALUE "banner".
 01 WS-ROW                 BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-HAND                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NEW.
     CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-ROW
     PERFORM VARYING WS-HAND FROM 1 BY 1 UNTIL WS-HAND > 2
         MOVE -1 TO WS-DYE
         IF WS-HAND = 1 AND CL-HAND-ITEM > 0
             COMPUTE WS-ITEM = CL-HAND-ITEM - 1
             CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE WS-ITEM WS-DYE
             COMPUTE WS-INDEX = PL-HELD + 1
         END-IF
         IF WS-HAND = 2 AND CL-OHAND-ITEM > 0
             COMPUTE WS-ITEM = CL-OHAND-ITEM - 1
             CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE WS-ITEM WS-DYE
             MOVE 37 TO WS-INDEX
         END-IF
         IF WS-DYE >= 0 AND WS-ROW > 0
             MOVE 0 TO WS-CODE
             CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
             MOVE 9001 TO WS-CODE
             CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > PL-SLOT-BN-COUNT(WS-INDEX)
                 IF PL-SLOT-BN-PAT(WS-INDEX, WS-N) >= 1 AND PL-SLOT-BN-PAT(WS-INDEX, WS-N) <= 43
                     COMPUTE WS-CODE = 9000 + PL-SLOT-BN-PAT(WS-INDEX, WS-N)
                     CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM HAND-BANNER-SLOTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. HAND-BANNER.
*> USING CLIENT-STATE, M (12 FLOAT-LONG: the pose through the display transform and the recentring of the item), hand (1 main, 2 off), dye of the banner's colour, light 0 to 1 (FLOAT-LONG):
*> BANNER-DRAW of the local player's stack in that hand (PL-SLOT-BN) into the hand mesh.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE 3.
 01 WS-N                   BINARY-LONG.
 01 WS-BANNER.
    05 WS-COUNT            BINARY-LONG.
    05 WS-PAT              BINARY-LONG OCCURS 16 TIMES.
    05 WS-DYES             BINARY-LONG OCCURS 16 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-HAND                 BINARY-LONG.
 01 L-DYE                  BINARY-LONG.
 01 L-LIGHT                FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-HAND L-DYE L-LIGHT.
     IF L-HAND = 1
         COMPUTE WS-INDEX = PL-HELD + 1
     ELSE
         MOVE 37 TO WS-INDEX
     END-IF
     MOVE PL-SLOT-BN-COUNT(WS-INDEX) TO WS-COUNT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 16
         MOVE PL-SLOT-BN-PAT(WS-INDEX, WS-N) TO WS-PAT(WS-N)
         MOVE PL-SLOT-BN-DYE(WS-INDEX, WS-N) TO WS-DYES(WS-N)
     END-PERFORM
     CALL "BANNER-DRAW" USING CLIENT-STATE L-M WS-BANNER L-DYE L-LIGHT WS-MODE
     GOBACK.
 END PROGRAM HAND-BANNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BANNER-DRAW.
*> USING CLIENT-STATE, M (12 FLOAT-LONG: the pose through the display transform and the recentring of the item), layers (BINARY-LONG count, 16 holders, 16 dyes), dye of the banner's colour, light 0 to 1
*> (FLOAT-LONG), mode (3 the hand mesh, 4 the ground item mesh): the banner's pole, bar, flag and layers (52 section 6.4, 54 section 22.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24) VALUE "banner".
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-SLOT-BASE           BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ORDER               BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-ARGB                BINARY-DOUBLE.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-M.
    05 WS-MV               FLOAT-LONG OCCURS 12 TIMES.
 01 WS-GEOM.
    05 WS-GV               FLOAT-LONG OCCURS 15 TIMES.
 01 WS-TINT.
    05 WS-TV               FLOAT-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-M.
    05 L-MV                FLOAT-LONG OCCURS 12 TIMES.
 01 L-BANNER.
    05 L-COUNT             BINARY-LONG.
    05 L-PAT               BINARY-LONG OCCURS 16 TIMES.
    05 L-DYES              BINARY-LONG OCCURS 16 TIMES.
 01 L-DYE                  BINARY-LONG.
 01 L-LIGHT                FLOAT-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-M L-BANNER L-DYE L-LIGHT L-MODE.
     CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-ROW
     MOVE 0 TO WS-SLOT-BASE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EA-MT-COUNT
         IF EA-MT-MODEL(WS-K) = WS-ROW AND EA-MT-TEX(WS-K) = 0
             MOVE WS-K TO WS-SLOT-BASE
         END-IF
     END-PERFORM
     IF WS-SLOT-BASE = 0 OR EA-W = 0 OR EA-H = 0
         GOBACK
     END-IF
*>   The local transform of the banner: translate (0.5, 0, 0.5), scale (2/3, -2/3, -2/3).
     MOVE L-M TO WS-M
     MOVE 0.5 TO WS-X
     MOVE 0 TO WS-Y
     MOVE 0.5 TO WS-Z
     CALL "HAND-M-TRANSLATE" USING WS-M WS-X WS-Y WS-Z
     COMPUTE WS-X = 2 / 3
     COMPUTE WS-Y = -2 / 3
     MOVE WS-Y TO WS-Z
     CALL "HAND-M-SCALE" USING WS-M WS-X WS-Y WS-Z
     MOVE 1 TO WS-TV(1) WS-TV(2) WS-TV(3)
     MOVE 0 TO WS-GV(4)
     MOVE 64 TO WS-GV(14) WS-GV(15)
     MOVE 0 TO WS-GV(13)
*>   The pole (tex 44, 0; origin -1 -42 -1; 2 x 42 x 2) and the bar (tex 0, 42; origin -10 -44 -1; 20 x 2 x 2): the pivot (0, 0, 0).
     MOVE 0 TO WS-GV(1) WS-GV(2) WS-GV(3)
     MOVE -1 TO WS-GV(5) WS-GV(7)
     MOVE -42 TO WS-GV(6)
     MOVE 2 TO WS-GV(8) WS-GV(10)
     MOVE 42 TO WS-GV(9)
     MOVE 44 TO WS-GV(11)
     MOVE 0 TO WS-GV(12)
     CALL "HAND-CUBOID-MODE" USING CLIENT-STATE WS-M WS-SLOT-BASE WS-GEOM WS-TINT L-LIGHT L-MODE
     MOVE -10 TO WS-GV(5)
     MOVE -44 TO WS-GV(6)
     MOVE -1 TO WS-GV(7)
     MOVE 20 TO WS-GV(8)
     MOVE 2 TO WS-GV(9) WS-GV(10)
     MOVE 0 TO WS-GV(11)
     MOVE 42 TO WS-GV(12)
     CALL "HAND-CUBOID-MODE" USING CLIENT-STATE WS-M WS-SLOT-BASE WS-GEOM WS-TINT L-LIGHT L-MODE
*>   The flag (pivot (0, -44, 0), turned about X by -0.0025 pi; tex 0, 0; origin -10 0 -2; 20 x 40 x 1): with the banner sprite, then the layers.
     MOVE -44 TO WS-GV(2)
     COMPUTE WS-GV(4) = -0.0025 * FUNCTION PI
     MOVE -10 TO WS-GV(5)
     MOVE 0 TO WS-GV(6)
     MOVE -2 TO WS-GV(7)
     MOVE 20 TO WS-GV(8)
     MOVE 40 TO WS-GV(9)
     MOVE 1 TO WS-GV(10)
     MOVE 0 TO WS-GV(11) WS-GV(12)
     CALL "HAND-CUBOID-MODE" USING CLIENT-STATE WS-M WS-SLOT-BASE WS-GEOM WS-TINT L-LIGHT L-MODE
*>   The base colour layer (the sprite `base`, order 1), then each pattern (order 2 on, its dye); a layer 0.05 pixel nearer the viewer than the one before.
     PERFORM VARYING WS-N FROM 0 BY 1 UNTIL WS-N > L-COUNT OR WS-N > 16
         IF WS-N = 0
             MOVE 9001 TO WS-CODE
             MOVE L-DYE TO WS-DYE
             MOVE 1 TO WS-ORDER
         ELSE
             COMPUTE WS-CODE = 9000 + L-PAT(WS-N)
             MOVE L-DYES(WS-N) TO WS-DYE
             COMPUTE WS-ORDER = WS-N + 1
         END-IF
         MOVE 0 TO WS-SLOT
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EA-MT-COUNT
             IF EA-MT-MODEL(WS-K) = WS-ROW AND EA-MT-TEX(WS-K) = WS-CODE
                 MOVE WS-K TO WS-SLOT
             END-IF
         END-PERFORM
         IF WS-SLOT > 0
             CALL "TINT-BANNER-LAYER" USING WS-ORDER WS-DYE WS-ARGB
             COMPUTE WS-TV(1) = FUNCTION MOD(FUNCTION INTEGER(WS-ARGB / 65536), 256) / 255
             COMPUTE WS-TV(2) = FUNCTION MOD(FUNCTION INTEGER(WS-ARGB / 256), 256) / 255
             COMPUTE WS-TV(3) = FUNCTION MOD(WS-ARGB, 256) / 255
             COMPUTE WS-GV(7) = -2 - 0.05 * WS-ORDER
             CALL "HAND-CUBOID-MODE" USING CLIENT-STATE WS-M WS-SLOT WS-GEOM WS-TINT L-LIGHT L-MODE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BANNER-DRAW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-BANNER-SLOTS.
*> USING CLIENT-STATE, replica row, new (BINARY-LONG, set to 1 when a slot's image changed): the entity atlas slots of the sprites of the banners a mob holds (HAND-BANNER-SLOTS for the local
*> player): for each hand slot (1 main, 2 off) whose item is a banner `banner_base` (code 0), `base` (9001) and 9000 + the holder of each of the layers of EN-HB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24) VALUE "banner".
 01 WS-ROW                 BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-DYE                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW L-NEW.
     CALL "ENTITY-MODEL-FIND" USING WS-KEY WS-ROW
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 2
         MOVE -1 TO WS-DYE
         IF EN-EQ(L-ROW, WS-SLOT) > 0
             CALL "HAND-BANNER-COLOUR" USING CLIENT-STATE EN-EQ(L-ROW, WS-SLOT) WS-DYE
         END-IF
         IF WS-DYE >= 0 AND WS-ROW > 0
             MOVE 0 TO WS-CODE
             CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
             MOVE 9001 TO WS-CODE
             CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-HB-COUNT(L-ROW, WS-SLOT)
                 IF EN-HB-PAT(L-ROW, WS-SLOT, WS-N) >= 1 AND EN-HB-PAT(L-ROW, WS-SLOT, WS-N) <= 43
                     COMPUTE WS-CODE = 9000 + EN-HB-PAT(L-ROW, WS-SLOT, WS-N)
                     CALL "ENTITY-SLOT-ENSURE" USING CLIENT-STATE WS-ROW WS-CODE L-NEW
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ENTITY-BANNER-SLOTS.
