*> English rendering of framework translation keys (docs/protocol/15-commands-framework.md §5;
*> core/copy/BRLANG.cpy), as the console prints them (operator-surface: a console line is the en_us text).
*>
*> Entry point:
*>   BR-LANG-TEXT USING PB-TEXT, text out (PIC X(1024)), length out: a plain or literal component is its
*>     text; a translate component is the table text of its key with %s (the next argument) and %n$s
*>     (argument n) replaced by the component's string arguments; a key not in the table is the key.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BR-LANG-TEXT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY BRLANG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TEMPLATE            PIC X(200).
 01 WS-TEMPLATE-LENGTH     BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NEXT-ARG            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TEXT                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING PB-TEXT L-TEXT L-LENGTH.
     GO TO MAIN-LINE.

*> Argument WS-N (nothing when the component has fewer).
 PUT-ARGUMENT.
     IF WS-N <= PB-TX-ARG-COUNT
         MOVE PB-TX-ARG-VALUE(WS-N)(1:PB-TX-ARG-LENGTH(WS-N)) TO L-TEXT(WS-POS:PB-TX-ARG-LENGTH(WS-N))
         ADD PB-TX-ARG-LENGTH(WS-N) TO WS-POS
     END-IF.

 MAIN-LINE.
     MOVE SPACES TO L-TEXT
     IF PB-TX-KIND NOT = PB-TEXT-TRANSLATE
         MOVE PB-TX-VALUE(1:PB-TX-LENGTH) TO L-TEXT
         MOVE PB-TX-LENGTH TO L-LENGTH
         GOBACK
     END-IF
     MOVE 0 TO WS-FOUND
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > LG-COUNT OR WS-FOUND = 1
         IF LG-KEY(WS-ROW) = PB-TX-VALUE(1:PB-TX-LENGTH)
             MOVE 1 TO WS-FOUND
             MOVE LG-TEXT(WS-ROW) TO WS-TEMPLATE
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         MOVE PB-TX-VALUE(1:PB-TX-LENGTH) TO L-TEXT
         MOVE PB-TX-LENGTH TO L-LENGTH
         GOBACK
     END-IF
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-TEMPLATE TRAILING)) TO WS-TEMPLATE-LENGTH
     MOVE 1 TO WS-POS
     MOVE 1 TO WS-NEXT-ARG
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I > WS-TEMPLATE-LENGTH
         EVALUATE TRUE
             WHEN WS-TEMPLATE(WS-I:1) = "%" AND WS-I < WS-TEMPLATE-LENGTH
                     AND WS-TEMPLATE(WS-I + 1:1) = "s"
                 MOVE WS-NEXT-ARG TO WS-N
                 ADD 1 TO WS-NEXT-ARG
                 PERFORM PUT-ARGUMENT
                 ADD 2 TO WS-I
             WHEN WS-TEMPLATE(WS-I:1) = "%" AND WS-I + 2 < WS-TEMPLATE-LENGTH
                     AND WS-TEMPLATE(WS-I + 1:1) >= "1" AND WS-TEMPLATE(WS-I + 1:1) <= "9"
                     AND WS-TEMPLATE(WS-I + 2:2) = "$s"
                 COMPUTE WS-N = FUNCTION ORD(WS-TEMPLATE(WS-I + 1:1)) - FUNCTION ORD("0")
                 PERFORM PUT-ARGUMENT
                 ADD 4 TO WS-I
             WHEN OTHER
                 MOVE WS-TEMPLATE(WS-I:1) TO L-TEXT(WS-POS:1)
                 ADD 1 TO WS-POS
                 ADD 1 TO WS-I
         END-EVALUATE
     END-PERFORM
     COMPUTE L-LENGTH = WS-POS - 1.
 END PROGRAM BR-LANG-TEXT.
