*> Cost and identity of generating chunks near a village or outpost and far from every adapting structure (real data, skipped as a pass without the generated packs): the production gates
*> of the standard world (CORE-WORLD-OPEN) are on; the first start of a structure with a terrain adaptation (SDT-ADAPT not 0) of a 300 x 300 chunk area is found by STRUCT-CHUNK-STARTS, an
*> N x N block of chunks (N 2, at most 3: CC_BENCH_N) around it and a block whose 19 x 19 windows hold no such start are generated whole by the atomic path (GEN-JOB-RUN-ALL), and the
*> process CPU time (clock()) of each chunk is printed as `PERF` lines with a checksum of its bytes (CC_BENCH_PREPARE=1 times STRUCT-BEARD-PREPARE of each chunk apart first). Cases: the far
*> chunks are the same bytes with the adapting structures gated off (nothing of the beardifier reaches a chunk away from them), and the chunks near a structure cost at most 5 times the far
*> ones in CPU time (the beardifier once made it 15 times: a kernel value computed by FUNCTION EXP on every call, and a bound of the beardifier over every cell that kept the terrain fill from
*> skipping any).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-BEARD-COST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY DIMENSIONS.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-DIM                 BINARY-LONG.
 01 WS-N                   BINARY-LONG VALUE 2.
 01 WS-NEAR-CX             BINARY-LONG.
 01 WS-NEAR-CZ             BINARY-LONG.
 01 WS-FAR-CX              BINARY-LONG.
 01 WS-FAR-CZ              BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-ADAPT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-REF                 PIC X(304640).
 01 WS-REF-Y               BINARY-LONG.
 01 WS-CLK                 BINARY-DOUBLE.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-US                  BINARY-DOUBLE.
 01 WS-BLOCK-US            BINARY-DOUBLE.
 01 WS-FAR-US              BINARY-DOUBLE.
 01 WS-NEAR-US             BINARY-DOUBLE.
 01 WS-PER                 BINARY-DOUBLE.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-BYTE                BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-EDIT                PIC Z(9)9.
 01 WS-EDIT2               PIC -(7)9.
 01 WS-EDIT3               PIC -(7)9.
 01 WS-EDIT4               PIC Z(9)9.
 01 WS-LABEL               PIC X(8).
 01 WS-PREP-MODE           BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEEP-BYTES          BINARY-LONG.
 01 WS-KEEP-N              BINARY-LONG.
 01 WS-KEEP.
    05 WS-KEEP-KEY         PIC X(80) OCCURS 64 TIMES.
 01 WS-FAR-BYTES.
    05 WS-FAR-CHUNK        PIC X(304640) OCCURS 9 TIMES.
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
         MOVE "test struct beard cost no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_BENCH_N"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-N = FUNCTION NUMVAL(WS-ENV)
         IF WS-N > 3
             MOVE 3 TO WS-N
         END-IF
     END-IF
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_BENCH_PREPARE"
     IF WS-ENV NOT = SPACES
         MOVE 1 TO WS-PREP-MODE
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-DIM(1) TO WS-DIM
     PERFORM FIND-NEAR
     PERFORM FIND-FAR
     MOVE WS-NEAR-CX TO WS-EDIT2
     MOVE WS-NEAR-CZ TO WS-EDIT3
     DISPLAY "PERF near start chunk (" FUNCTION TRIM(WS-EDIT2) "," FUNCTION TRIM(WS-EDIT3) ")"
     MOVE WS-FAR-CX TO WS-EDIT2
     MOVE WS-FAR-CZ TO WS-EDIT3
     DISPLAY "PERF far chunk (" FUNCTION TRIM(WS-EDIT2) "," FUNCTION TRIM(WS-EDIT3) ")"
*>   the far block with every production gate, its bytes kept
     MOVE "far" TO WS-LABEL
     MOVE WS-FAR-CX TO WS-CX
     MOVE WS-FAR-CZ TO WS-CZ
     MOVE 1 TO WS-KEEP-BYTES
     PERFORM GENERATE-BLOCK
     MOVE WS-BLOCK-US TO WS-FAR-US
