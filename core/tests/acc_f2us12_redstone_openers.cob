*> Acceptance test (T29000..T29010, US12-4; docs/protocol/30-redstone-7 sections 3 to 8 over the signal model of 30-redstone-1 section 2.3): a power change next to a redstone lamp, a
*> copper bulb, a door, a trapdoor, a fence gate and a TNT block reaches the block through its neighborChanged hook, as the documents say. A lamp lights at once and goes out 4 ticks after
*> its power left (6 step 2 and 3); a door, a trapdoor and a gate open with the signal and close when it leaves (3.5, 4.3, 5.3), a door through both halves (power seen from the cell and
*> from the other half's cell); a copper bulb flips lit on each rising edge (7.2); a TNT block beside power becomes a primed TNT entity (8.3). Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-OPENERS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
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
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-EXP                 PIC X(160).
 01 WS-CASE                PIC X(240).
 01 WS-I                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-BARE                PIC X(48).
 01 WS-TNT-TYPE            BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-OP-NAME             PIC X(16).
 01 WS-OP-KEEP             PIC X(16) VALUE "keep".
 01 WS-OP-NEW              BINARY-LONG.
 01 WS-OP-A                PIC X(16).
 01 WS-OP-B                PIC X(16).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone openers: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE "minecraft:tnt" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TNT-TYPE WS-ENTITY-ROW WS-STATUS
*>   a stone floor at y 100 and clear air at y 101 to 103 for x 0 to 6, z 0 to 20
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 24
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 6
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K
             MOVE SPACES TO WS-PR
             PERFORM PUT-BLOCK
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 103
                 MOVE "air" TO WS-K
                 PERFORM PUT-BLOCK
             END-PERFORM
         END-PERFORM
     END-PERFORM

*>   A. redstone lamp (z 0) beside a redstone block at x 4
     MOVE 0 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_lamp" TO WS-K MOVE "lit=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 6 step 2 an unlit lamp beside power lights at once, with no delay" TO WS-CASE
     MOVE "lit=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 6 step 2 a lit lamp that lost its power is still lit 3 ticks later (a tick is pending for 4)" TO WS-CASE
     MOVE "lit=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "acceptance US12-4 live redstone 30-7 6 step 3 the lamp goes out on its tick, 4 ticks after the power left" TO WS-CASE
     MOVE "lit=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   a gap shorter than 4 ticks does not put a lit lamp out
     MOVE 4 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE "air" TO WS-K PERFORM PUT-BLOCK
     MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 6 step 3 power back before the tick: the tick does nothing and the lamp stays lit" TO WS-CASE
     MOVE "lit=true" TO WS-EXP
     PERFORM ASSERT-PROPS

*>   B. trapdoor (z 2) beside a redstone block
     MOVE 2 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "oak_trapdoor" TO WS-K
     MOVE "facing=north,half=bottom,open=false,powered=false,waterlogged=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 4.3 a trapdoor beside power opens and records powered" TO WS-CASE
     MOVE "facing=north,half=bottom,open=true,powered=true,waterlogged=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 4.3 the signal gone: the trapdoor closes and clears powered" TO WS-CASE
     MOVE "facing=north,half=bottom,open=false,powered=false,waterlogged=false" TO WS-EXP
     PERFORM ASSERT-PROPS

*>   C. fence gate (z 4)
     MOVE 4 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "oak_fence_gate" TO WS-K
     MOVE "facing=north,in_wall=false,open=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 5.3 a fence gate beside power opens and records powered" TO WS-CASE
     MOVE "facing=north,in_wall=false,open=true,powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 5.3 the signal gone: the gate closes" TO WS-CASE
     MOVE "facing=north,in_wall=false,open=false,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS

*>   D. door (z 6): the signal reaches the lower half only, the upper half follows (3.5)
     MOVE 6 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "oak_door" TO WS-K
     MOVE "facing=north,half=lower,hinge=left,open=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 102 TO WS-Y MOVE "facing=north,half=upper,hinge=left,open=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     MOVE "acceptance US12-4 live redstone 30-7 3.5 a door whose lower half is beside power opens that half" TO WS-CASE
     MOVE "facing=north,half=lower,hinge=left,open=true,powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 102 TO WS-Y
     MOVE "acceptance US12-4 live redstone 30-7 3.5 the upper half follows with the same open and powered" TO WS-CASE
     MOVE "facing=north,half=upper,hinge=left,open=true,powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 3.5 the signal gone: the lower half closes" TO WS-CASE
     MOVE "facing=north,half=lower,hinge=left,open=false,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 102 TO WS-Y
     MOVE "acceptance US12-4 live redstone 30-7 3.5 and the upper half closes with it" TO WS-CASE
     MOVE "facing=north,half=upper,hinge=left,open=false,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   power at the upper half's side reaches the door through the other half's cell
     MOVE 4 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     MOVE "acceptance US12-4 live redstone 30-7 3.5 step 1 power beside the upper half opens the door (each half asks the other half's neighbours too)" TO WS-CASE
     MOVE "facing=north,half=lower,hinge=left,open=true,powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS

*>   the lower half rewritten with flags 3 tells the upper half with the door as the source: the upper half does nothing (3.5 step 2)
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "oak_door" TO WS-K
     MOVE "facing=north,half=lower,hinge=right,open=true,powered=true" TO WS-PR PERFORM PUT-BLOCK
     MOVE 102 TO WS-Y
     MOVE "acceptance US12-4 live redstone 30-7 3.5 step 2 an update from the other door half changes nothing: the upper half keeps open and powered" TO WS-CASE
     MOVE "facing=north,half=upper,hinge=left,open=true,powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS

*>   E. copper bulb (z 8): each rising edge flips lit, a falling edge only clears powered (7.2)
     MOVE 8 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "copper_bulb" TO WS-K MOVE "lit=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 7.2 the first rising edge turns the bulb on" TO WS-CASE
     MOVE "lit=true,powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 7.2 a falling edge only clears powered: the bulb stays lit" TO WS-CASE
     MOVE "lit=true,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 7.2 the next rising edge turns it off again" TO WS-CASE
     MOVE "lit=false,powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS

*>   F. TNT (z 10) beside a redstone block becomes a primed TNT entity (8.3 neighborChanged)
     MOVE 10 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "tnt" TO WS-K MOVE "unstable=false" TO WS-PR PERFORM PUT-BLOCK
     PERFORM COUNT-TNT
     MOVE WS-COUNT TO WS-BEFORE
     MOVE 4 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     MOVE "acceptance US12-4 live redstone 30-7 8.3 a TNT block beside power is removed" TO WS-CASE
     MOVE "air" TO WS-EXP
     PERFORM ASSERT-KEY
     PERFORM COUNT-TNT
     COMPUTE WS-COUNT = WS-COUNT - WS-BEFORE
     MOVE "acceptance US12-4 live redstone 30-7 8.2 and 8.3 and a primed TNT entity appears in its place" TO WS-CASE
     MOVE "1" TO WS-EXP
     MOVE WS-COUNT TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   TNT placed beside permanent power ignites on placement (onPlace)
     PERFORM COUNT-TNT
     MOVE WS-COUNT TO WS-BEFORE
     MOVE 4 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X MOVE "tnt" TO WS-K MOVE "unstable=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE "acceptance US12-4 live redstone 30-7 8.3 TNT placed beside power is removed by its onPlace" TO WS-CASE
     MOVE "air" TO WS-EXP
     PERFORM ASSERT-KEY
     PERFORM COUNT-TNT
     COMPUTE WS-COUNT = WS-COUNT - WS-BEFORE
     MOVE "acceptance US12-4 live redstone 30-7 8.3 and it primed one TNT entity" TO WS-CASE
     MOVE "1" TO WS-EXP
     MOVE WS-COUNT TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   G. placement beside power (z 12 to 18): the lamp, the trapdoor, the gate and the door start lit or open
     MOVE 12 TO WS-Z
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE "redstone_lamp" TO WS-K
     PERFORM FIND-ITEM
     PERFORM PLACE-ITEM
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     MOVE "acceptance US12-4 live redstone 30-7 6 step 1 a lamp placed beside power is lit" TO WS-CASE
     MOVE "lit=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 14 TO WS-Z
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE "oak_trapdoor" TO WS-K
     PERFORM FIND-ITEM
     PERFORM PLACE-ITEM
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-OPEN-POWERED
     MOVE "acceptance US12-4 live redstone 30-7 4.2 step 4 a trapdoor placed beside power is open and powered" TO WS-CASE
     MOVE "true,true" TO TL-EXPECTED
     PERFORM ASSERT-OP
     MOVE 16 TO WS-Z
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE "oak_fence_gate" TO WS-K
     PERFORM FIND-ITEM
     PERFORM PLACE-ITEM
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-OPEN-POWERED
     MOVE "acceptance US12-4 live redstone 30-7 5.2 step 1 a fence gate placed beside power is open and powered" TO WS-CASE
     MOVE "true,true" TO TL-EXPECTED
     PERFORM ASSERT-OP
     MOVE 18 TO WS-Z
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE "oak_door" TO WS-K
     PERFORM FIND-ITEM
     PERFORM PLACE-ITEM
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-OPEN-POWERED
     MOVE "acceptance US12-4 live redstone 30-7 3.3 step 2 a door placed beside power is open and powered" TO WS-CASE
     MOVE "true,true" TO TL-EXPECTED
     PERFORM ASSERT-OP
     MOVE 102 TO WS-Y
     PERFORM READ-OPEN-POWERED
     MOVE "acceptance US12-4 live redstone 30-7 3.3 step 4 and so is the upper half" TO WS-CASE
     MOVE "true,true" TO TL-EXPECTED
     PERFORM ASSERT-OP
*>   H. a door placed with the signal only beside its upper cell (z 22) is open and powered (3.3 step 2)
     MOVE 22 TO WS-Z
     MOVE 4 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE "oak_door" TO WS-K
     PERFORM FIND-ITEM
     PERFORM PLACE-ITEM
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-OPEN-POWERED
     MOVE "acceptance US12-4 live redstone 30-7 3.3 step 2 a door placed where only the cell above has a signal is open and powered" TO WS-CASE
     MOVE "true,true" TO TL-EXPECTED
     PERFORM ASSERT-OP
*>   I. placing a block that follows no signal changes nothing about it (z 20)
     MOVE 20 TO WS-Z
     MOVE "stone" TO WS-K
     PERFORM FIND-ITEM
     PERFORM PLACE-ITEM
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     MOVE "acceptance US12-4 live redstone 30-7 placement of an unrelated block (stone) is untouched" TO WS-CASE
     MOVE "stone" TO WS-EXP
     PERFORM ASSERT-KEY
     STOP RUN.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 PLACE-ITEM.
*>   the creative player holds WS-ITEM and clicks the top of the floor block at x 3 of row WS-Z, standing above it
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-ROW, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 1)
     MOVE 0 TO PL-HELD(WS-ROW)
     COMPUTE WS-PX = 3 + 0.5
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 104.0 TO PL-Y(WS-ROW)
     COMPUTE WS-PX = WS-Z + 0.5
     MOVE WS-PX TO PL-Z(WS-ROW)
     MOVE 3 TO WS-X
     MOVE 100 TO WS-Y
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 READ-OPEN-POWERED.
*>   "open,powered" of the block at (WS-X, WS-Y, WS-Z)
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "open" TO WS-OP-NAME
     CALL "SW-SET-PROP" USING WS-STATE WS-OP-NAME WS-OP-KEEP WS-OP-NEW WS-OP-A
     MOVE "powered" TO WS-OP-NAME
     CALL "SW-SET-PROP" USING WS-STATE WS-OP-NAME WS-OP-KEEP WS-OP-NEW WS-OP-B
     MOVE SPACES TO WS-PROPS
     STRING FUNCTION TRIM(WS-OP-A) "," FUNCTION TRIM(WS-OP-B) DELIMITED BY SIZE INTO WS-PROPS.

 ASSERT-OP.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 PUT-BLOCK.
*>   the block of key WS-K and property pairs WS-PR at (WS-X, WS-Y, WS-Z), written with flags 3
     CALL "PT-STATE" USING WS-K WS-PR WS-ST
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 ASSERT-PROPS.
*>   the property text of the block at (WS-X, WS-Y, WS-Z) against WS-EXP
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ASSERT-KEY.
*>   the bare key of the block at (WS-X, WS-Y, WS-Z) against WS-EXP
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) TO WS-K
     CALL "KEY-BARE" USING WS-K WS-BARE
     MOVE WS-BARE TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 COUNT-TNT.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = WS-TNT-TYPE
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM.

 END PROGRAM ACC-F2US12-REDSTONE-OPENERS.

 COPY CORETEST.
 COPY PORTALTEST.
