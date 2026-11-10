*> The options screen (US16; 13 §7.2, §7.6; Decision of builtin-ui-art 6.2: texts): the options of the table CLOPTS.cpy, 7 to a page, one
*> button each labelled "<name>: <value>" (a key option shows "> Press a key <" while it waits), Previous Page, Next Page and Done.
*> A button changes its option to the next value (a flag toggles, a named value goes on to the next name, a number goes up by a tenth of its
*> range and wraps to the minimum; a key option waits for the next key, Escape unbinds it) and the change is applied (OPTIONS-APPLY) and
*> saved (OPTIONS-SAVE) at once. Opened from the title screen and the pause menu (ACT-OPTIONS); Done and Escape return there.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLOPTS.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PAGES               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 200.
 01 WS-H                   BINARY-LONG VALUE 20.
 01 WS-HALF                BINARY-LONG VALUE 98.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LABEL               PIC X(512).
 01 WS-LABEL-LENGTH        BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-N1                  PIC Z(3)9.
 01 WS-N2                  PIC Z(3)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     COMPUTE WS-PAGES = (OT-COUNT + 6) / 7
     IF OP-PAGE < 0
         MOVE 0 TO OP-PAGE
     END-IF
     IF OP-PAGE >= WS-PAGES
         COMPUTE OP-PAGE = WS-PAGES - 1
     END-IF
*>   The title with the page number.
     MOVE "cobolcraft.screen.options.title" TO WS-KEY
     MOVE 31 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     COMPUTE WS-N1 = OP-PAGE + 1
     MOVE WS-PAGES TO WS-N2
     MOVE SPACES TO WS-LABEL
     MOVE 1 TO WS-PTR
     STRING WS-TEXT(1:WS-LENGTH) " (" FUNCTION TRIM(WS-N1) "/" FUNCTION TRIM(WS-N2) ")" DELIMITED BY SIZE
         INTO WS-LABEL WITH POINTER WS-PTR
     COMPUTE WS-LABEL-LENGTH = WS-PTR - 1
     MOVE WK-LABEL TO WS-KIND
     MOVE 0 TO WS-ACTION
     COMPUTE WS-X = L-GW / 2 - WS-LABEL-LENGTH * 3
     MOVE 14 TO WS-Y
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ZERO WS-X WS-Y WS-Z2 WS-Z3
         WS-LABEL WS-LABEL-LENGTH WS-Z4
*>   The seven options of the page.
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 6
         COMPUTE WS-ROW = OP-PAGE * 7 + WS-I + 1
         IF WS-ROW <= OT-COUNT
             MOVE SPACES TO WS-LABEL
             MOVE 1 TO WS-PTR
             IF OP-REBIND = WS-ROW
                 MOVE "cobolcraft.screen.options.press_key" TO WS-KEY
                 MOVE 35 TO WS-KEY-LENGTH
                 CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
                 STRING FUNCTION TRIM(OT-NAME(WS-ROW)) ": " WS-TEXT(1:WS-LENGTH) DELIMITED BY SIZE
                     INTO WS-LABEL WITH POINTER WS-PTR
             ELSE
                 IF OP-OPT-LEN(WS-ROW) > 0
                     STRING FUNCTION TRIM(OT-NAME(WS-ROW)) ": " OP-OPT-VALUE(WS-ROW)(1:OP-OPT-LEN(WS-ROW))
                         DELIMITED BY SIZE INTO WS-LABEL WITH POINTER WS-PTR
                 ELSE
                     STRING FUNCTION TRIM(OT-NAME(WS-ROW)) ": " DELIMITED BY SIZE INTO WS-LABEL WITH POINTER WS-PTR
                 END-IF
             END-IF
             COMPUTE WS-LABEL-LENGTH = WS-PTR - 1
             MOVE WK-BUTTON TO WS-KIND
             MOVE ACT-OPTION TO WS-ACTION
             COMPUTE WS-X = L-GW / 2 - 100
             COMPUTE WS-Y = 34 + 22 * WS-I
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ROW WS-X WS-Y WS-W WS-H
                 WS-LABEL WS-LABEL-LENGTH WS-ZERO
         END-IF
     END-PERFORM
