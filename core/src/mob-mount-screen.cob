*> The mount screen of the horse family and the nautilus in the live window of a player (docs/protocol/40-menus-6-mount-inventories.md sections 2 to 4; 19 section 3.5 steps 2 and 3).
*> Wrap I2 round 2, T52093. A menu of MN-CFAMILY 15 (CMENU.cpy): MN-BENCH-X the tracker row of the mount, MN-BENCH-Y its entity id, MN-BENCH-DIM the dimension; own slots 0 the saddle (EN-SADDLE
*> says whether a saddle is worn), 1 the body slot (WC-BODY of WCSTATE.cpy: horse armor, a llama carpet, nautilus armor), 2 and up the chest (WC-INV, 3 x columns slots), then the 27 main
*> inventory and 9 hotbar slots of the player. Opened by a sneaking player's Interact on a tamed adult mount (MNT-USE) or by Player Command 5 of its rider (MNT-RIDER-OPEN); the
*> packet is Mount Screen Open 0x2A (no Open Screen packet), then Container Set Content. menu-container.cob, menus.cob and menu-lifecycle.cob route the family here.
*> Mount numbers are those of MN6-CLASS (menu-40-6.cob): 1 horse, 2 donkey, 3 mule, 4 llama, 5 trader llama, 6 skeleton horse, 7 zombie horse, 8 nautilus, 9 zombie nautilus.
*> Not built: the equip sound (no entity sounds exist), the item components of a worn armour (only its item id is kept), prevent_armor_change, saving the chest and the body slot in the mob's NBT.
*>
*>   MNT-KIND USING row, mount number out (0: not a mount)
*>   MNT-ITEM-KIND USING item, kind out (1 saddle, 2 llama carpet, 3 horse armor, 4 nautilus armor, 0 none)
*>   MNT-COLUMNS USING row, chest columns out (MN6-COLUMNS: 5 for a chested donkey or mule, the strength of a chested llama)
*>   MNT-EQUIP-SEND USING row, equipment slot ordinal (6 body, 7 saddle), item, count      Set Equipment to the viewers
*>   MNT-OPEN USING connection id, mount row, opened out
*>   MNT-GET / MNT-SET USING player row, own slot (0 based), item, count, patch handle
*>   MNT-MAYPLACE USING player row, own slot, item, result out
*>   MNT-QUICK USING player row, menu slot, returned item out, returned count out
*>   MNT-VALID USING player row, valid out
*>   MNT-DROP USING mount row                       the chest, the saddle and the body slot land on the ground when the mount dies
*>   MNT-USE USING player row, mount row, handled out       step 2: a tamed player-sneaking Interact opens the screen
*>   MNT-HELD USING player row, mount row, handled out      step 3: an item that is no food: makeMad on an untamed horse, else the body slot takes an equippable item
*>   MNT-RIDER-OPEN USING player row, handled out   OPEN_INVENTORY of the player riding a mount

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KIND.
     MOVE 0 TO L-KIND
     CALL "MOB-SPECIES-KEY" USING L-ROW WS-KEY
     EVALUATE WS-KEY
         WHEN "horse"
             MOVE 1 TO L-KIND
         WHEN "donkey"
             MOVE 2 TO L-KIND
         WHEN "mule"
             MOVE 3 TO L-KIND
         WHEN "llama"
             MOVE 4 TO L-KIND
         WHEN "trader_llama"
             MOVE 5 TO L-KIND
         WHEN "skeleton_horse"
             MOVE 6 TO L-KIND
         WHEN "zombie_horse"
             MOVE 7 TO L-KIND
         WHEN "nautilus"
             MOVE 8 TO L-KIND
         WHEN "zombie_nautilus"
             MOVE 9 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM MNT-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-ITEM-KIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CITEMS.
 01 WS-LEN                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-MOSS                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ITEM                 BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ITEM L-KIND.
     MOVE 0 TO L-KIND
     IF L-ITEM <= 0 OR L-ITEM >= IT-COUNT
         GOBACK
     END-IF
     MOVE IT-KEY-LENGTH(L-ITEM + 1) TO WS-LEN
     IF IT-KEY(L-ITEM + 1)(1:WS-LEN) = "minecraft:saddle" OR "saddle"
         MOVE 1 TO L-KIND
         GOBACK
     END-IF
     MOVE 0 TO WS-MOSS
     INSPECT IT-KEY(L-ITEM + 1)(1:WS-LEN) TALLYING WS-MOSS FOR ALL "moss"
     COMPUTE WS-START = WS-LEN - 6
     IF WS-LEN > 7 AND IT-KEY(L-ITEM + 1)(WS-START:7) = "_carpet" AND WS-MOSS = 0
         MOVE 2 TO L-KIND
     END-IF
     COMPUTE WS-START = WS-LEN - 11
     IF WS-LEN > 12 AND IT-KEY(L-ITEM + 1)(WS-START:12) = "_horse_armor"
         MOVE 3 TO L-KIND
     END-IF
     COMPUTE WS-START = WS-LEN - 14
     IF WS-LEN > 15 AND IT-KEY(L-ITEM + 1)(WS-START:15) = "_nautilus_armor"
         MOVE 4 TO L-KIND
     END-IF
     GOBACK.
 END PROGRAM MNT-ITEM-KIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-COLUMNS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-STRENGTH            BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-COLUMNS              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-COLUMNS.
     CALL "MNT-KIND" USING L-ROW WS-KIND
     CALL "WC-ROW-OPEN" USING L-ROW
     CALL "MN6-STRCLAMP" USING EN-STRENGTH(L-ROW) WS-STRENGTH
     CALL "MN6-COLUMNS" USING WS-KIND WC-CHEST(L-ROW) WS-STRENGTH L-COLUMNS WS-SLOTS
     GOBACK.
 END PROGRAM MNT-COLUMNS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-EQUIP-SEND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==EQ-==.
 COPY PROTO.
 01 WS-PACKET-ID           BINARY-LONG VALUE 104.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER EN-ID(L-ROW)
     CALL "PB-PUT-UBYTE" USING PB-BUFFER L-SLOT
     INITIALIZE EQ-ITEMSTACK-X
     MOVE L-COUNT TO EQ-ISX-COUNT
     MOVE L-ITEM TO EQ-ISX-ITEM
     CALL "PB-PUT-ITEM-STACK" USING PB-BUFFER EQ-ITEMSTACK-X
     CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM MNT-EQUIP-SEND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-PACKET-ID           BINARY-LONG VALUE 42.
 01 WS-KIND                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COLUMNS             BINARY-LONG.
 01 WS-NOPASS              BINARY-LONG.
 01 WS-PASSENGER           BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-INVENTORY           BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
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
     MOVE CN-PLAYER(L-ID) TO WS-ROW
     CALL "MNT-KIND" USING L-ENT WS-KIND
     MOVE 0 TO WS-NOPASS WS-PASSENGER
     IF EN-RIDER(L-ENT) = 0 AND EN-RIDER2(L-ENT) = 0 AND EN-PASS(L-ENT) = 0
         MOVE 1 TO WS-NOPASS
     END-IF
     IF EN-RIDER(L-ENT) = WS-ROW OR EN-RIDER2(L-ENT) = WS-ROW
         MOVE 1 TO WS-PASSENGER
     END-IF
     CALL "MN6-OPENOK" USING WS-NOPASS WS-PASSENGER EN-TAMED(L-ENT) WS-OK
     IF WS-KIND = 0 OR WS-OK = 0
         GOBACK
     END-IF
     CALL "MNT-COLUMNS" USING L-ENT WS-COLUMNS
     MOVE 0 TO WS-INVENTORY
     IF MN-WINDOW(WS-ROW) = 0
         MOVE 1 TO WS-INVENTORY
     END-IF
     CALL "MN6-OPENSTEPS" USING WS-INVENTORY MN-COUNTER(WS-ROW) WS-CLOSE WS-NEW
     IF WS-CLOSE = 1
         CALL "MENU-CLOSE" USING L-ID
     END-IF
     MOVE WS-NEW TO MN-COUNTER(WS-ROW) MN-WINDOW(WS-ROW)
     COMPUTE MN-CSIZE(WS-ROW) = 2 + 3 * WS-COLUMNS
     MOVE -1 TO MN-TYPE(WS-ROW)
     MOVE 15 TO MN-CFAMILY(WS-ROW)
     MOVE 0 TO MN-CBE1(WS-ROW) MN-CBE2(WS-ROW) MN-COPEN(WS-ROW, 1) MN-COPEN(WS-ROW, 2)
     MOVE 1 TO MN-STATE-ID(WS-ROW)
     MOVE EN-DIM(L-ENT) TO MN-BENCH-DIM(WS-ROW)
     MOVE L-ENT TO MN-BENCH-X(WS-ROW)
     MOVE EN-ID(L-ENT) TO MN-BENCH-Y(WS-ROW)
     MOVE 0 TO MN-BENCH-Z(WS-ROW)
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER MN-WINDOW(WS-ROW)
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-COLUMNS
     CALL "PB-PUT-INT" USING PB-BUFFER EN-ID(L-ENT)
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-CONTENT-BUILD" USING WS-ROW PB-BUFFER
     CALL "CORE-SEND" USING L-ID PB-BUFFER
     MOVE 1 TO L-OPENED
     GOBACK.
 END PROGRAM MNT-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY WCSTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE 0 TO L-ITEM L-COUNT L-VAR
     MOVE MN-BENCH-X(L-ROW) TO WS-E
     CALL "WC-ROW-OPEN" USING WS-E
     EVALUATE TRUE
         WHEN L-SLOT = 0 AND EN-SADDLE(WS-E) = 1
             MOVE "saddle" TO WS-KEY
             CALL "MOB-ITEM-ID" USING WS-KEY L-ITEM
             MOVE 1 TO L-COUNT
         WHEN L-SLOT = 1 AND WC-BODY(WS-E) > 0
             MOVE WC-BODY(WS-E) TO L-ITEM
             MOVE 1 TO L-COUNT
         WHEN L-SLOT >= 2 AND L-SLOT <= 16
             COMPUTE WS-I = L-SLOT - 1
             MOVE WC-INV-ITEM(WS-E, WS-I) TO L-ITEM
             MOVE WC-INV-COUNT(WS-E, WS-I) TO L-COUNT
             MOVE WC-INV-VAR(WS-E, WS-I) TO L-VAR
     END-EVALUATE
     GOBACK.
 END PROGRAM MNT-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-SET.
