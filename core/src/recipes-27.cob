*> The recipe engine rules of docs/protocol/27-recipes-and-unlocks.md that sit beside the matching of crafting-match.cob:
*> section 1 (types and serializers), section 2 (the crafting families beyond shaped and shapeless), section 3 (the other
*> families), section 4 (the recipe book of a player and the display ids), section 5 (advancement progress) and section 6
*> (lookup). The recipes are rows of RC-STORE (CTRECIPE.cpy). Every program is pure over its parameters and the stores.
*>
*> Section 1:
*>   RECIPE-SERIALIZER-TYPE USING serializer id, type id out (0 crafting, 1 smelting, 2 blasting, 3 smoking,
*>     4 campfire_cooking, 5 stonecutting, 6 smithing, 7 brewing; -1 for an id that is not a serializer)
*>   RECIPE-TYPE-NAME USING type id, name out (PIC X(16), spaces when unknown)
*>   RECIPE-SERIALIZER-ID USING name (PIC X(40)), id out (-1 when unknown)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-SERIALIZER-TYPE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-SERIALIZER           BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SERIALIZER L-TYPE.
     EVALUATE TRUE
         WHEN L-SERIALIZER >= 0 AND L-SERIALIZER <= 13
             MOVE 0 TO L-TYPE
         WHEN L-SERIALIZER >= 14 AND L-SERIALIZER <= 18
             COMPUTE L-TYPE = L-SERIALIZER - 13
         WHEN L-SERIALIZER = 19 OR L-SERIALIZER = 21
             MOVE 6 TO L-TYPE
         WHEN L-SERIALIZER = 20
             MOVE 7 TO L-TYPE
         WHEN OTHER
             MOVE -1 TO L-TYPE
     END-EVALUATE
     GOBACK.
 END PROGRAM RECIPE-SERIALIZER-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-TYPE-NAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(16).
 PROCEDURE DIVISION USING L-TYPE L-NAME.
     EVALUATE L-TYPE
         WHEN 0 MOVE "crafting" TO L-NAME
         WHEN 1 MOVE "smelting" TO L-NAME
         WHEN 2 MOVE "blasting" TO L-NAME
         WHEN 3 MOVE "smoking" TO L-NAME
         WHEN 4 MOVE "campfire_cooking" TO L-NAME
         WHEN 5 MOVE "stonecutting" TO L-NAME
         WHEN 6 MOVE "smithing" TO L-NAME
         WHEN 7 MOVE "brewing" TO L-NAME
         WHEN OTHER MOVE SPACES TO L-NAME
     END-EVALUATE
     GOBACK.
 END PROGRAM RECIPE-TYPE-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-SERIALIZER-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES-DATA.
    05 FILLER PIC X(40) VALUE "crafting_shaped".
    05 FILLER PIC X(40) VALUE "crafting_shapeless".
    05 FILLER PIC X(40) VALUE "crafting_dye".
    05 FILLER PIC X(40) VALUE "crafting_imbue".
    05 FILLER PIC X(40) VALUE "crafting_transmute".
    05 FILLER PIC X(40) VALUE "crafting_decorated_pot".
    05 FILLER PIC X(40) VALUE "crafting_special_bookcloning".
    05 FILLER PIC X(40) VALUE "crafting_special_mapextending".
    05 FILLER PIC X(40) VALUE "crafting_special_firework_rocket".
    05 FILLER PIC X(40) VALUE "crafting_special_firework_star".
    05 FILLER PIC X(40) VALUE "crafting_special_firework_star_fade".
    05 FILLER PIC X(40) VALUE "crafting_special_bannerduplicate".
    05 FILLER PIC X(40) VALUE "crafting_special_shielddecoration".
    05 FILLER PIC X(40) VALUE "crafting_special_repairitem".
    05 FILLER PIC X(40) VALUE "smelting".
    05 FILLER PIC X(40) VALUE "blasting".
    05 FILLER PIC X(40) VALUE "smoking".
    05 FILLER PIC X(40) VALUE "campfire_cooking".
    05 FILLER PIC X(40) VALUE "stonecutting".
    05 FILLER PIC X(40) VALUE "smithing_transform".
    05 FILLER PIC X(40) VALUE "brewing".
    05 FILLER PIC X(40) VALUE "smithing_trim".
 01 WS-NAMES REDEFINES WS-NAMES-DATA.
    05 WS-NAME             PIC X(40) OCCURS 22 TIMES.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(40).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID.
     MOVE -1 TO L-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 22 OR L-ID >= 0
         IF WS-NAME(WS-I) = L-NAME
             COMPUTE L-ID = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPE-SERIALIZER-ID.

