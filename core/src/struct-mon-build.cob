*> The building of the ocean monument (docs/protocol/36-structures-6-ocean.md sections 5.1, 5.7, 5.9 and 5.11): the start (MON-FIND-POINT), the regeneration of the child pieces from the building piece
*> (MON-REGEN) and MonumentBuilding.postProcess (MON-POST, called once per chunk pass whose write box meets the start's piece box). The building is one piece of the builder (SP-TYPE 38, orientation the
*> 2-D data value of the direction: 0 south, 1 west, 2 north, 3 east); the children (rooms, wings, penthouse) are never in the builder and are never saved: every pass rebuilds them from the building's
*> box and orientation and the level seed (5.11), then draws the building and each child that meets the write box. Local coordinates of 5.9 are the building's own (box 58 x 23 x 58).
*> The pieces of the monument use the placement random of the pass (SP-XR) only inside the children (the sponges, the pillar flags).
*>
*> Entry points:
*>   MON-FIND-POINT USING structure row, seed (BINARY-DOUBLE), chunk x, chunk z, x out, y out, z out, valid out: findGenerationPoint (5.1): the biomes within 29 blocks of (chunkMin + 9) must all be in the tag
*>     required_ocean_monument_surrounding (SD-SURR-*), the stub on top of the chunk centre; the builder holds the building piece (box x0 = chunkMinX - 29, y 39 to 61, z0 = chunkMinZ - 29; the direction one nextInt(4))
*>   MON-REGEN USING rng, seed (BINARY-DOUBLE UNSIGNED), chunk x, chunk z, direction of the piece (0 north to 3 west, -1 none), x0, z0: regeneratePiecesAfterLoad (5.11), the layout of MON-LAYOUT
*>   MON-POST USING row: postProcess of the building piece in row
*>   MONP-CELLS USING child: the cells MP-CELL of a child piece (5.8)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-CELLS.
*> USING child (index in MO-CHILD): A is the slot of the child's definition (the grid room of index i is slot i + 1, the wings and the penthouse 76 to 78), B the second cell of a double room (east of A for X and XY,
*> north for Z and YZ), C the cell above A, D the cell above B; a piece without that cell has slot 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CHILD                BINARY-LONG.
 PROCEDURE DIVISION USING L-CHILD.
     MOVE 0 TO MP-CELL(1) MP-CELL(2) MP-CELL(3) MP-CELL(4)
     IF MC-INDEX(L-CHILD) < 75
         COMPUTE WS-A = MC-INDEX(L-CHILD) + 1
     ELSE
         COMPUTE WS-A = MC-INDEX(L-CHILD) - 925
     END-IF
     MOVE WS-A TO MP-CELL(1)
     MOVE 0 TO WS-B
     EVALUATE MC-KIND(L-CHILD)
         WHEN 5
             MOVE MD-CONN(WS-A, 6) TO WS-B
             MOVE WS-B TO MP-CELL(2)
         WHEN 7
             MOVE MD-CONN(WS-A, 3) TO WS-B
             MOVE WS-B TO MP-CELL(2)
         WHEN 6
             MOVE MD-CONN(WS-A, 2) TO MP-CELL(3)
         WHEN 8
             MOVE MD-CONN(WS-A, 6) TO WS-B
             MOVE WS-B TO MP-CELL(2)
             MOVE MD-CONN(WS-A, 2) TO MP-CELL(3)
             MOVE MD-CONN(WS-B, 2) TO MP-CELL(4)
         WHEN 9
             MOVE MD-CONN(WS-A, 3) TO WS-B
             MOVE WS-B TO MP-CELL(2)
             MOVE MD-CONN(WS-A, 2) TO MP-CELL(3)
             MOVE MD-CONN(WS-B, 2) TO MP-CELL(4)
     END-EVALUATE
     GOBACK.
 END PROGRAM MONP-CELLS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-REGEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-4                   BINARY-LONG VALUE 4.
 01 WS-DRAWN               BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-RNG                  BINARY-DOUBLE UNSIGNED.
 01 L-SEED                 BINARY-DOUBLE UNSIGNED.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 PROCEDURE DIVISION USING L-RNG L-SEED L-CX L-CZ L-DIR L-X0 L-Z0.
     CALL "JRAND-LARGE-FEATURE-SEED" USING L-RNG L-SEED L-CX L-CZ
     CALL "JRAND-NEXT-INT-BOUND" USING L-RNG WS-4 WS-DRAWN
     MOVE WS-DRAWN TO WS-DIR
     IF L-DIR >= 0
         MOVE L-DIR TO WS-DIR
     END-IF
     CALL "MON-LAYOUT" USING L-RNG WS-DIR L-X0 L-Z0
     GOBACK.
 END PROGRAM MON-REGEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-WINGS.
