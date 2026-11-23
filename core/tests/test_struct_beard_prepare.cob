*> Acceptance test of the preparation of the beardifier of a chunk (core/src/struct-beard.cob STRUCT-BEARD-PREPARE; docs/protocol/36-structures-1-model-placement-starts.md sections 5.2, 7.4, 9.2 and 9.3):
*> with the mineshaft of the fixture (core/tests/fixtures/struct-ms, seed 12345) given terrain adaptation beard_box and gated on, preparing chunk (13, 7) makes the starts of the chunks within 8 of it, their references
*> and the beardifier: it is active with a record per close piece, the beardifier is nonzero just above the first piece and is 0 far from every piece, preparing the same chunk again does nothing (the
*> prepared chunk, seed and data epoch are remembered), STRUCT-BASE-HEIGHT leaves the beardifier as it found it (off for its walk, back on after, SBD-GEN changed each way), a chunk 40 chunks from any
*> start has an empty beardifier, and with no structure gated on the beardifier is empty (the standard world's terrain is untouched).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-BEARD-PREPARE.
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
 COPY STRUCTBEARD.
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
 01 WS-MS-ROW2             BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-GEN                 BINARY-LONG.
 01 WS-H1                  BINARY-LONG.
 01 WS-H2                  BINARY-LONG.
 01 WS-KIND2               BINARY-LONG.
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

     MOVE 0 TO WS-MS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:mineshaft"
             MOVE WS-I TO WS-MS-ROW
         END-IF
     END-PERFORM
     MOVE 3 TO SDT-ADAPT(WS-MS-ROW)
     MOVE "minecraft:mineshaft" TO WS-GKEY
     CALL "STRUCT-GATE-ON" USING WS-GKEY
     CALL "STRUCT-STORE-RESET"
     MOVE 13 TO WS-CX
     MOVE 7 TO WS-CZ
     CALL "STRUCT-BEARD-PREPARE" USING WS-CX WS-CZ
     MOVE "acceptance US12 36-1§9.2 preparing chunk (13, 7): the beardifier is active with at least one rigid record (the pieces of the start of this chunk are close to it)" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SBD-ACTIVE = 1 AND SBD-READY = 1 AND SBD-RIGID-COUNT > 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§5.2 the start of chunk (13, 7) is in the store, made by the generator for the preparation (no decoration ran)" TO TL-CASE
     CALL "STRUCT-START-FIND" USING WS-MS-ROW WS-CX WS-CZ WS-ROW
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         IF SST-N(WS-ROW) > 10
             MOVE 1 TO TL-OBSERVED-N
         END-IF
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   just above the first record's box the beard of a beard_box is nonzero
     COMPUTE WS-X = SBR-X0(1)
     COMPUTE WS-Y = SBR-Y1(1) + 2
     COMPUTE WS-Z = SBR-Z0(1)
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-V
     MOVE "acceptance US12 36-1§9.3 the beardifier above the first piece (2 above its top) is not 0" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF WS-V > 0.000001 OR WS-V < -0.000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5000 TO WS-X
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-V
     MOVE "acceptance US12 36-1§13.14 the beardifier far from every piece (x 5000) is exactly 0" TO TL-CASE
     MOVE WS-V TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   once: the same chunk again does nothing
     MOVE SBD-RIGID-COUNT TO WS-GEN
     MOVE 0 TO SBD-RIGID-COUNT
     CALL "STRUCT-BEARD-PREPARE" USING WS-CX WS-CZ
     MOVE "acceptance US12 36-1§9.2 preparing the same chunk again keeps it (the record count I zeroed is still 0)" TO TL-CASE
     MOVE SBD-RIGID-COUNT TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-GEN TO SBD-RIGID-COUNT
*>   STRUCT-BASE-HEIGHT: the same height as with the beardifier off, the beardifier on after it, SBD-GEN changed by two
     MOVE SBD-GEN TO WS-GEN
     MOVE 0 TO WS-KIND2
     MOVE 215 TO WS-X
     MOVE 118 TO WS-Z
     CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND2 WS-H1
     MOVE "acceptance US12 36-1§5.4 STRUCT-BASE-HEIGHT leaves the beardifier on and counts two changes of SBD-GEN (off for the walk, on after it)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SBD-ACTIVE * 10 + SBD-GEN - WS-GEN
     MOVE 12 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO SBD-ACTIVE
     CALL "STRUCT-BASE-HEIGHT" USING WS-X WS-Z WS-KIND2 WS-H2
     MOVE 1 TO SBD-ACTIVE
     MOVE "acceptance US12 36-1§5.4 the base height is the same with the beardifier prepared and off (no structures in the column query)" TO TL-CASE
     MOVE WS-H2 TO TL-EXPECTED-N
     MOVE WS-H1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a chunk far from every start: empty, and the generation counter changed (it was active)
     MOVE SBD-GEN TO WS-GEN
     MOVE 400 TO WS-CX
     MOVE 400 TO WS-CZ
     CALL "STRUCT-BEARD-PREPARE" USING WS-CX WS-CZ
     MOVE "acceptance US12 36-1§13.14 a chunk far from every adapting start has an empty beardifier, and SBD-GEN changed once (the previous one was active)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SBD-ACTIVE * 10 + SBD-GEN - WS-GEN
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   no structure on: empty
     CALL "STRUCT-GATE-RESET"
     MOVE 13 TO WS-CX
     MOVE 7 TO WS-CZ
     CALL "STRUCT-BEARD-PREPARE" USING WS-CX WS-CZ
     MOVE "acceptance US12 36-1§9.2 with no structure gated on the beardifier is empty even at chunk (13, 7)" TO TL-CASE
     MOVE SBD-ACTIVE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
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
 END PROGRAM TEST-STRUCT-BEARD-PREPARE.
 COPY NOSPAWN.
 COPY CORETEST.
