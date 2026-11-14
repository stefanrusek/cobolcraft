*> Acceptance test of docs/protocol/15a-brigadier-command-library.md §8 Messages and exceptions: each exception of the provider
*> table (key, arguments in the order the framework raises them, cursor) and the text a player sees (the game text of 15 §5.1, the
*> library column of §8 differs where its last column says so: comma versus colon, the escape with a backslash, Invalid boolean).
*> The tree has one literal per argument type: i integer 1 to 10, l long -5 to 5, f float 0 to 1, d double -1 to 1, b bool, s string
*> phrase, w word, g greedy string, and foo with the children n (integer 1 to 10) and bar. The result is "key|args@cursor|text".
*> Not produced by a parse of this tree: literalIncorrect (the word is matched before the literal is parsed, §2.5: only a literal
*> holding a space can fail), readerExpectedStartOfQuote (readQuotedString only; no node here uses it) and dispatcherParseException
*> (a runtime exception inside a type; none of the stock types raises one) - these rows are checked by name in their cases below.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-15A-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 COPY PROTO.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==RS-==.
 01 WS-CASES.
    05 FILLER PIC X(120) VALUE "i 11$".
    05 FILLER PIC X(240) VALUE "argument.integer.big|10|11@2|Integer must not " & "be more than 10: found 11".
    05 FILLER PIC X(120) VALUE "i 0$".
    05 FILLER PIC X(240) VALUE "argument.integer.low|1|0@2|Integer must not be" & " less than 1: found 0".
    05 FILLER PIC X(120) VALUE "l 6$".
    05 FILLER PIC X(240) VALUE "argument.long.big|5|6@2|Long must not be more " & "than 5: found 6".
    05 FILLER PIC X(120) VALUE "l -6$".
    05 FILLER PIC X(240) VALUE "argument.long.low|-5|-6@2|Long must not be les" & "s than -5: found -6".
    05 FILLER PIC X(120) VALUE "f 2$".
    05 FILLER PIC X(240) VALUE "argument.float.big|1.0|2.0@2|Float must not be" & " more than 1.0: found 2.0".
    05 FILLER PIC X(120) VALUE "f -0.5$".
    05 FILLER PIC X(240) VALUE "argument.float.low|0.0|-0.5@2|Float must not b" & "e less than 0.0: found -0.5".
    05 FILLER PIC X(120) VALUE "d 1.5$".
    05 FILLER PIC X(240) VALUE "argument.double.big|1.0|1.5@2|Double must not " & "be more than 1.0: found 1.5".
    05 FILLER PIC X(120) VALUE "d -1.5$".
    05 FILLER PIC X(240) VALUE "argument.double.low|-1.0|-1.5@2|Double must no" & "t be less than -1.0: found -1.5".
    05 FILLER PIC X(120) VALUE "i abc$".
    05 FILLER PIC X(240) VALUE "parsing.int.expected@2|Expected integer".
    05 FILLER PIC X(120) VALUE "i 1.5$".
    05 FILLER PIC X(240) VALUE "parsing.int.invalid|1.5@2|Invalid integer '1.5" & "'".
    05 FILLER PIC X(120) VALUE "l abc$".
    05 FILLER PIC X(240) VALUE "parsing.long.expected@2|Expected long".
    05 FILLER PIC X(120) VALUE "l 1.5$".
    05 FILLER PIC X(240) VALUE "parsing.long.invalid|1.5@2|Invalid long '1.5'".
    05 FILLER PIC X(120) VALUE "f abc$".
    05 FILLER PIC X(240) VALUE "parsing.float.expected@2|Expected float".
    05 FILLER PIC X(120) VALUE "f 1.5.2$".
    05 FILLER PIC X(240) VALUE "parsing.float.invalid|1.5.2@2|Invalid float '1" & ".5.2'".
    05 FILLER PIC X(120) VALUE "d abc$".
    05 FILLER PIC X(240) VALUE "parsing.double.expected@2|Expected double".
    05 FILLER PIC X(120) VALUE "d 1.5.2$".
    05 FILLER PIC X(240) VALUE "parsing.double.invalid|1.5.2@2|Invalid double " & "'1.5.2'".
    05 FILLER PIC X(120) VALUE "b yes$".
    05 FILLER PIC X(240) VALUE "parsing.bool.invalid|yes@2|Invalid boolean: ex" & "pected 'true' or 'false' but found 'yes'".
    05 FILLER PIC X(120) VALUE "b """"$".
    05 FILLER PIC X(240) VALUE "parsing.bool.expected@4|Expected boolean".
    05 FILLER PIC X(120) VALUE "b ""50%""$".
    05 FILLER PIC X(240) VALUE "parsing.bool.invalid|50%@2|Invalid boolean: ex" & "pected 'true' or 'false' but found '50%'".
    05 FILLER PIC X(120) VALUE "s ""a\'b""$".
    05 FILLER PIC X(240) VALUE "parsing.quote.escape|'@5|Invalid escape sequen" & "ce '\'' in quoted string".
    05 FILLER PIC X(120) VALUE "s ""a\nb""$".
    05 FILLER PIC X(240) VALUE "parsing.quote.escape|n@5|Invalid escape sequen" & "ce '\n' in quoted string".
    05 FILLER PIC X(120) VALUE "s ""abc$".
    05 FILLER PIC X(240) VALUE "parsing.quote.expected.end@6|Unclosed quoted s" & "tring".
    05 FILLER PIC X(120) VALUE "foo 5x$".
    05 FILLER PIC X(240) VALUE "command.expected.separator@5|Expected whitespa" & "ce to end one argument, but found trailing dat" & "a".
    05 FILLER PIC X(120) VALUE "foo bogus$".
    05 FILLER PIC X(240) VALUE "parsing.int.expected@4|Expected integer".
    05 FILLER PIC X(120) VALUE "bogus$".
    05 FILLER PIC X(240) VALUE "command.unknown.command@0|Unknown or incomplet" & "e command. See below for error".
    05 FILLER PIC X(120) VALUE "foo 5 $".
    05 FILLER PIC X(240) VALUE "command.unknown.argument@5|Incorrect argument " & "for command".
    05 FILLER PIC X(120) VALUE "foo bar$".
    05 FILLER PIC X(240) VALUE "ok".
 01 WS-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 27 TIMES.
       10 WS-CASE-LINE PIC X(120).
       10 WS-CASE-EXPECTED PIC X(240).
 01 WS-TREE.
    05 FILLER PIC X(4) VALUE "i".
    05 FILLER PIC S9(9) BINARY VALUE 3.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 10.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(4) VALUE "l".
    05 FILLER PIC S9(9) BINARY VALUE 4.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE -5.
    05 FILLER PIC S9(9) BINARY VALUE 5.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(4) VALUE "f".
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER COMP-2 VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(4) VALUE "d".
    05 FILLER PIC S9(9) BINARY VALUE 2.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER COMP-2 VALUE -1.
    05 FILLER COMP-2 VALUE 1.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(4) VALUE "b".
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(4) VALUE "s".
    05 FILLER PIC S9(9) BINARY VALUE 5.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 1.
    05 FILLER PIC X(4) VALUE "w".
    05 FILLER PIC S9(9) BINARY VALUE 5.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC X(4) VALUE "g".
    05 FILLER PIC S9(9) BINARY VALUE 5.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER COMP-2 VALUE 0.
    05 FILLER PIC S9(9) BINARY VALUE 2.
 01 WS-TREE-TABLE REDEFINES WS-TREE.
    05 WS-T OCCURS 8 TIMES.
       10 WS-T-LIT PIC X(4).
       10 WS-T-ID PIC S9(9) BINARY.
       10 WS-T-HMIN PIC S9(9) BINARY.
       10 WS-T-HMAX PIC S9(9) BINARY.
       10 WS-T-IMIN PIC S9(9) BINARY.
       10 WS-T-IMAX PIC S9(9) BINARY.
       10 WS-T-DMIN COMP-2.
       10 WS-T-DMAX COMP-2.
       10 WS-T-SK PIC S9(9) BINARY.
 01 WS-LINE                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-VERDICT             BINARY-LONG.
 01 WS-COMMAND             BINARY-LONG.
 01 WS-TEXT                PIC X(400).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FOO                 BINARY-LONG.
 01 WS-SHOWN               PIC X(1024).
 01 WS-SHOWN-LENGTH        BINARY-LONG.
 01 WS-EXPECTED            PIC X(240).
 01 WS-REST                PIC X(1024).
 01 WS-SUGGESTING          BINARY-LONG.
 01 WS-CURSOR              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "BR-TREE-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         PERFORM ADD-TYPE
     END-PERFORM
     PERFORM ADD-FOO
     PERFORM ADD-EXTRA
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE WS-CASE-LINE(WS-I) TO WS-LINE
         MOVE WS-CASE-EXPECTED(WS-I) TO WS-EXPECTED
         PERFORM CHECK
     END-PERFORM
     GOBACK.

*> A literal under the root with the argument "v" of the type row WS-I (command WS-I).
 ADD-TYPE.
     MOVE 1 TO WS-NODE
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE
     MOVE WS-T-LIT(WS-I) TO WS-NAME
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED
     MOVE WS-CHILD TO WS-NODE
     MOVE BR-ARGUMENT TO WS-KIND
     MOVE "v" TO WS-NAME
     MOVE 1 TO WS-NAME-LENGTH
     MOVE WS-T-ID(WS-I) TO WS-TYPE
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED
     MOVE WS-I TO BR-N-COMMAND(WS-CHILD)
     MOVE WS-T-HMIN(WS-I) TO BR-N-HAS-MIN(WS-CHILD)
     MOVE WS-T-HMAX(WS-I) TO BR-N-HAS-MAX(WS-CHILD)
     MOVE WS-T-IMIN(WS-I) TO BR-N-IMIN(WS-CHILD)
     MOVE WS-T-IMAX(WS-I) TO BR-N-IMAX(WS-CHILD)
     MOVE WS-T-DMIN(WS-I) TO BR-N-DMIN(WS-CHILD)
     MOVE WS-T-DMAX(WS-I) TO BR-N-DMAX(WS-CHILD)
     MOVE WS-T-SK(WS-I) TO BR-N-STRING-KIND(WS-CHILD).

*> foo (a command) with the children n = integer 1 to 10 (a command) and the literal bar (a command).
 ADD-FOO.
     MOVE 1 TO WS-NODE
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE
     MOVE "foo" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-FOO WS-CREATED
     MOVE 20 TO BR-N-COMMAND(WS-FOO)
     MOVE "n" TO WS-NAME
     MOVE 1 TO WS-NAME-LENGTH
     MOVE BR-ARGUMENT TO WS-KIND
     MOVE BR-P-INTEGER TO WS-TYPE
     CALL "BR-ADD-NODE" USING WS-FOO WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED
     MOVE 21 TO BR-N-COMMAND(WS-CHILD)
     MOVE 1 TO BR-N-HAS-MIN(WS-CHILD) BR-N-HAS-MAX(WS-CHILD)
     MOVE 1 TO BR-N-IMIN(WS-CHILD)
     MOVE 10 TO BR-N-IMAX(WS-CHILD)
     MOVE "bar" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE
     CALL "BR-ADD-NODE" USING WS-FOO WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED
     MOVE 22 TO BR-N-COMMAND(WS-CHILD).

 ADD-EXTRA.
*> adm: a command whose requirement is level 2; run: a redirect to the root; nc: no command, with the child x (a command).
     MOVE 1 TO WS-NODE
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE
     MOVE "adm" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED
     MOVE 30 TO BR-N-COMMAND(WS-CHILD)
     MOVE 2 TO BR-N-LEVEL(WS-CHILD)
     MOVE "run" TO WS-NAME
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED
     MOVE 1 TO BR-N-REDIRECT(WS-CHILD)
     MOVE "nc" TO WS-NAME
     MOVE 2 TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED
     MOVE WS-CHILD TO WS-NODE
     MOVE "x" TO WS-NAME
     MOVE 1 TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED
     MOVE 31 TO BR-N-COMMAND(WS-CHILD).

 CHECK.
     MOVE 4 TO WS-LEVEL
     IF WS-LINE(1:2) = "0>"
         MOVE 0 TO WS-LEVEL
         MOVE WS-LINE(3:) TO WS-REST
         MOVE WS-REST TO WS-LINE
     END-IF
     MOVE 0 TO WS-SUGGESTING
     IF WS-LINE(1:1) = "S" AND WS-LINE(3:1) = ">"
         MOVE 1 TO WS-SUGGESTING
         MOVE WS-LINE(2:1) TO WS-LEVEL
         MOVE WS-LINE(4:) TO WS-REST
         MOVE WS-REST TO WS-LINE
     END-IF
     IF WS-SUGGESTING = 1
         PERFORM CHECK-SUGGEST
     ELSE
         PERFORM CHECK-PARSE
     END-IF.

 CHECK-PARSE.
     MOVE 0 TO WS-LENGTH
     INSPECT WS-LINE TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL "$"
     MOVE SPACE TO WS-LINE(WS-LENGTH + 1:1)
     CALL "BR-PARSE" USING WS-LEVEL WS-LINE WS-LENGTH RS-TRAIL
     CALL "BR-VERDICT" USING RS-TRAIL WS-VERDICT WS-COMMAND
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     IF WS-VERDICT = 0
         MOVE "ok" TO WS-TEXT
     ELSE
         PERFORM DESCRIBE-ERROR
     END-IF
     MOVE SPACES TO TL-CASE
     STRING "acceptance US13 15a§8 Messages and exceptions [" WS-LINE(1:WS-LENGTH) "]" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECTED TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> The suggestions at the end of the line: sug= the entries joined by commas.
 CHECK-SUGGEST.
     MOVE 0 TO WS-LENGTH
     INSPECT WS-LINE TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL "$"
     MOVE SPACE TO WS-LINE(WS-LENGTH + 1:1)
     MOVE WS-LENGTH TO WS-CURSOR
     CALL "BR-SUGGEST" USING WS-LEVEL WS-LINE WS-LENGTH WS-CURSOR
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     STRING "sug=" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > BR-SG-COUNT
         IF WS-E > 1
             STRING "," DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-IF
         STRING BR-SG-TEXT(WS-E)(1:BR-SG-TEXT-LENGTH(WS-E)) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-PERFORM
     MOVE SPACES TO TL-CASE
     STRING "acceptance US13 15a§8 Messages and exceptions [" WS-LINE(1:WS-LENGTH) "]" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXPECTED TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> key|args@cursor|the text of the translation (BR-LANG-TEXT of the translate component).
 DESCRIBE-ERROR.
     STRING FUNCTION TRIM(BR-E-KEY) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     INITIALIZE PB-TEXT
     MOVE PB-TEXT-TRANSLATE TO PB-TX-KIND
     MOVE FUNCTION TRIM(BR-E-KEY) TO PB-TX-VALUE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(BR-E-KEY)) TO PB-TX-LENGTH
     MOVE BR-E-ARG-COUNT TO PB-TX-ARG-COUNT
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > BR-E-ARG-COUNT
         STRING "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         IF BR-E-ARG-LENGTH(WS-E) > 0
             STRING BR-E-ARG(WS-E)(1:BR-E-ARG-LENGTH(WS-E)) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
             MOVE BR-E-ARG(WS-E)(1:BR-E-ARG-LENGTH(WS-E)) TO PB-TX-ARG-VALUE(WS-E)
         END-IF
         MOVE BR-E-ARG-LENGTH(WS-E) TO PB-TX-ARG-LENGTH(WS-E)
     END-PERFORM
     MOVE BR-E-CURSOR TO WS-EDIT
     STRING "@" FUNCTION TRIM(WS-EDIT) "|" DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     CALL "BR-LANG-TEXT" USING PB-TEXT WS-SHOWN WS-SHOWN-LENGTH
     STRING WS-SHOWN(1:WS-SHOWN-LENGTH) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS.

 END PROGRAM TEST-CMD-15A-8.

 COPY CORETEST.

