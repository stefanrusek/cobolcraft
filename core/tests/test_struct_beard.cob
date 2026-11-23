*> Implementation test of the beardifier of a chunk from stored starts (docs/protocol/36-structures-1-model-placement-starts.md sections 9.2, 9.3 and 9.4 and 13.14; core/src/struct-beard.cob): the contributors of a chunk are
*> the pieces of the referencing starts of structures that adapt the terrain (none does not), a rigid record per piece that is close to the chunk (inside the chunk square widened by 12), per jigsaw piece
*> with the rigid projection a record with its ground level delta and for every close jigsaw piece (rigid or terrain_matching) its junctions that lie strictly inside 12 blocks of the chunk; the value at a
*> block is the single precision sum of the records' contributions in list order (rigid records, then junctions) and exactly 0 outside the affected box (the union of the record boxes inflated by 24) or when no record
*> was collected; a volume of grid points is the value at every grid point in the loop order z, x, y, 0 where the point lies outside the affected box. Each record's contribution is that of STRUCT-BEARD-RIGID and
*> STRUCT-BEARD-JUNCTION (checked against independent values in test_struct_36_1_9), so the sum is compared with those added in the same order.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-BEARD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 COPY STRUCTSTART.
 COPY STRUCTBEARD.
 01 WS-S                   BINARY-LONG.
 01 WS-PCX                 BINARY-LONG.
 01 WS-PCZ                 BINARY-LONG.
 01 WS-REFS                BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PR                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-V                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-WANT                FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-OP-ADD              BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-VOL.
    05 WS-VAL              FLOAT-LONG OCCURS 60 TIMES.
 01 WS-MINX                BINARY-LONG.
 01 WS-MINY                BINARY-LONG.
 01 WS-MINZ                BINARY-LONG.
 01 WS-STEPX               BINARY-LONG VALUE 4.
 01 WS-STEPY               BINARY-LONG VALUE 8.
 01 WS-STEPZ               BINARY-LONG VALUE 4.
 01 WS-SIZEX               BINARY-LONG VALUE 3.
 01 WS-SIZEY               BINARY-LONG VALUE 4.
 01 WS-SIZEZ               BINARY-LONG VALUE 5.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 3 TO SDT-ADAPT(1)
     MOVE 2 TO SDT-ADAPT(2)
     MOVE 0 TO SDT-ADAPT(3)
     CALL "STRUCT-STORE-RESET"
*>   start 1 (beard_box, structure 1) at chunk (0, 0): a plain piece (0..4, 60..63, 0..4) and a jigsaw piece, rigid, ground delta 2, box (6..10, 60..64, 6..10), junctions (10, 64, 10) and (40, 64, 10);
*>   a terrain_matching jigsaw piece (12..14, 60..62, 12..14) with the junction (12, 61, 12); a far piece (60..64, 60..63, 0..4) that is not close
     MOVE 1 TO WS-S
     MOVE 0 TO WS-PCX WS-PCZ
     CALL "STRUCT-START-PUT" USING WS-S WS-PCX WS-PCZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     MOVE 5 TO WS-T
     MOVE 0 TO WS-O WS-D WS-J WS-G
     MOVE 0 TO WS-X0 WS-Z0
     MOVE 60 TO WS-Y0
     MOVE 4 TO WS-X1 WS-Z1
     MOVE 63 TO WS-Y1
     PERFORM ADD-PIECE
     MOVE 60 TO WS-T
     MOVE 1 TO WS-J
     MOVE 2 TO WS-G
     MOVE 6 TO WS-X0 WS-Z0
     MOVE 10 TO WS-X1 WS-Z1
     MOVE 64 TO WS-Y1
     PERFORM ADD-PIECE
     MOVE 10 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 10 TO WS-Z
     PERFORM ADD-JUNCTION
     MOVE 40 TO WS-X
     PERFORM ADD-JUNCTION
     MOVE 2 TO WS-J
     MOVE 0 TO WS-G
     MOVE 12 TO WS-X0 WS-Z0
     MOVE 14 TO WS-X1 WS-Z1
     MOVE 62 TO WS-Y1
     PERFORM ADD-PIECE
     MOVE 12 TO WS-X
     MOVE 61 TO WS-Y
     MOVE 12 TO WS-Z
     PERFORM ADD-JUNCTION
     MOVE 5 TO WS-T
     MOVE 0 TO WS-J WS-G
     MOVE 60 TO WS-X0
     MOVE 0 TO WS-Z0
     MOVE 64 TO WS-X1
     MOVE 4 TO WS-Z1
     MOVE 63 TO WS-Y1
     PERFORM ADD-PIECE
