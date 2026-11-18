*> The beardifier of a chunk from the stored starts (docs/protocol/36-structures-1-model-placement-starts.md sections 9.2, 9.3 and 9.4; STRUCTBEARD.cpy, STRUCTSTART.cpy): the contributors are collected from the starts that
*> reference the chunk and adapt the terrain, the value at a block is the float sum of 9.3 over them (the per-record formulas are core/src/struct-36-1-9.cob), and a volume of grid points is sampled in the loop order of 9.4.
*> The `beardifier` node of the final density (core/src/density.cob, node type 35) reads STRUCT-BEARD-SAMPLE; the terrain stage prepares the chunk (STRUCT-BEARD-PREPARE) before it reads any density column.
*> The volume buffer index of a grid point is ((z * size x) + x) * size y + y + 1 (z outermost, y innermost, the loop order of 9.4; the document gives no other layout).
*>
*> Entry points:
*>   STRUCT-BEARD-COLLECT USING chunk x, chunk z: 9.2 from the store of starts (references of the chunk must exist: STRUCT-REFS-CREATE)
*>   STRUCT-BEARD-SAMPLE USING x, y, z, value out (FLOAT-LONG, single precision): 9.3, 0 when the beardifier is empty or the block is outside the affected box
*>   STRUCT-BEARD-VOLUME USING min x, min y, min z, step x, step y, step z, size x, size y, size z (BINARY-LONG), out (a table of FLOAT-LONG, size x * size y * size z entries): 9.4
*>   STRUCT-BEARD-PREPARE USING chunk x, chunk z: makes the starts of the adapting structures within 8 chunks (their generators, STRUCT-CAPTURE) and collects; empty when no structure is gated on; once per chunk, seed and data epoch

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD-COLLECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTBEARD.
 COPY STRUCTSTART.
 COPY STRUCTDATA.
 01 WS-MARGIN              BINARY-LONG VALUE 12.
 01 WS-COUNT               BINARY-LONG.
 01 WS-LIST.
    05 WS-START            BINARY-LONG OCCURS 64 TIMES.
 01 WS-FILTER              BINARY-LONG VALUE -1.
 01 WS-I                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-JLAST               BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-BX0                 BINARY-LONG.
 01 WS-BY0                 BINARY-LONG.
 01 WS-BZ0                 BINARY-LONG.
 01 WS-BX1                 BINARY-LONG.
 01 WS-BY1                 BINARY-LONG.
 01 WS-BZ1                 BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     MOVE 0 TO SBD-ACTIVE SBD-RIGID-COUNT SBD-JUNC-COUNT SBD-LOST WS-HAVE
     MOVE L-CX TO SBD-CX
     MOVE L-CZ TO SBD-CZ
     CALL "STRUCT-STARTS-FOR" USING L-CX L-CZ WS-FILTER WS-COUNT WS-LIST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE SDT-ADAPT(SST-STRUCT(WS-START(WS-I))) TO WS-MODE
         COMPUTE WS-LAST = SST-FIRST(WS-START(WS-I)) + SST-N(WS-START(WS-I)) - 1
         PERFORM VARYING WS-P FROM SST-FIRST(WS-START(WS-I)) BY 1 UNTIL WS-P > WS-LAST
             MOVE SPC-X0(WS-P) TO WS-BX0
             MOVE SPC-Y0(WS-P) TO WS-BY0
             MOVE SPC-Z0(WS-P) TO WS-BZ0
             MOVE SPC-X1(WS-P) TO WS-BX1
             MOVE SPC-Y1(WS-P) TO WS-BY1
             MOVE SPC-Z1(WS-P) TO WS-BZ1
             CALL "STRUCT-BEARD-CLOSE" USING WS-BX0 WS-BZ0 WS-BX1 WS-BZ1 L-CX L-CZ WS-MARGIN WS-CLOSE
             IF WS-CLOSE = 1
