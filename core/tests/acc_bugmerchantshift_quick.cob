*> Acceptance test of the operator report "shift clicking in the trading UI should move stacks or buy all that can be bought" (try18 play; bug lane bugmerchantshift;
*> docs/protocol/40-menus-5 sections 2.7 and 2.8, 40-1 sections 3.4 and 3.6). Everything goes through Container Click packets (TEST-CLICK) on the real play path: an apprentice
*> librarian (level 1, 8 xp) with its three level 1 trades, the Player with 64 emeralds, trade 2 (9 emeralds for a bookshelf, 12 uses, 1 xp) selected with Select Trade, which
*> fills the payment slot with the whole stack from the inventory (2.7). A shift click on the result slot buys while the payments satisfy the offer (7 trades: one bookshelf each,
*> 63 emeralds used), stops at the maximum uses (3 trades left of 12), at a full inventory (nothing moves), and levels the villager up. A shift click on a payment slot returns the
*> stack to the inventory; a shift click on an inventory slot goes between the main inventory and the hotbar, never into the payment slots (2.8).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGMERCHANTSHIFT-QUICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY COREAPI.
 COPY VILSTATE.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PACKET-ID           BINARY-LONG VALUE 18.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-EMERALD             BINARY-LONG.
 01 WS-SHELF               BINARY-LONG.
 01 WS-DIRT                BINARY-LONG.
 01 WS-VROW                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-LIB                 PIC X(16) VALUE "librarian".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-IDS                 PIC X(1024).
 01 WS-OTYPE               BINARY-LONG.
 01 WS-OBEFORE             BINARY-LONG.
 01 WS-OAFTER              BINARY-LONG.
 01 WS-OI                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CLICK-SLOT          BINARY-LONG.
 01 WS-CLICK-BUTTON        BINARY-LONG VALUE 0.
 01 WS-CLICK-TYPE          BINARY-LONG VALUE 1.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-LABEL               PIC X(120).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "emerald" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-EMERALD
     MOVE "bookshelf" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SHELF
     MOVE "dirt" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DIRT
     CALL "XP-ORB-TYPE" USING WS-OTYPE
     MOVE PL-X(WS-ROW) TO WS-X
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-VROW
     CALL "VL-FIND" USING EN-ID(WS-VROW) WS-ONE WS-SLOT
     MOVE "librarian" TO VL-PROF(WS-SLOT)
     CALL "VIL-TRADE-SET" USING WS-LIB WS-ONE WS-FIRST WS-N WS-PICK
     MOVE "N" TO TL-MODE
     PERFORM RESET-TRADER
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "MERCHANT-INTERACT" USING WS-ROW WS-VROW WS-USED
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS

*>   2.7: Select Trade fills the payment slot with the whole stack from the inventory, not only the price.
     PERFORM RESET-TRADER
     PERFORM SELECT-SHELF
     MOVE "acceptance bugmerchantshift 40-5 2.7 Select Trade fills payment slot 0 with all 64 emeralds" TO TL-CASE
     MOVE 64 TO TL-EXPECTED-N
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugmerchantshift 40-5 2.7 the inventory slot is empty after the fill" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SLOT-COUNT(WS-ROW, 10) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugmerchantshift 40-5 2.4 the result is 1 bookshelf" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-SHELF * 1000 + 1
     COMPUTE TL-OBSERVED-N = MN-RESULT-ITEM(WS-ROW) * 1000 + MN-RESULT-COUNT(WS-ROW)
     PERFORM CHECK

