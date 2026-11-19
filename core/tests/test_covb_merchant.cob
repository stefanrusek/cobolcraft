*> Implementation test (lane covB; docs/protocol/40-menus-5 section 2, 19 section 22.4): the merchant window with an offer that has two prices: Merchant Offers carries the second price, Select
*> Trade fills both payment slots (returning the old payments first, emptying the inventory stack it takes from), the result needs both payments, taking uses both and levels the villager up.
*> Also an out of stock mark, a wandering trader (no level bar), a merchant that is gone or has no state, an offer index out of range and a select with no window.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-MERCHANT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CMENU.
 COPY COREAPI.
 COPY VILSTATE.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-COW-T               BINARY-LONG.
 01 WS-VROW                BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-R                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
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
 01 WS-ITEM-A              BINARY-LONG.
 01 WS-ITEM-B              BINARY-LONG.
 01 WS-ITEM-R              BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-LEVEL0              BINARY-LONG.
 01 WS-GONE                BINARY-LONG VALUE 999999.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE "N" TO TL-MODE
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW-T WS-ENTITY-ROW WS-STATUS
     MOVE PL-X(WS-ROW) TO WS-X
     MOVE PL-Y(WS-ROW) TO WS-Y
     MOVE PL-Z(WS-ROW) TO WS-Z
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-VROW
     CALL "MOB-SPAWN" USING PL-DIM(WS-ROW) WS-COW-T WS-X WS-Y WS-Z WS-YAW WS-COW
     CALL "VL-FIND" USING EN-ID(WS-VROW) WS-ONE WS-SLOT
*>   An offer row with a second price (the first row of the trade table that has one).
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 397 OR WS-FOUND > 0
         CALL "VIL-TRADE-ROW" USING WS-R WS-WANT WS-WC WS-EXTRA WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
         IF WS-EC > 0
             MOVE WS-R TO WS-FOUND
         END-IF
     END-PERFORM
     MOVE "covB 19 22.4 the trade table has an offer with two prices" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VIL-TRADE-ROW" USING WS-FOUND WS-WANT WS-WC WS-EXTRA WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
     CALL "MERCHANT-ITEM-ID" USING WS-WANT WS-ITEM-A
     CALL "MERCHANT-ITEM-ID" USING WS-EXTRA WS-ITEM-B
     CALL "MERCHANT-ITEM-ID" USING WS-GIVE WS-ITEM-R
     MOVE "librarian" TO VL-PROF(WS-SLOT)
     MOVE 1 TO VL-O-N(WS-SLOT) VL-BUILT(WS-SLOT)
     MOVE WS-FOUND TO VL-O-ROW(WS-SLOT, 1)
     MOVE 0 TO VL-O-USES(WS-SLOT, 1) VL-O-DEMAND(WS-SLOT, 1) VL-O-SPECIAL(WS-SLOT, 1) VL-O-EXTRA(WS-SLOT, 1)
*>   The inventory holds exactly the first price and more than the second.
     MOVE WS-ITEM-A TO PL-SLOT-ITEM(WS-ROW, 10)
     MOVE WS-WC TO PL-SLOT-COUNT(WS-ROW, 10)
     MOVE WS-ITEM-B TO PL-SLOT-ITEM(WS-ROW, 11)
     COMPUTE PL-SLOT-COUNT(WS-ROW, 11) = WS-EC + 3
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
*>   The offer is marked out of stock in the window when its uses reached the maximum.
     MOVE 1000 TO VL-O-USES(WS-SLOT, 1)
     CALL "MERCHANT-INTERACT" USING WS-ROW WS-VROW WS-USED
     MOVE "covB 40-5 2.1 a villager with an out of stock offer with two prices opens the window" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO VL-O-USES(WS-SLOT, 1)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