*>               a jigsaw piece with the rigid projection and every other piece is a rigid record; a terrain_matching jigsaw piece only has its junctions
                 MOVE 0 TO WS-ADD
                 MOVE 0 TO WS-GROUND
                 IF SPC-JIG(WS-P) = 0
                     MOVE 1 TO WS-ADD
                 END-IF
                 IF SPC-JIG(WS-P) = 1
                     MOVE 1 TO WS-ADD
                     MOVE SPC-GROUND(WS-P) TO WS-GROUND
                 END-IF
                 IF WS-ADD = 1
                     IF SBD-RIGID-COUNT < SBD-MAX
                         ADD 1 TO SBD-RIGID-COUNT
                         MOVE WS-MODE TO SBR-MODE(SBD-RIGID-COUNT)
                         MOVE WS-BX0 TO SBR-X0(SBD-RIGID-COUNT)
                         MOVE WS-BY0 TO SBR-Y0(SBD-RIGID-COUNT)
                         MOVE WS-BZ0 TO SBR-Z0(SBD-RIGID-COUNT)
                         MOVE WS-BX1 TO SBR-X1(SBD-RIGID-COUNT)
                         MOVE WS-BY1 TO SBR-Y1(SBD-RIGID-COUNT)
                         MOVE WS-BZ1 TO SBR-Z1(SBD-RIGID-COUNT)
                         MOVE WS-GROUND TO SBR-GROUND(SBD-RIGID-COUNT)
                         PERFORM EXTEND-BOX
                     ELSE
                         ADD 1 TO SBD-LOST
                     END-IF
                 END-IF
                 COMPUTE WS-JLAST = SPC-J-FIRST(WS-P) + SPC-J-N(WS-P) - 1
                 PERFORM VARYING WS-J FROM SPC-J-FIRST(WS-P) BY 1 UNTIL WS-J > WS-JLAST
                     MOVE SJ-X(WS-J) TO WS-SX
                     MOVE SJ-Y(WS-J) TO WS-SY
                     MOVE SJ-Z(WS-J) TO WS-SZ
                     CALL "STRUCT-BEARD-JUNCTION-IN" USING WS-SX WS-SZ L-CX L-CZ WS-IN
                     IF WS-IN = 1
                         IF SBD-JUNC-COUNT < SBD-MAX
                             ADD 1 TO SBD-JUNC-COUNT
                             MOVE WS-SX TO SBJ-X(SBD-JUNC-COUNT)
                             MOVE WS-SY TO SBJ-Y(SBD-JUNC-COUNT)
                             MOVE WS-SZ TO SBJ-Z(SBD-JUNC-COUNT)
                             MOVE WS-SX TO WS-BX0
                             MOVE WS-SY TO WS-BY0
                             MOVE WS-SZ TO WS-BZ0
                             MOVE WS-SX TO WS-BX1
                             MOVE WS-SY TO WS-BY1
                             MOVE WS-SZ TO WS-BZ1
                             PERFORM EXTEND-BOX
                         ELSE
                             ADD 1 TO SBD-LOST
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     IF SBD-RIGID-COUNT + SBD-JUNC-COUNT > 0
         MOVE 1 TO SBD-ACTIVE
     END-IF
     GOBACK.

*> the union of the affected box and the box WS-BX0 .. WS-BZ1
 EXTEND-BOX.
     IF WS-HAVE = 0
         MOVE WS-BX0 TO SBD-AX0
         MOVE WS-BY0 TO SBD-AY0
         MOVE WS-BZ0 TO SBD-AZ0
         MOVE WS-BX1 TO SBD-AX1
         MOVE WS-BY1 TO SBD-AY1
         MOVE WS-BZ1 TO SBD-AZ1
         MOVE 1 TO WS-HAVE
     ELSE
         MOVE FUNCTION MIN(SBD-AX0, WS-BX0) TO SBD-AX0
         MOVE FUNCTION MIN(SBD-AY0, WS-BY0) TO SBD-AY0
         MOVE FUNCTION MIN(SBD-AZ0, WS-BZ0) TO SBD-AZ0
         MOVE FUNCTION MAX(SBD-AX1, WS-BX1) TO SBD-AX1
         MOVE FUNCTION MAX(SBD-AY1, WS-BY1) TO SBD-AY1
         MOVE FUNCTION MAX(SBD-AZ1, WS-BZ1) TO SBD-AZ1
     END-IF.
 END PROGRAM STRUCT-BEARD-COLLECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD-SAMPLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTBEARD.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-R.
     MOVE 0 TO L-R
     IF SBD-ACTIVE = 0
         GOBACK
     END-IF
     CALL "STRUCT-BEARD-AFFECTED" USING SBD-AX0 SBD-AY0 SBD-AZ0 SBD-AX1 SBD-AY1 SBD-AZ1 L-X L-Y L-Z WS-FLAG
     IF WS-FLAG = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-SUM
