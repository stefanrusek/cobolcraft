*> Acceptance test of docs/protocol/36-structures-1 sections 7 and 8 (chunk integration and placing pieces) with the mineshaft as the structure: a chunk is decorated with the starts of the chunks
*> within 8 of it (the vanilla model: the start of chunk (13,7) of seed 0 is rebuilt from the seed by every chunk it reaches and each chunk writes only its own cells), only at the structure's
*> decoration step (underground_structures, 3), only for structures that are on, never for a start more than 8 chunks away, the same blocks every time, and a start of the mesa type makes nothing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-1-7.
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

*>   nothing is gated on: the hook leaves the chunk alone at the structure step
     MOVE 13 TO J-CX
     MOVE 7 TO J-CZ
     MOVE 3 TO J-SUB
     PERFORM RUN-CHUNK
     MOVE "acceptance US12 36-1§8 Placing pieces: no structure on: the chunk is untouched" TO TL-CASE
     MOVE WS-AIRS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the mesa structure alone: its start is refused (no base height), so nothing is placed
     MOVE "minecraft:mineshaft_mesa" TO WS-GKEY
     CALL "STRUCT-GATE-ON" USING WS-GKEY
     PERFORM RUN-CHUNK
     MOVE "acceptance US12 36-5§2.3 Placing pieces: only the mesa mineshaft on: no start, no block" TO TL-CASE
     MOVE WS-AIRS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the normal mineshaft on: the chunk of the root room
     MOVE "minecraft:mineshaft" TO WS-GKEY
     CALL "STRUCT-GATE-ON" USING WS-GKEY
     MOVE 2 TO J-SUB
     PERFORM RUN-CHUNK
     MOVE "acceptance US12 36-1§8 Placing pieces: at another decoration step (2) nothing is placed" TO TL-CASE
     MOVE WS-AIRS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO J-SUB
     PERFORM RUN-CHUNK
     MOVE WS-HASH TO WS-HASH2
     MOVE WS-AIRS TO WS-AIRS2
     MOVE "acceptance US12 36-1§8 Placing pieces: chunk (13,7) seed 0 at step 3: the start of this very chunk is placed (cave air in the chunk)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-AIRS > 100
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-X
     MOVE -57 TO WS-Y
     MOVE 6 TO WS-Z
     PERFORM CELL-STATE
     MOVE "acceptance US12 36-5§2.5 Placing pieces: the root room (210,-59,114)-(221,-53,121) of the script: its middle (215,-57,118) is cave air" TO TL-CASE
     MOVE WS-CELL TO TL-OBSERVED-N
     MOVE SB-S-CAVE-AIR TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§8 Placing pieces: the decoration discards no write (every cell written is inside the chunk's window) and the request lists were handed to the job" TO TL-CASE
     COMPUTE TL-OBSERVED-N = FL-DISCARDED + FL-OV-COUNT + GBL-COUNT
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the same chunk again gives the same blocks (a pure function of seed, chunk and world)
     PERFORM RUN-CHUNK
     MOVE "acceptance US12 36-1§8 Placing pieces: the same chunk again: the same blocks" TO TL-CASE
     MOVE WS-HASH TO TL-OBSERVED-N
     MOVE WS-HASH2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the next chunk east (14,7), generated alone, is decorated from the same start; the tunnels meet at the border x = 223 / 224
     MOVE 14 TO J-CX
     PERFORM RUN-CHUNK
     MOVE "acceptance US12 36-1§7 Chunk integration: the neighbour chunk (14,7) is decorated by the start of (13,7) (cave air in it)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     IF WS-AIRS > 0
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM COUNT-SEAM
     MOVE "acceptance US12 36-1§7 Chunk integration: pieces that cross the border are rebuilt by both chunks: some air cell at x = 223 meets a placed (non-rock) cell at x = 224: the tunnel of piece 64 of the script continues across the border" TO TL-CASE

     MOVE 0 TO TL-EXPECTED-N
     IF WS-PAIRS-SEAM > 0
         MOVE 1 TO TL-EXPECTED-N
     END-IF
     MOVE 1 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   more than 8 chunks away: not referenced
     MOVE 22 TO J-CX
     PERFORM RUN-CHUNK
     MOVE "acceptance US12 36-1§7 Chunk integration: chunk (22,7) is 9 chunks from the start: nothing" TO TL-CASE
     MOVE WS-AIRS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 200 TO J-CX
     MOVE 200 TO J-CZ
     PERFORM RUN-CHUNK
     MOVE "acceptance US12 36-1§7 Chunk integration: a chunk far from any start: nothing (and the 17 x 17 scan finds none)" TO TL-CASE
     MOVE WS-AIRS TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a terrain adapting structure: the start's box is inflated by 12 for the references, the pieces and the blocks are the same
     MOVE 0 TO WS-MS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF ST-KEY(WS-I) = "minecraft:mineshaft"
             MOVE WS-I TO WS-MS-ROW
         END-IF
     END-PERFORM
     MOVE 1 TO ST-ADAPT(WS-MS-ROW)
     MOVE 13 TO J-CX
     MOVE 7 TO J-CZ
     PERFORM RUN-CHUNK
     MOVE 0 TO ST-ADAPT(WS-MS-ROW)
     MOVE "acceptance US12 36-1§5.6 Placing pieces: with terrain adaptation the start's box grows by 12 and the chunk gets the same blocks" TO TL-CASE
     MOVE WS-HASH TO TL-OBSERVED-N
     MOVE WS-HASH2 TO TL-EXPECTED-N
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
 COUNT-SEAM.
*>   the chunk (14,7) is in WS-PTR; the chunk (13,7) kept from the earlier run is not available, so the seam is read from a fresh run of (13,7) into WS-PTR2
     MOVE 0 TO WS-PAIRS-SEAM
     MOVE WS-PTR TO WS-PTR-KEEP
     MOVE WS-PTR2 TO WS-PTR
     MOVE 13 TO J-CX
     PERFORM RUN-CHUNK
     MOVE WS-PTR-KEEP TO WS-PTR2
     PERFORM VARYING WS-Y FROM -64 BY 1 UNTIL WS-Y > 40
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             MOVE 15 TO WS-X
             COMPUTE WS-I = (WS-Y + 64) * 256 + WS-Z * 16 + WS-X + 1
             SET ADDRESS OF CE-CHUNK TO WS-PTR
             MOVE CE-STATE(WS-I) TO WS-CELL
             IF WS-CELL = SB-S-CAVE-AIR
                 COMPUTE WS-I = (WS-Y + 64) * 256 + WS-Z * 16 + 1
                 SET ADDRESS OF CE-CHUNK TO WS-PTR2
                 IF CE-STATE(WS-I) NOT = WS-STONE
                     ADD 1 TO WS-PAIRS-SEAM
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM.
 ADD-POINT.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE 0 TO WS-OFFSET
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET.
 END PROGRAM TEST-STRUCT-36-1-7.
 COPY CORETEST.
