*> Acceptance test (US15, FR-036, SC-008; docs/protocol/18-mob-framework.md section 6.6, with doc 44 part 2 section 4): spawner data (the natural_mob_spawns table).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-6-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY XORO.
 COPY MOBSPAWN.
 COPY STDMOBS.
 01 WS-CASE               PIC X(240).
 01 WS-E                  BINARY-DOUBLE.
 01 WS-O                  BINARY-DOUBLE.
 01 WS-SEED               BINARY-DOUBLE UNSIGNED.
 01 WS-MIRROR.
    05 WS-M-LO            BINARY-DOUBLE UNSIGNED.
    05 WS-M-HI            BINARY-DOUBLE UNSIGNED.
 01 WS-KEY               PIC X(48).
 01 WS-BIOME             BINARY-LONG.
 01 WS-DEEP              BINARY-LONG.
 01 WS-SWAMP             BINARY-LONG.
 01 WS-CAT               BINARY-LONG.
 01 WS-ENTRY             BINARY-LONG.
 01 WS-N                 BINARY-LONG.
 01 WS-I                 BINARY-LONG.
 01 WS-HITS              BINARY-LONG.
 01 WS-ROLL              BINARY-LONG.
 01 WS-TOTAL             BINARY-LONG.
 01 WS-SUM               BINARY-LONG.
 01 WS-EXPECT            BINARY-LONG.
 01 WS-L1                BINARY-DOUBLE UNSIGNED.
 01 WS-L2                BINARY-DOUBLE UNSIGNED.
 01 WS-SLIMES            BINARY-LONG.
 01 WS-MIN               BINARY-LONG.
 01 WS-MAXN              BINARY-LONG.
 01 WS-OTHER             BINARY-LONG.
 01 WS-DIM               BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     MOVE "minecraft:plains" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-BIOME
     MOVE "acceptance US15 18§6.6 Spawner data: the plains biome is found and has the default 0.1 world gen probability" TO WS-CASE
     COMPUTE WS-E = 100
     COMPUTE WS-O = SPB-PROB(WS-BIOME)
     PERFORM CHECK-N
     MOVE "minecraft:badlands" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-OTHER
     MOVE "acceptance US15 18§6.6 Spawner data: badlands overrides the world gen probability with 0.03" TO WS-CASE
     COMPUTE WS-E = 30
     COMPUTE WS-O = SPB-PROB(WS-OTHER)
     PERFORM CHECK-N
     MOVE "minecraft:ice_spikes" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-OTHER
     MOVE "acceptance US15 18§6.6 Spawner data: ice spikes has 0.07" TO WS-CASE
     COMPUTE WS-E = 70
     COMPUTE WS-O = SPB-PROB(WS-OTHER)
     PERFORM CHECK-N
     MOVE "cobolcraft:lowland" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-OTHER
     MOVE "acceptance US15 18§6.6 Spawner data: a biome the table does not know is not found (index 0)" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-OTHER
     PERFORM CHECK-N
     MOVE "minecraft:deep_dark" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-DEEP
     MOVE "minecraft:swamp" TO WS-KEY
     CALL "MS6-BIOME-FIND" USING WS-KEY WS-SWAMP
     MOVE 2 TO WS-CAT
     MOVE 3 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "XORO-SEED" USING WS-SEED WS-MIRROR
     CALL "MS6-ENTRY-PICK" USING XR-STATE WS-DEEP WS-CAT WS-ENTRY
     CALL "XORO-NEXT-LONG" USING XR-STATE WS-L1
     CALL "XORO-NEXT-LONG" USING WS-MIRROR WS-L2
     MOVE "acceptance US15 18§6.6 Spawner data: an empty list gives no entry" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-ENTRY
     PERFORM CHECK-N
     MOVE 0 TO WS-O
     IF WS-L1 = WS-L2
         MOVE 1 TO WS-O
     END-IF
     MOVE "acceptance US15 44-2§7.1 WeightedList: an empty list consumes no random number" TO WS-CASE
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO WS-HITS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "XORO-SEED" USING WS-SEED WS-MIRROR
         CALL "MS6-ENTRY-PICK" USING XR-STATE WS-BIOME WS-CAT WS-ENTRY
         MOVE 46 TO WS-TOTAL
         CALL "XORO-NEXT-INT" USING WS-MIRROR WS-TOTAL WS-ROLL
         EVALUATE TRUE
             WHEN WS-ROLL < 12
                 MOVE "sheep" TO WS-KEY
             WHEN WS-ROLL < 22
                 MOVE "pig" TO WS-KEY
             WHEN WS-ROLL < 32
                 MOVE "chicken" TO WS-KEY
             WHEN WS-ROLL < 40
                 MOVE "cow" TO WS-KEY
             WHEN WS-ROLL < 45
                 MOVE "horse" TO WS-KEY
             WHEN OTHER
                 MOVE "donkey" TO WS-KEY
         END-EVALUATE
         IF SPE-KEY(WS-ENTRY) = WS-KEY AND SPE-CAT(WS-ENTRY) = 2
             ADD 1 TO WS-HITS
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§6.6 Spawner data: the plains creature entry is the first whose cumulative weight exceeds one nextInt(46)" TO WS-CASE
     COMPUTE WS-E = 60
     COMPUTE WS-O = WS-HITS
     PERFORM CHECK-N
     MOVE 1 TO WS-CAT
     MOVE 0 TO WS-SLIMES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3000
         MOVE WS-I TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-ENTRY-PICK" USING XR-STATE WS-SWAMP WS-CAT WS-ENTRY
         IF SPE-KEY(WS-ENTRY) = "slime"
             ADD 1 TO WS-SLIMES
         END-IF
     END-PERFORM
     MOVE 0 TO WS-O
     IF WS-SLIMES > 480 AND WS-SLIMES < 660
         MOVE 1 TO WS-O
     END-IF
     MOVE "acceptance US15 44-2§7.2 duplicate entries: swamp slime (100 + 1 of 531) is picked about 570 of 3000 times" TO WS-CASE
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     MOVE 2 TO WS-CAT
     MOVE 1 TO WS-SEED
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "XORO-SEED" USING WS-SEED WS-MIRROR
     CALL "MS6-ENTRY-PICK" USING XR-STATE WS-BIOME WS-CAT WS-ENTRY
     CALL "XORO-NEXT-LONG" USING XR-STATE WS-L1
     MOVE 1 TO WS-SEED
     MOVE 1 TO WS-ENTRY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL SPE-KEY(WS-I) = "sheep" AND SPE-CAT(WS-I) = 2
         CONTINUE
     END-PERFORM
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     CALL "XORO-SEED" USING WS-SEED WS-MIRROR
     CALL "MS6-PACK-SIZE" USING XR-STATE WS-I WS-N
     CALL "XORO-NEXT-LONG" USING XR-STATE WS-L1
     CALL "XORO-NEXT-LONG" USING WS-MIRROR WS-L2
     MOVE "acceptance US15 18§6.6 Spawner data: a constant count (sheep 4) is the pack size" TO WS-CASE
     COMPUTE WS-E = 4
     COMPUTE WS-O = WS-N
     PERFORM CHECK-N
     MOVE 0 TO WS-O
     IF WS-L1 = WS-L2
         MOVE 1 TO WS-O
     END-IF
     MOVE "acceptance US15 18§6.6 Spawner data: a constant count draws no random number" TO WS-CASE
     MOVE 1 TO WS-E
     PERFORM CHECK-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL SPE-KEY(WS-I) = "horse" AND SPE-CAT(WS-I) = 2
         CONTINUE
     END-PERFORM
     MOVE 99 TO WS-MIN
     MOVE 0 TO WS-MAXN
     PERFORM VARYING WS-ROLL FROM 1 BY 1 UNTIL WS-ROLL > 100
         MOVE WS-ROLL TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED XR-STATE
         CALL "MS6-PACK-SIZE" USING XR-STATE WS-I WS-N
         MOVE WS-ROLL TO WS-SEED
         CALL "XORO-SEED" USING WS-SEED WS-MIRROR
         MOVE 5 TO WS-TOTAL
         CALL "XORO-NEXT-INT" USING WS-MIRROR WS-TOTAL WS-SUM
         ADD 2 TO WS-SUM
         IF WS-N NOT = WS-SUM
             ADD 100 TO WS-MAXN
         END-IF
         IF WS-N < WS-MIN
             MOVE WS-N TO WS-MIN
         END-IF
     END-PERFORM
     MOVE "acceptance US15 18§6.6 Spawner data: a uniform count (horse 2 to 6) is 2 + nextInt(5) in every sample" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-MAXN
     PERFORM CHECK-N
     MOVE "acceptance US15 18§6.6 Spawner data: the horse pack size never falls below its minimum 2" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = FUNCTION MIN(WS-MIN - 1, 1)
     PERFORM CHECK-N
     MOVE "minecraft:plains" TO WS-KEY
     MOVE "cobolcraft:pig" TO WS-KEY
     CALL "MS6-SPECIES" USING WS-KEY WS-N
     MOVE "acceptance US15 18§6.6 Spawner data: an entry of a species without a mob row has no standard row (0)" TO WS-CASE
     COMPUTE WS-E = 0
     COMPUTE WS-O = WS-N
     PERFORM CHECK-N
     MOVE "pig" TO WS-KEY
     CALL "MS6-SPECIES" USING WS-KEY WS-N
     MOVE "acceptance US15 18§6.6 Spawner data: pig is row 1 of the standard mob table" TO WS-CASE
     COMPUTE WS-E = 1
     COMPUTE WS-O = WS-N
     PERFORM CHECK-N

     STOP RUN.
 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-18-6-6.
