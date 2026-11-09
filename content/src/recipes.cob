*> The recipe loader of the content library (docs/protocol/27-recipes-and-unlocks.md sections 1 to 3, 5.9 and 6.1;
*> 13 sections 3.1 and 3.2; 23 sections 1 and 3.4, "recipe" being a RELOADABLE registry, 23 section 2).
*> RECIPES-LOAD reads the recipe files data/<namespace>/recipe/**/*.json of a data tree through the registry loader
*> (registry.cob: strict JSON, identifiers, entry order = path first, then namespace) and parses every file into a
*> row of RC-STORE (CTRECIPE.cpy, the layout and the meaning of each field are documented there); the recipe
*> advancements data/<namespace>/advancement/recipes/**/*.json are read the same way and give each recipe its unlock
*> conditions (27 5.9: the criteria other than recipe_unlocked). Every error is printed on standard error as
*> "ERROR registry: recipe <key>: <detail>" (or the registry loader's own text); any error fails the whole load
*> (23 section 3.5): the status is CT-BAD-DATA and nothing stays loaded.
*> The registry loader's private working table is used for the load and released before returning, so a set that is
*> open keeps its registries. Not read here (owed to the engines of 27): the shapes of a firework star, the
*> ingredients of a brewing recipe, component data of a result, material counts of the display, advancement
*> triggers other than the trigger name (inventory_changed also keeps its item predicates).
*> A transmute recipe's material_count: a number is an exact count, an object a range with the bounds default 1 and
*> 8 (27 2.4; a bound that is left out is inferred, not read).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-TYPE-AT.
*> USING index (BINARY-LONG, 1 to 22: the serializer id plus one, 27 section 1.1), name out (PIC X(40), without
*> "minecraft:"), ingredient fields out (PIC X(80): the ingredient fields of the serializer in the order of 27
*> section 2.1 and of RR-ING, separated by single spaces, a trailing "?" marking a field that may be left out; a
*> shaped and a shapeless recipe have their own readers and none here), result flag out (PIC X: "1" when the
*> recipe must have a result with an id).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPES.
    05 FILLER PIC X(121) VALUE "crafting_shaped                                                                                                         1".
    05 FILLER PIC X(121) VALUE "crafting_shapeless                                                                                                      1".
    05 FILLER PIC X(121) VALUE "crafting_dye                            target dye                                                                      0".
    05 FILLER PIC X(121) VALUE "crafting_imbue                          source material                                                                 0".
    05 FILLER PIC X(121) VALUE "crafting_transmute                      input material                                                                  0".
    05 FILLER PIC X(121) VALUE "crafting_decorated_pot                  back left right front                                                           0".
    05 FILLER PIC X(121) VALUE "crafting_special_bookcloning            source material                                                                 0".
    05 FILLER PIC X(121) VALUE "crafting_special_mapextending           map material                                                                    0".
    05 FILLER PIC X(121) VALUE "crafting_special_firework_rocket        shell fuel star                                                                 0".
    05 FILLER PIC X(121) VALUE "crafting_special_firework_star          trail twinkle fuel dye                                                          0".
    05 FILLER PIC X(121) VALUE "crafting_special_firework_star_fade     target dye                                                                      0".
    05 FILLER PIC X(121) VALUE "crafting_special_bannerduplicate        banner                                                                          0".
    05 FILLER PIC X(121) VALUE "crafting_special_shielddecoration       banner target                                                                   0".
    05 FILLER PIC X(121) VALUE "crafting_special_repairitem                                                                                             0".
    05 FILLER PIC X(121) VALUE "smelting                                ingredient                                                                      1".
    05 FILLER PIC X(121) VALUE "blasting                                ingredient                                                                      1".
    05 FILLER PIC X(121) VALUE "smoking                                 ingredient                                                                      1".
    05 FILLER PIC X(121) VALUE "campfire_cooking                        ingredient                                                                      1".
    05 FILLER PIC X(121) VALUE "stonecutting                            ingredient                                                                      1".
    05 FILLER PIC X(121) VALUE "smithing_transform                      template? base addition?                                                        1".
    05 FILLER PIC X(121) VALUE "brewing                                                                                                                 0".
    05 FILLER PIC X(121) VALUE "smithing_trim                           template base addition                                                          0".
 01 WS-TABLE REDEFINES WS-TYPES.
    05 WS-TYPE OCCURS 22 TIMES.
       10 WS-T-NAME           PIC X(40).
       10 WS-T-FIELDS         PIC X(80).
       10 WS-T-FLAG           PIC X.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(40).
 01 L-FIELDS               PIC X(80).
 01 L-FLAG                 PIC X.
 PROCEDURE DIVISION USING L-INDEX L-NAME L-FIELDS L-FLAG.
     MOVE WS-T-NAME(L-INDEX) TO L-NAME
     MOVE WS-T-FIELDS(L-INDEX) TO L-FIELDS
     MOVE WS-T-FLAG(L-INDEX) TO L-FLAG
     GOBACK.
 END PROGRAM RECIPE-TYPE-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-FAIL.
*> USING key (PIC X(64)), detail (PIC X(120)): prints "ERROR registry: recipe <key>: <detail>" on standard error
*> and counts the error (RS-ERROR).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MESSAGE             PIC X(200).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-DETAIL               PIC X(120).
 PROCEDURE DIVISION USING L-KEY L-DETAIL.
     MOVE SPACES TO WS-MESSAGE
     STRING "recipe " FUNCTION TRIM(L-KEY) ": " FUNCTION TRIM(L-DETAIL) DELIMITED BY SIZE INTO WS-MESSAGE
     CALL "RS-ERROR" USING WS-MESSAGE
     GOBACK.
 END PROGRAM RECIPE-FAIL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-MEMBER.
*> USING JSON-DOC, object node (BINARY-LONG; 0 gives 0), name (PIC X(32), space padded), member node out (0 when
*> absent): JSON-MEMBER by a padded name.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NAME                PIC X(32).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-OBJECT               BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-NODE                 BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-OBJECT L-NAME L-NODE.
     MOVE 0 TO WS-LENGTH
     INSPECT L-NAME TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
     MOVE L-NAME TO WS-NAME
     CALL "JSON-MEMBER" USING JSON-DOC L-OBJECT WS-NAME WS-LENGTH L-NODE
     GOBACK.
 END PROGRAM RECIPE-MEMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-GET-TEXT.
*> USING JSON-DOC, object node, name (PIC X(32)), text out (PIC X(200), spaces when not found), found out
*> (BINARY-LONG: 1 when the member is a string).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NODE                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 200.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-OBJECT               BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-TEXT                 PIC X(200).
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-OBJECT L-NAME L-TEXT L-FOUND.
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-FOUND
     CALL "RECIPE-MEMBER" USING JSON-DOC L-OBJECT L-NAME WS-NODE
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-STRING
             CALL "JSON-STRING" USING JSON-DOC WS-NODE L-TEXT WS-CAPACITY WS-LENGTH
             MOVE 1 TO L-FOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RECIPE-GET-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-NUMBER.
*> USING JSON-DOC, object node, name (PIC X(32)), value out (FLOAT-LONG), found out (BINARY-LONG: 1 when the
*> member is a number).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NODE                BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-OBJECT               BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-VALUE                FLOAT-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-OBJECT L-NAME L-VALUE L-FOUND.
     MOVE 0 TO L-VALUE L-FOUND
     CALL "RECIPE-MEMBER" USING JSON-DOC L-OBJECT L-NAME WS-NODE
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-NUMBER
             MOVE JN-NUM(WS-NODE) TO L-VALUE
             MOVE 1 TO L-FOUND
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RECIPE-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-INGREDIENT.
*> USING JSON-DOC, node (BINARY-LONG; 0 = absent), text out (PIC X(160)), status out (BINARY-LONG): an ingredient
*> (27 1.3) is an item id or "#tag" string or a non-empty array of id strings; the text is the ids separated by
*> single spaces. Status 0 read; 1 an empty list; 2 not a string or list of strings, or an empty string; 3 more
*> than 160 bytes; 4 absent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CAPACITY            BINARY-LONG VALUE 160.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-ITEM                PIC X(160).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-TEXT                 PIC X(160).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-TEXT L-STATUS.
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-STATUS
     IF L-NODE = 0
         MOVE 4 TO L-STATUS
         GOBACK
     END-IF
     EVALUATE JN-TYPE(L-NODE)
         WHEN JT-STRING
             CALL "JSON-STRING" USING JSON-DOC L-NODE L-TEXT WS-CAPACITY WS-LENGTH
             IF WS-LENGTH = 0
                 MOVE 2 TO L-STATUS
             END-IF
         WHEN JT-ARRAY
             IF JN-COUNT(L-NODE) = 0
                 MOVE 1 TO L-STATUS
             END-IF
             MOVE 1 TO WS-POS
             MOVE JN-FIRST(L-NODE) TO WS-CHILD
             PERFORM UNTIL WS-CHILD = 0 OR L-STATUS NOT = 0
                 MOVE 0 TO WS-LENGTH
                 IF JN-TYPE(WS-CHILD) = JT-STRING
                     CALL "JSON-STRING" USING JSON-DOC WS-CHILD WS-ITEM WS-CAPACITY WS-LENGTH
                 END-IF
                 IF WS-LENGTH = 0
                     MOVE 2 TO L-STATUS
                 END-IF
                 MOVE WS-POS TO WS-START
                 IF WS-POS > 1
                     ADD 1 TO WS-START
                 END-IF
                 IF L-STATUS = 0 AND WS-START + WS-LENGTH > 161
                     MOVE 3 TO L-STATUS
                 END-IF
                 IF L-STATUS = 0
                     MOVE WS-ITEM(1:WS-LENGTH) TO L-TEXT(WS-START:WS-LENGTH)
                     COMPUTE WS-POS = WS-START + WS-LENGTH
                 END-IF
                 MOVE JN-NEXT(WS-CHILD) TO WS-CHILD
             END-PERFORM
         WHEN OTHER
             MOVE 2 TO L-STATUS
     END-EVALUATE
     IF L-STATUS NOT = 0
         MOVE SPACES TO L-TEXT
     END-IF
     GOBACK.
 END PROGRAM RECIPE-INGREDIENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-ING-ERROR.
*> USING key (PIC X(64)), field name (PIC X(32)), status (BINARY-LONG, not 0: a RECIPE-INGREDIENT status):
*> prints the error of a bad ingredient (RECIPE-FAIL).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-NAME                 PIC X(32).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-NAME L-STATUS.
     MOVE SPACES TO WS-DETAIL
     EVALUATE L-STATUS
         WHEN 1
             STRING FUNCTION TRIM(L-NAME) " is an empty list" DELIMITED BY SIZE INTO WS-DETAIL
         WHEN 3
             STRING FUNCTION TRIM(L-NAME) " is over 160 bytes" DELIMITED BY SIZE INTO WS-DETAIL
         WHEN 4
             STRING FUNCTION TRIM(L-NAME) " is missing" DELIMITED BY SIZE INTO WS-DETAIL
         WHEN OTHER
             STRING FUNCTION TRIM(L-NAME) " is not an item, a tag or a list of items" DELIMITED BY SIZE
                 INTO WS-DETAIL
     END-EVALUATE
     CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
     GOBACK.
 END PROGRAM RECIPE-ING-ERROR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-SET-ING.
*> USING JSON-DOC, ingredient node, row (BINARY-LONG), slot (BINARY-LONG, 1 to 9), key (PIC X(64)), field name
*> (PIC X(32)), status out (BINARY-LONG: 0 stored in RR-ING(row, slot); 1 reported by RECIPE-ING-ERROR).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-TEXT                PIC X(160).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-NAME                 PIC X(32).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW L-SLOT L-KEY L-NAME L-STATUS.
     CALL "RECIPE-INGREDIENT" USING JSON-DOC L-NODE WS-TEXT WS-STATUS
     MOVE 0 TO L-STATUS
     IF WS-STATUS = 0
         MOVE WS-TEXT TO RR-ING(L-ROW, L-SLOT)
     ELSE
         CALL "RECIPE-ING-ERROR" USING L-KEY L-NAME WS-STATUS
         MOVE 1 TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM RECIPE-SET-ING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-SHAPELESS.
*> USING JSON-DOC, row (BINARY-LONG), key (PIC X(64)), status out (BINARY-LONG: 0 read, 1 reported): the
*> "ingredients" list of 1 to 9 ingredients (27 2.2) into RR-ING in order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(32).
 01 WS-LIST                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-ROW L-KEY L-STATUS.
     MOVE 1 TO L-STATUS
     MOVE "ingredients" TO WS-NAME
     CALL "RECIPE-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-LIST
     MOVE 0 TO WS-COUNT
     IF WS-LIST > 0
         IF JN-TYPE(WS-LIST) = JT-ARRAY
             MOVE JN-COUNT(WS-LIST) TO WS-COUNT
         END-IF
     END-IF
     IF WS-COUNT < 1 OR WS-COUNT > 9
         MOVE "ingredients must be a list of 1 to 9 ingredients" TO WS-DETAIL
         CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
         GOBACK
     END-IF
     MOVE JN-FIRST(WS-LIST) TO WS-CHILD
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > WS-COUNT
         CALL "RECIPE-SET-ING" USING JSON-DOC WS-CHILD L-ROW WS-SLOT L-KEY WS-NAME L-STATUS
         IF L-STATUS NOT = 0
             GOBACK
         END-IF
         MOVE JN-NEXT(WS-CHILD) TO WS-CHILD
     END-PERFORM
     MOVE WS-COUNT TO RR-ING-COUNT(L-ROW)
     MOVE 0 TO L-STATUS
     GOBACK.
 END PROGRAM RECIPE-SHAPELESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-GENERIC.
*> USING JSON-DOC, row (BINARY-LONG), key (PIC X(64)), serializer index (BINARY-LONG, 1 to 22), status out
*> (BINARY-LONG: 0 read, 1 reported): the ingredient fields of the serializer (RECIPE-TYPE-AT) into RR-ING in
*> order; a field marked optional that is absent leaves its slot empty.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-TYPE-NAME           PIC X(40).
 01 WS-FIELDS              PIC X(80).
 01 WS-FLAG                PIC X.
 01 WS-NAME                PIC X(32).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-OPTIONAL            BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-INDEX                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-ROW L-KEY L-INDEX L-STATUS.
     CALL "RECIPE-TYPE-AT" USING L-INDEX WS-TYPE-NAME WS-FIELDS WS-FLAG
     MOVE 0 TO L-STATUS WS-SLOT
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > 80
         MOVE SPACES TO WS-NAME
         UNSTRING WS-FIELDS DELIMITED BY ALL SPACE INTO WS-NAME WITH POINTER WS-POINTER
         IF WS-NAME = SPACES
             MOVE 81 TO WS-POINTER
         ELSE
             MOVE 0 TO WS-LENGTH WS-OPTIONAL
             INSPECT WS-NAME TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL SPACE
             IF WS-NAME(WS-LENGTH:1) = "?"
                 MOVE SPACE TO WS-NAME(WS-LENGTH:1)
                 MOVE 1 TO WS-OPTIONAL
             END-IF
             ADD 1 TO WS-SLOT
             CALL "RECIPE-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NODE
             IF WS-NODE > 0 OR WS-OPTIONAL = 0
                 CALL "RECIPE-SET-ING" USING JSON-DOC WS-NODE L-ROW WS-SLOT L-KEY WS-NAME L-STATUS
                 IF L-STATUS NOT = 0
                     GOBACK
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-SLOT TO RR-ING-COUNT(L-ROW)
     GOBACK.
 END PROGRAM RECIPE-GENERIC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-SHAPED.
*> USING JSON-DOC, row (BINARY-LONG), key (PIC X(64)), status out (BINARY-LONG: 0 read, 1 reported): a shaped
*> recipe (13 3.1, 3.2): "pattern" of 1 to 3 rows of 1 to 3 characters of one length (a space is an empty cell),
*> "key" of at most nine one-character names (not a space) each with an ingredient; every character of the
*> pattern must have a key and every key must be used. The pattern is trimmed to the bounding box of its
*> non-empty cells (RR-WIDTH, RR-HEIGHT) and RR-ING gets the cells of the box row by row.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(32).
 01 WS-DETAIL              PIC X(120).
 01 WS-PATTERN             BINARY-LONG.
 01 WS-KEYS                BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG.
 01 WS-MEMBER              BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-COLS                BINARY-LONG.
 01 WS-KEY-COUNT           BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 200.
 01 WS-TEXT                PIC X(200).
 01 WS-GRID                PIC X(9).
 01 WS-CHAR                PIC X.
 01 WS-MIN-R               BINARY-LONG.
 01 WS-MAX-R               BINARY-LONG.
 01 WS-MIN-C               BINARY-LONG.
 01 WS-MAX-C               BINARY-LONG.
 01 WS-WIDTH               BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-KEY-TABLE.
    05 WS-K OCCURS 9 TIMES.
       10 WS-K-CHAR        PIC X.
       10 WS-K-NODE        BINARY-LONG.
       10 WS-K-USED        BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-ROW L-KEY L-STATUS.
     MOVE 1 TO L-STATUS
     MOVE SPACES TO WS-GRID
     MOVE "pattern" TO WS-NAME
     CALL "RECIPE-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-PATTERN
     MOVE 0 TO WS-ROWS
     IF WS-PATTERN > 0
         IF JN-TYPE(WS-PATTERN) = JT-ARRAY
             MOVE JN-COUNT(WS-PATTERN) TO WS-ROWS
         END-IF
     END-IF
     IF WS-ROWS < 1 OR WS-ROWS > 3
         MOVE "pattern must be a list of 1 to 3 rows" TO WS-DETAIL
         CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
         GOBACK
     END-IF
*>   The rows: 1 to 3 characters each, all of one length, into the 3 x 3 grid.
     MOVE 0 TO WS-COLS
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WS-ROWS
         COMPUTE WS-N = WS-R - 1
         CALL "JSON-ELEMENT" USING JSON-DOC WS-PATTERN WS-N WS-ELEMENT
         CALL "JSON-STRING" USING JSON-DOC WS-ELEMENT WS-TEXT WS-CAPACITY WS-LENGTH
         IF WS-LENGTH < 1 OR WS-LENGTH > 3
             MOVE "a pattern row must be 1 to 3 characters" TO WS-DETAIL
             CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
             GOBACK
         END-IF
         IF WS-R = 1
             MOVE WS-LENGTH TO WS-COLS
         END-IF
         IF WS-LENGTH NOT = WS-COLS
             MOVE "the pattern rows differ in length" TO WS-DETAIL
             CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
             GOBACK
         END-IF
         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > WS-COLS
             COMPUTE WS-CELL = (WS-R - 1) * 3 + WS-C
             MOVE WS-TEXT(WS-C:1) TO WS-GRID(WS-CELL:1)
         END-PERFORM
     END-PERFORM
*>   The keys: one character each, at most nine.
     MOVE "key" TO WS-NAME
     CALL "RECIPE-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-KEYS
     MOVE 0 TO WS-FOUND WS-KEY-COUNT
     IF WS-KEYS > 0
         IF JN-TYPE(WS-KEYS) = JT-OBJECT
             MOVE 1 TO WS-FOUND
             MOVE JN-COUNT(WS-KEYS) TO WS-KEY-COUNT
         END-IF
     END-IF
     IF WS-FOUND = 0
         MOVE "key must be an object" TO WS-DETAIL
         CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
         GOBACK
     END-IF
     IF WS-KEY-COUNT > 9
         MOVE "key has more than 9 entries" TO WS-DETAIL
         CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
         GOBACK
     END-IF
     MOVE JN-FIRST(WS-KEYS) TO WS-MEMBER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KEY-COUNT
         CALL "JSON-KEY" USING JSON-DOC WS-MEMBER WS-TEXT WS-CAPACITY WS-LENGTH
         IF WS-LENGTH NOT = 1 OR WS-TEXT(1:1) = SPACE
             MOVE "a key must be one character and not a space" TO WS-DETAIL
             CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
             GOBACK
         END-IF
         MOVE WS-TEXT(1:1) TO WS-K-CHAR(WS-I)
         MOVE WS-MEMBER TO WS-K-NODE(WS-I)
         MOVE 0 TO WS-K-USED(WS-I)
         MOVE JN-NEXT(WS-MEMBER) TO WS-MEMBER
     END-PERFORM
*>   Every pattern character needs a key; the bounding box of the non-empty cells.
     MOVE 4 TO WS-MIN-R WS-MIN-C
     MOVE 0 TO WS-MAX-R WS-MAX-C
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WS-ROWS
         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > WS-COLS
             COMPUTE WS-CELL = (WS-R - 1) * 3 + WS-C
             MOVE WS-GRID(WS-CELL:1) TO WS-CHAR
             IF WS-CHAR NOT = SPACE
                 MOVE 0 TO WS-FOUND
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KEY-COUNT OR WS-FOUND > 0
                     IF WS-K-CHAR(WS-I) = WS-CHAR
                         MOVE WS-I TO WS-FOUND
                     END-IF
                 END-PERFORM
                 IF WS-FOUND = 0
                     MOVE "the pattern uses a character that has no key" TO WS-DETAIL
                     CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
                     GOBACK
                 END-IF
                 MOVE 1 TO WS-K-USED(WS-FOUND)
                 MOVE FUNCTION MIN(WS-MIN-R, WS-R) TO WS-MIN-R
                 MOVE FUNCTION MAX(WS-MAX-R, WS-R) TO WS-MAX-R
                 MOVE FUNCTION MIN(WS-MIN-C, WS-C) TO WS-MIN-C
                 MOVE FUNCTION MAX(WS-MAX-C, WS-C) TO WS-MAX-C
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KEY-COUNT
         IF WS-K-USED(WS-I) = 0
             MOVE "a key is not used in the pattern" TO WS-DETAIL
             CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
             GOBACK
         END-IF
     END-PERFORM
     IF WS-MAX-R = 0
         MOVE "the pattern has no ingredient" TO WS-DETAIL
         CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
         GOBACK
     END-IF
*>   The trimmed cells, row by row.
     COMPUTE WS-WIDTH = WS-MAX-C - WS-MIN-C + 1
     COMPUTE WS-HEIGHT = WS-MAX-R - WS-MIN-R + 1
     MOVE WS-WIDTH TO RR-WIDTH(L-ROW)
     MOVE WS-HEIGHT TO RR-HEIGHT(L-ROW)
     COMPUTE RR-ING-COUNT(L-ROW) = WS-WIDTH * WS-HEIGHT
     MOVE "key" TO WS-NAME
     PERFORM VARYING WS-R FROM WS-MIN-R BY 1 UNTIL WS-R > WS-MAX-R
         PERFORM VARYING WS-C FROM WS-MIN-C BY 1 UNTIL WS-C > WS-MAX-C
             COMPUTE WS-CELL = (WS-R - 1) * 3 + WS-C
             MOVE WS-GRID(WS-CELL:1) TO WS-CHAR
             IF WS-CHAR NOT = SPACE
                 MOVE 0 TO WS-FOUND
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KEY-COUNT OR WS-FOUND > 0
                     IF WS-K-CHAR(WS-I) = WS-CHAR
                         MOVE WS-I TO WS-FOUND
                     END-IF
                 END-PERFORM
                 COMPUTE WS-SLOT = (WS-R - WS-MIN-R) * WS-WIDTH + (WS-C - WS-MIN-C) + 1
                 CALL "RECIPE-SET-ING" USING JSON-DOC WS-K-NODE(WS-FOUND) L-ROW WS-SLOT L-KEY WS-NAME L-STATUS
                 IF L-STATUS NOT = 0
                     GOBACK
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO L-STATUS
     GOBACK.
 END PROGRAM RECIPE-SHAPED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-TRANSMUTE.
*> USING JSON-DOC, row (BINARY-LONG), key (PIC X(64)), status out (BINARY-LONG: 0 read, 1 reported): the
*> material_count (a number, or an object with min and max; default exactly 1; within 1 to 8, 27 2.4) and
*> add_material_count_to_result (default false) of a transmute recipe.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(32).
 01 WS-DETAIL              PIC X(120).
 01 WS-NODE                BINARY-LONG.
 01 WS-VALUE               FLOAT-LONG.
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-ROW L-KEY L-STATUS.
     MOVE 1 TO L-STATUS
     MOVE 1 TO RR-MATERIAL-MIN(L-ROW) RR-MATERIAL-MAX(L-ROW)
     MOVE 0 TO RR-ADD-COUNT(L-ROW)
     MOVE "material_count" TO WS-NAME
     CALL "RECIPE-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NODE
     EVALUATE TRUE
         WHEN WS-NODE = 0
             CONTINUE
         WHEN JN-TYPE(WS-NODE) = JT-NUMBER
             COMPUTE RR-MATERIAL-MIN(L-ROW) = JN-NUM(WS-NODE)
             MOVE RR-MATERIAL-MIN(L-ROW) TO RR-MATERIAL-MAX(L-ROW)
         WHEN JN-TYPE(WS-NODE) = JT-OBJECT
             MOVE 8 TO RR-MATERIAL-MAX(L-ROW)
             MOVE "min" TO WS-NAME
             CALL "RECIPE-NUMBER" USING JSON-DOC WS-NODE WS-NAME WS-VALUE WS-FOUND
             IF WS-FOUND = 1
                 COMPUTE RR-MATERIAL-MIN(L-ROW) = WS-VALUE
             END-IF
             MOVE "max" TO WS-NAME
             CALL "RECIPE-NUMBER" USING JSON-DOC WS-NODE WS-NAME WS-VALUE WS-FOUND
             IF WS-FOUND = 1
                 COMPUTE RR-MATERIAL-MAX(L-ROW) = WS-VALUE
             END-IF
         WHEN OTHER
             MOVE 0 TO RR-MATERIAL-MAX(L-ROW)
     END-EVALUATE
     IF RR-MATERIAL-MIN(L-ROW) < 1 OR RR-MATERIAL-MAX(L-ROW) > 8
             OR RR-MATERIAL-MIN(L-ROW) > RR-MATERIAL-MAX(L-ROW)
         MOVE "material_count must be a number or a range within 1 to 8" TO WS-DETAIL
         CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
         GOBACK
     END-IF
     MOVE "add_material_count_to_result" TO WS-NAME
     CALL "RECIPE-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NODE
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-TRUE
             MOVE 1 TO RR-ADD-COUNT(L-ROW)
         END-IF
     END-IF
     MOVE 0 TO L-STATUS
     GOBACK.
 END PROGRAM RECIPE-TRANSMUTE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-FILL.
*> USING JSON-DOC, row (BINARY-LONG: the row to fill, already cleared and keyed), key (PIC X(64)), status out
*> (BINARY-LONG: 0 filled, 1 an error was reported): the common fields of 27 1.2 (group, category, show_notification
*> and, for the special serializers, no notification and group ""), the serializer's own fields, the result
*> (a template {id, count} named "result", "output" for brewing; the id is required when RECIPE-TYPE-AT says so),
*> the cooking fields of 27 3.1 (cookingtime required, experience default 0) and the pattern of a smithing trim.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(32).
 01 WS-DETAIL              PIC X(120).
 01 WS-TEXT                PIC X(200).
 01 WS-FULL                PIC X(200).
 01 WS-TYPE-NAME           PIC X(40).
 01 WS-FIELDS              PIC X(80).
 01 WS-FLAG                PIC X.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-SERIALIZER          BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-VALUE               FLOAT-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-ROW                  BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-ROW L-KEY L-STATUS.
     MOVE 1 TO L-STATUS
*>   The serializer: the "minecraft:" name of the type field, found in the table of RECIPE-TYPE-AT.
     MOVE "type" TO WS-NAME
     CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-ROOT WS-NAME WS-TEXT WS-FOUND
     MOVE 0 TO WS-I
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 22 OR WS-I > 0
         CALL "RECIPE-TYPE-AT" USING WS-J WS-TYPE-NAME WS-FIELDS WS-FLAG
         MOVE SPACES TO WS-FULL
         STRING "minecraft:" FUNCTION TRIM(WS-TYPE-NAME) DELIMITED BY SIZE INTO WS-FULL
         IF WS-FOUND = 1 AND WS-TEXT = WS-FULL
             MOVE WS-J TO WS-I
         END-IF
     END-PERFORM
     IF WS-I = 0
         MOVE "type is missing or not a recipe type" TO WS-DETAIL
         CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
         GOBACK
     END-IF
     COMPUTE WS-SERIALIZER = WS-I - 1
     MOVE WS-SERIALIZER TO RR-SERIALIZER(L-ROW)
*>   Special recipes (27 1.2): the custom crafting serializers 5 to 13 and brewing (20) never notify.
     MOVE 0 TO RR-SPECIAL(L-ROW)
     IF (WS-SERIALIZER >= 5 AND WS-SERIALIZER <= 13) OR WS-SERIALIZER = 20
         MOVE 1 TO RR-SPECIAL(L-ROW)
     END-IF
     MOVE 1 TO RR-NOTIFY(L-ROW)
     MOVE "show_notification" TO WS-NAME
     CALL "RECIPE-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NODE
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-FALSE
             MOVE 0 TO RR-NOTIFY(L-ROW)
         END-IF
     END-IF
     IF RR-SPECIAL(L-ROW) = 1
         MOVE 0 TO RR-NOTIFY(L-ROW)
     END-IF
     MOVE "group" TO WS-NAME
     CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-ROOT WS-NAME WS-TEXT WS-FOUND
     MOVE WS-TEXT TO RR-GROUP(L-ROW)
     MOVE SPACES TO RR-CATEGORY(L-ROW)
     IF WS-SERIALIZER < 18
         MOVE "misc" TO RR-CATEGORY(L-ROW)
     END-IF
     MOVE "category" TO WS-NAME
     CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-ROOT WS-NAME WS-TEXT WS-FOUND
     IF WS-FOUND = 1
         MOVE WS-TEXT TO RR-CATEGORY(L-ROW)
     END-IF
*>   The serializer's own ingredient fields.
     EVALUATE WS-I
         WHEN 1
             CALL "RECIPE-SHAPED" USING JSON-DOC L-ROW L-KEY WS-STATUS
         WHEN 2
             CALL "RECIPE-SHAPELESS" USING JSON-DOC L-ROW L-KEY WS-STATUS
         WHEN OTHER
             CALL "RECIPE-GENERIC" USING JSON-DOC L-ROW L-KEY WS-I WS-STATUS
     END-EVALUATE
     IF WS-STATUS NOT = 0
         GOBACK
     END-IF
     IF WS-SERIALIZER = 4
         CALL "RECIPE-TRANSMUTE" USING JSON-DOC L-ROW L-KEY WS-STATUS
         IF WS-STATUS NOT = 0
             GOBACK
         END-IF
     END-IF
     IF WS-SERIALIZER >= 14 AND WS-SERIALIZER <= 17
         MOVE "cookingtime" TO WS-NAME
         CALL "RECIPE-NUMBER" USING JSON-DOC WS-ROOT WS-NAME WS-VALUE WS-FOUND
         IF WS-FOUND = 0
             MOVE "cookingtime is missing or not a number" TO WS-DETAIL
             CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
             GOBACK
         END-IF
         COMPUTE RR-COOK-TIME(L-ROW) = WS-VALUE
         MOVE "experience" TO WS-NAME
         CALL "RECIPE-NUMBER" USING JSON-DOC WS-ROOT WS-NAME WS-VALUE WS-FOUND
         MOVE WS-VALUE TO RR-EXPERIENCE(L-ROW)
     END-IF
     IF WS-SERIALIZER = 21
         MOVE "pattern" TO WS-NAME
         CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-ROOT WS-NAME WS-TEXT WS-FOUND
         MOVE WS-TEXT TO RR-EXTRA(L-ROW)
     END-IF
*>   The result template.
     MOVE "result" TO WS-NAME
     IF WS-SERIALIZER = 20
         MOVE "output" TO WS-NAME
     END-IF
     CALL "RECIPE-MEMBER" USING JSON-DOC WS-ROOT WS-NAME WS-NODE
     MOVE 0 TO WS-FOUND
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-OBJECT
             MOVE 1 TO WS-FOUND
         END-IF
     END-IF
     IF WS-FOUND = 1
         MOVE "id" TO WS-NAME
         CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-NODE WS-NAME WS-TEXT WS-FOUND
         MOVE WS-TEXT TO RR-RESULT-ID(L-ROW)
         IF WS-FOUND = 0 AND WS-FLAG = "1"
             MOVE "result has no id" TO WS-DETAIL
             CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
             GOBACK
         END-IF
         MOVE 1 TO RR-RESULT-COUNT(L-ROW)
         MOVE "count" TO WS-NAME
         CALL "RECIPE-NUMBER" USING JSON-DOC WS-NODE WS-NAME WS-VALUE WS-FOUND
         IF WS-FOUND = 1
             COMPUTE RR-RESULT-COUNT(L-ROW) = WS-VALUE
         END-IF
     ELSE
         IF WS-FLAG = "1"
             MOVE "result is missing" TO WS-DETAIL
             CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
             GOBACK
         END-IF
     END-IF
     MOVE 0 TO L-STATUS
     GOBACK.
 END PROGRAM RECIPE-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-PARSE.
*> USING key (PIC X(64), "namespace:path"), text address (POINTER), length (BINARY-LONG), status out (BINARY-LONG:
*> 0 the recipe was added as the next row of RC-STORE, 1 an error was reported and no row was added): parses one
*> recipe file that the strict reader accepted.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 COPY JSONDOC.
 01 B-TEXT                 PIC X(268435456) BASED.
 01 WS-DETAIL              PIC X(120).
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-ADDR                 USAGE POINTER.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ADDR L-LENGTH L-STATUS.
     MOVE 1 TO L-STATUS
     SET ADDRESS OF B-TEXT TO L-ADDR
     CALL "JSON-PARSE" USING JSON-DOC B-TEXT L-LENGTH
     IF JN-TYPE(1) NOT = JT-OBJECT
         MOVE "the file is not a JSON object" TO WS-DETAIL
         CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
         GOBACK
     END-IF
     IF RC-COUNT >= RC-MAX-RECIPES
         MOVE "more than 4096 recipes" TO WS-DETAIL
         CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
         GOBACK
     END-IF
     ADD 1 TO RC-COUNT
     MOVE RC-COUNT TO WS-ROW
     INITIALIZE RC-ROW(WS-ROW)
     MOVE L-KEY TO RR-KEY(WS-ROW)
     CALL "RECIPE-FILL" USING JSON-DOC WS-ROW L-KEY L-STATUS
     IF L-STATUS NOT = 0
         SUBTRACT 1 FROM RC-COUNT
     END-IF
     GOBACK.
 END PROGRAM RECIPE-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-FIND.
*> USING key (PIC X(64), "namespace:path"), row out (BINARY-LONG: the 1-based row of RC-STORE, 0 when not found).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RC-COUNT OR L-ROW > 0
         IF RR-KEY(WS-I) = L-KEY
             MOVE WS-I TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPE-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-UNLOCK-ITEMS.
*> USING JSON-DOC, criterion node (BINARY-LONG), key (PIC X(64)), text out (PIC X(200)), status out (BINARY-LONG: 0
*> read, 1 reported): the item predicates of an inventory_changed criterion (conditions.items[*].items, 27 5.2):
*> the ids of one predicate separated by spaces, the predicates by " & "; a predicate without items adds nothing.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(32).
 01 WS-CONDITIONS          BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-PREDICATE           BINARY-LONG.
 01 WS-IDS                 BINARY-LONG.
 01 WS-IDS-TEXT            PIC X(160).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-CRITERION            BINARY-LONG.
 01 L-KEY                  PIC X(64).
 01 L-TEXT                 PIC X(200).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-CRITERION L-KEY L-TEXT L-STATUS.
     MOVE SPACES TO L-TEXT
     MOVE 0 TO L-STATUS
     MOVE "conditions" TO WS-NAME
     CALL "RECIPE-MEMBER" USING JSON-DOC L-CRITERION WS-NAME WS-CONDITIONS
     MOVE "items" TO WS-NAME
     CALL "RECIPE-MEMBER" USING JSON-DOC WS-CONDITIONS WS-NAME WS-LIST
     IF WS-LIST = 0
         GOBACK
     END-IF
     IF JN-TYPE(WS-LIST) NOT = JT-ARRAY
         GOBACK
     END-IF
     MOVE 1 TO WS-POS
     MOVE JN-FIRST(WS-LIST) TO WS-PREDICATE
     PERFORM UNTIL WS-PREDICATE = 0 OR L-STATUS NOT = 0
         CALL "RECIPE-MEMBER" USING JSON-DOC WS-PREDICATE WS-NAME WS-IDS
         IF WS-IDS > 0
             CALL "RECIPE-INGREDIENT" USING JSON-DOC WS-IDS WS-IDS-TEXT WS-STATUS
             IF WS-STATUS NOT = 0
                 CALL "RECIPE-ING-ERROR" USING L-KEY WS-NAME WS-STATUS
                 MOVE 1 TO L-STATUS
             ELSE
                 COMPUTE WS-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(WS-IDS-TEXT TRAILING))
                 IF WS-POS + WS-LENGTH + 3 > 201
                     MOVE "inventory_changed items are over 200 bytes" TO WS-DETAIL
                     CALL "RECIPE-FAIL" USING L-KEY WS-DETAIL
                     MOVE 1 TO L-STATUS
                 ELSE
                     IF WS-POS > 1
                         MOVE " & " TO L-TEXT(WS-POS:3)
                         ADD 3 TO WS-POS
                     END-IF
                     MOVE WS-IDS-TEXT(1:WS-LENGTH) TO L-TEXT(WS-POS:WS-LENGTH)
                     ADD WS-LENGTH TO WS-POS
                 END-IF
             END-IF
         END-IF
         MOVE JN-NEXT(WS-PREDICATE) TO WS-PREDICATE
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPE-UNLOCK-ITEMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-UNLOCK-PARSE.
*> USING key (PIC X(64): the advancement), text address (POINTER), length (BINARY-LONG), status out (BINARY-LONG: 0
*> read, 1 an error was reported): one recipe advancement file (27 5.9) that the strict reader accepted. The recipe
*> is rewards.recipes[0]; an advancement without one (the root) or for a recipe that is not loaded is ignored (27
*> 4.6: keys that the manager does not know are ignored). Each criterion whose trigger is not recipe_unlocked
*> becomes an entry of RC-UNLOCK (trigger and, for inventory_changed, the item predicates) in the order of the
*> file; a second advancement for one recipe is an error.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 COPY JSONDOC.
 01 B-TEXT                 PIC X(268435456) BASED.
 01 WS-PATH                PIC X(32).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 200.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-RECIPE              PIC X(64).
 01 WS-ROW                 BINARY-LONG.
 01 WS-CRITERION           BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-TRIGGER             PIC X(200).
 01 WS-FOUND               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-DETAIL              PIC X(120).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-ADDR                 USAGE POINTER.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ADDR L-LENGTH L-STATUS.
     MOVE 0 TO L-STATUS
     SET ADDRESS OF B-TEXT TO L-ADDR
     CALL "JSON-PARSE" USING JSON-DOC B-TEXT L-LENGTH
     MOVE "rewards.recipes[0]" TO WS-PATH
     MOVE 18 TO WS-PATH-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-PATH WS-PATH-LENGTH WS-NODE
     IF WS-NODE = 0
         GOBACK
     END-IF
     MOVE SPACES TO WS-RECIPE
     CALL "JSON-STRING" USING JSON-DOC WS-NODE WS-RECIPE WS-CAPACITY WS-LENGTH
     CALL "RECIPE-FIND" USING WS-RECIPE WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     IF RR-UNLOCK-N(WS-ROW) > 0
         MOVE "a second recipe advancement rewards this recipe" TO WS-DETAIL
         CALL "RECIPE-FAIL" USING WS-RECIPE WS-DETAIL
         MOVE 1 TO L-STATUS
         GOBACK
     END-IF
     MOVE "criteria" TO WS-PATH
     MOVE 8 TO WS-PATH-LENGTH
     CALL "JSON-FIND" USING JSON-DOC WS-PATH WS-PATH-LENGTH WS-NODE
     MOVE 0 TO WS-CRITERION
     IF WS-NODE > 0
         MOVE JN-FIRST(WS-NODE) TO WS-CRITERION
     END-IF
     PERFORM UNTIL WS-CRITERION = 0
         MOVE "trigger" TO WS-NAME
         CALL "RECIPE-GET-TEXT" USING JSON-DOC WS-CRITERION WS-NAME WS-TRIGGER WS-FOUND
         IF WS-TRIGGER NOT = "minecraft:recipe_unlocked"
             IF RC-UNLOCK-COUNT >= RC-MAX-UNLOCKS
                 MOVE "more than 4096 unlock conditions" TO WS-DETAIL
                 CALL "RECIPE-FAIL" USING WS-RECIPE WS-DETAIL
                 MOVE 1 TO L-STATUS
                 GOBACK
             END-IF
             ADD 1 TO RC-UNLOCK-COUNT
             MOVE WS-TRIGGER TO RU-TRIGGER(RC-UNLOCK-COUNT)
             MOVE SPACES TO RU-ITEMS(RC-UNLOCK-COUNT)
             IF RR-UNLOCK-N(WS-ROW) = 0
                 MOVE RC-UNLOCK-COUNT TO RR-UNLOCK-FIRST(WS-ROW)
             END-IF
             ADD 1 TO RR-UNLOCK-N(WS-ROW)
             IF WS-TRIGGER = "minecraft:inventory_changed"
                 CALL "RECIPE-UNLOCK-ITEMS" USING JSON-DOC WS-CRITERION WS-RECIPE WS-TEXT WS-STATUS
                 IF WS-STATUS NOT = 0
                     MOVE 1 TO L-STATUS
                     GOBACK
                 END-IF
                 MOVE WS-TEXT TO RU-ITEMS(RC-UNLOCK-COUNT)
             END-IF
         END-IF
         MOVE JN-NEXT(WS-CRITERION) TO WS-CRITERION
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPE-UNLOCK-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPES-FREE.
*> No parameters: empties RC-STORE (no recipe, no unlock condition). Safe with nothing loaded.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 PROCEDURE DIVISION.
     MOVE 0 TO RC-COUNT RC-UNLOCK-COUNT
     GOBACK.
 END PROGRAM RECIPES-FREE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPES-LOAD.
