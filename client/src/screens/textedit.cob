*> The text engines of the book and sign editors (docs/protocol/40-menus-8-book-and-sign-editors.md): the page editor (BOOK-*: MultilineTextField, section 2), the book's pages and
*> packets (3.3, 4, 7: Edit Book 05c 0x18) and the sign line editor (SIGN-*: TextFieldHelper, sections 5 and 6.2: Sign Update 05c 0x3E). Text is ASCII here (one byte per code unit); a
*> fixed advance (BK-ADVANCE above 0) stands for the font in tests. No screen widgets are drawn yet.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TXT-WIDTH.
*> USING CLIENT-STATE, text (PIC X(1100)), start (1 based), length, width out: the width of text(start : length): length x BK-ADVANCE with a fixed advance, else the font's.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PART                PIC X(256).
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1100).
 01 L-START                BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-START L-LENGTH L-WIDTH.
     MOVE 0 TO L-WIDTH
     IF L-LENGTH > 0
         IF BK-ADVANCE > 0
             COMPUTE L-WIDTH = L-LENGTH * BK-ADVANCE
         ELSE
             MOVE FUNCTION MIN(L-LENGTH, 256) TO WS-N
             MOVE SPACES TO WS-PART
             MOVE L-TEXT(L-START:WS-N) TO WS-PART
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-PART WS-N L-WIDTH
         END-IF
     END-IF
     GOBACK.
 END PROGRAM TXT-WIDTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-INIT.
*> USING CLIENT-STATE, wrap width, character limit, line limit, fixed advance (0 = the font): an empty page editor (cursor 0, no selection, one empty display line).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-WIDTH                BINARY-LONG.
 01 L-CLIMIT               BINARY-LONG.
 01 L-LLIMIT               BINARY-LONG.
 01 L-ADVANCE              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-WIDTH L-CLIMIT L-LLIMIT L-ADVANCE.
     MOVE L-WIDTH TO BK-WIDTH
     MOVE L-CLIMIT TO BK-CHAR-LIMIT
     MOVE L-LLIMIT TO BK-LINE-LIMIT
     MOVE L-ADVANCE TO BK-ADVANCE
     MOVE SPACES TO BK-VALUE BK-CLIP
     MOVE 0 TO BK-LEN BK-CURSOR BK-ANCHOR BK-SELECTING BK-CLIP-LEN BE-ACTIVE
     MOVE 1 TO BK-LINE-COUNT BK-OVERFLOW
     MOVE 0 TO BK-LB(1) BK-LE(1)
     GOBACK.
 END PROGRAM BOOK-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-WRAP.