*> Section 2 (crafting recipes beyond shaped and shapeless). Grids are tables of 9 item ids, 0 = empty (the slots of a
*> 3 x 3 grid row by row; a smaller grid fills the first slots), as CRAFT-MATCH takes them.
*>   RECIPE-TRANSMUTE-MATCH USING recipe row, items, matched out (1 or 0), result count out (2.4)
*>   RECIPE-REPAIR USING max damage A, damage A, max damage B, damage B, max damage out, damage out (2.13)
*>   RECIPE-CENTRE-MATCH USING items, source ingredient, material ingredient, matched out (2.9)
*>   RECIPE-POT-MATCH USING items, ingredient, matched out (2.10)
*>   RECIPE-ROCKET-MATCH USING items, shell, fuel, star ingredients, matched out, flight duration out (2.12)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-TRANSMUTE-MATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 COPY CITEMS.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-INPUTS              BINARY-LONG.
 01 WS-MATERIALS           BINARY-LONG.
 01 WS-INPUT-ITEM          BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-RESULT-KEY          PIC X(800).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEMS.
    05 L-ITEM              BINARY-LONG OCCURS 9 TIMES.
 01 L-MATCHED              BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEMS L-MATCHED L-COUNT.
     MOVE 0 TO L-MATCHED L-COUNT WS-N WS-INPUTS WS-MATERIALS WS-BAD WS-INPUT-ITEM
     MOVE RR-MATERIAL-MIN(L-ROW) TO WS-MIN
     MOVE RR-MATERIAL-MAX(L-ROW) TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF L-ITEM(WS-I) NOT = 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     COMPUTE WS-LIMIT = WS-MIN + 1
     IF WS-N < WS-LIMIT
         GOBACK
     END-IF
     COMPUTE WS-LIMIT = WS-MAX + 1
     IF WS-N > WS-LIMIT
         GOBACK
     END-IF
*>   The input is tested first, so an item accepted by both is the input.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF L-ITEM(WS-I) NOT = 0
             CALL "CRAFT-ING-TEST" USING L-ITEM(WS-I) RR-ING(L-ROW, 1) WS-PASS
             IF WS-PASS = 1
                 ADD 1 TO WS-INPUTS
                 MOVE L-ITEM(WS-I) TO WS-INPUT-ITEM
             ELSE
                 CALL "CRAFT-ING-TEST" USING L-ITEM(WS-I) RR-ING(L-ROW, 2) WS-PASS
                 IF WS-PASS = 1
                     ADD 1 TO WS-MATERIALS
                 ELSE
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-INPUTS NOT = 1 OR WS-BAD > 0 OR WS-MATERIALS < WS-MIN OR WS-MATERIALS > WS-MAX
         GOBACK
     END-IF
     MOVE 0 TO WS-ADD
     IF RR-ADD-COUNT(L-ROW) = 1
         MOVE WS-MATERIALS TO WS-ADD
     END-IF
     COMPUTE WS-SIZE = RR-RESULT-COUNT(L-ROW) + WS-ADD
     IF WS-SIZE = 1