*> The saddle and body slots write the mount's equipment (Set Equipment to the viewers when the item changed; a non-empty stack makes the drop guaranteed and the mob persistent, 40-6 section 2.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY WCSTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-SADDLE              BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-SLOT-BODY           BINARY-LONG VALUE 6.
 01 WS-SLOT-SADDLE         BINARY-LONG VALUE 7.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-COUNT L-VAR.
     MOVE MN-BENCH-X(L-ROW) TO WS-E
     CALL "WC-ROW-OPEN" USING WS-E
     EVALUATE TRUE
         WHEN L-SLOT = 0
             MOVE 0 TO WS-SADDLE
             IF L-COUNT > 0
                 MOVE 1 TO WS-SADDLE
             END-IF
             IF WS-SADDLE NOT = EN-SADDLE(WS-E)
                 MOVE WS-SADDLE TO EN-SADDLE(WS-E)
                 MOVE "saddle" TO WS-KEY
                 CALL "MOB-ITEM-ID" USING WS-KEY WS-I
                 IF WS-SADDLE = 1
                     MOVE 1 TO EN-PERSISTENT(WS-E)
                     CALL "MNT-EQUIP-SEND" USING WS-E WS-SLOT-SADDLE WS-I WS-ONE
                 ELSE
                     CALL "MNT-EQUIP-SEND" USING WS-E WS-SLOT-SADDLE WS-ZERO WS-ZERO2
                 END-IF
             END-IF
         WHEN L-SLOT = 1
             MOVE 0 TO WS-SAME
             IF L-COUNT = 0 AND WC-BODY(WS-E) = 0
                 MOVE 1 TO WS-SAME
             END-IF
             IF L-COUNT > 0 AND WC-BODY(WS-E) = L-ITEM
                 MOVE 1 TO WS-SAME
             END-IF
             IF WS-SAME = 0
                 IF L-COUNT > 0
                     MOVE L-ITEM TO WC-BODY(WS-E)
                     MOVE 1 TO EN-PERSISTENT(WS-E)
                     CALL "MNT-EQUIP-SEND" USING WS-E WS-SLOT-BODY L-ITEM WS-ONE
                 ELSE
                     MOVE 0 TO WC-BODY(WS-E)
                     CALL "MNT-EQUIP-SEND" USING WS-E WS-SLOT-BODY WS-ZERO WS-ZERO2
                 END-IF
             END-IF
         WHEN L-SLOT >= 2 AND L-SLOT <= 16
             COMPUTE WS-I = L-SLOT - 1
             MOVE L-ITEM TO WC-INV-ITEM(WS-E, WS-I)
             MOVE L-COUNT TO WC-INV-COUNT(WS-E, WS-I)
             MOVE L-VAR TO WC-INV-VAR(WS-E, WS-I)
     END-EVALUATE
     GOBACK.
 END PROGRAM MNT-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-MAYPLACE.
