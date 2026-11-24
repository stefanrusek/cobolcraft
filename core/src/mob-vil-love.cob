*> Villager breeding (docs/protocol/19 section 22.6; lane 002-lane-mobsb4, T8800). The state is VILSTATE.cpy (VL-FOOD, VL-INV, VL-LOVE, VL-LOVE-AT). The rules are VIL-CAN-BREED and
*> VIL-OFFSPRING of mob-19-22.cob. Reduced forms: the inventory is only its food points (VL-INV); the idle behaviour InteractWith(villager, 8, breeding possible) is one roll in 8 every 20
*> ticks of an idle adult (the weights of the idle RunOne), the walk is a straight line by the stroll fields, no path check for the bed (the index range 48 stands in), a baby gets event 12
*> only. Gaps: no food sharing between villagers (the amount and range of the share behaviour are not in the documents; the predicates VL-FOOD-FLAGS exist), nothing gives a villager food
*> yet (no pick-up of dropped food, no farmer harvest), the animals_bred statistic.
*>
*>   VL-EVENT-SEND USING entity row, event               Entity Event to the viewers
*>   VL-FOOD-FLAGS USING inventory points, wants more out, has excess out    22.6 wantsMoreFood (below 12) and hasExcessFood (24 or more)
*>   VL-CAN-BREED-ROW USING row, yes out                 canBreed of a villager row
*>   VL-LOVE-PICK USING row, partner row out             the nearest willing villager within 8 blocks that is not in love mode (0 none)
*>   VL-LOVE-START USING row a, row b                    both in love mode, birth in 275 + nextInt(50) ticks, event 18
*>   VL-LOVE-TICK USING row                              one tick of the make-love behaviour
*>   VL-BREED-STEP USING row                             the per-tick entry (VL-STEP)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-EVENT-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-CAPACITY             BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-EVENT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-EVENT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) L-EVENT PB-BUFFER
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM VL-EVENT-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-FOOD-FLAGS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-INV                   BINARY-LONG.
 01 L-WANTS                 BINARY-LONG.
 01 L-EXCESS                BINARY-LONG.
 PROCEDURE DIVISION USING L-INV L-WANTS L-EXCESS.
     MOVE 0 TO L-WANTS L-EXCESS
     IF L-INV < 12
         MOVE 1 TO L-WANTS
     END-IF
     IF L-INV >= 24
         MOVE 1 TO L-EXCESS
     END-IF
     GOBACK.
 END PROGRAM VL-FOOD-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-CAN-BREED-ROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-KEY                  PIC X(24).
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-YES                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-YES.
     MOVE 0 TO L-YES
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     IF WS-KEY NOT = "villager"
         GOBACK
     END-IF
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         CALL "VIL-CAN-BREED" USING VL-FOOD(WS-SLOT) VL-INV(WS-SLOT) VL-SLEEP(WS-SLOT) EN-MOBAGE(L-ROW) L-YES
     END-IF
     GOBACK.
 END PROGRAM VL-CAN-BREED-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-LOVE-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-E                    BINARY-LONG.
 01 WS-YES                  BINARY-LONG.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-BEST                 FLOAT-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DY                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 01 L-PARTNER               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PARTNER.
     MOVE 0 TO L-PARTNER
     CALL "VL-CAN-BREED-ROW" USING L-ROW WS-YES
     IF WS-YES = 0
         GOBACK
     END-IF
     MOVE 64 TO WS-BEST
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
             CALL "VL-CAN-BREED-ROW" USING WS-E WS-YES
             IF WS-YES = 1
                 CALL "VL-FIND" USING EN-ID(WS-E) WS-NO WS-SLOT
                 IF VL-LOVE(WS-SLOT) = 0
                     COMPUTE WS-DX = EN-X(WS-E) - EN-X(L-ROW)
                     COMPUTE WS-DY = EN-Y(WS-E) - EN-Y(L-ROW)
                     COMPUTE WS-DZ = EN-Z(WS-E) - EN-Z(L-ROW)
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                     IF WS-D2 <= WS-BEST
                         MOVE WS-D2 TO WS-BEST
                         MOVE WS-E TO L-PARTNER
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM VL-LOVE-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-LOVE-START.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-SA                   BINARY-LONG.
 01 WS-SB                   BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-SALT                 BINARY-LONG VALUE 801.
 01 WS-FIFTY                BINARY-LONG VALUE 50.
 01 WS-R                    BINARY-LONG.
 01 WS-EVENT                BINARY-LONG VALUE 18.
 LINKAGE SECTION.
 01 L-A                     BINARY-LONG.
 01 L-B                     BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B.
     CALL "VL-FIND" USING EN-ID(L-A) WS-NO WS-SA
     CALL "VL-FIND" USING EN-ID(L-B) WS-NO WS-SB
     CALL "XP-RANDOM" USING WS-SALT WS-FIFTY WS-R
     MOVE EN-ID(L-B) TO VL-LOVE(WS-SA)
     MOVE EN-ID(L-A) TO VL-LOVE(WS-SB)
     COMPUTE VL-LOVE-AT(WS-SA) = CW-TICKS + 275 + WS-R
     MOVE VL-LOVE-AT(WS-SA) TO VL-LOVE-AT(WS-SB)
     CALL "VL-EVENT-SEND" USING L-A WS-EVENT
     CALL "VL-EVENT-SEND" USING L-B WS-EVENT
     GOBACK.
 END PROGRAM VL-LOVE-START.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-LOVE-EAT.