*>   start 2 (beard_thin, structure 2) at chunk (0, 0): one piece (2..6, 62..66, 2..6)
     MOVE 2 TO WS-S
     CALL "STRUCT-START-PUT" USING WS-S WS-PCX WS-PCZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     MOVE 5 TO WS-T
     MOVE 2 TO WS-X0 WS-Z0
     MOVE 62 TO WS-Y0
     MOVE 6 TO WS-X1 WS-Z1
     MOVE 66 TO WS-Y1
     PERFORM ADD-PIECE
*>   start 3 (structure 3, terrain adaptation none) at chunk (0, 0): a piece that must not contribute
     MOVE 3 TO WS-S
     CALL "STRUCT-START-PUT" USING WS-S WS-PCX WS-PCZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     MOVE 0 TO WS-X0 WS-Z0
     MOVE 60 TO WS-Y0
     MOVE 15 TO WS-X1 WS-Z1
     MOVE 70 TO WS-Y1
     PERFORM ADD-PIECE
     MOVE 0 TO WS-CX WS-CZ
     CALL "STRUCT-REFS-CREATE" USING WS-CX WS-CZ
     CALL "STRUCT-BEARD-COLLECT" USING WS-CX WS-CZ

     MOVE "acceptance US12 36-1§9.2 collecting: rigid records are the plain piece, the rigid jigsaw piece, the terrain_matching piece's none (no record), start 2's piece: 3; the far piece and structure 3 give none" TO TL-CASE
     MOVE SBD-RIGID-COUNT TO TL-OBSERVED-N
     MOVE 3 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§9.2 collecting: the junctions strictly inside 12 blocks of the chunk are kept: (10, 64, 10) and (12, 61, 12), not (40, 64, 10)" TO TL-CASE
     MOVE SBD-JUNC-COUNT TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§9.2 collecting: the rigid jigsaw piece's record carries mode 3 (its start's beard_box) and ground level delta 2, the plain pieces 0" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SBR-MODE(2) * 100 + SBR-GROUND(2) * 10 + SBR-GROUND(1) + SBR-GROUND(3)
     MOVE 320 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§9.2 collecting: the third record is start 2's piece with mode 2 (beard_thin)" TO TL-CASE
     MOVE SBR-MODE(3) TO TL-OBSERVED-N
     MOVE 2 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-1§9.2 affected box: the union of the record boxes and the junction cells, (0, 60, 0) to (12, 66, 12), before the inflation by 24" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF SBD-AX0 = 0 AND SBD-AY0 = 60 AND SBD-AZ0 = 0 AND SBD-AX1 = 12 AND SBD-AY1 = 66 AND SBD-AZ1 = 12
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the sample: the sum in list order of the rigid records, then the junctions
     MOVE 3 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 3 TO WS-Z
     PERFORM EXPECT-SUM
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-V
     MOVE "acceptance US12 36-1§9.3 sampleValue (3, 64, 3): the float sum of the three rigid records and two junctions in list order" TO TL-CASE
     PERFORM CHECK-FLOAT
     MOVE 11 TO WS-X
     MOVE 70 TO WS-Y
     MOVE -8 TO WS-Z
     PERFORM EXPECT-SUM
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-V
     MOVE "acceptance US12 36-1§9.3 sampleValue (11, 70, -8): inside the inflated affected box, the sum again" TO TL-CASE
     PERFORM CHECK-FLOAT
     MOVE 200 TO WS-X
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-V
     MOVE "acceptance US12 36-1§13.14 the value is exactly 0 outside the affected box (x 200)" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-FLOAT
     MOVE 37 TO WS-X
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-V
     MOVE "acceptance US12 36-1§9.3 the affected box is inflated by 24: x 37 is outside (box to 12), x 36 is inside" TO TL-CASE
     MOVE 0 TO WS-WANT
     PERFORM CHECK-FLOAT
     MOVE 36 TO WS-X
     MOVE 62 TO WS-Y
     MOVE 5 TO WS-Z
     PERFORM EXPECT-SUM
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-V
     MOVE "acceptance US12 36-1§9.3 sampleValue (36, 62, 5): inside the box inflated by 24, the sum" TO TL-CASE
     PERFORM CHECK-FLOAT