*>       A result that is empty or the input's own item is refused; an absent result id keeps the input's item.
         MOVE 1 TO WS-SAME
         IF RR-RESULT-ID(L-ROW) NOT = SPACES
             MOVE RR-RESULT-ID(L-ROW) TO WS-RESULT-KEY
             CALL "CRAFT-ING-TEST" USING WS-INPUT-ITEM WS-RESULT-KEY WS-SAME
         END-IF
         IF WS-SAME = 1
             GOBACK
         END-IF
     END-IF
     MOVE 1 TO L-MATCHED
     MOVE WS-SIZE TO L-COUNT
     GOBACK.
 END PROGRAM RECIPE-TRANSMUTE-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-REPAIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REMAINING           BINARY-LONG.
 01 WS-FIVE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-MAX-A                BINARY-LONG.
 01 L-DMG-A                BINARY-LONG.
 01 L-MAX-B                BINARY-LONG.
 01 L-DMG-B                BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-DMG                  BINARY-LONG.
 PROCEDURE DIVISION USING L-MAX-A L-DMG-A L-MAX-B L-DMG-B L-MAX L-DMG.
     MOVE FUNCTION MAX(L-MAX-A, L-MAX-B) TO L-MAX
     COMPUTE WS-FIVE = L-MAX * 5
     COMPUTE WS-REMAINING = L-MAX-A - L-DMG-A + L-MAX-B - L-DMG-B + WS-FIVE / 100
     COMPUTE L-DMG = FUNCTION MAX(L-MAX - WS-REMAINING, 0)
     GOBACK.
 END PROGRAM RECIPE-REPAIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-CENTRE-MATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEMS.
    05 L-ITEM              BINARY-LONG OCCURS 9 TIMES.
 01 L-SOURCE               PIC X(800).
 01 L-MATERIAL             PIC X(800).
 01 L-MATCHED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEMS L-SOURCE L-MATERIAL L-MATCHED.
     MOVE 0 TO L-MATCHED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF L-ITEM(WS-I) = 0
             GOBACK
         END-IF
         IF WS-I = 5
             CALL "CRAFT-ING-TEST" USING L-ITEM(WS-I) L-SOURCE WS-PASS
         ELSE
             CALL "CRAFT-ING-TEST" USING L-ITEM(WS-I) L-MATERIAL WS-PASS
         END-IF
         IF WS-PASS = 0
             GOBACK
         END-IF
     END-PERFORM
     MOVE 1 TO L-MATCHED
     GOBACK.
 END PROGRAM RECIPE-CENTRE-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-POT-MATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEMS.
    05 L-ITEM              BINARY-LONG OCCURS 9 TIMES.
 01 L-INGREDIENT           PIC X(800).
 01 L-MATCHED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEMS L-INGREDIENT L-MATCHED.
     MOVE 0 TO L-MATCHED WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF L-ITEM(WS-I) NOT = 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N NOT = 4
         GOBACK
     END-IF
*>   Back (1, 0), left (0, 1), right (2, 1), front (1, 2): slots 2, 4, 6 and 8.
     PERFORM VARYING WS-I FROM 2 BY 2 UNTIL WS-I > 8
         CALL "CRAFT-ING-TEST" USING L-ITEM(WS-I) L-INGREDIENT WS-PASS
         IF WS-PASS = 0
             GOBACK
         END-IF
     END-PERFORM
     MOVE 1 TO L-MATCHED
     GOBACK.
 END PROGRAM RECIPE-POT-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-ROCKET-MATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SHELLS              BINARY-LONG.
 01 WS-FUEL                BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEMS.
    05 L-ITEM              BINARY-LONG OCCURS 9 TIMES.
 01 L-SHELL                PIC X(800).
 01 L-FUEL                 PIC X(800).
 01 L-STAR                 PIC X(800).
 01 L-MATCHED              BINARY-LONG.
 01 L-FLIGHT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEMS L-SHELL L-FUEL L-STAR L-MATCHED L-FLIGHT.
     MOVE 0 TO L-MATCHED L-FLIGHT WS-N WS-SHELLS WS-FUEL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         IF L-ITEM(WS-I) NOT = 0
             ADD 1 TO WS-N
             CALL "CRAFT-ING-TEST" USING L-ITEM(WS-I) L-SHELL WS-PASS
             IF WS-PASS = 1
                 ADD 1 TO WS-SHELLS
             ELSE
                 CALL "CRAFT-ING-TEST" USING L-ITEM(WS-I) L-FUEL WS-PASS
                 IF WS-PASS = 1
                     ADD 1 TO WS-FUEL
                 ELSE
                     CALL "CRAFT-ING-TEST" USING L-ITEM(WS-I) L-STAR WS-PASS
                     IF WS-PASS = 0
                         GOBACK
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-N < 2 OR WS-SHELLS NOT = 1 OR WS-FUEL < 1 OR WS-FUEL > 3
         GOBACK
     END-IF
     MOVE 1 TO L-MATCHED
     MOVE WS-FUEL TO L-FLIGHT
     GOBACK.
 END PROGRAM RECIPE-ROCKET-MATCH.

