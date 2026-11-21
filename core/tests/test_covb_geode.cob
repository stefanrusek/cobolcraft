*> Implementation test (lane covB; docs/protocol/35-worldgen-features-6-underground.md section 4): a geode asking for no distribution point places nothing, and a geode whose hollow is water
*> (filling_provider water) puts waterlogged buds: the buds' neighbour cells hold the source fluid. Cells are not compared with a model (test_feat_35_6_4 does that for the data).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-GEODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY FEATINDEX.
 COPY CARVER.
 COPY NOISE.
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 COPY SPELWS.
 01 WS-BUDS.
    05 WS-WLBUD            BINARY-LONG OCCURS 24 TIMES.
 01 WS-DIRNAME             PIC X(5) OCCURS 6 TIMES.
 01 WS-BUDKEY              PIC X(24) OCCURS 4 TIMES.
 01 WS-WATERLOGGED         BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PLACED-SEEDS        BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "core/tests/fixtures/covb-geode" TO WS-DIR
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE 777 TO CV-SEED
     MOVE "bedrock" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(1) = WS-WANT - 1
     MOVE 1 TO WS-COUNT
     MOVE "minecraft:features_cannot_replace" TO WS-TAG
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "water" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(2) = WS-WANT - 1
     MOVE "lava" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(3) = WS-WANT - 1
     MOVE "ice" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(4) = WS-WANT - 1
     MOVE "packed_ice" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(5) = WS-WANT - 1
     MOVE "blue_ice" TO WS-KEY
     PERFORM WANT-BLOCK
     COMPUTE WS-ID(6) = WS-WANT - 1
     MOVE 6 TO WS-COUNT
     MOVE "minecraft:geode_invalid_blocks" TO WS-TAG
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AIR
     MOVE "down" TO WS-DIRNAME(1)
     MOVE "up" TO WS-DIRNAME(2)
     MOVE "north" TO WS-DIRNAME(3)
     MOVE "south" TO WS-DIRNAME(4)
     MOVE "west" TO WS-DIRNAME(5)
     MOVE "east" TO WS-DIRNAME(6)
     MOVE "small_amethyst_bud" TO WS-BUDKEY(1)
     MOVE "medium_amethyst_bud" TO WS-BUDKEY(2)
     MOVE "large_amethyst_bud" TO WS-BUDKEY(3)
     MOVE "amethyst_cluster" TO WS-BUDKEY(4)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
             MOVE WS-BUDKEY(WS-I) TO WS-KEY
             MOVE SPACES TO WS-PAIRS
             STRING "facing=" FUNCTION TRIM(WS-DIRNAME(WS-J)) ",waterlogged=true" DELIMITED BY SIZE INTO WS-PAIRS
             COMPUTE WS-K = (WS-I - 1) * 6 + WS-J
             CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WLBUD(WS-K)
         END-PERFORM
     END-PERFORM
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
*>   No distribution point: false at once.
     MOVE "minecraft:geode_zero" TO WS-FTKEY
     PERFORM COMPILE-FT
     PERFORM NEW-WORLD
     MOVE 63 TO WS-Y0
     MOVE 69 TO WS-Y1
     MOVE 16 TO WS-X0
     MOVE 31 TO WS-X1
     MOVE 32 TO WS-Z0
     MOVE 47 TO WS-Z1
     MOVE "stone" TO WS-KEY
     PERFORM FILL-BOX
     MOVE 5 TO WS-SEED
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     MOVE 24 TO WS-OX
     MOVE 60 TO WS-OY
     MOVE 40 TO WS-OZ
     MOVE 9 TO WS-RESULT
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-RESULT
     MOVE "covB 35-6 4 a geode with no distribution point is not placed" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-RESULT TO WS-OBS
     PERFORM ASSERT-N
*>   A geode with a water hollow: over the seeds some bud is waterlogged.
     MOVE "minecraft:geode_water" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE 0 TO WS-WATERLOGGED WS-PLACED-SEEDS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
         PERFORM NEW-WORLD
         MOVE 63 TO WS-Y0
         MOVE 69 TO WS-Y1
         MOVE 16 TO WS-X0
         MOVE 31 TO WS-X1
         MOVE 32 TO WS-Z0
         MOVE 47 TO WS-Z1
         MOVE "stone" TO WS-KEY
         PERFORM FILL-BOX
         MOVE WS-I TO WS-SEED
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-RESULT
         ADD WS-RESULT TO WS-PLACED-SEEDS
         PERFORM VARYING WS-X FROM 16 BY 1 UNTIL WS-X > 31
             PERFORM VARYING WS-Z FROM 32 BY 1 UNTIL WS-Z > 47
                 PERFORM VARYING WS-Y FROM 40 BY 1 UNTIL WS-Y > 80
                     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 24
                         IF WS-STATE = WS-WLBUD(WS-K)
                             ADD 1 TO WS-WATERLOGGED
                         END-IF
                     END-PERFORM
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "covB 35-6 4 geodes with a water hollow were placed over the seeds" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-PLACED-SEEDS > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE "covB 35-6 4 and some bud of them is waterlogged" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-WATERLOGGED > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     STOP RUN.
 COPY SPELPROC.
 COPY FWTEST.
 END PROGRAM TEST-COVB-GEODE.
 COPY NOSPAWN.
 COPY CORETEST.
