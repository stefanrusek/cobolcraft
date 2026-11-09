*> Test of the biome loaders (T0222; docs/protocol/10-world-generation-terrain.md section 7, 37-nether-3 sections 2 and 6,
*> 43 section 5). BIOMES-LOAD and BIOME-SOURCES-LOAD USING root (PIC X(1100): the folder that holds data/), status out
*> (CT-OK, or CT-BAD-DATA with every error on standard error as "ERROR registry: biome <key>: <detail>"; nothing of
*> the failed registry stays loaded): worldgen/biome files become function rows of kind 7 (domain 13 nodes: climate
*> numbers, the colours of 43 5 as 24 bit RGB values, the carvers as one text, the placed features per decoration
*> step as a chain of domain 14 nodes) and worldgen/multi_noise_biome_source_parameter_list files rows of kind 9 (the
*> preset: 0 minecraft:overworld, 1 minecraft:nether). BIOME-SOURCE-POINT-COUNT USING preset, count out and
*> BIOME-SOURCE-POINT USING preset, index, biome out (PIC X(40)), values out (seven BINARY-LONG: T, H, C, E, D, W,
*> offset, quantised): the five parameter points of the Nether preset (37-3 2.2); the overworld list is code
*> (10 7.4) and not stored. Fixture tree: content/tests/fixtures/worldgen (3 biomes, 2 sources).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLDGEN-BIOMES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONTENT.
 COPY CTWORLDGEN.
 01 WS-DIR                 PIC X(1100).
 01 WS-STATUS              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 PIC X(64).
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
 01 WS-PRESET              BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-VALUES.
    05 WS-V                BINARY-LONG OCCURS 7 TIMES.
 01 WS-TEXT                PIC X(60).
 PROCEDURE DIVISION.
     MOVE "content/tests/fixtures/worldgen" TO WS-DIR
     MOVE 7 TO WS-KIND

*>   Before any load nothing is found.
     MOVE "minecraft:plains" TO WS-KEY
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-NODE
     MOVE "biome: nothing is found before a load" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NODE TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

     CALL "BIOMES-LOAD" USING WS-DIR WS-STATUS
     MOVE "biome: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "biome: 3 biomes" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-N
     MOVE "minecraft:nether_wastes" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 3 TO WS-N
     MOVE "minecraft:swamp" TO WS-WANT-T
     PERFORM ASSERT-ORDER

*>   plains: the integer form of a colour, a #RRGGBB attribute, no overrides (-1), features by decoration step.
     MOVE "minecraft:plains" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "temperature bits of 0.8" TO WS-LABEL
     MOVE 4605380978949069210 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "downfall bits of 0.4" TO WS-LABEL
     MOVE 4600877379321698714 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 2) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "has_precipitation" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "temperature_modifier none" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "water_color as written" TO WS-LABEL
     MOVE 4159204 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "foliage_color left out" TO WS-LABEL
     MOVE -1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "dry_foliage_color left out" TO WS-LABEL
     MOVE WGN-INT(WS-NODE, 5) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "grass_color left out" TO WS-LABEL
     MOVE WGN-INT(WS-NODE, 6) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "grass_color_modifier none" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 7) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "sky_color #78a7ff" TO WS-LABEL
     MOVE 7907327 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 8) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "fog_color left out" TO WS-LABEL
     MOVE -1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 9) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "water_fog_color left out" TO WS-LABEL
     MOVE WGN-INT(WS-NODE, 10) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "carvers list joined" TO WS-LABEL
     MOVE "minecraft:cave minecraft:cave_extra_underground minecraft:canyon" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE "first feature is of step 2" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE-2, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "first feature id" TO WS-LABEL
     MOVE "minecraft:lake_lava_underground" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE-2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-NEXT(WS-NODE-2) TO WS-NODE-2
     MOVE "second feature is of step 4" TO WS-LABEL
     MOVE 4 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE-2, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "second feature id" TO WS-LABEL
     MOVE "minecraft:patch_grass_plain" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE-2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WGN-NEXT(WS-NODE-2) TO WS-NODE-2
     MOVE "third feature keeps the order of its list" TO WS-LABEL
     MOVE "minecraft:flower_plains" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE-2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "no fourth feature" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-NEXT(WS-NODE-2) TO WS-GOT-N
     PERFORM EXPECT-N

