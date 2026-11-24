*> Implementation test of StructureCheck (docs/protocol/36-structures-1-model-placement-starts.md section 7.6; core/src/struct-check.cob): a chunk loadedChunks knows is answered from its map (a structure with a valid
*> start there is START_PRESENT, one absent or stored as -1 is START_NOT_PRESENT, a stored reference count other than 0 is START_NOT_PRESENT when referenced starts are skipped), onStructureLoad takes the valid starts of
*> the store with their references (an INVALID or pieceless start is not in the map) and drops the chunk's memoised featureChecks, incrementReference creates the map when missing and adds one, an unknown chunk
*> fails step 3 when the placement's frequency test says no, and otherwise answers CHUNK_LOAD_NEEDED when the structure's generator and the biome of its stub allow a start and START_NOT_PRESENT when the biome
*> does not (the mesa mineshaft in a plains fixture), memoised; the without-starts set is emptied when it reaches 131072 entries and the chunk asked for is added; the loaded table wraps at 1024 chunks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-CHECK.
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
 COPY STRUCTCHECK.
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
 01 WS-SET                 BINARY-LONG.
 01 WS-SETKEY              PIC X(80) VALUE "minecraft:mineshafts".
 01 WS-MS-MESA             BINARY-LONG.
 01 WS-ANSWER              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-SKIP                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FOUND-CX            BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
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

     MOVE "minecraft:mineshaft" TO WS-GKEY
     CALL "STRUCT-GATE-ON" USING WS-GKEY
     CALL "STRUCT-STORE-RESET"
     CALL "STRUCT-CHECK-RESET"
     MOVE 0 TO WS-MS-ROW WS-MS-MESA
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = "minecraft:mineshaft"
             MOVE WS-I TO WS-MS-ROW
         END-IF
         IF SDT-KEY(WS-I) = "minecraft:mineshaft_mesa"
             MOVE WS-I TO WS-MS-MESA
         END-IF
     END-PERFORM
     CALL "STRUCT-FIND-SET" USING WS-SETKEY WS-SET
*>   decorate chunk (13, 7): the start of the fixture is in the store
     MOVE 13 TO J-CX
     MOVE 7 TO J-CZ
     MOVE 3 TO J-SUB
     PERFORM RUN-CHUNK
     MOVE 13 TO WS-CX
     MOVE 7 TO WS-CZ
*>   not loaded: step 3 and 4: the set's frequency test passes at chunk (13, 7), the normal structure can be created (CHUNK_LOAD_NEEDED = 2), the mesa one has no valid biome (1)
     MOVE 0 TO WS-SKIP
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 checkStart of a chunk that is not loaded: the frequency test passes and the generator makes a stub in a valid biome: CHUNK_LOAD_NEEDED" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-ANSWER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-MESA WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 checkStart: the mesa mineshaft's stub is not in a mesa biome: START_NOT_PRESENT" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ANSWER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§7.6 featureChecks: both answers are memoised (two entries), the chunk is in the without-starts set once" TO TL-CASE
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     COMPUTE TL-OBSERVED-N = SCF-COUNT * 100 + SCW-COUNT * 10 + WS-ANSWER
     MOVE 212 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   step 3: a chunk where the frequency test says no
     MOVE 0 TO WS-OK
     PERFORM VARYING WS-FOUND-CX FROM 0 BY 1 UNTIL WS-FOUND-CX > 40 OR WS-OK = 1
         MOVE WS-FOUND-CX TO WS-CX
         CALL "STRUCT-FREQ-OK" USING WS-SET WS-SEED WS-CX WS-CZ WS-OK
         IF WS-OK = 1
             MOVE 0 TO WS-OK
         ELSE
             MOVE 1 TO WS-OK
         END-IF
     END-PERFORM
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 checkStart step 3: where the frequency reducer says no the answer is START_NOT_PRESENT without a generator run" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ANSWER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   loaded chunk (13, 7): onStructureLoad from the store
     MOVE 13 TO WS-CX
     CALL "STRUCT-CHECK-ON-LOAD" USING WS-CX WS-CZ
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 onStructureLoad: the valid start of the store is in the map: START_PRESENT" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ANSWER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-MESA WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 checkStart on a loaded chunk: a structure with no start there is START_NOT_PRESENT (no generator run)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ANSWER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-SKIP
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 skipReferenced: a start with references 0 is still START_PRESENT" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ANSWER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-CHECK-INCREMENT" USING WS-CX WS-CZ WS-MS-ROW
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 incrementReference + skipReferenced: references 1 is START_NOT_PRESENT when referenced starts are skipped" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ANSWER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SKIP
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 without skipReferenced a referenced start is START_PRESENT" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ANSWER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the marker -1: absent
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SCL-N(1)
         MOVE -1 TO SCL-REFS(1, WS-I)
     END-PERFORM
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 a stored -1 is START_NOT_PRESENT" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ANSWER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-CHECK-INCREMENT" USING WS-CX WS-CZ WS-MS-ROW
     MOVE "acceptance US12 36-1§7.6 incrementReference of a stored -1 starts again at 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SCL-REFS(1, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   incrementReference creates the map of a chunk the check does not know, and a second structure entry
     MOVE 5 TO WS-CX
     MOVE 5 TO WS-CZ
     CALL "STRUCT-CHECK-INCREMENT" USING WS-CX WS-CZ WS-MS-ROW
     CALL "STRUCT-CHECK-INCREMENT" USING WS-CX WS-CZ WS-MS-MESA
     MOVE 0 TO WS-SKIP
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-MESA WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 incrementReference makes the map of an unknown chunk: both structures are START_PRESENT there" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ANSWER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the sets' bounds
     MOVE 131072 TO SCW-COUNT
     MOVE 77 TO WS-CX
     MOVE 77 TO WS-CZ
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 chunksWithoutStartsInStorage: at 131072 entries the set is emptied and the chunk asked for is added" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SCW-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-CHECK-RESET"
     MOVE 1024 TO SCF-COUNT
     MOVE 13 TO WS-CX
     MOVE 7 TO WS-CZ
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     MOVE "acceptance US12 36-1§7.6 featureChecks wrap: a full memo table starts again with one entry" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SCF-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1024 TO SCL-COUNT
     MOVE 900 TO WS-CX
     MOVE 900 TO WS-CZ
     CALL "STRUCT-CHECK-ON-LOAD" USING WS-CX WS-CZ
     MOVE "acceptance US12 36-1§7.6 loadedChunks wrap: a full table starts again with the chunk loaded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE SCL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   onStructureLoad drops the chunk's memoised answers (marks them stale) and a stale one is asked again
     MOVE 5 TO WS-CX
     MOVE 5 TO WS-CZ
     CALL "STRUCT-CHECK-RESET"
     CALL "STRUCT-CHECK-START" USING WS-CX WS-CZ WS-MS-ROW WS-SET WS-SEED WS-SKIP WS-ANSWER
     CALL "STRUCT-CHECK-ON-LOAD" USING WS-CX WS-CZ
     CALL "STRUCT-CHECK-RESET"
     MOVE "acceptance US12 36-1§7.6 reset: every table is empty" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SCL-COUNT + SCF-COUNT + SCW-COUNT
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
 END PROGRAM TEST-STRUCT-CHECK.
 COPY NOSPAWN.
 COPY CORETEST.