*> USING slot: eatAndDigestFood: eatUntilFull takes inventory food until the food level is 12, then digestFood(12).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY VILSTATE.
 01 WS-TAKE                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-SLOT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SLOT.
     IF VL-FOOD(L-SLOT) < 12
         COMPUTE WS-TAKE = FUNCTION MIN(12 - VL-FOOD(L-SLOT), VL-INV(L-SLOT))
         ADD WS-TAKE TO VL-FOOD(L-SLOT)
         SUBTRACT WS-TAKE FROM VL-INV(L-SLOT)
     END-IF
     SUBTRACT 12 FROM VL-FOOD(L-SLOT)
     GOBACK.
 END PROGRAM VL-LOVE-EAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-LOVE-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-SA                   BINARY-LONG.
 01 WS-SB                   BINARY-LONG.
 01 WS-BABY-SLOT            BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-P                    BINARY-LONG.
 01 WS-E                    BINARY-LONG.
 01 WS-DX                   FLOAT-LONG.
 01 WS-DZ                   FLOAT-LONG.
 01 WS-D2                   FLOAT-LONG.
 01 WS-SALT-H               BINARY-LONG VALUE 802.
 01 WS-SALT-T               BINARY-LONG VALUE 803.
 01 WS-THIRTY-FIVE          BINARY-LONG VALUE 35.
 01 WS-THOUSAND             BINARY-LONG VALUE 1000.
 01 WS-R                    BINARY-LONG.
 01 WS-EV-HAPPY             BINARY-LONG VALUE 12.
 01 WS-EV-ANGRY             BINARY-LONG VALUE 13.
 01 WS-KIND-BED             BINARY-LONG VALUE 1.
 01 WS-HOME                 BINARY-LONG VALUE 2.
 01 WS-RANGE                BINARY-LONG VALUE 48.
 01 WS-PX                   BINARY-LONG.
 01 WS-PY                   BINARY-LONG.
 01 WS-PZ                   BINARY-LONG.
 01 WS-QX                   BINARY-LONG.
 01 WS-QY                   BINARY-LONG.
 01 WS-QZ                   BINARY-LONG.
 01 WS-FOUND                BINARY-LONG.
 01 WS-TYPE                 BINARY-LONG.
 01 WS-KEY                  PIC X(112).
 01 WS-ENTITY-ROW           PIC X(66).
 01 WS-STATUS               BINARY-LONG.
 01 WS-X                    FLOAT-LONG.
 01 WS-Y                    FLOAT-LONG.
 01 WS-Z                    FLOAT-LONG.
 01 WS-YAW                  FLOAT-SHORT VALUE 0.
 01 WS-BABY                 BINARY-LONG.
 01 WS-BIOME                BINARY-LONG.
 01 WS-OWN                  BINARY-LONG.
 01 WS-OTHER                BINARY-LONG.
 01 WS-DIM                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SA
     IF WS-SA = 0 OR VL-LOVE(WS-SA) = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-P
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-P > 0
         IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = VL-LOVE(WS-SA) AND EN-HEALTH(WS-E) > 0
             MOVE WS-E TO WS-P
         END-IF
     END-PERFORM
     IF WS-P > 0
         CALL "VL-FIND" USING EN-ID(WS-P) WS-NO WS-SB
     END-IF
     IF WS-P = 0 OR WS-SB = 0 OR VL-LOVE(WS-SB) NOT = EN-ID(L-ROW)
         MOVE 0 TO VL-LOVE(WS-SA)
         GOBACK
     END-IF
     COMPUTE WS-DX = EN-X(WS-P) - EN-X(L-ROW)
     COMPUTE WS-DZ = EN-Z(WS-P) - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
     IF WS-D2 > 5
