*> Acceptance test of the nether fossil in the Nether's chunk pipeline (docs/protocol/37-nether-6-structures-spawns-hooks.md sections 3.4 and 7, 37-nether-5 section 6, 36-structures-4 section 9;
*> core/src/nether-struct.cob NETHER-GEN-STRUCTURES, core/src/struct-place.cob STRUCT-PLACE-START, core/src/struct-fossil.cob; T51501): on the generated vanilla-data (CC_GENERATED_DIR, read only; passes
*> as skipped without it) of world seed 12345 the nether_fossil starts of a 161 by 161 chunk grid are collected (NETHER-FOSSIL-START: the candidate of the set nether_fossils, the soul sand valley, the
*> generation point); of the starts with no other start within 3 chunks (so that no other piece reaches its chunks) up to three are taken. The chunks that the piece's box touches are made by
*> NETHER-DIM-CHUNK (the Nether pipeline of the dimension) and together hold exactly the bone blocks of the start's template, all inside the piece's box, and at most one dried ghast; a chunk the
*> box does not touch holds none; a chunk with no start within 3 chunks holds no bone block.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-FOSSIL-GEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTTPL.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-PTR                 USAGE POINTER.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-N                   BINARY-LONG VALUE 0.
 01 WS-ST.
    05 WS-ST-ENTRY OCCURS 400 TIMES.
       10 WS-ST-X          BINARY-LONG.
       10 WS-ST-Z          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-CASES               BINARY-LONG VALUE 0.
 01 WS-FCX                 BINARY-LONG.
 01 WS-FCZ                 BINARY-LONG.
 01 WS-TROW                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-EXPECTED            BINARY-LONG.
 01 WS-BX0                 BINARY-LONG.
 01 WS-BY0                 BINARY-LONG.
 01 WS-BZ0                 BINARY-LONG.
 01 WS-BX1                 BINARY-LONG.
 01 WS-BY1                 BINARY-LONG.
 01 WS-BZ1                 BINARY-LONG.
 01 WS-CX0                 BINARY-LONG.
 01 WS-CX1                 BINARY-LONG.
 01 WS-CZ0                 BINARY-LONG.
 01 WS-CZ1                 BINARY-LONG.
 01 WS-CCX                 BINARY-LONG.
 01 WS-CCZ                 BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-BONES               BINARY-LONG.
 01 WS-GHASTS              BINARY-LONG.
 01 WS-OUTSIDE             BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-REM                 BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-ED                  PIC 9.
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
         MOVE "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: no generated packs here, skipped" TO TL-CASE
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
     MOVE CW-SEED TO WS-SEED
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
*>   the starts of the grid
     MOVE 0 TO WS-N
     PERFORM VARYING WS-SX FROM -80 BY 1 UNTIL WS-SX > 80
         PERFORM VARYING WS-SZ FROM -80 BY 1 UNTIL WS-SZ > 80
             CALL "NETHER-FOSSIL-START" USING WS-SEED WS-SX WS-SZ WS-VALID
             IF WS-VALID = 1 AND WS-N < 400
                 ADD 1 TO WS-N
                 MOVE WS-SX TO WS-ST-X(WS-N)
                 MOVE WS-SZ TO WS-ST-Z(WS-N)
             END-IF
         END-PERFORM
     END-PERFORM
     DISPLAY "PROBE fossil starts in the 161 x 161 grid " WS-N
     MOVE "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: the grid holds nether_fossil starts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N >= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   up to three starts with no other start within 3 chunks
     MOVE 0 TO WS-CASES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR WS-CASES >= 3
         MOVE 0 TO WS-NEAR
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
             IF WS-J NOT = WS-I
                 IF FUNCTION ABS(WS-ST-X(WS-J) - WS-ST-X(WS-I)) <= 3 AND FUNCTION ABS(WS-ST-Z(WS-J) - WS-ST-Z(WS-I)) <= 3
                     ADD 1 TO WS-NEAR
                 END-IF
             END-IF
         END-PERFORM
         IF WS-NEAR = 0
             ADD 1 TO WS-CASES
             MOVE WS-ST-X(WS-I) TO WS-FCX
             MOVE WS-ST-Z(WS-I) TO WS-FCZ
             PERFORM START-CASE
         END-IF
     END-PERFORM
     MOVE "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: three isolated starts were found to test" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-CASES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM EMPTY-CASE
     PERFORM GATE-OFF-CASE
     STOP RUN.

