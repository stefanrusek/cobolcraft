*> Real-data test (skipped as a pass without the generated packs; docs/protocol/36-structures-3-jigsaw-assembly.md section 5, pool elements): over the pools of the pack, the element kinds and what
*> they answer (expected values from the independent reader gen_jigsaw.py): a legacy_single_pool_element (5.2: kind 2) of the plains village has the box of its template at every rotation (5.1)
*> and its two jigsaws; a list_pool_element (5.3) of the pillager outpost's towers pool holds two sub-elements, has the union box, takes the jigsaws of its first sub-element, and a list's
*> projection is pushed onto its sub-elements (a synthetic list that is terrain_matching over rigid templates); a feature_pool_element (5.5) has a box of one block at the position and one
*> synthetic jigsaw (front down, top south, rollable, no tag, both priorities 0); the empty_pool_element (5.4) is the shared row 1, terrain_matching, with no jigsaw; the plains decor pool lists
*> its entries in order with their weights. The processors of 5.1 and 5.2 and the replacement of 5.6 are in test_struct_jigsaw_place.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-3-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTTPL.
 COPY STRUCTJIG.
 COPY JSONDOC.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1100).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KEY                 PIC X(80).
 01 WS-POOL                BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 10.
 01 WS-Y                   BINARY-LONG VALUE 20.
 01 WS-Z                   BINARY-LONG VALUE 30.
 01 WS-BOX.
    05 WS-B                BINARY-LONG OCCURS 6 TIMES.
 01 WS-BAD                 BINARY-LONG.
 01 WS-TEXT                PIC X(600).
 01 WS-LEN                 BINARY-LONG.
 01 WS-NODE                BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BOXES.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 20.
    05 FILLER BINARY-LONG VALUE 30.
    05 FILLER BINARY-LONG VALUE 16.
    05 FILLER BINARY-LONG VALUE 26.
    05 FILLER BINARY-LONG VALUE 36.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 20.
    05 FILLER BINARY-LONG VALUE 30.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 26.
    05 FILLER BINARY-LONG VALUE 36.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 20.
    05 FILLER BINARY-LONG VALUE 24.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 26.
    05 FILLER BINARY-LONG VALUE 30.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 20.
    05 FILLER BINARY-LONG VALUE 24.
    05 FILLER BINARY-LONG VALUE 16.
    05 FILLER BINARY-LONG VALUE 26.
    05 FILLER BINARY-LONG VALUE 30.
 01 WS-BOX-TAB REDEFINES WS-BOXES.
    05 WS-HB OCCURS 4 TIMES.
       10 WS-HV            BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-3§5 Pool elements: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-ENV TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "JIG-RESET"