*>   swamp: #RRGGBB, a float list (floor(v * 255)), an object with an argument, a modifier.
     MOVE "minecraft:swamp" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "downfall bits of 0.9" TO WS-LABEL
     MOVE 4606281698874543309 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 2) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "temperature_modifier frozen" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "water_color #617B64" TO WS-LABEL
     MOVE 6388580 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "foliage_color of [1.0, 0.5, 0.0]" TO WS-LABEL
     MOVE 16744192 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "dry_foliage_color as written" TO WS-LABEL
     MOVE 1193046 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 5) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "grass_color #00ff10" TO WS-LABEL
     MOVE 65296 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 6) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "grass_color_modifier swamp" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 7) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "fog_color from an argument" TO WS-LABEL
     MOVE 12638463 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 9) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "water_fog_color as written" TO WS-LABEL
     MOVE 329011 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 10) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "a single carver is a text" TO WS-LABEL
     MOVE "minecraft:cave" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "an empty feature list gives no node" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N

*>   nether_wastes: dark_forest modifier, no precipitation, step 7.
     MOVE "minecraft:nether_wastes" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "temperature bits of 2.0" TO WS-LABEL
     MOVE 4611686018427387904 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "no precipitation" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "water_color #3f76e4 is 4159204" TO WS-LABEL
     MOVE 4159204 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "grass_color_modifier dark_forest" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 7) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE "feature step 7" TO WS-LABEL
     MOVE 7 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE-2, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "feature domain 14" TO WS-LABEL
     MOVE 14 TO WS-WANT-N
     MOVE WGN-DOMAIN(WS-NODE-2) TO WS-GOT-N
     PERFORM EXPECT-N
     CALL "WORLDGEN-FREE"

*>   The multi-noise biome source lists (37-3 2.1).
     MOVE 9 TO WS-KIND
     CALL "BIOME-SOURCES-LOAD" USING WS-DIR WS-STATUS
     MOVE "source: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "source: 2 lists" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "minecraft:nether" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "preset nether" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "minecraft:overworld" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "preset overworld" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     CALL "WORLDGEN-FREE"

*>   The code-defined points: five for the Nether (37-3 2.2), none stored for the overworld.
     MOVE 1 TO WS-PRESET
     CALL "BIOME-SOURCE-POINT-COUNT" USING WS-PRESET WS-COUNT
     MOVE "points: the Nether has 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 0 TO WS-PRESET
     CALL "BIOME-SOURCE-POINT-COUNT" USING WS-PRESET WS-COUNT
     MOVE "points: the overworld list is code, none stored" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-PRESET
     MOVE 1 TO WS-INDEX
     PERFORM POINT-OF
     MOVE "points: 1 nether_wastes" TO WS-TEXT
     MOVE "minecraft:nether_wastes" TO WS-WANT-T
     PERFORM EXPECT-POINT-BIOME
     MOVE 2 TO WS-INDEX
     PERFORM POINT-OF
     MOVE "points: 2 soul_sand_valley" TO WS-TEXT
     MOVE "minecraft:soul_sand_valley" TO WS-WANT-T
     PERFORM EXPECT-POINT-BIOME
     MOVE "points: soul_sand_valley humidity" TO TL-CASE
     MOVE -5000 TO TL-EXPECTED-N
     MOVE WS-V(2) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 4 TO WS-INDEX
     PERFORM POINT-OF
     MOVE "points: 4 warped_forest" TO WS-TEXT
     MOVE "minecraft:warped_forest" TO WS-WANT-T
     PERFORM EXPECT-POINT-BIOME
     MOVE "points: warped_forest humidity" TO TL-CASE
     MOVE 5000 TO TL-EXPECTED-N
     MOVE WS-V(2) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "points: warped_forest offset" TO TL-CASE
     MOVE 3750 TO TL-EXPECTED-N
     MOVE WS-V(7) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 5 TO WS-INDEX
     PERFORM POINT-OF
     MOVE "points: basalt_deltas temperature" TO TL-CASE
     MOVE -5000 TO TL-EXPECTED-N
     MOVE WS-V(1) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "points: basalt_deltas offset" TO TL-CASE
     MOVE 1750 TO TL-EXPECTED-N
     MOVE WS-V(7) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 3 TO WS-INDEX
     PERFORM POINT-OF
     MOVE "points: crimson_forest temperature" TO TL-CASE
     MOVE 4000 TO TL-EXPECTED-N
     MOVE WS-V(1) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 6 TO WS-INDEX
     PERFORM POINT-OF
     MOVE "points: index 6 is outside" TO WS-TEXT
     MOVE SPACES TO WS-WANT-T
     PERFORM EXPECT-POINT-BIOME
     MOVE 0 TO WS-PRESET
     MOVE 1 TO WS-INDEX
     PERFORM POINT-OF
     MOVE "points: no overworld point" TO WS-TEXT
     MOVE SPACES TO WS-WANT-T
     PERFORM EXPECT-POINT-BIOME

