*> Implementation test of client/src/sp-host.cob and the memory connection of net-client.cob (US16;
*> research R7; core-host-api §2): opening a world runs the in-process core over a memory connection
*> without compression, with CS-HOST-KIND 1 and CS-ALLOW-LIST-ENFORCED 0 (a new world's access.dat
*> seeds AllowListEnforced 0); one core tick per elapsed 50 ms; none while the pause menu is open and
*> the world is not opened to others; quitting calls CORE-STOP (the world saved) and returns to the
*> title screen; the shutdown command (the host is an operator) quits too; a connection the core
*> ends stops hosting.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SP-HOST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-sp-host".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-FOLDER              PIC X(80) VALUE "First".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-NAME                PIC X(64) VALUE "First".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-LEVEL               PIC X(256)
     VALUE "build/client-test-sp-host/saves/First/level.dat".
 01 WS-TAG                 PIC X(64).
 01 WS-NUMBER              BINARY-LONG.
 01 WS-TAG-TEXT            PIC X(64).
 01 WS-INFO                PIC X(16).
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-T1                  BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-EVENTS              PIC X(24).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MS                  BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(1024).
 01 WS-TYPED               PIC X(64).
 01 WS-TYPED-LENGTH        BINARY-LONG.
 01 WS-REASON              PIC X(40) VALUE Z"cobolcraft.disconnect.host_closed".
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "sp host opening a world joins the in-process core over a memory connection without "
         & "compression: in play on the world screen, the Player online" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "joined 1 memory 1 core 1 threshold -1 screen 5 online 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE CN-MEMORY(CONN-GAME) TO WS-E2
     MOVE 0 TO WS-E3
     IF CN-CORE-ID(CONN-GAME) > 0
         MOVE 1 TO WS-E3
     END-IF
     MOVE CN-THRESHOLD(CONN-GAME) TO WS-E4
     MOVE SM-SCREEN TO WS-E5
     MOVE CST-PLAYERS-ONLINE TO WS-E6
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " memory " FUNCTION TRIM(WS-E2) " core "
         FUNCTION TRIM(WS-E3) " threshold " FUNCTION TRIM(WS-E4) " screen " FUNCTION TRIM(WS-E5)
         " online " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE "sp host the settings handed to the core carry the 002 fields: the world type (a new "
         & "world is a cobolcraft one unless the create screen chose), the game directory, no seed text"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "cobolcraft build/client-test-sp-host []" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(CS-WORLD-TYPE) " " FUNCTION TRIM(CS-GAME-DIR) " [" FUNCTION TRIM(CS-SEED-TEXT)
         "]" DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE "build/client-test-sp-host/saves/First/access.dat" TO WS-PATH
     MOVE 48 TO WS-PATH-LENGTH
     MOVE "AllowListEnforced" TO WS-TAG
     CALL "TEST-NBT-TAG" USING WS-PATH WS-PATH-LENGTH WS-TAG WS-NUMBER WS-TAG-TEXT
     MOVE "sp host the world is opened with host kind 1, the Player's name as host, the chosen "
         & "mode and name, allow-list off; the new world's access.dat seeds AllowListEnforced 0"
         TO TL-CASE
     MOVE "kind 1 host Alice mode 0 name First allow 0 access 0" TO TL-EXPECTED
     MOVE WS-NUMBER TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "kind " CS-HOST-KIND " host " FUNCTION TRIM(CS-HOST-NAME) " mode " CS-DEFAULT-MODE
         " name " FUNCTION TRIM(CS-NEW-WORLD-NAME) " allow " CS-ALLOW-LIST-ENFORCED " access "
         FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Tick cadence: 50 frames 20 ms apart are 1000 ms, 20 ticks; one frame 200 ms later catches up 4.
     MOVE SP-TICKS TO WS-TICKS
     PERFORM 50 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     COMPUTE WS-T1 = SP-TICKS - WS-TICKS
     MOVE SP-TICKS TO WS-TICKS
     MOVE 200 TO WS-MS
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-ZERO WS-MS
     MOVE "sp host one CORE-TICK per elapsed 50 ms: 20 in 1000 ms of 20 ms frames, 4 in one frame "
         & "200 ms later" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2004 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-T1 * 100 + SP-TICKS - WS-TICKS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Pausing (US16-4): Escape opens the pause menu; no ticks while it is open.
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE SP-TICKS TO WS-TICKS
     PERFORM 50 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     MOVE "acceptance US16-4 given a single-player world not open to others when the Player opens "
         & "the pause menu then the game is paused: no core tick in 1000 ms" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "screen 9 paused 1 ticks 0" TO TL-EXPECTED
     MOVE SM-SCREEN TO WS-E1
     MOVE SP-PAUSED TO WS-E2
     COMPUTE WS-E3 = SP-TICKS - WS-TICKS
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E1) " paused " FUNCTION TRIM(WS-E2) " ticks "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE SP-TICKS TO WS-TICKS
     MOVE 50 TO WS-MS
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-ZERO WS-MS
     MOVE "sp host back in the world the ticks go on without catching up the paused time: 1 tick "
         & "50 ms later" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 501 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SM-SCREEN * 100 + SP-PAUSED * 10 + SP-TICKS - WS-TICKS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A world opened to others (host kind 2) does not pause (US17-3).
     MOVE 2 TO CS-HOST-KIND
     MOVE CORE-SETTINGS TO SP-SETTINGS
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE SP-TICKS TO WS-TICKS
     PERFORM 10 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     MOVE "sp host with host kind 2 (opened to others) the pause menu does not pause: 4 ticks in "
         & "200 ms" TO TL-CASE
     MOVE 904 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SM-SCREEN * 100 + SP-PAUSED * 10 + SP-TICKS - WS-TICKS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO CS-HOST-KIND
     MOVE CORE-SETTINGS TO SP-SETTINGS