*>   a record is exactly 0 farther than 12 blocks from its box in x or z, and farther than 12 above or below its layers (beard: -12 <= y - bottom < 12 after the ground level delta; bury and
*>   encapsulate: the y distance halved is below 6): such a record adds 0.0, which changes no single precision sum, so it is not evaluated
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBD-RIGID-COUNT
         COMPUTE WS-LO = FUNCTION MIN(SBR-Y0(WS-I), SBR-Y0(WS-I) + SBR-GROUND(WS-I)) - 13
         COMPUTE WS-HI = FUNCTION MAX(SBR-Y1(WS-I), SBR-Y0(WS-I) + SBR-GROUND(WS-I)) + 13
         IF L-X >= SBR-X0(WS-I) - 12 AND L-X <= SBR-X1(WS-I) + 12 AND L-Z >= SBR-Z0(WS-I) - 12 AND L-Z <= SBR-Z1(WS-I) + 12
                 AND L-Y >= WS-LO AND L-Y <= WS-HI
             CALL "STRUCT-BEARD-RIGID" USING SBR-MODE(WS-I) SBR-X0(WS-I) SBR-Y0(WS-I) SBR-Z0(WS-I) SBR-X1(WS-I) SBR-Y1(WS-I)
                 SBR-Z1(WS-I) SBR-GROUND(WS-I) L-X L-Y L-Z WS-V
             CALL "FX-OP" USING WS-OP-ADD WS-SUM WS-V WS-T
             MOVE WS-T TO WS-SUM
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBD-JUNC-COUNT
         IF L-X >= SBJ-X(WS-I) - 12 AND L-X <= SBJ-X(WS-I) + 12 AND L-Y >= SBJ-Y(WS-I) - 12 AND L-Y <= SBJ-Y(WS-I) + 12
                 AND L-Z >= SBJ-Z(WS-I) - 12 AND L-Z <= SBJ-Z(WS-I) + 12
             CALL "STRUCT-BEARD-JUNCTION" USING SBJ-X(WS-I) SBJ-Y(WS-I) SBJ-Z(WS-I) L-X L-Y L-Z WS-V
             CALL "FX-OP" USING WS-OP-ADD WS-SUM WS-V WS-T
             MOVE WS-T TO WS-SUM
         END-IF
     END-PERFORM
     MOVE WS-SUM TO L-R
     GOBACK.
 END PROGRAM STRUCT-BEARD-SAMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD-VOLUME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTBEARD.
 01 WS-LO.
    05 WS-LO-N             BINARY-LONG OCCURS 3 TIMES.
 01 WS-HI.
    05 WS-HI-N             BINARY-LONG OCCURS 3 TIMES.
 01 WS-A                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-IX                  BINARY-LONG.
 01 WS-IY                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 B-OUT BASED.
    05 B-VAL               FLOAT-LONG OCCURS 268435455 TIMES.
 LINKAGE SECTION.
 01 L-MINX                 BINARY-LONG.
 01 L-MINY                 BINARY-LONG.
 01 L-MINZ                 BINARY-LONG.
 01 L-STEPX                BINARY-LONG.
 01 L-STEPY                BINARY-LONG.
 01 L-STEPZ                BINARY-LONG.
 01 L-SIZEX                BINARY-LONG.
 01 L-SIZEY                BINARY-LONG.
 01 L-SIZEZ                BINARY-LONG.
 01 L-OUT                  PIC X.
 PROCEDURE DIVISION USING L-MINX L-MINY L-MINZ L-STEPX L-STEPY L-STEPZ L-SIZEX L-SIZEY L-SIZEZ L-OUT.
     SET ADDRESS OF B-OUT TO ADDRESS OF L-OUT
     COMPUTE WS-TOTAL = L-SIZEX * L-SIZEY * L-SIZEZ
     PERFORM VARYING WS-INDEX FROM 1 BY 1 UNTIL WS-INDEX > WS-TOTAL
         MOVE 0 TO B-VAL(WS-INDEX)
     END-PERFORM
     IF SBD-ACTIVE = 0
         GOBACK
     END-IF