*>   2.8 result slot: shift click buys 7 times (63 of 64 emeralds), one stack of 7 bookshelves in the last hotbar slot.
     PERFORM COUNT-ORBS
     MOVE WS-OAFTER TO WS-OBEFORE
     MOVE 2 TO WS-CLICK-SLOT
     PERFORM SHIFT-CLICK
     MOVE "acceptance bugmerchantshift 40-5 2.8 shift click on the result buys 7 bookshelves into the hotbar end" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-SHELF * 1000 + 7
     COMPUTE TL-OBSERVED-N = PL-SLOT-ITEM(WS-ROW, 9) * 1000 + PL-SLOT-COUNT(WS-ROW, 9)
     PERFORM CHECK
     MOVE "acceptance bugmerchantshift 40-5 2.8 63 emeralds are used, 1 is left in the payment slot" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugmerchantshift 19 22.4 the offer was used 7 times" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     MOVE VL-O-USES(WS-SLOT, 3) TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "acceptance bugmerchantshift 19 22.4 the villager gained 7 xp (8 + 7 = 15, level 2)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 15 * 100 + 2
     COMPUTE TL-OBSERVED-N = VL-XP(WS-SLOT) * 100 + VL-LEVEL(WS-SLOT)
     PERFORM CHECK
     PERFORM COUNT-ORBS
     MOVE "acceptance bugmerchantshift 19 22.2 each trade spawned an xp orb" TO TL-CASE
     MOVE 7 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-OAFTER - WS-OBEFORE
     PERFORM CHECK
     MOVE "acceptance bugmerchantshift 40-5 2.4 the result is empty once the payment cannot pay" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MN-RESULT-COUNT(WS-ROW) TO TL-OBSERVED-N
     PERFORM CHECK

*>   2.8 payment slot: shift click returns the stack to the inventory (main inventory first).
     MOVE 0 TO WS-CLICK-SLOT
     PERFORM SHIFT-CLICK
     MOVE "acceptance bugmerchantshift 40-5 2.8 shift click on the payment slot returns the emerald to the main inventory" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-EMERALD * 1000 + 1
     COMPUTE TL-OBSERVED-N = PL-SLOT-ITEM(WS-ROW, 10) * 1000 + PL-SLOT-COUNT(WS-ROW, 10)
     PERFORM CHECK
     MOVE "acceptance bugmerchantshift 40-5 2.8 the payment slot is empty" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO TL-OBSERVED-N
     PERFORM CHECK

*>   2.8 inventory slots: main inventory to hotbar, hotbar to main inventory; nothing goes into the payment slots.
     MOVE 3 TO WS-CLICK-SLOT
     PERFORM SHIFT-CLICK
     MOVE "acceptance bugmerchantshift 40-5 2.8 shift click on a main inventory slot moves the emerald into the hotbar" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-EMERALD * 1000 + 1
     COMPUTE TL-OBSERVED-N = PL-SLOT-ITEM(WS-ROW, 1) * 1000 + PL-SLOT-COUNT(WS-ROW, 1)
     PERFORM CHECK
     MOVE "acceptance bugmerchantshift 40-5 2.8 the payment slots stay empty" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = MN-WSLOT-COUNT(WS-ROW, 1) + MN-WSLOT-COUNT(WS-ROW, 2) + PL-SLOT-COUNT(WS-ROW, 10)
     PERFORM CHECK
     MOVE 30 TO WS-CLICK-SLOT
     PERFORM SHIFT-CLICK
     MOVE "acceptance bugmerchantshift 40-5 2.8 shift click on a hotbar slot moves the emerald into the main inventory" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-EMERALD * 1000 + 1
     COMPUTE TL-OBSERVED-N = PL-SLOT-ITEM(WS-ROW, 10) * 1000 + PL-SLOT-COUNT(WS-ROW, 10)
     PERFORM CHECK

*>   Maximum uses: 9 of 12 used, so 3 trades are left whatever the emeralds; 11 + 3 xp is level 2 (the threshold is 10).
     PERFORM RESET-TRADER
     MOVE 9 TO VL-O-USES(WS-SLOT, 3)
     PERFORM SELECT-SHELF
     MOVE 2 TO WS-CLICK-SLOT
     PERFORM SHIFT-CLICK
     MOVE "acceptance bugmerchantshift 40-5 2.8 shift click stops at the maximum uses: 3 bookshelves, 12 uses" TO TL-CASE
     COMPUTE TL-EXPECTED-N = (WS-SHELF * 1000 + 3) * 100 + 12
     COMPUTE TL-OBSERVED-N = (PL-SLOT-ITEM(WS-ROW, 9) * 1000 + PL-SLOT-COUNT(WS-ROW, 9)) * 100 + VL-O-USES(WS-SLOT, 3)
     PERFORM CHECK
     MOVE "acceptance bugmerchantshift 40-5 2.4 out of stock: no result, 37 emeralds still in the payment slot" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 37
     COMPUTE TL-OBSERVED-N = MN-WSLOT-COUNT(WS-ROW, 1) + MN-RESULT-COUNT(WS-ROW)
     PERFORM CHECK
     MOVE "acceptance bugmerchantshift 19 22.4 three trades of 1 xp level the villager up (11 xp, level 2)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 11 * 100 + 2
     COMPUTE TL-OBSERVED-N = VL-XP(WS-SLOT) * 100 + VL-LEVEL(WS-SLOT)
     PERFORM CHECK

