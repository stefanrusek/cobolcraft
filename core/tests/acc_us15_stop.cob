*> Acceptance test, US15-2 core half (spec US15 scenario 2; FR-014; contracts/core-host-api.md §2
*> CORE-STOP; standin-content §16.2 row 29, §17): given players in play, a connection still logging
*> in and one that has only connected, and changes to the world, CORE-STOP with the stopping text
*> (the §17 key cobolcraft.disconnect.shutdown) saves the world, queues every connection the
*> Disconnect of its phase with that text (play: byte-equal to play-s2c-20-disconnect-stopping.hex;
*> login: Login Disconnect; handshake: none) and its close flag, and sets run state 2. Reopening the
*> saved world finds the changes and each player as they were.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY BLOCKS.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-WORLD               PIC X(64) VALUE Z"build/core-test-world".
 01 WS-REASON              PIC X(64) VALUE Z"cobolcraft.disconnect.shutdown".
 01 WS-CREATED             BINARY-LONG.
 01 WS-ALICE-NAME          PIC X(16) VALUE "Alice".
 01 WS-BOB-NAME            PIC X(16) VALUE "Bob".
 01 WS-CAROL-NAME          PIC X(16) VALUE "Carol".
 01 WS-LENGTH-5            BINARY-LONG VALUE 5.
 01 WS-LENGTH-3            BINARY-LONG VALUE 3.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-CAROL               BINARY-LONG.
 01 WS-BARE                BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 10.
 01 WS-Y                   BINARY-LONG VALUE 60.
 01 WS-Z                   BINARY-LONG VALUE 10.
 01 WS-STATE               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-LAST-ID             BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-CLOSE-ALICE         BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FIXTURE             PIC X(256)
     VALUE "contract/fixtures/wire/play-s2c-20-disconnect-stopping.hex".
 01 WS-ALICE-BEFORE        PIC X(8192).
 01 WS-BOB-BEFORE          PIC X(8192).
 01 WS-TEXT                PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 B-AREA                 PIC X(65536) BASED.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-LENGTH-5 WS-ALICE
     CALL "TEST-JOIN" USING WS-BOB-NAME WS-LENGTH-3 WS-BOB
     CALL "TEST-HELLO" USING WS-CAROL-NAME WS-LENGTH-5 WS-CAROL
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-BARE
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     MOVE WS-CAROL TO WS-ID
     PERFORM DRAIN-LAST

*>   Changes: a block, the time, and Alice's health, food and held slot.
     MOVE DIM-MAIN TO WS-DIM
     MOVE ST-LUCITE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 4321 TO CW-TIME
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 21.5 TO PL-HEALTH(WS-ROW)
     MOVE 13 TO PL-FOOD(WS-ROW)
     MOVE 2 TO PL-HELD(WS-ROW)
     CALL "TEST-PLAYER-SNAPSHOT" USING CN-PLAYER(WS-ALICE) WS-ALICE-BEFORE
     CALL "TEST-PLAYER-SNAPSHOT" USING CN-PLAYER(WS-BOB) WS-BOB-BEFORE

     CALL "CORE-STOP" USING WS-REASON

     MOVE "acceptance US15-2 given players and changes when CORE-STOP is called with the "
         & "stopping text then the run state becomes 2" TO TL-CASE
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE CST-RUN-STATE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US15-2 when CORE-STOP is called then each player in play is queued the "
         & "stopping Disconnect as its last packet (play-s2c-20-disconnect-stopping.hex)"
         TO TL-CASE
     MOVE WS-ALICE TO WS-ID
     PERFORM DRAIN-LAST
     MOVE WS-CLOSE TO WS-CLOSE-ALICE
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-FIXTURE TESTLIB-ASSERT
     MOVE WS-BOB TO WS-ID
     PERFORM DRAIN-LAST
     MOVE "acceptance US15-2 when CORE-STOP is called then the second player in play is queued "
         & "the same stopping Disconnect as its last packet" TO TL-CASE
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER WS-FIXTURE TESTLIB-ASSERT
     MOVE "acceptance US15-2 when CORE-STOP is called then each player's connection gets the "
         & "close flag" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE WS-CLOSE-ALICE TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-CLOSE TO WS-EDIT
     PERFORM APPEND-EDIT
     MOVE "1 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US15-2 when CORE-STOP is called then a connection still logging in is "
         & "queued Login Disconnect (id 0) and the close flag" TO TL-CASE
     MOVE WS-CAROL TO WS-ID
     PERFORM DRAIN-LAST
     PERFORM DESCRIBE-LAST
     MOVE "1 0 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US15-2 when CORE-STOP is called then a connection in the handshake is "
         & "queued no packet and the close flag" TO TL-CASE
     MOVE WS-BARE TO WS-ID
     PERFORM DRAIN-LAST
     PERFORM DESCRIBE-LAST
     MOVE "0 -1 1" TO TL-EXPECTED
     PERFORM CHECK

     CALL "CORE-WORLD-OPEN" USING WS-WORLD CORE-SETTINGS WS-CREATED
     MOVE "acceptance US15-2 when CORE-STOP is called then the world is saved: reopened, it is "
         & "an existing world with the changed block and time" TO TL-CASE
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z WS-STATE
     MOVE SPACES TO WS-TEXT
     MOVE WS-CREATED TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-STATE TO WS-EDIT
     PERFORM APPEND-EDIT
     MOVE CW-TIME TO WS-EDIT
     PERFORM APPEND-EDIT
     MOVE SPACES TO TL-EXPECTED
     MOVE ST-LUCITE TO WS-EDIT
     STRING "0 " FUNCTION TRIM(WS-EDIT) " 4321" DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US15-2 when CORE-STOP is called then each player in play is saved: "
         & "rejoining after the reopen finds them as they were" TO TL-CASE
     CALL "TEST-JOIN" USING WS-ALICE-NAME WS-LENGTH-5 WS-ALICE
     CALL "TEST-PLAYER-SNAPSHOT" USING CN-PLAYER(WS-ALICE) WS-TEXT
     MOVE WS-ALICE-BEFORE TO TL-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US15-2 when CORE-STOP is called then the second player in play is saved "
         & "too" TO TL-CASE
     CALL "TEST-JOIN" USING WS-BOB-NAME WS-LENGTH-3 WS-BOB
     CALL "TEST-PLAYER-SNAPSHOT" USING CN-PLAYER(WS-BOB) WS-TEXT
     MOVE WS-BOB-BEFORE TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Drains connection WS-ID: WS-COUNT packets, the last one in PK-BUFFER with its id in WS-LAST-ID
*> (-1 when none), and the close flag in WS-CLOSE.
 DRAIN-LAST.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-COUNT
     MOVE -1 TO WS-LAST-ID
     MOVE 0 TO WS-OUTCOME
     PERFORM UNTIL WS-OUTCOME NOT = 0
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
         IF WS-OUTCOME = 0
             ADD 1 TO WS-COUNT
             MOVE WS-PACKET-ID TO WS-LAST-ID
         END-IF
     END-PERFORM.

*> WS-TEXT: "<packets> <last id> <close flag>".
 DESCRIBE-LAST.
     MOVE SPACES TO WS-TEXT
     MOVE WS-COUNT TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-LAST-ID TO WS-EDIT
     PERFORM APPEND-EDIT
     MOVE WS-CLOSE TO WS-EDIT
     PERFORM APPEND-EDIT.

 APPEND-EDIT.
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-US15-STOP.

 COPY CORETEST.
