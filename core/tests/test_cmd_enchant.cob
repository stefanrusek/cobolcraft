*> Acceptance test of docs/protocol/16-commands-catalog.md §5.11 `enchant` (permission level 2) with 14a: enchant <targets> <enchantment> [<level>] adds the
*> enchantment at the level (default 1, at most the enchantment's maximum level, checked once before any target) to the main-hand item of each living target whose item
*> the enchantment supports; commands.enchant.success.single [enchantment, name] / .multiple [enchantment, count] is broadcast; a single target that is not living, holds
*> nothing or holds an unsupported item is failed.entity / .itemless / .incompatible, none changed is commands.enchant.failed; the result is the number changed. Opal holds
*> operator status. The only enchantment of the standard content is minecraft:efficiency (maximum level 5, for the item tag minecraft:enchantable/mining).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-ENCHANT.
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
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-LINE                PIC X(768).
 01 WS-TEXT                PIC X(4096).
 01 WS-DISCARD             PIC X(4096).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-EXPECTED-N          BINARY-DOUBLE.
 01 WS-NUM                 BINARY-DOUBLE.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ENCHANT-ID          BINARY-LONG VALUE 0.
 01 WS-HANDLE              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-Y                   FLOAT-LONG VALUE 70.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO-B              FLOAT-LONG VALUE 0.
 01 WS-ZERO-C              FLOAT-LONG VALUE 0.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-SX                  FLOAT-LONG VALUE 30.
 01 WS-SZ                  FLOAT-LONG VALUE 30.
 01 WS-ITEM-ROW            BINARY-LONG.
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
     MOVE "acceptance US13 /enchant a single target holding nothing: itemless" TO TL-CASE
     MOVE "enchant Cleo efficiency" TO WS-LINE
     MOVE "commands.enchant.failed.itemless(Cleo)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "give Alice pry_bar" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "give Cleo dump_shard" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /enchant a single target holding an unsupported item: incompatible" TO TL-CASE
     MOVE "enchant Cleo efficiency" TO WS-LINE
     MOVE "commands.enchant.failed.incompatible(cobolcraft:dump_shard)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant a level (3) on a supported item: Applied enchantment to Alice" TO TL-CASE
     MOVE "enchant Alice efficiency 3" TO WS-LINE
     MOVE "commands.enchant.success.single(minecraft:efficiency,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant the pry_bar holds efficiency 3" TO TL-CASE
     MOVE PL-SLOT-VAR(CN-PLAYER(WS-ID-ALICE), PL-HELD(CN-PLAYER(WS-ID-ALICE)) + 1) TO WS-HANDLE
     CALL "SP-ENCHANT-LEVEL" USING WS-HANDLE WS-ENCHANT-ID WS-LEVEL
     MOVE WS-LEVEL TO WS-NUM
     MOVE 3 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /enchant the level defaults to 1 and replaces the old level" TO TL-CASE
     MOVE "enchant Alice minecraft:efficiency" TO WS-LINE
     MOVE "commands.enchant.success.single(minecraft:efficiency,Alice)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant the pry_bar now holds efficiency 1" TO TL-CASE
     MOVE PL-SLOT-VAR(CN-PLAYER(WS-ID-ALICE), PL-HELD(CN-PLAYER(WS-ID-ALICE)) + 1) TO WS-HANDLE
     CALL "SP-ENCHANT-LEVEL" USING WS-HANDLE WS-ENCHANT-ID WS-LEVEL
     MOVE WS-LEVEL TO WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     MOVE "acceptance US13 /enchant a level above the maximum (5) is failed.level" TO TL-CASE
     MOVE "enchant Alice efficiency 6" TO WS-LINE
     MOVE "commands.enchant.failed.level(6,5)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant the result is the number of items enchanted" TO TL-CASE
     MOVE "enchant Alice efficiency 5" TO WS-LINE
     CALL "TEST-RUN-RESULT" USING WS-ID-OPAL WS-LINE WS-NUM
     MOVE 1 TO WS-EXPECTED-N
     CALL "TEST-EXPECT-NUMBER" USING TL-CASE WS-EXPECTED-N WS-NUM
     CALL "TEST-DRAIN-CHAT" USING WS-ID-OPAL WS-DISCARD
     MOVE "clear Cleo cobolcraft:dump_shard" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "give Cleo pry_bar" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "acceptance US13 /enchant two players changed: the multiple message with the count" TO TL-CASE
     MOVE "enchant @a[name=!Opal] efficiency 2" TO WS-LINE
     MOVE "commands.enchant.success.multiple(minecraft:efficiency,2)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant several targets none of which can take it: Nothing changed" TO TL-CASE
     MOVE "enchant @a efficiency" TO WS-LINE
     MOVE "commands.enchant.failed()" TO WS-EXPECTED
     MOVE 0 TO PL-SLOT-COUNT(CN-PLAYER(WS-ID-ALICE), 1)
     MOVE 0 TO PL-SLOT-COUNT(CN-PLAYER(WS-ID-CLEO), 1)
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant a mob is living but holds no item: itemless" TO TL-CASE
     MOVE "summon cobolcraft:sodgrazer 5.0 64.0 5.0" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "enchant @e[type=cobolcraft:sodgrazer,x=5,y=64,z=5,sort=nearest,limit=1] efficiency" TO WS-LINE
     MOVE "commands.enchant.failed.itemless(cobolcraft:sodgrazer)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant a ground item is not living: failed.entity" TO TL-CASE
     CALL "GI-SPAWN" USING WS-DIM WS-SX WS-Y WS-SZ WS-ZERO WS-ZERO-B WS-ZERO-C WS-STONE WS-ONE WS-DELAY WS-ITEM-ROW
     MOVE "enchant @e[type=cobolcraft:loose_item,limit=1] efficiency" TO WS-LINE
     MOVE "commands.enchant.failed.entity(cobolcraft:loose_item)" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant an unknown enchantment" TO TL-CASE
     MOVE "enchant Alice nothing" TO WS-LINE
     MOVE "argument.resource.not_found(cobolcraft:nothing,minecraft:enchantment) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant a negative level is out of range" TO TL-CASE
     MOVE "enchant Alice efficiency -1" TO WS-LINE
     MOVE "argument.integer.low(0,-1) |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant the enchantment argument completes from the registry" TO TL-CASE
     MOVE "/enchant Alice eff" TO WS-LINE
     MOVE 18 TO WS-NUM
     CALL "TEST-SUGGEST" USING WS-ID-OPAL 7 WS-LINE WS-NUM
     CALL "TEST-DRAIN-SUGGESTIONS" USING WS-ID-OPAL WS-TEXT
     MOVE "7 15 3 [minecraft:efficiency]" TO WS-EXPECTED
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant a player without operator status does not know the command" TO TL-CASE
     MOVE "enchant Alice efficiency" TO WS-LINE
     MOVE "command.unknown.command() |" TO WS-EXPECTED
     CALL "TEST-RUN" USING WS-ID-ALICE WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     MOVE "acceptance US13 /enchant the console prints the English text" TO TL-CASE
     MOVE "give Alice pry_bar" TO WS-LINE
     CALL "TEST-RUN" USING WS-ID-OPAL WS-LINE WS-TEXT
     MOVE "enchant Alice efficiency" TO WS-LINE
     MOVE "Applied enchantment minecraft:efficiency to Alice's item" TO WS-EXPECTED
     CALL "TEST-RUN-CONSOLE" USING WS-LINE WS-TEXT
     CALL "TEST-EXPECT" USING TL-CASE WS-EXPECTED WS-TEXT
     GOBACK.
 END PROGRAM TEST-CMD-ENCHANT.

 COPY CORETEST.
 COPY CMDTEST.
