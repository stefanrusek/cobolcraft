*> Function files (docs/protocol/15-commands-framework.md §12 Functions): the line rules of CommandFunction.fromLines and the macro lines.
*> Calling a function (the function command, tags, the macro argument compound and the cache of 8 instantiated functions) is BLOCKED; the 2,000,000
*> character limit of a joined line (an IllegalStateException) is BLOCKED because a line here is at most 1024 bytes.
*>
*> Entry points:
*>   FN-JOIN USING text (PIC X(8192), lines separated by LF), byte length, joined out (PIC X(8192), the lines after the continuations, separated by
*>     LF), joined length out, status out (0 ok, 1 a continuation on the last line: message "Line continuation at end of file"), message out (PIC X(64)):
*>     each line is trimmed on both sides; a line that ends with a backslash loses it and the next line, trimmed too, is appended; this repeats
*>   FN-READ-LINE USING line (PIC X(1024), one joined line), length, line number (1-based), kind out (0 a comment or an empty line, 1 a command,
*>     2 a macro line, 3 refused), message out (PIC X(256)): a line that starts with / is refused ("Unknown or invalid command '<line>' on line N", then
*>     "(if you intended to make a comment, use '#' not '//')" when it starts with //, else "(did you mean '<line without the />'? Do not use a preceding
*>     forwards slash.)"); # and an empty line are comments; $ starts a macro line; anything else is a command
*>   FN-MACRO-VARS USING macro line (PIC X(1024), without the $), length, variable count out, status out (0 ok, 1 Unterminated macro variable,
*>     2 invalid variable name, 3 No variables in macro), message out (PIC X(64)): the variables are $(name) with name of letters, digits and _

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FN-JOIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 01 WS-END                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-ACC                 PIC X(8192).
 01 WS-ACC-LENGTH          BINARY-LONG.
 01 WS-OUT                 BINARY-LONG.
 01 WS-OPEN                BINARY-LONG.
 01 WS-LF                  PIC X VALUE X"0A".
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(8192).
 01 L-LENGTH               BINARY-LONG.
 01 L-JOINED               PIC X(8192).
 01 L-JOINED-LENGTH        BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 01 L-MESSAGE              PIC X(64).
 PROCEDURE DIVISION USING L-TEXT L-LENGTH L-JOINED L-JOINED-LENGTH L-STATUS L-MESSAGE.
     GO TO MAIN-LINE.

