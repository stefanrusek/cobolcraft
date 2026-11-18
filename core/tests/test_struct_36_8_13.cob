*> Acceptance test of the bastion remnant on the jigsaw engine (docs/protocol/36-structures-8-nether-and-end.md sections 13 to 17; core/src/nether-struct.cob, struct-jig.cob; T13514): on the
*> generated vanilla-data (CC_GENERATED_DIR, read only; passes as skipped without it) the starts of the bastion in the Nether: the stub at y 33, the start piece with the template and the rotation
*> of the first two draws (13.2: 17.2 for every start: origin, box from the rotated template size, minimum y 32, stub at the centre), every piece of the start's own family or the shared mob
*> and block pools (14), the processor lists each variant uses (14, 16), the twelve named processor lists load (16), and the four variants occur.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-13.
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
         MOVE "acceptance US12 36-8§13 C. Bastion remnant: no generated packs here, skipped" TO TL-CASE
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
     COMPUTE WS-USEED = FUNCTION MOD(WS-SEED + WS-M64, WS-M64)
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SD-ST-COUNT
         IF SDT-KEY(WS-I) = WS-BASTION
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§13 C. Bastion remnant: use of the jigsaw engine: the structure is loaded from the data" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ROW > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-ROW = 0
         STOP RUN
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE 0 TO WS-SEEN-V(WS-K)
     END-PERFORM
*>   the starts of a stretch of the set's candidate chunks that pick the bastion
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 1 TO SDM-KIND
     PERFORM VARYING WS-SX FROM 0 BY 1 UNTIL WS-SX > 400 OR WS-STARTS >= 24
         PERFORM VARYING WS-SZ FROM 0 BY 1 UNTIL WS-SZ > 400 OR WS-STARTS >= 24
             CALL "NETHER-STRUCTURE-CANDIDATE" USING WS-SEED WS-SET WS-SX WS-SZ WS-CAND-X WS-CAND-Z WS-FLAG
             IF WS-FLAG = 1
                 CALL "NETHER-STRUCTURE-PICK" USING WS-SEED WS-SET WS-SX WS-SZ WS-VALID WS-PICKED
                 IF WS-PICKED = 2
                     PERFORM CHECK-START
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 0 TO SDM-KIND
     MOVE "acceptance US12 36-8§13 C. Bastion remnant: use of the jigsaw engine: 24 bastion starts were built" TO TL-CASE
     MOVE 24 TO TL-EXPECTED-N
     MOVE WS-STARTS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§13 C. Bastion remnant: use of the jigsaw engine: some picked starts are refused for their biome" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-REJECTED >= 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§13 C. Bastion remnant: use of the jigsaw engine: the stub is (centre x, 33, centre z) and the start box begins at y 32 with the rotated template size" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-STUB TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§13 C. Bastion remnant: use of the jigsaw engine: the start template is the second draw nextInt(4) after the rotation draw" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-DRAW TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§14 C. The four variants and their pool graphs: every piece is of the start's family or of the shared mob and block pools" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-FAMILY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§16 C. Processors: each variant uses only its own named lists (or none)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-PROC TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         IF WS-SEEN-V(WS-K) > 0
             ADD 1 TO WS-SUM
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§14 C. The four variants and their pool graphs: all four variants occur in 24 starts" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SUM >= 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§15 C. Mobs, blocks, spawner, loot: the chests of generated bastions carry one of the bastion loot tables" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-LOOT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§15 C. Mobs, blocks, spawner, loot: the chunks of four bastions publish chests, and any spawner is the magma cube's" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CHESTS >= 1 AND WS-BAD-SPAWNER = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     DISPLAY "PROBE bastion chests " WS-CHESTS " spawners " WS-SPAWNERS
*>   the bastion's mob templates hold 2 piglins, 2 piglin brutes and 1 hoglin (18.3 item 4): every distinct template of the mob pools reached by the starts
     MOVE 0 TO WS-ENT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > JE-COUNT
         MOVE JE-LOC(WS-I) TO WS-LOC
         IF WS-LOC(1:23) = "minecraft:bastion/mobs/"
             MOVE 0 TO WS-DUP
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-I
                 IF JE-LOC(WS-J) = WS-LOC
                     MOVE 1 TO WS-DUP
                 END-IF
             END-PERFORM
             IF WS-DUP = 0
                 CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-LOC WS-TROW
                 IF WS-TROW > 0
                     ADD TP-ENTITIES(WS-TROW) TO WS-ENT
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§15 C. Mobs, blocks, spawner, loot: the mob templates store 5 entities (2 piglins, 2 piglin brutes, 1 hoglin)" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-ENT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the twelve named processor lists load
     MOVE 0 TO WS-BADLOAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 12
         MOVE SPACES TO WS-PKEY
         STRING "minecraft:" FUNCTION TRIM(WS-PNAME(WS-K)) DELIMITED BY SIZE INTO WS-PKEY
         CALL "STRUCT-PROC-LOAD" USING WS-PKEY WS-PID
         IF WS-PID < 1
             ADD 1 TO WS-BADLOAD
             DISPLAY "PROBE processor list not loaded: " FUNCTION TRIM(WS-PKEY)
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§16 C. Processors: the twelve named processor lists load" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BADLOAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 CHECK-START.
*>   the two draws that open the start: the rotation, then the start element
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-RNG WS-USEED WS-SX WS-SZ
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-FOUR WS-ROT
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-FOUR WS-IDX
     COMPUTE WS-K = WS-IDX + 1
     ADD 1 TO WS-SEEN-V(WS-K)
     CALL "STRUCT-FIND-POINT" USING WS-ROW WS-SEED WS-SX WS-SZ WS-PX WS-PY WS-PZ WS-PV
