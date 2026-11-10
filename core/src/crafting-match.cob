*> Crafting matching over a crafting grid (docs/protocol/13 sections 3.2 to 3.4 and 3.6; 27 sections 1.3, 2.2, 2.3
*> and 6.1; US9, US10): the recipes come from the recipe store of the content set (RC-STORE, CTRECIPE.cpy: the
*> cobolcraft built-ins or the standard recipes), so the same code serves the 2 x 2 grid of the inventory menu and the
*> 3 x 3 grid of the crafting bench, and both world types.
*>
*> The grid is a table of item ids (0 = empty slot), row-major, width x height (2 x 2 or 3 x 3).
*> Shaped (serializer 0): the grid is trimmed to the bounding box of its non-empty slots; the recipe matches when the
*> number of non-empty slots equals the number of non-empty pattern cells, the trimmed size equals the pattern's and
*> every cell satisfies its ingredient (an empty pattern cell needs an empty slot); a pattern that is not left-right
*> symmetric is also tried mirrored horizontally, never vertically. Shapeless (serializer 1): the number of non-empty
*> slots equals the number of ingredients and every ingredient can be given a distinct slot (a bipartite matching,
*> solved by backtracking: an ingredient may accept several items). An ingredient is an item key, a "#" tag
*> reference, or several separated by spaces; only the item decides, never the count. The first recipe in store
*> order that matches wins (27 section 6.1); an empty grid matches nothing. Recipes of other serializers are not
*> offered here (27 sections 2.4 to 2.13 are not built yet).
*>
*> Taking the result (CRAFT-TAKE, 13 section 3.6) uses one item of every non-empty slot of the grid; no item in the
*> content tables has a crafting remainder, so none is returned.
*>
*> Entry points:
*>   CRAFT-ING-TEST USING item id (BINARY-LONG, 0 = empty), ingredient (PIC X(800)), result out (1 or 0)
*>   CRAFT-MATCH USING width, height, items (table of 9 BINARY-LONG), row out (the RC-STORE row, 0 = no recipe),
*>     result item out (BINARY-LONG), result count out (BINARY-LONG)
*>   CRAFT-TAKE USING width, height, items (table of 9), counts (table of 9): one item of each non-empty slot is
*>     used up (an emptied slot gets item 0)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-ING-TEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-REGISTRY            PIC X(48) VALUE "item".
 01 WS-TOKEN               PIC X(112).
 01 WS-KEY                 PIC X(112).
 01 WS-TAG                 PIC X(112).
 01 WS-POINTER             BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-TAGGED              BINARY-LONG.
 01 WS-REST                PIC X(112).
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-INGREDIENT           PIC X(800).
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-INGREDIENT L-RESULT.
     MOVE 0 TO L-RESULT
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     MOVE SPACES TO WS-KEY
     MOVE IT-KEY(L-ITEM + 1) TO WS-KEY
     IF WS-KEY(1:10) = "minecraft:"
         MOVE WS-KEY(11:102) TO WS-REST
         MOVE WS-REST TO WS-KEY
     END-IF
     COMPUTE WS-END = FUNCTION LENGTH(FUNCTION TRIM(L-INGREDIENT TRAILING))
     MOVE 1 TO WS-POINTER
     PERFORM UNTIL WS-POINTER > WS-END OR L-RESULT = 1
         MOVE SPACES TO WS-TOKEN
         UNSTRING L-INGREDIENT DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-POINTER
         IF WS-TOKEN(1:1) = "#"
             MOVE SPACES TO WS-TAG
             MOVE WS-TOKEN(2:111) TO WS-TAG
             CALL "CONTENT-TAG-HAS" USING WS-REGISTRY WS-TAG L-ITEM WS-TAGGED
             MOVE WS-TAGGED TO L-RESULT
         ELSE
             IF WS-TOKEN(1:10) = "minecraft:"
                 MOVE WS-TOKEN(11:102) TO WS-REST
                 MOVE WS-REST TO WS-TOKEN
             END-IF
             IF WS-TOKEN NOT = SPACES AND WS-TOKEN = WS-KEY
                 MOVE 1 TO L-RESULT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CRAFT-ING-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-MATCH-SHAPED.
