*> Acceptance test, US2/US14 edge case (spec US2 and US14 edge cases; FR-010, FR-016; standin-content
*> §17; docs/protocol/09-cobolcraft-profile.md §3.1 Login Disconnect): a banned player who tries to
*> join is refused with Login Disconnect cobolcraft.disconnect.barred
*> (login-s2c-00-login-disconnect-banned.hex) and the connection closes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-BAN-LOGIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==ST-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-UUID                PIC X(16).
 01 WS-LIST                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OPAL                BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-CONSOLE             BINARY-LONG VALUE 0.
 01 WS-LINE                PIC X(768).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-IDS                 PIC X(1024).
 01 WS-PATH                PIC X(256).
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-DEDIT               PIC -(9)9.99.
 01 WS-AREA                PIC X(4096).
 01 WS-MINUS-ONE           BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM JOIN-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE "ban Mallory" TO WS-LINE
     PERFORM OPAL-RUN
     MOVE "Mallory" TO WS-NAME
     MOVE 7 TO WS-NAME-LENGTH
     CALL "TEST-HELLO" USING WS-NAME WS-NAME-LENGTH WS-ID
     PERFORM FIRST-PACKET
     MOVE "US2/US14 edge given a banned player when they try to join then Login "
         & "Disconnect carries the §17 barred message "
         & "(login-s2c-00-login-disconnect-banned.hex)" TO TL-CASE
     MOVE "contract/fixtures/wire/login-s2c-00-login-disconnect-banned.hex" TO WS-PATH
     CALL "TEST-SAME-AS-FIXTURE" USING PB-BUFFER WS-PATH TESTLIB-ASSERT
     MOVE "US2/US14 edge the banned player's connection is closed and no player is "
         & "created" TO TL-CASE
     COMPUTE WS-N = WS-CLOSE * 10 + 1
     CALL "PLAYERS-ONLINE" USING WS-I
     COMPUTE WS-N = WS-N + WS-I * 100
     MOVE WS-N TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "211" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "pardon Mallory" TO WS-LINE
     PERFORM OPAL-RUN
     CALL "TEST-HELLO" USING WS-NAME WS-NAME-LENGTH WS-ID
     PERFORM FIRST-PACKET
     MOVE "US2/US14 edge after the ban is lifted the player logs in (Login Finished)" TO TL-CASE
     MOVE WS-PACKET-ID TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "2" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     STOP RUN.

*> Opal holds operator status through the world's operator list.
 JOIN-OPAL.
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-OPERATORS TO WS-LIST
     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-OPAL.

*> Opal runs WS-LINE; WS-TEXT is the System Chat she is sent.
 OPAL-RUN.
     CALL "TEST-COMMAND" USING WS-OPAL WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT.

 OPAL-CHECK.
     PERFORM OPAL-RUN
     PERFORM CHECK-TEXT.

*> The console runs WS-LINE; WS-TEXT is the console lines it printed, separated by " | ".
 CONSOLE-RUN.
     PERFORM CONSOLE-LINES
     COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING))
     CALL "CMD-RUN" USING WS-CONSOLE WS-LINE WS-LENGTH
     PERFORM CONSOLE-LINES.

 CONSOLE-LINES.
     MOVE SPACES TO WS-AREA WS-TEXT
     SET CB-ADDR TO ADDRESS OF WS-AREA
     MOVE 4096 TO CB-CAPACITY
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
     MOVE 1 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-LENGTH
         IF WS-AREA(WS-I:1) = X"0A"
             IF WS-I < CB-LENGTH
                 STRING " | " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             END-IF
         ELSE
             STRING WS-AREA(WS-I:1) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
         END-IF
     END-PERFORM.

 CHECK-TEXT.
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM ASSERT-TEXT.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> WS-ID's stream: its first packet (id + body) into PB-BUFFER and the close flag.
 FIRST-PACKET.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING ST-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-ID ST-BUFFER WS-CLOSE
     CALL "TEST-NEXT-PACKET" USING ST-BUFFER PB-BUFFER WS-MINUS-ONE WS-PACKET-ID WS-OUTCOME
     CALL "PB-FREE" USING ST-BUFFER.

 END PROGRAM ACC-US14-BAN-LOGIN.

 COPY CORETEST.
