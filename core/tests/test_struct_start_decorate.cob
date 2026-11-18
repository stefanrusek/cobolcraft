*> Acceptance test of the store of starts as STRUCT-DECORATE fills it (docs/protocol/36-structures-1-model-placement-starts.md sections 5.6, 7.1, 7.3, 7.4, 7.5 and 8): decorating chunk (13, 7) of seed 12345 with
*> the mineshaft on stores its start (held by chunk (13, 7), valid, once), the references of the decorated chunk and of its neighbour name that start (7.4), getStructureWithPieceAt finds the root room's middle
*> (215, -57, 118) and a block far outside every piece finds nothing, a chunk beyond 8 chunks is not referenced, decorating again stores nothing new, and the chunk's `structures` NBT lists the start and its
*> reference. The mineshaft is the structure of the fixture (core/tests/fixtures/struct-ms), terrain adaptation none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-START-DECORATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATLEVEL.
 COPY STRUCTPIECE.
 COPY STRUCTBLK.
 COPY STRUCTDATA.
 COPY STRUCTSTART.
 COPY PROTO.
 COPY GENBE.
 COPY CARVER.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct-ms".
 01 WS-CLIMATE-DIR         PIC X(1100) VALUE "core/tests/fixtures/density".
 01 WS-STATUS              BINARY-LONG.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-PTR                 USAGE POINTER.
 01 WS-PTR2                USAGE POINTER.
 01 WS-PTR-KEEP            USAGE POINTER.
 01 WS-STONE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-GKEY                PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-NAME                PIC X(40).
 01 WS-I                   BINARY-LONG.
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE.
 01 WS-AIRS                BINARY-LONG.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-HASH2               BINARY-DOUBLE.
 01 WS-AIRS2               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-PAIRS-SEAM          BINARY-LONG.
 01 WS-MS-ROW              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-WN                  PIC X(32).
 01 WS-WL                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PIECES              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-STRUCTS.
    05 WS-STRUCT           BINARY-LONG OCCURS 64 TIMES.
 01 WS-SXS.
    05 WS-SX               BINARY-LONG OCCURS 64 TIMES.
 01 WS-SZS.
    05 WS-SZ               BINARY-LONG OCCURS 64 TIMES.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