*>   Previous Page and Next Page side by side, Done below.
     MOVE WK-BUTTON TO WS-KIND
     MOVE ACT-OPTIONS-PREV TO WS-ACTION
     MOVE "cobolcraft.screen.options.previous" TO WS-KEY
     MOVE 34 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     COMPUTE WS-X = L-GW / 2 - 100
     MOVE 192 TO WS-Y
     MOVE 0 TO WS-I
     IF OP-PAGE = 0
         MOVE 2 TO WS-I
     END-IF
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ZERO WS-X WS-Y WS-HALF WS-H
         WS-TEXT WS-LENGTH WS-I
     MOVE ACT-OPTIONS-NEXT TO WS-ACTION
     MOVE "cobolcraft.screen.options.next" TO WS-KEY
     MOVE 30 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     COMPUTE WS-X = L-GW / 2 + 2
     MOVE 0 TO WS-I
     IF OP-PAGE = WS-PAGES - 1
         MOVE 2 TO WS-I
     END-IF
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ZERO WS-X WS-Y WS-HALF WS-H
         WS-TEXT WS-LENGTH WS-I
     MOVE ACT-OPTIONS-DONE TO WS-ACTION
     MOVE "cobolcraft.screen.common.done" TO WS-KEY
     MOVE 29 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     COMPUTE WS-X = L-GW / 2 - 100
     MOVE 216 TO WS-Y
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-ZERO WS-X WS-Y WS-W WS-H
         WS-TEXT WS-LENGTH WS-Z2
     GOBACK.
 END PROGRAM OPTIONS-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-CYCLE.
*> USING CLIENT-STATE, row: the next value of the option of that row (a flag toggles; a named value goes to the next name and wraps; a number
*> goes up by a tenth of its range, at least 1 for an integer, and wraps to the minimum; a key option waits for a key, OP-REBIND; text is
*> not changed here), then OPTIONS-APPLY and OPTIONS-SAVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLOPTS.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-N                   PIC S9(9)V99.
 01 WS-MIN                 PIC S9(9)V99.
 01 WS-MAX                 PIC S9(9)V99.
 01 WS-STEP                PIC S9(9)V99.
 01 WS-INT-EDIT            PIC -(9)9.
 01 WS-DEC-EDIT            PIC -(9)9.99.
 01 WS-TOKENS.
    05 WS-TOKEN            PIC X(20) OCCURS 6 TIMES.
 01 WS-TOKEN-COUNT         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-TEXT                PIC X(48).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ROW.
     MOVE 0 TO WS-CHANGED
     MOVE SPACES TO WS-VALUE
     MOVE OT-NAME(L-ROW) TO WS-NAME
     EVALUATE OT-KIND(L-ROW)
         WHEN "B"
             MOVE 1 TO WS-CHANGED
             IF OP-OPT-VALUE(L-ROW)(1:4) = "true"
                 MOVE "false" TO WS-VALUE
                 MOVE 5 TO WS-LENGTH
             ELSE
                 MOVE "true" TO WS-VALUE
                 MOVE 4 TO WS-LENGTH
             END-IF
         WHEN "J"
*>           The names of the row's list; the one after the current value, the first after the last.
             MOVE SPACES TO WS-TOKENS
             MOVE 0 TO WS-TOKEN-COUNT
             UNSTRING OT-ENUM(L-ROW) DELIMITED BY "|" INTO WS-TOKEN(1) WS-TOKEN(2) WS-TOKEN(3) WS-TOKEN(4)
                 WS-TOKEN(5) WS-TOKEN(6) TALLYING IN WS-TOKEN-COUNT
             MOVE 1 TO WS-AT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TOKEN-COUNT
                 IF FUNCTION TRIM(WS-TOKEN(WS-I)) = OP-OPT-VALUE(L-ROW)(1:OP-OPT-LEN(L-ROW))
                     COMPUTE WS-AT = WS-I + 1
                 END-IF
             END-PERFORM
             IF WS-AT > WS-TOKEN-COUNT
                 MOVE 1 TO WS-AT
             END-IF
             MOVE FUNCTION TRIM(WS-TOKEN(WS-AT)) TO WS-VALUE
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN(WS-AT))) TO WS-LENGTH
             MOVE 1 TO WS-CHANGED
         WHEN "I"
             COMPUTE WS-N = FUNCTION NUMVAL(OP-OPT-VALUE(L-ROW)(1:OP-OPT-LEN(L-ROW)))
             COMPUTE WS-MIN = FUNCTION NUMVAL(OT-MIN(L-ROW))
             COMPUTE WS-MAX = FUNCTION NUMVAL(OT-MAX(L-ROW))
             COMPUTE WS-STEP = FUNCTION MAX(1, FUNCTION INTEGER((WS-MAX - WS-MIN) / 10))
             ADD WS-STEP TO WS-N
             IF WS-N > WS-MAX
                 MOVE WS-MIN TO WS-N
             END-IF
             MOVE WS-N TO WS-INT-EDIT
             MOVE FUNCTION TRIM(WS-INT-EDIT) TO WS-VALUE
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-INT-EDIT)) TO WS-LENGTH
             MOVE 1 TO WS-CHANGED
         WHEN "F"
             COMPUTE WS-N = FUNCTION NUMVAL(OP-OPT-VALUE(L-ROW)(1:OP-OPT-LEN(L-ROW)))
             COMPUTE WS-MIN = FUNCTION NUMVAL(OT-MIN(L-ROW))
             COMPUTE WS-MAX = FUNCTION NUMVAL(OT-MAX(L-ROW))
             COMPUTE WS-STEP = (WS-MAX - WS-MIN) / 10
             ADD WS-STEP TO WS-N
             IF WS-N > WS-MAX
                 MOVE WS-MIN TO WS-N
             END-IF
             MOVE WS-N TO WS-DEC-EDIT
             MOVE FUNCTION TRIM(WS-DEC-EDIT) TO WS-VALUE
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DEC-EDIT)) TO WS-LENGTH
             MOVE 1 TO WS-CHANGED
         WHEN "K"
             MOVE L-ROW TO OP-REBIND
     END-EVALUATE
     IF WS-CHANGED = 1
         CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-OK
         CALL "OPTIONS-APPLY" USING CLIENT-STATE
         CALL "OPTIONS-SAVE" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM OPTIONS-CYCLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-REBIND.
