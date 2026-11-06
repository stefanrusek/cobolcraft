*> Acceptance test of US4-2 to US4-5, client half (client-surface §3 break and place controls;
*> standin-content §1.1 break times, §1.3 use rules, §2 tools; 09 §3.2 Player Action 0x29 and Use
*> Item On 0x42 with a sequence number per block action): the right button on a face with a block
*> item held sends Use Item On with that face and the hit point; the left button sends start destroy,
*> and in survival stop destroy once the break time has passed (a quarter of it with the matching
*> tool), or abort destroy when released early; in creative start destroy alone; the right button
*> on a glowtube without a block item sends Use Item On, on another block nothing. What the server
*> receives is read on the server side of a real loopback connection.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-CONTROLS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-TEXT                PIC X(1024).
 01 WS-LEFT                BINARY-LONG VALUE 0.
 01 WS-RIGHT               BINARY-LONG VALUE 1.
 01 WS-DOWN                BINARY-LONG VALUE 4.
 01 WS-UP                  BINARY-LONG VALUE 5.
 01 WS-CLICK               BINARY-LONG VALUE 0.
 01 WS-MS                  BINARY-LONG.
 01 WS-X                   BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG VALUE 9.
 01 WS-Z                   BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-STEPS.
    05 WS-STEP-TEXT        PIC X(1024) OCCURS 4 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
*>   Survival, looking straight down at the greystone (0, 9, 0) under the feet, 64 greystone held.
     MOVE 0 TO PL-MODE PL-HELD
     MOVE 64 TO PL-SLOT-COUNT(1)
     MOVE 2 TO PL-SLOT-ITEM(1)
     MOVE 90 TO PL-PITCH
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD

     MOVE 20 TO WS-MS
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-RIGHT WS-CLICK WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-TEXT WS-THRESHOLD
     MOVE "acceptance US4-2 client half given a greystone item held and the top face of (0, 9, 0) "
         & "aimed at when the right button is used then Use Item On is sent with that block, face "
         & "up (1), the hit point (0.5, 1, 0.5) and sequence 1" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "4200000000000000000901" & "3f0000003f8000003f000000" & "000001" TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Survival break of greystone by hand: 1.5 s.
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-LEFT WS-DOWN WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(1) WS-THRESHOLD
     MOVE 1000 TO WS-MS
     CALL "TEST-IDLE" USING CLIENT-STATE WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(2) WS-THRESHOLD
     MOVE 600 TO WS-MS
     CALL "TEST-IDLE" USING CLIENT-STATE WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(3) WS-THRESHOLD
     MOVE 100 TO WS-MS
     CALL "TEST-IDLE" USING CLIENT-STATE WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(4) WS-THRESHOLD
     MOVE "acceptance US4-3 client half given survival when the left button is held on greystone "
         & "then start destroy is sent at once, nothing more after 1 s, stop destroy once 1.5 s "
         & "have passed, and nothing more while the button stays held" TO TL-CASE
     PERFORM STEPS-TEXT
     MOVE "290000000000000000090102 | - | 290300000000000000090103 | -" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 20 TO WS-MS
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-LEFT WS-UP WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(1) WS-THRESHOLD
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-LEFT WS-DOWN WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(2) WS-THRESHOLD
     MOVE 100 TO WS-MS
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-LEFT WS-UP WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(3) WS-THRESHOLD
     MOVE 20 TO WS-MS
     CALL "TEST-IDLE" USING CLIENT-STATE WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(4) WS-THRESHOLD
     MOVE "acceptance US4-3 client half given survival when the left button is released before "
         & "the break time then abort destroy is sent" TO TL-CASE
     PERFORM STEPS-TEXT
     MOVE "- | 290000000000000000090104 | 290200000000000000090105 | -" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   With the pry bar (hard class, like greystone): a quarter, 375 ms.
     MOVE 1 TO PL-SLOT-COUNT(1)
     MOVE 10 TO PL-SLOT-ITEM(1)
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-LEFT WS-DOWN WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(1) WS-THRESHOLD
     MOVE 300 TO WS-MS
     CALL "TEST-IDLE" USING CLIENT-STATE WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(2) WS-THRESHOLD
     MOVE 100 TO WS-MS
     CALL "TEST-IDLE" USING CLIENT-STATE WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(3) WS-THRESHOLD
     MOVE 20 TO WS-MS
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-LEFT WS-UP WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(4) WS-THRESHOLD
     MOVE "acceptance US4-3 client half given the pry bar held when greystone (hard) is broken "
         & "then stop destroy follows after a quarter of the break time (375 ms)" TO TL-CASE
     PERFORM STEPS-TEXT
     MOVE "290000000000000000090106 | - | 290300000000000000090107 | -" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Creative: start destroy only.
     MOVE 1 TO PL-MODE
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-LEFT WS-DOWN WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(1) WS-THRESHOLD
     MOVE 2000 TO WS-MS
     CALL "TEST-IDLE" USING CLIENT-STATE WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(2) WS-THRESHOLD
     MOVE 20 TO WS-MS
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-LEFT WS-UP WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(3) WS-THRESHOLD
     MOVE "-" TO WS-STEP-TEXT(4)
     MOVE "acceptance US4-4 client half given creative when the left button is pressed then start "
         & "destroy is sent and nothing else, however long it is held" TO TL-CASE
     PERFORM STEPS-TEXT
     MOVE "290000000000000000090108 | - | - | -" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   No block item held (the pry bar): greystone gets nothing, a glowtube Use Item On.
     MOVE 0 TO PL-MODE
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-RIGHT WS-CLICK WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(1) WS-THRESHOLD
     MOVE 13 TO WS-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-RIGHT WS-CLICK WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(2) WS-THRESHOLD
     MOVE 16 TO WS-STATE
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-STEP" USING CLIENT-STATE
     CALL "TEST-BUTTON" USING CLIENT-STATE WS-RIGHT WS-CLICK WS-MS
     CALL "TEST-SERVER-READ-HEX" USING WS-SERVER WS-STEP-TEXT(3) WS-THRESHOLD
     MOVE "-" TO WS-STEP-TEXT(4)
     MOVE "acceptance US4-5 client half given no block item held when the right button is used "
         & "then greystone gets nothing, a glowtube Use Item On (toggle), and so does a goto_pad "
         & "(travel, standin §1.3)" TO TL-CASE
     PERFORM STEPS-TEXT
     MOVE "- | 4200000000000000000901" & "3f0000003f8000003f000000" & "000009 | "
         & "4200000000000000000901" & "3f0000003f8000003f000000" & "00000a | -" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 STEPS-TEXT.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-MS FROM 1 BY 1 UNTIL WS-MS > 4
         IF WS-STEP-TEXT(WS-MS) = SPACES
             MOVE "-" TO WS-STEP-TEXT(WS-MS)
         END-IF
         IF WS-MS > 1
             STRING " | " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
         END-IF
         STRING FUNCTION TRIM(WS-STEP-TEXT(WS-MS)) DELIMITED BY SIZE INTO TL-OBSERVED
             WITH POINTER WS-PTR
     END-PERFORM
     MOVE 20 TO WS-MS.
 END PROGRAM ACC-US4-CONTROLS.

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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-IDLE.
*> USING CLIENT-STATE, milliseconds: one CL-STEP without events that many ms after the last.
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
