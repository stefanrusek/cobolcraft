*> Acceptance test, US14-2 empty (spec US14 scenario 2; FR-016; standin-content §16.2 row 19): the
*> clear-inventory command empties all 36 slots of the named player's inventory (nothing is
*> dropped), sends them their inventory and sends the sender cobolcraft.command.empty.done [name,
*> total number of items removed]. Only the two players' entities are tracked (no ground items).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-CLEAR-INVENTORY.
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
     MOVE "supply Alice loam 5" TO WS-LINE
     PERFORM OPAL-RUN
     MOVE "supply Alice pry_bar" TO WS-LINE
     PERFORM OPAL-RUN
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS
     MOVE "acceptance US14-2 when an operator empties Alice's inventory then the "
         & "sender is sent empty.done with the name and the total number of items removed"
         TO TL-CASE
     MOVE "empty Alice" TO WS-LINE
     MOVE "cobolcraft.command.empty.done(Alice,6)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 all 36 slots of Alice's inventory are empty and nothing "
         & "was dropped" TO TL-CASE
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         ADD PL-SLOT-COUNT(CN-PLAYER(WS-ALICE), WS-I) TO WS-N
     END-PERFORM
     MOVE EN-COUNT TO WS-I
     COMPUTE WS-N = WS-N * 1000 + WS-I
     MOVE WS-N TO WS-EDIT
     MOVE FUNCTION TRIM(WS-EDIT) TO WS-TEXT
     MOVE "2" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 Alice is sent her emptied inventory" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "18" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 emptying an empty inventory removes 0 items" TO TL-CASE
     MOVE "empty Alice" TO WS-LINE
     MOVE "cobolcraft.command.empty.done(Alice,0)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 naming a player who is not online changes nothing and "
         & "sends the §16 player-not-found message (§16 target rule)" TO TL-CASE
     MOVE "empty Zed" TO WS-LINE
     MOVE "cobolcraft.command.player_not_found(Zed)" TO TL-EXPECTED
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

 END PROGRAM ACC-US14-CMD-CLEAR-INVENTORY.

 COPY CORETEST.
