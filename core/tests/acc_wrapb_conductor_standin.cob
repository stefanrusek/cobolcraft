*> Acceptance test (wrap agent B, T63111; docs/protocol/30-redstone-1 section 2.4): the stand-in content set has no collision shapes, so RL-LOOK keeps the solid and opaque rule there: the first
*> solid opaque block of the table conducts and air does not. (The vanilla set reads the collision shape: acc_wrapb_conductor_chest.)
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-CONDUCTOR-STANDIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 20.
 01 WS-Y                   BINARY-LONG VALUE 100.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-I                   BINARY-LONG.
 01 WS-OPAQUE-ID           BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-STATE-OUT           BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-COND                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE 0 TO WS-OPAQUE-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         IF CB-SOLID(WS-I) = 1 AND CB-OPAQUE(WS-I) = 1 AND WS-OPAQUE-ID = 0
             MOVE WS-I TO WS-OPAQUE-ID
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance wrapb conductor standin: the table has a solid opaque block" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE "0" TO TL-OBSERVED
     IF WS-OPAQUE-ID > 0
         MOVE "1" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CB-DEFAULT-STATE(WS-OPAQUE-ID) TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "RL-LOOK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE-OUT WS-CLASS WS-COND
     MOVE "acceptance wrapb conductor 30-1 2.4 a solid opaque stand-in block conducts" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     MOVE "0" TO TL-OBSERVED
     IF WS-COND = 1
         MOVE "1" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "RL-LOOK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE-OUT WS-CLASS WS-COND
     MOVE "acceptance wrapb conductor 30-1 2.4 air does not conduct" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     MOVE "0" TO TL-OBSERVED
     IF WS-COND = 1
         MOVE "1" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 END PROGRAM ACC-WRAPB-CONDUCTOR-STANDIN.

 COPY CORETEST.
