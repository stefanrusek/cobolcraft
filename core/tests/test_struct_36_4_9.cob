*> Section test of 36-structures-4-scattered-and-small.md section 9 (nether fossil; core/src/struct-fossil.cob) over the generated vanilla-data (CC_GENERATED_DIR, read only; skipped as a pass
*> without it). Expectations from the document: the fourteen templates (sizes and bone block counts of 37-nether-5 section 6), the base column and the scan of 9.1 (the columns of 37-2 section 12.4
*> at world seed 0, the V11 rule, lava under air is not a support, no start at or below the sea level 32), the draws of 9.1 against a model written from the text over a chunk filled by NETHER-FILL,
*> the piece of 9.2 (box of the four rotations, STRUCTURE_AND_AIR leaves the terrain where the template has air, the template is written across two windows), and the dried ghast of 9.3 (the
*> 50 percent gate, the position and rotation from the stream of the world seed's positional factory at the box centre, only into an air cell inside the window).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-4-9.
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
 COPY NETHER.
 COPY GENBE.
 COPY STRUCTPROC.
 COPY FEATLEVEL.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-PTR                 USAGE POINTER.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-TPL                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-COLUMN              PIC X(128).
 01 WS-MODEL               PIC X(128).
 01 WS-SEA                 BINARY-LONG VALUE 32.
 01 WS-ID                  PIC X(96).
 01 WS-NUM                 PIC 99.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BONES               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ED                  PIC -(5)9.
 01 WS-ED2                 PIC -(5)9.
 01 WS-ED3                 PIC -(5)9.
 01 WS-MIN-Y               BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 128.
 01 WS-NETHERRACK          BINARY-LONG.
 01 WS-STONE-KEY           PIC X(112) VALUE "netherrack".
 01 WS-NO-PROPS            PIC X(600) VALUE SPACES.
 01 WS-BONE-KEY            PIC X(112) VALUE "bone_block".
 01 WS-RACK                BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-PROC-KEY            PIC X(80).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ZERO3               BINARY-LONG VALUE 0.
 01 WS-ZERO4               BINARY-LONG VALUE 0.
 01 WS-ZERO5               BINARY-LONG VALUE 0.
 01 WS-ZERO6               BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG VALUE 0.
 01 WS-PIECE               BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-CHUNK-PTR           USAGE POINTER.
 01 WS-VX                  BINARY-LONG.
 01 WS-VY                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-VROT                BINARY-LONG.
 01 WS-VTPL                BINARY-LONG.
 01 WS-VVALID              BINARY-LONG.
 01 WS-STARTS              BINARY-LONG.
 01 WS-NONE                BINARY-LONG.
 01 WS-A                   PIC X.
 01 WS-B                   PIC X.
 01 WS-DONE                BINARY-LONG.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-MX0                 BINARY-LONG.
 01 WS-MY0                 BINARY-LONG.
 01 WS-MZ0                 BINARY-LONG.
 01 WS-MX1                 BINARY-LONG.
 01 WS-MY1                 BINARY-LONG.
 01 WS-MZ1                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-U                   FLOAT-LONG.
 01 WS-GSEED               BINARY-DOUBLE.
 01 WS-STATE-R             BINARY-DOUBLE UNSIGNED.
 01 WS-FACTORY             BINARY-DOUBLE UNSIGNED.
 01 WS-POSSEED             BINARY-DOUBLE UNSIGNED.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-GROT                BINARY-LONG.
 01 WS-WANT-GHAST          BINARY-LONG.
 01 WS-GHASTS              BINARY-LONG.
 01 WS-GATED               BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-BONE-CELL           BINARY-LONG.
 01 WS-OUTSIDE             BINARY-LONG.
 01 WS-MISMATCH            BINARY-LONG.
 01 WS-FOUND-X             BINARY-LONG.
 01 WS-FOUND-Z             BINARY-LONG.
 01 WS-FACING              PIC X(8).
 01 WS-WANT-FACING         PIC X(8).
 01 WS-TEXT                PIC X(32).
 01 WS-PROP                PIC X(24).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FCX                 BINARY-LONG.
 01 WS-FCZ                 BINARY-LONG.
 01 WS-WCX                 BINARY-LONG VALUE 0.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SAVE-DIR            PIC X(1100).
 01 WS-SAVE-SEED           BINARY-DOUBLE.
 01 WS-SW-X0               BINARY-LONG.
 01 WS-SW-X1               BINARY-LONG.
*> doc 37-5 section 6: sizes x, y, z and bone block counts of fossil_1 to fossil_14
 01 WS-TABLE.
    05 FILLER PIC X(8) VALUE "04040510".
    05 FILLER PIC X(8) VALUE "05010510".
    05 FILLER PIC X(8) VALUE "03040206".
    05 FILLER PIC X(8) VALUE "03040106".
    05 FILLER PIC X(8) VALUE "02050105".
    05 FILLER PIC X(8) VALUE "07050521".
    05 FILLER PIC X(8) VALUE "04060518".
    05 FILLER PIC X(8) VALUE "03050106".
    05 FILLER PIC X(8) VALUE "03050515".
    05 FILLER PIC X(8) VALUE "03070108".
    05 FILLER PIC X(8) VALUE "05050724".
    05 FILLER PIC X(8) VALUE "04040311".
    05 FILLER PIC X(8) VALUE "04050617".
    05 FILLER PIC X(8) VALUE "07070626".
 01 WS-TABLE-T REDEFINES WS-TABLE.
    05 WS-T OCCURS 14 TIMES.
       10 T-SX             PIC 99.
       10 T-SY             PIC 99.
       10 T-SZ             PIC 99.
       10 T-BONES          PIC 99.
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
         MOVE "acceptance US12 36-4§9 Nether fossil: no generated packs here, skipped" TO TL-CASE
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
     CALL "GEN-WORLD-SETUP"
     PERFORM TEMPLATE-CASES
     PERFORM COLUMN-CASES
     PERFORM SCAN-CASES
     PERFORM START-CASES
     PERFORM BOX-CASES
     PERFORM PLACE-CASES
     PERFORM GHAST-CASES
     PERFORM ABSENT-CASE
     STOP RUN.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the template id of the number WS-I into WS-ID
 TEMPLATE-ID.
     MOVE WS-I TO WS-NUM
     MOVE SPACES TO WS-ID
     IF WS-I < 10
         STRING "minecraft:nether_fossils/fossil_" WS-NUM(2:1) DELIMITED BY SIZE INTO WS-ID
     ELSE
         STRING "minecraft:nether_fossils/fossil_" WS-NUM DELIMITED BY SIZE INTO WS-ID
     END-IF.

*> 9.2 and 37-5 section 6: the fourteen templates exist with the table's sizes and bone block counts, and the file holds nothing else but bone blocks and air
 TEMPLATE-CASES.
     MOVE 0 TO WS-N
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 14
         PERFORM TEMPLATE-ID
         CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
         MOVE 0 TO WS-BONES
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > TP-BLOCKS(WS-ROW)
             MOVE TB-STATE(TP-BASE(WS-ROW, 1) + WS-K) TO WS-STATE
             IF WS-STATE NOT = 0
                 CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                 IF CB-KEY(WS-BLOCK) = "bone_block"
                     ADD 1 TO WS-BONES
                 ELSE
                     ADD 1 TO WS-COUNT
                 END-IF
             END-IF
         END-PERFORM
         IF TP-STATUS(WS-ROW) = 1 AND TP-SX(WS-ROW) = T-SX(WS-I) AND TP-SY(WS-ROW) = T-SY(WS-I) AND TP-SZ(WS-ROW) = T-SZ(WS-I)
             ADD 1 TO WS-N
         END-IF
         MOVE WS-I TO WS-ED
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§9.2 Nether fossil: fossil_" FUNCTION TRIM(WS-ED) " has " T-BONES(WS-I) " bone blocks" DELIMITED BY SIZE INTO TL-CASE
         MOVE T-BONES(WS-I) TO TL-EXPECTED-N
         MOVE WS-BONES TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "acceptance US12 36-4§9.2 Nether fossil: the fourteen templates have the table's sizes" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§9.2 Nether fossil: no template holds a block that is neither bone block nor air" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> 9.1 step 3: the base column at world seed 0, chunk (0,0): column (0,0) is solid 0 to 75, air 76 to 94, solid 95 to 127; column (5,2) has air 76 to 95 (37-2 section 12.4)
 COLUMN-CASES.
     MOVE 0 TO WS-CX WS-CZ WS-LX WS-LZ
     CALL "NFOS-BASE-COLUMN" USING WS-SEED WS-CX WS-CZ WS-LX WS-LZ WS-COLUMN
     MOVE ALL "N" TO WS-MODEL
     MOVE ALL "A" TO WS-MODEL(77:19)
     MOVE "acceptance US12 36-4§9.1 Nether fossil: the base column (0,0) of world seed 0 is netherrack 0..75, air 76..94, netherrack 95..127" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-COLUMN(1:76) = WS-MODEL(1:76) AND WS-COLUMN(77:19) = ALL "A" AND WS-COLUMN(96:33) = WS-MODEL(96:33)
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE 5 TO WS-LX
     MOVE 2 TO WS-LZ
     CALL "NFOS-BASE-COLUMN" USING WS-SEED WS-CX WS-CZ WS-LX WS-LZ WS-COLUMN
     MOVE "acceptance US12 36-4§9.1 Nether fossil: the base column (5,2) of world seed 0 has air 76..95 over netherrack and under netherrack" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-COLUMN(1:76) = WS-MODEL(1:76) AND WS-COLUMN(77:20) = ALL "A" AND WS-COLUMN(97:32) = WS-MODEL(1:32)
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE CW-SEED TO WS-GSEED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         COMPUTE WS-CX = WS-K - 3
         COMPUTE WS-CZ = 2 * WS-K - 5
         COMPUTE WS-LX = FUNCTION MOD(WS-K * 7, 16)
         COMPUTE WS-LZ = FUNCTION MOD(WS-K * 5 + 3, 16)
         CALL "NFOS-BASE-COLUMN" USING WS-GSEED WS-CX WS-CZ WS-LX WS-LZ WS-COLUMN
         PERFORM MODEL-COLUMN
         MOVE WS-K TO WS-ED
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§9.1 Nether fossil: base column case " FUNCTION TRIM(WS-ED) " equals the column of the filled chunk (netherrack, lava below 32, air)" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-COLUMN = WS-MODEL
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
     END-PERFORM.

*> WS-MODEL: the column (WS-LX, WS-LZ) of the chunk (WS-CX, WS-CZ) as NETHER-FILL makes it (the density grid and the fill of 37-2), as letters
 MODEL-COLUMN.
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-CHUNK-PTR
     CALL "NETHER-SETUP" USING WS-GSEED
     CALL "NETHER-STATES"
     CALL "NETHER-CORNERS" USING WS-CX WS-CZ
     SET ADDRESS OF CE-CHUNK TO WS-CHUNK-PTR
     CALL "NETHER-FILL" USING CE-CHUNK
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 127
         COMPUTE WS-I = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
         EVALUATE TRUE
             WHEN CE-STATE(WS-I) = NH-S-NETHERRACK
                 MOVE "N" TO WS-MODEL(WS-Y + 1:1)
             WHEN CE-STATE(WS-I) = NH-S-LAVA
                 MOVE "L" TO WS-MODEL(WS-Y + 1:1)
             WHEN OTHER
                 MOVE "A" TO WS-MODEL(WS-Y + 1:1)
         END-EVALUATE
     END-PERFORM
     FREE WS-CHUNK-PTR.

*> 9.1 step 4: the scan over the 12.4 columns and over crafted ones
 SCAN-CASES.
     MOVE 0 TO WS-CX WS-CZ WS-LX WS-LZ
     CALL "NFOS-BASE-COLUMN" USING WS-SEED WS-CX WS-CZ WS-LX WS-LZ WS-COLUMN
     MOVE 120 TO WS-Y
     CALL "NFOS-SCAN" USING WS-COLUMN WS-Y WS-SEA
     MOVE "acceptance US12 36-4§9.1 Nether fossil: from y 120 down the first air over solid in column (0,0) is the support block y 75" TO TL-CASE
     MOVE 75 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 90 TO WS-Y
     CALL "NFOS-SCAN" USING WS-COLUMN WS-Y WS-SEA
     MOVE "acceptance US12 36-4§9.1 Nether fossil: from y 90, inside the cave, the answer is y 75 as well" TO TL-CASE
     MOVE 75 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 60 TO WS-Y
     CALL "NFOS-SCAN" USING WS-COLUMN WS-Y WS-SEA
     MOVE "acceptance US12 36-4§9.1 Nether fossil: from y 60, in solid rock down to the sea level, the scan ends at 32 and there is no start" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   V11: y starts at 40, an air cell over soul sand at y 35
     MOVE ALL "N" TO WS-COLUMN
     MOVE ALL "A" TO WS-COLUMN(37:5)
     MOVE "S" TO WS-COLUMN(36:1)
     MOVE 40 TO WS-Y
     CALL "NFOS-SCAN" USING WS-COLUMN WS-Y WS-SEA
     MOVE "acceptance US12 36-4§9.1 Nether fossil: V11, from y 40 an air cell over soul sand at y 35 gives y 35" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   air over lava is not a support: the scan goes on to the netherrack below the lava
     MOVE ALL "N" TO WS-COLUMN
     MOVE ALL "A" TO WS-COLUMN(51:30)
     MOVE ALL "L" TO WS-COLUMN(46:5)
     MOVE 70 TO WS-Y
     CALL "NFOS-SCAN" USING WS-COLUMN WS-Y WS-SEA
     MOVE "acceptance US12 36-4§9.1 Nether fossil: air over lava is no support, the scan passes the lava to the netherrack under it (air above it is not a pair)" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a start at the sea level gets no loop at all
     MOVE ALL "A" TO WS-COLUMN
     MOVE "N" TO WS-COLUMN(32:1)
     MOVE 32 TO WS-Y
     CALL "NFOS-SCAN" USING WS-COLUMN WS-Y WS-SEA
     MOVE "acceptance US12 36-4§9.1 Nether fossil: a sampled y at the sea level 32 is not scanned and stays 32 (no start)" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the pair at the bottom of the range: air at 33 over netherrack at 32 ends the loop at y 32, which is no start
     MOVE ALL "N" TO WS-COLUMN
     MOVE ALL "A" TO WS-COLUMN(34:5)
     MOVE 36 TO WS-Y
     CALL "NFOS-SCAN" USING WS-COLUMN WS-Y WS-SEA
     MOVE "acceptance US12 36-4§9.1 Nether fossil: an air cell at 33 over netherrack at 32 ends at y 32, not above the sea level" TO TL-CASE
     MOVE 32 TO TL-EXPECTED-N
     MOVE WS-Y TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> the start of the chunk (WS-CX, WS-CZ) written from the text of 9.1 with the base column of a filled chunk: WS-VVALID, WS-VX, WS-VY, WS-VZ, WS-VROT, WS-VTPL
 MODEL-START.
     COMPUTE WS-USEED = FUNCTION MOD(WS-GSEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-RNG WS-USEED WS-CX WS-CZ
     MOVE 16 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
     COMPUTE WS-VX = WS-CX * 16 + WS-DRAW
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
     COMPUTE WS-VZ = WS-CZ * 16 + WS-DRAW
     MOVE 94 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
     COMPUTE WS-VY = 32 + WS-DRAW
     COMPUTE WS-LX = WS-VX - WS-CX * 16
     COMPUTE WS-LZ = WS-VZ - WS-CZ * 16
     PERFORM MODEL-COLUMN
     PERFORM UNTIL WS-VY <= 32
         MOVE WS-MODEL(WS-VY + 1:1) TO WS-A
         SUBTRACT 1 FROM WS-VY
         MOVE WS-MODEL(WS-VY + 1:1) TO WS-B
         IF WS-A = "A" AND WS-B = "N"
             EXIT PERFORM
         END-IF
     END-PERFORM
     MOVE 0 TO WS-VVALID
     IF WS-VY > 32
         MOVE 1 TO WS-VVALID
         MOVE 4 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-VROT
         MOVE 14 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
         COMPUTE WS-VTPL = WS-DRAW + 1
     END-IF.

*> 9.1 steps 1 to 5 over a 5 x 5 block of chunks at the level seed: the start, the rotation and the template are the model's
 START-CASES.
     MOVE CW-SEED TO WS-GSEED
     MOVE 0 TO WS-STARTS WS-NONE WS-MISMATCH WS-FOUND
     PERFORM VARYING WS-CX FROM -2 BY 1 UNTIL WS-CX > 2
         PERFORM VARYING WS-CZ FROM -2 BY 1 UNTIL WS-CZ > 2
             PERFORM MODEL-START
             CALL "NFOS-FIND-POINT" USING WS-GSEED WS-CX WS-CZ WS-X WS-Y WS-Z WS-VALID WS-ROT WS-TPL
             IF WS-VALID NOT = WS-VVALID
                 ADD 1 TO WS-MISMATCH
             ELSE
                 IF WS-VALID = 1
                     ADD 1 TO WS-STARTS
                     IF WS-X NOT = WS-VX OR WS-Y NOT = WS-VY OR WS-Z NOT = WS-VZ OR WS-ROT NOT = WS-VROT OR WS-TPL NOT = WS-VTPL
                         ADD 1 TO WS-MISMATCH
                     END-IF
                     IF WS-FOUND = 0
                         MOVE 1 TO WS-FOUND
                         MOVE WS-CX TO WS-FCX
                         MOVE WS-CZ TO WS-FCZ
                     END-IF
                 ELSE
                     ADD 1 TO WS-NONE
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-4§9.1 Nether fossil: 25 chunks give the model's start (x, y of the support block, z, rotation, template) or none, in agreement" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MISMATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§9.1 Nether fossil: some of the 25 chunks have a start" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-STARTS > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "acceptance US12 36-4§9.1 Nether fossil: some of the 25 chunks have none (the scan ended at or below the sea level)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-NONE > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   the first chunk with a start: one piece with the drawn template, position, rotation, mirror none and the STRUCTURE_AND_AIR list
     CALL "NFOS-FIND-POINT" USING WS-GSEED WS-FCX WS-FCZ WS-X WS-Y WS-Z WS-VALID WS-ROT WS-TPL
     MOVE WS-TPL TO WS-I
     PERFORM TEMPLATE-ID
     MOVE SP-T-ROW(1) TO WS-ROW
     MOVE 0 TO WS-FLAG
     IF SP-COUNT = 1 AND TP-KEY(WS-ROW) = WS-ID AND SP-T-X(1) = WS-X AND SP-T-Y(1) = WS-Y AND SP-T-Z(1) = WS-Z
        AND SP-T-ROT(1) = WS-ROT AND SP-T-MIR(1) = 0 AND SPL-KEY(SP-T-PROC(1)) = "cobolcraft:inline/ignore_structure_and_air"
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance US12 36-4§9.2 Nether fossil: the start holds one piece with the drawn template, position, rotation, mirror none and the STRUCTURE_AND_AIR list" TO TL-CASE
     PERFORM CHECK.

*> a piece of fossil_6 (7 x 5 x 5) at (100, 60, 200) in each rotation: the box of 36-6 section 2.2 with the pivot at zero, moved by the position
 BOX-CASES.
     MOVE "minecraft:nether_fossils/fossil_6" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     MOVE "cobolcraft:inline/ignore_structure_and_air" TO WS-PROC-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-PROC-KEY WS-LIST
     PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
         CALL "SPB-RESET"
         MOVE 100 TO WS-OX
         MOVE 60 TO WS-OY
         MOVE 200 TO WS-OZ
         CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-ROW WS-OX WS-OY WS-OZ WS-ROT WS-ZERO WS-ZERO2 WS-ZERO3 WS-ZERO4 WS-LIST WS-ZERO5 WS-ZERO6 WS-PIECE
         EVALUATE WS-ROT
             WHEN 0
                 MOVE 100 TO WS-MX0
                 MOVE 106 TO WS-MX1
                 MOVE 200 TO WS-MZ0
                 MOVE 204 TO WS-MZ1
             WHEN 1
                 MOVE 96 TO WS-MX0
                 MOVE 100 TO WS-MX1
                 MOVE 200 TO WS-MZ0
                 MOVE 206 TO WS-MZ1
             WHEN 2
                 MOVE 94 TO WS-MX0
                 MOVE 100 TO WS-MX1
                 MOVE 196 TO WS-MZ0
                 MOVE 200 TO WS-MZ1
             WHEN OTHER
                 MOVE 100 TO WS-MX0
                 MOVE 104 TO WS-MX1
                 MOVE 194 TO WS-MZ0
                 MOVE 200 TO WS-MZ1
         END-EVALUATE
         MOVE WS-ROT TO WS-ED
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§9.2 Nether fossil: the box of fossil_6 at (100,60,200) with rotation " FUNCTION TRIM(WS-ED) " is the transformed footprint, y 60 to 64" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO WS-FLAG
         IF WS-PIECE = 1 AND SP-X0(1) = WS-MX0 AND SP-X1(1) = WS-MX1 AND SP-Z0(1) = WS-MZ0 AND SP-Z1(1) = WS-MZ1 AND SP-Y0(1) = 60 AND SP-Y1(1) = 64
             MOVE 1 TO WS-FLAG
         END-IF
         PERFORM CHECK
     END-PERFORM.

*> a window of chunk (WS-WCX, 0) of nether height, empty (air)
 NEW-WINDOW.
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FL-OPEN" USING WS-PTR WS-WCX WS-ZERO WS-MIN-Y WS-HEIGHT WS-SEA
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 0 TO GBL-COUNT GBL-LOST
     CALL "MSP-OPEN".

*> netherrack in the cells y 55 to 70 of the whole window
 FILL-WINDOW.
     PERFORM VARYING WS-Y FROM 55 BY 1 UNTIL WS-Y > 70
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
             COMPUTE WS-J = WS-Y * 256 + WS-I
             MOVE WS-RACK TO CE-STATE(WS-J)
         END-PERFORM
     END-PERFORM.

*> counts of the window: WS-BONES bone blocks, WS-COUNT netherrack cells within the box WS-MX0..WS-MX1 x 60..63 x WS-MZ0..WS-MZ1 are made by the caller
 COUNT-BONES.
     MOVE 0 TO WS-BONES
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 256 * 128
         IF CE-STATE(WS-J) NOT = 0
             MOVE CE-STATE(WS-J) TO WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF CB-KEY(WS-BLOCK) = "bone_block"
                 ADD 1 TO WS-BONES
             END-IF
         END-IF
     END-PERFORM.

*> 9.2: the template is placed with STRUCTURE_AND_AIR: fossil_1 (10 bone blocks of 80 cells) in each rotation over solid netherrack writes 10 bone blocks and the other cells of its box keep their netherrack
 PLACE-CASES.
     MOVE "netherrack" TO WS-STONE-KEY
     CALL "STRUCT-TPL-STATE" USING WS-STONE-KEY WS-NO-PROPS WS-RACK
     MOVE "minecraft:nether_fossils/fossil_1" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     MOVE "cobolcraft:inline/ignore_structure_and_air" TO WS-PROC-KEY
     CALL "STRUCT-PROC-LOAD" USING WS-PROC-KEY WS-LIST
     MOVE 0 TO WS-WCX
     PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
         PERFORM NEW-WINDOW
         PERFORM FILL-WINDOW
         CALL "SPB-RESET"
         MOVE 8 TO WS-OX
         MOVE 60 TO WS-OY
         MOVE 8 TO WS-OZ
         MOVE 5 TO SP-SEED
         CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-ROW WS-OX WS-OY WS-OZ WS-ROT WS-ZERO WS-ZERO2 WS-ZERO3 WS-ZERO4 WS-LIST WS-ZERO5 WS-ZERO6 WS-PIECE
         CALL "MSP-OPEN"
         CALL "NFOS-POST" USING WS-PIECE
         PERFORM COUNT-BONES
         MOVE WS-ROT TO WS-ED
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§9.2 Nether fossil: fossil_1 with rotation " FUNCTION TRIM(WS-ED) " writes its 10 bone blocks" DELIMITED BY SIZE INTO TL-CASE
         MOVE 10 TO TL-EXPECTED-N
         MOVE WS-BONES TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-Y FROM 55 BY 1 UNTIL WS-Y > 70
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
                 COMPUTE WS-J = WS-Y * 256 + WS-I
                 IF CE-STATE(WS-J) = WS-RACK
                     ADD 1 TO WS-COUNT
                 END-IF
             END-PERFORM
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-4§9.2 Nether fossil: with rotation " FUNCTION TRIM(WS-ED) " the template's air does not carve: all other netherrack cells stay" DELIMITED BY SIZE INTO TL-CASE
         COMPUTE TL-EXPECTED-N = 16 * 256 - 10
         MOVE WS-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   across two windows: fossil_6 (21 bone blocks) at (14, 60, 6) is written part by part, 21 in all
     MOVE "minecraft:nether_fossils/fossil_6" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     MOVE 0 TO WS-N
     PERFORM VARYING WS-WCX FROM 0 BY 1 UNTIL WS-WCX > 1
         PERFORM NEW-WINDOW
         PERFORM FILL-WINDOW
         CALL "SPB-RESET"
         MOVE 14 TO WS-OX
         MOVE 60 TO WS-OY
         MOVE 6 TO WS-OZ
         MOVE 0 TO WS-ROT
         MOVE 5 TO SP-SEED
         CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-ROW WS-OX WS-OY WS-OZ WS-ROT WS-ZERO WS-ZERO2 WS-ZERO3 WS-ZERO4 WS-LIST WS-ZERO5 WS-ZERO6 WS-PIECE
         CALL "MSP-OPEN"
         CALL "NFOS-POST" USING WS-PIECE
         PERFORM COUNT-BONES
         ADD WS-BONES TO WS-N
     END-PERFORM
     MOVE "acceptance US12 36-4§9.2 Nether fossil: fossil_6 across the border of two windows is written in full by the two passes (21 bone blocks)" TO TL-CASE
     MOVE 21 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-WCX.

*> 9.3: fossil_2 (5 x 1 x 5, 10 bone blocks) at (12, 60, 4) over air in the window of chunk (0, 0), for 200 level seeds: the gate, the position and the rotation of the model written from the text
 GHAST-CASES.
     MOVE "minecraft:nether_fossils/fossil_2" TO WS-ID
     CALL "STRUCT-TPL-LOAD" USING SD-DIR WS-ID WS-ROW
     MOVE 0 TO WS-MISMATCH WS-GATED WS-PLACED WS-BONE-CELL WS-OUTSIDE WS-GHASTS
     MOVE 0 TO WS-WCX
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 200
         PERFORM NEW-WINDOW
         CALL "SPB-RESET"
         COMPUTE WS-OX = 8 + FUNCTION MOD(WS-K, 6)
         MOVE 60 TO WS-OY
         COMPUTE WS-OZ = 4 + FUNCTION MOD(WS-K, 3)
         MOVE 0 TO WS-ROT
         COMPUTE SP-SEED = 1000 + WS-K * 37
         CALL "STRUCT-TPL-PIECE-ADD" USING WS-KIND WS-ROW WS-OX WS-OY WS-OZ WS-ROT WS-ZERO WS-ZERO2 WS-ZERO3 WS-ZERO4 WS-LIST WS-ZERO5 WS-ZERO6 WS-PIECE
         CALL "MSP-OPEN"
         CALL "NFOS-POST" USING WS-PIECE
         PERFORM GHAST-MODEL
         PERFORM GHAST-FOUND
         IF WS-WANT-GHAST = 2
             ADD 1 TO WS-GATED
         END-IF
         IF WS-WANT-GHAST = 3
             ADD 1 TO WS-OUTSIDE
         END-IF
         IF WS-WANT-GHAST = 4
             ADD 1 TO WS-BONE-CELL
         END-IF
         IF WS-WANT-GHAST = 1
             ADD 1 TO WS-PLACED
         END-IF
         IF (WS-WANT-GHAST = 1 AND WS-GHASTS NOT = 1) OR (WS-WANT-GHAST NOT = 1 AND WS-GHASTS NOT = 0)
             ADD 1 TO WS-MISMATCH
         ELSE
             IF WS-WANT-GHAST = 1
                 IF WS-FOUND-X NOT = WS-GX OR WS-FOUND-Z NOT = WS-GZ OR WS-FACING NOT = WS-WANT-FACING
                     ADD 1 TO WS-MISMATCH
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-4§9.3 Nether fossil: 200 level seeds, the dried ghast is where the model puts it, facing as drawn, or absent" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MISMATCH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-4§9.3 Nether fossil: the gate closes for some level seeds (float 0.5 or more)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-GATED > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "acceptance US12 36-4§9.3 Nether fossil: the gate opens and the cell is air for some level seeds (a ghast is placed)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-PLACED > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "acceptance US12 36-4§9.3 Nether fossil: the gate opens and the drawn cell is a bone block for some level seeds (no ghast)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-BONE-CELL > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "acceptance US12 36-4§9.3 Nether fossil: the gate opens and the drawn cell is outside the window for some level seeds (the other window's ghast)" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-OUTSIDE > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.

*> the model of 9.3 for the piece WS-PIECE (box SP-*, level seed SP-SEED): WS-WANT-GHAST 1 a ghast at (WS-GX, WS-GY, WS-GZ) facing WS-WANT-FACING, 2 the gate is shut, 3 the cell is outside the window,
*> 4 the cell is a bone block (decided after the placement from the window)
 GHAST-MODEL.
     MOVE SP-X0(WS-PIECE) TO WS-MX0
     MOVE SP-Y0(WS-PIECE) TO WS-MY0
     MOVE SP-Z0(WS-PIECE) TO WS-MZ0
     MOVE SP-X1(WS-PIECE) TO WS-MX1
     MOVE SP-Y1(WS-PIECE) TO WS-MY1
     MOVE SP-Z1(WS-PIECE) TO WS-MZ1
*>   getCenter: min + (max - min + 1) / 2 per axis
     COMPUTE WS-PX = WS-MX0 + FUNCTION INTEGER((WS-MX1 - WS-MX0 + 1) / 2)
     COMPUTE WS-PY = WS-MY0 + FUNCTION INTEGER((WS-MY1 - WS-MY0 + 1) / 2)
     COMPUTE WS-PZ = WS-MZ0 + FUNCTION INTEGER((WS-MZ1 - WS-MZ0 + 1) / 2)
     COMPUTE WS-USEED = FUNCTION MOD(SP-SEED + WS-M64, WS-M64)
     CALL "JRAND-SET-SEED" USING WS-STATE-R WS-USEED
     CALL "JRAND-NEXT-LONG" USING WS-STATE-R WS-FACTORY
     CALL "XORO-GET-SEED" USING WS-PX WS-PY WS-PZ WS-GSEED
     COMPUTE WS-POSSEED = FUNCTION MOD(WS-GSEED + WS-M64, WS-M64)
     CALL "CBL_XOR" USING WS-FACTORY WS-POSSEED BY VALUE 8
     CALL "JRAND-SET-SEED" USING WS-STATE-R WS-POSSEED
     CALL "JRAND-NEXT-FLOAT" USING WS-STATE-R WS-U
     IF WS-U >= 0.5
         MOVE 2 TO WS-WANT-GHAST
     ELSE
         PERFORM GHAST-CELL
     END-IF.

 GHAST-CELL.
     COMPUTE WS-BOUND = WS-MX1 - WS-MX0 + 1
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE-R WS-BOUND WS-DRAW
     COMPUTE WS-GX = WS-MX0 + WS-DRAW
     MOVE WS-MY0 TO WS-GY
     COMPUTE WS-BOUND = WS-MZ1 - WS-MZ0 + 1
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE-R WS-BOUND WS-DRAW
     COMPUTE WS-GZ = WS-MZ0 + WS-DRAW
     IF WS-GX < 0 OR WS-GX > 15
         MOVE 3 TO WS-WANT-GHAST
     ELSE
         MOVE 4 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE-R WS-BOUND WS-GROT
         EVALUATE WS-GROT
             WHEN 0
                 MOVE "north" TO WS-WANT-FACING
             WHEN 1
                 MOVE "east" TO WS-WANT-FACING
             WHEN 2
                 MOVE "south" TO WS-WANT-FACING
             WHEN OTHER
                 MOVE "west" TO WS-WANT-FACING
         END-EVALUATE
         MOVE 1 TO WS-WANT-GHAST
         COMPUTE WS-J = WS-GY * 256 + WS-GZ * 16 + WS-GX + 1
         MOVE CE-STATE(WS-J) TO WS-STATE
         IF WS-STATE NOT = 0
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF CB-KEY(WS-BLOCK) = "bone_block"
                 MOVE 4 TO WS-WANT-GHAST
             END-IF
         END-IF
     END-IF.

*> the ghasts of the window: WS-GHASTS of them, the position of the last in WS-FOUND-X, WS-FOUND-Z, its facing in WS-FACING
 GHAST-FOUND.
     MOVE 0 TO WS-GHASTS
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 256 * 128
         IF CE-STATE(WS-J) NOT = 0
             MOVE CE-STATE(WS-J) TO WS-STATE
             CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
             IF CB-KEY(WS-BLOCK) = "dried_ghast"
                 ADD 1 TO WS-GHASTS
                 COMPUTE WS-I = WS-J - 1
                 COMPUTE WS-FOUND-X = FUNCTION MOD(WS-I, 16)
                 COMPUTE WS-FOUND-Z = FUNCTION MOD(FUNCTION INTEGER(WS-I / 16), 16)
                 MOVE "facing" TO WS-PROP
                 CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-PROP WS-TEXT WS-FLAG
                 MOVE WS-TEXT TO WS-FACING
             END-IF
         END-IF
     END-PERFORM.

*> no template file under the data folder: no piece and no start (the cache forgets what it loaded first)
 ABSENT-CASE.
     MOVE SD-DIR TO WS-SAVE-DIR
     CALL "STRUCT-TPL-RESET"
     MOVE "/nonexistent/folder" TO SD-DIR
     CALL "NFOS-FIND-POINT" USING WS-GSEED WS-FCX WS-FCZ WS-X WS-Y WS-Z WS-VALID WS-ROT WS-TPL
     MOVE WS-SAVE-DIR TO SD-DIR
     CALL "STRUCT-TPL-RESET"
     MOVE "acceptance US12 36-4§9.2 Nether fossil: with no template file the start has no piece and is not valid" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-VALID = 0 AND SP-COUNT = 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.
 END PROGRAM TEST-STRUCT-36-4-9.

 COPY NOSPAWN.
 COPY CORETEST.