*> 2.3: a stack is placed in the saddle or body slot only when it has an equippable component of that slot, the mount can use the slot and the item's allowed set holds the mount.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-E                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-IKIND               BINARY-LONG.
 01 WS-ISLOT               BINARY-LONG.
 01 WS-SHEAR               BINARY-LONG.
 01 WS-STACK               BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-SLOTEQ              BINARY-LONG.
 01 WS-ALIVE               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-CAN                 BINARY-LONG.
 01 WS-ABSENT              BINARY-LONG VALUE 0.
 01 WS-CONTAINS            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-ITEM L-RESULT.
     MOVE 1 TO L-RESULT
     IF L-SLOT >= 2
         GOBACK
     END-IF
     MOVE MN-BENCH-X(L-ROW) TO WS-E
     CALL "MNT-KIND" USING WS-E WS-KIND
     CALL "MNT-ITEM-KIND" USING L-ITEM WS-IKIND
     MOVE 0 TO WS-HAS WS-SLOTEQ WS-ALIVE WS-BABY
     IF WS-IKIND > 0
         MOVE 1 TO WS-HAS
     END-IF
     CALL "MN6-EQUIPPABLE" USING WS-IKIND WS-ISLOT WS-SHEAR WS-STACK
     IF WS-ISLOT = L-SLOT
         MOVE 1 TO WS-SLOTEQ
     END-IF
     IF EN-HEALTH(WS-E) > 0
         MOVE 1 TO WS-ALIVE
     END-IF
     IF EN-MOBAGE(WS-E) < 0
         MOVE 1 TO WS-BABY
     END-IF
     CALL "MN6-CANUSE" USING WS-KIND L-SLOT WS-ALIVE WS-BABY EN-TAMED(WS-E) WS-CAN
     CALL "MN6-ACCEPTS" USING WS-IKIND WS-KIND WS-CONTAINS
     CALL "MN6-MAYPLACE" USING WS-HAS WS-SLOTEQ WS-CAN WS-ABSENT WS-CONTAINS L-RESULT
     GOBACK.
 END PROGRAM MNT-MAYPLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-QUICK.
