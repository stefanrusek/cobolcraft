*> TEST-GEN-FIXTURE: no parameters. A new standard world on the fixture terrain data of core/tests/fixtures/gen (seed 12345, one alive
*> player in dimension row 3 at (8.5, 8.5)) with the block and biome tables the stages resolve keys in: the setup of test_gen_cost,
*> shared by the tests of the generation worker. COPY it after the test program (it needs TESTLIB, CORESTATE, COREAPI, CBLOCKS, CLIMATE).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-GEN-FIXTURE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CLIMATE.
 COPY GENSTAGE.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/gen".
 01 WS-STATUS              BINARY-LONG.
 01 WS-READY               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "12345" TO CS-SEED-TEXT
     MOVE 12345 TO CW-SEED
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE 1 TO PL-USED(1)
     MOVE PS-ALIVE TO PL-STATE(1)
     MOVE 3 TO PL-DIM(1)
     MOVE 8.5 TO PL-X(1)
     MOVE 8.5 TO PL-Z(1)

*>   the block and biome tables the stages resolve keys in
     MOVE 4 TO CB-BLOCK-COUNT
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE 13 TO CB-KEY-LENGTH(1)
     MOVE 0 TO CB-DEFAULT-STATE(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 15 TO CB-KEY-LENGTH(2)
     MOVE 1 TO CB-DEFAULT-STATE(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE 15 TO CB-KEY-LENGTH(3)
     MOVE 86 TO CB-DEFAULT-STATE(3)
     MOVE "minecraft:lava" TO CB-KEY(4)
     MOVE 14 TO CB-KEY-LENGTH(4)
     MOVE 102 TO CB-DEFAULT-STATE(4)
     MOVE 2 TO CBI-COUNT
     MOVE "minecraft:plains" TO CBI-KEY(1)
     MOVE 16 TO CBI-KEY-LENGTH(1)
     MOVE "minecraft:desert" TO CBI-KEY(2)
     MOVE 16 TO CBI-KEY-LENGTH(2)
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE 1399 TO WS-MAX(6)
     MOVE "minecraft:plains" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     MOVE 10000 TO WS-MAX(6)
     MOVE 1400 TO WS-MIN(6)
     MOVE "minecraft:desert" TO WS-NAME
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET

     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     CALL "GEN-DATA-READY" USING WS-READY
     CALL "GEN-QUEUE-RESET"
     INITIALIZE GEN-STAGES
     GOBACK.
 END PROGRAM TEST-GEN-FIXTURE.