*>   A full inventory: no trade at all, the payment stays.
     PERFORM RESET-TRADER
     PERFORM SELECT-SHELF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE WS-DIRT TO PL-SLOT-ITEM(WS-ROW, WS-I)
         MOVE 64 TO PL-SLOT-COUNT(WS-ROW, WS-I)
     END-PERFORM
     MOVE 2 TO WS-CLICK-SLOT
     PERFORM SHIFT-CLICK
     MOVE "acceptance bugmerchantshift 40-5 2.8 a full inventory: no trade, 64 emeralds and 0 uses" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 64 * 100 + 0
     COMPUTE TL-OBSERVED-N = MN-WSLOT-COUNT(WS-ROW, 1) * 100 + VL-O-USES(WS-SLOT, 3)
     PERFORM CHECK
     STOP RUN.

*> A villager of level 1 with its three trades, unused, 8 xp; an empty inventory with 64 emeralds in the first main inventory slot; the payments back in the inventory.
 RESET-TRADER.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         MOVE 0 TO MN-WSLOT-ITEM(WS-ROW, WS-I) MN-WSLOT-COUNT(WS-ROW, WS-I) MN-WSLOT-VAR(WS-ROW, WS-I)
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-ITEM(WS-ROW, WS-I) PL-SLOT-COUNT(WS-ROW, WS-I)
     END-PERFORM
     MOVE WS-EMERALD TO PL-SLOT-ITEM(WS-ROW, 10)
     MOVE 64 TO PL-SLOT-COUNT(WS-ROW, 10)
     MOVE 3 TO VL-O-N(WS-SLOT)
     MOVE 1 TO VL-BUILT(WS-SLOT) VL-LEVEL(WS-SLOT)
     MOVE 8 TO VL-XP(WS-SLOT)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         COMPUTE VL-O-ROW(WS-SLOT, WS-I) = WS-FIRST + WS-I - 1
         MOVE 0 TO VL-O-USES(WS-SLOT, WS-I) VL-O-DEMAND(WS-SLOT, WS-I) VL-O-SPECIAL(WS-SLOT, WS-I) VL-O-EXTRA(WS-SLOT, WS-I)
     END-PERFORM.

 SELECT-SHELF.
     MOVE 2 TO WS-INDEX
     CALL "MERCHANT-SELECT" USING WS-CONN WS-INDEX
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 SHIFT-CLICK.
*>   Container Click (05c 0x12) of the open window (TEST-CLICK names container 0): the state id, the slot, the button, the type, no changed slots, no cursor.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-PACKET-ID
     CALL "PB-PUT-VARINT" USING PB-BUFFER MN-WINDOW(WS-ROW)
     CALL "PB-PUT-VARINT" USING PB-BUFFER PL-STATE-ID(WS-ROW)
     CALL "PB-PUT-SHORT" USING PB-BUFFER WS-CLICK-SLOT
     CALL "PB-PUT-BYTE" USING PB-BUFFER WS-CLICK-BUTTON
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-CLICK-TYPE
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     CALL "PB-PUT-BOOL" USING PB-BUFFER WS-ZERO
     CALL "TEST-FEED-BUFFER" USING WS-CONN PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS.

 COUNT-ORBS.
     MOVE 0 TO WS-OAFTER
     PERFORM VARYING WS-OI FROM 1 BY 1 UNTIL WS-OI > EN-COUNT
         IF EN-USED(WS-OI) = 1 AND EN-TYPE(WS-OI) = WS-OTYPE
             ADD 1 TO WS-OAFTER
         END-IF
     END-PERFORM.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-BUGMERCHANTSHIFT-QUICK.
 COPY CORETEST.
 COPY BETEST.
