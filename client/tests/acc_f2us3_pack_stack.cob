*> Acceptance test US3-5, US3-6 (spec 002; docs/design/faithful-pack-mapping.md section 9.1; 08 section 3.2): the pack
*> stack bottom to top: built-in (level 1), the optional skin (level 2, absent unless enabled), the generated
*> vanilla pack (3, when the packs check is ok), the user's packs in the user's order (4), server packs (5); the
*> top-most pack that has a path wins; minecraft: paths come from the generated pack, and cobolcraft: paths
*> from the built-in one; with the packs not ok there is no level 3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US3-PACK-STACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-f2-stack".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-NAMES               PIC X(256) VALUE "alpha beta.zip".
 01 WS-IDS                 PIC X(256) VALUE "file/beta.zip file/alpha".
 01 WS-PATH                PIC X(256).
 01 WS-PACK                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 9.
 01 WS-E3                  PIC 9.
 01 WS-E4                  PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE "contract/fixtures/content/valid" TO CL-GENERATED-DIR
     MOVE 31 TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     PERFORM LEVELS
     MOVE "acceptance US3-5 given the packs are ok and two user packs are enabled then the stack is the "
         & "built-in (1), the generated vanilla pack (3), then the user packs in their order (4, 4)"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "4 levels1344" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "assets/minecraft/textures/block/stone.png" TO WS-PATH
     CALL "PACK-RESOLVE" USING CLIENT-STATE WS-PATH 41 WS-PACK
     MOVE "acceptance US3-5 a minecraft: path only the generated pack has is resolved from level 3" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-PACK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "assets/cobolcraft/textures/block/greystone.png" TO WS-PATH
     CALL "PACK-RESOLVE" USING CLIENT-STATE WS-PATH 46 WS-PACK
     MOVE "acceptance US3-6 a path three packs have is resolved from the top-most (beta.zip, the stack's "
         & "last)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-PACK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "assets/cobolcraft/textures/block/loam.png" TO WS-PATH
     CALL "PACK-RESOLVE" USING CLIENT-STATE WS-PATH 41 WS-PACK
     MOVE "acceptance US3-6 a path only the built-in pack has is resolved from level 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PACK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Packs not ok: no level 3.
     MOVE CT-PACKS-STALE TO CL-PACKS-STATUS
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     PERFORM LEVELS
     MOVE "acceptance US3-5 given the packs are stale then the stack has no generated level: 1, 4, 4" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "3 levels144" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 LEVELS.
     MOVE SPACES TO TL-OBSERVED
     MOVE PK-COUNT TO WS-E1
     MOVE 0 TO WS-E2 WS-E3 WS-E4
     STRING WS-E1 " levels " DELIMITED BY SIZE INTO TL-OBSERVED
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PK-COUNT
         MOVE PK-LEVEL(WS-I) TO WS-E2
         STRING FUNCTION TRIM(TL-OBSERVED) WS-E2 DELIMITED BY SIZE INTO TL-OBSERVED
     END-PERFORM.
 END PROGRAM ACC-F2US3-PACK-STACK.
 COPY CLTEST.
 COPY PACKTEST.
