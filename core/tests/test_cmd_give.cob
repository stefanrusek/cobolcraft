*> Acceptance test of docs/protocol/16-commands-catalog.md §6.1 `give` (permission level 2) with 14a: the count (1 by default, at most 100 stacks) of the
*> item goes into each target's inventory in stacks of at most the maximum stack size (what does not fit is dropped at the player as
*> ground items with no pickup delay) and the player is sent the inventory; commands.give.success.single [count, item, player]
*> or .multiple [count, item, number of players] (broadcast; the item is shown by its key); more than 100 stacks is
*> commands.give.failed.toomanyitems [maximum, item]; the result is the number of items given in total. Item components are
*> BLOCKED (refused: cobolcraft.item.components_unsupported). Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-GIVE.
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
 01 WS-IDS                 PIC X(1024).
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
     MOVE "acceptance US13 /give an operator gives Alice a pry_bar (cou" & "nt 1): Gave 1 item to Alice" TO TL-CASE
     MOVE "give Alice pry_bar" TO WS-LINE
     MOVE "commands.give.success.single(1,cobolcraft:pry_bar,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give Alice holds the pry_bar" TO TL-CASE
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-ROW
     MOVE "cobolcraft:pry_bar" TO WS-KEY-TEXT
     PERFORM SUM-ITEM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /give Alice is sent her inventory (18)" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ID-ALICE WS-IDS
     MOVE WS-IDS TO WS-TEXT
     MOVE "18" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give 100 greystone" TO TL-CASE
     MOVE "give Alice greystone 100" TO WS-LINE
     MOVE "commands.give.success.single(100,cobolcraft:greystone,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give Alice holds 100 greystone (64 and 36)" TO TL-CASE
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-ROW
     MOVE "cobolcraft:greystone" TO WS-KEY-TEXT
     PERFORM SUM-ITEM
     MOVE 100 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /give more than fits is still given: what do" & "es not fit is dropped" TO TL-CASE
     MOVE "give Alice loam 2304" TO WS-LINE
     MOVE "commands.give.success.single(2304,cobolcraft:loam,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give Alice holds 2112 loam: 33 empty slots " & "of 64" TO TL-CASE
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-ROW
     MOVE "cobolcraft:loam" TO WS-KEY-TEXT
     PERFORM SUM-ITEM
     MOVE 2112 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /give more than 100 stacks: Can't give more " & "than 6400 of the item" TO TL-CASE
     MOVE "give Bob loam 6401" TO WS-LINE
     MOVE "commands.give.failed.toomanyitems(6400,cobolcraft:loam)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give Bob holds none" TO TL-CASE
     MOVE CN-PLAYER(WS-ID-BOB) TO WS-ROW
     MOVE "cobolcraft:loam" TO WS-KEY-TEXT
     PERFORM SUM-ITEM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /give the result is the total given: 2 each " & "to three players" TO TL-CASE
     MOVE "give @a pry_bar 2" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 6 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /give a selector with one match is the singl" & "e message" TO TL-CASE
     MOVE "give @a[name=Bob] pry_bar" TO WS-LINE
     MOVE "commands.give.success.single(1,cobolcraft:pry_bar,Bob)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give several players: the multiple message " & "with the number of players" TO TL-CASE
     MOVE "give @a loam" TO WS-LINE
     MOVE "commands.give.success.multiple(1,cobolcraft:loam,3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give an unknown item is a parse error" TO TL-CASE
     MOVE "give Alice nothing" TO WS-LINE
     MOVE "argument.item.id.invalid(cobolcraft:nothing) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give a count below 1 is below the minimum" TO TL-CASE
     MOVE "give Alice pry_bar 0" TO WS-LINE
     MOVE "argument.integer.low(1,0) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give item components are refused (BLOCKED)" TO TL-CASE
     MOVE "give Alice pry_bar[damage=1]" TO WS-LINE
     MOVE "cobolcraft.item.components_unsupported()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give a name that is not online is No player" & " was found" TO TL-CASE
     MOVE "give Zed pry_bar" TO WS-LINE
     MOVE "argument.entity.notfound.player()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give a player without operator status does " & "not know the command" TO TL-CASE
     MOVE "give Bob loam" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /give the console prints the English text" TO TL-CASE
     MOVE "give Bob pry_bar" TO WS-LINE
     MOVE "Gave 1 cobolcraft:pry_bar to Bob" TO WS-EXPECTED
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
 END PROGRAM TEST-CMD-GIVE.

 COPY CORETEST.
 COPY CMDTEST.
