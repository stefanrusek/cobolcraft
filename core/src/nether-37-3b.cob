*> The Nether biome definitions as data (docs/protocol/37-nether-3 sections 6 and 7; T1669 to T1672): climate settings, effects, the fog colour, the ambient
*> particle, the sound ids, the music delays, the feature list shapes and the spawner lists of the five biomes, by the number of the preset (1 nether_wastes,
*> 2 soul_sand_valley, 3 crimson_forest, 4 warped_forest, 5 basalt_deltas). Pure tables, no state.
*>
*> Entry points:
*>   NETHER-BIOME-DEF USING number (1 to 5), def out (the group below, fixed point numbers: x10 for temperature, downfall and mood offset, x10000 for the
*>     additions chance, x1000000000 for the particle probability; colours as the signed ARGB ints of NetherBiomes; particle length 0 when none)
*>   NETHER-BIOME-SOUND USING number, kind (1 loop, 2 mood, 3 additions, 4 music), id out (PIC X(48)), length out: the sound-event id (no namespace)
*>   NETHER-SPAWN-COUNT USING number, category (1 monster, 2 creature), count out
*>   NETHER-SPAWN-ENTRY USING number, category, index (1 up), entity out (PIC X(20), no namespace), length out, weight, min count, max count (BINARY-LONG)
*>   NETHER-SPAWN-COST USING number, entity (PIC X(20)), charge x100 out, energy budget x100 out, found out (1 when the biome sets a cost for it)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BIOME-DEF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-DEF.
    05 D-NAME              PIC X(20).
    05 D-NAME-LENGTH       BINARY-LONG.
    05 D-TEMPERATURE-X10   BINARY-LONG.
    05 D-DOWNFALL-X10      BINARY-LONG.
    05 D-PRECIPITATION     BINARY-LONG.
    05 D-WATER-COLOR       BINARY-LONG.
    05 D-FOG-COLOR         BINARY-LONG.
    05 D-PARTICLE          PIC X(20).
    05 D-PARTICLE-LENGTH   BINARY-LONG.
    05 D-PARTICLE-PROB     BINARY-LONG.
    05 D-MOOD-DELAY        BINARY-LONG.
    05 D-MOOD-EXTENT       BINARY-LONG.
    05 D-MOOD-OFFSET-X10   BINARY-LONG.
    05 D-ADDITIONS-X10000  BINARY-LONG.
    05 D-MUSIC-MIN         BINARY-LONG.
    05 D-MUSIC-MAX         BINARY-LONG.
    05 D-STEP-LISTS        BINARY-LONG.
    05 D-FEATURES          BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-DEF.
     MOVE SPACES TO D-NAME D-PARTICLE
     MOVE 20 TO D-TEMPERATURE-X10
     MOVE 0 TO D-DOWNFALL-X10 D-PRECIPITATION D-PARTICLE-LENGTH D-PARTICLE-PROB
     MOVE 4159204 TO D-WATER-COLOR
     MOVE 6000 TO D-MOOD-DELAY
     MOVE 8 TO D-MOOD-EXTENT
     MOVE 20 TO D-MOOD-OFFSET-X10
     MOVE 111 TO D-ADDITIONS-X10000
     MOVE 12000 TO D-MUSIC-MIN
     MOVE 24000 TO D-MUSIC-MAX
     MOVE 10 TO D-STEP-LISTS
     EVALUATE L-NUMBER
         WHEN 1
             MOVE "nether_wastes" TO D-NAME
             MOVE 13 TO D-NAME-LENGTH
             MOVE -13432824 TO D-FOG-COLOR
             MOVE 18 TO D-FEATURES
         WHEN 2
             MOVE "soul_sand_valley" TO D-NAME
             MOVE 16 TO D-NAME-LENGTH
             MOVE -14989499 TO D-FOG-COLOR
             MOVE "ash" TO D-PARTICLE
             MOVE 3 TO D-PARTICLE-LENGTH
             MOVE 6250000 TO D-PARTICLE-PROB
             MOVE 17 TO D-FEATURES
         WHEN 3
             MOVE "crimson_forest" TO D-NAME
             MOVE 14 TO D-NAME-LENGTH
             MOVE -13434109 TO D-FOG-COLOR
             MOVE "crimson_spore" TO D-PARTICLE
             MOVE 13 TO D-PARTICLE-LENGTH
             MOVE 25000000 TO D-PARTICLE-PROB
             MOVE 18 TO D-FEATURES
         WHEN 4
             MOVE "warped_forest" TO D-NAME
             MOVE 13 TO D-NAME-LENGTH
             MOVE -15071974 TO D-FOG-COLOR
             MOVE "warped_spore" TO D-PARTICLE
             MOVE 12 TO D-PARTICLE-LENGTH
             MOVE 14280000 TO D-PARTICLE-PROB
             MOVE 20 TO D-FEATURES
         WHEN OTHER
             MOVE "basalt_deltas" TO D-NAME
             MOVE 13 TO D-NAME-LENGTH
             MOVE -9937040 TO D-FOG-COLOR
             MOVE "white_ash" TO D-PARTICLE
             MOVE 9 TO D-PARTICLE-LENGTH
             MOVE 118093334 TO D-PARTICLE-PROB
             MOVE 8 TO D-STEP-LISTS
             MOVE 18 TO D-FEATURES
     END-EVALUATE
     GOBACK.
 END PROGRAM NETHER-BIOME-DEF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-BIOME-SOUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DEF.
    05 WS-NAME             PIC X(20).
    05 WS-NAME-LENGTH      BINARY-LONG.
    05 FILLER              PIC X(200).
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-ID                   PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-KIND L-ID L-LENGTH.
     CALL "NETHER-BIOME-DEF" USING L-NUMBER WS-DEF
     MOVE SPACES TO L-ID
     EVALUATE L-KIND
         WHEN 1
             STRING "ambient." WS-NAME(1:WS-NAME-LENGTH) ".loop" DELIMITED BY SIZE INTO L-ID
         WHEN 2
             STRING "ambient." WS-NAME(1:WS-NAME-LENGTH) ".mood" DELIMITED BY SIZE INTO L-ID
         WHEN 3
             STRING "ambient." WS-NAME(1:WS-NAME-LENGTH) ".additions" DELIMITED BY SIZE INTO L-ID
         WHEN OTHER
             STRING "music.nether." WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO L-ID
     END-EVALUATE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-ID TRAILING)) TO L-LENGTH
     GOBACK.
 END PROGRAM NETHER-BIOME-SOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SPAWN-COUNT.
