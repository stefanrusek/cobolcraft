*> The built-in recipe layer of the cobolcraft world type (T0215; docs/design/cobolcraft-standard-core.md section 5.7 and
*> decision CORE-23, docs/design/standin-content.md section 13): the stand-in recipes as rows of the RC-STORE shape
*> the recipe loader (recipes.cob) gives a data file. Nine crafting_shapeless recipes in the order of core 5.7
*> (display ids 0 to 8): each ingredient is written once per unit, every item is a cobolcraft: item, the category is
*> that of the table of 5.7, there is no group, show_notification is false and no recipe has an unlock condition (a
*> player knows all recipes from joining, core 5.7 "Unlock"). The bench recipe (display id 9, shaped) belongs to
*> the bench phase (core 5.7, T0217 to T0218). Each line below is one recipe, its columns separated by "|": key,
*> category, result, result count, ingredients separated by spaces (all names without "cobolcraft:").

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUILTIN-RECIPES-LOAD.
*> No parameters: replaces the content of RC-STORE with the nine built-in recipes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-ROWS.
    05 FILLER PIC X(140) VALUE "ledger_tile|building|ledger_tile|2|greystone greystone greystone greystone".
    05 FILLER PIC X(140) VALUE "lucite|building|lucite|2|grit grit grit grit".
    05 FILLER PIC X(140) VALUE "pry_bar|equipment|pry_bar|1|greystone greystone greystone cardstack".
    05 FILLER PIC X(140) VALUE "trowel|equipment|trowel|1|greystone greystone cardstack".
    05 FILLER PIC X(140) VALUE "glowtube|building|glowtube|2|lucite dump_shard".
    05 FILLER PIC X(140) VALUE "sod_cake|misc|sod_cake|1|turf turf turf turf loam".
    05 FILLER PIC X(140) VALUE "seared_flank|misc|seared_flank|2|grazer_flank grazer_flank glowtube".
    05 FILLER PIC X(140) VALUE "goto_pad|misc|goto_pad|1|ledger_tile ledger_tile ledger_tile ledger_tile dump_shard dump_shard glowtube".
    05 FILLER PIC X(140) VALUE "dump_shard|misc|dump_shard|1|cardstack cardstack lucite lucite".
 01 WS-TABLE REDEFINES WS-ROWS.
    05 WS-LINE             PIC X(140) OCCURS 9 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 01 WS-CATEGORY            PIC X(24).
 01 WS-RESULT              PIC X(40).
 01 WS-COUNT               PIC 9.
 01 WS-LIST                PIC X(140).
 01 WS-NAME                PIC X(40).
 01 WS-POINTER             BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "RECIPES-FREE"
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > 9
         MOVE SPACES TO WS-LIST
         UNSTRING WS-LINE(WS-INDEX) DELIMITED BY "|" INTO WS-KEY WS-CATEGORY WS-RESULT WS-COUNT WS-LIST
         ADD 1 TO RC-COUNT
         INITIALIZE RC-ROW(RC-COUNT)
         STRING "cobolcraft:" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO RR-KEY(RC-COUNT)
         MOVE 1 TO RR-SERIALIZER(RC-COUNT)
         MOVE WS-CATEGORY TO RR-CATEGORY(RC-COUNT)
         STRING "cobolcraft:" FUNCTION TRIM(WS-RESULT) DELIMITED BY SIZE INTO RR-RESULT-ID(RC-COUNT)
         MOVE WS-COUNT TO RR-RESULT-COUNT(RC-COUNT)
*>       The ingredients: one slot per name.
         COMPUTE WS-END = FUNCTION LENGTH(FUNCTION TRIM(WS-LIST TRAILING))
         MOVE 1 TO WS-POINTER
         PERFORM UNTIL WS-POINTER > WS-END
             MOVE SPACES TO WS-NAME
             UNSTRING WS-LIST DELIMITED BY SPACE INTO WS-NAME WITH POINTER WS-POINTER
             ADD 1 TO RR-ING-COUNT(RC-COUNT)
             STRING "cobolcraft:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE
                 INTO RR-ING(RC-COUNT, RR-ING-COUNT(RC-COUNT))
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BUILTIN-RECIPES-LOAD.
