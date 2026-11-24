*> Acceptance test US1-3 (spec 002 FR-001, FR-002; SC-012; docs/protocol/22-extraction-tool.md §9.2): the
*> title screen shows the built-in-language banner cobolcraft.packs.* (word-wrapped lines under the buttons)
*> stating the status of the generated packs and how to build them, when the start-up check
*> (PACKS-STATUS-CHECK, CORE-PACKS-STATUS) says absent, incomplete, stale or damaged; with valid packs there is
*> no banner; the cobolcraft world type is unaffected (its content opens and the Single-player button is
*> there).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US1-BANNER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TYPE                BINARY-LONG.
 01 WS-BUFFER              PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-BUTTONS             PIC X(72) VALUE "CobolCraft|Single-player|Multiplayer|Resource Packs|Options|Quit Game".
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING "rm -rf build/client-test-banner"
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE "Alice" TO CL-NAME
     MOVE 5 TO CL-NAME-LENGTH
     MOVE "build/client-test-banner" TO CL-GAME-DIR
     MOVE 24 TO CL-GAME-DIR-LENGTH
     CALL "CL-START" USING CLIENT-STATE

     MOVE "contract/fixtures/content/valid" TO WS-DIR
     MOVE 31 TO WS-LENGTH
     PERFORM TITLE-TEXTS
     MOVE "acceptance US1-3 given valid generated packs when the title screen opens then it shows no "
         & "banner, only the buttons" TO TL-CASE
     MOVE FUNCTION TRIM(WS-BUTTONS) TO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE "build/client-test-banner/none" TO WS-DIR
     MOVE 28 TO WS-LENGTH
     PERFORM TITLE-TEXTS
     MOVE "acceptance US1-3 given no generated packs (absent) then the banner says the content is not "
         & "set up and how to build it" TO TL-CASE
     STRING FUNCTION TRIM(WS-BUTTONS) "|Minecraft content is not set up. Run the extraction tool|"
         "with your Minecraft 26.3 client jar to play standard|worlds." DELIMITED BY SIZE
         INTO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE "contract/fixtures/content/incomplete" TO WS-DIR
     MOVE 36 TO WS-LENGTH
     PERFORM TITLE-TEXTS
     MOVE "acceptance US1-3 given incomplete packs then the banner says so" TO TL-CASE
     STRING FUNCTION TRIM(WS-BUTTONS) "|The Minecraft content is incomplete. Run the extraction|"
         "tool again." DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE "contract/fixtures/content/stale" TO WS-DIR
     MOVE 31 TO WS-LENGTH
     PERFORM TITLE-TEXTS
     MOVE "acceptance US1-3 given stale packs then the banner says they were made for another version"
         TO TL-CASE
     STRING FUNCTION TRIM(WS-BUTTONS) "|The Minecraft content was made for another version. Run|"
         "the extraction tool again." DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE "contract/fixtures/content/damaged" TO WS-DIR
     MOVE 33 TO WS-LENGTH
     PERFORM TITLE-TEXTS
     MOVE "acceptance US1-3 given damaged packs then the banner says so and names --force" TO TL-CASE
     STRING FUNCTION TRIM(WS-BUTTONS) "|The Minecraft content is damaged. Run the extraction|"
         "tool with --force." DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM ASSERT-TEXT

     MOVE CT-TYPE-COBOLCRAFT TO WS-TYPE
     MOVE SPACES TO WS-BUFFER
     CALL "CONTENT-OPEN" USING WS-TYPE WS-BUFFER WS-STATUS
     MOVE "acceptance US1-3 the cobolcraft type is unaffected by the packs status: its content opens"
         TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CONTENT-CLOSE"
     STOP RUN.

*> Runs the start-up check over the directory in WS-DIR and shows the title screen.
 TITLE-TEXTS.
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR(1:WS-LENGTH) TO CL-GENERATED-DIR
     MOVE WS-LENGTH TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     MOVE SCR-TITLE TO WS-TYPE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-TYPE
     CALL "SCREEN-BUILD" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE SPACES TO TL-EXPECTED.

 ASSERT-TEXT.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US1-BANNER.
 COPY CLTEST.