*>   the volume: 3 x 4 x 5 grid points from (-4, 56, -4) with steps 4, 8, 4: the value at each point, z outermost, y innermost
     MOVE -4 TO WS-MINX
     MOVE 56 TO WS-MINY
     MOVE -4 TO WS-MINZ
     CALL "STRUCT-BEARD-VOLUME" USING WS-MINX WS-MINY WS-MINZ WS-STEPX WS-STEPY WS-STEPZ WS-SIZEX WS-SIZEY WS-SIZEZ WS-VOL
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-N
     PERFORM VARYING WS-K FROM 0 BY 1 UNTIL WS-K > 4
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 2
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J > 3
                 COMPUTE WS-X = WS-MINX + WS-I * WS-STEPX
                 COMPUTE WS-Y = WS-MINY + WS-J * WS-STEPY
                 COMPUTE WS-Z = WS-MINZ + WS-K * WS-STEPZ
                 CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-WANT
                 ADD 1 TO WS-N
                 COMPUTE WS-DIFF = WS-VAL(WS-N) - WS-WANT
                 IF WS-DIFF > 0.0000001 OR WS-DIFF < -0.0000001
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-1§9.4 sampleVolume: every grid point of a 3 x 4 x 5 volume holds the sample at its block position, in the order z, x, y (index (z * 3 + x) * 4 + y + 1)" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a volume far from the box is all 0, and the buffer is cleared first
     MOVE 1000 TO WS-MINX
     MOVE 7 TO WS-VAL(1)
     CALL "STRUCT-BEARD-VOLUME" USING WS-MINX WS-MINY WS-MINZ WS-STEPX WS-STEPY WS-STEPZ WS-SIZEX WS-SIZEY WS-SIZEZ WS-VOL
     MOVE "acceptance US12 36-1§9.4 sampleVolume: a volume that misses the affected box is all 0 (the buffer is filled with 0 first)" TO TL-CASE
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 60
         IF WS-VAL(WS-N) NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a chunk that nothing references: empty beardifier, value 0, volume 0
     MOVE 30 TO WS-CX
     MOVE 30 TO WS-CZ
     CALL "STRUCT-BEARD-COLLECT" USING WS-CX WS-CZ
     MOVE 3 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "STRUCT-BEARD-SAMPLE" USING WS-X WS-Y WS-Z WS-V
     MOVE "acceptance US12 36-1§13.14 the beardifier of a chunk with no adapting start is 0 everywhere (inactive)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SBD-ACTIVE * 10 + WS-V
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-VAL(1)
     CALL "STRUCT-BEARD-VOLUME" USING WS-MINX WS-MINY WS-MINZ WS-STEPX WS-STEPY WS-STEPZ WS-SIZEX WS-SIZEY WS-SIZEZ WS-VOL
     MOVE "acceptance US12 36-1§9.4 sampleVolume of an inactive beardifier: all 0" TO TL-CASE
     MOVE WS-VAL(1) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the record tables hold 1024 records each; the rest is counted: 1030 rigid pieces, then 60 pieces of 20 junctions
     CALL "STRUCT-STORE-RESET"
     MOVE 1 TO WS-S
     MOVE 0 TO WS-PCX WS-PCZ
     CALL "STRUCT-START-PUT" USING WS-S WS-PCX WS-PCZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     MOVE 60 TO WS-T
     MOVE 1 TO WS-J
     MOVE 0 TO WS-G WS-X0 WS-Z0 WS-Y0
     MOVE 1 TO WS-X1 WS-Y1 WS-Z1
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 1030
         PERFORM ADD-PIECE
     END-PERFORM
     MOVE 0 TO WS-CX WS-CZ
     CALL "STRUCT-REFS-CREATE" USING WS-CX WS-CZ
     CALL "STRUCT-BEARD-COLLECT" USING WS-CX WS-CZ
     MOVE "acceptance US12 36-1§9.2 the record tables: 1030 rigid records fit 1024, six are counted as lost" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SBD-RIGID-COUNT * 1000 + SBD-LOST
     MOVE 1024006 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STRUCT-STORE-RESET"
     CALL "STRUCT-START-PUT" USING WS-S WS-PCX WS-PCZ WS-REFS WS-ROW
     MOVE WS-ROW TO WS-PR
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 60
         PERFORM ADD-PIECE
         MOVE 4 TO WS-X
         MOVE 5 TO WS-Y
         MOVE 6 TO WS-Z
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
             PERFORM ADD-JUNCTION
         END-PERFORM
     END-PERFORM
     CALL "STRUCT-REFS-CREATE" USING WS-CX WS-CZ
     CALL "STRUCT-BEARD-COLLECT" USING WS-CX WS-CZ
     MOVE "acceptance US12 36-1§9.2 the record tables: 1200 junctions fit 1024, 176 are counted as lost" TO TL-CASE
     COMPUTE TL-OBSERVED-N = SBD-JUNC-COUNT * 1000 + SBD-LOST
     MOVE 1024176 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 ADD-PIECE.
     CALL "STRUCT-START-PIECE-ADD" USING WS-PR WS-T WS-O WS-D WS-J WS-G WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-P.

 ADD-JUNCTION.
     CALL "STRUCT-START-JUNCTION-ADD" USING WS-P WS-X WS-Y WS-Z.

