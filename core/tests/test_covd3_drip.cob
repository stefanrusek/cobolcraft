*> Implementation test (lane covD3; docs/protocol/35-worldgen-features-6-underground.md section 7.4): a large dripstone in a stone cave only 3, 2 and 1 cells high (a ceiling and a
*> floor are found, the cave height is below 4) makes no column: no dripstone_block appears and the air cells of the cave stay air, over many seeds.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVD3-DRIP.
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
 01 WS-AIR-BEFORE          BINARY-LONG.
 01 WS-AIR-LOST            BINARY-LONG.
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
     MOVE "covD3 35-6 7 the large dripstone compiles (type is not unsupported)" TO WS-CASE
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF FT-TYPE(WS-FT) > 0
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM ASSERT-N
     MOVE 0 TO WS-TOTAL-BASE
     MOVE 0 TO WS-AIR-LOST
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 40
             PERFORM NEW-WORLD
             MOVE 63 TO WS-Y0
             MOVE 69 TO WS-Y1
             MOVE 16 TO WS-X0
             MOVE 31 TO WS-X1
             MOVE 32 TO WS-Z0
             MOVE 47 TO WS-Z1
             MOVE "air" TO WS-KEY
             PERFORM FILL-BOX
*>           stone up to y 65 + j leaves the air cells y 66 + j .. 69: heights 3, 2, 1
             COMPUTE WS-Y1 = 65 + WS-J
             MOVE "stone" TO WS-KEY
             PERFORM FILL-BOX
             MOVE "air" TO WS-KEY
             PERFORM WANT-BLOCK
             PERFORM COUNT-BLOCK
             MOVE WS-N TO WS-AIR-BEFORE
             MOVE WS-I TO WS-SEED
             CALL "F351-GAUSSIAN-RESET"
             CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
             MOVE 24 TO WS-OX
             MOVE 68 TO WS-OY
             MOVE 40 TO WS-OZ
             CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-OX WS-OY WS-OZ WS-RESULT
             MOVE "dripstone_block" TO WS-KEY
             PERFORM WANT-BLOCK
             PERFORM COUNT-BLOCK
             ADD WS-N TO WS-TOTAL-BASE
             MOVE "air" TO WS-KEY
             PERFORM WANT-BLOCK
             PERFORM COUNT-BLOCK
             COMPUTE WS-N = WS-AIR-BEFORE - WS-N
             IF WS-N NOT = 0
                 ADD 1 TO WS-AIR-LOST
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "covD3 35-6 7 a cave below 4 cells high gets no dripstone column" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-TOTAL-BASE TO WS-OBS
     PERFORM ASSERT-N
     MOVE "covD3 35-6 7 the air cells of a shallow cave stay air" TO WS-CASE
     MOVE 0 TO WS-EXP
     MOVE WS-AIR-LOST TO WS-OBS
     PERFORM ASSERT-N
     STOP RUN.
 COPY SPELPROC.
 COPY FWTEST.
 END PROGRAM TEST-COVD3-DRIP.
 COPY NOSPAWN.
 COPY CORETEST.