*> generateWing(isRight, X) for (false, 0) and (true, 33) (5.9.1): guard chunkIntersects(X, 0, X + 23, 20); rows 1 and 2; loop A (i 0 to 3: six brick lines); rows 3 to 9; the dot pass; rows 10 and 11.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-XO                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-BB                  BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-Y5                  BINARY-LONG VALUE 5.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-XO FROM 0 BY 33 UNTIL WS-XO > 33
         COMPUTE W-X1 = WS-XO + 23
         MOVE WS-XO TO W-X0
         MOVE 0 TO W-Z0
         MOVE 20 TO W-Z1
         CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
         IF W-F = 1
             MOVE WS-XO TO MP-XOFF
             MOVE 12 TO W-CLASS
             MOVE 1 TO W-FROM
             MOVE 2 TO W-TO
             CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
             MOVE 1 TO W-B
             MOVE 20 TO W-Z1
             PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
                 COMPUTE W-X0 = WS-XO + W-I
                 COMPUTE W-Y = W-I + 1
                 MOVE W-I TO W-Z0
                 MOVE W-X0 TO W-X1
                 CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
                 COMPUTE W-X0 = WS-XO + W-I + 7
                 COMPUTE W-Y = W-I + 5
                 COMPUTE W-Z0 = W-I + 7
                 MOVE W-X0 TO W-X1
                 CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
                 COMPUTE W-X0 = WS-XO + 17 - W-I
                 MOVE W-X0 TO W-X1
                 CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
                 COMPUTE W-X0 = WS-XO + 24 - W-I
                 COMPUTE W-Y = W-I + 1
                 MOVE W-I TO W-Z0
                 MOVE W-X0 TO W-X1
                 CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
                 COMPUTE W-X0 = WS-XO + W-I + 1
                 COMPUTE W-X1 = WS-XO + 23 - W-I
                 MOVE W-I TO W-Z0
                 MOVE W-I TO W-Z1
                 CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
                 COMPUTE W-X0 = WS-XO + W-I + 8
                 COMPUTE W-X1 = WS-XO + 16 - W-I
                 COMPUTE W-Y = W-I + 5
                 COMPUTE W-Z0 = W-I + 7
                 MOVE W-Z0 TO W-Z1
                 CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
                 MOVE 20 TO W-Z1
             END-PERFORM
             MOVE 3 TO W-FROM
             MOVE 9 TO W-TO
             CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
*>           the dot pass: a is the dotted line of the outer side (x + 5 left, x + 19 right), b the other
             IF WS-XO = 0
                 MOVE 0 TO WS-RIGHT
                 COMPUTE WS-A = WS-XO + 5
                 COMPUTE WS-BB = WS-XO + 19
             ELSE
                 MOVE 1 TO WS-RIGHT
                 COMPUTE WS-A = WS-XO + 19
                 COMPUTE WS-BB = WS-XO + 5
             END-IF
             PERFORM VARYING W-Z FROM 20 BY -3 UNTIL W-Z < 5
                 CALL "MONP-PUT" USING WS-A WS-Y5 W-Z W-B
             END-PERFORM
             PERFORM VARYING W-Z FROM 19 BY -3 UNTIL W-Z < 7
                 CALL "MONP-PUT" USING WS-BB WS-Y5 W-Z W-B
             END-PERFORM
             MOVE 5 TO W-Z
             PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
                 IF WS-RIGHT = 1
                     COMPUTE W-X = WS-XO + 7 + 3 * W-I
                 ELSE
                     COMPUTE W-X = WS-XO + 17 - 3 * W-I
                 END-IF
                 CALL "MONP-PUT" USING W-X WS-Y5 W-Z W-B
             END-PERFORM
             CALL "MONP-PUT" USING WS-BB WS-Y5 W-Z W-B
             MOVE 10 TO W-FROM
             MOVE 11 TO W-TO
             CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
             MOVE 0 TO MP-XOFF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MONP-WINGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-ARCHS.
