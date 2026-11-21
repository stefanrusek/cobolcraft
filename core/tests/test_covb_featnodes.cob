*> Implementation test (lane covB; docs/protocol/35-worldgen-features-*): the feature compilers' refusals. Each compiler (delta, stepped column, pillar, neighbor spread, patchy square, geode, dripstone
*> cluster, iceberg, end gateway/spike/podium options, weighted leaf provider, root system, the processor lists of templates) must mark a feature whose JSON is malformed or whose tables are missing
*> something as unsupported (FD-BAD / SP-BAD / ok 0) and must not partly compile it: no feature that the stage cannot run entirely is ever placed (the header of core/copy/FEATDATA.cpy).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-FEATNODES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY STRUCTPROC.
 COPY JSONDOC.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/nether7".
 01 WS-TEXT                PIC X(2000).
 01 WS-LEN                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-SAVED-KEY           PIC X(48).
 01 WS-SAVED-COUNT         BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NODE                BINARY-LONG VALUE 1.
 01 WS-INDEX               BINARY-LONG.
 01 WS-FTROW               BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
*>   The Nether features with nothing in them.
     MOVE '{"type":"minecraft:delta_feature"}' TO WS-TEXT
     PERFORM COMPILE-DELTA
     MOVE "covB 35-7 3 a delta feature without contents, rim and sizes is unsupported" TO TL-CASE
     PERFORM ASSERT-BAD
     MOVE '{"type":"minecraft:basalt_columns"}' TO WS-TEXT
     PERFORM COMPILE-STEP
     MOVE "covB 35-7 4 a column cluster without its members is unsupported" TO TL-CASE
     PERFORM ASSERT-BAD
     MOVE '{"direction":"up","cap_feature":5}' TO WS-TEXT
     PERFORM COMPILE-PILLAR
     MOVE "covB 35-7 5 a pillar whose cap is not a placed feature is unsupported" TO TL-CASE
     PERFORM ASSERT-BAD
     MOVE '{"direction":"sideways"}' TO WS-TEXT
     PERFORM COMPILE-PILLAR
     MOVE "covB 35-7 5 a pillar with a direction that is neither up nor down is unsupported" TO TL-CASE
     PERFORM ASSERT-BAD
     MOVE '{"direction":"down"}' TO WS-TEXT
     PERFORM COMPILE-PILLAR
     MOVE "covB 35-7 5 a pillar going down compiles with direction -1" TO TL-CASE
     MOVE -1 TO TL-EXPECTED-N
     MOVE WA-I(WS-ROW, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{}' TO WS-TEXT
     PERFORM COMPILE-SPREAD
     MOVE "covB 35-4 7.3 a neighbor spread without its members is unsupported" TO TL-CASE
     PERFORM ASSERT-BAD
     PERFORM COMPILE-PATCHY
     MOVE "covB 35-4 7.6 a patchy square without size and height is unsupported" TO TL-CASE
     PERFORM ASSERT-BAD
*>   A full work table: each compiler answers row 0 and marks the feature unsupported.
     MOVE FD-MAX-WA TO FD-WA-COUNT
     MOVE 0 TO FD-BAD
     CALL "FD-DELTA-NODE" USING JSON-DOC WS-NODE WS-ROW
     MOVE WS-ROW TO WS-ROW2
     CALL "FD-STEP-NODE" USING JSON-DOC WS-NODE WS-ROW
     ADD WS-ROW TO WS-ROW2
     CALL "FD-PILLAR-NODE" USING JSON-DOC WS-NODE WS-ROW
     ADD WS-ROW TO WS-ROW2
     CALL "FD-NSPREAD-NODE" USING JSON-DOC WS-NODE WS-ROW
     ADD WS-ROW TO WS-ROW2
     CALL "FD-PATCHY-NODE" USING JSON-DOC WS-NODE WS-ROW
     ADD WS-ROW TO WS-ROW2
     CALL "FD-ROOTSYS-NODE" USING JSON-DOC WS-NODE WS-ROW
     ADD WS-ROW TO WS-ROW2
     MOVE "covB 35-4 a full work table gives no row to any of the compilers" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 35-4 and marks the feature unsupported" TO TL-CASE
     PERFORM ASSERT-BAD
*>   The geode with a placement that is no block state, crack numbers and offsets that are no numbers and an empty wall distance.
     MOVE 0 TO FD-WA-COUNT
     MOVE '{"blocks":{"inner_placements":[5]},"crack":{"base_crack_size":"x","crack_point_offset":"x"},"outer_wall_distance":0,"point_offset":"x"}' TO WS-TEXT
     PERFORM COMPILE-GEODE
     MOVE "covB 35-7 a geode with unreadable placements, crack numbers, wall distance and point offset is unsupported" TO TL-CASE
     PERFORM ASSERT-BAD
*>   The dripstone cluster with none of its numbers, and then (the other case) with a block table without dripstone_block.
     MOVE 0 TO FD-WA-COUNT
     MOVE '{}' TO WS-TEXT
     PERFORM COMPILE-DRIP
     MOVE "covB 35-7 a dripstone cluster without its ratio and wind numbers is unsupported" TO TL-CASE
     PERFORM ASSERT-BAD
     MOVE "minecraft:dripstone_block" TO WS-KEY
     PERFORM HIDE-BLOCK
     MOVE '{}' TO WS-TEXT
     PERFORM COMPILE-DRIP
     PERFORM SHOW-BLOCK
     MOVE "covB 35-7 a block table without dripstone_block cannot compile a dripstone cluster" TO TL-CASE
     PERFORM ASSERT-BAD
*>   The iceberg needs six blocks of the table.
     MOVE "minecraft:blue_ice" TO WS-KEY
     PERFORM HIDE-BLOCK
     MOVE '{"state":{"Name":"minecraft:packed_ice"}}' TO WS-TEXT
     PERFORM COMPILE-ICEBERG
     PERFORM SHOW-BLOCK
     MOVE "covB 35-5 a block table without blue_ice cannot compile an iceberg" TO TL-CASE
     PERFORM ASSERT-BAD
*>   The end features: an inactive podium (false), a gateway exit of non-numbers, and a type the node does not know.
     MOVE 0 TO FD-WA-COUNT
     MOVE '{"active":false}' TO WS-TEXT
     MOVE 14 TO WS-TYPE
     PERFORM COMPILE-END
     MOVE "covB 35-7 an end podium feature with active false is inactive and valid" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FD-BAD * 10 + FT-A(WS-FTROW)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"exact":true,"exit":["a","b","c"]}' TO WS-TEXT
     MOVE 11 TO WS-TYPE
     PERFORM COMPILE-END
     MOVE "covB 35-7 an end gateway whose exit holds no numbers is unsupported" TO TL-CASE
     PERFORM ASSERT-BAD
     MOVE '{}' TO WS-TEXT
     MOVE 99 TO WS-TYPE
     PERFORM COMPILE-END
     MOVE "covB 35-7 an end feature type of no known kind is accepted without members" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE FD-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The weighted leaf provider: no entries, entries that are no array, an object state, a mixed state count, no weight sum and an unknown block.
     MOVE '{"type":"minecraft:weighted"}' TO WS-TEXT
     PERFORM COMPILE-LEAVES
     MOVE "covB 35-2 4 a weighted provider without entries is not a leaf provider" TO TL-CASE
     PERFORM ASSERT-NOT-OK
     MOVE '{"type":"minecraft:weighted","entries":5}' TO WS-TEXT
     PERFORM COMPILE-LEAVES
     MOVE "covB 35-2 4 entries that are no array are refused" TO TL-CASE
     PERFORM ASSERT-NOT-OK
     MOVE '{"type":"minecraft:weighted","entries":[{"data":{"Name":"minecraft:oak_leaves"},"weight":1}]}' TO WS-TEXT
     PERFORM COMPILE-LEAVES
     MOVE "covB 35-2 4 an entry whose data is a state object is read" TO TL-CASE
     PERFORM ASSERT-OK
     MOVE '{"type":"minecraft:weighted","entries":[{"data":"minecraft:oak_leaves","weight":1},{"data":"minecraft:stone","weight":1}]}' TO WS-TEXT
     PERFORM COMPILE-LEAVES
     MOVE "covB 35-2 4 entries whose blocks have different numbers of states are refused" TO TL-CASE
     PERFORM ASSERT-NOT-OK
     MOVE '{"type":"minecraft:weighted","entries":[{"data":"minecraft:oak_leaves","weight":0}]}' TO WS-TEXT
     PERFORM COMPILE-LEAVES
     MOVE "covB 35-2 4 weights that sum to 0 are refused" TO TL-CASE
     PERFORM ASSERT-NOT-OK
     MOVE '{"type":"minecraft:weighted","entries":[{"data":"minecraft:no_such_leaves","weight":1}]}' TO WS-TEXT
     PERFORM COMPILE-LEAVES
     MOVE "covB 35-2 4 an unknown block is refused" TO TL-CASE
     PERFORM ASSERT-NOT-OK
