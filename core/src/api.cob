*> Host entry points of the core (contracts/core-host-api.md §2). Hosts drive the core only through
*> these programs; connection work is delegated to the session module (core/src/session.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-WORLD-OPEN.
*> USING world folder path (z-string), CORE-SETTINGS, created-flag out (BINARY-LONG: 1 created, 0 opened, or minus a
*> CORE-WO-* status word when the world is refused: -1 packs not ok, -2 world data but no level.dat, -3 no or an
*> unknown WorldType; the world is then not open). Stores the
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
 COPY EXTRAS.
 COPY KNSTATE.
 COPY DIMENSIONS.
 COPY CONTENT.
 COPY PROTO.
 01 WS-I                   BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-FILE                PIC X(1040).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-RANDOM              BINARY-LONG.
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
         CORE-KNOWN CORE-KNOWN-EXTRA CORE-ACCESS CORE-EXTRA
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
*>   The world type (world-types section 2.1) and the content set it opens, before anything reads the world.
     CALL "WORLD-TYPE-DECIDE" USING CS-WORLD-TYPE CW-WORLD-TYPE WS-STATUS
     IF WS-STATUS = CORE-WO-OK
         CALL "WORLD-CONTENT-OPEN" USING CW-WORLD-TYPE CS-GENERATED-DIR WS-STATUS
     END-IF
     IF WS-STATUS NOT = CORE-WO-OK
         MOVE "N" TO CW-OPEN
         COMPUTE L-CREATED = 0 - WS-STATUS
         GOBACK
     END-IF
     CALL "BLOCKS-OPEN"
     CALL "CORE-TABLES-OPEN"
     CALL "GB-RULES-OPEN"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE PB-BUFFER TO CW-CONSOLE
     MOVE 0 TO CW-RUN-STATE CW-TIME CW-TICKS
     MOVE 1 TO CW-NEXT-ENTITY-ID
     CALL "WORLD-DIMS-SELECT" USING CW-WORLD-TYPE CS-EXTRA-DIMENSIONS
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
         CALL "GEN-SPAWN-OPEN"
     ELSE
         MOVE 1 TO L-CREATED
*>       A new standard world is created in the 26.3 layout (07 section 10; operator rule: the standard type uses the
*>       game's own format); the cobolcraft and debug types keep their flat layout (07 section 9).
         IF CW-WORLD-TYPE = "standard"
             MOVE 1 TO CW-LAYOUT
         END-IF
         CALL "SEED-FROM-TEXT" USING CS-SEED-TEXT CW-SEED WS-RANDOM
         CALL "WORLDSIM-NEW-WORLD-SPAWN"
     END-IF
     MOVE 0 TO RETURN-CODE
     CALL "PERSIST-DIRS"
     GOBACK.
 END PROGRAM CORE-WORLD-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-DIMS-SELECT.
*> USING world type (PIC X(10)), extra-dimensions setting (PIC 9): fills CW-DIM and CW-DIM-COUNT with the dimensions
*> the world has, in Login order. A cobolcraft world has cobolcraft:main and, while extra dimensions are on, the extras
*> (DM-EXTRA 1); a standard or debug world has minecraft:overworld only (the DM-EXTRA 2 row), its first dimension.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(10).
 01 L-EXTRA                PIC 9.
 PROCEDURE DIVISION USING L-TYPE L-EXTRA.
     MOVE 0 TO CW-DIM-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DIM-TABLE-ROWS
         IF (L-TYPE = "cobolcraft" AND (DM-EXTRA(WS-I) = 0 OR (DM-EXTRA(WS-I) = 1 AND L-EXTRA = 1)))
                 OR (L-TYPE NOT = "cobolcraft" AND DM-EXTRA(WS-I) = 2)
             ADD 1 TO CW-DIM-COUNT
             MOVE WS-I TO CW-DIM(CW-DIM-COUNT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-DIMS-SELECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-SAVE.
*> No parameters: writes the whole world to its folder (FR-014; WORLD-SAVE, 07 §9.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 PROCEDURE DIVISION.
     IF CW-OPEN NOT = "Y"
         GOBACK
     END-IF
     CALL "WORLD-SAVE"
     GOBACK.
 END PROGRAM CORE-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONN-OPEN.
*> USING kind (BINARY-LONG, CORE-CONN-NETWORK or CORE-CONN-MEMORY), connection id out
*> (BINARY-LONG; 0 when the connection table is full).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-ID.
     IF CW-OPEN NOT = "Y"
         MOVE 0 TO L-ID
         GOBACK
     END-IF
     CALL "SESSION-OPEN" USING L-KIND L-ID
     GOBACK.
 END PROGRAM CORE-CONN-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONN-INPUT.
*> USING connection id, CORE-BUFFER (CB-LENGTH received bytes at CB-ADDR).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID CORE-BUFFER.
     IF CW-OPEN NOT = "Y"
         GOBACK
     END-IF
     CALL "SESSION-INPUT" USING L-ID CORE-BUFFER
     GOBACK.
 END PROGRAM CORE-CONN-INPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONN-OUTPUT.
*> USING connection id, CORE-BUFFER (up to CB-CAPACITY bytes at CB-ADDR; CB-LENGTH out),
*> close-flag out (BINARY-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-ID                   BINARY-LONG.
 01 L-CLOSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID CORE-BUFFER L-CLOSE.
     IF CW-OPEN NOT = "Y"
         MOVE 0 TO CB-LENGTH
         MOVE 1 TO L-CLOSE
         GOBACK
     END-IF
     CALL "SESSION-OUTPUT" USING L-ID CORE-BUFFER L-CLOSE
     GOBACK.
 END PROGRAM CORE-CONN-OUTPUT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONN-CLOSED.
*> USING connection id: the transport closed; the player, if any, leaves.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID.
     IF CW-OPEN NOT = "Y"
         GOBACK
     END-IF
     CALL "SESSION-CLOSED" USING L-ID
     GOBACK.
 END PROGRAM CORE-CONN-CLOSED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-TICK.
*> One 50 ms game tick (research R6): the tick counter, the time of day and its Set Time cadence
*> (WORLD-TIME-TICK), the weather (WEATHER-TICK, step 3 of standin §9.5), break progress
*> (BLOCKS-TICK), the player survival and hunger rules (HEALTH-TICK, step 4), mob spawning (MOBS-SPAWN-TICK, step 5), the mobs
*> (MOBS-TICK, step 6), ground items (GROUND-ITEMS-TICK, step 7, last of the game rules), the
*> world simulation of 33 section 2.1 (WORLDSIM-TICK: scheduled block and fluid ticks, random ticks, the changes broadcast to the viewers, block
*> events; WORLDSIM-ACKS: the Block Changed Acks), the recipe book of each player whose inventory the tick changed (CRAFT-REFRESH-ALL), the
*> bench menus that are no longer valid (MENU-TICK), the automatic save (WORLD-AUTOSAVE-TICK) and the connections' keep-alives.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DEBUG               BINARY-LONG.
 PROCEDURE DIVISION.
     IF CW-OPEN NOT = "Y"
         GOBACK
     END-IF
     ADD 1 TO CW-TICKS
*>   A debug world runs no world work (debug-world.md section 6): only the connections' keep-alives.
     CALL "WORLD-IS-DEBUG" USING WS-DEBUG
     IF WS-DEBUG = 1
         CALL "SESSION-TICK"
         GOBACK
     END-IF
     CALL "WORLDSIM-SLEEP-TICK"
     CALL "WORLD-TIME-TICK"
     CALL "WEATHER-TICK"
     CALL "WORLDSIM-TICK"
     CALL "BLOCKS-TICK"
     CALL "HEALTH-TICK"
     CALL "MOBS-SPAWN-TICK"
     CALL "MOBS-TICK"
     CALL "GROUND-ITEMS-TICK"
     CALL "XP-ORBS-TICK"
     CALL "ARROWS-TICK"
     CALL "BE-TICK-ALL"
     CALL "MENU-DATA-TICK"
     CALL "GEN-QUEUE-TICK"
     CALL "GEN-SPAWN-TICK"
     CALL "CHUNK-FEED-TICK"
     CALL "CRAFT-REFRESH-ALL"
     CALL "MENU-TICK"
     CALL "WORLDSIM-ACKS"
     CALL "WORLD-AUTOSAVE-TICK"
     CALL "SESSION-TICK"
     GOBACK.
 END PROGRAM CORE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-CONSOLE-DRAIN.
*> USING CORE-BUFFER: moves up to CB-CAPACITY bytes of pending console lines into the buffer
*> (CB-LENGTH = bytes moved); the rest stays queued.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION USING CORE-BUFFER.
     IF CW-OPEN NOT = "Y"
         MOVE 0 TO CB-LENGTH
         GOBACK
     END-IF
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
     IF CW-OPEN NOT = "Y"
         MOVE 2 TO CST-RUN-STATE
         MOVE 0 TO CST-PLAYERS-ONLINE
         GOBACK
     END-IF
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
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-LINE                 PIC X.
 PROCEDURE DIVISION USING L-LINE.
     IF CW-OPEN NOT = "Y"
         GOBACK
     END-IF
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
     IF CW-OPEN NOT = "Y"
         GOBACK
     END-IF
     CALL "WORLD-SAVE"
     CALL "GEN-WORKERS-STOP"
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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-TYPE-DECIDE.
*> USING requested type (PIC X(10): CS-WORLD-TYPE, spaces = cobolcraft), type out (PIC X(10)), status out (BINARY-LONG,
*> CORE-WO-*). The rules of world-types section 2.1 for the folder CW-FOLDER: a folder with level.dat takes the type
*> of its WorldType (standard, cobolcraft, debug); an absent key with no dimensions/minecraft folder is an old
*> world, cobolcraft (rule 2); an absent key with a level.dat of the 26.3 layout (compound Data) is a standard world;
*> an absent key with that folder, a key of another value or a tag of another type is
*> refused CORE-WO-NO-WORLDTYPE (rules 3 and 4); a folder without level.dat that holds dimensions/ content is refused
*> CORE-WO-NO-LEVEL-DAT (WT-24: any region or entities file counts, WORLD-HAS-DATA); otherwise a new world takes the requested type (an unknown one is refused).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(32).
 01 WS-FILE                PIC X(1100).
 01 WS-INFO                PIC X(16).
 01 WS-HAS-LEVEL           PIC 9.
 01 WS-HAS-MINECRAFT       PIC 9.
 01 WS-HAS-DATA           BINARY-LONG.
 LINKAGE SECTION.
 01 L-REQUEST              PIC X(10).
 01 L-TYPE                 PIC X(10).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-REQUEST L-TYPE L-STATUS.
     MOVE CORE-WO-OK TO L-STATUS
     MOVE SPACES TO L-TYPE WS-FILE
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/level.dat" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
     MOVE 0 TO WS-HAS-LEVEL
     IF RETURN-CODE = 0
         MOVE 1 TO WS-HAS-LEVEL
     END-IF
     MOVE SPACES TO WS-FILE
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/dimensions/minecraft" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
     MOVE 0 TO WS-HAS-MINECRAFT
     IF RETURN-CODE = 0
         MOVE 1 TO WS-HAS-MINECRAFT
     END-IF
     MOVE 0 TO RETURN-CODE
     IF WS-HAS-LEVEL = 0
         CALL "WORLD-HAS-DATA" USING WS-HAS-DATA
         IF WS-HAS-DATA = 1
             MOVE CORE-WO-NO-LEVEL-DAT TO L-STATUS
             GOBACK
         END-IF
         MOVE L-REQUEST TO L-TYPE
         IF L-TYPE = SPACES
             MOVE "cobolcraft" TO L-TYPE
         END-IF
     ELSE
         CALL "LEVEL-PEEK-TYPE" USING WS-FOUND WS-TEXT
         EVALUATE TRUE
             WHEN WS-FOUND = 1
                 MOVE WS-TEXT TO L-TYPE
*>           A level.dat of a real 26.3 game (compound Data, no WorldType): a standard world (33 section 10).
             WHEN WS-FOUND = 3
                 MOVE "standard" TO L-TYPE
             WHEN WS-FOUND = 0 AND WS-HAS-MINECRAFT = 0
                 MOVE "cobolcraft" TO L-TYPE
             WHEN OTHER
                 MOVE CORE-WO-NO-WORLDTYPE TO L-STATUS
                 GOBACK
         END-EVALUATE
     END-IF
     IF L-TYPE NOT = "standard" AND L-TYPE NOT = "cobolcraft" AND L-TYPE NOT = "debug"
         MOVE CORE-WO-NO-WORLDTYPE TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM WORLD-TYPE-DECIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-CONTENT-OPEN.
*> USING world type (PIC X(10), standard, cobolcraft or debug), generated directory (PIC X(1024), CS-GENERATED-DIR),
*> status out (BINARY-LONG CORE-WO-*): opens the content set of the type (the cobolcraft set reads nothing from the
*> directory; a standard or debug set needs the packs check ok and loads the generated data). A set that does not
*> open is CORE-WO-PACKS-NOT-OK (FR-004): CT-PACKS-STATUS holds the packs answer.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY COREAPI.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-LOOT-STATUS         BINARY-LONG.
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(10).
 01 L-DIR                  PIC X(1024).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-TYPE L-DIR L-STATUS.
     MOVE SPACES TO WS-DIR
     EVALUATE L-TYPE
         WHEN "standard"
             MOVE CT-TYPE-STANDARD TO WS-TYPE
             MOVE L-DIR TO WS-DIR
         WHEN "debug"
             MOVE CT-TYPE-DEBUG TO WS-TYPE
             MOVE L-DIR TO WS-DIR
         WHEN OTHER
             MOVE CT-TYPE-COBOLCRAFT TO WS-TYPE
     END-EVALUATE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR WS-STATUS
     MOVE CORE-WO-OK TO L-STATUS
     IF WS-STATUS NOT = CT-OK
         MOVE CORE-WO-PACKS-NOT-OK TO L-STATUS
     ELSE
*>       The loot tables of the set (world-loot.cob): a standard or debug set uses them, a cobolcraft set (and a set whose loot
*>       data fails its shapes, with the errors on standard error) keeps the stand-in yield of BLOCK-DROPS.
         CALL "WORLD-LOOT-OPEN" USING L-TYPE L-DIR WS-LOOT-STATUS
         CALL "WORLD-RECIPES-OPEN" USING L-TYPE L-DIR WS-LOOT-STATUS
*>       The terrain data of the standard pipeline (WORLD-GEN-DATA-OPEN).
         CALL "WORLD-GEN-DATA-OPEN" USING L-TYPE L-DIR
     END-IF
     CALL "FURN-PROVIDERS-LOAD" USING WS-DIR
     GOBACK.
 END PROGRAM WORLD-CONTENT-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-GEN-DATA-OPEN.
*> USING world type (PIC X(10)), generated directory (PIC X(1024)): for a standard world loads the terrain data of the standard pipeline
*> (noises, density functions, surface rules and conditions, carvers) from <directory>/vanilla-data, after WORLDGEN-FREE, and resets the
*> generation queue. Without them GEN-DATA-READY is 0 and the world is void (worldgen-standard.cob). The cobolcraft type has none and the
*> debug type builds its grid without them: nothing is loaded for them.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATINDEX.
 01 WS-GEN-STATUS          BINARY-LONG.
 01 WS-GEN-DIR             PIC X(1100).
 LINKAGE SECTION.
 01 L-TYPE                 PIC X(10).
 01 L-DIR                  PIC X(1024).
 PROCEDURE DIVISION USING L-TYPE L-DIR.
     IF L-TYPE = "standard"
         MOVE SPACES TO WS-GEN-DIR
         STRING FUNCTION TRIM(L-DIR TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO WS-GEN-DIR
         CALL "WORLDGEN-FREE"
         CALL "NOISES-LOAD" USING WS-GEN-DIR WS-GEN-STATUS
         CALL "DENSITY-FUNCTIONS-LOAD" USING WS-GEN-DIR WS-GEN-STATUS
         CALL "MATERIAL-RULES-LOAD" USING WS-GEN-DIR WS-GEN-STATUS
         CALL "CARVERS-LOAD" USING WS-GEN-DIR WS-GEN-STATUS
*>       the feature lists of the biomes; the stage runs only their tree features (FI-ONLY)
         CALL "BIOMES-LOAD" USING WS-GEN-DIR WS-GEN-STATUS
         MOVE 1 TO FI-ONLY
         CALL "GEN-QUEUE-RESET"
     END-IF
     GOBACK.
 END PROGRAM WORLD-GEN-DATA-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-HAS-DATA.
*> USING found out (BINARY-LONG 1 or 0): 1 when a region or entities folder of any dimension of the table, in the
*> world folder CW-FOLDER, holds a file (saved chunks or entities that creating a world over it would destroy).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-D                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-KIND                PIC X(8).
 01 WS-DIR                 PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-DIRZ                PIC X(1025).
 01 WS-LIST                PIC X(4096).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 4096.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-FOUND.
     MOVE 0 TO L-FOUND
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > DIM-TABLE-ROWS
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
             MOVE "region" TO WS-KIND
             IF WS-K = 2
                 MOVE "entities" TO WS-KIND
             END-IF
             CALL "PERSIST-DIM-DIR" USING WS-D WS-KIND WS-DIR WS-LENGTH
             MOVE LOW-VALUES TO WS-DIRZ
             MOVE WS-DIR(1:WS-LENGTH) TO WS-DIRZ(1:WS-LENGTH)
             MOVE 0 TO WS-LIST-COUNT
             CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
                 BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
             IF WS-LIST-COUNT > 0
                 MOVE 1 TO L-FOUND
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM WORLD-HAS-DATA.
