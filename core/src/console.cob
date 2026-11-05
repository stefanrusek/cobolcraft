*> Console lines (contracts/operator-surface.md §3; core-host-api §2 CORE-CONSOLE-DRAIN): the queue
*> of pending lines (CW-CONSOLE, UTF-8, each ended by a line feed) that the host drains and prints.
*> Messages the core sends to players as `translate` components are queued as the en_us text of their
*> key (core/copy/CONSOLELANG.cpy; docs/protocol/08-resource-packs.md §10.8 rules: each "%s" takes
*> the next argument, an unknown key shows as the key itself).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONSOLE-DRAIN.
*> USING CORE-BUFFER: moves up to CB-CAPACITY bytes of pending console lines into the buffer
*> (CB-LENGTH = bytes moved); the rest stays queued.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-COUNT               BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 B-QUEUE                PIC X(1073741824) BASED.
 01 B-HOST                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION USING CORE-BUFFER.
     MOVE CW-CONSOLE TO PB-BUFFER
     COMPUTE WS-COUNT = FUNCTION MIN(PB-LENGTH, CB-CAPACITY)
     MOVE WS-COUNT TO CB-LENGTH
     IF WS-COUNT > 0
         SET ADDRESS OF B-QUEUE TO PB-ADDR
         SET ADDRESS OF B-HOST TO CB-ADDR
         MOVE B-QUEUE(1:WS-COUNT) TO B-HOST(1:WS-COUNT)
         COMPUTE WS-REST = PB-LENGTH - WS-COUNT
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-REST
             MOVE B-QUEUE(WS-COUNT + WS-I:1) TO B-QUEUE(WS-I:1)
         END-PERFORM
         MOVE WS-REST TO PB-LENGTH
         MOVE PB-BUFFER TO CW-CONSOLE
     END-IF
     GOBACK.
 END PROGRAM CONSOLE-DRAIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CONSOLE-TEXT.
*> USING PB-TEXT: queues the text as one console line: a plain or literal text as it is; a
*> `translate` text as the en_us text of its key (the key itself when CONSOLELANG.cpy has no such
*> key) with each "%s" replaced by the next argument (an empty text once the arguments run out).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONSOLELANG.
 01 WS-LINE                PIC X(4096).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-TEMPLATE            PIC X(1024).
 01 WS-TEMPLATE-LENGTH     BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 PROCEDURE DIVISION USING PB-TEXT.
     MOVE SPACES TO WS-LINE
     MOVE 0 TO WS-LENGTH
     IF PB-TX-KIND NOT = PB-TEXT-TRANSLATE
         MOVE PB-TX-VALUE(1:PB-TX-LENGTH) TO WS-LINE
         MOVE PB-TX-LENGTH TO WS-LENGTH
         CALL "CORE-LOG" USING WS-LINE WS-LENGTH
         GOBACK
     END-IF
     MOVE PB-TX-VALUE TO WS-TEMPLATE
     MOVE PB-TX-LENGTH TO WS-TEMPLATE-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-COUNT
         IF CL-KEY-LENGTH(WS-I) = PB-TX-LENGTH
                 AND CL-KEY(WS-I)(1:CL-KEY-LENGTH(WS-I)) = PB-TX-VALUE(1:PB-TX-LENGTH)
             MOVE CL-TEXT(WS-I) TO WS-TEMPLATE
             MOVE CL-TEXT-LENGTH(WS-I) TO WS-TEMPLATE-LENGTH
         END-IF
     END-PERFORM
     MOVE 1 TO WS-ARG
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I > WS-TEMPLATE-LENGTH
         IF WS-TEMPLATE(WS-I:2) = "%s" AND WS-I < WS-TEMPLATE-LENGTH
             IF WS-ARG <= PB-TX-ARG-COUNT AND PB-TX-ARG-LENGTH(WS-ARG) > 0
                 MOVE PB-TX-ARG-VALUE(WS-ARG)(1:PB-TX-ARG-LENGTH(WS-ARG))
                     TO WS-LINE(WS-LENGTH + 1:PB-TX-ARG-LENGTH(WS-ARG))
                 ADD PB-TX-ARG-LENGTH(WS-ARG) TO WS-LENGTH
             END-IF
             ADD 1 TO WS-ARG
             ADD 2 TO WS-I
         ELSE
             MOVE WS-TEMPLATE(WS-I:1) TO WS-LINE(WS-LENGTH + 1:1)
             ADD 1 TO WS-LENGTH
             ADD 1 TO WS-I
         END-IF
     END-PERFORM
     CALL "CORE-LOG" USING WS-LINE WS-LENGTH
     GOBACK.
 END PROGRAM CONSOLE-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-LOG.
*> USING text area, byte length (BINARY-LONG): queues one console line (the text and a line feed)
*> for CORE-CONSOLE-DRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-LF                  PIC X VALUE X"0A".
 01 WS-ONE                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH.
     MOVE CW-CONSOLE TO PB-BUFFER
     CALL "PB-APPEND-BYTES" USING PB-BUFFER L-TEXT L-LENGTH
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-LF WS-ONE
     MOVE PB-BUFFER TO CW-CONSOLE
     GOBACK.
 END PROGRAM CORE-LOG.
