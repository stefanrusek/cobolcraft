*> The writable book editor screen (docs/protocol/40-menus-8-book-and-sign-editors.md sections 1.1, 3, 4): BOOK-USE-CHECK opens it when the held item is a writable_book and the right
*> button is pressed in the world (the client's own prediction: the server sends nothing); BOOK-BUILD draws the page (text origin (x + 4, 32) of the box at (W - 114) / 2 - 8), the page
*> indicator, the page buttons and Sign and Done, or in the signing mode (BE-MODE 1) the title screen; BOOK-INPUT takes typed text and keys; BOOK-ACTION the buttons. The book's pages
*> already written are not loaded (the client keeps no item components), so the editor opens on one empty page.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-OPEN.
*> USING CLIENT-STATE: one empty page, the main hand, editing mode; the editor engine at width 114, 1024 units and 14 lines with the font's advances.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-WIDTH               BINARY-LONG VALUE 114.
 01 WS-CLIMIT              BINARY-LONG VALUE 1024.
 01 WS-LLIMIT              BINARY-LONG VALUE 14.
 01 WS-ADVANCE             BINARY-LONG VALUE 0.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-BOOK.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 1 TO BE-PAGE-COUNT
     MOVE 0 TO BE-PAGE-LEN(1) BE-CURRENT BE-HAND BE-MODE BE-TITLE-LEN
     MOVE SPACES TO BE-PAGE-TEXT(1) BE-TITLE
     CALL "BOOK-INIT" USING CLIENT-STATE WS-WIDTH WS-CLIMIT WS-LLIMIT WS-ADVANCE
     CALL "BOOK-LOAD" USING CLIENT-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     GOBACK.
 END PROGRAM BOOK-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-USE-CHECK.
*> USING CLIENT-STATE, held item id: the right button was pressed in the world with that item: a writable_book opens the editor.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(16) VALUE "writable_book".
 01 WS-ITEM                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM.
     CALL "ITEM-BY-KEY" USING CLIENT-STATE WS-KEY WS-ITEM
     IF WS-ITEM > 0 AND WS-ITEM = L-ITEM
         CALL "BOOK-OPEN" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM BOOK-USE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-LABEL.
*> USING CLIENT-STATE, text (PIC X(512)), length, x, y: a label widget.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG VALUE WK-LABEL.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-W                   BINARY-LONG VALUE 200.
 01 WS-H                   BINARY-LONG VALUE 9.
 01 WS-STATE               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-TEXT L-LENGTH L-X L-Y.
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG L-X L-Y WS-W WS-H L-TEXT L-LENGTH WS-STATE
     GOBACK.
 END PROGRAM BOOK-LABEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-BUTTON.
*> USING CLIENT-STATE, lang key (PIC X(80)), key length, action, argument, x, y, width, height, state (0 normal, 2 disabled): a button with the key's text.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-KIND                BINARY-LONG VALUE WK-BUTTON.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KEY L-KEY-LENGTH L-ACTION L-ARG L-X L-Y L-W L-H L-STATE.
     CALL "LANG-GET" USING CLIENT-STATE L-KEY L-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND L-ACTION L-ARG L-X L-Y L-W L-H WS-OUT WS-OUT-LENGTH L-STATE
     GOBACK.
 END PROGRAM BOOK-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height: the editing screen (3.2): the page lines at (99, 32 + 9 i) for W 320, the indicator right-aligned to L + 148 at y 18, back (L + 43, 159, only
*> past the first page) and forward (L + 116, 159) buttons 23 x 13, Sign (W / 2 - 100, 196) and Done (W / 2 + 2, 196) 98 x 20; the signing screen (4): the caption at y 34, the title
*> at y 55, the warning at y 82, Sign and Close (inactive for a blank title) and Cancel.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 01 WS-L                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT-256            PIC X(256).
 01 WS-WIDTH               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-PAGE                PIC Z(8)9.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SWATCH              BINARY-LONG.
 01 WS-BLANK               BINARY-LONG.
 01 WS-BIG                 PIC X(1100).
 01 WS-NOTEXT              PIC X(512).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     COMPUTE WS-L = (L-GW - 192) / 2
     IF BE-MODE = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BK-LINE-COUNT OR WS-I > 14
             COMPUTE WS-LEN = BK-LE(WS-I) - BK-LB(WS-I)
             IF WS-LEN > 0
                 MOVE SPACES TO WS-TEXT
                 MOVE BK-VALUE(BK-LB(WS-I) + 1:WS-LEN) TO WS-TEXT
                 COMPUTE WS-X = (L-GW - 114) / 2 - 8 + 4
                 COMPUTE WS-Y = 32 + 9 * (WS-I - 1)
                 CALL "BOOK-LABEL" USING CLIENT-STATE WS-TEXT WS-LEN WS-X WS-Y
             END-IF
         END-PERFORM
         MOVE 2 TO LA-COUNT
         COMPUTE WS-PAGE = BE-CURRENT + 1
         MOVE FUNCTION TRIM(WS-PAGE) TO LA-TEXT(1)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PAGE)) TO LA-LENGTH(1)
         COMPUTE WS-PAGE = BE-PAGE-COUNT
         MOVE FUNCTION TRIM(WS-PAGE) TO LA-TEXT(2)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PAGE)) TO LA-LENGTH(2)
         MOVE "book.pageIndicator" TO WS-KEY
         MOVE 18 TO WS-KEY-LENGTH
         CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-OUT WS-OUT-LENGTH
         MOVE WS-OUT(1:256) TO WS-TEXT-256
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT-256 WS-OUT-LENGTH WS-WIDTH
         COMPUTE WS-X = WS-L + 148 - WS-WIDTH
         MOVE 18 TO WS-Y
         CALL "BOOK-LABEL" USING CLIENT-STATE WS-OUT WS-OUT-LENGTH WS-X WS-Y
         MOVE 23 TO WS-W
         MOVE 13 TO WS-H
         MOVE 159 TO WS-Y
         MOVE SW-BUTTON TO WS-SWATCH
         MOVE ACT-NONE TO WS-ACTION
         MOVE 0 TO WS-STATE
         MOVE SPACES TO WS-NOTEXT
         IF BE-CURRENT > 0
             COMPUTE WS-X = WS-L + 43
             MOVE WK-OVERLAY TO WS-KIND
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-NOTEXT WS-ZERO WS-STATE
             MOVE WK-IMAGE TO WS-KIND
             MOVE ACT-BOOK-PAGE TO WS-ACTION
             MOVE 1 TO WS-ARG
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-NOTEXT WS-ZERO WS-STATE
         END-IF
         COMPUTE WS-X = WS-L + 116
         MOVE WK-OVERLAY TO WS-KIND
         MOVE ACT-NONE TO WS-ACTION
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-SWATCH WS-X WS-Y WS-W WS-H WS-NOTEXT WS-ZERO WS-STATE
         MOVE WK-IMAGE TO WS-KIND
         MOVE ACT-BOOK-PAGE TO WS-ACTION
         MOVE 2 TO WS-ARG
         CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-W WS-H WS-NOTEXT WS-ZERO WS-STATE
         MOVE "book.signButton" TO WS-KEY
         MOVE 15 TO WS-KEY-LENGTH
         COMPUTE WS-X = L-GW / 2 - 100
         MOVE 196 TO WS-Y
         MOVE 98 TO WS-W
         MOVE 20 TO WS-H
         MOVE 0 TO WS-ARG
         CALL "BOOK-BUTTON" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH ACT-BOOK-SIGN WS-ARG WS-X WS-Y WS-W WS-H WS-STATE
         MOVE "gui.done" TO WS-KEY
         MOVE 8 TO WS-KEY-LENGTH
         COMPUTE WS-X = L-GW / 2 + 2
         CALL "BOOK-BUTTON" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH ACT-BOOK-DONE WS-ARG WS-X WS-Y WS-W WS-H WS-STATE
     ELSE
         MOVE "book.editTitle" TO WS-KEY
         MOVE 14 TO WS-KEY-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
         MOVE WS-OUT(1:256) TO WS-TEXT-256
         CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT-256 WS-OUT-LENGTH WS-WIDTH
         COMPUTE WS-X = WS-L + 36 + (114 - WS-WIDTH) / 2
         MOVE 34 TO WS-Y
         CALL "BOOK-LABEL" USING CLIENT-STATE WS-OUT WS-OUT-LENGTH WS-X WS-Y
         IF BE-TITLE-LEN > 0
             MOVE SPACES TO WS-TEXT
             MOVE BE-TITLE(1:BE-TITLE-LEN) TO WS-TEXT
             MOVE WS-TEXT(1:256) TO WS-TEXT-256
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT-256 BE-TITLE-LEN WS-WIDTH
             COMPUTE WS-X = (L-GW - 114) / 2 - 3 + (114 - WS-WIDTH) / 2
             MOVE 55 TO WS-Y
             CALL "BOOK-LABEL" USING CLIENT-STATE WS-TEXT BE-TITLE-LEN WS-X WS-Y
         END-IF
         MOVE "book.finalizeWarning" TO WS-KEY
         MOVE 20 TO WS-KEY-LENGTH
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
         COMPUTE WS-X = WS-L + 36
         MOVE 82 TO WS-Y
         CALL "BOOK-LABEL" USING CLIENT-STATE WS-OUT WS-OUT-LENGTH WS-X WS-Y
         MOVE SPACES TO WS-BIG
         IF BE-TITLE-LEN > 0
             MOVE BE-TITLE(1:BE-TITLE-LEN) TO WS-BIG
         END-IF
         CALL "BOOK-TITLE-BLANK" USING WS-BIG BE-TITLE-LEN WS-BLANK
         MOVE 0 TO WS-STATE
         IF WS-BLANK = 1
             MOVE 2 TO WS-STATE
         END-IF
         MOVE "book.finalizeButton" TO WS-KEY
         MOVE 19 TO WS-KEY-LENGTH
         COMPUTE WS-X = L-GW / 2 - 100
         MOVE 196 TO WS-Y
         MOVE 98 TO WS-W
         MOVE 20 TO WS-H
         MOVE 0 TO WS-ARG
         CALL "BOOK-BUTTON" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH ACT-BOOK-FINALIZE WS-ARG WS-X WS-Y WS-W WS-H WS-STATE
         MOVE "gui.cancel" TO WS-KEY
         MOVE 10 TO WS-KEY-LENGTH
         COMPUTE WS-X = L-GW / 2 + 2
         MOVE 0 TO WS-STATE
         CALL "BOOK-BUTTON" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH ACT-BOOK-CANCEL WS-ARG WS-X WS-Y WS-W WS-H WS-STATE
     END-IF
     GOBACK.
 END PROGRAM BOOK-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-LEAVE.
