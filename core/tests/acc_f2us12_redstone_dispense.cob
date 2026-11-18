*> Acceptance test (T29070..T29090, US12-4; docs/protocol/30-redstone-4 sections 1.2 to 1.4, 2, 3.2 and 5.1): a dispenser or dropper beside power is triggered once per rising edge and
*> dispenses 4 ticks later: the dispenser drops an item (level events 1000 and 2000) or primes TNT, the dropper puts one item into the container in front or drops it, an empty one only
*> plays event 1001; a signal that reaches only the block above triggers it too (quasi-connectivity); a hopper beside power is disabled and enabled again when the power goes (5.1).
*> Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-DISPENSE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY PROJSTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-ST2                 BINARY-LONG.
 01 WS-PN                  PIC X(16).
 01 WS-PV                  PIC X(16).
 01 WS-OLD                 PIC X(16).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-EXP                 PIC X(160).
 01 WS-CASE                PIC X(240).
 01 WS-WIRE-BLOCK          BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-SIG                 BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-PX                  FLOAT-LONG.
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FKEY                PIC X(112).
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-FROW                BINARY-LONG.
 01 WS-FSLOT               BINARY-LONG.
 01 WS-FDIR                BINARY-LONG.
 01 WS-FKIND               BINARY-LONG.
 01 WS-K2                  PIC X(48).
 01 WS-P1N                 PIC X(16).
 01 WS-P1V                 PIC X(16).
 01 WS-P2N                 PIC X(16).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BE3                 BINARY-LONG.
 01 WS-TNT-TYPE            BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-KEY112              PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RULE-NAME           PIC X(40).
 01 WS-RULE-INDEX          BINARY-LONG.
 01 WS-RULE-VALUE          BINARY-DOUBLE.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-TNT-BEFORE          BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone dispense: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CB-BLOCK-COUNT
         IF CB-KEY(WS-ID) = "redstone_wire"
             COMPUTE WS-WIRE-BLOCK = WS-ID
         END-IF
     END-PERFORM
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 30
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 6
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             PERFORM PUT-DEF
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 103
                 MOVE "air" TO WS-K
                 PERFORM PUT-DEF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     PERFORM PLAYER-AWAY
     MOVE "minecraft:tnt" TO WS-KEY112
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY112 WS-TNT-TYPE WS-ENTITY-ROW WS-STATUS

     MOVE "stone" TO WS-K
     PERFORM FIND-ITEM

*>   A. a dispenser (z 0) facing east, the redstone block at x 2 on its west side
     MOVE 0 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "dispenser" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 5 TO BE-SLOT-COUNT(WS-BE, 1)
     PERFORM COUNT-LOOSE
     MOVE WS-COUNT TO WS-BEFORE
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-4 1.2 step 2 a dispenser beside power is triggered at once" TO WS-CASE
     MOVE "facing=east,triggered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 1.2 it has not dispensed 3 ticks later: 5 items left" TO WS-CASE
     MOVE "5" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 1.3 step 5 and 2.1 the tick 4 ticks after the trigger dispensed one item: 4 left" TO WS-CASE
     MOVE "4" TO WS-EXP
     PERFORM ASSERT-POWER
     PERFORM COUNT-LOOSE
     COMPUTE WS-P = WS-COUNT - WS-BEFORE
     MOVE "acceptance US12-4 live redstone 30-4 2 and the item is on the ground as an entity" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 20 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 1.2 a signal that stays on dispenses once only: 4 left" TO WS-CASE
     MOVE "4" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 2 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-4 1.2 step 3 the power gone: triggered is cleared" TO WS-CASE
     MOVE "facing=east,triggered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 1.2 the next rising edge dispenses again: 3 left" TO WS-CASE
     MOVE "3" TO WS-EXP
     PERFORM ASSERT-POWER

