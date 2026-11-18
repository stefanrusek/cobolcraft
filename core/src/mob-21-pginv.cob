*> The piglin inventory (docs/protocol/44-residual-mob-questions-6-nether.md sections 3.2 step 5, 3.4 step 2, 7 and 10; lane 002-lane-p49l, T25004; state PG-INV of core/copy/PGBRAIN.cpy):
*> 8 slots of an item id and a count, 64 at most per slot (every item stacks to 64 here: the stack size table is not consulted, open). A gold nugget stack picked up goes in when it
*> fits (canAddToInventory); the whole inventory is dropped as items when the piglin converts (section 7) or dies (section 10, Piglin.dropCustomDeathLoot); a loved item that is not
*> currency and was held in the off hand goes in when the admiring ends or the piglin is hurt (stopHoldingOffHandItem without a barter).
*>   PGB-INV-ADD USING row, item, count, left out      puts the stack in: first the slots of the same item, then empty ones; left is what did not fit
*>   PGB-INV-COUNT USING row, item, count out          the number of that item in the inventory
*>   PGB-INV-FITS USING row, item, count, fits out     canAddToInventory
*>   PGB-INV-DROP USING row                            every stack on the ground at the piglin (one block up, as an item entity); the inventory is empty
*>   PIGLIN-DROP-INVENTORY USING row                   the death drop of a piglin (nothing for any other mob)
*>   PGB-OFFHAND-STOP USING row, kept out              the off-hand item of an admiring piglin put away (not bartered): a currency is lost, any other item goes in the inventory
*>                                                     (dropped when it does not fit); kept is 1 when an item went in

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-INV-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-YES                 BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 01 WS-PUT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-LEFT.
     MOVE L-COUNT TO L-LEFT
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-YES WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8 OR L-LEFT = 0
         IF PG-INV-COUNT(WS-SLOT, WS-I) > 0 AND PG-INV-ITEM(WS-SLOT, WS-I) = L-ITEM
             COMPUTE WS-ROOM = 64 - PG-INV-COUNT(WS-SLOT, WS-I)
             COMPUTE WS-PUT = FUNCTION MIN(WS-ROOM, L-LEFT)
             ADD WS-PUT TO PG-INV-COUNT(WS-SLOT, WS-I)
             SUBTRACT WS-PUT FROM L-LEFT
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8 OR L-LEFT = 0
         IF PG-INV-COUNT(WS-SLOT, WS-I) = 0
             MOVE L-ITEM TO PG-INV-ITEM(WS-SLOT, WS-I)
             COMPUTE WS-PUT = FUNCTION MIN(64, L-LEFT)
             MOVE WS-PUT TO PG-INV-COUNT(WS-SLOT, WS-I)
             SUBTRACT WS-PUT FROM L-LEFT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PGB-INV-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-INV-COUNT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT.
     MOVE 0 TO L-COUNT
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
             IF PG-INV-COUNT(WS-SLOT, WS-I) > 0 AND PG-INV-ITEM(WS-SLOT, WS-I) = L-ITEM
                 ADD PG-INV-COUNT(WS-SLOT, WS-I) TO L-COUNT
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PGB-INV-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-INV-FITS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-ROOM                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-FITS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM L-COUNT L-FITS.
     MOVE 0 TO L-FITS WS-ROOM
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0
         MOVE 64 TO WS-ROOM
     ELSE
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
             IF PG-INV-COUNT(WS-SLOT, WS-I) = 0
                 ADD 64 TO WS-ROOM
             END-IF
             IF PG-INV-COUNT(WS-SLOT, WS-I) > 0 AND PG-INV-ITEM(WS-SLOT, WS-I) = L-ITEM
                 COMPUTE WS-ROOM = WS-ROOM + 64 - PG-INV-COUNT(WS-SLOT, WS-I)
             END-IF
         END-PERFORM
     END-IF
     IF WS-ROOM >= L-COUNT
         MOVE 1 TO L-FITS
     END-IF
     GOBACK.
 END PROGRAM PGB-INV-FITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-INV-DROP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-DROP                BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     MOVE EN-X(L-ROW) TO WS-X
     COMPUTE WS-Y = EN-Y(L-ROW) + 1
     MOVE EN-Z(L-ROW) TO WS-Z
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         IF PG-INV-COUNT(WS-SLOT, WS-I) > 0
             MOVE PG-INV-ITEM(WS-SLOT, WS-I) TO WS-ITEM
             MOVE PG-INV-COUNT(WS-SLOT, WS-I) TO WS-COUNT
             MOVE 0 TO PG-INV-COUNT(WS-SLOT, WS-I)
             CALL "GI-SPAWN-RANDOM" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-ITEM WS-COUNT WS-ZERO WS-DELAY WS-DROP
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PGB-INV-DROP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PIGLIN-DROP-INVENTORY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PGAI-KIND" USING L-ROW WS-KIND
     IF WS-KIND = 1
         CALL "PGB-INV-DROP" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM PIGLIN-DROP-INVENTORY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-OFFHAND-STOP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-LEFT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-DELAY               BINARY-LONG VALUE 10.
 01 WS-DROP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KEPT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KEPT.
     MOVE 0 TO L-KEPT
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT = 0
         GOBACK
     END-IF
     IF PG-OFFHAND(WS-SLOT) > 0
         COMPUTE WS-ITEM = PG-OFFHAND(WS-SLOT) - 1
         MOVE 0 TO PG-OFFHAND(WS-SLOT)
         CALL "PGB-INV-ADD" USING L-ROW WS-ITEM WS-ONE WS-LEFT
         MOVE 1 TO L-KEPT
         IF WS-LEFT > 0
             MOVE 0 TO L-KEPT
             MOVE EN-X(L-ROW) TO WS-X
             COMPUTE WS-Y = EN-Y(L-ROW) + 1
             MOVE EN-Z(L-ROW) TO WS-Z
             CALL "GI-SPAWN-RANDOM" USING EN-DIM(L-ROW) WS-X WS-Y WS-Z WS-ITEM WS-LEFT WS-ZERO WS-DELAY WS-DROP
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGB-OFFHAND-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PGB-OFFHAND-ITEM.
*> USING row, item (BINARY-LONG, in out): the item the off hand holds when the piglin converts while admiring (cancelAdmiring): the loved item that was picked up when there is one
*> (and the off hand is emptied), else the item given in (the gold ingot a player handed over).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PGBRAIN.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ITEM.
     CALL "PGB-SLOT" USING EN-ID(L-ROW) WS-NO WS-SLOT
     IF WS-SLOT > 0
         IF PG-OFFHAND(WS-SLOT) > 0
             COMPUTE L-ITEM = PG-OFFHAND(WS-SLOT) - 1
             MOVE 0 TO PG-OFFHAND(WS-SLOT)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PGB-OFFHAND-ITEM.
