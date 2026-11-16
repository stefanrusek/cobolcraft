*> Gossip exchange between villagers (docs/protocol/19 section 22.5; lane 002-lane-mobsb4, T8801). The state is VILGOSSIP.cpy and VL-LAST-GOSSIP of VILSTATE.cpy. Gaps: the walk to the
*> other villager (InteractWith interaction_target, within 2 blocks here at once), golems and villagers as targets (only players are stored), a trading player's price refresh.
*>
*>   VL-GOSSIP-EXCHANGE USING receiver row, sender row, copied out    gossip(level, other, time): -1 when either villager talked within 1200 ticks, else the entries copied
*>   VL-GOSSIP-STEP USING entity row                                  an idle or meeting adult within 2 blocks of another adult villager exchanges on the 20 tick beat

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-GOSSIP-EXCHANGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VILGOSSIP.
 01 WS-RS                   BINARY-LONG.
 01 WS-SS                   BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-YES                  BINARY-LONG VALUE 1.
 01 WS-WEIGHTS.
    05 FILLER               BINARY-LONG VALUE 5.
    05 FILLER               BINARY-LONG VALUE 1.
    05 FILLER               BINARY-LONG VALUE 1.
    05 FILLER               BINARY-LONG VALUE 5.
    05 FILLER               BINARY-LONG VALUE 1.
 01 WS-WV REDEFINES WS-WEIGHTS.
    05 WS-W                 BINARY-LONG OCCURS 5 TIMES.
 01 WS-DECAYS.
    05 FILLER               BINARY-LONG VALUE 10.
    05 FILLER               BINARY-LONG VALUE 20.
    05 FILLER               BINARY-LONG VALUE 5.
    05 FILLER               BINARY-LONG VALUE 20.
    05 FILLER               BINARY-LONG VALUE 20.
 01 WS-DV REDEFINES WS-DECAYS.
    05 WS-D                 BINARY-LONG OCCURS 5 TIMES.
 01 WS-LIST.
    05 WS-L                 OCCURS 2560 TIMES.
       10 WS-L-ENT          BINARY-LONG.
       10 WS-L-TYPE         BINARY-LONG.
       10 WS-L-CUM          BINARY-LONG.
       10 WS-L-PICK         BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-TOTAL                BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-T                    BINARY-LONG.
 01 WS-K                    BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-R                    BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 821.
 01 WS-ENT                  BINARY-LONG.
 01 WS-TYP                  BINARY-LONG.
 01 WS-VALUE                BINARY-LONG.
 01 WS-TARGET               BINARY-LONG.
 01 WS-RSLOT                BINARY-LONG.
 01 WS-EXISTING             BINARY-LONG.
 01 WS-MIN                  BINARY-LONG VALUE 5.
 01 WS-SPAWNED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-RECV                  BINARY-LONG.
 01 L-SEND                  BINARY-LONG.
 01 L-COPIED                BINARY-LONG.
 PROCEDURE DIVISION USING L-RECV L-SEND L-COPIED.
     MOVE -1 TO L-COPIED
     CALL "VL-FIND" USING EN-ID(L-RECV) WS-NO WS-RS
     CALL "VL-FIND" USING EN-ID(L-SEND) WS-NO WS-SS
     IF WS-RS = 0 OR WS-SS = 0
         GOBACK
     END-IF
     IF (CW-TICKS >= VL-LAST-GOSSIP(WS-RS) AND CW-TICKS < VL-LAST-GOSSIP(WS-RS) + 1200)
             OR (CW-TICKS >= VL-LAST-GOSSIP(WS-SS) AND CW-TICKS < VL-LAST-GOSSIP(WS-SS) + 1200)
         GOBACK
     END-IF
     MOVE 0 TO L-COPIED
