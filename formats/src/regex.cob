*> Regular expressions for pack filter patterns (08 §3.3: Java Pattern.asPredicate, a find match
*> anywhere in the subject). REGEX-FIND compiles a pattern into the Thompson program of
*> CLREGEX.cpy and runs it as a breadth-first NFA simulation over the subject's bytes, so every
*> start position and every way through alternations and quantifiers is tried at once, without
*> the exponential cost of a backtracking matcher. Match or no match is the same as Java's
*> backtracking (greedy and lazy quantifiers differ only in the matched span, which the
*> predicate does not report).
*>
*> Supported subset of java.util.regex: literal bytes; "."; escapes \d \D \w \W \s \S, \t \n \r
*> \f \a \e, \xhh and a backslash before any other non-alphanumeric byte (that byte); classes
*> [...] and [^...] with ranges, escapes and a leading "]" or a leading or trailing "-" taken
*> literally; anchors ^ (start of the subject) and $ (end, or before a final line terminator);
*> groups (...) and (?:...); alternation |; quantifiers * + ? {n} {n,} {n,m} (greedy, or lazy
*> with a trailing ?). Anything else is an error: a malformed pattern (unbalanced parenthesis or
*> bracket, nothing to repeat, a bad repetition, a reversed range, a dangling backslash) or an
*> unsupported construct (backreferences, \b and other alphanumeric escapes, lookaround, inline
*> flags and named groups, possessive quantifiers, nested classes and && intersections, \p{..}).
*> A pattern whose program would exceed RX-MAX-OPS instructions or RX-MAX-CLASSES classes is an
*> error too. Bytes are matched one by one ("." matches one byte of a multi-byte character):
*> resource namespaces and paths are ASCII (08 §1.3).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-FIND.
*> USING pattern (PIC X(128)), pattern length (0 to 128), subject (PIC X(256)), subject length
*> (0 to 256), matched out (BINARY-LONG 1 when the pattern matches somewhere in the subject, else
*> 0), error out (BINARY-LONG 1 when the pattern is invalid or unsupported; matched is then 0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FMREGEX.
 01 WS-START               BINARY-LONG VALUE 1.
 01 WS-END                 BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO-Y              BINARY-LONG VALUE 0.
 01 WS-KIND                BINARY-LONG.
 01 WS-SUBJ-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-PAT                  PIC X(128).
 01 L-PAT-LENGTH           BINARY-LONG.
 01 L-SUBJ                 PIC X(256).
 01 L-SUBJ-LENGTH          BINARY-LONG.
 01 L-MATCHED              BINARY-LONG.
 01 L-ERROR                BINARY-LONG.
 PROCEDURE DIVISION USING L-PAT L-PAT-LENGTH L-SUBJ L-SUBJ-LENGTH L-MATCHED L-ERROR.
     MOVE 0 TO RX-ERROR RX-COUNT RX-CLASS-COUNT L-MATCHED
     COMPUTE WS-END = FUNCTION MAX(0, FUNCTION MIN(L-PAT-LENGTH, 128)) + 1
     COMPUTE WS-SUBJ-LENGTH = FUNCTION MAX(0, FUNCTION MIN(L-SUBJ-LENGTH, 256))
     CALL "REGEX-ALTS" USING REGEX-PROG L-PAT WS-START WS-END
     MOVE RX-OP-MATCH TO WS-KIND
     CALL "REGEX-EMIT" USING REGEX-PROG WS-KIND WS-ZERO WS-ZERO-Y
     IF RX-ERROR = 0
         CALL "REGEX-EXEC" USING REGEX-PROG REGEX-THREADS L-SUBJ WS-SUBJ-LENGTH L-MATCHED
     END-IF
     MOVE RX-ERROR TO L-ERROR
     GOBACK.
 END PROGRAM REGEX-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-EMIT.
*> USING REGEX-PROG, kind, x, y: appends an instruction (RX-ERROR 1 when the program is full or
*> already failed).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY FMREGEX.
 01 L-KIND                 BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 PROCEDURE DIVISION USING REGEX-PROG L-KIND L-X L-Y.
     IF RX-COUNT >= RX-MAX-OPS
         MOVE 1 TO RX-ERROR
     END-IF
     IF RX-ERROR = 0
         ADD 1 TO RX-COUNT
         MOVE L-KIND TO RX-KIND(RX-COUNT)
         MOVE L-X TO RX-X(RX-COUNT)
         MOVE L-Y TO RX-Y(RX-COUNT)
     END-IF
     GOBACK.
 END PROGRAM REGEX-EMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-ATOM-END RECURSIVE.
*> USING pattern (PIC X(128)), position of an atom, end (one past the last byte of the span),
*> atom end out (one past the atom), error out (BINARY-LONG): the extent of one atom: an escape
*> (\xhh is four bytes), a class up to its closing "]", a group up to its matching ")", or one
*> byte. A ")" here has no "(" and is an error, as is an unclosed class or group.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PAT                  PIC X(128).
 01 L-POS                  BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-ATOM-END             BINARY-LONG.
 01 L-ERROR                BINARY-LONG.
 PROCEDURE DIVISION USING L-PAT L-POS L-END L-ATOM-END L-ERROR.
     MOVE 0 TO L-ERROR
     COMPUTE L-ATOM-END = L-POS + 1
     EVALUATE L-PAT(L-POS:1)
         WHEN "\"
             MOVE 1 TO L-ERROR
             IF L-POS + 1 < L-END
                 MOVE 0 TO L-ERROR
                 COMPUTE L-ATOM-END = L-POS + 2
                 IF L-PAT(L-POS + 1:1) = "x"
                     COMPUTE L-ATOM-END = FUNCTION MIN(L-POS + 4, L-END)
                 END-IF
             END-IF
         WHEN "["
             COMPUTE LS-I = L-POS + 1
             IF LS-I < L-END
                 IF L-PAT(LS-I:1) = "^"
                     ADD 1 TO LS-I
                 END-IF
             END-IF
             IF LS-I < L-END
                 IF L-PAT(LS-I:1) = "]"
                     ADD 1 TO LS-I
                 END-IF
             END-IF
             MOVE 0 TO LS-DONE
             PERFORM UNTIL LS-DONE = 1
                 EVALUATE TRUE
                     WHEN LS-I >= L-END
                         MOVE 1 TO L-ERROR LS-DONE
                     WHEN L-PAT(LS-I:1) = "\"
                         ADD 2 TO LS-I
                     WHEN L-PAT(LS-I:1) = "]"
                         COMPUTE L-ATOM-END = LS-I + 1
                         MOVE 1 TO LS-DONE
                     WHEN OTHER
                         ADD 1 TO LS-I
                 END-EVALUATE
             END-PERFORM
         WHEN "("
             COMPUTE LS-I = L-POS + 1
             MOVE 0 TO LS-DONE
             PERFORM UNTIL LS-DONE = 1
                 EVALUATE TRUE
                     WHEN LS-I >= L-END
                         MOVE 1 TO L-ERROR LS-DONE
                     WHEN L-PAT(LS-I:1) = ")"
                         COMPUTE L-ATOM-END = LS-I + 1
                         MOVE 1 TO LS-DONE
                     WHEN L-PAT(LS-I:1) = "|" OR "*" OR "+" OR "?" OR "{"
                         ADD 1 TO LS-I
                     WHEN OTHER
                         CALL "REGEX-ATOM-END" USING L-PAT LS-I L-END LS-NEXT L-ERROR
                         MOVE LS-NEXT TO LS-I
                         MOVE L-ERROR TO LS-DONE
                 END-EVALUATE
             END-PERFORM
         WHEN ")"
             MOVE 1 TO L-ERROR
     END-EVALUATE
     GOBACK.
 END PROGRAM REGEX-ATOM-END.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-NEXT-BAR.
*> USING pattern (PIC X(128)), from, end, bar out, error out: the position of the next "|" at
*> the top level of the span from..end-1 (end when there is none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-PAT                  PIC X(128).
 01 L-FROM                 BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-BAR                  BINARY-LONG.
 01 L-ERROR                BINARY-LONG.
 PROCEDURE DIVISION USING L-PAT L-FROM L-END L-BAR L-ERROR.
     MOVE 0 TO L-ERROR L-BAR
     MOVE L-FROM TO WS-I
     PERFORM UNTIL L-BAR > 0 OR L-ERROR = 1
         EVALUATE TRUE
             WHEN WS-I >= L-END
                 MOVE L-END TO L-BAR
             WHEN L-PAT(WS-I:1) = "|"
                 MOVE WS-I TO L-BAR
             WHEN L-PAT(WS-I:1) = "*" OR "+" OR "?" OR "{"
                 ADD 1 TO WS-I
             WHEN OTHER
                 CALL "REGEX-ATOM-END" USING L-PAT WS-I L-END WS-NEXT L-ERROR
                 MOVE WS-NEXT TO WS-I
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM REGEX-NEXT-BAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-ALTS RECURSIVE.
*> USING REGEX-PROG, pattern (PIC X(128)), start, end: compiles the alternation in start..end-1:
*> SPLIT to each alternative and to the next SPLIT, every alternative but the last ending in a
*> JMP past the last one (the JMPs are chained through RX-X until the end is known).
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-P                   BINARY-LONG.
 01 LS-BAR                 BINARY-LONG.
 01 LS-ERROR               BINARY-LONG.
 01 LS-DONE                BINARY-LONG.
 01 LS-SPLIT               BINARY-LONG.
 01 LS-CHAIN               BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-ZERO                BINARY-LONG.
 LINKAGE SECTION.
 COPY FMREGEX.
 01 L-PAT                  PIC X(128).
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING REGEX-PROG L-PAT L-START L-END.
     MOVE L-START TO LS-P
     MOVE 0 TO LS-DONE LS-CHAIN LS-ZERO
     PERFORM UNTIL LS-DONE = 1 OR RX-ERROR = 1
         CALL "REGEX-NEXT-BAR" USING L-PAT LS-P L-END LS-BAR LS-ERROR
         EVALUATE TRUE
             WHEN LS-ERROR = 1
                 MOVE 1 TO RX-ERROR
             WHEN LS-BAR < L-END
                 COMPUTE LS-SPLIT = RX-COUNT + 1
                 COMPUTE LS-NEXT = RX-COUNT + 2
                 MOVE RX-OP-SPLIT TO LS-KIND
                 CALL "REGEX-EMIT" USING REGEX-PROG LS-KIND LS-NEXT LS-ZERO
                 CALL "REGEX-SEQ" USING REGEX-PROG L-PAT LS-P LS-BAR
                 MOVE RX-OP-JMP TO LS-KIND
                 CALL "REGEX-EMIT" USING REGEX-PROG LS-KIND LS-CHAIN LS-ZERO
                 IF RX-ERROR = 0
                     MOVE RX-COUNT TO LS-CHAIN
                     COMPUTE RX-Y(LS-SPLIT) = RX-COUNT + 1
                 END-IF
                 COMPUTE LS-P = LS-BAR + 1
             WHEN OTHER
                 CALL "REGEX-SEQ" USING REGEX-PROG L-PAT LS-P L-END
                 MOVE 1 TO LS-DONE
         END-EVALUATE
     END-PERFORM
     PERFORM UNTIL LS-CHAIN = 0
         MOVE RX-X(LS-CHAIN) TO LS-NEXT
         COMPUTE RX-X(LS-CHAIN) = RX-COUNT + 1
         MOVE LS-NEXT TO LS-CHAIN
     END-PERFORM
     GOBACK.
 END PROGRAM REGEX-ALTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-QUANT.
*> USING pattern (PIC X(128)), position (moved past the quantifier), end, minimum out, maximum
*> out (-1 = no limit), error out: the quantifier at the position, if any (none: 1 and 1). A
*> lazy "?" after it is accepted, a possessive "+" is unsupported, and a further quantifier
*> right after it is an error (Java: dangling meta character). Counts above 1000 are refused.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FOUND               BINARY-LONG.
 01 WS-DIGITS              BINARY-LONG.
 01 WS-FIRST-DIGITS        BINARY-LONG.
 01 WS-CLOSED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-PAT                  PIC X(128).
 01 L-POS                  BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-MIN                  BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-ERROR                BINARY-LONG.
 PROCEDURE DIVISION USING L-PAT L-POS L-END L-MIN L-MAX L-ERROR.
     MOVE 1 TO L-MIN L-MAX
     MOVE 0 TO L-ERROR WS-FOUND
     IF L-POS < L-END
         MOVE 1 TO WS-FOUND
         EVALUATE L-PAT(L-POS:1)
             WHEN "*"
                 MOVE 0 TO L-MIN
                 MOVE -1 TO L-MAX
             WHEN "+"
                 MOVE -1 TO L-MAX
             WHEN "?"
                 MOVE 0 TO L-MIN
             WHEN "{"
                 ADD 1 TO L-POS
                 CALL "REGEX-NUMBER" USING L-PAT L-POS L-END L-MIN WS-DIGITS
                 MOVE WS-DIGITS TO WS-FIRST-DIGITS
                 MOVE L-MIN TO L-MAX
                 MOVE 0 TO WS-CLOSED
                 IF L-POS < L-END
                     IF L-PAT(L-POS:1) = ","
                         ADD 1 TO L-POS
                         CALL "REGEX-NUMBER" USING L-PAT L-POS L-END L-MAX WS-DIGITS
                         IF WS-DIGITS = 0
                             MOVE -1 TO L-MAX
                         END-IF
                     END-IF
                 END-IF
                 IF L-POS < L-END
                     IF L-PAT(L-POS:1) = "}"
                         MOVE 1 TO WS-CLOSED
                     END-IF
                 END-IF
                 IF WS-FIRST-DIGITS = 0 OR WS-CLOSED = 0 OR L-MIN > 1000 OR L-MAX > 1000
                         OR (L-MAX >= 0 AND L-MIN > L-MAX)
                     MOVE 1 TO L-ERROR
                 END-IF
             WHEN OTHER
                 MOVE 0 TO WS-FOUND
                 SUBTRACT 1 FROM L-POS
         END-EVALUATE
         ADD 1 TO L-POS
     END-IF
     IF WS-FOUND = 1 AND L-POS < L-END
         EVALUATE L-PAT(L-POS:1)
             WHEN "?"
                 ADD 1 TO L-POS
             WHEN "+"
                 MOVE 1 TO L-ERROR
         END-EVALUATE
     END-IF
     IF WS-FOUND = 1 AND L-POS < L-END
         IF L-PAT(L-POS:1) = "*" OR "+" OR "?" OR "{"
             MOVE 1 TO L-ERROR
         END-IF
     END-IF
     GOBACK.
 END PROGRAM REGEX-QUANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-NUMBER.
*> USING pattern (PIC X(128)), position (moved past the digits), end, value out, digit count
*> out: a decimal number (at most 6 digits are read into the value; more stay in the count).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PAT                  PIC X(128).
 01 L-POS                  BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-DIGITS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PAT L-POS L-END L-VALUE L-DIGITS.
     MOVE 0 TO L-VALUE L-DIGITS
     PERFORM UNTIL L-POS >= L-END
         IF L-PAT(L-POS:1) IS NOT NUMERIC
             EXIT PERFORM
         END-IF
         IF L-DIGITS < 6
             COMPUTE L-VALUE = L-VALUE * 10 + FUNCTION NUMVAL(L-PAT(L-POS:1))
         END-IF
         ADD 1 TO L-DIGITS L-POS
     END-PERFORM
     GOBACK.
 END PROGRAM REGEX-NUMBER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-SEQ RECURSIVE.
*> USING REGEX-PROG, pattern (PIC X(128)), start, end: compiles a sequence of quantified atoms
*> (no top-level "|"): an atom repeated n to m times is n copies, then m - n optional copies
*> (SPLIT over each), or a loop (SPLIT into the atom, JMP back) when m has no limit.
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-I                   BINARY-LONG.
 01 LS-ATOM-END            BINARY-LONG.
 01 LS-Q                   BINARY-LONG.
 01 LS-MIN                 BINARY-LONG.
 01 LS-MAX                 BINARY-LONG.
 01 LS-N                   BINARY-LONG.
 01 LS-ERROR               BINARY-LONG.
 01 LS-LOOP                BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-ZERO                BINARY-LONG.
 LINKAGE SECTION.
 COPY FMREGEX.
 01 L-PAT                  PIC X(128).
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING REGEX-PROG L-PAT L-START L-END.
     MOVE L-START TO LS-I
     MOVE 0 TO LS-ZERO
     PERFORM UNTIL LS-I >= L-END OR RX-ERROR = 1
         MOVE 0 TO LS-ERROR
         IF L-PAT(LS-I:1) = "*" OR "+" OR "?" OR "{"
             MOVE 1 TO LS-ERROR
         ELSE
             CALL "REGEX-ATOM-END" USING L-PAT LS-I L-END LS-ATOM-END LS-ERROR
         END-IF
         IF LS-ERROR = 0
             MOVE LS-ATOM-END TO LS-Q
             CALL "REGEX-QUANT" USING L-PAT LS-Q L-END LS-MIN LS-MAX LS-ERROR
         END-IF
         IF LS-ERROR = 1
             MOVE 1 TO RX-ERROR
         ELSE
             PERFORM LS-MIN TIMES
                 CALL "REGEX-EMIT-ATOM" USING REGEX-PROG L-PAT LS-I LS-ATOM-END
             END-PERFORM
             IF LS-MAX < 0
                 COMPUTE LS-LOOP = RX-COUNT + 1
                 COMPUTE LS-NEXT = RX-COUNT + 2
                 MOVE RX-OP-SPLIT TO LS-KIND
                 CALL "REGEX-EMIT" USING REGEX-PROG LS-KIND LS-NEXT LS-ZERO
                 CALL "REGEX-EMIT-ATOM" USING REGEX-PROG L-PAT LS-I LS-ATOM-END
                 MOVE RX-OP-JMP TO LS-KIND
                 CALL "REGEX-EMIT" USING REGEX-PROG LS-KIND LS-LOOP LS-ZERO
                 IF RX-ERROR = 0
                     COMPUTE RX-Y(LS-LOOP) = RX-COUNT + 1
                 END-IF
             ELSE
                 COMPUTE LS-N = LS-MAX - LS-MIN
                 PERFORM LS-N TIMES
                     COMPUTE LS-LOOP = RX-COUNT + 1
                     COMPUTE LS-NEXT = RX-COUNT + 2
                     MOVE RX-OP-SPLIT TO LS-KIND
                     CALL "REGEX-EMIT" USING REGEX-PROG LS-KIND LS-NEXT LS-ZERO
                     CALL "REGEX-EMIT-ATOM" USING REGEX-PROG L-PAT LS-I LS-ATOM-END
                     IF RX-ERROR = 0
                         COMPUTE RX-Y(LS-LOOP) = RX-COUNT + 1
                     END-IF
                 END-PERFORM
             END-IF
         END-IF
         MOVE LS-Q TO LS-I
     END-PERFORM
     GOBACK.
 END PROGRAM REGEX-SEQ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-EMIT-ATOM RECURSIVE.
*> USING REGEX-PROG, pattern (PIC X(128)), atom start, atom end: emits one copy of an atom
*> (a group compiles its inside through REGEX-ALTS; "(?:" is the only "(?" form supported).
 DATA DIVISION.
 LOCAL-STORAGE SECTION.
 01 LS-IN                  BINARY-LONG.
 01 LS-CLOSE               BINARY-LONG.
 01 LS-KIND                BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-ZERO                BINARY-LONG.
 01 LS-ESC-KIND            BINARY-LONG.
 01 LS-NEXT                BINARY-LONG.
 01 LS-ERROR               BINARY-LONG.
 LINKAGE SECTION.
 COPY FMREGEX.
 01 L-PAT                  PIC X(128).
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING REGEX-PROG L-PAT L-START L-END.
     IF RX-ERROR = 1
         GOBACK
     END-IF
     MOVE 0 TO LS-ZERO LS-X
     MOVE RX-OP-CHAR TO LS-KIND
     EVALUATE L-PAT(L-START:1)
         WHEN "("
             COMPUTE LS-IN = L-START + 1
             COMPUTE LS-CLOSE = L-END - 1
             IF L-PAT(LS-IN:1) = "?"
                 MOVE 1 TO RX-ERROR
                 IF LS-IN + 1 < LS-CLOSE
                     IF L-PAT(LS-IN + 1:1) = ":"
                         MOVE 0 TO RX-ERROR
                         ADD 2 TO LS-IN
                     END-IF
                 END-IF
             END-IF
             IF RX-ERROR = 0
                 CALL "REGEX-ALTS" USING REGEX-PROG L-PAT LS-IN LS-CLOSE
             END-IF
             MOVE 0 TO LS-KIND
         WHEN "["
             CALL "REGEX-CLASS" USING REGEX-PROG L-PAT L-START L-END
             MOVE 0 TO LS-KIND
         WHEN "."
             MOVE RX-OP-ANY TO LS-KIND
         WHEN "^"
             MOVE RX-OP-BOL TO LS-KIND
         WHEN "$"
             MOVE RX-OP-EOL TO LS-KIND
         WHEN "\"
             CALL "REGEX-ESCAPE" USING L-PAT L-START L-END LS-ESC-KIND LS-X LS-NEXT LS-ERROR
             EVALUATE TRUE
                 WHEN LS-ERROR = 1
                     MOVE 1 TO RX-ERROR
                     MOVE 0 TO LS-KIND
                 WHEN LS-ESC-KIND = 2
                     CALL "REGEX-SHORTHAND-CLASS" USING REGEX-PROG LS-X
                     MOVE 0 TO LS-KIND
             END-EVALUATE
         WHEN OTHER
             MOVE FUNCTION ORD(L-PAT(L-START:1)) TO LS-X
     END-EVALUATE
     IF LS-KIND > 0
         CALL "REGEX-EMIT" USING REGEX-PROG LS-KIND LS-X LS-ZERO
     END-IF
     GOBACK.
 END PROGRAM REGEX-EMIT-ATOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-ESCAPE.
*> USING pattern (PIC X(128)), position of the backslash, end, kind out (1 a byte, 2 a shorthand
*> class), value out (the byte's ordinal, or the ordinal of the shorthand letter d D w W s S),
*> next position out, error out (a bad \x, or an alphanumeric escape this subset does not
*> support). REGEX-ATOM-END has made sure a byte follows the backslash inside the span.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-C                   PIC X.
 01 WS-HEX                 PIC X(16) VALUE "0123456789ABCDEF".
 01 WS-H                   PIC X.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DIGIT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-PAT                  PIC X(128).
 01 L-POS                  BINARY-LONG.
 01 L-END                  BINARY-LONG.
 01 L-KIND                 BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-NEXT                 BINARY-LONG.
 01 L-ERROR                BINARY-LONG.
 PROCEDURE DIVISION USING L-PAT L-POS L-END L-KIND L-VALUE L-NEXT L-ERROR.
     MOVE 1 TO L-KIND
     MOVE 0 TO L-ERROR L-VALUE
     COMPUTE L-NEXT = L-POS + 2
     MOVE L-PAT(L-POS + 1:1) TO WS-C
     EVALUATE TRUE
         WHEN WS-C = "d" OR "D" OR "w" OR "W" OR "s" OR "S"
             MOVE 2 TO L-KIND
             MOVE FUNCTION ORD(WS-C) TO L-VALUE
         WHEN WS-C = "t"
             MOVE 10 TO L-VALUE
         WHEN WS-C = "n"
             MOVE 11 TO L-VALUE
         WHEN WS-C = "r"
             MOVE 14 TO L-VALUE
         WHEN WS-C = "f"
             MOVE 13 TO L-VALUE
         WHEN WS-C = "a"
             MOVE 8 TO L-VALUE
         WHEN WS-C = "e"
             MOVE 28 TO L-VALUE
         WHEN WS-C = "x"
             COMPUTE L-NEXT = L-POS + 4
             IF L-NEXT > L-END
                 MOVE 1 TO L-ERROR
             END-IF
             PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 3 OR L-ERROR = 1
                 MOVE FUNCTION UPPER-CASE(L-PAT(L-POS + WS-I:1)) TO WS-H
                 MOVE -1 TO WS-DIGIT
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 16
                     IF WS-HEX(WS-K:1) = WS-H
                         COMPUTE WS-DIGIT = WS-K - 1
                     END-IF
                 END-PERFORM
                 IF WS-DIGIT < 0
                     MOVE 1 TO L-ERROR
                 END-IF
                 COMPUTE L-VALUE = L-VALUE * 16 + WS-DIGIT
             END-PERFORM
             ADD 1 TO L-VALUE
         WHEN (WS-C >= "a" AND WS-C <= "z") OR (WS-C >= "A" AND WS-C <= "Z")
                 OR (WS-C >= "0" AND WS-C <= "9")
             MOVE 1 TO L-ERROR
         WHEN OTHER
             MOVE FUNCTION ORD(WS-C) TO L-VALUE
     END-EVALUATE
     GOBACK.
 END PROGRAM REGEX-ESCAPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-SHORTHAND.
*> USING letter ordinal (BINARY-LONG: d D w W s S), set (PIC X(256), one "0"/"1" flag per byte
*> ordinal): adds the shorthand's bytes to the set (\d [0-9], \w [a-zA-Z_0-9], \s [ \t\n\x0B\f\r];
*> the upper-case letters add every other byte).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SET                 PIC X(256).
 01 WS-C                   PIC X.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-LETTER               BINARY-LONG.
 01 L-SET                  PIC X(256).
 PROCEDURE DIVISION USING L-LETTER L-SET.
     MOVE ALL "0" TO WS-SET
     MOVE FUNCTION CHAR(L-LETTER) TO WS-C
     MOVE FUNCTION LOWER-CASE(WS-C) TO WS-C
     MOVE ALL "1" TO WS-SET(49:10)
     EVALUATE WS-C
         WHEN "w"
             MOVE ALL "1" TO WS-SET(66:26)
             MOVE ALL "1" TO WS-SET(98:26)
             MOVE "1" TO WS-SET(96:1)
         WHEN "s"
             MOVE ALL "0" TO WS-SET(49:10)
             MOVE ALL "1" TO WS-SET(10:5)
             MOVE "1" TO WS-SET(33:1)
     END-EVALUATE
     IF FUNCTION CHAR(L-LETTER) NOT = WS-C
         INSPECT WS-SET CONVERTING "01" TO "10"
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         IF WS-SET(WS-I:1) = "1"
             MOVE "1" TO L-SET(WS-I:1)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REGEX-SHORTHAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-SHORTHAND-CLASS.
*> USING REGEX-PROG, letter ordinal: emits a CLASS of a shorthand escape outside brackets.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SET                 PIC X(256).
 LINKAGE SECTION.
 COPY FMREGEX.
 01 L-LETTER               BINARY-LONG.
 PROCEDURE DIVISION USING REGEX-PROG L-LETTER.
     MOVE ALL "0" TO WS-SET
     CALL "REGEX-SHORTHAND" USING L-LETTER WS-SET
     CALL "REGEX-ADD-CLASS" USING REGEX-PROG WS-SET
     GOBACK.
 END PROGRAM REGEX-SHORTHAND-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-ADD-CLASS.
*> USING REGEX-PROG, set (PIC X(256)): stores the set as a new class and emits CLASS (RX-ERROR 1
*> when the class table is full).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KIND                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 COPY FMREGEX.
 01 L-SET                  PIC X(256).
 PROCEDURE DIVISION USING REGEX-PROG L-SET.
     IF RX-CLASS-COUNT >= RX-MAX-CLASSES
         MOVE 1 TO RX-ERROR
     END-IF
     IF RX-ERROR = 0
         ADD 1 TO RX-CLASS-COUNT
         MOVE L-SET TO RX-CLASS(RX-CLASS-COUNT)
         MOVE RX-OP-CLASS TO WS-KIND
         CALL "REGEX-EMIT" USING REGEX-PROG WS-KIND RX-CLASS-COUNT WS-ZERO
     END-IF
     GOBACK.
 END PROGRAM REGEX-ADD-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-CLASS.
*> USING REGEX-PROG, pattern (PIC X(128)), class start (the "["), class end (one past its "]"):
*> builds the set of a bracket class (bytes, escapes, shorthands, ranges lo-hi; "^" first
*> negates) and emits it. A nested "[", "&&", a reversed range or a shorthand as a range end is
*> an error.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SET                 PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-NEG                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-HI-POS              BINARY-LONG.
 01 WS-ERROR               BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 COPY FMREGEX.
 01 L-PAT                  PIC X(128).
 01 L-START                BINARY-LONG.
 01 L-END                  BINARY-LONG.
 PROCEDURE DIVISION USING REGEX-PROG L-PAT L-START L-END.
     MOVE ALL "0" TO WS-SET
     COMPUTE WS-I = L-START + 1
     COMPUTE WS-LAST = L-END - 1
     MOVE 0 TO WS-NEG WS-ERROR
     IF L-PAT(WS-I:1) = "^"
         MOVE 1 TO WS-NEG
         ADD 1 TO WS-I
     END-IF
     PERFORM UNTIL WS-I >= WS-LAST OR WS-ERROR = 1
         MOVE 1 TO WS-KIND
         COMPUTE WS-NEXT = WS-I + 1
         MOVE FUNCTION ORD(L-PAT(WS-I:1)) TO WS-LO
         EVALUATE TRUE
             WHEN L-PAT(WS-I:1) = "\"
                 CALL "REGEX-ESCAPE" USING L-PAT WS-I L-END WS-KIND WS-LO WS-NEXT WS-ERROR
             WHEN L-PAT(WS-I:1) = "["
                 MOVE 1 TO WS-ERROR
             WHEN L-PAT(WS-I:2) = "&&"
                 MOVE 1 TO WS-ERROR
         END-EVALUATE
         MOVE WS-LO TO WS-HI
         IF WS-KIND = 2
             CALL "REGEX-SHORTHAND" USING WS-LO WS-SET
         END-IF
         COMPUTE WS-HI-POS = WS-NEXT + 1
         IF WS-KIND = 1 AND WS-ERROR = 0 AND WS-HI-POS < WS-LAST
             IF L-PAT(WS-NEXT:1) = "-"
                 COMPUTE WS-NEXT = WS-HI-POS + 1
                 MOVE FUNCTION ORD(L-PAT(WS-HI-POS:1)) TO WS-HI
                 EVALUATE TRUE
                     WHEN L-PAT(WS-HI-POS:1) = "\"
                         CALL "REGEX-ESCAPE" USING L-PAT WS-HI-POS L-END WS-KIND WS-HI WS-NEXT
                             WS-ERROR
                     WHEN L-PAT(WS-HI-POS:1) = "["
                         MOVE 1 TO WS-ERROR
                 END-EVALUATE
                 IF WS-KIND = 2 OR WS-LO > WS-HI
                     MOVE 1 TO WS-ERROR
                 END-IF
             END-IF
         END-IF
         IF WS-KIND = 1 AND WS-ERROR = 0
             PERFORM VARYING WS-K FROM WS-LO BY 1 UNTIL WS-K > WS-HI
                 MOVE "1" TO WS-SET(WS-K:1)
             END-PERFORM
         END-IF
         MOVE WS-NEXT TO WS-I
     END-PERFORM
     IF WS-NEG = 1
         INSPECT WS-SET CONVERTING "01" TO "10"
     END-IF
     IF WS-ERROR = 1
         MOVE 1 TO RX-ERROR
     END-IF
     CALL "REGEX-ADD-CLASS" USING REGEX-PROG WS-SET
     GOBACK.
 END PROGRAM REGEX-CLASS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-EXEC.
*> USING REGEX-PROG, REGEX-THREADS, subject (PIC X(256)), subject length, matched out: runs the
*> program over the subject (Pike/Thompson simulation): before each byte a new thread starts at
*> instruction 1 (find: a match may start anywhere), then every thread at a byte-consuming
*> instruction that accepts the byte moves on. "." accepts every byte but LF and CR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-POS                 BINARY-LONG.
 01 WS-NEXT-POS            BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PC                  BINARY-LONG.
 01 WS-NEXT-PC             BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-CURRENT             BINARY-LONG VALUE 1.
 01 WS-FOLLOWING           BINARY-LONG VALUE 2.
 01 WS-ORD                 BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-SET                 PIC X(256).
 01 WS-OK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY FMREGEX.
 01 L-SUBJ                 PIC X(256).
 01 L-SUBJ-LENGTH          BINARY-LONG.
 01 L-MATCHED              BINARY-LONG.
 PROCEDURE DIVISION USING REGEX-PROG REGEX-THREADS L-SUBJ L-SUBJ-LENGTH L-MATCHED.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RX-COUNT
         MOVE 0 TO RR-MARK(WS-K)
     END-PERFORM
     MOVE 0 TO RR-MATCHED RR-N(1) WS-DONE
     MOVE 1 TO WS-POS
     PERFORM UNTIL WS-DONE = 1
         CALL "REGEX-ADD" USING REGEX-PROG REGEX-THREADS L-SUBJ L-SUBJ-LENGTH WS-POS WS-ONE
             WS-CURRENT
         IF RR-MATCHED = 1 OR WS-POS > L-SUBJ-LENGTH
             MOVE 1 TO WS-DONE
         ELSE
             MOVE 0 TO RR-N(2)
             COMPUTE WS-NEXT-POS = WS-POS + 1
             MOVE FUNCTION ORD(L-SUBJ(WS-POS:1)) TO WS-ORD
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > RR-N(1)
                 MOVE RR-PC(1, WS-K) TO WS-PC
                 MOVE 0 TO WS-OK
                 EVALUATE RX-KIND(WS-PC)
                     WHEN RX-OP-CHAR
                         IF WS-ORD = RX-X(WS-PC)
                             MOVE 1 TO WS-OK
                         END-IF
                     WHEN RX-OP-ANY
                         IF WS-ORD NOT = 11 AND WS-ORD NOT = 14
                             MOVE 1 TO WS-OK
                         END-IF
                     WHEN RX-OP-CLASS
                         MOVE RX-X(WS-PC) TO WS-CLASS
                         MOVE RX-CLASS(WS-CLASS) TO WS-SET
                         IF WS-SET(WS-ORD:1) = "1"
                             MOVE 1 TO WS-OK
                         END-IF
                 END-EVALUATE
                 IF WS-OK = 1
                     COMPUTE WS-NEXT-PC = WS-PC + 1
                     CALL "REGEX-ADD" USING REGEX-PROG REGEX-THREADS L-SUBJ L-SUBJ-LENGTH
                         WS-NEXT-POS WS-NEXT-PC WS-FOLLOWING
                 END-IF
             END-PERFORM
             MOVE RR-LIST(2) TO RR-LIST(1)
             MOVE WS-NEXT-POS TO WS-POS
         END-IF
     END-PERFORM
     MOVE RR-MATCHED TO L-MATCHED
     GOBACK.
 END PROGRAM REGEX-EXEC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. REGEX-ADD.
*> USING REGEX-PROG, REGEX-THREADS, subject (PIC X(256)), subject length, position, instruction,
*> list (1 or 2): adds the thread and every thread reachable from it without consuming a byte
*> (JMP, SPLIT, and BOL/EOL when they hold at the position) to the list; an instruction is taken
*> once per position (RR-MARK holds the position it was last taken at). Reaching MATCH sets
*> RR-MATCHED. EOL holds at the end and before a final LF, CR or CR LF.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 LINKAGE SECTION.
 COPY FMREGEX.
 01 L-SUBJ                 PIC X(256).
 01 L-SUBJ-LENGTH          BINARY-LONG.
 01 L-POS                  BINARY-LONG.
 01 L-PC                   BINARY-LONG.
 01 L-LIST                 BINARY-LONG.
 PROCEDURE DIVISION USING REGEX-PROG REGEX-THREADS L-SUBJ L-SUBJ-LENGTH L-POS L-PC L-LIST.
     MOVE 1 TO RR-STACK-N
     MOVE L-PC TO RR-STACK(1)
     PERFORM UNTIL RR-STACK-N = 0
         MOVE RR-STACK(RR-STACK-N) TO WS-P
         SUBTRACT 1 FROM RR-STACK-N
         IF RR-MARK(WS-P) NOT = L-POS
             MOVE L-POS TO RR-MARK(WS-P)
             EVALUATE RX-KIND(WS-P)
                 WHEN RX-OP-JMP
                     ADD 1 TO RR-STACK-N
                     MOVE RX-X(WS-P) TO RR-STACK(RR-STACK-N)
                 WHEN RX-OP-SPLIT
                     ADD 1 TO RR-STACK-N
                     MOVE RX-Y(WS-P) TO RR-STACK(RR-STACK-N)
                     ADD 1 TO RR-STACK-N
                     MOVE RX-X(WS-P) TO RR-STACK(RR-STACK-N)
                 WHEN RX-OP-BOL
                     IF L-POS = 1
                         ADD 1 TO RR-STACK-N
                         COMPUTE RR-STACK(RR-STACK-N) = WS-P + 1
                     END-IF
                 WHEN RX-OP-EOL
                     COMPUTE WS-REST = L-SUBJ-LENGTH - L-POS + 1
                     MOVE 0 TO WS-HOLDS
                     EVALUATE WS-REST
                         WHEN 0
                             MOVE 1 TO WS-HOLDS
                         WHEN 1
                             IF L-SUBJ(L-POS:1) = X"0A" OR L-SUBJ(L-POS:1) = X"0D"
                                 MOVE 1 TO WS-HOLDS
                             END-IF
                         WHEN 2
                             IF L-SUBJ(L-POS:2) = X"0D0A"
                                 MOVE 1 TO WS-HOLDS
                             END-IF
                     END-EVALUATE
                     IF WS-HOLDS = 1
                         ADD 1 TO RR-STACK-N
                         COMPUTE RR-STACK(RR-STACK-N) = WS-P + 1
                     END-IF
                 WHEN RX-OP-MATCH
                     MOVE 1 TO RR-MATCHED
                 WHEN OTHER
                     ADD 1 TO RR-N(L-LIST)
                     MOVE WS-P TO RR-PC(L-LIST, RR-N(L-LIST))
             END-EVALUATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM REGEX-ADD.
