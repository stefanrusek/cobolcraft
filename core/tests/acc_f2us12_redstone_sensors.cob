*> Acceptance test (T29520..T29529, US12-4; docs/protocol/30-redstone-5 sections 5 and 7, 30-redstone-6 section 6): the daylight detector recomputes its power on game ticks that are multiples of 20 and
*> flips `inverted` on use at once (5), the sun angle curve (12 section 3.3), the lightning rod struck by a bolt powers for 8 ticks and sends level event 3002 (7.1, 7.2), the detector rail is pressed by a
*> minecart and released after the cart is gone, with the 20 tick re-check (6.3). Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-SENSORS.
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
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY2                 FLOAT-LONG.
 01 WS-FZ2                 FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-T                   BINARY-DOUBLE.
 01 WS-KIND                BINARY-LONG.
 01 WS-CART                BINARY-LONG.
 01 WS-BOLT                BINARY-LONG.
 01 WS-VISUAL              BINARY-LONG VALUE 0.
 01 WS-ANG-INT             BINARY-LONG.
 01 WS-STRIKE              BINARY-DOUBLE.
 01 WS-RELEASE             BINARY-DOUBLE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone sensors: no generated packs here, skipped" TO TL-CASE
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
     PERFORM DRAIN
*>   5: the sun angle curve: 0 at tick 6000, 180 at tick 18000 (the curve is symmetric), always increasing
     MOVE 6000 TO WS-T
     CALL "RL-SUN-ANGLE" USING WS-T WS-ANGLE
     COMPUTE WS-ANG-INT = FUNCTION INTEGER(WS-ANGLE + 0.5)
     MOVE WS-ANG-INT TO WS-P
     MOVE "acceptance US12-4 sensors 30-5 5 the sun angle at tick 6000 is 0 degrees" TO WS-CASE
     MOVE "0" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 18000 TO WS-T
     CALL "RL-SUN-ANGLE" USING WS-T WS-ANGLE
     COMPUTE WS-ANG-INT = FUNCTION INTEGER(WS-ANGLE + 0.5)
     MOVE WS-ANG-INT TO WS-P
     MOVE "acceptance US12-4 sensors 30-5 5 the sun angle at tick 18000 is 180 degrees" TO WS-CASE
     MOVE "180" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 12000 TO WS-T
     CALL "RL-SUN-ANGLE" USING WS-T WS-ANGLE
     COMPUTE WS-ANG-INT = FUNCTION INTEGER(WS-ANGLE)
     MOVE 0 TO WS-P
     IF WS-ANG-INT > 60 AND WS-ANG-INT < 120
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 sensors 30-5 5 and about 90 degrees near tick 12000" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
*>   5: the daylight detector at noon: the power follows on the next multiple of 20 game ticks
     MOVE 6000 TO CW-TIME
     MOVE 2 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "daylight_detector" TO WS-K PERFORM PUT-DEF
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sensors 30-5 5 a placed daylight detector starts at power 0" TO WS-CASE
     MOVE "daylight_detector:inverted=false,power=0" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 21 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sensors 30-5 5 at noon the detector has power 15 after the next tick of the 20 cycle" TO WS-CASE
     MOVE "daylight_detector:inverted=false,power=15" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   5 use: a right click flips inverted and recomputes at once (15 - 15 = 0)
     MOVE 1 TO WS-FACE MOVE 1 TO WS-SEQ
     MOVE 3 TO WS-NX
     MOVE 1.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 101.0 TO PL-Y(WS-ROW)
     MOVE 2.5 TO WS-PX
     MOVE WS-PX TO PL-Z(WS-ROW)
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sensors 30-5 5 a use flips inverted and the power at once" TO WS-CASE
     MOVE "daylight_detector:inverted=true,power=0" TO WS-EXP
     PERFORM ASSERT-PROPS
