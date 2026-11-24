*> Implementation test of the five Nether biome definitions and the fog, sky and particle attributes (core/src/nether-37-3b.cob; T1669 to T1672;
*> docs/protocol/37-nether-3 sections 6.2 to 6.6 and 7.1 to 7.3, validation V9 to V13): temperature 2.0, downfall 0.0, no precipitation, water colour
*> 4159204, the fog colour ints, the ambient particles with their probabilities, the sound ids, the music and mood parameters, the number of decoration
*> lists and placed features, the spawner lists with weights and counts and the spawn costs. Expected texts are transcribed from the tables of the document.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-3-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-DEF.
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
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-ID                  PIC X(48).
 01 WS-LEN                 BINARY-LONG.
 01 WS-CAT                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ENT                 PIC X(20).
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-CHARGE              BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-D                   PIC -(9)9.
 01 WS-E                   PIC -(9)9.
 01 WS-F                   PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     PERFORM CHECK-DEFS
     PERFORM CHECK-SOUNDS
     PERFORM CHECK-SPAWNS
     GOBACK.

 CHECK-DEFS.
     MOVE 1 TO WS-N
     PERFORM SHOW-BIOME
     MOVE "acceptance US12 37-3§6 biome 1 nether_wastes: climate, fog colour, particle, mood and music, lists" TO TL-CASE
     MOVE "nether_wastes|20 0 0 4159204|-13432824|none|6000 8 20 111 12000 24000|10 18" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-N
     PERFORM SHOW-BIOME
     MOVE "acceptance US12 37-3§6 biome 2 soul_sand_valley: climate, fog colour, particle, mood and music, lists" TO TL-CASE
     MOVE "soul_sand_valley|20 0 0 4159204|-14989499|ash 6250000|6000 8 20 111 12000 24000|10 17" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-N
     PERFORM SHOW-BIOME
     MOVE "acceptance US12 37-3§6 biome 3 crimson_forest: climate, fog colour, particle, mood and music, lists" TO TL-CASE
     MOVE "crimson_forest|20 0 0 4159204|-13434109|crimson_spore 25000000|6000 8 20 111 12000 24000|10 18" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-N
     PERFORM SHOW-BIOME
     MOVE "acceptance US12 37-3§6 biome 4 warped_forest: climate, fog colour, particle, mood and music, lists" TO TL-CASE
     MOVE "warped_forest|20 0 0 4159204|-15071974|warped_spore 14280000|6000 8 20 111 12000 24000|10 20" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-N
     PERFORM SHOW-BIOME
     MOVE "acceptance US12 37-3§6 biome 5 basalt_deltas: climate, fog colour, particle, mood and music, lists" TO TL-CASE
     MOVE "basalt_deltas|20 0 0 4159204|-9937040|white_ash 118093334|6000 8 20 111 12000 24000|8 18" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SHOW-BIOME.
     CALL "NETHER-BIOME-DEF" USING WS-N WS-DEF
     MOVE D-TEMPERATURE-X10 TO WS-A
     MOVE D-DOWNFALL-X10 TO WS-B
     MOVE D-PRECIPITATION TO WS-C
     MOVE D-WATER-COLOR TO WS-D
     MOVE D-FOG-COLOR TO WS-E
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-K
     STRING D-NAME(1:D-NAME-LENGTH) "|" FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D)
         "|" FUNCTION TRIM(WS-E) "|" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
     IF D-PARTICLE-LENGTH = 0
         STRING "none" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
     ELSE
         MOVE D-PARTICLE-PROB TO WS-F
         STRING D-PARTICLE(1:D-PARTICLE-LENGTH) " " FUNCTION TRIM(WS-F) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
     END-IF
     MOVE D-MOOD-DELAY TO WS-A
     MOVE D-MOOD-EXTENT TO WS-B
     MOVE D-MOOD-OFFSET-X10 TO WS-C
     MOVE D-ADDITIONS-X10000 TO WS-D
     MOVE D-MUSIC-MIN TO WS-E
     MOVE D-MUSIC-MAX TO WS-F
     STRING "|" FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D) " " FUNCTION TRIM(WS-E) " "
         FUNCTION TRIM(WS-F) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
     MOVE D-STEP-LISTS TO WS-A
     MOVE D-FEATURES TO WS-B
     STRING "|" FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K.

 CHECK-SOUNDS.
