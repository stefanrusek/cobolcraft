*> Acceptance test of docs/protocol/16-commands-catalog.md §6.2 `clear` (permission level 2) with 14a: without an item every item of the target's inventory (the 36
*> slots and the cursor) is removed, with an item predicate the matching ones, at most maxCount of them (0: only counted, nothing
*> removed); the player is sent the inventory; commands.clear.success.single [count, player] or .multiple [count, players],
*> .test.single or .test.multiple for maxCount 0 (broadcast); nothing found is clear.failed.single [player] or .multiple [players];
*> the result is the number of items found. Item tags and conditions in the predicate are BLOCKED (refused). Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-BOB            BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-WANT                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-KEY-TEXT            PIC X(48).
 01 WS-ITEM-ID             BINARY-LONG.
 COPY CITEMS.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-BOB
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-BOB WS-DISCARD
     MOVE "pry_bar" TO WS-NAME
     MOVE "give Alice greystone 100" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     MOVE "give Alice pry_bar" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     MOVE "give Bob loam 10" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-DISCARD
     MOVE "acceptance US13 /clear maxCount 0 only counts: Found 1 match" & "ing item on player Alice" TO TL-CASE
     MOVE "clear Alice pry_bar 0" TO WS-LINE
     MOVE "commands.clear.test.single(1,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear nothing was removed" TO TL-CASE
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-ROW
     MOVE "cobolcraft:pry_bar" TO WS-KEY-TEXT
     PERFORM SUM-ITEM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /clear at most maxCount items are removed" TO TL-CASE
     MOVE "clear Alice greystone 10" TO WS-LINE
     MOVE "commands.clear.success.single(10,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear 90 greystone are left" TO TL-CASE
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-ROW
     MOVE "cobolcraft:greystone" TO WS-KEY-TEXT
     PERFORM SUM-ITEM
     MOVE 90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /clear every item that matches" TO TL-CASE
     MOVE "clear Alice pry_bar" TO WS-LINE
     MOVE "commands.clear.success.single(1,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear the pry_bar is gone" TO TL-CASE
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-ROW
     MOVE "cobolcraft:pry_bar" TO WS-KEY-TEXT
     PERFORM SUM-ITEM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /clear without an item every item goes: the " & "result is the count removed" TO TL-CASE
     MOVE "clear Alice" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 90 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /clear Alice's inventory is empty" TO TL-CASE
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-ROW
     MOVE "cobolcraft:greystone" TO WS-KEY-TEXT
     PERFORM SUM-ITEM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /clear nothing found: No items were found on" & " player Alice" TO TL-CASE
     MOVE "clear Alice" TO WS-LINE
     MOVE "clear.failed.single(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear several players, one with items: the " & "single message" TO TL-CASE
     MOVE "clear @a" TO WS-LINE
     MOVE "commands.clear.success.single(10,Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear no items on any of three players" TO TL-CASE
     MOVE "clear @a" TO WS-LINE
     MOVE "clear.failed.multiple(3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear items for two players" TO TL-CASE
     MOVE "give Alice loam 5" TO WS-LINE
     MOVE "commands.give.success.single(5,cobolcraft:loam,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear items for two players" TO TL-CASE
     MOVE "give Bob loam 7" TO WS-LINE
     MOVE "commands.give.success.single(7,cobolcraft:loam,Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear two players had items: the multiple m" & "essage with the count of players" TO TL-CASE
     MOVE "clear @a loam" TO WS-LINE
     MOVE "commands.clear.success.multiple(12,2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear the predicate * is any item" TO TL-CASE
     MOVE "clear Alice *" TO WS-LINE
     MOVE "clear.failed.single(Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear an item tag or conditions in the pred" & "icate are refused (BLOCKED)" TO TL-CASE
     MOVE "clear Alice #minecraft:logs" TO WS-LINE
     MOVE "cobolcraft.item.predicate_unsupported()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear a name that is not online is No playe" & "r was found" TO TL-CASE
     MOVE "clear Zed" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear maxCount below 0" TO TL-CASE
     MOVE "clear Alice loam -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear a player without operator status does" & " not know the command" TO TL-CASE
     MOVE "clear" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /clear the console prints the failure text" TO TL-CASE
     MOVE "clear Alice" TO WS-LINE
     MOVE "No items were found on player Alice" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> The count of the items of key WS-KEY-TEXT in the inventory of player WS-ROW, in WS-NUM.
 SUM-ITEM.
     MOVE 0 TO WS-NUM
     PERFORM VARYING WS-ITEM-ID FROM 1 BY 1 UNTIL WS-ITEM-ID > IT-COUNT
         IF IT-KEY(WS-ITEM-ID) = WS-KEY-TEXT
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
                 IF PL-SLOT-ITEM(WS-ROW, WS-S) = WS-ITEM-ID - 1
                     ADD PL-SLOT-COUNT(WS-ROW, WS-S) TO WS-NUM
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM.
 END PROGRAM TEST-CMD-CLEAR.

 COPY CORETEST.
 COPY CMDTEST.
