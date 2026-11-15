*> block_column (docs/protocol/35-worldgen-features-4 section 5; kelp, sugar cane, cactus, vines of the data): the heights of the layers are sampled in layer order, the allowed_placement
*> predicate is tested from the cell after the origin along the direction, the first failing cell truncates the column (from the first layer when prioritize_tip, else from the last) and
*> the blocks are written from the origin itself, one provider state per block (flags 2).
*>
*> Entry point: FR-BLOCK-COLUMN USING state, column row (FEATDATA.cpy FD-BC), x, y, z, result out (1 when a column was written, 0 for a total height of 0).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-BLOCK-COLUMN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-HEIGHTS.
    05 WS-H                BINARY-LONG OCCURS 4 TIMES.
 01 WS-P4.
    05 WS-Q                BINARY-LONG OCCURS 4 TIMES.
 01 WS-L                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-KEPT                BINARY-LONG.
 01 WS-REMAIN              BINARY-LONG.
 01 WS-TAKE                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-PV                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-BC                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BC L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT WS-TOTAL
*>   1. every layer's height, in layer order
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > BC-N(L-BC)
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
             MOVE BC-H(L-BC, WS-L, WS-K) TO WS-Q(WS-K)
         END-PERFORM
         CALL "FR-INT-SAMPLE" USING L-STATE WS-P4 WS-H(WS-L)
         IF WS-H(WS-L) < 0
             MOVE 0 TO WS-H(WS-L)
         END-IF
         ADD WS-H(WS-L) TO WS-TOTAL
     END-PERFORM
     IF WS-TOTAL = 0
         GOBACK
     END-IF
*>   2. the test starts one cell beyond the origin: the first failing cell truncates the column
     MOVE WS-TOTAL TO WS-KEPT
     MOVE 0 TO WS-STOP
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= WS-TOTAL OR WS-STOP = 1
         COMPUTE WS-CY = L-Y + BC-DIR(L-BC) * (WS-I + 1)
         CALL "FR-PRED-TEST" USING BC-PR(L-BC) L-X WS-CY L-Z WS-PASS
         IF WS-PASS = 0
             MOVE WS-I TO WS-KEPT
             MOVE 1 TO WS-STOP
         END-IF
     END-PERFORM
*>   3. truncation removes total - kept blocks: from the first layer with prioritize_tip, else from the last
     COMPUTE WS-REMAIN = WS-TOTAL - WS-KEPT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > BC-N(L-BC)
         IF BC-TIP(L-BC) = 1
             MOVE WS-S TO WS-L
         ELSE
             COMPUTE WS-L = BC-N(L-BC) - WS-S + 1
         END-IF
         MOVE WS-H(WS-L) TO WS-TAKE
         IF WS-TAKE > WS-REMAIN
             MOVE WS-REMAIN TO WS-TAKE
         END-IF
         SUBTRACT WS-TAKE FROM WS-H(WS-L)
         SUBTRACT WS-TAKE FROM WS-REMAIN
     END-PERFORM
*>   4. write from the origin, one provider state per block
     MOVE L-Y TO WS-CY
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > BC-N(L-BC)
         MOVE BC-PV(L-BC, WS-L) TO WS-PV
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-H(WS-L)
             CALL "FR-PROV-STATE" USING L-STATE WS-PV L-X WS-CY L-Z WS-STATE WS-OK
             IF WS-OK = 1
                 CALL "FL-SET-STATE" USING L-X WS-CY L-Z WS-STATE WS-FLAGS WS-OK
             END-IF
             ADD BC-DIR(L-BC) TO WS-CY
         END-PERFORM
     END-PERFORM
     MOVE 1 TO L-RESULT
     GOBACK.
 END PROGRAM FR-BLOCK-COLUMN.
