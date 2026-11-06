*> Implementation test of client/src/packs/itemdefs.cob (08 §5.7 generated item model, §6 item
*> model definitions, §10.7 the built-in item models and definitions; standin-content §2 icons):
*> every item of the built-in pack gets the layer0 sprite of the generated model its definition
*> names (block items the block texture: turf's top, cardstack's end, glowtube's lit face); a
*> definition of another type, a model chain that does not reach minecraft:builtin/generated, a
*> model that no pack has, malformed JSON or a missing definition give the missing texture.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEMDEFS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-I                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-DEF                 PIC X(256).
 01 WS-DEF-LENGTH          BINARY-LONG.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-AREA                PIC X(4096).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEY                 PIC X(32).
 01 WS-KEY-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     CALL "ITEMDEFS-LOAD" USING CLIENT-STATE
     MOVE "itemdefs every built-in item's icon is the layer0 sprite of its generated item model "
         & "(08 §10.7)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > CL-ITEM-COUNT
         MOVE IT-SPRITE(WS-I) TO WS-S
         MOVE "           missing" TO WS-PATH
         MOVE 7 TO WS-LENGTH
         IF WS-S > 1
             COMPUTE WS-LENGTH = AT-NAME-LENGTH(WS-S) - 11
             MOVE AT-NAME(WS-S) TO WS-PATH
         END-IF
         STRING FUNCTION TRIM(TL-OBSERVED) " " WS-PATH(12:WS-LENGTH)
             DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     MOVE "block/baseplate block/greystone block/loam block/turf_top block/grit block/cardstack_end "
         & "block/lucite block/glowtube_lit block/ledger_tile item/pry_bar item/trowel "
         & "item/grazer_flank item/seared_flank item/sod_cake item/dump_shard block/goto_pad "
         & "block/slag" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "itemdefs cobolcraft:nothing has no definition: the missing texture (sprite 1)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE IT-SPRITE(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "items/turf.json" TO WS-KEY
     MOVE "itemdefs the built-in items/turf.json names its model with type minecraft:model"
         TO TL-CASE
     MOVE '{"model":{"type":"minecraft:model","model":"cobolcraft:item/turf"}}' TO TL-EXPECTED
     PERFORM FILE-TEXT
     MOVE "models/item/turf.json" TO WS-KEY
     MOVE "itemdefs the built-in models/item/turf.json is a generated model with layer0 "
         & "cobolcraft:block/turf_top" TO TL-CASE
     MOVE '{"parent":"minecraft:builtin/generated","textures":{"layer0":"cobolcraft:block/turf_top'
         & '"}}' TO TL-EXPECTED
     PERFORM FILE-TEXT

     MOVE '{"model":{"type":"model","model":"cobolcraft:item/trowel"}}' TO WS-DEF
     PERFORM DEF-SPRITE
     MOVE "itemdefs a definition of type model (default namespace) resolves to its layer0 sprite"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "cobolcraft:item/trowel" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     IF WS-SPRITE > 0
         MOVE AT-NAME(WS-SPRITE) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE '{"model":{"type":"minecraft:empty"}}' TO WS-DEF
     PERFORM DEF-SPRITE
     MOVE "itemdefs a definition of type minecraft:empty gives the missing texture" TO TL-CASE
     MOVE WS-SPRITE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"model":{"type":"minecraft:model","model":"cobolcraft:block/greystone"}}' TO WS-DEF
     PERFORM DEF-SPRITE
     MOVE "itemdefs a model chain that never reaches minecraft:builtin/generated (a block model) "
         & "gives the missing texture" TO TL-CASE
     MOVE WS-SPRITE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"model":{"type":"minecraft:model","model":"item/nothing_here"}}' TO WS-DEF
     PERFORM DEF-SPRITE
     MOVE "itemdefs a model no pack has gives the missing texture" TO TL-CASE
     MOVE WS-SPRITE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"model":' TO WS-DEF
     PERFORM DEF-SPRITE
     MOVE "itemdefs malformed JSON gives the missing texture" TO TL-CASE
     MOVE WS-SPRITE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 DEF-SPRITE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DEF)) TO WS-DEF-LENGTH
     CALL "ITEMDEF-SPRITE" USING CLIENT-STATE WS-DEF WS-DEF-LENGTH WS-SPRITE.

 FILE-TEXT.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-PATH TL-OBSERVED
     STRING "assets/cobolcraft/" FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-PATH
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
     CALL "PACK-READ" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-AREA WS-CAPACITY WS-LENGTH
         WS-FOUND
     IF WS-LENGTH > 0
         MOVE WS-AREA(1:WS-LENGTH) TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ITEMDEFS.
 COPY CLTEST.
