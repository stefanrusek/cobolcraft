*> Piglin bartering (docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md section 5.5.1; lane 002-lane-mobsb). Programs of plain numbers over BARTER.cpy.
*>
*>   PIGLIN-BARTER USING draw (0 to 468), item key out (X(24)), count low out, count high out, modifier out   the row of the barter table a draw falls in
*>   PIGLIN-CURRENCY USING item key (X(24)), yes out                                                       the barter currency is gold_ingot
*>   PIGLIN-LOVED USING item key (X(24)), yes out                                                          piglin_loved
*>   PIGLIN-SAFE-ARMOR USING item key (X(24)), yes out                                                     piglin_safe_armor: the four golden armor pieces
*>   PIGLIN-ADMIRE USING adult, admiring, admiring disabled, yes out                                         mobInteract accepts an ingot only from an adult not admiring and not disabled

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-BARTER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BARTER.
 01 WS-BT REDEFINES BARTER-DATA.
    05 WS-ROW OCCURS 19 TIMES.
       10 WS-KEY               PIC X(24).
       10 WS-WEIGHT            BINARY-LONG.
       10 WS-LO                BINARY-LONG.
       10 WS-HI                BINARY-LONG.
       10 WS-MOD               BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-SUM                  BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DRAW                  BINARY-LONG.
 01 L-KEY                   PIC X(24).
 01 L-LO                    BINARY-LONG.
 01 L-HI                    BINARY-LONG.
 01 L-MOD                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DRAW L-KEY L-LO L-HI L-MOD.
     MOVE 0 TO WS-SUM WS-DONE
     MOVE SPACES TO L-KEY
     MOVE 0 TO L-LO L-HI L-MOD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > BT-COUNT
         ADD WS-WEIGHT(WS-I) TO WS-SUM
         IF WS-DONE = 0 AND L-DRAW < WS-SUM
             MOVE 1 TO WS-DONE
             MOVE WS-KEY(WS-I) TO L-KEY
             MOVE WS-LO(WS-I) TO L-LO
             MOVE WS-HI(WS-I) TO L-HI
             MOVE WS-MOD(WS-I) TO L-MOD
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PIGLIN-BARTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-CURRENCY.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(24).
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-YES.
     MOVE 0 TO L-YES
     IF L-KEY = "gold_ingot"
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-CURRENCY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-LOVED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY LOVED.
 01 WS-LV REDEFINES LOVED-DATA.
    05 WS-L                 PIC X(32) OCCURS 28 TIMES.
 01 WS-I                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(32).
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-YES.
     MOVE 0 TO L-YES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LV-COUNT
         IF WS-L(WS-I) = L-KEY
             MOVE 1 TO L-YES
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PIGLIN-LOVED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-SAFE-ARMOR.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                   PIC X(24).
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-YES.
     MOVE 0 TO L-YES
     IF L-KEY = "golden_helmet" OR "golden_chestplate" OR "golden_leggings" OR "golden_boots"
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-SAFE-ARMOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-ADMIRE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ADULT                 BINARY-LONG.
 01 L-ADMIRING              BINARY-LONG.
 01 L-DISABLED              BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ADULT L-ADMIRING L-DISABLED L-YES.
     MOVE 0 TO L-YES
     IF L-ADULT = 1 AND L-ADMIRING = 0 AND L-DISABLED = 0
         MOVE 1 TO L-YES
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-ADMIRE.