*> generateEntranceArchs (5.9.2): guard chunkIntersects(22, 5, 35, 17); the water box (25, 0, 0) to (32, 8, 20); for i 0 to 3 (z = 5 + 4 i) the two arch sides and the prismarine bar.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 PROCEDURE DIVISION.
     MOVE 22 TO W-X0
     MOVE 5 TO W-Z0
     MOVE 35 TO W-X1
     MOVE 17 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 25 TO W-X0
         MOVE 0 TO W-Y0 W-Z0
         MOVE 32 TO W-X1
         MOVE 8 TO W-Y1
         MOVE 20 TO W-Z1
         MOVE 0 TO W-B
         CALL "MONP-OP" USING "W" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-Z = 5 + 4 * W-I
             MOVE W-Z TO W-Z0 W-Z1
             MOVE 1 TO W-B
             MOVE 24 TO W-X
             MOVE 2 TO W-Y0
             MOVE 4 TO W-Y1
             CALL "MONP-BC" USING W-X W-Y0 W-Z W-Y1 W-B
             MOVE 22 TO W-X0
             MOVE 4 TO W-Y
             MOVE 23 TO W-X1
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
             MOVE 25 TO W-X
             MOVE 5 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 26 TO W-X
             MOVE 6 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 4 TO W-B
             MOVE 26 TO W-X
             MOVE 5 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 1 TO W-B
             MOVE 33 TO W-X
             MOVE 2 TO W-Y0
             MOVE 4 TO W-Y1
             CALL "MONP-BC" USING W-X W-Y0 W-Z W-Y1 W-B
             MOVE 34 TO W-X0
             MOVE 4 TO W-Y
             MOVE 35 TO W-X1
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
             MOVE 32 TO W-X
             MOVE 5 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 31 TO W-X
             MOVE 6 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 4 TO W-B
             MOVE 31 TO W-X
             MOVE 5 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 2 TO W-B
             MOVE 27 TO W-X0
             MOVE 6 TO W-Y
             MOVE 30 TO W-X1
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM MONP-ARCHS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-ENTRANCE.
*> generateEntranceWall (5.9.3): guard chunkIntersects(15, 20, 42, 21); rows 1 to 20; loops 1 and 2 (dark prismarine at z 21: the gable lines (28 - i, 6 + i) and (29 + i, 6 + i) for i 0 to 6, (28 - i, 9 + i) and
*> (29 + i, 9 + i) for i 0 to 3); rows 21 and 22; loop 3 (i 0 to 2: (22 - 2 i, 8), (22 - 2 i, 9), (35 + 2 i, 8), (35 + 2 i, 9)); rows 23 to 35.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 01 WS-Z21                 BINARY-LONG VALUE 21.
 PROCEDURE DIVISION.
     MOVE 15 TO W-X0
     MOVE 20 TO W-Z0
     MOVE 42 TO W-X1
     MOVE 21 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 13 TO W-CLASS
         MOVE 1 TO W-FROM
         MOVE 20 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         MOVE 3 TO W-B
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 6
             COMPUTE W-X = 28 - W-I
             COMPUTE W-Y = 6 + W-I
             CALL "MONP-PUT" USING W-X W-Y WS-Z21 W-B
             COMPUTE W-X = 29 + W-I
             CALL "MONP-PUT" USING W-X W-Y WS-Z21 W-B
         END-PERFORM
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-X = 28 - W-I
             COMPUTE W-Y = 9 + W-I
             CALL "MONP-PUT" USING W-X W-Y WS-Z21 W-B
             COMPUTE W-X = 29 + W-I
             CALL "MONP-PUT" USING W-X W-Y WS-Z21 W-B
         END-PERFORM
         MOVE 21 TO W-FROM
         MOVE 22 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 2
             MOVE 8 TO W-Y
             COMPUTE W-X = 22 - 2 * W-I
             CALL "MONP-PUT" USING W-X W-Y WS-Z21 W-B
             COMPUTE W-X = 35 + 2 * W-I
             CALL "MONP-PUT" USING W-X W-Y WS-Z21 W-B
             MOVE 9 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y WS-Z21 W-B
             COMPUTE W-X = 22 - 2 * W-I
             CALL "MONP-PUT" USING W-X W-Y WS-Z21 W-B
         END-PERFORM
         MOVE 23 TO W-FROM
         MOVE 35 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     END-IF
     GOBACK.
 END PROGRAM MONP-ENTRANCE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-ROOF.
*> generateRoofPiece (5.9.4): guard chunkIntersects(21, 21, 36, 36); rows 1 and 2; for i 0 to 3 the four brick lines of the stepped roof; rows 3 to 23.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 PROCEDURE DIVISION.
     MOVE 21 TO W-X0
     MOVE 21 TO W-Z0
     MOVE 36 TO W-X1
     MOVE 36 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 14 TO W-CLASS
         MOVE 1 TO W-FROM
         MOVE 2 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         MOVE 1 TO W-B
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-Y = 13 + W-I
             COMPUTE W-X0 = 21 + W-I
             COMPUTE W-X1 = 36 - W-I
             COMPUTE W-Z0 = 21 + W-I
             MOVE W-Z0 TO W-Z1
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
             COMPUTE W-Z0 = 36 - W-I
             MOVE W-Z0 TO W-Z1
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
             COMPUTE W-X1 = 21 + W-I
             COMPUTE W-Z0 = 22 + W-I
             COMPUTE W-Z1 = 35 - W-I
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
             COMPUTE W-X0 = 36 - W-I
             COMPUTE W-X1 = 36 - W-I
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
         END-PERFORM
         MOVE 3 TO W-FROM
         MOVE 23 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     END-IF
     GOBACK.
 END PROGRAM MONP-ROOF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-LOWER.
