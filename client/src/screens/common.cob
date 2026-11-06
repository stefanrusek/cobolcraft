*> The screen model (data-model §13; client-surface.md §3 controls; 08 §10.8.6 texts): SCREEN-OPEN
*> shows a screen; SCREEN-BUILD writes the current screen's widgets each frame (GUI pixels: the
*> window divided by CL-GUI-SCALE); SCREEN-INPUT routes the frame's clicks, typed text and keys to
*> the current screen; SCREEN-ACTION carries out what a widget does; WIDGET-ADD and WIDGET-ADD-KEY
*> append widgets (WIDGET-ADD-KEY takes its text from the language). The world screen shows the HUD
*> (hud.cob: crosshair, hotbar and chat area); E opens the inventory screen from the world and closes
*> it again; C opens the crafting screen (crafting.cob) from the world and closes it again; T opens
*> the chat screen (chat.cob) from the world, / opens it with / typed (a command, US14). The death
*> screen (death.cob) opens on Player Combat Kill and its respawn control sends Client Command.
*> Single-player (US16): the world list (world-list.cob), the create-world and confirm-delete
*> screens, and the pause menu's quit-world control (sp-host.cob). Opening to others (US17): the
*> pause menu's open-to-others screen (open-to-others.cob). Packs (US18): the title screen's
*> Resource Packs opens the pack selection screen (pack-select.cob) and its confirmation screen
*> (pack-confirm.cob); a server's pack offer opens the pack prompt (pack-prompt.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCREEN-OPEN.
*> USING CLIENT-STATE, screen id (SCR-*): nothing focused; the server list asks every entry for its
*> status again; chat opens with an empty line, scrolled to the newest message; the world list is
*> read from saves/ again, nothing selected; the create-world screen starts with the default name
*> and survival; the open-to-others screen starts with survival guests and no guest operators; the
*> pack screen lists resourcepacks/ again (LOCAL-PACKS-SCAN), nothing selected.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.create_world.default_name".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 43.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-Z1                   BINARY-LONG VALUE 0.
 01 WS-Z2                   BINARY-LONG VALUE 0.
 01 WS-Z3                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SCREEN               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SCREEN.
     MOVE L-SCREEN TO SM-SCREEN
     MOVE 0 TO SM-FOCUS SM-WIDGET-COUNT
     IF L-SCREEN = SCR-SERVER-LIST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SL-COUNT
             MOVE SLS-NONE TO SL-STATUS(WS-I)
         END-PERFORM
     END-IF
     IF L-SCREEN = SCR-CHAT
         MOVE SPACES TO CH-LINE
         MOVE 0 TO CH-LINE-LENGTH CH-SCROLL CS-COUNT CS-ANSWERS CS-ASKED-LENGTH CS-SHOWN
     END-IF
     IF L-SCREEN = SCR-WORLD-LIST
         CALL "WORLDS-LIST" USING CLIENT-STATE
         MOVE 0 TO SM-SELECTED
     END-IF
     IF L-SCREEN = SCR-CREATE-WORLD
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
         MOVE WS-TEXT(1:64) TO SM-EDIT-NAME
         MOVE FUNCTION MIN(WS-LENGTH, 64) TO SM-EDIT-NAME-LENGTH
         MOVE 0 TO SP-CREATE-MODE
     END-IF
     IF L-SCREEN = SCR-OPEN-TO-OTHERS
         MOVE 0 TO SP-GUEST-MODE SP-GUEST-OPERATOR
     END-IF
     IF L-SCREEN = SCR-PACKS
         CALL "LOCAL-PACKS-SCAN" USING CLIENT-STATE
         MOVE 0 TO SM-SELECTED
     END-IF
     GOBACK.
 END PROGRAM SCREEN-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCREEN-BUILD.