*>   a standard world opens with the mineshaft gated on (WORLD-GEN-DATA-OPEN): this test starts from an empty gate
     CALL "STRUCT-GATE-RESET"
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     MOVE "minecraft:plains" TO WS-NAME
     PERFORM ADD-POINT
     CALL "STRUCT-POSSIBLE-BUILD"
     MOVE 0 TO CV-SEED
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR2
     MOVE SPACES TO WS-PAIRS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     CALL "MSP-BLOCKS"

     MOVE 13 TO J-CX
     MOVE 7 TO J-CZ
     MOVE 3 TO J-SUB
     MOVE "minecraft:mineshaft" TO WS-GKEY
     CALL "STRUCT-GATE-ON" USING WS-GKEY
     CALL "STRUCT-STORE-RESET"
     MOVE 0 TO WS-MS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:mineshaft"
             MOVE WS-I TO WS-MS-ROW
         END-IF
     END-PERFORM
     PERFORM RUN-CHUNK
     MOVE 13 TO WS-CX
     MOVE 7 TO WS-CZ
     CALL "STRUCT-START-FIND" USING WS-MS-ROW WS-CX WS-CZ WS-ROW
     MOVE "acceptance US12 36-1§7.1 the decorated chunk's start is in the store: held by chunk (13, 7), with pieces (valid)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         IF SST-N(WS-ROW) > 10
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SST-COUNT TO WS-COUNT
     MOVE SST-PIECE-COUNT TO WS-PIECES
     MOVE 215 TO WS-X
     MOVE -57 TO WS-Y
     MOVE 118 TO WS-Z
     CALL "STRUCT-WITH-PIECE-AT" USING WS-X WS-Y WS-Z WS-MS-ROW WS-FOUND
     MOVE "acceptance US12 36-1§13.11 getStructureWithPieceAt at the middle of the root room (215, -57, 118): this start" TO TL-CASE
     MOVE WS-ROW TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 500 TO WS-X
     CALL "STRUCT-WITH-PIECE-AT" USING WS-X WS-Y WS-Z WS-MS-ROW WS-FOUND
     MOVE "acceptance US12 36-1§13.11 getStructureWithPieceAt far from every piece (500, -57, 118): none" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 14 TO J-CX
     PERFORM RUN-CHUNK
     MOVE 215 TO WS-X
     MOVE 230 TO WS-Z
     CALL "STRUCT-ALL-AT" USING WS-X WS-Z WS-N WS-STRUCTS WS-SXS WS-SZS
     MOVE "acceptance US12 36-1§7.4 the neighbour chunk (14, 7) decorated after it references the same start (source chunk (13, 7))" TO TL-CASE
     MOVE 215 TO WS-X
     MOVE 118 TO WS-Z
     CALL "STRUCT-ALL-AT" USING WS-X WS-Z WS-N WS-STRUCTS WS-SXS WS-SZS
     COMPUTE TL-OBSERVED-N = WS-N * 10000 + WS-STRUCT(1) * 100 + WS-SX(1)
     COMPUTE TL-EXPECTED-N = 1 * 10000 + WS-MS-ROW * 100 + 13
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 22 TO J-CX
     PERFORM RUN-CHUNK
     MOVE 360 TO WS-X
     CALL "STRUCT-ALL-AT" USING WS-X WS-Z WS-N WS-STRUCTS WS-SXS WS-SZS
     MOVE "acceptance US12 36-1§7.4 chunk (22, 7) is 9 chunks from the start of chunk (13, 7): no reference to that start" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         IF WS-SX(WS-I) = 13 AND WS-SZ(WS-I) = 7
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SST-COUNT TO WS-COUNT
     MOVE SST-PIECE-COUNT TO WS-PIECES
     MOVE 13 TO J-CX
     PERFORM RUN-CHUNK
     MOVE "acceptance US12 36-1§7.1 the same start is stored once: decorating chunk (13, 7) again keeps the store's start and piece counts" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (SST-COUNT - WS-COUNT) * 100000 + (SST-PIECE-COUNT - WS-PIECES)
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the chunk NBT of (13, 7)
     MOVE 13 TO WS-CX
     MOVE 7 TO WS-CZ
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 0 TO WS-WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-WN WS-WL
     CALL "STRUCT-STARTS-WRITE" USING PB-BUFFER WS-CX WS-CZ
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "structures.starts.minecraft:mineshaft.ChunkX" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE "acceptance US12 36-1§7.3 the chunk's structures NBT lists the mineshaft start with ChunkX 13" TO TL-CASE
     MOVE "13" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "A" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "structures.References.minecraft:mineshaft" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE "acceptance US12 36-1§7.3 the chunk's References list the mineshaft with one packed position (its own start)" TO TL-CASE
     MOVE "L1" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 RUN-CHUNK.
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE LOW-VALUES TO CE-CHUNK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 135 * 256
         MOVE WS-STONE TO CE-STATE(WS-I)
     END-PERFORM
     SET J-ADDR TO WS-PTR
     CALL "STRUCT-STAGE-HOOK" USING WS-JOB
     MOVE 0 TO WS-AIRS
     MOVE 0 TO WS-HASH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 135 * 256
         IF CE-STATE(WS-I) NOT = WS-STONE
             ADD 1 TO WS-AIRS
             COMPUTE WS-HASH = FUNCTION MOD(WS-HASH * 31 + WS-I * 7 + CE-STATE(WS-I), 2147483647)
         END-IF
     END-PERFORM.
 CELL-STATE.
     COMPUTE WS-I = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
     MOVE CE-STATE(WS-I) TO WS-CELL.
 ADD-POINT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE 0 TO WS-OFFSET
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET.
 END PROGRAM TEST-STRUCT-START-DECORATE.
 COPY NOSPAWN.
 COPY CORETEST.
