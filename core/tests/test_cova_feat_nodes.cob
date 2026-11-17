*> Implementation test (coverage lane A; docs/protocol/35-worldgen-features-1, 4, 5, 7; core/src/feat-data.cob, feat-bonus.cob, feat-ice.cob, feat-magma.cob, feat-blob.cob, feat-fossil.cob,
*> feat-template.cob): the data of a feature that cannot be compiled whole makes it unsupported (feature type -1, FD-BAD for the node): a bonus chest or blue ice or magma feature while its
*> block is absent from the block table (the row is hidden by a zero key length), an exhausted work-area table, missing members, an inline template list with a missing id, a negative weight
*> and a bad rotation list, a uniform entry with min above max, fixed placement positions that are absent or no triples, and the nether features given no members.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-FEAT-NODES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY FEATDATA.
 COPY JSONDOC.
 COPY STRUCTDATA.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/water".
 01 WS-TEXT                PIC X(1024).
 01 WS-LEN                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-IDX                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-SAVED-LEN           BINARY-LONG.
 01 WS-SAVED-WA            BINARY-LONG.
 01 WS-P.
    05 WS-V                BINARY-LONG OCCURS 4 TIMES.
 01 WS-OK                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAMES.
    05 FILLER              PIC X(40) VALUE "minecraft:delta_feature".
    05 FILLER              PIC X(40) VALUE "minecraft:stepped_column_cluster".
    05 FILLER              PIC X(40) VALUE "minecraft:single_block_pillar".
    05 FILLER              PIC X(40) VALUE "minecraft:random_neighbor_spread".
    05 FILLER              PIC X(40) VALUE "minecraft:projected_random_patchy_square".
    05 FILLER              PIC X(40) VALUE "minecraft:block_blob".
 01 WS-NAME-T REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(40) OCCURS 6 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
*>   The nether features and the forest rock given no members are unsupported.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE SPACES TO WS-TEXT
         STRING '{"type": "' FUNCTION TRIM(WS-NAME(WS-I)) '"}' DELIMITED BY SIZE INTO WS-TEXT
         PERFORM COMPILE-FEATURE
         MOVE SPACES TO WS-CASE
         STRING "test cova feat nodes a feature of type " FUNCTION TRIM(WS-NAME(WS-I)) " without members is unsupported" DELIMITED BY SIZE INTO WS-CASE
         MOVE -1 TO WS-E
         MOVE FT-TYPE(WS-IDX) TO WS-O
         CALL "CA-N" USING WS-CASE WS-E WS-O
     END-PERFORM
