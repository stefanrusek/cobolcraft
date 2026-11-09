*> Test of the noise and density function loaders (T0220; docs/protocol/10-world-generation-terrain.md sections 3.3, 4.1 to
*> 4.3 and 5, 23 section 3). NOISES-LOAD and DENSITY-FUNCTIONS-LOAD USING root (PIC X(1100): the folder that holds
*> data/), status out (CT-OK, or CT-BAD-DATA with every error printed on standard error as "ERROR registry: noise <key>:
*> <detail>" or "... density function <key>: ..."; nothing of the failed registry stays loaded): the files of
*> data/<namespace>/worldgen/noise and worldgen/density_function become function rows (WGF-ROW of CTWORLDGEN.cpy,
*> kinds 8 and 1, listing order) over trees of nodes. WG-FIND USING kind, key (PIC X(64)), root node out (0 when not
*> found); WG-TYPE-AT USING type index, domain out, name out (PIC X(32)), field list out (PIC X(640)); WORLDGEN-FREE
*> empties the store. Numbers are read with cc_f64_from_text, so the bits of a double are those of its decimal text.
*> The fixture tree is content/tests/fixtures/worldgen (3 noises, 8 density functions); the failing trees are copies
*> of it under build/content-test/worldgen altered per case.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-WORLDGEN-NOISE.
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
 01 WS-NODE-3              BINARY-LONG.
 01 WS-LABEL               PIC X(70).
 01 WS-GOT-N               BINARY-LONG.
 01 WS-WANT-N              BINARY-LONG.
 01 WS-GOT-T               PIC X(200).
 01 WS-WANT-T              PIC X(200).
 01 WS-GOT-F               USAGE FLOAT-LONG.
 01 WS-BITS                BINARY-DOUBLE.
 01 WS-WANT-BITS           BINARY-DOUBLE.
 01 WS-DOMAIN              BINARY-LONG.
 01 WS-TYPE-NAME           PIC X(32).
 01 WS-FIELDS              PIC X(640).
 01 WS-T                   PIC X(70).
 01 WS-N                   BINARY-LONG.
 01 WS-N-TEXT              PIC Z(4)9.
 PROCEDURE DIVISION.
     MOVE "content/tests/fixtures/worldgen" TO WS-DIR

*>   Before any load nothing is found.
     MOVE 8 TO WS-KIND
     MOVE "minecraft:continentalness" TO WS-KEY
     CALL "WG-FIND" USING WS-KIND WS-KEY WS-NODE
     MOVE "noise: nothing is found before a load" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NODE TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   The noise definitions (10 3.3).
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     MOVE "noise: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "noise: 3 noises" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-N
     MOVE "minecraft:aquifer_barrier" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 3 TO WS-N
     MOVE "minecraft:offset" TO WS-WANT-T
     PERFORM ASSERT-ORDER

     MOVE "minecraft:continentalness" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "base_octave" TO WS-LABEL
     MOVE -9 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "octave_count" TO WS-LABEL
     MOVE 3 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "base_amplitude bits of 1.0" TO WS-LABEL
     MOVE 4607182418800017408 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "three amplitude modifiers" TO WS-LABEL
     MOVE 3 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "normalize enabled" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE WGN-NEXT(WS-NODE-2) TO WS-NODE-3
     MOVE "first modifier bits of 1.0" TO WS-LABEL
     MOVE 4607182418800017408 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE-2, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE WGN-NEXT(WS-NODE-3) TO WS-NODE-3
     MOVE "third modifier bits of 2.0" TO WS-LABEL
     MOVE 4611686018427387904 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE-3, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "last modifier has no next" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-NEXT(WS-NODE-3) TO WS-GOT-N
     PERFORM EXPECT-N

     MOVE "minecraft:offset" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "base_amplitude is the nearest double of 0.1" TO WS-LABEL
     MOVE 4591870180066957722 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "normalize disabled" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 4) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE WGN-NEXT(WS-NODE-2) TO WS-NODE-3
     MOVE "a zero modifier is kept" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-NUM(WS-NODE-3, 1) TO WS-GOT-N
     PERFORM EXPECT-N

     MOVE "minecraft:aquifer_barrier" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "octave_count defaults to 1" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "no modifiers" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "no modifier chain" TO WS-LABEL
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N