*>   a start whose stub biome is not the structure's (the basalt deltas) is no structure (JIG-BIOME-OK)
     IF WS-PV NOT = 1
         ADD 1 TO WS-REJECTED
         EXIT PARAGRAPH
     END-IF
     ADD 1 TO WS-STARTS
*>   the expected start box: the origin (16 cx, 16 cz), the template's far corner turned about the origin
     MOVE WS-S-X(WS-K) TO WS-SXX
     MOVE WS-S-Y(WS-K) TO WS-SYY
     MOVE WS-S-Z(WS-K) TO WS-SZZ
     COMPUTE WS-X0 = WS-SX * 16
     COMPUTE WS-X1 = WS-X0 + WS-SXX - 1
     COMPUTE WS-Z0 = WS-SZ * 16
     COMPUTE WS-Z1 = WS-Z0 + WS-SZZ - 1
     EVALUATE WS-ROT
         WHEN 1
             COMPUTE WS-X1 = WS-X0
             COMPUTE WS-X0 = WS-X1 - WS-SZZ + 1
             COMPUTE WS-Z1 = WS-Z0 + WS-SXX - 1
         WHEN 2
             COMPUTE WS-X1 = WS-X0
             COMPUTE WS-X0 = WS-X1 - WS-SXX + 1
             COMPUTE WS-Z1 = WS-Z0
             COMPUTE WS-Z0 = WS-Z1 - WS-SZZ + 1
         WHEN 3
             COMPUTE WS-X1 = WS-X0 + WS-SZZ - 1
             COMPUTE WS-Z1 = WS-Z0
             COMPUTE WS-Z0 = WS-Z1 - WS-SXX + 1
     END-EVALUATE
     IF SP-X0(1) NOT = WS-X0 OR SP-X1(1) NOT = WS-X1 OR SP-Z0(1) NOT = WS-Z0 OR SP-Z1(1) NOT = WS-Z1 OR SP-Y0(1) NOT = 32
         OR SP-Y1(1) NOT = 31 + WS-SYY
         ADD 1 TO WS-BAD-STUB
     END-IF
     COMPUTE WS-SUM = WS-X0 + WS-X1
     DIVIDE 2 INTO WS-SUM GIVING WS-CEN-X
     COMPUTE WS-SUM = WS-Z0 + WS-Z1
     DIVIDE 2 INTO WS-SUM GIVING WS-CEN-Z
     IF WS-PX NOT = WS-CEN-X OR WS-PY NOT = 33 OR WS-PZ NOT = WS-CEN-Z
         ADD 1 TO WS-BAD-STUB
     END-IF
