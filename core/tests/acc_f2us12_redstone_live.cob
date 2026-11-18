*> Acceptance test (T19000..T19010, US12-4; docs/protocol/30-redstone-1 sections 2.3, 5, 8, 30-2 sections 2 to 4, 30-5 sections 2 and 3): circuits built in a live world behave as the
*> documents say. A lever strongly powers the stone block it hangs on and a redstone torch standing on that block turns off two ticks later and back on when the lever is pulled again, the
*> wire beside the torch follows; a stone button powers a wire beside its block and releases after 20 ticks; a repeater delays its input by its delay and a repeater powered from the side
*> locks the one beside it; a comparator in compare mode passes the input and in subtract mode a side input of the same strength blocks it; wire climbs a conductor and comes down the
*> other side losing 1 per step; a torch toggled 8 times within 60 ticks burns out (level event 1502) and relights 160 ticks later. Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-LIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-J2                  BINARY-LONG VALUE 0.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-TICKS               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-WIRE-BLOCK          BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-LINE                PIC X(1100).
 01 WS-TEXT                PIC X(4096).
 01 WS-PROPS               PIC X(160).
 01 WS-HITS                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 live redstone: no generated packs here, skipped" TO TL-CASE
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
*>   a stone floor at y 100 and clear air at y 101 to 103 for x 0 to 6, z 0 to 30
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 30
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

*>   A. lever -> stone block -> torch on top -> wire beside the torch (z 0): lever at x 2 hangs on the block at x 3, the torch stands on it, the wire at x 4 y 102 on a stone block
     MOVE 0 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "stone" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE 101 TO WS-Y PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "lever" TO WS-K MOVE "face=wall,facing=west,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_torch" TO WS-K MOVE "lit=true" TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 4 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 8.3 a lit torch beside wire powers it: the wire power is 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 2 TO WS-X MOVE 101 TO WS-Y
     PERFORM USE-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 2.3 and 8.3 a pulled lever strongly powers the block it hangs on and the torch on that block turns off within 3 ticks" TO TL-CASE
     MOVE "lit=false" TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 8.2 the unlit torch stops powering the wire beside it: the power is 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 2 TO WS-X MOVE 101 TO WS-Y
     PERFORM USE-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 8.3 the lever pulled back: the torch lights again" TO TL-CASE
     MOVE "lit=true" TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 8.2 the relit torch powers the wire again: 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER
*>   a powered lever that is removed tells its neighbours (30-5 2.3): the torch lights again; a removed torch stops powering its wire (8.2)
     MOVE 2 TO WS-X MOVE 101 TO WS-Y
     PERFORM USE-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 2.3 a powered lever removed from the world: the block it powered falls back and the torch on it lights" TO TL-CASE
     MOVE "lit=true" TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 8.2 a torch removed from the world tells its neighbours: the wire beside it falls to 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER

*>   B. stone button -> stone block -> wire beside the block (z 2): 15 while pressed, 0 after the 20 ticks of the stone button
     MOVE 2 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "stone" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "stone_button" TO WS-K MOVE "face=wall,facing=west,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 3.2 an unpressed button gives no power: the wire beside its block is 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 2 TO WS-X MOVE 101 TO WS-Y
     PERFORM USE-BLOCK
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 3.3 and 3.7 a pressed button strongly powers its block and the wire beside it: 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 22 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 3.4 the stone button releases after 20 ticks and the wire falls back to 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER

*>   C. a repeater of delay 1 (z 4): the redstone block at x 0 feeds it from the west, the wire at x 2 and 3 follows
     MOVE 4 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X MOVE 101 TO WS-Y PERFORM PUT-BLOCK
     MOVE 0 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE 101 TO WS-Y MOVE "repeater" TO WS-K MOVE "delay=1,facing=west,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 2.3 a repeater placed on a live input has not powered its output yet: the wire is 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-X FROM 2 BY 1 UNTIL WS-X > 3
         PERFORM READ-WIRE
         PERFORM ADD-POWER
     END-PERFORM
     MOVE "acceptance US12-4 live redstone 2.4 the repeater powers its output side after its tick: the wires are 15 and 14" TO TL-CASE
     MOVE "15 14" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 3.2 the repeater keeps its output for its delay after the input drops: the wire is still 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 2.4 after its delay of 2 ticks the repeater turns off and the wire is 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 1 TO WS-X
     PERFORM USE-BLOCK
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 3.6 using a repeater cycles its delay: 1 becomes 2" TO TL-CASE
     MOVE "delay=2" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "delay=2"
     IF WS-HITS = 1
         MOVE "delay=2" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   C2. a repeater of delay 4 (z 6): still on 5 ticks after the input drops, off after 10
     MOVE 6 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 0 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE 101 TO WS-Y MOVE "repeater" TO WS-K MOVE "delay=4,facing=west,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 0 TO WS-X MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 3.2 a repeater of delay 4 waits 8 ticks: 5 ticks after the input dropped the wire is still 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 3.2 and 2.4 10 ticks after the input dropped the delay 4 repeater is off and the wire is 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER

*>   D. the lock (z 8): a repeater at x 3 facing west, a side repeater at z 7 facing north powered from z 6
     MOVE 8 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "repeater" TO WS-K MOVE "delay=1,facing=west,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 7 TO WS-Z
     MOVE "repeater" TO WS-K MOVE "delay=1,facing=north,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 6 TO WS-Z
     MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 8 TO WS-Z
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 3.4 and 3.5 a powered repeater facing a repeater from its side locks it: locked=true" TO TL-CASE
     MOVE "true" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "locked=true"
     IF WS-HITS = 1
         MOVE "true" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 3.4 a locked repeater ignores its input: powered=false" TO TL-CASE
     MOVE "false" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "powered=false"
     IF WS-HITS = 1
         MOVE "false" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   E. a comparator (z 12): compare passes the input, a side input of the same strength in subtract mode blocks it
     MOVE 12 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X PERFORM PUT-BLOCK
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE "comparator" TO WS-K MOVE "facing=west,mode=compare,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-X FROM 2 BY 1 UNTIL WS-X > 3
         PERFORM READ-WIRE
         PERFORM ADD-POWER
     END-PERFORM
     MOVE "acceptance US12-4 live redstone 4.3 a comparator in compare mode passes its input of 15: the wires are 15 and 14" TO TL-CASE
     MOVE "15 14" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 11 TO WS-Z MOVE 1 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 12 TO WS-Z
     PERFORM USE-BLOCK
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 4.3 and 4.6 subtract mode with a side input of 15 and an input of 15 gives 0: the wire is 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 1 TO WS-X
     PERFORM USE-BLOCK
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 4.3 back in compare mode the input 15 is not above the side 15 but equal: the output is 15 again" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER
*>   in subtract mode a tick that finds the output unchanged does nothing (4.5 step 3)
     MOVE 1 TO WS-X
     PERFORM USE-BLOCK
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-STATE-BLOCK
     CALL "RL-DIODE-TICK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE WS-BLOCK
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 4.5 a subtract comparator whose output did not change keeps it on a tick: the wire stays 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER

*>   F. wire climbs a conductor and comes down (z 16): block at x 1, wire at x 2 (y 101), wire on the step at x 3 (y 102), wire at x 4 (y 101)
     MOVE 16 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "stone" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE "redstone_wire" TO WS-K PERFORM PUT-BLOCK
     MOVE 4 TO WS-X PERFORM PUT-BLOCK
     MOVE 3 TO WS-X MOVE 102 TO WS-Y PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE SPACES TO TL-OBSERVED
     MOVE 2 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     PERFORM ADD-POWER
     MOVE 3 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-WIRE
     PERFORM ADD-POWER
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     PERFORM ADD-POWER
     MOVE "acceptance US12-4 live redstone 5.2 and 5.4 wire goes up on a conductor and down the other side losing 1 per step: 15 14 13" TO TL-CASE
     MOVE "15 14 13" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-4 live redstone 5.2 the wire before the step connects up to the wire on it: its east side is 0 (up)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-E TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     MOVE 1 TO WS-X
     MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE SPACES TO TL-OBSERVED
     MOVE 2 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     PERFORM ADD-POWER
     MOVE 3 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-WIRE
     PERFORM ADD-POWER
     MOVE 4 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     PERFORM ADD-POWER
     MOVE "acceptance US12-4 live redstone 5.5 removing the source returns the wires below, on and beside the step to 0: 0 0 0" TO TL-CASE
     MOVE "0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   L. wire beside a hopper and a trapdoor (z 14 and 15): the wire on the hopper takes the power of the wire beside it, 15 then 14
     MOVE 14 TO WS-Z
     MOVE 1 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE "hopper" TO WS-K PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_wire" TO WS-K PERFORM PUT-BLOCK
     MOVE 0 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     PERFORM ADD-POWER
     MOVE 2 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-WIRE
     PERFORM ADD-POWER
     MOVE "acceptance US12-4 live redstone 5.2 wire climbs to a wire on a hopper (a hopper supports wire): 15 14" TO TL-CASE
     MOVE "15 14" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 15 TO WS-Z
     MOVE 1 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE "oak_trapdoor" TO WS-K PERFORM PUT-BLOCK
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE 1 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 5.2 a trapdoor beside wire does not break it: the wire still takes 15 from the block" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER

*>   H. a torch powers the block above it (30-1 8.3): the lit torch under a block turns off the wall torch on the side of that block, and the wire beside the wall torch follows (z 26)
     MOVE 26 TO WS-Z
     MOVE 0 TO WS-X MOVE 101 TO WS-Y MOVE "stone" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE 102 TO WS-Y PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_wall_torch" TO WS-K MOVE "facing=west,lit=true" TO WS-PR PERFORM PUT-BLOCK
     MOVE 0 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE 103 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE 104 TO WS-Y MOVE "air" TO WS-K PERFORM PUT-BLOCK
     MOVE "redstone_torch" TO WS-K MOVE "lit=true" TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X MOVE 104 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 8.3 a lit wall torch strongly powers the block above it: the torch standing on that block is off" TO TL-CASE
     MOVE "lit=false" TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 8.3 a lit wall torch powers the wire beside it (not the block it hangs on): 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_torch" TO WS-K MOVE "lit=true" TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 8.3 a torch strongly powers the block above it and the wall torch hanging on that block turns off" TO TL-CASE
     MOVE "lit=false" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "lit=false"
     IF WS-HITS = 1
         MOVE "lit=false" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 8.2 the unlit wall torch stops powering its wire: 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER

*>   I. two repeaters in a row (z 28): the chain passes the signal and drops it again; a powered repeater removed tells its front
     MOVE 28 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE "repeater" TO WS-K MOVE "delay=1,facing=west,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X PERFORM PUT-BLOCK
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 4
         PERFORM READ-WIRE
         PERFORM ADD-POWER
     END-PERFORM
     MOVE "acceptance US12-4 live redstone 2.3 a chain of two repeaters passes the signal on: the wires after it are 15 and 14" TO TL-CASE
     MOVE "15 14" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X MOVE "air" TO WS-K PERFORM PUT-BLOCK
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-X FROM 3 BY 1 UNTIL WS-X > 4
         PERFORM READ-WIRE
         PERFORM ADD-POWER
     END-PERFORM
     MOVE "acceptance US12-4 live redstone 2.4 the chain turns off again after the input is gone: the wires are 0 and 0" TO TL-CASE
     MOVE "0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X MOVE "air" TO WS-K PERFORM PUT-BLOCK
     MOVE 3 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 2.5 a powered repeater removed from the world tells its front: the wire it fed is 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER

*>   J. a pulse shorter than the delay (z 30): the input is gone before the repeater ticks, yet it turns on for one more delay (2.4 step 4) and then off
     MOVE 30 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE "repeater" TO WS-K MOVE "delay=1,facing=west,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE "air" TO WS-K PERFORM PUT-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 2.4 a repeater whose input vanished before its tick still pulses: the wire is 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 2.4 and the pulse ends by itself: the wire is 0" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM SHOW-POWER

