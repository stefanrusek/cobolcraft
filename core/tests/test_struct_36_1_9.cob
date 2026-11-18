*> Implementation test of the terrain adaptation and the beardifier (T1312, docs/protocol/36-structures-1-model-placement-starts.md section 9; core/src/struct-36-1-9.cob): the contribution of a rigid record by mode (none,
*> bury, beard_thin, beard_box, encapsulate: dy by mode, 0.8 weights, bury of dx, dy / 2, dz), of a junction (0.4 beard of the offsets), bury (zero from squared distance 36, single precision), the 24 x 24 x 24 kernel
*> entry exp(-(a^2 + (b + 0.5)^2 + c^2) / 16) at i * 576 + j * 24 + k, beard (zero outside the 24 cells, fastInvSqrt Newton step), the close-to-chunk test of 9.2 (inclusive box against the chunk square widened by 12), the strict
*> junction range of 9.2 and the affected box (union inflated by 24). The expected values come from an independent evaluation of the document's formulas (a Python script with float32 rounding of each step) over fixed cases
*> (box 0..4 x 0..3 x 0..4, ground level delta 2, junction source (10, 64, 10)); each is compared to 1e-6 absolute (the values are at most 1 in magnitude and float32 holds 7 digits).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-1-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-A                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-WANT                FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-YB                  BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-G                   BINARY-LONG VALUE 2.
 01 WS-SX                  BINARY-LONG VALUE 10.
 01 WS-SY                  BINARY-LONG VALUE 64.
 01 WS-SZ                  BINARY-LONG VALUE 10.
 01 WS-FLAG                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-MARGIN              BINARY-LONG VALUE 12.
 01 WS-NAME                PIC X(60).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-X0 WS-Y0 WS-Z0
     MOVE 4 TO WS-X1
     MOVE 3 TO WS-Y1
     MOVE 4 TO WS-Z1
     MOVE 0.0 TO WS-A
     MOVE 0.0 TO WS-B
     MOVE 0.0 TO WS-C
     MOVE 1.0 TO WS-WANT
     MOVE "bury(0, 0, 0)" TO WS-NAME
     PERFORM CHECK-BURY
     MOVE 3.0 TO WS-A
     MOVE 0.0 TO WS-B
     MOVE 0.0 TO WS-C
     MOVE 0.5 TO WS-WANT
     MOVE "bury(3, 0, 0)" TO WS-NAME
     PERFORM CHECK-BURY
     MOVE 6.0 TO WS-A
     MOVE 0.0 TO WS-B
     MOVE 0.0 TO WS-C
     MOVE 0.0 TO WS-WANT
     MOVE "bury(6, 0, 0)" TO WS-NAME
     PERFORM CHECK-BURY
     MOVE 1.0 TO WS-A
     MOVE 2.0 TO WS-B
     MOVE 3.0 TO WS-C
     MOVE 0.37639039754867554 TO WS-WANT
     MOVE "bury(1, 2, 3)" TO WS-NAME
     PERFORM CHECK-BURY
     MOVE 2.5 TO WS-A
     MOVE 1.5 TO WS-B
     MOVE 0.5 TO WS-C
     MOVE 0.506993293762207 TO WS-WANT
     MOVE "bury(2.5, 1.5, 0.5)" TO WS-NAME
     PERFORM CHECK-BURY
     MOVE 0.0 TO WS-A
     MOVE 5.9 TO WS-B
     MOVE 0.0 TO WS-C
     MOVE 0.016666650772094727 TO WS-WANT
     MOVE "bury(0, 5.9, 0)" TO WS-NAME
     PERFORM CHECK-BURY
     MOVE 12 TO WS-I
     MOVE 12 TO WS-J
     MOVE 12 TO WS-K
     MOVE 0.9844964146614075 TO WS-WANT
     MOVE "kernel[12, 12, 12]" TO WS-NAME
     PERFORM CHECK-KERNEL
     MOVE 0 TO WS-I
     MOVE 0 TO WS-J
     MOVE 0 TO WS-K
     MOVE 0.00000000000392 TO WS-WANT
     MOVE "kernel[0, 0, 0]" TO WS-NAME
     PERFORM CHECK-KERNEL
     MOVE 23 TO WS-I
     MOVE 23 TO WS-J
     MOVE 23 TO WS-K
     MOVE 0.00000000006944 TO WS-WANT
     MOVE "kernel[23, 23, 23]" TO WS-NAME
     PERFORM CHECK-KERNEL
     MOVE 12 TO WS-I
     MOVE 5 TO WS-J
     MOVE 18 TO WS-K
     MOVE 0.0033355257473886013 TO WS-WANT
     MOVE "kernel[12, 5, 18]" TO WS-NAME
     PERFORM CHECK-KERNEL
     MOVE 0 TO WS-DX
     MOVE 0 TO WS-DY
     MOVE 0 TO WS-DZ
     MOVE 0 TO WS-YB
     MOVE -0.6959697008132935 TO WS-WANT
     MOVE "beard(0, 0, 0, 0)" TO WS-NAME
     PERFORM CHECK-BEARD
     MOVE 3 TO WS-DX
     MOVE -2 TO WS-DY
     MOVE 4 TO WS-DZ
     MOVE -2 TO WS-YB
     MOVE 0.03700249269604683 TO WS-WANT
     MOVE "beard(3, -2, 4, -2)" TO WS-NAME
     PERFORM CHECK-BEARD
     MOVE 11 TO WS-DX
     MOVE 0 TO WS-DY
     MOVE 0 TO WS-DZ
     MOVE 0 TO WS-YB
     MOVE -0.00001639585207 TO WS-WANT
     MOVE "beard(11, 0, 0, 0)" TO WS-NAME
     PERFORM CHECK-BEARD
     MOVE 12 TO WS-DX
     MOVE 0 TO WS-DY
     MOVE 0 TO WS-DZ
     MOVE 0 TO WS-YB
     MOVE 0.0 TO WS-WANT
     MOVE "beard(12, 0, 0, 0)" TO WS-NAME
     PERFORM CHECK-BEARD
     MOVE 0 TO WS-DX
     MOVE 12 TO WS-DY
     MOVE 0 TO WS-DZ
     MOVE 0 TO WS-YB
     MOVE 0.0 TO WS-WANT
     MOVE "beard(0, 12, 0, 0)" TO WS-NAME
     PERFORM CHECK-BEARD
     MOVE 0 TO WS-DX
     MOVE 11 TO WS-DY
     MOVE 0 TO WS-DZ
     MOVE 5 TO WS-YB
     MOVE -0.00018156216538045555 TO WS-WANT
     MOVE "beard(0, 11, 0, 5)" TO WS-NAME
     PERFORM CHECK-BEARD
     MOVE 0 TO WS-DX
     MOVE -12 TO WS-DY
     MOVE 0 TO WS-DZ
     MOVE -12 TO WS-YB
     MOVE 0.00018168652604799718 TO WS-WANT
     MOVE "beard(0, -12, 0, -12)" TO WS-NAME
     PERFORM CHECK-BEARD
     MOVE -5 TO WS-DX
     MOVE 3 TO WS-DY
     MOVE 2 TO WS-DZ
     MOVE 3 TO WS-YB
     MOVE -0.029243463650345802 TO WS-WANT
     MOVE "beard(-5, 3, 2, 3)" TO WS-NAME
     PERFORM CHECK-BEARD
     MOVE 2 TO WS-DX
     MOVE 2 TO WS-DY
     MOVE 2 TO WS-DZ
     MOVE -1 TO WS-YB
     MOVE 0.0504629984498024 TO WS-WANT
     MOVE "beard(2, 2, 2, -1)" TO WS-NAME
     PERFORM CHECK-BEARD
     MOVE 0 TO WS-MODE
     MOVE 2 TO WS-X
     MOVE -3 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.0 TO WS-WANT
     MOVE "none rigid at (2, -3, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 0 TO WS-MODE
     MOVE 8 TO WS-X
     MOVE 5 TO WS-Y
     MOVE -3 TO WS-Z
     MOVE 0.0 TO WS-WANT
     MOVE "none rigid at (8, 5, -3)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 0 TO WS-MODE
     MOVE 2 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.0 TO WS-WANT
     MOVE "none rigid at (2, 1, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 0 TO WS-MODE
     MOVE 1 TO WS-X
     MOVE 4 TO WS-Y
     MOVE 6 TO WS-Z
     MOVE 0.0 TO WS-WANT
     MOVE "none rigid at (1, 4, 6)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 0 TO WS-MODE
     MOVE -2 TO WS-X
     MOVE -4 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.0 TO WS-WANT
     MOVE "none rigid at (-2, -4, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 1 TO WS-MODE
     MOVE 2 TO WS-X
     MOVE -3 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.5833333730697632 TO WS-WANT
     MOVE "bury rigid at (2, -3, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 1 TO WS-MODE
     MOVE 8 TO WS-X
     MOVE 5 TO WS-Y
     MOVE -3 TO WS-Z
     MOVE 0.12997442483901978 TO WS-WANT
     MOVE "bury rigid at (8, 5, -3)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 1 TO WS-MODE
     MOVE 2 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.9166666865348816 TO WS-WANT
     MOVE "bury rigid at (2, 1, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 1 TO WS-MODE
     MOVE 1 TO WS-X
     MOVE 4 TO WS-Y
     MOVE 6 TO WS-Z
     MOVE 0.6273219585418701 TO WS-WANT
     MOVE "bury rigid at (1, 4, 6)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 1 TO WS-MODE
     MOVE -2 TO WS-X
     MOVE -4 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.3990747928619385 TO WS-WANT
     MOVE "bury rigid at (-2, -4, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 2 TO WS-MODE
     MOVE 2 TO WS-X
     MOVE -3 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.15928147733211517 TO WS-WANT
     MOVE "beard_thin rigid at (2, -3, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 2 TO WS-MODE
     MOVE 8 TO WS-X
     MOVE 5 TO WS-Y
     MOVE -3 TO WS-Z
     MOVE -0.03162175789475441 TO WS-WANT
     MOVE "beard_thin rigid at (8, 5, -3)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 2 TO WS-MODE
     MOVE 2 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.5567757487297058 TO WS-WANT
     MOVE "beard_thin rigid at (2, 1, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 2 TO WS-MODE
     MOVE 1 TO WS-X
     MOVE 4 TO WS-Y
     MOVE 6 TO WS-Z
     MOVE -0.2327035516500473 TO WS-WANT
     MOVE "beard_thin rigid at (1, 4, 6)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 2 TO WS-MODE
     MOVE -2 TO WS-X
     MOVE -4 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.06247733160853386 TO WS-WANT
     MOVE "beard_thin rigid at (-2, -4, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 3 TO WS-MODE
     MOVE 2 TO WS-X
     MOVE -3 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.08525723218917847 TO WS-WANT
     MOVE "beard_box rigid at (2, -3, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 3 TO WS-MODE
     MOVE 8 TO WS-X
     MOVE 5 TO WS-Y
     MOVE -3 TO WS-Z
     MOVE -0.04600938782095909 TO WS-WANT
     MOVE "beard_box rigid at (8, 5, -3)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 3 TO WS-MODE
     MOVE 2 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.4913528859615326 TO WS-WANT
     MOVE "beard_box rigid at (2, 1, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 3 TO WS-MODE
     MOVE 1 TO WS-X
     MOVE 4 TO WS-Y
     MOVE 6 TO WS-Z
     MOVE -0.29879721999168396 TO WS-WANT
     MOVE "beard_box rigid at (1, 4, 6)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 3 TO WS-MODE
     MOVE -2 TO WS-X
     MOVE -4 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.029512202367186546 TO WS-WANT
     MOVE "beard_box rigid at (-2, -4, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 4 TO WS-MODE
     MOVE 2 TO WS-X
     MOVE -3 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.6000000238418579 TO WS-WANT
     MOVE "encapsulate rigid at (2, -3, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 4 TO WS-MODE
     MOVE 8 TO WS-X
     MOVE 5 TO WS-Y
     MOVE -3 TO WS-Z
     MOVE 0.44098901748657227 TO WS-WANT
     MOVE "encapsulate rigid at (8, 5, -3)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 4 TO WS-MODE
     MOVE 2 TO WS-X
     MOVE 1 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.800000011920929 TO WS-WANT
     MOVE "encapsulate rigid at (2, 1, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 4 TO WS-MODE
     MOVE 1 TO WS-X
     MOVE 4 TO WS-Y
     MOVE 6 TO WS-Z
     MOVE 0.650928795337677 TO WS-WANT
     MOVE "encapsulate rigid at (1, 4, 6)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 4 TO WS-MODE
     MOVE -2 TO WS-X
     MOVE -4 TO WS-Y
     MOVE 2 TO WS-Z
     MOVE 0.501857578754425 TO WS-WANT
     MOVE "encapsulate rigid at (-2, -4, 2)" TO WS-NAME
     PERFORM CHECK-RIGID
     MOVE 12 TO WS-X
     MOVE 66 TO WS-Y
     MOVE 9 TO WS-Z
     MOVE -0.10426115989685059 TO WS-WANT
     MOVE "junction at (12, 66, 9)" TO WS-NAME
     PERFORM CHECK-JUNCTION
     MOVE 10 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 10 TO WS-Z
     MOVE -0.2783878743648529 TO WS-WANT
     MOVE "junction at (10, 64, 10)" TO WS-NAME
     PERFORM CHECK-JUNCTION
     MOVE 10 TO WS-X
     MOVE 52 TO WS-Y
     MOVE 10 TO WS-Z
     MOVE 0.00007267461478 TO WS-WANT
     MOVE "junction at (10, 52, 10)" TO WS-NAME
     PERFORM CHECK-JUNCTION
     MOVE 20 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 22 TO WS-Z
     MOVE 0.0 TO WS-WANT
     MOVE "junction at (20, 70, 22)" TO WS-NAME
     PERFORM CHECK-JUNCTION
