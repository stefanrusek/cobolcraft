*> Acceptance test of docs/protocol/36-structures-1 section 1 (what a structure is in this version, and what is data): the structure and
*> structure set elements are read from the loaded data pack at run time (the invented fixture tree core/tests/fixtures/struct), never
*> tabulated: a set, its salt and spacing and its weights come from the files, a structure belongs to the sets that list it, an element the
*> schema rejects is left out and counted, a folder without elements loads nothing, and a second load replaces the first.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-1-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct".
 01 WS-EMPTY               PIC X(1100) VALUE "core/tests/fixtures/struct/data/minecraft/tags".
 01 WS-STATUS              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "STRUCT-RESET"
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: nothing is loaded before the data pack is read" TO TL-CASE
     MOVE SD-SET-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: the fixture pack loads" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: fourteen set files, eight accepted" TO TL-CASE
     MOVE SD-SET-COUNT TO TL-OBSERVED-N
     MOVE 8 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: six elements the schema rejects (JSON, placement, spacing, weight, structure) are counted" TO TL-CASE
     MOVE SD-BAD TO TL-OBSERVED-N
     MOVE 6 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: four structures are read, each once although several sets list them" TO TL-CASE
     MOVE SD-ST-COUNT TO TL-OBSERVED-N
     MOVE 4 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "minecraft:alpha_set" TO WS-KEY
     CALL "STRUCT-FIND-SET" USING WS-KEY WS-INDEX
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: a set is found by its id, in registry listing order" TO TL-CASE
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: the salt, spacing and separation are the file's" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SS-SALT(WS-INDEX) * 10000 + SS-SPACING(WS-INDEX) * 100 + SS-SEPARATION(WS-INDEX)
     MOVE 123453208 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:bad_set" TO WS-KEY
     CALL "STRUCT-FIND-SET" USING WS-KEY WS-INDEX
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: the rejected set is not in the table" TO TL-CASE
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:s_two" TO WS-KEY
     CALL "STRUCT-FIND-STRUCT" USING WS-KEY WS-INDEX
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: a structure is found by its id, in order of first use" TO TL-CASE
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "minecraft:nothing" TO WS-KEY
     CALL "STRUCT-FIND-STRUCT" USING WS-KEY WS-INDEX
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: an unknown structure id is 0" TO TL-CASE
     MOVE WS-INDEX TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "STRUCT-LOAD" USING WS-EMPTY WS-STATUS
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: a folder without a structure_set folder is refused" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§1 What a structure is in this version, and what is data: and it leaves nothing loaded (a load replaces the earlier one)" TO TL-CASE
     MOVE SD-SET-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