*>   K. a repeater locked before its tick ignores the tick (3.4): delay 4 gives the side repeater time to lock it (x 5, z 20 to 22)
     MOVE 22 TO WS-Z
     MOVE 5 TO WS-X MOVE 101 TO WS-Y MOVE "repeater" TO WS-K MOVE "delay=4,facing=west,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 21 TO WS-Z MOVE 5 TO WS-X MOVE "repeater" TO WS-K MOVE "delay=1,facing=north,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 20 TO WS-Z MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 22 TO WS-Z
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 3.4 a repeater locked before its tick keeps its powered value: locked and unpowered" TO TL-CASE
     MOVE "locked=true powered=false" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "locked=true"
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "powered=false"
     IF WS-HITS = 2
         MOVE "locked=true powered=false" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   M. wire feeding a repeater and a conductor (z 13 and 17): the repeater reads the wire's power, a wire pointing at a stone block powers the torch standing on it off; a lever powers a wire beside it
     MOVE 13 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE "redstone_wire" TO WS-K PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE "repeater" TO WS-K MOVE "delay=1,facing=west,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 5 TO WS-X MOVE "repeater" TO WS-K MOVE "delay=1,facing=east,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 6 TO WS-X MOVE "repeater" TO WS-K MOVE "delay=1,facing=south,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 2.2 a repeater reads the wire in front of its input side: the wire behind it carries 14 and the one after it is 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 17 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "stone" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_torch" TO WS-K MOVE "lit=true" TO WS-PR PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 2.3 and 5.6 a wire pointing at a stone block powers it: the torch standing on the block turns off" TO TL-CASE
     MOVE "lit=false" TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 18 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE "lever" TO WS-K MOVE "face=floor,facing=north,powered=true" TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 2.1 a powered lever gives weak power to the wire beside it: 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER

*>   N. a comparator placed before its input (z 29): the neighbour change schedules its tick, a torch and a wire on its sides are read as side inputs
     MOVE 29 TO WS-Z
     MOVE 5 TO WS-X MOVE 101 TO WS-Y MOVE "comparator" TO WS-K MOVE "facing=west,mode=compare,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 28 TO WS-Z MOVE "redstone_torch" TO WS-K MOVE "lit=true" TO WS-PR PERFORM PUT-BLOCK
     MOVE 30 TO WS-Z MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 29 TO WS-Z MOVE 4 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 5 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 4.4 a comparator placed first turns on after its input appears: powered=true" TO TL-CASE
     MOVE "powered=true" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "powered=true"
     IF WS-HITS = 1
         MOVE "powered=true" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   O. other hook kinds are ignored, a trapdoor opens by use (z 15)
     MOVE 15 TO WS-Z
     MOVE 1 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-WIRE
     MOVE 8 TO WS-I
     MOVE 0 TO WS-J
     CALL "REDSTONE-HOOK" USING WS-I WS-DIM WS-X WS-Y WS-Z WS-STATE WS-J WS-J2 WS-ID
     MOVE WS-P TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone a random tick is not a redstone hook: the wire keeps its power 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER
     MOVE 2 TO WS-X
     PERFORM USE-BLOCK
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-7 using a trapdoor opens it: open=true" TO TL-CASE
     MOVE "open=true" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "open=true"
     IF WS-HITS = 1
         MOVE "open=true" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   P. a wire on a stone block powers the wall torch hanging on the side of that block (z 19): wire power reaches the block from above (30-1 5.6)
     MOVE 19 TO WS-Z
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "stone" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X MOVE "redstone_wall_torch" TO WS-K MOVE "facing=east,lit=true" TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 1 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-BLOCK
     MOVE 4 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 5.6 a powered wire on a block powers the block (asked with UP): the wall torch on its side turns off" TO TL-CASE
     MOVE "lit=false" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 0 TO WS-HITS
     INSPECT WS-PROPS TALLYING WS-HITS FOR ALL "lit=false"
     IF WS-HITS = 1
         MOVE "lit=false" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Q. a comparator feeding a repeater is prioritised (z 27)
     MOVE 27 TO WS-Z
     MOVE 5 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_wire" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 4 TO WS-X MOVE "repeater" TO WS-K MOVE "delay=1,facing=west,locked=false,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X MOVE "comparator" TO WS-K MOVE "facing=west,mode=compare,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 5 TO WS-X
     PERFORM READ-WIRE
     MOVE "acceptance US12-4 live redstone 4.4 a comparator that feeds a repeater passes the signal through it: the wire after it is 15" TO TL-CASE
     MOVE "15" TO TL-EXPECTED
     PERFORM SHOW-POWER