*>   Quitting (US16-5): the pause menu's quit-world control saves through CORE-STOP and returns
*>   to the title screen. level.dat is removed first, so finding it afterwards shows the save.
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "sp host the pause menu of a hosted world offers Save and Leave the World in place of "
         & "Disconnect" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "Game Menu|Back to the World|Open to Others|Save and Leave the World" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CBL_DELETE_FILE" USING WS-LEVEL
     MOVE ACT-QUIT-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "sp host quitting the world calls CORE-STOP (run state 2, level.dat saved), closes the "
         & "memory connection and returns to the title screen" TO TL-CASE
     MOVE "found 1 active 0 run 2 saved 1 phase 0 core 0 screen 1" TO TL-EXPECTED
     MOVE WS-FOUND TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
     MOVE CST-RUN-STATE TO WS-E3
     MOVE 0 TO WS-E4
     CALL "CBL_CHECK_FILE_EXIST" USING WS-LEVEL WS-INFO
     IF RETURN-CODE = 0
         MOVE 1 TO WS-E4
     END-IF
     MOVE 0 TO RETURN-CODE
     MOVE CN-PHASE(CONN-GAME) TO WS-E5
     MOVE CN-CORE-ID(CONN-GAME) TO WS-E6
     MOVE SPACES TO TL-OBSERVED
     STRING "found " FUNCTION TRIM(WS-E1) " active " FUNCTION TRIM(WS-E2) " run "
         FUNCTION TRIM(WS-E3) " saved " FUNCTION TRIM(WS-E4) " phase " FUNCTION TRIM(WS-E5)
         " core " FUNCTION TRIM(WS-E6) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " screen " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The shutdown command in a hosted world is the host quitting (standin-content §16 row 29): the
*>   host holds operator status, so it runs; the next frame quits the world.
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE 0 TO CH-COUNT
     MOVE CC-KEY-SLASH TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "shutdown" TO WS-TYPED
     MOVE 8 TO WS-TYPED-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-TYPED-LENGTH
     MOVE CC-KEY-ENTER TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10 OR SP-ACTIVE = 0
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "sp host the host's /shutdown command (operator status as host) quits the world: saved "
         & "(run state 2), title screen" TO TL-CASE
     MOVE "joined 1 active 0 run 2 screen 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
     MOVE CST-RUN-STATE TO WS-E3
     MOVE SM-SCREEN TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " active " FUNCTION TRIM(WS-E2) " run "
         FUNCTION TRIM(WS-E3) " screen " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "sp host the shutdown confirmation (sent before stopping, standin-content §16 row 29) "
         & "reaches the host's chat before the world is quit" TO TL-CASE
     MOVE "Shutting down" TO TL-EXPECTED
     MOVE "none" TO TL-OBSERVED
     IF CH-COUNT > 0
         MOVE CH-TEXT(CH-COUNT) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A connection the core ends: CORE-STOP called past the host sends Disconnect and hands the
*>   memory connection back (close flag; the host itself cannot be ejected); the client shows
*>   the message and, the connection over, hosting stops.
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     CALL "CORE-STOP" USING WS-REASON
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10 OR SP-ACTIVE = 0
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "sp host a Disconnect from the core ends the memory connection (handed back, not lost: "
         & "the server list shows the core's message) and stops hosting" TO TL-CASE
     MOVE "joined 1 active 0 run 2 phase 0 core 0 screen 2 message The host closed the world"
         TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE SP-ACTIVE TO WS-E2
     MOVE CST-RUN-STATE TO WS-E3
     MOVE CN-PHASE(CONN-GAME) TO WS-E4
     MOVE CN-CORE-ID(CONN-GAME) TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " active " FUNCTION TRIM(WS-E2) " run "
         FUNCTION TRIM(WS-E3) " phase " FUNCTION TRIM(WS-E4) " core " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SM-SCREEN TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " screen " FUNCTION TRIM(WS-E1) " message "
         SM-MESSAGE(1:SM-MESSAGE-LENGTH) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SP-HOST.
 COPY CLTEST.