*> USING CLIENT-STATE: 2.3 the display lines of BK-VALUE at the wrap width: a line ends when the running width passes the limit (at the last space, else before the character just
*> added; the first character of a line always fits) or at a line feed; a space or line feed at the break is consumed; a final line feed adds an empty view; an empty text is the
*> view (0, 0). BK-LINE-COUNT and BK-OVERFLOW (the line count the line limit is tested against) are set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-START               BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-BROKE               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-POS                 BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO BK-LINE-COUNT
     MOVE 0 TO WS-START
     MOVE FUNCTION MAX(BK-WIDTH, 1) TO WS-LIMIT
     PERFORM UNTIL WS-START >= BK-LEN
         MOVE WS-START TO WS-IDX
         MOVE 0 TO WS-RUN WS-FLAG WS-BROKE
         MOVE -1 TO WS-LAST
         PERFORM UNTIL WS-IDX >= BK-LEN OR WS-BROKE = 1
             COMPUTE WS-B = FUNCTION ORD(BK-VALUE(WS-IDX + 1:1)) - 1
             IF WS-B = 10
                 MOVE WS-IDX TO WS-END
                 MOVE 1 TO WS-BROKE
             ELSE
                 IF WS-B = 32
                     MOVE WS-IDX TO WS-LAST
                 END-IF
                 COMPUTE WS-POS = WS-IDX + 1
                 CALL "TXT-WIDTH" USING CLIENT-STATE BK-VALUE WS-POS WS-ONE WS-W
                 ADD WS-W TO WS-RUN
                 IF WS-FLAG = 1 AND WS-RUN > WS-LIMIT
                     IF WS-LAST >= 0
                         MOVE WS-LAST TO WS-END
                     ELSE
                         MOVE WS-IDX TO WS-END
                     END-IF
                     MOVE 1 TO WS-BROKE
                 ELSE
                     IF WS-W NOT = 0
                         MOVE 1 TO WS-FLAG
                     END-IF
                     ADD 1 TO WS-IDX
                 END-IF
             END-IF
         END-PERFORM
         IF BK-LINE-COUNT < 64
             ADD 1 TO BK-LINE-COUNT
             MOVE WS-START TO BK-LB(BK-LINE-COUNT)
         END-IF
         IF WS-BROKE = 0
             IF BK-LINE-COUNT <= 64
                 MOVE BK-LEN TO BK-LE(BK-LINE-COUNT)
             END-IF
             MOVE BK-LEN TO WS-START
         ELSE
             IF BK-LINE-COUNT <= 64
                 MOVE WS-END TO BK-LE(BK-LINE-COUNT)
             END-IF
             COMPUTE WS-B = FUNCTION ORD(BK-VALUE(WS-END + 1:1)) - 1
             IF WS-B = 32 OR WS-B = 10
                 COMPUTE WS-START = WS-END + 1
             ELSE
                 MOVE WS-END TO WS-START
             END-IF
         END-IF
     END-PERFORM
     IF BK-LEN = 0
         MOVE 1 TO BK-LINE-COUNT
         MOVE 0 TO BK-LB(1) BK-LE(1)
     ELSE
         COMPUTE WS-B = FUNCTION ORD(BK-VALUE(BK-LEN:1)) - 1
         IF WS-B = 10 AND BK-LINE-COUNT < 64
             ADD 1 TO BK-LINE-COUNT
             MOVE BK-LEN TO BK-LB(BK-LINE-COUNT) BK-LE(BK-LINE-COUNT)
         END-IF
     END-IF
     MOVE BK-LINE-COUNT TO BK-OVERFLOW
     GOBACK.
 END PROGRAM BOOK-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-STORE-PAGE.
*> USING CLIENT-STATE: the value listener of 3.3: the page shown takes the text of the editor (while a book is being edited).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF BE-ACTIVE = 1
         MOVE SPACES TO BE-PAGE-TEXT(BE-CURRENT + 1)
         IF BK-LEN > 0
             MOVE BK-VALUE(1:BK-LEN) TO BE-PAGE-TEXT(BE-CURRENT + 1)(1:BK-LEN)
         END-IF
         MOVE BK-LEN TO BE-PAGE-LEN(BE-CURRENT + 1)
     END-IF
     GOBACK.
 END PROGRAM BOOK-STORE-PAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-SET-VALUE.
*> USING CLIENT-STATE, text (PIC X(1100)), length, force: 2.4 setValue: cut to the character limit; without force a text that overflows the line limit is ignored; the cursor and the
*> anchor go to the end.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 PIC X(1100).
 01 WS-OLD-LEN             BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 01 L-FORCE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-FORCE.
     MOVE BK-VALUE TO WS-OLD
     MOVE BK-LEN TO WS-OLD-LEN
     MOVE FUNCTION MIN(L-LENGTH, BK-CHAR-LIMIT) TO WS-N
     MOVE SPACES TO BK-VALUE
     IF WS-N > 0
         MOVE L-TEXT(1:WS-N) TO BK-VALUE(1:WS-N)
     END-IF
     MOVE WS-N TO BK-LEN
     CALL "BOOK-WRAP" USING CLIENT-STATE
     IF L-FORCE = 0 AND BK-OVERFLOW > BK-LINE-LIMIT
         MOVE WS-OLD TO BK-VALUE
         MOVE WS-OLD-LEN TO BK-LEN
         CALL "BOOK-WRAP" USING CLIENT-STATE
     ELSE
         MOVE BK-LEN TO BK-CURSOR BK-ANCHOR
     END-IF
     GOBACK.
 END PROGRAM BOOK-SET-VALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-INSERT.
