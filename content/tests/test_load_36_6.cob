*> Test of the loader of docs/protocol/36-structures-6-ocean.md (T0255/T0256): LOAD-36-6 USING root (PIC X(1100)), status out. The fixture tree content/tests/fixtures/load-36-6 holds the
*> documented data pack files of the part (8 elements: worldgen/structure, worldgen/structure_set); each reject case copies one bad file of content/tests/fixtures/load-36-6/bad into
*> a fresh copy of the tree and the whole load is CT-BAD-DATA with nothing left loaded.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-36-6.
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
    05 FILLER PIC X(112) VALUE "minecraft:ocean_ruin_cold".
    05 FILLER PIC X(48) VALUE "ocean_ruin".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(112) VALUE "minecraft:ocean_ruin_warm".
    05 FILLER PIC X(48) VALUE "ocean_ruin".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(112) VALUE "minecraft:shipwreck".
    05 FILLER PIC X(48) VALUE "shipwreck".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(112) VALUE "minecraft:shipwreck_beached".
    05 FILLER PIC X(48) VALUE "shipwreck".
    05 FILLER PIC X(48) VALUE "worldgen/structure".
    05 FILLER PIC X(112) VALUE "minecraft:monument".
    05 FILLER PIC X(48) VALUE "ocean_monument".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(112) VALUE "minecraft:ocean_ruins".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(112) VALUE "minecraft:shipwrecks".
    05 FILLER PIC X(48) VALUE "-".
    05 FILLER PIC X(48) VALUE "worldgen/structure_set".
    05 FILLER PIC X(112) VALUE "minecraft:ocean_monuments".
    05 FILLER PIC X(48) VALUE "-".
 01 WS-FIND-TABLE REDEFINES WS-FINDS.
    05 WS-FIND OCCURS 8 TIMES.
       10 WS-F-REGISTRY   PIC X(48).
       10 WS-F-KEY        PIC X(112).
       10 WS-F-TYPE       PIC X(48).
 01 WS-BADS.
    05 FILLER PIC X(40) VALUE "an ocean ruin without biome_temp".
    05 FILLER PIC X(40) VALUE "ruin-no-temp.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "an ocean ruin of biome_temp hot".
    05 FILLER PIC X(40) VALUE "ruin-hot.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "large_probability above 1".
    05 FILLER PIC X(40) VALUE "ruin-large-high.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "cluster_probability below 0".
    05 FILLER PIC X(40) VALUE "ruin-cluster-low.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "large_probability that is a string".
    05 FILLER PIC X(40) VALUE "ruin-large-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "is_beached that is a string".
    05 FILLER PIC X(40) VALUE "ship-string.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a shipwreck without is_beached".
    05 FILLER PIC X(40) VALUE "ship-missing.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a monument without biomes".
    05 FILLER PIC X(40) VALUE "mon-no-biomes.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a step that is a number".
    05 FILLER PIC X(40) VALUE "mon-step-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a monument without step".
    05 FILLER PIC X(40) VALUE "mon-no-step.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "spawn_overrides that is an array".
    05 FILLER PIC X(40) VALUE "mon-so-array.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a monument without spawn_overrides".
    05 FILLER PIC X(40) VALUE "mon-no-so.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "terrain_adaptation that is a number".
    05 FILLER PIC X(40) VALUE "mon-ta-number.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a biomes entry that is not an identifier".
    05 FILLER PIC X(40) VALUE "mon-bad-biome-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a structure without type".
    05 FILLER PIC X(40) VALUE "no-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
    05 FILLER PIC X(40) VALUE "a structure set entry of weight 0".
    05 FILLER PIC X(40) VALUE "set-weight-0.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a structure set entry with a bad id".
    05 FILLER PIC X(40) VALUE "set-bad-id.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a negative salt".
    05 FILLER PIC X(40) VALUE "set-salt-neg.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "spacing above 4096".
    05 FILLER PIC X(40) VALUE "set-spacing-high.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a placement without spacing".
    05 FILLER PIC X(40) VALUE "set-no-spacing.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a spread_type that is not listed".
    05 FILLER PIC X(40) VALUE "set-spread-square.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a structure set without placement".
    05 FILLER PIC X(40) VALUE "set-no-placement.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a placement without type".
    05 FILLER PIC X(40) VALUE "set-placement-no-type.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "structures that is an object".
    05 FILLER PIC X(40) VALUE "set-structures-object.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "frequency above 1".
    05 FILLER PIC X(40) VALUE "set-freq-high.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a structure set that is an array".
    05 FILLER PIC X(40) VALUE "set-array.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure_set".
    05 FILLER PIC X(40) VALUE "a file that is no JSON".
    05 FILLER PIC X(40) VALUE "not-json.json".
    05 FILLER PIC X(40) VALUE "worldgen/structure".
 01 WS-BAD-TABLE REDEFINES WS-BADS.
    05 WS-BAD OCCURS 27 TIMES.
       10 WS-B-LABEL      PIC X(40).
       10 WS-B-FILE       PIC X(40).
       10 WS-B-REGISTRY   PIC X(40).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-36-6" TO WS-DIR
     CALL "LOAD-36-6" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 36-6 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 36-6 every documented file is an element" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE WS-F-REGISTRY(WS-I) TO WS-REGISTRY
         MOVE WS-F-KEY(WS-I) TO WS-KEY
         MOVE WS-F-TYPE(WS-I) TO WS-WANT-TYPE
         PERFORM CHECK-FIND
     END-PERFORM
     CALL "SHAPE-FREE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE WS-B-LABEL(WS-I) TO WS-LABEL
         MOVE WS-B-FILE(WS-I) TO WS-FILE
         MOVE WS-B-REGISTRY(WS-I) TO WS-DEST
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 CHECK-FIND.
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-6 " FUNCTION TRIM(WS-KEY) " is loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 1 TO WS-ROW
     END-IF
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-6 " FUNCTION TRIM(WS-KEY) " has the shape " FUNCTION TRIM(WS-WANT-TYPE)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-TYPE TO TL-EXPECTED
     MOVE SH-T-NAME(SH-E-TYPE(WS-ROW)) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 BAD-CASE.
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-36-6 2>/dev/null; rm -rf build/content-test/load-36-6; "
         "mkdir -p build/content-test/load-36-6/t && cp -R content/tests/fixtures/load-36-6/data build/content-test/load-36-6/t/data && "
         "cp content/tests/fixtures/load-36-6/bad/" FUNCTION TRIM(WS-FILE) " build/content-test/load-36-6/t/data/minecraft/"
         FUNCTION TRIM(WS-DEST) "/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     MOVE "build/content-test/load-36-6/t" TO WS-DIR
     CALL "LOAD-36-6" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-6 reject " FUNCTION TRIM(WS-LABEL) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 36-6 reject " FUNCTION TRIM(WS-LABEL) ": nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
