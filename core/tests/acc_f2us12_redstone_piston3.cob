*> Acceptance test (T29575, US12-4; docs/protocol/30-redstone-3-pistons.md section 7.4 and 29 section 3.2): a block with a survive rule that a piston pushes to a place where it cannot stand is
*> placed by the moving block entity's last tick and its neighbours' shape updates turn it to air (it is destroyed with its drops). Needs the generated packs.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE-PISTON3.
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
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/p46h-piston3-world".
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
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone piston3: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 8
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
*>   a rail on the floor at x 2 is pushed east to x 3, where the floor is missing: it does not survive its new place
     MOVE 0 TO WS-Z
     PERFORM PUT-STONE-ROW
     MOVE 3 TO WS-X MOVE 100 TO WS-Y MOVE "air" TO WS-K PERFORM PUT-DEF
     MOVE 2 TO WS-CODE MOVE 5 TO WS-FACE-N MOVE 0 TO WS-FLAG-N MOVE 0 TO WS-TYPE-N MOVE 1 TO WS-X
     PERFORM PUT-PISTON
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "rail" TO WS-K PERFORM PUT-DEF
     PERFORM DRAIN
     MOVE 0 TO WS-X MOVE "redstone_block" TO WS-K PERFORM PUT-DEF
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     MOVE 1 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 7.4 the piston is extended" TO WS-CASE
     MOVE "piston:extended=true,facing=east" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 2 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 7.4 the head is placed where the rail was" TO WS-CASE
     MOVE "piston_head:facing=east,short=false,type=normal" TO WS-EXP
     PERFORM ASSERT-PROPS
     MOVE 3 TO WS-X PERFORM READ-FULL
     MOVE "acceptance US12-4 pistons 30-3 7.4 and the rail pushed over the hole is air, not placed" TO WS-CASE
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

 END PROGRAM ACC-F2US12-REDSTONE-PISTON3.

 COPY CORETEST.
 COPY PORTALTEST.
