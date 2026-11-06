*> The single-player host (US16; research R7; contracts/core-host-api.md §2): the client runs the
*> game core in its own process and joins it over a memory connection. SP-DEFAULTS holds the
*> settings of a hosted world (the server defaults of operator-surface §2, the allow-list off);
*> SP-OPEN opens a world folder under saves/ with CORE-WORLD-OPEN (host kind 1, the Player's name
*> as host name, the chosen game mode and name for a new world, which is saved at once so the world
*> list shows it) and joins it (NET-OPEN-MEMORY); SP-PUMP, once per frame while hosting, runs one
*> CORE-TICK per elapsed 50 ms (none while the pause menu is open and the world is not opened to
*> others, US16-4), prints the core's console lines on the terminal and ends hosting when the core
*> was told to stop (the shutdown command: the host quitting) or the connection has ended; SP-QUIT
*> is the quit-world control: CORE-STOP (saves the world), the connection closed, back to the title
*> screen (US16-5).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-DEFAULTS.
*> USING CLIENT-STATE: SP-SETTINGS for a hosted world: survival, the operator-surface §2 defaults
*> (description, view distance 8, combat, hostile mobs, weather changes and extra dimensions on),
*> no allow-list (a new single-player world seeds AllowListEnforced 0, 07 §9.2), no server pack,
*> host kind 1 (SP-OPEN adds the host name, game mode and world name).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     INITIALIZE CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE "A CobolCraft server" TO CS-DESCRIPTION
     MOVE 8 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-PLAYER-COMBAT CS-HOSTILE-MOBS CS-WEATHER-CHANGES CS-EXTRA-DIMENSIONS
     MOVE 0 TO CS-ALLOW-LIST-ENFORCED CS-PACK-OFFERED CS-PACK-REQUIRED
     MOVE 1 TO CS-HOST-KIND
     MOVE CORE-SETTINGS TO SP-SETTINGS
     GOBACK.
 END PROGRAM SP-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-OPEN.
*> USING CLIENT-STATE, folder (PIC X(80), under saves/), folder length, world name (PIC X(64)),
*> name length, game mode (BINARY-LONG): opens the world (a new one when the folder has no
*> level.dat) and joins it; the connecting screen shows the world name.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY COREAPI.
 01 WS-PATH                PIC X(1200).
 01 WS-CREATED             BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CONNECTING.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-FOLDER               PIC X(80).
 01 L-FOLDER-LENGTH        BINARY-LONG.
 01 L-NAME                 PIC X(64).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-MODE                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-FOLDER L-FOLDER-LENGTH L-NAME L-NAME-LENGTH L-MODE.
     MOVE L-FOLDER TO SP-FOLDER
     MOVE L-FOLDER-LENGTH TO SP-FOLDER-LENGTH
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE 1 TO CS-HOST-KIND
     MOVE CL-NAME TO CS-HOST-NAME
     MOVE L-MODE TO CS-DEFAULT-MODE
     MOVE SPACES TO CS-NEW-WORLD-NAME
     MOVE L-NAME(1:L-NAME-LENGTH) TO CS-NEW-WORLD-NAME
     MOVE CORE-SETTINGS TO SP-SETTINGS
     MOVE LOW-VALUES TO WS-PATH
     STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/saves/" L-FOLDER(1:L-FOLDER-LENGTH)
         DELIMITED BY SIZE INTO WS-PATH
     CALL "CORE-WORLD-OPEN" USING WS-PATH CORE-SETTINGS WS-CREATED
     IF WS-CREATED = 1
         CALL "CORE-SAVE"
     END-IF
     MOVE 1 TO SP-ACTIVE
     MOVE 0 TO SP-TICKS SP-PAUSED
     COMPUTE SP-NEXT-TICK = CL-NOW-MS + CL-TICK-MS
     MOVE SPACES TO SM-CONNECT-ADDR
     MOVE L-NAME(1:L-NAME-LENGTH) TO SM-CONNECT-ADDR
     MOVE L-NAME-LENGTH TO SM-CONNECT-ADDR-LENGTH
     MOVE 0 TO SM-MESSAGE-LENGTH
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "NET-OPEN-MEMORY" USING CLIENT-STATE WS-CONN
     GOBACK.
 END PROGRAM SP-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-PUMP.