*>   the block near the structure
     MOVE "near" TO WS-LABEL
     MOVE WS-NEAR-CX TO WS-CX
     MOVE WS-NEAR-CZ TO WS-CZ
     MOVE 0 TO WS-KEEP-BYTES
     PERFORM GENERATE-BLOCK
     MOVE WS-BLOCK-US TO WS-NEAR-US
     MOVE "test struct beard cost given chunks near a village or outpost when a block is generated then it costs at most 5 times a block far from structures" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NEAR-US <= WS-FAR-US * 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the adapting structures gated off (every other gate as it was): the far chunks are the same bytes
     MOVE SD-GATE-COUNT TO WS-KEEP-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-GATE-COUNT
         MOVE SD-GATE(WS-I) TO WS-KEEP-KEY(WS-I)
     END-PERFORM
     CALL "STRUCT-GATE-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KEEP-N
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > SD-ST-COUNT
             IF SDT-KEY(WS-K) = WS-KEEP-KEY(WS-I) AND SDT-ADAPT(WS-K) = 0
                 CALL "STRUCT-GATE-ON" USING WS-KEEP-KEY(WS-I)
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-SLOT
     PERFORM VARYING WS-WZ FROM 0 BY 1 UNTIL WS-WZ >= WS-N
         PERFORM VARYING WS-WX FROM 0 BY 1 UNTIL WS-WX >= WS-N
             ADD 1 TO WS-SLOT
             COMPUTE WS-SX = WS-FAR-CX - 1 + WS-WX
             COMPUTE WS-SZ = WS-FAR-CZ - 1 + WS-WZ
             CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-SX WS-SZ WS-REF WS-REF-Y
             MOVE 0 TO TL-OBSERVED-N
             IF WS-REF = WS-FAR-CHUNK(WS-SLOT)
                 MOVE 1 TO TL-OBSERVED-N
             END-IF
             MOVE WS-SX TO WS-EDIT2
             MOVE WS-SZ TO WS-EDIT3
             MOVE SPACES TO TL-CASE
             STRING "test struct beard cost given chunk (" FUNCTION TRIM(WS-EDIT2) "," FUNCTION TRIM(WS-EDIT3)
                 ") with no adapting start within 8 chunks when it is generated with and without the adapting structures then the bytes are the same" DELIMITED BY SIZE INTO TL-CASE
             MOVE 1 TO TL-EXPECTED-N
             CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         END-PERFORM
     END-PERFORM
     STOP RUN.

