*> Implementation test (lane 002-lane-p49s, T38520 to T38530; docs/protocol/44-residual-mob-questions-6-nether.md section 3.2 steps 2 and 6, 3.4 step 2, 44-1 RQ-1.3): the item tag
*> piglin_repellents is never picked up; canReplaceCurrentItem decides whether a piglin takes anything else (preferred weapons, the attack damage, the empty hand), the main hand holds
*> what it took, the old item is dropped with the probability of the drop chance, and an admired loved item that is no currency is equipped when it replaces the main hand.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-PICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CITEMS.
 COPY BRWORLD.
 COPY PGBRAIN.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-K24                 PIC X(24).
 01 WS-KEY40               PIC X(40).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-YES                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TORCH               BINARY-LONG.
 01 WS-LANTERN             BINARY-LONG.
 01 WS-CAMPFIRE            BINARY-LONG.
 01 WS-DSWORD              BINARY-LONG.
 01 WS-ISWORD              BINARY-LONG.
 01 WS-GSWORD              BINARY-LONG.
 01 WS-XBOW                BINARY-LONG.
 01 WS-GSPEAR              BINARY-LONG.
 01 WS-HELMET              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-ROCK                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) - 20
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ 40 WS-BY 1
     MOVE 1000 TO CW-TICKS
     MOVE "soul_torch" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-TORCH
     MOVE "soul_lantern" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-LANTERN
     MOVE "soul_campfire" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-CAMPFIRE
     MOVE "diamond_sword" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-DSWORD
     MOVE "iron_sword" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-ISWORD
     MOVE "golden_sword" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-GSWORD
     MOVE "crossbow" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-XBOW
     MOVE "golden_spear" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-GSPEAR
     MOVE "iron_helmet" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-HELMET
     MOVE "gold_block" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BLOCK
     MOVE "cobblestone" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-ROCK

