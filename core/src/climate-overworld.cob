*> The overworld multi-noise biome parameter list (docs/protocol/10 section 7.4, OverworldBiomeBuilder): the 7594
*> parameter points of the preset minecraft:overworld, in the order of the document (off-coast biomes, the 13
*> weirdness slices of the inland biomes, then the underground biomes), built into the point table of CLIMATE.cpy.
*> Every value is the quantised one of the document. A surface entry is two points, depth 0 and depth 1.0.
*>
*> Entry point: OVB-BUILD (no parameters): empties the table (CLIMATE-POINTS-RESET) and builds the list.
*> The rules are written as in the document: OVB-RULE USING continentalness from, to (one letter each: c coast,
*> n near inland, m mid inland, f far inland, i inland (whole), u mushroom fields, d deep ocean, o ocean),
*> erosion from, to (a digit 0 to 6, or * for the full range; the step 1 entries use * with the continentalness letters u, d, o), biome (PIC X(24), without the
*> namespace); the temperature, humidity and weirdness ranges are those of OVB-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-MATRIX.
*> USING which (BINARY-LONG: 1 middle, 2 middle variant, 3 plateau, 4 plateau variant, 5 shattered, 6 oceans),
*> t, h (BINARY-LONG 0 to 4; for the oceans h is the row, 0 deep and 1 normal, and t the column), biome out
*> (PIC X(24); "-" when the matrix has none there).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MIDDLE.
    05 FILLER PIC X(24) VALUE "snowy_plains".
    05 FILLER PIC X(24) VALUE "snowy_plains".
    05 FILLER PIC X(24) VALUE "snowy_plains".
    05 FILLER PIC X(24) VALUE "snowy_taiga".
    05 FILLER PIC X(24) VALUE "taiga".
    05 FILLER PIC X(24) VALUE "plains".
    05 FILLER PIC X(24) VALUE "plains".
    05 FILLER PIC X(24) VALUE "forest".
    05 FILLER PIC X(24) VALUE "taiga".
    05 FILLER PIC X(24) VALUE "old_growth_spruce_taiga".
    05 FILLER PIC X(24) VALUE "flower_forest".
    05 FILLER PIC X(24) VALUE "plains".
    05 FILLER PIC X(24) VALUE "forest".
    05 FILLER PIC X(24) VALUE "birch_forest".
    05 FILLER PIC X(24) VALUE "dark_forest".
    05 FILLER PIC X(24) VALUE "savanna".
    05 FILLER PIC X(24) VALUE "savanna".
    05 FILLER PIC X(24) VALUE "forest".
    05 FILLER PIC X(24) VALUE "jungle".
    05 FILLER PIC X(24) VALUE "jungle".
    05 FILLER PIC X(24) VALUE "desert".
    05 FILLER PIC X(24) VALUE "desert".
    05 FILLER PIC X(24) VALUE "desert".
    05 FILLER PIC X(24) VALUE "desert".
    05 FILLER PIC X(24) VALUE "desert".
 01 WS-MIDDLE-T REDEFINES WS-MIDDLE.
    05 WS-MIDDLE-E         PIC X(24) OCCURS 25 TIMES.
 01 WS-MIDDLE-VARIANT.
    05 FILLER PIC X(24) VALUE "ice_spikes".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "snowy_taiga".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "dappled_forest".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "old_growth_pine_taiga".
    05 FILLER PIC X(24) VALUE "sunflower_plains".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "old_growth_birch_forest".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "plains".
    05 FILLER PIC X(24) VALUE "sparse_jungle".
    05 FILLER PIC X(24) VALUE "bamboo_jungle".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
 01 WS-MIDDLE-VARIANT-T REDEFINES WS-MIDDLE-VARIANT.
    05 WS-MIDDLE-VARIANT-E PIC X(24) OCCURS 25 TIMES.
 01 WS-PLATEAU.
    05 FILLER PIC X(24) VALUE "snowy_plains".
    05 FILLER PIC X(24) VALUE "snowy_plains".
    05 FILLER PIC X(24) VALUE "snowy_plains".
    05 FILLER PIC X(24) VALUE "snowy_taiga".
    05 FILLER PIC X(24) VALUE "snowy_taiga".
    05 FILLER PIC X(24) VALUE "meadow".
    05 FILLER PIC X(24) VALUE "meadow".
    05 FILLER PIC X(24) VALUE "forest".
    05 FILLER PIC X(24) VALUE "taiga".
    05 FILLER PIC X(24) VALUE "old_growth_spruce_taiga".
    05 FILLER PIC X(24) VALUE "meadow".
    05 FILLER PIC X(24) VALUE "meadow".
    05 FILLER PIC X(24) VALUE "meadow".
    05 FILLER PIC X(24) VALUE "meadow".
    05 FILLER PIC X(24) VALUE "pale_garden".
    05 FILLER PIC X(24) VALUE "savanna_plateau".
    05 FILLER PIC X(24) VALUE "savanna_plateau".
    05 FILLER PIC X(24) VALUE "forest".
    05 FILLER PIC X(24) VALUE "forest".
    05 FILLER PIC X(24) VALUE "jungle".
    05 FILLER PIC X(24) VALUE "badlands".
    05 FILLER PIC X(24) VALUE "badlands".
    05 FILLER PIC X(24) VALUE "badlands".
    05 FILLER PIC X(24) VALUE "wooded_badlands".
    05 FILLER PIC X(24) VALUE "wooded_badlands".
 01 WS-PLATEAU-T REDEFINES WS-PLATEAU.
    05 WS-PLATEAU-E        PIC X(24) OCCURS 25 TIMES.
 01 WS-PLATEAU-VARIANT.
    05 FILLER PIC X(24) VALUE "ice_spikes".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "cherry_grove".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "meadow".
    05 FILLER PIC X(24) VALUE "meadow".
    05 FILLER PIC X(24) VALUE "old_growth_pine_taiga".
    05 FILLER PIC X(24) VALUE "cherry_grove".
    05 FILLER PIC X(24) VALUE "cherry_grove".
    05 FILLER PIC X(24) VALUE "forest".
    05 FILLER PIC X(24) VALUE "birch_forest".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "eroded_badlands".
    05 FILLER PIC X(24) VALUE "eroded_badlands".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
 01 WS-PLATEAU-VARIANT-T REDEFINES WS-PLATEAU-VARIANT.
    05 WS-PLATEAU-VARIANT-E PIC X(24) OCCURS 25 TIMES.
 01 WS-SHATTERED.
    05 FILLER PIC X(24) VALUE "windswept_gravelly_hills".
    05 FILLER PIC X(24) VALUE "windswept_gravelly_hills".
    05 FILLER PIC X(24) VALUE "windswept_hills".
    05 FILLER PIC X(24) VALUE "windswept_forest".
    05 FILLER PIC X(24) VALUE "windswept_forest".
    05 FILLER PIC X(24) VALUE "windswept_gravelly_hills".
    05 FILLER PIC X(24) VALUE "windswept_gravelly_hills".
    05 FILLER PIC X(24) VALUE "windswept_hills".
    05 FILLER PIC X(24) VALUE "windswept_forest".
    05 FILLER PIC X(24) VALUE "windswept_forest".
    05 FILLER PIC X(24) VALUE "windswept_hills".
    05 FILLER PIC X(24) VALUE "windswept_hills".
    05 FILLER PIC X(24) VALUE "windswept_hills".
    05 FILLER PIC X(24) VALUE "windswept_forest".
    05 FILLER PIC X(24) VALUE "windswept_forest".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
    05 FILLER PIC X(24) VALUE "-".
 01 WS-SHATTERED-T REDEFINES WS-SHATTERED.
    05 WS-SHATTERED-E      PIC X(24) OCCURS 25 TIMES.
 01 WS-OCEAN.
    05 FILLER PIC X(24) VALUE "deep_frozen_ocean".
    05 FILLER PIC X(24) VALUE "deep_cold_ocean".
    05 FILLER PIC X(24) VALUE "deep_ocean".
    05 FILLER PIC X(24) VALUE "deep_lukewarm_ocean".
    05 FILLER PIC X(24) VALUE "warm_ocean".
    05 FILLER PIC X(24) VALUE "frozen_ocean".
    05 FILLER PIC X(24) VALUE "cold_ocean".
    05 FILLER PIC X(24) VALUE "ocean".
    05 FILLER PIC X(24) VALUE "lukewarm_ocean".
    05 FILLER PIC X(24) VALUE "warm_ocean".
 01 WS-OCEAN-T REDEFINES WS-OCEAN.
    05 WS-OCEAN-E          PIC X(24) OCCURS 10 TIMES.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-WHICH                BINARY-LONG.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-WHICH L-T L-H L-BIOME.
     COMPUTE WS-INDEX = L-T * 5 + L-H + 1
     EVALUATE L-WHICH
         WHEN 1
             MOVE WS-MIDDLE-E(WS-INDEX) TO L-BIOME
         WHEN 2
             MOVE WS-MIDDLE-VARIANT-E(WS-INDEX) TO L-BIOME
         WHEN 3
             MOVE WS-PLATEAU-E(WS-INDEX) TO L-BIOME
         WHEN 4
             MOVE WS-PLATEAU-VARIANT-E(WS-INDEX) TO L-BIOME
         WHEN 5
             MOVE WS-SHATTERED-E(WS-INDEX) TO L-BIOME
         WHEN OTHER
             COMPUTE WS-INDEX = L-H * 5 + L-T + 1
             MOVE WS-OCEAN-E(WS-INDEX) TO L-BIOME
     END-EVALUATE
     GOBACK.
 END PROGRAM OVB-MATRIX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-MIDDLE.
