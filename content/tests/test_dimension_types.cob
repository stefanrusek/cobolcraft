*> Test of the dimension loaders (T0226; docs/protocol/04-registry-sync.md section 6 (dimension_type), 23 sections 7.3.3 and
*> 9.5, 10 section 5, 37-nether-1 sections 1 and 2, 38-end). DIMENSION-TYPES-LOAD USING root (PIC X(1100): the folder
*> that holds data/), status out (CT-OK, or CT-BAD-DATA with every error on standard error as "ERROR registry:
*> dimension type <key>: <detail>"; nothing of the failed registry stays loaded): the files of data/<namespace>/
*> dimension_type become function rows of kind 10 (domain 17 nodes: the integers 1 has_fixed_time, 2 has_skylight,
*> 3 has_ceiling, 4 has_ender_dragon_fight, 5 min_y, 6 height, 7 logical_height, 8 monster_spawn_block_light_limit, 9 skybox
*> (0 overworld, 1 none, 2 end), 10 cardinal_light (0 default, 1 nether); the numbers coordinate_scale and ambient_light;
*> infiniburn as text; the monster_spawn_light_level as an int provider child) with the constructor checks of 04: height
*> a multiple of 16 and at least 16, min_y a multiple of 16, min_y + height at most 2032, logical_height at most height.
*> DIMENSION-DEFINITION-AT USING index (1 to 3: the standard overworld, the_nether, the_end), dimension key out, dimension type
*> key out, biome source out ("multi_noise" or "the_end"), biome source preset out (spaces for the End), noise settings
*> key out (every output PIC X(40); the key is spaces for an index outside). DIMENSION-HEIGHTS USING index, min_y out,
*> height out, logical height out, sea level out (BINARY-LONG), status out (CT-OK; CT-NO-DIMENSION when the
*> dimension type is not loaded; CT-NOT-FOUND when the index is outside or the noise settings are not loaded).
*> Fixture tree: content/tests/fixtures/worldgen (the three dimension types of the contract's valid tree).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DIMENSION-TYPES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTWORLDGEN.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-NODE                BINARY-LONG.
 01 WS-NODE-2              BINARY-LONG.
 01 WS-LABEL               PIC X(70).
 01 WS-GOT-N               BINARY-LONG.
 01 WS-WANT-N              BINARY-LONG.
 01 WS-GOT-T               PIC X(200).
 01 WS-WANT-T              PIC X(200).
 01 WS-GOT-F               USAGE FLOAT-LONG.
 01 WS-BITS                BINARY-DOUBLE.
 01 WS-WANT-BITS           BINARY-DOUBLE.
 01 WS-T                   PIC X(70).
 01 WS-N                   BINARY-LONG.
 01 WS-N-TEXT              PIC Z(4)9.
 01 WS-INDEX               BINARY-LONG.
 01 WS-D-KEY               PIC X(40).
 01 WS-D-TYPE              PIC X(40).
 01 WS-D-SOURCE            PIC X(40).
 01 WS-D-PRESET            PIC X(40).
 01 WS-D-SETTINGS          PIC X(40).
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-LOGICAL             BINARY-LONG.
 01 WS-SEA                 BINARY-LONG.
 01 WS-BODY                PIC X(700).
 01 WS-COMMAND             PIC X(1000).
 PROCEDURE DIVISION.
     MOVE "content/tests/fixtures/worldgen" TO WS-DIR
     MOVE 10 TO WS-KIND

*>   Before any load nothing is found, and a height lookup finds no dimension type.
     MOVE "minecraft:overworld" TO WS-KEY
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-NODE
     MOVE "dimension type: nothing is found before a load" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NODE TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-INDEX
     PERFORM HEIGHTS-OF
     MOVE "heights: no dimension type loaded" TO TL-CASE
     MOVE CT-NO-DIMENSION TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

     CALL "DIMENSION-TYPES-LOAD" USING WS-DIR WS-STATUS
     MOVE "dimension type: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "dimension type: 3 dimension types" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-N
     MOVE "minecraft:overworld" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 2 TO WS-N
     MOVE "minecraft:the_end" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 3 TO WS-N
     MOVE "minecraft:the_nether" TO WS-WANT-T
     PERFORM ASSERT-ORDER

*>   The overworld row (04 6, 10 5): min_y -64, height 384, a uniform 0 to 7 spawn light level.
     MOVE "minecraft:overworld" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "min_y" TO WS-LABEL
     MOVE -64 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 5) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "height" TO WS-LABEL
     MOVE 384 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 6) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "logical_height" TO WS-LABEL
     MOVE WGN-INT(WS-NODE, 7) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "has_skylight" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "has_ceiling" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "coordinate_scale bits of 1.0" TO WS-LABEL
     MOVE 4607182418800017408 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "ambient_light bits of 0.0" TO WS-LABEL
     MOVE 0 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 2) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "infiniburn" TO WS-LABEL
     MOVE "#minecraft:infiniburn_overworld" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "skybox overworld" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 9) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "cardinal_light default" TO WS-LABEL
     MOVE WGN-INT(WS-NODE, 10) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE "spawn light level max 7" TO WS-LABEL
     MOVE 7 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE-2, 2) TO WS-GOT-N
     PERFORM EXPECT-N

     MOVE "minecraft:the_nether" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "min_y" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 5) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "height" TO WS-LABEL
     MOVE 256 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 6) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "logical_height" TO WS-LABEL
     MOVE 128 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 7) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "coordinate_scale bits of 8.0" TO WS-LABEL
     MOVE 4620693217682128896 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "ambient_light bits of 0.1" TO WS-LABEL
     MOVE 4591870180066957722 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 2) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "has_fixed_time" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "has_ceiling" TO WS-LABEL
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "skybox none" TO WS-LABEL
     MOVE WGN-INT(WS-NODE, 9) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "cardinal_light nether" TO WS-LABEL
     MOVE WGN-INT(WS-NODE, 10) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "monster_spawn_block_light_limit" TO WS-LABEL
     MOVE 15 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 8) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE "constant spawn light level" TO WS-LABEL
     MOVE 7 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE-2, 1) TO WS-GOT-N
     PERFORM EXPECT-N

     MOVE "minecraft:the_end" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "has_ender_dragon_fight" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "skybox end" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 9) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "ambient_light bits of 0.25" TO WS-LABEL
     MOVE 4598175219545276416 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 2) TO WS-GOT-F
     PERFORM EXPECT-BITS

