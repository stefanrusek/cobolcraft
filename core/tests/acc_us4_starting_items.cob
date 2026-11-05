*> Acceptance test, US4-8 (spec US4 scenario 8; tasks T456; standin-content §2 "Starting inventory";
*> 09 §3.2 Container Set Content rows): a first-time survival player's inventory holds the starting
*> items, sent in the join's Container Set Content (play-s2c-12-container-set-content-starting-
*> items.hex); a returning player is not given them again.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-STARTING-ITEMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PATH                PIC X(256).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS

     MOVE "acceptance US4-8 given a first-time survival player when they join then their "
         & "inventory holds the standin §2 starting items (Container Set Content equal to "
         & "play-s2c-12-container-set-content-starting-items.hex)" TO TL-CASE
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-starting-items.hex"
         TO WS-PATH
     CALL "STARTING-CONTENT-CASE" USING WS-CONN WS-PATH TESTLIB-ASSERT

     MOVE "acceptance US4-8 given a player who has been in the world when they join again "
         & "then they are not given the starting items again (Container Set Content equal to "
         & "play-s2c-12-container-set-content-empty.hex)" TO TL-CASE
     CALL "CORE-CONN-CLOSED" USING WS-CONN
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE "contract/fixtures/wire/play-s2c-12-container-set-content-empty.hex" TO WS-PATH
     CALL "STARTING-CONTENT-CASE" USING WS-CONN WS-PATH TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US4-STARTING-ITEMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STARTING-CONTENT-CASE.
*> USING connection id, fixture path, TESTLIB-ASSERT (TL-CASE set): drains the connection and
*> asserts its Container Set Content (0x12) equals the fixture.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 LINKAGE SECTION.
 COPY TESTLIB.
 01 L-ID                   BINARY-LONG.
 01 L-PATH                 PIC X(256).
 PROCEDURE DIVISION USING L-ID L-PATH TESTLIB-ASSERT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING L-ID PB-BUFFER WS-CLOSE
     MOVE 0 TO WS-OUTCOME
     MOVE -1 TO WS-PACKET-ID
     PERFORM UNTIL WS-OUTCOME NOT = 0 OR WS-PACKET-ID = 18
         CALL "PB-RESET" USING PK-BUFFER
         CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     END-PERFORM
     CALL "TEST-SAME-AS-FIXTURE" USING PK-BUFFER L-PATH TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING PK-BUFFER
     GOBACK.
 END PROGRAM STARTING-CONTENT-CASE.

 COPY CORETEST.
