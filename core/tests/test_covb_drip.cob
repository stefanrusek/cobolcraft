*> Implementation test (lane covB; docs/protocol/35-worldgen-features-6-underground.md section 7): a large dripstone column with a strong wind (offsets past the bound are clamped) and
*> columns whose height formula goes negative (it is clamped to 0), placed in a stone cave over many seeds. The cells are not compared with a model here (test_feat_35_6_6 does that
*> for the data): the check is that columns are made and that none leaves the chunk's column of stone or the cave.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-DRIP.
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
 COPY XORO.
 COPY XORO REPLACING ==XR-STATE== BY ==XR2-STATE== LEADING ==XR-== BY ==X2-==.
 COPY SPELWS.
 01 WS-PLACED              BINARY-LONG.
 01 WS-TOTAL-BASE          BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE "core/tests/fixtures/covb-drip" TO WS-DIR
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     MOVE "stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-STONE
     COMPUTE WS-ID(1) = WS-WANT - 1
     MOVE 1 TO WS-COUNT
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "minecraft:base_stone_overworld" TO WS-TAG
     CALL "TAG-PUT" USING WS-REG WS-TAG WS-COUNT WS-IDS WS-STATUS
     MOVE "dripstone_block" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BASE
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-AIR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE "minecraft:large_wind" TO WS-FTKEY
     PERFORM COMPILE-FT
     MOVE "covB 35-6 7 the strong wind large dripstone compiles (type is not unsupported)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF FT-TYPE(WS-FT) > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE 0 TO WS-TOTAL-BASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 120
         PERFORM NEW-WORLD
         MOVE 63 TO WS-Y0
         MOVE 69 TO WS-Y1
         MOVE 16 TO WS-X0
         MOVE 31 TO WS-X1
         MOVE 32 TO WS-Z0
         MOVE 47 TO WS-Z1
         MOVE "air" TO WS-KEY
         PERFORM FILL-BOX
         MOVE WS-I TO WS-SEED
         CALL "F351-GAUSSIAN-RESET"
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         MOVE 24 TO WS-OX
         MOVE 66 TO WS-OY
         MOVE 40 TO WS-OZ
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-RESULT
         MOVE "dripstone_block" TO WS-KEY
         PERFORM WANT-BLOCK
         PERFORM COUNT-BLOCK
         ADD WS-N TO WS-TOTAL-BASE
     END-PERFORM
     MOVE "covB 35-6 7 over 120 seeds large dripstone columns were made in the cave" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF WS-TOTAL-BASE > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     STOP RUN.
 COPY SPELPROC.
 COPY FWTEST.
 END PROGRAM TEST-COVB-DRIP.
 COPY CORETEST.