*> USING CLIENT-STATE (hosting): the frame's core ticks (one per elapsed 50 ms of CL-NOW-MS; while
*> paused the tick clock is held, so resuming does not catch up), the console lines, and the end
*> of hosting: run state 1 (the shutdown command) quits the world; a game connection that has
*> ended (a Disconnect, or lost) stops the core, leaving the screen the disconnect chose.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY COREAPI.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE 0 TO SP-PAUSED
     IF SM-SCREEN = SCR-PAUSE AND CS-HOST-KIND = 1
         MOVE 1 TO SP-PAUSED
         COMPUTE SP-NEXT-TICK = CL-NOW-MS + CL-TICK-MS
     END-IF
     PERFORM UNTIL CL-NOW-MS < SP-NEXT-TICK
         CALL "CORE-TICK"
         ADD 1 TO SP-TICKS
         ADD CL-TICK-MS TO SP-NEXT-TICK
     END-PERFORM
     CALL "SP-CONSOLE"
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     EVALUATE TRUE
         WHEN CST-RUN-STATE = 1
             CALL "SP-QUIT" USING CLIENT-STATE
         WHEN CN-PHASE(CONN-GAME) = PH-NONE
             CALL "SP-STOP" USING CLIENT-STATE
     END-EVALUATE
     GOBACK.
 END PROGRAM SP-PUMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-STOP.
*> USING CLIENT-STATE: while hosting, CORE-STOP with cobolcraft.disconnect.host_closed (standin
*> §17; the world is saved, every connection is sent its Disconnect, run state 2), the console
*> lines printed, hosting ends. Nothing when not hosting.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REASON              PIC X(40) VALUE Z"cobolcraft.disconnect.host_closed".
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF SP-ACTIVE = 1
         CALL "CORE-STOP" USING WS-REASON
         CALL "SP-CONSOLE"
         MOVE 0 TO SP-ACTIVE SP-PAUSED
     END-IF
     GOBACK.
 END PROGRAM SP-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-QUIT.
*> USING CLIENT-STATE: the quit-world control (US16-5): SP-STOP, the game connection closed, the
*> world replica emptied, the title screen.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-TITLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "SP-STOP" USING CLIENT-STATE
     CALL "NET-CLOSE" USING CLIENT-STATE WS-CONN
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO SM-MESSAGE-LENGTH
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     GOBACK.
 END PROGRAM SP-QUIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-CONSOLE.
*> Displays every pending console line of the core (CORE-CONSOLE-DRAIN) on the terminal, one per
*> line (core-host-api §2: the client prints them on its terminal).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 01 WS-AREA                PIC X(65537).
 01 WS-I                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 1 TO CB-LENGTH
     PERFORM UNTIL CB-LENGTH = 0
         SET CB-ADDR TO ADDRESS OF WS-AREA
         MOVE 65536 TO CB-CAPACITY
         MOVE 0 TO CB-LENGTH
         CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
         MOVE 1 TO WS-FROM
*>       Each line ends at a newline; the end of the drained bytes ends a line too.
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-LENGTH + 1 OR CB-LENGTH = 0
             IF WS-I > CB-LENGTH OR WS-AREA(WS-I:1) = X"0A"
                 COMPUTE WS-LENGTH = WS-I - WS-FROM
                 IF WS-LENGTH > 0
                     DISPLAY WS-AREA(WS-FROM:WS-LENGTH)
                 END-IF
                 COMPUTE WS-FROM = WS-I + 1
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM SP-CONSOLE.
