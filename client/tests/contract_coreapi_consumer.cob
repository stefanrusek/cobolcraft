*> Contract test, the client's consumer side of the game core host API (contracts/core-host-api.md
*> §1, §2, §4): record lengths and constant values from COREAPI.cpy; the single-player host's call
*> sequence: CORE-WORLD-OPEN of saves/<folder> with host kind 1, the Player's name as host name and
*> the chosen mode (a world created from the create-world screen); CORE-CONN-OPEN memory; input and
*> output pumped each frame until the Player is in play; one CORE-TICK per elapsed 50 ms; CORE-STOP
*> on quit (the world and the Player's file saved, run state 2).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CL-CONTRACT-COREAPI-CONSUMER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-coreapi".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 25.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FOUND-ALL           BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-PATH                PIC X(256)
     VALUE "build/client-test-coreapi/saves/New World/level.dat".
 01 WS-PATH-LENGTH         BINARY-LONG VALUE 51.
 01 WS-TAG                 PIC X(64).
 01 WS-NUMBER              BINARY-LONG.
 01 WS-TAG-TEXT            PIC X(64).
 01 WS-INFO                PIC X(16).
 01 WS-TICKS               BINARY-DOUBLE.
 01 WS-DIRZ                PIC X(64) VALUE Z"build/client-test-coreapi/saves/New World/players".
 01 WS-LIST                PIC X(4096).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 4096.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "contract client coreapi consumer record lengths CORE-SETTINGS 3829 CORE-BUFFER 16 "
         & "CORE-STATUS 5 (core-host-api §1)" TO TL-CASE
     MOVE 3829016005 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = LENGTH OF CORE-SETTINGS * 1000000 + LENGTH OF CORE-BUFFER * 1000
         + LENGTH OF CORE-STATUS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract client coreapi consumer connection kinds network 0 memory 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = CORE-CONN-NETWORK * 10 + CORE-CONN-MEMORY
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "contract client coreapi consumer the client keeps a whole CORE-SETTINGS record"
         TO TL-CASE
     MOVE LENGTH OF CORE-SETTINGS TO TL-EXPECTED-N
     MOVE LENGTH OF SP-SETTINGS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   CORE-WORLD-OPEN: title, Single-player, Create New World, creative, Create.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE 1 TO WS-FOUND-ALL
     MOVE ACT-SINGLE-PLAYER TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MULTIPLY WS-FOUND BY WS-FOUND-ALL
     MOVE ACT-NEW-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MULTIPLY WS-FOUND BY WS-FOUND-ALL
     MOVE ACT-WORLD-MODE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MULTIPLY WS-FOUND BY WS-FOUND-ALL
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MULTIPLY WS-FOUND BY WS-FOUND-ALL
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE "GameMode" TO WS-TAG
     CALL "TEST-NBT-TAG" USING WS-PATH WS-PATH-LENGTH WS-TAG WS-NUMBER WS-TAG-TEXT
     MOVE "contract client coreapi consumer CORE-WORLD-OPEN of saves/<folder> with host kind 1, the "
         & "Player's name as host name and the chosen mode; the new world is saved (level.dat "
         & "GameMode)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "clicked 1 kind 1 host Alice mode 1 world New World level.dat mode 1" TO TL-EXPECTED
     MOVE WS-FOUND-ALL TO WS-E1
     MOVE WS-NUMBER TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "clicked " FUNCTION TRIM(WS-E1) " kind " CS-HOST-KIND " host "
         FUNCTION TRIM(CS-HOST-NAME) " mode " CS-DEFAULT-MODE " world "
         FUNCTION TRIM(CS-NEW-WORLD-NAME) " level.dat mode " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   CORE-CONN-OPEN memory, then input and output pumped every frame.
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE "contract client coreapi consumer CORE-CONN-OPEN memory (no compression); pumping "
         & "CORE-CONN-INPUT and CORE-CONN-OUTPUT brings the Player into play, creative" TO TL-CASE
     MOVE "memory 1 threshold -1 joined 1 online 1 mode 1" TO TL-EXPECTED
     MOVE CN-MEMORY(CONN-GAME) TO WS-E1
     MOVE CN-THRESHOLD(CONN-GAME) TO WS-E2
     MOVE WS-JOINED TO WS-E3
     MOVE CST-PLAYERS-ONLINE TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING "memory " FUNCTION TRIM(WS-E1) " threshold " FUNCTION TRIM(WS-E2) " joined "
         FUNCTION TRIM(WS-E3) " online " FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE PL-MODE TO WS-E1
     STRING FUNCTION TRIM(TL-OBSERVED) " mode " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Tick cadence: 1000 ms of 20 ms frames.
     MOVE SP-TICKS TO WS-TICKS
     PERFORM 50 TIMES
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     MOVE "contract client coreapi consumer one CORE-TICK per elapsed 50 ms: 20 in 1000 ms"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SP-TICKS - WS-TICKS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   CORE-STOP on quit: level.dat removed first; the quit control saves it and the Player's file.
     CALL "CBL_DELETE_FILE" USING WS-PATH
     CALL "SP-QUIT" USING CLIENT-STATE
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE 0 TO WS-LIST-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
     MOVE "contract client coreapi consumer quitting calls CORE-STOP: run state 2, level.dat and "
         & "the Player's file saved" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "run 2 saved 1 players 1" TO TL-EXPECTED
     MOVE CST-RUN-STATE TO WS-E1
     MOVE 0 TO WS-E2
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     IF RETURN-CODE = 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE 0 TO RETURN-CODE
     MOVE WS-LIST-COUNT TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "run " FUNCTION TRIM(WS-E1) " saved " FUNCTION TRIM(WS-E2) " players "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM CL-CONTRACT-COREAPI-CONSUMER.
 COPY CLTEST.
