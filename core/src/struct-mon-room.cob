*> The eleven room, wing and penthouse pieces of the ocean monument (docs/protocol/36-structures-6-ocean.md section 5.8): each program draws one piece through the helpers and rows of
*> struct-mon-geo.cob, in the order of the steps the document gives (floors, the ceiling fill, the draws, the rows and the passes the text describes). The piece is the row MP-ROW, its cells
*> A, B, C and D (5.8: B the second cell of a double room, C the cell above A, D the cell above B) the slots MP-CELL(1) to MP-CELL(4) of the room definitions (STRUCTMON.cpy), its design MP-DESIGN.
*> Entry points: MONP-PIECE USING kind (the child kind of STRUCTMON.cpy: 1 entry, 2 core, 3 simple, 4 simple top, 5 double X, 6 double Y, 7 double Z, 8 double XY, 9 double YZ, 10 wing, 11 penthouse)
*> and one program per kind below. The random is the placement random of the chunk pass (SP-XR, MSP-RNG-INT and MSP-RNG-BOOL of struct-ms-place.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-ENTRY.
*> 5.8.1: rows 1 to 12 (no floor, no ceiling).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 PROCEDURE DIVISION.
     MOVE 1 TO W-CLASS
     MOVE 1 TO W-FROM
     MOVE 12 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     GOBACK.
 END PROGRAM MONP-ENTRY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-SIMPLE.
*> 5.8.2: (1) the floor when the room is not on the bottom layer; (2) the ceiling when there is no up link; (3) the pillar flag, a draw only when the main design is not 0 (mainDesign != 0 and
*> nextBoolean and no opening down or up and more than one opening, left to right); (4) the rows of the design; (5) the three pillar rows.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-A                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-XZ                  BINARY-LONG VALUE 0.
 01 WS-XZ2                 BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE MP-CELL(1) TO WS-A
     IF MD-INDEX(WS-A) >= 25
         MOVE MD-OPEN(WS-A, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-XZ WS-XZ2 WS-OPEN
     END-IF
     MOVE 2 TO W-CLASS
     IF MD-CONN(WS-A, 2) = 0
         MOVE 1 TO W-FROM
         MOVE 1 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     END-IF
     MOVE 0 TO MP-PILLAR
     IF MP-DESIGN NOT = 0
         CALL "MSP-RNG-BOOL" USING W-F
         MOVE 0 TO WS-N
         PERFORM VARYING W-I FROM 1 BY 1 UNTIL W-I > 6
             ADD MD-OPEN(WS-A, W-I) TO WS-N
         END-PERFORM
         IF W-F = 1 AND MD-OPEN(WS-A, 1) = 0 AND MD-OPEN(WS-A, 2) = 0 AND WS-N > 1
             MOVE 1 TO MP-PILLAR
         END-IF
     END-IF
     MOVE 2 TO W-FROM
     MOVE 93 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     IF MP-PILLAR = 1
         MOVE 94 TO W-FROM
         MOVE 96 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     END-IF
     GOBACK.
 END PROGRAM MONP-SIMPLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-TOP.
*> 5.8.3: the floor, the ceiling, the sponge pass (per column of x, z 1 to 6: nextInt(3), 0 skips the column, else nextInt(4) and y0 = 2 when 0 else 3, wet sponge from y0 to 3), rows 2 to 18.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-A                   BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-XZ                  BINARY-LONG VALUE 0.
 01 WS-XZ2                 BINARY-LONG VALUE 0.
 01 WS-3                   BINARY-LONG VALUE 3.
 01 WS-4                   BINARY-LONG VALUE 4.
 01 WS-D                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE MP-CELL(1) TO WS-A
     IF MD-INDEX(WS-A) >= 25
         MOVE MD-OPEN(WS-A, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-XZ WS-XZ2 WS-OPEN
     END-IF
     MOVE 3 TO W-CLASS
     IF MD-CONN(WS-A, 2) = 0
         MOVE 1 TO W-FROM
         MOVE 1 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     END-IF
     MOVE 6 TO W-B
     PERFORM VARYING W-X FROM 1 BY 1 UNTIL W-X > 6
         PERFORM VARYING W-Z FROM 1 BY 1 UNTIL W-Z > 6
             CALL "MSP-RNG-INT" USING WS-3 WS-D
             IF WS-D NOT = 0
                 CALL "MSP-RNG-INT" USING WS-4 WS-D
                 MOVE 3 TO W-Y0
                 IF WS-D = 0
                     MOVE 2 TO W-Y0
                 END-IF
                 MOVE 3 TO W-Y1
                 MOVE W-X TO W-X0 W-X1
                 MOVE W-Z TO W-Z0 W-Z1
                 CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 2 TO W-FROM
     MOVE 18 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     GOBACK.
 END PROGRAM MONP-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-DBLX.
*> 5.8.4: the floors of B (at x 8) and A when not on the bottom layer, rows 1 to 25.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-A                   BINARY-LONG.
 01 WS-BC                  BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-X8                  BINARY-LONG VALUE 8.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE MP-CELL(1) TO WS-A
     MOVE MP-CELL(2) TO WS-BC
     IF MD-INDEX(WS-A) >= 25
         MOVE MD-OPEN(WS-BC, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-X8 WS-ZERO WS-OPEN
         MOVE MD-OPEN(WS-A, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-ZERO WS-ZERO2 WS-OPEN
     END-IF
     MOVE 4 TO W-CLASS
     MOVE 1 TO W-FROM
     MOVE 25 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     GOBACK.
 END PROGRAM MONP-DBLX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-DBLZ.
*> 5.8.5: the floors of B (at z 8) and A when not on the bottom layer, rows 1 to 44.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-A                   BINARY-LONG.
 01 WS-BC                  BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-Z8                  BINARY-LONG VALUE 8.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE MP-CELL(1) TO WS-A
     MOVE MP-CELL(2) TO WS-BC
     IF MD-INDEX(WS-A) >= 25
         MOVE MD-OPEN(WS-BC, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-ZERO WS-Z8 WS-OPEN
         MOVE MD-OPEN(WS-A, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-ZERO WS-ZERO2 WS-OPEN
     END-IF
     MOVE 5 TO W-CLASS
     MOVE 1 TO W-FROM
     MOVE 44 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     GOBACK.
 END PROGRAM MONP-DBLZ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-WALLY.
*> USING cell slot, y0: the wall pass of the double Y room (5.8.6) for one cell: the walls south (z 0, opening of the south slot), north (z 7), west (x 0) and east (x 7); with an opening a doorway framed by
*> pillars at 2 and 5 and a lintel at y0 + 2, else a brick wall with a prismarine band at y0 + 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-FIX                 BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Y1B                 BINARY-LONG.
 01 WS-Y3                  BINARY-LONG.
 01 WS-Y1C                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-CELL                 BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 PROCEDURE DIVISION USING L-CELL L-Y0.
     COMPUTE WS-Y2 = L-Y0 + 2
     COMPUTE WS-Y1B = L-Y0 + 1
     MOVE WS-Y2 TO WS-Y3
     MOVE WS-Y1B TO WS-Y1C
     PERFORM VARYING W-K FROM 1 BY 1 UNTIL W-K > 4
         EVALUATE W-K
             WHEN 1
                 MOVE MD-OPEN(L-CELL, 4) TO WS-OPEN
                 MOVE 0 TO WS-FIX
             WHEN 2
                 MOVE MD-OPEN(L-CELL, 3) TO WS-OPEN
                 MOVE 7 TO WS-FIX
             WHEN 3
                 MOVE MD-OPEN(L-CELL, 5) TO WS-OPEN
                 MOVE 0 TO WS-FIX
             WHEN OTHER
                 MOVE MD-OPEN(L-CELL, 6) TO WS-OPEN
                 MOVE 7 TO WS-FIX
         END-EVALUATE
         MOVE 1 TO W-B
         IF WS-OPEN = 1
             IF W-K <= 2
                 MOVE 2 TO W-X0
                 MOVE 2 TO W-X1
                 MOVE WS-FIX TO W-Z0 W-Z1
                 CALL "MONP-OP" USING "B" W-X0 L-Y0 W-Z0 W-X1 WS-Y2 W-Z1 W-B
                 MOVE 5 TO W-X0 W-X1
                 CALL "MONP-OP" USING "B" W-X0 L-Y0 W-Z0 W-X1 WS-Y2 W-Z1 W-B
                 MOVE 3 TO W-X0
                 MOVE 4 TO W-X1
                 CALL "MONP-OP" USING "B" W-X0 WS-Y2 W-Z0 W-X1 WS-Y3 W-Z1 W-B
             ELSE
                 MOVE WS-FIX TO W-X0 W-X1
                 MOVE 2 TO W-Z0 W-Z1
                 CALL "MONP-OP" USING "B" W-X0 L-Y0 W-Z0 W-X1 WS-Y2 W-Z1 W-B
                 MOVE 5 TO W-Z0 W-Z1
                 CALL "MONP-OP" USING "B" W-X0 L-Y0 W-Z0 W-X1 WS-Y2 W-Z1 W-B
                 MOVE 3 TO W-Z0
                 MOVE 4 TO W-Z1
                 CALL "MONP-OP" USING "B" W-X0 WS-Y2 W-Z0 W-X1 WS-Y3 W-Z1 W-B
             END-IF
         ELSE
             IF W-K <= 2
                 MOVE 0 TO W-X0
                 MOVE 7 TO W-X1
                 MOVE WS-FIX TO W-Z0 W-Z1
             ELSE
                 MOVE WS-FIX TO W-X0 W-X1
                 MOVE 0 TO W-Z0
                 MOVE 7 TO W-Z1
             END-IF
             CALL "MONP-OP" USING "B" W-X0 L-Y0 W-Z0 W-X1 WS-Y2 W-Z1 W-B
             MOVE 2 TO W-B
             CALL "MONP-OP" USING "B" W-X0 WS-Y1B W-Z0 W-X1 WS-Y1C W-Z1 W-B
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MONP-WALLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-DBLY.
*> 5.8.6: the floor of A when not on the bottom layer, row 1 (the ceiling of the upper cell when it has no up link), rows 2 to 13, the wall pass of A (y0 1) and of the upper cell (y0 5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-A                   BINARY-LONG.
 01 WS-U                   BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-Y1                  BINARY-LONG VALUE 1.
 01 WS-Y5                  BINARY-LONG VALUE 5.
 PROCEDURE DIVISION.
     MOVE MP-CELL(1) TO WS-A
     MOVE MP-CELL(3) TO WS-U
     IF MD-INDEX(WS-A) >= 25
         MOVE MD-OPEN(WS-A, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-ZERO WS-ZERO2 WS-OPEN
     END-IF
     MOVE 6 TO W-CLASS
     MOVE 1 TO W-FROM
     MOVE 13 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     CALL "MONP-WALLY" USING WS-A WS-Y1
     CALL "MONP-WALLY" USING WS-U WS-Y5
     GOBACK.
 END PROGRAM MONP-DBLY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-DBLXY.
*> 5.8.7: the floors, the two ceiling rows, the column pass (y 1 to 7: prismarine when y is 2 or 6, else bricks; the west, east, south and north wall lines), rows 3 to 37.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-A                   BINARY-LONG.
 01 WS-BC                  BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-X8                  BINARY-LONG VALUE 8.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE MP-CELL(1) TO WS-A
     MOVE MP-CELL(2) TO WS-BC
     IF MD-INDEX(WS-A) >= 25
         MOVE MD-OPEN(WS-BC, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-X8 WS-ZERO WS-OPEN
         MOVE MD-OPEN(WS-A, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-ZERO WS-ZERO2 WS-OPEN
     END-IF
     MOVE 7 TO W-CLASS
     MOVE 1 TO W-FROM
     MOVE 2 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     PERFORM VARYING W-Y FROM 1 BY 1 UNTIL W-Y > 7
         MOVE W-Y TO W-Y0 W-Y1
         MOVE 1 TO W-B
         IF W-Y = 2 OR W-Y = 6
             MOVE 2 TO W-B
         END-IF
         MOVE 0 TO W-X0 W-X1 W-Z0
         MOVE 7 TO W-Z1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         MOVE 15 TO W-X0 W-X1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         MOVE 1 TO W-X0
         MOVE 0 TO W-Z1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         MOVE 14 TO W-X1
         MOVE 7 TO W-Z0 W-Z1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     END-PERFORM
     MOVE 3 TO W-FROM
     MOVE 37 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     GOBACK.
 END PROGRAM MONP-DBLXY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-DBLYZ.
*> 5.8.8: the floors (B at z 8), the two ceiling rows, wall pass 1 (y 1 to 7: prismarine when y is 2 or 6, else bricks), wall pass 2 (sea lantern when y is 2 or 6, else dark prismarine: (3, y, 7) to
*> (4, y, 8)), rows 3 to 26.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-A                   BINARY-LONG.
 01 WS-BC                  BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-Z8                  BINARY-LONG VALUE 8.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE MP-CELL(1) TO WS-A
     MOVE MP-CELL(2) TO WS-BC
     IF MD-INDEX(WS-A) >= 25
         MOVE MD-OPEN(WS-BC, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-ZERO WS-Z8 WS-OPEN
         MOVE MD-OPEN(WS-A, 1) TO WS-OPEN
         CALL "MONP-FLOOR" USING WS-ZERO WS-ZERO2 WS-OPEN
     END-IF
     MOVE 8 TO W-CLASS
     MOVE 1 TO W-FROM
     MOVE 2 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     PERFORM VARYING W-Y FROM 1 BY 1 UNTIL W-Y > 7
         MOVE W-Y TO W-Y0 W-Y1
         MOVE 1 TO W-B
         IF W-Y = 2 OR W-Y = 6
             MOVE 2 TO W-B
         END-IF
         MOVE 0 TO W-X0 W-X1 W-Z0
         MOVE 15 TO W-Z1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         MOVE 7 TO W-X0 W-X1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         MOVE 1 TO W-X0
         MOVE 6 TO W-X1
         MOVE 0 TO W-Z1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         MOVE 15 TO W-Z0 W-Z1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     END-PERFORM
     PERFORM VARYING W-Y FROM 1 BY 1 UNTIL W-Y > 7
         MOVE W-Y TO W-Y0 W-Y1
         MOVE 3 TO W-B
         IF W-Y = 2 OR W-Y = 6
             MOVE 4 TO W-B
         END-IF
         MOVE 3 TO W-X0
         MOVE 4 TO W-X1
         MOVE 7 TO W-Z0
         MOVE 8 TO W-Z1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     END-PERFORM
     MOVE 3 TO W-FROM
     MOVE 26 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     GOBACK.
 END PROGRAM MONP-DBLYZ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-CORE.
*> 5.8.9: row 1 (the ceiling), the rim at y 7, the wall pass (y 1 to 6, prismarine when y is 2 or 6; x 0 and 15, then the south and north lines), rows 2 and 3, the lantern pass (y 3 and 6, x 6 and 9, at z 6 and 9), rows 4 to 31.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 01 WS-XS.
    05 FILLER              PIC 99 VALUE 0.
    05 FILLER              PIC 99 VALUE 15.
 01 WS-XT REDEFINES WS-XS.
    05 WS-XV               PIC 99 OCCURS 2 TIMES.
 PROCEDURE DIVISION.
     MOVE 9 TO W-CLASS
     MOVE 1 TO W-FROM
     MOVE 1 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     MOVE 1 TO W-B
     MOVE 7 TO W-Y0 W-Y1
     MOVE 0 TO W-X0 W-X1 W-Z0
     MOVE 15 TO W-Z1
     CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     MOVE 15 TO W-X0 W-X1
     CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     MOVE 1 TO W-X0
     MOVE 0 TO W-Z1
     CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     MOVE 14 TO W-X1
     MOVE 15 TO W-Z0 W-Z1
     CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     PERFORM VARYING W-Y FROM 1 BY 1 UNTIL W-Y > 6
         MOVE W-Y TO W-Y0 W-Y1
         MOVE 1 TO W-B
         IF W-Y = 2 OR W-Y = 6
             MOVE 2 TO W-B
         END-IF
         PERFORM VARYING W-J FROM 1 BY 1 UNTIL W-J > 2
             MOVE WS-XV(W-J) TO W-X0 W-X1
             MOVE 0 TO W-Z0
             MOVE 1 TO W-Z1
             CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
             MOVE 6 TO W-Z0
             MOVE 9 TO W-Z1
             CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
             MOVE 14 TO W-Z0
             MOVE 15 TO W-Z1
             CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         END-PERFORM
         MOVE 1 TO W-X0 W-X1
         MOVE 0 TO W-Z0 W-Z1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         MOVE 6 TO W-X0
         MOVE 9 TO W-X1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         MOVE 14 TO W-X0 W-X1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         MOVE 1 TO W-X0
         MOVE 15 TO W-Z0 W-Z1
         CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
     END-PERFORM
     MOVE 2 TO W-FROM
     MOVE 3 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     MOVE 4 TO W-B
     PERFORM VARYING W-J FROM 3 BY 3 UNTIL W-J > 6
         MOVE W-J TO W-Y
         PERFORM VARYING W-I FROM 6 BY 3 UNTIL W-I > 9
             MOVE W-I TO W-X
             MOVE 6 TO W-Z
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 9 TO W-Z
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         END-PERFORM
     END-PERFORM
     MOVE 4 TO W-FROM
     MOVE 31 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     GOBACK.
 END PROGRAM MONP-CORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-WING.
*> 5.8.10: design 0: the four stair boxes of z 20 - i, rows 1 to 13, the lanterns at z 18, 15, 12, 9, rows 14 to 36 (the last the elder). Design 1: rows 37 to 39, the three posts at x 9 and 13, row 40,
*> the pillars at x 10 and 12 with their lanterns, the posts at x 8 and 14, rows 41 to 43.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMON.
 COPY MONWS.
 01 WS-S                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 10 TO W-CLASS
     IF MP-DESIGN = 0
         MOVE 1 TO W-B
         PERFORM VARYING W-I FROM 0 BY 1 UNTIL W-I > 3
             COMPUTE W-X0 = 10 - W-I
             COMPUTE W-Y0 = 3 - W-I
             COMPUTE W-Z0 = 20 - W-I
             COMPUTE W-X1 = 12 + W-I
             MOVE W-Y0 TO W-Y1
             MOVE 20 TO W-Z1
             CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         END-PERFORM
         MOVE 1 TO W-FROM
         MOVE 13 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         MOVE 4 TO W-B
         MOVE 3 TO W-Y
         PERFORM VARYING W-Z FROM 18 BY -3 UNTIL W-Z < 9
             MOVE 6 TO W-X
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 16 TO W-X
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         END-PERFORM
         MOVE 14 TO W-FROM
         MOVE 36 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     ELSE
         MOVE 37 TO W-FROM
         MOVE 39 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         MOVE 20 TO W-Z
         PERFORM VARYING W-X FROM 9 BY 4 UNTIL W-X > 13
             MOVE 1 TO W-B
             MOVE 6 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 4 TO W-B
             MOVE 5 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 1 TO W-B
             MOVE 4 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         END-PERFORM
         MOVE 40 TO W-FROM
         MOVE 40 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
         PERFORM VARYING W-X FROM 10 BY 2 UNTIL W-X > 12
             MOVE 1 TO W-B
             MOVE 0 TO W-Y0
             MOVE 6 TO W-Y1
             MOVE W-X TO W-X0 W-X1
             MOVE 10 TO W-Z0 W-Z1
             CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
             MOVE 12 TO W-Z0 W-Z1
             CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
             MOVE 4 TO W-B
             MOVE 0 TO W-Y
             MOVE 10 TO W-Z
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 12 TO W-Z
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 4 TO W-Y
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
             MOVE 10 TO W-Z
             CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         END-PERFORM
         PERFORM VARYING W-X FROM 8 BY 6 UNTIL W-X > 14
             MOVE 1 TO W-B
             MOVE 0 TO W-Y0
             MOVE 2 TO W-Y1
             MOVE W-X TO W-X0 W-X1
             MOVE 7 TO W-Z0 W-Z1
             CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
             MOVE 14 TO W-Z0 W-Z1
             CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         END-PERFORM
         MOVE 41 TO W-FROM
         MOVE 43 TO W-TO
         CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     END-IF
     GOBACK.
 END PROGRAM MONP-WING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-PENT.
*> 5.8.11: rows 1 to 9, the lanterns at v = 2, 5, 8, 11 (x 0 and 13 at z = v, z 0 at x = v), rows 10 to 19, the pillars at x 3 and 10, z 2, 5, 8, rows 20 to 24 (the last the elder).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY MONWS.
 PROCEDURE DIVISION.
     MOVE 11 TO W-CLASS
     MOVE 1 TO W-FROM
     MOVE 9 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     MOVE 4 TO W-B
     MOVE 0 TO W-Y
     PERFORM VARYING W-J FROM 2 BY 3 UNTIL W-J > 11
         MOVE 0 TO W-X
         MOVE W-J TO W-Z
         CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         MOVE 13 TO W-X
         CALL "MONP-PUT" USING W-X W-Y W-Z W-B
         MOVE W-J TO W-X
         MOVE 0 TO W-Z
         CALL "MONP-PUT" USING W-X W-Y W-Z W-B
     END-PERFORM
     MOVE 10 TO W-FROM
     MOVE 19 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     MOVE 1 TO W-B
     MOVE 0 TO W-Y0
     MOVE 2 TO W-Y1
     PERFORM VARYING W-X FROM 3 BY 7 UNTIL W-X > 10
         PERFORM VARYING W-Z FROM 2 BY 3 UNTIL W-Z > 8
             MOVE W-X TO W-X0 W-X1
             MOVE W-Z TO W-Z0 W-Z1
             CALL "MONP-OP" USING "B" W-X0 W-Y0 W-Z0 W-X1 W-Y1 W-Z1 W-B
         END-PERFORM
     END-PERFORM
     MOVE 20 TO W-FROM
     MOVE 24 TO W-TO
     CALL "MONP-ROWS" USING W-CLASS W-FROM W-TO
     GOBACK.
 END PROGRAM MONP-PENT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MONP-PIECE.
*> USING kind (the child kind of STRUCTMON.cpy): draws that piece in the frame MP-ROW with the cells MP-CELL and the design MP-DESIGN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND.
     EVALUATE L-KIND
         WHEN 1
             CALL "MONP-ENTRY"
         WHEN 2
             CALL "MONP-CORE"
         WHEN 3
             CALL "MONP-SIMPLE"
         WHEN 4
             CALL "MONP-TOP"
         WHEN 5
             CALL "MONP-DBLX"
         WHEN 6
             CALL "MONP-DBLY"
         WHEN 7
             CALL "MONP-DBLZ"
         WHEN 8
             CALL "MONP-DBLXY"
         WHEN 9
             CALL "MONP-DBLYZ"
         WHEN 10
             CALL "MONP-WING"
         WHEN OTHER
             CALL "MONP-PENT"
     END-EVALUATE
     GOBACK.
 END PROGRAM MONP-PIECE.
