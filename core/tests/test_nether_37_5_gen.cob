*> Implementation test of the Nether decoration driver (core/src/nether-37-5.cob NETHER-GEN-FEATURES; T1693 to T1696; docs/protocol/37-nether-5 sections 3 and 4.1): placed features
*> from core/tests/fixtures/nether-feat (patch_fire: air over netherrack, patch_soul_fire: air over soul_soil, with the chains of 4.1 without the biome modifier) run for the
*> biomes of the chunk only (patch_soul_fire is absent from crimson_forest), in (step, index) order with the seeds decorationSeed + 70004 and + 70005; the result is compared byte for
*> byte with the same two placed features run by hand through the placement runtime into a second chunk. Missing placed feature data is skipped.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-5-GEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY NETHER.
 COPY FEATDATA.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/nether-feat".
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-DECOR               BINARY-DOUBLE UNSIGNED.
 01 WS-FSEED               BINARY-DOUBLE UNSIGNED.
 01 WS-PTR1                USAGE POINTER.
 01 WS-PTR2                USAGE POINTER.
 01 WS-A                   PIC X(304640) BASED.
 01 WS-B                   PIC X(304640) BASED.
 01 WS-CX                  BINARY-LONG VALUE 11.
 01 WS-CZ                  BINARY-LONG VALUE 11.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-MIN                 BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 128.
 01 WS-SEA                 BINARY-LONG VALUE 32.
 01 WS-I                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-INDEX0              BINARY-LONG.
 01 WS-STEP                BINARY-LONG VALUE 7.
 01 WS-KEY                 PIC X(80).
 01 WS-PF                  BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-FIRES               BINARY-LONG.
 01 WS-SOULS               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-NEG                 BINARY-DOUBLE SIGNED VALUE -1.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     COMPUTE WS-BX = WS-CX * 16
     COMPUTE WS-BZ = WS-CZ * 16
     MOVE 10 TO CB-BLOCK-COUNT
     MOVE 10 TO CB-STATE-COUNT
     MOVE 9 TO CB-EPOCH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         COMPUTE CB-S-BLOCK(WS-I) = WS-I - 1
         COMPUTE CB-DEFAULT-STATE(WS-I) = WS-I - 1
         MOVE 0 TO CB-SOLID(WS-I)
     END-PERFORM
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE "minecraft:netherrack" TO CB-KEY(2)
     MOVE "minecraft:soul_soil" TO CB-KEY(3)
     MOVE "minecraft:fire" TO CB-KEY(4)
     MOVE "minecraft:soul_fire" TO CB-KEY(5)
     MOVE "minecraft:cave_air" TO CB-KEY(6)
     MOVE "minecraft:void_air" TO CB-KEY(7)
     MOVE "minecraft:bedrock" TO CB-KEY(8)
     MOVE "minecraft:lava" TO CB-KEY(9)
     MOVE "minecraft:water" TO CB-KEY(10)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE FUNCTION LENGTH(FUNCTION TRIM(CB-KEY(WS-I))) TO CB-KEY-LENGTH(WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         COMPUTE NH-BIOME-ID(WS-I) = WS-I - 1
     END-PERFORM
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR1
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR2
     SET ADDRESS OF WS-A TO WS-PTR1
     SET ADDRESS OF WS-B TO WS-PTR2
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"

*>   nether_wastes (cells 0): both placed features of the fixtures run
     MOVE 1 TO WS-FLOOR
     MOVE 0 TO WS-BIOME
     PERFORM NEW-CHUNK
     CALL "NETHER-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-A WS-PLACED
     MOVE "acceptance US12 37-5§3 a nether_wastes chunk selects its 18 placed features (15 + 3, 2 §2)" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE WS-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM ORACLE-BOTH
     PERFORM COUNT-FIRES
     MOVE "acceptance US12 37-5§4 4.1 patch_fire sets fire in air over netherrack (some, and no soul fire without soul soil)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-FIRES > 0 AND WS-SOULS = 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 37-5§3 the driver's chunk equals the hand run with seeds decorationSeed + 70004 and + 70005" TO TL-CASE
     PERFORM COMPARE
     MOVE "acceptance US12 37-5§4 4.1 every fire stands on netherrack and replaced air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a soul_soil floor in nether_wastes: patch_soul_fire places soul fire, patch_fire none
     MOVE 2 TO WS-FLOOR
     PERFORM NEW-CHUNK
     CALL "NETHER-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-A WS-PLACED
     PERFORM COUNT-FIRES
     MOVE "acceptance US12 37-5§4 4.1 patch_soul_fire sets soul fire over soul soil, patch_fire none there" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-SOULS > 0 AND WS-FIRES = 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM ORACLE-BOTH
     MOVE "acceptance US12 37-5§3 the soul soil chunk equals the hand run too" TO TL-CASE
     PERFORM COMPARE

*>   crimson_forest (id 2): patch_soul_fire is not in its lists: one placed feature, no soul fire although soul soil is there
     MOVE 2 TO WS-BIOME
     PERFORM NEW-CHUNK
     CALL "NETHER-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-A WS-PLACED
     PERFORM COUNT-FIRES
     MOVE "acceptance US12 37-5§2 a crimson_forest chunk selects 18 placed features (12 + 6) and sets no soul fire" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     IF WS-PLACED = 18 AND WS-SOULS = 0
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   basalt_deltas (id 4) lists both; a chunk of two biomes (cells 0 and 4) runs the union
     MOVE 4 TO WS-BIOME
     PERFORM NEW-CHUNK
     CALL "NETHER-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-A WS-PLACED
     MOVE "acceptance US12 37-5§2 a basalt_deltas chunk selects 18 placed features (3 + 15)" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE WS-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-BIOME
     PERFORM NEW-CHUNK
     CALL "NETHER-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-A WS-PLACED
     MOVE "acceptance US12 37-5§2 a warped_forest chunk selects 20 placed features (13 + 7)" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-PLACED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a negative world seed is the unsigned 64 bits: the same chunk as the seed 2^64 - 1 handed over unsigned to the hand run
     MOVE -1 TO WS-SEED
     MOVE 1 TO WS-FLOOR
     MOVE 0 TO WS-BIOME
     PERFORM NEW-CHUNK
     CALL "NETHER-GEN-FEATURES" USING WS-SEED WS-CX WS-CZ WS-A WS-PLACED
     COMPUTE WS-USEED = WS-NEG + 18446744073709551616
     PERFORM ORACLE-BOTH
     MOVE "acceptance US12 37-5§3 world seed -1 decorates like the unsigned seed 2^64 - 1" TO TL-CASE
     PERFORM COMPARE
     GOBACK.

 NEW-CHUNK.
*>   bands: even y netherrack (or WS-FLOOR's block), odd y air, y 0 and 127 bedrock; every cell of the biome WS-BIOME
     SET ADDRESS OF CE-CHUNK TO WS-PTR1
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 255
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             COMPUTE WS-K = WS-Y * 256 + WS-I
             MOVE 0 TO CE-STATE(WS-K)
             IF WS-Y <= 127 AND FUNCTION MOD(WS-Y, 2) = 0
                 MOVE WS-FLOOR TO CE-STATE(WS-K)
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 1536
         MOVE WS-BIOME TO CE-BIOME(WS-K)
     END-PERFORM
     MOVE WS-A TO WS-B.

 ORACLE-BOTH.
*>   the same two placed features by hand into the second chunk, each seeded with decorationSeed + 10000 * 7 + index (4 and 5)
     CALL "FL-OPEN" USING WS-PTR2 WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "ORE-DECOR-SEED" USING WS-USEED WS-BX WS-BZ XR-STATE WS-DECOR
     MOVE 4 TO WS-INDEX0
     PERFORM ORACLE-ONE
     MOVE 5 TO WS-INDEX0
     PERFORM ORACLE-ONE
     CALL "FL-CLOSE".

 ORACLE-ONE.
     CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-INDEX0 WS-STEP WS-FSEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-FSEED
     MOVE SPACES TO WS-KEY
     IF WS-INDEX0 = 4
         MOVE "minecraft:patch_fire" TO WS-KEY
     ELSE
         MOVE "minecraft:patch_soul_fire" TO WS-KEY
     END-IF
     CALL "FD-GET-PF" USING WS-KEY WS-PF
     MOVE WS-PF TO WS-TOP
     CALL "FR-PLACE-PF" USING XR-STATE WS-PF WS-TOP WS-BX WS-MIN WS-BZ WS-RESULT.

 COUNT-FIRES.
     MOVE 0 TO WS-FIRES WS-SOULS WS-BAD
     SET ADDRESS OF CE-CHUNK TO WS-PTR1
     PERFORM VARYING WS-K FROM 257 BY 1 UNTIL WS-K > 32768
         COMPUTE WS-I = WS-K - 256
         IF CE-STATE(WS-K) = 3
             ADD 1 TO WS-FIRES
             IF CE-STATE(WS-I) NOT = 1
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
         IF CE-STATE(WS-K) = 4
             ADD 1 TO WS-SOULS
             IF CE-STATE(WS-I) NOT = 2
                 ADD 1 TO WS-BAD
             END-IF
         END-IF
     END-PERFORM.

 COMPARE.
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-A = WS-B
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-NETHER-37-5-GEN.