*> USING recipe row, width, height, items, minimum row, minimum column, trimmed width, trimmed height, mirror (0 or
*> 1), result out: 1 when the trimmed grid satisfies the shaped recipe as it is (mirror 0) or mirrored (1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-ITEMS.
    05 L-ITEM              BINARY-LONG OCCURS 9 TIMES.
 01 L-MIN-ROW              BINARY-LONG.
 01 L-MIN-COL              BINARY-LONG.
 01 L-TRIM-W               BINARY-LONG.
 01 L-TRIM-H               BINARY-LONG.
 01 L-MIRROR               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WIDTH L-HEIGHT L-ITEMS L-MIN-ROW L-MIN-COL L-TRIM-W L-TRIM-H
         L-MIRROR L-RESULT.
     MOVE 1 TO L-RESULT
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R >= L-TRIM-H OR L-RESULT = 0
         PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C >= L-TRIM-W OR L-RESULT = 0
             IF L-MIRROR = 1
                 COMPUTE WS-CELL = WS-R * L-TRIM-W + (L-TRIM-W - 1 - WS-C) + 1
             ELSE
                 COMPUTE WS-CELL = WS-R * L-TRIM-W + WS-C + 1
             END-IF
             COMPUTE WS-SLOT = (L-MIN-ROW + WS-R) * L-WIDTH + L-MIN-COL + WS-C + 1
             IF RR-ING(L-ROW, WS-CELL) = SPACES
                 IF L-ITEM(WS-SLOT) NOT = 0
                     MOVE 0 TO L-RESULT
                 END-IF
             ELSE
                 CALL "CRAFT-ING-TEST" USING L-ITEM(WS-SLOT) RR-ING(L-ROW, WS-CELL) WS-OK
                 IF WS-OK = 0
                     MOVE 0 TO L-RESULT
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM CRAFT-MATCH-SHAPED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-MATCH-SHAPELESS.
*> USING recipe row, width, height, items, result out: 1 when every ingredient of the shapeless recipe can be given a
*> distinct non-empty slot and no non-empty slot is left over (backtracking).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ASSIGN.
    05 WS-A                BINARY-LONG OCCURS 9 TIMES.
 01 WS-USED.
    05 WS-U                BINARY-LONG OCCURS 9 TIMES.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-ITEMS.
    05 L-ITEM              BINARY-LONG OCCURS 9 TIMES.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-WIDTH L-HEIGHT L-ITEMS L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > L-WIDTH * L-HEIGHT
         MOVE 0 TO WS-U(WS-J)
         IF L-ITEM(WS-J) NOT = 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     IF WS-N = 0 OR WS-N NOT = RR-ING-COUNT(L-ROW)
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE 0 TO WS-A(WS-I)
     END-PERFORM
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I > WS-N OR WS-I < 1
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-J FROM WS-A(WS-I) BY 1 UNTIL WS-J >= L-WIDTH * L-HEIGHT OR WS-FOUND = 1
             IF WS-U(WS-J + 1) = 0 AND L-ITEM(WS-J + 1) NOT = 0
                 CALL "CRAFT-ING-TEST" USING L-ITEM(WS-J + 1) RR-ING(L-ROW, WS-I) WS-OK
                 IF WS-OK = 1
                     MOVE 1 TO WS-FOUND
                     COMPUTE WS-A(WS-I) = WS-J + 1
                     MOVE 1 TO WS-U(WS-J + 1)
                 END-IF
             END-IF
         END-PERFORM
         IF WS-FOUND = 1
             ADD 1 TO WS-I
             IF WS-I <= WS-N
                 MOVE 0 TO WS-A(WS-I)
             END-IF
         ELSE
             MOVE 0 TO WS-A(WS-I)
             SUBTRACT 1 FROM WS-I
             IF WS-I >= 1
                 MOVE 0 TO WS-U(WS-A(WS-I))
             END-IF
         END-IF
     END-PERFORM
     IF WS-I > WS-N
         MOVE 1 TO L-RESULT
     END-IF
     GOBACK.
 END PROGRAM CRAFT-MATCH-SHAPELESS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-MATCH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CTRECIPE.
 01 WS-R                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-MIN-ROW             BINARY-LONG.
 01 WS-MAX-ROW             BINARY-LONG.
 01 WS-MIN-COL             BINARY-LONG.
 01 WS-MAX-COL             BINARY-LONG.
 01 WS-TRIM-W              BINARY-LONG.
 01 WS-TRIM-H              BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-MATCHED             BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-ITEMS.
    05 L-ITEM              BINARY-LONG OCCURS 9 TIMES.
 01 L-ROW                  BINARY-LONG.
 01 L-RESULT-ITEM          BINARY-LONG.
 01 L-RESULT-COUNT         BINARY-LONG.
 PROCEDURE DIVISION USING L-WIDTH L-HEIGHT L-ITEMS L-ROW L-RESULT-ITEM L-RESULT-COUNT.
     MOVE 0 TO L-ROW L-RESULT-ITEM L-RESULT-COUNT
*>   The bounding box of the non-empty slots.
     MOVE 0 TO WS-N
     MOVE L-HEIGHT TO WS-MIN-ROW
     MOVE L-WIDTH TO WS-MIN-COL
     MOVE -1 TO WS-MAX-ROW WS-MAX-COL
     PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R >= L-HEIGHT
         PERFORM VARYING WS-C FROM 0 BY 1 UNTIL WS-C >= L-WIDTH
             COMPUTE WS-SLOT = WS-R * L-WIDTH + WS-C + 1
             IF L-ITEM(WS-SLOT) NOT = 0
                 ADD 1 TO WS-N
                 MOVE FUNCTION MIN(WS-MIN-ROW, WS-R) TO WS-MIN-ROW
                 MOVE FUNCTION MAX(WS-MAX-ROW, WS-R) TO WS-MAX-ROW
                 MOVE FUNCTION MIN(WS-MIN-COL, WS-C) TO WS-MIN-COL
                 MOVE FUNCTION MAX(WS-MAX-COL, WS-C) TO WS-MAX-COL
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-N = 0
         GOBACK
     END-IF
     COMPUTE WS-TRIM-W = WS-MAX-COL - WS-MIN-COL + 1
     COMPUTE WS-TRIM-H = WS-MAX-ROW - WS-MIN-ROW + 1
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RC-COUNT OR L-ROW > 0
         MOVE 0 TO WS-MATCHED
         IF RR-SERIALIZER(WS-K) = 0 AND RR-WIDTH(WS-K) = WS-TRIM-W AND RR-HEIGHT(WS-K) = WS-TRIM-H
*>           The number of non-empty pattern cells must equal the number of non-empty slots.
             MOVE 0 TO WS-CELLS
             PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > WS-TRIM-W * WS-TRIM-H
                 IF RR-ING(WS-K, WS-C) NOT = SPACES
                     ADD 1 TO WS-CELLS
                 END-IF
             END-PERFORM
             IF WS-CELLS = WS-N
                 MOVE 0 TO WS-R
                 CALL "CRAFT-MATCH-SHAPED" USING WS-K L-WIDTH L-HEIGHT L-ITEMS WS-MIN-ROW
                     WS-MIN-COL WS-TRIM-W WS-TRIM-H WS-R WS-MATCHED
                 IF WS-MATCHED = 0
                     MOVE 1 TO WS-R
                     CALL "CRAFT-MATCH-SHAPED" USING WS-K L-WIDTH L-HEIGHT L-ITEMS WS-MIN-ROW
                         WS-MIN-COL WS-TRIM-W WS-TRIM-H WS-R WS-MATCHED
                 END-IF
             END-IF
         END-IF
         IF RR-SERIALIZER(WS-K) = 1
             CALL "CRAFT-MATCH-SHAPELESS" USING WS-K L-WIDTH L-HEIGHT L-ITEMS WS-MATCHED
         END-IF
         IF WS-MATCHED = 1
             MOVE WS-K TO L-ROW
         END-IF
     END-PERFORM
     IF L-ROW > 0
         MOVE SPACES TO WS-KEY
         MOVE RR-RESULT-ID(L-ROW) TO WS-KEY
         CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ID WS-ITEM-ROW WS-STATUS
         MOVE WS-ID TO L-RESULT-ITEM
         MOVE RR-RESULT-COUNT(L-ROW) TO L-RESULT-COUNT
     END-IF
     GOBACK.
 END PROGRAM CRAFT-MATCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-TAKE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-J                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-WIDTH                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-ITEMS.
    05 L-ITEM              BINARY-LONG OCCURS 9 TIMES.
 01 L-COUNTS.
    05 L-COUNT             BINARY-LONG OCCURS 9 TIMES.
 PROCEDURE DIVISION USING L-WIDTH L-HEIGHT L-ITEMS L-COUNTS.
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > L-WIDTH * L-HEIGHT
         IF L-ITEM(WS-J) NOT = 0
             SUBTRACT 1 FROM L-COUNT(WS-J)
             IF L-COUNT(WS-J) <= 0
                 MOVE 0 TO L-COUNT(WS-J)
                 MOVE 0 TO L-ITEM(WS-J)
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CRAFT-TAKE.