*> quickMoveStack of 40-6 section 2.6: a stack of the mount part goes to the player's slots from the end; a stack of the player part goes to the body slot, else the saddle slot, else the chest,
*> else it changes between the main inventory and the hotbar (that last move returns the empty stack, the others the pre-move stack).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CMENU.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-OWN                 BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-REVERSE             BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-HCOUNT              BINARY-LONG.
 01 WS-HVAR                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-RET-ITEM             BINARY-LONG.
 01 L-RET-COUNT            BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-SLOT L-RET-ITEM L-RET-COUNT.
     MOVE 0 TO L-RET-ITEM L-RET-COUNT WS-DONE
     CALL "MENU-GET-X" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-VAR
     IF WS-COUNT = 0
         GOBACK
     END-IF
     MOVE MN-CSIZE(L-ROW) TO WS-OWN
     COMPUTE WS-TOTAL = WS-OWN + 36
     MOVE WS-COUNT TO WS-LEFT
     MOVE 0 TO WS-MOVED
     IF L-SLOT < WS-OWN
         MOVE 1 TO WS-REVERSE
         CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-OWN WS-TOTAL WS-REVERSE WS-MOVED WS-VAR
         MOVE 1 TO WS-DONE
     END-IF
     MOVE 0 TO WS-REVERSE
