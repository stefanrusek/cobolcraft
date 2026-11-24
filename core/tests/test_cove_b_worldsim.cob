*> Coverage test, group B (random tick loop of the sections, core/src/worldsim-33f.cob WL-SECTION-RUN): a section whose cells all hold a block with a randomly ticking fluid (rule kind 13 of the
*> block hook table, 29 section 5 class 8) gets the random tick of those cells: 300 ticks run in a world with 16 x 16 such cells and the trace of the hook machinery records the fluid random ticks
*> (H entries, hook 11), as it records G entries for a randomly ticking block (rule kind 11, acc_us12_worldsim_lava).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-B-WORLDSIM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY BUSTATE.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-RULE-KIND           BINARY-LONG VALUE 13.
 01 WS-RULE-EFFECT         BINARY-LONG VALUE 0.
 01 WS-RULE-ARG            BINARY-LONG VALUE 0.
 01 WS-RULE-FLAGS          BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE "T" TO TL-MODE
     CALL "BU-ENSURE"
     MOVE 1 TO BU-TRACE-ON
     MOVE 0 TO BU-TRACE-LENGTH
     MOVE CB-S-BLOCK(WS-STATE + 1) TO WS-BLOCK
     CALL "BU-RULE-ADD" USING WS-RULE-KIND WS-BLOCK WS-RULE-EFFECT WS-RULE-ARG WS-RULE-FLAGS
     PERFORM VARYING WS-DX FROM 0 BY 1 UNTIL WS-DX > 15
         PERFORM VARYING WS-DZ FROM 0 BY 1 UNTIL WS-DZ > 15
             MOVE WS-DX TO WS-X
             MOVE WS-DZ TO WS-Z
             MOVE 90 TO WS-Y
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
         END-PERFORM
     END-PERFORM
     MOVE 300 TO WS-TICKS
     CALL "TEST-TICKS-ANSWERED" USING WS-TICKS
     MOVE 0 TO WS-N
     COMPUTE WS-COUNT = BU-TRACE-LENGTH - 1
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-COUNT
         IF BU-TRACE(WS-K:2) = "H "
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "test cove b worldsim: cells of a block with a randomly ticking fluid (kind 13) get random ticks" TO TL-CASE
     MOVE "none" TO TL-OBSERVED
     IF WS-N > 0
         MOVE "random ticks seen" TO TL-OBSERVED
     END-IF
     MOVE "random ticks seen" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVE-B-WORLDSIM.
 COPY CORETEST.
