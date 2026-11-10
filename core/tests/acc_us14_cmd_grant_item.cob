*> Acceptance test, US14-2 supply (spec US14 scenario 2; FR-016; standin-content §16.2 row 18): the
*> grant-item command adds count (1 to 2304, default 1) of the item named by its key path to the
*> named player's inventory with the inventory add rule (what does not fit is not added), sends them
*> their inventory, and sends the sender cobolcraft.command.supply.done [number added, item path,
*> name]; supply.no_room when nothing fits; item_not_found for an unknown path or `nothing`. The
*> test world's default mode is creative, so Alice starts with an empty inventory.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US14-CMD-GRANT-ITEM.
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
     MOVE "acceptance US14-2 when an operator supplies Alice a pry_bar (count left "
         & "out: 1) then the sender is sent supply.done with the number added, the item "
         & "path and the name" TO TL-CASE
     MOVE "supply Alice pry_bar" TO WS-LINE
     MOVE "cobolcraft.command.supply.done(1,pry_bar,Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 Alice is sent her inventory (Container Set Content) and, "
         & "the inventory changed, the recipe book" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE "18" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 supplying 100 greystone adds them with the inventory add "
         & "rule" TO TL-CASE
     MOVE "supply Alice greystone 100" TO WS-LINE
     MOVE "cobolcraft.command.supply.done(100,greystone,Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 Alice's inventory holds the pry_bar and 100 greystone as "
         & "64 and 36" TO TL-CASE
     PERFORM INVENTORY-OF
     MOVE "0=10x1 1=2x64 2=2x36" TO TL-EXPECTED
     PERFORM CHECK-TEXT
     MOVE "acceptance US14-2 what does not fit is not added: 2304 loam into 33 empty "
         & "slots adds 2112" TO TL-CASE
     MOVE "supply Alice loam 2304" TO WS-LINE
     MOVE "cobolcraft.command.supply.done(2112,loam,Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 when nothing fits the sender is sent supply.no_room" TO TL-CASE
     MOVE "supply Alice turf" TO WS-LINE
     MOVE "cobolcraft.command.supply.no_room(Alice)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 the item nothing is not an item that can be supplied" TO TL-CASE
     MOVE "supply Alice nothing" TO WS-LINE
     MOVE "cobolcraft.command.item_not_found(nothing)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 an unknown item path sends item_not_found with the word "
         & "as typed" TO TL-CASE
     MOVE "supply Alice diamond 3" TO WS-LINE
     MOVE "cobolcraft.command.item_not_found(diamond)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 items are named by the path of their key, not the full "
         & "key" TO TL-CASE
     MOVE "supply Alice cobolcraft:loam" TO WS-LINE
     MOVE "cobolcraft.command.item_not_found(cobolcraft:loam)" TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 a count out of range is an invalid argument" TO TL-CASE
     MOVE "supply Alice loam 2305" TO WS-LINE
     MOVE "cobolcraft.command.invalid_argument(2305,supply <player> <item> [<count>])"
         TO TL-EXPECTED
     PERFORM OPAL-CHECK
     MOVE "acceptance US14-2 naming a player who is not online changes nothing and "
         & "sends the §16 player-not-found message (§16 target rule)" TO TL-CASE
     MOVE "supply Zed loam" TO WS-LINE
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

*> WS-TEXT: Alice's non-empty slots among 0 to 2 as "<slot>=<item>x<count>".
 INVENTORY-OF.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-N
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         IF PL-SLOT-COUNT(WS-ROW, WS-I) > 0
             IF WS-N > 1
                 STRING " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             END-IF
             COMPUTE WS-EDIT = WS-I - 1
             STRING FUNCTION TRIM(WS-EDIT) "=" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             MOVE PL-SLOT-ITEM(WS-ROW, WS-I) TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) "x" DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
             MOVE PL-SLOT-COUNT(WS-ROW, WS-I) TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-N
         END-IF
     END-PERFORM.

 END PROGRAM ACC-US14-CMD-GRANT-ITEM.

 COPY CORETEST.
