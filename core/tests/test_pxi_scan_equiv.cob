*> Equivalence test (002-lane-bugvlag): PXI-SCAN reads a section straight from the chunk's cell table; it must find what the per-cell walk it replaced found, in the same order.
*> The reference is that walk (24 sections, x then z then y, PXI-KIND-OF and PXI-ADD for each cell) run in this program over a chunk that holds 80 planted blocks of every kind (beds,
*> bells, workstations) and decoys, at every height down to -64 and up to 319; the entry table of the index must be byte for byte the same afterwards, and the chunk done after the 24th step.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PXI-SCAN-EQUIV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY VILPOIX.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-KEYS.
    05 WS-KEY-ENTRY        PIC X(112) OCCURS 10 TIMES.
 01 WS-STATES.
    05 WS-STATE-OF         BINARY-LONG OCCURS 10 TIMES.
 01 WS-STATE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-SEC                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 20261118.
 01 WS-PICK                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-REF                 PIC X(20480).
 01 WS-SAME                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER) / 16)
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER) / 16)
     COMPUTE WS-X0 = WS-CX * 16
     COMPUTE WS-Z0 = WS-CZ * 16
     MOVE "minecraft:red_bed" TO WS-KEY-ENTRY(1)
     MOVE "minecraft:blue_bed" TO WS-KEY-ENTRY(2)
     MOVE "minecraft:bell" TO WS-KEY-ENTRY(3)
     MOVE "minecraft:lectern" TO WS-KEY-ENTRY(4)
     MOVE "minecraft:barrel" TO WS-KEY-ENTRY(5)
     MOVE "minecraft:composter" TO WS-KEY-ENTRY(6)
     MOVE "minecraft:blast_furnace" TO WS-KEY-ENTRY(7)
     MOVE "minecraft:stone" TO WS-KEY-ENTRY(8)
     MOVE "minecraft:chest" TO WS-KEY-ENTRY(9)
     MOVE "minecraft:oak_planks" TO WS-KEY-ENTRY(10)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
         CALL "BLOCKS-STATE-OF" USING WS-KEY-ENTRY(WS-I) WS-PAIRS WS-STATE
         MOVE WS-STATE TO WS-STATE-OF(WS-I)
     END-PERFORM
*>   80 planted blocks: the cell and the block drawn from a linear congruential stream; the two extreme heights are planted by hand
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 80
         PERFORM DRAW
         COMPUTE WS-X = WS-X0 + FUNCTION MOD(WS-PICK, 16)
         PERFORM DRAW
         COMPUTE WS-Z = WS-Z0 + FUNCTION MOD(WS-PICK, 16)
         PERFORM DRAW
         COMPUTE WS-Y = FUNCTION MOD(WS-PICK, 384) - 64
         PERFORM DRAW
         COMPUTE WS-PICK = FUNCTION MOD(WS-PICK, 10) + 1
         IF WS-I = 1
             MOVE -64 TO WS-Y
         END-IF
         IF WS-I = 2
             MOVE 319 TO WS-Y
         END-IF
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE-OF(WS-PICK)
     END-PERFORM
*>   reference: the walk the scan replaced
     INITIALIZE PX-STATE
     PERFORM VARYING WS-SEC FROM 0 BY 1 UNTIL WS-SEC > 23
         COMPUTE WS-Y0 = WS-SEC * 16 - 64
         PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X0 + 15
             PERFORM VARYING WS-Z FROM WS-Z0 BY 1 UNTIL WS-Z > WS-Z0 + 15
                 PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y0 + 15
                     CALL "PXI-KIND-OF" USING WS-DIM WS-X WS-Y WS-Z WS-KIND
                     IF WS-KIND > 0
                         CALL "PXI-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-KIND
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE PX-STATE(1405:20480) TO WS-REF
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
         IF PX-KIND(WS-I) > 0
             ADD 1 TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "bugvlag the reference walk finds points of interest in the planted chunk (more than 20)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the scan: 23 steps leave the chunk open, the 24th closes it
     INITIALIZE PX-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 23
         CALL "PXI-SCAN" USING WS-DIM WS-CX WS-CZ
     END-PERFORM
     MOVE "bugvlag the chunk is not done after 23 section steps" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PX-DONE-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PXI-SCAN" USING WS-DIM WS-CX WS-CZ
     MOVE "bugvlag the chunk is done after the 24th" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PX-DONE-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SAME
     IF PX-STATE(1405:20480) = WS-REF
         MOVE 1 TO WS-SAME
     END-IF
     MOVE "bugvlag the entry table of the scan is byte for byte that of the reference walk" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SAME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 DRAW.
     COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
     COMPUTE WS-PICK = FUNCTION MOD(WS-SEED / 65536, 32768).
 END PROGRAM TEST-PXI-SCAN-EQUIV.
 COPY CORETEST.
 COPY MOBSPTEST.
