*> Test of 29 section 6, Block events (core/src/blockupd-29.cob; T0465): blockEvent adds to an insertion-ordered set (a repeat of
*> all four fields is dropped), runBlockEvents takes the first event each time, runs doBlockEvent only for a ticking chunk (the
*> block must still be at the position; the hook's answer true broadcasts a Block Event packet, id 7, to players strictly less than
*> 64.0 from the block corner), puts events of a chunk that does not tick on a reschedule list appended after the loop, and runs
*> events added while the loop runs in the same loop. Expected values come from 29 section 6 and 2.3.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BLOCKUPD-29-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY BUSTATE.
 COPY BLOCKEVT.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-GS                  BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-LS                  BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 01 WS-E5                  PIC -(9)9.
 01 WS-E6                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     COMPUTE WS-TOP = DM-MIN-Y(1) + DM-HEIGHT(1)
     COMPUTE WS-Y = WS-TOP - 6
     MOVE CR-GREYSTONE TO WS-G
     MOVE CB-DEFAULT-STATE(WS-G + 1) TO WS-GS
     MOVE CR-LUCITE TO WS-L
     MOVE CB-DEFAULT-STATE(WS-L + 1) TO WS-LS
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     CALL "BU-ENSURE"
     MOVE 5 TO WS-X WS-Z
     MOVE "T" TO TL-MODE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS
     MOVE 10 TO WS-KIND
     MOVE WS-G TO WS-BLOCK
     MOVE 4 TO WS-EFFECT
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     COMPUTE PL-X(WS-ROW) = WS-X
     COMPUTE PL-Y(WS-ROW) = WS-Y
     COMPUTE PL-Z(WS-ROW) = WS-Z
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT

     MOVE "acceptance US12 29§6 Block events: an event equal in all four fields to a pending one is dropped, any difference "
         & "makes a new one" TO TL-CASE
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     CALL "BE-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-G WS-A WS-B
     CALL "BE-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-G WS-A WS-B
     MOVE BE-COUNT TO WS-E1
     MOVE 3 TO WS-B
     CALL "BE-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-G WS-A WS-B
     MOVE BE-COUNT TO WS-E2
     STRING FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 2" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§6 Block events: a handled event in a ticking chunk sends one Block Event (id 7) per event and "
         & "empties the set" TO TL-CASE
     CALL "BE-RUN" USING WS-DIM
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE BE-COUNT TO WS-E1
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "7x2 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§6 Block events: an event whose block is no longer at the position is not handled and sends nothing"
         TO TL-CASE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS
     CALL "BU-RESET-TRACE"
     MOVE 1 TO BU-TRACE-ON
     CALL "BE-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-G WS-A WS-B
     CALL "BE-RUN" USING WS-DIM
     MOVE 0 TO BU-TRACE-ON
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE BU-TRACE-LENGTH TO WS-E1
     MOVE BE-COUNT TO WS-E2
     STRING "[" FUNCTION TRIM(WS-TEXT) "] " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE "[] 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS

     MOVE "acceptance US12 29§6 Block events: events run in insertion order, and one added by a handler runs in the same loop "
         & "after the pending ones" TO TL-CASE
     MOVE 10 TO WS-KIND
     MOVE WS-L TO WS-BLOCK
     MOVE 5 TO WS-EFFECT
     MOVE 3 TO WS-FLAGS
     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ARG WS-FLAGS
     COMPUTE WS-Z = 7
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-LS
     MOVE 5 TO WS-Z
     CALL "BU-RESET-TRACE"
     MOVE 1 TO BU-TRACE-ON
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 7 TO WS-Z
     CALL "BE-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-L WS-A WS-B
     MOVE 5 TO WS-Z
     CALL "BE-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-G WS-A WS-B
     CALL "BE-RUN" USING WS-DIM
     MOVE 0 TO BU-TRACE-ON
     MOVE WS-X TO WS-E1
     MOVE WS-Y TO WS-E2
     MOVE WS-LS TO WS-E3
     MOVE WS-GS TO WS-E4
     STRING "E " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " 7 " FUNCTION TRIM(WS-E3) " 1 1;E "
         FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " 5 " FUNCTION TRIM(WS-E4) " 1 1;E "
         FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " 7 " FUNCTION TRIM(WS-E3) " 2 1;E "
         FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " 7 " FUNCTION TRIM(WS-E3) " 3 1;" DELIMITED BY SIZE
         INTO TL-EXPECTED
     MOVE BU-TRACE(1:BU-TRACE-LENGTH) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 29§6 Block events: an event in a chunk that does not tick waits on the reschedule list and is back in "
         & "the set after the loop" TO TL-CASE
     MOVE 8000 TO WS-X
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-GS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     CALL "BE-ADD" USING WS-DIM WS-X WS-Y WS-Z WS-G WS-A WS-B
     CALL "BE-RUN" USING WS-DIM
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE BE-COUNT TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "[" FUNCTION TRIM(WS-TEXT) "] " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "[] 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-BLOCKUPD-29-6.

 COPY CORETEST.
