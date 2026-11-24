*> Test of 29 section 7, How clients learn about block changes (core/src/blockupd-29.cob; T0467): the change set per chunk section
*> (recorded only for a ticking chunk, a set of positions), the broadcast (one changed position of a section: a Block Update with
*> the CURRENT state; two or more: one Section Blocks Update, id 86; sections bottom to top; several changes of one position are
*> sent once with the final state), the acknowledgement (highest sequence kept, a negative one rejected, sent at the start of the
*> connection's next tick once and cleared) and the direct corrective Block Update. Expected values come from 29 sections 7.1 to 7.3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCKUPD-29-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY BCHANGE.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-GS                  BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-LS                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-SEQ                 BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-TEXT                PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     COMPUTE WS-TOP = DM-MIN-Y(1) + DM-HEIGHT(1)
     COMPUTE WS-Y = WS-TOP - 6
     COMPUTE WS-Y2 = WS-Y - 32
     MOVE 5 TO WS-X WS-Z
     MOVE CR-GREYSTONE TO WS-G
     MOVE CB-DEFAULT-STATE(WS-G + 1) TO WS-GS
     MOVE CR-LUCITE TO WS-L
     MOVE CB-DEFAULT-STATE(WS-L + 1) TO WS-LS
     CALL "BU-ENSURE"
     MOVE "T" TO TL-MODE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "BC-BROADCAST"
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT

     MOVE "acceptance US12 29§7 How clients learn about block changes: one changed position of a section is a Block Update with "
         & "the current state, after two writes of that position" TO TL-CASE
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET WS-RESULT
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS WS-FLAGS WS-BUDGET WS-RESULT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE 0 TO WS-RESULT
     INSPECT WS-TEXT TALLYING WS-RESULT FOR ALL "8("
     CALL "BC-BROADCAST"
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE WS-X TO WS-E1
     MOVE WS-Y TO WS-E2
     MOVE WS-Z TO WS-E3
     MOVE WS-GS TO WS-E4
     MOVE WS-RESULT TO WS-E5
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E5) "|" FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE SPACES TO TL-EXPECTED
     STRING "0|8(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) "=" FUNCTION TRIM(WS-E4) ")"
         DELIMITED BY SIZE INTO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§7 How clients learn about block changes: two positions of one section are one Section Blocks Update "
         & "(id 86), and a second section adds its own packet, sections bottom to top" TO TL-CASE
     COMPUTE WS-Z = 6
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET WS-RESULT
     COMPUTE WS-Z = 5
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS WS-FLAGS WS-BUDGET WS-RESULT
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y2 WS-Z WS-LS WS-FLAGS WS-BUDGET WS-RESULT
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "BC-BROADCAST"
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE WS-X TO WS-E1
     MOVE WS-Y2 TO WS-E2
     MOVE WS-Z TO WS-E3
     MOVE WS-LS TO WS-E4
     MOVE SPACES TO TL-EXPECTED
     STRING "8(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) "=" FUNCTION TRIM(WS-E4) ") 86"
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§7 How clients learn about block changes: nothing is left after a broadcast" TO TL-CASE
     CALL "BC-BROADCAST"
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE BC-COUNT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "[" FUNCTION TRIM(WS-TEXT) "] " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "[] 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§7 How clients learn about block changes: a chunk that does not tick records nothing" TO TL-CASE
     MOVE 8000 TO WS-X
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS
     CALL "BC-MARK" USING WS-DIM WS-X WS-Y WS-Z WS-RESULT
     MOVE WS-RESULT TO WS-E1
     MOVE BC-COUNT TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§7 How clients learn about block changes: the highest sequence is kept, a negative one is rejected"
         TO TL-CASE
     MOVE 7 TO WS-SEQ
     CALL "BC-ACK-SET" USING WS-ALICE WS-SEQ WS-RESULT
     MOVE WS-RESULT TO WS-E1
     MOVE 5 TO WS-SEQ
     CALL "BC-ACK-SET" USING WS-ALICE WS-SEQ WS-RESULT
     MOVE WS-RESULT TO WS-E2
     MOVE -1 TO WS-SEQ
     CALL "BC-ACK-SET" USING WS-ALICE WS-SEQ WS-RESULT
     MOVE WS-RESULT TO WS-E3
     MOVE BC-ACK(WS-ALICE) TO WS-E4
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " " FUNCTION TRIM(WS-E3) " " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1 0 8" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§7 How clients learn about block changes: the start of the connection's tick sends Block Changed Ack "
         & "with that sequence once" TO TL-CASE
     CALL "BC-ACK-TICK" USING WS-ALICE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "BC-ACK-TICK" USING WS-ALICE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     STRING "4(7)" DELIMITED BY SIZE INTO TL-EXPECTED
     IF WS-TEXT NOT = SPACES
         MOVE "second tick sent something" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§7 How clients learn about block changes: a rejected action re-sends the authoritative state directly "
         & "(Block Update from the level)" TO TL-CASE
     MOVE 5 TO WS-X
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS WS-FLAGS WS-BUDGET WS-RESULT
     CALL "BC-BROADCAST"
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     CALL "BLOCK-TELL" USING WS-ALICE WS-X WS-Y WS-Z
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     MOVE WS-X TO WS-E1
     MOVE WS-Y TO WS-E2
     MOVE WS-Z TO WS-E3
     MOVE WS-GS TO WS-E4
     MOVE SPACES TO TL-EXPECTED
     STRING "8(" FUNCTION TRIM(WS-E1) "," FUNCTION TRIM(WS-E2) "," FUNCTION TRIM(WS-E3) "=" FUNCTION TRIM(WS-E4) ")"
         DELIMITED BY SIZE INTO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-BLOCKUPD-29-7.

 COPY CORETEST.
