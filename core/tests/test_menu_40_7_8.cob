*> Test of 40-7§8 section, The search tab (T1085): refresh decision, visible tags, tree matching, result order and tooltip planning (core/src/menu-40-7.cob).
*> A case loads its inputs from a text of numbers (LOAD-IN fills WS-I as integers and WS-FX as doubles), calls the program
*> and shows the outputs WS-R(1..WS-N) joined by "/", one group per call; expected values come from the rules and tables of the section.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MENU-40-7-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY INTERACT.
 01 WS-ISG.
    05 WS-I1 BINARY-LONG.
    05 WS-I2 BINARY-LONG.
    05 WS-I3 BINARY-LONG.
    05 WS-I4 BINARY-LONG.
    05 WS-I5 BINARY-LONG.
    05 WS-I6 BINARY-LONG.
    05 WS-I7 BINARY-LONG.
    05 WS-I8 BINARY-LONG.
    05 WS-I9 BINARY-LONG.
    05 WS-I10 BINARY-LONG.
    05 WS-I11 BINARY-LONG.
    05 WS-I12 BINARY-LONG.
    05 WS-I13 BINARY-LONG.
    05 WS-I14 BINARY-LONG.
    05 WS-I15 BINARY-LONG.
    05 WS-I16 BINARY-LONG.
 01 WS-IST REDEFINES WS-ISG.
    05 WS-I BINARY-LONG OCCURS 16 TIMES.
 01 WS-FXSG.
    05 WS-FX1 FLOAT-LONG.
    05 WS-FX2 FLOAT-LONG.
    05 WS-FX3 FLOAT-LONG.
    05 WS-FX4 FLOAT-LONG.
    05 WS-FX5 FLOAT-LONG.
    05 WS-FX6 FLOAT-LONG.
    05 WS-FX7 FLOAT-LONG.
    05 WS-FX8 FLOAT-LONG.
    05 WS-FX9 FLOAT-LONG.
    05 WS-FX10 FLOAT-LONG.
    05 WS-FX11 FLOAT-LONG.
    05 WS-FX12 FLOAT-LONG.
    05 WS-FX13 FLOAT-LONG.
    05 WS-FX14 FLOAT-LONG.
    05 WS-FX15 FLOAT-LONG.
    05 WS-FX16 FLOAT-LONG.
 01 WS-FXST REDEFINES WS-FXSG.
    05 WS-FX FLOAT-LONG OCCURS 16 TIMES.
 01 WS-RSG.
    05 WS-R1 BINARY-LONG.
    05 WS-R2 BINARY-LONG.
    05 WS-R3 BINARY-LONG.
    05 WS-R4 BINARY-LONG.
    05 WS-R5 BINARY-LONG.
    05 WS-R6 BINARY-LONG.
    05 WS-R7 BINARY-LONG.
    05 WS-R8 BINARY-LONG.
    05 WS-R9 BINARY-LONG.
    05 WS-R10 BINARY-LONG.
    05 WS-R11 BINARY-LONG.
    05 WS-R12 BINARY-LONG.
    05 WS-R13 BINARY-LONG.
    05 WS-R14 BINARY-LONG.
    05 WS-R15 BINARY-LONG.
    05 WS-R16 BINARY-LONG.
 01 WS-RST REDEFINES WS-RSG.
    05 WS-R BINARY-LONG OCCURS 16 TIMES.
 01 WS-RFSG.
    05 WS-RF1 FLOAT-LONG.
    05 WS-RF2 FLOAT-LONG.
    05 WS-RF3 FLOAT-LONG.
    05 WS-RF4 FLOAT-LONG.
    05 WS-RF5 FLOAT-LONG.
    05 WS-RF6 FLOAT-LONG.
    05 WS-RF7 FLOAT-LONG.
    05 WS-RF8 FLOAT-LONG.
 01 WS-RFST REDEFINES WS-RFSG.
    05 WS-RF FLOAT-LONG OCCURS 8 TIMES.
 01 WS-IN                  PIC X(160).
 01 WS-TOK                 PIC X(24).
 01 WS-P                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-SHOW                PIC -(10)9.
 01 WS-TEXTS.
    05 WS-T1               PIC X(96).
    05 WS-T2               PIC X(96).
 01 WS-NM                PIC X(32).
 01 WS-T3                 PIC X(96).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 40-7§8 The search tab: 8.1 refreshSearchResults: an empty query shows the whole sear" &
         "ch list; without a connection the list stays empty; a leading # uses the tag tree (3), else" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-SREFRESH" USING WS-I1 WS-I2 WS-I3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-SREFRESH" USING WS-I1 WS-I2 WS-I3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-SREFRESH" USING WS-I1 WS-I2 WS-I3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-SREFRESH" USING WS-I1 WS-I2 WS-I3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-SREFRESH" USING WS-I1 WS-I2 WS-I3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 0 2 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§8 The search tab: 8.1 updateVisibleTags: without a colon the tag path contains " &
         "the text; with a colon the first colon splits into namespace and path parts, each trimmed," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "log" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "log" TO WS-T1
     MOVE "minecraft:logs_that_burn" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "plank" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:logs" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "mine:log" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "mine : log" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "x:log" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE ":log" TO WS-T1
     MOVE "c:logs" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "LOG" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "c:" TO WS-T1
     MOVE "a:b" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "x" TO WS-T1
     MOVE "a:" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "longer" TO WS-T1
     MOVE "a:ab" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "logs" TO WS-T1
     MOVE "my:mylogs_two" TO WS-T2
     CALL "MN7-VISTAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 0 1 1 1 0 1 1 0 0 0 0 1 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§8 The search tab: 8.2, 12 lower-casing: ASCII letters only change, in the root " &
         "locale (a capital I becomes i, never a dotless i)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "Iron Ingot" TO WS-T1
     MOVE SPACES TO WS-T2
     CALL "MN7-S-LOWER" USING WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "OAK" TO WS-T1
     MOVE SPACES TO WS-T2
     CALL "MN7-S-LOWER" USING WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "abc" TO WS-T1
     MOVE SPACES TO WS-T2
     CALL "MN7-S-LOWER" USING WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "mIxEd 123 I" TO WS-T1
     MOVE SPACES TO WS-T2
     CALL "MN7-S-LOWER" USING WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "I" TO WS-T1
     MOVE SPACES TO WS-T2
     CALL "MN7-S-LOWER" USING WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE "Iron Ingot|iron ingot OAK|oak abc|abc mIxEd 123 I|mixed 123 i I|i" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§8 The search tab: 8.2 indexed text per tooltip line: formatting codes (the sect" &
         "ion sign and the character after it) stripped, trimmed, lower-cased (line -> indexed text)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "§6Iron Ingot" TO WS-T1
     MOVE SPACES TO WS-T2
     CALL "MN7-S-LINE" USING WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "  §lBold§r Text " TO WS-T1
     MOVE SPACES TO WS-T2
     CALL "MN7-S-LINE" USING WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "plain" TO WS-T1
     MOVE SPACES TO WS-T2
     CALL "MN7-S-LINE" USING WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "§aGreen §eYellow" TO WS-T1
     MOVE SPACES TO WS-T2
     CALL "MN7-S-LINE" USING WS-T1 WS-T2
     PERFORM ADD-TEXT
     MOVE "§6Iron Ingot|iron ingot §lBold§r Text|bold text plain|plain §aGreen §eYellow|green yellow" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§8 The search tab: 8.2 an indexed line that is empty after stripping and trimmin" &
         "g is dropped (line -> dropped)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "§7" TO WS-T1
     CALL "MN7-S-DROP" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE " " TO WS-T1
     CALL "MN7-S-DROP" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "§a  " TO WS-T1
     CALL "MN7-S-DROP" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "x" TO WS-T1
     CALL "MN7-S-DROP" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "§ax" TO WS-T1
     CALL "MN7-S-DROP" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "  y " TO WS-T1
     CALL "MN7-S-DROP" USING WS-T1 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 1 0 0 0 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§8 The search tab: 8.2 name search of one stack: without a colon the lower-cased" &
         " query is a substring of the indexed text or the item path; with a colon the namespace part" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "iron" TO WS-T1
     MOVE "minecraft:iron_ingot" TO WS-T2
     MOVE "iron ingot" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "oak" TO WS-T1
     MOVE "minecraft:oak_log" TO WS-T2
     MOVE "oak log" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "oak" TO WS-T1
     MOVE "minecraft:oak_planks" TO WS-T2
     MOVE "oak planks" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "iron" TO WS-T1
     MOVE "minecraft:stick" TO WS-T2
     MOVE "stick" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lea" TO WS-T1
     MOVE "minecraft:leather" TO WS-T2
     MOVE "leather" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lea" TO WS-T1
     MOVE "minecraft:stick" TO WS-T2
     MOVE "a leaf item" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lea" TO WS-T1
     MOVE "mod:leather" TO WS-T2
     MOVE "leather" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:lea" TO WS-T1
     MOVE "minecraft:stick" TO WS-T2
     MOVE "stick" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "mine:lea" TO WS-T1
     MOVE "minecraft:leather_boots" TO WS-T2
     MOVE "leather boots" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "IRON" TO WS-T1
     MOVE "minecraft:iron_ingot" TO WS-T2
     MOVE "iron ingot" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "log" TO WS-T1
     MOVE "minecraft:oak_log" TO WS-T2
     MOVE "oak wood" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "x" TO WS-T1
     MOVE "minecraft:stick" TO WS-T2
     MOVE "stick" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "stick" TO WS-T1
     MOVE "minecraft:iron_ingot" TO WS-T2
     MOVE "long stick of iron" TO WS-T3
     CALL "MN7-S-NAME" USING WS-T1 WS-T2 WS-T3 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 1 0 1 1 0 0 1 1 1 0 1 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§8 The search tab: 8.2 tag search of one stack: without a colon the text is a su" &
         "bstring of a tag path; with a colon some tag namespace contains the first part and some tag" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "logs" TO WS-T1
     MOVE "minecraft:logs,minecraft:logs_that_burn" TO WS-T2
     CALL "MN7-S-TAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "burn" TO WS-T1
     MOVE "minecraft:logs,minecraft:logs_that_burn" TO WS-T2
     CALL "MN7-S-TAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:logs" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-S-TAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "c:logs" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-S-TAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ingots" TO WS-T1
     MOVE "a:ingots,minecraft:x" TO WS-T2
     CALL "MN7-S-TAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ingots" TO WS-T1
     MOVE "a:ingots" TO WS-T2
     CALL "MN7-S-TAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "minecraft:ingots" TO WS-T1
     MOVE "minecraft:other" TO WS-T2
     CALL "MN7-S-TAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "zzz" TO WS-T1
     MOVE "minecraft:logs" TO WS-T2
     CALL "MN7-S-TAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "x" TO WS-T1
     MOVE "a:x,b:y" TO WS-T2
     CALL "MN7-S-TAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "0" TO WS-IN
     PERFORM LOAD-IN
     MOVE "b:y" TO WS-T1
     MOVE "a:x,b:y" TO WS-T2
     CALL "MN7-S-TAG" USING WS-T1 WS-T2 WS-R1
     MOVE 1 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 1 1 1 0 0 0 1 1 " TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§8 The search tab: 8.2 result order: the matching entries in the order they were" &
         " added, a stack matched through several lines once at its first position (eight (stack id," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "1 1 2 1 3 1 4 1 5 1 6 1 7 1 8 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-S-RESULTS" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-I5 WS-I6 WS-I7 WS-I8 WS-I9 WS-I10 WS-I11 WS-I12 WS-I13 WS-I14 WS-I15 WS-I16 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5 WS-R6 WS-R7 WS-R8 WS-R9
     MOVE 9 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 2 1 3 0 4 1 5 0 6 0 7 0 8 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-S-RESULTS" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-I5 WS-I6 WS-I7 WS-I8 WS-I9 WS-I10 WS-I11 WS-I12 WS-I13 WS-I14 WS-I15 WS-I16 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5 WS-R6 WS-R7 WS-R8 WS-R9
     MOVE 9 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 1 1 2 1 2 0 3 1 1 1 4 0 5 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-S-RESULTS" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-I5 WS-I6 WS-I7 WS-I8 WS-I9 WS-I10 WS-I11 WS-I12 WS-I13 WS-I14 WS-I15 WS-I16 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5 WS-R6 WS-R7 WS-R8 WS-R9
     MOVE 9 TO WS-N
     PERFORM ADD-N
     MOVE "3 1 3 1 3 1 3 1 3 1 3 1 3 1 3 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-S-RESULTS" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-I5 WS-I6 WS-I7 WS-I8 WS-I9 WS-I10 WS-I11 WS-I12 WS-I13 WS-I14 WS-I15 WS-I16 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5 WS-R6 WS-R7 WS-R8 WS-R9
     MOVE 9 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-S-RESULTS" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-I5 WS-I6 WS-I7 WS-I8 WS-I9 WS-I10 WS-I11 WS-I12 WS-I13 WS-I14 WS-I15 WS-I16 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5 WS-R6 WS-R7 WS-R8 WS-R9
     MOVE 9 TO WS-N
     PERFORM ADD-N
     MOVE "5 0 5 1 2 1 5 1 2 0 7 1 7 1 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-S-RESULTS" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-I5 WS-I6 WS-I7 WS-I8 WS-I9 WS-I10 WS-I11 WS-I12 WS-I13 WS-I14 WS-I15 WS-I16 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5 WS-R6 WS-R7 WS-R8 WS-R9
     MOVE 9 TO WS-N
     PERFORM ADD-N
     MOVE "8/1/2/3/4/5/6/7/8 2/2/4/0/0/0/0/0/0 4/1/2/3/5/0/0/0/0 1/3/0/0/0/0/0/0/0 0/0/0/0/0/0/0/0/0 3/5/2/7/0/" &
         "0/0/0/0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§8 The search tab: 8.3 tooltip plan: the advanced flags with the option, the cre" &
         "ative variant on a grid slot; an empty line list is returned; a CATEGORY tab grid slot returns" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0 1 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPPLAN" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "1 1 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPPLAN" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "0 1 4 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPPLAN" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 4 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPPLAN" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "0 0 1 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPPLAN" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "0 1 3 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPPLAN" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "0 1 1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPPLAN" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "1 0 3 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPPLAN" USING WS-I1 WS-I2 WS-I3 WS-I4 WS-R1 WS-R2 WS-R3 WS-R4 WS-R5
     MOVE 5 TO WS-N
     PERFORM ADD-N
     MOVE "0/1/1/0/0 1/1/1/0/0 0/1/0/1/1 0/0/0/0/1 0/0/0/0/1 0/1/0/0/1 0/0/0/0/0 1/0/0/0/1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 40-7§8 The search tab: 8.3 insert positions: tag lines go in at index 1 first, then " &
         "each tab title at index 1, 2, ..., so the tab names come before the tag lines (tags, tabs ->" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "0 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPORDER" USING WS-I1 WS-I2 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "2 0" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPORDER" USING WS-I1 WS-I2 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "0 2" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPORDER" USING WS-I1 WS-I2 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "2 3" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPORDER" USING WS-I1 WS-I2 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "1 1" TO WS-IN
     PERFORM LOAD-IN
     CALL "MN7-TIPORDER" USING WS-I1 WS-I2 WS-R1 WS-R2
     MOVE 2 TO WS-N
     PERFORM ADD-N
     MOVE "1/1 1/1 1/3 1/4 1/2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 LOAD-IN.
     MOVE 1 TO WS-P
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
         MOVE SPACES TO WS-TOK
         IF WS-P <= 160
             UNSTRING WS-IN DELIMITED BY ALL SPACE INTO WS-TOK WITH POINTER WS-P
         END-IF
         COMPUTE WS-FX(WS-K) = FUNCTION NUMVAL(WS-TOK)
         COMPUTE WS-I(WS-K) = FUNCTION NUMVAL(WS-TOK)
     END-PERFORM
     .

 ADD-N.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
         MOVE WS-R(WS-J) TO WS-SHOW
         IF WS-J > 1
             STRING "/" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-SHOW) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     END-PERFORM
     STRING " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

 ADD-TEXT.
     STRING FUNCTION TRIM(WS-T1) "|" FUNCTION TRIM(WS-T2) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .
 END PROGRAM TEST-MENU-40-7-8.