*> USING CLIENT-STATE: the widgets of the current screen.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-GW                  BINARY-LONG.
 01 WS-GH                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO SM-WIDGET-COUNT
     COMPUTE WS-GW = IN-WIN-W / CL-GUI-SCALE
     COMPUTE WS-GH = IN-WIN-H / CL-GUI-SCALE
     EVALUATE SM-SCREEN
         WHEN SCR-TITLE
             CALL "TITLE-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-SERVER-LIST
             CALL "SERVER-LIST-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-EDIT-SERVER
             CALL "EDIT-SERVER-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-CONNECTING
             CALL "CONNECTING-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-PAUSE
             CALL "PAUSE-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-WORLD
             CALL "HUD-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-INVENTORY
             CALL "INVENTORY-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-CRAFTING
             CALL "CRAFTING-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-CHAT
             CALL "CHAT-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-DEATH
             CALL "DEATH-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-WORLD-LIST
             CALL "WORLD-LIST-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-CREATE-WORLD
             CALL "CREATE-WORLD-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-CONFIRM-DELETE
             CALL "CONFIRM-DELETE-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-OPEN-TO-OTHERS
             CALL "OPEN-TO-OTHERS-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-PACKS
             CALL "PACK-SELECT-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-PACK-CONFIRM
             CALL "PACK-CONFIRM-BUILD" USING CLIENT-STATE WS-GW WS-GH
         WHEN SCR-PACK-PROMPT
             CALL "PACK-PROMPT-BUILD" USING CLIENT-STATE WS-GW WS-GH
     END-EVALUATE
     GOBACK.
 END PROGRAM SCREEN-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCREEN-INPUT.
*> USING CLIENT-STATE: a click on a widget (not a label, an overlay or a disabled widget) focuses a
*> field or does the widget's action; typed text
*> goes into the focused field, Backspace deletes its last character and Enter confirms; Escape
*> opens the pause menu from the world, returns to the world from it and to it from the
*> open-to-others screen, cancels editing, and leaves
*> the server list and the world list for the title screen, and the create-world and confirm-delete
*> screens for the world list; typed text goes to the create-world name (create-world.cob);
*> Escape leaves the pack screen as Done does and the pack confirmation for the pack screen;
*> Escape and E close the inventory screen, E opens it from the world; Escape and C close the crafting screen, C opens it from the world (as T); T opens chat
*> from the world (the screen the frame began on, so the T typed with it and a line just sent do
*> not reopen it), / opens it the same way with / typed, Escape closes chat; on the chat screen
*> the frame's typed text, keys and wheel go to the chat line (chat.cob).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-WAS                 BINARY-LONG.
 01 WS-Z1                   BINARY-LONG VALUE 0.
 01 WS-Z2                   BINARY-LONG VALUE 0.
 01 WS-Z3                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF IN-BUTTON-PRESSED(1) = 1
         COMPUTE WS-X = IN-CLICK-X / CL-GUI-SCALE
         COMPUTE WS-Y = IN-CLICK-Y / CL-GUI-SCALE
         MOVE 0 TO WS-HIT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT OR WS-HIT > 0
             IF SM-W-KIND(WS-I) NOT = WK-LABEL AND SM-W-KIND(WS-I) NOT = WK-OVERLAY
                     AND SM-W-STATE(WS-I) NOT = 2
                     AND WS-X >= SM-W-X(WS-I)
                     AND WS-X < SM-W-X(WS-I) + SM-W-W(WS-I) AND WS-Y >= SM-W-Y(WS-I)
                     AND WS-Y < SM-W-Y(WS-I) + SM-W-H(WS-I)
                 MOVE WS-I TO WS-HIT
             END-IF
         END-PERFORM
         IF WS-HIT > 0
             CALL "SCREEN-ACTION" USING CLIENT-STATE SM-W-ACTION(WS-HIT) SM-W-ARG(WS-HIT)
         END-IF
     END-IF
     MOVE SM-SCREEN TO WS-WAS
     IF SM-SCREEN = SCR-EDIT-SERVER
         CALL "EDIT-SERVER-INPUT" USING CLIENT-STATE
     END-IF
     IF SM-SCREEN = SCR-CHAT
         CALL "CHAT-INPUT" USING CLIENT-STATE
     END-IF
     IF SM-SCREEN = SCR-CREATE-WORLD AND WS-WAS = SCR-CREATE-WORLD
         CALL "CREATE-WORLD-INPUT" USING CLIENT-STATE
     END-IF
     IF IN-KEY-PRESSED(CC-KEY-T + 1) = 1 AND WS-WAS = SCR-WORLD AND SM-SCREEN = SCR-WORLD
         MOVE SCR-CHAT TO WS-SCREEN
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     END-IF
     IF IN-KEY-PRESSED(CC-KEY-SLASH + 1) = 1 AND WS-WAS = SCR-WORLD AND SM-SCREEN = SCR-WORLD
         MOVE SCR-CHAT TO WS-SCREEN
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
         MOVE "/" TO CH-LINE(1:1)
         MOVE 1 TO CH-LINE-LENGTH
         CALL "CHAT-SUGGEST" USING CLIENT-STATE
     END-IF
     IF IN-KEY-PRESSED(CC-KEY-C + 1) = 1 AND WS-WAS = SM-SCREEN
         MOVE 0 TO WS-SCREEN
         EVALUATE SM-SCREEN
             WHEN SCR-WORLD
                 MOVE SCR-CRAFTING TO WS-SCREEN
             WHEN SCR-CRAFTING
                 MOVE SCR-WORLD TO WS-SCREEN
         END-EVALUATE
         IF WS-SCREEN > 0
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
         END-IF
     END-IF
     IF IN-KEY-PRESSED(CC-KEY-ESCAPE + 1) = 1
         MOVE 0 TO WS-SCREEN
         EVALUATE SM-SCREEN
             WHEN SCR-WORLD
                 MOVE SCR-PAUSE TO WS-SCREEN
             WHEN SCR-PAUSE
                 MOVE SCR-WORLD TO WS-SCREEN
             WHEN SCR-OPEN-TO-OTHERS
                 MOVE SCR-PAUSE TO WS-SCREEN
             WHEN SCR-PACK-CONFIRM
                 MOVE SCR-PACKS TO WS-SCREEN
             WHEN SCR-PACKS
                 MOVE ACT-PACKS-DONE TO WS-ACTION
                 CALL "PACK-SELECT-ACTION" USING CLIENT-STATE WS-ACTION
             WHEN SCR-EDIT-SERVER
                 MOVE SCR-SERVER-LIST TO WS-SCREEN
             WHEN SCR-SERVER-LIST
             WHEN SCR-WORLD-LIST
                 MOVE SCR-TITLE TO WS-SCREEN
             WHEN SCR-CREATE-WORLD
             WHEN SCR-CONFIRM-DELETE
                 MOVE SCR-WORLD-LIST TO WS-SCREEN
             WHEN SCR-INVENTORY
             WHEN SCR-CRAFTING
             WHEN SCR-CHAT
                 MOVE SCR-WORLD TO WS-SCREEN
         END-EVALUATE
         IF WS-SCREEN > 0
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
         END-IF
     END-IF
     IF IN-KEY-PRESSED(CC-KEY-E + 1) = 1
         MOVE 0 TO WS-SCREEN
         EVALUATE SM-SCREEN
             WHEN SCR-WORLD
                 MOVE SCR-INVENTORY TO WS-SCREEN
             WHEN SCR-INVENTORY
                 MOVE SCR-WORLD TO WS-SCREEN
         END-EVALUATE
         IF WS-SCREEN > 0
             CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
         END-IF
     END-IF
     GOBACK.
 END PROGRAM SCREEN-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SCREEN-ACTION.