*>   Processor lists of templates: a full list table, a member that is no array and too many processors.
     MOVE SP-LIST-COUNT TO WS-SAVED-COUNT
     MOVE SP-MAX-LISTS TO SP-LIST-COUNT
     MOVE '{"processors":[]}' TO WS-TEXT
     PERFORM PARSE-IT
     CALL "STRUCT-PROC-INLINE" USING JSON-DOC WS-NODE WS-INDEX
     MOVE WS-SAVED-COUNT TO SP-LIST-COUNT
     MOVE "covB 36 a full list table gives no inline processor list" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE '{"processors":5}' TO WS-TEXT
     PERFORM PARSE-IT
     CALL "STRUCT-PROC-INLINE" USING JSON-DOC WS-NODE WS-INDEX
     MOVE "covB 36 a processors member that is no array gives no list" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SP-PROC-COUNT TO WS-SAVED-COUNT
     MOVE SP-MAX-PROCS TO SP-PROC-COUNT
     MOVE '{"processors":[{"processor_type":"minecraft:nop"}]}' TO WS-TEXT
     PERFORM PARSE-IT
     CALL "STRUCT-PROC-INLINE" USING JSON-DOC WS-NODE WS-INDEX
     MOVE WS-SAVED-COUNT TO SP-PROC-COUNT
     MOVE "covB 36 more processors than the table holds give no list" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-INDEX TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 PARSE-IT.
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT TRAILING))
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     .
 COMPILE-DELTA.
     PERFORM PARSE-IT
     MOVE 0 TO FD-WA-COUNT FD-BAD
     CALL "FD-DELTA-NODE" USING JSON-DOC WS-NODE WS-ROW
     .
 COMPILE-STEP.
     PERFORM PARSE-IT
     MOVE 0 TO FD-WA-COUNT FD-BAD
     CALL "FD-STEP-NODE" USING JSON-DOC WS-NODE WS-ROW
     .
 COMPILE-PILLAR.
     PERFORM PARSE-IT
     MOVE 0 TO FD-WA-COUNT FD-BAD
     CALL "FD-PILLAR-NODE" USING JSON-DOC WS-NODE WS-ROW
     .
 COMPILE-SPREAD.
     PERFORM PARSE-IT
     MOVE 0 TO FD-WA-COUNT FD-BAD
     CALL "FD-NSPREAD-NODE" USING JSON-DOC WS-NODE WS-ROW
     .
 COMPILE-PATCHY.
     PERFORM PARSE-IT
     MOVE 0 TO FD-WA-COUNT FD-BAD
     CALL "FD-PATCHY-NODE" USING JSON-DOC WS-NODE WS-ROW
     .
 COMPILE-GEODE.
     PERFORM PARSE-IT
     MOVE 0 TO FD-WA-COUNT FD-BAD
     CALL "FD-GEODE-NODE" USING JSON-DOC WS-NODE WS-ROW
     .
 COMPILE-DRIP.
     PERFORM PARSE-IT
     MOVE 0 TO FD-WA-COUNT FD-BAD
     CALL "FD-DRIP-NODE" USING JSON-DOC WS-NODE WS-ROW
     .
 COMPILE-ICEBERG.
     PERFORM PARSE-IT
     MOVE 0 TO FD-WA-COUNT FD-BAD
     CALL "FD-ICEBERG-NODE" USING JSON-DOC WS-NODE WS-ROW
     .
 COMPILE-END.
     PERFORM PARSE-IT
     MOVE 0 TO FD-WA-COUNT FD-BAD
     CALL "FD-END-NODE" USING JSON-DOC WS-NODE WS-TYPE WS-FTROW
     .
 COMPILE-LEAVES.
     PERFORM PARSE-IT
     MOVE 0 TO FD-WA-COUNT FD-BAD
     CALL "FD-TREE-LEAFPROV" USING JSON-DOC WS-NODE WS-FTROW WS-OK
     .
 HIDE-BLOCK.
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-IDX
     MOVE CB-KEY(WS-IDX) TO WS-SAVED-KEY
     MOVE "covb_hidden" TO CB-KEY(WS-IDX)
     .
 SHOW-BLOCK.
     MOVE WS-SAVED-KEY TO CB-KEY(WS-IDX)
     .
 ASSERT-BAD.
     MOVE 1 TO TL-EXPECTED-N
     MOVE FD-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 ASSERT-OK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 ASSERT-NOT-OK.
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OK TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-COVB-FEATNODES.
 COPY NOSPAWN.
 COPY CORETEST.
