*> Implementation test of command edges (core/src/commands.cob; standin-content §16.1; FR-012): a
*> player whose connection has not reached play is not online for the target rule and is treated as
*> offline by promote; adding to a full operator, ban or allow-list (CORE-MAX-ACCESS) is a non-fatal
*> failure: the console line "ERROR access: the list is full", no reply, nothing changes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COMMAND-EDGES.
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
     MOVE "Lurker" TO WS-NAME
     MOVE 6 TO WS-NAME-LENGTH
     CALL "TEST-HELLO" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE "test command edges a player who has logged in but is not yet in play is "
         & "not online for a command acting on a player in the world" TO TL-CASE
     MOVE "murmur Lurker hello" TO WS-LINE
     MOVE "cobolcraft.command.player_not_found(Lurker)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "test command edges promoting a player who is not yet in play records the "
         & "identity as offline" TO TL-CASE
     MOVE "promote Lurker" TO WS-LINE
     MOVE "cobolcraft.command.promote.done(Lurker)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "test command edges the not-yet-in-play player was not given operator "
         & "status by the promote command" TO TL-CASE
     MOVE PL-OPERATOR(CN-PLAYER(WS-BOB)) TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE "0" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE ACCESS-OPERATORS TO WS-LIST
     PERFORM FILL-LIST
     MOVE "test command edges promoting into a full operator list sends nothing back" TO TL-CASE
     MOVE "promote Alice" TO WS-LINE
     MOVE SPACES TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "test command edges a full operator list is a non-fatal failure: one ERROR "
         & "console line" TO TL-CASE
     PERFORM CONSOLE-LINES
     MOVE "ERROR access: the list is full" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE ACCESS-BANS TO WS-LIST
     PERFORM FILL-LIST
     MOVE "test command edges barring into a full ban list sends nothing back and "
         & "Alice stays" TO TL-CASE
     MOVE "bar Alice" TO WS-LINE
     MOVE SPACES TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "test command edges a full ban list is a non-fatal failure: one ERROR "
         & "console line" TO TL-CASE
     PERFORM CONSOLE-LINES
     MOVE "ERROR access: the list is full" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE ACCESS-ALLOW TO WS-LIST
     PERFORM FILL-LIST
     MOVE "test command edges adding to a full allow-list sends nothing back" TO TL-CASE
     MOVE "guestlist add Alice" TO WS-LINE
     MOVE SPACES TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "test command edges a full allow-list is a non-fatal failure: one ERROR "
         & "console line" TO TL-CASE
     PERFORM CONSOLE-LINES
     MOVE "ERROR access: the list is full" TO TL-EXPECTED
     PERFORM CHECK-TEXT
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

*> Fills list WS-LIST up to CORE-MAX-ACCESS rows with identities that are nobody's.
 FILL-LIST.
     MOVE "Filler" TO WS-NAME
     MOVE 6 TO WS-NAME-LENGTH
     MOVE ALL "F" TO WS-UUID
     PERFORM VARYING WS-I FROM AC-COUNT(WS-LIST) BY 1 UNTIL WS-I >= CORE-MAX-ACCESS
         MOVE WS-I TO WS-EDIT
         MOVE WS-EDIT TO WS-UUID(7:10)
         CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME
     END-PERFORM
     PERFORM CONSOLE-LINES.

 END PROGRAM TEST-COMMAND-EDGES.

 COPY CORETEST.
