*> Live redstone, dispensers, droppers and hoppers (docs/protocol/30-redstone-4 sections 1, 2 and 5.1): the trigger of a dispenser or dropper on a neighbour change (power at the block or at the
*> block above, one dispense per rising edge, 4 ticks later), the dispense of the scheduled tick (a random non-empty slot; the dropper puts one item into the container in front or drops it,
*> the dispenser drops it or, for TNT, primes it; level events 1000, 1001 and 2000), and the hopper's `enabled` property follows its signal.
*> The dropper puts into a furnace, smoker, blast furnace or brewing stand through the slots of its face (HOPPER-ADD-ONE, redstone-live-k.cob).
*> Deviations: the slot is drawn as nextInt(n) is, with the level's double (the same distribution, not the same sequence); the registered behaviours of 30-4 section 4 other than TNT are in
*> redstone-live-j.cob (flint and steel, bone meal, buckets, spawn eggs, minecarts); the others are not wired: such an item is dropped like any other; the container in front of a dropper is a block entity container (a minecart or a horse is not looked for); the
*> game event block_activate of an empty dispenser is not sent. The hopper's transfer of items (31-2 section 5) is not part of this core: only its enabled state is.
*> Entry points:
*>   RL-DISP-HOOK USING kind, dimension row, x, y, z, state    kinds 3 neighborChanged and 7 scheduled tick of a dispenser (class 29) or a dropper (class 30)
*>   RL-HOPPER-HOOK USING kind, dimension row, x, y, z, state, old state    kinds 1 onPlace and 3 neighborChanged of a hopper (checkPoweredState)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-INSERT-ONE.
*> USING block entity index, item, variant, left out (0 when one item went in): HopperBlockEntity.addItem of a single item into the container of the entity (31-2 5.6): the first slot in order that is
*> empty or holds the same stack with room takes it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BESTATE.
 COPY CITEMS.
 01 WS-SIZE                BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-INDEX                BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-VAR                  BINARY-LONG.
 01 L-LEFT                 BINARY-LONG.
 PROCEDURE DIVISION USING L-INDEX L-ITEM L-VAR L-LEFT.
     MOVE 1 TO L-LEFT
     CALL "BE-CONTAINER-SIZE" USING BE-TYPE(L-INDEX) WS-SIZE
     CALL "BE-MAX-STACK" USING IT-MAX-STACK(L-ITEM + 1) WS-LIMIT
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > WS-SIZE OR L-LEFT = 0
         EVALUATE TRUE
             WHEN BE-SLOT-COUNT(L-INDEX, WS-S) = 0
                 MOVE L-ITEM TO BE-SLOT-ITEM(L-INDEX, WS-S)
                 MOVE L-VAR TO BE-SLOT-VAR(L-INDEX, WS-S)
                 MOVE 1 TO BE-SLOT-COUNT(L-INDEX, WS-S)
                 MOVE 0 TO L-LEFT
             WHEN BE-SLOT-ITEM(L-INDEX, WS-S) = L-ITEM AND BE-SLOT-VAR(L-INDEX, WS-S) = L-VAR
                     AND BE-SLOT-COUNT(L-INDEX, WS-S) < WS-LIMIT
                 ADD 1 TO BE-SLOT-COUNT(L-INDEX, WS-S)
                 MOVE 0 TO L-LEFT
         END-EVALUATE
     END-PERFORM
     IF L-LEFT = 0
         CALL "BE-MARK-CHUNK" USING L-INDEX
     END-IF
     GOBACK.
 END PROGRAM RL-INSERT-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-DISP-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 COPY RSLIVE.
 01 WS-TRIGGERED           PIC X(16) VALUE "triggered".
 LOCAL-STORAGE SECTION.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-CLASS               BINARY-LONG.
 01 LS-F                   BINARY-LONG.
 01 LS-FACE                BINARY-LONG.
 01 LS-HERE                BINARY-LONG.
 01 LS-ABOVE               BINARY-LONG.
 01 LS-QY                  BINARY-LONG.
 01 LS-POWERED             BINARY-LONG.
 01 LS-TRIG                BINARY-LONG.
 01 LS-SCHEDULE            BINARY-LONG.
 01 LS-DELAY               BINARY-LONG.
 01 LS-NEW-TRIG            BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-ACTION              BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-PRIO                BINARY-LONG VALUE 0.
 01 LS-INDEX               BINARY-LONG.
 01 LS-INDEX2              BINARY-LONG.
 01 LS-S                   BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-CHOICE              BINARY-LONG.
 01 LS-DRAW                FLOAT-LONG.
 01 LS-PICK                BINARY-LONG.
 01 LS-ITEM                BINARY-LONG.
 01 LS-VAR                 BINARY-LONG.
 01 LS-COUNT               BINARY-LONG.
 01 LS-KEY                 PIC X(48).
 01 LS-BARE                PIC X(48).
 01 LS-DX                  BINARY-LONG.
 01 LS-DY                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-FX                  BINARY-LONG.
 01 LS-FY                  BINARY-LONG.
 01 LS-FZ                  BINARY-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-OK                  BINARY-LONG.
 01 LS-EVENT               BINARY-LONG.
 01 LS-DATA                BINARY-LONG.
 01 LS-EXCLUDED            BINARY-LONG VALUE 0.
 01 LS-PROCEED             BINARY-LONG.
 01 LS-GAME                BINARY-LONG.
 01 LS-EMPTY               BINARY-LONG VALUE 0.
 01 LS-CONTAINER           BINARY-LONG.
 01 LS-LEFT                BINARY-LONG.
 01 LS-NOTHING-LEFT        BINARY-LONG.
 01 LS-OUTCOME             BINARY-LONG.
 01 LS-NEWCOUNT            BINARY-LONG.
 01 LS-WRITE               BINARY-LONG.
 01 LS-SIZE                BINARY-LONG.
 01 LS-DROPPER             BINARY-LONG.
 01 LS-DEC                 BINARY-LONG.
 01 LS-REMAIN              BINARY-LONG.
 01 LS-HANDLED             BINARY-LONG.
 01 LS-CONSUMED            BINARY-LONG.
 01 LS-RITEM               BINARY-LONG.
 01 LS-RVAR                BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     MOVE RL-CLASS(LS-BLOCK + 1) TO LS-CLASS
     MOVE RL-S-DIR(L-STATE + 1) TO LS-F
     EVALUATE L-KIND
         WHEN 3