*> pickMiddle(t, h, w): the middle biome when w.max < 0, else the variant when there is one.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MIDDLE-KIND         BINARY-LONG VALUE 1.
 01 WS-VARIANT-KIND        BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     IF L-WMAX >= 0
         CALL "OVB-MATRIX" USING WS-VARIANT-KIND L-T L-H L-BIOME
         IF L-BIOME NOT = "-"
             GOBACK
         END-IF
     END-IF
     CALL "OVB-MATRIX" USING WS-MIDDLE-KIND L-T L-H L-BIOME
     GOBACK.
 END PROGRAM OVB-MIDDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-BADLANDS.
*> pickBadlands(h, w).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-H L-WMAX L-BIOME.
     EVALUATE TRUE
         WHEN L-H < 2 AND L-WMAX < 0
             MOVE "badlands" TO L-BIOME
         WHEN L-H < 2
             MOVE "eroded_badlands" TO L-BIOME
         WHEN L-H < 3
             MOVE "badlands" TO L-BIOME
         WHEN OTHER
             MOVE "wooded_badlands" TO L-BIOME
     END-EVALUATE
     GOBACK.
 END PROGRAM OVB-BADLANDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-MID-OR-BADLANDS.
*> pickMiddleOrBadlandsIfHot(t, h, w).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     IF L-T = 4
         CALL "OVB-BADLANDS" USING L-H L-WMAX L-BIOME
     ELSE
         CALL "OVB-MIDDLE" USING L-T L-H L-WMAX L-BIOME
     END-IF
     GOBACK.
 END PROGRAM OVB-MID-OR-BADLANDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-PLATEAU.
