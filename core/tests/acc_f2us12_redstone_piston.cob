*> Acceptance test (T29510..T29519, US12-4; docs/protocol/30-redstone-3-pistons.md sections 2 to 7, 9.3): the pistons of the level. Power (section 2.2, 12.6) queues the block event, the event runs
*> moveBlocks (6): the pushed blocks become moving_piston with a block entity, the head arrives, the timeline of 7.2 (progress 0.5 on the event tick, 1.0 after, the blocks placed on the third tick), the
*> push limit of 12 (12.2), immovable and block entity blocks (5.1), POPPED blocks destroyed (12.3), slime and honey (12.4), the sticky piston pulling (12.5) and a plain piston leaving the block,
*> the head that cannot survive. Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-PISTON.
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
 01 WS-IDS                 PIC X(1024).
 01 WS-HITS                BINARY-LONG.
 01 WS-BE3                 BINARY-LONG.
 01 WS-TNT-TYPE            BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-KEY112              PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-TNT-BEFORE          BINARY-LONG.
 01 WS-FACE                BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CODE                BINARY-LONG.
 01 WS-FACE-N              BINARY-LONG.
 01 WS-FLAG-N              BINARY-LONG.
 01 WS-TYPE-N              BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-KEYN                PIC X(48).
 01 WS-EXP-TMP             PIC X(160).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone piston: no generated packs here, skipped" TO TL-CASE
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
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 16
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
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO PL-MODE(WS-ROW)
     MOVE 0 TO WS-Z
     PERFORM DRAIN
*>   12.1 simple extension: piston east at x 1, stone at x 2, air at x 3, a redstone block behind at x 0
     MOVE 0 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
     MOVE 2 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     PERFORM DRAIN
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.1 the piston is extended after the event tick" TO WS-CASE
     MOVE "piston:extended=true,facing=east" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 2 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.1 the head is a moving block, with the stone moving to x 3" TO WS-CASE
     MOVE "moving_piston:facing=east,type=normal" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 3 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.1 and so is the cell the stone moves into" TO WS-CASE
     MOVE "moving_piston:facing=east,type=normal" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 2 TO WS-X
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE 0 TO WS-P
     IF WS-BE > 0
         IF BE-TYPE(WS-BE) = 11
             MOVE 1 TO WS-P
         END-IF
     END-IF
     MOVE "acceptance US12-4 pistons 30-3 7 a moving block entity (type 11) holds the head" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     PERFORM DRAIN
     MOVE 0 TO WS-HITS
     INSPECT WS-IDS TALLYING WS-HITS FOR ALL " 7 "
     MOVE WS-HITS TO WS-P
     IF WS-P > 0
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 pistons 30-3 3.2 the event reaches the viewers as a Block Event (7)" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.1 on the third tick the head is placed" TO WS-CASE
     MOVE "piston_head:facing=east,short=false,type=normal" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 3 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.1 and the stone is placed at x 3" TO WS-CASE
     MOVE "stone:" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.1 x 4 stays air" TO WS-CASE
     MOVE "air:" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   3.2 types 1 and 0: the power goes, a plain piston retracts and leaves the stone
     MOVE 0 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 3.2 a retracted plain piston" TO WS-CASE
     MOVE "piston:extended=false,facing=east" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 2 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 3.2 the head is gone" TO WS-CASE
     MOVE "air:" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 3 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 3.2 a plain piston leaves the stone where it is" TO WS-CASE
     MOVE "stone:" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   12.5 a sticky piston pulls the stone back
     MOVE 3 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 1 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
     MOVE 2 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.5 the sticky head is placed (sticky type)" TO WS-CASE
     MOVE "piston_head:facing=east,short=false,type=sticky" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 0 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.5 the sticky piston is retracted" TO WS-CASE
     MOVE "sticky_piston:extended=false,facing=east" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 2 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.5 and the stone it pushed is pulled back to x 2" TO WS-CASE
     MOVE "stone:" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 3 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.5 x 3 is empty again" TO WS-CASE
     MOVE "air:" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   12.2 the push limit: 12 stones move, 13 do not
     MOVE 6 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
     PERFORM VARYING WS-NX FROM 2 BY 1 UNTIL WS-NX > 13
         MOVE WS-NX TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     END-PERFORM
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.2 a piston pushes 12 stones: extended" TO WS-CASE
     MOVE "piston:extended=true,facing=east" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 14 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.2 the 12th stone is at x 14" TO WS-CASE
     MOVE "stone:" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 9 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
     PERFORM VARYING WS-NX FROM 2 BY 1 UNTIL WS-NX > 14
         MOVE WS-NX TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     END-PERFORM
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.2 13 stones are too many: the piston stays retracted" TO WS-CASE
     MOVE "piston:extended=false,facing=east" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   5.1 immovable obsidian and a chest (block entity) in front: no extension
     MOVE 12 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
     MOVE 2 TO WS-X MOVE "obsidian" TO WS-K PERFORM PUT-DEF
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 5.1 obsidian is immovable: no extension" TO WS-CASE
     MOVE "piston:extended=false,facing=east" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 15 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
     MOVE 2 TO WS-X MOVE "chest" TO WS-K PERFORM PUT-DEF
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 5.1 a chest (block entity) cannot move: no extension" TO WS-CASE
     MOVE "piston:extended=false,facing=east" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   12.3 a torch at the start cell is destroyed, the head moves in
     MOVE 18 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
     MOVE 2 TO WS-X MOVE "torch" TO WS-K PERFORM PUT-DEF
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.3 the torch is destroyed and the head is placed" TO WS-CASE
     MOVE "piston_head:facing=east,short=false,type=normal" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   12.4 a slime block drags the stone above it, not honey beside it
     MOVE 21 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
