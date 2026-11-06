*> The built-in pack `cobolcraft` (docs/protocol/08-resource-packs.md §10), served from memory:
*> BUILTIN-PATH lists its files, BUILTIN-READ serves its JSON files (pack.mcmeta §10.1, the atlas
*> definitions §10.2, the template and block models §10.4, §10.5, the block state files §10.6, the
*> item models and item definitions §10.7, font/default.json §10.10, lang/en_us.json §10.8),
*> BUILTIN-IMAGE its textures as RGBA, drawn by BUILTIN-TEXTURE from the recipes of
*> standin-content §1.4 (with the integer hash H of §1.4.1), the item icons of §2 (TEX-ICON with
*> the §1.4.1 rectangles, lines and triangles), §3.2 and the glyphs of §18. Texts: CLLANG.cpy;
*> glyphs: CLGLYPHS.cpy.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-PATH.
*> USING index (1-based), path out (PIC X(256)), path length out, found out (0 past the last file).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLBUILTIN.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-PATH L-LENGTH L-FOUND.
     MOVE 0 TO L-FOUND L-LENGTH
     MOVE SPACES TO L-PATH
     IF L-INDEX >= 1 AND L-INDEX <= BI-FILE-COUNT
         MOVE 1 TO L-FOUND
         MOVE BI-FILE(L-INDEX) TO L-PATH
         MOVE FUNCTION LENGTH(FUNCTION TRIM(BI-FILE(L-INDEX))) TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM BUILTIN-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-FIND.
*> USING path (PIC X(256)), path length, file index out (0 = the pack has no such file).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLBUILTIN.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-LENGTH L-INDEX.
     MOVE 0 TO L-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BI-FILE-COUNT OR L-INDEX > 0
         IF BI-FILE(WS-I) = L-PATH(1:L-LENGTH) AND L-LENGTH <= 64
             MOVE WS-I TO L-INDEX
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BUILTIN-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-READ.
*> USING path (PIC X(256)), path length, area, capacity, length out, found out: the file's JSON
*> text (at most the capacity). Texture paths and unknown paths: not found.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLBUILTIN.
 COPY CLLANG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-TEXT                PIC X(32768).
 01 WS-Q                   PIC X VALUE X"22".
 01 WS-BS                  PIC X VALUE X"5C".
 01 WS-DIRS.
    05 FILLER PIC X(6) VALUE "down".
    05 FILLER PIC X(6) VALUE "up".
    05 FILLER PIC X(6) VALUE "north".
    05 FILLER PIC X(6) VALUE "south".
    05 FILLER PIC X(6) VALUE "west".
    05 FILLER PIC X(6) VALUE "east".
 01 WS-DIR-TABLE REDEFINES WS-DIRS.
    05 WS-DIR              PIC X(6) OCCURS 6 TIMES.
 01 B-AREA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-OUT-LENGTH           BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-LENGTH L-AREA L-CAPACITY L-OUT-LENGTH L-FOUND.
     SET ADDRESS OF B-AREA TO ADDRESS OF L-AREA
     CALL "BUILTIN-FIND" USING L-PATH L-LENGTH WS-INDEX
     MOVE 1 TO WS-PTR
     MOVE 1 TO L-FOUND
     EVALUATE TRUE
         WHEN WS-INDEX = 1
             STRING '{"pack":{"description":"CobolCraft stand-in default pack",'
                 '"min_format":97,"max_format":97}}' DELIMITED BY SIZE
                 INTO WS-TEXT WITH POINTER WS-PTR
         WHEN WS-INDEX = 2
             STRING '{"sources":[{"type":"directory","source":"block","prefix":"block/"}]}'
                 DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN WS-INDEX = 3
             STRING '{"sources":[{"type":"directory","source":"item","prefix":"item/"}]}'
                 DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN WS-INDEX = BI-TEMPLATE-BOX
*>           template_box (§10.4): a full cube, every face its own slot and cullface.
             STRING '{"textures":{"particle":"#north"},"elements":[{"from":[0,0,0],'
                 '"to":[16,16,16],"faces":{' DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 IF WS-I > 1
                     STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
                 END-IF
                 STRING WS-Q FUNCTION TRIM(WS-DIR(WS-I)) '":{"texture":"#'
                     FUNCTION TRIM(WS-DIR(WS-I)) '","cullface":"' FUNCTION TRIM(WS-DIR(WS-I))
                     '"}' DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-PERFORM
             STRING "}}]}" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN WS-INDEX > BI-TEMPLATE-BOX AND WS-INDEX <= BI-LAST-MODEL
