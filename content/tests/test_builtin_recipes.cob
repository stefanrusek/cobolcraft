*> Test of the built-in recipes (T0214; docs/design/cobolcraft-standard-core.md section 5.7 and decision CORE-23,
*> docs/protocol/27-recipes-and-unlocks.md sections 1 and 2.2): BUILTIN-RECIPES-LOAD (no parameters) fills RC-STORE
*> with the cobolcraft recipes as rows of the same shape RECIPES-LOAD gives a data file: the nine stand-in recipes
*> (display ids 0 to 8, in the order of core 5.7), each a crafting_shapeless row (serializer 1) with its category,
*> its result and one ingredient slot per unit, every item a cobolcraft: item, no group, show_notification false
*> and no unlock condition (core 5.7: a player knows all recipes from joining). The bench recipe (display id 9) is covered by
*> test_builtin_bench. RECIPE-FIND finds a row by key; RECIPES-FREE empties the store.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BUILTIN-RECIPES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTRECIPE.
*> Key, category, result and its count, then the ingredients (names without "cobolcraft:", one per slot, "," between).
 01 WS-RECIPES.
    05 FILLER PIC X(120) VALUE "ledger_tile |building |ledger_tile |2|greystone,greystone,greystone,greystone".
    05 FILLER PIC X(120) VALUE "lucite      |building |lucite      |2|grit,grit,grit,grit".
    05 FILLER PIC X(120) VALUE "pry_bar     |equipment|pry_bar     |1|greystone,greystone,greystone,cardstack".
    05 FILLER PIC X(120) VALUE "trowel      |equipment|trowel      |1|greystone,greystone,cardstack".
    05 FILLER PIC X(120) VALUE "glowtube    |building |glowtube    |2|lucite,dump_shard".
    05 FILLER PIC X(120) VALUE "sod_cake    |misc     |sod_cake    |1|turf,turf,turf,turf,loam".
    05 FILLER PIC X(120) VALUE "seared_flank|misc     |seared_flank|2|grazer_flank,grazer_flank,glowtube".
    05 FILLER PIC X(120) VALUE "goto_pad    |misc     |goto_pad    |1|ledger_tile,ledger_tile,ledger_tile,ledger_tile,dump_shard,dump_shard,glowtube".
    05 FILLER PIC X(120) VALUE "dump_shard  |misc     |dump_shard  |1|cardstack,cardstack,lucite,lucite".
 01 WS-TABLE REDEFINES WS-RECIPES.
    05 WS-R OCCURS 9 TIMES.
       10 WS-R-KEY         PIC X(12).
       10 FILLER           PIC X.
       10 WS-R-CATEGORY    PIC X(9).
       10 FILLER           PIC X.
       10 WS-R-RESULT      PIC X(12).
       10 FILLER           PIC X.
       10 WS-R-COUNT       PIC 9.
       10 FILLER           PIC X.
       10 WS-R-INGREDIENTS PIC X(82).
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-NAME                PIC X(40).
 01 WS-GOT                 PIC X(100).
 01 WS-POS                 BINARY-LONG.
 01 WS-PREFIXED            BINARY-LONG.
 01 WS-I-TEXT              PIC 9.
 PROCEDURE DIVISION.
     CALL "BUILTIN-RECIPES-LOAD"
     MOVE "builtin recipes: nine stand-in rows and the bench" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 10 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "builtin recipes: no unlock conditions" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RC-UNLOCK-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         COMPUTE WS-ROW = WS-I
         COMPUTE WS-S = WS-I - 1
         MOVE WS-S TO WS-I-TEXT
         MOVE SPACES TO WS-KEY
         STRING "cobolcraft:" FUNCTION TRIM(WS-R-KEY(WS-I)) DELIMITED BY SIZE INTO WS-KEY
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: display id " WS-I-TEXT " is " FUNCTION TRIM(WS-R-KEY(WS-I))
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-KEY TO TL-EXPECTED
         MOVE RR-KEY(WS-ROW) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       RECIPE-FIND gives the same row.
         CALL "RECIPE-FIND" USING WS-KEY WS-ROW
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " is found at its display id"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE WS-I TO TL-EXPECTED-N
         MOVE WS-ROW TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " is crafting_shapeless"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE RR-SERIALIZER(WS-ROW) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " is not special"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE RR-SPECIAL(WS-ROW) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " shows no notification"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE RR-NOTIFY(WS-ROW) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " has no group"
             DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-EXPECTED
         MOVE RR-GROUP(WS-ROW) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " category" DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-R-CATEGORY(WS-I) TO TL-EXPECTED
         MOVE RR-CATEGORY(WS-ROW) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " result" DELIMITED BY SIZE INTO TL-CASE
         MOVE SPACES TO TL-EXPECTED
         STRING "cobolcraft:" FUNCTION TRIM(WS-R-RESULT(WS-I)) DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE RR-RESULT-ID(WS-ROW) TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " result count" DELIMITED BY SIZE INTO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE WS-R-COUNT(WS-I) TO TL-EXPECTED-N
         MOVE RR-RESULT-COUNT(WS-ROW) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " has no pattern size" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = RR-WIDTH(WS-ROW) + RR-HEIGHT(WS-ROW)
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " has no unlock entries" DELIMITED BY SIZE INTO TL-CASE
         MOVE RR-UNLOCK-N(WS-ROW) TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       The ingredients, one slot per unit, each a cobolcraft: item.
         MOVE SPACES TO WS-GOT
         MOVE 1 TO WS-POS
         MOVE 0 TO WS-PREFIXED
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > RR-ING-COUNT(WS-ROW)
             IF RR-ING(WS-ROW, WS-S)(1:11) = "cobolcraft:"
                 ADD 1 TO WS-PREFIXED
             END-IF
             MOVE SPACES TO WS-NAME
             MOVE RR-ING(WS-ROW, WS-S)(12:40) TO WS-NAME
             IF WS-S > 1
                 MOVE "," TO WS-GOT(WS-POS:1)
                 ADD 1 TO WS-POS
             END-IF
             STRING FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-GOT WITH POINTER WS-POS
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " ingredients" DELIMITED BY SIZE INTO TL-CASE
         MOVE "T" TO TL-MODE
         MOVE WS-R-INGREDIENTS(WS-I) TO TL-EXPECTED
         MOVE WS-GOT TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "builtin recipes: " FUNCTION TRIM(WS-R-KEY(WS-I)) " names only cobolcraft: items" DELIMITED BY SIZE INTO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE RR-ING-COUNT(WS-ROW) TO TL-EXPECTED-N
         MOVE WS-PREFIXED TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM

*>   sod_cake (five ingredients) and goto_pad (seven) need the 3 x 3 grid: more slots than the 2 x 2 grid has (core 5.7).
     MOVE "cobolcraft:sod_cake" TO WS-KEY
     CALL "RECIPE-FIND" USING WS-KEY WS-ROW
     MOVE "builtin recipes: sod_cake has five slots" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE RR-ING-COUNT(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cobolcraft:goto_pad" TO WS-KEY
     CALL "RECIPE-FIND" USING WS-KEY WS-ROW
     MOVE "builtin recipes: goto_pad has seven slots" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE RR-ING-COUNT(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The standard names are not here (WT-25); a second load replaces the first; free empties the store.
     MOVE "minecraft:stick" TO WS-KEY
     CALL "RECIPE-FIND" USING WS-KEY WS-ROW
     MOVE "builtin recipes: a standard recipe is not in the cobolcraft set" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BUILTIN-RECIPES-LOAD"
     MOVE "builtin recipes: loading again keeps ten rows" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "RECIPES-FREE"
     MOVE "builtin recipes: RECIPES-FREE empties the store" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
