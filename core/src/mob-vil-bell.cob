*> The entity side of a ringing bell (docs/protocol/44 part 3 section 2.11a; lane 002-lane-p49p). When a bell is rung, every living entity whose position is within 32 blocks of the bell's
*> centre (inside the box of 48) gets the memory heard_bell_time = the game tick. Only villagers have a brain here (gap: other brain mobs do not hear it). The bell block entity's own
*> timing (shaking, resonance, the 60 tick list refresh) is the decision units Q3-BELL-RING, Q3-BELL-TICK and Q3-BELL-REFRESH of core/src/q44-44-3d.cob; the block itself is not hooked to a
*> player's use here.
*>   VL-BELL-RING USING dim, x, y, z (BINARY-LONG block of the bell)    every villager within 32 blocks hears it

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BELL-RING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VLMEM.
 COPY VILSTATE.
 01 WS-N                    BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-NOW                  BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z.
     MOVE CW-TICKS TO WS-NOW
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-DIM(WS-N) = L-DIM AND EN-HEALTH(WS-N) > 0
             COMPUTE WS-D2 = (EN-X(WS-N) - L-X - 0.5) ** 2 + (EN-Y(WS-N) - L-Y - 0.5) ** 2 + (EN-Z(WS-N) - L-Z - 0.5) ** 2
             IF WS-D2 < 1024
                 CALL "VL-FIND" USING EN-ID(WS-N) WS-NO WS-SLOT
                 IF WS-SLOT > 0 AND VL-KIND(WS-SLOT) = 1
                     CALL "VM-NOTE" USING WS-SLOT MT-HEARD-BELL-TIME WS-NOW
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VL-BELL-RING.
