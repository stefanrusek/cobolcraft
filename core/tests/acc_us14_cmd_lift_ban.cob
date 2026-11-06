*> Acceptance test, US14-2 unbar (spec US14 scenario 2; FR-016; standin-content §16.1, §16.2 row 8):
*> the lift-ban command removes the identity from the ban list and confirms with
*> cobolcraft.command.unbar.done [name]; a name not on the list gets unbar.not_barred; any valid
*> name works, online or not.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-LIFT-BAN.
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
     MOVE "bar Alice" TO WS-LINE
     PERFORM OPAL-RUN
     MOVE "acceptance US14-2 when an operator lifts Alice's ban then the sender is "
         & "sent unbar.done" TO TL-CASE
     MOVE "unbar Alice" TO WS-LINE
     MOVE "cobolcraft.command.unbar.done(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 the lifted ban is removed from the ban list" TO TL-CASE
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     PERFORM LISTED
     MOVE "not listed" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 lifting the ban of a player who is not barred sends "
         & "unbar.not_barred" TO TL-CASE
     MOVE "unbar Alice" TO WS-LINE
     MOVE "cobolcraft.command.unbar.not_barred(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "bar Ghost" TO WS-LINE
     PERFORM OPAL-RUN
     MOVE "acceptance US14-2 naming a valid offline player who has never joined "
         & "works, the identity coming from the name's offline UUID" TO TL-CASE
     MOVE "unbar Ghost" TO WS-LINE
     MOVE "cobolcraft.command.unbar.done(Ghost)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 an invalid name sends invalid_name" TO TL-CASE
     MOVE "unbar Gh*st" TO WS-LINE
     MOVE "cobolcraft.command.invalid_name(Gh*st)" TO TL-EXPECTED
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

*> WS-TEXT: "listed" when the identity of WS-NAME is on the ban list, else "not listed".
 LISTED.
     CALL "LOGIN-OFFLINE-UUID" USING WS-NAME WS-NAME-LENGTH WS-UUID
     MOVE ACCESS-BANS TO WS-LIST
     CALL "ACCESS-FIND" USING WS-LIST WS-UUID WS-ROW
     MOVE "not listed" TO WS-TEXT
     IF WS-ROW > 0
         MOVE "listed" TO WS-TEXT
     END-IF.

 END PROGRAM ACC-US14-CMD-LIFT-BAN.

 COPY CORETEST.