*>   (the floor under the slime and the block it moves to is taken away: a slime block drags every neighbour, the floor included)
     MOVE 100 TO WS-Y MOVE "air" TO WS-K
     MOVE 2 TO WS-X PERFORM PUT-DEF
     MOVE 3 TO WS-X PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     MOVE 2 TO WS-X MOVE "slime_block" TO WS-K PERFORM PUT-DEF
     MOVE 102 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
     ADD 1 TO WS-Z
     MOVE "honey_block" TO WS-K PERFORM PUT-DEF
     SUBTRACT 1 FROM WS-Z
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.4 the slime block moves to x 3" TO WS-CASE
     MOVE "slime_block:" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 102 TO WS-Y PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.4 and drags the stone above it" TO WS-CASE
     MOVE "stone:" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 101 TO WS-Y
     MOVE 2 TO WS-X
     ADD 1 TO WS-Z
     PERFORM READ-FULL
     SUBTRACT 1 FROM WS-Z
     MOVE "acceptance US12-4 pistons 30-3 12.4 honey beside slime is not dragged" TO WS-CASE
     MOVE "honey_block:" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   12.6 quasi-connectivity: a redstone block two cells above powers the piston; one in front does not
     MOVE 24 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
     MOVE 103 TO WS-Y MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 101 TO WS-Y
*>   (the block two above does not tell the piston: a block update beside the piston makes it check)
     ADD 1 TO WS-Z MOVE "stone" TO WS-K PERFORM PUT-DEF
     SUBTRACT 1 FROM WS-Z
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.6 a redstone block two cells above powers the piston" TO WS-CASE
     MOVE "piston:extended=true,facing=east" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 27 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 12.6 a redstone block in front does not power it" TO WS-CASE
     MOVE "piston:extended=false,facing=east" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   9.3 the head loses its base: it becomes air
     MOVE 0 TO WS-Z
     MOVE 1 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 9.3 a head whose base is gone becomes air" TO WS-CASE
     MOVE "air:" TO WS-EXP
     PERFORM ASSERT-PROPS
     STOP RUN.

 PUT-STONE-ROW.
*>   clears the row of z WS-Z (x 0 to 15, y 101 to 103) to air
     PERFORM VARYING WS-NX FROM 0 BY 1 UNTIL WS-NX > 15
         MOVE WS-NX TO WS-X
         PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 103
             MOVE "air" TO WS-K
             PERFORM PUT-DEF
         END-PERFORM
     END-PERFORM
     MOVE 101 TO WS-Y.

 PUT-PISTON.
*>   the piston state of code WS-CODE, facing WS-FACE-N, flag WS-FLAG-N, type WS-TYPE-N at (WS-X, 101, WS-Z)
     MOVE 101 TO WS-Y
     CALL "PST-STATE-OF" USING WS-CODE WS-FACE-N WS-FLAG-N WS-TYPE-N WS-ST
     PERFORM PUT-ST.

 READ-FULL.
*>   WS-PROPS = block key, ":" and the properties of the cell at (WS-X, WS-Y, WS-Z)
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS
     CALL "KEY-BARE" USING CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) WS-KEYN
     MOVE SPACES TO WS-EXP-TMP
     STRING FUNCTION TRIM(WS-KEYN) ":" FUNCTION TRIM(WS-PROPS) DELIMITED BY SIZE INTO WS-EXP-TMP
     MOVE WS-EXP-TMP TO WS-PROPS.

 DRAIN.
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-IDS.

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

 END PROGRAM ACC-F2US12-REDSTONE-PISTON.

 COPY CORETEST.
 COPY PORTALTEST.