*> pickPlateau(t, h, w): the variant when w.max >= 0 and there is one, else the plateau biome.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PLATEAU-KIND        BINARY-LONG VALUE 3.
 01 WS-VARIANT-KIND        BINARY-LONG VALUE 4.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     IF L-WMAX >= 0
         CALL "OVB-MATRIX" USING WS-VARIANT-KIND L-T L-H L-BIOME
         IF L-BIOME NOT = "-"
             GOBACK
         END-IF
     END-IF
     CALL "OVB-MATRIX" USING WS-PLATEAU-KIND L-T L-H L-BIOME
     GOBACK.
 END PROGRAM OVB-PLATEAU.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-SHATTERED.
*> pickShattered(t, h, w): the shattered biome, else pickMiddle.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG VALUE 5.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     CALL "OVB-MATRIX" USING WS-KIND L-T L-H L-BIOME
     IF L-BIOME = "-"
         CALL "OVB-MIDDLE" USING L-T L-H L-WMAX L-BIOME
     END-IF
     GOBACK.
 END PROGRAM OVB-SHATTERED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-SLOPE.
*> pickSlope(t, h, w).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     EVALUATE TRUE
         WHEN L-T >= 3
             CALL "OVB-PLATEAU" USING L-T L-H L-WMAX L-BIOME
         WHEN L-H <= 1
             MOVE "snowy_slopes" TO L-BIOME
         WHEN OTHER
             MOVE "grove" TO L-BIOME
     END-EVALUATE
     GOBACK.
 END PROGRAM OVB-SLOPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-MID-BAD-SLOPE.
*> pickMiddleOrBadlandsIfHotOrSlopeIfCold(t, h, w).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     IF L-T = 0
         CALL "OVB-SLOPE" USING L-T L-H L-WMAX L-BIOME
     ELSE
         CALL "OVB-MID-OR-BADLANDS" USING L-T L-H L-WMAX L-BIOME
     END-IF
     GOBACK.
 END PROGRAM OVB-MID-BAD-SLOPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-BEACH.
*> pickBeach(t, h).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-BIOME.
     EVALUATE L-T
         WHEN 0
             MOVE "snowy_beach" TO L-BIOME
         WHEN 4
             MOVE "desert" TO L-BIOME
         WHEN OTHER
             MOVE "beach" TO L-BIOME
     END-EVALUATE
     GOBACK.
 END PROGRAM OVB-BEACH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-WINDSWEPT.
*> windswept(t, h, w, base): windswept_savanna when t > 1, h < 4 and w.max >= 0, else the base biome (in and out).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     IF L-T > 1 AND L-H < 4 AND L-WMAX >= 0
         MOVE "windswept_savanna" TO L-BIOME
     END-IF
     GOBACK.
 END PROGRAM OVB-WINDSWEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-WINDSWEPT-MIDDLE.
*> Ws: windswept with the middle biome as base.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     CALL "OVB-MIDDLE" USING L-T L-H L-WMAX L-BIOME
     CALL "OVB-WINDSWEPT" USING L-T L-H L-WMAX L-BIOME
     GOBACK.
 END PROGRAM OVB-WINDSWEPT-MIDDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-WINDSWEPT-SHATTERED.
*> WsSh: windswept with the shattered biome as base.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     CALL "OVB-SHATTERED" USING L-T L-H L-WMAX L-BIOME
     CALL "OVB-WINDSWEPT" USING L-T L-H L-WMAX L-BIOME
     GOBACK.
 END PROGRAM OVB-WINDSWEPT-SHATTERED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-SHATTERED-COAST.
*> pickShatteredCoast(t, h, w): the middle biome when w.max >= 0 else the beach, then windswept.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     IF L-WMAX >= 0
         CALL "OVB-MIDDLE" USING L-T L-H L-WMAX L-BIOME
     ELSE
         CALL "OVB-BEACH" USING L-T L-BIOME
     END-IF
     CALL "OVB-WINDSWEPT" USING L-T L-H L-WMAX L-BIOME
     GOBACK.
 END PROGRAM OVB-SHATTERED-COAST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-PEAK.
