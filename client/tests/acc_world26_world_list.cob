*> Acceptance test (world-types.md section 2.1 rule 3, section 8.2; docs/protocol/33 section 10): the world list reads a
*> real 26.3 world's level.dat (compound `Data`: LevelName, GameType) and lists it as a standard world, not as a
*> cobolcraft one named after its folder. Play on it with the packs not ok says the world needs the Minecraft content;
*> with the packs ok, a world the core refuses (no world type, folder of the standard layout) is not opened and the
*> screen gives the refusal's own text, never the Minecraft content text.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WORLD26-WORLD-LIST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-w26-list".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-H1                  PIC 9.
 01 WS-H2                  PIC 9.
 01 WS-H3                  PIC 9.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 99.
 01 WS-COMMAND             PIC X(300).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE CT-PACKS-STALE TO CL-PACKS-STATUS
     MOVE "mkdir -p build/client-test-w26-list/saves/a_real/dimensions/minecraft/overworld/region" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "cp -R core/tests/fixtures/world26/. build/client-test-w26-list/saves/a_real/" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "mkdir -p build/client-test-w26-list/saves/b_untyped/dimensions/minecraft/overworld/region" TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "cp core/tests/fixtures/world26-untyped/level.dat build/client-test-w26-list/saves/b_untyped/level.dat"
         TO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND

     MOVE SCR-WORLD-LIST TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance world26 given a real 26.3 world folder when the list opens then it is Vanilla Fixture, Standard"
         TO TL-CASE
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Vanilla Fixture (a_real)  Type: Standard"
     MOVE WS-HITS TO WS-H1
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "a_real (a_real)"
     MOVE WS-HITS TO WS-H2
     MOVE WL-MODE(1) TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING WS-H1 " " WS-H2 " mode " WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0 mode 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Packs not ok: the real world needs the Minecraft content.
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PLAY-WORLD TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Standard worlds need the Minecraft content"
     MOVE WS-HITS TO WS-H1
     MOVE SP-ACTIVE TO WS-E1
     MOVE "acceptance world26 given the packs are not ok when Play is clicked on the real world then the content text shows"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-H1 " active " WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 active 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Packs ok: a world the core refuses (no world type) gives the refusal text, not the content text.
     MOVE CT-PACKS-OK TO CL-PACKS-STATUS
     MOVE ACT-SELECT TO WS-ACTION
     MOVE 2 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE ACT-PLAY-WORLD TO WS-ACTION
     MOVE 0 TO WS-ARG
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Standard worlds need the Minecraft content"
     MOVE WS-HITS TO WS-H1
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "This world cannot be opened"
     MOVE WS-HITS TO WS-H2
     MOVE SP-ACTIVE TO WS-E1
     MOVE "acceptance world26 given the packs are ok when Play is clicked on a world with no type then the refusal text shows"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING WS-H1 " " WS-H2 " active " WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 1 active 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-WORLD26-WORLD-LIST.
 COPY CLTEST.
