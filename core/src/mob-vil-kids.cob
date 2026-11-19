*> Baby villagers (docs/protocol/44 part 3 sections 2.9, 2.15, 4.4, 4.5 and 19 section 22.3; lane 002-lane-p49q, T37006 and T37007). VL-KIDS-TICK runs every tick for a baby (an adult returns at once):
*>   sensors (the scan interval is 20 ticks, countdowns as in 2.18): visible_villager_babies (MT-VISIBLE-BABIES, NUM the count: the baby villagers within 16 blocks, no occlusion test; the document
*>     writes it for every villager, only babies read it so it is kept for babies only) and nearest_bed (MT-NEAREST-BED: the nearest home bed of the index within 48 blocks that a path reaches; the
*>     document's one path to the batch of up to 4 new positions with the 40 tick cache is one path to the nearest bed here);
*>   PlayTagWithOtherKids (play activity; requires visible_villager_babies and walk_target absent): 1 in 10 per tick; a baby chased by a friend flees (10 attempts at a land position within 20 x 8 of
*>     it that a villager can stand on and that is a village position, VL-IS-VILLAGE: walk_target at 0.6 = 1.2 s, closeness 0); else the baby that is chased by 1 to 5 others with the fewest chasers
*>     (the first in the table's order on equal counts), else the first listed baby, is chased: interaction_target = it, walk_target at its block (the document's entity tracker is the block of this
*>     tick), 1.2 s, closeness 1. Gaps: the position sampler of LandRandomPos is a uniform draw in the box, the list order is the entity table's, not the distance order;
*>   JumpOnBed (play activity with no visible baby, or idle; requires nearest_bed and walk_target absent): the RunOne of the activity is approximated by its weight (play 2 in 9, idle 1 in 8 per tick). On
*>     start: walking budget 100, 3 + nextInt(4) jumps, cooldown 0, walk_target at the bed (1.0 s, closeness 0). Each tick: not on or over a bed: budget - 1; cooldown above 0: cooldown - 1; else on the bed
*>     surface: jump (vertical speed max(0.42, current)), jumps - 1, cooldown 5. It ends when the bed is gone, or when the baby is not on or over a bed with the budget used up, or is on or over one with
*>     no jumps left. "On or over a bed": the block of its feet or the one below is a bed; the bed surface is the same here (the movement step puts a mob on top of a bed block, not in it).
*>   VL-IS-VILLAGE USING dim, x, y, z (BINARY-LONG block), village out: 1.3 and 1.4 of the document, isVillage = a village centre section within 1 section (Chebyshev) of the block's section, a centre
*>     being a section with a claimed job site, home bed or meeting point (the claim tables of VILPOI.cpy).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-IS-VILLAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOI.
 01 WS-I                    BINARY-LONG.
 01 WS-SX                   BINARY-LONG.
 01 WS-SY                   BINARY-LONG.
 01 WS-SZ                   BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-VILLAGE               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-VILLAGE.
     MOVE 0 TO L-VILLAGE
     COMPUTE WS-SX = FUNCTION INTEGER(L-X / 16)
     COMPUTE WS-SY = FUNCTION INTEGER(L-Y / 16)
     COMPUTE WS-SZ = FUNCTION INTEGER(L-Z / 16)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PO-MAX OR L-VILLAGE = 1
         IF PO-OWNER(WS-I) > 0 AND PO-DIM(WS-I) = L-DIM
             COMPUTE WS-PX = FUNCTION INTEGER(PO-X(WS-I) / 16)
             COMPUTE WS-PY = FUNCTION INTEGER(PO-Y(WS-I) / 16)
             COMPUTE WS-PZ = FUNCTION INTEGER(PO-Z(WS-I) / 16)
             IF FUNCTION ABS(WS-PX - WS-SX) <= 1 AND FUNCTION ABS(WS-PY - WS-SY) <= 1 AND FUNCTION ABS(WS-PZ - WS-SZ) <= 1
                 MOVE 1 TO L-VILLAGE
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VL-IS-VILLAGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PXI-NEAREST-ANY.
*> USING dim, x, y, z, kind, range, ox, oy, oz out, found out: PXI-NEAREST without the ticket test (the nearest_bed sensor takes the home POIs of any occupancy, 44 section 4.5).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILPOIX.
 01 WS-I                    BINARY-LONG.
 01 WS-KIND                 BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-BEST                 FLOAT-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-DIM                   BINARY-LONG.
 01 L-X                     BINARY-LONG.
 01 L-Y                     BINARY-LONG.
 01 L-Z                     BINARY-LONG.
 01 L-KIND                  BINARY-LONG.
 01 L-RANGE                 BINARY-LONG.
 01 L-OX                    BINARY-LONG.
 01 L-OY                    BINARY-LONG.
 01 L-OZ                    BINARY-LONG.
 01 L-FOUND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-KIND L-RANGE L-OX L-OY L-OZ L-FOUND.
     MOVE 0 TO L-FOUND
     COMPUTE WS-BEST = L-RANGE * L-RANGE + 1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PX-MAX
         IF PX-KIND(WS-I) = L-KIND AND PX-DIM(WS-I) = L-DIM
             COMPUTE WS-DX = PX-X(WS-I) - L-X
             COMPUTE WS-DY = PX-Y(WS-I) - L-Y
             COMPUTE WS-DZ = PX-Z(WS-I) - L-Z
             COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
             IF WS-D2 < WS-BEST
                 CALL "PXI-KIND-OF" USING L-DIM PX-X(WS-I) PX-Y(WS-I) PX-Z(WS-I) WS-KIND
                 IF WS-KIND = L-KIND
                     MOVE WS-D2 TO WS-BEST
                     MOVE PX-X(WS-I) TO L-OX
                     MOVE PX-Y(WS-I) TO L-OY
                     MOVE PX-Z(WS-I) TO L-OZ
                     MOVE 1 TO L-FOUND
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PXI-NEAREST-ANY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-KIDS-SENSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-INTERVAL             BINARY-LONG VALUE 20.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-SALT-A               BINARY-LONG VALUE 183.
 01 WS-SALT-B               BINARY-LONG VALUE 184.
 01 WS-SCAN                 BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-OSLOT                BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-COUNT                BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-RANGE                BINARY-LONG VALUE 48.
 01 WS-KIND-BED             BINARY-LONG VALUE 1.
 01 WS-REACH                BINARY-LONG VALUE 1.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-OK                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF VM-T(L-SLOT, TM-SENS-INIT) < 2
         CALL "XP-RANDOM" USING WS-SALT-A WS-INTERVAL WS-DRAW
         CALL "Q3-SENSOR-INIT" USING WS-INTERVAL WS-DRAW VM-T(L-SLOT, TM-SENS-BABIES)
         CALL "XP-RANDOM" USING WS-SALT-B WS-INTERVAL WS-DRAW
         CALL "Q3-SENSOR-INIT" USING WS-INTERVAL WS-DRAW VM-T(L-SLOT, TM-SENS-BED)
         MOVE 2 TO VM-T(L-SLOT, TM-SENS-INIT)
     END-IF
     CALL "Q3-SENSOR-TICK" USING VM-T(L-SLOT, TM-SENS-BABIES) WS-INTERVAL WS-SCAN
     IF WS-SCAN = 1
         MOVE 0 TO WS-COUNT
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
             IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0
                     AND EN-DIM(WS-N) = EN-DIM(L-ROW) AND EN-MOBAGE(WS-N) < 0
                 COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
                 IF WS-D2 <= 256
                     CALL "VL-FIND" USING EN-ID(WS-N) WS-NO WS-OSLOT
                     IF WS-OSLOT > 0
                         IF VL-KIND(WS-OSLOT) = 1
                             ADD 1 TO WS-COUNT
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-COUNT > 0
             CALL "VM-NOTE" USING L-SLOT MT-VISIBLE-BABIES WS-COUNT
         ELSE
             CALL "VM-ERASE" USING L-SLOT MT-VISIBLE-BABIES
         END-IF
     END-IF
     CALL "Q3-SENSOR-TICK" USING VM-T(L-SLOT, TM-SENS-BED) WS-INTERVAL WS-SCAN
     IF WS-SCAN = 1
         COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
         CALL "PXI-NEAREST-ANY" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-KIND-BED WS-RANGE WS-QX WS-QY WS-QZ WS-FOUND
         IF WS-FOUND = 1
             CALL "VL-CAN-REACH" USING L-ROW WS-QX WS-QY WS-QZ WS-REACH WS-OK
             IF WS-OK = 1
                 CALL "VM-AT" USING L-SLOT MT-NEAREST-BED EN-DIM(L-ROW) WS-QX WS-QY WS-QZ
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-KIDS-SENSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-KIDS-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 COPY CBLOCKS.
 01 WS-HAS                  BINARY-LONG.
 01 WS-PRESENT              BINARY-LONG.
 01 WS-QD                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-N1                   BINARY-LONG.
 01 WS-N2                   BINARY-LONG.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-SALT-TAG             BINARY-LONG VALUE 185.
 01 WS-SALT-FLEE            BINARY-LONG VALUE 186.
 01 WS-SALT-JUMP            BINARY-LONG VALUE 187.
 01 WS-TEN                  BINARY-LONG VALUE 10.
 01 WS-NINE                 BINARY-LONG VALUE 9.
 01 WS-EIGHT                BINARY-LONG VALUE 8.
 01 WS-FOUR                 BINARY-LONG VALUE 4.
 01 WS-SPAN                 BINARY-LONG VALUE 41.
 01 WS-N                    BINARY-LONG.
 01 WS-I                    BINARY-LONG.
 01 WS-J                    BINARY-LONG.
 01 WS-OSLOT                BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-D2                   FLOAT-LONG.
 01 WS-KIDS.
    05 WS-KID OCCURS 32 TIMES.
       10 WS-KID-ROW        BINARY-LONG.
       10 WS-KID-ID         BINARY-LONG.
       10 WS-KID-TGT        BINARY-LONG.
       10 WS-KID-CNT        BINARY-LONG.
 01 WS-KID-N                BINARY-LONG.
 01 WS-FRIEND               BINARY-LONG.
 01 WS-PICK                 BINARY-LONG.
 01 WS-BEST                 BINARY-LONG.
 01 WS-ATTEMPT              BINARY-LONG.
 01 WS-TX                   BINARY-LONG.
 01 WS-TY                   BINARY-LONG.
 01 WS-TZ                   BINARY-LONG.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-OK                   BINARY-LONG.
 01 WS-HEIGHT               BINARY-LONG VALUE 1.
 01 WS-VILLAGE              BINARY-LONG.
 01 WS-DONE                 BINARY-LONG.
 01 WS-SPEED                FLOAT-LONG VALUE 1.2.
 01 WS-SPEED-S              FLOAT-LONG VALUE 1.0.
 01 WS-CLOSE-0              BINARY-LONG VALUE 0.
 01 WS-CLOSE-1              BINARY-LONG VALUE 1.
 01 WS-BED                  BINARY-LONG.
 01 WS-STATE                BINARY-LONG.
 01 WS-FY                   BINARY-LONG.
 01 WS-OVER                 BINARY-LONG.
 01 WS-BED-OK               BINARY-LONG.
 01 WS-STOP                 BINARY-LONG.
 01 WS-NUM                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 01 L-BABY                  BINARY-LONG.
 01 L-ACT                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-BABY L-ACT.
     IF L-BABY = 0
         GOBACK
     END-IF
     CALL "VL-KIDS-SENSE" USING L-ROW L-SLOT
     COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
*>   JumpOnBed in progress.
     IF VM-T(L-SLOT, TM-JUMP-ON) = 1
         CALL "VM-GET" USING L-SLOT MT-NEAREST-BED WS-BED WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
         MOVE 0 TO WS-BED-OK
         IF WS-BED = 1
             CALL "WORLD-GET-BLOCK" USING WS-QD WS-QX WS-QY WS-QZ WS-STATE
             CALL "WORLDSIM-BED-KEY" USING WS-STATE WS-BED-OK
         END-IF
         MOVE 0 TO WS-OVER
         CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-STATE
         CALL "WORLDSIM-BED-KEY" USING WS-STATE WS-OVER
         IF WS-OVER = 0
             COMPUTE WS-FY = WS-PY - 1
             CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-PX WS-FY WS-PZ WS-STATE
             CALL "WORLDSIM-BED-KEY" USING WS-STATE WS-OVER
         END-IF
         MOVE 0 TO WS-STOP
         IF WS-BED-OK = 0
             MOVE 1 TO WS-STOP
         END-IF
         IF WS-OVER = 0 AND VM-T(L-SLOT, TM-JUMP-BUDGET) <= 0
             MOVE 1 TO WS-STOP
         END-IF
         IF WS-OVER = 1 AND VM-T(L-SLOT, TM-JUMP-LEFT) <= 0
             MOVE 1 TO WS-STOP
         END-IF
         EVALUATE TRUE
             WHEN WS-STOP = 1
                 MOVE 0 TO VM-T(L-SLOT, TM-JUMP-ON) VM-T(L-SLOT, TM-JUMP-BUDGET) VM-T(L-SLOT, TM-JUMP-LEFT) VM-T(L-SLOT, TM-JUMP-COOL)
             WHEN WS-OVER = 0
                 SUBTRACT 1 FROM VM-T(L-SLOT, TM-JUMP-BUDGET)
             WHEN VM-T(L-SLOT, TM-JUMP-COOL) > 0
                 SUBTRACT 1 FROM VM-T(L-SLOT, TM-JUMP-COOL)
             WHEN OTHER
                 IF EN-VY(L-ROW) < 0.42
                     MOVE 0.42 TO EN-VY(L-ROW)
                 END-IF
                 SUBTRACT 1 FROM VM-T(L-SLOT, TM-JUMP-LEFT)
                 MOVE 5 TO VM-T(L-SLOT, TM-JUMP-COOL)
         END-EVALUATE
         GOBACK
     END-IF
     IF L-ACT NOT = VA-PLAY AND L-ACT NOT = VA-IDLE
         GOBACK
     END-IF
     CALL "VM-HAS" USING L-SLOT MT-WALK-TARGET WS-HAS
     IF WS-HAS = 1
         GOBACK
     END-IF
     CALL "VM-HAS" USING L-SLOT MT-VISIBLE-BABIES WS-HAS
*>   PlayTagWithOtherKids (play activity, with visible babies).
     IF L-ACT = VA-PLAY AND WS-HAS = 1
         CALL "XP-RANDOM" USING WS-SALT-TAG WS-TEN WS-DRAW
         IF WS-DRAW NOT = 0
             GOBACK
         END-IF
         MOVE 0 TO WS-KID-N
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT OR WS-KID-N >= 32
             IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-HEALTH(WS-N) > 0
                     AND EN-DIM(WS-N) = EN-DIM(L-ROW) AND EN-MOBAGE(WS-N) < 0
                 COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
                 CALL "VL-FIND" USING EN-ID(WS-N) WS-NO WS-OSLOT
                 IF WS-D2 <= 256 AND WS-OSLOT > 0
                     IF VL-KIND(WS-OSLOT) = 1
                         ADD 1 TO WS-KID-N
                         MOVE WS-N TO WS-KID-ROW(WS-KID-N)
                         MOVE EN-ID(WS-N) TO WS-KID-ID(WS-KID-N)
                         MOVE 0 TO WS-KID-CNT(WS-KID-N)
                         CALL "VM-GET" USING WS-OSLOT MT-INTERACTION-TARGET WS-PRESENT WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
                         MOVE 0 TO WS-KID-TGT(WS-KID-N)
                         IF WS-PRESENT = 1
                             MOVE WS-N1 TO WS-KID-TGT(WS-KID-N)
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-KID-N = 0
             GOBACK
         END-IF
         MOVE 0 TO WS-FRIEND
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KID-N
             IF WS-KID-TGT(WS-I) = EN-ID(L-ROW)
                 MOVE 1 TO WS-FRIEND
             END-IF
         END-PERFORM
         IF WS-FRIEND = 1
*>           Flee: up to 10 attempts at a position within 20 x 8 that is a village position.
             MOVE 0 TO WS-DONE
             PERFORM VARYING WS-ATTEMPT FROM 1 BY 1 UNTIL WS-ATTEMPT > 10 OR WS-DONE = 1
                 CALL "XP-RANDOM" USING WS-SALT-FLEE WS-SPAN WS-TX
                 CALL "XP-RANDOM" USING WS-SALT-FLEE WS-SPAN WS-TZ
                 COMPUTE WS-TX = WS-PX + WS-TX - 20
                 COMPUTE WS-TZ = WS-PZ + WS-TZ - 20
                 MOVE WS-PY TO WS-TY
                 CALL "STDMOB-STANDABLE" USING EN-DIM(L-ROW) WS-TX WS-TY WS-TZ WS-HEIGHT WS-OK
                 IF WS-OK = 1
                     CALL "VL-IS-VILLAGE" USING EN-DIM(L-ROW) WS-TX WS-TY WS-TZ WS-VILLAGE
                     IF WS-VILLAGE = 1
                         CALL "VL-WALK-SET" USING L-ROW L-SLOT EN-DIM(L-ROW) WS-TX WS-TY WS-TZ WS-SPEED WS-CLOSE-0
                         MOVE 1 TO WS-DONE
                     END-IF
                 END-IF
             END-PERFORM
             GOBACK
         END-IF
*>       Someone being chased: the baby chased by 1 to 5 others, the fewest first; else any baby.
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KID-N
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-KID-N
                 IF WS-J NOT = WS-I AND WS-KID-TGT(WS-J) = WS-KID-ID(WS-I)
                     ADD 1 TO WS-KID-CNT(WS-I)
                 END-IF
             END-PERFORM
         END-PERFORM
         MOVE 1 TO WS-PICK
         MOVE 99 TO WS-BEST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KID-N
             IF WS-KID-CNT(WS-I) >= 1 AND WS-KID-CNT(WS-I) <= 5 AND WS-KID-CNT(WS-I) < WS-BEST
                 MOVE WS-KID-CNT(WS-I) TO WS-BEST
                 MOVE WS-I TO WS-PICK
             END-IF
         END-PERFORM
         MOVE WS-KID-ID(WS-PICK) TO WS-NUM
         CALL "VM-NOTE" USING L-SLOT MT-INTERACTION-TARGET WS-NUM
         MOVE EN-X(WS-KID-ROW(WS-PICK)) TO WS-TX
         MOVE EN-Y(WS-KID-ROW(WS-PICK)) TO WS-TY
         MOVE EN-Z(WS-KID-ROW(WS-PICK)) TO WS-TZ
         CALL "VL-WALK-SET" USING L-ROW L-SLOT EN-DIM(L-ROW) WS-TX WS-TY WS-TZ WS-SPEED WS-CLOSE-1
         GOBACK
     END-IF
*>   JumpOnBed: the activity's RunOne reaches it with its weight; it needs the nearest bed (the play branch above always ends the tick when babies are in sight).
     CALL "VM-GET" USING L-SLOT MT-NEAREST-BED WS-BED WS-QD WS-QX WS-QY WS-QZ WS-N1 WS-N2
     IF WS-BED = 0
         GOBACK
     END-IF
     IF L-ACT = VA-PLAY
         CALL "XP-RANDOM" USING WS-SALT-JUMP WS-NINE WS-DRAW
         IF WS-DRAW >= 2
             GOBACK
         END-IF
     ELSE
         CALL "XP-RANDOM" USING WS-SALT-JUMP WS-EIGHT WS-DRAW
         IF WS-DRAW NOT = 0
             GOBACK
         END-IF
     END-IF
     MOVE 1 TO VM-T(L-SLOT, TM-JUMP-ON)
     MOVE 100 TO VM-T(L-SLOT, TM-JUMP-BUDGET)
     CALL "XP-RANDOM" USING WS-SALT-JUMP WS-FOUR WS-DRAW
     COMPUTE VM-T(L-SLOT, TM-JUMP-LEFT) = 3 + WS-DRAW
     MOVE 0 TO VM-T(L-SLOT, TM-JUMP-COOL)
     CALL "VL-WALK-SET" USING L-ROW L-SLOT WS-QD WS-QX WS-QY WS-QZ WS-SPEED-S WS-CLOSE-0
     GOBACK.
 END PROGRAM VL-KIDS-TICK.