*> the first chunk of a scan of 300 x 300 chunks (x outer, z inner) holding the start of an adapting structure
 FIND-NEAR.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-SX FROM -150 BY 1 UNTIL WS-SX > 149 OR WS-FOUND = 1
         PERFORM VARYING WS-SZ FROM -150 BY 1 UNTIL WS-SZ > 149 OR WS-FOUND = 1
             CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-SX WS-SZ WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                 IF SDT-ADAPT(SC-STRUCT(WS-I)) NOT = 0 AND WS-FOUND = 0
                     MOVE 1 TO WS-FOUND
                     MOVE WS-SX TO WS-NEAR-CX
                     MOVE WS-SZ TO WS-NEAR-CZ
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "test struct beard cost given the production gates when 300 x 300 chunks are scanned then a start of an adapting structure is found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the first candidate of a row, 40 chunks apart in x, whose 19 x 19 chunks hold no start of an adapting structure
 FIND-FAR.
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 400 OR WS-FOUND = 1
         COMPUTE WS-FAR-CX = 1000 + WS-K * 40
         COMPUTE WS-FAR-CZ = -1000 + WS-K * 13
         MOVE 0 TO WS-ADAPT
         PERFORM VARYING WS-WX FROM -9 BY 1 UNTIL WS-WX > 9
             PERFORM VARYING WS-WZ FROM -9 BY 1 UNTIL WS-WZ > 9
                 COMPUTE WS-SX = WS-FAR-CX + WS-WX
                 COMPUTE WS-SZ = WS-FAR-CZ + WS-WZ
                 CALL "STRUCT-CHUNK-STARTS" USING CW-SEED WS-SX WS-SZ WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                     IF SDT-ADAPT(SC-STRUCT(WS-I)) NOT = 0
                         MOVE 1 TO WS-ADAPT
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         IF WS-ADAPT = 0
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "test struct beard cost given the production gates when a row of candidates is scanned then a chunk with no adapting start near it is found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> N x N chunks from (WS-CX - 1, WS-CZ - 1), z outer: the CPU time of each chunk and of the block, a checksum of each chunk; WS-KEEP-BYTES 1 keeps the bytes of the chunks
 GENERATE-BLOCK.
     MOVE 0 TO WS-SLOT
     CALL STATIC "clock" RETURNING WS-T0
     PERFORM VARYING WS-WZ FROM 0 BY 1 UNTIL WS-WZ >= WS-N
         PERFORM VARYING WS-WX FROM 0 BY 1 UNTIL WS-WX >= WS-N
             ADD 1 TO WS-SLOT
             COMPUTE WS-SX = WS-CX - 1 + WS-WX
             COMPUTE WS-SZ = WS-CZ - 1 + WS-WZ
             IF WS-PREP-MODE = 1
                 CALL STATIC "clock" RETURNING WS-CLK
                 CALL "STRUCT-BEARD-PREPARE" USING WS-SX WS-SZ
                 CALL STATIC "clock" RETURNING WS-US
                 COMPUTE WS-US = WS-US - WS-CLK
                 MOVE WS-US TO WS-EDIT4
                 DISPLAY "PERF " FUNCTION TRIM(WS-LABEL) " prepare " FUNCTION TRIM(WS-EDIT4) " us"
             END-IF
             CALL STATIC "clock" RETURNING WS-CLK
             CALL "GEN-JOB-RUN-ALL" USING WS-DIM WS-SX WS-SZ WS-REF WS-REF-Y
             CALL STATIC "clock" RETURNING WS-US
             COMPUTE WS-US = WS-US - WS-CLK
             IF WS-KEEP-BYTES = 1
                 MOVE WS-REF TO WS-FAR-CHUNK(WS-SLOT)
             END-IF
             PERFORM CHECKSUM
             MOVE WS-SX TO WS-EDIT2
             MOVE WS-SZ TO WS-EDIT3
             MOVE WS-US TO WS-EDIT4
             DISPLAY "PERF " FUNCTION TRIM(WS-LABEL) " chunk (" FUNCTION TRIM(WS-EDIT2) "," FUNCTION TRIM(WS-EDIT3) ") cpu " FUNCTION TRIM(WS-EDIT4)
                 " us, checksum " WS-HASH
         END-PERFORM
     END-PERFORM
     CALL STATIC "clock" RETURNING WS-CLK
     COMPUTE WS-BLOCK-US = WS-CLK - WS-T0
     COMPUTE WS-PER = WS-BLOCK-US / (WS-N * WS-N)
     MOVE WS-PER TO WS-EDIT
     MOVE WS-N TO WS-EDIT4
     DISPLAY "PERF " FUNCTION TRIM(WS-LABEL) " " FUNCTION TRIM(WS-EDIT4) " x " FUNCTION TRIM(WS-EDIT4) " chunks: " FUNCTION TRIM(WS-EDIT) " cpu us per chunk".

 CHECKSUM.
     MOVE 1 TO WS-HASH
     PERFORM VARYING WS-POS FROM 1 BY 1 UNTIL WS-POS > 304640
         COMPUTE WS-BYTE = FUNCTION ORD(WS-REF(WS-POS:1))
         COMPUTE WS-HASH = FUNCTION MOD(WS-HASH * 31 + WS-BYTE, 2147483629)
     END-PERFORM.
 END PROGRAM TEST-STRUCT-BEARD-COST.

 COPY NOSPAWN.
 COPY CORETEST.
