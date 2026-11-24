*> Live redstone, the blocks that follow a signal (docs/protocol/30-redstone-7 sections 3 to 8 over the signal model of redstone-live.cob): the hooks of the redstone lamp, the copper
*> bulb, doors, trapdoors, fence gates and TNT, and the powered state a placed block starts with. The decisions are those of the RS3-* tables of redstone-30-7.cob; this file reads
*> hasNeighborSignal (RL-BEST-NEIGHBOR > 0, 30-1 section 2.3), writes the block and schedules the tick.
*> Deviations: no door, trapdoor, gate or bulb sound and no BLOCK_OPEN, BLOCK_CLOSE or PRIME_FUSE game event goes out (the sound and the event of each table row are decided by the table and
*> not sent); a waterlogged trapdoor changed by a signal does not schedule its water tick; the TNT block is removed with flags 3 and the entity appears at once (the entity carries the sound
*> of 8.2 in the document, not here).
*> Entry points:
*>   RL-LAMP-HOOK USING kind, dimension row, x, y, z, state    kind 3 neighborChanged and 7 scheduled tick of a redstone lamp
*>   RL-OPEN-HOOK USING kind, dimension row, x, y, z, state, source block    kind 3 (neighborChanged, the only kind it is called with) of a door, a trapdoor and a fence gate
*>   RL-BULB-HOOK USING kind, dimension row, x, y, z, state, old state    kind 1 and 3 of a copper bulb (checkAndFlip)
*>   RL-TNT-HOOK USING kind, dimension row, x, y, z, state, old state    kind 1 and 3 of a TNT block
*>   REDSTONE-PLACE-STATE USING dimension row, x, y, z, state (in and out)    the placed state of a lamp, a trapdoor, a fence gate, the lower half of a door and a crafter (triggered)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-SET-BOOL.
*> USING state, property name (PIC X(16)), value 0 or 1, state out: the state with that boolean property set (the state itself when it has none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TRUE                PIC X(16) VALUE "true".
 01 WS-FALSE               PIC X(16) VALUE "false".
 01 WS-OLD                 PIC X(16).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-VALUE                BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-NAME L-VALUE L-OUT.
     IF L-VALUE = 1
         CALL "SW-SET-PROP" USING L-STATE L-NAME WS-TRUE L-OUT WS-OLD
     ELSE
         CALL "SW-SET-PROP" USING L-STATE L-NAME WS-FALSE L-OUT WS-OLD
     END-IF
     GOBACK.
 END PROGRAM RL-SET-BOOL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-GET-BOOL.
*> USING state, property name (PIC X(16)), value out (1 when the property is true).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-OLD                 PIC X(16).
 01 WS-NEW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-VALUE                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-NAME L-VALUE.
     CALL "SW-SET-PROP" USING L-STATE L-NAME WS-KEEP WS-NEW WS-OLD
     MOVE 0 TO L-VALUE
     IF WS-OLD = "true"
         MOVE 1 TO L-VALUE
     END-IF
     GOBACK.
 END PROGRAM RL-GET-BOOL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-HAS-SIGNAL.
*> USING dimension row, x, y, z, signal out: hasNeighborSignal (30-1 section 2.3), 1 or 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BEST                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SIGNAL               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SIGNAL.
     CALL "RL-BEST-NEIGHBOR" USING L-DIM L-X L-Y L-Z WS-BEST
     MOVE 0 TO L-SIGNAL
     IF WS-BEST > 0
         MOVE 1 TO L-SIGNAL
     END-IF
     GOBACK.
 END PROGRAM RL-HAS-SIGNAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-LAMP-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIT                 PIC X(16) VALUE "lit".
 LOCAL-STORAGE SECTION.
 01 LS-SERVER              BINARY-LONG VALUE 1.
 01 LS-SIGNAL              BINARY-LONG.
 01 LS-LIT                 BINARY-LONG.
 01 LS-ACTION              BINARY-LONG.
 01 LS-LIT-NOW             BINARY-LONG.
 01 LS-DELAY               BINARY-LONG.
 01 LS-AFTER               BINARY-LONG.
 01 LS-WRITE               BINARY-LONG.
 01 LS-NEW                 BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 2.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-TYPE                BINARY-LONG VALUE 1.
 01 LS-PRIO                BINARY-LONG VALUE 0.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE.
     CALL "RL-HAS-SIGNAL" USING L-DIM L-X L-Y L-Z LS-SIGNAL
     CALL "RL-GET-BOOL" USING L-STATE WS-LIT LS-LIT
     EVALUATE L-KIND
         WHEN 3
*>           neighborChanged (6 step 2): lit but unpowered schedules the turn-off 4 ticks ahead, unlit but powered lights at once
             CALL "RS3-LAMP-NEIGHBOR" USING LS-SERVER LS-LIT LS-SIGNAL LS-ACTION LS-LIT-NOW LS-DELAY
             IF LS-ACTION = 1
                 CALL "RL-BLOCK-OF" USING L-STATE LS-BLOCK
                 CALL "BT-SCHEDULE" USING L-DIM LS-TYPE LS-BLOCK L-X L-Y L-Z LS-DELAY LS-PRIO LS-RESULT
             END-IF
             IF LS-ACTION = 2
                 CALL "RL-SET-BOOL" USING L-STATE WS-LIT LS-ONE LS-NEW
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
             END-IF
         WHEN 7
*>           the tick (6 step 3): lit without a signal turns off
             CALL "RS3-LAMP-TICK" USING LS-LIT LS-SIGNAL LS-AFTER LS-WRITE
             IF LS-WRITE = 1
                 CALL "RL-SET-BOOL" USING L-STATE WS-LIT LS-AFTER LS-NEW
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-NEW LS-FLAGS LS-BUDGET LS-RESULT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-LAMP-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-BLOCK-OF.
*> USING state, block id out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-BLOCK.
     MOVE CB-S-BLOCK(L-STATE + 1) TO L-BLOCK
     GOBACK.
 END PROGRAM RL-BLOCK-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-OPEN-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-POWERED             PIC X(16) VALUE "powered".
 01 WS-OPEN                PIC X(16) VALUE "open".
 01 WS-HALF                PIC X(16) VALUE "half".
 01 WS-WATERLOGGED         PIC X(16) VALUE "waterlogged".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 LOCAL-STORAGE SECTION.
 01 LS-SERVER              BINARY-LONG VALUE 1.
 01 LS-CLASS               BINARY-LONG.
 01 LS-BLOCK               BINARY-LONG.
 01 LS-HERE                BINARY-LONG.
 01 LS-OTHER-SIG           BINARY-LONG.
 01 LS-POWER               BINARY-LONG.
 01 LS-POWERED             BINARY-LONG.
 01 LS-OPEN                BINARY-LONG.
 01 LS-WATERLOGGED         BINARY-LONG.
 01 LS-SAME                BINARY-LONG.
 01 LS-WRITE               BINARY-LONG.
 01 LS-SOUND               BINARY-LONG.
 01 LS-EVENT               BINARY-LONG.
 01 LS-NEW-POWERED         BINARY-LONG.
 01 LS-NEW-OPEN            BINARY-LONG.
 01 LS-WATER-TICK          BINARY-LONG.
 01 LS-STATE-A             BINARY-LONG.
 01 LS-STATE-B             BINARY-LONG.
 01 LS-OLD                 PIC X(16).
 01 LS-OY                  BINARY-LONG.
 01 LS-OSTATE              BINARY-LONG.
 01 LS-ONEW                BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 2.
 01 LS-BUDGET              BINARY-LONG VALUE 512.
 01 LS-RESULT              BINARY-LONG.
 01 LS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-SOURCE.
     MOVE CB-S-BLOCK(L-STATE + 1) TO LS-BLOCK
     MOVE RL-CLASS(LS-BLOCK + 1) TO LS-CLASS
     CALL "RL-GET-BOOL" USING L-STATE WS-POWERED LS-POWERED
     CALL "RL-GET-BOOL" USING L-STATE WS-OPEN LS-OPEN
     CALL "RL-HAS-SIGNAL" USING L-DIM L-X L-Y L-Z LS-HERE
     MOVE 0 TO LS-SAME
     IF L-SOURCE = LS-BLOCK
         MOVE 1 TO LS-SAME
     END-IF
     EVALUATE LS-CLASS
         WHEN 12
*>           a door (3.5): the cell and the other half's cell both count
             CALL "SW-SET-PROP" USING L-STATE WS-HALF WS-KEEP LS-STATE-A LS-OLD
             COMPUTE LS-OY = L-Y + 1
             IF LS-OLD = "upper"
                 COMPUTE LS-OY = L-Y - 1
             END-IF
             CALL "RL-HAS-SIGNAL" USING L-DIM L-X LS-OY L-Z LS-OTHER-SIG
             CALL "RS3-DOOR-POWER" USING LS-HERE LS-OTHER-SIG LS-POWER
             CALL "RS3-DOOR-NEIGHBOR" USING LS-POWER LS-POWERED LS-OPEN LS-SAME LS-WRITE LS-SOUND LS-EVENT
                 LS-NEW-POWERED LS-NEW-OPEN
             IF LS-WRITE = 1
                 CALL "RL-SET-BOOL" USING L-STATE WS-POWERED LS-NEW-POWERED LS-STATE-A
                 CALL "RL-SET-BOOL" USING LS-STATE-A WS-OPEN LS-NEW-OPEN LS-STATE-B
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-STATE-B LS-FLAGS LS-BUDGET LS-RESULT
                 CALL "RL-OPEN-EFFECTS" USING L-DIM L-X L-Y L-Z LS-STATE-B LS-CLASS LS-SOUND LS-ZERO
*>               the other half follows through its shape update (3.5 pairing)
                 CALL "WORLD-GET-BLOCK" USING L-DIM L-X LS-OY L-Z LS-OSTATE
                 IF CB-S-BLOCK(LS-OSTATE + 1) = LS-BLOCK
                     CALL "RL-SET-BOOL" USING LS-OSTATE WS-POWERED LS-NEW-POWERED LS-STATE-A
                     CALL "RL-SET-BOOL" USING LS-STATE-A WS-OPEN LS-NEW-OPEN LS-ONEW
                     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X LS-OY L-Z LS-ONEW LS-FLAGS LS-BUDGET LS-RESULT
                 END-IF
             END-IF
         WHEN 9
*>           a trapdoor (4.3): this cell only
             CALL "RL-GET-BOOL" USING L-STATE WS-WATERLOGGED LS-WATERLOGGED
             CALL "RS3-TRAP-NEIGHBOR" USING LS-SERVER LS-HERE LS-POWERED LS-OPEN LS-WATERLOGGED LS-WRITE LS-NEW-OPEN
                 LS-NEW-POWERED LS-SOUND LS-EVENT LS-WATER-TICK
             IF LS-WRITE = 1
                 CALL "RL-SET-BOOL" USING L-STATE WS-POWERED LS-NEW-POWERED LS-STATE-A
                 CALL "RL-SET-BOOL" USING LS-STATE-A WS-OPEN LS-NEW-OPEN LS-STATE-B
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-STATE-B LS-FLAGS LS-BUDGET LS-RESULT
                 CALL "RL-OPEN-EFFECTS" USING L-DIM L-X L-Y L-Z LS-STATE-B LS-CLASS LS-SOUND LS-WATER-TICK
             END-IF
         WHEN 13
*>           a fence gate (5.3)
             CALL "RS3-GATE-NEIGHBOR" USING LS-SERVER LS-HERE LS-POWERED LS-OPEN LS-WRITE LS-NEW-POWERED LS-NEW-OPEN
                 LS-SOUND LS-EVENT
             IF LS-WRITE = 1
                 CALL "RL-SET-BOOL" USING L-STATE WS-POWERED LS-NEW-POWERED LS-STATE-A
                 CALL "RL-SET-BOOL" USING LS-STATE-A WS-OPEN LS-NEW-OPEN LS-STATE-B
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-STATE-B LS-FLAGS LS-BUDGET LS-RESULT
                 CALL "RL-OPEN-EFFECTS" USING L-DIM L-X L-Y L-Z LS-STATE-B LS-CLASS LS-SOUND LS-ZERO
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM RL-OPEN-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-BULB-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LIT                 PIC X(16) VALUE "lit".
 01 WS-POWERED             PIC X(16) VALUE "powered".
 LOCAL-STORAGE SECTION.
 01 LS-SERVER              BINARY-LONG VALUE 1.
 01 LS-SAME                BINARY-LONG.
 01 LS-RUNS                BINARY-LONG.
 01 LS-SIGNAL              BINARY-LONG.
 01 LS-LIT                 BINARY-LONG.
 01 LS-POWERED             BINARY-LONG.
 01 LS-WRITE               BINARY-LONG.
 01 LS-NEW-LIT             BINARY-LONG.
 01 LS-NEW-POWERED         BINARY-LONG.
 01 LS-SOUND               BINARY-LONG.
 01 LS-EVENT               BINARY-LONG.
 01 LS-KEY                 PIC X(48).
 01 LS-STATE-A             BINARY-LONG.
 01 LS-STATE-B             BINARY-LONG.
 01 LS-FLAGS               BINARY-LONG VALUE 3.
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
     MOVE 0 TO LS-RUNS
     EVALUATE L-KIND
         WHEN 1
             MOVE 0 TO LS-SAME
             CALL "RL-SAME-BLOCK" USING L-STATE L-OLD LS-SAME
             CALL "RS3-BULB-ON-PLACE" USING LS-SAME LS-SERVER LS-RUNS
         WHEN 3
             CALL "RS3-BULB-NEIGHBOR" USING LS-SERVER LS-RUNS
     END-EVALUATE
     IF LS-RUNS = 1
*>       checkAndFlip (7.2)
         CALL "RL-HAS-SIGNAL" USING L-DIM L-X L-Y L-Z LS-SIGNAL
         CALL "RL-GET-BOOL" USING L-STATE WS-LIT LS-LIT
         CALL "RL-GET-BOOL" USING L-STATE WS-POWERED LS-POWERED
         CALL "RS3-BULB-FLIP" USING LS-LIT LS-POWERED LS-SIGNAL LS-WRITE LS-NEW-LIT LS-NEW-POWERED LS-SOUND
         IF LS-WRITE = 1
             CALL "RL-SET-BOOL" USING L-STATE WS-LIT LS-NEW-LIT LS-STATE-A
             CALL "RL-SET-BOOL" USING LS-STATE-A WS-POWERED LS-NEW-POWERED LS-STATE-B
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z LS-STATE-B LS-FLAGS LS-BUDGET LS-RESULT
             IF LS-SOUND > 0
*>               turn_on or turn_off (7.2)
                 COMPUTE LS-EVENT = 4 - LS-NEW-LIT
                 CALL "RL-BLOCK-SOUND" USING L-DIM L-X L-Y L-Z LS-KEY LS-EVENT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RL-BULB-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-SAME-BLOCK.
*> USING state, other state, same out: 1 when both states are of one block.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 LINKAGE SECTION.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-SAME                 BINARY-LONG.
 PROCEDURE DIVISION USING L-A L-B L-SAME.
     MOVE 0 TO L-SAME
     IF CB-S-BLOCK(L-A + 1) = CB-S-BLOCK(L-B + 1)
         MOVE 1 TO L-SAME
     END-IF
     GOBACK.
 END PROGRAM RL-SAME-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RL-TNT-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RULE-NAME           PIC X(40) VALUE "tnt_explodes".
 LOCAL-STORAGE SECTION.
 01 LS-SERVER              BINARY-LONG VALUE 1.
 01 LS-SIGNAL              BINARY-LONG.
 01 LS-EXPLODES            BINARY-LONG.
 01 LS-RULE                BINARY-DOUBLE.
 01 LS-NO                  BINARY-LONG VALUE 0.
 01 LS-NO2                 BINARY-LONG VALUE 0.
 01 LS-CAN                 BINARY-LONG VALUE 1.
 01 LS-CREATED             BINARY-LONG.
 01 LS-OLD-TNT             BINARY-LONG.
 01 LS-CALLED              BINARY-LONG.
 01 LS-REMOVE              BINARY-LONG.
 01 LS-PX                  FLOAT-LONG.
 01 LS-PY                  FLOAT-LONG.
 01 LS-PZ                  FLOAT-LONG.
 01 LS-ROW                 BINARY-LONG.
 01 LS-MOVED               BINARY-LONG VALUE 0.
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
     CALL "RL-HAS-SIGNAL" USING L-DIM L-X L-Y L-Z LS-SIGNAL
     MOVE 0 TO LS-CALLED LS-REMOVE
     IF L-KIND = 1
         CALL "RL-SAME-BLOCK" USING L-STATE L-OLD LS-OLD-TNT
         CALL "RS3-TNT-PLACE" USING LS-OLD-TNT LS-SIGNAL LS-CREATED LS-CALLED LS-REMOVE
     ELSE
         CALL "RS3-TNT-NEIGHBOR" USING LS-SIGNAL LS-CREATED LS-CALLED LS-REMOVE
     END-IF
     IF LS-CALLED = 1
*>       prime (8.2 steps 1 to 4): the entity is made at the block centre; the block goes when it was
         CALL "BR-RULE-GET" USING WS-RULE-NAME LS-RULE
         MOVE 0 TO LS-EXPLODES
         IF LS-RULE NOT = 0
             MOVE 1 TO LS-EXPLODES
         END-IF
         CALL "RS3-TNT-PRIME" USING LS-SERVER LS-EXPLODES LS-NO LS-NO2 LS-CAN LS-CREATED
         IF LS-CREATED = 1
             COMPUTE LS-PX = L-X + 0.5
             MOVE L-Y TO LS-PY
             COMPUTE LS-PZ = L-Z + 0.5
             CALL "TNT-PRIME" USING L-DIM LS-PX LS-PY LS-PZ LS-ROW
             CALL "LEVEL-REMOVE-BLOCK" USING L-DIM L-X L-Y L-Z LS-MOVED LS-RESULT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM RL-TNT-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REDSTONE-PLACE-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY RSLIVE.
 01 WS-LIT                 PIC X(16) VALUE "lit".
 01 WS-POWERED             PIC X(16) VALUE "powered".
 01 WS-OPEN                PIC X(16) VALUE "open".
 01 WS-HALF                PIC X(16) VALUE "half".
 01 WS-TRIGGERED           PIC X(16) VALUE "triggered".
 01 WS-KEEP                PIC X(16) VALUE "keep".
 01 WS-CLASS               BINARY-LONG.
 01 WS-SIGNAL              BINARY-LONG.
 01 WS-SIGNAL-UP           BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-NEW                 BINARY-LONG.
 01 WS-OLD                 PIC X(16).
 01 WS-TMP                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     CALL "REDSTONE-IDS-ENSURE"
     MOVE RL-CLASS(CB-S-BLOCK(L-STATE + 1) + 1) TO WS-CLASS
     IF WS-CLASS NOT = 11 AND WS-CLASS NOT = 9 AND WS-CLASS NOT = 12 AND WS-CLASS NOT = 13 AND WS-CLASS NOT = 16 AND WS-CLASS NOT = 25
             AND WS-CLASS NOT = 35
         GOBACK
     END-IF
     IF WS-CLASS = 25
*>       the wire's four sides at placement (30-8 7.1)
         CALL "RL-WIRE-SIDES" USING L-DIM L-X L-Y L-Z L-STATE WS-NEW
         MOVE WS-NEW TO L-STATE
         GOBACK
     END-IF
     IF WS-CLASS = 16
*>       the note block (30-5 8.2): getStateForPlacement applies setInstrument
         CALL "RL-NOTE-SET-INSTRUMENT" USING L-DIM L-X L-Y L-Z L-STATE
         GOBACK
     END-IF
     CALL "RL-HAS-SIGNAL" USING L-DIM L-X L-Y L-Z WS-SIGNAL
     EVALUATE WS-CLASS
         WHEN 11
*>           the lamp (30-7 6 step 1): lit with the signal
             CALL "RL-SET-BOOL" USING L-STATE WS-LIT WS-SIGNAL WS-NEW
             MOVE WS-NEW TO L-STATE
         WHEN 35
*>           the crafter (30-4 6.1): triggered with the signal at the placed position
             CALL "RL-SET-BOOL" USING L-STATE WS-TRIGGERED WS-SIGNAL WS-NEW
             MOVE WS-NEW TO L-STATE
         WHEN 9
         WHEN 13
*>           trapdoor (4.2 step 4) and fence gate (5.2 step 1): open and powered with the signal at the placed position
             CALL "RL-SET-BOOL" USING L-STATE WS-POWERED WS-SIGNAL WS-NEW
             CALL "RL-SET-BOOL" USING WS-NEW WS-OPEN WS-SIGNAL L-STATE
         WHEN 12
*>           the door (3.3 step 2): the cell or the cell above
             CALL "SW-SET-PROP" USING L-STATE WS-HALF WS-KEEP WS-TMP WS-OLD
             IF WS-OLD NOT = "upper"
                 COMPUTE WS-QY = L-Y + 1
                 CALL "RL-HAS-SIGNAL" USING L-DIM L-X WS-QY L-Z WS-SIGNAL-UP
                 IF WS-SIGNAL-UP = 1
                     MOVE 1 TO WS-SIGNAL
                 END-IF
                 CALL "RL-SET-BOOL" USING L-STATE WS-POWERED WS-SIGNAL WS-NEW
                 CALL "RL-SET-BOOL" USING WS-NEW WS-OPEN WS-SIGNAL L-STATE
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM REDSTONE-PLACE-STATE.