*>   B. a dispenser of TNT (z 2) primes it in front
     MOVE 2 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "dispenser" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE "tnt" TO WS-K
     PERFORM FIND-ITEM
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 3)
     MOVE 2 TO BE-SLOT-COUNT(WS-BE, 3)
     PERFORM COUNT-TNT
     MOVE WS-COUNT TO WS-TNT-BEFORE
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM COUNT-TNT
     COMPUTE WS-P = WS-COUNT - WS-TNT-BEFORE
     MOVE "acceptance US12-4 live redstone 30-4 4.14 a dispenser takes a TNT item and primes a TNT entity" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 4.14 and shrinks the stack: 1 left" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER

*>   C. an empty dispenser (z 4) only fails (event 1001): it stays triggered, nothing is dropped
     MOVE 4 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "dispenser" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     PERFORM COUNT-LOOSE
     MOVE WS-COUNT TO WS-BEFORE
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM COUNT-LOOSE
     COMPUTE WS-P = WS-COUNT - WS-BEFORE
     MOVE "acceptance US12-4 live redstone 30-4 1.3 step 3 an empty dispenser drops nothing" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER

*>   D. a dropper (z 6) facing east puts one item into the chest in front (x 4)
     MOVE 6 TO WS-Z
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "chest" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 3 TO WS-X MOVE "dropper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 3 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 1.4 step 6 a dropper moves one item into the container in front" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 1.4 step 6 and its own stack shrinks by one: 2 left" TO WS-CASE
     MOVE "2" TO WS-EXP
     PERFORM ASSERT-POWER

*>   E. a dropper (z 8) with nothing in front drops the item (event 1000 and an entity)
     MOVE 8 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "dropper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     PERFORM COUNT-LOOSE
     MOVE WS-COUNT TO WS-BEFORE
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM COUNT-LOOSE
     COMPUTE WS-P = WS-COUNT - WS-BEFORE
     MOVE "acceptance US12-4 live redstone 30-4 1.4 step 5 a dropper with no container in front drops the item as an entity" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 1.4 step 5 and its stack shrinks: 1 left" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER

*>   F. quasi-connectivity (z 10): the redstone block at x 3, y 102 powers the cell above the dispenser, not the dispenser
     MOVE 10 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "dispenser" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 4 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-4 1.2 a source diagonal to the dispenser sends it no update: not triggered yet" TO WS-CASE
     MOVE "facing=east,triggered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 3 TO WS-X MOVE 102 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-4 1.2 step 1 the next update (a block placed above it) finds the cell above powered by the source beside it: triggered" TO WS-CASE
     MOVE "facing=east,triggered=true" TO WS-EXP
     PERFORM ASSERT-PROPS

*>   G. hopper (z 12): disabled beside power, enabled again after it
     MOVE 12 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "hopper" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-4 5.1 a hopper beside power is disabled" TO WS-CASE
     MOVE "enabled=false,facing=down" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 2 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-4 5.1 the power gone: it is enabled again" TO WS-CASE
     MOVE "enabled=true,facing=down" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 14 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X MOVE "hopper" TO WS-K PERFORM PUT-DEF
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-4 5.1 a hopper placed beside power is disabled by its onPlace" TO WS-CASE
     MOVE "enabled=false,facing=down" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   H. a dropper (z 16) into a chest that already holds the item stacks it; the last item of the dropper empties its slot
     MOVE 16 TO WS-Z
     MOVE "stone" TO WS-K
     PERFORM FIND-ITEM
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "chest" TO WS-K PERFORM PUT-DEF
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE2, 1)
     MOVE 5 TO BE-SLOT-COUNT(WS-BE2, 1)
     MOVE 3 TO WS-X MOVE "dropper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 1.4 step 6 an item that matches a stack of the container joins it: 6" TO WS-CASE
     MOVE "6" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 1.4 the dropper's last item leaves its slot empty: 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