*> generateLowerWall (5.9.5), three sections each with its own guard. Section 1 (0, 21, 6, 58): rows 1 to 3, the i loop (i 0 to 3: brick line (i, i + 1, 21) to (i, i + 1, 57 - i)), the dots (5, 5, z) for z 23 to 50 step 3,
*> row 4, the i loop a second time, rows 5 and 6. Section 2 (51, 21, 58, 58): rows 7 to 9, the loop on x 57 - i, the dots (52, 5, z), rows 10 to 12. Section 3 (0, 51, 57, 57): rows 13 and 14, the loop on z 57 - i.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 PROCEDURE DIVISION.
     MOVE 15 TO W-CLASS
     MOVE 1 TO W-B
     MOVE 0 TO W-X0
     MOVE 21 TO W-Z0
     MOVE 6 TO W-X1
     MOVE 58 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 1 TO W-FROM
         MOVE 3 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         PERFORM VARYING W-J FROM 1 BY 1 UNTIL W-J > 2
             PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
                 MOVE W-I TO W-X0 W-X1
                 COMPUTE W-Y = W-I + 1
                 MOVE 21 TO W-Z0
                 COMPUTE W-Z1 = 57 - W-I
                 CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
             END-PERFORM
             IF W-J = 1
                 MOVE 5 TO W-X W-Y
                 PERFORM VARYING W-Z FROM 23 BY 3 UNTIL W-Z >= 53
                     CALL "MONP-PUT" USING W-X W-Y W-Z W-B
                 END-PERFORM
                 MOVE 4 TO W-FROM
                 MOVE 4 TO W-TO
                 CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
             END-IF
         END-PERFORM
         MOVE 5 TO W-FROM
         MOVE 6 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     END-IF
     MOVE 51 TO W-X0
     MOVE 21 TO W-Z0
     MOVE 58 TO W-X1
     MOVE 58 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 7 TO W-FROM
         MOVE 9 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-X0 = 57 - W-I
             MOVE W-X0 TO W-X1
             COMPUTE W-Y = W-I + 1
             MOVE 21 TO W-Z0
             COMPUTE W-Z1 = 57 - W-I
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
         END-PERFORM
         MOVE 52 TO W-X
         MOVE 5 TO W-Y
         PERFORM VARYING W-Z FROM 23 BY 3 UNTIL W-Z > 50
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         END-PERFORM
         MOVE 10 TO W-FROM
         MOVE 12 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     END-IF
     MOVE 0 TO W-X0
     MOVE 51 TO W-Z0
     MOVE 57 TO W-X1
     MOVE 57 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 13 TO W-FROM
         MOVE 14 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-X0 = W-I + 1
             COMPUTE W-X1 = 56 - W-I
             COMPUTE W-Y = W-I + 1
             COMPUTE W-Z0 = 57 - W-I
             MOVE W-Z0 TO W-Z1
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM MONP-LOWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-MIDDLE.
*> generateMiddleWall (5.9.6), three sections. Section 1 (7, 21, 13, 50): rows 1 to 3, the i loop (brick line (7 + i, 5 + i, 21) to (7 + i, 5 + i, 54)), the dots (12, 9, z) for z 21 to 45 step 3. Section 2 (44, 21, 50, 54):
*> rows 4 to 6, the loop on x 50 - i, the dots (45, 9, z). Section 3 (8, 44, 49, 54): rows 7 and 8; for x 12 to 45 step 3 the dots (x, 9, 45) and (x, 9, 52) and, for x in 12, 18, 24, 33, 39, 45, ten more dots; the prismarine
*> lines (8 + i, 5 + i, 54) to (49 - i, 5 + i, 54) for i 0 to 2; rows 9 and 10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 01 WS-XS.
    05 FILLER              PIC 99 VALUE 12.
    05 FILLER              PIC 99 VALUE 18.
    05 FILLER              PIC 99 VALUE 24.
    05 FILLER              PIC 99 VALUE 33.
    05 FILLER              PIC 99 VALUE 39.
    05 FILLER              PIC 99 VALUE 45.
 01 WS-XT REDEFINES WS-XS.
    05 WS-XV               PIC 99 OCCURS 6 TIMES.
 01 WS-DOTS.
    05 FILLER              PIC X(6) VALUE "090047".
    05 FILLER              PIC X(6) VALUE "090050".
    05 FILLER              PIC X(6) VALUE "100045".
    05 FILLER              PIC X(6) VALUE "100046".
    05 FILLER              PIC X(6) VALUE "100051".
    05 FILLER              PIC X(6) VALUE "100052".
    05 FILLER              PIC X(6) VALUE "110047".
    05 FILLER              PIC X(6) VALUE "110050".
    05 FILLER              PIC X(6) VALUE "120048".
    05 FILLER              PIC X(6) VALUE "120049".
 01 WS-DOT-TAB REDEFINES WS-DOTS.
    05 WS-DOT OCCURS 10 TIMES.
       10 WS-DOT-Y         PIC 99.
       10 WS-DOT-Z         PIC 9(4).
 PROCEDURE DIVISION.
     MOVE 16 TO W-CLASS
     MOVE 1 TO W-B
     MOVE 7 TO W-X0
     MOVE 21 TO W-Z0
     MOVE 13 TO W-X1
     MOVE 50 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 1 TO W-FROM
         MOVE 3 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-X0 = 7 + W-I
             MOVE W-X0 TO W-X1
             COMPUTE W-Y = 5 + W-I
             MOVE 21 TO W-Z0
             MOVE 54 TO W-Z1
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
         END-PERFORM
         MOVE 12 TO W-X
         MOVE 9 TO W-Y
         PERFORM VARYING W-Z FROM 21 BY 3 UNTIL W-Z > 45
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         END-PERFORM
     END-IF
     MOVE 44 TO W-X0
     MOVE 21 TO W-Z0
     MOVE 50 TO W-X1
     MOVE 54 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 4 TO W-FROM
         MOVE 6 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-X0 = 50 - W-I
             MOVE W-X0 TO W-X1
             COMPUTE W-Y = 5 + W-I
             MOVE 21 TO W-Z0
             MOVE 54 TO W-Z1
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
         END-PERFORM
         MOVE 45 TO W-X
         MOVE 9 TO W-Y
         PERFORM VARYING W-Z FROM 21 BY 3 UNTIL W-Z > 45
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         END-PERFORM
     END-IF
     MOVE 8 TO W-X0
     MOVE 44 TO W-Z0
     MOVE 49 TO W-X1
     MOVE 54 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 7 TO W-FROM
         MOVE 8 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         MOVE 9 TO W-Y
         PERFORM VARYING W-X FROM 12 BY 3 UNTIL W-X > 45
             MOVE 45 TO W-Z
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 52 TO W-Z
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 0 TO W-K
             PERFORM VARYING W-J FROM 1 BY 1 UNTIL W-J > 6
                 IF WS-XV(W-J) = W-X
                     MOVE 1 TO W-K
                 END-IF
             END-PERFORM
             IF W-K = 1
                 PERFORM VARYING W-J FROM 1 BY 1 UNTIL W-J > 10
                     MOVE WS-DOT-Y(W-J) TO W-Y0
                     MOVE WS-DOT-Z(W-J) TO W-Z
                     CALL "MONP-PUT" USING W-X W-Y0 W-Z W-B
                 END-PERFORM
             END-IF
         END-PERFORM
         MOVE 2 TO W-B
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 2
             COMPUTE W-X0 = 8 + W-I
             COMPUTE W-X1 = 49 - W-I
             COMPUTE W-Y = 5 + W-I
             MOVE 54 TO W-Z0 W-Z1
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
         END-PERFORM
         MOVE 9 TO W-FROM
         MOVE 10 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     END-IF
     GOBACK.
 END PROGRAM MONP-MIDDLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-UPPER.