*> pickPeak(t, h, w).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-T L-H L-WMAX L-BIOME.
     EVALUATE TRUE
         WHEN L-T <= 2 AND L-WMAX < 0
             MOVE "jagged_peaks" TO L-BIOME
         WHEN L-T <= 2
             MOVE "frozen_peaks" TO L-BIOME
         WHEN L-T = 3
             MOVE "stony_peaks" TO L-BIOME
         WHEN OTHER
             CALL "OVB-BADLANDS" USING L-H L-WMAX L-BIOME
     END-EVALUATE
     GOBACK.
 END PROGRAM OVB-PEAK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-RULE.
*> USING continentalness from, to (PIC X each), erosion from, to (PIC X each), biome (PIC X(24)): adds the two
*> parameter points of a surface entry (depth point 0.0 and point 1.0) with the temperature, humidity and weirdness
*> ranges of OVB-STATE, the offset 0 and the biome named minecraft:<biome>.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY OVB.
 01 WS-LETTERS             PIC X(8) VALUE "cnmfiudo".
 01 WS-C-LOS.
    05 FILLER BINARY-DOUBLE VALUE -1900.
    05 FILLER BINARY-DOUBLE VALUE -1100.
    05 FILLER BINARY-DOUBLE VALUE 300.
    05 FILLER BINARY-DOUBLE VALUE 3000.
    05 FILLER BINARY-DOUBLE VALUE -1100.
    05 FILLER BINARY-DOUBLE VALUE -12000.
    05 FILLER BINARY-DOUBLE VALUE -10500.
    05 FILLER BINARY-DOUBLE VALUE -4550.
 01 WS-C-LO-TABLE REDEFINES WS-C-LOS.
    05 WS-C-LO             BINARY-DOUBLE OCCURS 8 TIMES.
 01 WS-C-HIS.
    05 FILLER BINARY-DOUBLE VALUE -1100.
    05 FILLER BINARY-DOUBLE VALUE 300.
    05 FILLER BINARY-DOUBLE VALUE 3000.
    05 FILLER BINARY-DOUBLE VALUE 10000.
    05 FILLER BINARY-DOUBLE VALUE 5500.
    05 FILLER BINARY-DOUBLE VALUE -10500.
    05 FILLER BINARY-DOUBLE VALUE -4550.
    05 FILLER BINARY-DOUBLE VALUE -1900.
 01 WS-C-HI-TABLE REDEFINES WS-C-HIS.
    05 WS-C-HI             BINARY-DOUBLE OCCURS 8 TIMES.
 01 WS-E-LOS.
    05 FILLER BINARY-DOUBLE VALUE -10000.
    05 FILLER BINARY-DOUBLE VALUE -7799.
    05 FILLER BINARY-DOUBLE VALUE -3750.
    05 FILLER BINARY-DOUBLE VALUE -2225.
    05 FILLER BINARY-DOUBLE VALUE 500.
    05 FILLER BINARY-DOUBLE VALUE 4500.
    05 FILLER BINARY-DOUBLE VALUE 5500.
 01 WS-E-LO-TABLE REDEFINES WS-E-LOS.
    05 WS-E-LO             BINARY-DOUBLE OCCURS 7 TIMES.
 01 WS-E-HIS.
    05 FILLER BINARY-DOUBLE VALUE -7799.
    05 FILLER BINARY-DOUBLE VALUE -3750.
    05 FILLER BINARY-DOUBLE VALUE -2225.
    05 FILLER BINARY-DOUBLE VALUE 500.
    05 FILLER BINARY-DOUBLE VALUE 4500.
    05 FILLER BINARY-DOUBLE VALUE 5500.
    05 FILLER BINARY-DOUBLE VALUE 10000.
 01 WS-E-HI-TABLE REDEFINES WS-E-HIS.
    05 WS-E-HI             BINARY-DOUBLE OCCURS 7 TIMES.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-NAME                PIC X(40).
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-C-FROM               PIC X.
 01 L-C-TO                 PIC X.
 01 L-E-FROM               PIC X.
 01 L-E-TO                 PIC X.
 01 L-BIOME                PIC X(24).
 PROCEDURE DIVISION USING L-C-FROM L-C-TO L-E-FROM L-E-TO L-BIOME.
     MOVE OVB-T-LO TO WS-MIN(1)
     MOVE OVB-T-HI TO WS-MAX(1)
     MOVE OVB-H-LO TO WS-MIN(2)
     MOVE OVB-H-HI TO WS-MAX(2)
     MOVE OVB-W-LO TO WS-MIN(6)
     MOVE OVB-W-HI TO WS-MAX(6)
     MOVE 0 TO WS-I
     MOVE 0 TO WS-J
     INSPECT WS-LETTERS TALLYING WS-I FOR CHARACTERS BEFORE INITIAL L-C-FROM
     INSPECT WS-LETTERS TALLYING WS-J FOR CHARACTERS BEFORE INITIAL L-C-TO
     MOVE WS-C-LO(WS-I + 1) TO WS-MIN(3)
     MOVE WS-C-HI(WS-J + 1) TO WS-MAX(3)
     IF L-E-FROM = "*"
         MOVE -10000 TO WS-MIN(4)
         MOVE 10000 TO WS-MAX(4)
     ELSE
         MOVE FUNCTION NUMVAL(L-E-FROM) TO WS-DIGIT
         MOVE WS-E-LO(WS-DIGIT + 1) TO WS-MIN(4)
         MOVE FUNCTION NUMVAL(L-E-TO) TO WS-DIGIT
         MOVE WS-E-HI(WS-DIGIT + 1) TO WS-MAX(4)
     END-IF
     MOVE SPACES TO WS-NAME
     STRING "minecraft:" FUNCTION TRIM(L-BIOME) DELIMITED BY SIZE INTO WS-NAME
     MOVE 0 TO WS-MIN(5) WS-MAX(5)
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     MOVE 10000 TO WS-MIN(5) WS-MAX(5)
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     GOBACK.
 END PROGRAM OVB-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-PICK-RULE.