*> Rows: biome digit, category letter (M monster, C creature), entity name (20), weight (3), min count (1), max count (1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHERSP.
 01 WS-I                   BINARY-LONG.
 01 WS-CAT                 PIC X.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-CATEGORY             BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-CATEGORY L-COUNT.
     MOVE "M" TO WS-CAT
     IF L-CATEGORY = 2
         MOVE "C" TO WS-CAT
     END-IF
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         IF SP-BIOME(WS-I) = L-NUMBER AND SP-CATEGORY(WS-I) = WS-CAT
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-SPAWN-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SPAWN-ENTRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHERSP.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CAT                 PIC X.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-CATEGORY             BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 01 L-ENTITY               PIC X(20).
 01 L-LENGTH               BINARY-LONG.
 01 L-WEIGHT               BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-CATEGORY L-INDEX L-ENTITY L-LENGTH L-WEIGHT L-MIN L-MAX.
     MOVE "M" TO WS-CAT
     IF L-CATEGORY = 2
         MOVE "C" TO WS-CAT
     END-IF
     MOVE SPACES TO L-ENTITY
     MOVE 0 TO L-LENGTH L-WEIGHT L-MIN L-MAX WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         IF SP-BIOME(WS-I) = L-NUMBER AND SP-CATEGORY(WS-I) = WS-CAT
             ADD 1 TO WS-N
             IF WS-N = L-INDEX
                 MOVE SP-ENTITY(WS-I) TO L-ENTITY
                 MOVE FUNCTION LENGTH(FUNCTION TRIM(SP-ENTITY(WS-I) TRAILING)) TO L-LENGTH
                 MOVE SP-WEIGHT(WS-I) TO L-WEIGHT
                 MOVE SP-MIN(WS-I) TO L-MIN
                 MOVE SP-MAX(WS-I) TO L-MAX
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM NETHER-SPAWN-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-SPAWN-COST.
*> The spawn costs of 6.6: soul_sand_valley sets charge 0.7 and energy budget 0.15 for enderman, ghast, skeleton and strider; warped_forest sets 1.0
*> and 0.12 for enderman; every other biome sets none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-NUMBER               BINARY-LONG.
 01 L-ENTITY               PIC X(20).
 01 L-CHARGE               BINARY-LONG.
 01 L-BUDGET               BINARY-LONG.
 01 L-FOUND                BINARY-LONG.
 PROCEDURE DIVISION USING L-NUMBER L-ENTITY L-CHARGE L-BUDGET L-FOUND.
     MOVE 0 TO L-CHARGE L-BUDGET L-FOUND
     IF L-NUMBER = 2 AND (L-ENTITY = "enderman" OR L-ENTITY = "ghast" OR L-ENTITY = "skeleton" OR L-ENTITY = "strider")
         MOVE 70 TO L-CHARGE
         MOVE 15 TO L-BUDGET
         MOVE 1 TO L-FOUND
     END-IF
     IF L-NUMBER = 4 AND L-ENTITY = "enderman"
         MOVE 100 TO L-CHARGE
         MOVE 12 TO L-BUDGET
         MOVE 1 TO L-FOUND
     END-IF
     GOBACK.
 END PROGRAM NETHER-SPAWN-COST.
