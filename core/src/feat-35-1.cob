*> Worldgen features, part 1 (docs/protocol/35-worldgen-features-1-model-and-placement.md): the wrapped random source draws (section 5.2 and 5.3),
*> the placement modifiers (section 7), the placement evaluator (section 8) and the selectors (section 9). The source is the Xoroshiro-wrapped
*> WorldgenRandom of core/src/ores.cob (WGR-*, state of XORO.cpy).
*>
*> Entry points (state is an XR-STATE):
*>   F351-NEXT-INT USING state, result out (BINARY-LONG, signed)        nextInt(): next(32)
*>   F351-NEXT-BOOLEAN USING state, result out (BINARY-LONG 0 or 1)      nextBoolean(): the top bit
*>   F351-NEXT-LONG USING state, result out (BINARY-DOUBLE signed)       nextLong(): two next(32), the low word sign-extended
*>   F351-NEXT-GAUSSIAN USING state, result out (FLOAT-LONG)             nextGaussian(): Marsaglia polar; the spare survives a reseed
*>   F351-MODIFY USING state, modifier index, x, y, z (BINARY-LONG), out count, out positions: one modifier on one position (section 7)
*>   F351-PLACE USING state, x, y, z, result out (BINARY-LONG 0 or 1): the evaluator of 8.2 over F351-PROGRAM; the feature records FO-POS

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-NEXT-INT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS                BINARY-LONG VALUE 32.
 01 WS-R                   BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     CALL "WGR-NEXT" USING L-STATE WS-BITS WS-R
     MOVE WS-R TO L-RESULT
     GOBACK.
 END PROGRAM F351-NEXT-INT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-NEXT-BOOLEAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS                BINARY-LONG VALUE 1.
 01 WS-R                   BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     CALL "WGR-NEXT" USING L-STATE WS-BITS WS-R
     MOVE WS-R TO L-RESULT
     GOBACK.
 END PROGRAM F351-NEXT-BOOLEAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-NEXT-LONG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS                BINARY-LONG VALUE 32.
 01 WS-HI                  BINARY-DOUBLE.
 01 WS-LO                  BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-RESULT               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     CALL "WGR-NEXT" USING L-STATE WS-BITS WS-HI
     CALL "WGR-NEXT" USING L-STATE WS-BITS WS-LO
     COMPUTE L-RESULT = WS-HI * 4294967296 + WS-LO
     GOBACK.
 END PROGRAM F351-NEXT-LONG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-NEXT-GAUSSIAN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HAVE                BINARY-LONG VALUE 0.
 01 WS-SPARE               FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-TWO                 FLOAT-LONG VALUE 2.
 01 WS-MINUS-TWO           FLOAT-LONG VALUE -2.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-D1                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-V1                  FLOAT-LONG.
 01 WS-V2                  FLOAT-LONG.
 01 WS-V1B                 FLOAT-LONG.
 01 WS-V2B                 FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-S1                  FLOAT-LONG.
 01 WS-S2                  FLOAT-LONG.
 01 WS-LN                  FLOAT-LONG.
 01 WS-Q                   FLOAT-LONG.
 01 WS-M                   FLOAT-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-RESULT               FLOAT-LONG.
 PROCEDURE DIVISION USING L-STATE L-RESULT.
     IF WS-HAVE = 1
         MOVE 0 TO WS-HAVE
         MOVE WS-SPARE TO L-RESULT
         GOBACK
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-D1
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-TWO WS-D1 WS-T
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T WS-ONE WS-V1
         CALL "WGR-NEXT-DOUBLE" USING L-STATE WS-D2
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-TWO WS-D2 WS-T
         CALL STATIC "cc_f64_sub" USING BY REFERENCE WS-T WS-ONE WS-V2
         MOVE WS-V1 TO WS-V1B
         MOVE WS-V2 TO WS-V2B
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-V1 WS-V1B WS-S1
         CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-V2 WS-V2B WS-S2
         CALL STATIC "cc_f64_add" USING BY REFERENCE WS-S1 WS-S2 WS-S
         IF WS-S < WS-ONE AND WS-S NOT = WS-ZERO
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     CALL STATIC "cc_f64_log" USING BY REFERENCE WS-S WS-LN
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-MINUS-TWO WS-LN WS-T
     CALL STATIC "cc_f64_div" USING BY REFERENCE WS-T WS-S WS-Q
     CALL STATIC "cc_f64_sqrt" USING BY REFERENCE WS-Q WS-M
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-V2 WS-M WS-SPARE
     MOVE 1 TO WS-HAVE
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-V1 WS-M L-RESULT
     GOBACK.
 END PROGRAM F351-NEXT-GAUSSIAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-MODIFY.