*> USING CLIENT-STATE, action (ACT-*), argument.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-Z1                   BINARY-LONG VALUE 0.
 01 WS-Z2                   BINARY-LONG VALUE 0.
 01 WS-Z3                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ACTION L-ARG.
     MOVE 0 TO WS-SCREEN
     EVALUATE L-ACTION
         WHEN ACT-MULTIPLAYER
         WHEN ACT-CANCEL
             MOVE SCR-SERVER-LIST TO WS-SCREEN
         WHEN ACT-QUIT
             MOVE 1 TO CL-QUIT
         WHEN ACT-BACK
             MOVE SCR-TITLE TO WS-SCREEN
         WHEN ACT-SELECT
             MOVE L-ARG TO SM-SELECTED
         WHEN ACT-ADD
             MOVE 0 TO SM-EDIT-INDEX SM-EDIT-NAME-LENGTH SM-EDIT-ADDR-LENGTH
             MOVE SPACES TO SM-EDIT-NAME SM-EDIT-ADDR
             MOVE SCR-EDIT-SERVER TO WS-SCREEN
         WHEN ACT-EDIT
             IF SM-SELECTED > 0
                 MOVE SM-SELECTED TO SM-EDIT-INDEX
                 MOVE SL-NAME(SM-SELECTED) TO SM-EDIT-NAME
                 MOVE SL-NAME-LENGTH(SM-SELECTED) TO SM-EDIT-NAME-LENGTH
                 MOVE SL-ADDR(SM-SELECTED) TO SM-EDIT-ADDR
                 MOVE SL-ADDR-LENGTH(SM-SELECTED) TO SM-EDIT-ADDR-LENGTH
                 MOVE SCR-EDIT-SERVER TO WS-SCREEN
             END-IF
         WHEN ACT-REMOVE
             IF SM-SELECTED > 0
                 PERFORM VARYING WS-I FROM SM-SELECTED BY 1 UNTIL WS-I >= SL-COUNT
                     MOVE SL-ENTRY(WS-I + 1) TO SL-ENTRY(WS-I)
                 END-PERFORM
                 SUBTRACT 1 FROM SL-COUNT
                 MOVE 0 TO SM-SELECTED
                 CALL "SERVERS-SAVE" USING CLIENT-STATE
             END-IF
         WHEN ACT-DONE
             IF SM-EDIT-INDEX = 0 AND SL-COUNT < CL-MAX-SERVERS
                 ADD 1 TO SL-COUNT
                 MOVE SL-COUNT TO SM-EDIT-INDEX
                 INITIALIZE SL-ENTRY(SL-COUNT)
             END-IF
             IF SM-EDIT-INDEX > 0
                 MOVE SM-EDIT-NAME TO SL-NAME(SM-EDIT-INDEX)
                 MOVE SM-EDIT-NAME-LENGTH TO SL-NAME-LENGTH(SM-EDIT-INDEX)
                 MOVE SM-EDIT-ADDR TO SL-ADDR(SM-EDIT-INDEX)
                 MOVE SM-EDIT-ADDR-LENGTH TO SL-ADDR-LENGTH(SM-EDIT-INDEX)
                 CALL "SERVERS-SAVE" USING CLIENT-STATE
             END-IF
             MOVE SCR-SERVER-LIST TO WS-SCREEN
         WHEN ACT-FIELD-NAME
             MOVE 1 TO SM-FOCUS
         WHEN ACT-FIELD-ADDRESS
             MOVE 2 TO SM-FOCUS
         WHEN ACT-JOIN
             IF SM-SELECTED > 0
                 MOVE SM-SELECTED TO RP-ENTRY-JOINED
                 MOVE SL-ADDR(SM-SELECTED) TO SM-CONNECT-ADDR
                 MOVE SL-ADDR-LENGTH(SM-SELECTED) TO SM-CONNECT-ADDR-LENGTH
                 MOVE 0 TO SM-MESSAGE-LENGTH
                 MOVE SCR-CONNECTING TO WS-SCREEN
                 CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
                 MOVE 0 TO WS-SCREEN
                 MOVE CONN-GAME TO WS-CONN
                 MOVE PH-LOGIN TO WS-NEXT
                 CALL "NET-OPEN" USING CLIENT-STATE WS-CONN SM-CONNECT-ADDR
                     SM-CONNECT-ADDR-LENGTH WS-NEXT
             END-IF
         WHEN ACT-RESUME
             MOVE SCR-WORLD TO WS-SCREEN
         WHEN ACT-SLOT
             CALL "INVENTORY-CLICK" USING CLIENT-STATE L-ARG
         WHEN ACT-RESPAWN
             CALL "DEATH-RESPAWN" USING CLIENT-STATE
         WHEN ACT-CRAFT
             CALL "CRAFTING-CRAFT" USING CLIENT-STATE L-ARG
         WHEN ACT-SINGLE-PLAYER
             MOVE SCR-WORLD-LIST TO WS-SCREEN
         WHEN ACT-PLAY-WORLD
             CALL "WORLD-PLAY" USING CLIENT-STATE
         WHEN ACT-NEW-WORLD
             MOVE SCR-CREATE-WORLD TO WS-SCREEN
         WHEN ACT-DELETE-WORLD
             IF SM-SELECTED > 0
                 MOVE SCR-CONFIRM-DELETE TO WS-SCREEN
             END-IF
         WHEN ACT-CREATE-WORLD
             CALL "CREATE-WORLD-CREATE" USING CLIENT-STATE
         WHEN ACT-WORLD-MODE
             COMPUTE SP-CREATE-MODE = 1 - SP-CREATE-MODE
         WHEN ACT-CONFIRM-DELETE
             CALL "CONFIRM-DELETE-DELETE" USING CLIENT-STATE
         WHEN ACT-QUIT-WORLD
             CALL "SP-QUIT" USING CLIENT-STATE
         WHEN ACT-OPEN-TO-OTHERS
             MOVE SCR-OPEN-TO-OTHERS TO WS-SCREEN
         WHEN ACT-GUEST-MODE
             COMPUTE SP-GUEST-MODE = 1 - SP-GUEST-MODE
         WHEN ACT-GUEST-OPERATOR
             COMPUTE SP-GUEST-OPERATOR = 1 - SP-GUEST-OPERATOR
         WHEN ACT-OPEN-WORLD
             CALL "SP-OPEN-OTHERS" USING CLIENT-STATE
         WHEN ACT-PAUSE
             MOVE SCR-PAUSE TO WS-SCREEN
         WHEN ACT-PACKS
             MOVE SCR-PACKS TO WS-SCREEN
         WHEN ACT-PACK-ENABLE
         WHEN ACT-PACK-DISABLE
         WHEN ACT-PACK-UP
         WHEN ACT-PACK-DOWN
         WHEN ACT-PACK-CONFIRM
         WHEN ACT-PACKS-DONE
             CALL "PACK-SELECT-ACTION" USING CLIENT-STATE L-ACTION
         WHEN ACT-PACK-ACCEPT
         WHEN ACT-PACK-DECLINE
             COMPUTE WS-I = ACT-PACK-DECLINE - L-ACTION
             CALL "PACK-PROMPT-ANSWER" USING CLIENT-STATE WS-I
         WHEN ACT-DISCONNECT
             MOVE CONN-GAME TO WS-CONN
             CALL "NET-CLOSE" USING CLIENT-STATE WS-CONN
             CALL "WORLD-CLEAR" USING CLIENT-STATE
             MOVE 0 TO SM-MESSAGE-LENGTH
             MOVE SCR-SERVER-LIST TO WS-SCREEN
     END-EVALUATE
     IF WS-SCREEN > 0
         CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     END-IF
     GOBACK.
 END PROGRAM SCREEN-ACTION.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIDGET-ADD-KEY.