*> USING selector (PIC X: M middle, B middle or badlands if hot, C that or slope if cold, L plateau, S shattered,
*> O slope, K peak, E beach, W windswept with the middle base, H windswept with the shattered base, A shattered
*> coast), then the arguments of OVB-RULE (continentalness from, to, erosion from, to), temperature index, humidity
*> index (BINARY-LONG 0 to 4) and the weirdness range's upper bound: picks the biome of the selector and adds the rule.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BIOME               PIC X(24).
 LINKAGE SECTION.
 01 L-SELECTOR             PIC X.
 01 L-C-FROM               PIC X.
 01 L-C-TO                 PIC X.
 01 L-E-FROM               PIC X.
 01 L-E-TO                 PIC X.
 01 L-T                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-WMAX                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SELECTOR L-C-FROM L-C-TO L-E-FROM L-E-TO L-T L-H L-WMAX.
     EVALUATE L-SELECTOR
         WHEN "M"
             CALL "OVB-MIDDLE" USING L-T L-H L-WMAX WS-BIOME
         WHEN "B"
             CALL "OVB-MID-OR-BADLANDS" USING L-T L-H L-WMAX WS-BIOME
         WHEN "C"
             CALL "OVB-MID-BAD-SLOPE" USING L-T L-H L-WMAX WS-BIOME
         WHEN "L"
             CALL "OVB-PLATEAU" USING L-T L-H L-WMAX WS-BIOME
         WHEN "S"
             CALL "OVB-SHATTERED" USING L-T L-H L-WMAX WS-BIOME
         WHEN "O"
             CALL "OVB-SLOPE" USING L-T L-H L-WMAX WS-BIOME
         WHEN "K"
             CALL "OVB-PEAK" USING L-T L-H L-WMAX WS-BIOME
         WHEN "E"
             CALL "OVB-BEACH" USING L-T WS-BIOME
         WHEN "W"
             CALL "OVB-WINDSWEPT-MIDDLE" USING L-T L-H L-WMAX WS-BIOME
         WHEN "H"
             CALL "OVB-WINDSWEPT-SHATTERED" USING L-T L-H L-WMAX WS-BIOME
         WHEN OTHER
             CALL "OVB-SHATTERED-COAST" USING L-T L-H L-WMAX WS-BIOME
     END-EVALUATE
     CALL "OVB-RULE" USING L-C-FROM L-C-TO L-E-FROM L-E-TO WS-BIOME
     GOBACK.
 END PROGRAM OVB-PICK-RULE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-SLICE.
*> USING slice kind (BINARY-LONG: 1 peaks, 2 high, 3 mid, 4 low, 5 valleys), weirdness range lower and upper
*> bound: the entries of one weirdness slice of 10 section 7.4 step 2. The mid, low and valleys slices begin with fixed
*> entries (stony shore, swamps, rivers); then, for the temperature index t of 0 to 4 outside and the humidity index
*> h of 0 to 4 inside, the entries of the slice in the order of the document.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY OVB.
 01 WS-T-LOS.
    05 FILLER BINARY-DOUBLE VALUE -10000.
    05 FILLER BINARY-DOUBLE VALUE -4500.
    05 FILLER BINARY-DOUBLE VALUE -1500.
    05 FILLER BINARY-DOUBLE VALUE 2000.
    05 FILLER BINARY-DOUBLE VALUE 5500.
 01 WS-T-LO-TABLE REDEFINES WS-T-LOS.
    05 WS-T-LO             BINARY-DOUBLE OCCURS 5 TIMES.
 01 WS-T-HIS.
    05 FILLER BINARY-DOUBLE VALUE -4500.
    05 FILLER BINARY-DOUBLE VALUE -1500.
    05 FILLER BINARY-DOUBLE VALUE 2000.
    05 FILLER BINARY-DOUBLE VALUE 5500.
    05 FILLER BINARY-DOUBLE VALUE 10000.
 01 WS-T-HI-TABLE REDEFINES WS-T-HIS.
    05 WS-T-HI             BINARY-DOUBLE OCCURS 5 TIMES.
 01 WS-H-LOS.
    05 FILLER BINARY-DOUBLE VALUE -10000.
    05 FILLER BINARY-DOUBLE VALUE -3500.
    05 FILLER BINARY-DOUBLE VALUE -1000.
    05 FILLER BINARY-DOUBLE VALUE 1000.
    05 FILLER BINARY-DOUBLE VALUE 3000.
 01 WS-H-LO-TABLE REDEFINES WS-H-LOS.
    05 WS-H-LO             BINARY-DOUBLE OCCURS 5 TIMES.
 01 WS-H-HIS.
    05 FILLER BINARY-DOUBLE VALUE -3500.
    05 FILLER BINARY-DOUBLE VALUE -1000.
    05 FILLER BINARY-DOUBLE VALUE 1000.
    05 FILLER BINARY-DOUBLE VALUE 3000.
    05 FILLER BINARY-DOUBLE VALUE 10000.
 01 WS-H-HI-TABLE REDEFINES WS-H-HIS.
    05 WS-H-HI             BINARY-DOUBLE OCCURS 5 TIMES.
 01 WS-NAME                PIC X(24).
 01 WS-T                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-WMAX                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-W-LO                 BINARY-DOUBLE.
 01 L-W-HI                 BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-KIND L-W-LO L-W-HI.
     MOVE L-W-LO TO OVB-W-LO
     MOVE L-W-HI TO OVB-W-HI
     MOVE L-W-HI TO WS-WMAX
     MOVE -10000 TO OVB-H-LO
     MOVE 10000 TO OVB-H-HI
     IF L-KIND = 3 OR L-KIND = 4
         MOVE -10000 TO OVB-T-LO
         MOVE 10000 TO OVB-T-HI
         MOVE "stony_shore" TO WS-NAME
         CALL "OVB-RULE" USING "c" "c" "0" "2" WS-NAME
         MOVE -4500 TO OVB-T-LO
         MOVE 2000 TO OVB-T-HI
         MOVE "swamp" TO WS-NAME
         CALL "OVB-RULE" USING "n" "f" "6" "6" WS-NAME
         MOVE 2000 TO OVB-T-LO
         MOVE 10000 TO OVB-T-HI
         MOVE "mangrove_swamp" TO WS-NAME
         CALL "OVB-RULE" USING "n" "f" "6" "6" WS-NAME
     END-IF
     IF L-KIND = 5