*>   7: the lightning rod struck by a bolt
     MOVE 6 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "lightning_rod" TO WS-K PERFORM PUT-DEF
     PERFORM DRAIN
     MOVE 3.5 TO WS-FX
     MOVE 102.0 TO WS-FY2
     COMPUTE WS-FZ2 = WS-Z + 0.5
     CALL "LIGHTNING-SPAWN" USING WS-DIM WS-FX WS-FY2 WS-FZ2 WS-VISUAL WS-BOLT
     MOVE 0 TO WS-STRIKE WS-RELEASE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30
         MOVE 1 TO WS-TICKS PERFORM RUN-TICKS
         PERFORM READ-FULL
         IF WS-PROPS = "lightning_rod:facing=up,powered=true,waterlogged=false" AND WS-STRIKE = 0
             MOVE CW-TICKS TO WS-STRIKE
         END-IF
         IF WS-PROPS = "lightning_rod:facing=up,powered=false,waterlogged=false" AND WS-STRIKE > 0 AND WS-RELEASE = 0
             MOVE CW-TICKS TO WS-RELEASE
         END-IF
     END-PERFORM
     MOVE 0 TO WS-P
     IF WS-STRIKE > 0
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 sensors 30-5 7.1 a bolt that strikes the rod powers it" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     PERFORM DRAIN
     MOVE 0 TO WS-HITS
     INSPECT WS-IDS TALLYING WS-HITS FOR ALL "47"
     MOVE WS-HITS TO WS-P
     IF WS-P > 0
         MOVE 1 TO WS-P
     END-IF
     MOVE "acceptance US12-4 sensors 30-5 7.1 and level event 3002 (Level Event 47) is sent" TO WS-CASE
     MOVE "1" TO WS-EXP
     PERFORM ASSERT-POWER
     COMPUTE WS-P = WS-RELEASE - WS-STRIKE
     MOVE "acceptance US12-4 sensors 30-5 7.2 the rod is released exactly 8 ticks after the strike" TO WS-CASE
     MOVE "8" TO WS-EXP
     PERFORM ASSERT-POWER
*>   6: the detector rail pressed by a minecart
     MOVE 10 TO WS-Z
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "detector_rail" TO WS-K PERFORM PUT-DEF
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sensors 30-6 6 an empty detector rail is not powered" TO WS-CASE
     MOVE "detector_rail:powered=false,shape=north_south,waterlogged=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 1 TO WS-KIND
     MOVE 3.5 TO WS-FX
     MOVE 101.0 TO WS-FY2
     COMPUTE WS-FZ2 = WS-Z + 0.5
     CALL "MINECART-SPAWN" USING WS-KIND WS-DIM WS-FX WS-FY2 WS-FZ2 WS-CART
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sensors 30-6 6.3 a minecart on the rail presses it" TO WS-CASE
     MOVE "detector_rail:powered=true,shape=north_south,waterlogged=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 2 TO WS-D
     CALL "RL-SIGNAL" USING WS-DIM WS-X WS-Y WS-Z WS-D WS-SIG
     MOVE WS-SIG TO WS-P
     MOVE "acceptance US12-4 sensors 30-6 6.1 a pressed detector rail gives 15 to its neighbours" TO WS-CASE
     MOVE "15" TO WS-EXP
     PERFORM ASSERT-POWER
     MOVE 25 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sensors 30-6 6.3 the cart still stands there at the 20 tick re-check: still powered" TO WS-CASE
     MOVE "detector_rail:powered=true,shape=north_south,waterlogged=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     CALL "ENTITY-REMOVE" USING WS-CART
     MOVE 22 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM READ-FULL
     MOVE "acceptance US12-4 sensors 30-6 6.3 the cart gone, the next check releases the rail" TO WS-CASE
     MOVE "detector_rail:powered=false,shape=north_south,waterlogged=false" TO WS-EXP
     PERFORM ASSERT-PROPS
     STOP RUN.

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

 END PROGRAM ACC-F2US12-REDSTONE-SENSORS.

 COPY CORETEST.
 COPY PORTALTEST.