*>   I. a dropper without an entity does nothing (z 18)
     MOVE 18 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "dropper" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 0 TO BE-USED(WS-BE)
     PERFORM COUNT-LOOSE
     MOVE WS-COUNT TO WS-BEFORE
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM COUNT-LOOSE
     COMPUTE WS-P = WS-COUNT - WS-BEFORE
     MOVE "acceptance US12-4 live redstone 30-4 1.4 step 1 a dropper whose block entity is missing dispenses nothing" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
*>   J. the last TNT of a dispenser with the rule tnt_explodes off: event 1001, the item stays (z 20)
     MOVE 20 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "dispenser" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE "tnt" TO WS-K
     PERFORM FIND-ITEM
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE "tnt_explodes" TO WS-RULE-NAME
     CALL "BR-RULE-FIND" USING WS-RULE-NAME WS-RULE-INDEX
     MOVE 0 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     PERFORM COUNT-TNT
     MOVE WS-COUNT TO WS-TNT-BEFORE
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-RULE-VALUE
     CALL "BR-RULE-SET" USING WS-RULE-INDEX WS-RULE-VALUE
     PERFORM COUNT-TNT
     COMPUTE WS-P = WS-COUNT - WS-TNT-BEFORE
     MOVE "acceptance US12-4 live redstone 30-4 4.14 with tnt_explodes off no TNT is primed" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 4.14 and the TNT item stays in the dispenser: 1" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   K. the last item of a dispenser empties its slot (z 22)
     MOVE 22 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "dispenser" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE "stone" TO WS-K
     PERFORM FIND-ITEM
     MOVE WS-ITEM TO BE-SLOT-ITEM(WS-BE, 1)
     MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-P
     MOVE "acceptance US12-4 live redstone 30-4 1.3 the last item dispensed leaves the slot empty: 0" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     STOP RUN.

 COUNT-LOOSE.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.

 COUNT-TNT.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TNT-TYPE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.

 MAKE-DEF.
*>   the default state of the block of key WS-K into WS-ST
     MOVE SPACES TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST.

 PUT-DEF.
*>   the default state of the block of key WS-K at (WS-X, WS-Y, WS-Z) into WS-ST and the world
     PERFORM MAKE-DEF
     PERFORM PUT-ST.

 SET-P.
*>   property WS-PN of WS-ST set to WS-PV
     CALL "SW-SET-PROP" USING WS-ST WS-PN WS-PV WS-ST2 WS-OLD
     MOVE WS-ST2 TO WS-ST.

 PUT-ST.
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 PLAYER-AWAY.
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 104.0 TO PL-Y(WS-ROW)
     MOVE 28.5 TO PL-Z(WS-ROW).

 PLAYER-ON-PLATE.
*>   the player stands on the plate of row WS-Z at x 3 (feet at the floor of the cell)
     MOVE 3.5 TO PL-X(WS-ROW)
     MOVE 101.0 TO PL-Y(WS-ROW)
     COMPUTE WS-PX = WS-Z + 0.5
     MOVE WS-PX TO PL-Z(WS-ROW).

 READ-PROPS.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS.

 READ-WIRE.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-N WS-E WS-S WS-W WS-P
     IF CB-S-BLOCK(WS-STATE + 1) = WS-WIRE-BLOCK - 1
         COMPUTE WS-ID = WS-STATE - CB-FIRST-STATE(WS-WIRE-BLOCK) + 5567
         CALL "RS1-WIRE-DECODE" USING WS-ID WS-N WS-E WS-S WS-W WS-P
     ELSE
         MOVE -1 TO WS-P
     END-IF.

 READ-SIGNAL.
*>   level.getSignal at (WS-X, WS-Y, WS-Z) asked with direction WS-D
     CALL "RL-SIGNAL" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-SIG
     MOVE WS-SIG TO WS-P.

 ASSERT-POWER.
     MOVE WS-P TO WS-ED
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-SIGNAL.
     PERFORM ASSERT-POWER.

 ASSERT-PROPS.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM ACC-F2US12-REDSTONE-DISPENSE.

 COPY CORETEST.
 COPY PORTALTEST.
