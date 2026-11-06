*> Acceptance test, US14-2 guestlist add / remove (spec US14 scenario 2; FR-016; standin-content
*> §16.1 target rule, §16.2 rows 12 and 13): the allow-list add and remove commands change the list
*> (confirmations guestlist.added / guestlist.removed; guestlist.already / guestlist.not_listed when
*> nothing changes); a removed online player stays online; any valid name works, online or not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-ALLOWLIST-EDIT.
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
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     PERFORM JOIN-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     MOVE "acceptance US14-2 the guestlist add command adds the identity to the "
         & "allow-list and confirms with guestlist.added" TO TL-CASE
     MOVE "guestlist add Alice" TO WS-LINE
     MOVE "cobolcraft.command.guestlist.added(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 after guestlist add Alice's identity is on the allow-list" TO TL-CASE
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     PERFORM ALLOWED
     MOVE "listed" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 adding a listed player sends guestlist.already" TO TL-CASE
     MOVE "guestlist add Alice" TO WS-LINE
     MOVE "cobolcraft.command.guestlist.already(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 the guestlist remove command removes the identity and "
         & "confirms with guestlist.removed" TO TL-CASE
     MOVE "guestlist remove Alice" TO WS-LINE
     MOVE "cobolcraft.command.guestlist.removed(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 after guestlist remove Alice is not on the allow-list "
         & "and, online, stays online" TO TL-CASE
     PERFORM ALLOWED
     CALL "PLAYERS-ONLINE" USING WS-N
     MOVE WS-N TO WS-EDIT
     STRING " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT(11:)
     MOVE "not listed 2" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 removing a player who is not listed sends "
         & "guestlist.not_listed" TO TL-CASE
     MOVE "guestlist remove Alice" TO WS-LINE
     MOVE "cobolcraft.command.guestlist.not_listed(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 naming a valid offline player who has never joined "
         & "works, the identity coming from the name's offline UUID" TO TL-CASE
     MOVE "guestlist add Ghost" TO WS-LINE
     MOVE "cobolcraft.command.guestlist.added(Ghost)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 the never-joined player's identity is on the allow-list" TO TL-CASE
     MOVE "Ghost" TO WS-NAME
     PERFORM ALLOWED
     MOVE "listed" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 an invalid name sends invalid_name" TO TL-CASE
     MOVE "guestlist remove G host" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(host,guestlist remove <player>)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 a name with a character not allowed at login sends "
         & "invalid_name" TO TL-CASE
     MOVE "guestlist add G#ost" TO WS-LINE
     MOVE "cobolcraft.command.invalid_name(G#ost)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
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

*> WS-TEXT: "listed" when the identity of WS-NAME is on the allow-list, else "not listed".
 ALLOWED.
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-ALLOW TO WS-LIST
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
     MOVE "not listed" TO WS-TEXT
     IF WS-ROW > 0
         MOVE "listed" TO WS-TEXT
     END-IF.

 END PROGRAM ACC-US14-CMD-ALLOWLIST-EDIT.

 COPY CORETEST.
