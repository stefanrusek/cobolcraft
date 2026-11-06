*> Font (08 §10.10; standin-content §18): FONT-LOAD reads font cobolcraft:default from the packs
*> (its first bitmap provider: image, height, chars rows), builds the UI atlas (texture 2: the font
*> image at its top-left, then a row of 8 x 8 swatches: white, the missing glyph box, and the UI
*> colours of CLCONST.cpy SW-*), and measures each glyph: its advance is its rightmost ink column + 2
*> cell pixels (4 for no ink), scaled by height / cell height. FONT-GLYPH gives a code point's cell
*> and advance; code points that have no cell draw as the missing glyph (advance 6).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FONT-LOAD.
*> USING CLIENT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY JSONDOC.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(65536).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-IMAGE               PIC X(1048576).
 01 WS-IMAGE-CAP           BINARY-LONG VALUE 1048576.
 01 WS-IW                  BINARY-LONG.
 01 WS-IH                  BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-PROVIDER            BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COLS                BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-CP                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-INK                 BINARY-LONG.
 01 WS-BYTES               BINARY-LONG.
 01 WS-VALUE               PIC X(256).
 01 WS-VALUE-CAP           BINARY-LONG VALUE 256.
 01 WS-VALUE-LENGTH        BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(256).
 01 WS-ROW-LENGTH          BINARY-LONG.
 01 WS-COLON               BINARY-LONG.
 01 WS-KEY                 PIC X(16).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-SWATCHES            PIC X(56) VALUE
     "FFFFFFFF00000000000000A05A5A6EFF8C8CC8FF141420FFC8141450".
 01 WS-BOX                 PIC X(16) VALUE "F88888888888F800".
 01 WS-BITS                BINARY-LONG.
 01 B-ATLAS                PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     INITIALIZE FN-GLYPH-AREA
     MOVE 8 TO FN-CELL-W FN-CELL-H FN-HEIGHT
     MOVE 0 TO WS-IW WS-IH WS-PROVIDER
     MOVE "assets/cobolcraft/font/default.json" TO WS-PATH
     MOVE 35 TO WS-PATH-LENGTH
     CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-TEXT WS-CAPACITY WS-LENGTH
         WS-FOUND
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LENGTH
*>   The first provider of type bitmap.
     MOVE "providers" TO WS-KEY
     MOVE 9 TO WS-KEY-LENGTH
     MOVE FUNCTION MIN(JD-COUNT, 1) TO WS-I
     CALL "JSON-MEMBER" USING JSON-DOC WS-I WS-KEY WS-KEY-LENGTH WS-NODE
     IF WS-NODE > 0
         MOVE JN-FIRST(WS-NODE) TO WS-NODE
     END-IF
     PERFORM UNTIL WS-NODE = 0 OR WS-PROVIDER > 0
         MOVE "type" TO WS-KEY
         MOVE 4 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-NODE WS-KEY WS-KEY-LENGTH WS-I
         CALL "JSON-STRING" USING JSON-DOC WS-I WS-VALUE WS-VALUE-CAP WS-VALUE-LENGTH
         IF WS-VALUE(1:WS-VALUE-LENGTH) = "bitmap" AND WS-VALUE-LENGTH = 6
             MOVE WS-NODE TO WS-PROVIDER
         END-IF
         MOVE JN-NEXT(WS-NODE) TO WS-NODE
     END-PERFORM
     IF WS-PROVIDER > 0
*>       file "ns:path" names assets/ns/textures/path.
         MOVE "file" TO WS-KEY
         MOVE 4 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-PROVIDER WS-KEY WS-KEY-LENGTH WS-I
         MOVE SPACES TO WS-VALUE
         CALL "JSON-STRING" USING JSON-DOC WS-I WS-VALUE WS-VALUE-CAP WS-VALUE-LENGTH
         MOVE 0 TO WS-COLON
         INSPECT WS-VALUE TALLYING WS-COLON FOR CHARACTERS BEFORE INITIAL ":"
         MOVE SPACES TO WS-PATH
         STRING "assets/" WS-VALUE(1:WS-COLON) "/textures/"
             WS-VALUE(WS-COLON + 2:WS-VALUE-LENGTH - WS-COLON - 1) DELIMITED BY SIZE INTO WS-PATH
         COMPUTE WS-PATH-LENGTH = WS-VALUE-LENGTH + 16
         CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMAGE WS-IMAGE-CAP WS-IW
             WS-IH WS-FOUND
         MOVE "height" TO WS-KEY
         MOVE 6 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-PROVIDER WS-KEY WS-KEY-LENGTH WS-I
         IF WS-I > 0
             MOVE JN-NUM(WS-I) TO FN-HEIGHT
         END-IF
         MOVE "chars" TO WS-KEY
         MOVE 5 TO WS-KEY-LENGTH
         CALL "JSON-MEMBER" USING JSON-DOC WS-PROVIDER WS-KEY WS-KEY-LENGTH WS-NODE
         MOVE JN-COUNT(WS-NODE) TO WS-ROWS
         MOVE JN-FIRST(WS-NODE) TO WS-NODE
         CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-ROW-TEXT WS-VALUE-CAP WS-ROW-LENGTH
         MOVE 0 TO WS-COLS
         MOVE 1 TO WS-POS
         PERFORM UNTIL WS-POS > WS-ROW-LENGTH
             CALL "UTF8-DECODE" USING WS-ROW-TEXT WS-ROW-LENGTH WS-POS WS-CP
             ADD 1 TO WS-COLS
         END-PERFORM
         COMPUTE FN-CELL-W = WS-IW / FUNCTION MAX(WS-COLS, 1)
         COMPUTE FN-CELL-H = WS-IH / FUNCTION MAX(WS-ROWS, 1)
     END-IF
