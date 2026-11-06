*> Acceptance test, US14-2 guestlist on / off (spec US14 scenario 2; FR-016; standin-content §16.2
*> rows 10 and 11; operator decision A2): the allow-list on and off commands switch the world's
*> enforcement flag (players already online stay) and confirm with cobolcraft.command.guestlist.on
*> or .off; the changed flag is saved in access.dat and still applies after the world is reopened
*> with a different allow-list setting (created flag 0, flag on).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-ALLOWLIST-TOGGLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
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
 01 WS-FOLDER              PIC X(64) VALUE Z"build/core-test-world".
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM JOIN-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE "acceptance US14-2 the guestlist on command turns allow-list enforcement on "
         & "and confirms with guestlist.on" TO TL-CASE
     MOVE "guestlist on" TO WS-LINE
     MOVE "cobolcraft.command.guestlist.on()" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 after guestlist on the world's enforcement flag is on" TO TL-CASE
     MOVE AC-ENFORCED TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US14-2 players already online stay when enforcement is turned on" TO TL-CASE
     CALL "PLAYERS-ONLINE" USING WS-N
     MOVE WS-N TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "2" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US14-2 the guestlist off command turns enforcement off and "
         & "confirms with guestlist.off" TO TL-CASE
     MOVE "guestlist off" TO WS-LINE
     MOVE "cobolcraft.command.guestlist.off()" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 after guestlist off the world's enforcement flag is off" TO TL-CASE
     MOVE AC-ENFORCED TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "guestlist on" TO WS-LINE
     PERFORM OPAL-RUN
     CALL "CORE-SAVE"
     MOVE 0 TO CS-ALLOW-LIST-ENFORCED
     CALL "CORE-WORLD-OPEN" USING WS-FOLDER CORE-SETTINGS WS-OUTCOME
     MOVE "acceptance US14-2 the changed flag is saved in access.dat and still "
         & "applies after the world is reopened with a different allow-list setting" TO TL-CASE
     COMPUTE WS-N = WS-OUTCOME * 10 + AC-ENFORCED
     MOVE WS-N TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO TL-OBSERVED
     MOVE "1" TO TL-EXPECTED
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

 END PROGRAM ACC-US14-CMD-ALLOWLIST-TOGGLE.

 COPY CORETEST.
