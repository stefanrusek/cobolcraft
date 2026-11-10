*> The client's main loop (research R6; contracts/test-harness.md §2; client-surface.md §1, §2):
*> CL-INIT empties a client state; CL-START prepares it without a window (game directory, server
*> list, the pack stack, language, font and UI atlas, block and entity atlases, baked models, item
*> icons, the title screen); CL-STEP is one frame: the frame's events, the screen's input (on the
*> world screen also looking and the fly toggle, physics.cob), a hosted world's core ticks and
*> console lines (sp-host.cob SP-PUMP), sprinting (controls.cob), the client tick (every 50 ms in
*> play, not while a single-player pause is in effect: the player's movement and its Move Player
*> once loaded, then Client Tick End), the target block or entity (raycast.cob, world screen) and the block, use,
*> eat, attack and hotbar controls (controls.cob), the connections pumped without waiting, the
*> server packs fetched and applied (packs/download.cob), the sky, meshing of changed sections,
*> then the screen model, the UI and the render list; CL-RUN repeats frames over the window
*> (cc_win_poll, CL-STEP, SUBMIT-FRAME) until the run ends; CL-MAIN is the program: the command
*> line, CL-START, the window and Vulkan, CL-RUN, exit status 0. One thread throughout.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-INIT.
*> USING CLIENT-STATE: a new client: everything empty, the title screen, no connection
*> (compression off), no world, the single-player settings (SP-DEFAULTS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     INITIALIZE CLIENT-STATE
     MOVE SCR-TITLE TO SM-SCREEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE -1 TO CN-THRESHOLD(WS-I)
     END-PERFORM
     MOVE 1000 TO SK-U
     MOVE -1 TO SK-MESHED-U
     CALL "SP-DEFAULTS" USING CLIENT-STATE
     GOBACK.
 END PROGRAM CL-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-START.
*> USING CLIENT-STATE (name and game directory set): everything a run needs except the window
*> (game directory, the generated packs' status (PACKS-STATUS-CHECK), server list, the enabled packs of options.dat, the download cache trimmed,
*> the local packs, the pack
*> stack, language, font, block, entity and environment atlases,
*> models).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-SCREEN              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "GAME-DIR-SETUP" USING CLIENT-STATE
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     CALL "SERVERS-LOAD" USING CLIENT-STATE
     CALL "OPTIONS-LOAD" USING CLIENT-STATE
     CALL "PACK-CACHE-VACUUM" USING CLIENT-STATE
     CALL "LOCAL-PACKS-SCAN" USING CLIENT-STATE
     CALL "PACK-STACK-BUILD" USING CLIENT-STATE
     CALL "LANG-LOAD" USING CLIENT-STATE
     CALL "FONT-LOAD" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     CALL "ENVIRONMENT-ATLAS-BUILD" USING CLIENT-STATE
     CALL "MODELS-BAKE" USING CLIENT-STATE
     CALL "ITEMDEFS-LOAD" USING CLIENT-STATE
     MOVE 854 TO IN-WIN-W
     MOVE 480 TO IN-WIN-H
     MOVE SCR-TITLE TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     GOBACK.
 END PROGRAM CL-START.


 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-CLOCK.
*> USING milliseconds out (BINARY-DOUBLE): the wall clock (10 ms resolution of CURRENT-DATE), from
*> day 1 of INTEGER-OF-DATE so midnight does not wrap.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOW                 PIC X(21).
 LINKAGE SECTION.
 01 L-MS                   BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-MS.
     MOVE FUNCTION CURRENT-DATE TO WS-NOW
     COMPUTE L-MS = (FUNCTION INTEGER-OF-DATE(FUNCTION NUMVAL(WS-NOW(1:8))) * 86400
         + FUNCTION NUMVAL(WS-NOW(9:2)) * 3600 + FUNCTION NUMVAL(WS-NOW(11:2)) * 60
         + FUNCTION NUMVAL(WS-NOW(13:2))) * 1000 + FUNCTION NUMVAL(WS-NOW(15:2)) * 10
     GOBACK.
 END PROGRAM CL-CLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-RUN.
*> USING CLIENT-STATE (window open, Vulkan ready): frames until the run ends (close request or the
*> quit control); the cursor is captured while the world is shown; at the end a hosted world is
*> stopped (saved, SP-STOP) and the connections are closed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-EVENTS              PIC X(6144).
 01 WS-CAPACITY            BINARY-LONG VALUE 6144.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-FB-W                BINARY-LONG.
 01 WS-FB-H                BINARY-LONG.
 01 WS-CAPTURE             BINARY-LONG.
 01 WS-PRESENTED           BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM UNTIL CL-QUIT = 1
         CALL STATIC "cc_win_poll" USING BY REFERENCE WS-EVENTS BY VALUE WS-CAPACITY
             BY REFERENCE WS-COUNT RETURNING WS-RC
         CALL STATIC "cc_win_size" USING BY REFERENCE IN-WIN-W BY REFERENCE IN-WIN-H
             BY REFERENCE WS-FB-W BY REFERENCE WS-FB-H
         CALL "CL-CLOCK" USING WS-NOW
         CALL "CL-STEP" USING CLIENT-STATE WS-EVENTS WS-COUNT WS-NOW
         MOVE 0 TO WS-CAPTURE
         IF SM-SCREEN = SCR-WORLD
             MOVE 1 TO WS-CAPTURE
         END-IF
         IF WS-CAPTURE NOT = IN-CAPTURED
             MOVE WS-CAPTURE TO IN-CAPTURED
             CALL STATIC "cc_win_capture_cursor" USING BY VALUE WS-CAPTURE
         END-IF
         CALL "SUBMIT-FRAME" USING CLIENT-STATE WS-PRESENTED
     END-PERFORM
     CALL "SP-STOP" USING CLIENT-STATE
     PERFORM VARYING WS-CONN FROM 1 BY 1 UNTIL WS-CONN > 2
         CALL "NET-CLOSE" USING CLIENT-STATE WS-CONN
     END-PERFORM
     GOBACK.
 END PROGRAM CL-RUN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-MAIN.
*> The client program (never returns): collects the command line, prepares the client (fatal on a
*> missing or invalid name), opens the window and Vulkan, runs, shuts down and exits with status 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLARGS.
 01 WS-I                   BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-W                   BINARY-LONG VALUE 854.
 01 WS-H                   BINARY-LONG VALUE 480.
 01 WS-VISIBLE             BINARY-LONG VALUE 1.
 01 WS-TITLE               PIC X(16) VALUE Z"CobolCraft".
 PROCEDURE DIVISION.
     INITIALIZE CL-ARGS
     ACCEPT AR-COUNT FROM ARGUMENT-NUMBER
     MOVE FUNCTION MIN(AR-COUNT, 16) TO AR-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > AR-COUNT
         ACCEPT AR-TEXT(WS-I) FROM ARGUMENT-VALUE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(AR-TEXT(WS-I) TRAILING)) TO AR-LENGTH(WS-I)
     END-PERFORM
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "ARGS-PARSE" USING CLIENT-STATE CL-ARGS
     CALL "CL-START" USING CLIENT-STATE
     CALL STATIC "cc_win_open" USING BY VALUE WS-W BY VALUE WS-H BY REFERENCE WS-TITLE
         BY VALUE WS-VISIBLE RETURNING WS-RC
     CALL STATIC "cc_vk_init" RETURNING WS-RC
     CALL "CL-RUN" USING CLIENT-STATE
     CALL STATIC "cc_vk_shutdown"
     CALL STATIC "cc_win_close"
     STOP RUN RETURNING 0.
 END PROGRAM CL-MAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-STEP.