*>   The sender's entries with their absolute weighted values as cumulative sums.
     MOVE 0 TO WS-N
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GS-MAX
         IF GS-VIL(WS-I) = EN-ID(L-SEND)
             PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 5
                 IF GS-V(WS-I, WS-T) > 0
                     ADD 1 TO WS-N
                     MOVE WS-I TO WS-L-ENT(WS-N)
                     MOVE WS-T TO WS-L-TYPE(WS-N)
                     MOVE 0 TO WS-L-PICK(WS-N)
                     COMPUTE WS-TOTAL = WS-TOTAL + GS-V(WS-I, WS-T) * WS-W(WS-T)
                     MOVE WS-TOTAL TO WS-L-CUM(WS-N)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
*>   Up to 10 draws with replacement into a set.
     IF WS-TOTAL > 0
         PERFORM VARYING WS-DRAW FROM 1 BY 1 UNTIL WS-DRAW > 10
             CALL "XP-RANDOM" USING WS-SALT WS-TOTAL WS-R
             MOVE 0 TO WS-K
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N OR WS-K > 0
                 IF WS-L-CUM(WS-I) > WS-R
                     MOVE WS-I TO WS-K
                 END-IF
             END-PERFORM
             MOVE 1 TO WS-L-PICK(WS-K)
         END-PERFORM
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         IF WS-L-PICK(WS-I) = 1
             MOVE WS-L-ENT(WS-I) TO WS-ENT
             MOVE WS-L-TYPE(WS-I) TO WS-TYP
             COMPUTE WS-VALUE = GS-V(WS-ENT, WS-TYP) - WS-D(WS-TYP)
             IF WS-VALUE >= 2
                 MOVE GS-TARGET(WS-ENT) TO WS-TARGET
                 CALL "VG-FIND" USING EN-ID(L-RECV) WS-TARGET WS-YES WS-RSLOT
                 IF WS-RSLOT > 0
                     MOVE GS-V(WS-RSLOT, WS-TYP) TO WS-EXISTING
                     MOVE FUNCTION MAX(WS-EXISTING, WS-VALUE) TO GS-V(WS-RSLOT, WS-TYP)
                     ADD 1 TO L-COPIED
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE CW-TICKS TO VL-LAST-GOSSIP(WS-RS) VL-LAST-GOSSIP(WS-SS)
     CALL "VL-GOLEM-CHECK" USING L-RECV WS-MIN WS-SPAWNED
     GOBACK.
 END PROGRAM VL-GOSSIP-EXCHANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-GOSSIP-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-DAY                  BINARY-LONG.
 01 WS-ACT                  BINARY-LONG.
 01 WS-BABY                 BINARY-LONG VALUE 0.
 01 WS-E                    BINARY-LONG.
 01 WS-KEY                  PIC X(24).
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-COPIED               BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0 OR EN-MOBAGE(L-ROW) < 0 OR FUNCTION MOD(CW-TICKS + EN-ID(L-ROW), 20) NOT = 0
         GOBACK
     END-IF
     COMPUTE WS-DAY = FUNCTION MOD(CW-TIME, 24000)
     CALL "VIL-DAY-ACT" USING WS-DAY WS-BABY WS-ACT
     IF WS-ACT NOT = 0 AND WS-ACT NOT = 2
         GOBACK
     END-IF
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-DONE = 1
         IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0 AND EN-MOBAGE(WS-E) >= 0
             CALL "MOB-SPECIES-KEY" USING WS-E WS-KEY
             IF WS-KEY = "villager"
                 COMPUTE WS-DX = EN-X(WS-E) - EN-X(L-ROW)
                 COMPUTE WS-DY = EN-Y(WS-E) - EN-Y(L-ROW)
                 COMPUTE WS-DZ = EN-Z(WS-E) - EN-Z(L-ROW)
                 COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                 IF WS-D2 <= 4
                     MOVE 1 TO WS-DONE
                     CALL "VL-GOSSIP-EXCHANGE" USING L-ROW WS-E WS-COPIED
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VL-GOSSIP-STEP.
