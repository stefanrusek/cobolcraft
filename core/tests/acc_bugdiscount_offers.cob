*> Acceptance test, lane 002-lane-bugdiscount (T59501; docs/protocol/40-menus-5-merchant-beacon-lectern.md 1.3 and 2.4, 19 section 22.4): Merchant Offers carries the offer's BASE first cost
*> (the client recomputes the price and draws the base count crossed out when it differs), the special price diff of the player (Hero of the Village), the price multiplier and the demand, and the
*> price the core charges for the offer (VL-OFFER-COST, the stacks of the payment slots) is the one the client computes from those wire fields: clamp(base + max(0, floor(base x demand x m)) + diff, 1, 64).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGDISCOUNT-OFFERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY VILSTATE.
 COPY PROTO.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-VROW                BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-LIB                 PIC X(16) VALUE "librarian".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-VID                 BINARY-LONG.
 01 WS-WANT                PIC X(32).
 01 WS-EXTRA               PIC X(32).
 01 WS-GIVE                PIC X(32).
 01 WS-WC                  BINARY-LONG.
 01 WS-EC                  BINARY-LONG.
 01 WS-GC                  BINARY-LONG.
 01 WS-MU                  BINARY-LONG.
 01 WS-XPV                 BINARY-LONG.
 01 WS-MULT                BINARY-LONG.
 01 WS-MASK                BINARY-LONG.
 01 WS-MOD                 BINARY-LONG.
 01 WS-DEMAND              BINARY-LONG.
 01 WS-HERO                BINARY-LONG VALUE 31.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DUR                 BINARY-LONG VALUE 24000.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-IDS                 PIC X(1024).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-FOUND               BINARY-LONG.
 01 WS-PACKET-ID           BINARY-LONG VALUE 53.
 01 WS-SKIP                BINARY-LONG.
 01 WS-W-COUNT             BINARY-LONG.
 01 WS-W-SPECIAL           BINARY-LONG.
 01 WS-W-DEMAND            BINARY-LONG.
 01 WS-W-MULT              FLOAT-SHORT.
 01 WS-W-MILLI             BINARY-LONG.
 01 WS-EXPECT              BINARY-LONG.
 01 WS-ADJ                 BINARY-LONG.
 01 WS-PRICE               BINARY-LONG.
 01 WS-ITEM                PIC X(32).
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
     MOVE PL-X(WS-ROW) TO WS-X
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-VROW
     MOVE EN-ID(WS-VROW) TO WS-VID
     CALL "VL-FIND" USING WS-VID WS-ONE WS-SLOT
     MOVE "librarian" TO VL-PROF(WS-SLOT)
     CALL "VIL-TRADE-SET" USING WS-LIB WS-ONE WS-FIRST WS-N WS-PICK
     MOVE 1 TO VL-O-N(WS-SLOT) VL-BUILT(WS-SLOT)
     MOVE WS-FIRST TO VL-O-ROW(WS-SLOT, 1)
     CALL "VIL-TRADE-ROW" USING VL-O-ROW(WS-SLOT, 1) WS-WANT WS-WC WS-EXTRA WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
*>   A demand that raises the price by at least one (a price multiplier of 0 gives none: any demand).
     MOVE 5 TO WS-DEMAND
     IF WS-MULT > 0 AND WS-WC > 0
         COMPUTE WS-DEMAND = 1000 / (WS-WC * WS-MULT) + 1
     END-IF
     MOVE 0 TO VL-O-USES(WS-SLOT, 1) VL-O-SPECIAL(WS-SLOT, 1) VL-O-EXTRA(WS-SLOT, 1)
     MOVE WS-DEMAND TO VL-O-DEMAND(WS-SLOT, 1)
*>   The player has Hero of the Village I.
     CALL "EFFECT-ADD" USING WS-ROW WS-HERO WS-AMP WS-DUR WS-FLAGS
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "MERCHANT-INTERACT" USING WS-ROW WS-VROW WS-USED
     MOVE "N" TO TL-MODE
     MOVE "acceptance US15 40§2.1 the villager with an offer opens the window" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Merchant Offers (0x35): the first offer's cost A, result, optional cost B, out of stock, uses, max uses, xp, special price, multiplier, demand.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN-PACKET" USING WS-CONN WS-PACKET-ID PB-BUFFER WS-FOUND
     MOVE "acceptance US15 40§1.3 Merchant Offers is sent" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SKIP
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SKIP
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SKIP
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SKIP
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-W-COUNT
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-SKIP
     CALL "PB-GET-ITEM-STACK" USING PB-BUFFER PB-ITEMSTACK-X
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-SKIP
     IF WS-SKIP = 1
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-SKIP
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-SKIP
         CALL "PB-GET-VARINT" USING PB-BUFFER WS-SKIP
     END-IF
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-SKIP
     CALL "PB-GET-INT" USING PB-BUFFER WS-SKIP
     CALL "PB-GET-INT" USING PB-BUFFER WS-SKIP
     CALL "PB-GET-INT" USING PB-BUFFER WS-SKIP
     CALL "PB-GET-INT" USING PB-BUFFER WS-W-SPECIAL
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-W-MULT
     CALL "PB-GET-INT" USING PB-BUFFER WS-W-DEMAND
     CALL "PB-FREE" USING PB-BUFFER
     MOVE "acceptance US15 40§1.3 the wire carries the base first cost, not the price" TO TL-CASE
     MOVE WS-WC TO TL-EXPECTED-N
     MOVE WS-W-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-EXPECT = FUNCTION INTEGER(300 * WS-WC / 1000)
     IF WS-EXPECT < 1
         MOVE 1 TO WS-EXPECT
     END-IF
     COMPUTE WS-EXPECT = 0 - WS-EXPECT
     MOVE "acceptance US15 19§22.4 the wire carries the special price diff of Hero of the Village I" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-W-SPECIAL TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 40§1.3 the wire carries the offer's demand" TO TL-CASE
     MOVE WS-DEMAND TO TL-EXPECTED-N
     MOVE WS-W-DEMAND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-W-MILLI ROUNDED = WS-W-MULT * 1000
     MOVE "acceptance US15 40§1.3 the wire carries the offer's price multiplier" TO TL-CASE
     MOVE WS-MULT TO TL-EXPECTED-N
     MOVE WS-W-MILLI TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The price from the wire fields (40-5 2.4, integer arithmetic on the milli multiplier) is what the core charges.
     COMPUTE WS-ADJ = FUNCTION INTEGER(WS-W-COUNT * WS-W-DEMAND * WS-W-MILLI / 1000)
     COMPUTE WS-PRICE = WS-W-COUNT + FUNCTION MAX(0, WS-ADJ) + WS-W-SPECIAL
     MOVE FUNCTION MAX(1, FUNCTION MIN(WS-PRICE, 64)) TO WS-EXPECT
     CALL "VL-OFFER-COST" USING WS-SLOT WS-ONE WS-W-SPECIAL WS-ITEM WS-PRICE
     MOVE "acceptance US15 40§2.4 the core's price of the offer is the one the client computes from the wire fields" TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-PRICE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGDISCOUNT-OFFERS.
 COPY CORETEST.