*> USING CLIENT-STATE, text (PIC X(1100)), length: 2.4 insert: nothing for an empty argument with no selection; the text is filtered (no byte below 32 but the line feed, no 127, no
*> section sign C2 A7), cut to the room left in the whole text (the selection is not credited), replaces the selection; an insertion that would pass the line limit is rejected whole;
*> the cursor goes after the inserted text.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 PIC X(1100).
 01 WS-OLD-LEN             BINARY-LONG.
 01 WS-INS                 PIC X(1100).
 01 WS-INS-LEN             BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 01 WS-TAIL                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH.
     MOVE FUNCTION MIN(BK-CURSOR, BK-ANCHOR) TO WS-S
     MOVE FUNCTION MAX(BK-CURSOR, BK-ANCHOR) TO WS-E
     IF L-LENGTH = 0 AND WS-S = WS-E
         GOBACK
     END-IF
     MOVE SPACES TO WS-INS
     MOVE 0 TO WS-INS-LEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         COMPUTE WS-B = FUNCTION ORD(L-TEXT(WS-I:1)) - 1
         MOVE 0 TO WS-NEXT
         IF WS-I < L-LENGTH
             COMPUTE WS-NEXT = FUNCTION ORD(L-TEXT(WS-I + 1:1)) - 1
         END-IF
         EVALUATE TRUE
             WHEN WS-B = 10
                 ADD 1 TO WS-INS-LEN
                 MOVE L-TEXT(WS-I:1) TO WS-INS(WS-INS-LEN:1)
             WHEN WS-B < 32 OR WS-B = 127
                 CONTINUE
             WHEN WS-B = 194 AND WS-NEXT = 167
                 ADD 1 TO WS-I
             WHEN OTHER
                 ADD 1 TO WS-INS-LEN
                 MOVE L-TEXT(WS-I:1) TO WS-INS(WS-INS-LEN:1)
         END-EVALUATE
     END-PERFORM
     MOVE FUNCTION MAX(BK-CHAR-LIMIT - BK-LEN, 0) TO WS-ROOM
     IF WS-INS-LEN > WS-ROOM
         MOVE WS-ROOM TO WS-INS-LEN
     END-IF
     MOVE BK-VALUE TO WS-OLD
     MOVE BK-LEN TO WS-OLD-LEN
     COMPUTE WS-TAIL = BK-LEN - WS-E
     MOVE SPACES TO BK-VALUE
     IF WS-S > 0
         MOVE WS-OLD(1:WS-S) TO BK-VALUE(1:WS-S)
     END-IF
     IF WS-INS-LEN > 0
         MOVE WS-INS(1:WS-INS-LEN) TO BK-VALUE(WS-S + 1:WS-INS-LEN)
     END-IF
     IF WS-TAIL > 0
         MOVE WS-OLD(WS-E + 1:WS-TAIL) TO BK-VALUE(WS-S + WS-INS-LEN + 1:WS-TAIL)
     END-IF
     COMPUTE BK-LEN = WS-S + WS-INS-LEN + WS-TAIL
     CALL "BOOK-WRAP" USING CLIENT-STATE
     IF BK-OVERFLOW > BK-LINE-LIMIT
         MOVE WS-OLD TO BK-VALUE
         MOVE WS-OLD-LEN TO BK-LEN
         CALL "BOOK-WRAP" USING CLIENT-STATE
     ELSE
         COMPUTE BK-CURSOR = WS-S + WS-INS-LEN
         MOVE BK-CURSOR TO BK-ANCHOR
         CALL "BOOK-STORE-PAGE" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM BOOK-INSERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-DELETE.
*> USING CLIENT-STATE, n: 2.5 deleteText: with no selection the anchor first goes to clamp(cursor + n, 0, length); then the selection is replaced by nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(1100).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-N.
     IF BK-CURSOR = BK-ANCHOR
         COMPUTE BK-ANCHOR = FUNCTION MAX(0, FUNCTION MIN(BK-CURSOR + L-N, BK-LEN))
     END-IF
     CALL "BOOK-INSERT" USING CLIENT-STATE WS-TEXT WS-ZERO
     GOBACK.
 END PROGRAM BOOK-DELETE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-WORD.