*>   the grid points whose block position lies in the affected box inflated by 24: floorDiv of the offsets by the steps, clamped to the volume (a point outside the box reads 0 from the sampler anyway)
     COMPUTE WS-T = SBD-AX0 - 24 - L-MINX
     COMPUTE WS-LO-N(1) = FUNCTION INTEGER(WS-T / L-STEPX)
     COMPUTE WS-T = SBD-AX1 + 24 - L-MINX
     COMPUTE WS-HI-N(1) = FUNCTION INTEGER(WS-T / L-STEPX)
     COMPUTE WS-T = SBD-AY0 - 24 - L-MINY
     COMPUTE WS-LO-N(2) = FUNCTION INTEGER(WS-T / L-STEPY)
     COMPUTE WS-T = SBD-AY1 + 24 - L-MINY
     COMPUTE WS-HI-N(2) = FUNCTION INTEGER(WS-T / L-STEPY)
     COMPUTE WS-T = SBD-AZ0 - 24 - L-MINZ
     COMPUTE WS-LO-N(3) = FUNCTION INTEGER(WS-T / L-STEPZ)
     COMPUTE WS-T = SBD-AZ1 + 24 - L-MINZ
     COMPUTE WS-HI-N(3) = FUNCTION INTEGER(WS-T / L-STEPZ)
     MOVE FUNCTION MAX(WS-LO-N(1), 0) TO WS-LO-N(1)
     MOVE FUNCTION MAX(WS-LO-N(2), 0) TO WS-LO-N(2)
     MOVE FUNCTION MAX(WS-LO-N(3), 0) TO WS-LO-N(3)
     COMPUTE WS-A = L-SIZEX - 1
     MOVE FUNCTION MIN(WS-HI-N(1), WS-A) TO WS-HI-N(1)
     COMPUTE WS-A = L-SIZEY - 1
     MOVE FUNCTION MIN(WS-HI-N(2), WS-A) TO WS-HI-N(2)
     COMPUTE WS-A = L-SIZEZ - 1
     MOVE FUNCTION MIN(WS-HI-N(3), WS-A) TO WS-HI-N(3)
     PERFORM VARYING WS-IZ FROM WS-LO-N(3) BY 1 UNTIL WS-IZ > WS-HI-N(3)
         PERFORM VARYING WS-IX FROM WS-LO-N(1) BY 1 UNTIL WS-IX > WS-HI-N(1)
             PERFORM VARYING WS-IY FROM WS-LO-N(2) BY 1 UNTIL WS-IY > WS-HI-N(2)
                 COMPUTE WS-X = L-MINX + WS-IX * L-STEPX
                 COMPUTE WS-Y = L-MINY + WS-IY * L-STEPY
                 COMPUTE WS-Z = L-MINZ + WS-IZ * L-STEPZ
                 CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-V
                 COMPUTE WS-INDEX = (WS-IZ * L-SIZEX + WS-IX) * L-SIZEY + WS-IY + 1
                 MOVE WS-V TO B-VAL(WS-INDEX)
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM STRUCT-BEARD-VOLUME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STRUCT-BEARD-PREPARE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTBEARD.
 COPY STRUCTSTART.
 COPY STRUCTDATA.
 COPY CARVER.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-M63                 PIC 9(20) VALUE 9223372036854775808.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-IX                  BINARY-LONG.
 01 WS-IZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STRUCT              BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-STORED              BINARY-LONG.
 01 WS-WAS                 BINARY-LONG.
 01 WS-STARTS.
    05 WS-START OCCURS 64 TIMES.
       10 WS-ST            BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ.
     COMPUTE WS-SEED = FUNCTION MOD(CV-SEED + WS-M63, WS-M64) - WS-M63
     IF SBD-READY = 1 AND SBD-CX = L-CX AND SBD-CZ = L-CZ AND SBD-SEED = WS-SEED AND SBD-EPOCH = SD-EPOCH
         GOBACK
     END-IF
     MOVE SBD-ACTIVE TO WS-WAS
     MOVE 0 TO SBD-ACTIVE SBD-RIGID-COUNT SBD-JUNC-COUNT
     MOVE L-CX TO SBD-CX
     MOVE L-CZ TO SBD-CZ
     MOVE WS-SEED TO SBD-SEED
     MOVE SD-EPOCH TO SBD-EPOCH
     MOVE 1 TO SBD-READY
     IF WS-WAS = 1
         ADD 1 TO SBD-GEN
     END-IF
     IF SD-GATE-COUNT = 0
         GOBACK
     END-IF
     CALL "STRUCT-STORE-SYNC"
     PERFORM VARYING WS-IX FROM 0 BY 1 UNTIL WS-IX > 16
         COMPUTE WS-SX = L-CX - 8 + WS-IX
         PERFORM VARYING WS-IZ FROM 0 BY 1 UNTIL WS-IZ > 16
             COMPUTE WS-SZ = L-CZ - 8 + WS-IZ
             CALL "STRUCT-CHUNK-STARTS" USING WS-SEED WS-SX WS-SZ WS-N
*>           the starts of this chunk that adapt the terrain, copied first (the generators below use the same working tables)
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
                 MOVE SC-STRUCT(WS-I) TO WS-ST(WS-I)
             END-PERFORM
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
                 MOVE WS-ST(WS-I) TO WS-STRUCT
                 IF SDT-ADAPT(WS-STRUCT) NOT = 0
                     CALL "STRUCT-START-FIND" USING WS-STRUCT WS-SX WS-SZ WS-ROW
                     IF WS-ROW = 0
                         CALL "STRUCT-FIND-POINT" USING WS-STRUCT WS-SEED WS-SX WS-SZ WS-X WS-Y WS-Z WS-VALID
                         IF WS-VALID = 1
                             CALL "STRUCT-START-CAPTURE" USING WS-STRUCT WS-SX WS-SZ WS-STORED
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "STRUCT-REFS-CREATE" USING L-CX L-CZ
     CALL "STRUCT-BEARD-COLLECT" USING L-CX L-CZ
     IF SBD-ACTIVE = 1
         ADD 1 TO SBD-GEN
     END-IF
     GOBACK.
 END PROGRAM STRUCT-BEARD-PREPARE.
