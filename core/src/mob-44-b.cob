*> Panda eating (002-lane-mobsa2; docs/protocol/44-residual-mob-questions-4-land-animals.md section 7; 19 section 8).
*> - A sitting panda (flags bit 8) that is not eating and holds an item in the mouth (EN-PANDA-HAND) starts eating when the draw nextInt(80) is 1: the eating counter (EN-PANDA-EAT, metadata 20) is 1.
*> - Each tick the counter goes up; past 80 the draw nextInt(20) = 1 finishes it when the counter is above 100: the item is consumed (the held items are bamboo, in panda_eats_from_ground),
*>   the counter is 0 and the panda stops sitting.
*> Open items: rolling, lying on the back and the sit goals (their durations are not in the docs: 44 part 4 section 7 gives the start rolls only), the scared state in thunder, picking items up.
*>
*> Entry points:
*>   M44-PANDA-EAT-START USING row, draw (nextInt(80)), started out
*>   M44-PANDA-EAT-TICK USING row, draw (nextInt(20)), finished out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-PANDA-EAT-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-Q                   BINARY-LONG.
 01 WS-SIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-STARTED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DRAW L-STARTED.
     MOVE 0 TO L-STARTED
     COMPUTE WS-Q = EN-PANDA-FLAGS(L-ROW) / 8
     MOVE FUNCTION MOD(WS-Q, 2) TO WS-SIT
     IF WS-SIT = 1 AND EN-PANDA-EAT(L-ROW) = 0 AND EN-PANDA-HAND(L-ROW) > 0 AND L-DRAW = 1
         MOVE 1 TO L-STARTED
         MOVE 1 TO EN-PANDA-EAT(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM M44-PANDA-EAT-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-PANDA-EAT-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-Q                   BINARY-LONG.
 01 WS-SIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-DONE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DRAW L-DONE.
     MOVE 0 TO L-DONE
     IF EN-PANDA-EAT(L-ROW) > 0
         ADD 1 TO EN-PANDA-EAT(L-ROW)
         IF EN-PANDA-EAT(L-ROW) > 100 AND L-DRAW = 1
             MOVE 1 TO L-DONE
             MOVE 0 TO EN-PANDA-EAT(L-ROW) EN-PANDA-HAND(L-ROW)
             COMPUTE WS-Q = EN-PANDA-FLAGS(L-ROW) / 8
             MOVE FUNCTION MOD(WS-Q, 2) TO WS-SIT
             IF WS-SIT = 1
                 SUBTRACT 8 FROM EN-PANDA-FLAGS(L-ROW)
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM M44-PANDA-EAT-TICK.
