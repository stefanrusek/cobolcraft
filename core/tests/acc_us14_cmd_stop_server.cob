*> Acceptance test, US14-2 shutdown (spec US14 scenario 2; FR-016; standin-content §16.2 row 29;
*> contracts/core-host-api.md §2 CORE-STATUS-GET): the stop-server command sends the sender
*> cobolcraft.command.shutdown.done and then sets run state 1 (stop requested); the host does the
*> stopping (US15).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-STOP-SERVER.
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
     MOVE "acceptance US14-2 when an operator runs the stop-server command then the "
         & "sender is sent shutdown.done before stopping" TO TL-CASE
     MOVE "shutdown" TO WS-LINE
     MOVE "cobolcraft.command.shutdown.done()" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 the stop-server command sets run state 1 "
         & "(CORE-STATUS-GET: stop requested)" TO TL-CASE
     CALL "CORE-STATUS-GET" USING CORE-STATUS
     MOVE CST-RUN-STATE TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE "1" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 the console may run the stop-server command too" TO TL-CASE
     MOVE "shutdown" TO WS-LINE
     PERFORM CONSOLE-RUN
     MOVE "Shutting down" TO TL-EXPECTED
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

 END PROGRAM ACC-US14-CMD-STOP-SERVER.

 COPY CORETEST.