*> USING CLIENT-STATE, direction (-1 previous, 1 next), position out: 2.6 the start of the previous word (back over whitespace, then over non-whitespace) or of the next word
*> (forward over non-whitespace, then over whitespace), from clamp(cursor, 0, length - 1); 0 for an empty text.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-WS                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-DIRECTION            BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-DIRECTION L-POS.
     MOVE 0 TO L-POS
     IF BK-LEN > 0
         MOVE FUNCTION MAX(0, FUNCTION MIN(BK-CURSOR, BK-LEN - 1)) TO WS-P
         IF L-DIRECTION < 0
             MOVE 1 TO WS-WS
             PERFORM UNTIL WS-P <= 0 OR WS-WS = 0
                 COMPUTE WS-B = FUNCTION ORD(BK-VALUE(WS-P:1)) - 1
                 IF WS-B = 32 OR (WS-B >= 9 AND WS-B <= 13) OR (WS-B >= 28 AND WS-B <= 31)
                     SUBTRACT 1 FROM WS-P
                 ELSE
                     MOVE 0 TO WS-WS
                 END-IF
             END-PERFORM
             MOVE 1 TO WS-WS
             PERFORM UNTIL WS-P <= 0 OR WS-WS = 0
                 COMPUTE WS-B = FUNCTION ORD(BK-VALUE(WS-P:1)) - 1
                 IF WS-B = 32 OR (WS-B >= 9 AND WS-B <= 13) OR (WS-B >= 28 AND WS-B <= 31)
                     MOVE 0 TO WS-WS
                 ELSE
                     SUBTRACT 1 FROM WS-P
                 END-IF
             END-PERFORM
         ELSE
             MOVE 1 TO WS-WS
             PERFORM UNTIL WS-P >= BK-LEN OR WS-WS = 0
                 COMPUTE WS-B = FUNCTION ORD(BK-VALUE(WS-P + 1:1)) - 1
                 IF WS-B = 32 OR (WS-B >= 9 AND WS-B <= 13) OR (WS-B >= 28 AND WS-B <= 31)
                     MOVE 0 TO WS-WS
                 ELSE
                     ADD 1 TO WS-P
                 END-IF
             END-PERFORM
             MOVE 1 TO WS-WS
             PERFORM UNTIL WS-P >= BK-LEN OR WS-WS = 0
                 COMPUTE WS-B = FUNCTION ORD(BK-VALUE(WS-P + 1:1)) - 1
                 IF WS-B = 32 OR (WS-B >= 9 AND WS-B <= 13) OR (WS-B >= 28 AND WS-B <= 31)
                     ADD 1 TO WS-P
                 ELSE
                     MOVE 0 TO WS-WS
                 END-IF
             END-PERFORM
         END-IF
         MOVE WS-P TO L-POS
     END-IF
     GOBACK.
 END PROGRAM BOOK-WORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-LINE-OF.