*>   Biome failures (43 5, 37-3 6.1).
     MOVE "a biome without temperature" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":1},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a biome whose has_precipitation is a number" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":1,""effects"":{""water_color"":1},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a biome without a water_color" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a colour string of 6 characters" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":""#12345""},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a colour string with a bad digit" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":""#12g456""},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a colour string without a hash" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":""1234567""},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a colour list of two floats" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":[0.1,0.2]},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a colour list with a float over 1" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":[0.1,0.2,1.5]},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a colour list with a text" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":[0.1,0.2,""x""]},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a colour that is true" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":true},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a colour object without an argument" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":1},""attributes"":{""minecraft:visual/sky_color"":{""modifier"":""override""}},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a temperature_modifier of hot" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""temperature_modifier"":""hot"",""effects"":{""water_color"":1},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a grass_color_modifier that is a number" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":1,""grass_color_modifier"":3},""carvers"":[],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a biome without carvers" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":1},""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "carvers that is a number" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":1},""carvers"":4,""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "carvers with a number in the list" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":1},""carvers"":[""a"",4],""features"":[]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "carvers over 160 bytes" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "(printf '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":1},""carvers"":['; for i in $(seq 1 9); do printf '""minecraft:carver_number_%s"",' $i; done; printf '""z""],""features"":[]}') > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "features that is a number" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":1},""carvers"":[],""features"":4}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a feature step that is no list" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":1},""carvers"":[],""features"":[4]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a feature id that is a number" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""temperature"":1.0,""downfall"":0.4,""has_precipitation"":true,""effects"":{""water_color"":1},""carvers"":[],""features"":[[4]]}' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS
     MOVE "a biome file that is a list" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '[]' > build/content-test/worldgen/t/data/minecraft/worldgen/biome/bad.json"
     PERFORM BIOME-FAILS

*>   Biome source failures.
     MOVE "a biome source with an unknown preset" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""preset"":""minecraft:end""}' > build/content-test/worldgen/t/data/minecraft/worldgen/multi_noise_biome_source_parameter_list/bad.json"
     PERFORM SOURCE-FAILS
     MOVE "a biome source without a preset" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{}' > build/content-test/worldgen/t/data/minecraft/worldgen/multi_noise_biome_source_parameter_list/bad.json"
     PERFORM SOURCE-FAILS
     MOVE "a biome source whose preset is a number" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""preset"":3}' > build/content-test/worldgen/t/data/minecraft/worldgen/multi_noise_biome_source_parameter_list/bad.json"
     PERFORM SOURCE-FAILS
     STOP RUN.

 FRESH-TREE.
     MOVE "build/content-test/worldgen/t" TO WS-DIR
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/worldgen 2>/dev/null; rm -rf build/content-test/worldgen; mkdir -p build/content-test/worldgen && cp -R content/tests/fixtures/worldgen build/content-test/worldgen/t".

 BIOME-FAILS.
     CALL "BIOMES-LOAD" USING WS-DIR WS-STATUS
     PERFORM FAILED-LOAD.

 SOURCE-FAILS.
     CALL "BIOME-SOURCES-LOAD" USING WS-DIR WS-STATUS
     PERFORM FAILED-LOAD.

 FAILED-LOAD.
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
     MOVE SPACES TO TL-CASE
     STRING "worldgen: after " FUNCTION TRIM(WS-T) " no node stays" DELIMITED BY SIZE INTO TL-CASE
     MOVE WG-COUNT(WGK-NODE) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     CALL "WORLDGEN-FREE".

 POINT-OF.
     CALL "BIOME-SOURCE-POINT" USING WS-PRESET WS-INDEX WS-BIOME WS-VALUES.

 EXPECT-POINT-BIOME.
     MOVE WS-TEXT TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-T TO TL-EXPECTED
     MOVE WS-BIOME TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

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
     STRING "worldgen: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT-N TO TL-EXPECTED-N
     MOVE WS-GOT-N TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 EXPECT-T.
     MOVE SPACES TO TL-CASE
     STRING "worldgen: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-WANT-T TO TL-EXPECTED
     MOVE WS-GOT-T TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 EXPECT-BITS.
     CALL STATIC "cc_f64_f64_bits" USING BY REFERENCE WS-GOT-F WS-BITS
     MOVE SPACES TO TL-CASE
     STRING "worldgen: " FUNCTION TRIM(WS-KEY) " " FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-WANT-BITS TO TL-EXPECTED-N
     MOVE WS-BITS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM.

 ASSERT-NUM.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