*>           The other templates and the block models: a parent and a textures map.
             STRING '{"parent":"cobolcraft:block/' FUNCTION TRIM(BI-PARENT(WS-INDEX))
                 '","textures":{' FUNCTION TRIM(BI-CONTENT(WS-INDEX)) "}}"
                 DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN WS-INDEX > BI-LAST-MODEL AND WS-INDEX <= BI-LAST-STATE
             STRING '{"variants":{' FUNCTION TRIM(BI-CONTENT(WS-INDEX)) "}}"
                 DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN WS-INDEX > BI-LAST-STATE AND WS-INDEX <= BI-LAST-ITEM-MODEL
*>           An item model (§10.7): the generated model with one layer0 sprite.
             STRING '{"parent":"minecraft:builtin/generated","textures":{"layer0":"'
                 FUNCTION TRIM(BI-CONTENT(WS-INDEX)) '"}}'
                 DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN WS-INDEX > BI-LAST-ITEM-MODEL AND WS-INDEX <= BI-LAST-ITEM-DEF
*>           An item definition (§10.7): a minecraft:model naming the item model.
             STRING '{"model":{"type":"minecraft:model","model":"'
                 FUNCTION TRIM(BI-CONTENT(WS-INDEX)) '"}}'
                 DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN WS-INDEX = BI-FONT
*>           font/default.json (§10.10): one bitmap provider; the chars rows with their escapes.
             STRING '{"providers":[{"type":"bitmap","file":"cobolcraft:font/ascii.png",'
                 '"height":8,"ascent":7,"chars":["' " !" WS-BS WS-Q "#$%&'()*+,-./" WS-Q ","
                 WS-Q "0123456789:;<=>?" WS-Q "," WS-Q "@ABCDEFGHIJKLMNO" WS-Q ","
                 WS-Q "PQRSTUVWXYZ[" WS-BS WS-BS "]^_" WS-Q "," WS-Q "`abcdefghijklmno" WS-Q ","
                 WS-Q "pqrstuvwxyz{|}~" WS-BS "u0000" WS-Q "]}]}"
                 DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN WS-INDEX = BI-LANG-FILE
*>           lang/en_us.json (§10.8): one object of every key.
             STRING "{" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BI-LANG-COUNT
                 IF WS-I > 1
                     STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
                 END-IF
                 STRING WS-Q FUNCTION TRIM(BI-LANG-KEY(WS-I)) WS-Q ":" WS-Q
                     FUNCTION TRIM(BI-LANG-TEXT(WS-I) TRAILING) WS-Q
                     DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-PERFORM
             STRING "}" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         WHEN OTHER
             MOVE 0 TO L-FOUND
     END-EVALUATE
     COMPUTE L-OUT-LENGTH = FUNCTION MIN(WS-PTR - 1, L-CAPACITY)
     IF L-OUT-LENGTH > 0
         MOVE WS-TEXT(1:L-OUT-LENGTH) TO B-AREA(1:L-OUT-LENGTH)
     END-IF
     GOBACK.
 END PROGRAM BUILTIN-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-IMAGE.
*> USING path (PIC X(256)), path length, area, capacity, width out, height out, found out: the
*> texture of a textures/... path as RGBA (rows top to bottom), drawn by BUILTIN-TEXTURE. A path
*> that is no texture of the pack, or an image larger than the capacity: not found.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLBUILTIN.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STEM                PIC X(32).
 01 WS-IMAGE               PIC X(24576).
 01 WS-BYTES               BINARY-LONG.
 01 B-AREA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-LENGTH L-AREA L-CAPACITY L-W L-H L-FOUND.
     SET ADDRESS OF B-AREA TO ADDRESS OF L-AREA
     CALL "BUILTIN-FIND" USING L-PATH L-LENGTH WS-INDEX
     MOVE 0 TO L-FOUND L-W L-H
     IF WS-INDEX >= BI-FIRST-TEXTURE AND WS-INDEX <= BI-LAST-TEXTURE