*> USING root (PIC X(1100), z-string or space padded: the folder that holds data/), status out (CT-OK, CT-BAD-DATA).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CTSTORE.
 COPY CTLOAD.
 COPY FORMATS.
 01 WS-DIR-Z               PIC X(1101).
 01 WS-DIR-LENGTH          BINARY-LONG.
 01 WS-PATH-STATUS         BINARY-LONG.
 01 WS-BASE                PIC X(1101).
 01 WS-MESSAGE             PIC X(200).
 01 WS-TABLE               USAGE POINTER.
 01 WS-SAVED-ADDR          USAGE POINTER.
 01 WS-SAVED-COUNT         BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-PAYLOAD             USAGE POINTER.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "RECIPES-FREE"
     MOVE 0 TO RS-ERRORS
     CALL "FILE-PATH-Z" USING L-DIR WS-DIR-Z WS-DIR-LENGTH WS-PATH-STATUS
     IF WS-PATH-STATUS NOT = FM-OK
         MOVE "recipes: the data directory path is too long" TO WS-MESSAGE
         CALL "RS-ERROR" USING WS-MESSAGE
         MOVE CT-BAD-DATA TO L-STATUS
         GOBACK
     END-IF
     MOVE LOW-VALUES TO WS-BASE
     STRING WS-DIR-Z(1:WS-DIR-LENGTH) "/data" DELIMITED BY SIZE INTO WS-BASE