*>   5.1 and 5.2: a legacy single element of the plains houses pool
     MOVE "minecraft:village/plains/houses" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE 0 TO WS-EL
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= JP-N(WS-POOL)
         MOVE JN-ELEM(JP-FIRST(WS-POOL) + WS-I) TO WS-SUB
         IF JE-LOC(WS-SUB) = "minecraft:village/plains/houses/plains_small_house_1"
             MOVE WS-SUB TO WS-EL
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-3§5.2 plains_small_house_1 is a legacy_single_pool_element (kind 2), rigid" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = JE-KIND(WS-EL) * 10 + JE-PROJ(WS-EL)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
         CALL "JIG-EL-BOX" USING WS-EL WS-X WS-Y WS-Z WS-ROT WS-BOX
         COMPUTE WS-I = WS-ROT + 1
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
             IF WS-B(WS-J) NOT = WS-HV(WS-I, WS-J)
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-3§5.1 the element's box at (10, 20, 30) of the 7 x 7 x 7 template is the model's at all four rotations" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ROT
     CALL "JIG-EL-JIGS" USING WS-EL WS-X WS-Y WS-Z WS-ROT
     MOVE "acceptance US12 36-3§5.1 the element's jigsaws are the template's two (4.3)" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE JW-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   5.3 the list of the towers pool
     MOVE "minecraft:pillager_outpost/towers" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE JN-ELEM(JP-FIRST(WS-POOL)) TO WS-EL
     MOVE "acceptance US12 36-3§5.3 the towers element is a list_pool_element (kind 3) of two sub-elements, rigid" TO TL-CASE
     MOVE 320 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = JE-KIND(WS-EL) * 100 + JE-SUB-N(WS-EL) * 10 + JE-PROJ(WS-EL)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ROT
     CALL "JIG-EL-BOX" USING WS-EL WS-X WS-Y WS-Z WS-ROT WS-BOX
     MOVE "acceptance US12 36-3§5.3 the list's box at (10, 20, 30) is the union of its sub-elements': (10, 20, 30) to (24, 42, 44)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-B(1) NOT = 10 OR WS-B(2) NOT = 20 OR WS-B(3) NOT = 30 OR WS-B(4) NOT = 24 OR WS-B(5) NOT = 42 OR WS-B(6) NOT = 44
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-ROT
     CALL "JIG-EL-BOX" USING WS-EL WS-X WS-Y WS-Z WS-ROT WS-BOX
     MOVE "acceptance US12 36-3§5.3 the same list turned 90 degrees: (-4, 20, 30) to (10, 42, 44)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-B(1) NOT = -4 OR WS-B(2) NOT = 20 OR WS-B(3) NOT = 30 OR WS-B(4) NOT = 10 OR WS-B(5) NOT = 42 OR WS-B(6) NOT = 44
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ROT
     CALL "JIG-EL-JIGS" USING WS-EL WS-X WS-Y WS-Z WS-ROT
     MOVE "acceptance US12 36-3§5.3 the list's jigsaws are its first sub-element's: one, at (17, 21, 43), front south (3), top up (1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF JW-COUNT = 1 AND JW-X(1) = 17 AND JW-Y(1) = 21 AND JW-Z(1) = 43 AND JW-FRONT(1) = 3 AND JW-TOP(1) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the projection of a list is pushed onto its sub-elements (a synthetic terrain_matching list over rigid templates)
     MOVE '{"element_type": "minecraft:list_pool_element", "projection": "terrain_matching", "elements": [{"element_type": "minecraft:single_pool_element", "location": "minecraft:pillager_outpost/watchtower", "processors": "minecraft:empty", "projection": "rigid"}, {"element_type": "minecraft:empty_pool_element"}]}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "JIG-EL-PARSE" USING JSON-DOC WS-NODE WS-EL
     MOVE JS-ELEM(JE-SUB-FIRST(WS-EL)) TO WS-SUB
     MOVE "acceptance US12 36-3§5.3 a terrain_matching list makes its rigid sub-element terrain_matching (1) and keeps the empty one's" TO TL-CASE
     MOVE 111 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = JE-PROJ(WS-EL) * 100 + JE-PROJ(WS-SUB) * 10 + JE-PROJ(JS-ELEM(JE-SUB-FIRST(WS-EL) + 1))
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-ROT
     CALL "JIG-EL-BOX" USING WS-EL WS-X WS-Y WS-Z WS-ROT WS-BOX
     MOVE "acceptance US12 36-3§5.3 the empty sub-element is left out of the list's box (the box is the watchtower's alone: 15 x 21 x 15)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-B(4) - WS-B(1) NOT = 14 OR WS-B(5) - WS-B(2) NOT = 20 OR WS-B(6) - WS-B(3) NOT = 14
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   5.2, 5.4, 5.5: the plains decor pool in order: a legacy element (2), three features (1), the empty element (2)
     MOVE "minecraft:village/plains/decor" TO WS-KEY
     CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
     MOVE "acceptance US12 36-3§6 plains decor: five entries, weights 2 1 1 1 2 (total 7)" TO TL-CASE
     MOVE 507 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = JP-N(WS-POOL) * 100 + JP-TOTAL(WS-POOL)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     MOVE 1 TO WS-ROW
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 4
         MOVE JN-ELEM(JP-FIRST(WS-POOL) + WS-I) TO WS-SUB
         EVALUATE WS-I
             WHEN 0
                 IF JE-KIND(WS-SUB) NOT = 2 OR JN-WEIGHT(JP-FIRST(WS-POOL) + WS-I) NOT = 2
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 1
                 IF JE-KIND(WS-SUB) NOT = 4 OR JE-FEATURE(WS-SUB) NOT = "minecraft:oak"
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 2
                 IF JE-KIND(WS-SUB) NOT = 4 OR JE-FEATURE(WS-SUB) NOT = "minecraft:flower_plain"
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN 3
                 IF JE-KIND(WS-SUB) NOT = 4 OR JE-FEATURE(WS-SUB) NOT = "minecraft:pile_hay"
                     ADD 1 TO WS-BAD
                 END-IF
             WHEN OTHER
                 IF JE-KIND(WS-SUB) NOT = 5 OR WS-SUB NOT = 1 OR JN-WEIGHT(JP-FIRST(WS-POOL) + WS-I) NOT = 2
                     ADD 1 TO WS-BAD
                 END-IF
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US12 36-3§5 plains decor entries in order: legacy single, features oak, flower_plain, pile_hay, then the shared empty element (row 1)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   5.5 the feature element: a box of one block, one synthetic jigsaw
     MOVE JN-ELEM(JP-FIRST(WS-POOL) + 1) TO WS-EL
     MOVE 1 TO WS-ROT
     CALL "JIG-EL-BOX" USING WS-EL WS-X WS-Y WS-Z WS-ROT WS-BOX
     MOVE "acceptance US12 36-3§5.5 a feature element's box is the single block at the position, whatever the rotation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-B(1) NOT = 10 OR WS-B(2) NOT = 20 OR WS-B(3) NOT = 30 OR WS-B(4) NOT = 10 OR WS-B(5) NOT = 20 OR WS-B(6) NOT = 30
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "JIG-EL-JIGS" USING WS-EL WS-X WS-Y WS-Z WS-ROT
     MOVE "acceptance US12 36-3§5.5 a feature element has one jigsaw at the position: front down (0), top south (3), rollable (2), no tag, priorities 0" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF JW-COUNT = 1 AND JW-X(1) = 10 AND JW-Y(1) = 20 AND JW-Z(1) = 30 AND JW-FRONT(1) = 0 AND JW-TOP(1) = 3 AND JW-JOINT(1) = 2
        AND JW-TAG(1) = 0 AND JW-PLACE(1) = 0 AND JW-SELECT(1) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   5.4 the empty element
     MOVE 1 TO WS-EL
     CALL "JIG-EL-JIGS" USING WS-EL WS-X WS-Y WS-Z WS-ROT
     MOVE "acceptance US12 36-3§5.4 the empty element is row 1: kind 5, terrain_matching, no jigsaw" TO TL-CASE
     MOVE 511 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = JE-KIND(1) * 100 + JE-PROJ(1) * 10 + 1 + JW-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-3-5.

 COPY NOSPAWN.
 COPY CORETEST.
