*> Acceptance test of the bastion's magma cube spawner (docs/protocol/36-structures-8-nether-and-end.md sections 15.4, 14 treasure row; core/src/nether-struct.cob, struct-tpl-piece.cob; T26003):
*> on the generated vanilla-data (CC_GENERATED_DIR, read only; passes as skipped without it) the treasure room starts of the Nether are scanned for one whose layout holds the template
*> bastion/treasure/bases/lava_basin; the chunks that piece touches are generated and publish exactly one spawner block entity request there, for the magma cube, at the template cell
*> (11, 7, 19) turned by the piece's rotation about its pivot and moved to its position, and no spawner anywhere else in those chunks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-15.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTJIG.
 COPY STRUCTTPL.
 COPY CELLS.
 COPY GENBE.
 COPY STRUCTDIM.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-ROT                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-SET                 BINARY-LONG VALUE 1.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-CAND-X              BINARY-LONG.
 01 WS-CAND-Z              BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-VALID               PIC X(7) VALUE "11     ".
 01 WS-PICKED              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PV                  BINARY-LONG.
 01 WS-STARTS              BINARY-LONG VALUE 0.
 01 WS-REJECTED            BINARY-LONG VALUE 0.
 01 WS-BAD-DRAW            BINARY-LONG VALUE 0.
 01 WS-BAD-FAMILY          BINARY-LONG VALUE 0.
 01 WS-BAD-PROC            BINARY-LONG VALUE 0.
 01 WS-BAD-STUB            BINARY-LONG VALUE 0.
 01 WS-SEEN.
    05 WS-SEEN-V           BINARY-LONG OCCURS 4 TIMES.
 01 WS-SIZES.
    05 FILLER PIC X(9) VALUE "046024046".
    05 FILLER PIC X(9) VALUE "030024048".
    05 FILLER PIC X(9) VALUE "038048038".
    05 FILLER PIC X(9) VALUE "016032032".
 01 WS-SZ-TAB REDEFINES WS-SIZES.
    05 WS-S OCCURS 4 TIMES.
       10 WS-S-X           PIC 999.
       10 WS-S-Y           PIC 999.
       10 WS-S-Z           PIC 999.
 01 WS-FAMILIES.
    05 FILLER PIC X(40) VALUE "minecraft:bastion/units/".
    05 FILLER PIC X(40) VALUE "minecraft:bastion/hoglin_stable/".
    05 FILLER PIC X(40) VALUE "minecraft:bastion/treasure/".
    05 FILLER PIC X(40) VALUE "minecraft:bastion/bridge/".
 01 WS-FAM REDEFINES WS-FAMILIES.
    05 WS-FAMILY           PIC X(40) OCCURS 4 TIMES.
 01 WS-LEN                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-SXX                 BINARY-LONG.
 01 WS-SYY                 BINARY-LONG.
 01 WS-SZZ                 BINARY-LONG.
 01 WS-CEN-X               BINARY-LONG.
 01 WS-CEN-Z               BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LOC                 PIC X(96).
 01 WS-PROC                PIC X(80).
 01 WS-BASTION             PIC X(80) VALUE "minecraft:bastion_remnant".
 01 WS-PROCS.
    05 FILLER PIC X(48) VALUE "bastion_generic_degradation".
    05 FILLER PIC X(48) VALUE "housing".
    05 FILLER PIC X(48) VALUE "stable_degradation".
    05 FILLER PIC X(48) VALUE "side_wall_degradation".
    05 FILLER PIC X(48) VALUE "treasure_rooms".
    05 FILLER PIC X(48) VALUE "high_wall".
    05 FILLER PIC X(48) VALUE "roof".
    05 FILLER PIC X(48) VALUE "bottom_rampart".
    05 FILLER PIC X(48) VALUE "high_rampart".
    05 FILLER PIC X(48) VALUE "bridge".
    05 FILLER PIC X(48) VALUE "rampart_degradation".
    05 FILLER PIC X(48) VALUE "entrance_replacement".
 01 WS-PR REDEFINES WS-PROCS.
    05 WS-PNAME            PIC X(48) OCCURS 12 TIMES.