*> USING CLIENT-STATE: the editor ends (no packet here): back to the world screen.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-WORLD.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO BE-ACTIVE BE-MODE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     GOBACK.
 END PROGRAM BOOK-LEAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-ACTION.
*> USING CLIENT-STATE, action, argument: Done (Edit Book without title, trailing empty pages erased), Sign (the title screen), the page buttons, Sign and Close (Edit Book with the trimmed
*> title) and Cancel (back to the pages, the title kept).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-ARG.
     EVALUATE L-ACTION
         WHEN ACT-BOOK-DONE
             CALL "BOOK-DONE" USING CLIENT-STATE
             CALL "BOOK-LEAVE" USING CLIENT-STATE
         WHEN ACT-BOOK-SIGN
             MOVE 1 TO BE-MODE
         WHEN ACT-BOOK-PAGE
             IF L-ARG = 1
                 CALL "BOOK-PAGE-BACK" USING CLIENT-STATE
             ELSE
                 CALL "BOOK-PAGE-FORWARD" USING CLIENT-STATE
             END-IF
         WHEN ACT-BOOK-FINALIZE
             CALL "BOOK-SIGN-SEND" USING CLIENT-STATE
             CALL "BOOK-LEAVE" USING CLIENT-STATE
         WHEN ACT-BOOK-CANCEL
             MOVE 0 TO BE-MODE
             CALL "BOOK-LOAD" USING CLIENT-STATE
     END-EVALUATE
     GOBACK.
 END PROGRAM BOOK-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BOOK-INPUT.