*>   G. burnout (z 20): the torch of row A's layout toggled 8 times within 60 ticks stays off, level event 1502 goes out, and 160 ticks later it relights
     MOVE 20 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "stone" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 2 TO WS-X MOVE "lever" TO WS-K MOVE "face=wall,facing=west,powered=false" TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_torch" TO WS-K MOVE "lit=true" TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         MOVE 2 TO WS-X MOVE 101 TO WS-Y
         PERFORM USE-BLOCK
         MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
         PERFORM USE-BLOCK
         MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     END-PERFORM
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE 0 TO WS-HITS
     MOVE SPACES TO WS-LINE
     STRING " " FUNCTION TRIM(WS-TEXT(1:1024)) " " DELIMITED BY SIZE INTO WS-LINE
     INSPECT WS-LINE TALLYING WS-HITS FOR ALL " 47 "
     MOVE 3 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12 30-1§8.3 Redstone torches: after 7 flips the torch is lit again and no burnout effect went out" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-HITS TO WS-ED
     STRING FUNCTION TRIM(WS-PROPS) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "lit=true 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-X MOVE 101 TO WS-Y
     PERFORM USE-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE 0 TO WS-HITS
     MOVE SPACES TO WS-LINE
     STRING " " FUNCTION TRIM(WS-TEXT(1:1024)) " " DELIMITED BY SIZE INTO WS-LINE
     INSPECT WS-LINE TALLYING WS-HITS FOR ALL " 47 "
     PERFORM USE-BLOCK
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12 30-1§8.3 Redstone torches: the 8th toggle within 60 ticks burns the torch out: it stays unlit after the lever is back and a Level Event (47) went out" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-HITS TO WS-ED
     STRING FUNCTION TRIM(WS-PROPS) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "lit=false 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 160 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 3 TO WS-X MOVE 102 TO WS-Y
     PERFORM READ-PROPS
     MOVE "acceptance US12 30-1§8.3 Redstone torches: the retry tick 160 ticks after the burnout relights the torch" TO TL-CASE
     MOVE "lit=true" TO TL-EXPECTED
     MOVE WS-PROPS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 PUT-BLOCK.
*>   the block of key WS-K and property pairs WS-PR at (WS-X, WS-Y, WS-Z), written with flags 3
     CALL "PT-STATE" USING WS-K WS-PR WS-ST
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 USE-BLOCK.
*>   a right click on the block at (WS-X, WS-Y, WS-Z) by the creative player standing above it
     COMPUTE WS-PX = WS-X + 0.5
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 104.0 TO PL-Y(WS-ROW)
     COMPUTE WS-PX = WS-Z + 0.5
     MOVE WS-PX TO PL-Z(WS-ROW)
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ.

 READ-PROPS.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS.

 READ-STATE-BLOCK.
*>   the state at (WS-X, WS-Y, WS-Z) and its block id
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK.

 READ-WIRE.
*>   the sides and the power of the wire at (WS-X, WS-Y, WS-Z): the state is the wire's first state id plus the index of 30-1 4.3
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-N WS-E WS-S WS-W WS-P
     IF CB-S-BLOCK(WS-STATE + 1) = WS-WIRE-BLOCK - 1
         COMPUTE WS-ID = WS-STATE - CB-FIRST-STATE(WS-WIRE-BLOCK) + 5567
         CALL "RS1-WIRE-DECODE" USING WS-ID WS-N WS-E WS-S WS-W WS-P
     ELSE
         MOVE -1 TO WS-P
     END-IF.

 SHOW-POWER.
     MOVE WS-P TO WS-ED
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 ADD-POWER.
     MOVE WS-P TO WS-ED
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     ELSE
         MOVE TL-OBSERVED TO WS-LINE
         STRING FUNCTION TRIM(WS-LINE) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 END PROGRAM ACC-F2US12-REDSTONE-LIVE.

 COPY CORETEST.
 COPY PORTALTEST.
