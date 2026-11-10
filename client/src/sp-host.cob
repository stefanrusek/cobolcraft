*> The single-player host (US16; research R7; contracts/core-host-api.md §2): the client runs the
*> game core in its own process and joins it over a memory connection. SP-DEFAULTS holds the
*> settings of a hosted world (the server defaults of operator-surface §2, the allow-list off);
*> SP-OPEN opens a world folder under saves/ with CORE-WORLD-OPEN (host kind 1, the Player's name
*> as host name, the chosen game mode and name for a new world, which is saved at once so the world
*> list shows it) and joins it (NET-OPEN-MEMORY); SP-PUMP, once per frame while hosting, runs one
*> CORE-TICK per elapsed 50 ms (none while the pause menu is open and the world is not opened to
*> others, US16-4), prints the core's console lines on the terminal and ends hosting when the core
*> was told to stop (the shutdown command: the host quitting, after receiving what the core sent
*> before stopping, such as the command's confirmation) or the connection has ended; SP-QUIT
*> is the quit-world control: CORE-STOP (saves the world), the connection closed, back to the title
*> screen (US16-5).
*> Opening to others (US17): SP-OPEN-OTHERS switches the world to host kind 2 (CORE-OPEN-TO-OTHERS
*> with the screen's choices), listens on a system-chosen port (cc_net_listen(0)) and keeps the
*> local addresses to show (cc_net_local_addresses). From then on SP-PUMP hosts guests as the
*> server's TCP host does (contracts/core-host-api.md §2): every pending connection is accepted as
*> a core network connection (GUEST-ACCEPT), received bytes go to CORE-CONN-INPUT (GUEST-PUMP-IN),
*> CORE-CONN-OUTPUT is sent, a partial send keeping the rest (GUEST-PUMP-OUT), a transport is closed
*> once the close flag is handed back and everything is sent, a peer close calls CORE-CONN-CLOSED
*> (GUEST-RELEASE). SP-STOP flushes every guest's Disconnect, then closes the guests and the
*> listener (GUESTS-CLOSE). A guest the host has no slot for, or the core no room for, and a
*> failed send are non-fatal (FR-012): one "ERROR connection: <detail>" line, that connection
*> closed, hosting continues.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-DEFAULTS.
*> USING CLIENT-STATE: SP-SETTINGS for a hosted world: survival, the operator-surface §2 defaults
*> (description, view distance 8, combat, hostile mobs, weather changes and extra dimensions on),
*> no allow-list (a new single-player world seeds AllowListEnforced 0, 07 §9.2), no server pack,
*> host kind 1 (SP-OPEN adds the host name, game mode and world name, and the game directory), the
*> world type cobolcraft (the create-world screen sets CS-WORLD-TYPE and CS-SEED-TEXT for a new
*> world: core-host-delta §2; SP-CREATE-TYPE starts as cobolcraft, so a world opened without the
*> screen is a cobolcraft one) and no seed text.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY CONTENT.
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
     MOVE "cobolcraft" TO CS-WORLD-TYPE
     MOVE CT-TYPE-COBOLCRAFT TO SP-CREATE-TYPE
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
 COPY CONTENT.
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
     MOVE SPACES TO CS-GAME-DIR
     MOVE CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) TO CS-GAME-DIR
     MOVE SPACES TO CS-GENERATED-DIR CS-SEED-TEXT
     MOVE CL-GENERATED-DIR(1:CL-GENERATED-DIR-LENGTH) TO CS-GENERATED-DIR
     EVALUATE SP-CREATE-TYPE
         WHEN CT-TYPE-STANDARD
             MOVE "standard" TO CS-WORLD-TYPE
         WHEN CT-TYPE-DEBUG
             MOVE "debug" TO CS-WORLD-TYPE
         WHEN OTHER
             MOVE "cobolcraft" TO CS-WORLD-TYPE
     END-EVALUATE
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
*> ended (a Disconnect, or lost) stops the core, leaving the screen the disconnect chose. The
*> pause holds on the pause menu and the open-to-others screen of a world not opened to others;
*> once opened, guests are accepted and received from before the ticks and sent to after them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY COREAPI.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE CONN-GAME.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE 0 TO SP-PAUSED
     IF (SM-SCREEN = SCR-PAUSE OR SM-SCREEN = SCR-OPEN-TO-OTHERS) AND CS-HOST-KIND = 1
         MOVE 1 TO SP-PAUSED
         COMPUTE SP-NEXT-TICK = CL-NOW-MS + CL-TICK-MS
     END-IF
     IF SP-LISTENER > 0
         CALL "GUEST-ACCEPT" USING CLIENT-STATE
         PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > CL-MAX-GUESTS
             IF GH-HANDLE(WS-SLOT) > 0
                 CALL "GUEST-PUMP-IN" USING CLIENT-STATE WS-SLOT
             END-IF
         END-PERFORM
     END-IF
     PERFORM UNTIL CL-NOW-MS < SP-NEXT-TICK
         CALL "CORE-TICK"
         ADD 1 TO SP-TICKS
         ADD CL-TICK-MS TO SP-NEXT-TICK
     END-PERFORM
     CALL "GUESTS-FLUSH" USING CLIENT-STATE
     CALL "SP-CONSOLE"
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     EVALUATE TRUE
         WHEN CST-RUN-STATE = 1
*>           What the core sent before stopping (the shutdown confirmation) is received first.
             CALL "NET-PUMP" USING CLIENT-STATE WS-CONN
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
*> lines printed, hosting ends; the guests of a world opened to others are sent their Disconnect,
*> then every guest and the listener are closed (US17-4). Nothing when not hosting.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REASON              PIC X(40) VALUE Z"cobolcraft.disconnect.host_closed".
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     IF SP-ACTIVE = 1
         CALL "CORE-STOP" USING WS-REASON
         CALL "GUESTS-FLUSH" USING CLIENT-STATE
         CALL "GUESTS-CLOSE" USING CLIENT-STATE
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SP-OPEN-OTHERS.
*> USING CLIENT-STATE (hosting, not yet opened): the open-to-others screen's Open the World (US17-1):
*> CORE-OPEN-TO-OTHERS with the guest mode and guest-operator choice (host kind 2 for the rest of
*> the session, so the pause menu no longer pauses), a listener on a system-chosen port (port 0
*> cannot be in use, shim-abi §3), and the local addresses (at most CL-MAX-ADDRESSES) to show.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY COREAPI.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-RC                  BINARY-LONG.
 01 WS-AREA                PIC X(256).
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "CORE-OPEN-TO-OTHERS" USING SP-GUEST-MODE SP-GUEST-OPERATOR
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE 2 TO CS-HOST-KIND
     MOVE SP-GUEST-MODE TO CS-GUEST-MODE
     MOVE SP-GUEST-OPERATOR TO CS-GUEST-OPERATOR
     MOVE CORE-SETTINGS TO SP-SETTINGS
     CALL STATIC "cc_net_listen" USING BY VALUE WS-ZERO BY REFERENCE SP-LISTENER
         BY REFERENCE SP-PORT RETURNING WS-RC
     MOVE LOW-VALUES TO WS-AREA
     CALL STATIC "cc_net_local_addresses" USING BY REFERENCE WS-AREA BY VALUE WS-CAPACITY
         RETURNING WS-COUNT
*>   Each entry is a dotted address ending in a newline.
     MOVE 0 TO SP-ADDR-COUNT
     MOVE 1 TO WS-FROM
     PERFORM VARYING WS-I FROM 1 BY 1
             UNTIL WS-I > WS-CAPACITY OR SP-ADDR-COUNT = CL-MAX-ADDRESSES
         IF WS-AREA(WS-I:1) = X"0A"
             ADD 1 TO SP-ADDR-COUNT
             COMPUTE WS-LENGTH = WS-I - WS-FROM
             MOVE WS-AREA(WS-FROM:WS-LENGTH) TO SP-ADDR-TEXT(SP-ADDR-COUNT)
             MOVE WS-LENGTH TO SP-ADDR-LENGTH(SP-ADDR-COUNT)
             COMPUTE WS-FROM = WS-I + 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM SP-OPEN-OTHERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUEST-ACCEPT.
*> USING CLIENT-STATE: accepts every pending guest connection. Each gets a free guest slot (its
*> outbound buffer allocated on first use) and a core network connection; when the host or the
*> core has no room, the connection is refused: an ERROR line, then it is closed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY COREAPI.
 01 WS-RC                  BINARY-LONG.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG VALUE CORE-CONN-NETWORK.
 01 WS-BYTES               BINARY-LONG VALUE CL-GUEST-OUT.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WS-RC
     PERFORM UNTIL WS-RC NOT = 0
         CALL STATIC "cc_net_accept" USING BY VALUE SP-LISTENER BY REFERENCE WS-HANDLE
             RETURNING WS-RC
         IF WS-RC = 0
             MOVE 0 TO WS-SLOT WS-ID
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-MAX-GUESTS OR WS-SLOT > 0
                 IF GH-HANDLE(WS-I) = 0
                     MOVE WS-I TO WS-SLOT
                 END-IF
             END-PERFORM
             IF WS-SLOT > 0
                 CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
             END-IF
             IF WS-ID = 0
                 DISPLAY "ERROR connection: refused, too many connections"
                 CALL STATIC "cc_net_close" USING BY VALUE WS-HANDLE
             ELSE
                 IF GH-OUT-ADDR(WS-SLOT) = NULL
                     ALLOCATE WS-BYTES CHARACTERS RETURNING GH-OUT-ADDR(WS-SLOT)
                 END-IF
                 MOVE WS-HANDLE TO GH-HANDLE(WS-SLOT)
                 MOVE WS-ID TO GH-CORE-ID(WS-SLOT)
                 MOVE 0 TO GH-CLOSING(WS-SLOT) GH-OUT-PENDING(WS-SLOT)
                 MOVE 1 TO GH-OUT-START(WS-SLOT)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GUEST-ACCEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUESTS-FLUSH.
*> USING CLIENT-STATE: GUEST-PUMP-OUT for every guest connection.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > CL-MAX-GUESTS
         IF GH-HANDLE(WS-SLOT) > 0
             CALL "GUEST-PUMP-OUT" USING CLIENT-STATE WS-SLOT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM GUESTS-FLUSH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUESTS-CLOSE.
*> USING CLIENT-STATE: releases every guest connection (GUEST-RELEASE) and closes the listener.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > CL-MAX-GUESTS
         IF GH-HANDLE(WS-SLOT) > 0
             CALL "GUEST-RELEASE" USING CLIENT-STATE WS-SLOT
         END-IF
     END-PERFORM
     IF SP-LISTENER > 0
         CALL STATIC "cc_net_close" USING BY VALUE SP-LISTENER
     END-IF
     MOVE 0 TO SP-LISTENER SP-PORT SP-ADDR-COUNT
     GOBACK.
 END PROGRAM GUESTS-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUEST-PUMP-IN.
*> USING CLIENT-STATE, slot (BINARY-LONG): receives everything available. The bytes go to
*> CORE-CONN-INPUT (or are dropped once the core has handed back the close flag); a peer close
*> releases the slot.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 COPY COREAPI.
 01 WS-SLOT                BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-GOT                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-AREA                PIC X(65536).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT.
     MOVE L-SLOT TO WS-SLOT
     MOVE 0 TO WS-RC
     PERFORM UNTIL WS-RC NOT = 0
         CALL STATIC "cc_net_recv" USING BY VALUE GH-HANDLE(WS-SLOT) BY REFERENCE WS-AREA
             BY VALUE WS-CAPACITY BY REFERENCE WS-GOT RETURNING WS-RC
         IF WS-RC = 0 AND GH-CLOSING(WS-SLOT) = 0
             SET CB-ADDR TO ADDRESS OF WS-AREA
             MOVE WS-CAPACITY TO CB-CAPACITY
             MOVE WS-GOT TO CB-LENGTH
             CALL "CORE-CONN-INPUT" USING GH-CORE-ID(WS-SLOT) CORE-BUFFER
         END-IF
     END-PERFORM
     IF WS-RC = CC-CLOSED
         CALL "GUEST-RELEASE" USING CLIENT-STATE WS-SLOT
     END-IF
     GOBACK.
 END PROGRAM GUEST-PUMP-IN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUEST-PUMP-OUT.
*> USING CLIENT-STATE, slot (BINARY-LONG): sends the slot's pending bytes, then whatever
*> CORE-CONN-OUTPUT has, until the core has nothing more or the socket takes no more (the rest
*> stays pending). Once the close flag has been handed back and everything is sent, the transport
*> is closed. A failed send is a socket error: an ERROR line and the slot is released.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY COREAPI.
 01 WS-SLOT                BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-SENT                BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 B-OUT                  PIC X(65536) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT.
     MOVE L-SLOT TO WS-SLOT
     SET ADDRESS OF B-OUT TO GH-OUT-ADDR(WS-SLOT)
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE NOT = 0
         IF GH-OUT-PENDING(WS-SLOT) = 0 AND GH-CLOSING(WS-SLOT) = 0
             SET CB-ADDR TO GH-OUT-ADDR(WS-SLOT)
             MOVE CL-GUEST-OUT TO CB-CAPACITY
             MOVE 0 TO CB-LENGTH WS-CLOSE
             CALL "CORE-CONN-OUTPUT" USING GH-CORE-ID(WS-SLOT) CORE-BUFFER WS-CLOSE
             MOVE 1 TO GH-OUT-START(WS-SLOT)
             MOVE CB-LENGTH TO GH-OUT-PENDING(WS-SLOT)
             MOVE WS-CLOSE TO GH-CLOSING(WS-SLOT)
         END-IF
         EVALUATE TRUE
             WHEN GH-OUT-PENDING(WS-SLOT) = 0
                 MOVE 1 TO WS-DONE
             WHEN OTHER
                 SET WS-PTR TO ADDRESS OF B-OUT(GH-OUT-START(WS-SLOT):1)
                 CALL STATIC "cc_net_send" USING BY VALUE GH-HANDLE(WS-SLOT) BY VALUE WS-PTR
                     BY VALUE GH-OUT-PENDING(WS-SLOT) BY REFERENCE WS-SENT RETURNING WS-RC
                 ADD WS-SENT TO GH-OUT-START(WS-SLOT)
                 SUBTRACT WS-SENT FROM GH-OUT-PENDING(WS-SLOT)
                 EVALUATE TRUE
                     WHEN WS-RC NOT = 0
                         MOVE 2 TO WS-DONE
                     WHEN GH-OUT-PENDING(WS-SLOT) > 0
                         MOVE 1 TO WS-DONE
                 END-EVALUATE
         END-EVALUATE
     END-PERFORM
     EVALUATE TRUE
         WHEN WS-DONE = 2
             DISPLAY "ERROR connection: send failed: closed or reset by the peer"
             CALL "GUEST-RELEASE" USING CLIENT-STATE WS-SLOT
         WHEN GH-CLOSING(WS-SLOT) = 1 AND GH-OUT-PENDING(WS-SLOT) = 0
             CALL "GUEST-RELEASE" USING CLIENT-STATE WS-SLOT
     END-EVALUATE
     GOBACK.
 END PROGRAM GUEST-PUMP-OUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GUEST-RELEASE.
*> USING CLIENT-STATE, slot (BINARY-LONG): closes the guest's transport and frees the slot (its
*> buffer is kept for the next guest). While the core still holds the connection (no close flag
*> handed back) it is told with CORE-CONN-CLOSED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-SLOT.
     MOVE L-SLOT TO WS-SLOT
     IF GH-CLOSING(WS-SLOT) = 0
         CALL "CORE-CONN-CLOSED" USING GH-CORE-ID(WS-SLOT)
     END-IF
     CALL STATIC "cc_net_close" USING BY VALUE GH-HANDLE(WS-SLOT)
     MOVE 0 TO GH-HANDLE(WS-SLOT) GH-CORE-ID(WS-SLOT) GH-CLOSING(WS-SLOT)
         GH-OUT-PENDING(WS-SLOT)
     MOVE 1 TO GH-OUT-START(WS-SLOT)
     GOBACK.
 END PROGRAM GUEST-RELEASE.
