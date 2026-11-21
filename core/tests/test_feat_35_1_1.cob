*> Acceptance test of docs/protocol/35-worldgen-features-1 section 1 (what this version's feature model is): the feature model (a flat Feature record dispatched on type, a placed feature as feature plus modifiers, no configured_feature layer) as the registries record it, and the 11 types without a top-level file.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-NAME                PIC X(48).
 01 WS-HM                  PIC X(32).
 01 WS-TEXT                PIC X(60).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LIST.
    05 WS-L                BINARY-LONG OCCURS 256 TIMES.
 PROCEDURE DIVISION.
     MOVE 1 TO WS-A
     CALL "F351-REGISTRY-SIZE" USING WS-A WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§1 What this version's feature model is: the feature registry has 58 types and no configured_feature registry exists" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 58 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE "no_op" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§1 What this version's feature model is: a Feature is a flat record: the type no_op is id 30 of worldgen/feature_type" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE 30 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE "configured_feature" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§1 What this version's feature model is: there is no configured_feature type name in the registry" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-A
     MOVE "placed_feature" TO WS-NAME
     CALL "F351-REGISTRY-ID" USING WS-A WS-NAME WS-B
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§1 What this version's feature model is: a placed feature is not a feature type (placed_feature is not in the feature registry)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-B
     MOVE -1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SUM
     MOVE "coral_claw" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM
     MOVE "coral_tree" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM
     MOVE "fill_layer" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM
     MOVE "no_op" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM
     MOVE "projected_random_patchy_square" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM
     MOVE "replace_single_block" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM
     MOVE "sculk_patch" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM
     MOVE "single_block_pillar" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM
     MOVE "speleothem" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM
     MOVE "stepped_column_cluster" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM
     MOVE "template" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     ADD WS-A TO WS-SUM

     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§1 What this version's feature model is: the 11 types without a top-level feature file report none" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-SUM
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "tree" TO WS-NAME
     CALL "F351-HAS-FILE" USING WS-NAME WS-A
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§1 What this version's feature model is: a type with a file (tree) reports one" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-A
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SUM
     MOVE 1 TO WS-C
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 57
         CALL "F351-REGISTRY-NAME" USING WS-C WS-I WS-NAME
         CALL "F351-HAS-FILE" USING WS-NAME WS-A
         ADD WS-A TO WS-SUM
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 35-1§1 What this version's feature model is: 47 of the 58 types have a top-level file" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-SUM
     MOVE 47 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
