*> Acceptance test, US14-2 murmur (spec US14 scenario 2; FR-016; standin-content §16.1 target rule,
*> §16.2 row 3): the private-message command delivers the text to the named player only
*> (cobolcraft.command.murmur.incoming [sender name, message], or .incoming_console [message] from
*> the console) and confirms to the sender (cobolcraft.command.murmur.sent [target, message]); a
*> target who is not online changes nothing and gets the sender player_not_found.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-PRIVATE-MESSAGE.
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
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     MOVE "acceptance US14-2 given Opal, Alice and Bob online when Opal murmurs to "
         & "Alice then Opal is sent the murmur.sent confirmation with the name and the "
         & "text as written" TO TL-CASE
     MOVE "murmur Alice meet me  at spawn" TO WS-LINE
     MOVE "cobolcraft.command.murmur.sent(Alice,meet me  at spawn)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 when Opal murmurs to Alice then Alice is sent "
         & "murmur.incoming with the sender's name and the text" TO TL-CASE
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-TEXT
     MOVE "cobolcraft.command.murmur.incoming(Opal,meet me  at spawn)" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 when Opal murmurs to Alice then Bob is sent nothing" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-BOB WS-IDS
     MOVE WS-IDS TO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US14-2 murmur is an everyone command: Bob, without operator "
         & "status, murmurs to Opal" TO TL-CASE
     MOVE "murmur Opal hi" TO WS-LINE
     CALL "TEST-COMMAND" USING WS-BOB WS-LINE
     CALL "TEST-DRAIN-CHAT" USING WS-BOB WS-TEXT
     CALL "TEST-DRAIN-CHAT" USING WS-OPAL WS-AREA
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " / " FUNCTION TRIM(WS-AREA) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "cobolcraft.command.murmur.sent(Opal,hi) / cobolcraft.command.murmur.incoming(Bob,hi)"
         TO TL-EXPECTED
     PERFORM ASSERT-TEXT
     MOVE "acceptance US14-2 naming a player who is not online changes nothing and "
         & "sends the §16 player-not-found message (§16 target rule)" TO TL-CASE
     MOVE "murmur Zed are you there" TO WS-LINE
     MOVE "cobolcraft.command.player_not_found(Zed)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 naming a name that is not valid at login sends the "
         & "invalid-name message" TO TL-CASE
     MOVE "murmur Z.ed hi" TO WS-LINE
     MOVE "cobolcraft.command.invalid_name(Z.ed)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 a murmur from the console reaches the player as "
         & "murmur.incoming_console and the console prints the murmur.sent confirmation" TO TL-CASE
     MOVE "murmur Alice server here" TO WS-LINE
     PERFORM CONSOLE-RUN
     CALL "TEST-DRAIN-CHAT" USING WS-ALICE WS-AREA
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " / " FUNCTION TRIM(WS-AREA) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "You murmur to Alice: server here / cobolcraft.command.murmur.incoming_console(server "
         & "here)" TO TL-EXPECTED
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

 END PROGRAM ACC-US14-CMD-PRIVATE-MESSAGE.

 COPY CORETEST.
