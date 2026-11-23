*> Section test of 37-nether-2-noise-settings-and-density.md section 10 (the beardifier in the Nether; core/src/nether-37-2.cob NETHER-SOLID, NETHER-FILL, NETHER-FOSSIL-START, NETHER-BEARD-COLLECT,
*> NETHER-BEARD-CLEAR over the term programs of core/src/struct-36-1-9.cob and the sampler of core/src/struct-beard.cob; T1653, T1654). 10.5 is the oracle: the worked values of one nether fossil piece (box (100, 40, 200)
*> to (101, 44, 200), beard_thin, ground level delta 0) to 8 decimals (2e-8), the other three modes and the junction at (100, 39, 200), the kernel and beard values at the centre; the sign and reach of 10.3 (terrain is
*> added below the box's bottom, removed from it up, nothing 12 or more blocks away) on the fill of a real Nether chunk of world seed 0 with and without the record; the two block examples of 10.5's last paragraph. With the
*> generated packs (CC_GENERATED_DIR, read only; skipped as a pass without them) the records of a real nether_fossil start of world seed 12345 (10.1, 10.2): the one rigid record of a fossil within 2 chunks, a chunk far
*> from every start has none, and a Nether chunk made by NETHER-GEN-CHUNK leaves the records empty (the overworld shares them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-2-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CBLOCKS.
 COPY CELLS.
 COPY NETHER.
 COPY CORESTATE.
 COPY COREAPI.
 COPY STRUCTBEARD.
 COPY STRUCTPIECE.
 01 WS-SEED                BINARY-DOUBLE SIGNED VALUE 0.
 01 WS-GSEED               BINARY-DOUBLE.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-SCALED              BINARY-DOUBLE.
 01 WS-FLAG                BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-MARGIN              BINARY-LONG VALUE 12.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FCX                 BINARY-LONG.
 01 WS-FCZ                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-ADDED               BINARY-LONG.
 01 WS-REMOVED             BINARY-LONG.
 01 WS-OUTSIDE             BINARY-LONG.
 01 WS-WRONG-SIGN          BINARY-LONG.
 01 WS-DIFFERENT           BINARY-LONG.
 01 WS-SOLID-A             BINARY-LONG.
 01 WS-SOLID-B             BINARY-LONG.
 01 WS-GEN                 BINARY-LONG.
 01 WS-ED                  PIC -(4)9.
 01 WS-ROWNO               PIC 99.
 01 WS-MARKER              BINARY-LONG.
 01 WS-CHUNK-A             PIC X(304640).
 01 WS-CHUNK-B             PIC X(304640).
 01 WS-TABLE.
    05 WS-T-DY             BINARY-LONG OCCURS 10 TIMES.
    05 WS-T-X              BINARY-LONG OCCURS 10 TIMES.
    05 WS-T-Y              BINARY-LONG OCCURS 10 TIMES.
    05 WS-T-Z              BINARY-LONG OCCURS 10 TIMES.
    05 WS-T-V              FLOAT-LONG OCCURS 10 TIMES.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM WORKED-TABLE
     PERFORM OTHER-MODES
     PERFORM BLOCK-EXAMPLES
     PERFORM NETHER-TABLES
     CALL "NETHER-SETUP" USING WS-SEED
     PERFORM FILL-CASES
     PERFORM FOSSIL-CASES
     STOP RUN.

*> the record of 10.5: one fossil_5 piece, box (100, 40, 200) to (101, 44, 200), beard_thin (mode 2), ground level delta 0
 SET-FOSSIL-RECORD.
     MOVE 0 TO SBD-READY SBD-JUNC-COUNT SBD-LOST
     MOVE 1 TO SBD-RIGID-COUNT
     MOVE 2 TO SBR-MODE(1)
     MOVE 100 TO SBR-X0(1) SBD-AX0
     MOVE 40 TO SBR-Y0(1) SBD-AY0
     MOVE 200 TO SBR-Z0(1) SBD-AZ0
     MOVE 101 TO SBR-X1(1) SBD-AX1
     MOVE 44 TO SBR-Y1(1) SBD-AY1
     MOVE 200 TO SBR-Z1(1) SBD-AZ1
     MOVE 0 TO SBR-GROUND(1)
     MOVE 1 TO SBD-ACTIVE
     MOVE 6 TO SBD-CX
     MOVE 12 TO SBD-CZ.

*> WS-R against WS-V to 8 decimals: WS-FLAG 1 when they differ by at most 2e-8
 NEAR.
     COMPUTE WS-D = WS-R - WS-V
     IF WS-D < 0
         COMPUTE WS-D = 0 - WS-D
     END-IF
     COMPUTE WS-SCALED = WS-D * 100000000 + 0.5
     MOVE 0 TO WS-FLAG
     IF WS-SCALED <= 2
         MOVE 1 TO WS-FLAG
     END-IF.

 CHECK.
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 WORKED-TABLE.
     PERFORM SET-FOSSIL-RECORD
     MOVE 100 TO WS-T-X(1)
     MOVE 40 TO WS-T-Y(1)
     MOVE 200 TO WS-T-Z(1)
     MOVE -0.55677575 TO WS-T-V(1)
     MOVE 100 TO WS-T-X(2)
     MOVE 39 TO WS-T-Y(2)
     MOVE 200 TO WS-T-Z(2)
     MOVE 0.55677575 TO WS-T-V(2)
     MOVE 100 TO WS-T-X(3)
     MOVE 38 TO WS-T-Y(3)
     MOVE 200 TO WS-T-Z(3)
     MOVE 0.49142528 TO WS-T-V(3)
     MOVE 100 TO WS-T-X(4)
     MOVE 41 TO WS-T-Y(4)
     MOVE 200 TO WS-T-Z(4)
     MOVE -0.49142528 TO WS-T-V(4)
     MOVE 100 TO WS-T-X(5)
     MOVE 44 TO WS-T-Y(5)
     MOVE 200 TO WS-T-Z(5)
     MOVE -0.15928148 TO WS-T-V(5)
     MOVE 100 TO WS-T-X(6)
     MOVE 45 TO WS-T-Y(6)
     MOVE 200 TO WS-T-Z(6)
     MOVE -0.08525947 TO WS-T-V(6)
     MOVE 105 TO WS-T-X(7)
     MOVE 40 TO WS-T-Y(7)
     MOVE 200 TO WS-T-Z(7)
     MOVE -0.02540309 TO WS-T-V(7)
     MOVE 105 TO WS-T-X(8)
     MOVE 36 TO WS-T-Y(8)
     MOVE 203 TO WS-T-Z(8)
     MOVE 0.03162176 TO WS-T-V(8)
     MOVE 100 TO WS-T-X(9)
     MOVE 52 TO WS-T-Y(9)
     MOVE 200 TO WS-T-Z(9)
     MOVE 0 TO WS-T-V(9)
     MOVE 112 TO WS-T-X(10)
     MOVE 40 TO WS-T-Y(10)
     MOVE 200 TO WS-T-Z(10)
     MOVE -0.00001312 TO WS-T-V(10)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         MOVE WS-T-X(WS-I) TO WS-X
         MOVE WS-T-Y(WS-I) TO WS-Y
         MOVE WS-T-Z(WS-I) TO WS-Z
         CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-R
         MOVE WS-T-V(WS-I) TO WS-V
         PERFORM NEAR
         MOVE WS-I TO WS-ROWNO
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 worked table row " WS-ROWNO " the term of one beard_thin fossil record at the block equals the table value" DELIMITED BY SIZE INTO TL-CASE
         PERFORM CHECK
     END-PERFORM
     MOVE 12 TO WS-I
     MOVE 12 TO WS-J
     MOVE 12 TO WS-X
     CALL "STRUCT-BEARD-KERNEL" USING WS-I WS-J WS-X WS-R
     MOVE 0.98449641 TO WS-V
     PERFORM NEAR
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 the kernel at the centre cell (12, 12, 12) is 0.98449641" TO TL-CASE
     PERFORM CHECK
     MOVE 0 TO WS-I WS-J WS-X WS-Y
     CALL "STRUCT-BEARD" USING WS-I WS-J WS-X WS-Y WS-R
     MOVE -0.69596970 TO WS-V
     PERFORM NEAR
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 beard(0, 0, 0, 0) is -0.69596970" TO TL-CASE
     PERFORM CHECK.

*> the same box in the other modes at (100, 39, 200) and a junction at (0, 0, 0) (the jigsaw terms the Nether never uses, 10.4)
 OTHER-MODES.
     MOVE 100 TO WS-X
     MOVE 39 TO WS-Y
     MOVE 200 TO WS-Z
     MOVE 1 TO WS-I
     PERFORM RIGID-AT
     MOVE 0.91666669 TO WS-V
     PERFORM NEAR
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 bury at (100, 39, 200) is 0.91666669" TO TL-CASE
     PERFORM CHECK
     MOVE 3 TO WS-I
     PERFORM RIGID-AT
     MOVE 0.49135289 TO WS-V
     PERFORM NEAR
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 beard_box at (100, 39, 200) is 0.49135289" TO TL-CASE
     PERFORM CHECK
     MOVE 4 TO WS-I
     PERFORM RIGID-AT
     MOVE 0.73333335 TO WS-V
     PERFORM NEAR
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 encapsulate at (100, 39, 200) is 0.73333335" TO TL-CASE
     PERFORM CHECK
     MOVE 0 TO WS-X WS-Y WS-Z WS-I WS-J WS-PX
     CALL "STRUCT-BEARD-JUNCTION" USING WS-I WS-J WS-PX WS-X WS-Y WS-Z WS-R
     MOVE -0.27838787 TO WS-V
     PERFORM NEAR
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 a junction at (0, 0, 0) at (0, 0, 0) is -0.27838787" TO TL-CASE
     PERFORM CHECK
     MOVE -1 TO WS-Y
     MOVE 0 TO WS-I WS-J WS-PX
     CALL "STRUCT-BEARD-JUNCTION" USING WS-I WS-J WS-PX WS-X WS-Y WS-Z WS-R
     MOVE 0.27838787 TO WS-V
     PERFORM NEAR
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 a junction at (0, 0, 0) at (0, -1, 0) is 0.27838787" TO TL-CASE
     PERFORM CHECK.

*> WS-I the mode: the term of the 10.5 box (100, 40, 200) to (101, 44, 200), ground 0, at (WS-X, WS-Y, WS-Z) into WS-R
 RIGID-AT.
     MOVE 100 TO WS-SX
     MOVE 40 TO WS-CX
     MOVE 200 TO WS-SZ
     MOVE 101 TO WS-PX
     MOVE 44 TO WS-CZ
     MOVE 200 TO WS-PZ
     MOVE 0 TO WS-J
     CALL "STRUCT-BEARD-RIGID" USING WS-I WS-SX WS-CX WS-SZ WS-PX WS-CZ WS-PZ WS-J WS-X WS-Y WS-Z WS-R.

*> the block examples of 10.5: a squeezed value 0.2 at (100, 40, 200) becomes air, -0.3 at (100, 39, 200) becomes solid; a small positive value falls under the weakest terms, 0 is not solid
 BLOCK-EXAMPLES.
     PERFORM SET-FOSSIL-RECORD
     MOVE 0.2 TO WS-V
     MOVE 100 TO WS-X
     MOVE 40 TO WS-Y
     MOVE 200 TO WS-Z
     CALL "NETHER-SOLID" USING WS-V WS-X WS-Y WS-Z WS-FLAG
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 a block of squeezed value 0.2 at (100, 40, 200) becomes air (0.2 - 0.5568 < 0)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -0.3 TO WS-V
     MOVE 39 TO WS-Y
     CALL "NETHER-SOLID" USING WS-V WS-X WS-Y WS-Z WS-FLAG
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 a block of squeezed value -0.3 at (100, 39, 200) becomes solid (-0.3 + 0.5568 > 0)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.01 TO WS-V
     MOVE 105 TO WS-X
     MOVE 40 TO WS-Y
     CALL "NETHER-SOLID" USING WS-V WS-X WS-Y WS-Z WS-FLAG
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 a block of squeezed value 0.01 at (105, 40, 200) becomes air (term -0.0254)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.6 TO WS-V
     CALL "NETHER-SOLID" USING WS-V WS-X WS-Y WS-Z WS-FLAG
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 a block of squeezed value 0.6 at (105, 40, 200) stays solid" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0.001 TO WS-V
     MOVE 52 TO WS-Y
     MOVE 100 TO WS-X
     CALL "NETHER-SOLID" USING WS-V WS-X WS-Y WS-Z WS-FLAG
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 a block of squeezed value 0.001 at (100, 52, 200) out of reach of the record stays solid (term 0)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-V
     CALL "NETHER-SOLID" USING WS-V WS-X WS-Y WS-Z WS-FLAG
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 6.3 a block of density 0 is not solid (the sum must be strictly above 0)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "NETHER-BEARD-CLEAR"
     MOVE 0.2 TO WS-V
     MOVE 40 TO WS-Y
     CALL "NETHER-SOLID" USING WS-V WS-X WS-Y WS-Z WS-FLAG
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.2 with no record the beardifier is 0 everywhere (0.2 stays solid)" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> chunk (6, 12) of world seed 0 holds the block (100, 40, 200): filled with the record of 10.5 and without
 FILL-CASES.
     MOVE 6 TO WS-CX
     MOVE 12 TO WS-CZ
     CALL "NETHER-CORNERS" USING WS-CX WS-CZ
     CALL "NETHER-BEARD-CLEAR"
     MOVE LOW-VALUES TO WS-CHUNK-A
     CALL "NETHER-FILL" USING WS-CHUNK-A
     PERFORM SET-FOSSIL-RECORD
     MOVE LOW-VALUES TO WS-CHUNK-B
     CALL "NETHER-FILL" USING WS-CHUNK-B
     CALL "NETHER-BEARD-CLEAR"
     MOVE 0 TO WS-ADDED WS-REMOVED WS-OUTSIDE WS-WRONG-SIGN WS-DIFFERENT
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 127
         PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
             PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
                 COMPUTE WS-CELL = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
                 SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK-A
                 MOVE 0 TO WS-SOLID-A
                 IF CE-STATE(WS-CELL) = NH-S-NETHERRACK
                     MOVE 1 TO WS-SOLID-A
                 END-IF
                 SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK-B
                 MOVE 0 TO WS-SOLID-B
                 IF CE-STATE(WS-CELL) = NH-S-NETHERRACK
                     MOVE 1 TO WS-SOLID-B
                 END-IF
                 COMPUTE WS-X = 96 + WS-LX
                 COMPUTE WS-Z = 192 + WS-LZ
                 IF WS-SOLID-A NOT = WS-SOLID-B
                     ADD 1 TO WS-DIFFERENT
*>                   10.3: nothing 12 or more blocks from the box in x or z, none more than 12 below its bottom or 11 above it
                     IF WS-X < 88 OR WS-X > 113 OR WS-Z < 188 OR WS-Z > 212 OR WS-Y < 28 OR WS-Y > 51
                         ADD 1 TO WS-OUTSIDE
                     END-IF
*>                   positive below the bottom (y 40): terrain added; at and above it: removed
                     IF WS-SOLID-B = 1
                         ADD 1 TO WS-ADDED
                         IF WS-Y >= 40
                             ADD 1 TO WS-WRONG-SIGN
                         END-IF
                     ELSE
                         ADD 1 TO WS-REMOVED
                         IF WS-Y < 40
                             ADD 1 TO WS-WRONG-SIGN
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-ADDED TO WS-ED
     DISPLAY "PROBE 37-2 10 fill of chunk (6, 12): " WS-ED " blocks added, " WS-REMOVED " removed"
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.3 the fill with a fossil record differs from the plain fill" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-DIFFERENT > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.3 no block changes 12 or more blocks away from the box or beyond the reach in y" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-OUTSIDE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.3 terrain is only added below the box's bottom and only removed from it up" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WRONG-SIGN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the column (100, 200): the squeezed density plus the 10.5 term (table values) decides the block, at y 38 to 41 and 44 and 45
     MOVE 4 TO WS-LX
     MOVE 8 TO WS-LZ
     CALL "NETHER-COLUMN" USING WS-LX WS-LZ
     MOVE 0 TO WS-WRONG-SIGN
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 6
         EVALUATE WS-J
             WHEN 1
                 MOVE 38 TO WS-Y
                 MOVE 0.49142528 TO WS-V
             WHEN 2
                 MOVE 39 TO WS-Y
                 MOVE 0.55677575 TO WS-V
             WHEN 3
                 MOVE 40 TO WS-Y
                 MOVE -0.55677575 TO WS-V
             WHEN 4
                 MOVE 41 TO WS-Y
                 MOVE -0.49142528 TO WS-V
             WHEN 5
                 MOVE 44 TO WS-Y
                 MOVE -0.15928148 TO WS-V
             WHEN OTHER
                 MOVE 45 TO WS-Y
                 MOVE -0.08525947 TO WS-V
         END-EVALUATE
         COMPUTE WS-I = WS-Y + 1
         COMPUTE WS-D = NH-COL(WS-I) + WS-V
         COMPUTE WS-CELL = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
         SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK-B
         MOVE 0 TO WS-MODEL
         IF WS-D > 0
             MOVE 1 TO WS-MODEL
         END-IF
         MOVE 0 TO WS-SOLID-B
         IF CE-STATE(WS-CELL) = NH-S-NETHERRACK
             MOVE 1 TO WS-SOLID-B
         END-IF
         IF WS-MODEL NOT = WS-SOLID-B
             ADD 1 TO WS-WRONG-SIGN
         END-IF
     END-PERFORM
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.5 the filled column (100, 200) at y 38 to 41, 44 and 45 is solid iff the squeezed density plus the table term is above 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-WRONG-SIGN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> a real nether_fossil start of world seed 12345 (the world is opened for the structure data: the templates)
 FOSSIL-CASES.
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
         MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.1 no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         EXIT PARAGRAPH
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "GEN-WORLD-SETUP"
     MOVE CW-SEED TO WS-GSEED
     CALL "NETHER-SETUP" USING WS-GSEED
     CALL "NETHER-STATES"
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-SX FROM -25 BY 1 UNTIL WS-SX > 25 OR WS-FOUND = 1
         PERFORM VARYING WS-SZ FROM -25 BY 1 UNTIL WS-SZ > 25 OR WS-FOUND = 1
             CALL "NETHER-FOSSIL-START" USING WS-GSEED WS-SX WS-SZ WS-VALID
             IF WS-VALID = 1
                 MOVE 1 TO WS-FOUND
                 MOVE WS-SX TO WS-FCX
                 MOVE WS-SZ TO WS-FCZ
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.1 a chunk of the 51 x 51 grid holds a nether_fossil start" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 0
         EXIT PARAGRAPH
     END-IF
*>   the start's piece box (the builder holds it after the call)
     CALL "NETHER-FOSSIL-START" USING WS-GSEED WS-FCX WS-FCZ WS-VALID
     CALL "SPB-UNION-ALL" USING WS-BOX
     CALL "NETHER-BEARD-COLLECT" USING WS-GSEED WS-FCX WS-FCZ
*>   the model: the starts of the 7 x 7 chunks around (wider than the 5 x 5 the collector reads) whose box widened by 12 reaches the chunk
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-SX FROM -3 BY 1 UNTIL WS-SX > 3
         PERFORM VARYING WS-SZ FROM -3 BY 1 UNTIL WS-SZ > 3
             COMPUTE WS-PX = WS-FCX + WS-SX
             COMPUTE WS-PZ = WS-FCZ + WS-SZ
             CALL "NETHER-FOSSIL-START" USING WS-GSEED WS-PX WS-PZ WS-VALID
             IF WS-VALID = 1
                 CALL "SPB-UNION-ALL" USING WS-BOX
                 CALL "STRUCT-BEARD-CLOSE" USING B-X0 B-Z0 B-X1 B-Z1 WS-FCX WS-FCZ WS-MARGIN WS-CLOSE
                 IF WS-CLOSE = 1
                     ADD 1 TO WS-COUNT
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.2 the collector keeps one record for every fossil start within reach of the chunk (7 x 7 model, at least one)" TO TL-CASE
     MOVE WS-COUNT TO TL-EXPECTED-N
     MOVE SBD-RIGID-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.2 the chunk of a start has an active beardifier" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SBD-ACTIVE = 1 AND WS-COUNT >= 1
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   the start's own record: beard_thin (mode 2), ground level delta 0, the piece box
     CALL "NETHER-FOSSIL-START" USING WS-GSEED WS-FCX WS-FCZ WS-VALID
     CALL "SPB-UNION-ALL" USING WS-BOX
     MOVE 0 TO WS-FLAG
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBD-RIGID-COUNT
         IF SBR-MODE(WS-I) = 2 AND SBR-GROUND(WS-I) = 0 AND SBR-X0(WS-I) = B-X0 AND SBR-Y0(WS-I) = B-Y0 AND SBR-Z0(WS-I) = B-Z0
             AND SBR-X1(WS-I) = B-X1 AND SBR-Y1(WS-I) = B-Y1 AND SBR-Z1(WS-I) = B-Z1
             MOVE 1 TO WS-FLAG
         END-IF
     END-PERFORM
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.1 the start's record is mode beard_thin, ground level delta 0 and the fossil piece's box" TO TL-CASE
     PERFORM CHECK
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.4 no junction record is made in the Nether" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE SBD-JUNC-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the fill of that chunk with the collected records differs from the plain fill, by the sign rule around the record's bottom
     CALL "NETHER-CORNERS" USING WS-FCX WS-FCZ
     MOVE LOW-VALUES TO WS-CHUNK-B
     CALL "NETHER-FILL" USING WS-CHUNK-B
     CALL "NETHER-BEARD-CLEAR"
     MOVE LOW-VALUES TO WS-CHUNK-A
     CALL "NETHER-FILL" USING WS-CHUNK-A
     MOVE 0 TO WS-DIFFERENT WS-WRONG-SIGN
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 127
         PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
             PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
                 COMPUTE WS-CELL = WS-Y * 256 + WS-LZ * 16 + WS-LX + 1
                 SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK-A
                 MOVE 0 TO WS-SOLID-A
                 IF CE-STATE(WS-CELL) = NH-S-NETHERRACK
                     MOVE 1 TO WS-SOLID-A
                 END-IF
                 SET ADDRESS OF CE-CHUNK TO ADDRESS OF WS-CHUNK-B
                 MOVE 0 TO WS-SOLID-B
                 IF CE-STATE(WS-CELL) = NH-S-NETHERRACK
                     MOVE 1 TO WS-SOLID-B
                 END-IF
                 IF WS-SOLID-A NOT = WS-SOLID-B
                     ADD 1 TO WS-DIFFERENT
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.2 the fill of a fossil start's chunk with its records differs from the fill without them" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF WS-DIFFERENT > 0
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK
*>   a chunk 10 chunks from every start of the grid has no record
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-SX FROM 30 BY 1 UNTIL WS-SX > 40 OR WS-FOUND = 1
         COMPUTE WS-PX = WS-FCX + WS-SX
         COMPUTE WS-PZ = WS-FCZ
         CALL "NETHER-BEARD-COLLECT" USING WS-GSEED WS-PX WS-PZ
         IF SBD-ACTIVE = 0
             MOVE 1 TO WS-FOUND
         END-IF
         CALL "NETHER-BEARD-CLEAR"
     END-PERFORM
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.2 a chunk with no fossil start near has no record (the beardifier is 0 everywhere)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   NETHER-GEN-CHUNK of the start's chunk leaves the records empty, and changes the stamp of the density memo
     MOVE SBD-GEN TO WS-GEN
     CALL "NETHER-GEN-CHUNK" USING WS-GSEED WS-FCX WS-FCZ WS-CHUNK-B WS-MARKER
     MOVE "acceptance US12 37-2§10 Hook: the beardifier in the Nether 10.2 a Nether chunk made by NETHER-GEN-CHUNK leaves no record behind for the overworld" TO TL-CASE
     MOVE 0 TO WS-FLAG
     IF SBD-ACTIVE = 0 AND SBD-RIGID-COUNT = 0 AND SBD-READY = 0 AND SBD-GEN NOT = WS-GEN
         MOVE 1 TO WS-FLAG
     END-IF
     PERFORM CHECK.
 COPY NETHERTEST.
 END PROGRAM TEST-NETHER-37-2-10.

 COPY NOSPAWN.
 COPY CORETEST.
