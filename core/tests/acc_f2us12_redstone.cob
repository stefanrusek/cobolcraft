*> Acceptance test (T0838, US12-4; docs/protocol/30-redstone-1-model-signal-and-wire.md sections 5, 6 and the worked examples 9.1 and 9.4): redstone is wired into the block update path of
*> a live world. A redstone block placed beside a line of wire powers the first wire to 15 and each further wire loses 1 (9.1: 15, 14, 13), the wire resolves its sides towards the
*> source and into a straight line (9.4), wire placed after the source reads it at once, and removing the source returns the whole line to power 0. Needs the generated packs (a pass
*> without them). Scope of the wiring: wire and the redstone block; torches, levers, repeaters and conductors are not wired yet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-REDSTONE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 01 WS-SKIP                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG VALUE 101.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY-STONE           PIC X(48) VALUE "stone".
 01 WS-KEY-WIRE            PIC X(48) VALUE "redstone_wire".
 01 WS-KEY-BLOCK           PIC X(48) VALUE "redstone_block".
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-STONE               BINARY-LONG.
 01 WS-WIRE                BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-WIRE-BLOCK          BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-LINE                PIC X(60).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-4 redstone: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "PT-STATE" USING WS-KEY-STONE WS-PAIRS WS-STONE
     CALL "PT-STATE" USING WS-KEY-WIRE WS-PAIRS WS-WIRE
     CALL "PT-STATE" USING WS-KEY-BLOCK WS-PAIRS WS-SOURCE
*>   a stone floor at y 100 for x 0 to 20, air above it
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 20
         MOVE 100 TO WS-Y
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STONE
         MOVE 101 TO WS-Y
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     END-PERFORM
     MOVE 101 TO WS-Y

*>   wire at x 1 to 3 first, then the redstone block at x 0 (neighbor change path)
     PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 3
         CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WIRE WS-FLAGS WS-BUDGET WS-RESULT
     END-PERFORM
     MOVE 0 TO WS-X
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SOURCE WS-FLAGS WS-BUDGET WS-RESULT
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 3
         PERFORM READ-WIRE
         PERFORM ADD-POWER
     END-PERFORM
     MOVE "acceptance US12-4 redstone 9.1 a redstone block beside a line of wire: the wire powers are 15, 14, 13" TO TL-CASE
     MOVE "15 14 13" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   9.4 the sides of the first wire: a signal source on the west side connects it, the line is straight (east and west side, north and south none)
     MOVE 1 TO WS-X
     PERFORM READ-WIRE
     MOVE SPACES TO TL-OBSERVED
     MOVE WS-N TO WS-ED
     STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-LINE
     MOVE WS-E TO WS-ED
     STRING FUNCTION TRIM(WS-LINE) " " FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-LINE
     MOVE WS-S TO WS-ED
     STRING FUNCTION TRIM(WS-LINE) " " FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-LINE
     MOVE WS-W TO WS-ED
     STRING FUNCTION TRIM(WS-LINE) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "acceptance US12-4 redstone 9.4 the first wire beside the source: north none, east side, south none, west side (2 1 2 1)" TO TL-CASE
     MOVE "2 1 2 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the line is longer: wire at x 4 to 17 is powered down to 0 after 15 steps
     PERFORM VARYING WS-X FROM 4 BY 1 UNTIL WS-X > 17
         CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-WIRE WS-FLAGS WS-BUDGET WS-RESULT
     END-PERFORM
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-X FROM 12 BY 1 UNTIL WS-X > 17
         PERFORM READ-WIRE
         PERFORM ADD-POWER
     END-PERFORM
     MOVE "acceptance US12-4 redstone 9.1 each wire loses 1: the wire at distance 12 to 17 has 4, 3, 2, 1, 0, 0" TO TL-CASE
     MOVE "4 3 2 1 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   removing the source returns every wire to 0
     MOVE 0 TO WS-X
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR WS-FLAGS WS-BUDGET WS-RESULT
     MOVE 0 TO WS-I
     PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 17
         PERFORM READ-WIRE
         ADD WS-P TO WS-I
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12-4 redstone removing the redstone block: the sum of the powers of the 17 wires is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-I TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   wire placed after the source reads it at once
     MOVE "T" TO TL-MODE
     MOVE 0 TO WS-X
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-SOURCE WS-FLAGS WS-BUDGET WS-RESULT
     MOVE 0 TO WS-X
     MOVE SPACES TO TL-OBSERVED
     PERFORM VARYING WS-X FROM 1 BY 1 UNTIL WS-X > 2
         PERFORM READ-WIRE
         PERFORM ADD-POWER
     END-PERFORM
     MOVE "acceptance US12-4 redstone a source placed beside powerless wire powers it again: 15 14" TO TL-CASE
     MOVE "15 14" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 READ-WIRE.
*>   the sides and the power of the wire at (WS-X, WS-Y, WS-Z): the state is the wire's first state id plus the index of 4.3
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-N WS-E WS-S WS-W WS-P
     PERFORM VARYING WS-ID FROM 1 BY 1 UNTIL WS-ID > CB-BLOCK-COUNT
         IF CB-KEY(WS-ID) = "redstone_wire"
             COMPUTE WS-WIRE-BLOCK = WS-ID
         END-IF
     END-PERFORM
     IF CB-S-BLOCK(WS-STATE + 1) = WS-WIRE-BLOCK - 1
         COMPUTE WS-ID = WS-STATE - CB-FIRST-STATE(WS-WIRE-BLOCK) + 5567
         CALL "RS1-WIRE-DECODE" USING WS-ID WS-N WS-E WS-S WS-W WS-P
     ELSE
         MOVE -1 TO WS-P
     END-IF.

 ADD-POWER.
     MOVE WS-P TO WS-ED
     IF TL-OBSERVED = SPACES
         MOVE FUNCTION TRIM(WS-ED) TO TL-OBSERVED
     ELSE
         MOVE TL-OBSERVED TO WS-LINE
         STRING FUNCTION TRIM(WS-LINE) " " FUNCTION TRIM(WS-ED) DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF.

 END PROGRAM ACC-F2US12-REDSTONE.

 COPY CORETEST.
 COPY PORTALTEST.