*> generateUpperWall (5.9.7), three sections. Section 1 (14, 21, 20, 43): rows 1 to 4, the i loop (brick line (14 + i, 9 + i, 21) to (14 + i, 9 + i, 43 - i)), the dots (19, 13, z) for z 23 to 39 step 3. Section 2 (37, 21, 43, 43):
*> rows 5 to 8, the loop on x 43 - i, the dots (38, 13, z). Section 3 (15, 37, 42, 43): rows 9 to 11, the loop (15 + i, 9 + i, 43 - i) to (42 - i, 9 + i, 43 - i), the dots (x, 13, 38) for x 21 to 36 step 3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 PROCEDURE DIVISION.
     MOVE 17 TO W-CLASS
     MOVE 1 TO W-B
     MOVE 14 TO W-X0
     MOVE 21 TO W-Z0
     MOVE 20 TO W-X1
     MOVE 43 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 1 TO W-FROM
         MOVE 4 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-X0 = 14 + W-I
             MOVE W-X0 TO W-X1
             COMPUTE W-Y = 9 + W-I
             MOVE 21 TO W-Z0
             COMPUTE W-Z1 = 43 - W-I
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
         END-PERFORM
         MOVE 19 TO W-X
         MOVE 13 TO W-Y
         PERFORM VARYING W-Z FROM 23 BY 3 UNTIL W-Z > 39
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         END-PERFORM
     END-IF
     MOVE 37 TO W-X0
     MOVE 21 TO W-Z0
     MOVE 43 TO W-X1
     MOVE 43 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 5 TO W-FROM
         MOVE 8 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-X0 = 43 - W-I
             MOVE W-X0 TO W-X1
             COMPUTE W-Y = 9 + W-I
             MOVE 21 TO W-Z0
             COMPUTE W-Z1 = 43 - W-I
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
         END-PERFORM
         MOVE 38 TO W-X
         MOVE 13 TO W-Y
         PERFORM VARYING W-Z FROM 23 BY 3 UNTIL W-Z > 39
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         END-PERFORM
     END-IF
     MOVE 15 TO W-X0
     MOVE 37 TO W-Z0
     MOVE 42 TO W-X1
     MOVE 43 TO W-Z1
     CALL "MONP-CHUNK-INT" USING W-X0 W-Z0 W-X1 W-Z1 W-F
     IF W-F = 1
         MOVE 9 TO W-FROM
         MOVE 11 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-X0 = 15 + W-I
             COMPUTE W-X1 = 42 - W-I
             COMPUTE W-Y = 9 + W-I
             COMPUTE W-Z0 = 43 - W-I
             MOVE W-Z0 TO W-Z1
             CALL "MONP-BH" USING W-X0 W-Y W-Z0 W-X1 W-Z1 W-B
         END-PERFORM
         MOVE 13 TO W-Y
         MOVE 38 TO W-Z
         PERFORM VARYING W-X FROM 21 BY 3 UNTIL W-X > 36
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM MONP-UPPER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-FOUND.
*> The foundation columns of 5.7 step 4: for gx 0 to 6, gz from 0 (to 6 when gz is 0 and gx is 3; then +1 for gx 0 and 6, else +6) while gz < 7: for the 4 x 4 cells (9 gx + a, 9 gz + b) a brick at y 0 and fillColumnDown
*> of bricks from y -1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-GX                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-BB                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-M1                  BINARY-LONG VALUE -1.
 PROCEDURE DIVISION.
     MOVE 1 TO W-B
     MOVE 0 TO W-Y
     MOVE MB-STATE(1) TO WS-STATE
     PERFORM VARYING WS-GX FROM 0 BY 1 UNTIL WS-GX > 6
         MOVE 0 TO WS-GZ
         PERFORM UNTIL WS-GZ >= 7
             IF WS-GZ = 0 AND WS-GX = 3
                 MOVE 6 TO WS-GZ
             END-IF
             PERFORM VARYING WS-A FROM 0 BY 1 UNTIL WS-A > 3
                 PERFORM VARYING WS-BB FROM 0 BY 1 UNTIL WS-BB > 3
                     COMPUTE W-X0 = 9 * WS-GX + WS-A
                     COMPUTE W-Z0 = 9 * WS-GZ + WS-BB
                     MOVE W-X0 TO W-X1
                     MOVE W-Z0 TO W-Z1
                     CALL "MONP-PUT" USING W-X0 W-Y W-Z0 W-B
                     CALL "SCP-COLUMN" USING MP-ROW WS-STATE W-X0 W-Z0 W-X1 W-Z1 WS-M1
                 END-PERFORM
             END-PERFORM
             IF WS-GX = 0 OR WS-GX = 6
                 ADD 1 TO WS-GZ
             ELSE
                 ADD 6 TO WS-GZ
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MONP-FOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-CLEAR.
*> The stepped ring of 5.7 step 5: for i 0 to 4 four water boxes: x -1 - i, x 58 + i (both z from -1 - i to 58 + i), z -1 - i and z 58 + i (x from -i to 57 + i), each from y 2 i to 23.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 PROCEDURE DIVISION.
     MOVE 0 TO W-B
     MOVE 23 TO W-Y1
     PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 4
         COMPUTE W-Y0 = 2 * W-I
         COMPUTE W-X0 = -1 - W-I
         MOVE W-X0 TO W-X1
         COMPUTE W-Z0 = -1 - W-I
         COMPUTE W-Z1 = 58 + W-I
         CALL "MONP-OP" USING "W" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         COMPUTE W-X0 = 58 + W-I
         MOVE W-X0 TO W-X1
         CALL "MONP-OP" USING "W" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         COMPUTE W-X0 = 0 - W-I
         COMPUTE W-X1 = 57 + W-I
         COMPUTE W-Z0 = -1 - W-I
         MOVE W-Z0 TO W-Z1
         CALL "MONP-OP" USING "W" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         COMPUTE W-Z0 = 58 + W-I
         MOVE W-Z0 TO W-Z1
         CALL "MONP-OP" USING "W" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     END-PERFORM
     GOBACK.
 END PROGRAM MONP-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-KIDS.