*>       The eleven fixed entries of the valleys, in the order of the document: frozen is the first temperature
*>       range, unfrozen the four after it. The weirdness of the valleys is -0.05 to 0.05, so its upper bound is
*>       not below 0 and the entries that name stony_shore for a negative bound give the river biomes.
         MOVE -10000 TO OVB-T-LO
         MOVE -4500 TO OVB-T-HI
         MOVE "frozen_river" TO WS-NAME
         CALL "OVB-RULE" USING "c" "c" "0" "1" WS-NAME
         MOVE -4500 TO OVB-T-LO
         MOVE 10000 TO OVB-T-HI
         MOVE "river" TO WS-NAME
         CALL "OVB-RULE" USING "c" "c" "0" "1" WS-NAME
         MOVE -10000 TO OVB-T-LO
         MOVE -4500 TO OVB-T-HI
         MOVE "frozen_river" TO WS-NAME
         CALL "OVB-RULE" USING "n" "n" "0" "1" WS-NAME
         MOVE -4500 TO OVB-T-LO
         MOVE 10000 TO OVB-T-HI
         MOVE "river" TO WS-NAME
         CALL "OVB-RULE" USING "n" "n" "0" "1" WS-NAME
         MOVE -10000 TO OVB-T-LO
         MOVE -4500 TO OVB-T-HI
         MOVE "frozen_river" TO WS-NAME
         CALL "OVB-RULE" USING "c" "f" "2" "5" WS-NAME
         MOVE -4500 TO OVB-T-LO
         MOVE 10000 TO OVB-T-HI
         MOVE "river" TO WS-NAME
         CALL "OVB-RULE" USING "c" "f" "2" "5" WS-NAME
         MOVE -10000 TO OVB-T-LO
         MOVE -4500 TO OVB-T-HI
         MOVE "frozen_river" TO WS-NAME
         CALL "OVB-RULE" USING "c" "c" "6" "6" WS-NAME
         MOVE -4500 TO OVB-T-LO
         MOVE 10000 TO OVB-T-HI
         MOVE "river" TO WS-NAME
         CALL "OVB-RULE" USING "c" "c" "6" "6" WS-NAME
         MOVE -4500 TO OVB-T-LO
         MOVE 2000 TO OVB-T-HI
         MOVE "swamp" TO WS-NAME
         CALL "OVB-RULE" USING "i" "f" "6" "6" WS-NAME
         MOVE 2000 TO OVB-T-LO
         MOVE 10000 TO OVB-T-HI
         MOVE "mangrove_swamp" TO WS-NAME
         CALL "OVB-RULE" USING "i" "f" "6" "6" WS-NAME
         MOVE -10000 TO OVB-T-LO
         MOVE -4500 TO OVB-T-HI
         MOVE "frozen_river" TO WS-NAME
         CALL "OVB-RULE" USING "i" "f" "6" "6" WS-NAME
     END-IF
     PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T > 4
         MOVE WS-T-LO(WS-T + 1) TO OVB-T-LO
         MOVE WS-T-HI(WS-T + 1) TO OVB-T-HI
         PERFORM VARYING WS-H FROM 0 BY 1 UNTIL WS-H > 4
             MOVE WS-H-LO(WS-H + 1) TO OVB-H-LO
             MOVE WS-H-HI(WS-H + 1) TO OVB-H-HI
             EVALUATE L-KIND
             WHEN 1
             CALL "OVB-PICK-RULE" USING "K" "c" "f" "0" "0" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "C" "c" "n" "1" "1" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "K" "m" "f" "1" "1" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "c" "n" "2" "3" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "L" "m" "f" "2" "2" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "B" "m" "m" "3" "3" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "L" "f" "f" "3" "3" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "c" "f" "4" "4" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "H" "c" "n" "5" "5" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "S" "m" "f" "5" "5" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "c" "f" "6" "6" WS-T WS-H WS-WMAX
             WHEN 2
             CALL "OVB-PICK-RULE" USING "M" "c" "c" "0" "1" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "O" "n" "n" "0" "0" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "K" "m" "f" "0" "0" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "C" "n" "n" "1" "1" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "O" "m" "f" "1" "1" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "c" "n" "2" "3" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "L" "m" "f" "2" "2" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "B" "m" "m" "3" "3" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "L" "f" "f" "3" "3" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "c" "f" "4" "4" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "W" "c" "n" "5" "5" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "S" "m" "f" "5" "5" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "c" "f" "6" "6" WS-T WS-H WS-WMAX
             WHEN 3
             CALL "OVB-PICK-RULE" USING "O" "n" "f" "0" "0" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "C" "n" "m" "1" "1" WS-T WS-H WS-WMAX
             IF WS-T = 0
             CALL "OVB-PICK-RULE" USING "O" "f" "f" "1" "1" WS-T WS-H WS-WMAX
             ELSE
             CALL "OVB-PICK-RULE" USING "L" "f" "f" "1" "1" WS-T WS-H WS-WMAX
             END-IF
             CALL "OVB-PICK-RULE" USING "M" "n" "n" "2" "2" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "B" "m" "m" "2" "2" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "L" "f" "f" "2" "2" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "c" "n" "3" "3" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "B" "m" "f" "3" "3" WS-T WS-H WS-WMAX
             IF WS-WMAX < 0
             CALL "OVB-PICK-RULE" USING "E" "c" "c" "4" "4" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "n" "f" "4" "4" WS-T WS-H WS-WMAX
             ELSE
             CALL "OVB-PICK-RULE" USING "M" "c" "f" "4" "4" WS-T WS-H WS-WMAX
             END-IF
             CALL "OVB-PICK-RULE" USING "A" "c" "c" "5" "5" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "W" "n" "n" "5" "5" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "S" "m" "f" "5" "5" WS-T WS-H WS-WMAX
             IF WS-WMAX < 0
             CALL "OVB-PICK-RULE" USING "E" "c" "c" "6" "6" WS-T WS-H WS-WMAX
             ELSE
             CALL "OVB-PICK-RULE" USING "M" "c" "c" "6" "6" WS-T WS-H WS-WMAX
             END-IF
             IF WS-T = 0
             CALL "OVB-PICK-RULE" USING "M" "n" "f" "6" "6" WS-T WS-H WS-WMAX
             END-IF
             WHEN 4
             CALL "OVB-PICK-RULE" USING "B" "n" "n" "0" "1" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "C" "m" "f" "0" "1" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "n" "n" "2" "3" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "B" "m" "f" "2" "3" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "E" "c" "c" "3" "4" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "n" "f" "4" "4" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "A" "c" "c" "5" "5" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "W" "n" "n" "5" "5" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "M" "m" "f" "5" "5" WS-T WS-H WS-WMAX
             CALL "OVB-PICK-RULE" USING "E" "c" "c" "6" "6" WS-T WS-H WS-WMAX
             IF WS-T = 0
             CALL "OVB-PICK-RULE" USING "M" "n" "f" "6" "6" WS-T WS-H WS-WMAX
             END-IF
             WHEN OTHER
             CALL "OVB-PICK-RULE" USING "B" "m" "f" "0" "1" WS-T WS-H WS-WMAX
             END-EVALUATE
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM OVB-SLICE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OVB-BUILD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY OVB.
 01 WS-SLICES.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-DOUBLE VALUE -10000.
    05 FILLER BINARY-DOUBLE VALUE -9333.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-DOUBLE VALUE -9333.
    05 FILLER BINARY-DOUBLE VALUE -7666.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-DOUBLE VALUE -7666.
    05 FILLER BINARY-DOUBLE VALUE -5666.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-DOUBLE VALUE -5666.
    05 FILLER BINARY-DOUBLE VALUE -4000.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-DOUBLE VALUE -4000.
    05 FILLER BINARY-DOUBLE VALUE -2666.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-DOUBLE VALUE -2666.
    05 FILLER BINARY-DOUBLE VALUE -500.
    05 FILLER BINARY-LONG VALUE 5.
    05 FILLER BINARY-DOUBLE VALUE -500.
    05 FILLER BINARY-DOUBLE VALUE 500.
    05 FILLER BINARY-LONG VALUE 4.
    05 FILLER BINARY-DOUBLE VALUE 500.
    05 FILLER BINARY-DOUBLE VALUE 2666.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-DOUBLE VALUE 2666.
    05 FILLER BINARY-DOUBLE VALUE 4000.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-DOUBLE VALUE 4000.
    05 FILLER BINARY-DOUBLE VALUE 5666.
    05 FILLER BINARY-LONG VALUE 1.
    05 FILLER BINARY-DOUBLE VALUE 5666.
    05 FILLER BINARY-DOUBLE VALUE 7666.
    05 FILLER BINARY-LONG VALUE 2.
    05 FILLER BINARY-DOUBLE VALUE 7666.
    05 FILLER BINARY-DOUBLE VALUE 9333.
    05 FILLER BINARY-LONG VALUE 3.
    05 FILLER BINARY-DOUBLE VALUE 9333.
    05 FILLER BINARY-DOUBLE VALUE 10000.
 01 WS-SLICE-TABLE REDEFINES WS-SLICES.
    05 WS-SLICE OCCURS 13 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-LO            BINARY-DOUBLE.
       10 WS-HI            BINARY-DOUBLE.
 01 WS-T-LOS.
    05 FILLER BINARY-DOUBLE VALUE -10000.
    05 FILLER BINARY-DOUBLE VALUE -4500.
    05 FILLER BINARY-DOUBLE VALUE -1500.
    05 FILLER BINARY-DOUBLE VALUE 2000.
    05 FILLER BINARY-DOUBLE VALUE 5500.
 01 WS-T-LO-TABLE REDEFINES WS-T-LOS.
    05 WS-T-LO             BINARY-DOUBLE OCCURS 5 TIMES.
 01 WS-T-HIS.
    05 FILLER BINARY-DOUBLE VALUE -4500.
    05 FILLER BINARY-DOUBLE VALUE -1500.
    05 FILLER BINARY-DOUBLE VALUE 2000.
    05 FILLER BINARY-DOUBLE VALUE 5500.
    05 FILLER BINARY-DOUBLE VALUE 10000.
 01 WS-T-HI-TABLE REDEFINES WS-T-HIS.
    05 WS-T-HI             BINARY-DOUBLE OCCURS 5 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-OCEANS              BINARY-LONG VALUE 6.
 01 WS-DEEP                BINARY-LONG VALUE 0.
 01 WS-NORMAL              BINARY-LONG VALUE 1.
 01 WS-BIOME               PIC X(24).
 01 WS-NAME                PIC X(40).
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 PROCEDURE DIVISION.
     CALL "CLIMATE-POINTS-RESET"
