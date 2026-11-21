*> Test of 29 section 2, The setBlock pipeline (core/src/blockupd-29.cob; T0457): LEVEL-SET-BLOCK steps of 2.2 in order
*> (bounds, the chunk write with the removal and onPlace hooks of 2.1 steps 9 and 11, the callback-replaced exit, the client
*> broadcast of flag 2, the neighbour updates with the OLD block as source, the shape updates under flag 16 and the budget),
*> removeBlock (flags 3, plus 64 for a move) and destroyBlock (air refused, effect, write, result). Hook calls are read from
*> BU-TRACE (BUSTATE.cpy). Expected values come from 29 sections 2.1, 2.2 and 13.1, independently of the core.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCKUPD-29-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY BLOCKUPD.
 COPY BUSTATE.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-GS                  BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-LS                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-BUDGET              BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-DROP                BINARY-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
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
 01 WS-TEXT                PIC X(1024).
 01 WS-ROW                 BINARY-LONG.
 01 WS-PLDIM               BINARY-LONG.
 01 WS-EXCLUDED            BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-OTHERDIM            BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-Y1                  BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     COMPUTE WS-TOP = DM-MIN-Y(1) + DM-HEIGHT(1)
     COMPUTE WS-Y = WS-TOP - 6
     MOVE 5 TO WS-X WS-Z
     MOVE CR-GREYSTONE TO WS-G
     MOVE CB-DEFAULT-STATE(WS-G + 1) TO WS-GS
     MOVE CR-LUCITE TO WS-L
     MOVE CB-DEFAULT-STATE(WS-L + 1) TO WS-LS
     CALL "BU-ENSURE"
     MOVE 512 TO WS-BUDGET
     MOVE "T" TO TL-MODE


     MOVE "acceptance US12 29§2 The `setBlock` pipeline: a position outside the build height is refused and nothing runs"
         TO TL-CASE
     PERFORM START-TRACE
     COMPUTE WS-Y1 = WS-TOP + 5
     MOVE 3 TO WS-FLAGS
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y1 WS-Z WS-GS WS-FLAGS WS-BUDGET WS-RESULT
     COMPUTE TL-OBSERVED-N = BU-TRACE-LENGTH * 10 + WS-RESULT
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: writing the state already there returns false and runs no hook"
         TO TL-CASE
     PERFORM START-TRACE
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR WS-FLAGS WS-BUDGET WS-RESULT
     COMPUTE TL-OBSERVED-N = BU-TRACE-LENGTH * 10 + WS-RESULT
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: placing with flags 3 runs removal and onPlace, then the six neighbours (old block as source) an"
         & "d the six shape updates (13.1)"
         TO TL-CASE
     PERFORM START-TRACE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS WS-FLAGS WS-BUDGET WS-RESULT
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "R" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-GS
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "P" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 5
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 4
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 3
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 2
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 1
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: a real change returns true, the world holds the state and the viewers of the chunk got a Block "
         & "Update"
         TO TL-CASE
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BC-BROADCAST"
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE 0 TO WS-P1
     INSPECT WS-TEXT TALLYING WS-P1 FOR ALL "8("
     COMPUTE TL-OBSERVED-N = WS-RESULT * 100000 + WS-STATE * 10 + WS-P1
     COMPUTE TL-EXPECTED-N = 100000 + WS-GS * 10 + 1
     PERFORM CHECK-N

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: flag 512 skips onPlace, flag 16 skips the shape updates, and flag 1 alone gives removal then si"
         & "x neighbours with the old block"
         TO TL-CASE
     PERFORM START-TRACE
     COMPUTE WS-FLAGS = BU-UPDATE-SKIP-ON-PLACE + BU-UPDATE-KNOWN-SHAPE + BU-UPDATE-NEIGHBORS
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET WS-RESULT
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "R" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = WS-LS
     COMPUTE WS-P6 = 0
     PERFORM EXP
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

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: flag 2 alone writes and broadcasts, runs onPlace and the shape updates, but sends no neighbour "
         & "notification"
         TO TL-CASE
     PERFORM START-TRACE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE BU-UPDATE-CLIENTS TO WS-FLAGS
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS WS-FLAGS WS-BUDGET WS-RESULT
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "P" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = WS-LS
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 5
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 4
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 3
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 2
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 1
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = WS-GS
     PERFORM EXP
     CALL "BC-BROADCAST"
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE 0 TO WS-P1
     INSPECT WS-TEXT TALLYING WS-P1 FOR ALL "8("
     MOVE WS-P1 TO WS-E1
     PERFORM CHECK
     MOVE WS-E1 TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     MOVE "acceptance US12 29§2 The `setBlock` pipeline: flag 2 queued the position for the viewers (one Block Update)" TO TL-CASE
     PERFORM CHECK-N

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: without flag 2 no Block Update is sent to the viewers"
         TO TL-CASE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE 16 TO WS-FLAGS
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET WS-RESULT
     CALL "BC-BROADCAST"
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE 0 TO WS-P1
     INSPECT WS-TEXT TALLYING WS-P1 FOR ALL "8("
     MOVE WS-P1 TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: budget 0 skips the shape updates and a piston move (64) runs the removal hook without flag 1, b"
         & "oth hooks with moved 1"
         TO TL-CASE
     PERFORM START-TRACE
     MOVE BU-UPDATE-MOVE-BY-PISTON TO WS-FLAGS
     MOVE 0 TO WS-BUDGET
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS WS-FLAGS WS-BUDGET WS-RESULT
     MOVE 512 TO WS-BUDGET
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "R" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = WS-GS
     COMPUTE WS-P6 = 1
     PERFORM EXP
     MOVE "P" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = WS-LS
     COMPUTE WS-P6 = 1
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: a state of the same block runs no removal hook, even with flag 1"
         TO TL-CASE
     MOVE 16 TO WS-FLAGS
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z CR-CARDSTACK-X WS-FLAGS WS-BUDGET WS-RESULT
     PERFORM START-TRACE
     COMPUTE WS-FLAGS = BU-UPDATE-NEIGHBORS + BU-UPDATE-KNOWN-SHAPE + BU-UPDATE-SKIP-ON-PLACE
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z CR-CARDSTACK-Z WS-FLAGS WS-BUDGET WS-RESULT
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = CR-CARDSTACK
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = CR-CARDSTACK
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = CR-CARDSTACK
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = CR-CARDSTACK
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = CR-CARDSTACK
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = CR-CARDSTACK
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: an onPlace that replaces the block makes the outer write return true and skip its own neighbour"
         & " and shape steps"
         TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR
     MOVE 1 TO WS-KIND
     MOVE WS-L TO WS-BLOCK
     MOVE 1 TO WS-EFFECT
     MOVE WS-GS TO WS-ARG
     MOVE 16 TO WS-FLAGS
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     PERFORM START-TRACE
     MOVE 3 TO WS-FLAGS
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET WS-RESULT
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "R" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-LS
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "P" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-LS
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "P" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = WS-LS
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE "acceptance US12 29§2 The `setBlock` pipeline: the replaced write still returns true and the callback state stays" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-RESULT * 100000 + WS-STATE
     COMPUTE TL-EXPECTED-N = 100000 + WS-GS
     PERFORM CHECK-N
     CALL "BU-RULES-CLEAR"

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: a removal hook that replaces the block makes the write return false and stop before onPlace"
         TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS
     MOVE 2 TO WS-KIND
     MOVE WS-G TO WS-BLOCK
     MOVE 1 TO WS-EFFECT
     MOVE WS-LS TO WS-ARG
     MOVE 16 TO WS-FLAGS
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     MOVE 3 TO WS-FLAGS
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-AIR WS-FLAGS WS-BUDGET WS-RESULT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     COMPUTE TL-OBSERVED-N = WS-RESULT * 100000 + WS-STATE
     MOVE WS-LS TO TL-EXPECTED-N
     PERFORM CHECK-N
     CALL "BU-RULES-CLEAR"
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: removeBlock writes air (no fluids) with flags 3, plus 64 for a move"
         TO TL-CASE
     PERFORM START-TRACE
     MOVE 0 TO WS-MOVED
     CALL "LEVEL-REMOVE-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-MOVED WS-RESULT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "R" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "P" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-GS
     COMPUTE WS-P6 = 0
     PERFORM EXP
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
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 5
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 4
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 3
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 2
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 1
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK
     MOVE "acceptance US12 29§2 The `setBlock` pipeline: removeBlock returned true and left air" TO TL-CASE
     COMPUTE TL-OBSERVED-N = WS-RESULT * 100000 + WS-STATE
     MOVE 100000 TO TL-EXPECTED-N
     PERFORM CHECK-N
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS
     PERFORM START-TRACE
     MOVE 1 TO WS-MOVED
     CALL "LEVEL-REMOVE-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-MOVED WS-RESULT
     MOVE "acceptance US12 29§2 The `setBlock` pipeline: a moved removal passes moved 1 to both hooks" TO TL-CASE
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "R" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 1
     PERFORM EXP
     MOVE "P" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-GS
     COMPUTE WS-P6 = 1
     PERFORM EXP
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
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 5
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 4
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 3
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 2
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 1
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "S" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = 0
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: destroyBlock of air returns false and does nothing"
         TO TL-CASE
     PERFORM START-TRACE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE 1 TO WS-DROP
     CALL "LEVEL-DESTROY-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-DROP WS-BUDGET WS-RESULT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     COMPUTE TL-OBSERVED-N = BU-TRACE-LENGTH * 10 + WS-RESULT
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE "acceptance US12 29§2 The `setBlock` pipeline: destroyBlock of air sent no packet" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: destroyBlock sends level event 2001 (id 47) with the state id, writes air with flags 3 and retu"
         & "rns true"
         TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     COMPUTE PL-X(WS-ROW) = WS-X
     COMPUTE PL-Y(WS-ROW) = WS-Y
     COMPUTE PL-Z(WS-ROW) = WS-Z
     PERFORM START-TRACE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     CALL "LEVEL-DESTROY-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-DROP WS-BUDGET WS-RESULT
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-P1
     INSPECT WS-TEXT TALLYING WS-P1 FOR ALL "47"
     COMPUTE TL-OBSERVED-N = WS-RESULT * 10000 + WS-STATE * 10 + WS-P1
     MOVE 10001 TO TL-EXPECTED-N
     PERFORM CHECK-N

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: a level event reaches a player strictly less than 64.0 from the block corner, not at exactly 64"
         & ".0, and never the excluded player"
         TO TL-CASE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-PLDIM
     COMPUTE PL-X(WS-ROW) = WS-X + 64
     COMPUTE PL-Y(WS-ROW) = WS-Y
     COMPUTE PL-Z(WS-ROW) = WS-Z
     MOVE 0 TO WS-EXCLUDED
     MOVE 2001 TO WS-EVENT
     MOVE 7 TO WS-ARG
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     CALL "LEVEL-EVENT" USING WS-PLDIM WS-EVENT WS-X WS-Y WS-Z WS-ARG WS-EXCLUDED
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT-EMPTY
     COMPUTE PL-X(WS-ROW) = WS-X + 63.9
     CALL "LEVEL-EVENT" USING WS-PLDIM WS-EVENT WS-X WS-Y WS-Z WS-ARG WS-EXCLUDED
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "acceptance US12 29§2 The `setBlock` pipeline: at 63.9 the level event is sent" TO TL-CASE
     MOVE "47" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-ROW TO WS-EXCLUDED
     CALL "LEVEL-EVENT" USING WS-PLDIM WS-EVENT WS-X WS-Y WS-Z WS-ARG WS-EXCLUDED
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "acceptance US12 29§2 The `setBlock` pipeline: the excluded player (the breaker) is skipped" TO TL-CASE
     PERFORM CHECK-TEXT-EMPTY

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: a level event of another dimension reaches nobody"
         TO TL-CASE
     COMPUTE PL-X(WS-ROW) = WS-X
     MOVE 0 TO WS-EXCLUDED
     MOVE 2 TO WS-OTHERDIM
     CALL "LEVEL-EVENT" USING WS-OTHERDIM WS-EVENT WS-X WS-Y WS-Z WS-ARG WS-EXCLUDED
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     PERFORM CHECK-TEXT-EMPTY

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: updateNeighboursOnBlockSet runs the old state's removal hook only when the block differs, then "
         & "tells the neighbours with the new block"
         TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS
     PERFORM START-TRACE
     CALL "LEVEL-NEIGHBOURS-ON-SET" USING WS-DIM WS-X WS-Y WS-Z WS-GS
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "R" TO WS-LETTER
     COMPUTE WS-P1 = WS-X
     COMPUTE WS-P2 = WS-Y
     COMPUTE WS-P3 = WS-Z
     COMPUTE WS-P4 = WS-GS
     COMPUTE WS-P5 = WS-LS
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     PERFORM CHECK

     MOVE "acceptance US12 29§2 The `setBlock` pipeline: updateNeighboursOnBlockSet with the same block skips the removal hook"
         TO TL-CASE
     PERFORM START-TRACE
     CALL "LEVEL-NEIGHBOURS-ON-SET" USING WS-DIM WS-X WS-Y WS-Z WS-LS
     MOVE SPACES TO TL-EXPECTED
     MOVE 1 TO WS-PTR
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (-1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (1)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (-1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (1)
     COMPUTE WS-P3 = WS-Z + (0)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (-1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
     COMPUTE WS-P6 = 0
     PERFORM EXP
     MOVE "N" TO WS-LETTER
     COMPUTE WS-P1 = WS-X + (0)
     COMPUTE WS-P2 = WS-Y + (0)
     COMPUTE WS-P3 = WS-Z + (1)
     COMPUTE WS-P4 = 0
     COMPUTE WS-P5 = WS-L
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
 CHECK-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE
     .
 CHECK-TEXT-EMPTY.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-BLOCKUPD-29-2.

 COPY CORETEST.