*> the expected sum at WS-X, WS-Y, WS-Z in WS-WANT: each record added in list order with FX-OP
 EXPECT-SUM.
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBD-RIGID-COUNT
         MOVE SBR-MODE(WS-I) TO WS-MODE
         MOVE SBR-GROUND(WS-I) TO WS-GROUND
         CALL "STRUCT-BEARD-RIGID" USING WS-MODE SBR-X0(WS-I) SBR-Y0(WS-I) SBR-Z0(WS-I) SBR-X1(WS-I) SBR-Y1(WS-I)
             SBR-Z1(WS-I) WS-GROUND WS-X WS-Y WS-Z WS-A
         CALL "FX-OP" USING WS-OP-ADD WS-SUM WS-A WS-B
         MOVE WS-B TO WS-SUM
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SBD-JUNC-COUNT
         MOVE SBJ-X(WS-I) TO WS-SX
         MOVE SBJ-Y(WS-I) TO WS-SY
         MOVE SBJ-Z(WS-I) TO WS-SZ
         CALL "STRUCT-BEARD-JUNCTION" USING WS-SX WS-SY WS-SZ WS-X WS-Y WS-Z WS-A
         CALL "FX-OP" USING WS-OP-ADD WS-SUM WS-A WS-B
         MOVE WS-B TO WS-SUM
     END-PERFORM
     MOVE WS-SUM TO WS-WANT.

 CHECK-FLOAT.
     COMPUTE WS-DIFF = WS-V - WS-WANT
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF > 0.0000001 OR WS-DIFF < -0.0000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-STRUCT-BEARD.
