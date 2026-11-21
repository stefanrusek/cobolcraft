*> Acceptance test (wrap agent B, T59503; docs/protocol/40-menus-5-merchant-beacon-lectern.md 2.4, 19 section 22.4): the price of an offer is clamped to the maximum stack size of the cost
*> item, not to 64. An offer whose cost item is the lava bucket (maximum stack 1: armorer/3/lava_bucket_emerald, 19 section 22.4) with a demand that would raise 1 to 6 costs 1; an offer with
*> an emerald cost (maximum stack 64) and the same demand costs 6.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-OFFER-STACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY VILSTATE.
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
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-VID                 BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-LAVA-ROW            BINARY-LONG.
 01 WS-EMERALD-ROW         BINARY-LONG.
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
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ITEM                PIC X(32).
 01 WS-PRICE               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "1" TO CS-SEED-TEXT
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
*>   The rows of the trade table whose first cost is the lava bucket and the emerald (count 1)
     MOVE 0 TO WS-LAVA-ROW WS-EMERALD-ROW
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 397
         CALL "VIL-TRADE-ROW" USING WS-R WS-WANT WS-WC WS-EXTRA WS-EC WS-GIVE WS-GC WS-MU WS-XPV WS-MULT WS-MASK WS-MOD
         IF WS-LAVA-ROW = 0 AND WS-WANT = "lava_bucket" AND WS-WC = 1 AND WS-MULT = 50
             MOVE WS-R TO WS-LAVA-ROW
         END-IF
         IF WS-EMERALD-ROW = 0 AND WS-WANT = "emerald" AND WS-WC = 1 AND WS-MULT = 50
             MOVE WS-R TO WS-EMERALD-ROW
         END-IF
     END-PERFORM
     MOVE 1 TO VL-O-N(WS-SLOT) VL-BUILT(WS-SLOT)
     MOVE 0 TO VL-O-USES(WS-SLOT, 1) VL-O-SPECIAL(WS-SLOT, 1) VL-O-EXTRA(WS-SLOT, 1)
     MOVE 100 TO VL-O-DEMAND(WS-SLOT, 1)
     MOVE "N" TO TL-MODE
     MOVE WS-LAVA-ROW TO VL-O-ROW(WS-SLOT, 1)
     CALL "VL-OFFER-COST" USING WS-SLOT WS-ONE WS-ZERO WS-ITEM WS-PRICE
     MOVE "acceptance US15 40§2.4 the cost of an offer whose cost item is the lava bucket is clamped to its stack size 1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-PRICE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-EMERALD-ROW TO VL-O-ROW(WS-SLOT, 1)
     CALL "VL-OFFER-COST" USING WS-SLOT WS-ONE WS-ZERO WS-ITEM WS-PRICE
     MOVE "acceptance US15 40§2.4 the cost of an emerald offer with the same demand is 1 + floor(1 x 100 x 0.05) = 6" TO TL-CASE
     MOVE 6 TO TL-EXPECTED-N
     MOVE WS-PRICE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-WRAPB-OFFER-STACK.
 COPY CORETEST.