*> Section 3 (the other families).
*>   RECIPE-BOOK-CATEGORY USING serializer id, category name (PIC X(24): building, redstone, equipment, misc, food,
*>     blocks), category id out (the 13 recipe book categories of 4.1; 3 for an unknown crafting category)
*>   RECIPE-STONECUT-VALID USING button index, option count, current index, valid out (3.2)
*>   RECIPE-TRIM-REFUSED USING base pattern, base material (0 = the base has no trim), new pattern, new material,
*>     refused out (3.3)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-BOOK-CATEGORY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TYPE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-SERIALIZER           BINARY-LONG.
 01 L-NAME                 PIC X(24).
 01 L-CATEGORY             BINARY-LONG.
 PROCEDURE DIVISION USING L-SERIALIZER L-NAME L-CATEGORY.
     CALL "RECIPE-SERIALIZER-TYPE" USING L-SERIALIZER WS-TYPE
     EVALUATE WS-TYPE
         WHEN 0
             EVALUATE L-NAME
                 WHEN "building" MOVE 0 TO L-CATEGORY
                 WHEN "redstone" MOVE 1 TO L-CATEGORY
                 WHEN "equipment" MOVE 2 TO L-CATEGORY
                 WHEN OTHER MOVE 3 TO L-CATEGORY
             END-EVALUATE
         WHEN 1
             EVALUATE L-NAME
                 WHEN "food" MOVE 4 TO L-CATEGORY
                 WHEN "blocks" MOVE 5 TO L-CATEGORY
                 WHEN OTHER MOVE 6 TO L-CATEGORY
             END-EVALUATE
         WHEN 2
             IF L-NAME = "blocks"
                 MOVE 7 TO L-CATEGORY
             ELSE
                 MOVE 8 TO L-CATEGORY
             END-IF
         WHEN 3
             MOVE 9 TO L-CATEGORY
         WHEN 4
             MOVE 12 TO L-CATEGORY
         WHEN 5
             MOVE 10 TO L-CATEGORY
         WHEN 6
             MOVE 11 TO L-CATEGORY
         WHEN OTHER
             MOVE 3 TO L-CATEGORY
     END-EVALUATE
     GOBACK.
 END PROGRAM RECIPE-BOOK-CATEGORY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-STONECUT-VALID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-OPTIONS              BINARY-LONG.
 01 L-CURRENT              BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-OPTIONS L-CURRENT L-VALID.
     MOVE 0 TO L-VALID
     IF L-INDEX >= 0 AND L-INDEX < L-OPTIONS AND L-INDEX NOT = L-CURRENT
         MOVE 1 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM RECIPE-STONECUT-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-TRIM-REFUSED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-BASE-PATTERN         BINARY-LONG.
 01 L-BASE-MATERIAL        BINARY-LONG.
 01 L-PATTERN              BINARY-LONG.
 01 L-MATERIAL             BINARY-LONG.
 01 L-REFUSED              BINARY-LONG.
 PROCEDURE DIVISION USING L-BASE-PATTERN L-BASE-MATERIAL L-PATTERN L-MATERIAL L-REFUSED.
     MOVE 0 TO L-REFUSED
     IF L-BASE-PATTERN > 0 AND L-BASE-PATTERN = L-PATTERN AND L-BASE-MATERIAL = L-MATERIAL
         MOVE 1 TO L-REFUSED
     END-IF
     GOBACK.
 END PROGRAM RECIPE-TRIM-REFUSED.