*> which of the twelve lists each variant may use (1 allowed): units, hoglin stable, treasure, bridge
 01 WS-ALLOW.
    05 FILLER PIC X(12) VALUE "110000000000".
    05 FILLER PIC X(12) VALUE "101100000000".
    05 FILLER PIC X(12) VALUE "100011111000".
    05 FILLER PIC X(12) VALUE "100000000111".
 01 WS-AL REDEFINES WS-ALLOW.
    05 WS-ALLOW-ROW        PIC X(12) OCCURS 4 TIMES.
 01 WS-PKEY                PIC X(80).
 01 WS-PID                 BINARY-LONG.
 01 WS-BADLOAD             BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-SDM-SAVE            BINARY-LONG.
 01 WS-PTR                 USAGE POINTER.
 01 WS-CHESTS              BINARY-LONG VALUE 0.
 01 WS-BAD-LOOT            BINARY-LONG VALUE 0.
 01 WS-SPAWNERS            BINARY-LONG VALUE 0.
 01 WS-BAD-SPAWNER         BINARY-LONG VALUE 0.
 01 WS-CCX                 BINARY-LONG.
 01 WS-CCZ                 BINARY-LONG.
 01 WS-CX0                 BINARY-LONG.
 01 WS-CX1                 BINARY-LONG.
 01 WS-CZ0                 BINARY-LONG.
 01 WS-CZ1                 BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-ENT                 BINARY-LONG.
 01 WS-DUP                 BINARY-LONG.
 01 WS-TROW                BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-EXP-X               BINARY-LONG.
 01 WS-EXP-Y               BINARY-LONG.
 01 WS-EXP-Z               BINARY-LONG.
 01 WS-HITS                BINARY-LONG.
 01 WS-OTHERS              BINARY-LONG.
 01 WS-TREASURES           BINARY-LONG.
 01 WS-BASINS              BINARY-LONG.
 01 WS-PIECE               BINARY-LONG.
 01 WS-BAD-SEED            BINARY-LONG.
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
         MOVE "acceptance US12 36-8§15.4 C. The magma cube spawner: no generated packs here, skipped" TO TL-CASE
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
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-BASTION
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     IF WS-ROW = 0
         MOVE "acceptance US12 36-8§15.4 C. The magma cube spawner: the bastion is loaded" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 0 TO WS-LAVA WS-TREASURES WS-BASINS WS-BAD-SEED WS-OTHERS
     MOVE 0 TO WS-SEEN-V(1) WS-SEEN-V(2) WS-SEEN-V(3) WS-SEEN-V(4)
     PERFORM VARYING WS-SX FROM 0 BY 1 UNTIL WS-SX > 600 OR WS-BASINS >= 4
         PERFORM VARYING WS-SZ FROM 0 BY 1 UNTIL WS-SZ > 600 OR WS-BASINS >= 4
             MOVE 1 TO SDM-KIND
             CALL "NETHER-STRUCTURE-CANDIDATE" USING WS-SEED WS-SET WS-SX WS-SZ WS-CAND-X WS-CAND-Z WS-FLAG
             IF WS-FLAG = 1
                 CALL "NETHER-STRUCTURE-PICK" USING WS-SEED WS-SET WS-SX WS-SZ WS-VALID WS-PICKED
                 IF WS-PICKED = 2
                     CALL "STRUCT-FIND-POINT" USING WS-ROW WS-SEED WS-SX WS-SZ WS-PX WS-PY WS-PZ WS-PV
                     IF WS-PV = 1
                         ADD 1 TO WS-TREASURES
                         MOVE 0 TO WS-LAVA
                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
                             MOVE JE-LOC(SP-F1(WS-I)) TO WS-LOC
                             IF WS-LOC = "minecraft:bastion/treasure/bases/lava_basin"
                                 MOVE WS-I TO WS-LAVA
                             END-IF
                         END-PERFORM
                         IF WS-LAVA > 0
                             PERFORM CHECK-BASIN
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO SDM-KIND
     DISPLAY "PROBE treasure starts scanned " WS-TREASURES " lava basins " WS-BASINS " bad " WS-OTHERS
     MOVE "acceptance US12 36-8§15.4 C. The magma cube spawner: treasure starts with a lava_basin piece were found for all four rotations" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF WS-SEEN-V(WS-I) > 0
             ADD 1 TO TL-OBSERVED-N
         END-IF
     END-PERFORM
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§15.4 C. The magma cube spawner: every lava basin's chunks publish exactly one magma cube spawner, at the template cell (11, 7, 19) turned and moved, and no other spawner" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OTHERS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 CHECK-BASIN.
*>   the spawner's cell: the template cell (11, 7, 19) turned by the rotation at the piece's position (the pivot is the origin)
     MOVE WS-LAVA TO WS-PIECE
     ADD 1 TO WS-BASINS
     COMPUTE WS-I = SP-T-ROT(WS-PIECE) + 1
     ADD 1 TO WS-SEEN-V(WS-I)
     IF WS-SEEN-V(WS-I) > 1
         SUBTRACT 1 FROM WS-BASINS
     END-IF
     EVALUATE SP-T-ROT(WS-PIECE)
         WHEN 0
             COMPUTE WS-EXP-X = SP-T-X(WS-PIECE) + 11
             COMPUTE WS-EXP-Z = SP-T-Z(WS-PIECE) + 19
         WHEN 1
             COMPUTE WS-EXP-X = SP-T-X(WS-PIECE) - 19
             COMPUTE WS-EXP-Z = SP-T-Z(WS-PIECE) + 11
         WHEN 2
             COMPUTE WS-EXP-X = SP-T-X(WS-PIECE) - 11
             COMPUTE WS-EXP-Z = SP-T-Z(WS-PIECE) - 19
         WHEN OTHER
             COMPUTE WS-EXP-X = SP-T-X(WS-PIECE) + 19
             COMPUTE WS-EXP-Z = SP-T-Z(WS-PIECE) - 11
     END-EVALUATE
     COMPUTE WS-EXP-Y = SP-T-Y(WS-PIECE) + 7
     COMPUTE WS-CX0 = FUNCTION INTEGER(SP-X0(WS-PIECE) / 16)
     COMPUTE WS-CX1 = FUNCTION INTEGER(SP-X1(WS-PIECE) / 16)
     COMPUTE WS-CZ0 = FUNCTION INTEGER(SP-Z0(WS-PIECE) / 16)
     COMPUTE WS-CZ1 = FUNCTION INTEGER(SP-Z1(WS-PIECE) / 16)
     MOVE 0 TO WS-HITS
     MOVE 0 TO SDM-KIND
     PERFORM VARYING WS-CCX FROM WS-CX0 BY 1 UNTIL WS-CCX > WS-CX1
         PERFORM VARYING WS-CCZ FROM WS-CZ0 BY 1 UNTIL WS-CCZ > WS-CZ1
             MOVE LOW-VALUES TO CE-CHUNK
             CALL "NETHER-DIM-CHUNK" USING WS-CCX WS-CCZ CE-CHUNK WS-MARKER
             PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > GB-COUNT
                 IF GB-KIND(WS-E) = 2
                     IF GB-X(WS-E) = WS-EXP-X AND GB-Y(WS-E) = WS-EXP-Y AND GB-Z(WS-E) = WS-EXP-Z AND GB-TEXT(WS-E) = "minecraft:magma_cube"
                         ADD 1 TO WS-HITS
                     ELSE
                         ADD 1 TO WS-OTHERS
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-HITS NOT = 1
         ADD 1 TO WS-OTHERS
     END-IF
     EXIT PARAGRAPH.
 END PROGRAM TEST-STRUCT-36-8-15.

 COPY NOSPAWN.
 COPY CORETEST.
