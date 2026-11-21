*> Acceptance test (spec 002 polish; 13 section 1.4; operator playtest): a creative single-player world (client + hosted core,
*> SP-PUMP, standard content set) flies: a double Space on the ground starts flying, Space held rises smoothly, released
*> hovers (no gravity), a double Space in the air stops flying (the Player falls).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US20-SP-FLIGHT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY COREAPI.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-sp-flight".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 27.
 01 WS-FOLDER              PIC X(80) VALUE "First".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-NAME                PIC X(64) VALUE "First".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR2                PIC X(1100).
 01 WS-TYPE                BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-SPACE               BINARY-LONG VALUE CC-KEY-SPACE.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-N                   BINARY-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-Y2                  FLOAT-LONG.
 01 WS-FLY                 BINARY-LONG.
 01 WS-RISEN               PIC -(4)9.99.
 PROCEDURE DIVISION.
     CALL "TEST-SP-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH
     CALL "SP-OPEN" USING CLIENT-STATE WS-FOLDER WS-FOLDER-LENGTH WS-NAME WS-NAME-LENGTH WS-MODE
     CALL "TEST-SP-JOIN" USING CLIENT-STATE WS-JOINED
     CALL "CONTENT-CLOSE"
     MOVE SPACES TO WS-DIR2
     MOVE "content/tests/fixtures/std" TO WS-DIR2
     MOVE CT-TYPE-STANDARD TO WS-TYPE
     CALL "CONTENT-OPEN" USING WS-TYPE WS-DIR2 WS-STATUS
     CALL "ENTITIES-OPEN"
     MOVE 100 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N

*>   Double Space on the ground: flying.
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     MOVE 5 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE "sp flight a double Space on the ground of a creative world starts flying" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-FLYING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Hold Space 1 s: smooth rise.
     MOVE PL-Y TO WS-Y0
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-DOWN
     MOVE 20 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     CALL "TEST-KEY-TICK" USING CLIENT-STATE WS-SPACE WS-UP
     MOVE PL-Y TO WS-Y1
     MOVE "sp flight Space held 1 s rises more than 6 blocks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-Y1 - WS-Y0 > 6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Released: hover for 1 s.
     MOVE 20 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE PL-Y TO WS-Y2
     MOVE "sp flight Space released hovers (no change of height in 1 s)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF FUNCTION ABS(WS-Y2 - WS-Y1) < 0.01 AND PL-FLYING = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Double Space in the air: flying stops and the Player falls.
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     CALL "TEST-KEY" USING CLIENT-STATE WS-SPACE
     MOVE 10 TO WS-N
     CALL "TEST-TICKS" USING CLIENT-STATE WS-N
     MOVE "sp flight a double Space in the air stops flying and the Player falls" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-FLYING = 0 AND PL-Y < WS-Y2 - 0.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US20-SP-FLIGHT.
 COPY CLTEST.
