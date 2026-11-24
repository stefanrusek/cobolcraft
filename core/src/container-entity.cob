*> Entities that hold a container: the chest minecart (27 slots, generic_9x3) and the hopper minecart (5 slots, hopper menu) of docs/protocol/44-residual-mob-questions-x2-continuation.md section 5
*> (ContainerEntity) and 44-residual-mob-questions-8 section 4.6 (container carts). Wrap C round 5, T24208 (core/copy/ECVSTATE.cpy holds the contents, one entry per tracker row).
*> The menu is the player's container menu with MN-CFAMILY 14 (MN-BENCH-X the tracker row, MN-BENCH-Y the entity id, MN-BENCH-DIM the dimension); menu-container.cob routes the slots of
*> that family here. The menu is valid while the entity lasts and the player's eye is within 3.0 + 4.0 blocks of its box (isChestVehicleStillValid).
*> Chest boats and chest rafts (EN-BT-KIND 2, T24205) use the same menu: BOAT-USE opens it (a sneaking player, a boat that cannot take a passenger) and BOAT-HURT scatters the contents.
*> Not built: the loot table of a mineshaft chest cart (key, seed, unpacking), the saved Items, container entities as the source of a hopper above, container_open and container_close game events.
*>
*>   ECV-ROW-OPEN USING row                                   the entry of the row is this entity's (a stale one is cleared)
*>   ECV-KIND USING row, size out, menu type out, name out (PIC X(48)), name length out       0 size: the entity holds no container
*>   ECV-OPEN USING connection id, entity row, opened out     interactWithContainerVehicle: Open Screen and Container Set Content
*>   ECV-GET USING player row, own slot (0 based), item out, count out, patch handle out
*>   ECV-SET USING player row, own slot, item, count, patch handle
*>   ECV-VALID USING player row, valid out                    the entity is alive and the player is within reach
*>   ECV-SIGNAL USING row, signal out                         getRedstoneSignalFromContainer (single precision, as BE-SIGNAL)
*>   ECV-FACTOR USING row, factor out                         the container cart's slowdown 0.98 + (15 - signal) x 0.001 (no loot table, not in water)
*>   ECV-ADD USING row, item, count in and out (what is left), patch handle      HopperBlockEntity.addItem into the entity's own slots, no face rules
*>   ECV-DROP USING row                                       Containers.dropContents at the entity's block position
*>   ECV-DESTROYED USING row, attacker player row (0 none)    chestVehicleDestroyed: the contents scatter, a player's hit angers the piglins that see him (entity_drops)
*>   ECV-TAKE-ITEMS USING row, box min x y z, box max x y z (FLOAT-LONG), moved out    the first item entity in the box that the container takes whole
*>   MC-HOPPER USING row, PJ slot                             MinecartHopper.tryConsumeItems: the container above, else the item entities above, else those in the cart's box

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-ROW-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ECVSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF ECV-ID(L-ROW) NOT = EN-ID(L-ROW)
         INITIALIZE ECV-ROW(L-ROW)
         MOVE EN-ID(L-ROW) TO ECV-ID(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM ECV-ROW-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY MOB181.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY-LENGTH          BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-NAME                 PIC X(48).
 01 L-NAME-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SIZE L-TYPE L-NAME L-NAME-LENGTH.
     MOVE 0 TO L-SIZE L-TYPE L-NAME-LENGTH
     MOVE SPACES TO L-NAME
     CALL "PJ-FIND" USING EN-ID(L-ROW) WS-SLOT
     IF WS-SLOT > 0 AND PJ-KIND(WS-SLOT) = 10
         EVALUATE PJ-I1(WS-SLOT)
             WHEN 2
                 MOVE 27 TO L-SIZE
                 MOVE 2 TO L-TYPE
                 MOVE "entity.minecraft.chest_minecart" TO L-NAME
                 MOVE 31 TO L-NAME-LENGTH
             WHEN 3
                 MOVE 5 TO L-SIZE
                 MOVE 16 TO L-TYPE
                 MOVE "entity.minecraft.hopper_minecart" TO L-NAME
                 MOVE 32 TO L-NAME-LENGTH
         END-EVALUATE
     END-IF
*>   A chest boat or chest raft (EN-BT-KIND 2): 27 slots, generic_9x3, titled by the entity's own name entity.minecraft.<key> (44-8 3.9).
     IF EN-BT-KIND(L-ROW) = 2
         MOVE 27 TO L-SIZE
         MOVE 2 TO L-TYPE
         COMPUTE WS-ROW = EN-TYPE(L-ROW) + 1
         COMPUTE WS-KEY-LENGTH = FUNCTION LENGTH(FUNCTION TRIM(M1-KEY(WS-ROW)))
         STRING "entity.minecraft." FUNCTION TRIM(M1-KEY(WS-ROW)) DELIMITED BY SIZE INTO L-NAME
         COMPUTE L-NAME-LENGTH = 17 + WS-KEY-LENGTH
     END-IF
     GOBACK.
 END PROGRAM ECV-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-PACKET-ID           BINARY-LONG VALUE 60.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-MENU-TYPE           BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-NAME-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-ENT                  BINARY-LONG.
 01 L-OPENED               BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-ENT L-OPENED.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE 0 TO L-OPENED
     CALL "ECV-KIND" USING L-ENT WS-SIZE WS-MENU-TYPE WS-NAME WS-NAME-LENGTH
     IF WS-SIZE = 0
         GOBACK
     END-IF
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "ECV-ROW-OPEN" USING L-ENT
     IF MN-WINDOW(WS-ROW) > 0
         CALL "MENU-CLOSE" USING L-ID
     END-IF
     COMPUTE MN-COUNTER(WS-ROW) = FUNCTION MOD(MN-COUNTER(WS-ROW), 100) + 1
     MOVE MN-COUNTER(WS-ROW) TO MN-WINDOW(WS-ROW)
     MOVE WS-SIZE TO MN-CSIZE(WS-ROW)
     MOVE WS-MENU-TYPE TO MN-TYPE(WS-ROW)
     MOVE 14 TO MN-CFAMILY(WS-ROW)
     MOVE 0 TO MN-CBE1(WS-ROW) MN-CBE2(WS-ROW) MN-COPEN(WS-ROW, 1) MN-COPEN(WS-ROW, 2)
     MOVE 1 TO MN-STATE-ID(WS-ROW)
     MOVE EN-DIM(L-ENT) TO MN-BENCH-DIM(WS-ROW)
     MOVE L-ENT TO MN-BENCH-X(WS-ROW)
     MOVE EN-ID(L-ENT) TO MN-BENCH-Y(WS-ROW)
     MOVE 0 TO MN-BENCH-Z(WS-ROW)
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE WS-NAME TO PB-TX-VALUE
     MOVE WS-NAME-LENGTH TO PB-TX-LENGTH
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-OPEN-SCREEN" USING PB-BUFFER MN-WINDOW(WS-ROW) WS-MENU-TYPE PB-TEXT
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     MOVE 1 TO L-OPENED
     GOBACK.
 END PROGRAM ECV-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 COPY ECVSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE ECV-ITEM(MN-BENCH-X(L-ROW), L-SLOT + 1) TO L-ITEM
     MOVE ECV-COUNT(MN-BENCH-X(L-ROW), L-SLOT + 1) TO L-COUNT
     MOVE ECV-VAR(MN-BENCH-X(L-ROW), L-SLOT + 1) TO L-VAR
     GOBACK.
 END PROGRAM ECV-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 COPY ECVSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE L-ITEM TO ECV-ITEM(MN-BENCH-X(L-ROW), L-SLOT + 1)
     MOVE L-COUNT TO ECV-COUNT(MN-BENCH-X(L-ROW), L-SLOT + 1)
     MOVE L-VAR TO ECV-VAR(MN-BENCH-X(L-ROW), L-SLOT + 1)
     GOBACK.
 END PROGRAM ECV-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-VALID.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY CITEMS.
 01 WS-E                   BINARY-LONG.
 01 WS-HALF                FLOAT-LONG.
 01 WS-HEIGHT              FLOAT-LONG.
 01 WS-EYE                 FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG VALUE 49.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-VALID.
     MOVE 0 TO L-VALID
     MOVE MN-BENCH-X(L-ROW) TO WS-E
     IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = MN-BENCH-Y(L-ROW) AND EN-DIM(WS-E) = PL-DIM(L-ROW)
         COMPUTE WS-HALF = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
         COMPUTE WS-HEIGHT = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
         COMPUTE WS-EYE = PL-Y(L-ROW) + 1.62
         COMPUTE WS-DX = FUNCTION MAX(EN-X(WS-E) - WS-HALF - PL-X(L-ROW), 0, PL-X(L-ROW) - EN-X(WS-E) - WS-HALF)
         COMPUTE WS-DY = FUNCTION MAX(EN-Y(WS-E) - WS-EYE, 0, WS-EYE - EN-Y(WS-E) - WS-HEIGHT)
         COMPUTE WS-DZ = FUNCTION MAX(EN-Z(WS-E) - WS-HALF - PL-Z(L-ROW), 0, PL-Z(L-ROW) - EN-Z(WS-E) - WS-HALF)
         IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < WS-LIMIT
             MOVE 1 TO L-VALID
         END-IF
     END-IF
     GOBACK.
 END PROGRAM ECV-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-SIGNAL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ECVSTATE.
 COPY CITEMS.
 01 WS-SUM                 FLOAT-SHORT.
 01 WS-Q                   FLOAT-SHORT.
 01 WS-F                   FLOAT-SHORT.
 01 WS-S                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SIGNAL.
     MOVE 0 TO WS-SUM L-SIGNAL
     CALL "ECV-KIND" USING L-ROW WS-SIZE WS-TYPE WS-NAME WS-NAME-LENGTH
     IF WS-SIZE = 0
         GOBACK
     END-IF
     CALL "ECV-ROW-OPEN" USING L-ROW
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SIZE
         IF ECV-COUNT(L-ROW, WS-S) > 0
             COMPUTE WS-MAX = ECV-ITEM(L-ROW, WS-S) + 1
             MOVE IT-MAX-STACK(WS-MAX) TO WS-MAX
             CALL "BE-MAX-STACK" USING WS-MAX WS-LIMIT
             COMPUTE WS-Q = ECV-COUNT(L-ROW, WS-S) / WS-LIMIT
             ADD WS-Q TO WS-SUM
         END-IF
     END-PERFORM
     COMPUTE WS-F = WS-SUM / WS-SIZE
     IF WS-F > 0
         COMPUTE WS-FLOOR = FUNCTION INTEGER(WS-F * 14)
         COMPUTE L-SIGNAL = WS-FLOOR + 1
     END-IF
     GOBACK.
 END PROGRAM ECV-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-FACTOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SIGNAL              BINARY-LONG.
 01 WS-LOOT                BINARY-LONG VALUE 0.
 01 WS-WATER               BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-F                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-F.
     CALL "ECV-SIGNAL" USING L-ROW WS-SIGNAL
     CALL "Q8-CART-FACTOR" USING WS-SIGNAL WS-LOOT WS-WATER L-F
     GOBACK.
 END PROGRAM ECV-FACTOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY ECVSTATE.
 COPY CITEMS.
 01 WS-S                   BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-NAME-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-VAR.
     CALL "ECV-KIND" USING L-ROW WS-SIZE WS-TYPE WS-NAME WS-NAME-LENGTH
     CALL "ECV-ROW-OPEN" USING L-ROW
     COMPUTE WS-MAX = L-ITEM + 1
     MOVE IT-MAX-STACK(WS-MAX) TO WS-MAX
     CALL "BE-MAX-STACK" USING WS-MAX WS-LIMIT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SIZE OR L-COUNT = 0
         EVALUATE TRUE
             WHEN ECV-COUNT(L-ROW, WS-S) = 0
                 MOVE FUNCTION MIN(L-COUNT, WS-LIMIT) TO WS-MOVE
                 MOVE L-ITEM TO ECV-ITEM(L-ROW, WS-S)
                 MOVE L-VAR TO ECV-VAR(L-ROW, WS-S)
                 MOVE WS-MOVE TO ECV-COUNT(L-ROW, WS-S)
                 SUBTRACT WS-MOVE FROM L-COUNT
             WHEN ECV-ITEM(L-ROW, WS-S) = L-ITEM AND ECV-VAR(L-ROW, WS-S) = L-VAR AND ECV-COUNT(L-ROW, WS-S) < WS-LIMIT
                 MOVE FUNCTION MIN(L-COUNT, WS-LIMIT - ECV-COUNT(L-ROW, WS-S)) TO WS-MOVE
                 ADD WS-MOVE TO ECV-COUNT(L-ROW, WS-S)
                 SUBTRACT WS-MOVE FROM L-COUNT
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM ECV-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ECVSTATE.
 01 WS-S                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "ECV-ROW-OPEN" USING L-ROW
     MOVE EN-DIM(L-ROW) TO WS-DIM
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 27
         IF ECV-COUNT(L-ROW, WS-S) > 0
             MOVE ECV-ITEM(L-ROW, WS-S) TO WS-ITEM
             MOVE ECV-COUNT(L-ROW, WS-S) TO WS-COUNT
             MOVE ECV-VAR(L-ROW, WS-S) TO WS-VAR
             MOVE 0 TO ECV-ITEM(L-ROW, WS-S) ECV-COUNT(L-ROW, WS-S) ECV-VAR(L-ROW, WS-S)
             CALL "BE-DROP-STACK" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM WS-COUNT WS-VAR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ECV-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-DESTROYED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RULE-NAME           PIC X(40) VALUE "entity_drops".
 01 WS-RULE                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     CALL "ECV-DROP" USING L-ROW
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     IF WS-RULE NOT = 0 AND L-ATTACKER > 0
         CALL "PIGLIN-CONTAINER-OPENED" USING L-ATTACKER
     END-IF
     GOBACK.
 END PROGRAM ECV-DESTROYED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ECV-TAKE-ITEMS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY CITEMPHYS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-E                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-MIN-X                FLOAT-LONG.
 01 L-MIN-Y                FLOAT-LONG.
 01 L-MIN-Z                FLOAT-LONG.
 01 L-MAX-X                FLOAT-LONG.
 01 L-MAX-Y                FLOAT-LONG.
 01 L-MAX-Z                FLOAT-LONG.
 01 L-MOVED                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-MIN-X L-MIN-Y L-MIN-Z L-MAX-X L-MAX-Y L-MAX-Z L-MOVED.
     MOVE 0 TO L-MOVED WS-DONE
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR WS-DONE = 1
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = CR-LOOSE-ITEM AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-ITEM-COUNT(WS-E) > 0
                 AND EN-X(WS-E) + 0.125 > L-MIN-X AND EN-X(WS-E) - 0.125 < L-MAX-X
                 AND EN-Y(WS-E) + 0.25 > L-MIN-Y AND EN-Y(WS-E) < L-MAX-Y
                 AND EN-Z(WS-E) + 0.125 > L-MIN-Z AND EN-Z(WS-E) - 0.125 < L-MAX-Z
             CALL "IP-ENSURE" USING WS-E
             MOVE EN-ITEM(WS-E) TO WS-ITEM
             MOVE EN-ITEM-COUNT(WS-E) TO WS-COUNT
             MOVE IP-I-VAR(WS-E) TO WS-VAR
             MOVE WS-COUNT TO WS-BEFORE
             CALL "ECV-ADD" USING L-ROW WS-ITEM WS-COUNT WS-VAR
             IF WS-COUNT < WS-BEFORE
                 MOVE WS-COUNT TO EN-ITEM-COUNT(WS-E)
                 IF WS-COUNT = 0
                     CALL "ENTITY-REMOVE" USING WS-E
                     MOVE 1 TO WS-DONE L-MOVED
                 ELSE
                     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
                     CALL "GI-DATA-BUILD" USING WS-E PB-BUFFER
                     CALL "GI-VIEWERS-SEND" USING WS-E PB-BUFFER
                     CALL "PB-FREE" USING PB-BUFFER
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ECV-TAKE-ITEMS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MC-HOPPER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY BESTATE.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-SSIZE               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-MIN-X               FLOAT-LONG.
 01 WS-MIN-Y               FLOAT-LONG.
 01 WS-MIN-Z               FLOAT-LONG.
 01 WS-MAX-X               FLOAT-LONG.
 01 WS-MAX-Y               FLOAT-LONG.
 01 WS-MAX-Z               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT.
     IF PJ-I6(L-SLOT) = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-DONE WS-SOURCE WS-SSIZE
*>   The container above: the block that holds (x, y + 0.5 + 1, z) (the cart's hopper position is (x, y + 0.5, z)).
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-MIN-Y = EN-Y(L-ROW) + 1.5
     COMPUTE WS-BY = FUNCTION INTEGER(WS-MIN-Y)
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "HOPPER-CONTAINER" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-SOURCE WS-SSIZE
     IF WS-SOURCE > 0
         PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-SSIZE OR WS-DONE = 1
             CALL "HOPPER-FACE-SLOT" USING WS-SOURCE WS-DOWN WS-N WS-S
             MOVE 0 TO WS-OK
             IF WS-S > 0 AND BE-SLOT-COUNT(WS-SOURCE, WS-S) > 0
                 CALL "HOPPER-CAN-TAKE" USING WS-SOURCE WS-S BE-SLOT-ITEM(WS-SOURCE, WS-S) WS-DOWN WS-OK
             END-IF
             IF WS-OK = 1
                 MOVE BE-SLOT-ITEM(WS-SOURCE, WS-S) TO WS-ITEM
                 MOVE BE-SLOT-VAR(WS-SOURCE, WS-S) TO WS-VAR
                 MOVE 1 TO WS-LEFT
                 CALL "ECV-ADD" USING L-ROW WS-ITEM WS-LEFT WS-VAR
                 IF WS-LEFT = 0
                     SUBTRACT 1 FROM BE-SLOT-COUNT(WS-SOURCE, WS-S)
                     IF BE-SLOT-COUNT(WS-SOURCE, WS-S) = 0
                         MOVE 0 TO BE-SLOT-ITEM(WS-SOURCE, WS-S) BE-SLOT-VAR(WS-SOURCE, WS-S)
                     END-IF
                     CALL "BE-MARK-CHUNK" USING WS-SOURCE
                     MOVE 1 TO WS-DONE
                 END-IF
             END-IF
         END-PERFORM
     ELSE
*>       No container: the item entities in SUCK_AABB (x and z 1 wide, y from 0.6875 to 2.0 above the cart's base less 0.5), then the ones in the cart's box inflated by (0.25, 0, 0.25).
         COMPUTE WS-MIN-X = EN-X(L-ROW) - 0.5
         COMPUTE WS-MAX-X = EN-X(L-ROW) + 0.5
         COMPUTE WS-MIN-Y = EN-Y(L-ROW) + 0.6875
         COMPUTE WS-MAX-Y = EN-Y(L-ROW) + 2.0
         COMPUTE WS-MIN-Z = EN-Z(L-ROW) - 0.5
         COMPUTE WS-MAX-Z = EN-Z(L-ROW) + 0.5
         CALL "ECV-TAKE-ITEMS" USING L-ROW WS-MIN-X WS-MIN-Y WS-MIN-Z WS-MAX-X WS-MAX-Y WS-MAX-Z WS-MOVED
         IF WS-MOVED = 0
             COMPUTE WS-MIN-X = EN-X(L-ROW) - 0.74
             COMPUTE WS-MAX-X = EN-X(L-ROW) + 0.74
             MOVE EN-Y(L-ROW) TO WS-MIN-Y
             COMPUTE WS-MAX-Y = EN-Y(L-ROW) + 0.7
             COMPUTE WS-MIN-Z = EN-Z(L-ROW) - 0.74
             COMPUTE WS-MAX-Z = EN-Z(L-ROW) + 0.74
             CALL "ECV-TAKE-ITEMS" USING L-ROW WS-MIN-X WS-MIN-Y WS-MIN-Z WS-MAX-X WS-MAX-Y WS-MAX-Z WS-MOVED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MC-HOPPER.