*> Section 4 (recipe book and unlocking). The book of a player row is RB-PLAYER of RECBOOK.cpy; a recipe is a row of RC-STORE.
*>   RECBOOK-RESET USING player row: an empty book, settings off
*>   RECBOOK-ADD USING player row, recipe row, added out: 1 when the recipe was not known and not special (it becomes
*>     known and highlighted, 4.4 addRecipes)
*>   RECBOOK-REMOVE USING player row, recipe row, removed out: 1 when it was known (4.4 removeRecipes)
*>   RECBOOK-CONTAINS USING player row, recipe row, known out
*>   RECBOOK-SEEN USING player row, recipe row: the highlight is removed (4.4 removeHighlight)
*>   RECBOOK-SETTING USING player row, book type (0 to 3), open, filtering (4.4 setBookSetting)
*>   RECBOOK-COPY USING from player row, to player row: the book is copied over (4.4 copyOverData)
*>   RECIPE-DISPLAY-COUNT USING recipe row, count out: the displays of a recipe (one per material count of a transmute)
*>   RECIPE-DISPLAY-FIRST USING recipe row, first display id out (4.2: ids are contiguous in row order)
*>   RECIPE-DISPLAY-ROW USING display id, recipe row out (0 = none), display index within the recipe out
*>   RECIPE-GROUP-NUMBER USING recipe row, wire group out (0 = none, else the first-seen index + 1, 4.2 step 2)
*>   RECIPE-LIMITED-USABLE USING limited_crafting rule, special, known, usable out (4.5)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECBOOK-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RECBOOK.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     INITIALIZE RB-PLAYER(L-ROW)
     GOBACK.
 END PROGRAM RECBOOK-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECBOOK-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RECBOOK.
 COPY CTRECIPE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RECIPE               BINARY-LONG.
 01 L-ADDED                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RECIPE L-ADDED.
     MOVE 0 TO L-ADDED
     IF L-RECIPE >= 1 AND L-RECIPE <= RC-COUNT AND RR-SPECIAL(L-RECIPE) = 0
             AND RB-KNOWN(L-ROW, L-RECIPE) = 0
         MOVE 1 TO RB-KNOWN(L-ROW, L-RECIPE) RB-HIGHLIGHT(L-ROW, L-RECIPE) RB-PENDING(L-ROW, L-RECIPE)
                 L-ADDED
     END-IF
     GOBACK.
 END PROGRAM RECBOOK-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECBOOK-REMOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RECBOOK.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RECIPE               BINARY-LONG.
 01 L-REMOVED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RECIPE L-REMOVED.
     MOVE 0 TO L-REMOVED
     IF L-RECIPE >= 1 AND L-RECIPE <= 4096
         IF RB-KNOWN(L-ROW, L-RECIPE) = 1
             MOVE 0 TO RB-KNOWN(L-ROW, L-RECIPE) RB-HIGHLIGHT(L-ROW, L-RECIPE) RB-PENDING(L-ROW, L-RECIPE)
             MOVE 1 TO L-REMOVED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RECBOOK-REMOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECBOOK-CONTAINS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RECBOOK.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RECIPE               BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RECIPE L-KNOWN.
     MOVE 0 TO L-KNOWN
     IF L-RECIPE >= 1 AND L-RECIPE <= 4096
         MOVE RB-KNOWN(L-ROW, L-RECIPE) TO L-KNOWN
     END-IF
     GOBACK.
 END PROGRAM RECBOOK-CONTAINS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECBOOK-SEEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RECBOOK.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RECIPE               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RECIPE.
     IF L-RECIPE >= 1 AND L-RECIPE <= 4096
         MOVE 0 TO RB-HIGHLIGHT(L-ROW, L-RECIPE)
     END-IF
     GOBACK.
 END PROGRAM RECBOOK-SEEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECBOOK-SETTING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RECBOOK.
 01 WS-T                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-OPEN                 BINARY-LONG.
 01 L-FILTER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TYPE L-OPEN L-FILTER.
     IF L-TYPE >= 0 AND L-TYPE <= 3
         COMPUTE WS-T = L-TYPE + 1
         MOVE L-OPEN TO RB-OPEN(L-ROW, WS-T)
         MOVE L-FILTER TO RB-FILTER(L-ROW, WS-T)
     END-IF
     GOBACK.
 END PROGRAM RECBOOK-SETTING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECBOOK-COPY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY RECBOOK.
 LINKAGE SECTION.
 01 L-FROM                 BINARY-LONG.
 01 L-TO                   BINARY-LONG.
 PROCEDURE DIVISION USING L-FROM L-TO.
     MOVE RB-PLAYER(L-FROM) TO RB-PLAYER(L-TO)
     GOBACK.
 END PROGRAM RECBOOK-COPY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-DISPLAY-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 LINKAGE SECTION.
 01 L-RECIPE               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-RECIPE L-COUNT.
     MOVE 1 TO L-COUNT
     IF RR-SERIALIZER(L-RECIPE) = 4
         COMPUTE L-COUNT = RR-MATERIAL-MAX(L-RECIPE) - RR-MATERIAL-MIN(L-RECIPE) + 1
     END-IF
     GOBACK.
 END PROGRAM RECIPE-DISPLAY-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-DISPLAY-FIRST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-RECIPE               BINARY-LONG.
 01 L-FIRST                BINARY-LONG.
 PROCEDURE DIVISION USING L-RECIPE L-FIRST.
     MOVE 0 TO L-FIRST
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K >= L-RECIPE
         CALL "RECIPE-DISPLAY-COUNT" USING WS-K WS-N
         ADD WS-N TO L-FIRST
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPE-DISPLAY-FIRST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-DISPLAY-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DISPLAY              BINARY-LONG.
 01 L-RECIPE               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-DISPLAY L-RECIPE L-INDEX.
     MOVE 0 TO L-RECIPE L-INDEX WS-FIRST
     IF L-DISPLAY < 0
         GOBACK
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT OR L-RECIPE > 0
         CALL "RECIPE-DISPLAY-COUNT" USING WS-K WS-N
         IF L-DISPLAY < WS-FIRST + WS-N
             MOVE WS-K TO L-RECIPE
             COMPUTE L-INDEX = L-DISPLAY - WS-FIRST
         END-IF
         ADD WS-N TO WS-FIRST
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPE-DISPLAY-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-GROUP-NUMBER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 LINKAGE SECTION.
 01 L-RECIPE               BINARY-LONG.
 01 L-GROUP                BINARY-LONG.
 PROCEDURE DIVISION USING L-RECIPE L-GROUP.
     MOVE 0 TO L-GROUP WS-N
     IF RR-GROUP(L-RECIPE) = SPACES
         GOBACK
     END-IF
