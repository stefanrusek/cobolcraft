*> Test of the loader of docs/protocol/36-structures-7-woodland-mansion.md (T0257/T0258): LOAD-36-7 USING root (PIC X(1100)), status out. The fixture tree content/tests/fixtures/load-36-7 holds the
*> documented data pack files of the part (2 elements: worldgen/structure, worldgen/structure_set); each reject case copies one bad file of content/tests/fixtures/load-36-7/bad into
*> a fresh copy of the tree and the whole load is CT-BAD-DATA with nothing left loaded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-36-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-WANT-TYPE           PIC X(48).
 01 WS-LABEL               PIC X(70).
 01 WS-NAME                PIC X(40).
 01 WS-FILE                PIC X(40).
 01 WS-DEST                PIC X(40).
 01 WS-COMMAND             PIC X(600).
 01 WS-FINDS.
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(112) VALUE "minecraft:mansion".
    05 FILLER PIC X(48) VALUE "woodland_mansion".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(112) VALUE "minecraft:woodland_mansions".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-FIND-TABLE REDEFINES WS-FINDS.
    05 WS-FIND OCCURS 2 TIMES.
       10 WS-F-REGISTRY   PIC X(48).
       10 WS-F-KEY        PIC X(112).
       10 WS-F-TYPE       PIC X(48).
 01 WS-BADS.
    05 FILLER PIC X(40) VALUE "a mansion without biomes".
    05 FILLER PIC X(40) VALUE "no-biomes.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "biomes that is a number".
    05 FILLER PIC X(40) VALUE "biomes-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "biomes that is a bad tag".
    05 FILLER PIC X(40) VALUE "biomes-bad-tag.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a mansion without step".
    05 FILLER PIC X(40) VALUE "no-step.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a step that is a list".
    05 FILLER PIC X(40) VALUE "step-list.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a mansion without spawn_overrides".
    05 FILLER PIC X(40) VALUE "no-so.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "spawn_overrides that is a string".
    05 FILLER PIC X(40) VALUE "so-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "terrain_adaptation that is not an identi".
    05 FILLER PIC X(40) VALUE "ta-bad-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a type that is a number".
    05 FILLER PIC X(40) VALUE "type-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a salt that is a string".
    05 FILLER PIC X(40) VALUE "set-salt-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "separation above 4096".
    05 FILLER PIC X(40) VALUE "set-sep-high.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a fractional spacing".
    05 FILLER PIC X(40) VALUE "set-spacing-frac.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a negative weight".
    05 FILLER PIC X(40) VALUE "set-weight-neg.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a weight that is a string".
    05 FILLER PIC X(40) VALUE "set-weight-str.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "an entry without structure".
    05 FILLER PIC X(40) VALUE "set-no-structure.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a set without structures".
    05 FILLER PIC X(40) VALUE "set-no-structures.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "spread_type with a bad value".
    05 FILLER PIC X(40) VALUE "set-spread-enum.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "an exclusion zone of 17 chunks".
    05 FILLER PIC X(40) VALUE "set-exclusion-chunks.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "an exclusion zone without other_set".
    05 FILLER PIC X(40) VALUE "set-exclusion-no-set.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a file that is no JSON".
    05 FILLER PIC X(40) VALUE "not-json.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
 01 WS-BAD-TABLE REDEFINES WS-BADS.
    05 WS-BAD OCCURS 20 TIMES.
       10 WS-B-LABEL      PIC X(40).
       10 WS-B-FILE       PIC X(40).
       10 WS-B-REGISTRY   PIC X(40).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-36-7" TO WS-DIR
     CALL "LOAD-36-7" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 36-7 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 36-7 every documented file is an element" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE WS-F-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-F-KEY(WS-I) TO WS-KEY
         MOVE WS-F-TYPE(WS-I) TO WS-WANT-TYPE
         PERFORM CHECK-FIND
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE WS-B-LABEL(WS-I) TO WS-LABEL
         MOVE WS-B-FILE(WS-I) TO WS-FILE
         MOVE WS-B-REGISTRY(WS-I) TO WS-DEST
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 CHECK-FIND.
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-7 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 1 TO WS-ROW
     END-IF
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-7 " FUNCTION TRIM(WS-KEY) " has the shape " FUNCTION TRIM(WS-WANT-TYPE)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-36-7 2>/dev/null; rm -rf build/content-test/load-36-7; "
         "mkdir -p build/content-test/load-36-7/t && cp -R content/tests/fixtures/load-36-7/data build/content-test/load-36-7/t/data && "
         "cp content/tests/fixtures/load-36-7/bad/" FUNCTION TRIM(WS-FILE) " build/content-test/load-36-7/t/data/minecraft/"
         FUNCTION TRIM(WS-DEST) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-36-7/t" TO WS-DIR
     CALL "LOAD-36-7" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-7 reject " FUNCTION TRIM(WS-LABEL) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-7 reject " FUNCTION TRIM(WS-LABEL) ": nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