*>   A private two-row registry table stands in for the set's (the set's own is put back afterwards).
     SET WS-SAVED-ADDR TO CT-REGISTRY-ADDR
     MOVE CT-REGISTRY-COUNT TO WS-SAVED-COUNT
     ALLOCATE LENGTH OF B-REGISTRIES CHARACTERS RETURNING WS-TABLE
     SET CT-REGISTRY-ADDR TO WS-TABLE
     SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
     PERFORM VARYING WS-SLOT FROM 1 BY 1 UNTIL WS-SLOT > 2
         MOVE SPACES TO BR-KEY(WS-SLOT)
         MOVE 0 TO BR-KEY-LENGTH(WS-SLOT) BR-ENTRY-COUNT(WS-SLOT) BR-PAYLOAD-LENGTH(WS-SLOT)
         SET BR-ENTRY-ADDR(WS-SLOT) TO NULL
         SET BR-PAYLOAD-ADDR(WS-SLOT) TO NULL
     END-PERFORM
     MOVE 2 TO CT-REGISTRY-COUNT
     MOVE 0 TO RS-MODE
     MOVE "recipe" TO WS-NAME
     MOVE 1 TO WS-SLOT
     CALL "REGISTRY-LOAD-ONE" USING WS-BASE WS-NAME WS-SLOT
     MOVE "advancement/recipes" TO WS-NAME
     MOVE 2 TO WS-SLOT
     CALL "REGISTRY-LOAD-ONE" USING WS-BASE WS-NAME WS-SLOT