*>   6.4: ids of the loop, the mood, the additions and the music of every biome
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 5
         CALL "NETHER-BIOME-DEF" USING WS-N WS-DEF
         MOVE SPACES TO TL-EXPECTED
         MOVE SPACES TO TL-OBSERVED
         MOVE 1 TO WS-K
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             CALL "NETHER-BIOME-SOUND" USING WS-N WS-I WS-ID WS-LEN
             STRING WS-ID(1:WS-LEN) ";" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
         END-PERFORM
         STRING "ambient." D-NAME(1:D-NAME-LENGTH) ".loop;ambient." D-NAME(1:D-NAME-LENGTH) ".mood;ambient." D-NAME(1:D-NAME-LENGTH)
             ".additions;music.nether." D-NAME(1:D-NAME-LENGTH) ";" DELIMITED BY SIZE INTO TL-EXPECTED
         MOVE WS-N TO WS-A
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 37-3§6 6.4 biome " FUNCTION TRIM(WS-A) " sound ids: loop, mood, additions, music" DELIMITED BY SIZE INTO TL-CASE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 3 TO WS-N
     MOVE 2 TO WS-I
     CALL "NETHER-BIOME-SOUND" USING WS-N WS-I WS-ID WS-LEN
     MOVE "acceptance US12 37-3§6 6.4 crimson_forest mood sound is ambient.crimson_forest.mood (length 27)" TO TL-CASE
     MOVE "ambient.crimson_forest.mood" TO TL-EXPECTED
     MOVE WS-ID(1:WS-LEN) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SPAWNS-OF.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-K
     CALL "NETHER-SPAWN-COUNT" USING WS-N WS-CAT WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         CALL "NETHER-SPAWN-ENTRY" USING WS-N WS-CAT WS-I WS-ENT WS-LEN WS-WEIGHT WS-MIN WS-MAX
         MOVE WS-WEIGHT TO WS-A
         MOVE WS-MIN TO WS-B
         MOVE WS-MAX TO WS-C
         STRING WS-ENT(1:WS-LEN) " " FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) "-" FUNCTION TRIM(WS-C) ";" DELIMITED BY SIZE
             INTO TL-OBSERVED WITH POINTER WS-K
     END-PERFORM.

 CHECK-SPAWNS.
*>   6.6: the creature and monster lists, weight and count range (a plain count n is n-n)
     MOVE 2 TO WS-CAT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 5
         PERFORM SPAWNS-OF
         MOVE WS-N TO WS-A
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 37-3§6 6.6 biome " FUNCTION TRIM(WS-A) " creature list: strider 60, uniform 1 to 2" DELIMITED BY SIZE INTO TL-CASE
         MOVE "strider 60 1-2;" TO TL-EXPECTED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE 1 TO WS-CAT
     MOVE 1 TO WS-N
     PERFORM SPAWNS-OF
     MOVE "acceptance US12 37-3§6 6.6 nether_wastes monsters" TO TL-CASE
     MOVE "ghast 50 4-4;zombified_piglin 100 4-4;magma_cube 2 4-4;enderman 1 4-4;piglin 15 4-4;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-N
     PERFORM SPAWNS-OF
     MOVE "acceptance US12 37-3§6 6.6 soul_sand_valley monsters" TO TL-CASE
     MOVE "skeleton 20 5-5;ghast 50 4-4;enderman 1 4-4;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-N
     PERFORM SPAWNS-OF
     MOVE "acceptance US12 37-3§6 6.6 crimson_forest monsters" TO TL-CASE
     MOVE "zombified_piglin 1 2-4;hoglin 9 3-4;piglin 5 3-4;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-N
     PERFORM SPAWNS-OF
     MOVE "acceptance US12 37-3§6 6.6 warped_forest monsters" TO TL-CASE
     MOVE "enderman 1 4-4;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-N
     PERFORM SPAWNS-OF
     MOVE "acceptance US12 37-3§6 6.6 basalt_deltas monsters" TO TL-CASE
     MOVE "ghast 40 1-1;magma_cube 100 2-5;" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   costs: soul_sand_valley 0.7 / 0.15 for four entities, warped_forest enderman 1.0 / 0.12, nothing elsewhere
     MOVE 2 TO WS-N
     MOVE "skeleton" TO WS-ENT
     PERFORM COST-OF
     MOVE "acceptance US12 37-3§6 6.6 soul_sand_valley skeleton cost: charge 0.7, budget 0.15" TO TL-CASE
     MOVE "1 70 15" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ghast" TO WS-ENT
     PERFORM COST-OF
     MOVE "acceptance US12 37-3§6 6.6 soul_sand_valley ghast cost: charge 0.7, budget 0.15" TO TL-CASE
     MOVE "1 70 15" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "piglin" TO WS-ENT
     PERFORM COST-OF
     MOVE "acceptance US12 37-3§6 6.6 soul_sand_valley piglin has no cost" TO TL-CASE
     MOVE "0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-N
     MOVE "enderman" TO WS-ENT
     PERFORM COST-OF
     MOVE "acceptance US12 37-3§6 6.6 warped_forest enderman cost: charge 1.0, budget 0.12" TO TL-CASE
     MOVE "1 100 12" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-N
     PERFORM COST-OF
     MOVE "acceptance US12 37-3§6 6.6 nether_wastes enderman has no cost" TO TL-CASE
     MOVE "0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 COST-OF.
     CALL "NETHER-SPAWN-COST" USING WS-N WS-ENT WS-CHARGE WS-BUDGET WS-FOUND
     MOVE WS-FOUND TO WS-A
     MOVE WS-CHARGE TO WS-B
     MOVE WS-BUDGET TO WS-C
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-OBSERVED.
 END PROGRAM TEST-NETHER-37-3-6.
