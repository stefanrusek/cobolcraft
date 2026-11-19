*> Villager brain sensors run on their own intervals (docs/protocol/44 part 3 sections 2.18 and 4; lane 002-lane-p49p). Every sensor has a countdown in VM-T that starts at a draw of nextInt(interval)
*> and is decremented every tick (Q3-SENSOR-INIT, Q3-SENSOR-TICK): it scans when the countdown reaches 0 and starts again from its interval. Built here: golem_detected (200 ticks: an iron golem
*> within 16 blocks sets the memory golem_detected_recently for 599 ticks and the golem-summoning rule's VL-GOLEM-UNTIL, Q3-GOLEM-SENSOR). The others run elsewhere: villager_hostiles on the 20 tick
*> beat of VL-FEAR-STEP (with the roster of hostiles found once per tick), hurt_by written by VL-HURT-BY (40 ticks), secondary_pois by VL-FARM-SENSE. Not built: visible_villager_babies and nearest_bed
*> (only the baby play behaviours read them, which are not built). Gap, named: the visibility predicate of 44 section 4 (no line of sight rule is documented), so "nearest living entities" is the
*> entities within 16 blocks, the follow range, with no occlusion test.
*>   VL-SENSE USING row, slot

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-SENSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 01 WS-INTERVAL             BINARY-LONG VALUE 200.
 01 WS-DRAW                 BINARY-LONG.
 01 WS-SALT                 BINARY-LONG VALUE 181.
 01 WS-SCAN                 BINARY-LONG.
 01 WS-KEY                  PIC X(112) VALUE "minecraft:iron_golem".
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-N                    BINARY-LONG.
 01 WS-LISTED               BINARY-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-SET                  BINARY-LONG.
 01 WS-EXPIRY               BINARY-LONG.
 01 WS-ONE                  BINARY-LONG VALUE 1.
 01 WS-ZERO                 BINARY-LONG VALUE 0.
 01 WS-UNTIL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF VM-T(L-SLOT, TM-SENS-INIT) = 0
         CALL "XP-RANDOM" USING WS-SALT WS-INTERVAL WS-DRAW
         CALL "Q3-SENSOR-INIT" USING WS-INTERVAL WS-DRAW VM-T(L-SLOT, TM-SENS-GOLEM)
         MOVE 1 TO VM-T(L-SLOT, TM-SENS-INIT)
     END-IF
     CALL "Q3-SENSOR-TICK" USING VM-T(L-SLOT, TM-SENS-GOLEM) WS-INTERVAL WS-SCAN
     IF WS-SCAN = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-LISTED
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT OR WS-LISTED = 1
         IF EN-USED(WS-N) = 1 AND EN-TYPE(WS-N) = WS-TYPE AND EN-HEALTH(WS-N) > 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW)
             COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
             IF WS-D2 <= 256
                 MOVE 1 TO WS-LISTED
             END-IF
         END-IF
     END-PERFORM
     CALL "Q3-GOLEM-SENSOR" USING WS-LISTED WS-SET WS-EXPIRY
     IF WS-SET = 1
         CALL "VM-NOTE-TTL" USING L-SLOT MT-GOLEM-DETECTED WS-ONE WS-ZERO WS-EXPIRY
         COMPUTE VL-GOLEM-UNTIL(L-SLOT) = CW-TICKS + WS-EXPIRY
     END-IF
     GOBACK.
 END PROGRAM VL-SENSE.