*>   Freeing empties the store.
     CALL "WORLDGEN-FREE"
     MOVE "noise: freed" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "noise: freed nodes" TO TL-CASE
     MOVE WG-COUNT(WGK-NODE) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

*>   The density functions (10 4.1 to 4.3).
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     MOVE "density: the fixture tree loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE "density: 8 functions" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WG-COUNT(WGK-FUNCTION) TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-N
     MOVE "minecraft:overworld/blended" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 6 TO WS-N
     MOVE "minecraft:shift_x" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 8 TO WS-N
     MOVE "minecraft:zero" TO WS-WANT-T
     PERFORM ASSERT-ORDER
     MOVE 1 TO WS-KIND

     MOVE "minecraft:zero" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "constant" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "constant value bits of 0.0" TO WS-LABEL
     MOVE 0 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS

     MOVE "minecraft:y" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "gradient" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "axis" TO WS-LABEL
     MOVE "y" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "from_coordinate" TO WS-LABEL
     MOVE -4064 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "to_coordinate" TO WS-LABEL
     MOVE 4062 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "to_value" TO WS-LABEL
     MOVE 4062 TO WS-WANT-N
     MOVE WGN-NUM(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N

*>   A cache of a shift_a of a named noise (10 4.2).
     MOVE "minecraft:shift_x" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "cache" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "shift_a" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "noise of shift_a" TO WS-LABEL
     MOVE "minecraft:offset" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T

*>   add(mul(0.5, ref y), clamp(noise ..., -1, 1)): a bare number is a constant, a string a reference (type 0).
     MOVE "minecraft:overworld/sloped" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "add" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE WGN-CHILD(WS-NODE, 2) TO WS-NODE-3
     MOVE WS-NODE-2 TO WS-NODE
     MOVE "mul" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "constant" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "bare number bits of 0.5" TO WS-LABEL
     MOVE 4602678819172646912 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE WGN-CHILD(WS-NODE-2, 2) TO WS-NODE
     MOVE "reference type" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-TYPE(WS-NODE) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "reference id" TO WS-LABEL
     MOVE "minecraft:y" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WS-NODE-3 TO WS-NODE
     MOVE "clamp" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "clamp min" TO WS-LABEL
     MOVE -1 TO WS-WANT-N
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "clamp max" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WGN-NUM(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "noise" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "noise id" TO WS-LABEL
     MOVE "minecraft:continentalness" TO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "xz_scale bits of 0.25" TO WS-LABEL
     MOVE 4598175219545276416 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "shift_x is a reference" TO WS-LABEL
     MOVE "minecraft:shift_x" TO WS-WANT-T
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE WGN-TEXT-1(WS-NODE-2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE "shift_y is left out" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WGN-CHILD(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "shift_z 0 is a constant" TO WS-LABEL
     MOVE WGN-CHILD(WS-NODE, 3) TO WS-NODE-2
     MOVE WGN-TYPE(WS-NODE-2) TO WS-GOT-N
     MOVE WS-NODE-2 TO WS-NODE
     MOVE "constant" TO WS-WANT-T
     PERFORM EXPECT-TYPE

*>   interpolated(squeeze(blend_density(range_choice(...)))) with lerp and find_top_surface below it.
     MOVE "minecraft:overworld/ranges" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "interpolated" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "cell_size_xz" TO WS-LABEL
     MOVE 4 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "cell_size_y" TO WS-LABEL
     MOVE 8 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "squeeze" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "blend_density" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE
     MOVE "range_choice" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "min_inclusive" TO WS-LABEL
     MOVE WGN-NUM(WS-NODE, 1) TO WS-GOT-F
     MOVE -4620693217682128896 TO WS-WANT-BITS
     PERFORM EXPECT-BITS
     MOVE WGN-CHILD(WS-NODE, 2) TO WS-NODE-2
     MOVE WGN-CHILD(WS-NODE, 3) TO WS-NODE-3
     MOVE WS-NODE-2 TO WS-NODE
     MOVE "lerp" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "lerp alpha" TO WS-LABEL
     MOVE WGN-CHILD(WS-NODE, 1) TO WS-NODE-2
     MOVE 4598175219545276416 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE-2, 1) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "lerp second is a reference" TO WS-LABEL
     MOVE "minecraft:overworld/sloped" TO WS-WANT-T
     MOVE WGN-CHILD(WS-NODE, 3) TO WS-NODE-2
     MOVE WGN-TEXT-1(WS-NODE-2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WS-NODE-3 TO WS-NODE
     MOVE "find_top_surface" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "lower_bound" TO WS-LABEL
     MOVE -64 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 1) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "cell_height" TO WS-LABEL
     MOVE 8 TO WS-WANT-N
     MOVE WGN-INT(WS-NODE, 2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "upper_bound is a constant" TO WS-LABEL
     MOVE WGN-CHILD(WS-NODE, 2) TO WS-NODE-2
     MOVE 80 TO WS-WANT-N
     MOVE WGN-NUM(WS-NODE-2, 1) TO WS-GOT-N
     PERFORM EXPECT-N

     MOVE "minecraft:overworld/blended" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "old_blended_noise" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE "y_scale bits of 0.375" TO WS-LABEL
     MOVE 4600427019358961664 TO WS-WANT-BITS
     MOVE WGN-NUM(WS-NODE, 2) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE "smear_scale_multiplier" TO WS-LABEL
     MOVE 8 TO WS-WANT-N
     MOVE WGN-NUM(WS-NODE, 5) TO WS-GOT-N
     PERFORM EXPECT-N

     MOVE "minecraft:overworld/unused" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "beardifier" TO WS-WANT-T
     PERFORM EXPECT-TYPE

*>   A spline (10 4.3): the coordinate function and strictly increasing points; a number is a constant spline.
     MOVE "minecraft:overworld/factor" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "spline" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WGN-INT(WS-NODE, 1) TO WS-N
     MOVE "spline: two points" TO WS-LABEL
     MOVE 2 TO WS-WANT-N
     MOVE WSP-N(WS-N) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "spline: coordinate is a reference" TO WS-LABEL
     MOVE "minecraft:y" TO WS-WANT-T
     MOVE WSP-COORD(WS-N) TO WS-NODE-2
     MOVE WGN-TEXT-1(WS-NODE-2) TO WS-GOT-T
     PERFORM EXPECT-T
     MOVE WSP-FIRST(WS-N) TO WS-NODE-2
     MOVE "spline: first location" TO WS-LABEL
     MOVE -1 TO WS-WANT-N
     MOVE WPT-LOCATION(WS-NODE-2) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "spline: first derivative bits of 0.0" TO WS-LABEL
     MOVE 0 TO WS-WANT-BITS
     MOVE WPT-DERIVATIVE(WS-NODE-2) TO WS-GOT-F
     PERFORM EXPECT-BITS
     MOVE WPT-VALUE(WS-NODE-2) TO WS-NODE-3
     MOVE "spline: first value is a constant spline" TO WS-LABEL
     MOVE 0 TO WS-WANT-N
     MOVE WSP-N(WS-NODE-3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE "spline: first value bits of 0.1" TO WS-LABEL
     MOVE 4591870180066957722 TO WS-WANT-BITS
     MOVE WSP-CONST(WS-NODE-3) TO WS-GOT-F
     PERFORM EXPECT-BITS
     ADD 1 TO WS-NODE-2
     MOVE "spline: second derivative" TO WS-LABEL
     MOVE WPT-DERIVATIVE(WS-NODE-2) TO WS-GOT-F
     MOVE 4598175219545276416 TO WS-WANT-BITS
     PERFORM EXPECT-BITS
     MOVE WPT-VALUE(WS-NODE-2) TO WS-NODE-3
     MOVE "spline: nested spline has one point" TO WS-LABEL
     MOVE 1 TO WS-WANT-N
     MOVE WSP-N(WS-NODE-3) TO WS-GOT-N
     PERFORM EXPECT-N
     MOVE WSP-COORD(WS-NODE-3) TO WS-NODE
     MOVE "abs" TO WS-WANT-T
     PERFORM EXPECT-TYPE
     MOVE WSP-FIRST(WS-NODE-3) TO WS-NODE-2
     MOVE "spline: nested point value bits of 2.0" TO WS-LABEL
     MOVE WPT-VALUE(WS-NODE-2) TO WS-NODE-3
     MOVE 4611686018427387904 TO WS-WANT-BITS
     MOVE WSP-CONST(WS-NODE-3) TO WS-GOT-F
     PERFORM EXPECT-BITS

*>   The type table: 10 4.2 names for domain 1; an index outside gives domain 0.
     MOVE 1 TO WS-N
     CALL "WG-TYPE-AT" USING WS-N WS-DOMAIN WS-TYPE-NAME WS-FIELDS
     MOVE "type table: row 1 is a density function" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DOMAIN TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1000 TO WS-N
     CALL "WG-TYPE-AT" USING WS-N WS-DOMAIN WS-TYPE-NAME WS-FIELDS
     MOVE "type table: row 1000 is outside" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DOMAIN TO TL-OBSERVED-N
     PERFORM ASSERT-NUM

     CALL "WORLDGEN-FREE"

*>   A string with an escape (JSON backslash-u0061 is "a") is read as the character it stands for, and the digits after an
*>   escape are not taken for a number.
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "printf '%s' '{""type"":""minecraft:shift_a"",""noise"":""minecraft:\u0061\n3""}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/esc.json"
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     MOVE "density: a tree with an escaped string loads" TO TL-CASE
     MOVE CT-OK TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     MOVE 1 TO WS-KIND
     MOVE "minecraft:esc" TO WS-KEY
     PERFORM FIND-NODE
     MOVE "escaped noise id" TO WS-LABEL
     MOVE SPACES TO WS-WANT-T
     STRING "minecraft:a" X"0A" "3" DELIMITED BY SIZE INTO WS-WANT-T
     MOVE WGN-TEXT-1(WS-NODE) TO WS-GOT-T
     PERFORM EXPECT-T
     CALL "WORLDGEN-FREE"

*>   Noise failures (10 3.3: octave_count 1 to 32, one modifier per octave, each 0 to 1000000, normalize values).
     MOVE "a noise with octave_count 0" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3,""octave_count"":0,""base_amplitude"":1.0}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise with octave_count 33" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3,""octave_count"":33,""base_amplitude"":1.0}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise with two modifiers for three octaves" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3,""octave_count"":3,""base_amplitude"":1.0,""amplitude_modifiers"":[1.0,2.0]}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise with a modifier of 2000000" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3,""octave_count"":1,""base_amplitude"":1.0,""amplitude_modifiers"":[2000000.0]}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise with a negative modifier" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3,""octave_count"":1,""base_amplitude"":1.0,""amplitude_modifiers"":[-1.0]}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise with normalize bogus" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3,""base_amplitude"":1.0,""normalize"":""bogus""}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise without base_amplitude" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise with base_octave 1.5" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":1.5,""base_amplitude"":1.0}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise with a modifier that is no number" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3,""base_amplitude"":1.0,""amplitude_modifiers"":[""x""]}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise with amplitude_modifiers that is no array" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3,""base_amplitude"":1.0,""amplitude_modifiers"":5}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise file that is no object" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '[1]' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise file that is not strict JSON" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3,}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS
     MOVE "a noise number text over 63 bytes" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""base_octave"":-3,""base_amplitude"":1.00000000000000000000000000000000000000000000000000000000000000000001}' > build/content-test/worldgen/t/data/minecraft/worldgen/noise/bad.json"
     PERFORM NOISE-FAILS

