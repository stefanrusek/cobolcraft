*> The sign editor screen (docs/protocol/40-menus-8-book-and-sign-editors.md sections 1.2, 6): Open Sign Editor (05a 0x3D: Position, Side) opens it (SIGN-OPEN); SIGN-BUILD draws the title,
*> the four lines centred on x of the GUI centre and the Done button; SIGN-INPUT takes typed characters, Backspace, Up, Down, Enter and Escape (closing); closing sends Sign Update
*> (SIGN-CLOSE, textedit.cob) and returns to the world. The client keeps no block entity text, so the lines start empty (the sign's current text is not shown); the sign is a standing
*> sign (width limit 90).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-OPEN.
*> USING CLIENT-STATE, packet PB-BUFFER: Position, Side (Boolean, true front): the sign editor of that sign side with four empty lines.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FRONT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-SIGN.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-POSITION" USING PB-BUFFER WS-X WS-Y WS-Z
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-FRONT
     IF PB-ERROR = 0
         MOVE WS-X TO SG-X
         MOVE WS-Y TO SG-Y
         MOVE WS-Z TO SG-Z
         MOVE WS-FRONT TO SG-SIDE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             MOVE SPACES TO SG-LINE-TEXT(WS-I)
             MOVE 0 TO SG-LEN(WS-I)
         END-PERFORM
         MOVE 0 TO SG-LINE SG-CURSOR SG-ANCHOR BK-ADVANCE
         MOVE 90 TO SG-MAXW
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     END-IF
     GOBACK.
 END PROGRAM SIGN-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height: 6.3: the title (sign.edit) centred at y 40, the lines centred on x at y 70, 80, 90, 100, Done at (W / 2 - 100, H / 4 + 144), 200 x 20.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE ACT-NONE.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-OUT                 PIC X(512).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-TEXT-256            PIC X(256).
 01 WS-WIDTH               BINARY-LONG.
 01 WS-LABEL-W             BINARY-LONG VALUE 200.
 01 WS-LABEL-H             BINARY-LONG VALUE 9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE "sign.edit" TO WS-KEY
     MOVE 9 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-OUT WS-OUT-LENGTH
     MOVE WS-OUT(1:256) TO WS-TEXT-256
     CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT-256 WS-OUT-LENGTH WS-WIDTH
     COMPUTE WS-X = L-GW / 2 - WS-WIDTH / 2
     MOVE 40 TO WS-Y
     MOVE WK-LABEL TO WS-KIND
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-LABEL-W WS-LABEL-H WS-OUT WS-OUT-LENGTH WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF SG-LEN(WS-I) > 0
             MOVE SPACES TO WS-TEXT
             MOVE SG-LINE-TEXT(WS-I)(1:SG-LEN(WS-I)) TO WS-TEXT
             MOVE WS-TEXT(1:256) TO WS-TEXT-256
             CALL "UI-TEXT-WIDTH" USING CLIENT-STATE WS-TEXT-256 SG-LEN(WS-I) WS-WIDTH
             COMPUTE WS-X = L-GW / 2 - WS-WIDTH / 2
             COMPUTE WS-Y = 60 + 10 * WS-I
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ARG WS-X WS-Y WS-LABEL-W WS-LABEL-H WS-TEXT SG-LEN(WS-I) WS-STATE
         END-IF
     END-PERFORM
     MOVE "gui.done" TO WS-KEY
     MOVE 8 TO WS-KEY-LENGTH
     COMPUTE WS-X = L-GW / 2 - 100
     COMPUTE WS-Y = L-GH / 4 + 144
     MOVE 200 TO WS-W
     MOVE 20 TO WS-H
     MOVE WK-BUTTON TO WS-KIND
     MOVE ACT-SIGN-DONE TO WS-ACTION
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY WS-KEY-LENGTH
     GOBACK.
 END PROGRAM SIGN-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-LEAVE.
*> USING CLIENT-STATE: any close of the sign editor (6.2 step 7): Sign Update is sent with the lines, then the world screen.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-WORLD.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "SIGN-CLOSE" USING CLIENT-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     GOBACK.
 END PROGRAM SIGN-LEAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SIGN-INPUT.
*> USING CLIENT-STATE: the frame's typed characters (allowed chat characters: from 32, not 127, not the section sign) go to the current line (SIGN-INSERT); Backspace removes the character
*> before the cursor; Up (GLFW 265), Down (264), Enter (257) and keypad Enter (335) select a line (SIGN-NAV, scancodes 82, 81, 40, 88); Escape closes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-BYTES               PIC X(4).
 01 WS-COUNT               BINARY-LONG.
 01 WS-TEXT                PIC X(1100).
 01 WS-SCAN                BINARY-LONG.
 01 WS-HANDLED             BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LEN                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IN-TEXT-COUNT
         IF IN-TEXT(WS-I) >= 32 AND IN-TEXT(WS-I) NOT = 127 AND IN-TEXT(WS-I) NOT = 167
             CALL "UTF8-ENCODE" USING IN-TEXT(WS-I) WS-BYTES WS-COUNT
             MOVE SPACES TO WS-TEXT
             MOVE WS-BYTES(1:WS-COUNT) TO WS-TEXT(1:WS-COUNT)
             CALL "SIGN-INSERT" USING CLIENT-STATE WS-TEXT WS-COUNT
         END-IF
     END-PERFORM
     IF IN-KEY-PRESSED(CC-KEY-BACKSPACE + 1) = 1 AND SG-CURSOR > 0
         MOVE SG-LINE-TEXT(SG-LINE + 1) TO WS-LINE
         MOVE SG-LEN(SG-LINE + 1) TO WS-LEN
         CALL "TEXT-DROP-LAST" USING WS-LINE WS-LEN
         MOVE WS-LINE TO SG-LINE-TEXT(SG-LINE + 1)
         MOVE WS-LEN TO SG-LEN(SG-LINE + 1) SG-CURSOR SG-ANCHOR
     END-IF
     MOVE 0 TO WS-SCAN
     IF IN-KEY-PRESSED(265 + 1) = 1
         MOVE 82 TO WS-SCAN
     END-IF
     IF IN-KEY-PRESSED(264 + 1) = 1
         MOVE 81 TO WS-SCAN
     END-IF
     IF IN-KEY-PRESSED(257 + 1) = 1
         MOVE 40 TO WS-SCAN
     END-IF
     IF IN-KEY-PRESSED(335 + 1) = 1
         MOVE 88 TO WS-SCAN
     END-IF
     IF WS-SCAN > 0
         CALL "SIGN-NAV" USING CLIENT-STATE WS-SCAN WS-HANDLED
     END-IF
     IF IN-KEY-PRESSED(CC-KEY-ESCAPE + 1) = 1
         CALL "SIGN-LEAVE" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM SIGN-INPUT.