*> 5.7 step 6: for each child piece in order whose box meets the write box (3-D) its postProcess with the shared random: the child is drawn in the frame of its own box (the scratch row SP-MAX copies the building's
*> orientation) with its cells and design.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 01 WS-I                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==K-==.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SP-MAX TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MO-COUNT
         CALL "SPB-BOX-NEW" USING MC-X0(WS-I) MC-Y0(WS-I) MC-Z0(WS-I) MC-X1(WS-I) MC-Y1(WS-I) MC-Z1(WS-I) WS-BOX
         CALL "SPB-BOX-INTERSECTS" USING WS-BOX SP-WBOX WS-FLAG
         IF WS-FLAG = 1
             MOVE SP-ORIENT(L-ROW) TO SP-ORIENT(WS-ROW)
             MOVE MC-X0(WS-I) TO SP-X0(WS-ROW)
             MOVE MC-Y0(WS-I) TO SP-Y0(WS-ROW)
             MOVE MC-Z0(WS-I) TO SP-Z0(WS-ROW)
             MOVE MC-X1(WS-I) TO SP-X1(WS-ROW)
             MOVE MC-Y1(WS-I) TO SP-Y1(WS-ROW)
             MOVE MC-Z1(WS-I) TO SP-Z1(WS-ROW)
             MOVE WS-ROW TO MP-ROW
             MOVE MC-DESIGN(WS-I) TO MP-DESIGN
             CALL "MONP-CELLS" USING WS-I
             CALL "MONP-PIECE" USING MC-KIND(WS-I)
         END-IF
     END-PERFORM
     MOVE L-ROW TO MP-ROW
     GOBACK.
 END PROGRAM MONP-KIDS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-POST.
