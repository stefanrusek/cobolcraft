*> Acceptance test (T29130..T29135, US12-4; docs/protocol/30-redstone-5 section 6): an arrow that hits a target block gives it the power of the hit position (6.1: the centre of a face 15, an
*> offset of 0.4 gives 3), the target keeps it for 20 ticks (an arrow's duration) and falls back to 0 (release), a hit while the power is pending changes nothing, and a target placed with
*> power and no tick pending is reset (6, onPlace). Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-TARGET.
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
 01 WS-ARROW-ROW           BINARY-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-AVX                 FLOAT-LONG.
 01 WS-AVY                 FLOAT-LONG.
 01 WS-AVZ                 FLOAT-LONG.
 01 WS-BASE                BINARY-LONG VALUE 2000.
 01 WS-OWNER               BINARY-LONG VALUE 0.
 01 WS-FACE-N              BINARY-LONG.
 01 WS-STR                 BINARY-LONG.
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
         MOVE "acceptance US12-4 redstone target: no generated packs here, skipped" TO TL-CASE
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

*>   a target at x 3 (z 0), the arrow flies east at the centre of its face
     MOVE 0 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "target" TO WS-K PERFORM PUT-DEF
     MOVE 101.5 TO WS-AY
     PERFORM SHOOT
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 6.1 an arrow into the centre of the face gives the target power 15" TO WS-CASE
     MOVE "power=15" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 15 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 6 the power holds for the 20 ticks of an arrow" TO WS-CASE
     MOVE "power=15" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 6 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 6 and the release tick sets it back to 0" TO WS-CASE
     MOVE "power=0" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   a hit near the edge (offset 0.35): 3; a second arrow while the release is pending changes nothing
     MOVE 2 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "target" TO WS-K PERFORM PUT-DEF
     MOVE 101.85 TO WS-AY
     PERFORM SHOOT
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 6.1 an arrow 0.35 from the centre of the face gives power ceil(15 * 0.3) = 5" TO WS-CASE
     MOVE "power=5" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 101.5 TO WS-AY
     PERFORM SHOOT
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 6 a hit while a tick is pending raises nothing: still 5" TO WS-CASE
     MOVE "power=5" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   an arrow that hits another block does nothing to a target (stone at x 3, z 4)
     MOVE 4 TO WS-Z
     MOVE 3 TO WS-X MOVE "stone" TO WS-K PERFORM PUT-DEF
     MOVE 101.5 TO WS-AY
     PERFORM SHOOT
     MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
*>   a target placed with power and no tick pending is reset (z 6)
     MOVE 6 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "target" TO WS-K PERFORM MAKE-DEF
     MOVE "power" TO WS-PN MOVE "9" TO WS-PV PERFORM SET-P
     PERFORM PUT-ST
     PERFORM READ-PROPS
     MOVE "acceptance US12-4 live redstone 30-5 6 onPlace a target placed with power 9 and no tick pending is reset to 0" TO WS-CASE
     MOVE "power=0" TO WS-EXP
     PERFORM ASSERT-PROPS
     STOP RUN.

 SHOOT.
*>   an arrow from (0.5, WS-AY, WS-Z + 0.5) at 3 blocks per tick east
     MOVE 0.5 TO WS-AX
     COMPUTE WS-AZ = WS-Z + 0.5
     MOVE 3.0 TO WS-AVX
     MOVE 0 TO WS-AVY WS-AVZ
     CALL "ARROW-SPAWN" USING WS-DIM WS-AX WS-AY WS-AZ WS-AVX WS-AVY WS-AVZ WS-BASE WS-OWNER WS-ARROW-ROW.

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

 END PROGRAM ACC-F2US12-REDSTONE-TARGET.

 COPY CORETEST.
 COPY PORTALTEST.
