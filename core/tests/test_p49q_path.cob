*> The open list of STDMOB-PATH (lane 002-lane-p49q, T37001): a binary heap instead of a scan of every node for the least f. The result must be the same as the scan's for the same input: this test
*> keeps the old program as STDMOB-PATH-REF (a copy of the scan version, in this file only) and compares the two on random grids (a stone floor with walls one and two high and holes, 10 grids, 60 searches each:
*> random start, target within 14 blocks (often unreachable, so the closest node decides), height 1 or 2, budget 20, 100 or 400): count, reached and every cell of the path must be equal. The
*> CPU time of the two over the same searches is shown (PATHBENCH, the C clock in microseconds summed over the searches) and the new one must not be above 1.25 times the old one's. A sample of the
*> searches shows the time is in STDMOB-STANDABLE and STDMOB-CELL (the world lookups), not in the open list: the heap makes the open list safe for larger budgets, it does not make these searches faster.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-P49Q-PATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-QUOT                BINARY-DOUBLE.
 01 WS-RND                 BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-HEIGHT              BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG.
 01 WS-BUDGETS-DATA.
    05 FILLER              BINARY-LONG VALUE 20.
    05 FILLER              BINARY-LONG VALUE 100.
    05 FILLER              BINARY-LONG VALUE 400.
 01 WS-BUDGETS REDEFINES WS-BUDGETS-DATA.
    05 WS-BUDGET-OF        BINARY-LONG OCCURS 3 TIMES.
 01 WS-PATH-A.
    05 WS-CELL-A OCCURS 128 TIMES.
       10 WS-AX            BINARY-LONG.
       10 WS-AY            BINARY-LONG.
       10 WS-AZ            BINARY-LONG.
 01 WS-PATH-B.
    05 WS-CELL-B OCCURS 128 TIMES.
       10 WS-BX            BINARY-LONG.
       10 WS-BY            BINARY-LONG.
       10 WS-BZ            BINARY-LONG.
 01 WS-COUNT-A             BINARY-LONG.
 01 WS-COUNT-B             BINARY-LONG.
 01 WS-REACHED-A           BINARY-LONG.
 01 WS-REACHED-B           BINARY-LONG.
 01 WS-MISMATCH            BINARY-LONG VALUE 0.
 01 WS-REACHED-N           BINARY-LONG VALUE 0.
 01 WS-LONG-N              BINARY-LONG VALUE 0.
 01 WS-SEARCHES            BINARY-LONG VALUE 0.
 01 WS-CLOCK0              BINARY-DOUBLE.
 01 WS-CLOCK1              BINARY-DOUBLE.
 01 WS-REF-US              BINARY-DOUBLE VALUE 0.
 01 WS-NEW-US              BINARY-DOUBLE VALUE 0.
 01 WS-RATIO-US            BINARY-DOUBLE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 10
         CALL "VT-FLAT" USING WS-PLAYER WS-FY
         COMPUTE WS-Y = WS-FY + 1
         COMPUTE WS-Y2 = WS-FY + 2
         PERFORM 160 TIMES
             MOVE 24 TO WS-RANGE
             PERFORM NEXT-RAND
             COMPUTE WS-X = WS-X0 - 12 + WS-RND
             PERFORM NEXT-RAND
             COMPUTE WS-Z = WS-Z0 - 12 + WS-RND
             MOVE 4 TO WS-RANGE
             PERFORM NEXT-RAND
             MOVE SPACES TO WS-PAIRS
             EVALUATE WS-RND
                 WHEN 0
                 WHEN 1
                     MOVE "minecraft:stone" TO WS-KEY
                     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
                 WHEN 2
                     MOVE "minecraft:stone" TO WS-KEY
                     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z WS-KEY WS-PAIRS
                     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y2 WS-Z WS-KEY WS-PAIRS
                 WHEN OTHER
                     MOVE "minecraft:air" TO WS-KEY
                     CALL "VT-PLACE" USING WS-DIM WS-X WS-FY WS-Z WS-KEY WS-PAIRS
             END-EVALUATE
         END-PERFORM
         PERFORM VARYING WS-Q FROM 1 BY 1 UNTIL WS-Q > 60
             MOVE 21 TO WS-RANGE
             PERFORM NEXT-RAND
             COMPUTE WS-SX = WS-X0 - 10 + WS-RND
             PERFORM NEXT-RAND
             COMPUTE WS-SZ = WS-Z0 - 10 + WS-RND
             MOVE 29 TO WS-RANGE
             PERFORM NEXT-RAND
             COMPUTE WS-TX = WS-SX - 14 + WS-RND
             PERFORM NEXT-RAND
             COMPUTE WS-TZ = WS-SZ - 14 + WS-RND
             COMPUTE WS-HEIGHT = 1 + FUNCTION MOD(WS-Q, 2)
             COMPUTE WS-BUDGET = WS-BUDGET-OF(1 + FUNCTION MOD(WS-Q, 3))
             MOVE 0 TO WS-COUNT-A WS-COUNT-B
             CALL STATIC "clock" RETURNING WS-CLOCK0
             CALL "STDMOB-PATH-REF" USING WS-DIM WS-SX WS-Y WS-SZ WS-TX WS-Y WS-TZ WS-HEIGHT WS-BUDGET WS-PATH-A WS-COUNT-A WS-REACHED-A
             CALL STATIC "clock" RETURNING WS-CLOCK1
             COMPUTE WS-REF-US = WS-REF-US + WS-CLOCK1 - WS-CLOCK0
             CALL STATIC "clock" RETURNING WS-CLOCK0
             CALL "STDMOB-PATH" USING WS-DIM WS-SX WS-Y WS-SZ WS-TX WS-Y WS-TZ WS-HEIGHT WS-BUDGET WS-PATH-B WS-COUNT-B WS-REACHED-B
             CALL STATIC "clock" RETURNING WS-CLOCK1
             COMPUTE WS-NEW-US = WS-NEW-US + WS-CLOCK1 - WS-CLOCK0
             ADD 1 TO WS-SEARCHES
             IF WS-COUNT-A NOT = WS-COUNT-B OR WS-REACHED-A NOT = WS-REACHED-B
                 ADD 1 TO WS-MISMATCH
             ELSE
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT-A
                     IF WS-AX(WS-K) NOT = WS-BX(WS-K) OR WS-AY(WS-K) NOT = WS-BY(WS-K) OR WS-AZ(WS-K) NOT = WS-BZ(WS-K)
                         ADD 1 TO WS-MISMATCH
                         MOVE 129 TO WS-K
                     END-IF
                 END-PERFORM
             END-IF
             IF WS-REACHED-A = 1
                 ADD 1 TO WS-REACHED-N
             END-IF
             IF WS-COUNT-A > 10
                 ADD 1 TO WS-LONG-N
             END-IF
         END-PERFORM
     END-PERFORM
     DISPLAY "PATHBENCH searches " WS-SEARCHES " reached " WS-REACHED-N " longer than 10 cells " WS-LONG-N " cpu us ref " WS-REF-US " new " WS-NEW-US
     MOVE "test p49q the heap finds the same path as the scan on 600 random searches" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-MISMATCH TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "test p49q the searches are not vacuous (reached 100 or more, 100 or more over 10 cells)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-REACHED-N >= 100 AND WS-LONG-N >= 100
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "test p49q the heap takes no more than 1.25 times the scan's CPU time" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     COMPUTE WS-RATIO-US = WS-NEW-US * 100
     IF WS-RATIO-US <= WS-REF-US * 125
         MOVE 1 TO WS-O
     END-IF
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     STOP RUN.
 NEXT-RAND.
     COMPUTE WS-SEED = WS-SEED * 1103515245 + 12345
     DIVIDE WS-SEED BY 2147483648 GIVING WS-QUOT REMAINDER WS-SEED
     DIVIDE WS-SEED BY 65536 GIVING WS-QUOT
     DIVIDE WS-QUOT BY WS-RANGE GIVING WS-QUOT REMAINDER WS-RND.
 END PROGRAM TEST-P49Q-PATH.