*>   9.2 isCloseToChunk(P, 12): the box intersects the chunk square widened by 12, inclusive, x and z only. Chunk (0, 0) is 0..15; widened -12..27
     MOVE 0 TO WS-CX WS-CZ
     MOVE 28 TO WS-X0
     MOVE 0 TO WS-Z0
     MOVE 30 TO WS-X1
     MOVE 3 TO WS-Z1
     CALL "STRUCT-BEARD-CLOSE" USING WS-X0 WS-Z0 WS-X1 WS-Z1 WS-CX WS-CZ WS-MARGIN WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: a box from x 28 is not close to chunk (0, 0) (the square ends at 15 + 12 = 27)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 27 TO WS-X0
     CALL "STRUCT-BEARD-CLOSE" USING WS-X0 WS-Z0 WS-X1 WS-Z1 WS-CX WS-CZ WS-MARGIN WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: a box from x 27 is close (inclusive end)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -20 TO WS-X0
     MOVE -13 TO WS-X1
     CALL "STRUCT-BEARD-CLOSE" USING WS-X0 WS-Z0 WS-X1 WS-Z1 WS-CX WS-CZ WS-MARGIN WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: a box ending at x -13 is not close (the square starts at -12)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -12 TO WS-X1
     CALL "STRUCT-BEARD-CLOSE" USING WS-X0 WS-Z0 WS-X1 WS-Z1 WS-CX WS-CZ WS-MARGIN WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: a box ending at x -12 is close (inclusive start)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X0
     MOVE 3 TO WS-X1
     MOVE 40 TO WS-Z0
     MOVE 41 TO WS-Z1
     CALL "STRUCT-BEARD-CLOSE" USING WS-X0 WS-Z0 WS-X1 WS-Z1 WS-CX WS-CZ WS-MARGIN WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: z is tested like x (a box at z 40 is not close to chunk (0, 0))" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the junction source range is strict: bx - 12 < srcX < bx + 15 + 12 (chunk (1, -1): bx 16, bz -16): x 5 to 42 exclusive of 4 and 43
     MOVE 1 TO WS-CX
     MOVE -1 TO WS-CZ
     MOVE 4 TO WS-X
     MOVE -16 TO WS-Z
     CALL "STRUCT-BEARD-JUNCTION-IN" USING WS-X WS-Z WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: a junction at x bx - 12 is out (strict)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-X
     CALL "STRUCT-BEARD-JUNCTION-IN" USING WS-X WS-Z WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: a junction at x bx - 11 is in" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 42 TO WS-X
     CALL "STRUCT-BEARD-JUNCTION-IN" USING WS-X WS-Z WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: a junction at x bx + 26 is in" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 43 TO WS-X
     CALL "STRUCT-BEARD-JUNCTION-IN" USING WS-X WS-Z WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: a junction at x bx + 27 is out (strict)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-X
     MOVE -44 TO WS-Z
     CALL "STRUCT-BEARD-JUNCTION-IN" USING WS-X WS-Z WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: a junction at z bz - 28 is out" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -4 TO WS-Z
     CALL "STRUCT-BEARD-JUNCTION-IN" USING WS-X WS-Z WS-CX WS-CZ WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: a junction at z bz + 12 is in" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the affected box is the union inflated by 24 on every axis: zero outside it
     MOVE 0 TO WS-X0 WS-Y0 WS-Z0
     MOVE 4 TO WS-X1
     MOVE 3 TO WS-Y1
     MOVE 4 TO WS-Z1
     MOVE 28 TO WS-X
     MOVE 3 TO WS-Y
     MOVE 4 TO WS-Z
     CALL "STRUCT-BEARD-AFFECTED" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-X WS-Y WS-Z WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: the affected box reaches 24 past maxX (x 28 is inside)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 29 TO WS-X
     CALL "STRUCT-BEARD-AFFECTED" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-X WS-Y WS-Z WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: x 29 is outside the affected box (value 0)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 28 TO WS-X
     MOVE -25 TO WS-Y
     CALL "STRUCT-BEARD-AFFECTED" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-X WS-Y WS-Z WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: y -25 is below the affected box (minY - 24 = -24)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE -24 TO WS-Y
     MOVE -24 TO WS-Z
     CALL "STRUCT-BEARD-AFFECTED" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-X WS-Y WS-Z WS-FLAG
     MOVE "acceptance US12 36-1§9 Terrain adaptation and the beardifier: the corner (28, -24, -24) is inside (inclusive)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-BURY.
     CALL "STRUCT-BURY" USING WS-A WS-B WS-C WS-R
     PERFORM ASSERT-NEAR
     .
 CHECK-KERNEL.
     CALL "STRUCT-BEARD-KERNEL" USING WS-I WS-J WS-K WS-R
     PERFORM ASSERT-NEAR
     .
 CHECK-BEARD.
     CALL "STRUCT-BEARD" USING WS-DX WS-DY WS-DZ WS-YB WS-R
     PERFORM ASSERT-NEAR
     .
 CHECK-RIGID.
     CALL "STRUCT-BEARD-RIGID" USING WS-MODE WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-G WS-X WS-Y WS-Z WS-R
     PERFORM ASSERT-NEAR
     .
 CHECK-JUNCTION.
     CALL "STRUCT-BEARD-JUNCTION" USING WS-SX WS-SY WS-SZ WS-X WS-Y WS-Z WS-R
     PERFORM ASSERT-NEAR
     .
 ASSERT-NEAR.
     COMPUTE WS-DIFF = FUNCTION ABS(WS-R - WS-WANT)
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 36-1§9 Terrain adaptation and the beardifier: " FUNCTION TRIM(WS-NAME) " agrees with the document's formula"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-STRUCT-36-1-9.