*>   Step 2: the three items of the tag piglin_repellents stay on the ground.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-TORCH WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     MOVE "acceptance US15 44-6§3.2 step 2 a soul torch is not picked up" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-LANTERN WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     MOVE "acceptance US15 44-6§3.2 step 2 a soul lantern is not picked up" TO TL-CASE
     MOVE EN-USED(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-CAMPFIRE WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     MOVE "acceptance US15 44-6§3.2 step 2 a soul campfire is not picked up" TO TL-CASE
     MOVE EN-USED(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§3.2 step 2 and the hand stays empty" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-HAND(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Step 6: an empty hand takes any item (one of a stack of two), the entity keeps the other.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-ROCK WS-TWO WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     MOVE "acceptance US15 44-6§3.2 step 6 an empty hand takes cobblestone into the main hand" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1000 + WS-ROCK
     MOVE EN-HAND(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§3.2 step 6 one of the two is taken" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-ITEM-COUNT(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "STDMOB-HAND-KEY" USING EN-HAND(WS-A) WS-KEY40
     MOVE "acceptance US15 44-6§3.2 step 6 the held item key is the one picked up" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-KEY40 = "minecraft:cobblestone"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Armour has no model on a piglin: an iron helmet stays.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-HELMET WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     MOVE "acceptance US15 44-6§3.2 an iron helmet is left on the ground (no armour model)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-USED(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The decision table of canReplaceCurrentItem (the main hand; EN-HAND 1000 + id, 13 a crossbow, 11 a golden sword, 0 empty).
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     COMPUTE EN-HAND(WS-A) = 1000 + WS-ISWORD
     CALL "PGW-CAN-REPLACE" USING WS-A WS-DSWORD WS-YES
     MOVE "acceptance US15 44-6 RQ-1.3 a diamond sword replaces an iron sword (more damage)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-HAND(WS-A) = 1000 + WS-DSWORD
     CALL "PGW-CAN-REPLACE" USING WS-A WS-ISWORD WS-YES
     MOVE "acceptance US15 44-6 RQ-1.3 an iron sword does not replace a diamond sword" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-HAND(WS-A) = 1000 + WS-DSWORD
     CALL "PGW-CAN-REPLACE" USING WS-A WS-DSWORD WS-YES
     MOVE "acceptance US15 44-6 RQ-1.3 an equal item does not replace (the tie-break says no)" TO TL-CASE
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE EN-HAND(WS-A) = 1000 + WS-DSWORD
     CALL "PGW-CAN-REPLACE" USING WS-A WS-XBOW WS-YES
     MOVE "acceptance US15 44-6 3.2 step 6c a crossbow (preferred) replaces a diamond sword" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13 TO EN-HAND(WS-A)
     CALL "PGW-CAN-REPLACE" USING WS-A WS-DSWORD WS-YES
     MOVE "acceptance US15 44-6 3.2 step 6c a diamond sword does not replace a crossbow" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO EN-HAND(WS-A)
     CALL "PGW-CAN-REPLACE" USING WS-A WS-DSWORD WS-YES
     MOVE "acceptance US15 44-6 3.2 step 6c a loved golden sword in hand is kept against a diamond sword" TO TL-CASE
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13 TO EN-HAND(WS-A)
     CALL "PGW-CAN-REPLACE" USING WS-A WS-GSPEAR WS-YES
     MOVE "acceptance US15 44-6 RQ-1.3 a golden spear against a crossbow: both preferred, equal damage modifier, no" TO TL-CASE
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO EN-HAND(WS-A)
     CALL "PGW-CAN-REPLACE" USING WS-A WS-XBOW WS-YES
     MOVE "acceptance US15 44-6 RQ-1.3 a crossbow against a golden spear: both preferred and in the tag, no" TO TL-CASE
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO EN-HAND(WS-A)
     CALL "PGW-CAN-REPLACE" USING WS-A WS-GSPEAR WS-YES
     MOVE "acceptance US15 44-6 RQ-1.3 a golden spear against a golden sword: the tag member wins" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 12 TO EN-HAND(WS-A)
     CALL "PGW-CAN-REPLACE" USING WS-A WS-GSWORD WS-YES
     MOVE "acceptance US15 44-6 RQ-1.3 a golden sword against a golden spear: the tag member stays" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A baby has no preferred weapon type: only loved items are preferred.
     MOVE -24000 TO EN-MOBAGE(WS-A)
     MOVE 0 TO EN-HAND(WS-A)
     COMPUTE EN-HAND(WS-A) = 1000 + WS-ISWORD
     CALL "PGW-CAN-REPLACE" USING WS-A WS-XBOW WS-YES
     MOVE "acceptance US15 44-6 RQ-1.3 a baby: a crossbow is no preferred weapon, the damage decides (no)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGW-CAN-REPLACE" USING WS-A WS-GSWORD WS-YES
     MOVE "acceptance US15 44-6 RQ-1.3 a baby: a loved golden sword is preferred and replaces an iron sword" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-YES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Through the pick-up: a crossbow lying near a piglin holding an iron sword is taken, and the old sword is lost or dropped (the drop chance 0.085 with max(nextFloat - 0.1, 0): about 18.5 per cent of 200 repeats).
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         COMPUTE EN-HAND(WS-A) = 1000 + WS-ISWORD
         CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-DSWORD WS-ONE WS-ZERO WS-DELAY WS-DROP
         CALL "PIGLIN-PICKUP" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-6§3.2 step 6 the better sword is held after 200 pick-ups" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1000 + WS-DSWORD
     MOVE EN-HAND(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-ISWORD
             ADD EN-ITEM-COUNT(WS-I) TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-6§3.2 step 6 about 18.5 per cent of the replaced swords are dropped (20 to 60 of 200)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-N >= 20 AND WS-N <= 60
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Step 3.4 step 2: a loved item that is no currency (a golden sword) is equipped when its admiring ends (the main hand is empty); a gold block goes into the inventory when the hand holds a crossbow.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-GSWORD WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     MOVE "acceptance US15 44-6§3.2 step 3 a golden sword is held in the off hand and admired" TO TL-CASE
     MOVE 119 TO TL-EXPECTED-N
     MOVE EN-ADMIRE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 119 TIMES
         CALL "PIGLIN-TICK" USING WS-A
     END-PERFORM
     MOVE "acceptance US15 44-6§3.4 step 2 the admired golden sword is equipped in the empty main hand" TO TL-CASE
     COMPUTE TL-EXPECTED-N = 1000 + WS-GSWORD
     MOVE EN-HAND(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-INV-COUNT" USING WS-A WS-GSWORD WS-N
     MOVE "acceptance US15 44-6§3.4 step 2 and not put in the inventory" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 13 TO EN-HAND(WS-A)
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-BLOCK WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     PERFORM 119 TIMES
         CALL "PIGLIN-TICK" USING WS-A
     END-PERFORM
     CALL "PGB-INV-COUNT" USING WS-A WS-BLOCK WS-N
     MOVE "acceptance US15 44-6§3.4 step 2 with a crossbow in hand the gold block goes into the inventory" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§3.4 step 2 and the crossbow stays in hand" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE EN-HAND(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PG-MAX
         MOVE 0 TO PG-ID(WS-I)
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-PICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM T-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE L-KEY DELIMITED BY SPACE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     GOBACK.
 END PROGRAM T-SPAWN.

 COPY CORETEST.
 COPY MOBSPTEST.
 COPY BETEST.