*> The scan version of the open list (the program before lane p49q), kept for the comparison.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PATH-REF.
*> USING dim, start x, y, z, target x, y, z (BINARY-LONG feet cells), height (1 or 2), budget (BINARY-LONG: nodes it may expand), path (128 x, y, z cells),
*> count out (cells in the path, start first; 0 = no path), reached out (1 when the last cell is the target).
*> The weighted A* of 18 section 5.2 over the walk neighbours of 5.3, simplified: a node is a standable feet cell (STDMOB-STANDABLE); its neighbours
*> are the four horizontal ones, the same level when standable, one up when the cell ahead is solid and standable above it with head room
*> over the current cell, and down by 1 to 3 when the cell ahead is passable with no floor; no diagonals. Step cost sqrt(1 + dy squared), heuristic 1.5 x
*> the Euclidean distance to the target, nodes never farther than 15 blocks horizontally from the start or 8 below / 15 above it. The search pops
*> the open node of the least f at most `budget` times; it ends at the target, or when the open set is empty or the budget used, with the path to
*> the node that came closest (the least heuristic). A start that is not standable moves down to a floor within 3 cells, else there is no path.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NODES.
    05 WS-NODE OCCURS 1024 TIMES.
       10 WN-X             BINARY-LONG.
       10 WN-Y             BINARY-LONG.
       10 WN-Z             BINARY-LONG.
       10 WN-G             FLOAT-LONG.
       10 WN-F             FLOAT-LONG.
       10 WN-H             FLOAT-LONG.
       10 WN-PARENT        BINARY-LONG.
       10 WN-STATE         BINARY-LONG.
 01 WS-GRID-TABLE.
    05 WS-GRID             BINARY-LONG OCCURS 24576 TIMES.
 01 WS-NODE-COUNT          BINARY-LONG.
 01 WS-POPPED              BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-GX                  BINARY-LONG.
 01 WS-GY                  BINARY-LONG.
 01 WS-GZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-LEAST               FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-TENT                FLOAT-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-CHAIN.
    05 WS-LINK             BINARY-LONG OCCURS 1024 TIMES.
 01 WS-DIRX-DATA.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DIRX REDEFINES WS-DIRX-DATA.
    05 WS-DX-OF            BINARY-LONG OCCURS 4 TIMES.
 01 WS-DIRZ-DATA.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE -1.
 01 WS-DIRZ REDEFINES WS-DIRZ-DATA.
    05 WS-DZ-OF            BINARY-LONG OCCURS 4 TIMES.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-TX                   BINARY-LONG.
 01 L-TY                   BINARY-LONG.
 01 L-TZ                   BINARY-LONG.
 01 L-HEIGHT               BINARY-LONG.
 01 L-BUDGET               BINARY-LONG.
 01 L-PATH.
    05 L-CELL OCCURS 128 TIMES.
       10 L-PX             BINARY-LONG.
       10 L-PY             BINARY-LONG.
       10 L-PZ             BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-REACHED              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-SX L-SY L-SZ L-TX L-TY L-TZ L-HEIGHT L-BUDGET L-PATH L-COUNT L-REACHED.
     MOVE 0 TO L-COUNT L-REACHED
     MOVE L-SY TO WS-NY
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3 OR WS-FOUND = 1
         COMPUTE WS-Y = L-SY - WS-D
         CALL "STDMOB-STANDABLE" USING L-DIM L-SX WS-Y L-SZ L-HEIGHT WS-OK
         IF WS-OK = 1
             MOVE WS-Y TO WS-NY
             MOVE 1 TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         GOBACK
     END-IF
     INITIALIZE WS-GRID-TABLE
     MOVE 1 TO WS-NODE-COUNT
     MOVE L-SX TO WN-X(1)
     MOVE WS-NY TO WN-Y(1)
     MOVE L-SZ TO WN-Z(1)
     MOVE 0 TO WN-G(1) WN-PARENT(1) WN-STATE(1)
     COMPUTE WS-DX = WN-X(1) - L-TX
     COMPUTE WS-DY = WN-Y(1) - L-TY
     COMPUTE WS-DZ = WN-Z(1) - L-TZ
     COMPUTE WN-H(1) = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
     COMPUTE WN-F(1) = 1.5 * WN-H(1)
     MOVE 1 TO WS-GRID(((16 * 32) + 16) * 24 + 8 + 1)
     MOVE 1 TO WS-BEST
     MOVE WN-H(1) TO WS-LEAST
     MOVE 0 TO WS-POPPED WS-DONE
     PERFORM UNTIL WS-DONE = 1
         MOVE 0 TO WS-CUR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NODE-COUNT
             IF WN-STATE(WS-I) = 0 AND (WS-CUR = 0 OR WN-F(WS-I) < WN-F(WS-CUR))
                 MOVE WS-I TO WS-CUR
             END-IF
         END-PERFORM
         IF WS-CUR = 0 OR WS-POPPED >= L-BUDGET
             MOVE 1 TO WS-DONE
         ELSE
             ADD 1 TO WS-POPPED
             MOVE 1 TO WN-STATE(WS-CUR)
             IF WN-X(WS-CUR) = L-TX AND WN-Y(WS-CUR) = L-TY AND WN-Z(WS-CUR) = L-TZ
                 MOVE WS-CUR TO WS-BEST
                 MOVE 1 TO L-REACHED
                 MOVE 1 TO WS-DONE
             ELSE
                 PERFORM VARYING WS-DIR FROM 1 BY 1 UNTIL WS-DIR > 4
                     COMPUTE WS-NX = WN-X(WS-CUR) + WS-DX-OF(WS-DIR)
                     COMPUTE WS-NZ = WN-Z(WS-CUR) + WS-DZ-OF(WS-DIR)
                     MOVE -1000 TO WS-CAND
                     MOVE WN-Y(WS-CUR) TO WS-Y
                     CALL "STDMOB-STANDABLE" USING L-DIM WS-NX WS-Y WS-NZ L-HEIGHT WS-OK
                     IF WS-OK = 1
                         MOVE WS-Y TO WS-CAND
                     ELSE
                         CALL "STDMOB-CELL" USING L-DIM WS-NX WS-Y WS-NZ WS-TYPE
                         EVALUATE WS-TYPE
                             WHEN 1
                                 COMPUTE WS-NY = WN-Y(WS-CUR) + 1
                                 COMPUTE WS-Y = WN-Y(WS-CUR) + L-HEIGHT
                                 CALL "STDMOB-CELL" USING L-DIM WN-X(WS-CUR) WS-Y WN-Z(WS-CUR) WS-TYPE
                                 IF WS-TYPE = 0
                                     CALL "STDMOB-STANDABLE" USING L-DIM WS-NX WS-NY WS-NZ L-HEIGHT WS-OK
                                     IF WS-OK = 1
                                         MOVE WS-NY TO WS-CAND
                                     END-IF
                                 END-IF
                             WHEN 0
                                 MOVE 0 TO WS-FOUND
                                 PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3 OR WS-FOUND = 1
                                     COMPUTE WS-NY = WN-Y(WS-CUR) - WS-D
                                     CALL "STDMOB-STANDABLE" USING L-DIM WS-NX WS-NY WS-NZ L-HEIGHT WS-OK
                                     IF WS-OK = 1
                                         MOVE WS-NY TO WS-CAND
                                         MOVE 1 TO WS-FOUND
                                     ELSE
                                         CALL "STDMOB-CELL" USING L-DIM WS-NX WS-NY WS-NZ WS-TYPE
                                         IF WS-TYPE NOT = 0
                                             MOVE 1 TO WS-FOUND
                                         END-IF
                                     END-IF
                                 END-PERFORM
                         END-EVALUATE
                     END-IF
                     IF WS-CAND > -1000
                         COMPUTE WS-GX = WS-NX - L-SX + 16
                         COMPUTE WS-GZ = WS-NZ - L-SZ + 16
                         COMPUTE WS-GY = WS-CAND - WN-Y(1) + 8
                         IF WS-GX >= 0 AND WS-GX < 32 AND WS-GZ >= 0 AND WS-GZ < 32 AND WS-GY >= 0 AND WS-GY < 24
                             COMPUTE WS-KEY = (WS-GX * 32 + WS-GZ) * 24 + WS-GY + 1
                             COMPUTE WS-DY = WS-CAND - WN-Y(WS-CUR)
                             COMPUTE WS-TENT = WN-G(WS-CUR) + FUNCTION SQRT(1 + WS-DY * WS-DY)
                             IF WS-GRID(WS-KEY) = 0
                                 IF WS-NODE-COUNT < 1024
                                     ADD 1 TO WS-NODE-COUNT
                                     MOVE WS-NODE-COUNT TO WS-GRID(WS-KEY)
                                     MOVE WS-NX TO WN-X(WS-NODE-COUNT)
                                     MOVE WS-CAND TO WN-Y(WS-NODE-COUNT)
                                     MOVE WS-NZ TO WN-Z(WS-NODE-COUNT)
                                     MOVE WS-TENT TO WN-G(WS-NODE-COUNT)
                                     MOVE WS-CUR TO WN-PARENT(WS-NODE-COUNT)
                                     MOVE 0 TO WN-STATE(WS-NODE-COUNT)
                                     COMPUTE WS-DX = WS-NX - L-TX
                                     COMPUTE WS-DY = WS-CAND - L-TY
                                     COMPUTE WS-DZ = WS-NZ - L-TZ
                                     COMPUTE WN-H(WS-NODE-COUNT) = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                                     COMPUTE WN-F(WS-NODE-COUNT) = WS-TENT + 1.5 * WN-H(WS-NODE-COUNT)
                                     IF WN-H(WS-NODE-COUNT) < WS-LEAST
                                         MOVE WN-H(WS-NODE-COUNT) TO WS-LEAST
                                         MOVE WS-NODE-COUNT TO WS-BEST
                                     END-IF
                                 END-IF
                             ELSE
                                 MOVE WS-GRID(WS-KEY) TO WS-I
                                 IF WN-STATE(WS-I) = 0 AND WS-TENT < WN-G(WS-I)
                                     MOVE WS-TENT TO WN-G(WS-I)
                                     MOVE WS-CUR TO WN-PARENT(WS-I)
                                     COMPUTE WN-F(WS-I) = WS-TENT + 1.5 * WN-H(WS-I)
                                 END-IF
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
     END-PERFORM
*>   The path: the chain of parents from the best node to the start, reversed.
     MOVE 0 TO WS-LEN
     MOVE WS-BEST TO WS-CUR
     PERFORM UNTIL WS-CUR = 0
         ADD 1 TO WS-LEN
         MOVE WS-CUR TO WS-LINK(WS-LEN)
         MOVE WN-PARENT(WS-CUR) TO WS-CUR
     END-PERFORM
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM WS-LEN BY -1 UNTIL WS-I < 1 OR L-COUNT >= 128
         ADD 1 TO L-COUNT
         MOVE WN-X(WS-LINK(WS-I)) TO L-PX(L-COUNT)
         MOVE WN-Y(WS-LINK(WS-I)) TO L-PY(L-COUNT)
         MOVE WN-Z(WS-LINK(WS-I)) TO L-PZ(L-COUNT)
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-PATH-REF.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
