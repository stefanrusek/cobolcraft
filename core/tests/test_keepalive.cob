*> Implementation test of keep-alive (core/src/session.cob; 01 §7.5; 09 §2): in configuration and play
*> the server sends Keep Alive every 300 ticks (15 s), an echo of the pending id is accepted, and a
*> missing or wrong answer disconnects with disconnect.timeout.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-KEEPALIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY COREAPI.
 COPY CORESTATE.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 COPY TESTLIB.
 01 WS-KIND                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-THRESHOLD           BINARY-LONG VALUE -1.
 01 WS-PACKET-ID           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-DESCRIPTION         PIC X(64).
 01 WS-EDIT                PIC -(18)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING PK-BUFFER WS-CAPACITY
     MOVE CORE-CONN-MEMORY TO WS-KIND
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE PH-LOGIN TO CN-PHASE(WS-ID)
     MOVE PH-CONFIG TO WS-PHASE
     CALL "CORE-SET-PHASE" USING WS-ID WS-PHASE

     MOVE 299 TO WS-TICKS
     PERFORM RUN-TICKS
     MOVE "test keepalive configuration: nothing is sent during the first 299 ticks" TO TL-CASE
     MOVE "none" TO TL-EXPECTED
     PERFORM DESCRIBE-OUTPUT
     MOVE 1 TO WS-TICKS
     PERFORM RUN-TICKS
     MOVE "test keepalive configuration: Keep Alive 0x04 with the tick count at tick 300" TO TL-CASE
     MOVE "4 300" TO TL-EXPECTED
     PERFORM DESCRIBE-OUTPUT

     MOVE 300 TO WS-LONG
     CALL "CORE-KEEPALIVE-ANSWER" USING WS-ID WS-LONG
     MOVE 300 TO WS-TICKS
     PERFORM RUN-TICKS
     MOVE "test keepalive the echo is accepted and the next Keep Alive follows 300 ticks later" TO TL-CASE
     MOVE "4 600" TO TL-EXPECTED
     PERFORM DESCRIBE-OUTPUT

     MOVE 300 TO WS-TICKS
     PERFORM RUN-TICKS
     MOVE "test keepalive an unanswered Keep Alive disconnects at the next check (disconnect.timeout)"
         TO TL-CASE
     MOVE "2 disconnect.timeout closed" TO TL-EXPECTED
     PERFORM DESCRIBE-OUTPUT

*>   Play: Keep Alive 0x2D; a wrong id disconnects with Disconnect 0x20.
     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE PH-LOGIN TO CN-PHASE(WS-ID)
     MOVE PH-CONFIG TO WS-PHASE
     CALL "CORE-SET-PHASE" USING WS-ID WS-PHASE
     MOVE PH-PLAY TO WS-PHASE
     CALL "CORE-SET-PHASE" USING WS-ID WS-PHASE
     MOVE 300 TO WS-TICKS
     PERFORM RUN-TICKS
     MOVE "test keepalive play: Keep Alive 0x2D every 300 ticks" TO TL-CASE
     COMPUTE WS-LONG = CW-TICKS
     MOVE WS-LONG TO WS-EDIT
     MOVE SPACES TO TL-EXPECTED
     STRING "45 " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM DESCRIBE-OUTPUT
     ADD 1 TO WS-LONG
     CALL "CORE-KEEPALIVE-ANSWER" USING WS-ID WS-LONG
     MOVE "test keepalive play: a wrong id disconnects (disconnect.timeout)" TO TL-CASE
     MOVE "32 disconnect.timeout closed" TO TL-EXPECTED
     PERFORM DESCRIBE-OUTPUT

     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE PH-PLAY TO CN-PHASE(WS-ID)
     MOVE 1 TO WS-LONG
     CALL "CORE-KEEPALIVE-ANSWER" USING WS-ID WS-LONG
     MOVE "test keepalive an answer with nothing pending disconnects (disconnect.timeout)" TO TL-CASE
     MOVE "32 disconnect.timeout closed" TO TL-EXPECTED
     PERFORM DESCRIBE-OUTPUT

     CALL "CORE-CONN-OPEN" USING WS-KIND WS-ID
     MOVE PH-STATUS TO CN-PHASE(WS-ID)
     MOVE 900 TO WS-TICKS
     PERFORM RUN-TICKS
     MOVE "test keepalive no Keep Alive outside configuration and play" TO TL-CASE
     MOVE "none" TO TL-EXPECTED
     PERFORM DESCRIBE-OUTPUT
     STOP RUN.

 RUN-TICKS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TICKS
         CALL "CORE-TICK"
     END-PERFORM.

*> TL-OBSERVED: "none", or "<packet id> <Long>" for a Keep Alive, or "<packet id> <translate key>
*> closed" for a disconnect followed by the close flag.
 DESCRIBE-OUTPUT.
     MOVE "T" TO TL-MODE
     CALL "PB-RESET" USING PB-BUFFER
     CALL "TEST-DRAIN" USING WS-ID PB-BUFFER WS-CLOSE
     CALL "TEST-NEXT-PACKET" USING PB-BUFFER PK-BUFFER WS-THRESHOLD WS-PACKET-ID WS-OUTCOME
     MOVE SPACES TO TL-OBSERVED
     EVALUATE TRUE
         WHEN WS-OUTCOME NOT = 0
             MOVE "none" TO TL-OBSERVED
         WHEN WS-PACKET-ID = 4 OR WS-PACKET-ID = 45
             CALL "PB-GET-LONG" USING PK-BUFFER WS-LONG
             MOVE WS-PACKET-ID TO WS-EDIT
             STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO TL-OBSERVED
             MOVE WS-LONG TO WS-EDIT
             STRING FUNCTION TRIM(TL-OBSERVED) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
                 INTO TL-OBSERVED
         WHEN OTHER
             CALL "PB-GET-TEXT" USING PK-BUFFER PB-TEXT
             MOVE WS-PACKET-ID TO WS-EDIT
             MOVE SPACES TO WS-DESCRIPTION
             IF WS-CLOSE = 1
                 MOVE "closed" TO WS-DESCRIPTION
             END-IF
             STRING FUNCTION TRIM(WS-EDIT) " " PB-TX-VALUE(1:PB-TX-LENGTH) " " WS-DESCRIPTION
                 DELIMITED BY SIZE INTO TL-OBSERVED
     END-EVALUATE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-KEEPALIVE.

 COPY CORETEST.
