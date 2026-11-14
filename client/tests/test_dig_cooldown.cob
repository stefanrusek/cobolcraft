*> Implementation test of the continuous-break cooldown (13 section 2.2: after each completed break the next one cannot start
*> for 5 ticks, destroyDelay 5): in survival with the left button held, after stop destroy the next block aimed at is
*> started no sooner than 250 ms later, and is started by 400 ms (the button never released). What the server receives
*> is read from a real loopback connection.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-DIG-COOLDOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-LEFT                BINARY-LONG VALUE 0.
 01 WS-DOWN                BINARY-LONG VALUE 4.
 01 WS-MS                  BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 9.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-TEXT                PIC X(1024).
 01 WS-STEP                BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     MOVE 0 TO PL-MODE PL-HELD
     MOVE 0 TO PL-SLOT-COUNT(1)
     MOVE 90 TO PL-PITCH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 20 TO WS-MS
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-LEFT WS-DOWN WS-MS
*>   Hold past the break time of greystone by hand (2.25 s): stop destroy is sent in the last step.
     MOVE 2400 TO WS-MS
     CALL "TEST-IDLE" USING CLIENT-STATE WS-MS
*>   The server breaks the block: the block under it is aimed at next.
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE 0 TO WS-FIRST
     MOVE 50 TO WS-MS
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 8
         CALL "TEST-IDLE" USING CLIENT-STATE WS-MS
         CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
         IF WS-FIRST = 0 AND WS-TEXT(1:4) = "2900"
             MOVE WS-STEP TO WS-FIRST
         END-IF
     END-PERFORM
     MOVE "dig cooldown the next block is started in the 5th to 8th 50 ms step after stop destroy, "
         & "not sooner (13 section 2.2)" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FIRST >= 5 AND WS-FIRST <= 8
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-DIG-COOLDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BUTTON.
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
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-COUNT L-MS
     GOBACK.
 END PROGRAM TEST-BUTTON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-IDLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EVENTS              PIC X(24).
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-MS                   BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-MS.
     CALL "TEST-EVENTS-MS" USING CLIENT-STATE WS-EVENTS WS-ZERO L-MS
     GOBACK.
 END PROGRAM TEST-IDLE.
 COPY CLTEST.