*>   The body slot (1) then the saddle slot (0) take the stack when they accept it and are empty.
     MOVE 1 TO WS-SLOT
     PERFORM UNTIL WS-DONE = 1 OR WS-SLOT < 0
         CALL "MENU-MAY-PLACE" USING L-ROW WS-SLOT WS-ITEM WS-OK
         CALL "MENU-GET-X" USING L-ROW WS-SLOT WS-HELD WS-HCOUNT WS-HVAR
         IF WS-OK = 1 AND WS-HCOUNT = 0
             COMPUTE WS-FIRST = WS-SLOT + 1
             CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-SLOT WS-FIRST WS-REVERSE WS-MOVED WS-VAR
             MOVE 1 TO WS-DONE
         END-IF
         SUBTRACT 1 FROM WS-SLOT
     END-PERFORM
*>   A chest takes it next, with no item filter (the rest is the shuffle between the main inventory and the hotbar, whose result is the empty stack).
     IF WS-DONE = 0 AND WS-OWN > 2
         MOVE 2 TO WS-FIRST
         CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-OWN WS-REVERSE WS-MOVED WS-VAR
         IF WS-MOVED = 1
             MOVE 1 TO WS-DONE
         END-IF
     END-IF
     IF WS-DONE = 0
         EVALUATE TRUE
             WHEN L-SLOT >= WS-OWN + 27
                 COMPUTE WS-END = WS-OWN + 27
                 CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-OWN WS-END WS-REVERSE WS-MOVED WS-VAR
             WHEN OTHER
                 COMPUTE WS-FIRST = WS-OWN + 27
                 CALL "MENU-MOVE-TO-X" USING L-ROW WS-ITEM WS-LEFT WS-FIRST WS-TOTAL WS-REVERSE WS-MOVED WS-VAR
         END-EVALUATE
         IF WS-MOVED = 1
             CALL "MENU-SET-X" USING L-ROW L-SLOT WS-ITEM WS-LEFT WS-VAR
         END-IF
         GOBACK
     END-IF
     IF WS-MOVED = 1
         CALL "MENU-QUICK-FINISH" USING L-ROW L-SLOT WS-ITEM WS-COUNT WS-LEFT WS-MOVED L-RET-ITEM L-RET-COUNT
     END-IF
     GOBACK.
 END PROGRAM MNT-QUICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-VALID.