*> USING state, modifier index (1 to FP-COUNT), x, y, z (BINARY-LONG), count out, positions out (F351-MAX-POS x 3 BINARY-LONG).
*> Kinds: 7 offset (A, B, C the half widths of the symmetric trapezoids, or the constants when D = 1), 1 count (A the constant count), 2 in_square, 3 height_range (uniform A to B), 4 biome (A = 1 passes), 5 rarity_filter (A = n),
*> 6 random_chance (F), 8 cuboid (A y_size, B xz_size constant providers; C include_edges, D include_interior, 1 or 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEAT351.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-EXTREME             BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-N                   FLOAT-LONG.
 01 WS-ONE                 FLOAT-LONG VALUE 1.
 01 WS-T                   FLOAT-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-ONCE                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-M                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-OUT.
    05 L-O OCCURS 8192 TIMES.
       10 L-OX             BINARY-LONG.
       10 L-OY             BINARY-LONG.
       10 L-OZ             BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-M L-X L-Y L-Z L-COUNT L-OUT.
     MOVE 0 TO L-COUNT WS-ONCE
     EVALUATE FP-KIND(L-M)
         WHEN 1
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > FP-A(L-M)
                 ADD 1 TO L-COUNT
                 MOVE L-X TO L-OX(L-COUNT)
                 MOVE L-Y TO L-OY(L-COUNT)
                 MOVE L-Z TO L-OZ(L-COUNT)
             END-PERFORM
         WHEN 2
             MOVE 16 TO WS-BOUND
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DX
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DZ
             ADD 1 TO L-COUNT
             COMPUTE L-OX(L-COUNT) = L-X + WS-DX
             MOVE L-Y TO L-OY(L-COUNT)
             COMPUTE L-OZ(L-COUNT) = L-Z + WS-DZ
         WHEN 3
             COMPUTE WS-BOUND = FP-B(L-M) - FP-A(L-M) + 1
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
             ADD 1 TO L-COUNT
             MOVE L-X TO L-OX(L-COUNT)
             COMPUTE L-OY(L-COUNT) = FP-A(L-M) + WS-DRAW
             MOVE L-Z TO L-OZ(L-COUNT)
         WHEN 4
             MOVE FP-A(L-M) TO WS-ONCE
         WHEN 5
             MOVE FP-A(L-M) TO WS-N
             CALL STATIC "cc_f64_div" USING BY REFERENCE WS-ONE WS-N WS-T
             CALL STATIC "cc_f64_f32_round" USING BY REFERENCE WS-T WS-U
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             IF WS-F < WS-U
                 MOVE 1 TO WS-ONCE
             END-IF
         WHEN 6
             CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
             IF WS-F < FP-F(L-M)
                 MOVE 1 TO WS-ONCE
             END-IF
         WHEN 7
*>           offset: x, then y, then z; a trapezoid of plateau 0 and half width m is nextInt(m + 1) - nextInt(m + 1), D = 1 gives the constants A, B, C
             IF FP-D(L-M) = 1
                 MOVE FP-A(L-M) TO WS-DX
                 MOVE FP-B(L-M) TO WS-DY
                 MOVE FP-C(L-M) TO WS-DZ
             ELSE
                 COMPUTE WS-BOUND = FP-A(L-M) + 1
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DX
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
                 SUBTRACT WS-DRAW FROM WS-DX
                 COMPUTE WS-BOUND = FP-B(L-M) + 1
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DY
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
                 SUBTRACT WS-DRAW FROM WS-DY
                 COMPUTE WS-BOUND = FP-C(L-M) + 1
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DZ
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DRAW
                 SUBTRACT WS-DRAW FROM WS-DZ
             END-IF
             ADD 1 TO L-COUNT
             COMPUTE L-OX(L-COUNT) = L-X + WS-DX
             COMPUTE L-OY(L-COUNT) = L-Y + WS-DY
             COMPUTE L-OZ(L-COUNT) = L-Z + WS-DZ
         WHEN OTHER
*>           kind 8, cuboid: y_size, then xz_size twice (constant providers draw nothing), x-major, then y, then z
             MOVE FP-A(L-M) TO WS-DY
             MOVE FP-B(L-M) TO WS-DX
             MOVE FP-B(L-M) TO WS-DZ
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > WS-DX
                 PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > WS-DY
                     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > WS-DZ
                         MOVE 0 TO WS-EXTREME
                         IF WS-X = 0 OR WS-X = WS-DX
                             ADD 1 TO WS-EXTREME
                         END-IF
                         IF WS-Y = 0 OR WS-Y = WS-DY
                             ADD 1 TO WS-EXTREME
                         END-IF
                         IF WS-Z = 0 OR WS-Z = WS-DZ
                             ADD 1 TO WS-EXTREME
                         END-IF
                         MOVE 1 TO WS-PASS
                         IF FP-C(L-M) = 0 AND WS-EXTREME >= 2
                             MOVE 0 TO WS-PASS
                         END-IF
                         IF FP-D(L-M) = 0 AND WS-EXTREME = 0
                             MOVE 0 TO WS-PASS
                         END-IF
                         IF WS-PASS = 1
                             ADD 1 TO L-COUNT
                             COMPUTE L-OX(L-COUNT) = L-X + WS-X
                             COMPUTE L-OY(L-COUNT) = L-Y + WS-Y
                             COMPUTE L-OZ(L-COUNT) = L-Z + WS-Z
                         END-IF
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
     END-EVALUATE
     IF WS-ONCE = 1
         ADD 1 TO L-COUNT
         MOVE L-X TO L-OX(L-COUNT)
         MOVE L-Y TO L-OY(L-COUNT)
         MOVE L-Z TO L-OZ(L-COUNT)
     END-IF
     GOBACK.
 END PROGRAM F351-MODIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-PLACE.
*> USING state, x, y, z (the input position), result out (BINARY-LONG 0 or 1). The evaluator of 8.2 over F351-PROGRAM: a stack of
*> (position, modifier index) pairs; the pair last pushed is taken; the positions a modifier emits are pushed from the last to the first
*> (so the first is processed first) when another modifier follows, or placed in emission order (FO-POS) by the last one. An empty list
*> places the feature once at the input. The result is the OR over the placements (a feature here is always true).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEAT351.
 01 WS-STACK.
    05 WS-S OCCURS 8192 TIMES.
       10 WS-SX            BINARY-LONG.
       10 WS-SY            BINARY-LONG.
       10 WS-SZ            BINARY-LONG.
       10 WS-SM            BINARY-LONG.
 01 WS-SP                  BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MCOUNT              BINARY-LONG.
 01 WS-MOUT.
    05 WS-MO OCCURS 8192 TIMES.
       10 WS-MX            BINARY-LONG.
       10 WS-MY            BINARY-LONG.
       10 WS-MZ            BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Y L-Z L-RESULT.
     MOVE 0 TO FO-COUNT L-RESULT
     IF FP-COUNT = 0
         MOVE 1 TO FO-COUNT L-RESULT
         MOVE L-X TO FO-X(1)
         MOVE L-Y TO FO-Y(1)
         MOVE L-Z TO FO-Z(1)
         GOBACK
     END-IF
     MOVE 1 TO WS-SP
     MOVE L-X TO WS-SX(1)
     MOVE L-Y TO WS-SY(1)
     MOVE L-Z TO WS-SZ(1)
     MOVE 1 TO WS-SM(1)
     PERFORM UNTIL WS-SP = 0
         MOVE WS-SX(WS-SP) TO WS-X
         MOVE WS-SY(WS-SP) TO WS-Y
         MOVE WS-SZ(WS-SP) TO WS-Z
         MOVE WS-SM(WS-SP) TO WS-M
         SUBTRACT 1 FROM WS-SP
         CALL "F351-MODIFY" USING L-STATE WS-M WS-X WS-Y WS-Z WS-MCOUNT WS-MOUT
         IF WS-M < FP-COUNT
             COMPUTE WS-NEXT = WS-M + 1
             PERFORM VARYING WS-I FROM WS-MCOUNT BY -1 UNTIL WS-I < 1
                 ADD 1 TO WS-SP
                 MOVE WS-MX(WS-I) TO WS-SX(WS-SP)
                 MOVE WS-MY(WS-I) TO WS-SY(WS-SP)
                 MOVE WS-MZ(WS-I) TO WS-SZ(WS-SP)
                 MOVE WS-NEXT TO WS-SM(WS-SP)
             END-PERFORM
         ELSE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-MCOUNT
                 ADD 1 TO FO-COUNT
                 MOVE WS-MX(WS-I) TO FO-X(FO-COUNT)
                 MOVE WS-MY(WS-I) TO FO-Y(FO-COUNT)
                 MOVE WS-MZ(WS-I) TO FO-Z(FO-COUNT)
                 MOVE 1 TO L-RESULT
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F351-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-SURFACE-REL.
*> surface_relative_threshold_filter (7.7): USING h (the height), min, max (BINARY-LONG; the int minimum and maximum when absent), y, pass out (0 or 1):
*> h + min <= y <= h + max in 64-bit arithmetic.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LOW                 BINARY-DOUBLE.
 01 WS-HIGH                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-H                    BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-PASS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-H L-MIN L-MAX L-Y L-PASS.
     COMPUTE WS-LOW = L-H + L-MIN
     COMPUTE WS-HIGH = L-H + L-MAX
     MOVE 0 TO L-PASS
     IF WS-LOW <= L-Y AND L-Y <= WS-HIGH
         MOVE 1 TO L-PASS
     END-IF
     GOBACK.
 END PROGRAM F351-SURFACE-REL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-WATER-DEPTH.
*> surface_water_depth_filter (7.8): USING ocean floor height, world surface height, max_water_depth (BINARY-LONG), pass out: surface - floor <= max.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FLOOR                BINARY-LONG.
 01 L-SURFACE              BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-PASS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLOOR L-SURFACE L-MAX L-PASS.
     MOVE 0 TO L-PASS
     IF L-SURFACE - L-FLOOR <= L-MAX
         MOVE 1 TO L-PASS
     END-IF
     GOBACK.
 END PROGRAM F351-WATER-DEPTH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-NOISE-COUNT.
*> noise_based_count (7.9): USING noise (FLOAT-LONG holding the float of the 2D noise), ratio (BINARY-LONG), offset (FLOAT-LONG), count out (BINARY-LONG):
*> (int) ceil((noise + offset) * ratio), the float widened to double before the addition.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-RATIO               FLOAT-LONG.
 01 WS-PROD                FLOAT-LONG.
 01 WS-CEIL                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-NOISE                FLOAT-LONG.
 01 L-RATIO                BINARY-LONG.
 01 L-OFFSET               FLOAT-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-NOISE L-RATIO L-OFFSET L-COUNT.
     MOVE L-RATIO TO WS-RATIO
     CALL STATIC "cc_f64_add" USING BY REFERENCE L-NOISE L-OFFSET WS-SUM
     CALL STATIC "cc_f64_mul" USING BY REFERENCE WS-SUM WS-RATIO WS-PROD
     CALL STATIC "cc_f64_ceil" USING BY REFERENCE WS-PROD WS-CEIL
     CALL STATIC "cc_f64_to_i32" USING BY REFERENCE WS-CEIL L-COUNT
     GOBACK.
 END PROGRAM F351-NOISE-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-NOISE-THRESHOLD.
*> noise_threshold_count (7.10): USING noise (FLOAT-LONG), noise_level (FLOAT-LONG), below, above (BINARY-LONG), count out:
*> below when noise < noise_level (strict; equal or NaN gives above).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NOISE                FLOAT-LONG.
 01 L-LEVEL                FLOAT-LONG.
 01 L-BELOW                BINARY-LONG.
 01 L-ABOVE                BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-NOISE L-LEVEL L-BELOW L-ABOVE L-COUNT.
     MOVE L-ABOVE TO L-COUNT
     IF L-NOISE < L-LEVEL
         MOVE L-BELOW TO L-COUNT
     END-IF
     GOBACK.
 END PROGRAM F351-NOISE-THRESHOLD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-HEIGHTMAP-EMIT.
*> heightmap (7.13): USING h (the height), min y (BINARY-LONG), emit out (0 or 1): emitted iff h > min y.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-H                    BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-EMIT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-H L-MIN-Y L-EMIT.
     MOVE 0 TO L-EMIT
     IF L-H > L-MIN-Y
         MOVE 1 TO L-EMIT
     END-IF
     GOBACK.
 END PROGRAM F351-HEIGHTMAP-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-FLOOR-OF-LAYER.
*> floorOfLayer of count_on_every_layer (7.11): USING column (BINARY-LONG classes by y, entry 1 is min y: 0 solid, 1 air, 2 water or lava,
*> 3 bedrock), min y, start y, target layer (BINARY-LONG), y out (BINARY-LONG; min y - 1 for none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-YY                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-ABOVE-EMPTY         BINARY-LONG.
 01 WS-BELOW-EMPTY         BINARY-LONG.
 LINKAGE SECTION.
 01 L-COLUMN.
    05 L-CLASS             BINARY-LONG OCCURS 512 TIMES.
 01 L-MIN-Y                BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-COLUMN L-MIN-Y L-START L-TARGET L-RESULT.
     COMPUTE L-RESULT = L-MIN-Y - 1
     MOVE 0 TO WS-N
     COMPUTE WS-ABOVE = L-CLASS(L-START - L-MIN-Y + 1)
     PERFORM VARYING WS-YY FROM L-START BY -1 UNTIL WS-YY <= L-MIN-Y OR L-RESULT >= L-MIN-Y
         MOVE L-CLASS(WS-YY - 1 - L-MIN-Y + 1) TO WS-BELOW
         MOVE 0 TO WS-ABOVE-EMPTY WS-BELOW-EMPTY
         IF WS-ABOVE = 1 OR WS-ABOVE = 2
             MOVE 1 TO WS-ABOVE-EMPTY
         END-IF
         IF WS-BELOW = 1 OR WS-BELOW = 2
             MOVE 1 TO WS-BELOW-EMPTY
         END-IF
         IF WS-BELOW-EMPTY = 0 AND WS-ABOVE-EMPTY = 1 AND WS-BELOW NOT = 3
             IF WS-N = L-TARGET
                 MOVE WS-YY TO L-RESULT
             ELSE
                 ADD 1 TO WS-N
             END-IF
         END-IF
         MOVE WS-BELOW TO WS-ABOVE
     END-PERFORM
     GOBACK.
 END PROGRAM F351-FLOOR-OF-LAYER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-LAYERS.
*> count_on_every_layer (7.11) over a world of one repeated column: USING state, x, z (the input), count (the constant count provider), column (as
*> F351-FLOOR-OF-LAYER), min y, height (the MOTION_BLOCKING height of every column), count out, positions out (F351-MAX-POS x 3 BINARY-LONG).
*> Per layer: for i from 0 while i < count (the provider is sampled at every test: a constant draws nothing), x = input + nextInt(16), then z; emit
*> when the layer has a floor; the next layer when any was found.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LAYER               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BOUND               BINARY-LONG VALUE 16.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-COLUMN.
    05 L-CLASS             BINARY-LONG OCCURS 512 TIMES.
 01 L-MIN-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-OUT.
    05 L-O OCCURS 8192 TIMES.
       10 L-OX             BINARY-LONG.
       10 L-OY             BINARY-LONG.
       10 L-OZ             BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-X L-Z L-N L-COLUMN L-MIN-Y L-HEIGHT L-COUNT L-OUT.
     MOVE 0 TO L-COUNT WS-LAYER WS-STOP
     PERFORM UNTIL WS-STOP = 1
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-N
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DX
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-BOUND WS-DZ
             CALL "F351-FLOOR-OF-LAYER" USING L-COLUMN L-MIN-Y L-HEIGHT WS-LAYER WS-Y
             IF WS-Y >= L-MIN-Y
                 ADD 1 TO L-COUNT
                 COMPUTE L-OX(L-COUNT) = L-X + WS-DX
                 MOVE WS-Y TO L-OY(L-COUNT)
                 COMPUTE L-OZ(L-COUNT) = L-Z + WS-DZ
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         ADD 1 TO WS-LAYER
         IF WS-FOUND = 0
             MOVE 1 TO WS-STOP
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F351-LAYERS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-ENV-SCAN.
*> environment_scan (7.12) over one column: USING column (BINARY-LONG flags by y, entry 1 is min y: 1 allowed, 2 target, 3 both, 0 neither), min y,
*> top y (the highest y inside the build height), start y, direction (1 up, -1 down), max steps (1 to 32), emit out (0 or 1), y out.
*> Not allowed at the start: nothing. Up to max steps moves: the target tested at each position, a move out of the world stops without emission,
*> a disallowed position ends the loop; after the loop the target is tested once more.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Y                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-COLUMN.
    05 L-F                 BINARY-LONG OCCURS 512 TIMES.
 01 L-MIN-Y                BINARY-LONG.
 01 L-TOP-Y                BINARY-LONG.
 01 L-START                BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-STEPS                BINARY-LONG.
 01 L-EMIT                 BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING L-COLUMN L-MIN-Y L-TOP-Y L-START L-DIR L-STEPS L-EMIT L-Y.
*>   WS-STATE: 0 scanning, 1 finished (emitted, or left the world), 2 left the loop at a disallowed position
     MOVE 0 TO L-EMIT L-Y WS-STATE WS-I
     MOVE L-START TO WS-Y
     MOVE L-F(WS-Y - L-MIN-Y + 1) TO WS-FLAG
     IF WS-FLAG NOT = 1 AND WS-FLAG NOT = 3
         MOVE 1 TO WS-STATE
     END-IF
     PERFORM UNTIL WS-STATE > 0 OR WS-I >= L-STEPS
         MOVE L-F(WS-Y - L-MIN-Y + 1) TO WS-FLAG
         IF WS-FLAG >= 2
             MOVE 1 TO L-EMIT
             MOVE WS-Y TO L-Y
             MOVE 1 TO WS-STATE
         ELSE
             ADD L-DIR TO WS-Y
             IF WS-Y < L-MIN-Y OR WS-Y > L-TOP-Y
                 MOVE 1 TO WS-STATE
             ELSE
                 MOVE L-F(WS-Y - L-MIN-Y + 1) TO WS-FLAG
                 IF WS-FLAG = 1 OR WS-FLAG = 3
                     ADD 1 TO WS-I
                 ELSE
                     MOVE 2 TO WS-STATE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-STATE NOT = 1
         MOVE L-F(WS-Y - L-MIN-Y + 1) TO WS-FLAG
         IF WS-FLAG >= 2
             MOVE 1 TO L-EMIT
             MOVE WS-Y TO L-Y
         END-IF
     END-IF
     GOBACK.
 END PROGRAM F351-ENV-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-FIXED.
*> fixed_placement (7.18): USING input x, input z, count of listed positions, listed positions (BINARY-LONG x, y, z each), count out, positions out:
*> the listed positions in the chunk of the input, in list order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-LIST.
    05 L-P OCCURS 64 TIMES.
       10 L-PX             BINARY-LONG.
       10 L-PY             BINARY-LONG.
       10 L-PZ             BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-OUT.
    05 L-O OCCURS 64 TIMES.
       10 L-OX             BINARY-LONG.
       10 L-OY             BINARY-LONG.
       10 L-OZ             BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Z L-N L-LIST L-COUNT L-OUT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         IF FUNCTION INTEGER(L-PX(WS-I) / 16) = FUNCTION INTEGER(L-X / 16) AND FUNCTION INTEGER(L-PZ(WS-I) / 16) = FUNCTION INTEGER(L-Z / 16)
             ADD 1 TO L-COUNT
             MOVE L-PX(WS-I) TO L-OX(L-COUNT)
             MOVE L-PY(WS-I) TO L-OY(L-COUNT)
             MOVE L-PZ(WS-I) TO L-OZ(L-COUNT)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F351-FIXED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-RANDOM-SELECTOR.
*> random_selector (9.2): USING state, entries (BINARY-LONG), chances (FLOAT-LONG x 64, floats widened to doubles), chosen out (BINARY-LONG:
*> the 1-based entry, 0 for the default). Walks the entries in order: one nextFloat each, the entry is chosen when the float is strictly less than its chance.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-N                    BINARY-LONG.
 01 L-CHANCES.
    05 L-CHANCE            FLOAT-LONG OCCURS 64 TIMES.
 01 L-CHOSEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-N L-CHANCES L-CHOSEN.
     MOVE 0 TO L-CHOSEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N OR L-CHOSEN > 0
         CALL "WGR-NEXT-FLOAT" USING L-STATE WS-F
         IF WS-F < L-CHANCE(WS-I)
             MOVE WS-I TO L-CHOSEN
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F351-RANDOM-SELECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-SIMPLE-SELECTOR.
*> simple_random_selector (9.3): USING state, size (BINARY-LONG > 0), chosen out (1-based): one nextInt(size), even for a size of 1.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-SIZE                 BINARY-LONG.
 01 L-CHOSEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-SIZE L-CHOSEN.
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE L-SIZE L-CHOSEN
     ADD 1 TO L-CHOSEN
     GOBACK.
 END PROGRAM F351-SIMPLE-SELECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-BOOLEAN-SELECTOR.
*> random_boolean_selector (9.4): USING state, chosen out (1 feature_true, 2 feature_false): one nextBoolean.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-CHOSEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-CHOSEN.
     CALL "F351-NEXT-BOOLEAN" USING L-STATE WS-B
     MOVE 2 TO L-CHOSEN
     IF WS-B = 1
         MOVE 1 TO L-CHOSEN
     END-IF
     GOBACK.
 END PROGRAM F351-BOOLEAN-SELECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-WEIGHTED-SELECTOR.
*> weighted_random_selector (9.5): USING state, entries, weights (BINARY-LONG x 64), chosen out (1-based; 0 when the total weight is 0, with no draw and
*> a false result): one nextInt(total weight), the entry whose cumulative weight first exceeds the draw.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-N                    BINARY-LONG.
 01 L-WEIGHTS.
    05 L-WEIGHT            BINARY-LONG OCCURS 64 TIMES.
 01 L-CHOSEN               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-N L-WEIGHTS L-CHOSEN.
     MOVE 0 TO L-CHOSEN WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N
         ADD L-WEIGHT(WS-I) TO WS-TOTAL
     END-PERFORM
     IF WS-TOTAL > 0
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-TOTAL WS-DRAW
         MOVE 0 TO WS-RUN
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-N OR L-CHOSEN > 0
             ADD L-WEIGHT(WS-I) TO WS-RUN
             IF WS-DRAW < WS-RUN
                 MOVE WS-I TO L-CHOSEN
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM F351-WEIGHTED-SELECTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-SEQUENCE.
*> sequence (9.6): USING entries, results (BINARY-LONG x 64, the result 1 or 0 the element would return, in set order), ran out (the elements run),
*> result out (1 when every element returned true): stops with false at the first element that returns false.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-RESULTS.
    05 L-R                 BINARY-LONG OCCURS 64 TIMES.
 01 L-RAN                  BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-RESULTS L-RAN L-RESULT.
     MOVE 1 TO L-RESULT
     MOVE 0 TO L-RAN
     PERFORM UNTIL L-RAN >= L-N OR L-RESULT = 0
         ADD 1 TO L-RAN
         MOVE L-R(L-RAN) TO L-RESULT
     END-PERFORM
     GOBACK.
 END PROGRAM F351-SEQUENCE.
*> Worldgen features, part 1, tables (docs/protocol/35-worldgen-features-1 sections 1, 2, 3, 4, 6, 10 and 14).
*>   F351-REGISTRY-SIZE USING registry (BINARY-LONG 1 to 12: feature_type, placement_modifier_type, block_predicate_type, block_state_provider_type,
*>     int_provider_type, float_provider_type, height_provider_type, trunk_placer_type, foliage_placer_type, root_placer_type, tree_decorator_type,
*>     feature_size_type), size out (BINARY-LONG)
*>   F351-REGISTRY-ID USING registry, name (PIC X(48), without the namespace), id out (BINARY-LONG; -1 unknown): the registration order of section 3
*>   F351-HAS-FILE USING feature type name, flag out: 0 for the 11 types without a top-level feature file (section 1.1)
*>   F351-WHERE USING feature type name, text out (PIC X(60)): the document part of section 14

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-REGISTRY-SIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SIZES.
    05 FILLER BINARY-LONG VALUE 58.
    05 FILLER BINARY-LONG VALUE 18.
    05 FILLER BINARY-LONG VALUE 16.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-LONG VALUE 6.
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 11.
    05 FILLER BINARY-LONG VALUE 2.
 01 WS-SIZE-TABLE REDEFINES WS-SIZES.
    05 WS-SIZE BINARY-LONG OCCURS 12 TIMES.
 LINKAGE SECTION.
 01 L-REGISTRY BINARY-LONG.
 01 L-SIZE BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-SIZE.
     MOVE 0 TO L-SIZE
     IF L-REGISTRY >= 1 AND L-REGISTRY <= 12
         MOVE WS-SIZE(L-REGISTRY) TO L-SIZE
     END-IF
     GOBACK.
 END PROGRAM F351-REGISTRY-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-REGISTRY-ID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "bamboo".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "block_blob".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "block_column".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "block_pile".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "blue_ice".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "bonus_chest".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "chorus_plant".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "coral_claw".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "coral_tree".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "delta_feature".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "disk".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "end_gateway".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "end_island".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "end_platform".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "end_podium".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "end_spike".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "fallen_tree".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "fill_layer".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "fossil".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "freeze_top_layer".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "geode".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "huge_brown_mushroom".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "huge_fungus".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "huge_red_mushroom".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "iceberg".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "lake".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "large_dripstone".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "monster_room".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "multiface_growth".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "netherrack_replace_blobs".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "no_op".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "ore".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "overlay".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "projected_random_patchy_square".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "random_boolean_selector".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "random_neighbor_spread".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "random_selector".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "replace_single_block".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "root_system".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "scattered_ore".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "sculk_patch".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "sequence".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "simple_block".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "simple_random_selector".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "single_block_pillar".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "speleothem".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "speleothem_cluster".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "spike".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "spring_feature".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "stepped_column_cluster".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "template".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "underwater_magma".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "vegetation_patch".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "vines".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "void_start_platform".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "waterlogged_vegetation_patch".
    05 FILLER PIC 99 VALUE 1.
    05 FILLER PIC X(48) VALUE "weighted_random_selector".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "block_predicate_filter".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "rarity_filter".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "random_chance".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "surface_relative_threshold_filter".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "surface_water_depth_filter".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "biome".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "count".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "noise_based_count".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "noise_threshold_count".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "count_on_every_layer".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "cuboid".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "environment_scan".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "heightmap".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "height_range".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "in_square".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "offset".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "randomly_selected".
    05 FILLER PIC 99 VALUE 2.
    05 FILLER PIC X(48) VALUE "fixed_placement".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "matching_blocks".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "matching_block_tag".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "matching_fluids".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "matching_biomes".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "has_sturdy_face".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "solid".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "replaceable".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "would_survive".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "inside_world_bounds".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "any_of".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "all_of".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "not".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "true".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "unobstructed".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "height_range".
    05 FILLER PIC 99 VALUE 3.
    05 FILLER PIC X(48) VALUE "volume_match".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(48) VALUE "copy_properties".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(48) VALUE "dual_noise".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(48) VALUE "noise".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(48) VALUE "noise_threshold".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(48) VALUE "random_block".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(48) VALUE "randomized_int".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(48) VALUE "rotated".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(48) VALUE "rule_based".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(48) VALUE "simple".
    05 FILLER PIC 99 VALUE 4.
    05 FILLER PIC X(48) VALUE "weighted".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(48) VALUE "constant".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(48) VALUE "uniform".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(48) VALUE "biased_to_bottom".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(48) VALUE "very_biased_to_bottom".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(48) VALUE "clamped".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(48) VALUE "weighted_list".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(48) VALUE "clamped_normal".
    05 FILLER PIC 99 VALUE 5.
    05 FILLER PIC X(48) VALUE "trapezoid".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(48) VALUE "constant".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(48) VALUE "uniform".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(48) VALUE "clamped_normal".
    05 FILLER PIC 99 VALUE 6.
    05 FILLER PIC X(48) VALUE "trapezoid".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(48) VALUE "constant".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(48) VALUE "uniform".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(48) VALUE "biased_to_bottom".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(48) VALUE "very_biased_to_bottom".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(48) VALUE "trapezoid".
    05 FILLER PIC 99 VALUE 7.
    05 FILLER PIC X(48) VALUE "weighted_list".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(48) VALUE "straight_trunk_placer".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(48) VALUE "forking_trunk_placer".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(48) VALUE "giant_trunk_placer".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(48) VALUE "mega_jungle_trunk_placer".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(48) VALUE "dark_oak_trunk_placer".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(48) VALUE "fancy_trunk_placer".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(48) VALUE "bending_trunk_placer".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(48) VALUE "upwards_branching_trunk_placer".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(48) VALUE "cherry_trunk_placer".
    05 FILLER PIC 99 VALUE 8.
    05 FILLER PIC X(48) VALUE "poplar_trunk_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "blob_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "spruce_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "pine_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "acacia_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "bush_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "fancy_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "jungle_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "mega_pine_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "dark_oak_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "random_spread_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "cherry_foliage_placer".
    05 FILLER PIC 99 VALUE 9.
    05 FILLER PIC X(48) VALUE "poplar_foliage_placer".
    05 FILLER PIC 99 VALUE 10.
    05 FILLER PIC X(48) VALUE "mangrove_root_placer".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "trunk_vine".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "leave_vine".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "pale_moss".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "creaking_heart".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "cocoa".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "shelf_mushroom".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "beehive".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "alter_ground".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "attached_to_leaves".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "place_on_ground".
    05 FILLER PIC 99 VALUE 11.
    05 FILLER PIC X(48) VALUE "attached_to_logs".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(48) VALUE "two_layers_feature_size".
    05 FILLER PIC 99 VALUE 12.
    05 FILLER PIC X(48) VALUE "three_layers_feature_size".
 01 WS-ROW-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 156 TIMES.
       10 WS-REG PIC 99.
       10 WS-NAME PIC X(48).
 01 WS-I BINARY-LONG.
 01 WS-ORD BINARY-LONG.
 LINKAGE SECTION.
 01 L-REGISTRY BINARY-LONG.
 01 L-NAME PIC X(48).
 01 L-ID BINARY-LONG.
 PROCEDURE DIVISION USING L-REGISTRY L-NAME L-ID.
     MOVE -1 TO L-ID
     MOVE 0 TO WS-ORD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 156 OR L-ID >= 0
         IF WS-REG(WS-I) = L-REGISTRY
             IF WS-NAME(WS-I) = L-NAME
                 MOVE WS-ORD TO L-ID
             END-IF
             ADD 1 TO WS-ORD
         END-IF
     END-PERFORM
     GOBACK.
*> F351-REGISTRY-NAME USING registry, id (BINARY-LONG), name out (PIC X(48), spaces when there is no such id): the inverse
     ENTRY "F351-REGISTRY-NAME" USING L-REGISTRY L-ID L-NAME
     MOVE SPACES TO L-NAME
     MOVE 0 TO WS-ORD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 156
         IF WS-REG(WS-I) = L-REGISTRY
             IF WS-ORD = L-ID
                 MOVE WS-NAME(WS-I) TO L-NAME
             END-IF
             ADD 1 TO WS-ORD
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F351-REGISTRY-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-HAS-FILE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NOFILE.
    05 FILLER PIC X(48) VALUE "coral_claw".
    05 FILLER PIC X(48) VALUE "coral_tree".
    05 FILLER PIC X(48) VALUE "fill_layer".
    05 FILLER PIC X(48) VALUE "no_op".
    05 FILLER PIC X(48) VALUE "projected_random_patchy_square".
    05 FILLER PIC X(48) VALUE "replace_single_block".
    05 FILLER PIC X(48) VALUE "sculk_patch".
    05 FILLER PIC X(48) VALUE "single_block_pillar".
    05 FILLER PIC X(48) VALUE "speleothem".
    05 FILLER PIC X(48) VALUE "stepped_column_cluster".
    05 FILLER PIC X(48) VALUE "template".
 01 WS-NOFILE-TABLE REDEFINES WS-NOFILE.
    05 WS-N PIC X(48) OCCURS 11 TIMES.
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME PIC X(48).
 01 L-FLAG BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-FLAG.
     MOVE 1 TO L-FLAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         IF WS-N(WS-I) = L-NAME
             MOVE 0 TO L-FLAG
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F351-HAS-FILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-WHERE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ROWS.
    05 FILLER PIC X(48) VALUE "bamboo".
    05 FILLER PIC X(60) VALUE "35-4 sections 4, 5, 6".
    05 FILLER PIC X(48) VALUE "block_blob".
    05 FILLER PIC X(60) VALUE "35-5 sections 3 to 12".
    05 FILLER PIC X(48) VALUE "block_column".
    05 FILLER PIC X(60) VALUE "35-4 sections 4, 5, 6".
    05 FILLER PIC X(48) VALUE "block_pile".
    05 FILLER PIC X(60) VALUE "35-5 sections 3 to 12".
    05 FILLER PIC X(48) VALUE "blue_ice".
    05 FILLER PIC X(60) VALUE "35-5 sections 3 to 12".
    05 FILLER PIC X(48) VALUE "bonus_chest".
    05 FILLER PIC X(60) VALUE "35-5 sections 13 to 16, 18".
    05 FILLER PIC X(48) VALUE "chorus_plant".
    05 FILLER PIC X(60) VALUE "35-7 sections 3, 4, 8, 9, 10".
    05 FILLER PIC X(48) VALUE "coral_claw".
    05 FILLER PIC X(60) VALUE "35-5 sections 13 to 16, 18".
    05 FILLER PIC X(48) VALUE "coral_tree".
    05 FILLER PIC X(60) VALUE "35-5 sections 13 to 16, 18".
    05 FILLER PIC X(48) VALUE "delta_feature".
    05 FILLER PIC X(60) VALUE "35-7 sections 3, 4, 8, 9, 10".
    05 FILLER PIC X(48) VALUE "disk".
    05 FILLER PIC X(60) VALUE "35-5 sections 3 to 12".
    05 FILLER PIC X(48) VALUE "end_gateway".
    05 FILLER PIC X(60) VALUE "35-7 sections 3, 4, 8, 9, 10".
    05 FILLER PIC X(48) VALUE "end_island".
    05 FILLER PIC X(60) VALUE "35-7 sections 3, 4, 8, 9, 10".
    05 FILLER PIC X(48) VALUE "end_platform".
    05 FILLER PIC X(60) VALUE "35-7 sections 3, 4, 8, 9, 10".
    05 FILLER PIC X(48) VALUE "end_podium".
    05 FILLER PIC X(60) VALUE "35-7 sections 3, 4, 8, 9, 10".
    05 FILLER PIC X(48) VALUE "end_spike".
    05 FILLER PIC X(60) VALUE "35-7 sections 3, 4, 8, 9, 10".
    05 FILLER PIC X(48) VALUE "fallen_tree".
    05 FILLER PIC X(60) VALUE "35-3 sections 2 and 7".
    05 FILLER PIC X(48) VALUE "fill_layer".
    05 FILLER PIC X(60) VALUE "35-5 sections 3 to 12".
    05 FILLER PIC X(48) VALUE "fossil".
    05 FILLER PIC X(60) VALUE "35-6 sections 4 to 10".
    05 FILLER PIC X(48) VALUE "freeze_top_layer".
    05 FILLER PIC X(60) VALUE "35-5 sections 3 to 12".
    05 FILLER PIC X(48) VALUE "geode".
    05 FILLER PIC X(60) VALUE "35-6 sections 4 to 10".
    05 FILLER PIC X(48) VALUE "huge_brown_mushroom".
    05 FILLER PIC X(60) VALUE "35-4 sections 8, 9, 10, 11".
    05 FILLER PIC X(48) VALUE "huge_fungus".
    05 FILLER PIC X(60) VALUE "35-4 sections 8, 9, 10, 11".
    05 FILLER PIC X(48) VALUE "huge_red_mushroom".
    05 FILLER PIC X(60) VALUE "35-4 sections 8, 9, 10, 11".
    05 FILLER PIC X(48) VALUE "iceberg".
    05 FILLER PIC X(60) VALUE "35-5 sections 3 to 12".
    05 FILLER PIC X(48) VALUE "lake".
    05 FILLER PIC X(60) VALUE "35-5 sections 3 to 12".
    05 FILLER PIC X(48) VALUE "large_dripstone".
    05 FILLER PIC X(60) VALUE "35-6 sections 4 to 10".
    05 FILLER PIC X(48) VALUE "monster_room".
    05 FILLER PIC X(60) VALUE "35-6 sections 4 to 10".
    05 FILLER PIC X(48) VALUE "multiface_growth".
    05 FILLER PIC X(60) VALUE "35-4 sections 8, 9, 10, 11".
    05 FILLER PIC X(48) VALUE "netherrack_replace_blobs".
    05 FILLER PIC X(60) VALUE "35-5 sections 3 to 12".
    05 FILLER PIC X(48) VALUE "no_op".
    05 FILLER PIC X(60) VALUE "35-1 section 9".
    05 FILLER PIC X(48) VALUE "ore".
    05 FILLER PIC X(60) VALUE "11 section 7".
    05 FILLER PIC X(48) VALUE "overlay".
    05 FILLER PIC X(60) VALUE "35-4 section 7".
    05 FILLER PIC X(48) VALUE "projected_random_patchy_square".
    05 FILLER PIC X(60) VALUE "35-4 section 7".
    05 FILLER PIC X(48) VALUE "random_boolean_selector".
    05 FILLER PIC X(60) VALUE "35-1 section 9".
    05 FILLER PIC X(48) VALUE "random_neighbor_spread".
    05 FILLER PIC X(60) VALUE "35-4 section 7".
    05 FILLER PIC X(48) VALUE "random_selector".
    05 FILLER PIC X(60) VALUE "35-1 section 9".
    05 FILLER PIC X(48) VALUE "replace_single_block".
    05 FILLER PIC X(60) VALUE "35-4 section 7".
    05 FILLER PIC X(48) VALUE "root_system".
    05 FILLER PIC X(60) VALUE "35-4 sections 8, 9, 10, 11".
    05 FILLER PIC X(48) VALUE "scattered_ore".
    05 FILLER PIC X(60) VALUE "35-1 section 13".
    05 FILLER PIC X(48) VALUE "sculk_patch".
    05 FILLER PIC X(60) VALUE "35-6 sections 4 to 10".
    05 FILLER PIC X(48) VALUE "sequence".
    05 FILLER PIC X(60) VALUE "35-1 section 9".
    05 FILLER PIC X(48) VALUE "simple_block".
    05 FILLER PIC X(60) VALUE "35-4 sections 4, 5, 6".
    05 FILLER PIC X(48) VALUE "simple_random_selector".
    05 FILLER PIC X(60) VALUE "35-1 section 9".
    05 FILLER PIC X(48) VALUE "single_block_pillar".
    05 FILLER PIC X(60) VALUE "35-4 section 7".
    05 FILLER PIC X(48) VALUE "speleothem".
    05 FILLER PIC X(60) VALUE "35-6 sections 4 to 10".
    05 FILLER PIC X(48) VALUE "speleothem_cluster".
    05 FILLER PIC X(60) VALUE "35-6 sections 4 to 10".
    05 FILLER PIC X(48) VALUE "spike".
    05 FILLER PIC X(60) VALUE "35-5 sections 13 to 16, 18".
    05 FILLER PIC X(48) VALUE "spring_feature".
    05 FILLER PIC X(60) VALUE "35-5 sections 3 to 12".
    05 FILLER PIC X(48) VALUE "stepped_column_cluster".
    05 FILLER PIC X(60) VALUE "35-7 sections 3, 4, 8, 9, 10".
    05 FILLER PIC X(48) VALUE "template".
    05 FILLER PIC X(60) VALUE "35-6 sections 4 to 10".
    05 FILLER PIC X(48) VALUE "tree".
    05 FILLER PIC X(60) VALUE "35-3 sections 2 and 7".
    05 FILLER PIC X(48) VALUE "underwater_magma".
    05 FILLER PIC X(60) VALUE "35-5 sections 13 to 16, 18".
    05 FILLER PIC X(48) VALUE "vegetation_patch".
    05 FILLER PIC X(60) VALUE "35-4 sections 8, 9, 10, 11".
    05 FILLER PIC X(48) VALUE "vines".
    05 FILLER PIC X(60) VALUE "35-4 section 7".
    05 FILLER PIC X(48) VALUE "void_start_platform".
    05 FILLER PIC X(60) VALUE "35-7 sections 3, 4, 8, 9, 10".
    05 FILLER PIC X(48) VALUE "waterlogged_vegetation_patch".
    05 FILLER PIC X(60) VALUE "35-4 sections 8, 9, 10, 11".
    05 FILLER PIC X(48) VALUE "weighted_random_selector".
    05 FILLER PIC X(60) VALUE "35-1 section 9".
 01 WS-ROW-TABLE REDEFINES WS-ROWS.
    05 WS-ROW OCCURS 58 TIMES.
       10 WS-NAME PIC X(48).
       10 WS-TEXT PIC X(60).
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME PIC X(48).
 01 L-TEXT PIC X(60).
 PROCEDURE DIVISION USING L-NAME L-TEXT.
     MOVE SPACES TO L-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 58
         IF WS-NAME(WS-I) = L-NAME
             MOVE WS-TEXT(WS-I) TO L-TEXT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F351-WHERE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-SET-FLAGS.
*> Section 2.2: USING kind (1 setBlock: setBlockAndUpdate, 2 safeSetBlock), flags out (BINARY-LONG): 3 (flags 1 and 2) and 2 (flag 2 only).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-FLAGS                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-FLAGS.
     MOVE 2 TO L-FLAGS
     IF L-KIND = 1
         MOVE 3 TO L-FLAGS
     END-IF
     GOBACK.
 END PROGRAM F351-SET-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-MARK-ABOVE.
*> Section 2.2 markAboveForPostProcessing: USING air one above (0 or 1), air two above (0 or 1), marks out (BINARY-LONG, 0 to 2): twice, move up; stop
*> at air; otherwise that position is marked.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AIR1                 BINARY-LONG.
 01 L-AIR2                 BINARY-LONG.
 01 L-MARKS                BINARY-LONG.
 PROCEDURE DIVISION USING L-AIR1 L-AIR2 L-MARKS.
     MOVE 0 TO L-MARKS
     IF L-AIR1 = 0
         ADD 1 TO L-MARKS
         IF L-AIR2 = 0
             ADD 1 TO L-MARKS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM F351-MARK-ABOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-WRITE-ZONE.
*> Section 4.1 item 1: USING chunk x, chunk z, centre x, centre z, write radius (BINARY-LONG), flag out: both distances at most the radius.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CENTER-X             BINARY-LONG.
 01 L-CENTER-Z             BINARY-LONG.
 01 L-RADIUS               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-CENTER-X L-CENTER-Z L-RADIUS L-FLAG.
     MOVE 0 TO L-FLAG
     IF FUNCTION ABS(L-CENTER-X - L-CX) <= L-RADIUS AND FUNCTION ABS(L-CENTER-Z - L-CZ) <= L-RADIUS
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM F351-WRITE-ZONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-READ-AVAILABLE.
*> Section 4.1 item 4: USING Chebyshev distance of a chunk from the centre, available out (1 when getChunk answers: distance at most 8; 0 when it throws),
*> has chunk out (1 for a distance below the dependency count 9).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DISTANCE             BINARY-LONG.
 01 L-AVAILABLE            BINARY-LONG.
 01 L-HAS                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DISTANCE L-AVAILABLE L-HAS.
     MOVE 0 TO L-AVAILABLE L-HAS
     IF L-DISTANCE <= 8
         MOVE 1 TO L-AVAILABLE
     END-IF
     IF L-DISTANCE < 9
         MOVE 1 TO L-HAS
     END-IF
     GOBACK.
 END PROGRAM F351-READ-AVAILABLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-Y-OUTSIDE.
*> Section 4.1 item 3: USING y, min y, height (BINARY-LONG), flag out: isOutsideBuildHeight, y < min y or y > min y + height - 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    BINARY-LONG.
 01 L-MIN-Y                BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-Y L-MIN-Y L-HEIGHT L-FLAG.
     MOVE 0 TO L-FLAG
     IF L-Y < L-MIN-Y OR L-Y > L-MIN-Y + L-HEIGHT - 1
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM F351-Y-OUTSIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-HEIGHTMAP-ORDINAL.
*> Section 4.2: USING name (PIC X(32)), ordinal out (BINARY-LONG 0 to 5; -1 for another name).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAMES.
    05 FILLER PIC X(32) VALUE "WORLD_SURFACE_WG".
    05 FILLER PIC X(32) VALUE "WORLD_SURFACE".
    05 FILLER PIC X(32) VALUE "OCEAN_FLOOR_WG".
    05 FILLER PIC X(32) VALUE "OCEAN_FLOOR".
    05 FILLER PIC X(32) VALUE "MOTION_BLOCKING".
    05 FILLER PIC X(32) VALUE "MOTION_BLOCKING_NO_LEAVES".
 01 WS-TABLE REDEFINES WS-NAMES.
    05 WS-NAME PIC X(32) OCCURS 6 TIMES.
 01 WS-I BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-ORDINAL              BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ORDINAL.
     MOVE -1 TO L-ORDINAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF WS-NAME(WS-I) = L-NAME
             COMPUTE L-ORDINAL = WS-I - 1
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM F351-HEIGHTMAP-ORDINAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-HEIGHTMAP-PASSES.
*> Section 4.2 test of a block state: USING ordinal (0 to 5), in tag blocks_motion_in_heightmap (0 or 1), in tag blocks_motion_in_heightmap_no_leaves (0 or 1),
*> fluid state non-empty (0 or 1), is air (0 or 1), pass out. The surface maps: not air; the ocean floor maps: the first tag; MOTION_BLOCKING: the first tag
*> or a fluid; MOTION_BLOCKING_NO_LEAVES: the second tag or a fluid.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ORDINAL              BINARY-LONG.
 01 L-IN-TAG               BINARY-LONG.
 01 L-IN-TAG-NL            BINARY-LONG.
 01 L-FLUID                BINARY-LONG.
 01 L-AIR                  BINARY-LONG.
 01 L-PASS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ORDINAL L-IN-TAG L-IN-TAG-NL L-FLUID L-AIR L-PASS.
     MOVE 0 TO L-PASS
     EVALUATE L-ORDINAL
         WHEN 0
         WHEN 1
             IF L-AIR = 0
                 MOVE 1 TO L-PASS
             END-IF
         WHEN 2
         WHEN 3
             MOVE L-IN-TAG TO L-PASS
         WHEN 4
             IF L-IN-TAG = 1 OR L-FLUID = 1
                 MOVE 1 TO L-PASS
             END-IF
         WHEN OTHER
             IF L-IN-TAG-NL = 1 OR L-FLUID = 1
                 MOVE 1 TO L-PASS
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM F351-HEIGHTMAP-PASSES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-HEIGHTMAP-UPDATE.
*> Section 4.2 update rule: USING first (the stored first free y), y (the changed block), passes (0 or 1: the new state passes the test), rescan (the first free
*> y a scan down from y - 1 finds: the y + 1 of the first passing block, or min y), first out. (1) y <= first - 2: unchanged. (2) passes: y >= first
*> raises it to y + 1. (3) fails and first - 1 = y: rescan. (4) else unchanged.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FIRST                BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-PASSES               BINARY-LONG.
 01 L-RESCAN               BINARY-LONG.
 01 L-NEW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-FIRST L-Y L-PASSES L-RESCAN L-NEW.
     MOVE L-FIRST TO L-NEW
     IF L-Y > L-FIRST - 2
         IF L-PASSES = 1
             IF L-Y >= L-FIRST
                 COMPUTE L-NEW = L-Y + 1
             END-IF
         ELSE
             IF L-FIRST - 1 = L-Y
                 MOVE L-RESCAN TO L-NEW
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM F351-HEIGHTMAP-UPDATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-STEP-COUNT.
*> Section 6 item 3: USING the number of step lists of the generation settings, steps out: the loop runs to max(11, size).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 01 L-STEPS                BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE L-STEPS.
     MOVE 11 TO L-STEPS
     IF L-SIZE > 11
         MOVE L-SIZE TO L-STEPS
     END-IF
     GOBACK.
 END PROGRAM F351-STEP-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-SORT-INDICES.
*> Section 6 item 3: USING count (in and out), indices (BINARY-LONG x 256, in and out): the set of feature indices of a step, ascending and without repeats.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 01 L-INDICES.
    05 L-INDEX             BINARY-LONG OCCURS 256 TIMES.
 PROCEDURE DIVISION USING L-COUNT L-INDICES.
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > L-COUNT
         MOVE L-INDEX(WS-I) TO WS-T
         MOVE WS-I TO WS-J
         PERFORM UNTIL WS-J = 1 OR L-INDEX(WS-J - 1) <= WS-T
             MOVE L-INDEX(WS-J - 1) TO L-INDEX(WS-J)
             SUBTRACT 1 FROM WS-J
         END-PERFORM
         MOVE WS-T TO L-INDEX(WS-J)
     END-PERFORM
     MOVE 0 TO WS-OUT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         IF WS-OUT = 0 OR L-INDEX(WS-I) NOT = L-INDEX(WS-OUT)
             ADD 1 TO WS-OUT
             MOVE L-INDEX(WS-I) TO L-INDEX(WS-OUT)
         END-IF
     END-PERFORM
     MOVE WS-OUT TO L-COUNT
     GOBACK.
 END PROGRAM F351-SORT-INDICES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F351-BOUND-OK.
*> Section 10: USING user (1 count [0, 4096], 2 count_on_every_layer [0, 256], 3 offset [-16, 16], 4 cuboid [1, 16]), the provider's minimum and maximum
*> (BINARY-LONG), ok out: a provider whose range is outside the bounds fails to decode.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIMITS.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 4096.
    05 FILLER BINARY-LONG VALUE 0.
    05 FILLER BINARY-LONG VALUE 256.
    05 FILLER BINARY-LONG VALUE -16.
    05 FILLER BINARY-LONG VALUE 16.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-LONG VALUE 16.
 01 WS-TABLE REDEFINES WS-LIMITS.
    05 WS-LIMIT OCCURS 4 TIMES.
       10 WS-LOW BINARY-LONG.
       10 WS-HIGH BINARY-LONG.
 LINKAGE SECTION.
 01 L-USER                 BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-USER L-MIN L-MAX L-OK.
     MOVE 0 TO L-OK
     IF L-MIN >= WS-LOW(L-USER) AND L-MAX <= WS-HIGH(L-USER)
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM F351-BOUND-OK.