*> USING CLIENT-STATE, events (24-byte records, shim-abi §8), event count, clock (BINARY-DOUBLE ms).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 13.
 01 WS-BUDGET              BINARY-LONG VALUE 64.
 01 B-EVENTS BASED.
    05 B-EVENT             PIC X(24) OCCURS 4096 TIMES.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-EVENTS               PIC X.
 01 L-COUNT                BINARY-LONG.
 01 L-NOW                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING CLIENT-STATE L-EVENTS L-COUNT L-NOW.
     MOVE L-NOW TO CL-NOW-MS
     ADD 1 TO CL-FRAMES
     SET ADDRESS OF B-EVENTS TO ADDRESS OF L-EVENTS
     CALL "INPUT-BEGIN-FRAME" USING CLIENT-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         CALL "INPUT-EVENT" USING CLIENT-STATE B-EVENT(WS-I)
     END-PERFORM
     IF IN-CLOSE = 1
         MOVE 1 TO CL-QUIT
     END-IF
     CALL "SCREEN-INPUT" USING CLIENT-STATE
     IF SM-SCREEN = SCR-WORLD
         CALL "PHYS-INPUT" USING CLIENT-STATE
     END-IF
*>   A hosted world (US16): its due core ticks, unless paused; its console lines.
     IF SP-ACTIVE = 1
         CALL "SP-PUMP" USING CLIENT-STATE
     END-IF