*>   the start element's template is the one the second draw chose: its box has the template size (no other template of the pool has it)
     IF (SP-X1(1) - SP-X0(1) + 1 NOT = WS-SXX AND SP-X1(1) - SP-X0(1) + 1 NOT = WS-SZZ) OR SP-Y1(1) - SP-Y0(1) + 1 NOT = WS-SYY
         ADD 1 TO WS-BAD-DRAW
     END-IF
*>   the chests and spawners the first four starts publish when their chunks are generated (15.4 and 15.5: the loot tables are the four of the bastion, a spawner is the magma cube's)
     IF WS-STARTS <= 4
         MOVE SDM-KIND TO WS-SDM-SAVE
         MOVE 0 TO SDM-KIND
         COMPUTE WS-CX0 = FUNCTION INTEGER(SP-X0(1) / 16)
         COMPUTE WS-CX1 = FUNCTION INTEGER(SP-X1(1) / 16)
         COMPUTE WS-CZ0 = FUNCTION INTEGER(SP-Z0(1) / 16)
         COMPUTE WS-CZ1 = FUNCTION INTEGER(SP-Z1(1) / 16)
         PERFORM VARYING WS-CCX FROM WS-CX0 BY 1 UNTIL WS-CCX > WS-CX1
             PERFORM VARYING WS-CCZ FROM WS-CZ0 BY 1 UNTIL WS-CCZ > WS-CZ1
                 MOVE LOW-VALUES TO CE-CHUNK
                 CALL "NETHER-DIM-CHUNK" USING WS-CCX WS-CCZ CE-CHUNK WS-MARKER
                 PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > GB-COUNT
                     IF GB-KIND(WS-E) = 1
                         ADD 1 TO WS-CHESTS
                         IF GB-LOOT(WS-E)(1:25) NOT = "minecraft:chests/bastion_"
                             ADD 1 TO WS-BAD-LOOT
                         END-IF
                     END-IF
                     IF GB-KIND(WS-E) = 2
                         ADD 1 TO WS-SPAWNERS
                         IF GB-TEXT(WS-E) NOT = "minecraft:magma_cube"
                             ADD 1 TO WS-BAD-SPAWNER
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         MOVE WS-SDM-SAVE TO SDM-KIND
         CALL "STRUCT-FIND-POINT" USING WS-ROW WS-SEED WS-SX WS-SZ WS-PX WS-PY WS-PZ WS-PV
     END-IF
*>   every piece: the family of the start or the mob and block pools; its processor list
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-FAMILY(WS-K))) TO WS-LEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SP-COUNT
         MOVE JE-LOC(SP-F1(WS-I)) TO WS-LOC
         IF WS-LOC NOT = SPACES
             IF WS-LOC(1:WS-LEN) NOT = WS-FAMILY(WS-K)(1:WS-LEN) AND WS-LOC(1:23) NOT = "minecraft:bastion/mobs/" AND WS-LOC(1:25) NOT = "minecraft:bastion/blocks/"
                 ADD 1 TO WS-BAD-FAMILY
                 DISPLAY "PROBE family " FUNCTION TRIM(WS-LOC)
             END-IF
         END-IF
         MOVE JE-PROC(SP-F1(WS-I)) TO WS-PROC
         IF WS-PROC NOT = SPACES
             MOVE 0 TO WS-OK
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 12
                 MOVE SPACES TO WS-PKEY
                 STRING "minecraft:" FUNCTION TRIM(WS-PNAME(WS-J)) DELIMITED BY SIZE INTO WS-PKEY
                 IF WS-PROC = WS-PKEY AND WS-ALLOW-ROW(WS-K)(WS-J:1) = "1"
                     MOVE 1 TO WS-OK
                 END-IF
             END-PERFORM
             IF WS-OK = 0
                 ADD 1 TO WS-BAD-PROC
                 DISPLAY "PROBE processor " FUNCTION TRIM(WS-PROC) " in variant " WS-K
             END-IF
         END-IF
     END-PERFORM
     EXIT PARAGRAPH.
 END PROGRAM TEST-STRUCT-36-8-13.

 COPY NOSPAWN.
 COPY CORETEST.