*> USING row: MonumentBuilding.postProcess (5.7) of the building piece in row, for the chunk write box SP-WBOX: the layout is made again from the piece (5.11: the chunk of the start from the box minimum,
*> the level seed SP-SEED, the direction of the piece), then (1) the water box up to y 64 (the sea level when higher) minus the box minimum y, (2) the two wings, (3) the archs, the entrance wall, the roof and the lower,
*> middle and upper walls, (4) the foundation columns, (5) the stepped ring, (6) the children.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY STRUCTPIECE.
 COPY FEATLEVEL.
 COPY MONWS.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE SP-X0(L-ROW) TO WS-X0
     MOVE SP-Z0(L-ROW) TO WS-Z0
     COMPUTE WS-CX = (WS-X0 + 29) / 16
     COMPUTE WS-CZ = (WS-Z0 + 29) / 16
     COMPUTE WS-DIR = FUNCTION MOD(SP-ORIENT(L-ROW) + 2, 4)
     COMPUTE WS-USEED = FUNCTION MOD(SP-SEED + WS-M64, WS-M64)
     CALL "MON-REGEN" USING WS-RNG WS-USEED WS-CX WS-CZ WS-DIR WS-X0 WS-Z0
     CALL "MONP-BLOCKS"
     MOVE L-ROW TO MP-ROW
     MOVE 0 TO MP-XOFF MP-DESIGN MP-PILLAR
     COMPUTE WS-TOP = FUNCTION MAX(FL-SEA, 64) - SP-Y0(L-ROW)
     MOVE 0 TO W-X0 W-Y0 W-Z0 W-B
     MOVE 58 TO W-X1 W-Z1
     MOVE WS-TOP TO W-Y1
     CALL "MONP-OP" USING "W" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     CALL "MONP-WINGS"
     CALL "MONP-ARCHS"
     CALL "MONP-ENTRANCE"
     CALL "MONP-ROOF"
     CALL "MONP-LOWER"
     CALL "MONP-MIDDLE"
     CALL "MONP-UPPER"
     CALL "MONP-FOUND"
     CALL "MONP-CLEAR"
     CALL "MONP-KIDS" USING L-ROW
     GOBACK.
 END PROGRAM MON-POST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MON-FIND-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-FLAT                BINARY-LONG.
 01 WS-SEA                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-QX0                 BINARY-LONG.
 01 WS-QX1                 BINARY-LONG.
 01 WS-QY0                 BINARY-LONG.
 01 WS-QY1                 BINARY-LONG.
 01 WS-QZ0                 BINARY-LONG.
 01 WS-QZ1                 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-J                   BINARY-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HEIGHTMAP           BINARY-LONG VALUE 1.
 01 WS-H                   BINARY-LONG.
 01 WS-4                   BINARY-LONG VALUE 4.
 01 WS-DIR                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG VALUE 39.
 01 WS-Y1                  BINARY-LONG VALUE 61.
 01 WS-X1                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==M-==.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-TYPE                BINARY-LONG VALUE 38.
 01 WS-ORIENT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-STRUCT               BINARY-LONG.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-STRUCT L-SEED L-CX L-CZ L-X L-Y L-Z L-VALID.
     CALL "SPB-RESET"
     MOVE 63 TO WS-SEA
     CALL "WORLD-IS-FLAT" USING WS-FLAT
     IF WS-FLAT = 1
         MOVE -63 TO WS-SEA
     END-IF