*>   The three dimension definitions (10 5, 37-1 1, 38).
     MOVE 1 TO WS-INDEX
     PERFORM DEFINITION-OF
     MOVE "overworld" TO WS-LABEL
     MOVE "minecraft:overworld" TO WS-WANT-T
     MOVE WS-D-KEY TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "overworld type" TO WS-LABEL
     MOVE WS-D-TYPE TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "overworld biome source" TO WS-LABEL
     MOVE "multi_noise" TO WS-WANT-T
     MOVE WS-D-SOURCE TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "overworld preset" TO WS-LABEL
     MOVE "minecraft:overworld" TO WS-WANT-T
     MOVE WS-D-PRESET TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "overworld noise settings" TO WS-LABEL
     MOVE WS-D-SETTINGS TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE 2 TO WS-INDEX
     PERFORM DEFINITION-OF
     MOVE "nether" TO WS-LABEL
     MOVE "minecraft:the_nether" TO WS-WANT-T
     MOVE WS-D-KEY TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "nether type" TO WS-LABEL
     MOVE WS-D-TYPE TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "nether preset" TO WS-LABEL
     MOVE "minecraft:nether" TO WS-WANT-T
     MOVE WS-D-PRESET TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "nether noise settings" TO WS-LABEL
     MOVE WS-D-SETTINGS TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE 3 TO WS-INDEX
     PERFORM DEFINITION-OF
     MOVE "end" TO WS-LABEL
     MOVE "minecraft:the_end" TO WS-WANT-T
     MOVE WS-D-KEY TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "end type" TO WS-LABEL
     MOVE WS-D-TYPE TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "end biome source" TO WS-LABEL
     MOVE "the_end" TO WS-WANT-T
     MOVE WS-D-SOURCE TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "end has no preset" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE WS-D-PRESET TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "end noise settings" TO WS-LABEL
     MOVE "minecraft:end" TO WS-WANT-T
     MOVE WS-D-SETTINGS TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE 4 TO WS-INDEX
     PERFORM DEFINITION-OF
     MOVE "no fourth dimension" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     MOVE WS-D-KEY TO WS-GOT-T
     PERFORM EXPECT-T

*>   Heights: the dimension type with the sea level of the noise settings (10 5: -64, 384, 63).
     MOVE 1 TO WS-INDEX
     PERFORM HEIGHTS-OF
     MOVE "heights: the settings are not loaded" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "NOISE-SETTINGS-LOAD" USING WS-DIR WS-STATUS
     PERFORM HEIGHTS-OF
     MOVE "heights: overworld loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "heights: overworld min_y" TO TL-CASE
     MOVE -64 TO TL-EXPECTED-N
     MOVE WS-MIN-Y TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "heights: overworld height" TO TL-CASE
     MOVE 384 TO TL-EXPECTED-N
     MOVE WS-HEIGHT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "heights: overworld logical height" TO TL-CASE
     MOVE WS-LOGICAL TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "heights: overworld sea level" TO TL-CASE
     MOVE 63 TO TL-EXPECTED-N
     MOVE WS-SEA TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 2 TO WS-INDEX
     PERFORM HEIGHTS-OF
     MOVE "heights: nether logical height" TO TL-CASE
     MOVE 128 TO TL-EXPECTED-N
     MOVE WS-LOGICAL TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "heights: nether sea level" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-SEA TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 3 TO WS-INDEX
     PERFORM HEIGHTS-OF
     MOVE "heights: the End settings are not in the fixture" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 4 TO WS-INDEX
     PERFORM HEIGHTS-OF
     MOVE "heights: index 4 is outside" TO TL-CASE
     MOVE CT-NOT-FOUND TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE"

