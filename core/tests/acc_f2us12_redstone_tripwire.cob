*> Acceptance test (T29100..T29110, US12-4; docs/protocol/30-redstone-8 section 7): tripwire hooks and tripwire. Two hooks facing each other with two wires between them become attached
*> when the second hook is placed (7.3), a player standing on a wire powers both hooks (7.5), a powered hook strongly powers the block it hangs on (7.2), the hooks release when the player has
*> left and the 10 tick check finds nothing, and cutting a wire detaches both hooks (7.5 removal). Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-TRIPWIRE.
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
 01 WS-BEFORE              BINARY-LONG.
 01 WS-TNT-BEFORE          BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone tripwire: no generated packs here, skipped" TO TL-CASE
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

*>   the line of row 0: supports at x 0 and 5, hook A at x 1 facing east, wires at x 2 and 3, hook B at x 4 facing west
     MOVE 0 TO WS-Z
     MOVE 0 TO WS-X MOVE 101 TO WS-Y MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 5 TO WS-X PERFORM PUT-DEF
     MOVE 1 TO WS-X MOVE "tripwire_hook" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "east" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 2 TO WS-X MOVE "tripwire" TO WS-K PERFORM PUT-DEF
     MOVE 3 TO WS-X PERFORM PUT-DEF
     MOVE 1 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.3 a hook with no hook at the end of the line is not attached" TO WS-CASE
     MOVE "attached=false,facing=east,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X MOVE "tripwire_hook" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "west" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.3 the second hook placed completes the line: it is attached" TO WS-CASE
     MOVE "attached=true,facing=west,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 1 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.3 writes step 1 and the far hook is attached too" TO WS-CASE
     MOVE "attached=true,facing=east,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 2 TO WS-X
     MOVE "attached" TO WS-PN
     PERFORM READ-ONE
     MOVE "acceptance US12-4 live redstone 30-8 7.3 writes step 4 the wires between follow: attached" TO WS-CASE
     MOVE "attached=true" TO WS-EXP
     PERFORM ASSERT-PROPS

*>   a player stands on the wire at x 2
     MOVE 2.5 TO PL-X(WS-ROW)
     MOVE 101.0 TO PL-Y(WS-ROW)
     MOVE 0.5 TO PL-Z(WS-ROW)
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 2 TO WS-X
     MOVE "powered" TO WS-PN
     PERFORM READ-ONE
     MOVE "acceptance US12-4 live redstone 30-8 7.5 an entity inside a tripwire wire powers it" TO WS-CASE
     MOVE "powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 1 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.3 the hooks at both ends are powered by it: hook A" TO WS-CASE
     MOVE "attached=true,facing=east,powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.3 and hook B" TO WS-CASE
     MOVE "attached=true,facing=west,powered=true" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 0 TO WS-X MOVE 0 TO WS-D
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-8 7.2 a powered hook strongly powers the block it hangs on (the receiver asks with the facing): 15" TO WS-CASE
     MOVE "15" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 3 TO WS-X
     MOVE 12 TO WS-D
     PERFORM READ-SIGNAL
     MOVE 6 TO WS-X
     PERFORM READ-SIGNAL
     MOVE "acceptance US12-4 live redstone 30-8 7.2 a block on the far side of the other support is strongly powered too (hook B): 15" TO WS-CASE
     MOVE "15" TO WS-EXP
     MOVE 5 TO WS-X MOVE 0 TO WS-D
     PERFORM READ-SIGNAL
     PERFORM ASSERT-POWER
*>   the player leaves: within 11 ticks the wire releases and the hooks follow
     PERFORM PLAYER-AWAY
     MOVE 14 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.5 the player left: the wire released at its check and hook A is unpowered" TO WS-CASE
     MOVE "attached=true,facing=east,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.5 and hook B" TO WS-CASE
     MOVE "attached=true,facing=west,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   cutting the wire at x 3 detaches both hooks after the 10 tick check
     MOVE 3 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 14 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.5 cutting a wire (no shears) and the check that follows: hook A is detached" TO WS-CASE
     MOVE "attached=false,facing=east,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.5 and hook B" TO WS-CASE
     MOVE "attached=false,facing=west,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   removing a hook (7.7)
     MOVE 3 TO WS-X MOVE "tripwire" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 4 TO WS-X MOVE "tripwire_hook" TO WS-K PERFORM MAKE-DEF
     MOVE "facing" TO WS-PN MOVE "west" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     MOVE 1 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.3 the hook placed again re-attaches the line" TO WS-CASE
     MOVE "attached=true,facing=east,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 4 TO WS-X MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 1 TO WS-X
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-8 7.7 a hook removed while attached: the calculation with removing true detaches the other hook" TO WS-CASE
     MOVE "attached=false,facing=east,powered=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     STOP RUN.

 READ-ONE.
*>   WS-PROPS = "name=value" of the property WS-PN of the block at (WS-X, WS-Y, WS-Z)
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "keep" TO WS-PV
     CALL "SW-SET-PROP" USING WS-STATE WS-PN WS-PV WS-ST2 WS-OLD
     MOVE SPACES TO WS-PROPS
     STRING FUNCTION TRIM(WS-PN) "=" FUNCTION TRIM(WS-OLD) DELIMITED BY SIZE INTO WS-PROPS.

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

 END PROGRAM ACC-F2US12-REDSTONE-TRIPWIRE.

 COPY CORETEST.
 COPY PORTALTEST.