*>   Count the distinct groups first seen before the first row that has this group.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > L-RECIPE OR L-GROUP > 0
         IF RR-GROUP(WS-K) NOT = SPACES
             MOVE 0 TO WS-SEEN
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-K
                 IF RR-GROUP(WS-J) = RR-GROUP(WS-K)
                     MOVE 1 TO WS-SEEN
                 END-IF
             END-PERFORM
             IF WS-SEEN = 0
                 ADD 1 TO WS-N
                 IF RR-GROUP(WS-K) = RR-GROUP(L-RECIPE)
                     MOVE WS-N TO L-GROUP
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPE-GROUP-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-LIMITED-USABLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-RULE                 BINARY-LONG.
 01 L-SPECIAL              BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 01 L-USABLE               BINARY-LONG.
 PROCEDURE DIVISION USING L-RULE L-SPECIAL L-KNOWN L-USABLE.
     MOVE 0 TO L-USABLE
     IF L-SPECIAL = 1 OR L-RULE = 0 OR L-KNOWN = 1
         MOVE 1 TO L-USABLE
     END-IF
     GOBACK.
 END PROGRAM RECIPE-LIMITED-USABLE.

*> Section 5 (advancement progress, 5.4). Up to 4 requirement groups of up to 8 criteria: MEMBERS(n) = 1 when criterion
*> c belongs to group g, n = (g - 1) * 8 + c; DONE(c) = 1 when criterion c is done.
*>   ADV-SATISFIED USING groups, members, done, satisfied groups out, advancement done out (no groups: never done)
*>   ADV-PERCENT USING criteria count, groups, satisfied groups, percent out (0 with no criteria)
*>   ADV-AWARD USING criterion, criteria count, groups, members, done (updated), changed out, completed out (1 when the
*>     advancement was not done before and is now: its rewards are granted, 5.5)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ADV-SATISFIED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-G                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-HIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-GROUPS               BINARY-LONG.
 01 L-MEMBERS.
    05 L-M                 PIC 9 OCCURS 32 TIMES.
 01 L-DONE.
    05 L-D                 PIC 9 OCCURS 8 TIMES.
 01 L-SATISFIED            BINARY-LONG.
 01 L-IS-DONE              BINARY-LONG.
 PROCEDURE DIVISION USING L-GROUPS L-MEMBERS L-DONE L-SATISFIED L-IS-DONE.
     MOVE 0 TO L-SATISFIED L-IS-DONE
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > L-GROUPS
         MOVE 0 TO WS-HIT
         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 8
             COMPUTE WS-N = (WS-G - 1) * 8 + WS-C
             IF L-M(WS-N) = 1 AND L-D(WS-C) = 1
                 MOVE 1 TO WS-HIT
             END-IF
         END-PERFORM
         ADD WS-HIT TO L-SATISFIED
     END-PERFORM
     IF L-GROUPS > 0 AND L-SATISFIED = L-GROUPS
         MOVE 1 TO L-IS-DONE
     END-IF
     GOBACK.
 END PROGRAM ADV-SATISFIED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ADV-PERCENT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HUNDRED             BINARY-LONG.
 LINKAGE SECTION.
 01 L-CRITERIA             BINARY-LONG.
 01 L-GROUPS               BINARY-LONG.
 01 L-SATISFIED            BINARY-LONG.
 01 L-PERCENT              BINARY-LONG.
 PROCEDURE DIVISION USING L-CRITERIA L-GROUPS L-SATISFIED L-PERCENT.
     MOVE 0 TO L-PERCENT
     IF L-CRITERIA > 0 AND L-GROUPS > 0
         COMPUTE WS-HUNDRED = L-SATISFIED * 100
         DIVIDE WS-HUNDRED BY L-GROUPS GIVING L-PERCENT
     END-IF
     GOBACK.
 END PROGRAM ADV-PERCENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ADV-AWARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SATISFIED           BINARY-LONG.
 01 WS-WAS                 BINARY-LONG.
 01 WS-NOW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-CRITERION            BINARY-LONG.
 01 L-CRITERIA             BINARY-LONG.
 01 L-GROUPS               BINARY-LONG.
 01 L-MEMBERS.
    05 L-M                 PIC 9 OCCURS 32 TIMES.
 01 L-DONE.
    05 L-D                 PIC 9 OCCURS 8 TIMES.
 01 L-CHANGED              BINARY-LONG.
 01 L-COMPLETED            BINARY-LONG.
 PROCEDURE DIVISION USING L-CRITERION L-CRITERIA L-GROUPS L-MEMBERS L-DONE L-CHANGED L-COMPLETED.
     MOVE 0 TO L-CHANGED L-COMPLETED
     IF L-CRITERION < 1 OR L-CRITERION > L-CRITERIA OR L-CRITERION > 8
         GOBACK
     END-IF
     IF L-D(L-CRITERION) = 1
         GOBACK
     END-IF
     CALL "ADV-SATISFIED" USING L-GROUPS L-MEMBERS L-DONE WS-SATISFIED WS-WAS
     MOVE 1 TO L-D(L-CRITERION) L-CHANGED
     CALL "ADV-SATISFIED" USING L-GROUPS L-MEMBERS L-DONE WS-SATISFIED WS-NOW
     IF WS-WAS = 0 AND WS-NOW = 1
         MOVE 1 TO L-COMPLETED
     END-IF
     GOBACK.
 END PROGRAM ADV-AWARD.

*> Section 6 (lookup). The first recipe in store order that matches wins (CRAFT-MATCH, crafting-match.cob).
*>   RECIPE-BY-KEY USING key (PIC X(112)), recipe row out (0 = none)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RECIPE-BY-KEY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(112).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT OR L-ROW > 0
         IF RR-KEY(WS-K) = L-KEY
             MOVE WS-K TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM RECIPE-BY-KEY.
