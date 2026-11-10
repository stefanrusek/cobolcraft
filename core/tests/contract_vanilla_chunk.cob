*> Contract test (T0441; docs/protocol/06 sections 3 to 6): the chunk data of a standard world (the generated chunk (-1, 2) of the veins
*> fixture of test_ore_veins.cob: seed 7, stone, copper ore veins, sea water, air) as the packet builder writes it equals the bytes of the
*> independent encoder core/tests/fixtures/veins/chunk_data.py (the three heightmaps of 37 Longs at 9 bits, 24 sections each with its
*> non-empty and fluid counts, the block states as a single value or an indirect container of at least 4 bits in the order of first
*> occurrence, one biome). The packet after its id and the two chunk coordinates up to the end of the section buffer is compared; the
*> block entities and the light follow it and are not part of the expected bytes (the light of a lit chunk is the light engine's).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONTRACT-VANILLA-CHUNK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CELLS.
 COPY GENSTEPS.
 COPY PROTO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/veins".
 01 WS-PATH                PIC X(256) VALUE "core/tests/fixtures/veins/chunk-data.hex".
 01 WS-STATUS              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 3.
 01 WS-CX                  BINARY-LONG VALUE -1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==T-==.
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-SLICE-CAPACITY      BINARY-LONG VALUE 16384.
 01 WS-WANT-LENGTH         BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE VALUE 0.
 01 WS-NAME                PIC X(40) VALUE "minecraft:plains".
 01 B-GOT                  PIC X(1073741824) BASED.
 COPY PROTO REPLACING LEADING ==PB-== BY ==WK-==.
 COPY PROTO REPLACING LEADING ==PB-== BY ==SL-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "7" TO CS-SEED-TEXT
     MOVE 7 TO CW-SEED
     MOVE CORE-SETTINGS TO CW-SETTINGS
     MOVE 7 TO CB-BLOCK-COUNT
     MOVE "minecraft:air" TO CB-KEY(1)
     MOVE 13 TO CB-KEY-LENGTH(1)
     MOVE 0 TO CB-DEFAULT-STATE(1)
     MOVE "minecraft:stone" TO CB-KEY(2)
     MOVE 15 TO CB-KEY-LENGTH(2)
     MOVE 1 TO CB-DEFAULT-STATE(2)
     MOVE "minecraft:water" TO CB-KEY(3)
     MOVE 15 TO CB-KEY-LENGTH(3)
     MOVE 86 TO CB-DEFAULT-STATE(3)
     MOVE 86 TO CB-FIRST-STATE(3)
     MOVE 16 TO CB-STATES(3)
     MOVE "minecraft:lava" TO CB-KEY(4)
     MOVE 14 TO CB-KEY-LENGTH(4)
     MOVE 102 TO CB-DEFAULT-STATE(4)
     MOVE 102 TO CB-FIRST-STATE(4)
     MOVE 16 TO CB-STATES(4)
     MOVE "minecraft:copper_ore" TO CB-KEY(5)
     MOVE 20 TO CB-KEY-LENGTH(5)
     MOVE 50 TO CB-DEFAULT-STATE(5)
     MOVE "minecraft:raw_copper_block" TO CB-KEY(6)
     MOVE 26 TO CB-KEY-LENGTH(6)
     MOVE 51 TO CB-DEFAULT-STATE(6)
     MOVE "minecraft:granite" TO CB-KEY(7)
     MOVE 17 TO CB-KEY-LENGTH(7)
     MOVE 52 TO CB-DEFAULT-STATE(7)
     MOVE 1 TO CBI-COUNT
     MOVE "minecraft:plains" TO CBI-KEY(1)
     MOVE 16 TO CBI-KEY-LENGTH(1)
     CALL "CLIMATE-POINTS-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-DIR WS-STATUS
     CALL "MATERIAL-RULES-LOAD" USING WS-DIR WS-STATUS
     CALL "GEN-QUEUE-RESET"
*>   the chunk of the terrain pipeline up to the carvers (the feature stage places the ores the table's blocks have, which the
*>   independent encoding does not model: test_ore_veins and acc_f2us11_world cover the stages), put in the world's chunk cache
     CALL "GEN-JOB-START" USING WS-JOB WS-DIM WS-CX WS-CZ
     PERFORM UNTIL T-ACTIVE NOT = 1 OR T-STAGE >= GJ-STAGE-CARVERS
         CALL "GEN-JOB-STEP" USING WS-JOB
     END-PERFORM
     CALL "WORLD-CHUNK" USING WS-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     CALL "GEN-JOB-INSTALL" USING WS-JOB CE-CHUNK WS-MARKER
     CALL "GEN-JOB-FREE" USING WS-JOB
     CALL "PB-INIT" USING WK-BUFFER WS-CAPACITY
     CALL "CHUNK-PACKET-BUILD" USING WS-DIM WS-CX WS-CZ WK-BUFFER
     MOVE "contract vanilla chunk the packet builds without error" TO TL-CASE
     MOVE WK-ERROR TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the chunk data: after the packet id (one byte) and the two Ints
     CALL "PB-INIT" USING SL-BUFFER WS-SLICE-CAPACITY
     CALL "PB-INIT" USING PB-BUFFER WS-SLICE-CAPACITY
     CALL "TEST-LOAD-HEX" USING WS-PATH PB-BUFFER
     MOVE PB-LENGTH TO WS-WANT-LENGTH
     SET ADDRESS OF B-GOT TO WK-ADDR
     CALL "PB-APPEND-BYTES" USING SL-BUFFER B-GOT(10:WS-WANT-LENGTH) WS-WANT-LENGTH
     MOVE "contract vanilla chunk the heightmaps and the 24 sections equal the independent encoding of 06" TO TL-CASE
     CALL "TEST-SAME-AS-FIXTURE" USING SL-BUFFER WS-PATH TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
     CALL "PB-FREE" USING SL-BUFFER
     CALL "PB-FREE" USING WK-BUFFER
     STOP RUN.
 END PROGRAM CONTRACT-VANILLA-CHUNK.
 COPY CORETEST.