*>       The stem is the file name between the last "/" and ".png".
         MOVE SPACES TO WS-STEM
         MOVE BI-CONTENT(WS-INDEX) TO WS-STEM
         CALL "BUILTIN-TEXTURE" USING WS-STEM WS-IMAGE L-W L-H
         COMPUTE WS-BYTES = L-W * L-H * 4
         IF WS-BYTES <= L-CAPACITY
             MOVE 1 TO L-FOUND
             MOVE WS-IMAGE(1:WS-BYTES) TO B-AREA(1:WS-BYTES)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM BUILTIN-IMAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-TEXTURE.
*> USING stem (PIC X(32)), RGBA out (PIC X(24576)), width out, height out: the texture with that
*> file stem (08 §10.3): the 15 block textures of standin-content §1.4.2 and the 6 item icons of §2
*> (16 x 16), the operator entity texture of §3.2 (66 x 28) and the font atlas "ascii" of §18
*> (128 x 48).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLGLYPHS.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 01 WS-BORDER              PIC X(4).
 01 WS-BAR                 PIC X(4).
 01 WS-FILL                PIC X(4).
 01 WS-NAME                PIC X(32).
 01 WS-LOAM                PIC X(1024).
 01 WS-TURF                PIC X(1024).
 01 WS-INK                 PIC X(4).
 01 WS-HEX                 PIC X(2).
 LINKAGE SECTION.
 01 L-STEM                 PIC X(32).
 01 L-RGBA                 PIC X(24576).
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-STEM L-RGBA L-W L-H.
     MOVE 16 TO L-W L-H
     MOVE LOW-VALUES TO L-RGBA(1:1024)
     EVALUATE L-STEM
         WHEN "baseplate"
             PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P > 255
                 DIVIDE WS-P BY 16 GIVING WS-Y REMAINDER WS-X
                 MOVE FUNCTION HEX-TO-CHAR("2B2B33FF") TO L-RGBA(WS-P * 4 + 1:4)
                 IF FUNCTION MOD(WS-X, 4) = FUNCTION MOD(WS-Y, 4)
                         OR FUNCTION MOD(WS-X, 4) + FUNCTION MOD(WS-Y, 4) = 3
                     MOVE FUNCTION HEX-TO-CHAR("45454FFF") TO L-RGBA(WS-P * 4 + 1:4)
                 END-IF
             END-PERFORM
         WHEN "greystone"
         WHEN "loam"
         WHEN "turf_top"
         WHEN "grit"
         WHEN "slag"
             CALL "TEX-NOISE" USING L-STEM L-RGBA
         WHEN "turf_side"
             MOVE "turf_top" TO WS-NAME
             CALL "TEX-NOISE" USING WS-NAME WS-TURF
             MOVE "loam" TO WS-NAME
             CALL "TEX-NOISE" USING WS-NAME WS-LOAM
             PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P > 255
                 DIVIDE WS-P BY 16 GIVING WS-Y REMAINDER WS-X
                 MOVE WS-LOAM(WS-P * 4 + 1:4) TO L-RGBA(WS-P * 4 + 1:4)
                 IF WS-Y <= 3 OR (WS-Y = 4 AND FUNCTION MOD(WS-X, 2) = 0)
                     MOVE WS-TURF(WS-P * 4 + 1:4) TO L-RGBA(WS-P * 4 + 1:4)
                 END-IF
             END-PERFORM
         WHEN "cardstack_end"
         WHEN "cardstack_side"
         WHEN "cardstack_side_punched"
             PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P > 255
                 DIVIDE WS-P BY 16 GIVING WS-Y REMAINDER WS-X
                 MOVE FUNCTION HEX-TO-CHAR("EDE6CFFF") TO L-RGBA(WS-P * 4 + 1:4)
                 EVALUATE TRUE
                     WHEN L-STEM = "cardstack_end"
                             AND (WS-X = 0 OR WS-X = 15 OR WS-Y = 0 OR WS-Y = 15)
                         MOVE FUNCTION HEX-TO-CHAR("B9AE8CFF") TO L-RGBA(WS-P * 4 + 1:4)
                     WHEN L-STEM = "cardstack_end"
                         CONTINUE
                     WHEN FUNCTION MOD(WS-Y, 2) = 1
                         MOVE FUNCTION HEX-TO-CHAR("B9AE8CFF") TO L-RGBA(WS-P * 4 + 1:4)
                     WHEN L-STEM = "cardstack_side_punched" AND (WS-Y = 2 OR WS-Y = 10)
                             AND (FUNCTION MOD(WS-X, 4) = 1 OR FUNCTION MOD(WS-X, 4) = 2)
                         MOVE FUNCTION HEX-TO-CHAR("2A2A2AFF") TO L-RGBA(WS-P * 4 + 1:4)
                 END-EVALUATE
             END-PERFORM
         WHEN "lucite"
             PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P > 255
                 DIVIDE WS-P BY 16 GIVING WS-Y REMAINDER WS-X
                 IF WS-X = 0 OR WS-X = 15 OR WS-Y = 0 OR WS-Y = 15
                     MOVE FUNCTION HEX-TO-CHAR("BFE6F299") TO L-RGBA(WS-P * 4 + 1:4)
                 END-IF
                 IF WS-X + WS-Y = 6 AND WS-X >= 2 AND WS-X <= 4
                     MOVE FUNCTION HEX-TO-CHAR("FFFFFFCC") TO L-RGBA(WS-P * 4 + 1:4)
                 END-IF
             END-PERFORM
         WHEN "glowtube_lit"
         WHEN "glowtube_unlit"
             MOVE FUNCTION HEX-TO-CHAR("FFE38AFF") TO WS-FILL
             MOVE FUNCTION HEX-TO-CHAR("FFF6D0FF") TO WS-BAR
             MOVE FUNCTION HEX-TO-CHAR("A08A3CFF") TO WS-BORDER
             IF L-STEM = "glowtube_unlit"
                 MOVE FUNCTION HEX-TO-CHAR("7A6E4AFF") TO WS-FILL
                 MOVE FUNCTION HEX-TO-CHAR("8F8460FF") TO WS-BAR
                 MOVE FUNCTION HEX-TO-CHAR("4E4630FF") TO WS-BORDER
             END-IF
             PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P > 255
                 DIVIDE WS-P BY 16 GIVING WS-Y REMAINDER WS-X
                 EVALUATE TRUE
                     WHEN WS-X = 0 OR WS-X = 15 OR WS-Y = 0 OR WS-Y = 15
                         MOVE WS-BORDER TO L-RGBA(WS-P * 4 + 1:4)
                     WHEN WS-X >= 6 AND WS-X <= 9
                         MOVE WS-BAR TO L-RGBA(WS-P * 4 + 1:4)
                     WHEN OTHER
                         MOVE WS-FILL TO L-RGBA(WS-P * 4 + 1:4)
                 END-EVALUATE
             END-PERFORM
         WHEN "ledger_tile"
             PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P > 255
                 DIVIDE WS-P BY 16 GIVING WS-Y REMAINDER WS-X
                 DIVIDE WS-X BY 4 GIVING WS-C
                 DIVIDE WS-Y BY 4 GIVING WS-R
                 ADD WS-R TO WS-C
                 EVALUATE TRUE
                     WHEN FUNCTION MOD(WS-X, 8) = 0 OR FUNCTION MOD(WS-Y, 8) = 0
                         MOVE FUNCTION HEX-TO-CHAR("24425AFF") TO L-RGBA(WS-P * 4 + 1:4)
                     WHEN FUNCTION MOD(WS-C, 2) = 0
                         MOVE FUNCTION HEX-TO-CHAR("3E6C8FFF") TO L-RGBA(WS-P * 4 + 1:4)
                     WHEN OTHER
                         MOVE FUNCTION HEX-TO-CHAR("355D7BFF") TO L-RGBA(WS-P * 4 + 1:4)
                 END-EVALUATE
             END-PERFORM
         WHEN "goto_pad"
             PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P > 255
                 DIVIDE WS-P BY 16 GIVING WS-Y REMAINDER WS-X
                 COMPUTE WS-R = FUNCTION MIN(WS-X, WS-Y, 15 - WS-X, 15 - WS-Y)
                 EVALUATE TRUE
                     WHEN WS-R = 0
                         MOVE FUNCTION HEX-TO-CHAR("3B2F5CFF") TO L-RGBA(WS-P * 4 + 1:4)
                     WHEN WS-R >= 6
                         MOVE FUNCTION HEX-TO-CHAR("C9B8FFFF") TO L-RGBA(WS-P * 4 + 1:4)
                     WHEN FUNCTION MOD(WS-R, 2) = 1
                         MOVE FUNCTION HEX-TO-CHAR("1F1B2EFF") TO L-RGBA(WS-P * 4 + 1:4)
                     WHEN OTHER
                         MOVE FUNCTION HEX-TO-CHAR("6A4FB3FF") TO L-RGBA(WS-P * 4 + 1:4)
                 END-EVALUATE
             END-PERFORM
         WHEN "pry_bar"
         WHEN "trowel"
         WHEN "grazer_flank"
         WHEN "seared_flank"
         WHEN "sod_cake"
         WHEN "dump_shard"
             CALL "TEX-ICON" USING L-STEM L-RGBA
         WHEN "operator"
