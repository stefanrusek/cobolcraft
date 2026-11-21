*> Implementation test of the console text of vanilla death messages (core/src/console.cob; T5003): a
*> translate text of a standard death key is shown as its en_us text with %1$s, %2$s and %3$s taking the
*> arguments by position (the texts are those of docs/protocol/17-tools-weapons-and-combat.md 4.13.2 and
*> 4.13.3), so the console echo of a death is a sentence and not the raw key.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONSOLE-DEATH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY PROTO.
 COPY CONSOLEDEATH.
 01 WS-AREA                PIC X(4096).
 01 WS-TEXT                PIC X(4096).
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-ARGS                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-SHOWN               PIC 9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM DRAIN

     MOVE "test console death a mob kill is the vanilla sentence" TO TL-CASE
     MOVE "death.attack.mob" TO WS-KEY
     MOVE 2 TO WS-ARGS
     PERFORM SEND-TEXT
     MOVE "Steve was slain by Zombie" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test console death the item form takes the third argument" TO TL-CASE
     MOVE "death.attack.mob.item" TO WS-KEY
     MOVE 3 TO WS-ARGS
     PERFORM SEND-TEXT
     MOVE "Steve was slain by Zombie using [Zing]" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test console death a message with the victim alone" TO TL-CASE
     MOVE "death.attack.genericKill" TO WS-KEY
     MOVE 1 TO WS-ARGS
     PERFORM SEND-TEXT
     MOVE "Steve was killed" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test console death the credit form" TO TL-CASE
     MOVE "death.attack.fall.player" TO WS-KEY
     MOVE 2 TO WS-ARGS
     PERFORM SEND-TEXT
     MOVE "Steve hit the ground too hard while trying to escape Zombie" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test console death a fall from a height" TO TL-CASE
     MOVE "death.fell.accident.generic" TO WS-KEY
     MOVE 1 TO WS-ARGS
     PERFORM SEND-TEXT
     MOVE "Steve fell from a high place" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test console death the assist form" TO TL-CASE
     MOVE "death.fell.assist" TO WS-KEY
     MOVE 2 TO WS-ARGS
     PERFORM SEND-TEXT
     MOVE "Steve was doomed to fall by Zombie" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test console death every key the core names has a text" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DT-COUNT
         MOVE DT-KEY(WS-I) TO WS-KEY
         MOVE DT-KEY-LENGTH(WS-I) TO WS-KEY-LENGTH
         MOVE 3 TO WS-ARGS
         PERFORM QUEUE-TEXT
     END-PERFORM
     PERFORM DRAIN
     MOVE 0 TO WS-COUNT
     INSPECT WS-TEXT TALLYING WS-COUNT FOR ALL "death."
     MOVE WS-COUNT TO WS-SHOWN
     MOVE WS-SHOWN TO TL-OBSERVED
     MOVE "0" TO TL-EXPECTED
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 SEND-TEXT.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY)) TO WS-KEY-LENGTH
     PERFORM QUEUE-TEXT
     PERFORM DRAIN.

 QUEUE-TEXT.
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE WS-KEY TO PB-TX-VALUE
     MOVE WS-KEY-LENGTH TO PB-TX-LENGTH
     MOVE WS-ARGS TO PB-TX-ARG-COUNT
     MOVE "Steve" TO PB-TX-ARG-VALUE(1)
     MOVE 5 TO PB-TX-ARG-LENGTH(1)
     MOVE "Zombie" TO PB-TX-ARG-VALUE(2)
     MOVE 6 TO PB-TX-ARG-LENGTH(2)
     MOVE "[Zing]" TO PB-TX-ARG-VALUE(3)
     MOVE 6 TO PB-TX-ARG-LENGTH(3)
     CALL "CONSOLE-TEXT" USING PB-TEXT.

 DRAIN.
     MOVE SPACES TO WS-AREA WS-TEXT
     SET CB-ADDR TO ADDRESS OF WS-AREA
     MOVE 4096 TO CB-CAPACITY
     CALL "CORE-CONSOLE-DRAIN" USING CORE-BUFFER
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-LENGTH
         IF WS-AREA(WS-I:1) = X"0A"
             IF WS-I < CB-LENGTH
                 STRING " | " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-IF
         ELSE
             STRING WS-AREA(WS-I:1) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CONSOLE-DEATH.

 COPY CORETEST.
