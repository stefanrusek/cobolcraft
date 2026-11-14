*> Acceptance test US2-1, US2-2 (spec 002 FR-003; SC-011; docs/design/world-types.md §3.2, §8.2): the
*> create-world screen offers the two world types on one control (a click cycles standard and cobolcraft;
*> standard is the default). With valid packs both create. With the packs not ok the standard choice stays
*> selectable and Create is refused: the explanation text cobolcraft.world_type.standard.unavailable is shown,
*> nothing is created (no world folder, no hosted world); the cobolcraft type creates. Create fills the
*> settings the core takes (CS-WORLD-TYPE, CS-GENERATED-DIR, CS-SEED-TEXT).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-CREATE-SCREEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-create-screen".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 31.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC 99.
 01 WS-E3                  PIC 9.
 01 WS-E4                  PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE CT-PACKS-OK TO CL-PACKS-STATUS
     MOVE SCR-CREATE-WORLD TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US2-1 given valid packs when the create-world screen opens then the world type "
         & "control shows Standard, the default" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM COUNT-TYPE-STANDARD
     PERFORM ASSERT-HITS

     MOVE ACT-WORLD-TYPE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "World type: CobolCraft"
     MOVE "acceptance US2-1 a click on the world type control switches to CobolCraft" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-HITS
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE "acceptance US2-1 a second click switches back to Standard" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM COUNT-TYPE-STANDARD
     PERFORM ASSERT-HITS

*>   Packs not ok: the standard choice stays, Create is refused with the explanation, nothing is created.
     MOVE CT-PACKS-ABSENT TO CL-PACKS-STATUS
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Standard worlds need the Minecraft content"
     MOVE "acceptance US2-2 given packs not ok when Create is clicked with standard chosen then the "
         & "explanation is shown on the create-world screen" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-HITS
     MOVE "acceptance US2-2 and standard is still the selected type, nothing is created or opened"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "World type: Standard"
     CALL "SYSTEM" USING "test -d build/client-test-create-screen/saves/New_World"
     MOVE 0 TO WS-E4
     IF RETURN-CODE NOT = 0
         MOVE 1 TO WS-E4
     END-IF
     MOVE WS-HITS TO WS-E1
     MOVE SM-SCREEN TO WS-E2
     MOVE SP-ACTIVE TO WS-E3
     STRING WS-E1 " screen " WS-E2 " active " WS-E3 " folder " WS-E4
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 screen 14 active 0 folder 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The cobolcraft type creates and opens a world whatever the packs are; the settings carry its type.
     MOVE ACT-WORLD-TYPE TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE "acceptance US2-2 given packs not ok when the cobolcraft type is chosen and Create is clicked "
         & "then the world is created and joined with the settings of its type" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-JOINED TO WS-E1
     MOVE SP-ACTIVE TO WS-E3
     STRING "joined " WS-E1 " active " WS-E3 " type " FUNCTION TRIM(CS-WORLD-TYPE)
         " seed [" FUNCTION TRIM(CS-SEED-TEXT) "]" DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "joined 1 active 1 type cobolcraft seed []" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT" USING CLIENT-STATE

*>   Packs not ok: the create-world screen opens with the cobolcraft type as its default.
     MOVE CT-PACKS-ABSENT TO CL-PACKS-STATUS
     MOVE SCR-CREATE-WORLD TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "World type: CobolCraft"
     MOVE "acceptance US2-2 given packs not ok when the create-world screen opens then the world type "
         & "control defaults to CobolCraft" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-HITS

*>   Valid packs: the standard type creates (the settings carry the generated directory).
     MOVE CT-PACKS-OK TO CL-PACKS-STATUS
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE "build/client-test-create-screen/generated" TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(CL-GENERATED-DIR)) TO CL-GENERATED-DIR-LENGTH
     MOVE SCR-CREATE-WORLD TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE "acceptance US2-1 given valid packs when Create is clicked with standard chosen then the "
         & "core is asked for the standard type and directory and refuses (fixture is no real set)"
         TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SP-CREATE-REFUSED TO WS-E1
     STRING "refused " WS-E1 " type " FUNCTION TRIM(CS-WORLD-TYPE) " dir "
         FUNCTION TRIM(CS-GENERATED-DIR) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "refused 1 type standard dir build/client-test-create-screen/generated" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 COUNT-TYPE-STANDARD.
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "World type: Standard"
     MOVE "N" TO TL-MODE.

 ASSERT-HITS.
     MOVE "N" TO TL-MODE
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US2-CREATE-SCREEN.
 COPY CLTEST.
