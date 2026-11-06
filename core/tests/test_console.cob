*> Implementation test of the console line queue (core/src/console.cob; contracts/operator-surface.md
*> §3; docs/protocol/08-resource-packs.md §10.8 rules): CONSOLE-TEXT queues a plain or literal text
*> as it is; a `translate` text as its en_us text with each "%s" taking the next argument (none once
*> the arguments run out, an empty argument adds nothing); a key CONSOLELANG.cpy does not have shows
*> as the key itself. CONSOLE-DRAIN hands the lines out.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CONSOLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY COREAPI.
 COPY PROTO.
 01 WS-AREA                PIC X(4096).
 01 WS-TEXT                PIC X(4096).
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     PERFORM DRAIN

     MOVE "test console a plain text and a literal text are queued as they are" TO TL-CASE
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-PLAIN TO PB-TX-KIND
     MOVE "plain words" TO PB-TX-VALUE
     MOVE 11 TO PB-TX-LENGTH
     CALL "CONSOLE-TEXT" USING PB-TEXT
     MOVE PB-TEXT-LITERAL TO PB-TX-KIND
     MOVE "literal" TO PB-TX-VALUE
     MOVE 7 TO PB-TX-LENGTH
     CALL "CONSOLE-TEXT" USING PB-TEXT
     PERFORM DRAIN
     MOVE "plain words | literal" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test console a translate text with fewer arguments than %s, or an empty one, leaves "
         & "those out" TO TL-CASE
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE "cobolcraft.death.player" TO PB-TX-VALUE
     MOVE 23 TO PB-TX-LENGTH
     MOVE 1 TO PB-TX-ARG-COUNT
     MOVE "Bob" TO PB-TX-ARG-VALUE(1)
     MOVE 3 TO PB-TX-ARG-LENGTH(1)
     CALL "CONSOLE-TEXT" USING PB-TEXT
     MOVE 2 TO PB-TX-ARG-COUNT
     MOVE 0 TO PB-TX-ARG-LENGTH(1)
     MOVE "Ann" TO PB-TX-ARG-VALUE(2)
     MOVE 3 TO PB-TX-ARG-LENGTH(2)
     CALL "CONSOLE-TEXT" USING PB-TEXT
     PERFORM DRAIN
     MOVE "Bob lost a duel with  |  lost a duel with Ann" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test console a translate key without an en_us text shows as the key" TO TL-CASE
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE "cobolcraft.no.such.key" TO PB-TX-VALUE
     MOVE 22 TO PB-TX-LENGTH
     CALL "CONSOLE-TEXT" USING PB-TEXT
     PERFORM DRAIN
     MOVE "cobolcraft.no.such.key" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

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
 END PROGRAM TEST-CONSOLE.

 COPY CORETEST.
