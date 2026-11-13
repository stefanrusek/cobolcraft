*> Acceptance test of docs/protocol/16-commands-catalog.md §6.4 `loot` (permission level 2) with 14a: loot <target> <source> rolls a loot table (loot <table>, fish <table> <pos>
*> [<tool> | mainhand | offhand], kill <entity>, mine <pos> [<tool> | mainhand | offhand]) and delivers the stacks: give <players> (inventory, leftovers dropped), spawn <pos>
*> (item entities), replace entity <entities> <slot> [<count>] (the slots from the slot on, at most count of them); commands.drop.success.single_with_table [count, item,
*> table] or .multiple_with_table [count, table] (not broadcast) and commands.item.entity.replace.success.single / .multiple tell it; a table the source lacks is
*> commands.drop.no_loot_table.entity / .block [name] (loot and fish: argument.resource_or_id.no_such_element), a target that holds nothing commands.drop.no_held_items, a block holder
*> commands.item.target.not_a_container; the result is the number of items. The tables are core/tests/fixtures/loot-cmd. Opal holds operator status.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-LOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 COPY CITEMS.
 COPY CBLOCKS.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/loot-cmd".
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID-OPAL           BINARY-LONG.
 01 WS-ID-ALICE          BINARY-LONG.
 01 WS-ID-CLEO           BINARY-LONG.
 01 WS-A                 BINARY-LONG.
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
 01 WS-PAIRS               PIC X(64) VALUE SPACES.
 01 WS-STATE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-BX                  BINARY-LONG VALUE 20.
 01 WS-BY                  BINARY-LONG VALUE 64.
 01 WS-BZ                  BINARY-LONG VALUE 20.
 01 WS-LUCITE              BINARY-LONG.
 01 WS-ROW                 PIC X(270).
 01 WS-TOTAL               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "LOOT-LOAD" USING WS-DIR WS-STATUS
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
     MOVE "cobolcraft:lucite" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-LUCITE WS-ROW WS-STATUS
     MOVE "acceptance US13 /loot give a one-stack table: Dropped 5 lucite from the table" TO TL-CASE
     MOVE "loot give Alice loot cobolcraft:chests/one" TO WS-LINE
     MOVE "commands.drop.success.single_with_table(5,cobolcraft:lucite,cobolcraft:chests/one)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot give: Alice holds 5 lucite" TO TL-CASE
     PERFORM COUNT-LUCITE
     MOVE WS-TOTAL TO WS-NUM
     MOVE 5 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /loot give a two-stack table: Dropped 5 items from the table" TO TL-CASE
     MOVE "loot give Alice loot cobolcraft:chests/cache" TO WS-LINE
     MOVE "commands.drop.success.multiple_with_table(5,cobolcraft:chests/cache)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot give: Alice holds 8 lucite now" TO TL-CASE
     PERFORM COUNT-LUCITE
     MOVE WS-TOTAL TO WS-NUM
     MOVE 8 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /loot the result is the number of items" TO TL-CASE
     MOVE "loot give Alice loot cobolcraft:chests/cache" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 5 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "acceptance US13 /loot replace entity: the stacks go on the slots from hotbar.4" TO TL-CASE
     MOVE "loot replace entity Alice hotbar.4 loot cobolcraft:chests/cache" TO WS-LINE
     MOVE "commands.item.entity.replace.success.single(2,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot replace entity: hotbar.4 holds 3 lucite, hotbar.5 2 dump_shard" TO TL-CASE
     COMPUTE WS-NUM = PL-SLOT-ITEM(WS-A, 5) * 1000 + PL-SLOT-COUNT(WS-A, 5)
     COMPUTE WS-EXPECTED-N = WS-LUCITE * 1000 + 3
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /loot replace entity with a count of 1 sets one slot" TO TL-CASE
     MOVE "loot replace entity Alice hotbar.0 1 loot cobolcraft:chests/cache" TO WS-LINE
     MOVE "commands.item.entity.replace.success.single(1,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot replace entity of several players: the multiple message" TO TL-CASE
     MOVE "loot replace entity @a hotbar.8 loot cobolcraft:chests/one" TO WS-LINE
     MOVE "commands.item.entity.replace.success.multiple(3)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot replace entity of a slot the player does not own: holds nothing" TO TL-CASE
     MOVE "loot replace entity Alice armor.head loot cobolcraft:chests/one" TO WS-LINE
     MOVE "commands.drop.no_held_items()" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot replace entity of a mob: it holds nothing" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "loot replace entity @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] hotbar.0 loot cobolcraft:chests/one" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot spawn drops item entities: Dropped 5 items from the table" TO TL-CASE
     MOVE "loot spawn 10 70 10 loot cobolcraft:chests/cache" TO WS-LINE
     MOVE "commands.drop.success.multiple_with_table(5,cobolcraft:chests/cache)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot kill rolls the entity table: Dropped 2 grazer_flank" TO TL-CASE
     MOVE "loot give Alice kill @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1]" TO WS-LINE
     MOVE "commands.drop.success.single_with_table(2,cobolcraft:grazer_flank,cobolcraft:entities/sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot kill of a player: the entity has no loot table" TO TL-CASE
     MOVE "loot give Alice kill Cleo" TO WS-LINE
     MOVE "commands.drop.no_loot_table.entity(Cleo)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "cobolcraft:turf" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "acceptance US13 /loot mine rolls the table of the block: Dropped 4 loam" TO TL-CASE
     MOVE "loot give Alice mine 20 64 20" TO WS-LINE
     MOVE "commands.drop.success.single_with_table(4,cobolcraft:loam,cobolcraft:blocks/turf)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot mine with a tool item" TO TL-CASE
     MOVE "loot give Alice mine 20 64 20 lucite" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot mine with mainhand" TO TL-CASE
     MOVE "loot give Alice mine 20 64 20 mainhand" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot mine with offhand" TO TL-CASE
     MOVE "loot give Alice mine 20 64 20 offhand" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot mine of air: the block has no loot table" TO TL-CASE
     MOVE "loot give Alice mine 20 90 20" TO WS-LINE
     MOVE "commands.drop.no_loot_table.block(cobolcraft:void)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot fish rolls the table at the position" TO TL-CASE
     MOVE "loot give Alice fish cobolcraft:chests/one 0 64 0" TO WS-LINE
     MOVE "commands.drop.success.single_with_table(5,cobolcraft:lucite,cobolcraft:chests/one)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot fish with a tool item" TO TL-CASE
     MOVE "loot give Alice fish cobolcraft:chests/one 0 64 0 lucite" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot fish with mainhand" TO TL-CASE
     MOVE "loot give Alice fish cobolcraft:chests/one 0 64 0 mainhand" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot fish with offhand" TO TL-CASE
     MOVE "loot give Alice fish cobolcraft:chests/one 0 64 0 offhand" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot an unknown table" TO TL-CASE
     MOVE "loot give Alice loot cobolcraft:chests/nothing" TO WS-LINE
     MOVE "argument.resource_or_id.no_such_element(cobolcraft:chests/nothing,minecraft:loot_table)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot insert is not a container" TO TL-CASE
     MOVE "loot insert 1 64 -2 loot cobolcraft:chests/one" TO WS-LINE
     MOVE "commands.item.target.not_a_container(1,64,-2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot replace block is not a container" TO TL-CASE
     MOVE "loot replace block 3 4 5 container.0 2 loot cobolcraft:chests/one" TO WS-LINE
     MOVE "commands.item.target.not_a_container(3,4,5)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot replace block without a count" TO TL-CASE
     MOVE "loot replace block 3 4 5 container.0 loot cobolcraft:chests/one" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot give to a full inventory drops the stacks at the player" TO TL-CASE
     MOVE "item fill entity Alice container.* with greystone 64" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "loot give Alice loot cobolcraft:chests/one" TO WS-LINE
     MOVE "commands.drop.success.single_with_table(5,cobolcraft:lucite,cobolcraft:chests/one)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM(WS-I) = WS-LUCITE AND EN-ITEM-COUNT(WS-I) = 5
             ADD 1 TO WS-TOTAL
         END-IF
     END-PERFORM
     MOVE "acceptance US13 /loot the 5 lucite that did not fit lie on the ground as an item entity" TO TL-CASE
     MOVE WS-TOTAL TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /loot the targets complete" TO TL-CASE
     MOVE "/loot " TO WS-LINE
     MOVE 6 TO WS-NUM
     CALL "TEST-SUGGEST" USING WS-ID-OPAL 9 WS-LINE WS-NUM
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "9 6 0 [give,insert,replace,spawn]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot a player without operator status does not know the command" TO TL-CASE
     MOVE "loot give Alice loot cobolcraft:chests/one" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /loot the console prints the English text" TO TL-CASE
     MOVE "loot give Alice loot cobolcraft:chests/cache" TO WS-LINE
     MOVE "Dropped 5 items from loot table cobolcraft:chests/cache" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.

*> WS-TOTAL: the lucite in Alice's slots.
 COUNT-LUCITE.
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-ITEM(WS-A, WS-I) = WS-LUCITE
             ADD PL-SLOT-COUNT(WS-A, WS-I) TO WS-TOTAL
         END-IF
     END-PERFORM.
 END PROGRAM TEST-CMD-LOOT.

 COPY CORETEST.
 COPY CMDTEST.
