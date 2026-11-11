*> Acceptance test of docs/protocol/35-worldgen-features-1 section 7 (placement modifiers): count, in_square, rarity_filter, random_chance,
*> height_range, offset, cuboid (the 27, 26, 7 and 0 cell cases), surface_relative_threshold_filter, surface_water_depth_filter, the noise counts
*> (with the float widening case 65), heightmap, count_on_every_layer (floorOfLayer, bedrock, the layers and their draws), environment_scan
*> (the cave vines example, the step limit, the world edge) and fixed_placement. Draws are those of the generator seeded with 1000 (11.3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-35-1-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY XORO.
 COPY FEAT351.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 1000.
 01 WS-M                   BINARY-LONG VALUE 1.
 01 WS-COUNT               BINARY-LONG.
 01 WS-OUT.
    05 WS-O OCCURS 8192 TIMES.
       10 WS-OX            BINARY-LONG.
       10 WS-OY            BINARY-LONG.
       10 WS-OZ            BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-NUM                 PIC -(9)9.
 01 WS-TEXT                PIC X(240).
 01 WS-PTR                 BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-OFFSET              FLOAT-LONG.
 01 WS-LEVEL               FLOAT-LONG.
 01 WS-RATIO               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-COLUMN.
    05 WS-CLASS            BINARY-LONG OCCURS 512 TIMES.
 01 WS-FLAGS REDEFINES WS-COLUMN.
    05 WS-FLAG             BINARY-LONG OCCURS 512 TIMES.
 01 WS-MIN-Y               BINARY-LONG VALUE -64.
 01 WS-TOP-Y               BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-STEPS               BINARY-LONG.
 01 WS-EMIT                BINARY-LONG.
 01 WS-LIST.
    05 WS-L OCCURS 64 TIMES.
       10 WS-LX            BINARY-LONG.
       10 WS-LY            BINARY-LONG.
       10 WS-LZ            BINARY-LONG.
 01 WS-SMALL.
    05 WS-S OCCURS 64 TIMES.
       10 WS-SX            BINARY-LONG.
       10 WS-SY            BINARY-LONG.
       10 WS-SZ            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 1 TO FP-COUNT

*>   7.1 count
     MOVE 1 TO FP-KIND(1)
     MOVE 3 TO FP-A(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: count 3 emits the input three times" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO FP-A(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: count 0 emits nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.2 in_square: nextInt(16) for x, then for z (9 and 10 for seed 1000)
     MOVE 2 TO FP-KIND(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: in_square adds 9 to x and 10 to z (the first two nextInt(16))" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OY(1) - 2) * 100000 + (WS-OX(1) - 5) * 100 + (WS-OZ(1) - 3)
     MOVE 910 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.5 rarity_filter n: passes iff nextFloat < 1.0f / n
     MOVE 5 TO FP-KIND(1)
     MOVE 4 TO FP-A(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: rarity_filter 4 rejects the first float 0.617" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO FP-A(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: rarity_filter 1 always passes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WGR-NEXT-FLOAT" USING XR-STATE WS-FLOAT
     MOVE "acceptance US12 35-1§7 Placement modifiers: rarity_filter 1 still consumes its draw (the next float is the second one, 0.640)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-FLOAT * 1000
     MOVE 640 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.6 random_chance f: strictly less
     MOVE 6 TO FP-KIND(1)
     MOVE 0.7 TO FP-F(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: random_chance 0.7 passes the first float 0.617" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.6 TO FP-F(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: random_chance 0.6 rejects the first float 0.617" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.15 height_range uniform 0..64: y = nextInt(65), the first draw of seed 1000 (nextInt(65) from the same bits)
     MOVE 3 TO FP-KIND(1)
     MOVE 0 TO FP-A(1)
     MOVE 64 TO FP-B(1)
     PERFORM RUN-MODIFY
     MOVE 65 TO WS-BOUND
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-DRAW
     MOVE "acceptance US12 35-1§7 Placement modifiers: height_range uniform 0 to 64 sets y to one nextInt(65) and keeps x and z" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-OY(1) * 1000000 + WS-OX(1) * 1000 + WS-OZ(1)
     COMPUTE TL-EXPECTED-N = WS-DRAW * 1000000 + 5003
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.16 offset: the plains flower trapezoids -6..6, -2..2, -6..6 give (-1, 2, -4) for seed 1000
     MOVE 7 TO FP-KIND(1)
     MOVE 6 TO FP-A(1)
     MOVE 2 TO FP-B(1)
     MOVE 6 TO FP-C(1)
     MOVE 0 TO FP-D(1)
     MOVE 0 TO WS-X WS-Y WS-Z
     PERFORM RUN-MODIFY-AT-ORIGIN
     MOVE "acceptance US12 35-1§7 Placement modifiers: offset with the plains trapezoids gives (-1, 2, -4) for seed 1000" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE WS-OX(1) TO WS-NUM
     STRING FUNCTION TRIM(WS-NUM) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE WS-OY(1) TO WS-NUM
     STRING FUNCTION TRIM(WS-NUM) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE WS-OZ(1) TO WS-NUM
     STRING FUNCTION TRIM(WS-NUM) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "-1 2 -4" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE

     MOVE 1 TO FP-D(1)
     MOVE 3 TO FP-A(1)
     MOVE -2 TO FP-B(1)
     MOVE 5 TO FP-C(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: offset with constant providers translates by (3, -2, 5) and draws nothing" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OX(1) - 5) * 10000 + (WS-OY(1) - 2 + 10) * 100 + (WS-OZ(1) - 3)
     MOVE 30805 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.14 cuboid
     MOVE 8 TO FP-KIND(1)
     MOVE 2 TO FP-A(1)
     MOVE 2 TO FP-B(1)
     MOVE 1 TO FP-C(1)
     MOVE 1 TO FP-D(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: cuboid 2 x 2 x 2 with defaults emits 27 cells" TO TL-CASE
     MOVE 27 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 35-1§7 Placement modifiers: cuboid emits x-major, then y, then z (the second cell is +0 +0 +1)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-OX(2) - 5) * 100 + (WS-OY(2) - 2) * 10 + (WS-OZ(2) - 3)
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO FP-D(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: cuboid without the interior emits 26 cells" TO TL-CASE
     MOVE 26 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO FP-D(1)
     MOVE 0 TO FP-C(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: cuboid without the edges emits 7 cells" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO FP-A(1)
     MOVE 1 TO FP-B(1)
     PERFORM RUN-MODIFY
     MOVE "acceptance US12 35-1§7 Placement modifiers: cuboid 1 x 1 x 1 without the edges emits nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.7 surface_relative_threshold_filter
     MOVE 70 TO WS-Y
     MOVE -2147483648 TO WS-MIN
     MOVE -13 TO WS-MAX
     MOVE 57 TO WS-Z
     CALL "F351-SURFACE-REL" USING WS-Y WS-MIN WS-MAX WS-Z WS-PASS
     MOVE "acceptance US12 35-1§7 Placement modifiers: surface_relative_threshold_filter max -13 at height 70 passes y 57" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PASS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 58 TO WS-Z
     CALL "F351-SURFACE-REL" USING WS-Y WS-MIN WS-MAX WS-Z WS-PASS
     MOVE "acceptance US12 35-1§7 Placement modifiers: surface_relative_threshold_filter max -13 at height 70 rejects y 58" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PASS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-Z
     MOVE 2147483647 TO WS-MAX
     CALL "F351-SURFACE-REL" USING WS-Y WS-MIN WS-MAX WS-Z WS-PASS
     MOVE "acceptance US12 35-1§7 Placement modifiers: the bounds are added in 64 bit (no overflow at the int limits)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PASS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.8 surface_water_depth_filter
     MOVE 60 TO WS-X
     MOVE 63 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "F351-WATER-DEPTH" USING WS-X WS-Y WS-Z WS-PASS
     MOVE "acceptance US12 35-1§7 Placement modifiers: surface_water_depth_filter passes a depth equal to the maximum" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PASS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-Z
     CALL "F351-WATER-DEPTH" USING WS-X WS-Y WS-Z WS-PASS
     MOVE "acceptance US12 35-1§7 Placement modifiers: surface_water_depth_filter rejects a depth above the maximum" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-PASS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.9 noise_based_count: ratio 160, offset 0.3
     MOVE 160 TO WS-RATIO
     MOVE 0.3 TO WS-OFFSET
     MOVE 0 TO WS-FLOAT
     CALL "F351-NOISE-COUNT" USING WS-FLOAT WS-RATIO WS-OFFSET WS-COUNT
     MOVE "acceptance US12 35-1§7 Placement modifiers: noise_based_count of noise 0.0 is 48" TO TL-CASE
     MOVE 48 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.25 TO WS-FLOAT
     CALL "F351-NOISE-COUNT" USING WS-FLOAT WS-RATIO WS-OFFSET WS-COUNT
     MOVE "acceptance US12 35-1§7 Placement modifiers: noise_based_count of noise 0.25 is 88" TO TL-CASE
     MOVE 88 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -0.5 TO WS-FLOAT
     CALL "F351-NOISE-COUNT" USING WS-FLOAT WS-RATIO WS-OFFSET WS-COUNT
     MOVE "acceptance US12 35-1§7 Placement modifiers: noise_based_count of noise -0.5 is -32 (no repeats)" TO TL-CASE
     MOVE -32 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.10000000149011612 TO WS-FLOAT
     CALL "F351-NOISE-COUNT" USING WS-FLOAT WS-RATIO WS-OFFSET WS-COUNT
     MOVE "acceptance US12 35-1§7 Placement modifiers: noise_based_count of the float 0.1f is 65 (the widening matters)" TO TL-CASE
     MOVE 65 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.10 noise_threshold_count: level -0.8, below 15, above 4
     MOVE -0.8 TO WS-LEVEL
     MOVE 15 TO WS-BELOW
     MOVE 4 TO WS-ABOVE
     MOVE -0.9 TO WS-FLOAT
     CALL "F351-NOISE-THRESHOLD" USING WS-FLOAT WS-LEVEL WS-BELOW WS-ABOVE WS-COUNT
     MOVE "acceptance US12 35-1§7 Placement modifiers: noise_threshold_count below the level gives below_noise" TO TL-CASE
     MOVE 15 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -0.8 TO WS-FLOAT
     CALL "F351-NOISE-THRESHOLD" USING WS-FLOAT WS-LEVEL WS-BELOW WS-ABOVE WS-COUNT
     MOVE "acceptance US12 35-1§7 Placement modifiers: noise_threshold_count equal to the level gives above_noise (strict comparison)" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.13 heightmap
     MOVE 70 TO WS-X
     MOVE -64 TO WS-Y
     CALL "F351-HEIGHTMAP-EMIT" USING WS-X WS-Y WS-EMIT
     MOVE "acceptance US12 35-1§7 Placement modifiers: heightmap emits a column above the minimum y" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-EMIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -64 TO WS-X
     CALL "F351-HEIGHTMAP-EMIT" USING WS-X WS-Y WS-EMIT
     MOVE "acceptance US12 35-1§7 Placement modifiers: heightmap drops a column with no qualifying block (height equal to min y)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EMIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.11 count_on_every_layer: air at y >= 90, solid 89 to 86, air 85 to 80, solid below (bedrock at -64)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 512
         MOVE 1 TO WS-CLASS(WS-I)
     END-PERFORM
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 79
         COMPUTE WS-I = WS-Y + 64 + 1
         MOVE 0 TO WS-CLASS(WS-I)
     END-PERFORM
     MOVE 3 TO WS-CLASS(1)
     PERFORM VARYING WS-Y FROM 86 BY 1 UNTIL WS-Y > 89
         COMPUTE WS-I = WS-Y + 64 + 1
         MOVE 0 TO WS-CLASS(WS-I)
     END-PERFORM
     MOVE 95 TO WS-START
     MOVE 0 TO WS-N
     CALL "F351-FLOOR-OF-LAYER" USING WS-COLUMN WS-MIN-Y WS-START WS-N WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: floorOfLayer layer 0 is 90" TO TL-CASE
     MOVE 90 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-N
     CALL "F351-FLOOR-OF-LAYER" USING WS-COLUMN WS-MIN-Y WS-START WS-N WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: floorOfLayer layer 1 is 80 (the cave floor)" TO TL-CASE
     MOVE 80 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-N
     CALL "F351-FLOOR-OF-LAYER" USING WS-COLUMN WS-MIN-Y WS-START WS-N WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: floorOfLayer layer 2 is none (min y - 1)" TO TL-CASE
     MOVE -65 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 512
         MOVE 1 TO WS-CLASS(WS-I)
     END-PERFORM
     MOVE 0 TO WS-N
     CALL "F351-FLOOR-OF-LAYER" USING WS-COLUMN WS-MIN-Y WS-START WS-N WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: a floor that is bedrock is never counted" TO TL-CASE
     MOVE -65 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 512
         MOVE 1 TO WS-CLASS(WS-I)
     END-PERFORM
     MOVE 2 TO WS-CLASS(1)
     MOVE 0 TO WS-N
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 79
         COMPUTE WS-I = WS-Y + 64 + 1
         MOVE 0 TO WS-CLASS(WS-I)
     END-PERFORM
     MOVE 3 TO WS-CLASS(1)
     PERFORM VARYING WS-Y FROM 86 BY 1 UNTIL WS-Y > 89
         COMPUTE WS-I = WS-Y + 64 + 1
         MOVE 0 TO WS-CLASS(WS-I)
     END-PERFORM
     MOVE 2 TO WS-N
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 0 TO WS-X WS-Z
     CALL "F351-LAYERS" USING XR-STATE WS-X WS-Z WS-N WS-COLUMN WS-MIN-Y WS-START WS-COUNT WS-OUT
     MOVE "acceptance US12 35-1§7 Placement modifiers: count_on_every_layer with count 2 emits 2 positions on each of 2 layers" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 35-1§7 Placement modifiers: the layer positions are 90, 90, 80, 80 in y" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-OY(1) * 1000000 + WS-OY(2) * 10000 + WS-OY(3) * 100 + WS-OY(4)
     MOVE 90908080 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   twelve nextInt(16) draws were made (3 layers x 2 iterations x x and z): the next one is the 13th
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 16 TO WS-BOUND
     PERFORM 13 TIMES
         CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-NEXT
     END-PERFORM
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-LAYERS" USING XR-STATE WS-X WS-Z WS-N WS-COLUMN WS-MIN-Y WS-START WS-COUNT WS-OUT
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-DRAW
     MOVE "acceptance US12 35-1§7 Placement modifiers: count_on_every_layer draws exactly 2 per iteration over 3 layers" TO TL-CASE
     MOVE WS-NEXT TO TL-EXPECTED-N
     MOVE WS-DRAW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.12 environment_scan: min y 0, top y 20; air 10 to 14, stone (target, not allowed) at 15
     MOVE 0 TO WS-MIN-Y
     MOVE 20 TO WS-TOP-Y
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 512
         MOVE 0 TO WS-FLAG(WS-I)
     END-PERFORM
     PERFORM VARYING WS-Y FROM 10 BY 1 UNTIL WS-Y > 14
         COMPUTE WS-I = WS-Y + 1
         MOVE 1 TO WS-FLAG(WS-I)
     END-PERFORM
     MOVE 2 TO WS-FLAG(16)
     MOVE 10 TO WS-START
     MOVE 1 TO WS-DIR
     MOVE 12 TO WS-STEPS
     CALL "F351-ENV-SCAN" USING WS-COLUMN WS-MIN-Y WS-TOP-Y WS-START WS-DIR WS-STEPS WS-EMIT WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: environment_scan up through air emits the ceiling at y 15" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-EMIT * 100 + WS-Y
     MOVE 115 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-STEPS
     CALL "F351-ENV-SCAN" USING WS-COLUMN WS-MIN-Y WS-TOP-Y WS-START WS-DIR WS-STEPS WS-EMIT WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: environment_scan with max_steps 2 emits nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EMIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 15 TO WS-START
     MOVE 12 TO WS-STEPS
     CALL "F351-ENV-SCAN" USING WS-COLUMN WS-MIN-Y WS-TOP-Y WS-START WS-DIR WS-STEPS WS-EMIT WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: environment_scan from a position that is not allowed emits nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EMIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-FLAG(12)
     MOVE 10 TO WS-START
     CALL "F351-ENV-SCAN" USING WS-COLUMN WS-MIN-Y WS-TOP-Y WS-START WS-DIR WS-STEPS WS-EMIT WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: environment_scan tests the target at every allowed position (y 11 here)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-EMIT * 100 + WS-Y
     MOVE 111 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 512
         MOVE 0 TO WS-FLAG(WS-I)
     END-PERFORM
     PERFORM VARYING WS-Y FROM 15 BY 1 UNTIL WS-Y > 20
         COMPUTE WS-I = WS-Y + 1
         MOVE 1 TO WS-FLAG(WS-I)
     END-PERFORM
     MOVE 18 TO WS-START
     CALL "F351-ENV-SCAN" USING WS-COLUMN WS-MIN-Y WS-TOP-Y WS-START WS-DIR WS-STEPS WS-EMIT WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: environment_scan leaving the world emits nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EMIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-STEPS
     MOVE 15 TO WS-START
     CALL "F351-ENV-SCAN" USING WS-COLUMN WS-MIN-Y WS-TOP-Y WS-START WS-DIR WS-STEPS WS-EMIT WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: environment_scan tests the target once more after the last step (not a target: none)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-EMIT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-FLAG(17)
     CALL "F351-ENV-SCAN" USING WS-COLUMN WS-MIN-Y WS-TOP-Y WS-START WS-DIR WS-STEPS WS-EMIT WS-Y
     MOVE "acceptance US12 35-1§7 Placement modifiers: environment_scan emits the position after the last step when it is a target" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-EMIT * 100 + WS-Y
     MOVE 116 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.18 fixed_placement: [100, 49, 0] is in chunk (6, 0)
     MOVE 100 TO WS-LX(1)
     MOVE 49 TO WS-LY(1)
     MOVE 0 TO WS-LZ(1)
     MOVE 5 TO WS-LX(2)
     MOVE 50 TO WS-LY(2)
     MOVE 5 TO WS-LZ(2)
     MOVE 2 TO WS-N
     MOVE 96 TO WS-X
     MOVE 0 TO WS-Z
     CALL "F351-FIXED" USING WS-X WS-Z WS-N WS-LIST WS-COUNT WS-SMALL
     MOVE "acceptance US12 35-1§7 Placement modifiers: fixed_placement emits only the listed positions of the input's chunk (6, 0)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-COUNT * 1000 + WS-SX(1)
     MOVE 1100 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -16 TO WS-X
     CALL "F351-FIXED" USING WS-X WS-Z WS-N WS-LIST WS-COUNT WS-SMALL
     MOVE "acceptance US12 35-1§7 Placement modifiers: fixed_placement of another chunk emits nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   7.17 randomly_selected: one nextInt(n) even for n = 1
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 1 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-DRAW
     MOVE 16 TO WS-BOUND
     CALL "WGR-NEXT-INT-BOUND" USING XR-STATE WS-BOUND WS-DRAW
     MOVE "acceptance US12 35-1§7 Placement modifiers: randomly_selected of one alternative still consumes a draw (the next nextInt(16) is the second, 10)" TO TL-CASE
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-DRAW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 RUN-MODIFY.
     MOVE 5 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-MODIFY" USING XR-STATE WS-M WS-X WS-Y WS-Z WS-COUNT WS-OUT.

 RUN-MODIFY-AT-ORIGIN.
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     CALL "F351-MODIFY" USING XR-STATE WS-M WS-X WS-Y WS-Z WS-COUNT WS-OUT.
