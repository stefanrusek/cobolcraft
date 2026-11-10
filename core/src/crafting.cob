*> Crafting (US10; data-model §8; standin-content §13; docs/protocol/09-cobolcraft-profile.md §3.2
*> join sequence, §3.3 Crafting rows, Open question 3; 05b 0x4B; 05c 0x27).
*>
*> A recipe (core/copy/RECIPES.cpy) is craftable for a player when the inventory holds every
*> ingredient count and the result fits after the ingredients are removed. Ingredients are taken
*> from the slots in slot order (0 to 35) and the result is added by the inventory add rule
*> (INV-ADD). Crafting works the same in both game modes and needs no block.
*>
*> Recipe book: Recipe Book Add (0x4B, Replace = true) holds one entry per recipe in display-id
*> order: RecipeDisplay crafting_shapeless with one item_stack SlotDisplay per ingredient line, the
*> result as item_stack, an empty crafting station, group 0, category 0, crafting requirements
*> (one HolderSet of the single item per ingredient line) present exactly when the recipe is
*> craftable, flags 0. It is sent in the join sequence after Login (PLAY-JOIN) and again whenever
*> the player's inventory differs from the one the last book was computed from: CRAFT-REFRESH-ALL
*> runs after every serverbound play packet (PLAY-PACKET) and at the end of the game rules of every
*> tick (CORE-TICK), so changes made by packets and by ticks are both seen.
*>
*> Place Recipe (0x27; container 0, a display id 0 to 8; "use max items" is ignored: one craft per
*> packet) crafts the recipe once, atomically: all ingredients are removed and the result added, or
*> nothing changes (missing ingredients, US10-3; no room for the result, US10-4). On a craft the
*> container's state id is raised by one and every changed slot is echoed with Container Set Slot.
*> Another container id or display id is ignored.
*>
*> Entry points:
*>   CRAFT-TRY USING player row, display id, commit (BINARY-LONG), outcome out (BINARY-LONG)
*>     outcome 1 when craftable; with commit 1 the craft is kept, otherwise the inventory is left
*>     as it was
*>   CRAFT-BOOK-BUILD USING player row, PB-BUFFER     appends Recipe Book Add for the player
*>   CRAFT-BOOK-SEND USING player row                 sends it and remembers the inventory
*>   CRAFT-REFRESH-ALL                                re-sends the book to each player whose
*>                                                    inventory changed since their last book
*>   CRAFT-PLACE USING connection id, PLAY-SERVERBOUND   Place Recipe

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-TRY.
*> USING player row, display id, commit, outcome out (BINARY-LONG): see above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-SAVED               PIC X(288).
 01 WS-R                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NEED                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-RECIPE               BINARY-LONG.
 01 L-COMMIT               BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-RECIPE L-COMMIT L-OUTCOME.
     MOVE PL-INVENTORY(L-ROW) TO WS-SAVED
     MOVE 1 TO L-OUTCOME
     COMPUTE WS-R = L-RECIPE + 1
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > RP-LINE-COUNT(WS-R)
         MOVE RP-IN-COUNT(WS-R, WS-L) TO WS-NEED
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36 OR WS-NEED = 0
             IF PL-SLOT-ITEM(L-ROW, WS-S) = RP-IN-ITEM(WS-R, WS-L)
                 MOVE PL-SLOT-COUNT(L-ROW, WS-S) TO WS-HAVE
                 COMPUTE WS-N = FUNCTION MIN(WS-NEED, WS-HAVE)
                 COMPUTE WS-SLOT = WS-S - 1
                 CALL "INV-REMOVE" USING L-ROW WS-SLOT WS-N
                 SUBTRACT WS-N FROM WS-NEED
             END-IF
         END-PERFORM
         IF WS-NEED > 0
             MOVE 0 TO L-OUTCOME
         END-IF
     END-PERFORM
     IF L-OUTCOME = 1
         CALL "INV-ADD" USING L-ROW RP-RESULT-ITEM(WS-R) RP-RESULT-COUNT(WS-R) WS-LEFT
         IF WS-LEFT > 0
             MOVE 0 TO L-OUTCOME
         END-IF
     END-IF
     IF L-OUTCOME = 0 OR L-COMMIT = 0
         MOVE WS-SAVED TO PL-INVENTORY(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM CRAFT-TRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-BOOK-BUILD.
*> USING player row (BINARY-LONG), PB-BUFFER: appends Recipe Book Add 0x4B (05b: Prefixed Array of
*> RecipeBookAddEntry (RecipeDisplayEntry, Byte flags), Boolean replace) as described above.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 01 WS-PACKET-ID           BINARY-LONG VALUE 75.
 01 WS-COUNT               BINARY-LONG VALUE 9.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-REPLACE             BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-R                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW PB-BUFFER.
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COUNT
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > RP-COUNT
         INITIALIZE WK-RECIPE-DISPLAY
         COMPUTE WS-ID = WS-R - 1
         MOVE WS-ID TO WK-RD-DISPLAY-ID
         MOVE PB-RECIPE-SHAPELESS TO WK-RD-TYPE
         MOVE RP-LINE-COUNT(WS-R) TO WK-RD-INGREDIENT-COUNT WK-RD-REQ-COUNT
         PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > RP-LINE-COUNT(WS-R)
             MOVE PB-SLOT-ITEM-STACK TO WK-RD-IN-TYPE(WS-L)
             MOVE RP-IN-ITEM(WS-R, WS-L) TO WK-RD-IN-ITEM(WS-L) WK-RD-REQ-ITEM(WS-L)
             MOVE RP-IN-COUNT(WS-R, WS-L) TO WK-RD-IN-COUNT(WS-L)
         END-PERFORM
         MOVE PB-SLOT-ITEM-STACK TO WK-RD-RES-TYPE
         MOVE RP-RESULT-ITEM(WS-R) TO WK-RD-RES-ITEM
         MOVE RP-RESULT-COUNT(WS-R) TO WK-RD-RES-COUNT
         MOVE PB-SLOT-EMPTY TO WK-RD-ST-TYPE
         CALL "CRAFT-TRY" USING L-ROW WS-ID WS-ZERO WS-OUTCOME
         MOVE WS-OUTCOME TO WK-RD-REQ-PRESENT
         CALL "PB-PUT-RECIPE-DISPLAY" USING PB-BUFFER WK-RECIPE-DISPLAY
         CALL "PB-PUT-BYTE" USING PB-BUFFER WS-FLAGS
     END-PERFORM
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-REPLACE
     GOBACK.
 END PROGRAM CRAFT-BOOK-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-BOOK-SEND.
*> USING player row (BINARY-LONG): sends the player's connection Recipe Book Add and remembers the
*> inventory it was computed from (PL-BOOK-INVENTORY, PL-BOOK-SENT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "CRAFT-BOOK-BUILD" USING L-ROW PB-BUFFER
     CALL "CORE-SEND" USING PL-CONN(L-ROW) PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     MOVE PL-INVENTORY(L-ROW) TO PL-BOOK-INVENTORY(L-ROW)
     MOVE 1 TO PL-BOOK-SENT(L-ROW)
     GOBACK.
 END PROGRAM CRAFT-BOOK-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-REFRESH-ALL.
*> Re-sends the recipe book to every player whose book was sent and whose inventory has changed
*> since.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-BOOK-SENT(WS-ROW) = 1
                 AND PL-INVENTORY(WS-ROW) NOT = PL-BOOK-INVENTORY(WS-ROW)
             CALL "CRAFT-BOOK-SEND" USING WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM CRAFT-REFRESH-ALL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CRAFT-PLACE.
*> USING connection id, PLAY-SERVERBOUND (a decoded Place Recipe): crafts once (see above).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-BEFORE.
    05 WS-BEFORE-SLOT OCCURS 36 TIMES.
       10 WS-BEFORE-ITEM   BINARY-LONG.
       10 WS-BEFORE-COUNT  BINARY-LONG.
 LINKAGE SECTION.
 COPY PLAYPKT.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ID PLAY-SERVERBOUND.
     IF PSB-CONTAINER NOT = 0 OR PSB-RECIPE < 0 OR PSB-RECIPE >= RP-COUNT
         GOBACK
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     MOVE PL-INVENTORY(WS-ROW) TO WS-BEFORE
     CALL "CRAFT-TRY" USING WS-ROW PSB-RECIPE WS-ONE WS-OUTCOME
     IF WS-OUTCOME = 1
         COMPUTE PL-STATE-ID(WS-ROW) = FUNCTION MOD(PL-STATE-ID(WS-ROW) + 1, 32768)
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
             IF PL-SLOT(WS-ROW, WS-S) NOT = WS-BEFORE-SLOT(WS-S)
                 COMPUTE WS-SLOT = WS-S - 1
                 CALL "INV-SLOT-SEND" USING L-ID WS-SLOT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM CRAFT-PLACE.