*>           §3.2 (strip layout of §3.1, one part 11 x 28 x 11): every face rectangle #3A5A9A
*>           (front, back, left, right x 0 to 43 rows 0 to 27; top and bottom x 44 to 65 rows 0
*>           to 10), the rest transparent; the eyes #F0F0F0 at front (2, 4) to (3, 5) and (7, 4)
*>           to (8, 5).
             MOVE 66 TO L-W
             MOVE 28 TO L-H
             MOVE LOW-VALUES TO L-RGBA
             PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P > 1847
                 DIVIDE WS-P BY 66 GIVING WS-Y REMAINDER WS-X
                 IF WS-X < 44 OR WS-Y < 11
                     MOVE FUNCTION HEX-TO-CHAR("3A5A9AFF") TO L-RGBA(WS-P * 4 + 1:4)
                 END-IF
                 IF WS-Y >= 4 AND WS-Y <= 5
                         AND (WS-X = 2 OR WS-X = 3 OR WS-X = 7 OR WS-X = 8)
                     MOVE FUNCTION HEX-TO-CHAR("F0F0F0FF") TO L-RGBA(WS-P * 4 + 1:4)
                 END-IF
             END-PERFORM
         WHEN "ascii"
*>           §18 atlas: the glyph of code c in the 8 x 8 cell at (((c - 32) mod 16) * 8,
*>           ((c - 32) div 16) * 8); set bits are #FFFFFF, clear bits transparent.
             MOVE 128 TO L-W
             MOVE 48 TO L-H
             MOVE LOW-VALUES TO L-RGBA
             MOVE FUNCTION HEX-TO-CHAR("FFFFFFFF") TO WS-INK
             PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C > 94
                 PERFORM VARYING WS-ROW FROM 0 BY 1 UNTIL WS-ROW > 7
                     MOVE BI-GLYPH(WS-C + 1)(WS-ROW * 2 + 1:2) TO WS-HEX
                     MOVE FUNCTION ORD(FUNCTION HEX-TO-CHAR(WS-HEX)) TO WS-BITS
                     SUBTRACT 1 FROM WS-BITS
                     PERFORM VARYING WS-BIT FROM 7 BY -1 UNTIL WS-BIT < 0
                         IF FUNCTION MOD(WS-BITS, 2) = 1
                             COMPUTE WS-X = FUNCTION MOD(WS-C, 16) * 8 + WS-BIT
                             DIVIDE WS-C BY 16 GIVING WS-Y
                             COMPUTE WS-Y = WS-Y * 8 + WS-ROW
                             COMPUTE WS-P = WS-Y * 128 + WS-X
                             MOVE WS-INK TO L-RGBA(WS-P * 4 + 1:4)
                         END-IF
                         COMPUTE WS-BITS = WS-BITS / 2
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
     END-EVALUATE
     GOBACK.
 END PROGRAM BUILTIN-TEXTURE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEX-ICON.