*>   Step 1: mushroom fields and the oceans, whole humidity and weirdness.
     MOVE -10000 TO OVB-H-LO OVB-W-LO OVB-T-LO
     MOVE 10000 TO OVB-H-HI OVB-W-HI OVB-T-HI
     MOVE "mushroom_fields" TO WS-BIOME
     CALL "OVB-RULE" USING "u" "u" "*" "*" WS-BIOME
     PERFORM VARYING WS-T FROM 0 BY 1 UNTIL WS-T > 4
         MOVE WS-T-LO(WS-T + 1) TO OVB-T-LO
         MOVE WS-T-HI(WS-T + 1) TO OVB-T-HI
         CALL "OVB-MATRIX" USING WS-OCEANS WS-T WS-DEEP WS-BIOME
         CALL "OVB-RULE" USING "d" "d" "*" "*" WS-BIOME
         CALL "OVB-MATRIX" USING WS-OCEANS WS-T WS-NORMAL WS-BIOME
         CALL "OVB-RULE" USING "o" "o" "*" "*" WS-BIOME
     END-PERFORM
*>   Step 2: the 13 weirdness slices.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         CALL "OVB-SLICE" USING WS-KIND(WS-I) WS-LO(WS-I) WS-HI(WS-I)
     END-PERFORM