*>   The UI atlas: the font image, then the pack icon cells (CL-MAX-ICONS cells of 16 x 16, as
*>   many to a row as fit; local.cob), then the swatch row.
     COMPUTE UA-W = FUNCTION MAX(WS-IW, SW-COUNT * 8)
     MOVE WS-IH TO UA-ICON-Y
     COMPUTE WS-BYTES = UA-W / 16
     COMPUTE WS-BYTES = (CL-MAX-ICONS + WS-BYTES - 1) / WS-BYTES
     COMPUTE UA-H = WS-IH + WS-BYTES * 16 + 8
     IF UA-ADDR NOT = NULL
         FREE UA-ADDR
     END-IF
     COMPUTE WS-BYTES = UA-W * UA-H * 4
     ALLOCATE WS-BYTES CHARACTERS INITIALIZED RETURNING UA-ADDR
     SET ADDRESS OF B-ATLAS TO UA-ADDR
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= WS-IH
         MOVE WS-IMAGE(WS-Y * WS-IW * 4 + 1:WS-IW * 4) TO B-ATLAS(WS-Y * UA-W * 4 + 1:WS-IW * 4)
     END-PERFORM
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= SW-COUNT
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 7
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 7
                 COMPUTE WS-POS = ((UA-H - 8 + WS-Y) * UA-W + WS-I * 8 + WS-X) * 4 + 1
                 MOVE FUNCTION HEX-TO-CHAR(WS-SWATCHES(WS-I * 8 + 1:8)) TO B-ATLAS(WS-POS:4)
                 IF WS-I = SW-MISSING-GLYPH
                     MOVE FUNCTION ORD(FUNCTION HEX-TO-CHAR(WS-BOX(WS-Y * 2 + 1:2))) TO WS-BITS
                     COMPUTE WS-BITS = (WS-BITS - 1) / 2 ** (7 - WS-X)
                     IF FUNCTION MOD(WS-BITS, 2) = 1
                         MOVE FUNCTION HEX-TO-CHAR("FFFFFFFF") TO B-ATLAS(WS-POS:4)
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 1 TO AT-UPLOAD(3)
*>   Glyph cells and advances of every code point 32 to 127 in the chars rows (U+0000 marks an
*>   unused cell).
     PERFORM VARYING WS-ROW FROM 0 BY 1 UNTIL WS-ROW >= WS-ROWS
         CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-ROW-TEXT WS-VALUE-CAP WS-ROW-LENGTH
         MOVE 1 TO WS-POS
         PERFORM VARYING WS-COL FROM 0 BY 1 UNTIL WS-POS > WS-ROW-LENGTH
             CALL "UTF8-DECODE" USING WS-ROW-TEXT WS-ROW-LENGTH WS-POS WS-CP
             IF WS-CP >= 32 AND WS-CP <= 127
                 COMPUTE WS-I = WS-CP - 31
                 MOVE 1 TO FN-PRESENT(WS-I)
                 COMPUTE FN-X(WS-I) = WS-COL * FN-CELL-W
                 COMPUTE FN-Y(WS-I) = WS-ROW * FN-CELL-H
                 MOVE -1 TO WS-INK
                 PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y >= FN-CELL-H
                     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X >= FN-CELL-W
                         COMPUTE WS-BITS = ((FN-Y(WS-I) + WS-Y) * UA-W + FN-X(WS-I) + WS-X) * 4 + 4
                         IF B-ATLAS(WS-BITS:1) NOT = LOW-VALUE AND WS-X > WS-INK
                             MOVE WS-X TO WS-INK
                         END-IF
                     END-PERFORM
                 END-PERFORM
                 COMPUTE FN-ADVANCE(WS-I) = (WS-INK + 2) * FN-HEIGHT / FN-CELL-H
                 IF WS-INK < 0
                     COMPUTE FN-ADVANCE(WS-I) = 4 * FN-HEIGHT / FN-CELL-H
                 END-IF
             END-IF
         END-PERFORM
         MOVE JN-NEXT(WS-NODE) TO WS-NODE
     END-PERFORM
     GOBACK.
 END PROGRAM FONT-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FONT-GLYPH.
*> USING CLIENT-STATE, code point, cell x out, cell y out, cell width out, cell height out (UI
*> atlas texels), advance out (drawn pixels at the font height).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CP                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-ADVANCE              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CP L-X L-Y L-W L-H L-ADVANCE.
     COMPUTE WS-I = L-CP - 31
     COMPUTE L-X = SW-MISSING-GLYPH * 8
     COMPUTE L-Y = UA-H - 8
     MOVE 8 TO L-W L-H
     MOVE 6 TO L-ADVANCE
     IF WS-I >= 1 AND WS-I <= 96
         IF FN-PRESENT(WS-I) = 1
             MOVE FN-X(WS-I) TO L-X
             MOVE FN-Y(WS-I) TO L-Y
             MOVE FN-CELL-W TO L-W
             MOVE FN-CELL-H TO L-H
             MOVE FN-ADVANCE(WS-I) TO L-ADVANCE
         END-IF
     END-IF
     GOBACK.
 END PROGRAM FONT-GLYPH.