*>   The recipes first (listing order), then the advancements that unlock them.
     SET ADDRESS OF B-REGISTRIES TO CT-REGISTRY-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-ENTRY-COUNT(1)
         SET ADDRESS OF B-ENTRIES TO BR-ENTRY-ADDR(1)
         MOVE BE-KEY(WS-I) TO WS-KEY
         MOVE BE-PAYLOAD-LENGTH(WS-I) TO WS-LENGTH
         SET WS-PAYLOAD TO BR-PAYLOAD-ADDR(1)
         SET WS-PAYLOAD UP BY BE-PAYLOAD-OFFSET(WS-I)
         CALL "RECIPE-PARSE" USING WS-KEY WS-PAYLOAD WS-LENGTH WS-STATUS
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BR-ENTRY-COUNT(2)
         SET ADDRESS OF B-ENTRIES TO BR-ENTRY-ADDR(2)
         MOVE BE-KEY(WS-I) TO WS-KEY
         MOVE BE-PAYLOAD-LENGTH(WS-I) TO WS-LENGTH
         SET WS-PAYLOAD TO BR-PAYLOAD-ADDR(2)
         SET WS-PAYLOAD UP BY BE-PAYLOAD-OFFSET(WS-I)
         CALL "RECIPE-UNLOCK-PARSE" USING WS-KEY WS-PAYLOAD WS-LENGTH WS-STATUS
     END-PERFORM
     CALL "REGISTRY-FREE"
     SET CT-REGISTRY-ADDR TO WS-SAVED-ADDR
     MOVE WS-SAVED-COUNT TO CT-REGISTRY-COUNT
     IF RS-ERRORS > 0
         CALL "RECIPES-FREE"
         MOVE CT-BAD-DATA TO L-STATUS
     ELSE
         MOVE CT-OK TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM RECIPES-LOAD.
