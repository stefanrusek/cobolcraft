*> Acceptance test US3-1, US3-4 (spec 002 FR-007, FR-008, FR-009, FR-010; SC-001), real input: the operator's real
*> Faithful 32x zip (tmp/Faithful 32x - 26.3.zip; the test FAILS loudly when it or the jar is absent) is
*> copied into resourcepacks/ next to the real generated packs (extracted from tmp/minecraft-26.3-client.jar
*> by the extraction tool). It lists on the pack screen as compatible, enables (its 32 pixel stone replaces the
*> generated 16 pixel one), moves above another pack, survives a restart in options.txt, and disabling it returns
*> the generated look.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US3-USER-PACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-GAME                PIC X(64) VALUE "build/generated-test/f2-faithful".
 01 WS-GAME-LENGTH         BINARY-LONG VALUE 32.
 01 WS-COMMAND             PIC X(1024).
 01 WS-EXIT                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-ANY                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-NAME                PIC X(80) VALUE "minecraft:block/stone".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 21.
 01 WS-SPRITE              BINARY-LONG.
 01 WS-E1                  PIC Z(3)9.
 01 WS-E2                  PIC Z(3)9.
 01 WS-E3                  PIC 9.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING 'test -f "tmp/Faithful 32x - 26.3.zip" && test -f tmp/minecraft-26.3-client.jar'
     MOVE RETURN-CODE TO WS-EXIT
     MOVE "acceptance US3-1 the real inputs (tmp/Faithful 32x - 26.3.zip, tmp/minecraft-26.3-client.jar) "
         & "are present (no skips)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EXIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE SPACES TO WS-COMMAND
     STRING "rm -rf build/generated-test/f2-faithful && mkdir -p build/generated-test/f2-faithful/resourcepacks "
         "&& make -C extract bin >/dev/null 2>&1; build/bin/cobolcraft-extract --jar tmp/minecraft-26.3-client.jar "
         "--game-dir build/generated-test/f2-faithful --generated-dir build/generated-test/f2-faithful/generated "
         "--quiet >/dev/null && cp 'tmp/Faithful 32x - 26.3.zip' build/generated-test/f2-faithful/resourcepacks/ "
         "&& cp -R client/tests/fixtures/packs/alpha build/generated-test/f2-faithful/resourcepacks/"
         X"00" DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE RETURN-CODE TO WS-EXIT
     MOVE "acceptance US3-1 the extraction and the copy of the real packs succeed" TO TL-CASE
     MOVE WS-EXIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM START-CLIENT
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     MOVE AT-SW(WS-SPRITE) TO WS-E1
     MOVE "acceptance US3-4 with the generated packs ok and no user pack the stone sprite is the "
         & "generated 16 pixel one" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "16" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE ACT-PACKS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Faithful 32x - 26.3.zip" ALL "The go-to 32x resource pack."
         ALL "Compatible"
     MOVE "acceptance US3-1 the real Faithful zip is listed on the pack screen with its description and "
         & "as compatible" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE FUNCTION MIN(WS-HITS / 3, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Enable alpha (entry 1: byte order puts "Faithful" first, alpha is entry 2), then Faithful on top.
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
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     MOVE AT-SW(WS-SPRITE) TO WS-E1
     MOVE PK-COUNT TO WS-E2
     MOVE "acceptance US3-1 enabled, Faithful is on top of alpha and the generated pack (4 packs) and "
         & "its 32 pixel stone is the sprite" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "4 32" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Moved down below alpha, Faithful stays enabled; then the restart keeps the order.
     MOVE ACT-PACKS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PACK-DOWN TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE ACT-PACKS-DONE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     PERFORM START-CLIENT
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     MOVE AT-SW(WS-SPRITE) TO WS-E1
     MOVE PK-COUNT TO WS-E2
     MOVE "acceptance US3-1 after a restart both packs are still enabled in the saved order (alpha on "
         & "top, then Faithful) and Faithful's stone is the sprite" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E2) " " PK-ID(4)(1:PK-ID-LENGTH(4)) " " FUNCTION TRIM(WS-E1)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "4 file/alpha 32" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Disable both: the generated look returns.
     MOVE ACT-PACKS TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PACK-DISABLE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 2 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PACK-DISABLE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     MOVE ACT-PACKS-DONE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ANY WS-FOUND
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-NAME WS-NAME-LENGTH WS-SPRITE
     MOVE AT-SW(WS-SPRITE) TO WS-E1
     MOVE "acceptance US3-4 with both packs disabled the stone is the generated 16 pixel sprite again"
         TO TL-CASE
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED
     MOVE "16" TO TL-EXPECTED
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
 END PROGRAM ACC-F2US3-USER-PACK.
 COPY CLTEST.
