*> Acceptance test, the optional seed field of the create-world screen (operator request "specify a
*> seed on the create world screen"; docs/design/builtin-ui-art.md Decision UI-24, world-types.md WT-19,
*> docs/protocol/11 section 12.1). The screen shows the label "Seed (optional)" and, while the field is
*> empty, the hint "Leave empty for a random seed". The name field has the focus when the screen opens;
*> a click on a field focuses it, Tab moves the focus between the two, typed text and Backspace edit the
*> focused field only, the seed holds at most 64 bytes. Create hands the seed text to the core
*> (CS-SEED-TEXT; the core's CORE-WORLD-OPEN turns it into CW-SEED with SEED-FROM-TEXT) and that seed is the vanilla rule's value: "abc" is its string
*> hash 96354, "123" the number 123, an empty field a random seed; the seed is not editable after.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-SEEDUI-CREATE-SCREEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY COREAPI.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-seedui".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 24.
 01 WS-SCREEN              BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG VALUE 0.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-TYPED               PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC -(19)9.
 01 WS-SEED             BINARY-DOUBLE.
 01 WS-RANDOM           BINARY-LONG.
 01 WS-N                 PIC 99 VALUE 0.
 01 WS-NAME-SHOW           PIC X(64).
 01 WS-SEED-SHOW           PIC X(64).
 01 WS-LONG                PIC X(70) VALUE "0123456789012345678901234567890123456789012345678901234567890123456789".
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     MOVE CT-PACKS-OK TO CL-PACKS-STATUS
     MOVE SCR-CREATE-WORLD TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Seed (optional)"
     MOVE "seedui the screen shows the seed label" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-HITS
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Leave empty for a random seed"
     MOVE "seedui an empty seed field shows the hint" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM ASSERT-HITS

*>   The name field has the focus: typing goes to the name, not the seed.
     MOVE "x" TO WS-TYPED
     MOVE 1 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE "seedui typing with the name focused edits the name only" TO TL-CASE
     PERFORM SHOW-FIELDS
     MOVE "name [New Worldx] seed [] focus 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY

*>   A click on the seed field focuses it; typed text and Backspace edit it.
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-FIELD-SEED TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE "abcd" TO WS-TYPED
     MOVE 4 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "seedui a click focuses the seed field, text and Backspace edit it" TO TL-CASE
     PERFORM SHOW-FIELDS
     MOVE "name [New World] seed [abc] focus 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE ZERO TO WS-HITS
     INSPECT WS-TEXT TALLYING WS-HITS FOR ALL "Leave empty for a random seed"
     MOVE "seedui a seed field with text shows no hint" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM ASSERT-HITS

*>   Tab moves the focus to the name field and back; a click on the name field focuses it too.
     MOVE CC-KEY-TAB TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "z" TO WS-TYPED
     MOVE 1 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE "seedui Tab moves the focus from the seed to the name field" TO TL-CASE
     PERFORM SHOW-FIELDS
     MOVE "name [New Worldz] seed [abc] focus 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "y" TO WS-TYPED
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE "seedui Tab again moves the focus back to the seed field" TO TL-CASE
     PERFORM SHOW-FIELDS
     MOVE "name [New Worldz] seed [abcy] focus 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-FIELD-NAME TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE "seedui a click on the name field focuses it" TO TL-CASE
     PERFORM SHOW-FIELDS
     MOVE "name [New Worldz] seed [abcy] focus 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The seed holds at most 64 bytes; Backspace on an empty field does nothing.
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE ACT-FIELD-SEED TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE CC-KEY-BACKSPACE TO WS-KEY
     PERFORM 4 TIMES
         CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM
     MOVE "seedui Backspace on an empty seed field does nothing" TO TL-CASE
     PERFORM SHOW-FIELDS
     MOVE "name [New Worldz] seed [] focus 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-LONG(1:32) TO WS-TYPED
     MOVE 32 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE WS-LONG(33:32) TO WS-TYPED
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE "q" TO WS-TYPED
     MOVE 1 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE "seedui the seed field takes 64 bytes and no more" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE SM-EDIT-SEED-LENGTH TO TL-OBSERVED-N
     MOVE 64 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Create with the seed text "abc": the core is handed it and the world's seed is its hash.
     MOVE SPACES TO SM-EDIT-SEED
     MOVE "abc" TO SM-EDIT-SEED
     MOVE 3 TO SM-EDIT-SEED-LENGTH
     MOVE CT-TYPE-COBOLCRAFT TO SP-CREATE-TYPE
     PERFORM CREATE-WORLD
     MOVE "seedui Create with the seed text abc gives the core abc and the world seed 96354" TO TL-CASE
     PERFORM SHOW-SEED
     MOVE "joined 1 text [abc] seed 96354" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT" USING CLIENT-STATE

*>   Seed text 123 is the number.
     MOVE SCR-CREATE-WORLD TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE "seedui reopening the screen clears the seed field" TO TL-CASE
     PERFORM SHOW-FIELDS
     MOVE "name [New World] seed [] focus 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE ACT-FIELD-SEED TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     MOVE "123" TO WS-TYPED
     MOVE 3 TO WS-LENGTH
     CALL "TEST-TYPE" USING CLIENT-STATE WS-TYPED WS-LENGTH
     MOVE CT-TYPE-COBOLCRAFT TO SP-CREATE-TYPE
     PERFORM CREATE-WORLD
     MOVE "seedui Create with the seed text 123 gives the world seed 123" TO TL-CASE
     PERFORM SHOW-SEED
     MOVE "joined 1 text [123] seed 123" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT" USING CLIENT-STATE

*>   An empty field: the core is handed no text (a random seed).
     MOVE SCR-CREATE-WORLD TO WS-SCREEN
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     CALL "TEST-STEP" USING CLIENT-STATE
     MOVE CT-TYPE-COBOLCRAFT TO SP-CREATE-TYPE
     PERFORM CREATE-WORLD
     MOVE "seedui Create with an empty seed field gives the core no text" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE SP-SETTINGS TO CORE-SETTINGS
     STRING "text [" FUNCTION TRIM(CS-SEED-TEXT) "]" DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "T" TO TL-MODE
     MOVE "text []" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "SP-QUIT" USING CLIENT-STATE
     STOP RUN.

 CREATE-WORLD.
*>   A distinct world name per world: the folder must not exist yet.
     ADD 1 TO WS-N
     MOVE SPACES TO SM-EDIT-NAME
     MOVE 2 TO SM-EDIT-NAME-LENGTH
     STRING "W" WS-N DELIMITED BY SIZE INTO SM-EDIT-NAME
     MOVE 3 TO SM-EDIT-NAME-LENGTH
     MOVE ACT-CREATE-WORLD TO WS-ACTION
     CALL "TEST-CLICK" USING CLIENT-STATE WS-ACTION WS-ARG WS-FOUND
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED.

 SHOW-FIELDS.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE SM-FOCUS TO WS-E1
     MOVE SPACES TO WS-NAME-SHOW WS-SEED-SHOW
     IF SM-EDIT-NAME-LENGTH > 0
         MOVE SM-EDIT-NAME(1:SM-EDIT-NAME-LENGTH) TO WS-NAME-SHOW
     END-IF
     IF SM-EDIT-SEED-LENGTH > 0
         MOVE SM-EDIT-SEED(1:SM-EDIT-SEED-LENGTH) TO WS-SEED-SHOW
     END-IF
     STRING "name [" FUNCTION TRIM(WS-NAME-SHOW TRAILING) "] seed [" FUNCTION TRIM(WS-SEED-SHOW TRAILING)
         "] focus " WS-E1 DELIMITED BY SIZE INTO TL-OBSERVED.

 SHOW-SEED.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE WS-JOINED TO WS-E1
     CALL "SEED-FROM-TEXT" USING CS-SEED-TEXT WS-SEED WS-RANDOM
     MOVE WS-SEED TO WS-E2
     STRING "joined " WS-E1 " text [" FUNCTION TRIM(CS-SEED-TEXT) "] seed " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED.

 ASSERT-HITS.
     MOVE "N" TO TL-MODE
     MOVE WS-HITS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-SEEDUI-CREATE-SCREEN.
 COPY CLTEST.