*>           neighborChanged (1.2): the signal at the block or at the block above (quasi-connectivity), one tick for one rising edge
             CALL "RL-HAS-SIGNAL" USING L-DIM L-X L-Y L-Z LS-HERE
             COMPUTE LS-QY = L-Y + 1
             CALL "RL-HAS-SIGNAL" USING L-DIM L-X LS-QY L-Z LS-ABOVE
             CALL "RS2-DISP-POWERED" USING LS-HERE LS-ABOVE LS-POWERED
             CALL "RL-GET-BOOL" USING L-STATE WS-TRIGGERED LS-TRIG
             CALL "RS2-DISP-NEIGHBOR" USING LS-POWERED LS-TRIG LS-SCHEDULE LS-DELAY LS-NEW-TRIG LS-FLAGS LS-ACTION
             IF LS-SCHEDULE = 1
                 CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIO LS-RESULT
             END-IF
             IF LS-ACTION > 0
                 CALL "RL-SET-BOOL" USING L-STATE WS-TRIGGERED LS-NEW-TRIG LS-NEW
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
             END-IF
         WHEN 7
*>           dispenseFrom (1.3, 1.4): the slot is chosen by reservoir selection over the non-empty slots
             CALL "BE-FIND" USING L-DIM L-X L-Y L-Z LS-INDEX
             IF LS-INDEX = 0
                 GOBACK
             END-IF
             MOVE -1 TO LS-CHOICE
             MOVE 0 TO LS-N
             PERFORM VARYING LS-S FROM 1 BY 1 UNTIL LS-S > 9
                 IF BE-SLOT-COUNT(LS-INDEX, LS-S) > 0
                     ADD 1 TO LS-N
                     CALL "IP-LEVEL-DOUBLE" USING LS-DRAW
                     COMPUTE LS-PICK = FUNCTION INTEGER(LS-DRAW * LS-N)
                     IF LS-PICK = 0
                         MOVE LS-S TO LS-CHOICE
                     END-IF
                 END-IF
             END-PERFORM
             MOVE 0 TO LS-DROPPER
             IF LS-CLASS = 30
                 MOVE 1 TO LS-DROPPER
             END-IF
             MOVE 0 TO LS-DATA
             IF LS-CHOICE < 0
                 CALL "RS2-DISP-EMPTY" USING LS-CHOICE LS-DROPPER LS-PROCEED LS-EVENT LS-GAME
                 CALL "LEVEL-EVENT" USING L-DIM LS-EVENT L-X L-Y L-Z LS-DATA LS-EXCLUDED
                 GOBACK
             END-IF
             MOVE BE-SLOT-ITEM(LS-INDEX, LS-CHOICE) TO LS-ITEM
             MOVE BE-SLOT-VAR(LS-INDEX, LS-CHOICE) TO LS-VAR
             MOVE BE-SLOT-COUNT(LS-INDEX, LS-CHOICE) TO LS-COUNT
             CALL "RS1-STEP" USING LS-F LS-DX LS-DY LS-DZ
             COMPUTE LS-FX = L-X + LS-DX
             COMPUTE LS-FY = L-Y + LS-DY
             COMPUTE LS-FZ = L-Z + LS-DZ
             IF LS-CLASS = 29
