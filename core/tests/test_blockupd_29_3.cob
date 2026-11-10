*> Test of 29 section 3, Neighbour updates and shape updates (core/src/blockupd-29.cob; T0459): the two update orders
*> (neighbour changed W E D U N S, shape updates W E N S D U with the receiver's direction), updateNeighborsAt and its
*> except-from-facing form, the shape update of 3.2 (flag 128 on wire, a new state of air destroys, the same state does
*> nothing), updateFromNeighbourShapes (direction towards the neighbour), the collecting updater of 3.3 (depth first in order
*> of addition, simple and full entries, the chained-update limit with its first skipped position, count reset) and
*> updateNeighbourForOutputSignal of 3.4 (a comparator directly or behind one conductor, unloaded chunks skipped).
*> Hook calls are read from BU-TRACE (BUSTATE.cpy); expected strings come from the order tables and examples of 29 sections
*> 3.1 to 3.4 and 13.2, independently of the core. Directions: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCKUPD-29-3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY BLOCKUPD.
 COPY BUSTATE.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-X3                  BINARY-LONG.
 01 WS-X4                  BINARY-LONG.
 01 WS-X5                  BINARY-LONG.
 01 WS-X6                  BINARY-LONG.
 01 WS-X7                  BINARY-LONG.
 01 WS-X8                  BINARY-LONG.
 01 WS-Z1                  BINARY-LONG.
 01 WS-Z2                  BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-G                   BINARY-LONG.
 01 WS-GS                  BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-LS                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-LETTER              PIC X.
 01 WS-P1                  BINARY-LONG.
 01 WS-P2                  BINARY-LONG.
 01 WS-P3                  BINARY-LONG.
 01 WS-P4                  BINARY-LONG.
 01 WS-P5                  BINARY-LONG.
 01 WS-P6                  BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 01 WS-TOP                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     COMPUTE WS-TOP = DM-MIN-Y(1) + DM-HEIGHT(1)
     COMPUTE WS-Y = WS-TOP - 6
     MOVE 5 TO WS-X WS-Z
     MOVE CR-GREYSTONE TO WS-G
     MOVE CB-DEFAULT-STATE(WS-G + 1) TO WS-GS
     MOVE CR-LUCITE TO WS-L
     MOVE CB-DEFAULT-STATE(WS-L + 1) TO WS-LS
     CALL "BU-ENSURE"
     MOVE "T" TO TL-MODE


     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: updateNeighborsAt notifies W, E, D, U, N, S with the given source block"
         TO TL-CASE
     PERFORM START-TRACE
     CALL "BU-NEIGHBORS-AT" USING WS-DIM WS-X WS-Y WS-Z WS-G
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: the except form skips one direction (up)"
         TO TL-CASE
     PERFORM START-TRACE
     MOVE 1 TO WS-SKIP
     CALL "BU-NEIGHBORS-EXCEPT" USING WS-DIM WS-X WS-Y WS-Z WS-G WS-SKIP
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: skipping the first direction (west) starts at east"
         TO TL-CASE
     PERFORM START-TRACE
     MOVE 4 TO WS-SKIP
     CALL "BU-NEIGHBORS-EXCEPT" USING WS-DIM WS-X WS-Y WS-Z WS-G WS-SKIP
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: shape updates go W, E, N, S, D, U and each receiver sees the opposite direction (13.2)"
         TO TL-CASE
     PERFORM START-TRACE
     MOVE 0 TO WS-FLAGS
     MOVE 5 TO WS-BUDGET
     CALL "BU-SHAPE-UPDATES" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 5
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 4
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 3
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 2
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 1
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: a shape update that returns air destroys the receiver "
         & "(the torch above the removed block of 13.2)" TO TL-CASE
     COMPUTE WS-Y1 = WS-Y + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-GS
     MOVE 4 TO WS-KIND
     MOVE WS-G TO WS-BLOCK
     MOVE 2 TO WS-EFFECT
     MOVE 0 TO WS-ARG
     MOVE 0 TO WS-FLAGS
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     MOVE 3 TO WS-FLAGS
     MOVE 512 TO WS-BUDGET
     CALL "BU-SHAPE-UPDATES" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-STATE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: under flag 32 a destroy by shape update still removes the block (no drops)"
         TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-GS
     MOVE 35 TO WS-FLAGS
     CALL "BU-SHAPE-UPDATES" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-STATE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: a shape update that returns another state writes it with flag 32 cleared"
         TO TL-CASE
     CALL "BU-RULES-CLEAR"
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-GS
     MOVE 2 TO WS-EFFECT
     MOVE WS-LS TO WS-ARG
     MOVE 0 TO WS-FLAGS
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     MOVE 3 TO WS-FLAGS
     CALL "BU-SHAPE-UPDATES" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-STATE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-LS TO TL-EXPECTED-N
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-GS

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: a shape update that returns the same state changes nothing"
         TO TL-CASE
     CALL "BU-RULES-CLEAR"
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-GS
     MOVE 2 TO WS-EFFECT
     MOVE WS-GS TO WS-ARG
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     CALL "BU-SHAPE-UPDATES" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-STATE
     MOVE WS-STATE TO TL-OBSERVED-N
     MOVE WS-GS TO TL-EXPECTED-N
     PERFORM CHECK-N

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: a receiver that is wire is skipped under flag 128"
         TO TL-CASE
     CALL "BU-RULES-CLEAR"
     MOVE 5 TO WS-KIND
     MOVE 0 TO WS-EFFECT
     MOVE 0 TO WS-ARG
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     PERFORM START-TRACE
     MOVE 128 TO WS-FLAGS
     MOVE 5 TO WS-BUDGET
     CALL "BU-SHAPE-UPDATES" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 5
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 4
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 3
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 2
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 1
     COMPUTE WS-P6 = WS-LS
     PERFORM EXP
     PERFORM CHECK
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-ZERO

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: updateFromNeighbourShapes passes the direction towards the neighbour"
         TO TL-CASE
     CALL "BU-RULES-CLEAR"
     PERFORM START-TRACE
     CALL "BU-UPDATE-FROM-SHAPES" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-OUT
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = 4
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = 5
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = 2
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = 3
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = 1
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: the final state of updateFromNeighbourShapes is returned"
         TO TL-CASE
     MOVE WS-OUT TO TL-OBSERVED-N
     MOVE WS-LS TO TL-EXPECTED-N
     PERFORM CHECK-N

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: each result feeds the next call"
         TO TL-CASE
     MOVE 4 TO WS-KIND
     MOVE WS-L TO WS-BLOCK
     MOVE 2 TO WS-EFFECT
     MOVE WS-GS TO WS-ARG
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     PERFORM START-TRACE
     CALL "BU-UPDATE-FROM-SHAPES" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-OUT
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = 4
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 5
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 2
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 3
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 1
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK
     CALL "BU-RULES-CLEAR"

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: propagation is depth first in order of addition"
         TO TL-CASE
     COMPUTE WS-X1 = WS-X + 5
     COMPUTE WS-X2 = WS-X + 6
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X1 WS-Y WS-Z WS-GS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y WS-Z WS-GS
     MOVE 3 TO WS-KIND
     MOVE WS-G TO WS-BLOCK
     MOVE 1 TO WS-EFFECT
     MOVE 0 TO WS-ARG
     MOVE 17 TO WS-FLAGS
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     PERFORM START-TRACE
     COMPUTE WS-X3 = WS-X + 4
     MOVE 0 TO WS-BLOCK
     CALL "BU-NEIGHBORS-AT" USING WS-DIM WS-X3 WS-Y WS-Z WS-BLOCK
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 3
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 5
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "R" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 5
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "P" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 5
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-GS
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 4
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 6
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "R" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 6
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "P" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 6
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-GS
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 6 + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 6 + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 6 + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 6 + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 6 + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 6 + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 5 + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 5 + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 5 + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 5 + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 4 + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 4 + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 4 + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + 4 + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: the count of a finished cascade is back to 0 and both lists are empty"
         TO TL-CASE
     COMPUTE TL-OBSERVED-N = BU-COUNT * 10000 + BU-STACK-SIZE * 100 + BU-ADDED-SIZE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: with the limit 2 the third entry of a cascade is dropped, "
         & "the first skipped position is kept and the neighbours of the last block are not told" TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X1 WS-Y WS-Z WS-GS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y WS-Z WS-GS
     MOVE 2 TO BU-CHAINED-LIMIT
     MOVE 0 TO BU-SKIPPED
     PERFORM START-TRACE
     CALL "BU-NEIGHBORS-AT" USING WS-DIM WS-X3 WS-Y WS-Z WS-BLOCK
     MOVE BU-SKIPPED TO WS-E1
     MOVE BU-FIRST-SKIPPED-X TO WS-E2
     MOVE BU-FIRST-SKIPPED-Y TO WS-E3
     MOVE BU-FIRST-SKIPPED-Z TO WS-E4
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X2 WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-E5
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " "
         FUNCTION TRIM(WS-E5) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE WS-X2 TO WS-E2
     MOVE WS-Y TO WS-E3
     MOVE WS-Z TO WS-E4
     MOVE 0 TO WS-E5
     STRING "1 " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5)
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK-PLAIN

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: a negative limit means unlimited" TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X1 WS-Y WS-Z WS-GS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X2 WS-Y WS-Z WS-GS
     MOVE -1 TO BU-CHAINED-LIMIT
     MOVE 0 TO BU-SKIPPED
     CALL "BU-NEIGHBORS-AT" USING WS-DIM WS-X3 WS-Y WS-Z WS-BLOCK
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X2 WS-Y WS-Z WS-STATE
     COMPUTE TL-OBSERVED-N = BU-SKIPPED * 10 + WS-STATE
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE 1000000 TO BU-CHAINED-LIMIT
     CALL "BU-RULES-CLEAR"

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: a simple entry reads the state at its turn, a full entry carries its own and the moved flag"
         TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X1 WS-Y WS-Z WS-GS
     PERFORM START-TRACE
     CALL "BU-NEIGHBOR-SIMPLE" USING WS-DIM WS-X1 WS-Y WS-Z WS-L
     MOVE 7 TO WS-STATE
     MOVE 1 TO WS-MOVED
     CALL "BU-NEIGHBOR-FULL" USING WS-DIM WS-X1 WS-Y WS-Z WS-L WS-STATE WS-MOVED
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X1
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X1
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = 7
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 1
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: the output-signal update tells a comparator beside the block and one behind a conductor, in N, E, S, W order, and skips unloaded chunks"
         TO TL-CASE
     COMPUTE WS-X4 = WS-X + 10
     COMPUTE WS-Z1 = WS-Z - 1
     COMPUTE WS-Z2 = WS-Z - 2
     COMPUTE WS-X5 = WS-X4 + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X4 WS-Y WS-Z1 WS-GS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X4 WS-Y WS-Z2 WS-LS
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X5 WS-Y WS-Z WS-LS
     MOVE 6 TO WS-KIND
     MOVE WS-L TO WS-BLOCK
     MOVE 0 TO WS-EFFECT
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     PERFORM START-TRACE
     CALL "BU-OUTPUT-SIGNAL" USING WS-DIM WS-X4 WS-Y WS-Z WS-G
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X4
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z2
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X5
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§3 Neighbour updates and shape updates: a neighbour in a chunk that is not loaded is skipped" TO TL-CASE
     MOVE 8000 TO WS-X6
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X6 WS-Y WS-Z WS-GS
     COMPUTE WS-X7 = WS-X6 + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X7 WS-Y WS-Z WS-LS
     COMPUTE WS-X8 = WS-X6 - 1
     PERFORM START-TRACE
     CALL "BU-OUTPUT-SIGNAL" USING WS-DIM WS-X6 WS-Y WS-Z WS-G
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X7
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = WS-G
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK
     STOP RUN.

 START-TRACE.
     CALL "BU-RESET-TRACE"
     MOVE 1 TO BU-TRACE-ON
     .
 EXP.
     MOVE WS-P1 TO WS-E1
     MOVE WS-P2 TO WS-E2
     MOVE WS-P3 TO WS-E3
     MOVE WS-P4 TO WS-E4
     MOVE WS-P5 TO WS-E5
     MOVE WS-P6 TO WS-E6
     STRING WS-LETTER " " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " "
         FUNCTION TRIM(WS-E4) " " FUNCTION TRIM(WS-E5) " " FUNCTION TRIM(WS-E6) ";" DELIMITED BY SIZE
         INTO TL-EXPECTED POINTER WS-PTR
     .
 CHECK.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-OBSERVED
     IF BU-TRACE-LENGTH > 0
         MOVE BU-TRACE(1:BU-TRACE-LENGTH) TO TL-OBSERVED
     END-IF
     MOVE 0 TO BU-TRACE-ON
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 CHECK-PLAIN.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 CHECK-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     .
 END PROGRAM TEST-BLOCKUPD-29-3.

 COPY CORETEST.