*>   Sprinting starts or stops before the tick that moves at its speed.
     IF CN-PHASE(CONN-GAME) = PH-PLAY
         CALL "CONTROLS-SPRINT" USING CLIENT-STATE
     END-IF
*>   A client tick every 50 ms in play: once loaded the player moves and the server hears of it,
*>   then Client Tick End, and the day advances one tick.
     IF CN-PHASE(CONN-GAME) = PH-PLAY AND L-NOW >= CL-NEXT-TICK AND SP-PAUSED = 0
         MOVE CONN-GAME TO WS-CONN
         IF PL-LOADED = 1
             CALL "PHYS-TICK" USING CLIENT-STATE
             CALL "CLP-MOVE-SEND" USING CLIENT-STATE WS-CONN
         END-IF
         CALL "CLP-SEND-SIMPLE" USING CLIENT-STATE WS-CONN WS-ID
         COMPUTE PL-TIME = FUNCTION MOD(PL-TIME + 1, 30000)
         ADD CL-TICK-MS TO CL-NEXT-TICK
         IF CL-NEXT-TICK <= L-NOW
             COMPUTE CL-NEXT-TICK = L-NOW + CL-TICK-MS
         END-IF
     END-IF
*>   The target (world screen only) and, in play, the block controls (which abort a break once the
*>   world is left), the hotbar (world and inventory screens) and the throw keys (world screen;
*>   on the inventory screen INVENTORY-INPUT throws from a slot or the cursor).
     MOVE 0 TO TG-HIT TG-ENTITY-HIT
     IF SM-SCREEN = SCR-WORLD
         CALL "RAYCAST" USING CLIENT-STATE
     END-IF
     IF CN-PHASE(CONN-GAME) = PH-PLAY
         CALL "CONTROLS-INPUT" USING CLIENT-STATE
         IF SM-SCREEN = SCR-WORLD OR SM-SCREEN = SCR-INVENTORY
             CALL "CONTROLS-HOTBAR" USING CLIENT-STATE
         END-IF
         IF SM-SCREEN = SCR-WORLD
             CALL "CONTROLS-THROW" USING CLIENT-STATE
         END-IF
         IF SM-SCREEN = SCR-INVENTORY
             CALL "INVENTORY-INPUT" USING CLIENT-STATE
         END-IF
     END-IF
*>   The connections, never waiting (what this frame queued goes out now).
     IF SM-SCREEN = SCR-SERVER-LIST
         CALL "SERVER-LIST-PING" USING CLIENT-STATE
     END-IF
     PERFORM VARYING WS-CONN FROM 1 BY 1 UNTIL WS-CONN > 2
         IF CN-PHASE(WS-CONN) NOT = PH-NONE
             CALL "NET-PUMP" USING CLIENT-STATE WS-CONN
         END-IF
     END-PERFORM
     CALL "PACKS-PUMP" USING CLIENT-STATE
*>   Daylight changes the brightness baked into the meshes: every section is meshed again.
     CALL "SKY-UPDATE" USING CLIENT-STATE
     IF SK-U NOT = SK-MESHED-U
         MOVE SK-U TO SK-MESHED-U
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                 MOVE WR-USED(WS-R) TO WR-DIRTY(WS-R, WS-S)
             END-PERFORM
         END-PERFORM
     END-IF
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-BUDGET
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "UI-RENDER" USING CLIENT-STATE
     CALL "RENDER-LIST-BUILD" USING CLIENT-STATE
     GOBACK.
 END PROGRAM CL-STEP.
