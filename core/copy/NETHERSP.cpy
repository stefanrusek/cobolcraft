*> The spawner lists of the five Nether biomes (docs/protocol/37-nether-3 section 6.6), one row each: biome, category, entity, weight, min, max.
 01 SP-ROWS.
 05 FILLER PIC X(27) VALUE "1Cstrider             06012".
 05 FILLER PIC X(27) VALUE "2Cstrider             06012".
 05 FILLER PIC X(27) VALUE "3Cstrider             06012".
 05 FILLER PIC X(27) VALUE "4Cstrider             06012".
 05 FILLER PIC X(27) VALUE "5Cstrider             06012".
 05 FILLER PIC X(27) VALUE "1Mghast               05044".
 05 FILLER PIC X(27) VALUE "1Mzombified_piglin    10044".
 05 FILLER PIC X(27) VALUE "1Mmagma_cube          00244".
 05 FILLER PIC X(27) VALUE "1Menderman            00144".
 05 FILLER PIC X(27) VALUE "1Mpiglin              01544".
 05 FILLER PIC X(27) VALUE "2Mskeleton            02055".
 05 FILLER PIC X(27) VALUE "2Mghast               05044".
 05 FILLER PIC X(27) VALUE "2Menderman            00144".
 05 FILLER PIC X(27) VALUE "3Mzombified_piglin    00124".
 05 FILLER PIC X(27) VALUE "3Mhoglin              00934".
 05 FILLER PIC X(27) VALUE "3Mpiglin              00534".
 05 FILLER PIC X(27) VALUE "4Menderman            00144".
 05 FILLER PIC X(27) VALUE "5Mghast               04011".
 05 FILLER PIC X(27) VALUE "5Mmagma_cube          10025".
 05 FILLER PIC X(27) VALUE "0X                    00000".
 01 SP-TABLE REDEFINES SP-ROWS.
    05 SP-ROW OCCURS 20 TIMES.
       10 SP-BIOME PIC 9.
       10 SP-CATEGORY PIC X.
       10 SP-ENTITY PIC X(20).
       10 SP-WEIGHT PIC 999.
       10 SP-MIN PIC 9.
       10 SP-MAX PIC 9.