*>               the dispenser: TNT is primed in the cell in front, every other item is dropped (default behaviour, 2)
                 MOVE IT-KEY(LS-ITEM + 1) TO LS-KEY
                 CALL "KEY-BARE" USING LS-KEY LS-BARE
                 MOVE 1 TO LS-OK
                 MOVE 1 TO LS-DEC
                 MOVE 0 TO LS-REMAIN
                 IF LS-BARE = "tnt"
                     CALL "TNT-DISPENSE" USING L-DIM LS-FX LS-FY LS-FZ LS-OK
                 ELSE
*>                   the registered behaviours of 4 (redstone-live-j.cob); an item without one is dropped
                     CALL "RL-DISP-BEHAVE" USING L-DIM LS-FX LS-FY LS-FZ LS-F LS-ITEM LS-VAR LS-HANDLED LS-CONSUMED LS-REMAIN
                     IF LS-HANDLED = 0
                         CALL "GI-DISPENSE" USING L-DIM L-X L-Y L-Z LS-F LS-ITEM LS-ROW
                     ELSE
                         MOVE 0 TO LS-OK
                         IF LS-CONSUMED > 0
                             MOVE 1 TO LS-OK
                         END-IF
                         IF LS-CONSUMED = 2
                             MOVE 0 TO LS-DEC
                         END-IF
                     END-IF
                 END-IF
                 IF LS-OK = 1 AND LS-DEC = 1
                     SUBTRACT 1 FROM BE-SLOT-COUNT(LS-INDEX, LS-CHOICE)
                     IF BE-SLOT-COUNT(LS-INDEX, LS-CHOICE) = 0
                         MOVE 0 TO BE-SLOT-ITEM(LS-INDEX, LS-CHOICE)
                     END-IF
                     CALL "BE-MARK-CHUNK" USING LS-INDEX
                 END-IF
*>               consumeWithRemainder (2): the remainder takes the emptied slot, else goes into the dispenser, else is dropped
                 IF LS-REMAIN > 0
                     COMPUTE LS-RITEM = LS-REMAIN - 1
                     IF BE-SLOT-COUNT(LS-INDEX, LS-CHOICE) = 0
                         MOVE LS-RITEM TO BE-SLOT-ITEM(LS-INDEX, LS-CHOICE)
                         MOVE 0 TO BE-SLOT-VAR(LS-INDEX, LS-CHOICE)
                         MOVE 1 TO BE-SLOT-COUNT(LS-INDEX, LS-CHOICE)
                     ELSE
                         MOVE 0 TO LS-RVAR
                         CALL "RL-INSERT-ONE" USING LS-INDEX LS-RITEM LS-RVAR LS-LEFT
                         IF LS-LEFT = 1
                             CALL "GI-DISPENSE" USING L-DIM L-X L-Y L-Z LS-F LS-RITEM LS-ROW
                         END-IF
                     END-IF
                     CALL "BE-MARK-CHUNK" USING LS-INDEX
                 END-IF
                 MOVE 1000 TO LS-EVENT
                 IF LS-OK = 0
                     MOVE 1001 TO LS-EVENT
                 END-IF
*>               a projectile (4.1) launches with the launch sound
                 IF LS-HANDLED = 1 AND LS-CONSUMED = 3
                     MOVE 1002 TO LS-EVENT
                 END-IF
                 CALL "LEVEL-EVENT" USING L-DIM LS-EVENT L-X L-Y L-Z LS-DATA LS-EXCLUDED
                 MOVE 2000 TO LS-EVENT
                 MOVE LS-F TO LS-DATA
                 CALL "LEVEL-EVENT" USING L-DIM LS-EVENT L-X L-Y L-Z LS-DATA LS-EXCLUDED
             ELSE
