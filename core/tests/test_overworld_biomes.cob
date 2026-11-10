*> Implementation test of the overworld biome parameter list (core/src/climate-overworld.cob; T0413, T0414;
*> docs/protocol/10 section 7.4 and its validation checklist item 7): OVB-BUILD makes 7594 parameter points,
*> 3795 surface points of depth 0, 3795 of depth 1.0 (the two points of every surface entry), 3 underground points
*> (depth 0.2 to 0.9) and the bottom point (depth 1.1); the number of points of each of the 56 biomes equals the
*> document's table; the first points are the mushroom fields and the oceans of step 1 in the document's order;
*> the lookup of a target at depth 1.1 with low erosion is deep_dark and of a target in the underground depth
*> with high humidity is lush_caves.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-OVERWORLD-BIOMES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CLIMATE.
 01 WS-EXPECTED.
    05 FILLER PIC X(40) VALUE "minecraft:badlands".
    05 FILLER BINARY-LONG VALUE 282.
    05 FILLER PIC X(40) VALUE "minecraft:bamboo_jungle".
    05 FILLER BINARY-LONG VALUE 104.
    05 FILLER PIC X(40) VALUE "minecraft:beach".
    05 FILLER BINARY-LONG VALUE 330.
    05 FILLER PIC X(40) VALUE "minecraft:birch_forest".
    05 FILLER BINARY-LONG VALUE 100.
    05 FILLER PIC X(40) VALUE "minecraft:cherry_grove".
    05 FILLER BINARY-LONG VALUE 60.
    05 FILLER PIC X(40) VALUE "minecraft:cold_ocean".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(40) VALUE "minecraft:dappled_forest".
    05 FILLER BINARY-LONG VALUE 92.
    05 FILLER PIC X(40) VALUE "minecraft:dark_forest".
    05 FILLER BINARY-LONG VALUE 172.
    05 FILLER PIC X(40) VALUE "minecraft:deep_cold_ocean".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(40) VALUE "minecraft:deep_dark".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER PIC X(40) VALUE "minecraft:deep_frozen_ocean".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(40) VALUE "minecraft:deep_lukewarm_ocean".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(40) VALUE "minecraft:deep_ocean".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(40) VALUE "minecraft:desert".
    05 FILLER BINARY-LONG VALUE 708.
    05 FILLER PIC X(40) VALUE "minecraft:dripstone_caves".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER PIC X(40) VALUE "minecraft:eroded_badlands".
    05 FILLER BINARY-LONG VALUE 144.
    05 FILLER PIC X(40) VALUE "minecraft:flower_forest".
    05 FILLER BINARY-LONG VALUE 80.
    05 FILLER PIC X(40) VALUE "minecraft:forest".
    05 FILLER BINARY-LONG VALUE 588.
    05 FILLER PIC X(40) VALUE "minecraft:frozen_ocean".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(40) VALUE "minecraft:frozen_peaks".
    05 FILLER BINARY-LONG VALUE 120.
    05 FILLER PIC X(40) VALUE "minecraft:frozen_river".
    05 FILLER BINARY-LONG VALUE 10.
    05 FILLER PIC X(40) VALUE "minecraft:grove".
    05 FILLER BINARY-LONG VALUE 312.
    05 FILLER PIC X(40) VALUE "minecraft:ice_spikes".
    05 FILLER BINARY-LONG VALUE 102.
    05 FILLER PIC X(40) VALUE "minecraft:jagged_peaks".
    05 FILLER BINARY-LONG VALUE 120.
    05 FILLER PIC X(40) VALUE "minecraft:jungle".
    05 FILLER BINARY-LONG VALUE 248.
    05 FILLER PIC X(40) VALUE "minecraft:lukewarm_ocean".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(40) VALUE "minecraft:lush_caves".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER PIC X(40) VALUE "minecraft:mangrove_swamp".
    05 FILLER BINARY-LONG VALUE 14.
    05 FILLER PIC X(40) VALUE "minecraft:meadow".
    05 FILLER BINARY-LONG VALUE 180.
    05 FILLER PIC X(40) VALUE "minecraft:mushroom_fields".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(40) VALUE "minecraft:ocean".
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER PIC X(40) VALUE "minecraft:old_growth_birch_forest".
    05 FILLER BINARY-LONG VALUE 76.
    05 FILLER PIC X(40) VALUE "minecraft:old_growth_pine_taiga".
    05 FILLER BINARY-LONG VALUE 112.
    05 FILLER PIC X(40) VALUE "minecraft:old_growth_spruce_taiga".
    05 FILLER BINARY-LONG VALUE 100.
    05 FILLER PIC X(40) VALUE "minecraft:pale_garden".
    05 FILLER BINARY-LONG VALUE 40.
    05 FILLER PIC X(40) VALUE "minecraft:plains".
    05 FILLER BINARY-LONG VALUE 494.
    05 FILLER PIC X(40) VALUE "minecraft:river".
    05 FILLER BINARY-LONG VALUE 8.
    05 FILLER PIC X(40) VALUE "minecraft:savanna".
    05 FILLER BINARY-LONG VALUE 356.
    05 FILLER PIC X(40) VALUE "minecraft:savanna_plateau".
    05 FILLER BINARY-LONG VALUE 128.
    05 FILLER PIC X(40) VALUE "minecraft:snowy_beach".
    05 FILLER BINARY-LONG VALUE 110.
    05 FILLER PIC X(40) VALUE "minecraft:snowy_plains".
    05 FILLER BINARY-LONG VALUE 388.
    05 FILLER PIC X(40) VALUE "minecraft:snowy_slopes".
    05 FILLER BINARY-LONG VALUE 208.
    05 FILLER PIC X(40) VALUE "minecraft:snowy_taiga".
    05 FILLER BINARY-LONG VALUE 310.
    05 FILLER PIC X(40) VALUE "minecraft:sparse_jungle".
    05 FILLER BINARY-LONG VALUE 86.
    05 FILLER PIC X(40) VALUE "minecraft:stony_peaks".
    05 FILLER BINARY-LONG VALUE 80.
    05 FILLER PIC X(40) VALUE "minecraft:stony_shore".
    05 FILLER BINARY-LONG VALUE 12.
    05 FILLER PIC X(40) VALUE "minecraft:sulfur_caves".
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER PIC X(40) VALUE "minecraft:sunflower_plains".
    05 FILLER BINARY-LONG VALUE 76.
    05 FILLER PIC X(40) VALUE "minecraft:swamp".
    05 FILLER BINARY-LONG VALUE 14.
    05 FILLER PIC X(40) VALUE "minecraft:taiga".
    05 FILLER BINARY-LONG VALUE 352.
    05 FILLER PIC X(40) VALUE "minecraft:warm_ocean".
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER PIC X(40) VALUE "minecraft:windswept_forest".
    05 FILLER BINARY-LONG VALUE 142.
    05 FILLER PIC X(40) VALUE "minecraft:windswept_gravelly_hills".
    05 FILLER BINARY-LONG VALUE 96.
    05 FILLER PIC X(40) VALUE "minecraft:windswept_hills".
    05 FILLER BINARY-LONG VALUE 114.
    05 FILLER PIC X(40) VALUE "minecraft:windswept_savanna".
    05 FILLER BINARY-LONG VALUE 216.
    05 FILLER PIC X(40) VALUE "minecraft:wooded_badlands".
    05 FILLER BINARY-LONG VALUE 284.
 01 WS-EXPECTED-TABLE REDEFINES WS-EXPECTED.
    05 WS-E OCCURS 56 TIMES.
       10 WS-E-NAME        PIC X(40).
       10 WS-E-COUNT       BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-SURFACE-0           BINARY-LONG.
 01 WS-SURFACE-1           BINARY-LONG.
 01 WS-UNDER               BINARY-LONG.
 01 WS-BOTTOM              BINARY-LONG.
 01 WS-TARGET.
    05 WS-T                BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-FITNESS             BINARY-DOUBLE.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "OVB-BUILD"
     MOVE "N" TO TL-MODE
     MOVE "test overworld biomes the list has 7594 parameter points" TO TL-CASE
     MOVE CL-COUNT TO TL-OBSERVED-N
     MOVE 7594 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-SURFACE-0 WS-SURFACE-1 WS-UNDER WS-BOTTOM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-COUNT
         EVALUATE TRUE
             WHEN CL-MIN(WS-I, 5) = 0 AND CL-MAX(WS-I, 5) = 0
                 ADD 1 TO WS-SURFACE-0
             WHEN CL-MIN(WS-I, 5) = 10000 AND CL-MAX(WS-I, 5) = 10000
                 ADD 1 TO WS-SURFACE-1
             WHEN CL-MIN(WS-I, 5) = 2000 AND CL-MAX(WS-I, 5) = 9000
                 ADD 1 TO WS-UNDER
             WHEN CL-MIN(WS-I, 5) = 11000 AND CL-MAX(WS-I, 5) = 11000
                 ADD 1 TO WS-BOTTOM
         END-EVALUATE
     END-PERFORM
     MOVE "test overworld biomes 3795 points of depth 0, 3795 of depth 1.0, 3 underground and 1 bottom" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-SURFACE-0 * 1000000000000 + WS-SURFACE-1 * 100000000 + WS-UNDER * 10 + WS-BOTTOM
     MOVE 3795003795000000001 TO TL-EXPECTED-N
     COMPUTE TL-EXPECTED-N = 3795 * 1000000000000 + 3795 * 100000000 + 3 * 10 + 1
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 56
         MOVE 0 TO WS-N
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-COUNT
             IF CL-BIOME(WS-I) = WS-E-NAME(WS-K)
                 ADD 1 TO WS-N
             END-IF
         END-PERFORM
         IF WS-N NOT = WS-E-COUNT(WS-K)
             MOVE "N" TO TL-MODE
             MOVE SPACES TO TL-CASE
             STRING "test overworld biomes count of " FUNCTION TRIM(WS-E-NAME(WS-K)) DELIMITED BY SIZE
                 INTO TL-CASE
             MOVE WS-N TO TL-OBSERVED-N
             MOVE WS-E-COUNT(WS-K) TO TL-EXPECTED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "test overworld biomes every one of the 56 biomes has the document's number of points" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test overworld biomes the first points are mushroom fields then the deep and normal oceans by temperature"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(CL-BIOME(1)) " " FUNCTION TRIM(CL-BIOME(3)) " " FUNCTION TRIM(CL-BIOME(5)) " "
         FUNCTION TRIM(CL-BIOME(15)) " " FUNCTION TRIM(CL-BIOME(21)) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "minecraft:mushroom_fields minecraft:deep_frozen_ocean minecraft:frozen_ocean "
         & "minecraft:deep_lukewarm_ocean minecraft:warm_ocean" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test overworld biomes a target at depth 1.1 with low erosion is deep_dark" TO TL-CASE
     MOVE 0 TO WS-T(1) WS-T(2) WS-T(3) WS-T(6)
     MOVE -8000 TO WS-T(4)
     MOVE 11000 TO WS-T(5)
     CALL "CLIMATE-FIND" USING WS-TARGET WS-INDEX WS-BIOME WS-FITNESS
     MOVE WS-BIOME TO TL-OBSERVED
     MOVE "minecraft:deep_dark" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test overworld biomes an underground target with humidity 0.8 is lush_caves" TO TL-CASE
     MOVE 0 TO WS-T(1) WS-T(3) WS-T(4) WS-T(6)
     MOVE 8000 TO WS-T(2)
     MOVE 5000 TO WS-T(5)
     CALL "CLIMATE-FIND" USING WS-TARGET WS-INDEX WS-BIOME WS-FITNESS
     MOVE WS-BIOME TO TL-OBSERVED
     MOVE "minecraft:lush_caves" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-OVERWORLD-BIOMES.
