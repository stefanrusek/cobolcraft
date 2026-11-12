*> Implementation test of the baked block models of a standard world (docs/protocol/08-resource-packs.md §4, §5; 12):
*> with the standard content set open (about 30,000 block states, all named minecraft:) and a pack that
*> holds assets/minecraft/blockstates, models and textures (client/tests/fixtures/mini-vanilla, a synthetic
*> pack in the shape of the generated vanilla pack), the mesher bakes the model of a state the first time a
*> section shows it. Before this, only the 18 stand-in states under assets/cobolcraft were baked and every
*> standard state (id 320 and up, or any id read as a stand-in one) drew nothing or the wrong block.
*> Cases: a stone block meshes six faces with the pack's texture (not the missing sprite 1); the same state
*> bakes once (the slot table does not grow); a state without a block state file draws the missing texture
*> cube, never nothing; the cobolcraft stand-in path still bakes its own 18 states after the set closes.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STANDARD-MODELS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-SPRITE-FOUND        BINARY-LONG.
 01 WS-SPRITE-ID           PIC X(80).
 01 WS-SPRITE-LENGTH       BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-SLOTS               BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-VERTICES            BINARY-LONG.
 01 WS-E1                  PIC Z(5)9.
 01 WS-E2                  PIC Z(5)9.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE "client/tests/fixtures/mini-vanilla" TO PK-ROOT(PK-COUNT)
     MOVE 34 TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     CALL "MODELS-BAKE" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 1000 TO SK-U

     MOVE "stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     MOVE "standard models the pack is on the stack with the stone texture in the atlas" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     MOVE SPACES TO WS-SPRITE-ID
     MOVE "minecraft:block/stone" TO WS-SPRITE-ID
     MOVE 21 TO WS-SPRITE-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-SPRITE-ID WS-SPRITE-LENGTH WS-SLOT
     MOVE WS-SLOT TO WS-SPRITE-FOUND
     IF WS-SLOT > 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "WORLD-ROW-NEW" USING CLIENT-STATE WS-ZERO WS-ZERO2 WS-ROW
     SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-ROW)
     MOVE ALL X"FF" TO CE-SKYS
     MOVE WS-STATE TO CE-STATE(1 + (1 * 256 + 1 * 16 + 1))
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     COMPUTE WS-VERTICES = WR-OP-COUNT(WS-ROW, 1) / 6
     MOVE "standard models a stone block of the standard set meshes six faces (36 vertices)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-VERTICES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "MODEL-SLOT-OF" USING CLIENT-STATE WS-STATE WS-SLOT
     MOVE "standard models the stone state's baked quads use the pack's texture, not the missing sprite"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "6 quads, sprite ok" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-E2
     IF WS-SLOT > 0
         MOVE BM-QUAD-COUNT(WS-SLOT) TO WS-E1
         IF BM-SPRITE(WS-SLOT, 1) > 1
             STRING FUNCTION TRIM(WS-E1) " quads, sprite ok" DELIMITED BY SIZE INTO TL-OBSERVED
         ELSE
             STRING FUNCTION TRIM(WS-E1) " quads, missing sprite" DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
     ELSE
         MOVE "no slot" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE BM-NEXT TO WS-SLOTS
     MOVE 1 TO WR-DIRTY(WS-ROW, 1)
     CALL "MESH-DIRTY" USING CLIENT-STATE WS-ONE
     MOVE "standard models a state is baked once: meshing it again takes no new slot" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-SLOTS TO TL-EXPECTED-N
     MOVE BM-NEXT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A block whose state file the pack lacks (the pack holds stone only): the missing cube, six faces.
     MOVE "dirt" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-ID WS-STATE WS-STATUS
     CALL "MODEL-SLOT-OF" USING CLIENT-STATE WS-STATE WS-SLOT
     MOVE "standard models a state with no block state file bakes the missing cube (six quads, sprite 1)"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "6 quads, sprite 1" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-SLOT > 0
         MOVE BM-QUAD-COUNT(WS-SLOT) TO WS-E1
         MOVE BM-SPRITE(WS-SLOT, 1) TO WS-E2
         STRING FUNCTION TRIM(WS-E1) " quads, sprite " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
             INTO TL-OBSERVED
     ELSE
         MOVE "no slot" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The icon of the stone item (a block item: the pack's items/stone.json names the stone block model): the
*>   pack's stone sprite, found on first use and kept.
     MOVE "stone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SLOT
     MOVE "standard models the stone item's icon is the pack's stone sprite, not a stand-in or missing one"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-SPRITE-FOUND TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "dirt" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SLOT
     MOVE "standard models an item whose definition the pack lacks gets the missing sprite 1, not nothing"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Flat items (layer0 of a generated model), block items whose model has no up face (the first face),
*>   a cached lookup, and ids no icon is drawn for.
     MOVE "stick" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SLOT
     MOVE SPACES TO WS-SPRITE-ID
     MOVE "minecraft:item/stick" TO WS-SPRITE-ID
     MOVE 20 TO WS-SPRITE-LENGTH
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-SPRITE-ID WS-SPRITE-LENGTH WS-SPRITE-FOUND
     MOVE "standard models a flat item's icon is its layer0 sprite" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE WS-SPRITE-FOUND TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SLOT
     MOVE "standard models an item's icon is found once: asking again gives the same sprite" TO TL-CASE
     MOVE WS-SPRITE-FOUND TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "cobblestone" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SLOT
     MOVE "standard models a block item whose model has no up face takes its first face's sprite"
         TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SLOT > 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -1 TO WS-ITEM
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SLOT
     MOVE "standard models item id -1 has no icon (0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3000 TO WS-ITEM
     CALL "ITEM-SPRITE-OF" USING CLIENT-STATE WS-ITEM WS-SLOT
     MOVE "standard models an item id beyond the table (3000) gets the missing sprite 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SLOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Closing the set returns the mesher to the stand-in table: state 2 is greystone again.
     MOVE 0 TO CT-OPEN
     MOVE 2 TO WS-STATE
     CALL "MODEL-SLOT-OF" USING CLIENT-STATE WS-STATE WS-SLOT
     MOVE "standard models with no set open a stand-in state's slot is its row (state + 1) and still has quads"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "slot 3 with quads" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-SLOT TO WS-E1
     IF WS-SLOT > 0 AND BM-QUAD-COUNT(WS-SLOT) > 0
         STRING "slot " FUNCTION TRIM(WS-E1) " with quads" DELIMITED BY SIZE INTO TL-OBSERVED
     ELSE
         STRING "slot " FUNCTION TRIM(WS-E1) " without quads" DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STANDARD-MODELS.