*>   Failures (04 6 constructor checks, ranges of 23 9.5).
     MOVE "a height of 8" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":0,"height":8,"logical_height":8,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a height of 24" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":0,"height":24,"logical_height":16,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a min_y of 8" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":8,"height":32,"logical_height":32,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "min_y plus height over 2032" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":2000,"height":64,"logical_height":64,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a min_y below -2032" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":-2048,"height":64,"logical_height":64,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a height over 4064" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":-2032,"height":4080,"logical_height":64,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a logical_height over the height" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":0,"height":64,"logical_height":80,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a negative logical_height" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":0,"height":64,"logical_height":-1,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a coordinate_scale of 0" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":0.0,"min_y":0,"height":64,"logical_height":64,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a coordinate_scale over 3.0E7" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":4.0E7,"min_y":0,"height":64,"logical_height":64,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a block light limit of 16" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":0,"height":64,"logical_height":64,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":16}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a dimension type without has_skylight" TO WS-T
     MOVE '{"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":0,"height":64,"logical_height":64,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a dimension type without a spawn light level" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":0,"height":64,"logical_height":64,"ambient_light":0.0,"monster_spawn_block_light_limit":0}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a skybox of sky" TO WS-T
     MOVE '{"has_skylight":true,"has_ceiling":false,"has_ender_dragon_fight":false,"coordinate_scale":1.0,"min_y":0,"height":64,"logical_height":64,"ambient_light":0.0,"monster_spawn_light_level":7,"monster_spawn_block_light_limit":0,"skybox":"sky"}' TO WS-BODY
     PERFORM DIMENSION-FAILS
     MOVE "a dimension type that is no object" TO WS-T
     MOVE '[]' TO WS-BODY
     PERFORM DIMENSION-FAILS
     STOP RUN.

 FRESH-TREE.
     MOVE "build/content-test/worldgen/t" TO WS-DIR
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/worldgen 2>/dev/null; rm -rf build/content-test/worldgen; mkdir -p build/content-test/worldgen && cp -R content/tests/fixtures/worldgen build/content-test/worldgen/t".

 DIMENSION-FAILS.
     PERFORM FRESH-TREE
     MOVE SPACES TO WS-COMMAND
     STRING "printf '%s' '" FUNCTION TRIM(WS-BODY) "' > build/content-test/worldgen/t/data/minecraft/dimension_type/bad.json"
         DELIMITED BY SIZE INTO WS-COMMAND
     CALL "SYSTEM" USING WS-COMMAND
     CALL "DIMENSION-TYPES-LOAD" USING WS-DIR WS-STATUS
     MOVE SPACES TO TL-CASE
     STRING "worldgen: " FUNCTION TRIM(WS-T) " is CT-BAD-DATA" DELIMITED BY SIZE INTO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE SPACES TO TL-CASE
     STRING "worldgen: after " FUNCTION TRIM(WS-T) " nothing stays loaded" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE".

 DEFINITION-OF.
     CALL "DIMENSION-DEFINITION-AT" USING WS-INDEX WS-D-KEY WS-D-TYPE WS-D-SOURCE WS-D-PRESET WS-D-SETTINGS.

 HEIGHTS-OF.
     CALL "DIMENSION-HEIGHTS" USING WS-INDEX WS-MIN-Y WS-HEIGHT WS-LOGICAL WS-SEA WS-STATUS.

 FIND-NODE.
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-NODE
     IF WS-NODE = 0
         MOVE 1 TO WS-NODE
     END-IF.

 ASSERT-ORDER.
     MOVE WGF-KEY(WS-N) TO WS-GOT-T
     MOVE WS-N TO WS-N-TEXT
     MOVE SPACES TO TL-CASE
     STRING "worldgen: listing position " WS-N-TEXT DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-T TO TL-EXPECTED
     MOVE WS-GOT-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 EXPECT-N.
     MOVE SPACES TO TL-CASE
     STRING "dimension: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT-N TO TL-EXPECTED-N
     MOVE WS-GOT-N TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 EXPECT-T.
     MOVE SPACES TO TL-CASE
     STRING "dimension: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-T TO TL-EXPECTED
     MOVE WS-GOT-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 EXPECT-BITS.
     CALL STATIC "cc_f64_f64_bits" USING BY REFERENCE WS-GOT-F WS-BITS
     MOVE SPACES TO TL-CASE
     STRING "dimension: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT-BITS TO TL-EXPECTED-N
     MOVE WS-BITS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
