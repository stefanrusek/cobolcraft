*> End to end test of the placement runtime (core/src/feat-run.cob, feat-data.cob, feat-level.cob): placed features compiled from core/tests/fixtures/feat are placed into a chunk
*> through the level and compared, block for block, with the same placement written out by hand from the draws of the wrapped random source (the oracle writes the expected blocks
*> into a second chunk): the patch idiom, a random_selector with inline features and a predicate filter, the filters (rarity, random_chance, surface relative, water depth),
*> cuboid, count_on_every_layer over a cave, every height provider, offset providers, the selectors, a random_block provider; the result of environment_scan, volume_match
*> and the other predicates; and that unsupported placed features place nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/feat".
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 1000.
 01 WS-KEY                 PIC X(80).
 01 WS-PF                  BINARY-LONG.
 01 WS-PTR1                USAGE POINTER.
 01 WS-PTR2                USAGE POINTER.
 01 WS-A                   PIC X(196608) BASED.
 01 WS-B                   PIC X(196608) BASED.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-FL                  FLOAT-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-B16                 BINARY-LONG VALUE 16.
 01 WS-SAME                BINARY-LONG.
 01 WS-NAME                PIC X(60).
 01 WS-BOOL                BINARY-LONG.
 01 WS-WRITES              BINARY-LONG.
 01 WS-A-V                 BINARY-LONG.
 01 WS-B-V                 BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 10 TO CB-BLOCK-COUNT
     MOVE 10 TO CB-STATE-COUNT
     MOVE 7 TO CB-EPOCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 1 TO CB-SOLID(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE "minecraft:dandelion" TO CB-KEY(4)
     MOVE "minecraft:poppy" TO CB-KEY(5)
     MOVE "minecraft:cave_air" TO CB-KEY(6)
     MOVE "minecraft:void_air" TO CB-KEY(7)
     MOVE "minecraft:bedrock" TO CB-KEY(8)
     MOVE 1 TO CB-SOLID(8)
     MOVE "minecraft:lava" TO CB-KEY(9)
     MOVE "minecraft:tall_grass" TO CB-KEY(10)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR1
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR2
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

*>   1 the patch idiom: count 4, in_square, heightmap, then the weighted flower
     MOVE "flowers_here" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     PERFORM 4 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DX
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DZ
         MOVE 4 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
         MOVE 3 TO WS-STATE
         IF WS-V >= 3
             MOVE 4 TO WS-STATE
         END-IF
         COMPUTE WS-X = 16 + WS-DX
         COMPUTE WS-Z = 32 + WS-DZ
         MOVE 63 TO WS-Y
         PERFORM SURV-PUT
     END-PERFORM
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: the patch idiom places the flowers the draws say" TO TL-CASE
     PERFORM COMPARE

*>   2 random_selector with an inline default, offset providers, a block predicate filter
     MOVE "rare_here" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 2 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     COMPUTE WS-K = 2 + WS-V
     PERFORM WS-K TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DX
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DZ
         MOVE 3 TO WS-N
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
         COMPUTE WS-OZ = WS-V - WS-W
         COMPUTE WS-X = 16 + WS-DX
         COMPUTE WS-Z = 32 + WS-DZ + WS-OZ
         MOVE 63 TO WS-Y
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         COMPUTE WS-YB = WS-Y - 1
         CALL "FL-GET-STATE" USING WS-X WS-YB WS-Z WS-T
         IF WS-STATE = 0 AND WS-T NOT = 0 AND WS-T NOT = 2
             CALL "WGR-NEXT-FLOAT" USING XR-STATE WS-FL
             IF WS-FL < 0.5
                 MOVE 4 TO WS-STATE
                 PERFORM SURV-PUT
             END-IF
         END-IF
     END-PERFORM
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: a random_selector, offsets and a predicate filter place the blocks the draws say" TO TL-CASE
     PERFORM COMPARE

*>   3 filters: rarity 2 and random_chance 0.5 (a float each), the surface filters draw nothing
     MOVE "filters_here" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     PERFORM 8 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DX
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DZ
         CALL "WGR-NEXT-FLOAT" USING XR-STATE WS-FL
         IF WS-FL < 0.5
             CALL "WGR-NEXT-FLOAT" USING XR-STATE WS-FL
             IF WS-FL < 0.5
                 COMPUTE WS-X = 16 + WS-DX
                 COMPUTE WS-Z = 32 + WS-DZ
                 MOVE 63 TO WS-Y
                 MOVE 4 TO WS-STATE
                 PERFORM SURV-PUT
             END-IF
         END-IF
     END-PERFORM
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: rarity_filter, random_chance and the surface filters" TO TL-CASE
     PERFORM COMPARE

*>   4 cuboid: 2 x 2 x 2 at (16, 0, 32); the sparse one keeps the six face centres of a 3 x 3 x 3 box
     MOVE "cuboid_here" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 1
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 1
             PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ > 1
                 COMPUTE WS-X = 16 + WS-DX
                 COMPUTE WS-Z = 32 + WS-DZ
                 MOVE 4 TO WS-STATE
                 PERFORM SURV-PUT
             END-PERFORM
         END-PERFORM
     END-PERFORM
     PERFORM SEED-IT
     MOVE 0 TO WS-Y
     PERFORM RUN-PF-ORIGIN-AT-Y
     MOVE "acceptance feature run: cuboid 2 x 2 x 2 places eight blocks" TO TL-CASE
     PERFORM COMPARE
     MOVE "cuboid_sparse" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     MOVE 4 TO WS-STATE
     MOVE 1 TO WS-N
     MOVE 17 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 32 TO WS-Z
     PERFORM SURV-PUT
     MOVE 17 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 34 TO WS-Z
     PERFORM SURV-PUT
     MOVE 17 TO WS-X
     MOVE 0 TO WS-Y
     MOVE 33 TO WS-Z
     PERFORM SURV-PUT
     MOVE 17 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 33 TO WS-Z
     PERFORM SURV-PUT
     MOVE 16 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 33 TO WS-Z
     PERFORM SURV-PUT
     MOVE 18 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 33 TO WS-Z
     PERFORM SURV-PUT
     PERFORM SEED-IT
     MOVE 0 TO WS-Y
     PERFORM RUN-PF-ORIGIN-AT-Y
     MOVE "acceptance feature run: cuboid without edges and interior keeps the six face centres" TO TL-CASE
     PERFORM COMPARE

*>   5 count_on_every_layer over a column with a cave (air 20 to 25): layer 0 floor at 63, layer 1 floor at 20, layer 2 none
     MOVE "layers_here" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DX
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DZ
     COMPUTE WS-X = 16 + WS-DX
     COMPUTE WS-Z = 32 + WS-DZ
     MOVE 63 TO WS-Y
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DX
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DZ
     COMPUTE WS-X = 16 + WS-DX
     COMPUTE WS-Z = 32 + WS-DZ
     MOVE 20 TO WS-Y
     PERFORM SURV-PUT
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: count_on_every_layer places on the surface and on the cave floor" TO TL-CASE
     PERFORM COMPARE

*>   6 height providers
     MOVE "hr_here" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DX
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-B16 WS-DZ
     MOVE 11 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     COMPUTE WS-X = 16 + WS-DX
     COMPUTE WS-Z = 32 + WS-DZ
     COMPUTE WS-Y = -64 + WS-V
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: height_range uniform above_bottom 0 to 10" TO TL-CASE
     PERFORM COMPARE
     MOVE "hr_biased" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 29 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     COMPUTE WS-N = WS-V + 2
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
     MOVE 16 TO WS-X
     MOVE 32 TO WS-Z
     COMPUTE WS-Y = -64 + WS-W
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: height_range biased_to_bottom (inner draw first, inner 2)" TO TL-CASE
     PERFORM COMPARE
     MOVE "hr_very" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 29 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     COMPUTE WS-A-V = -62 + WS-V
     COMPUTE WS-N = WS-A-V + 64
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
     COMPUTE WS-B-V = -64 + WS-W
     COMPUTE WS-N = WS-B-V - 1 + 2 + 64 + 1
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-T
     MOVE 16 TO WS-X
     MOVE 32 TO WS-Z
     COMPUTE WS-Y = -64 + WS-T
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: height_range very_biased_to_bottom (three draws, inner 2)" TO TL-CASE
     PERFORM COMPARE
     MOVE "hr_trap" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 14 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     MOVE 8 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
     MOVE 16 TO WS-X
     MOVE 32 TO WS-Z
     COMPUTE WS-Y = -64 + WS-V + WS-W
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: height_range trapezoid 0 to 20 plateau 6 (side 13, slope 7)" TO TL-CASE
     PERFORM COMPARE
     MOVE "hr_const" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: a constant height at the top of the world cannot survive (nothing below)" TO TL-CASE
     PERFORM COMPARE

*>   7 integer providers of an offset
     MOVE "ips" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 6 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     COMPUTE WS-N = WS-V + 1
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-DX
     MOVE 6 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     COMPUTE WS-N = WS-V + 1
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
     COMPUTE WS-N = WS-W + 1
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-T
     MOVE 5 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     MOVE 3 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-W
     COMPUTE WS-X = 20 + WS-DX
     COMPUTE WS-Y = 40 + WS-T
     COMPUTE WS-Z = 40 + WS-V + WS-W
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     MOVE 40 TO WS-Y
     MOVE 20 TO WS-X
     MOVE 40 TO WS-Z
     PERFORM SEED-IT
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: offset with biased_to_bottom, very_biased_to_bottom and trapezoid providers" TO TL-CASE
     PERFORM COMPARE

*>   8 the selectors, at (21, 63, 37)
     MOVE "simple_sel" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 2 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     COMPUTE WS-STATE = 4 - WS-V
     PERFORM PUT-AT-SELECTOR
     PERFORM RUN-PF-SELECTOR
     MOVE "acceptance feature run: simple_random_selector chooses by one nextInt(2)" TO TL-CASE
     PERFORM COMPARE
     MOVE "single_sel" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 1 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     MOVE 4 TO WS-STATE
     PERFORM PUT-AT-SELECTOR
     PERFORM RUN-PF-SELECTOR
     MOVE "acceptance feature run: a selector of one placed feature (a bare id) places it" TO TL-CASE
     PERFORM COMPARE
     MOVE "bool_sel" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     CALL "F351-NEXT-BOOLEAN" USING XR-STATE WS-V
     MOVE 4 TO WS-STATE
     IF WS-V = 0
         MOVE 3 TO WS-STATE
     END-IF
     PERFORM PUT-AT-SELECTOR
     PERFORM RUN-PF-SELECTOR
     MOVE "acceptance feature run: random_boolean_selector chooses by one nextBoolean" TO TL-CASE
     PERFORM COMPARE
     MOVE "weighted_sel" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 4 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     MOVE 3 TO WS-STATE
     IF WS-V < 1
         MOVE 4 TO WS-STATE
     END-IF
     PERFORM PUT-AT-SELECTOR
     PERFORM RUN-PF-SELECTOR
     MOVE "acceptance feature run: weighted_random_selector 1 and 3 chooses by one nextInt(4)" TO TL-CASE
     PERFORM COMPARE
     MOVE "seq" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     MOVE 3 TO WS-STATE
     PERFORM PUT-AT-SELECTOR
     PERFORM SEED-IT
     PERFORM RUN-PF-SELECTOR
     MOVE "acceptance feature run: sequence places both elements, the second one last" TO TL-CASE
     PERFORM COMPARE
     MOVE "acceptance feature run: sequence returns true when every element does" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "seq" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     MOVE 21 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 37 TO WS-Z
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: sequence stops at the first element that fails (nothing survives in the air): false, no write" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-RESULT * 10 + WS-WRITES
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "rb_here" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 2 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     COMPUTE WS-STATE = 4 + WS-V
     MOVE 3 TO WS-STATE
     IF WS-V = 0
         MOVE 4 TO WS-STATE
     ELSE
         MOVE 3 TO WS-STATE
     END-IF
     PERFORM PUT-AT-SELECTOR
     PERFORM RUN-PF-SELECTOR
     MOVE "acceptance feature run: a random_block provider draws one nextInt(2) over its blocks (poppy, dandelion)" TO TL-CASE
     PERFORM COMPARE

*>   9 results of the predicates and scans
     MOVE "volume_here" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     MOVE 21 TO WS-X
     MOVE 61 TO WS-Y
     MOVE 37 TO WS-Z
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: volume_match true over stone (box y 59 to 60)" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 64 TO WS-Y
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: volume_match false when the box holds air (y 62 to 63)" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 16 TO WS-X
     MOVE 61 TO WS-Y
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: volume_match false when the box leaves the chunk (the outside reads air)" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "preds_here" TO WS-NAME
     MOVE 21 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 37 TO WS-Z
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: any_of, all_of, solid below, bounds, unobstructed, height_range and fluids: true on air over stone" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 80 TO WS-Y
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: false outside the height range (y 80)" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 63 TO WS-Y
     MOVE 2 TO WS-STATE
     MOVE 21 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 37 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: the first branch matches a water block (matching_fluids water)" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "env_here" TO WS-NAME
     MOVE 0 TO WS-STATE
     MOVE 63 TO WS-Y
     MOVE 21 TO WS-X
     MOVE 37 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE 70 TO WS-Y
     MOVE 1 TO WS-STATE
     MOVE 21 TO WS-X
     MOVE 37 TO WS-Z
     CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     MOVE 63 TO WS-Y
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: environment_scan up through air finds the stone at 70 within 12 steps" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 22 TO WS-X
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: environment_scan with nothing above within 12 steps finds nothing" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO WS-Y
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: environment_scan starting inside stone (not allowed) finds nothing" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 319 TO WS-Y
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: environment_scan leaving the world finds nothing" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "env_down" TO WS-NAME
     MOVE 64 TO WS-Y
     MOVE 21 TO WS-X
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: environment_scan down finds the stone at 62 in three steps" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 66 TO WS-Y
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: environment_scan down: the stone is four steps away, the last test fails" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   10 unsupported placed features place nothing
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         EVALUATE WS-I
             WHEN 1
                 MOVE "bad_predicate" TO WS-NAME
             WHEN 2
                 MOVE "bad_modifier" TO WS-NAME
             WHEN 3
                 MOVE "bad_feature" TO WS-NAME
             WHEN 4
                 MOVE "props" TO WS-NAME
             WHEN 5
                 MOVE "double" TO WS-NAME
             WHEN 6
                 MOVE "pf_ore" TO WS-NAME
             WHEN OTHER
                 MOVE "no_such_pf" TO WS-NAME
         END-EVALUATE
         PERFORM NEW-WORLD
         PERFORM OPEN-ORACLE
         PERFORM SEED-IT
         PERFORM RUN-PF-ORIGIN
         MOVE "acceptance feature run: an unsupported or unknown placed feature places nothing" TO TL-CASE
         PERFORM COMPARE
     END-PERFORM

*>   11 more providers and edges
     MOVE "hr_flat" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 5 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     MOVE 16 TO WS-X
     MOVE 32 TO WS-Z
     MOVE WS-V TO WS-Y
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: height_range trapezoid with plateau equal to the range is one nextInt(5)" TO TL-CASE
     PERFORM COMPARE
     MOVE "ip_flat" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     MOVE 5 TO WS-N
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-N WS-V
     COMPUTE WS-X = 20 + WS-V
     MOVE 40 TO WS-Y
     MOVE 40 TO WS-Z
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     MOVE 20 TO WS-X
     PERFORM SEED-IT
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: an offset trapezoid with plateau equal to the range is one nextInt(5)" TO TL-CASE
     PERFORM COMPARE
     MOVE "hr_empty" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     MOVE 16 TO WS-X
     MOVE 5 TO WS-Y
     MOVE 32 TO WS-Z
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: an empty biased height range gives its minimum without a draw" TO TL-CASE
     PERFORM COMPARE
     MOVE "hr_vempty" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     MOVE 16 TO WS-X
     MOVE 5 TO WS-Y
     MOVE 32 TO WS-Z
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: an empty very biased height range gives its minimum without a draw" TO TL-CASE
     PERFORM COMPARE
     MOVE "hr_uempty" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     MOVE 16 TO WS-X
     MOVE 9 TO WS-Y
     MOVE 32 TO WS-Z
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: a uniform height range with minimum above maximum gives the minimum without a draw" TO TL-CASE
     PERFORM COMPARE
     MOVE "hr_tempty" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     MOVE 16 TO WS-X
     MOVE 9 TO WS-Y
     MOVE 32 TO WS-Z
     MOVE 4 TO WS-STATE
     PERFORM SURV-PUT
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: a trapezoid height range with minimum above maximum gives the minimum without a draw" TO TL-CASE
     PERFORM COMPARE
     MOVE "count_cap" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM RUN-PF-ORIGIN
     MOVE "acceptance feature run: a count of 5000 is capped to 4096 positions and still returns true" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "tag_air" TO WS-NAME
     MOVE 21 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 37 TO WS-Z
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: matching_blocks of the tag #minecraft:air (the known air tag) is true on air" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 50 TO WS-Y
     PERFORM RUN-PF-AT
     MOVE "acceptance feature run: matching_blocks of the tag #minecraft:air is false on stone" TO TL-CASE
     MOVE WS-RESULT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   four booleans in a row (true, true, true, false for seed 1000): the false branch of the selector
     MOVE "bool_sel" TO WS-NAME
     PERFORM NEW-WORLD
     PERFORM OPEN-ORACLE
     PERFORM SEED-IT
     PERFORM 4 TIMES
         CALL "F351-NEXT-BOOLEAN" USING XR-STATE WS-V
         MOVE 4 TO WS-STATE
         IF WS-V = 0
             MOVE 3 TO WS-STATE
         END-IF
         PERFORM PUT-AT-SELECTOR
     END-PERFORM
     PERFORM SEED-IT
     PERFORM 4 TIMES
         PERFORM RUN-PF-SELECTOR
     END-PERFORM
     MOVE "acceptance feature run: four selector runs follow true, true, true, false (the last places the false branch)" TO TL-CASE
     PERFORM COMPARE
     FREE WS-PTR1
     FREE WS-PTR2
     GOBACK.

 NEW-WORLD.
     SET ADDRESS OF CE-CHUNK TO WS-PTR1
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 319
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             COMPUTE WS-K = (WS-Y + 64) * 256 + WS-I
             MOVE 0 TO CE-STATE(WS-K)
             IF WS-Y <= 62 AND (WS-Y < 20 OR WS-Y > 25)
                 MOVE 1 TO CE-STATE(WS-K)
             END-IF
         END-PERFORM
     END-PERFORM
     SET ADDRESS OF WS-A TO WS-PTR1
     SET ADDRESS OF WS-B TO WS-PTR2
     MOVE WS-A TO WS-B
     CALL "FD-RESET"
     CALL "FL-OPEN" USING WS-PTR1 WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA.

 OPEN-ORACLE.
     CALL "FL-OPEN" USING WS-PTR2 WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA.

 SEED-IT.
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED.

 SURV-PUT.
*>   the oracle's simple_block: written when a block that is not air lies below
     COMPUTE WS-YB = WS-Y - 1
     CALL "FL-GET-STATE" USING WS-X WS-YB WS-Z WS-T
     CALL "FL-CLASS" USING WS-T WS-CLASS
     IF WS-CLASS NOT = 1 AND WS-YB >= -64
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     END-IF.

 PUT-AT-SELECTOR.
     MOVE 21 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 37 TO WS-Z
     PERFORM SURV-PUT.

 RUN-PF-SELECTOR.
     MOVE 21 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 37 TO WS-Z
     PERFORM RUN-PF-AT.

 RUN-PF-ORIGIN.
     MOVE 16 TO WS-X
     MOVE -64 TO WS-Y
     MOVE 32 TO WS-Z
     PERFORM SEED-IT
     PERFORM RUN-PF-AT.

 RUN-PF-ORIGIN-AT-Y.
     MOVE 16 TO WS-X
     MOVE 32 TO WS-Z
     PERFORM RUN-PF-AT.

 RUN-PF-AT.
*>   the placed feature named in WS-NAME at (WS-X, WS-Y, WS-Z) into the first chunk
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" FUNCTION TRIM(WS-NAME) DELIMITED BY SIZE INTO WS-KEY
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     CALL "FL-OPEN" USING WS-PTR1 WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-ZERO WS-X WS-Y WS-Z WS-RESULT
     MOVE FL-WRITES TO WS-WRITES.

 COMPARE.
     SET ADDRESS OF WS-A TO WS-PTR1
     SET ADDRESS OF WS-B TO WS-PTR2
     MOVE 0 TO TL-OBSERVED-N
     IF WS-A = WS-B
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