*>   A bonus chest while chest is absent, then torch, then with the work-area table full.
     MOVE "minecraft:chest" TO WS-KEY
     PERFORM HIDE-BLOCK
     MOVE '{"type": "minecraft:bonus_chest"}' TO WS-TEXT
     PERFORM COMPILE-FEATURE
     PERFORM SHOW-BLOCK
     MOVE "test cova feat nodes a bonus chest without a chest block is unsupported" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE FT-TYPE(WS-IDX) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "minecraft:torch" TO WS-KEY
     PERFORM HIDE-BLOCK
     PERFORM COMPILE-FEATURE
     PERFORM SHOW-BLOCK
     MOVE "test cova feat nodes a bonus chest without a torch block is unsupported" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE FT-TYPE(WS-IDX) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE FD-WA-COUNT TO WS-SAVED-WA
     MOVE FD-MAX-WA TO FD-WA-COUNT
     PERFORM COMPILE-FEATURE
     MOVE "test cova feat nodes a bonus chest with a full work-area table is unsupported" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE FT-TYPE(WS-IDX) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   The work-area table full also stops magma, fossil and template nodes.
     MOVE '{"type": "minecraft:underwater_magma"}' TO WS-TEXT
     PERFORM COMPILE-FEATURE
     MOVE FT-TYPE(WS-IDX) TO WS-O
     MOVE "test cova feat nodes magma with a full work-area table is unsupported" TO WS-CASE
     MOVE -1 TO WS-E
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE '{"type": "minecraft:fossil"}' TO WS-TEXT
     PERFORM COMPILE-FEATURE
     MOVE FT-TYPE(WS-IDX) TO WS-O
     MOVE "test cova feat nodes a fossil with a full work-area table is unsupported" TO WS-CASE
     MOVE -1 TO WS-E
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE WS-SAVED-WA TO FD-WA-COUNT
*>   Magma: members missing (ints and the double), then complete but the magma block hidden.
     MOVE '{"type": "minecraft:underwater_magma"}' TO WS-TEXT
     PERFORM COMPILE-FEATURE
     MOVE "test cova feat nodes magma without its members is unsupported" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE FT-TYPE(WS-IDX) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "minecraft:magma_block" TO WS-KEY
     PERFORM HIDE-BLOCK
     MOVE SPACES TO WS-TEXT
     MOVE '{"type": "minecraft:underwater_magma", "floor_search_range": 5, "placement_radius_around_floor": 1, "placement_probability_per_valid_position": 0.5}' TO WS-TEXT
     PERFORM COMPILE-FEATURE
     PERFORM SHOW-BLOCK
     MOVE "test cova feat nodes magma without the magma block is unsupported" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE FT-TYPE(WS-IDX) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Blue ice without its blocks.
     MOVE "minecraft:blue_ice" TO WS-KEY
     PERFORM HIDE-BLOCK
     MOVE '{"type": "minecraft:blue_ice"}' TO WS-TEXT
     PERFORM COMPILE-FEATURE
     PERFORM SHOW-BLOCK
     MOVE "test cova feat nodes blue ice without the blue_ice block is unsupported" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE FT-TYPE(WS-IDX) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   Template lists: a missing id, a negative weight, an accepted rotation list and a bad one; with and without a template root of the structure data.
     MOVE SPACES TO SD-DIR
     MOVE '{"type": "minecraft:template", "templates": [{"data": {"rotations": ["none", "minecraft:clockwise_90"]}, "weight": -1}, {"data": {"id": "x", "rotations": 5}, "weight": 1}]}' TO WS-TEXT
     PERFORM COMPILE-FEATURE
     MOVE "test cova feat nodes a template list with a missing id, a negative weight and a bad rotation list is unsupported" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE FT-TYPE(WS-IDX) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE '{"type": "minecraft:fossil"}' TO WS-TEXT
     PERFORM COMPILE-FEATURE
     MOVE "test cova feat nodes a fossil feature without members is unsupported" TO WS-CASE
     MOVE -1 TO WS-E
     MOVE FT-TYPE(WS-IDX) TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A uniform entry whose minimum is above its maximum is refused by the weighted list; fixed placement without positions or with bad ones.
     MOVE '{"type": "minecraft:weighted_list", "distribution": [{"data": {"type": "minecraft:uniform", "min_inclusive": 5, "max_inclusive": 1}, "weight": 1}]}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-J-IP" USING JSON-DOC WS-ONE WS-P WS-OK
     MOVE "test cova feat nodes a weighted list with a uniform entry 5 to 1 is refused" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-OK TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO FD-BAD
     MOVE '{"type": "minecraft:fixed_placement"}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-MD-NODE" USING JSON-DOC WS-ONE
     MOVE "test cova feat nodes a fixed placement without positions is unsupported" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FD-BAD TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE 0 TO FD-BAD
     MOVE '{"type": "minecraft:fixed_placement", "positions": [[1, 2]]}' TO WS-TEXT
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-MD-NODE" USING JSON-DOC WS-ONE
     MOVE "test cova feat nodes a fixed placement position that is no triple is unsupported" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE FD-BAD TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.

 COMPILE-FEATURE.
     MOVE 0 TO FD-BAD
     MOVE 0 TO WS-IDX
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEXT)) TO WS-LEN
     CALL "JSON-PARSE" USING JSON-DOC WS-TEXT WS-LEN
     CALL "FD-FEAT-NODE" USING JSON-DOC WS-ONE WS-IDX.
 HIDE-BLOCK.
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-BLK
     MOVE CB-KEY-LENGTH(WS-BLK) TO WS-SAVED-LEN
     MOVE 0 TO CB-KEY-LENGTH(WS-BLK).
 SHOW-BLOCK.
     MOVE WS-SAVED-LEN TO CB-KEY-LENGTH(WS-BLK).

 END PROGRAM TEST-COVA-FEAT-NODES.
 COPY CORETEST.
 COPY COVATEST.