*>   Step 3: the underground, depth 0.2 to 0.9 (2000 to 9000), and the bottom, depth 1.1.
     MOVE -10000 TO WS-MIN(1) WS-MIN(2) WS-MIN(3) WS-MIN(4) WS-MIN(6)
     MOVE 10000 TO WS-MAX(1) WS-MAX(2) WS-MAX(3) WS-MAX(4) WS-MAX(6)
     MOVE 2000 TO WS-MIN(5)
     MOVE 9000 TO WS-MAX(5)
     MOVE 8000 TO WS-MIN(3)
     MOVE "minecraft:dripstone_caves" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     MOVE -10000 TO WS-MIN(3)
     MOVE 7000 TO WS-MIN(2)
     MOVE "minecraft:lush_caves" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     MOVE -10000 TO WS-MIN(2)
     MOVE -1900 TO WS-MIN(3)
     MOVE 5500 TO WS-MAX(3)
     MOVE 4500 TO WS-MIN(4)
     MOVE -11000 TO WS-MIN(6)
     MOVE -8500 TO WS-MAX(6)
     MOVE "minecraft:sulfur_caves" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     MOVE -10000 TO WS-MIN(3) WS-MIN(4) WS-MIN(6)
     MOVE 10000 TO WS-MAX(3) WS-MAX(4) WS-MAX(6)
     MOVE -3750 TO WS-MAX(4)
     MOVE 11000 TO WS-MIN(5) WS-MAX(5)
     MOVE "minecraft:deep_dark" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     GOBACK.
 END PROGRAM OVB-BUILD.
