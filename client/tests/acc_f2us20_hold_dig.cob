*> Acceptance test (spec 002 polish; docs/protocol/13 section 2.2 "Holding"; operator playtest): in a hosted
*> survival world (client + core, SP-PUMP) the left button held while aiming straight down keeps breaking
*> the blocks one after the other, the post-break cooldown between them, with no release and re-press.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US20-HOLD-DIG.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY COREAPI.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-hold-dig".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 26.
 01 WS-FOLDER              PIC X(80) VALUE "First".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-NAME                PIC X(64) VALUE "First".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-LEFT                BINARY-LONG VALUE 0.
 01 WS-DOWN                BINARY-LONG VALUE 4.
 01 WS-MS                  BINARY-LONG VALUE 50.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BROKEN              BINARY-LONG.
 01 WS-LAST                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-FRAME               BINARY-LONG.
 01 WS-EVENTS              PIC X(24).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-MS16                BINARY-LONG VALUE 16.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
*>   Let the Player settle on the ground, then look straight down and hold the left button.
     MOVE 200 TO WS-F
     CALL "TEST-TICKS" USING CLIENT-STATE WS-F
     MOVE 90 TO PL-PITCH
     COMPUTE WS-X = FUNCTION INTEGER(PL-X)
     COMPUTE WS-Z = FUNCTION INTEGER(PL-Z)
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y) - 1
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-LEFT WS-DOWN WS-MS
     PERFORM VARYING WS-FRAME FROM 1 BY 1 UNTIL WS-FRAME > 1250
         CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-ZERO WS-MS16
         MOVE 0 TO WS-BROKEN
         PERFORM VARYING WS-Y FROM WS-Y0 BY -1 UNTIL WS-Y < WS-Y0 - 12
             CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
             IF WS-STATE = 0
                 ADD 1 TO WS-BROKEN
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance holding the left button aimed straight down breaks at least 4 blocks in 20 s "
         & "with no re-press" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BROKEN >= 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US20-HOLD-DIG.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BUTTON.
*> USING CLIENT-STATE, button (0 left, 1 right), event kind (4 down, 5 up, 0 a click: down and up),
*> milliseconds: one CL-STEP with that mouse button event, that many ms after the last step.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-EVENTS.
    05 WS-EVENT OCCURS 2 TIMES.
       10 WS-KIND          BINARY-LONG.
       10 WS-A             BINARY-LONG.
       10 WS-B             BINARY-LONG.
       10 WS-C             BINARY-LONG.
       10 WS-X             FLOAT-SHORT.
       10 WS-Y             FLOAT-SHORT.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-BUTTON               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-MS                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-BUTTON L-KIND L-MS.
     INITIALIZE WS-EVENTS
     MOVE L-BUTTON TO WS-A(1) WS-A(2)
     MOVE 1 TO WS-COUNT
     MOVE L-KIND TO WS-KIND(1)
     IF L-KIND = 0
         MOVE CC-EV-BUTTON-DOWN TO WS-KIND(1)
         MOVE CC-EV-BUTTON-UP TO WS-KIND(2)
         MOVE 2 TO WS-COUNT
     END-IF
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-COUNT L-MS
     GOBACK.
 END PROGRAM TEST-BUTTON.

 COPY CLTEST.