*>   Select Trade fills both payment slots and empties the inventory stack of the first price.
     MOVE 0 TO WS-INDEX
     CALL "MERCHANT-SELECT" USING WS-CONN WS-INDEX
     MOVE "covB 40-5 2.7 Select Trade fills the second payment slot with the whole inventory stack (up to a full stack)" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-EC + 3
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 40-5 2.7 and takes the whole inventory stack of the first price" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SLOT-ITEM(WS-ROW, 10) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 40-5 2.4 with both payments the result is the offer's" TO TL-CASE
     MOVE WS-ITEM-R TO TL-EXPECTED-N
     MOVE MN-RESULT-ITEM(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Selecting again returns the payments to the inventory first and fills them again.
     CALL "MERCHANT-SELECT" USING WS-CONN WS-INDEX
     MOVE "covB 40-5 2.7 selecting again leaves both payments in place" TO TL-CASE
     COMPUTE TL-EXPECTED-N = WS-WC * 1000 + WS-EC + 3
     COMPUTE TL-OBSERVED-N = MN-WSLOT-COUNT(WS-ROW, 1) * 1000 + MN-WSLOT-COUNT(WS-ROW, 2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without the second payment there is no result.
     MOVE MN-WSLOT-COUNT(WS-ROW, 2) TO WS-GC
     MOVE 0 TO MN-WSLOT-COUNT(WS-ROW, 2)
     CALL "MERCHANT-UPDATE" USING WS-ROW
     MOVE "covB 40-5 2.4 a missing second payment gives no result" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MN-RESULT-COUNT(WS-ROW) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-GC TO MN-WSLOT-COUNT(WS-ROW, 2)
*>   Taking the result uses both payments and the villager levels up on reaching the xp.
     MOVE VL-LEVEL(WS-SLOT) TO WS-LEVEL0
     MOVE 9 TO VL-XP(WS-SLOT)
     CALL "MERCHANT-TAKEN" USING WS-ROW
     MOVE "covB 40-5 2.5 taking the result uses up the price of both payments (the 3 extra of the second stay)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = MN-WSLOT-COUNT(WS-ROW, 1) + MN-WSLOT-COUNT(WS-ROW, 2)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "covB 19 22.4 the villager has gone up a level" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF VL-LEVEL(WS-SLOT) > WS-LEVEL0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A wandering trader has no level bar: the offers are sent without it.
     MOVE VL-KIND(WS-SLOT) TO WS-GC
     MOVE 2 TO VL-KIND(WS-SLOT)
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "MERCHANT-OFFERS-SEND" USING WS-ROW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "covB 19 23 the offers of a wandering trader are sent (Merchant Offers 53)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-IDS(1:2) = "53"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-GC TO VL-KIND(WS-SLOT)
*>   A merchant that is gone, or has no state, sends nothing.
     MOVE MN-BENCH-X(WS-ROW) TO WS-ITEM-A
     MOVE WS-GONE TO MN-BENCH-X(WS-ROW)
     CALL "MERCHANT-OFFERS-SEND" USING WS-ROW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "covB 40-5 2 the offers of a merchant that is gone are not sent" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-IDS(1:2) TO TL-OBSERVED
     MOVE SPACES TO TL-OBSERVED(3:)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE EN-ID(WS-COW) TO MN-BENCH-X(WS-ROW)
     CALL "MERCHANT-OFFERS-SEND" USING WS-ROW
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "covB 40-5 2 nor those of an entity with no merchant state" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE WS-IDS(1:2) TO TL-OBSERVED
     MOVE SPACES TO TL-OBSERVED(3:)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MERCHANT-INTERACT" USING WS-ROW WS-COW WS-USED
     MOVE "covB 40-5 2 a cow is no merchant: the interaction opens nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-USED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The offer index out of the list: update and take do nothing.
     MOVE WS-ITEM-A TO MN-BENCH-X(WS-ROW)
     MOVE 77 TO MN-WDATA(WS-ROW, 1)
     MOVE 5 TO MN-WSLOT-COUNT(WS-ROW, 1)
     CALL "MERCHANT-TAKEN" USING WS-ROW
     MOVE "covB 40-5 2.5 taking with an offer that does not exist leaves the payment alone" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO MN-WDATA(WS-ROW, 1)
     MOVE 99 TO WS-INDEX
     CALL "MERCHANT-SELECT" USING WS-CONN WS-INDEX
     MOVE "covB 40-5 2.7 Select Trade with an index past the offers changes nothing" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Without a merchant window Select Trade does nothing.
     MOVE MN-WINDOW(WS-ROW) TO WS-GC
     MOVE 0 TO MN-WINDOW(WS-ROW)
     MOVE 0 TO WS-INDEX
     CALL "MERCHANT-SELECT" USING WS-CONN WS-INDEX
     MOVE "covB 40-5 2.7 Select Trade with no window open changes nothing" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE MN-WSLOT-COUNT(WS-ROW, 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-GC TO MN-WINDOW(WS-ROW)
     STOP RUN.
 END PROGRAM TEST-COVB-MERCHANT.
 COPY CORETEST.
 COPY BETEST.
