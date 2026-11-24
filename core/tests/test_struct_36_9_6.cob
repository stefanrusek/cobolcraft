*> Acceptance test of docs/protocol/36-structures-9-villages-outposts.md section 6 (terrain matching as the villages and the outpost use it, T1464) over the generated vanilla-data
*> (CC_GENERATED_DIR, read only; skipped as a pass without it): the 66 pools below village/ and pillager_outpost/ (62 and 4, section 13 item 3); every template element of a pool named streets or
*> terminators (the roads, also the zombie ones) and the outpost's feature_plates is terrain_matching and every other template element (centres, houses, wells, decor templates, towers, features,
*> base plate, the villager and animal pools) is rigid; the four rows of the vertical-placement table are the engine's (36-3 section 12) and are proved against an independent model by
*> test_struct_jigsaw (the junction deltas and projections of the built villages) and the gravity processor of a terrain_matching element by test_struct_jigsaw_place.
*> NOT covered: the beardifier sentence of section 6 (rigid pieces by their ground level, junctions by ground height: 36-1 section 9): the terrain is not shaped around the pieces yet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-9-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTJIG.
 COPY VILCENSW.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-KEY                 PIC X(80).
 01 WS-POOL                BINARY-LONG.
 01 WS-EL                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N-VILLAGE           BINARY-LONG.
 01 WS-N-OUTPOST           BINARY-LONG.
 01 WS-N-ROAD              BINARY-LONG.
 01 WS-N-TM                BINARY-LONG.
 01 WS-N-BAD               BINARY-LONG.
 01 WS-N-MISSING           BINARY-LONG.
 01 WS-N-ELEMENTS          BINARY-LONG.
 01 WS-ROAD                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-ID                  PIC X(96).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "acceptance US12 36-9§6 Terrain matching as villages and the outpost use it: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     CALL "JIG-RESET"
     MOVE SPACES TO VC-ROOT
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data" DELIMITED BY SIZE INTO VC-ROOT
     MOVE "worldgen/template_pool" TO VC-BASE
     MOVE ".json" TO VC-EXT
     MOVE 5 TO VC-EXT-LEN
     PERFORM VC-COLLECT
     MOVE 0 TO WS-N-VILLAGE WS-N-OUTPOST WS-N-ROAD WS-N-TM WS-N-BAD WS-N-MISSING WS-N-ELEMENTS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > VC-TPL-N
         MOVE VC-TPL(WS-I) TO WS-ID
         IF WS-ID(1:8) = "village/"
             ADD 1 TO WS-N-VILLAGE
         ELSE
             ADD 1 TO WS-N-OUTPOST
         END-IF
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" FUNCTION TRIM(WS-ID) DELIMITED BY SIZE INTO WS-KEY
         CALL "JIG-POOL-FIND" USING WS-KEY WS-POOL
         IF WS-POOL < 2
             ADD 1 TO WS-N-MISSING
         ELSE
             PERFORM ONE-POOL
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-9§13 Validation item 3: 66 pools below village/ and pillager_outpost/ (62 and 4), all of them load" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-N-VILLAGE * 10000 + WS-N-OUTPOST * 100 + WS-N-MISSING
     MOVE 620400 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-9§6 Terrain matching: the template elements of the roads (streets, terminators) and the feature plates are terrain_matching, every other template element is rigid" TO TL-CASE
     MOVE WS-N-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-9§6 Terrain matching: there are road pools and terrain_matching elements in them (the census is not empty)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N-ROAD >= 10 AND WS-N-TM > 50 AND WS-N-ELEMENTS > 400
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ONE-POOL.
*>   a road pool is one whose last folder is streets or terminators, the outpost's feature_plates too
     MOVE 0 TO WS-ROAD
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-ID))
     IF WS-LEN >= 7 AND WS-ID(WS-LEN - 6:7) = "streets"
         MOVE 1 TO WS-ROAD
     END-IF
     IF WS-LEN >= 11 AND WS-ID(WS-LEN - 10:11) = "terminators"
         MOVE 1 TO WS-ROAD
     END-IF
     IF WS-ID = "pillager_outpost/feature_plates"
         MOVE 1 TO WS-ROAD
     END-IF
     IF WS-ROAD = 1
         ADD 1 TO WS-N-ROAD
     END-IF
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= JP-N(WS-POOL)
         COMPUTE WS-K = JP-FIRST(WS-POOL) + WS-J
         MOVE JN-ELEM(WS-K) TO WS-EL
*>       the elements that are templates (single, legacy single, list): features and the empty element have no projection of their own
         IF JE-KIND(WS-EL) >= 1 AND JE-KIND(WS-EL) <= 3
             ADD 1 TO WS-N-ELEMENTS
             IF JE-PROJ(WS-EL) NOT = WS-ROAD
                 ADD 1 TO WS-N-BAD
             END-IF
             IF JE-PROJ(WS-EL) = 1
                 ADD 1 TO WS-N-TM
             END-IF
         END-IF
     END-PERFORM.
 COPY VILCENSP.
 END PROGRAM TEST-STRUCT-36-9-6.
 COPY CORETEST.