*>               the dropper (1.4): a container in front takes one item, else the item is dropped
                 CALL "BE-FIND" USING L-DIM LS-FX LS-FY LS-FZ LS-INDEX2
                 MOVE 0 TO LS-CONTAINER LS-SIZE
                 IF LS-INDEX2 > 0
                     CALL "BE-CONTAINER-SIZE" USING BE-TYPE(LS-INDEX2) LS-SIZE
                 END-IF
                 IF LS-SIZE > 0
                     MOVE 1 TO LS-CONTAINER
*>                   addItem(dropper, container, stack, facing.getOpposite()) (30-4 1.4): a furnace or brewing stand takes it through the face that looks back at the dropper
                     EVALUATE LS-F
                         WHEN 0
                             MOVE 1 TO LS-FACE
                         WHEN 1
                             MOVE 0 TO LS-FACE
                         WHEN OTHER
                             MOVE 2 TO LS-FACE
                     END-EVALUATE
                     CALL "HOPPER-ADD-ONE" USING LS-INDEX2 LS-ITEM LS-VAR LS-FACE LS-LEFT
                 ELSE
                     MOVE 1 TO LS-LEFT
                 END-IF
                 MOVE 0 TO LS-NOTHING-LEFT
                 IF LS-LEFT = 0
                     MOVE 1 TO LS-NOTHING-LEFT
                 END-IF
                 CALL "RS2-DROPPER-RUN" USING LS-CHOICE LS-EMPTY LS-CONTAINER LS-NOTHING-LEFT LS-COUNT LS-OUTCOME LS-EVENT
                     LS-NEWCOUNT LS-WRITE
                 IF LS-OUTCOME = 1
                     CALL "GI-DISPENSE" USING L-DIM L-X L-Y L-Z LS-F LS-ITEM LS-ROW
                     MOVE 1000 TO LS-EVENT
                     CALL "LEVEL-EVENT" USING L-DIM LS-EVENT L-X L-Y L-Z LS-DATA LS-EXCLUDED
                     MOVE 2000 TO LS-EVENT
                     MOVE LS-F TO LS-DATA
                     CALL "LEVEL-EVENT" USING L-DIM LS-EVENT L-X L-Y L-Z LS-DATA LS-EXCLUDED
                 END-IF
                 IF LS-WRITE = 1
                     MOVE LS-NEWCOUNT TO BE-SLOT-COUNT(LS-INDEX, LS-CHOICE)
                     IF LS-NEWCOUNT = 0
                         MOVE 0 TO BE-SLOT-ITEM(LS-INDEX, LS-CHOICE)
                     END-IF
                     CALL "BE-MARK-CHUNK" USING LS-INDEX
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-DISP-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-HOPPER-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-ENABLED             PIC X(16) VALUE "enabled".
 LOCAL-STORAGE SECTION.
 01 LS-SAME                BINARY-LONG.
 01 LS-SIGNAL              BINARY-LONG.
 01 LS-ENABLED             BINARY-LONG.
 01 LS-SHOULD              BINARY-LONG.
 01 LS-WRITE               BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-OLD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-OLD.
     MOVE 0 TO LS-SAME
     IF L-KIND = 1
         CALL "RL-SAME-BLOCK" USING L-STATE L-OLD LS-SAME
         IF LS-SAME = 1
             GOBACK
         END-IF
     END-IF
*>   checkPoweredState (5.1): enabled = not hasNeighborSignal, written with flags 2 when it changed
     CALL "RL-HAS-SIGNAL" USING L-DIM L-X L-Y L-Z LS-SIGNAL
     CALL "RL-GET-BOOL" USING L-STATE WS-ENABLED LS-ENABLED
     CALL "RS2-HOPPER-ENABLE" USING LS-SIGNAL LS-ENABLED LS-SHOULD LS-WRITE LS-FLAGS
     IF LS-WRITE = 1
         CALL "RL-SET-BOOL" USING L-STATE WS-ENABLED LS-SHOULD LS-NEW
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
     END-IF
     GOBACK.
 END PROGRAM RL-HOPPER-HOOK.
