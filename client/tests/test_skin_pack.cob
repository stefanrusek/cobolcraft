*> Implementation test of the skin pack's files (SKIN-READ, SKIN-FIND, SKIN-MAP; PACK-SOURCE-* of kind 3): the
*> skin supplies only the block and item models whose texture ids the mapping changes (greystone's block model
*> names minecraft:block/stone; the turf model, an unknown model, a path outside the models and every texture are
*> not its files), lists no file for the atlases and has no image.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SKIN-PACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-skin-pack".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-NAMES               PIC X(256) VALUE "alpha".
 01 WS-IDS                 PIC X(256) VALUE "cobolcraft_faithful_skin".
 01 WS-PATH                PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(2048).
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 01 WS-FOUND               BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG VALUE 1.
 01 WS-PACK                BINARY-LONG VALUE 2.
 01 WS-FOUND2              BINARY-LONG.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 9.
 01 WS-E3                  PIC 9.
 01 WS-E4                  PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE SPACES TO WS-PATH
     MOVE "assets/cobolcraft/models/block/greystone.json" TO WS-PATH
     MOVE 46 TO WS-LENGTH
     CALL "PACK-SOURCE-READ" USING CLIENT-STATE WS-PACK WS-PATH WS-LENGTH WS-TEXT WS-CAPACITY
         WS-OUT-LENGTH WS-FOUND
     MOVE "skin pack greystone's block model is the built-in one naming minecraft:block/stone" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT(1:WS-OUT-LENGTH) TO TL-OBSERVED
     MOVE '{"parent":"cobolcraft:block/template_uniform","textures":{"all":"minecraft:block/stone"}}'
         TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE FUNCTION CHAR(1 + 48) TO WS-TEXT(1:1)
     MOVE 0 TO WS-E1 WS-E2 WS-E3 WS-E4
     MOVE SPACES TO WS-PATH
     MOVE "assets/cobolcraft/models/block/nothing.json" TO WS-PATH
     MOVE 43 TO WS-LENGTH
     CALL "PACK-SOURCE-HAS" USING CLIENT-STATE WS-PACK WS-PATH WS-LENGTH WS-FOUND
     MOVE WS-FOUND TO WS-E1
     MOVE SPACES TO WS-PATH
     MOVE "assets/cobolcraft/models/block/turf.json" TO WS-PATH
     MOVE 41 TO WS-LENGTH
     CALL "PACK-SOURCE-HAS" USING CLIENT-STATE WS-PACK WS-PATH WS-LENGTH WS-FOUND
     MOVE WS-FOUND TO WS-E2
     MOVE SPACES TO WS-PATH
     MOVE "assets/minecraft/atlases/blocks.json" TO WS-PATH
     MOVE 36 TO WS-LENGTH
     CALL "PACK-SOURCE-HAS" USING CLIENT-STATE WS-PACK WS-PATH WS-LENGTH WS-FOUND
     MOVE WS-FOUND TO WS-E3
     MOVE SPACES TO WS-PATH
     MOVE "assets/cobolcraft/models/item/pry_bar.json" TO WS-PATH
     MOVE 42 TO WS-LENGTH
     CALL "PACK-SOURCE-HAS" USING CLIENT-STATE WS-PACK WS-PATH WS-LENGTH WS-FOUND
     MOVE WS-FOUND TO WS-E4
     MOVE "skin pack has no unknown model, no turf model, no atlas file, but the pry_bar item model"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 WS-E2 WS-E3 WS-E4 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0001" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "PACK-SOURCE-IMAGE" USING CLIENT-STATE WS-PACK WS-PATH WS-LENGTH WS-TEXT WS-CAPACITY
         WS-W WS-H WS-FOUND
     CALL "PACK-SOURCE-PATH" USING CLIENT-STATE WS-PACK WS-INDEX WS-PATH WS-LENGTH WS-FOUND2
     MOVE WS-FOUND TO WS-E2
     MOVE WS-FOUND2 TO WS-E1
     MOVE "skin pack has no image and lists no file" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E2 WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "00" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-SKIN-PACK.
 COPY CLTEST.
 COPY PACKTEST.
