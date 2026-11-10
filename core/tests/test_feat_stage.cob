*> Test of the feature stage (core/src/feat-stage.cob GEN-STAGE-FEATURES; docs/protocol/35-worldgen-features-1 sections 5.1 and 6): the biomes of core/tests/fixtures/feat are
*> loaded, a stone chunk of plains (then of desert) cells gets decoration step 9, and the result is compared with the placements written out by hand from the seeds
*> decorationSeed + index + 10000 * step; steps without a feature list change nothing; the biome modifier keeps a feature to the biomes that list it; the feature index is
*> the position in the step's list over the loaded biomes (desert first: patch_dead 0, then patch_flowers 1, rare_patch 2, bad_predicate 3).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-STAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY CARVER.
 COPY GENSTAGE.
 COPY FEATLEVEL.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/feat".
 01 WS-STATUS              BINARY-LONG.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 01 WS-PTR1                USAGE POINTER.
 01 WS-PTR2                USAGE POINTER.
 01 WS-A                   PIC X(196608) BASED.
 01 WS-B                   PIC X(196608) BASED.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE -64.
 01 WS-HEIGHT              BINARY-LONG VALUE 384.
 01 WS-SEA                 BINARY-LONG VALUE 63.
 01 WS-BX                  BINARY-LONG VALUE 16.
 01 WS-BZ                  BINARY-LONG VALUE 32.
 01 WS-DECOR               BINARY-DOUBLE UNSIGNED.
 01 WS-FSEED               BINARY-DOUBLE UNSIGNED.
 01 WS-WORLD               BINARY-DOUBLE UNSIGNED VALUE 12345.
 01 WS-INDEX               BINARY-LONG.
 01 WS-STEP                BINARY-LONG VALUE 9.
 01 WS-B16                 BINARY-LONG VALUE 16.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-FL                  FLOAT-LONG.
 01 WS-COUNT               BINARY-LONG.
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
     MOVE 3 TO CBI-COUNT
     MOVE "minecraft:plains" TO CBI-KEY(1)
     MOVE "minecraft:desert" TO CBI-KEY(2)
     MOVE "minecraft:ocean" TO CBI-KEY(3)
     CALL "WORLDGEN-FREE"
     CALL "BIOMES-LOAD" USING WS-DIR WS-STATUS
     MOVE "acceptance feature stage: the fixture biomes with feature lists load" TO TL-CASE
     MOVE WS-STATUS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "FD-SET-DIR" USING WS-DIR
     MOVE 1 TO CV-READY
     MOVE 12345 TO CV-SEED
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR1
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR2
     INITIALIZE WS-JOB
     SET T-ADDR TO WS-PTR1
     MOVE WS-CX TO T-CX
     MOVE WS-CZ TO T-CZ

*>   plains: step 9 lists patch_flowers (index 1), rare_patch (index 2), bad_predicate (index 3, unsupported)
     PERFORM NEW-WORLD
     CALL "FL-OPEN" USING WS-PTR2 WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     CALL "ORE-DECOR-SEED" USING WS-WORLD WS-BX WS-BZ XR-STATE WS-DECOR
     MOVE 1 TO WS-INDEX
     CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-INDEX WS-STEP WS-FSEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-FSEED
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
     MOVE 2 TO WS-INDEX
     CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-INDEX WS-STEP WS-FSEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-FSEED
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
     CALL "FL-CLOSE"
     MOVE 9 TO T-SUB
     CALL "GEN-STAGE-FEATURES" USING WS-JOB
     MOVE "acceptance feature stage: step 9 of a plains chunk places patch_flowers and rare_patch with the seeds of 5.1" TO TL-CASE
     PERFORM COMPARE
     MOVE "acceptance feature stage: the stage counts its entries" TO TL-CASE
     MOVE GS-FEATURE TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM NEW-WORLD
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 10
         IF WS-K NOT = 9
             MOVE WS-K TO T-SUB
             CALL "GEN-STAGE-FEATURES" USING WS-JOB
         END-IF
     END-PERFORM
     MOVE "acceptance feature stage: the steps with no feature list change nothing" TO TL-CASE
     PERFORM COMPARE
     MOVE 11 TO T-SUB
     CALL "GEN-STAGE-FEATURES" USING WS-JOB
     MOVE "acceptance feature stage: a step beyond 10 changes nothing" TO TL-CASE
     PERFORM COMPARE

*>   desert: step 9 lists patch_dead (index 0): ten flowers
     PERFORM NEW-WORLD
     SET ADDRESS OF CE-CHUNK TO WS-PTR1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         MOVE 1 TO CE-BIOME(WS-I)
     END-PERFORM
     CALL "FL-OPEN" USING WS-PTR2 WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     MOVE 0 TO WS-INDEX
     CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-INDEX WS-STEP WS-FSEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-FSEED
     PERFORM 10 TIMES
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
     MOVE 1 TO WS-INDEX
     CALL "ORE-FEATURE-SEED" USING WS-DECOR WS-INDEX WS-STEP WS-FSEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-FSEED
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
     CALL "FL-CLOSE"
     MOVE 9 TO T-SUB
     CALL "GEN-STAGE-FEATURES" USING WS-JOB
     MOVE "acceptance feature stage: step 9 of a desert chunk places patch_dead (index 0) and patch_flowers (index 1, listed by both biomes)" TO TL-CASE
     PERFORM COMPARE
*>   an ocean chunk: its biome lists nothing, so no feature of the step is wanted
     PERFORM NEW-WORLD
     SET ADDRESS OF CE-CHUNK TO WS-PTR1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         MOVE 2 TO CE-BIOME(WS-I)
     END-PERFORM
     MOVE 9 TO T-SUB
     CALL "GEN-STAGE-FEATURES" USING WS-JOB
     MOVE "acceptance feature stage: a chunk of a biome with no feature list places nothing" TO TL-CASE
     PERFORM COMPARE
     MOVE 0 TO CV-READY
     PERFORM NEW-WORLD
     CALL "GEN-STAGE-FEATURES" USING WS-JOB
     MOVE "acceptance feature stage: without the carver and ore data (CV-READY 0) the stage places nothing" TO TL-CASE
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
             IF WS-Y <= 62
                 MOVE 1 TO CE-STATE(WS-K)
             END-IF
         END-PERFORM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1536
         MOVE 0 TO CE-BIOME(WS-I)
     END-PERFORM
     SET ADDRESS OF WS-A TO WS-PTR1
     SET ADDRESS OF WS-B TO WS-PTR2
     MOVE WS-A TO WS-B.

 SURV-PUT.
     COMPUTE WS-YB = WS-Y - 1
     CALL "FL-GET-STATE" USING WS-X WS-YB WS-Z WS-T
     CALL "FL-CLASS" USING WS-T WS-CLASS
     IF WS-CLASS NOT = 1 AND WS-YB >= -64
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-STATE WS-FLAGS WS-OK
     END-IF.

 COMPARE.
     SET ADDRESS OF WS-A TO WS-PTR1
     SET ADDRESS OF WS-B TO WS-PTR2
     MOVE 0 TO TL-OBSERVED-N
     IF WS-A = WS-B
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
