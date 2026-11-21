*> Acceptance test of docs/protocol/16-commands-catalog.md §6.3 `item` (permission level 2) with 14a: item replace|fill|override entity <targets> <slots> with <item> [<count>] |
*> from entity <sourceEntities> <sourceSlots> sets the slots of the players (the slots a player owns here: 0 to 35 = hotbar, inventory and container, and weapon.mainhand = the
*> held hotbar slot): replace lays the supplied stacks on the first slots, fill repeats them over all the slots, override also empties the slots after them;
*> commands.item.entity.replace.success.single[.known_item] [slots, name (, item)] and .multiple[.known_item] [entities (, item)] are broadcast; a target with none of the slots
*> is commands.item.target.no_such_slot [slot] (.unnamed for a range), a source without the slot commands.item.source.no_such_slot, a block holder (no live container block
*> exists) commands.item.target.not_a_container / .source.not_a_container [x, y, z], a modifier cobolcraft.item.modifier_unsupported. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-ITEM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
 01 WS-A                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-GREY                BINARY-LONG.
 01 WS-LUCITE              BINARY-LONG.
 01 WS-SHARD               BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Opal" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN-OP" USING WS-NAME WS-NAME-LENGTH WS-ID-OPAL
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-ALICE
     MOVE "Cleo" TO WS-NAME
     MOVE 4 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ID-CLEO
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-ALICE WS-DISCARD
     CALL "TEST-DRAIN-CHAT" USING WS-ID-CLEO WS-DISCARD
     MOVE CN-PLAYER(WS-ID-ALICE) TO WS-A
     MOVE CN-PLAYER(WS-ID-CLEO) TO WS-C
     MOVE "cobolcraft:greystone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-GREY WS-ROW WS-STATUS
     MOVE "cobolcraft:lucite" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-LUCITE WS-ROW WS-STATUS
     MOVE "cobolcraft:dump_shard" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SHARD WS-ROW WS-STATUS
     MOVE "acceptance US13 /item replace one slot with a count: Replaced 1 slot(s) on Alice with the item" TO TL-CASE
     MOVE "item replace entity Alice hotbar.0 with greystone 5" TO WS-LINE
     MOVE "commands.item.entity.replace.success.single.known_item(1,Alice,cobolcraft:greystone)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item replace hotbar.0 now holds 5 greystone" TO TL-CASE
     PERFORM CHECK-SLOT-1-GREY-5
     MOVE "acceptance US13 /item replace without a count gives 1; inventory.5 is slot 14" TO TL-CASE
     MOVE "item replace entity Alice inventory.5 with lucite" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     COMPUTE WS-NUM = PL-SLOT-ITEM(WS-A, 15) * 1000 + PL-SLOT-COUNT(WS-A, 15)
     COMPUTE WS-EXPECTED-N = WS-LUCITE * 1000 + 1
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /item replace weapon.mainhand sets the held hotbar slot" TO TL-CASE
     MOVE 3 TO PL-HELD(WS-A)
     MOVE "item replace entity Alice weapon.mainhand with dump_shard 2" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     COMPUTE WS-NUM = PL-SLOT-ITEM(WS-A, 4) * 1000 + PL-SLOT-COUNT(WS-A, 4)
     COMPUTE WS-EXPECTED-N = WS-SHARD * 1000 + 2
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /item replace of a range lays the one stack on the first slot only" TO TL-CASE
     MOVE "item replace entity Cleo hotbar.* with greystone 3" TO WS-LINE
     MOVE "commands.item.entity.replace.success.single.known_item(1,Cleo,cobolcraft:greystone)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item fill repeats the stack over the 9 hotbar slots" TO TL-CASE
     MOVE "item fill entity Cleo hotbar.* with lucite 2" TO WS-LINE
     MOVE "commands.item.entity.replace.success.single.known_item(9,Cleo,cobolcraft:lucite)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item fill: the last hotbar slot holds 2 lucite" TO TL-CASE
     COMPUTE WS-NUM = PL-SLOT-ITEM(WS-C, 9) * 1000 + PL-SLOT-COUNT(WS-C, 9)
     COMPUTE WS-EXPECTED-N = WS-LUCITE * 1000 + 2
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /item override empties the slots after the supplied stack" TO TL-CASE
     MOVE "item override entity Cleo hotbar.* with greystone" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     COMPUTE WS-NUM = PL-SLOT-COUNT(WS-C, 1) * 1000 + PL-SLOT-COUNT(WS-C, 2) + PL-SLOT-COUNT(WS-C, 9)
     MOVE 1000 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /item replace from a source entity takes the first stack for the one slot" TO TL-CASE
     MOVE "item replace entity Cleo hotbar.5 from entity Alice hotbar.* " TO WS-LINE
     MOVE "commands.item.entity.replace.success.single(1,Cleo)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item replace from: Cleo's hotbar.5 now holds Alice's 5 greystone" TO TL-CASE
     COMPUTE WS-NUM = PL-SLOT-ITEM(WS-C, 6) * 1000 + PL-SLOT-COUNT(WS-C, 6)
     COMPUTE WS-EXPECTED-N = WS-GREY * 1000 + 5
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /item replace: a slot of the source is empty, the target takes it as empty" TO TL-CASE
     MOVE "item replace entity Cleo hotbar.0 from entity Alice hotbar.7" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE PL-SLOT-COUNT(WS-C, 1) TO WS-NUM
     MOVE 0 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /item several players: the multiple message with the count" TO TL-CASE
     MOVE "item replace entity @a hotbar.1 with lucite" TO WS-LINE
     MOVE "commands.item.entity.replace.success.multiple.known_item(3,cobolcraft:lucite)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item several players with from: the multiple message without an item" TO TL-CASE
     MOVE "item replace entity @a hotbar.2 from entity Alice hotbar.1" TO WS-LINE
     MOVE "commands.item.entity.replace.success.multiple(3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item the result is the number of slots set" TO TL-CASE
     MOVE "item fill entity Alice hotbar.* with lucite" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 9 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /item a mob has no slots: the target does not have slot hotbar.0" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "item replace entity @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] hotbar.0 with lucite" TO WS-LINE
     MOVE "commands.item.target.no_such_slot(hotbar.0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item a player without the slot: armor.head" TO TL-CASE
     MOVE "item replace entity Alice armor.head with lucite" TO WS-LINE
     MOVE "commands.item.target.no_such_slot(armor.head)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item no slot of a range: the unnamed message" TO TL-CASE
     MOVE "item replace entity Alice armor.* with lucite" TO WS-LINE
     MOVE "commands.item.target.no_such_slot.unnamed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item a source without the slot" TO TL-CASE
     MOVE "item replace entity Cleo hotbar.0 from entity Alice armor.head" TO WS-LINE
     MOVE "commands.item.source.no_such_slot(armor.head)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item a source range without slots: the unnamed message" TO TL-CASE
     MOVE "item replace entity Cleo hotbar.0 from entity Alice armor.*" TO WS-LINE
     MOVE "commands.item.source.no_such_slot.unnamed()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item a mob as the source has no slots" TO TL-CASE
     MOVE "item replace entity Alice hotbar.0 from entity @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] hotbar.0" TO WS-LINE
     MOVE "commands.item.source.no_such_slot(hotbar.0)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item a block target is not a container" TO TL-CASE
     MOVE "item replace block 1 64 -2 container.0 with lucite" TO WS-LINE
     MOVE "commands.item.target.not_a_container(1,64,-2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item a block source is not a container" TO TL-CASE
     MOVE "item replace entity Alice hotbar.0 from block 3 4 5 container.0" TO WS-LINE
     MOVE "commands.item.source.not_a_container(3,4,5)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item modify needs an item modifier: not supported yet" TO TL-CASE
     MOVE "item modify entity Alice hotbar.0 cobolcraft:anything" TO WS-LINE
     MOVE "cobolcraft.item.modifier_unsupported()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item modify of a block parses too" TO TL-CASE
     MOVE "item modify block 0 0 0 container.0 cobolcraft:anything" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item replace from with a modifier" TO TL-CASE
     MOVE "item replace entity Alice hotbar.0 from entity Cleo hotbar.0 cobolcraft:anything" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item replace from a block with a modifier" TO TL-CASE
     MOVE "item replace block 1 2 3 container.0 from block 4 5 6 container.0 cobolcraft:anything" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item an item with components is not supported yet" TO TL-CASE
     MOVE "item replace entity Alice hotbar.0 with lucite[minecraft:damage=1]" TO WS-LINE
     MOVE "cobolcraft.item.components_unsupported()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item a count above 99 is out of range" TO TL-CASE
     MOVE "item replace entity Alice hotbar.0 with lucite 100" TO WS-LINE
     MOVE "argument.integer.big(99,100) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item a count under 1 is out of range" TO TL-CASE
     MOVE "item replace entity Alice hotbar.0 with lucite 0" TO WS-LINE
     MOVE "argument.integer.low(1,0) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item the verbs complete" TO TL-CASE
     MOVE "/item " TO WS-LINE
     MOVE 6 TO WS-NUM
     CALL "TEST-SUGGEST" USING WS-ID-OPAL 5 WS-LINE WS-NUM
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "5 6 0 [fill,modify,override,replace]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item a player without operator status does not know the command" TO TL-CASE
     MOVE "item replace entity Alice hotbar.0 with lucite" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /item the console prints the English text" TO TL-CASE
     MOVE "item replace entity Alice hotbar.0 with lucite" TO WS-LINE
     MOVE "Replaced 1 slot(s) on Alice with cobolcraft:lucite" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> WS-NUM compared: Alice's hotbar.0 holds 5 greystone.
 CHECK-SLOT-1-GREY-5.
     COMPUTE WS-NUM = PL-SLOT-ITEM(WS-A, 1) * 1000 + PL-SLOT-COUNT(WS-A, 1)
     COMPUTE WS-EXPECTED-N = WS-GREY * 1000 + 5
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM.
 END PROGRAM TEST-CMD-ITEM.

 COPY CORETEST.
 COPY CMDTEST.
