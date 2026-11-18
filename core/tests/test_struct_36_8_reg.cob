*> Acceptance test of the nether fortress in the Nether's worldgen (docs/protocol/36-structures-8-nether-and-end.md sections 2 and 5, 37-nether-6 sections 2 and 3; core/src/nether-struct.cob,
*> nether-dim.cob; T13511): on the generated vanilla-data (CC_GENERATED_DIR, read only; passes as skipped without it) a Nether chunk that holds a fortress start has nether bricks from the start
*> piece, the same chunk without the structure gate has none, regenerating it gives the same blocks, and the chunk publishes its spawn boxes (the override boxes of the fortress, 44-2 8.1).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-REG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CELLS.
 COPY GENENT.
 COPY GENBE.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTDIM.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-PTR                 USAGE POINTER.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-BRICKS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-SET                 BINARY-LONG VALUE 1.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-CAND-X              BINARY-LONG.
 01 WS-CAND-Z              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-VALID               PIC X(7) VALUE "11     ".
 01 WS-PICKED              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT1              BINARY-LONG.
 01 WS-COUNT2              BINARY-LONG.
 01 WS-FORTRESS            PIC X(80) VALUE "minecraft:fortress".
 01 WS-ROW                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PV                  BINARY-LONG.
 01 WS-MISSING             PIC X(80) VALUE "minecraft:not_a_structure".
 01 WS-MINY                BINARY-LONG VALUE 0.
 01 WS-HGT                 BINARY-LONG VALUE 256.
 01 WS-SEA                 BINARY-LONG VALUE 32.
 01 WS-ROW2                BINARY-LONG.
 01 WS-BSTONE              BINARY-LONG.
 01 WS-BASTION             PIC X(80) VALUE "minecraft:bastion_remnant".
 01 WS-FOUND2              BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
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
         MOVE "acceptance US12 36-8§2 A. Nether fortress: no generated packs here, skipped" TO TL-CASE
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
     MOVE "minecraft:nether_bricks" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-BRICKS
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
*>   the first chunk of the scan that holds a fortress start (the set's candidate, the weighted pick of 2.1 and 37-6 section 2)
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-SX FROM 0 BY 1 UNTIL WS-SX > 80 OR WS-FOUND = 1
         PERFORM VARYING WS-SZ FROM 0 BY 1 UNTIL WS-SZ > 80 OR WS-FOUND = 1
             CALL "NETHER-STRUCTURE-CANDIDATE" USING WS-SEED WS-SET WS-SX WS-SZ WS-CAND-X WS-CAND-Z WS-FLAG
             IF WS-FLAG = 1
                 CALL "NETHER-STRUCTURE-PICK" USING WS-SEED WS-SET WS-SX WS-SZ WS-VALID WS-PICKED
                 IF WS-PICKED = 1
                     MOVE 1 TO WS-FOUND
                     MOVE WS-SX TO WS-FX
                     MOVE WS-SZ TO WS-FZ
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: a fortress start chunk was found in the scan" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 0
         STOP RUN
     END-IF
     MOVE WS-FX TO WS-ED
     DISPLAY "PROBE fortress start chunk " FUNCTION TRIM(WS-ED) " " WS-FZ
*>   the chunk of the start: the start piece begins at (16 cx + 2, 16 cz + 2)
     MOVE 0 TO GE-BOX-COUNT
     CALL "NETHER-DIM-CHUNK" USING WS-FX WS-FZ CE-CHUNK WS-MARKER
     MOVE 0 TO WS-COUNT1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256 * 256
         IF CE-STATE(WS-I) = WS-BRICKS
             ADD 1 TO WS-COUNT1
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§5 A. Piece geometry: the start chunk of a fortress holds nether bricks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-COUNT1 > 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§6 A. Chests, the blaze spawner, loot and spawns: the chunk publishes the fortress's spawn boxes" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF GE-BOX-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the same again
     MOVE LOW-VALUES TO CE-CHUNK
     CALL "NETHER-DIM-CHUNK" USING WS-FX WS-FZ CE-CHUNK WS-MARKER
     MOVE 0 TO WS-COUNT2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256 * 256
         IF CE-STATE(WS-I) = WS-BRICKS
             ADD 1 TO WS-COUNT2
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: regenerating the chunk gives the same bricks" TO TL-CASE
     MOVE WS-COUNT1 TO TL-EXPECTED-N
     MOVE WS-COUNT2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the generic start query (STRUCT-FIND-POINT) builds the same fortress: the start piece first, the stub at the chunk's corner at y 64
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-FORTRESS
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     CALL "STRUCT-FIND-POINT" USING WS-ROW WS-SEED WS-FX WS-FZ WS-PX WS-PY WS-PZ WS-PV
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: the generic start query builds the fortress with its stub at (16 cx, 64, 16 cz)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-PV = 1 AND SP-COUNT > 1 AND SP-TYPE(1) = 18 AND WS-PY = 64 AND WS-PX = WS-FX * 16 AND WS-PZ = WS-FZ * 16
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   without the gate: no fortress
     CALL "STRUCT-GATE-RESET"
     MOVE LOW-VALUES TO CE-CHUNK
     CALL "NETHER-DIM-CHUNK" USING WS-FX WS-FZ CE-CHUNK WS-MARKER
     MOVE 0 TO WS-COUNT2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256 * 256
         IF CE-STATE(WS-I) = WS-BRICKS
             ADD 1 TO WS-COUNT2
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: with the structure off the chunk has no nether bricks" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-GATE-ON" USING WS-FORTRESS
*>   a bastion remnant: the same scan for the second entry of the set; its start chunk holds blackstone
     CALL "STRUCT-GATE-ON" USING WS-BASTION
     MOVE "minecraft:polished_blackstone_bricks" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-BSTONE
     MOVE 0 TO WS-FOUND2
     PERFORM VARYING WS-SX FROM 0 BY 1 UNTIL WS-SX > 80 OR WS-FOUND2 = 1
         PERFORM VARYING WS-SZ FROM 0 BY 1 UNTIL WS-SZ > 80 OR WS-FOUND2 = 1
             CALL "NETHER-STRUCTURE-CANDIDATE" USING WS-SEED WS-SET WS-SX WS-SZ WS-CAND-X WS-CAND-Z WS-FLAG
             IF WS-FLAG = 1
                 CALL "NETHER-STRUCTURE-PICK" USING WS-SEED WS-SET WS-SX WS-SZ WS-VALID WS-PICKED
                 IF WS-PICKED = 2
                     MOVE 1 TO WS-FOUND2
                     MOVE WS-SX TO WS-BX
                     MOVE WS-SZ TO WS-BZ
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-8§13 C. Bastion remnant: use of the jigsaw engine: a bastion start chunk was found in the scan" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND2 = 1
         DISPLAY "PROBE bastion start chunk " WS-BX " " WS-BZ
         MOVE 0 TO WS-ROW
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
             IF SDT-KEY(WS-I) = WS-BASTION
                 MOVE WS-I TO WS-ROW
             END-IF
         END-PERFORM
         MOVE 1 TO SDM-KIND
         CALL "STRUCT-FIND-POINT" USING WS-ROW WS-SEED WS-BX WS-BZ WS-PX WS-PY WS-PZ WS-PV
         MOVE 0 TO SDM-KIND
         DISPLAY "PROBE bastion valid " WS-PV " pieces " SP-COUNT " stub " WS-PX " " WS-PY " " WS-PZ
         COMPUTE WS-FX = FUNCTION INTEGER(WS-PX / 16)
         COMPUTE WS-FZ = FUNCTION INTEGER(WS-PZ / 16)
         MOVE LOW-VALUES TO CE-CHUNK
         CALL "NETHER-DIM-CHUNK" USING WS-FX WS-FZ CE-CHUNK WS-MARKER
         MOVE 0 TO WS-COUNT2
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256 * 256
             IF CE-STATE(WS-I) = WS-BSTONE
                 ADD 1 TO WS-COUNT2
             END-IF
         END-PERFORM
         DISPLAY "PROBE bastion bricks " WS-COUNT2
         MOVE "acceptance US12 36-8§13 C. Bastion remnant: use of the jigsaw engine: the start chunk of a bastion holds polished blackstone bricks" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-COUNT2 > 20
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-IF
*>   a structure that is gated on but not in the table prepares nothing
     CALL "STRUCT-GATE-ON" USING WS-MISSING
     CALL "STRUCT-DIM-OPEN" USING WS-MISSING WS-FX WS-FZ CE-CHUNK WS-MINY WS-HGT WS-SEA WS-ROW2
     MOVE "acceptance US12 36-8§2 A. Nether fortress: structure, start and growth: a gated structure that is not loaded has no row and nothing is prepared" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-ROW2 TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-REG.

 COPY NOSPAWN.
 COPY CORETEST.
