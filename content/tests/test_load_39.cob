*> Test of the loader of docs/protocol/39-portals.md (T0277; portals). LOAD-39 USING root (PIC X(1100): the folder that holds
*> data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error and nothing of the load stays): the data
*> inputs of section 1.2, through the shape engine (shapes.cob): the dimension types (coordinate_scale, min_y, height,
*> logical_height, attributes) and the block tag files tags/block (nether_portal_frame, fire: 23 section 6.1 grammar).
*> Fixture tree content/tests/fixtures/load-39; each reject case copies a file of content/tests/fixtures/load-39-bad
*> into a fresh copy of the tree.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-LOAD-39.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTSHAPE.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-REGISTRY            PIC X(48).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW                 BINARY-LONG.
 01 WS-COMMAND             PIC X(600).
 01 WS-T                   PIC X(50).
 01 WS-PATH                PIC X(48).
 01 WS-I                   BINARY-LONG.
 01 WS-N-TEXT              PIC 99.
 01 WS-CASES.
    05 FILLER PIC X(50) VALUE "a dimension type without coordinate_scale".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "coordinate_scale 0".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "coordinate_scale 31000000".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "coordinate_scale that is a string".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "a fractional min_y".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "a dimension type without height".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "a dimension type without logical_height".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "a dimension type without min_y".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "attributes that is an array".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "a dimension type that is no object".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "a dimension type file with a bad identifier".
    05 FILLER PIC X(48) VALUE "dimension_type/Bad.json".
    05 FILLER PIC X(50) VALUE "a dimension type that is no JSON".
    05 FILLER PIC X(48) VALUE "dimension_type/bad.json".
    05 FILLER PIC X(50) VALUE "a tag without values".
    05 FILLER PIC X(48) VALUE "tags/block/bad.json".
    05 FILLER PIC X(50) VALUE "a tag whose values is an object".
    05 FILLER PIC X(48) VALUE "tags/block/bad.json".
    05 FILLER PIC X(50) VALUE "a tag whose replace is a number".
    05 FILLER PIC X(48) VALUE "tags/block/bad.json".
    05 FILLER PIC X(50) VALUE "a tag that is an array".
    05 FILLER PIC X(48) VALUE "tags/block/bad.json".
 01 WS-CASE-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 16 TIMES.
       10 WS-CASE-LABEL    PIC X(50).
       10 WS-CASE-PATH     PIC X(48).
 PROCEDURE DIVISION.
     CALL "SHAPE-FREE"
     MOVE "content/tests/fixtures/load-39" TO WS-DIR
     CALL "LOAD-39" USING WS-DIR WS-STATUS
     MOVE "acceptance US12 load 39 the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "acceptance US12 load 39 five shape elements (3 dimension types, 2 tags)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE SH-ELEMENT-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "dimension_type" TO WS-REGISTRY
     MOVE "minecraft:the_nether" TO WS-KEY
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE "acceptance US12 load 39 the_nether is the third dimension type" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "tags/block" TO WS-REGISTRY
     MOVE "minecraft:fire" TO WS-KEY
     CALL "SHAPE-FIND" USING WS-REGISTRY WS-KEY WS-ROW
     MOVE "acceptance US12 load 39 the tag fire is there" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-ROW TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE"

     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE WS-CASE-LABEL(WS-I) TO WS-T
         MOVE WS-CASE-PATH(WS-I) TO WS-PATH
         PERFORM BAD-CASE
     END-PERFORM
     STOP RUN.

 BAD-CASE.
     MOVE "build/content-test/load-39/t" TO WS-DIR
     MOVE WS-I TO WS-N-TEXT
     MOVE SPACES TO WS-COMMAND
     STRING "chmod -R u+rwx build/content-test/load-39 2>/dev/null; rm -rf build/content-test/load-39; "
         "mkdir -p build/content-test/load-39 && cp -R content/tests/fixtures/load-39 build/content-test/load-39/t && "
         "cp content/tests/fixtures/load-39-bad/" WS-N-TEXT ".json build/content-test/load-39/t/data/minecraft/"
         FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "LOAD-39" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 39 " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 load 39 after " FUNCTION TRIM(WS-T) " nothing stays" DELIMITED BY SIZE INTO TL-CASE
     COMPUTE TL-EXPECTED-N = 0
     COMPUTE TL-OBSERVED-N = SH-ELEMENT-COUNT
     PERFORM ASSERT-NUM
     CALL "SHAPE-FREE".

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