*> USING CLIENT-STATE, kind, action, x, y, width, height, lang key (PIC X(80)), key length: a widget
*> (argument 0, normal state) showing the key's text.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-Z1                   BINARY-LONG VALUE 0.
 01 WS-Z2                   BINARY-LONG VALUE 0.
 01 WS-Z3                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KIND                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-KEY                  PIC X(80).
 01 L-KEY-LENGTH           BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KIND L-ACTION L-X L-Y L-W L-H L-KEY L-KEY-LENGTH.
     CALL "LANG-GET" USING CLIENT-STATE L-KEY L-KEY-LENGTH WS-TEXT WS-LENGTH
     CALL "WIDGET-ADD" USING CLIENT-STATE L-KIND L-ACTION WS-Z1 L-X L-Y L-W L-H WS-TEXT WS-LENGTH
         WS-Z2
     GOBACK.
 END PROGRAM WIDGET-ADD-KEY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WIDGET-ADD.
*> USING CLIENT-STATE, kind, action, argument, x, y, width, height, text (PIC X(512)), length,
*> state: appends a widget while the screen model has room (texts are cut at 256 bytes).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-Z1                   BINARY-LONG VALUE 0.
 01 WS-Z2                   BINARY-LONG VALUE 0.
 01 WS-Z3                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-KIND                 BINARY-LONG.
 01 L-ACTION               BINARY-LONG.
 01 L-ARG                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-KIND L-ACTION L-ARG L-X L-Y L-W L-H L-TEXT L-LENGTH
         L-STATE.
     IF SM-WIDGET-COUNT < CL-MAX-WIDGETS
         ADD 1 TO SM-WIDGET-COUNT
         MOVE L-KIND TO SM-W-KIND(SM-WIDGET-COUNT)
         MOVE L-ACTION TO SM-W-ACTION(SM-WIDGET-COUNT)
         MOVE L-ARG TO SM-W-ARG(SM-WIDGET-COUNT)
         MOVE L-X TO SM-W-X(SM-WIDGET-COUNT)
         MOVE L-Y TO SM-W-Y(SM-WIDGET-COUNT)
         MOVE L-W TO SM-W-W(SM-WIDGET-COUNT)
         MOVE L-H TO SM-W-H(SM-WIDGET-COUNT)
         MOVE L-TEXT TO SM-W-TEXT(SM-WIDGET-COUNT)
         MOVE FUNCTION MIN(L-LENGTH, 256) TO SM-W-LENGTH(SM-WIDGET-COUNT)
         MOVE L-STATE TO SM-W-STATE(SM-WIDGET-COUNT)
     END-IF
     GOBACK.
 END PROGRAM WIDGET-ADD.
