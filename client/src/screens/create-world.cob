*> The create-world screen (US16-1; 08 §10.8.6 create_world texts): the world name field (focused;
*> it starts with the default name, typed text goes into it, Backspace deletes its last character,
*> Enter creates), the game mode control (survival or creative, a click switches), the world type
*> control (US2: standard, the default, or cobolcraft, a click cycles; a Ctrl-click selects the hidden
*> debug type, which reads like the standard one: world-types.md §2.1), Create and Cancel.
*> Create names the folder (WORLD-FOLDER-NAME, client-surface §2) and opens the new world (SP-OPEN).
*> A standard or debug world with the packs not ok (CL-PACKS-STATUS) is not created: the screen shows
*> cobolcraft.world_type.standard.unavailable (world-types.md §8.2) and nothing else happens.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATE-WORLD-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 COPY CONTENT.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 200.
 01 WS-H                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE WK-LABEL TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 100
     MOVE 20 TO WS-Y
     MOVE "cobolcraft.screen.create_world.title" TO WS-KEY
     MOVE 36 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     MOVE 48 TO WS-Y
     MOVE "cobolcraft.screen.create_world.name" TO WS-KEY
     MOVE 35 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     MOVE WK-FIELD TO WS-KIND
     MOVE 58 TO WS-Y
     MOVE SM-EDIT-NAME TO WS-TEXT
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-W WS-H WS-TEXT
         SM-EDIT-NAME-LENGTH WS-STATE
*>   The game mode control: "Game mode: <mode name>".
     MOVE "cobolcraft.gamemode.survival" TO WS-KEY
     IF SP-CREATE-MODE = 1
         MOVE "cobolcraft.gamemode.creative" TO WS-KEY
     END-IF
     MOVE 28 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     MOVE 1 TO LA-COUNT
     MOVE WS-TEXT TO LA-TEXT(1)
     MOVE FUNCTION MIN(WS-LENGTH, 256) TO LA-LENGTH(1)
     MOVE "cobolcraft.screen.create_world.mode" TO WS-KEY
     MOVE 35 TO WS-KEY-LENGTH
     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
     MOVE WK-BUTTON TO WS-KIND
     MOVE ACT-WORLD-MODE TO WS-ACTION
     MOVE 90 TO WS-Y
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z1 WS-X WS-Y WS-W WS-H WS-TEXT
         WS-LENGTH WS-Z4
*>   The world type control: "World type: <type name>" (debug reads as the standard type).
     MOVE "cobolcraft.world_type.standard" TO WS-KEY
     MOVE 30 TO WS-KEY-LENGTH
     IF SP-CREATE-TYPE = CT-TYPE-COBOLCRAFT
         MOVE "cobolcraft.world_type.cobolcraft" TO WS-KEY
         MOVE 32 TO WS-KEY-LENGTH
     END-IF
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     MOVE 1 TO LA-COUNT
     MOVE WS-TEXT TO LA-TEXT(1)
     MOVE FUNCTION MIN(WS-LENGTH, 256) TO LA-LENGTH(1)
     MOVE "cobolcraft.screen.create_world.type" TO WS-KEY
     MOVE 35 TO WS-KEY-LENGTH
     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
     MOVE ACT-WORLD-TYPE TO WS-ACTION
     MOVE 112 TO WS-Y
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z1 WS-X WS-Y WS-W WS-H WS-TEXT
         WS-LENGTH WS-Z4
     MOVE 98 TO WS-W
     MOVE 150 TO WS-Y
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     MOVE "cobolcraft.screen.create_world.create" TO WS-KEY
     MOVE 37 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     ADD 102 TO WS-X
     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     MOVE "cobolcraft.screen.common.cancel" TO WS-KEY
     MOVE 31 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     IF SP-CREATE-REFUSED = 1
         MOVE WK-LABEL TO WS-KIND
         COMPUTE WS-X = L-GW / 2 - 100
         MOVE 176 TO WS-Y
         MOVE "cobolcraft.world_type.standard.unavailable" TO WS-KEY
         MOVE 42 TO WS-KEY-LENGTH
         CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
             WS-KEY-LENGTH
     END-IF
     GOBACK.
 END PROGRAM CREATE-WORLD-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATE-WORLD-INPUT.