*> Appends the next physical line from WS-POS, trimmed on both sides, to WS-ACC; WS-POS moves past its LF.
 NEXT-PHYSICAL.
     MOVE WS-POS TO WS-END
     PERFORM UNTIL WS-END > L-LENGTH OR L-TEXT(WS-END:1) = WS-LF
         ADD 1 TO WS-END
     END-PERFORM
     MOVE WS-POS TO WS-START
     COMPUTE WS-STOP = WS-END - 1
     PERFORM UNTIL WS-START > WS-STOP OR (L-TEXT(WS-START:1) NOT = SPACE AND L-TEXT(WS-START:1) NOT = X"09"
             AND L-TEXT(WS-START:1) NOT = X"0D")
         ADD 1 TO WS-START
     END-PERFORM
     PERFORM UNTIL WS-STOP < WS-START OR (L-TEXT(WS-STOP:1) NOT = SPACE AND L-TEXT(WS-STOP:1) NOT = X"09"
             AND L-TEXT(WS-STOP:1) NOT = X"0D")
         SUBTRACT 1 FROM WS-STOP
     END-PERFORM
     IF WS-STOP >= WS-START
         COMPUTE WS-LINE-LENGTH = WS-STOP - WS-START + 1
         MOVE L-TEXT(WS-START:WS-LINE-LENGTH) TO WS-ACC(WS-ACC-LENGTH + 1:WS-LINE-LENGTH)
         ADD WS-LINE-LENGTH TO WS-ACC-LENGTH
     END-IF
     COMPUTE WS-POS = WS-END + 1.

 MAIN-LINE.
     MOVE SPACES TO L-JOINED L-MESSAGE WS-ACC
     MOVE 0 TO L-JOINED-LENGTH L-STATUS WS-OUT
     MOVE 1 TO WS-POS
     PERFORM UNTIL WS-POS > L-LENGTH OR L-STATUS NOT = 0
         MOVE 0 TO WS-ACC-LENGTH
         PERFORM NEXT-PHYSICAL
         MOVE 1 TO WS-OPEN
         PERFORM UNTIL WS-OPEN = 0
             MOVE 0 TO WS-OPEN
             IF WS-ACC-LENGTH > 0
                 IF WS-ACC(WS-ACC-LENGTH:1) = "\"
                     SUBTRACT 1 FROM WS-ACC-LENGTH
                     IF WS-POS > L-LENGTH
                         MOVE 1 TO L-STATUS
                         MOVE "Line continuation at end of file" TO L-MESSAGE
                     ELSE
                         PERFORM NEXT-PHYSICAL
                         MOVE 1 TO WS-OPEN
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF L-STATUS = 0
             IF WS-OUT > 0
                 ADD 1 TO WS-OUT
                 MOVE WS-LF TO L-JOINED(WS-OUT:1)
             END-IF
             IF WS-ACC-LENGTH > 0
                 MOVE WS-ACC(1:WS-ACC-LENGTH) TO L-JOINED(WS-OUT + 1:WS-ACC-LENGTH)
                 ADD WS-ACC-LENGTH TO WS-OUT
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-OUT TO L-JOINED-LENGTH
     GOBACK.
 END PROGRAM FN-JOIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FN-READ-LINE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-EDIT                PIC Z(9)9.
 01 WS-POS                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-LINE                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 01 L-NUMBER               BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-MESSAGE              PIC X(256).
 PROCEDURE DIVISION USING L-LINE L-LENGTH L-NUMBER L-KIND L-MESSAGE.
     GO TO MAIN-LINE.

 MAIN-LINE.
     MOVE SPACES TO L-MESSAGE
     MOVE L-NUMBER TO WS-EDIT
     MOVE 1 TO WS-POS
     EVALUATE TRUE
         WHEN L-LENGTH = 0
             MOVE 0 TO L-KIND
         WHEN L-LINE(1:1) = "#"
             MOVE 0 TO L-KIND
         WHEN L-LINE(1:1) = "$"
             MOVE 2 TO L-KIND
         WHEN L-LINE(1:1) = "/"
             MOVE 3 TO L-KIND
             STRING "Unknown or invalid command '" L-LINE(1:L-LENGTH) "' on line "
                 FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO L-MESSAGE WITH POINTER WS-POS
             IF L-LENGTH > 1 AND L-LINE(2:1) = "/"
                 STRING " (if you intended to make a comment, use '#' not '//')" DELIMITED BY SIZE
                     INTO L-MESSAGE WITH POINTER WS-POS
             ELSE
                 STRING " (did you mean '" L-LINE(2:L-LENGTH - 1) "'? Do not use a preceding forwards slash.)"
                     DELIMITED BY SIZE INTO L-MESSAGE WITH POINTER WS-POS
             END-IF
         WHEN OTHER
             MOVE 1 TO L-KIND
     END-EVALUATE
     GOBACK.
 END PROGRAM FN-READ-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FN-MACRO-VARS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-CH                  PIC X.
 LINKAGE SECTION.
 01 L-LINE                 PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 01 L-MESSAGE              PIC X(64).
 PROCEDURE DIVISION USING L-LINE L-LENGTH L-COUNT L-STATUS L-MESSAGE.
     GO TO MAIN-LINE.

 MAIN-LINE.
     MOVE 0 TO L-COUNT L-STATUS
     MOVE SPACES TO L-MESSAGE
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I > L-LENGTH OR L-STATUS NOT = 0
         IF L-LINE(WS-I:1) = "$" AND WS-I < L-LENGTH AND L-LINE(WS-I + 1:1) = "("
             COMPUTE WS-J = WS-I + 2
             PERFORM UNTIL WS-J > L-LENGTH OR L-LINE(WS-J:1) = ")"
                 MOVE L-LINE(WS-J:1) TO WS-CH
                 IF NOT ((WS-CH >= "a" AND WS-CH <= "z") OR (WS-CH >= "A" AND WS-CH <= "Z")
                         OR (WS-CH >= "0" AND WS-CH <= "9") OR WS-CH = "_")
                     MOVE 2 TO L-STATUS
                     MOVE "Invalid macro variable name" TO L-MESSAGE
                 END-IF
                 ADD 1 TO WS-J
             END-PERFORM
             IF WS-J > L-LENGTH AND L-STATUS = 0
                 MOVE 1 TO L-STATUS
                 MOVE "Unterminated macro variable" TO L-MESSAGE
             END-IF
             IF L-STATUS = 0 AND WS-J = WS-I + 2
                 MOVE 2 TO L-STATUS
                 MOVE "Invalid macro variable name" TO L-MESSAGE
             END-IF
             ADD 1 TO L-COUNT
             MOVE WS-J TO WS-I
         END-IF
         ADD 1 TO WS-I
     END-PERFORM
     IF L-STATUS = 0 AND L-COUNT = 0
         MOVE 3 TO L-STATUS
         MOVE "No variables in macro" TO L-MESSAGE
     END-IF
     GOBACK.
 END PROGRAM FN-MACRO-VARS.
