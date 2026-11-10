*> Acceptance test of the error decision and presentation of docs/protocol/15-commands-framework.md
*> §4 Tokenising and parsing: §4.5 (the decision after a parse, 15 §15.1 examples) and §4.6 (the two System
*> Chat lines: the raw message red; the context line gray with a suggest_command click event of "/" and
*> the input, "..." when the cursor is above 10, the up to ten characters before the cursor, the rest
*> red and underlined, then the translated command.context.here red and italic). The tree: gamemode
*> (level 2, no command, argument mode), demo (n integer 1..10), name (s string), b (flag bool) and a
*> literal of 24 characters with an integer child. The message reads key(args)/color, the context
*> "/input" then each extra as [text/color/flags] (U underlined, I italic, T translate).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==RS-==.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==PK-==.
 01 WS-CASES.
    05 FILLER PIC X(64) VALUE "foo$".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(80) VALUE "command.unknown.command/red".
    05 FILLER PIC X(220) VALUE "/foo [foo/red/U] [command.context.here/red/IT]".
    05 FILLER PIC X(64) VALUE "gamemode$".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(80) VALUE "command.unknown.command/red".
    05 FILLER PIC X(220) VALUE "/gamemode [gamemode/gray/] [command.context.here/red/IT]".
    05 FILLER PIC X(64) VALUE "gamemode $".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(80) VALUE "command.unknown.argument/red".
    05 FILLER PIC X(220) VALUE "/gamemode  [gamemode/gray/] [ /red/U] [command.context.here/red/IT]".
    05 FILLER PIC X(64) VALUE "demo 11$".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(80) VALUE "argument.integer.big(10,11)/red".
    05 FILLER PIC X(220) VALUE "/demo 11 [demo /gray/] [11/red/U] [command.context.here/red/IT]".
    05 FILLER PIC X(64) VALUE "demo 5x$".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(80) VALUE "command.expected.separator/red".
    05 FILLER PIC X(220) VALUE "/demo 5x [demo 5/gray/] [x/red/U] [command.context.here/red/IT]".
    05 FILLER PIC X(64) VALUE "demo abc$".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(80) VALUE "parsing.int.expected/red".
    05 FILLER PIC X(220) VALUE "/demo abc [demo /gray/] [abc/red/U] [command.context.here/red/IT]".
    05 FILLER PIC X(64) VALUE 'name "a\nb"$'.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(80) VALUE "parsing.quote.escape(n)/red".
    05 FILLER PIC X(220) VALUE '/name "a\nb" [name "a\/gray/] [nb"/red/U] [command.context.here/red/IT]'.
    05 FILLER PIC X(64) VALUE 'name "abc$'.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(80) VALUE "parsing.quote.expected.end/red".
    05 FILLER PIC X(220) VALUE '/name "abc [name "abc/gray/] [command.context.here/red/IT]'.
    05 FILLER PIC X(64) VALUE "longname1234567890abcdef zzzzzzzzzzzzzzz$".
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC X(80) VALUE "parsing.int.expected/red".
    05 FILLER PIC X(220) VALUE "/longname1234567890abcdef zzzzzzzzzzzzzzz [...//] [890abcdef /gray/] [zzzzzzzzzzzzzzz/red/U] [command.context.here/red/IT]".
 01 WS-TABLE REDEFINES WS-CASES.
    05 WS-CASE              OCCURS 9 TIMES.
       10 WS-CASE-LINE       PIC X(64).
       10 WS-CASE-LEVEL      PIC 9.
       10 WS-CASE-MESSAGE    PIC X(80).
       10 WS-CASE-CONTEXT    PIC X(220).
 01 WS-LINE                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-VERDICT             BINARY-LONG.
 01 WS-COMMAND             BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-HAS                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM BUILD-TREE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE WS-CASE-LINE(WS-I) TO WS-LINE
         MOVE WS-CASE-LEVEL(WS-I) TO WS-LEVEL
         PERFORM CHECK
     END-PERFORM
     GOBACK.

 ADD-NODE.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED.

 LITERAL-NODE.
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE
     PERFORM ADD-NODE.

 ARGUMENT-NODE.
     MOVE BR-ARGUMENT TO WS-KIND
     PERFORM ADD-NODE.

 BUILD-TREE.
     CALL "BR-TREE-RESET"
     MOVE 1 TO WS-NODE
     MOVE "gamemode" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE 2 TO BR-N-LEVEL(WS-CHILD)
     MOVE WS-CHILD TO WS-NODE
     MOVE "mode" TO WS-NAME
     MOVE BR-P-INTEGER TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 1 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "demo" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "n" TO WS-NAME
     MOVE BR-P-INTEGER TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 2 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO BR-N-HAS-MIN(WS-CHILD) BR-N-HAS-MAX(WS-CHILD)
     MOVE 1 TO BR-N-IMIN(WS-CHILD)
     MOVE 10 TO BR-N-IMAX(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "name" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "s" TO WS-NAME
     MOVE BR-P-STRING TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 3 TO BR-N-COMMAND(WS-CHILD)
     MOVE BR-S-PHRASE TO BR-N-STRING-KIND(WS-CHILD)
     MOVE 1 TO WS-NODE
     MOVE "longname1234567890abcdef" TO WS-NAME
     PERFORM LITERAL-NODE
     MOVE WS-CHILD TO WS-NODE
     MOVE "k" TO WS-NAME
     MOVE BR-P-INTEGER TO WS-TYPE
     PERFORM ARGUMENT-NODE
     MOVE 4 TO BR-N-COMMAND(WS-CHILD).

 CHECK.
     MOVE 0 TO WS-LENGTH
     INSPECT WS-LINE TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL "$"
     MOVE SPACE TO WS-LINE(WS-LENGTH + 1:1)
     CALL "BR-PARSE" USING WS-LEVEL WS-LINE WS-LENGTH RS-TRAIL
     CALL "BR-VERDICT" USING RS-TRAIL WS-VERDICT WS-COMMAND
     INITIALIZE PB-TEXT PK-TEXT
     CALL "BR-ERROR-TEXT" USING PB-TEXT PK-TEXT WS-HAS
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     STRING FUNCTION TRIM(PB-TX-VALUE(1:PB-TX-LENGTH)) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     IF PB-TX-ARG-COUNT > 0
         STRING "(" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > PB-TX-ARG-COUNT
             IF WS-E > 1
                 STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             END-IF
             STRING PB-TX-ARG-VALUE(WS-E)(1:PB-TX-ARG-LENGTH(WS-E)) DELIMITED BY SIZE
                 INTO WS-TEXT WITH POINTER WS-POS
         END-PERFORM
         STRING ")" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     STRING "/" FUNCTION TRIM(PB-TX-COLOR) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US13 15§4 Tokenising and parsing message [" WS-LINE(1:WS-LENGTH) "]"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-CASE-MESSAGE(WS-I) TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     STRING "/" PK-TX-CLICK(2:PK-TX-CLICK-LENGTH - 1) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > PK-TX-EXTRA-COUNT
         STRING " [" PK-TXE-VALUE(WS-E)(1:PK-TXE-LENGTH(WS-E)) "/" FUNCTION TRIM(PK-TXE-COLOR(WS-E)) "/"
             DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         IF PK-TXE-UNDERLINED(WS-E) = 1
             STRING "U" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-IF
         IF PK-TXE-ITALIC(WS-E) = 1
             STRING "I" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-IF
         IF PK-TXE-KIND(WS-E) = PB-TEXT-TRANSLATE
             STRING "T" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-IF
         STRING "]" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US13 15§4 Tokenising and parsing context [" WS-LINE(1:WS-LENGTH) "]"
         DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-CASE-CONTEXT(WS-I) TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-CMD-15-4.