*> USING CLIENT-STATE: typed code points (UTF-8 encoded) are appended to the name while it has
*> room (64 bytes); Backspace removes its last character; Enter creates the world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-I                   BINARY-LONG.
 01 WS-BYTES               PIC X(4).
 01 WS-COUNT               BINARY-LONG.
 01 WS-ACTION              BINARY-LONG VALUE ACT-CREATE-WORLD.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IN-TEXT-COUNT
         CALL "UTF8-ENCODE" USING IN-TEXT(WS-I) WS-BYTES WS-COUNT
         IF SM-EDIT-NAME-LENGTH + WS-COUNT <= 64
             MOVE WS-BYTES(1:WS-COUNT) TO SM-EDIT-NAME(SM-EDIT-NAME-LENGTH + 1:WS-COUNT)
             ADD WS-COUNT TO SM-EDIT-NAME-LENGTH
         END-IF
     END-PERFORM
     IF IN-KEY-PRESSED(CC-KEY-BACKSPACE + 1) = 1
         CALL "TEXT-DROP-LAST" USING SM-EDIT-NAME SM-EDIT-NAME-LENGTH
     END-IF
     IF IN-KEY-PRESSED(CC-KEY-ENTER + 1) = 1
         CALL "SCREEN-ACTION" USING CLIENT-STATE WS-ACTION WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM CREATE-WORLD-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATE-WORLD-CREATE.
*> USING CLIENT-STATE: Create: a standard or debug world with the packs not ok is refused (the screen
*> shows why); otherwise an empty name becomes the default name, the folder is named from the name and
*> the world created and opened in the chosen mode and type.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-KEY                 PIC X(80) VALUE "cobolcraft.screen.create_world.default_name".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 43.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-FOLDER              PIC X(80).
 01 WS-FOLDER-LENGTH       BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF SP-CREATE-TYPE NOT = CT-TYPE-COBOLCRAFT AND CL-PACKS-STATUS NOT = CT-PACKS-OK
         MOVE 1 TO SP-CREATE-REFUSED
         GOBACK
     END-IF
     MOVE SM-EDIT-NAME TO WS-NAME
     MOVE SM-EDIT-NAME-LENGTH TO WS-NAME-LENGTH
     IF WS-NAME-LENGTH = 0
         CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
         MOVE WS-TEXT(1:64) TO WS-NAME
         MOVE FUNCTION MIN(WS-LENGTH, 64) TO WS-NAME-LENGTH
     END-IF
     MOVE SP-CREATE-MODE TO WS-MODE
     CALL "WORLD-FOLDER-NAME" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-FOLDER
         WS-FOLDER-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     GOBACK.
 END PROGRAM CREATE-WORLD-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CREATE-WORLD-TYPE.
*> USING CLIENT-STATE: a click on the world type control: with Ctrl held (CONTROLS-CTRL-DOWN) the
*> hidden debug type; otherwise standard becomes cobolcraft and cobolcraft or debug becomes standard.
*> A refusal shown by the last Create goes away.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-CTRL                PIC 9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "CONTROLS-CTRL-DOWN" USING CLIENT-STATE WS-CTRL
     EVALUATE TRUE
         WHEN WS-CTRL = 1
             MOVE CT-TYPE-DEBUG TO SP-CREATE-TYPE
         WHEN SP-CREATE-TYPE = CT-TYPE-STANDARD
             MOVE CT-TYPE-COBOLCRAFT TO SP-CREATE-TYPE
         WHEN OTHER
             MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     END-EVALUATE
     MOVE 0 TO SP-CREATE-REFUSED
     GOBACK.
 END PROGRAM CREATE-WORLD-TYPE.