*> USING CLIENT-STATE: editing: typed characters go to the page (BOOK-INSERT), the keys Backspace, Delete, Enter, Left, Right, Up, Down, Home and End (GLFW 259, 261, 257, 263, 262, 265,
*> 264, 268, 269) to the engine as their SDL keycodes, Page Up and Page Down (266, 267) turn the page, Escape closes with no packet; signing: typed characters go to the title (15
*> units, no control character), Backspace removes one, Enter with a non-empty title signs, Escape closes with no packet.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-BYTES               PIC X(4).
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT                PIC X(1100).
 01 WS-KEY                 BINARY-LONG.
 01 WS-SHIFT               BINARY-LONG VALUE 0.
 01 WS-EDIT                BINARY-LONG VALUE 0.
 01 WS-ALT                 BINARY-LONG VALUE 0.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF BE-MODE = 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IN-TEXT-COUNT
             IF IN-TEXT(WS-I) >= 32 AND IN-TEXT(WS-I) NOT = 127 AND IN-TEXT(WS-I) NOT = 167
                 CALL "UTF8-ENCODE" USING IN-TEXT(WS-I) WS-BYTES WS-COUNT
                 MOVE SPACES TO WS-TEXT
                 MOVE WS-BYTES(1:WS-COUNT) TO WS-TEXT(1:WS-COUNT)
                 CALL "BOOK-INSERT" USING CLIENT-STATE WS-TEXT WS-COUNT
             END-IF
         END-PERFORM
         MOVE 0 TO WS-KEY
         EVALUATE TRUE
             WHEN IN-KEY-PRESSED(259 + 1) = 1
                 MOVE 8 TO WS-KEY
             WHEN IN-KEY-PRESSED(261 + 1) = 1
                 MOVE 127 TO WS-KEY
             WHEN IN-KEY-PRESSED(257 + 1) = 1
                 MOVE 13 TO WS-KEY
             WHEN IN-KEY-PRESSED(263 + 1) = 1
                 MOVE 1073741904 TO WS-KEY
             WHEN IN-KEY-PRESSED(262 + 1) = 1
                 MOVE 1073741903 TO WS-KEY
             WHEN IN-KEY-PRESSED(265 + 1) = 1
                 MOVE 1073741906 TO WS-KEY
             WHEN IN-KEY-PRESSED(264 + 1) = 1
                 MOVE 1073741905 TO WS-KEY
             WHEN IN-KEY-PRESSED(268 + 1) = 1
                 MOVE 1073741898 TO WS-KEY
             WHEN IN-KEY-PRESSED(269 + 1) = 1
                 MOVE 1073741901 TO WS-KEY
         END-EVALUATE
         IF WS-KEY > 0
             CALL "BOOK-KEY" USING CLIENT-STATE WS-KEY WS-SHIFT WS-EDIT WS-ALT WS-HANDLED
         END-IF
         IF IN-KEY-PRESSED(CL-KEY-PAGE-UP + 1) = 1
             MOVE ACT-BOOK-PAGE TO WS-ACTION
             MOVE 1 TO WS-ARG
             CALL "BOOK-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
         END-IF
         IF IN-KEY-PRESSED(CL-KEY-PAGE-DOWN + 1) = 1
             MOVE ACT-BOOK-PAGE TO WS-ACTION
             MOVE 2 TO WS-ARG
             CALL "BOOK-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
         END-IF
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IN-TEXT-COUNT
             IF IN-TEXT(WS-I) >= 32 AND IN-TEXT(WS-I) NOT = 127 AND IN-TEXT(WS-I) NOT = 167 AND IN-TEXT(WS-I) < 128
                 IF BE-TITLE-LEN < 15
                     ADD 1 TO BE-TITLE-LEN
                     MOVE FUNCTION CHAR(IN-TEXT(WS-I) + 1) TO BE-TITLE(BE-TITLE-LEN:1)
                 END-IF
             END-IF
         END-PERFORM
         IF IN-KEY-PRESSED(CC-KEY-BACKSPACE + 1) = 1 AND BE-TITLE-LEN > 0
             MOVE BE-TITLE TO WS-LINE
             MOVE BE-TITLE-LEN TO WS-LEN
             CALL "TEXT-DROP-LAST" USING WS-LINE WS-LEN
             MOVE WS-LINE(1:32) TO BE-TITLE
             MOVE WS-LEN TO BE-TITLE-LEN
         END-IF
         IF (IN-KEY-PRESSED(257 + 1) = 1 OR IN-KEY-PRESSED(335 + 1) = 1) AND BE-TITLE-LEN > 0
             MOVE ACT-BOOK-FINALIZE TO WS-ACTION
             MOVE 0 TO WS-ARG
             CALL "BOOK-ACTION" USING CLIENT-STATE WS-ACTION WS-ARG
         END-IF
     END-IF
     IF IN-KEY-PRESSED(CC-KEY-ESCAPE + 1) = 1 AND SM-SCREEN = SCR-BOOK
         CALL "BOOK-LEAVE" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM BOOK-INPUT.