*> USING stem (PIC X(32)), RGBA (16 x 16, transparent on entry): the item icon recipes of
*> standin-content §2, drawn step by step with the §1.4.1 shapes: R a rectangle (x0, y0, x1, y1),
*> T a triangle (three corners), L a line (x0, y0, x1, y1, width) of which only the pixels with
*> y at least the sixth number are drawn (0 = all; the pry bar's grip).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STEPS.
    05 FILLER PIC X(32) VALUE "pry_bar     L021312030200 9AA3AD".
    05 FILLER PIC X(32) VALUE "pry_bar     L110209020200 9AA3AD".
    05 FILLER PIC X(32) VALUE "pry_bar     L021312030210 C24A3A".
    05 FILLER PIC X(32) VALUE "trowel      T080103091309 B8BEC6".
    05 FILLER PIC X(32) VALUE "trowel      L081008150200 6B4A2B".
    05 FILLER PIC X(32) VALUE "grazer_flankR040511100000 B5544A".
    05 FILLER PIC X(32) VALUE "grazer_flankT110514081110 B5544A".
    05 FILLER PIC X(32) VALUE "grazer_flankL050610060100 E3B7A0".
    05 FILLER PIC X(32) VALUE "grazer_flankL010703070200 EDE6CF".
    05 FILLER PIC X(32) VALUE "seared_flankR040511100000 6E3B22".
    05 FILLER PIC X(32) VALUE "seared_flankT110514081110 6E3B22".
    05 FILLER PIC X(32) VALUE "seared_flankL050610060100 A0623A".
    05 FILLER PIC X(32) VALUE "seared_flankL010703070200 EDE6CF".
    05 FILLER PIC X(32) VALUE "sod_cake    R030712120000 7A5634".
    05 FILLER PIC X(32) VALUE "sod_cake    R030512060000 4F8F3A".
    05 FILLER PIC X(32) VALUE "sod_cake    L031312130100 5A3F26".
    05 FILLER PIC X(32) VALUE "dump_shard  T080104121109 8F7CFF".
    05 FILLER PIC X(32) VALUE "dump_shard  L080307100100 E8F04A".
 01 WS-STEP-TABLE REDEFINES WS-STEPS.
    05 WS-STEP OCCURS 18 TIMES.
       10 WS-ST-STEM       PIC X(12).
       10 WS-ST-OP         PIC X.
       10 WS-ST-N          PIC 99 OCCURS 6 TIMES.
       10 FILLER           PIC X.
       10 WS-ST-RGB        PIC X(6).
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-NUMBERS.
    05 WS-N                BINARY-LONG OCCURS 6 TIMES.
 01 WS-E1                  BINARY-LONG.
 01 WS-E2                  BINARY-LONG.
 01 WS-E3                  BINARY-LONG.
 01 WS-INK                 PIC X(4).
 LINKAGE SECTION.
 01 L-STEM                 PIC X(32).
 01 L-RGBA                 PIC X(1024).
 PROCEDURE DIVISION USING L-STEM L-RGBA.
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 18
         IF WS-ST-STEM(WS-S) = L-STEM(1:12)
             MOVE FUNCTION HEX-TO-CHAR(WS-ST-RGB(WS-S)) TO WS-INK(1:3)
             MOVE FUNCTION CHAR(256) TO WS-INK(4:1)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 MOVE WS-ST-N(WS-S, WS-I) TO WS-N(WS-I)
             END-PERFORM
             EVALUATE WS-ST-OP(WS-S)
                 WHEN "L"
                     CALL "TEX-LINE" USING L-RGBA WS-NUMBERS WS-INK
                 WHEN OTHER
                     PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P > 255
                         DIVIDE WS-P BY 16 GIVING WS-Y REMAINDER WS-X
*>                       R: inside the rectangle. T: the three edge values E(P, Q) = (Qx - Px)
*>                       (y - Py) - (Qy - Py)(x - Px) all >= 0 or all <= 0.
                         COMPUTE WS-E1 = (WS-N(3) - WS-N(1)) * (WS-Y - WS-N(2))
                             - (WS-N(4) - WS-N(2)) * (WS-X - WS-N(1))
                         COMPUTE WS-E2 = (WS-N(5) - WS-N(3)) * (WS-Y - WS-N(4))
                             - (WS-N(6) - WS-N(4)) * (WS-X - WS-N(3))
                         COMPUTE WS-E3 = (WS-N(1) - WS-N(5)) * (WS-Y - WS-N(6))
                             - (WS-N(2) - WS-N(6)) * (WS-X - WS-N(5))
                         EVALUATE TRUE
                             WHEN WS-ST-OP(WS-S) = "R"
                                     AND (WS-X < WS-N(1) OR WS-X > WS-N(3)
                                     OR WS-Y < WS-N(2) OR WS-Y > WS-N(4))
                                 CONTINUE
                             WHEN WS-ST-OP(WS-S) = "R"
                                 MOVE WS-INK TO L-RGBA(WS-P * 4 + 1:4)
                             WHEN (WS-E1 >= 0 AND WS-E2 >= 0 AND WS-E3 >= 0)
                                     OR (WS-E1 <= 0 AND WS-E2 <= 0 AND WS-E3 <= 0)
                                 MOVE WS-INK TO L-RGBA(WS-P * 4 + 1:4)
                         END-EVALUATE
                     END-PERFORM
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM TEX-ICON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEX-LINE.
*> USING RGBA (16 x 16), numbers (6 BINARY-LONG: x0, y0, x1, y1, width, lowest y drawn), colour
*> (4 bytes): the line L of
*> standin-content §1.4.1: n = max(|dx|, |dy|) centre pixels xi = x0 + sgn(dx)((2 i |dx| + n) div
*> 2n), likewise yi; a shallow line is thickened downward, a steep or diagonal one to the right;
*> pixels outside the texture or above the lowest y are dropped.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AY                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-RGBA                 PIC X(1024).
 01 L-NUMBERS.
    05 L-X0                BINARY-LONG.
    05 L-Y0                BINARY-LONG.
    05 L-X1                BINARY-LONG.
    05 L-Y1                BINARY-LONG.
    05 L-W                 BINARY-LONG.
    05 L-MIN-Y             BINARY-LONG.
 01 L-INK                  PIC X(4).
 PROCEDURE DIVISION USING L-RGBA L-NUMBERS L-INK.
     COMPUTE WS-DX = L-X1 - L-X0
     COMPUTE WS-DY = L-Y1 - L-Y0
     COMPUTE WS-AX = FUNCTION ABS(WS-DX)
     COMPUTE WS-AY = FUNCTION ABS(WS-DY)
     COMPUTE WS-N = FUNCTION MAX(WS-AX, WS-AY)
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > WS-N
         MOVE L-X0 TO WS-X
         MOVE L-Y0 TO WS-Y
         IF WS-N > 0
             COMPUTE WS-Q = (2 * WS-I * WS-AX + WS-N) / (2 * WS-N)
             COMPUTE WS-X = L-X0 + FUNCTION SIGN(WS-DX) * WS-Q
             COMPUTE WS-Q = (2 * WS-I * WS-AY + WS-N) / (2 * WS-N)
             COMPUTE WS-Y = L-Y0 + FUNCTION SIGN(WS-DY) * WS-Q
         END-IF
         PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K >= L-W
             MOVE WS-X TO WS-PX
             MOVE WS-Y TO WS-PY
             IF WS-AX > WS-AY
                 ADD WS-K TO WS-PY
             ELSE
                 ADD WS-K TO WS-PX
             END-IF
             IF WS-PX >= 0 AND WS-PX <= 15 AND WS-PY >= L-MIN-Y AND WS-PY <= 15
                 MOVE L-INK TO L-RGBA((WS-PY * 16 + WS-PX) * 4 + 1:4)
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM TEX-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEX-NOISE.
*> USING texture name (PIC X(32)), RGBA out (16 x 16): the noise recipes of standin-content §1.4.2:
*> n = H(name bytes, x, y) mod 100; the second colour when n < p1, the third when p1 <= n < p1 + p2,
*> otherwise the fill.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RECIPES.
    05 FILLER PIC X(46) VALUE "greystone7D7F86FF206C6E75FF088E9097FF".
    05 FILLER PIC X(46) VALUE "loam     7A5634FF15664629FF058C6640FF".
    05 FILLER PIC X(46) VALUE "turf_top 4F8F3AFF20447D32FF105CA044FF".
    05 FILLER PIC X(46) VALUE "grit     D2C08AFF30C2AE76FF10E0D09EFF".
    05 FILLER PIC X(46) VALUE "slag     4A3F3AFF253A302CFF126E4A32FF".
 01 WS-RECIPE-TABLE REDEFINES WS-RECIPES.
    05 WS-RECIPE OCCURS 5 TIMES.
       10 WS-RC-NAME       PIC X(9).
       10 WS-RC-FILL       PIC X(8).
       10 WS-RC-P1         PIC 99.
       10 WS-RC-C1         PIC X(8).
       10 WS-RC-P2         PIC 99.
       10 WS-RC-C2         PIC X(8).
       10 FILLER           PIC X(9).
 01 WS-R                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PREFIX              BINARY-DOUBLE UNSIGNED.
 01 WS-H                   BINARY-DOUBLE UNSIGNED.
 01 WS-V                   BINARY-DOUBLE UNSIGNED.
 01 WS-FILL                PIC X(4).
 01 WS-C1                  PIC X(4).
 01 WS-C2                  PIC X(4).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-RGBA                 PIC X(1024).
 PROCEDURE DIVISION USING L-NAME L-RGBA.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-RC-NAME(WS-R) = L-NAME(1:9)
         CONTINUE
     END-PERFORM
     MOVE FUNCTION HEX-TO-CHAR(WS-RC-FILL(WS-R)) TO WS-FILL
     MOVE FUNCTION HEX-TO-CHAR(WS-RC-C1(WS-R)) TO WS-C1
     MOVE FUNCTION HEX-TO-CHAR(WS-RC-C2(WS-R)) TO WS-C2
*>   H over the name bytes is the same for every pixel: computed once.
     MOVE 2166136261 TO WS-PREFIX
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-NAME)) TO WS-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LENGTH
         COMPUTE WS-V = FUNCTION ORD(L-NAME(WS-I:1)) - 1
         CALL "TEX-HASH-STEP" USING WS-PREFIX WS-V
     END-PERFORM
     PERFORM VARYING WS-P FROM 0 BY 1 UNTIL WS-P > 255
         DIVIDE WS-P BY 16 GIVING WS-Y REMAINDER WS-X
         MOVE WS-PREFIX TO WS-H
         MOVE WS-X TO WS-V
         CALL "TEX-HASH-STEP" USING WS-H WS-V
         MOVE WS-Y TO WS-V
         CALL "TEX-HASH-STEP" USING WS-H WS-V
         COMPUTE WS-N = FUNCTION MOD(WS-H, 100)
         EVALUATE TRUE
             WHEN WS-N < WS-RC-P1(WS-R)
                 MOVE WS-C1 TO L-RGBA(WS-P * 4 + 1:4)
             WHEN WS-N < WS-RC-P1(WS-R) + WS-RC-P2(WS-R)
                 MOVE WS-C2 TO L-RGBA(WS-P * 4 + 1:4)
             WHEN OTHER
                 MOVE WS-FILL TO L-RGBA(WS-P * 4 + 1:4)
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM TEX-NOISE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEX-HASH-STEP.
*> USING h (BINARY-DOUBLE UNSIGNED, below 2^32), v (non-negative, below 2^32): one step of H
*> (standin-content §1.4.1): h <- mix((h + v) mod 2^32).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M                   BINARY-DOUBLE UNSIGNED VALUE 4294967296.
 01 WS-K1                  BINARY-DOUBLE UNSIGNED VALUE 2654435761.
 01 WS-K2                  BINARY-DOUBLE UNSIGNED VALUE 2246822519.
 01 WS-PRODUCT             BINARY-DOUBLE UNSIGNED.
 01 WS-Q                   BINARY-DOUBLE UNSIGNED.
 01 WS-HI                  BINARY-DOUBLE UNSIGNED.
 01 WS-LO                  BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-H                    BINARY-DOUBLE UNSIGNED.
 01 L-V                    BINARY-DOUBLE UNSIGNED.
 PROCEDURE DIVISION USING L-H L-V.
     COMPUTE WS-PRODUCT = L-H + L-V
     DIVIDE WS-PRODUCT BY WS-M GIVING WS-Q REMAINDER L-H
     COMPUTE WS-PRODUCT = L-H * WS-K1
     DIVIDE WS-PRODUCT BY WS-M GIVING WS-Q REMAINDER L-H
     DIVIDE L-H BY 65536 GIVING WS-HI REMAINDER WS-LO
     COMPUTE L-H = WS-HI + WS-LO * 65536
     COMPUTE WS-PRODUCT = L-H * WS-K2
     DIVIDE WS-PRODUCT BY WS-M GIVING WS-Q REMAINDER L-H
     DIVIDE L-H BY 65536 GIVING WS-HI REMAINDER WS-LO
     COMPUTE L-H = WS-HI + WS-LO * 65536
     GOBACK.
 END PROGRAM TEX-HASH-STEP.
