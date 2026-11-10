*> Acceptance test of US6-2 (client-surface §4 chat area; docs/protocol/09-cobolcraft-profile.md
*> §3.2 System Chat 0x7C): received messages appear in the chat area in the order received; while
*> chat is closed at most the 10 most recent are shown, each for 10 seconds; while chat is open the
*> 10 most recent are shown regardless of age and the scroll wheel moves back through earlier ones.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US6-CHAT-AREA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-SERVER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG VALUE 1.
 01 WS-TEXT                PIC X(1024).
 01 WS-MESSAGE             PIC X(64).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   PIC Z(4)9.
 01 WS-TICKS               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-EVENT.
    05 WS-KIND             BINARY-LONG.
    05 WS-A                BINARY-LONG.
    05 WS-B                BINARY-LONG.
    05 WS-C                BINARY-LONG.
    05 WS-X                FLOAT-SHORT.
    05 WS-Y                FLOAT-SHORT.
 PROCEDURE DIVISION.
     CALL "TEST-PLAY" USING CLIENT-STATE WS-SERVER
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 12
         MOVE WS-I TO WS-E
         MOVE SPACES TO WS-MESSAGE
         STRING "message " FUNCTION TRIM(WS-E) DELIMITED BY SIZE INTO WS-MESSAGE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-MESSAGE)) TO WS-LENGTH
         CALL "TEST-SYSTEM-CHAT" USING CLIENT-STATE WS-CONN WS-MESSAGE WS-LENGTH
         CALL "TEST-STEP" USING CLIENT-STATE
     END-PERFORM

     MOVE "acceptance US6-2 given 12 received messages when the Player looks at the chat area "
         & "then the 10 most recent are shown in the order received (after the crosshair, the "
         & "hotbar and the health widgets)" TO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "|||||||||Health 30/30|Food 24/24|message 3|message 4|message 5|message 6|message 7|"
         & "message 8|message 9|"
         & "message 10|message 11|message 12" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Ten seconds later (200 client ticks of 50 ms) every message has expired.
     MOVE 200 TO WS-TICKS
     CALL "TEST-TICKS" USING CLIENT-STATE WS-TICKS
     MOVE "acceptance US6-2 given chat closed when 10 seconds have passed then the messages are "
         & "hidden" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "|||||||||Health 30/30|Food 24/24" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE CC-KEY-T TO WS-KEY
     CALL "TEST-KEY" USING CLIENT-STATE WS-KEY
     MOVE "acceptance US6-2 when chat is opened then the 10 most recent messages are shown "
         & "regardless of age, above the input line" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "message 3|message 4|message 5|message 6|message 7|message 8|message 9|message 10|"
         & "message 11|message 12|Type a message, or / for a command" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     INITIALIZE WS-EVENT
     MOVE CC-EV-SCROLL TO WS-KIND
     MOVE 1.0 TO WS-Y
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     MOVE "acceptance US6-2 given chat open when the wheel turns up one step then the chat area "
         & "shows one earlier message" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "message 2|message 3|message 4|message 5|message 6|message 7|message 8|message 9|"
         & "message 10|message 11|Type a message, or / for a command" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 3.0 TO WS-Y
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     MOVE "acceptance US6-2 when the wheel turns up past the oldest message then the scroll-back "
         & "stops at the first message received" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "message 1|message 2|message 3|message 4|message 5|message 6|message 7|message 8|"
         & "message 9|message 10|Type a message, or / for a command" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE -1.0 TO WS-Y
     CALL "TEST-EVENTS" USING CLIENT-STATE WS-EVENT WS-ONE
     MOVE "acceptance US6-2 when the wheel turns down one step then the chat area moves one "
         & "message forward again" TO TL-CASE
     CALL "TEST-SCREEN-TEXTS" USING CLIENT-STATE WS-TEXT
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "message 2|message 3|message 4|message 5|message 6|message 7|message 8|message 9|"
         & "message 10|message 11|Type a message, or / for a command" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-US6-CHAT-AREA.
 COPY CLTEST.