*> one isolated start (chunk WS-FCX, WS-FCZ): the piece, its template's bone blocks, the chunks of its box, the ring of chunks around them
 START-CASE.
     CALL "NETHER-FOSSIL-START" USING WS-SEED WS-FCX WS-FCZ WS-VALID
     MOVE SP-T-ROW(1) TO WS-TROW
     MOVE SP-X0(1) TO WS-BX0
     MOVE SP-Y0(1) TO WS-BY0
     MOVE SP-Z0(1) TO WS-BZ0
     MOVE SP-X1(1) TO WS-BX1
     MOVE SP-Y1(1) TO WS-BY1
     MOVE SP-Z1(1) TO WS-BZ1
     MOVE 0 TO WS-EXPECTED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TP-BLOCKS(WS-TROW)
         MOVE TB-STATE(TP-BASE(WS-TROW, 1) + WS-K) TO WS-STATE
         IF WS-STATE NOT = 0
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF CB-KEY(WS-BLOCK) = "bone_block"
                 ADD 1 TO WS-EXPECTED
             END-IF
         END-IF
     END-PERFORM
     COMPUTE WS-CX0 = FUNCTION INTEGER(WS-BX0 / 16)
     COMPUTE WS-CX1 = FUNCTION INTEGER(WS-BX1 / 16)
     COMPUTE WS-CZ0 = FUNCTION INTEGER(WS-BZ0 / 16)
     COMPUTE WS-CZ1 = FUNCTION INTEGER(WS-BZ1 / 16)
     MOVE 0 TO WS-BONES WS-GHASTS WS-OUTSIDE
     PERFORM VARYING WS-CCX FROM WS-CX0 BY 1 UNTIL WS-CCX > WS-CX1
         PERFORM VARYING WS-CCZ FROM WS-CZ0 BY 1 UNTIL WS-CCZ > WS-CZ1
             PERFORM COUNT-CHUNK
         END-PERFORM
     END-PERFORM
     MOVE WS-CASES TO WS-ED
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: start " WS-ED " has a template of at least one bone block" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-EXPECTED >= 5
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: the chunks of start " WS-ED " hold exactly the bone blocks of its template" DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECTED TO TL-EXPECTED-N
     MOVE WS-BONES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: every bone block of start " WS-ED " is inside the piece's box" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUTSIDE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: start " WS-ED " has at most one dried ghast (the 50 percent gate of 9.3)" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-GHASTS <= 1
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the chunks just outside the box's chunks hold no bone block (no other start reaches them: no start within 3 chunks)
     MOVE 0 TO WS-BONES WS-GHASTS WS-OUTSIDE
     COMPUTE WS-CCX = WS-CX1 + 1
     PERFORM VARYING WS-CCZ FROM WS-CZ0 BY 1 UNTIL WS-CCZ > WS-CZ1
         PERFORM COUNT-CHUNK
     END-PERFORM
     COMPUTE WS-CCX = WS-CX0 - 1
     PERFORM VARYING WS-CCZ FROM WS-CZ0 BY 1 UNTIL WS-CCZ > WS-CZ1
         PERFORM COUNT-CHUNK
     END-PERFORM
     COMPUTE WS-CCZ = WS-CZ1 + 1
     PERFORM VARYING WS-CCX FROM WS-CX0 BY 1 UNTIL WS-CCX > WS-CX1
         PERFORM COUNT-CHUNK
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: the chunks beside the box of start " WS-ED " hold no bone block" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BONES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> a chunk of the grid with no start within 3 chunks holds no bone block
 EMPTY-CASE.
     MOVE 0 TO WS-FLAG
     PERFORM VARYING WS-SX FROM -80 BY 1 UNTIL WS-SX > 80 OR WS-FLAG = 1
         MOVE 0 TO WS-NEAR
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-N
             IF FUNCTION ABS(WS-ST-X(WS-J) - WS-SX) <= 3 AND FUNCTION ABS(WS-ST-Z(WS-J)) <= 3
                 ADD 1 TO WS-NEAR
             END-IF
         END-PERFORM
         IF WS-NEAR = 0
             MOVE 1 TO WS-FLAG
             MOVE WS-SX TO WS-CCX
             MOVE 0 TO WS-CCZ
         END-IF
     END-PERFORM
     MOVE "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: a chunk on the row z 0 with no start within 3 chunks was found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BONES WS-GHASTS WS-OUTSIDE
     PERFORM COUNT-CHUNK
     MOVE "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: a chunk with no start within 3 chunks holds no bone block and no dried ghast" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-BONES + WS-GHASTS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the gate of minecraft:nether_fossil is off (every gate emptied): the chunks of the last start's box hold no bone block although the start is there
 GATE-OFF-CASE.
     CALL "STRUCT-GATE-RESET"
     MOVE 0 TO WS-BONES WS-GHASTS WS-OUTSIDE
     PERFORM VARYING WS-CCX FROM WS-CX0 BY 1 UNTIL WS-CCX > WS-CX1
         PERFORM VARYING WS-CCZ FROM WS-CZ0 BY 1 UNTIL WS-CCZ > WS-CZ1
             PERFORM COUNT-CHUNK
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 37-6§3.4 Nether fossil in the chunk pipeline: with the gate of minecraft:nether_fossil off the chunks of a start's box hold no bone block" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BONES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the chunk WS-CCX, WS-CCZ made by the Nether pipeline: its bone blocks and dried ghasts are added to WS-BONES and WS-GHASTS; a bone block outside the box WS-BX0..WS-BZ1 adds to WS-OUTSIDE
 COUNT-CHUNK.
     MOVE LOW-VALUES TO CE-CHUNK
     CALL "NETHER-DIM-CHUNK" USING WS-CCX WS-CCZ CE-CHUNK WS-MARKER
     PERFORM VARYING WS-CELL FROM 1 BY 1 UNTIL WS-CELL > 65536
         IF CE-STATE(WS-CELL) NOT = 0
             MOVE CE-STATE(WS-CELL) TO WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF CB-KEY(WS-BLOCK) = "bone_block"
                 ADD 1 TO WS-BONES
                 COMPUTE WS-Y = (WS-CELL - 1) / 256
                 COMPUTE WS-REM = WS-CELL - 1 - WS-Y * 256
                 COMPUTE WS-K = FUNCTION INTEGER(WS-REM / 16)
                 COMPUTE WS-Z = WS-CCZ * 16 + WS-K
                 COMPUTE WS-X = WS-CCX * 16 + WS-REM - WS-K * 16
                 IF WS-X < WS-BX0 OR WS-X > WS-BX1 OR WS-Y < WS-BY0 OR WS-Y > WS-BY1 OR WS-Z < WS-BZ0 OR WS-Z > WS-BZ1
                     ADD 1 TO WS-OUTSIDE
                 END-IF
             END-IF
             IF CB-KEY(WS-BLOCK) = "dried_ghast"
                 ADD 1 TO WS-GHASTS
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM TEST-NETHER-FOSSIL-GEN.

 COPY NOSPAWN.
 COPY CORETEST.
