*> Entity NBT, part 3 (docs/protocol/45-entity-nbt-3-player-and-player-data.md sections 2, 3.4 and 12; lane 002-lane-p49k, T24570): in a world of the 26.3 layout (CW-LAYOUT 1) the player
*> file players/data/<uuid>.dat carries the keys of the standard player file besides the core's own: SelectedItemSlot, playerGameType, foodLevel, foodTickTimer, foodExhaustionLevel,
*> SleepTimer, XpSeed, Score, abilities (the seven values of the game mode), spawn_extra_particles_on_fall and post_effects; a file that holds only those keys (a file of the game itself)
*> loads the held slot, the game mode and the food level from them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FILE                PIC X(256).
 01 WS-ROOT                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-HEX                 PIC X(1024).
 01 WS-AREA                PIC X(512).
 01 WS-SIXTEEN             BINARY-LONG VALUE 16.
 01 WS-UUID-TEXT           PIC X(36).
 01 WS-SUFFIX              PIC X(128).
 01 WS-FILE-PATH           PIC X(1100).
 01 WS-FILE-LENGTH         BINARY-LONG.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-SEVEN               BINARY-LONG VALUE 7.
 01 WS-SIX                 BINARY-LONG VALUE 6.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-UUID                PIC X(16).
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 1 TO CW-LAYOUT
     CALL "CBL_CREATE_DIR" USING "build/core-test-world/players/data"
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 12 TO PL-FOOD(WS-ROW)
     MOVE 4 TO PL-HELD(WS-ROW)
     CALL "CORE-SAVE"
     PERFORM PLAYER-FILE
     CALL "TEST-NBT-FILE" USING WS-FILE PB-BUFFER WS-ROOT
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-OBSERVED
     MOVE "SelectedItemSlot" TO WS-PATH PERFORM ADD-GET
     MOVE "playerGameType" TO WS-PATH PERFORM ADD-GET
     MOVE "foodLevel" TO WS-PATH PERFORM ADD-GET
     MOVE "foodTickTimer" TO WS-PATH PERFORM ADD-GET
     MOVE "foodExhaustionLevel" TO WS-PATH PERFORM ADD-GET
     MOVE "SleepTimer" TO WS-PATH PERFORM ADD-GET
     MOVE "XpSeed" TO WS-PATH PERFORM ADD-GET
     MOVE "Score" TO WS-PATH PERFORM ADD-GET
     MOVE "spawn_extra_particles_on_fall" TO WS-PATH PERFORM ADD-GET
     MOVE "post_effects" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance US15 45-3 the 26.3 player file: held slot 4, creative, food 12, the timers, the seed and the score at 0, no particles, no post effects" TO TL-CASE
     MOVE "4 1 12 0 0.000 0 0 0 0 []" TO TL-EXPECTED
     PERFORM CHECK
     MOVE SPACES TO WS-OBSERVED
     MOVE "abilities" TO WS-PATH PERFORM ADD-GET
     MOVE "acceptance US15 45-3 the abilities of creative: invulnerable, flying off, mayfly, instabuild, mayBuild, the two speeds" TO TL-CASE
     MOVE "{invulnerable:1,flying:0,mayfly:1,instabuild:1,mayBuild:1,flySpeed:0.050,walkSpeed:0.100}" TO TL-EXPECTED
     PERFORM CHECK

*>   A file of the game itself has no HeldSlot, GameMode or Food: its own keys are read.
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     MOVE "SelectedItemSlot" TO WN MOVE 16 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-SIX
     MOVE "playerGameType" TO WN MOVE 14 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-TWO
     MOVE "foodLevel" TO WN MOVE 9 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-SEVEN
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE PL-UUID(WS-ROW) TO WS-UUID
     CALL "PERSIST-UUID-TEXT" USING WS-UUID WS-UUID-TEXT
     MOVE SPACES TO WS-SUFFIX
     STRING "/players/data/" WS-UUID-TEXT ".dat" DELIMITED BY SIZE INTO WS-SUFFIX
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-FILE-PATH WS-FILE-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-FILE-PATH WS-FILE-LENGTH PB-BUFFER
     CALL "PLAYER-DAT-READ" USING WS-UUID WS-ROW
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 45-3 a file with only SelectedItemSlot 6, playerGameType 2 and foodLevel 7 loads held slot 6, adventure, food 7" TO TL-CASE
     MOVE 627 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = KN-HELD(WS-ROW) * 100 + KN-MODE(WS-ROW) * 10 + KN-FOOD(WS-ROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 PLAYER-FILE.
     MOVE PL-UUID(WS-ROW) TO WS-AREA
     CALL "TEST-HEX-OF" USING WS-AREA WS-SIXTEEN WS-HEX
     MOVE SPACES TO WS-FILE
     STRING "build/core-test-world/players/data/" WS-HEX(1:8) "-" WS-HEX(9:4) "-" WS-HEX(13:4) "-"
         WS-HEX(17:4) "-" WS-HEX(21:12) ".dat" DELIMITED BY SIZE INTO WS-FILE.
 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE
         INTO WS-OBSERVED.
 CHECK.
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-NBT-3.
 COPY CORETEST.
