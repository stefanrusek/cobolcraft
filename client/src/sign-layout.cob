*> Sign text layout (docs/protocol/52-block-entity-models-2-signs.md sections 2.1, 4.3, 5): SGR-KIND tells which of the four sign families a block state is and
*> its rotation or facing, SGR-WRAP cuts a line to the sign's width limit (5.2), SGR-LAYOUT gives the pen origin of a line (5.3, 5.4). Widths are the advances of the
*> font of the packs (FONT-GLYPH), the project font cobolcraft:default: 8 x 8 cells, the advance of a glyph its rightmost ink column + 2 (a space 4).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-WRAP.
*> USING CLIENT-STATE, text (UTF-8, any size), length, width limit (90 for a sign, 60 for a hanging sign), piece length out: the byte length of the first piece
*> of the line cut to the limit (5.2; only that piece is drawn). Scanning code point by code point: a line feed ends the piece; a space is remembered; the
*> width grows by the glyph's advance, and when an earlier glyph had a non-zero advance and the width is then above the limit (strictly) the piece ends at the last
*> space seen, or else before this character; the first glyph with an advance is always taken. A text that is not cut is all one piece.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-CP                  BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-ADV                 BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-PIECE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-WIDTH L-PIECE.
     MOVE L-LENGTH TO L-PIECE
     MOVE L-WIDTH TO WS-LIMIT
     IF WS-LIMIT < 1
         MOVE 1 TO WS-LIMIT
     END-IF
     MOVE 1 TO WS-POS
     MOVE 0 TO WS-W WS-FLAG WS-LAST WS-DONE
     PERFORM UNTIL WS-POS > L-LENGTH OR WS-DONE = 1
         MOVE WS-POS TO WS-START
         CALL "UTF8-DECODE" USING L-TEXT L-LENGTH WS-POS WS-CP
         EVALUATE TRUE
             WHEN WS-CP = 10
                 COMPUTE L-PIECE = WS-START - 1
                 MOVE 1 TO WS-DONE
             WHEN OTHER
                 IF WS-CP = 32
                     MOVE WS-START TO WS-LAST
                 END-IF
                 CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-GX WS-GY WS-GW WS-GH WS-ADV
                 ADD WS-ADV TO WS-W
                 IF WS-FLAG = 1 AND WS-W > WS-LIMIT
                     COMPUTE L-PIECE = WS-START - 1
                     IF WS-LAST > 0
                         COMPUTE L-PIECE = WS-LAST - 1
                     END-IF
                     MOVE 1 TO WS-DONE
                 END-IF
                 IF WS-DONE = 0 AND WS-ADV NOT = 0
                     MOVE 1 TO WS-FLAG
                 END-IF
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM SGR-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-LAYOUT.
*> USING CLIENT-STATE, kind (1, 2: a sign, line height 10 and limit 90; 3, 4: a hanging sign, 9 and 60), line (1 to 4), text, length, x out, y out (the pen
*> origin of the line in font pixels), piece length out, width out: line i is drawn at y = (i - 1) * h - (4 * h) / 2 (-20, -10, 0, 10; hanging -18, -9, 0, 9) and
*> at x = the integer quotient of -width / 2 truncated toward zero (27 gives -13, 83 gives -41), width the advance sum of the piece (5.3, 5.4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-H                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-CP                  BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 01 WS-ADV                 BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KIND                 BINARY-LONG.
 01 L-LINE                 BINARY-LONG.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-PIECE                BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KIND L-LINE L-TEXT L-LENGTH L-X L-Y L-PIECE L-WIDTH.
     MOVE 10 TO WS-H
     MOVE 90 TO WS-LIMIT
     IF L-KIND >= 3
         MOVE 9 TO WS-H
         MOVE 60 TO WS-LIMIT
     END-IF
     COMPUTE WS-H2 = WS-H * 4 / 2
     COMPUTE L-Y = (L-LINE - 1) * WS-H - WS-H2
     MOVE 0 TO L-PIECE L-WIDTH L-X
     IF L-LENGTH > 0
         CALL "SGR-WRAP" USING CLIENT-STATE L-TEXT L-LENGTH WS-LIMIT L-PIECE
     END-IF
     MOVE 1 TO WS-POS
     PERFORM UNTIL WS-POS > L-PIECE
         CALL "UTF8-DECODE" USING L-TEXT L-LENGTH WS-POS WS-CP
         CALL "FONT-GLYPH" USING CLIENT-STATE WS-CP WS-GX WS-GY WS-GW WS-GH WS-ADV
         ADD WS-ADV TO L-WIDTH
     END-PERFORM
     COMPUTE WS-HALF = L-WIDTH / 2
     COMPUTE L-X = 0 - WS-HALF
     GOBACK.
 END PROGRAM SGR-LAYOUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SGR-KIND.
*> USING CLIENT-STATE, block state id, kind out (SGR-STANDING 1, SGR-WALL 2, SGR-HANGING 3, SGR-WALL-HANGING 4, 0 for any other block), key out (the rotation property of a
*> standing or ceiling hanging sign, 0 to 15; the facing of a wall sign or wall hanging sign: 0 south, 1 west, 2 north, 3 east): 2.1, 4.3. The block is read from
*> the open content set (nothing is a sign without one); answers are kept by state id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CLSIGN.
 01 WS-CACHE.
    05 WS-C-ENTRY OCCURS 4096 TIMES.
       10 WS-C-STATE       BINARY-LONG VALUE -1.
       10 WS-C-KIND        BINARY-LONG VALUE 0.
       10 WS-C-KEY         BINARY-LONG VALUE 0.
 01 WS-LAST-SET            BINARY-LONG VALUE -1.
 01 WS-RESET               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ROW                 PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PROPS.
    05 WS-P-COUNT          BINARY-LONG.
    05 WS-P-ENTRY OCCURS 16 TIMES.
       10 WS-P-NAME        PIC X(24).
       10 WS-P-VALUE       PIC X(32).
 01 WS-I                   BINARY-LONG.
 01 WS-N-WALL-HANGING      BINARY-LONG.
 01 WS-N-HANGING           BINARY-LONG.
 01 WS-N-WALL              BINARY-LONG.
 01 WS-N-SIGN              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-STATE                BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-KEY                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-STATE L-KIND L-KEY.
     MOVE 0 TO L-KIND L-KEY
     IF CT-OPEN = 0 OR L-STATE <= 0
         GOBACK
     END-IF
*>   A state id means another block in another content set: the answers are dropped when the set changes.
     IF CT-SET-TYPE NOT = WS-LAST-SET
         PERFORM VARYING WS-RESET FROM 1 BY 1 UNTIL WS-RESET > 4096
             MOVE -1 TO WS-C-STATE(WS-RESET)
         END-PERFORM
         MOVE CT-SET-TYPE TO WS-LAST-SET
     END-IF
     COMPUTE WS-SLOT = FUNCTION MOD(L-STATE, 4096) + 1
     IF WS-C-STATE(WS-SLOT) = L-STATE
         MOVE WS-C-KIND(WS-SLOT) TO L-KIND
         MOVE WS-C-KEY(WS-SLOT) TO L-KEY
         GOBACK
     END-IF
     MOVE 0 TO WS-KIND WS-KEY
     MOVE L-STATE TO WS-CODE
     CALL "CONTENT-BLOCK-OF-STATE" USING WS-CODE WS-ID WS-INDEX WS-ROW WS-STATUS
     MOVE WS-ROW TO CT-BLOCK-ROW
     IF WS-STATUS = CT-OK
         MOVE 0 TO WS-N-WALL-HANGING WS-N-HANGING WS-N-WALL WS-N-SIGN
         INSPECT CT-BR-KEY TALLYING WS-N-WALL-HANGING FOR ALL "wall_hanging_sign"
         INSPECT CT-BR-KEY TALLYING WS-N-HANGING FOR ALL "hanging_sign"
         INSPECT CT-BR-KEY TALLYING WS-N-WALL FOR ALL "wall_sign"
         INSPECT CT-BR-KEY TALLYING WS-N-SIGN FOR ALL "_sign"
         EVALUATE TRUE
             WHEN WS-N-WALL-HANGING > 0
                 MOVE SGR-WALL-HANGING TO WS-KIND
             WHEN WS-N-HANGING > 0
                 MOVE SGR-HANGING TO WS-KIND
             WHEN WS-N-WALL > 0
                 MOVE SGR-WALL TO WS-KIND
             WHEN WS-N-SIGN > 0
                 MOVE SGR-STANDING TO WS-KIND
         END-EVALUATE
         IF WS-KIND > 0
             CALL "CONTENT-STATE-PROPS" USING WS-CODE WS-PROPS WS-STATUS
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-P-COUNT
                 IF WS-P-NAME(WS-I) = "rotation"
                     COMPUTE WS-KEY = FUNCTION NUMVAL(WS-P-VALUE(WS-I))
                 END-IF
                 IF WS-P-NAME(WS-I) = "facing"
                     EVALUATE WS-P-VALUE(WS-I)
                         WHEN "west"
                             MOVE 1 TO WS-KEY
                         WHEN "north"
                             MOVE 2 TO WS-KEY
                         WHEN "east"
                             MOVE 3 TO WS-KEY
                         WHEN OTHER
                             MOVE 0 TO WS-KEY
                     END-EVALUATE
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     MOVE L-STATE TO WS-C-STATE(WS-SLOT)
     MOVE WS-KIND TO WS-C-KIND(WS-SLOT)
     MOVE WS-KEY TO WS-C-KEY(WS-SLOT)
     MOVE WS-KIND TO L-KIND
     MOVE WS-KEY TO L-KEY
     GOBACK.
 END PROGRAM SGR-KIND.