*>   5.1 steps 2 and 3: every biome of the quart cells within 29 blocks of (chunkMin + 9, sea level) is in required_ocean_monument_surrounding, else the start is absent
     COMPUTE WS-BX = L-CX * 16 + 9
     COMPUTE WS-BZ = L-CZ * 16 + 9
     COMPUTE WS-T = WS-BX - 29
     CALL "STRUCT-QUART" USING WS-T WS-QX0
     COMPUTE WS-T = WS-BX + 29
     CALL "STRUCT-QUART" USING WS-T WS-QX1
     COMPUTE WS-T = WS-SEA - 29
     CALL "STRUCT-QUART" USING WS-T WS-QY0
     COMPUTE WS-T = WS-SEA + 29
     CALL "STRUCT-QUART" USING WS-T WS-QY1
     COMPUTE WS-T = WS-BZ - 29
     CALL "STRUCT-QUART" USING WS-T WS-QZ0
     COMPUTE WS-T = WS-BZ + 29
     CALL "STRUCT-QUART" USING WS-T WS-QZ1
     MOVE 1 TO WS-OK
     PERFORM VARYING WS-QX FROM WS-QX0 BY 1 UNTIL WS-QX > WS-QX1 OR WS-OK = 0
         PERFORM VARYING WS-QY FROM WS-QY0 BY 1 UNTIL WS-QY > WS-QY1 OR WS-OK = 0
             PERFORM VARYING WS-QZ FROM WS-QZ0 BY 1 UNTIL WS-QZ > WS-QZ1 OR WS-OK = 0
                 CALL "STRUCT-BIOME-AT" USING WS-QX WS-QY WS-QZ WS-INDEX WS-BIOME
                 MOVE 0 TO WS-IN
                 PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= SD-SURR-COUNT
                     IF SD-BIOME(SD-SURR-FIRST + WS-J) = WS-BIOME
                         MOVE 1 TO WS-IN
                     END-IF
                 END-PERFORM
                 IF WS-IN = 0
                     MOVE 0 TO WS-OK
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE L-X = L-CX * 16 + 8
     COMPUTE L-Z = L-CZ * 16 + 8
     CALL "STRUCT-BASE-HEIGHT" USING L-X L-Z WS-HEIGHTMAP WS-H
     COMPUTE L-Y = WS-H - 1
     MOVE WS-OK TO L-VALID
     IF WS-OK = 0
         GOBACK
     END-IF
*>   5.1 step 5: the building (the direction is the only draw the start needs; the children are rebuilt by every pass, 5.11)
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED L-CX L-CZ
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-4 WS-DIR
     COMPUTE WS-X0 = L-CX * 16 - 29
     COMPUTE WS-Z0 = L-CZ * 16 - 29
     COMPUTE WS-X1 = WS-X0 + 57
     COMPUTE WS-Z1 = WS-Z0 + 57
     CALL "SPB-BOX-NEW" USING WS-X0 WS-Y0 WS-Z0 WS-X1 WS-Y1 WS-Z1 WS-BOX
     COMPUTE WS-ORIENT = FUNCTION MOD(WS-DIR + 2, 4)
     CALL "SPB-ADD" USING WS-TYPE WS-ORIENT WS-ZERO WS-ZERO2 WS-BOX WS-ROW
     GOBACK.
 END PROGRAM MON-FIND-POINT.