*>   Density function failures.
     MOVE "a density function of an unknown type" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:bogus""}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a density function type of another namespace" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""mod:add"",""left"":1,""right"":2}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a density function without a type" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""left"":1}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "an add without right" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:add"",""left"":1}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "an add with a child that is true" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:add"",""left"":1,""right"":true}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a clamp with a min that is text" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:clamp"",""input"":1,""min"":""x"",""max"":1}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a gradient with a from_coordinate of 1.5" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:gradient"",""axis"":""y"",""from_coordinate"":1.5,""to_coordinate"":1,""from_value"":0,""to_value"":1}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a noise node whose noise is a number" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:shift_a"",""noise"":5}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a text of 161 bytes" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "(printf '{""type"":""minecraft:shift_a"",""noise"":""'; printf 'a%.0s' $(seq 1 161); printf '""}') > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a spline of a string" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":""x""}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a spline without a coordinate" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":{""points"":[{""location"":0,""value"":1,""derivative"":0}]}}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a spline without points" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":{""coordinate"":1,""points"":[]}}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a spline with points that are no array" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":{""coordinate"":1,""points"":3}}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a spline point that is no object" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":{""coordinate"":1,""points"":[3]}}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a spline point without a location" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":{""coordinate"":1,""points"":[{""value"":1,""derivative"":0}]}}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a spline point without a derivative" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":{""coordinate"":1,""points"":[{""location"":0,""value"":1}]}}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a spline point without a value" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":{""coordinate"":1,""points"":[{""location"":0,""derivative"":0}]}}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "spline locations that do not increase" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":{""coordinate"":1,""points"":[{""location"":1,""value"":1,""derivative"":0},{""location"":1,""value"":2,""derivative"":0}]}}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a spline point whose value is a bad spline" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":{""coordinate"":1,""points"":[{""location"":1,""value"":true,""derivative"":0}]}}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a spline with a bad coordinate" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:spline"",""spline"":{""coordinate"":true,""points"":[{""location"":1,""value"":1,""derivative"":0}]}}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "a failure deep in the tree is one error for the file" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "echo '{""type"":""minecraft:add"",""left"":{""type"":""minecraft:add"",""left"":1,""right"":{""type"":""minecraft:squeeze""}},""right"":1}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/bad.json"
     PERFORM DENSITY-FAILS
     MOVE "more than 4096 density functions" TO WS-T
     PERFORM FRESH-TREE
     CALL "SYSTEM" USING "for i in $(seq 1 4090); do printf '{""type"":""minecraft:constant"",""value"":0.0}' > build/content-test/worldgen/t/data/minecraft/worldgen/density_function/f$i.json; done"
     PERFORM DENSITY-FAILS
     MOVE "a directory path of 1100 characters" TO WS-T
     MOVE ALL "a" TO WS-DIR
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     MOVE "worldgen: a directory path of 1100 characters is CT-BAD-DATA" TO TL-CASE
     MOVE CT-BAD-DATA TO TL-EXPECTED-N
     MOVE WS-STATUS TO TL-OBSERVED-N
     PERFORM ASSERT-NUM
     STOP RUN.

 FRESH-TREE.
     MOVE "build/content-test/worldgen/t" TO WS-DIR
     CALL "SYSTEM" USING "chmod -R u+rwx build/content-test/worldgen 2>/dev/null; rm -rf build/content-test/worldgen; mkdir -p build/content-test/worldgen && cp -R content/tests/fixtures/worldgen build/content-test/worldgen/t".

 NOISE-FAILS.
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     PERFORM FAILED-LOAD.

 DENSITY-FAILS.
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
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

 EXPECT-TYPE.
     CALL "WG-TYPE-AT" USING WGN-TYPE(WS-NODE) WS-DOMAIN WS-TYPE-NAME WS-FIELDS
     MOVE WS-TYPE-NAME TO WS-GOT-T
     MOVE "type" TO WS-LABEL
     PERFORM EXPECT-T.

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