*> USING CLIENT-STATE, GLFW key code (0 = unbound): the waiting key option (OP-REBIND) takes the key of that code, by the first
*> name of the key table that has it ("key.keyboard.unknown" for 0); applied and saved. A code the table does not know leaves it waiting.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLOPTS.
 01 WS-NAME                PIC X(40).
 01 WS-VALUE               PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-CODE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-CODE.
     MOVE 0 TO WS-AT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KT-COUNT OR WS-AT > 0
         IF KT-GLFW(WS-I) = L-CODE AND (L-CODE > 0 OR KT-NAME(WS-I) = "key.keyboard.unknown")
             MOVE WS-I TO WS-AT
         END-IF
     END-PERFORM
     IF WS-AT > 0 AND OP-REBIND > 0
         MOVE OT-NAME(OP-REBIND) TO WS-NAME
         MOVE SPACES TO WS-VALUE
         MOVE FUNCTION TRIM(KT-NAME(WS-AT)) TO WS-VALUE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(KT-NAME(WS-AT))) TO WS-LENGTH
         CALL "OPTIONS-SET" USING CLIENT-STATE WS-NAME WS-VALUE WS-LENGTH WS-OK
         MOVE 0 TO OP-REBIND
         CALL "OPTIONS-APPLY" USING CLIENT-STATE
         CALL "OPTIONS-SAVE" USING CLIENT-STATE
     END-IF
     GOBACK.
 END PROGRAM OPTIONS-REBIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-INPUT.
*> USING CLIENT-STATE: on the options screen with a key option waiting, the first key pressed in the frame is its new key (Escape
*> unbinds it, and is then not seen by the screen); nothing otherwise.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-CODE                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF SM-SCREEN = SCR-OPTIONS AND OP-REBIND > 0
         MOVE 0 TO WS-DONE
         PERFORM VARYING WS-CODE FROM 1 BY 1 UNTIL WS-CODE > 399 OR WS-DONE = 1
             IF IN-KEY-PRESSED(WS-CODE + 1) = 1
                 MOVE 1 TO WS-DONE
                 IF WS-CODE = CC-KEY-ESCAPE
                     CALL "OPTIONS-REBIND" USING CLIENT-STATE WS-ZERO
                     MOVE 0 TO IN-KEY-PRESSED(WS-CODE + 1)
                 ELSE
                     CALL "OPTIONS-REBIND" USING CLIENT-STATE WS-CODE
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM OPTIONS-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-ACTION.
*> USING CLIENT-STATE, action (ACT-OPTION, ACT-OPTIONS-PREV, ACT-OPTIONS-NEXT), argument (the row of ACT-OPTION).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-ARG.
     EVALUATE L-ACTION
         WHEN ACT-OPTION
             MOVE 0 TO OP-REBIND
             CALL "OPTIONS-CYCLE" USING CLIENT-STATE L-ARG
         WHEN ACT-OPTIONS-PREV
             MOVE 0 TO OP-REBIND
             SUBTRACT 1 FROM OP-PAGE
         WHEN ACT-OPTIONS-NEXT
             MOVE 0 TO OP-REBIND
             ADD 1 TO OP-PAGE
     END-EVALUATE
     GOBACK.
 END PROGRAM OPTIONS-ACTION.