*>       Both walk toward each other (speed 0.5, within 2 blocks counts as there).
         IF EN-COOLDOWN(L-ROW) = 0
             MOVE EN-X(WS-P) TO EN-DEST-X(L-ROW)
             MOVE EN-Z(WS-P) TO EN-DEST-Z(L-ROW)
             MOVE 20 TO EN-COOLDOWN(L-ROW)
         END-IF
     ELSE
         CALL "XP-RANDOM" USING WS-SALT-H WS-THIRTY-FIVE WS-R
         IF WS-R = 0
             CALL "VL-EVENT-SEND" USING L-ROW WS-EV-HAPPY
             CALL "VL-EVENT-SEND" USING WS-P WS-EV-HAPPY
         END-IF
     END-IF
     IF CW-TICKS >= VL-LOVE-AT(WS-SA)
         CALL "VL-LOVE-EAT" USING WS-SA
         CALL "VL-LOVE-EAT" USING WS-SB
         PERFORM BIRTH
         MOVE 0 TO VL-LOVE(WS-SA) VL-LOVE(WS-SB)
     END-IF
     GO TO MAIN-EXIT.

 BIRTH.
*>   takeVacantBed: an unclaimed bed within 48 blocks; none: angry particles on both and no child.
     COMPUTE WS-PX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "PXI-NEAREST" USING EN-DIM(L-ROW) WS-PX WS-PY WS-PZ WS-KIND-BED WS-RANGE WS-QX WS-QY WS-QZ WS-FOUND
     IF WS-FOUND = 0
         CALL "VL-EVENT-SEND" USING L-ROW WS-EV-ANGRY
         CALL "VL-EVENT-SEND" USING WS-P WS-EV-ANGRY
     ELSE
         MOVE "minecraft:villager" TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         MOVE EN-DIM(L-ROW) TO WS-DIM
         MOVE EN-X(L-ROW) TO WS-X
         MOVE EN-Y(L-ROW) TO WS-Y
         MOVE EN-Z(L-ROW) TO WS-Z
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-BABY
         MOVE -24000 TO EN-MOBAGE(WS-BABY)
         MOVE 1 TO EN-VARIANT(WS-BABY)
         MOVE 6000 TO EN-MOBAGE(L-ROW) EN-MOBAGE(WS-P)
         CALL "VL-FIND" USING EN-ID(WS-BABY) WS-NO WS-BABY-SLOT
*>       The biome type of the position is the one MOB-BORN gave the baby (r < 0.5); then this parent's and the other parent's.
         CALL "XP-RANDOM" USING WS-SALT-T WS-THOUSAND WS-R
         MOVE VL-TYPE(WS-BABY-SLOT) TO WS-BIOME
         MOVE VL-TYPE(WS-SA) TO WS-OWN
         MOVE VL-TYPE(WS-SB) TO WS-OTHER
         CALL "VIL-OFFSPRING" USING WS-R WS-BIOME WS-OWN WS-OTHER VL-TYPE(WS-BABY-SLOT)
         CALL "VPX-CLAIM" USING EN-ID(WS-BABY) WS-HOME WS-DIM WS-QX WS-QY WS-QZ
         CALL "MOB-DATA-SEND" USING WS-BABY
         CALL "VL-EVENT-SEND" USING WS-BABY WS-EV-HAPPY
     END-IF.
 MAIN-EXIT.
     CONTINUE.
 END PROGRAM VL-LOVE-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. VL-BREED-STEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 01 WS-SLOT                 BINARY-LONG.
 01 WS-NO                   BINARY-LONG VALUE 0.
 01 WS-DAY                  BINARY-LONG.
 01 WS-ACT                  BINARY-LONG.
 01 WS-BABY                 BINARY-LONG VALUE 0.
 01 WS-SALT                 BINARY-LONG VALUE 804.
 01 WS-EIGHT                BINARY-LONG VALUE 8.
 01 WS-R                    BINARY-LONG.
 01 WS-P                    BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "VL-FIND" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0 OR VL-KIND(WS-SLOT) NOT = 1
         GOBACK
     END-IF
     IF VL-LOVE(WS-SLOT) > 0
         CALL "VL-LOVE-TICK" USING L-ROW
         GOBACK
     END-IF
     IF EN-MOBAGE(L-ROW) NOT = 0 OR FUNCTION MOD(CW-TICKS + EN-ID(L-ROW), 20) NOT = 0
         GOBACK
     END-IF
     COMPUTE WS-DAY = FUNCTION MOD(CW-TIME, 24000)
     CALL "VIL-DAY-ACT" USING WS-DAY WS-BABY WS-ACT
     IF WS-ACT NOT = 0
         GOBACK
     END-IF
     CALL "XP-RANDOM" USING WS-SALT WS-EIGHT WS-R
     IF WS-R = 0
         CALL "VL-LOVE-PICK" USING L-ROW WS-P
         IF WS-P > 0
             CALL "VL-LOVE-START" USING L-ROW WS-P
         END-IF
     END-IF
     GOBACK.
 END PROGRAM VL-BREED-STEP.
