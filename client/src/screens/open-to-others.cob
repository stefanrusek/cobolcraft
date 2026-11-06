*> The open-to-others screen (US17-1; 08 §10.8.6 open_to_others texts), from the pause menu of a
*> hosted world. Before the world is opened: the guest game mode control (survival or creative, a
*> click switches), the guest-operator control (No or Yes, a click switches), Open the World
*> (sp-host.cob SP-OPEN-OTHERS) and Cancel (the pause menu). Once opened: "Others can join at
*> <address>:<port>" for each local address, and Back to the World.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPEN-TO-OTHERS-BUILD.
*> USING CLIENT-STATE, GUI width, GUI height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY CLARGS.
 01 WS-KIND                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 200.
 01 WS-H                   BINARY-LONG VALUE 20.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PORT                PIC Z(4)9.
 01 WS-ADDRESS             PIC X(32).
 01 WS-ADDRESS-LENGTH      BINARY-LONG.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-Z4                  BINARY-LONG VALUE 0.
 01 WS-Z5                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-GW                   BINARY-LONG.
 01 L-GH                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-GW L-GH.
     MOVE WK-LABEL TO WS-KIND
     COMPUTE WS-X = L-GW / 2 - 100
     MOVE 20 TO WS-Y
     MOVE "cobolcraft.screen.open_to_others.title" TO WS-KEY
     MOVE 38 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-Z1 WS-X WS-Y WS-Z2 WS-Z3 WS-KEY
         WS-KEY-LENGTH
     IF SP-LISTENER > 0
*>       Opened: one line per address, then Back to the World.
         MOVE SP-PORT TO WS-PORT
         MOVE "cobolcraft.screen.open_to_others.address" TO WS-KEY
         MOVE 40 TO WS-KEY-LENGTH
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-ADDR-COUNT
             MOVE SP-ADDR-LENGTH(WS-I) TO WS-LENGTH
             MOVE SPACES TO WS-ADDRESS
             STRING SP-ADDR-TEXT(WS-I)(1:WS-LENGTH) ":" FUNCTION TRIM(WS-PORT)
                 DELIMITED BY SIZE INTO WS-ADDRESS
             MOVE 1 TO LA-COUNT
             MOVE WS-ADDRESS TO LA-TEXT(1)
             MOVE FUNCTION STORED-CHAR-LENGTH(WS-ADDRESS) TO LA-LENGTH(1)
             CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT
                 WS-LENGTH
             COMPUTE WS-Y = 40 + WS-I * 14
             CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-Z1 WS-Z2 WS-X WS-Y WS-Z3 WS-Z4
                 WS-TEXT WS-LENGTH WS-Z5
         END-PERFORM
         MOVE WK-BUTTON TO WS-KIND
         COMPUTE WS-Y = 60 + SP-ADDR-COUNT * 14
         MOVE ACT-RESUME TO WS-ACTION
         MOVE "cobolcraft.screen.pause.resume" TO WS-KEY
         MOVE 30 TO WS-KEY-LENGTH
         CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
             WS-KEY-LENGTH
         GOBACK
     END-IF
*>   The guest game mode control: "Guest game mode: <mode name>".
     MOVE "cobolcraft.gamemode.survival" TO WS-KEY
     IF SP-GUEST-MODE = 1
         MOVE "cobolcraft.gamemode.creative" TO WS-KEY
     END-IF
     MOVE 28 TO WS-KEY-LENGTH
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     MOVE 1 TO LA-COUNT
     MOVE WS-TEXT TO LA-TEXT(1)
     MOVE FUNCTION MIN(WS-LENGTH, 256) TO LA-LENGTH(1)
     MOVE "cobolcraft.screen.open_to_others.mode" TO WS-KEY
     MOVE 37 TO WS-KEY-LENGTH
     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
     MOVE WK-BUTTON TO WS-KIND
     MOVE ACT-GUEST-MODE TO WS-ACTION
     MOVE 60 TO WS-Y
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z1 WS-X WS-Y WS-W WS-H WS-TEXT
         WS-LENGTH WS-Z4
*>   The guest-operator control: "Guests may use operator commands: <Yes or No>".
     MOVE "cobolcraft.screen.common.no" TO WS-KEY
     MOVE 27 TO WS-KEY-LENGTH
     IF SP-GUEST-OPERATOR = 1
         MOVE "cobolcraft.screen.common.yes" TO WS-KEY
         MOVE 28 TO WS-KEY-LENGTH
     END-IF
     CALL "LANG-GET" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH WS-TEXT WS-LENGTH
     MOVE 1 TO LA-COUNT
     MOVE WS-TEXT TO LA-TEXT(1)
     MOVE FUNCTION MIN(WS-LENGTH, 256) TO LA-LENGTH(1)
     MOVE "cobolcraft.screen.open_to_others.operators" TO WS-KEY
     MOVE 42 TO WS-KEY-LENGTH
     CALL "LANG-FORMAT" USING CLIENT-STATE WS-KEY WS-KEY-LENGTH LANG-ARGS WS-TEXT WS-LENGTH
     MOVE ACT-GUEST-OPERATOR TO WS-ACTION
     MOVE 86 TO WS-Y
     CALL "WIDGET-ADD" USING CLIENT-STATE WS-KIND WS-ACTION WS-Z1 WS-X WS-Y WS-W WS-H WS-TEXT
         WS-LENGTH WS-Z4
     MOVE 98 TO WS-W
     MOVE 130 TO WS-Y
     MOVE ACT-OPEN-WORLD TO WS-ACTION
     MOVE "cobolcraft.screen.open_to_others.start" TO WS-KEY
     MOVE 38 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     ADD 102 TO WS-X
     MOVE ACT-PAUSE TO WS-ACTION
     MOVE "cobolcraft.screen.common.cancel" TO WS-KEY
     MOVE 31 TO WS-KEY-LENGTH
     CALL "WIDGET-ADD-KEY" USING CLIENT-STATE WS-KIND WS-ACTION WS-X WS-Y WS-W WS-H WS-KEY
         WS-KEY-LENGTH
     GOBACK.
 END PROGRAM OPEN-TO-OTHERS-BUILD.
