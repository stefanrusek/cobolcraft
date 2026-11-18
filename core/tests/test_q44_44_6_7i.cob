*> The piglin inventory (docs/protocol/44-residual-mob-questions-6-nether.md sections 3.2 step 5, 3.4, 7 and 10; lane 002-lane-p49l, T25004): a gold nugget stack goes into the 8-slot
*> inventory when it fits, the inventory is dropped whole when the piglin converts and when it dies, and a loved item that is not currency goes into it when the admiring ends or the
*> piglin is hurt (stopHoldingOffHandItem without a barter).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-7I.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CITEMS.
 COPY BRWORLD.
 COPY RULES.
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
 01 WS-NUGGET              BINARY-LONG.
 01 WS-STICK               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INGOT               BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-K24                 PIC X(24).
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-C5                  BINARY-LONG VALUE 5.
 01 WS-C64                 BINARY-LONG VALUE 64.
 01 WS-C3                  BINARY-LONG VALUE 3.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
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
     MOVE "gold_nugget" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-NUGGET
     MOVE "stick" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-STICK
     MOVE "gold_block" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-BLOCK
     MOVE "gold_ingot" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-INGOT
*>   Section 3.2 step 2 and 5: the whole nugget stack is taken into the inventory; stacks of one kind fill up to 64 before they use another slot.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-NUGGET WS-C5 WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     CALL "PGB-INV-COUNT" USING WS-A WS-NUGGET WS-N
     MOVE "acceptance US15 44-6§3.2 a stack of 5 nuggets goes into the inventory" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§3.2 and the item entity is gone" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-USED(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-NUGGET WS-C64 WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     CALL "PGB-INV-COUNT" USING WS-A WS-NUGGET WS-N
     MOVE "acceptance US15 44-6§3.2 5 + 64 nuggets are 69 in two slots" TO TL-CASE
     MOVE 69 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   canAddToInventory: with all 8 slots held by other items and no room in a nugget slot, the nuggets stay on the ground.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE WS-ITEM = WS-STICK + WS-I - 1
         CALL "PGB-INV-ADD" USING WS-A WS-ITEM WS-C64 WS-LEFT
     END-PERFORM
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-NUGGET WS-C5 WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     MOVE "acceptance US15 44-6§3.2 step 5 a full inventory: the nuggets stay where they lie" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE EN-USED(WS-DROP) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 7: the conversion drops the whole inventory as items.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     CALL "PGB-INV-ADD" USING WS-A WS-NUGGET WS-C5 WS-LEFT
     CALL "PGB-INV-ADD" USING WS-A WS-STICK WS-C3 WS-LEFT
     MOVE 300 TO EN-ZOMBIFY(WS-A)
     CALL "PIGLIN-ZOMBIFY" USING WS-A WS-DONE
     MOVE "acceptance US15 44-6§7 the 301st step converts" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-SUM
     MOVE 0 TO WS-N
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-HEALTH(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD EN-ITEM-COUNT(WS-I) TO WS-SUM
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-6§7 conversion drops the whole inventory: 8 items" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-SUM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§7 as two item entities" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 10: the death of a piglin drops its inventory.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     CALL "PGB-INV-ADD" USING WS-A WS-NUGGET WS-C5 WS-LEFT
     CALL "STDMOB-DIE" USING WS-A
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0
             ADD EN-ITEM-COUNT(WS-I) TO WS-SUM
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-6§10 a dying piglin drops its inventory" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-SUM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-INV-COUNT" USING WS-A WS-NUGGET WS-N
     MOVE "acceptance US15 44-6§10 and the inventory is empty" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Section 3.4 step 2: a loved item that is not currency goes into the inventory when the admiring ends; the gold ingot barters instead.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-BLOCK WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     MOVE "acceptance US15 44-6§3.2 step 3 a gold block is held and admired" TO TL-CASE
     MOVE 119 TO TL-EXPECTED-N
     MOVE EN-ADMIRE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM 119 TIMES
         CALL "PIGLIN-TICK" USING WS-A
     END-PERFORM
     CALL "PGB-INV-COUNT" USING WS-A WS-BLOCK WS-N
     MOVE "acceptance US15 44-6§3.4 the admired gold block ends up in the inventory" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hurt while admiring: a loved non-currency item is kept in the inventory, an ingot is lost (step 2).
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-BLOCK WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     CALL "PIGLIN-HURT" USING WS-A WS-ONE
     CALL "PGB-INV-COUNT" USING WS-A WS-BLOCK WS-N
     MOVE "acceptance US15 44-6§3.4 hurt while admiring a gold block: it is put in the inventory" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-INGOT WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     CALL "PIGLIN-HURT" USING WS-A WS-ONE
     CALL "PGB-INV-COUNT" USING WS-A WS-INGOT WS-N
     MOVE "acceptance US15 44-6§3.4 hurt while admiring an ingot: it is lost" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Hurt by a mob (attacker 0) while admiring: the admiring ends, ADMIRING_DISABLED is not set (only a player sets it, 2.3 step 4).
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     MOVE 50 TO EN-ADMIRE(WS-A)
     MOVE 1 TO EN-ADMIRE-CUR(WS-A)
     MOVE 0 TO EN-HURT(WS-A)
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-ONE CAUSE-MOB WS-ZERO
     MOVE "acceptance US15 44-6§2.3 step 4 a hit by no player ends the admiring" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-ADMIRE(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§2.3 step 4 and does not disable it" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-ADMIRE-OFF(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The conversion while admiring a gold block drops that block (cancelAdmiring) and the inventory.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-BLOCK WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     MOVE 300 TO EN-ZOMBIFY(WS-A)
     CALL "PIGLIN-ZOMBIFY" USING WS-A WS-DONE
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-HEALTH(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0 AND EN-ITEM(WS-I) = WS-BLOCK
             ADD EN-ITEM-COUNT(WS-I) TO WS-SUM
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-6§3.4 converting while admiring a gold block drops it" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SUM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   An off-hand item that does not fit in a full inventory is dropped (kept = 0).
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         COMPUTE WS-ITEM = WS-STICK + WS-I - 1
         CALL "PGB-INV-ADD" USING WS-A WS-ITEM WS-C64 WS-LEFT
     END-PERFORM
     CALL "GI-SPAWN-RANDOM" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-BLOCK WS-ONE WS-ZERO WS-DELAY WS-DROP
     CALL "PIGLIN-PICKUP" USING WS-A
     CALL "PIGLIN-HURT" USING WS-A WS-ONE
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-HEALTH(WS-I) = 0 AND EN-ITEM-COUNT(WS-I) > 0 AND EN-ITEM(WS-I) = WS-BLOCK
             ADD EN-ITEM-COUNT(WS-I) TO WS-SUM
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-6§3.4 hurt while admiring with a full inventory: the gold block is dropped" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-SUM TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   With every slot of the brain table taken a piglin has no inventory: nothing fits through the store, and the programs answer without it.
     CALL "T-CLEAR"
     MOVE "piglin" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PG-MAX
         COMPUTE PG-ID(WS-I) = 900000 + WS-I
     END-PERFORM
     CALL "PGB-INV-ADD" USING WS-A WS-NUGGET WS-C5 WS-LEFT
     MOVE "acceptance US15 44-6§3.2 no brain slot free: the stack is not stored" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-LEFT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-INV-FITS" USING WS-A WS-NUGGET WS-C5 WS-DONE
     MOVE "acceptance US15 44-6§3.2 canAddToInventory with no slot: an empty inventory fits it" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-INV-DROP" USING WS-A
     CALL "PGB-OFFHAND-STOP" USING WS-A WS-DONE
     MOVE "acceptance US15 44-6§3.4 nothing kept with no slot" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE WS-DONE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PGB-OFFHAND-ITEM" USING WS-A WS-ITEM
     CALL "PIGLIN-DROP-INVENTORY" USING WS-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PG-MAX
         MOVE 0 TO PG-ID(WS-I)
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-7I.

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
