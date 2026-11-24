*> Menus, part 8: the book and sign editors (docs/protocol/40-menus-8-book-and-sign-editors.md; US12 phase 44).
*> Programs of plain numbers and texts (MN8- prefix). Texts are one byte per UTF-16 code unit (the editors' indexes are code-unit indexes) and
*> every glyph advance is one uniform number (the fixture advance of section 8; the real advances are 12 section 5.10 and 14 section 10.3).
*> Flags are 0 or 1. The page editor state is MN8-ED (MN8ED.cpy, section 2.1) and its display lines MN8-LINES (MN8LINES.cpy). The live screens,
*> the clipboard and the packets themselves belong to the client and the server; these programs hold the rules.
*>
*>   MN8-OPENGUI, -OPENBOOK, -OPENSIGN, -CLOSE (1); MN8-ALLOWED, -FILTER, -WRAP, -LINECOUNT, -LINEAT, -SETVALUE, -INSERT, -PREVWORD, -NEXTWORD,
*>   -SEEK, -INDEXAT, -MODS, -KEY, -CLICK, -HILITE, -CARET, -BOXSIZE (2)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-OPENGUI.
*> USING side (1 client, 2 server), stack has writable_book_content, stack has written_book_content, action out:
*> 0 nothing, 1 the client pushes BookEditScreen, 2 the server sends Open Book (1.1 steps 1 and 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIDE                 BINARY-LONG.
 01 L-WRITABLE             BINARY-LONG.
 01 L-WRITTEN              BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-SIDE L-WRITABLE L-WRITTEN L-ACTION.
    MOVE 0 TO L-ACTION
    IF L-SIDE = 1 AND L-WRITABLE = 1
        MOVE 1 TO L-ACTION
    END-IF
    IF L-SIDE = 2 AND L-WRITTEN = 1
        MOVE 2 TO L-ACTION
    END-IF
    GOBACK.
 END PROGRAM MN8-OPENGUI.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-OPENBOOK.
*> USING written content present, writable content present, source out (1 pages as text, 2 literal pages, 0 nothing opens) (1.1, handleOpenBook).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-WRITTEN              BINARY-LONG.
 01 L-WRITABLE             BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-WRITTEN L-WRITABLE L-SOURCE.
    EVALUATE TRUE
        WHEN L-WRITTEN = 1
            MOVE 1 TO L-SOURCE
        WHEN L-WRITABLE = 1
            MOVE 2 TO L-SOURCE
        WHEN OTHER
            MOVE 0 TO L-SOURCE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN8-OPENBOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-OPENSIGN.
*> USING block entity is a sign, it is a hanging sign, screen out (0 none, 1 SignEditScreen, 2 HangingSignEditScreen) (1.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIGN                 BINARY-LONG.
 01 L-HANGING              BINARY-LONG.
 01 L-SCREEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-SIGN L-HANGING L-SCREEN.
    EVALUATE TRUE
        WHEN L-SIGN = 0
            MOVE 0 TO L-SCREEN
        WHEN L-HANGING = 1
            MOVE 2 TO L-SCREEN
        WHEN OTHER
            MOVE 1 TO L-SCREEN
    END-EVALUATE
    GOBACK.
 END PROGRAM MN8-OPENSIGN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-CLOSE.
*> USING screen (1 book edit, 2 book sign, 3 sign edit), how it closed (1 Done or Sign and Close, 2 Enter in the title field, 3 Escape,
*> 4 Cancel or any other removal), packet id out (0 none, 24 = 0x18 Edit Book, 62 = 0x3E Sign Update), title present out (1 section 1 table).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-HOW                  BINARY-LONG.
 01 L-PACKET               BINARY-LONG.
 01 L-TITLE                BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-HOW L-PACKET L-TITLE.
    MOVE 0 TO L-PACKET L-TITLE
    EVALUATE TRUE
        WHEN L-SCREEN = 1 AND L-HOW = 1
            MOVE 24 TO L-PACKET
        WHEN L-SCREEN = 2 AND (L-HOW = 1 OR L-HOW = 2)
            MOVE 24 TO L-PACKET
            MOVE 1 TO L-TITLE
        WHEN L-SCREEN = 3
            MOVE 62 TO L-PACKET
    END-EVALUATE
    GOBACK.
 END PROGRAM MN8-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-ALLOWED.
*> USING code point, allowed out: an allowed chat character is a code point of 32 or more that is not 127 and not 167 (2.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CP                   BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CP L-OK.
    MOVE 0 TO L-OK
    IF L-CP >= 32 AND L-CP NOT = 127 AND L-CP NOT = 167
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN8-ALLOWED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-FILTER.
*> USING text, length, keep line feeds (1 page editor, 0 single-line fields), filtered text out (spaces first), its length out (2.2 filterText).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-C                    BINARY-LONG.
 01 W-OK                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN                   PIC X(2000).
 01 L-INLEN                BINARY-LONG.
 01 L-NL                   BINARY-LONG.
 01 L-OUT                  PIC X(2000).
 01 L-OUTLEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-IN L-INLEN L-NL L-OUT L-OUTLEN.
    MOVE SPACES TO L-OUT
    MOVE 0 TO L-OUTLEN
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > L-INLEN
        COMPUTE W-C = FUNCTION ORD(L-IN(W-I:1)) - 1
        CALL "MN8-ALLOWED" USING W-C W-OK
        IF W-C = 10 AND L-NL = 1
            MOVE 1 TO W-OK
        END-IF
        IF W-OK = 1
            ADD 1 TO L-OUTLEN
            MOVE L-IN(W-I:1) TO L-OUT(L-OUTLEN:1)
        END-IF
    END-PERFORM
    GOBACK.
 END PROGRAM MN8-FILTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-WRAP.
*> USING MN8-ED, MN8-LINES, line count out: the display lines of the text (2.3 StringSplitter.splitLines with the line break finder, uniform advance).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-START                BINARY-LONG.
 01 W-I                    BINARY-LONG.
 01 W-IDX                  BINARY-LONG.
 01 W-W                    BINARY-LONG.
 01 W-LIM                  BINARY-LONG.
 01 W-LAST                 BINARY-LONG.
 01 W-BRK                  BINARY-LONG.
 01 W-NZ                   BINARY-LONG.
 01 W-CH                   PIC X.
 LINKAGE SECTION.
 COPY MN8ED.
 COPY MN8LINES.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED MN8-LINES L-COUNT.
    MOVE 0 TO L-COUNT
    IF MN8-LEN = 0
        MOVE 1 TO L-COUNT
        MOVE 0 TO MN8-LB(1) MN8-LE(1)
        GOBACK
    END-IF
    COMPUTE W-LIM = FUNCTION MAX(MN8-WIDTH, 1)
    MOVE 0 TO W-START
    PERFORM UNTIL W-START >= MN8-LEN
        MOVE W-START TO W-I
        MOVE 0 TO W-W W-NZ
        MOVE -1 TO W-LAST W-BRK
        PERFORM UNTIL W-I >= MN8-LEN OR W-BRK >= 0
            COMPUTE W-IDX = W-I + 1
            MOVE MN8-TEXT(W-IDX:1) TO W-CH
            IF W-CH = X"0A"
                MOVE W-I TO W-BRK
            ELSE
                IF W-CH = SPACE
                    MOVE W-I TO W-LAST
                END-IF
                ADD MN8-ADV TO W-W
                IF W-NZ = 1 AND W-W > W-LIM
                    IF W-LAST >= 0
                        MOVE W-LAST TO W-BRK
                    ELSE
                        MOVE W-I TO W-BRK
                    END-IF
                END-IF
                IF MN8-ADV > 0
                    MOVE 1 TO W-NZ
                END-IF
                ADD 1 TO W-I
            END-IF
        END-PERFORM
        ADD 1 TO L-COUNT
        MOVE W-START TO MN8-LB(L-COUNT)
        IF W-BRK < 0
            MOVE MN8-LEN TO MN8-LE(L-COUNT) W-START
        ELSE
            MOVE W-BRK TO MN8-LE(L-COUNT)
            COMPUTE W-IDX = W-BRK + 1
            IF MN8-TEXT(W-IDX:1) = SPACE OR MN8-TEXT(W-IDX:1) = X"0A"
                COMPUTE W-START = W-BRK + 1
            ELSE
                MOVE W-BRK TO W-START
            END-IF
        END-IF
    END-PERFORM
    IF MN8-TEXT(MN8-LEN:1) = X"0A"
        ADD 1 TO L-COUNT
        MOVE MN8-LEN TO MN8-LB(L-COUNT) MN8-LE(L-COUNT)
    END-IF
    GOBACK.
 END PROGRAM MN8-WRAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-LINECOUNT.
*> USING MN8-ED, display line count out, overflow line count out, ends with a terminator out (2.4 overflowsLineLimit: the split lines plus 1
*> when the page ends in LF, VT, FF, CR or U+0085; only a line feed adds the extra display view).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MN8LINES REPLACING LEADING ==MN8-== BY ==W-==.
 01 W-LAST                 BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-DISPLAY              BINARY-LONG.
 01 L-OVER                 BINARY-LONG.
 01 L-ENDNL                BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-DISPLAY L-OVER L-ENDNL.
    CALL "MN8-WRAP" USING MN8-ED W-LINES L-DISPLAY
    MOVE L-DISPLAY TO L-OVER
    MOVE 0 TO L-ENDNL
    IF MN8-LEN > 0
        COMPUTE W-LAST = FUNCTION ORD(MN8-TEXT(MN8-LEN:1)) - 1
        IF W-LAST = 10
            SUBTRACT 1 FROM L-OVER
        END-IF
        IF W-LAST = 10 OR W-LAST = 11 OR W-LAST = 12 OR W-LAST = 13 OR W-LAST = 133
            MOVE 1 TO L-ENDNL
            ADD 1 TO L-OVER
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN8-LINECOUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-LINEAT.
*> USING MN8-ED, cursor, line out (0 based: the first display line with begin <= cursor <= end), its begin and end out (2.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MN8LINES REPLACING LEADING ==MN8-== BY ==W-==.
 01 W-COUNT                BINARY-LONG.
 01 W-J                    BINARY-LONG.
 01 W-FOUND                BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-CURSOR               BINARY-LONG.
 01 L-LINE                 BINARY-LONG.
 01 L-BEGIN                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-CURSOR L-LINE L-BEGIN L-END.
    CALL "MN8-WRAP" USING MN8-ED W-LINES W-COUNT
    MOVE W-COUNT TO W-FOUND
    PERFORM VARYING W-J FROM W-COUNT BY -1 UNTIL W-J < 1
        IF W-LB(W-J) <= L-CURSOR AND L-CURSOR <= W-LE(W-J)
            MOVE W-J TO W-FOUND
        END-IF
    END-PERFORM
    COMPUTE L-LINE = W-FOUND - 1
    MOVE W-LB(W-FOUND) TO L-BEGIN
    MOVE W-LE(W-FOUND) TO L-END
    GOBACK.
 END PROGRAM MN8-LINEAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SETVALUE.
*> USING MN8-ED, text, its length, force: the text is cut to the character limit; without force a text over the line limit is ignored; the
*> cursor and anchor go to the end; MN8-CHANGED is 1 when the text was stored (2.4 setValue).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MN8ED REPLACING LEADING ==MN8-== BY ==C-==.
 01 W-N                    BINARY-LONG.
 01 W-D                    BINARY-LONG.
 01 W-O                    BINARY-LONG.
 01 W-E                    BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-IN                   PIC X(2000).
 01 L-INLEN                BINARY-LONG.
 01 L-FORCE                BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-IN L-INLEN L-FORCE.
    MOVE 0 TO MN8-CHANGED
    MOVE L-INLEN TO W-N
    IF W-N > MN8-CHARLIM
        MOVE MN8-CHARLIM TO W-N
    END-IF
    MOVE SPACES TO C-TEXT
    IF W-N > 0
        MOVE L-IN(1:W-N) TO C-TEXT(1:W-N)
    END-IF
    MOVE W-N TO C-LEN
    MOVE MN8-WIDTH TO C-WIDTH
    MOVE MN8-ADV TO C-ADV
    IF L-FORCE = 0
        CALL "MN8-LINECOUNT" USING C-ED W-D W-O W-E
        IF W-O > MN8-LINELIM
            GOBACK
        END-IF
    END-IF
    MOVE C-TEXT TO MN8-TEXT
    MOVE W-N TO MN8-LEN MN8-CUR MN8-ANC
    MOVE 1 TO MN8-CHANGED
    GOBACK.
 END PROGRAM MN8-SETVALUE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-INSERT.
*> USING MN8-ED, inserted text, its length: 2.4 insert. An empty raw string with nothing selected does nothing; the text is filtered, cut to the
*> room left in the whole text (the selection is not credited), replaces the selection, and is rejected whole when the result would overflow
*> the line limit; otherwise the cursor and anchor go after it and MN8-CHANGED is 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MN8ED REPLACING LEADING ==MN8-== BY ==C-==.
 01 W-F                    PIC X(2000).
 01 W-FLEN                 BINARY-LONG.
 01 W-ONE                  BINARY-LONG VALUE 1.
 01 W-ROOM                 BINARY-LONG.
 01 W-A                    BINARY-LONG.
 01 W-B                    BINARY-LONG.
 01 W-TAIL                 BINARY-LONG.
 01 W-P                    BINARY-LONG.
 01 W-D                    BINARY-LONG.
 01 W-O                    BINARY-LONG.
 01 W-E                    BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-IN                   PIC X(2000).
 01 L-INLEN                BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-IN L-INLEN.
    MOVE 0 TO MN8-CHANGED
    IF L-INLEN = 0 AND MN8-CUR = MN8-ANC
        GOBACK
    END-IF
    CALL "MN8-FILTER" USING L-IN L-INLEN W-ONE W-F W-FLEN
    COMPUTE W-ROOM = FUNCTION MAX(MN8-CHARLIM - MN8-LEN, 0)
    IF W-FLEN > W-ROOM
        MOVE W-ROOM TO W-FLEN
    END-IF
    COMPUTE W-A = FUNCTION MIN(MN8-CUR, MN8-ANC)
    COMPUTE W-B = FUNCTION MAX(MN8-CUR, MN8-ANC)
    MOVE SPACES TO C-TEXT
    IF W-A > 0
        MOVE MN8-TEXT(1:W-A) TO C-TEXT(1:W-A)
    END-IF
    COMPUTE W-P = W-A + 1
    IF W-FLEN > 0
        MOVE W-F(1:W-FLEN) TO C-TEXT(W-P:W-FLEN)
    END-IF
    COMPUTE W-TAIL = MN8-LEN - W-B
    COMPUTE W-P = W-A + W-FLEN + 1
    IF W-TAIL > 0
        COMPUTE W-B = W-B + 1
        MOVE MN8-TEXT(W-B:W-TAIL) TO C-TEXT(W-P:W-TAIL)
    END-IF
    COMPUTE C-LEN = W-A + W-FLEN + W-TAIL
    MOVE MN8-WIDTH TO C-WIDTH
    MOVE MN8-ADV TO C-ADV
    CALL "MN8-LINECOUNT" USING C-ED W-D W-O W-E
    IF W-O > MN8-LINELIM
        GOBACK
    END-IF
    MOVE C-TEXT TO MN8-TEXT
    MOVE C-LEN TO MN8-LEN
    COMPUTE MN8-CUR = W-A + W-FLEN
    MOVE MN8-CUR TO MN8-ANC
    MOVE 1 TO MN8-CHANGED
    GOBACK.
 END PROGRAM MN8-INSERT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-ISWS.
*> USING code unit, flag out: Java Character.isWhitespace for a one-byte code unit (9 to 13, 28 to 31, 32) (2.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-FLAG.
    MOVE 0 TO L-FLAG
    IF (L-CODE >= 9 AND L-CODE <= 13) OR (L-CODE >= 28 AND L-CODE <= 32)
        MOVE 1 TO L-FLAG
    END-IF
    GOBACK.
 END PROGRAM MN8-ISWS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SKIP.
*> USING MN8-ED, position (in and out, 0 based), direction (-1 back, +1 forward), class wanted (1 whitespace, 0 not): steps while the unit
*> passed over has that class (2.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-GO                   BINARY-LONG.
 01 W-LOOK                 BINARY-LONG.
 01 W-CODE                 BINARY-LONG.
 01 W-F                    BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-POS                  BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-WANT                 BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-POS L-DIR L-WANT.
    MOVE 1 TO W-GO
    PERFORM UNTIL W-GO = 0
        IF L-DIR < 0
            MOVE L-POS TO W-LOOK
        ELSE
            COMPUTE W-LOOK = L-POS + 1
        END-IF
        IF W-LOOK < 1 OR W-LOOK > MN8-LEN
            MOVE 0 TO W-GO
        ELSE
            COMPUTE W-CODE = FUNCTION ORD(MN8-TEXT(W-LOOK:1)) - 1
            CALL "MN8-ISWS" USING W-CODE W-F
            IF W-F = L-WANT
                ADD L-DIR TO L-POS
            ELSE
                MOVE 0 TO W-GO
            END-IF
        END-IF
    END-PERFORM
    GOBACK.
 END PROGRAM MN8-SKIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-PREVWORD.
*> USING MN8-ED, cursor, begin out, end out: the previous word view (2.6). From the cursor clamped to the last index step back over whitespace
*> then over non-whitespace; the word ends at the next whitespace or the end. Empty text gives 0, 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-NEG                  BINARY-LONG VALUE -1.
 01 W-POS                  BINARY-LONG VALUE 1.
 01 W-ZERO                 BINARY-LONG VALUE 0.
 01 W-ONE                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-POS                  BINARY-LONG.
 01 L-BEGIN                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-POS L-BEGIN L-END.
    MOVE 0 TO L-BEGIN L-END
    IF MN8-LEN = 0
        GOBACK
    END-IF
    COMPUTE W-I = FUNCTION MIN(FUNCTION MAX(L-POS, 0), MN8-LEN - 1)
    CALL "MN8-SKIP" USING MN8-ED W-I W-NEG W-ONE
    CALL "MN8-SKIP" USING MN8-ED W-I W-NEG W-ZERO
    MOVE W-I TO L-BEGIN L-END
    CALL "MN8-SKIP" USING MN8-ED L-END W-POS W-ZERO
    GOBACK.
 END PROGRAM MN8-PREVWORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-NEXTWORD.
*> USING MN8-ED, cursor, position out: from the cursor clamped to the last index step forward over non-whitespace then over whitespace (2.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-POS                  BINARY-LONG VALUE 1.
 01 W-ZERO                 BINARY-LONG VALUE 0.
 01 W-ONE                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-CURSOR               BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-CURSOR L-NEXT.
    MOVE 0 TO L-NEXT
    IF MN8-LEN = 0
        GOBACK
    END-IF
    COMPUTE L-NEXT = FUNCTION MIN(FUNCTION MAX(L-CURSOR, 0), MN8-LEN - 1)
    CALL "MN8-SKIP" USING MN8-ED L-NEXT W-POS W-ZERO
    CALL "MN8-SKIP" USING MN8-ED L-NEXT W-POS W-ONE
    GOBACK.
 END PROGRAM MN8-NEXTWORD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-INDEXAT.
*> USING MN8-ED, line begin, line end, width budget, characters out: plainIndexAtWidth (2.7). Each advance is taken from the budget; the prefix
*> ends before the first character that makes it negative (no rounding to the nearest boundary).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-B                    BINARY-LONG.
 01 W-SPAN                 BINARY-LONG.
 01 W-GO                   BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-BEGIN                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-BUDGET               BINARY-LONG.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-BEGIN L-END L-BUDGET L-N.
    MOVE 0 TO L-N
    MOVE L-BUDGET TO W-B
    COMPUTE W-SPAN = L-END - L-BEGIN
    MOVE 1 TO W-GO
    PERFORM UNTIL W-GO = 0 OR L-N >= W-SPAN
        SUBTRACT MN8-ADV FROM W-B
        IF W-B < 0
            MOVE 0 TO W-GO
        ELSE
            ADD 1 TO L-N
        END-IF
    END-PERFORM
    GOBACK.
 END PROGRAM MN8-INDEXAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SEEK.
*> USING MN8-ED, dy (-1 up, 1 down): sets MN8-CUR to the nearest boundary at or before the pointer on the neighbouring display line; the target
*> is the width from the cursor's line start to the cursor plus the bias 2 (2.7 seekCursorLine). The first and last line clamp.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MN8LINES REPLACING LEADING ==MN8-== BY ==W-==.
 01 W-COUNT                BINARY-LONG.
 01 W-LINE                 BINARY-LONG.
 01 W-LB0                  BINARY-LONG.
 01 W-LE0                  BINARY-LONG.
 01 W-J                    BINARY-LONG.
 01 W-TARGET               BINARY-LONG.
 01 W-N                    BINARY-LONG.
 01 W-BEGIN                BINARY-LONG.
 01 W-END                  BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-DY                   BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-DY.
    CALL "MN8-WRAP" USING MN8-ED W-LINES W-COUNT
    CALL "MN8-LINEAT" USING MN8-ED MN8-CUR W-LINE W-LB0 W-LE0
    COMPUTE W-TARGET = MN8-ADV * (MN8-CUR - W-LB0) + 2
    COMPUTE W-J = FUNCTION MIN(FUNCTION MAX(W-LINE + L-DY, 0), W-COUNT - 1) + 1
    MOVE W-LB(W-J) TO W-BEGIN
    MOVE W-LE(W-J) TO W-END
    CALL "MN8-INDEXAT" USING MN8-ED W-BEGIN W-END W-TARGET W-N
    COMPUTE MN8-CUR = W-BEGIN + W-N
    GOBACK.
 END PROGRAM MN8-SEEK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-MODS.
*> USING modifier word, macOS flag, shift out, edit shortcut out, alt out: Shift is the mask 3, Alt 768, the edit shortcut 192 (Control) or on
*> macOS 3072 (Command) (2.5; SDL modifier bits). A mask is down when any of its bits is set.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-Q                    BINARY-LONG.
 01 W-D                    BINARY-LONG.
 01 W-R                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-MODS                 BINARY-LONG.
 01 L-MAC                  BINARY-LONG.
 01 L-SHIFT                BINARY-LONG.
 01 L-CTRL                 BINARY-LONG.
 01 L-ALT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MODS L-MAC L-SHIFT L-CTRL L-ALT.
    MOVE 0 TO L-SHIFT L-CTRL L-ALT
    DIVIDE L-MODS BY 4 GIVING W-Q REMAINDER W-R
    IF W-R > 0
        MOVE 1 TO L-SHIFT
    END-IF
    DIVIDE L-MODS BY 64 GIVING W-Q
    DIVIDE W-Q BY 4 GIVING W-D REMAINDER W-R
    IF W-R > 0 AND L-MAC = 0
        MOVE 1 TO L-CTRL
    END-IF
    DIVIDE L-MODS BY 256 GIVING W-Q
    DIVIDE W-Q BY 4 GIVING W-D REMAINDER W-R
    IF W-R > 0
        MOVE 1 TO L-ALT
    END-IF
    DIVIDE L-MODS BY 1024 GIVING W-Q
    DIVIDE W-Q BY 4 GIVING W-D REMAINDER W-R
    IF W-R > 0 AND L-MAC = 1
        MOVE 1 TO L-CTRL
    END-IF
    GOBACK.
 END PROGRAM MN8-MODS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-COPYSEL.
*> USING MN8-ED: the clipboard becomes the selected text (the empty string when nothing is selected) (2.5 copy and cut).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-A                    BINARY-LONG.
 01 W-N                    BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 PROCEDURE DIVISION USING MN8-ED.
    COMPUTE W-A = FUNCTION MIN(MN8-CUR, MN8-ANC)
    COMPUTE W-N = FUNCTION MAX(MN8-CUR, MN8-ANC) - W-A
    MOVE SPACES TO MN8-CLIP
    MOVE W-N TO MN8-CLIPLEN
    IF W-N > 0
        ADD 1 TO W-A
        MOVE MN8-TEXT(W-A:W-N) TO MN8-CLIP(1:W-N)
    END-IF
    GOBACK.
 END PROGRAM MN8-COPYSEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-DELETE.
*> USING MN8-ED, n: deleteText(n). With nothing selected the anchor first goes to clamp(cursor + n, 0, length), then the empty string is
*> inserted, so the span between the cursor and the anchor is removed; at the end of the text there is no span (2.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-IN                   PIC X(2000).
 01 W-INLEN                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-N.
    IF MN8-CUR = MN8-ANC
        COMPUTE MN8-ANC = FUNCTION MIN(FUNCTION MAX(MN8-CUR + L-N, 0), MN8-LEN)
    END-IF
    MOVE SPACES TO W-IN
    CALL "MN8-INSERT" USING MN8-ED W-IN W-INLEN
    GOBACK.
 END PROGRAM MN8-DELETE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-KEY.
*> USING MN8-ED, keycode, modifier word, macOS flag, handled out: MultilineTextField.keyPressed (2.5). Every key first sets selecting to Shift;
*> the first matching rule wins; motion keys keep the anchor only while Shift is down.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-SHIFT                BINARY-LONG.
 01 W-CTRL                 BINARY-LONG.
 01 W-ALT                  BINARY-LONG.
 01 W-PLAIN                BINARY-LONG.
 01 W-MOVED                BINARY-LONG.
 01 W-NEW                  BINARY-LONG.
 01 W-LINE                 BINARY-LONG.
 01 W-LB0                  BINARY-LONG.
 01 W-LE0                  BINARY-LONG.
 01 W-DY                   BINARY-LONG.
 01 W-BEGIN                BINARY-LONG.
 01 W-END                  BINARY-LONG.
 01 W-IN                   PIC X(2000).
 01 W-INLEN                BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-KEY                  BINARY-LONG.
 01 L-MODS                 BINARY-LONG.
 01 L-MAC                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-KEY L-MODS L-MAC L-HANDLED.
    CALL "MN8-MODS" USING L-MODS L-MAC W-SHIFT W-CTRL W-ALT
    MOVE 0 TO W-PLAIN W-MOVED
    IF W-CTRL = 1 AND W-SHIFT = 0 AND W-ALT = 0
        MOVE 1 TO W-PLAIN
    END-IF
    MOVE 1 TO L-HANDLED
    EVALUATE TRUE
        WHEN L-KEY = 97 AND W-PLAIN = 1
            MOVE MN8-LEN TO MN8-CUR
            MOVE 0 TO MN8-ANC
        WHEN L-KEY = 99 AND W-PLAIN = 1
            CALL "MN8-COPYSEL" USING MN8-ED
        WHEN L-KEY = 118 AND W-PLAIN = 1
            MOVE SPACES TO W-IN
            MOVE MN8-CLIP(1:1100) TO W-IN(1:1100)
            MOVE MN8-CLIPLEN TO W-INLEN
            CALL "MN8-INSERT" USING MN8-ED W-IN W-INLEN
        WHEN L-KEY = 120 AND W-PLAIN = 1
            CALL "MN8-COPYSEL" USING MN8-ED
            MOVE SPACES TO W-IN
            MOVE 0 TO W-INLEN
            CALL "MN8-INSERT" USING MN8-ED W-IN W-INLEN
        WHEN L-KEY = 8
            MOVE -1 TO W-DY
            IF W-CTRL = 1
                CALL "MN8-PREVWORD" USING MN8-ED MN8-CUR W-BEGIN W-END
                COMPUTE W-DY = W-BEGIN - MN8-CUR
            END-IF
            CALL "MN8-DELETE" USING MN8-ED W-DY
        WHEN L-KEY = 127
            MOVE 1 TO W-DY
            IF W-CTRL = 1
                CALL "MN8-NEXTWORD" USING MN8-ED MN8-CUR W-NEW
                COMPUTE W-DY = W-NEW - MN8-CUR
            END-IF
            CALL "MN8-DELETE" USING MN8-ED W-DY
        WHEN L-KEY = 13 OR L-KEY = 1073741912
            MOVE SPACES TO W-IN
            MOVE X"0A" TO W-IN(1:1)
            MOVE 1 TO W-INLEN
            CALL "MN8-INSERT" USING MN8-ED W-IN W-INLEN
        WHEN L-KEY = 1073741904
            MOVE 1 TO W-MOVED
            IF W-CTRL = 1
                CALL "MN8-PREVWORD" USING MN8-ED MN8-CUR W-BEGIN W-END
                MOVE W-BEGIN TO W-NEW
            ELSE
                COMPUTE W-NEW = FUNCTION MAX(MN8-CUR - 1, 0)
            END-IF
        WHEN L-KEY = 1073741903
            MOVE 1 TO W-MOVED
            IF W-CTRL = 1
                CALL "MN8-NEXTWORD" USING MN8-ED MN8-CUR W-NEW
            ELSE
                COMPUTE W-NEW = FUNCTION MIN(MN8-CUR + 1, MN8-LEN)
            END-IF
        WHEN L-KEY = 1073741906 OR L-KEY = 1073741905
            IF W-CTRL = 0
                MOVE 1 TO W-MOVED
                MOVE 1 TO W-DY
                IF L-KEY = 1073741906
                    MOVE -1 TO W-DY
                END-IF
                CALL "MN8-SEEK" USING MN8-ED W-DY
                MOVE MN8-CUR TO W-NEW
            END-IF
        WHEN L-KEY = 1073741898
            MOVE 1 TO W-MOVED
            MOVE 0 TO W-NEW
            IF W-CTRL = 0
                CALL "MN8-LINEAT" USING MN8-ED MN8-CUR W-LINE W-NEW W-LE0
            END-IF
        WHEN L-KEY = 1073741901
            MOVE 1 TO W-MOVED
            MOVE MN8-LEN TO W-NEW
            IF W-CTRL = 0
                CALL "MN8-LINEAT" USING MN8-ED MN8-CUR W-LINE W-LB0 W-NEW
            END-IF
        WHEN L-KEY = 1073741899
            MOVE 1 TO W-MOVED
            MOVE 0 TO W-NEW
        WHEN L-KEY = 1073741902
            MOVE 1 TO W-MOVED
            MOVE MN8-LEN TO W-NEW
        WHEN OTHER
            MOVE 0 TO L-HANDLED
    END-EVALUATE
    IF W-MOVED = 1
        MOVE W-NEW TO MN8-CUR
        IF W-SHIFT = 0
            MOVE W-NEW TO MN8-ANC
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN8-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-CLICK.
*> USING MN8-ED, mouse x, mouse y (doubles), box x, box y, scroll, mode (1 click, 2 double click, 3 drag), Shift: 2.7 mouse. The pointer
*> position is x = floor(mouseX - boxX - 4), y = mouseY - boxY - 4 + scroll, line floor(y / 9) clamped; the cursor goes to the boundary at or
*> before x on that line. A click keeps the anchor only with Shift, a drag always keeps it, a double click selects the word at the cursor.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MN8LINES REPLACING LEADING ==MN8-== BY ==W-==.
 01 W-COUNT                BINARY-LONG.
 01 W-X                    BINARY-LONG.
 01 W-Y                    FLOAT-LONG.
 01 W-LINE                 BINARY-LONG.
 01 W-BEGIN                BINARY-LONG.
 01 W-END                  BINARY-LONG.
 01 W-N                    BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-MX                   FLOAT-LONG.
 01 L-MY                   FLOAT-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-SCROLL               BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 01 L-SHIFT                BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-MX L-MY L-BX L-BY L-SCROLL L-MODE L-SHIFT.
    IF L-MODE = 2
        CALL "MN8-PREVWORD" USING MN8-ED MN8-CUR W-BEGIN W-END
        MOVE W-BEGIN TO MN8-ANC
        MOVE W-END TO MN8-CUR
        GOBACK
    END-IF
    CALL "MN8-WRAP" USING MN8-ED W-LINES W-COUNT
    COMPUTE W-X = FUNCTION INTEGER(L-MX - L-BX - 4)
    COMPUTE W-Y = L-MY - L-BY - 4 + L-SCROLL
    COMPUTE W-LINE = FUNCTION INTEGER(W-Y / 9)
    COMPUTE W-LINE = FUNCTION MIN(FUNCTION MAX(W-LINE, 0), W-COUNT - 1) + 1
    MOVE W-LB(W-LINE) TO W-BEGIN
    MOVE W-LE(W-LINE) TO W-END
    CALL "MN8-INDEXAT" USING MN8-ED W-BEGIN W-END W-X W-N
    COMPUTE MN8-CUR = W-BEGIN + W-N
    IF L-MODE = 1 AND L-SHIFT = 0
        MOVE MN8-CUR TO MN8-ANC
    END-IF
    GOBACK.
 END PROGRAM MN8-CLICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-HILITE.
*> USING MN8-ED, display line (0 based), box x, box width, intersects out, x0 out, x1 out: 2.8 step 3. The selection [sb, se] reaches a line
*> when sb <= line end and line begin <= se; x0 = boxX + 4 + width(line begin .. max(sb, begin)); x1 = boxX + 4 + (boxWidth - 4) when the
*> selection goes past the line end, else boxX + 4 + width(line begin .. se).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MN8LINES REPLACING LEADING ==MN8-== BY ==W-==.
 01 W-COUNT                BINARY-LONG.
 01 W-J                    BINARY-LONG.
 01 W-SB                   BINARY-LONG.
 01 W-SE                   BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-LINE                 BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BW                   BINARY-LONG.
 01 L-INTER                BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-LINE L-BX L-BW L-INTER L-X0 L-X1.
    MOVE 0 TO L-INTER L-X0 L-X1
    CALL "MN8-WRAP" USING MN8-ED W-LINES W-COUNT
    COMPUTE W-J = L-LINE + 1
    COMPUTE W-SB = FUNCTION MIN(MN8-CUR, MN8-ANC)
    COMPUTE W-SE = FUNCTION MAX(MN8-CUR, MN8-ANC)
    IF W-SB <= W-LE(W-J) AND W-LB(W-J) <= W-SE
        MOVE 1 TO L-INTER
        COMPUTE L-X0 = L-BX + 4 + MN8-ADV * (FUNCTION MAX(W-SB, W-LB(W-J)) - W-LB(W-J))
        IF W-SE > W-LE(W-J)
            COMPUTE L-X1 = L-BX + 4 + (L-BW - 4)
        ELSE
            COMPUTE L-X1 = L-BX + 4 + MN8-ADV * (W-SE - W-LB(W-J))
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN8-HILITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-CARET.
*> USING MN8-ED, focused, milliseconds since the box gained focus, box x, box y, kind out (0 none, 1 insert bar, 2 append underscore), x out,
*> y out (the top of the cursor's line): 2.8 step 4. Shown only while focused and floor(t / 300) is even; the append cursor sits at the end
*> of the last display line, the bar at the cursor of its own line.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MN8LINES REPLACING LEADING ==MN8-== BY ==W-==.
 01 W-COUNT                BINARY-LONG.
 01 W-Q                    BINARY-LONG.
 01 W-D                    BINARY-LONG.
 01 W-R                    BINARY-LONG.
 01 W-LINE                 BINARY-LONG.
 01 W-LB0                  BINARY-LONG.
 01 W-LE0                  BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8ED.
 01 L-FOCUS                BINARY-LONG.
 01 L-MS                   BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING MN8-ED L-FOCUS L-MS L-BX L-BY L-KIND L-X L-Y.
    MOVE 0 TO L-KIND L-X L-Y
    DIVIDE L-MS BY 300 GIVING W-Q
    DIVIDE W-Q BY 2 GIVING W-D REMAINDER W-R
    IF L-FOCUS = 1 AND W-R = 0
        IF MN8-CUR < MN8-LEN
            MOVE 1 TO L-KIND
            CALL "MN8-LINEAT" USING MN8-ED MN8-CUR W-LINE W-LB0 W-LE0
        ELSE
            MOVE 2 TO L-KIND
            CALL "MN8-WRAP" USING MN8-ED W-LINES W-COUNT
            COMPUTE W-LINE = W-COUNT - 1
            MOVE W-LB(W-COUNT) TO W-LB0
        END-IF
        COMPUTE L-X = L-BX + 4 + MN8-ADV * (MN8-CUR - W-LB0)
        COMPUTE L-Y = L-BY + 4 + 9 * W-LINE
    END-IF
    GOBACK.
 END PROGRAM MN8-CARET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-BOXSIZE.
*> USING display line count, inner text height out (9 per line), content height out (plus 8), scroll bar shown out: 2.8 step 5 (the page
*> box is 122 x 134 with wrap width 114; the content height is compared with the box height 134).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LINES                BINARY-LONG.
 01 L-INNER                BINARY-LONG.
 01 L-CONTENT              BINARY-LONG.
 01 L-BAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-LINES L-INNER L-CONTENT L-BAR.
    COMPUTE L-INNER = 9 * L-LINES
    COMPUTE L-CONTENT = L-INNER + 8
    MOVE 0 TO L-BAR
    IF L-CONTENT > 134
        MOVE 1 TO L-BAR
    END-IF
    GOBACK.
 END PROGRAM MN8-BOXSIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-BOOKRECT.
*> USING scaled window width, element (1 background, 2 page box, 3 back button, 4 forward button, 5 Sign button, 6 Done button, 7 page
*> indicator, whose x is its right edge), x, y, width, height out (3.2). L = (W - 192) / 2 and T = 2, with Java integer division.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-L                    BINARY-LONG.
 01 W-H                    BINARY-LONG.
 01 W-T                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-ELEM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-ELEM L-X L-Y L-WIDTH L-HEIGHT.
    COMPUTE W-L = (L-W - 192) / 2
    COMPUTE W-H = L-W / 2
    MOVE 0 TO L-WIDTH L-HEIGHT
    EVALUATE L-ELEM
        WHEN 1
            MOVE W-L TO L-X
            MOVE 2 TO L-Y
            MOVE 192 TO L-WIDTH L-HEIGHT
        WHEN 2
            COMPUTE W-T = (L-W - 114) / 2
            COMPUTE L-X = W-T - 8
            MOVE 28 TO L-Y
            MOVE 122 TO L-WIDTH
            MOVE 134 TO L-HEIGHT
        WHEN 3
            COMPUTE L-X = W-L + 43
            MOVE 159 TO L-Y
            MOVE 23 TO L-WIDTH
            MOVE 13 TO L-HEIGHT
        WHEN 4
            COMPUTE L-X = W-L + 116
            MOVE 159 TO L-Y
            MOVE 23 TO L-WIDTH
            MOVE 13 TO L-HEIGHT
        WHEN 5
            COMPUTE L-X = W-H - 100
            MOVE 196 TO L-Y
            MOVE 98 TO L-WIDTH
            MOVE 20 TO L-HEIGHT
        WHEN 6
            COMPUTE L-X = W-H + 2
            MOVE 196 TO L-Y
            MOVE 98 TO L-WIDTH
            MOVE 20 TO L-HEIGHT
        WHEN OTHER
            COMPUTE L-X = W-L + 148
            MOVE 18 TO L-Y
    END-EVALUATE
    GOBACK.
 END PROGRAM MN8-BOOKRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-BOOKCONST.
*> USING index, value out: the constants of 3.1 and 3.2 (1 text width, 2 text height, 3 image width, 4 image height, 5 texture size, 6 menu
*> button size, 7 margin, 8 page button y, 9 back x, 10 forward x, 11 indicator x offset, 12 indicator y offset, 13 character limit, 14 line
*> limit, 15 page cap, 16 and 17 page button size, 18 turn volume in hundredths, 19 turn pitch in hundredths, 20 takes focus after a click,
*> 21 pauses, 22 in-game UI).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-VALUE.
    EVALUATE L-INDEX
        WHEN 1  MOVE 114 TO L-VALUE
        WHEN 2  MOVE 126 TO L-VALUE
        WHEN 3  MOVE 192 TO L-VALUE
        WHEN 4  MOVE 192 TO L-VALUE
        WHEN 5  MOVE 256 TO L-VALUE
        WHEN 6  MOVE 98 TO L-VALUE
        WHEN 7  MOVE 4 TO L-VALUE
        WHEN 8  MOVE 157 TO L-VALUE
        WHEN 9  MOVE 43 TO L-VALUE
        WHEN 10 MOVE 116 TO L-VALUE
        WHEN 11 MOVE 148 TO L-VALUE
        WHEN 12 MOVE 16 TO L-VALUE
        WHEN 13 MOVE 1024 TO L-VALUE
        WHEN 14 COMPUTE L-VALUE = 126 / 9
        WHEN 15 MOVE 100 TO L-VALUE
        WHEN 16 MOVE 23 TO L-VALUE
        WHEN 17 MOVE 13 TO L-VALUE
        WHEN 18 MOVE 25 TO L-VALUE
        WHEN 19 MOVE 100 TO L-VALUE
        WHEN 20 MOVE 0 TO L-VALUE
        WHEN 21 MOVE 1 TO L-VALUE
        WHEN OTHER MOVE 1 TO L-VALUE
    END-EVALUATE
    GOBACK.
 END PROGRAM MN8-BOOKCONST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-PAGEFWD.
*> USING current page, page count, new page out, new count out, appended out (3.3 step 5): move on; at the last page append an empty page
*> (refused at 100 pages) and move on when the index is then below the last page.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CUR                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-NEWCOUNT             BINARY-LONG.
 01 L-APPENDED             BINARY-LONG.
 PROCEDURE DIVISION USING L-CUR L-COUNT L-NEW L-NEWCOUNT L-APPENDED.
    MOVE L-CUR TO L-NEW
    MOVE L-COUNT TO L-NEWCOUNT
    MOVE 0 TO L-APPENDED
    IF L-CUR < L-COUNT - 1
        ADD 1 TO L-NEW
    ELSE
        IF L-COUNT < 100
            ADD 1 TO L-NEWCOUNT
            MOVE 1 TO L-APPENDED
        END-IF
        IF L-NEW < L-NEWCOUNT - 1
            ADD 1 TO L-NEW
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN8-PAGEFWD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-PAGEBACK.
*> USING current page, new page out, back button visible out (3.3 steps 3 and 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CUR                  BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 PROCEDURE DIVISION USING L-CUR L-NEW L-VISIBLE.
    MOVE L-CUR TO L-NEW
    IF L-NEW > 0
        SUBTRACT 1 FROM L-NEW
    END-IF
    MOVE 0 TO L-VISIBLE
    IF L-NEW > 0
        MOVE 1 TO L-VISIBLE
    END-IF
    GOBACK.
 END PROGRAM MN8-PAGEBACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-BOOKKEY.
*> USING keycode, action out (1 Page-up presses back, 2 Page-down presses forward, 0 the key goes on) (3.3 step 6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ACTION.
    MOVE 0 TO L-ACTION
    IF L-KEY = 1073741899
        MOVE 1 TO L-ACTION
    END-IF
    IF L-KEY = 1073741902
        MOVE 2 TO L-ACTION
    END-IF
    GOBACK.
 END PROGRAM MN8-BOOKKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-TABNEXT.
*> USING focus (1 page box, 2 back, 3 forward, 4 Sign, 5 Done), back button visible, Shift, next focus out: the Tab order of 3.3 step 6 in
*> creation order, skipping the hidden back button and wrapping around.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-ORDER.
    05 W-O                 BINARY-LONG OCCURS 5 TIMES.
 01 W-N                    BINARY-LONG.
 01 W-I                    BINARY-LONG.
 01 W-AT                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-FOCUS                BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 01 L-SHIFT                BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FOCUS L-VISIBLE L-SHIFT L-NEXT.
    MOVE 1 TO W-N
    MOVE 1 TO W-O(1)
    IF L-VISIBLE = 1
        ADD 1 TO W-N
        MOVE 2 TO W-O(W-N)
    END-IF
    ADD 1 TO W-N
    MOVE 3 TO W-O(W-N)
    ADD 1 TO W-N
    MOVE 4 TO W-O(W-N)
    ADD 1 TO W-N
    MOVE 5 TO W-O(W-N)
    MOVE 1 TO W-AT
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > W-N
        IF W-O(W-I) = L-FOCUS
            MOVE W-I TO W-AT
        END-IF
    END-PERFORM
    IF L-SHIFT = 1
        SUBTRACT 1 FROM W-AT
        IF W-AT < 1
            MOVE W-N TO W-AT
        END-IF
    ELSE
        ADD 1 TO W-AT
        IF W-AT > W-N
            MOVE 1 TO W-AT
        END-IF
    END-IF
    MOVE W-O(W-AT) TO L-NEXT
    GOBACK.
 END PROGRAM MN8-TABNEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SAVEPAGES.
*> USING page flags (one byte per page: E empty, anything else not empty), page count, pages kept out: Done erases trailing empty pages
*> from the end, stopping at the first non-empty one (3.3 step 9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PAGES                PIC X(100).
 01 L-COUNT                BINARY-LONG.
 01 L-KEPT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-PAGES L-COUNT L-KEPT.
    MOVE L-COUNT TO L-KEPT
    PERFORM UNTIL L-KEPT = 0
        IF L-PAGES(L-KEPT:1) = "E"
            SUBTRACT 1 FROM L-KEPT
        ELSE
            EXIT PERFORM
        END-IF
    END-PERFORM
    GOBACK.
 END PROGRAM MN8-SAVEPAGES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SLOTOF.
*> USING hand (0 main, 1 off), selected hotbar slot, slot out: the Slot of the Edit Book packet (3.3 step 10).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HAND                 BINARY-LONG.
 01 L-SELECTED             BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HAND L-SELECTED L-SLOT.
    MOVE L-SELECTED TO L-SLOT
    IF L-HAND = 1
        MOVE 40 TO L-SLOT
    END-IF
    GOBACK.
 END PROGRAM MN8-SLOTOF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-INDICATOR.
*> USING current page (0 based), page count, shown page out, shown count out: the arguments of book.pageIndicator (3.2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CUR                  BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-SHOWN                BINARY-LONG.
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-CUR L-COUNT L-SHOWN L-TOTAL.
    COMPUTE L-SHOWN = L-CUR + 1
    MOVE L-COUNT TO L-TOTAL
    GOBACK.
 END PROGRAM MN8-INDICATOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-PAGEBTN.
*> USING direction (1 forward, 2 back), hovered or focused, sprite out, narration label out (3.2 PageButton).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-HOVER                BINARY-LONG.
 01 L-SPRITE               PIC X(96).
 01 L-LABEL                PIC X(96).
 PROCEDURE DIVISION USING L-DIR L-HOVER L-SPRITE L-LABEL.
    MOVE SPACES TO L-SPRITE L-LABEL
    IF L-DIR = 1
        MOVE "widget/page_forward" TO L-SPRITE
        MOVE "book.page_button.next" TO L-LABEL
    ELSE
        MOVE "widget/page_backward" TO L-SPRITE
        MOVE "book.page_button.previous" TO L-LABEL
    END-IF
    IF L-HOVER = 1
        STRING FUNCTION TRIM(L-SPRITE) "_highlighted" DELIMITED BY SIZE INTO L-SPRITE
    END-IF
    GOBACK.
 END PROGRAM MN8-PAGEBTN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SCREENFLAGS.
*> USING screen (1 book edit, 2 book sign, 3 sign edit, 4 hanging sign edit), pauses out, in-game UI out, input captured out, closes on
*> Escape out (3.2, 4 behaviour 7, 6.2 step 7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCREEN               BINARY-LONG.
 01 L-PAUSE                BINARY-LONG.
 01 L-INGAME               BINARY-LONG.
 01 L-CAPTURED             BINARY-LONG.
 01 L-ESCAPE               BINARY-LONG.
 PROCEDURE DIVISION USING L-SCREEN L-PAUSE L-INGAME L-CAPTURED L-ESCAPE.
    MOVE 1 TO L-INGAME L-ESCAPE
    MOVE 0 TO L-PAUSE L-CAPTURED
    IF L-SCREEN < 3
        MOVE 1 TO L-PAUSE
    ELSE
        MOVE 1 TO L-CAPTURED
    END-IF
    GOBACK.
 END PROGRAM MN8-SCREENFLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNRECT.
*> USING window width, element (1 background, 2 Sign and Close, 3 Cancel, 4 title box, 5 warning text origin), x, y, width, height out (4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-L                    BINARY-LONG.
 01 W-H                    BINARY-LONG.
 01 W-T                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-ELEM                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-ELEM L-X L-Y L-WIDTH L-HEIGHT.
    COMPUTE W-L = (L-W - 192) / 2
    COMPUTE W-H = L-W / 2
    MOVE 0 TO L-HEIGHT
    EVALUATE L-ELEM
        WHEN 1
            MOVE W-L TO L-X
            MOVE 2 TO L-Y
            MOVE 192 TO L-WIDTH L-HEIGHT
        WHEN 2
            COMPUTE L-X = W-H - 100
            MOVE 196 TO L-Y
            MOVE 98 TO L-WIDTH
            MOVE 20 TO L-HEIGHT
        WHEN 3
            COMPUTE L-X = W-H + 2
            MOVE 196 TO L-Y
            MOVE 98 TO L-WIDTH
            MOVE 20 TO L-HEIGHT
        WHEN 4
            COMPUTE W-T = (L-W - 114) / 2
            COMPUTE L-X = W-T - 3
            MOVE 50 TO L-Y
            MOVE 114 TO L-WIDTH
            MOVE 20 TO L-HEIGHT
        WHEN OTHER
            COMPUTE L-X = W-L + 36
            MOVE 82 TO L-Y
            MOVE 114 TO L-WIDTH
    END-EVALUATE
    GOBACK.
 END PROGRAM MN8-SIGNRECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-LABELX.
*> USING window width, text width, label (1 Enter Book Title, 2 owner line), x out, y out: x = L + 36 + (114 - width) / 2 with Java division.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-L                    BINARY-LONG.
 01 W-H                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-TEXTW                BINARY-LONG.
 01 L-LABEL                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-TEXTW L-LABEL L-X L-Y.
    COMPUTE W-L = (L-W - 192) / 2
    COMPUTE W-H = (114 - L-TEXTW) / 2
    COMPUTE L-X = W-L + 36 + W-H
    MOVE 34 TO L-Y
    IF L-LABEL = 2
        MOVE 60 TO L-Y
    END-IF
    GOBACK.
 END PROGRAM MN8-LABELX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-ISSPACE.
*> USING code point, flag out: Character.isWhitespace or Character.isSpaceChar (9 to 13, 28 to 32, 160, 0x1680, 0x2000 to 0x200A, 0x2028,
*> 0x2029, 0x202F, 0x205F, 0x3000) (4 behaviour 1, StringUtil.isBlank).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CP                   BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CP L-FLAG.
    MOVE 0 TO L-FLAG
    IF (L-CP >= 9 AND L-CP <= 13) OR (L-CP >= 28 AND L-CP <= 32) OR L-CP = 160 OR L-CP = 5760
       OR (L-CP >= 8192 AND L-CP <= 8202) OR L-CP = 8232 OR L-CP = 8233 OR L-CP = 8239 OR L-CP = 8287 OR L-CP = 12288
        MOVE 1 TO L-FLAG
    END-IF
    GOBACK.
 END PROGRAM MN8-ISSPACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-ISBLANK.
*> USING table (element 1 the count, then the code points; up to 15), blank out: true for no characters or only whitespace and space
*> separators (4 behaviour 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-I                    BINARY-LONG.
 01 W-F                    BINARY-LONG.
 01 W-AT                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TAB.
    05 L-CP                BINARY-LONG OCCURS 16 TIMES.
 01 L-BLANK                BINARY-LONG.
 PROCEDURE DIVISION USING L-TAB L-BLANK.
    MOVE 1 TO L-BLANK
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > L-CP(1)
        COMPUTE W-AT = W-I + 1
        CALL "MN8-ISSPACE" USING L-CP(W-AT) W-F
        IF W-F = 0
            MOVE 0 TO L-BLANK
        END-IF
    END-PERFORM
    GOBACK.
 END PROGRAM MN8-ISBLANK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNACTIVE.
*> USING title table (as MN8-ISBLANK), active out: the Sign and Close button is active while the title is not blank (4 behaviour 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-BLANK                BINARY-LONG.
 LINKAGE SECTION.
 01 L-TAB.
    05 L-CP                BINARY-LONG OCCURS 16 TIMES.
 01 L-ACTIVE               BINARY-LONG.
 PROCEDURE DIVISION USING L-TAB L-ACTIVE.
    CALL "MN8-ISBLANK" USING L-TAB W-BLANK
    COMPUTE L-ACTIVE = 1 - W-BLANK
    GOBACK.
 END PROGRAM MN8-SIGNACTIVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-TRIM.
*> USING text, length, trimmed text out (spaces first), trimmed length out: String.trim removes every character up to U+0020 at both ends (4 behaviour 4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-A                    BINARY-LONG.
 01 W-B                    BINARY-LONG.
 01 W-C                    BINARY-LONG.
 01 W-GO                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN                   PIC X(2000).
 01 L-INLEN                BINARY-LONG.
 01 L-OUT                  PIC X(2000).
 01 L-OUTLEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-IN L-INLEN L-OUT L-OUTLEN.
    MOVE SPACES TO L-OUT
    MOVE 1 TO W-A
    MOVE L-INLEN TO W-B
    MOVE 1 TO W-GO
    PERFORM UNTIL W-GO = 0 OR W-A > W-B
        COMPUTE W-C = FUNCTION ORD(L-IN(W-A:1)) - 1
        IF W-C <= 32
            ADD 1 TO W-A
        ELSE
            MOVE 0 TO W-GO
        END-IF
    END-PERFORM
    MOVE 1 TO W-GO
    PERFORM UNTIL W-GO = 0 OR W-B < W-A
        COMPUTE W-C = FUNCTION ORD(L-IN(W-B:1)) - 1
        IF W-C <= 32
            SUBTRACT 1 FROM W-B
        ELSE
            MOVE 0 TO W-GO
        END-IF
    END-PERFORM
    COMPUTE L-OUTLEN = W-B - W-A + 1
    IF L-OUTLEN > 0
        MOVE L-IN(W-A:L-OUTLEN) TO L-OUT(1:L-OUTLEN)
    ELSE
        MOVE 0 TO L-OUTLEN
    END-IF
    GOBACK.
 END PROGRAM MN8-TRIM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-FIELDINS.
*> USING MN8-FLD, text, length: EditBox.insertText as the title box uses it. The selection is the replace range; the space left is the maximum
*> length minus the length plus the selected length; with none left nothing happens; the text is cleaned (no line feeds), cut to the space
*> left and spliced in, the cursor goes after it with no selection (4 behaviour 2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-F                    PIC X(2000).
 01 W-FLEN                 BINARY-LONG.
 01 W-ZERO                 BINARY-LONG VALUE 0.
 01 W-A                    BINARY-LONG.
 01 W-B                    BINARY-LONG.
 01 W-LEFT                 BINARY-LONG.
 01 W-TAIL                 BINARY-LONG.
 01 W-P                    BINARY-LONG.
 01 W-NEW                  PIC X(256).
 LINKAGE SECTION.
 COPY MN8FLD.
 01 L-IN                   PIC X(2000).
 01 L-INLEN                BINARY-LONG.
 PROCEDURE DIVISION USING MN8-FLD L-IN L-INLEN.
    MOVE 0 TO MN8-FCHANGED
    COMPUTE W-A = FUNCTION MIN(MN8-FCUR, MN8-FANC)
    COMPUTE W-B = FUNCTION MAX(MN8-FCUR, MN8-FANC)
    COMPUTE W-LEFT = MN8-FMAX - MN8-FLEN + (W-B - W-A)
    IF W-LEFT <= 0
        GOBACK
    END-IF
    CALL "MN8-FILTER" USING L-IN L-INLEN W-ZERO W-F W-FLEN
    IF W-FLEN > W-LEFT
        MOVE W-LEFT TO W-FLEN
    END-IF
    MOVE SPACES TO W-NEW
    IF W-A > 0
        MOVE MN8-FTEXT(1:W-A) TO W-NEW(1:W-A)
    END-IF
    COMPUTE W-P = W-A + 1
    IF W-FLEN > 0
        MOVE W-F(1:W-FLEN) TO W-NEW(W-P:W-FLEN)
    END-IF
    COMPUTE W-TAIL = MN8-FLEN - W-B
    COMPUTE W-P = W-A + W-FLEN + 1
    IF W-TAIL > 0
        COMPUTE W-B = W-B + 1
        MOVE MN8-FTEXT(W-B:W-TAIL) TO W-NEW(W-P:W-TAIL)
    END-IF
    MOVE W-NEW TO MN8-FTEXT
    COMPUTE MN8-FLEN = W-A + W-FLEN + W-TAIL
    COMPUTE MN8-FCUR = W-A + W-FLEN
    MOVE MN8-FCUR TO MN8-FANC
    MOVE 1 TO MN8-FCHANGED
    GOBACK.
 END PROGRAM MN8-FIELDINS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-FIELDSET.
*> USING MN8-FLD, text, length: EditBox.setValue: the text is cut to the maximum length, the cursor goes to the end with no selection and the
*> responder is called (MN8-FCHANGED 1) (4 behaviour 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-N                    BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8FLD.
 01 L-IN                   PIC X(2000).
 01 L-INLEN                BINARY-LONG.
 PROCEDURE DIVISION USING MN8-FLD L-IN L-INLEN.
    COMPUTE W-N = FUNCTION MIN(L-INLEN, MN8-FMAX)
    MOVE SPACES TO MN8-FTEXT
    IF W-N > 0
        MOVE L-IN(1:W-N) TO MN8-FTEXT(1:W-N)
    END-IF
    MOVE W-N TO MN8-FLEN MN8-FCUR MN8-FANC
    MOVE 1 TO MN8-FCHANGED
    GOBACK.
 END PROGRAM MN8-FIELDSET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-TITLEENTER.
*> USING scancode, field focused, value length, saves out: Enter (scancode 40, or 88 on the keypad) with the field focused and a value that is
*> not empty (a whitespace-only value counts as not empty) saves like the button (4 behaviour 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  BINARY-LONG.
 01 L-FOCUS                BINARY-LONG.
 01 L-LEN                  BINARY-LONG.
 01 L-SAVES                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-FOCUS L-LEN L-SAVES.
    MOVE 0 TO L-SAVES
    IF (L-KEY = 40 OR L-KEY = 88) AND L-FOCUS = 1 AND L-LEN > 0
        MOVE 1 TO L-SAVES
    END-IF
    GOBACK.
 END PROGRAM MN8-TITLEENTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNINS.
*> USING MN8-FLD, text, length: TextFieldHelper insert (5.2). A selection is deleted first (the cursor and anchor go to its start); the new
*> line is accepted when its width (advance x length) is at most MN8-FMAXW, then the cursor and anchor go after the inserted text; a rejected
*> insert leaves the text unchanged with the selection collapsed to its start. The caller keeps the line within 256 units.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-A                    BINARY-LONG.
 01 W-B                    BINARY-LONG.
 01 W-BLEN                 BINARY-LONG.
 01 W-CAND                 BINARY-LONG.
 01 W-P                    BINARY-LONG.
 01 W-TAIL                 BINARY-LONG.
 01 W-NEW                  PIC X(256).
 LINKAGE SECTION.
 COPY MN8FLD.
 01 L-IN                   PIC X(2000).
 01 L-INLEN                BINARY-LONG.
 PROCEDURE DIVISION USING MN8-FLD L-IN L-INLEN.
    MOVE 0 TO MN8-FCHANGED
    COMPUTE W-A = FUNCTION MIN(MN8-FCUR, MN8-FANC)
    COMPUTE W-B = FUNCTION MAX(MN8-FCUR, MN8-FANC)
    COMPUTE W-BLEN = MN8-FLEN - (W-B - W-A)
    COMPUTE W-CAND = W-BLEN + L-INLEN
    IF MN8-FADV * W-CAND > MN8-FMAXW
        MOVE W-A TO MN8-FCUR MN8-FANC
        GOBACK
    END-IF
    MOVE SPACES TO W-NEW
    IF W-A > 0
        MOVE MN8-FTEXT(1:W-A) TO W-NEW(1:W-A)
    END-IF
    COMPUTE W-P = W-A + 1
    IF L-INLEN > 0
        MOVE L-IN(1:L-INLEN) TO W-NEW(W-P:L-INLEN)
    END-IF
    COMPUTE W-TAIL = MN8-FLEN - W-B
    COMPUTE W-P = W-A + L-INLEN + 1
    IF W-TAIL > 0
        COMPUTE W-B = W-B + 1
        MOVE MN8-FTEXT(W-B:W-TAIL) TO W-NEW(W-P:W-TAIL)
    END-IF
    MOVE W-NEW TO MN8-FTEXT
    MOVE W-CAND TO MN8-FLEN
    COMPUTE MN8-FCUR = W-A + L-INLEN
    MOVE MN8-FCUR TO MN8-FANC
    MOVE 1 TO MN8-FCHANGED
    GOBACK.
 END PROGRAM MN8-SIGNINS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNTYPED.
*> USING MN8-FLD, code point, handled out: charTyped (5.1). An allowed chat character is inserted through 5.2; the call reports 1 always.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-OK                   BINARY-LONG.
 01 W-IN                   PIC X(2000).
 01 W-ONE                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY MN8FLD.
 01 L-CP                   BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING MN8-FLD L-CP L-HANDLED.
    MOVE 1 TO L-HANDLED
    MOVE 0 TO MN8-FCHANGED
    CALL "MN8-ALLOWED" USING L-CP W-OK
    IF W-OK = 1
        MOVE SPACES TO W-IN
        MOVE FUNCTION CHAR(L-CP + 1) TO W-IN(1:1)
        CALL "MN8-SIGNINS" USING MN8-FLD W-IN W-ONE
    END-IF
    GOBACK.
 END PROGRAM MN8-SIGNTYPED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-FDEL.
*> USING MN8-FLD, begin, end: removes the units from begin up to end (0 based) and puts the cursor and anchor at begin (5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-NEW                  PIC X(256).
 01 W-TAIL                 BINARY-LONG.
 01 W-P                    BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8FLD.
 01 L-BEGIN                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING MN8-FLD L-BEGIN L-END.
    MOVE SPACES TO W-NEW
    IF L-BEGIN > 0
        MOVE MN8-FTEXT(1:L-BEGIN) TO W-NEW(1:L-BEGIN)
    END-IF
    COMPUTE W-TAIL = MN8-FLEN - L-END
    COMPUTE W-P = L-END + 1
    IF W-TAIL > 0
        COMPUTE L-END = L-BEGIN + 1
        MOVE MN8-FTEXT(W-P:W-TAIL) TO W-NEW(L-END:W-TAIL)
    END-IF
    MOVE W-NEW TO MN8-FTEXT
    COMPUTE MN8-FLEN = MN8-FLEN - (W-P - 1 - L-BEGIN)
    MOVE L-BEGIN TO MN8-FCUR MN8-FANC
    GOBACK.
 END PROGRAM MN8-FDEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-FSKIP.
*> USING MN8-FLD, position (in and out), direction (-1 back, +1 forward), class wanted (1 separator, 0 not): steps while the unit passed over has
*> that class; the separators of the sign editor are only the space and the line feed (5.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-GO                   BINARY-LONG.
 01 W-LOOK                 BINARY-LONG.
 01 W-SEP                  BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8FLD.
 01 L-POS                  BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-WANT                 BINARY-LONG.
 PROCEDURE DIVISION USING MN8-FLD L-POS L-DIR L-WANT.
    MOVE 1 TO W-GO
    PERFORM UNTIL W-GO = 0
        IF L-DIR < 0
            MOVE L-POS TO W-LOOK
        ELSE
            COMPUTE W-LOOK = L-POS + 1
        END-IF
        IF W-LOOK < 1 OR W-LOOK > MN8-FLEN
            MOVE 0 TO W-GO
        ELSE
            MOVE 0 TO W-SEP
            IF MN8-FTEXT(W-LOOK:1) = SPACE OR MN8-FTEXT(W-LOOK:1) = X"0A"
                MOVE 1 TO W-SEP
            END-IF
            IF W-SEP = L-WANT
                ADD L-DIR TO L-POS
            ELSE
                MOVE 0 TO W-GO
            END-IF
        END-IF
    END-PERFORM
    GOBACK.
 END PROGRAM MN8-FSKIP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-WORDPOS.
*> USING MN8-FLD, direction (1 forward, -1 back), cursor, position out: StringSplitter.getWordPosition with skipWhitespace (5.3). Forward:
*> the next separator at or after the cursor (none: the end), then all following separators; backward: the separators before the cursor,
*> then the non-separators.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-NEG                  BINARY-LONG VALUE -1.
 01 W-POS                  BINARY-LONG VALUE 1.
 01 W-ZERO                 BINARY-LONG VALUE 0.
 01 W-ONE                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY MN8FLD.
 01 L-DIR                  BINARY-LONG.
 01 L-CURSOR               BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING MN8-FLD L-DIR L-CURSOR L-OUT.
    MOVE L-CURSOR TO L-OUT
    IF L-DIR > 0
        CALL "MN8-FSKIP" USING MN8-FLD L-OUT W-POS W-ZERO
        CALL "MN8-FSKIP" USING MN8-FLD L-OUT W-POS W-ONE
    ELSE
        CALL "MN8-FSKIP" USING MN8-FLD L-OUT W-NEG W-ONE
        CALL "MN8-FSKIP" USING MN8-FLD L-OUT W-NEG W-ZERO
    END-IF
    GOBACK.
 END PROGRAM MN8-WORDPOS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-FSEL.
*> USING MN8-FLD: the clipboard becomes the selected text (5.3 copy and cut).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-A                    BINARY-LONG.
 01 W-N                    BINARY-LONG.
 LINKAGE SECTION.
 COPY MN8FLD.
 PROCEDURE DIVISION USING MN8-FLD.
    COMPUTE W-A = FUNCTION MIN(MN8-FCUR, MN8-FANC)
    COMPUTE W-N = FUNCTION MAX(MN8-FCUR, MN8-FANC) - W-A
    MOVE SPACES TO MN8-FCLIP
    MOVE W-N TO MN8-FCLIPLEN
    IF W-N > 0
        ADD 1 TO W-A
        MOVE MN8-FTEXT(W-A:W-N) TO MN8-FCLIP(1:W-N)
    END-IF
    GOBACK.
 END PROGRAM MN8-FSEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNKEY.
*> USING MN8-FLD, keycode, scancode, modifier word, macOS flag, handled out: TextFieldHelper.keyPressed (5.3). Keycode rules first (select all,
*> copy, paste, cut with the edit shortcut and no Shift or Alt; Backspace; Delete, which reports 0 although it deletes; Home; End), then the
*> scancode rules Left (80) and Right (79). Steps are code points (one byte here).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-SHIFT                BINARY-LONG.
 01 W-CTRL                 BINARY-LONG.
 01 W-ALT                  BINARY-LONG.
 01 W-PLAIN                BINARY-LONG.
 01 W-MOVED                BINARY-LONG.
 01 W-NEW                  BINARY-LONG.
 01 W-A                    BINARY-LONG.
 01 W-B                    BINARY-LONG.
 01 W-POS                  BINARY-LONG.
 01 W-IN                   PIC X(2000).
 01 W-INLEN                BINARY-LONG.
 01 W-NEG                  BINARY-LONG VALUE -1.
 01 W-ONE                  BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 COPY MN8FLD.
 01 L-KEY                  BINARY-LONG.
 01 L-SCAN                 BINARY-LONG.
 01 L-MODS                 BINARY-LONG.
 01 L-MAC                  BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING MN8-FLD L-KEY L-SCAN L-MODS L-MAC L-HANDLED.
    CALL "MN8-MODS" USING L-MODS L-MAC W-SHIFT W-CTRL W-ALT
    MOVE 0 TO W-PLAIN W-MOVED
    IF W-CTRL = 1 AND W-SHIFT = 0 AND W-ALT = 0
        MOVE 1 TO W-PLAIN
    END-IF
    MOVE 1 TO L-HANDLED
    MOVE 0 TO MN8-FCHANGED
    COMPUTE W-A = FUNCTION MIN(MN8-FCUR, MN8-FANC)
    COMPUTE W-B = FUNCTION MAX(MN8-FCUR, MN8-FANC)
    EVALUATE TRUE
        WHEN L-KEY = 97 AND W-PLAIN = 1
            MOVE 0 TO MN8-FANC
            MOVE MN8-FLEN TO MN8-FCUR
        WHEN L-KEY = 99 AND W-PLAIN = 1
            CALL "MN8-FSEL" USING MN8-FLD
        WHEN L-KEY = 118 AND W-PLAIN = 1
            MOVE SPACES TO W-IN
            MOVE MN8-FCLIP TO W-IN(1:256)
            MOVE MN8-FCLIPLEN TO W-INLEN
            CALL "MN8-SIGNINS" USING MN8-FLD W-IN W-INLEN
            MOVE MN8-FCUR TO MN8-FANC
        WHEN L-KEY = 120 AND W-PLAIN = 1
            CALL "MN8-FSEL" USING MN8-FLD
            CALL "MN8-FDEL" USING MN8-FLD W-A W-B
        WHEN L-KEY = 8
            EVALUATE TRUE
                WHEN W-A NOT = W-B
                    CALL "MN8-FDEL" USING MN8-FLD W-A W-B
                WHEN W-CTRL = 1
                    CALL "MN8-WORDPOS" USING MN8-FLD W-NEG MN8-FCUR W-POS
                    CALL "MN8-FDEL" USING MN8-FLD W-POS W-B
                WHEN MN8-FCUR > 0
                    COMPUTE W-POS = MN8-FCUR - 1
                    CALL "MN8-FDEL" USING MN8-FLD W-POS W-B
            END-EVALUATE
        WHEN L-KEY = 127
            MOVE 0 TO L-HANDLED
            EVALUATE TRUE
                WHEN W-A NOT = W-B
                    CALL "MN8-FDEL" USING MN8-FLD W-A W-B
                WHEN W-CTRL = 1
                    CALL "MN8-WORDPOS" USING MN8-FLD W-ONE MN8-FCUR W-POS
                    CALL "MN8-FDEL" USING MN8-FLD W-A W-POS
                WHEN OTHER
                    COMPUTE W-POS = FUNCTION MIN(MN8-FCUR + 1, MN8-FLEN)
                    CALL "MN8-FDEL" USING MN8-FLD W-A W-POS
            END-EVALUATE
        WHEN L-SCAN = 80
            MOVE 1 TO W-MOVED
            IF W-CTRL = 1
                CALL "MN8-WORDPOS" USING MN8-FLD W-NEG MN8-FCUR W-NEW
            ELSE
                COMPUTE W-NEW = FUNCTION MAX(MN8-FCUR - 1, 0)
            END-IF
        WHEN L-SCAN = 79
            MOVE 1 TO W-MOVED
            IF W-CTRL = 1
                CALL "MN8-WORDPOS" USING MN8-FLD W-ONE MN8-FCUR W-NEW
            ELSE
                COMPUTE W-NEW = FUNCTION MIN(MN8-FCUR + 1, MN8-FLEN)
            END-IF
        WHEN L-KEY = 1073741898
            MOVE 1 TO W-MOVED
            MOVE 0 TO W-NEW
        WHEN L-KEY = 1073741901
            MOVE 1 TO W-MOVED
            MOVE MN8-FLEN TO W-NEW
        WHEN OTHER
            MOVE 0 TO L-HANDLED
    END-EVALUATE
    IF W-MOVED = 1
        MOVE W-NEW TO MN8-FCUR
        IF W-SHIFT = 0
            MOVE W-NEW TO MN8-FANC
        END-IF
    END-IF
    GOBACK.
 END PROGRAM MN8-SIGNKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-CLIPGET.
*> USING clipboard text, its length, text out (spaces first), length out: the sign clipboard getter (5.4). Every carriage return is deleted, then
*> every section sign (unit 167) followed by one of 0-9 a-f k-o r (either case) is removed; nothing else is filtered.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-T                    PIC X(2000).
 01 W-TLEN                 BINARY-LONG.
 01 W-I                    BINARY-LONG.
 01 W-NEXT                 BINARY-LONG.
 01 W-U                    PIC X.
 01 W-SET                  PIC X(22) VALUE "0123456789ABCDEFKLMNOR".
 01 W-CNT                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN                   PIC X(2000).
 01 L-INLEN                BINARY-LONG.
 01 L-OUT                  PIC X(2000).
 01 L-OUTLEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-IN L-INLEN L-OUT L-OUTLEN.
    MOVE SPACES TO W-T L-OUT
    MOVE 0 TO W-TLEN L-OUTLEN
    PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > L-INLEN
        IF L-IN(W-I:1) NOT = X"0D"
            ADD 1 TO W-TLEN
            MOVE L-IN(W-I:1) TO W-T(W-TLEN:1)
        END-IF
    END-PERFORM
    MOVE 1 TO W-I
    PERFORM UNTIL W-I > W-TLEN
        MOVE 0 TO W-CNT
        IF FUNCTION ORD(W-T(W-I:1)) = 168 AND W-I < W-TLEN
            COMPUTE W-NEXT = W-I + 1
            MOVE FUNCTION UPPER-CASE(W-T(W-NEXT:1)) TO W-U
            INSPECT W-SET TALLYING W-CNT FOR ALL W-U
        END-IF
        IF W-CNT > 0
            ADD 2 TO W-I
        ELSE
            ADD 1 TO L-OUTLEN
            MOVE W-T(W-I:1) TO L-OUT(L-OUTLEN:1)
            ADD 1 TO W-I
        END-IF
    END-PERFORM
    GOBACK.
 END PROGRAM MN8-CLIPGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNDIMS.
*> USING hanging, line height out, maximum line width out, frame y offset out, text scale x 1e7 out, background scale x 10 out (6.1 step 5, 6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HANGING              BINARY-LONG.
 01 L-LH                   BINARY-LONG.
 01 L-MAXW                 BINARY-LONG.
 01 L-YOFF                 BINARY-LONG.
 01 L-TSCALE               BINARY-LONG.
 01 L-BSCALE               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANGING L-LH L-MAXW L-YOFF L-TSCALE L-BSCALE.
    IF L-HANGING = 1
        MOVE 9 TO L-LH
        MOVE 60 TO L-MAXW
        MOVE 125 TO L-YOFF
        MOVE 10000000 TO L-TSCALE
        MOVE 45 TO L-BSCALE
    ELSE
        MOVE 10 TO L-LH
        MOVE 90 TO L-MAXW
        MOVE 90 TO L-YOFF
        MOVE 9765628 TO L-TSCALE
        MOVE 39 TO L-BSCALE
    END-IF
    GOBACK.
 END PROGRAM MN8-SIGNDIMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNBG.
*> USING hanging, wall-mounted, translate y out, blit x, blit y, width, height out, scale x 10 out (6.4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HANGING              BINARY-LONG.
 01 L-WALL                 BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BW                   BINARY-LONG.
 01 L-BH                   BINARY-LONG.
 01 L-SCALE                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANGING L-WALL L-TY L-BX L-BY L-BW L-BH L-SCALE.
    IF L-HANGING = 1
        MOVE -13 TO L-TY
        MOVE -8 TO L-BX L-BY
        MOVE 16 TO L-BW L-BH
        MOVE 45 TO L-SCALE
    ELSE
        MOVE 27 TO L-TY
        MOVE -12 TO L-BX
        MOVE -13 TO L-BY
        MOVE 24 TO L-BW
        MOVE 26 TO L-BH
        IF L-WALL = 1
            MOVE 12 TO L-BH
        END-IF
        MOVE 39 TO L-SCALE
    END-IF
    GOBACK.
 END PROGRAM MN8-SIGNBG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-PREVIEWCOLOR.
*> USING glow, dye text colour RGB, preview colour out: glowing text keeps the colour; other text scales each channel by 0.4f, truncated and
*> clamped to 0..255 (6.1 step 3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-K                    FLOAT-SHORT VALUE 0.4.
 01 W-F                    FLOAT-SHORT.
 01 W-C                    BINARY-LONG.
 01 W-V                    BINARY-LONG.
 01 W-SH                   BINARY-LONG.
 01 W-Q                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-GLOW                 BINARY-LONG.
 01 L-RGB                  BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-GLOW L-RGB L-OUT.
    IF L-GLOW = 1
        MOVE L-RGB TO L-OUT
        GOBACK
    END-IF
    MOVE 0 TO L-OUT
    MOVE 65536 TO W-SH
    PERFORM 3 TIMES
        DIVIDE L-RGB BY W-SH GIVING W-Q
        DIVIDE W-Q BY 256 GIVING W-V REMAINDER W-C
        COMPUTE W-F = W-C * W-K
        COMPUTE W-V = FUNCTION INTEGER-PART(W-F)
        COMPUTE W-V = FUNCTION MIN(FUNCTION MAX(W-V, 0), 255)
        COMPUTE L-OUT = L-OUT + W-V * W-SH
        DIVIDE W-SH BY 256 GIVING W-SH
    END-PERFORM
    GOBACK.
 END PROGRAM MN8-PREVIEWCOLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-MSGPRESENT.
*> USING list length, line index, present out (6.1 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-I                    BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-I L-PRESENT.
    MOVE 0 TO L-PRESENT
    IF L-I < L-N
        MOVE 1 TO L-PRESENT
    END-IF
    GOBACK.
 END PROGRAM MN8-MSGPRESENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNSCREENKEY.
*> USING scancode, line, kind out (1 line change, 2 close, 3 goes on), new line out (6.2 step 3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  BINARY-LONG.
 01 L-LINE                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-LINE L-KIND L-NEW.
    MOVE L-LINE TO L-NEW
    EVALUATE TRUE
        WHEN L-KEY = 82
            MOVE 1 TO L-KIND
            COMPUTE L-NEW = FUNCTION MOD(L-LINE + 3, 4)
        WHEN L-KEY = 81 OR L-KEY = 40 OR L-KEY = 88
            MOVE 1 TO L-KIND
            COMPUTE L-NEW = FUNCTION MOD(L-LINE + 1, 4)
        WHEN L-KEY = 41
            MOVE 2 TO L-KIND
        WHEN OTHER
            MOVE 3 TO L-KIND
    END-EVALUATE
    GOBACK.
 END PROGRAM MN8-SIGNSCREENKEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-KEYKIND.
*> USING scancode, selection key out, confirmation key out, escape out (6.2 step 3d).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  BINARY-LONG.
 01 L-SEL                  BINARY-LONG.
 01 L-CONF                 BINARY-LONG.
 01 L-ESC                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-SEL L-CONF L-ESC.
    MOVE 0 TO L-SEL L-CONF L-ESC
    IF L-KEY = 40 OR L-KEY = 44 OR L-KEY = 88
        MOVE 1 TO L-SEL
    END-IF
    IF L-KEY = 40 OR L-KEY = 88
        MOVE 1 TO L-CONF
    END-IF
    IF L-KEY = 41
        MOVE 1 TO L-ESC
    END-IF
    GOBACK.
 END PROGRAM MN8-KEYKIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNTICK.
*> USING player missing, sign removed, player too far, close out (6.2 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-MISSING              BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 01 L-FAR                  BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-MISSING L-REMOVED L-FAR L-CLOSE.
    MOVE 0 TO L-CLOSE
    IF L-MISSING = 1 OR L-REMOVED = 1 OR L-FAR = 1
        MOVE 1 TO L-CLOSE
    END-IF
    GOBACK.
 END PROGRAM MN8-SIGNTICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNCHANGE.
*> USING new string equals stored, connection exists, store out, packet now out (always 0), packet on removal out (6.2 steps 5 to 7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SAME                 BINARY-LONG.
 01 L-CONN                 BINARY-LONG.
 01 L-STORE                BINARY-LONG.
 01 L-NOW                  BINARY-LONG.
 01 L-REMOVAL              BINARY-LONG.
 PROCEDURE DIVISION USING L-SAME L-CONN L-STORE L-NOW L-REMOVAL.
    COMPUTE L-STORE = 1 - L-SAME
    MOVE 0 TO L-NOW
    MOVE L-CONN TO L-REMOVAL
    GOBACK.
 END PROGRAM MN8-SIGNCHANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNDONE.
*> USING width, height, x, y, w, h, title x, title y out (6.2 step 1, 6.3 step 2).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-BW                   BINARY-LONG.
 01 L-BH                   BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-H L-X L-Y L-BW L-BH L-TX L-TY.
    COMPUTE L-TX = L-W / 2
    COMPUTE L-X = L-TX - 100
    COMPUTE L-Y = L-H / 4
    ADD 144 TO L-Y
    MOVE 200 TO L-BW
    MOVE 20 TO L-BH
    MOVE 40 TO L-TY
    GOBACK.
 END PROGRAM MN8-SIGNDONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNPREVIEW.
*> USING width, height, hanging, wall, x0, y0, x1, y1 out in tenths of a pixel (6.4, 6.6).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-CX                   BINARY-LONG.
 01 W-C                    BINARY-LONG.
 01 W-H                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-HT                   BINARY-LONG.
 01 L-HANGING              BINARY-LONG.
 01 L-WALL                 BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-HT L-HANGING L-WALL L-X0 L-Y0 L-X1 L-Y1.
    COMPUTE W-CX = L-W / 2
    COMPUTE W-CX = W-CX * 10
    IF L-HANGING = 1
        COMPUTE L-X0 = W-CX - 360
        COMPUTE L-X1 = W-CX + 360
        COMPUTE L-Y0 = 1120 - 360
        COMPUTE L-Y1 = 1120 + 360
    ELSE
        MOVE 26 TO W-H
        IF L-WALL = 1
            MOVE 12 TO W-H
        END-IF
        COMPUTE L-X0 = W-CX - 468
        COMPUTE L-X1 = W-CX + 468
        COMPUTE W-C = 1170 - 507
        MOVE W-C TO L-Y0
        COMPUTE L-Y1 = L-Y0 + 39 * W-H
    END-IF
    GOBACK.
 END PROGRAM MN8-SIGNPREVIEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNTEXTY.
*> USING hanging, line, screen y x 1e6 out (6.5, 6.6).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HANGING              BINARY-LONG.
 01 L-LINE                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-HANGING L-LINE L-Y.
    IF L-HANGING = 1
        COMPUTE L-Y = 125000000 + (L-LINE * 9 - 18) * 1000000
    ELSE
        COMPUTE L-Y = 90000000 + (L-LINE - 2) * 9765628
    END-IF
    GOBACK.
 END PROGRAM MN8-SIGNTEXTY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-LINEX.
*> USING text width, x out: -(width / 2) (6.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-H                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-W                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 PROCEDURE DIVISION USING L-W L-X.
    DIVIDE L-W BY 2 GIVING W-H
    COMPUTE L-X = 0 - W-H
    GOBACK.
 END PROGRAM MN8-LINEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNCARET.
*> USING length, advance, cursor, anchor, line height, line y, ms since init, kind out (0 none, 1 append, 2 bar), x, top, bottom, selection,
*> selection x0, x1 out (6.5). P(k) = advance x k - width / 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 W-HALF                 BINARY-LONG.
 01 W-Q                    BINARY-LONG.
 01 W-D                    BINARY-LONG.
 01 W-R                    BINARY-LONG.
 01 W-PC                   BINARY-LONG.
 01 W-PA                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-ADV                  BINARY-LONG.
 01 L-C                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-LH                   BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-MS                   BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 01 L-BOT                  BINARY-LONG.
 01 L-SEL                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-ADV L-C L-A L-LH L-Y L-MS L-KIND L-X L-TOP L-BOT L-SEL L-X0 L-X1.
    MOVE 0 TO L-KIND L-X L-TOP L-BOT L-SEL L-X0 L-X1
    COMPUTE W-Q = L-ADV * L-N
    DIVIDE W-Q BY 2 GIVING W-HALF
    DIVIDE L-MS BY 300 GIVING W-Q
    DIVIDE W-Q BY 2 GIVING W-D REMAINDER W-R
    IF L-C >= 0 AND W-R = 0
        IF L-C >= L-N
            MOVE 1 TO L-KIND
            COMPUTE L-X = L-ADV * L-N - W-HALF
            MOVE L-Y TO L-TOP
            COMPUTE L-BOT = L-Y + L-LH
        ELSE
            MOVE 2 TO L-KIND
            COMPUTE L-X = L-ADV * L-C - W-HALF
            COMPUTE L-TOP = L-Y - 1
            COMPUTE L-BOT = L-Y + L-LH
        END-IF
    END-IF
    IF L-A NOT = L-C
        MOVE 1 TO L-SEL
        COMPUTE W-PC = L-ADV * L-C - W-HALF
        COMPUTE W-PA = L-ADV * L-A - W-HALF
        COMPUTE L-X0 = FUNCTION MIN(W-PC, W-PA)
        COMPUTE L-X1 = FUNCTION MAX(W-PC, W-PA)
    END-IF
    GOBACK.
 END PROGRAM MN8-SIGNCARET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-PACKET.
*> USING action (1 book Done, 2 Sign and Close, 3 sign editor close), packet id, title present, erases trailing pages, updates local stack,
*> title wire limit out (7, 3.3 step 9, 4 behaviour 4).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ACTION               BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-TITLE                BINARY-LONG.
 01 L-ERASE                BINARY-LONG.
 01 L-LOCAL                BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ACTION L-ID L-TITLE L-ERASE L-LOCAL L-LIMIT.
    MOVE 0 TO L-TITLE L-ERASE L-LOCAL L-LIMIT
    EVALUATE L-ACTION
        WHEN 1
            MOVE 24 TO L-ID
            MOVE 1 TO L-ERASE L-LOCAL
        WHEN 2
            MOVE 24 TO L-ID
            MOVE 1 TO L-TITLE
            MOVE 32 TO L-LIMIT
        WHEN OTHER
            MOVE 62 TO L-ID
    END-EVALUATE
    GOBACK.
 END PROGRAM MN8-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-ACCEPT.
*> USING case (1 zero pages, 2 trailing empty pages, 3 empty trimmed title, 4 sign line with line feed or tab), accepted out (7).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CASE                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CASE L-OK.
    MOVE 0 TO L-OK
    IF L-CASE >= 1 AND L-CASE <= 4
        MOVE 1 TO L-OK
    END-IF
    GOBACK.
 END PROGRAM MN8-ACCEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MN8-SIGNPKT.
*> USING side (0 back, 1 front), side VarInt out, line strings out (4), count prefix present out (0) (7, 8 example 9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIDE                 BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-LINES                BINARY-LONG.
 01 L-PREFIX               BINARY-LONG.
 PROCEDURE DIVISION USING L-SIDE L-VAR L-LINES L-PREFIX.
    MOVE L-SIDE TO L-VAR
    MOVE 4 TO L-LINES
    MOVE 0 TO L-PREFIX
    GOBACK.
 END PROGRAM MN8-SIGNPKT.