*> USING CLIENT-STATE, line index out (1 based): the first display line with begin <= cursor <= end (the last line when none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-LINE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-LINE.
     MOVE BK-LINE-COUNT TO L-LINE
     PERFORM VARYING WS-I FROM BK-LINE-COUNT BY -1 UNTIL WS-I < 1
         IF BK-LB(WS-I) <= BK-CURSOR AND BK-CURSOR <= BK-LE(WS-I)
             MOVE WS-I TO L-LINE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BOOK-LINE-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-SEEK-LINE.
*> USING CLIENT-STATE, dy (-1 or 1): 2.7 the cursor moves to the line above or below (clamped): target = the width of the cursor's line up to the cursor + 2; the new cursor is the
*> destination line's begin plus the longest prefix whose width is within the target (no rounding to the nearest boundary).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LINE                BINARY-LONG.
 01 WS-DEST                BINARY-LONG.
 01 WS-TARGET              BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-STOP                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-DY                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-DY.
     CALL "BOOK-LINE-OF" USING CLIENT-STATE WS-LINE
     COMPUTE WS-LEN = BK-CURSOR - BK-LB(WS-LINE)
     COMPUTE WS-POS = BK-LB(WS-LINE) + 1
     CALL "TXT-WIDTH" USING CLIENT-STATE BK-VALUE WS-POS WS-LEN WS-TARGET
     ADD 2 TO WS-TARGET
     COMPUTE WS-DEST = FUNCTION MAX(1, FUNCTION MIN(WS-LINE + L-DY, BK-LINE-COUNT))
     MOVE BK-LB(WS-DEST) TO BK-CURSOR
     MOVE 0 TO WS-STOP
     PERFORM VARYING WS-K FROM BK-LB(WS-DEST) BY 1 UNTIL WS-K >= BK-LE(WS-DEST) OR WS-STOP = 1
         COMPUTE WS-POS = WS-K + 1
         CALL "TXT-WIDTH" USING CLIENT-STATE BK-VALUE WS-POS WS-ONE WS-W
         SUBTRACT WS-W FROM WS-TARGET
         IF WS-TARGET < 0
             MOVE 1 TO WS-STOP
         ELSE
             ADD 1 TO BK-CURSOR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BOOK-SEEK-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-KEY.
*> USING CLIENT-STATE, keycode (the SDL keycodes of 2.5), shift, edit shortcut, alt, handled out (1/0): 2.5 in the order of the table: select all (97), copy (99), paste (118), cut
*> (120) with the edit shortcut and no Shift or Alt; Backspace (8) and Delete (127) by one unit or a word; Enter (13, 1073741912) a line feed; Left, Right, Up, Down, Home, End and the
*> page keys. Shift keeps the anchor.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIRECTION           BINARY-LONG.
 01 WS-LINE                BINARY-LONG.
 01 WS-LF                  PIC X(1100).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MINUS               BINARY-LONG VALUE -1.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KEY                  BINARY-LONG.
 01 L-SHIFT                BINARY-LONG.
 01 L-EDIT                 BINARY-LONG.
 01 L-ALT                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY L-SHIFT L-EDIT L-ALT L-HANDLED.
     MOVE L-SHIFT TO BK-SELECTING
     MOVE 1 TO L-HANDLED
     MOVE FUNCTION MIN(BK-CURSOR, BK-ANCHOR) TO WS-S
     MOVE FUNCTION MAX(BK-CURSOR, BK-ANCHOR) TO WS-E
     EVALUATE TRUE
         WHEN L-KEY = 97 AND L-EDIT = 1 AND L-SHIFT = 0 AND L-ALT = 0
             MOVE BK-LEN TO BK-CURSOR
             MOVE 0 TO BK-ANCHOR
         WHEN (L-KEY = 99 OR L-KEY = 120) AND L-EDIT = 1 AND L-SHIFT = 0 AND L-ALT = 0
             MOVE SPACES TO BK-CLIP
             COMPUTE BK-CLIP-LEN = WS-E - WS-S
             IF BK-CLIP-LEN > 0
                 MOVE BK-VALUE(WS-S + 1:BK-CLIP-LEN) TO BK-CLIP
             END-IF
             IF L-KEY = 120
                 CALL "BOOK-INSERT" USING CLIENT-STATE WS-LF WS-ZERO
             END-IF
         WHEN L-KEY = 118 AND L-EDIT = 1 AND L-SHIFT = 0 AND L-ALT = 0
             CALL "BOOK-INSERT" USING CLIENT-STATE BK-CLIP BK-CLIP-LEN
         WHEN L-KEY = 8
             IF L-EDIT = 1
                 CALL "BOOK-WORD" USING CLIENT-STATE WS-MINUS WS-POS
                 COMPUTE WS-N = WS-POS - BK-CURSOR
                 CALL "BOOK-DELETE" USING CLIENT-STATE WS-N
             ELSE
                 CALL "BOOK-DELETE" USING CLIENT-STATE WS-MINUS
             END-IF
         WHEN L-KEY = 127
             IF L-EDIT = 1
                 CALL "BOOK-WORD" USING CLIENT-STATE WS-ONE WS-POS
                 COMPUTE WS-N = WS-POS - BK-CURSOR
                 CALL "BOOK-DELETE" USING CLIENT-STATE WS-N
             ELSE
                 CALL "BOOK-DELETE" USING CLIENT-STATE WS-ONE
             END-IF
         WHEN L-KEY = 13 OR L-KEY = 1073741912
             MOVE X"0A" TO WS-LF(1:1)
             CALL "BOOK-INSERT" USING CLIENT-STATE WS-LF WS-ONE
         WHEN L-KEY = 1073741904
             IF L-EDIT = 1
                 CALL "BOOK-WORD" USING CLIENT-STATE WS-MINUS WS-POS
                 MOVE WS-POS TO BK-CURSOR
             ELSE
                 COMPUTE BK-CURSOR = FUNCTION MAX(BK-CURSOR - 1, 0)
             END-IF
         WHEN L-KEY = 1073741903
             IF L-EDIT = 1
                 CALL "BOOK-WORD" USING CLIENT-STATE WS-ONE WS-POS
                 MOVE WS-POS TO BK-CURSOR
             ELSE
                 COMPUTE BK-CURSOR = FUNCTION MIN(BK-CURSOR + 1, BK-LEN)
             END-IF
         WHEN L-KEY = 1073741906
             IF L-EDIT = 0
                 CALL "BOOK-SEEK-LINE" USING CLIENT-STATE WS-MINUS
             END-IF
         WHEN L-KEY = 1073741905
             IF L-EDIT = 0
                 CALL "BOOK-SEEK-LINE" USING CLIENT-STATE WS-ONE
             END-IF
         WHEN L-KEY = 1073741898
             IF L-EDIT = 1
                 MOVE 0 TO BK-CURSOR
             ELSE
                 CALL "BOOK-LINE-OF" USING CLIENT-STATE WS-LINE
                 MOVE BK-LB(WS-LINE) TO BK-CURSOR
             END-IF
         WHEN L-KEY = 1073741901
             IF L-EDIT = 1
                 MOVE BK-LEN TO BK-CURSOR
             ELSE
                 CALL "BOOK-LINE-OF" USING CLIENT-STATE WS-LINE
                 MOVE BK-LE(WS-LINE) TO BK-CURSOR
             END-IF
         WHEN L-KEY = 1073741899
             MOVE 0 TO BK-CURSOR
         WHEN L-KEY = 1073741902
             MOVE BK-LEN TO BK-CURSOR
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     IF BK-SELECTING = 0 AND (L-KEY = 1073741904 OR L-KEY = 1073741903 OR L-KEY = 1073741906 OR L-KEY = 1073741905
             OR L-KEY = 1073741898 OR L-KEY = 1073741901 OR L-KEY = 1073741899 OR L-KEY = 1073741902)
         MOVE BK-CURSOR TO BK-ANCHOR
     END-IF
     GOBACK.
 END PROGRAM BOOK-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-LOAD.
*> USING CLIENT-STATE: 3.3 updatePageContent: the editor takes the text of the shown page (forced, cursor at the end) and edits it from now on.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FORCE               BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(1100).
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE SPACES TO WS-TEXT
     IF BE-PAGE-LEN(BE-CURRENT + 1) > 0
         MOVE BE-PAGE-TEXT(BE-CURRENT + 1)(1:BE-PAGE-LEN(BE-CURRENT + 1)) TO WS-TEXT
     END-IF
     CALL "BOOK-SET-VALUE" USING CLIENT-STATE WS-TEXT BE-PAGE-LEN(BE-CURRENT + 1) WS-FORCE
     MOVE 1 TO BE-ACTIVE
     GOBACK.
 END PROGRAM BOOK-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-PAGE-BACK.
*> USING CLIENT-STATE: 3.3 step 4: back one page when not on the first, and load it.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF BE-CURRENT > 0
         SUBTRACT 1 FROM BE-CURRENT
     END-IF
     CALL "BOOK-LOAD" USING CLIENT-STATE
     GOBACK.
 END PROGRAM BOOK-PAGE-BACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-PAGE-FORWARD.
*> USING CLIENT-STATE: 3.3 step 5: forward when not on the last page; else an empty page is appended (not past 100 pages) and shown when the index is then below the last; load it.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF BE-CURRENT < BE-PAGE-COUNT - 1
         ADD 1 TO BE-CURRENT
     ELSE
         IF BE-PAGE-COUNT < 100
             ADD 1 TO BE-PAGE-COUNT
             MOVE 0 TO BE-PAGE-LEN(BE-PAGE-COUNT)
             MOVE SPACES TO BE-PAGE-TEXT(BE-PAGE-COUNT)
         END-IF
         IF BE-CURRENT < BE-PAGE-COUNT - 1
             ADD 1 TO BE-CURRENT
         END-IF
     END-IF
     CALL "BOOK-LOAD" USING CLIENT-STATE
     GOBACK.
 END PROGRAM BOOK-PAGE-FORWARD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-SEND.
*> USING CLIENT-STATE, with title (1/0): Edit Book (05c 0x18): the slot (the selected hotbar slot for the main hand, 40 for the off hand), the pages (up to 100, 1024 units each) and
*> the optional title (BE-TITLE trimmed of leading and trailing spaces, up to 32).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 110000.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-ID                  BINARY-LONG VALUE 24.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MAX-PAGE            BINARY-LONG VALUE 1024.
 01 WS-MAX-TITLE           BINARY-LONG VALUE 32.
 01 WS-FLAG                BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TITLE               PIC X(32).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TITLE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TITLE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     IF BE-HAND = 0
         MOVE PL-HELD TO WS-SLOT
     ELSE
         MOVE 40 TO WS-SLOT
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-SLOT
     CALL "PB-PUT-VARINT" USING PB-BUFFER BE-PAGE-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BE-PAGE-COUNT
         CALL "PB-PUT-STRING" USING PB-BUFFER BE-PAGE-TEXT(WS-I) BE-PAGE-LEN(WS-I) WS-MAX-PAGE
     END-PERFORM
     MOVE L-TITLE TO WS-FLAG
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-FLAG
     IF L-TITLE = 1
         MOVE 1 TO WS-FIRST
         MOVE BE-TITLE-LEN TO WS-LAST
         PERFORM UNTIL WS-FIRST > WS-LAST OR BE-TITLE(WS-FIRST:1) NOT = SPACE
             ADD 1 TO WS-FIRST
         END-PERFORM
         PERFORM UNTIL WS-LAST < WS-FIRST OR BE-TITLE(WS-LAST:1) NOT = SPACE
             SUBTRACT 1 FROM WS-LAST
         END-PERFORM
         COMPUTE WS-LENGTH = WS-LAST - WS-FIRST + 1
         MOVE SPACES TO WS-TITLE
         IF WS-LENGTH > 0
             MOVE BE-TITLE(WS-FIRST:WS-LENGTH) TO WS-TITLE
         END-IF
         CALL "PB-PUT-STRING" USING PB-BUFFER WS-TITLE WS-LENGTH WS-MAX-TITLE
     END-IF
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM BOOK-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-DONE.
*> USING CLIENT-STATE: 3.3 step 9: the trailing empty pages are erased (a page of spaces is not empty), then Edit Book is sent without a title.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM UNTIL BE-PAGE-COUNT = 0 OR BE-PAGE-LEN(BE-PAGE-COUNT) > 0
         SUBTRACT 1 FROM BE-PAGE-COUNT
     END-PERFORM
     CALL "BOOK-SEND" USING CLIENT-STATE WS-NO
     GOBACK.
 END PROGRAM BOOK-DONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-SIGN-SEND.
*> USING CLIENT-STATE: section 4 behaviour 4: Sign and Close sends the pages as they are (no erase) and the trimmed title.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-YES                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "BOOK-SEND" USING CLIENT-STATE WS-YES
     GOBACK.
 END PROGRAM BOOK-SIGN-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-TITLE-BLANK.
*> USING title text (PIC X(1100)), length, blank out (1/0): StringUtil.isBlank: empty, or every character a space, a control whitespace (9 to 13, 28 to 31) or a no-break space (C2 A0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 01 L-BLANK                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-BLANK.
     MOVE 1 TO L-BLANK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-LENGTH
         COMPUTE WS-B = FUNCTION ORD(L-TEXT(WS-I:1)) - 1
         IF NOT (WS-B = 32 OR (WS-B >= 9 AND WS-B <= 13) OR (WS-B >= 28 AND WS-B <= 31) OR WS-B = 194 OR WS-B = 160)
             MOVE 0 TO L-BLANK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BOOK-TITLE-BLANK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-INSERT.
*> USING CLIENT-STATE, text (PIC X(1100)), length: 5.2 insert into the line being edited: a selection is deleted first; the candidate is kept when its width is within the sign's
*> limit (SG-MAXW), else the line is unchanged (the selection stays collapsed); the cursor and the anchor go after the inserted text.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CAND                PIC X(1100).
 01 WS-CAND-LEN            BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TAIL                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH.
     MOVE SG-LINE-TEXT(SG-LINE + 1) TO WS-LINE
     MOVE SG-LEN(SG-LINE + 1) TO WS-LEN
     MOVE FUNCTION MIN(SG-CURSOR, SG-ANCHOR) TO WS-S
     MOVE FUNCTION MAX(SG-CURSOR, SG-ANCHOR) TO WS-E
     IF WS-E > WS-LEN
         MOVE WS-LEN TO WS-E
     END-IF
     IF WS-S > WS-E
         MOVE WS-E TO WS-S
     END-IF
     MOVE WS-S TO SG-CURSOR SG-ANCHOR
     COMPUTE WS-TAIL = WS-LEN - WS-E
     MOVE SPACES TO WS-CAND
     IF WS-S > 0
         MOVE WS-LINE(1:WS-S) TO WS-CAND(1:WS-S)
     END-IF
     IF L-LENGTH > 0
         MOVE L-TEXT(1:L-LENGTH) TO WS-CAND(WS-S + 1:L-LENGTH)
     END-IF
     IF WS-TAIL > 0
         MOVE WS-LINE(WS-E + 1:WS-TAIL) TO WS-CAND(WS-S + L-LENGTH + 1:WS-TAIL)
     END-IF
     COMPUTE WS-CAND-LEN = WS-S + L-LENGTH + WS-TAIL
     CALL "TXT-WIDTH" USING CLIENT-STATE WS-CAND WS-ONE WS-CAND-LEN WS-W
     IF WS-W <= SG-MAXW AND WS-CAND-LEN <= 63
         MOVE WS-CAND(1:63) TO SG-LINE-TEXT(SG-LINE + 1)
         MOVE WS-CAND-LEN TO SG-LEN(SG-LINE + 1)
         COMPUTE SG-CURSOR = FUNCTION MIN(WS-CAND-LEN, WS-S + L-LENGTH)
         MOVE SG-CURSOR TO SG-ANCHOR
     END-IF
     GOBACK.
 END PROGRAM SIGN-INSERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-NAV.
*> USING CLIENT-STATE, scancode, handled out (1/0): 6.2 step 3: Up (scancode 82) selects the line (line - 1) & 3; Down (81) and Enter (40, 88) the line (line + 1) & 3; the cursor goes to
*> the end of the new line with no selection.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SCAN                 BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SCAN L-HANDLED.
     MOVE 1 TO L-HANDLED
     EVALUATE L-SCAN
         WHEN 82
             COMPUTE SG-LINE = FUNCTION MOD(SG-LINE + 3, 4)
         WHEN 81 WHEN 40 WHEN 88
             COMPUTE SG-LINE = FUNCTION MOD(SG-LINE + 1, 4)
         WHEN OTHER
             MOVE 0 TO L-HANDLED
     END-EVALUATE
     IF L-HANDLED = 1
         MOVE SG-LEN(SG-LINE + 1) TO SG-CURSOR SG-ANCHOR
     END-IF
     GOBACK.
 END PROGRAM SIGN-NAV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-CLOSE.
*> USING CLIENT-STATE: 6.2 step 7: removing the sign editor, however it closed, sends Sign Update (05c 0x3E): the position, the four lines (no count prefix, up to 384 units each) and the
*> side (VarInt: 0 back, 1 front).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-ID                  BINARY-LONG VALUE 62.
 01 WS-MAX                 BINARY-LONG VALUE 384.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ID
     CALL "PB-PUT-POSITION" USING PB-BUFFER SG-X SG-Y SG-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         CALL "PB-PUT-STRING" USING PB-BUFFER SG-LINE-TEXT(WS-I) SG-LEN(WS-I) WS-MAX
     END-PERFORM
     CALL "PB-PUT-VARINT" USING PB-BUFFER SG-SIDE
     CALL "NET-SEND" USING CLIENT-STATE WS-CONN PB-BUFFER
     GOBACK.
 END PROGRAM SIGN-CLOSE.