*> 2.1 stillValid: the mount is alive and the player is within the interaction range plus 4.0 (ECV-VALID's reach of the box).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-VALID.
     CALL "ECV-VALID" USING L-ROW L-VALID
     IF L-VALID = 1 AND EN-HEALTH(MN-BENCH-X(L-ROW)) = 0
         MOVE 0 TO L-VALID
     END-IF
     GOBACK.
 END PROGRAM MNT-VALID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-S                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-KEY                 PIC X(24).
 01 WS-OFFSET              FLOAT-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-PATCH               BINARY-LONG VALUE 0.
 01 WS-ITEM-ENTITY         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "MNT-KIND" USING L-ROW WS-KIND
     IF WS-KIND = 0
         GOBACK
     END-IF
     CALL "WC-ROW-OPEN" USING L-ROW
     MOVE EN-DIM(L-ROW) TO WS-DIM
     COMPUTE WS-X = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-Y = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-Z = FUNCTION INTEGER(EN-Z(L-ROW))
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 15
         IF WC-INV-COUNT(L-ROW, WS-S) > 0
             MOVE WC-INV-ITEM(L-ROW, WS-S) TO WS-ITEM
             MOVE WC-INV-COUNT(L-ROW, WS-S) TO WS-COUNT
             MOVE WC-INV-VAR(L-ROW, WS-S) TO WS-VAR
             MOVE 0 TO WC-INV-ITEM(L-ROW, WS-S) WC-INV-COUNT(L-ROW, WS-S) WC-INV-VAR(L-ROW, WS-S)
             CALL "BE-DROP-STACK" USING WS-DIM WS-X WS-Y WS-Z WS-ITEM WS-COUNT WS-VAR
         END-IF
     END-PERFORM
     IF WC-BODY(L-ROW) > 0
         CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET WC-BODY(L-ROW) WS-ONE
             WS-PATCH WS-ITEM-ENTITY
         MOVE 0 TO WC-BODY(L-ROW)
     END-IF
     IF EN-SADDLE(L-ROW) = 1
         MOVE "saddle" TO WS-KEY
         CALL "MOB-ITEM-ID" USING WS-KEY WS-ITEM
         CALL "IP-AT-LOCATION" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-OFFSET WS-ITEM WS-ONE
             WS-PATCH WS-ITEM-ENTITY
         MOVE 0 TO EN-SADDLE(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM MNT-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-PACKET              BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-VEHICLE             BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-OPENED              BINARY-LONG.
 01 WS-SNEAK               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ENTITY L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "MNT-KIND" USING L-ENTITY WS-KIND
     IF WS-KIND = 0
         GOBACK
     END-IF
     MOVE PL-SNEAKING(L-PLAYER) TO WS-SNEAK
     CALL "MN6-CLASS" USING WS-KIND WS-CLASS WS-TYPE WS-PACKET
     MOVE 0 TO WS-BABY WS-VEHICLE
     IF EN-MOBAGE(L-ENTITY) < 0
         MOVE 1 TO WS-BABY
     END-IF
     IF EN-RIDER(L-ENTITY) > 0 OR EN-RIDER2(L-ENTITY) > 0 OR EN-PASS(L-ENTITY) > 0
         MOVE 1 TO WS-VEHICLE
     END-IF
     CALL "MN6-INTERACT" USING WS-CLASS WS-BABY WS-VEHICLE EN-TAMED(L-ENTITY) WS-SNEAK WS-RESULT
     IF WS-RESULT = 1
         CALL "MNT-OPEN" USING PL-CONN(L-PLAYER) L-ENTITY WS-OPENED
         MOVE 1 TO L-HANDLED
     END-IF
     GOBACK.
 END PROGRAM MNT-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-HELD.
*> 19 section 3.5 step 3 for the horse family (mounts 1 to 7): an item that is no food on an untamed adult is makeMad (the action is consumed: SUCCESS; the rearing and its sound are doc gaps);
*> on a tamed one an item equippable in the body slot is equipped as one copy when none is worn (equipBodyArmor). An untamed skeleton horse is not interacted with (PASS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WCSTATE.
 01 WS-KIND                BINARY-LONG.
 01 WS-FOOD-KIND           BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KEY48               PIC X(48).
 01 WS-KEY                 PIC X(24).
 01 WS-FOUND               BINARY-LONG.
 01 WS-HEAL                BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-TEMPER              BINARY-LONG.
 01 WS-LOVE                BINARY-LONG.
 01 WS-IKIND               BINARY-LONG.
 01 WS-ISLOT               BINARY-LONG.
 01 WS-SHEAR               BINARY-LONG.
 01 WS-STACK               BINARY-LONG.
 01 WS-CONTAINS            BINARY-LONG.
 01 WS-SLOT-BODY           BINARY-LONG VALUE 6.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-ENTITY               BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-ENTITY L-HANDLED.
     MOVE 0 TO L-HANDLED
     CALL "MNT-KIND" USING L-ENTITY WS-KIND
     MOVE PL-SLOT-ITEM(L-PLAYER, PL-HELD(L-PLAYER) + 1) TO WS-ITEM
     IF WS-KIND = 0 OR WS-KIND > 7 OR EN-MOBAGE(L-ENTITY) < 0 OR PL-SLOT-COUNT(L-PLAYER, PL-HELD(L-PLAYER) + 1) = 0
         GOBACK
     END-IF
     MOVE 0 TO WS-FOOD-KIND
     IF WS-KIND = 4 OR WS-KIND = 5
         MOVE 1 TO WS-FOOD-KIND
     END-IF
     IF WS-KIND = 7
         MOVE 3 TO WS-FOOD-KIND
     END-IF
     CALL "TOOLUSE-KEY" USING WS-ITEM WS-KEY48
     MOVE WS-KEY48 TO WS-KEY
     CALL "M19-HORSE-FOOD" USING WS-FOOD-KIND WS-KEY WS-FOUND WS-HEAL WS-AGE WS-TEMPER WS-LOVE
     IF WS-FOUND = 1 OR (WS-KIND = 6 AND EN-TAMED(L-ENTITY) = 0)
         GOBACK
     END-IF
     IF EN-TAMED(L-ENTITY) = 0
         MOVE 1 TO L-HANDLED
         GOBACK
     END-IF
     CALL "WC-ROW-OPEN" USING L-ENTITY
     CALL "MNT-ITEM-KIND" USING WS-ITEM WS-IKIND
     CALL "MN6-ACCEPTS" USING WS-IKIND WS-KIND WS-CONTAINS
     CALL "MN6-EQUIPPABLE" USING WS-IKIND WS-ISLOT WS-SHEAR WS-STACK
     IF WS-IKIND > 1 AND WS-ISLOT = 1 AND WS-CONTAINS = 1 AND WC-BODY(L-ENTITY) = 0
         MOVE WS-ITEM TO WC-BODY(L-ENTITY)
         MOVE 1 TO EN-PERSISTENT(L-ENTITY)
         CALL "MNT-EQUIP-SEND" USING L-ENTITY WS-SLOT-BODY WS-ITEM WS-ONE
         CALL "MOB-TAKE" USING L-PLAYER
         MOVE 1 TO L-HANDLED
     END-IF
     GOBACK.
 END PROGRAM MNT-HELD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNT-RIDER-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-VEHICLE             BINARY-LONG.
 01 WS-OPENED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLAYER               BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-PLAYER L-HANDLED.
     MOVE 0 TO L-HANDLED
     MOVE EN-VEHICLE(PL-ENTITY-ROW(L-PLAYER)) TO WS-VEHICLE
     IF WS-VEHICLE > 0
         CALL "MNT-OPEN" USING PL-CONN(L-PLAYER) WS-VEHICLE WS-OPENED
         MOVE WS-OPENED TO L-HANDLED
     END-IF
     GOBACK.
 END PROGRAM MNT-RIDER-OPEN.
