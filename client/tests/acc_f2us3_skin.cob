*> Acceptance test US3-3 (spec 002 FR-005, FR-006; docs/design/faithful-pack-mapping.md 3, 4, 9.3, 9.7), real input
*> (tmp/Faithful 32x - 26.3.zip and tmp/minecraft-26.3-client.jar; the test FAILS loudly when absent): the
*> optional Faithful skin pack (id cobolcraft_faithful_skin) is off by default; enabling it on the resource pack
*> screen puts it at level 2 of the stack, below the generated vanilla pack; with it on, the cobolcraft blocks
*> and items resolve the minecraft: texture ids of the mapping from the Faithful zip (greystone is
*> minecraft:block/stone, 32 pixels) while the turf models are not overridden; off again, greystone is its
*> built-in 16 pixel texture.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US3-SKIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GAME                PIC X(64) VALUE "build/generated-test/f2-skin".
 01 WS-GAME-LENGTH         BINARY-LONG VALUE 28.
 01 WS-COMMAND             PIC X(1024).
 01 WS-EXIT                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-ANY                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-D                   PIC 9.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-STATE-ROW           BINARY-LONG.
 01 WS-LEVELS              PIC X(16).
 01 WS-E1                  PIC Z(3)9.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING 'test -f "tmp/Faithful 32x - 26.3.zip" && test -f tmp/minecraft-26.3-client.jar'
     MOVE RETURN-CODE TO WS-EXIT
     MOVE "acceptance US3-3 the real inputs are present (no skips)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf build/generated-test/f2-skin && mkdir -p build/generated-test/f2-skin/resourcepacks "
         "&& make -C extract bin >/dev/null 2>&1; build/bin/cobolcraft-extract --jar tmp/minecraft-26.3-client.jar "
         "--game-dir build/generated-test/f2-skin --generated-dir build/generated-test/f2-skin/generated "
         "--quiet >/dev/null && cp 'tmp/Faithful 32x - 26.3.zip' build/generated-test/f2-skin/resourcepacks/"
         X"00" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE RETURN-CODE TO WS-EXIT
     MOVE "acceptance US3-3 the extraction and the copy of the Faithful zip succeed" TO TL-CASE
     MOVE WS-EXIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM START-CLIENT
     PERFORM LEVELS
     MOVE "acceptance US3-3 the skin is off by default: the stack is the built-in and the generated pack "
         & "(levels 1, 3)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "13" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-STATE-ROW
     PERFORM SPRITE-OF-STATE
     MOVE "acceptance US3-3 without the skin greystone's quads use cobolcraft:block/greystone" TO TL-CASE
     MOVE "cobolcraft:block/greystone 16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-PACKS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Faithful Skin" ALL "Uses Faithful 32x textures"
     MOVE "acceptance US3-3 the skin is an entry of the resource pack screen with its description" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Entries by byte order: Faithful (1), then the skin (2, built-in, listed last). Enable the skin, then Faithful.
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 2 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PACK-ENABLE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PACK-ENABLE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE ACT-PACKS-DONE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     PERFORM LEVELS
     MOVE "acceptance US3-3 with the skin and Faithful enabled the stack is built-in (1), skin (2), "
         & "generated (3), Faithful (4)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "1234" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-STATE-ROW
     PERFORM SPRITE-OF-STATE
     MOVE "acceptance US3-3 with the skin greystone's quads use minecraft:block/stone" TO TL-CASE
     MOVE "minecraft:block/stone 32" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-STATE-ROW
     PERFORM SPRITE-OF-STATE
     MOVE "acceptance US3-3 the turf models are not overridden: its quads are cobolcraft:block/turf_*"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF TL-OBSERVED(1:17) = "cobolcraft:block/"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 START-CLIENT.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE WS-GAME TO CL-GAME-DIR
     MOVE WS-GAME-LENGTH TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE
     CALL "TEST-STEP" USING CLIENT-STATE.

 LEVELS.
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PK-COUNT
         MOVE PK-LEVEL(WS-I) TO WS-D
         STRING FUNCTION TRIM(TL-OBSERVED) WS-D DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM
     MOVE "T" TO TL-MODE.

*> The name and the width of the sprite of the first quad of the baked state WS-STATE-ROW (state id + 1).
 SPRITE-OF-STATE.
     MOVE SPACES TO TL-OBSERVED
     MOVE BM-SPRITE(WS-STATE-ROW + 1, 1) TO WS-SPRITE
     MOVE AT-SW(WS-SPRITE) TO WS-E1
     STRING AT-NAME(WS-SPRITE)(1:AT-NAME-LENGTH(WS-SPRITE)) " " FUNCTION TRIM(WS-E1)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE.
 END PROGRAM ACC-F2US3-SKIN.
 COPY CLTEST.
