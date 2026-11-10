*> Host entry points of the core (contracts/core-host-api.md §2). Hosts drive the core only through
*> these programs; connection work is delegated to the session module (core/src/session.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-WORLD-OPEN.
*> USING world folder path (z-string), CORE-SETTINGS, created-flag out (BINARY-LONG). Stores the
*> settings and empties every table (a world already open in this process is closed first). A
*> folder without level.dat becomes a new in-memory world: the cobolcraft:main dimension and, while
*> the extra-dimensions setting is on, every extra dimension (DIMENSIONS.cpy DM-EXTRA 1, standin
*> §15.1), in table (Login) order; the spawn point (standin-content §5.2), time 0 (§4.8) and the
*> starting weather (§14.3, WEATHER-INIT), the access state of a new world (ACCESS-RESET) and the
*> settings' game mode as its GameMode; created-flag 1. A folder with level.dat is an existing
*> world (created-flag 0): WORLD-LOAD reads its level.dat, access.dat and entities over those
*> defaults; the settings never overwrite them (US13 edge case). Either way the world's folders are
*> created when missing (PERSIST-DIRS, 07 §9.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-I                   BINARY-LONG.
 01 WS-FILE                PIC X(1040).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 B-PATH                 PIC X(1024) BASED.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-PATH                 PIC X.
 01 L-CREATED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH CORE-SETTINGS L-CREATED.
     IF CW-OPEN = "Y"
         CALL "SESSION-RESET"
         CALL "WORLD-RESET"
         MOVE CW-CONSOLE TO PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
     INITIALIZE CORE-WORLD CORE-CONNS CORE-PLAYERS CORE-CHUNKS CORE-ENTITIES CORE-VIEWS
         CORE-KNOWN CORE-ACCESS
     MOVE "Y" TO CW-OPEN
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE CS-NEW-WORLD-NAME TO CW-NAME
     MOVE CS-DEFAULT-MODE TO CW-GAME-MODE
     SET ADDRESS OF B-PATH TO ADDRESS OF L-PATH
     MOVE 0 TO CW-FOLDER-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1024 OR CW-FOLDER-LENGTH > 0
         IF B-PATH(WS-I:1) = X"00"
             COMPUTE CW-FOLDER-LENGTH = WS-I - 1
         END-IF
     END-PERFORM
     MOVE B-PATH(1:CW-FOLDER-LENGTH) TO CW-FOLDER
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE PB-BUFFER TO CW-CONSOLE
     MOVE 0 TO CW-RUN-STATE CW-TIME CW-TICKS
     MOVE 1 TO CW-NEXT-ENTITY-ID
     MOVE 0 TO CW-DIM-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DIM-TABLE-ROWS
         IF DM-EXTRA(WS-I) = 0 OR (DM-EXTRA(WS-I) = 1 AND CS-EXTRA-DIMENSIONS = 1)
             ADD 1 TO CW-DIM-COUNT
             MOVE WS-I TO CW-DIM(CW-DIM-COUNT)
         END-IF
     END-PERFORM
     CALL "WEATHER-INIT"
     CALL "ACCESS-RESET"
     COMPUTE CW-SPAWN-X = SPAWN-X10 / 10
     COMPUTE CW-SPAWN-Y = SPAWN-Y10 / 10
     COMPUTE CW-SPAWN-Z = SPAWN-Z10 / 10
     MOVE SPAWN-YAW TO CW-SPAWN-YAW
     MOVE SPACES TO WS-FILE
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/level.dat" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE = 0
         MOVE 0 TO L-CREATED
         CALL "WORLD-LOAD"
     ELSE
         MOVE 1 TO L-CREATED
     END-IF
     MOVE 0 TO RETURN-CODE
     CALL "PERSIST-DIRS"
     GOBACK.
 END PROGRAM CORE-WORLD-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-SAVE.
*> No parameters: writes the whole world to its folder (FR-014; WORLD-SAVE, 07 §9.5).
 PROCEDURE DIVISION.
     CALL "WORLD-SAVE"
     GOBACK.
 END PROGRAM CORE-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONN-OPEN.
*> USING kind (BINARY-LONG, CORE-CONN-NETWORK or CORE-CONN-MEMORY), connection id out
*> (BINARY-LONG; 0 when the connection table is full).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ID.
     CALL "SESSION-OPEN" USING L-KIND L-ID
     GOBACK.
 END PROGRAM CORE-CONN-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONN-INPUT.
*> USING connection id, CORE-BUFFER (CB-LENGTH received bytes at CB-ADDR).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID CORE-BUFFER.
     CALL "SESSION-INPUT" USING L-ID CORE-BUFFER
     GOBACK.
 END PROGRAM CORE-CONN-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONN-OUTPUT.
*> USING connection id, CORE-BUFFER (up to CB-CAPACITY bytes at CB-ADDR; CB-LENGTH out),
*> close-flag out (BINARY-LONG).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID CORE-BUFFER L-CLOSE.
     CALL "SESSION-OUTPUT" USING L-ID CORE-BUFFER L-CLOSE
     GOBACK.
 END PROGRAM CORE-CONN-OUTPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONN-CLOSED.
*> USING connection id: the transport closed; the player, if any, leaves.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     CALL "SESSION-CLOSED" USING L-ID
     GOBACK.
 END PROGRAM CORE-CONN-CLOSED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-TICK.
*> One 50 ms game tick (research R6): the tick counter, the time of day and its Set Time cadence
*> (WORLD-TIME-TICK), the weather (WEATHER-TICK, step 3 of standin §9.5), break progress
*> (BLOCKS-TICK), the player survival and hunger rules (HEALTH-TICK, step 4), mob spawning (MOBS-SPAWN-TICK, step 5), the mobs
*> (MOBS-TICK, step 6), ground items (GROUND-ITEMS-TICK, step 7, last of the game rules), the
*> recipe book of each player whose inventory the tick changed (CRAFT-REFRESH-ALL) and the
*> connections' keep-alives.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 PROCEDURE DIVISION.
     ADD 1 TO CW-TICKS
     CALL "WORLD-TIME-TICK"
     CALL "WEATHER-TICK"
     CALL "BLOCKS-TICK"
     CALL "HEALTH-TICK"
     CALL "MOBS-SPAWN-TICK"
     CALL "MOBS-TICK"
     CALL "GROUND-ITEMS-TICK"
     CALL "CRAFT-REFRESH-ALL"
     CALL "SESSION-TICK"
     GOBACK.
 END PROGRAM CORE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONSOLE-DRAIN.
*> USING CORE-BUFFER: moves up to CB-CAPACITY bytes of pending console lines into the buffer
*> (CB-LENGTH = bytes moved); the rest stays queued.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION USING CORE-BUFFER.
     CALL "CONSOLE-DRAIN" USING CORE-BUFFER
     GOBACK.
 END PROGRAM CORE-CONSOLE-DRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-STATUS-GET.
*> USING CORE-STATUS out: run state and the number of players in the world.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION USING CORE-STATUS.
     MOVE CW-RUN-STATE TO CST-RUN-STATE
     CALL "PLAYERS-ONLINE" USING CST-PLAYERS-ONLINE
     GOBACK.
 END PROGRAM CORE-STATUS-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONSOLE.
*> USING command line (z-string, without a leading `/`): runs it as the console, with operator
*> permission (US15-1, FR-016; CONSOLE-RUN); its result or error is queued as console lines for
*> CORE-CONSOLE-DRAIN (US15-3).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LINE                 PIC X.
 PROCEDURE DIVISION USING L-LINE.
     CALL "CONSOLE-RUN" USING L-LINE
     GOBACK.
 END PROGRAM CORE-CONSOLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-STOP.
*> USING reason (z-string: a standin-content §17 translate key, e.g. cobolcraft.disconnect.shutdown
*> for the stopping server, US15-2, or cobolcraft.disconnect.host_closed, US17-4; at most 1024 bytes
*> before the NUL): saves the world (WORLD-SAVE, FR-014), queues every connection not already closing
*> the disconnect of its phase with that key and no arguments (CORE-SEND-DISCONNECT: play Disconnect
*> 0x20, configuration 0x02, Login Disconnect; handshake and status only the close flag) and sets
*> run state 2 (stopped, CORE-STATUS-GET).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 B-REASON               PIC X(1024) BASED.
 LINKAGE SECTION.
 01 L-REASON               PIC X.
 PROCEDURE DIVISION USING L-REASON.
     CALL "WORLD-SAVE"
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     SET ADDRESS OF B-REASON TO ADDRESS OF L-REASON
     MOVE 1024 TO PB-TX-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PB-TX-LENGTH
         IF B-REASON(WS-I:1) = X"00"
             COMPUTE PB-TX-LENGTH = WS-I - 1
         END-IF
     END-PERFORM
     MOVE B-REASON(1:PB-TX-LENGTH) TO PB-TX-VALUE
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CORE-MAX-CONNS
         IF CN-USED(WS-ID) = 1 AND CN-CLOSE(WS-ID) = 0
             CALL "CORE-SEND-DISCONNECT" USING WS-ID PB-TEXT
         END-IF
     END-PERFORM
     MOVE 2 TO CW-RUN-STATE
     GOBACK.
 END PROGRAM CORE-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-OPEN-TO-OTHERS.
*> USING guest mode (BINARY-LONG, 0 survival or 1 creative), guest-operator flag (BINARY-LONG, 1 =
*> guests may use operator commands): a single-player world (host kind 1) becomes a world opened to
*> others (host kind 2) for the rest of the session (FR-017), so guests joining over network
*> connections get that mode (PLAYER-CREATE) and operator status only when the flag is 1
*> (ACCESS-OPERATOR-STATUS). Any other host kind is left as it is: a dedicated server is not
*> opened, and a world already opened keeps its first choice.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-GUEST-MODE           BINARY-LONG.
 01 L-GUEST-OPERATOR       BINARY-LONG.
 PROCEDURE DIVISION USING L-GUEST-MODE L-GUEST-OPERATOR.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     IF CS-HOST-KIND = 1
         MOVE 2 TO CS-HOST-KIND
         MOVE L-GUEST-MODE TO CS-GUEST-MODE
         MOVE L-GUEST-OPERATOR TO CS-GUEST-OPERATOR
     END-IF
     GOBACK.
 END PROGRAM CORE-OPEN-TO-OTHERS.
